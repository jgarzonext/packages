--------------------------------------------------------
--  DDL for Function F_ESTCONSORCI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ESTCONSORCI" (
   psproces IN NUMBER,
   psseguro IN NUMBER,
   pnrecibo IN NUMBER,
   pnriesgo IN NUMBER,
   pfefecto IN DATE,
   pfvencim IN DATE,
   pcmodo IN VARCHAR2,
   ptipomovimiento IN NUMBER,
   pcramo IN NUMBER,
   pcmodali IN NUMBER,
   pcactivi IN NUMBER,
   pccolect IN NUMBER,
   pctipseg IN NUMBER,
   pcduraci IN NUMBER,
   pnduraci IN NUMBER,
   pnmovimi IN NUMBER,
   pgrabar OUT NUMBER,
   pnmovimiant IN NUMBER,
   pcforpag IN NUMBER,
   pdifdiasanu IN NUMBER,
   paltarisc IN BOOLEAN)
   RETURN NUMBER AUTHID CURRENT_USER IS
   -- ALLIBADM. AQUESTA FUNCIÓ ÉS CRIDADA PER
   -- LA FUNCIÓ F_DETRECIBO, I S' ENCARREGA NOMÉS D' OMPLIR LA TAULA
   -- DETRECIBOS AMB LES DADES DEL CONSORCI.
   -- NOMÉS S' HA CREAT PER PROBLEMES D' ESPAI DE LA FUNCIÓ ORIGINAL
   -- F_DETRECIBO EN LA BD.
   -- ALLIBADM. CANVIA COMPLETAMENT.
   -- EN LA PROPERA MODIFICACIÓ, M' HE DE CARREGAR EL PARÀMETRE PCFORPAG,
   -- AQUÍ I A F_DETRECIBO
   error          NUMBER := 0;
   xmeses         NUMBER;
   xresult        NUMBER;
   xcclarie       NUMBER;
   xsegtemporada  BOOLEAN;
   xsegtemp1      NUMBER;
   xctipcla       NUMBER;
   xivalnor       NUMBER;
   xvalorconsorcio NUMBER;
   xcapitaltrobat NUMBER;
   xcapitaltotal  NUMBER;
   xpercent       NUMBER;
   xtotcapital    NUMBER;
   xnvalor1       NUMBER;
   xnvalor2       NUMBER;
   iconcep0       NUMBER;
   xcgarant       NUMBER;
   xnriesgo       NUMBER;
   xcgarantant    NUMBER;
   xtotcapitalant NUMBER;
   xcapitaltotalant NUMBER;
   xnriesgoant    NUMBER;
   xcgarantseg    NUMBER;
   xnriesgoseg    NUMBER;
   xgrabar        NUMBER := 0;
   xnmovimiant    NUMBER;
   xnmovimiseg    NUMBER;
   xfefectoant    DATE;
   xfefectoseg    DATE;
   decimals       NUMBER := 0;
   existant       BOOLEAN := TRUE;
   xinnomin       BOOLEAN;
   xnasegur1      NUMBER;
   xnasegur2      NUMBER;
   xcobjase       NUMBER;
   xinsert        BOOLEAN;
   xnmovima       NUMBER;

   CURSOR cur_garansegxrisc IS
      SELECT   nriesgo, cgarant
          FROM estgaranseg
         WHERE sseguro = psseguro
           AND nriesgo = NVL(pnriesgo, nriesgo)
           AND nmovimi = pnmovimi
      GROUP BY cgarant, nriesgo;

   CURSOR cur_garansegant IS
      SELECT cgarant, nriesgo
        FROM garanseg
       WHERE sseguro = psseguro
         AND nriesgo = NVL(pnriesgo, nriesgo)
         AND nmovimi = pnmovimiant;

   CURSOR cur_garancarxrisc IS
      SELECT   nriesgo, cgarant
          FROM garancar
         WHERE sproces = psproces
           AND sseguro = psseguro
           AND nriesgo = NVL(pnriesgo, nriesgo)
      GROUP BY cgarant, nriesgo;
BEGIN
-- ********************************************************************
-- *************  FASE 3  DE F_DETRECIBO ******************************
-- ********************************************************************
-- CÀLCUL DEL CONSORCI (CCONCEP 2) (TAULA GARANSEG)
   pgrabar := 0;   -- EN UN PRINCIPI, NO HEM GRABAT RES

   BEGIN
      SELECT cobjase
        INTO xcobjase
        FROM productos
       WHERE cramo = pcramo
         AND cmodali = pcmodali
         AND ctipseg = pctipseg
         AND ccolect = pccolect;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 104347;   -- PRODUCTE NO TROBAT A PRODUCTOS
      WHEN OTHERS THEN
         RETURN 102705;   -- ERROR AL LLEGIR DE PRODUCTOS
   END;

   IF xcobjase = 4 THEN   -- PRODUCTE INNOMINAT
      xinnomin := TRUE;
   ELSE
      xinnomin := FALSE;
   END IF;

-- MIREM SI ÉS UNA ASSEGURANÇA DE TEMPORADA, I QUIN ÉS EL PERCENTATGE QUE
-- LI CORRESPON, SI HO ÉS.
   IF pcduraci = 2 THEN
      xmeses := pnduraci;
   ELSIF pcduraci = 3 THEN
      error := f_difdata(pfefecto, pfvencim, 1, 2, xresult);

      IF error = 0 THEN
         xmeses := xresult;
      ELSE
         RETURN error;
      END IF;
   ELSE
      xsegtemporada := FALSE;
   END IF;

   IF xsegtemporada THEN
      BEGIN
         SELECT nvalor1
           INTO xsegtemp1
           FROM limites
          WHERE climite = 2
            AND xmeses >= nminimo
            AND(xmeses < nmaximo
                OR nmaximo IS NULL);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            error := 103834;   -- LÍMIT NO TROBAT A LA TAULA LIMITES
            RETURN error;
         WHEN OTHERS THEN
            error := 103514;   -- ERROR AL LLEGIR DE LA TAULA LIMITES
            RETURN error;
      END;

      IF xsegtemp1 IS NOT NULL THEN
         xsegtemp1 := xsegtemp1 / 100;
      ELSE
         RETURN 103835;   -- AQUEST CAMP NO POT SER NUL
      END IF;
   END IF;

