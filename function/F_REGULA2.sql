--------------------------------------------------------
--  DDL for Function F_REGULA2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_REGULA2" (
   psproces IN NUMBER,
   psseguro IN NUMBER,
   pnmovimi IN NUMBER,
   pmoneda IN NUMBER)
   /***********************************************************************
      F_REGULA      :  PERMITE CREAR CESIONES DE PRIMA POR REGULARIZACIONES
                          POR +- PRIMA Y +-CAPITAL.
                          SE CREAN MOVIMIENTOS 20 DE REGULARIZACIÓN Y 8 DE
                          ANULACIÓN POR REGULARIZACIÓN.
                          LA DISTRIBUCIÓN EN TRAMOS PUEDE VARIAR DE LO QUE YA
                          HABÍA ANTES DE LA REGULARIZACIÓN.
         ESQUEMA DE LO QUE TIENE QUE HACER ESTA FUNCIÓN:
                    FANULAC
                      ^
    ------|__________________|MOV.: 1 - CESIÓN TRAMO 1
          |..................|MOV.: 1 - CESIÓN TRAMO 2
                      |______|MOV.: 2 - CESIÓN POSITIVA SUPL. TRAMO 1
                      |......|MOV.: 2 - CESIÓN POSITIVA SUPL. TRAMO 2
                             |____________________|MOV. : 3 - CESI. TRAMO 1----
                             |....................|MOV. : 3 - CESI. TRAMO 2
                             |++++++++++++++++++++|MOV. : 3 - CESI. TRAMO 4
               A      B      C          D
               |************************| ESTO ES LA REGULARIZACIÓN...
    POR LOS PERÍODOS AB, BC Y CD, SE CREARÁN EN CESIONESREA CESIONES NEGATIVAS
    DE LO ANTERIOR POR CADA REGISTRO DE CESIONESREA.
    TAMBIÉN SE CREARÁN EN CESIONESAUX, POR LOS MISMOS PERÍODOS, CESIONES
    POSITIVAS CON LOS DATOS ANTERIORES.
    SE CREARÁN REGISTROS EN CESIONEAUX POR LAS GARANTÍAS QUE FORMAN LA REGULA-
    RIZACIÓN.
    A PARTIR DE ESTE GRUPO DE CESIONESAUX SE GENERAN LAS CESIONES.
      ALLIBREA
   ***********************************************************************/
RETURN NUMBER AUTHID CURRENT_USER IS
   codi_error     NUMBER := 0;
   w_finireg      garanseg.finiefe%TYPE;   --    w_finireg      DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_ffinreg      garanseg.ffinefe%TYPE;   --    w_ffinreg      DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   ende           DATE;
   fini           cesionesrea.fefecto%TYPE;   --    fini           DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   ffin           cesionesrea.fvencim%TYPE;   --    ffin           DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_cramo        seguros.cramo%TYPE;   --    w_cramo        NUMBER(8); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_cmodali      seguros.cmodali%TYPE;   --    w_cmodali      NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_ccolect      seguros.ccolect%TYPE;   --    w_ccolect      NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_ctipseg      seguros.ctipseg%TYPE;   --    w_ctipseg      NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_cactivi      seguros.cactivi%TYPE;   --    w_cactivi      NUMBER(4); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_cempres      codiram.cempres%TYPE;   --    w_cempres      NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_cfacult      seguros.creafac%TYPE;   --    w_cfacult      NUMBER(1); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_cobjase      seguros.cobjase%TYPE;   --    w_cobjase      NUMBER(1); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_ctiprea      seguros.ctiprea%TYPE;   --    w_ctiprea      NUMBER(1); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_cduraci      seguros.cduraci%TYPE;   --    w_cduraci      NUMBER(1); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_creaseg      NUMBER(1);
   w_iprianu      NUMBER;   --NUMBER(13, 2);
   w_icapital     NUMBER;   --NUMBER(15, 2);
   w_dias_origen  NUMBER;
   w_dias         NUMBER;
   w_icesion      cesionesrea.icesion%TYPE;   --    w_icesion      NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_scesrea      cesionesrea.scesrea%TYPE;   --    w_scesrea      NUMBER(8); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_nnumlin      cesionesaux.nnumlin%TYPE;   --    w_nnumlin      NUMBER(6); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_creafac      NUMBER(1);
   w_nasegur      riesgos.nasegur%TYPE;   --    w_nasegur      NUMBER(6); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_scontra      reariesgos.scontra%TYPE;   --    w_scontra      NUMBER(6); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_nversio      reariesgos.nversio%TYPE;   --    w_nversio      NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_scumulo      reariesgos.scumulo%TYPE;   --    w_scumulo      NUMBER(6); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_cestado      cesionesaux.nriesgo%TYPE;   --    w_cestado      NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   lcforpag       seguros.cforpag%TYPE;   --    lcforpag       NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   lsproduc       seguros.sproduc%TYPE;   --    lsproduc       NUMBER(6); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   -- 11845.NMM.12/2009.
   w_sproduc      seguros.sproduc%TYPE;

   CURSOR cur_cesi1 IS
      SELECT   *
          FROM cesionesrea
         WHERE sseguro = psseguro
           AND nmovimi <> pnmovimi
           AND cgenera IN(1, 3, 4, 5, 9)
           AND((fefecto <= w_finireg
                AND fvencim > w_finireg
                AND(fanulac IS NULL
                    OR fanulac > w_finireg)
                AND(fregula IS NULL
                    OR fregula > w_finireg))
               OR(fefecto >= w_finireg
                  AND fvencim <= w_ffinreg)
               OR(fefecto >= w_finireg
                  AND fefecto < w_ffinreg
                  AND fvencim > w_ffinreg))
      ORDER BY nmovimi;

   CURSOR cur_garan1 IS
      SELECT *
        FROM garanseg
       WHERE sseguro = psseguro
         AND nmovimi <> pnmovimi
         AND finiefe < w_finireg
         AND ffinefe > w_finireg
         AND ffinefe IS NOT NULL
         AND ffinefe < w_ffinreg;

   CURSOR cur_garan2 IS
      SELECT *
        FROM garanseg
       WHERE sseguro = psseguro
         AND nmovimi <> pnmovimi
         AND finiefe >= w_finireg
         AND ffinefe IS NOT NULL
         AND ffinefe < w_ffinreg;

   CURSOR cur_garan3 IS
      SELECT *
        FROM garanseg
       WHERE sseguro = psseguro
         AND nmovimi <> pnmovimi
         AND((finiefe >= w_finireg
              AND finiefe < w_ffinreg)
             OR finiefe < w_finireg)
         AND(ffinefe >= w_ffinreg
             OR ffinefe IS NULL);

