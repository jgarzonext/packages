--------------------------------------------------------
--  DDL for Package Body PAC_CANVIFORPAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CANVIFORPAG" IS
/******************************************************************************
   NOMBRE:       pac_canviforpag
   PROPÓSITO:  Suplemento cambio forma pago

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        ??           ???                1. Creación del package.
   2.0        07/06/2009   JRH                2. 0008648: CRE - Error en suplemento de suspención aportación periodica PPJ
   3.0        13/04/2010   JMC                3. 0014119: Suplemento cambio forma de pago en pólizas renovadas.
   4.0        13/08/2010   RSC                4. 14775: AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012
   5.0        03/03/2014   JDS                5. 0029991: LCOL_T010-Revision incidencias qtracker (2014/02)
******************************************************************************/
   FUNCTION f_canvi_forpag(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pnsuplem IN NUMBER,
      pfefecto IN DATE,
      pfcaranu IN DATE,
      pfcarpro IN DATE,
      pfsuplem IN DATE,
      pcforpag_ant IN NUMBER,
      pcforpag_nou IN NUMBER,
      pctipreb IN NUMBER,
      paplica IN NUMBER)
      RETURN NUMBER IS
      /***********************************************************************************
      Funció que realitza el suplement de canvi de forma de pagament
      Paràmetres :
              pcempres
              psproces
              psseguro
              pnsuplem         : Nº de suplement
              pfefecto         : Data d'efecte de la pòlissa
              pfcaranu         : Data cartera anual
              pfcarpro         : Data de propera cartera actual
              pfsuplem         : Data del suplement de canvi de forma de pagament
         pcforpag_ant
         pcforpag_nou
              pctipreb         : Tipus de rebut (per prenedor o assegurat)
      ***********************************************************************************/
      l_fefecto      DATE;
      l_fvencim      DATE;
      l_fcarpro      DATE;
      l_nmovimi      NUMBER;
      limp           NUMBER;
      l_cmodcom      NUMBER;
      num_err        NUMBER;
      l_ahorro       NUMBER;
      l_cmovi        NUMBER;
      l_faux         DATE;
      v_nmovimi      NUMBER;
      v_cdomper      NUMBER;
      v_cmovdom      NUMBER;
      w_fefecto           DATE;     -- bug AMA-415 - FAL - 13/07/2016
      w_ptipomovimiento   NUMBER;   -- bug AMA-415 - FAL - 13/07/2016
   BEGIN
      num_err := 0;

      IF pcforpag_ant = 0 THEN
         -- No es contempla aquest cas (selecció no permesa)
         RETURN 102864;
      ELSE
         -- Mirem si té domiciliació
         SELECT MAX(nmovimi)
           INTO v_nmovimi
           FROM movseguro
          WHERE sseguro = psseguro
            AND cmovseg NOT IN(3);

         --Que no sea un movimiento de anulación
         BEGIN
            SELECT cdomper
              INTO v_cdomper
              FROM movseguro
             WHERE sseguro = psseguro
               AND nmovimi = v_nmovimi;
         EXCEPTION
            WHEN OTHERS THEN
               v_cdomper := NULL;
         END;

         -- Mirem si per aquest producte domicilia els moviments de no_cartera
         SELECT cmovdom
           INTO v_cmovdom
           FROM productos
          WHERE sproduc = (SELECT sproduc
                             FROM seguros
                            WHERE sseguro = psseguro);

         -- Creem el suplement
         IF v_cmovdom = 1 THEN
            num_err := f_movseguro(psseguro, NULL, 269, 1, pfsuplem, NULL, pnsuplem, 0, NULL,
                                   l_nmovimi, f_sysdate, v_cdomper);
         ELSE
            num_err := f_movseguro(psseguro, NULL, 269, 1, pfsuplem, NULL, pnsuplem, 0, NULL,
                                   l_nmovimi, f_sysdate, 0);
         END IF;

          -- bug AMA-415 - FAL - 13/07/2016
          select max(fefecto) into w_fefecto
          from movseguro
          where sseguro = psseguro and
                cmovseg in (0,2);

          if trunc(l_fefecto) = trunc(w_fefecto) then --si efecto recibo = efecto de NP o renovación genera recibo como de NP (0), sinó como de renovación parcial o fraccionada (22) para que no genere impuestos
            w_ptipomovimiento:= 0;
          else
            w_ptipomovimiento:= 22;
          end if;
          -- bug AMA-415 - FAL - 13/07/2016

         IF num_err <> 0 THEN
            --dbms_output.put_line(' ERROR movseguro ' || num_err);
            NULL;
         ELSE
            -- Se llama a f_act_hisseg para guardar la situación anterior al suplemento.
            -- El nmovimi es el anterior al del suplemento, por eso se le resta uno al
            -- recién creado.
            num_err := f_act_hisseg(psseguro, l_nmovimi - 1);

            IF num_err <> 0 THEN
               --dbms_output.put_line(' ERROR historicoseguros ' || num_err);
               RETURN num_err;
            ELSE
               -- Duplicar les garanties al moviment de canvi de fp
               num_err := f_dupgaran(psseguro, pfsuplem, l_nmovimi);
               -- Duplicar preguntes i clausules
               num_err := f_duppregun(psseguro, l_nmovimi, pfsuplem);
               num_err := f_dupclausules(psseguro, pfsuplem, l_nmovimi);
               -- Duplicar exclusions i carències.
               num_err := f_dupexclucarenseg(psseguro, pfsuplem, l_nmovimi);
               num_err := f_dupgaran_ocs(psseguro, pfsuplem, l_nmovimi);

               IF num_err <> 0 THEN
                  --dbms_output.put_line(' ERROR duplica garan ' || num_err);
                  RETURN num_err;
               ELSE
                  -- Si s'aplica en data de cartera, no cal fer rebuts ni rès.
                  IF paplica = 1 THEN
                     UPDATE seguros
                        SET cforpag = pcforpag_nou,
                            nsuplem = pnsuplem
                      WHERE sseguro = psseguro;
                  ELSE
                     -- Comprovem si és de més a menys fracionament o al contrari
                     IF pcforpag_ant < pcforpag_nou THEN   -- ANUAL --> MENSUAL
                        -- Aquest cas és quan passem de menys fraccionat a més fraccionat

                        -- Obtenir data d'efecte del nou rebut, buscant la data de l'últim rebut
                        -- no anulat.
                        num_err := f_ultim_venciment(psseguro, l_fefecto);

                        IF num_err <> 0 THEN
                           --dbms_output.put_line(' ERROR ultim vct' || num_err);
                           RETURN num_err;
                        ELSE
                           IF l_fefecto IS NULL THEN
                              l_fefecto := pfefecto;
                           END IF;

                           IF l_fefecto = pfcarpro THEN
                              -- No canvia rès
                              l_fcarpro := pfcarpro;
                           ELSE
                              -- Calculem la data de propera cartera
                              l_fcarpro := f_calcula_fcarpro(pfcaranu, pcforpag_nou,
                                                             l_fefecto, pfefecto);

                              IF l_fefecto < pfcaranu
                                 AND l_fefecto <> pfcarpro
                                 AND l_fefecto <> l_fcarpro THEN
                                 -- La data de venciment del rebut és la de propera cartera
                                 l_fvencim := l_fcarpro;

                                 -- Veure si és la primera anualitat
                                 IF f_es_renovacion(psseguro) = 1 THEN
                                    l_cmodcom := 2;
                                 ELSE
                                    l_cmodcom := 1;
                                 END IF;

                                 IF f_esahorro(NULL, psseguro, num_err) = 1 THEN
                                    IF num_err <> 0 THEN
                                       --dbms_output.put_line('ERROR en f_esahorro ');
                                       RETURN num_err;
                                    ELSE
                                       l_ahorro := 1;
                                       l_cmovi := 2;
                                    END IF;
                                 ELSE
                                    l_ahorro := 0;
                                 END IF;

                                 BEGIN
                                    UPDATE seguros
                                       SET cforpag = pcforpag_nou,
                                           fcarpro = l_fcarpro,
                                           nsuplem = pnsuplem
                                     WHERE sseguro = psseguro;
                                 EXCEPTION
                                    WHEN OTHERS THEN
                                       RETURN 102361;
                                 END;

                                 --BUG9028-XVM-01102009 inici
                                 IF NVL(pac_parametros.f_parinstalacion_n('CALCULO_RECIBO'), 1) =
                                                                                              0 THEN
                                    -- Bug 14775 - RSC - 13/08/2010 - AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012
                                    num_err := pac_adm.f_recries(pctipreb, psseguro, NULL,
                                                                 f_sysdate, l_fefecto,
                                                                 l_fvencim, 1, NULL, NULL,
                                                                 NULL, NULL, psproces,
                                                                 -- 0,
                                                                 w_ptipomovimiento, -- bug AMA-415 - FAL - 13/07/2016
                                                                 'R',
                                                                 l_cmodcom, pfcaranu, 0,
                                                                 l_cmovi, pcempres, l_nmovimi,
                                                                 NULL, limp);
                                 ELSE
                                    num_err := f_recries(pctipreb, psseguro, NULL, f_sysdate,
                                                         l_fefecto, l_fvencim, 1, NULL, NULL,
                                                         NULL, NULL, psproces,
                                                         -- 0,
                                                         w_ptipomovimiento, -- bug AMA-415 - FAL - 13/07/2016
                                                         'R',
                                                         l_cmodcom, pfcaranu, 0, l_cmovi,
                                                         NULL, l_nmovimi, NULL, limp);
                                 END IF;

                                 --BUG9028-XVM-01102009 inici

                                 --BUG9028-XVM-01102009 fi
                                 IF num_err <> 0 THEN
                                    --dbms_output.put_line(' ERROR recries ' || num_err);
                                    RETURN num_err;
                                 ELSE
                                    -- Cal modificar el rebut per eliminar la prima devengada
                                    -- si no li correspon
                                    num_err := f_recalcula_rebut(psproces, psseguro,
                                                                 l_nmovimi, pfefecto,
                                                                 pfcaranu);
                                 END IF;

                                 --Bug.: 20923 - 14/01/2012 - ICV
                                 IF NVL(pac_parametros.f_parempresa_n(pcempres,
                                                                      'GESTIONA_COBPAG'),
                                        0) = 1
                                    AND num_err = 0 THEN
                                    num_err :=
                                       pac_ctrl_env_recibos.f_proc_recpag_mov(pcempres,
                                                                              psseguro,
                                                                              l_nmovimi, 4,
                                                                              psproces);
                                 --Si ha dado error
                                 --De momento se comenta la devolución del error
                                 /*
                                 IF num_err <> 0 THEN
                                   RETURN num_err;
                                 end if;*/
                                 END IF;
                              END IF;
                           END IF;
                        END IF;
                     ELSIF pcforpag_ant > pcforpag_nou THEN
                        -- Aquest cas és quan passem de més fraccionat a menys fraccionat
                        -- P.e. mensual a trimestral

                        -- Obtenir la data de venciment del últim rebut no anulat com a efecte
                        num_err := f_ultim_venciment(psseguro, l_fefecto);

                        IF l_fefecto IS NULL THEN
                           l_fefecto := pfefecto;
                        END IF;

                        IF l_fefecto = pfcaranu THEN
                           -- No cal fer rès, ja ho farà la renovació
                           l_fcarpro := pfcarpro;
                        ELSE
                           -- Calculem la nova data de propera cartera
                           IF pcforpag_nou = 1 THEN
                              l_fcarpro := pfcaranu;
                           ELSE
                              l_fcarpro := f_calcula_fcarpro(pfcaranu, pcforpag_nou,
                                                             l_fefecto, pfefecto);
                           END IF;

                           -- Si la propera cartera coincideix amb la del últim venciment no anul.lat,
                           -- no s'ha de crear rebut, només canviar la forma de pagament i fcarpro
                           IF l_fefecto < pfcaranu
                              AND l_fefecto <> l_fcarpro THEN
                              l_fvencim := l_fcarpro;

                              IF f_es_renovacion(psseguro) = 1 THEN
                                 l_cmodcom := 2;
                              ELSE
                                 l_cmodcom := 1;
                              END IF;

                              IF f_esahorro(NULL, psseguro, num_err) = 1 THEN
                                 IF num_err <> 0 THEN
                                    --dbms_output.put_line('ERROR en f_esahorro ');
                                    RETURN num_err;
                                 ELSE
                                    l_ahorro := 1;
                                    l_cmovi := 2;
                                 END IF;
                              ELSE
                                 l_ahorro := 0;
                              END IF;

                              BEGIN
                                 UPDATE seguros
                                    SET cforpag = pcforpag_nou,
                                        fcarpro = l_fcarpro,
                                        nsuplem = pnsuplem
                                  WHERE sseguro = psseguro;
                              EXCEPTION
                                 WHEN OTHERS THEN
                                    RETURN 102361;
                              END;

                              --BUG9028-XVM-01102009 inici
                              IF NVL(pac_parametros.f_parinstalacion_n('CALCULO_RECIBO'), 1) =
                                                                                              0 THEN
                                 -- Bug 14775 - RSC - 13/08/2010 - AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012
                                 num_err := pac_adm.f_recries(pctipreb, psseguro, NULL,
                                                              f_sysdate, l_fefecto, l_fvencim,
                                                              1, NULL, NULL, NULL, NULL,
                                                              psproces,
                                                              -- 0,
                                                              w_ptipomovimiento, -- bug AMA-415 - FAL - 13/07/2016
                                                              'R', l_cmodcom,
                                                              pfcaranu, 0, l_cmovi, pcempres,
                                                              l_nmovimi, NULL, limp);
                              ELSE
                                 num_err := f_recries(pctipreb, psseguro, NULL, f_sysdate,
                                                      l_fefecto, l_fvencim, 1, NULL, NULL,
                                                      NULL, NULL, psproces,
                                                      -- 0,
                                                      w_ptipomovimiento, -- bug AMA-415 - FAL - 13/07/2016
                                                      'R', l_cmodcom,
                                                      pfcaranu, 0, l_cmovi, NULL, l_nmovimi,
                                                      NULL, limp);
                              END IF;

                              --BUG9028-XVM-01102009 fi
                              IF num_err <> 0 THEN
                                 --dbms_output.put_line(' ERROR recries ' || num_err);
                                 RETURN num_err;
                              ELSE
                                 num_err := f_recalcula_rebut(psproces, psseguro, l_nmovimi,
                                                              pfefecto, pfcaranu);
                              END IF;

                              --Bug.: 20923 - 14/01/2012 - ICV
                              IF NVL(pac_parametros.f_parempresa_n(pcempres, 'GESTIONA_COBPAG'),
                                     0) = 1
                                 AND num_err = 0 THEN
                                 num_err := pac_ctrl_env_recibos.f_proc_recpag_mov(pcempres,
                                                                                   psseguro,
                                                                                   l_nmovimi,
                                                                                   4,
                                                                                   psproces);
                              --Si ha dado error
                              --De momento se comenta la devolución del error
                              /*
                              IF num_err <> 0 THEN
                                RETURN num_err;
                              end if;*/
                              END IF;
                           END IF;
                        END IF;
                     ELSE
                        -- Error , la igualtat no es contempla
                        RETURN 102864;
                     END IF;

                     IF num_err = 0 THEN
                        -- Aquests camps s'ctualitzen sempre
                        UPDATE seguros
                           SET cforpag = pcforpag_nou,
                               nsuplem = pnsuplem
                         WHERE sseguro = psseguro;
                     END IF;
                  END IF;   -- aplica = 1
               END IF;   -- num_err garan
            END IF;   -- num_err historicoseguros
         END IF;   -- num_err movseg
      END IF;   --if  cforpag_ant = 0

      RETURN num_err;
   END f_canvi_forpag;

   /*************************************************************************
         f_ultim_venciment_NP: Fecha vto. ult. recibo de NP
        param in psseguro  : Código seguro
        param out pfefecto : Fecha vto. ult. recibo de NP
        *******************************************************************/
   FUNCTION f_ultim_venciment_np(psseguro IN NUMBER, pfefecto OUT DATE)
      RETURN NUMBER IS
   /***********************************************************************************
   Funció que busca la última data de venciment dels rebuts de NP no anulats
   ************************************************************************************/
   BEGIN
      SELECT MAX(r.fvencim)
        INTO pfefecto
        FROM recibos r, seguros s
       WHERE r.sseguro = psseguro
         AND s.sseguro = r.sseguro
         AND ctiprec = 0   -- de NP
         AND NOT EXISTS(SELECT cgarant
                          FROM detrecibos
                         WHERE nrecibo = r.nrecibo
                           AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                               s.cactivi, cgarant, 'TIPO') = 4)
         AND NOT EXISTS(SELECT re.nrecibo
                          FROM recanudevban re
                         WHERE re.nrecibo = r.nrecibo)
         AND NOT EXISTS(SELECT nrecibo
                          FROM movrecibo
                         WHERE nrecibo = r.nrecibo
                           AND fmovfin IS NULL
                           AND cestrec = 2);

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         RETURN 102367;
   END f_ultim_venciment_np;

