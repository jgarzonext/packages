--------------------------------------------------------
--  DDL for Package Body PAC_OPERATIVA_FINV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_OPERATIVA_FINV" AS
   /******************************************************************************
      NOMBRE:       PAC_OPERATIVA_FINV
      PROPÓSITO:
      REVISIONES:

      Ver        Fecha        Autor     Descripción
      ---------  ----------  -------  ------------------------------------
       1.0       -            -       1. Creación de package
       2.0       17/03/2009  RSC      2. Análisis adaptación productos indexados
       3.0       07/04/2009  RSC      3. Análisis adaptación productos indexados: PPJ Din, Pla estudiant
       4.0       17/09/2009  RSC      4. Bug 0010828: CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
       5.0       25/09/2009  JGM      5. Bug 0011175
       6.0       15/12/2009  NMM      6. 12274: CRE - ajuste de la fecha valor en redistribución (cambio de perfil).
       7.0       16/06/2011  JTS      7. BUG 0018799
       8.0       21/10/2011  JGR      8. 19852: CRE998 - Impressió de compte assegurança  (nota 0095567)
       9.0       15/12/2011  JMP      9. 0018423: LCOL705 - Multimoneda
       10.0      26/07/2012  MDS     10. 0023120: ENSA102-Revisar provisi?n siniestro ENSA
       11.0      07/11/2012  XVM     11.     0024587: CRE800 - PPJ amb suplement de canvi de perfil amb errors
       12.0      04/12/2012  AEG     12. 0022815: LCOL_T004- Qtracker 4665 - Periodictat comissions estalvi
       13.0      15/07/2014  AFM     13. 32058: GAP. Prima de Riesgo, gastos y comisiones prepagables
      14.0      30/07/2014  AFM     14. 32059/181051: Activación Gastos Redistribución. Cambio de tablas de gastos
                                        a PRODTRARESC y DETPRODTRARESC. Quedan obsoletas XXXGASTOS_ULK
       15.0      10/06/2015  IGIL    15  Tarea 31548-206135_Management expenses
   ******************************************************************************/
   FUNCTION ff_primas_satisfechas(
      psseguro IN seguros.sseguro%TYPE,
      fdesde IN DATE,
      fhasta IN DATE)
      RETURN NUMBER IS
      v              NUMBER;
      vsproduc       NUMBER;
   BEGIN
      SELECT sproduc
        INTO vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      IF NVL(f_parproductos_v(vsproduc, 'PRODUCTO_MIXTO'), 0) <> 1 THEN
         SELECT SUM(imovimi)
           INTO v
           FROM ctaseguro cs
          WHERE cs.cmovimi IN(1, 2, 4, 8)
            AND cs.sseguro = psseguro
            AND cmovanu <> 1   -- líneas no anuladas
            AND fvalmov >= fdesde
            AND fvalmov <= fhasta;
      ELSE
         SELECT SUM(crespue)
           INTO v
           FROM pregunseg
          WHERE sseguro = psseguro
            AND cpregun IN(1012, 1013)
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM pregunseg
                            WHERE sseguro = psseguro
                              AND cpregun IN(1012, 1013));
      END IF;

      /*
      SELECT SUM(NVL(itotalr,0)) INTO v
      FROM(
          select distinct v.* --SUM(NVL(v.itotalr,0)) --SUM(c.imovimi)
          from recibos r, vdetrecibos v, ctaseguro c
          where r.sseguro = psSeguro
            AND r.nrecibo = v.nrecibo
            AND c.sseguro = r.sseguro
            AND c.nrecibo = r.nrecibo
            AND c.cmovimi IN (1,2,4,8)
            AND c.fvalmov >= fdesde
            AND c.fvalmov <= fhasta
            AND c.nrecibo not in (select c2.nrecibo
                                  from recibos r2, vdetrecibos v2, ctaseguro c2
                                  where r2.sseguro = psSeguro
                                    AND r2.nrecibo = v2.nrecibo
                                    AND c2.sseguro = r2.sseguro
                                    AND c2.nrecibo = r2.nrecibo
                                    AND c2.cmovimi IN (51)
                                    AND c2.fvalmov >= fdesde
                                    AND c2.fvalmov <= fhasta)
      );
      */
      RETURN v;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.ff_primas_satisfechas', 1,
                     'psSeguro = ' || psseguro, SQLERRM);
         RETURN NULL;
   END ff_primas_satisfechas;

   FUNCTION ff_primas_satisfechas_shw(
      psseguro IN seguros.sseguro%TYPE,
      fdesde IN DATE,
      fhasta IN DATE)
      RETURN NUMBER IS
      v              NUMBER;
      vsproduc       NUMBER;
   BEGIN
      SELECT sproduc
        INTO vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      IF NVL(f_parproductos_v(vsproduc, 'PRODUCTO_MIXTO'), 0) <> 1 THEN
         SELECT SUM(imovimi)
           INTO v
           FROM ctaseguro_shadow cs
          WHERE cs.cmovimi IN(1, 2, 4, 8)
            AND cs.sseguro = psseguro
            AND cmovanu <> 1   -- líneas no anuladas
            AND fvalmov >= fdesde
            AND fvalmov <= fhasta;
      ELSE
         SELECT SUM(crespue)
           INTO v
           FROM pregunseg
          WHERE sseguro = psseguro
            AND cpregun IN(1012, 1013)
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM pregunseg
                            WHERE sseguro = psseguro
                              AND cpregun IN(1012, 1013));
      END IF;

      RETURN v;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.ff_primas_satisfechas', 1,
                     'psSeguro = ' || psseguro, SQLERRM);
         RETURN NULL;
   END ff_primas_satisfechas_shw;

   FUNCTION ff_gastos_gestion_y_cobertura(
      psseguro IN seguros.sseguro%TYPE,
      fdesde IN DATE,
      fhasta IN DATE)
      RETURN NUMBER IS
      v              NUMBER;
   BEGIN
      SELECT SUM(imovimi)
        INTO v
        FROM ctaseguro cs
       WHERE cs.cmovimi IN(82, 21)
         AND cs.sseguro = psseguro
         AND cmovanu <> 1   -- líneas no anuladas
         AND fvalmov >= fdesde
         AND fvalmov <= fhasta;

      RETURN v;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.ff_primas_satisfechas', 1,
                     'psSeguro = ' || psseguro, SQLERRM);
         RETURN NULL;
   END ff_gastos_gestion_y_cobertura;

   FUNCTION ff_gastos_gestioncobertura_shw(
      psseguro IN seguros.sseguro%TYPE,
      fdesde IN DATE,
      fhasta IN DATE)
      RETURN NUMBER IS
      v              NUMBER;
   BEGIN
      SELECT SUM(imovimi)
        INTO v
        FROM ctaseguro_shadow cs
       WHERE cs.cmovimi IN(82, 21)
         AND cs.sseguro = psseguro
         AND cmovanu <> 1   -- líneas no anuladas
         AND fvalmov >= fdesde
         AND fvalmov <= fhasta;

      RETURN v;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user,
                     'PAC_OPERATIVA_FINV.ff_gastos_gestion_y_cobertura_shw', 1,
                     'psSeguro = ' || psseguro, SQLERRM);
         RETURN NULL;
   END ff_gastos_gestioncobertura_shw;

   FUNCTION ff_gastos_redistribucion(
      psseguro IN seguros.sseguro%TYPE,
      fdesde IN DATE,
      fhasta IN DATE)
      RETURN NUMBER IS
      v              NUMBER;
   BEGIN
      SELECT SUM(imovimi)
        INTO v
        FROM ctaseguro cs
       WHERE cs.cmovimi IN(80)
         AND cs.sseguro = psseguro
         AND cmovanu <> 1   -- líneas no anuladas
         AND fvalmov >= fdesde
         AND fvalmov <= fhasta;

      RETURN v;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.ff_primas_satisfechas', 1,
                     'psSeguro = ' || psseguro, SQLERRM);
         RETURN NULL;
   END ff_gastos_redistribucion;

   FUNCTION ff_gastos_redistribucion_shw(
      psseguro IN seguros.sseguro%TYPE,
      fdesde IN DATE,
      fhasta IN DATE)
      RETURN NUMBER IS
      v              NUMBER;
   BEGIN
      SELECT SUM(imovimi)
        INTO v
        FROM ctaseguro_shadow cs
       WHERE cs.cmovimi IN(80)
         AND cs.sseguro = psseguro
         AND cmovanu <> 1   -- líneas no anuladas
         AND fvalmov >= fdesde
         AND fvalmov <= fhasta;

      RETURN v;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.ff_gastos_redistribucion_shw', 1,
                     'psSeguro = ' || psseguro, SQLERRM);
         RETURN NULL;
   END ff_gastos_redistribucion_shw;

   FUNCTION ff_provmat(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      ppfefecto IN NUMBER,
      pnnumlin IN NUMBER DEFAULT NULL)   -- Bug 19312 - RSC - 24/11/2011
      RETURN NUMBER IS
      CURSOR cur_cesta(v_sseguro IN NUMBER) IS
         SELECT ccesta, pdistrec
           FROM segdisin2
          WHERE sseguro = v_sseguro
            AND ffin IS NULL
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM segdisin2
                            WHERE sseguro = v_sseguro
                              AND ffin IS NULL);

      nparacts       NUMBER;
      iuniacts       NUMBER;
      v_provision    NUMBER := 0;
      pfefecto       DATE;
      v_seguroini    estseguros.ssegpol%TYPE;
      -- Bug 19312 - RSC - 24/11/2011
      v_pfvalmov     DATE;
      -- Fin Bug 19312

      -- Bug 23455 - RSC - 05/09/2012 CRE800 - Càlcul capital de mort PPJ dinàmic
      v_origen       NUMBER;
   -- Fin Bug 23455
   BEGIN
      --BEGIN
      --   SELECT ssegpol   -- Queremos el sseguro original
      --     INTO v_seguroini
      --     FROM estseguros
      --    WHERE sseguro = psseguro;
      --EXCEPTION
      --   WHEN NO_DATA_FOUND THEN
      --      v_seguroini := psseguro;
      --END;

      -- Bug 23455 - RSC - 05/09/2012 CRE800 - Càlcul capital de mort PPJ dinàmic
      -- v_seguroini := psseguro;
      v_origen := NVL(pac_gfi.f_sgt_parms('ORIGEN', psesion), 0);

      IF v_origen = 2 THEN
         v_seguroini := psseguro;
      ELSIF v_origen = 1 THEN
         BEGIN
            SELECT ssegpol   -- Queremos el sseguro original
              INTO v_seguroini
              FROM estseguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               v_seguroini := psseguro;
         END;
      ELSE
         v_seguroini := psseguro;
      END IF;

      -- Fin Bug 23455
      pfefecto := TO_DATE(ppfefecto, 'yyyy/mm/dd');

      FOR regs IN cur_cesta(v_seguroini) LOOP
         BEGIN
            -- Bug 19312 - RSC - 24/11/2011
            IF pnnumlin IS NOT NULL THEN
               -- Query para obtener las participaciones acumuladas de la cesta
               SELECT NVL(SUM(nunidad), 0)
                 INTO nparacts
                 FROM ctaseguro
                WHERE sseguro = v_seguroini
                  AND cesta = regs.ccesta
                  AND nnumlin <= pnnumlin
                  AND((cestado <> '9')
                      OR(cestado = '9'
                         AND imovimi <> 0
                         AND imovimi IS NOT NULL));
            ELSE
               -- Fin Bug 19312

               -- Query para obtener las participaciones acumuladas de la cesta
               SELECT NVL(SUM(nunidad), 0)
                 INTO nparacts
                 FROM ctaseguro
                WHERE sseguro = v_seguroini
                  --and cmovimi <> 0
                  --AND cmovimi NOT IN(0, 91, 93, 94, 97)   -- Bug 10846 - RSC - 13/10/2009 - CRE - Operaciones con Fondos
                  AND cesta = regs.ccesta
                  -- bug 2312 - MDS - truncar las dos fechas
                  AND TRUNC(fvalmov) <= TRUNC(pfefecto)
                  AND((cestado <> '9')
                      OR(cestado = '9'
                         AND imovimi <> 0
                         AND imovimi IS NOT NULL));
            END IF;

            --PRECIO UNIDAD

            -- Bug 19312 - RSC - 24/11/2011
            IF pnnumlin IS NOT NULL THEN
               SELECT fvalmov
                 INTO v_pfvalmov
                 FROM ctaseguro
                WHERE sseguro = v_seguroini
                  AND nnumlin = pnnumlin;

               BEGIN
                  SELECT NVL(iuniact, 0)
                    INTO iuniacts
                    FROM tabvalces
                   WHERE ccesta = regs.ccesta
                     AND TRUNC(fvalor) = TRUNC(v_pfvalmov);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                        SELECT NVL(iuniact, 0)
                          INTO iuniacts
                          FROM tabvalces
                         WHERE ccesta = regs.ccesta
                           AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                                  FROM tabvalces
                                                 WHERE ccesta = regs.ccesta
                                                   AND TRUNC(fvalor) <= TRUNC(v_pfvalmov));
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           iuniacts := 0;
                     END;
               END;
            ELSE
               -- Fin Bug 19312
               BEGIN
                  SELECT NVL(iuniact, 0)
                    INTO iuniacts
                    FROM tabvalces
                   WHERE ccesta = regs.ccesta
                     AND TRUNC(fvalor) = TRUNC(pfefecto);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                        SELECT NVL(iuniact, 0)
                          INTO iuniacts
                          FROM tabvalces
                         WHERE ccesta = regs.ccesta
                           AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                                  FROM tabvalces
                                                 WHERE ccesta = regs.ccesta
                                                   AND TRUNC(fvalor) <= TRUNC(pfefecto));
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           iuniacts := 0;
                     END;
               END;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.FF_PROVMAT', NULL,
                           'parametros: psseguro =' || psseguro || 'pfefecto =' || pfefecto,
                           SQLERRM);
               RETURN(NULL);
         END;

         v_provision := v_provision +(nparacts * iuniacts);
      END LOOP;

      v_provision := ROUND(v_provision, 2);
      RETURN(v_provision);
   END ff_provmat;

   FUNCTION ff_provshw(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      ppfefecto IN NUMBER,
      pnnumlin IN NUMBER DEFAULT NULL)   -- Bug 19312 - RSC - 24/11/2011
      RETURN NUMBER IS
      CURSOR cur_cesta(v_sseguro IN NUMBER) IS
         SELECT ccesta, pdistrec
           FROM segdisin2
          WHERE sseguro = v_sseguro
            AND ffin IS NULL
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM segdisin2
                            WHERE sseguro = v_sseguro
                              AND ffin IS NULL);

      nparacts       NUMBER;
      iuniacts       NUMBER;
      v_provision    NUMBER := 0;
      pfefecto       DATE;
      v_seguroini    estseguros.ssegpol%TYPE;
      -- Bug 19312 - RSC - 24/11/2011
      v_pfvalmov     DATE;
      -- Fin Bug 19312

      -- Bug 23455 - RSC - 05/09/2012 CRE800 - Càlcul capital de mort PPJ dinàmic
      v_origen       NUMBER;
   -- Fin Bug 23455
   BEGIN
      v_origen := NVL(pac_gfi.f_sgt_parms('ORIGEN', psesion), 0);

      IF v_origen = 2 THEN
         v_seguroini := psseguro;
      ELSIF v_origen = 1 THEN
         BEGIN
            SELECT ssegpol   -- Queremos el sseguro original
              INTO v_seguroini
              FROM estseguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               v_seguroini := psseguro;
         END;
      ELSE
         v_seguroini := psseguro;
      END IF;

      -- Fin Bug 23455
      pfefecto := TO_DATE(ppfefecto, 'yyyy/mm/dd');

      FOR regs IN cur_cesta(v_seguroini) LOOP
         BEGIN
            -- Bug 19312 - RSC - 24/11/2011
            IF pnnumlin IS NOT NULL THEN
               -- Query para obtener las participaciones acumuladas de la cesta
               SELECT NVL(SUM(nunidad), 0)
                 INTO nparacts
                 FROM ctaseguro_shadow
                WHERE sseguro = v_seguroini
                  AND cesta = regs.ccesta
                  AND nnumlin <= pnnumlin
                  AND((cestado <> '9')
                      OR(cestado = '9'
                         AND imovimi <> 0
                         AND imovimi IS NOT NULL));
            ELSE
               -- Fin Bug 19312

               -- Query para obtener las participaciones acumuladas de la cesta
               SELECT NVL(SUM(nunidad), 0)
                 INTO nparacts
                 FROM ctaseguro_shadow
                WHERE sseguro = v_seguroini
                  --and cmovimi <> 0
                  --AND cmovimi NOT IN(0, 91, 93, 94, 97)   -- Bug 10846 - RSC - 13/10/2009 - CRE - Operaciones con Fondos
                  AND cesta = regs.ccesta
                  -- bug 2312 - MDS - truncar las dos fechas
                  AND TRUNC(fvalmov) <= TRUNC(pfefecto)
                  AND((cestado <> '9')
                      OR(cestado = '9'
                         AND imovimi <> 0
                         AND imovimi IS NOT NULL));
            END IF;

            --PRECIO UNIDAD

            -- Bug 19312 - RSC - 24/11/2011
            IF pnnumlin IS NOT NULL THEN
               SELECT fvalmov
                 INTO v_pfvalmov
                 FROM ctaseguro_shadow
                WHERE sseguro = v_seguroini
                  AND nnumlin = pnnumlin;

               BEGIN
                  SELECT NVL(iuniactvtashw, 0)
                    INTO iuniacts
                    FROM tabvalces
                   WHERE ccesta = regs.ccesta
                     AND TRUNC(fvalor) = TRUNC(v_pfvalmov);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                        SELECT NVL(iuniactvtashw, 0)
                          INTO iuniacts
                          FROM tabvalces
                         WHERE ccesta = regs.ccesta
                           AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                                  FROM tabvalces
                                                 WHERE ccesta = regs.ccesta
                                                   AND TRUNC(fvalor) <= TRUNC(v_pfvalmov));
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           iuniacts := 0;
                     END;
               END;
            ELSE
               -- Fin Bug 19312
               BEGIN
                  SELECT NVL(iuniactvtashw, 0)
                    INTO iuniacts
                    FROM tabvalces
                   WHERE ccesta = regs.ccesta
                     AND TRUNC(fvalor) = TRUNC(pfefecto);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                        SELECT NVL(iuniactvtashw, 0)
                          INTO iuniacts
                          FROM tabvalces
                         WHERE ccesta = regs.ccesta
                           AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                                  FROM tabvalces
                                                 WHERE ccesta = regs.ccesta
                                                   AND TRUNC(fvalor) <= TRUNC(pfefecto));
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           iuniacts := 0;
                     END;
               END;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.FF_PROVSHW', NULL,
                           'parametros: psseguro =' || psseguro || 'pfefecto =' || pfefecto,
                           SQLERRM);
               RETURN(NULL);
         END;

         v_provision := v_provision +(nparacts * iuniacts);
      END LOOP;

      v_provision := ROUND(v_provision, 2);
      RETURN(v_provision);
   END ff_provshw;

   /*
     En Desarrollo: Función que determina el valor de provisión de la distribución existente a una determinada
     fecha. Es decir, en lugar de coger de segdisin2 la ultima distribución en este caso queremos coger
     la distribución de una fecha concreta i calcular los valores de esa distribución con valor
     liquidativo a esa fecha (consulta tabvalces a esa fecha)
   */
   FUNCTION ff_valor_provision_fecha(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      ppfefecto IN NUMBER)
      RETURN NUMBER IS
      CURSOR cur_cesta(pfefecto IN DATE) IS
         SELECT ccesta, pdistrec
           FROM segdisin2
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi
            AND ffin IS NULL;

      nparacts       NUMBER;
      iuniacts       NUMBER;
      v_provision    NUMBER := 0;
      pfefecto       DATE;
   BEGIN
      pfefecto := TO_DATE(ppfefecto, 'yyyy/mm/dd');

      FOR regs IN cur_cesta(pfefecto) LOOP
         BEGIN
            -- Query para obtener las participaciones acumuladas de la cesta
            -- !!!! ATENCION a la linea and trunc(fvalmov) <= trunc(pfefecto) !!!!
            SELECT NVL(SUM(nunidad), 0)
              INTO nparacts
              FROM ctaseguro
             WHERE sseguro = psseguro
               --and cmovimi <> 0
               --AND cmovimi NOT IN(0, 91, 93, 94, 97)   -- Bug 10846 - RSC - 13/10/2009 - CRE - Operaciones con Fondos
               AND cesta = regs.ccesta
               AND TRUNC(fvalmov) <= TRUNC(pfefecto)
               AND((cestado <> '9')
                   OR(cestado = '9'
                      AND imovimi <> 0
                      AND imovimi IS NOT NULL));

            --PRECIO UNIDAD
            BEGIN
               SELECT NVL(iuniact, 0)
                 INTO iuniacts
                 FROM tabvalces
                WHERE ccesta = regs.ccesta
                  AND TRUNC(fvalor) = TRUNC(pfefecto);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT NVL(iuniact, 0)
                       INTO iuniacts
                       FROM tabvalces
                      WHERE ccesta = regs.ccesta
                        AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                               FROM tabvalces
                                              WHERE ccesta = regs.ccesta
                                                AND TRUNC(fvalor) <= TRUNC(pfefecto));
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        iuniacts := 0;
                  END;
            END;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_valor_provisión', NULL,
                           'parametros: psseguro =' || psseguro || 'pfefecto =' || pfefecto,
                           SQLERRM);
               RETURN(NULL);
         END;

         v_provision := v_provision +(nparacts * iuniacts);
      END LOOP;

      v_provision := ROUND(v_provision, 2);
      RETURN(v_provision);
   END ff_valor_provision_fecha;

   /*
         SHADOW ACCOUNTS
      En Desarrollo: Función que determina el valor de provisión de la distribución existente a una determinada
      fecha. Es decir, en lugar de coger de segdisin2 la ultima distribución en este caso queremos coger
      la distribución de una fecha concreta i calcular los valores de esa distribución con valor
      liquidativo a esa fecha (consulta tabvalces a esa fecha)
    */
   FUNCTION ff_valor_provision_fecha_shw(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      ppfefecto IN NUMBER)
      RETURN NUMBER IS
      CURSOR cur_cesta(pfefecto IN DATE) IS
         SELECT ccesta, pdistrec
           FROM segdisin2
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi
            AND ffin IS NULL;

      nparacts       NUMBER;
      iuniacts       NUMBER;
      v_provision    NUMBER := 0;
      pfefecto       DATE;
   BEGIN
      pfefecto := TO_DATE(ppfefecto, 'yyyy/mm/dd');

      FOR regs IN cur_cesta(pfefecto) LOOP
         BEGIN
            -- Query para obtener las participaciones acumuladas de la cesta
            -- !!!! ATENCION a la linea and trunc(fvalmov) <= trunc(pfefecto) !!!!
            SELECT NVL(SUM(nunidad), 0)
              INTO nparacts
              FROM ctaseguro_shadow
             WHERE sseguro = psseguro
               --and cmovimi <> 0
               --AND cmovimi NOT IN(0, 91, 93, 94, 97)   -- Bug 10846 - RSC - 13/10/2009 - CRE - Operaciones con Fondos
               AND cesta = regs.ccesta
               AND TRUNC(fvalmov) <= TRUNC(pfefecto)
               AND((cestado <> '9')
                   OR(cestado = '9'
                      AND imovimi <> 0
                      AND imovimi IS NOT NULL));

            --PRECIO UNIDAD
            BEGIN
               SELECT NVL(iuniactvtashw, 0)
                 INTO iuniacts
                 FROM tabvalces
                WHERE ccesta = regs.ccesta
                  AND TRUNC(fvalor) = TRUNC(pfefecto);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT NVL(iuniactvtashw, 0)
                       INTO iuniacts
                       FROM tabvalces
                      WHERE ccesta = regs.ccesta
                        AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                               FROM tabvalces
                                              WHERE ccesta = regs.ccesta
                                                AND TRUNC(fvalor) <= TRUNC(pfefecto));
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        iuniacts := 0;
                  END;
            END;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_valor_provisión', NULL,
                           'parametros: psseguro =' || psseguro || 'pfefecto =' || pfefecto,
                           SQLERRM);
               RETURN(NULL);
         END;

         v_provision := v_provision +(nparacts * iuniacts);
      END LOOP;

      v_provision := ROUND(v_provision, 2);
      RETURN(v_provision);
   END ff_valor_provision_fecha_shw;

   FUNCTION f_gastos_gestion_anual(
      psseguro IN NUMBER,
      v_provision IN NUMBER,
      ggesanual IN OUT NUMBER)
      RETURN NUMBER IS
      v_gasges       NUMBER;
      p_pgasto       NUMBER;
      pimaximo       NUMBER;
      piminimo       NUMBER;
   BEGIN
      BEGIN
         SELECT cgasges
           INTO v_gasges
           FROM seguros_ulk
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_gastos_gestion_anual', NULL,
                        'parametros: psseguro =' || psseguro || ' v_provision ='
                        || v_provision,
                        SQLERRM);
            RETURN(108190);
      -- Cambiar por gasto de gestion no definido para la póliza
      END;

      BEGIN
         SELECT pgasto, imaximo, iminimo
           INTO p_pgasto, pimaximo, piminimo
           FROM detgastos_ulk
          WHERE ffinvig IS NULL
            AND cgasto = v_gasges;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_gastos_gestion_anual', NULL,
                        'parametros: psseguro =' || psseguro || ' v_provision ='
                        || v_provision,
                        SQLERRM);
            RETURN(108190);   -- detalle de gasto no definido. Error general?
      END;

      IF (v_provision *(p_pgasto / 100)) < piminimo THEN
         ggesanual := piminimo;
      ELSIF(v_provision *(p_pgasto / 100)) >= pimaximo THEN
         ggesanual := pimaximo;
      ELSE
         ggesanual := v_provision *(p_pgasto / 100);
      END IF;

      RETURN(0);
   END f_gastos_gestion_anual;

   FUNCTION f_cta_gastos_gestion(
      psseguro IN NUMBER,
      ppfefecto IN DATE,
      pmodo IN VARCHAR2,
      pcmovimi IN NUMBER,
      pnrecibo IN NUMBER DEFAULT NULL,
      pnsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      CURSOR cur_cesta IS
         SELECT ccesta, pdistrec
           FROM segdisin2
          WHERE sseguro = psseguro
            AND ffin IS NULL
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM segdisin2
                            WHERE sseguro = psseguro
                              AND ffin IS NULL);

      ggesmensual    NUMBER := 0;
      nnumlin        NUMBER;
      iuniacts       NUMBER;
      xnnumlin       NUMBER;
      imovimo        NUMBER;
      v_provision    NUMBER;
      ggesanual      NUMBER;
      num_err        NUMBER;
      pfefecto       DATE;
      ntraza         NUMBER := 0;
      --09/01/2008 RSC
      v_sproduc      NUMBER;
      -- RSC 28/01/2008
      vacumpercent   NUMBER := 0;
      vacumrounded   NUMBER := 0;
      -- RSC 06/11/2008
      vpgastoges     NUMBER;
      -- RSC 09/12/2008 Tarea 8407
      vfsysdate      DATE;
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      --
      v_gastosext    ctaseguro.imovimi%TYPE;
      v_gastosint    ctaseguro.imovimi%TYPE;
      v_fecha        DATE;
      v_ahorro_prepagable NUMBER;
      v_seqgrupo     NUMBER;
   --
   BEGIN
      -- RSC 09/12/2008 Tarea 8407
      vfsysdate := f_sysdate;

      -- Obtebemos la sequence para la agrupación (82-83)
      SELECT scagrcta.NEXTVAL
        INTO v_seqgrupo
        FROM DUAL;

      -- Buscamos en la tabla SEGUROS la empresa y el producto
      SELECT sproduc, cempres
        INTO v_sproduc, v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);
      v_ahorro_prepagable := NVL(f_parproductos_v(v_sproduc, 'AHORRO_PREPAGABLE'), 0);

      IF v_ahorro_prepagable = 1
         AND pcmovimi = 0 THEN
         v_fecha := ppfefecto + 1;
      ELSE
         -- Si NO es prepagable y no es el cierre se graba la fecha de entrada.
         v_fecha := ppfefecto;
      END IF;

      --
      -- DETGASTOS_ULK (gastos de gestión) ahora se formula, si se desea utilizar el % definido
      -- tendrá que ser en la formula.
      --
      v_gastosext := f_round_moneda(pac_provmat_formul.f_calcul_formulas_provi(psseguro,
                                                                               v_fecha,
                                                                               'IGASEXT', NULL,
                                                                               NULL, 1, NULL,
                                                                               NULL, pnrecibo,
                                                                               pnsinies));

      --
      IF v_gastosext IS NULL THEN
         v_gastosext := 0;
      END IF;

      --
      v_gastosint := f_round_moneda(pac_provmat_formul.f_calcul_formulas_provi(psseguro,
                                                                               v_fecha,
                                                                               'IGASINT', NULL,
                                                                               NULL, 1, NULL,
                                                                               NULL, pnrecibo,
                                                                               pnsinies));

      --
      IF v_gastosint IS NULL THEN
         v_gastosint := 0;
      END IF;

      --
      ggesmensual := v_gastosext + v_gastosint;

            --
            -- Si no hay gastos salimos
            --
          /*  IF NVL(ggesmensual, 0) = 0 THEN
               RETURN 0;
            END IF;

            -- Insertamos el movimiento general gastos y se desglosa la parte interna y externa(comision)
            num_err := pac_ctaseguro.f_insctaseguro(psseguro, vfsysdate, NULL, v_fecha, v_fecha, 82,
                                                    ggesmensual, NULL, NULL, v_seqgrupo, 0, NULL,
                                                    NULL, NULL, pmodo, NULL, NULL, NULL, NULL, NULL,
                                                    v_gastosext, v_gastosint, NULL);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
      --ACL
      */
      IF NVL(f_parproductos_v(v_sproduc, 'SEPARA_GASTOSGESTION'), 0) = 1 THEN
         --IF SEPARA_GASTOSGESTION = 1 THEN
         ntraza := 2;
         /* La idea es que a la nueva función 'f_ins_detalle_gasto' no le pasaremos ggesmensual igual a 'v_gastosext + v_gastosint',
         sino que primero le pasaremos v_gastosext y luego se volverá a llamar a la misma función, pero pasandole v_gastosint:
         */
         num_err := pac_operativa_finv.f_ins_detalle_gasto(psseguro, v_fecha, vfsysdate, NULL,
                                                           v_fecha, v_fecha, 82, NULL, NULL,
                                                           NULL, v_seqgrupo, 0, NULL, NULL,
                                                           NULL, pmodo, NULL, NULL, NULL,
                                                           NULL, NULL, v_gastosext, NULL,
                                                           NULL);
         num_err := pac_operativa_finv.f_ins_detalle_gasto(psseguro, v_fecha, vfsysdate, NULL,
                                                           v_fecha, v_fecha, 82, NULL, NULL,
                                                           NULL, v_seqgrupo, 0, NULL, NULL,
                                                           NULL, pmodo, NULL, NULL, NULL,
                                                           NULL, NULL, NULL, v_gastosint,
                                                           NULL);
      ELSE   -- SEPARA_GASTOSGESTION = 0
         ntraza := 3;
         num_err := pac_operativa_finv.f_ins_detalle_gasto(psseguro, v_fecha, vfsysdate, NULL,
                                                           v_fecha, v_fecha, 82, ggesmensual,
                                                           NULL, NULL, v_seqgrupo, 0, NULL,
                                                           NULL, NULL, pmodo, NULL, NULL,
                                                           NULL, NULL, NULL, v_gastosext,
                                                           v_gastosint, NULL);

         --ACL
         FOR regs IN cur_cesta LOOP
            ntraza := 5;

            -- obtenemos el numero de linia siguiente
            BEGIN
               IF pmodo = 'R' THEN
                  ntraza := 3;

                  SELECT NVL(MAX(nnumlin) + 1, 1)
                    INTO xnnumlin
                    FROM ctaseguro
                   WHERE sseguro = psseguro;
               ELSIF pmodo = 'P' THEN
                  ntraza := 4;

                  SELECT NVL(MAX(nnumlin) + 1, 1)
                    INTO xnnumlin
                    FROM ctaseguro_previo
                   WHERE sseguro = psseguro;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 104882;   -- Error al llegir de CTASEGURO
            END;

            BEGIN
               -- RSC 18/03/2008 (ultimo valor lo cogemos de tabvalces)
               -- Tarea 31548/206135 Management expenses
               SELECT NVL(iuniact, 0)
                 INTO iuniacts
                 FROM tabvalces
                WHERE ccesta = regs.ccesta
                  AND TRUNC(fvalor) = v_fecha + pac_md_fondos.f_get_diasdep(regs.ccesta);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  p_tab_error
                        (f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_cta_gastos_gestion', ntraza,
                         'No hay valor liquidativo para la fecha. parametros: psseguro = '
                         || psseguro || ' ppfefecto=' || ppfefecto || ' v_sproduc='
                         || v_sproduc || ' pmodo=' || pmodo || ' pcmovimi=' || pcmovimi
                         || ' v_fecha=' || v_fecha,
                         SQLERRM, 50);
                  iuniacts := 0;
            END;

            --
            --Calcula les distribucions
            vacumpercent := vacumpercent + (ggesmensual * regs.pdistrec) / 100;
            imovimo := ROUND(vacumpercent - vacumrounded, 2);
            vacumrounded := vacumrounded + ROUND(vacumpercent - vacumrounded, 2);

            --
            IF NVL(iuniacts, 0) = 0 THEN
               num_err := pac_ctaseguro.f_insctaseguro(psseguro, vfsysdate, NULL, v_fecha,
                                                       v_fecha, 83, imovimo, NULL, NULL,
                                                       v_seqgrupo, 0, NULL, NULL, '1', pmodo,
                                                       NULL, NULL, NULL, NULL, NULL, NULL,
                                                       NULL, NULL, regs.ccesta);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            ELSE
               BEGIN
                  IF pmodo = 'R' THEN
                     ntraza := 6;

                     INSERT INTO ctaseguro
                                 (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi,
                                  imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies,
                                  smovrec, cesta, nunidad, cestado, fasign)
                          VALUES (psseguro, vfsysdate, xnnumlin, v_fecha, v_fecha, 83,
                                  imovimo, NULL, NULL, v_seqgrupo, 0, NULL,
                                  NULL, regs.ccesta, -1 *(imovimo / iuniacts), '2', vfsysdate);

                     -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     IF v_cmultimon = 1 THEN
                        num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro,
                                                                              vfsysdate,
                                                                              xnnumlin,
                                                                              v_fecha);

                        IF num_err <> 0 THEN
                           p_tab_error(f_sysdate, f_user,
                                       'PAC_OPERATIVA_FINV.f_cta_gastos_gestion', ntraza,
                                       'parametros: psseguro = ' || psseguro || ' ppfefecto='
                                       || ppfefecto || ' v_sproduc=' || v_sproduc || ' pmodo='
                                       || pmodo || ' pcmovimi=' || pcmovimi || ' v_fecha='
                                       || v_fecha,
                                       SQLERRM);
                           RETURN num_err;
                        END IF;
                     END IF;

                     -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     xnnumlin := xnnumlin + 1;
                  ELSIF pmodo = 'P' THEN
                     ntraza := 7;

                     INSERT INTO ctaseguro_previo
                                 (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi,
                                  imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies,
                                  smovrec, cesta, nunidad, cestado, fasign)
                          VALUES (psseguro, vfsysdate, xnnumlin, v_fecha, v_fecha, 83,
                                  imovimo, NULL, NULL, v_seqgrupo, 0, NULL,
                                  NULL, regs.ccesta, -1 *(imovimo / iuniacts), '2', vfsysdate);

                     xnnumlin := xnnumlin + 1;
                  END IF;
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_cta_gastos_gestion',
                                 ntraza,
                                 'parametros: psseguro = ' || psseguro || ' ppfefecto='
                                 || ppfefecto || ' v_sproduc=' || v_sproduc || ' pmodo='
                                 || pmodo || ' pcmovimi=' || pcmovimi || ' v_fecha='
                                 || v_fecha,
                                 SQLERRM);
                     RETURN 104879;   -- Registre duplicat a CTASEGURO
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_cta_gastos_gestion',
                                 ntraza,
                                 'parametros: psseguro = ' || psseguro || ' ppfefecto='
                                 || ppfefecto || ' v_sproduc=' || v_sproduc || ' pmodo='
                                 || pmodo || ' pcmovimi=' || pcmovimi || ' v_fecha='
                                 || v_fecha,
                                 SQLERRM);
                     RETURN 102555;   -- Error al insertar a la taula CTASEGURO
               END;
            --
            END IF;
         --
         END LOOP;
      END IF;

      --
      RETURN(0);
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_cta_gastos_gestion', ntraza,
                     'parametros: psseguro = ' || psseguro || ' ppfefecto=' || ppfefecto
                     || ' v_sproduc=' || v_sproduc || ' pmodo=' || pmodo || ' pcmovimi='
                     || pcmovimi || ' v_fecha=' || v_fecha,
                     SQLERRM);
         RETURN 102555;   -- Error al insertar a la taula CTASEGURO
   END f_cta_gastos_gestion;

   FUNCTION f_cta_gastos_gestion_shw(
      psseguro IN NUMBER,
      ppfefecto IN DATE,
      pmodo IN VARCHAR2,
      pcmovimi IN NUMBER,
      pnrecibo IN NUMBER DEFAULT NULL,
      pnsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      CURSOR cur_cesta IS
         SELECT ccesta, pdistrec
           FROM segdisin2
          WHERE sseguro = psseguro
            AND ffin IS NULL
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM segdisin2
                            WHERE sseguro = psseguro
                              AND ffin IS NULL);

      ggesmensual    NUMBER := 0;
      nnumlin        NUMBER;
      iuniacts       NUMBER;
      xnnumlin       NUMBER;
      imovimo        NUMBER;
      v_provision    NUMBER;
      ggesanual      NUMBER;
      num_err        NUMBER;
      pfefecto       DATE;
      ntraza         NUMBER := 0;
      --09/01/2008 RSC
      v_sproduc      NUMBER;
      -- RSC 28/01/2008
      vacumpercent   NUMBER := 0;
      vacumrounded   NUMBER := 0;
      -- RSC 06/11/2008
      vpgastoges     NUMBER;
      -- RSC 09/12/2008 Tarea 8407
      vfsysdate      DATE;
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      --
      v_gastosext    ctaseguro_shadow.imovimi%TYPE;
      v_gastosint    ctaseguro_shadow.imovimi%TYPE;
      v_fecha        DATE;
      v_ahorro_prepagable NUMBER;
      v_seqgrupo     NUMBER;
   --
   BEGIN
      -- RSC 09/12/2008 Tarea 8407
      vfsysdate := f_sysdate;

      -- Obtebemos la sequence para la agrupación (82-83)
      SELECT scagrcta.NEXTVAL
        INTO v_seqgrupo
        FROM DUAL;

      -- Buscamos en la tabla SEGUROS la empresa y el producto
      SELECT sproduc, cempres
        INTO v_sproduc, v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);
      v_ahorro_prepagable := NVL(f_parproductos_v(v_sproduc, 'AHORRO_PREPAGABLE'), 0);

      IF v_ahorro_prepagable = 1
         AND pcmovimi = 0 THEN
         v_fecha := ppfefecto + 1;
      ELSE
         -- Si NO es prepagable y no es el cierre se graba la fecha de entrada.
         v_fecha := ppfefecto;
      END IF;

      --
      -- DETGASTOS_ULK (gastos de gestión) ahora se formula, si se desea utilizar el % definido
      -- tendrá que ser en la formula.
      --
      v_gastosext := pac_provmat_formul.f_calcul_formulas_provi(psseguro, v_fecha, 'IGASESHW',
                                                                NULL, NULL, 1, NULL, NULL,
                                                                pnrecibo, pnsinies);

      --
      IF v_gastosext IS NULL THEN
         v_gastosext := 0;
      END IF;

      --
      v_gastosint := pac_provmat_formul.f_calcul_formulas_provi(psseguro, v_fecha, 'IGASISHW',
                                                                NULL, NULL, 1, NULL, NULL,
                                                                pnrecibo, pnsinies);

      --
      IF v_gastosint IS NULL THEN
         v_gastosint := 0;
      END IF;

      --
      ggesmensual := v_gastosext + v_gastosint;

            --
            -- Si no hay gastos salimos
            --
          /*  IF NVL(ggesmensual, 0) = 0 THEN
               RETURN 0;
            END IF;

            -- Insertamos el movimiento general gastos y se desglosa la parte interna y externa(comision)
            num_err := pac_ctaseguro.f_insctaseguro_shw(psseguro, vfsysdate, NULL, v_fecha, v_fecha,
                                                        82, ggesmensual, NULL, NULL, v_seqgrupo, 0,
                                                        NULL, NULL, NULL, pmodo, NULL, NULL, NULL,
                                                        NULL, NULL, v_gastosext, v_gastosint, NULL);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
      */
         --ACL
      IF NVL(f_parproductos_v(v_sproduc, 'SEPARA_GASTOSGESTION'), 0) = 1 THEN
         --IF SEPARA_GASTOSGESTION = 1 THEN
         ntraza := 2;
         /* La idea es que a la nueva función 'f_ins_detalle_gasto' no le pasaremos ggesmensual igual a 'v_gastosext + v_gastosint',
         sino que primero le pasaremos v_gastosext y luego se volverá a llamar a la misma función, pero pasandole v_gastosint:
         */
         num_err := pac_operativa_finv.f_ins_detalle_gasto_shw(psseguro, v_fecha, vfsysdate,
                                                               NULL, v_fecha, v_fecha, 82,
                                                               NULL, NULL, NULL, v_seqgrupo,
                                                               0, NULL, NULL, NULL, pmodo,
                                                               NULL, NULL, NULL, NULL, NULL,
                                                               v_gastosext, NULL, NULL);
         num_err := pac_operativa_finv.f_ins_detalle_gasto_shw(psseguro, v_fecha, vfsysdate,
                                                               NULL, v_fecha, v_fecha, 82,
                                                               NULL, NULL, NULL, v_seqgrupo,
                                                               0, NULL, NULL, NULL, pmodo,
                                                               NULL, NULL, NULL, NULL, NULL,
                                                               NULL, v_gastosint, NULL);
      ELSE   -- SEPARA_GASTOSGESTION = 0
         ntraza := 3;
         num_err := pac_operativa_finv.f_ins_detalle_gasto_shw(psseguro, v_fecha, vfsysdate,
                                                               NULL, v_fecha, v_fecha, 82,
                                                               ggesmensual, NULL, NULL,
                                                               v_seqgrupo, 0, NULL, NULL,
                                                               NULL, pmodo, NULL, NULL, NULL,
                                                               NULL, NULL, v_gastosext,
                                                               v_gastosint, NULL);

         --ACL

         --
         FOR regs IN cur_cesta LOOP
            ntraza := 5;

            --
                -- obtenemos el numero de linia siguiente
            BEGIN
               IF pmodo = 'R' THEN
                  ntraza := 3;

                  SELECT NVL(MAX(nnumlin) + 1, 1)
                    INTO xnnumlin
                    FROM ctaseguro_shadow
                   WHERE sseguro = psseguro;
               ELSIF pmodo = 'P' THEN
                  ntraza := 4;

                  SELECT NVL(MAX(nnumlin) + 1, 1)
                    INTO xnnumlin
                    FROM ctaseguro_previo_shw
                   WHERE sseguro = psseguro;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 104882;   -- Error al llegir de CTASEGURO
            END;

            BEGIN
               -- RSC 18/03/2008 (ultimo valor lo cogemos de tabvalces)
               -- Tarea 31548/206135 Management expenses
               SELECT NVL(iuniactvtashw, 0)
                 INTO iuniacts
                 FROM tabvalces
                WHERE ccesta = regs.ccesta
                  AND TRUNC(fvalor) = v_fecha + pac_md_fondos.f_get_diasdep(regs.ccesta);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  p_tab_error
                        (f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_cta_gastos_gestion_shw',
                         ntraza,
                         'No hay valor liquidativo para la fecha. parametros: psseguro = '
                         || psseguro || ' ppfefecto=' || ppfefecto || ' v_sproduc='
                         || v_sproduc || ' pmodo=' || pmodo || ' pcmovimi=' || pcmovimi
                         || ' v_fecha=' || v_fecha,
                         SQLERRM, 50);
                  iuniacts := 0;
            END;

            --
            --Calcula les distribucions
            vacumpercent := vacumpercent + (ggesmensual * regs.pdistrec) / 100;
            imovimo := ROUND(vacumpercent - vacumrounded, 2);
            vacumrounded := vacumrounded + ROUND(vacumpercent - vacumrounded, 2);

            --
            IF NVL(iuniacts, 0) = 0 THEN
               num_err := pac_ctaseguro.f_insctaseguro_shw(psseguro, vfsysdate, NULL, v_fecha,
                                                           v_fecha, 83, imovimo, NULL, NULL,
                                                           v_seqgrupo, 0, NULL, NULL, '1',
                                                           pmodo, NULL, NULL, NULL, NULL,
                                                           NULL, NULL, NULL, NULL,
                                                           regs.ccesta);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            ELSE
               BEGIN
                  IF pmodo = 'R' THEN
                     ntraza := 6;

                     INSERT INTO ctaseguro_shadow
                                 (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi,
                                  imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies,
                                  smovrec, cesta, nunidad, cestado, fasign)
                          VALUES (psseguro, vfsysdate, xnnumlin, v_fecha, v_fecha, 83,
                                  imovimo, NULL, NULL, v_seqgrupo, 0, NULL,
                                  NULL, regs.ccesta, -1 *(imovimo / iuniacts), '2', vfsysdate);

                     -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     IF v_cmultimon = 1 THEN
                        num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro,
                                                                                  vfsysdate,
                                                                                  xnnumlin,
                                                                                  v_fecha);

                        IF num_err <> 0 THEN
                           p_tab_error(f_sysdate, f_user,
                                       'PAC_OPERATIVA_FINV.f_cta_gastos_gestion_shw', ntraza,
                                       'parametros: psseguro = ' || psseguro || ' ppfefecto='
                                       || ppfefecto || ' v_sproduc=' || v_sproduc || ' pmodo='
                                       || pmodo || ' pcmovimi=' || pcmovimi || ' v_fecha='
                                       || v_fecha,
                                       SQLERRM);
                           RETURN num_err;
                        END IF;
                     END IF;

                     -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     xnnumlin := xnnumlin + 1;
                  ELSIF pmodo = 'P' THEN
                     ntraza := 7;

                     INSERT INTO ctaseguro_previo_shw
                                 (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi,
                                  imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies,
                                  smovrec, cesta, nunidad, cestado, fasign)
                          VALUES (psseguro, vfsysdate, xnnumlin, v_fecha, v_fecha, 83,
                                  imovimo, NULL, NULL, v_seqgrupo, 0, NULL,
                                  NULL, regs.ccesta, -1 *(imovimo / iuniacts), '2', vfsysdate);

                     xnnumlin := xnnumlin + 1;
                  END IF;
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     p_tab_error(f_sysdate, f_user,
                                 'PAC_OPERATIVA_FINV.f_cta_gastos_gestion_shw', ntraza,
                                 'parametros: psseguro = ' || psseguro || ' ppfefecto='
                                 || ppfefecto || ' v_sproduc=' || v_sproduc || ' pmodo='
                                 || pmodo || ' pcmovimi=' || pcmovimi || ' v_fecha='
                                 || v_fecha,
                                 SQLERRM);
                     RETURN 104879;   -- Registre duplicat a CTASEGURO
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user,
                                 'PAC_OPERATIVA_FINV.f_cta_gastos_gestion_shw', ntraza,
                                 'parametros: psseguro = ' || psseguro || ' ppfefecto='
                                 || ppfefecto || ' v_sproduc=' || v_sproduc || ' pmodo='
                                 || pmodo || ' pcmovimi=' || pcmovimi || ' v_fecha='
                                 || v_fecha,
                                 SQLERRM);
                     RETURN 102555;   -- Error al insertar a la taula CTASEGURO
               END;
            --
            END IF;
         --
         END LOOP;
      END IF;

      --
      RETURN(0);
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_cta_gastos_gestion_shw', ntraza,
                     'parametros: psseguro = ' || psseguro || ' ppfefecto=' || ppfefecto
                     || ' v_sproduc=' || v_sproduc || ' pmodo=' || pmodo || ' pcmovimi='
                     || pcmovimi || ' v_fecha=' || v_fecha,
                     SQLERRM);
         RETURN 102555;   -- Error al insertar a la taula CTASEGURO
   END f_cta_gastos_gestion_shw;

   FUNCTION f_cta_gastos_scobertura(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      psproduc IN NUMBER,
      pmodo IN VARCHAR2,
      pcmovimi IN NUMBER,
      pipririe IN NUMBER DEFAULT NULL,
      pnrecibo IN NUMBER DEFAULT NULL,
      pnsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      CURSOR cur_cesta IS
         SELECT ccesta, pdistrec
           FROM segdisin2
          WHERE sseguro = psseguro
            AND ffin IS NULL
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM segdisin2
                            WHERE sseguro = psseguro
                              AND ffin IS NULL);

      nnumlin        NUMBER;
      iuniacts       NUMBER;
      xnnumlin       NUMBER;
      num_err        NUMBER;
      resultado      NUMBER := 0;
      imovimo        NUMBER;
      ntraza         NUMBER := 0;
      v_sproduc      NUMBER;
      capgar         NUMBER;
      capgar2        NUMBER;
      vcontaseg      NUMBER := 0;
      -- RSC 28/01/2008
      vacumpercent   NUMBER := 0;
      vacumrounded   NUMBER := 0;
      -- RSC 09/12/2008 Tarea 8407
      vfsysdate      DATE;
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      v_ahorro_prepagable NUMBER;
      v_fecha        DATE;
      v_seqgrupo     NUMBER;
   --
   BEGIN
      ntraza := 1;
      vfsysdate := f_sysdate;

      -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
      SELECT sproduc, cempres
        INTO v_sproduc, v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      ntraza := 2;

      -- Si nos llega el producto a NULL lo cogemos de la tabla SEGUROS
      IF psproduc IS NOT NULL THEN
         v_sproduc := psproduc;
      END IF;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);
      v_ahorro_prepagable := NVL(f_parproductos_v(v_sproduc, 'AHORRO_PREPAGABLE'), 0);
      ntraza := 3;

      IF v_ahorro_prepagable = 1
         AND pcmovimi = 0 THEN
         v_fecha := pfefecto + 1;
      ELSE
         -- Si NO es prepagable y no es el cierre se graba la fecha de entrada.
         v_fecha := pfefecto;
      END IF;

      -- Obtebemos la sequence para la agrupación (21-84)
      SELECT scagrcta.NEXTVAL
        INTO v_seqgrupo
        FROM DUAL;

      ntraza := 4;

      IF NVL(f_parproductos_v(v_sproduc, 'PRODUCTO_MIXTO'), 0) = 1 THEN
         RETURN 0;
      END IF;

        -- AND NVL(f_parproductos_v(v_sproduc, 'USA_EDAD_CFALLAC'), 0) <> 1 THEN   -- Si es Ibex 35 Garantizado o
                                                                                 --       Ibex 35 no lo aplicamos
      -- AFM Prima de riesgo
      IF pipririe IS NULL THEN
         resultado := f_round_moneda(pac_provmat_formul.f_calcul_formulas_provi(psseguro,
                                                                                v_fecha,
                                                                                'IPRIRIE',
                                                                                NULL, NULL, 1,
                                                                                NULL, NULL,
                                                                                pnrecibo,
                                                                                pnsinies));
      ELSE
         resultado := NVL(pipririe, 0);
      END IF;

      ntraza := 5;

      --
      -- Si no hay prima de riesgo salimos
      --
      IF NVL(resultado, 0) = 0 THEN
         RETURN 0;
      END IF;

      -- Insertamos el movimiento general de Compra por redistribución
      num_err := pac_ctaseguro.f_insctaseguro(psseguro, vfsysdate, NULL, v_fecha, v_fecha, 21,
                                              resultado, NULL, NULL, v_seqgrupo, 0, NULL, NULL,
                                              NULL, pmodo);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      ntraza := 6;

      --
      -- obtenemos el numero de linia siguiente
      BEGIN
         IF pmodo = 'R' THEN
            ntraza := 7;

            SELECT NVL(MAX(nnumlin) + 1, 1)
              INTO xnnumlin
              FROM ctaseguro
             WHERE sseguro = psseguro;
         ELSIF pmodo = 'P' THEN
            ntraza := 8;

            SELECT NVL(MAX(nnumlin) + 1, 1)
              INTO xnnumlin
              FROM ctaseguro_previo
             WHERE sseguro = psseguro;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 104882;   -- Error al llegir de CTASEGURO
      END;

      --
      FOR regs IN cur_cesta LOOP
         --Valor participación de la cesta
         ntraza := 9;

         BEGIN
            -- Último valor liquidativo del fondo
            -- Tarea 31548/206135 Management expenses
            SELECT NVL(iuniact, 0)
              INTO iuniacts
              FROM tabvalces
             WHERE ccesta = regs.ccesta
               AND TRUNC(fvalor) = v_fecha + pac_md_fondos.f_get_diasdep(regs.ccesta);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               p_tab_error
                         (f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_cta_gastos_scobertura',
                          ntraza,
                          'No hay valor liquidativo para la fecha. Parametros: psseguro ='
                          || psseguro || ' v_fecha =' || v_fecha || ' psproduc =' || psproduc
                          || ' pmodo =' || pmodo,
                          SQLERRM, 50);
               iuniacts := 0;
         END;

         --
         -- Calcula las distribuciones
         --
         vacumpercent := vacumpercent + (resultado * regs.pdistrec) / 100;
         imovimo := ROUND(vacumpercent - vacumrounded, 2);
         vacumrounded := vacumrounded + ROUND(vacumpercent - vacumrounded, 2);
         --
         ntraza := 10;

         IF NVL(iuniacts, 0) = 0 THEN
            num_err := pac_ctaseguro.f_insctaseguro(psseguro, vfsysdate, NULL, v_fecha,
                                                    v_fecha, 84, imovimo, NULL, NULL,
                                                    v_seqgrupo, 0, NULL, NULL, '1', pmodo,
                                                    NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                    NULL, regs.ccesta);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         ELSE
            -- cmovimi 84 = Gasto Prima Riesgo = Gasto de Seguro de Cobertura
            BEGIN
               IF pmodo = 'R' THEN
                  ntraza := 11;

                  INSERT INTO ctaseguro
                              (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                               imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec, cesta,
                               nunidad, cestado, fasign)
                       VALUES (psseguro, vfsysdate, xnnumlin, v_fecha, v_fecha, 84, imovimo,
                               NULL, NULL, v_seqgrupo, 0, NULL, NULL, regs.ccesta,
                               -1 *(imovimo / iuniacts), '2', vfsysdate);

                  -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  IF v_cmultimon = 1 THEN
                     ntraza := 12;
                     num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro,
                                                                           vfsysdate,
                                                                           xnnumlin, v_fecha);

                     IF num_err <> 0 THEN
                        p_tab_error(f_sysdate, f_user,
                                    'PAC_OPERATIVA_FINV.f_cta_gastos_scobertura', ntraza,
                                    'parametros: psseguro =' || psseguro || ' pfefecto ='
                                    || pfefecto || ' pmodo =' || pmodo || ' v_fecha ='
                                    || v_fecha || ' psproduc =' || psproduc,
                                    SQLERRM);
                        RETURN num_err;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  xnnumlin := xnnumlin + 1;
               ELSIF pmodo = 'P' THEN
                  ntraza := 13;

                  INSERT INTO ctaseguro_previo
                              (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                               imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec, cesta,
                               nunidad, cestado, fasign)
                       VALUES (psseguro, vfsysdate, xnnumlin, v_fecha, v_fecha, 84, imovimo,
                               NULL, NULL, v_seqgrupo, 0, NULL, NULL, regs.ccesta,
                               -1 *(imovimo / iuniacts), '2', vfsysdate);

                  xnnumlin := xnnumlin + 1;
               END IF;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_cta_gastos_scobertura',
                              ntraza,
                              'parametros: psseguro = ' || psseguro || ' pfefecto='
                              || pfefecto || ' psproduc=' || psproduc || ' pmodo=' || pmodo
                              || ' pcmovimi=' || pcmovimi || ' pipririe=' || pipririe
                              || ' v_fecha=' || v_fecha,
                              SQLERRM);
                  RETURN 104879;   -- Registre duplicat a CTASEGURO
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_cta_gastos_scobertura',
                              ntraza,
                              'parametros: psseguro = ' || psseguro || ' pfefecto='
                              || pfefecto || ' psproduc=' || psproduc || ' pmodo=' || pmodo
                              || ' pcmovimi=' || pcmovimi || ' pipririe=' || pipririe
                              || ' v_fecha=' || v_fecha,
                              SQLERRM);
                  RETURN 102555;   -- Error al insertar a la taula CTASEGURO
            END;
         --
         END IF;
      --
      END LOOP;

      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_cta_gastos_scobertura', ntraza,
                     'parametros: psseguro = ' || psseguro || ' pfefecto=' || pfefecto
                     || ' psproduc=' || psproduc || ' pmodo=' || pmodo || ' pcmovimi='
                     || pcmovimi || ' pipririe=' || pipririe || ' v_fecha=' || v_fecha,
                     SQLERRM);
         RETURN 102555;   -- Error al insertar a la taula CTASEGURO
   END f_cta_gastos_scobertura;

   FUNCTION f_cta_gastos_scobertura_shw(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      psproduc IN NUMBER,
      pmodo IN VARCHAR2,
      pcmovimi IN NUMBER,
      pipririe IN NUMBER DEFAULT NULL,
      pnrecibo IN NUMBER DEFAULT NULL,
      pnsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      CURSOR cur_cesta IS
         SELECT ccesta, pdistrec
           FROM segdisin2
          WHERE sseguro = psseguro
            AND ffin IS NULL
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM segdisin2
                            WHERE sseguro = psseguro
                              AND ffin IS NULL);

      nnumlin        NUMBER;
      iuniacts       NUMBER;
      xnnumlin       NUMBER;
      num_err        NUMBER;
      resultado      NUMBER := 0;
      imovimo        NUMBER;
      ntraza         NUMBER := 0;
      v_sproduc      NUMBER;
      capgar         NUMBER;
      capgar2        NUMBER;
      vcontaseg      NUMBER := 0;
      -- RSC 28/01/2008
      vacumpercent   NUMBER := 0;
      vacumrounded   NUMBER := 0;
      -- RSC 09/12/2008 Tarea 8407
      vfsysdate      DATE;
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      v_ahorro_prepagable NUMBER;
      v_fecha        DATE;
      v_seqgrupo     NUMBER;
   --
   BEGIN
      ntraza := 1;
      vfsysdate := f_sysdate;

      -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
      SELECT sproduc, cempres
        INTO v_sproduc, v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      ntraza := 2;

      -- Si nos llega el producto a NULL lo cogemos de la tabla SEGUROS
      IF psproduc IS NOT NULL THEN
         v_sproduc := psproduc;
      END IF;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);
      v_ahorro_prepagable := NVL(f_parproductos_v(v_sproduc, 'AHORRO_PREPAGABLE'), 0);
      ntraza := 3;

      IF v_ahorro_prepagable = 1
         AND pcmovimi = 0 THEN
         v_fecha := pfefecto + 1;
      ELSE
         -- Si NO es prepagable y no es el cierre se graba la fecha de entrada.
         v_fecha := pfefecto;
      END IF;

      -- Obtebemos la sequence para la agrupación (21-84)
      SELECT scagrcta.NEXTVAL
        INTO v_seqgrupo
        FROM DUAL;

      ntraza := 4;

      IF NVL(f_parproductos_v(v_sproduc, 'PRODUCTO_MIXTO'), 0) = 1 THEN
         RETURN 0;
      END IF;

        -- AND NVL(f_parproductos_v(v_sproduc, 'USA_EDAD_CFALLAC'), 0) <> 1 THEN   -- Si es Ibex 35 Garantizado o
                                                                                 --       Ibex 35 no lo aplicamos
      -- AFM Prima de riesgo
      IF pipririe IS NULL THEN
         resultado := pac_provmat_formul.f_calcul_formulas_provi(psseguro, v_fecha,
                                                                 'IPRIRSHW', NULL, NULL, 1,
                                                                 NULL, NULL, pnrecibo,
                                                                 pnsinies);
      ELSE
         resultado := NVL(pipririe, 0);
      END IF;

      ntraza := 5;

      --
      -- Si no hay prima de riesgo salimos
      --
      IF NVL(resultado, 0) = 0 THEN
         RETURN 0;
      END IF;

      -- Insertamos el movimiento general de Compra por redistribución
      num_err := pac_ctaseguro.f_insctaseguro_shw(psseguro, vfsysdate, NULL, v_fecha, v_fecha,
                                                  21, resultado, NULL, NULL, v_seqgrupo, 0,
                                                  NULL, NULL, NULL, pmodo);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      ntraza := 6;

      --
      -- obtenemos el numero de linia siguiente
      BEGIN
         IF pmodo = 'R' THEN
            ntraza := 7;

            SELECT NVL(MAX(nnumlin) + 1, 1)
              INTO xnnumlin
              FROM ctaseguro_shadow
             WHERE sseguro = psseguro;
         ELSIF pmodo = 'P' THEN
            ntraza := 8;

            SELECT NVL(MAX(nnumlin) + 1, 1)
              INTO xnnumlin
              FROM ctaseguro_previo_shw
             WHERE sseguro = psseguro;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 104882;   -- Error al llegir de CTASEGURO
      END;

      --
      FOR regs IN cur_cesta LOOP
         --Valor participación de la cesta
         ntraza := 9;

         BEGIN
            -- Último valor liquidativo del fondo
            -- Tarea 31548/206135 Management expenses
            SELECT NVL(iuniactvtashw, 0)
              INTO iuniacts
              FROM tabvalces
             WHERE ccesta = regs.ccesta
               AND TRUNC(fvalor) = v_fecha + pac_md_fondos.f_get_diasdep(regs.ccesta);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               p_tab_error
                         (f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_cta_gastos_scobertura_shw',
                          ntraza,
                          'No hay valor liquidativo para la fecha. Parametros: psseguro ='
                          || psseguro || ' v_fecha =' || v_fecha || ' psproduc =' || psproduc
                          || ' pmodo =' || pmodo,
                          SQLERRM, 50);
               iuniacts := 0;
         END;

         --
         -- Calcula las distribuciones
         --
         vacumpercent := vacumpercent + (resultado * regs.pdistrec) / 100;
         imovimo := ROUND(vacumpercent - vacumrounded, 2);
         vacumrounded := vacumrounded + ROUND(vacumpercent - vacumrounded, 2);
         --
         ntraza := 10;

         IF NVL(iuniacts, 0) = 0 THEN
            num_err := pac_ctaseguro.f_insctaseguro_shw(psseguro, vfsysdate, NULL, v_fecha,
                                                        v_fecha, 84, imovimo, NULL, NULL,
                                                        v_seqgrupo, 0, NULL, NULL, '1', pmodo,
                                                        NULL, NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, regs.ccesta);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         ELSE
            -- cmovimi 84 = Gasto Prima Riesgo = Gasto de Seguro de Cobertura
            BEGIN
               IF pmodo = 'R' THEN
                  ntraza := 11;

                  INSERT INTO ctaseguro_shadow
                              (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                               imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec, cesta,
                               nunidad, cestado, fasign)
                       VALUES (psseguro, vfsysdate, xnnumlin, v_fecha, v_fecha, 84, imovimo,
                               NULL, NULL, v_seqgrupo, 0, NULL, NULL, regs.ccesta,
                               -1 *(imovimo / iuniacts), '2', vfsysdate);

                  -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  IF v_cmultimon = 1 THEN
                     ntraza := 12;
                     num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro,
                                                                               vfsysdate,
                                                                               xnnumlin,
                                                                               v_fecha);

                     IF num_err <> 0 THEN
                        p_tab_error(f_sysdate, f_user,
                                    'PAC_OPERATIVA_FINV.f_cta_gastos_scobertura_shw', ntraza,
                                    'parametros: psseguro =' || psseguro || ' pfefecto ='
                                    || pfefecto || ' pmodo =' || pmodo || ' v_fecha ='
                                    || v_fecha || ' psproduc =' || psproduc,
                                    SQLERRM);
                        RETURN num_err;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  xnnumlin := xnnumlin + 1;
               ELSIF pmodo = 'P' THEN
                  ntraza := 13;

                  INSERT INTO ctaseguro_previo_shw
                              (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                               imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec, cesta,
                               nunidad, cestado, fasign)
                       VALUES (psseguro, vfsysdate, xnnumlin, v_fecha, v_fecha, 84, imovimo,
                               NULL, NULL, v_seqgrupo, 0, NULL, NULL, regs.ccesta,
                               -1 *(imovimo / iuniacts), '2', vfsysdate);

                  xnnumlin := xnnumlin + 1;
               END IF;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  p_tab_error(f_sysdate, f_user,
                              'PAC_OPERATIVA_FINV.f_cta_gastos_scobertura_shw', ntraza,
                              'parametros: psseguro = ' || psseguro || ' pfefecto='
                              || pfefecto || ' psproduc=' || psproduc || ' pmodo=' || pmodo
                              || ' pcmovimi=' || pcmovimi || ' pipririe=' || pipririe
                              || ' v_fecha=' || v_fecha,
                              SQLERRM);
                  RETURN 104879;   -- Registre duplicat a CTASEGURO
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user,
                              'PAC_OPERATIVA_FINV.f_cta_gastos_scobertura_shw', ntraza,
                              'parametros: psseguro = ' || psseguro || ' pfefecto='
                              || pfefecto || ' psproduc=' || psproduc || ' pmodo=' || pmodo
                              || ' pcmovimi=' || pcmovimi || ' pipririe=' || pipririe
                              || ' v_fecha=' || v_fecha,
                              SQLERRM);
                  RETURN 102555;   -- Error al insertar a la taula CTASEGURO
            END;
         --
         END IF;
      --
      END LOOP;

      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_cta_gastos_scobertura_shw',
                     ntraza,
                     'parametros: psseguro = ' || psseguro || ' pfefecto=' || pfefecto
                     || ' psproduc=' || psproduc || ' pmodo=' || pmodo || ' pcmovimi='
                     || pcmovimi || ' pipririe=' || pipririe || ' v_fecha=' || v_fecha,
                     SQLERRM);
         RETURN 102555;   -- Error al insertar a la taula CTASEGURO
   END f_cta_gastos_scobertura_shw;

   /**********************************************************************
     Esta función esta obsoleta. Diria que no se llama ni se llamará
     en ninguna parte. (ya que los gastos por redistribución se
     aplican en el momento de la redistribución (movimientos 80, 81)).
   **********************************************************************/
   FUNCTION f_gastos_redistribucion_anual(
      psseguro IN NUMBER,
      v_provision IN NUMBER,
      gredanual IN OUT NUMBER)
      RETURN NUMBER IS
      v_gasred       NUMBER;
      p_pgasto       NUMBER;
      pimaximo       NUMBER;
      piminimo       NUMBER;
   BEGIN
      BEGIN
         SELECT cgasred
           INTO v_gasred
           FROM seguros_ulk
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_gastos_redistribucion_anual',
                        NULL,
                        'parametros: psseguro =' || psseguro || ' v_provision ='
                        || v_provision,
                        SQLERRM);
            RETURN(108190);
      -- Cambiar por gasto de gestion no definido para la póliza
      END;

      -- Bug 9424 - 15/04/2009 - RSC - Creación del producto PPJ Dinàmic
      -- Si no tiene definido gasto por redistribución no se aplica gasto
      IF v_gasred IS NULL THEN
         RETURN(0);
      END IF;

      -- Fin Bug 9424
      BEGIN
         SELECT pgasto, imaximo, iminimo
           INTO p_pgasto, pimaximo, piminimo
           FROM detgastos_ulk
          WHERE ffinvig IS NULL
            AND cgasto = v_gasred;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_gastos_redistribucion_anual',
                        NULL,
                        'parametros: psseguro =' || psseguro || ' v_provision ='
                        || v_provision,
                        SQLERRM);
            RETURN(108190);   -- detalle de gasto no definido. Error general?
      END;

      IF (v_provision *(p_pgasto / 100)) < piminimo THEN
         gredanual := piminimo;
      ELSIF(v_provision *(p_pgasto / 100)) >= pimaximo THEN
         gredanual := pimaximo;
      ELSE
         gredanual := v_provision *(p_pgasto / 100);
      END IF;

      RETURN(0);
   END f_gastos_redistribucion_anual;

   /**********************************************************************
     Nueva función, que utiliza las tablas PRODTRASREC y DETPRODTRASREC,
     Con tipo de movimiento de penalización = 8 - Redistribución de fondos.

     Se aplica en el momento de la resdistribución (movimientos 80, 81)).
   **********************************************************************/
   FUNCTION f_gastos_redistribucion(psseguro IN NUMBER, pfecha IN DATE, pgtosred OUT NUMBER)
      RETURN NUMBER IS
      --
      v_gasred       NUMBER;
      v_nro_distr    NUMBER;
      v_tippenali    NUMBER;
      v_ngraano      detprodtraresc.ngraano%TYPE;
      v_iminimo      detprodtraresc.iminimo%TYPE;
      v_imaximo      detprodtraresc.imaximo%TYPE;
      v_anyos        NUMBER;
      v_provision    ctaseguro.imovimi%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      v_fefecto      seguros.fefecto%TYPE;
   --
   BEGIN
      v_gasred := calc_rescates.f_get_penalizacion(psseguro,
                                                   TO_NUMBER(TO_CHAR(pfecha, 'yyyymmdd')), 8,
                                                   v_tippenali);

      IF NVL(v_gasred, 0) = 0 THEN
         pgtosred := 0;
         RETURN 0;
      END IF;

      BEGIN
         SELECT sproduc, fefecto
           INTO v_sproduc, v_fefecto
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_gastos_redistribucion_anual',
                        NULL,
                        'parametros: psseguro =' || psseguro || ' v_provision ='
                        || v_provision,
                        SQLERRM);
            RETURN 101919;   -- Error al leer datos de la tabla SEGUROS
      END;

      -- Miro cuantas redistribuciones se han generado en el año.
      SELECT COUNT(1)
        INTO v_nro_distr
        FROM ctaseguro
       WHERE TO_CHAR(pfecha, 'yyyy') = TO_CHAR(fvalmov, 'yyyy')
         AND cmovimi = 80
         AND sseguro = psseguro;

      v_anyos :=((pfecha - v_fefecto) / 365.25);

      -- Miro cuantas son gratuítas
      BEGIN
         SELECT d.ngraano, d.iminimo, d.imaximo
           INTO v_ngraano, v_iminimo, v_imaximo
           FROM detprodtraresc d, prodtraresc p
          WHERE d.sidresc = p.sidresc
            AND p.sproduc = v_sproduc
            AND p.ctipmov = 8
            AND p.finicio <= pfecha
            AND(p.ffin > pfecha
                OR p.ffin IS NULL)
            AND d.niniran = (SELECT MIN(dp.niniran)
                               FROM detprodtraresc dp
                              WHERE dp.sidresc = d.sidresc
                                AND v_anyos BETWEEN dp.niniran AND dp.nfinran);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_gastos_redistribucion_anual',
                        NULL,
                        'parametros: psseguro =' || psseguro || ' v_provision ='
                        || v_provision,
                        SQLERRM);
            RETURN 108190;   -- detalle de gasto no definido. Error general?
      END;

      --
      IF (NVL(v_ngraano, 0) > 0)
         AND(NVL(v_ngraano, 0) >= NVL(v_nro_distr, 0)) THEN
         pgtosred := 0;
         RETURN 0;
      END IF;

      --
      IF v_tippenali = 1 THEN
         pgtosred := v_gasred;
         RETURN 0;
      END IF;

      -- Si es un porcentaje calculo sobre la provisión.
      IF v_tippenali = 2 THEN
         v_provision := pac_operativa_finv.ff_provmat(1, psseguro,
                                                      TO_NUMBER(TO_CHAR(pfecha, 'yyyymmdd')));

         --
         IF (v_provision *(v_gasred / 100)) < NVL(v_iminimo, 0) THEN
            pgtosred := v_iminimo;
         ELSIF(((v_provision *(v_gasred / 100)) >= NVL(v_imaximo, 0))
               AND(NVL(v_imaximo, 0) > 0)) THEN
            pgtosred := v_imaximo;
         ELSE
            pgtosred := f_round_moneda(v_provision *(v_gasred / 100));
         END IF;
      --
      END IF;

      --
      RETURN(0);
   --
   END f_gastos_redistribucion;

   FUNCTION f_cta_saldo_fondos(
      psseguro IN NUMBER,
      fdesde IN DATE,
      total_cestas IN OUT NUMBER,
      tcestasu IN OUT NUMBER,
      v_det_modinv IN OUT tt_det_modinv,
      pfunds IN t_iax_produlkmodinvfondo DEFAULT NULL)   -- Bug 36746/0211309 - APD - 17/09/2015
      RETURN NUMBER IS
      -- Revisar los movimientos que no se tienen que contemplar aqui!!!
      CURSOR cur_ctaseguro IS
         SELECT   ROWID, cesta, ffecmov, cmovimi, imovimi, nunidad
             FROM ctaseguro
            WHERE sseguro = psseguro
              AND(ffecmov >= fdesde
                  OR fdesde IS NULL)
              --AND cmovimi NOT IN(0, 1, 2, 4, 60, 70, 80)
              --AND cesta IS NOT NULL
              -- Bug 10846 - RSC - 13/10/2009 - CRE - Operaciones con Fondos
              -- Bug 36746/0211309 - APD - 17/09/2015
              AND((cesta IS NOT NULL
                   AND pfunds IS NULL)
                  OR(cesta IS NOT NULL
                     AND pfunds IS NOT NULL
                     AND f_valida_cesta_switch(cesta, pfunds) = 1))
         -- fin Bug 36746/0211309 - APD - 17/09/2015
         ORDER BY cesta, ffecmov;

      cesta_ant      NUMBER;
      cesta_cur      NUMBER;
      saldo_cesta    NUMBER := 0;
      precio_cesta   NUMBER;
      primer         NUMBER := 1;

      FUNCTION f_det_modinv(cesta IN NUMBER, ucesta IN NUMBER, valorcesta IN NUMBER)
         RETURN rt_det_modinv IS
         v_det_modinv   rt_det_modinv;
      BEGIN
         v_det_modinv.vccesta := cesta;
         v_det_modinv.vucesta := ucesta;
         v_det_modinv.vvalcesta := valorcesta;
         RETURN(v_det_modinv);
      END;
   BEGIN
      FOR regs IN cur_ctaseguro LOOP
         IF primer = 1 THEN
            cesta_ant := regs.cesta;
            primer := 0;
         END IF;

         cesta_cur := regs.cesta;

         IF cesta_ant <> cesta_cur THEN
            --PRECIO UNIDAD DE LA CESTA
            /*
            select NVL(iuniact,0) into precio_cesta
            from fondos
            where ccodfon = cesta_ant;
            */
            -- RSC 18/03/2008 -- Ultimo valor liquidativo de cesta realmente
            BEGIN
               SELECT NVL(iuniact, 0)
                 INTO precio_cesta
                 FROM tabvalces
                WHERE ccesta = cesta_ant
                  AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                         FROM tabvalces
                                        WHERE ccesta = cesta_ant);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  precio_cesta := 0;
            END;

            -- (saldo_cesta*precio_cesta) = Saldo de la cesta en euros
            total_cestas := total_cestas +(saldo_cesta * precio_cesta);
            tcestasu := tcestasu + saldo_cesta;
            -- Guaramos en un table las diferentes cesta y saldos de cesta
            v_det_modinv(NVL(v_det_modinv.LAST, 0) + 1) :=
                              f_det_modinv(cesta_ant, saldo_cesta,
                                           (saldo_cesta * precio_cesta));
            saldo_cesta := 0;
            cesta_ant := cesta_cur;

            -- sumen les unitats de la cistella actual
            IF regs.nunidad IS NOT NULL THEN
               saldo_cesta := saldo_cesta + NVL(regs.nunidad, 0);
            END IF;
         ELSE
            IF regs.nunidad IS NOT NULL THEN
               saldo_cesta := saldo_cesta + NVL(regs.nunidad, 0);
            END IF;
         END IF;
      END LOOP;

      -- RSC 18/03/2008 -- Ultimo valor liquidativo de cesta realmente
      IF cesta_ant IS NOT NULL THEN
         BEGIN
            SELECT NVL(iuniact, 0)
              INTO precio_cesta
              FROM tabvalces
             WHERE ccesta = cesta_ant
               AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                      FROM tabvalces
                                     WHERE ccesta = cesta_ant);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               precio_cesta := 0;
         END;

         -- (saldo_cesta*precio_cesta) = Saldo de la cesta en euros
         total_cestas := total_cestas +(saldo_cesta * precio_cesta);
         tcestasu := tcestasu + saldo_cesta;
         -- Guaramos en un table las diferentes cesta y saldos de cesta
         v_det_modinv(NVL(v_det_modinv.LAST, 0) + 1) :=
                              f_det_modinv(cesta_ant, saldo_cesta,
                                           (saldo_cesta * precio_cesta));
      ELSE
         total_cestas := 0;
         tcestasu := 0;
      END IF;

      RETURN(0);
   END f_cta_saldo_fondos;

   FUNCTION f_cta_saldo_fondos_shw(
      psseguro IN NUMBER,
      fdesde IN DATE,
      total_cestas IN OUT NUMBER,
      tcestasu IN OUT NUMBER,
      v_det_modinv IN OUT tt_det_modinv,
      pfunds IN t_iax_produlkmodinvfondo)   -- Bug 36746/0211309 - APD - 17/09/2015
      RETURN NUMBER IS
      -- Revisar los movimientos que no se tienen que contemplar aqui!!!
      CURSOR cur_ctaseguro IS
         SELECT   ROWID, cesta, ffecmov, cmovimi, imovimi, nunidad
             FROM ctaseguro_shadow
            WHERE sseguro = psseguro
              AND(ffecmov >= fdesde
                  OR fdesde IS NULL)
              --AND cmovimi NOT IN(0, 1, 2, 4, 60, 70, 80)
              --AND cesta IS NOT NULL
              -- Bug 10846 - RSC - 13/10/2009 - CRE - Operaciones con Fondos
              -- Bug 36746/0211309 - APD - 17/09/2015
              AND((cesta IS NOT NULL
                   AND pfunds IS NULL)
                  OR(cesta IS NOT NULL
                     AND pfunds IS NOT NULL
                     AND 1 = f_valida_cesta_switch(cesta, pfunds)))
         -- fin Bug 36746/0211309 - APD - 17/09/2015
         ORDER BY cesta, ffecmov;

      cesta_ant      NUMBER;
      cesta_cur      NUMBER;
      saldo_cesta    NUMBER := 0;
      precio_cesta   NUMBER;
      primer         NUMBER := 1;

      FUNCTION f_det_modinv(cesta IN NUMBER, ucesta IN NUMBER, valorcesta IN NUMBER)
         RETURN rt_det_modinv IS
         v_det_modinv   rt_det_modinv;
      BEGIN
         v_det_modinv.vccesta := cesta;
         v_det_modinv.vucesta := ucesta;
         v_det_modinv.vvalcesta := valorcesta;
         RETURN(v_det_modinv);
      END;
   BEGIN
      FOR regs IN cur_ctaseguro LOOP
         IF primer = 1 THEN
            cesta_ant := regs.cesta;
            primer := 0;
         END IF;

         cesta_cur := regs.cesta;

         IF cesta_ant <> cesta_cur THEN
            --PRECIO UNIDAD DE LA CESTA
            /*
            select NVL(iuniact,0) into precio_cesta
            from fondos
            where ccodfon = cesta_ant;
            */
            -- RSC 18/03/2008 -- Ultimo valor liquidativo de cesta realmente
            BEGIN
               SELECT NVL(iuniactvtashw, 0)
                 INTO precio_cesta
                 FROM tabvalces
                WHERE ccesta = cesta_ant
                  AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                         FROM tabvalces
                                        WHERE ccesta = cesta_ant);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  precio_cesta := 0;
            END;

            -- (saldo_cesta*precio_cesta) = Saldo de la cesta en euros
            total_cestas := total_cestas +(saldo_cesta * precio_cesta);
            tcestasu := tcestasu + saldo_cesta;
            -- Guaramos en un table las diferentes cesta y saldos de cesta
            v_det_modinv(NVL(v_det_modinv.LAST, 0) + 1) :=
                              f_det_modinv(cesta_ant, saldo_cesta,
                                           (saldo_cesta * precio_cesta));
            saldo_cesta := 0;
            cesta_ant := cesta_cur;

            -- sumen les unitats de la cistella actual
            IF regs.nunidad IS NOT NULL THEN
               saldo_cesta := saldo_cesta + NVL(regs.nunidad, 0);
            END IF;
         ELSE
            IF regs.nunidad IS NOT NULL THEN
               saldo_cesta := saldo_cesta + NVL(regs.nunidad, 0);
            END IF;
         END IF;
      END LOOP;

      -- RSC 18/03/2008 -- Ultimo valor liquidativo de cesta realmente
      IF cesta_ant IS NOT NULL THEN
         BEGIN
            SELECT NVL(iuniactvtashw, 0)
              INTO precio_cesta
              FROM tabvalces
             WHERE ccesta = cesta_ant
               AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                      FROM tabvalces
                                     WHERE ccesta = cesta_ant);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               precio_cesta := 0;
         END;

         -- (saldo_cesta*precio_cesta) = Saldo de la cesta en euros
         total_cestas := total_cestas +(saldo_cesta * precio_cesta);
         tcestasu := tcestasu + saldo_cesta;
         -- Guaramos en un table las diferentes cesta y saldos de cesta
         v_det_modinv(NVL(v_det_modinv.LAST, 0) + 1) :=
                              f_det_modinv(cesta_ant, saldo_cesta,
                                           (saldo_cesta * precio_cesta));
      ELSE
         total_cestas := 0;
         tcestasu := 0;
      END IF;

      RETURN(0);
   END f_cta_saldo_fondos_shw;

   FUNCTION f_cta_saldo_fondos_cesta(
      psseguro IN NUMBER,
      fdesde IN DATE,
      pcesta IN NUMBER,
      tcesta_unidades IN OUT NUMBER,
      tcesta_importe IN OUT NUMBER,
      total_cestas IN OUT NUMBER)
      RETURN NUMBER IS
      -- Revisar los movimientos que no se tienen que contemplar aqui!!!
      CURSOR cur_ctaseguro IS
         SELECT   ROWID, cesta, ffecmov, cmovimi, imovimi, nunidad
             FROM ctaseguro
            WHERE sseguro = psseguro
              AND(ffecmov >= fdesde
                  OR fdesde IS NULL)
              --AND cmovimi NOT IN(0, 1, 2, 4, 60, 70, 80)
              AND cesta IS NOT NULL
         -- Bug 10846 - RSC - 13/10/2009 - CRE - Operaciones con Fondos
         ORDER BY cesta, ffecmov;

      cesta_ant      NUMBER;
      cesta_cur      NUMBER;
      saldo_cesta    NUMBER := 0;
      precio_cesta   NUMBER;
      primer         NUMBER := 1;
   BEGIN
      FOR regs IN cur_ctaseguro LOOP
         IF primer = 1 THEN
            cesta_ant := regs.cesta;
            primer := 0;
         END IF;

         cesta_cur := regs.cesta;

         IF cesta_ant <> cesta_cur THEN
            --PRECIO UNIDAD DE LA CESTA
            BEGIN
               SELECT NVL(iuniact, 0)
                 INTO precio_cesta
                 FROM tabvalces
                WHERE ccesta = cesta_ant
                  AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                         FROM tabvalces
                                        WHERE ccesta = cesta_ant);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  precio_cesta := 0;
            END;

            -- (saldo_cesta*precio_cesta) = Saldo de la cesta en euros
            total_cestas := total_cestas +(saldo_cesta * precio_cesta);

            IF cesta_ant = pcesta THEN
               tcesta_unidades := tcesta_unidades + saldo_cesta;
               tcesta_importe := tcesta_unidades * precio_cesta;
            END IF;

            saldo_cesta := 0;
            cesta_ant := cesta_cur;

            -- sumen les unitats de la cistella actual
            IF regs.nunidad IS NOT NULL THEN
               saldo_cesta := saldo_cesta + NVL(regs.nunidad, 0);
            END IF;
         ELSE
            IF regs.nunidad IS NOT NULL THEN
               saldo_cesta := saldo_cesta + NVL(regs.nunidad, 0);
            END IF;
         END IF;
      END LOOP;

      -- ultimo caso
      --PRECIO UNIDAD DE LA CESTA
      IF cesta_ant IS NOT NULL THEN
         BEGIN
            SELECT NVL(iuniact, 0)
              INTO precio_cesta
              FROM tabvalces
             WHERE ccesta = cesta_ant
               AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                      FROM tabvalces
                                     WHERE ccesta = cesta_ant);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               precio_cesta := 0;
         END;

         -- (saldo_cesta*precio_cesta) = Saldo de la cesta en euros
         total_cestas := total_cestas +(saldo_cesta * precio_cesta);

         IF cesta_ant = pcesta THEN
            tcesta_unidades := tcesta_unidades + saldo_cesta;
            tcesta_importe := tcesta_unidades * precio_cesta;
         END IF;
      ELSE
         total_cestas := 0;
         tcesta_unidades := 0;
         tcesta_importe := 0;
      END IF;

      RETURN(0);
   END f_cta_saldo_fondos_cesta;

   FUNCTION f_cta_saldo_fondos_cesta_shw(
      psseguro IN NUMBER,
      fdesde IN DATE,
      pcesta IN NUMBER,
      tcesta_unidades IN OUT NUMBER,
      tcesta_importe IN OUT NUMBER,
      total_cestas IN OUT NUMBER)
      RETURN NUMBER IS
      -- Revisar los movimientos que no se tienen que contemplar aqui!!!
      CURSOR cur_ctaseguro IS
         SELECT   ROWID, cesta, ffecmov, cmovimi, imovimi, nunidad
             FROM ctaseguro_shadow
            WHERE sseguro = psseguro
              AND(ffecmov >= fdesde
                  OR fdesde IS NULL)
              --AND cmovimi NOT IN(0, 1, 2, 4, 60, 70, 80)
              AND cesta IS NOT NULL
         -- Bug 10846 - RSC - 13/10/2009 - CRE - Operaciones con Fondos
         ORDER BY cesta, ffecmov;

      cesta_ant      NUMBER;
      cesta_cur      NUMBER;
      saldo_cesta    NUMBER := 0;
      precio_cesta   NUMBER;
      primer         NUMBER := 1;
   BEGIN
      FOR regs IN cur_ctaseguro LOOP
         IF primer = 1 THEN
            cesta_ant := regs.cesta;
            primer := 0;
         END IF;

         cesta_cur := regs.cesta;

         IF cesta_ant <> cesta_cur THEN
            --PRECIO UNIDAD DE LA CESTA
            BEGIN
               SELECT NVL(iuniactvtashw, 0)
                 INTO precio_cesta
                 FROM tabvalces
                WHERE ccesta = cesta_ant
                  AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                         FROM tabvalces
                                        WHERE ccesta = cesta_ant);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  precio_cesta := 0;
            END;

            -- (saldo_cesta*precio_cesta) = Saldo de la cesta en euros
            total_cestas := total_cestas +(saldo_cesta * precio_cesta);

            IF cesta_ant = pcesta THEN
               tcesta_unidades := tcesta_unidades + saldo_cesta;
               tcesta_importe := tcesta_unidades * precio_cesta;
            END IF;

            saldo_cesta := 0;
            cesta_ant := cesta_cur;

            -- sumen les unitats de la cistella actual
            IF regs.nunidad IS NOT NULL THEN
               saldo_cesta := saldo_cesta + NVL(regs.nunidad, 0);
            END IF;
         ELSE
            IF regs.nunidad IS NOT NULL THEN
               saldo_cesta := saldo_cesta + NVL(regs.nunidad, 0);
            END IF;
         END IF;
      END LOOP;

      -- ultimo caso
      --PRECIO UNIDAD DE LA CESTA
      IF cesta_ant IS NOT NULL THEN
         BEGIN
            SELECT NVL(iuniactvtashw, 0)
              INTO precio_cesta
              FROM tabvalces
             WHERE ccesta = cesta_ant
               AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                      FROM tabvalces
                                     WHERE ccesta = cesta_ant);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               precio_cesta := 0;
         END;

         -- (saldo_cesta*precio_cesta) = Saldo de la cesta en euros
         total_cestas := total_cestas +(saldo_cesta * precio_cesta);

         IF cesta_ant = pcesta THEN
            tcesta_unidades := tcesta_unidades + saldo_cesta;
            tcesta_importe := tcesta_unidades * precio_cesta;
         END IF;
      ELSE
         total_cestas := 0;
         tcesta_unidades := 0;
         tcesta_importe := 0;
      END IF;

      RETURN(0);
   END f_cta_saldo_fondos_cesta_shw;

   FUNCTION f_cta_provision_cesta(
      psseguro IN NUMBER,
      fdesde IN DATE,
      fhasta IN DATE,
      pcesta IN NUMBER,
      tcesta_unidades IN OUT NUMBER,
      tcesta_importe IN OUT NUMBER,
      total_cestas IN OUT NUMBER,
      pnnumlin IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      -- Revisar los movimientos que no se tienen que contemplar aqui!!!
      CURSOR cur_ctaseguro IS
         SELECT   ROWID, cesta, ffecmov, cmovimi, imovimi, nunidad
             FROM ctaseguro
            WHERE sseguro = psseguro
              AND(ffecmov >= fdesde
                  OR fdesde IS NULL)
              AND fvalmov <= NVL(fhasta, f_sysdate)
              AND nnumlin <= NVL(pnnumlin, nnumlin)
              --AND cmovimi NOT IN(0, 1, 2, 4, 60, 70, 80)
              AND cesta IS NOT NULL
         -- Bug 10846 - RSC - 13/10/2009 - CRE - Operaciones con Fondos
         ORDER BY cesta, ffecmov;

      cesta_ant      NUMBER;
      cesta_cur      NUMBER;
      saldo_cesta    NUMBER := 0;
      precio_cesta   NUMBER;
      primer         NUMBER := 1;
   BEGIN
      FOR regs IN cur_ctaseguro LOOP
         IF primer = 1 THEN
            cesta_ant := regs.cesta;
            primer := 0;
         END IF;

         cesta_cur := regs.cesta;

         IF cesta_ant <> cesta_cur THEN
            --PRECIO UNIDAD DE LA CESTA
            BEGIN
               SELECT NVL(iuniact, 0)
                 INTO precio_cesta
                 FROM tabvalces
                WHERE ccesta = cesta_ant
                  AND TRUNC(fvalor) = TRUNC(fhasta);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT NVL(iuniact, 0)
                       INTO precio_cesta
                       FROM tabvalces
                      WHERE ccesta = cesta_ant
                        AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                               FROM tabvalces
                                              WHERE ccesta = cesta_ant
                                                AND TRUNC(fvalor) <= TRUNC(fhasta));
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        precio_cesta := 0;
                  END;
            END;

            -- (saldo_cesta*precio_cesta) = Saldo de la cesta en euros
            total_cestas := total_cestas +(saldo_cesta * precio_cesta);

            IF cesta_ant = pcesta THEN
               tcesta_unidades := tcesta_unidades + saldo_cesta;
               tcesta_importe := tcesta_unidades * precio_cesta;
            END IF;

            saldo_cesta := 0;
            cesta_ant := cesta_cur;

            -- sumen les unitats de la cistella actual
            IF regs.nunidad IS NOT NULL THEN
               saldo_cesta := saldo_cesta + NVL(regs.nunidad, 0);
            END IF;
         ELSE
            IF regs.nunidad IS NOT NULL THEN
               saldo_cesta := saldo_cesta + NVL(regs.nunidad, 0);
            END IF;
         END IF;
      END LOOP;

      -- ultimo caso
      --PRECIO UNIDAD DE LA CESTA
      IF cesta_ant IS NOT NULL THEN
         BEGIN
            SELECT NVL(iuniact, 0)
              INTO precio_cesta
              FROM tabvalces
             WHERE ccesta = cesta_ant
               AND TRUNC(fvalor) = TRUNC(fhasta);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT NVL(iuniact, 0)
                    INTO precio_cesta
                    FROM tabvalces
                   WHERE ccesta = cesta_ant
                     AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                            FROM tabvalces
                                           WHERE ccesta = cesta_ant
                                             AND TRUNC(fvalor) <= TRUNC(fhasta));
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     precio_cesta := 0;
               END;
         END;

         -- (saldo_cesta*precio_cesta) = Saldo de la cesta en euros
         total_cestas := total_cestas +(saldo_cesta * precio_cesta);

         IF cesta_ant = pcesta THEN
            tcesta_unidades := tcesta_unidades + saldo_cesta;
            tcesta_importe := tcesta_unidades * precio_cesta;
         END IF;
      END IF;

      RETURN(0);
   END f_cta_provision_cesta;

   FUNCTION f_cta_provision_cesta_shw(
      psseguro IN NUMBER,
      fdesde IN DATE,
      fhasta IN DATE,
      pcesta IN NUMBER,
      tcesta_unidades IN OUT NUMBER,
      tcesta_importe IN OUT NUMBER,
      total_cestas IN OUT NUMBER,
      pnnumlin IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      -- Revisar los movimientos que no se tienen que contemplar aqui!!!
      CURSOR cur_ctaseguro IS
         SELECT   ROWID, cesta, ffecmov, cmovimi, imovimi, nunidad
             FROM ctaseguro_shadow
            WHERE sseguro = psseguro
              AND(ffecmov >= fdesde
                  OR fdesde IS NULL)
              AND fvalmov <= NVL(fhasta, f_sysdate)
              AND nnumlin <= NVL(pnnumlin, nnumlin)
              --AND cmovimi NOT IN(0, 1, 2, 4, 60, 70, 80)
              AND cesta IS NOT NULL
         -- Bug 10846 - RSC - 13/10/2009 - CRE - Operaciones con Fondos
         ORDER BY cesta, ffecmov;

      cesta_ant      NUMBER;
      cesta_cur      NUMBER;
      saldo_cesta    NUMBER := 0;
      precio_cesta   NUMBER;
      primer         NUMBER := 1;
   BEGIN
      FOR regs IN cur_ctaseguro LOOP
         IF primer = 1 THEN
            cesta_ant := regs.cesta;
            primer := 0;
         END IF;

         cesta_cur := regs.cesta;

         IF cesta_ant <> cesta_cur THEN
            --PRECIO UNIDAD DE LA CESTA
            BEGIN
               SELECT NVL(iuniactvtashw, 0)
                 INTO precio_cesta
                 FROM tabvalces
                WHERE ccesta = cesta_ant
                  AND TRUNC(fvalor) = TRUNC(fhasta);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT NVL(iuniactvtashw, 0)
                       INTO precio_cesta
                       FROM tabvalces
                      WHERE ccesta = cesta_ant
                        AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                               FROM tabvalces
                                              WHERE ccesta = cesta_ant
                                                AND TRUNC(fvalor) <= TRUNC(fhasta));
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        precio_cesta := 0;
                  END;
            END;

            -- (saldo_cesta*precio_cesta) = Saldo de la cesta en euros
            total_cestas := total_cestas +(saldo_cesta * precio_cesta);

            IF cesta_ant = pcesta THEN
               tcesta_unidades := tcesta_unidades + saldo_cesta;
               tcesta_importe := tcesta_unidades * precio_cesta;
            END IF;

            saldo_cesta := 0;
            cesta_ant := cesta_cur;

            -- sumen les unitats de la cistella actual
            IF regs.nunidad IS NOT NULL THEN
               saldo_cesta := saldo_cesta + NVL(regs.nunidad, 0);
            END IF;
         ELSE
            IF regs.nunidad IS NOT NULL THEN
               saldo_cesta := saldo_cesta + NVL(regs.nunidad, 0);
            END IF;
         END IF;
      END LOOP;

      -- ultimo caso
      --PRECIO UNIDAD DE LA CESTA
      IF cesta_ant IS NOT NULL THEN
         BEGIN
            SELECT NVL(iuniactvtashw, 0)
              INTO precio_cesta
              FROM tabvalces
             WHERE ccesta = cesta_ant
               AND TRUNC(fvalor) = TRUNC(fhasta);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT NVL(iuniactvtashw, 0)
                    INTO precio_cesta
                    FROM tabvalces
                   WHERE ccesta = cesta_ant
                     AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                            FROM tabvalces
                                           WHERE ccesta = cesta_ant
                                             AND TRUNC(fvalor) <= TRUNC(fhasta));
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     precio_cesta := 0;
               END;
         END;

         -- (saldo_cesta*precio_cesta) = Saldo de la cesta en euros
         total_cestas := total_cestas +(saldo_cesta * precio_cesta);

         IF cesta_ant = pcesta THEN
            tcesta_unidades := tcesta_unidades + saldo_cesta;
            tcesta_importe := tcesta_unidades * precio_cesta;
         END IF;
      END IF;

      RETURN(0);
   END f_cta_provision_cesta_shw;

   FUNCTION f_redistribucion_fondos(psseguro IN NUMBER)
      RETURN NUMBER IS
      total_cestas   NUMBER := 0;
      total_saldo_u  NUMBER := 0;
      total_cestas_shw NUMBER := 0;
      total_saldo_u_shw NUMBER := 0;
      num_err        NUMBER;
      -- Estructura para almacenar pares (cesta - unidades cesta)
      v_det_modinv   tt_det_modinv;
      v_det_modinv_shw tt_det_modinv;
      pfefecto       DATE;
      sivendecompra  NUMBER := 0;
      sivendecompra_shw NUMBER := 0;
      seqgrupo       NUMBER;
      -- Bug 9424 - 15/04/2009 - RSC - Creación del producto PPJ Dinàmic
      v_gasred       NUMBER;
      -- Fin Bug 9424
      v_nerrores     NUMBER := 0;
      v_sproces      NUMBER;
      -- Mantis 12274.NMM.15/12/2009.i.
      w_fdiahabil    DATE;
      w_fdiahabil2   DATE;   -- Mantis 12274.f.
      v_sproduc      NUMBER;
      v_cempres      NUMBER;
      -- Bug 10828 - RSC - 14/10/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      v_preciounidad NUMBER;
      v_nomvimi      NUMBER;
      vfefecto       DATE;
      vfmovimi       DATE;
      vtieneshw      NUMBER;

      CURSOR nmov IS
         SELECT   movseguro.nmovimi, movseguro.fefecto, movseguro.fmovimi
             FROM movseguro, detmovseguro
            WHERE movseguro.sseguro = psseguro
              AND detmovseguro.sseguro = movseguro.sseguro
              AND detmovseguro.nmovimi = movseguro.nmovimi
              AND detmovseguro.cmotmov = 526
         ORDER BY nmovimi DESC;
   -- Fin Bug 10828
   BEGIN
      vtieneshw := pac_ctaseguro.f_tiene_ctashadow(psseguro, NULL);

      OPEN nmov;

      FETCH nmov
       INTO v_nomvimi, vfefecto, vfmovimi;

      CLOSE nmov;

      -- Mantis 12274.NMM.i.
      SELECT sproduc, cempres
        INTO v_sproduc, v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      -- 12274.f.

      -- Mantis 12274.NMM.i.
      --Bug -XVM-07/11/2012.Inicio
      w_fdiahabil := f_diahabil(13, TRUNC(vfefecto), NULL);

      IF pac_mantenimiento_fondos_finv.f_get_estado_fondo(v_cempres, TRUNC(f_sysdate)) = 107742 THEN
         w_fdiahabil2 := f_diahabil(0, TRUNC(f_sysdate), NULL);
      ELSE
         w_fdiahabil2 := TRUNC(f_sysdate);
      END IF;

      pfefecto := GREATEST(w_fdiahabil, w_fdiahabil2);
      --Bug -XVM-07/11/2012.Fin.
      pfefecto := GREATEST(w_fdiahabil, w_fdiahabil2);
      -- 12274.f.
      num_err := f_cta_saldo_fondos(psseguro, NULL, total_cestas, total_saldo_u, v_det_modinv);

      IF num_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_cta_saldo_fondos', NULL,
                     'parametros: psseguro = ' || psseguro,
                     f_axis_literales(num_err, f_idiomauser));
         RETURN num_err;
      END IF;

      IF vtieneshw = 1 THEN
         num_err := f_cta_saldo_fondos_shw(psseguro, NULL, total_cestas_shw,
                                           total_saldo_u_shw, v_det_modinv_shw);

         IF num_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_cta_saldo_fondos_shw', NULL,
                        'parametros: psseguro = ' || psseguro,
                        f_axis_literales(num_err, f_idiomauser));
            RETURN num_err;
         END IF;
      END IF;

      -- Reconversión de aportaciones realizadas entre la primera redistribución y la presente
      num_err := f_redistribuye_aportaciones(psseguro, pfefecto);

      IF num_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_aportaciones',
                     NULL, 'parametros: psseguro = ' || psseguro,
                     f_axis_literales(num_err, f_idiomauser));
         RETURN num_err;
      END IF;

      IF vtieneshw = 1 THEN
         num_err := f_redist_aportaciones_shw(psseguro, pfefecto);

         IF num_err <> 0 THEN
            p_tab_error(f_sysdate, f_user,
                        'PAC_OPERATIVA_FINV.f_redistribuye_aportaciones_shw', NULL,
                        'parametros: psseguro = ' || psseguro,
                        f_axis_literales(num_err, f_idiomauser));
            RETURN num_err;
         END IF;
      END IF;

      SELECT scagrcta.NEXTVAL
        INTO seqgrupo
        FROM DUAL;

      -- Entradas de venta por redistribución
      num_err := f_redistribuye_venta(psseguro, v_det_modinv, pfefecto, sivendecompra,
                                      seqgrupo);

      IF num_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_venta', NULL,
                     'parametros: psseguro = ' || psseguro,
                     f_axis_literales(num_err, f_idiomauser));
         RETURN num_err;
      END IF;

      IF vtieneshw = 1 THEN
         num_err := f_redistribuye_venta_shw(psseguro, v_det_modinv_shw, pfefecto,
                                             sivendecompra_shw, seqgrupo);

         IF num_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_venta', NULL,
                        'parametros: psseguro = ' || psseguro,
                        f_axis_literales(num_err, f_idiomauser));
            RETURN num_err;
         END IF;
      END IF;

      -- Entradas de compra por redistribución
      num_err := f_redistribuye_compra(psseguro, pfefecto, sivendecompra, seqgrupo);

      IF num_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_compra', NULL,
                     'parametros: psseguro = ' || psseguro,
                     f_axis_literales(num_err, f_idiomauser));
         RETURN num_err;
      END IF;

      IF vtieneshw = 1 THEN
         num_err := f_redistribuye_compra_shw(psseguro, pfefecto, sivendecompra_shw, seqgrupo);

         IF num_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_compra_shw',
                        NULL, 'parametros: psseguro = ' || psseguro,
                        f_axis_literales(num_err, f_idiomauser));
            RETURN num_err;
         END IF;
      END IF;

      -- Bug 9424 - 15/04/2009 - RSC - Creación del producto PPJ Dinàmic
      /* INI AFM
      SELECT cgasred
        INTO v_gasred
        FROM seguros_ulk
       WHERE sseguro = psseguro;

      -- Si no tiene definido gasto por redistribución no se aplica gasto
      IF v_gasred IS NOT NULL THEN
      */
         -- Entradas de gastos por redistribución
      num_err := f_redistribuye_gastosredis(psseguro, pfefecto, seqgrupo);

      IF num_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_gastosredis', NULL,
                     'parametros: psseguro = ' || psseguro,
                     f_axis_literales(num_err, f_idiomauser));
         RETURN num_err;
      END IF;

      IF vtieneshw = 1 THEN
         num_err := f_redistribuye_gastosredis_shw(psseguro, pfefecto, seqgrupo);

         IF num_err <> 0 THEN
            p_tab_error(f_sysdate, f_user,
                        'PAC_OPERATIVA_FINV.f_redistribuye_gastosredis_shw', NULL,
                        'parametros: psseguro = ' || psseguro,
                        f_axis_literales(num_err, f_idiomauser));
            RETURN num_err;
         END IF;
      END IF;

      -- Asignamos movimientos de venta y compra si disponemos del valor liquidativo.
      num_err := pac_mantenimiento_fondos_finv.f_redist_asign_unidades(TRUNC(pfefecto),
                                                                       v_sproces, v_nerrores,
                                                                       f_idiomauser, NULL,
                                                                       psseguro);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      IF vtieneshw = 1 THEN
         num_err :=
            pac_mantenimiento_fondos_finv.f_redist_asign_unidades_shw(TRUNC(pfefecto),
                                                                      v_sproces, v_nerrores,
                                                                      f_idiomauser, NULL,
                                                                      psseguro);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      -- Fin Bug 9424
      RETURN(0);
   -- BUG -21546_108724- 08/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
   EXCEPTION
      WHEN OTHERS THEN
         IF nmov%ISOPEN THEN
            CLOSE nmov;
         END IF;

         RETURN 140999;
   END f_redistribucion_fondos;

   FUNCTION f_redistribuye_venta(
      psseguro IN NUMBER,
      pdet_modinv IN tt_det_modinv,
      pfefecto IN DATE,
      sivendecompra IN OUT NUMBER,
      seqgrupo IN NUMBER)
      RETURN NUMBER IS
      xnnumlin       NUMBER;
      contaces       NUMBER;
      existeventa    NUMBER;
      primer         NUMBER := 0;
      -- Bug 10828 - RSC - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      v_f_sysdate    DATE;
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      num_err        axis_literales.slitera%TYPE;
   -- Fin Bug 10828
   BEGIN
      -- Bug 10828 - RSC - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      v_f_sysdate := f_sysdate;

      -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
      SELECT cempres
        INTO v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);

      -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda

      -- Fin Bug 10828
      BEGIN
         SELECT COUNT(*)
           INTO existeventa
           FROM ctaseguro
          WHERE sseguro = psseguro
            AND TRUNC(ffecmov) = TRUNC(pfefecto)
            AND TRUNC(fvalmov) = TRUNC(pfefecto)
            AND imovimi = 0
            AND nunidad IS NULL
            AND cmovimi IN(60, 61);
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_compra', NULL,
                        'parametros: psseguro = ' || psseguro, SQLERRM);
            RETURN 104767;   -- Error a l'esborrar a la taula CTASEGURO
      END;

      IF existeventa = 0 THEN
