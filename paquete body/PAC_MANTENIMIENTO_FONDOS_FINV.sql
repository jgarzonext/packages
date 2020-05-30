--------------------------------------------------------
--  DDL for Package Body PAC_MANTENIMIENTO_FONDOS_FINV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MANTENIMIENTO_FONDOS_FINV" AS
   /******************************************************************************
     NOMBRE:       PAC_MANTENIMIENTO_FONDOS_FINV
     PROPÓSITO:
     REVISIONES:

     Ver        Fecha        Autor     Descripción
     ---------  ----------  -------- ------------------------------------
      1.0       -            -       1. Creación de package
      2.0       17/03/2009  RSC      2. Análisis adaptación productos indexados
      2.1       07/04/2009  RSC      2.1 Análisis adaptación productos indexados
      3.0       17/09/2009  RSC      3. Bug 0010828: CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      4.0       03/11/2009  JMF      4. 0011678 CRE - Ajustes cartera PPJ dinámico y Pla Estudiant
      5.0       03/11/2009  NMM      5. 12275: CRE - Cálculo de provisión en vencimientos del PPJ Dinámico.
      6.0       16/04/2010  RSC      6. 0014160: CEM800 - Adaptar packages de productos de inversión al nuevo módulo de siniestros
      7.0       06/10/2010  FAL      7. 0016219: GRC - Pagos de siniestros de dos garantías
      8.0       10/02/2011  SRA      8. 0017630: CRE800 - Ajuste fondos
      9.0       25/02/2011  APD      9. 0015707: ENSA102 - Valors liquidatius - Estat actual
     10.0       07/06/2011  JMF     10. 0018741: Job de carga de valor liquidativo diario
     11.0       28/06/2011  RSC     11. 0018851: ENSA102 - Parametrización básica de traspasos de Contribución definida
     12.0       30/11/2011  RSC     12. 0020309: LCOL_T004-Parametrización Fondos
     13.0       08/11/2011  JMP     13. 0018423: LCOL000 - Multimoneda
     14.0       15/12/2011  JMP     14. 0018423: LCOL705 - Multimoneda
     15.0       28/02/2012  RSC     15. 0020309: LCOL_T004-Parametrización Fondos
     16.0       6/10/215    JCP     16. 0033665: MSV, Cambio funcion f_set_fondo
     17.0       07/10/2015  YDA     17. 0033665: Creación de la función f_asign_dividends
      ******************************************************************************/

   /*
     Función que determina si a una fecha determinada estan valoradas todas las cestas vigentes
   */
   FUNCTION f_cestas_valoradas(
      pfasig IN DATE,
      pcempres IN NUMBER,
      pccodfon IN NUMBER DEFAULT NULL,
      psseguro IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vcontador      NUMBER := 0;
      vvaloradas     NUMBER := 0;
      -- RSC 08/08/2008
      vpfasig        DATE;
   BEGIN
      vpfasig := pfasig;

      IF pccodfon IS NULL THEN
         IF psseguro IS NOT NULL THEN
            -- BUG30181:DRA:13/11/2014: Añadimos la revision de fondos por seguro
            SELECT COUNT(*)
              INTO vvaloradas
              FROM tabvalces t, fondos f, segdisin2 s
             WHERE s.sseguro = psseguro
               AND s.nmovimi = (SELECT MAX(s1.nmovimi)
                                  FROM segdisin2 s1
                                 WHERE s1.sseguro = s.sseguro
                                   AND s1.nriesgo = s.nriesgo)
               AND s.ffin IS NULL
               AND f.ccodfon = s.ccesta
               AND f.cempres = pcempres
               AND f.ffin IS NULL
               AND t.ccesta = f.ccodfon
               AND TRUNC(t.fvalor) = TRUNC(vpfasig);

            SELECT COUNT(*)
              INTO vcontador
              FROM fondos f, segdisin2 s
             WHERE s.sseguro = psseguro
               AND s.nmovimi = (SELECT MAX(s1.nmovimi)
                                  FROM segdisin2 s1
                                 WHERE s1.sseguro = s.sseguro
                                   AND s1.nriesgo = s.nriesgo)
               AND s.ffin IS NULL
               AND f.ccodfon = s.ccesta
               AND f.cempres = pcempres
               AND f.ffin IS NULL;
         -- BUG30181:DRA:13/11/2014: Fi
         ELSE
            -- Bug 9031 - 12/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
            -- Simplificación Unit Linked. Eliminamos las cestas (ctipfon = 3)
            SELECT COUNT(*)
              INTO vvaloradas
              FROM tabvalces t, fondos f
             WHERE TRUNC(t.fvalor) = TRUNC(vpfasig)
               AND t.ccesta = f.ccodfon
               AND f.cempres = pcempres
               AND f.ffin IS NULL;

            SELECT COUNT(*)
              INTO vcontador
              FROM fondos
             WHERE ffin IS NULL
               AND cempres = pcempres;
         END IF;
      ELSE
         SELECT COUNT(*)
           INTO vvaloradas
           FROM tabvalces t, fondos f
          WHERE TRUNC(t.fvalor) = TRUNC(vpfasig)
            AND t.ccesta = f.ccodfon
            AND f.cempres = pcempres
            AND f.ccodfon = pccodfon
            AND f.ffin IS NULL;

         SELECT COUNT(*)
           INTO vcontador
           FROM fondos
          WHERE ffin IS NULL
            AND cempres = pcempres
            AND ccodfon = pccodfon;
      END IF;

      --and ccodfon IN (select distinct ccodfon from modinvfondo);
      RETURN(vvaloradas - vcontador);
-- Si contador <> 0 --> Hay cestas en la fecha indicada que no estan valoradas
   END f_cestas_valoradas;

-- -----------------------------------------------------------------------------------
-- Obtención de importes todavia no asignados ( Revisar el tema este del < 10 )
-- -----------------------------------------------------------------------------------
   PROCEDURE f_get_importes_asignar(seguro IN NUMBER, pfefecto IN DATE, importes OUT NUMBER) IS
      CURSOR cctaseguro IS
         SELECT sseguro, cmovimi, imovimi, nunidad, cesta, fvalmov, cestado, fcontab, nnumlin
           FROM ctaseguro
          WHERE sseguro = seguro
            AND cestado IN('1', '9')
            AND cmovanu = 0
            AND cesta IS NOT NULL
            AND(nunidad <= 0
                OR nunidad IS NULL
                OR imovimi = 0)
            AND TRUNC(fvalmov) <= TRUNC(pfefecto);

      importe        NUMBER;
      unidades       NUMBER;
      preciounidad   NUMBER;
      impmovimi      NUMBER;
      vfdiahabil     DATE;
   BEGIN
      importes := 0;

      -- es el valor absoluto de importes (ya sean negativos o positivos)
      FOR valor IN cctaseguro LOOP
         /*
           IF valor.cmovimi < 10 THEN
                importe := valor.imovimi * -1;
           ELSE
                importe := valor.imovimi;
           END IF;
         */
         IF valor.cmovimi IN(5, 6, 7, 21, 22, 23, 24, 26, 27, 28, 29, 39, 58, 83, 84, 91, 93,
                             94, 97, 87) THEN
            importe := valor.imovimi * -1;
         END IF;

         unidades := valor.nunidad;

         --SI UNIDADES = 0" (compras --> compras € --> importes)
         IF unidades = 0
            OR unidades IS NULL THEN
            importes := importes + valor.imovimi;
         END IF;

         --SI UNIDADES < 0 E IMPORTE = 0" (vendes unidades --> importes = unidades * precio unidad a la fecha * -1)
         IF unidades < 0
            AND importe = 0 THEN
            BEGIN
               vfdiahabil := f_diahabil(12, TRUNC(valor.fvalmov), NULL);

               SELECT iuniact
                 INTO preciounidad
                 FROM tabvalces
                WHERE ccesta = valor.cesta
                  AND TRUNC(fvalor) = TRUNC(vfdiahabil);

               impmovimi := unidades * preciounidad * -1;
               importes := importes + impmovimi;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
               WHEN OTHERS THEN
                  importes := -1;
            END;
         END IF;
      END LOOP;
   END f_get_importes_asignar;

   PROCEDURE f_get_importes_asignar_shw(seguro IN NUMBER, pfefecto IN DATE, importes OUT NUMBER) IS
      CURSOR cctaseguro_shw IS
         SELECT sseguro, cmovimi, imovimi, nunidad, cesta, fvalmov, cestado, fcontab, nnumlin
           FROM ctaseguro_shadow
          WHERE sseguro = seguro
            AND cestado IN('1', '9')
            AND cmovanu = 0
            AND cesta IS NOT NULL
            AND(nunidad <= 0
                OR nunidad IS NULL
                OR imovimi = 0)
            AND TRUNC(fvalmov) <= TRUNC(pfefecto);

      importe        NUMBER;
      unidades       NUMBER;
      preciounidad   NUMBER;
      impmovimi      NUMBER;
      vfdiahabil     DATE;
   BEGIN
      importes := 0;

      -- es el valor absoluto de importes (ya sean negativos o positivos)
      FOR valor IN cctaseguro_shw LOOP
         /*
           IF valor.cmovimi < 10 THEN
                importe := valor.imovimi * -1;
           ELSE
                importe := valor.imovimi;
           END IF;
         */
         IF valor.cmovimi IN(5, 6, 7, 21, 22, 23, 24, 26, 27, 28, 29, 39, 58, 83, 84, 91, 93,
                             94, 97, 87) THEN
            importe := valor.imovimi * -1;
         END IF;

         unidades := valor.nunidad;

         --SI UNIDADES = 0" (compras --> compras € --> importes)
         IF unidades = 0
            OR unidades IS NULL THEN
            importes := importes + valor.imovimi;
         END IF;

         --SI UNIDADES < 0 E IMPORTE = 0" (vendes unidades --> importes = unidades * precio unidad a la fecha * -1)
         IF unidades < 0
            AND importe = 0 THEN
            BEGIN
               vfdiahabil := f_diahabil(12, TRUNC(valor.fvalmov), NULL);

               SELECT iuniactvtashw
                 INTO preciounidad
                 FROM tabvalces
                WHERE ccesta = valor.cesta
                  AND TRUNC(fvalor) = TRUNC(vfdiahabil);

               impmovimi := unidades * preciounidad * -1;
               importes := importes + impmovimi;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
               WHEN OTHERS THEN
                  importes := -1;
            END;
         END IF;
      END LOOP;
   END f_get_importes_asignar_shw;

   FUNCTION f_redist_asign_unidades(
      pfvalmov IN DATE,
      psproces IN OUT NUMBER,
      nerrores IN OUT NUMBER,
      pcidioma_user IN NUMBER,
      pcempres IN NUMBER,
      psseguro IN NUMBER DEFAULT NULL,
-- Bug 10828 - RSC - 15/09/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      pfunds IN t_iax_produlkmodinvfondo DEFAULT NULL)   -- Bug 36746/0211309 - APD - 17/09/2015
      RETURN NUMBER IS
      CURSOR cctaseguro IS
         SELECT   --+ USE_NL(s c) INDEX(s SEGUROS_CAGRPRO_NUK) INDEX(c CTASEG_FVMOV)
                  c.sseguro, c.cmovimi, c.imovimi, c.nunidad, c.cesta, c.fvalmov, c.cestado,
                  c.fcontab, c.nnumlin, s.cempres
             FROM ctaseguro c, seguros s
            WHERE c.sseguro = s.sseguro
              AND s.cagrpro IN(11, 21)   -- Bug - 13/05/2010 - RSC
              AND s.sseguro = NVL(psseguro, s.sseguro)
              AND c.fvalmov >= TRUNC(pfvalmov)
              AND c.fvalmov < TRUNC(pfvalmov) + 1
              AND c.cmovimi IN(60, 70, 80)
              AND s.cempres = NVL(pcempres, s.cempres)
         ORDER BY c.sseguro;

      CURSOR cctaseguro_venta(psseguro IN NUMBER, pnnumlin IN NUMBER) IS
         SELECT sseguro, cmovimi, cesta
           FROM ctaseguro
          WHERE sseguro = psseguro
            AND nnumlin > pnnumlin;

      CURSOR cur_estsegdisin2(psseguro IN NUMBER) IS
         SELECT ccesta, pdistrec
           FROM segdisin2
          WHERE sseguro = psseguro
            AND ffin IS NULL
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM segdisin2
                            WHERE sseguro = psseguro
                              AND ffin IS NULL);

      num_err        NUMBER;
      v_provision    NUMBER;
      gredanual      NUMBER;
      preciounidad   NUMBER;
      totalsaldo     NUMBER := 0;
      totalsaldou    NUMBER := 0;
      numlinaux      NUMBER;
      xsseguro       NUMBER;
      -- Estructura para almacenar pares (cesta - unidades cesta)
      v_det_modinv   pac_operativa_finv.tt_det_modinv;
      ntraza         NUMBER;
      vsseguro_a     NUMBER := -1;
      vsseguro_b     NUMBER := -1;
      vtexto         VARCHAR2(200);
      vnprolin       NUMBER;
      algun_error    NUMBER := 0;
      vacumpercent   NUMBER := 0;
      vimovimo       NUMBER := 0;
      vacumrounded   NUMBER := 0;
      vfdiahabil     DATE;
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      error_bucle    BOOLEAN;
   BEGIN
      -- Actualizamos el importe de los gastos por redistribución (hasta el momento de asignar no sabiamos
      -- el valor consolidado (el valor de provisión actualizado)
      FOR valor IN cctaseguro LOOP
         -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
         IF v_cempres IS NULL
            OR valor.cempres <> v_cempres THEN
            v_cempres := valor.cempres;
            v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);
         END IF;

         -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
         vsseguro_b := valor.sseguro;

         IF vsseguro_b <> vsseguro_a THEN   -- Al cambiar de seguro hacemos COMMIT del anterior seguro
            vsseguro_a := vsseguro_b;

            IF algun_error = 0 THEN
               COMMIT;
            ELSE
               ROLLBACK;
            END IF;

            algun_error := 0;
         END IF;

         BEGIN
            IF xsseguro IS NULL
               OR xsseguro <> valor.sseguro THEN
               xsseguro := valor.sseguro;
               -- Inicializamos las variables de salida antes de llamar a 'PAC_OPERATIVA_FINV.f_cta_saldo_fondos'
               totalsaldo := 0;
               totalsaldou := 0;
               v_det_modinv.DELETE;
               num_err := pac_operativa_finv.f_cta_saldo_fondos(valor.sseguro, NULL,
                                                                totalsaldo, totalsaldou,
                                                                v_det_modinv, pfunds);

               IF num_err <> 0 THEN
                  vtexto := f_axis_literales(num_err, pcidioma_user);
                  num_err := f_proceslin(psproces,
                                         f_axis_literales(180713, pcidioma_user) || ' '
                                         || f_axis_literales(104482, pcidioma_user)
                                         || valor.sseguro || ','
                                         || f_axis_literales(103242, pcidioma_user) || vtexto,
                                         num_err, vnprolin, 1);
                  algun_error := 1;
                  nerrores := nerrores + 1;
               END IF;
            END IF;

            -- Gastos por Redistribución
            IF valor.cmovimi = 80 THEN
               v_provision := pac_operativa_finv.ff_provmat(NULL, valor.sseguro,
                                                            TO_NUMBER(TO_CHAR(pfvalmov,
                                                                              'yyyymmdd')));