-- ************************************************************************
-- ************************************************************************
-- ************************************************************************
   FUNCTION f_regul(pfini IN DATE, pffin IN DATE)
      RETURN NUMBER IS
      codi_error     NUMBER := 0;

      CURSOR cur_garanreg IS
         SELECT *
           FROM garanseg
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;
   --
   BEGIN
      FOR reggar IN cur_garanreg LOOP
         IF reggar.cgarant = 9999 THEN   -- GARANTIA 9999(DESPESES SINISTRE)
            w_creaseg := 1;   -- SEMPRE ES REASSEGURRA...
         ELSE
            -- BUG 11100 - 16/09/2009 - FAL - Crida a la pac_cesionesrea.f_gar_rea per si garantia reasegurable
            codi_error :=
               pac_cesionesrea.f_gar_rea(w_cramo, w_cmodali, w_ctipseg, w_ccolect,
                                         pac_seguros.ff_get_actividad(reggar.sseguro,
                                                                      reggar.nriesgo),
                                         reggar.cgarant, w_creaseg);

            /*
            BEGIN   -- AQUÍ ES MIRA SI LA GARANTÍA
               SELECT creaseg   -- ES REASSEGURA...
                 INTO w_creaseg
                 FROM garanpro
                WHERE cramo = w_cramo
                  AND cmodali = w_cmodali
                  AND ctipseg = w_ctipseg
                  AND ccolect = w_ccolect
                  AND cactivi = pac_seguros.ff_get_actividad(reggar.sseguro, reggar.nriesgo)
                  AND cgarant = reggar.cgarant;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT creaseg
                       INTO w_creaseg
                       FROM garanpro
                      WHERE cramo = w_cramo
                        AND cmodali = w_cmodali
                        AND ctipseg = w_ctipseg
                        AND ccolect = w_ccolect
                        AND cactivi = 0
                        AND cgarant = reggar.cgarant;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        codi_error := 104110;
                        RETURN(codi_error);
                     WHEN OTHERS THEN
                        codi_error := 103503;
                        RETURN(codi_error);
                  END;
               WHEN OTHERS THEN
                  codi_error := 103503;
                  RETURN(codi_error);
            END;
            */
            IF codi_error <> 0 THEN
               RETURN codi_error;
            END IF;
         --FI BUG 11100 - 16/09/2009 – FAL
         END IF;

         w_iprianu := NVL(reggar.itarrea, reggar.iprianu);

         IF w_creaseg = 1 THEN
            w_icapital := reggar.icapital;
         ELSIF w_creaseg = 2 THEN
            w_icapital := 0;
         ELSIF w_creaseg = 3 THEN
            w_icapital := reggar.icapital;
            w_iprianu := 0;
         END IF;

         IF w_cobjase = 4 THEN   -- ES TRACTA D'UN INNOMINAT...
            BEGIN
               SELECT nasegur
                 INTO w_nasegur
                 FROM riesgos
                WHERE sseguro = psseguro
                  AND nriesgo = reggar.nriesgo;

               w_iprianu := w_iprianu * w_nasegur;
               w_icapital := w_icapital * w_nasegur;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  codi_error := 103836;
                  RETURN(codi_error);
               WHEN OTHERS THEN
                  codi_error := 103509;
                  RETURN(codi_error);
            END;
         END IF;

         ---------     BUSQUEM SI EL RISC FORMA PART D'UN CUMUL...
         w_scumulo := NULL;

         BEGIN
            SELECT scumulo
              INTO w_scumulo
              FROM reariesgos
             WHERE ROWNUM = 1
               AND sseguro = psseguro
               AND nriesgo = reggar.nriesgo
               AND cgarant = reggar.cgarant
               AND pfini >= freaini
               AND(pfini < freafin
                   OR freafin IS NULL)
               AND scumulo IS NOT NULL;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT scumulo
                    INTO w_scumulo
                    FROM reariesgos
                   WHERE ROWNUM = 1
                     AND sseguro = psseguro
                     AND nriesgo = reggar.nriesgo
                     AND cgarant IS NULL
                     AND pfini >= freaini
                     AND(pfini < freafin
                         OR freafin IS NULL)
                     AND scumulo IS NOT NULL;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     NULL;
                  WHEN OTHERS THEN
                     codi_error := 104665;
                     RETURN(codi_error);
               END;
            WHEN OTHERS THEN
               codi_error := 104665;
               RETURN(codi_error);
         END;

         ----------     BUSQUEM SI HI HA ALGUN RISC, GARANTIA O CUMUL A "PIÑÓN FIJO"...
         w_scontra := NULL;
         w_nversio := NULL;

         BEGIN
            SELECT scontra, nversio
              INTO w_scontra, w_nversio
              FROM reariesgos
             WHERE ROWNUM = 1
               AND sseguro = psseguro
               AND nriesgo = reggar.nriesgo
               AND cgarant = reggar.cgarant
               AND nversio IS NOT NULL
               AND pfini >= freaini
               AND pfini < NVL(freafin, TO_DATE('31/12/3000', 'DD/MM/YYYY'));
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT scontra, nversio
                    INTO w_scontra, w_nversio
                    FROM reariesgos
                   WHERE ROWNUM = 1
                     AND sseguro = psseguro
                     AND nriesgo = reggar.nriesgo
                     AND cgarant IS NULL
                     AND nversio IS NOT NULL
                     AND pfini >= freaini
                     AND pfini < NVL(freafin, TO_DATE('31/12/3000', 'DD/MM/YYYY'));
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                        IF w_scumulo IS NOT NULL THEN
                           SELECT scontra, nversio
                             INTO w_scontra, w_nversio
                             FROM reariesgos
                            WHERE ROWNUM = 1
                              AND scumulo = w_scumulo
                              AND nversio IS NOT NULL
                              AND pfini >= freaini
                              AND pfini < NVL(freafin, TO_DATE('31/12/3000', 'DD/MM/YYYY'));
                        END IF;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           NULL;
                        WHEN OTHERS THEN
                           codi_error := 104666;
                           RETURN(codi_error);
                     END;
                  WHEN OTHERS THEN
                     codi_error := 104666;
                     RETURN(codi_error);
               END;
            WHEN OTHERS THEN
               codi_error := 104666;
               RETURN(codi_error);
         END;