--*********** ACTUEM DEPENENT DEL PCMODO (REAL O PROVES) *******************
   IF pcmodo = 'P'
      OR pcmodo = 'N' THEN
      IF ptipomovimiento = 0 THEN
         OPEN cur_garansegxrisc;

         FETCH cur_garansegxrisc
          INTO xnriesgo, xcgarant;

         WHILE cur_garansegxrisc%FOUND LOOP
            xnasegur1 := 0;
            xnasegur2 := 0;

            BEGIN
               SELECT cclarie
                 INTO xcclarie
                 FROM estriesgos
                WHERE sseguro = psseguro
                  AND nriesgo = xnriesgo;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  CLOSE cur_garansegxrisc;

                  error := 103836;   -- RISC NO TROBAT A LA TAULA RIESGOS
                  RETURN error;
               WHEN OTHERS THEN
                  CLOSE cur_garansegxrisc;

                  error := 103509;   -- ERROR AL LLEGIR DE LA TAULA RIESGOS
                  RETURN error;
            END;

            IF xcclarie IS NULL THEN
               BEGIN
                  SELECT cclarie
                    INTO xcclarie
                    FROM codiactseg
                   WHERE cramo = pcramo
                     AND cactivi = pcactivi;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     CLOSE cur_garansegxrisc;

                     error := 103837;   -- RAM I ACTIVITAT NO TROBADES A CODIACTSEG
                     RETURN error;
                  WHEN OTHERS THEN
                     CLOSE cur_garansegxrisc;

                     error := 103510;   -- ERROR AL LLEGIR DE LA TAULA CODIACTSEG
                     RETURN error;
               END;
            END IF;

            IF xcclarie IS NOT NULL THEN
               BEGIN
                  SELECT ctipcla, ivalnor
                    INTO xctipcla, xivalnor
                    FROM codiclarie
                   WHERE cclarie = xcclarie;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     CLOSE cur_garansegxrisc;

                     error := 103838;   -- CLASSE DE RISC NO TROBADA A CODICLARIE
                     RETURN error;
                  WHEN OTHERS THEN
                     CLOSE cur_garansegxrisc;

                     error := 103511;   -- ERROR AL LLEGIR DE LA TAULA CODICLARIE
                     RETURN error;
               END;

               IF xctipcla IS NOT NULL THEN
                  BEGIN
                     SELECT DECODE(nasegur, NULL, 1, nasegur)
                       INTO xnasegur1
                       FROM estriesgos
                      WHERE sseguro = psseguro
                        AND nriesgo = NVL(xnriesgo, 1);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        CLOSE cur_garansegxrisc;

                        RETURN 103836;   -- RISC NO TROBAT A RIESGOS
                     WHEN OTHERS THEN
                        CLOSE cur_garansegxrisc;

                        RETURN 103509;   -- ERROR AL LLEGIR DE RIESGOS
                  END;

                  IF xctipcla = 2 THEN
                     xvalorconsorcio := xivalnor;

                     IF xinnomin THEN   -- ES INNOMINAT
                        xvalorconsorcio := NVL(xvalorconsorcio, 0) * xnasegur1;
                     END IF;
                  ELSIF xctipcla = 1 THEN
                     xtotcapital := f_estbasecon(psseguro, pfefecto, xnriesgo, xcgarant,
                                                 pcramo, pcmodali, pccolect, pctipseg, pcmodo,
                                                 pcactivi, psproces, pnmovimi, error);

                     IF error = 0 THEN
                        IF xinnomin THEN   -- ES INNOMINAT
                           xtotcapital := NVL(xtotcapital, 0) * xnasegur1;
                        END IF;

                        xcapitaltrobat := NVL(xtotcapital, 0) *(xivalnor / 1000);

                        IF xcgarant = 212 THEN   -- ES LA GARANTIA DE PRIMER RIESGO
                           BEGIN
                              SELECT icapital
                                INTO xcapitaltotal
                                FROM estgaranseg
                               WHERE sseguro = psseguro
                                 AND nriesgo = xnriesgo
                                 AND cgarant = xcgarant
                                 AND nmovimi = pnmovimi;
                           EXCEPTION
                              WHEN NO_DATA_FOUND THEN
                                 CLOSE cur_garansegxrisc;

                                 error := 103839;   -- GARANTIA NO TROBADA A GARANSEG
                                 RETURN error;
                              WHEN OTHERS THEN
                                 CLOSE cur_garansegxrisc;

                                 error := 103500;   -- ERROR AL LLEGIR DE LA TAULA
                                 RETURN error;   -- GARANSEG
                           END;

                           IF xinnomin THEN   -- ES INNOMINAT
                              BEGIN
                                 SELECT DECODE(nasegur, NULL, 1, nasegur)
                                   INTO xnasegur1
                                   FROM estriesgos
                                  WHERE sseguro = psseguro
                                    AND nriesgo = NVL(xnriesgo, 1);
                              EXCEPTION
                                 WHEN NO_DATA_FOUND THEN
                                    CLOSE cur_garansegxrisc;

                                    RETURN 103836;   -- RISC NO TROBAT A RIESGOS
                                 WHEN OTHERS THEN
                                    CLOSE cur_garansegxrisc;

                                    RETURN 103509;   -- ERROR AL LLEGIR DE RIESGOS
                              END;

                              xcapitaltotal := NVL(xcapitaltotal, 0) * xnasegur1;
                           END IF;

                           xpercent := (xcapitaltotal / xcapitaltrobat) * 100;

                           IF xpercent IS NOT NULL THEN
                              BEGIN
                                 SELECT nvalor1, nvalor2
                                   INTO xnvalor1, xnvalor2
                                   FROM limites
                                  WHERE climite = 1
                                    AND xpercent >= nminimo
                                    AND(xpercent < nmaximo
                                        OR nmaximo IS NULL);
                              EXCEPTION
                                 WHEN NO_DATA_FOUND THEN
                                    CLOSE cur_garansegxrisc;

                                    error := 103834;   --LÍMIT NO TROBAT A LIMITES
                                    RETURN error;
                                 WHEN OTHERS THEN
                                    CLOSE cur_garansegxrisc;

                                    error := 103514;   -- ERROR AL LLEGIR DE LA TAULA
                                    RETURN error;   -- LIMITES
                              END;

                              xcapitaltotal := xcapitaltotal * xnvalor2;
                              xcapitaltrobat := xcapitaltrobat * xnvalor1;

                              IF xcapitaltotal > xcapitaltrobat THEN
                                 xvalorconsorcio := xcapitaltotal;
                              ELSE
                                 xvalorconsorcio := xcapitaltrobat;
                              END IF;
                           END IF;
                        ELSE
                           xvalorconsorcio := xcapitaltrobat;
                        END IF;
                     ELSE
                        CLOSE cur_garansegxrisc;

                        RETURN error;
                     END IF;
                  ELSIF xctipcla = 3 THEN
                     BEGIN
                        SELECT   SUM(iconcep)
                            INTO iconcep0
                            FROM detreciboscar
                           WHERE sproces = psproces
                             AND nrecibo = pnrecibo
                             AND nriesgo = xnriesgo
                             AND cgarant = xcgarant
                             AND cconcep = 0
                        GROUP BY nriesgo, cgarant;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           NULL;
                        WHEN OTHERS THEN
                           CLOSE cur_garansegxrisc;

                           error := 103516;   -- ERROR AL LLEGIR DE DETRECIBOSCAR
                           RETURN error;
                     END;

                     IF xinnomin THEN   -- ES INNOMINAT
                        BEGIN
                           SELECT DECODE(nasegur, NULL, 1, nasegur)
                             INTO xnasegur1
                             FROM estriesgos
                            WHERE sseguro = psseguro
                              AND nriesgo = NVL(xnriesgo, 1);
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              CLOSE cur_garansegxrisc;

                              RETURN 103836;   -- RISC NO TROBAT A RIESGOS
                           WHEN OTHERS THEN
                              CLOSE cur_garansegxrisc;

                              RETURN 103509;   -- ERROR AL LLEGIR DE RIESGOS
                        END;

                        xvalorconsorcio := NVL(iconcep0, 0) * xnasegur1;
                        xvalorconsorcio := xvalorconsorcio *(xivalnor / 100);
                     ELSE
                        xvalorconsorcio := NVL(iconcep0, 0) *(xivalnor / 100);
                     END IF;
                  END IF;

                  IF xvalorconsorcio IS NOT NULL
                     AND xvalorconsorcio <> 0 THEN
                     IF xsegtemporada THEN
                        xvalorconsorcio := xvalorconsorcio * xsegtemp1;
