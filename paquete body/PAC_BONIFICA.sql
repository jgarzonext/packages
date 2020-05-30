--------------------------------------------------------
--  DDL for Package Body PAC_BONIFICA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_BONIFICA" IS
   /******************************************************************************
      NOMBRE:     PAC_BONIFICA
      PROPÓSITO:  Càlculs de la bonificació.

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        XX/XX/XXXX   XXX                1. Creación del package.
      2.0        04/06/2009   RSC                2. Bug 10350: APR - Detalle garantías (tarificación)
      3.0        02/11/2009  APD                 3. Bug 11595: CEM - Siniestros. Adaptación al nuevo módulo de siniestros
   ******************************************************************************/
   FUNCTION f_bonifica_poliza(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psseguro IN NUMBER,
      pfcaranu IN DATE,
      pfefecto IN DATE,
      ppercent OUT NUMBER,
      paplica_bonifica OUT NUMBER)
      RETURN NUMBER IS
      /******************************************************************
      Càlcul de la bonificació de les pòlisses que renoven en data fcaranu
      *******************************************************************/
      lsinis         NUMBER;
      lporcen        NUMBER;
      num_err        NUMBER;
      lsproduc       NUMBER;
      lcvalpar       NUMBER;
      lbonifi        NUMBER;
      lbonifiman     NUMBER;
      v_cempres      NUMBER;
   BEGIN
      paplica_bonifica := 0;

      -- Obtenim sproduc
      BEGIN
         SELECT sproduc
           INTO lsproduc
           FROM productos
          WHERE cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 102705;
      END;

      num_err := 0;
      ppercent := 0;
      -- Comprovar si el producte te bonificació
      num_err := f_parproductos(lsproduc, 'BONIFICACION', lcvalpar);

      IF num_err = 0 THEN
         IF NVL(lcvalpar, 0) = 1 THEN
            paplica_bonifica := 1;
            -- El producte contempla la bonificació
            -- Obtenir si ja se li ha calculat la bonificació
            num_err := f_obte_bonifica(psseguro, pfcaranu, lbonifi, lbonifiman);

            IF num_err = 0 THEN
               -- Si te bonificació manual ja no cal calcular
               IF lbonifiman IS NOT NULL THEN
                  ppercent := lbonifiman;
               ELSE
                  -- Per cada anualitat veure si te bonificació.
                  -- Ens quedem amb la més gran
                  lporcen := 0;

                  FOR v_boni IN (SELECT   pbonifi, nanudes
                                     FROM bonificaprod
                                    WHERE sproduc = lsproduc
                                      AND nanudes < MONTHS_BETWEEN(pfcaranu, pfefecto) / 12 + 1
                                 ORDER BY nanudes) LOOP
                     -- Veure si existeixen sinistres per el rang d'anualitats
                     -- sempre que la pòlissa existis

                     -- BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
                     SELECT cempres
                       INTO v_cempres
                       FROM seguros
                      WHERE sseguro = psseguro;

                     IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
                        SELECT COUNT(*)
                          INTO lsinis
                          FROM siniestros
                         WHERE sseguro = psseguro
                           AND fsinies >= ADD_MONTHS(pfcaranu, -v_boni.nanudes * 12)
                           AND cestsin = 1
                           AND EXISTS(SELECT nsinies
                                        FROM pagosini
                                       WHERE nsinies = siniestros.nsinies
                                         AND isinret <> 0);
                     ELSE
                        SELECT COUNT(*)
                          INTO lsinis
                          FROM sin_siniestro s, sin_movsiniestro m
                         WHERE s.sseguro = psseguro
                           AND s.fsinies >= ADD_MONTHS(pfcaranu, -v_boni.nanudes * 12)
                           AND s.nsinies = m.nsinies
                           AND m.nmovsin = (SELECT MAX(nmovsin)
                                              FROM sin_movsiniestro
                                             WHERE nsinies = s.nsinies)
                           AND m.cestsin = 1
                           AND EXISTS(SELECT nsinies
                                        FROM sin_tramita_pago
                                       WHERE nsinies = s.nsinies
                                         AND isinret <> 0);
                     END IF;

                     -- Fin BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
                     IF lsinis <> 0 THEN
                        EXIT;
                     ELSE
                        lporcen := v_boni.pbonifi;
                     END IF;
                  END LOOP;

                  IF lporcen IS NOT NULL THEN
                     BEGIN
                        INSERT INTO bonificaseg
                                    (sseguro, fcaranu, pbonifi)
                             VALUES (psseguro, pfcaranu, lporcen);
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           UPDATE bonificaseg
                              SET pbonifi = lporcen
                            WHERE sseguro = psseguro
                              AND fcaranu = pfcaranu;
                        WHEN OTHERS THEN
                           num_err := 110292;
                     END;
                  END IF;

                  ppercent := lporcen;
               END IF;
            END IF;
         END IF;
      END IF;

      RETURN num_err;
   END f_bonifica_poliza;

