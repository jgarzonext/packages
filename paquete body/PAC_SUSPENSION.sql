--------------------------------------------------------
--  DDL for Package Body PAC_SUSPENSION
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY PAC_SUSPENSION
AS
/******************************************************************************
   NOMBRE:    PAC_suspension
   PROP¿SITO: Funciones para la suspensi¿n/reinicio de p¿lizas

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        14/11/2012   FAL                1. Creaci¿¿n del package (Bug 0024450)
   2.0        07/02/2013   FAL                2. 0025583: LCOL - Revision incidencias qtracker (IV)
   3.0        30/04/2013   ECP                3. 0026488: LCOL_T010-LCOL - Revision incidencias qtracker (VI) Nota 143648
   4.0        29/11/2013   DCT                4. 0024450: LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS.
   5.0        02/12/2013   DCT                5. 0029229: LCOL_T010-LCOL - Revision incidencias qtracker (VIII)
   6.0        11/12/2013   RSC                6. 0029229: LCOL_T010-LCOL - Revision incidencias qtracker (VIII)
   7.0        04/05/2015   BLA                7. 0034576/0197625: Habilitar la Suspensi¿n (Lapse) de p¿lizas para productos de Protecci¿n
   8.0        15/05/2019   CJMR               8. IAXIS-3654: Suplemento Suspensión y reinicio de contratos
*****************************************************************************/
   FUNCTION f_graba_tmpadm_recunif (p_nrecibo IN NUMBER, ptratar IN NUMBER)
      RETURN NUMBER
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      IF ptratar = 1
      THEN
         INSERT INTO tmp_adm_recunif
            SELECT *
              FROM adm_recunif
             WHERE nrecunif = p_nrecibo;

         DELETE      adm_recunif
               WHERE nrecunif = p_nrecibo;
      ELSIF ptratar = 2
      THEN
         INSERT INTO adm_recunif
            SELECT *
              FROM tmp_adm_recunif
             WHERE nrecunif = p_nrecibo;

         DELETE      tmp_adm_recunif
               WHERE nrecunif = p_nrecibo;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_SUSPENSION.f_graba_tmpadm_recunif',
                      1,
                      SQLCODE,
                         'p_nrecibo '
                      || p_nrecibo
                      || ' -- '
                      || 'SQLERROR: '
                      || SQLCODE
                      || ' - '
                      || SQLERRM
                     );
         RETURN 1;
   --FIN--BUG 15853 - 03/09/2010 - ETM -se hacen un mejor tratmiento de errores
   END f_graba_tmpadm_recunif;

   FUNCTION f_calcula_fcarpro (
      pfcaranu   IN   DATE,
      pcforpag   IN   NUMBER,
      pfefecto   IN   DATE,
      pfefepol   IN   DATE
   )
      RETURN DATE
   IS
      ddmm        VARCHAR2 (4);
      dd          VARCHAR2 (2);
      l_faux      DATE;
      l_fcarpro   DATE;
   BEGIN
      ddmm := LPAD (TO_CHAR (pfcaranu, 'ddmm'), 4, '0');
      dd := LPAD (TO_CHAR (pfcaranu, 'dd'), 2, '0');
      l_faux := pfcaranu;

      WHILE TRUE
      LOOP
         l_faux := f_summeses (l_faux, -12 / pcforpag, dd);

         -- BUG : 14119 - 13-04-2010 - JMC - Se modifica la condici¿n.
         /*
         IF (l_faux < pfefecto)
            OR(l_faux = pfefecto
               AND l_faux = pfefepol) THEN
         */
         IF (l_faux < pfefecto)
         THEN
            -- FIN BUG : 14119 - 13-04-2010 - JMC
               --  Es treu la igualtat, pq tiri enrera un periode m¿s,
               -- pq no fagi rebuts futurs de cartera,
               --  Es deixa la igualtat nom¿s per la Nova producci¿ , que no passa per cartera
            l_fcarpro := f_summeses (l_faux, 12 / pcforpag, dd);
            EXIT;
         END IF;
      END LOOP;

      RETURN l_fcarpro;
   END f_calcula_fcarpro;

   FUNCTION f_recibostochar (ppend IN rec_cob)
      RETURN VARCHAR2
   IS
      v_aux   VARCHAR2 (500);
   BEGIN
      IF ppend.FIRST IS NOT NULL
      THEN
         v_aux := '(' || ppend.COUNT || ':(nrecibo,fmovini,fefecto,fvencim) ';

         FOR i IN ppend.FIRST .. ppend.LAST
         LOOP
            v_aux :=
                  v_aux
               || '('
               || ppend (i).nrecibo
               || ','
               || ppend (i).fmovini
               || ','
               || ppend (i).fefecto
               || ','
               || ppend (i).fvencim
               || ') ';

            IF LENGTH (v_aux) >= 200
            THEN
               v_aux := v_aux || ' (...) ';
               EXIT;
            END IF;
         END LOOP;

         v_aux := v_aux || ')';
      ELSE
         v_aux := '(empty)';
      END IF;

      RETURN v_aux;
   END;

-- Funcion para extornar los recibos cobrados y suspendidos (con vigencia durante la suspension)
   FUNCTION f_extorn_rec_cobrats (
      psseguro   IN   NUMBER,
      pcagente   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pfsuspen   IN   DATE,
      pcmoneda   IN   NUMBER,
      prcob      IN   rec_cob
   )
      RETURN NUMBER
   IS
      ffecextini     DATE;
      ffecextfin     DATE;
      num_err        NUMBER;
      nnrecibo       NUMBER;
      nnfactor       NUMBER;
      cccobban       NUMBER;
      ccdelega       NUMBER;
      cex_pdte_imp   NUMBER;
      nnpneta        NUMBER;
      nnpconsor      NUMBER;
      nnpdeven       NUMBER;
      ccvalpar       NUMBER;
      vfefecto       DATE;
      -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186)
      vfvencim       DATE;
      -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186)
      vdecimals      NUMBER;
      -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186)
      v_cmodcom      comisionprod.cmodcom%TYPE;

      CURSOR rec_ext (pnrecibo IN NUMBER)
      IS
         SELECT r.nrecibo, d.cconcep, d.cgarant, NVL (d.nriesgo, 1) nriesgo,
                d.iconcep iconcep
           FROM detrecibos d, recibos r, seguros s
          WHERE d.nrecibo = r.nrecibo
            AND d.cconcep NOT IN (21, 71, 15, 16, 65, 66, 2, 52)
            AND r.sseguro = s.sseguro
            AND r.nrecibo = pnrecibo;

      CURSOR gar_venta (pnrecibo IN NUMBER)
      IS
         -- Bug 9685 - APD - 15/05/2009 - en lugar de coger la actividad de la tabla seguros,
         -- llamar a la funci¿n pac_seguros.ff_get_actividad
         SELECT DISTINCT cramo, cmodali, ctipseg, ccolect,
                         pac_seguros.ff_get_actividad
                                                     (s.sseguro,
                                                      NVL (d.nriesgo, 1)
                                                     ) cactivi,
                         cgarant
                    FROM recibos r, detrecibos d, seguros s
                   WHERE r.nrecibo = d.nrecibo
                     AND r.sseguro = s.sseguro
                     AND r.nrecibo = pnrecibo;

      v_sproces      NUMBER                      := 1;
      ximporx        NUMBER;
      reg_seg        seguros%ROWTYPE;
      v_nfactor      NUMBER;
      v_retctiprec   recibos.ctiprec%TYPE;
      rcob           rec_cob;
      n_rec          NUMBER;
      vcont          NUMBER;
      rcob_unif      rec_cob;
      n_rec_unif     NUMBER;
      v_sseguro      seguros.sseguro%TYPE;
      v_nmovimi      movseguro.nmovimi%TYPE;
      v_cagente      seguros.cagente%TYPE;
      v_fefecto      recibos.fefecto%TYPE;
      v_fvencim      recibos.fvencim%TYPE;
      v_fmovini      movrecibo.fmovini%TYPE;
      v_menor        NUMBER                      := 9999999999;
      v_res          NUMBER;
      pdifdata1      NUMBER;
      pdifdata2      NUMBER;
   BEGIN
      rcob.DELETE;
      n_rec := 0;

      IF prcob.FIRST IS NOT NULL
      THEN
         FOR i IN prcob.FIRST .. prcob.LAST
         LOOP
            n_rec := n_rec + 1;
            rcob (n_rec).nrecibo := prcob (i).nrecibo;
            rcob (n_rec).fmovini := prcob (i).fmovini;
            rcob (n_rec).fefecto := prcob (i).fefecto;
            rcob (n_rec).fvencim := prcob (i).fvencim;
         END LOOP;
      END IF;

      SELECT *
        INTO reg_seg
        FROM seguros
       WHERE sseguro = psseguro;

      BEGIN
         SELECT pac_monedas.f_moneda_producto (sproduc)
           INTO vdecimals
           FROM productos
          WHERE cramo = reg_seg.cramo
            AND cmodali = reg_seg.cmodali
            AND ctipseg = reg_seg.ctipseg
            AND ccolect = reg_seg.ccolect;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 104347;                  -- Producte no trobat a PRODUCTOS
         WHEN OTHERS
         THEN
            RETURN 102705;                    -- Error al llegir de PRODUCTOS
      END;

       /*
      {Extornamos los recibos cobrados que nos pasan en el parametro rcob}
       */
      /*
       {
        Marcamos un punto, por si el detalle de recibo no tiene los conceptos 0,2,50,52,21,71
       lo tiramos todo hacia atr¿s, pero solo hasta aqu¿. No es un error.
       }
      */
      SAVEPOINT recibos_extorno;

      IF rcob.FIRST IS NOT NULL
      THEN
         FOR i IN rcob.FIRST .. rcob.LAST
         LOOP
            IF v_menor > rcob (i).nrecibo
            THEN
               v_menor := rcob (i).nrecibo;
            END IF;
         END LOOP;
      END IF;

      /*
               { Si hab¿a recibos cobrados se devolver¿n aquellos que est¿n enteros y se prorratear¿
       si se devuelve parcialmente alg¿n recibo.}
      */
      IF rcob.FIRST IS NOT NULL
      THEN
         FOR i IN rcob.FIRST .. rcob.LAST
         LOOP
            -- ini Bug 0022701 - 03/09/2012 - JMF
            SELECT MAX (ctiprec)
              INTO v_retctiprec
              FROM recibos
             WHERE nrecibo = rcob (i).nrecibo;

            -- Los recibos de retorno los tratamos aparte.
            IF v_retctiprec NOT IN (13, 15)
            THEN
               -- fin Bug 0022701 - 03/09/2012 - JMF
               DECLARE
                  -- 0011652 A¿adir tipo certificado cero o no.
                  v_tipocert   VARCHAR2 (20);
               BEGIN
                  -- 0011652 A¿adir tipo certificado cero o no.
                  SELECT MAX (DECODE (esccero, 1, 'CERTIF0', NULL))
                    INTO v_tipocert
                    FROM recibos
                   WHERE nrecibo = rcob (i).nrecibo;

                  /*
                                           {Creamos el recibo de extorno de primas desde la suspension hasta el vto}
                  */
                  --ffecextini := pfsuspen;   -- inicio extorno ser¿ la fecha de suspensi¿n

                  -- RSC -- 22/07/2013 - qt: 8698
                  IF rcob (i).nrecibo = v_menor
                  THEN
                     ffecextini := pfsuspen;
                  ELSE
                     ffecextini := rcob (i).fefecto;
                  -- inicio extorno ser¿ la fecha de suspensi¿n
                  END IF;

                  -- Fin qT: 8698
                  ffecextfin := rcob (i).fvencim;
                    -- vto. extorno ser¿ el vto. del recibo cobrado a extornar
                  --
                  --
                  -- 0011652 A¿adir tipo certificado cero o no.
                  nnrecibo := NULL;
                  num_err :=
                     f_insrecibo (psseguro,
                                  pcagente,
                                  f_sysdate,
                                  ffecextini,
                                  ffecextfin,
                                  9,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  nnrecibo,
                                  'R',
                                  NULL,
                                  NULL,
                                  pnmovimi,
                                  f_sysdate,
                                  v_tipocert
                                 );

                  --                                {El error 103108 , es un error controlado se genera el recibo}
                  IF num_err NOT IN (0, 103108)
                  THEN
                     RETURN num_err;
                  END IF;

                  -- Bug 25583 - RSC - 28/01/2013
                  IF     v_tipocert = 'CERTIF0'
                     AND pac_seguros.f_get_escertifcero (NULL, psseguro) = 1
                  THEN
                     UPDATE recibos
                        SET cestaux = 0
                      WHERE nrecibo = nnrecibo;
                  END IF;

                  -- FIn bug 25583

                  --                         {Buscamos el nrecibo que hemos creado}
                  BEGIN
                     SELECT MAX (nrecibo), MAX (cdelega)
                       INTO nnrecibo, ccdelega
                       FROM recibos
                      WHERE sseguro = psseguro AND nmovimi = pnmovimi;
                  END;

                  BEGIN
                     SELECT ccobban
                       INTO cccobban
                       FROM seguros
                      WHERE sseguro = psseguro;
                  END;

                  IF cccobban IS NOT NULL
                  THEN
                     cex_pdte_imp :=
                                   NVL (f_parinstalacion_n ('EX_PTE_IMP'), 0);
                  END IF;

                  IF cex_pdte_imp = 0
                  THEN
                     UPDATE recibos
                        SET cestimp = 7
                      WHERE nrecibo = nnrecibo;
                  END IF;

                  DELETE      detrecibos
                        WHERE nrecibo = nnrecibo;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     RETURN 105156;
               END;

               v_res :=
                       f_difdata (pfsuspen, rcob (i).fvencim, 3, 3, pdifdata1);
               v_res :=
                  f_difdata (rcob (i).fefecto,
                             rcob (i).fvencim,
                             3,
                             3,
                             pdifdata2
                            );

               IF rcob (i).fefecto < pfsuspen
               THEN
                  nnfactor := pdifdata1 / pdifdata2;
               ELSE
                  nnfactor := 1;
               END IF;

               --                  {recuperamos y grabamos los conceptos de los recibos a extornar}
               FOR c IN rec_ext (rcob (i).nrecibo)
               LOOP
                  -- Bug 19557 - APD - 31/10/2011 -  funcion para determinar si se debe
                  -- realizar o no el retorno de un recibo a extornar

                  -- BUG 0020414 - 05/12/2011 - JMF: a¿adir factor
                  v_nfactor := nnfactor;
                  num_err :=
                     pac_anulacion.f_concep_retorna_anul (psseguro,
                                                          pnmovimi,
                                                          reg_seg.sproduc,
                                                          c.cconcep,
                                                          pfsuspen,
                                                          -- BUG 19557 - 22/11/2011 - JMP - LCOL_T001-Despeses expedici¿
                                                          v_nfactor
                                                         );

                  --                                                                              {El error 1 , es un error controlado}
                  IF num_err NOT IN (0, 1)
                  THEN
                     RETURN num_err;
                  END IF;

                  -- Bug 19557 - APD - 28/10/2011 - se a¿ade la condicion IF
                  -- si el error 0, se debe insertar en detrecibos (si se debe realizar el extorno)
                  -- si el error 1, NO se debe insetar en detrecibos (NO se retorna el recibo)
                  IF num_err = 0
                  THEN
                     BEGIN
                        INSERT INTO detrecibos
                                    (nrecibo, cconcep, cgarant,
                                     nriesgo,
                                     iconcep
                                    )
                             VALUES (nnrecibo, c.cconcep, c.cgarant,
                                     c.nriesgo,
                                     f_round (c.iconcep * v_nfactor, pcmoneda)
                                    );
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX
                        THEN
                           BEGIN
                              UPDATE detrecibos
                                 SET iconcep =
                                          iconcep
                                        + f_round (c.iconcep * v_nfactor,
                                                   pcmoneda
                                                  )
                               WHERE nrecibo = nnrecibo
                                 AND cconcep = c.cconcep
                                 AND cgarant = c.cgarant
                                 AND nriesgo = c.nriesgo;
                           EXCEPTION
                              WHEN OTHERS
                              THEN
                                 RETURN 104377;
                           --{ error al modificar recibos}
                           END;
                        WHEN OTHERS
                        THEN
                           RETURN 103513; --{error al insertar en detrecibos}
                     END;
                  -- fin Bug 22826 - APD - 11/07/2012
                  END IF;
               -- fin Bug 19557 - APD - 28/10/2011 - se a¿ade la condicion IF
               END LOOP;

               DELETE FROM vdetrecibos_monpol
                     WHERE nrecibo = nnrecibo;

               -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
               DELETE      vdetrecibos
                     WHERE nrecibo = nnrecibo;

               num_err := f_vdetrecibos ('R', nnrecibo);

               IF num_err = 0
               THEN
                  SELECT fefecto, fvencim
                    INTO vfefecto, vfvencim
                    FROM recibos
                   WHERE nrecibo = nnrecibo;

                  num_err :=
                     pac_cesionesrea.f_cessio_det (v_sproces,
                                                   psseguro,
                                                   nnrecibo,
                                                   reg_seg.cactivi,
                                                   reg_seg.cramo,
                                                   reg_seg.cmodali,
                                                   reg_seg.ctipseg,
                                                   reg_seg.ccolect,
                                                   vfefecto,
                                                   vfvencim,
                                                   1,
                                                   vdecimals
                                                  );
               ELSE
                  RETURN num_err;
               END IF;

               -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186) - Fi
               num_err :=
                  f_prima_minima_extorn (psseguro,
                                         nnrecibo,
                                         2,
                                         NULL,
                                         NULL,
                                         7,
                                         pcagente,
                                         ffecextini
                                        );

               IF num_err <> 0
               THEN
                  RETURN num_err;
               END IF;

               IF pac_retorno.f_tiene_retorno (NULL, psseguro, NULL) = 1
               THEN
                  num_err :=
                     pac_retorno.f_generar_retorno (psseguro,
                                                    NULL,
                                                    nnrecibo,
                                                    NULL
                                                   );

                  IF num_err <> 0
                  THEN
                     p_tab_error (f_sysdate,
                                  f_user,
                                  'pac_suspension.f_extorn_rec_cobrats',
                                  1313,
                                     'psseguro:'
                                  || psseguro
                                  || ' pnmovimi:'
                                  || pnmovimi
                                  || ' num_err='
                                  || num_err,
                                  SQLCODE || ' ' || SQLERRM
                                 );
                     RETURN num_err;
                  END IF;
               END IF;
            END IF;
         -- fin Bug 0022701 - 03/09/2012 - JMF
         END LOOP;
      END IF;