-- Si ya ha habido una redistribución, no es necesario volver a generar estos movimientos
-- (como mínimo un mov general 60 y un mov detalle 61).
         -- Obtenemos el numero de linia que le toca
         BEGIN
            SELECT NVL(MAX(nnumlin) + 1, 1)
              INTO xnnumlin
              FROM ctaseguro
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 104882;   -- Error al llegir de CTASEGURO
         END;

         IF pdet_modinv.LAST IS NOT NULL THEN
            FOR i IN 1 .. pdet_modinv.LAST LOOP
               IF pdet_modinv(i).vucesta <> 0 THEN
                  -- vendemos unidades
                  sivendecompra := 1;

                  IF primer = 0 THEN
                     -- Insertamos el movimiento general de Venta Redistribución (una sola vez)
                     BEGIN
                        INSERT INTO ctaseguro
                                    (sseguro, fcontab, nnumlin, ffecmov,
                                     fvalmov, cmovimi, imovimi, imovim2, nrecibo, ccalint,
                                     cmovanu, nsinies, smovrec, cesta, nunidad, cestado)
                             VALUES (psseguro, v_f_sysdate, xnnumlin, TRUNC(pfefecto),
                                     TRUNC(pfefecto), 60, 0, NULL, NULL, seqgrupo,
                                     0, NULL, NULL, NULL, NULL, NULL);

                        -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                        IF v_cmultimon = 1 THEN
                           num_err :=
                              pac_oper_monedas.f_update_ctaseguro_monpol(psseguro,
                                                                         v_f_sysdate,
                                                                         xnnumlin,
                                                                         TRUNC(pfefecto));

                           IF num_err <> 0 THEN
                              RETURN num_err;
                           END IF;
                        END IF;
                     -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           p_tab_error(f_sysdate, f_user,
                                       'PAC_OPERATIVA_FINV.f_redistribuye_venta', NULL,
                                       'parametros: psseguro = ' || psseguro, SQLERRM);
                           RETURN 104879;   -- Registre duplicat a CTASEGURO
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user,
                                       'PAC_OPERATIVA_FINV.f_redistribuye_venta', NULL,
                                       'parametros: psseguro = ' || psseguro, SQLERRM);
                           RETURN 102555;
                     -- Error al insertar a la taula CTASEGURO
                     END;

                     BEGIN
                        INSERT INTO ctaseguro_libreta
                                    (sseguro, nnumlin, fcontab, ccapgar, ccapfal, nmovimi,
                                     sintbatch, nnumlib)
                             VALUES (psseguro, xnnumlin, v_f_sysdate, NULL, NULL, NULL,
                                     NULL, NULL);
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user,
                                       'PAC_OPERATIVA_FINV.f_redistribuye_venta', NULL,
                                       'parametros: psseguro = ' || psseguro, SQLERRM);
                           RETURN 102555;
                     -- Error al insertar a la taula CTASEGURO
                     END;

                     xnnumlin := xnnumlin + 1;
                     primer := 1;
                  END IF;

                  BEGIN
                     INSERT INTO ctaseguro
                                 (sseguro, fcontab, nnumlin, ffecmov,
                                  fvalmov, cmovimi, imovimi, imovim2, nrecibo, ccalint,
                                  cmovanu, nsinies, smovrec, cesta, nunidad, cestado)
                          VALUES (psseguro, v_f_sysdate, xnnumlin, TRUNC(pfefecto),
                                  TRUNC(pfefecto), 61, 0, NULL, NULL, seqgrupo,
                                  0, NULL, NULL, pdet_modinv(i).vccesta, NULL, '1');

                     -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     IF v_cmultimon = 1 THEN
                        num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro,
                                                                              v_f_sysdate,
                                                                              xnnumlin,
                                                                              TRUNC(pfefecto));

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;
                     END IF;

                     -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     xnnumlin := xnnumlin + 1;
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        p_tab_error(f_sysdate, f_user,
                                    'PAC_OPERATIVA_FINV.f_redistribuye_venta', NULL,
                                    'parametros: psseguro = ' || psseguro, SQLERRM);
                        RETURN 104879;   -- Registre duplicat a CTASEGURO
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user,
                                    'PAC_OPERATIVA_FINV.f_redistribuye_venta', NULL,
                                    'parametros: psseguro = ' || psseguro, SQLERRM);
                        RETURN 102555;
                  -- Error al insertar a la taula CTASEGURO
                  END;
               END IF;
            END LOOP;
         END IF;
      ELSE
         -- Si ya existia venta hemos de ponere sivendecompra también a 1 ya que si no nos comprará como dios manda
         sivendecompra := 1;
      END IF;

      RETURN 0;
   END f_redistribuye_venta;

   FUNCTION f_redistribuye_venta_shw(
      psseguro IN NUMBER,
      pdet_modinv IN tt_det_modinv,
      pfefecto IN DATE,
      sivendecompra IN OUT NUMBER,
      seqgrupo IN NUMBER)
      RETURN NUMBER IS
      xnnumlin       NUMBER;
      contaces       NUMBER;
      existeventa    NUMBER;
      primer         NUMBER := 0;
      -- Bug 10828 - RSC - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      v_f_sysdate    DATE;
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      num_err        axis_literales.slitera%TYPE;
   -- Fin Bug 10828
   BEGIN
      -- Bug 10828 - RSC - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      v_f_sysdate := f_sysdate;

      -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
      SELECT cempres
        INTO v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);

      -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda

      -- Fin Bug 10828
      BEGIN
         SELECT COUNT(*)
           INTO existeventa
           FROM ctaseguro_shadow
          WHERE sseguro = psseguro
            AND TRUNC(ffecmov) = TRUNC(pfefecto)
            AND TRUNC(fvalmov) = TRUNC(pfefecto)
            AND imovimi = 0
            AND nunidad IS NULL
            AND cmovimi IN(60, 61);
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_venta_shw',
                        NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
            RETURN 104767;   -- Error a l'esborrar a la taula CTASEGURO
      END;

      IF existeventa = 0 THEN
