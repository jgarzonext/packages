--------------------------------------------------------
--  DDL for Package Body PAC_OPERATIVA_ULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_OPERATIVA_ULK" AS
   /******************************************************************************
      NOMBRE:       PAC_OPERATIVA_ULK
      PROPÓSITO:
      REVISIONES:

      Ver        Fecha        Autor     Descripción
      ---------  ----------  -------  ------------------------------------
       1.0       -            -       1. Creación de package
       2.0       15/12/2011   JMP     2. 0018423: LCOL705 - Multimoneda
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
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.ff_primas_satisfechas', 1,
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
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.ff_primas_satisfechas_shw', 1,
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
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.ff_gastos_gestion_y_cobertura', 1,
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
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.ff_gastos_gestion_y_cobertura_shw',
                     1, 'psSeguro = ' || psseguro, SQLERRM);
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
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.ff_gastos_redistribucion', 1,
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
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.ff_gastos_redistribucion_shw', 1,
                     'psSeguro = ' || psseguro, SQLERRM);
         RETURN NULL;
   END ff_gastos_redistribucion_shw;

   FUNCTION ff_valor_provision(psseguro IN NUMBER, ppfefecto IN NUMBER)
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

      nparacts       NUMBER;
      iuniacts       NUMBER;
      v_provision    NUMBER := 0;
      pfefecto       DATE;
   BEGIN
      pfefecto := TO_DATE(ppfefecto, 'yyyy/mm/dd');

      FOR regs IN cur_cesta LOOP
         BEGIN
            -- Query para obtener las participaciones acumuladas de la cesta
            SELECT NVL(SUM(nunidad), 0)
              INTO nparacts
              FROM ctaseguro
             WHERE sseguro = psseguro
               --and cmovimi <> 0
               AND cmovimi NOT IN(0, 91, 93, 94, 97)   -- RSC 01/12/2008
               AND cesta = regs.ccesta
               AND fvalmov <= pfefecto
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
                  SELECT NVL(iuniact, 0)
                    INTO iuniacts
                    FROM tabvalces
                   WHERE ccesta = regs.ccesta
                     AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                            FROM tabvalces
                                           WHERE ccesta = regs.ccesta
                                             AND TRUNC(fvalor) <= TRUNC(pfefecto));
            END;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_valor_provisión', NULL,
                           'parametros: psseguro =' || psseguro || 'pfefecto =' || pfefecto,
                           SQLERRM);
               RETURN(NULL);
         END;

         v_provision := v_provision +(nparacts * iuniacts);
      END LOOP;

      v_provision := ROUND(v_provision, 2);
      RETURN(v_provision);
   END ff_valor_provision;

   FUNCTION ff_valor_provision_shw(psseguro IN NUMBER, ppfefecto IN NUMBER)
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

      nparacts       NUMBER;
      iuniacts       NUMBER;
      v_provision    NUMBER := 0;
      pfefecto       DATE;
   BEGIN
      pfefecto := TO_DATE(ppfefecto, 'yyyy/mm/dd');

      FOR regs IN cur_cesta LOOP
         BEGIN
            -- Query para obtener las participaciones acumuladas de la cesta
            SELECT NVL(SUM(nunidad), 0)
              INTO nparacts
              FROM ctaseguro_shadow
             WHERE sseguro = psseguro
               --and cmovimi <> 0
               AND cmovimi NOT IN(0, 91, 93, 94, 97)   -- RSC 01/12/2008
               AND cesta = regs.ccesta
               AND fvalmov <= pfefecto
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
                  SELECT NVL(iuniactvtashw, 0)
                    INTO iuniacts
                    FROM tabvalces
                   WHERE ccesta = regs.ccesta
                     AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                            FROM tabvalces
                                           WHERE ccesta = regs.ccesta
                                             AND TRUNC(fvalor) <= TRUNC(pfefecto));
            END;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_valor_provisión_shw', NULL,
                           'parametros: psseguro =' || psseguro || 'pfefecto =' || pfefecto,
                           SQLERRM);
               RETURN(NULL);
         END;

         v_provision := v_provision +(nparacts * iuniacts);
      END LOOP;

      v_provision := ROUND(v_provision, 2);
      RETURN(v_provision);
   END ff_valor_provision_shw;

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
               AND cmovimi NOT IN(0, 91, 93, 94, 97)   -- RSC 01/12/2008
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
                  SELECT NVL(iuniact, 0)
                    INTO iuniacts
                    FROM tabvalces
                   WHERE ccesta = regs.ccesta
                     AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                            FROM tabvalces
                                           WHERE ccesta = regs.ccesta
                                             AND TRUNC(fvalor) <= TRUNC(pfefecto));
            END;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_valor_provisión', NULL,
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
               AND cmovimi NOT IN(0, 91, 93, 94, 97)   -- RSC 01/12/2008
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
                  SELECT NVL(iuniactvtashw, 0)
                    INTO iuniacts
                    FROM tabvalces
                   WHERE ccesta = regs.ccesta
                     AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                            FROM tabvalces
                                           WHERE ccesta = regs.ccesta
                                             AND TRUNC(fvalor) <= TRUNC(pfefecto));
            END;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_valor_provisión_shw', NULL,
                           'parametros: psseguro =' || psseguro || 'pfefecto =' || pfefecto,
                           SQLERRM);
               RETURN(NULL);
         END;

         v_provision := v_provision +(nparacts * iuniacts);
      END LOOP;

      v_provision := ROUND(v_provision, 2);
      RETURN(v_provision);
   END ff_valor_provision_fecha_shw;

   FUNCTION ff_cfallecimiento(psseguro IN NUMBER, ppfefecto IN NUMBER)
      RETURN NUMBER IS
      duracion       NUMBER;
      primas         NUMBER;
      primascap      NUMBER := 0;
      vprovision     NUMBER := 0;
      num_err        NUMBER;
      vprovincrementado NUMBER;
      v_cfallecimiento NUMBER := 0;
      pfefecto       DATE;
      v_sproduc      NUMBER;
      v_sperson      NUMBER;
      vedad          NUMBER;
   BEGIN
      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

      IF NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
         AND NVL(f_parproductos_v(v_sproduc, 'USA_EDAD_CFALLAC'), 0) = 1 THEN   -- Ibex 35, Ibex 35 Garantizado
         SELECT sperson
           INTO v_sperson
           FROM asegurados
          WHERE sseguro = psseguro
            AND norden = 1;

         vedad := fedadaseg(0, v_sperson, TO_CHAR(f_sysdate, 'YYYYMMDD'), 2);
         vprovision := pac_operativa_ulk.ff_valor_provision(psseguro, ppfefecto);

         IF vedad < 45 THEN
            v_cfallecimiento := vprovision + vprovision * 0.03;
         ELSIF vedad >= 45
               AND vedad <= 55 THEN
            v_cfallecimiento := vprovision + vprovision * 0.02;
         ELSIF vedad > 55 THEN
            v_cfallecimiento := vprovision + vprovision * 0.01;
         END IF;
      ELSE
         pfefecto := TO_DATE(ppfefecto, 'yyyy/mm/dd');

         BEGIN
            -- 1.  Las primas capitalizadas a una tasa de expansión del 2%.
            --SELECT nduraci INTO duracion
            --FROM seguros
            --WHERE sseguro = psseguro;

            -- RSC 08/01/2009 Se cambia la manera de obtener las primas
            -- capitalizadas al 2 %.
            FOR regs IN (SELECT imovimi, fvalmov
                           FROM ctaseguro
                          WHERE sseguro = psseguro
                            AND cmovanu <> 1   -- líneas no anuladas
                            AND cmovimi IN(1, 2, 4)) LOOP
               -- Obtenemos la duración
               SELECT (pfefecto - regs.fvalmov) / 365
                 INTO duracion
                 FROM DUAL;

               primascap := primascap + (1.02 ** duracion) * regs.imovimi;
            END LOOP;
         --primascap := (1.02**duracion)*primas;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN(NULL);
         END;

         --2. El valor de provisión incrementado en 601, 01 euros
         vprovision := pac_operativa_ulk.ff_valor_provision(psseguro, ppfefecto);

         IF vprovision <> -1 THEN
            vprovincrementado := vprovision + pac_operativa_ulk.k_extracapfall;   -- Revisar si este valor de 601.01 debe
         -- estar fijado como constante en alguna parte
         ELSE
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_capital_fallecimiento', NULL,
                        'parametros: psseguro =' || psseguro || 'pfefecto =' || pfefecto,
                        NULL);
            RETURN(NULL);
         END IF;

         -- actualizamos el valor del capital de fallecimiento
         IF primascap > vprovincrementado THEN
            v_cfallecimiento := primascap;
         ELSIF primascap <= vprovincrementado THEN
            v_cfallecimiento := vprovincrementado;
         END IF;

         v_cfallecimiento := ROUND(v_cfallecimiento, 2);
      END IF;

      RETURN(v_cfallecimiento);
   END ff_cfallecimiento;

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
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_gastos_gestion_anual', NULL,
                        'parametros: psseguro =' || psseguro || ' v_provision ='
                        || v_provision,
                        SQLERRM);
            RETURN(108190);   -- Cambiar por gasto de gestion no definido para la póliza
      END;

      BEGIN
         SELECT pgasto, imaximo, iminimo
           INTO p_pgasto, pimaximo, piminimo
           FROM detgastos_ulk
          WHERE ffinvig IS NULL
            AND cgasto = v_gasges;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_gastos_gestion_anual', NULL,
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
      seqgrupo IN NUMBER)
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

      ggesmensual    NUMBER;
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
   BEGIN
      -- RSC 09/12/2008 Tarea 8407
      vfsysdate := f_sysdate;

      -- Si nos llega el producto a NULL lo cogemos de la tabla SEGUROS
      SELECT sproduc, cempres
        INTO v_sproduc, v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);   -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda

      -- RSC 06/11/2008 ------------------
      SELECT d.pgasto
        INTO vpgastoges
        FROM seguros_ulk s, detgastos_ulk d
       WHERE s.sseguro = psseguro
         AND s.cgasges = d.cgasto
         AND d.ffinvig IS NULL;

------------------------------------

      --IF NVL(F_PARPRODUCTOS_V(v_sproduc,'PRODUCTO_MIXTO'),0) <> 1 AND
      --   NVL(F_PARPRODUCTOS_V(v_sproduc,'USA_EDAD_CFALLAC'),0) <> 1 THEN -- Si es Ibex 35 Garantizado
                                                                           -- o Ibex 35 no lo aplicamos

      -- Si > 0 es que se deben aplicar gastos de gestión
      IF vpgastoges > 0 THEN
         ntraza := 1;
         v_provision := pac_operativa_ulk.ff_valor_provision(psseguro,
                                                             TO_NUMBER(TO_CHAR(ppfefecto,
                                                                               'yyyymmdd')));

         IF v_provision IS NULL THEN
            RETURN 151026;
         END IF;

         ntraza := 2;
         num_err := pac_operativa_ulk.f_gastos_gestion_anual(psseguro, v_provision, ggesanual);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         -- cálculo del gasto de gestión mensual
         ggesmensual := ggesanual / 12;

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

         -- Insertamos el movimiento general de Compra por redistribución
         BEGIN
            IF pmodo = 'R' THEN
               ntraza := 1;

               INSERT INTO ctaseguro
                           (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi,
                            imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec)
                    VALUES (psseguro, vfsysdate, xnnumlin, ppfefecto, ppfefecto, 82,
                            ggesmensual, NULL, NULL, seqgrupo, 0, NULL, NULL);

               -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
               IF v_cmultimon = 1 THEN
                  num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro, vfsysdate,
                                                                        xnnumlin, ppfefecto);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END IF;
            -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
            ELSIF pmodo = 'P' THEN
               ntraza := 2;

               INSERT INTO ctaseguro_previo
                           (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi,
                            imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec)
                    VALUES (psseguro, vfsysdate, xnnumlin, ppfefecto, ppfefecto, 82,
                            ggesmensual, NULL, NULL, seqgrupo, 0, NULL, NULL);
            END IF;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_gastos_gestion',
                           ntraza,
                           'parametros: psseguro =' || psseguro || 'ppfefecto =' || ppfefecto
                           || ' pmodo =' || pmodo,
                           SQLERRM);
               RETURN 104879;   -- Registre duplicat a CTASEGURO
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_gastos_gestion',
                           ntraza,
                           'parametros: psseguro =' || psseguro || 'ppfefecto =' || ppfefecto
                           || ' pmodo =' || pmodo,
                           SQLERRM);
               RETURN 102555;   -- Error al insertar a la taula CTASEGURO
         END;

         -- Creamos registro en CTASEGURO_LIBRETA
         BEGIN
            IF pmodo = 'R' THEN
               ntraza := 3;

               INSERT INTO ctaseguro_libreta
                           (sseguro, nnumlin, fcontab, ccapgar, ccapfal, nmovimi, sintbatch,
                            nnumlib)
                    VALUES (psseguro, xnnumlin, vfsysdate, NULL, NULL, NULL, NULL,
                            NULL);
            ELSIF pmodo = 'P' THEN
               ntraza := 4;

               INSERT INTO ctaseguro_libreta_previo
                           (sseguro, nnumlin, fcontab, ccapgar, ccapfal, nmovimi, sintbatch,
                            nnumlib)
                    VALUES (psseguro, xnnumlin, vfsysdate, NULL, NULL, NULL, NULL,
                            NULL);
            END IF;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_gastos_gestion',
                           ntraza,
                           'parametros: psseguro =' || psseguro || 'ppfefecto =' || ppfefecto
                           || ' pmodo =' || pmodo,
                           SQLERRM);
               RETURN 104879;   -- Registre duplicat a CTASEGURO
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_gastos_gestion',
                           ntraza,
                           'parametros: psseguro =' || psseguro || 'ppfefecto =' || ppfefecto
                           || ' pmodo =' || pmodo,
                           SQLERRM);
               RETURN 102555;   -- Error al insertar a la taula CTASEGURO
         END;

         xnnumlin := xnnumlin + 1;

         FOR regs IN cur_cesta LOOP
            --Valor participación (PRECIO UNIDAD) (si no tiene para el dia coge la mayor anterior) -- PREGUNTAR
            ntraza := 5;

            BEGIN
               /*
               -- RSC 12/11/2007
                 select nvl(iuniact,0) into iuniacts
                 from tabvalces
                 where ccesta = regs.ccesta
                 and trunc(fvalor) = trunc(ppfefecto);
               */
               /*
               select nvl(iuniact,0) into iuniacts
               from tabvalces
               where ccesta = regs.ccesta
                 and trunc(fvalor) = (select max(fvalor)
                                      from tabvalces
                                      where ccesta = regs.ccesta
                                        and trunc(fvalor) <= trunc(ppfefecto));
               */

               -- Último valor liquidativo del fondo
               /*
               select nvl(iuniact,0) into iuniacts
               from fondos
               where ccodfon = regs.ccesta;
               */
               -- RSC 18/03/2008 (ultimo valor lo cogemos de tabvalces)
               SELECT NVL(iuniact, 0)
                 INTO iuniacts
                 FROM tabvalces
                WHERE ccesta = regs.ccesta
                  AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                         FROM tabvalces
                                        WHERE ccesta = regs.ccesta);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  -- El valor liquidativo ha de ser el del dia para generar en CTASEGURO
                  -- (al momento del cierre ya disponemos del vliquidativo del día)
                  p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_gastos_gestion',
                              ntraza,
                              'parametros: psseguro =' || psseguro || 'ppfefecto ='
                              || ppfefecto || ' pmodo =' || pmodo,
                              SQLERRM);
                  RETURN 180619;   --No hay valor liquidativo para la fecha
            END;

            -- REVISAR TEMA DE SIGNOS
            --imovimo := ggesmensual*(regs.pdistrec/100);

            --Calcula les distribucions
            vacumpercent := vacumpercent + (ggesmensual * regs.pdistrec) / 100;
            imovimo := ROUND(vacumpercent - vacumrounded, 2);
            vacumrounded := vacumrounded + ROUND(vacumpercent - vacumrounded, 2);

            BEGIN
               IF pmodo = 'R' THEN
                  ntraza := 6;

                  -- nunidad = (imovimo/iuniacts)*-1)
                  INSERT INTO ctaseguro
                              (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi,
                               imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec,
                               cesta, nunidad, cestado)
                       VALUES (psseguro, vfsysdate, xnnumlin, ppfefecto, ppfefecto, 83,
                               imovimo, NULL, NULL, seqgrupo, 0, NULL, NULL,
                               regs.ccesta, NULL, '1');

                  -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  IF v_cmultimon = 1 THEN
                     num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro,
                                                                           vfsysdate,
                                                                           xnnumlin,
                                                                           ppfefecto);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  xnnumlin := xnnumlin + 1;
               --ACTUALIZAR CESTA"
               /*
               UPDATE FONDOS
               SET FONDOS.nparasi = fondos.nparasi + ((imovimo/iuniacts)*-1)
               WHERE FONDOS.ccodfon = regs.ccesta;
               */
               ELSIF pmodo = 'P' THEN
                  ntraza := 7;

                  --((imovimo/iuniacts)*-1)
                  INSERT INTO ctaseguro_previo
                              (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi,
                               imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec,
                               cesta, nunidad, cestado)
                       VALUES (psseguro, vfsysdate, xnnumlin, ppfefecto, ppfefecto, 83,
                               imovimo, NULL, NULL, seqgrupo, 0, NULL, NULL,
                               regs.ccesta, NULL, '1');

                  xnnumlin := xnnumlin + 1;
               END IF;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_gastos_gestion',
                              ntraza,
                              'parametros: psseguro =' || psseguro || 'ppfefecto ='
                              || ppfefecto || ' pmodo =' || pmodo,
                              SQLERRM);
                  RETURN 104879;   -- Registre duplicat a CTASEGURO
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_gastos_gestion',
                              ntraza,
                              'parametros: psseguro =' || psseguro || 'ppfefecto ='
                              || ppfefecto || ' pmodo =' || pmodo,
                              SQLERRM);
                  RETURN 102555;   -- Error al insertar a la taula CTASEGURO
            END;
         END LOOP;
      END IF;

      RETURN(0);
   END f_cta_gastos_gestion;

   FUNCTION f_cta_gastos_gestion_shw(
      psseguro IN NUMBER,
      ppfefecto IN DATE,
      pmodo IN VARCHAR2,
      seqgrupo IN NUMBER)
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

      ggesmensual    NUMBER;
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
   BEGIN
      -- RSC 09/12/2008 Tarea 8407
      vfsysdate := f_sysdate;

      -- Si nos llega el producto a NULL lo cogemos de la tabla SEGUROS
      SELECT sproduc, cempres
        INTO v_sproduc, v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);   -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda

      -- RSC 06/11/2008 ------------------
      SELECT d.pgasto
        INTO vpgastoges
        FROM seguros_ulk s, detgastos_ulk d
       WHERE s.sseguro = psseguro
         AND s.cgasges = d.cgasto
         AND d.ffinvig IS NULL;