/*
      IF nnrecibo IS NOT NULL THEN   -- bug 19451/92191 - 13/09/2011 - AMC
         --                                     {Calculamos el consorcio}
         num_err := f_consoranul(psseguro, pfsuspen, nnrecibo, pcmoneda);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         --             {Miramos si el recibo no tiene importe}
         SELECT COUNT(DECODE(cconcep, 0, 'a', 50, 'a', NULL)),
                --{num. registros prima neta}
                COUNT(DECODE(cconcep, 2, 'a', 52, 'a', NULL)),
                --{num. registros consoricio}
                COUNT(DECODE(cconcep, 21, 'a', 71, 'a', NULL))
           --{num. registros prima devengada}
         INTO   nnpneta,
                nnpconsor,
                nnpdeven
           FROM detrecibos
          WHERE nrecibo = nnrecibo
            AND cconcep IN(0, 50, 2, 52, 21, 71);

         --               {si el recibo no tiene los conceptos tiramos hacia atras, hasta el savepoint}
         IF nnpneta = 0
            AND nnpconsor = 0
            AND nnpdeven = 0 THEN
            ROLLBACK TO recibos_extorno;
         ELSE
            --            {grabamos una venta igual a la prima que extornamos}
            INSERT INTO detrecibos
                        (nrecibo, cgarant, nriesgo, iconcep, cconcep)
               (SELECT nrecibo, cgarant, nriesgo, iconcep,
                       DECODE(cconcep,
                              0, 21,
                              11, 15,
                              12, 16,
                              50, 71,
                              61, 65,
                              62, 66,
                              NULL) cconcep
                  FROM detrecibos
                 WHERE cconcep IN(0, 50, 11, 61, 12, 62)
                   AND nrecibo = nnrecibo);

            --                {Borramos las garant¿as que no generan venta}
            FOR g IN gar_venta(nnrecibo) LOOP
               num_err := f_pargaranpro(g.cramo, g.cmodali, g.ctipseg, g.ccolect, g.cactivi,
                                        g.cgarant, 'GENVENTA', ccvalpar);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;

               IF NVL(ccvalpar, 1) = 0 THEN
                  --                { La garantia no genera venta eliminamos los conceptos para esta garant¿a}
                  DELETE FROM detrecibos
                        WHERE nrecibo = nnrecibo
                          AND cgarant = g.cgarant
                          AND cconcep IN(21, 71, 15, 16, 65, 66);
               END IF;
            END LOOP;

            --                     { restauramos los totales del recibo}
            -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
            DELETE FROM vdetrecibos_monpol
                  WHERE nrecibo = nnrecibo;

            -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
            DELETE      vdetrecibos
                  WHERE nrecibo = nnrecibo;

            num_err := f_vdetrecibos('R', nnrecibo);

            -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186) - Inici
            -- IF num_err <> 0 THEN
            --    RETURN num_err;
            -- END IF;
            IF num_err = 0 THEN
               SELECT fefecto, fvencim
                 INTO vfefecto, vfvencim
                 FROM recibos
                WHERE nrecibo = nnrecibo;

               num_err := pac_cesionesrea.f_cessio_det(v_sproces, psseguro, nnrecibo,
                                                       reg_seg.cactivi, reg_seg.cramo,
                                                       reg_seg.cmodali, reg_seg.ctipseg,
                                                       reg_seg.ccolect, vfefecto, vfvencim, 1,
                                                       vdecimals);
            ELSE
               RETURN num_err;
            END IF;

            -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186) - Fi
            num_err := f_prima_minima_extorn(psseguro, nnrecibo, 2, NULL, NULL, 7, pcagente,
                                             ffecextini);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;*/

      -- ini Bug 0022701 - 03/09/2012 - JMF
      /*IF pac_retorno.f_tiene_retorno(NULL, psseguro, NULL) = 1 THEN
         num_err := pac_retorno.f_generar_retorno(psseguro, NULL, nnrecibo, NULL);

         IF num_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'pac_suspension.f_extorn_rec_cobrats', 1313,
                        'psseguro:' || psseguro || ' pnmovimi:' || pnmovimi || ' num_err='
                        || num_err,
                        SQLCODE || ' ' || SQLERRM);
            RETURN num_err;
         END IF;
      END IF;*/

      -- fin Bug 0022701 - 03/09/2012 - JMF

      --Se a¿ade la llamada a los procesos de envio a ERP en el extrono de prima devengada, de momento
      --no se env¿an estos recibos a la ERP, pero se deja preparado.
      --Bug.: 20923 - 14/01/2012 - ICV
      /*IF NVL(pac_parametros.f_parempresa_n(reg_seg.cempres, 'GESTIONA_COBPAG'), 0) = 1
         AND num_err = 0 THEN
         num_err := pac_ctrl_env_recibos.f_proc_recpag_mov(reg_seg.cempres, psseguro,
                                                           pnmovimi, 4, NULL);
      --Si ha dado error retornamos el error
      --De momento no retornamos el error
      END IF;*/

      --Fi Bug.: 20923
      --END IF;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_suspension.f_extorn_rec_cobrats',
                      1,
                         'psseguro:'
                      || psseguro
                      || ' pcagente:'
                      || pcagente
                      || ' pnmovimi:'
                      || pnmovimi
                      || ' pcmoneda:'
                      || pcmoneda
                      || ' pfsuspen:'
                      || pfsuspen
                      || ' rcob:'
                      || f_recibostochar (rcob),
                      SQLERRM
                     );
         RETURN 140999;                                 --{Error no controlat}
   END f_extorn_rec_cobrats;

   -- Funcion para extornar los recibos anuales/unicos y cobrados/pdtes y suspendidos (con vigencia entre la suspension y el reinicio)
   FUNCTION f_extorn_rec_unic_anual (
      psseguro   IN   NUMBER,
      pcagente   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pfsuspen   IN   DATE,
      pfreini    IN   DATE,
      pcmoneda   IN   NUMBER,
      prcob      IN   rec_cob
   )
      RETURN NUMBER
   IS
      ffecextini     DATE;
      ffecextfin     DATE;
      num_err        NUMBER;
      nnrecibo       NUMBER;
      nnfactor       NUMBER;
      cccobban       NUMBER;
      ccdelega       NUMBER;
      cex_pdte_imp   NUMBER;
      nnpneta        NUMBER;
      nnpconsor      NUMBER;
      nnpdeven       NUMBER;
      ccvalpar       NUMBER;
      vfefecto       DATE;
      -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186)
      vfvencim       DATE;
      -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186)
      vdecimals      NUMBER;
      -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186)
      v_cmodcom      comisionprod.cmodcom%TYPE;

      CURSOR rec_ext (pnrecibo IN NUMBER)
      IS
         SELECT r.nrecibo, d.cconcep, d.cgarant, NVL (d.nriesgo, 1) nriesgo,
                d.iconcep iconcep
           FROM detrecibos d, recibos r, seguros s
          WHERE d.nrecibo = r.nrecibo
            AND d.cconcep NOT IN (21, 71, 15, 16, 65, 66, 2, 52)
            AND r.sseguro = s.sseguro
            AND r.nrecibo = pnrecibo;

      CURSOR gar_venta (pnrecibo IN NUMBER)
      IS
         -- Bug 9685 - APD - 15/05/2009 - en lugar de coger la actividad de la tabla seguros,
         -- llamar a la funci¿n pac_seguros.ff_get_actividad
         SELECT DISTINCT cramo, cmodali, ctipseg, ccolect,
                         pac_seguros.ff_get_actividad
                                                     (s.sseguro,
                                                      NVL (d.nriesgo, 1)
                                                     ) cactivi,
                         cgarant
                    FROM recibos r, detrecibos d, seguros s
                   WHERE r.nrecibo = d.nrecibo
                     AND r.sseguro = s.sseguro
                     AND r.nrecibo = pnrecibo;

      v_sproces      NUMBER                      := 1;
      ximporx        NUMBER;
      reg_seg        seguros%ROWTYPE;
      v_nfactor      NUMBER;
      v_retctiprec   recibos.ctiprec%TYPE;
      rcob           rec_cob;
      n_rec          NUMBER;
      vcont          NUMBER;
      rcob_unif      rec_cob;
      n_rec_unif     NUMBER;
      v_sseguro      seguros.sseguro%TYPE;
      v_nmovimi      movseguro.nmovimi%TYPE;
      v_cagente      seguros.cagente%TYPE;
      v_fefecto      recibos.fefecto%TYPE;
      v_fvencim      recibos.fvencim%TYPE;
      v_fmovini      movrecibo.fmovini%TYPE;
      --BUG 27048 - INICIO - DCT - 14/11/2013
      v_cprorra      productos.cprorra%TYPE;
      vdifdata1      NUMBER;
      vdifdata2      NUMBER;
   --BUG 27048 - FIN - DCT - 14/11/2013
   BEGIN
      rcob.DELETE;
      n_rec := 0;

      IF prcob.FIRST IS NOT NULL
      THEN
         FOR i IN prcob.FIRST .. prcob.LAST
         LOOP
            n_rec := n_rec + 1;
            rcob (n_rec).nrecibo := prcob (i).nrecibo;
            rcob (n_rec).fmovini := prcob (i).fmovini;
            rcob (n_rec).fefecto := prcob (i).fefecto;
            rcob (n_rec).fvencim := prcob (i).fvencim;
         END LOOP;
      END IF;

      SELECT *
        INTO reg_seg
        FROM seguros
       WHERE sseguro = psseguro;

      BEGIN
         SELECT pac_monedas.f_moneda_producto (sproduc), cprorra
           INTO vdecimals, v_cprorra
           FROM productos
          WHERE cramo = reg_seg.cramo
            AND cmodali = reg_seg.cmodali
            AND ctipseg = reg_seg.ctipseg
            AND ccolect = reg_seg.ccolect;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 104347;                  -- Producte no trobat a PRODUCTOS
         WHEN OTHERS
         THEN
            RETURN 102705;                    -- Error al llegir de PRODUCTOS
      END;

      -- {Extornamos los recibos cobrados que nos pasan en el parametro rcob}

      --  Marcamos un punto, por si el detalle de recibo no tiene los conceptos 0,2,50,52,21,71
      -- lo tiramos todo hacia atr¿s, pero solo hasta aqu¿. No es un error.
      SAVEPOINT recibos_extorno;

      --         { Si hab¿a recibos cobrados se devolver¿n aquellos que est¿n enteros y se prorratear¿
      -- si se devuelve parcialmente alg¿n recibo.}
      IF rcob.FIRST IS NOT NULL
      THEN
         FOR i IN rcob.FIRST .. rcob.LAST
         LOOP
            -- ini Bug 0022701 - 03/09/2012 - JMF
            SELECT MAX (ctiprec)
              INTO v_retctiprec
              FROM recibos
             WHERE nrecibo = rcob (i).nrecibo;

            -- Los recibos de retorno los tratamos aparte.
            IF v_retctiprec NOT IN (13, 15)
            THEN
               -- fin Bug 0022701 - 03/09/2012 - JMF
               DECLARE
                  -- 0011652 A¿adir tipo certificado cero o no.
                  v_tipocert   VARCHAR2 (20);
               BEGIN
                  -- 0011652 A¿adir tipo certificado cero o no.
                  SELECT MAX (DECODE (esccero, 1, 'CERTIF0', NULL))
                    INTO v_tipocert
                    FROM recibos
                   WHERE nrecibo = rcob (i).nrecibo;

                  --                         {Creamos el recibo de extorno de primas desde la suspension hasta el vto}
                  ffecextini := pfsuspen;
                  -- inicio extorno ser¿ la fecha de suspensi¿n
                  ffecextfin := pfreini;
                                      -- fin extorno ser¿ la fecha de reinicio
                  --
                  --
                  -- 0011652 A¿adir tipo certificado cero o no.
                  nnrecibo := NULL;
                  num_err :=
                     f_insrecibo (psseguro,
                                  pcagente,
                                  f_sysdate,
                                  ffecextini,
                                  ffecextfin,
                                  9,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  nnrecibo,
                                  'R',
                                  NULL,
                                  NULL,
                                  pnmovimi,
                                  f_sysdate,
                                  v_tipocert
                                 );

                  --                                {El error 103108 , es un error controlado se genera el recibo}
                  IF num_err NOT IN (0, 103108)
                  THEN
                     RETURN num_err;
                  END IF;

                  -- Bug 25583 - RSC - 28/01/2013
                  IF     v_tipocert = 'CERTIF0'
                     AND pac_seguros.f_get_escertifcero (NULL, psseguro) = 1
                  THEN
                     UPDATE recibos
                        SET cestaux = 0
                      WHERE nrecibo = nnrecibo;
                  END IF;

                  -- FIn bug 25583

                  --                         {Buscamos el nrecibo que hemos creado}
                  BEGIN
                     SELECT MAX (nrecibo), MAX (cdelega)
                       INTO nnrecibo, ccdelega
                       FROM recibos
                      WHERE sseguro = psseguro AND nmovimi = pnmovimi;
                  END;

                  --                        {evaluamos el estado de impresi¿n}
                  BEGIN
                     SELECT ccobban
                       INTO cccobban
                       FROM seguros
                      WHERE sseguro = psseguro;
                  END;

                  IF cccobban IS NOT NULL
                  THEN
                     cex_pdte_imp :=
                                   NVL (f_parinstalacion_n ('EX_PTE_IMP'), 0);
                  END IF;

                  IF cex_pdte_imp = 0
                  THEN
                     UPDATE recibos
                        SET cestimp = 7
                      WHERE nrecibo = nnrecibo;
                  END IF;

                  --                        {borramos todos los conceptos}
                  DELETE      detrecibos
                        WHERE nrecibo = nnrecibo;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     RETURN 105156;
               END;

               --                         {Miramos si hay que proratear o incoporar}
               IF rcob (i).fefecto < pfsuspen
               THEN
                  --nnfactor := (pfreini - pfsuspen) /(rcob(i).fvencim - rcob(i).fefecto);
                  --BUG 27048 - INICIO - DCT - 14/11/2013
                  IF v_cprorra = 1
                  THEN
                     --1-Pro dias reales (mod 365) (punid = 3 --> en dias)
                     num_err :=
                               f_difdata (pfsuspen, pfreini, 1, 3, vdifdata1);

                     IF num_err <> 0
                     THEN
                        RETURN num_err;
                     END IF;

                     num_err :=
                        f_difdata (rcob (i).fefecto,
                                   rcob (i).fvencim,
                                   1,
                                   3,
                                   vdifdata2
                                  );

                     IF num_err <> 0
                     THEN
                        RETURN num_err;
                     END IF;

                     nnfactor := vdifdata1 / vdifdata2;
                  ELSIF v_cprorra = 2
                  THEN
                     --2-Por dias Actuariales (mod 360)
                     num_err :=
                               f_difdata (pfsuspen, pfreini, 3, 3, vdifdata1);

                     IF num_err <> 0
                     THEN
                        RETURN num_err;
                     END IF;

                     num_err :=
                        f_difdata (rcob (i).fefecto,
                                   rcob (i).fvencim,
                                   3,
                                   3,
                                   vdifdata2
                                  );

                     IF num_err <> 0
                     THEN
                        RETURN num_err;
                     END IF;

                     nnfactor := vdifdata1 / vdifdata2;
                  END IF;
               ELSE
                  nnfactor := 1;
               END IF;

               --                  {recuperamos y grabamos los conceptos de los recibos a extornar}
               FOR c IN rec_ext (rcob (i).nrecibo)
               LOOP
                  -- Bug 19557 - APD - 31/10/2011 -  funcion para determinar si se debe
                  -- realizar o no el retorno de un recibo a extornar

                  -- BUG 0020414 - 05/12/2011 - JMF: a¿adir factor
                  v_nfactor := nnfactor;
                  num_err :=
                     pac_anulacion.f_concep_retorna_anul (psseguro,
                                                          pnmovimi,
                                                          reg_seg.sproduc,
                                                          c.cconcep,
                                                          pfsuspen,
                                                          -- BUG 19557 - 22/11/2011 - JMP - LCOL_T001-Despeses expedici¿
                                                          v_nfactor
                                                         );

                  --                                                                              {El error 1 , es un error controlado}
                  IF num_err NOT IN (0, 1)
                  THEN
                     RETURN num_err;
                  END IF;

                  -- Bug 19557 - APD - 28/10/2011 - se a¿ade la condicion IF
                  -- si el error 0, se debe insertar en detrecibos (si se debe realizar el extorno)
                  -- si el error 1, NO se debe insetar en detrecibos (NO se retorna el recibo)
                  IF num_err = 0
                  THEN
                     BEGIN
                        INSERT INTO detrecibos
                                    (nrecibo, cconcep, cgarant,
                                     nriesgo,
                                     iconcep
                                    )
                             VALUES (nnrecibo, c.cconcep, c.cgarant,
                                     c.nriesgo,
                                     f_round (c.iconcep * v_nfactor, pcmoneda)
                                    );
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX
                        THEN
                           BEGIN
                              UPDATE detrecibos
                                 SET iconcep =
                                          iconcep
                                        + f_round (c.iconcep * v_nfactor,
                                                   pcmoneda
                                                  )
                               WHERE nrecibo = nnrecibo
                                 AND cconcep = c.cconcep
                                 AND cgarant = c.cgarant
                                 AND nriesgo = c.nriesgo;
                           EXCEPTION
                              WHEN OTHERS
                              THEN
                                 RETURN 104377;
                           --{ error al modificar recibos}
                           END;
                        WHEN OTHERS
                        THEN
                           RETURN 103513; --{error al insertar en detrecibos}
                     END;
                  -- fin Bug 22826 - APD - 11/07/2012
                  END IF;
               -- fin Bug 19557 - APD - 28/10/2011 - se a¿ade la condicion IF
               END LOOP;
            END IF;
         -- fin Bug 0022701 - 03/09/2012 - JMF
         END LOOP;
      END IF;

      IF nnrecibo IS NOT NULL
      THEN                               -- bug 19451/92191 - 13/09/2011 - AMC
         --                                     {Calculamos el consorcio}
         num_err := f_consoranul (psseguro, pfsuspen, nnrecibo, pcmoneda);

         IF num_err <> 0
         THEN
            RETURN num_err;
         END IF;

         --             {Miramos si el recibo no tiene importe}
         SELECT COUNT (DECODE (cconcep, 0, 'a', 50, 'a', NULL)),
                --{num. registros prima neta}
                COUNT (DECODE (cconcep, 2, 'a', 52, 'a', NULL)),
                --{num. registros consoricio}
                COUNT (DECODE (cconcep, 21, 'a', 71, 'a', NULL))
           --{num. registros prima devengada}
         INTO   nnpneta,
                nnpconsor,
                nnpdeven
           FROM detrecibos
          WHERE nrecibo = nnrecibo AND cconcep IN (0, 50, 2, 52, 21, 71);

         --               {si el recibo no tiene los conceptos tiramos hacia atras, hasta el savepoint}
         IF nnpneta = 0 AND nnpconsor = 0 AND nnpdeven = 0
         THEN
            ROLLBACK TO recibos_extorno;
         ELSE
            --            {grabamos una venta igual a la prima que extornamos}
            INSERT INTO detrecibos
                        (nrecibo, cgarant, nriesgo, iconcep, cconcep)
               (SELECT nrecibo, cgarant, nriesgo, iconcep,
                       DECODE (cconcep,
                               0, 21,
                               11, 15,
                               12, 16,
                               50, 71,
                               61, 65,
                               62, 66,
                               NULL
                              ) cconcep
                  FROM detrecibos
                 WHERE cconcep IN (0, 50, 11, 61, 12, 62)
                   AND nrecibo = nnrecibo);

            --                {Borramos las garant¿as que no generan venta}
            FOR g IN gar_venta (nnrecibo)
            LOOP
               num_err :=
                  f_pargaranpro (g.cramo,
                                 g.cmodali,
                                 g.ctipseg,
                                 g.ccolect,
                                 g.cactivi,
                                 g.cgarant,
                                 'GENVENTA',
                                 ccvalpar
                                );

               IF num_err <> 0
               THEN
                  RETURN num_err;
               END IF;

               IF NVL (ccvalpar, 1) = 0
               THEN
                  --                { La garantia no genera venta eliminamos los conceptos para esta garant¿a}
                  DELETE FROM detrecibos
                        WHERE nrecibo = nnrecibo
                          AND cgarant = g.cgarant
                          AND cconcep IN (21, 71, 15, 16, 65, 66);
               END IF;
            END LOOP;

            --                     { restauramos los totales del recibo}
            -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
            DELETE FROM vdetrecibos_monpol
                  WHERE nrecibo = nnrecibo;

            -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
            DELETE      vdetrecibos
                  WHERE nrecibo = nnrecibo;

            num_err := f_vdetrecibos ('R', nnrecibo);

            -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186) - Inici
            -- IF num_err <> 0 THEN
            --    RETURN num_err;
            -- END IF;
            IF num_err = 0
            THEN
               SELECT fefecto, fvencim
                 INTO vfefecto, vfvencim
                 FROM recibos
                WHERE nrecibo = nnrecibo;

               num_err :=
                  pac_cesionesrea.f_cessio_det (v_sproces,
                                                psseguro,
                                                nnrecibo,
                                                reg_seg.cactivi,
                                                reg_seg.cramo,
                                                reg_seg.cmodali,
                                                reg_seg.ctipseg,
                                                reg_seg.ccolect,
                                                vfefecto,
                                                vfvencim,
                                                1,
                                                vdecimals
                                               );
            ELSE
               RETURN num_err;
            END IF;

            -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186) - Fi
            num_err :=
               f_prima_minima_extorn (psseguro,
                                      nnrecibo,
                                      2,
                                      NULL,
                                      NULL,
                                      7,
                                      pcagente,
                                      ffecextini
                                     );

            IF num_err <> 0
            THEN
               RETURN num_err;
            END IF;
         END IF;

         -- ini Bug 0022701 - 03/09/2012 - JMF
         IF pac_retorno.f_tiene_retorno (NULL, psseguro, NULL) = 1
         THEN
            num_err :=
               pac_retorno.f_generar_retorno (psseguro, NULL, nnrecibo, NULL);

            IF num_err <> 0
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'pac_suspension.f_extorn_rec_unic_anual',
                            1313,
                               'psseguro:'
                            || psseguro
                            || ' pnmovimi:'
                            || pnmovimi
                            || ' num_err='
                            || num_err,
                            SQLCODE || ' ' || SQLERRM
                           );
               RETURN num_err;
            END IF;
         END IF;
      -- fin Bug 0022701 - 03/09/2012 - JMF

      --Se a¿ade la llamada a los procesos de envio a ERP en el extrono de prima devengada, de momento
         --no se env¿an estos recibos a la ERP, pero se deja preparado.
         --Bug.: 20923 - 14/01/2012 - ICV
         /*IF NVL(pac_parametros.f_parempresa_n(reg_seg.cempres, 'GESTIONA_COBPAG'), 0) = 1
            AND num_err = 0 THEN
            num_err := pac_ctrl_env_recibos.f_proc_recpag_mov(reg_seg.cempres, psseguro,
                                                              pnmovimi, 4, NULL);
         --Si ha dado error retornamos el error
         --De momento no retornamos el error
         END IF;*/
      --Fi Bug.: 20923
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_suspension.f_extorn_rec_unic_anual',
                      1,
                         'psseguro:'
                      || psseguro
                      || ' pcagente:'
                      || pcagente
                      || ' pnmovimi:'
                      || pnmovimi
                      || ' pcmoneda:'
                      || pcmoneda
                      || ' pfsuspen:'
                      || pfsuspen
                      || ' pfreini:'
                      || pfreini
                      || ' rcob:'
                      || f_recibostochar (rcob),
                      SQLERRM
                     );
         RETURN 140999;                                 --{Error no controlat}
   END f_extorn_rec_unic_anual;

   -- funcion para crear recibos a partir de los recibos pdtes con vigencia en el momento de la suspension y ke luego se anulan
   FUNCTION f_gen_rec_partir_pdte (
      psseguro   IN   NUMBER,
      pcagente   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pfsuspen   IN   DATE,
      pcmoneda   IN   NUMBER,
      prpend     IN   pac_anulacion.recibos_pend,
      pmodo      IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      ffecextini     DATE;
      ffecextfin     DATE;
      num_err        NUMBER;
      nnrecibo       NUMBER;
      nnfactor       NUMBER;
      cccobban       NUMBER;
      ccdelega       NUMBER;
      cex_pdte_imp   NUMBER;
      nnpneta        NUMBER;
      nnpconsor      NUMBER;
      nnpdeven       NUMBER;
      ccvalpar       NUMBER;
      vfefecto       DATE;
      -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186)
      vfvencim       DATE;
      -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186)
      vdecimals      NUMBER;
      -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186)
      v_cmodcom      comisionprod.cmodcom%TYPE;

      CURSOR rec_ext (pnrecibo IN NUMBER)
      IS
         SELECT r.nrecibo, d.cconcep, d.cgarant, NVL (d.nriesgo, 1) nriesgo,
                DECODE (ctiprec, 9, -d.iconcep, d.iconcep) iconcep
           FROM detrecibos d, recibos r, seguros s
          WHERE d.nrecibo = r.nrecibo
            AND d.cconcep NOT IN (21, 71, 15, 16, 65, 66, 2, 52)
            AND r.sseguro = s.sseguro
            AND r.nrecibo = pnrecibo;

      v_sproces      NUMBER                      := 1;
      lsproces       NUMBER;
      ximporx        NUMBER;
      reg_seg        seguros%ROWTYPE;
      v_nfactor      NUMBER;
      v_retctiprec   recibos.ctiprec%TYPE;
      rpend          pac_anulacion.recibos_pend;
      n_rec          NUMBER;
      vcont          NUMBER;
      rpend_unif     pac_anulacion.recibos_pend;
      n_rec_unif     NUMBER;
      v_sseguro      seguros.sseguro%TYPE;
      v_nmovimi      movseguro.nmovimi%TYPE;
      v_cagente      seguros.cagente%TYPE;
      v_fefecto      recibos.fefecto%TYPE;
      v_fvencim      recibos.fvencim%TYPE;
      v_fmovini      movrecibo.fmovini%TYPE;
      v_cprorra      productos.cprorra%TYPE;
      num_err1       NUMBER;
      num_err2       NUMBER;
      dias1          NUMBER;
      dias2          NUMBER;
      v_nrec         NUMBER;
      ssmovrec       NUMBER;
   BEGIN
      rpend.DELETE;
      n_rec := 0;

      IF prpend.FIRST IS NOT NULL
      THEN
         FOR i IN prpend.FIRST .. prpend.LAST
         LOOP
            SELECT COUNT (1)
              INTO vcont
              FROM adm_recunif a
             WHERE nrecunif = prpend (i).nrecibo
               AND nrecibo != prpend (i).nrecibo;

            -- el recibo no es unificado
            --IF vcont = 0 THEN
            n_rec := n_rec + 1;
            rpend (n_rec).nrecibo := prpend (i).nrecibo;
            rpend (n_rec).fmovini := prpend (i).fmovini;
            rpend (n_rec).fefecto := prpend (i).fefecto;
            rpend (n_rec).fvencim := prpend (i).fvencim;
         END LOOP;
      END IF;

      -- fin Bug 23817 - APD - 02/10/2012
      SELECT *
        INTO reg_seg
        FROM seguros
       WHERE sseguro = psseguro;

      -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186) - Inici
      BEGIN
         SELECT pac_monedas.f_moneda_producto (sproduc), cprorra
           INTO vdecimals, v_cprorra
           FROM productos
          WHERE cramo = reg_seg.cramo
            AND cmodali = reg_seg.cmodali
            AND ctipseg = reg_seg.ctipseg
            AND ccolect = reg_seg.ccolect;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 104347;                  -- Producte no trobat a PRODUCTOS
         WHEN OTHERS
         THEN
            RETURN 102705;                    -- Error al llegir de PRODUCTOS
      END;

      /*
                {
        Marcamos un punto, por si el detalle de recibo no tiene los conceptos 0,2,50,52,21,71
       lo tiramos todo hacia atr¿s, pero solo hasta aqu¿. No es un error.
       }
      */
      SAVEPOINT recibos_pdtes;

      IF rpend.FIRST IS NOT NULL
      THEN
         FOR i IN rpend.FIRST .. rpend.LAST
         LOOP
            -- ini Bug 0022701 - 03/09/2012 - JMF
            SELECT MAX (ctiprec)
              INTO v_retctiprec
              FROM recibos
             WHERE nrecibo = rpend (i).nrecibo;

            -- Los recibos de retorno los tratamos aparte.
            IF v_retctiprec NOT IN (13, 15)
            THEN
               -- fin Bug 0022701 - 03/09/2012 - JMF
               IF rpend (i).fefecto < pfsuspen
               THEN                           -- BUG 25583 - FAL - 07/02/2013
                  DECLARE
                     -- 0011652 A¿adir tipo certificado cero o no.
                     v_tipocert   VARCHAR2 (20);
                  BEGIN
                     -- 0011652 A¿adir tipo certificado cero o no.
                     SELECT MAX (DECODE (esccero, 1, 'CERTIF0', NULL))
                       INTO v_tipocert
                       FROM recibos
                      WHERE nrecibo = rpend (i).nrecibo;

                     IF pmodo IS NULL
                     THEN
                        ffecextini := rpend (i).fefecto;
                        -- inicio del recibo a crear = el efecto del pdte y suspendido
                        ffecextfin := pfsuspen;
                     -- fin del recibo a crear = fecha de la suspension
                     ELSE
                        ffecextini := pfsuspen;
                        -- inicio del recibo a crear = fecha de la suspension
                        ffecextfin := rpend (i).fvencim;
                     -- fin del recibo a crear = el vencimiento del pdte y suspendido
                     END IF;

                     --                         {Creamos el recibo de extorno de primas}
                     -- 0011652 A¿adir tipo certificado cero o no.
                     nnrecibo := NULL;

                     IF pmodo IS NULL
                     THEN
                        num_err :=
                           f_insrecibo (psseguro,
                                        pcagente,
                                        f_sysdate,
                                        ffecextini,
                                        ffecextfin,
                                        1,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        nnrecibo,
                                        'R',
                                        NULL,
                                        NULL,
                                        pnmovimi,
                                        f_sysdate,
                                        v_tipocert
                                       );
                     ELSE
                        num_err :=
                           f_insrecibo (psseguro,
                                        pcagente,
                                        f_sysdate,
                                        ffecextini,
                                        ffecextfin,
                                        9,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        nnrecibo,
                                        'R',
                                        NULL,
                                        NULL,
                                        pnmovimi,
                                        f_sysdate,
                                        v_tipocert
                                       );
                     END IF;

                     --                                {El error 103108 , es un error controlado se genera el recibo}
                     IF num_err NOT IN (0, 103108)
                     THEN
                        RETURN num_err;
                     END IF;

                     -- Bug 25583 - RSC - 28/01/2013
                     IF     v_tipocert = 'CERTIF0'
                        AND pac_seguros.f_get_escertifcero (NULL, psseguro) =
                                                                             1
                     THEN
                        UPDATE recibos
                           SET cestaux = 0
                         WHERE nrecibo = nnrecibo;
                     END IF;

                     -- FIn bug 25583

                     --                         {Buscamos el nrecibo que hemos creado}
                     BEGIN
                        SELECT MAX (nrecibo), MAX (cdelega)
                          INTO nnrecibo, ccdelega
                          FROM recibos
                         WHERE sseguro = psseguro AND nmovimi = pnmovimi;
                     END;

                     --                        {evaluamos el estado de impresi¿n}
                     BEGIN
                        SELECT ccobban
                          INTO cccobban
                          FROM seguros
                         WHERE sseguro = psseguro;
                     END;

                     IF cccobban IS NOT NULL
                     THEN
                        cex_pdte_imp :=
                                   NVL (f_parinstalacion_n ('EX_PTE_IMP'), 0);
                     END IF;

                     IF cex_pdte_imp = 0
                     THEN
                        UPDATE recibos
                           SET cestimp = 7
                         WHERE nrecibo = nnrecibo;
                     END IF;

                     --                        {borramos todos los conceptos}
                     DELETE      detrecibos
                           WHERE nrecibo = nnrecibo;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        RETURN 105156;
                  END;

                  --                         {Miramos si hay que proratear o incoporar}
                  IF NVL (f_parproductos_v (reg_seg.sproduc,
                                            'NO_PRORRATEO_SUPLEM'
                                           ),
                          0
                         ) = 1
                  THEN
                     nnfactor := 1;
                  ELSE
                     IF rpend (i).fefecto < pfsuspen
                     THEN
                        IF v_cprorra = 1
                        THEN
                           --BUG27048 - INICIO - DCT - 12/11/2013
                           --12/11/2013 num_err1 := f_difdata(pfsuspen, rpend(i).fvencim, 3, 3, dias1);
                           num_err1 :=
                              f_difdata (rpend (i).fefecto,
                                         pfsuspen,
                                         1,
                                         3,
                                         dias1
                                        );

                           --BUG27048 - FIN - DCT - 12/11/2013
                           IF num_err1 <> 0
                           THEN
                              p_tab_error
                                     (f_sysdate,
                                      f_user,
                                      'pac_suspension.f_gen_rec_partir_pdte',
                                      1000,
                                      'dias1:' || dias1,
                                      num_err1
                                     );
                              RETURN num_err1;
                           END IF;

                           num_err2 :=
                              f_difdata (rpend (i).fefecto,
                                         rpend (i).fvencim,
                                         1,
                                         3,
                                         dias2
                                        );

                           IF num_err2 <> 0
                           THEN
                              p_tab_error
                                     (f_sysdate,
                                      f_user,
                                      'pac_suspension.f_gen_rec_partir_pdte',
                                      1001,
                                      'dias2:' || dias2,
                                      num_err2
                                     );
                              RETURN num_err2;
                           END IF;

                           nnfactor := dias1 / dias2;
                        ELSIF v_cprorra = 2
                        THEN
                           --BUG27048 - INICIO - DCT - 12/11/2013
                           --12/11/2013 num_err1 := f_difdata(pfsuspen, rpend(i).fvencim, 3, 3, dias1);
                           num_err1 :=
                              f_difdata (rpend (i).fefecto,
                                         pfsuspen,
                                         3,
                                         3,
                                         dias1
                                        );

                           --BUG27048 - FIN - DCT - 12/11/2013
                           IF num_err1 <> 0
                           THEN
                              p_tab_error
                                     (f_sysdate,
                                      f_user,
                                      'pac_suspension.f_gen_rec_partir_pdte',
                                      1000,
                                      'dias1:' || dias1,
                                      num_err1
                                     );
                              RETURN num_err1;
                           END IF;

                           num_err2 :=
                              f_difdata (rpend (i).fefecto,
                                         rpend (i).fvencim,
                                         3,
                                         3,
                                         dias2
                                        );

                           IF num_err2 <> 0
                           THEN
                              p_tab_error
                                     (f_sysdate,
                                      f_user,
                                      'pac_suspension.f_gen_rec_partir_pdte',
                                      1001,
                                      'dias2:' || dias2,
                                      num_err2
                                     );
                              RETURN num_err2;
                           END IF;

                           nnfactor := dias1 / dias2;
                        ELSE
                           IF pmodo IS NULL
                           THEN
                              nnfactor :=
                                   (pfsuspen - rpend (i).fefecto)
                                 / (rpend (i).fvencim - rpend (i).fefecto);
                           ELSE
                              nnfactor :=
                                   (rpend (i).fefecto - pfsuspen)
                                 / (rpend (i).fvencim - rpend (i).fefecto);
                           END IF;
                        END IF;
                     ELSE
                        nnfactor := 1;
                     END IF;
                  END IF;

                  IF pmodo IS NULL
                  THEN
                     v_nfactor := nnfactor;
                  ELSE
                     v_nfactor := 1 - nnfactor;
                  END IF;

                  --  {recuperamos y grabamos los conceptos de los recibos a extornar}
                  FOR c IN rec_ext (rpend (i).nrecibo)
                  LOOP
                     --BUG27048 - INICIO - DCT - 12/11/2013  --Los Gastos de Expedici¿n no se extornan.
                     IF c.cconcep <> 14
                     THEN
                        BEGIN
                           INSERT INTO detrecibos
                                       (nrecibo, cconcep, cgarant,
                                        nriesgo,
                                        iconcep
                                       )
                                VALUES (nnrecibo, c.cconcep, c.cgarant,
                                        c.nriesgo,
                                        f_round (c.iconcep * v_nfactor,
                                                 pcmoneda
                                                )
                                       );
                        EXCEPTION
                           WHEN DUP_VAL_ON_INDEX
                           THEN
                              BEGIN
                                 UPDATE detrecibos
                                    SET iconcep =
                                             iconcep
                                           + f_round (c.iconcep * v_nfactor,
                                                      pcmoneda
                                                     )
                                  WHERE nrecibo = nnrecibo
                                    AND cconcep = c.cconcep
                                    AND cgarant = c.cgarant
                                    AND nriesgo = c.nriesgo;
                              EXCEPTION
                                 WHEN OTHERS
                                 THEN
                                    RETURN 104377;
                              --{ error al modificar recibos}
                              END;
                           WHEN OTHERS
                           THEN
                              RETURN 103513;
                        --{error al insertar en detrecibos}
                        END;
                     END IF;
                  --BUG27048 - INICIO - DCT - 12/11/2013  --Los Gastos de Expedici¿n no se extornan.
                  END LOOP;
               /*IF NVL(pac_parametros.f_parempresa_n(reg_seg.cempres, 'GESTIONA_COBPAG'), 0) =
                                                                                           1 THEN
                  num_err := pac_ctrl_env_recibos.f_proc_recpag_mov(reg_seg.cempres,
                                                                    psseguro, pnmovimi, 4,
                                                                    lsproces);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END IF;*/
               ELSE
                  SELECT smovagr.NEXTVAL
                    INTO ssmovrec
                    FROM DUAL;

                  num_err :=
                     pac_adm.f_clonrecibo (1,
                                           rpend (i).nrecibo,
                                           v_nrec,
                                           ssmovrec,
                                           NULL,
                                           2
                                          );

                  IF pmodo IS NULL
                  THEN
                     UPDATE recibos r
                        SET nmovimi = pnmovimi,
                            femisio = f_sysdate,
                            ctiprec = 1
                      WHERE nrecibo = v_nrec;
                  ELSE
                     UPDATE recibos r
                        SET nmovimi = pnmovimi,
                            femisio = f_sysdate,
                            ctiprec = 9
                      WHERE nrecibo = v_nrec;
                  END IF;
               END IF;
            END IF;                            -- BUG 25583 - FAL - 07/02/2013
         END LOOP;
      END IF;

      IF nnrecibo IS NOT NULL
      THEN                               -- bug 19451/92191 - 13/09/2011 - AMC
         --                      {Miramos si el recibo no tiene importe}
         SELECT COUNT (DECODE (cconcep, 0, 'a', 50, 'a', NULL)),
                --{num. registros prima neta}
                COUNT (DECODE (cconcep, 2, 'a', 52, 'a', NULL)),
                --{num. registros consoricio}
                COUNT (DECODE (cconcep, 21, 'a', 71, 'a', NULL))
           --{num. registros prima devengada}
         INTO   nnpneta,
                nnpconsor,
                nnpdeven
           FROM detrecibos
          WHERE nrecibo = nnrecibo AND cconcep IN (0, 50, 2, 52, 21, 71);

         --               {si el recibo no tiene los conceptos tiramos hacia atras, hasta el savepoint}
         IF nnpneta = 0 AND nnpconsor = 0 AND nnpdeven = 0
         THEN
            ROLLBACK TO recibos_pdtes;
         ELSE
            --            {grabamos una venta igual a la prima que extornamos}
            --                     { restauramos los totales del recibo}
            -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
            DELETE FROM vdetrecibos_monpol
                  WHERE nrecibo = nnrecibo;

            -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
            DELETE      vdetrecibos
                  WHERE nrecibo = nnrecibo;

            num_err := f_vdetrecibos ('R', nnrecibo);

            -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186) - Inici
            -- IF num_err <> 0 THEN
            --    RETURN num_err;
            -- END IF;
            IF num_err = 0
            THEN
               SELECT fefecto, fvencim
                 INTO vfefecto, vfvencim
                 FROM recibos
                WHERE nrecibo = nnrecibo;

               num_err :=
                  pac_cesionesrea.f_cessio_det (v_sproces,
                                                psseguro,
                                                nnrecibo,
                                                reg_seg.cactivi,
                                                reg_seg.cramo,
                                                reg_seg.cmodali,
                                                reg_seg.ctipseg,
                                                reg_seg.ccolect,
                                                vfefecto,
                                                vfvencim,
                                                1,
                                                vdecimals
                                               );
            ELSE
               RETURN num_err;
            END IF;
         END IF;

         -- ini Bug 0022701 - 03/09/2012 - JMF
         IF pac_retorno.f_tiene_retorno (NULL, psseguro, NULL) = 1
         THEN
            num_err :=
               pac_retorno.f_generar_retorno (psseguro, NULL, nnrecibo, NULL);

            IF num_err <> 0
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'pac_suspensionseg.f_gen_rec_partir_pdte',
                            1313,
                               'psseguro:'
                            || psseguro
                            || ' pnmovimi:'
                            || pnmovimi
                            || ' num_err='
                            || num_err,
                            SQLCODE || ' ' || SQLERRM
                           );
               RETURN num_err;
            END IF;
         END IF;
      /*IF NVL(pac_parametros.f_parempresa_n(reg_seg.cempres, 'GESTIONA_COBPAG'), 0) = 1
         AND num_err = 0 THEN
         num_err := pac_ctrl_env_recibos.f_proc_recpag_mov(reg_seg.cempres, psseguro,
                                                           pnmovimi, 4, NULL);
         --Si ha dado error retornamos el error
         p_tab_error(f_sysdate, f_user, 'pac_suspensionseg.f_gen_rec_partir_pdte', 1315,
                     'psseguro:' || psseguro || ' pnmovimi:' || pnmovimi || ' num_err='
                     || num_err,
                     SQLCODE || ' ' || SQLERRM);
         RETURN num_err;
      END IF;*/
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_suspension.f_gen_rec_partir_pdte',
                      1,
                         'psseguro:'
                      || psseguro
                      || ' pcagente:'
                      || pcagente
                      || ' pnmovimi:'
                      || pnmovimi
                      || ' pcmoneda:'
                      || pcmoneda
                      || ' pfsuspen:'
                      || pfsuspen,