--------------
--      AQUI ES PRORRATEJA LA PRIMA DE LA REGULARITZACIÓ, PENSANT QUE LA
--      TENIM DE CONVERTIR EN PRIMA ANUAL PER EL "CESIONESAUX"...
         codi_error := f_difdata(reggar.finiefe, reggar.ffinefe, 3, 3, w_dias_origen);

         IF codi_error <> 0 THEN
            RETURN(codi_error);
         END IF;

         IF w_dias_origen = 0 THEN
            w_dias_origen := 1;
         END IF;

         w_iprianu := (w_iprianu * 360) / w_dias_origen;
         w_iprianu := f_round(w_iprianu, pmoneda);

         IF NVL(w_iprianu, 0) <> 0
            OR NVL(w_icapital, 0) <> 0 THEN
            w_cestado := 0;
            w_nnumlin := w_nnumlin + 1;

            BEGIN
               INSERT INTO cesionesaux
                           (sproces, nnumlin, sseguro, iprirea,
                            icapital, cestado, cfacult, nriesgo,
                            nmovimi, cgarant, scontra, fconini, fconfin, nversio,
                            scumulo, nagrupa)
                    VALUES (psproces, w_nnumlin, psseguro, NVL(w_iprianu, 0),
                            NVL(w_icapital, 0), w_cestado, w_cfacult, reggar.nriesgo,
                            pnmovimi, reggar.cgarant, w_scontra, pfini, pffin, w_nversio,
                            w_scumulo, NULL);
            EXCEPTION
               WHEN OTHERS THEN
                  codi_error := 104667;
                  RETURN(codi_error);
            END;
         END IF;
      END LOOP;

      RETURN(codi_error);
   END f_regul;
-- ************************************************************************
-- ************************************************************************
-- ************************************************************************
BEGIN
-- AQUI SE BUSCAN LAS FECHAS INICIAL Y FINAL DE LA REGULARIZACIÓN
-- ( EN W_FINIREG Y W_FFINREG )...
-- **************************************************************
   BEGIN
      SELECT UNIQUE finiefe, ffinefe
               INTO w_finireg, w_ffinreg
               FROM garanseg
              WHERE sseguro = psseguro
                AND nmovimi = pnmovimi;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         codi_error := 105814;
         RETURN(codi_error);
      WHEN OTHERS THEN
         codi_error := 103500;
         RETURN(codi_error);
   END;

   BEGIN
      SELECT cforpag, sproduc
        INTO lcforpag, lsproduc
        FROM seguros
       WHERE sseguro = psseguro;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 101919;
   END;

