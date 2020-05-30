--------------------------------------------------------
--  DDL for Package Body PAC_CARGAS_COL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CARGAS_COL" IS
---------------------------------------------
   FUNCTION f_texte(plinia IN VARCHAR2, pseparador IN VARCHAR2, pordre IN NUMBER)
      RETURN VARCHAR2 IS
      ldesde         NUMBER;
      lhasta         NUMBER;
      ltexte         VARCHAR2(300);
   BEGIN
      IF pordre > 1 THEN
         ldesde := INSTR(plinia, pseparador, 1, pordre - 1) + 1;
      ELSE
         ldesde := 1;
      END IF;

      lhasta := INSTR(plinia, pseparador, 1, pordre);
      ltexte := SUBSTR(plinia, ldesde, lhasta - ldesde);
      RETURN ltexte;
   EXCEPTION
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line(SQLERRM);
         p_tab_error(f_sysdate, f_user, 'pac_cargas_col', 1, 'f_texte.Error f_texte.',
                     SQLERRM);
         RETURN NULL;
   END;

-----------------------------------------------------------------------------------------
   FUNCTION f_carrega_fitxer(
      psproces OUT NUMBER,
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psperson IN NUMBER,
      pcdomici IN NUMBER,
      pnpoliza IN NUMBER,
      pfefecto IN DATE,
      pfvencim IN DATE,
      pcobrar IN NUMBER,
      pcactivi IN NUMBER,
      pcoficin IN NUMBER,
      pcagente IN NUMBER,
      ptnatrie IN VARCHAR2,
      ppath IN VARCHAR2,
      pnomfitx IN VARCHAR2,
      psep IN VARCHAR2)
      RETURN NUMBER IS
-----------------------------------------------------------------------------------------
      lfitxer        UTL_FILE.file_type;
      llinia         VARCHAR2(1000);
      lnlinea        NUMBER;
      lprimer        NUMBER := 1;
      lnif_empresa   VARCHAR2(14);
      lnnumnif       VARCHAR2(14);
      num_err        NUMBER;
      l_carregat     NUMBER;
   BEGIN
      num_err := f_procesini(f_user, pcempres, 'ALTA_COL', 'ALTA PP PIMES', psproces);
      COMMIT;

      SELECT COUNT(*)
        INTO l_carregat
        FROM cap_carrega_col
       WHERE tnomfitx = pnomfitx;

      IF l_carregat > 0 THEN
         RETURN 105245;
      END IF;

      BEGIN
         SELECT nnumnif
           INTO lnnumnif
           FROM personas
          WHERE sperson = psperson;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 100524;
      END;

      lfitxer := UTL_FILE.fopen(ppath, pnomfitx, 'r');
      lnlinea := 1;

      LOOP
         BEGIN
            UTL_FILE.get_line(lfitxer, llinia);

            -- Les dades del prenedor (persona i adreça) venen informades per paràmetre
            -- i s'obtenen de la pantalla, només agaferem les dades bancàries, però
            -- comprovarem que el nif sigui el mateix
            IF lprimer = 1 THEN
               -- Saltem la capçalera del fitxer
               UTL_FILE.get_line(lfitxer, llinia);
               lnif_empresa := f_texte(llinia, psep, 3);

               IF lnif_empresa <> lnnumnif THEN
                  RETURN 111650;
               END IF;

               lprimer := 0;

               -- Gravem la capçalera de càrrega
               BEGIN
                  INSERT INTO cap_carrega_col
                              (sproces, tnomfitx, cempres, cramo, cmodali, ctipseg,
                               ccolect, sperson, cdomici, npoliza, fefecto, fvencim,
                               ccobrar, cactivi, coficin, cagente, tnatrie, pathfitx, sep)
                       VALUES (psproces, pnomfitx, pcempres, pcramo, pcmodali, pctipseg,
                               pccolect, psperson, pcdomici, pnpoliza, pfefecto, pfvencim,
                               pcobrar, pcactivi, pcoficin, pcagente, ptnatrie, ppath, psep);
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 140740;
               END;
            END IF;

            -- Insertem el registre
            INSERT INTO carrega_col
                        (sproces, nlinea, polissa_ini,
                         tapelli_promo,
                         nnumnif_promo,
                         csiglas_promo,
                         tdomici_pro,
                         nnumvia_pro,
                         t_comple_promo,
                         cpostal_promo,
                         tpoblac_promo,
                         tprovin_promo,
                         cbancar_promo,
                         cfiscal_promo,
                         ctipreg,
                         tidenti_asseg,
                         nnumnif_asseg,
                         tnom_asseg,
                         tapelli1_asseg,
                         tapelli2_asseg,
                         csexper_asseg,
                         cestciv_asseg,
                         fnacimi_asseg,
                         isalari_asseg,
                         fingres_asseg,
                         cfiscal_asseg,
                         csiglas_asseg,
                         tdomici_asseg,
                         nnumvia_asseg,
                         tcomple_asseg,
                         cpostal_asseg,
                         tpoblac_asseg,
                         tprovin_asseg,
                         cbancar_asseg,
                         iapoini_promo,
                         iapoini_asseg,
                         iprianu_per,
                         papor_promo,
                         iapor_promo,
                         fcarpro_promo,
                         fcarpro_asseg,
                         cforpag_prom,
                         cforpag_asseg,
                         crevali,
                         prevali,
                         frevali,
                         tbenef1,
                         tbenef2,
                         tbenef3, cestado)
                 VALUES (psproces, lnlinea, SUBSTR(f_texte(llinia, psep, 1), 1, 15),
                         SUBSTR(f_texte(llinia, psep, 2), 1, 20),
                         SUBSTR(f_texte(llinia, psep, 3), 1, 14),
                         SUBSTR(f_texte(llinia, psep, 4), 1, 2),
                         SUBSTR(f_texte(llinia, psep, 5), 1, 40),
                         SUBSTR(f_texte(llinia, psep, 6), 1, 5),
                         SUBSTR(f_texte(llinia, psep, 7), 1, 15),
                         SUBSTR(f_texte(llinia, psep, 8), 1, 30),   --3606 jdomingo 29/11/2007  canvi format codi postal - el nou tamany és 30
                         SUBSTR(f_texte(llinia, psep, 9), 1, 50),
                         SUBSTR(f_texte(llinia, psep, 10), 1, 30),
                         SUBSTR(REPLACE(f_texte(llinia, psep, 11), '-', NULL), 1, 20),
                         SUBSTR(f_texte(llinia, psep, 12), 1, 1),
                         SUBSTR(f_texte(llinia, psep, 13), 1, 1),
                         SUBSTR(f_texte(llinia, psep, 14), 1, 1),
                         SUBSTR(f_texte(llinia, psep, 15), 1, 14),
                         SUBSTR(f_texte(llinia, psep, 16), 1, 20),
                         SUBSTR(f_texte(llinia, psep, 17), 1, 40),
                         SUBSTR(f_texte(llinia, psep, 18), 1, 19),
                         SUBSTR(f_texte(llinia, psep, 19), 1, 1),
                         SUBSTR(f_texte(llinia, psep, 20), 1, 1),
                         SUBSTR(f_texte(llinia, psep, 21), 1, 10),
                         SUBSTR(f_texte(llinia, psep, 22), 1, 17),
                         SUBSTR(f_texte(llinia, psep, 23), 1, 10),
                         SUBSTR(f_texte(llinia, psep, 24), 1, 1),
                         SUBSTR(f_texte(llinia, psep, 25), 1, 2),
                         SUBSTR(f_texte(llinia, psep, 26), 1, 40),
                         SUBSTR(f_texte(llinia, psep, 27), 1, 5),
                         SUBSTR(f_texte(llinia, psep, 28), 1, 15),
                         SUBSTR(f_texte(llinia, psep, 29), 1, 30),   --3606 jdomingo 29/11/2007  canvi format codi postal - el nou tamany és 30
                         SUBSTR(f_texte(llinia, psep, 30), 1, 50),
                         SUBSTR(f_texte(llinia, psep, 31), 1, 30),
                         SUBSTR(REPLACE(f_texte(llinia, psep, 32), '-', NULL), 1, 20),
                         SUBSTR(f_texte(llinia, psep, 33), 1, 17),
                         SUBSTR(f_texte(llinia, psep, 34), 1, 17),
                         SUBSTR(f_texte(llinia, psep, 35), 1, 17),
                         SUBSTR(f_texte(llinia, psep, 36), 1, 7),
                         SUBSTR(f_texte(llinia, psep, 37), 1, 17),
                         SUBSTR(f_texte(llinia, psep, 38), 1, 10),
                         SUBSTR(f_texte(llinia, psep, 39), 1, 10),
                         SUBSTR(f_texte(llinia, psep, 40), 1, 2),
                         SUBSTR(f_texte(llinia, psep, 41), 1, 2),
                         SUBSTR(f_texte(llinia, psep, 42), 1, 1),
                         SUBSTR(f_texte(llinia, psep, 43), 1, 7),
                         SUBSTR(f_texte(llinia, psep, 44), 1, 10),
                         SUBSTR(f_texte(llinia, psep, 45), 1, 100),
                         SUBSTR(f_texte(llinia, psep, 46), 1, 100),
                         SUBSTR(f_texte(llinia, psep, 47), 1, 100), 0);

            lnlinea := lnlinea + 1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               EXIT;
            WHEN OTHERS THEN
               --DBMS_OUTPUT.put_line(' 140706 ' || SQLERRM);
               p_tab_error(f_sysdate, f_user, 'pac_cargas_col', 1,
                           'f_carrega_fitxer.Error f_carrega_fitxer.', SQLERRM);
               num_err := f_procesfin(psproces, 140706);
               UTL_FILE.fclose_all;
               RETURN 140706;
         END;
      END LOOP;

      num_err := f_procesfin(psproces, 0);
      UTL_FILE.fclose_all;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 103187;
   END f_carrega_fitxer;