--                     || ' rcob:' || f_recibostochar(rpend),
                      SQLERRM
                     );
         RETURN 140999;                                 --{Error no controlat}
   END f_gen_rec_partir_pdte;

   /*************************************************************************
      Funcion que realiza la insercion de los movimientos suspensi¿n/reinicio de polizas
      param in psseguro : id. de la poliza
      param in pcmotmov : codigo motivo movimiento
      param in pfmovini : fecha inicio movimiento
      param in pfrenova : fecha nueva vigencia
      param in pttexto  : descripcion del movimiento de suspensi¿n/reinicio
      param in pttexto2 : descripcion del movimiento de debloqueo/despignoarcion
      param in ptratarec default:  0- Suspende y No Trata Recibos, 1- Suspende y Trata Recibos y 2-No Suspende y Trata Recibos
      param in pnrecibo  default: NULL
      return            : Error
   *************************************************************************/
   FUNCTION f_set_mov (
      psseguro    IN   NUMBER,
      pcmotmov    IN   NUMBER,
      pfmovini    IN   DATE,
      pfrenova    IN   DATE,
      pttexto     IN   VARCHAR2,
      pttexto2    IN   VARCHAR2,
      ptratarec   IN   NUMBER DEFAULT 1,
      pnrecibo    IN   NUMBER DEFAULT NULL,
      pnmovimi    IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      num_err                   NUMBER;
      v_validamov               NUMBER                       := 0;
      v_suplemento              movseguro.nsuplem%TYPE;
      v_siguiente_mov           movseguro.nmovimi%TYPE;
      v_motmovdes               NUMBER;
      v_nriesgo                 riesgos.nriesgo%TYPE;
      v_cmotmov                 suspensionseg.cmotmov%TYPE;
      v_nmovimi                 suspensionseg.nmovimi%TYPE;
      v_motaux                  NUMBER;
      v_ttexto                  VARCHAR2 (1000);
      v_ffinalaux               suspensionseg.finicio%TYPE;
      v_desnmovimi              suspensionseg.nmovimi%TYPE;
      v_situac_ant              VARCHAR2 (1000);
      v_situac_act              VARCHAR2 (1000);
      v_maxlenght               NUMBER                       := 1000;
      v_existe_recibo_cobrado   BOOLEAN                      := FALSE;
      pxnrecibo                 NUMBER;

      CURSOR c_rec_cob (psseguro IN NUMBER, pfmovini IN DATE)
      IS
         SELECT   r.nrecibo, r.cforpag, r.fefecto, r.fvencim, m.fmovini,
                  ROWNUM - 1 contad
             FROM movrecibo m, recibos r, vdetrecibos v, seguros s
            WHERE m.nrecibo = r.nrecibo
              AND m.nrecibo = v.nrecibo
              AND s.sseguro = r.sseguro
              AND m.fmovfin IS NULL
              AND m.cestrec = 1
              AND r.sseguro = psseguro
              AND r.nrecibo = NVL (pnrecibo, r.nrecibo)
                                        --BUG29229 - INICIO - DCT - 02/12/2013
              --AND r.fefecto <= pfmovini  -- Bug 27539 - 08/07/2013 - RSC
              AND r.fvencim >= pfmovini
              -- Ini Bug 26488 -- ECP -- 30/04/2013
              --AND 1 = f_cestrec(r.nrecibo, pfmovini)
              -- Fin Bug 26488 -- ECP -- 30/04/2013
              --BUG29229 - INICIO - DCT - 02/12/2013
              AND (   (    NVL (f_parproductos_v (s.sproduc,
                                                  'ADMITE_CERTIFICADOS'
                                                 ),
                                0
                               ) = 1
                       AND s.ncertif = 0
                       AND r.nrecibo NOT IN (SELECT nrecibo
                                               FROM adm_recunif)
                      )
                   OR (    NVL (f_parproductos_v (s.sproduc,
                                                  'ADMITE_CERTIFICADOS'
                                                 ),
                                0
                               ) = 1
                       AND s.ncertif <> 0
                      )
                   OR (NVL (f_parproductos_v (s.sproduc,
                                              'ADMITE_CERTIFICADOS'),
                            0
                           ) = 0
                      )
                   OR (    NVL (f_parproductos_v (s.sproduc,
                                                  'ADMITE_CERTIFICADOS'
                                                 ),
                                0
                               ) = 1
                       AND s.ncertif = 0
                       AND pnrecibo IS NOT NULL
                      )
                  )
         --BUG29229 - FIN - DCT - 02/12/2013
         ORDER BY contad;

      CURSOR c_rec_pend (psseguro IN NUMBER, pfmovini IN DATE)
      IS
         SELECT   r.nrecibo, r.cforpag, r.fefecto, r.fvencim, r.cagente,
                  m.fmovini, r.cempres, r.cdelega, ROWNUM - 1 contad
             FROM movrecibo m, recibos r, vdetrecibos v, seguros s
            WHERE m.nrecibo = r.nrecibo
              AND m.nrecibo = v.nrecibo
              AND s.sseguro = r.sseguro
              AND m.fmovfin IS NULL
              AND m.cestrec = 0
              AND r.sseguro = psseguro
              AND r.nrecibo = NVL (pnrecibo, r.nrecibo)
                                        --BUG29229 - INICIO - DCT - 02/12/2013
              --AND fefecto <= pfmovini  -- Bug 27539 - 08/07/2013 - RSC
              -- AND r.fvencim >= pfmovini
              AND r.fvencim > pfmovini         -- BUG 25583 - FAL - 07/02/2013
              --BUG29229 - INICIO - DCT - 02/12/2013
              AND (   (    NVL (f_parproductos_v (s.sproduc,
                                                  'ADMITE_CERTIFICADOS'
                                                 ),
                                0
                               ) = 1
                       AND s.ncertif = 0
                       AND r.nrecibo NOT IN (SELECT nrecibo
                                               FROM adm_recunif)
                      )
                   OR (    NVL (f_parproductos_v (s.sproduc,
                                                  'ADMITE_CERTIFICADOS'
                                                 ),
                                0
                               ) = 1
                       AND s.ncertif <> 0
                      )
                   OR (NVL (f_parproductos_v (s.sproduc,
                                              'ADMITE_CERTIFICADOS'),
                            0
                           ) = 0
                      )
                  )
         --BUG29229 - FIN - DCT - 02/12/2013
         ORDER BY contad;

      -- cursor de recibos unicos o anuales para extornar en el supl. de reinicio
      --El recibo para extornar debe estar cobrado
      CURSOR c_rec_unic_anual (
         psseguro   IN   NUMBER,
         pfsuspen   IN   DATE,
         pfreini    IN   DATE
      )
      IS
         SELECT   r.nrecibo, r.cforpag, r.fefecto, r.fvencim, r.cagente,
                  m.fmovini, r.cempres, r.cdelega, ROWNUM - 1 contad
             FROM movrecibo m, recibos r, vdetrecibos v, seguros s
            WHERE m.nrecibo = r.nrecibo
              AND m.nrecibo = v.nrecibo
              AND s.sseguro = r.sseguro
              AND m.fmovfin IS NULL
              AND r.sseguro = psseguro
              AND r.nrecibo = NVL (pnrecibo, r.nrecibo)
              --BUG29229 - INICIO - DCT - 02/12/2013
              AND r.fefecto <= pfreini
              AND (   (r.fvencim >= pfreini)
                   OR (r.fvencim <= pfreini AND r.fvencim >= pfsuspen)
                  )
              AND r.cforpag IN (1, 0)
              AND m.cestrec = 1
              --BUG29229 - INICIO - DCT - 02/12/2013
              AND (   (    NVL (f_parproductos_v (s.sproduc,
                                                  'ADMITE_CERTIFICADOS'
                                                 ),
                                0
                               ) = 1
                       AND s.ncertif = 0
                       AND r.nrecibo NOT IN (SELECT nrecibo
                                               FROM adm_recunif)
                      )
                   OR (    NVL (f_parproductos_v (s.sproduc,
                                                  'ADMITE_CERTIFICADOS'
                                                 ),
                                0
                               ) = 1
                       AND s.ncertif <> 0
                      )
                   OR (NVL (f_parproductos_v (s.sproduc,
                                              'ADMITE_CERTIFICADOS'),
                            0
                           ) = 0
                      )
                  )
         --BUG29229 - FIN - DCT - 02/12/2013
         ORDER BY contad;

      v_ctipreb                 seguros.ctipreb%TYPE;
      v_cagente                 seguros.cagente%TYPE;
      v_ccobban                 seguros.ccobban%TYPE;
      v_cempres                 seguros.cempres%TYPE;
      v_frenova                 seguros.frenova%TYPE;
      v_fcaranu                 seguros.fcaranu%TYPE;
      v_csituac                 seguros.csituac%TYPE;
      v_cforpag                 seguros.cforpag%TYPE;
      v_fefecto                 seguros.fefecto%TYPE;
      v_fcarpro                 seguros.fcarpro%TYPE;
      xcmodcom                  NUMBER;
      lfcanua                   DATE;
      lnmovimi                  NUMBER;
      lsproces                  NUMBER;
      ximporx                   NUMBER;
      rpend                     pac_anulacion.recibos_pend;
      wfcarpro                  seguros.fcarpro%TYPE;
      rrcob                     rec_cob;
      w_fsuspen                 DATE;
      rec_unic_anual            rec_cob;
      v_sproduc                 seguros.sproduc%TYPE;
      v_ctipreb_cert            seguros.ctipreb%TYPE;
      v_cagente_cert            seguros.cagente%TYPE;
      v_ccobban_cert            seguros.ccobban%TYPE;
      v_cempres_cert            seguros.cempres%TYPE;
      v_frenova_cert            seguros.frenova%TYPE;
      v_fcaranu_cert            seguros.fcaranu%TYPE;
      v_csituac_cert            seguros.csituac%TYPE;
      v_cforpag_cert            seguros.cforpag%TYPE;
      v_fefecto_cert            seguros.fefecto%TYPE;
      v_fcarpro_cert            seguros.fcarpro%TYPE;
      v_lista                   t_lista_id                   := t_lista_id ();
      v_nrecibo_cert            recibos.nrecibo%TYPE;
      v_siguiente_movcert       movseguro.nmovimi%TYPE;
      v_mens                    VARCHAR2 (2000);
      v_sseguro_est             estseguros.sseguro%TYPE;
      v_finicio                 recibos.fefecto%TYPE;
      v_ffin                    recibos.fvencim%TYPE;
      v_ctiprec                 recibos.ctiprec%TYPE;
      v_cpregun4821             pregunpolseg.cpregun%TYPE    := 4821;
      v_crespue4821             pregunpolseg.crespue%TYPE;
      v_totalr_aux              NUMBER                       := 0;
      v_totalr                  NUMBER                       := 0;
      v_sseguro_0               seguros.sseguro%TYPE;
   BEGIN
      IF pnmovimi IS NOT NULL
      THEN
         v_siguiente_mov := pnmovimi;
      END IF;

      IF ptratarec <> 2
      THEN                                --(ptratarec = 0 y 1 debe suspender)
         -- Se valida si se puede realizar el movimiento de suplemento/reinicio
         v_validamov := f_valida_mov (psseguro, pcmotmov, pfmovini, pfrenova);
      END IF;      --ptratarec <> 2 THEN  --(ptratarec = 0 y 1 debe suspender)

      -- Si se puede realizar el movimiento
      IF v_validamov = 0
      THEN
         IF ptratarec <> 2
         THEN                            --(ptratarec = 0 y 1 debe suspender)
            -- Inicio duplicaci¿n de movimiento
            pac_alctr126.traspaso_tablas_seguros (psseguro, v_mens);

            -- Bug 27539/148894 - APD - 12/07/2013 - se busca sseguro de las
            -- tablas EST que se acaba de generar
            SELECT MAX (sseguro)
              INTO v_sseguro_est
              FROM estseguros
             WHERE ssegpol = psseguro;

            num_err :=
               f_movseguro (psseguro,
                            NULL,
                            pcmotmov,
                            1,
                            pfmovini,
                            NULL,
                            NULL,
                            0,
                            NULL,
                            v_siguiente_mov,
                            f_sysdate,
                            NULL
                           );

            IF num_err <> 0
            THEN
               RETURN num_err;
            END IF;

            -- BUG 0024450 - INICIO - DCT - 26/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS.
            num_err := f_act_hisseg (psseguro, v_siguiente_mov - 1);

            IF num_err <> 0
            THEN
               RETURN num_err;
            END IF;

            -- BUG 0024450 - INICIO - DCT - 26/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS.
            pac_alctr126.traspaso_tablas_est (v_sseguro_est,
                                              pfmovini,
                                              NULL,
                                              v_mens,
                                              'ALCTR126',
                                              NULL,
                                              v_siguiente_mov,
                                              NULL,
                                              1
                                             );
            pac_alctr126.borrar_tablas_est (v_sseguro_est);

            UPDATE garanseg
               SET ffinefe = pfmovini
             WHERE sseguro = psseguro
               AND ffinefe IS NULL
               AND nmovimi =
                      (SELECT MAX (nmovimi)
                         FROM garanseg
                        WHERE sseguro = psseguro
                          AND ffinefe IS NULL
                          AND nmovimi < v_siguiente_mov);

            UPDATE clausuesp
               SET ffinclau = pfmovini
             WHERE sseguro = psseguro
               AND ffinclau IS NULL
               AND nmovimi =
                      (SELECT MAX (nmovimi)
                         FROM clausuesp
                        WHERE sseguro = psseguro
                          AND ffinclau IS NULL
                          AND nmovimi < v_siguiente_mov);

            UPDATE benespseg
               SET ffinben = pfmovini
             WHERE sseguro = psseguro
               AND ffinben IS NULL
               AND nmovimi =
                      (SELECT MAX (nmovimi)
                         FROM benespseg
                        WHERE sseguro = psseguro
                          AND ffinben IS NULL
                          AND nmovimi < v_siguiente_mov);

            -- Fin duplicaci¿n de movimiento

            -- recuperar riesgo de la poliza
            BEGIN
               SELECT nriesgo
                 INTO v_nriesgo
                 FROM riesgos
                WHERE sseguro = psseguro
                  AND fanulac IS NULL
                  AND nriesgo =
                               (SELECT MIN (nriesgo)
                                  FROM riesgos
                                 WHERE sseguro = psseguro AND fanulac IS NULL);
            EXCEPTION
               WHEN OTHERS
               THEN
                  BEGIN
                     SELECT nriesgo
                       INTO v_nriesgo
                       FROM riesgos
                      WHERE sseguro = psseguro
                        AND nriesgo = (SELECT MIN (nriesgo)
                                         FROM riesgos
                                        WHERE sseguro = psseguro);
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        v_nriesgo := 0;
                  END;
            END;

            IF pcmotmov = 391
            THEN                                                 -- suspensi¿n
               v_situac_act :=
                  SUBSTR (   f_axis_literales (9904518,
                                               pac_md_common.f_get_cxtidioma
                                              )
                          || '. ',
                          1,
                          v_maxlenght
                         );
               v_situac_act :=
                  SUBSTR
                     (   v_situac_act
                      || f_axis_literales (9000526,
                                           pac_md_common.f_get_cxtidioma
                                          )
                      || ' ( '
                      || TO_CHAR (TRUNC (pfmovini), 'dd/mm/yyyy')
                      || ' ) ',              -- BUG 0025033 - FAL - 10/12/2012
                      1,
                      v_maxlenght
                     );

               IF pttexto IS NOT NULL
               THEN
                  v_situac_act :=
                     SUBSTR
                          (   v_situac_act
                           || f_axis_literales (100559,
                                                pac_md_common.f_get_cxtidioma
                                               )
                           || ' '
                           || pttexto
                           || '.',
                           1,
                           v_maxlenght
                          );
               END IF;
            ELSIF pcmotmov = pac_suspension.vcod_reinicio  -- CONF-274-25/11/2016-JLTS- Se cambia 392 por la variable vcod_reinicio 141
            THEN                                                   -- reinicio
               v_situac_ant :=
                  SUBSTR (   f_axis_literales (9904519,
                                               pac_md_common.f_get_cxtidioma
                                              )
                          || '. ',
                          1,
                          v_maxlenght
                         );
               v_situac_ant :=
                  SUBSTR
                     (   v_situac_ant
                      || f_axis_literales (9000526,
                                           pac_md_common.f_get_cxtidioma
                                          )
                      || ' ( '
                      || TO_CHAR (TRUNC (pfmovini), 'dd/mm/yyyy')
                      || ' ) ',              -- BUG 0025033 - FAL - 10/12/2012
                      1,
                      v_maxlenght
                     );

               IF pttexto IS NOT NULL
               THEN
                  v_situac_ant :=
                     SUBSTR
                          (   v_situac_ant
                           || f_axis_literales (100559,
                                                pac_md_common.f_get_cxtidioma
                                               )
                           || ' '
                           || pttexto
                           || '.',
                           1,
                           v_maxlenght
                          );
               END IF;
            END IF;
         --BUG29229 - INICIO - DCT - 02/12/2013. De momento lo comentamos
         -- Inserci¿n del detalle del movimiento
        if  NVL(pac_parametros.f_parempresa_n(f_empres, 'VISUALIZA_REI_SUS'), 0) = 1 THEN
         BEGIN
            INSERT INTO detmovseguro
                        (sseguro, nmovimi, cmotmov, nriesgo, cgarant, tvalora,
                         tvalord, cpregun)
                 VALUES (psseguro, v_siguiente_mov, pcmotmov, v_nriesgo, 0, v_situac_ant,
                         v_situac_act, 0);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE detmovseguro
                  SET tvalora = v_situac_ant,
                      tvalord = v_situac_act
                WHERE sseguro = psseguro
                  AND nriesgo = v_nriesgo
                  AND cgarant = 0
                  AND cpregun = 0
                  AND cmotmov = pcmotmov
                  AND nmovimi = v_siguiente_mov;
         END;
          END IF;
         --BUG29229 - FIN - DCT - 02/12/2013. De momento lo comentamos
         END IF;  -- ptratarec <> 2 THEN  --(ptratarec = 0 y 1 debe suspender)

         SELECT ctipreb, cagente, ccobban, cempres, frenova,
                fcaranu, csituac, cforpag, fefecto, fcarpro,
                sproduc
           INTO v_ctipreb, v_cagente, v_ccobban, v_cempres, v_frenova,
                v_fcaranu, v_csituac, v_cforpag, v_fefecto, v_fcarpro,
                v_sproduc
           FROM seguros
          WHERE sseguro = psseguro;

         IF f_es_renovacion (psseguro) = 0
         THEN
            xcmodcom := 2;
         ELSE
            xcmodcom := 1;
         END IF;

         IF pcmotmov = 391
         THEN                                                    -- SUSPENSION
            IF ptratarec <> 2
            THEN                         --(ptratarec = 0 y 1 debe suspender)
               BEGIN
                  INSERT INTO suspensionseg
                              (sseguro, finicio, ffinal, ttexto, cmotmov,
                               nmovimi, fvigencia
                              )
                       VALUES (psseguro, pfmovini, NULL, pttexto, pcmotmov,
                               v_siguiente_mov, NULL
                              );
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX
                  THEN
                     RETURN 9905023;
               END;

               BEGIN
-- si hay reinicio anterior, modificamos su fecha fin con el finicio de la suspension
                  UPDATE suspensionseg
                     SET ffinal = pfmovini
                   WHERE sseguro = psseguro
                     AND cmotmov = pac_suspension.vcod_reinicio  -- CONF-274-25/11/2016-JLTS- Se cambia 392 por la variable vcod_reinicio 141
                     AND nmovimi =
                            (SELECT MAX (nmovimi)
                               FROM suspensionseg
                              WHERE sseguro = psseguro
                                AND cmotmov = pac_suspension.vcod_reinicio -- CONF-274-25/11/2016-JLTS- Se cambia 392 por la variable vcod_reinicio 141
                                AND nmovimi < v_siguiente_mov);
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     NULL;
               END;
            END IF;

            -- ptratarec <> 2 THEN  --(ptratarec = 0 y 1 debe suspender)
            IF v_frenova IS NOT NULL
            THEN
               lfcanua := v_frenova;
            ELSE
               lfcanua := v_fcaranu;
            END IF;

            IF NVL (f_parproductos_v (v_sproduc, 'TRATA_REC_SUSPENSION'), 1) =
                                                                             1
            THEN      --Mantis 34576/0197625 - abre if - BLA - DD04/MM05/2015.
               --BUG29229 - INICIO - DCT - 02/12/2013.
               IF ptratarec IN (1, 2)
               THEN
                  /* Tratamiento de recibos pendientes */
                  FOR rec_pend IN c_rec_pend (psseguro, pfmovini)
                  LOOP
                     -- Bug 25583 - RSC - 28/01/2013
                     --IF rec_pend.cforpag NOT IN(0, 1) THEN   -- fpago unica o anual se trata en el reinicio
                     -- Fin Bug 25583
                     rpend (rec_pend.contad).nrecibo := rec_pend.nrecibo;
                     rpend (rec_pend.contad).fmovini := rec_pend.fmovini;
                     rpend (rec_pend.contad).fefecto := rec_pend.fefecto;
                     rpend (rec_pend.contad).fvencim := rec_pend.fvencim;
                     p_tab_error (f_sysdate,
                                  f_user,
                                  'pac_suspension.f_set_mov',
                                  1,
                                     'psseguro:'
                                  || psseguro
                                  || ' pfmovini:'
                                  || pfmovini
                                  || ' pcmotmov:'
                                  || pcmotmov
                                  || ' pfrenova:'
                                  || pfrenova
                                  || ' ptratarec = '
                                  || ptratarec
                                  || ' v_nriesgo = '
                                  || v_nriesgo,
                                  NULL
                                 );
                     p_tab_error (f_sysdate,
                                  f_user,
                                  'pac_suspension.f_set_mov',
                                  11,
                                     ' rpend(rec_pend.contad).nrecibo = '
                                  || rpend (rec_pend.contad).nrecibo,
                                  NULL
                                 );
                  END LOOP;

                  p_tab_error (f_sysdate,
                               f_user,
                               'pac_suspension.f_set_mov',
                               2,
                                  'psseguro:'
                               || psseguro
                               || ' pfmovini:'
                               || pfmovini
                               || ' pcmotmov:'
                               || pcmotmov
                               || ' pfrenova:'
                               || pfrenova
                               || ' ptratarec = '
                               || ptratarec
                               || ' v_nriesgo = '
                               || v_nriesgo,
                               NULL
                              );

                  IF    NVL (f_parproductos_v (v_sproduc,
                                               'ADMITE_CERTIFICADOS'
                                              ),
                             0
                            ) = 0
                     OR v_cforpag IN (0, 1)
                  THEN
                     -- crea recibos a partir de los pdtes. con vigencia durante la suspensi¿n,
                     -- con fecha inicio = ini. vigencia del recibo suspendido hasta la fecha de la suspensi¿n.
                     num_err :=
                        pac_suspension.f_gen_rec_partir_pdte
                                                            (psseguro,
                                                             v_cagente,
                                                             v_siguiente_mov,
                                                             pfmovini,
                                                             1,
                                                             rpend
                                                            );
                     p_tab_error (f_sysdate,
                                  f_user,
                                  'pac_suspension.f_set_mov',
                                  3,
                                     'num_err  = '
                                  || num_err
                                  || ' v_siguiente_mov = '
                                  || v_siguiente_mov,
                                  NULL
                                 );

                     IF num_err <> 0
                     THEN
                        ROLLBACK;
                        RETURN num_err;
                     END IF;
                  END IF;

                  -- Si es diferente de anual / unica
                  -- Genera la parte de extorno. El recibo agrupado nunca se anula en la suspension.
                  -- Por esta raz¿n siempre es necesario generar el extorno en los certificados.

                  -- Esto es necesario por el agrupado. Al existir un recibo agrupado no se pueden anular recibos pendientes
                  -- ya que implicar¿a reconstruir el recibo agrupado y eso no puede ser. Se debe generar extorno del resto.
                  IF NVL (f_parproductos_v (v_sproduc, 'ADMITE_CERTIFICADOS'),
                          0
                         ) = 1
                  THEN
                     IF v_cforpag NOT IN (0, 1)
                     THEN
                        num_err :=
                           pac_suspension.f_gen_rec_partir_pdte
                                                            (psseguro,
                                                             v_cagente,
                                                             v_siguiente_mov,
                                                             pfmovini,
                                                             1,
                                                             rpend,
                                                             1
                                                            );
                        p_tab_error (f_sysdate,
                                     f_user,
                                     'pac_suspension.f_set_mov',
                                     3,
                                        'num_err  = '
                                     || num_err
                                     || ' v_siguiente_mov = '
                                     || v_siguiente_mov,
                                     NULL
                                    );

                        IF num_err <> 0
                        THEN
                           ROLLBACK;
                           RETURN num_err;
                        END IF;
                     END IF;
                  END IF;

                  -- BUG 0024450 - INICIO - DCT - 25/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS. A¿adir pcmodo
                  -- Anula los recibos pdtes.
                  -- quiz¿ se tenga que hacer un pac_suspension.f_baja_rec_pend que no genere extornos al anular los recibos pdtes.
                  -- Cuando es mensual NO SE DEBEN ANULAR LOS RECIBOS PENDIENTES sinada ya que ese recibo mensual pertenece a un recibo agrup
                  IF    NVL (f_parproductos_v (v_sproduc,
                                               'ADMITE_CERTIFICADOS'
                                              ),
                             0
                            ) = 0
                     OR v_cforpag IN (0, 1)
                  THEN
                     num_err :=
                        pac_anulacion.f_baja_rec_pend (pfmovini,
                                                       rpend,
                                                       1,
                                                       NULL,
                                                       pcmotmov
                                                      );
                     p_tab_error (f_sysdate,
                                  f_user,
                                  'pac_suspension.f_set_mov',
                                  4,
                                     'num_err  = '
                                  || num_err
                                  || ' v_siguiente_mov = '
                                  || v_siguiente_mov,
                                  NULL
                                 );

                     -- BUG 0024450 - FIN - DCT - 25/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS. A¿adir pcmodo
                     IF num_err <> 0
                     THEN
                        ROLLBACK;
                        RETURN num_err;
                     END IF;
                  END IF;

                  /* Tratamiento de recibos cobrados */
                  FOR rec_cob IN c_rec_cob (psseguro, pfmovini)
                  LOOP
                     IF rec_cob.cforpag NOT IN (0, 1)
                     THEN      -- fpago unica o anual se trata en el reinicio
                        rrcob (rec_cob.contad).nrecibo := rec_cob.nrecibo;
                        rrcob (rec_cob.contad).fmovini := rec_cob.fmovini;
                        rrcob (rec_cob.contad).fefecto := rec_cob.fefecto;
                        rrcob (rec_cob.contad).fvencim := rec_cob.fvencim;
                        p_tab_error (f_sysdate,
                                     f_user,
                                     'pac_suspension.f_set_mov',
                                     21,
                                        ' rrcob(rec_cob.contad).nrecibo = '
                                     || rrcob (rec_cob.contad).nrecibo,
                                     NULL
                                    );
                     END IF;
                  END LOOP;

                  num_err :=
                     pac_suspension.f_extorn_rec_cobrats (psseguro,
                                                          v_cagente,
                                                          v_siguiente_mov,
                                                          pfmovini,
                                                          1,
                                                          rrcob
                                                         );

                  IF num_err <> 0
                  THEN
                     ROLLBACK;
                     RETURN num_err;
                  END IF;
               END IF;                              --ptratarec IN (1, 2) THEN
            --BUG29229 - FIN - DCT - 02/12/2013.
            /*ELSE  IAXIS-3654 CJMR 15/05/2019
               FOR rec_pend IN c_rec_pend (psseguro, pfmovini)
               LOOP
                  rpend (rec_pend.contad).nrecibo := rec_pend.nrecibo;
                  rpend (rec_pend.contad).fmovini := rec_pend.fmovini;
                  rpend (rec_pend.contad).fefecto := rec_pend.fefecto;
                  rpend (rec_pend.contad).fvencim := rec_pend.fvencim;
               END LOOP;

               num_err := pac_anulacion.f_baja_rec_pend (pfmovini, rpend);*/ --IAXIS-3654 CJMR 15/05/2019
            END IF; --Mantis 34576/0197625 - cierra if - BLA - DD04/MM05/2015.
         --BUG29229 - INICIO - DCT - 02/12/2013. De momento lo comentamos
         /* Creamos en el certificado un movimient de suspensi¿n */
         /*IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
            AND pac_seguros.f_es_col_admin(psseguro) = 1 THEN   -- Colectivo administrado
            FOR regs IN (SELECT sseguro
                           FROM seguros
                          WHERE npoliza = (SELECT npoliza
                                             FROM seguros
                                            WHERE sseguro = psseguro)
                            AND ncertif <> 0
                            AND csituac = 0) LOOP
               num_err := f_movseguro(regs.sseguro, NULL, pcmotmov, 1, pfmovini, NULL,
                                      NULL, 0, NULL, v_siguiente_movcert, f_sysdate, NULL);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;

               -- BUG 0024450 - INICIO - DCT - 26/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS.
               num_err := f_act_hisseg(regs.sseguro, v_siguiente_movcert - 1);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;

               --insertamos en detmovsegurocol( psseguro,  v_siguiente_mov,
               num_err := pac_seguros.f_set_detmovsegurocol(psseguro, v_siguiente_mov,
                                                            regs.sseguro,
                                                            v_siguiente_movcert);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            -- BUG 0024450 - FIN - DCT - 26/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS.
            END LOOP;
         END IF;*/
         --BUG29229 - INICIO - DCT - 02/12/2013. De momento lo comentamos
         ELSIF pcmotmov = pac_suspension.vcod_reinicio  -- CONF-274-25/11/2016-JLTS - Se cambia 392 por la variable vcod_reinicio 141
         THEN                                                      -- REINICIO
            -- Se busca el ultimo suplemento de la poliza
            num_err :=
               f_procesini (f_user,
                            v_cempres,
                            'SUPLEM',
                            'Recibo por causa de reinicio',
                            lsproces
                           );

            IF ptratarec <> 2
            THEN                          --(ptratarec = 0 y 1 debe suspender)
               BEGIN
                  INSERT INTO suspensionseg
                              (sseguro, finicio, ffinal, ttexto, cmotmov,
                               nmovimi, fvigencia
                              )
                       VALUES (psseguro, pfmovini, NULL, pttexto, pcmotmov,
                               v_siguiente_mov, pfrenova
                              );
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX
                  THEN
                     RETURN 9905024;
               END;

               -- recupera fecha suspension anterio al reinicio
               SELECT finicio
                 INTO w_fsuspen
                 FROM suspensionseg
                WHERE sseguro = psseguro
                  AND cmotmov = 391
                  AND nmovimi =
                         (SELECT MAX (nmovimi)
                            FROM suspensionseg
                           WHERE sseguro = psseguro
                             AND cmotmov = 391
                             AND nmovimi < v_siguiente_mov);

               -- debe haber suspension anterior, se informa fin de suspension con fini reinicio
               UPDATE suspensionseg
                  SET ffinal = pfmovini
                WHERE sseguro = psseguro
                  AND cmotmov = 391
                  AND nmovimi =
                         (SELECT MAX (nmovimi)
                            FROM suspensionseg
                           WHERE sseguro = psseguro
                             AND cmotmov = 391
                             AND nmovimi < v_siguiente_mov);
            END IF;

            -- ptratarec <> 2 THEN  --(ptratarec = 0 y 1 debe suspender)
            IF NVL (f_parproductos_v (v_sproduc, 'TRATA_REC_SUSPENSION'), 1) =
                                                                             1
            THEN      --Mantis 34576/0197625 - abre if - BLA - DD04/MM05/2015.
               IF ptratarec IN (1, 2)
               THEN
                  IF v_cforpag IN (0, 1)
                  THEN
                     FOR rec_unic_anul IN c_rec_unic_anual (psseguro,
                                                            w_fsuspen,
                                                            pfmovini
                                                           )
                     LOOP
                        rec_unic_anual (rec_unic_anul.contad).nrecibo :=
                                                        rec_unic_anul.nrecibo;
                        rec_unic_anual (rec_unic_anul.contad).fmovini :=
                                                        rec_unic_anul.fmovini;
                        rec_unic_anual (rec_unic_anul.contad).fefecto :=
                                                        rec_unic_anul.fefecto;
                        rec_unic_anual (rec_unic_anul.contad).fvencim :=
                                                        rec_unic_anul.fvencim;
                        v_existe_recibo_cobrado := TRUE;
                     END LOOP;

                     num_err :=
                        pac_suspension.f_extorn_rec_unic_anual
                                                             (psseguro,
                                                              v_cagente,
                                                              v_siguiente_mov,
                                                              w_fsuspen,
                                                              pfmovini,
                                                              1,
                                                              rec_unic_anual
                                                             );
                  END IF;

                  IF pfrenova <> v_fcaranu
                  THEN
                     IF v_cforpag IN (0, 1)
                     THEN
                        UPDATE seguros
                           SET fcarpro = NVL (pfrenova, fcarpro),
                               frenova = NVL (pfrenova, frenova),
                               fcaranu = NVL (pfrenova, fcaranu),
                               nrenova =
                                     TO_CHAR (NVL (pfrenova, fcaranu), 'mmdd'),
                               cduraci = 6
                         WHERE sseguro = psseguro;

                        IF pfrenova < v_fcaranu
                        THEN
                           v_finicio := pfrenova;
                           v_ffin := v_fcaranu;
                           v_ctiprec := 9;
                        ELSIF pfrenova > v_fcaranu
                        THEN
                           v_finicio := v_fcaranu;
                           v_ffin := pfrenova;
                           v_ctiprec := 1;
                        END IF;

                        IF     NVL (f_parproductos_v (v_sproduc,
                                                      'ADMITE_CERTIFICADOS'
                                                     ),
                                    0
                                   ) = 1
                           AND pac_seguros.f_es_col_admin (psseguro) = 1
                        THEN                         -- Colectivo administrado
                           num_err :=
                              pac_suspension.f_tratar_certificados_reinicio
                                                                   (psseguro,
                                                                    wfcarpro,
                                                                    pfmovini,
                                                                    pcmotmov,
                                                                    pfrenova,
                                                                    lsproces,
                                                                    v_lista,
                                                                    pttexto
                                                                   );

                           IF num_err <> 0
                           THEN
                              RETURN num_err;
                           END IF;

                           IF v_lista IS NOT NULL
                           THEN
                              IF v_lista.COUNT > 0
                              THEN
                                 num_err :=
                                    pac_gestion_rec.f_agruparecibo
                                                                  (v_sproduc,
                                                                   pfmovini,
                                                                   pfmovini,
                                                                   v_cempres,
                                                                   v_lista,
                                                                   1
                                                                  );

                                 IF num_err <> 0
                                 THEN
                                    RETURN num_err;
                                 END IF;
                              END IF;
                           END IF;
                        ELSE
                           num_err :=
                              f_recries (v_ctipreb,
                                         psseguro,
                                         v_cagente,
                                         f_sysdate,
                                         v_finicio,
                                         v_ffin,
                                         v_ctiprec,
                                         NULL,
                                         NULL,
                                         v_ccobban,
                                         NULL,
                                         lsproces,
                                         0,
                                         'R',
                                         xcmodcom,
                                         pfrenova,
                                         0,
                                         NULL,
                                         v_cempres,
                                         v_siguiente_mov,
                                         v_csituac,
                                         ximporx
                                        );

                           IF num_err <> 0
                           THEN
                              RETURN num_err;
                           END IF;

                           UPDATE seguros
                              SET fcarpro = NVL (pfrenova, fcarpro),
                                  frenova = NVL (pfrenova, frenova),
                                  fcaranu = NVL (pfrenova, fcaranu),
                                  nrenova =
                                     TO_CHAR (NVL (pfrenova, fcaranu), 'mmdd')
                            WHERE sseguro = psseguro;
                        END IF;
                     ELSE
                        wfcarpro :=
                           f_calcula_fcarpro (pfrenova,
                                              v_cforpag,
                                              pfmovini,
                                              pfmovini
                                             );

                        UPDATE seguros
                           SET frenova = NVL (pfrenova, frenova),
                               fcaranu = NVL (pfrenova, fcaranu),
                               fcarpro = NVL (wfcarpro, fcarpro),
                               cduraci = 6,
                               nrenova =
                                     TO_CHAR (NVL (pfrenova, fcaranu), 'mmdd')
                         WHERE sseguro = psseguro;

                        IF     NVL (f_parproductos_v (v_sproduc,
                                                      'ADMITE_CERTIFICADOS'
                                                     ),
                                    0
                                   ) = 1
                           AND pac_seguros.f_es_col_admin (psseguro) = 1
                        THEN                         -- Colectivo administrado
                           num_err :=
                              pac_suspension.f_tratar_certificados_reinicio
                                                                   (psseguro,
                                                                    wfcarpro,
                                                                    pfmovini,
                                                                    pcmotmov,
                                                                    pfrenova,
                                                                    lsproces,
                                                                    v_lista,
                                                                    pttexto
                                                                   );

                           IF num_err <> 0
                           THEN
                              RETURN num_err;
                           END IF;

                           --BUG27048 - INICIO - DCT - 28/11/2013
                           --Debemos validar si hace falta generar recibo de prima m¿nima
                           --Tenemos que sumar la ITOTALR de vdetrecibos de todos los recibos generados en f_trat_certificados_reinicio
                           IF v_lista IS NOT NULL
                           THEN
                              IF v_lista.COUNT > 0
                              THEN
                                 FOR reg IN v_lista.FIRST .. v_lista.LAST
                                 LOOP
                                    IF v_lista.EXISTS (reg)
                                    THEN
                                       SELECT v.itotalr
                                         INTO v_totalr_aux
                                         FROM recibos r, vdetrecibos v
                                        WHERE r.nrecibo = v_lista (reg).idd
                                          AND r.nrecibo = v.nrecibo;

                                       v_totalr := v_totalr + v_totalr_aux;
                                    END IF;      --IF v_lista.EXISTS(reg) THEN
                                 END LOOP;
                              --FOR reg IN v_lista.FIRST .. v_lista.LAST LOOP
                              END IF;              --IF v_lista.COUNT > 0 THEN
                           END IF;               --IF v_lista is not null then

                           --Tenemos que saber que  valor de prima m¿nima hay.
                           --Si el valor de los recibos que hemos realizado en v_lista es menor que la prima m¿nima deberemos
                           --llamar a pac_suspension.f_genera_rec_prima_minima sino no.
                           SELECT s.sseguro
                             INTO v_sseguro_0
                             FROM seguros s, productos pr
                            WHERE s.npoliza = (SELECT npoliza
                                                 FROM seguros
                                                WHERE sseguro = psseguro)
                              AND s.ncertif = 0
                              AND s.sproduc = pr.sproduc;

                           num_err :=
                              pac_preguntas.f_get_pregunpolseg (v_sseguro_0,
                                                                v_cpregun4821,
                                                                'SEG',
                                                                v_crespue4821
                                                               );

                           IF num_err <> 0
                           THEN
                              RETURN num_err;
                           END IF;

                           IF v_totalr < v_crespue4821
                           THEN
                              --Llamar a la funci¿n f_genera_rec_prima_m¿nima.
                              num_err :=
                                 pac_suspension.f_genera_rec_prima_minima
                                                              (psseguro,
                                                               NULL,
                                                               wfcarpro,
                                                               pfmovini,
                                                               lsproces,
                                                               v_nrecibo_cert
                                                              );

                              IF num_err <> 0
                              THEN
                                 RETURN num_err;
                              END IF;

                              v_lista.EXTEND;
                              v_lista (v_lista.LAST) := ob_lista_id ();
                              v_lista (v_lista.LAST).idd := v_nrecibo_cert;
                           END IF;         -- IF v_totalr < v_crespue4821 THEN

                           --BUG27048 - FIN- DCT -28/11/2013
                           IF v_lista IS NOT NULL
                           THEN
                              IF v_lista.COUNT > 0
                              THEN
                                 num_err :=
                                    pac_gestion_rec.f_agruparecibo
                                                                  (v_sproduc,
                                                                   pfmovini,
                                                                   pfmovini,
                                                                   v_cempres,
                                                                   v_lista,
                                                                   1
                                                                  );

                                 IF num_err <> 0
                                 THEN
                                    RETURN num_err;
                                 END IF;
                              END IF;
                           END IF;
                        ELSE
                           IF pfmovini < wfcarpro
                           THEN
                              num_err :=
                                 f_recries (v_ctipreb,
                                            psseguro,
                                            v_cagente,
                                            f_sysdate,
                                            pfmovini,
                                            wfcarpro,
                                            1,
                                            NULL,
                                            NULL,
                                            v_ccobban,
                                            NULL,
                                            lsproces,
                                            0,
                                            'R',
                                            xcmodcom,
                                            pfrenova,
                                            0,
                                            NULL,
                                            v_cempres,
                                            v_siguiente_mov,
                                            v_csituac,
                                            ximporx
                                           );

                              IF num_err <> 0
                              THEN
                                 RETURN num_err;
                              END IF;
                           END IF;
                        END IF;
                     END IF;
                  ELSE
                     IF v_cforpag NOT IN (0, 1)
                     THEN
                        wfcarpro :=
                           f_calcula_fcarpro (pfrenova,
                                              v_cforpag,
                                              pfmovini,
                                              pfmovini
                                             );

                        UPDATE seguros
                           SET fcarpro = wfcarpro
                         WHERE sseguro = psseguro;

                        /*UPDATE seguros
                           SET fcarpro = GREATEST(v_fcarpro, pfmovini)   -- GREATEST(01/05, 15/05) --> 15/05
                         WHERE sseguro = psseguro;*/
                        IF     NVL (f_parproductos_v (v_sproduc,
                                                      'ADMITE_CERTIFICADOS'
                                                     ),
                                    0
                                   ) = 1
                           AND pac_seguros.f_es_col_admin (psseguro) = 1
                        THEN                         -- Colectivo administrado
                           --IF pfmovini < wfcarpro THEN
                           num_err :=
                              pac_suspension.f_tratar_certificados_reinicio
                                                                   (psseguro,
                                                                    wfcarpro,
                                                                    pfmovini,
                                                                    pcmotmov,
                                                                    pfrenova,
                                                                    lsproces,
                                                                    v_lista,
                                                                    pttexto
                                                                   );

                           IF num_err <> 0
                           THEN
                              RETURN num_err;
                           END IF;

                           IF pfmovini < wfcarpro
                           THEN
                              --BUG27048 - INICIO - DCT - 28/11/2013
                              --Debemos validar si hace falta generar recibo de prima m¿nima
                              --Tenemos que sumar la ITOTALR de vdetrecibos de todos los recibos generados en f_trat_certificados_reinicio
                              IF v_lista IS NOT NULL
                              THEN
                                 IF v_lista.COUNT > 0
                                 THEN
                                    FOR reg IN v_lista.FIRST .. v_lista.LAST
                                    LOOP
                                       IF v_lista.EXISTS (reg)
                                       THEN
                                          SELECT v.itotalr
                                            INTO v_totalr_aux
                                            FROM recibos r, vdetrecibos v
                                           WHERE r.nrecibo = v_lista (reg).idd
                                             AND r.nrecibo = v.nrecibo;

                                          v_totalr := v_totalr + v_totalr_aux;
                                       END IF;   --IF v_lista.EXISTS(reg) THEN
                                    END LOOP;
                                 --FOR reg IN v_lista.FIRST .. v_lista.LAST LOOP
                                 END IF;           --IF v_lista.COUNT > 0 THEN
                              END IF;            --IF v_lista is not null then

                              p_tab_error (f_sysdate,
                                           f_user,
                                           'pac_suspension.f_set_mov',
                                           7777,
                                              'v_totalr:'
                                           || v_totalr
                                           || ' psseguro:'
                                           || psseguro,
                                           NULL
                                          );

                              --Tenemos que saber que  valor de prima m¿nima hay.
                              --Si el valor de los recibos que hemos realizado en v_lista es menor que la prima m¿nima deberemos
                              --llamar a pac_suspension.f_genera_rec_prima_minima sino no.
                              SELECT s.sseguro
                                INTO v_sseguro_0
                                FROM seguros s, productos pr
                               WHERE s.npoliza = (SELECT npoliza
                                                    FROM seguros
                                                   WHERE sseguro = psseguro)
                                 AND s.ncertif = 0
                                 AND s.sproduc = pr.sproduc;

                              p_tab_error (f_sysdate,
                                           f_user,
                                           'pac_suspension.f_set_mov',
                                           7778,
                                           'v_sseguro_0:' || v_sseguro_0,
                                           NULL
                                          );
                              num_err :=
                                 pac_preguntas.f_get_pregunpolseg
                                                               (v_sseguro_0,
                                                                v_cpregun4821,
                                                                'SEG',
                                                                v_crespue4821
                                                               );
                              p_tab_error (f_sysdate,
                                           f_user,
                                           'pac_suspension.f_set_mov',
                                           7779,
                                           'v_crespue4821:' || v_crespue4821,
                                           NULL
                                          );

                              IF num_err <> 0
                              THEN
                                 RETURN num_err;
                              END IF;

                              IF v_totalr < v_crespue4821
                              THEN
                                 --Llamar a la funci¿n f_genera_rec_prima_m¿nima.
                                 num_err :=
                                    pac_suspension.f_genera_rec_prima_minima
                                                              (psseguro,
                                                               NULL,
                                                               wfcarpro,
                                                               pfmovini,
                                                               lsproces,
                                                               v_nrecibo_cert
                                                              );

                                 IF num_err <> 0
                                 THEN
                                    RETURN num_err;
                                 END IF;

                                 v_lista.EXTEND;
                                 v_lista (v_lista.LAST) := ob_lista_id ();
                                 v_lista (v_lista.LAST).idd := v_nrecibo_cert;
                                 p_tab_error (f_sysdate,
                                              f_user,
                                              'pac_suspension.f_set_mov',
                                              7780,
                                                 'v_nrecibo_cert:'
                                              || v_nrecibo_cert,
                                              NULL
                                             );
                              END IF;      -- IF v_totalr < v_crespue4821 THEN

                              --BUG27048 - FIN- DCT -28/11/2013
                              IF v_lista IS NOT NULL
                              THEN
                                 IF v_lista.COUNT > 0
                                 THEN
                                    p_tab_error (f_sysdate,
                                                 f_user,
                                                 'pac_suspension.f_set_mov',
                                                 7781,
                                                 'v_sproduc:' || v_sproduc,
                                                 NULL
                                                );
                                    num_err :=
                                       pac_gestion_rec.f_agruparecibo
                                                                   (v_sproduc,
                                                                    pfmovini,
                                                                    pfmovini,
                                                                    v_cempres,
                                                                    v_lista,
                                                                    1
                                                                   );
                                    p_tab_error (f_sysdate,
                                                 f_user,
                                                 'pac_suspension.f_set_mov',
                                                 7782,
                                                 'num_err:' || num_err,
                                                 NULL
                                                );

                                    IF num_err <> 0
                                    THEN
                                       RETURN num_err;
                                    END IF;
                                 END IF;
                              END IF;
                           --END IF;
                           END IF;
                        ELSE
                           IF pfmovini < wfcarpro               /*v_fcarpro*/
                           THEN
                              num_err :=
                                 f_recries (v_ctipreb,
                                            psseguro,
                                            v_cagente,
                                            f_sysdate,
                                            pfmovini,
                                            wfcarpro /*v_fcarpro*/,
                                            1,
                                            NULL,
                                            NULL,
                                            v_ccobban,
                                            NULL,
                                            lsproces,
                                            0,
                                            'R',
                                            xcmodcom,
                                            pfrenova,
                                            0,
                                            NULL,
                                            v_cempres,
                                            v_siguiente_mov,
                                            v_csituac,
                                            ximporx
                                           );

                              IF num_err <> 0
                              THEN
                                 RETURN num_err;
                              END IF;
                           END IF;
                        END IF;
                     ELSE                            --v_cforpag IN(0, 1) THEN
                        --BUG27048 - INICIO - DCT -11/11/2013
                        IF NOT v_existe_recibo_cobrado
                        THEN
                           wfcarpro :=
                              f_calcula_fcarpro (pfrenova,
                                                 v_cforpag,
                                                 pfmovini,
                                                 pfmovini
                                                );

                           UPDATE seguros
                              SET fcarpro = wfcarpro
                            WHERE sseguro = psseguro;

                           IF     NVL
                                     (f_parproductos_v (v_sproduc,
                                                        'ADMITE_CERTIFICADOS'
                                                       ),
                                      0
                                     ) = 1
                              AND pac_seguros.f_es_col_admin (psseguro) = 1
                           THEN                      -- Colectivo administrado
                              num_err :=
                                 pac_suspension.f_tratar_certificados_reinicio
                                                                   (psseguro,
                                                                    wfcarpro,
                                                                    pfmovini,
                                                                    pcmotmov,
                                                                    pfrenova,
                                                                    lsproces,
                                                                    v_lista,
                                                                    pttexto
                                                                   );

                              IF num_err <> 0
                              THEN
                                 RETURN num_err;
                              END IF;

                              --BUG27048 - INICIO - DCT - 28/11/2013
                              --Debemos validar si hace falta generar recibo de prima m¿nima
                              --Tenemos que sumar la ITOTALR de vdetrecibos de todos los recibos generados en f_trat_certificados_reinicio
                              IF v_lista IS NOT NULL
                              THEN
                                 IF v_lista.COUNT > 0
                                 THEN
                                    FOR reg IN v_lista.FIRST .. v_lista.LAST
                                    LOOP
                                       IF v_lista.EXISTS (reg)
                                       THEN
                                          SELECT v.itotalr
                                            INTO v_totalr_aux
                                            FROM recibos r, vdetrecibos v
                                           WHERE r.nrecibo = v_lista (reg).idd
                                             AND r.nrecibo = v.nrecibo;

                                          v_totalr := v_totalr + v_totalr_aux;
                                       END IF;   --IF v_lista.EXISTS(reg) THEN
                                    END LOOP;
                                 --FOR reg IN v_lista.FIRST .. v_lista.LAST LOOP
                                 END IF;           --IF v_lista.COUNT > 0 THEN
                              END IF;            --IF v_lista is not null then

                              --Tenemos que saber que  valor de prima m¿nima hay.
                              --Si el valor de los recibos que hemos realizado en v_lista es menor que la prima m¿nima deberemos
                              --llamar a pac_suspension.f_genera_rec_prima_minima sino no.
                              SELECT s.sseguro
                                INTO v_sseguro_0
                                FROM seguros s, productos pr
                               WHERE s.npoliza = (SELECT npoliza
                                                    FROM seguros
                                                   WHERE sseguro = psseguro)
                                 AND s.ncertif = 0
                                 AND s.sproduc = pr.sproduc;

                              num_err :=
                                 pac_preguntas.f_get_pregunpolseg
                                                               (v_sseguro_0,
                                                                v_cpregun4821,
                                                                'SEG',
                                                                v_crespue4821
                                                               );

                              IF num_err <> 0
                              THEN
                                 RETURN num_err;
                              END IF;

                              IF v_totalr < v_crespue4821
                              THEN
                                 --Llamar a la funci¿n f_genera_rec_prima_m¿nima.
                                 num_err :=
                                    pac_suspension.f_genera_rec_prima_minima
                                                              (psseguro,
                                                               NULL,
                                                               wfcarpro,
                                                               pfmovini,
                                                               lsproces,
                                                               v_nrecibo_cert
                                                              );

                                 IF num_err <> 0
                                 THEN
                                    RETURN num_err;
                                 END IF;

                                 v_lista.EXTEND;
                                 v_lista (v_lista.LAST) := ob_lista_id ();
                                 v_lista (v_lista.LAST).idd := v_nrecibo_cert;
                              END IF;      -- IF v_totalr < v_crespue4821 THEN

                              --BUG27048 - FIN- DCT -28/11/2013
                              IF v_lista IS NOT NULL
                              THEN
                                 IF v_lista.COUNT > 0
                                 THEN
                                    num_err :=
                                       pac_gestion_rec.f_agruparecibo
                                                                  (v_sproduc,
                                                                   pfmovini,
                                                                   pfmovini,
                                                                   v_cempres,
                                                                   v_lista,
                                                                   1
                                                                  );

                                    IF num_err <> 0
                                    THEN
                                       RETURN num_err;
                                    END IF;
                                 END IF;
                              END IF;
                           ELSE
                              IF pfmovini < wfcarpro            /*v_fcarpro*/
                              THEN
                                 num_err :=
                                    f_recries (v_ctipreb,
                                               psseguro,
                                               v_cagente,
                                               f_sysdate,
                                               pfmovini,
                                               wfcarpro /*v_fcarpro*/,
                                               1,
                                               NULL,
                                               NULL,
                                               v_ccobban,
                                               NULL,
                                               lsproces,
                                               0,
                                               'R',
                                               xcmodcom,
                                               pfrenova,
                                               0,
                                               NULL,
                                               v_cempres,
                                               v_siguiente_mov,
                                               v_csituac,
                                               ximporx
                                              );

                                 IF num_err <> 0
                                 THEN
                                    RETURN num_err;
                                 END IF;
                              END IF;
                           END IF;
                        ELSE
                           num_err :=
                              pac_suspension.f_tratar_certifs_reini_norec
                                                                   (psseguro,
                                                                    wfcarpro,
                                                                    pfmovini,
                                                                    pcmotmov,
                                                                    pfrenova,
                                                                    lsproces,
                                                                    v_lista,
                                                                    pttexto
                                                                   );

                           IF num_err <> 0
                           THEN
                              RETURN num_err;
                           END IF;
                        END IF;
                     END IF;                 --BUG27048 - FIN- DCT -11/11/2013
                  END IF;
               END IF;
            /*ELSE  IAXIS-3654 CJMR 15/05/2019
               num_err :=
                  pac_rehabilita.f_recibos (psseguro,
                                            v_siguiente_mov,
                                            pxnrecibo
                                           );*/  --IAXIS-3654 CJMR 15/05/2019
            END IF;
         END IF;    --Mantis 34576/0197625 - cierra if - BLA - DD04/MM05/2015.

         --COMMIT;
         RETURN 0;                                                  -- Todo Ok
      ELSE        -- No se puede realizar el movimiento de suspensi¿n/reinicio
         RETURN v_validamov;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         --ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_suspension.f_set_mov',
                         'psseguro:'
                      || psseguro
                      || ' pcmotmov:'
                      || pcmotmov
                      || ' pfmovini:'
                      || pfmovini
                      || ' pfrenova:'
                      || pfrenova
                      || ' pttexto2:'
                      || pttexto2,
                      1,
                      SQLERRM
                     );
         RETURN 101283;                  -- No se han podido grabar los datos.
   END f_set_mov;

   /*************************************************************************
      Funcion que valida la situacion de una poliza para realizar una suspensi¿n/reinicio
      param in psseguro : id. de la poliza
      param in pcmotmov : codigo motivo movimiento
      return            : Error
   *************************************************************************/
   FUNCTION f_valida_crea_mov (psseguro IN NUMBER, pcmotmov IN NUMBER)
      RETURN NUMBER
   IS
      v_sseguro      seguros.sseguro%TYPE;
      v_csituac      seguros.csituac%TYPE;
      v_creteni      seguros.creteni%TYPE;
      v_fcaranu      seguros.fcaranu%TYPE;
      v_fcarpro      seguros.fcarpro%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      v_fefecto      seguros.fefecto%TYPE;
      v_fvencim      seguros.fvencim%TYPE;
      v_motmovsusp   NUMBER;
      v_motmovrein   NUMBER;
      v_numsusp      NUMBER;
      v_numreini     NUMBER;
   BEGIN
      -- se mira que el seguro exista
      BEGIN
         SELECT sseguro, csituac, creteni, fcaranu, fcarpro,
                sproduc, fefecto, fvencim
           INTO v_sseguro, v_csituac, v_creteni, v_fcaranu, v_fcarpro,
                v_sproduc, v_fefecto, v_fvencim
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN (100500);                            -- P¿liza inexistente
      END;

      -- situaci¿n de la p¿liza: la poliza debe estar vigente y no retenida
      IF v_csituac <> 0 OR v_creteni <> 0
      THEN
         RETURN (120129);
      END IF;

      -- Si no permite pignoraci¿n pues mensage informativo
      IF f_parproductos_v (v_sproduc, 'PERMITE_SUSPENSION') = 0
      THEN
         RETURN (9904529);
      -- Suspensi¿n/Reinicio de este tipo de p¿lizas no permitida
      END IF;

      -- Comprobar la situaci¿n de suspensiones/reinicios.
      BEGIN
         v_motmovsusp := 391;
         v_motmovrein := pac_suspension.vcod_reinicio; -- CONF-274-25/11/2016-JLTS- Se cambia 392 por la variable vcod_reinicio 141

         SELECT COUNT (sseguro)
           INTO v_numsusp
           FROM suspensionseg
          WHERE sseguro = psseguro AND cmotmov = v_motmovsusp;

         SELECT COUNT (sseguro)
           INTO v_numreini
           FROM suspensionseg
          WHERE sseguro = psseguro AND cmotmov = v_motmovrein;
      END;

      IF v_numsusp > v_numreini AND pcmotmov = 391
      THEN
         RETURN (9904531);
      -- P¿liza suspendida. Antes se debe reiniciar la p¿liza
      END IF;

      IF v_numreini > v_numsusp AND pcmotmov = pac_suspension.vcod_reinicio -- CONF-274-25/11/2016-JLTS- Se cambia 392 por la variable vcod_reinicio 141
      THEN
         RETURN (9904532);
      -- P¿liza reiniciada. Antes se debe suspender la p¿liza
      END IF;

      RETURN 0;                                                     -- Todo Ok
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_suspension.f_valida_crea_mov',
                      'psseguro:' || psseguro || ' pcmotmov:' || pcmotmov,
                      1,
                      SQLERRM
                     );
         RETURN 140999;                                 -- Error no controlado
   END f_valida_crea_mov;

   /*************************************************************************
      Funcion que realiza la validacion para la insercion de un movimiento de
      suspensi¿n/reinicio de la poliza
      param in psseguro : id. de la poliza
      param in pcmotmov : codigo motivo movimiento
      param in pfmovini : fecha inicio movimiento
      param in pfrenova : fecha nueva vigencia
      return            : Error
   *************************************************************************/
   FUNCTION f_valida_mov (
      psseguro   IN   NUMBER,
      pcmotmov   IN   NUMBER,
      pfmovini   IN   DATE,
      pfrenova   IN   DATE
   )
      RETURN NUMBER
   IS
      v_fefecto              DATE;
      v_sseguro              seguros.sseguro%TYPE;
      v_csituac              seguros.csituac%TYPE;
      v_creteni              seguros.creteni%TYPE;
      v_fcaranu              seguros.fcaranu%TYPE;
      v_fcarpro              seguros.fcarpro%TYPE;
      v_sproduc              seguros.sproduc%TYPE;
      v_fefectopol           seguros.fefecto%TYPE;
      v_fvencim              seguros.fvencim%TYPE;
      v_finicio              suspensionseg.finicio%TYPE;
      v_ffinal               suspensionseg.ffinal%TYPE;
      v_sinis_post_suspens   NUMBER                       := 0;
      v_crespue_4790         pregunpolseg.crespue%TYPE;
      num_err                NUMBER;
      v_crealiza     cfg_accion.crealiza%TYPE;   -- BUG:34496
      vnumerr        NUMBER;   -- BUG:34496
      v_cempres number;
      -- CONF-274-25/11/2016-JLTS- Ini
      v_existe_contractual NUMBER := 0;
      v_existe_sin         NUMBER := 0;
      v_existe_susp        NUMBER := 0;
      -- CONF-274-25/11/2016-JLTS- Fin
   BEGIN
      -- comprobaci¿n de fechas
      SELECT MAX (fefecto)
        INTO v_fefecto
        FROM movseguro
       WHERE sseguro = psseguro
         --La propuestas de cartera no hay que tenerlas en cuenta.
         AND cmovseg NOT IN (52)
         AND cmotmov NOT IN (996, 997, 403);

      BEGIN
         SELECT sseguro, csituac, creteni, fcaranu, fcarpro,
                sproduc, fefecto, fvencim, cempres
           INTO v_sseguro, v_csituac, v_creteni, v_fcaranu, v_fcarpro,
                v_sproduc, v_fefectopol, v_fvencim, v_cempres
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN (100500);                            -- P¿liza inexistente
      END;

      IF v_csituac <> 0
      THEN
         RETURN (120129);
      END IF;

      -- Bug 28224/153119 - 19/09/2013 - AMC
      IF NVL (f_parproductos_v (v_sproduc, 'PERMITE_SUSPENSION'), 0) = 0
      THEN
         RETURN (9904862);
      END IF;

      -- La fecha de incio del movimiento debe ser anterior a la fecha de
      -- pr¿xima cartera y a la fecha de cartera anual, y posterior a la fecha
      -- del ¿ltimo movimiento
      IF pfmovini > v_fcaranu
      THEN
         RETURN (103308);
