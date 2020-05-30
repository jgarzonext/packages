--------------------------------------------------------
--  DDL for Function F_ESTDETRECIBO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ESTDETRECIBO" (
   pnproces IN NUMBER,
   psseguro IN NUMBER,
   pnrecibo IN NUMBER,
   ptipomovimiento IN NUMBER,
   pmodo IN VARCHAR2,
   pcmodcom IN NUMBER,
   pfmovini IN DATE,
   pfefecto IN DATE,
   pfvencim IN DATE,
   pfcaranu IN DATE,
   pnimport IN NUMBER,
   pnriesgo IN NUMBER,
   pnmovimi IN NUMBER,
   pcpoliza IN NUMBER,
   pnimport2 OUT NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
--
-- ALLIBADM. OBTÉ EL DESGLÒS PER RISC I GARANTIA DE CADASCUN
-- DELS CONCEPTES QUE FORMEN UN REBUT. L' ORIGEN DE LA INFORMACIÓ SÓN LES
-- GARANTIES QUE TÉ L' ASSEGURANÇA AMB ELS SEUS CAPITALS I PRIMES.
--
-- S' HA TRET EL CÀLCUL DEL CONCEPTE 9 (DESCOMPTE TÈCNIC).
-- PER A VEURE SI S' APLICA EL RECÀRREC PER FRACCIONAMENT, MIREM
-- TAMBÉ EL CAMP CRECFRA, DE LA TAULA SEGUROS. TAMBÉ ALTRES MODIFICACIONS
-- PER LA TAULA GARANCAR.
-- EN EL CAS DE PROVES = 'P', NOMÉS EN EL TIPUS DE MOVIMENT = 21
-- ACCEDIREM A GARANCAR; EN ELS ALTRES CASOS, ACCEDIREM A
-- GARANSEG / GARANCOLEC (DEPENENT DE SI EL PRODUCTE ÉS INNOMINAT O NO).
--
--
--  S' AFEGEIX FUNCIÓ F_VDETRECIBO PER OMPLIR TAULA VDETRECIBOS I
-- CÀLCUL DE L' IMPOST FNG.
--
--
   error          NUMBER := 0;
   num_err        NUMBER := 0;
   num_err2       NUMBER := 0;
   xnprolin       NUMBER;
   xcmodali       NUMBER;
   xccolect       NUMBER;
   xcramo         NUMBER;
   xctipseg       NUMBER;
   xcgarant       NUMBER;
   xnriesgo       NUMBER;
   xfiniefe       DATE;
   xnorden        NUMBER;
   xctarifa       NUMBER;
   xicapital      NUMBER;
   xprecarg       NUMBER;
   xiprianu       NUMBER;
   xfinefe        DATE;
   xcformul       NUMBER;
   xiextrap       NUMBER;
   xctipfra       NUMBER;
   xifranqu       NUMBER;
   xcagente       NUMBER;
   xnmovimi       NUMBER;
   xnmovimiant    NUMBER;
   xcforpag       NUMBER;
   xcrecfra       NUMBER;
   xpdtoord       NUMBER;
   difdias        NUMBER;
   difdiasanu     NUMBER;
   grabar         NUMBER;
   decimals       NUMBER := 0;
   xcconcep       NUMBER;
   xiconcep       NUMBER;
   difiprianu     NUMBER;
   difcapital     NUMBER;
   xcimpcon       NUMBER;
   xcimpdgs       NUMBER;
   xcimpips       NUMBER;
   xcimpcom       NUMBER;
   xcimpces       NUMBER;
   xcimparb       NUMBER;
   xcimpfng       NUMBER;
   xiatribu       NUMBER;
   xcconcep       NUMBER;
   xnanuali       NUMBER;
   xnfracci       NUMBER;
   iconcep0       NUMBER;
-- ICONCEP9  NUMBER;
   tot_iconcepdgs NUMBER;
   tot_iconcepips NUMBER;
   tot_iconceparb NUMBER;
   tot_iconcepfng NUMBER;
   taxadgs        NUMBER;
   taxaips        NUMBER;
   taxacon        NUMBER;
   taxaces        NUMBER;
   taxaarb        NUMBER;
   taxafng        NUMBER;
   totrecfracc    NUMBER;
   comis_agente   NUMBER := 0;
   reten_agente   NUMBER := 0;
   comis_calc     NUMBER;
   pnprocesin     NUMBER := pnproces;
   pcaplica       NUMBER;
   xfemisio       DATE;
   xfvencim       DATE;
   xiprianu2      NUMBER;
   reten_calc     NUMBER;
   dummy          DATE;
   xxcgarant      NUMBER;
   xxnriesgo      NUMBER;
   xxfiniefe      DATE;
   xxiprianu      NUMBER;
   xxffinefe      DATE;
   xxiconcep      NUMBER;
   xtotprimaneta  NUMBER;
   ha_grabat      BOOLEAN := FALSE;
   xcactivi       NUMBER;
   xcduraci       NUMBER;
   xnduraci       NUMBER;
   pgrabar        NUMBER;
   xidtocom       NUMBER;
   xidtocom2      NUMBER;
   xxidtocom      NUMBER;
   difidtocom     NUMBER;
   xndurcob       NUMBER;
   xnmeses        NUMBER;
   xfcaranu       DATE;
   xnimpcom       NUMBER;
   xnimpret       NUMBER;
   xccomisi       NUMBER;
   xcretenc       NUMBER;
   xcsituac       NUMBER;
   xccalcom       NUMBER;
   xcmotmov       NUMBER;
   xaltarisc      BOOLEAN;
   xinsert        BOOLEAN;
   xnmovima       NUMBER;

-- *************************
-- CURSORES PARA PMODO = 'R'
-- *************************
   -- CURSORES PARA GARANSEG
   -- **********************
   CURSOR cur_garanseg IS
      SELECT cgarant, nriesgo, finiefe, norden, ctarifa, NVL(icapital, 0), precarg,
             NVL(iprianu, 0), ffinefe, cformul, iextrap, ctipfra, ifranqu, nmovimi, idtocom
        FROM estgaranseg
       WHERE sseguro = psseguro
         AND nriesgo = NVL(pnriesgo, nriesgo)
         AND nmovimi = pnmovimi;

   CURSOR cur_garansegant IS
      SELECT cgarant, nriesgo, finiefe, norden, ctarifa, NVL(icapital, 0), precarg,
             NVL(iprianu, 0), ffinefe, cformul, iextrap, ctipfra, ifranqu, nmovimi, idtocom
        FROM estgaranseg
       WHERE sseguro = psseguro
         AND nriesgo = NVL(pnriesgo, nriesgo)
         AND nmovimi = xnmovimiant;

   CURSOR cur_detrecibos IS
      SELECT   nriesgo, cgarant
          FROM detrecibos
         WHERE nrecibo = pnrecibo
      GROUP BY cgarant, nriesgo;

-- *************************
-- CURSORES PARA PMODO = 'P'
-- *************************
   CURSOR cur_garancar IS
      SELECT cgarant, nriesgo, finiefe, norden, ctarifa, NVL(icapital, 0), precarg,
             NVL(iprianu, 0), ffinefe, cformul, iextrap, idtocom
        FROM garancar
       WHERE sproces = pnproces
         AND sseguro = psseguro
         AND nriesgo = NVL(pnriesgo, nriesgo)
         AND TRUNC(pfefecto) >= TRUNC(finiefe)
         AND((TRUNC(pfefecto) < TRUNC(ffinefe))
             OR(ffinefe IS NULL));

   CURSOR cur_detreciboscar IS
      SELECT   nriesgo, cgarant
          FROM detreciboscar
         WHERE sproces = pnproces
           AND nrecibo = pnrecibo
           AND nriesgo = NVL(pnriesgo, nriesgo)
      GROUP BY nriesgo, cgarant;
BEGIN
   -- COMPROBEM SI EXISTEIX L' ASSEGURANÇA ENTRADA COM A PARÀMETRE
   BEGIN
      SELECT cforpag, crecfra, pdtoord, cagente, femisio, fvencim, cmodali, ccolect,
             cramo, ctipseg, pac_seguros.ff_get_actividad(sseguro, pnriesgo, 'EST'), cduraci,
             nduraci, ndurcob, csituac
        INTO xcforpag, xcrecfra, xpdtoord, xcagente, xfemisio, xfvencim, xcmodali, xccolect,
             xcramo, xctipseg, xcactivi, xcduraci,
             xnduraci, xndurcob, xcsituac
        FROM estseguros
       WHERE sseguro = psseguro;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         num_err := 101903;   -- SEGURO NO ENCONTRADO EN LA TABLA SEGUROS
         RETURN num_err;
      WHEN OTHERS THEN
         num_err := 101919;   -- ERROR AL LLEGIR DADES DE LA TAULA SEGUROS
         RETURN num_err;
   END;

   IF pmodo = 'N' THEN   -- ESTEM EN EL CAS DE REBUT PREVI (ANUAL)
      xcforpag := 1;
   END IF;

   xfvencim := pfvencim;

   IF xcforpag <> 0 THEN   -- FORMA DE PAGAMENT NO ÚNICA
      IF pfcaranu IS NOT NULL THEN
         num_err := f_difdata(pfefecto, xfvencim, 3, 3, difdias);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         num_err := f_difdata(pfefecto, pfcaranu, 3, 3, difdiasanu);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      ELSE   -- PFCARANU ES NULL
         IF xndurcob IS NULL THEN
            RETURN 104515;   -- EL CAMP NDURCOB DE SEGUROS HA DE ESTAR INFORMAT
         END IF;

         xnmeses := (xndurcob + 1) * 12;
         xfcaranu := ADD_MONTHS(pfefecto, xnmeses);

         IF xfvencim IS NULL THEN
            xfvencim := xfcaranu;
         END IF;

         num_err := f_difdata(pfefecto, xfvencim, 3, 3, difdias);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         num_err := f_difdata(pfefecto, xfcaranu, 3, 3, difdiasanu);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;
   ELSE   -- = 0, FORMA DE PAGO ÚNICA
      num_err := f_difdata(pfefecto, xfvencim, 3, 3, difdias);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      num_err := f_difdata(pfefecto, xfvencim, 3, 3, difdiasanu);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;
   END IF;