---------------------------------------------------------------------------------------
   FUNCTION f_ultim_venciment(psseguro IN NUMBER, pfefecto OUT DATE)
      RETURN NUMBER IS
   /***********************************************************************************
   Funció que busca la última data de venciment dels rebuts no anulats
   ************************************************************************************/
   BEGIN
      SELECT MAX(r.fvencim)
        INTO pfefecto
        FROM recibos r, seguros s
       WHERE r.sseguro = psseguro
         AND s.sseguro = r.sseguro
         AND ctiprec <> 4   -- que no sea de aportación extraordinaria
         AND NOT EXISTS(SELECT cgarant
                          FROM detrecibos
                         WHERE nrecibo = r.nrecibo
                           AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                               s.cactivi, cgarant, 'TIPO') = 4)
         AND NOT EXISTS(SELECT re.nrecibo
                          FROM recanudevban re
                         WHERE re.nrecibo = r.nrecibo)
         AND NOT EXISTS(SELECT nrecibo
                          FROM movrecibo
                         WHERE nrecibo = r.nrecibo
                           AND fmovfin IS NULL
                           AND cestrec = 2);

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         RETURN 102367;
   END f_ultim_venciment;

---------------------------------------------------------------------------------------
   FUNCTION f_anular_pendents(pcempres IN NUMBER, psseguro IN NUMBER, pdata IN DATE)
      RETURN NUMBER IS
      /************************************************************************************
      Funció que anul.la rebuts pendents a a partir de la data pdata
      ************************************************************************************/
      CURSOR c IS
         SELECT m.nrecibo, m.fmovini, r.cdelega
           FROM recibos r, movrecibo m
          WHERE r.sseguro = psseguro
            AND r.fefecto >= pdata
            AND r.nrecibo = m.nrecibo
            AND m.fmovfin IS NULL
            AND m.cestrec = 0
            AND NOT EXISTS(SELECT nmovimi
                             FROM movseguro
                            WHERE sseguro = r.sseguro
                              AND nmovimi = r.nmovimi
                              AND cmovseg = 6);

      error          NUMBER;
      l_data_anula   DATE;
      psmovagr       NUMBER;
      pnliqmen       NUMBER;
      pnliqlin       NUMBER;
   BEGIN
      error := 0;

      FOR v IN c LOOP
         --dbms_output.put_line(' Rebut ' || v.nrecibo);
         -- Anul.lem en data de suplement
         -- Siempre se tendrá en cuenta que no puede ser anterior al último movimiento del recibo.
         error := 0;

         IF pdata >= f_sysdate THEN
            l_data_anula := pdata;
         ELSE
            BEGIN
               SELECT LAST_DAY(ADD_MONTHS(MAX(fperini), 1))
                 INTO l_data_anula
                 FROM cierres
                WHERE ctipo = 1
                  AND cestado = 1
                  AND cempres = pcempres;

               IF l_data_anula IS NULL THEN
                  l_data_anula := f_sysdate;
               END IF;

               IF f_sysdate < NVL(l_data_anula, f_sysdate) THEN
                  --dbms_output.put_line('ssydate <l_data_anula');
                  l_data_anula := f_sysdate;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  --dbms_output.put_line('no_data_found ');
                  l_data_anula := f_sysdate;
            END;
         END IF;

         IF l_data_anula < v.fmovini THEN
            --dbms_output.put_line(' anula < que moviment ');
            l_data_anula := v.fmovini;
         END IF;

         --dbms_output.put_line('data anul ' || l_data_anula);
         -- Anul. per reemplaç = 1
         --dbms_output.put_line('pdata ' || pdata);
         psmovagr := 0;
         error := f_movrecibo(v.nrecibo, 2, l_data_anula, 2, psmovagr, pnliqmen, pnliqlin,
                              l_data_anula, NULL, v.cdelega, 1, NULL);
      --dbms_output.put_line('ERROR ' || error);
      END LOOP;

      RETURN error;
   END f_anular_pendents;

   FUNCTION f_copiagaran(psseguro IN NUMBER, pfefecto IN DATE, pmovimi IN NUMBER)
      RETURN NUMBER IS
      /************************************************************************
         F_copiagaran   Duplica las garantías activas con el nuevo nº de
                  movimiento, però deixa activas les del moviment
                              anterior
      *************************************************************************/
      nerror         NUMBER;
   BEGIN
      INSERT INTO garanseg
                  (cgarant, nriesgo, nmovimi, sseguro, finiefe, norden, crevali, ctarifa,
                   icapital, precarg, iextrap, iprianu, ffinefe, cformul, ctipfra, ifranqu,
                   irecarg, ipritar, pdtocom, idtocom, prevali, irevali, itarifa, itarrea,
                   ipritot, icaptot, ftarifa)
         SELECT cgarant, nriesgo, pmovimi, sseguro, pfefecto, norden, crevali, ctarifa,
                icapital, precarg, iextrap, iprianu, pfefecto, cformul, ctipfra, ifranqu,
                irecarg, ipritar, pdtocom, idtocom, prevali, irevali, itarifa, itarrea,
                ipritot, icaptot, ftarifa
           FROM garanseg
          WHERE sseguro = psseguro
            AND ffinefe IS NULL
            AND nmovimi <> pmovimi;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 103500;
   END f_copiagaran;