-- La fecha del suplemento no puede ser superior a la fecha de la pr¿xima cartera
      END IF;

      IF pcmotmov IN (391)
      THEN                           -- En reinicio no aplica esta validaci¿n.
         IF pfmovini > v_fcarpro
         THEN
            RETURN (103308);
-- La fecha del suplemento no puede ser superior a la fecha de la pr¿xima cartera
         END IF;
      END IF;

      vnumerr := pac_cfg.f_get_user_accion_permitida(f_user, 'PERMITE_PIGNORAR', psseguro,
                                                     v_cempres, v_crealiza);
      --ini CONF-782 KJSC segun incidencia 451 y funcional se quitara esta validacion a Confianza
      IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'FECHA_MOVIMIENTO'), 0) = 0 THEN
         IF NVL(v_crealiza, 0) = 0 THEN
             IF pfmovini < v_fefecto
             THEN
                RETURN (700088);
             -- La fecha no puede ser anterior al moviento anterior
             END IF;
         END IF;
      END IF;
      --fin CONF-782 KJSC segun incidencia 451 y funcional se quitara esta validacion a Confianza

      -- La fecha de incio del movimiento debe ser posterior a la fecha efecto
      -- de la p¿liza y anterior a la fecha de vencimiento
      IF pfmovini < v_fefectopol
      THEN
         RETURN (101203);
      -- Esta fecha no puede ser m¿s peque¿a que la fecha efecto del seg.
      END IF;

      IF pfmovini > v_fvencim
      THEN
         RETURN (101729);
      -- Esta fecha no puede ser m¿s grande que la de vencimiento del seg.
      END IF;

      -- 391: Suspension. 392,141: Reinicio
      IF pcmotmov = pac_suspension.vcod_reinicio -- CONF-274-25/11/2016-JLTS- Se cambia 392 por la variable vcod_reinicio 141
      THEN
         -- Se comprueba que la fecha de inicio de un reinicio no sea menor que la de la ultima suspension
         BEGIN
            SELECT finicio, ffinal
              INTO v_finicio, v_ffinal
              FROM suspensionseg
             WHERE sseguro = psseguro
               AND cmotmov = 391
               AND nmovimi = (SELECT MAX (nmovimi)
                                FROM suspensionseg
                               WHERE sseguro = psseguro AND cmotmov = 391);
         EXCEPTION
            WHEN OTHERS
            THEN
               v_finicio := NULL;
               v_ffinal := NULL;
         END;

         IF (v_finicio IS NOT NULL) AND (pfmovini < v_finicio)
         THEN
            RETURN (9904520);