-------EST
--   ERROR := F_BUSCANMOVIMI(PSSEGURO, 1, 1, XNMOVIMIANT);
   xnmovimiant := 1;
   error := 0;

   IF error <> 0 THEN
      RETURN error;
   END IF;

   BEGIN
      SELECT ccalcom
        INTO xccalcom
        FROM productos
       WHERE cramo = xcramo
         AND cmodali = xcmodali
         AND ctipseg = xctipseg
         AND ccolect = xccolect;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 104347;   -- PRODUCTE NO TROBAT A PRODUCTOS
      WHEN OTHERS THEN
         RETURN 102705;   -- ERROR AL LLEGIR DE PRODUCTOS
   END;

   IF xccalcom = 1 THEN   -- SOBRE PRIMA
      num_err := f_pcomisi(NULL, pcmodcom, F_SYSDATE, comis_agente, reten_agente, xcagente,
                           xcramo, xcmodali, xctipseg, xccolect, xcactivi);

      IF num_err <> 0 THEN
         xnprolin := NULL;
         num_err2 := f_proceslin(pnproces,
                                 'ERROR = ' || 'FPCOMISI(' || ' PCMODCOM=' || pcmodcom
                                 || ' PNRECIBO=' || pnrecibo || ' PCOMISI=' || comis_agente
                                 || ' PRETENC=' || reten_agente || ')',
                                 psseguro, xnprolin);

         IF num_err2 <> 0 THEN
            RETURN num_err2;
         END IF;

         RETURN num_err;
      END IF;
   ELSIF xccalcom = 2 THEN   -- SOBRE INTERÉS
      comis_agente := 0;
      reten_agente := 0;
   END IF;

   IF pnmovimi IS NOT NULL THEN
      xaltarisc := FALSE;
   END IF;