------------------------------------

      --IF NVL(F_PARPRODUCTOS_V(v_sproduc,'PRODUCTO_MIXTO'),0) <> 1 AND
      --   NVL(F_PARPRODUCTOS_V(v_sproduc,'USA_EDAD_CFALLAC'),0) <> 1 THEN -- Si es Ibex 35 Garantizado
                                                                           -- o Ibex 35 no lo aplicamos

      -- Si > 0 es que se deben aplicar gastos de gestión
      IF vpgastoges > 0 THEN
         ntraza := 1;
         v_provision :=
            pac_operativa_ulk.ff_valor_provision_shw(psseguro,
                                                     TO_NUMBER(TO_CHAR(ppfefecto, 'yyyymmdd')));

         IF v_provision IS NULL THEN
            RETURN 151026;
         END IF;

         ntraza := 2;
         num_err := pac_operativa_ulk.f_gastos_gestion_anual(psseguro, v_provision, ggesanual);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         -- cálculo del gasto de gestión mensual
         ggesmensual := ggesanual / 12;

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

         -- Insertamos el movimiento general de Compra por redistribución
         BEGIN
            IF pmodo = 'R' THEN
               ntraza := 1;

               INSERT INTO ctaseguro_shadow
                           (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi,
                            imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec)
                    VALUES (psseguro, vfsysdate, xnnumlin, ppfefecto, ppfefecto, 82,
                            ggesmensual, NULL, NULL, seqgrupo, 0, NULL, NULL);

               -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
               IF v_cmultimon = 1 THEN
                  num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro,
                                                                            vfsysdate,
                                                                            xnnumlin,
                                                                            ppfefecto);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END IF;
            -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
            ELSIF pmodo = 'P' THEN
               ntraza := 2;

               INSERT INTO ctaseguro_previo_shw
                           (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi,
                            imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec)
                    VALUES (psseguro, vfsysdate, xnnumlin, ppfefecto, ppfefecto, 82,
                            ggesmensual, NULL, NULL, seqgrupo, 0, NULL, NULL);
            END IF;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_gastos_gestion_shw',
                           ntraza,
                           'parametros: psseguro =' || psseguro || 'ppfefecto =' || ppfefecto
                           || ' pmodo =' || pmodo,
                           SQLERRM);
               RETURN 104879;   -- Registre duplicat a CTASEGURO
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_gastos_gestion_shw',
                           ntraza,
                           'parametros: psseguro =' || psseguro || 'ppfefecto =' || ppfefecto
                           || ' pmodo =' || pmodo,
                           SQLERRM);
               RETURN 102555;   -- Error al insertar a la taula CTASEGURO
         END;

         -- Creamos registro en CTASEGURO_LIBRETA
         BEGIN
            IF pmodo = 'R' THEN
               ntraza := 3;

               INSERT INTO ctaseguro_libreta_shw
                           (sseguro, nnumlin, fcontab, ccapgar, ccapfal, nmovimi, sintbatch,
                            nnumlib)
                    VALUES (psseguro, xnnumlin, vfsysdate, NULL, NULL, NULL, NULL,
                            NULL);
            ELSIF pmodo = 'P' THEN
               ntraza := 4;

               INSERT INTO ctaseguro_libreta_previo_shw
                           (sseguro, nnumlin, fcontab, ccapgar, ccapfal, nmovimi, sintbatch,
                            nnumlib)
                    VALUES (psseguro, xnnumlin, vfsysdate, NULL, NULL, NULL, NULL,
                            NULL);
            END IF;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_gastos_gestion_shw',
                           ntraza,
                           'parametros: psseguro =' || psseguro || 'ppfefecto =' || ppfefecto
                           || ' pmodo =' || pmodo,
                           SQLERRM);
               RETURN 104879;   -- Registre duplicat a CTASEGURO
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_gastos_gestion_shw',
                           ntraza,
                           'parametros: psseguro =' || psseguro || 'ppfefecto =' || ppfefecto
                           || ' pmodo =' || pmodo,
                           SQLERRM);
               RETURN 102555;   -- Error al insertar a la taula CTASEGURO_SHADOW
         END;

         xnnumlin := xnnumlin + 1;

         FOR regs IN cur_cesta LOOP
            --Valor participación (PRECIO UNIDAD) (si no tiene para el dia coge la mayor anterior) -- PREGUNTAR
            ntraza := 5;

            BEGIN
               -- RSC 18/03/2008 (ultimo valor lo cogemos de tabvalces)
               SELECT NVL(iuniactvtashw, 0)
                 INTO iuniacts
                 FROM tabvalces
                WHERE ccesta = regs.ccesta
                  AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                         FROM tabvalces
                                        WHERE ccesta = regs.ccesta);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  -- El valor liquidativo ha de ser el del dia para generar en CTASEGURO
                  -- (al momento del cierre ya disponemos del vliquidativo del día)
                  p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_gastos_gestion_shw',
                              ntraza,
                              'parametros: psseguro =' || psseguro || 'ppfefecto ='
                              || ppfefecto || ' pmodo =' || pmodo,
                              SQLERRM);
                  RETURN 180619;   --No hay valor liquidativo para la fecha
            END;

            --Calcula les distribucions
            vacumpercent := vacumpercent + (ggesmensual * regs.pdistrec) / 100;
            imovimo := ROUND(vacumpercent - vacumrounded, 2);
            vacumrounded := vacumrounded + ROUND(vacumpercent - vacumrounded, 2);

            BEGIN
               IF pmodo = 'R' THEN
                  ntraza := 6;

                  -- nunidad = (imovimo/iuniacts)*-1)
                  INSERT INTO ctaseguro_shadow
                              (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi,
                               imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec,
                               cesta, nunidad, cestado)
                       VALUES (psseguro, vfsysdate, xnnumlin, ppfefecto, ppfefecto, 83,
                               imovimo, NULL, NULL, seqgrupo, 0, NULL, NULL,
                               regs.ccesta, NULL, '1');

                  -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  IF v_cmultimon = 1 THEN
                     num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro,
                                                                               vfsysdate,
                                                                               xnnumlin,
                                                                               ppfefecto);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  xnnumlin := xnnumlin + 1;
               ELSIF pmodo = 'P' THEN
                  ntraza := 7;

                  --((imovimo/iuniacts)*-1)
                  INSERT INTO ctaseguro_previo_shw
                              (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi,
                               imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec,
                               cesta, nunidad, cestado)
                       VALUES (psseguro, vfsysdate, xnnumlin, ppfefecto, ppfefecto, 83,
                               imovimo, NULL, NULL, seqgrupo, 0, NULL, NULL,
                               regs.ccesta, NULL, '1');

                  xnnumlin := xnnumlin + 1;
               END IF;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_gastos_gestion_shw',
                              ntraza,
                              'parametros: psseguro =' || psseguro || 'ppfefecto ='
                              || ppfefecto || ' pmodo =' || pmodo,
                              SQLERRM);
                  RETURN 104879;   -- Registre duplicat a CTASEGURO
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_gastos_gestion_shw',
                              ntraza,
                              'parametros: psseguro =' || psseguro || 'ppfefecto ='
                              || ppfefecto || ' pmodo =' || pmodo,
                              SQLERRM);
                  RETURN 102555;   -- Error al insertar a la taula CTASEGURO
            END;
         END LOOP;
      END IF;

      RETURN(0);
   END f_cta_gastos_gestion_shw;

   FUNCTION ff_tarcobertura(psseguro IN NUMBER, ppfefecto IN NUMBER)
      RETURN NUMBER IS
      v_provision    NUMBER;
      v_cfallac      NUMBER;
   BEGIN
      v_provision := pac_operativa_ulk.ff_valor_provision(psseguro, ppfefecto);

      IF v_provision IS NOT NULL THEN
         v_cfallac := pac_operativa_ulk.ff_cfallecimiento(psseguro, ppfefecto);

         IF v_cfallac IS NOT NULL THEN
            RETURN(v_cfallac - v_provision);
         END IF;
      END IF;

      RETURN NULL;
   END ff_tarcobertura;

   FUNCTION f_cta_gastos_scobertura(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      psproduc IN NUMBER,
      pmodo IN VARCHAR2,
      seqgrupo IN NUMBER)
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
   BEGIN
      vfsysdate := f_sysdate;

      -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
      SELECT sproduc, cempres
        INTO v_sproduc, v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);

      -- Si nos llega el producto a NULL lo cogemos de la tabla SEGUROS
      IF psproduc IS NOT NULL THEN
         v_sproduc := psproduc;
      END IF;

      -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
      IF NVL(f_parproductos_v(v_sproduc, 'PRODUCTO_MIXTO'), 0) <> 1
         AND NVL(f_parproductos_v(v_sproduc, 'USA_EDAD_CFALLAC'), 0) <> 1 THEN   -- Si es Ibex 35 Garantizado o
                                                                                 --       Ibex 35 no lo aplicamos
         SELECT COUNT(*)
           INTO vcontaseg
           FROM asegurados
          WHERE sseguro = psseguro;

         IF vcontaseg > 1 THEN   -- dos asegurados
            -- Cálculo del TAR para asegurado 1 y asegurado 2
            num_err := pac_calculo_formulas.calc_formul(TRUNC(pfefecto), v_sproduc, NULL, 48,
                                                        1, psseguro, 216, capgar, NULL, NULL,
                                                        2, TRUNC(pfefecto), pmodo);

            IF num_err = 0 THEN
               resultado := resultado +(capgar / 12);   -- te calcula por prima anual --> dividir entre 12 para este cierre
               num_err := pac_calculo_formulas.calc_formul(TRUNC(pfefecto), v_sproduc, NULL,
                                                           48, 1, psseguro, 218, capgar2,
                                                           NULL, NULL, 2, TRUNC(pfefecto),
                                                           pmodo);

               IF num_err = 0 THEN
                  resultado := resultado +(capgar2 / 12);   -- te calcula por prima anual --> dividir entre 12 para este cierre
               END IF;
            END IF;
         ELSE   -- si la póliza es de un solo asegurado
            num_err := pac_calculo_formulas.calc_formul(TRUNC(pfefecto), v_sproduc, NULL, 48,
                                                        1, psseguro, 218, capgar2, NULL, NULL,
                                                        2, TRUNC(pfefecto), pmodo);

            IF num_err = 0 THEN
               resultado := resultado +(capgar2 / 12);   -- te calcula por prima anual --> dividir entre 12 para este cierre
            END IF;
         END IF;

         -- obtenemos el numero de linia siguiente
         BEGIN
            IF pmodo = 'R' THEN
               SELECT NVL(MAX(nnumlin) + 1, 1)
                 INTO xnnumlin
                 FROM ctaseguro
                WHERE sseguro = psseguro;
            ELSIF pmodo = 'P' THEN
               SELECT NVL(MAX(nnumlin) + 1, 1)
                 INTO xnnumlin
                 FROM ctaseguro_previo
                WHERE sseguro = psseguro;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 104882;   -- Error al llegir de CTASEGURO
         END;

         -- Insertamos el movimiento general de Compra por redistribución
         BEGIN
            IF pmodo = 'R' THEN
               ntraza := 1;

               INSERT INTO ctaseguro
                           (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                            imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec)
                    VALUES (psseguro, vfsysdate, xnnumlin, pfefecto, pfefecto, 21, resultado,
                            NULL, NULL, seqgrupo, 0, NULL, NULL);

               -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
               IF v_cmultimon = 1 THEN
                  num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro, vfsysdate,
                                                                        xnnumlin, pfefecto);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END IF;
            -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
            ELSIF pmodo = 'P' THEN
               ntraza := 2;

               INSERT INTO ctaseguro_previo
                           (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                            imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec)
                    VALUES (psseguro, vfsysdate, xnnumlin, pfefecto, pfefecto, 21, resultado,
                            NULL, NULL, seqgrupo, 0, NULL, NULL);
            END IF;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_gastos_scobertura',
                           ntraza,
                           'parametros: psseguro =' || psseguro || ' pfefecto =' || pfefecto
                           || ' psproduc =' || psproduc || ' pmodo =' || pmodo,
                           SQLERRM);
               RETURN 104879;   -- Registre duplicat a CTASEGURO
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_gastos_scobertura',
                           ntraza,
                           'parametros: psseguro =' || psseguro || ' pfefecto =' || pfefecto
                           || ' psproduc =' || psproduc || ' pmodo =' || pmodo,
                           SQLERRM);
               RETURN 102555;   -- Error al insertar a la taula CTASEGURO
         END;

         -- Creamos registro en CTASEGURO_LIBRETA
         BEGIN
            IF pmodo = 'R' THEN
               ntraza := 3;

               INSERT INTO ctaseguro_libreta
                           (sseguro, nnumlin, fcontab, ccapgar, ccapfal, nmovimi, sintbatch,
                            nnumlib)
                    VALUES (psseguro, xnnumlin, vfsysdate, NULL, NULL, NULL, NULL,
                            NULL);
            ELSIF pmodo = 'P' THEN
               ntraza := 4;

               INSERT INTO ctaseguro_libreta_previo
                           (sseguro, nnumlin, fcontab, ccapgar, ccapfal, nmovimi, sintbatch,
                            nnumlib)
                    VALUES (psseguro, xnnumlin, vfsysdate, NULL, NULL, NULL, NULL,
                            NULL);
            END IF;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_gastos_scobertura',
                           ntraza,
                           'parametros: psseguro =' || psseguro || ' pfefecto =' || pfefecto
                           || ' psproduc =' || psproduc || ' pmodo =' || pmodo,
                           SQLERRM);
               RETURN 104879;   -- Registre duplicat a CTASEGURO
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_gastos_scobertura',
                           ntraza,
                           'parametros: psseguro =' || psseguro || ' pfefecto =' || pfefecto
                           || ' psproduc =' || psproduc || ' pmodo =' || pmodo,
                           SQLERRM);
               RETURN 102555;   -- Error al insertar a la taula CTASEGURO
         END;

         xnnumlin := xnnumlin + 1;

         FOR regs IN cur_cesta LOOP
            --Valor participación de la cesta
            ntraza := 5;

            BEGIN
               -- Último valor liquidativo del fondo
               /*
               select nvl(iuniact,0) into iuniacts
               from fondos
               where ccodfon = regs.ccesta;
               */
               SELECT NVL(iuniact, 0)
                 INTO iuniacts
                 FROM tabvalces
                WHERE ccesta = regs.ccesta
                  AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                         FROM tabvalces
                                        WHERE ccesta = regs.ccesta);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_gastos_scobertura',
                              ntraza,
                              'parametros: psseguro =' || psseguro || ' pfefecto ='
                              || pfefecto || ' psproduc =' || psproduc || ' pmodo =' || pmodo,
                              SQLERRM);
                  RETURN 180619;   --No hay valor liquidativo para la fecha
            END;

            -- REVISAR TEMA DE SIGNOS
            --imovimo := resultado*(regs.pdistrec/100);
            -- RSC 28/01/2008
            vacumpercent := vacumpercent + (resultado * regs.pdistrec) / 100;
            imovimo := ROUND(vacumpercent - vacumrounded, 2);
            vacumrounded := vacumrounded + ROUND(vacumpercent - vacumrounded, 2);

            BEGIN
               -- cmovimi 84 = Gasto Prima Riesgo = Gasto de Seguro de Cobertura
               IF pmodo = 'R' THEN
                  ntraza := 6;

                  --((imovimo/iuniacts)*-1)
                  INSERT INTO ctaseguro
                              (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi,
                               imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec,
                               cesta, nunidad, cestado)
                       VALUES (psseguro, vfsysdate, xnnumlin, pfefecto, pfefecto, 84,
                               imovimo, NULL, NULL, seqgrupo, 0, NULL, NULL,
                               regs.ccesta, NULL, '1');

                  -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  IF v_cmultimon = 1 THEN
                     num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro,
                                                                           vfsysdate,
                                                                           xnnumlin, pfefecto);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  xnnumlin := xnnumlin + 1;
               --ACTUALIZAR CESTA"
               /*
               UPDATE FONDOS
               SET FONDOS.nparasi = fondos.nparasi + ((imovimo/iuniacts)*-1)
               WHERE FONDOS.ccodfon = regs.ccesta;
               */
               ELSIF pmodo = 'P' THEN
                  ntraza := 7;

                  -- ((imovimo/iuniacts)*-1)
                  INSERT INTO ctaseguro_previo
                              (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi,
                               imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec,
                               cesta, nunidad, cestado)
                       VALUES (psseguro, vfsysdate, xnnumlin, pfefecto, pfefecto, 84,
                               imovimo, NULL, NULL, seqgrupo, 0, NULL, NULL,
                               regs.ccesta, NULL, '1');

                  xnnumlin := xnnumlin + 1;
               END IF;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_gastos_scobertura',
                              ntraza,
                              'parametros: psseguro =' || psseguro || ' pfefecto ='
                              || pfefecto || ' psproduc =' || psproduc || ' pmodo =' || pmodo,
                              SQLERRM);
                  RETURN 104879;   -- Registre duplicat a CTASEGURO
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_gastos_scobertura',
                              ntraza,
                              'parametros: psseguro =' || psseguro || ' pfefecto ='
                              || pfefecto || ' psproduc =' || psproduc || ' pmodo =' || pmodo,
                              SQLERRM);
                  RETURN 102555;   -- Error al insertar a la taula CTASEGURO
            END;
         END LOOP;
      END IF;

      RETURN(0);
   END f_cta_gastos_scobertura;

   FUNCTION f_cta_gastos_scobertura_shw(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      psproduc IN NUMBER,
      pmodo IN VARCHAR2,
      seqgrupo IN NUMBER)
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
   BEGIN
      vfsysdate := f_sysdate;

      -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
      SELECT sproduc, cempres
        INTO v_sproduc, v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);

      -- Si nos llega el producto a NULL lo cogemos de la tabla SEGUROS
      IF psproduc IS NOT NULL THEN
         v_sproduc := psproduc;
      END IF;

      -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
      IF NVL(f_parproductos_v(v_sproduc, 'PRODUCTO_MIXTO'), 0) <> 1
         AND NVL(f_parproductos_v(v_sproduc, 'USA_EDAD_CFALLAC'), 0) <> 1 THEN   -- Si es Ibex 35 Garantizado o
                                                                                 --       Ibex 35 no lo aplicamos
         SELECT COUNT(*)
           INTO vcontaseg
           FROM asegurados
          WHERE sseguro = psseguro;

         IF vcontaseg > 1 THEN   -- dos asegurados
            -- Cálculo del TAR para asegurado 1 y asegurado 2
            num_err := pac_calculo_formulas.calc_formul(TRUNC(pfefecto), v_sproduc, NULL, 48,
                                                        1, psseguro, 216, capgar, NULL, NULL,
                                                        2, TRUNC(pfefecto), pmodo);

            IF num_err = 0 THEN
               resultado := resultado +(capgar / 12);   -- te calcula por prima anual --> dividir entre 12 para este cierre
               num_err := pac_calculo_formulas.calc_formul(TRUNC(pfefecto), v_sproduc, NULL,
                                                           48, 1, psseguro, 218, capgar2,
                                                           NULL, NULL, 2, TRUNC(pfefecto),
                                                           pmodo);

               IF num_err = 0 THEN
                  resultado := resultado +(capgar2 / 12);   -- te calcula por prima anual --> dividir entre 12 para este cierre
               END IF;
            END IF;
         ELSE   -- si la póliza es de un solo asegurado
            num_err := pac_calculo_formulas.calc_formul(TRUNC(pfefecto), v_sproduc, NULL, 48,
                                                        1, psseguro, 218, capgar2, NULL, NULL,
                                                        2, TRUNC(pfefecto), pmodo);

            IF num_err = 0 THEN
               resultado := resultado +(capgar2 / 12);   -- te calcula por prima anual --> dividir entre 12 para este cierre
            END IF;
         END IF;

         -- obtenemos el numero de linia siguiente
         BEGIN
            IF pmodo = 'R' THEN
               SELECT NVL(MAX(nnumlin) + 1, 1)
                 INTO xnnumlin
                 FROM ctaseguro_shadow
                WHERE sseguro = psseguro;
            ELSIF pmodo = 'P' THEN
               SELECT NVL(MAX(nnumlin) + 1, 1)
                 INTO xnnumlin
                 FROM ctaseguro_previo_shw
                WHERE sseguro = psseguro;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 104882;   -- Error al llegir de CTASEGURO
         END;

         -- Insertamos el movimiento general de Compra por redistribución
         BEGIN
            IF pmodo = 'R' THEN
               ntraza := 1;

               INSERT INTO ctaseguro_shadow
                           (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                            imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec)
                    VALUES (psseguro, vfsysdate, xnnumlin, pfefecto, pfefecto, 21, resultado,
                            NULL, NULL, seqgrupo, 0, NULL, NULL);

               -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
               IF v_cmultimon = 1 THEN
                  num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro,
                                                                            vfsysdate,
                                                                            xnnumlin,
                                                                            pfefecto);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END IF;
            -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
            ELSIF pmodo = 'P' THEN
               ntraza := 2;

               INSERT INTO ctaseguro_previo_shw
                           (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                            imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec)
                    VALUES (psseguro, vfsysdate, xnnumlin, pfefecto, pfefecto, 21, resultado,
                            NULL, NULL, seqgrupo, 0, NULL, NULL);
            END IF;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_gastos_scobertura_shw',
                           ntraza,
                           'parametros: psseguro =' || psseguro || ' pfefecto =' || pfefecto
                           || ' psproduc =' || psproduc || ' pmodo =' || pmodo,
                           SQLERRM);
               RETURN 104879;   -- Registre duplicat a CTASEGURO
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_gastos_scobertura_shw',
                           ntraza,
                           'parametros: psseguro =' || psseguro || ' pfefecto =' || pfefecto
                           || ' psproduc =' || psproduc || ' pmodo =' || pmodo,
                           SQLERRM);
               RETURN 102555;   -- Error al insertar a la taula CTASEGURO
         END;

         -- Creamos registro en CTASEGURO_LIBRETA
         BEGIN
            IF pmodo = 'R' THEN
               ntraza := 3;

               INSERT INTO ctaseguro_libreta_shw
                           (sseguro, nnumlin, fcontab, ccapgar, ccapfal, nmovimi, sintbatch,
                            nnumlib)
                    VALUES (psseguro, xnnumlin, vfsysdate, NULL, NULL, NULL, NULL,
                            NULL);
            ELSIF pmodo = 'P' THEN
               ntraza := 4;

               INSERT INTO ctaseguro_libreta_previo_shw
                           (sseguro, nnumlin, fcontab, ccapgar, ccapfal, nmovimi, sintbatch,
                            nnumlib)
                    VALUES (psseguro, xnnumlin, vfsysdate, NULL, NULL, NULL, NULL,
                            NULL);
            END IF;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_gastos_scobertura_shw',
                           ntraza,
                           'parametros: psseguro =' || psseguro || ' pfefecto =' || pfefecto
                           || ' psproduc =' || psproduc || ' pmodo =' || pmodo,
                           SQLERRM);
               RETURN 104879;   -- Registre duplicat a CTASEGURO
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_gastos_scobertura_shw',
                           ntraza,
                           'parametros: psseguro =' || psseguro || ' pfefecto =' || pfefecto
                           || ' psproduc =' || psproduc || ' pmodo =' || pmodo,
                           SQLERRM);
               RETURN 102555;   -- Error al insertar a la taula CTASEGURO
         END;

         xnnumlin := xnnumlin + 1;

         FOR regs IN cur_cesta LOOP
            --Valor participación de la cesta
            ntraza := 5;

            BEGIN
               -- Último valor liquidativo del fondo
               SELECT NVL(iuniactvtashw, 0)
                 INTO iuniacts
                 FROM tabvalces
                WHERE ccesta = regs.ccesta
                  AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                         FROM tabvalces
                                        WHERE ccesta = regs.ccesta);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  p_tab_error(f_sysdate, f_user,
                              'PAC_OPERATIVA_ULK.f_cta_gastos_scobertura_shw', ntraza,
                              'parametros: psseguro =' || psseguro || ' pfefecto ='
                              || pfefecto || ' psproduc =' || psproduc || ' pmodo =' || pmodo,
                              SQLERRM);
                  RETURN 180619;   --No hay valor liquidativo para la fecha
            END;

            -- REVISAR TEMA DE SIGNOS
            --imovimo := resultado*(regs.pdistrec/100);
            -- RSC 28/01/2008
            vacumpercent := vacumpercent + (resultado * regs.pdistrec) / 100;
            imovimo := ROUND(vacumpercent - vacumrounded, 2);
            vacumrounded := vacumrounded + ROUND(vacumpercent - vacumrounded, 2);

            BEGIN
               -- cmovimi 84 = Gasto Prima Riesgo = Gasto de Seguro de Cobertura
               IF pmodo = 'R' THEN
                  ntraza := 6;

                  --((imovimo/iuniacts)*-1)
                  INSERT INTO ctaseguro_shadow
                              (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi,
                               imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec,
                               cesta, nunidad, cestado)
                       VALUES (psseguro, vfsysdate, xnnumlin, pfefecto, pfefecto, 84,
                               imovimo, NULL, NULL, seqgrupo, 0, NULL, NULL,
                               regs.ccesta, NULL, '1');

                  -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  IF v_cmultimon = 1 THEN
                     num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro,
                                                                               vfsysdate,
                                                                               xnnumlin,
                                                                               pfefecto);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  xnnumlin := xnnumlin + 1;
               ELSIF pmodo = 'P' THEN
                  ntraza := 7;

                  -- ((imovimo/iuniacts)*-1)
                  INSERT INTO ctaseguro_previo_shw
                              (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi,
                               imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec,
                               cesta, nunidad, cestado)
                       VALUES (psseguro, vfsysdate, xnnumlin, pfefecto, pfefecto, 84,
                               imovimo, NULL, NULL, seqgrupo, 0, NULL, NULL,
                               regs.ccesta, NULL, '1');

                  xnnumlin := xnnumlin + 1;
               END IF;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  p_tab_error(f_sysdate, f_user,
                              'PAC_OPERATIVA_ULK.f_cta_gastos_scobertura_shw', ntraza,
                              'parametros: psseguro =' || psseguro || ' pfefecto ='
                              || pfefecto || ' psproduc =' || psproduc || ' pmodo =' || pmodo,
                              SQLERRM);
                  RETURN 104879;   -- Registre duplicat a CTASEGURO
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user,
                              'PAC_OPERATIVA_ULK.f_cta_gastos_scobertura_shw', ntraza,
                              'parametros: psseguro =' || psseguro || ' pfefecto ='
                              || pfefecto || ' psproduc =' || psproduc || ' pmodo =' || pmodo,
                              SQLERRM);
                  RETURN 102555;   -- Error al insertar a la taula CTASEGURO
            END;
         END LOOP;
      END IF;

      RETURN(0);
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
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_gastos_redistribucion_anual',
                        NULL,
                        'parametros: psseguro =' || psseguro || ' v_provision ='
                        || v_provision,
                        SQLERRM);
            RETURN(108190);   -- Cambiar por gasto de gestion no definido para la póliza
      END;

      BEGIN
         SELECT pgasto, imaximo, iminimo
           INTO p_pgasto, pimaximo, piminimo
           FROM detgastos_ulk
          WHERE ffinvig IS NULL
            AND cgasto = v_gasred;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_gastos_redistribucion_anual',
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
     Esta función esta obsoleta. Diria que no se llama ni se llamará
     en ninguna parte. (ya que los gastos por redistribución se
     aplican en el momento de la redistribución (movimientos 80, 81)).
   **********************************************************************/
   FUNCTION f_cta_gastos_redistribucion(
      psseguro IN NUMBER,
      fefecto IN DATE,
      v_provision IN NUMBER,
      gredanual IN NUMBER)
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

      gredmensual    NUMBER;
      nnumlin        NUMBER;
      iuniacts       NUMBER;
      xnnumlin       NUMBER;
      imovimo        NUMBER;
      -- RSC 28/01/2008
      vacumpercent   NUMBER := 0;
      vacumrounded   NUMBER := 0;
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      num_err        axis_literales.slitera%TYPE;
   BEGIN
      -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
      SELECT cempres
        INTO v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);
      -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
      gredmensual := gredanual / 12;

      -- obtenemos el numero de linia siguiente
      SELECT NVL(MAX(nnumlin) + 1, 1)
        INTO xnnumlin
        FROM ctaseguro
       WHERE sseguro = psseguro;

      FOR regs IN cur_cesta LOOP
         --Valor participación (PRECIO UNIDAD) (si no tiene para el dia coge la mayor anterior) -- PREGUNTAR
         BEGIN
            SELECT NVL(iuniact, 0)
              INTO iuniacts
              FROM tabvalces
             WHERE ccesta = regs.ccesta
               AND TRUNC(fvalor) = TRUNC(fefecto);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               -- El valor liquidativo ha de ser el del dia para generar en CTASEGURO
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_gastos_redistribucion',
                           NULL,
                           'parametros: psseguro =' || psseguro || 'fefecto =' || fefecto
                           || ' v_provision =' || v_provision || ' gredanual =' || gredanual,
                           SQLERRM);
         /*
         select nvl(iuniact,0) into iuniacts
         from tabvalces
         where ccesta = regs.ccesta
           and trunc(fvalor) = (select max(fvalor)
                                from tabvalces
                                where ccesta = regs.ccesta
                                  and trunc(fvalor) <= trunc(fefecto));
         */
         END;

         -- REVISAR TEMA DE SIGNOS
         BEGIN
            --imovimo := round(gredmensual*(regs.pdistrec/100),2);
            -- RSC 28/01/2008
            vacumpercent := vacumpercent + (gredmensual * regs.pdistrec) / 100;
            imovimo := ROUND(vacumpercent - vacumrounded, 2);
            vacumrounded := vacumrounded + ROUND(vacumpercent - vacumrounded, 2);

            -- de momento no calculamos las unidades a descontar ((ggesmensual*regs.pdistrec)/iuniacts)
            -- Será el proceso de asignar que se encargue de realizarlo ( o bien la función f_movcta_ulk
            -- sera la encargada de pasar estos importes negativos a venta de participaciones (cmovimi = 5)
            -- con la conseqüente descuento de participaciones en el momento de asignar).
            INSERT INTO ctaseguro
                        (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                         imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec, cesta, cestado)
                 VALUES (psseguro, fefecto, xnnumlin, fefecto, fefecto, 22, imovimo,
                         NULL, NULL, 0, 0, NULL, NULL, regs.ccesta, '1');

            -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
            IF v_cmultimon = 1 THEN
               num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro, fefecto,
                                                                     xnnumlin, fefecto);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;

            -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
            xnnumlin := xnnumlin + 1;