-- La fecha de reinicio no puede ser inferior a la fecha de la ¿ltima suspensi¿n
         ELSIF v_finicio IS NULL
         THEN
            RETURN (9904526);
-- El suplemento de reinicio s¿lo puede realizarse si la p¿liza est¿ suspendida
         END IF;
      ELSIF pcmotmov = 391
      THEN
         -- Se comprueba que la fecha de inicio de una suspensi¿n no sea menor que la del ultimo reinicio
         BEGIN
            SELECT finicio, ffinal
              INTO v_finicio, v_ffinal
              FROM suspensionseg
             WHERE sseguro = psseguro
               AND cmotmov = pac_suspension.vcod_reinicio -- CONF-274-25/11/2016-JLTS- Se cambia 392 por la variable vcod_reinicio 141
               AND nmovimi = (SELECT MAX (nmovimi)
                                FROM suspensionseg
                               WHERE sseguro = psseguro AND cmotmov = pac_suspension.vcod_reinicio);  -- CONF-274-25/11/2016-JLTS- Se cambia 392 por la variable vcod_reinicio 141
         EXCEPTION
            WHEN OTHERS
            THEN
               v_finicio := NULL;
               v_ffinal := NULL;
         END;

         IF (v_finicio IS NOT NULL) AND (pfmovini < v_finicio)
         THEN
            RETURN (9904521);