/*
               num_err := pac_operativa_finv.f_gastos_redistribucion_anual(valor.sseguro,
                                                                     v_provision, gredanual);
*/
               num_err := pac_operativa_finv.f_gastos_redistribucion(valor.sseguro, pfvalmov,
                                                                     gredanual);

               IF num_err <> 0 THEN
                  vtexto := f_axis_literales(num_err, pcidioma_user);
                  num_err := f_proceslin(psproces,
                                         f_axis_literales(180713, pcidioma_user) || ' '
                                         || f_axis_literales(104482, pcidioma_user)
                                         || valor.sseguro || ','
                                         || f_axis_literales(103242, pcidioma_user) || vtexto,
                                         num_err, vnprolin, 1);
                  algun_error := 1;
                  nerrores := nerrores + 1;
               END IF;

               ntraza := 1;
               -- Recorrido de la distribución de la póliza para generar los detalles de gastos por redistribución (CONSOLIDADO)
               vacumpercent := 0;
               vimovimo := 0;
               vacumrounded := 0;

               FOR regs IN cur_estsegdisin2(valor.sseguro) LOOP
                  -- Bug 36746/0211309 - APD - 17/09/2015 -- se añade IF pac_operativa_finv.f_valida_cesta_switch
                  IF ((pfunds IS NULL)
                      OR(pfunds IS NOT NULL
                         AND pac_operativa_finv.f_valida_cesta_switch(regs.ccesta, pfunds) = 1)) THEN
                     -- fin Bug 36746/0211309 - APD - 17/09/2015
                        -- Precio unidad de la asignación actual para la cesta
                     vfdiahabil := f_diahabil(12, TRUNC(valor.fvalmov), NULL);

                     BEGIN
                        SELECT NVL(iuniactcmp, iuniact)
                          INTO preciounidad
                          FROM tabvalces
                         WHERE ccesta = regs.ccesta
                           AND TRUNC(fvalor) = TRUNC(vfdiahabil);
                     -- Bug 10828 - RSC - 14/10/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error
                                   (f_sysdate, f_user,
                                    ' 2. PAC_MANTENIMIENTO_FONDOS_FINV.F_POST_ASIGN_UNIDADES',
                                    ntraza, 'parametros: pfvalmov = ' || pfvalmov, SQLERRM);
                           vtexto := f_axis_literales(107223, pcidioma_user);
                           num_err := f_proceslin(psproces,
                                                  f_axis_literales(180713, pcidioma_user)
                                                  || ' '
                                                  || f_axis_literales(104482, pcidioma_user)
                                                  || valor.sseguro || ','
                                                  || f_axis_literales(103242, pcidioma_user)
                                                  || vtexto,
                                                  num_err, vnprolin, 1);
                           algun_error := 1;
                           nerrores := nerrores + 1;
                     END;

                     -- Fin Bug 10828

                     --Calcula les distribucions
                     ntraza := 2;
                     vacumpercent := vacumpercent + NVL(gredanual *(regs.pdistrec / 100), 0);
                     vimovimo := ROUND(vacumpercent - vacumrounded, 2);
                     vacumrounded := vacumrounded + ROUND(vacumpercent - vacumrounded, 2);

                     IF algun_error = 0
                        OR psseguro IS NULL THEN
                        BEGIN
                           -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                           error_bucle := FALSE;

                           FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                                         FROM ctaseguro
                                        WHERE sseguro = valor.sseguro
                                          AND cmovimi = 81
                                          AND cesta = regs.ccesta
                                          AND TRUNC(fvalmov) = TRUNC(pfvalmov)
                                          AND imovimi = 0
                                          AND(nunidad = 0
                                              OR nunidad IS NULL)) LOOP
                              -- Actualizamos los movimientos de detalle (asignamos las unidades que le tocan según el valor
                              -- de provisión a fecha de la asignación
                              UPDATE ctaseguro
                                 SET imovimi = vimovimo,
                                     nunidad = (vimovimo / preciounidad) * -1,
                                     cestado = '2',
                                     fasign = valor.fvalmov
                               WHERE sseguro = reg.sseguro
                                 AND fcontab = reg.fcontab
                                 AND nnumlin = reg.nnumlin;

                              IF v_cmultimon = 1 THEN
                                 num_err :=
                                    pac_oper_monedas.f_update_ctaseguro_monpol(reg.sseguro,
                                                                               reg.fcontab,
                                                                               reg.nnumlin,
                                                                               reg.fvalmov);

                                 IF num_err <> 0 THEN
                                    p_tab_error
                                       (f_sysdate, f_user,
                                        ' 2. PAC_MANTENIMIENTO_FONDOS_FINV.F_REDIST_ASIGN_UNIDADES',
                                        ntraza, 'parametros: pfvalmov = ' || pfvalmov,
                                        f_axis_literales(num_err, pcidioma_user));
                                    num_err := f_proceslin(psproces,
                                                           f_axis_literales(180713,
                                                                            pcidioma_user)
                                                           || ' '
                                                           || f_axis_literales(104482,
                                                                               pcidioma_user)
                                                           || valor.sseguro,
                                                           num_err, vnprolin, 1);
                                    error_bucle := TRUE;
                                 END IF;
                              END IF;
                           END LOOP;

                           IF error_bucle THEN
                              algun_error := 1;
                              nerrores := nerrores + 1;
                           END IF;
                        -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                        EXCEPTION
                           WHEN OTHERS THEN
                              p_tab_error
                                   (f_sysdate, f_user,
                                    ' 2. PAC_MANTENIMIENTO_FONDOS_FINV.F_POST_ASIGN_UNIDADES',
                                    ntraza, 'parametros: pfvalmov = ' || pfvalmov, SQLERRM);
                              vtexto := f_axis_literales(107223, pcidioma_user);
                              num_err := f_proceslin(psproces,
                                                     f_axis_literales(180713, pcidioma_user)
                                                     || ' '
                                                     || f_axis_literales(104482,
                                                                         pcidioma_user)
                                                     || valor.sseguro || ','
                                                     || f_axis_literales(103242,
                                                                         pcidioma_user)
                                                     || vtexto,
                                                     num_err, vnprolin, 1);
                              algun_error := 1;
                              nerrores := nerrores + 1;
                        --RETURN 107223;
                        END;

                        -- Actualizamos las participaciones asignadas a la cesta
                        ntraza := 3;

                        BEGIN
                           --ACTUALIZAR CESTA"
                           UPDATE fondos
                              SET fondos.nparasi =
                                          NVL(fondos.nparasi, 0)
                                          +((vimovimo / preciounidad) * -1)
                            WHERE fondos.ccodfon = regs.ccesta;
                        EXCEPTION
                           WHEN OTHERS THEN
                              p_tab_error
                                  (f_sysdate, f_user,
                                   ' 22. PAC_MANTENIMIENTO_FONDOS_FINV.F_POST_ASIGN_UNIDADES',
                                   ntraza, 'parametros: pfvalmov = ' || pfvalmov, SQLERRM);
                              vtexto := f_axis_literales(107223, pcidioma_user);
                              num_err := f_proceslin(psproces,
                                                     f_axis_literales(180713, pcidioma_user)
                                                     || ' '
                                                     || f_axis_literales(104482,
                                                                         pcidioma_user)
                                                     || valor.sseguro || ','
                                                     || f_axis_literales(103242,
                                                                         pcidioma_user)
                                                     || vtexto,
                                                     num_err, vnprolin, 1);
                              algun_error := 1;
                              nerrores := nerrores + 1;
                        --RETURN 107223;
                        END;
                     END IF;
                  END IF;
               END LOOP;

               IF algun_error = 0
                  OR psseguro IS NULL THEN
                  BEGIN
                     -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     error_bucle := FALSE;

                     FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                                   FROM ctaseguro
                                  WHERE sseguro = valor.sseguro
                                    AND cmovimi = valor.cmovimi
                                    AND TRUNC(fvalmov) = TRUNC(pfvalmov)
                                    AND imovimi = 0
                                    AND(nunidad = 0
                                        OR nunidad IS NULL)) LOOP
                        UPDATE ctaseguro
                           SET imovimi = NVL(gredanual, 0),
                               cestado = '2',
                               fasign = pfvalmov
                         WHERE sseguro = reg.sseguro
                           AND fcontab = reg.fcontab
                           AND nnumlin = reg.nnumlin;

                        IF v_cmultimon = 1 THEN
                           num_err := pac_oper_monedas.f_update_ctaseguro_monpol(reg.sseguro,
                                                                                 reg.fcontab,
                                                                                 reg.nnumlin,
                                                                                 reg.fvalmov);

                           IF num_err <> 0 THEN
                              p_tab_error
                                 (f_sysdate, f_user,
                                  ' 1. PAC_MANTENIMIENTO_FONDOS_FINV.F_REDIST_ASIGN_UNIDADES',
                                  ntraza, 'parametros: pfvalmov = ' || pfvalmov,
                                  f_axis_literales(num_err, pcidioma_user));
                              num_err := f_proceslin(psproces,
                                                     f_axis_literales(180713, pcidioma_user)
                                                     || ' '
                                                     || f_axis_literales(104482,
                                                                         pcidioma_user)
                                                     || valor.sseguro,
                                                     num_err, vnprolin, 1);
                              error_bucle := TRUE;
                           END IF;
                        END IF;
                     END LOOP;

                     IF error_bucle THEN
                        algun_error := 1;
                        nerrores := nerrores + 1;
                     END IF;
                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                                   (f_sysdate, f_user,
                                    ' 1. PAC_MANTENIMIENTO_FONDOS_FINV.F_POST_ASIGN_UNIDADES',
                                    ntraza, 'parametros: pfvalmov = ' || pfvalmov, SQLERRM);
                        vtexto := f_axis_literales(107223, pcidioma_user);
                        num_err := f_proceslin(psproces,
                                               f_axis_literales(180713, pcidioma_user) || ' '
                                               || f_axis_literales(104482, pcidioma_user)
                                               || valor.sseguro || ','
                                               || f_axis_literales(103242, pcidioma_user)
                                               || vtexto,
                                               num_err, vnprolin, 1);
                        algun_error := 1;
                        nerrores := nerrores + 1;
                  --RETURN 107223;
                  END;
               END IF;
            END IF;

            -- Consolidación de las ventas
            IF valor.cmovimi = 60 THEN
               ntraza := 4;

               -- Recorrido de la antigua distribución de la póliza para generar los detalles de gastos por redistribución (CONSOLIDADO)
               FOR regs IN cctaseguro_venta(valor.sseguro, valor.nnumlin) LOOP
                  -- Bug 36746/0211309 - APD - 17/09/2015 -- se añade IF pac_operativa_finv.f_valida_cesta_switch
                  IF ((pfunds IS NULL)
                      OR(pfunds IS NOT NULL
                         AND pac_operativa_finv.f_valida_cesta_switch(regs.cesta, pfunds) = 1)) THEN
                     -- fin Bug 36746/0211309 - APD - 17/09/2015
                     IF regs.cmovimi <> 61 THEN
                        EXIT;
                     ELSE
                        -- Precio unidad de la asignación actual para la cesta
                        vfdiahabil := f_diahabil(12, TRUNC(valor.fvalmov), NULL);

                        BEGIN
                           SELECT iuniact
                             INTO preciounidad
                             FROM tabvalces
                            WHERE ccesta = regs.cesta
                              AND TRUNC(fvalor) = TRUNC(vfdiahabil);
                        -- Bug 10828 - RSC - 14/10/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
                        EXCEPTION
                           WHEN OTHERS THEN
                              p_tab_error(f_sysdate, f_user,
                                          ' 2. PAC_MANTENIMIENTO_FONDOS_FINV.preciounidad',
                                          ntraza, 'parametros: pfvalmov = ' || pfvalmov,
                                          SQLERRM);
                              vtexto := f_axis_literales(107223, pcidioma_user);
                              num_err := f_proceslin(psproces,
                                                     f_axis_literales(180713, pcidioma_user)
                                                     || ' '
                                                     || f_axis_literales(104482,
                                                                         pcidioma_user)
                                                     || valor.sseguro || ','
                                                     || f_axis_literales(103242,
                                                                         pcidioma_user)
                                                     || vtexto,
                                                     num_err, vnprolin, 1);
                              algun_error := 1;
                              nerrores := nerrores + 1;
                        END;

                        -- Fin Bug 10828
                        IF algun_error = 0
                           OR psseguro IS NULL THEN
                           -- Recorrido de las cestas del modelo de inversión
                           FOR i IN 1 .. v_det_modinv.LAST LOOP
                              -- para la cesta que tratamos ahora, obtenemos las participaciones acumuladas ahora (saldo de la cesta)
                              IF v_det_modinv(i).vccesta = regs.cesta THEN
                                 ntraza := 5;

                                 BEGIN
                                    -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                                    error_bucle := FALSE;

                                    FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                                                  FROM ctaseguro
                                                 WHERE sseguro = valor.sseguro
                                                   AND cmovimi = 61
                                                   AND cesta = regs.cesta
                                                   AND TRUNC(fvalmov) = TRUNC(pfvalmov)
                                                   AND imovimi = 0
                                                   AND(nunidad = 0
                                                       OR nunidad IS NULL)) LOOP
                                       -- Actualizamos los movimientos de detalle
                                       -- (asignamos las unidades que le tocan según el valor de provisión a fecha de la asignación)
                                       UPDATE ctaseguro
                                          SET imovimi =
                                                 NVL(v_det_modinv(i).vucesta * preciounidad, 0),
                                              nunidad = v_det_modinv(i).vucesta * -1,
                                              cestado = '2',
                                              fasign = valor.fvalmov
                                        WHERE sseguro = reg.sseguro
                                          AND fcontab = reg.fcontab
                                          AND nnumlin = reg.nnumlin;

                                       IF v_cmultimon = 1 THEN
                                          num_err :=
                                             pac_oper_monedas.f_update_ctaseguro_monpol
                                                                                 (reg.sseguro,
                                                                                  reg.fcontab,
                                                                                  reg.nnumlin,
                                                                                  reg.fvalmov);

                                          IF num_err <> 0 THEN
                                             p_tab_error
                                                (f_sysdate, f_user,
                                                 ' 4. PAC_MANTENIMIENTO_FONDOS_FINV.F_REDIST_ASIGN_UNIDADES',
                                                 ntraza,
                                                 'parametros: pfvalmov = ' || pfvalmov,
                                                 f_axis_literales(num_err, pcidioma_user));
                                             num_err :=
                                                f_proceslin
                                                           (psproces,
                                                            f_axis_literales(180713,
                                                                             pcidioma_user)
                                                            || ' '
                                                            || f_axis_literales(104482,
                                                                                pcidioma_user)
                                                            || valor.sseguro,
                                                            num_err, vnprolin, 1);
                                             error_bucle := TRUE;
                                          END IF;
                                       END IF;
                                    END LOOP;

                                    IF error_bucle THEN
                                       algun_error := 1;
                                       nerrores := nerrores + 1;
                                    END IF;
                                 -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                                 EXCEPTION
                                    WHEN OTHERS THEN
                                       p_tab_error
                                          (f_sysdate, f_user,
                                           ' 4. PAC_MANTENIMIENTO_FONDOS_FINV.F_POST_ASIGN_UNIDADES',
                                           ntraza, 'parametros: pfvalmov = ' || pfvalmov,
                                           SQLERRM);
                                       vtexto := f_axis_literales(107223, pcidioma_user);
                                       num_err :=
                                          f_proceslin(psproces,
                                                      f_axis_literales(180713, pcidioma_user)
                                                      || ' '
                                                      || f_axis_literales(104482,
                                                                          pcidioma_user)
                                                      || valor.sseguro || ','
                                                      || f_axis_literales(103242,
                                                                          pcidioma_user)
                                                      || vtexto,
                                                      num_err, vnprolin, 1);
                                       algun_error := 1;
                                       nerrores := nerrores + 1;
                                 --RETURN 107223;
                                 END;

                                 -- Actualizamos las participaciones asignadas a la cesta
                                 ntraza := 6;

                                 BEGIN
                                    --ACTUALIZAR CESTA"
                                    UPDATE fondos
                                       SET fondos.nparasi =
                                              NVL(fondos.nparasi, 0)
                                              +(v_det_modinv(i).vucesta * -1)
                                     WHERE fondos.ccodfon = regs.cesta;
                                 EXCEPTION
                                    WHEN OTHERS THEN
                                       p_tab_error
                                          (f_sysdate, f_user,
                                           ' 44. PAC_MANTENIMIENTO_FONDOS_FINV.F_POST_ASIGN_UNIDADES',
                                           ntraza, 'parametros: pfvalmov = ' || pfvalmov,
                                           SQLERRM);
                                       vtexto := f_axis_literales(107223, pcidioma_user);
                                       num_err :=
                                          f_proceslin(psproces,
                                                      f_axis_literales(180713, pcidioma_user)
                                                      || ' '
                                                      || f_axis_literales(104482,
                                                                          pcidioma_user)
                                                      || valor.sseguro || ','
                                                      || f_axis_literales(103242,
                                                                          pcidioma_user)
                                                      || vtexto,
                                                      num_err, vnprolin, 1);
                                       algun_error := 1;
                                       nerrores := nerrores + 1;
                                 --RETURN 107223;
                                 END;
                              END IF;
                           END LOOP;
                        END IF;
                     END IF;
                  END IF;
               END LOOP;

               IF algun_error = 0
                  OR psseguro IS NULL THEN
                  BEGIN
                     -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     error_bucle := FALSE;

                     FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                                   FROM ctaseguro
                                  WHERE sseguro = valor.sseguro
                                    AND cmovimi = valor.cmovimi
                                    AND TRUNC(fvalmov) = TRUNC(pfvalmov)
                                    AND imovimi = 0
                                    AND(nunidad = 0
                                        OR nunidad IS NULL)) LOOP
                        -- Actualizamos las unidades de venta y el importe que representa
                        UPDATE ctaseguro
                           SET imovimi = NVL(totalsaldo, 0),
                               --, nunidad = totalsaldou
                               cestado = '2',
                               fasign = pfvalmov
                         WHERE sseguro = reg.sseguro
                           AND fcontab = reg.fcontab
                           AND nnumlin = reg.nnumlin;

                        IF v_cmultimon = 1 THEN
                           num_err := pac_oper_monedas.f_update_ctaseguro_monpol(reg.sseguro,
                                                                                 reg.fcontab,
                                                                                 reg.nnumlin,
                                                                                 reg.fvalmov);

                           IF num_err <> 0 THEN
                              p_tab_error
                                 (f_sysdate, f_user,
                                  ' 3. PAC_MANTENIMIENTO_FONDOS_FINV.F_REDIST_ASIGN_UNIDADES',
                                  ntraza, 'parametros: pfvalmov = ' || pfvalmov,
                                  f_axis_literales(num_err, pcidioma_user));
                              num_err := f_proceslin(psproces,
                                                     f_axis_literales(180713, pcidioma_user)
                                                     || ' '
                                                     || f_axis_literales(104482,
                                                                         pcidioma_user)
                                                     || valor.sseguro,
                                                     num_err, vnprolin, 1);
                              error_bucle := TRUE;
                           END IF;
                        END IF;
                     END LOOP;

                     IF error_bucle THEN
                        algun_error := 1;
                        nerrores := nerrores + 1;
                     END IF;
                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                                   (f_sysdate, f_user,
                                    ' 3. PAC_MANTENIMIENTO_FONDOS_FINV.F_POST_ASIGN_UNIDADES',
                                    ntraza, 'parametros: pfvalmov = ' || pfvalmov, SQLERRM);
                        vtexto := f_axis_literales(107223, pcidioma_user);
                        num_err := f_proceslin(psproces,
                                               f_axis_literales(180713, pcidioma_user) || ' '
                                               || f_axis_literales(104482, pcidioma_user)
                                               || valor.sseguro || ','
                                               || f_axis_literales(103242, pcidioma_user)
                                               || vtexto,
                                               num_err, vnprolin, 1);
                        algun_error := 1;
                        nerrores := nerrores + 1;
                  --RETURN 107223;
                  END;
               END IF;
            END IF;

            -- Consolidación de las compras
            IF valor.cmovimi = 70 THEN
               ntraza := 7;
               -- Recorrido de la distribución de la póliza para generar los detalles de gastos por redistribución (CONSOLIDADO)
               vacumpercent := 0;
               vimovimo := 0;
               vacumrounded := 0;

               FOR regs IN cur_estsegdisin2(valor.sseguro) LOOP
                  -- Bug 36746/0211309 - APD - 17/09/2015 -- se añade IF pac_operativa_finv.f_valida_cesta_switch
                  IF ((pfunds IS NULL)
                      OR(pfunds IS NOT NULL
                         AND pac_operativa_finv.f_valida_cesta_switch(regs.ccesta, pfunds) = 1)) THEN
                     -- fin Bug 36746/0211309 - APD - 17/09/2015
                        -- Precio unidad de la asignación actual para la cesta
                     vfdiahabil := f_diahabil(12, TRUNC(valor.fvalmov), NULL);

                     -- Bug 10828 - RSC - 14/10/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
                     -- Añadimos tratamiento de excepcción
                     BEGIN
                        SELECT NVL(iuniactcmp, iuniact)
                          INTO preciounidad
                          FROM tabvalces
                         WHERE ccesta = regs.ccesta
                           AND TRUNC(fvalor) = TRUNC(vfdiahabil);
                     -- Bug 10828 - RSC - 14/10/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user,
                                       ' 2. PAC_MANTENIMIENTO_FONDOS_FINV.preciounidad',
                                       ntraza, 'parametros: pfvalmov = ' || pfvalmov, SQLERRM);
                           vtexto := f_axis_literales(107223, pcidioma_user);
                           num_err := f_proceslin(psproces,
                                                  f_axis_literales(180713, pcidioma_user)
                                                  || ' '
                                                  || f_axis_literales(104482, pcidioma_user)
                                                  || valor.sseguro || ','
                                                  || f_axis_literales(103242, pcidioma_user)
                                                  || vtexto,
                                                  num_err, vnprolin, 1);
                           algun_error := 1;
                           nerrores := nerrores + 1;
                     END;

                     -- Fin Bug 10828

                     -- Calculamos la distribución
                     ntraza := 8;
                     vacumpercent := vacumpercent + NVL(totalsaldo *(regs.pdistrec / 100), 0);
                     vimovimo := ROUND(vacumpercent - vacumrounded, 2);
                     vacumrounded := vacumrounded + ROUND(vacumpercent - vacumrounded, 2);

                     IF algun_error = 0
                        OR psseguro IS NULL THEN
                        BEGIN
                           -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                           error_bucle := FALSE;

                           FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                                         FROM ctaseguro
                                        WHERE sseguro = valor.sseguro
                                          AND cmovimi = 71
                                          AND cesta = regs.ccesta
                                          AND TRUNC(fvalmov) = TRUNC(pfvalmov)
                                          AND imovimi = 0
                                          AND(nunidad = 0
                                              OR nunidad IS NULL)) LOOP
                              -- Actualizamos los movimientos de detalle (asignamos las unidades que le tocan según el valor
                              -- de provisión a fecha de la asignación
                              UPDATE ctaseguro
                                 SET imovimi = vimovimo,
                                     nunidad = vimovimo / preciounidad,
                                     cestado = '2',
                                     fasign = valor.fvalmov
                               WHERE sseguro = reg.sseguro
                                 AND fcontab = reg.fcontab
                                 AND nnumlin = reg.nnumlin;

                              IF v_cmultimon = 1 THEN
                                 num_err :=
                                    pac_oper_monedas.f_update_ctaseguro_monpol(reg.sseguro,
                                                                               reg.fcontab,
                                                                               reg.nnumlin,
                                                                               reg.fvalmov);

                                 IF num_err <> 0 THEN
                                    p_tab_error
                                       (f_sysdate, f_user,
                                        ' 5. PAC_MANTENIMIENTO_FONDOS_FINV.F_REDIST_ASIGN_UNIDADES',
                                        ntraza, 'parametros: pfvalmov = ' || pfvalmov,
                                        f_axis_literales(num_err, pcidioma_user));
                                    num_err := f_proceslin(psproces,
                                                           f_axis_literales(180713,
                                                                            pcidioma_user)
                                                           || ' '
                                                           || f_axis_literales(104482,
                                                                               pcidioma_user)
                                                           || valor.sseguro,
                                                           num_err, vnprolin, 1);
                                    error_bucle := TRUE;
                                 END IF;
                              END IF;
                           END LOOP;

                           IF error_bucle THEN
                              algun_error := 1;
                              nerrores := nerrores + 1;
                           END IF;
                        -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                        EXCEPTION
                           WHEN OTHERS THEN
                              p_tab_error
                                   (f_sysdate, f_user,
                                    ' 5. PAC_MANTENIMIENTO_FONDOS_FINV.F_POST_ASIGN_UNIDADES',
                                    ntraza, 'parametros: pfvalmov = ' || pfvalmov, SQLERRM);
                              vtexto := f_axis_literales(107223, pcidioma_user);
                              num_err := f_proceslin(psproces,
                                                     f_axis_literales(180713, pcidioma_user)
                                                     || ' '
                                                     || f_axis_literales(104482,
                                                                         pcidioma_user)
                                                     || valor.sseguro || ','
                                                     || f_axis_literales(103242,
                                                                         pcidioma_user)
                                                     || vtexto,
                                                     num_err, vnprolin, 1);
                              algun_error := 1;
                              nerrores := nerrores + 1;
                        --RETURN 107223;
                        END;

                        -- Actualizamos las participaciones asignadas a la cesta
                        ntraza := 9;

                        BEGIN
                           --ACTUALIZAR CESTA"
                           UPDATE fondos
                              SET fondos.nparasi =
                                               NVL(fondos.nparasi, 0)
                                               +(vimovimo / preciounidad)
                            WHERE fondos.ccodfon = regs.ccesta;
                        EXCEPTION
                           WHEN OTHERS THEN
                              p_tab_error
                                  (f_sysdate, f_user,
                                   ' 55. PAC_MANTENIMIENTO_FONDOS_FINV.F_POST_ASIGN_UNIDADES',
                                   ntraza, 'parametros: pfvalmov = ' || pfvalmov, SQLERRM);
                              vtexto := f_axis_literales(107223, pcidioma_user);
                              num_err := f_proceslin(psproces,
                                                     f_axis_literales(180713, pcidioma_user)
                                                     || ' '
                                                     || f_axis_literales(104482,
                                                                         pcidioma_user)
                                                     || valor.sseguro || ','
                                                     || f_axis_literales(103242,
                                                                         pcidioma_user)
                                                     || vtexto,
                                                     num_err, vnprolin, 1);
                              algun_error := 1;
                              nerrores := nerrores + 1;
                        --RETURN 107223;
                        END;
                     END IF;
                  END IF;
               END LOOP;

               IF algun_error = 0
                  OR psseguro IS NULL THEN
                  BEGIN
                     -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     error_bucle := FALSE;

                     FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                                   FROM ctaseguro
                                  WHERE sseguro = valor.sseguro
                                    AND cmovimi = valor.cmovimi
                                    AND TRUNC(fvalmov) = TRUNC(pfvalmov)
                                    AND imovimi = 0
                                    AND(nunidad = 0
                                        OR nunidad IS NULL)) LOOP
                        UPDATE ctaseguro
                           SET imovimi = NVL(totalsaldo, 0),
                               cestado = '2',
                               fasign = pfvalmov
                         WHERE sseguro = reg.sseguro
                           AND fcontab = reg.fcontab
                           AND nnumlin = reg.nnumlin;

                        IF v_cmultimon = 1 THEN
                           num_err := pac_oper_monedas.f_update_ctaseguro_monpol(reg.sseguro,
                                                                                 reg.fcontab,
                                                                                 reg.nnumlin,
                                                                                 reg.fvalmov);

                           IF num_err <> 0 THEN
                              p_tab_error
                                 (f_sysdate, f_user,
                                  ' 5. PAC_MANTENIMIENTO_FONDOS_FINV.F_REDIST_ASIGN_UNIDADES',
                                  ntraza, 'parametros: pfvalmov = ' || pfvalmov,
                                  f_axis_literales(num_err, pcidioma_user));
                              num_err := f_proceslin(psproces,
                                                     f_axis_literales(180713, pcidioma_user)
                                                     || ' '
                                                     || f_axis_literales(104482,
                                                                         pcidioma_user)
                                                     || valor.sseguro,
                                                     num_err, vnprolin, 1);
                              error_bucle := TRUE;
                           END IF;
                        END IF;
                     END LOOP;

                     IF error_bucle THEN
                        algun_error := 1;
                        nerrores := nerrores + 1;
                     END IF;
                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                                   (f_sysdate, f_user,
                                    ' 5. PAC_MANTENIMIENTO_FONDOS_FINV.F_POST_ASIGN_UNIDADES',
                                    ntraza, 'parametros: pfvalmov = ' || pfvalmov, SQLERRM);
                        vtexto := f_axis_literales(107223, pcidioma_user);
                        num_err := f_proceslin(psproces,
                                               f_axis_literales(180713, pcidioma_user) || ' '
                                               || f_axis_literales(104482, pcidioma_user)
                                               || valor.sseguro || ','
                                               || f_axis_literales(103242, pcidioma_user)
                                               || vtexto,
                                               num_err, vnprolin, 1);
                        algun_error := 1;
                        nerrores := nerrores + 1;
                  --RETURN 107223;
                  END;
               END IF;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user,
                           ' 6. PAC_MANTENIMIENTO_FONDOS_FINV.F_POST_ASIGN_UNIDADES', ntraza,
                           'parametros: pfvalmov = ' || pfvalmov, SQLERRM);
               vtexto := f_axis_literales(107223, pcidioma_user);
               num_err := f_proceslin(psproces,
                                      f_axis_literales(180713, pcidioma_user) || ' '
                                      || f_axis_literales(104482, pcidioma_user)
                                      || valor.sseguro || ','
                                      || f_axis_literales(103242, pcidioma_user) || vtexto,
                                      num_err, vnprolin, 1);
               algun_error := 1;
               nerrores := nerrores + 1;
         --RETURN 107223;
         END;
      END LOOP;

      IF psseguro IS NULL THEN
         IF algun_error = 0 THEN
            COMMIT;
         ELSE
            ROLLBACK;
         END IF;
      END IF;

      RETURN 0;
   END f_redist_asign_unidades;

   FUNCTION f_redist_asign_unidades_shw(
      pfvalmov IN DATE,
      psproces IN OUT NUMBER,
      nerrores IN OUT NUMBER,
      pcidioma_user IN NUMBER,
      pcempres IN NUMBER,
      psseguro IN NUMBER DEFAULT NULL,
-- Bug 10828 - RSC - 15/09/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      pfunds IN t_iax_produlkmodinvfondo DEFAULT NULL)   -- Bug 36746/0211309 - APD - 17/09/2015
      RETURN NUMBER IS
      CURSOR cctaseguro IS
         SELECT   --+ USE_NL(s c) INDEX(s SEGUROS_CAGRPRO_NUK) INDEX(c CTASEG_FVMOV)
                  c.sseguro, c.cmovimi, c.imovimi, c.nunidad, c.cesta, c.fvalmov, c.cestado,
                  c.fcontab, c.nnumlin, s.cempres
             FROM ctaseguro_shadow c, seguros s
            WHERE c.sseguro = s.sseguro
              AND s.cagrpro IN(11, 21)   -- Bug - 13/05/2010 - RSC
              AND s.sseguro = NVL(psseguro, s.sseguro)
              AND c.fvalmov >= TRUNC(pfvalmov)
              AND c.fvalmov < TRUNC(pfvalmov) + 1
              AND c.cmovimi IN(60, 70, 80)
              AND s.cempres = NVL(pcempres, s.cempres)
         ORDER BY c.sseguro;

      CURSOR cctaseguro_venta(psseguro IN NUMBER, pnnumlin IN NUMBER) IS
         SELECT sseguro, cmovimi, cesta
           FROM ctaseguro_shadow
          WHERE sseguro = psseguro
            AND nnumlin > pnnumlin;

      CURSOR cur_estsegdisin2(psseguro IN NUMBER) IS
         SELECT ccesta, pdistrec
           FROM segdisin2
          WHERE sseguro = psseguro
            AND ffin IS NULL
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM segdisin2
                            WHERE sseguro = psseguro
                              AND ffin IS NULL);

      num_err        NUMBER;
      v_provision    NUMBER;
      gredanual      NUMBER;
      preciounidad   NUMBER;
      totalsaldo     NUMBER := 0;
      totalsaldou    NUMBER := 0;
      numlinaux      NUMBER;
      xsseguro       NUMBER;
      -- Estructura para almacenar pares (cesta - unidades cesta)
      v_det_modinv   pac_operativa_finv.tt_det_modinv;
      ntraza         NUMBER;
      vsseguro_a     NUMBER := -1;
      vsseguro_b     NUMBER := -1;
      vtexto         VARCHAR2(200);
      vnprolin       NUMBER;
      algun_error    NUMBER := 0;
      vacumpercent   NUMBER := 0;
      vimovimo       NUMBER := 0;
      vacumrounded   NUMBER := 0;
      vfdiahabil     DATE;
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      error_bucle    BOOLEAN;
   BEGIN
      -- Actualizamos el importe de los gastos por redistribución (hasta el momento de asignar no sabiamos
      -- el valor consolidado (el valor de provisión actualizado)
      FOR valor IN cctaseguro LOOP
         -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
         IF v_cempres IS NULL
            OR valor.cempres <> v_cempres THEN
            v_cempres := valor.cempres;
            v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);
         END IF;

         -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
         vsseguro_b := valor.sseguro;

         IF vsseguro_b <> vsseguro_a THEN   -- Al cambiar de seguro hacemos COMMIT del anterior seguro
            vsseguro_a := vsseguro_b;

            IF algun_error = 0 THEN
               COMMIT;
            ELSE
               ROLLBACK;
            END IF;

            algun_error := 0;
         END IF;

         BEGIN
            IF xsseguro IS NULL
               OR xsseguro <> valor.sseguro THEN
               xsseguro := valor.sseguro;
               -- Inicializamos las variables de salida antes de llamar a 'PAC_OPERATIVA_FINV.f_cta_saldo_fondos'
               totalsaldo := 0;
               totalsaldou := 0;
               v_det_modinv.DELETE;
               num_err := pac_operativa_finv.f_cta_saldo_fondos_shw(valor.sseguro, NULL,
                                                                    totalsaldo, totalsaldou,
                                                                    v_det_modinv, pfunds);

               IF num_err <> 0 THEN
                  vtexto := f_axis_literales(num_err, pcidioma_user);
                  num_err := f_proceslin(psproces,
                                         f_axis_literales(180713, pcidioma_user) || ' '
                                         || f_axis_literales(104482, pcidioma_user)
                                         || valor.sseguro || ','
                                         || f_axis_literales(103242, pcidioma_user) || vtexto,
                                         num_err, vnprolin, 1);
                  algun_error := 1;
                  nerrores := nerrores + 1;
               END IF;
            END IF;

            -- Gastos por Redistribución
            IF valor.cmovimi = 80 THEN
               v_provision := pac_operativa_finv.ff_provshw(NULL, valor.sseguro,
                                                            TO_NUMBER(TO_CHAR(pfvalmov,
                                                                              'yyyymmdd')));
/*
               num_err := pac_operativa_finv.f_gastos_redistribucion_anual(valor.sseguro,
                                                                     v_provision, gredanual);
*/
               num_err := pac_operativa_finv.f_gastos_redistribucion(valor.sseguro, pfvalmov,
                                                                     gredanual);

               IF num_err <> 0 THEN
                  vtexto := f_axis_literales(num_err, pcidioma_user);
                  num_err := f_proceslin(psproces,
                                         f_axis_literales(180713, pcidioma_user) || ' '
                                         || f_axis_literales(104482, pcidioma_user)
                                         || valor.sseguro || ','
                                         || f_axis_literales(103242, pcidioma_user) || vtexto,
                                         num_err, vnprolin, 1);
                  algun_error := 1;
                  nerrores := nerrores + 1;
               END IF;

               ntraza := 1;
               -- Recorrido de la distribución de la póliza para generar los detalles de gastos por redistribución (CONSOLIDADO)
               vacumpercent := 0;
               vimovimo := 0;
               vacumrounded := 0;

               FOR regs IN cur_estsegdisin2(valor.sseguro) LOOP
                  -- Bug 36746/0211309 - APD - 17/09/2015 -- se añade IF pac_operativa_finv.f_valida_cesta_switch
                  IF ((pfunds IS NULL)
                      OR(pfunds IS NOT NULL
                         AND pac_operativa_finv.f_valida_cesta_switch(regs.ccesta, pfunds) = 1)) THEN
                     -- fin Bug 36746/0211309 - APD - 17/09/2015
                        -- Precio unidad de la asignación actual para la cesta
                     vfdiahabil := f_diahabil(12, TRUNC(valor.fvalmov), NULL);

                     BEGIN
                        SELECT iuniactcmpshw
                          INTO preciounidad
                          FROM tabvalces
                         WHERE ccesta = regs.ccesta
                           AND TRUNC(fvalor) = TRUNC(vfdiahabil);
                     -- Bug 10828 - RSC - 14/10/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error
                               (f_sysdate, f_user,
                                ' 2. PAC_MANTENIMIENTO_FONDOS_FINV.F_POST_ASIGN_UNIDADES_SHW',
                                ntraza, 'parametros: pfvalmov = ' || pfvalmov, SQLERRM);
                           vtexto := f_axis_literales(107223, pcidioma_user);
                           num_err := f_proceslin(psproces,
                                                  f_axis_literales(180713, pcidioma_user)
                                                  || ' '
                                                  || f_axis_literales(104482, pcidioma_user)
                                                  || valor.sseguro || ','
                                                  || f_axis_literales(103242, pcidioma_user)
                                                  || vtexto,
                                                  num_err, vnprolin, 1);
                           algun_error := 1;
                           nerrores := nerrores + 1;
                     END;

                     -- Fin Bug 10828

                     --Calcula les distribucions
                     ntraza := 2;
                     vacumpercent := vacumpercent + NVL(gredanual *(regs.pdistrec / 100), 0);
                     vimovimo := ROUND(vacumpercent - vacumrounded, 2);
                     vacumrounded := vacumrounded + ROUND(vacumpercent - vacumrounded, 2);

                     IF algun_error = 0
                        OR psseguro IS NULL THEN
                        BEGIN
                           -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                           error_bucle := FALSE;

                           FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                                         FROM ctaseguro_shadow
                                        WHERE sseguro = valor.sseguro
                                          AND cmovimi = 81
                                          AND cesta = regs.ccesta
                                          AND TRUNC(fvalmov) = TRUNC(pfvalmov)
                                          AND imovimi = 0
                                          AND(nunidad = 0
                                              OR nunidad IS NULL)) LOOP
                              -- Actualizamos los movimientos de detalle (asignamos las unidades que le tocan según el valor
                              -- de provisión a fecha de la asignación
                              UPDATE ctaseguro_shadow
                                 SET imovimi = vimovimo,
                                     nunidad = (vimovimo / preciounidad) * -1,
                                     cestado = '2',
                                     fasign = valor.fvalmov
                               WHERE sseguro = reg.sseguro
                                 AND fcontab = reg.fcontab
                                 AND nnumlin = reg.nnumlin;

                              IF v_cmultimon = 1 THEN
                                 num_err :=
                                    pac_oper_monedas.f_update_ctaseguro_shw_monpol
                                                                                 (reg.sseguro,
                                                                                  reg.fcontab,
                                                                                  reg.nnumlin,
                                                                                  reg.fvalmov);

                                 IF num_err <> 0 THEN
                                    p_tab_error
                                       (f_sysdate, f_user,
                                        ' 2. PAC_MANTENIMIENTO_FONDOS_FINV.F_REDIST_ASIGN_UNIDADES_SHW',
                                        ntraza, 'parametros: pfvalmov = ' || pfvalmov,
                                        f_axis_literales(num_err, pcidioma_user));
                                    num_err := f_proceslin(psproces,
                                                           f_axis_literales(180713,
                                                                            pcidioma_user)
                                                           || ' '
                                                           || f_axis_literales(104482,
                                                                               pcidioma_user)
                                                           || valor.sseguro,
                                                           num_err, vnprolin, 1);
                                    error_bucle := TRUE;
                                 END IF;
                              END IF;
                           END LOOP;

                           IF error_bucle THEN
                              algun_error := 1;
                              nerrores := nerrores + 1;
                           END IF;
                        -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                        EXCEPTION
                           WHEN OTHERS THEN
                              p_tab_error
                                 (f_sysdate, f_user,
                                  ' 2. PAC_MANTENIMIENTO_FONDOS_FINV.F_POST_ASIGN_UNIDADES_SHW',
                                  ntraza, 'parametros: pfvalmov = ' || pfvalmov, SQLERRM);
                              vtexto := f_axis_literales(107223, pcidioma_user);
                              num_err := f_proceslin(psproces,
                                                     f_axis_literales(180713, pcidioma_user)
                                                     || ' '
                                                     || f_axis_literales(104482,
                                                                         pcidioma_user)
                                                     || valor.sseguro || ','
                                                     || f_axis_literales(103242,
                                                                         pcidioma_user)
                                                     || vtexto,
                                                     num_err, vnprolin, 1);
                              algun_error := 1;
                              nerrores := nerrores + 1;
                        --RETURN 107223;
                        END;

                        -- Actualizamos las participaciones asignadas a la cesta
                        ntraza := 3;
                     END IF;
                  END IF;
               END LOOP;

               IF algun_error = 0
                  OR psseguro IS NULL THEN
                  BEGIN
                     -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     error_bucle := FALSE;

                     FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                                   FROM ctaseguro_shadow
                                  WHERE sseguro = valor.sseguro
                                    AND cmovimi = valor.cmovimi
                                    AND TRUNC(fvalmov) = TRUNC(pfvalmov)
                                    AND imovimi = 0
                                    AND(nunidad = 0
                                        OR nunidad IS NULL)) LOOP
                        UPDATE ctaseguro_shadow
                           SET imovimi = NVL(gredanual, 0),
                               cestado = '2',
                               fasign = pfvalmov
                         WHERE sseguro = reg.sseguro
                           AND fcontab = reg.fcontab
                           AND nnumlin = reg.nnumlin;

                        IF v_cmultimon = 1 THEN
                           num_err :=
                              pac_oper_monedas.f_update_ctaseguro_shw_monpol(reg.sseguro,
                                                                             reg.fcontab,
                                                                             reg.nnumlin,
                                                                             reg.fvalmov);

                           IF num_err <> 0 THEN
                              p_tab_error
                                 (f_sysdate, f_user,
                                  ' 1. PAC_MANTENIMIENTO_FONDOS_FINV.F_REDIST_ASIGN_UNIDADES_SHW',
                                  ntraza, 'parametros: pfvalmov = ' || pfvalmov,
                                  f_axis_literales(num_err, pcidioma_user));
                              num_err := f_proceslin(psproces,
                                                     f_axis_literales(180713, pcidioma_user)
                                                     || ' '
                                                     || f_axis_literales(104482,
                                                                         pcidioma_user)
                                                     || valor.sseguro,
                                                     num_err, vnprolin, 1);
                              error_bucle := TRUE;
                           END IF;
                        END IF;
                     END LOOP;

                     IF error_bucle THEN
                        algun_error := 1;
                        nerrores := nerrores + 1;
                     END IF;
                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                               (f_sysdate, f_user,
                                ' 1. PAC_MANTENIMIENTO_FONDOS_FINV.F_POST_ASIGN_UNIDADES_SHW',
                                ntraza, 'parametros: pfvalmov = ' || pfvalmov, SQLERRM);
                        vtexto := f_axis_literales(107223, pcidioma_user);
                        num_err := f_proceslin(psproces,
                                               f_axis_literales(180713, pcidioma_user) || ' '
                                               || f_axis_literales(104482, pcidioma_user)
                                               || valor.sseguro || ','
                                               || f_axis_literales(103242, pcidioma_user)
                                               || vtexto,
                                               num_err, vnprolin, 1);
                        algun_error := 1;
                        nerrores := nerrores + 1;
                  --RETURN 107223;
                  END;
               END IF;
            END IF;

            -- Consolidación de las ventas
            IF valor.cmovimi = 60 THEN
               ntraza := 4;

               -- Recorrido de la antigua distribución de la póliza para generar los detalles de gastos por redistribución (CONSOLIDADO)
               FOR regs IN cctaseguro_venta(valor.sseguro, valor.nnumlin) LOOP
                  -- Bug 36746/0211309 - APD - 17/09/2015 -- se añade IF pac_operativa_finv.f_valida_cesta_switch
                  IF ((pfunds IS NULL)
                      OR(pfunds IS NOT NULL
                         AND pac_operativa_finv.f_valida_cesta_switch(regs.cesta, pfunds) = 1)) THEN
                     -- fin Bug 36746/0211309 - APD - 17/09/2015
                     IF regs.cmovimi <> 61 THEN
                        EXIT;
                     ELSE
                        -- Precio unidad de la asignación actual para la cesta
                        vfdiahabil := f_diahabil(12, TRUNC(valor.fvalmov), NULL);

                        BEGIN
                           SELECT iuniactvtashw
                             INTO preciounidad
                             FROM tabvalces
                            WHERE ccesta = regs.cesta
                              AND TRUNC(fvalor) = TRUNC(vfdiahabil);
                        -- Bug 10828 - RSC - 14/10/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
                        EXCEPTION
                           WHEN OTHERS THEN
                              p_tab_error
                                        (f_sysdate, f_user,
                                         ' 2. PAC_MANTENIMIENTO_FONDOS_FINV.preciounidad_shw',
                                         ntraza, 'parametros: pfvalmov = ' || pfvalmov,
                                         SQLERRM);
                              vtexto := f_axis_literales(107223, pcidioma_user);
                              num_err := f_proceslin(psproces,
                                                     f_axis_literales(180713, pcidioma_user)
                                                     || ' '
                                                     || f_axis_literales(104482,
                                                                         pcidioma_user)
                                                     || valor.sseguro || ','
                                                     || f_axis_literales(103242,
                                                                         pcidioma_user)
                                                     || vtexto,
                                                     num_err, vnprolin, 1);
                              algun_error := 1;
                              nerrores := nerrores + 1;
                        END;

                        -- Fin Bug 10828
                        IF algun_error = 0
                           OR psseguro IS NULL THEN
                           -- Recorrido de las cestas del modelo de inversión
                           FOR i IN 1 .. v_det_modinv.LAST LOOP
                              -- para la cesta que tratamos ahora, obtenemos las participaciones acumuladas ahora (saldo de la cesta)
                              IF v_det_modinv(i).vccesta = regs.cesta THEN
                                 ntraza := 5;

                                 BEGIN
                                    -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                                    error_bucle := FALSE;

                                    FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                                                  FROM ctaseguro_shadow
                                                 WHERE sseguro = valor.sseguro
                                                   AND cmovimi = 61
                                                   AND cesta = regs.cesta
                                                   AND TRUNC(fvalmov) = TRUNC(pfvalmov)
                                                   AND imovimi = 0
                                                   AND(nunidad = 0
                                                       OR nunidad IS NULL)) LOOP
                                       -- Actualizamos los movimientos de detalle
                                       -- (asignamos las unidades que le tocan según el valor de provisión a fecha de la asignación)
                                       UPDATE ctaseguro_shadow
                                          SET imovimi =
                                                 NVL(v_det_modinv(i).vucesta * preciounidad, 0),
                                              nunidad = v_det_modinv(i).vucesta * -1,
                                              cestado = '2',
                                              fasign = valor.fvalmov
                                        WHERE sseguro = reg.sseguro
                                          AND fcontab = reg.fcontab
                                          AND nnumlin = reg.nnumlin;

                                       IF v_cmultimon = 1 THEN
                                          num_err :=
                                             pac_oper_monedas.f_update_ctaseguro_shw_monpol
                                                                                 (reg.sseguro,
                                                                                  reg.fcontab,
                                                                                  reg.nnumlin,
                                                                                  reg.fvalmov);

                                          IF num_err <> 0 THEN
                                             p_tab_error
                                                (f_sysdate, f_user,
                                                 ' 4. PAC_MANTENIMIENTO_FONDOS_FINV.F_REDIST_ASIGN_UNIDADES_SHW',
                                                 ntraza,
                                                 'parametros: pfvalmov = ' || pfvalmov,
                                                 f_axis_literales(num_err, pcidioma_user));
                                             num_err :=
                                                f_proceslin
                                                           (psproces,
                                                            f_axis_literales(180713,
                                                                             pcidioma_user)
                                                            || ' '
                                                            || f_axis_literales(104482,
                                                                                pcidioma_user)
                                                            || valor.sseguro,
                                                            num_err, vnprolin, 1);
                                             error_bucle := TRUE;
                                          END IF;
                                       END IF;
                                    END LOOP;

                                    IF error_bucle THEN
                                       algun_error := 1;
                                       nerrores := nerrores + 1;
                                    END IF;
                                 -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                                 EXCEPTION
                                    WHEN OTHERS THEN
                                       p_tab_error
                                          (f_sysdate, f_user,
                                           ' 4. PAC_MANTENIMIENTO_FONDOS_FINV.F_POST_ASIGN_UNIDADES_SHW',
                                           ntraza, 'parametros: pfvalmov = ' || pfvalmov,
                                           SQLERRM);
                                       vtexto := f_axis_literales(107223, pcidioma_user);
                                       num_err :=
                                          f_proceslin(psproces,
                                                      f_axis_literales(180713, pcidioma_user)
                                                      || ' '
                                                      || f_axis_literales(104482,
                                                                          pcidioma_user)
                                                      || valor.sseguro || ','
                                                      || f_axis_literales(103242,
                                                                          pcidioma_user)
                                                      || vtexto,
                                                      num_err, vnprolin, 1);
                                       algun_error := 1;
                                       nerrores := nerrores + 1;
                                 --RETURN 107223;
                                 END;

                                 -- Actualizamos las participaciones asignadas a la cesta
                                 ntraza := 6;
                              END IF;
                           END LOOP;
                        END IF;
                     END IF;
                  END IF;
               END LOOP;

               IF algun_error = 0
                  OR psseguro IS NULL THEN
                  BEGIN
                     -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     error_bucle := FALSE;

                     FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                                   FROM ctaseguro_shadow
                                  WHERE sseguro = valor.sseguro
                                    AND cmovimi = valor.cmovimi
                                    AND TRUNC(fvalmov) = TRUNC(pfvalmov)
                                    AND imovimi = 0
                                    AND(nunidad = 0
                                        OR nunidad IS NULL)) LOOP
                        -- Actualizamos las unidades de venta y el importe que representa
                        UPDATE ctaseguro_shadow
                           SET imovimi = NVL(totalsaldo, 0),
                               --, nunidad = totalsaldou
                               cestado = '2',
                               fasign = pfvalmov
                         WHERE sseguro = reg.sseguro
                           AND fcontab = reg.fcontab
                           AND nnumlin = reg.nnumlin;

                        IF v_cmultimon = 1 THEN
                           num_err :=
                              pac_oper_monedas.f_update_ctaseguro_shw_monpol(reg.sseguro,
                                                                             reg.fcontab,
                                                                             reg.nnumlin,
                                                                             reg.fvalmov);

                           IF num_err <> 0 THEN
                              p_tab_error
                                 (f_sysdate, f_user,
                                  ' 3. PAC_MANTENIMIENTO_FONDOS_FINV.F_REDIST_ASIGN_UNIDADES_SHW',
                                  ntraza, 'parametros: pfvalmov = ' || pfvalmov,
                                  f_axis_literales(num_err, pcidioma_user));
                              num_err := f_proceslin(psproces,
                                                     f_axis_literales(180713, pcidioma_user)
                                                     || ' '
                                                     || f_axis_literales(104482,
                                                                         pcidioma_user)
                                                     || valor.sseguro,
                                                     num_err, vnprolin, 1);
                              error_bucle := TRUE;
                           END IF;
                        END IF;
                     END LOOP;

                     IF error_bucle THEN
                        algun_error := 1;
                        nerrores := nerrores + 1;
                     END IF;
                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                               (f_sysdate, f_user,
                                ' 3. PAC_MANTENIMIENTO_FONDOS_FINV.F_POST_ASIGN_UNIDADES_SHW',
                                ntraza, 'parametros: pfvalmov = ' || pfvalmov, SQLERRM);
                        vtexto := f_axis_literales(107223, pcidioma_user);
                        num_err := f_proceslin(psproces,
                                               f_axis_literales(180713, pcidioma_user) || ' '
                                               || f_axis_literales(104482, pcidioma_user)
                                               || valor.sseguro || ','
                                               || f_axis_literales(103242, pcidioma_user)
                                               || vtexto,
                                               num_err, vnprolin, 1);
                        algun_error := 1;
                        nerrores := nerrores + 1;
                  --RETURN 107223;
                  END;
               END IF;
            END IF;

            -- Consolidación de las compras
            IF valor.cmovimi = 70 THEN
               ntraza := 7;
               -- Recorrido de la distribución de la póliza para generar los detalles de gastos por redistribución (CONSOLIDADO)
               vacumpercent := 0;
               vimovimo := 0;
               vacumrounded := 0;

               FOR regs IN cur_estsegdisin2(valor.sseguro) LOOP
                  -- Bug 36746/0211309 - APD - 17/09/2015 -- se añade IF pac_operativa_finv.f_valida_cesta_switch
                  IF ((pfunds IS NULL)
                      OR(pfunds IS NOT NULL
                         AND pac_operativa_finv.f_valida_cesta_switch(regs.ccesta, pfunds) = 1)) THEN
                     -- fin Bug 36746/0211309 - APD - 17/09/2015
                        -- Precio unidad de la asignación actual para la cesta
                     vfdiahabil := f_diahabil(12, TRUNC(valor.fvalmov), NULL);

                     -- Bug 10828 - RSC - 14/10/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
                     -- Añadimos tratamiento de excepcción
                     BEGIN
                        SELECT iuniactcmpshw
                          INTO preciounidad
                          FROM tabvalces
                         WHERE ccesta = regs.ccesta
                           AND TRUNC(fvalor) = TRUNC(vfdiahabil);
                     -- Bug 10828 - RSC - 14/10/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user,
                                       ' 2. PAC_MANTENIMIENTO_FONDOS_FINV.preciounidad_shw',
                                       ntraza, 'parametros: pfvalmov = ' || pfvalmov, SQLERRM);
                           vtexto := f_axis_literales(107223, pcidioma_user);
                           num_err := f_proceslin(psproces,
                                                  f_axis_literales(180713, pcidioma_user)
                                                  || ' '
                                                  || f_axis_literales(104482, pcidioma_user)
                                                  || valor.sseguro || ','
                                                  || f_axis_literales(103242, pcidioma_user)
                                                  || vtexto,
                                                  num_err, vnprolin, 1);
                           algun_error := 1;
                           nerrores := nerrores + 1;
                     END;

                     -- Fin Bug 10828

                     -- Calculamos la distribución
                     ntraza := 8;
                     vacumpercent := vacumpercent + NVL(totalsaldo *(regs.pdistrec / 100), 0);
                     vimovimo := ROUND(vacumpercent - vacumrounded, 2);
                     vacumrounded := vacumrounded + ROUND(vacumpercent - vacumrounded, 2);

                     IF algun_error = 0
                        OR psseguro IS NULL THEN
                        BEGIN
                           -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                           error_bucle := FALSE;

                           FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                                         FROM ctaseguro_shadow
                                        WHERE sseguro = valor.sseguro
                                          AND cmovimi = 71
                                          AND cesta = regs.ccesta
                                          AND TRUNC(fvalmov) = TRUNC(pfvalmov)
                                          AND imovimi = 0
                                          AND(nunidad = 0
                                              OR nunidad IS NULL)) LOOP
                              -- Actualizamos los movimientos de detalle (asignamos las unidades que le tocan según el valor
                              -- de provisión a fecha de la asignación
                              UPDATE ctaseguro_shadow
                                 SET imovimi = vimovimo,
                                     nunidad = vimovimo / preciounidad,
                                     cestado = '2',
                                     fasign = valor.fvalmov
                               WHERE sseguro = reg.sseguro
                                 AND fcontab = reg.fcontab
                                 AND nnumlin = reg.nnumlin;

                              IF v_cmultimon = 1 THEN
                                 num_err :=
                                    pac_oper_monedas.f_update_ctaseguro_shw_monpol
                                                                                 (reg.sseguro,
                                                                                  reg.fcontab,
                                                                                  reg.nnumlin,
                                                                                  reg.fvalmov);

                                 IF num_err <> 0 THEN
                                    p_tab_error
                                       (f_sysdate, f_user,
                                        ' 5. PAC_MANTENIMIENTO_FONDOS_FINV.F_REDIST_ASIGN_UNIDADES_SHW',
                                        ntraza, 'parametros: pfvalmov = ' || pfvalmov,
                                        f_axis_literales(num_err, pcidioma_user));
                                    num_err := f_proceslin(psproces,
                                                           f_axis_literales(180713,
                                                                            pcidioma_user)
                                                           || ' '
                                                           || f_axis_literales(104482,
                                                                               pcidioma_user)
                                                           || valor.sseguro,
                                                           num_err, vnprolin, 1);
                                    error_bucle := TRUE;
                                 END IF;
                              END IF;
                           END LOOP;

                           IF error_bucle THEN
                              algun_error := 1;
                              nerrores := nerrores + 1;
                           END IF;
                        -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                        EXCEPTION
                           WHEN OTHERS THEN
                              p_tab_error
                                 (f_sysdate, f_user,
                                  ' 5. PAC_MANTENIMIENTO_FONDOS_FINV.F_POST_ASIGN_UNIDADES_SHW',
                                  ntraza, 'parametros: pfvalmov = ' || pfvalmov, SQLERRM);
                              vtexto := f_axis_literales(107223, pcidioma_user);
                              num_err := f_proceslin(psproces,
                                                     f_axis_literales(180713, pcidioma_user)
                                                     || ' '
                                                     || f_axis_literales(104482,
                                                                         pcidioma_user)
                                                     || valor.sseguro || ','
                                                     || f_axis_literales(103242,
                                                                         pcidioma_user)
                                                     || vtexto,
                                                     num_err, vnprolin, 1);
                              algun_error := 1;
                              nerrores := nerrores + 1;
                        --RETURN 107223;
                        END;

                        -- Actualizamos las participaciones asignadas a la cesta
                        ntraza := 9;
                     END IF;
                  END IF;
               END LOOP;

               IF algun_error = 0
                  OR psseguro IS NULL THEN
                  BEGIN
                     -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     error_bucle := FALSE;

                     FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                                   FROM ctaseguro_shadow
                                  WHERE sseguro = valor.sseguro
                                    AND cmovimi = valor.cmovimi
                                    AND TRUNC(fvalmov) = TRUNC(pfvalmov)
                                    AND imovimi = 0
                                    AND(nunidad = 0
                                        OR nunidad IS NULL)) LOOP
                        UPDATE ctaseguro_shadow
                           SET imovimi = NVL(totalsaldo, 0),
                               cestado = '2',
                               fasign = pfvalmov
                         WHERE sseguro = reg.sseguro
                           AND fcontab = reg.fcontab
                           AND nnumlin = reg.nnumlin;

                        IF v_cmultimon = 1 THEN
                           num_err :=
                              pac_oper_monedas.f_update_ctaseguro_shw_monpol(reg.sseguro,
                                                                             reg.fcontab,
                                                                             reg.nnumlin,
                                                                             reg.fvalmov);

                           IF num_err <> 0 THEN
                              p_tab_error
                                 (f_sysdate, f_user,
                                  ' 5. PAC_MANTENIMIENTO_FONDOS_FINV.F_REDIST_ASIGN_UNIDADES_SHW',
                                  ntraza, 'parametros: pfvalmov = ' || pfvalmov,
                                  f_axis_literales(num_err, pcidioma_user));
                              num_err := f_proceslin(psproces,
                                                     f_axis_literales(180713, pcidioma_user)
                                                     || ' '
                                                     || f_axis_literales(104482,
                                                                         pcidioma_user)
                                                     || valor.sseguro,
                                                     num_err, vnprolin, 1);
                              error_bucle := TRUE;
                           END IF;
                        END IF;
                     END LOOP;

                     IF error_bucle THEN
                        algun_error := 1;
                        nerrores := nerrores + 1;
                     END IF;
                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error
                               (f_sysdate, f_user,
                                ' 5. PAC_MANTENIMIENTO_FONDOS_FINV.F_POST_ASIGN_UNIDADES_SHW',
                                ntraza, 'parametros: pfvalmov = ' || pfvalmov, SQLERRM);
                        vtexto := f_axis_literales(107223, pcidioma_user);
                        num_err := f_proceslin(psproces,
                                               f_axis_literales(180713, pcidioma_user) || ' '
                                               || f_axis_literales(104482, pcidioma_user)
                                               || valor.sseguro || ','
                                               || f_axis_literales(103242, pcidioma_user)
                                               || vtexto,
                                               num_err, vnprolin, 1);
                        algun_error := 1;
                        nerrores := nerrores + 1;
                  --RETURN 107223;
                  END;
               END IF;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user,
                           ' 6. PAC_MANTENIMIENTO_FONDOS_FINV.F_POST_ASIGN_UNIDADES_SHW',
                           ntraza, 'parametros: pfvalmov = ' || pfvalmov, SQLERRM);
               vtexto := f_axis_literales(107223, pcidioma_user);
               num_err := f_proceslin(psproces,
                                      f_axis_literales(180713, pcidioma_user) || ' '
                                      || f_axis_literales(104482, pcidioma_user)
                                      || valor.sseguro || ','
                                      || f_axis_literales(103242, pcidioma_user) || vtexto,
                                      num_err, vnprolin, 1);
               algun_error := 1;
               nerrores := nerrores + 1;
         --RETURN 107223;
         END;
      END LOOP;

      IF psseguro IS NULL THEN
         IF algun_error = 0 THEN
            COMMIT;
         ELSE
            ROLLBACK;
         END IF;
      END IF;

      RETURN 0;
   END f_redist_asign_unidades_shw;