-- Si ya ha habido una redistribución, no es necesario volver a generar estos movimientos
-- (como mínimo un mov general 60 y un mov detalle 61).
         -- Obtenemos el numero de linia que le toca
         BEGIN
            SELECT NVL(MAX(nnumlin) + 1, 1)
              INTO xnnumlin
              FROM ctaseguro_shadow
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 104882;   -- Error al llegir de CTASEGURO
         END;

         IF pdet_modinv.LAST IS NOT NULL THEN
            FOR i IN 1 .. pdet_modinv.LAST LOOP
               IF pdet_modinv(i).vucesta <> 0 THEN
                  -- vendemos unidades
                  sivendecompra := 1;

                  IF primer = 0 THEN
                     -- Insertamos el movimiento general de Venta Redistribución (una sola vez)
                     BEGIN
                        INSERT INTO ctaseguro_shadow
                                    (sseguro, fcontab, nnumlin, ffecmov,
                                     fvalmov, cmovimi, imovimi, imovim2, nrecibo, ccalint,
                                     cmovanu, nsinies, smovrec, cesta, nunidad, cestado)
                             VALUES (psseguro, v_f_sysdate, xnnumlin, TRUNC(pfefecto),
                                     TRUNC(pfefecto), 60, 0, NULL, NULL, seqgrupo,
                                     0, NULL, NULL, NULL, NULL, NULL);

                        -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                        IF v_cmultimon = 1 THEN
                           num_err :=
                              pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro,
                                                                             v_f_sysdate,
                                                                             xnnumlin,
                                                                             TRUNC(pfefecto));

                           IF num_err <> 0 THEN
                              RETURN num_err;
                           END IF;
                        END IF;
                     -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           p_tab_error(f_sysdate, f_user,
                                       'PAC_OPERATIVA_FINV.f_redistribuye_venta_shw', NULL,
                                       'parametros: psseguro = ' || psseguro, SQLERRM);
                           RETURN 104879;   -- Registre duplicat a CTASEGURO
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user,
                                       'PAC_OPERATIVA_FINV.f_redistribuye_venta_shw', NULL,
                                       'parametros: psseguro = ' || psseguro, SQLERRM);
                           RETURN 102555;
                     -- Error al insertar a la taula CTASEGURO
                     END;

                     BEGIN
                        INSERT INTO ctaseguro_libreta_shw
                                    (sseguro, nnumlin, fcontab, ccapgar, ccapfal, nmovimi,
                                     sintbatch, nnumlib)
                             VALUES (psseguro, xnnumlin, v_f_sysdate, NULL, NULL, NULL,
                                     NULL, NULL);
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user,
                                       'PAC_OPERATIVA_FINV.f_redistribuye_venta_shw', NULL,
                                       'parametros: psseguro = ' || psseguro, SQLERRM);
                           RETURN 102555;
                     -- Error al insertar a la taula CTASEGURO
                     END;

                     xnnumlin := xnnumlin + 1;
                     primer := 1;
                  END IF;

                  BEGIN
                     INSERT INTO ctaseguro_shadow
                                 (sseguro, fcontab, nnumlin, ffecmov,
                                  fvalmov, cmovimi, imovimi, imovim2, nrecibo, ccalint,
                                  cmovanu, nsinies, smovrec, cesta, nunidad, cestado)
                          VALUES (psseguro, v_f_sysdate, xnnumlin, TRUNC(pfefecto),
                                  TRUNC(pfefecto), 61, 0, NULL, NULL, seqgrupo,
                                  0, NULL, NULL, pdet_modinv(i).vccesta, NULL, '1');

                     -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     IF v_cmultimon = 1 THEN
                        num_err :=
                           pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro,
                                                                          v_f_sysdate,
                                                                          xnnumlin,
                                                                          TRUNC(pfefecto));

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;
                     END IF;

                     -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     xnnumlin := xnnumlin + 1;
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        p_tab_error(f_sysdate, f_user,
                                    'PAC_OPERATIVA_FINV.f_redistribuye_venta_shw', NULL,
                                    'parametros: psseguro = ' || psseguro, SQLERRM);
                        RETURN 104879;   -- Registre duplicat a CTASEGURO
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user,
                                    'PAC_OPERATIVA_FINV.f_redistribuye_venta_shw', NULL,
                                    'parametros: psseguro = ' || psseguro, SQLERRM);
                        RETURN 102555;
                  -- Error al insertar a la taula CTASEGURO
                  END;
               END IF;
            END LOOP;
         END IF;
      ELSE
         -- Si ya existia venta hemos de ponere sivendecompra también a 1 ya que si no nos comprará como dios manda
         sivendecompra := 1;
      END IF;

      RETURN 0;
   END f_redistribuye_venta_shw;

   FUNCTION f_redistribuye_compra(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      sivendecompra IN OUT NUMBER,
      seqgrupo IN NUMBER,
      pfunds IN t_iax_produlkmodinvfondo DEFAULT NULL)   -- Bug 36746/0211309 - APD - 17/09/2015
      RETURN NUMBER IS
      xnnumlin       NUMBER;
      precio_cesta   NUMBER;

      CURSOR cur_estsegdisin2 IS
         SELECT ccesta, pdistrec
           FROM segdisin2
          WHERE sseguro = psseguro
            AND ffin IS NULL
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM segdisin2
                            WHERE sseguro = psseguro
                              AND ffin IS NULL)
            -- Bug 36746/0211309 - APD - 17/09/2015
            AND((pfunds IS NULL)
                OR(pfunds IS NOT NULL
                   AND f_valida_cesta_switch(ccesta, pfunds) = 1))
                                                                  -- fin Bug 36746/0211309 - APD - 17/09/2015
      ;

      -- Bug 10828 - RSC - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      v_f_sysdate    DATE;
      -- Fin Bug 10828
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      num_err        axis_literales.slitera%TYPE;
   BEGIN
      -- Bug 10828 - RSC - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      v_f_sysdate := f_sysdate;

      -- Fin Bug 10828 - RSC - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)

      -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
      SELECT cempres
        INTO v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);

      -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
      IF sivendecompra = 1 THEN
         -- Borramos redistribuciones antiguas que todavia no se han consolidado
         -- Esto es por si se hacen mas de una redistribución en el dia (al consolidar
         -- hay que consolidar la distribución final)
         BEGIN
            DELETE FROM ctaseguro_libreta
                  WHERE (sseguro, nnumlin, fcontab) IN(
                           SELECT sseguro, nnumlin, fcontab
                             FROM ctaseguro
                            WHERE sseguro = psseguro
                              AND TRUNC(ffecmov) = TRUNC(pfefecto)
                              AND TRUNC(fvalmov) = TRUNC(pfefecto)
                              AND imovimi = 0
                              AND nunidad IS NULL
                              AND cmovimi IN(70, 71));

            DELETE FROM ctaseguro
                  WHERE sseguro = psseguro
                    AND TRUNC(ffecmov) = TRUNC(pfefecto)
                    AND TRUNC(fvalmov) = TRUNC(pfefecto)
                    AND imovimi = 0
                    AND nunidad IS NULL
                    AND cmovimi IN(70, 71);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_compra',
                           NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
               RETURN 104767;   -- Error a l'esborrar a la taula CTASEGURO
         END;

         -- Obtenemos el numero de linia que le toca
         BEGIN
            SELECT NVL(MAX(nnumlin) + 1, 1)
              INTO xnnumlin
              FROM ctaseguro
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 104882;   -- Error al llegir de CTASEGURO
         END;

         -- Insertamos el movimiento general de Compra por redistribución
         BEGIN
            INSERT INTO ctaseguro
                        (sseguro, fcontab, nnumlin, ffecmov, fvalmov,
                         cmovimi, imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies,
                         smovrec)
                 VALUES (psseguro, v_f_sysdate, xnnumlin, TRUNC(pfefecto), TRUNC(pfefecto),
                         70, 0, NULL, NULL, seqgrupo, 0, NULL,
                         NULL);

            -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
            IF v_cmultimon = 1 THEN
               num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro, v_f_sysdate,
                                                                     xnnumlin,
                                                                     TRUNC(pfefecto));

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;
         -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_compra',
                           NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
               RETURN 104879;   -- Registre duplicat a CTASEGURO
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_compra',
                           NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
               RETURN 102555;   -- Error al insertar a la taula CTASEGURO
         END;

         BEGIN
            INSERT INTO ctaseguro_libreta
                        (sseguro, nnumlin, fcontab, ccapgar, ccapfal, nmovimi, sintbatch,
                         nnumlib)
                 VALUES (psseguro, xnnumlin, v_f_sysdate, NULL, NULL, NULL, NULL,
                         NULL);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_compra',
                           NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
               RETURN 102555;   -- Error al insertar a la taula CTASEGURO
         END;

         xnnumlin := xnnumlin + 1;

         FOR regs IN cur_estsegdisin2 LOOP
            --PRECIO UNIDAD DE LA CESTA - aqui siempre se guarda el último valorado --
            /*
            select NVL(iuniact,0) into precio_cesta
            from fondos
            where ccodfon = regs.ccesta;
            */
            BEGIN
               INSERT INTO ctaseguro
                           (sseguro, fcontab, nnumlin, ffecmov,
                            fvalmov, cmovimi, imovimi, imovim2, nrecibo, ccalint, cmovanu,
                            nsinies, smovrec, cesta, nunidad, cestado)
                    VALUES (psseguro, v_f_sysdate, xnnumlin, TRUNC(pfefecto),
                            TRUNC(pfefecto), 71, 0, NULL, NULL, seqgrupo, 0,
                            NULL, NULL, regs.ccesta, NULL, '1');

               -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
               IF v_cmultimon = 1 THEN
                  num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro, v_f_sysdate,
                                                                        xnnumlin,
                                                                        TRUNC(pfefecto));

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END IF;

               -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
               xnnumlin := xnnumlin + 1;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_compra',
                              NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
                  RETURN 104879;   -- Registre duplicat a CTASEGURO
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_compra',
                              NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
                  RETURN 102555;   -- Error al insertar a la taula CTASEGURO
            END;
         END LOOP;
      END IF;

      RETURN 0;
   END f_redistribuye_compra;

   FUNCTION f_redistribuye_compra_shw(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      sivendecompra IN OUT NUMBER,
      seqgrupo IN NUMBER,
      pfunds IN t_iax_produlkmodinvfondo DEFAULT NULL)   -- Bug 36746/0211309 - APD - 17/09/2015
      RETURN NUMBER IS
      xnnumlin       NUMBER;
      precio_cesta   NUMBER;

      CURSOR cur_estsegdisin2 IS
         SELECT ccesta, pdistrec
           FROM segdisin2
          WHERE sseguro = psseguro
            AND ffin IS NULL
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM segdisin2
                            WHERE sseguro = psseguro
                              AND ffin IS NULL)
            -- Bug 36746/0211309 - APD - 17/09/2015
            AND((pfunds IS NULL)
                OR(pfunds IS NOT NULL
                   AND f_valida_cesta_switch(ccesta, pfunds) = 1))
                                                                  -- fin Bug 36746/0211309 - APD - 17/09/2015
      ;

      -- Bug 10828 - RSC - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      v_f_sysdate    DATE;
      -- Fin Bug 10828
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      num_err        axis_literales.slitera%TYPE;
   BEGIN
      -- Bug 10828 - RSC - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      v_f_sysdate := f_sysdate;

      -- Fin Bug 10828 - RSC - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)

      -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
      SELECT cempres
        INTO v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);

      -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
      IF sivendecompra = 1 THEN
         -- Borramos redistribuciones antiguas que todavia no se han consolidado
         -- Esto es por si se hacen mas de una redistribución en el dia (al consolidar
         -- hay que consolidar la distribución final)
         BEGIN
            DELETE FROM ctaseguro_libreta_shw
                  WHERE (sseguro, nnumlin, fcontab) IN(
                           SELECT sseguro, nnumlin, fcontab
                             FROM ctaseguro_shadow
                            WHERE sseguro = psseguro
                              AND TRUNC(ffecmov) = TRUNC(pfefecto)
                              AND TRUNC(fvalmov) = TRUNC(pfefecto)
                              AND imovimi = 0
                              AND nunidad IS NULL
                              AND cmovimi IN(70, 71));

            DELETE FROM ctaseguro_shadow
                  WHERE sseguro = psseguro
                    AND TRUNC(ffecmov) = TRUNC(pfefecto)
                    AND TRUNC(fvalmov) = TRUNC(pfefecto)
                    AND imovimi = 0
                    AND nunidad IS NULL
                    AND cmovimi IN(70, 71);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_compra_shw',
                           NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
               RETURN 104767;   -- Error a l'esborrar a la taula CTASEGURO
         END;

         -- Obtenemos el numero de linia que le toca
         BEGIN
            SELECT NVL(MAX(nnumlin) + 1, 1)
              INTO xnnumlin
              FROM ctaseguro_shadow
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 104882;   -- Error al llegir de CTASEGURO
         END;

         -- Insertamos el movimiento general de Compra por redistribución
         BEGIN
            INSERT INTO ctaseguro_shadow
                        (sseguro, fcontab, nnumlin, ffecmov, fvalmov,
                         cmovimi, imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies,
                         smovrec)
                 VALUES (psseguro, v_f_sysdate, xnnumlin, TRUNC(pfefecto), TRUNC(pfefecto),
                         70, 0, NULL, NULL, seqgrupo, 0, NULL,
                         NULL);

            -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
            IF v_cmultimon = 1 THEN
               num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro,
                                                                         v_f_sysdate,
                                                                         xnnumlin,
                                                                         TRUNC(pfefecto));

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;
         -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_compra_shw',
                           NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
               RETURN 104879;   -- Registre duplicat a CTASEGURO
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_compra_shw',
                           NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
               RETURN 102555;   -- Error al insertar a la taula CTASEGURO
         END;

         BEGIN
            INSERT INTO ctaseguro_libreta_shw
                        (sseguro, nnumlin, fcontab, ccapgar, ccapfal, nmovimi, sintbatch,
                         nnumlib)
                 VALUES (psseguro, xnnumlin, v_f_sysdate, NULL, NULL, NULL, NULL,
                         NULL);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_compra_shw',
                           NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
               RETURN 102555;   -- Error al insertar a la taula CTASEGURO
         END;

         xnnumlin := xnnumlin + 1;

         FOR regs IN cur_estsegdisin2 LOOP
            --PRECIO UNIDAD DE LA CESTA - aqui siempre se guarda el último valorado --
            /*
            select NVL(iuniact,0) into precio_cesta
            from fondos
            where ccodfon = regs.ccesta;
            */
            BEGIN
               INSERT INTO ctaseguro_shadow
                           (sseguro, fcontab, nnumlin, ffecmov,
                            fvalmov, cmovimi, imovimi, imovim2, nrecibo, ccalint, cmovanu,
                            nsinies, smovrec, cesta, nunidad, cestado)
                    VALUES (psseguro, v_f_sysdate, xnnumlin, TRUNC(pfefecto),
                            TRUNC(pfefecto), 71, 0, NULL, NULL, seqgrupo, 0,
                            NULL, NULL, regs.ccesta, NULL, '1');

               -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
               IF v_cmultimon = 1 THEN
                  num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro,
                                                                            v_f_sysdate,
                                                                            xnnumlin,
                                                                            TRUNC(pfefecto));

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END IF;

               -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
               xnnumlin := xnnumlin + 1;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  p_tab_error(f_sysdate, f_user,
                              'PAC_OPERATIVA_FINV.f_redistribuye_compra_shw', NULL,
                              'parametros: psseguro = ' || psseguro, SQLERRM);
                  RETURN 104879;   -- Registre duplicat a CTASEGURO
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user,
                              'PAC_OPERATIVA_FINV.f_redistribuye_compra_shw', NULL,
                              'parametros: psseguro = ' || psseguro, SQLERRM);
                  RETURN 102555;   -- Error al insertar a la taula CTASEGURO
            END;
         END LOOP;
      END IF;

      RETURN 0;
   END f_redistribuye_compra_shw;

   FUNCTION f_redistribuye_gastosredis(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      seqgrupo IN NUMBER,
      pfunds IN t_iax_produlkmodinvfondo DEFAULT NULL)   -- Bug 36746/0211309 - APD - 17/09/2015
      RETURN NUMBER IS
      xnnumlin       NUMBER;
      iuniacts       NUMBER;
      precio_cesta   NUMBER;
      v_provision    NUMBER;
      gredanual      NUMBER;
      num_err        NUMBER;
      imovimo        NUMBER;
      vacumpercent   NUMBER := 0;
      vacumrounded   NUMBER := 0;

      CURSOR cur_estsegdisin2 IS
         SELECT ccesta, pdistrec
           FROM segdisin2
          WHERE sseguro = psseguro
            AND ffin IS NULL
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM segdisin2
                            WHERE sseguro = psseguro
                              AND ffin IS NULL)
            -- Bug 36746/0211309 - APD - 17/09/2015
            AND((pfunds IS NULL)
                OR(pfunds IS NOT NULL
                   AND f_valida_cesta_switch(ccesta, pfunds) = 1))
                                                                  -- fin Bug 36746/0211309 - APD - 17/09/2015
      ;

      -- Bug 10828 - RSC - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      v_f_sysdate    DATE;
      -- Fin Bug 10828
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
   BEGIN
      -- Bug 10828 - RSC - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      v_f_sysdate := f_sysdate;

      -- Fin Bug 10828 - RSC - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)

      -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
      SELECT cempres
        INTO v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);
      num_err := f_gastos_redistribucion(psseguro, pfefecto, gredanual);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      --
      -- Si no hay gastos de redistribución salimos
      --
      IF NVL(gredanual, 0) = 0 THEN
         RETURN 0;
      END IF;

      -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
      -- Borramos redistribuciones antiguas que todavia no se han consolidado
      -- Esto es por si se hacen mas de una redistribución en el dia (al consolidar
      -- hay que consolidar la distribución final)
      BEGIN
         DELETE FROM ctaseguro_libreta
               WHERE sseguro = psseguro
                 AND nnumlin IN(SELECT nnumlin
                                  FROM ctaseguro
                                 WHERE sseguro = psseguro
                                   AND TRUNC(ffecmov) = TRUNC(pfefecto)
                                   AND TRUNC(fvalmov) = TRUNC(pfefecto)
                                   AND imovimi = 0
                                   AND nunidad IS NULL
                                   AND cmovimi IN(80, 81));

         DELETE FROM ctaseguro
               WHERE sseguro = psseguro
                 AND TRUNC(ffecmov) = TRUNC(pfefecto)
                 AND TRUNC(fvalmov) = TRUNC(pfefecto)
                 AND imovimi = 0
                 AND nunidad IS NULL
                 AND cmovimi IN(80, 81);
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_gastosredis',
                        NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
            RETURN 104767;   -- Error a l'esborrar a la taula CTASEGURO
      END;

      -- Obtenemos el numero de linia que le toca
      BEGIN
         SELECT NVL(MAX(nnumlin) + 1, 1)
           INTO xnnumlin
           FROM ctaseguro
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 104882;   -- Error al llegir de CTASEGURO
      END;

      -- Insertamos el movimiento general de Compra por redistribución
      BEGIN
         INSERT INTO ctaseguro
                     (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi,
                      imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec)
              VALUES (psseguro, v_f_sysdate, xnnumlin, TRUNC(pfefecto), TRUNC(pfefecto), 80,
                      0, NULL, NULL, seqgrupo, 0, NULL, NULL);

         -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
         IF v_cmultimon = 1 THEN
            num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro, v_f_sysdate,
                                                                  xnnumlin, TRUNC(pfefecto));

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;
      -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_gastosredis',
                        NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
            RETURN 104879;   -- Registre duplicat a CTASEGURO
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_gastosredis',
                        NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
            RETURN 102555;   -- Error al insertar a la taula CTASEGURO
      END;

      -- Creamos un registro en
      BEGIN
         INSERT INTO ctaseguro_libreta
                     (sseguro, nnumlin, fcontab, ccapgar, ccapfal, nmovimi, sintbatch, nnumlib)
              VALUES (psseguro, xnnumlin, v_f_sysdate, NULL, NULL, NULL, NULL, NULL);
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_gastosredis',
                        NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
            RETURN 102555;   -- Error al insertar a la taula CTASEGURO
      END;

      xnnumlin := xnnumlin + 1;

      FOR regs IN cur_estsegdisin2 LOOP
         --PRECIO UNIDAD DE LA CESTA - aqui siempre se guarda el último valorado --
         /*
         select NVL(iuniact,0) into precio_cesta
         from fondos
         where ccodfon = regs.ccesta;
         */
         BEGIN
            INSERT INTO ctaseguro
                        (sseguro, fcontab, nnumlin, ffecmov, fvalmov,
                         cmovimi, imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies,
                         smovrec, cesta, nunidad, cestado)
                 VALUES (psseguro, v_f_sysdate, xnnumlin, TRUNC(pfefecto), TRUNC(pfefecto),
                         81, 0, NULL, NULL, seqgrupo, 0, NULL,
                         NULL, regs.ccesta, NULL, '1');

            -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
            IF v_cmultimon = 1 THEN
               num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro, v_f_sysdate,
                                                                     xnnumlin,
                                                                     TRUNC(pfefecto));

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;

            -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
            xnnumlin := xnnumlin + 1;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_gastosredis',
                           NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
               RETURN 104879;   -- Registre duplicat a CTASEGURO
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_gastosredis',
                           NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
               RETURN 102555;   -- Error al insertar a la taula CTASEGURO
         END;
      END LOOP;

      RETURN 0;
   END f_redistribuye_gastosredis;

   FUNCTION f_redistribuye_gastosredis_shw(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      seqgrupo IN NUMBER,
      pfunds IN t_iax_produlkmodinvfondo DEFAULT NULL)   -- Bug 36746/0211309 - APD - 17/09/2015
      RETURN NUMBER IS
      xnnumlin       NUMBER;
      precio_cesta   NUMBER;
      v_provision    NUMBER;
      gredanual      NUMBER;
      num_err        NUMBER;

      CURSOR cur_estsegdisin2 IS
         SELECT ccesta, pdistrec
           FROM segdisin2
          WHERE sseguro = psseguro
            AND ffin IS NULL
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM segdisin2
                            WHERE sseguro = psseguro
                              AND ffin IS NULL)
            -- Bug 36746/0211309 - APD - 17/09/2015
            AND((pfunds IS NULL)
                OR(pfunds IS NOT NULL
                   AND f_valida_cesta_switch(ccesta, pfunds) = 1))
                                                                  -- fin Bug 36746/0211309 - APD - 17/09/2015
      ;

      -- Bug 10828 - RSC - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      v_f_sysdate    DATE;
      -- Fin Bug 10828
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
   BEGIN
      -- Bug 10828 - RSC - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      v_f_sysdate := f_sysdate;

      -- Fin Bug 10828 - RSC - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)

      -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
      SELECT cempres
        INTO v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);

      -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
      -- Borramos redistribuciones antiguas que todavia no se han consolidado
      -- Esto es por si se hacen mas de una redistribución en el dia (al consolidar
      -- hay que consolidar la distribución final)
      BEGIN
         DELETE FROM ctaseguro_shadow
               WHERE sseguro = psseguro
                 AND TRUNC(ffecmov) = TRUNC(pfefecto)
                 AND TRUNC(fvalmov) = TRUNC(pfefecto)
                 AND imovimi = 0
                 AND nunidad IS NULL
                 AND cmovimi IN(80, 81);
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user,
                        'PAC_OPERATIVA_FINV.f_redistribuye_gastosredis_shw', NULL,
                        'parametros: psseguro = ' || psseguro, SQLERRM);
            RETURN 104767;   -- Error a l'esborrar a la taula CTASEGURO
      END;

      -- Obtenemos el numero de linia que le toca
      BEGIN
         SELECT NVL(MAX(nnumlin) + 1, 1)
           INTO xnnumlin
           FROM ctaseguro_shadow
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 104882;   -- Error al llegir de CTASEGURO
      END;

      /*
        v_provision := ff_valor_provision(psseguro, to_number(to_char(pfefecto,'yyyymmdd')));
        num_err := f_gastos_redistribucion_anual(psseguro, v_provision, gredanual);
        IF num_err <> 0 THEN
          RETURN num_err;
        END IF;
      */

      -- Insertamos el movimiento general de Compra por redistribución
      BEGIN
         INSERT INTO ctaseguro_shadow
                     (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi,
                      imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec)
              VALUES (psseguro, v_f_sysdate, xnnumlin, TRUNC(pfefecto), TRUNC(pfefecto), 80,
                      0, NULL, NULL, seqgrupo, 0, NULL, NULL);

         -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
         IF v_cmultimon = 1 THEN
            num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro, v_f_sysdate,
                                                                      xnnumlin,
                                                                      TRUNC(pfefecto));

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;
      -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            p_tab_error(f_sysdate, f_user,
                        'PAC_OPERATIVA_FINV.f_redistribuye_gastosredis_shw', NULL,
                        'parametros: psseguro = ' || psseguro, SQLERRM);
            RETURN 104879;   -- Registre duplicat a CTASEGURO
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user,
                        'PAC_OPERATIVA_FINV.f_redistribuye_gastosredis_shw', NULL,
                        'parametros: psseguro = ' || psseguro, SQLERRM);
            RETURN 102555;   -- Error al insertar a la taula CTASEGURO
      END;

      -- Creamos un registro en
      BEGIN
         INSERT INTO ctaseguro_libreta_shw
                     (sseguro, nnumlin, fcontab, ccapgar, ccapfal, nmovimi, sintbatch, nnumlib)
              VALUES (psseguro, xnnumlin, v_f_sysdate, NULL, NULL, NULL, NULL, NULL);
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user,
                        'PAC_OPERATIVA_FINV.f_redistribuye_gastosredis_shw', NULL,
                        'parametros: psseguro = ' || psseguro, SQLERRM);
            RETURN 102555;   -- Error al insertar a la taula CTASEGURO
      END;

      xnnumlin := xnnumlin + 1;

      FOR regs IN cur_estsegdisin2 LOOP
         --PRECIO UNIDAD DE LA CESTA - aqui siempre se guarda el último valorado --
         /*
         select NVL(iuniact,0) into precio_cesta
         from fondos
         where ccodfon = regs.ccesta;
         */
         BEGIN
            INSERT INTO ctaseguro_shadow
                        (sseguro, fcontab, nnumlin, ffecmov, fvalmov,
                         cmovimi, imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies,
                         smovrec, cesta, nunidad, cestado)
                 VALUES (psseguro, v_f_sysdate, xnnumlin, TRUNC(pfefecto), TRUNC(pfefecto),
                         81, 0, NULL, NULL, seqgrupo, 0, NULL,
                         NULL, regs.ccesta, NULL, '1');

            -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
            IF v_cmultimon = 1 THEN
               num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro,
                                                                         v_f_sysdate,
                                                                         xnnumlin,
                                                                         TRUNC(pfefecto));

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;

            -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
            xnnumlin := xnnumlin + 1;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               p_tab_error(f_sysdate, f_user,
                           'PAC_OPERATIVA_FINV.f_redistribuye_gastosredis_shw', NULL,
                           'parametros: psseguro = ' || psseguro, SQLERRM);
               RETURN 104879;   -- Registre duplicat a CTASEGURO
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user,
                           'PAC_OPERATIVA_FINV.f_redistribuye_gastosredis_shw', NULL,
                           'parametros: psseguro = ' || psseguro, SQLERRM);
               RETURN 102555;   -- Error al insertar a la taula CTASEGURO
         END;
      END LOOP;

      RETURN 0;
   END f_redistribuye_gastosredis_shw;

   FUNCTION f_redistribuye_aportaciones(psseguro IN NUMBER, pfefecto IN DATE)
      RETURN NUMBER IS
      xnnumlin       NUMBER;
      num_err        NUMBER;
      borrado        NUMBER;

      CURSOR cur_aportaciones IS
         SELECT fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi, imovim2, ccalint,
                nrecibo, nsinies, cmovanu, smovrec
           FROM ctaseguro
          WHERE sseguro = psseguro
            AND TRUNC(fvalmov) = TRUNC(pfefecto)
            AND cmovimi IN(1, 2, 4);

      CURSOR cur_det_aport(pxnumlin IN NUMBER) IS
         SELECT fcontab, nnumlin, cmovimi, imovimi, cesta, fasign
           FROM ctaseguro
          WHERE sseguro = psseguro
            AND TRUNC(fvalmov) = TRUNC(pfefecto)
            AND nnumlin > pxnumlin;

      CURSOR cur_estsegdisin2 IS
         SELECT ccesta, pdistrec
           FROM segdisin2
          WHERE sseguro = psseguro
            AND ffin IS NULL
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM segdisin2
                            WHERE sseguro = psseguro
                              AND ffin IS NULL);

      -- RSC 28/01/2008
      vacumpercent   NUMBER := 0;
      vimport        NUMBER := 0;
      vacumrounded   NUMBER := 0;
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
   BEGIN
      -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
      SELECT cempres
        INTO v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);

      -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
      -- Obtenemos el numero de linia que le toca
      BEGIN
         SELECT NVL(MAX(nnumlin) + 1, 1)
           INTO xnnumlin
           FROM ctaseguro
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 104882;   -- Error al llegir de CTASEGURO
      END;

      FOR regs IN cur_aportaciones LOOP
         borrado := 0;

         -- LOOP para borrar la aportación antigua
         FOR regs2 IN cur_det_aport(regs.nnumlin) LOOP
            IF regs2.fasign IS NULL THEN
               IF regs2.cmovimi <> 45 THEN
                  EXIT;
               ELSE
                  borrado := 1;

                  BEGIN
                     DELETE FROM ctaseguro
                           WHERE sseguro = psseguro
                             AND fcontab = regs2.fcontab
                             AND nnumlin = regs2.nnumlin;
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user,
                                    'PAC_OPERATIVA_FINV.f_redistribuye_aportaciones', NULL,
                                    'parametros: psseguro = ' || psseguro, SQLERRM);
                        RETURN 104767;
                  -- Error a l'esborrar a la taula CTASEGURO
                  END;
               END IF;
            END IF;
         END LOOP;

         -- LOOP para distribuir la aportación
         IF borrado = 1 THEN
            -- Insertamos una repetición de la linea de aportación (esto es solo por mantener las lineas de
            -- aportaciones de manera contigua)
            BEGIN
               INSERT INTO ctaseguro
                           (sseguro, fcontab, nnumlin, ffecmov, fvalmov,
                            cmovimi, imovimi, imovim2, nrecibo,
                            ccalint, cmovanu, nsinies, smovrec)
                    VALUES (psseguro, regs.fcontab, xnnumlin, regs.ffecmov, regs.fvalmov,
                            regs.cmovimi, regs.imovimi, regs.imovim2, regs.nrecibo,
                            regs.ccalint, regs.cmovanu, regs.nsinies, regs.smovrec);

               -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
               IF v_cmultimon = 1 THEN
                  num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro,
                                                                        regs.fcontab,
                                                                        xnnumlin,
                                                                        regs.fvalmov);

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

            BEGIN
               INSERT INTO ctaseguro_libreta
                           (sseguro, nnumlin, fcontab, ccapgar, ccapfal, nmovimi, sintbatch,
                            nnumlib)
                    VALUES (psseguro, xnnumlin, regs.fcontab, NULL, NULL, NULL, NULL,
                            NULL);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  RETURN 104879;   -- Registre duplicat a CTASEGURO
               WHEN OTHERS THEN
                  RETURN 102555;   -- Error al insertar a la taula CTASEGURO
            END;

            xnnumlin := xnnumlin + 1;

            BEGIN
               DELETE FROM ctaseguro_libreta
                     WHERE sseguro = psseguro
                       AND fcontab = regs.fcontab
                       AND nnumlin = regs.nnumlin;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user,
                              'PAC_OPERATIVA_FINV.f_redistribuye_aportaciones', NULL,
                              'parametros: psseguro = ' || psseguro, SQLERRM);
                  RETURN 102555;   -- Error a l'esborrar a la taula CTASEGURO
            END;

            -- Borramos la linea original de aportación ya que hemos borrado sus consiguientes movimientos 45
            BEGIN
               DELETE FROM ctaseguro
                     WHERE sseguro = psseguro
                       AND fcontab = regs.fcontab
                       AND nnumlin = regs.nnumlin;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user,
                              'PAC_OPERATIVA_FINV.f_redistribuye_aportaciones', NULL,
                              'parametros: psseguro = ' || psseguro, SQLERRM);
                  RETURN 102555;   -- Error a l'esborrar a la taula CTASEGURO
            END;

            FOR regs3 IN cur_estsegdisin2 LOOP
               --Calcula les distribucions
               vacumpercent := vacumpercent + regs.imovimi *(regs3.pdistrec / 100);
               vimport := ROUND(vacumpercent - vacumrounded, 2);
               vacumrounded := vacumrounded + ROUND(vacumpercent - vacumrounded, 2);

               BEGIN
                  INSERT INTO ctaseguro
                              (sseguro, fcontab, nnumlin, ffecmov, fvalmov,
                               cmovimi, imovimi, imovim2, nrecibo, ccalint, cmovanu,
                               nsinies, smovrec, cesta, cestado)
                       VALUES (psseguro, regs.fcontab, xnnumlin, regs.ffecmov, regs.fvalmov,
                               45, vimport, NULL, regs.nrecibo, regs.ccalint, regs.cmovanu,
                               regs.nsinies, regs.smovrec, regs3.ccesta, '1');

                  -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  IF v_cmultimon = 1 THEN
                     num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro,
                                                                           regs.fcontab,
                                                                           xnnumlin,
                                                                           regs.fvalmov);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  xnnumlin := xnnumlin + 1;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user,
                                 'PAC_OPERATIVA_FINV.f_redistribuye_aportaciones', NULL,
                                 'parametros: psseguro = ' || psseguro, SQLERRM);
                     RETURN 102555;   -- Error al insertar a la taula CTASEGURO
               END;
            END LOOP;
         END IF;
      END LOOP;

      RETURN 0;
   END f_redistribuye_aportaciones;

   FUNCTION f_redist_aportaciones_shw(psseguro IN NUMBER, pfefecto IN DATE)
      RETURN NUMBER IS
      xnnumlin       NUMBER;
      num_err        NUMBER;
      borrado        NUMBER;

      CURSOR cur_aportaciones IS
         SELECT fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi, imovim2, ccalint,
                nrecibo, nsinies, cmovanu, smovrec
           FROM ctaseguro_shadow
          WHERE sseguro = psseguro
            AND TRUNC(fvalmov) = TRUNC(pfefecto)
            AND cmovimi IN(1, 2, 4);

      CURSOR cur_det_aport(pxnumlin IN NUMBER) IS
         SELECT fcontab, nnumlin, cmovimi, imovimi, cesta, fasign
           FROM ctaseguro_shadow
          WHERE sseguro = psseguro
            AND TRUNC(fvalmov) = TRUNC(pfefecto)
            AND nnumlin > pxnumlin;

      CURSOR cur_estsegdisin2 IS
         SELECT ccesta, pdistrec
           FROM segdisin2
          WHERE sseguro = psseguro
            AND ffin IS NULL
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM segdisin2
                            WHERE sseguro = psseguro
                              AND ffin IS NULL);

      -- RSC 28/01/2008
      vacumpercent   NUMBER := 0;
      vimport        NUMBER := 0;
      vacumrounded   NUMBER := 0;
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
   BEGIN
      -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
      SELECT cempres
        INTO v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);

      -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
      -- Obtenemos el numero de linia que le toca
      BEGIN
         SELECT NVL(MAX(nnumlin) + 1, 1)
           INTO xnnumlin
           FROM ctaseguro_shadow
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 104882;   -- Error al llegir de CTASEGURO
      END;

      FOR regs IN cur_aportaciones LOOP
         borrado := 0;

         -- LOOP para borrar la aportación antigua
         FOR regs2 IN cur_det_aport(regs.nnumlin) LOOP
            IF regs2.fasign IS NULL THEN
               IF regs2.cmovimi <> 45 THEN
                  EXIT;
               ELSE
                  borrado := 1;

                  BEGIN
                     DELETE FROM ctaseguro_shadow
                           WHERE sseguro = psseguro
                             AND fcontab = regs2.fcontab
                             AND nnumlin = regs2.nnumlin;
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user,
                                    'PAC_OPERATIVA_FINV.f_redistribuye_aportaciones_shw',
                                    NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
                        RETURN 104767;
                  -- Error a l'esborrar a la taula CTASEGURO
                  END;
               END IF;
            END IF;
         END LOOP;

         -- LOOP para distribuir la aportación
         IF borrado = 1 THEN
            -- Insertamos una repetición de la linea de aportación (esto es solo por mantener las lineas de
            -- aportaciones de manera contigua)
            BEGIN
               INSERT INTO ctaseguro_shadow
                           (sseguro, fcontab, nnumlin, ffecmov, fvalmov,
                            cmovimi, imovimi, imovim2, nrecibo,
                            ccalint, cmovanu, nsinies, smovrec)
                    VALUES (psseguro, regs.fcontab, xnnumlin, regs.ffecmov, regs.fvalmov,
                            regs.cmovimi, regs.imovimi, regs.imovim2, regs.nrecibo,
                            regs.ccalint, regs.cmovanu, regs.nsinies, regs.smovrec);

               -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
               IF v_cmultimon = 1 THEN
                  num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro,
                                                                            regs.fcontab,
                                                                            xnnumlin,
                                                                            regs.fvalmov);

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

            BEGIN
               INSERT INTO ctaseguro_libreta_shw
                           (sseguro, nnumlin, fcontab, ccapgar, ccapfal, nmovimi, sintbatch,
                            nnumlib)
                    VALUES (psseguro, xnnumlin, regs.fcontab, NULL, NULL, NULL, NULL,
                            NULL);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  RETURN 104879;   -- Registre duplicat a CTASEGURO
               WHEN OTHERS THEN
                  RETURN 102555;   -- Error al insertar a la taula CTASEGURO
            END;

            xnnumlin := xnnumlin + 1;

            BEGIN
               DELETE FROM ctaseguro_libreta_shw
                     WHERE sseguro = psseguro
                       AND fcontab = regs.fcontab
                       AND nnumlin = regs.nnumlin;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user,
                              'PAC_OPERATIVA_FINV.f_redistribuye_aportaciones_shw', NULL,
                              'parametros: psseguro = ' || psseguro, SQLERRM);
                  RETURN 102555;   -- Error a l'esborrar a la taula CTASEGURO
            END;

            -- Borramos la linea original de aportación ya que hemos borrado sus consiguientes movimientos 45
            BEGIN
               DELETE FROM ctaseguro_shadow
                     WHERE sseguro = psseguro
                       AND fcontab = regs.fcontab
                       AND nnumlin = regs.nnumlin;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user,
                              'PAC_OPERATIVA_FINV.f_redistribuye_aportaciones_shw', NULL,
                              'parametros: psseguro = ' || psseguro, SQLERRM);
                  RETURN 102555;   -- Error a l'esborrar a la taula CTASEGURO
            END;

            FOR regs3 IN cur_estsegdisin2 LOOP
               --Calcula les distribucions
               vacumpercent := vacumpercent + regs.imovimi *(regs3.pdistrec / 100);
               vimport := ROUND(vacumpercent - vacumrounded, 2);
               vacumrounded := vacumrounded + ROUND(vacumpercent - vacumrounded, 2);

               BEGIN
                  INSERT INTO ctaseguro_shadow
                              (sseguro, fcontab, nnumlin, ffecmov, fvalmov,
                               cmovimi, imovimi, imovim2, nrecibo, ccalint, cmovanu,
                               nsinies, smovrec, cesta, cestado)
                       VALUES (psseguro, regs.fcontab, xnnumlin, regs.ffecmov, regs.fvalmov,
                               45, vimport, NULL, regs.nrecibo, regs.ccalint, regs.cmovanu,
                               regs.nsinies, regs.smovrec, regs3.ccesta, '1');

                  -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  IF v_cmultimon = 1 THEN
                     num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro,
                                                                               regs.fcontab,
                                                                               xnnumlin,
                                                                               regs.fvalmov);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  xnnumlin := xnnumlin + 1;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user,
                                 'PAC_OPERATIVA_FINV.f_redistribuye_aportaciones_shw', NULL,
                                 'parametros: psseguro = ' || psseguro, SQLERRM);
                     RETURN 102555;   -- Error al insertar a la taula CTASEGURO
               END;
            END LOOP;
         END IF;
      END LOOP;

      RETURN 0;
   END f_redist_aportaciones_shw;

   /********************************************************************************************
       RSC 17-10-2007.
       Obtiene los códigos de modelos de inversión de la tabla segdisin2. No se guarda en
       ningun sitio los códigos de modelo pero sin embargo si guardamos todos los movimientos
       de las distribuciones de cestas. Por tanto podemos extraer los códigos de perfiles
       de inversión.

       Esta función se ha desarrollado para la libreria tfcon031.fmb.
       Y filtra de todos los movimientos solo aquellos que sean de suplemento por redistribución.
   **********************************************************************************************/
   FUNCTION ff_get_movimis_segdisin2(psseguro IN NUMBER, pcidioma IN NUMBER)
      RETURN tt_mov_modinv IS
      nummovimis     NUMBER;
      contamatch     NUMBER;
      v_cramo        NUMBER;
      v_cmodali      NUMBER;
      v_ctipseg      NUMBER;
      v_ccolect      NUMBER;
      v_sproduc      NUMBER;

      CURSOR cur_modinv(
         pcramo IN NUMBER,
         pcmodali IN NUMBER,
         pctipseg IN NUMBER,
         pccolect IN NUMBER) IS
         SELECT DISTINCT cmodinv
                    FROM codimodelosinversion
                   WHERE cramo = pcramo
                     AND cmodali = pcmodali
                     AND ctipseg = pctipseg
                     AND ccolect = pccolect;

      v_movi         NUMBER;
      v_finicio      DATE;
      v_cmodinv      NUMBER;
      v_tmodinv      VARCHAR2(50);
      v_m_modinv     tt_mov_modinv;
      i              NUMBER;
      motmovseg      NUMBER;
      v_contamod     NUMBER;
      trobat         NUMBER;

      FUNCTION f_mov_modinv(
         pmovimi IN NUMBER,
         pfecha IN DATE,
         pcmodinv IN NUMBER,
         ptmodinv IN VARCHAR2)
         RETURN rt_mov_modinv IS
         v_mov_modinv   rt_mov_modinv;
      BEGIN
         v_mov_modinv.vnmovimi := pmovimi;
         v_mov_modinv.vfinicio := pfecha;
         v_mov_modinv.vcmodinv := pcmodinv;
         v_mov_modinv.vtmodinv := ptmodinv;
         RETURN(v_mov_modinv);
      END;
   BEGIN
      SELECT MAX(nmovimi)
        INTO nummovimis
        FROM segdisin2
       WHERE sseguro = psseguro;

      SELECT cramo, cmodali, ctipseg, ccolect, sproduc
        INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

      i := nummovimis;

      WHILE i >= 1 LOOP
         FOR regs IN cur_modinv(v_cramo, v_cmodali, v_ctipseg, v_ccolect) LOOP
            SELECT COUNT(1)
              INTO contamatch
              FROM (SELECT ccodfon, pinvers
                      FROM modinvfondo
                     WHERE cmodinv = regs.cmodinv
                       AND cramo = v_cramo
                       AND cmodali = v_cmodali
                       AND ctipseg = v_ctipseg
                       AND ccolect = v_ccolect
                    MINUS
                    SELECT ccesta, pdistrec
                      FROM segdisin2
                     WHERE sseguro = psseguro
                       AND nmovimi = i);

            SELECT COUNT(*)
              INTO v_contamod
              FROM modinvfondo
             WHERE cmodinv = f_parproductos_v(v_sproduc, 'PERFIL_LIBRE')
               AND cramo = v_cramo
               AND cmodali = v_cmodali
               AND ctipseg = v_ctipseg
               AND ccolect = v_ccolect;

            SELECT cmotmov
              INTO motmovseg
              FROM movseguro
             WHERE sseguro = psseguro
               AND nmovimi = i;

            IF contamatch = 0 THEN   -- (contamatch = v_contamod) --> perfil Libre
               BEGIN
                  SELECT DISTINCT i, finicio, regs.cmodinv
                             INTO v_movi, v_finicio, v_cmodinv
                             FROM segdisin2
                            WHERE sseguro = psseguro
                              AND nmovimi = i;
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_movi IS NOT NULL
                  AND v_finicio IS NOT NULL
                  AND v_cmodinv IS NOT NULL THEN
                  SELECT tmodinv
                    INTO v_tmodinv
                    FROM codimodelosinversion
                   WHERE cmodinv = v_cmodinv
                     AND cidioma = pcidioma;

                  IF motmovseg = 526
                     OR motmovseg = 100 THEN   --Modificación del perfil de inversión o Alta Póliza
                     v_m_modinv(NVL(v_m_modinv.LAST, 0) + 1) :=
                                         f_mov_modinv(v_movi, v_finicio, v_cmodinv, v_tmodinv);
                  END IF;
               END IF;
            ELSIF contamatch = v_contamod THEN
               BEGIN
                  SELECT DISTINCT i, finicio, regs.cmodinv
                             INTO v_movi, v_finicio, v_cmodinv
                             FROM segdisin2
                            WHERE sseguro = psseguro
                              AND nmovimi = i;
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               IF v_movi IS NOT NULL
                  AND v_finicio IS NOT NULL
                  AND v_cmodinv IS NOT NULL THEN
                  SELECT tmodinv
                    INTO v_tmodinv
                    FROM codimodelosinversion
                   WHERE cmodinv = v_cmodinv
                     AND cidioma = pcidioma;

                  IF motmovseg = 526
                     OR motmovseg = 100 THEN   --Modificación del perfil de inversión o Alta Póliza
                     trobat := 0;

                     IF v_m_modinv.LAST IS NOT NULL THEN
                        FOR j IN 1 .. v_m_modinv.LAST LOOP
                           IF v_m_modinv(j).vnmovimi = v_movi THEN
                              trobat := 1;
                           END IF;

                           IF trobat = 0
                              AND j = v_m_modinv.LAST THEN
                              v_m_modinv(NVL(v_m_modinv.LAST, 0) + 1) :=
                                         f_mov_modinv(v_movi, v_finicio, v_cmodinv, v_tmodinv);
                           END IF;
                        END LOOP;
                     ELSE
                        v_m_modinv(NVL(v_m_modinv.LAST, 0) + 1) :=
                                         f_mov_modinv(v_movi, v_finicio, v_cmodinv, v_tmodinv);
                     END IF;
                  END IF;
               END IF;
            END IF;
         END LOOP;

         i := i - 1;
      END LOOP;

      RETURN v_m_modinv;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.ff_get_movimis_segdisin2', NULL,
                     'parametros: psseguro = ' || psseguro, SQLERRM);
         RETURN v_m_modinv;   -- Error
   END ff_get_movimis_segdisin2;

   /********************************************************************************************
       RSC 22-01-2007.
       Si la distribución grabada en ESTSEGDISIN2 para el movimiendo "nmovimi" corresponde a algún
       modelo de inversión predefinido en la base de datos, retorna una variable con el modelo
       de inversión al cual hace referencia.

       (Esta función se ha desarrollado en el contexto de un suplemento de redistribución de cartera.
       La utilidad reside en la detección de una distribución predefinida en la base de datos cuando
       el usuario escoge manualmente una distribución LIBRE que justamente coincide con una predefinida
       y que por tanto es absurdo que sea LIBRE.)
   **********************************************************************************************/
   FUNCTION ff_get_segdisin2_nmovimi(psseguro IN NUMBER, nmovimi IN NUMBER, pcidioma IN NUMBER)
      RETURN tt_mov_modinv IS
      contamatch     NUMBER;
      v_cramo        NUMBER;
      v_cmodali      NUMBER;
      v_ctipseg      NUMBER;
      v_ccolect      NUMBER;
      v_sproduc      NUMBER;

      CURSOR cur_modinv(
         pcramo IN NUMBER,
         pcmodali IN NUMBER,
         pctipseg IN NUMBER,
         pccolect IN NUMBER,
         psproduc IN NUMBER) IS
         SELECT DISTINCT cmodinv
                    FROM codimodelosinversion
                   WHERE cramo = pcramo
                     AND cmodali = pcmodali
                     AND ctipseg = pctipseg
                     AND ccolect = pccolect
                     AND cmodinv <> f_parproductos_v(psproduc, 'PERFIL_LIBRE');

      v_movi         NUMBER;
      v_finicio      DATE;
      v_cmodinv      NUMBER;
      v_tmodinv      VARCHAR2(50);
      v_m_modinv     tt_mov_modinv;

      FUNCTION f_mov_modinv(
         pmovimi IN NUMBER,
         pfecha IN DATE,
         pcmodinv IN NUMBER,
         ptmodinv IN VARCHAR2)
         RETURN rt_mov_modinv IS
         v_mov_modinv   rt_mov_modinv;
      BEGIN
         v_mov_modinv.vnmovimi := pmovimi;
         v_mov_modinv.vfinicio := pfecha;
         v_mov_modinv.vcmodinv := pcmodinv;
         v_mov_modinv.vtmodinv := ptmodinv;
         RETURN(v_mov_modinv);
      END;
   BEGIN
      SELECT cramo, cmodali, ctipseg, ccolect, sproduc
        INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_sproduc
        FROM estseguros
       WHERE sseguro = psseguro;

      FOR regs IN cur_modinv(v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_sproduc) LOOP
         SELECT COUNT(1)
           INTO contamatch
           FROM (SELECT ccodfon, pinvers
                   FROM modinvfondo
                  WHERE cmodinv = regs.cmodinv
                    AND cramo = v_cramo
                    AND cmodali = v_cmodali
                    AND ctipseg = v_ctipseg
                    AND ccolect = v_ccolect
                 MINUS
                 SELECT ccesta, pdistrec
                   FROM estsegdisin2
                  WHERE sseguro = psseguro
                    AND nmovimi = nmovimi
                    AND ffin IS NULL   -- < Añadido el 21/01/2008
                                    );

         IF contamatch = 0 THEN   -- (contamatch = v_contamod) --> perfil Libre
            BEGIN
               SELECT DISTINCT nmovimi, finicio, regs.cmodinv
                          INTO v_movi, v_finicio, v_cmodinv
                          FROM estsegdisin2
                         WHERE sseguro = psseguro
                           AND nmovimi = nmovimi;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF v_movi IS NOT NULL
               AND v_finicio IS NOT NULL
               AND v_cmodinv IS NOT NULL THEN
               SELECT tmodinv
                 INTO v_tmodinv
                 FROM codimodelosinversion
                WHERE cmodinv = v_cmodinv
                  AND cidioma = pcidioma;

               v_m_modinv(NVL(v_m_modinv.LAST, 0) + 1) :=
                                          f_mov_modinv(v_movi, v_finicio, v_cmodinv, v_tmodinv);
            END IF;
         END IF;
      END LOOP;

      RETURN(v_m_modinv);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.ff_get_segdisin2_nmovimi', NULL,
                     'parametros: psseguro = ' || psseguro, SQLERRM);
         RETURN v_m_modinv;   -- Error
   END ff_get_segdisin2_nmovimi;

   -- BUG - 23/02/2012 - se quita la funcion y se pasa el PAC_MD_OPERATIVA_FINV
   /*************************************************************************
      FUNCTION f_insert_reggastos
        PARAM IN ccodfon
        PARAM IN finicio
        PARAM IN ffin
        PARAM IN iimpmin
        PARAM IN iimpmax
        PARAM IN cdivisa
        PARAM IN pgastos
        PARAM IN iimpfij
        PARAM IN column9
        PARAM IN ctipcom
        PARAM IN cconcep
        PARAM IN ctipocalcul
        PARAM IN clave
        return : 0.- OK Otros.- Cod. Error
        --BUG18799 - JTS - 16/06/2011
   *************************************************************************/
   FUNCTION f_insert_reggastos(
      pccodfon IN NUMBER,
      pfinicio IN DATE,
      pffin IN DATE,
      piimpmin IN NUMBER,
      piimpmax IN NUMBER,
      pcdivisa IN NUMBER,
      ppgastos IN NUMBER,
      piimpfij IN NUMBER,
      pcolumn9 IN NUMBER,
      pctipcom IN NUMBER,
      pcconcep IN NUMBER,
      pctipocalcul IN NUMBER,
      pclave IN NUMBER)
      RETURN NUMBER IS
      vdatamax       DATE;
      vcount         NUMBER;
      vntraza        NUMBER := 0;
   BEGIN
      IF pffin IS NOT NULL THEN
         IF pffin < pfinicio THEN
            RETURN 9902126;
         END IF;
      END IF;

      vntraza := 1;

      --
      IF pctipcom = 1 THEN   --Per pólissa
         IF (ppgastos IS NULL
             AND ppgastos = 0)
            OR(piimpfij IS NOT NULL
               AND piimpfij != 0)
            OR(pclave IS NOT NULL
               AND pclave != 0) THEN
            RETURN 1000005;
         END IF;
      ELSIF pctipcom = 2 THEN   --Per tancament
         IF pctipocalcul = 1 THEN   --pct
            IF (ppgastos IS NULL
                AND ppgastos = 0)
               OR(piimpfij IS NOT NULL
                  AND piimpfij != 0)
               OR(pclave IS NOT NULL
                  AND pclave != 0) THEN
               RETURN 1000005;
            END IF;
         ELSIF pctipocalcul = 2 THEN   --import
            IF (piimpfij IS NULL
                AND piimpfij = 0)
               OR(ppgastos IS NOT NULL
                  AND ppgastos != 0)
               OR(pclave IS NOT NULL
                  AND pclave != 0) THEN
               RETURN 1000005;
            END IF;
         ELSIF pctipocalcul = 3 THEN   --formula
            IF (pclave IS NULL
                AND pclave = 0)
               OR(ppgastos IS NOT NULL
                  AND ppgastos != 0)
               OR(piimpfij IS NOT NULL
                  AND piimpfij != 0) THEN
               RETURN 1000005;
            END IF;
         END IF;
      END IF;

      vntraza := 2;

      SELECT MAX(finicio)   --Últim registre
        INTO vdatamax
        FROM fongast
       WHERE ccodfon = pccodfon;

      SELECT COUNT(1)   --Ja existeix el que estem insertant?
        INTO vcount
        FROM fongast
       WHERE ccodfon = pccodfon
         AND finicio = pfinicio;

      vntraza := 3;

      IF pfinicio < vdatamax   --Data inici mes petita
         AND vcount = 0 THEN   --que el registre anterior
         RETURN 9902127;
      ELSIF pfinicio < vdatamax   --Intento updatejar un registre
            AND vcount = 1 THEN   --que no es l'últim
         RETURN 9902125;
      ELSIF vdatamax = pfinicio   --Updatejo el registre anterior
            AND vcount = 1 THEN
         UPDATE fongast
            SET ffin = pffin,
                iimpmin = piimpmin,
                iimpmax = piimpmax,
                cdivisa = pcdivisa,
                pgastos = ppgastos,
                iimpfij = piimpfij,
                column9 = pcolumn9,
                ctipcom = pctipcom,
                cconcep = pcconcep,
                ctipocalcul = pctipocalcul,
                clave = pclave
          WHERE ccodfon = pccodfon
            AND finicio = pfinicio;
      ELSE   --Inserto un nou tram
         INSERT INTO fongast
                     (ccodfon, finicio, ffin, iimpmin, iimpmax, cdivisa, pgastos,
                      iimpfij, column9, ctipcom, cconcep, ctipocalcul, clave)
              VALUES (pccodfon, pfinicio, pffin, piimpmin, piimpmax, pcdivisa, ppgastos,
                      piimpfij, pcolumn9, pctipcom, pcconcep, pctipocalcul, pclave);

         vntraza := 4;

         UPDATE fongast
            SET ffin = pfinicio
          WHERE ccodfon = pccodfon
            AND finicio = vdatamax;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_insert_reggastos', vntraza,
                     SQLCODE, SQLERRM);
         RETURN 1000141;
   END f_insert_reggastos;

   /*************************************************************************
      FUNCTION f_get_gastos_hist
        PARAM IN pccodfon
        return : cursor
        --BUG18799 - JTS - 16/06/2011
   *************************************************************************/
   FUNCTION f_get_gastos_hist(pccodfon IN NUMBER, pcidioma IN NUMBER)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vsquery        VARCHAR2(1000)
         := 'SELECT fg.ccodfon, f.tfoncmp, fg.finicio, fg.ffin, fg.iimpmin, fg.iimpmax, fg.cdivisa,
       fg.pgastos, fg.iimpfij, fg.column9, fg.ctipcom,
       ff_desvalorfijo(1027, '
            || pcidioma || ', fg.ctipcom) ttipcom, fg.cconcep,
       ff_desvalorfijo(1028, ' || pcidioma
            || ', fg.cconcep) tconcep, fg.ctipocalcul,
       ff_desvalorfijo(1029, ' || pcidioma
            || ', fg.ctipocalcul) ttipocalcul, fg.clave, f.cempres
  FROM fongast fg, fondos f
 WHERE fg.ccodfon = f.ccodfon
   AND fg.ccodfon = '
            || pccodfon || ' order by finicio desc';
   BEGIN
      OPEN cur FOR vsquery;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_get_gastos_hist', 1, SQLCODE,
                     SQLERRM);
         RETURN NULL;
   END f_get_gastos_hist;

   /*************************************************************************
      FUNCTION f_get_gastos
        PARAM IN pccodfon
        return : cursor
        --BUG18799 - JTS - 16/06/2011
   *************************************************************************/
   FUNCTION f_get_gastos(pcempres IN NUMBER, pccodfon IN NUMBER, pcidioma IN NUMBER)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vsquery        VARCHAR2(1000)
         := 'SELECT fg.ccodfon, f.tfoncmp, fg.finicio, fg.ffin, fg.iimpmin, fg.iimpmax, fg.cdivisa,
       fg.pgastos, fg.iimpfij, fg.column9, fg.ctipcom,
       ff_desvalorfijo(1027, '
            || pcidioma || ', fg.ctipcom) ttipcom, fg.cconcep,
       ff_desvalorfijo(1028, ' || pcidioma
            || ', fg.cconcep) tconcep, fg.ctipocalcul,
       ff_desvalorfijo(1029, ' || pcidioma
            || ', fg.ctipocalcul) ttipocalcul, fg.clave, f.cempres
  FROM fongast fg, fondos f
 WHERE fg.ccodfon = f.ccodfon
   AND fg.finicio = (SELECT MAX(finicio)
                       FROM fongast
                      WHERE ccodfon = fg.ccodfon)';
   BEGIN
      IF pcempres IS NOT NULL THEN
         vsquery := vsquery || ' and f.cempres = ' || pcempres;
      END IF;

      IF pccodfon IS NOT NULL THEN
         vsquery := vsquery || ' and fg.ccodfon = ' || pccodfon;
      END IF;

      OPEN cur FOR vsquery;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_get_gastos', 1, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_gastos;

   /*************************************************************************
      FUNCTION f_op_pdtes_valorar
        PARAM IN psseguro
        return : NUMBER
        BUG0019852: CRE998 - Impressió de compte assegurança - JGR - 21/10/2011
        Retorna si ha de mostrar o no la icone de impresora.
        També retorna el literal que es comenta en el bug "Pòlissa amb operacions pedents de valorar"
   *************************************************************************/
   FUNCTION f_op_pdtes_valorar(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pcidioma IN NUMBER,
      pliteral IN OUT VARCHAR2)
      RETURN NUMBER IS
      vicono         NUMBER := 0;
      -- Mostrar l'icona de l'impressora: 0 - NO, 1 -SÍ.
      vreteni        seguros.creteni%TYPE;
   BEGIN
      -- pac_md_common.f_get_cxtempresa
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'OP_PDTE_VALORAR'), 0) = 0 THEN
         vicono := 1;
      ELSE
         SELECT creteni
           INTO vreteni
           FROM seguros
          WHERE sseguro = psseguro;

         IF vreteni = 1 THEN
            -- 9902532 Pòlissa amb operacions pedents de valorar
            pliteral := f_axis_literales(9902532, pcidioma);
         ELSE
            BEGIN
               SELECT DISTINCT 0
                          INTO vicono
                          FROM ctaseguro
                         WHERE sseguro = psseguro
                           AND cesta IS NOT NULL
                           AND nunidad IS NULL;

               -- 9902532 Pòlissa amb operacions pedents de valorar
               pliteral := f_axis_literales(9902532, pcidioma);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vicono := 1;
               WHEN OTHERS THEN
                  vicono := 0;
                  p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_op_pdtes_valorar', 1,
                              'SSEGURO:' || psseguro, SQLERRM);
            END;
         END IF;
      END IF;

      RETURN vicono;
   END f_op_pdtes_valorar;

   FUNCTION ff_rendimiento(psseguro IN NUMBER, pnnumlin IN NUMBER)
      RETURN NUMBER IS
      v_saldo        NUMBER;
      v_movimientos  NUMBER;
      v_mov_negativo NUMBER;
      v_mov_positivo NUMBER;
   BEGIN
      v_saldo := pac_operativa_finv.ff_provmat(NULL, psseguro, NULL, pnnumlin);

      SELECT SUM(imovimi) * -1
        INTO v_mov_negativo
        FROM ctaseguro
       WHERE sseguro = psseguro
         AND nnumlin <= NVL(pnnumlin, nnumlin)
         AND cesta IS NOT NULL
         AND cmovimi IN(5, 6, 7, 21, 22, 23, 24, 26, 27, 28, 29, 39, 58, 83, 84, 91, 93, 94,
                        97, 87, 88, 99);

      SELECT SUM(imovimi)
        INTO v_mov_positivo
        FROM ctaseguro
       WHERE sseguro = psseguro
         AND nnumlin <= NVL(pnnumlin, nnumlin)
         AND cesta IS NOT NULL
         AND cmovimi NOT IN(5, 6, 7, 21, 22, 23, 24, 26, 27, 28, 29, 39, 58, 83, 84, 91, 93,
                            94, 97, 87, 88, 99);

      v_movimientos := NVL(v_mov_positivo, 0) + NVL(v_mov_negativo, 0);
      RETURN(v_saldo - NVL(v_movimientos, 0));   -- Rendimiento
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.ff_rendimiento', NULL,
                     'parametros: psseguro = ' || psseguro || ', nnumlin = ' || pnnumlin,
                     NULL);
         RETURN NULL;
   END ff_rendimiento;

   FUNCTION ff_rendimiento_shw(psseguro IN NUMBER, pnnumlin IN NUMBER)
      RETURN NUMBER IS
      v_saldo        NUMBER;
      v_movimientos  NUMBER;
      v_mov_negativo NUMBER;
      v_mov_positivo NUMBER;
   BEGIN
      v_saldo := pac_operativa_finv.ff_provshw(NULL, psseguro, NULL, pnnumlin);

      SELECT SUM(imovimi) * -1
        INTO v_mov_negativo
        FROM ctaseguro_shadow
       WHERE sseguro = psseguro
         AND nnumlin <= NVL(pnnumlin, nnumlin)
         AND cesta IS NOT NULL
         AND cmovimi IN(5, 6, 7, 21, 22, 23, 24, 26, 27, 28, 29, 39, 58, 83, 84, 91, 93, 94,
                        97, 87, 88, 99);

      SELECT SUM(imovimi)
        INTO v_mov_positivo
        FROM ctaseguro_shadow
       WHERE sseguro = psseguro
         AND nnumlin <= NVL(pnnumlin, nnumlin)
         AND cesta IS NOT NULL
         AND cmovimi NOT IN(5, 6, 7, 21, 22, 23, 24, 26, 27, 28, 29, 39, 58, 83, 84, 91, 93,
                            94, 97, 87, 88, 99);

      v_movimientos := NVL(v_mov_positivo, 0) + NVL(v_mov_negativo, 0);
      RETURN(v_saldo - NVL(v_movimientos, 0));   -- Rendimiento
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.ff_rendimiento_shw', NULL,
                     'parametros: psseguro = ' || psseguro || ', nnumlin = ' || pnnumlin,
                     NULL);
         RETURN NULL;
   END ff_rendimiento_shw;

   FUNCTION ffrendiment(psesion IN NUMBER, psseguro IN NUMBER, pfecha IN NUMBER)
      RETURN NUMBER IS
      v_saldo        NUMBER;
      v_movimientos  NUMBER;
      v_mov_negativo NUMBER;
      v_mov_positivo NUMBER;
      v_pfecha       DATE;
   BEGIN
      v_pfecha := TO_DATE(pfecha, 'YYYYMMDD');
      v_saldo := pac_operativa_finv.ff_provmat(psesion, psseguro, pfecha);

      SELECT SUM(imovimi) * -1
        INTO v_mov_negativo
        FROM ctaseguro
       WHERE sseguro = psseguro
         AND fvalmov <= TRUNC(v_pfecha)
         AND cesta IS NOT NULL
         AND cmovimi IN(5, 6, 7, 21, 22, 23, 24, 26, 27, 28, 29, 39, 58, 83, 84, 91, 93, 94,
                        97, 87, 88, 99);

      SELECT SUM(imovimi)
        INTO v_mov_positivo
        FROM ctaseguro
       WHERE sseguro = psseguro
         AND fvalmov <= TRUNC(v_pfecha)
         AND cesta IS NOT NULL
         AND cmovimi NOT IN(5, 6, 7, 21, 22, 23, 24, 26, 27, 28, 29, 39, 58, 83, 84, 91, 93,
                            94, 97, 87, 88, 99);

      v_movimientos := NVL(v_mov_positivo, 0) + NVL(v_mov_negativo, 0);
      RETURN(v_saldo - NVL(v_movimientos, 0));   -- Rendimiento
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.ffrendiment', NULL,
                     'parametros: psseguro = ' || psseguro || ', pfecha = ' || pfecha, NULL);
         RETURN NULL;
   END ffrendiment;

   FUNCTION ffrendiment_shw(psesion IN NUMBER, psseguro IN NUMBER, pfecha IN NUMBER)
      RETURN NUMBER IS
      v_saldo        NUMBER;
      v_movimientos  NUMBER;
      v_mov_negativo NUMBER;
      v_mov_positivo NUMBER;
      v_pfecha       DATE;
   BEGIN
      v_pfecha := TO_DATE(pfecha, 'YYYYMMDD');
      v_saldo := pac_operativa_finv.ff_provshw(psesion, psseguro, pfecha);

      SELECT SUM(imovimi) * -1
        INTO v_mov_negativo
        FROM ctaseguro_shadow
       WHERE sseguro = psseguro
         AND fvalmov <= TRUNC(v_pfecha)
         AND cesta IS NOT NULL
         AND cmovimi IN(5, 6, 7, 21, 22, 23, 24, 26, 27, 28, 29, 39, 58, 83, 84, 91, 93, 94,
                        97, 87, 88, 99);

      SELECT SUM(imovimi)
        INTO v_mov_positivo
        FROM ctaseguro_shadow
       WHERE sseguro = psseguro
         AND fvalmov <= TRUNC(v_pfecha)
         AND cesta IS NOT NULL
         AND cmovimi NOT IN(5, 6, 7, 21, 22, 23, 24, 26, 27, 28, 29, 39, 58, 83, 84, 91, 93,
                            94, 97, 87, 88, 99);

      v_movimientos := NVL(v_mov_positivo, 0) + NVL(v_mov_negativo, 0);
      RETURN(v_saldo - NVL(v_movimientos, 0));   -- Rendimiento
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.ffrendiment_shw', NULL,
                     'parametros: psseguro = ' || psseguro || ', pfecha = ' || pfecha, NULL);
         RETURN NULL;
   END ffrendiment_shw;

   FUNCTION ffrend_trim(psesion IN NUMBER, psseguro IN NUMBER, pfecha IN NUMBER)
      RETURN NUMBER IS
      v_movimientos  NUMBER;
      v_mov_negativo NUMBER;
      v_mov_positivo NUMBER;
      v_pfecha       DATE;
      v_pfecha_inicio DATE;
      v_saldo        NUMBER;
      v_saldo_inicio NUMBER;
      -- Bug 23018 - RSC - 19/07/2012 - LCOL - Adaptación para el cálculo del rendimiento
      v_sproduc      seguros.sproduc%TYPE;
      -- Fin bug 23018
      -- Bug 22815 - AEG - 04/12/2012 - 0022815: LCOL_T004- Qtracker 4665 - Periodictat comissions estalvi
      v_num_err      NUMBER;
      v_salida       NUMBER;

      -- Fin bug 22815

      -- Bug 22815 - RSC - 10/09/2012 - LCOL_T004- Qtracker 4665 - Periodictat comissions estalvi
      FUNCTION f_fecha_ult_cierre(psseguro IN NUMBER, pfecha IN DATE)
         RETURN DATE IS
         valor          DATE;
      BEGIN
         valor := NULL;

         BEGIN
            FOR regs IN (SELECT   c.fvalmov
                             FROM ctaseguro c, ctaseguro_libreta cl
                            WHERE c.sseguro = psseguro
                              AND c.sseguro = cl.sseguro
                              AND c.nnumlin = cl.nnumlin
                              AND c.cmovimi = 0
                              AND c.cmovanu <> 1   -- 1 = Anulado
                              AND c.fvalmov < pfecha
                         ORDER BY c.fvalmov DESC, c.nnumlin DESC) LOOP
               valor := regs.fvalmov;
               EXIT;
            END LOOP;

            RETURN valor;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN NULL;
         END;
      END;

      -- Fin Bug 22815

      -- Ini Bug 26902_0145456 - JLTS - 12/06/2013
      FUNCTION f_imovimi_ult_act(psseguro IN NUMBER, pfecha IN DATE)
         RETURN NUMBER IS
         valor          NUMBER;
      BEGIN
         valor := NULL;

         BEGIN
            FOR regs IN (SELECT   c.imovimi
                             FROM ctaseguro c, ctaseguro_libreta cl
                            WHERE c.sseguro = psseguro
                              AND c.sseguro = cl.sseguro
                              AND c.nnumlin = cl.nnumlin
                              AND c.cmovimi = 0
                              AND c.cmovanu <> 1   -- 1 = Anulado
                              AND c.fvalmov <= pfecha
                         ORDER BY c.fvalmov DESC, c.nnumlin DESC) LOOP
               valor := regs.imovimi;
               EXIT;
            END LOOP;

            RETURN valor;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN NULL;
         END;
      END f_imovimi_ult_act;
