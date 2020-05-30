--------------------------------------------------------
--  DDL for Function F_BORDERO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_BORDERO" (
   pdefi IN NUMBER,
   pempresa IN NUMBER,
   pmes IN NUMBER,
   pany IN NUMBER,
   pidioma IN NUMBER,
   pproces IN NUMBER,
   ptexto OUT VARCHAR2)
   RETURN NUMBER AUTHID CURRENT_USER IS
   codi_error     NUMBER := 0;
   texto          VARCHAR2(100);
   w_proces       procesoscab.sproces%TYPE;   --25803 NUMBER(6);
   w_icomisi      movctaaux.iimport%TYPE;   --25803--NUMBER(13,2);
   w_scontra      movctaaux.scontra%TYPE;   --25803
   w_nversio      movctaaux.nversio%TYPE;   --25803
   w_ctramo       movctaaux.ctramo%TYPE;   --25803
   w_ccomrea      comisreas.ccomrea%TYPE;   --25803
   w_fefecto      comisreas.fcomini%TYPE;   --25803
   w_fvencim      comisreas.fcomfin%TYPE;   --25803
   w_cgarant      cesionesrea.cgarant%TYPE;   --25803 NUMBER(4);
   w_scomrea      NUMBER(6);
   w_sseguro      seguros.sseguro%TYPE;   --25803
   w_pcomias      detcesaux.pcomisi%TYPE;
   w_icesion      detcesaux.icesion%TYPE;
   w_icapces      detcesaux.icapces%TYPE;
   numlin         movctaaux.nnumlin%TYPE := 0;
   w_nnumlin      movctaaux.nnumlin%TYPE;
   w_cconcep      movctaaux.cconcep%TYPE;
   w_cdebhab      movctaaux.cdebhab%TYPE;
   w_cestado      movctaaux.cestado%TYPE;
   w_reserva      movctaaux.iimport%TYPE;
   w_reemb        movctaaux.iimport%TYPE;
   w_pintres      cuadroces.pintres%TYPE;
   w_int          movctaaux.iimport%TYPE;
   w_preten       paises.pretenc%TYPE;
   w_reten        movctaaux.iimport%TYPE;
   w_pcesion      detcesionesrea.pcesion%TYPE;
   w_aux          movctaaux.iimport%TYPE;
   w_pnostre      NUMBER(8, 5);
   w_plocal       tramos.plocal%TYPE;
   w_imaxplo      movctaaux.iimport%TYPE;
   w_nsegcon      contratos.scontra%TYPE;
   w_icestot      movctaaux.iimport%TYPE;
   w_icaptot      cesionesrea.icapces%TYPE;
   w_volta        NUMBER(1);
   w_iimport      movctaaux.iimport%TYPE;
   w_dataseg      siniestros.fsinies%TYPE;
   w_nriesgo      cesionesrea.nriesgo%TYPE;
   data_t         DATE;
   avui           DATE;
   cont           NUMBER(10) := 0;
   cent           NUMBER(10) := 0;

   CURSOR cur_ces IS
      SELECT   ce.scontra, ce.nversio, ce.ctramo, ce.cgarant, ce.sseguro, ce.nriesgo,
               ce.fefecto, ce.fvencim, ce.pcesion, ce.icesion, ce.icapces, ce.scesrea,
               ce.cgenera, ce.sproces, ce.nsinies, tr.cfrebor, tr.fultbor
          FROM tramos tr, cesionesrea ce, codicontratos ct
         WHERE ct.cempres = pempresa
           AND ct.scontra = ce.scontra
           AND((pdefi < 3
                AND ce.fcontab IS NULL)
               OR(pdefi = 3
                  AND ce.fcontab = LAST_DAY(TO_DATE('01' || '/' || pmes || '/' || pany,
                                                    'DD/MM/YYYY'))))
           AND ce.fefecto <= LAST_DAY(TO_DATE('01' || '/' || pmes || '/' || pany, 'DD/MM/YYYY'))
           AND ce.ctramo <> 5
           AND tr.scontra = ce.scontra
           AND tr.nversio = ce.nversio
           AND tr.ctramo = ce.ctramo
           AND(tr.fultbor IS NULL
               OR pdefi = 3
               OR(tr.cfrebor = 1
                  AND tr.fultbor < TO_DATE('01' || '/' || pmes || '/' || pany, 'DD/MM/YYYY'))
               OR(tr.cfrebor = 2
                  AND tr.fultbor < ADD_MONTHS(TO_DATE('01' || '/' || pmes || '/' || pany,
                                                      'DD/MM/YYYY'),
                                              -1))
               OR(tr.cfrebor = 3
                  AND tr.fultbor < ADD_MONTHS(TO_DATE('01' || '/' || pmes || '/' || pany,
                                                      'DD/MM/YYYY'),
                                              -2))
               OR(tr.cfrebor = 4
                  AND tr.fultbor < ADD_MONTHS(TO_DATE('01' || '/' || pmes || '/' || pany,
                                                      'DD/MM/YYYY'),
                                              -3))
               OR(tr.cfrebor = 6
                  AND tr.fultbor < ADD_MONTHS(TO_DATE('01' || '/' || pmes || '/' || pany,
                                                      'DD/MM/YYYY'),
                                              -5))
               OR(tr.cfrebor = 12
                  AND tr.fultbor < ADD_MONTHS(TO_DATE('01' || '/' || pmes || '/' || pany,
                                                      'DD/MM/YYYY'),
                                              -11)))
      ORDER BY ce.scesrea;

   CURSOR cur_cuadroces IS
      SELECT ccompani, ccomrea, icomfij, pcesion, preserv, scontra
        FROM cuadroces
       WHERE scontra = w_scontra
         AND nversio = w_nversio
         AND ctramo = w_ctramo;

   CURSOR cur_comisrea IS
      SELECT scomrea, fcomini, fcomfin
        FROM comisreas
       WHERE ccomrea = w_ccomrea
         AND fcomini <= w_fefecto
         AND(fcomfin > w_fvencim
             OR fcomfin IS NULL);

   CURSOR cur_reemb IS
      SELECT m.ccompani, m.scontra, m.nversio, m.ctramo, m.cdebhab, m.iimport, m.cestado,
             m.nnumlin
        FROM movctatecnica m, codicontratos ct
       WHERE ct.cempres = pempresa
         AND m.scontra = ct.scontra
         AND m.cconcep = 03
         AND m.fmovimi = LAST_DAY(TO_DATE('01' || '/' || pmes || '/' ||(pany - 1),
                                          'DD/MM/YYYY'));