-- -----------------------------------------------------------------------------------
-- Asignación de unidades
-- -----------------------------------------------------------------------------------
   -- Bug 0018741 - JMF - 07/06/2011
   FUNCTION f_asign_unidades(
      pfvalmov IN DATE,
      pcidioma_user IN NUMBER,
      pcempres IN NUMBER,
      p_cesta IN NUMBER DEFAULT NULL,
      psseguro IN NUMBER DEFAULT NULL)   -- Bug 18851 - RSC - 23/06/2011
      RETURN NUMBER IS
      CURSOR cctaseguro IS
         SELECT   --+ INDEX(s SEGUROS_CAGRPRO_NUK) INDEX(c CTASEGURO_ULK_CS_NUK)
                  c.sseguro, c.cmovimi, c.imovimi, c.nunidad, c.cesta, c.fvalmov, c.cestado,
                  c.fcontab, c.nnumlin, c.ccalint
             FROM ctaseguro c, seguros s
            WHERE c.sseguro = s.sseguro
              AND s.cagrpro IN(21, 11)   -- bug 12440 pps civ.
              AND c.cestado IN('1', '9')
              AND c.cesta IS NOT NULL
              -- JGM - bug 10824 -- 31/07/09
              AND cempres = NVL(pcempres, cempres)
              AND c.cesta = NVL(p_cesta, c.cesta)
              AND s.sseguro = NVL(psseguro, s.sseguro)
              -- Bug 18851 - RSC - 23/06/2011
              AND(c.nunidad <= 0
                  OR c.nunidad IS NULL
                  OR c.imovimi = 0)
              AND TRUNC(c.fvalmov) <= TRUNC(pfvalmov)
         ORDER BY c.sseguro, c.fvalmov, c.nnumlin;

      --AND cmovanu = 0
      -- Hemos quitado esta condición en la SELECT por la siguiente razón:
      -- Si hay un impago de una aportación que todavia no se ha asignado
      -- entonces se asignarian las participaciones en negativo del movimiento 58,
      -- pero estas solo tienen sentido si se asignan las participaciones en + del
      -- movimiento de aportación (para equilibrar el saldo y dejarlo igual --> impago)
      importe        NUMBER;
      unidades       NUMBER;
      preciounidad   NUMBER;
      preciounidadcmp NUMBER;
      preciounidadvtashw NUMBER;
      preciounidadcmpshw NUMBER;
      numunidades    NUMBER;
      impmovimi      NUMBER;
      fondocuenta    NUMBER;
      pestado        VARCHAR2(1);
      num_err        NUMBER;

      TYPE tt_date_asign IS TABLE OF DATE
         INDEX BY BINARY_INTEGER;

      tabladates     tt_date_asign;
      ejecutared     NUMBER := 1;
      v_ccalint      NUMBER;
      vsseguro_a     NUMBER := -1;
      vsseguro_b     NUMBER := -1;
      v_sproces      NUMBER;
      vtexto         VARCHAR2(100);
      vnprolin       NUMBER;
      algun_error    NUMBER := 0;
      nerrores       NUMBER := 0;
      -- numero de errores en el proceso
      vccodfon       NUMBER;
      vtraza         NUMBER := 0;
      --vfvalmov_a    DATE := to_date('01/01/1900','dd/mm/yyyy');
      --vfvalmov_b    DATE := to_date('01/01/1900','dd/mm/yyyy');
      errorexp       EXCEPTION;
      -- RSC 09/01/2008
      vfdiahabil     DATE;
      vcempres       empresas.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
   BEGIN
      --Arreglo provisional, el vcempres se acabará obteniendo por el parámetro pcempres
      --vcempres:=pcempres;
      vcempres := pac_md_common.f_get_cxtempresa;
      -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
      v_cmultimon := NVL(pac_parametros.f_parempresa_n(vcempres, 'MULTIMONEDA'), 0);
      -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
      num_err := f_procesini(f_user, vcempres,
                             'ASIG_FINV:' || TO_CHAR(pfvalmov, 'dd/mm/yyyy'),
                             f_axis_literales(180712, pcidioma_user), v_sproces);
      -- Ejecutamos la funcion para consolidar movimientos por redistribución
      -- (Se ejecuta antes de asignar unidades) --> Las aportaciones que se habian realizado
      -- antes de la redistribución ya se han redistribuido en función de la nueva redistribución.
      -- Por eso no importa llamar al principio de todo.

      -- De momento consolida la redistribución de la fecha de asignación
      num_err := f_redist_asign_unidades(pfvalmov, v_sproces, nerrores, pcidioma_user,
                                         pcempres);

      FOR valor IN cctaseguro LOOP
         BEGIN
                /*
                 vsseguro_b := valor.sseguro;
                 IF vsseguro_b <> vsseguro_a THEN -- Al cambiar de seguro hacemos COMMIT del anterior seguro
                   vsseguro_a := vsseguro_b;
                   IF algun_error = 0 THEN
                     COMMIT;
                   ELSE
                     ROLLBACK;
                   END IF;
                   algun_error := 0;
                 END IF;


            */
            vtraza := 1;

            BEGIN
               SELECT p.ccodfon
                 INTO fondocuenta
                 FROM productos_ulk p, seguros s
                WHERE p.cramo = s.cramo
                  AND p.cmodali = s.cmodali
                  AND p.ctipseg = s.ctipseg
                  AND p.ccolect = s.ccolect
                  -- JGM - bug 10824 -- 31/07/09
                  AND cempres = NVL(pcempres, cempres)
                  --
                  AND s.sseguro = valor.sseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  fondocuenta := NULL;
            END;

            vtraza := 2;
            importe := valor.imovimi;
            unidades := valor.nunidad;
            vtraza := 3;

            --SI UNIDADES = 0"
            IF unidades = 0
               OR unidades IS NULL THEN
               BEGIN
                  -- RSC 09/01/2008 Obtenemos el último día habil
                  vtraza := 4;
                  vfdiahabil := f_diahabil(12, TRUNC(valor.fvalmov), NULL);

                  BEGIN
                     SELECT iuniact, iuniactcmp, iuniactvtashw,
                            iuniactcmpshw
                       INTO preciounidad, preciounidadcmp, preciounidadvtashw,
                            preciounidadcmpshw
                       FROM tabvalces
                      WHERE ccesta = valor.cesta
                        AND TRUNC(fvalor) = TRUNC(vfdiahabil);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        RAISE errorexp;   -- RSC 08/01/2008
                  END;

                  vtraza := 5;
                  --ACTUALITZAR CTASEGURO"
                  numunidades := importe / NVL(preciounidadcmp, preciounidad);

                  -- cmovimi = 58 --> Anulación Aport. detalle
                       --  cmovimi = 91,93,94,97,87
                  -- Bug 0018741 - JMF - 07/06/2011 : Ricard afegir 99.
                  IF valor.cmovimi IN(5, 6, 7, 21, 22, 23, 24, 26, 27, 28, 29, 39, 58, 83, 84,
                                      91, 93, 94, 97, 87, 88, 99) THEN
                     numunidades := importe / NVL(preciounidadcmp, preciounidad);
                     numunidades := numunidades * -1;
                  END IF;

                  IF valor.cestado = '9' THEN
                     pestado := '9';
                  ELSE
                     pestado := '2';
                  END IF;

                  vtraza := 6;

                  UPDATE ctaseguro
                     SET nunidad = numunidades,
                         cestado = pestado,
                         fasign = pfvalmov
                   WHERE sseguro = valor.sseguro
                     AND TRUNC(fcontab) = TRUNC(valor.fcontab)
                     AND nnumlin = valor.nnumlin;

                  vtraza := 7;

                  -- Para la impresión de libreta (para que los movimientos generales también tenga actualizada
                  -- la fecha de asignación. Actualizamos el movimiento general anterior
                  UPDATE ctaseguro
                     SET cestado = pestado,
                         fasign = pfvalmov
                   WHERE sseguro = valor.sseguro
                     AND TRUNC(fcontab) = TRUNC(valor.fcontab)
                     AND ccalint = valor.ccalint
                     AND cesta IS NULL
                     AND nnumlin < valor.nnumlin;

-----------------------------------------------------------------
                  vtraza := 8;

                  --ACTUALIZAR CESTA"
                  UPDATE fondos
                     SET fondos.nparasi = NVL(fondos.nparasi, 0) + numunidades
                   WHERE fondos.ccodfon = valor.cesta
                     -- JGM - bug 10824 -- 31/07/09
                     AND cempres = NVL(pcempres, cempres);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     SELECT ccodfon
                       INTO vccodfon
                       FROM parpgcf
                      WHERE ccesta = valor.cesta
                        -- JGM - bug 10824 -- 31/07/09
                        AND cempres = NVL(pcempres, cempres)
                                                            --
                     ;

                     ROLLBACK;
                     vtexto := f_axis_literales(180619, pcidioma_user);
                     num_err := f_proceslin(v_sproces,
                                            f_axis_literales(180715, pcidioma_user)
                                            || f_axis_literales(104482, pcidioma_user)
                                            || valor.sseguro || ','
                                            || f_axis_literales(102512, pcidioma_user) || ' '
                                            || valor.fvalmov || ',' || vtexto || ' ' || '('
                                            || vccodfon || ')',
                                            num_err, vnprolin, 1);
                     COMMIT;
                     --algun_error := 1;
                     nerrores := nerrores + 1;
                  --NULL;
                  WHEN OTHERS THEN
                     --RETURN 107223;
                     vtexto := f_axis_literales(107223, pcidioma_user);
                     ROLLBACK;
                     num_err := f_proceslin(v_sproces,
                                            f_axis_literales(180715, pcidioma_user) || ' '
                                            || f_axis_literales(104482, pcidioma_user)
                                            || valor.sseguro || ','
                                            || f_axis_literales(103242, pcidioma_user)
                                            || vtexto,
                                            num_err, vnprolin, 1);
                     COMMIT;
                     --algun_error := 1;
                     nerrores := nerrores + 1;
               END;
            END IF;

            --SI UNIDADES < 0 E IMPORTE = 0"
            IF unidades < 0
               AND(importe = 0
                   OR importe IS NULL) THEN
               BEGIN
                  -- RSC 09/01/2008
                  vfdiahabil := f_diahabil(12, TRUNC(valor.fvalmov), NULL);

                  BEGIN
                     SELECT iuniact, iuniactcmp, iuniactvtashw,
                            iuniactcmpshw
                       INTO preciounidad, preciounidadcmp, preciounidadvtashw,
                            preciounidadcmpshw
                       FROM tabvalces
                      WHERE ccesta = valor.cesta
                        AND TRUNC(fvalor) = TRUNC(vfdiahabil);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        RAISE errorexp;   -- RSC 08/01/2008
                  END;

                  --ACTUALIZAR CTASEGURO"
                  impmovimi := unidades * NVL(preciounidadcmp, preciounidad) * -1;

                  IF valor.cestado = '9' THEN
                     pestado := '9';
                  ELSE
                     pestado := '2';
                  END IF;

                  UPDATE ctaseguro
                     SET imovimi = impmovimi,
                         cestado = pestado,
                         fasign = pfvalmov
                   WHERE sseguro = valor.sseguro
                     AND TRUNC(fcontab) = TRUNC(valor.fcontab)
                     AND nnumlin = valor.nnumlin;

                  -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  IF v_cmultimon = 1 THEN
                     FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                                   FROM ctaseguro
                                  WHERE sseguro = valor.sseguro
                                    AND TRUNC(fcontab) = TRUNC(valor.fcontab)
                                    AND nnumlin = valor.nnumlin) LOOP
                        num_err := pac_oper_monedas.f_update_ctaseguro_monpol(reg.sseguro,
                                                                              reg.fcontab,
                                                                              reg.nnumlin,
                                                                              reg.fvalmov);

                        IF num_err <> 0 THEN
                           nerrores := nerrores + 1;
                           vtexto := f_axis_literales(num_err, pcidioma_user);
                           RAISE errorexp;
                        END IF;
                     END LOOP;
                  END IF;

                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda

                  -- Para la impresión de libreta (para que los movimientos generales también tengan actualizada
                  -- la fecha de asignación. Actualizamos el movimiento general anterior
                  UPDATE ctaseguro
                     SET cestado = pestado,
                         fasign = pfvalmov
                   WHERE sseguro = valor.sseguro
                     AND TRUNC(fcontab) = TRUNC(valor.fcontab)
                     AND ccalint = valor.ccalint
                     AND cesta IS NULL
                     AND nnumlin < valor.nnumlin;

-----------------------------------------------------------------

                  --ACTUALIZAR CESTA"
                  UPDATE fondos
                     SET fondos.nparasi = NVL(fondos.nparasi, 0) + unidades
                   WHERE fondos.ccodfon = valor.cesta
                     -- JGM - bug 10824 -- 31/07/09
                     AND cempres = NVL(pcempres, cempres)
                                                         --
                  ;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     vtexto := f_axis_literales(180619, pcidioma_user);
                     ROLLBACK;
                     num_err := f_proceslin(v_sproces,
                                            f_axis_literales(180715, pcidioma_user) || ' '
                                            || f_axis_literales(104482, pcidioma_user)
                                            || valor.sseguro || ','
                                            || f_axis_literales(102512, pcidioma_user) || ' '
                                            || valor.fvalmov || ',' || vtexto,
                                            num_err, vnprolin, 1);
                     COMMIT;
                     --algun_error := 1;
                     nerrores := nerrores + 1;
                  --NULL;
                  WHEN OTHERS THEN
                     vtexto := f_axis_literales(107223, pcidioma_user);
                     ROLLBACK;
                     num_err := f_proceslin(v_sproces,
                                            f_axis_literales(180715, pcidioma_user) || ' '
                                            || f_axis_literales(104482, pcidioma_user)
                                            || valor.sseguro || ','
                                            || f_axis_literales(103242, pcidioma_user)
                                            || vtexto,
                                            num_err, vnprolin, 1);
                     COMMIT;
                     --algun_error := 1;
                     nerrores := nerrores + 1;
               --RETURN 107223;
               END;
            END IF;

            COMMIT;
         EXCEPTION
            WHEN errorexp THEN   -- RSC 08/01/2008
               ROLLBACK;
               num_err := f_proceslin(v_sproces,
                                      f_axis_literales(180715, pcidioma_user) || ' '
                                      || f_axis_literales(104482, pcidioma_user)
                                      || valor.sseguro || ','
                                      || f_axis_literales(103242, pcidioma_user) || vtexto,
                                      num_err, vnprolin, 1);
               COMMIT;
         END;
      END LOOP;

      --IF algun_error = 0 THEN  -- Commit o rollback del último seguro tratado en el bucle anterior
      --   COMMIT;
      --ELSE
      --   ROLLBACK;
      --END IF;

      --
      BEGIN
         FOR seg IN (SELECT sseguro
                       FROM seguros
                      WHERE cagrpro IN(11, 21)   -- Bug - 13/05/2010 - RSC
                        -- JGM - bug 10824 -- 31/07/09
                        AND cempres = NVL(pcempres, cempres)
                                                            --
                   ) LOOP
            FOR valor IN (SELECT ROWID, cmovimi, nunidad, cestado, fasign
                            FROM ctaseguro
                           WHERE sseguro = seg.sseguro) LOOP
               IF valor.fasign IS NULL
                  AND valor.cestado = '2' THEN
                  UPDATE ctaseguro
                     SET fasign = pfvalmov
                   WHERE ROWID = valor.ROWID;
               END IF;
            END LOOP;
         END LOOP;
      END;

      -- Bug 0018741 - JMF - 07/06/2011
      IF p_cesta IS NULL
         AND psseguro IS NULL THEN
         num_err := f_asign_unidades_shw(pfvalmov, pcidioma_user, pcempres, p_cesta, psseguro);

         IF num_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_MANTENIMIENTO_FONDOS_FINV.f_asign_unidades',
                        1,
                        'error en f_asign_unidades_shw' || '#' || num_err || '#'
                        || TO_CHAR(pfvalmov) || '#' || p_cesta || '#' || psseguro,
                        SQLERRM);
         END IF;

         -- Realizamos las valoraciones de siniestros -------------------------
         num_err := f_genera_valsiniestros(pfvalmov, v_sproces, nerrores, pcidioma_user);
      END IF;

----------------------------------------------------------------------

      -- Finalizamos proces
      num_err := f_procesfin(v_sproces, nerrores);
      RETURN 0;
   END f_asign_unidades;