---------------------------------------------------------------------------------------
   FUNCTION f_recalcula_rebut(
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto IN DATE,
      pfcaranu IN DATE)
      RETURN NUMBER IS
---------------------------------------------------------------------------------------
-- Cal eliminar els imports devengats i el consorci, si el rebut no coincideix
-- el primer de la anualitat
--------------------------------------------------------------------------------
      l_fcaranu_ant  DATE;
      num_err        NUMBER;
      l_ctiprec      NUMBER;

      CURSOR c IS
         SELECT nrecibo, fefecto
           FROM tmp_adm_recibos
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;
   BEGIN
      num_err := 0;

      FOR v IN c LOOP
         BEGIN
            IF v.fefecto = pfefecto THEN
               l_ctiprec := 0;
            ELSE
               l_ctiprec := 3;
            END IF;

            UPDATE tmp_adm_recibos
               SET ctiprec = l_ctiprec
             WHERE nrecibo = v.nrecibo;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := 102358;
         END;

         IF num_err = 0 THEN
            IF pfcaranu IS NULL THEN
               l_fcaranu_ant := pfefecto;
            ELSE
               l_fcaranu_ant := ADD_MONTHS(pfcaranu, -12);

               IF l_fcaranu_ant < pfefecto THEN
                  l_fcaranu_ant := pfefecto;
               END IF;
            END IF;

            IF v.fefecto <> l_fcaranu_ant THEN
               -- Esborrem els conceptes que es cobren en el primer rebut (devengats i consorci)
               BEGIN
                  DELETE FROM tmp_adm_detrecibos
                        WHERE nrecibo = v.nrecibo
                          AND cconcep IN(15, 16, 21, 65, 66, 71, 2, 52, 3, 53, 5, 55);

                  DELETE FROM tmp_adm_vdetrecibos
                        WHERE nrecibo = v.nrecibo;

                  num_err := pac_adm.f_tmp_vdetrecibos('R', v.nrecibo, psproces);
               EXCEPTION
                  WHEN OTHERS THEN
                     num_err := 105156;
               END;
            END IF;
         END IF;
      END LOOP;

      RETURN num_err;
   END f_recalcula_rebut;

   FUNCTION f_calcula_fcarpro(
      pfcaranu IN DATE,
      pcforpag IN NUMBER,
      pfefecto IN DATE,
      pfefepol IN DATE)
      RETURN DATE IS
      ddmm           VARCHAR2(4);
      dd             VARCHAR2(2);
      l_faux         DATE;
      l_fcarpro      DATE;
   BEGIN
      ddmm := LPAD(TO_CHAR(pfcaranu, 'ddmm'), 4, '0');
      dd := LPAD(TO_CHAR(pfcaranu, 'dd'), 2, '0');
      l_faux := pfcaranu;

      WHILE TRUE LOOP
         l_faux := f_summeses(l_faux, -12 / pcforpag, dd);

         -- BUG : 14119 - 13-04-2010 - JMC - Se modifica la condición.
         /*
         IF (l_faux < pfefecto)
            OR(l_faux = pfefecto
               AND l_faux = pfefepol) THEN
         */
         IF (l_faux <= pfefecto) THEN
            -- FIN BUG : 14119 - 13-04-2010 - JMC
               --  Es treu la igualtat, pq tiri enrera un periode més,
               -- pq no fagi rebuts futurs de cartera,
               --  Es deixa la igualtat només per la Nova producció , que no passa per cartera
            l_fcarpro := f_summeses(l_faux, 12 / pcforpag, dd);
            EXIT;
         END IF;
      END LOOP;

      RETURN l_fcarpro;
   END f_calcula_fcarpro;

