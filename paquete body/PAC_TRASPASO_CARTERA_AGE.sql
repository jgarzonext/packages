--------------------------------------------------------
--  DDL for Package Body PAC_TRASPASO_CARTERA_AGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_TRASPASO_CARTERA_AGE" AS
/******************************************************************************
   NAME:       PAC_TRASPASO_CARTERA_AGE
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        16/11/2009  ???              1. Created this package.
   2.0        29/03/2011  DRA              2. 0018078: LCOL - Analisis Traspaso de Cartera
   3.0        30/09/2011  DRA              3. 0019069: LCOL_C001 - Co-corretaje
   4.0        21/11/2011  JMP              4. 0018423: LCOL000: Multimoneda
   5.0        19/12/2011  JMF              5. 0020480: LCOL_C001: Ajuste de la retención en la función de cálculo
   6.0        14/01/2012  APD              6. 0020915: LCOL_C001: Consulta de Traspasos de cartera
   7.0        01/03/2012  APD              7. 0021421: LCOL_C001: Incidencia en el traspaso de cartera
   8.0        07/03/2012  MDS              8. 0021597: LCOL898-Enviar rebuts en Trasllats i canvis de sucursal
   9.0        31/10/2012  AVT              9. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
   10.0       27/03/2014  MMM              10. 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion...
******************************************************************************/
   FUNCTION f_traspasar_cartera(
      pcageini IN NUMBER,
      pcagefin IN NUMBER,
      pctiptra IN VARCHAR2,
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      psproces_in IN NUMBER,
      ptipotras IN NUMBER,
      pcomis IN t_iax_gstcomision,
      pcmotraspaso IN traspacarage.cmotraspaso%TYPE,
      ptobserv IN traspacarage.tobserv%TYPE,
      psproces_out OUT NUMBER)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(500)
         := 'pcageini: ' || pcageini || ' - pcagefin: ' || pcagefin || ' - pctiptra: '
            || pctiptra || ' - psseguro: ' || psseguro || ' - pnrecibo: ' || pnrecibo
            || ' - psproces_in: ' || psproces_in || ' - pcmotraspaso: ' || pcmotraspaso
            || ' - ptobserv: ' || ptobserv;
      vobject        VARCHAR2(200) := 'PAC_TRASPASO_CARTERA_AGE.f_traspasar_cartera';
      vtxt           VARCHAR2(500);
      v_stras        NUMBER;
      v_numerr       NUMBER;
      v_errproc      NUMBER;
      v_nmovimi      NUMBER;
      v_fsuplem      DATE;
      v_nsuplem      NUMBER;
      vantes         VARCHAR2(1000);
      vdespues       VARCHAR2(1000);
      xctipcoa       NUMBER;
      xncuacoa       NUMBER;
      xpcomcoa       NUMBER;
      porcagente     NUMBER;
      porragente     NUMBER;
      pcomisagente   NUMBER;
      pretenagente   NUMBER;
      xccalcom       NUMBER;
      xploccoa       NUMBER;   -- COASEGURO
      xsproduc       seguros.sproduc%TYPE;
      xcgarant       detrecibos.cgarant%TYPE;
      xnriesgo       detrecibos.nriesgo%TYPE;
      xcageven       detrecibos.cageven%TYPE;
      xnmovima       detrecibos.nmovima%TYPE;
      iconcep0       detrecibos.iconcep%TYPE;
      iconcep21      detrecibos.iconcep%TYPE;
      iconcep11      detrecibos.iconcep%TYPE;   -- BUG18078:DRA:29/03/2011
      iconcep12      detrecibos.iconcep%TYPE;   -- BUG18078:DRA:29/03/2011
      iconcep15      detrecibos.iconcep%TYPE;   -- BUG18078:DRA:29/03/2011
      iconcep16      detrecibos.iconcep%TYPE;   -- BUG18078:DRA:29/03/2011
      iconcep61      detrecibos.iconcep%TYPE;   -- 10.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion...
      v_cestrec      movrecibo.cestrec%TYPE;   -- BUG18078:DRA:29/03/2011
      v_fmovdia      movrecibo.fmovdia%TYPE;   -- BUG18078:DRA:29/03/2011
      v_fefecto      seguros.fefecto%TYPE;
      v_sseguro      seguros.sseguro%TYPE;
      v_cactivi      seguros.cactivi%TYPE;
      v_cramo        seguros.cramo%TYPE;
      v_cmodali      seguros.cmodali%TYPE;
      v_ctipseg      seguros.ctipseg%TYPE;
      v_ccolect      seguros.ccolect%TYPE;
      v_cempres      empresas.cempres%TYPE;
      v_sproces      procesoslin.sproces%TYPE;
      v_nprolin      procesoslin.nprolin%TYPE;
      pmoneda        monedas.cmoneda%TYPE := f_parinstalacion_n('MONEDAINST');
      v_cmodcom      comisionprod.cmodcom%TYPE;
      comis_calc     NUMBER;
      reten_calc     NUMBER;
      vpolok         NUMBER;
      error_proc     EXCEPTION;
      v_fefectovig   DATE;   --BUG20342 - JTS - 02/12/2011
      v_sproduc      NUMBER;   --BUG20342 - JTS - 02/12/2011
      v_fefectopol   DATE;   --BUG20342 - JTS - 02/12/2011
      v_param_sincroagen_cobpag NUMBER;   -- Bug 21597 - MDS - 08/03/2012
      v_param_gestiona_cobpag NUMBER;   -- Bug 21597 - MDS - 08/03/2012
      v_num          NUMBER;
      v_nmovaux      garansegcom.nmovimi%TYPE;
      v_mensajes	   T_IAX_MENSAJES;

      CURSOR cur_detrecibos IS
         SELECT   nriesgo, cgarant, cageven, nmovima
             FROM detrecibos
            WHERE nrecibo = pnrecibo
         GROUP BY nriesgo, cgarant, cageven, nmovima;

   CURSOR c_garansegcom(
         p_seguro NUMBER,
         p_nmovimi NUMBER,
         p_fecha DATE) IS
         SELECT cmodcom, sseguro, cgarant, ipricom, nriesgo, nmovimi
           FROM garansegcom seg
          WHERE seg.sseguro = p_seguro
            --AND seg.nriesgo = p_nriesgo
            --AND seg.cgarant = p_cgarant
            AND(seg.nmovimi = p_nmovimi
                OR(seg.nmovimi < p_nmovimi
                   AND seg.nmovimi = (SELECT MAX(seg2.nmovimi)
                                        FROM garansegcom seg2
                                       WHERE seg2.sseguro = seg.sseguro
                                         AND seg2.nriesgo = seg.nriesgo
                                         AND seg2.cgarant = seg.cgarant)));
   BEGIN
      IF NVL(pcageini, -1) = NVL(pcagefin, -1) THEN
         RETURN 9902052;
      END IF;

      vpasexec := 1;

      --Insertamos en la tabla PROCESOSCAB el registro identificativo de proceso -----
      IF psproces_in IS NOT NULL THEN
         v_sproces := psproces_in;
      ELSE
         v_errproc := f_empresa(psseguro, pnrecibo, NULL, v_cempres);

         IF v_errproc <> 0 THEN
            RAISE error_proc;
         END IF;

         v_errproc := f_procesini(f_user, v_cempres, 'TRASPASO_CARTERA_AGE',
                                  f_axis_literales(9002269, f_usu_idioma), v_sproces);

         IF v_errproc <> 0 THEN
            RAISE error_proc;
         END IF;
      END IF;

      psproces_out := v_sproces;
      v_nprolin := NULL;
      vpasexec := 2;

      SELECT stras.NEXTVAL
        INTO v_stras
        FROM DUAL;

      v_fsuplem := f_sysdate;

      INSERT INTO traspacarage
                  (stras, cageini, cagefin, ctiptra, sseguro, nrecibo, ftrasp,
                   sproces, nprolin, cestado, cmotraspaso, tobserv)
           VALUES (v_stras, pcageini, pcagefin, pctiptra, psseguro, pnrecibo, v_fsuplem,
                   v_sproces, v_nprolin, 0, pcmotraspaso, ptobserv);

      COMMIT;

      IF pctiptra = 'POL' THEN
         BEGIN
            vpasexec := 3;

            SELECT nsuplem,sproduc
              INTO v_nsuplem,v_sproduc
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_nsuplem := 0;
         END;

         vpasexec := 4;
         v_numerr := f_movseguro(psseguro, NULL, 999, 1, v_fsuplem, NULL, v_nsuplem + 1, 0,
                                 NULL, v_nmovimi, v_fsuplem);
         vpasexec := 5;
         v_numerr := f_act_hisseg(psseguro, v_nmovimi - 1);
         vpasexec := 6;
         vantes := f_axis_literales(100584, f_usu_idioma) || ' '
                   || f_axis_literales(112451, f_usu_idioma) || ': ' || pcageini;
         vpasexec := 7;
         vdespues := f_axis_literales(100584, f_usu_idioma) || ' '
                     || f_axis_literales(151287, f_usu_idioma) || ': ' || pcagefin;
         vpasexec := 8;

         INSERT INTO detmovseguro
                     (sseguro, nmovimi, cmotmov, nriesgo, cgarant, cpregun, tvalora,
                      tvalord)
              VALUES (psseguro, v_nmovimi, 999, 1, 0, 0, SUBSTR(vantes, 0, 1000),
                      SUBSTR(vdespues, 0, 1000));

         vpasexec := 9;

         IF ptipotras IS NOT NULL
            AND(ptipotras = 99
                OR ptipotras = 90) THEN
            UPDATE seguros
               SET cagente = pcagefin,
                   ctipcom = 99
             WHERE sseguro = psseguro
               AND cagente = pcageini;   -- BUG19069:DRA:03/10/2011

            IF ptipotras = 90 THEN
               FOR i IN pcomis.FIRST .. pcomis.LAST LOOP
                  vpasexec := 7;
                  p_tab_error(f_sysdate, f_user, vobject, vpasexec, v_numerr,
                              'tipotras:' || TO_CHAR(pcomis(i).cmodcom));

                  IF pcomis.EXISTS(i) THEN
                     vpasexec := 8;

                     SELECT COUNT(1)
                       INTO v_num
                       FROM comisionsegu
                      WHERE sseguro = psseguro
                        AND cmodcom = pcomis(i).cmodcom;

                     IF v_num > 0 THEN   --existeix, updatejem
                        vpasexec := 9;

                        UPDATE comisionsegu
                           SET cmodcom = pcomis(i).cmodcom,
                               pcomisi = pcomis(i).pcomisi,
                               ninialt = pcomis(i).ninialt,
                               nfinalt = pcomis(i).nfinalt
                         WHERE sseguro = psseguro
                           AND cmodcom = pcomis(i).cmodcom;
                     ELSE
                        vpasexec := 10;
                        p_tab_error(f_sysdate, f_user, vobject, vpasexec, v_numerr,
                                    'psseguro:' || psseguro || ' cmodcom:'
                                    || TO_CHAR(pcomis(i).cmodcom) || ' pcomisi:'
                                    || pcomis(i).pcomisi || ' ninialt:' || pcomis(i).ninialt
                                    || ' nfinalt:' || pcomis(i).nfinalt);

                        INSERT INTO comisionsegu
                                    (sseguro, cmodcom, pcomisi,
                                     ninialt, nfinalt)
                             VALUES (psseguro, pcomis(i).cmodcom, pcomis(i).pcomisi,
                                     pcomis(i).ninialt, pcomis(i).nfinalt);
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         ELSE
            UPDATE seguros
               SET cagente = pcagefin
             WHERE sseguro = psseguro
               AND cagente = pcageini;
         END IF;

         vpasexec := 91;

         -- BUG19069:DRA:30/09/2011:Inici
         IF pac_corretaje.f_tiene_corretaje(psseguro, NULL) = 1 THEN
            v_numerr := pac_corretaje.f_traspaso_corretaje(psseguro, v_nmovimi, NULL,
                                                           pcageini, pcagefin);

            IF v_numerr <> 0 THEN
               RAISE error_proc;
            END IF;
         END IF;

         -- BUG19069:DRA:30/09/2011:Fi
         vpasexec := 92;
         v_numerr := pk_suplementos.f_cambio_agente(psseguro);

         IF v_numerr <> 0 THEN
            v_numerr := 9000503;   -- Error al recuperar los datos del agente
            RAISE error_proc;
         END IF;

         BEGIN
          select max(nmovimi)
          into v_nmovaux
          from garansegcom
          where sseguro = psseguro;
        EXCEPTION
         WHEN OTHERS THEN
           v_nmovaux := 1;
        END;

        FOR i IN c_garansegcom(psseguro, v_nmovaux, v_fsuplem) LOOP
                delete from garansegcom where sseguro = i.sseguro and cgarant = i.cgarant and nmovimi = i.nmovimi;
        v_numerr := pac_comisiones.f_grabarcomisionmovimiento
                                                         (p_cempres => pac_md_common.f_get_cxtempresa,
                                                          p_sseguro => i.sseguro,
                                                          p_cgarant => i.cgarant,
                                                          p_nriesgo => i.nriesgo,
                                                          p_nmovimi => i.nmovimi,
                                                          p_fecha => trunc(sysdate),
                                                          p_modo => 'TRASP_CAR',
                                                          p_ipricom => i.ipricom,
                                                          p_cmodcom => i.cmodcom,
                                                          p_sproces => v_sproces,
                                                          p_mensajes => v_mensajes);
        END LOOP;

      ELSIF pctiptra IN('RECGES', 'RECPEN') THEN
         vpasexec := 10;

         SELECT sseguro
           INTO v_sseguro
           FROM recibos
          WHERE nrecibo = pnrecibo;

         SELECT MAX(nmovimi)
           INTO v_nmovimi
           FROM movseguro
          WHERE sseguro = v_sseguro;

         -- Si la poliza se ha seleccionado y ha fallado no se traspasaran sus recibos
         vpasexec := 101;

         SELECT COUNT(1)
           INTO vpolok
           FROM traspacarage
          WHERE sproces = v_sproces
            AND ctiptra = 'POL'
            AND sseguro = v_sseguro
            AND cageini = pcageini
            AND cagefin = pcagefin
            AND NVL(cestado, 0) <> 0;

         IF NVL(vpolok, 0) >= 1 THEN
            v_numerr := 9901950;
            RAISE error_proc;
         END IF;

         -- BUG19069:DRA:03/10/2011:Inici
         IF pac_corretaje.f_tiene_corretaje(v_sseguro, NULL) = 1 THEN
            vpasexec := 11;
            v_numerr := pac_corretaje.f_traspaso_corretaje(NULL, NULL, pnrecibo, pcageini,
                                                           pcagefin);
         ELSE
            -- BUG18078:DRA:29/03/2011:Inici
            SELECT m.cestrec, m.fmovdia
              INTO v_cestrec, v_fmovdia
              FROM movrecibo m
             WHERE m.nrecibo = pnrecibo
               AND m.smovrec = (SELECT MAX(m1.smovrec)
                                  FROM movrecibo m1
                                 WHERE m1.nrecibo = m.nrecibo);

            vpasexec := 12;

            -- Comision bruta
            SELECT NVL(SUM(iconcep), 0)
              INTO iconcep11
              FROM detrecibos
             WHERE nrecibo = pnrecibo
               AND cconcep = 11;

            vpasexec := 13;

            -- Retención Comision bruta
            SELECT NVL(SUM(iconcep), 0)
              INTO iconcep12
              FROM detrecibos
             WHERE nrecibo = pnrecibo
               AND cconcep = 12;

            vpasexec := 14;

            -- Comision devengada
            SELECT NVL(SUM(iconcep), 0)
              INTO iconcep15
              FROM detrecibos
             WHERE nrecibo = pnrecibo
               AND cconcep = 15;

            vpasexec := 15;

            -- Retención Comision devengada
            SELECT NVL(SUM(iconcep), 0)
              INTO iconcep16
              FROM detrecibos
             WHERE nrecibo = pnrecibo
               AND cconcep = 16;

            vpasexec := 16;
            v_numerr := pac_comisiones.f_anu_comisionrec(pnrecibo, v_cestrec, v_fmovdia,
                                                         iconcep11, iconcep12, iconcep15,
                                                         iconcep16, pcageini);

            IF v_numerr <> 0 THEN
               RAISE error_proc;
            END IF;

               -- BUG18078:DRA:29/03/2011:Fi
            --Modificació del agent del rebut tant Pendent com gestió de cobrament
            vpasexec := 17;

            -- Bug 21421 - APD - 01/03/2012 - se debe actualizar tambien el cdelega
            UPDATE recibos
               SET cagente = pcagefin,
                   cdelega = pac_redcomercial.f_busca_padre(cempres, pcagefin, 1, v_fsuplem)
             WHERE nrecibo = pnrecibo;

            -- fin Bug 21421 - APD - 01/03/2012
            -- Bug 19512/92724 - 30/09/2011 - AMC Si hi ha recàlcul de comissions, torna a generar els conceptes
            --segons la comissió del nou agent
            IF NVL(pac_parametros.f_parempresa_n(f_empres(), 'RECALCOM_TRASPASO'), 1) = 1 THEN
               vpasexec := 18;

               DELETE FROM detrecibos
                     WHERE nrecibo = pnrecibo
                       AND cconcep IN(11, 12, 15, 16);

               vpasexec := 19;

               OPEN cur_detrecibos;

               vpasexec := 20;

               FETCH cur_detrecibos
                INTO xnriesgo, xcgarant, xcageven, xnmovima;

               vpasexec := 21;

               WHILE cur_detrecibos%FOUND LOOP
                  iconcep0 := 0;
                  iconcep21 := 0;
                  vtxt := vparam || ' v_sseguro=' || v_sseguro || ' xnriesgo=' || xnriesgo
                          || 'xcgarant=' || xcgarant || ' xnmovima=' || xnmovima;
                  vpasexec := 22;

                  BEGIN
                     SELECT   NVL(SUM(iconcep), 0)
                         INTO iconcep0
                         FROM detrecibos
                        WHERE nrecibo = pnrecibo
                          AND nriesgo = xnriesgo
                          AND cgarant = xcgarant
                          AND NVL(nmovima, 0) =
                                NVL
                                   (NVL(xnmovima, nmovima), 0)   -- BUG 0038114 - FAL - 15/10/2015   -- AND nmovima = xnmovima
                          AND cconcep IN(0, 50)   -- LOCAL + CEDIDA
                     GROUP BY nriesgo, cgarant;
                  EXCEPTION
                     WHEN OTHERS THEN
                        iconcep0 := 0;
                  END;

                  vpasexec := 23;

                  BEGIN
                     SELECT   NVL(SUM(iconcep), 0)
                         INTO iconcep21
                         FROM detrecibos
                        WHERE nrecibo = pnrecibo
                          AND nriesgo = xnriesgo
                          AND cgarant = xcgarant
                          AND NVL(nmovima, 0) =
                                NVL
                                   (NVL(xnmovima, nmovima), 0)   -- BUG 0038114 - FAL - 15/10/2015   -- AND nmovima = xnmovima
                          AND cconcep IN(21, 71)   -- LOCAL + CEDIDA
                     GROUP BY nriesgo, cgarant;
                  EXCEPTION
                     WHEN OTHERS THEN
                        iconcep21 := 0;
                  END;

                  --CALCUL COMISIONS I RETENCIONS (MODE 'R': REAL)
                  --SI SE TRATA DE UN COASEGURO ACEPTADO. PUEDE PASAR QUE NOSOTROS PAGUEMOS DIRECTAMENTE AL
                  --AGENTE CON LO QUE PCOMCOA SERA NULO, Y DEBEREMOS IR A BUSCAR LOS PORCENTAJES POR P_FCOMISI.
                  --SINO PCOMCOA SERA DIFERENTE A NULO, Y TENDRA EL PORCENTAJE A PAGAR A LA OTRA COMPAÑIA Y LA
                  --COMISION Y RETENCIO EN VDETRECIBOS SERA 0.
                  vpasexec := 24;

                  SELECT ctipcoa, ncuacoa, fefecto, cactivi, cramo, cmodali,
                         ctipseg, ccolect
                                         -- JLB - I - BUG 18423 COjo la moneda del producto
                  ,      pac_monedas.f_moneda_producto(sproduc)
                    -- JLB - F - BUG 18423 COjo la moneda del producto
                  INTO   xctipcoa, xncuacoa, v_fefecto, v_cactivi, v_cramo, v_cmodali,
                         v_ctipseg, v_ccolect
                                             -- JLB - I - BUG 18423 COjo la moneda del producto
                  ,      pmoneda
                    -- JLB - F - BUG 18423 COjo la moneda del producto
                  FROM   seguros
                   WHERE sseguro = v_sseguro;

                  IF xctipcoa != 0 THEN
                     vpasexec := 25;

                     SELECT ploccoa
                       INTO xploccoa
                       FROM coacuadro
                      WHERE ncuacoa = xncuacoa
                        AND sseguro = v_sseguro;
                  END IF;

                  --COASEGURO ACEPTADO NO NOS INTERESA APLICAR DOS VECES EL PORCENTAJE LOCAL
                  IF xctipcoa = 8
                     OR xctipcoa = 9 THEN
                     xploccoa := 100;
                  END IF;

                  vpasexec := 26;

                  IF f_es_renovacion(v_sseguro) = 0 THEN   -- es cartera
                     v_cmodcom := 2;
                  ELSE   -- si es 1 es nueva produccion
                     v_cmodcom := 1;
                  END IF;

                  vpasexec := 261;

                  --BUG20342 - JTS - 02/12/2011
                  SELECT sproduc, fefecto
                    INTO v_sproduc, v_fefectopol
                    FROM seguros
                   WHERE sseguro = v_sseguro;

                  IF NVL(pac_parametros.f_parproducto_t(v_sproduc, 'FVIG_COMISION'),
                         'FEFECTO_REC') = 'FEFECTO_REC' THEN
                     v_fefectovig := f_sysdate;   --Efecto del recibo
                  ELSIF pac_parametros.f_parproducto_t(v_sproduc, 'FVIG_COMISION') =
                                                                                  'FEFECTO_POL' THEN   --Efecto de la póliza
                     BEGIN
                        SELECT TO_DATE(crespue, 'YYYYMMDD')
                          INTO v_fefectovig
                          FROM pregunpolseg
                         WHERE sseguro = v_sseguro
                           AND nmovimi = (SELECT MAX(p.nmovimi)
                                            FROM pregunpolseg p
                                           WHERE p.sseguro = v_sseguro)
                           AND cpregun = 4046;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           v_fefectovig := v_fefectopol;
                     END;
                  ELSIF pac_parametros.f_parproducto_t(v_sproduc, 'FVIG_COMISION') =
                                                                               'FEFECTO_RENOVA' THEN   -- efecto a la renovacion
                     v_fefectovig := TO_DATE(frenovacion(NULL, v_sseguro, 2), 'yyyymmdd');
                  END IF;

                  -- BUG 0020480 - 19/12/2011 - JMF: pfretenc te que ser data del dia
                  /*
                  v_numerr := f_pcomisi(NULL, v_cmodcom, f_sysdate, pcomisagente, pretenagente,
                                        pcagefin, v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                                        v_cactivi, NULL, 'POL', 'CAR', v_fefectovig);
                  */
                    -- BUG 0038114 - FAL - 15/10/2015. Informar param psseguro
                  v_numerr := f_pcomisi(v_sseguro, v_cmodcom, f_sysdate, pcomisagente,
                                        pretenagente, pcagefin, v_cramo, v_cmodali, v_ctipseg,
                                        v_ccolect, v_cactivi, NULL, 'POL', 'CAR', v_fefectovig);

                  --FIBUG20342
                  IF v_numerr <> 0 THEN
                     RAISE error_proc;
                  END IF;

                  BEGIN
                     vpasexec := 27;

                     SELECT p.ccalcom, p.sproduc
                       INTO xccalcom, xsproduc
                       FROM productos p, seguros s
                      WHERE p.sproduc = s.sproduc
                        AND s.sseguro = v_sseguro;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        v_numerr := 104347;   -- Producte no trobat a PRODUCTOS
                        RAISE error_proc;
                     WHEN OTHERS THEN
                        v_numerr := 102705;   -- Error al llegir de PRODUCTOS
                        RAISE error_proc;
                  END;

                  IF xctipcoa = 8
                     OR xctipcoa = 9 THEN
                     BEGIN
                        vpasexec := 28;

                        SELECT pcomcoa
                          INTO xpcomcoa
                          FROM coacedido
                         WHERE sseguro = v_sseguro
                           AND ncuacoa = xncuacoa;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN   -- 23183 AVT 31/10/2012 no hi ha coacedido a la Coa. Acceptada
                           xpcomcoa := NULL;
                        WHEN OTHERS THEN
                           v_numerr := 105582;   -- ERROR AL LEER DE LA TABLA COACEDIDO
                           RAISE error_proc;
                     END;

                     IF xpcomcoa IS NULL THEN
                        porcagente := pcomisagente;
                        porragente := pretenagente;
                     ELSE
                        porcagente := 0;
                        porragente := 0;
                     END IF;
                  ELSE
                     porcagente := pcomisagente;
                     porragente := pretenagente;
                  END IF;

                  --
                  -- Calculo de comisiones
                  --
                  IF xccalcom = 1 THEN   -- Sobre prima
                     vpasexec := 29;

                     IF f_es_renovacion(v_sseguro) = 0 THEN   -- es cartera
                        v_cmodcom := 2;
                     ELSE   -- si es 1 es nueva produccion
                        v_cmodcom := 1;
                     END IF;

                     vpasexec := 30;

                     --BUG20342 - JTS - 02/12/2011
                     SELECT sproduc, fefecto
                       INTO v_sproduc, v_fefectopol
                       FROM seguros
                      WHERE sseguro = v_sseguro;

                     IF NVL(pac_parametros.f_parproducto_t(v_sproduc, 'FVIG_COMISION'),
                            'FEFECTO_REC') = 'FEFECTO_REC' THEN
                        v_fefectovig := f_sysdate;   --Efecto del recibo
                     ELSIF pac_parametros.f_parproducto_t(v_sproduc, 'FVIG_COMISION') =
                                                                                  'FEFECTO_POL' THEN   --Efecto de la póliza
                        BEGIN
                           SELECT TO_DATE(crespue, 'YYYYMMDD')
                             INTO v_fefectovig
                             FROM pregunpolseg
                            WHERE sseguro = v_sseguro
                              AND nmovimi = (SELECT MAX(p.nmovimi)
                                               FROM pregunpolseg p
                                              WHERE p.sseguro = v_sseguro)
                              AND cpregun = 4046;
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              v_fefectovig := v_fefectopol;
                        END;
                     ELSIF pac_parametros.f_parproducto_t(v_sproduc, 'FVIG_COMISION') =
                                                                               'FEFECTO_RENOVA' THEN   -- efecto a la renovacion
                        v_fefectovig := TO_DATE(frenovacion(NULL, v_sseguro, 2), 'yyyymmdd');
                     END IF;

                     -- BUG 0020480 - 19/12/2011 - JMF: pfretenc te que ser data del dia
                     v_numerr := f_pcomisi(v_sseguro, v_cmodcom, f_sysdate, porcagente,
                                           porragente, NULL, NULL, NULL, NULL, NULL, NULL,
                                           xcgarant, NULL, 'CAR', v_fefectovig);

                     --FIBUG20342
                     IF v_numerr <> 0 THEN
                        RAISE error_proc;
                     END IF;
                  END IF;

                  vpasexec := 31;
                  comis_calc := f_round(NVL(iconcep0, 0) * porcagente / 100, pmoneda);

                  IF NVL(comis_calc, 0) <> 0
                     AND NVL(porcagente, 0) <> 0 THEN   --INSERTEM LA COMISIO
                     vpasexec := 32;
                     v_numerr := f_insdetrec(pnrecibo, 11, comis_calc, xploccoa, xcgarant,
                                             NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                             porcagente, v_sseguro);

                     IF v_numerr != 0 THEN
                        CLOSE cur_detrecibos;

                        RAISE error_proc;
                     END IF;

                     vpasexec := 33;
                     reten_calc := f_round(((comis_calc * porragente) / 100), pmoneda);

                     IF NVL(reten_calc, 0) <> 0 THEN   -- INSERTEM LA RETENCIO
                        vpasexec := 34;
                        v_numerr := f_insdetrec(pnrecibo, 12, reten_calc, xploccoa, xcgarant,
                                                NVL(xnriesgo, 0), xctipcoa, xcageven,
                                                xnmovima, porcagente, v_sseguro);

                        IF v_numerr != 0 THEN
                           CLOSE cur_detrecibos;

                           RAISE error_proc;
                        END IF;
                     END IF;
                  END IF;

                  --CALCUL COMISIO I RETENCIO DEVENGADES(CCONCEP = 15 I 16)(MODE 'R' : REAL)
                  --COMIS_CALC := ROUND(((COMIS_CALC * PORCAGENTE) / 100), 0);
                  vpasexec := 35;
                  comis_calc := f_round(NVL(iconcep21, 0) * porcagente / 100, pmoneda);

                  IF NVL(comis_calc, 0) <> 0
                     AND NVL(porcagente, 0) <> 0 THEN
                     --INSERTEM LA COMISIO DEVENGADA
                     vpasexec := 36;
                     v_numerr := f_insdetrec(pnrecibo, 15, comis_calc, xploccoa, xcgarant,
                                             NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                             porcagente, v_sseguro);

                     IF v_numerr != 0 THEN
                        CLOSE cur_detrecibos;

                        RAISE error_proc;
                     END IF;

                     vpasexec := 37;
                     reten_calc := f_round(((comis_calc * porragente) / 100), pmoneda);

                     IF NVL(reten_calc, 0) <> 0 THEN
                        -- INSERTEM LA RETENCIO DEVENGADA
                        vpasexec := 38;
                        v_numerr := f_insdetrec(pnrecibo, 16, reten_calc, xploccoa, xcgarant,
                                                NVL(xnriesgo, 0), xctipcoa, xcageven,
                                                xnmovima, porcagente, v_sseguro);

                        IF v_numerr != 0 THEN
                           CLOSE cur_detrecibos;

                           RAISE error_proc;
                        END IF;
                     END IF;
                  END IF;

                  IF v_numerr != 0 THEN
                     CLOSE cur_detrecibos;

                     RAISE error_proc;
                  END IF;

                  vpasexec := 39;

                  FETCH cur_detrecibos
                   INTO xnriesgo, xcgarant, xcageven, xnmovima;
               END LOOP;

               vpasexec := 40;

               CLOSE cur_detrecibos;

               vpasexec := 41;

               -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
               DELETE FROM vdetrecibos_monpol
                     WHERE nrecibo = pnrecibo;

               -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
               DELETE FROM vdetrecibos
                     WHERE nrecibo = pnrecibo;

               vpasexec := 42;
               v_numerr := f_vdetrecibos('R', pnrecibo);

               IF v_numerr <> 0 THEN
                  RAISE error_proc;
               END IF;
            END IF;   -- Bug 19512/92724 - 30/09/2011 - Fin

            vpasexec := 43;

            -- BUG18078:DRA:29/03/2011:Inici
            -- Comision bruta
            SELECT NVL(SUM(iconcep), 0)
              INTO iconcep11
              FROM detrecibos
             WHERE nrecibo = pnrecibo
               AND cconcep = 11;

            vpasexec := 44;

            -- Retención Comision bruta
            SELECT NVL(SUM(iconcep), 0)
              INTO iconcep12
              FROM detrecibos
             WHERE nrecibo = pnrecibo
               AND cconcep = 12;

            vpasexec := 45;

            -- Comision devengada
            SELECT NVL(SUM(iconcep), 0)
              INTO iconcep15
              FROM detrecibos
             WHERE nrecibo = pnrecibo
               AND cconcep = 15;

            vpasexec := 46;

            -- Retención Comision devengada
            SELECT NVL(SUM(iconcep), 0)
              INTO iconcep16
              FROM detrecibos
             WHERE nrecibo = pnrecibo
               AND cconcep = 16;

            vpasexec := 47;

            -- Retención Comision devengada
            SELECT NVL(SUM(iconcep), 0)
              INTO iconcep16
              FROM detrecibos
             WHERE nrecibo = pnrecibo
               AND cconcep = 16;

            vpasexec := 47;

            -- 10.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion... Inicio
            -- Se incluye la parte cedida

            -- Comisión cedida
            SELECT NVL(SUM(iconcep), 0)
              INTO iconcep61
              FROM detrecibos
             WHERE nrecibo = pnrecibo
               AND cconcep = 61;

            vpasexec := 48;
            v_numerr := pac_comisiones.f_alt_comisionrec(pnrecibo, v_cestrec, v_fmovdia,
                                                         (iconcep11 + iconcep61), iconcep12,
                                                         iconcep15, iconcep16, pcagefin, NULL,
                                                         iconcep61);
         -- 10.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion... Fin
         END IF;

         -- BUG19069:DRA:03/10/2011:Fi
         IF v_numerr <> 0 THEN
            RAISE error_proc;
         END IF;
      -- BUG18078:DRA:29/03/2011:Fi
      END IF;

      -- ini Bug 21597 - MDS - 08/03/2012
      v_param_sincroagen_cobpag :=
         NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'SINCROAGEN_COBPAG'),
             0);
      v_param_gestiona_cobpag :=
         NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'GESTIONA_COBPAG'),
             0);

     IF (v_param_sincroagen_cobpag = 1)
       AND(V_PARAM_GESTIONA_COBPAG = 1)
       AND pnrecibo is not null
       THEN
         DECLARE
          vemitido NUMBER;
          vsinterf NUMBER;
          v_ttippag NUMBER := 22;
          vterminal VARCHAR2(20);
          perror VARCHAR2(2000);
          verror NUMBER(10);

         BEGIN
         --compensar primas diferidas
            vsinterf  := NULL;
            perror    := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vterminal);
            verror    := pac_con.f_emision_pagorec(v_cempres, 1, v_ttippag, pnrecibo, 1, vterminal, vemitido, vsinterf, perror, f_user);
              IF verror <> 0 OR TRIM(perror) IS NOT NULL THEN
               RAISE error_proc;
              END IF;
        END;
       v_numerr    := pac_redcomercial.f_sincroniza_recibos(pcagefin, psseguro, pnrecibo);

       IF v_numerr <> 0 THEN
        RAISE error_proc;
       END IF;
     END IF;

      -- fin Bug 21597 - MDS - 08/03/2012
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN error_proc THEN
         ROLLBACK;
         v_nprolin := NULL;

         IF v_sproces IS NOT NULL THEN
            v_errproc := f_proceslin(v_sproces,
                                     vpasexec || '->'
                                     || SUBSTR(f_axis_literales(v_numerr, f_usu_idioma), 1,
                                               115),
                                     NVL(psseguro, pnrecibo), v_nprolin);
         END IF;

         UPDATE traspacarage
            SET cestado = 1,
                nprolin = v_nprolin
          WHERE stras = v_stras;

         COMMIT;
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, v_numerr,
                     f_axis_literales(v_numerr, f_usu_idioma));
         RETURN v_numerr;
      WHEN OTHERS THEN
         ROLLBACK;
         v_nprolin := NULL;

         IF v_sproces IS NOT NULL THEN
            v_errproc := f_proceslin(v_sproces, vpasexec || '->' || SUBSTR(SQLERRM, 1, 115),
                                     NVL(psseguro, pnrecibo), v_nprolin);
         END IF;

         UPDATE traspacarage
            SET cestado = 1,
                nprolin = v_nprolin
          WHERE stras = v_stras;

         COMMIT;
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, SQLCODE,
                     NVL(vtxt, vparam) || ': ' || SQLERRM);
         RETURN 1000001;
   END f_traspasar_cartera;

   FUNCTION f_get_listtraspasos(pcageini IN NUMBER, pcagefin IN NUMBER, pfefecto IN DATE)
      RETURN VARCHAR2 IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'pcageini: ' || pcageini || ' - pcagefin: ' || pcagefin || ' - pfefecto: '
            || pfefecto;
      vobject        VARCHAR2(200) := 'PAC_TRASPASO_CARTERA_AGE.f_get_listtraspasos';
      vsquery        VARCHAR2(2000);
      vfefecto       VARCHAR2(100) := pfefecto;
      vcempres       NUMBER := pac_md_common.f_get_cxtempresa;
      vwhere         VARCHAR2(100) := ' and 1=1 ';
   BEGIN
       -- Bug 20915 - APD - 14/01/2012 - se añade la variable vfefecto
      -- vfefecto := TO_CHAR(pfefecto, 'DD/MM/YYYY');
      IF vfefecto IS NOT NULL THEN
         vfefecto := CHR(39) || vfefecto || CHR(39);
         vwhere := ' AND (TRUNC (t.ftrasp) = ' || vfefecto || ') ';
      END IF;

      -- fin Bug 20915 - APD - 14/01/2012
      -- Bug 20915 - APD - 14/01/2012 - se modifica la condicion de filtro por la ftrasp
      -- ya que no estaba filtrando correctamente
      vsquery :=
         'SELECT DISTINCT t.cageini, f_nombre (a1.sperson, 1) tageini,'
         || ' t.cagefin, f_nombre (a2.sperson, 1) tagefin,'
         || ' TRUNC (t.ftrasp) ftrasp, t.sproces, MAX (t.cestado) cestado,'
         || ' ff_desvalorfijo (92, f_usu_idioma, decode (MAX (t.cestado), 0, 2, 1, 3, 0)) testado '
         || ' , (SELECT CAGENTE||'' ''||f_nombre (sperson, 1) FROM AGENTES WHERE CAGENTE = (SELECT CPADRE FROM REDCOMERCIAL WHERE CEMPRES = '
         || vcempres || ' AND CAGENTE = t.cageini AND FMOVFIN IS NULL))  CPADREINI '
         || ' , (SELECT CAGENTE||'' ''||f_nombre (sperson, 1) FROM AGENTES WHERE CAGENTE = (SELECT CPADRE FROM REDCOMERCIAL WHERE CEMPRES = '
         || vcempres
         || ' AND CAGENTE = t.cagefin AND FMOVFIN IS NULL))  CPADREFIN, ff_desvalorfijo(8001008, f_usu_idioma, t.CMOTRASPASO) TMOTRASPASO, t.TOBSERV '
         || ' FROM traspacarage t, agentes a1, agentes a2'
         || ' WHERE a1.cagente = t.cageini AND a2.cagente = t.cagefin AND t.cageini = '
         || NVL(TO_CHAR(pcageini), 't.cageini') || ' AND t.cagefin = '
         || NVL(TO_CHAR(pcagefin), 't.cagefin') || vwhere
         --|| ' AND (TRUNC (t.ftrasp) = NVL('|| NVL(TO_CHAR(vfefecto), 'NULL') || ',TRUNC (t.ftrasp)))'
         || ' GROUP BY t.cageini, f_nombre (a1.sperson, 1),'
         || ' t.cagefin, f_nombre (a2.sperson, 1), TRUNC (t.ftrasp), t.sproces, cmotraspaso, t.tobserv ';
      -- fin Bug 20915 - APD - 14/01/2012
      RETURN vsquery;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN NULL;
   END f_get_listtraspasos;

   FUNCTION f_get_listdettrasp(psproces IN NUMBER)
      RETURN VARCHAR2 IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'psproces: ' || psproces;
      vobject        VARCHAR2(200) := 'PAC_TRASPASO_CARTERA_AGE.f_get_listdettrasp';
      vsquery        VARCHAR2(2000);
   BEGIN
      vsquery :=
         'SELECT t.stras, t.cageini, f_nombre (a1.sperson, 1) tageini,'
         || ' t.cagefin, f_nombre (a2.sperson, 1) tagefin, t.ctiptra,'
         || ' f_axis_literales (decode (t.ctiptra, ''POL'', 111324, ''RECPEN'', 9001635, ''RECGES'', 9002260, 9901086), f_usu_idioma) ttiptra,'
         || ' t.sseguro, s.npoliza, t.nrecibo, t.ftrasp, t.sproces, t.nprolin, t.cestado,'
         || ' ff_desvalorfijo (92, f_usu_idioma, decode (t.cestado, 0, 2, 1, 3, 0)) testado, ff_desvalorfijo (8001008, f_usu_idioma, t.CMOTRASPASO) TMOTRASPASO, t.TOBSERV'
         || ' FROM traspacarage t, agentes a1, agentes a2, seguros s'
         || ' WHERE a1.cagente = t.cageini AND a2.cagente = t.cagefin AND s.sseguro(+) = t.sseguro'
         || ' AND t.sproces = ' || NVL(TO_CHAR(psproces), 't.sproces');
      RETURN vsquery;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN NULL;
   END f_get_listdettrasp;
END pac_traspaso_cartera_age;

/

  GRANT EXECUTE ON "AXIS"."PAC_TRASPASO_CARTERA_AGE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_TRASPASO_CARTERA_AGE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_TRASPASO_CARTERA_AGE" TO "PROGRAMADORESCSI";