--        ELSE
--       IF PCFORPAG <> 0 THEN
--         XVALORCONSORCIO := NVL(XVALORCONSORCIO, 0) / PCFORPAG;
--       END IF;
                     END IF;

                     xvalorconsorcio := ROUND(xvalorconsorcio, decimals);

                     IF NVL(xvalorconsorcio, 0) <> 0 THEN
                        BEGIN
                           INSERT INTO detreciboscar
                                       (sproces, nrecibo, cconcep, iconcep, cgarant,
                                        nriesgo)
                                VALUES (psproces, pnrecibo, 2, xvalorconsorcio, xcgarant,
                                        xnriesgo);

                           pgrabar := 1;
                        EXCEPTION
                           WHEN DUP_VAL_ON_INDEX THEN
                              CLOSE cur_garansegxrisc;

                              error := 102309;   -- REGISTRE DUPLICAT EN DETRECIBOSCAR
                              RETURN error;
                           WHEN OTHERS THEN
                              CLOSE cur_garansegxrisc;

                              error := 103517;   -- ERROR A L' INSERIR A DETRECIBOSCAR
                              RETURN error;
                        END;
                     END IF;
                  END IF;
               END IF;
            END IF;

            FETCH cur_garansegxrisc
             INTO xnriesgo, xcgarant;
         END LOOP;

         CLOSE cur_garansegxrisc;

         RETURN 0;
      ELSIF ptipomovimiento = 1 THEN   -- SUPLEMENTS
         OPEN cur_garansegxrisc;

         FETCH cur_garansegxrisc
          INTO xnriesgo, xcgarant;

         WHILE cur_garansegxrisc%FOUND LOOP
            xnasegur1 := 0;
            xnasegur2 := 0;
            existant := TRUE;

            BEGIN
               SELECT cclarie
                 INTO xcclarie
                 FROM estriesgos
                WHERE sseguro = psseguro
                  AND nriesgo = xnriesgo;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  CLOSE cur_garansegxrisc;

                  error := 103836;   -- RISC NO TROBAT A LA TAULA RIESGOS
                  RETURN error;
               WHEN OTHERS THEN
                  CLOSE cur_garansegxrisc;

                  error := 103509;   -- ERROR AL LLEGIR DE LA TAULA RIESGOS
                  RETURN error;
            END;

            -- OBTENIM LA GARANTIA ANTERIOR
            xcgarantant := NULL;
            xnriesgoant := NULL;
            xnmovimiant := NULL;

            BEGIN
               SELECT cgarant, nriesgo, nmovimi
                 INTO xcgarantant, xnriesgoant, xnmovimiant
                 FROM estgaranseg
                WHERE sseguro = psseguro
                  AND nriesgo = NVL(xnriesgo, nriesgo)
                  AND cgarant = NVL(xcgarant, cgarant)
                  AND nmovimi = pnmovimiant;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  existant := FALSE;   -- NO TENIM GARANTIA ANTERIOR
               WHEN OTHERS THEN
                  CLOSE cur_garansegxrisc;

                  RETURN 103500;   -- ERROR AL LLEGIR DE GARANSEG
            END;

            IF xcclarie IS NULL THEN
               BEGIN
                  SELECT cclarie
                    INTO xcclarie
                    FROM codiactseg
                   WHERE cramo = pcramo
                     AND cactivi = pcactivi;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     CLOSE cur_garansegxrisc;

                     error := 103837;   -- RAM I ACTIVITAT NO TROBADES A CODIACTSEG
                     RETURN error;
                  WHEN OTHERS THEN
                     CLOSE cur_garansegxrisc;

                     error := 103510;   -- ERROR AL LLEGIR DE LA TAULA CODIACTSEG
                     RETURN error;
               END;
            END IF;

            IF xcclarie IS NOT NULL THEN
               BEGIN
                  SELECT ctipcla, ivalnor
                    INTO xctipcla, xivalnor
                    FROM codiclarie
                   WHERE cclarie = xcclarie;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     CLOSE cur_garansegxrisc;

                     error := 103838;   -- CLASSE DE RISC NO TROBADA A CODICLARIE
                     RETURN error;
                  WHEN OTHERS THEN
                     CLOSE cur_garansegxrisc;

                     error := 103511;   -- ERROR AL LLEGIR DE LA TAULA CODICLARIE
                     RETURN error;
               END;

               IF xctipcla IS NOT NULL THEN
                  IF xctipcla = 2 THEN
                     xvalorconsorcio := 0;
                  ELSIF xctipcla = 1 THEN
                     xtotcapital := f_estbasecon(psseguro, pfefecto, xnriesgo, xcgarant,
                                                 pcramo, pcmodali, pccolect, pctipseg, pcmodo,
                                                 pcactivi, psproces, pnmovimi, error);

                     IF xinnomin THEN   -- ES INNOMINAT
                        BEGIN
                           SELECT DECODE(nasegur, NULL, 1, nasegur)
                             INTO xnasegur1
                             FROM estriesgos
                            WHERE sseguro = psseguro
                              AND nriesgo = NVL(xnriesgo, 1);
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              CLOSE cur_garansegxrisc;

                              RETURN 103836;   -- RISC NO TROBAT A RIESGOS
                           WHEN OTHERS THEN
                              CLOSE cur_garansegxrisc;

                              RETURN 103509;   -- ERROR AL LLEGIR DE RIESGOS
                        END;

                        xtotcapital := NVL(xtotcapital, 0) * xnasegur1;
                     END IF;

                     IF existant THEN
                        xfefectoant := pfefecto - 1;

                        BEGIN
                           SELECT DECODE(nasegur, NULL, 1, nasegur)
                             INTO xnasegur2
                             FROM estriesgos
                            WHERE sseguro = psseguro
                              AND nriesgo = NVL(xnriesgoant, 1);
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              CLOSE cur_garansegxrisc;

                              RETURN 103836;   -- RISC NO TROBAT A RIESGOS
                           WHEN OTHERS THEN
                              CLOSE cur_garansegxrisc;

                              RETURN 103509;   -- ERROR AL LLEGIR DE RIESGOS
                        END;

                        xtotcapitalant := f_estbasecon(psseguro, xfefectoant, xnriesgoant,
                                                       xcgarantant, pcramo, pcmodali, pccolect,
                                                       pctipseg, pcmodo, pcactivi, psproces,
                                                       xnmovimiant, error);
                     END IF;

                     IF error = 0 THEN
                        IF xinnomin THEN   -- ES INNOMINAT
                           xtotcapitalant := NVL(xtotcapitalant, 0) * xnasegur2;
                        END IF;

                        xcapitaltrobat := (NVL(xtotcapital, 0) - NVL(xtotcapitalant, 0))
                                          *(xivalnor / 1000);

                        IF xcgarant = 212 THEN   -- ES LA GARANTIA DE PRIMER RIESGO
                           BEGIN
                              SELECT icapital
                                INTO xcapitaltotal
                                FROM estgaranseg
                               WHERE sseguro = psseguro
                                 AND nriesgo = xnriesgo
                                 AND cgarant = xcgarant
                                 AND nmovimi = pnmovimi;
                           EXCEPTION
                              WHEN NO_DATA_FOUND THEN
                                 CLOSE cur_garansegxrisc;

                                 error := 103839;   -- GARANTIA NO TROBADA A GARANSEG
                                 RETURN error;
                              WHEN OTHERS THEN
                                 CLOSE cur_garansegxrisc;

                                 error := 103500;   -- ERROR AL LLEGIR DE LA TAULA
                                 RETURN error;   -- GARANSEG
                           END;

                           BEGIN
                              SELECT DECODE(nasegur, NULL, 1, nasegur)
                                INTO xnasegur1
                                FROM estriesgos
                               WHERE sseguro = psseguro
                                 AND nriesgo = NVL(xnriesgo, 1);
                           EXCEPTION
                              WHEN NO_DATA_FOUND THEN
                                 CLOSE cur_garansegxrisc;

                                 RETURN 103836;   -- RISC NO TROBAT A RIESGOS
                              WHEN OTHERS THEN
                                 CLOSE cur_garansegxrisc;

                                 RETURN 103509;   -- ERROR AL LLEGIR DE RIESGOS
                           END;

                           xcapitaltotalant := NULL;

                           BEGIN
                              SELECT icapital
                                INTO xcapitaltotalant
                                FROM estgaranseg
                               WHERE sseguro = psseguro
                                 AND nriesgo = xnriesgo
                                 AND cgarant = xcgarant
                                 AND nmovimi = pnmovimiant;
                           EXCEPTION
                              WHEN NO_DATA_FOUND THEN
                                 NULL;   -- NO HI HA ANTERIOR
                              WHEN OTHERS THEN
                                 CLOSE cur_garansegxrisc;

                                 error := 103500;   -- ERROR AL LLEGIR DE LA TAULA
                                 RETURN error;   -- GARANSEG
                           END;

                           IF xinnomin THEN   -- ES INNOMINAT
                              xcapitaltotal := NVL(xcapitaltotal, 0) * xnasegur1;
                              xcapitaltotalant := NVL(xcapitaltotalant, 0) * xnasegur1;
                           END IF;

                           xcapitaltotal := NVL(xcapitaltotal, 0) - NVL(xcapitaltotalant, 0);
                           xpercent := (xcapitaltotal / xcapitaltrobat) * 100;

                           IF xpercent IS NOT NULL THEN
                              BEGIN
                                 SELECT nvalor1, nvalor2
                                   INTO xnvalor1, xnvalor2
                                   FROM limites
                                  WHERE climite = 1
                                    AND xpercent >= nminimo
                                    AND(xpercent < nmaximo
                                        OR nmaximo IS NULL);
                              EXCEPTION
                                 WHEN NO_DATA_FOUND THEN
                                    CLOSE cur_garansegxrisc;

                                    error := 103834;   --LÍMIT NO TROBAT A LIMITES
                                    RETURN error;
                                 WHEN OTHERS THEN
                                    CLOSE cur_garansegxrisc;

                                    error := 103514;   -- ERROR AL LLEGIR DE LA TAULA
                                    RETURN error;   -- LIMITES
                              END;

                              xcapitaltotal := xcapitaltotal * xnvalor2;
                              xcapitaltrobat := xcapitaltrobat * xnvalor1;

                              IF xcapitaltotal > xcapitaltrobat THEN
                                 xvalorconsorcio := xcapitaltotal;
                              ELSE
                                 xvalorconsorcio := xcapitaltrobat;
                              END IF;
                           END IF;
                        ELSE
                           xvalorconsorcio := xcapitaltrobat;
                        END IF;
                     ELSE
                        CLOSE cur_garansegxrisc;

                        RETURN error;
                     END IF;
                  ELSIF xctipcla = 3 THEN
                     BEGIN
                        SELECT   NVL(SUM(iconcep), 0)
                            INTO iconcep0
                            FROM detreciboscar
                           WHERE sproces = psproces
                             AND nrecibo = pnrecibo
                             AND nriesgo = xnriesgo
                             AND cgarant = xcgarant
                             AND cconcep = 0
                        GROUP BY nriesgo, cgarant;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           NULL;
                        WHEN OTHERS THEN
                           CLOSE cur_garansegxrisc;

                           error := 103516;   -- ERROR AL LLEGIR DE DETRECIBOSCAR
                           RETURN error;
                     END;

                     BEGIN
                        SELECT DECODE(nasegur, NULL, 1, nasegur)
                          INTO xnasegur1
                          FROM estriesgos
                         WHERE sseguro = psseguro
                           AND nriesgo = NVL(xnriesgo, 1);
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           CLOSE cur_garansegxrisc;

                           RETURN 103836;   -- RISC NO TROBAT A RIESGOS
                        WHEN OTHERS THEN
                           CLOSE cur_garansegxrisc;

                           RETURN 103509;   -- ERROR AL LLEGIR DE RIESGOS
                     END;

                     IF xinnomin THEN   -- ES INNOMINAT
                        xvalorconsorcio := NVL(iconcep0, 0) * xnasegur1;
                        xvalorconsorcio := xvalorconsorcio *(xivalnor / 100);
                     ELSE
                        xvalorconsorcio := NVL(iconcep0, 0) *(xivalnor / 100);
                     END IF;
                  END IF;

                  IF xvalorconsorcio IS NOT NULL
                     AND xvalorconsorcio <> 0 THEN
                     IF xsegtemporada THEN
                        xvalorconsorcio := xvalorconsorcio * xsegtemp1;
                     ELSE
                        xvalorconsorcio := (NVL(xvalorconsorcio, 0) * pdifdiasanu) / 360;
                     END IF;

                     xvalorconsorcio := ROUND(xvalorconsorcio, decimals);

                     IF NVL(xvalorconsorcio, 0) <> 0 THEN
                        xinsert := TRUE;

                        IF paltarisc THEN   -- ES UN SUPLEMENT DE ALTA
                           BEGIN
                              SELECT nmovima
                                INTO xnmovima
                                FROM riesgos
                               WHERE sseguro = psseguro
                                 AND nriesgo = xnriesgo
                                 AND nmovima = pnmovimi;

                              xinsert := TRUE;
                           EXCEPTION
                              WHEN NO_DATA_FOUND THEN
                                 xinsert := FALSE;
                              WHEN OTHERS THEN
                                 CLOSE cur_garansegxrisc;

                                 RETURN 103509;   -- ERROR AL LLEGIR DE RIESGOS
                           END;
                        END IF;

                        IF xinsert THEN
                           BEGIN
                              INSERT INTO detreciboscar
                                          (sproces, nrecibo, cconcep, iconcep, cgarant,
                                           nriesgo)
                                   VALUES (psproces, pnrecibo, 2, xvalorconsorcio, xcgarant,
                                           xnriesgo);

                              pgrabar := 1;
                           EXCEPTION
                              WHEN DUP_VAL_ON_INDEX THEN
                                 CLOSE cur_garansegxrisc;

                                 error := 102309;   -- REGISTRE DUPLICAT EN DETRECIBOSCAR
                                 RETURN error;
                              WHEN OTHERS THEN
                                 CLOSE cur_garansegxrisc;

                                 error := 103517;   -- ERROR A L' INSERIR A DETRECIBOSCAR
                                 RETURN error;
                           END;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END IF;

            FETCH cur_garansegxrisc
             INTO xnriesgo, xcgarant;
         END LOOP;

         CLOSE cur_garansegxrisc;

         -- ARA BUSCAREM LES GARANTIES QUE ESTAVEN EN (FEFECTO-1) I ARA NO ESTAN
         OPEN cur_garansegant;

         FETCH cur_garansegant
          INTO xcgarant, xnriesgo;

         WHILE cur_garansegant%FOUND LOOP
            xnasegur1 := 0;
            xnasegur2 := 0;

            BEGIN
               SELECT cclarie
                 INTO xcclarie
                 FROM estriesgos
                WHERE sseguro = psseguro
                  AND nriesgo = xnriesgo;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  CLOSE cur_garansegant;

                  error := 103836;   -- RISC NO TROBAT A LA TAULA RIESGOS
                  RETURN error;
               WHEN OTHERS THEN
                  CLOSE cur_garansegant;

                  error := 103509;   -- ERROR AL LLEGIR DE LA TAULA RIESGOS
                  RETURN error;
            END;

            -- MIREM SI EXISTEIX LA GARANTIA ACTUALMENT
            xcgarantseg := NULL;
            xnriesgoseg := NULL;
            xnmovimiseg := NULL;
            xfefectoseg := NULL;

            BEGIN
               SELECT cgarant, nriesgo, nmovimi, finiefe
                 INTO xcgarantseg, xnriesgoseg, xnmovimiseg, xfefectoseg
                 FROM estgaranseg
                WHERE sseguro = psseguro
                  AND nriesgo = NVL(xnriesgo, nriesgo)
                  AND cgarant = NVL(xcgarant, cgarant)
                  AND nmovimi = pnmovimi;

               xgrabar := 0;   -- QUE NO GRABI
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  xgrabar := 1;   -- NO TENIM GARANTIA SEGUENT
               WHEN OTHERS THEN
                  CLOSE cur_garansegant;

                  RETURN 103500;   -- ERROR AL LLEGIR DE GARANSEG
            END;

            IF xgrabar = 1 THEN
               IF xcclarie IS NULL THEN
                  BEGIN
                     SELECT cclarie
                       INTO xcclarie
                       FROM codiactseg
                      WHERE cramo = pcramo
                        AND cactivi = pcactivi;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        CLOSE cur_garansegant;

                        error := 103837;   -- RAM I ACTIVITAT NO TROBADES A CODIACTSEG
                        RETURN error;
                     WHEN OTHERS THEN
                        CLOSE cur_garansegant;

                        error := 103510;   -- ERROR AL LLEGIR DE LA TAULA CODIACTSEG
                        RETURN error;
                  END;
               END IF;

               IF xcclarie IS NOT NULL THEN
                  BEGIN
                     SELECT ctipcla, ivalnor
                       INTO xctipcla, xivalnor
                       FROM codiclarie
                      WHERE cclarie = xcclarie;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        CLOSE cur_garansegant;

                        error := 103838;   -- CLASSE DE RISC NO TROBADA A CODICLARIE
                        RETURN error;
                     WHEN OTHERS THEN
                        CLOSE cur_garansegant;

                        error := 103511;   -- ERROR AL LLEGIR DE LA TAULA CODICLARIE
                        RETURN error;
                  END;

                  IF xctipcla IS NOT NULL THEN
                     IF xctipcla = 2 THEN
                        xvalorconsorcio := 0;
                     ELSIF xctipcla = 1 THEN
                        xtotcapital := f_estbasecon(psseguro, pfefecto, xnriesgo, xcgarant,
                                                    pcramo, pcmodali, pccolect, pctipseg,
                                                    pcmodo, pcactivi, psproces, pnmovimiant,
                                                    error);

                        IF error = 0 THEN
                           IF xinnomin THEN   -- ES INNOMINAT
                              BEGIN
                                 SELECT DECODE(nasegur, NULL, 1, nasegur)
                                   INTO xnasegur1
                                   FROM estriesgos
                                  WHERE sseguro = psseguro
                                    AND nriesgo = NVL(xnriesgo, 1);
                              EXCEPTION
                                 WHEN NO_DATA_FOUND THEN
                                    CLOSE cur_garansegant;

                                    RETURN 103836;   -- RISC NO TROBAT A RIESGOS
                                 WHEN OTHERS THEN
                                    CLOSE cur_garansegant;

                                    RETURN 103509;   -- ERROR AL LLEGIR DE RIESGOS
                              END;

                              xtotcapital := NVL(xtotcapital, 0) * xnasegur1;
                           END IF;

                           xcapitaltrobat := (0 - NVL(xtotcapital, 0)) *(xivalnor / 1000);

                           IF xcgarant = 212 THEN   -- ES LA GARANTIA DE PRIMER RIESGO
                              BEGIN
                                 SELECT icapital
                                   INTO xcapitaltotal
                                   FROM estgaranseg
                                  WHERE sseguro = psseguro
                                    AND nriesgo = xnriesgo
                                    AND cgarant = xcgarant
                                    AND nmovimi = pnmovimiant;
                              EXCEPTION
                                 WHEN NO_DATA_FOUND THEN
                                    CLOSE cur_garansegant;

                                    error := 103839;   -- GARANTIA NO TROBADA A GARANSEG
                                    RETURN error;
                                 WHEN OTHERS THEN
                                    CLOSE cur_garansegant;

                                    error := 103500;   -- ERROR AL LLEGIR DE LA TAULA
                                    RETURN error;   -- GARANSEG
                              END;

                              IF xinnomin THEN   -- ES INNOMINAT
                                 BEGIN
                                    SELECT DECODE(nasegur, NULL, 1, nasegur)
                                      INTO xnasegur1
                                      FROM estriesgos
                                     WHERE sseguro = psseguro
                                       AND nriesgo = NVL(xnriesgo, 1);
                                 EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                       CLOSE cur_garansegant;

                                       RETURN 103836;   -- RISC NO TROBAT A RIESGOS
                                    WHEN OTHERS THEN
                                       CLOSE cur_garansegant;

                                       RETURN 103509;   -- ERROR AL LLEGIR DE RIESGOS
                                 END;

                                 xcapitaltotal := NVL(xcapitaltotal, 0) * xnasegur1;
                              END IF;

                              xcapitaltotal := 0 - NVL(xcapitaltotal, 0);
                              xpercent := (xcapitaltotal / xcapitaltrobat) * 100;

                              IF xpercent IS NOT NULL THEN
                                 BEGIN
                                    SELECT nvalor1, nvalor2
                                      INTO xnvalor1, xnvalor2
                                      FROM limites
                                     WHERE climite = 1
                                       AND xpercent >= nminimo
                                       AND(xpercent < nmaximo
                                           OR nmaximo IS NULL);
                                 EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                       CLOSE cur_garansegant;

                                       error := 103834;   --LÍMIT NO TROBAT A LIMITES
                                       RETURN error;
                                    WHEN OTHERS THEN
                                       CLOSE cur_garansegant;

                                       error := 103514;   -- ERROR AL LLEGIR DE LA TAULA
                                       RETURN error;   -- LIMITES
                                 END;

                                 xcapitaltotal := xcapitaltotal * xnvalor2;
                                 xcapitaltrobat := xcapitaltrobat * xnvalor1;

                                 IF xcapitaltotal > xcapitaltrobat THEN
                                    xvalorconsorcio := xcapitaltotal;
                                 ELSE
                                    xvalorconsorcio := xcapitaltrobat;
                                 END IF;
                              END IF;
                           ELSE
                              xvalorconsorcio := xcapitaltrobat;
                           END IF;
                        ELSE
                           CLOSE cur_garansegant;

                           RETURN error;
                        END IF;
                     ELSIF xctipcla = 3 THEN
                        BEGIN
                           SELECT   NVL(SUM(iconcep), 0)
                               INTO iconcep0
                               FROM detreciboscar
                              WHERE sproces = psproces
                                AND nrecibo = pnrecibo
                                AND nriesgo = xnriesgo
                                AND cgarant = xcgarant
                                AND cconcep = 0
                           GROUP BY nriesgo, cgarant;
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              NULL;
                           WHEN OTHERS THEN
                              CLOSE cur_garansegant;

                              error := 103516;   -- ERROR AL LLEGIR DE DETRECIBOSCAR
                              RETURN error;
                        END;

                        IF xinnomin THEN   -- ES INNOMINAT
                           BEGIN
                              SELECT DECODE(nasegur, NULL, 1, nasegur)
                                INTO xnasegur1
                                FROM estriesgos
                               WHERE sseguro = psseguro
                                 AND nriesgo = NVL(xnriesgo, 1);
                           EXCEPTION
                              WHEN NO_DATA_FOUND THEN
                                 CLOSE cur_garansegant;

                                 RETURN 103836;   -- RISC NO TROBAT A RIESGOS
                              WHEN OTHERS THEN
                                 CLOSE cur_garansegant;

                                 RETURN 103509;   -- ERROR AL LLEGIR DE RIESGOS
                           END;

                           xvalorconsorcio := NVL(iconcep0, 0) * xnasegur1;
                           xvalorconsorcio := xvalorconsorcio *(xivalnor / 100);
                        ELSE
                           xvalorconsorcio := iconcep0 *(xivalnor / 100);
                        END IF;
                     END IF;

                     IF xvalorconsorcio IS NOT NULL
                        AND xvalorconsorcio <> 0 THEN
                        IF xsegtemporada THEN
                           xvalorconsorcio := xvalorconsorcio * xsegtemp1;
                        ELSE
                           xvalorconsorcio := (NVL(xvalorconsorcio, 0) * pdifdiasanu) / 360;
                        END IF;

                        xvalorconsorcio := ROUND(xvalorconsorcio, decimals);

                        IF NVL(xvalorconsorcio, 0) <> 0 THEN
                           BEGIN
                              INSERT INTO detreciboscar
                                          (sproces, nrecibo, cconcep, iconcep, cgarant,
                                           nriesgo)
                                   VALUES (psproces, pnrecibo, 2, xvalorconsorcio, xcgarant,
                                           xnriesgo);

                              pgrabar := 1;
                           EXCEPTION
                              WHEN DUP_VAL_ON_INDEX THEN
                                 CLOSE cur_garansegant;

                                 error := 102309;   -- REGISTRE DUPLICAT EN DETRECIBOSCAR
                                 RETURN error;
                              WHEN OTHERS THEN
                                 CLOSE cur_garansegant;

                                 error := 103517;   -- ERROR A L' INSERIR A DETRECIBOSCAR
                                 RETURN error;
                           END;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END IF;   -- IF DEL XGRABAR

            FETCH cur_garansegant
             INTO xcgarant, xnriesgo;
         END LOOP;

         CLOSE cur_garansegant;

         RETURN 0;
      ELSIF ptipomovimiento = 22 THEN   -- RENOVACIONS NO ANUALS
         RETURN 0;   -- AQUÍ NO ES CALCULA EL CONSORCI
      ELSIF ptipomovimiento = 21 THEN   -- RENOVACIONS ANUALS
         OPEN cur_garancarxrisc;

         FETCH cur_garancarxrisc
          INTO xnriesgo, xcgarant;

         WHILE cur_garancarxrisc%FOUND LOOP
            xnasegur1 := 0;
            xnasegur2 := 0;

            BEGIN
               SELECT cclarie
                 INTO xcclarie
                 FROM estriesgos
                WHERE sseguro = psseguro
                  AND nriesgo = xnriesgo;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  CLOSE cur_garancarxrisc;

                  error := 103836;   -- RISC NO TROBAT A LA TAULA RIESGOS
                  RETURN error;
               WHEN OTHERS THEN
                  CLOSE cur_garancarxrisc;

                  error := 103509;   -- ERROR AL LLEGIR DE LA TAULA RIESGOS
                  RETURN error;
            END;

            IF xcclarie IS NULL THEN
               BEGIN
                  SELECT cclarie
                    INTO xcclarie
                    FROM codiactseg
                   WHERE cramo = pcramo
                     AND cactivi = pcactivi;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     CLOSE cur_garancarxrisc;

                     error := 103837;   -- RAM I ACTIVITAT NO TROBADES A CODIACTSEG
                     RETURN error;
                  WHEN OTHERS THEN
                     CLOSE cur_garancarxrisc;

                     error := 103510;   -- ERROR AL LLEGIR DE LA TAULA CODIACTSEG
                     RETURN error;
               END;
            END IF;

            IF xcclarie IS NOT NULL THEN
               BEGIN
                  SELECT ctipcla, ivalnor
                    INTO xctipcla, xivalnor
                    FROM codiclarie
                   WHERE cclarie = xcclarie;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     CLOSE cur_garancarxrisc;

                     error := 103838;   -- CLASSE DE RISC NO TROBADA A CODICLARIE
                     RETURN error;
                  WHEN OTHERS THEN
                     CLOSE cur_garancarxrisc;

                     error := 103511;   -- ERROR AL LLEGIR DE LA TAULA CODICLARIE
                     RETURN error;
               END;

               IF xctipcla IS NOT NULL THEN
                  IF xctipcla = 2 THEN
                     xvalorconsorcio := xivalnor;

                     IF xinnomin THEN   -- ES INNOMINAT
                        BEGIN
                           SELECT DECODE(nasegur, NULL, 1, nasegur)
                             INTO xnasegur1
                             FROM estriesgos
                            WHERE sseguro = psseguro
                              AND nriesgo = NVL(xnriesgo, 1);
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              CLOSE cur_garancarxrisc;

                              RETURN 103836;   -- RISC NO TROBAT A RIESGOS
                           WHEN OTHERS THEN
                              CLOSE cur_garancarxrisc;

                              RETURN 103509;   -- ERROR AL LLEGIR DE RIESGOS
                        END;

                        xvalorconsorcio := NVL(xvalorconsorcio, 0) * xnasegur1;
                     END IF;
                  ELSIF xctipcla = 1 THEN
                     xtotcapital := f_estbasecon(psseguro, pfefecto, xnriesgo, xcgarant,
                                                 pcramo, pcmodali, pccolect, pctipseg, pcmodo,
                                                 pcactivi, psproces, pnmovimi, error);

                     IF error = 0 THEN
                        IF xinnomin THEN   -- ES INNOMINAT
                           BEGIN
                              SELECT DECODE(nasegur, NULL, 1, nasegur)
                                INTO xnasegur1
                                FROM estriesgos
                               WHERE sseguro = psseguro
                                 AND nriesgo = NVL(xnriesgo, 1);
                           EXCEPTION
                              WHEN NO_DATA_FOUND THEN
                                 CLOSE cur_garancarxrisc;

                                 RETURN 103836;   -- RISC NO TROBAT A RIESGOS
                              WHEN OTHERS THEN
                                 CLOSE cur_garancarxrisc;

                                 RETURN 103509;   -- ERROR AL LLEGIR DE RIESGOS
                           END;

                           xtotcapital := NVL(xtotcapital, 0) * xnasegur1;
                        END IF;

                        xcapitaltrobat := NVL(xtotcapital, 0) *(xivalnor / 1000);

                        IF xcgarant = 212 THEN   -- ES LA GARANTIA DE PRIMER RIESGO
                           BEGIN
                              SELECT icapital
                                INTO xcapitaltotal
                                FROM estgaranseg
                               WHERE sseguro = psseguro
                                 AND nriesgo = xnriesgo
                                 AND cgarant = xcgarant
                                 AND nmovimi = pnmovimi;
                           EXCEPTION
                              WHEN NO_DATA_FOUND THEN
                                 CLOSE cur_garancarxrisc;

                                 error := 103839;   -- GARANTIA NO TROBADA A GARANSEG
                                 RETURN error;
                              WHEN OTHERS THEN
                                 CLOSE cur_garancarxrisc;

                                 error := 103500;   -- ERROR AL LLEGIR DE LA TAULA
                                 RETURN error;   -- GARANSEG
                           END;

                           IF xinnomin THEN   -- ES INNOMINAT
                              BEGIN
                                 SELECT DECODE(nasegur, NULL, 1, nasegur)
                                   INTO xnasegur1
                                   FROM estriesgos
                                  WHERE sseguro = psseguro
                                    AND nriesgo = NVL(xnriesgo, 1);
                              EXCEPTION
                                 WHEN NO_DATA_FOUND THEN
                                    CLOSE cur_garancarxrisc;

                                    RETURN 103836;   -- RISC NO TROBAT A RIESGOS
                                 WHEN OTHERS THEN
                                    CLOSE cur_garancarxrisc;

                                    RETURN 103509;   -- ERROR AL LLEGIR DE RIESGOS
                              END;

                              xcapitaltotal := NVL(xcapitaltotal, 0) * xnasegur1;
                           END IF;

                           xpercent := (xcapitaltotal / xcapitaltrobat) * 100;

                           IF xpercent IS NOT NULL THEN
                              BEGIN
                                 SELECT nvalor1, nvalor2
                                   INTO xnvalor1, xnvalor2
                                   FROM limites
                                  WHERE climite = 1
                                    AND xpercent >= nminimo
                                    AND(xpercent < nmaximo
                                        OR nmaximo IS NULL);
                              EXCEPTION
                                 WHEN NO_DATA_FOUND THEN
                                    CLOSE cur_garancarxrisc;

                                    error := 103834;   --LÍMIT NO TROBAT A LIMITES
                                    RETURN error;
                                 WHEN OTHERS THEN
                                    CLOSE cur_garancarxrisc;

                                    error := 103514;   -- ERROR AL LLEGIR DE LA TAULA
                                    RETURN error;   -- LIMITES
                              END;

                              xcapitaltotal := xcapitaltotal * xnvalor2;
                              xcapitaltrobat := xcapitaltrobat * xnvalor1;

                              IF xcapitaltotal > xcapitaltrobat THEN
                                 xvalorconsorcio := xcapitaltotal;
                              ELSE
                                 xvalorconsorcio := xcapitaltrobat;
                              END IF;
                           END IF;
                        ELSE
                           xvalorconsorcio := xcapitaltrobat;
                        END IF;
                     ELSE
                        CLOSE cur_garancarxrisc;

                        RETURN error;
                     END IF;
                  ELSIF xctipcla = 3 THEN
                     BEGIN
                        SELECT   SUM(iconcep)
                            INTO iconcep0
                            FROM detreciboscar
                           WHERE sproces = psproces
                             AND nrecibo = pnrecibo
                             AND nriesgo = xnriesgo
                             AND cgarant = xcgarant
                             AND cconcep = 0
                        GROUP BY nriesgo, cgarant;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           NULL;
                        WHEN OTHERS THEN
                           CLOSE cur_garancarxrisc;

                           error := 103516;   -- ERROR AL LLEGIR DE DETRECIBOSCAR
                           RETURN error;
                     END;

                     IF xinnomin THEN   -- ES INNOMINAT
                        BEGIN
                           SELECT DECODE(nasegur, NULL, 1, nasegur)
                             INTO xnasegur1
                             FROM estriesgos
                            WHERE sseguro = psseguro
                              AND nriesgo = NVL(xnriesgo, 1);
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              CLOSE cur_garancarxrisc;

                              RETURN 103836;   -- RISC NO TROBAT A RIESGOS
                           WHEN OTHERS THEN
                              CLOSE cur_garancarxrisc;

                              RETURN 103509;   -- ERROR AL LLEGIR DE RIESGOS
                        END;

                        xvalorconsorcio := NVL(iconcep0, 0) * xnasegur1;
                        xvalorconsorcio := xvalorconsorcio *(xivalnor / 100);
                     ELSE
                        xvalorconsorcio := NVL(iconcep0, 0) *(xivalnor / 100);
                     END IF;
                  END IF;

                  IF xvalorconsorcio IS NOT NULL
                     AND xvalorconsorcio <> 0 THEN
                     IF xsegtemporada THEN
                        xvalorconsorcio := xvalorconsorcio * xsegtemp1;
