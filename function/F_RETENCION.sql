--------------------------------------------------------
--  DDL for Function F_RETENCION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_RETENCION" (
   psseguro NUMBER,
   pnmovimi NUMBER,
   pnsinies NUMBER,
   pfefecto DATE,
   pfrescat DATE,
   pctipres NUMBER,
   pimpres NUMBER,
   iretencion OUT NUMBER,
   pfrescat2 DATE DEFAULT NULL,
   pfmuerte DATE DEFAULT NULL)
   RETURN NUMBER AUTHID CURRENT_USER IS
   r              NUMBER;   -- Rendimiento total antes de reducciones
   rn             NUMBER;   -- Rendimiento total antes de reducciones
   rt             NUMBER;   -- Rendimiento asociado a la prima
   rtr            NUMBER;   -- Rendimiento reducido
   rtra           NUMBER;   -- Rendimiento reducido por antigüedad
   pase           NUMBER;
   xircm          NUMBER;
   valores_rescate_dia NUMBER;
   sumrt          NUMBER;   -- Sumatorio de rendimientos antes de reducciones
   sumpa          NUMBER;   -- Sumatorio de prestaciones pagadas
   sumra          NUMBER;   -- Sumatorio de rendimientos asociados a prestaciones
   sumpavivo      NUMBER;
   sumravivo      NUMBER;
   rbruto         NUMBER;   -- Suma de rendimientos reducidos
   red            NUMBER;   -- Porcentaje de reducción
   ret            NUMBER;   -- Porcentaje de retención
   resto          NUMBER;
   impsucesion    NUMBER;
   vivo           NUMBER;
   primasaportadas NUMBER;
   primasaportvivo NUMBER;
   rescate_pend   NUMBER := pimpres;
   rescate_acum   NUMBER;
   sumprim        NUMBER;
   kyt            NUMBER;
   kat            NUMBER;
   sumatoriobruto NUMBER;
   sumatoriobruto_1 NUMBER;
   sumando        NUMBER;
   sumarentas     NUMBER;
   movimiento_ult NUMBER;
   num_orden      NUMBER;
   seqresc        NUMBER;
   fcontabresc    DATE;
   rescates       NUMBER;
   ramo           NUMBER;
   modalidad      NUMBER;
   xcactivi       NUMBER;
   xsproduc       NUMBER;
   xcgarant       NUMBER;
   xfefecto       DATE;
   xcumple        NUMBER;
   xsumpri        NUMBER;
   xsumppa        NUMBER;
   xanys          NUMBER;
   cagrpro        NUMBER;
   cuantos        NUMBER;
BEGIN
   pase := 1;
   xcumple := 0;

   -- Cuenta cuantos rescate PARCIALES lleva esta póliza en el año.
   IF pfrescat >= TO_DATE('01012003', 'ddmmyyyy') THEN
      IF pctipres IN(33) THEN
         SELECT COUNT(*)
           INTO cuantos
           FROM ctaseguro
          WHERE ctaseguro.sseguro = psseguro
            AND TO_NUMBER(TO_CHAR(fvalmov, 'yyyy')) = TO_NUMBER(TO_CHAR(pfrescat, 'yyyy'))
            AND cmovimi IN(33);

         IF (cuantos + 1) > 1 THEN
            xcumple := 2;   -- Se le aplicara deducción 0
         END IF;
      END IF;
   END IF;

   -- Determinación del valor del rendimiento antes de reducciones
   IF pfmuerte IS NULL THEN
      SELECT NVL(SUM(ipricons), 0) + NVL(SUM(ircm), 0), NVL(SUM(ircm), 0)
        INTO sumpa, sumra
        FROM primas_consumidas
       WHERE sseguro = psseguro
         AND fecha < pfrescat;
   ELSE
      SELECT NVL(SUM(ipricons), 0) + NVL(SUM(ircm), 0), NVL(SUM(ircm), 0)
        INTO sumpa, sumra
        FROM primas_consumidas
       WHERE sseguro = psseguro
         AND fecha <= pfmuerte;

      SELECT NVL(SUM(ipricons), 0) + NVL(SUM(ircm), 0), NVL(SUM(ircm), 0)
        INTO sumpavivo, sumravivo
        FROM primas_consumidas
       WHERE sseguro = psseguro
         AND fecha BETWEEN pfmuerte + 1 AND pfrescat - 1;

      IF sumra > 0 THEN
         sumra := NVL(sumra, 2) / 2;
         sumra := sumra + sumravivo;
      END IF;

      IF sumpavivo > 0 THEN
         sumpa := sumpa + sumpavivo;
      END IF;
   END IF;