------------------------------------------------------------------------------------------------
-- Dupliquem les preguntes per tenir asignat el nou num de moviment amb les preguntes corresponents
------------------------------------------------------------------------------------------------
   FUNCTION f_duppregun(psseguro NUMBER, pnmovimi NUMBER, pfsuplem DATE)
      RETURN NUMBER IS
   BEGIN
      INSERT INTO pregunseg
                  (sseguro, nriesgo, cpregun, crespue, nmovimi)
         (SELECT psseguro, nriesgo, cpregun, crespue, pnmovimi
            FROM pregunseg
           WHERE sseguro = psseguro
             AND nmovimi = (SELECT MAX(nmovimi)
                              FROM pregunseg
                             WHERE sseguro = psseguro));

      INSERT INTO pregungaranseg
                  (sseguro, nriesgo, cgarant, nmovimi, cpregun, crespue, nmovima, finiefe)
         (SELECT psseguro, nriesgo, cgarant, pnmovimi, cpregun, crespue, nmovima, pfsuplem
            FROM pregungaranseg
           WHERE sseguro = psseguro
             AND nmovimi = (SELECT MAX(nmovimi)
                              FROM pregunseg
                             WHERE sseguro = psseguro));

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 99;
   END f_duppregun;

---------------------------------------------------------------------------------------------------
-- Dupliquem les clausules que tenem num moviment, ja que sino dupliquem aquestes pel nou moviment
-- no existiran
---------------------------------------------------------------------------------------------------
   FUNCTION f_dupclausules(psseguro NUMBER, pfsuplem DATE, pnmovimi NUMBER)
      RETURN NUMBER IS
   BEGIN
      BEGIN
         INSERT INTO claubenseg
                     (nmovimi, sclaben, sseguro, nriesgo, finiclau, ffinclau)
            (SELECT pnmovimi, psseguro, sclaben, nriesgo, finiclau, ffinclau
               FROM claubenseg
              WHERE sseguro = psseguro
                AND nmovimi <> pnmovimi
                AND ffinclau IS NULL);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      BEGIN
         INSERT INTO clausuesp
                     (nmovimi, sseguro, cclaesp, nordcla, nriesgo, finiclau, sclagen, tclaesp,
                      ffinclau)
            (SELECT pnmovimi, psseguro, cclaesp, nordcla, nriesgo, finiclau, sclagen, tclaesp,
                    ffinclau
               FROM clausuesp
              WHERE sseguro = psseguro
                AND nmovimi <> pnmovimi
                AND ffinclau IS NULL);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      BEGIN
         INSERT INTO claususeg
                     (nmovimi, sseguro, sclagen, finiclau, ffinclau, nordcla)
            (SELECT pnmovimi, psseguro, sclagen, finiclau, ffinclau, nordcla
               FROM claususeg
              WHERE sseguro = psseguro
                AND nmovimi <> pnmovimi
                AND ffinclau IS NULL);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      BEGIN
         INSERT INTO clauparesp
                     (sseguro, nriesgo, nmovimi, sclagen, nparame, cclaesp, nordcla, tvalor,
                      ctippar)
            (SELECT psseguro, nriesgo, pnmovimi, sclagen, nparame, cclaesp, nordcla, tvalor,
                    ctippar
               FROM clauparesp
              WHERE sseguro = psseguro
                AND nmovimi <> pnmovimi);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      -- Actualitzem les clausules
      UPDATE claubenseg
         SET ffinclau = pfsuplem
       WHERE sseguro = psseguro
         AND nmovimi <> pnmovimi
         AND ffinclau IS NULL;

      UPDATE clausuesp
         SET ffinclau = pfsuplem
       WHERE sseguro = psseguro
         AND nmovimi <> pnmovimi
         AND ffinclau IS NULL;

      UPDATE claususeg
         SET ffinclau = pfsuplem
       WHERE sseguro = psseguro
         AND nmovimi <> pnmovimi
         AND ffinclau IS NULL;

      RETURN 0;
   END f_dupclausules;

   FUNCTION f_dupexclucarenseg(psseguro NUMBER, pfsuplem DATE, pnmovimi NUMBER)
      RETURN NUMBER IS
   BEGIN
      BEGIN
         -- Insertamos las exclusiones en el caso de que haya en el movimiento anterior.
         INSERT INTO excluseg
                     (sseguro, nriesgo, cgarant, nmovimi, finiefe, nmovima, cexclu, nduraci,
                      cizqder, nproext)
            (SELECT psseguro, nriesgo, cgarant, pnmovimi, pfsuplem, nmovima, cexclu, nduraci,
                    cizqder, nproext
               FROM excluseg
              WHERE sseguro = psseguro
                AND nmovimi IN(SELECT MAX(nmovimi)
                                 FROM garanseg
                                WHERE sseguro = psseguro
                                  AND nmovimi <> pnmovimi));
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      BEGIN
         INSERT INTO carenseg
                     (sseguro, nriesgo, cgarant, nmovimi, finiefe, nmovima, ccaren, nmescar)
            (SELECT psseguro, nriesgo, cgarant, pnmovimi, pfsuplem, nmovima, ccaren, nmescar
               FROM carenseg
              WHERE sseguro = psseguro
                AND nmovimi IN(SELECT MAX(nmovimi)
                                 FROM garanseg
                                WHERE sseguro = psseguro
                                  AND nmovimi <> pnmovimi));
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      RETURN 0;
   END f_dupexclucarenseg;

   FUNCTION f_dupgaran_ocs(psseguro NUMBER, pfsuplem DATE, pnmovimi NUMBER)
      RETURN NUMBER IS
   BEGIN
      BEGIN
         -- Insertamos las exclusiones en el caso de que haya en el movimiento anterior.
         INSERT INTO garansegcom
                     (sseguro, nriesgo, cgarant, nmovimi, finiefe, cmodcom, pcomisi)
            (SELECT psseguro, nriesgo, cgarant, pnmovimi, pfsuplem, cmodcom, pcomisi
               FROM garansegcom
              WHERE sseguro = psseguro
                AND nmovimi IN(SELECT MAX(nmovimi)
                                 FROM garanseg
                                WHERE sseguro = psseguro
                                  AND nmovimi <> pnmovimi));
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      BEGIN
         INSERT INTO garanseggas
                     (sseguro, nriesgo, cgarant, nmovimi, finiefe, cgastos, pvalor, pvalres,
                      nprima, cmatch, tdesmat, pintfin)
            (SELECT psseguro, nriesgo, cgarant, pnmovimi, pfsuplem, cgastos, pvalor, pvalres,
                    nprima, cmatch, tdesmat, pintfin
               FROM garanseggas
              WHERE sseguro = psseguro
                AND nmovimi IN(SELECT MAX(nmovimi)
                                 FROM garanseg
                                WHERE sseguro = psseguro
                                  AND nmovimi <> pnmovimi));
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      BEGIN
         INSERT INTO garanseg_sbpri
                     (sseguro, nriesgo, cgarant, nmovimi, finiefe, norden, ctipsbr, ccalsbr,
                      pvalor, ncomisi)
            (SELECT psseguro, nriesgo, cgarant, pnmovimi, pfsuplem, norden, ctipsbr, ccalsbr,
                    pvalor, ncomisi
               FROM garanseg_sbpri
              WHERE sseguro = psseguro
                AND nmovimi IN(SELECT MAX(nmovimi)
                                 FROM garanseg
                                WHERE sseguro = psseguro
                                  AND nmovimi <> pnmovimi));
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      RETURN 0;
   END f_dupgaran_ocs;

   FUNCTION f_prorrateo(
      psseguro IN NUMBER,
      pfinicial IN DATE,
      pffinal IN DATE,
      pfacnet OUT NUMBER,
      pfacdev OUT NUMBER,
      pfacnetsup OUT NUMBER,
      pfacdevsup OUT NUMBER)
      RETURN NUMBER IS
      xffinrec       DATE;
      xffinany       DATE;
      v_fcaranu      DATE;
      xcprorra       NUMBER;
      xcforpag       NUMBER;
      xndurcob       NUMBER;
      xnmeses        NUMBER;
      xsproduc       NUMBER;
      xfefepol       DATE;
      xnpoliza       NUMBER;
      fanyoprox      DATE;
      xcmodulo       NUMBER;
      difdias        NUMBER;
      difdiasanu     NUMBER;
      difdias2       NUMBER;
      difdiasanu2    NUMBER;
      divisor        NUMBER;
      divisor2       NUMBER;
      xpro_np_360    NUMBER;
      error          NUMBER;
   BEGIN
      SELECT fcaranu, cprorra, cforpag, s.ndurcob, fefecto, npoliza, s.sproduc
        INTO v_fcaranu, xcprorra, xcforpag, xndurcob, xfefepol, xnpoliza, xsproduc
        FROM seguros s, productos p
       WHERE s.sproduc = p.sproduc
         AND s.sseguro = psseguro;

      /******** Cálculo de los factores a aplicar para el prorrateo ********/
      xffinrec := pffinal;
      xffinany := v_fcaranu;
      fanyoprox := ADD_MONTHS(pfinicial, 12);

      -- Para calcular el divisor del modulo 365 (365 o 366)
      IF xcforpag <> 0 THEN
         IF xffinany IS NULL THEN
            IF xndurcob IS NULL THEN
               RETURN 104515;
            -- El camp ndurcob de SEGUROS ha de estar informat
            END IF;

            xnmeses := (xndurcob + 1) * 12;
            xffinany := ADD_MONTHS(pfinicial, xnmeses);

            IF xffinrec IS NULL THEN
               xffinrec := xffinany;
            END IF;
         END IF;
      ELSE
         xffinany := xffinrec;
      END IF;

      -- Cálculo de días
      IF xcprorra = 2 THEN   -- Mod. 360
         xcmodulo := 3;
      ELSE   -- Mod. 365
         xcmodulo := 1;
      END IF;

      error := f_difdata(pfinicial, xffinrec, 3, 3, difdias);

      IF error <> 0 THEN
         RETURN error;
      END IF;

      error := f_difdata(pfinicial, xffinany, 3, 3, difdiasanu);

      IF error <> 0 THEN
         RETURN error;
      END IF;

      error := f_difdata(pfinicial, xffinrec, xcmodulo, 3, difdias2);

      -- dias recibo
      IF error <> 0 THEN
         RETURN error;
      END IF;

      error := f_difdata(pfinicial, xffinany, xcmodulo, 3, difdiasanu2);

      -- dias venta
      IF error <> 0 THEN
         RETURN error;
      END IF;

      error := f_difdata(pfinicial, fanyoprox, xcmodulo, 3, divisor2);

      -- divisor del módulo de suplementos para pagos anuales
      IF error <> 0 THEN
         RETURN error;
      END IF;

      error := f_difdata(xfefepol, xffinrec, xcmodulo, 3, divisor);

      -- divisor del periodo para pago único
      IF error <> 0 THEN
         RETURN error;
      END IF;

      -- Calculem els factors a aplicar per prorratejar
      IF xcprorra IN(1, 2) THEN   -- Per dies
         IF xcforpag <> 0
            --  DRA:28/10/2013:0028690: POSTEC Camio forma de pago
            OR NVL(f_parproductos_v(xsproduc, 'PRORR_PRIMA_UNICA'), 0) = 1 THEN
            -- El càlcul del factor a la nova producció si s'ha de prorratejar, es fará modul 360 o
            -- mòdul 365 segon un paràmetre d'instal.lació
            xpro_np_360 := f_parinstalacion_n('PRO_NP_360');

            IF NVL(xpro_np_360, 1) = 1 THEN
               pfacnet := difdias / 360;
               pfacdev := difdiasanu / 360;
            ELSE
               IF MOD(difdias, 30) = 0 THEN
                  -- No hi ha prorrata
                  pfacnet := difdias / 360;
                  pfacdev := difdiasanu / 360;
               ELSE
                  -- Hi ha prorrata, prorratejem mòdul 365
                  pfacnet := difdias2 / divisor2;
                  pfacdev := difdiasanu2 / divisor2;
               END IF;
            END IF;

            pfacnetsup := difdias2 / divisor2;
            pfacdevsup := difdiasanu2 / divisor2;
         ELSE
            pfacnet := 1;
            pfacdev := 1;
            pfacnetsup := difdias2 / divisor;
            pfacdevsup := difdiasanu2 / divisor;
         END IF;
      ELSIF xcprorra = 3 THEN
         BEGIN
            SELECT f1.npercen / 100
              INTO pfacnet
              FROM federaprimas f1
             WHERE f1.npoliza = xnpoliza
               AND f1.diames = (SELECT MAX(f2.diames)
                                  FROM federaprimas f2
                                 WHERE f1.npoliza = f2.npoliza
                                   AND f2.diames <= TO_CHAR(pfinicial, 'mm/dd'));
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 109086;
         -- Porcentajes de prorrateo no dados de alta para la póliza
         END;

         IF xcforpag <> 0 THEN
            RETURN 109087;
         -- Tipo de prorrateo incompatible con la forma de pago
         ELSE
            pfacdev := pfacnet;
            pfacnetsup := pfacnet;
            pfacdevsup := pfacnet;
         END IF;
      ELSE
         RETURN 109085;   -- Codi de prorrateig inexistent
      END IF;

      IF NVL(f_parinstalacion_n('PRO_SP_360'), 0) = 1 THEN
         pfacnetsup := pfacnet;
         pfacdevsup := pfacdev;
      END IF;

      RETURN 0;
   END f_prorrateo;

   /*************************************************************************
         f_rebut_prima_deveng_ahorro: Genera recibo de extorno
        param in psseguro  : Código seguro
        param in pfcarpro_ant      : Fecha recibo anterior
        param out pfcarpro_nou : Fecha recibo
        param in pcforpag_ant      : Forma pago anterior
        param in pcforpag_nou : Forma pago
        param in pfcaranu : Fecha cartera
        param in pnmovimi : Numero movimiento
        param in pfsuplem : Fecha de suplemento
        param in pnriesgo : Número de riesgo

     *************************************************************************/
   FUNCTION f_rebut_prima_deveng_ahorro(
      psseguro IN NUMBER,
      pfcarpro_ant IN DATE,
      pfcarpro_nou IN DATE,
      pcforpag_ant IN NUMBER,
      pcforpag_nou IN NUMBER,
      pfcaranu IN DATE,
      pnmovimi IN NUMBER,
      pfsuplem IN DATE,
      pnriesgo IN NUMBER)
      RETURN NUMBER IS
      xnmovimiant    NUMBER;
      error          NUMBER;
      v_apperiodo_ant NUMBER;
      v_iprianu_ant  NUMBER;
      v_cgarant      NUMBER;
      v_apperiodo_nou NUMBER;
      v_iprianu_nou  NUMBER;
      xfacnet_ant    NUMBER;
      xfacdev_ant    NUMBER;
      xfacnetsup_ant NUMBER;
      xfacdevsup_ant NUMBER;
      xfacnet_nou    NUMBER;
      xfacdev_nou    NUMBER;
      xfacnetsup_nou NUMBER;
      xfacdevsup_nou NUMBER;
      num_err        NUMBER;
      prima_devengada_ant NUMBER;
      prima_devengada_nou NUMBER;
      prima_devengada NUMBER;
      xctiprec       NUMBER;
      wnrecibo       NUMBER;
      xfmovim        DATE;
      xcimprim       NUMBER;
      vccalcom       productos.ccalcom%TYPE;
      vporcagente    NUMBER;
      vporragente    NUMBER;
      vcomis_calc    NUMBER;
      vdecimals      NUMBER;
      v_cmodcom      comisionprod.cmodcom%TYPE;
   BEGIN
      -- Buscamos el movimiento anterior
      error := f_buscanmovimi(psseguro, 1, 1, xnmovimiant);

      IF error <> 0 THEN
         RETURN error;
      END IF;

      -- Miramos la prima en el movimiento actual
      SELECT NVL(SUM(g.icapital), 0), NVL(SUM(g.iprianu), 0), MAX(g.cgarant)
        INTO v_apperiodo_ant, v_iprianu_ant, v_cgarant   --48
        FROM garanseg g, seguros s
       WHERE g.sseguro = psseguro
         AND g.nmovimi = xnmovimiant
         AND g.nriesgo = NVL(pnriesgo, 1)
         AND s.sseguro = g.sseguro
         AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi, g.cgarant,
                             'TIPO') = 3;

      -- Miramos la prima en el movimiento anterior
      SELECT NVL(SUM(g.icapital), 0), NVL(SUM(g.iprianu), 0), MAX(g.cgarant)
        INTO v_apperiodo_nou, v_iprianu_nou, v_cgarant   --48
        FROM garanseg g, seguros s
       WHERE g.sseguro = psseguro
         AND g.nmovimi = pnmovimi
         AND g.nriesgo = NVL(pnriesgo, 1)
         AND s.sseguro = g.sseguro
         AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi, g.cgarant,
                             'TIPO') = 3;

      -- Prorrateo a aplicar para calcular la prima devengada anterior:
      -- desde fcarpro_ant a fcaranu.
      num_err := f_prorrateo(psseguro, pfcarpro_ant, pfcaranu, xfacnet_ant, xfacdev_ant,
                             xfacnetsup_ant, xfacdevsup_ant);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Prorrateo a aplicar para calcular la prima devengada actual:
      -- desde fcarpro_nou a fcaranu.
      num_err := f_prorrateo(psseguro, pfcarpro_nou, pfcaranu, xfacnet_nou, xfacdev_nou,
                             xfacnetsup_nou, xfacdevsup_nou);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      BEGIN
         SELECT productos.ccalcom,
                                  -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                  --DECODE(productos.cdivisa, 2, 2, 3, 1)
                                  pac_monedas.f_moneda_producto(productos.sproduc)
           -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
         INTO   vccalcom, vdecimals
           FROM productos, seguros
          WHERE seguros.sseguro = psseguro
            AND productos.sproduc = seguros.sproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 104347;   -- Producte no trobat a PRODUCTOS
         WHEN OTHERS THEN
            RETURN 102705;   -- Error al llegir de PRODUCTOS
      END;

      prima_devengada_ant := f_round(v_iprianu_ant * xfacdevsup_ant, vdecimals);
      prima_devengada_nou := f_round(v_iprianu_nou * xfacdevsup_nou, vdecimals);
      prima_devengada := prima_devengada_nou - prima_devengada_ant;

      IF prima_devengada >= 0 THEN
         xctiprec := 1;
      ELSE
         xctiprec := 9;
      END IF;

      num_err := f_insrecibo(psseguro, NULL, pfsuplem, pfcarpro_nou, pfcaranu, xctiprec, NULL,
                             NULL, NULL, 0, NULL, wnrecibo, 'R', NULL, NULL, pnmovimi,
                             f_sysdate);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

     -- insertyamos en detrecibos