-- Fin Bug 26902_0145456 - JLTS - 2013-06-12
   BEGIN
      -- Bug 23018 - RSC - 19/07/2012 - LCOL - Adaptación para el cálculo del rendimiento
      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

      -- Fin Bug 23018
      v_pfecha := LAST_DAY(TO_DATE(pfecha, 'YYYYMMDD'));
      -- Bug 23018 - RSC - 19/07/2012 - LCOL - Adaptación para el cálculo del rendimiento

      -- Bug 22815 - RSC - 10/09/2012 - LCOL_T004- Qtracker 4665 - Periodictat comissions estalvi
      /*v_pfecha_inicio := ADD_MONTHS(LAST_DAY(TO_DATE(pfecha, 'YYYYMMDD')),
                                    -1
                                    * vtramo(NULL, 291,
                                             NVL(f_parproductos_v(v_sproduc,
                                                                  'PERIODICI_COMISION'),
                                                 12)));*/
      -- Fin Bug 23018
      -- FinBug 22815

      -- 2012-12-04 aeg BUG: 0022815  ini
      -- se rescribe el siguiente bloque comentariado hasta la marca de final de bug.
      /*
      -- Bug 22815 - RSC - 10/09/2012 - LCOL_T004- Qtracker 4665 - Periodictat comissions estalvi
      v_pfecha_inicio := f_fecha_ult_cierre(psseguro, TO_DATE(pfecha, 'YYYYMMDD'));
      -- FinBug 22815
      v_saldo := pac_operativa_finv.ff_provmat(psesion, psseguro,
                                               TO_NUMBER(TO_CHAR(v_pfecha, 'YYYYMMDD')));
      v_saldo_inicio := pac_operativa_finv.ff_provmat(psesion, psseguro,
                                                      TO_NUMBER(TO_CHAR(v_pfecha_inicio,
                                                                        'YYYYMMDD')));
      */
      v_saldo := pac_operativa_finv.ff_provmat(psesion, psseguro,
                                               TO_NUMBER(TO_CHAR(v_pfecha, 'YYYYMMDD')));
      v_pfecha_inicio := f_fecha_ult_cierre(psseguro, TO_DATE(pfecha, 'YYYYMMDD'));

      IF v_pfecha_inicio IS NULL THEN
         SELECT MAX(fcierre)
           INTO v_pfecha_inicio
           FROM cierres
          WHERE ctipo = 11
            AND cestado = 1
            AND fcierre < TO_DATE(pfecha, 'YYYYMMDD');

         IF v_pfecha_inicio IS NULL THEN
            v_pfecha_inicio := ADD_MONTHS(v_pfecha, -1);
         END IF;

         v_num_err := pac_seguros.f_es_migracion(psseguro, 'SEG', v_salida);

         IF v_salida = 0 THEN
            v_saldo_inicio := 0;
         ELSE
            v_saldo_inicio :=
               pac_operativa_finv.ff_provmat(psesion, psseguro,
                                             TO_NUMBER(TO_CHAR(v_pfecha_inicio, 'YYYYMMDD')));
         END IF;
      ELSE
         -- BUG 26902_0145456 - JLTS - 2013-06-12 - Se adicionan las siguientes 2 lineas
         v_saldo_inicio := f_imovimi_ult_act(psseguro, v_pfecha_inicio);

         IF v_saldo_inicio IS NULL
            OR v_saldo_inicio = 0 THEN
            v_saldo_inicio :=
               pac_operativa_finv.ff_provmat(psesion, psseguro,
                                             TO_NUMBER(TO_CHAR(v_pfecha_inicio, 'YYYYMMDD')));
         END IF;
      END IF;

      -- 2012-12-04 aeg BUG: 0022815  fin
      SELECT SUM(imovimi) * -1
        INTO v_mov_negativo
        FROM ctaseguro
       WHERE sseguro = psseguro
         AND fvalmov <= TRUNC(v_pfecha)
         AND fvalmov > TRUNC(v_pfecha_inicio)
         AND cesta IS NOT NULL
         AND cmovimi IN(5, 6, 7, 21, 22, 23, 24, 26, 27, 28, 29, 39, 58, 83, 84, 91, 93, 94,
                        97, 87, 88, 99);

      SELECT SUM(imovimi)
        INTO v_mov_positivo
        FROM ctaseguro
       WHERE sseguro = psseguro
         AND fvalmov <= TRUNC(v_pfecha)
         AND fvalmov > TRUNC(v_pfecha_inicio)
         AND cesta IS NOT NULL
         AND cmovimi NOT IN(5, 6, 7, 21, 22, 23, 24, 26, 27, 28, 29, 39, 58, 83, 84, 91, 93,
                            94, 97, 87, 88, 99);

      v_movimientos := NVL(v_mov_positivo, 0) + NVL(v_mov_negativo, 0) + v_saldo_inicio;
      RETURN(v_saldo - ABS(NVL(v_movimientos, 0)));   -- Rendimiento
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.ffrend_trim', NULL,
                     'parametros: psseguro = ' || psseguro || ', pfecha = ' || pfecha, NULL);
         RETURN NULL;
   END ffrend_trim;

   FUNCTION ffrend_trim_shw(psesion IN NUMBER, psseguro IN NUMBER, pfecha IN NUMBER)
      RETURN NUMBER IS
      v_movimientos  NUMBER;
      v_mov_negativo NUMBER;
      v_mov_positivo NUMBER;
      v_pfecha       DATE;
      v_pfecha_inicio DATE;
      v_saldo        NUMBER;
      v_saldo_inicio NUMBER;
      -- Bug 23018 - RSC - 19/07/2012 - LCOL - Adaptación para el cálculo del rendimiento
      v_sproduc      seguros.sproduc%TYPE;
      -- Fin bug 23018
      -- Bug 22815 - AEG - 04/12/2012 - 0022815: LCOL_T004- Qtracker 4665 - Periodictat comissions estalvi
      v_num_err      NUMBER;
      v_salida       NUMBER;

      -- Fin bug 22815

      -- Bug 22815 - RSC - 10/09/2012 - LCOL_T004- Qtracker 4665 - Periodictat comissions estalvi
      FUNCTION f_fecha_ult_cierre(psseguro IN NUMBER, pfecha IN DATE)
         RETURN DATE IS
         valor          DATE;
      BEGIN
         valor := NULL;

         BEGIN
            FOR regs IN (SELECT   c.fvalmov
                             FROM ctaseguro_shadow c, ctaseguro_libreta_shw cl
                            WHERE c.sseguro = psseguro
                              AND c.sseguro = cl.sseguro
                              AND c.nnumlin = cl.nnumlin
                              AND c.cmovimi = 0
                              AND c.cmovanu <> 1   -- 1 = Anulado
                              AND c.fvalmov < pfecha
                         ORDER BY c.fvalmov DESC, c.nnumlin DESC) LOOP
               valor := regs.fvalmov;
               EXIT;
            END LOOP;

            RETURN valor;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN NULL;
         END;
      END;

      -- Fin Bug 22815

      -- Ini Bug 26902_0145456 - JLTS - 12/06/2013
      FUNCTION f_imovimi_ult_act(psseguro IN NUMBER, pfecha IN DATE)
         RETURN NUMBER IS
         valor          NUMBER;
      BEGIN
         valor := NULL;

         BEGIN
            FOR regs IN (SELECT   c.imovimi
                             FROM ctaseguro_shadow c, ctaseguro_libreta_shw cl
                            WHERE c.sseguro = psseguro
                              AND c.sseguro = cl.sseguro
                              AND c.nnumlin = cl.nnumlin
                              AND c.cmovimi = 0
                              AND c.cmovanu <> 1   -- 1 = Anulado
                              AND c.fvalmov <= pfecha
                         ORDER BY c.fvalmov DESC, c.nnumlin DESC) LOOP
               valor := regs.imovimi;
               EXIT;
            END LOOP;

            RETURN valor;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN NULL;
         END;
      END f_imovimi_ult_act;