--------------------------------------------------------------------------------
-- DE MOMENTO VAMOS A DEJARLO ASI, PERO ESTO VA A CANVIAR
--------------------------------------------------------------------------------

         -- Version : Descontando participaciones en el momento de la llamada (contando con que el
            -- valor de participacion este informado para esta fecha, si no malament)
            /*
            INSERT INTO CTASEGURO
                (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
         imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec,cesta,nunidad, cestado, fasign)
         VALUES
             (psseguro, fefecto, xnnumlin, fefecto, fefecto,
             22, imovimo, null, null, 0, 0, null, null,regs.ccesta,imovimo/iuniacts,'2',f_sysdate);
                xnnumlin := xnnumlin + 1;

            --ACTUALIZAR CESTA"
            UPDATE FONDOS
            SET FONDOS.nparasi = fondos.nparasi + (imovimo/iuniacts)
            WHERE FONDOS.ccodfon = regs.ccesta;
            */
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_gastos_redistribucion',
                           NULL,
                           'parametros: psseguro =' || psseguro || 'fefecto =' || fefecto
                           || ' v_provision =' || v_provision || ' gredanual =' || gredanual,
                           SQLERRM);
               RETURN 104879;   -- Registre duplicat a CTASEGURO
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_gastos_redistribucion',
                           NULL,
                           'parametros: psseguro =' || psseguro || 'fefecto =' || fefecto
                           || ' v_provision =' || v_provision || ' gredanual =' || gredanual,
                           SQLERRM);
               RETURN 102555;   -- Error al insertar a la taula CTASEGURO
         END;
      END LOOP;

      RETURN(0);
   END f_cta_gastos_redistribucion;

   FUNCTION f_cta_gastos_redist_shw(
      psseguro IN NUMBER,
      fefecto IN DATE,
      v_provision IN NUMBER,
      gredanual IN NUMBER)
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

      gredmensual    NUMBER;
      nnumlin        NUMBER;
      iuniacts       NUMBER;
      xnnumlin       NUMBER;
      imovimo        NUMBER;
      -- RSC 28/01/2008
      vacumpercent   NUMBER := 0;
      vacumrounded   NUMBER := 0;
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      num_err        axis_literales.slitera%TYPE;
   BEGIN
      -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
      SELECT cempres
        INTO v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);
      -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
      gredmensual := gredanual / 12;

      -- obtenemos el numero de linia siguiente
      SELECT NVL(MAX(nnumlin) + 1, 1)
        INTO xnnumlin
        FROM ctaseguro_shadow
       WHERE sseguro = psseguro;

      FOR regs IN cur_cesta LOOP
         --Valor participación (PRECIO UNIDAD) (si no tiene para el dia coge la mayor anterior) -- PREGUNTAR
         BEGIN
            SELECT NVL(iuniactvtashw, 0)
              INTO iuniacts
              FROM tabvalces
             WHERE ccesta = regs.ccesta
               AND TRUNC(fvalor) = TRUNC(fefecto);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               -- El valor liquidativo ha de ser el del dia para generar en CTASEGURO
               p_tab_error(f_sysdate, f_user,
                           'PAC_OPERATIVA_ULK.f_cta_gastos_redistribucion_shw', NULL,
                           'parametros: psseguro =' || psseguro || 'fefecto =' || fefecto
                           || ' v_provision =' || v_provision || ' gredanual =' || gredanual,
                           SQLERRM);
         END;

         -- REVISAR TEMA DE SIGNOS
         BEGIN
            --imovimo := round(gredmensual*(regs.pdistrec/100),2);
            -- RSC 28/01/2008
            vacumpercent := vacumpercent + (gredmensual * regs.pdistrec) / 100;
            imovimo := ROUND(vacumpercent - vacumrounded, 2);
            vacumrounded := vacumrounded + ROUND(vacumpercent - vacumrounded, 2);

            -- de momento no calculamos las unidades a descontar ((ggesmensual*regs.pdistrec)/iuniacts)
            -- Será el proceso de asignar que se encargue de realizarlo ( o bien la función f_movcta_ulk
            -- sera la encargada de pasar estos importes negativos a venta de participaciones (cmovimi = 5)
            -- con la conseqüente descuento de participaciones en el momento de asignar).
            INSERT INTO ctaseguro_shadow
                        (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                         imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec, cesta, cestado)
                 VALUES (psseguro, fefecto, xnnumlin, fefecto, fefecto, 22, imovimo,
                         NULL, NULL, 0, 0, NULL, NULL, regs.ccesta, '1');

            -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
            IF v_cmultimon = 1 THEN
               num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro, fefecto,
                                                                         xnnumlin, fefecto);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;

            -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
            xnnumlin := xnnumlin + 1;