------------------------------------------------------------------------
   FUNCTION f_buscomgarant(
      pscomrea IN NUMBER,
      psseguro IN NUMBER,
      pcgarant IN NUMBER,
      pfefecto IN DATE,
      ppcomias OUT NUMBER)
      RETURN NUMBER IS
--  ***********************************************************************
--  AQUÍ ES BUSCA EL % DE COMISSIÓ QUE CORRESPON A UN CODI DE COMISSIÓ
--  (CCOMREA), EN FUNCIÓ D'UNA GARANTIA...
-- ***********************************************************************
      codi_error     NUMBER := 0;
      w_cgaraux      NUMBER(4);
      regcontin      comcontin%ROWTYPE;
      w_fini         DATE;
      w_ffin         DATE;
      w_cduraci      seguros.cduraci%TYPE;
      w_nduraci      seguros.nduraci%TYPE;
      w_durex        comgarant.cdurdes%TYPE;
      w_edad         comgarant.canyhas%TYPE;

      CURSOR cur_comgarant1 IS
         SELECT *
           FROM comgarant
          WHERE scomrea = pscomrea
            AND cgaraux <> 0
            AND canydes <= w_edad
            AND canyhas >= w_edad
            AND cdurdes <= w_durex
            AND cdurhas >= w_durex;

      CURSOR cur_comgarant2 IS
         SELECT *
           FROM comgarant
          WHERE scomrea = pscomrea
            AND cgaraux = 0
            AND canydes <= w_edad
            AND canyhas >= w_edad
            AND cdurdes <= w_durex
            AND cdurhas >= w_durex;
   BEGIN
--       AQUÍ LLEGIM LA DATA INICIAL DEL SEGURO I LA DURACIÓ...
      BEGIN
         SELECT fefecto, fvencim, cduraci, nduraci
           INTO w_fini, w_ffin, w_cduraci, w_nduraci
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            codi_error := 101903;
            RETURN(codi_error);
         WHEN OTHERS THEN
            codi_error := 101919;
            RETURN(codi_error);
      END;

      IF w_cduraci = 0
         OR w_cduraci = 4 THEN
         w_durex := 99;
      ELSIF w_cduraci = 1 THEN
         w_durex := w_nduraci;
      ELSIF w_cduraci = 2 THEN
         w_durex := w_nduraci / 12;
      ELSIF w_cduraci = 3 THEN
         w_durex := MONTHS_BETWEEN(w_ffin, w_fini) / 12;
      END IF;

      w_edad := MONTHS_BETWEEN(pfefecto, w_fini) / 12;

--       AQUÍ LLEGIM EL COMGARANT I EL COMCONTIN...
      FOR reggar1 IN cur_comgarant1 LOOP
         IF reggar1.cgaraux = pcgarant
            AND pcgarant IS NOT NULL THEN
            ppcomias := reggar1.pcomias;

            BEGIN
               SELECT *
                 INTO regcontin
                 FROM comcontin
                WHERE scomrea = reggar1.scomrea
                  AND cgaraux = reggar1.cgaraux;

               IF TO_CHAR(pfefecto, 'MM') = 01 THEN
                  ppcomias := regcontin.pcomi01;
               ELSIF TO_CHAR(pfefecto, 'MM') = 02 THEN
                  ppcomias := regcontin.pcomi02;
               ELSIF TO_CHAR(pfefecto, 'MM') = 03 THEN
                  ppcomias := regcontin.pcomi03;
               ELSIF TO_CHAR(pfefecto, 'MM') = 04 THEN
                  ppcomias := regcontin.pcomi04;
               ELSIF TO_CHAR(pfefecto, 'MM') = 05 THEN
                  ppcomias := regcontin.pcomi05;
               ELSIF TO_CHAR(pfefecto, 'MM') = 06 THEN
                  ppcomias := regcontin.pcomi06;
               ELSIF TO_CHAR(pfefecto, 'MM') = 07 THEN
                  ppcomias := regcontin.pcomi07;
               ELSIF TO_CHAR(pfefecto, 'MM') = 08 THEN
                  ppcomias := regcontin.pcomi08;
               ELSIF TO_CHAR(pfefecto, 'MM') = 09 THEN
                  ppcomias := regcontin.pcomi09;
               ELSIF TO_CHAR(pfefecto, 'MM') = 10 THEN
                  ppcomias := regcontin.pcomi10;
               ELSIF TO_CHAR(pfefecto, 'MM') = 11 THEN
                  ppcomias := regcontin.pcomi11;
               ELSIF TO_CHAR(pfefecto, 'MM') = 12 THEN
                  ppcomias := regcontin.pcomi12;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
               WHEN OTHERS THEN
                  codi_error := 104851;
                  RETURN(codi_error);
            END;

            RETURN(codi_error);
         END IF;
      END LOOP;

      FOR reggar2 IN cur_comgarant2 LOOP
         ppcomias := reggar2.pcomias;

         BEGIN
            SELECT *
              INTO regcontin
              FROM comcontin
             WHERE scomrea = reggar2.scomrea
               AND cgaraux = reggar2.cgaraux;

            IF TO_CHAR(pfefecto, 'MM') = 01 THEN
               ppcomias := regcontin.pcomi01;
            ELSIF TO_CHAR(pfefecto, 'MM') = 02 THEN
               ppcomias := regcontin.pcomi02;
            ELSIF TO_CHAR(pfefecto, 'MM') = 03 THEN
               ppcomias := regcontin.pcomi03;
            ELSIF TO_CHAR(pfefecto, 'MM') = 04 THEN
               ppcomias := regcontin.pcomi04;
            ELSIF TO_CHAR(pfefecto, 'MM') = 05 THEN
               ppcomias := regcontin.pcomi05;
            ELSIF TO_CHAR(pfefecto, 'MM') = 06 THEN
               ppcomias := regcontin.pcomi06;
            ELSIF TO_CHAR(pfefecto, 'MM') = 07 THEN
               ppcomias := regcontin.pcomi07;
            ELSIF TO_CHAR(pfefecto, 'MM') = 08 THEN
               ppcomias := regcontin.pcomi08;
            ELSIF TO_CHAR(pfefecto, 'MM') = 09 THEN
               ppcomias := regcontin.pcomi09;
            ELSIF TO_CHAR(pfefecto, 'MM') = 10 THEN
               ppcomias := regcontin.pcomi10;
            ELSIF TO_CHAR(pfefecto, 'MM') = 11 THEN
               ppcomias := regcontin.pcomi11;
            ELSIF TO_CHAR(pfefecto, 'MM') = 12 THEN
               ppcomias := regcontin.pcomi12;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
            WHEN OTHERS THEN
               codi_error := 104851;
               RETURN(codi_error);
         END;

         RETURN(codi_error);
      END LOOP;

      RETURN(codi_error);
   END;