-- Fin Bug 26902_0145456 - JLTS - 2013-06-12
   BEGIN
      -- Bug 23018 - RSC - 19/07/2012 - LCOL - Adaptación para el cálculo del rendimiento
      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

      -- Fin Bug 23018
      v_pfecha := LAST_DAY(TO_DATE(pfecha, 'YYYYMMDD'));
      v_saldo := pac_operativa_finv.ff_provshw(psesion, psseguro,
                                               TO_NUMBER(TO_CHAR(v_pfecha, 'YYYYMMDD')));
      v_pfecha_inicio := f_fecha_ult_cierre(psseguro, TO_DATE(pfecha, 'YYYYMMDD'));

      IF v_pfecha_inicio IS NULL THEN
         SELECT MAX(fcierre)
           INTO v_pfecha_inicio
           FROM cierres
          WHERE ctipo = 11
            AND cestado = 1
            AND fcierre < TO_DATE(pfecha, 'YYYYMMDD');

         IF v_pfecha_inicio IS NULL THEN
            v_pfecha_inicio := ADD_MONTHS(v_pfecha, -1);
         END IF;

         v_num_err := pac_seguros.f_es_migracion(psseguro, 'SEG', v_salida);

         IF v_salida = 0 THEN
            v_saldo_inicio := 0;
         ELSE
            v_saldo_inicio :=
               pac_operativa_finv.ff_provshw(psesion, psseguro,
                                             TO_NUMBER(TO_CHAR(v_pfecha_inicio, 'YYYYMMDD')));
         END IF;
      ELSE
         -- BUG 26902_0145456 - JLTS - 2013-06-12 - Se adicionan las siguientes 2 lineas
         v_saldo_inicio := f_imovimi_ult_act(psseguro, v_pfecha_inicio);

         IF v_saldo_inicio IS NULL
            OR v_saldo_inicio = 0 THEN
            v_saldo_inicio :=
               pac_operativa_finv.ff_provshw(psesion, psseguro,
                                             TO_NUMBER(TO_CHAR(v_pfecha_inicio, 'YYYYMMDD')));
         END IF;
      END IF;

      -- 2012-12-04 aeg BUG: 0022815  fin
      SELECT SUM(imovimi) * -1
        INTO v_mov_negativo
        FROM ctaseguro_shadow
       WHERE sseguro = psseguro
         AND fvalmov <= TRUNC(v_pfecha)
         AND fvalmov > TRUNC(v_pfecha_inicio)
         AND cesta IS NOT NULL
         AND cmovimi IN(5, 6, 7, 21, 22, 23, 24, 26, 27, 28, 29, 39, 58, 83, 84, 91, 93, 94,
                        97, 87, 88, 99);

      SELECT SUM(imovimi)
        INTO v_mov_positivo
        FROM ctaseguro_shadow
       WHERE sseguro = psseguro
         AND fvalmov <= TRUNC(v_pfecha)
         AND fvalmov > TRUNC(v_pfecha_inicio)
         AND cesta IS NOT NULL
         AND cmovimi NOT IN(5, 6, 7, 21, 22, 23, 24, 26, 27, 28, 29, 39, 58, 83, 84, 91, 93,
                            94, 97, 87, 88, 99);

      v_movimientos := NVL(v_mov_positivo, 0) + NVL(v_mov_negativo, 0) + v_saldo_inicio;
      RETURN(v_saldo - ABS(NVL(v_movimientos, 0)));   -- Rendimiento
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.ffrend_trim_shw', NULL,
                     'parametros: psseguro = ' || psseguro || ', pfecha = ' || pfecha, NULL);
         RETURN NULL;
   END ffrend_trim_shw;

   /**************************************************************************************
Nueva funcion f_ins_detalle_gasto  ACL
***************************************************************************************/
   FUNCTION f_ins_detalle_gasto(
      psseguro IN NUMBER,
      ppfefecto IN DATE,
      pfcontab IN DATE,
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
      pcestado IN VARCHAR2,
      pmodo IN VARCHAR2 DEFAULT 'R',
      psproces IN NUMBER DEFAULT NULL,
      pnmovimi IN NUMBER DEFAULT NULL,
      pccapgar IN NUMBER DEFAULT NULL,
      pccapfal IN NUMBER DEFAULT NULL,
      psrecren IN NUMBER DEFAULT NULL,
      pigasext IN NUMBER DEFAULT NULL,
      pigasint IN NUMBER DEFAULT NULL,
      pipririe IN NUMBER DEFAULT NULL,
      pcesta IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      CURSOR cur_cesta IS
         SELECT ccesta, pdistrec
           FROM segdisin2
          WHERE sseguro = psseguro
            AND ffin IS NULL
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM segdisin2
                            WHERE sseguro = psseguro
                              AND ffin IS NULL);

      ggesmensual    NUMBER := 0;
      nnumlin        NUMBER;
      iuniacts       NUMBER;
      xnnumlin       NUMBER;
      imovimo        NUMBER;
      v_provision    NUMBER;
      ggesanual      NUMBER;
      num_err        NUMBER;
      pfefecto       DATE;
      ntraza         NUMBER := 0;
      --09/01/2008 RSC
      v_sproduc      NUMBER;
      -- RSC 28/01/2008
      vacumpercent   NUMBER := 0;
      vacumrounded   NUMBER := 0;
      -- RSC 06/11/2008
      vpgastoges     NUMBER;
      -- RSC 09/12/2008 Tarea 8407
      vfsysdate      DATE;
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      --
      v_gastosext    ctaseguro.imovimi%TYPE;
      v_gastosint    ctaseguro.imovimi%TYPE;
      v_fecha        DATE;
      v_ahorro_prepagable NUMBER;
      v_seqgrupo     NUMBER;
   --
   BEGIN
      -- RSC 09/12/2008 Tarea 8407
      vfsysdate := f_sysdate;

      -- Obtebemos la sequence para la agrupación (82-83)
      SELECT scagrcta.NEXTVAL
        INTO v_seqgrupo
        FROM DUAL;

      -- Buscamos en la tabla SEGUROS la empresa y el producto
      SELECT sproduc, cempres
        INTO v_sproduc, v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);
      v_ahorro_prepagable := NVL(f_parproductos_v(v_sproduc, 'AHORRO_PREPAGABLE'), 0);

      IF v_ahorro_prepagable = 1
         AND pcmovimi = 0 THEN
         v_fecha := ppfefecto + 1;
      ELSE
         -- Si NO es prepagable y no es el cierre se graba la fecha de entrada.
         v_fecha := ppfefecto;
      END IF;

      v_gastosext := pigasext;

      --
      IF v_gastosext IS NULL THEN
         v_gastosext := 0;
      END IF;

      --
      v_gastosint := pigasint;

      --
      IF v_gastosint IS NULL THEN
         v_gastosint := 0;
      END IF;

      --
      ggesmensual := v_gastosext + v_gastosint;   -- ACL

      --
      -- Si no hay gastos salimos
      --
      IF NVL(ggesmensual, 0) = 0 THEN
         RETURN 0;
      END IF;

      -- Insertamos el movimiento general gastos y se desglosa la parte interna y externa(comision)
      num_err := pac_ctaseguro.f_insctaseguro(psseguro, vfsysdate, NULL, v_fecha, v_fecha, 82,
                                              ggesmensual, NULL, NULL, v_seqgrupo, 0, NULL,
                                              NULL, NULL, pmodo, NULL, NULL, NULL, NULL, NULL,
                                              v_gastosext, v_gastosint, NULL);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      --

      --
      FOR regs IN cur_cesta LOOP
         ntraza := 5;

         -- obtenemos el numero de linia siguiente
         BEGIN
            IF pmodo = 'R' THEN
               ntraza := 3;

               SELECT NVL(MAX(nnumlin) + 1, 1)
                 INTO xnnumlin
                 FROM ctaseguro
                WHERE sseguro = psseguro;
            ELSIF pmodo = 'P' THEN
               ntraza := 4;

               SELECT NVL(MAX(nnumlin) + 1, 1)
                 INTO xnnumlin
                 FROM ctaseguro_previo
                WHERE sseguro = psseguro;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 104882;   -- Error al llegir de CTASEGURO
         END;

         BEGIN
            -- RSC 18/03/2008 (ultimo valor lo cogemos de tabvalces)
            -- Tarea 31548/206135 Management expenses
            SELECT NVL(iuniact, 0)
              INTO iuniacts
              FROM tabvalces
             WHERE ccesta = regs.ccesta
               AND TRUNC(fvalor) = v_fecha + pac_md_fondos.f_get_diasdep(regs.ccesta);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               p_tab_error
                        (f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_ins_detalle_gasto', ntraza,
                         'No hay valor liquidativo para la fecha. parametros: psseguro = '
                         || psseguro || ' ppfefecto=' || ppfefecto || ' v_sproduc='
                         || v_sproduc || ' pmodo=' || pmodo || ' pcmovimi=' || pcmovimi
                         || ' v_fecha=' || v_fecha,
                         SQLERRM, 50);
               iuniacts := 0;
         END;

         --
         --Calcula les distribucions
         vacumpercent := vacumpercent + (ggesmensual * regs.pdistrec) / 100;
         imovimo := ROUND(vacumpercent - vacumrounded, 2);
         vacumrounded := vacumrounded + ROUND(vacumpercent - vacumrounded, 2);

         --
         IF NVL(iuniacts, 0) = 0 THEN
            num_err := pac_ctaseguro.f_insctaseguro(psseguro, vfsysdate, NULL, v_fecha,
                                                    v_fecha, 83, imovimo, NULL, NULL,
                                                    v_seqgrupo, 0, NULL, NULL, '1', pmodo,
                                                    NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                    NULL, regs.ccesta);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         ELSE
            BEGIN
               IF pmodo = 'R' THEN
                  ntraza := 6;

                  INSERT INTO ctaseguro
                              (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                               imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec, cesta,
                               nunidad, cestado, fasign)
                       VALUES (psseguro, vfsysdate, xnnumlin, v_fecha, v_fecha, 83, imovimo,
                               NULL, NULL, v_seqgrupo, 0, NULL, NULL, regs.ccesta,
                               -1 *(imovimo / iuniacts), '2', vfsysdate);

                  -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  IF v_cmultimon = 1 THEN
                     num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro,
                                                                           vfsysdate,
                                                                           xnnumlin, v_fecha);

                     IF num_err <> 0 THEN
                        p_tab_error(f_sysdate, f_user,
                                    'PAC_OPERATIVA_FINV.f_ins_detalle_gasto', ntraza,
                                    'parametros: psseguro = ' || psseguro || ' ppfefecto='
                                    || ppfefecto || ' v_sproduc=' || v_sproduc || ' pmodo='
                                    || pmodo || ' pcmovimi=' || pcmovimi || ' v_fecha='
                                    || v_fecha,
                                    SQLERRM);
                        RETURN num_err;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  xnnumlin := xnnumlin + 1;
               ELSIF pmodo = 'P' THEN
                  ntraza := 7;

                  INSERT INTO ctaseguro_previo
                              (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                               imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec, cesta,
                               nunidad, cestado, fasign)
                       VALUES (psseguro, vfsysdate, xnnumlin, v_fecha, v_fecha, 83, imovimo,
                               NULL, NULL, v_seqgrupo, 0, NULL, NULL, regs.ccesta,
                               -1 *(imovimo / iuniacts), '2', vfsysdate);

                  xnnumlin := xnnumlin + 1;
               END IF;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_ins_detalle_gasto',
                              ntraza,
                              'parametros: psseguro = ' || psseguro || ' ppfefecto='
                              || ppfefecto || ' v_sproduc=' || v_sproduc || ' pmodo=' || pmodo
                              || ' pcmovimi=' || pcmovimi || ' v_fecha=' || v_fecha,
                              SQLERRM);
                  RETURN 104879;   -- Registre duplicat a CTASEGURO
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_ins_detalle_gasto',
                              ntraza,
                              'parametros: psseguro = ' || psseguro || ' ppfefecto='
                              || ppfefecto || ' v_sproduc=' || v_sproduc || ' pmodo=' || pmodo
                              || ' pcmovimi=' || pcmovimi || ' v_fecha=' || v_fecha,
                              SQLERRM);
                  RETURN 102555;   -- Error al insertar a la taula CTASEGURO
            END;
         --
         END IF;
      --
      END LOOP;

      COMMIT;
      --
      RETURN(0);
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_ins_detalle_gasto', ntraza,
                     'parametros: psseguro = ' || psseguro || ' ppfefecto=' || ppfefecto
                     || ' v_sproduc=' || v_sproduc || ' pmodo=' || pmodo || ' pcmovimi='
                     || pcmovimi || ' v_fecha=' || v_fecha,
                     SQLERRM);
         RETURN 102555;   -- Error al insertar a la taula CTASEGURO
   END f_ins_detalle_gasto;

   /**************************************************************************************
Nueva funcion f_ins_detalle_gasto_shw  ACL
***************************************************************************************/
   FUNCTION f_ins_detalle_gasto_shw(
      psseguro IN NUMBER,
      ppfefecto IN DATE,
      pfcontab IN DATE,
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
      pcestado IN VARCHAR2,
      pmodo IN VARCHAR2 DEFAULT 'R',
      psproces IN NUMBER DEFAULT NULL,
      pnmovimi IN NUMBER DEFAULT NULL,
      pccapgar IN NUMBER DEFAULT NULL,
      pccapfal IN NUMBER DEFAULT NULL,
      psrecren IN NUMBER DEFAULT NULL,
      pigasext IN NUMBER DEFAULT NULL,
      pigasint IN NUMBER DEFAULT NULL,
      pipririe IN NUMBER DEFAULT NULL,
      pcesta IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      CURSOR cur_cesta IS
         SELECT ccesta, pdistrec
           FROM segdisin2
          WHERE sseguro = psseguro
            AND ffin IS NULL
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM segdisin2
                            WHERE sseguro = psseguro
                              AND ffin IS NULL);

      ggesmensual    NUMBER := 0;
      nnumlin        NUMBER;
      iuniacts       NUMBER;
      xnnumlin       NUMBER;
      imovimo        NUMBER;
      v_provision    NUMBER;
      ggesanual      NUMBER;
      num_err        NUMBER;
      pfefecto       DATE;
      ntraza         NUMBER := 0;
      --09/01/2008 RSC
      v_sproduc      NUMBER;
      -- RSC 28/01/2008
      vacumpercent   NUMBER := 0;
      vacumrounded   NUMBER := 0;
      -- RSC 06/11/2008
      vpgastoges     NUMBER;
      -- RSC 09/12/2008 Tarea 8407
      vfsysdate      DATE;
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      --
      v_gastosext    ctaseguro.imovimi%TYPE;
      v_gastosint    ctaseguro.imovimi%TYPE;
      v_fecha        DATE;
      v_ahorro_prepagable NUMBER;
      v_seqgrupo     NUMBER;
   --
   BEGIN
      -- RSC 09/12/2008 Tarea 8407
      vfsysdate := f_sysdate;

      -- Obtebemos la sequence para la agrupación (82-83)
      SELECT scagrcta.NEXTVAL
        INTO v_seqgrupo
        FROM DUAL;

      -- Buscamos en la tabla SEGUROS la empresa y el producto
      SELECT sproduc, cempres
        INTO v_sproduc, v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);
      v_ahorro_prepagable := NVL(f_parproductos_v(v_sproduc, 'AHORRO_PREPAGABLE'), 0);

      IF v_ahorro_prepagable = 1
         AND pcmovimi = 0 THEN
         v_fecha := ppfefecto + 1;
      ELSE
         -- Si NO es prepagable y no es el cierre se graba la fecha de entrada.
         v_fecha := ppfefecto;
      END IF;

      --
      -- DETGASTOS_ULK (gastos de gestión) ahora se formula, si se desea utilizar el % definido
      -- tendrá que ser en la formula.
      --
      v_gastosext := pigasext;

      --
      IF v_gastosext IS NULL THEN
         v_gastosext := 0;
      END IF;

      --
      v_gastosint := pigasint;

      --
      IF v_gastosint IS NULL THEN
         v_gastosint := 0;
      END IF;

      --
      ggesmensual := v_gastosext + v_gastosint;

      --
      -- Si no hay gastos salimos
      --
      IF NVL(ggesmensual, 0) = 0 THEN
         RETURN 0;
      END IF;

      -- Insertamos el movimiento general gastos y se desglosa la parte interna y externa(comision)
      num_err := pac_ctaseguro.f_insctaseguro_shw(psseguro, vfsysdate, NULL, v_fecha, v_fecha,
                                                  82, ggesmensual, NULL, NULL, v_seqgrupo, 0,
                                                  NULL, NULL, NULL, pmodo, NULL, NULL, NULL,
                                                  NULL, NULL, v_gastosext, v_gastosint, NULL);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      --
      FOR regs IN cur_cesta LOOP
         ntraza := 5;

         --
             -- obtenemos el numero de linia siguiente
         BEGIN
            IF pmodo = 'R' THEN
               ntraza := 3;

               SELECT NVL(MAX(nnumlin) + 1, 1)
                 INTO xnnumlin
                 FROM ctaseguro_shadow
                WHERE sseguro = psseguro;
            ELSIF pmodo = 'P' THEN
               ntraza := 4;

               SELECT NVL(MAX(nnumlin) + 1, 1)
                 INTO xnnumlin
                 FROM ctaseguro_previo_shw
                WHERE sseguro = psseguro;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 104882;   -- Error al llegir de CTASEGURO
         END;

         BEGIN
            -- RSC 18/03/2008 (ultimo valor lo cogemos de tabvalces)
            -- Tarea 31548/206135 Management expenses
            SELECT NVL(iuniactvtashw, 0)
              INTO iuniacts
              FROM tabvalces
             WHERE ccesta = regs.ccesta
               AND TRUNC(fvalor) = v_fecha + pac_md_fondos.f_get_diasdep(regs.ccesta);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               p_tab_error
                        (f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_ins_detalle_gasto_shw',
                         ntraza,
                         'No hay valor liquidativo para la fecha. parametros: psseguro = '
                         || psseguro || ' ppfefecto=' || ppfefecto || ' v_sproduc='
                         || v_sproduc || ' pmodo=' || pmodo || ' pcmovimi=' || pcmovimi
                         || ' v_fecha=' || v_fecha,
                         SQLERRM, 50);
               iuniacts := 0;
         END;

         --
         --Calcula les distribucions
         vacumpercent := vacumpercent + (ggesmensual * regs.pdistrec) / 100;
         imovimo := ROUND(vacumpercent - vacumrounded, 2);
         vacumrounded := vacumrounded + ROUND(vacumpercent - vacumrounded, 2);

         --
         IF NVL(iuniacts, 0) = 0 THEN
            num_err := pac_ctaseguro.f_insctaseguro_shw(psseguro, vfsysdate, NULL, v_fecha,
                                                        v_fecha, 83, imovimo, NULL, NULL,
                                                        v_seqgrupo, 0, NULL, NULL, '1', pmodo,
                                                        NULL, NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, regs.ccesta);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         ELSE
            BEGIN
               IF pmodo = 'R' THEN
                  ntraza := 6;

                  INSERT INTO ctaseguro_shadow
                              (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                               imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec, cesta,
                               nunidad, cestado, fasign)
                       VALUES (psseguro, vfsysdate, xnnumlin, v_fecha, v_fecha, 83, imovimo,
                               NULL, NULL, v_seqgrupo, 0, NULL, NULL, regs.ccesta,
                               -1 *(imovimo / iuniacts), '2', vfsysdate);

                  -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  IF v_cmultimon = 1 THEN
                     num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro,
                                                                               vfsysdate,
                                                                               xnnumlin,
                                                                               v_fecha);

                     IF num_err <> 0 THEN
                        p_tab_error(f_sysdate, f_user,
                                    'PAC_OPERATIVA_FINV.f_ins_detalle_gasto_shw', ntraza,
                                    'parametros: psseguro = ' || psseguro || ' ppfefecto='
                                    || ppfefecto || ' v_sproduc=' || v_sproduc || ' pmodo='
                                    || pmodo || ' pcmovimi=' || pcmovimi || ' v_fecha='
                                    || v_fecha,
                                    SQLERRM);
                        RETURN num_err;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  xnnumlin := xnnumlin + 1;
               ELSIF pmodo = 'P' THEN
                  ntraza := 7;

                  INSERT INTO ctaseguro_previo_shw
                              (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                               imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec, cesta,
                               nunidad, cestado, fasign)
                       VALUES (psseguro, vfsysdate, xnnumlin, v_fecha, v_fecha, 83, imovimo,
                               NULL, NULL, v_seqgrupo, 0, NULL, NULL, regs.ccesta,
                               -1 *(imovimo / iuniacts), '2', vfsysdate);

                  xnnumlin := xnnumlin + 1;
               END IF;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_ins_detalle_gasto_shw',
                              ntraza,
                              'parametros: psseguro = ' || psseguro || ' ppfefecto='
                              || ppfefecto || ' v_sproduc=' || v_sproduc || ' pmodo=' || pmodo
                              || ' pcmovimi=' || pcmovimi || ' v_fecha=' || v_fecha,
                              SQLERRM);
                  RETURN 104879;   -- Registre duplicat a CTASEGURO
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_ins_detalle_gasto_shw',
                              ntraza,
                              'parametros: psseguro = ' || psseguro || ' ppfefecto='
                              || ppfefecto || ' v_sproduc=' || v_sproduc || ' pmodo=' || pmodo
                              || ' pcmovimi=' || pcmovimi || ' v_fecha=' || v_fecha,
                              SQLERRM);
                  RETURN 102555;   -- Error al insertar a la taula CTASEGURO
            END;
         --
         END IF;
      --
      END LOOP;

      --
      RETURN(0);
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_ins_detalle_gasto_shw', ntraza,
                     'parametros: psseguro = ' || psseguro || ' ppfefecto=' || ppfefecto
                     || ' v_sproduc=' || v_sproduc || ' pmodo=' || pmodo || ' pcmovimi='
                     || pcmovimi || ' v_fecha=' || v_fecha,
                     SQLERRM);
         RETURN 102555;   -- Error al insertar a la taula CTASEGURO
   END f_ins_detalle_gasto_shw;

   /********************************************
     funcion que retorna el importe total de la bonificación rescatable
   ********************************************/
   FUNCTION f_get_imppb(
      psseguro IN seguros.sseguro%TYPE,
      pccesta IN NUMBER,
      pfecha IN DATE,
      pimppb OUT NUMBER)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'parametros: psseguro = ' || psseguro || ' pccesta = ' || pccesta || ' pfecha = '
            || pfecha;
      vobject        VARCHAR2(50) := 'PAC_OPERATIVA_FINV.f_get_imppb';
   --
   BEGIN
      --
      SELECT NVL(SUM(DECODE(c.cmovimi, 9, 1, 37, -1, 39, -1) * c.imovimi), 0)
        INTO pimppb
        FROM ctaseguro c, fondos f
       WHERE c.sseguro = psseguro
         AND f.ccodfon = c.cesta
         AND c.cesta = pccesta
         AND c.cmovanu <> 1
         AND c.ffecmov BETWEEN TRUNC(ADD_MONTHS(pfecha,(-1 * NVL(f.nperiodbon, 0)))) AND pfecha
         AND c.cmovimi IN(9, 37, 39);

      --
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 140999;
   END f_get_imppb;

   /********************************************
     funcion que retorna el importe total de la bonificación rescatable sombra
   ********************************************/
   FUNCTION f_get_imppb_shw(
      psseguro IN seguros.sseguro%TYPE,
      pccesta IN NUMBER,
      pfecha IN DATE,
      pimppb OUT NUMBER)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'parametros: psseguro = ' || psseguro || ' pccesta = ' || pccesta || ' pfecha = '
            || pfecha;
      vobject        VARCHAR2(50) := 'PAC_OPERATIVA_FINV.f_get_imppb_shw';
   --
   BEGIN
      --
      SELECT NVL(SUM(DECODE(c.cmovimi, 9, 1, 37, -1, 39, -1) * c.imovimi), 0)
        INTO pimppb
        FROM ctaseguro_shadow c, fondos f
       WHERE c.sseguro = psseguro
         AND c.cesta = pccesta
         AND f.ccodfon = c.cesta
         AND c.cmovanu <> 1
         AND c.ffecmov BETWEEN TRUNC(ADD_MONTHS(pfecha,(-1 * NVL(f.nperiodbon, 0)))) AND pfecha
         AND c.cmovimi IN(9, 37, 39);

      --
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 140999;
   END f_get_imppb_shw;

   FUNCTION f_valida_cesta_switch(pccesta IN NUMBER, funds IN t_iax_produlkmodinvfondo)
      RETURN NUMBER IS
      existe         NUMBER := 0;
   BEGIN
      FOR i IN funds.FIRST .. funds.LAST LOOP
         IF funds(i).ccodfon = pccesta THEN
            existe := 1;
         END IF;
      END LOOP;

      RETURN existe;
   END f_valida_cesta_switch;