---------------------------------------------------------------------
-- AQUI SE CREAN LOS MOVIMIENTOS PRORRATEADOS DE ANULACIÓN...
-- **********************************************************
   FOR regcesi IN cur_cesi1 LOOP
      --      SE DETERMINAN LAS FECHAS LÍMITE PARA PRORRATEO...
      ende := regcesi.fvencim;

      IF regcesi.fanulac IS NOT NULL
         AND regcesi.fanulac < regcesi.fvencim THEN
         ende := regcesi.fanulac;
      END IF;

      IF regcesi.fregula IS NOT NULL
         AND regcesi.fregula < regcesi.fvencim THEN
         ende := regcesi.fregula;
      END IF;

      IF regcesi.fefecto <= w_finireg
         AND ende > w_finireg THEN
         fini := w_finireg;

         IF ende < w_ffinreg THEN
            ffin := ende;
         ELSE
            ffin := w_ffinreg;
         END IF;
      END IF;

      IF regcesi.fefecto >= w_finireg
         AND ende <= w_ffinreg THEN
         fini := regcesi.fefecto;
         ffin := ende;
      END IF;

      IF regcesi.fefecto >= w_finireg
         AND ende > w_ffinreg THEN
         fini := regcesi.fefecto;
         ffin := w_ffinreg;
      END IF;

      --      SE PRORRATEA LA PRIMA Y SE DAN DE ALTA LOS MOVIMIENTOS NEGATIVOS EN
      --      "CESIONESREA"...
      codi_error := f_difdata(regcesi.fefecto, regcesi.fvencim, 3, 3, w_dias_origen);

      IF codi_error <> 0 THEN
         RETURN(codi_error);
      END IF;

      codi_error := f_difdata(fini, ffin, 3, 3, w_dias);

      IF codi_error <> 0 THEN
         RETURN(codi_error);
      END IF;

      IF w_dias_origen = 0 THEN
         w_dias_origen := 1;
      END IF;

      IF w_dias = 0 THEN
         w_dias := 1;
      END IF;

      w_icesion := (regcesi.icesion * w_dias) / w_dias_origen;
      --W_ICESION := F_ROUND(W_ICESION,PMONEDA);
      w_icesion := f_round_forpag(w_icesion, lcforpag,
                                   -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                  --2,
                                  pmoneda,
                                  -- BUG 18423 - F- 27/12/2011 - JLB - LCOL000 - Multimoneda
                                  lsproduc);
      w_icesion := w_icesion * -1;

      --      SE GENERAN LOS MOVIMIENTOS NEGATIVOS EN "CESIONESREA"...
      SELECT scesrea.NEXTVAL
        INTO w_scesrea
        FROM DUAL;

      BEGIN
         INSERT INTO cesionesrea
                     (scesrea, ncesion, icesion, icapces, sseguro,
                      nversio, scontra, ctramo, sfacult,
                      nriesgo, icomisi, icomreg, scumulo,
                      cgarant, spleno, ccalif1, ccalif2,
                      nsinies, fefecto, fvencim, fcontab, pcesion, sproces, cgenera,
                      fgenera, fregula, fanulac, nmovimi, ipleno, icapaci)
              VALUES (w_scesrea, 0, w_icesion, regcesi.icapces, regcesi.sseguro,
                      regcesi.nversio, regcesi.scontra, regcesi.ctramo, regcesi.sfacult,
                      regcesi.nriesgo, regcesi.icomisi, regcesi.icomreg, regcesi.scumulo,
                      regcesi.cgarant, regcesi.spleno, regcesi.ccalif1, regcesi.ccalif2,
                      regcesi.nsinies, fini, ffin, NULL, regcesi.pcesion, psproces, 8,
                      f_sysdate, NULL, NULL, pnmovimi, regcesi.ipleno, regcesi.icapaci);
      EXCEPTION
         WHEN OTHERS THEN
            codi_error := 105200;
            RETURN(codi_error);
      END;
   END LOOP;

-------------------------------------------------------------------------
-- AQUI SE GENERAN LOS MOVIMIENTOS POSITIVOS A PARTIR DEL "GARANSEG" SOBRE
-- "CESIONESAUX" PARA CADA LAPSUS DE TIEMPO (AB, BC, CD...ETC.).
-- PARA CADA SEGMENTO DE TIEMPO SE LLAMARÁ A LA FUNCIÓN ESPECIAL "F_BUSCA"
-- Y A "F_CESSIO"...
-- ***********************************************************************
-- AQUI ESBORREM QUALSEVOL COSA QUE HI HAGI A LA TAULA CESIONESAUX...
   BEGIN
      DELETE FROM cesionesaux
            WHERE sproces = psproces;
   EXCEPTION
      WHEN OTHERS THEN
         codi_error := 104703;
         RETURN(codi_error);
   END;

   BEGIN
      SELECT s.cramo, s.cmodali, s.ccolect, s.ctipseg, s.cactivi, r.cempres, s.creafac,
             s.cobjase, s.ctiprea, s.cduraci, s.sproduc
        INTO w_cramo, w_cmodali, w_ccolect, w_ctipseg, w_cactivi, w_cempres, w_cfacult,
             w_cobjase, w_ctiprea, w_cduraci, w_sproduc
        FROM seguros s, codiram r
       WHERE s.sseguro = psseguro
         AND s.cramo = r.cramo;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         codi_error := 101903;
         RETURN(codi_error);
      WHEN OTHERS THEN
         codi_error := 101919;
         RETURN(codi_error);
   END;

   -- AQUI ES MIRA SI L'ASSEGURANÇA INDIVIDUALMENT ES REASSEGURA...
   IF w_ctiprea = 2 THEN
      codi_error := 199;   -- SEGURO NO REASSEGURAT...
      RETURN(codi_error);   -- EL CODI_ERROR 199 EVITA QUE ES
   END IF;   -- REALITZI LA CESSIÓ...

      -- Mantis 11845.12/2009.NMM.CRE - Ajustar reassegurança d'estalvi .i.
   -- AQUI ES MIRA SI EL PRODUCTE GLOBAL ES REASSEGURA...
      /*BEGIN
         SELECT creaseg
           INTO w_creaseg
           FROM productos
          WHERE cramo = w_cramo
            AND cmodali = w_cmodali
            AND ctipseg = w_ctipseg
            AND ccolect = w_ccolect;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            codi_error := 104347;
            RETURN(codi_error);
         WHEN OTHERS THEN
            codi_error := 102705;
            RETURN(codi_error);
      END;*/
   IF pac_cesionesrea.producte_reassegurable(w_sproduc) = 0 THEN
      --IF w_creaseg = 0 THEN
      codi_error := 199;   -- PRODUCTE NO REASSEGURAT...
      RETURN(codi_error);   -- EL CODI_ERROR 199 EVITA QUE ES REALITZI
   END IF;   -- LA CESSIÓ...