------------------------------------------------------------------------
BEGIN
-- AQUÍ LLEGEIXO ELS MOVIMENTS DE CESIONESREA AFECTATS I CREO DETCESIONESREA
-- AMB DADES DE COMISSIONS,ETC...
   w_proces := pproces;

   FOR regces IN cur_ces LOOP
      w_scontra := regces.scontra;
      w_nversio := regces.nversio;
      w_ctramo := regces.ctramo;
      w_fefecto := regces.fefecto;
      w_fvencim := regces.fvencim;
      w_cgarant := regces.cgarant;
      w_sseguro := regces.sseguro;
      w_nriesgo := regces.nriesgo;

-- AQUÍ ES MIRA SI ES UNA CESSIÓ DEL TRAM 1 AMB UN LÍMIT MÀXIM DE RETENCIÓ
-- PER PART NOSTRE ( IMAXPLO DE TRAM 1 INFORMAT)...
-- SI ES UN PAGAMENT DE SINISTRE (CGENERA = 2) I PERTANY AL TRAM 1 D'UN
-- CONTRACTE AMB IMAXPLO, BUSCA ELS % REALS DE LA CESSIÓ ORIGINAL EN EL
-- ÚNIC LLOC ON ES GUARDEN, ES A DIR A LA TAULA DETCESIONESREA ( EN UN
-- PAGAMENT DE SINISTRE, HEM GUARDAT EL SCESREA ORIGINAL DE LA CESSIÓ DE
-- EN EL CAMP SPROCES DE CESIONESREA)...
-- TAMBÉ ES MIRA SI HI HA UN CONTRACTE SECUNDARI QUE CUBREIXI LA NOSTRE
-- PARTICIPACIÓ EN UN "QUOTA PART"...
      IF regces.ctramo = 1 THEN
         BEGIN
            SELECT plocal, imaxplo, nsegcon
              INTO w_plocal, w_imaxplo, w_nsegcon
              FROM tramos
             WHERE scontra = regces.scontra
               AND nversio = regces.nversio
               AND ctramo = 1;
         EXCEPTION
            WHEN OTHERS THEN
               codi_error := 104714;
               ptexto := SQLERRM || '-' || TO_CHAR(regces.scesrea);
               RETURN(codi_error);
         END;
      ELSE
         w_plocal := NULL;
         w_imaxplo := NULL;
         w_nsegcon := NULL;
      END IF;