-------------------------------------------------------------------------------------
   FUNCTION f_tracta_persones(psproces IN NUMBER, pcidioma IN NUMBER)
      RETURN NUMBER IS
-------------------------------------------------------------------------------------
   -- cursor de registres a tractar
      CURSOR c_pers(wsproces NUMBER) IS
         SELECT *
           FROM carrega_col
          WHERE sproces = wsproces
            AND cestado = 0;   -- Primer pas, tractar les persones

      num_err        NUMBER;
      num_err2       NUMBER;
      lsperson       NUMBER;
      lcdomici       NUMBER;
      ltexto         VARCHAR2(400);
      lnumlin        NUMBER;
   BEGIN
      --DBMS_OUTPUT.put_line(' sproces ' || psproces);
      FOR v_pers IN c_pers(psproces) LOOP
         -- crida a la funció que mira si existeix la persona i sino la crea
         -- crea també l'adreça
         num_err := pac_cargas.persona(psproces, 1, v_pers.tidenti_asseg,
                                       v_pers.nnumnif_asseg, v_pers.tnom_asseg,
                                       v_pers.tapelli1_asseg, v_pers.tapelli2_asseg,
                                       v_pers.csexper_asseg, v_pers.cestciv_asseg,
                                       v_pers.fnacimi_asseg, v_pers.csiglas_asseg,
                                       v_pers.tdomici_asseg, v_pers.nnumvia_asseg,
                                       v_pers.tcomple_asseg, v_pers.cpostal_asseg,
                                       v_pers.tpoblac_asseg, v_pers.tprovin_asseg, lsperson,
                                       lcdomici);

         IF num_err = 0 THEN
            UPDATE carrega_col
               SET cestado = 1,
                   sperson = lsperson,
                   cdomici = lcdomici,
                   cerror = 0
             WHERE sproces = v_pers.sproces
               AND nlinea = v_pers.nlinea;

            COMMIT;
         ELSE
            ROLLBACK;
            ltexto := f_axis_literales(num_err, pcidioma);
            num_err2 := f_proceslin(psproces, ltexto || '-' || pcidioma, psproces, lnumlin);

            UPDATE carrega_col
               SET cerror = num_err
             WHERE sproces = v_pers.sproces
               AND nlinea = v_pers.nlinea;

            COMMIT;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 140714;
   END f_tracta_persones;