---------------------------------
   FUNCTION f_obte_bonifica(
      psseguro IN NUMBER,
      pfcaranu IN DATE,
      ppbonifi OUT NUMBER,
      ppbonifiman OUT NUMBER)
      RETURN NUMBER IS
      /********************************************************************************
       Retorna el percentatge de bonificació, null si no en te
      ********************************************************************************/
      num_err        NUMBER;
      lpbonifi       NUMBER;
      lpbonifiman    NUMBER;
   BEGIN
      num_err := 0;

      -- Veure si te bonificació per aquesta renovació
      BEGIN
         SELECT pbonifi, pbonifiman
           INTO ppbonifi, ppbonifiman
           FROM bonificaseg
          WHERE sseguro = psseguro
            AND fcaranu = pfcaranu;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            ppbonifi := NULL;
            ppbonifiman := NULL;
         WHEN OTHERS THEN
            num_err := 110299;
      END;

      RETURN num_err;
   END f_obte_bonifica;

------------------------------------------------------------------
   FUNCTION calcul_bonificacio_actual(
      psseguro IN NUMBER,
      psproces IN NUMBER,
      pnmovimi IN NUMBER,
      pnmovimi_ant OUT NUMBER)
      RETURN NUMBER IS
      lbonificacio_actual NUMBER;
      lprima_actual  NUMBER;
      lprima_anterior NUMBER;
      lnmovimi       NUMBER;
   BEGIN
      lbonificacio_actual := 1;   --Si

      IF pnmovimi IS NULL THEN
         SELECT MAX(nmovimi) + 1
           INTO lnmovimi
           FROM movseguro
          WHERE sseguro = psseguro;
      ELSE
         lnmovimi := pnmovimi;
      END IF;

      SELECT MAX(nmovimi)
        INTO pnmovimi_ant
        FROM movseguro
       WHERE sseguro = psseguro
         AND nmovimi < lnmovimi
         AND cmovseg IN(0, 2);

      --DBMS_OUTPUT.put_line(' mov anterior ' || pnmovimi_ant);
      SELECT SUM(iprianu)
        INTO lprima_actual
        FROM garancar
       WHERE sseguro = psseguro
         AND sproces = psproces;

      --DBMS_OUTPUT.put_line(' PRIMA ACTUAL ' || lprima_actual);
      SELECT SUM(iprianu)
        INTO lprima_anterior
        FROM garanseg
       WHERE sseguro = psseguro
         AND nmovimi = pnmovimi_ant;

      --DBMS_OUTPUT.put_line(' PRIMA ANTERIOR ' || lprima_anterior);
      IF lprima_anterior = 0 THEN
         -- Si la prima anterior és 0, agaferem la del últim moviment, degut a que falten primes
         -- a l'historic de la migració
         --DBMS_OUTPUT.put_line(' ES ZERO ');
         SELECT MAX(nmovimi)
           INTO pnmovimi_ant
           FROM garanseg
          WHERE sseguro = psseguro
            AND ffinefe IS NULL;

         --DBMS_OUTPUT.put_line(' NOU CALCULA DE MOVIMENT ANT  ' || pnmovimi_ant);
         SELECT SUM(iprianu)
           INTO lprima_anterior
           FROM garanseg
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi_ant;
      --DBMS_OUTPUT.put_line('  NOU CALCUL DE PRIMA ANT  ' || lprima_anterior);
      END IF;

      IF lprima_actual IS NOT NULL
         AND lprima_anterior IS NOT NULL THEN
         IF lprima_actual <= lprima_anterior THEN
            lbonificacio_actual := 1;   --Si
         ELSE
            lbonificacio_actual := 0;   --No
         END IF;
      END IF;

      RETURN lbonificacio_actual;
   END calcul_bonificacio_actual;

   FUNCTION calcul_prima_ant(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pndetgar IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      liprianu       NUMBER;
      -- Bug 10350 - 04/06/2009 - RSC - Detalle garantías (tarificación)
      v_sproduc      seguros.sproduc%TYPE;
      v_num_err      NUMBER;
   -- Fin Bug 10350
   BEGIN
      -- Bug 10350 - 04/06/2009 - RSC - Detalle garantías (tarificación)
      v_num_err := pac_productos.f_get_sproduc(psseguro, v_sproduc);

      IF v_num_err <> 0 THEN
         liprianu := NULL;
      END IF;

      -- Fin Bug 10350

      -- Bug 10350 - 04/06/2009 - RSC - Detalle garantías (tarificación)
      IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) = 1 THEN
         BEGIN
            SELECT iprianu
              INTO liprianu
              FROM detgaranseg
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi
               AND nriesgo = pnriesgo
               AND cgarant = pcgarant
               AND ndetgar = pndetgar;
         EXCEPTION
            WHEN OTHERS THEN
               liprianu := NULL;
         END;
      ELSE
         -- Fin Bug 10350
         BEGIN
            SELECT iprianu
              INTO liprianu
              FROM garanseg
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi
               AND nriesgo = pnriesgo
               AND cgarant = pcgarant;
         EXCEPTION
            WHEN OTHERS THEN
               liprianu := NULL;
         END;
      END IF;

      RETURN liprianu;
   END calcul_prima_ant;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_BONIFICA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_BONIFICA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_BONIFICA" TO "PROGRAMADORESCSI";