-------------------------------------------------------------------
   fini := NULL;
   ffin := NULL;
   w_nnumlin := 0;

   FOR reggar IN cur_garan1 LOOP
      fini := w_finireg;
      ffin := reggar.ffinefe;

      IF reggar.cgarant = 9999 THEN   -- GARANTIA 9999(DESPESES SINISTRE)
         w_creaseg := 1;   -- SEMPRE ES REASSEGURRA...
      ELSE
         -- BUG 11100 - 16/09/2009 - FAL - Crida a la pac_cesionesrea.f_gar_rea per si garantia reasegurable
         codi_error :=
            pac_cesionesrea.f_gar_rea(w_cramo, w_cmodali, w_ctipseg, w_ccolect,
                                      pac_seguros.ff_get_actividad(reggar.sseguro,
                                                                   reggar.nriesgo),
                                      reggar.cgarant, w_creaseg);

         /*
         BEGIN   -- AQUÍ ES MIRA SI LA GARANTÍA
            SELECT creaseg   -- ES REASSEGURA...
              INTO w_creaseg
              FROM garanpro
             WHERE cramo = w_cramo
               AND cmodali = w_cmodali
               AND ctipseg = w_ctipseg
               AND ccolect = w_ccolect
               AND cactivi = pac_seguros.ff_get_actividad(reggar.sseguro, reggar.nriesgo)
               AND cgarant = reggar.cgarant;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT creaseg
                    INTO w_creaseg
                    FROM garanpro
                   WHERE cramo = w_cramo
                     AND cmodali = w_cmodali
                     AND ctipseg = w_ctipseg
                     AND ccolect = w_ccolect
                     AND cactivi = 0
                     AND cgarant = reggar.cgarant;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     codi_error := 104110;
                     RETURN(codi_error);
                  WHEN OTHERS THEN
                     codi_error := 103503;
                     RETURN(codi_error);
               END;
            WHEN OTHERS THEN
               codi_error := 103503;
               RETURN(codi_error);
         END;
         */
         IF codi_error <> 0 THEN
            RETURN codi_error;
         END IF;
      --FI BUG 11100 - 16/09/2009 – FAL
      END IF;

      IF w_creaseg <> 0 THEN
         w_iprianu := NVL(reggar.itarrea, reggar.iprianu);

         IF w_creaseg = 1 THEN
            w_icapital := reggar.icapital;
         ELSIF w_creaseg = 2 THEN
            w_icapital := 0;
         ELSIF w_creaseg = 3 THEN
            w_icapital := reggar.icapital;
            w_iprianu := 0;
         END IF;

         IF w_cobjase = 4 THEN   -- ES TRACTA D'UN INNOMINAT...
            BEGIN
               SELECT nasegur
                 INTO w_nasegur
                 FROM riesgos
                WHERE sseguro = psseguro
                  AND nriesgo = reggar.nriesgo;

               w_iprianu := w_iprianu * w_nasegur;
               w_icapital := w_icapital * w_nasegur;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  codi_error := 103836;
                  RETURN(codi_error);
               WHEN OTHERS THEN
                  codi_error := 103509;
                  RETURN(codi_error);
            END;
         END IF;

         ---------     BUSQUEM SI EL RISC FORMA PART D'UN CUMUL...
         w_scumulo := NULL;

         BEGIN
            SELECT scumulo
              INTO w_scumulo
              FROM reariesgos
             WHERE ROWNUM = 1
               AND sseguro = psseguro
               AND nriesgo = reggar.nriesgo
               AND cgarant = reggar.cgarant
               AND fini >= freaini
               AND(fini < freafin
                   OR freafin IS NULL)
               AND scumulo IS NOT NULL;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT scumulo
                    INTO w_scumulo
                    FROM reariesgos
                   WHERE ROWNUM = 1
                     AND sseguro = psseguro
                     AND nriesgo = reggar.nriesgo
                     AND cgarant IS NULL
                     AND fini >= freaini
                     AND(fini < freafin
                         OR freafin IS NULL)
                     AND scumulo IS NOT NULL;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     NULL;
                  WHEN OTHERS THEN
                     codi_error := 104665;
                     RETURN(codi_error);
               END;
            WHEN OTHERS THEN
               codi_error := 104665;
               RETURN(codi_error);
         END;

         ----------     BUSQUEM SI HI HA ALGUN RISC, GARANTIA O CUMUL A "PIÑÓN FIJO"...
         w_scontra := NULL;
         w_nversio := NULL;

         BEGIN
            SELECT scontra, nversio
              INTO w_scontra, w_nversio
              FROM reariesgos
             WHERE ROWNUM = 1
               AND sseguro = psseguro
               AND nriesgo = reggar.nriesgo
               AND cgarant = reggar.cgarant
               AND nversio IS NOT NULL
               AND fini >= freaini
               AND fini < NVL(freafin, TO_DATE('31/12/3000', 'DD/MM/YYYY'));
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT scontra, nversio
                    INTO w_scontra, w_nversio
                    FROM reariesgos
                   WHERE ROWNUM = 1
                     AND sseguro = psseguro
                     AND nriesgo = reggar.nriesgo
                     AND cgarant IS NULL
                     AND nversio IS NOT NULL
                     AND fini >= freaini
                     AND fini < NVL(freafin, TO_DATE('31/12/3000', 'DD/MM/YYYY'));
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                        IF w_scumulo IS NOT NULL THEN
                           SELECT scontra, nversio
                             INTO w_scontra, w_nversio
                             FROM reariesgos
                            WHERE ROWNUM = 1
                              AND scumulo = w_scumulo
                              AND nversio IS NOT NULL
                              AND fini >= freaini
                              AND fini < NVL(freafin, TO_DATE('31/12/3000', 'DD/MM/YYYY'));
                        END IF;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           NULL;
                        WHEN OTHERS THEN
                           codi_error := 104666;
                           RETURN(codi_error);
                     END;
                  WHEN OTHERS THEN
                     codi_error := 104666;
                     RETURN(codi_error);
               END;
            WHEN OTHERS THEN
               codi_error := 104666;
               RETURN(codi_error);
         END;