--***************************************************************************
   IF pmodo = 'P' THEN   -- PROVES (AVANÇ CARTERA)
      IF ptipomovimiento = 21 THEN
         OPEN cur_garancar;

         FETCH cur_garancar
          INTO xcgarant, xnriesgo, xfiniefe, xnorden, xctarifa, xicapital, xprecarg, xiprianu,
               xfinefe, xcformul, xiextrap, xidtocom;

         WHILE cur_garancar%FOUND LOOP
            xidtocom := 0 - NVL(xidtocom, 0);

            IF xcforpag = 0 THEN
               xiprianu2 := ROUND(xiprianu, decimals);
               xidtocom2 := ROUND(xidtocom, decimals);
            ELSE
               xiprianu2 := ROUND(xiprianu / xcforpag, decimals);
               xidtocom2 := ROUND(xidtocom / xcforpag, decimals);
            END IF;

            BEGIN
               IF NVL(xiprianu2, 0) <> 0 THEN
                  -- PRIMA NETA
                  INSERT INTO detreciboscar
                              (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                       VALUES (pnproces, pnrecibo, 0, xiprianu2, xcgarant, xnriesgo);

                  ha_grabat := TRUE;
               END IF;

               IF xidtocom2 <> 0
                  AND xidtocom2 IS NOT NULL THEN
                  -- DTE. COMERCIAL
                  INSERT INTO detreciboscar
                              (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                       VALUES (pnproces, pnrecibo, 10, xidtocom2, xcgarant, xnriesgo);

                  ha_grabat := TRUE;
               END IF;

               -- PRIMA DEVENGADA
               xiprianu := ROUND(xiprianu, decimals);

               IF NVL(xiprianu, 0) <> 0 THEN
                  INSERT INTO detreciboscar
                              (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                       VALUES (pnproces, pnrecibo, 21, xiprianu, xcgarant, xnriesgo);

                  ha_grabat := TRUE;
               END IF;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  CLOSE cur_garancar;

                  num_err := 102312;   -- REGISTRE DUPLICAT A DETRECIBOSCAR
                  RETURN num_err;
               WHEN OTHERS THEN
                  CLOSE cur_garancar;

                  num_err := 103517;   -- ERROR A L' INSERIR A DETRECIBOSCAR
                  RETURN num_err;
            END;

            FETCH cur_garancar
             INTO xcgarant, xnriesgo, xfiniefe, xnorden, xctarifa, xicapital, xprecarg,
                  xiprianu, xfinefe, xcformul, xiextrap, xidtocom;
         END LOOP;

         CLOSE cur_garancar;
      ELSIF ptipomovimiento IN(0, 1, 6, 22) THEN
-- COMENCEM AMB LA TAULA GARANSEG
-- ******************************
         OPEN cur_garanseg;

         FETCH cur_garanseg
          INTO xcgarant, xnriesgo, xfiniefe, xnorden, xctarifa, xicapital, xprecarg, xiprianu,
               xfinefe, xcformul, xiextrap, xctipfra, xifranqu, xnmovimi, xidtocom;

         WHILE cur_garanseg%FOUND LOOP
            xidtocom := 0 - NVL(xidtocom, 0);

            -- COMPROBEM SI HI HA MÉS D'UN REGISTRE PEL MATEIX CGARANT-NRIESGO-
            -- NMOVIMI-FINIEFE
            BEGIN
               SELECT finiefe
                 INTO dummy
                 FROM estgaranseg
                WHERE sseguro = psseguro
                  AND cgarant = xcgarant
                  AND nriesgo = xnriesgo
                  AND nmovimi = xnmovimi
                  AND finiefe = xfiniefe;
            EXCEPTION
               WHEN TOO_MANY_ROWS THEN
                  CLOSE cur_garanseg;

                  num_err := 102310;   -- GARANTIA-RISC REPETIDA EN GARANSEG
                  RETURN num_err;
               WHEN OTHERS THEN
                  CLOSE cur_garanseg;

                  num_err := 103500;   -- ERROR AL LLEGIR DE GARANSEG
                  RETURN num_err;
            END;

            -- FASE 1: CÀLCUL DE LA PRIMA NETA (CCONCEP = 0) Y DE LA PRIMA
            -- DEVENGADA (FASE 2).
            IF ptipomovimiento IN(0, 22) THEN
               BEGIN
                  IF xcforpag = 0 THEN
                     xiprianu2 := ROUND(xiprianu, decimals);
                     xidtocom2 := ROUND(xidtocom, decimals);
                  ELSE
                     xiprianu2 := ROUND(xiprianu / xcforpag, decimals);
                     xidtocom2 := ROUND(xidtocom / xcforpag, decimals);
                  END IF;

                  IF NVL(xiprianu2, 0) <> 0 THEN
                     -- PRIMA NETA
                     INSERT INTO detreciboscar
                                 (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                          VALUES (pnproces, pnrecibo, 0, xiprianu2, xcgarant, xnriesgo);

                     ha_grabat := TRUE;
                  END IF;

                  IF xidtocom2 <> 0
                     AND xidtocom2 IS NOT NULL THEN
                     -- DTE. TÈCNIC
                     INSERT INTO detreciboscar
                                 (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                          VALUES (pnproces, pnrecibo, 10, xidtocom2, xcgarant, xnriesgo);

                     ha_grabat := TRUE;
                  END IF;

                  -- PRIMA DEVENGADA
                  IF ptipomovimiento = 0 THEN
                     xiprianu := ROUND(xiprianu, decimals);

                     IF NVL(xiprianu, 0) <> 0 THEN
                        INSERT INTO detreciboscar
                                    (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                             VALUES (pnproces, pnrecibo, 21, xiprianu, xcgarant, xnriesgo);

                        ha_grabat := TRUE;
                     END IF;
                  END IF;
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     CLOSE cur_garanseg;

                     num_err := 102309;   -- REGISTRE DUPLICAT EN DETRECIBOSCAR
                     RETURN num_err;
                  WHEN OTHERS THEN
                     CLOSE cur_garanseg;

                     num_err := 103517;   -- ERROR A L' INSERIR A DETRECIBOSCAR
                     RETURN num_err;
               END;
            ELSIF ptipomovimiento = 1 THEN   -- SUPLEMENTS
               BEGIN
                  xxcgarant := NULL;
                  xxnriesgo := NULL;
                  xxfiniefe := NULL;
                  xxiprianu := NULL;
                  xxffinefe := NULL;
                  xxidtocom := NULL;

                  SELECT cgarant, nriesgo, finiefe, iprianu, ffinefe, idtocom
                    INTO xxcgarant, xxnriesgo, xxfiniefe, xxiprianu, xxffinefe, xxidtocom
                    FROM estgaranseg
                   WHERE sseguro = psseguro
                     AND cgarant = xcgarant
                     AND nriesgo = xnriesgo
                     AND nmovimi = xnmovimiant;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     NULL;   -- NO HI HA GARANTIA ANTERIOR
                  WHEN TOO_MANY_ROWS THEN
                     CLOSE cur_garanseg;

                     num_err := 102310;   -- GARANTIA-RISC REPETIDA EN GARANSEG
                     RETURN num_err;
                  WHEN OTHERS THEN
                     CLOSE cur_garanseg;

                     num_err := 103500;   -- ERROR AL LLEGIR DE GARANSEG
                     RETURN num_err;
               END;

               xxidtocom := 0 - NVL(xxidtocom, 0);
               difiprianu := xiprianu - NVL(xxiprianu, 0);
               difidtocom := NVL(xidtocom, 0) - NVL(xxidtocom, 0);
               xinsert := TRUE;

               IF xaltarisc THEN   -- ES UN SUPLEMENT DE ALTA
                  BEGIN
                     SELECT nmovima
                       INTO xnmovima
                       FROM estriesgos
                      WHERE sseguro = psseguro
                        AND nriesgo = xnriesgo
                        AND nmovima = pnmovimi;

                     xinsert := TRUE;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        xinsert := FALSE;
                     WHEN OTHERS THEN
                        CLOSE cur_garanseg;

                        RETURN 103509;   -- ERROR AL LLEGIR DE RIESGOS
                  END;
               END IF;

               IF xinsert THEN
                  BEGIN
                     xiconcep := ROUND((difdias * difiprianu) / 360, decimals);

                     IF NVL(xiconcep, 0) <> 0 THEN
                        -- PRIMA NETA
                        INSERT INTO detreciboscar
                                    (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                             VALUES (pnproces, pnrecibo, 0, xiconcep, xcgarant, xnriesgo);

                        ha_grabat := TRUE;
                     END IF;

                     xiconcep := ROUND((difdias * difidtocom) / 360, decimals);

                     IF xiconcep <> 0
                        AND xiconcep IS NOT NULL THEN
                        -- PRIMA NETA
                        INSERT INTO detreciboscar
                                    (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                             VALUES (pnproces, pnrecibo, 10, xiconcep, xcgarant, xnriesgo);

                        ha_grabat := TRUE;
                     END IF;

                     -- PRIMA DEVENGADA
                     xiconcep := ROUND((difdiasanu * difiprianu) / 360, decimals);

                     IF NVL(xiconcep, 0) <> 0 THEN
                        INSERT INTO detreciboscar
                                    (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                             VALUES (pnproces, pnrecibo, 21, xiconcep, xcgarant, xnriesgo);

                        ha_grabat := TRUE;
                     END IF;
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        CLOSE cur_garanseg;

                        num_err := 102309;   -- REGISTRE DUPLICAT EN DETRECIBOSCAR
                        RETURN num_err;
                     WHEN OTHERS THEN
                        CLOSE cur_garanseg;

                        num_err := 103517;   -- ERROR A L' INSERIR A DETRECIBOSCAR
                        RETURN num_err;
                  END;
               END IF;
            END IF;

            FETCH cur_garanseg
             INTO xcgarant, xnriesgo, xfiniefe, xnorden, xctarifa, xicapital, xprecarg,
                  xiprianu, xfinefe, xcformul, xiextrap, xctipfra, xifranqu, xnmovimi,
                  xidtocom;
         END LOOP;

         CLOSE cur_garanseg;

         IF ptipomovimiento = 1 THEN
            -- ARA BUSCAREM LES GARANTIES QUE ESTAVEN EN (FEFECTO-1) I ARA NO ESTAN
            OPEN cur_garansegant;

            FETCH cur_garansegant
             INTO xcgarant, xnriesgo, xfiniefe, xnorden, xctarifa, xicapital, xprecarg,
                  xiprianu, xfinefe, xcformul, xiextrap, xctipfra, xifranqu, xnmovimi,
                  xidtocom;

            WHILE cur_garansegant%FOUND LOOP
               xidtocom := 0 - NVL(xidtocom, 0);

               -- COMPROBEM SI HI HA MÉS D'UN REGISTRE PEL MATEIX CGARANT-NRIESGO
               -- NMOVIMI-FINIEFE
               BEGIN
                  SELECT finiefe
                    INTO dummy
                    FROM estgaranseg
                   WHERE sseguro = psseguro
                     AND cgarant = xcgarant
                     AND nriesgo = xnriesgo
                     AND nmovimi = xnmovimi;
               EXCEPTION
                  WHEN TOO_MANY_ROWS THEN
                     CLOSE cur_garansegant;

                     num_err := 102310;   -- GARANTIA-RISC REPETIDA EN GARANSEG
                     RETURN num_err;
                  WHEN OTHERS THEN
                     CLOSE cur_garansegant;

                     num_err := 103500;   -- ERROR AL LLEGIR DE GARANSEG
                     RETURN num_err;
               END;

               BEGIN
                  grabar := 0;
                  xxcgarant := NULL;
                  xxnriesgo := NULL;
                  xxfiniefe := NULL;
                  xxiprianu := NULL;
                  xxffinefe := NULL;
                  xxidtocom := NULL;

                  SELECT cgarant, nriesgo, finiefe, iprianu, ffinefe, idtocom
                    INTO xxcgarant, xxnriesgo, xxfiniefe, xxiprianu, xxffinefe, xxidtocom
                    FROM estgaranseg
                   WHERE sseguro = psseguro
                     AND cgarant = xcgarant
                     AND nriesgo = xnriesgo
                     AND nmovimi = pnmovimi;

                  xxidtocom := 0 - NVL(xxidtocom, 0);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     grabar := 1;   -- ÉS UNA GARANTIA DESAPAREGUDA
                  WHEN TOO_MANY_ROWS THEN
                     CLOSE cur_garansegant;

                     num_err := 102310;   -- GARANTIA-RISC REPETIDA EN GARANSEG
                     RETURN num_err;
                  WHEN OTHERS THEN
                     CLOSE cur_garansegant;

                     num_err := 103500;   -- ERROR AL LLEGIR DE GARANSEG
                     RETURN num_err;
               END;

               IF grabar = 1 THEN
                  difiprianu := 0 - xiprianu;

                  IF difiprianu <> 0 THEN
                     BEGIN
                        -- PRIMA NETA
                        xiconcep := ROUND((difdias * difiprianu) / 360, decimals);

                        IF NVL(xiconcep, 0) <> 0 THEN
                           INSERT INTO detreciboscar
                                       (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                                VALUES (pnproces, pnrecibo, 0, xiconcep, xcgarant, xnriesgo);

                           ha_grabat := TRUE;
                        END IF;

                        -- PRIMA DEVENGADA
                        xiconcep := ROUND((difdiasanu * difiprianu) / 360, decimals);

                        IF NVL(xiconcep, 0) <> 0 THEN
                           INSERT INTO detreciboscar
                                       (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                                VALUES (pnproces, pnrecibo, 21, xiconcep, xcgarant, xnriesgo);

                           ha_grabat := TRUE;
                        END IF;
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           CLOSE cur_garansegant;

                           num_err := 102309;   -- REGISTRE DUPLICAT EN DETRECIBOSCAR
                           RETURN num_err;
                        WHEN OTHERS THEN
                           CLOSE cur_garansegant;

                           num_err := 103517;   -- ERROR A L' INSERIR A DETRECIBOSCAR
                           RETURN num_err;
                     END;
                  END IF;

                  difidtocom := 0 - NVL(xidtocom, 0);

                  IF difidtocom <> 0
                     AND difidtocom IS NOT NULL THEN
                     BEGIN
                        -- PRIMA NETA
                        xiconcep := ROUND((difdias * difidtocom) / 360, decimals);

                        IF NVL(xiconcep, 0) <> 0 THEN
                           INSERT INTO detreciboscar
                                       (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                                VALUES (pnproces, pnrecibo, 10, xiconcep, xcgarant, xnriesgo);

                           ha_grabat := TRUE;
                        END IF;
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           CLOSE cur_garansegant;

                           num_err := 102309;   -- REGISTRE DUPLICAT EN DETRECIBOSCAR
                           RETURN num_err;
                        WHEN OTHERS THEN
                           CLOSE cur_garansegant;

                           num_err := 103517;   -- ERROR A L' INSERIR A DETRECIBOSCAR
                           RETURN num_err;
                     END;
                  END IF;
               END IF;

               FETCH cur_garansegant
                INTO xcgarant, xnriesgo, xfiniefe, xnorden, xctarifa, xicapital, xprecarg,
                     xiprianu, xfinefe, xcformul, xiextrap, xctipfra, xifranqu, xnmovimi,
                     xidtocom;
            END LOOP;

            CLOSE cur_garansegant;
         END IF;
      ELSE
         num_err := 101901;   -- PASO INCORRECTO DE PARÁMETROS A LA FUNCIÓN
         RETURN num_err;
      END IF;

      -- ARA CRIDAREM A LA FUNCIÓ QUE CALCULA LES DADES DEL CONSORCI
      num_err := f_estconsorci(pnproces, psseguro, pnrecibo, pnriesgo, pfefecto, xfvencim,
                               pmodo, ptipomovimiento, xcramo, xcmodali, xcactivi, xccolect,
                               xctipseg, xcduraci, xnduraci, pnmovimi, pgrabar, xnmovimiant,
                               xcforpag, difdiasanu, xaltarisc);

      IF num_err = 0 THEN
         IF pgrabar = 1 THEN
            ha_grabat := TRUE;
         END IF;
      ELSE
         RETURN num_err;
      END IF;

-- DESCOMPTES (CCONCEP = 13)
      OPEN cur_detreciboscar;

      FETCH cur_detreciboscar
       INTO xnriesgo, xcgarant;

      WHILE cur_detreciboscar%FOUND LOOP
         IF ptipomovimiento IN(0, 1, 21, 22) THEN
            IF (xpdtoord <> 0
                AND xpdtoord IS NOT NULL) THEN
               grabar := 1;

               BEGIN
                  SELECT   SUM(iconcep)
                      INTO xiconcep
                      FROM detreciboscar
                     WHERE sproces = pnproces
                       AND nrecibo = pnrecibo
                       AND cconcep = 0
                       AND nriesgo = xnriesgo
                       AND cgarant = xcgarant
                  GROUP BY nriesgo, cgarant;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     grabar := 0;   -- NO HI HAN REGISTRES
                  WHEN OTHERS THEN
                     CLOSE cur_detreciboscar;

                     num_err := 103516;   -- ERROR AL LLEGIR DE DETRECIBOSCAR
                     RETURN num_err;
               END;

               IF grabar = 1 THEN
                  -- CALCULEM EL DESCOMPTE O.M. (CCONCEP=13)
                  IF xpdtoord <> 0
                     AND xpdtoord IS NOT NULL THEN
                     xxiconcep := ROUND((xiconcep * xpdtoord) / 100, decimals);

                     IF NVL(xxiconcep, 0) <> 0 THEN
                        BEGIN
                           INSERT INTO detreciboscar
                                       (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                                VALUES (pnproces, pnrecibo, 13, xxiconcep, xcgarant, xnriesgo);

                           ha_grabat := TRUE;
                        EXCEPTION
                           WHEN DUP_VAL_ON_INDEX THEN
                              CLOSE cur_detreciboscar;

                              num_err := 102309;   -- REGISTRE DUPLICAT EN DETRECIBOSCAR
                              RETURN num_err;
                           WHEN OTHERS THEN
                              CLOSE cur_detreciboscar;

                              num_err := 103517;   -- ERROR A L' INSERIR A DETRECIBOSCAR
                              RETURN num_err;
                        END;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;

         FETCH cur_detreciboscar
          INTO xnriesgo, xcgarant;
      END LOOP;

      CLOSE cur_detreciboscar;

      -- CALCUL IMPOSTOS
      -- DGS, IPS, BOMBERS (ARBITRIS), FNG (CCONCEP = 5, 4, 6, 7 )
      OPEN cur_detreciboscar;

      FETCH cur_detreciboscar
       INTO xnriesgo, xcgarant;

      WHILE cur_detreciboscar%FOUND LOOP
         iconcep0 := 0;
         xprecarg := 0;
         taxaips := 0;
         taxadgs := 0;
         taxaarb := 0;
         taxafng := 0;
         xcimpips := 0;
         xcimparb := 0;
         xcimpdgs := 0;
         xcimpfng := 0;

         IF ptipomovimiento IN(0, 1, 21, 22) THEN
            -- TROBEM EL TOTAL DE ICONCEP PER CCONCEP = 0
            BEGIN
               SELECT   SUM(iconcep)
                   INTO iconcep0
                   FROM detreciboscar
                  WHERE sproces = pnproces
                    AND nrecibo = pnrecibo
                    AND nriesgo = xnriesgo
                    AND cgarant = xcgarant
                    AND cconcep = 0
               GROUP BY nriesgo, cgarant;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
               WHEN OTHERS THEN
                  CLOSE cur_detreciboscar;

                  num_err := 103516;   -- ERROR AL LLEGIR DE DETRECIBOSCAR
                  RETURN num_err;
            END;

            -- CALCULEM EL RECARREC PER FRACCIONAMENT (CCONCEP = 8)
            IF xcrecfra = 1
               AND xcforpag IS NOT NULL THEN
               BEGIN
                  SELECT precarg
                    INTO xprecarg
                    FROM forpagrec
                   WHERE cforpag = xcforpag;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     CLOSE cur_detreciboscar;

                     num_err := 103845;   -- FORMA PAG. NO TROBADA A FORPAGREC
                     RETURN num_err;
                  WHEN OTHERS THEN
                     CLOSE cur_detreciboscar;

                     num_err := 103846;   -- ERROR AL LLEGIR DE FORPAGREC
                     RETURN num_err;
               END;

               IF xprecarg <> 0 THEN
                  totrecfracc := ROUND((NVL(iconcep0, 0) * xprecarg) / 100, decimals);

                  IF NVL(totrecfracc, 0) <> 0 THEN
                     BEGIN
                        INSERT INTO detreciboscar
                                    (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                             VALUES (pnproces, pnrecibo, 8, totrecfracc, xcgarant, xnriesgo);

                        ha_grabat := TRUE;
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           CLOSE cur_detreciboscar;

                           num_err := 102309;   -- REGISTRE DUPLICAT EN DETRECIBOSCAR
                           RETURN num_err;
                        WHEN OTHERS THEN
                           CLOSE cur_detreciboscar;

                           num_err := 103517;   -- ERROR A L' INSERIR A DETRECIBOSCAR
                           RETURN num_err;
                     END;
                  END IF;
               END IF;
            END IF;

            -- BUSQUEM EL IMPOST DGS DE LA GARANTIA
            BEGIN
               SELECT NVL(cimpdgs, 0)
                 INTO xcimpdgs
                 FROM garanpro
                WHERE cramo = xcramo
                  AND cmodali = xcmodali
                  AND ccolect = xccolect
                  AND ctipseg = xctipseg
                  AND cgarant = xcgarant
                  AND cactivi = xcactivi;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT NVL(cimpdgs, 0)
                       INTO xcimpdgs
                       FROM garanpro
                      WHERE cramo = xcramo
                        AND cmodali = xcmodali
                        AND ccolect = xccolect
                        AND ctipseg = xctipseg
                        AND cgarant = xcgarant
                        AND cactivi = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        CLOSE cur_detrecibos;

                        num_err := 104110;   -- PRODUCTE NO TROBAT A GARANPRO
                        RETURN num_err;
                     WHEN OTHERS THEN
                        CLOSE cur_detrecibos;

                        num_err := 103503;   -- ERROR AL LLEGIR DE LA TAULA GARANPRO
                        RETURN num_err;
                  END;
               WHEN OTHERS THEN
                  CLOSE cur_detreciboscar;

                  num_err := 103503;   -- ERROR AL LLEGIR DE LA TAULA GARANPRO
                  RETURN num_err;
            END;

            IF xcimpdgs > 0 THEN
               BEGIN
                  SELECT iatribu
                    INTO taxadgs
                    FROM tarifas
                   WHERE ctarifa = 0
                     AND ncolumn = 3
                     AND nfila = xcimpdgs;

                  tot_iconcepdgs := ROUND(NVL(iconcep0, 0) * taxadgs, decimals);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     CLOSE cur_detreciboscar;

                     num_err := 103844;   -- TARIFA NO TROBADA A TARIFAS
                     RETURN num_err;
                  WHEN OTHERS THEN
                     CLOSE cur_detreciboscar;

                     num_err := 103843;   -- ERROR AL LLEGIR DE TARIFAS
                     RETURN num_err;
               END;
            ELSE
               tot_iconcepdgs := 0;
            END IF;

            -- BUSQUEM EL IMPOST IPS DE LA GARANTIA
            BEGIN
               SELECT NVL(cimpips, 0)
                 INTO xcimpips
                 FROM garanpro
                WHERE cramo = xcramo
                  AND cmodali = xcmodali
                  AND ccolect = xccolect
                  AND ctipseg = xctipseg
                  AND cgarant = xcgarant
                  AND cactivi = xcactivi;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT NVL(cimpips, 0)
                       INTO xcimpips
                       FROM garanpro
                      WHERE cramo = xcramo
                        AND cmodali = xcmodali
                        AND ccolect = xccolect
                        AND ctipseg = xctipseg
                        AND cgarant = xcgarant
                        AND cactivi = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        CLOSE cur_detrecibos;

                        num_err := 104110;   -- PRODUCTE NO TROBAT A GARANPRO
                        RETURN num_err;
                     WHEN OTHERS THEN
                        CLOSE cur_detrecibos;

                        num_err := 103503;   -- ERROR AL LLEGIR DE LA TAULA GARANPRO
                        RETURN num_err;
                  END;
               WHEN OTHERS THEN
                  CLOSE cur_detreciboscar;

                  num_err := 103503;   -- ERROR AL LLEGIR DE LA TAULA GARANPRO
                  RETURN num_err;
            END;

            IF xcimpips > 0 THEN
               BEGIN
                  SELECT iatribu
                    INTO taxaips
                    FROM tarifas
                   WHERE ctarifa = 0
                     AND ncolumn = 4
                     AND nfila = xcimpips;

                  tot_iconcepips := ROUND(NVL(iconcep0, 0) * taxaips, decimals);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     CLOSE cur_detreciboscar;

                     num_err := 103844;   -- TARIFA NO TROBADA A TARIFAS
                     RETURN num_err;
                  WHEN OTHERS THEN
                     CLOSE cur_detreciboscar;

                     num_err := 103843;   -- ERROR AL LLEGIR DE TARIFAS
                     RETURN num_err;
               END;
            ELSE
               tot_iconcepips := 0;
            END IF;

            -- BUSQUEM EL IMPOST D' ARBITRIS DE LA GARANTIA
            BEGIN
               SELECT NVL(cimparb, 0)
                 INTO xcimparb
                 FROM garanpro
                WHERE cramo = xcramo
                  AND cmodali = xcmodali
                  AND ccolect = xccolect
                  AND ctipseg = xctipseg
                  AND cgarant = xcgarant
                  AND cactivi = xcactivi;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT NVL(cimparb, 0)
                       INTO xcimparb
                       FROM garanpro
                      WHERE cramo = xcramo
                        AND cmodali = xcmodali
                        AND ccolect = xccolect
                        AND ctipseg = xctipseg
                        AND cgarant = xcgarant
                        AND cactivi = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        CLOSE cur_detrecibos;

                        num_err := 104110;   -- PRODUCTE NO TROBAT A GARANPRO
                        RETURN num_err;
                     WHEN OTHERS THEN
                        CLOSE cur_detrecibos;

                        num_err := 103503;   -- ERROR AL LLEGIR DE LA TAULA GARANPRO
                        RETURN num_err;
                  END;
               WHEN OTHERS THEN
                  CLOSE cur_detreciboscar;

                  num_err := 103503;   -- ERROR AL LLEGIR DE LA TAULA GARANPRO
                  RETURN num_err;
            END;

            IF xcimparb > 0 THEN
               BEGIN
                  SELECT iatribu
                    INTO taxaarb
                    FROM tarifas
                   WHERE ctarifa = 0
                     AND ncolumn = 5
                     AND nfila = xcimparb;

                  tot_iconceparb := ROUND(NVL(iconcep0, 0) * taxaarb, decimals);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     CLOSE cur_detreciboscar;

                     num_err := 103844;   -- TARIFA NO TROBADA A TARIFAS
                     RETURN num_err;
                  WHEN OTHERS THEN
                     CLOSE cur_detreciboscar;

                     num_err := 103843;   -- ERROR AL LLEGIR DE TARIFAS
                     RETURN num_err;
               END;
            ELSE
               tot_iconceparb := 0;
            END IF;

            -- BUSQUEM EL IMPOST FNG DE LA GARANTIA
            BEGIN
               SELECT NVL(cimpfng, 0)
                 INTO xcimpfng
                 FROM garanpro
                WHERE cramo = xcramo
                  AND cmodali = xcmodali
                  AND ccolect = xccolect
                  AND ctipseg = xctipseg
                  AND cgarant = xcgarant
                  AND cactivi = xcactivi;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT NVL(cimpfng, 0)
                       INTO xcimpfng
                       FROM garanpro
                      WHERE cramo = xcramo
                        AND cmodali = xcmodali
                        AND ccolect = xccolect
                        AND ctipseg = xctipseg
                        AND cgarant = xcgarant
                        AND cactivi = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        CLOSE cur_detrecibos;

                        num_err := 104110;   -- PRODUCTE NO TROBAT A GARANPRO
                        RETURN num_err;
                     WHEN OTHERS THEN
                        CLOSE cur_detrecibos;

                        num_err := 103503;   -- ERROR AL LLEGIR DE LA TAULA GARANPRO
                        RETURN num_err;
                  END;
               WHEN OTHERS THEN
                  CLOSE cur_detreciboscar;

                  num_err := 103503;   -- ERROR AL LLEGIR DE LA TAULA GARANPRO
                  RETURN num_err;
            END;

            IF xcimpfng > 0 THEN
               BEGIN
                  SELECT iatribu
                    INTO taxafng
                    FROM tarifas
                   WHERE ctarifa = 0
                     AND ncolumn = 2
                     AND nfila = xcimpfng;

                  tot_iconcepfng := ROUND(NVL(iconcep0, 0) * taxafng, decimals);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     CLOSE cur_detreciboscar;

                     num_err := 103844;   -- TARIFA NO TROBADA A TARIFAS
                     RETURN num_err;
                  WHEN OTHERS THEN
                     CLOSE cur_detreciboscar;

                     num_err := 103843;   -- ERROR AL LLEGIR DE TARIFAS
                     RETURN num_err;
               END;
            ELSE
               tot_iconcepfng := 0;
            END IF;

            IF tot_iconcepdgs IS NOT NULL
               AND tot_iconcepdgs > 0
               AND taxadgs IS NOT NULL THEN
               INSERT INTO detreciboscar
                           (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                    VALUES (pnproces, pnrecibo, 5, tot_iconcepdgs, xcgarant, xnriesgo);

               ha_grabat := TRUE;
            END IF;

            IF tot_iconcepips IS NOT NULL
               AND tot_iconcepips > 0
               AND taxaips IS NOT NULL THEN
               INSERT INTO detreciboscar
                           (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                    VALUES (pnproces, pnrecibo, 4, tot_iconcepips, xcgarant, xnriesgo);

               ha_grabat := TRUE;
            END IF;

            IF tot_iconceparb IS NOT NULL
               AND tot_iconceparb > 0
               AND taxaarb IS NOT NULL THEN
               INSERT INTO detreciboscar
                           (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                    VALUES (pnproces, pnrecibo, 6, tot_iconceparb, xcgarant, xnriesgo);

               ha_grabat := TRUE;
            END IF;

            IF tot_iconcepfng IS NOT NULL
               AND tot_iconcepfng > 0
               AND taxafng IS NOT NULL THEN
               INSERT INTO detreciboscar
                           (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                    VALUES (pnproces, pnrecibo, 7, tot_iconcepfng, xcgarant, xnriesgo);

               ha_grabat := TRUE;
            END IF;

 -- ******************************************************
 -- FASE 4: CALCUL COMISIO BRUTA I RETENCIO (CCONCEP = 11 I 12)
 -- (MODE 'P' : PROVES).
 -- ******************************************************
-- CALCULEM LA DIFERENCIA (0) - (9)
            comis_calc := NVL(iconcep0, 0);
            comis_calc := ROUND(((comis_calc * comis_agente) / 100), decimals);

            IF comis_calc <> 0
               AND comis_agente <> 0
               AND comis_calc IS NOT NULL
               AND comis_agente IS NOT NULL THEN
               BEGIN
                  --INSERTEM LA COMISIO
                  INSERT INTO detreciboscar
                              (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                       VALUES (pnproces, pnrecibo, 11, comis_calc, xcgarant, xnriesgo);

                  ha_grabat := TRUE;
                  reten_calc := ROUND(((comis_calc * reten_agente) / 100), decimals);

                  IF reten_calc <> 0
                     AND reten_calc IS NOT NULL THEN
                     -- INSERTEM LA RETENCIO
                     INSERT INTO detreciboscar
                                 (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                          VALUES (pnproces, pnrecibo, 12, reten_calc, xcgarant, xnriesgo);
                  END IF;
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     CLOSE cur_detreciboscar;

                     num_err := 102309;   -- REGISTRE DUPLICAT EN DETRECIBOSCAR
                     RETURN num_err;
                  WHEN OTHERS THEN
                     CLOSE cur_detreciboscar;

                     num_err := 103517;   -- ERROR A L' INSERIR A DETRECIBOSCAR
                     RETURN num_err;
               END;
            END IF;
         END IF;   -- IF DE SELECCIO DELS TIPUS 00, 01, 21 I 22

         FETCH cur_detreciboscar
          INTO xnriesgo, xcgarant;
      END LOOP;

      CLOSE cur_detreciboscar;

      -- ARA MIRAREM SI LA PRIMA NETA TOTAL ÉS NEGATIVA. SI HO ÉS, ES
      -- TRACTA D' UN EXTORN
      BEGIN
         SELECT SUM(iconcep)
           INTO xtotprimaneta
           FROM detreciboscar
          WHERE sproces = pnproces
            AND nrecibo = pnrecibo
            AND cconcep = 0;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 103516;   -- ERROR AL LLEGIR DE DETRECIBOSCAR
      END;

      IF xtotprimaneta < 0 THEN
         BEGIN
            UPDATE reciboscar
               SET ctiprec = 9   -- SI LA PRIMA ÉS NEGATIVA,
             WHERE sproces = pnproces
               AND   -- ES TRACTA D' UN EXTORN
                  nrecibo = pnrecibo;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 103520;   -- ERROR AL MODIFICAR LA TAULA RECIBOSCAR
         END;

         num_err := f_extornpos(pnrecibo, pmodo, pnproces);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      IF ha_grabat = TRUE THEN
         num_err := f_estmultdetrecibo(psseguro, pnrecibo, xcramo, xcmodali, xctipseg,
                                       xccolect, pmodo, pnproces);

         IF num_err = 0 THEN
            num_err := f_vdetrecibos(pmodo, pnrecibo, pnproces);
            RETURN num_err;
         ELSE
            RETURN num_err;
         END IF;
      ELSE
         RETURN 103108;   -- NO S' HA GRABAT CAP REGISTRE EN LA FUNCIÓ
      -- DE CÀLCUL DE REBUTS
      END IF;
-- **************************************************************************
   ELSIF pmodo = 'N' THEN   -- CAS DE CRIDA PER F_PREVRECIBO (ANUAL)
      IF ptipomovimiento IN(0, 1, 6, 22) THEN
-- COMENCEM AMB LA TAULA GARANSEG
-- ******************************
         OPEN cur_garanseg;

         FETCH cur_garanseg
          INTO xcgarant, xnriesgo, xfiniefe, xnorden, xctarifa, xicapital, xprecarg, xiprianu,
               xfinefe, xcformul, xiextrap, xctipfra, xifranqu, xnmovimi, xidtocom;

         WHILE cur_garanseg%FOUND LOOP
            xidtocom := 0 - NVL(xidtocom, 0);

            -- COMPROBEM SI HI HA MÉS D'UN REGISTRE PEL MATEIX CGARANT-NRIESGO-
            -- NMOVIMI-FINIEFE
            BEGIN
               SELECT finiefe
                 INTO dummy
                 FROM estgaranseg
                WHERE sseguro = psseguro
                  AND cgarant = xcgarant
                  AND nriesgo = xnriesgo
                  AND nmovimi = xnmovimi;
            EXCEPTION
               WHEN TOO_MANY_ROWS THEN
                  CLOSE cur_garanseg;

                  num_err := 102310;   -- GARANTIA-RISC REPETIDA EN GARANSEG
                  RETURN num_err;
               WHEN OTHERS THEN
                  CLOSE cur_garanseg;

                  num_err := 103500;   -- ERROR AL LLEGIR DE GARANSEG
                  RETURN num_err;
            END;

            -- FASE 1: CÀLCUL DE LA PRIMA NETA (CCONCEP = 0) Y DE LA PRIMA
            -- DEVENGADA (FASE 2).
            IF ptipomovimiento IN(0, 22) THEN
               BEGIN
                  IF xcforpag = 0 THEN
                     xiprianu2 := ROUND(xiprianu, decimals);
                     xidtocom2 := ROUND(xidtocom, decimals);
                  ELSE
                     xiprianu2 := ROUND(xiprianu / xcforpag, decimals);
                     xidtocom2 := ROUND(xidtocom / xcforpag, decimals);
                  END IF;

                  IF NVL(xiprianu2, 0) <> 0 THEN
                     -- PRIMA NETA
                     INSERT INTO detreciboscar
                                 (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                          VALUES (pnproces, pnrecibo, 0, xiprianu2, xcgarant, xnriesgo);

                     ha_grabat := TRUE;
                  END IF;

                  IF xidtocom2 <> 0
                     AND xidtocom2 IS NOT NULL THEN
                     -- DTE. TÈCNIC
                     INSERT INTO detreciboscar
                                 (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                          VALUES (pnproces, pnrecibo, 10, xidtocom2, xcgarant, xnriesgo);

                     ha_grabat := TRUE;
                  END IF;

                  -- PRIMA DEVENGADA
                  IF ptipomovimiento = 0 THEN
                     xiprianu := ROUND(xiprianu, decimals);

                     IF NVL(xiprianu, 0) <> 0 THEN
                        INSERT INTO detreciboscar
                                    (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                             VALUES (pnproces, pnrecibo, 21, xiprianu, xcgarant, xnriesgo);

                        ha_grabat := TRUE;
                     END IF;
                  END IF;
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     CLOSE cur_garanseg;

                     num_err := 102309;   -- REGISTRE DUPLICAT EN DETRECIBOSCAR
                     RETURN num_err;
                  WHEN OTHERS THEN
                     CLOSE cur_garanseg;

                     num_err := 103517;   -- ERROR A L' INSERIR A DETRECIBOSCAR
                     RETURN num_err;
               END;
            ELSIF ptipomovimiento = 1 THEN   -- SUPLEMENTS
               xxcgarant := NULL;
               xxnriesgo := NULL;
               xxfiniefe := NULL;
               xxiprianu := NULL;
               xxffinefe := NULL;
               xxidtocom := NULL;

               BEGIN
                  SELECT cgarant, nriesgo, finiefe, iprianu, ffinefe, idtocom
                    INTO xxcgarant, xxnriesgo, xxfiniefe, xxiprianu, xxffinefe, xxidtocom
                    FROM estgaranseg
                   WHERE sseguro = psseguro
                     AND cgarant = xcgarant
                     AND nriesgo = xnriesgo
                     AND nmovimi = xnmovimiant;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     NULL;   -- NO HI HA GARANTIA ANTERIOR
                  WHEN TOO_MANY_ROWS THEN
                     CLOSE cur_garanseg;

                     num_err := 102310;   -- GARANTIA-RISC REPETIDA EN GARANSEG
                     RETURN num_err;
                  WHEN OTHERS THEN
                     CLOSE cur_garanseg;

                     num_err := 103500;   -- ERROR AL LLEGIR DE GARANSEG
                     RETURN num_err;
               END;

               xxidtocom := 0 - NVL(xxidtocom, 0);
               difiprianu := xiprianu - NVL(xxiprianu, 0);
               difidtocom := NVL(xidtocom, 0) - NVL(xxidtocom, 0);
               xinsert := TRUE;

               IF xaltarisc THEN   -- ES UN SUPLEMENT DE ALTA
                  BEGIN
                     SELECT nmovima
                       INTO xnmovima
                       FROM estriesgos
                      WHERE sseguro = psseguro
                        AND nriesgo = xnriesgo
                        AND nmovima = pnmovimi;

                     xinsert := TRUE;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        xinsert := FALSE;
                     WHEN OTHERS THEN
                        CLOSE cur_garanseg;

                        RETURN 103509;   -- ERROR AL LLEGIR DE RIESGOS
                  END;
               END IF;

               IF xinsert THEN
                  BEGIN
                     xiconcep := ROUND((difdias * difiprianu) / 360, decimals);

                     IF NVL(xiconcep, 0) <> 0 THEN
                        -- PRIMA NETA
                        INSERT INTO detreciboscar
                                    (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                             VALUES (pnproces, pnrecibo, 0, xiconcep, xcgarant, xnriesgo);

                        ha_grabat := TRUE;
                     END IF;

                     xiconcep := ROUND((difdias * difidtocom) / 360, decimals);

                     IF xiconcep <> 0
                        AND xiconcep IS NOT NULL THEN
                        -- PRIMA NETA
                        INSERT INTO detreciboscar
                                    (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                             VALUES (pnproces, pnrecibo, 10, xiconcep, xcgarant, xnriesgo);

                        ha_grabat := TRUE;
                     END IF;

                     -- PRIMA DEVENGADA
                     xiconcep := ROUND((difdiasanu * difiprianu) / 360, decimals);

                     IF NVL(xiconcep, 0) <> 0 THEN
                        INSERT INTO detreciboscar
                                    (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                             VALUES (pnproces, pnrecibo, 21, xiconcep, xcgarant, xnriesgo);

                        ha_grabat := TRUE;
                     END IF;
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        CLOSE cur_garanseg;

                        num_err := 102309;   -- REGISTRE DUPLICAT EN DETRECIBOSCAR
                        RETURN num_err;
                     WHEN OTHERS THEN
                        CLOSE cur_garanseg;

                        num_err := 103517;   -- ERROR A L' INSERIR A DETRECIBOSCAR
                        RETURN num_err;
                  END;
               END IF;
            END IF;

            FETCH cur_garanseg
             INTO xcgarant, xnriesgo, xfiniefe, xnorden, xctarifa, xicapital, xprecarg,
                  xiprianu, xfinefe, xcformul, xiextrap, xctipfra, xifranqu, xnmovimi,
                  xidtocom;
         END LOOP;

         CLOSE cur_garanseg;

         IF ptipomovimiento = 1 THEN
            -- ARA BUSCAREM LES GARANTIES QUE ESTAVEN EN (FEFECTO-1) I ARA NO ESTAN
            OPEN cur_garansegant;

            FETCH cur_garansegant
             INTO xcgarant, xnriesgo, xfiniefe, xnorden, xctarifa, xicapital, xprecarg,
                  xiprianu, xfinefe, xcformul, xiextrap, xctipfra, xifranqu, xnmovimi,
                  xidtocom;

            WHILE cur_garansegant%FOUND LOOP
               xidtocom := 0 - NVL(xidtocom, 0);

               -- COMPROBEM SI HI HA MÉS D'UN REGISTRE PEL MATEIX CGARANT-NRIESGO
               -- NMOVIMI-FINIEFE
               BEGIN
                  SELECT finiefe
                    INTO dummy
                    FROM estgaranseg
                   WHERE sseguro = psseguro
                     AND cgarant = xcgarant
                     AND nriesgo = xnriesgo
                     AND nmovimi = xnmovimi;
               EXCEPTION
                  WHEN TOO_MANY_ROWS THEN
                     CLOSE cur_garansegant;

                     num_err := 102310;   -- GARANTIA-RISC REPETIDA EN GARANSEG
                     RETURN num_err;
                  WHEN OTHERS THEN
                     CLOSE cur_garansegant;

                     num_err := 103500;   -- ERROR AL LLEGIR DE GARANSEG
                     RETURN num_err;
               END;

               BEGIN
                  grabar := 0;
                  xxcgarant := NULL;
                  xxnriesgo := NULL;
                  xxfiniefe := NULL;
                  xxiprianu := NULL;
                  xxffinefe := NULL;
                  xxidtocom := NULL;

                  SELECT cgarant, nriesgo, finiefe, iprianu, ffinefe, idtocom
                    INTO xxcgarant, xxnriesgo, xxfiniefe, xxiprianu, xxffinefe, xxidtocom
                    FROM estgaranseg
                   WHERE sseguro = psseguro
                     AND cgarant = xcgarant
                     AND nriesgo = xnriesgo
                     AND nmovimi = pnmovimi;

                  xxidtocom := 0 - NVL(xxidtocom, 0);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     grabar := 1;   -- ÉS UNA GARANTIA DESAPAREGUDA
                  WHEN TOO_MANY_ROWS THEN
                     CLOSE cur_garansegant;

                     num_err := 102310;   -- GARANTIA-RISC REPETIDA EN GARANSEG
                     RETURN num_err;
                  WHEN OTHERS THEN
                     CLOSE cur_garansegant;

                     num_err := 103500;   -- ERROR AL LLEGIR DE GARANSEG
                     RETURN num_err;
               END;

               IF grabar = 1 THEN
                  difiprianu := 0 - xiprianu;

                  IF difiprianu <> 0 THEN
                     BEGIN
                        -- PRIMA NETA
                        xiconcep := ROUND((difdias * difiprianu) / 360, decimals);

                        IF NVL(xiconcep, 0) <> 0 THEN
                           INSERT INTO detreciboscar
                                       (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                                VALUES (pnproces, pnrecibo, 0, xiconcep, xcgarant, xnriesgo);

                           ha_grabat := TRUE;
                        END IF;

                        -- PRIMA DEVENGADA
                        xiconcep := ROUND((difdiasanu * difiprianu) / 360, decimals);

                        IF NVL(xiconcep, 0) <> 0 THEN
                           INSERT INTO detreciboscar
                                       (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                                VALUES (pnproces, pnrecibo, 21, xiconcep, xcgarant, xnriesgo);

                           ha_grabat := TRUE;
                        END IF;
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           CLOSE cur_garansegant;

                           num_err := 102309;   -- REGISTRE DUPLICAT EN DETRECIBOSCAR
                           RETURN num_err;
                        WHEN OTHERS THEN
                           CLOSE cur_garansegant;

                           num_err := 103517;   -- ERROR A L' INSERIR A DETRECIBOSCAR
                           RETURN num_err;
                     END;
                  END IF;

                  difidtocom := 0 - NVL(xidtocom, 0);

                  IF difidtocom <> 0
                     AND difidtocom IS NOT NULL THEN
                     BEGIN
                        -- PRIMA NETA
                        xiconcep := ROUND((difdias * difidtocom) / 360, decimals);

                        IF NVL(xiconcep, 0) <> 0 THEN
                           INSERT INTO detreciboscar
                                       (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                                VALUES (pnproces, pnrecibo, 10, xiconcep, xcgarant, xnriesgo);

                           ha_grabat := TRUE;
                        END IF;
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           CLOSE cur_garansegant;

                           num_err := 102309;   -- REGISTRE DUPLICAT EN DETRECIBOSCAR
                           RETURN num_err;
                        WHEN OTHERS THEN
                           CLOSE cur_garansegant;

                           num_err := 103517;   -- ERROR A L' INSERIR A DETRECIBOSCAR
                           RETURN num_err;
                     END;
                  END IF;
               END IF;

               FETCH cur_garansegant
                INTO xcgarant, xnriesgo, xfiniefe, xnorden, xctarifa, xicapital, xprecarg,
                     xiprianu, xfinefe, xcformul, xiextrap, xctipfra, xifranqu, xnmovimi,
                     xidtocom;
            END LOOP;

            CLOSE cur_garansegant;
         END IF;
      ELSE
         num_err := 101901;   -- PASO INCORRECTO DE PARÁMETROS A LA FUNCIÓN
         RETURN num_err;
      END IF;

      -- ARA CRIDAREM A LA FUNCIÓ QUE CALCULA LES DADES DEL CONSORCI
      num_err := f_estconsorci(pnproces, psseguro, pnrecibo, pnriesgo, pfefecto, xfvencim, 'N',
                               ptipomovimiento, xcramo, xcmodali, xcactivi, xccolect, xctipseg,
                               xcduraci, xnduraci, pnmovimi, pgrabar, xnmovimiant, xcforpag,
                               difdiasanu, xaltarisc);

      IF num_err = 0 THEN
         IF pgrabar = 1 THEN
            ha_grabat := TRUE;
         END IF;
      ELSE
         RETURN num_err;
      END IF;

-- DESCOMPTES (CCONCEP = 13)
      OPEN cur_detreciboscar;

      FETCH cur_detreciboscar
       INTO xnriesgo, xcgarant;

      WHILE cur_detreciboscar%FOUND LOOP
         IF ptipomovimiento IN(0, 1, 21, 22) THEN
            IF (xpdtoord <> 0
                AND xpdtoord IS NOT NULL) THEN
               grabar := 1;

               BEGIN
                  SELECT   SUM(iconcep)
                      INTO xiconcep
                      FROM detreciboscar
                     WHERE sproces = pnproces
                       AND nrecibo = pnrecibo
                       AND cconcep = 0
                       AND nriesgo = xnriesgo
                       AND cgarant = xcgarant
                  GROUP BY nriesgo, cgarant;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     grabar := 0;   -- NO HI HAN REGISTRES
                  WHEN OTHERS THEN
                     CLOSE cur_detreciboscar;

                     num_err := 103516;   -- ERROR AL LLEGIR DE DETRECIBOSCAR
                     RETURN num_err;
               END;

               IF grabar = 1 THEN
                  -- CALCULEM EL DESCOMPTE O.M. (CCONCEP=13)
                  IF xpdtoord <> 0
                     AND xpdtoord IS NOT NULL THEN
                     xxiconcep := ROUND((xiconcep * xpdtoord) / 100, decimals);

                     IF NVL(xxiconcep, 0) <> 0 THEN
                        BEGIN
                           INSERT INTO detreciboscar
                                       (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                                VALUES (pnproces, pnrecibo, 13, xxiconcep, xcgarant, xnriesgo);

                           ha_grabat := TRUE;
                        EXCEPTION
                           WHEN DUP_VAL_ON_INDEX THEN
                              CLOSE cur_detreciboscar;

                              num_err := 102309;   -- REGISTRE DUPLICAT EN DETRECIBOSCAR
                              RETURN num_err;
                           WHEN OTHERS THEN
                              CLOSE cur_detreciboscar;

                              num_err := 103517;   -- ERROR A L' INSERIR A DETRECIBOSCAR
                              RETURN num_err;
                        END;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;

         FETCH cur_detreciboscar
          INTO xnriesgo, xcgarant;
      END LOOP;

      CLOSE cur_detreciboscar;

      -- CALCUL IMPOSTOS
      -- DGS, IPS, BOMBERS (ARBITRIS), FNG (CCONCEP = 5, 4, 6, 7 )
      OPEN cur_detreciboscar;

      FETCH cur_detreciboscar
       INTO xnriesgo, xcgarant;

      WHILE cur_detreciboscar%FOUND LOOP
         iconcep0 := 0;
         xprecarg := 0;
         taxaips := 0;
         taxadgs := 0;
         taxaarb := 0;
         taxafng := 0;
         xcimpips := 0;
         xcimparb := 0;
         xcimpdgs := 0;
         xcimpfng := 0;

         IF ptipomovimiento IN(0, 1, 21, 22) THEN
            -- TROBEM EL TOTAL DE ICONCEP PER CCONCEP = 0
            BEGIN
               SELECT   SUM(iconcep)
                   INTO iconcep0
                   FROM detreciboscar
                  WHERE sproces = pnproces
                    AND nrecibo = pnrecibo
                    AND nriesgo = xnriesgo
                    AND cgarant = xcgarant
                    AND cconcep = 0
               GROUP BY nriesgo, cgarant;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
               WHEN OTHERS THEN
                  CLOSE cur_detreciboscar;

                  num_err := 103516;   -- ERROR AL LLEGIR DE DETRECIBOSCAR
                  RETURN num_err;
            END;

            -- CALCULEM EL RECARREC PER FRACCIONAMENT (CCONCEP = 8)
            IF xcrecfra = 1
               AND xcforpag IS NOT NULL THEN
               BEGIN
                  SELECT precarg
                    INTO xprecarg
                    FROM forpagrec
                   WHERE cforpag = xcforpag;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     CLOSE cur_detreciboscar;

                     num_err := 103845;   -- FORMA PAG. NO TROBADA A FORPAGREC
                     RETURN num_err;
                  WHEN OTHERS THEN
                     CLOSE cur_detreciboscar;

                     num_err := 103846;   -- ERROR AL LLEGIR DE FORPAGREC
                     RETURN num_err;
               END;

               IF xprecarg <> 0 THEN
                  totrecfracc := ROUND((NVL(iconcep0, 0) * xprecarg) / 100, decimals);

                  IF NVL(totrecfracc, 0) <> 0 THEN
                     BEGIN
                        INSERT INTO detreciboscar
                                    (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                             VALUES (pnproces, pnrecibo, 8, totrecfracc, xcgarant, xnriesgo);

                        ha_grabat := TRUE;
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           CLOSE cur_detreciboscar;

                           num_err := 102309;   -- REGISTRE DUPLICAT EN DETRECIBOSCAR
                           RETURN num_err;
                        WHEN OTHERS THEN
                           CLOSE cur_detreciboscar;

                           num_err := 103517;   -- ERROR A L' INSERIR A DETRECIBOSCAR
                           RETURN num_err;
                     END;
                  END IF;
               END IF;
            END IF;

            -- BUSQUEM EL IMPOST DGS DE LA GARANTIA
            BEGIN
               SELECT NVL(cimpdgs, 0)
                 INTO xcimpdgs
                 FROM garanpro
                WHERE cramo = xcramo
                  AND cmodali = xcmodali
                  AND ccolect = xccolect
                  AND ctipseg = xctipseg
                  AND cgarant = xcgarant
                  AND cactivi = xcactivi;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT NVL(cimpdgs, 0)
                       INTO xcimpdgs
                       FROM garanpro
                      WHERE cramo = xcramo
                        AND cmodali = xcmodali
                        AND ccolect = xccolect
                        AND ctipseg = xctipseg
                        AND cgarant = xcgarant
                        AND cactivi = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        CLOSE cur_detrecibos;

                        num_err := 104110;   -- PRODUCTE NO TROBAT A GARANPRO
                        RETURN num_err;
                     WHEN OTHERS THEN
                        CLOSE cur_detrecibos;

                        num_err := 103503;   -- ERROR AL LLEGIR DE LA TAULA GARANPRO
                        RETURN num_err;
                  END;
               WHEN OTHERS THEN
                  CLOSE cur_detreciboscar;

                  num_err := 103503;   -- ERROR AL LLEGIR DE LA TAULA GARANPRO
                  RETURN num_err;
            END;

            IF xcimpdgs > 0 THEN
               BEGIN
                  SELECT iatribu
                    INTO taxadgs
                    FROM tarifas
                   WHERE ctarifa = 0
                     AND ncolumn = 3
                     AND nfila = xcimpdgs;

                  tot_iconcepdgs := ROUND(NVL(iconcep0, 0) * taxadgs, decimals);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     CLOSE cur_detreciboscar;

                     num_err := 103844;   -- TARIFA NO TROBADA A TARIFAS
                     RETURN num_err;
                  WHEN OTHERS THEN
                     CLOSE cur_detreciboscar;

                     num_err := 103843;   -- ERROR AL LLEGIR DE TARIFAS
                     RETURN num_err;
               END;
            ELSE
               tot_iconcepdgs := 0;
            END IF;

            -- BUSQUEM EL IMPOST IPS DE LA GARANTIA
            BEGIN
               SELECT NVL(cimpips, 0)
                 INTO xcimpips
                 FROM garanpro
                WHERE cramo = xcramo
                  AND cmodali = xcmodali
                  AND ccolect = xccolect
                  AND ctipseg = xctipseg
                  AND cgarant = xcgarant
                  AND cactivi = xcactivi;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT NVL(cimpips, 0)
                       INTO xcimpips
                       FROM garanpro
                      WHERE cramo = xcramo
                        AND cmodali = xcmodali
                        AND ccolect = xccolect
                        AND ctipseg = xctipseg
                        AND cgarant = xcgarant
                        AND cactivi = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        CLOSE cur_detrecibos;

                        num_err := 104110;   -- PRODUCTE NO TROBAT A GARANPRO
                        RETURN num_err;
                     WHEN OTHERS THEN
                        CLOSE cur_detrecibos;

                        num_err := 103503;   -- ERROR AL LLEGIR DE LA TAULA GARANPRO
                        RETURN num_err;
                  END;
               WHEN OTHERS THEN
                  CLOSE cur_detreciboscar;

                  num_err := 103503;   -- ERROR AL LLEGIR DE LA TAULA GARANPRO
                  RETURN num_err;
            END;

            IF xcimpips > 0 THEN
               BEGIN
                  SELECT iatribu
                    INTO taxaips
                    FROM tarifas
                   WHERE ctarifa = 0
                     AND ncolumn = 4
                     AND nfila = xcimpips;

                  tot_iconcepips := ROUND(NVL(iconcep0, 0) * taxaips, decimals);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     CLOSE cur_detreciboscar;

                     num_err := 103844;   -- TARIFA NO TROBADA A TARIFAS
                     RETURN num_err;
                  WHEN OTHERS THEN
                     CLOSE cur_detreciboscar;

                     num_err := 103843;   -- ERROR AL LLEGIR DE TARIFAS
                     RETURN num_err;
               END;
            ELSE
               tot_iconcepips := 0;
            END IF;

            -- BUSQUEM EL IMPOST D' ARBITRIS DE LA GARANTIA
            BEGIN
               SELECT NVL(cimparb, 0)
                 INTO xcimparb
                 FROM garanpro
                WHERE cramo = xcramo
                  AND cmodali = xcmodali
                  AND ccolect = xccolect
                  AND ctipseg = xctipseg
                  AND cgarant = xcgarant
                  AND cactivi = xcactivi;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT NVL(cimparb, 0)
                       INTO xcimparb
                       FROM garanpro
                      WHERE cramo = xcramo
                        AND cmodali = xcmodali
                        AND ccolect = xccolect
                        AND ctipseg = xctipseg
                        AND cgarant = xcgarant
                        AND cactivi = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        CLOSE cur_detrecibos;

                        num_err := 104110;   -- PRODUCTE NO TROBAT A GARANPRO
                        RETURN num_err;
                     WHEN OTHERS THEN
                        CLOSE cur_detrecibos;

                        num_err := 103503;   -- ERROR AL LLEGIR DE LA TAULA GARANPRO
                        RETURN num_err;
                  END;
               WHEN OTHERS THEN
                  CLOSE cur_detreciboscar;

                  num_err := 103503;   -- ERROR AL LLEGIR DE LA TAULA GARANPRO
                  RETURN num_err;
            END;

            IF xcimparb > 0 THEN
               BEGIN
                  SELECT iatribu
                    INTO taxaarb
                    FROM tarifas
                   WHERE ctarifa = 0
                     AND ncolumn = 5
                     AND nfila = xcimparb;

                  tot_iconceparb := ROUND(NVL(iconcep0, 0) * taxaarb, decimals);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     CLOSE cur_detreciboscar;

                     num_err := 103844;   -- TARIFA NO TROBADA A TARIFAS
                     RETURN num_err;
                  WHEN OTHERS THEN
                     CLOSE cur_detreciboscar;

                     num_err := 103843;   -- ERROR AL LLEGIR DE TARIFAS
                     RETURN num_err;
               END;
            ELSE
               tot_iconceparb := 0;
            END IF;

            -- BUSQUEM EL IMPOST FNG DE LA GARANTIA
            BEGIN
               SELECT NVL(cimpfng, 0)
                 INTO xcimpfng
                 FROM garanpro
                WHERE cramo = xcramo
                  AND cmodali = xcmodali
                  AND ccolect = xccolect
                  AND ctipseg = xctipseg
                  AND cgarant = xcgarant
                  AND cactivi = xcactivi;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT NVL(cimpfng, 0)
                       INTO xcimpfng
                       FROM garanpro
                      WHERE cramo = xcramo
                        AND cmodali = xcmodali
                        AND ccolect = xccolect
                        AND ctipseg = xctipseg
                        AND cgarant = xcgarant
                        AND cactivi = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        CLOSE cur_detrecibos;

                        num_err := 104110;   -- PRODUCTE NO TROBAT A GARANPRO
                        RETURN num_err;
                     WHEN OTHERS THEN
                        CLOSE cur_detrecibos;

                        num_err := 103503;   -- ERROR AL LLEGIR DE LA TAULA GARANPRO
                        RETURN num_err;
                  END;
               WHEN OTHERS THEN
                  CLOSE cur_detreciboscar;

                  num_err := 103503;   -- ERROR AL LLEGIR DE LA TAULA GARANPRO
                  RETURN num_err;
            END;

            IF xcimpfng > 0 THEN
               BEGIN
                  SELECT iatribu
                    INTO taxafng
                    FROM tarifas
                   WHERE ctarifa = 0
                     AND ncolumn = 2
                     AND nfila = xcimpfng;

                  tot_iconcepfng := ROUND(NVL(iconcep0, 0) * taxafng, decimals);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     CLOSE cur_detreciboscar;

                     num_err := 103844;   -- TARIFA NO TROBADA A TARIFAS
                     RETURN num_err;
                  WHEN OTHERS THEN
                     CLOSE cur_detreciboscar;

                     num_err := 103843;   -- ERROR AL LLEGIR DE TARIFAS
                     RETURN num_err;
               END;
            ELSE
               tot_iconcepfng := 0;
            END IF;

            IF tot_iconcepdgs IS NOT NULL
               AND tot_iconcepdgs > 0
               AND taxadgs IS NOT NULL THEN
               INSERT INTO detreciboscar
                           (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                    VALUES (pnproces, pnrecibo, 5, tot_iconcepdgs, xcgarant, xnriesgo);

               ha_grabat := TRUE;
            END IF;

            IF tot_iconcepips IS NOT NULL
               AND tot_iconcepips > 0
               AND taxaips IS NOT NULL THEN
               INSERT INTO detreciboscar
                           (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                    VALUES (pnproces, pnrecibo, 4, tot_iconcepips, xcgarant, xnriesgo);

               ha_grabat := TRUE;
            END IF;

            IF tot_iconceparb IS NOT NULL
               AND tot_iconceparb > 0
               AND taxaarb IS NOT NULL THEN
               INSERT INTO detreciboscar
                           (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                    VALUES (pnproces, pnrecibo, 6, tot_iconceparb, xcgarant, xnriesgo);

               ha_grabat := TRUE;
            END IF;

            IF tot_iconcepfng IS NOT NULL
               AND tot_iconcepfng > 0
               AND taxafng IS NOT NULL THEN
               INSERT INTO detreciboscar
                           (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                    VALUES (pnproces, pnrecibo, 7, tot_iconcepfng, xcgarant, xnriesgo);

               ha_grabat := TRUE;
            END IF;

 -- ******************************************************
 -- FASE 4: CALCUL COMISIO BRUTA I RETENCIO (CCONCEP = 11 I 12)
 -- (MODE 'P' : PROVES).
 -- ******************************************************
-- CALCULEM LA DIFERENCIA (0) - (9)
            comis_calc := NVL(iconcep0, 0);
            comis_calc := ROUND(((comis_calc * comis_agente) / 100), decimals);

            IF comis_calc <> 0
               AND comis_agente <> 0
               AND comis_calc IS NOT NULL
               AND comis_agente IS NOT NULL THEN
               BEGIN
                  --INSERTEM LA COMISIO
                  INSERT INTO detreciboscar
                              (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                       VALUES (pnproces, pnrecibo, 11, comis_calc, xcgarant, xnriesgo);

                  ha_grabat := TRUE;
                  reten_calc := ROUND(((comis_calc * reten_agente) / 100), decimals);

                  IF reten_calc <> 0
                     AND reten_calc IS NOT NULL THEN
                     -- INSERTEM LA RETENCIO
                     INSERT INTO detreciboscar
                                 (sproces, nrecibo, cconcep, iconcep, cgarant, nriesgo)
                          VALUES (pnproces, pnrecibo, 12, reten_calc, xcgarant, xnriesgo);
                  END IF;
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     CLOSE cur_detreciboscar;

                     num_err := 102309;   -- REGISTRE DUPLICAT EN DETRECIBOSCAR
                     RETURN num_err;
                  WHEN OTHERS THEN
                     CLOSE cur_detreciboscar;

                     num_err := 103517;   -- ERROR A L' INSERIR A DETRECIBOSCAR
                     RETURN num_err;
               END;
            END IF;
         END IF;   -- IF DE SELECCIO DELS TIPUS 00, 01, 21 I 22

         FETCH cur_detreciboscar
          INTO xnriesgo, xcgarant;
      END LOOP;

      CLOSE cur_detreciboscar;

      -- ARA MIRAREM SI LA PRIMA NETA TOTAL ÉS NEGATIVA. SI HO ÉS, ES
      -- TRACTA D' UN EXTORN
      BEGIN
         SELECT SUM(iconcep)
           INTO xtotprimaneta
           FROM detreciboscar
          WHERE sproces = pnproces
            AND nrecibo = pnrecibo
            AND cconcep = 0;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 103516;   -- ERROR AL LLEGIR DE DETRECIBOSCAR
      END;

      IF xtotprimaneta < 0 THEN
         BEGIN
            UPDATE reciboscar
               SET ctiprec = 9   -- SI LA PRIMA ÉS NEGATIVA,
             WHERE sproces = pnproces
               AND   -- ES TRACTA D' UN EXTORN
                  nrecibo = pnrecibo;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 103520;   -- ERROR AL MODIFICAR LA TAULA RECIBOSCAR
         END;

         num_err := f_extornpos(pnrecibo, pmodo, pnproces);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      IF ha_grabat = TRUE THEN
         num_err := f_estmultdetrecibo(psseguro, pnrecibo, xcramo, xcmodali, xctipseg,
                                       xccolect, 'N', pnproces);

         IF num_err = 0 THEN
            num_err := f_vdetrecibos('N', pnrecibo, pnproces);
            RETURN num_err;
         ELSE
            RETURN num_err;
         END IF;
      ELSE
         RETURN 103108;   -- NO S' HA GRABAT CAP REGISTRE EN LA FUNCIÓ
      -- DE CÀLCUL DE REBUTS
      END IF;
   ELSE
      RETURN 101901;   -- PAS INCORRECTE DE PARÀMETRES A LA FUNCIÓ
   END IF;
-- BUG - 08/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
EXCEPTION
WHEN OTHERS THEN
  IF cur_garancar%ISOPEN THEN
  close cur_garancar;
END IF;
  IF cur_garanseg%ISOPEN THEN
  close cur_garanseg;
END IF;
  IF cur_garansegant%ISOPEN THEN
  close cur_garansegant;
END IF;
  IF cur_detreciboscar%ISOPEN THEN
  close cur_detreciboscar;
END IF;
RETURN 140999;
END F_ESTDETRECIBO;

/

  GRANT EXECUTE ON "AXIS"."F_ESTDETRECIBO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ESTDETRECIBO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ESTDETRECIBO" TO "PROGRAMADORESCSI";