-- Bug 8648 - 10/06/2009 - JRH -  Error en suplemento de suspención aportación periodica PPJ  Buscamos comisión
      INSERT INTO detrecibos
                  (nrecibo, cconcep, iconcep, cgarant, nriesgo, nmovima)
           VALUES (wnrecibo, 21, ABS(prima_devengada), v_cgarant, NVL(pnriesgo, 1), 1);

      BEGIN
         SELECT productos.ccalcom, DECODE(productos.cdivisa, 2, 2, 3, 1)
           INTO vccalcom, vdecimals
           FROM productos, seguros
          WHERE seguros.sseguro = psseguro
            AND productos.sproduc = seguros.sproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 104347;   -- Producte no trobat a PRODUCTOS
         WHEN OTHERS THEN
            RETURN 102705;   -- Error al llegir de PRODUCTOS
      END;

      IF vccalcom = 1 THEN   -- Sobre prima
         -- Bug 19777/95194 - 26/10/2011 -AMC
         IF f_es_renovacion(psseguro) = 0 THEN   -- es cartera
            v_cmodcom := 2;
         ELSE   -- si es 1 es nueva produccion
            v_cmodcom := 1;
         END IF;

         error := f_pcomisi(psseguro, v_cmodcom, f_sysdate, vporcagente, vporragente, NULL,
                            NULL, NULL, NULL, NULL, NULL, v_cgarant);

         --Fi Bug 19777/95194 - 26/10/2011 -AMC
         IF error <> 0 THEN
            RETURN error;
         END IF;

         vcomis_calc := f_round(NVL(prima_devengada, 0) * vporcagente / 100, vdecimals);