-- -----------------------------------------------------------------------------------
-- Asignación de unidades
-- -----------------------------------------------------------------------------------
   -- Bug 0018741 - JMF - 07/06/2011
   FUNCTION f_asign_unidades_shw(
      pfvalmov IN DATE,
      pcidioma_user IN NUMBER,
      pcempres IN NUMBER,
      p_cesta IN NUMBER DEFAULT NULL,
      psseguro IN NUMBER DEFAULT NULL)   -- Bug 18851 - RSC - 23/06/2011
      RETURN NUMBER IS
      CURSOR cctaseguro_shadow IS
         SELECT   --+ INDEX(s SEGUROS_CAGRPRO_NUK) INDEX(c ctaseguro_shadow_ULK_CS_NUK)
                  c.sseguro, c.cmovimi, c.imovimi, c.nunidad, c.cesta, c.fvalmov, c.cestado,
                  c.fcontab, c.nnumlin, c.ccalint
             FROM ctaseguro_shadow c, seguros s
            WHERE c.sseguro = s.sseguro
              AND s.cagrpro IN(21, 11)   -- bug 12440 pps civ.
              AND c.cestado IN('1', '9')
              AND c.cesta IS NOT NULL
              -- JGM - bug 10824 -- 31/07/09
              AND cempres = NVL(pcempres, cempres)
              AND c.cesta = NVL(p_cesta, c.cesta)
              AND s.sseguro = NVL(psseguro, s.sseguro)
              -- Bug 18851 - RSC - 23/06/2011
              AND(c.nunidad <= 0
                  OR c.nunidad IS NULL
                  OR c.imovimi = 0)
              AND TRUNC(c.fvalmov) <= TRUNC(pfvalmov)
         ORDER BY c.sseguro, c.fvalmov, c.nnumlin;

      --AND cmovanu = 0
      -- Hemos quitado esta condición en la SELECT por la siguiente razón:
      -- Si hay un impago de una aportación que todavia no se ha asignado
      -- entonces se asignarian las participaciones en negativo del movimiento 58,
      -- pero estas solo tienen sentido si se asignan las participaciones en + del
      -- movimiento de aportación (para equilibrar el saldo y dejarlo igual --> impago)
      importe        NUMBER;
      unidades       NUMBER;
      preciounidad   NUMBER;
      preciounidadcmp NUMBER;
      preciounidadvtashw NUMBER;
      preciounidadcmpshw NUMBER;
      numunidades    NUMBER;
      impmovimi      NUMBER;
      fondocuenta    NUMBER;
      pestado        VARCHAR2(1);
      num_err        NUMBER;

      TYPE tt_date_asign IS TABLE OF DATE
         INDEX BY BINARY_INTEGER;

      tabladates     tt_date_asign;
      ejecutared     NUMBER := 1;
      v_ccalint      NUMBER;
      vsseguro_a     NUMBER := -1;
      vsseguro_b     NUMBER := -1;
      v_sproces      NUMBER;
      vtexto         VARCHAR2(100);
      vnprolin       NUMBER;
      algun_error    NUMBER := 0;
      nerrores       NUMBER := 0;
      -- numero de errores en el proceso
      vccodfon       NUMBER;
      vtraza         NUMBER := 0;
      --vfvalmov_a    DATE := to_date('01/01/1900','dd/mm/yyyy');
      --vfvalmov_b    DATE := to_date('01/01/1900','dd/mm/yyyy');
      errorexp       EXCEPTION;
      -- RSC 09/01/2008
      vfdiahabil     DATE;
      vcempres       empresas.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
   BEGIN
      --Arreglo provisional, el vcempres se acabará obteniendo por el parámetro pcempres
      --vcempres:=pcempres;
      vcempres := pac_md_common.f_get_cxtempresa;
      -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
      v_cmultimon := NVL(pac_parametros.f_parempresa_n(vcempres, 'MULTIMONEDA'), 0);
      -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
      num_err := f_procesini(f_user, vcempres,
                             'ASIG_FSHW:' || TO_CHAR(pfvalmov, 'dd/mm/yyyy'),
                             f_axis_literales(180712, pcidioma_user), v_sproces);
      -- Ejecutamos la funcion para consolidar movimientos por redistribución
      -- (Se ejecuta antes de asignar unidades) --> Las aportaciones que se habian realizado
      -- antes de la redistribución ya se han redistribuido en función de la nueva redistribución.
      -- Por eso no importa llamar al principio de todo.

      -- De momento consolida la redistribución de la fecha de asignación
      num_err := f_redist_asign_unidades_shw(pfvalmov, v_sproces, nerrores, pcidioma_user,
                                             pcempres);

      FOR valor IN cctaseguro_shadow LOOP
         BEGIN
            vtraza := 1;

            BEGIN
               SELECT p.ccodfon
                 INTO fondocuenta
                 FROM productos_ulk p, seguros s
                WHERE p.cramo = s.cramo
                  AND p.cmodali = s.cmodali
                  AND p.ctipseg = s.ctipseg
                  AND p.ccolect = s.ccolect
                  -- JGM - bug 10824 -- 31/07/09
                  AND cempres = NVL(pcempres, cempres)
                  --
                  AND s.sseguro = valor.sseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  fondocuenta := NULL;
            END;

            vtraza := 2;
            importe := valor.imovimi;
            unidades := valor.nunidad;
            vtraza := 3;

            --SI UNIDADES = 0"
            IF unidades = 0
               OR unidades IS NULL THEN
               BEGIN
                  -- RSC 09/01/2008 Obtenemos el último día habil
                  vtraza := 4;
                  vfdiahabil := f_diahabil(12, TRUNC(valor.fvalmov), NULL);

                  BEGIN
                     SELECT iuniact, iuniactcmp, iuniactvtashw,
                            iuniactcmpshw
                       INTO preciounidad, preciounidadcmp, preciounidadvtashw,
                            preciounidadcmpshw
                       FROM tabvalces
                      WHERE ccesta = valor.cesta
                        AND TRUNC(fvalor) = TRUNC(vfdiahabil);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        RAISE errorexp;   -- RSC 08/01/2008
                  END;

                  vtraza := 5;
                  --ACTUALITZAR ctaseguro_shadow"
                  numunidades := importe / preciounidadcmpshw;

                  -- cmovimi = 58 --> Anulación Aport. detalle
                       --  cmovimi = 91,93,94,97,87
                  -- Bug 0018741 - JMF - 07/06/2011 : Ricard afegir 99.
                  IF valor.cmovimi IN(5, 6, 7, 21, 22, 23, 24, 26, 27, 28, 29, 39, 58, 83, 84,
                                      91, 93, 94, 97, 87, 88, 99) THEN
                     numunidades := importe / preciounidadcmpshw;
                     numunidades := numunidades * -1;
                  END IF;

                  IF valor.cestado = '9' THEN
                     pestado := '9';
                  ELSE
                     pestado := '2';
                  END IF;

                  vtraza := 6;

                  UPDATE ctaseguro_shadow
                     SET nunidad = numunidades,
                         cestado = pestado,
                         fasign = pfvalmov
                   WHERE sseguro = valor.sseguro
                     AND TRUNC(fcontab) = TRUNC(valor.fcontab)
                     AND nnumlin = valor.nnumlin;

                  vtraza := 7;

                  -- Para la impresión de libreta (para que los movimientos generales también tenga actualizada
                  -- la fecha de asignación. Actualizamos el movimiento general anterior
                  UPDATE ctaseguro_shadow
                     SET cestado = pestado,
                         fasign = pfvalmov
                   WHERE sseguro = valor.sseguro
                     AND TRUNC(fcontab) = TRUNC(valor.fcontab)
                     AND ccalint = valor.ccalint
                     AND cesta IS NULL
                     AND nnumlin < valor.nnumlin;

-----------------------------------------------------------------
                  vtraza := 8;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     SELECT ccodfon
                       INTO vccodfon
                       FROM parpgcf
                      WHERE ccesta = valor.cesta
                        -- JGM - bug 10824 -- 31/07/09
                        AND cempres = NVL(pcempres, cempres);

                     ROLLBACK;
                     vtexto := f_axis_literales(180619, pcidioma_user);
                     num_err := f_proceslin(v_sproces,
                                            f_axis_literales(180715, pcidioma_user)
                                            || f_axis_literales(104482, pcidioma_user)
                                            || valor.sseguro || ','
                                            || f_axis_literales(102512, pcidioma_user) || ' '
                                            || valor.fvalmov || ',' || vtexto || ' ' || '('
                                            || vccodfon || ')',
                                            num_err, vnprolin, 1);
                     COMMIT;
                     --algun_error := 1;
                     nerrores := nerrores + 1;
                  --NULL;
                  WHEN OTHERS THEN
                     --RETURN 107223;
                     vtexto := f_axis_literales(107223, pcidioma_user);
                     ROLLBACK;
                     num_err := f_proceslin(v_sproces,
                                            f_axis_literales(180715, pcidioma_user) || ' '
                                            || f_axis_literales(104482, pcidioma_user)
                                            || valor.sseguro || ','
                                            || f_axis_literales(103242, pcidioma_user)
                                            || vtexto,
                                            num_err, vnprolin, 1);
                     COMMIT;
                     --algun_error := 1;
                     nerrores := nerrores + 1;
               END;
            END IF;

            --SI UNIDADES < 0 E IMPORTE = 0"
            IF unidades < 0
               AND(importe = 0
                   OR importe IS NULL) THEN
               BEGIN
                  -- RSC 09/01/2008
                  vfdiahabil := f_diahabil(12, TRUNC(valor.fvalmov), NULL);

                  BEGIN
                     SELECT iuniact, iuniactcmp, iuniactvtashw,
                            iuniactcmpshw
                       INTO preciounidad, preciounidadcmp, preciounidadvtashw,
                            preciounidadcmpshw
                       FROM tabvalces
                      WHERE ccesta = valor.cesta
                        AND TRUNC(fvalor) = TRUNC(vfdiahabil);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        RAISE errorexp;   -- RSC 08/01/2008
                  END;

                  --ACTUALIZAR ctaseguro_shadow"
                  impmovimi := unidades * preciounidadcmpshw * -1;

                  --
                  IF valor.cestado = '9' THEN
                     pestado := '9';
                  ELSE
                     pestado := '2';
                  END IF;

                  UPDATE ctaseguro_shadow
                     SET imovimi = impmovimi,
                         cestado = pestado,
                         fasign = pfvalmov
                   WHERE sseguro = valor.sseguro
                     AND TRUNC(fcontab) = TRUNC(valor.fcontab)
                     AND nnumlin = valor.nnumlin;

                  -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  IF v_cmultimon = 1 THEN
                     FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                                   FROM ctaseguro_shadow
                                  WHERE sseguro = valor.sseguro
                                    AND TRUNC(fcontab) = TRUNC(valor.fcontab)
                                    AND nnumlin = valor.nnumlin) LOOP
                        num_err :=
                           pac_oper_monedas.f_update_ctaseguro_shw_monpol(reg.sseguro,
                                                                          reg.fcontab,
                                                                          reg.nnumlin,
                                                                          reg.fvalmov);

                        IF num_err <> 0 THEN
                           nerrores := nerrores + 1;
                           vtexto := f_axis_literales(num_err, pcidioma_user);
                           RAISE errorexp;
                        END IF;
                     END LOOP;
                  END IF;

                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda

                  -- Para la impresión de libreta (para que los movimientos generales también tengan actualizada
                  -- la fecha de asignación. Actualizamos el movimiento general anterior
                  UPDATE ctaseguro_shadow
                     SET cestado = pestado,
                         fasign = pfvalmov
                   WHERE sseguro = valor.sseguro
                     AND TRUNC(fcontab) = TRUNC(valor.fcontab)
                     AND ccalint = valor.ccalint
                     AND cesta IS NULL
                     AND nnumlin < valor.nnumlin;
-----------------------------------------------------------------
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     vtexto := f_axis_literales(180619, pcidioma_user);
                     ROLLBACK;
                     num_err := f_proceslin(v_sproces,
                                            f_axis_literales(180715, pcidioma_user) || ' '
                                            || f_axis_literales(104482, pcidioma_user)
                                            || valor.sseguro || ','
                                            || f_axis_literales(102512, pcidioma_user) || ' '
                                            || valor.fvalmov || ',' || vtexto,
                                            num_err, vnprolin, 1);
                     COMMIT;
                     --algun_error := 1;
                     nerrores := nerrores + 1;
                  --NULL;
                  WHEN OTHERS THEN
                     vtexto := f_axis_literales(107223, pcidioma_user);
                     ROLLBACK;
                     num_err := f_proceslin(v_sproces,
                                            f_axis_literales(180715, pcidioma_user) || ' '
                                            || f_axis_literales(104482, pcidioma_user)
                                            || valor.sseguro || ','
                                            || f_axis_literales(103242, pcidioma_user)
                                            || vtexto,
                                            num_err, vnprolin, 1);
                     COMMIT;
                     --algun_error := 1;
                     nerrores := nerrores + 1;
               --RETURN 107223;
               END;
            END IF;

            COMMIT;
         EXCEPTION
            WHEN errorexp THEN   -- RSC 08/01/2008
               ROLLBACK;
               num_err := f_proceslin(v_sproces,
                                      f_axis_literales(180715, pcidioma_user) || ' '
                                      || f_axis_literales(104482, pcidioma_user)
                                      || valor.sseguro || ','
                                      || f_axis_literales(103242, pcidioma_user) || vtexto,
                                      num_err, vnprolin, 1);
               COMMIT;
         END;
      END LOOP;

      --IF algun_error = 0 THEN  -- Commit o rollback del último seguro tratado en el bucle anterior
      --   COMMIT;
      --ELSE
      --   ROLLBACK;
      --END IF;

      --
      BEGIN
         FOR seg IN (SELECT sseguro
                       FROM seguros
                      WHERE cagrpro IN(11, 21)   -- Bug - 13/05/2010 - RSC
                        -- JGM - bug 10824 -- 31/07/09
                        AND cempres = NVL(pcempres, cempres)
                                                            --
                   ) LOOP
            FOR valor IN (SELECT ROWID, cmovimi, nunidad, cestado, fasign
                            FROM ctaseguro_shadow
                           WHERE sseguro = seg.sseguro) LOOP
               IF valor.fasign IS NULL
                  AND valor.cestado = '2' THEN
                  UPDATE ctaseguro_shadow
                     SET fasign = pfvalmov
                   WHERE ROWID = valor.ROWID;
               END IF;
            END LOOP;
         END LOOP;
      END;

      -- Finalizamos proces
      num_err := f_procesfin(v_sproces, nerrores);
      RETURN 0;
   END f_asign_unidades_shw;

   /******************************************************************************

      Función destinada a realizar las valoraciones de siniestros y rescates asignados
      a una poliza en el momento de la asignación.
    ******************************************************************************/--FUNCTION F_GENERA_VALSINIESTROS(psseguro IN NUMBER, pfsinies IN DATE) RETURN NUMBER IS
    --FUNCTION F_GENERA_VALSINIESTROS(psseguro IN NUMBER) RETURN NUMBER IS
   -- Bug 14160 - RSC - 16/04/2010 - CEM800 - Adaptar packages de productos de inversión al nuevo módulo de siniestros
   -- (incluimos nuevo módulo de siniestros)
   FUNCTION f_genera_valsiniestros(
      pfvalmov IN DATE,
      psproces IN OUT NUMBER,
      nerrores IN OUT NUMBER,
      pcidioma_user IN NUMBER)
      RETURN NUMBER IS
      -- Siniestros a una fecha que no se han valorado
      CURSOR cur_sinval IS
         SELECT   /*+ INDEX(se SEGUROS_CAGRPRO_NUK) INDEX(s SINIES_NUK_1) */
                  s.sseguro, s.fsinies, TO_CHAR(s.nsinies) nsinies, s.nasegur, s.nriesgo,
                  se.sproduc, se.cactivi, s.ccausin, s.cmotsin, s.fnotifi, se.cempres
             FROM siniestros s, seguros se
            WHERE s.sseguro = se.sseguro
              AND se.cagrpro IN(11, 21)   -- Bug - 13/05/2010 - RSC
              AND se.csituac IN(0, 2)
              -- Bug 20309 - RSC - 28/02/2012: Hay anulaciones que generan rescate.
              AND (SELECT COUNT(*)
                     FROM valorasini v
                    WHERE v.nsinies = s.nsinies) = 0
              AND s.fsinies <= pfvalmov
              AND NVL(pac_parametros.f_parempresa_n(se.cempres, 'MODULO_SINI'), 0) = 0
         UNION
         SELECT   se.sseguro, s.fsinies, s.nsinies, s.nasegur, s.nriesgo, se.sproduc,
                  se.cactivi, s.ccausin, s.cmotsin, s.fnotifi, se.cempres
             FROM sin_siniestro s, seguros se, sin_movsiniestro sm
            WHERE s.sseguro = se.sseguro
              AND se.cagrpro IN(11, 21)   -- Bug - 13/05/2010 - RSC
              AND se.csituac IN(0, 2)
              -- Bug 20309 - RSC - 28/02/2012: Hay anulaciones que generan rescate.
              AND TRUNC(s.fsinies) <= pfvalmov
              AND (SELECT COUNT(*)
                     FROM sin_tramita_reserva v
                    WHERE v.nsinies = s.nsinies
                      AND v.ctipres = 1   -- jlb - 18423#c105054
                                       ) = 0
              AND NVL(pac_parametros.f_parempresa_n(se.cempres, 'MODULO_SINI'), 0) = 1
              AND NVL(f_parproductos_v(se.sproduc, 'RESCATE_VENTANA'), 0) = 0
         ORDER BY fsinies, sseguro, nsinies DESC;

      num_err        NUMBER;
      vivalora       NUMBER;
      vipenali       NUMBER;
      vicapris       NUMBER;
      vivalora_tot   NUMBER;
      xppagdes       NUMBER;
      cavis          NUMBER;
      pdatos         NUMBER;
      xnivel         NUMBER;
      vsseguro_a     NUMBER;
      vsseguro_b     NUMBER;
      vtexto         VARCHAR2(100);
      vnprolin       NUMBER;
      algun_error    NUMBER := 0;
      v_ntramit      NUMBER;
      v_cgarant      NUMBER;
      v_nmovres      NUMBER;
      v_sidepag      NUMBER;
      v_ipago        NUMBER;
      vifranq        NUMBER;
      usarshw        NUMBER;
      viuniact       NUMBER;
      viuniactshw    NUMBER;
      breserva       BOOLEAN := TRUE;
      vretenc        NUMBER;
      res            pac_sin_formula.t_val;
   BEGIN
      FOR regs IN cur_sinval LOOP
         -- Control para ir haciendo commit para cada seguro
         vsseguro_b := regs.sseguro;

         IF vsseguro_b <> vsseguro_a THEN   -- Al cambiar de seguro hacemos COMMIT del anterior seguro
            vsseguro_a := vsseguro_b;

            IF algun_error = 0 THEN
               COMMIT;
            ELSE
               ROLLBACK;
            END IF;

            algun_error := 0;
         END IF;

         num_err := f_valora_siniestros_fnd(pfvalmov, NULL, regs.sseguro, psproces, nerrores,
                                            pcidioma_user, regs.ccausin);

         IF num_err <> 0 THEN
            algun_error := algun_error + 1;
            p_tab_error(f_sysdate, f_user,
                        'PAC_MANTENIMIENTOS_FONDOS_FINV.f_genera_valsiniestros', 1,
                        num_err || '#' || pfvalmov || '#' || regs.sseguro || '#' || psproces
                        || '#' || nerrores || '#' || pcidioma_user || '#' || regs.ccausin,
                        SQLERRM);
            algun_error := 1;
            nerrores := nerrores + 1;
         ELSE
            IF regs.ccausin = 1 THEN   -- Siniestros
               IF regs.cmotsin <> 4
                  OR(NVL(f_parproductos_v(regs.sproduc, 'USA_EDAD_CFALLAC'), 0) = 1
                     AND regs.cmotsin = 4) THEN
                  IF NVL(pac_parametros.f_parempresa_n(regs.cempres, 'MODULO_SINI'), 0) = 0 THEN
                     num_err := pk_cal_sini.valo_pagos_sini(regs.fsinies, regs.sseguro,
                                                            regs.nsinies, regs.sproduc,
                                                            regs.cactivi, 1, regs.ccausin,
                                                            regs.cmotsin, regs.fnotifi,
                                                            vivalora, vipenali, vicapris);

                     IF num_err <> 0 THEN
                        vtexto := f_axis_literales(num_err, pcidioma_user);
                        num_err := f_proceslin(psproces,
                                               f_axis_literales(180714, pcidioma_user) || ' '
                                               || f_axis_literales(104482, pcidioma_user)
                                               || regs.sseguro || ','
                                               || f_axis_literales(103242, pcidioma_user)
                                               || vtexto,
                                               num_err, vnprolin, 1);
                        algun_error := 1;
                        nerrores := nerrores + 1;
                     --RETURN num_err;
                     END IF;

                     num_err := pac_sin_insert.f_insert_valoraciones(regs.nsinies, 1,
                                                                     regs.fnotifi, vivalora,
                                                                     vipenali, vicapris);

                     IF num_err <> 0 THEN
                        vtexto := f_axis_literales(num_err, pcidioma_user);
                        num_err := f_proceslin(psproces,
                                               f_axis_literales(180714, pcidioma_user) || ' '
                                               || f_axis_literales(104482, pcidioma_user)
                                               || regs.sseguro || ','
                                               || f_axis_literales(103242, pcidioma_user)
                                               || vtexto,
                                               num_err, vnprolin, 1);
                        algun_error := 1;
                        nerrores := nerrores + 1;
                     --RETURN num_err;
                     END IF;
                  END IF;

                  IF NVL(pac_parametros.f_parempresa_n(regs.cempres, 'MODULO_SINI'), 0) = 1 THEN
                     FOR reg IN (SELECT DISTINCT cgarant
                                            FROM sin_gar_causa_motivo sgcm,
                                                 sin_causa_motivo scm
                                           WHERE sgcm.scaumot = scm.scaumot
                                             AND scm.ccausin = regs.ccausin
                                             AND scm.cmotsin = regs.cmotsin
                                             AND sgcm.sproduc = regs.sproduc
                                             AND sgcm.cactivi = regs.cactivi) LOOP
                        SELECT ntramit
                          INTO v_ntramit
                          FROM sin_tramitacion
                         WHERE nsinies = regs.nsinies
                           AND ntramit = 0;

                        -- Bug 20665 - RSC - 14/02/2012 - LCOL_T001-LCOL - UAT - TEC - Rescates
                        v_cgarant := reg.cgarant;
                        -- Se ejecutan las valoraciones contra la garantía
                        num_err := pac_sin_formula.f_cal_valora(regs.fsinies, regs.sseguro,
                                                                regs.nriesgo, regs.nsinies,
                                                                v_ntramit, 0, regs.sproduc,
                                                                regs.cactivi, v_cgarant,
                                                                regs.ccausin, regs.cmotsin,
                                                                regs.fnotifi, regs.fnotifi,
                                                                NULL, NULL, vivalora, vipenali,
                                                                vicapris, vifranq
                                                                                 --Bug 27059:NSS:05/06/2013
                                  );

                        IF num_err <> 0 THEN
                           algun_error := 1;
                           nerrores := nerrores + 1;
                           p_tab_error
                                     (f_sysdate, f_user,
                                      'PAC_MANTENIMIENTOS_FONDOS_FINV.f_genera_valsiniestros',
                                      2,
                                      f_axis_literales(num_err, -1) || '#' || pfvalmov || '#'
                                      || regs.sseguro || '#' || psproces || '#' || nerrores
                                      || '#' || pcidioma_user || '#' || regs.ccausin,
                                      SQLERRM);
                        END IF;

                        -- Se inserta la reserva
                        num_err :=
                           pac_siniestros.f_ins_reserva
                                                  (regs.nriesgo, v_ntramit, 1, v_cgarant, 1,
                                                   regs.fsinies, NULL,

-- BUG 18423 - 14/11/2011 - JMP - Pasamos moneda reserva NULL para que la coja en función
-- de si es multimoneda o no
                                                   NVL(vivalora, 0) - NVL(vipenali, 0), NULL,
                                                   vicapris, vipenali, NULL, NULL, NULL, NULL,
                                                   NULL, NULL, NULL, NULL, v_nmovres,
                                                   1   --cmovres --Bug 31294/174788:NSS:22/05/2014
                                                    );

                        IF num_err <> 0 THEN
                           algun_error := 1;
                           nerrores := nerrores + 1;
                           p_tab_error
                                     (f_sysdate, f_user,
                                      'PAC_MANTENIMIENTOS_FONDOS_FINV.f_genera_valsiniestros',
                                      1,
                                      f_axis_literales(num_err, -1) || '#' || pfvalmov || '#'
                                      || regs.sseguro || '#' || psproces || '#' || nerrores
                                      || '#' || pcidioma_user || '#' || regs.ccausin,
                                      SQLERRM);
                        END IF;

                        vivalora_tot := vivalora_tot +(NVL(vivalora, 0) - NVL(vipenali, 0));
                     END LOOP;
                  END IF;
               END IF;
            -- La valoraciones del Fallecimiento del 1er titular en pólizas a 2 Cabezas se realizará en el momento
            -- de valorar el Rescate Total (siguiente IF). En la función f_tratar_sinies_fallec.
            ELSIF regs.ccausin IN(3, 4) THEN   -- Rescate Total
               -- Considerando importe del rescate a 0 (en este caso seria rescate total)
               IF pac_rescates.f_vivo_o_muerto(regs.sseguro, 2, regs.fnotifi) = 1 THEN   -- hay un asegurado fallecido
                  num_err := pac_rescates.f_tratar_sinies_fallec(regs.sseguro, regs.fnotifi);

                  IF num_err <> 0 THEN
                     vtexto := f_axis_literales(num_err, pcidioma_user);
                     num_err := f_proceslin(psproces,
                                            f_axis_literales(180714, pcidioma_user) || ' '
                                            || f_axis_literales(104482, pcidioma_user)
                                            || regs.sseguro || ','
                                            || f_axis_literales(103242, pcidioma_user)
                                            || vtexto,
                                            num_err, vnprolin, 1);
                     algun_error := 1;
                     nerrores := nerrores + 1;
                  --return num_err;
                  END IF;
               END IF;

               vivalora_tot := 0;

               IF NVL(pac_parametros.f_parempresa_n(regs.cempres, 'MODULO_SINI'), 0) = 0 THEN
                  FOR reg2 IN (SELECT cgarant
                                 FROM prodcaumotsin
                                WHERE sproduc = regs.sproduc
                                  AND ccausin = regs.ccausin
                                  AND cmotsin = regs.cmotsin) LOOP
                     num_err := pk_cal_sini.valo_pagos_sini(regs.fsinies, regs.sseguro,
                                                            regs.nsinies, regs.sproduc,
                                                            regs.cactivi, reg2.cgarant,
                                                            regs.ccausin, regs.cmotsin,
                                                            regs.fnotifi, vivalora, vipenali,
                                                            vicapris);

                     IF num_err <> 0 THEN
                        vtexto := f_axis_literales(num_err, pcidioma_user);
                        num_err := f_proceslin(psproces,
                                               f_axis_literales(180714, pcidioma_user) || ' '
                                               || f_axis_literales(104482, pcidioma_user)
                                               || regs.sseguro || ','
                                               || f_axis_literales(103242, pcidioma_user)
                                               || vtexto,
                                               num_err, vnprolin, 1);
                        algun_error := 1;
                        nerrores := nerrores + 1;
                     --RETURN num_err;
                     END IF;

                     /* {registramos la valoración del siniestro} */
                     num_err := pac_sin_insert.f_insert_valoraciones(regs.nsinies,
                                                                     reg2.cgarant,
                                                                     regs.fnotifi,
                                                                     vivalora - vipenali,
                                                                     vipenali, vicapris);

                     IF num_err <> 0 THEN
                        vtexto := f_axis_literales(num_err, pcidioma_user);
                        num_err := f_proceslin(psproces,
                                               f_axis_literales(180714, pcidioma_user) || ' '
                                               || f_axis_literales(104482, pcidioma_user)
                                               || regs.sseguro || ','
                                               || f_axis_literales(103242, pcidioma_user)
                                               || vtexto,
                                               num_err, vnprolin, 1);
                        algun_error := 1;
                        nerrores := nerrores + 1;
                     --RETURN num_err;
                     END IF;

                     vivalora_tot := vivalora_tot +(vivalora - vipenali);
                  END LOOP;
               END IF;

               IF NVL(pac_parametros.f_parempresa_n(regs.cempres, 'MODULO_SINI'), 0) = 1 THEN
                  FOR reg IN (SELECT DISTINCT cgarant
                                         FROM sin_gar_causa_motivo sgcm, sin_causa_motivo scm
                                        WHERE sgcm.scaumot = scm.scaumot
                                          AND scm.ccausin = regs.ccausin
                                          AND scm.cmotsin = regs.cmotsin
                                          AND sgcm.sproduc = regs.sproduc
                                          AND sgcm.cactivi = regs.cactivi) LOOP
                     SELECT ntramit
                       INTO v_ntramit
                       FROM sin_tramitacion
                      WHERE nsinies = regs.nsinies
                        AND ntramit = 0;

                     -- Bug 20665 - RSC - 14/02/2012 - LCOL_T001-LCOL - UAT - TEC - Rescates
                     v_cgarant := reg.cgarant;
                     -- Se ejecutan las valoraciones contra la garantía
                     num_err := pac_sin_formula.f_cal_valora(regs.fsinies, regs.sseguro,
                                                             regs.nriesgo, regs.nsinies,
                                                             v_ntramit, 0, regs.sproduc,
                                                             regs.cactivi, v_cgarant,
                                                             regs.ccausin, regs.cmotsin,
                                                             regs.fnotifi, regs.fnotifi, NULL,
                                                             NULL, vivalora, vipenali,
                                                             vicapris, vifranq
                                                                              --Bug 27059:NSS:05/06/2013
                               );

                     IF num_err <> 0 THEN
                        vtexto := f_axis_literales(num_err, pcidioma_user);
                        num_err := f_proceslin(psproces,
                                               f_axis_literales(180714, pcidioma_user) || ' '
                                               || f_axis_literales(104482, pcidioma_user)
                                               || regs.sseguro || ','
                                               || f_axis_literales(103242, pcidioma_user)
                                               || vtexto,
                                               num_err, vnprolin, 1);
                        algun_error := 1;
                        nerrores := nerrores + 1;
                     END IF;

                     -- Se inserta la reserva
                     num_err := pac_siniestros.f_ins_reserva(regs.nsinies, v_ntramit, 1,
                                                             v_cgarant, 1, regs.fsinies, NULL,

-- BUG 18423 - 14/11/2011 - JMP - Pasamos moneda reserva NULL para que la coja en función
-- de si es multimoneda o no
                                                             NVL(vivalora, 0)
                                                             - NVL(vipenali, 0),
                                                             NULL, vicapris, vipenali, NULL,
                                                             NULL, NULL, NULL, NULL, NULL,
                                                             NULL, NULL, v_nmovres, 1);   --cmovres --Bug 31294/174788:NSS:22/05/2014

                     IF num_err <> 0 THEN
                        vtexto := f_axis_literales(num_err, pcidioma_user);
                        num_err := f_proceslin(psproces,
                                               f_axis_literales(180714, pcidioma_user) || ' '
                                               || f_axis_literales(104482, pcidioma_user)
                                               || regs.sseguro || ','
                                               || f_axis_literales(103242, pcidioma_user)
                                               || vtexto,
                                               num_err, vnprolin, 1);
                        algun_error := 1;
                        nerrores := nerrores + 1;
                     END IF;

                     vivalora_tot := vivalora_tot +(NVL(vivalora, 0) - NVL(vipenali, 0));
                  END LOOP;
               END IF;

               xppagdes := NULL;

               IF NVL(pac_parametros.f_parempresa_n(regs.cempres, 'MODULO_SINI'), 0) = 0 THEN
                  num_err := pac_sin_insert.f_insert_destinatarios(regs.nsinies, regs.sseguro,
                                                                   regs.nriesgo, xppagdes, 1,
                                                                   1, vivalora_tot, NULL,
                                                                   NULL, NULL);

                  IF num_err <> 0 THEN
                     vtexto := f_axis_literales(num_err, pcidioma_user);
                     num_err := f_proceslin(psproces,
                                            f_axis_literales(180714, pcidioma_user) || ' '
                                            || f_axis_literales(104482, pcidioma_user)
                                            || regs.sseguro || ','
                                            || f_axis_literales(103242, pcidioma_user)
                                            || vtexto,
                                            num_err, vnprolin, 1);
                     algun_error := 1;
                     nerrores := nerrores + 1;
                  END IF;
               END IF;

               IF NVL(pac_parametros.f_parempresa_n(regs.cempres, 'MODULO_SINI'), 0) = 1 THEN
                  num_err := pac_sin_rescates.f_ins_destinatario(regs.nsinies, v_ntramit,
                                                                 regs.sseguro, regs.nriesgo,
                                                                 xppagdes, 1, 1, NULL, NULL,
                                                                 NULL, NULL);

                  IF num_err <> 0 THEN
                     vtexto := f_axis_literales(num_err, pcidioma_user);
                     num_err := f_proceslin(psproces,
                                            f_axis_literales(180714, pcidioma_user) || ' '
                                            || f_axis_literales(104482, pcidioma_user)
                                            || regs.sseguro || ','
                                            || f_axis_literales(103242, pcidioma_user)
                                            || vtexto,
                                            num_err, vnprolin, 1);
                     algun_error := 1;
                     nerrores := nerrores + 1;
                  END IF;
               END IF;

               pk_cal_sini.borra_mensajes;

               IF NVL(pac_parametros.f_parempresa_n(regs.cempres, 'MODULO_SINI'), 0) = 0 THEN
                  num_err := pac_rescates.f_avisos_rescates(regs.sseguro, regs.fnotifi, NULL,
                                                            cavis, pdatos);

                  IF cavis IS NOT NULL THEN
                     xnivel := 2;   -- no se generan datos
                  ELSE
                     xnivel := 1;   -- se generarán también los pagos
                  END IF;

                  IF NVL(vivalora_tot, 0) > 0
                     AND xnivel = 1 THEN
                     -- Generamos los pagos
                     num_err := pk_cal_sini.gen_pag_sini(regs.fnotifi, regs.sseguro,
                                                         regs.nsinies, regs.sproduc,
                                                         regs.cactivi, regs.ccausin,
                                                         regs.cmotsin, regs.fnotifi);

                     IF num_err <> 0 THEN
                        vtexto := f_axis_literales(num_err, pcidioma_user);
                        num_err := f_proceslin(psproces,
                                               f_axis_literales(180714, pcidioma_user) || ' '
                                               || f_axis_literales(104482, pcidioma_user)
                                               || regs.sseguro || ','
                                               || f_axis_literales(103242, pcidioma_user)
                                               || vtexto,
                                               num_err, vnprolin, 1);
                        algun_error := 1;
                        nerrores := nerrores + 1;
                     --RETURN num_err;
                     END IF;

                     num_err := pk_cal_sini.insertar_pagos(regs.nsinies);

                     IF num_err <> 0 THEN
                        vtexto := f_axis_literales(num_err, pcidioma_user);
                        num_err := f_proceslin(psproces,
                                               f_axis_literales(180714, pcidioma_user) || ' '
                                               || f_axis_literales(104482, pcidioma_user)
                                               || regs.sseguro || ','
                                               || f_axis_literales(103242, pcidioma_user)
                                               || vtexto,
                                               num_err, vnprolin, 1);
                        algun_error := 1;
                        nerrores := nerrores + 1;
                     --RETURN num_err;
                     END IF;
                  END IF;
               END IF;

               IF NVL(pac_parametros.f_parempresa_n(regs.cempres, 'MODULO_SINI'), 0) = 1 THEN
                  IF NVL(vivalora_tot, 0) > 0 THEN
                     -- Generamos los pagos
                     num_err := pac_sin_formula.f_genera_pago(regs.sseguro, regs.nriesgo,

                                                              -- Bug 16219. FAL. 06/10/2010. Parametrizar que la generación del pago sea por garantia
                                                              v_cgarant,
                                                              -- Fi Bug 16219
                                                              regs.sproduc, regs.cactivi,
                                                              regs.nsinies, v_ntramit,
                                                              regs.ccausin, regs.cmotsin,
                                                              regs.fsinies, regs.fnotifi);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;

                     num_err := pac_sin_formula.f_inserta_pago(regs.nsinies, v_ntramit, 1,
                                                               v_cgarant, v_sidepag, v_ipago);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  END IF;
               END IF;

               num_err := f_traspaso_tmp_primas_cons(regs.sseguro, NULL, regs.nsinies);

               IF num_err <> 0 THEN
                  vtexto := f_axis_literales(num_err, pcidioma_user);
                  num_err := f_proceslin(psproces,
                                         f_axis_literales(180714, pcidioma_user) || ' '
                                         || f_axis_literales(104482, pcidioma_user)
                                         || regs.sseguro || ','
                                         || f_axis_literales(103242, pcidioma_user) || vtexto,
                                         num_err, vnprolin, 1);
                  algun_error := 1;
                  nerrores := nerrores + 1;
               END IF;
            ELSIF regs.ccausin = 5 THEN   -- Rescate Parcial
               /*
                   No debemos hacer nada con los rescates parciales. Al tratarse de un rescate parcial, la cantidad
                   o valoración del rescate la sabemos de antemanos. En la propia generación del rescate
                   (PAC_RESCATES.f_gest_siniestro) ya se realiza la inserción de la valoración, destinatarios y pagos
                   dejando el pago pendiente para ser tratado en el módulo de siniestros y transferencias.

               NULL;
               */
               usarshw := pac_propio.f_usar_shw(regs.sseguro, NULL);
               v_ntramit := 0;
               vivalora_tot := 0;

               FOR sinpre IN (SELECT stpf.nsinies, stpf.ntramit, stpf.ccesta,
                                     DECODE(usarshw,
                                            1, stpf.ireservashw,
                                            stpf.ireserva) ireserva
                                FROM sin_tramita_prereserva_fnd stpf, sin_siniestro s
                               WHERE stpf.nsinies = s.nsinies
                                 AND s.sseguro = regs.sseguro
                                 AND stpf.nsinies =
                                       (SELECT MAX(TO_NUMBER(stpf2.nsinies))
                                          FROM sin_tramita_prereserva_fnd stpf2,
                                               sin_siniestro s2
                                         WHERE stpf2.nsinies = s2.nsinies
                                           AND s2.sseguro = regs.sseguro)) LOOP
                  IF sinpre.ireserva IS NULL THEN
                     breserva := FALSE;
                     EXIT;
                  ELSE
                     vivalora_tot := vivalora_tot + sinpre.ireserva;
                  END IF;
               END LOOP;

               IF breserva
                  AND vivalora_tot <> 0 THEN
                  IF NVL(pac_parametros.f_parempresa_n(regs.cempres, 'MODULO_SINI'), 0) = 1 THEN
                     FOR reg IN (SELECT DISTINCT cgarant
                                            FROM sin_gar_causa_motivo sgcm,
                                                 sin_causa_motivo scm
                                           WHERE sgcm.scaumot = scm.scaumot
                                             AND scm.ccausin = regs.ccausin
                                             AND scm.cmotsin = regs.cmotsin
                                             AND sgcm.sproduc = regs.sproduc
                                             AND sgcm.cactivi = regs.cactivi) LOOP
                        v_cgarant := reg.cgarant;
                        num_err := pac_sin_formula.f_simu_calc_sin(regs.sseguro, NULL,
                                                                   regs.cactivi, reg.cgarant,
                                                                   regs.sproduc, pfvalmov,
                                                                   pfvalmov, regs.ccausin,
                                                                   regs.cmotsin, vivalora_tot,
                                                                   NULL, 1, vipenali);

                        IF num_err <> 0 THEN
                           vtexto := f_axis_literales(num_err, pcidioma_user);
                           num_err := f_proceslin(psproces,
                                                  f_axis_literales(180714, pcidioma_user)
                                                  || ' '
                                                  || f_axis_literales(104482, pcidioma_user)
                                                  || regs.sseguro || ','
                                                  || f_axis_literales(103242, pcidioma_user)
                                                  || vtexto,
                                                  num_err, vnprolin, 1);
                           algun_error := 1;
                           nerrores := nerrores + 1;
                        END IF;

                        res := pac_sin_formula.f_retorna_valores;
                        pac_sin_formula.p_borra_mensajes;
                        vipenali := res(1).ipenali;
                        vretenc := res(1).pretenc;

                        -- Actualizar el registro de SIN_TRAMITA_PRERESERVA:
                        UPDATE sin_tramita_prereserva
                           SET ipenali = vipenali,
                               pretenc = vretenc
                         WHERE nsinies = regs.nsinies;

                        -- Se inserta la reserva
                        num_err := pac_siniestros.f_ins_reserva(regs.nsinies, 0, 1, v_cgarant,
                                                                1, regs.fsinies, NULL,

-- BUG 18423 - 14/11/2011 - JMP - Pasamos moneda reserva NULL para que la coja en función
                               -- de si es multimoneda o no
                                                                NVL(vivalora_tot, 0)
                                                                - NVL(vipenali, 0),
                                                                NULL, vivalora_tot, vipenali,
                                                                NULL, NULL, NULL, NULL, NULL,
                                                                NULL, NULL, NULL, v_nmovres, 1);   --cmovres --Bug 31294/174788:NSS:22/05/2014

                        IF num_err <> 0 THEN
                           vtexto := f_axis_literales(num_err, pcidioma_user);
                           num_err := f_proceslin(psproces,
                                                  f_axis_literales(180714, pcidioma_user)
                                                  || ' '
                                                  || f_axis_literales(104482, pcidioma_user)
                                                  || regs.sseguro || ','
                                                  || f_axis_literales(103242, pcidioma_user)
                                                  || vtexto,
                                                  num_err, vnprolin, 1);
                           algun_error := 1;
                           nerrores := nerrores + 1;
                        END IF;
                     --vivalora_tot := vivalora_tot  - NVL(vipenali, 0);
                     END LOOP;
                  END IF;

                  p_tab_error(f_sysdate, f_user, 'PAC_MANTENIMIENTO_FONDOS_FINV', 1,
                              'nerrores=' || nerrores, 'PROVES RESCATS');

                  IF NVL(pac_parametros.f_parempresa_n(regs.cempres, 'MODULO_SINI'), 0) = 1 THEN
                     num_err := pac_sin_rescates.f_ins_destinatario(regs.nsinies, v_ntramit,
                                                                    regs.sseguro,
                                                                    regs.nriesgo, xppagdes, 1,
                                                                    1, NULL, NULL, NULL, NULL);

                     IF num_err <> 0 THEN
                        vtexto := f_axis_literales(num_err, pcidioma_user);
                        num_err := f_proceslin(psproces,
                                               f_axis_literales(180714, pcidioma_user) || ' '
                                               || f_axis_literales(104482, pcidioma_user)
                                               || regs.sseguro || ','
                                               || f_axis_literales(103242, pcidioma_user)
                                               || vtexto,
                                               num_err, vnprolin, 1);
                        algun_error := 1;
                        nerrores := nerrores + 1;
                     END IF;
                  END IF;

                  pk_cal_sini.borra_mensajes;

                  IF NVL(pac_parametros.f_parempresa_n(regs.cempres, 'MODULO_SINI'), 0) = 1 THEN
                     IF NVL(vivalora_tot, 0) > 0 THEN
                        -- Generamos los pagos
                        num_err := pac_sin_formula.f_genera_pago(regs.sseguro, regs.nriesgo,

                                                                 -- Bug 16219. FAL. 06/10/2010. Parametrizar que la generación del pago sea por garantia
                                                                 v_cgarant,
                                                                 -- Fi Bug 16219
                                                                 regs.sproduc, regs.cactivi,
                                                                 regs.nsinies, v_ntramit,
                                                                 regs.ccausin, regs.cmotsin,
                                                                 regs.fsinies, regs.fnotifi);

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;

                        num_err := pac_sin_formula.f_inserta_pago(regs.nsinies, v_ntramit, 1,
                                                                  v_cgarant, v_sidepag,
                                                                  v_ipago);

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;
                     END IF;
                  END IF;

                  num_err := f_traspaso_tmp_primas_cons(regs.sseguro, NULL, regs.nsinies);

                  IF num_err <> 0 THEN
                     vtexto := f_axis_literales(num_err, pcidioma_user);
                     num_err := f_proceslin(psproces,
                                            f_axis_literales(180714, pcidioma_user) || ' '
                                            || f_axis_literales(104482, pcidioma_user)
                                            || regs.sseguro || ','
                                            || f_axis_literales(103242, pcidioma_user)
                                            || vtexto,
                                            num_err, vnprolin, 1);
                     algun_error := 1;
                     nerrores := nerrores + 1;
                  END IF;
               END IF;
            END IF;
         END IF;
      END LOOP;

      -- Tratemiento del último seguro
      IF algun_error = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      RETURN 0;
   END f_genera_valsiniestros;

   FUNCTION p_insertar_vliquidativo(linea IN VARCHAR2, pcempres IN NUMBER, pfvalor IN DATE)
      RETURN NUMBER IS
      ccesta1        NUMBER(6);
      ffecha1        VARCHAR2(16);
      vliq1          NUMBER(15, 6);
      vvliqcmp       NUMBER(15, 6);
      vvliqvtashw    NUMBER(15, 6);
      vvliqcmpshw    NUMBER(15, 6);
      uncompra1      NUMBER(15, 6);
      iunicomp1      NUMBER(15, 6);
      unventa1       NUMBER(15, 6);
      iuniven1       NUMBER(15, 6);
      -- Bug 9031 - 16/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
      -- Añadimos validaciones
      vcvalorat      NUMBER;
      vcodfon        fondos.ccodfon%TYPE;

      FUNCTION splitt(
         pc$chaine IN VARCHAR2,
         pn$pos IN PLS_INTEGER,
         pc$sep IN VARCHAR2 DEFAULT ',')
         RETURN VARCHAR2 IS
         lc$chaine      VARCHAR2(32767) := pc$sep || pc$chaine;
         li$i           PLS_INTEGER;
         li$i2          PLS_INTEGER;
      BEGIN
         li$i := INSTR(lc$chaine, pc$sep, 1, pn$pos);

         IF li$i > 0 THEN
            li$i2 := INSTR(lc$chaine, pc$sep, 1, pn$pos + 1);

            IF li$i2 = 0 THEN
               li$i2 := LENGTH(lc$chaine) + 1;
            END IF;

            RETURN(SUBSTR(lc$chaine, li$i + 1, li$i2 - li$i - 1));
         ELSE
            RETURN NULL;
         END IF;
      END;
   BEGIN
      -- Bug 14160 - RSC - 16/04/2010 - CEM800 - Adaptar packages de productos de inversión al nuevo módulo de siniestros
      ccesta1 := TO_NUMBER(splitt(TRIM(linea), 1, ';'));
      ffecha1 := TO_DATE(splitt(TRIM(linea), 2, ';'), 'dd/mm/yyyy');
      vliq1 := TO_NUMBER(splitt(TRIM(linea), 3, ';'));
      uncompra1 := TO_NUMBER(splitt(TRIM(linea), 4, ';'));
      iunicomp1 := TO_NUMBER(splitt(TRIM(linea), 5, ';'));
      unventa1 := TO_NUMBER(splitt(TRIM(linea), 6, ';'));
      iuniven1 := TO_NUMBER(splitt(TRIM(linea), 7, ';'));
      vvliqcmp := TO_NUMBER(splitt(TRIM(linea), 8, ';'));
      vvliqvtashw := TO_NUMBER(splitt(TRIM(linea), 9, ';'));
      vvliqcmpshw := TO_NUMBER(splitt(TRIM(linea), 10, ';'));

      -- Fin Bug 14160

      /* Bug 9031 - 16/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
         Añadimos validaciones */
      BEGIN
         SELECT ccodfon
           INTO vcodfon
           FROM fondos
          WHERE ccodfon = ccesta1
            AND cempres = pcempres;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN(9001263);
      END;

      IF ffecha1 <> TRUNC(pfvalor) THEN
         -- Alguna fecha contenida en el fichero no coincide con la fecha valor
         -- que estamos tratando.
         RETURN(9001262);
      END IF;

      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'MODIFICAR_VALOR_UP'), 0) = 0 THEN
         SELECT COUNT(*)
           INTO vcvalorat
           FROM tabvalces
          WHERE ccesta = ccesta1
            AND fvalor = pfvalor;
      ELSE
         vcvalorat := 0;
      END IF;

      IF vcvalorat > 0 THEN
         RETURN(9001259);
      END IF;

      /* Fin Bug 9031 - 16/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
         Añadimos validaciones */
      BEGIN
         -- La introducimos en la tabla
         INSERT INTO tmp_vliquidativos2
                     (ccesta, ffecha, vliq, uncompra, iunicomp, unventa, iuniven,
                      vliqcmp, vliqvtashw, vliqcmpshw)
              VALUES (ccesta1, ffecha1, vliq1, uncompra1, iunicomp1, unventa1, iuniven1,
                      vvliqcmp, vvliqvtashw, vvliqcmpshw);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE tmp_vliquidativos2
               SET vliq = vliq1,
                   uncompra = uncompra1,
                   iunicomp = iunicomp1,
                   unventa = unventa1,
                   iuniven = iuniven1,
                   vliqcmp = vvliqcmp,
                   vliqvtashw = vvliqvtashw,
                   vliqcmpshw = vvliqcmpshw
             WHERE ccesta = ccesta1
               AND ffecha = ffecha1;
         WHEN OTHERS THEN
            NULL;
      END;

      RETURN(0);
   END p_insertar_vliquidativo;

   PROCEDURE p_actualizar_fondo(fvalora IN DATE, pfonoper2 IN fonoper2%ROWTYPE) IS
   BEGIN
      UPDATE fondos
         SET nparact = nparact + pfonoper2.nunicmp - pfonoper2.nunivnt,
             iuniact = pfonoper2.iuniact,
             iuniactcmp = pfonoper2.iuniactcmp,
             iuniactvtashw = pfonoper2.iuniactvtashw,
             iuniactcmpshw = pfonoper2.iuniactcmpshw,
             ivalact = (nparact + pfonoper2.nunicmp - pfonoper2.nunivnt) * pfonoper2.iuniact,
             nparasi = NVL(nparasi, 0) + pfonoper2.nunicmp - pfonoper2.nunivnt,
             fultval = fvalora
       WHERE ccodfon = pfonoper2.ccodfon;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MANTENIMIENTO_FONDOS_FINV.p_actualizar_fondo',
                     NULL, 'parametros: fvalora = ' || fvalora || 'FONOPER2%ROWTYPE', SQLERRM);
   END p_actualizar_fondo;

   FUNCTION f_precio_uniactual(codigo IN NUMBER, fecha IN DATE)
      RETURN NUMBER IS
      fecha2         VARCHAR2(8);
      preciohost     VARCHAR2(15);
      parteentera    VARCHAR2(7);
      partedecimal   VARCHAR2(6);
      preciopc       NUMBER;
      codigo2        VARCHAR2(3);
   BEGIN
      -- inicializamos variables
      preciopc := 0;