--------------
         IF NVL(w_iprianu, 0) <> 0
            OR NVL(w_icapital, 0) <> 0 THEN
            w_cestado := 0;
            w_nnumlin := w_nnumlin + 1;

            BEGIN
               INSERT INTO cesionesaux
                           (sproces, nnumlin, sseguro, iprirea,
                            icapital, cestado, cfacult, nriesgo,
                            nmovimi, cgarant, scontra, fconini, fconfin, nversio,
                            scumulo, nagrupa)
                    VALUES (psproces, w_nnumlin, psseguro, NVL(w_iprianu, 0),
                            NVL(w_icapital, 0), w_cestado, w_cfacult, reggar.nriesgo,
                            pnmovimi, reggar.cgarant, w_scontra, fini, ffin, w_nversio,
                            w_scumulo, NULL);
            EXCEPTION
               WHEN OTHERS THEN
                  codi_error := 104667;
                  RETURN(codi_error);
            END;
         END IF;
      END IF;
   END LOOP;

   --  AQUÍ SE CREA LA PARTE CORRESPONDIENTE AL MOVIMIENTO DE REGULARIZACION...
   --  GENERACION DE CESIONES...
   IF fini IS NOT NULL
      AND ffin IS NOT NULL THEN
      codi_error := f_regul(fini, ffin);

      IF codi_error <> 0 THEN
         RETURN(codi_error);
      END IF;

      codi_error := f_busca(psseguro, pnmovimi, psproces, 20);

      IF codi_error <> 0
         AND codi_error <> 99 THEN
         RETURN(codi_error);
      ELSIF codi_error = 99 THEN
         codi_error := 0;
      ELSE
         codi_error := f_cessio(psproces, 20,
                                 -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                --2
                                pmoneda
                                       -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                      );

         IF codi_error <> 0 THEN
            RETURN(codi_error);
         END IF;
      END IF;
   END IF;

-----------------------------------------------------------------
   fini := NULL;
   ffin := NULL;

   FOR reggar IN cur_garan2 LOOP
      fini := reggar.finiefe;
      ffin := reggar.ffinefe;

      IF reggar.cgarant = 9999 THEN   -- GARANTIA 9999(DESPESES SINISTRE)
         w_creaseg := 1;   -- SEMPRE ES REASSEGURRA...
      ELSE
         -- BUG 11100 - 16/09/2009 - FAL - Crida a la pac_cesionesrea.f_gar_rea per si garantia reasegurable
         codi_error :=
            pac_cesionesrea.f_gar_rea(w_cramo, w_cmodali, w_ctipseg, w_ccolect,
                                      pac_seguros.ff_get_actividad(reggar.sseguro,
                                                                   reggar.nriesgo),
                                      reggar.cgarant, w_creaseg);

         /*
         BEGIN   -- AQUÍ ES MIRA SI LA GARANTÍA
            SELECT creaseg   -- ES REASSEGURA...
              INTO w_creaseg
              FROM garanpro
             WHERE cramo = w_cramo
               AND cmodali = w_cmodali
               AND ctipseg = w_ctipseg
               AND ccolect = w_ccolect
               AND cactivi = pac_seguros.ff_get_actividad(reggar.sseguro, reggar.nriesgo)
               AND cgarant = reggar.cgarant;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT creaseg
                    INTO w_creaseg
                    FROM garanpro
                   WHERE cramo = w_cramo
                     AND cmodali = w_cmodali
                     AND ctipseg = w_ctipseg
                     AND ccolect = w_ccolect
                     AND cactivi = 0
                     AND cgarant = reggar.cgarant;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     codi_error := 104110;
                     RETURN(codi_error);
                  WHEN OTHERS THEN
                     codi_error := 103503;
                     RETURN(codi_error);
               END;
            WHEN OTHERS THEN
               codi_error := 103503;
               RETURN(codi_error);
         END;
         */
         IF codi_error <> 0 THEN
            RETURN codi_error;
         END IF;
      --FI BUG 11100 - 16/09/2009 – FAL
      END IF;

      IF w_creaseg <> 0 THEN
         w_iprianu := NVL(reggar.itarrea, reggar.iprianu);

         IF w_creaseg = 1 THEN
            w_icapital := reggar.icapital;
         ELSIF w_creaseg = 2 THEN
            w_icapital := 0;
         ELSIF w_creaseg = 3 THEN
            w_icapital := reggar.icapital;
            w_iprianu := 0;
         END IF;

         IF w_cobjase = 4 THEN   -- ES TRACTA D'UN INNOMINAT...
            BEGIN
               SELECT nasegur
                 INTO w_nasegur
                 FROM riesgos
                WHERE sseguro = psseguro
                  AND nriesgo = reggar.nriesgo;

               w_iprianu := w_iprianu * w_nasegur;
               w_icapital := w_icapital * w_nasegur;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  codi_error := 103836;
                  RETURN(codi_error);
               WHEN OTHERS THEN
                  codi_error := 103509;
                  RETURN(codi_error);
            END;
         END IF;

         ---------     BUSQUEM SI EL RISC FORMA PART D'UN CUMUL...
         w_scumulo := NULL;

         BEGIN
            SELECT scumulo
              INTO w_scumulo
              FROM reariesgos
             WHERE ROWNUM = 1
               AND sseguro = psseguro
               AND nriesgo = reggar.nriesgo
               AND cgarant = reggar.cgarant
               AND fini >= freaini
               AND(fini < freafin
                   OR freafin IS NULL)
               AND scumulo IS NOT NULL;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT scumulo
                    INTO w_scumulo
                    FROM reariesgos
                   WHERE ROWNUM = 1
                     AND sseguro = psseguro
                     AND nriesgo = reggar.nriesgo
                     AND cgarant IS NULL
                     AND fini >= freaini
                     AND(fini < freafin
                         OR freafin IS NULL)
                     AND scumulo IS NOT NULL;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     NULL;
                  WHEN OTHERS THEN
                     codi_error := 104665;
                     RETURN(codi_error);
               END;
            WHEN OTHERS THEN
               codi_error := 104665;
               RETURN(codi_error);
         END;

         ----------     BUSQUEM SI HI HA ALGUN RISC, GARANTIA O CUMUL A "PIÑÓN FIJO"...
         w_scontra := NULL;
         w_nversio := NULL;

         BEGIN
            SELECT scontra, nversio
              INTO w_scontra, w_nversio
              FROM reariesgos
             WHERE ROWNUM = 1
               AND sseguro = psseguro
               AND nriesgo = reggar.nriesgo
               AND cgarant = reggar.cgarant
               AND nversio IS NOT NULL
               AND fini >= freaini
               AND fini < NVL(freafin, TO_DATE('31/12/3000', 'DD/MM/YYYY'));
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT scontra, nversio
                    INTO w_scontra, w_nversio
                    FROM reariesgos
                   WHERE ROWNUM = 1
                     AND sseguro = psseguro
                     AND nriesgo = reggar.nriesgo
                     AND cgarant IS NULL
                     AND nversio IS NOT NULL
                     AND fini >= freaini
                     AND fini < NVL(freafin, TO_DATE('31/12/3000', 'DD/MM/YYYY'));
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                        IF w_scumulo IS NOT NULL THEN
                           SELECT scontra, nversio
                             INTO w_scontra, w_nversio
                             FROM reariesgos
                            WHERE ROWNUM = 1
                              AND scumulo = w_scumulo
                              AND nversio IS NOT NULL
                              AND fini >= freaini
                              AND fini < NVL(freafin, TO_DATE('31/12/3000', 'DD/MM/YYYY'));
                        END IF;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           NULL;
                        WHEN OTHERS THEN
                           codi_error := 104666;
                           RETURN(codi_error);
                     END;
                  WHEN OTHERS THEN
                     codi_error := 104666;
                     RETURN(codi_error);
               END;
            WHEN OTHERS THEN
               codi_error := 104666;
               RETURN(codi_error);
         END;