-- Fi Bug 8648
         INSERT INTO detrecibos
                     (nrecibo, cconcep, iconcep, cgarant, nriesgo, nmovima)
              VALUES (wnrecibo, 15, ABS(vcomis_calc), v_cgarant, NVL(pnriesgo, 1), 1);
      END IF;

      error := f_vdetrecibos('R', wnrecibo);

      IF error <> 0 THEN
         RETURN error;
      END IF;

      IF pfsuplem < pfcarpro_nou THEN
         xfmovim := pfcarpro_nou;
      ELSE
         xfmovim := pfsuplem;
      END IF;

      error := f_rebnoimprim(wnrecibo, xfmovim, xcimprim, NULL);

      IF error <> 0 THEN
         RETURN error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_rebut_prima_deveng_ahorro', 1,
                     'when others sseguro =' || psseguro, SQLERRM);
         RETURN 103513;   -- error al insertar en detrecibos
   END f_rebut_prima_deveng_ahorro;

   FUNCTION f_fcarpro_final(
      psseguro IN NUMBER,
      pfsuplem IN DATE,
      pcforpag_nou IN NUMBER,
      pcforpag_ant IN NUMBER,
      pfcarpro OUT DATE,
      pfeferec OUT DATE)
      RETURN NUMBER IS
      l_fcarpro      DATE;
      l_fefecto      DATE;
      num_err        NUMBER;
      desde_efecto   BOOLEAN;
      l_fefecto_1    DATE;
      v_ctipefe      NUMBER;
      v_sproduc      NUMBER;
      v_fcaranu      DATE;
      v_fefepol      DATE;
      v_fcarpro      DATE;
      l_fefecto_aux  DATE;
      v_modo         NUMBER;
      v_cempres      NUMBER;
      v_fcarpro_emp  DATE;
      l_fcaranu      DATE;
      v_cont         NUMBER;
   BEGIN
      BEGIN
         SELECT ctipefe, p.sproduc, fcaranu, fefecto, fcarpro, cempres
           INTO v_ctipefe, v_sproduc, v_fcaranu, v_fefepol, v_fcarpro, v_cempres
           FROM seguros s, productos p
          WHERE s.sproduc = p.sproduc
            AND s.sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 140720;
      END;

      IF NVL(f_parproductos_v(v_sproduc, 'TIPSUPFPAGO'), 1) = 2 THEN   -- tipo fecha mes siguiente
         num_err := pac_tfv.f_sup_fpago(psseguro, pfsuplem, pcforpag_nou, pcforpag_ant, 0,
                                        l_fcarpro, l_fcaranu);
         l_fefecto := l_fcarpro;
      ELSE
         IF pcforpag_ant < pcforpag_nou THEN   -- anual ==> semestral
            v_modo := 0;
         ELSIF(pcforpag_ant > pcforpag_nou
               OR pcforpag_ant = 0) THEN   -- mensual==> trimestral
            v_modo := 1;
         END IF;

          -- Obtenir data d'efecte del nou rebut, buscant la data de l'últim rebut
          -- no anulat..
         -- 17/2/2004. YIL. Si tiene el parámetro CAMB_FP_NO_REC = 1 entonces no se generará recibo
         -- en el cambio, y la fecha que consideraremos será la fecha mayor entre la fecha del suplemento
         -- y la de cartera de la empresa
         IF f_parproductos_v(v_sproduc, 'CAMB_FP_NO_REC') = 1 THEN
            BEGIN
               num_err := f_proxcar(v_cempres, v_fcarpro_emp);
            EXCEPTION
               WHEN OTHERS THEN
                  v_fcarpro_emp := NULL;
            END;

            l_fefecto := GREATEST(pfsuplem, LEAST(v_fcarpro_emp, v_fcarpro));

            -- Bug 8648 - 10/06/2009 - JRH -  Error en suplemento de suspención aportación periodica PPJ  En algun caso , el recibo de NP puede
            -- estar avanzado a v_fcarpro_emp (caso de credit), por eso cogeremos la máxima fecha entre l_fefecto i la fecvencim del recibo de NP si éste existe
            -- Sobretodo es para el caso de rehabilitación de la suspensió.
            DECLARE
               fecha          DATE;
            BEGIN
               num_err := f_ultim_venciment_np(psseguro, fecha);
               fecha := NVL(fecha, l_fefecto);
               l_fefecto := GREATEST(fecha, l_fefecto);
            END;
         --fi bug
         ELSE
            num_err := f_ultim_venciment(psseguro, l_fefecto);
         END IF;

         IF num_err <> 0 THEN
            RETURN num_err;
         ELSE
            -- Bug 29991/168276
            -- Para los productos Colectivos Agrupados se debe tratar de manera diferente
            -- el calculo de la fcarpro en el suplemento de 'Cambio de forma de pago' ya que
            -- para productos Colectivos Agrupados el certificado 0 no tiene recibos por lo que
            -- en este punto la variable l_fefecto siempre será NULL.
            IF l_fefecto IS NULL
               AND NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
               AND pac_seguros.f_es_col_agrup(psseguro) = 1
               AND pac_seguros.f_get_escertifcero(NULL, psseguro) = 1 THEN
               SELECT COUNT(1)
                 INTO v_cont
                 FROM seguros
                WHERE npoliza = (SELECT npoliza
                                   FROM seguros
                                  WHERE sseguro = psseguro)
                  AND ncertif <> 0;

               -- Si existen certificados, l_fefecto no puede ser nula, debe ser
               -- la fcarpro que tenia anteriormente, no mas pequeña
               IF v_cont > 0 THEN
                  l_fefecto := v_fcarpro;
               END IF;
            END IF;

            -- fin Bug 29991/168276
            IF l_fefecto IS NULL THEN
               desde_efecto := TRUE;

               IF v_ctipefe = 2
                  AND TO_CHAR(v_fefepol, 'dd') <> 1 THEN
                  l_fefecto_1 := '01/' || TO_CHAR(ADD_MONTHS(v_fefepol, 1), 'mm/yyyy');
               ELSE
                  l_fefecto_1 := v_fefepol;
               END IF;

               l_fefecto := v_fefepol;
            ELSE
               l_fefecto_1 := l_fefecto;
            END IF;

            IF (l_fefecto = v_fcarpro
                AND v_modo = 0)
               OR(l_fefecto = v_fcaranu
                  AND v_modo = 1) THEN
               -- No canvia rès
               l_fcarpro := v_fcarpro;
            ELSE
               IF pcforpag_nou IN(1, 0)
                  AND v_modo = 1 THEN
                  l_fcarpro := v_fcaranu;
               ELSE
                  -- Calculem la data de propera cartera
                  IF v_ctipefe = 2
                     AND TO_CHAR(v_fefepol, 'dd') <> 1 THEN
                     l_fefecto_aux := '01/' || TO_CHAR(ADD_MONTHS(l_fefecto_1, 1), 'mm/yyyy');
                  ELSE
                     l_fefecto_aux := l_fefecto;
                  END IF;

                  l_fcarpro := f_calcula_fcarpro(v_fcaranu, pcforpag_nou, l_fefecto_aux,
                                                 v_fefepol);
               END IF;
            END IF;
         END IF;
      END IF;   -- Tipo suplemento cambio forma de pago

      pfcarpro := l_fcarpro;
      pfeferec := l_fefecto;
      RETURN 0;
   END f_fcarpro_final;

   FUNCTION f_canvi_forpag_tf(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pfcaranu IN DATE,
      pfcarpro IN DATE,
      pfsuplem IN DATE,
      pcforpag_ant IN NUMBER,
      pcforpag_nou IN NUMBER,
      pctipreb IN NUMBER,
      paplica IN NUMBER,
      pnmovimi IN NUMBER)
      RETURN NUMBER IS
      l_fefecto      DATE;
      l_fcarpro      DATE;
      num_err        NUMBER;
      l_fvencim      DATE;
      l_cmodcom      NUMBER;
      l_ahorro       NUMBER;
      l_cmovi        NUMBER;
      limp           NUMBER;
      v_ctipefe      NUMBER;
      l_fefecto_aux  DATE;
      l_fefecto_1    DATE;
      desde_efecto   BOOLEAN := FALSE;
      lnomesextra    NUMBER;
      v_sproduc      NUMBER;
      lcapital       NUMBER;
      lcgarant       NUMBER;
      x_fcarpro      DATE;
      x_fcaranu      DATE;
      w_fefecto           DATE;     -- bug AMA-415 - FAL - 13/07/2016
      w_ptipomovimiento   NUMBER;   -- bug AMA-415 - FAL - 13/07/2016
   BEGIN
      -- Si s'aplica en data de cartera, no cal fer rebuts ni rès.
      IF paplica = 0 THEN
         BEGIN
            SELECT ctipefe, p.sproduc
              INTO v_ctipefe, v_sproduc
              FROM seguros s, productos p
             WHERE s.sproduc = p.sproduc
               AND s.sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 140720;   -- error al obterr el código de producto
         END;

         IF NVL(f_parproductos_v(v_sproduc, 'TIPSUPFPAGO'), 1) = 2 THEN   -- tipo fecha mes siguiente
            num_err := pac_tfv.f_sup_fpago(psseguro, pfsuplem, pcforpag_nou, pcforpag_ant, 1,
                                           x_fcarpro, x_fcaranu);

            IF num_err = 0 THEN
               UPDATE movseguro
                  SET femisio = f_sysdate
                WHERE sseguro = psseguro
                  AND nmovimi = pnmovimi;

               UPDATE seguros
                  SET csituac = 0,
                      femisio = f_sysdate
                WHERE sseguro = psseguro;
            END IF;
         ELSE
            num_err := f_parproductos(v_sproduc, 'NOMESEXTRA', lnomesextra);
            lnomesextra := NVL(lnomesextra, 0);
            -- Comprovem si és de més a menys fracionament o al contrari
            num_err := f_fcarpro_final(psseguro, pfsuplem, pcforpag_nou, pcforpag_ant,
                                       l_fcarpro, l_fefecto);

            IF num_err <> 0 THEN
               RETURN num_err;   -- error al buscar la fecha de cartera
            ELSE
                -- Generamos el recibo de prima devengada en caso de ahorro porque se puede
               -- cambiar a la vez la prima
               IF NVL(f_parproductos_v(v_sproduc, 'CAMB_FP_NO_REC'), 0) = 1
                  AND f_prod_ahorro(v_sproduc) = 1
                  AND NVL(f_parproductos_v(v_sproduc, 'REC_RIESGO_AHORRO'), 0) <> 1 THEN   -- bug19808
                  num_err := f_rebut_prima_deveng_ahorro(psseguro, pfcarpro, l_fcarpro,
                                                         pcforpag_ant, pcforpag_nou, pfcaranu,
                                                         pnmovimi, pfsuplem, 1);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END IF;

               IF l_fefecto < pfcaranu
                  --   AND l_fefecto <> pfcarpro
                  AND l_fefecto <> l_fcarpro THEN
                  -- La data de venciment del rebut és la de propera cartera
                  l_fvencim := l_fcarpro;

                  -- Veure si és la primera anualitat
                  IF f_es_renovacion(psseguro) = 1 THEN
                     l_cmodcom := 1;
                  ELSE
                     l_cmodcom := 2;
                  END IF;

                  IF f_esahorro(NULL, psseguro, num_err) = 1
                     AND NVL(f_parproductos_v(v_sproduc, 'REC_RIESGO_AHORRO'), 0) <> 1 THEN   --bug19808
                     IF num_err <> 0 THEN
                        RETURN num_err;
                     ELSE
                        l_ahorro := 1;
                        l_cmovi := 2;
                     END IF;
                  ELSE
                     l_ahorro := 0;
                  END IF;

                  BEGIN
                     UPDATE seguros
                        SET fcarpro = l_fcarpro,
                            csituac = 0,
                            cforpag = pcforpag_nou
                      WHERE sseguro = psseguro;
                  EXCEPTION
                     WHEN OTHERS THEN
                        RETURN 102361;
                  END;


                  -- bug AMA-415 - FAL - 13/07/2016
                  select max(fefecto) into w_fefecto
                  from movseguro
                  where sseguro = psseguro and
                        cmovseg in (0,2);

                  if trunc(l_fefecto) = trunc(w_fefecto) then --si efecto recibo = efecto de NP o renovación genera recibo como de NP (0), sinó como de renovación parcial o fraccionada (22) para que no genere impuestos
                    w_ptipomovimiento:= 0;
                  else
                    w_ptipomovimiento:= 22;
                  end if;
                  -- bug AMA-415 - FAL - 13/07/2016


                  IF l_ahorro = 1
                     AND lnomesextra = 1
                     AND desde_efecto THEN
                     BEGIN
                        SELECT SUM(icapital), MAX(cgarant)
                          INTO lcapital, lcgarant
                          FROM garanseg g, seguros s
                         WHERE g.sseguro = psseguro
                           AND s.sseguro = g.sseguro
                           -- AND cgarant = 282
                           AND f_pargaranpro_v(cramo, cmodali, ctipseg, ccolect, cactivi,
                                               cgarant, 'TIPO') = 3
                           AND g.ffinefe IS NULL;
                     EXCEPTION
                        WHEN OTHERS THEN
                           RETURN 111111;
                     END;

                     --BUG9028-XVM-01102009 inici
                          IF nvl(pac_parametros.f_parproducto_n(v_sproduc, 'AFECTA_COMISESPPROD'),0) = 1 THEN
                              BEGIN
                                    DELETE FROM garansegcom
                                          WHERE sseguro = psseguro
                                            AND nmovimi = pnmovimi;

                                    FOR rc IN (SELECT cgarant, nmovimi, iprianu
                                                 FROM garanseg g
                                                WHERE g.sseguro = psseguro
                                                  AND g.nmovimi =
                                                        (SELECT MAX(nmovimi)
                                                           FROM garanseg g2
                                                          WHERE g2.sseguro = g.sseguro
                                                            AND g2.nmovimi <= pnmovimi)) LOOP
                                       INSERT INTO garansegcom
                                                   (sseguro, nriesgo, cgarant, nmovimi, finiefe,
                                                    cmodcom, pcomisi, ninialt, nfinalt, pcomisicua,
                                                    falta, cusualt, fmodifi, cusumod, ipricom,
                                                    cageven)
                                          (SELECT sseguro, nriesgo, cgarant, pnmovimi, finiefe,
                                                  cmodcom, pcomisi, ninialt, nfinalt, pcomisicua,
                                                  falta, cusualt, fmodifi, cusumod, rc.iprianu,
                                                  cageven
                                             FROM garansegcom g
                                            WHERE sseguro = psseguro
                                              AND cgarant = rc.cgarant
                                              AND nmovimi =
                                                    (SELECT MAX(nmovimi)
                                                       FROM garansegcom g2
                                                      WHERE g2.sseguro = g.sseguro
                                                        AND g2.cgarant = g.cgarant
                                                        AND nmovimi <= rc.nmovimi));
                                    END LOOP;
                                 EXCEPTION
                                    WHEN OTHERS THEN
                                       p_tab_error(f_sysdate, f_user,
                                                   'PAC_CANVIFORPAG.F_CANVI_FORPAG_TF', 2,
                                                   'Error insertando en garansegcom ', SQLERRM);
                           END;
                      END IF;

                     IF NVL(pac_parametros.f_parinstalacion_n('CALCULO_RECIBO'), 1) = 0 THEN
                        -- Bug 14775 - RSC - 13/08/2010 - AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012
                        num_err := pac_adm.f_recries(pctipreb, psseguro, NULL, f_sysdate,
                                                     l_fefecto, l_fvencim, 1, NULL, NULL,
                                                     NULL, NULL, psproces,
                                                     -- 0,
                                                     w_ptipomovimiento, -- bug AMA-415 - FAL - 13/07/2016
                                                     'A', 1,
                                                     pfcaranu, lcapital, 2, pcempres,
                                                     pnmovimi, NULL, limp, NULL, lcgarant);
                     ELSE
                        num_err := f_recries(pctipreb, psseguro, NULL, f_sysdate, l_fefecto,
                                             l_fvencim, 1, NULL, NULL, NULL, NULL, psproces,
                                             -- 0,
                                             w_ptipomovimiento, -- bug AMA-415 - FAL - 13/07/2016
                                             'A', 1, pfcaranu, lcapital, 2, NULL, pnmovimi,
                                             NULL, limp, NULL, lcgarant);
                     END IF;

                     --BUG9028-XVM-01102009 fi
                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  ELSE
                     IF NVL(f_parproductos_v(v_sproduc, 'CAMB_FP_NO_REC'), 0) <> 1 THEN
                              -- para ahorro no generamos recibo, se generará en la cartera
                        --BUG9028-XVM-01102009 inici
                      IF nvl(pac_parametros.f_parproducto_n(v_sproduc, 'AFECTA_COMISESPPROD'),0) = 1 THEN
                         BEGIN
                              DELETE FROM garansegcom
                                    WHERE sseguro = psseguro
                                      AND nmovimi = pnmovimi;

                              FOR rc IN (SELECT cgarant, nmovimi, iprianu
                                           FROM garanseg g
                                          WHERE g.sseguro = psseguro
                                            AND g.nmovimi =
                                                  (SELECT MAX(nmovimi)
                                                     FROM garanseg g2
                                                    WHERE g2.sseguro = g.sseguro
                                                      AND g2.nmovimi <= pnmovimi)) LOOP
                                 INSERT INTO garansegcom
                                             (sseguro, nriesgo, cgarant, nmovimi, finiefe,
                                              cmodcom, pcomisi, ninialt, nfinalt, pcomisicua,
                                              falta, cusualt, fmodifi, cusumod, ipricom,
                                              cageven)
                                    (SELECT sseguro, nriesgo, cgarant, pnmovimi, finiefe,
                                            cmodcom, pcomisi, ninialt, nfinalt, pcomisicua,
                                            falta, cusualt, fmodifi, cusumod, rc.iprianu,
                                            cageven
                                       FROM garansegcom g
                                      WHERE sseguro = psseguro
                                        AND cgarant = rc.cgarant
                                        AND nmovimi =
                                              (SELECT MAX(nmovimi)
                                                 FROM garansegcom g2
                                                WHERE g2.sseguro = g.sseguro
                                                  AND g2.cgarant = g.cgarant
                                                  AND nmovimi <= rc.nmovimi));
                              END LOOP;
                           EXCEPTION
                              WHEN OTHERS THEN
                                 p_tab_error(f_sysdate, f_user,
                                             'PAC_CANVIFORPAG.F_CANVI_FORPAG_TF', 2,
                                             'Error insertando en garansegcom ', SQLERRM);
                           END;
                        END IF;

                        IF NVL(pac_parametros.f_parinstalacion_n('CALCULO_RECIBO'), 1) = 0 THEN
                           -- Bug 14775 - RSC - 13/08/2010 - AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012
                           num_err := pac_adm.f_recries(pctipreb, psseguro, NULL, f_sysdate,
                                                        l_fefecto, l_fvencim, 1, NULL, NULL,
                                                        NULL, NULL, psproces,
                                                        -- 0,
                                                        w_ptipomovimiento, -- bug AMA-415 - FAL - 13/07/2016
                                                        'R',
                                                        l_cmodcom, pfcaranu, 0, l_cmovi,
                                                        pcempres, pnmovimi, NULL, limp);
                        ELSE
                           num_err := f_recries(pctipreb, psseguro, NULL, f_sysdate,
                                                l_fefecto, l_fvencim, 1, NULL, NULL, NULL,
                                                NULL, psproces,
                                                -- 0,
                                                w_ptipomovimiento, -- bug AMA-415 - FAL - 13/07/2016
                                                'R', l_cmodcom, pfcaranu,
                                                0, l_cmovi, NULL, pnmovimi, NULL, limp);
                        END IF;

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;

                        --19808 -- se calcula el recibo de la parte de riesgo
                        IF NVL(f_parproductos_v(v_sproduc, 'SEPARA_RIESGO_AHORRO'), 0) = 1 THEN
                           IF NVL(pac_parametros.f_parinstalacion_n('CALCULO_RECIBO'), 1) = 0 THEN
                              num_err := pac_adm.f_recries(pctipreb, psseguro, NULL,
                                                           f_sysdate, l_fefecto, l_fvencim, 1,
                                                           NULL, NULL, NULL, NULL, psproces,
                                                           -- 0,
                                                           w_ptipomovimiento, -- bug AMA-415 - FAL - 13/07/2016
                                                           'RRIE', l_cmodcom, pfcaranu, 0,
                                                           l_cmovi, pcempres, pnmovimi, NULL,
                                                           limp);
                           ELSE
                              num_err := f_recries(pctipreb, psseguro, NULL, f_sysdate,
                                                   l_fefecto, l_fvencim, 1, NULL, NULL, NULL,
                                                   NULL, psproces,
                                                   -- 0,
                                                   w_ptipomovimiento, -- bug AMA-415 - FAL - 13/07/2016
                                                   'RRIE', l_cmodcom,
                                                   pfcaranu, 0, l_cmovi, NULL, pnmovimi, NULL,
                                                   limp);
                           END IF;

                           IF num_err <> 0 THEN
                              RETURN num_err;
                           END IF;
                        END IF;

                        --BUG9028-XVM-01102009 fi
                        IF num_err <> 0 THEN
                           RETURN num_err;
                        ELSE
                           -- Cal modificar el rebut per eliminar la prima devengada
                           -- si no li correspon
                           num_err := f_recalcula_rebut(psproces, psseguro, pnmovimi,
                                                        pfefecto, pfcaranu);
                        END IF;

                        --Bug.: 20923 - 14/01/2012 - ICV
                        IF NVL(pac_parametros.f_parempresa_n(pcempres, 'GESTIONA_COBPAG'), 0) =
                                                                                              1
                           AND num_err = 0 THEN
                           num_err := pac_ctrl_env_recibos.f_proc_recpag_mov(pcempres,
                                                                             psseguro,
                                                                             pnmovimi, 4,
                                                                             psproces);
                        --Si ha dado error
                        --De momento se comenta la devolución del error
                        /*
                        IF num_err <> 0 THEN
                          RETURN num_err;
                        end if;*/
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END IF;

            IF num_err = 0 THEN
               UPDATE movseguro
                  SET femisio = f_sysdate
                WHERE sseguro = psseguro
                  AND nmovimi = pnmovimi;

               UPDATE seguros
                  SET csituac = 0,
                      fcarpro = l_fcarpro,
                      femisio = f_sysdate
                WHERE sseguro = psseguro;
            END IF;
         END IF;   -- tip supl. pago
      END IF;

      -- aplica = 0
      RETURN 0;
   END f_canvi_forpag_tf;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_CANVIFORPAG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CANVIFORPAG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CANVIFORPAG" TO "PROGRAMADORESCSI";