-- AQUÍ ES PREPAREN ELS CAMPS PER CRIDAR EL DESGLÓS PER COMPANYIES (UN SOL
-- COP, SI NO HI HA CONTRACTE SECUNDARI, O DOS COPS SI ES TRAM 1 I HI HA UN
-- CONTRACTE SECUNDARI (NSEGCON))...
      w_icestot := regces.icesion;
      w_icaptot := regces.icapces;

      IF w_nsegcon IS NOT NULL THEN
         w_volta := 0;

         IF regces.cgenera = 2 THEN   -- SI ES UN PAGAMENT,AGAFEN LA
            BEGIN   -- LA DATA DEL SINISTRE...
               SELECT fsinies
                 INTO w_dataseg
                 FROM siniestros
                WHERE nsinies = regces.nsinies;
            EXCEPTION
               WHEN OTHERS THEN
                  codi_error := 105144;
                  ptexto := SQLERRM || ' 1-' || TO_CHAR(regces.scesrea);
                  RETURN(codi_error);
            END;
         ELSE
            w_dataseg := w_fefecto;
         END IF;

         BEGIN
            SELECT nversio
              INTO w_nversio
              FROM contratos
             WHERE scontra = w_nsegcon
               AND fconini <= w_dataseg
               AND(fconfin > w_dataseg
                   OR fconfin IS NULL);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               w_volta := 1;
            WHEN OTHERS THEN
               codi_error := 104704;
               ptexto := SQLERRM || ' 1-' || TO_CHAR(regces.scesrea);
               RETURN(codi_error);
         END;
      ELSE
         w_volta := 1;
      END IF;

      WHILE w_volta < 2 LOOP
         IF w_volta = 0 THEN
            w_icestot := (w_icestot * w_plocal) / 100;
            w_icaptot := (w_icaptot * w_plocal) / 100;
            w_ctramo := 1;
            w_scontra := w_nsegcon;

            BEGIN
               SELECT nversio
                 INTO w_nversio
                 FROM contratos
                WHERE scontra = w_nsegcon
                  AND fconini <= w_dataseg
                  AND(fconfin > w_dataseg
                      OR fconfin IS NULL);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  codi_error := 105786;
                  ptexto := SQLERRM || '-' || TO_CHAR(regces.scesrea);
                  RETURN(codi_error);
               WHEN OTHERS THEN
                  codi_error := 104704;
                  ptexto := SQLERRM || ' 2-' || TO_CHAR(regces.scesrea);
                  RETURN(codi_error);
            END;
         ELSE
            w_scontra := regces.scontra;
            w_nversio := regces.nversio;
            w_ctramo := regces.ctramo;
            w_icestot := regces.icesion;
            w_icaptot := regces.icapces;
         END IF;

         w_volta := w_volta + 1;

         FOR regcia IN cur_cuadroces LOOP
            w_pcesion := regcia.pcesion;

            IF NVL(w_imaxplo, 0) <> 0 THEN
               IF regces.cgenera <> 2 THEN
                  w_aux := (regces.icapces * w_plocal) / 100;

                  IF w_aux > w_imaxplo THEN
                     BEGIN
                        w_pnostre := (w_plocal * w_imaxplo) / w_aux;
                        w_pcesion := (regcia.pcesion *(100 - w_pnostre)) /(100 - w_plocal);
                     EXCEPTION
                        WHEN OTHERS THEN
                           codi_error := 108182;
                           ptexto := TO_CHAR(regces.scesrea);
                           RETURN(codi_error);
                     END;
                  END IF;
               ELSE
                  BEGIN
                     SELECT pcesion
                       INTO w_pcesion
                       FROM detcesionesrea
                      WHERE scesrea = regces.sproces
                        AND ccompani = regcia.ccompani;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        NULL;
                     WHEN OTHERS THEN
                        codi_error := 105769;
                        ptexto := SQLERRM || '-' || TO_CHAR(regces.scesrea);
                        RETURN(codi_error);
                  END;
               END IF;
            END IF;

            w_icomisi := 0;
            w_pcomias := 0;
            w_icesion := (w_icestot * w_pcesion) / 100;
            w_icapces := (w_icaptot * w_pcesion) / 100;

            IF regces.cgenera <> 02 THEN   -- ELS PAGAMENTS NO TENEN COMISS...
               IF regcia.icomfij IS NOT NULL THEN
                  w_icomisi := regcia.icomfij;
               ELSIF regcia.ccomrea IS NOT NULL THEN
                  w_ccomrea := regcia.ccomrea;

                  FOR curcomis IN cur_comisrea LOOP
                     codi_error := f_buscomgarant(curcomis.scomrea, w_sseguro, w_cgarant,
                                                  w_fefecto, w_pcomias);

                     IF codi_error <> 0 THEN
                        ptexto := 'BUSCOM:' || TO_CHAR(regces.scesrea);
                        RETURN(codi_error);
                     END IF;
                  END LOOP;

                  IF w_pcomias IS NOT NULL THEN
                     w_icomisi := (((w_icestot * w_pcesion) / 100) * w_pcomias) / 100;
                  END IF;
               END IF;

               IF codi_error = 0 THEN
                  BEGIN
                     INSERT INTO detcesaux
                                 (scesrea, ccompani, pcesion, icesion,
                                  pcomisi, icomisi, sproces, icapces, scontra,
                                  nversio, ctramo)
                          VALUES (regces.scesrea, regcia.ccompani, w_pcesion, w_icesion,
                                  w_pcomias, w_icomisi, pproces, w_icapces, w_scontra,
                                  w_nversio, w_ctramo);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        codi_error := 105805;
                        ptexto := SQLERRM || '-' || TO_CHAR(regces.scesrea) || '-'
                                  || regcia.ccompani;
                        RETURN(codi_error);
                     WHEN OTHERS THEN
                        codi_error := 105804;
                        ptexto := SQLERRM || '-' || TO_CHAR(regces.scesrea) || '-'
                                  || regcia.ccompani;
                        RETURN(codi_error);
                  END;
               END IF;
            END IF;

/*
-- AQUÍ CRIDEM A LA FUNCIÓ "F_REASEGURO" PER OMPLIR LA TAULA PER EL MARGE
-- BRUT...
           IF PDEFI = 2 AND REGCES.CGENERA <> 2 THEN
              DATA_T := LAST_DAY(TO_DATE('01'||'/'||PMES||'/'||
                                 PANY,'DD/MM/YYYY'));
              AVUI   := F_SYSDATE;
              CODI_ERROR := F_REASEGURO(W_SSEGURO,W_NRIESGO,PPROCES,
                                        DATA_T,AVUI,W_ICESION,W_ICOMISI);
              IF CODI_ERROR <> 0 THEN
                PTEXTO := 'F_REASEGURO:'||TO_CHAR(REGCES.SCESREA);
                RETURN(CODI_ERROR);
               END IF;
           END IF;
*/
-- AQUÍ ES CREA EL COMPTE TÈCNIC...
--         AQUÍ BUSQUEM EL ÚLTIM NNUMLIN...
            BEGIN
               SELECT NVL(MAX(nnumlin), 0)
                 INTO w_nnumlin
                 FROM movctaaux
                WHERE scontra = w_scontra
                  AND nversio = w_nversio
                  AND ctramo = w_ctramo
                  AND ccompani = regcia.ccompani;

               w_nnumlin := w_nnumlin + 1;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  w_nnumlin := 1;
               WHEN OTHERS THEN
                  codi_error := 104863;
                  ptexto := SQLERRM || '-' || TO_CHAR(regces.scesrea) || '-'
                            || regcia.ccompani;
                  RETURN(codi_error);
            END;