--------------
         IF NVL(w_iprianu, 0) <> 0
            OR NVL(w_icapital, 0) <> 0 THEN
            w_cestado := 0;
            w_nnumlin := w_nnumlin + 1;

            BEGIN
               INSERT INTO cesionesaux
                           (sproces, nnumlin, sseguro, iprirea,
                            icapital, cestado, cfacult, nriesgo,
                            nmovimi, cgarant, scontra, fconini, fconfin, nversio,
                            scumulo, nagrupa)
                    VALUES (psproces, w_nnumlin, psseguro, NVL(w_iprianu, 0),
                            NVL(w_icapital, 0), w_cestado, w_cfacult, reggar.nriesgo,
                            pnmovimi, reggar.cgarant, w_scontra, fini, ffin, w_nversio,
                            w_scumulo, NULL);
            EXCEPTION
               WHEN OTHERS THEN
                  codi_error := 104667;
                  RETURN(codi_error);
            END;
         END IF;
      END IF;
   END LOOP;

   --  AQUÍ SE CREA LA PARTE CORRESPONDIENTE AL MOVIMIENTO DE REGULARIZACION...
   IF fini IS NOT NULL
      AND ffin IS NOT NULL THEN
      codi_error := f_regul(fini, ffin);

      IF codi_error <> 0 THEN
         RETURN(codi_error);
      END IF;

      codi_error := f_busca(psseguro, pnmovimi, psproces, 20);

      IF codi_error <> 0
         AND codi_error <> 99 THEN
         RETURN(codi_error);
      ELSIF codi_error = 99 THEN
         codi_error := 0;
      ELSE
         codi_error := f_cessio(psproces, 20,
                                 -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                --2
                                pmoneda
                                       -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                      );

         IF codi_error <> 0 THEN
            RETURN(codi_error);
         END IF;
      END IF;
   END IF;