--        ELSE
--       IF PCFORPAG <> 0 THEN
--         XVALORCONSORCIO := NVL(XVALORCONSORCIO, 0) / PCFORPAG;
--       END IF;
                     END IF;

                     xvalorconsorcio := ROUND(xvalorconsorcio, decimals);

                     IF NVL(xvalorconsorcio, 0) <> 0 THEN
                        BEGIN
                           INSERT INTO detreciboscar
                                       (sproces, nrecibo, cconcep, iconcep, cgarant,
                                        nriesgo)
                                VALUES (psproces, pnrecibo, 2, xvalorconsorcio, xcgarant,
                                        xnriesgo);

                           pgrabar := 1;
                        EXCEPTION
                           WHEN DUP_VAL_ON_INDEX THEN
                              CLOSE cur_garancarxrisc;

                              error := 102309;   -- REGISTRE DUPLICAT EN DETRECIBOSCAR
                              RETURN error;
                           WHEN OTHERS THEN
                              CLOSE cur_garancarxrisc;

                              error := 103517;   -- ERROR A L' INSERIR A DETRECIBOSCAR
                              RETURN error;
                        END;
                     END IF;
                  END IF;
               END IF;
            END IF;

            FETCH cur_garancarxrisc
             INTO xnriesgo, xcgarant;
         END LOOP;

         CLOSE cur_garancarxrisc;

         RETURN 0;
      ELSE
         RETURN 101901;   -- PAS DE PARÀMETRES INCORRECTE A LA FUNCIÓ
      END IF;
   ELSE
      RETURN 101901;   -- PAS DE PARÀMETRES INCORRECTES A LA FUNCIÓ
   END IF;
-- BUG 21546_108724 - 08/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
EXCEPTION
   WHEN OTHERS THEN
      IF cur_garansegxrisc%ISOPEN THEN
         CLOSE cur_garansegxrisc;
      END IF;

      IF cur_garansegant%ISOPEN THEN
         CLOSE cur_garansegant;
      END IF;

      IF cur_garancarxrisc%ISOPEN THEN
         CLOSE cur_garancarxrisc;
      END IF;

      RETURN 140999;
END f_estconsorci;

/

  GRANT EXECUTE ON "AXIS"."F_ESTCONSORCI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ESTCONSORCI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ESTCONSORCI" TO "PROGRAMADORESCSI";