-------------------------------------------------------------------------------------
   FUNCTION f_alta_certif(
      pcempres IN NUMBER,
      pfefecto IN DATE,
      psproces IN NUMBER,
      pnlinea IN NUMBER,
      pcestado IN OUT NUMBER,
      pnpoliza IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psperson_promo IN NUMBER,
      psperson_asseg IN NUMBER,
      pcbancar_promo IN VARCHAR2,
      pcbancar_asseg IN VARCHAR2,
      pcdomici_promo IN NUMBER,
      pcdomici_asseg IN NUMBER,
      piapoini_promo IN NUMBER,
      piapoini_asseg IN NUMBER,
      piprianu IN NUMBER,
      papor_promo IN NUMBER,
      piapor_promo IN NUMBER,
      pfcarpro_promo IN DATE,
      pfcarpro_asseg IN DATE,
      pcforpag_promo IN NUMBER,
      pcforpag_asseg IN NUMBER,
      pcrevali IN NUMBER,
      pprevali IN NUMBER,
      pfrevali IN DATE,
      ptbenef1 IN VARCHAR2,
      ptbenef2 IN VARCHAR2,
      ptbenef3 IN VARCHAR2,
      ppolissa_ini IN NUMBER,
      pcidioma IN NUMBER,
      pcoficin IN NUMBER,
      pcagente IN NUMBER,
      pfvencim IN DATE,
      pcactivi IN NUMBER,
      ptnatrie IN VARCHAR2,
      pmoneda IN NUMBER,
      pcfiscal_promo IN NUMBER,
      pcfiscal_asseg IN NUMBER,
      ppimport_promo IN NUMBER,
      ppimport_asseg IN NUMBER,
      piimport_promo IN NUMBER,
      piimport_asseg IN NUMBER,
      pcobrar IN NUMBER,
      psseguro IN OUT NUMBER)
      RETURN NUMBER IS