--         AQUÍ BUSQUEN L'ESTAT DEL COMPTE A CTATECNICA...
            BEGIN
               SELECT cestado
                 INTO w_cestado
                 FROM ctatecnica
                WHERE scontra = w_scontra
                  AND nversio = w_nversio
                  AND ctramo = w_ctramo
                  AND ccompani = regcia.ccompani;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  codi_error := 104865;
                  ptexto := SQLERRM || '-' || TO_CHAR(regces.scesrea) || '-'
                            || regcia.ccompani;
                  RETURN(codi_error);
               WHEN OTHERS THEN
                  codi_error := 104866;
                  ptexto := SQLERRM || '-' || TO_CHAR(regces.scesrea) || '-'
                            || regcia.ccompani;
                  RETURN(codi_error);
            END;

            IF regces.cgenera = 02 THEN
               w_cdebhab := 1;
               w_cconcep := 05;
            ELSE
               w_cdebhab := 2;
               w_cconcep := 01;
            END IF;

--         AQUÍ FEM REALMENT EL INSERT DE LA CESSIÓ O DEL PAGAMENT SINISTRE...
            BEGIN
               SELECT iimport
                 INTO w_iimport
                 FROM movctaaux
                WHERE scontra = w_scontra
                  AND nversio = w_nversio
                  AND ctramo = w_ctramo
                  AND ccompani = regcia.ccompani
                  AND cconcep = w_cconcep;

               w_iimport := w_iimport + w_icesion;

               UPDATE movctaaux
                  SET iimport = w_iimport
                WHERE scontra = w_scontra
                  AND nversio = w_nversio
                  AND ctramo = w_ctramo
                  AND ccompani = regcia.ccompani
                  AND cconcep = w_cconcep;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     INSERT INTO movctaaux
                                 (ccompani, nversio, scontra, ctramo, nnumlin,
                                  fmovimi,
                                  fefecto, cconcep, cdebhab, iimport, cestado,
                                  sproces, scesrea)
                          VALUES (regcia.ccompani, w_nversio, w_scontra, w_ctramo, w_nnumlin,
                                  LAST_DAY(TO_DATE('01/' || pmes || '/' || pany, 'DD/MM/YYYY')),
                                  regces.fefecto, w_cconcep, w_cdebhab, w_icesion, w_cestado,
                                  pproces, regces.scesrea);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        codi_error := 105800;
                        ptexto := '1-' || SQLERRM || '-' || TO_CHAR(regces.scesrea) || '-'
                                  || regcia.ccompani;
                        RETURN(codi_error);
                     WHEN OTHERS THEN
                        codi_error := 105802;
                        ptexto := '1-' || SQLERRM || '-' || TO_CHAR(regces.scesrea) || '-'
                                  || regcia.ccompani;
                        RETURN(codi_error);
                  END;
               WHEN OTHERS THEN
                  codi_error := 105801;
                  ptexto := '1-' || SQLERRM || '-' || TO_CHAR(regces.scesrea) || '-'
                            || regcia.ccompani;
                  RETURN(codi_error);
            END;

--         AQUÍ ES FA EL INSERT DE LES RESERVES, SI EXISTEIXEN, A EFECTIU I
--         A DIPÒSIT...
            IF regces.cgenera <> 02
               AND regcia.preserv IS NOT NULL THEN
               w_reserva := (w_icesion * regcia.preserv) / 100;
               w_nnumlin := w_nnumlin + 1;

               BEGIN
                  SELECT iimport
                    INTO w_iimport
                    FROM movctaaux
                   WHERE scontra = w_scontra
                     AND nversio = w_nversio
                     AND ctramo = w_ctramo
                     AND ccompani = regcia.ccompani
                     AND cconcep = 03;

                  w_iimport := w_iimport + w_reserva;

                  UPDATE movctaaux
                     SET iimport = w_iimport
                   WHERE scontra = w_scontra
                     AND nversio = w_nversio
                     AND ctramo = w_ctramo
                     AND ccompani = regcia.ccompani
                     AND cconcep = 03;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                        INSERT INTO movctaaux
                                    (ccompani, nversio, scontra, ctramo,
                                     nnumlin,
                                     fmovimi,
                                     fefecto, cconcep, cdebhab, iimport, cestado, sproces,
                                     scesrea)
                             VALUES (regcia.ccompani, w_nversio, w_scontra, w_ctramo,
                                     w_nnumlin,
                                     LAST_DAY(TO_DATE('01/' || pmes || '/' || pany,
                                                      'DD/MM/YYYY')),
                                     regces.fefecto, 03, 1, w_reserva, w_cestado, pproces,
                                     regces.scesrea);
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           codi_error := 105800;
                           ptexto := '2-' || SQLERRM || '-' || TO_CHAR(regces.scesrea) || '-'
                                     || regcia.ccompani;
                           RETURN(codi_error);
                        WHEN OTHERS THEN
                           codi_error := 105802;
                           ptexto := '2-' || SQLERRM || '-' || TO_CHAR(regces.scesrea) || '-'
                                     || regcia.ccompani;
                           RETURN(codi_error);
                     END;
                  WHEN OTHERS THEN
                     codi_error := 105801;
                     ptexto := '2-' || SQLERRM || '-' || TO_CHAR(regces.scesrea) || '-'
                               || regcia.ccompani;
                     RETURN(codi_error);
               END;

               w_nnumlin := w_nnumlin + 1;

               BEGIN
                  SELECT iimport
                    INTO w_iimport
                    FROM movctaaux
                   WHERE scontra = w_scontra
                     AND nversio = w_nversio
                     AND ctramo = w_ctramo
                     AND ccompani = regcia.ccompani
                     AND cconcep = 52;

                  w_iimport := w_iimport + w_reserva;

                  UPDATE movctaaux
                     SET iimport = w_iimport
                   WHERE scontra = w_scontra
                     AND nversio = w_nversio
                     AND ctramo = w_ctramo
                     AND ccompani = regcia.ccompani
                     AND cconcep = 52;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                        INSERT INTO movctaaux
                                    (ccompani, nversio, scontra, ctramo,
                                     nnumlin,
                                     fmovimi,
                                     fefecto, cconcep, cdebhab, iimport, cestado, sproces,
                                     scesrea)
                             VALUES (regcia.ccompani, w_nversio, w_scontra, w_ctramo,
                                     w_nnumlin,
                                     LAST_DAY(TO_DATE('01/' || pmes || '/' || pany,
                                                      'DD/MM/YYYY')),
                                     regces.fefecto, 52, 2, w_reserva, w_cestado, pproces,
                                     regces.scesrea);
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           codi_error := 105800;
                           ptexto := '3-' || SQLERRM || '-' || TO_CHAR(regces.scesrea) || '-'
                                     || regcia.ccompani;
                           RETURN(codi_error);
                        WHEN OTHERS THEN
                           codi_error := 105802;
                           ptexto := '3-' || SQLERRM || '-' || TO_CHAR(regces.scesrea) || '-'
                                     || regcia.ccompani;
                           RETURN(codi_error);
                     END;
                  WHEN OTHERS THEN
                     codi_error := 105801;
                     ptexto := '3-' || SQLERRM || '-' || TO_CHAR(regces.scesrea) || '-'
                               || regcia.ccompani;
                     RETURN(codi_error);
               END;
            END IF;

