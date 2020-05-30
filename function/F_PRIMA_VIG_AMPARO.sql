/* Formatted on 2020/04/28 12:52 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FUNCTION f_prima_vig_amparo (
   psseguro            NUMBER,
   pcgarant            NUMBER,
   pefecto             DATE,
   pnriesgo            NUMBER,
   pnmovimiant         NUMBER,
   pnmovimi            NUMBER,
   pxiprianu           NUMBER,
   pxxiprianu          NUMBER,
   xnasegur            NUMBER,
   perror        OUT   NUMBER
)
   RETURN NUMBER
IS
   /* ******************************************************************
   Funcin que retorna el valor a cobrar en el recibo por vigencia

   Ver        Fecha        Autor             Descripcin
   ---------  ----------  -------  -------------------------------------
   1.0        19/04/2016  FCAMPOS  1. Creacin de la funcin.
   2.0        01/08/2019  DFRP     2. IAXIS-3979: Primas mnimas en endosos
   3.0        18/09/2019  ECP      3. IAXIS-4985. Tarifa Endosos
   4.0        10/10/2019  CJMR     4. IAXIS-5418. Tarifación amparos Postcontractuales
   5.0        23/10/2019  ECP      5. IAXIS-5267. Tasa Manual Cumplimiento Nueva y Suplemento
   6.0        29/10/2019  ECP      6. IAXIS-4985. Tarifa Endosos
   7.0        12/12/2019  ECP      7. IAXIS-5267. Tasa Manual Cumplimiento Nueva y Suplemento
   8.0        02/01/2020  CJMR     8. IAXIS-4205. Endosos RC: Ajuste para producto RC Derivado de Contrato prorratee la tarifa.
   9.0        22/01/2020  CJMR     9. IAXIS-3394. Solución bug 11906
   *********************************************************************/
   --
   vprimaprorrata       NUMBER;
   vobj                 VARCHAR2 (200)            := 'f_prima_vig_amparo';
   xxcgarant            NUMBER;
   xxnriesgo            NUMBER;
   xxfinivig            DATE;
   xxffinvig            DATE;
   xcgarant             NUMBER;
   xnriesgo             NUMBER;
   xfinivig             DATE;
   xffinvig             DATE;
   diastotalaumento     NUMBER;
   diastotalvigencia    NUMBER;
   -- Ini IAXIS - 4985 -- ECP --  09/10/2019
   diastotalaumento1    NUMBER;
   diastotalvigencia1   NUMBER;
   diasprorrata1        NUMBER;
   -- Ini IAXIS - 4985 -- ECP --  29/10/2019
   diasprorroga         NUMBER;
   -- Fin IAXIS - 4985 -- ECP --  09/10/2019
   diasprorrata         NUMBER;
   error                NUMBER;
   xdifdias             NUMBER;
   primaprorrata        NUMBER;
   primaprorrata_1      NUMBER;
   primaprorrata_2      NUMBER;
   difdias              NUMBER;
   v_finivig            DATE;
   v_ffinvig            DATE;
   xxcapital            NUMBER;
   xxitarifa            NUMBER;
   xxipridev            NUMBER;
   n_prima_min          NUMBER;
   alta_garantia        BOOLEAN                   := FALSE;
   -- Inicio IAXIS-3979 01/08/2019
   vctipage             NUMBER;
   vcpadre              NUMBER;
   vcagente             NUMBER;
   -- Fin IAXIS-3979 01/08/2019
   --Ini IAXIS - 4985 -- ECP -- 18/09/2019
   v_cmotmov            motmovseg.cmotmov%TYPE;
   v_sproduc            seguros.sproduc%TYPE;
--Ini IAXIS - 4985 -- ECP -- 18/09/2019
   -- INI IAXIS-5418 CJMR 10/10/2019
   v_cactivi            seguros.cactivi%TYPE;
   v_extcontractual     NUMBER                    := NULL;
   v_tarifa_0           NUMBER                    := 0;
   v_dias_ini           NUMBER                    := 0;
   v_meses_ini          NUMBER                    := 0;
   v_anios_ini          NUMBER                    := 0;
   v_dias_fin           NUMBER                    := 0;
   v_meses_fin          NUMBER                    := 0;
   v_anios_fin          NUMBER                    := 0;
   v_crespue2883old     FLOAT;
   v_crespue2883new     FLOAT;
   v_sseguronew         estseguros.sseguro%TYPE;
   -- FIN IAXIS-5418 CJMR 10/10/2019
   prima_manual         NUMBER;