-- La fecha de suspensi¿n no puede ser inferior a la fecha del ¿ltimo reinicio
         END IF;
         -- CONF-274-25/11/2016-JLTS- Ini
         IF NVL (f_parproductos_v (v_sproduc, 'VAL_SUSP_CUMPLIM'), 0) = 1
          THEN
            -- Hay amparos Contractuales con periodo de vigencia activo en esa fecha
            BEGIN
              SELECT COUNT(1)
                INTO v_existe_contractual
                FROM garanseg g
               WHERE g.sseguro = psseguro
                 AND nmovimi =
                     (SELECT MAX(nmovimi)
                        FROM garanseg gs
                       WHERE g.sseguro = gs.sseguro)
                    --and pfmovini between finivig and ffinvig
                 AND g.ffinefe IS NULL
                 AND EXISTS (SELECT 1
                        FROM pargaranpro pgp
                       WHERE pgp.cgarant = g.cgarant
                         AND cpargar = 'EXCONTRACTUAL'
                         AND cvalpar = 1);
            EXCEPTION
              WHEN no_data_found THEN
                RETURN NULL; -- P¿liza inexistente
            END;
            IF v_existe_contractual = 0 THEN
              RETURN(9909374); -- No Existen garant¿as Contractuales vigentes
            END IF;
            --No puede haber siniestros con fecha de ocurrencia posterior asociados a amparos que
            --se suspenden (no generan cobro de prima en suspensi¿n/reinicio)
            BEGIN
              SELECT COUNT(1)
                INTO v_existe_sin
                FROM sin_siniestro
               WHERE sseguro = psseguro
                 AND f_sysdate > fsinies;
            EXCEPTION
              WHEN no_data_found THEN
                RETURN NULL;
            END;
            IF v_existe_sin = 1 THEN
              RETURN(9909375); --La fecha de inicio de suspensi¿n con fecha de ocurrencia de siniestro.
            END IF;
            -- La fecha no puede solaparse son otra suspensi¿n anterior
            BEGIN
              SELECT COUNT(1)
                INTO v_existe_susp
                FROM suspensionseg g
               WHERE g.sseguro = psseguro
                 AND nmovimi =
                     (SELECT MAX(nmovimi)
                        FROM suspensionseg gs
                       WHERE g.sseguro = gs.sseguro)
                 and pfmovini between g.finicio and g.ffinal
                 AND g.ffinal IS NULL;
            EXCEPTION
              WHEN no_data_found THEN
                RETURN NULL; -- P¿liza inexistente
            END;
            IF v_existe_susp > 0 THEN
              RETURN(9909376); --La suspensi¿n a realizar esta dentro del periodo de una suspensi¿n anterior.
            END IF;
         END IF;
         -- CONF-274-25/11/2016-JLTS- Fin
      END IF;

      -- Validaciones de la fecha de fin.
      /*
      IF pfmovfin IS NOT NULL THEN
         -- La fecha fin de un movimiento debe ser posterior a la fecha inicio del movimiento
         IF pfmovfin < pfmovini THEN
            RETURN(101922);   -- La fecha inicial no puede ser mayor que la final
         END IF;

         -- La fecha fin de un movimiento debe ser anterior a la fecha de vencimiento de la poliza
         IF pfmovfin > v_fvencim THEN
            RETURN(101729);   -- Esta fecha no puede ser m¿s grande que la de vencimiento del seg.
         END IF;
      ELSE
      */
         -- Si reinicio la fecha de fin no puede ser nula. -- 391: Suspension. 392,141: Reinicio
      IF pcmotmov = pac_suspension.vcod_reinicio AND pfrenova IS NULL -- CONF-274-25/11/2016-JLTS- Se cambia 392 por la variable vcod_reinicio 141
      THEN
         RETURN (105554);                          -- Fecha final obligatoria
      END IF;

      --END IF;
      v_sinis_post_suspens := 0;

      SELECT COUNT (1)
        INTO v_sinis_post_suspens
        FROM sin_siniestro
       WHERE sseguro = psseguro AND fsinies > pfmovini;

      IF v_sinis_post_suspens > 0
      THEN
         RETURN (9904538);
      -- Existen siniestros con fecha ocurrencia posterior a la suspensi¿n
      END IF;

      --BUG29229 - INICIO - DCT - 02/12/2013. Lo trasladamos al PAC_MD_SUSPENSION.f_set_mov
      /*IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
         AND pac_seguros.f_es_col_agrup(psseguro) = 1 THEN
         IF pac_seguros.f_get_escertifcero(NULL, psseguro) = 1 THEN
            RETURN(9905997);   -- La suspensi¿n/reinicio en colectivos agrupados no aplica sobre la car¿tula.
         END IF;
      END IF;

      IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
         AND pac_seguros.f_es_col_admin(psseguro) = 1 THEN
         IF pac_seguros.f_get_escertifcero(NULL, psseguro) <> 1 THEN
            RETURN(9906000);   -- La suspensi¿n/reinicio en colectivos administrados no aplica en los certificados.
         END IF;
      END IF;*/
      --BUG29229 - FIN - DCT - 02/12/2013. Lo trasladamos al PAC_MD_SUSPENSION.f_set_mov

      --BUG29229 - INICIO - DCT - 02/12/2013. A¿adir nueva validaci¿n
      IF NVL (f_parproductos_v (v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
      THEN
         IF pac_seguros.f_get_escertifcero (NULL, psseguro) = 1
         THEN
            BEGIN
               SELECT MAX (m.fefecto)
                 INTO v_fefecto
                 FROM movseguro m, seguros s
                WHERE s.npoliza = (SELECT npoliza
                                     FROM seguros
                                    WHERE sseguro = psseguro)
                  AND s.ncertif <> 0
                  AND s.sseguro = m.sseguro
                  AND s.csituac <> 2
                  AND m.cmovseg NOT IN (52)
                  AND m.cmotmov NOT IN (996, 997, 403);
            EXCEPTION
               WHEN OTHERS
               THEN
                  RETURN SQLCODE;
            END;

            IF pfmovini < v_fefecto
            THEN
               RETURN (9901064);
            END IF;
         END IF;
      END IF;

      --BUG29229 - FIN - DCT - 02/12/2013. A¿adir nueva validaci¿n
      RETURN 0;                                                     -- Todo Ok
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_suspension.f_valida_mov',
                         'psseguro:'
                      || psseguro
                      || ' pcmotmov:'
                      || pcmotmov
                      || ' pfmovini:'
                      || pfmovini
                      || ' pfrenova:'
                      || pfrenova,
                      1,
                      SQLERRM
                     );
         RETURN 140999;                                 -- Error no controlado
   END f_valida_mov;

   /*************************************************************************
      Funcion que inicializa los campos de pantalla en funcion de los
      parametros de entrada
      param in psseguro : id. de la poliza
      param in pcmotmov : codigo motivo movimiento
      param out pquery  : consulta a realizar construida en funcion de los
                          parametros
      return            : Error
   *************************************************************************/
   FUNCTION f_get_mov (
      psseguro   IN       NUMBER,
      pcmotmov   IN       NUMBER,
      pquery     OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      v_motmovbloq    NUMBER;
      v_motmovdes     NUMBER;
      v_fefecto_mov   VARCHAR2 (10);
   BEGIN

      IF pcmotmov IN (391, pac_suspension.vcod_reinicio) -- CONF-274-25/11/2016-JLTS- Se cambia 392 por la variable vcod_reinicio 141
      THEN
         v_motmovbloq := 391;
         v_motmovdes := pac_suspension.vcod_reinicio; -- CONF-274-25/11/2016-JLTS- Se cambia 392 por la variable vcod_reinicio 141
      END IF;

      IF pcmotmov IN (391, pac_suspension.vcod_reinicio) -- CONF-274-25/11/2016-JLTS- Se cambia 392 por la variable vcod_reinicio 141
      THEN
         IF pcmotmov = pac_suspension.vcod_reinicio -- CONF-274-25/11/2016-JLTS- Se cambia 392 por la variable vcod_reinicio 141
         THEN
            SELECT TO_CHAR (MAX (fefecto), 'dd/mm/yyyy')
              INTO v_fefecto_mov
              FROM movseguro
             WHERE sseguro = psseguro;

            pquery :=
                  'select TO_DATE('''
               || v_fefecto_mov
               || ''', ''dd/mm/yyyy'') finicio, s.ffinal, s.ttexto from suspensionseg s where s.sseguro = '
               || psseguro
               || ' and s.cmotmov = '
               || v_motmovbloq
               || ' and s.nmovimi = '
               || '(select max(s2.nmovimi) from suspensionseg s2, movseguro m2 where s2.sseguro = '
               || psseguro
               || ' and s2.sseguro = m2.sseguro and s2.nmovimi = m2.nmovimi and m2.cmovseg <> 52 and s2.cmotmov = '
               || v_motmovbloq
               || ')';
         ELSE
            pquery :=
                  'select s.finicio, s.ffinal, s.ttexto from suspensionseg s where s.sseguro = '
               || psseguro
               || ' and s.cmotmov = '
               || v_motmovbloq
               || ' and s.nmovimi = '
               || '(select max(s2.nmovimi) from suspensionseg s2, movseguro m2 where s2.sseguro = '
               || psseguro
               || ' and s2.sseguro = m2.sseguro and s2.nmovimi = m2.nmovimi and m2.cmovseg <> 52 and s2.cmotmov = '
               || v_motmovbloq
               || ')';
         END IF;
      END IF;

      RETURN 0;                                                     -- Todo Ok
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_suspension.f_get_mov',
                      'psseguro:' || psseguro || ' pcmotmov:' || pcmotmov,
                      1,
                      SQLERRM
                     );
         RETURN 140999;
   -- Error no controlado
   END f_get_mov;

   -- funcion para recuperar que boton ense¿ar
   FUNCTION f_get_prox_mov (psseguro IN NUMBER)
      RETURN NUMBER
   IS
      wcmotmov   suspensionseg.cmotmov%TYPE;
   BEGIN
      BEGIN
         SELECT s.cmotmov
           INTO wcmotmov
           FROM suspensionseg s
          WHERE s.sseguro = psseguro
            AND s.nmovimi =
                   (SELECT MAX (s2.nmovimi)
                      FROM suspensionseg s2, movseguro m2
                     WHERE s2.sseguro = psseguro
                       AND s2.sseguro = m2.sseguro
                       AND s2.nmovimi = m2.nmovimi
                       AND m2.cmovseg <> 52);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            wcmotmov := NULL;
      END;

      IF wcmotmov IS NULL
      THEN
         RETURN (391);                                          -- suspension
      ELSIF wcmotmov = 391
      THEN
         RETURN (pac_suspension.vcod_reinicio);  -- CONF-274-25/11/2016-JLTS- reinicio - Se cambia 392 por la variable vcod_reinicio 141
      ELSIF wcmotmov = pac_suspension.vcod_reinicio -- CONF-274-25/11/2016-JLTS-  Se cambia 392 por la variable vcod_reinicio 141
      THEN
         RETURN (391);                                          -- suspension
      END IF;
   END f_get_prox_mov;

   FUNCTION f_set_mov_est (
      psseguro   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pcmotmov   IN   NUMBER
   )
      RETURN NUMBER
   IS
      num_err   NUMBER;
   BEGIN
      BEGIN
         INSERT INTO estdetmovseguro
                     (sseguro, nmovimi, cmotmov, nriesgo, cgarant, tvalora,
                      tvalord, cpregun
                     )
              VALUES (psseguro, pnmovimi, pcmotmov, 0, 0, NULL,
                      NULL, 0
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            UPDATE detmovseguro
               SET tvalora = NULL,
                   tvalord = NULL
             WHERE sseguro = psseguro
               AND nriesgo = 0
               AND cgarant = 0
               AND cpregun = 0
               AND cmotmov = pcmotmov
               AND nmovimi = pnmovimi;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_suspension.f_set_mov_est',
                      'psseguro:' || psseguro || ' pcmotmov:' || pcmotmov,
                      1,
                      SQLERRM
                     );
         RETURN 140999;
   -- Error no controlado
   END f_set_mov_est;

   FUNCTION f_tratar_certificados_reinicio (
      psseguro   IN       NUMBER,
      pfcarpro   IN       DATE,
      pfmovini   IN       DATE,
      pcmotmov   IN       NUMBER,
      pfrenova   IN       DATE,
      psproces   IN       NUMBER,
      plista     IN OUT   t_lista_id,
      pttexto    IN       VARCHAR2
   )
      RETURN NUMBER
   IS
      v_ctipreb_cert        seguros.ctipreb%TYPE;
      v_cagente_cert        seguros.cagente%TYPE;
      v_ccobban_cert        seguros.ccobban%TYPE;
      v_cempres_cert        seguros.cempres%TYPE;
      v_frenova_cert        seguros.frenova%TYPE;
      v_fcaranu_cert        seguros.fcaranu%TYPE;
      v_csituac_cert        seguros.csituac%TYPE;
      v_cforpag_cert        seguros.cforpag%TYPE;
      v_fefecto_cert        seguros.fefecto%TYPE;
      v_fcarpro_cert        seguros.fcarpro%TYPE;
      v_mens                VARCHAR2 (2000);
      v_sseguro_est         estseguros.sseguro%TYPE;
      v_nrecibo_cert        recibos.nrecibo%TYPE;
      v_siguiente_movcert   movseguro.nmovimi%TYPE;
      lsproces              NUMBER;
      num_err               NUMBER;
      ximporx               NUMBER;
      xcmodcom              NUMBER;
      -- BUG 0024450 - INICIO - DCT - 26/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS.
      v_nmovimi_0           NUMBER;
      -- BUG 0024450 - FIN - DCT - 26/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS.
      w_fsuspen             DATE;
   BEGIN
      FOR regs IN (SELECT sseguro
                     FROM seguros
                    WHERE npoliza = (SELECT npoliza
                                       FROM seguros
                                      WHERE sseguro = psseguro)
                      AND ncertif <> 0
                      AND csituac = 0)
      LOOP
         UPDATE seguros
            SET fcarpro = pfcarpro,
                frenova = NVL (pfrenova, frenova),
                fcaranu = NVL (pfrenova, fcaranu),
                nrenova = TO_CHAR (NVL (pfrenova, fcaranu), 'mmdd')
          WHERE sseguro = regs.sseguro;

         IF f_es_renovacion (regs.sseguro) = 0
         THEN
            xcmodcom := 2;
         ELSE
            xcmodcom := 1;
         END IF;

         IF pfmovini <= pfcarpro
         THEN
            SELECT ctipreb, cagente, ccobban,
                   cempres, frenova, fcaranu,
                   csituac, cforpag, fefecto,
                   fcarpro
              INTO v_ctipreb_cert, v_cagente_cert, v_ccobban_cert,
                   v_cempres_cert, v_frenova_cert, v_fcaranu_cert,
                   v_csituac_cert, v_cforpag_cert, v_fefecto_cert,
                   v_fcarpro_cert
              FROM seguros
             WHERE sseguro = regs.sseguro;

            pac_alctr126.traspaso_tablas_seguros (regs.sseguro, v_mens);

            -- Bug 27539/148894 - APD - 12/07/2013 - se busca sseguro de las
            -- tablas EST que se acaba de generar
            SELECT MAX (sseguro)
              INTO v_sseguro_est
              FROM estseguros
             WHERE ssegpol = regs.sseguro;

            num_err :=
               f_movseguro (regs.sseguro,
                            NULL,
                            pcmotmov,
                            1,
                            pfmovini,
                            NULL,
                            NULL,
                            0,
                            NULL,
                            v_siguiente_movcert,
                            f_sysdate,
                            NULL
                           );

            IF num_err <> 0
            THEN
               RETURN num_err;
            END IF;

            -- BUG 0024450 - INICIO - DCT - 26/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS.
            num_err := f_act_hisseg (regs.sseguro, v_siguiente_movcert - 1);

            IF num_err <> 0
            THEN
               RETURN num_err;
            END IF;

            BEGIN
               SELECT MAX (nmovimi)
                 INTO v_nmovimi_0
                 FROM movseguro
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               'pac_suspension.f_tratar_certificados',
                               2,
                                  'psseguro:'
                               || psseguro
                               || ' pfcarpro:'
                               || pfcarpro
                               || ' pfmovini:'
                               || pfmovini
                               || ' pcmotmov:'
                               || pcmotmov,
                               SQLERRM
                              );
                  RETURN 102819;                      --Registro no encontrado
            END;

            num_err :=
               pac_seguros.f_set_detmovsegurocol (psseguro,
                                                  v_nmovimi_0,
                                                  regs.sseguro,
                                                  v_siguiente_movcert
                                                 );

            IF num_err <> 0
            THEN
               RETURN num_err;
            END IF;

            -- BUG 0024450 - FIN - DCT - 26/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS.
            pac_alctr126.traspaso_tablas_est (v_sseguro_est,
                                              pfmovini,
                                              NULL,
                                              v_mens,
                                              'ALCTR126',
                                              NULL,
                                              v_siguiente_movcert,
                                              NULL,
                                              1
                                             );
            pac_alctr126.borrar_tablas_est (v_sseguro_est);

            /* Updateamos la fecha fin del movimiento anterior */
            UPDATE garanseg
               SET ffinefe = pfmovini
             WHERE sseguro = regs.sseguro
               AND ffinefe IS NULL
               AND nmovimi =
                      (SELECT MAX (nmovimi)
                         FROM garanseg
                        WHERE sseguro = regs.sseguro
                          AND ffinefe IS NULL
                          AND nmovimi < v_siguiente_movcert);

            UPDATE clausuesp
               SET ffinclau = pfmovini
             WHERE sseguro = regs.sseguro
               AND ffinclau IS NULL
               AND nmovimi =
                      (SELECT MAX (nmovimi)
                         FROM clausuesp
                        WHERE sseguro = regs.sseguro
                          AND ffinclau IS NULL
                          AND nmovimi < v_siguiente_movcert);

            IF pfmovini < pfcarpro
            THEN
               num_err :=
                  f_recries (v_ctipreb_cert,
                             regs.sseguro,
                             v_cagente_cert,
                             f_sysdate,
                             pfmovini,
                             pfcarpro,
                             1,
                             NULL,
                             NULL,
                             v_ccobban_cert,
                             NULL,
                             psproces,
                             0,
                             'R',
                             xcmodcom,
                             pfrenova,
                             0,
                             NULL,
                             v_cempres_cert,
                             v_siguiente_movcert,
                             v_csituac_cert,
                             ximporx
                            );

               IF num_err <> 0
               THEN
                  RETURN num_err;
               END IF;

               SELECT nrecibo
                 INTO v_nrecibo_cert
                 FROM recibos
                WHERE sseguro = regs.sseguro AND nmovimi = v_siguiente_movcert;

               plista.EXTEND;
               plista (plista.LAST) := ob_lista_id ();
               plista (plista.LAST).idd := v_nrecibo_cert;
            END IF;

            --BUG29229 - INICIO - DCT - 02/12/2013.
            BEGIN
               INSERT INTO suspensionseg
                           (sseguro, finicio, ffinal, ttexto, cmotmov,
                            nmovimi, fvigencia
                           )
                    VALUES (regs.sseguro, pfmovini, NULL, pttexto, pcmotmov,
                            v_siguiente_movcert, pfrenova
                           );
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  RETURN 9905024;
            END;

            -- recupera fecha suspension anterio al reinicio
            SELECT finicio
              INTO w_fsuspen
              FROM suspensionseg
             WHERE sseguro = regs.sseguro
               AND cmotmov = 391
               AND nmovimi =
                      (SELECT MAX (nmovimi)
                         FROM suspensionseg
                        WHERE sseguro = regs.sseguro
                          AND cmotmov = 391
                          AND nmovimi < v_siguiente_movcert);

            -- debe haber suspension anterior, se informa fin de suspension con fini reinicio
            UPDATE suspensionseg
               SET ffinal = pfmovini
             WHERE sseguro = regs.sseguro
               AND cmotmov = 391
               AND nmovimi =
                      (SELECT MAX (nmovimi)
                         FROM suspensionseg
                        WHERE sseguro = regs.sseguro
                          AND cmotmov = 391
                          AND nmovimi < v_siguiente_movcert);
         --BUG29229 - FIN - DCT - 02/12/2013.
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_suspension.f_tratar_certificados',
                      1,
                         'psseguro:'
                      || psseguro
                      || ' pfcarpro:'
                      || pfcarpro
                      || ' pfmovini:'
                      || pfmovini
                      || ' pcmotmov:'
                      || pcmotmov,
                      SQLERRM
                     );
         RETURN 140999;
   END f_tratar_certificados_reinicio;

   --BUG27048 - INICIO - DCT -11/11/2013
   FUNCTION f_genera_rec_prima_minima (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pfcarpro   IN       DATE,
      pfmovini   IN       DATE,
      psproces   IN       NUMBER,
      pnrecibo   OUT      NUMBER
   )
      RETURN NUMBER
   IS
      num_err                 NUMBER;
      v_cpregun4821           pregunpolseg.cpregun%TYPE   := 4821;
      v_crespue4821           pregunpolseg.crespue%TYPE;
      v_sseguro_0             seguros.sseguro%TYPE;
      v_importe_prorrateado   NUMBER;
      v_cprorra               productos.cprorra%TYPE;
      v_numrec                recibos.nrecibo%TYPE;
      vdifdata                NUMBER;
      v_mov                   movseguro.nmovimi%TYPE;
      mensajes                t_iax_mensajes;
      v_cforpag               seguros.cforpag%TYPE;
      v_valor                 NUMBER;
      v_sproduc               productos.sproduc%TYPE;
   BEGIN
      SELECT s.sseguro, pr.cprorra, cforpag, pr.sproduc
        INTO v_sseguro_0, v_cprorra, v_cforpag, v_sproduc
        FROM seguros s, productos pr
       WHERE s.npoliza = (SELECT npoliza
                            FROM seguros
                           WHERE sseguro = psseguro)
         AND s.ncertif = 0
         AND s.sproduc = pr.sproduc;

      SELECT NVL (MAX (nmovimi), 1)
        INTO v_mov
        FROM movseguro
       WHERE sseguro = v_sseguro_0;

      num_err :=
         pac_preguntas.f_get_pregunpolseg (v_sseguro_0,
                                           v_cpregun4821,
                                           'SEG',
                                           v_crespue4821
                                          );

      IF num_err <> 0
      THEN
         RETURN num_err;
      END IF;

----------------------
      SELECT NVL (SUM (g.iprianu / DECODE (s.cforpag, 0, 1, s.cforpag)), 0)
        INTO v_valor
        FROM garanseg g, seguros s, seguros s0
       WHERE s0.sseguro = psseguro
         AND s.npoliza = s0.npoliza
         AND s.sseguro <> s0.sseguro
         AND s.csituac = 0
         AND g.sseguro = s.sseguro
         AND g.nmovimi =
                    (SELECT MAX (g1.nmovimi)
                       FROM garanseg g1
                      WHERE g1.sseguro = g.sseguro AND g1.nriesgo = g.nriesgo);

      v_valor := f_round (v_valor, pac_monedas.f_moneda_producto (v_sproduc));

      IF v_cprorra = 1
      THEN
         --1-Pro dias reales (mod 365) (punid = 3 --> en dias)
         num_err := f_difdata (pfmovini, pfcarpro, 1, 3, vdifdata);

         IF num_err <> 0
         THEN
            RETURN num_err;
         END IF;

         v_importe_prorrateado :=
              ((NVL (v_crespue4821, 0) - NVL (v_valor, 0)) * v_cforpag
              )
            / 365
            * vdifdata;
      ELSIF v_cprorra = 2
      THEN
         --(mod 360)
         num_err := f_difdata (pfmovini, pfcarpro, 3, 3, vdifdata);

         IF num_err <> 0
         THEN
            RETURN num_err;
         END IF;

         v_importe_prorrateado :=
              ((NVL (v_crespue4821, 0) - NVL (v_valor, 0)) * v_cforpag
              )
            / 360
            * vdifdata;
      END IF;

      IF v_importe_prorrateado > 0
      THEN
         num_err :=
            pac_md_gestion_rec.f_genrec_primin_col (v_sseguro_0,
                                                    v_mov,
                                                    3,
                                                    f_sysdate,
                                                    pfmovini,
                                                    pfcarpro,
                                                    v_importe_prorrateado,
                                                    v_numrec,
                                                    'R',
                                                    psproces,
                                                    'SEG',
                                                    mensajes
                                                   );
      END IF;

      pnrecibo := v_numrec;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_suspension.f_genera_rec_prima_minima',
                      1,
                         'psseguro:'
                      || psseguro
                      || ' pfcarpro:'
                      || pfcarpro
                      || ' pfmovini:'
                      || pfmovini,
                      SQLERRM
                     );
         RETURN 140999;
   END f_genera_rec_prima_minima;

--BUG27048 - FIN - DCT -11/11/2013

   /*************************************************************************
      Funcion que realiza la insercion de los movimientos suspensi¿n/reinicio de polizas
      param in psseguro : id. de la poliza
      param in pcmotmov : codigo motivo movimiento
      param in pfmovini : fecha inicio movimiento
      param in pfrenova : fecha nueva vigencia
      param in pttexto  : descripcion del movimiento de suspensi¿n/reinicio
      param in pttexto2 : descripcion del movimiento de debloqueo/despignoarcion
      param in number default:  0- Suspende y No Trata Recibos, 1- Suspende y Trata Recibos y 2-No Suspende y Trata Recibos
      return            : Error
   *************************************************************************/
   FUNCTION f_call_set_mov (
      psseguro    IN   NUMBER,
      pcmotmov    IN   NUMBER,
      pfmovini    IN   DATE,
      pfrenova    IN   DATE,
      pttexto     IN   VARCHAR2,
      pttexto2    IN   VARCHAR2,
      ptratarec   IN   NUMBER DEFAULT 1
   )
      RETURN NUMBER
   IS
      num_err             NUMBER;
      v_sproduc           seguros.sproduc%TYPE;
      v_ncertif           seguros.ncertif%TYPE;
      v_nmovimi_0         movseguro.nmovimi%TYPE;
      v_nmovimi           movseguro.nmovimi%TYPE;
      v_situac_ant        VARCHAR2 (1000);
      v_situac_act        VARCHAR2 (1000);
      v_maxlenght         NUMBER                     := 1000;
      v_nriesgo           riesgos.nriesgo%TYPE;
      v_siguiente_mov     movseguro.nmovimi%TYPE;
      v_lista             t_lista_id                 := t_lista_id ();
      v_nrecibo_primin    recibos.nrecibo%TYPE;
      v_cempres           seguros.cempres%TYPE;
      rpend               pac_anulacion.recibos_pend;
      v_nrec_gastclon     NUMBER;
      v_nrecibo_gastos    NUMBER;
      ssmovrec            NUMBER;
      v_fefecto_min       DATE;
      v_fvencim_max       DATE;
      v_cforpag           NUMBER;
      lsproces            NUMBER;
      v_ctiprec           NUMBER;
      v_totalr            NUMBER;
      v_total_suspende    NUMBER;
      v_agrup_tiprec      NUMBER;
      v_nrec_priminclon   NUMBER;
      v_nrecibo_agrup     NUMBER;

      TYPE data_t IS TABLE OF NUMBER
         INDEX BY PLS_INTEGER;

      v_recibos_min       data_t;

      CURSOR c_rec_pend (psseguro IN NUMBER, pfmovini IN DATE)
      IS
         SELECT   r.nrecibo, r.cforpag, r.fefecto, r.fvencim, r.cagente,
                  m.fmovini, r.cempres, r.cdelega, ROWNUM - 1 contad
             FROM movrecibo m, recibos r, vdetrecibos v, seguros s
            WHERE m.nrecibo = r.nrecibo
              AND m.nrecibo = v.nrecibo
              AND s.sseguro = r.sseguro
              AND m.fmovfin IS NULL
              AND m.cestrec = 0
              AND r.sseguro = psseguro
              AND r.fvencim > pfmovini
              AND (   (    NVL (f_parproductos_v (s.sproduc,
                                                  'ADMITE_CERTIFICADOS'
                                                 ),
                                0
                               ) = 1
                       AND s.ncertif = 0
                       AND r.nrecibo NOT IN (SELECT nrecibo
                                               FROM adm_recunif)
                      )
                   OR (    NVL (f_parproductos_v (s.sproduc,
                                                  'ADMITE_CERTIFICADOS'
                                                 ),
                                0
                               ) = 1
                       AND s.ncertif <> 0
                      )
                   OR (NVL (f_parproductos_v (s.sproduc,
                                              'ADMITE_CERTIFICADOS'),
                            0
                           ) = 0
                      )
                  )
         ORDER BY contad;
   BEGIN

      SELECT ncertif, sproduc, cforpag, cempres
        INTO v_ncertif, v_sproduc, v_cforpag, v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      IF pcmotmov = 391
      THEN
         -- Suspensi¿n --
         IF     NVL (f_parproductos_v (v_sproduc, 'ADMITE_CERTIFICADOS'), 0) =
                                                                            1
            AND v_ncertif = 0
         THEN                      -- Si soy colectivo y soy un certificado 0.
            -- Suspendemos el certificado 0, pero no me toques nada de recibos (crea movimiento, suspensionseg, etc): ptratarec = 0
            num_err :=
               pac_suspension.f_set_mov (psseguro,
                                         pcmotmov,
                                         pfmovini,
                                         NULL,
                                         pttexto,
                                         pttexto2,
                                         0
                                        );

            IF num_err <> 0
            THEN
               RETURN num_err;
            ELSE
               -- Obtenemos la lista de recibos pendientes del certificado 0 que pueden estar implicados en la
               -- suspensi¿n
               FOR rec_pend IN c_rec_pend (psseguro, pfmovini)
               LOOP
                  rpend (rec_pend.contad).nrecibo := rec_pend.nrecibo;
                  rpend (rec_pend.contad).fmovini := rec_pend.fmovini;
                  rpend (rec_pend.contad).fefecto := rec_pend.fefecto;
                  rpend (rec_pend.contad).fvencim := rec_pend.fvencim;
               END LOOP;

               -- Para la lista de recibos pendientes guardo una copia en tmp_adm_recunif y borro el adm_recunif.
               -- El grabar en tmp_adm_recunif es PRAGMA para garantizar que los datos quedan grabados pese a que pudiera
               -- petar el proceso. Es necesario borrar la relaci¿n en ADM_RECUNIF para tratar los recibos de los
               -- certificados que pertenecen a un recibo agrupado.
               IF rpend.FIRST IS NOT NULL
               THEN
                  FOR i IN rpend.FIRST .. rpend.LAST
                  LOOP
                     num_err := f_graba_tmpadm_recunif (rpend (i).nrecibo, 1);

                     IF num_err <> 0
                     THEN
                        RETURN num_err;
                     END IF;
                  END LOOP;
               END IF;

               -- Obtenemos el movimiento de suspensi¿n generado en el certificado 0.
               BEGIN
                  SELECT MAX (nmovimi)
                    INTO v_nmovimi_0
                    FROM movseguro
                   WHERE sseguro =
                            (SELECT sseguro
                               FROM seguros
                              WHERE npoliza = (SELECT npoliza
                                                 FROM seguros
                                                WHERE sseguro = psseguro)
                                AND ncertif = 0);
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     p_tab_error (f_sysdate,
                                  f_user,
                                  'pac_suspension.f_call_set_mov',
                                  1,
                                     'psseguro:'
                                  || psseguro
                                  || ' pfmovini:'
                                  || pfmovini
                                  || ' pcmotmov:'
                                  || pcmotmov,
                                  SQLERRM
                                 );
                     RETURN 102819;                   --Registro no encontrado
               END;

               -- Iteramos sobre los certificados del colectivo. Vamos a generar la suspensi¿n en cada uno de ellos
               -- y tratar los recibos pendientes / cobrados que existan en esos certificados para la vigencia de cada
               -- uno de esos recibos.
               FOR regs IN (SELECT sseguro
                              FROM seguros
                             WHERE npoliza = (SELECT npoliza
                                                FROM seguros
                                               WHERE sseguro = psseguro)
                               AND ncertif <> 0
                               AND csituac = 0)
               LOOP
                  -- Suspensi¿n de cada certificado. En este caso si trata recibos, pero recibos del certificado.
                  num_err :=
                     pac_suspension.f_set_mov (regs.sseguro,
                                               pcmotmov,
                                               pfmovini,
                                               NULL,
                                               pttexto,
                                               pttexto2
                                              );

                  IF num_err <> 0
                  THEN
                     RETURN num_err;
                  ELSE
                     -- Obtener el MAX(nmovimi) de movseguro del certificado
                     BEGIN
                        SELECT MAX (nmovimi)
                          INTO v_nmovimi
                          FROM movseguro
                         WHERE sseguro = regs.sseguro;
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           RETURN 102819;            --Registro no encontrado
                     END;

                     -- insertamos en detmovsegurocol( psseguro,  v_siguiente_mov,
                     num_err :=
                        pac_seguros.f_set_detmovsegurocol (psseguro,
                                                           v_nmovimi_0,
                                                           regs.sseguro,
                                                           v_nmovimi
                                                          );

                     IF num_err <> 0
                     THEN
                        RETURN num_err;
                     END IF;

                     -- INSERT INTO detmovseguro
                     -- UPDATE detmovseguro
                     --BUG29229 - INICIO - DCT - 02/12/2013.
                     v_situac_act :=
                        SUBSTR
                           (   f_axis_literales (9904518,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                            || '. ',
                            1,
                            v_maxlenght
                           );
                     v_situac_act :=
                        SUBSTR
                           (   v_situac_act
                            || f_axis_literales (9000526,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                            || ' ( '
                            || TO_CHAR (TRUNC (pfmovini), 'dd/mm/yyyy')
                            || ' ) ',        -- BUG 0025033 - FAL - 10/12/2012
                            1,
                            v_maxlenght
                           );

                     IF pttexto IS NOT NULL
                     THEN
                        v_situac_act :=
                           SUBSTR
                              (   v_situac_act
                               || f_axis_literales
                                                (100559,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                               || ' '
                               || pttexto
                               || '.',
                               1,
                               v_maxlenght
                              );
                     END IF;

                     -- recuperar riesgo de la poliza
                     BEGIN
                        SELECT nriesgo
                          INTO v_nriesgo
                          FROM riesgos
                         WHERE sseguro = psseguro
                           AND fanulac IS NULL
                           AND nriesgo =
                                  (SELECT MIN (nriesgo)
                                     FROM riesgos
                                    WHERE sseguro = psseguro
                                      AND fanulac IS NULL);
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           BEGIN
                              SELECT nriesgo
                                INTO v_nriesgo
                                FROM riesgos
                               WHERE sseguro = psseguro
                                 AND nriesgo = (SELECT MIN (nriesgo)
                                                  FROM riesgos
                                                 WHERE sseguro = psseguro);
                           EXCEPTION
                              WHEN OTHERS
                              THEN
                                 v_nriesgo := 0;
                           END;
                     END;

                     -- Inserci¿n del detalle del movimiento
                     BEGIN
                        INSERT INTO detmovseguro
                                    (sseguro, nmovimi, cmotmov,
                                     nriesgo, cgarant, tvalora,
                                     tvalord, cpregun
                                    )
                             VALUES (regs.sseguro, v_nmovimi, pcmotmov,
                                     v_nriesgo, 0, v_situac_ant,
                                     v_situac_act, 0
                                    );
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX
                        THEN
                           UPDATE detmovseguro
                              SET tvalora = v_situac_ant,
                                  tvalord = v_situac_act
                            WHERE sseguro = regs.sseguro
                              AND nriesgo = v_nriesgo
                              AND cgarant = 0
                              AND cpregun = 0
                              AND cmotmov = pcmotmov
                              AND nmovimi = v_nmovimi;
                     END;
                  --BUG29229 - FIN - DCT - 02/12/2013.
                  END IF;
               END LOOP;

               -- Obtenemos la fecha m¿nima y m¿xima de los recibos generados. A diferencia de la emisi¿n de colectivos
               -- o cartera al final del proceso de suspensi¿n agruparemos el conjunto de recibos generados y en este caso
               -- les grabaremos la m¿nima y m¿xima del efecto. Hacerlo como la emisi¿n o cartera queda realmente raro, adem¿s,
               -- dado que la suspensi¿n siempre se suele hacer a pasado siempre actuar¿ sobre recibos cuyo efecto es inferior
               -- a la fecha de suspensi¿n y por tanto no tendriamos problemas para cobrar el nuevo recibo agrupado (recordemos
               -- que el motivo del MAX(FEFECTO) est¿ en que si grabamos el MIN luego si intentamos cobrar el recibo agrupado
               -- nos puede dar problemas al intentar cobrar los recibos peque¿itos si estos son de efecto superior)
               SELECT MIN (fefecto)
                 INTO v_fefecto_min
                 FROM recibos
                WHERE (sseguro, nmovimi) IN (
                         SELECT sseguro_cert, nmovimi_cert
                           FROM detmovsegurocol
                          WHERE sseguro_0 = psseguro
                            AND nmovimi_0 = v_nmovimi_0);

               SELECT MAX (fvencim)
                 INTO v_fvencim_max
                 FROM recibos
                WHERE (sseguro, nmovimi) IN (
                         SELECT sseguro_cert, nmovimi_cert
                           FROM detmovsegurocol
                          WHERE sseguro_0 = psseguro
                            AND nmovimi_0 = v_nmovimi_0);

               -- Reinsertamos el ADM_RECUNIF y Anulamos los recibos pendientes del certificado

               -- Realizamos un cursor los recibos de prima m¿nima que puedieran existir desde la fecha de suspensi¿n.
               -- Para cada recibo se har¿ el tratamiento de suspensi¿n / prima m¿nima. Si la vigencia del recibo de prima m¿nima
               -- est¿ dentro de la fecha de suspensi¿n se deber¿ prorratear, en caso contrario se hace un clon del recibo de prima
               -- m¿nima. Esto se hace dentro de la funci¿n: pac_suspension.f_set_mov --> f_gen_rec_partir_pdte
               FOR regs IN (SELECT r.nrecibo, r.fefecto, r.fvencim
                              FROM recibos r, detrecibos d
                             WHERE r.sseguro = psseguro
                               AND d.nrecibo = r.nrecibo
                               AND r.fvencim > pfmovini
                               AND d.cgarant = 400
                               AND d.iconcep <> 0
                               AND r.cestaux = 2
                               AND d.cconcep = 0
                               AND f_cestrec_mv (r.nrecibo, 2) IN (0, 1))
               LOOP
                  v_nrecibo_primin := regs.nrecibo;

                  IF v_nrecibo_primin IS NOT NULL
                  THEN
                     num_err :=
                        pac_suspension.f_set_mov (psseguro,
                                                  pcmotmov,
                                                  pfmovini,
                                                  NULL,
                                                  pttexto,
                                                  pttexto2,
                                                  2,
                                                  --> 2: no crees nada en movseguro, No insertes en suspensionseg, ...
                                                  v_nrecibo_primin,
                                                  v_nmovimi_0
                                                 );
                  END IF;
               END LOOP;

               --> Toma los recibos de prima minima generados en el punto anterior y los guardamos en una lista de recibos.
               FOR regs3 IN (SELECT *
                               FROM recibos
                              WHERE sseguro = psseguro
                                AND nmovimi = v_nmovimi_0)
               LOOP
                  v_lista.EXTEND;
                  v_lista (v_lista.LAST) := ob_lista_id ();
                  v_lista (v_lista.LAST).idd := regs3.nrecibo;

                  -- Cada uno de los recibos nos aseguramos que les grabamos el cestaux igual a 2. Luego los agruparemos.
                  UPDATE recibos
                     SET                           --fefecto = v_fefecto_min,
                                                   --fvencim = v_fvencim_max,
                        cestaux = 2
                   WHERE nrecibo = regs3.nrecibo;
               END LOOP;

               -- Cursor de los recibos pendientes que hemos tratado anteriormente y los volvemos a reinsertar.
               IF rpend.FIRST IS NOT NULL
               THEN
                  FOR i IN rpend.FIRST .. rpend.LAST
                  LOOP
                     num_err := f_graba_tmpadm_recunif (rpend (i).nrecibo, 2);

                     IF num_err <> 0
                     THEN
                        RETURN num_err;
                     END IF;
                  END LOOP;
               END IF;

               -- Funcionamiento de la suspensi¿n:
               --   Forma de pago anual: Si el recibo agrupado est¿ pendiente se anula y se hace un recibo desde el efecto del recibo
               --                        anulado hasta la fecha de suspensi¿n.
               --
               --   Forma de pago <> anual (mensual, trimestral, etc): El recibo agrupado puede contener recibos peque¿itos de vigencias (mensualidades)
               --                        con lo que la vigencia del recibo agrupado no refleja las vigencias que contiene. Prorratear sobre ese recibo
               --                        agrupado es un error. Por esta raz¿n, en este caso los recibos agrupados no los tocaremos y se mantienen tal cual.
               --                        lo que debemos asegurar es que al suspender los diferentes certificados vamos generando la devoluci¿n / extorno
               --                        que toque y que luego ese extorno se agrupe generando la compensaci¿n.
               --
               --  Recibos cobrados: En forma de pago anual no se tocan. En forma de pago diferente de anual se genera igualmente la devoluci¿n / extorno
               --                    por el periodo suspendido de la vigencia del recibo.
               --
               IF v_cforpag IN (0, 1)
               THEN
                  num_err :=
                     pac_anulacion.f_baja_rec_pend (pfmovini,
                                                    rpend,
                                                    1,
                                                    NULL,
                                                    pcmotmov
                                                   );

                  IF num_err <> 0
                  THEN
                     ROLLBACK;
                     RETURN num_err;
                  END IF;
               END IF;

               FOR regs2 IN (SELECT *
                               FROM detmovsegurocol
                              WHERE sseguro_0 = psseguro
                                AND nmovimi_0 = v_nmovimi_0)
               LOOP
                  -- Obtener el listado de recibos generados del certificado (los vamos insertando en la lista de recibos a agrupar
                  FOR regs3 IN (SELECT *
                                  FROM recibos
                                 WHERE sseguro = regs2.sseguro_cert
                                   AND nmovimi = regs2.nmovimi_cert)
                  LOOP
                     v_lista.EXTEND;
                     v_lista (v_lista.LAST) := ob_lista_id ();
                     v_lista (v_lista.LAST).idd := regs3.nrecibo;
                  END LOOP;
               END LOOP;

               -- Realizamos un cursor los recibos de gastos de expedici¿n que puedieran existir desde la fecha de suspensi¿n.
               -- Para cada recibo se har¿ un clon ya que los gastos se debe cobrar integramente. el tratamiento de suspensi¿n / prima m¿nima. Si la vigencia del recibo de prima m¿nima
               -- est¿ dentro de la fecha de suspensi¿n se deber¿ prorratear, en caso contrario se hace un clon del recibo de prima
               -- m¿nima. Esto se hace dentro de la funci¿n: pac_suspension.f_set_mov --> f_gen_rec_partir_pdte
               IF v_cforpag IN (0, 1)
               THEN
                  FOR regs IN (SELECT DISTINCT r.nrecibo
                                          FROM recibos r,
                                               detrecibos d,
                                               garanseg g
                                         WHERE r.sseguro = psseguro
                                           AND r.nrecibo = d.nrecibo
                                           AND r.sseguro = g.sseguro
                                           AND d.cgarant = g.cgarant
                                           AND d.nriesgo = g.nriesgo
                                           AND d.cgarant = g.cgarant
                                           AND d.cconcep = 14
                                           AND f_cestrec_mv (r.nrecibo, 2) = 2
                                           AND r.fvencim > pfmovini
                                           AND r.cestaux = 2
                                           AND d.iconcep <> 0)
                  LOOP
                     v_nrecibo_gastos := regs.nrecibo;

                     IF v_nrecibo_gastos IS NOT NULL
                     THEN
                        SELECT smovagr.NEXTVAL
                          INTO ssmovrec
                          FROM DUAL;

                        num_err :=
                           pac_adm.f_clonrecibo (1,
                                                 v_nrecibo_gastos,
                                                 v_nrec_gastclon,
                                                 ssmovrec,
                                                 NULL,
                                                 2
                                                );

                        UPDATE recibos r
                           SET nmovimi = v_nmovimi_0,
                               femisio = f_sysdate
                         WHERE nrecibo = v_nrec_gastclon;

                        v_lista.EXTEND;
                        v_lista (v_lista.LAST) := ob_lista_id ();
                        v_lista (v_lista.LAST).idd := v_nrec_gastclon;
                     END IF;
                  END LOOP;
               END IF;

               IF v_lista IS NOT NULL
               THEN
                  IF v_lista.COUNT > 0
                  THEN
                     p_tab_error (f_sysdate,
                                  f_user,
                                  'pac_suspension.f_call_set_mov',
                                  27,
                                  ' Antes de pac_gestion_rec.f_agruparecibo',
                                  NULL
                                 );
                     v_total_suspende := 0;

                     FOR reg IN v_lista.FIRST .. v_lista.LAST
                     LOOP
                        BEGIN
                           SELECT ctiprec
                             INTO v_ctiprec
                             FROM recibos
                            WHERE nrecibo = v_lista (reg).idd;

                           SELECT itotalr
                             INTO v_totalr
                             FROM vdetrecibos
                            WHERE nrecibo = v_lista (reg).idd;

                           IF v_ctiprec = 9
                           THEN
                              v_total_suspende := v_total_suspende - v_totalr;
                           ELSE
                              v_total_suspende := v_total_suspende + v_totalr;
                           END IF;
                        EXCEPTION
                           WHEN NO_DATA_FOUND
                           THEN
                              NULL;
                        END;

                        IF v_total_suspende < 0
                        THEN
                           v_agrup_tiprec := 9;
                        ELSE
                           v_agrup_tiprec := 1;
                        END IF;
                     END LOOP;

                     num_err :=
                        pac_gestion_rec.f_agruparecibo (v_sproduc,
                                                        pfmovini,
                                                        pfmovini,
                                                        v_cempres,
                                                        v_lista,
                                                        v_agrup_tiprec
                                                       );

                     IF num_err <> 0
                     THEN
                        RETURN num_err;
                     END IF;

                     BEGIN
                        SELECT nrecibo
                          INTO v_nrecibo_agrup
                          FROM recibos
                         WHERE sseguro = psseguro
                           AND nmovimi = v_nmovimi_0
                           AND cestaux = 0;

                        UPDATE recibos
                           SET fefecto = v_fefecto_min,
                               fvencim = v_fvencim_max
                         WHERE nrecibo = v_nrecibo_agrup;
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           NULL;
                     END;
                  --BUG29229 - INICIO - DCT - 13/12/2013
                  --Lo comentamos de momento
                  /*IF num_err = 0 THEN
                     num_err := pac_cesionesrea.f_cessio_det(v_sproces, psseguro, v_nrecibo_agrup,
                                                             reg_seg.cactivi, reg_seg.cramo,
                                                             reg_seg.cmodali,
                                                             reg_seg.ctipseg,
                                                             reg_seg.ccolect, v_fefecto_min,
                                                             v_fvencim_max, 1, vdecimals);
                  ELSE
                     RETURN num_err;
                  END IF;

                  IF pac_retorno.f_tiene_retorno(NULL, psseguro, NULL) = 1 THEN
                     num_err := pac_retorno.f_generar_retorno(psseguro, NULL, v_nrecibo_agrup,
                                                              NULL);

                     IF num_err <> 0 THEN
                        p_tab_error(f_sysdate, f_user,
                                    'pac_suspension.f_extorn_rec_cobrats', 1313,
                                    'psseguro:' || psseguro || ' pnmovimi:' || pnmovimi
                                    || ' num_err=' || num_err,
                                    SQLCODE || ' ' || SQLERRM);
                        RETURN num_err;
                     END IF;
                  END IF;*/
                  --BUG29229 - FIN - DCT - 13/12/2013
                  END IF;
               END IF;
            END IF;
         ELSE
            num_err :=
               pac_suspension.f_set_mov (psseguro,
                                         pcmotmov,
                                         pfmovini,
                                         NULL,
                                         pttexto,
                                         pttexto2
                                        );
         END IF;
      ELSE

         num_err :=
            pac_suspension.f_set_mov (psseguro,
                                      pcmotmov,
                                      pfmovini,
                                      pfrenova,
                                      pttexto,
                                      pttexto2
                                     );

      END IF;

      BEGIN
         SELECT MAX (nmovimi)
           INTO v_nmovimi_0
           FROM movseguro
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         'pac_suspension.f_call_set_mov',
                         1,
                            'psseguro:'
                         || psseguro
                         || ' pfmovini:'
                         || pfmovini
                         || ' pcmotmov:'
                         || pcmotmov,
                         SQLERRM
                        );
            RETURN 102819;                            --Registro no encontrado
      END;

      -- Al final de todo enviamos a JDE si todo ha ido bien.
      IF     NVL (pac_parametros.f_parempresa_n (v_cempres, 'GESTIONA_COBPAG'),
                  0
                 ) = 1
         AND num_err = 0
      THEN
         num_err :=
            pac_ctrl_env_recibos.f_proc_recpag_mov (v_cempres,
                                                    psseguro,
                                                    v_nmovimi_0,
                                                    4,
                                                    lsproces
                                                   );

         IF num_err <> 0
         THEN
            RETURN num_err;
         END IF;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_suspension.f_set_mov',
                         'psseguro:'
                      || psseguro
                      || ' pcmotmov:'
                      || pcmotmov
                      || ' pfmovini:'
                      || pfmovini
                      || ' pfrenova:'
                      || pfrenova
                      || ' pttexto2:'
                      || pttexto2,
                      1,
                      SQLERRM
                     );
         RETURN 101283;                  -- No se han podido grabar los datos.
   END f_call_set_mov;

--BUG29229 - INICIO - DCT - 09/12/2013
   FUNCTION f_trata_recibo_suspende (
      psseguro   IN   NUMBER,
      pnrecibo   IN   NUMBER,
      pfecha     IN   DATE,
      pctiprec   IN   NUMBER
   )
      RETURN NUMBER
   IS
      num_err        NUMBER;
      mensajes       t_iax_mensajes;
      vpasexec       NUMBER                   := 1;
      w_sseguro      recibos.sseguro%TYPE;
      w_cagente      recibos.cagente%TYPE;
      w_cdelega      recibos.cdelega%TYPE;
      xccobban       recibos.ccobban%TYPE;
      xcempres       recibos.cempres%TYPE;
      xnmovimi       recibos.nmovimi%TYPE;
      w_nrecclon     NUMBER;
      FINAL          BOOLEAN;
      v_fechasus     DATE;
      v_fsuspensio   DATE;
      v_freinicio    DATE;
      v_sproduc      seguros.sproduc%TYPE;
      v_cprorra      productos.cprorra%TYPE;
      v_fefecto      recibos.fefecto%TYPE;
      v_fvencim      recibos.fvencim%TYPE;
      num_err1       NUMBER;
      num_err2       NUMBER;
      dias1          NUMBER;
      dias2          NUMBER;
      nnfactor       NUMBER;
      lmensaje       NUMBER;
      psmovagr       NUMBER                   := 0;
      w_nliqmen      NUMBER;
      w_nliqlin      NUMBER;
      w_fechaux      DATE;
      v_smovagr      movrecibo.smovagr%TYPE;
   BEGIN
      BEGIN
         SELECT r.sseguro, r.cagente, r.cdelega, r.ccobban, r.cempres,
                r.nmovimi, s.sproduc
           INTO w_sseguro, w_cagente, w_cdelega, xccobban, xcempres,
                xnmovimi, v_sproduc
           FROM recibos r, seguros s
          WHERE r.sseguro = s.sseguro AND r.nrecibo = pnrecibo;
      EXCEPTION
         WHEN OTHERS
         THEN
            num_err := 101902;
      END;

      vpasexec := 2;
      --Cursor de movseguro para obtener las fechas de suspensi¿n y reinicio:
      FINAL := FALSE;
      v_fechasus := pfecha;

      WHILE NOT FINAL
      LOOP
         BEGIN
            IF pctiprec IN (1, 9)
            THEN
               SELECT fefecto
                 INTO v_fsuspensio
                 FROM movseguro
                WHERE sseguro = psseguro
                  AND fefecto > v_fechasus
                  AND cmotmov = 391
                  AND ROWNUM = 1;

               vpasexec := 3;
               v_fechasus := v_fsuspensio;

               BEGIN
                  SELECT fefecto
                    INTO v_freinicio
                    FROM movseguro
                   WHERE sseguro = psseguro
                     AND fefecto >= v_fsuspensio
                     AND cmotmov = pac_suspension.vcod_reinicio -- CONF-274-25/11/2016-JLTS- Se cambia 392 por la variable vcod_reinicio 141
                     AND ROWNUM = 1;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     v_freinicio := NULL;
               END;
            ELSE
               SELECT fefecto
                 INTO v_fsuspensio
                 FROM movseguro
                WHERE sseguro =
                         (SELECT sseguro
                            FROM seguros
                           WHERE npoliza = (SELECT npoliza
                                              FROM seguros
                                             WHERE sseguro = psseguro)
                             AND ncertif = 0)
                  AND fefecto > v_fechasus
                  AND cmotmov = 391
                  AND ROWNUM = 1;

               vpasexec := 3;
               v_fechasus := v_fsuspensio;

               BEGIN
                  SELECT fefecto
                    INTO v_freinicio
                    FROM movseguro
                   WHERE sseguro =
                            (SELECT sseguro
                               FROM seguros
                              WHERE npoliza = (SELECT npoliza
                                                 FROM seguros
                                                WHERE sseguro = psseguro)
                                AND ncertif = 0)
                     AND fefecto >= v_fsuspensio
                     AND cmotmov in pac_suspension.vcod_reinicio  -- CONF-274-25/11/2016-JLTS- Se cambia 392 por la variable vcod_reinicio 141
                     AND ROWNUM = 1;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     v_freinicio := NULL;
               END;
            END IF;

            vpasexec := 4;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               FINAL := TRUE;
         END;

         --Creamos el recibo
         w_nrecclon := pac_adm.f_get_seq_cont (xcempres);

         IF NVL (w_nrecclon, 0) = 0
         THEN
            num_err := 102876;
         END IF;

         vpasexec := 5;

         BEGIN
            INSERT INTO recibos
                        (nrecibo, cagente, cempres, nmovimi, sseguro,
                         femisio, fefecto, fvencim, ctiprec, cdelega,
                         ccobban, cestaux, nanuali, nfracci, cestimp,
                         nriesgo, cforpag, cbancar, nmovanu, cretenc,
                         pretenc, ncuacoa, ctipcoa, cestsop, cmanual,
                         nperven, ctransf, cgescob, festimp, ctipban,
                         esccero, ctipcob, creccia, cvalidado, sperson,
                         ctipapor, ctipaportante, cmodifi, ncuotar)
               SELECT w_nrecclon, cagente, cempres,
                      DECODE (pctiprec, 0, 1, nmovimi), psseguro, femisio,
                      v_fsuspensio, NVL (v_freinicio, fvencim),
                      DECODE (ctiprec, 0, 9, 1, 9, 9, 1), cdelega, ccobban,
                      cestaux, nanuali, nfracci, cestimp, nriesgo, cforpag,
                      cbancar, nmovanu, cretenc, pretenc, ncuacoa, ctipcoa,
                      cestsop, cmanual, nperven, ctransf, cgescob, festimp,
                      ctipban, esccero, ctipcob, creccia, cvalidado, sperson,
                      ctipapor, ctipaportante, cmodifi, ncuotar
                 FROM recibos
                WHERE nrecibo = pnrecibo;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'pac_suspension.f_trata_recibo_suspende',
                            1,
                               'psseguro:'
                            || psseguro
                            || ' pnrecibo:'
                            || pnrecibo
                            || ' pfecha:'
                            || pfecha,
                            SQLERRM
                           );
               RETURN SQLCODE;                         --Registro ya existente
            WHEN OTHERS
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'pac_suspension.f_trata_recibo_suspende',
                            111111,
                               'psseguro:'
                            || psseguro
                            || ' pnrecibo:'
                            || pnrecibo
                            || ' pfecha:'
                            || pfecha
                            || ' xnmovimi = '
                            || xnmovimi,
                            SQLERRM
                           );
               RETURN SQLCODE;                                             --R
         END;

         vpasexec := 6;

-->>>>>>>>>>>>>>>>>>>>>>>>>>>> 10.4.- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
         SELECT cprorra
           INTO v_cprorra
           FROM productos
          WHERE sproduc = v_sproduc;

         vpasexec := 7;

         --Obtener el efecto y vencimiento del recibo original
         SELECT fefecto, fvencim
           INTO v_fefecto, v_fvencim
           FROM recibos
          WHERE nrecibo = pnrecibo;

         vpasexec := 8;

         IF v_cprorra = 1
         THEN
            num_err1 :=
               f_difdata (v_fsuspensio,
                          NVL (v_freinicio, v_fvencim),
                          1,
                          3,
                          dias1
                         );
            num_err2 := f_difdata (v_fefecto, v_fvencim, 1, 3, dias2);
            nnfactor := dias1 / dias2;
         ELSIF v_cprorra = 2
         THEN
            num_err1 :=
               f_difdata (v_fsuspensio,
                          NVL (v_freinicio, v_fvencim),
                          3,
                          3,
                          dias1
                         );
            num_err2 := f_difdata (v_fefecto, v_fvencim, 3, 3, dias2);
            nnfactor := dias1 / dias2;
         ELSE
            nnfactor :=
                 (NVL (v_freinicio, v_fvencim) - v_fsuspensio)
               / (v_fvencim - v_fefecto);
         END IF;

         vpasexec := 9;

         --10.5
         FOR regs IN (SELECT *
                        FROM detrecibos
                       WHERE nrecibo = pnrecibo)
         LOOP
            BEGIN
               INSERT INTO detrecibos
                           (nrecibo, cconcep, cgarant,
                            nriesgo, iconcep,
                            cageven, nmovima
                           )
                    VALUES (w_nrecclon, regs.cconcep, regs.cgarant,
                            regs.nriesgo, ABS (regs.iconcep * nnfactor),
                            regs.cageven, regs.nmovima
                           );
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  UPDATE detrecibos
                     SET iconcep = iconcep + ABS (regs.iconcep * nnfactor)
                   WHERE nrecibo = w_nrecclon
                     AND cconcep = regs.cconcep
                     AND cgarant = regs.cgarant
                     AND nriesgo = regs.nriesgo;
               WHEN NO_DATA_FOUND
               THEN
                  num_err := 103469;
               WHEN OTHERS
               THEN
                  num_err := 103513;
            END;
         END LOOP;

         vpasexec := 10;

         BEGIN
            INSERT INTO recibosredcom
                        (nrecibo, cempres, cagente, ctipage, nnivel)
               SELECT w_nrecclon, cempres, cagente, ctipage, nnivel
                 FROM recibosredcom
                WHERE nrecibo = pnrecibo;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               num_err := 103909;
            WHEN DUP_VAL_ON_INDEX
            THEN
               num_err := 103907;
            WHEN OTHERS
            THEN
               num_err := 103354;
         END;

         vpasexec := 11;
         num_err := f_vdetrecibos ('R', w_nrecclon);

         IF num_err <> 0
         THEN
            lmensaje := num_err;
            num_err := 1;
            ROLLBACK;
            p_tab_error (f_sysdate,
                         f_user,
                         'pac_suspension.f_trata_recibo_suspende',
                         2,
                            'psseguro = '
                         || psseguro
                         || ' pnrecibo = '
                         || pnrecibo
                         || ' pfecha = '
                         || pfecha,
                         lmensaje
                        );
         END IF;

         SELECT smovagr.NEXTVAL
           INTO v_smovagr
           FROM DUAL;

         p_tab_error (f_sysdate,
                      f_user,
                      'Dentro pac_suspension.f_trata_recibo_suspende',
                      1,
                         'psseguro = '
                      || psseguro
                      || ' pnrecibo = '
                      || pnrecibo
                      || ' pfecha = '
                      || pfecha
                      || ' v_smovagr = '
                      || v_smovagr,
                      NULL
                     );
         num_err :=
            f_movrecibo (w_nrecclon,
                         0,
                         NULL,
                         NULL,
                         v_smovagr,
                         w_nliqmen,
                         w_nliqlin,
                         f_sysdate,
                         xccobban,
                         w_cdelega,
                         NULL,
                         w_cagente
                        );

         IF num_err <> 0
         THEN
            lmensaje := num_err;
            num_err := 1;
            ROLLBACK;
            p_tab_error (f_sysdate,
                         f_user,
                         'pac_suspension.f_trata_recibo_suspende',
                         3,
                            'psseguro = '
                         || psseguro
                         || ' pnrecibo = '
                         || pnrecibo
                         || ' pfecha = '
                         || pfecha,
                         lmensaje
                        );
         END IF;

         IF pctiprec IN (1, 9)
         THEN
            BEGIN
               SELECT fefecto
                 INTO v_fsuspensio
                 FROM movseguro
                WHERE sseguro = psseguro
                  AND fefecto > v_fsuspensio
                  AND cmotmov = 391
                  AND ROWNUM = 1;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  FINAL := TRUE;
            END;
         ELSE
            BEGIN
               SELECT fefecto
                 INTO v_fsuspensio
                 FROM movseguro
                WHERE sseguro =
                         (SELECT sseguro
                            FROM seguros
                           WHERE npoliza = (SELECT npoliza
                                              FROM seguros
                                             WHERE sseguro = psseguro)
                             AND ncertif = 0)
                  AND fefecto > v_fsuspensio
                  AND cmotmov = 391
                  AND ROWNUM = 1;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  FINAL := TRUE;
            END;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_suspension.f_trata_recibo_suspende',
                      1,
                         'psseguro:'
                      || psseguro
                      || ' pnrecibo:'
                      || pnrecibo
                      || ' pfecha:'
                      || pfecha,
                      SQLERRM
                     );
         RETURN 140999;
   END f_trata_recibo_suspende;

--BUG29229 - FIN - DCT - 09/12/2013

   --BUG29229 - INICIO - DCT - 13/12/2013
   FUNCTION f_tratar_certifs_reini_norec (
      psseguro   IN       NUMBER,
      pfcarpro   IN       DATE,
      pfmovini   IN       DATE,
      pcmotmov   IN       NUMBER,
      pfrenova   IN       DATE,
      psproces   IN       NUMBER,
      plista     IN OUT   t_lista_id,
      pttexto    IN       VARCHAR2
   )
      RETURN NUMBER
   IS
      v_ctipreb_cert        seguros.ctipreb%TYPE;
      v_cagente_cert        seguros.cagente%TYPE;
      v_ccobban_cert        seguros.ccobban%TYPE;
      v_cempres_cert        seguros.cempres%TYPE;
      v_frenova_cert        seguros.frenova%TYPE;
      v_fcaranu_cert        seguros.fcaranu%TYPE;
      v_csituac_cert        seguros.csituac%TYPE;
      v_cforpag_cert        seguros.cforpag%TYPE;
      v_fefecto_cert        seguros.fefecto%TYPE;
      v_fcarpro_cert        seguros.fcarpro%TYPE;
      v_mens                VARCHAR2 (2000);
      v_sseguro_est         estseguros.sseguro%TYPE;
      v_nrecibo_cert        recibos.nrecibo%TYPE;
      v_siguiente_movcert   movseguro.nmovimi%TYPE;
      lsproces              NUMBER;
      num_err               NUMBER;
      ximporx               NUMBER;
      xcmodcom              NUMBER;
      -- BUG 0024450 - INICIO - DCT - 26/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS.
      v_nmovimi_0           NUMBER;
      -- BUG 0024450 - FIN - DCT - 26/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS.
      w_fsuspen             DATE;
   BEGIN
      FOR regs IN (SELECT sseguro
                     FROM seguros
                    WHERE npoliza = (SELECT npoliza
                                       FROM seguros
                                      WHERE sseguro = psseguro)
                      AND ncertif <> 0
                      AND csituac = 0)
      LOOP
         pac_alctr126.traspaso_tablas_seguros (regs.sseguro, v_mens);

         -- Bug 27539/148894 - APD - 12/07/2013 - se busca sseguro de las
         -- tablas EST que se acaba de generar
         SELECT MAX (sseguro)
           INTO v_sseguro_est
           FROM estseguros
          WHERE ssegpol = regs.sseguro;

         num_err :=
            f_movseguro (regs.sseguro,
                         NULL,
                         pcmotmov,
                         1,
                         pfmovini,
                         NULL,
                         NULL,
                         0,
                         NULL,
                         v_siguiente_movcert,
                         f_sysdate,
                         NULL
                        );

         IF num_err <> 0
         THEN
            RETURN num_err;
         END IF;

         -- BUG 0024450 - INICIO - DCT - 26/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS.
         num_err := f_act_hisseg (regs.sseguro, v_siguiente_movcert - 1);

         IF num_err <> 0
         THEN
            RETURN num_err;
         END IF;

         BEGIN
            SELECT MAX (nmovimi)
              INTO v_nmovimi_0
              FROM movseguro
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'pac_suspension.f_tratar_certificados',
                            2,
                               'psseguro:'
                            || psseguro
                            || ' pfcarpro:'
                            || pfcarpro
                            || ' pfmovini:'
                            || pfmovini
                            || ' pcmotmov:'
                            || pcmotmov,
                            SQLERRM
                           );
               RETURN 102819;                         --Registro no encontrado
         END;

         num_err :=
            pac_seguros.f_set_detmovsegurocol (psseguro,
                                               v_nmovimi_0,
                                               regs.sseguro,
                                               v_siguiente_movcert
                                              );

         IF num_err <> 0
         THEN
            RETURN num_err;
         END IF;

         -- BUG 0024450 - FIN - DCT - 26/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS.
         pac_alctr126.traspaso_tablas_est (v_sseguro_est,
                                           pfmovini,
                                           NULL,
                                           v_mens,
                                           'ALCTR126',
                                           NULL,
                                           v_siguiente_movcert,
                                           NULL,
                                           1
                                          );
         pac_alctr126.borrar_tablas_est (v_sseguro_est);

         /* Updateamos la fecha fin del movimiento anterior */
         UPDATE garanseg
            SET ffinefe = pfmovini
          WHERE sseguro = regs.sseguro
            AND ffinefe IS NULL
            AND nmovimi =
                   (SELECT MAX (nmovimi)
                      FROM garanseg
                     WHERE sseguro = regs.sseguro
                       AND ffinefe IS NULL
                       AND nmovimi < v_siguiente_movcert);

         UPDATE clausuesp
            SET ffinclau = pfmovini
          WHERE sseguro = regs.sseguro
            AND ffinclau IS NULL
            AND nmovimi =
                   (SELECT MAX (nmovimi)
                      FROM clausuesp
                     WHERE sseguro = regs.sseguro
                       AND ffinclau IS NULL
                       AND nmovimi < v_siguiente_movcert);

         --BUG29229 - INICIO - DCT - 02/12/2013.
         BEGIN
            INSERT INTO suspensionseg
                        (sseguro, finicio, ffinal, ttexto, cmotmov,
                         nmovimi, fvigencia
                        )
                 VALUES (regs.sseguro, pfmovini, NULL, pttexto, pcmotmov,
                         v_siguiente_movcert, pfrenova
                        );
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               RETURN 9905024;
         END;

         -- recupera fecha suspension anterio al reinicio
         SELECT finicio
           INTO w_fsuspen
           FROM suspensionseg
          WHERE sseguro = regs.sseguro
            AND cmotmov = 391
            AND nmovimi =
                   (SELECT MAX (nmovimi)
                      FROM suspensionseg
                     WHERE sseguro = regs.sseguro
                       AND cmotmov = 391
                       AND nmovimi < v_siguiente_movcert);

         -- debe haber suspension anterior, se informa fin de suspension con fini reinicio
         UPDATE suspensionseg
            SET ffinal = pfmovini
          WHERE sseguro = regs.sseguro
            AND cmotmov = 391
            AND nmovimi =
                   (SELECT MAX (nmovimi)
                      FROM suspensionseg
                     WHERE sseguro = regs.sseguro
                       AND cmotmov = 391
                       AND nmovimi < v_siguiente_movcert);
      END LOOP;

      RETURN 0;
   END f_tratar_certifs_reini_norec;
--BUG29229 - FIN - DCT - 13/12/2013
END pac_suspension;

/