-- Calculamos el verdadero código
--  ------------------------------------------------------
/*
begin
    select to_char(ccesta) into codigo2
    from parpgcf
    where ccodfon = codigo
      and ffin is null;
 exception
    when others then
       p_tab_error(f_sysdate,  F_USER,'PAC_MANTENIMIENTO_FONDOS_FINV.f_precio_uniactual',NULL,
            'parametros: codigo = '||codigo||' fecha = '||fecha,SQLERRM);
end;
*/
------------------------------------------------------------------------

      -- Si el fondo es el '01' hacemos lo obtenemos a partir de una formula, sino, lo
      -- cogemos del fichero de texto
      --if to_number(codigo2)=1 then
      --    return F_PRECIO_FOND1ACTUAL(to_number(codigo2), fecha);
      --else

      -- buscamos el liquidativo correspondiente a ese código y esa fecha
      -- obtenemos el precio host
      BEGIN
         /*
         -- RSC 28/09/2007 ---------------------------------------------------
         select vliq into preciohost
         from tmp_vliquidativos2
         where ccesta = codigo2
          and ffecha = fecha;
         ---------------------------------------------------------------------
          */
         SELECT vliq
           INTO preciohost
           FROM tmp_vliquidativos2
          WHERE ccesta = codigo
            AND ffecha = fecha;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'PAC_MANTENIMIENTO_FONDOS_FINV.f_precio_uniactual',
                        NULL, 'parametros: codigo = ' || codigo || ' fecha = ' || fecha,
                        SQLERRM);
         /*
         select iuniact
         from tabvalces
         where ccesta = codigo2
           and trunc(fvalor) = (select max(t.fvalor)
                                from tabvalces t
                                where t.ccesta = codigo2);
         */
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_MANTENIMIENTO_FONDOS_FINV.f_precio_uniactual',
                        NULL, 'parametros: codigo = ' || codigo || ' fecha = ' || fecha,
                        SQLERRM);
      END;

      -- RSC 30072007 -----------------------------------------
      -- Pasamos el precio de formato host a formato pc
      --preciopc := cnvebcdic_ascii(preciohost, 6);
      --return preciopc;
      RETURN preciohost;
   --end if;
   END f_precio_uniactual;

   -- Bug 0018741 - JMF - 07/06/2011
   FUNCTION f_valorar(fvalora IN DATE, pcempres IN NUMBER, p_ccodfon IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      valor1         NUMBER;
      --VALORES DEL FONDO
      ffultval       VARCHAR2(10);
      --VALORES DE LAS OPERACIONES
      oiimpcmp       NUMBER;
      onunicmp       NUMBER;
      oiimpvnt       NUMBER;
      onunivnt       NUMBER;
      oiuniact       NUMBER;
      oiuniactcmp    NUMBER;
      oiuniactvtashw NUMBER;
      oiuniactcmpshw NUMBER;
      oivalact       NUMBER;
      operpend       NUMBER := 0;
      precio         NUMBER;
      precio_cmp     NUMBER;

      CURSOR cestas IS
         SELECT DISTINCT ccodfon
                    FROM fondos
                   WHERE ffin IS NULL
                     -- JGM - bug -- 10824 -- 31/07/09
                     AND cempres = NVL(pcempres, cempres)
                     --
                     AND ccodfon = NVL(p_ccodfon, ccodfon)
                     AND ccodfon IN(SELECT ccodfon
                                      FROM fonoper2
                                     WHERE TRUNC(fvalor) = TRUNC(fvalora)
                                       -- JGM - bug -- 10824 -- 31/07/09
                                       AND cempres = NVL(pcempres, cempres)
                                                                           --
                        );
   BEGIN
      --POR CADA UNA DE LAS CESTAS
      FOR vcesta IN cestas LOOP
         --VALORES NECESARIOS DE LA TABLA OPERACIONES
         BEGIN
            SELECT NVL(SUM(iimpcmp), 0), NVL(SUM(nunicmp), 0), NVL(SUM(iimpvnt), 0),
                   NVL(SUM(nunivnt), 0), NVL(SUM(iuniact), 0), SUM(iuniactcmp),
                   SUM(iuniactvtashw), SUM(iuniactcmpshw), NVL(SUM(ivalact), 0)
              INTO oiimpcmp, onunicmp, oiimpvnt,
                   onunivnt, oiuniact, oiuniactcmp,
                   oiuniactvtashw, oiuniactcmpshw, oivalact
              FROM fonoper2
             WHERE ccodfon = vcesta.ccodfon
               AND cestado = '0'
               -- JGM - bug -- 10824 -- 31/07/09
               AND cempres = NVL(pcempres, cempres)
               --
               AND TRUNC(fvalor) = TRUNC(fvalora);
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         --CUENTO LAS OPERACIONES PENDIENTES
         SELECT COUNT(*)
           INTO operpend
           FROM fonoper2
          WHERE ccesta = vcesta.ccodfon
            -- JGM - bug -- 10824 -- 31/07/09
            AND cempres = NVL(pcempres, cempres)
            --
            AND cestado = '0'
            AND TRUNC(fvalor) = TRUNC(fvalora);

         IF operpend <> 0 THEN
            -- Obtenemos el valor liquidativo
            BEGIN
               SELECT iuniact, iuniactcmp
                 INTO precio, precio_cmp
                 FROM fonoper2
                WHERE TRUNC(fvalor) = TRUNC(fvalora)
                  AND cempres = NVL(pcempres, cempres)
                  AND ccodfon = vcesta.ccodfon;
            EXCEPTION
               WHEN OTHERS THEN
                  precio := 0;
            END;

            --Patrimonio de participaciones del fondo
            BEGIN
               SELECT NVL(nparact, 0)
                 INTO valor1
                 FROM fondos
                WHERE ccodfon = vcesta.ccodfon
                  AND cempres = NVL(pcempres, cempres);
            EXCEPTION
               WHEN OTHERS THEN
                  valor1 := 0;
            END;

            IF precio = 0 THEN
               valor1 := valor1;
            ELSE
               -- => valor1 := valor1 + (OIIMPCMP-OIIMPVNT)/precio;
               valor1 := valor1 +(oivalact / NVL(precio_cmp, precio));
            END IF;

            -- El patrimonio en este caso seria : numero de
            -- participaciones acumuladas (valor1) * precio_unidad
            UPDATE fondos
               SET fultval = TRUNC(fvalora),
                   nparact = valor1,
                   ivalact =(valor1 * precio),
                   iuniact = precio,
                   iuniactcmp = oiuniactcmp,
                   iuniactcmpshw = oiuniactcmpshw,
                   iuniactvtashw = oiuniactvtashw
             WHERE ccodfon = vcesta.ccodfon
               AND cempres = NVL(pcempres, cempres);
         END IF;

         --ACTUALIZAR TABLA OPERACIONES
         UPDATE fonoper2
            SET cestado = '1'
          WHERE ccesta = vcesta.ccodfon
            AND cempres = NVL(pcempres, cempres)
            AND TRUNC(fvalor) = TRUNC(fvalora);

         --HISTORICO CESTAS, PASO POR PARAMETRO LA CESTA, LA FECHA Y LOS GASTOS
         p_historico_cesta(vcesta.ccodfon, TRUNC(fvalora));
      END LOOP;

      RETURN(0);
   END f_valorar;

   PROCEDURE p_proponer_valores(
      codfon IN NUMBER,
      fvalora IN DATE,
      iimpcmp IN OUT NUMBER,
      nunivnt IN OUT NUMBER) IS
   BEGIN
      BEGIN
         SELECT iunicomp, unventa
           INTO iimpcmp, nunivnt
           FROM tmp_vliquidativos2
          WHERE ccesta = codfon
            AND TRUNC(ffecha) = TRUNC(fvalora);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END;
   END p_proponer_valores;

   PROCEDURE p_historico_cesta(cesta IN NUMBER, fecha IN DATE) IS
      part           NUMBER;
      importe        NUMBER;
      valor          NUMBER;
      asig           NUMBER;
      gast           NUMBER;
      viuniactcmp    NUMBER;
      viuniactvtashw NUMBER;
      viuniactcmpshw NUMBER;
      vipatrimonio   fonoper2.ipatrimonio%TYPE;
   -- Bug 17243 - APD - 28/02/2011
   BEGIN
      SELECT nparact, iuniact, ivalact, nparasi, iuniactcmp, iuniactvtashw, iuniactcmpshw
        INTO part, importe, valor, asig, viuniactcmp, viuniactvtashw, viuniactcmpshw
        FROM fondos
       WHERE ccodfon = cesta;

      -- Bug 17243 - APD - 28/02/2011 - se busca el valor del patrimonio en fonoper2
      BEGIN
         SELECT ipatrimonio
           INTO vipatrimonio
           FROM fonoper2
          WHERE ccodfon = cesta
            AND fvalor = fecha;
      EXCEPTION
         WHEN OTHERS THEN
            vipatrimonio := NULL;
      END;

      -- Fin Bug 17243 - APD - 28/02/2011
      INSERT INTO tabvalces
                  (ccesta, fvalor, nparact, iuniact, ivalact, nparasi, ipatrimonio,
                   iuniactcmp, iuniactvtashw, iuniactcmpshw)
           VALUES (cesta, fecha, part, importe, valor, asig, vipatrimonio,
                   viuniactcmp, viuniactvtashw, viuniactcmpshw);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         -- Bug 17243 - APD - 28/02/2011 - se busca el valor del patrimonio en fonoper2
         BEGIN
            SELECT ipatrimonio
              INTO vipatrimonio
              FROM fonoper2
             WHERE ccodfon = cesta
               AND fvalor = fecha;
         EXCEPTION
            WHEN OTHERS THEN
               vipatrimonio := NULL;
         END;

         -- Fin Bug 17243 - APD - 28/02/2011
         UPDATE tabvalces
            SET ipatrimonio = vipatrimonio
          WHERE ccesta = cesta
            AND fvalor = fecha;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MANTENIMIENTO_FONDOS_FINV.p_historico_cesta', 1,
                     'parametros: cesta = ' || cesta || ' fecha = ' || fecha, SQLERRM);
   END p_historico_cesta;

   FUNCTION p_modifica_estadofondos(pcempres IN NUMBER, pfvalor IN DATE, pestado IN VARCHAR2)
      RETURN NUMBER IS
      CURSOR fondoscur IS
         SELECT ccodfon
           FROM fondos
          WHERE ffin IS NULL
            AND cempres = NVL(pcempres, cempres);
   BEGIN
      -- Valida
      IF pestado NOT IN('A', 'C') THEN
         RETURN(9001264);
      END IF;

      -- Bug 9031 - 13/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
      -- Abrimos / Cerramos los fondos vigentes de la empresa
      FOR regs IN fondoscur LOOP
         BEGIN
            INSERT INTO fonestado
                        (ccodfon, fvalora, cestado)
                 VALUES (regs.ccodfon, pfvalor, pestado);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE fonestado
                  SET cestado = pestado
                WHERE ccodfon = regs.ccodfon
                  AND fvalora = pfvalor;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user,
                           'PAC_MANTENIMIENTO_FONDOS_FINV.p_modifica_estadofondos', NULL,
                           'parametros: pcempres = ' || pcempres || ' fvalor = ' || pfvalor
                           || ' pestado = ' || pestado,
                           SQLERRM);
               -- Bug 9031 - 07/04/2009 - RSC - Análisis adaptación productos indexados
               RETURN 1;
         -- Fin Bug 9031
         END;
      END LOOP;

      -- Bug 9031 - 07/04/2009 - RSC - Análisis adaptación productos indexados
      -- Añadimos el COMMIT
      COMMIT;
      -- Fin Bug 9031
      RETURN 0;
   END p_modifica_estadofondos;

   /*
   PROCEDURE p_modifica_cerrarestadofondos (fvalor IN DATE) IS
       CURSOR fondoscur is
           SELECT ccodfon
           FROM FONDOS
           WHERE ctipfon <> 3;
   BEGIN

       FOR regs IN fondoscur LOOP
        BEGIN
               INSERT INTO FONESTADO (CCODFON,FVALORA,CESTADO) VALUES (regs.ccodfon,fvalor,'C');
           EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                   UPDATE FONESTADO
                 SET CESTADO = 'C'
                   WHERE CCODFON = regs.ccodfon
                      AND FVALORA = fvalor;
              WHEN OTHERS THEN
                   p_tab_error(f_sysdate,  F_USER,  'PAC_MANTENIMIENTO_FONDOS_FINV.p_modifica_cerrarestadofondos',NULL,
                   'parametros: fvalor = '||fvalor,SQLERRM);
           END;
     END LOOP;
   END;
   */
   FUNCTION f_cambio_aestado(pcempres IN NUMBER, fvalor IN DATE, paestado OUT VARCHAR2)
      RETURN VARCHAR2 IS
      hi_haa         NUMBER := 0;
      hi_hac         NUMBER := 0;

      CURSOR estados IS
         SELECT DISTINCT fe.cestado
                    FROM fonestado fe, fondos f
                   WHERE fe.fvalora = fvalor
                     AND fe.ccodfon = f.ccodfon
                     AND f.cempres = NVL(pcempres, f.cempres);
   BEGIN
      FOR regs IN estados LOOP
         IF regs.cestado = 'A' THEN
            hi_haa := hi_haa + 1;
         ELSIF regs.cestado = 'C' THEN
            hi_hac := hi_hac + 1;
         END IF;
      END LOOP;

      IF hi_haa > 0
         AND hi_hac > 0 THEN
         paestado := 'A';
         RETURN(f_axis_literales(100946));
      ELSIF hi_haa > 0 THEN
         paestado := 'C';
         RETURN(f_axis_literales(104961));
      ELSIF hi_hac > 0 THEN
         paestado := 'A';
         RETURN(f_axis_literales(100946));
      ELSE
         paestado := 'A';
         RETURN(f_axis_literales(100946));
      END IF;
   END f_cambio_aestado;

   FUNCTION f_get_estado(pcempres IN NUMBER, fvalor IN DATE)
      RETURN VARCHAR2 IS
      hi_haa         NUMBER := 0;
      hi_hac         NUMBER := 0;

      CURSOR estados IS
         SELECT DISTINCT fe.cestado
                    FROM fonestado fe, fondos f
                   WHERE fe.fvalora = fvalor
                     AND fe.ccodfon = f.ccodfon
                     AND f.cempres = NVL(pcempres, f.cempres);
   BEGIN
      FOR regs IN estados LOOP
         IF regs.cestado = 'A' THEN
            hi_haa := hi_haa + 1;
         ELSIF regs.cestado = 'C' THEN
            hi_hac := hi_hac + 1;
         END IF;
      END LOOP;

      IF hi_haa > 0
         AND hi_hac > 0 THEN
         RETURN(f_axis_literales(107742));
      ELSIF hi_haa > 0 THEN
         RETURN(f_axis_literales(107741));
      ELSIF hi_hac > 0 THEN
         RETURN(f_axis_literales(107742));
      ELSE
         RETURN(f_axis_literales(107742));
      END IF;
   END f_get_estado;

   FUNCTION f_carga_fichero_vliquidativo(
      pdirname VARCHAR2,
      pnom_fitxer VARCHAR2,
      pcempres IN NUMBER,
      pfvalor IN DATE)
      RETURN NUMBER IS
      in_file        UTL_FILE.file_type;
      linebuf        VARCHAR2(400);
      directory_name VARCHAR2(100);
      num_err        NUMBER;
   BEGIN
      IF pnom_fitxer IS NULL THEN
         RETURN(112223);
      END IF;

      directory_name := pdirname;
      in_file := UTL_FILE.fopen(directory_name, pnom_fitxer, 'r');

      IF UTL_FILE.is_open(in_file) THEN
         LOOP
            BEGIN
               UTL_FILE.get_line(in_file, linebuf);
            EXCEPTION
               WHEN OTHERS THEN
                  EXIT;
            END;

            num_err := pac_mantenimiento_fondos_finv.p_insertar_vliquidativo(linebuf, pcempres,
                                                                             pfvalor);

            IF num_err <> 0 THEN
               ROLLBACK;

               IF UTL_FILE.is_open(in_file) THEN
                  UTL_FILE.fclose(in_file);
               END IF;

               RETURN num_err;
            END IF;
         END LOOP;
      ELSE
         RETURN(102631);
      END IF;

      UTL_FILE.fclose(in_file);
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         ROLLBACK;

         IF UTL_FILE.is_open(in_file) THEN
            UTL_FILE.fclose(in_file);
         END IF;

         RETURN SQLCODE;
      WHEN OTHERS THEN
         ROLLBACK;

         IF UTL_FILE.is_open(in_file) THEN
            UTL_FILE.fclose(in_file);
         END IF;

         RETURN SQLCODE;
   END f_carga_fichero_vliquidativo;

   /***************************************************************************
     Esta función esta pensada para la consulta diaria on-line de las operaciones
     del dia (por eso busca los que nunidad IS NULL. Al consultar este formulario
     con fechas anteriores nos apareceran entradas i/o salidas a 0 (con la excepción
     de los siniestros / rescates). Es decir, esta función no devolverá valores
     historicos, si no mas bien devolverá valores del dia.
   ***************************************************************************/
   FUNCTION f_proponer_entradas_salidas(
      pfvalor IN DATE,
      pcesta IN NUMBER,
      pentradas OUT NUMBER,
      psalidas OUT NUMBER,
      pcompras OUT NUMBER,
      pentunidades OUT NUMBER,
      psalunidades OUT NUMBER,
      psaldocesta OUT NUMBER,
      pvliquid OUT NUMBER,
      pvliquidcmp OUT NUMBER,
      pvliquidvtashw OUT NUMBER,
      pvliquidcmpshw OUT NUMBER)
      RETURN NUMBER IS
      compras        NUMBER;
      ventas         NUMBER;
      compras_uni    NUMBER;
      ventas_uni     NUMBER;
      precio_uni     NUMBER;
      precio_uni_cmp NUMBER;
      precio_uni_vtashw NUMBER;
      precio_uni_cmpshw NUMBER;
      parven         NUMBER;
      nventas        NUMBER;
      proponervalores NUMBER;

      CURSOR cctaseguro(ccesta NUMBER) IS
         SELECT   --+ ORDERED USE_NL(s c) INDEX(s SEGUROS_CAGRPRO_NUK) INDEX(c CTASEG_FVMOV)
                  c.sseguro, c.cmovimi, NVL(c.imovimi, 0) imovimi, NVL(c.nunidad, 0) nunidad
             FROM seguros s, ctaseguro c
            WHERE s.sseguro = c.sseguro
              AND s.cagrpro IN(11, 21)   -- Bug - 13/05/2010 - RSC
              AND c.cesta = ccesta
              AND c.fvalmov >= TRUNC(pfvalor)
              AND c.fvalmov < TRUNC(pfvalor) + 1
              AND nunidad IS NULL   -- operaciones del dia no consolidadas
         ORDER BY c.sseguro;

      CURSOR cur_siniestros IS
         SELECT /*+ INDEX(si SINIES_NUK_1) */
                si.*
           FROM siniestros si, seguros s
          WHERE si.sseguro = s.sseguro
            AND s.cagrpro IN(11, 21)   -- Bug - 13/05/2010 - RSC
            AND TRUNC(si.fnotifi) = TRUNC(TO_DATE(pfvalor))
            AND si.ccausin IN(1, 3, 4, 5)
            AND si.cmotsin <> 4;

      num_err        NUMBER;
      tcesta_unidades NUMBER;
      tcesta_importe NUMBER;
      total_cestas   NUMBER;
      pdistrec       NUMBER;
      v_provision    NUMBER;
      gredanual      NUMBER;
      --
      vcontansin     NUMBER;
      vivalora       NUMBER;
      vfvalora       DATE;
      vsiniestro     NUMBER := 0;   -- Valoracion de siniestro o rescate
      vunidades      NUMBER;
      psalidas_anulacion NUMBER;
   BEGIN
      -- Inicializamos las columnas
      pentradas := 0;
      psalidas := 0;
      pcompras := 0;
      pentunidades := 0;
      psalunidades := 0;
      --COMPRAS QUE ESTAN EN LA TABLA CTASEGURO
      compras := 0;
      compras_uni := 0;
      ventas := 0;
      ventas_uni := 0;

      FOR valor IN cctaseguro(pcesta) LOOP
         IF valor.cmovimi IN(45, 46) THEN
            compras := compras + valor.imovimi;
         ELSIF valor.cmovimi IN(61) THEN
            -- Si hay un 61 --> Existe: 60,70,71,80 y 81 (los trato todos en este if)
            IF valor.imovimi = 0
               AND valor.nunidad = 0 THEN
               tcesta_unidades := 0;
               tcesta_importe := 0;
               total_cestas := 0;
               -- Existe una redistribución pendiente para el seguro
               num_err := pac_operativa_finv.f_cta_saldo_fondos_cesta(valor.sseguro, NULL,
                                                                      pcesta, tcesta_unidades,
                                                                      tcesta_importe,
                                                                      total_cestas);
               ventas := ventas + tcesta_importe;
                     -- este valor de la cesta es con último valor liquidativo