BEGIN
   BEGIN
      SELECT cgarant, nriesgo, finivig, ffinvig, icapital,
             itarifa, ipridev
        INTO xxcgarant, xxnriesgo, xxfinivig, xxffinvig, xxcapital,
             xxitarifa, xxipridev
        FROM garanseg
       WHERE sseguro = psseguro
         AND cgarant = pcgarant
         AND nriesgo = pnriesgo
         AND nmovimi = pnmovimiant;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         alta_garantia := TRUE;
   END;

   --Ini IAXIS - 5267 -- ECP -- 12/11/2019
--Ini IAXIS - 4985 -- ECP -- 12/11/2019
   BEGIN
      SELECT cgarant, nriesgo, finivig, ffinvig
        INTO xcgarant, xnriesgo, xfinivig, xffinvig
        FROM estgaranseg g
       WHERE g.sseguro = (SELECT sseguro
                            FROM estseguros
                           WHERE ssegpol = psseguro)
         AND g.nriesgo = NVL (pnriesgo, nriesgo)
         AND cgarant = pcgarant
         AND g.nmovimi = pnmovimi;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         BEGIN
            SELECT cgarant, nriesgo, finivig, ffinvig
              INTO xcgarant, xnriesgo, xfinivig, xffinvig
              FROM garanseg
             WHERE sseguro = psseguro
               AND cgarant = pcgarant
               AND nriesgo = NVL (pnriesgo, nriesgo)
               AND nmovimi = pnmovimi;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;
   END;

   --Fin IAXIS - 5267 -- ECP -- 12/11/2019
   --Fin IAXIS - 4985 -- ECP -- 12/11/2019

   --Ini IAXIS - 4985 -- ECP -- 18/09/2019
   BEGIN
      SELECT sproduc, cactivi                    -- IAXIS-5418 CJMR 10/10/2019
        INTO v_sproduc, v_cactivi                -- IAXIS-5418 CJMR 10/10/2019
        FROM seguros
       WHERE sseguro = psseguro;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
   END;

   --Fin IAXIS - 4985 -- ECP -- 18/09/2019
   IF alta_garantia = TRUE
   THEN
      vprimaprorrata :=
                      (pxiprianu * xnasegur) - NVL (pxxiprianu * xnasegur, 0);
   ELSE
      -- INI IAXIS-5418 CJMR 10/10/2019
      BEGIN
         SELECT cvalpar
           INTO v_extcontractual
           FROM pargaranpro
          WHERE sproduc = v_sproduc
            AND cgarant = pcgarant
            AND cactivi = v_cactivi
            AND cpargar = 'EXCONTRACTUAL';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_extcontractual := 0;
      END;

      BEGIN
         SELECT cmotmov
           INTO v_cmotmov
           FROM movseguro
          WHERE sseguro = psseguro AND nmovimi = pnmovimi;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_cmotmov := pac_iax_suplementos.lstmotmov (1).cmotmov;
      END;

      -- INI IAXIS-3394 CJMR 22/01/2020
      IF v_cmotmov = 918
      THEN
         RETURN v_tarifa_0;
      ELSIF v_extcontractual IN (2) AND v_cmotmov = 915
      THEN
         --IF v_extcontractual IN (2) AND pac_iax_suplementos.lstmotmov (1).cmotmov = 915 THEN
         -- FIN IAXIS-3394 CJMR 22/01/2020
         v_dias_ini :=
                    EXTRACT (DAY FROM xfinivig)
                    - EXTRACT (DAY FROM xxfinivig);
         v_meses_ini :=
                EXTRACT (MONTH FROM xfinivig)
                - EXTRACT (MONTH FROM xxfinivig);
         v_anios_ini :=
                  EXTRACT (YEAR FROM xfinivig)
                  - EXTRACT (YEAR FROM xxfinivig);
         v_dias_fin :=
                    EXTRACT (DAY FROM xffinvig)
                    - EXTRACT (DAY FROM xxffinvig);
         v_meses_fin :=
                EXTRACT (MONTH FROM xffinvig)
                - EXTRACT (MONTH FROM xxffinvig);
         v_anios_fin :=
                  EXTRACT (YEAR FROM xffinvig)
                  - EXTRACT (YEAR FROM xxffinvig);

         BEGIN
            SELECT sseguro
              INTO v_sseguronew
              FROM estseguros
             WHERE ssegpol = psseguro;

            error :=
               pac_preguntas.f_get_pregunseg (psseguro,
                                              pnriesgo,
                                              2883,
                                              'SEG',
                                              v_crespue2883old
                                             );
            error :=
               pac_preguntas.f_get_pregunseg (v_sseguronew,
                                              pnriesgo,
                                              2883,
                                              'EST',
                                              v_crespue2883new
                                             );
         EXCEPTION
            WHEN OTHERS
            THEN
               v_crespue2883old :=
                  TO_NUMBER (pac_preguntas.ff_buscapregunseg (psseguro,
                                                              1,
                                                              2883,
                                                              pnmovimiant,
                                                              NULL
                                                             )
                            );
               v_crespue2883new :=
                  TO_NUMBER (pac_preguntas.ff_buscapregunseg (psseguro,
                                                              1,
                                                              2883,
                                                              pnmovimi,
                                                              NULL
                                                             )
                            );
         END;

         IF     (v_dias_ini = v_dias_fin)
            AND (v_meses_ini = v_meses_fin)
            AND (v_anios_ini = v_anios_fin)
            AND (v_crespue2883old = v_crespue2883new)
         THEN
            IF pac_iax_produccion.poliza.det_poliza.sproduc NOT IN
                  (8063, 80004, 80005, 80006, 80008, 80010, 80041, 80042,
                   80043)
            THEN
               RETURN v_tarifa_0;
            END IF;
         END IF;
      END IF;

      -- FIN IAXIS-5418 CJMR 10/10/2019
      error := f_difdata (xxfinivig, xxffinvig, 1, 3, difdias);

      IF error <> 0
      THEN
         RETURN error;
      END IF;

      diastotalaumento := difdias;
      diastotalaumento1 := difdias;
      error := f_difdata (xfinivig, xffinvig, 1, 3, difdias);

      IF error <> 0
      THEN
         RETURN error;
      END IF;

      diastotalvigencia := difdias;
      diastotalvigencia1 := difdias;