--         AQUÍ ES FA EL INSERT DE LES COMISSIONS, SI EXISTEIXEN...
            IF w_icomisi <> 0 THEN
               w_nnumlin := w_nnumlin + 1;

               BEGIN
                  SELECT iimport
                    INTO w_iimport
                    FROM movctaaux
                   WHERE scontra = w_scontra
                     AND nversio = w_nversio
                     AND ctramo = w_ctramo
                     AND ccompani = regcia.ccompani
                     AND cconcep = 02;

                  w_iimport := w_iimport + w_icomisi;

                  UPDATE movctaaux
                     SET iimport = w_iimport
                   WHERE scontra = w_scontra
                     AND nversio = w_nversio
                     AND ctramo = w_ctramo
                     AND ccompani = regcia.ccompani
                     AND cconcep = 02;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                        INSERT INTO movctaaux
                                    (ccompani, nversio, scontra, ctramo,
                                     nnumlin,
                                     fmovimi,
                                     fefecto, cconcep, cdebhab, iimport, cestado, sproces,
                                     scesrea)
                             VALUES (regcia.ccompani, w_nversio, w_scontra, w_ctramo,
                                     w_nnumlin,
                                     LAST_DAY(TO_DATE('01/' || pmes || '/' || pany,
                                                      'DD/MM/YYYY')),
                                     regces.fefecto, 02, 1, w_icomisi, w_cestado, pproces,
                                     regces.scesrea);
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           codi_error := 105800;
                           ptexto := '4-' || SQLERRM || '-' || TO_CHAR(regces.scesrea) || '-'
                                     || regcia.ccompani;
                           RETURN(codi_error);
                        WHEN OTHERS THEN
                           codi_error := 105802;
                           ptexto := '4-' || SQLERRM || '-' || TO_CHAR(regces.scesrea) || '-'
                                     || regcia.ccompani;
                           RETURN(codi_error);
                     END;
                  WHEN OTHERS THEN
                     codi_error := 105801;
                     ptexto := '4-' || SQLERRM || '-' || TO_CHAR(regces.scesrea) || '-'
                               || regcia.ccompani;
                     RETURN(codi_error);
               END;
            END IF;
         END LOOP;
      END LOOP;

      IF pdefi = 2 THEN
         BEGIN
            UPDATE cesionesrea
               SET fcontab = LAST_DAY(TO_DATE('01/' || pmes || '/' || pany, 'DD/MM/YYYY'))
             WHERE scesrea = regces.scesrea;
         EXCEPTION
            WHEN OTHERS THEN
               codi_error := 104859;
               ptexto := SQLERRM || '-' || TO_CHAR(regces.scesrea);
               RETURN(codi_error);
         END;
      END IF;

      COMMIT;
   END LOOP;

-- AQUÍ ES CREAN ELS MOVIMENTS DE COMPTE TÈCNIC REFERENTS A REEMBORSAMENT
-- DE RESERVES (REEMBORSAMENT DE RESERVES, INTERESSOS SOBRE REEMBORSAMENT,
-- RETENCIÓ SOBRE INTERESSOS)...
   FOR regemb IN cur_reemb LOOP
      w_scontra := regemb.scontra;
      w_nversio := regemb.nversio;
      w_ctramo := regemb.ctramo;

      BEGIN   -- BUSQUEM EL % D'INTERESSOS I LA
         SELECT pintres
           INTO w_pintres
           FROM cuadroces
          WHERE scontra = regemb.scontra
            AND nversio = regemb.nversio
            AND ctramo = regemb.ctramo
            AND ccompani = regemb.ccompani;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            w_pintres := 0;
         WHEN OTHERS THEN
            codi_error := 104318;
            ptexto := SQLERRM || '-' || TO_CHAR(regemb.scontra) || '-'
                      || TO_CHAR(regemb.nversio) || '-' || TO_CHAR(regemb.ctramo) || '-'
                      || TO_CHAR(regemb.ccompani);
            RETURN(codi_error);
      END;