--
   SELECT cramo, cmodali, cagrpro, sproduc, cactivi, fefecto
     INTO ramo, modalidad, cagrpro, xsproduc, xcactivi, xfefecto
     FROM seguros
    WHERE sseguro = psseguro;

   -- Averigüo si se aplicara una deducción de coeficientes parametrizada o la máxima, siempre
   -- y cuando no sobrepase el limite de 3 rescates parciales que será una deducción 0.
   IF xcumple = 0 THEN
      IF pctipres IN(35, 33, 34) THEN
         IF pfrescat >= TO_DATE('01012003', 'ddmmyyyy') THEN
            IF xfefecto > TO_DATE('31121994', 'DDMMYYYY') THEN
               IF CEIL((pfrescat - xfefecto) / 365) > 8 THEN
                  xsumppa := 0;
                  xsumpri := 0;

                  FOR r IN (SELECT (iprima - prima_consumida(psseguro, nnumlin, f_sysdate))
                                                                                        prima,
                                   fvalmov
                              FROM primas_aportadas
                             WHERE sseguro = psseguro
                               AND fvalmov <= pfrescat) LOOP
                     xsumpri := xsumpri + r.prima;
                     xsumppa := xsumppa +(r.prima *(pfrescat - r.fvalmov));
                  END LOOP;

                  xanys := CEIL(xsumppa / xsumpri);

                  IF xanys > 4 THEN
                     xcumple := 1;
                  ELSE
                     xcumple := 0;
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;
   END IF;

   --
   sumprim := 0;
   sumatoriobruto := 0;
   sumatoriobruto_1 := 0;
   -- Cálculo del denominador para la determinación del rendimiento a nivel prima
   pase := 2;

   FOR r IN (SELECT DECODE(pfmuerte, NULL, iprima, iprima / 2)
                    - DECODE(pfmuerte,
                             NULL, prima_consumida(psseguro, nnumlin, f_sysdate),
                             prima_consumida(psseguro, nnumlin, f_sysdate) / 2) prima,
                    fvalmov
               FROM primas_aportadas
              WHERE sseguro = psseguro
                AND fvalmov <= pfrescat) LOOP
      sumprim := sumprim + r.prima *(pfrescat - r.fvalmov) / 365;
   END LOOP;

   --Cálculo de PrimasAportadas
   IF pfmuerte IS NULL THEN
      SELECT NVL(SUM(iprima), 0)
        INTO primasaportadas
        FROM primas_aportadas
       WHERE sseguro = psseguro
         AND fvalmov < pfrescat;
   ELSE
      SELECT NVL(SUM(iprima), 0)
        INTO primasaportadas
        FROM primas_aportadas
       WHERE sseguro = psseguro
         AND fvalmov <= pfmuerte;

      SELECT NVL(SUM(iprima), 0)
        INTO primasaportvivo
        FROM primas_aportadas
       WHERE sseguro = psseguro
         AND fvalmov BETWEEN pfmuerte + 1 AND pfrescat - 1;

      IF primasaportadas > 0 THEN
         primasaportadas := NVL(primasaportadas, 0) / 2;
         primasaportadas := primasaportadas + primasaportvivo;
      END IF;
   END IF;

   pase := 3;

   --Cálculo de Valores de Rescate
   SELECT NVL(SUM(imovimi), 0)
     INTO valores_rescate_dia
     FROM ctaseguro
    WHERE sseguro = psseguro
      AND cmovimi IN(33, 34)
      AND fvalmov BETWEEN primera_hora(pfrescat) AND ultima_hora(pfrescat);

   BEGIN
      pase := 4;

      --Cálculo de Rentas
      IF pfmuerte IS NULL THEN
         SELECT NVL(SUM(NVL(isinret, 0) - NVL(ibase, 0)), 0)
           INTO sumarentas
           FROM pagosrenta
          WHERE sseguro = psseguro
            AND ffecefe <= ultima_hora(pfrescat);
      ELSE
         SELECT sperson
           INTO vivo
           FROM asegurados
          WHERE sseguro = psseguro
            AND ffecmue IS NULL
            AND ffecfin IS NULL;   -- BUG11183:DRA:30/09/2009

         SELECT NVL(SUM(NVL(isinret, 0) - NVL(ibase, 0)), 0)
           INTO sumarentas
           FROM pagosrenta
          WHERE sseguro = psseguro
            AND ffecefe <= ultima_hora(pfrescat)
            AND sperson = vivo;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(-1);
   END;

   pase := 5;

   -- Rendimiento total antes de reducciones
   IF cagrpro = 21 THEN
      r := f_saldo_poliza_ulk(psseguro, pfrescat, pfrescat2) + valores_rescate_dia
           -(primasaportadas - sumpa) - sumra;
   ELSIF cagrpro = 10 THEN
      IF pfmuerte IS NULL THEN
         r := GREATEST(NVL(pk_provmatematicas.f_provmat(1, psseguro, pfrescat, 2, 0), 0), 0)
              - primasaportadas + sumarentas;
      ELSE
         r := pimpres - primasaportadas + sumarentas;
      END IF;
   ELSE
      IF pctipres = 34 THEN
         r := GREATEST(NVL(pk_provmatematicas.f_provmat(1, psseguro, pfrescat, 0, 0), 0), 0)
              -(primasaportadas - sumpa) - sumra;   -- Penalización
      ELSIF pctipres IN(33, 31) THEN
         r := GREATEST(NVL(pk_provmatematicas.f_provmat(0, psseguro, pfrescat - 1, 1, pimpres),
                           0),
                       0)
              -(primasaportadas - sumpa) - sumra;   -- Penalización

         IF pfmuerte IS NOT NULL THEN
            impsucesion := pk_provmatematicas.f_provmat(0, psseguro, pfmuerte, 1, pimpres) / 2;
            r := r - impsucesion;
         END IF;
      ELSE
         r := GREATEST(NVL(pk_provmatematicas.f_provmat(1, psseguro, pfefecto - 1, 1, 0), 0),
                       0)
              -(primasaportadas - sumpa) - sumra;   -- Penalización
      END IF;
   END IF;

   pase := 6;
   sumrt := 0;
   rbruto := 0;
   rescate_acum := 0;
   rtra := 0;
   xircm := 0;
   -- Cálculo del rendimiento antes de reducciones a nivel de prima
   movimiento_ult := 0;

   FOR p IN (SELECT   sseguro, nnumlin, fvalmov,
                      DECODE(pfmuerte, NULL, iprima, iprima / 2)
                      - DECODE(pfmuerte,
                               NULL, prima_consumida(sseguro, nnumlin, f_sysdate),
                               prima_consumida(sseguro, nnumlin, f_sysdate) / 2) imovimi
                 FROM primas_aportadas
                WHERE sseguro = psseguro
                  AND fvalmov <= pfrescat
             ORDER BY fvalmov) LOOP
      pase := 7;
      movimiento_ult := p.nnumlin;
      rt := r *(p.imovimi *((pfrescat - p.fvalmov) / 365)) / sumprim;
      sumando :=(p.imovimi + rt);
      sumatoriobruto := sumatoriobruto + sumando;
      kat := 1;

      IF pctipres IN(33, 31) THEN
         IF p.imovimi = 0 THEN
            kat := 0;
         ELSIF pimpres > sumatoriobruto THEN
            kat := 1;
         ELSIF pimpres BETWEEN sumatoriobruto_1 AND sumatoriobruto THEN
            kat := (pimpres - sumatoriobruto_1) /(p.imovimi + rt);
         ELSE
            kat := 0;
         END IF;

         rt := ROUND(rt * kat, 2);
      END IF;

      pase := 8;
      rescate_acum := rescate_acum +(p.imovimi + rt);
      rescate_pend := pimpres - rescate_acum;
      resto := ROUND(p.imovimi * kat, 2);

      IF p.imovimi > 0 THEN
         IF resto <> 0
            OR rt <> 0 THEN
            -- Grabación de la prima consumida
            DECLARE
               orden          NUMBER;
            BEGIN
               SELECT NVL(MAX(norden), 0)
                 INTO orden
                 FROM primas_consumidas
                WHERE sseguro = p.sseguro
                  AND nnumlin = p.nnumlin;

               INSERT INTO primas_consumidas
                           (sseguro, nnumlin, norden, ipricons, ircm, fecha, frescat)
                    VALUES (p.sseguro, p.nnumlin, orden + 1, resto, rt, p.fvalmov, pfrescat);
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN NULL;
            END;
         END IF;
      END IF;

      pase := 9;

      -- Determinación del % de reducción
      IF pctipres = 31 THEN
         xcgarant := 1;
      ELSIF pctipres = 32 THEN
         xcgarant := 2;
      ELSIF pctipres IN(33, 34, 35) THEN
         xcgarant := 999;
      END IF;

      --
      IF xcumple = 1 THEN
         xanys := 900;
      ELSE
         xanys := MONTHS_BETWEEN(pfrescat, p.fvalmov) / 12;
      END IF;

      IF xcumple IN(0, 1) THEN
         red := NULL;
         red := fbuscapreduc(1, xsproduc, xcactivi, xcgarant,
                             TO_NUMBER(TO_CHAR(pfrescat, 'yyyymmdd')), xanys);

         IF red IS NULL THEN
            RETURN 107710;
         END IF;
      ELSE
         red := 0;
      END IF;

      --
      xircm := xircm + rt;
      rtr := rt *(1 - red);
      rtra := rtra + rtr;

      -- Reducción adicional (primas anteriores a 31/12/1994)
      IF p.fvalmov < TO_DATE('31/12/1994', 'dd/mm/yyyy') THEN
         rtr := rtr
                * GREATEST(0,
                           1
                           - 0.1428
                             * CEIL((TO_DATE('31/12/1994', 'dd/mm/yyyy') - p.fvalmov) / 365));
      END IF;

      rbruto := rbruto + rtr;
      sumrt := sumrt + rtr;
      sumatoriobruto_1 := sumatoriobruto;
   END LOOP;

   pase := 10;
   -- Determinación del % de retención