--------------------------------------------------------------------------------
-- DE MOMENTO VAMOS A DEJARLO ASI, PERO ESTO VA A CANVIAR
--------------------------------------------------------------------------------

         -- Version : Descontando participaciones en el momento de la llamada (contando con que el
            -- valor de participacion este informado para esta fecha, si no malament)
            /*
            INSERT INTO CTASEGURO
                (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
         imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec,cesta,nunidad, cestado, fasign)
         VALUES
             (psseguro, fefecto, xnnumlin, fefecto, fefecto,
             22, imovimo, null, null, 0, 0, null, null,regs.ccesta,imovimo/iuniacts,'2',f_sysdate);
                xnnumlin := xnnumlin + 1;

            --ACTUALIZAR CESTA"
            UPDATE FONDOS
            SET FONDOS.nparasi = fondos.nparasi + (imovimo/iuniacts)
            WHERE FONDOS.ccodfon = regs.ccesta;
            */
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               p_tab_error(f_sysdate, f_user,
                           'PAC_OPERATIVA_ULK.f_cta_gastos_redistribucion_shw', NULL,
                           'parametros: psseguro =' || psseguro || 'fefecto =' || fefecto
                           || ' v_provision =' || v_provision || ' gredanual =' || gredanual,
                           SQLERRM);
               RETURN 104879;   -- Registre duplicat a CTASEGURO
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user,
                           'PAC_OPERATIVA_ULK.f_cta_gastos_redistribucion_shw', NULL,
                           'parametros: psseguro =' || psseguro || 'fefecto =' || fefecto
                           || ' v_provision =' || v_provision || ' gredanual =' || gredanual,
                           SQLERRM);
               RETURN 102555;   -- Error al insertar a la taula CTASEGURO
         END;
      END LOOP;

      RETURN(0);
   END f_cta_gastos_redist_shw;

   FUNCTION f_cta_saldo_fondos(
      psseguro IN NUMBER,
      fdesde IN DATE,
      total_cestas IN OUT NUMBER,
      tcestasu IN OUT NUMBER,
      v_det_modinv IN OUT tt_det_modinv)
      RETURN NUMBER IS
      -- Revisar los movimientos que no se tienen que contemplar aqui!!!
      CURSOR cur_ctaseguro IS
         SELECT   ROWID, cesta, ffecmov, cmovimi, imovimi, nunidad
             FROM ctaseguro
            WHERE sseguro = psseguro
              AND(ffecmov >= fdesde
                  OR fdesde IS NULL)
              AND cmovimi NOT IN(0, 1, 2, 4, 60, 70, 80)
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
            -- RSC 18/03/2008 -- Ultimo valor liquidativo de cesta realmente
            SELECT NVL(iuniact, 0)
              INTO precio_cesta
              FROM tabvalces
             WHERE ccesta = cesta_ant
               AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                      FROM tabvalces
                                     WHERE ccesta = cesta_ant);

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

      -- ultimo caso
      --PRECIO UNIDAD DE LA CESTA
      /*
      select NVL(iuniact,0) into precio_cesta
      from fondos
      where ccodfon = cesta_ant;
      */
      -- RSC 18/03/2008 -- Ultimo valor liquidativo de cesta realmente
      SELECT NVL(iuniact, 0)
        INTO precio_cesta
        FROM tabvalces
       WHERE ccesta = cesta_ant
         AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                FROM tabvalces
                               WHERE ccesta = cesta_ant);

      -- (saldo_cesta*precio_cesta) = Saldo de la cesta en euros
      total_cestas := total_cestas +(saldo_cesta * precio_cesta);
      tcestasu := tcestasu + saldo_cesta;
      -- Guaramos en un table las diferentes cesta y saldos de cesta
      v_det_modinv(NVL(v_det_modinv.LAST, 0) + 1) :=
                              f_det_modinv(cesta_ant, saldo_cesta,
                                           (saldo_cesta * precio_cesta));
      RETURN(0);
   END f_cta_saldo_fondos;

   FUNCTION f_cta_saldo_fondos_shw(
      psseguro IN NUMBER,
      fdesde IN DATE,
      total_cestas IN OUT NUMBER,
      tcestasu IN OUT NUMBER,
      v_det_modinv IN OUT tt_det_modinv)
      RETURN NUMBER IS
      -- Revisar los movimientos que no se tienen que contemplar aqui!!!
      CURSOR cur_ctaseguro IS
         SELECT   ROWID, cesta, ffecmov, cmovimi, imovimi, nunidad
             FROM ctaseguro_shadow
            WHERE sseguro = psseguro
              AND(ffecmov >= fdesde
                  OR fdesde IS NULL)
              AND cmovimi NOT IN(0, 1, 2, 4, 60, 70, 80)
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
            -- RSC 18/03/2008 -- Ultimo valor liquidativo de cesta realmente
            SELECT NVL(iuniactvtashw, 0)
              INTO precio_cesta
              FROM tabvalces
             WHERE ccesta = cesta_ant
               AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                      FROM tabvalces
                                     WHERE ccesta = cesta_ant);

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

      -- ultimo caso
      --PRECIO UNIDAD DE LA CESTA
      /*
      select NVL(iuniact,0) into precio_cesta
      from fondos
      where ccodfon = cesta_ant;
      */
      -- RSC 18/03/2008 -- Ultimo valor liquidativo de cesta realmente
      SELECT NVL(iuniactvtashw, 0)
        INTO precio_cesta
        FROM tabvalces
       WHERE ccesta = cesta_ant
         AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                FROM tabvalces
                               WHERE ccesta = cesta_ant);

      -- (saldo_cesta*precio_cesta) = Saldo de la cesta en euros
      total_cestas := total_cestas +(saldo_cesta * precio_cesta);
      tcestasu := tcestasu + saldo_cesta;
      -- Guaramos en un table las diferentes cesta y saldos de cesta
      v_det_modinv(NVL(v_det_modinv.LAST, 0) + 1) :=
                              f_det_modinv(cesta_ant, saldo_cesta,
                                           (saldo_cesta * precio_cesta));
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
              AND cmovimi NOT IN(0, 1, 2, 4, 60, 70, 80)
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
            /*
            select NVL(iuniact,0) into precio_cesta
            from fondos
            where ccodfon = cesta_ant;
            */
            -- RSC 18/03/2008 -- Ultimo valor liquidativo de cesta realmente
            SELECT NVL(iuniact, 0)
              INTO precio_cesta
              FROM tabvalces
             WHERE ccesta = cesta_ant
               AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                      FROM tabvalces
                                     WHERE ccesta = cesta_ant);

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
      /*
      select NVL(iuniact,0) into precio_cesta
      from fondos
      where ccodfon = cesta_ant;
      */
      -- RSC 18/03/2008 -- Ultimo valor liquidativo de cesta realmente
      SELECT NVL(iuniact, 0)
        INTO precio_cesta
        FROM tabvalces
       WHERE ccesta = cesta_ant
         AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                FROM tabvalces
                               WHERE ccesta = cesta_ant);

      -- (saldo_cesta*precio_cesta) = Saldo de la cesta en euros
      total_cestas := total_cestas +(saldo_cesta * precio_cesta);

      IF cesta_ant = pcesta THEN
         tcesta_unidades := tcesta_unidades + saldo_cesta;
         tcesta_importe := tcesta_unidades * precio_cesta;
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
              AND cmovimi NOT IN(0, 1, 2, 4, 60, 70, 80)
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

            -- RSC 18/03/2008 -- Ultimo valor liquidativo de cesta realmente
            SELECT NVL(iuniactvtashw, 0)
              INTO precio_cesta
              FROM tabvalces
             WHERE ccesta = cesta_ant
               AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                      FROM tabvalces
                                     WHERE ccesta = cesta_ant);

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

      -- RSC 18/03/2008 -- Ultimo valor liquidativo de cesta realmente
      SELECT NVL(iuniactvtashw, 0)
        INTO precio_cesta
        FROM tabvalces
       WHERE ccesta = cesta_ant
         AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                FROM tabvalces
                               WHERE ccesta = cesta_ant);

      -- (saldo_cesta*precio_cesta) = Saldo de la cesta en euros
      total_cestas := total_cestas +(saldo_cesta * precio_cesta);

      IF cesta_ant = pcesta THEN
         tcesta_unidades := tcesta_unidades + saldo_cesta;
         tcesta_importe := tcesta_unidades * precio_cesta;
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
      total_cestas IN OUT NUMBER)
      RETURN NUMBER IS
      -- Revisar los movimientos que no se tienen que contemplar aqui!!!
      CURSOR cur_ctaseguro IS
         SELECT   ROWID, cesta, ffecmov, cmovimi, imovimi, nunidad
             FROM ctaseguro
            WHERE sseguro = psseguro
              AND(ffecmov >= fdesde
                  OR fdesde IS NULL)
              AND fvalmov <= NVL(fhasta, f_sysdate)
              AND cmovimi NOT IN(0, 1, 2, 4, 60, 70, 80)
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
                  SELECT NVL(iuniact, 0)
                    INTO precio_cesta
                    FROM tabvalces
                   WHERE ccesta = cesta_ant
                     AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                            FROM tabvalces
                                           WHERE ccesta = cesta_ant
                                             AND TRUNC(fvalor) <= TRUNC(fhasta));
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
               SELECT NVL(iuniact, 0)
                 INTO precio_cesta
                 FROM tabvalces
                WHERE ccesta = cesta_ant
                  AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                         FROM tabvalces
                                        WHERE ccesta = cesta_ant
                                          AND TRUNC(fvalor) <= TRUNC(fhasta));
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
      total_cestas IN OUT NUMBER)
      RETURN NUMBER IS
      -- Revisar los movimientos que no se tienen que contemplar aqui!!!
      CURSOR cur_ctaseguro IS
         SELECT   ROWID, cesta, ffecmov, cmovimi, imovimi, nunidad
             FROM ctaseguro_shadow
            WHERE sseguro = psseguro
              AND(ffecmov >= fdesde
                  OR fdesde IS NULL)
              AND fvalmov <= NVL(fhasta, f_sysdate)
              AND cmovimi NOT IN(0, 1, 2, 4, 60, 70, 80)
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
                  SELECT NVL(iuniactvtashw, 0)
                    INTO precio_cesta
                    FROM tabvalces
                   WHERE ccesta = cesta_ant
                     AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                            FROM tabvalces
                                           WHERE ccesta = cesta_ant
                                             AND TRUNC(fvalor) <= TRUNC(fhasta));
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
               SELECT NVL(iuniactvtashw, 0)
                 INTO precio_cesta
                 FROM tabvalces
                WHERE ccesta = cesta_ant
                  AND TRUNC(fvalor) = (SELECT MAX(fvalor)
                                         FROM tabvalces
                                        WHERE ccesta = cesta_ant
                                          AND TRUNC(fvalor) <= TRUNC(fhasta));
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
      vtieneshw      NUMBER;
   BEGIN
      vtieneshw := pac_ctaseguro.f_tiene_ctashadow(psseguro, NULL);
      -- La fecha de la redistribución es la fecha de efecto (ahora)
      pfefecto := TRUNC(f_sysdate);
      num_err := f_cta_saldo_fondos(psseguro, NULL, total_cestas, total_saldo_u, v_det_modinv);

      IF num_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_saldo_fondos', NULL,
                     'parametros: psseguro = ' || psseguro,
                     f_axis_literales(num_err, f_idiomauser));
         RETURN num_err;
      END IF;

      IF vtieneshw = 1 THEN
         num_err := f_cta_saldo_fondos_shw(psseguro, NULL, total_cestas_shw,
                                           total_saldo_u_shw, v_det_modinv_shw);

         IF num_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_cta_saldo_fondos_shw', NULL,
                        'parametros: psseguro = ' || psseguro,
                        f_axis_literales(num_err, f_idiomauser));
            RETURN num_err;
         END IF;
      END IF;

      -- Reconversión de aportaciones realizadas entre la primera redistribución y la presente
      num_err := f_redistribuye_aportaciones(psseguro, pfefecto);

      IF num_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_aportaciones', NULL,
                     'parametros: psseguro = ' || psseguro,
                     f_axis_literales(num_err, f_idiomauser));
         RETURN num_err;
      END IF;

      IF vtieneshw = 1 THEN
         num_err := f_redist_aportaciones_shw(psseguro, pfefecto);

         IF num_err <> 0 THEN
            p_tab_error(f_sysdate, f_user,
                        'PAC_OPERATIVA_ULK.f_redistribuye_aportaciones_shw', NULL,
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
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_venta', NULL,
                     'parametros: psseguro = ' || psseguro,
                     f_axis_literales(num_err, f_idiomauser));
         RETURN num_err;
      END IF;

      IF vtieneshw = 1 THEN
         num_err := f_redistribuye_venta_shw(psseguro, v_det_modinv_shw, pfefecto,
                                             sivendecompra_shw, seqgrupo);

         IF num_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_venta_shw', NULL,
                        'parametros: psseguro = ' || psseguro,
                        f_axis_literales(num_err, f_idiomauser));
            RETURN num_err;
         END IF;
      END IF;

      -- Entradas de compra por redistribución
      num_err := f_redistribuye_compra(psseguro, pfefecto, sivendecompra, seqgrupo);

      IF num_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_compra', NULL,
                     'parametros: psseguro = ' || psseguro,
                     f_axis_literales(num_err, f_idiomauser));
         RETURN num_err;
      END IF;

      IF vtieneshw = 1 THEN
         num_err := f_redistribuye_compra_shw(psseguro, pfefecto, sivendecompra_shw, seqgrupo);

         IF num_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_compra_shw',
                        NULL, 'parametros: psseguro = ' || psseguro,
                        f_axis_literales(num_err, f_idiomauser));
            RETURN num_err;
         END IF;
      END IF;

      -- Entradas de gastos por redistribución
      num_err := f_redistribuye_gastosredis(psseguro, pfefecto, seqgrupo);

      IF num_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_gastosredis', NULL,
                     'parametros: psseguro = ' || psseguro,
                     f_axis_literales(num_err, f_idiomauser));
         RETURN num_err;
      END IF;

      IF vtieneshw = 1 THEN
         num_err := f_redistribuye_gastosredis_shw(psseguro, pfefecto, seqgrupo);

         IF num_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_gastosredis_shw',
                        NULL, 'parametros: psseguro = ' || psseguro,
                        f_axis_literales(num_err, f_idiomauser));
            RETURN num_err;
         END IF;
      END IF;

      RETURN(0);
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
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      num_err        axis_literales.slitera%TYPE;
   BEGIN
      -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
      SELECT cempres
        INTO v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);

      -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
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
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_compra', NULL,
                        'parametros: psseguro = ' || psseguro, SQLERRM);
            RETURN 104767;   -- Error a l'esborrar a la taula CTASEGURO
      END;

      IF existeventa = 0 THEN   -- Si ya ha habido una redistribución, no es necesario volver a generar estos movimientos
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

         FOR i IN 1 .. pdet_modinv.LAST LOOP
            IF pdet_modinv(i).vucesta <> 0 THEN
               -- vendemos unidades
               sivendecompra := 1;

               IF primer = 0 THEN
                  -- Insertamos el movimiento general de Venta Redistribución (una sola vez)
                  BEGIN
                     INSERT INTO ctaseguro
                                 (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi,
                                  imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies,
                                  smovrec, cesta, nunidad, cestado)
                          VALUES (psseguro, pfefecto, xnnumlin, pfefecto, pfefecto, 60,
                                  0, NULL, NULL, seqgrupo, 0, NULL,
                                  NULL, NULL, NULL, NULL);

                     -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     IF v_cmultimon = 1 THEN
                        num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro,
                                                                              pfefecto,
                                                                              xnnumlin,
                                                                              pfefecto);

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;
                     END IF;
                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        p_tab_error(f_sysdate, f_user,
                                    'PAC_OPERATIVA_ULK.f_redistribuye_venta', NULL,
                                    'parametros: psseguro = ' || psseguro, SQLERRM);
                        RETURN 104879;   -- Registre duplicat a CTASEGURO
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user,
                                    'PAC_OPERATIVA_ULK.f_redistribuye_venta', NULL,
                                    'parametros: psseguro = ' || psseguro, SQLERRM);
                        RETURN 102555;   -- Error al insertar a la taula CTASEGURO
                  END;

                  BEGIN
                     INSERT INTO ctaseguro_libreta
                                 (sseguro, nnumlin, fcontab, ccapgar, ccapfal, nmovimi,
                                  sintbatch, nnumlib)
                          VALUES (psseguro, xnnumlin, pfefecto, NULL, NULL, NULL,
                                  NULL, NULL);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user,
                                    'PAC_OPERATIVA_ULK.f_redistribuye_venta', NULL,
                                    'parametros: psseguro = ' || psseguro, SQLERRM);
                        RETURN 102555;   -- Error al insertar a la taula CTASEGURO
                  END;

                  xnnumlin := xnnumlin + 1;
                  primer := 1;
               END IF;

               BEGIN
                  INSERT INTO ctaseguro
                              (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                               imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec, cesta,
                               nunidad, cestado)
                       VALUES (psseguro, pfefecto, xnnumlin, pfefecto, pfefecto, 61, 0,
                               NULL, NULL, seqgrupo, 0, NULL, NULL, pdet_modinv(i).vccesta,
                               NULL, '1');

                  -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  IF v_cmultimon = 1 THEN
                     num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro, pfefecto,
                                                                           xnnumlin, pfefecto);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  xnnumlin := xnnumlin + 1;
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_venta',
                                 NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
                     RETURN 104879;   -- Registre duplicat a CTASEGURO
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_venta',
                                 NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
                     RETURN 102555;   -- Error al insertar a la taula CTASEGURO
               END;
            END IF;
         END LOOP;
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
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      num_err        axis_literales.slitera%TYPE;
   BEGIN
      -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
      SELECT cempres
        INTO v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);

      -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
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
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_venta_shw', NULL,
                        'parametros: psseguro = ' || psseguro, SQLERRM);
            RETURN 104767;   -- Error a l'esborrar a la taula CTASEGURO
      END;

      IF existeventa = 0 THEN   -- Si ya ha habido una redistribución, no es necesario volver a generar estos movimientos
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

         FOR i IN 1 .. pdet_modinv.LAST LOOP
            IF pdet_modinv(i).vucesta <> 0 THEN
               -- vendemos unidades
               sivendecompra := 1;

               IF primer = 0 THEN
                  -- Insertamos el movimiento general de Venta Redistribución (una sola vez)
                  BEGIN
                     INSERT INTO ctaseguro_shadow
                                 (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi,
                                  imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies,
                                  smovrec, cesta, nunidad, cestado)
                          VALUES (psseguro, pfefecto, xnnumlin, pfefecto, pfefecto, 60,
                                  0, NULL, NULL, seqgrupo, 0, NULL,
                                  NULL, NULL, NULL, NULL);

                     -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                     IF v_cmultimon = 1 THEN
                        num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro,
                                                                                  pfefecto,
                                                                                  xnnumlin,
                                                                                  pfefecto);

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;
                     END IF;
                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        p_tab_error(f_sysdate, f_user,
                                    'PAC_OPERATIVA_ULK.f_redistribuye_venta_shw', NULL,
                                    'parametros: psseguro = ' || psseguro, SQLERRM);
                        RETURN 104879;   -- Registre duplicat a CTASEGURO
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user,
                                    'PAC_OPERATIVA_ULK.f_redistribuye_venta_shw', NULL,
                                    'parametros: psseguro = ' || psseguro, SQLERRM);
                        RETURN 102555;   -- Error al insertar a la taula CTASEGURO
                  END;

                  BEGIN
                     INSERT INTO ctaseguro_libreta_shw
                                 (sseguro, nnumlin, fcontab, ccapgar, ccapfal, nmovimi,
                                  sintbatch, nnumlib)
                          VALUES (psseguro, xnnumlin, pfefecto, NULL, NULL, NULL,
                                  NULL, NULL);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user,
                                    'PAC_OPERATIVA_ULK.f_redistribuye_venta_shw', NULL,
                                    'parametros: psseguro = ' || psseguro, SQLERRM);
                        RETURN 102555;   -- Error al insertar a la taula CTASEGURO
                  END;

                  xnnumlin := xnnumlin + 1;
                  primer := 1;
               END IF;

               BEGIN
                  INSERT INTO ctaseguro_shadow
                              (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                               imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec, cesta,
                               nunidad, cestado)
                       VALUES (psseguro, pfefecto, xnnumlin, pfefecto, pfefecto, 61, 0,
                               NULL, NULL, seqgrupo, 0, NULL, NULL, pdet_modinv(i).vccesta,
                               NULL, '1');

                  -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  IF v_cmultimon = 1 THEN
                     num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro,
                                                                               pfefecto,
                                                                               xnnumlin,
                                                                               pfefecto);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
                  xnnumlin := xnnumlin + 1;
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     p_tab_error(f_sysdate, f_user,
                                 'PAC_OPERATIVA_ULK.f_redistribuye_venta_shw', NULL,
                                 'parametros: psseguro = ' || psseguro, SQLERRM);
                     RETURN 104879;   -- Registre duplicat a CTASEGURO
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user,
                                 'PAC_OPERATIVA_ULK.f_redistribuye_venta_shw', NULL,
                                 'parametros: psseguro = ' || psseguro, SQLERRM);
                     RETURN 102555;   -- Error al insertar a la taula CTASEGURO
               END;
            END IF;
         END LOOP;
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
      seqgrupo IN NUMBER)
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
                              AND ffin IS NULL);

      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      num_err        axis_literales.slitera%TYPE;
   BEGIN
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
            DELETE FROM ctaseguro
                  WHERE sseguro = psseguro
                    AND TRUNC(ffecmov) = TRUNC(pfefecto)
                    AND TRUNC(fvalmov) = TRUNC(pfefecto)
                    AND imovimi = 0
                    AND nunidad IS NULL
                    AND cmovimi IN(70, 71);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_compra', NULL,
                           'parametros: psseguro = ' || psseguro, SQLERRM);
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
                        (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                         imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec)
                 VALUES (psseguro, pfefecto, xnnumlin, pfefecto, pfefecto, 70, 0,
                         NULL, NULL, seqgrupo, 0, NULL, NULL);

            -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
            IF v_cmultimon = 1 THEN
               num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro, pfefecto,
                                                                     xnnumlin, pfefecto);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;
         -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_compra', NULL,
                           'parametros: psseguro = ' || psseguro, SQLERRM);
               RETURN 104879;   -- Registre duplicat a CTASEGURO
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_compra', NULL,
                           'parametros: psseguro = ' || psseguro, SQLERRM);
               RETURN 102555;   -- Error al insertar a la taula CTASEGURO
         END;

         BEGIN
            INSERT INTO ctaseguro_libreta
                        (sseguro, nnumlin, fcontab, ccapgar, ccapfal, nmovimi, sintbatch,
                         nnumlib)
                 VALUES (psseguro, xnnumlin, pfefecto, NULL, NULL, NULL, NULL,
                         NULL);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_compra', NULL,
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
               INSERT INTO ctaseguro
                           (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                            imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec, cesta,
                            nunidad, cestado)
                    VALUES (psseguro, pfefecto, xnnumlin, pfefecto, pfefecto, 71, 0,
                            NULL, NULL, seqgrupo, 0, NULL, NULL, regs.ccesta,
                            NULL, '1');

               -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
               IF v_cmultimon = 1 THEN
                  num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro, pfefecto,
                                                                        xnnumlin, pfefecto);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END IF;

               -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
               xnnumlin := xnnumlin + 1;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_compra',
                              NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
                  RETURN 104879;   -- Registre duplicat a CTASEGURO
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_compra',
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
      seqgrupo IN NUMBER)
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
                              AND ffin IS NULL);

      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      num_err        axis_literales.slitera%TYPE;
   BEGIN
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
            DELETE FROM ctaseguro_shadow
                  WHERE sseguro = psseguro
                    AND TRUNC(ffecmov) = TRUNC(pfefecto)
                    AND TRUNC(fvalmov) = TRUNC(pfefecto)
                    AND imovimi = 0
                    AND nunidad IS NULL
                    AND cmovimi IN(70, 71);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_compra_shw',
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
                        (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                         imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec)
                 VALUES (psseguro, pfefecto, xnnumlin, pfefecto, pfefecto, 70, 0,
                         NULL, NULL, seqgrupo, 0, NULL, NULL);

            -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
            IF v_cmultimon = 1 THEN
               num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro, pfefecto,
                                                                         xnnumlin, pfefecto);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;
         -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_compra_shw',
                           NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
               RETURN 104879;   -- Registre duplicat a CTASEGURO
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_compra_shw',
                           NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
               RETURN 102555;   -- Error al insertar a la taula CTASEGURO
         END;

         BEGIN
            INSERT INTO ctaseguro_libreta_shw
                        (sseguro, nnumlin, fcontab, ccapgar, ccapfal, nmovimi, sintbatch,
                         nnumlib)
                 VALUES (psseguro, xnnumlin, pfefecto, NULL, NULL, NULL, NULL,
                         NULL);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_compra_shw',
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
                           (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                            imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec, cesta,
                            nunidad, cestado)
                    VALUES (psseguro, pfefecto, xnnumlin, pfefecto, pfefecto, 71, 0,
                            NULL, NULL, seqgrupo, 0, NULL, NULL, regs.ccesta,
                            NULL, '1');

               -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
               IF v_cmultimon = 1 THEN
                  num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro,
                                                                            pfefecto,
                                                                            xnnumlin,
                                                                            pfefecto);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END IF;

               -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
               xnnumlin := xnnumlin + 1;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  p_tab_error(f_sysdate, f_user,
                              'PAC_OPERATIVA_ULK.f_redistribuye_compra_shw', NULL,
                              'parametros: psseguro = ' || psseguro, SQLERRM);
                  RETURN 104879;   -- Registre duplicat a CTASEGURO
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user,
                              'PAC_OPERATIVA_ULK.f_redistribuye_compra_shw', NULL,
                              'parametros: psseguro = ' || psseguro, SQLERRM);
                  RETURN 102555;   -- Error al insertar a la taula CTASEGURO
            END;
         END LOOP;
      END IF;

      RETURN 0;
   END f_redistribuye_compra_shw;

   FUNCTION f_redistribuye_gastosredis(psseguro IN NUMBER, pfefecto IN DATE, seqgrupo IN NUMBER)
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
                              AND ffin IS NULL);

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
      -- Borramos redistribuciones antiguas que todavia no se han consolidado
      -- Esto es por si se hacen mas de una redistribución en el dia (al consolidar
      -- hay que consolidar la distribución final)
      BEGIN
         DELETE FROM ctaseguro
               WHERE sseguro = psseguro
                 AND TRUNC(ffecmov) = TRUNC(pfefecto)
                 AND TRUNC(fvalmov) = TRUNC(pfefecto)
                 AND imovimi = 0
                 AND nunidad IS NULL
                 AND cmovimi IN(80, 81);
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_gastosredis',
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

      /*
        v_provision := ff_valor_provision(psseguro, to_number(to_char(pfefecto,'yyyymmdd')));
        num_err := f_gastos_redistribucion_anual(psseguro, v_provision, gredanual);
        IF num_err <> 0 THEN
          RETURN num_err;
        END IF;
      */

      -- Insertamos el movimiento general de Compra por redistribución
      BEGIN
         INSERT INTO ctaseguro
                     (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi, imovim2,
                      nrecibo, ccalint, cmovanu, nsinies, smovrec)
              VALUES (psseguro, pfefecto, xnnumlin, pfefecto, pfefecto, 80, 0, NULL,
                      NULL, seqgrupo, 0, NULL, NULL);

         -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
         IF v_cmultimon = 1 THEN
            num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro, pfefecto,
                                                                  xnnumlin, pfefecto);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;
      -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_gastosredis',
                        NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
            RETURN 104879;   -- Registre duplicat a CTASEGURO
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_gastosredis',
                        NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
            RETURN 102555;   -- Error al insertar a la taula CTASEGURO
      END;

      -- Creamos un registro en
      BEGIN
         INSERT INTO ctaseguro_libreta
                     (sseguro, nnumlin, fcontab, ccapgar, ccapfal, nmovimi, sintbatch, nnumlib)
              VALUES (psseguro, xnnumlin, pfefecto, NULL, NULL, NULL, NULL, NULL);
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_gastosredis',
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
                        (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                         imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec, cesta,
                         nunidad, cestado)
                 VALUES (psseguro, pfefecto, xnnumlin, pfefecto, pfefecto, 81, 0,
                         NULL, NULL, seqgrupo, 0, NULL, NULL, regs.ccesta,
                         NULL, '1');

            -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
            IF v_cmultimon = 1 THEN
               num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro, pfefecto,
                                                                     xnnumlin, pfefecto);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;

            -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
            xnnumlin := xnnumlin + 1;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_gastosredis',
                           NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
               RETURN 104879;   -- Registre duplicat a CTASEGURO
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_gastosredis',
                           NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
               RETURN 102555;   -- Error al insertar a la taula CTASEGURO
         END;
      END LOOP;

      RETURN 0;
   END f_redistribuye_gastosredis;

   FUNCTION f_redistribuye_gastosredis_shw(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      seqgrupo IN NUMBER)
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
                              AND ffin IS NULL);

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
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_gastosredis_shw',
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
                     (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi, imovim2,
                      nrecibo, ccalint, cmovanu, nsinies, smovrec)
              VALUES (psseguro, pfefecto, xnnumlin, pfefecto, pfefecto, 80, 0, NULL,
                      NULL, seqgrupo, 0, NULL, NULL);

         -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
         IF v_cmultimon = 1 THEN
            num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro, pfefecto,
                                                                      xnnumlin, pfefecto);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;
      -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_gastosredis_shw',
                        NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
            RETURN 104879;   -- Registre duplicat a CTASEGURO
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_gastosredis_shw',
                        NULL, 'parametros: psseguro = ' || psseguro, SQLERRM);
            RETURN 102555;   -- Error al insertar a la taula CTASEGURO
      END;

      -- Creamos un registro en
      BEGIN
         INSERT INTO ctaseguro_libreta_shw
                     (sseguro, nnumlin, fcontab, ccapgar, ccapfal, nmovimi, sintbatch, nnumlib)
              VALUES (psseguro, xnnumlin, pfefecto, NULL, NULL, NULL, NULL, NULL);
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.f_redistribuye_gastosredis_shw',
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
                        (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                         imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec, cesta,
                         nunidad, cestado)
                 VALUES (psseguro, pfefecto, xnnumlin, pfefecto, pfefecto, 81, 0,
                         NULL, NULL, seqgrupo, 0, NULL, NULL, regs.ccesta,
                         NULL, '1');

            -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
            IF v_cmultimon = 1 THEN
               num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro, pfefecto,
                                                                         xnnumlin, pfefecto);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;

            -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
            xnnumlin := xnnumlin + 1;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               p_tab_error(f_sysdate, f_user,
                           'PAC_OPERATIVA_ULK.f_redistribuye_gastosredis_shw', NULL,
                           'parametros: psseguro = ' || psseguro, SQLERRM);
               RETURN 104879;   -- Registre duplicat a CTASEGURO
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user,
                           'PAC_OPERATIVA_ULK.f_redistribuye_gastosredis_shw', NULL,
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
                                    'PAC_OPERATIVA_ULK.f_redistribuye_aportaciones', NULL,
                                    'parametros: psseguro = ' || psseguro, SQLERRM);
                        RETURN 104767;   -- Error a l'esborrar a la taula CTASEGURO
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
                              'PAC_OPERATIVA_ULK.f_redistribuye_aportaciones', NULL,
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
                              'PAC_OPERATIVA_ULK.f_redistribuye_aportaciones', NULL,
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
                                 'PAC_OPERATIVA_ULK.f_redistribuye_aportaciones', NULL,
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
                                    'PAC_OPERATIVA_ULK.f_redistribuye_aportaciones_shw', NULL,
                                    'parametros: psseguro = ' || psseguro, SQLERRM);
                        RETURN 104767;   -- Error a l'esborrar a la taula CTASEGURO
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
                              'PAC_OPERATIVA_ULK.f_redistribuye_aportaciones_shw', NULL,
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
                              'PAC_OPERATIVA_ULK.f_redistribuye_aportaciones_shw', NULL,
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
                                 'PAC_OPERATIVA_ULK.f_redistribuye_aportaciones_shw', NULL,
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
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.ff_get_movimis_segdisin2', NULL,
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
         p_tab_error(f_sysdate, f_user, 'PAC_OPERATIVA_ULK.ff_get_segdisin2_nmovimi', NULL,
                     'parametros: psseguro = ' || psseguro, SQLERRM);
         RETURN v_m_modinv;   -- Error
   END ff_get_segdisin2_nmovimi;
END pac_operativa_ulk;

/

  GRANT EXECUTE ON "AXIS"."PAC_OPERATIVA_ULK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_OPERATIVA_ULK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_OPERATIVA_ULK" TO "PROGRAMADORESCSI";