------------------------------------------------------------------
   fini := NULL;
   ffin := NULL;

   FOR reggar IN cur_garan3 LOOP
      IF reggar.finiefe < w_finireg THEN
         fini := w_finireg;
      ELSE
         fini := reggar.finiefe;
      END IF;

      ffin := w_ffinreg;

      IF reggar.cgarant = 9999 THEN   -- GARANTIA 9999(DESPESES SINISTRE)
         w_creaseg := 1;   -- SEMPRE ES REASSEGURRA...
      ELSE
         -- BUG 11100 - 16/09/2009 - FAL - Crida a la pac_cesionesrea.f_gar_rea per si garantia reasegurable
         codi_error :=
            pac_cesionesrea.f_gar_rea(w_cramo, w_cmodali, w_ctipseg, w_ccolect,
                                      pac_seguros.ff_get_actividad(reggar.sseguro,
                                                                   reggar.nriesgo),
                                      reggar.cgarant, w_creaseg);

         /*
         BEGIN   -- AQUÍ ES MIRA SI LA GARANTÍA
            SELECT creaseg   -- ES REASSEGURA...
              INTO w_creaseg
              FROM garanpro
             WHERE cramo = w_cramo
               AND cmodali = w_cmodali
               AND ctipseg = w_ctipseg
               AND ccolect = w_ccolect
               AND cactivi = pac_seguros.ff_get_actividad(reggar.sseguro, reggar.nriesgo)
               AND cgarant = reggar.cgarant;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT creaseg
                    INTO w_creaseg
                    FROM garanpro
                   WHERE cramo = w_cramo
                     AND cmodali = w_cmodali
                     AND ctipseg = w_ctipseg
                     AND ccolect = w_ccolect
                     AND cactivi = 0
                     AND cgarant = reggar.cgarant;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     codi_error := 104110;
                     RETURN(codi_error);
                  WHEN OTHERS THEN
                     codi_error := 103503;
                     RETURN(codi_error);
               END;
            WHEN OTHERS THEN
               codi_error := 103503;
               RETURN(codi_error);
         END;
         */
         IF codi_error <> 0 THEN
            RETURN codi_error;
         END IF;
      --FI BUG 11100 - 16/09/2009 – FAL
      END IF;

      IF w_creaseg <> 0 THEN
         w_iprianu := NVL(reggar.itarrea, reggar.iprianu);

         IF w_creaseg = 1 THEN
            w_icapital := reggar.icapital;
         ELSIF w_creaseg = 2 THEN
            w_icapital := 0;
         ELSIF w_creaseg = 3 THEN
            w_icapital := reggar.icapital;
            w_iprianu := 0;
         END IF;

         IF w_cobjase = 4 THEN   -- ES TRACTA D'UN INNOMINAT...
            BEGIN
               SELECT nasegur
                 INTO w_nasegur
                 FROM riesgos
                WHERE sseguro = psseguro
                  AND nriesgo = reggar.nriesgo;

               w_iprianu := w_iprianu * w_nasegur;
               w_icapital := w_icapital * w_nasegur;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  codi_error := 103836;
                  RETURN(codi_error);
               WHEN OTHERS THEN
                  codi_error := 103509;
                  RETURN(codi_error);
            END;
         END IF;

         ---------     BUSQUEM SI EL RISC FORMA PART D'UN CUMUL...
         w_scumulo := NULL;

         BEGIN
            SELECT scumulo
              INTO w_scumulo
              FROM reariesgos
             WHERE ROWNUM = 1
               AND sseguro = psseguro
               AND nriesgo = reggar.nriesgo
               AND cgarant = reggar.cgarant
               AND fini >= freaini
               AND(fini < freafin
                   OR freafin IS NULL)
               AND scumulo IS NOT NULL;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT scumulo
                    INTO w_scumulo
                    FROM reariesgos
                   WHERE ROWNUM = 1
                     AND sseguro = psseguro
                     AND nriesgo = reggar.nriesgo
                     AND cgarant IS NULL
                     AND fini >= freaini
                     AND(fini < freafin
                         OR freafin IS NULL)
                     AND scumulo IS NOT NULL;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     NULL;
                  WHEN OTHERS THEN
                     codi_error := 104665;
                     RETURN(codi_error);
               END;
            WHEN OTHERS THEN
               codi_error := 104665;
               RETURN(codi_error);
         END;

         ----------     BUSQUEM SI HI HA ALGUN RISC, GARANTIA O CUMUL A "PIÑÓN FIJO"...
         w_scontra := NULL;
         w_nversio := NULL;

         BEGIN
            SELECT scontra, nversio
              INTO w_scontra, w_nversio
              FROM reariesgos
             WHERE ROWNUM = 1
               AND sseguro = psseguro
               AND nriesgo = reggar.nriesgo
               AND cgarant = reggar.cgarant
               AND nversio IS NOT NULL
               AND fini >= freaini
               AND fini < NVL(freafin, TO_DATE('31/12/3000', 'DD/MM/YYYY'));
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT scontra, nversio
                    INTO w_scontra, w_nversio
                    FROM reariesgos
                   WHERE ROWNUM = 1
                     AND sseguro = psseguro
                     AND nriesgo = reggar.nriesgo
                     AND cgarant IS NULL
                     AND nversio IS NOT NULL
                     AND fini >= freaini
                     AND fini < NVL(freafin, TO_DATE('31/12/3000', 'DD/MM/YYYY'));
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                        IF w_scumulo IS NOT NULL THEN
                           SELECT scontra, nversio
                             INTO w_scontra, w_nversio
                             FROM reariesgos
                            WHERE ROWNUM = 1
                              AND scumulo = w_scumulo
                              AND nversio IS NOT NULL
                              AND fini >= freaini
                              AND fini < NVL(freafin, TO_DATE('31/12/3000', 'DD/MM/YYYY'));
                        END IF;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           NULL;
                        WHEN OTHERS THEN
                           codi_error := 104666;
                           RETURN(codi_error);
                     END;
                  WHEN OTHERS THEN
                     codi_error := 104666;
                     RETURN(codi_error);
               END;
            WHEN OTHERS THEN
               codi_error := 104666;
               RETURN(codi_error);
         END;

--------------
         IF NVL(w_iprianu, 0) <> 0
            OR NVL(w_icapital, 0) <> 0 THEN
            w_cestado := 0;
            w_nnumlin := w_nnumlin + 1;

            BEGIN
               INSERT INTO cesionesaux
                           (sproces, nnumlin, sseguro, iprirea,
                            icapital, cestado, cfacult, nriesgo,
                            nmovimi, cgarant, scontra, fconini, fconfin, nversio,
                            scumulo, nagrupa)
                    VALUES (psproces, w_nnumlin, psseguro, NVL(w_iprianu, 0),
                            NVL(w_icapital, 0), w_cestado, w_cfacult, reggar.nriesgo,
                            pnmovimi, reggar.cgarant, w_scontra, fini, ffin, w_nversio,
                            w_scumulo, NULL);
            EXCEPTION
               WHEN OTHERS THEN
                  codi_error := 104667;
                  RETURN(codi_error);
            END;
         END IF;
      END IF;
   END LOOP;

   --  AQUÍ SE CREA LA PARTE CORRESPONDIENTE AL MOVIMIENTO DE REGULARIZACION...
   IF fini IS NOT NULL
      AND ffin IS NOT NULL THEN
      codi_error := f_regul(fini, ffin);

      IF codi_error <> 0 THEN
         RETURN(codi_error);
      END IF;

      codi_error := f_busca(psseguro, pnmovimi, psproces, 20);

      IF codi_error <> 0
         AND codi_error <> 99 THEN
         RETURN(codi_error);
      ELSIF codi_error = 99 THEN
         codi_error := 0;
      ELSE
         codi_error := f_cessio(psproces, 20,
                                 -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                --2
                                pmoneda
                                       -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                      );

         IF codi_error <> 0 THEN
            RETURN(codi_error);
         END IF;
      END IF;
   END IF;

   RETURN(codi_error);
END f_regula2;

/

  GRANT EXECUTE ON "AXIS"."F_REGULA2" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_REGULA2" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_REGULA2" TO "PROGRAMADORESCSI";