-----------------------------------------------------------------------------------------------
            ELSE
               ventas := ventas + valor.imovimi;
            END IF;
         ELSIF valor.cmovimi IN(71) THEN
            IF valor.imovimi <> 0
               OR valor.nunidad <> 0 THEN   -- ya consolidada
               compras := compras + valor.imovimi;
            ELSE
               tcesta_unidades := 0;
               tcesta_importe := 0;
               total_cestas := 0;
               num_err := pac_operativa_finv.f_cta_saldo_fondos_cesta(valor.sseguro, NULL,
                                                                      pcesta, tcesta_unidades,
                                                                      tcesta_importe,
                                                                      total_cestas);

               -- Obtenemos el % que le toca a la cesta en la nueva distribución -----------------------------
               -- (ya que hay un redistribución en este seguro)
               BEGIN
                  SELECT pdistrec
                    INTO pdistrec
                    FROM segdisin2
                   WHERE sseguro = valor.sseguro
                     AND ccesta = pcesta
                     AND ffin IS NULL
                     AND nmovimi = (SELECT MAX(nmovimi)
                                      FROM segdisin2
                                     WHERE sseguro = valor.sseguro
                                       AND ffin IS NULL);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     pdistrec := 0;
               END;

               -- total_cestas = total ¬ que representan las unidades de la cesta con ultimo valor liquidativo
               compras := compras +(total_cestas *(pdistrec / 100));
            -- por los movimientos 71
            END IF;
         ELSIF valor.cmovimi IN(81) THEN
            IF valor.imovimi <> 0
               OR valor.nunidad <> 0 THEN   -- ya consolidada
               ventas := ventas + valor.imovimi;
            ELSE
               -- Faltaria computar los gastos por redistribución los cuales son negativos (acumular en ventas)
               v_provision := pac_operativa_finv.ff_provmat(NULL, valor.sseguro,
                                                            TO_NUMBER(TO_CHAR(f_sysdate,
                                                                              'yyyymmdd')));
               num_err := pac_operativa_finv.f_gastos_redistribucion_anual(valor.sseguro,
                                                                           v_provision,
                                                                           gredanual);

               IF num_err <> 0 THEN
                  --RETURN num_err;
                  NULL;
               END IF;

               -- Obtenemos el % que le toca a la cesta en la nueva distribución -----------------------------
               -- (ya que hay un redistribución en este seguro)
               BEGIN
                  SELECT pdistrec
                    INTO pdistrec
                    FROM segdisin2
                   WHERE sseguro = valor.sseguro
                     AND ccesta = pcesta
                     AND ffin IS NULL
                     AND nmovimi = (SELECT MAX(nmovimi)
                                      FROM segdisin2
                                     WHERE sseguro = valor.sseguro
                                       AND ffin IS NULL);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     pdistrec := 0;
               END;

               --ventas := ventas + (gredanual*(pdistrec/100));
               compras := compras -(gredanual *(pdistrec / 100));
            -- los movimientos de gasto
            END IF;
         ELSIF valor.cmovimi NOT IN(1, 2, 4, 33, 34, 60, 70, 71, 80, 81, 31, 47, 91, 93, 94) THEN   -- seguro q no son 1,2,4,33,34,45, 46 o 61
            ventas := ventas + valor.imovimi;

            IF valor.imovimi = 0 THEN   -- --> no esta valorado a esta fecha
               ventas_uni := ventas_uni + NVL(valor.nunidad, 0);
            END IF;
         END IF;
      END LOOP;

      --  -------- Tratamiento siniestros (Entradas / Salidas)
      FOR regsini IN cur_siniestros LOOP
         -- Loop de siniestros --> Loop de pólizas con diferentes distribuciones
         SELECT COUNT(*)
           INTO vcontansin
           FROM valorasini
          WHERE nsinies = regsini.nsinies;

         -- ultima valoración disponible de la cesta
         BEGIN
            SELECT iuniact, iuniactcmp, iuniactvtashw, iuniactcmpshw
              INTO precio_uni, precio_uni_cmp, precio_uni_vtashw, precio_uni_cmpshw
              FROM tabvalces
             WHERE ccesta = pcesta
               AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                      FROM tabvalces
                                     WHERE ccesta = pcesta);
         EXCEPTION
            WHEN OTHERS THEN
               precio_uni := 1;
         END;

         IF vcontansin <> 0 THEN
            SELECT ivalora, fvalora
              INTO vivalora, vfvalora
              FROM valorasini
             WHERE nsinies = regsini.nsinies;

            -- Bug 10828 - RSC - 10/09/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
            IF regsini.ccausin = 5 THEN   -- Rescate parcial
               BEGIN
                  SELECT pdistrec
                    INTO pdistrec
                    FROM segdisin2
                   WHERE sseguro = regsini.sseguro
                     AND ccesta = pcesta
                     AND ffin IS NULL
                     AND nmovimi = (SELECT MAX(nmovimi)
                                      FROM segdisin2
                                     WHERE sseguro = regsini.sseguro
                                       AND ffin IS NULL);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     pdistrec := 0;
               END;

               ventas := ventas +(vivalora *(pdistrec / 100));
            ELSE
               -- Fin Bug 10828
                   -- Saldo de participaciones de la cesta en el seguro (provision de la cesta)
               SELECT NVL(SUM(nunidad), 0)
                 INTO vunidades
                 FROM ctaseguro
                WHERE sseguro = regsini.sseguro
                  AND cmovimi <> 0
                  AND cesta = pcesta
                  AND fvalmov <= vfvalora
                  AND((cestado <> '9')
                      OR(cestado = '9'
                         AND imovimi <> 0
                         AND imovimi IS NOT NULL));

               ventas_uni := ventas_uni + NVL(vunidades, 0);
            -- Bug 10828 - RSC - 10/09/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
            END IF;
         -- Fin Bug 10828
         ELSE
            -- Saldo de participaciones de la cesta en el seguro (provision de la cesta)
            SELECT NVL(SUM(nunidad), 0)
              INTO vunidades
              FROM ctaseguro
             WHERE sseguro = regsini.sseguro
               AND cmovimi <> 0
               AND cesta = pcesta
               AND fvalmov <= pfvalor
               AND((cestado <> '9')
                   OR(cestado = '9'
                      AND imovimi <> 0
                      AND imovimi IS NOT NULL));

            ventas_uni := ventas_uni + NVL(vunidades, 0);
         END IF;

         vsiniestro := vsiniestro + ABS(ventas_uni) * precio_uni;
      END LOOP;

----------------------------------------------------------------------

      -- ultima valoración disponible de la cesta
      BEGIN
         SELECT iuniact, iuniactcmp, iuniactvtashw, iuniactcmpshw
           INTO precio_uni, precio_uni_cmp, precio_uni_vtashw, precio_uni_cmpshw
           FROM tabvalces
          WHERE ccesta = pcesta
            AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                   FROM tabvalces
                                  WHERE ccesta = pcesta);
      EXCEPTION
         WHEN OTHERS THEN
            precio_uni := 1;
      END;

      -- Asignación a las variables de salida
      pentradas := compras;
      psalidas_anulacion := ff_entsal_anulaciones(pfvalor, pcesta);
      psalidas := ABS(ventas_uni) * precio_uni + ventas + psalidas_anulacion;
      --psalidas := abs(ventas_uni)*precio_uni + ventas;
      pcompras := pentradas - psalidas;
      pentunidades := pentradas / NVL(precio_uni_cmp, precio_uni);
      psalunidades := psalidas / precio_uni;

      BEGIN
         SELECT   --+ ORDERED USE_NL(s) INDEX(s SEGUROS_CAGRPRO_NUK)
                  SUM(NVL(c.nunidad, 0)) tnunidad
             INTO psaldocesta
             FROM seguros s, ctaseguro c
            WHERE s.sseguro = c.sseguro
              AND s.cagrpro IN(11, 21)   -- Bug - 13/05/2010 - RSC
              AND c.cesta = pcesta
              AND nunidad IS NOT NULL   -- consolidado
              AND TRUNC(c.fvalmov) <= TRUNC(pfvalor)
         ORDER BY c.sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            psaldocesta := 0;
      END;

      psaldocesta := psaldocesta -(vsiniestro / precio_uni);
      -- descontamos al saldo los importes de siniestros / rescates
      pvliquid := precio_uni;
      pvliquidcmp := precio_uni_cmp;
      pvliquidvtashw := precio_uni_vtashw;
      pvliquidcmpshw := precio_uni_cmpshw;
      RETURN(0);
   END f_proponer_entradas_salidas;

   /***************************************************************************

     Función para el cálculo de las entradas y salidas de una cesta consolidadas
     a fecha de la ultima fecha de asignación de participaciones anterior a la
     fecha de emisión pasada por parámetro.
   ***************************************************************************/
   FUNCTION f_entsal_consolidado(
      pfvalor IN DATE,
      pcesta IN NUMBER,
      pcramo IN ramos.cramo%TYPE,
      psproduc IN productos.sproduc%TYPE,
      pcagente IN seguros.cagente%TYPE,
      pentradas OUT NUMBER,
      psalidas OUT NUMBER,
      pcompras OUT NUMBER,
      pentunidades OUT NUMBER,
      psalunidades OUT NUMBER,
      psaldocesta OUT NUMBER,
      pvliquid OUT NUMBER)
      RETURN NUMBER IS
      precio_uni     NUMBER;

      CURSOR cctaseguro(xcesta NUMBER) IS
         SELECT   --+ ORDERED USE_NL(s c) INDEX(s SEGUROS_CAGRPRO_NUK) INDEX(c CTASEG_FVMOV)
                  c.sseguro, c.cmovimi, c.fvalmov, NVL(c.imovimi, 0) imovimi,
                  NVL(c.nunidad, 0) nunidad
             FROM seguros s, ctaseguro c
            WHERE s.sseguro = c.sseguro
              AND s.cagrpro IN(11, 21)   -- Bug - 13/05/2010 - RSC
              AND(s.sproduc = psproduc
                  OR psproduc IS NULL)
              AND(s.cramo = pcramo
                  OR pcramo IS NULL)
              AND(s.cagente = pcagente
                  OR pcagente IS NULL)
              AND c.cesta = xcesta
              AND c.nunidad IS NOT NULL   -- consolidados
              AND c.fvalmov >= TRUNC(pfvalor)
              AND c.fvalmov < TRUNC(pfvalor) + 1
         ORDER BY c.sseguro;
   BEGIN
      -- Inicializamos las columnas
      pentradas := 0;
      psalidas := 0;
      pcompras := 0;
      pentunidades := 0;
      psalunidades := 0;

      -- Si estan consolidados tenemos las participaciones en CTASEGURO
      FOR valor IN cctaseguro(pcesta) LOOP
         --IF valor.cmovimi NOT IN (94,93,91,87,97) THEN  -- Los rescates, siniestros
         IF valor.nunidad < 0 THEN
            psalidas := psalidas + valor.imovimi;
            psalunidades := psalunidades + ABS(valor.nunidad);
         ELSE
            pentradas := pentradas + valor.imovimi;
            pentunidades := pentunidades + valor.nunidad;
         END IF;
      --END IF;
      END LOOP;

/************************************************************************************************************/
--  Tras discutir cuando se deben ver reflejados los rescates como salidas
-- hemos concluido que hasta que no se han finalizado (pagado y finalizado), es decir hasta que no se graban
-- en CTASEGURO no se deben contabilizar como salidas consolidadas.
--
-- En la consulta on-line, alli todavia no estan los rescates contabilizados (finalizados), ya que en el dia (on-line)
-- todavia no se habrán valorado ni nada. En este caso sin embargo si se deben controlar para que la compañia venda
-- o compre en consequencia ese dia (función: f_proponer_entradas_salidas).
/************************************************************************************************************/

      -- Valor liquidativo de la cesta a la fecha
      BEGIN
         SELECT iuniact
           INTO precio_uni
           FROM tabvalces
          WHERE ccesta = pcesta
            AND TRUNC(fvalor) = TRUNC(pfvalor);
      EXCEPTION
         WHEN OTHERS THEN
            RETURN(180717);
      END;

      BEGIN
         SELECT   --+ ORDERED USE_NL(s) INDEX(s SEGUROS_CAGRPRO_NUK)
                  SUM(NVL(c.nunidad, 0)) tnunidad
             INTO psaldocesta
             FROM seguros s, ctaseguro c
            WHERE s.sseguro = c.sseguro
              AND s.cagrpro IN(11, 21)   -- Bug - 13/05/2010 - RSC
              AND c.cesta = pcesta
              AND(s.sproduc = psproduc
                  OR psproduc IS NULL)
              AND(s.cramo = pcramo
                  OR pcramo IS NULL)
              AND(s.cagente = pcagente
                  OR pcagente IS NULL)
              AND s.csituac = 0
              AND nunidad IS NOT NULL   -- consolidado
              AND TRUNC(c.fvalmov) <= TRUNC(pfvalor)
         ORDER BY c.sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN(180717);
      END;

      pvliquid := precio_uni;
      RETURN(0);
   END f_entsal_consolidado;

   ---------- RSC 17 / 01 / 2008 ---------------------------------------------

   /***************************************************************************

     Función para el cálculo de las entradas y salidas de una cesta consolidadas
     a fecha de la ultima fecha de asignación de participaciones anterior a la
     fecha de emisión pasada por parámetro.
   ***************************************************************************/
   FUNCTION f_entsal_consolidado_shw(
      pfvalor IN DATE,
      pcesta IN NUMBER,
      pcramo IN ramos.cramo%TYPE,
      psproduc IN productos.sproduc%TYPE,
      pcagente IN seguros.cagente%TYPE,
      pentradas OUT NUMBER,
      psalidas OUT NUMBER,
      pcompras OUT NUMBER,
      pentunidades OUT NUMBER,
      psalunidades OUT NUMBER,
      psaldocesta OUT NUMBER,
      pvliquid OUT NUMBER)
      RETURN NUMBER IS
      precio_uni     NUMBER;

      CURSOR cctaseguro(xcesta NUMBER) IS
         SELECT   --+ ORDERED USE_NL(s c) INDEX(s SEGUROS_CAGRPRO_NUK) INDEX(c CTASEG_FVMOV)
                  c.sseguro, c.cmovimi, c.fvalmov, NVL(c.imovimi, 0) imovimi,
                  NVL(c.nunidad, 0) nunidad
             FROM seguros s, ctaseguro_shadow c
            WHERE s.sseguro = c.sseguro
              AND s.cagrpro IN(11, 21)   -- Bug - 13/05/2010 - RSC
              AND(s.sproduc = psproduc
                  OR psproduc IS NULL)
              AND(s.cramo = pcramo
                  OR pcramo IS NULL)
              AND(s.cagente = pcagente
                  OR pcagente IS NULL)
              AND c.cesta = xcesta
              AND c.nunidad IS NOT NULL   -- consolidados
              AND c.fvalmov >= TRUNC(pfvalor)
              AND c.fvalmov < TRUNC(pfvalor) + 1
         ORDER BY c.sseguro;
   BEGIN
      -- Inicializamos las columnas
      pentradas := 0;
      psalidas := 0;
      pcompras := 0;
      pentunidades := 0;
      psalunidades := 0;

      -- Si estan consolidados tenemos las participaciones en CTASEGURO
      FOR valor IN cctaseguro(pcesta) LOOP
         --IF valor.cmovimi NOT IN (94,93,91,87,97) THEN  -- Los rescates, siniestros
         IF valor.nunidad < 0 THEN
            psalidas := psalidas + valor.imovimi;
            psalunidades := psalunidades + ABS(valor.nunidad);
         ELSE
            pentradas := pentradas + valor.imovimi;
            pentunidades := pentunidades + valor.nunidad;
         END IF;
      --END IF;
      END LOOP;

      BEGIN
         SELECT iuniactvtashw
           INTO precio_uni
           FROM tabvalces
          WHERE ccesta = pcesta
            AND TRUNC(fvalor) = TRUNC(pfvalor);
      EXCEPTION
         WHEN OTHERS THEN
            RETURN(180717);
      END;

      BEGIN
         SELECT   --+ ORDERED USE_NL(s) INDEX(s SEGUROS_CAGRPRO_NUK)
                  SUM(NVL(c.nunidad, 0)) tnunidad
             INTO psaldocesta
             FROM seguros s, ctaseguro_shadow c
            WHERE s.sseguro = c.sseguro
              AND s.cagrpro IN(11, 21)   -- Bug - 13/05/2010 - RSC
              AND c.cesta = pcesta
              AND(s.sproduc = psproduc
                  OR psproduc IS NULL)
              AND(s.cramo = pcramo
                  OR pcramo IS NULL)
              AND(s.cagente = pcagente
                  OR pcagente IS NULL)
              AND s.csituac = 0
              AND nunidad IS NOT NULL   -- consolidado
              AND TRUNC(c.fvalmov) <= TRUNC(pfvalor)
         ORDER BY c.sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN(180717);
      END;

      pvliquid := precio_uni;
      RETURN(0);
   END f_entsal_consolidado_shw;

   FUNCTION ff_entsal_anulaciones(pfefecto IN DATE, pcesta IN NUMBER)
      RETURN NUMBER IS
      CURSOR cctaseguro(ccesta NUMBER) IS
         SELECT   --+ ORDERED USE_NL(s c) INDEX(s SEGUROS_CAGRPRO_NUK) INDEX(c CTASEG_FVMOV)
                  c.sseguro, f_formatopol(s.npoliza, s.ncertif, 1) contrato, c.cmovimi,
                  NVL(c.imovimi, 0) imovimi, NVL(c.nunidad, 0) nunidad, t.iuniact
             FROM seguros s, ctaseguro c, tabvalces t
            WHERE s.sseguro = c.sseguro
              AND s.cagrpro IN(11, 21)   -- Bug - 13/05/2010 - RSC
              AND c.cesta = pcesta
              AND c.ffecmov >= TRUNC(pfefecto)
              AND c.ffecmov < TRUNC(pfefecto) + 1
              AND c.fvalmov < TRUNC(pfefecto)
              AND c.cmovimi = 58
              AND t.ccesta = c.cesta
              AND t.fvalor = c.fvalmov
         ORDER BY c.sseguro;

      psalidas       NUMBER;
      ventas_uni     NUMBER;
      precio_uni     NUMBER;
   BEGIN
      -- Inicializamos las columnas
      psalidas := 0;

      FOR valor IN cctaseguro(pcesta) LOOP
         -- Asignación a las variables de salida
         psalidas := psalidas + ABS(NVL(valor.nunidad, 0)) * valor.iuniact;
      END LOOP;

      RETURN(psalidas);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(NULL);
   END ff_entsal_anulaciones;

   FUNCTION f_proponer_ent_sal(
      pfvalor IN DATE,
      pcesta IN NUMBER,
      pentradas OUT NUMBER,
      pentradas_teo OUT NUMBER,
      psalidas OUT NUMBER,
      psalidas_teo OUT NUMBER,
      pentunidades OUT NUMBER,
      pentunidades_teo OUT NUMBER,
      psalunidades OUT NUMBER,
      psalunidades_teo OUT NUMBER,
      pcompras OUT NUMBER,
      pvliquid OUT NUMBER,
      pvliquidcmp OUT NUMBER,
      pvliquidvtashw OUT NUMBER,
      pvliquidcmpshw OUT NUMBER,
      pentrada_penali OUT NUMBER)
      RETURN NUMBER IS
      compras        NUMBER;
      ventas         NUMBER;
      compras_uni    NUMBER;
      ventas_uni     NUMBER;
      precio_uni     NUMBER;
      precio_uni_cmp NUMBER;
      precio_uni_vtashw NUMBER;
      precio_uni_cmpshw NUMBER;
      parven         NUMBER;
      nventas        NUMBER;
      proponervalores NUMBER;

      CURSOR cctaseguro(ccesta NUMBER) IS
         SELECT   --+ ORDERED USE_NL(s c) INDEX(s SEGUROS_CAGRPRO_NUK) INDEX(c CTASEG_FVMOV)
                  c.sseguro, c.nnumlin, c.cmovimi, NVL(c.imovimi, 0) imovimi,
                  NVL(c.nunidad, 0) nunidad, c.fvalmov
             FROM seguros s, ctaseguro c
            WHERE s.sseguro = c.sseguro
              AND s.cagrpro IN(11, 21)   -- Bug - 13/05/2010 - RSC
              AND c.cesta = ccesta
              AND c.fvalmov >= TRUNC(pfvalor)
              AND c.fvalmov < TRUNC(pfvalor) + 1
              AND nunidad IS NULL   -- operaciones del dia no consolidadas
              AND c.cmovimi NOT IN(91, 93, 94, 97)
         -- los siniestros los tratamos en el otro cursor
         UNION
         SELECT   --+ ORDERED USE_NL(s c) INDEX(s SEGUROS_CAGRPRO_NUK) INDEX(c CTASEG_FVMOV)
                  c.sseguro, c.nnumlin, c.cmovimi, NVL(c.imovimi, 0) imovimi,
                  NVL(c.nunidad, 0) nunidad, c.fvalmov
             FROM seguros s, ctaseguro c
            WHERE s.sseguro = c.sseguro
              AND s.cagrpro IN(11, 21)
              AND c.cesta = ccesta
              AND c.ffecmov >= TRUNC(pfvalor)
              AND c.ffecmov < TRUNC(pfvalor) + 1
              AND c.fvalmov < c.ffecmov
              -- Bug 15707 - 22/03/2011 - RSC
              -- También cogemos aquellos movimientos de anulación generados en el dia pero con fecha valor anterior
               -- (por la anulación de aportación). Son movimientos que aunque consolidados se deben mostrar en la sección de operaciones
               -- del dia para que la compañia tenga constancia del movimiento y actue vendiendo parti cipaciones en conseqüencia
              AND nunidad IS NULL
              AND c.cmovimi IN(51, 58, 10, 90)
         ORDER BY sseguro, nnumlin;

      -- Bug 15707 - APD - 25/02/2011 - Los siniestros que generan pagos de renta se tratan en el CURSOR ctaseguro.
      -- Para estar seguros de que no entran en el CURSOR cur_siniestros excluiremos del cursos los siniestros que
      -- generan renta (PRESTAREN).
      -- Se añade la condicion AND NOT EXISTS (SELECT 1 FROM prestaren p WHERE p.nsinies = si.nsinies)
      -- Ademas se debe añadir ccausin = 8
      CURSOR cur_siniestros IS
         SELECT /*+ INDEX(si SINIES_NUK_1) */
                si.sseguro, si.fsinies, TO_CHAR(si.nsinies) nsinies, si.ccausin, s.cempres
           FROM siniestros si, seguros s, segdisin2 se
          WHERE si.sseguro = s.sseguro
            AND s.cagrpro IN(11, 21)   -- Bug - 13/05/2010 - RSC
            AND si.ccausin IN(1, 3, 4, 5, 8)
            AND si.cmotsin <> 4
            --AND TRUNC(si.fnotifi) = TRUNC(pfvalor)
            --AND si.cestsin NOT IN(1, 2, 3)
            AND s.sseguro = se.sseguro
            AND se.nmovimi = (SELECT MAX(nmovimi)
                                FROM segdisin2
                               WHERE sseguro = s.sseguro)
            AND((si.cestsin NOT IN(1, 2, 3)
                 AND si.ccausin IN(1, 3, 4, 5)
                 AND TRUNC(si.fnotifi) = TRUNC(pfvalor))
                OR
                  -- Traspasos realizados a la fecha con fecha valor la del siniestro
                (  si.ccausin = 8
                   AND NOT EXISTS(SELECT 1
                                    FROM tabvalces
                                   WHERE ccesta = se.ccesta
                                     AND fvalor = TRUNC(si.fsinies))
                   AND TRUNC(si.fsinies) = TRUNC(pfvalor))
                OR
                  -- Traspasos realizados a la fecha con fecha valor anterior (valor liquidativo ya entrado)
                (  si.ccausin = 8
                   AND EXISTS(SELECT 1
                                FROM tabvalces
                               WHERE ccesta = se.ccesta
                                 AND fvalor = TRUNC(si.fsinies))
                   AND TRUNC(si.falta) = TRUNC(pfvalor)
                   AND TRUNC(si.fsinies) < TRUNC(pfvalor)))
            AND NOT EXISTS(SELECT 1
                             FROM prestaren p
                            WHERE p.nsinies = si.nsinies)
            AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 0
         UNION
         SELECT si.sseguro, si.fsinies, si.nsinies, si.ccausin, s.cempres
           FROM sin_siniestro si, seguros s, sin_movsiniestro sm, segdisin2 se
          WHERE si.sseguro = s.sseguro
            AND s.cagrpro IN(11, 21)
            AND(si.ccausin IN(1, 3, 4, 5, 8)
                OR(si.ccausin IN(2410, 2411, 2412, 2413, 2414, 2415, 2416, 2417, 2418, 2419,
                                 2420, 2421, 2422, 2423, 2424)
                   AND EXISTS(SELECT 1
                                FROM sin_tramita_reserva st
                               WHERE st.nsinies = si.nsinies
                                 AND st.ctipres = 1   -- jlb - 18423#c105054
                                 AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg,
                                                         s.ccolect, s.cactivi, st.cgarant,
                                                         'GAR_CONTRA_CTASEGURO'),
                                         0) = 1)))
            AND si.cmotsin <> 4
            AND si.nsinies = sm.nsinies
            AND s.sseguro = se.sseguro
            AND se.nmovimi = (SELECT MAX(nmovimi)
                                FROM segdisin2
                               WHERE sseguro = s.sseguro)
            AND sm.nmovsin = (SELECT MAX(nmovsin)
                                FROM sin_movsiniestro
                               WHERE nsinies = sm.nsinies)
            AND NOT EXISTS(SELECT 1
                             FROM prestaren p
                            WHERE p.nsinies = si.nsinies)
            --AND sm.cestsin NOT IN(1, 2, 3)
            AND((sm.cestsin NOT IN(1, 2, 3)
                 AND(si.ccausin IN(1, 3, 4, 5)
                     OR(si.ccausin IN(2410, 2411, 2412, 2413, 2414, 2415, 2416, 2417, 2418,
                                      2419, 2420, 2421, 2422, 2423, 2424)
                        AND EXISTS(SELECT 1
                                     FROM sin_tramita_reserva st
                                    WHERE st.nsinies = si.nsinies
                                      AND st.ctipres = 1
                                      -- jlb - 18423#c105054
                                      AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg,
                                                              s.ccolect, s.cactivi, st.cgarant,
                                                              'GAR_CONTRA_CTASEGURO'),
                                              0) = 1)))
                 AND TRUNC(si.fnotifi) = TRUNC(pfvalor))
                OR
                  -- Traspasos realizados a la fecha con fecha valor la del siniestro
                (  si.ccausin = 8
                   AND NOT EXISTS(SELECT 1
                                    FROM tabvalces
                                   WHERE ccesta = se.ccesta
                                     AND fvalor = TRUNC(si.fsinies))
                   AND TRUNC(si.fsinies) = TRUNC(pfvalor))
                OR
                  -- Traspasos realizados a la fecha con fecha valor anterior (valor liquidativo ya entrado)
                (  si.ccausin = 8
                   AND EXISTS(SELECT 1
                                FROM tabvalces
                               WHERE ccesta = se.ccesta
                                 AND fvalor = TRUNC(si.fsinies))
                   AND TRUNC(si.falta) = TRUNC(pfvalor)
                   AND TRUNC(si.fsinies) < TRUNC(pfvalor)))
            AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 1;

      -- Bug 20853 - RSC - 09/01/2012 - CRE - Errors ordres de compra i venda.
      CURSOR cur_siniestros_anul_rech IS
         SELECT /*+ INDEX(si SINIES_NUK_1) */
                si.sseguro, si.fsinies, TO_CHAR(si.nsinies) nsinies, si.ccausin, s.cempres,
                NULL nmovsin
           FROM siniestros si, seguros s, segdisin2 se
          WHERE si.sseguro = s.sseguro
            AND s.cagrpro IN(11, 21)
            AND si.ccausin IN(1, 3, 4, 5, 8)
            AND(si.cmotsin NOT IN(2, 4)
                OR(si.cmotsin = 2
                   AND si.ccausin = 8))
            AND s.sseguro = se.sseguro
            AND se.nmovimi = (SELECT MAX(nmovimi)
                                FROM segdisin2
                               WHERE sseguro = s.sseguro)
            AND si.cestsin IN(2, 3)
            AND TRUNC(si.festsin) = TRUNC(pfvalor)
            AND NOT EXISTS(SELECT 1
                             FROM prestaren p
                            WHERE p.nsinies = si.nsinies)
            AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 0
         UNION
         SELECT si.sseguro, si.fsinies, si.nsinies, si.ccausin, s.cempres, sm.nmovsin
           FROM sin_siniestro si, seguros s, sin_movsiniestro sm, segdisin2 se
          WHERE si.sseguro = s.sseguro
            AND s.cagrpro IN(11, 21)
            AND(si.ccausin IN(1, 3, 4, 5, 8)
                OR(si.ccausin IN(2410, 2411, 2412, 2413, 2414, 2415, 2416, 2417, 2418, 2419,
                                 2420, 2421, 2422, 2423, 2424)
                   AND EXISTS(SELECT 1
                                FROM sin_tramita_reserva st
                               WHERE st.nsinies = si.nsinies
                                 AND st.ctipres = 1   -- jlb - 18423#c105054
                                 AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg,
                                                         s.ccolect, s.cactivi, st.cgarant,
                                                         'GAR_CONTRA_CTASEGURO'),
                                         0) = 1)))
            AND(si.cmotsin NOT IN(2, 4)
                OR(si.cmotsin = 2
                   AND si.ccausin = 8))
            AND si.nsinies = sm.nsinies
            AND s.sseguro = se.sseguro
            AND se.nmovimi = (SELECT MAX(nmovimi)
                                FROM segdisin2
                               WHERE sseguro = s.sseguro)
            AND sm.nmovsin = (SELECT MAX(nmovsin)
                                FROM sin_movsiniestro
                               WHERE nsinies = sm.nsinies)
            AND NOT EXISTS(SELECT 1
                             FROM prestaren p
                            WHERE p.nsinies = si.nsinies)
            AND sm.cestsin IN(2, 3)
            AND TRUNC(sm.festsin) = TRUNC(pfvalor)
            AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 1;

      -- Fin Bug 20853
      num_err        NUMBER;
      tcesta_unidades NUMBER;
      tcesta_importe NUMBER;
      total_cestas   NUMBER;
      pdistrec       NUMBER;
      v_provision    NUMBER;
      gredanual      NUMBER;
      --
      vcontansin     NUMBER;
      vivalora       NUMBER;
      vfvalora       DATE;
      vsiniestro     NUMBER := 0;
      -- Valoracion de siniestro o rescate
      vunidades      NUMBER;
      psalidas_anulacion NUMBER;
      v_vliq_resc    NUMBER;
      -- Bug XXX - RSC - 25/11/2009 - Ajustes PPJ Dinámico / PLA Estudiant
      v_icaprisc     NUMBER;
      -- Fin Bug XXX

      -- Bug 20309 - RSC - 29/11/2011 - LCOL_T004-Parametrización Fondos
      v_sproduc      seguros.sproduc%TYPE;
      v_ipenali      sin_tramita_reserva.ipenali%TYPE;
      v_ppenali      NUMBER;
      -- Fin Bug 20309

      -- Bug 20853 - RSC - 09/01/2012 - CRE - Errors ordres de compra i venda.
      v_rendiment    NUMBER;
      v_unidades_rend NUMBER;
      v_movrech      NUMBER;
   -- Fin Bug 20853
   BEGIN
      -- Inicializamos las columnas
      pentradas := 0;
      pentradas_teo := 0;
      pentunidades := 0;
      pentunidades_teo := 0;
      psalidas := 0;
      psalidas_teo := 0;
      psalunidades := 0;
      psalunidades_teo := 0;
      -- Bug 20309 - RSC - 29/11/2011 - LCOL_T004-Parametrización Fondos
      pentrada_penali := 0;
      -- Fin bug 20309
      pcompras := 0;
      --COMPRAS QUE ESTAN EN LA TABLA CTASEGURO
      compras := 0;
      compras_uni := 0;
      ventas := 0;
      ventas_uni := 0;

      -- bug 0011678 el valor liquidativo más reciente igual o anterior a una fecha (mas fiable)
      BEGIN
         SELECT iuniact, iuniactcmp, iuniactvtashw, iuniactcmpshw
           INTO precio_uni, precio_uni_cmp, precio_uni_vtashw, precio_uni_cmpshw
           FROM tabvalces
          WHERE ccesta = pcesta
            AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                   FROM tabvalces
                                  WHERE ccesta = pcesta
                                    AND TRUNC(fvalor) <= TRUNC(pfvalor));
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 0;
      END;

      FOR valor IN cctaseguro(pcesta) LOOP
         -- Bug 15707 - APD - 25/02/2011 - Pueden llegar anulaciones de pago de prestación (90)
         -- Como es una anulación de pago se considera un entrada en la compañia
         IF valor.cmovimi IN(45, 90) THEN
            pentradas := pentradas + valor.imovimi;
            pentunidades_teo := pentunidades_teo
                                +(valor.imovimi / NVL(precio_uni_cmp, precio_uni));
         -- Bug 15707 - APD - 25/02/2011 - Pueden llegar pagos de renta (92)
         -- Como es un pago se considera una salida en la compañia
         ELSIF valor.cmovimi IN(58, 92) THEN
            psalidas := psalidas + valor.imovimi;
            psalunidades_teo := psalunidades_teo +(valor.imovimi / precio_uni);
         ELSIF valor.cmovimi IN(61) THEN
            -- Si hay un 61 --> Existe: 60,70,71,80 y 81 (los trato todos en este if)
            IF valor.imovimi = 0 THEN
               tcesta_unidades := 0;
               tcesta_importe := 0;
               total_cestas := 0;
               -- Existe una redistribución pendiente para el seguro
               num_err := pac_operativa_finv.f_cta_provision_cesta(valor.sseguro, NULL,
                                                                   pfvalor, pcesta,
                                                                   tcesta_unidades,
                                                                   tcesta_importe,
                                                                   total_cestas);
               -- Salida de participaciones reales. Saldo. (Valor real)
               psalunidades := psalunidades + tcesta_unidades;
               -- Salida en €. Saldo. (Valor teorico)
               psalidas_teo := psalidas_teo +(tcesta_unidades * precio_uni);
            ELSE
               psalunidades := psalunidades + valor.nunidad;
               psalidas := psalidas + valor.imovimi;
            END IF;
         ELSIF valor.cmovimi IN(71) THEN
            IF valor.imovimi <> 0 THEN   -- Consolidada
               pentradas := pentradas + valor.imovimi;
               pentunidades := pentunidades + valor.nunidad;
            ELSE
               -- Obtenemos la provisión a la fecha
               tcesta_unidades := 0;
               tcesta_importe := 0;
               total_cestas := 0;
               -- Existe una redistribución pendiente para el seguro
               num_err := pac_operativa_finv.f_cta_provision_cesta(valor.sseguro, NULL,
                                                                   pfvalor, pcesta,
                                                                   tcesta_unidades,
                                                                   tcesta_importe,
                                                                   total_cestas);

               -- Obtenemos el % que le toca a la cesta en la nueva distribución
               BEGIN
                  SELECT pdistrec
                    INTO pdistrec
                    FROM segdisin2
                   WHERE sseguro = valor.sseguro
                     AND ccesta = pcesta
                     AND ffin IS NULL
                     AND nmovimi = (SELECT MAX(nmovimi)
                                      FROM segdisin2
                                     WHERE sseguro = valor.sseguro
                                       AND ffin IS NULL);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     pdistrec := 0;
               END;

               pentradas_teo := pentradas_teo +(total_cestas *(pdistrec / 100));
               pentunidades_teo := pentunidades_teo
                                   +((total_cestas *(pdistrec / 100))
                                     / NVL(precio_uni_cmp, precio_uni));
            END IF;
         END IF;
      END LOOP;

      -- Tratamiento siniestros (Entradas / Salidas)
      FOR regsini IN cur_siniestros LOOP
         -- Bug 14072 - RSC - 09/04/2010 - LBCOL - Parametrización del producto de Vida Ahorro
         vcontansin := 0;

         -- Bug 15707 - APD - 14/03/2011 - Tratar el ccausin = 8 como si fuera un rescate parcial
         IF regsini.ccausin IN(5, 8) THEN
            IF NVL(pac_parametros.f_parempresa_n(regsini.cempres, 'MODULO_SINI'), 0) = 0 THEN
               SELECT COUNT(*)
                 INTO vcontansin
                 FROM valorasini
                WHERE nsinies = regsini.nsinies;
            ELSE