-----------------------------------------------DIAS PRORRATA FAC--------------------------------
      IF pefecto > xxffinvig
      THEN
         v_finivig := xxffinvig;
      ELSE
         IF pefecto < xxfinivig
         THEN
            v_finivig := xxfinivig;
         ELSE
            v_finivig := pefecto;
         END IF;
      END IF;

      IF xffinvig < xxfinivig
      THEN
         v_ffinvig := xxfinivig;
      ELSE
         IF xffinvig > xxffinvig
         THEN
            v_ffinvig := xxffinvig;
         ELSE
            v_ffinvig := xffinvig;
         END IF;
      END IF;

      --error := f_difdata(v_ffinvig, v_finivig, 1, 3, difdias);
      difdias := TRUNC (v_ffinvig - v_finivig);

      IF error <> 0
      THEN
         RETURN error;
      END IF;

      diasprorrata := difdias;
      diasprorrata1 := difdias;

      /*IF diasprorrata <= 0
      THEN
         diasprorrata := 1;--No tarifa cuando la fecha inicio y fin estaban igual
      END IF;*/
      --Ini IAXIS - 4985 -- ECP -- 18/09/2019
      IF v_sproduc IN (80007)
      THEN
         diastotalvigencia := 0;
         diastotalaumento := 0;
         diasprorrata := 1;
      END IF;

      IF xcgarant = 7000
      THEN
         diastotalvigencia := 0;
         diastotalaumento := 0;
         diasprorrata := 1;
      END IF;

--Fin IAXIS - 4985 -- ECP -- 18/09/2019
      IF diastotalvigencia = 0
      THEN
         diastotalvigencia := 1;
      END IF;

      IF diastotalaumento = 0
      THEN
         diastotalaumento := 1;
      END IF;

      primaprorrata := pxiprianu / diastotalvigencia * diastotalaumento;