--     AQUÍ BUSQUEM EL ÚLTIM NNUMLIN...
      BEGIN
         SELECT NVL(MAX(nnumlin), 0)
           INTO w_nnumlin
           FROM movctaaux
          WHERE scontra = regemb.scontra
            AND nversio = regemb.nversio
            AND ctramo = regemb.ctramo
            AND ccompani = regemb.ccompani;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            w_nnumlin := 1;
         WHEN OTHERS THEN
            codi_error := 104863;
            ptexto := SQLERRM;
            RETURN(codi_error);
      END;

      IF regemb.cdebhab = 1 THEN   -- REEMBORSAMENT RESERVES...
         w_reemb := regemb.iimport;
      ELSE
         w_reemb := regemb.iimport * -1;
      END IF;

      BEGIN
         SELECT iimport
           INTO w_iimport
           FROM movctaaux
          WHERE scontra = w_scontra
            AND nversio = w_nversio
            AND ctramo = w_ctramo
            AND ccompani = regemb.ccompani
            AND cconcep = 06;

         w_iimport := w_iimport + w_reemb;

         UPDATE movctaaux
            SET iimport = w_iimport
          WHERE scontra = w_scontra
            AND nversio = w_nversio
            AND ctramo = w_ctramo
            AND ccompani = regemb.ccompani
            AND cconcep = 06;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            w_nnumlin := w_nnumlin + 1;

            BEGIN
               INSERT INTO movctaaux
                           (ccompani, nversio, scontra, ctramo,
                            nnumlin,
                            fmovimi,
                            fefecto,
                            cconcep, cdebhab, iimport, cestado, sproces)
                    VALUES (regemb.ccompani, regemb.nversio, regemb.scontra, regemb.ctramo,
                            w_nnumlin,
                            LAST_DAY(TO_DATE('01/' || pmes || '/' || pany, 'DD/MM/YYYY')),
                            LAST_DAY(TO_DATE('01/' || pmes || '/' || pany, 'DD/MM/YYYY')),
                            06, 2, w_reemb, regemb.cestado, pproces);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  codi_error := 105800;
                  ptexto := SQLERRM || '-' || TO_CHAR(regemb.scontra) || '-'
                            || TO_CHAR(regemb.nversio) || '-' || TO_CHAR(regemb.ctramo) || '-'
                            || TO_CHAR(regemb.ccompani);
                  RETURN(codi_error);
               WHEN OTHERS THEN
                  codi_error := 105802;
                  ptexto := SQLERRM || '-' || TO_CHAR(regemb.scontra) || '-'
                            || TO_CHAR(regemb.nversio) || '-' || TO_CHAR(regemb.ctramo) || '-'
                            || TO_CHAR(regemb.ccompani);
                  RETURN(codi_error);
            END;
         WHEN OTHERS THEN
            codi_error := 105801;
            ptexto := SQLERRM || '-' || TO_CHAR(regemb.scontra) || '-'
                      || TO_CHAR(regemb.nversio) || '-' || TO_CHAR(regemb.ctramo) || '-'
                      || TO_CHAR(regemb.ccompani);
            RETURN(codi_error);
      END;

      BEGIN
         SELECT iimport
           INTO w_iimport
           FROM movctaaux
          WHERE scontra = w_scontra
            AND nversio = w_nversio
            AND ctramo = w_ctramo
            AND ccompani = regemb.ccompani
            AND cconcep = 51;

         w_iimport := w_iimport + w_reemb;

         UPDATE movctaaux
            SET iimport = w_iimport
          WHERE scontra = w_scontra
            AND nversio = w_nversio
            AND ctramo = w_ctramo
            AND ccompani = regemb.ccompani
            AND cconcep = 51;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            w_nnumlin := w_nnumlin + 1;

            BEGIN
               INSERT INTO movctaaux
                           (ccompani, nversio, scontra, ctramo,
                            nnumlin,
                            fmovimi,
                            fefecto,
                            cconcep, cdebhab, iimport, cestado, sproces)
                    VALUES (regemb.ccompani, regemb.nversio, regemb.scontra, regemb.ctramo,
                            w_nnumlin,
                            LAST_DAY(TO_DATE('01/' || pmes || '/' || pany, 'DD/MM/YYYY')),
                            LAST_DAY(TO_DATE('01/' || pmes || '/' || pany, 'DD/MM/YYYY')),
                            51, 1, w_reemb, regemb.cestado, pproces);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  codi_error := 105800;
                  ptexto := SQLERRM || '-' || TO_CHAR(regemb.scontra) || '-'
                            || TO_CHAR(regemb.nversio) || '-' || TO_CHAR(regemb.ctramo) || '-'
                            || TO_CHAR(regemb.ccompani);
                  RETURN(codi_error);
               WHEN OTHERS THEN
                  codi_error := 105802;
                  ptexto := SQLERRM || '-' || TO_CHAR(regemb.scontra) || '-'
                            || TO_CHAR(regemb.nversio) || '-' || TO_CHAR(regemb.ctramo) || '-'
                            || TO_CHAR(regemb.ccompani);
                  RETURN(codi_error);
            END;
         WHEN OTHERS THEN
            codi_error := 105801;
            ptexto := SQLERRM || '-' || TO_CHAR(regemb.scontra) || '-'
                      || TO_CHAR(regemb.nversio) || '-' || TO_CHAR(regemb.ctramo) || '-'
                      || TO_CHAR(regemb.ccompani);
            RETURN(codi_error);
      END;

      IF w_pintres > 0 THEN
         w_int := (w_reemb * w_pintres) / 100;   -- INTERESSOS S/ RESERVES...

         BEGIN
            SELECT iimport
              INTO w_iimport
              FROM movctaaux
             WHERE scontra = w_scontra
               AND nversio = w_nversio
               AND ctramo = w_ctramo
               AND ccompani = regemb.ccompani
               AND cconcep = 04;

            w_iimport := w_iimport + w_int;

            UPDATE movctaaux
               SET iimport = w_iimport
             WHERE scontra = w_scontra
               AND nversio = w_nversio
               AND ctramo = w_ctramo
               AND ccompani = regemb.ccompani
               AND cconcep = 04;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               w_nnumlin := w_nnumlin + 1;

               BEGIN
                  INSERT INTO movctaaux
                              (ccompani, nversio, scontra,
                               ctramo, nnumlin,
                               fmovimi,
                               fefecto,
                               cconcep, cdebhab, iimport, cestado, sproces)
                       VALUES (regemb.ccompani, regemb.nversio, regemb.scontra,
                               regemb.ctramo, w_nnumlin,
                               LAST_DAY(TO_DATE('01/' || pmes || '/' || pany, 'DD/MM/YYYY')),
                               LAST_DAY(TO_DATE('01/' || pmes || '/' || pany, 'DD/MM/YYYY')),
                               04, 2, w_int, regemb.cestado, pproces);
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     codi_error := 105800;
                     ptexto := SQLERRM || '-' || TO_CHAR(regemb.scontra) || '-'
                               || TO_CHAR(regemb.nversio) || '-' || TO_CHAR(regemb.ctramo)
                               || '-' || TO_CHAR(regemb.ccompani);
                     RETURN(codi_error);
                  WHEN OTHERS THEN
                     codi_error := 105802;
                     ptexto := SQLERRM || '-' || TO_CHAR(regemb.scontra) || '-'
                               || TO_CHAR(regemb.nversio) || '-' || TO_CHAR(regemb.ctramo)
                               || '-' || TO_CHAR(regemb.ccompani);
                     RETURN(codi_error);
               END;
            WHEN OTHERS THEN
               codi_error := 105801;
               ptexto := SQLERRM || '-' || TO_CHAR(regemb.scontra) || '-'
                         || TO_CHAR(regemb.nversio) || '-' || TO_CHAR(regemb.ctramo) || '-'
                         || TO_CHAR(regemb.ccompani);
               RETURN(codi_error);
         END;

         BEGIN   -- BUSQUEM EL % DE RETENCIÓ SEGONS EL PAIS...
            SELECT p.pretenc
              INTO w_preten
              FROM paises p, companias c
             WHERE c.ccompani = regemb.ccompani
               AND p.cpais = c.cpais;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               w_preten := 0;
            WHEN OTHERS THEN
               codi_error := 105249;
               ptexto := SQLERRM || '-' || TO_CHAR(regemb.scontra) || '-'
                         || TO_CHAR(regemb.nversio) || '-' || TO_CHAR(regemb.ctramo) || '-'
                         || TO_CHAR(regemb.ccompani);
               RETURN(codi_error);
         END;

         IF NVL(w_preten, 0) <> 0 THEN
            w_reten := (w_int * w_preten) / 100;

            --  RETENCIÓ SOBRE INTERESSOS...
            BEGIN
               SELECT iimport
                 INTO w_iimport
                 FROM movctaaux
                WHERE scontra = w_scontra
                  AND nversio = w_nversio
                  AND ctramo = w_ctramo
                  AND ccompani = regemb.ccompani
                  AND cconcep = 07;

               w_iimport := w_iimport + w_reten;

               UPDATE movctaaux
                  SET iimport = w_iimport
                WHERE scontra = w_scontra
                  AND nversio = w_nversio
                  AND ctramo = w_ctramo
                  AND ccompani = regemb.ccompani
                  AND cconcep = 07;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  w_nnumlin := w_nnumlin + 1;

                  BEGIN
                     INSERT INTO movctaaux
                                 (ccompani, nversio, scontra,
                                  ctramo, nnumlin,
                                  fmovimi,
                                  fefecto,
                                  cconcep, cdebhab, iimport, cestado, sproces)
                          VALUES (regemb.ccompani, regemb.nversio, regemb.scontra,
                                  regemb.ctramo, w_nnumlin,
                                  LAST_DAY(TO_DATE('01/' || pmes || '/' || pany, 'DD/MM/YYYY')),
                                  LAST_DAY(TO_DATE('01/' || pmes || '/' || pany, 'DD/MM/YYYY')),
                                  07, 1, w_reten, regemb.cestado, pproces);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        codi_error := 105800;
                        ptexto := SQLERRM || '-' || TO_CHAR(regemb.scontra) || '-'
                                  || TO_CHAR(regemb.nversio) || '-' || TO_CHAR(regemb.ctramo)
                                  || '-' || TO_CHAR(regemb.ccompani);
                        RETURN(codi_error);
                     WHEN OTHERS THEN
                        codi_error := 105802;
                        ptexto := SQLERRM || '-' || TO_CHAR(regemb.scontra) || '-'
                                  || TO_CHAR(regemb.nversio) || '-' || TO_CHAR(regemb.ctramo)
                                  || '-' || TO_CHAR(regemb.ccompani);
                        RETURN(codi_error);
                  END;
               WHEN OTHERS THEN
                  codi_error := 105801;
                  ptexto := SQLERRM || '-' || TO_CHAR(regemb.scontra) || '-'
                            || TO_CHAR(regemb.nversio) || '-' || TO_CHAR(regemb.ctramo) || '-'
                            || TO_CHAR(regemb.ccompani);
                  RETURN(codi_error);
            END;
         END IF;
      END IF;
   END LOOP;

   COMMIT;
   RETURN(codi_error);
EXCEPTION
   WHEN OTHERS THEN
      codi_error := 99;
      ptexto := SQLERRM;
      RETURN(codi_error);
END;

/

  GRANT EXECUTE ON "AXIS"."F_BORDERO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_BORDERO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_BORDERO" TO "PROGRAMADORESCSI";