-- Bug 17630 - SRA - 10/02/2011: añadimos alias de la tabla en la join
               SELECT COUNT(*)
                 INTO vcontansin
                 FROM sin_tramita_reserva v0
                WHERE v0.nsinies = regsini.nsinies
                  AND v0.ctipres = 1   -- jlb - 18423#c105054
                  AND v0.nmovres = (SELECT MAX(v1.nmovres)
                                      FROM sin_tramita_reserva v1
                                     WHERE v1.nsinies = v0.nsinies
                                       AND v1.ctipres = v0.ctipres);
-- Fin Bug 17630 - SRA - 10/02/2011
            END IF;
         END IF;

         -- Bug 20309 - RSC - 29/11/2011 - LCOL_T004-Parametrización Fondos
         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = regsini.sseguro;

         -- Fin Bug 20309

         -- Fin Bug 14072
         IF vcontansin <> 0 THEN
            -- Bug 14072 - RSC - 09/04/2010 - LBCOL - Parametrización del producto de Vida Ahorro
            IF NVL(pac_parametros.f_parempresa_n(regsini.cempres, 'MODULO_SINI'), 0) = 0 THEN
               SELECT ivalora, fvalora, icaprisc, ipenali
                 INTO vivalora, vfvalora, v_icaprisc, v_ipenali
                 FROM valorasini
                WHERE nsinies = regsini.nsinies;
            ELSE
-- Bug 17630 - SRA - 10/02/2011: añadimos alias de la tabla en la join
               SELECT ireserva, fmovres, icaprie, ipenali
                 INTO vivalora, vfvalora, v_icaprisc, v_ipenali
                 FROM sin_tramita_reserva v0
                WHERE v0.nsinies = regsini.nsinies
                  AND v0.ctipres = 1   -- jlb - 18423#c105054
                  AND v0.nmovres = (SELECT MAX(v1.nmovres)
                                      FROM sin_tramita_reserva v1
                                     WHERE v1.nsinies = v0.nsinies
                                       AND v1.ctipres = v0.ctipres);