-------------------------------------------------------------------------------------
      lncertif       NUMBER;
      lccobban       NUMBER;
      lprod          productos%ROWTYPE;
      lproducte      VARCHAR2(4);
      l282           garanpro%ROWTYPE;
      l48            garanpro%ROWTYPE;
      lnmovimi       NUMBER;
      num_err        NUMBER;
      lnorden_promo  NUMBER;
      lnorden_asseg  NUMBER;
      lnordcla       NUMBER;
      lindice        NUMBER;
      lindice_e      NUMBER;
      lindice_t      NUMBER;
      lnrecibo       NUMBER;
      llinea         NUMBER;
      lsmovagr       NUMBER := 0;
      lnliqmen       NUMBER;
      lnliqlin       NUMBER;
      lnparpla       NUMBER;
      lcdelega       NUMBER;
      lparticipacion NUMBER;
      lnsuplem       NUMBER;
      ldivisa        NUMBER;
      lfmovini       DATE;
      pmensaje       VARCHAR2(500);   -- BUG 27642 - FAL - 30/04/2014
   BEGIN
      -- Obtenim dades generals de les garanties
      SELECT *
        INTO l282
        FROM garanpro
       WHERE cramo = pcramo
         AND cmodali = pcmodali
         AND ctipseg = pctipseg
         AND ccolect = pccolect
         AND cactivi = pcactivi
         AND cgarant = 282;

      SELECT *
        INTO l48
        FROM garanpro
       WHERE cramo = pcramo
         AND cmodali = pcmodali
         AND ctipseg = pctipseg
         AND ccolect = pccolect
         AND cactivi = pcactivi
         AND cgarant = 48;

      IF pcestado = 1 THEN
         -- Obtenim el nº de certificat per la pòlissa
         BEGIN
            SELECT NVL(MAX(ncertif), 0) + 1
              INTO lncertif
              FROM seguros
             WHERE npoliza = pnpoliza;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 100500;
         END;

         -- Obtenim les dades del producte
         BEGIN
            SELECT *
              INTO lprod
              FROM productos
             WHERE cramo = pcramo
               AND cmodali = pcmodali
               AND ccolect = pccolect
               AND ctipseg = pctipseg;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 102705;
         END;

         -- Obtenir cobrador bancari
         BEGIN
            SELECT ccobban
              INTO lccobban
              FROM cobbancariosel
             WHERE cramo = pcramo
               AND cmodali = pcmodali
               AND ctipseg = pctipseg
               AND ccolect = pccolect;
         EXCEPTION
            WHEN TOO_MANY_ROWS THEN
               SELECT MIN(ccobban)
                 INTO lccobban
                 FROM cobbancariosel
                WHERE cramo = pcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect = pccolect;
            WHEN NO_DATA_FOUND THEN
               lccobban := NULL;
         END;

         -- Obtenim la seq. de seguros
         BEGIN
            SELECT sseguro.NEXTVAL
              INTO psseguro
              FROM DUAL;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 140719;
         END;

         --Dades i insert a CNVPOLIZAS
         BEGIN
            SELECT sistema
              INTO lproducte
              FROM cnvproductos
             WHERE cramo = pcramo
               AND cmodal = pcmodali
               AND ctipseg = pctipseg
               AND ccolect = pccolect;
         EXCEPTION
            WHEN OTHERS THEN
               lproducte := '';
         END;

         BEGIN
            INSERT INTO cnvpolizas
                        (sseguro, sistema, polissa_ini, npoliza, producte, ram, moda,
                         tipo, cole)
                 VALUES (psseguro, 'MU', ppolissa_ini, pnpoliza, lproducte, pcramo, pcmodali,
                         pctipseg, pccolect);
         EXCEPTION
            WHEN OTHERS THEN
               --DBMS_OUTPUT.put_line(SQLERRM);
               p_tab_error(f_sysdate, f_user, 'pac_cargas_col', 1,
                           'f_alta_certif.Error f_alta_certif.', SQLERRM);
               RETURN 140757;
         END;

         -- Insert a seguros
         BEGIN
            INSERT INTO seguros
                        (sseguro, cmodali, ccolect, ctipseg, casegur, cagente, cramo,
                         npoliza, ncertif, nsuplem, fefecto, creafac, ctarman, cobjase,
                         ctipreb, cactivi, ccobban, ctipcoa, ctiprea, crecman, creccob,
                         ctipcom, fvencim, femisio, fanulac, fcancel, csituac, cbancar,
                         ctipcol, fcarant, fcarpro, fcaranu, cduraci, nduraci, nanuali,
                         iprianu, cidioma, nfracci, cforpag, pdtoord,
                         nrenova,
                         crecfra, tasegur, creteni, ndurcob, sciacoa, pparcoa, npolcoa,
                         nsupcoa, tnatrie, pdtocom, prevali, irevali, ncuacoa, nedamed,
                         crevali, cempres, cagrpro)
                 VALUES (psseguro, pcmodali, pccolect, pctipseg, 1, pcagente, pcramo,
                         pnpoliza, lncertif, 0, pfefecto, 0, lprod.ctarman, lprod.cobjase,
                         lprod.ctipreb, pcactivi, lccobban, 0, 0, 0, lprod.creccob,
                         0, pfvencim, f_sysdate, NULL, NULL, 4, pcbancar_promo,
                         1, NULL, NULL, NULL, lprod.cduraci, 0, 1,
                         piprianu, pcidioma, 1, 0, 0,
                         pac_cargas.diames(LEAST(NVL(pfcarpro_promo, '31/12/2999'),
                                                 NVL(pfcarpro_asseg, '31/12/2999'))),
                         lprod.crecfra, NULL, 0, 0, NULL, NULL, NULL,
                         NULL, ptnatrie, 0, NULL, NULL, NULL, NULL,
                         0, pcempres, lprod.cagrpro);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 110165;
         END;

         -- inicialitzem nsuplem
         lnsuplem := 1;
         -- Insertem el moviment, el primer es de nova producció
         num_err := f_movseguro(psseguro, NULL, 100, 0, pfefecto, NULL, 0, 0, NULL, lnmovimi,
                                NULL, NULL, NULL, NULL);

         --DBMS_OUTPUT.put_line(' nmovimi ' || lnmovimi);
         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         -- Insertem historicooficinas
         BEGIN
            INSERT INTO historicooficinas
                        (sseguro, finicio, ffin, coficin)
                 VALUES (psseguro, pfefecto, NULL, pcoficin);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 140721;
         END;

         -- Insertem el prenedor
         BEGIN
            INSERT INTO tomadores
                        (sperson, sseguro, nordtom, cdomici)
                 VALUES (psperson_promo, psseguro, 1, pcdomici_promo);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 110167;
         END;

         -- Insert  a asegurados
         BEGIN
            INSERT INTO asegurados
                        (sseguro, sperson, norden, cdomici, ffecini)
                 VALUES (psseguro, psperson_asseg, 1, pcdomici_asseg, pfefecto);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 110168;
         END;

         -- Insertem els aportants
         IF lprod.ctipreb = 4 THEN
            lnorden_promo := 1;
            lnorden_asseg := 1;

            IF pcforpag_promo IS NOT NULL THEN
               BEGIN
                  INSERT INTO aportaseg
                              (sseguro, norden, sperson, finiefe, ffinefe,
                               cbancar, cforpag,
                               ctipimp, pimport,
                               iimport, fcarpro, fcarant, cfiscal, ctipo)
                       VALUES (psseguro, lnorden_promo, psperson_promo, pfefecto, NULL,
                               pcbancar_promo, pcforpag_promo,
                               DECODE(ppimport_promo, NULL, 2, 1), ppimport_promo,
                               piimport_promo, pfcarpro_promo, NULL, pcfiscal_promo, 4);

                  lnorden_asseg := 2;
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 140613;
               END;
            END IF;

            IF pcforpag_asseg IS NOT NULL THEN
               BEGIN
                  INSERT INTO aportaseg
                              (sseguro, norden, sperson, finiefe, ffinefe,
                               cbancar, cforpag,
                               ctipimp, pimport,
                               iimport, fcarpro, fcarant, cfiscal, ctipo)
                       VALUES (psseguro, lnorden_asseg, psperson_asseg, pfefecto, NULL,
                               pcbancar_asseg, pcforpag_asseg,
                               DECODE(ppimport_asseg, NULL, 2, 1), ppimport_asseg,
                               piimport_asseg, pfcarpro_asseg, NULL, pcfiscal_asseg, 4);
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 140613;
               END;
            END IF;
         END IF;

         -- Insertem a riesgos
         BEGIN
            --MCC- 02/04/2009 - BUG 0009593: IAX - Incluir actividad a nivel de riesgo
            INSERT INTO riesgos
                        (nriesgo, sseguro, nmovima, fefecto, sperson, cclarie, nmovimb,
                         fanulac, tnatrie, cdomici, nasegur, cactivi)
                 VALUES (1, psseguro, 1, pfefecto, psperson_asseg, NULL, NULL,
                         NULL, NULL, pcdomici_asseg, NULL, pcactivi);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 110169;
         END;

         --Insert a claususeg
         FOR vcla IN (SELECT sclagen
                        FROM clausupro
                       WHERE cramo = pcramo
                         AND cmodali = pcmodali
                         AND ctipseg = pctipseg
                         AND ccolect = pccolect
                         AND ctipcla = 2) LOOP
            IF vcla.sclagen IS NOT NULL THEN
               BEGIN
                  INSERT INTO claususeg
                              (sseguro, nmovimi, sclagen, finiclau, ffinclau)
                       VALUES (psseguro, lnmovimi, vcla.sclagen, pfefecto, NULL);
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 102427;
               END;
            END IF;
         END LOOP;

         -- Insertem beneficiaris
         IF lprod.sclaben IS NOT NULL THEN
            BEGIN
               INSERT INTO claubenseg
                           (finiclau, sclaben, sseguro, nriesgo, nmovimi)
                    VALUES (pfefecto, lprod.sclaben, psseguro, 1, lnmovimi);
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 140272;
            END;
         END IF;

         -- Insertem beneficiaris
         lnordcla := 1;

         IF ptbenef1 IS NOT NULL THEN
            BEGIN
               INSERT INTO clausuesp
                           (nmovimi, sseguro, cclaesp, nordcla, nriesgo, finiclau, sclagen,
                            tclaesp, ffinclau)
                    VALUES (lnmovimi, psseguro, 1, lnordcla, 1, pfefecto, NULL,
                            ptbenef1, NULL);

               lnordcla := lnordcla + 1;
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 140729;
            END;
         END IF;

         IF ptbenef2 IS NOT NULL THEN
            BEGIN
               INSERT INTO clausuesp
                           (nmovimi, sseguro, cclaesp, nordcla, nriesgo, finiclau, sclagen,
                            tclaesp, ffinclau)
                    VALUES (lnmovimi, psseguro, 1, lnordcla, 1, pfefecto, NULL,
                            ptbenef2, NULL);

               lnordcla := lnordcla + 1;
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 140729;
            END;
         END IF;

         IF ptbenef3 IS NOT NULL THEN
            BEGIN
               INSERT INTO clausuesp
                           (nmovimi, sseguro, cclaesp, nordcla, nriesgo, finiclau, sclagen,
                            tclaesp, ffinclau)
                    VALUES (lnmovimi, psseguro, 1, lnordcla, 1, pfefecto, NULL,
                            ptbenef3, NULL);
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 140729;
            END;
         END IF;

         -- Gravem les garanties del primer moviment :
         -- Les obligatòries
         -- La extra inicial (del promotor si ni ha o la de l'asseg.)
         FOR voblig IN (SELECT *
                          FROM garanpro
                         WHERE cramo = pcramo
                           AND cmodali = pcmodali
                           AND ctipseg = pctipseg
                           AND ccolect = pccolect
                           AND ctipgar = 2) LOOP
            INSERT INTO garanseg
                        (cgarant, nriesgo, nmovimi, sseguro, finiefe, norden,
                         ctarifa, icapital, icaptot, iprianu, ipritar, ipritot, ftarifa,
                         crevali)
                 VALUES (voblig.cgarant, 1, lnmovimi, psseguro, pfefecto, voblig.norden,
                         voblig.ctarifa, 0, 0, 0, 0, 0, pfefecto,
                         0);
         END LOOP;

         pcestado := 2;   -- Dades bàsiques gravades

--------------------------------------------------------------------------
-- Primer commit, ja tenim les dades bàsiques de la pòlissa, actualitzem
-- l'estat del registre, i la emissió si va be fa commit i si no rollback
-- quan tornem a cridar al procés, haurà de continuar per aquí
         BEGIN
            UPDATE carrega_col
               SET cestado = 2,
                   sseguro = psseguro
             WHERE sproces = psproces
               AND nlinea = pnlinea;

            COMMIT;   ---
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 140714;
         END;
      END IF;   -- Fi de l'estat = 1

      IF pcestado = 2
         OR pcestado = 3 THEN   -- Dades bàsiques gravades (pòlissa no emesa)
         IF piapoini_promo IS NOT NULL THEN
            IF pcestado = 2 THEN
               IF lnmovimi IS NULL THEN
                  lnmovimi := 1;
               END IF;

               INSERT INTO garanseg
                           (cgarant, nriesgo, nmovimi, sseguro, finiefe, norden, crevali,
                            ctarifa, icapital, iprianu, ipritar, prevali, itarifa, itarrea,
                            ipritot, icaptot, ftarifa, nmovima)
                    VALUES (282, 1, lnmovimi, psseguro, pfefecto, l282.norden, l282.crevali,
                            l282.ctarifa, piapoini_promo, 0, 0, l282.prevali, 0, 0,
                            0, piapoini_promo, pfefecto, 1);

               p_emitir_propuesta(pcempres, pnpoliza, lncertif, pcramo, pcmodali, pctipseg,
                                  pccolect, pcactivi, pmoneda, pcidioma, lindice, lindice_e,
                                  lindice_t, pmensaje,   -- BUG 27642 - FAL - 30/04/2014
                                  psproces, NVL(lnorden_promo, 1));

               IF lindice_e <> 0 THEN
                  --DBMS_OUTPUT.put_line(' ERROR AL EMITIR PROPUESTA ');
                  RETURN 140730;
               END IF;

--------------------------------------------------------
-- Si ha anat be, tenim la proposta emesa, cestado = 3
-- actualitzem l'estat de la línia
               BEGIN
                  UPDATE carrega_col
                     SET cestado = 3
                   WHERE sproces = psproces
                     AND nlinea = pnlinea;

                  COMMIT;   ---
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 140714;
               END;

               pcestado := 3;
            END IF;

            --DBMS_OUTPUT.put_line('****************** cobrar ' || pcobrar || ' nmovimi '
            --                     || lnmovimi);

            -- cestado = 3 anem a cobrar el rebut
            IF pcestado = 3 THEN
               IF pcobrar = 1 THEN
                  IF lnmovimi IS NULL THEN
                     lnmovimi := 1;
                  END IF;

                  IF lccobban IS NULL THEN
                     SELECT ccobban
                       INTO lccobban
                       FROM seguros
                      WHERE sseguro = psseguro;
                  END IF;

                  -- Cobrar el rebut
                  SELECT MAX(nrecibo)
                    INTO lnrecibo
                    FROM recibos
                   WHERE sseguro = psseguro
                     AND nmovimi = lnmovimi;

                  --DBMS_OUTPUT.put_line(' 1 REBUT a cobrar ' || lnrecibo || ' data ' || pfefecto);

                  -- Obtenim la delegació
                  SELECT c01
                    INTO lcdelega
                    FROM seguredcom
                   WHERE sseguro = psseguro
                     AND fmovfin IS NULL;

                  IF pfefecto > f_sysdate THEN
                     lfmovini := pfefecto;
                  ELSE
                     lfmovini := f_sysdate;
                  END IF;

                  num_err := f_movrecibo(lnrecibo, 1, lfmovini, NULL, lsmovagr, lnliqmen,
                                         lnliqlin, lfmovini, lccobban, lcdelega, NULL, NULL);

                  --DBMS_OUTPUT.put_line('f_movrecibo ' || num_err);
                  IF num_err <> 0 THEN
                     --DBMS_OUTPUT.put_line(' f_movrecibo ' || num_err);
                     RETURN num_err;
                  END IF;

                  IF lprod.cagrpro = 11 THEN
                     SELECT MAX(nnumlin)
                       INTO llinea
                       FROM ctaseguro
                      WHERE sseguro = psseguro;

                     ldivisa := 3;
                     lnparpla := f_valor_participlan(pfefecto, psseguro, ldivisa);

                     IF lnparpla <> -1 THEN
                        lparticipacion := ROUND((piapoini_promo / lnparpla), 6);

                        UPDATE ctaseguro
                           SET nparpla = lparticipacion,
                               cestpar = 1
                         WHERE sseguro = psseguro
                           AND nnumlin = llinea;
                     END IF;
                  END IF;

--------------------------------------------------------
-- Si ha anat be, tenim el primer rebut cobrat, cestado = 4
-- actualitzem l'estat de la línia
                  BEGIN
                     UPDATE carrega_col
                        SET cestado = 4
                      WHERE sproces = psproces
                        AND nlinea = pnlinea;

                     COMMIT;   ---
                  EXCEPTION
                     WHEN OTHERS THEN
                        RETURN 140714;
                  END;

                  pcestado := 4;
               ELSE
                  -- si no es cobren, l'estat passa directament a 4,
                  --pendent d'emetre el segon moviment
                  pcestado := 4;
               END IF;
            END IF;
         ELSE
            -- si no hi ha aport. inicial de promotor,l'estat passa directament a 4,
            --pendent d'emetre el segon moviment
            pcestado := 4;
         END IF;
      END IF;

      --DBMS_OUTPUT.put_line(' piapoini_asseg ' || piapoini_asseg);

      -----------------------------------------------------------------------
-- tractament de l'aportació de l'assegurat
-----------------------------------------------------------------------
-- Obtenim dades parcials dels estats anteriors
      IF lnmovimi IS NULL THEN
         SELECT MAX(nmovimi), MAX(nsuplem) + 1
           INTO lnmovimi, lnsuplem
           FROM movseguro
          WHERE sseguro = psseguro;
      END IF;

      IF lncertif IS NULL
         OR lccobban IS NULL THEN
         SELECT ncertif, ccobban
           INTO lncertif, lccobban
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      IF lcdelega IS NULL THEN
         -- Obtenim la delegació
         SELECT c01
           INTO lcdelega
           FROM seguredcom
          WHERE sseguro = psseguro
            AND fmovfin IS NULL;
      END IF;

      IF pcestado = 4
         OR pcestado = 5
         OR pcestado = 6 THEN
         IF piapoini_asseg IS NOT NULL THEN
            IF pcestado = 4 THEN
               IF piapoini_promo IS NOT NULL THEN
                  -- Cal generar un moviment d'extra per el segon aportant
                  num_err := f_act_hisseg(psseguro, lnmovimi);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;

                  UPDATE seguros
                     SET csituac = 5
                   WHERE sseguro = psseguro;

                  num_err := f_movseguro(psseguro, NULL, 500, 1, pfefecto, NULL, lnsuplem, 0,
                                         NULL, lnmovimi, NULL, NULL, NULL, NULL);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;

                  --DBMS_OUTPUT.put_line(' ha creat moviment ' || lnmovimi);
                  lnsuplem := lnsuplem + 1;
                  num_err := f_dupgaran(psseguro, pfefecto, lnmovimi);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;

---------------------------------------------------------
--------------------------------------------------------
-- Si ha anat be, tenim el moviment generat, cal emetre cestado = 5
-- actualitzem l'estat de la línia
                  BEGIN
                     UPDATE carrega_col
                        SET cestado = 5
                      WHERE sproces = psproces
                        AND nlinea = pnlinea;

                     COMMIT;   ---
                  EXCEPTION
                     WHEN OTHERS THEN
                        RETURN 140714;
                  END;

                  pcestado := 5;
               ELSE
                  -- no cal generar el moviment, cal emetre el de nova producció
                  pcestado := 5;
               END IF;
            END IF;   -- cestado = 4

            --- cestado = 5, anem a emetre el moviment
            IF pcestado = 5 THEN
               --DBMS_OUTPUT.put_line('insert a garanseg la 2ª aport ' || piapoini_asseg);
               INSERT INTO garanseg
                           (cgarant, nriesgo, nmovimi, sseguro, finiefe, norden, crevali,
                            ctarifa, icapital, iprianu, ipritar, prevali, itarifa, itarrea,
                            ipritot, icaptot, ftarifa, nmovima)
                    VALUES (282, 1, lnmovimi, psseguro, pfefecto, l282.norden, l282.crevali,
                            l282.ctarifa, piapoini_asseg, 0, 0, l282.prevali, 0, 0,
                            0, piapoini_asseg, pfefecto, 1);

               --DBMS_OUTPUT.put_line(' Emetre 2º ');
               IF lnorden_asseg IS NULL THEN
                  lnorden_asseg := lnmovimi;
               END IF;

               p_emitir_propuesta(pcempres, pnpoliza, lncertif, pcramo, pcmodali, pctipseg,
                                  pccolect, pcactivi, pmoneda, pcidioma, lindice, lindice_e,
                                  lindice_t, pmensaje,   -- BUG 27642 - FAL - 30/04/2014
                                  psproces, lnorden_asseg);

               IF lindice_e <> 0 THEN
                  RETURN 140730;
               END IF;

--------------------------------------------------------
-- Si ha anat be, tenim la proposta emesa, cestado = 6
-- actualitzem l'estat de la línia
               BEGIN
                  UPDATE carrega_col
                     SET cestado = 6
                   WHERE sproces = psproces
                     AND nlinea = pnlinea;

                  COMMIT;   ---
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 140714;
               END;

               pcestado := 6;
            END IF;

            IF pcestado = 6 THEN
               IF pcobrar = 1 THEN
                  -- Cobrar el rebut
                  SELECT MAX(nrecibo)
                    INTO lnrecibo
                    FROM recibos
                   WHERE sseguro = psseguro
                     AND nmovimi = lnmovimi;

                  --DBMS_OUTPUT.put_line('2 REBUT a cobrar ' || lnrecibo);
                  IF pfefecto > f_sysdate THEN
                     lfmovini := pfefecto;
                  ELSE
                     lfmovini := f_sysdate;
                  END IF;

                  num_err := f_movrecibo(lnrecibo, 1, lfmovini, NULL, lsmovagr, lnliqmen,
                                         lnliqlin, lfmovini, lccobban, lcdelega, NULL, NULL);

                  --DBMS_OUTPUT.put_line(' fmovrec ' || num_err);
                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;

                  IF lprod.cagrpro = 11 THEN
                     SELECT MAX(nnumlin)
                       INTO llinea
                       FROM ctaseguro
                      WHERE sseguro = psseguro;

                     ldivisa := 3;
                     lnparpla := f_valor_participlan(pfefecto, psseguro, ldivisa);

                     IF lnparpla <> -1 THEN
                        lparticipacion := ROUND((piapoini_asseg / lnparpla), 6);

                        UPDATE ctaseguro
                           SET nparpla = lparticipacion,
                               cestpar = 1
                         WHERE sseguro = psseguro
                           AND nnumlin = llinea;
                     END IF;
                  END IF;

--------------------------------------------------------
-- Si ha anat be, tenim el segon rebut cobrat, cestado = 7
-- actualitzem l'estat de la línia
                  BEGIN
                     UPDATE carrega_col
                        SET cestado = 7
                      WHERE sproces = psproces
                        AND nlinea = pnlinea;

                     COMMIT;   ---
                  EXCEPTION
                     WHEN OTHERS THEN
                        RETURN 140714;
                  END;

                  pcestado := 7;
               ELSE
                  pcestado := 7;
               END IF;
            END IF;
         ELSE
            -- si no hi ha aport. asseg, l'estat passa a pendent de generar la periòdica
            pcestado := 7;
         END IF;
      END IF;

      --
      -- Obtenim dades parcials dels estats anteriors
      IF lnmovimi IS NULL THEN
         SELECT MAX(nmovimi), MAX(nsuplem) + 1
           INTO lnmovimi, lnsuplem
           FROM movseguro
          WHERE sseguro = psseguro;
      END IF;

      IF pcestado = 7 THEN
         IF piprianu IS NOT NULL THEN
            -- Fer moviment d'inici d'aportacio, ja es genera emès
            num_err := f_act_hisseg(psseguro, lnmovimi);

            UPDATE seguros
               SET cforpag = GREATEST(NVL(pcforpag_promo, 0), NVL(pcforpag_asseg, 0)),
                   fcarpro = LEAST(NVL(pfcarpro_promo, '31/12/2999'),
                                   NVL(pfcarpro_asseg, '31/12/2999')),
                   fcaranu = ADD_MONTHS(LEAST(NVL(pfcarpro_promo, '31/12/2999'),
                                              NVL(pfcarpro_asseg, '31/12/2999')),
                                        12)
             WHERE sseguro = psseguro;

            num_err := f_movseguro(psseguro, NULL, 252, 1, pfefecto, NULL, lnsuplem, 0, NULL,
                                   lnmovimi, f_sysdate, NULL, NULL, NULL);
            lnsuplem := lnsuplem + 1;
            num_err := f_dupgaran(psseguro, pfefecto, lnmovimi);

            INSERT INTO garanseg
                        (cgarant, nriesgo, nmovimi, sseguro, finiefe, norden, crevali,
                         ctarifa, icapital, iprianu, ipritar, prevali, itarifa, itarrea,
                         ipritot, icaptot, ftarifa, nmovima)
                 VALUES (48, 1, lnmovimi, psseguro, pfefecto, l48.norden, l48.crevali,
                         l48.ctarifa, 0, piprianu, piprianu, l48.prevali, 0, 0,
                         piprianu, 0, pfefecto, lnmovimi);

--------------------------------------------------------
-- Si ha anat be, el moviment de canvi de periòdica, cestado = 8
-- actualitzem l'estat de la línia
            BEGIN
               UPDATE carrega_col
                  SET cestado = 8
                WHERE sproces = psproces
                  AND nlinea = pnlinea;

               COMMIT;   ---
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 140714;
            END;

            pcestado := 8;
         ELSE
            pcestado := 8;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line(SQLERRM);
         p_tab_error(f_sysdate, f_user, 'pac_cargas_col', 2,
                     'f_alta_certif.Error f_alta_certif.', SQLERRM);
         RETURN 9999;
   END f_alta_certif;

-------------------------------------------------------------------------------------
   FUNCTION f_tracta_mov(
      pcempres IN NUMBER,
      pcactivi IN NUMBER,
      psproces IN NUMBER,
      pnpoliza IN NUMBER,
      pcidioma IN NUMBER,
      pfefecto IN DATE,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcoficin IN NUMBER,
      pcagente IN NUMBER,
      pfvencim IN DATE,
      ptnatrie IN VARCHAR2,
      psperson_promo IN NUMBER,
      pcdomici_promo IN NUMBER,
      pmoneda IN NUMBER,
      pcobrar IN NUMBER)
      RETURN NUMBER IS
-------------------------------------------------------------------------------------
      CURSOR c_mov(wsproces NUMBER) IS
         SELECT *
           FROM carrega_col
          WHERE sproces = wsproces
            AND cestado >= 1   -- Ja s'ha tractat la persona, cal tractar el moviment
                            ;

      lsseguro       NUMBER;
      lcestado       NUMBER;
      ltexto         VARCHAR2(400);
      num_err        NUMBER;
      num_err2       NUMBER;
      lnnumlin       NUMBER;
   BEGIN
      FOR v IN c_mov(psproces) LOOP
         IF v.ctipreg = 'A' THEN
            IF v.sseguro IS NOT NULL THEN
               lsseguro := v.sseguro;
            END IF;

            num_err := f_alta_certif(pcempres, pfefecto, psproces, v.nlinea, v.cestado,
                                     pnpoliza, pcramo, pcmodali, pctipseg, pccolect,
                                     psperson_promo, v.sperson, v.cbancar_promo,
                                     v.cbancar_asseg, pcdomici_promo, v.cdomici,
                                     v.iapoini_promo, v.iapoini_asseg, v.iprianu_per,
                                     v.papor_promo, v.iapor_promo, v.fcarpro_promo,
                                     v.fcarpro_asseg, v.cforpag_prom, v.cforpag_asseg,
                                     v.crevali, v.prevali, v.frevali, v.tbenef1, v.tbenef2,
                                     v.tbenef3, v.polissa_ini, pcidioma, pcoficin, pcagente,
                                     pfvencim, pcactivi, ptnatrie, pmoneda, v.cfiscal_promo,
                                     v.cfiscal_asseg, v.papor_promo,
                                     100 - NVL(v.papor_promo, 0), v.iapor_promo,
                                     v.iprianu_per - NVL(v.iapor_promo, 0), pcobrar, lsseguro);
         ELSIF v.ctipreg = '' THEN
            NULL;
         END IF;

         IF num_err = 0 THEN
--------------------------------------------------------
-- Si ha anat be, actualitzem la línia amb l'estat últim
-- que retorna la funció
            BEGIN
               UPDATE carrega_col
                  SET cestado = v.cestado
                WHERE sproces = psproces
                  AND nlinea = v.nlinea;

               COMMIT;   ---
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 140714;
            END;
         ELSE
            ROLLBACK;
            lcestado := NULL;
            ltexto := f_axis_literales(num_err, pcidioma);
            num_err2 := f_proceslin(psproces, ltexto || '-' || pcidioma, lsseguro, lnnumlin);
         END IF;

         UPDATE carrega_col
            SET cestado = NVL(lcestado, cestado),
                cerror = num_err
          WHERE sproces = v.sproces
            AND nlinea = v.nlinea;

         COMMIT;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line(' 1' || SQLERRM);
         p_tab_error(f_sysdate, f_user, 'pac_cargas_col', 1,
                     'f_tracta_mov.Error f_tracta_mov.', SQLERRM);
         RETURN 9999;
   END f_tracta_mov;

-------------------------------------------------------------------------------------
   FUNCTION f_carga_col(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psperson IN NUMBER,
      pcdomici IN NUMBER,
      pfefecto IN DATE,
      pnpoliza IN OUT NUMBER,
      ptnatrie IN VARCHAR2,
      pcoficin IN NUMBER,
      pcagente IN NUMBER,
      pfvencim IN DATE,
      ppath IN VARCHAR2,
      pnomfitx IN VARCHAR2,
      psep IN VARCHAR2,   -- Separador de camps
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pcactivi IN NUMBER,
      pcobrar IN NUMBER)
      RETURN NUMBER IS
---------------------------------------------------------------------------------------
      lerror         NUMBER := 0;
      lnnumnif       VARCHAR2(14);
   BEGIN
      -- Tractament de les persones del fitxer
      lerror := f_tracta_persones(psproces, pcidioma);

      --DBMS_OUTPUT.put_line(' tracta_personas ' || lerror);

      -- Tractament del moviments de pòlissa (altes, suplem., ..)
      IF lerror = 0 THEN
         COMMIT;

         IF pnpoliza IS NULL THEN
            -- Si és pòlissa nova, cal obtenir un nou nº de pòlissa
            pnpoliza := f_contador('02', pcramo);

            BEGIN
               UPDATE cap_carrega_col
                  SET npoliza = pnpoliza
                WHERE sproces = psproces;
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 140741;
            END;
         END IF;

         -- Fem el commit, ja tindrem nº de pòlissa encara que vagi malament
         COMMIT;
         lerror := f_tracta_mov(pcempres, pcactivi, psproces, pnpoliza, pcidioma, pfefecto,
                                pcramo, pcmodali, pctipseg, pccolect, pcoficin, pcagente,
                                pfvencim, ptnatrie, psperson, pcdomici, pmoneda, pcobrar);
      --DBMS_OUTPUT.put_line(' tracta_mov ' || lerror);
      END IF;

      RETURN lerror;
   END f_carga_col;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_COL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_COL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_COL" TO "PROGRAMADORESCSI";