-- Bug 36746/0211309 - APD - 17/09/2015 - se crea la funcion
   FUNCTION f_ejecutar_switch(psseguro IN NUMBER)
      RETURN NUMBER IS
      total_cestas   NUMBER := 0;
      total_saldo_u  NUMBER := 0;
      total_cestas_shw NUMBER := 0;
      total_saldo_u_shw NUMBER := 0;
      num_err        NUMBER;
      -- Estructura para almacenar pares (cesta - unidades cesta)
      v_det_modinv   tt_det_modinv;
      v_det_modinv_shw tt_det_modinv;
      pfefecto       DATE;
      sivendecompra  NUMBER := 0;
      sivendecompra_shw NUMBER := 0;
      seqgrupo       NUMBER;
      -- Bug 9424 - 15/04/2009 - RSC - Creación del producto PPJ Dinàmic
      v_gasred       NUMBER;
      -- Fin Bug 9424
      v_nerrores     NUMBER := 0;
      v_sproces      NUMBER;
      -- Mantis 12274.NMM.15/12/2009.i.
      w_fdiahabil    DATE;
      w_fdiahabil2   DATE;   -- Mantis 12274.f.
      v_sproduc      NUMBER;
      v_cempres      NUMBER;
      -- Bug 10828 - RSC - 14/10/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      v_preciounidad NUMBER;
      v_nmovimi      NUMBER;
      vfefecto       DATE;
      vfmovimi       DATE;
      vtieneshw      NUMBER;
      funds          t_iax_produlkmodinvfondo := t_iax_produlkmodinvfondo();
      i              NUMBER;

      CURSOR nmov IS
         SELECT   movseguro.nmovimi, movseguro.fefecto, movseguro.fmovimi
             FROM movseguro, detmovseguro
            WHERE movseguro.sseguro = psseguro
              AND detmovseguro.sseguro = movseguro.sseguro
              AND detmovseguro.nmovimi = movseguro.nmovimi
              AND detmovseguro.cmotmov = 408
         ORDER BY nmovimi DESC;

      CURSOR curcestas IS
         SELECT ccesta, pdistrec
           FROM (SELECT ccesta, pdistrec
                   FROM segdisin2
                  WHERE sseguro = psseguro
                    AND nmovimi = (SELECT MAX(nmovimi)
                                     FROM segdisin2
                                    WHERE sseguro = psseguro)
                 MINUS
                 SELECT ccesta, pdistrec
                   FROM segdisin2
                  WHERE sseguro = psseguro
                    AND nmovimi = (SELECT MAX(nmovimi) - 1
                                     FROM segdisin2
                                    WHERE sseguro = psseguro));
   -- Fin Bug 10828
   BEGIN
      vtieneshw := pac_ctaseguro.f_tiene_ctashadow(psseguro, NULL);

      OPEN nmov;

      FETCH nmov
       INTO v_nmovimi, vfefecto, vfmovimi;

      CLOSE nmov;

      -- Mantis 12274.NMM.i.
      SELECT sproduc, cempres
        INTO v_sproduc, v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      -- 12274.f.

      -- Se debe guardar en una lista la informacion que se haya modificado de los fondos
      OPEN curcestas;

      LOOP
         funds.EXTEND;
         funds(funds.LAST) := ob_iax_produlkmodinvfondo();

         FETCH curcestas
          INTO funds(funds.LAST).ccodfon, funds(funds.LAST).pinvers;

         EXIT WHEN curcestas%NOTFOUND;
      END LOOP;

      CLOSE curcestas;

      IF funds.COUNT <> 0 THEN
         -- Mantis 12274.NMM.i.
         --Bug -XVM-07/11/2012.Inicio
         w_fdiahabil := f_diahabil(13, TRUNC(vfefecto), NULL);

         IF pac_mantenimiento_fondos_finv.f_get_estado_fondo(v_cempres, TRUNC(f_sysdate)) =
                                                                                        107742 THEN
            w_fdiahabil2 := f_diahabil(0, TRUNC(f_sysdate), NULL);
         ELSE
            w_fdiahabil2 := TRUNC(f_sysdate);
         END IF;

         pfefecto := GREATEST(w_fdiahabil, w_fdiahabil2);
         --Bug -XVM-07/11/2012.Fin.

         -- 12274.f.
         num_err := f_cta_saldo_fondos(psseguro, NULL, total_cestas, total_saldo_u,
                                       v_det_modinv, funds);

         IF num_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_cta_saldo_fondos', NULL,
                        'parametros: psseguro = ' || psseguro,
                        f_axis_literales(num_err, f_idiomauser));
            RETURN num_err;
         END IF;

         IF vtieneshw = 1 THEN
            num_err := f_cta_saldo_fondos_shw(psseguro, NULL, total_cestas_shw,
                                              total_saldo_u_shw, v_det_modinv_shw, funds);

            IF num_err <> 0 THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_cta_saldo_fondos_shw',
                           NULL, 'parametros: psseguro = ' || psseguro,
                           f_axis_literales(num_err, f_idiomauser));
               RETURN num_err;
            END IF;
         END IF;

         -- Reconversión de aportaciones realizadas entre la primera redistribución y la presente
         num_err := f_redistribuye_aportaciones(psseguro, pfefecto);

         IF num_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_aportaciones',
                        NULL, 'parametros: psseguro = ' || psseguro,
                        f_axis_literales(num_err, f_idiomauser));
            RETURN num_err;
         END IF;

         IF vtieneshw = 1 THEN
            num_err := f_redist_aportaciones_shw(psseguro, pfefecto);

            IF num_err <> 0 THEN
               p_tab_error(f_sysdate, f_user,
                           'PAC_OPERATIVA_FINV.f_redistribuye_aportaciones_shw', NULL,
                           'parametros: psseguro = ' || psseguro,
                           f_axis_literales(num_err, f_idiomauser));
               RETURN num_err;
            END IF;
         END IF;

         SELECT scagrcta.NEXTVAL
           INTO seqgrupo
           FROM DUAL;

         -- Entradas de venta por redistribución
         num_err := f_redistribuye_venta(psseguro, v_det_modinv, pfefecto, sivendecompra,
                                         seqgrupo);

         IF num_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_venta', NULL,
                        'parametros: psseguro = ' || psseguro,
                        f_axis_literales(num_err, f_idiomauser));
            RETURN num_err;
         END IF;

         IF vtieneshw = 1 THEN
            num_err := f_redistribuye_venta_shw(psseguro, v_det_modinv_shw, pfefecto,
                                                sivendecompra_shw, seqgrupo);

            IF num_err <> 0 THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_venta', NULL,
                           'parametros: psseguro = ' || psseguro,
                           f_axis_literales(num_err, f_idiomauser));
               RETURN num_err;
            END IF;
         END IF;

         -- Entradas de compra por redistribución
         num_err := f_redistribuye_compra(psseguro, pfefecto, sivendecompra, seqgrupo, funds);

         IF num_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_compra', NULL,
                        'parametros: psseguro = ' || psseguro,
                        f_axis_literales(num_err, f_idiomauser));
            RETURN num_err;
         END IF;

         IF vtieneshw = 1 THEN
            num_err := f_redistribuye_compra_shw(psseguro, pfefecto, sivendecompra_shw,
                                                 seqgrupo, funds);

            IF num_err <> 0 THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_compra_shw',
                           NULL, 'parametros: psseguro = ' || psseguro,
                           f_axis_literales(num_err, f_idiomauser));
               RETURN num_err;
            END IF;
         END IF;

         -- Bug 9424 - 15/04/2009 - RSC - Creación del producto PPJ Dinàmic
         /* INI AFM
         SELECT cgasred
           INTO v_gasred
           FROM seguros_ulk
          WHERE sseguro = psseguro;

         -- Si no tiene definido gasto por redistribución no se aplica gasto
         IF v_gasred IS NOT NULL THEN
         */

         -- Entradas de gastos por redistribución
         num_err := f_redistribuye_gastosredis(psseguro, pfefecto, seqgrupo, funds);

         IF num_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_redistribuye_gastosredis',
                        NULL, 'parametros: psseguro = ' || psseguro,
                        f_axis_literales(num_err, f_idiomauser));
            RETURN num_err;
         END IF;

         IF vtieneshw = 1 THEN
            num_err := f_redistribuye_gastosredis_shw(psseguro, pfefecto, seqgrupo, funds);

            IF num_err <> 0 THEN
               p_tab_error(f_sysdate, f_user,
                           'PAC_OPERATIVA_FINV.f_redistribuye_gastosredis_shw', NULL,
                           'parametros: psseguro = ' || psseguro,
                           f_axis_literales(num_err, f_idiomauser));
               RETURN num_err;
            END IF;
         END IF;

         -- Asignamos movimientos de venta y compra si disponemos del valor liquidativo.
         num_err := pac_mantenimiento_fondos_finv.f_redist_asign_unidades(TRUNC(pfefecto),
                                                                          v_sproces,
                                                                          v_nerrores,
                                                                          f_idiomauser, NULL,
                                                                          psseguro, funds);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         IF vtieneshw = 1 THEN
            num_err :=
               pac_mantenimiento_fondos_finv.f_redist_asign_unidades_shw(TRUNC(pfefecto),
                                                                         v_sproces,
                                                                         v_nerrores,
                                                                         f_idiomauser, NULL,
                                                                         psseguro, funds);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;
      -- Fin Bug 9424
      END IF;   -- v_det_fondos.COUNT <> 0

      RETURN(0);
   -- BUG -21546_108724- 08/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
   EXCEPTION
      WHEN OTHERS THEN
         IF nmov%ISOPEN THEN
            CLOSE nmov;
         END IF;

         RETURN 140999;
   END f_ejecutar_switch;