/*
   ret := NULL;
   ret := FBUSCAPRETEN (1,pperson,psproduc,pfecha);
   IF ret IS NULL THEN
           RETURN 107710;
   END IF;
--
   BEGIN
      SELECT preten
        INTO ret
        FROM ULPRETE
       WHERE cramo = 35 AND cmodali = 1 AND ctipseg = 0 AND ccolect = 0
         AND finicio = (SELECT MAX(finicio)
                          FROM ULPRETE
                        WHERE cramo = 35 AND cmodali = 1 AND ctipseg = 0 AND ccolect = 0
                          AND finicio <= pfrescat);
   EXCEPTION
     WHEN OTHERS THEN
        RETURN 107710;
   END;
*/
   pase := 11;

   IF cagrpro = 10 THEN
      rt := r;
      rbruto := r;
   END IF;

   iretencion := 0;

--   iretencion := GREATEST(ROUND(Rbruto * ret/100, 2), 0);
   BEGIN
      SELECT NVL(MAX(norden), 0)
        INTO num_orden
        FROM ulreten
       WHERE sseguro = psseguro;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         num_orden := 0;
   END;

   num_orden := num_orden + 1;
   --INSERTAR REGISTRO EN ULRETEN

   --***************************************************************
--*** Si el tipo de rescate es 31 y la fecha de muerte es nula
--*** indicamos que es contingencia sin retención
--*** Si el tipo de rescate es 31 y la fecha de muerte NO es nula
--*** indicamos que es contingencia CON retención
--***************************************************************
   pase := 12;

   IF pctipres = 31
      AND pfmuerte IS NULL THEN
      BEGIN
         iretencion := 0;

         INSERT INTO ulreten
                     (sseguro, nmovimi, frescat, crescat, nsinies, irescat, iimpred, ireten,
                      norden, iprima, iprircm, iprinet, iprired, iprires, iresrcm, iresret,
                      iresred, cproces)
              VALUES (psseguro, movimiento_ult, pfrescat, pctipres, pnsinies, pimpres, 0, 0,
                      num_orden, NULL, 0, NULL, NULL, 0, 0, NULL,
                      0, '0');

         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 107611;
      END;
   ELSIF pctipres = 33 THEN
      --SI ES RESCATE PARCIAL
      BEGIN
         INSERT INTO ulreten
                     (sseguro, nmovimi, frescat, crescat, nsinies, irescat,
                      iimpred, ireten, norden, iprircm,
                      iprires, iresrcm, iresred, cproces)
              VALUES (psseguro, movimiento_ult, pfrescat, pctipres, pnsinies, pimpres,
                      ROUND(sumrt, 2), iretencion, num_orden, ROUND(sumrt, 2),
                      ROUND(resto, 2), ROUND(xircm, 2), ROUND(rtra, 2), '0');

         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 107611;
      END;
   ELSE
      --SI ES RESCATE TOTAL
      BEGIN
         INSERT INTO ulreten
                     (sseguro, nmovimi, frescat, crescat, nsinies, irescat,
                      iimpred, ireten, norden, iresrcm,
                      iresred, cproces)
              VALUES (psseguro, movimiento_ult, pfrescat, pctipres, pnsinies, pimpres,
                      ROUND(sumrt, 2), ROUND(iretencion, 2), num_orden, ROUND(xircm, 2),
                      ROUND(rtra, 2), '0');

         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 107801;
      END;
   END IF;

   RETURN 0;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN NULL;
   WHEN OTHERS THEN
      RETURN NULL;
END f_retencion;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_RETENCION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_RETENCION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_RETENCION" TO "PROGRAMADORESCSI";