-- Ini IAXIS-4985 -- ECP -- 04/10/2019
      /*primaprorrata_1 := (primaprorrata - pxxiprianu) * diasprorrata /
                         diastotalaumento;*/
      IF (diasprorrata + diastotalaumento - diastotalvigencia) = 1
      THEN
          -- Ini IAXIS-4985 -- ECP -- 10/12/2019
-- Ini IAXIS-4985 -- ECP -- 16/12/2019
         IF v_sproduc NOT IN (80007, 80009) AND (xcgarant <> 7000)
         THEN
            -- Fin IAXIS-4985 -- ECP -- 16/12/2019
            primaprorrata_1 :=
                 (primaprorrata - pxxiprianu)
               * diasprorrata1
               / diastotalvigencia1;
         ELSE
            IF diastotalvigencia1 = diastotalaumento1
            THEN
               primaprorrata_1 :=
                    (primaprorrata - pxxiprianu)
                  * diasprorrata
                  / diastotalaumento;
            ELSIF diastotalvigencia1 > diastotalaumento1
            THEN
               primaprorrata_1 := (primaprorrata - pxxiprianu);
            ELSE
               primaprorrata_1 := (primaprorrata - pxxiprianu);
            END IF;
         END IF;
      -- Ini IAXIS-4985 -- ECP -- 10/12/2019
      ELSE
         IF diastotalvigencia = diastotalaumento
         THEN
            IF TRUNC (v_finivig) = TRUNC (f_sysdate)
            THEN
               primaprorrata_1 := (primaprorrata - pxxiprianu);
            ELSE
               --Ini IAXIS - 5267 -- ECP -- 12/12/2019
               IF v_extcontractual IN (2)
               THEN
                  primaprorrata_1 := (primaprorrata - pxxiprianu);
               --Fin IAXIS - 5267 -- ECP -- 12/12/2019
               ELSE
                  primaprorrata_1 :=
                       (primaprorrata - pxxiprianu)
                     * (diasprorrata + diastotalaumento - diastotalvigencia)
                     / diastotalaumento;
               END IF;
            END IF;
         ELSIF diastotalvigencia < diastotalaumento
         THEN
            primaprorrata_1 :=
                 (primaprorrata - pxxiprianu)
               * (diasprorrata + diastotalaumento - diastotalvigencia)
               / diastotalaumento;
         ELSE
            primaprorrata_1 :=
                 (primaprorrata - pxxiprianu)
               * (diasprorrata + (diastotalvigencia - diastotalaumento))
               / diastotalaumento;
            primaprorrata_1 :=
                (primaprorrata - pxxiprianu) * diasprorrata / diastotalaumento;
         END IF;
      END IF;

      -- primaprorrata_1 :=
       --       (primaprorrata - pxxiprianu) * diasprorrata / diastotalaumento;

      -- Ini IAXIS-4985 -- ECP -- 04/10/2019
      primaprorrata_2 := pxiprianu - primaprorrata;
      vprimaprorrata := primaprorrata_1 + primaprorrata_2;
   END IF;

   IF     NVL (f_parproductos_v (v_sproduc, 'RESTA_PRIMA_ANTERIOR'), 0) = 1
      AND NVL (pac_iax_suplementos.lstmotmov (1).cmotmov, v_cmotmov) = 915
   THEN
      IF NVL (pac_iaxpar_productos.f_get_pargarantia ('PRIMA_MANUAL',
                                                      v_sproduc,
                                                      pcgarant,
                                                      NVL (v_cactivi, 0)
                                                     ),
              0
             ) = 1
      THEN
         IF pxiprianu = pxxiprianu
         THEN
            vprimaprorrata := 0;
         ELSE
            vprimaprorrata := pxiprianu;
         END IF;
      ELSE
         vprimaprorrata := pxiprianu - pxxiprianu;
      END IF;
   END IF;

   IF     NVL
             (f_parproductos_v (pac_iax_produccion.poliza.det_poliza.sproduc,
                                'PRIMA_MINIMA_SUP'
                               ),
              0
             ) = 1
      AND (NVL (f_parmotmov (NVL (pac_iax_suplementos.lstmotmov (1).cmotmov,
                                  v_cmotmov
                                 ),
                             'MOTMOV_NO_MONETARIO'
                            ),
                0
               ) = 0
          )
   THEN
      --
      -- Inicio IAXIS-3979 01/08/2019
      --
      SELECT ctipage, cpadre
        INTO vctipage, vcpadre
        FROM redcomercial
       WHERE cagente = pac_iax_produccion.poliza.det_poliza.cagente
         AND cempres = pac_iax_produccion.poliza.det_poliza.cempres
         AND fmovini <= TRUNC (f_sysdate)
         AND (fmovfin > TRUNC (f_sysdate) OR fmovfin IS NULL);

      --
      IF vctipage IN (0, 1, 2, 3)
      THEN
         vcagente := pac_iax_produccion.poliza.det_poliza.cagente;
      ELSE
         vcagente := vcpadre;
      END IF;

      --
      -- Fin IAXIS-3979 01/08/2019
      --
      n_prima_min :=
         NVL
            (pac_subtablas.f_vsubtabla
                (p_in_nsesion        => -1,
                 p_in_csubtabla      => 9000008,
                 p_in_cquery         => 33143,        -- IAXIS-3979 01/08/2019
                 p_in_cval           => 1,
                 p_in_ccla1          => pac_iax_produccion.poliza.det_poliza.sproduc,
                 p_in_ccla2          => pac_iax_produccion.poliza.det_poliza.gestion.cactivi,
                 p_in_ccla3          => NVL (vprimaprorrata, 0),
                 p_in_ccla4          => NVL (vprimaprorrata, 0),
                 p_in_ccla5          => vcagente
                ),
             99
            );                                        -- IAXIS-3979 01/08/2019

      IF n_prima_min <> 99
      THEN
         vprimaprorrata := n_prima_min;
      END IF;
   END IF;

   -- INI IAXIS-4205 CJMR 02/01/2020
   --IF pac_iax_produccion.poliza.det_poliza.sproduc in (8063, 80004, 80005, 80006, 80008, 80010, 80041, 80042, 80043, 80038) THEN
   IF    NVL (f_parproductos_v (v_sproduc, 'NO_PRORRATEA_TARIFA'), 0) = 1
      OR NVL (pac_iaxpar_productos.f_get_pargarantia ('PRIMA_MANUAL',
                                                      v_sproduc,
                                                      pcgarant,
                                                      NVL (v_cactivi, 0)
                                                     ),
              0
             ) = 1
   THEN
      -- FIN IAXIS-4205 CJMR 02/01/2020
      IF pxiprianu = pxxiprianu
      THEN
         vprimaprorrata := 0;
      ELSE
         vprimaprorrata := pxiprianu;
      END IF;
   END IF;

   p_tab_error (f_sysdate,
                f_user,
                vobj,
                1,
                1,
                   'psseguro-a->'
                || psseguro
                || ' pnmovimi     '
                || pnmovimi
                || 'v_sproduc-->'
                || v_sproduc
                || 'pxxiprianu-->'
                || pxxiprianu
                || 'primaprorrata-->'
                || primaprorrata
                || ' xfinivig-->'
                || xfinivig
                || ' xxfinivig-->'
                || xxfinivig
                || ' xffinvig-->'
                || xffinvig
                || ' xxffinvig-->'
                || xxffinvig
                || 'pxiprianu = '
                || pxiprianu
                || ' - '
                || ' xnasegur= '
                || xnasegur
                || ' xcgarant-->'
                || xcgarant
                || ' vprimaprorrata-->'
                || vprimaprorrata
                || 'primaprorrata_2-->'
                || primaprorrata_2
                || 'primaprorrata_1--> '
                || primaprorrata_1
                || 'diastotalvigencia1-->'
                || diastotalvigencia1
                || 'diastotalvigencia-->'
                || diastotalvigencia
                || 'diastotalaumento1-->'
                || diastotalaumento1
                || 'diastotalaumento-->'
                || diastotalaumento
                || ' diasprorrata1-->'
                || diasprorrata1
                || ' diasprorrata-->'
                || diasprorrata
                || ' pxiprianu-->'
                || pxiprianu
                || 'v_ffinvig'
                || v_ffinvig
                || 'v_finivig '
                || v_finivig
                || 'v_cmotmov'
                || v_cmotmov
                || 'pac_iax_suplementos.lstmotmov (1).cmotmov = 915'
                || pac_iax_suplementos.lstmotmov (1).cmotmov
               );
   RETURN vprimaprorrata;
END f_prima_vig_amparo;
/