-- Bug 36746/0211309 - APD - 17/09/2015 - se crea la funcion
   FUNCTION f_get_lstfondosseg(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN DATE,
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      IF psseguro IS NOT NULL THEN
         psquery :=
            'SELECT DISTINCT s.ccesta ccodfon, f.tfonabv tfonabv
           FROM segdisin2 s, fondos f
          WHERE s.ccesta = f.ccodfon
            AND s.sseguro = '
            || psseguro || ' AND ((to_date(''' || TO_CHAR(pfecha, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'') >= s.finicio
                   AND to_date(''' || TO_CHAR(pfecha, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'') < s.ffin)
                OR(to_date(''' || TO_CHAR(pfecha, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'') >= s.finicio
                   AND s.ffin IS NULL))
            AND s.nmovimi = (SELECT MAX(s2.nmovimi)
                               FROM segdisin2 s2
                              WHERE s2.sseguro = s.sseguro
                                AND s2.nriesgo = s.nriesgo)
       ORDER BY f.tfonabv';
      ELSE
         psquery :=
            'SELECT   ccodfon, tfonabv
                    FROM fondos
                  WHERE ((to_date('''
            || TO_CHAR(pfecha, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'') >= finicio
                   AND to_date(''' || TO_CHAR(pfecha, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'') < ffin)
                OR(to_date(''' || TO_CHAR(pfecha, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'') >= finicio
                   AND ffin IS NULL))
                    AND cempres = '
            || pcempres || '
               ORDER BY tfonabv';
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_operativa_finv.f_get_lstfondosseg', 1, SQLCODE,
                     SQLERRM);
         RETURN 1000455;
   END f_get_lstfondosseg;

-- Bug 36746/0211309 - APD - 17/09/2015 - se crea la funcion
   FUNCTION f_valida_switch(
      pccodfonori IN NUMBER,
      pccodfondtn IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN DATE)
      RETURN NUMBER IS
      ntraza         NUMBER;
      vcont          NUMBER;
      vnumerr        NUMBER;
      vcempres       NUMBER;
   BEGIN
      IF pccodfonori IS NULL
         OR pccodfondtn IS NULL THEN
         RETURN 9908464;   -- Debe informar un fondo.
      END IF;

      IF pccodfonori = pccodfondtn THEN
         RETURN 9908465;   -- El fondo origen y el fondo destino no pueden ser el mismo.
      END IF;

      SELECT COUNT(1)
        INTO vcont
        FROM fondos f1, fondos f2
       WHERE f1.ccodfon = pccodfonori
         AND f2.ccodfon = pccodfondtn
         AND f1.ctipfon <> f2.ctipfon;

      IF vcont <> 0 THEN
         RETURN 9908466;   -- El fondo origen y el fondo destino deben ser del mismo tipo (Interno / Externo).
      END IF;

      IF psseguro IS NOT NULL THEN
         IF pfecha IS NULL THEN
            RETURN 9000522;   --Falta informar el param. fecha
         END IF;

         SELECT COUNT(1)
           INTO vcont
           FROM segdisin2 s1
          WHERE sseguro = psseguro
            AND nmovimi IN(SELECT MAX(s2.nmovimi)
                             FROM segdisin2 s2
                            WHERE s1.sseguro = s2.sseguro
                              AND s1.nriesgo = s2.nriesgo)
            AND ccesta = pccodfonori
            AND(ffin > pfecha
                OR ffin IS NULL);

         IF vcont = 0 THEN
            RETURN 9908468;   -- Fondo no contratado en la póliza.
         END IF;

         SELECT COUNT(1)
           INTO vcont
           FROM seguros s, seguros_ulk su, modinvfondo m
          WHERE s.sseguro = su.sseguro
            AND su.cmodinv = m.cmodinv
            AND m.cramo = s.cramo
            AND m.cmodali = s.cmodali
            AND m.ctipseg = s.ctipseg
            AND m.ccolect = s.ccolect
            AND m.ccodfon = pccodfondtn
            AND s.sseguro = psseguro;

         IF vcont = 0 THEN
            RETURN 9908469;   -- Fondo no incluido en el perfil de inversión contratado en la póliza.
         END IF;

         SELECT cempres
           INTO vcempres
           FROM seguros
          WHERE sseguro = psseguro;

         vnumerr := pac_ctaseguro.f_ctaseguro_consolidada(pfecha, vcempres, pccodfonori,
                                                          psseguro,
                                                          pac_propio.f_usar_shw(psseguro,
                                                                                pfecha));

         IF vnumerr = 0 THEN
            RETURN 9908467;   -- Fondo no consolidado
         END IF;

         SELECT COUNT(1)
           INTO vcont
           FROM seguros s
          WHERE s.sseguro = psseguro
            AND f_situacion_v(s.sseguro, pfecha) = 1
            AND s.creteni = 0;

         IF vcont = 0 THEN
            RETURN 9908470;   -- Póliza no vigente
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_FINV.f_valida_switch', ntraza,
                     'parametros: pccodfonori = ' || pccodfonori || ' pccodfondtn ='
                     || pccodfondtn || ' psseguro =' || psseguro || ' pfecha='
                     || TO_CHAR(pfecha, 'DD/MM/YYYY'),
                     SQLERRM);
         RETURN 1000455;   -- Error no controlado.
   END f_valida_switch;

-- Bug 36746/0211309 - APD - 17/09/2015 - se crea la funcion
   FUNCTION f_switch_fondos(
      pccodfonori IN NUMBER,
      pccodfondtn IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN DATE,
      psproces IN OUT NUMBER,
      plineas IN OUT NUMBER,
      plineas_error IN OUT NUMBER)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      numerr         NUMBER := 0;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(400)
         := 'pccodfonori = ' || pccodfonori || ' pccodfondtn =' || pccodfondtn
            || ' psseguro =' || psseguro || ' pfecha=' || TO_CHAR(pfecha, 'DD/MM/YYYY')
            || ' psproces =' || psproces || ' plineas =' || plineas || ' plineas_error ='
            || plineas_error;
      vobject        VARCHAR2(200) := 'PAC_OPERATIVA_FINV.f_switch_fondos';
      salida         EXCEPTION;
      error_fin_supl EXCEPTION;
      warn_fin_supl  EXCEPTION;
      e_param_error  EXCEPTION;
      vcmotmov       NUMBER := 409;
      v_est_sseguro  NUMBER;
      v_nmovimi      NUMBER;
      vpdistrec      NUMBER;
      vcont          NUMBER;
      v_sproduc      seguros.sproduc%TYPE;
      v_cactivi      seguros.cactivi%TYPE;
      v_cforpag      seguros.cforpag%TYPE;
      vcempres       seguros.cempres%TYPE;
      vnpoliza       seguros.npoliza%TYPE;
      vncertif       seguros.ncertif%TYPE;
      vcramo         seguros.cramo%TYPE;
      vcmodali       seguros.cmodali%TYPE;
      vctipseg       seguros.ctipseg%TYPE;
      vccolect       seguros.ccolect%TYPE;
      vcidioma       seguros.cidioma%TYPE;
      indice         NUMBER;
      indice_e       NUMBER;
      indice_t       NUMBER;
      v_sproces      NUMBER;
      v_nnumlin      NUMBER := NULL;
      v_texto        VARCHAR2(500);
      v_err          NUMBER;
      pmensaje       VARCHAR2(500);   -- BUG 27642 - FAL - 30/04/2014
   BEGIN
      plineas := 0;
      plineas_error := 0;
      vpasexec := 1;

      IF pccodfonori IS NULL
         OR pccodfondtn IS NULL THEN
         RETURN 9908464;   -- Debe informar un fondo.
      END IF;

      IF pfecha IS NULL THEN
         RETURN 9000522;   --Falta informar el param. fecha
      END IF;

      vpasexec := 2;

      -- Si no viene informacio SPROCES creamos uno
      IF psproces IS NULL THEN
         numerr := f_procesini(f_user, pac_md_common.f_get_cxtempresa, 'SWITCH FONDOS',
                               f_axis_literales(9908373, f_idiomauser), v_sproces);
      ELSE
         v_sproces := psproces;
      END IF;

      FOR reg IN (SELECT s.sseguro
                    FROM segdisin2 s1, seguros s
                   WHERE s1.sseguro = s.sseguro
                     AND((s.sseguro = psseguro
                          AND psseguro IS NOT NULL)
                         OR(psseguro IS NULL))
                     AND s1.nmovimi IN(SELECT MAX(s2.nmovimi)
                                         FROM segdisin2 s2
                                        WHERE s1.sseguro = s2.sseguro
                                          AND s1.nriesgo = s2.nriesgo)
                     AND s1.ccesta = pccodfonori
                     AND(s1.ffin > pfecha
                         OR s1.ffin IS NULL)
                     AND f_situacion_v(s.sseguro, pfecha) = 1
                     AND s.creteni = 0) LOOP
         BEGIN
            vpasexec := 3;
            plineas := plineas + 1;
            numerr := pac_operativa_finv.f_valida_switch(pccodfonori, pccodfondtn,
                                                         reg.sseguro, pfecha);

            IF numerr <> 0 THEN
               v_texto := f_axis_literales(numerr, f_idiomauser);
               v_err := f_proceslin(v_sproces, v_texto || ' Traza ' || vpasexec, reg.sseguro,
                                    v_nnumlin);
               RAISE error_fin_supl;
            END IF;

            v_est_sseguro := NULL;
            v_nmovimi := NULL;

            SELECT cempres, npoliza, ncertif, cramo, cmodali, ctipseg, ccolect,
                   sproduc, cforpag, cactivi, cidioma
              INTO vcempres, vnpoliza, vncertif, vcramo, vcmodali, vctipseg, vccolect,
                   v_sproduc, v_cforpag, v_cactivi, vcidioma
              FROM seguros
             WHERE sseguro = reg.sseguro;

            vpasexec := 4;
-------------------------------------------------------------------------------------------
-- Se traspasan los datos a las tablas EST y se dejan preparadas para hacer el suplemento
-------------------------------------------------------------------------------------------
-- Todas las funciones a partir de esta deben tener RAISE error_fin_supl
            vpasexec := 5;
            numerr := pk_suplementos.f_permite_suplementos(reg.sseguro, pfecha, vcmotmov);

            IF numerr <> 0 THEN
               v_texto := f_axis_literales(numerr, f_idiomauser);
               v_err := f_proceslin(v_sproces, v_texto || ' Traza ' || vpasexec, reg.sseguro,
                                    v_nnumlin);
               RAISE error_fin_supl;
            END IF;

            vpasexec := 6;

            IF vcmotmov IS NOT NULL THEN
               numerr := pk_suplementos.f_permite_este_suplemento(reg.sseguro, pfecha,
                                                                  vcmotmov);

               IF numerr <> 0 THEN
                  v_texto := f_axis_literales(numerr, f_idiomauser);
                  v_err := f_proceslin(v_sproces, v_texto || ' Traza ' || vpasexec,
                                       reg.sseguro, v_nnumlin);
                  RAISE error_fin_supl;
               END IF;
            END IF;

            vpasexec := 7;
            numerr := pk_suplementos.f_inicializar_suplemento(reg.sseguro, 'SUPLEMENTO',
                                                              pfecha, 'BBDD', '*', vcmotmov,
                                                              v_est_sseguro, v_nmovimi,
                                                              'NOPRAGMA');

            IF numerr <> 0 THEN
               v_texto := f_axis_literales(numerr, f_idiomauser);
               v_err := f_proceslin(v_sproces, v_texto || ' Traza ' || vpasexec, reg.sseguro,
                                    v_nnumlin);
               RAISE error_fin_supl;
            END IF;

-- UPDATE  ----------------------------------------------------
            vpasexec := 8;

            -- redirecciona todo el % del fondo origen al fondo destino
            SELECT pdistrec
              INTO vpdistrec
              FROM estsegdisin2
             WHERE sseguro = v_est_sseguro
               AND nmovimi = v_nmovimi
               AND ccesta = pccodfonori;

            UPDATE estsegdisin2
               SET pdistrec = 0
             WHERE sseguro = v_est_sseguro
               AND nmovimi = v_nmovimi
               AND ccesta = pccodfonori;

            UPDATE estsegdisin2
               SET pdistrec = pdistrec + vpdistrec
             WHERE sseguro = v_est_sseguro
               AND nmovimi = v_nmovimi
               AND ccesta = pccodfondtn;

----------------------------------------------------
            vpasexec := 9;
            -- se le pasa el cmotmov a la funcion para que solo valide el suplemento indicado
            numerr := pk_suplementos.f_validar_cambios(f_user, v_est_sseguro, v_nmovimi,
                                                       v_sproduc, 'BBDD', 'SUPLEMENTO',
                                                       vcidioma, vcmotmov);

            IF numerr <> 0 THEN
               v_texto := f_axis_literales(numerr, f_idiomauser);
               v_err := f_proceslin(v_sproces, v_texto || ' Traza ' || vpasexec, reg.sseguro,
                                    v_nnumlin);
               RAISE error_fin_supl;
            END IF;

            vpasexec := 10;

            BEGIN
               -- s'ha de validar que hi hagin registres
               SELECT COUNT(*)
                 INTO vcont
                 FROM estdetmovseguro
                WHERE sseguro = v_est_sseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  v_texto := f_axis_literales(1000455, f_idiomauser);   -- Error no controlado.
                  v_err := f_proceslin(v_sproces, v_texto || ' Traza ' || vpasexec,
                                       reg.sseguro, v_nnumlin);
                  RAISE error_fin_supl;
            END;

            IF vcont = 0 THEN   -- No hi hagut canvis
               v_texto := f_axis_literales(107804, f_idiomauser);   -- No se ha realizado ningún cambio
               v_err := f_proceslin(v_sproces, v_texto || ' Traza ' || vpasexec, reg.sseguro,
                                    v_nnumlin);
               RAISE warn_fin_supl;
            END IF;

            -- Es grava el suplement a las taules reals
            vpasexec := 11;
            numerr := pk_suplementos.f_grabar_suplemento_poliza(v_est_sseguro, v_nmovimi);

            IF numerr <> 0 THEN
               v_texto := f_axis_literales(numerr, f_idiomauser);
               v_err := f_proceslin(v_sproces, v_texto || ' Traza ' || vpasexec, reg.sseguro,
                                    v_nnumlin);
               RAISE error_fin_supl;
            END IF;

-------------------------------------------------------------------------------------------
-- Se emite el suplemento
-------------------------------------------------------------------------------------------
            vpasexec := 12;
            p_emitir_propuesta(vcempres, vnpoliza, vncertif, vcramo, vcmodali, vctipseg,
                               vccolect, v_cactivi, 1, vcidioma, indice, indice_e, indice_t,
                               pmensaje,   -- BUG 27642 - FAL - 30/04/2014
                               NULL, NULL, 1);

            IF indice_e <> 0
               OR indice < 1 THEN
               v_texto := f_axis_literales(151237, f_idiomauser);
               v_err := f_proceslin(v_sproces, v_texto || ' Traza ' || vpasexec, reg.sseguro,
                                    v_nnumlin);
               RAISE error_fin_supl;
            END IF;

            -- Fin Bug 16095 - APD - 05/11/2010
            v_texto := f_axis_literales(9904571, f_idiomauser);   -- Suplemento ejecutado correctamente.
            v_err := f_proceslin(v_sproces, v_texto, reg.sseguro, v_nnumlin, 2);
            COMMIT;
         EXCEPTION
            WHEN e_param_error THEN
               plineas_error := plineas_error + 1;
               ROLLBACK;
               numerr := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi,
                                                           reg.sseguro);
               COMMIT;
               v_est_sseguro := NULL;
               v_nmovimi := NULL;
               v_texto := f_axis_literales(103135, f_idiomauser);   -- Faltan parámetros
               v_err := f_proceslin(v_sproces, v_texto || ' Traza ' || vpasexec, reg.sseguro,
                                    v_nnumlin);
            WHEN warn_fin_supl THEN
               plineas_error := plineas_error + 1;
               ROLLBACK;
               numerr := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi,
                                                           reg.sseguro);
               COMMIT;
               v_est_sseguro := NULL;
               v_nmovimi := NULL;
            WHEN error_fin_supl THEN
               plineas_error := plineas_error + 1;
               ROLLBACK;
               numerr := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi,
                                                           reg.sseguro);
               COMMIT;
               v_est_sseguro := NULL;
               v_nmovimi := NULL;
            WHEN OTHERS THEN
               plineas_error := plineas_error + 1;
               ROLLBACK;
               numerr := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi,
                                                           reg.sseguro);
               COMMIT;
               v_est_sseguro := NULL;
               v_nmovimi := NULL;
               v_texto := f_axis_literales(1000455, f_idiomauser) || ' - ' || SQLERRM;   -- Error no controlado.
               v_err := f_proceslin(v_sproces, v_texto || ' Traza ' || vpasexec, reg.sseguro,
                                    v_nnumlin);
         END;
      END LOOP;

      v_texto := f_axis_literales(103351, f_idiomauser) || TO_CHAR(plineas - plineas_error)
                 || ' | ' || f_axis_literales(103149, f_idiomauser) || plineas_error;
      v_err := f_proceslin(v_sproces, v_texto, 0, v_nnumlin, 2);

      -- Finalizamos proces
      IF psproces IS NULL THEN
         numerr := f_procesfin(v_sproces, 0);
      END IF;

      psproces := v_sproces;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1000455;   -- Error no controlado.
   END f_switch_fondos;
END pac_operativa_finv;

/

  GRANT EXECUTE ON "AXIS"."PAC_OPERATIVA_FINV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_OPERATIVA_FINV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_OPERATIVA_FINV" TO "PROGRAMADORESCSI";