-- Fin Bug 17630 - SRA - 10/02/2011
            END IF;

            -- Fin Bug 14072

            --PRECIO UNIDAD
            -- bug 0011678 proteger la 'división by 0'
            BEGIN
               SELECT NVL(iuniact, 0)
                 INTO v_vliq_resc
                 FROM tabvalces
                WHERE ccesta = pcesta
                  AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                         FROM tabvalces
                                        WHERE ccesta = pcesta
                                          AND TRUNC(fvalor) <= TRUNC(vfvalora));
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  -- bug 0011678 proteger la 'división by 0'
                  v_vliq_resc := 0;
            END;

            -- Obtenemos el % que le toca a la cesta en la nueva distribución
            BEGIN
               SELECT pdistrec
                 INTO pdistrec
                 FROM segdisin2
                WHERE sseguro = regsini.sseguro
                  AND ccesta = pcesta
                  AND ffin IS NULL
                  AND nmovimi = (SELECT MAX(nmovimi)
                                   FROM segdisin2
                                  WHERE sseguro = regsini.sseguro
                                    AND ffin IS NULL);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  pdistrec := 0;
            END;

            -- Bug 20309 - RSC - 29/11/2011 - LCOL_T004-Parametrización Fondos
            IF NVL(f_parproductos_v(v_sproduc, 'PENALI_EN_SALIDAS'), 1) = 1 THEN
               -- Bug XXX - RSC - 25/11/2009 - Ajustes PPJ Dinámico / PLA Estudiant
               --psalidas := psalidas +(vivalora *(pdistrec / 100));
               psalidas := psalidas +(v_icaprisc *(pdistrec / 100));
            -- Fin Bug XXX
            ELSE
               psalidas := psalidas +((v_icaprisc - v_ipenali) *(pdistrec / 100));
               pentrada_penali := pentrada_penali + v_ipenali *(pdistrec / 100);
            END IF;

            -- Fin Bug 20309

            -- bug 0011678 proteger la 'división by 0'
            IF v_vliq_resc > 0 THEN
               -- Bug 20309 - RSC - 29/11/2011 - LCOL_T004-Parametrización Fondos
               IF NVL(f_parproductos_v(v_sproduc, 'PENALI_EN_SALIDAS'), 1) = 1 THEN
                  -- Bug XXX - RSC - 25/11/2009 - Ajustes PPJ Dinámico / PLA Estudiant
                  --psalunidades_teo := psalunidades_teo
                  --                    +((vivalora *(pdistrec / 100)) / v_vliq_resc);
                  psalunidades_teo := psalunidades_teo
                                      +((v_icaprisc *(pdistrec / 100)) / v_vliq_resc);
               -- Fin Bug XXX
               ELSE
                  psalunidades_teo := psalunidades_teo
                                      +(((v_icaprisc - v_ipenali) *(pdistrec / 100))
                                        / v_vliq_resc);
                  pentunidades_teo := pentunidades_teo
                                      +(v_ipenali *(pdistrec / 100) / v_vliq_resc);
               END IF;
            END IF;
         -- Fin Bug 10828
         ELSE
            -- Obtenemos el % que le toca a la cesta en la nueva distribución
            BEGIN
               SELECT pdistrec
                 INTO pdistrec
                 FROM segdisin2
                WHERE sseguro = regsini.sseguro
                  AND ccesta = pcesta
                  AND ffin IS NULL
                  AND nmovimi = (SELECT MAX(nmovimi)
                                   FROM segdisin2
                                  WHERE sseguro = regsini.sseguro
                                    AND ffin IS NULL);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  pdistrec := 0;
            END;

            BEGIN
               SELECT NVL(iuniact, 0)
                 INTO v_vliq_resc
                 FROM tabvalces
                WHERE ccesta = pcesta
                  AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                         FROM tabvalces
                                        WHERE ccesta = pcesta
                                          AND TRUNC(fvalor) <= TRUNC(regsini.fsinies));
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  -- bug 0011678 proteger la 'división by 0'
                  v_vliq_resc := 0;
            END;

            -- Saldo de participaciones de la cesta en el seguro (provision de la cesta)
            SELECT NVL(SUM(nunidad), 0)
              INTO vunidades
              FROM ctaseguro
             WHERE sseguro = regsini.sseguro
               AND cmovimi <> 0
               AND cesta = pcesta
               AND fvalmov <= regsini.fsinies
               AND((cestado <> '9')
                   OR(cestado = '9'
                      AND imovimi <> 0
                      AND imovimi IS NOT NULL));

            IF NVL(f_parproductos_v(v_sproduc, 'PENALI_EN_SALIDAS'), 1) = 1 THEN
               -- Salida de participaciones reales. Saldo. (Valor real)
               psalunidades := psalunidades + vunidades;
            ELSE
               v_ppenali :=
                  calc_rescates.fporcenpenali(NULL, regsini.sseguro,
                                              TO_NUMBER(TO_CHAR(regsini.fsinies, 'YYYYMMDD')),
                                              4)
                  / 100;

               IF NVL(f_parproductos_v(v_sproduc, 'PENALIZA_RENDIMIENTO'), 0) = 1 THEN
                  v_rendiment :=
                     pac_operativa_finv.ffrendiment(NULL, regsini.sseguro,
                                                    TO_NUMBER(TO_CHAR(regsini.fsinies,
                                                                      'YYYYMMDD')));

                  IF v_vliq_resc > 0 THEN
                     v_unidades_rend := v_rendiment / v_vliq_resc;
                  END IF;

                  psalunidades := psalunidades +(vunidades -(v_unidades_rend * v_ppenali));
                  pentunidades := pentunidades +(v_unidades_rend * v_ppenali);
                  -- Unidades consolidadas de entrada
                  pentradas_teo := pentradas_teo
                                   +((v_unidades_rend * v_ppenali) *(pdistrec / 100));
               -- Importe redistribuciones (teorico)
               ELSE
                  psalunidades := psalunidades +(vunidades -(vunidades * v_ppenali));
                  pentunidades := pentunidades +(vunidades * v_ppenali);
                  -- Unidades consolidadas de entrada
                  pentradas_teo := pentradas_teo +((vunidades * v_ppenali) *(pdistrec / 100));
               -- Importe redistribuciones (teorico)
               END IF;
            END IF;
         END IF;
      END LOOP;

      -- Bug 20853 - RSC - 09/01/2012 - CRE - Errors ordres de compra i venda.
      FOR regsini IN cur_siniestros_anul_rech LOOP
         vcontansin := 0;

         IF regsini.ccausin IN(5, 8) THEN
            IF NVL(pac_parametros.f_parempresa_n(regsini.cempres, 'MODULO_SINI'), 0) = 0 THEN
               SELECT COUNT(*)
                 INTO vcontansin
                 FROM valorasini
                WHERE nsinies = regsini.nsinies;
            ELSE
               SELECT COUNT(*)
                 INTO vcontansin
                 FROM sin_tramita_reserva v0
                WHERE v0.nsinies = regsini.nsinies
                  AND v0.ctipres = 1   -- jlb - 18423#c105054
                  AND v0.nmovres = (SELECT MAX(v1.nmovres)
                                      FROM sin_tramita_reserva v1
                                     WHERE v1.nsinies = v0.nsinies
                                       AND v1.ctipres = v0.ctipres);
            END IF;
         END IF;

         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = regsini.sseguro;

         IF vcontansin <> 0 THEN
            IF NVL(pac_parametros.f_parempresa_n(regsini.cempres, 'MODULO_SINI'), 0) = 0 THEN
               SELECT ivalora, fvalora, icaprisc, ipenali
                 INTO vivalora, vfvalora, v_icaprisc, v_ipenali
                 FROM valorasini
                WHERE nsinies = regsini.nsinies;
            ELSE
               SELECT ireserva, fmovres, icaprie, ipenali
                 INTO vivalora, vfvalora, v_icaprisc, v_ipenali
                 FROM sin_tramita_reserva v0
                WHERE v0.nsinies = regsini.nsinies
                  AND v0.ctipres = 1   -- jlb - 18423#c105054
                  AND v0.nmovres = (SELECT MAX(v1.nmovres)
                                      FROM sin_tramita_reserva v1
                                     WHERE v1.nsinies = v0.nsinies
                                       AND v1.ctipres = v0.ctipres);
            END IF;

            --PRECIO UNIDAD
            BEGIN
               SELECT NVL(iuniact, 0)
                 INTO v_vliq_resc
                 FROM tabvalces
                WHERE ccesta = pcesta
                  AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                         FROM tabvalces
                                        WHERE ccesta = pcesta
                                          AND TRUNC(fvalor) <= TRUNC(vfvalora));
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_vliq_resc := 0;
            END;

            -- Obtenemos el % que le toca a la cesta en la nueva distribución
            BEGIN
               SELECT pdistrec
                 INTO pdistrec
                 FROM segdisin2
                WHERE sseguro = regsini.sseguro
                  AND ccesta = pcesta
                  AND ffin IS NULL
                  AND nmovimi = (SELECT MAX(nmovimi)
                                   FROM segdisin2
                                  WHERE sseguro = regsini.sseguro
                                    AND ffin IS NULL);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  pdistrec := 0;
            END;

            SELECT COUNT(*)
              INTO v_movrech
              FROM sin_movsiniestro
             WHERE nsinies = regsini.nsinies
               AND cestsin = 0
               AND TRUNC(festsin) = TRUNC(pfvalor)
               AND nmovsin = regsini.nmovsin - 1;

            IF NVL(f_parproductos_v(v_sproduc, 'PENALI_EN_SALIDAS'), 1) = 1 THEN
               pentradas := pentradas +(v_icaprisc *(pdistrec / 100));
            ELSE
               pentradas := pentradas +((v_icaprisc - v_ipenali) *(pdistrec / 100));
               psalidas := psalidas + v_ipenali *(pdistrec / 100);
            END IF;

            IF v_movrech > 0 THEN
               IF NVL(f_parproductos_v(v_sproduc, 'PENALI_EN_SALIDAS'), 1) = 1 THEN
                  psalidas := psalidas +(v_icaprisc *(pdistrec / 100));
               ELSE
                  psalidas := psalidas +((v_icaprisc - v_ipenali) *(pdistrec / 100));
                  pentrada_penali := pentrada_penali + v_ipenali *(pdistrec / 100);
               END IF;
            END IF;

            IF v_vliq_resc > 0 THEN
               IF NVL(f_parproductos_v(v_sproduc, 'PENALI_EN_SALIDAS'), 1) = 1 THEN
                  pentunidades_teo := pentunidades_teo
                                      +((v_icaprisc *(pdistrec / 100)) / v_vliq_resc);
               ELSE
                  pentunidades_teo := pentunidades_teo
                                      +(((v_icaprisc - v_ipenali) *(pdistrec / 100))
                                        / v_vliq_resc);
                  psalunidades_teo := psalunidades_teo
                                      +(v_ipenali *(pdistrec / 100) / v_vliq_resc);
               END IF;

               IF v_movrech > 0 THEN
                  IF NVL(f_parproductos_v(v_sproduc, 'PENALI_EN_SALIDAS'), 1) = 1 THEN
                     psalunidades_teo := psalunidades_teo
                                         +((v_icaprisc *(pdistrec / 100)) / v_vliq_resc);
                  ELSE
                     psalunidades_teo := psalunidades_teo
                                         +(((v_icaprisc - v_ipenali) *(pdistrec / 100))
                                           / v_vliq_resc);
                     pentunidades_teo := pentunidades_teo
                                         +(v_ipenali *(pdistrec / 100) / v_vliq_resc);
                  END IF;
               END IF;
            END IF;
         ELSE
            -- Obtenemos el % que le toca a la cesta en la nueva distribución
            BEGIN
               SELECT pdistrec
                 INTO pdistrec
                 FROM segdisin2
                WHERE sseguro = regsini.sseguro
                  AND ccesta = pcesta
                  AND ffin IS NULL
                  AND nmovimi = (SELECT MAX(nmovimi)
                                   FROM segdisin2
                                  WHERE sseguro = regsini.sseguro
                                    AND ffin IS NULL);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  pdistrec := 0;
            END;

            BEGIN
               SELECT NVL(iuniact, 0)
                 INTO v_vliq_resc
                 FROM tabvalces
                WHERE ccesta = pcesta
                  AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                         FROM tabvalces
                                        WHERE ccesta = pcesta
                                          AND TRUNC(fvalor) <= TRUNC(regsini.fsinies));
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  -- bug 0011678 proteger la 'división by 0'
                  v_vliq_resc := 0;
            END;

            -- Saldo de participaciones de la cesta en el seguro (provision de la cesta)
            SELECT NVL(SUM(nunidad), 0)
              INTO vunidades
              FROM ctaseguro
             WHERE sseguro = regsini.sseguro
               AND cmovimi <> 0
               AND cesta = pcesta
               AND fvalmov <= regsini.fsinies
               AND((cestado <> '9')
                   OR(cestado = '9'
                      AND imovimi <> 0
                      AND imovimi IS NOT NULL));

            SELECT COUNT(*)
              INTO v_movrech
              FROM sin_movsiniestro
             WHERE nsinies = regsini.nsinies
               AND cestsin = 0
               AND TRUNC(festsin) = TRUNC(pfvalor)
               AND nmovsin = regsini.nmovsin - 1;

            IF NVL(f_parproductos_v(v_sproduc, 'PENALI_EN_SALIDAS'), 1) = 1 THEN
               -- Salida de participaciones reales. Saldo. (Valor real)
               pentunidades := pentunidades + vunidades;

               IF v_movrech > 0 THEN
                  psalunidades := psalunidades + vunidades;
               END IF;
            ELSE
               v_ppenali :=
                  calc_rescates.fporcenpenali(NULL, regsini.sseguro,
                                              TO_NUMBER(TO_CHAR(regsini.fsinies, 'YYYYMMDD')),
                                              4)
                  / 100;

               IF NVL(f_parproductos_v(v_sproduc, 'PENALIZA_RENDIMIENTO'), 0) = 1 THEN
                  v_rendiment :=
                     pac_operativa_finv.ffrendiment(NULL, regsini.sseguro,
                                                    TO_NUMBER(TO_CHAR(regsini.fsinies,
                                                                      'YYYYMMDD')));

                  IF v_vliq_resc > 0 THEN
                     v_unidades_rend := v_rendiment / v_vliq_resc;
                  END IF;

                  pentunidades := pentunidades +(vunidades -(v_unidades_rend * v_ppenali));
                  psalunidades := psalunidades +(v_unidades_rend * v_ppenali);
                  -- Unidades consolidadas de entrada
                  psalunidades_teo := psalunidades_teo
                                      +((v_unidades_rend * v_ppenali) *(pdistrec / 100));

                  -- Importe redistribuciones (teorico)
                  IF v_movrech > 0 THEN
                     psalunidades := psalunidades +(vunidades -(v_unidades_rend * v_ppenali));
                     pentunidades := pentunidades +(v_unidades_rend * v_ppenali);
                     -- Unidades consolidadas de entrada
                     pentradas_teo := pentradas_teo
                                      +((v_unidades_rend * v_ppenali) *(pdistrec / 100));
                  -- Importe redistribuciones (teorico)
                  END IF;
               ELSE
                  pentunidades := pentunidades +(vunidades -(vunidades * v_ppenali));
                  psalunidades := psalunidades +(vunidades * v_ppenali);
                  -- Unidades consolidadas de entrada
                  psalunidades_teo := psalunidades_teo
                                      +((vunidades * v_ppenali) *(pdistrec / 100));

                  -- Importe redistribuciones (teorico)
                  IF v_movrech > 0 THEN
                     psalunidades := psalunidades +(vunidades -(vunidades * v_ppenali));
                     pentunidades := pentunidades +(vunidades * v_ppenali);
                     -- Unidades consolidadas de entrada
                     pentradas_teo := pentradas_teo
                                      +((vunidades * v_ppenali) *(pdistrec / 100));
                  -- Importe redistribuciones (teorico)
                  END IF;
               END IF;
            END IF;
         END IF;
      END LOOP;

      -- Fin Bug 20853

      --
      pcompras := (pentunidades_teo) -(psalunidades + psalunidades_teo);
      pvliquid := precio_uni;
      pvliquidcmp := precio_uni_cmp;
      pvliquidvtashw := precio_uni_vtashw;
      pvliquidcmpshw := precio_uni_cmpshw;
      RETURN(0);
   END f_proponer_ent_sal;

   FUNCTION f_get_estado_fondo(
      pcempres IN NUMBER,
      fvalor IN DATE,
      pcesta IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      hi_haa         NUMBER := 0;
      hi_hac         NUMBER := 0;

      CURSOR estados IS
         SELECT DISTINCT fe.cestado
                    FROM fonestado fe, fondos f
                   WHERE fe.fvalora = fvalor
                     AND fe.ccodfon = f.ccodfon
                     AND fe.ccodfon = NVL(pcesta, fe.ccodfon)
                     AND f.cempres = NVL(pcempres, f.cempres);
   BEGIN
      FOR regs IN estados LOOP
         IF regs.cestado = 'A' THEN
            hi_haa := hi_haa + 1;
         ELSIF regs.cestado = 'C' THEN
            hi_hac := hi_hac + 1;
         END IF;
      END LOOP;

      IF hi_haa > 0
         AND hi_hac > 0 THEN
         RETURN(107742);
      ELSIF hi_haa > 0 THEN
         RETURN(107741);
      ELSIF hi_hac > 0 THEN
         RETURN(107742);
      ELSE
         -- Mantis 12275.NMM.14/12/2009.
         --RETURN(107742);
         RETURN(107741);
      END IF;
   END f_get_estado_fondo;

   -- Bug 0018741 - JMF - 07/06/2011
   /*************************************************************************
      FUNCTION f_carga_valliqdiario
      Carga de valor liquidativo diario (Se llama desde un job).
      p_cesta in : Codigo cesta opcional (si es vacio seran todas)
      p_fecha in : Fecha opcional (si es vacio sera la del dia)
      return     : 0 OK - codigo error
   *************************************************************************/
   FUNCTION f_carga_valliqdiario(p_cesta IN NUMBER DEFAULT NULL, p_fecha IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      v_obj          VARCHAR2(100) := 'PAC_MANTENIMIENTO_FONDOS_FINV.f_carga_valliqdiario';
      v_par          VARCHAR2(100)
                                 := 'c=' || p_cesta || ' f=' || TO_CHAR(p_fecha, 'dd-mm-yyyy');
      v_pas          NUMBER;
      n_diadef       NUMBER(2) := 01;
      v_emp          empresas.cempres%TYPE := f_empres;
      d_hoy          DATE := f_sysdate;
      d_ini          DATE;
      d_fin          DATE := NVL(p_fecha, d_hoy);

      CURSOR c1 IS
         SELECT a.sproduc, a.ccodpla, b.ccodfon
           FROM proplapen a, planpensiones b, productos c, codiram d
          WHERE a.ccodpla = b.ccodpla
            AND NVL(f_parproductos_v(a.sproduc, 'VAL_LIQUIDA_FIJO'), 0) = 0
            AND NVL(b.fbajare, d_fin + 1) > d_fin
            AND b.ccodfon = NVL(p_cesta, b.ccodfon)
            AND c.sproduc = a.sproduc
            AND d.cramo = c.cramo
            AND d.cempres = v_emp;

      n_diavalman    NUMBER(2);   -- Dia valoracion manual
      d_maxvalman    DATE;
      n_err          NUMBER;
      n_idioma       idiomas.cidioma%TYPE;
      n_sproces      procesoscab.sproces%TYPE;
      n_toterror     NUMBER;
      n_prolin       NUMBER;
   BEGIN
      v_pas := 1000;

      SELECT MAX(cidioma)
        INTO n_idioma
        FROM usuarios
       WHERE cusuari = f_user;

      v_pas := 1002;
      -- Miro que no supere la fecha de hoy.
      d_fin := LEAST(d_hoy, d_fin);
      v_pas := 1004;
      n_err := f_procesini(f_user, v_emp, 'VALLIQDIA:' || TO_CHAR(d_fin, 'ddmmyyyy'),
                           f_axis_literales(9001482, n_idioma), n_sproces);
      v_pas := 1010;
      n_toterror := 0;

      FOR f1 IN c1 LOOP
         DECLARE
            no_cargar_fondo EXCEPTION;
            d_aux          DATE;
            d_aux2         DATE;
         BEGIN
            -- Dia que entran manualmente la valoracion de la cesta.
            v_pas := 1015;
            n_diavalman := NVL(f_parproductos_v(f1.sproduc, 'DIA_VALOR_MANUAL'), n_diadef);
            -- Buscar si existe valoracion del fondo y si la fecha supera la actual.
            v_pas := 1022;

            SELECT MAX(fvalor)
              INTO d_aux
              FROM tabvalces a
             WHERE a.ccesta = f1.ccodfon;

            IF d_aux IS NULL THEN
               n_err := f_proceslin(n_sproces,
                                    f_axis_literales(1000179, n_idioma) || ' ' || f1.ccodfon,
                                    100539, n_prolin, 1);
               n_toterror := n_toterror + 1;
               RAISE no_cargar_fondo;
            ELSIF d_aux > d_fin THEN
               n_err := f_proceslin(n_sproces,
                                    f_axis_literales(1000179, n_idioma) || ' ' || f1.ccodfon
                                    || ' ' || TO_CHAR(d_aux, 'dd-mm-yyyy') || ' '
                                    || TO_CHAR(d_fin, 'dd-mm-yyyy'),
                                    107705, n_prolin, 1);
               n_toterror := n_toterror + 1;
               RAISE no_cargar_fondo;
            END IF;

            BEGIN
               v_pas := 1025;
               d_ini := TO_DATE(TO_CHAR(n_diavalman, '09') || TO_CHAR(d_fin, 'mmyyyy'),
                                'ddmmyyyy');
               d_ini := f_diahabil(13, TRUNC(d_ini), NULL);
            EXCEPTION
               WHEN OTHERS THEN
                  -- Seguramente dara problemas por fecha final de mes.
                  v_pas := 1030;
                  d_ini := LAST_DAY(d_fin);
            END;

            -- Siguiente valoracion manual
            IF d_ini > d_hoy THEN
               d_maxvalman := d_ini;
            ELSE
               d_maxvalman := TO_DATE(TO_CHAR(n_diavalman, '09')
                                      || TO_CHAR(ADD_MONTHS(d_ini, 1), 'mmyyyy'),
                                      'ddmmyyyy');
            END IF;

            IF d_ini > d_hoy THEN
               v_pas := 1035;
               d_ini := TO_DATE(TO_CHAR(n_diavalman, '09')
                                || TO_CHAR(ADD_MONTHS(d_fin, -1), 'mmyyyy'),
                                'ddmmyyyy');
            END IF;

            v_pas := 1040;

            SELECT MAX(fvalor)
              INTO d_aux2
              FROM tabvalces a
             WHERE a.ccesta = f1.ccodfon
               AND fvalor >= d_ini;

            IF d_aux2 IS NULL THEN
               n_err := f_proceslin(n_sproces,
                                    f_axis_literales(1000179, n_idioma) || ' ' || f1.ccodfon,
                                    102473, n_prolin, 1);
               n_toterror := n_toterror + 1;
               RAISE no_cargar_fondo;
            END IF;

            -- Inici proces per dies.
            v_pas := 1040;

            LOOP
               d_aux := d_aux + 1;
               -- Si es la fecha de calculo manual o si supera fecha peticion paramos.
               EXIT WHEN(d_aux = d_maxvalman
                         OR d_aux > d_fin);

               IF d_aux <> d_maxvalman THEN
                  v_pas := 1045;

                  BEGIN
                     INSERT INTO fonoper2
                                 (cempres, ccodfon, foperac, fvalor, ctipope, iimpcmp,
                                  nunicmp, iimpvnt, nunivnt, iuniact, ivalact, cestado,
                                  ccesta, ipatrimonio)
                        SELECT cempres, ccodfon, foperac, d_aux fvalor, ctipope, iimpcmp,
                               nunicmp, iimpvnt, nunivnt, iuniact, ivalact, cestado, ccesta,
                               ipatrimonio
                          FROM fonoper2
                         WHERE cempres = v_emp
                           AND ccodfon = f1.ccodfon
                           AND fvalor = d_aux - 1;
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;
               END IF;

               v_pas := 1050;
               n_err := pac_mantenimiento_fondos_finv.f_valorar(d_aux, v_emp, f1.ccodfon);

               IF NVL(n_err, -1) <> 0 THEN
                  n_err := f_proceslin(n_sproces,
                                       '1.-' || f_axis_literales(1000179, n_idioma) || ' '
                                       || f1.ccodfon || ' ' || TO_CHAR(d_aux, 'dd-mm-yyyy'),
                                       NVL(n_err, -1), n_prolin, 1);
                  n_toterror := n_toterror + 1;
                  RAISE no_cargar_fondo;
               END IF;

               v_pas := 1070;
               n_err := pac_mantenimiento_fondos_finv.f_asign_unidades(d_aux, n_idioma, v_emp,
                                                                       f1.ccodfon);

               IF NVL(n_err, -2) <> 0 THEN
                  n_err := f_proceslin(n_sproces,
                                       '2.-' || f_axis_literales(1000179, n_idioma) || ' '
                                       || f1.ccodfon || ' ' || TO_CHAR(d_aux, 'dd-mm-yyyy'),
                                       NVL(n_err, -2), n_prolin, 1);
                  n_toterror := n_toterror + 1;
                  RAISE no_cargar_fondo;
               END IF;

               v_pas := 1080;
               n_err := f_proceslin(n_sproces,
                                    f1.ccodfon || ' (' || f1.sproduc || ') '
                                    || TO_CHAR(d_aux, 'dd-mm-yyyy'),
                                    0, n_prolin, 0);
            END LOOP;
         EXCEPTION
            WHEN no_cargar_fondo THEN
               NULL;
         END;
      END LOOP;

      -- Finalizamos proces
      n_err := f_procesfin(n_sproces, n_toterror);
      v_pas := 9999;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(d_hoy, f_user, v_obj, v_pas, v_par, SQLCODE || '-' || SQLERRM);
         -- Finalizamos proces
         n_err := f_procesfin(n_sproces, n_toterror + 1);
         RETURN 9901850;
   END f_carga_valliqdiario;

   /******************************************************************************
    función que graba o actualiza la tabla fondos

    param in:       pcempres
    param in out:   pccodfon
    param in:       ptfonabv
    param in:       ptfoncmp
    param in:       pcmoneda
    param in:       pcmanager
    param in:       pnmaxuni
    param in:       pigasttran
    param in:       pfinicio
    param in:       pcclsfon
    param in:       pctipfon
    param in out:   mensajes

   ******************************************************************************/
   FUNCTION f_set_fondo(
      pcempres IN NUMBER,
      pccodfon IN OUT NUMBER,
      ptfonabv IN VARCHAR2,
      ptfoncmp IN VARCHAR2,
      pcmoneda IN NUMBER,
      pcmanager IN NUMBER,
      pnmaxuni IN NUMBER,
      pigasttran IN NUMBER,
      pfinicio IN DATE,
      pcclsfon IN NUMBER,
      pctipfon IN NUMBER,
      pcmodabo IN NUMBER,
      pndayaft IN NUMBER,
      pnperiodbon IN NUMBER,
      pcdividend IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        NUMBER := 0;
      vobject        VARCHAR2(100) := 'PAC_MANTENIMIENTO_FONDOS.f_set_fondo';
      vparam         VARCHAR2(500)
         := 'pccodfon: ' || pccodfon || ' ptfonabv:' || ptfonabv || ' ptfoncmp:' || ptfoncmp
            || ' pcclsfon:' || pcclsfon || ' pctipfon:' || pctipfon || ' pcmanager:'
            || pcmanager || ' pnmaxuni:' || pnmaxuni || ' pigasttran:' || pigasttran
            || ' pcmodabo:' || pcmodabo || ' pndayaft:' || pndayaft || ' pcdividend: '
            || pcdividend;
      vpasexec       NUMBER := 1;
   BEGIN
      IF pccodfon IS NULL
         OR pccodfon <= 0 THEN
         BEGIN
            SELECT MAX(ccodfon) + 1
              INTO pccodfon
              FROM fondos
             WHERE cempres = pcempres;

            IF pccodfon IS NULL THEN
               pccodfon := 1;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 1000254;
         END;
      END IF;

      BEGIN
         vpasexec := 2;

         INSERT INTO fondos
                     (ccodfon, tfonabv, tfoncmp, cclsfon, ctipfon, cempres, cmoneda,
                      cmanager, nmaxuni, igasttran, finicio, cmodabo, ndayaft,
                      nperiodbon, cdividend)
              VALUES (pccodfon, ptfonabv, ptfoncmp, pcclsfon, pctipfon, pcempres, pcmoneda,
                      pcmanager, pnmaxuni, pigasttran, f_sysdate, pcmodabo, pndayaft,
                      pnperiodbon, pcdividend);

         INSERT INTO fonestado
                     (ccodfon, fvalora, cestado)
              VALUES (pccodfon, f_sysdate, 'A');
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            vpasexec := 3;

            UPDATE fondos
               SET tfonabv = ptfonabv,
                   tfoncmp = ptfoncmp,
                   cclsfon = pcclsfon,
                   ctipfon = pctipfon,
                   cmoneda = pcmoneda,
                   cmanager = pcmanager,
                   nmaxuni = pnmaxuni,
                   igasttran = pigasttran,
                   cmodabo = pcmodabo,
                   ndayaft = pndayaft,
                   nperiodbon = pnperiodbon,
                   cdividend = pcdividend
             WHERE ccodfon = pccodfon
               AND cempres = pcempres;
         WHEN OTHERS THEN
            vpasexec := 4;
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                        SQLCODE || '-' || SQLERRM);
            RETURN 1000001;
      END;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         vpasexec := 5;
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLCODE || '-' || SQLERRM);
         RETURN 1000001;
   END f_set_fondo;

   /******************************************************************************
      función que graba o actualiza el estado de un fondo.

      param in:       pccodfon
      param in :      pfecha
      param in:       ptfonabv
      param in out:   mensajes

     ******************************************************************************/
   FUNCTION f_set_estado_fondo(
      pccodfon IN NUMBER,
      pfecha IN DATE,
      pcestado IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
   BEGIN
      INSERT INTO fonestado
                  (ccodfon, fvalora, cestado)
           VALUES (pccodfon, pfecha, pcestado);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         UPDATE fonestado
            SET fvalora = f_sysdate,
                cestado = pcestado
          WHERE ccodfon = pccodfon;
   END f_set_estado_fondo;

   FUNCTION f_valora_siniestros_fnd(
      pfvalmov IN DATE,
      pcesta IN NUMBER,
      psseguro IN NUMBER,
      psproces IN OUT NUMBER,
      pnerrores IN OUT NUMBER,
      pcidioma IN NUMBER,
      pccausin IN NUMBER)
      RETURN NUMBER IS
      v_error        NUMBER;
      v_cmonpol      NUMBER;
      v_itasa        NUMBER;
      v_fcambio      DATE;
      vsquery        VARCHAR2(1000);
      cur            sys_refcursor;
      mensajes       t_iax_mensajes;
      viuniact       NUMBER;
      viuniactshw    NUMBER;
      vnunidad       NUMBER;
      vnunidadshw    NUMBER;
      iuniact_cmoncia NUMBER;
      iuniactshw_cmoncia NUMBER;

      TYPE linea IS RECORD(
         ccesta         NUMBER,
         sseguro        NUMBER,
         ireserva       NUMBER,
         nsinies        NUMBER,
         ntramit        NUMBER,
         nunidad        NUMBER,
         freserva       DATE,
         ireservashw    NUMBER,
         nunidadshw     NUMBER
      );

      lineat         linea;
      retorno        NUMBER := 0;
      vireserva      NUMBER;
      vireservashw   NUMBER;
      bupdate        BOOLEAN := TRUE;
      v_usar_shw     NUMBER;
      vnmaxuni       NUMBER;
      vnmaxunishw    NUMBER;
      vtotalcestas   NUMBER;
      vpexec         NUMBER := 1;
      vobject        VARCHAR2(200) := 'PAC_MANTENIMIENTO_FONDOS_FINV.f_valora_siniestros_fnd';
      data_error     EXCEPTION;
      vparam         VARCHAR2(1000)
         := 'pcesta:' || pcesta || 'psseguro:' || psseguro || 'psproces:' || psproces
            || 'pnerrores:' || pnerrores || 'pcidioma:' || pcidioma || 'pccausin:' || pccausin;
   BEGIN
      vsquery :=
         'SELECT stpf.ccesta, s.sseguro,stpf.ireserva,stpf.nsinies,stpf.ntramit,stpf.nunidad,stp.freserva,stpf.ireservashw,stpf.nunidadshw
       FROM SIN_TRAMITA_PRERESERVA_FND stpf ,
            SIN_TRAMITA_PRERESERVA stp,
            SIN_SINIESTRO s
       WHERE (stpf.iunidad is null)
             AND stpf.NSINIES = stp.NSINIES
             AND s.nsinies = stp.nsinies';

      IF pcesta IS NOT NULL THEN
         vsquery := vsquery || ' AND stpf.ccesta = ' || pcesta;
      END IF;

      IF psseguro IS NOT NULL THEN
         vsquery := vsquery || ' AND s.sseguro = ' || psseguro;
      END IF;

      cur := pac_iax_listvalores.f_opencursor(vsquery, mensajes);

      LOOP
         FETCH cur
          INTO lineat;

         bupdate := TRUE;

         BEGIN
            vpexec := 2;
            v_usar_shw := pac_propio.f_usar_shw(lineat.sseguro, NULL);

            SELECT iuniact, iuniactvtashw
              INTO viuniact, viuniactshw
              FROM tabvalces
             WHERE ccesta = lineat.ccesta
               AND fvalor = lineat.freserva + pac_md_fondos.f_get_diasdep(lineat.ccesta);

            ---FALTA POSAR EL FILTRE PER DATA ---
            IF viuniact IS NOT NULL
               OR viuniactshw IS NOT NULL THEN
               BEGIN
                  IF pccausin = 5 THEN
                     vpexec := 3;

                     /*
                         v_error := pac_oper_monedas.f_datos_contraval
                         (psseguro, NULL, NULL, pfvalmov, 1, v_itasa, v_fcambio);

                         v_cmonpol := pac_oper_monedas.f_monpol(psseguro);

                         iuniact_cmoncia := f_round(viuniact * v_itasa, v_cmonpol);

                         iuniactshw_cmoncia := f_round(viuniactshw * v_itasa, v_cmonpol);
                         */
                     IF lineat.ireserva IS NOT NULL THEN
                        vnunidadshw := lineat.ireservashw / viuniactshw;
                        vnunidad := lineat.ireserva / viuniact;
                        vireserva := lineat.ireserva;
                        vireservashw := lineat.ireservashw;
                     ELSIF lineat.nunidad IS NOT NULL
                           OR lineat.nunidadshw IS NOT NULL THEN
                        IF v_usar_shw = 1 THEN
                           vireservashw := viuniactshw * lineat.nunidadshw;
                           v_error := pac_propio.f_reparto_shadow(psseguro, NULL,
                                                                  lineat.ccesta, vireservashw,
                                                                  vireserva, vireservashw);
                        ELSE
                           vireserva := viuniact * lineat.nunidad;
                           v_error := pac_propio.f_reparto_shadow(psseguro, NULL,
                                                                  lineat.ccesta, vireserva,
                                                                  vireserva, vireservashw);
                        END IF;

                        IF v_error <> 0 THEN
                           RAISE data_error;
                        END IF;

                        vnunidad := lineat.nunidad;
                        vnunidadshw := lineat.nunidadshw;
                     ELSE
                        bupdate := FALSE;
                     END IF;
                  ELSIF pccausin IN(3, 4) THEN
                     vireserva := 0;
                     vtotalcestas := 0;
                     vnunidad := 0;
                     v_error := pac_operativa_finv.f_cta_saldo_fondos_cesta(psseguro, NULL,
                                                                            lineat.ccesta,
                                                                            vnunidad,
                                                                            vireserva,
                                                                            vtotalcestas);

                     IF v_error <> 0 THEN
                        RAISE data_error;
                     END IF;

                     vireservashw := 0;
                     vtotalcestas := 0;
                     vnunidadshw := 0;
                     v_error := pac_operativa_finv.f_cta_saldo_fondos_cesta_shw(psseguro, NULL,
                                                                                lineat.ccesta,
                                                                                vnunidadshw,
                                                                                vireservashw,
                                                                                vtotalcestas);

                     IF v_error <> 0 THEN
                        RAISE data_error;
                     END IF;
                  END IF;
               EXCEPTION
                  WHEN data_error THEN
                     p_tab_error(f_sysdate, f_user, vobject, vpexec, vparam,
                                 f_axis_literales(v_error, -1) || '-' || SQLERRM);
                     bupdate := FALSE;
                     retorno := v_error;
               END;

               vpexec := 4;

               IF bupdate THEN
                  UPDATE sin_tramita_prereserva_fnd
                     SET nunidad = vnunidad,
                         iunidad = viuniact,
                         ireserva = vireserva,
                         iunidadshw = viuniactshw,
                         ireservashw = vireservashw,
                         nunidadshw = vnunidadshw
                   WHERE ccesta = lineat.ccesta
                     AND nsinies = lineat.nsinies
                     AND ntramit = lineat.ntramit;
               END IF;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               retorno := 0;
         END;

         EXIT WHEN cur%NOTFOUND;
      END LOOP;

      CLOSE cur;

      RETURN retorno;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpexec, vparam, SQLCODE || '-' || SQLERRM);
         RETURN 140999;
   END f_valora_siniestros_fnd;

   FUNCTION f_asign_dividends(
      pmodo IN VARCHAR2,
      pccodfon IN NUMBER,
      pfvigencia IN DATE,
      pfvalmov IN DATE,
      piimpdiv IN NUMBER,
      psproces IN OUT NUMBER,
      plineas IN OUT NUMBER,
      plineas_error IN OUT NUMBER)
      RETURN NUMBER IS
      --
      verrparms      EXCEPTION;
      verrproc       EXCEPTION;
      verrsalir      EXCEPTION;
      v_texto        VARCHAR2(1000);
      vtitulo        VARCHAR2(1000);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := ' pmodo = ' || pmodo || ' pccodfon = ' || pccodfon || ' pfvigencia= '
            || TO_CHAR(pfvigencia, 'DD/MM/YYYY') || ' pfvalmov= '
            || TO_CHAR(pfvalmov, 'DD/MM/YYYY') || ' piimpdiv = ' || piimpdiv || ' psproces = '
            || psproces || ' plineas = ' || plineas || ' plineas_error = ' || plineas_error;
      vobject        VARCHAR2(200) := 'PAC_CTASEGURO.F_ASIGN_DIVIDENDS';
      vnum_err       NUMBER := 0;
      v_err          NUMBER := 0;
      vcont          NUMBER;
      vtcesta_unidades NUMBER := 0;
      vtcesta_importe NUMBER := 0;
      vtotal_cestas  NUMBER := 0;
      vimpdiv        NUMBER;
      v_tipopb       NUMBER := 0;
      vctipproc      NUMBER := 1;   -- v.f. 2000
      vnrecibo       NUMBER;
      vnmovimi       NUMBER;
      vnnumlin       NUMBER;

      -- Polizas nuevas a procesar
      -- el sseguro no debe existir dentro de la tabla ADM_PROCESO_PU, con la misma FEFECTO que el parámetro pfvalmov y CTIPPROC=1
      CURSOR polizas IS
         SELECT DISTINCT s.sproduc, s.sseguro, s.npoliza, s.cempres, s.cactivi, s.cidioma,
                         s.cmoneda, f.cmodabo, f.ccodfon
                    FROM segdisin2 s1, seguros s, fondos f
                   WHERE s1.sseguro = s.sseguro
                     AND s1.ccesta = f.ccodfon
                     AND s1.ccesta = pccodfon
                     AND((pfvalmov >= s1.finicio
                          AND pfvalmov < s1.ffin)
                         OR(pfvalmov >= s1.finicio
                            AND s1.ffin IS NULL))
                     AND f_situacion_v(s.sseguro, pfvigencia) = 1
                     AND s.creteni = 0
                     AND NOT EXISTS(SELECT 1
                                      FROM adm_proceso_pu adm
                                     WHERE adm.sseguro = s.sseguro
                                       AND adm.fefecto = pfvalmov
                                       AND adm.ctipproc = vctipproc);

      -- Polizas pendientes de reprocesar
      -- el sseguro debe existir dentro de la tabla ADM_PROCESO_PU, con la misma FEFECTO que el parámetro pfvalmov y con el valor de la columna CESTADO=0 y CTIPPROC=1
      CURSOR polizas_no_procesadas IS
         SELECT DISTINCT s.sproduc, s.sseguro, s.npoliza, s.cempres, s.cactivi, s.cidioma,
                         s.cmoneda, f.cmodabo, f.ccodfon, adm.sproces, adm.nriesgo,
                         adm.fefecto
                    FROM segdisin2 s1, seguros s, fondos f, adm_proceso_pu adm
                   WHERE s1.sseguro = s.sseguro
                     AND s1.ccesta = f.ccodfon
                     AND s.sseguro = adm.sseguro
                     AND adm.fefecto = pfvalmov
                     AND adm.cestado = 0
                     AND adm.ctipproc = vctipproc
                     AND adm.ccodfon = pccodfon
                     AND s1.ccesta = pccodfon
                     AND((pfvalmov >= s1.finicio
                          AND pfvalmov < s1.ffin)
                         OR(pfvalmov >= s1.finicio
                            AND s1.ffin IS NULL))
                     AND f_situacion_v(s.sseguro, pfvigencia) = 1
                     AND s.creteni = 0;

      reg            polizas%ROWTYPE;
      reg_adm        polizas_no_procesadas%ROWTYPE;
   BEGIN
      vpasexec := 1;

      IF plineas_error IS NULL THEN
         plineas_error := 0;
      END IF;

      IF plineas IS NULL THEN
         plineas := 0;
      END IF;

      vpasexec := 2;

      IF pmodo IS NULL
         AND pccodfon IS NULL
         OR pfvigencia IS NULL
         OR pfvalmov IS NULL
         OR piimpdiv IS NULL THEN
         vnum_err := 103135;
         RAISE verrparms;
      END IF;

      vpasexec := 3;

      IF pmodo = 'A' THEN
         vtitulo := f_axis_literales(9908488, pac_md_common.f_get_cxtidioma);
      ELSE
         vtitulo := f_axis_literales(9908489, pac_md_common.f_get_cxtidioma);
      END IF;

      vpasexec := 4;

      IF psproces IS NULL THEN
         vnum_err := f_procesini(f_user, pac_md_common.f_get_cxtempresa, 'DIVIDENDS', vtitulo,
                                 psproces);
      END IF;

      IF psproces IS NULL THEN
         vnum_err := 9908490;
         RAISE verrsalir;
      END IF;

      vpasexec := 5;

      IF pmodo = 'A' THEN   -- reproceso
         OPEN polizas_no_procesadas;
      ELSE
         OPEN polizas;
      END IF;

      LOOP
         IF pmodo = 'A' THEN   -- reproceso
            vpasexec := 6;

            FETCH polizas_no_procesadas
             INTO reg_adm;

            EXIT WHEN polizas_no_procesadas%NOTFOUND;
            reg.sproduc := reg_adm.sproduc;
            reg.sseguro := reg_adm.sseguro;
            reg.npoliza := reg_adm.npoliza;
            reg.cempres := reg_adm.cempres;
            reg.cactivi := reg_adm.cactivi;
            reg.cidioma := reg_adm.cidioma;
            reg.cmoneda := reg_adm.cmoneda;
            reg.cmodabo := reg_adm.cmodabo;
            reg.ccodfon := reg_adm.ccodfon;
         ELSE
            vpasexec := 7;

            FETCH polizas
             INTO reg;

            EXIT WHEN polizas%NOTFOUND;
         END IF;

         vpasexec := 8;
         plineas := plineas + 1;

         BEGIN
            vpasexec := 9;
            vnum_err := pac_operativa_finv.f_cta_provision_cesta(reg.sseguro, NULL, pfvalmov,
                                                                 reg.ccodfon,
                                                                 vtcesta_unidades,
                                                                 vtcesta_importe,
                                                                 vtotal_cestas, NULL);
            vimpdiv := ROUND(vtcesta_unidades * piimpdiv, NVL(reg.cmoneda, 6));

            IF vimpdiv IS NULL THEN
               vnum_err := 9908491;
               v_texto := f_axis_literales(vnum_err, f_idiomauser);
               vnnumlin := NULL;
               v_err := f_proceslin(psproces,
                                    v_texto || ' ' || TO_CHAR(pfvalmov, 'dd/mm/yyyy')
                                    || ' Traza ' || vpasexec,
                                    reg.sseguro, vnnumlin);
               RAISE verrproc;
            END IF;

            vpasexec := 10;
            vnum_err := f_movseguro(reg.sseguro, NULL, 402, NULL, pfvalmov, NULL, NULL, NULL,
                                    pfvalmov, vnmovimi, f_sysdate);

            IF vnum_err <> 0 THEN
               vnum_err := 101992;
               -- Error en la función MOVSEGURO para el seguro:
               v_texto := f_axis_literales(vnum_err, f_idiomauser);
               vnnumlin := NULL;
               v_err := f_proceslin(psproces,
                                    v_texto || ' ' || reg.sseguro || ' '
                                    || TO_CHAR(pfvalmov, 'dd/mm/yyyy') || ' Traza '
                                    || vpasexec,
                                    reg.sseguro, vnnumlin);
               RAISE verrproc;
            END IF;

            IF NVL(reg.cmodabo, 0) = 0 THEN
               -- fondos.cmodabo = 0 --> Asignacion en la cuenta de la poliza
               vnum_err := pac_ctaseguro.f_insctaseguro(reg.sseguro, f_sysdate, NULL,
                                                        pfvalmov, pfvalmov, 15, vimpdiv, NULL,
                                                        NULL, scagrcta.NEXTVAL, NULL, NULL,
                                                        NULL, NULL, 'R', psproces, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        reg.ccodfon);

               IF vnum_err <> 0 THEN
                  vnum_err := 111914;   -- Error a ctaseguro
                  v_texto := f_axis_literales(vnum_err, f_idiomauser);
                  vnnumlin := NULL;
                  v_err := f_proceslin(psproces,
                                       v_texto || ' ' || reg.sseguro || ' '
                                       || TO_CHAR(pfvalmov, 'dd/mm/yyyy') || ' Traza '
                                       || vpasexec,
                                       reg.sseguro, vnnumlin);
                  RAISE verrproc;
               END IF;
            ELSE
               -- fondos.cmodabo = 1 --> Generacion de pago al cliente
               vpasexec := 11;
               vnum_err := pac_ctaseguro.f_genera_recibo(reg.cempres, psproces, f_sysdate,
                                                         pfvalmov, pfvalmov + 1, reg.sseguro,
                                                         reg.cactivi, vimpdiv, reg.cidioma,
                                                         vnmovimi, 13, vnrecibo, reg.sproduc,
                                                         NULL);

               IF vnum_err <> 0 THEN
                  vnum_err := 9904162;
                  -- Error al generar recibos de retorno.
                  v_texto := f_axis_literales(vnum_err, f_idiomauser);
                  vnnumlin := NULL;
                  v_err := f_proceslin(psproces,
                                       v_texto || ' ' || TO_CHAR(pfvalmov, 'dd/mm/yyyy')
                                       || ' Traza ' || vpasexec,
                                       reg.sseguro, vnnumlin);
                  RAISE verrproc;
               END IF;
            END IF;

            vpasexec := 12;

            IF vnum_err = 0 THEN
               IF pmodo = 'A' THEN   -- reproceso
                  vpasexec := 13;

                  UPDATE adm_proceso_pu
                     SET cestado = 1,   -- Estado tratado
                         importe = vimpdiv,
                         fcalcul = pfvalmov,
                         freproc = f_sysdate,
                         cerror = NULL,
                         terror = NULL
                   WHERE sproces = reg_adm.sproces
                     AND sseguro = reg_adm.sseguro
                     AND nriesgo = reg_adm.nriesgo
                     AND fefecto = reg_adm.fefecto;
               ELSE
                  vpasexec := 14;
                  v_err := f_buscanmovimi(reg.sseguro, 1, 1, vnmovimi);

                  INSERT INTO adm_proceso_pu
                              (sproces, sseguro, nriesgo, nmovimi, fefecto, fcalcul,
                               ctipopu, cestado, importe, ctipproc, ccodfon)
                       VALUES (psproces, reg.sseguro, 1, vnmovimi, pfvalmov, pfvalmov,
                               v_tipopb, 1, vimpdiv, vctipproc, reg.ccodfon);
               END IF;
            END IF;

            vpasexec := 15;
            v_texto := f_axis_literales(9908492, f_idiomauser) || ' '
                       || f_axis_literales(9001514, f_idiomauser) || ' ' || reg.npoliza;

            IF vnrecibo IS NOT NULL THEN
               v_texto := v_texto || ' ' || f_axis_literales(109253, f_idiomauser) || ' '
                          || vnrecibo;
            END IF;

            vnnumlin := NULL;
            v_err := f_proceslin(psproces, v_texto || ' ' || TO_CHAR(pfvalmov, 'dd/mm/yyyy'),
                                 reg.sseguro, vnnumlin);
            vpasexec := 16;
            COMMIT;
         EXCEPTION
            --Las que fallan no las tratamos y las dejamos para más adelante
            WHEN verrproc THEN
               ROLLBACK;
               -- Grabamos un registro en la tabla de procesos PU con cestado = 0 - Pdte procesar
               v_err := f_buscanmovimi(reg.sseguro, 1, 1, vnmovimi);

               IF pmodo = 'A' THEN
                  UPDATE adm_proceso_pu
                     SET cestado = 0,
                         importe = vimpdiv,
                         fcalcul = pfvalmov,
                         freproc = f_sysdate,
                         cerror = vnum_err,
                         terror = v_texto
                   WHERE sproces = reg_adm.sproces
                     AND sseguro = reg_adm.sseguro
                     AND nriesgo = reg_adm.nriesgo
                     AND fefecto = reg_adm.fefecto;
               ELSE
                  INSERT INTO adm_proceso_pu
                              (sproces, sseguro, nriesgo, nmovimi, fefecto, fcalcul, cestado,
                               ctipopu, importe, cerror, terror, ctipproc, ccodfon)
                       VALUES (psproces, reg.sseguro, 1, vnmovimi, pfvalmov, pfvalmov, 0,
                               v_tipopb, vimpdiv, vnum_err, v_texto, vctipproc, reg.ccodfon);
               END IF;

               plineas_error := plineas_error + 1;
               COMMIT;
            WHEN OTHERS THEN
               ROLLBACK;
               -- Grabamos un registro en la tabla de procesos PU con cestado = 0 - Pdte procesar
               v_texto := 'Error no controlado:' || vparam || ' Traza ' || vpasexec
                          || ' SQLERROR: ' || SQLERRM;
               v_err := f_buscanmovimi(reg.sseguro, 1, 1, vnmovimi);

               IF pmodo = 'A' THEN
                  UPDATE adm_proceso_pu
                     SET cestado = 0,
                         importe = vimpdiv,
                         fcalcul = pfvalmov,
                         freproc = f_sysdate,
                         cerror = vnum_err,
                         terror = v_texto
                   WHERE sproces = reg_adm.sproces
                     AND sseguro = reg_adm.sseguro
                     AND nriesgo = reg_adm.nriesgo
                     AND fefecto = reg_adm.fefecto;
               ELSE
                  INSERT INTO adm_proceso_pu
                              (sproces, sseguro, nriesgo, nmovimi, fefecto, fcalcul, cestado,
                               ctipopu, importe, cerror, terror, ctipproc, ccodfon)
                       VALUES (psproces, reg.sseguro, 1, vnmovimi, pfvalmov, pfvalmov, 0,
                               v_tipopb, vimpdiv, vnum_err, v_texto, vctipproc, reg.ccodfon);
               END IF;

               vnnumlin := NULL;
               vnum_err := f_proceslin(psproces, v_texto, reg.sseguro, vnnumlin);
               plineas_error := plineas_error + 1;
               COMMIT;
         END;
      END LOOP;

      IF pmodo = 'A' THEN   -- Reproceso
         CLOSE polizas_no_procesadas;
      ELSE
         CLOSE polizas;
      END IF;

      vpasexec := 17;
      v_texto := f_axis_literales(103351, f_idiomauser) || TO_CHAR(plineas - plineas_error)
                 || ' | ' || f_axis_literales(103149, f_idiomauser) || plineas_error;
      v_err := f_proceslin(psproces, v_texto, 0, vnnumlin, 2);
      -- Finalizamos proces
      vnum_err := f_procesfin(psproces, 0);
      vpasexec := 18;
      RETURN 0;
   EXCEPTION
      WHEN verrparms THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'Faltan parámetros=' || vparam,
                     f_axis_literales(vnum_err, f_idiomauser));
         RETURN vnum_err;
      WHEN verrsalir THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'Error proceso=' || vparam,
                     f_axis_literales(vnum_err, f_idiomauser));
         RETURN vnum_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     'Error When others,sqlcode=' || vparam, SQLERRM);
         RETURN 1000455;   -- Error no controlado.
   END f_asign_dividends;
END pac_mantenimiento_fondos_finv;

/

  GRANT EXECUTE ON "AXIS"."PAC_MANTENIMIENTO_FONDOS_FINV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MANTENIMIENTO_FONDOS_FINV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MANTENIMIENTO_FONDOS_FINV" TO "PROGRAMADORESCSI";
