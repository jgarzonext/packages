--------------------------------------------------------
--  DDL for Function F_BUSCA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_BUSCA" (
   psseguro IN NUMBER,
   pnmovimi IN NUMBER,
   psproces IN NUMBER,
   pmotiu IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***********************************************************************
   F_BUSCA        : Obtenció del contracte/versió de reassegurança
                       per una regularització per +-prima i +-capital.
                       Ja té l'informació a la taula auxiliar "CESIONESAUX".
      QUADRE DE CERQUES ORDENAT:
      -------------------------
      B1   Ram    Producte    Activitat   Garantía
      B2   Ram    --------    Activitat   Garantía
      B3   Ram    Producte    ---------   Garantía
      B4   Ram    --------    ---------   Garantía
      B5   Ram    Producte    Activitat   --------
      B6   Ram    --------    Activitat   --------
      B7   Ram    Producte    ---------   --------
      B8   Ram    --------    ---------   --------
      error devuelto:
         ** de 1 87 : errores varios de B.D., etc.
         ** 88      : No hace falta reaseguro
                     ( todas las garantías sin contrato;no se harán cesiones posteriores...)
         ** 99      : Hay garantías sin contrato y no hay XL o SL que ampare el ramo...
REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  -------  -------------------------------------
      1.0        XX/XX/XXXX   XXX     1. Creación de la función.
      2.0        14/05/2010   AVT     2. 14536: CRE200 - Reaseguro: Se requiere que un contrato se pueda utilizar
                                                en varias agrupaciones de producto
     3.0        26/02/2013   LCF     3.  0025803: RSA001 - Ampliar los decimales que utiliza iAXIS
***********************************************************************/
   perr           NUMBER;
   w_cempres      codicontratos.cempres%TYPE;   --25803
   w_cramo        seguros.cramo%TYPE;   --25803
   w_cmodali      seguros.cmodali%TYPE;   --25803
   w_ccolect      seguros.ccolect%TYPE;   --25803
   w_ctipseg      seguros.ctipseg%TYPE;   --25803
   w_cactivi      seguros.cactivi%TYPE;   --25803
   w_cobjase      seguros.cobjase%TYPE;   --25803
   w_nasegur      riesgos.nasegur%TYPE;
   w_iprianu      garanseg.iprianu%TYPE;
   w_icapital     cesionesaux.icapital%TYPE;
   fpolefe        contratos.fconini%TYPE;   --25803
   fpolvto        contratos.fconfin%TYPE;   --25803
   w_fconini      contratos.fconini%TYPE;   --25803
   w_fconfin      contratos.fconfin%TYPE;   --25803
   w_numlin       cesionesaux.nnumlin%TYPE;   --25803
   w_scumulo      cesionesaux.scumulo%TYPE;
   w_cestado      cesionesaux.cestado%TYPE;   --25803
   w_cfacult      cesionesaux.cfacult%TYPE;   --25803
   w_scontra      cesionesaux.scontra%TYPE;
   w_nversio      cesionesaux.nversio%TYPE;
   w_cgarant      agr_contratos.cgarant%TYPE;   --25803
   w_volta        NUMBER(1);
   w_cduraci      seguros.cduraci%TYPE;   --25803
   w_scontra2     cesionesaux.scontra%TYPE;
   w_nversio2     cesionesaux.nversio%TYPE;
   w_olvidate     NUMBER(1);
   w_creaseg      NUMBER(1);
   w_ctiprea      seguros.ctiprea%TYPE;   --NUMBER(1);--25803
   w_datainici    DATE;
   w_datafinal    DATE;
   w_dias         NUMBER;
   w_dias_origen  NUMBER;
   data_final     DATE;

   CURSOR cur_cesaux IS
      SELECT *
        FROM cesionesaux
       WHERE scontra IS NULL
         AND nversio IS NULL
         AND NVL(cfacult, 0) = 0
         AND sproces = psproces;

   CURSOR cur_cesaux2 IS
      SELECT nriesgo, cgarant, scumulo, iprirea, icapital
        FROM cesionesaux
       WHERE scontra IS NOT NULL
         AND nversio IS NOT NULL
         AND sproces = psproces;

   CURSOR cur_contra_b1 IS
      SELECT   v.scontra, v.nversio, v.fconini, v.fconfin
          FROM codicontratos c, contratos v, agr_contratos a
         WHERE c.scontra = v.scontra
           AND c.scontra = a.scontra   -- 14536 14-05-2010 AVT
           AND c.cempres = w_cempres
           AND a.cgarant = w_cgarant
           AND(c.ctiprea = 1
               OR c.ctiprea = 2)
           AND a.cramo = w_cramo
           AND a.cmodali = w_cmodali
           AND a.ctipseg = w_ctipseg
           AND a.ccolect = w_ccolect
           AND a.cactivi = w_cactivi
           AND v.fconini < fpolvto
           AND(v.fconfin IS NULL
               OR v.fconfin > fpolefe)
           AND c.nconrel IS NULL
      ORDER BY v.fconini;

   CURSOR cur_contra_b2 IS
      SELECT   v.scontra, v.nversio, v.fconini, v.fconfin
          FROM codicontratos c, contratos v, agr_contratos a
         WHERE c.scontra = v.scontra
           AND c.scontra = a.scontra   -- 14536 14-05-2010 AVT
           AND c.cempres = w_cempres
           AND a.cgarant = w_cgarant
           AND(c.ctiprea = 1
               OR c.ctiprea = 2)
           AND a.cramo = w_cramo
           AND a.cactivi = w_cactivi
           AND a.cmodali IS NULL
           AND a.ctipseg IS NULL
           AND a.ccolect IS NULL
           AND v.fconini < fpolvto
           AND(v.fconfin IS NULL
               OR v.fconfin > fpolefe)
           AND c.nconrel IS NULL
      ORDER BY v.fconini;

   CURSOR cur_contra_b3 IS
      SELECT   v.scontra, v.nversio, v.fconini, v.fconfin
          FROM codicontratos c, contratos v, agr_contratos a
         WHERE c.scontra = v.scontra
           AND c.scontra = a.scontra   -- 14536 14-05-2010 AVT
           AND c.cempres = w_cempres
           AND a.cgarant = w_cgarant
           AND(c.ctiprea = 1
               OR c.ctiprea = 2)
           AND a.cramo = w_cramo
           AND a.cmodali = w_cmodali
           AND a.ctipseg = w_ctipseg
           AND a.ccolect = w_ccolect
           AND a.cactivi IS NULL
           AND v.fconini < fpolvto
           AND(v.fconfin IS NULL
               OR v.fconfin > fpolefe)
           AND c.nconrel IS NULL
      ORDER BY v.fconini;

   CURSOR cur_contra_b4 IS
      SELECT   v.scontra, v.nversio, v.fconini, v.fconfin
          FROM codicontratos c, contratos v, agr_contratos a
         WHERE c.scontra = v.scontra
           AND c.scontra = a.scontra   -- 14536 14-05-2010 AVT
           AND c.cempres = w_cempres
           AND a.cgarant = w_cgarant
           AND(c.ctiprea = 1
               OR c.ctiprea = 2)
           AND a.cramo = w_cramo
           AND a.cactivi IS NULL
           AND a.cmodali IS NULL
           AND a.ctipseg IS NULL
           AND a.ccolect IS NULL
           AND v.fconini < fpolvto
           AND(v.fconfin IS NULL
               OR v.fconfin > fpolefe)
           AND c.nconrel IS NULL
      ORDER BY fconini;

   CURSOR cur_contra_b5 IS
      SELECT   v.scontra, v.nversio, v.fconini, v.fconfin
          FROM codicontratos c, contratos v, agr_contratos a
         WHERE c.scontra = v.scontra
           AND c.scontra = a.scontra   -- 14536 14-05-2010 AVT
           AND c.cempres = w_cempres
           AND a.cgarant IS NULL
           AND(c.ctiprea = 1
               OR c.ctiprea = 2)
           AND a.cramo = w_cramo
           AND a.cmodali = w_cmodali
           AND a.ctipseg = w_ctipseg
           AND a.ccolect = w_ccolect
           AND a.cactivi = w_cactivi
           AND v.fconini < fpolvto
           AND(v.fconfin IS NULL
               OR v.fconfin > fpolefe)
           AND c.nconrel IS NULL
      ORDER BY fconini;

   CURSOR cur_contra_b6 IS
      SELECT   v.scontra, v.nversio, v.fconini, v.fconfin
          FROM codicontratos c, contratos v, agr_contratos a
         WHERE c.scontra = v.scontra
           AND c.scontra = a.scontra   -- 14536 14-05-2010 AVT
           AND c.cempres = w_cempres
           AND a.cgarant IS NULL
           AND(c.ctiprea = 1
               OR c.ctiprea = 2)
           AND a.cramo = w_cramo
           AND a.cmodali IS NULL
           AND a.ctipseg IS NULL
           AND a.ccolect IS NULL
           AND a.cactivi = w_cactivi
           AND v.fconini < fpolvto
           AND(v.fconfin IS NULL
               OR v.fconfin > fpolefe)
           AND c.nconrel IS NULL
      ORDER BY fconini;

   CURSOR cur_contra_b7 IS
      SELECT   v.scontra, v.nversio, v.fconini, v.fconfin
          FROM codicontratos c, contratos v, agr_contratos a
         WHERE c.scontra = v.scontra
           AND c.scontra = a.scontra   -- 14536 14-05-2010 AVT
           AND c.cempres = w_cempres
           AND a.cgarant IS NULL
           AND(c.ctiprea = 1
               OR c.ctiprea = 2)
           AND a.cramo = w_cramo
           AND a.cmodali = w_cmodali
           AND a.ctipseg = w_ctipseg
           AND a.ccolect = w_ccolect
           AND a.cactivi IS NULL
           AND v.fconini < fpolvto
           AND(v.fconfin IS NULL
               OR v.fconfin > fpolefe)
           AND c.nconrel IS NULL
      ORDER BY fconini;

   CURSOR cur_contra_b8 IS
      SELECT   v.scontra, v.nversio, v.fconini, v.fconfin
          FROM codicontratos c, contratos v, agr_contratos a
         WHERE c.scontra = v.scontra
           AND c.scontra = a.scontra   -- 14536 14-05-2010 AVT
           AND c.cempres = w_cempres
           AND a.cgarant IS NULL
           AND(c.ctiprea = 1
               OR c.ctiprea = 2)
           AND a.cramo = w_cramo
           AND a.cmodali IS NULL
           AND a.ctipseg IS NULL
           AND a.ccolect IS NULL
           AND a.cactivi IS NULL
           AND v.fconini < fpolvto
           AND(v.fconfin IS NULL
               OR v.fconfin > fpolefe)
           AND c.nconrel IS NULL
      ORDER BY fconini;

   CURSOR cur_contra_xlsl IS
      SELECT   v.scontra, v.nversio
          FROM codicontratos c, contratos v, agr_contratos a
         WHERE c.scontra = v.scontra
           AND c.scontra = a.scontra   -- 14536 14-05-2010 AVT
           AND c.cempres = w_cempres
           AND a.cgarant IS NULL
           AND(c.ctiprea = 3
               OR c.ctiprea = 4)
           AND a.cramo = w_cramo
           AND(a.cmodali = w_cmodali
               OR a.cmodali IS NULL)
           AND(a.ctipseg = w_ctipseg
               OR a.ctipseg IS NULL)
           AND(a.ccolect = w_ccolect
               OR a.ccolect IS NULL)
           AND a.cactivi IS NULL
           AND v.fconini < fpolvto
           AND(v.fconfin IS NULL
               OR v.fconfin > fpolefe)
           AND c.nconrel IS NULL
      ORDER BY fconini;
BEGIN
   SAVEPOINT reaseguro;
   perr := 0;

------------------------------------------------------------------
   BEGIN
      SELECT MAX(nnumlin)
        INTO w_numlin
        FROM cesionesaux
       WHERE sproces = psproces;
   END;

-- DADES GENERALS DEL SEGURO...
   BEGIN
      SELECT s.cramo, s.cmodali, s.ccolect, s.ctipseg, s.cactivi, r.cempres, s.creafac,
             s.cobjase, s.ctiprea, s.cduraci
        INTO w_cramo, w_cmodali, w_ccolect, w_ctipseg, w_cactivi, w_cempres, w_cfacult,
             w_cobjase, w_ctiprea, w_cduraci
        FROM seguros s, codiram r
       WHERE s.sseguro = psseguro
         AND s.cramo = r.cramo;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         perr := 101903;
         RETURN(perr);
      WHEN OTHERS THEN
         perr := 101919;
         RETURN(perr);
   END;

-- AQUI ANEM A EFECTUAR LES CERQUES SUCCESSIVES, PER CADA GARANTIA SENSE
-- CONTRACTE ASSIGNAT, SEGONS EL QUADRE EXPOST EN ELS COMENTARIS INICIALS...
-- ES FA UNA CERCA PER TOTES LES GARANTIES I DESPRES ES PASSA, SI FA FALTA,
-- A LA SEGÜENT CERCA...
-- CERCA B1...
-- ********
   FOR regcesion IN cur_cesaux   -- llegim les garanties sense contracte...
                              LOOP
      w_cgarant := regcesion.cgarant;
      w_volta := 0;
      fpolefe := regcesion.fconini;
      fpolvto := regcesion.fconfin;
      w_cestado := 0;

      FOR regcontrato IN cur_contra_b1 LOOP
         IF regcontrato.fconini <= fpolefe THEN
            w_fconini := fpolefe;
         ELSE
            w_fconini := regcontrato.fconini;
         END IF;

         IF regcontrato.fconfin IS NOT NULL
            AND regcontrato.fconfin <= fpolvto THEN
            w_fconfin := regcontrato.fconfin;
         ELSE
            w_fconfin := fpolvto;
         END IF;

         IF w_volta = 0 THEN   -- update amb el 1º contracte trovat...
            w_volta := 1;

            BEGIN
               UPDATE cesionesaux
                  SET scontra = regcontrato.scontra,
                      nversio = regcontrato.nversio,
                      fconini = w_fconini,
                      fconfin = w_fconfin
                WHERE nriesgo = regcesion.nriesgo
                  AND cgarant = regcesion.cgarant
                  AND sproces = psproces;
--             post;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  perr := 104668;
                  RETURN(perr);
               WHEN OTHERS THEN
                  perr := 104669;
                  RETURN(perr);
            END;
         ELSE
            BEGIN
               w_numlin := w_numlin + 1;

               INSERT INTO cesionesaux
                           (sproces, nnumlin, sseguro, iprirea,
                            icapital, cestado, cfacult, nriesgo,
                            nmovimi, cgarant, scontra, fconini,
                            fconfin, nversio, scumulo, nagrupa)
                    VALUES (psproces, w_numlin, psseguro, regcesion.iprirea,
                            regcesion.icapital, w_cestado, w_cfacult, regcesion.nriesgo,
                            pnmovimi, regcesion.cgarant, regcontrato.scontra, w_fconini,
                            w_fconfin, regcontrato.nversio, regcesion.scumulo, NULL);
--             post;
            EXCEPTION
               WHEN OTHERS THEN
                  perr := 104670;
                  RETURN(perr);
            END;
         END IF;
      END LOOP;
   END LOOP;

---------------
-- CERCA B2...
-- ********
   FOR regcesion IN cur_cesaux   -- llegim les garanties sense contracte...
                              LOOP
      w_cgarant := regcesion.cgarant;
      w_volta := 0;

      FOR regcontrato IN cur_contra_b2 LOOP
         IF regcontrato.fconini <= fpolefe THEN
            w_fconini := fpolefe;
         ELSE
            w_fconini := regcontrato.fconini;
         END IF;

         IF regcontrato.fconfin IS NOT NULL
            AND regcontrato.fconfin <= fpolvto THEN
            w_fconfin := regcontrato.fconfin;
         ELSE
            w_fconfin := fpolvto;
         END IF;

         IF w_volta = 0 THEN   -- update amb el 1º contracte trovat...
            w_volta := 1;

            BEGIN
               UPDATE cesionesaux
                  SET scontra = regcontrato.scontra,
                      nversio = regcontrato.nversio,
                      fconini = w_fconini,
                      fconfin = w_fconfin
                WHERE nriesgo = regcesion.nriesgo
                  AND cgarant = regcesion.cgarant
                  AND sproces = psproces;
--             post;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  perr := 104671;
                  RETURN(perr);
               WHEN OTHERS THEN
                  perr := 104672;
                  RETURN(perr);
            END;
         ELSE
            BEGIN
               w_numlin := w_numlin + 1;

               INSERT INTO cesionesaux
                           (sproces, nnumlin, sseguro, iprirea,
                            icapital, cestado, cfacult, nriesgo,
                            nmovimi, cgarant, scontra, fconini,
                            fconfin, nversio, scumulo, nagrupa)
                    VALUES (psproces, w_numlin, psseguro, regcesion.iprirea,
                            regcesion.icapital, w_cestado, w_cfacult, regcesion.nriesgo,
                            pnmovimi, regcesion.cgarant, regcontrato.scontra, w_fconini,
                            w_fconfin, regcontrato.nversio, regcesion.scumulo, NULL);
--             post;
            EXCEPTION
               WHEN OTHERS THEN
                  perr := 104673;
                  RETURN(perr);
            END;
         END IF;
      END LOOP;
   END LOOP;

---------------
-- CERCA B3...
-- ********
   FOR regcesion IN cur_cesaux   -- llegim les garanties sense contracte...
                              LOOP
      w_cgarant := regcesion.cgarant;
      w_volta := 0;

      FOR regcontrato IN cur_contra_b3 LOOP
         IF regcontrato.fconini <= fpolefe THEN
            w_fconini := fpolefe;
         ELSE
            w_fconini := regcontrato.fconini;
         END IF;

         IF regcontrato.fconfin IS NOT NULL
            AND regcontrato.fconfin <= fpolvto THEN
            w_fconfin := regcontrato.fconfin;
         ELSE
            w_fconfin := fpolvto;
         END IF;

         IF w_volta = 0 THEN   -- update amb el 1º contracte trovat...
            w_volta := 1;

            BEGIN
               UPDATE cesionesaux
                  SET scontra = regcontrato.scontra,
                      nversio = regcontrato.nversio,
                      fconini = w_fconini,
                      fconfin = w_fconfin
                WHERE nriesgo = regcesion.nriesgo
                  AND cgarant = regcesion.cgarant
                  AND sproces = psproces;
--                post;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  perr := 104674;
                  RETURN(perr);
               WHEN OTHERS THEN
                  perr := 104675;
                  RETURN(perr);
            END;
         ELSE
            BEGIN
               w_numlin := w_numlin + 1;

               INSERT INTO cesionesaux
                           (sproces, nnumlin, sseguro, iprirea,
                            icapital, cestado, cfacult, nriesgo,
                            nmovimi, cgarant, scontra, fconini,
                            fconfin, nversio, scumulo, nagrupa)
                    VALUES (psproces, w_numlin, psseguro, regcesion.iprirea,
                            regcesion.icapital, w_cestado, w_cfacult, regcesion.nriesgo,
                            pnmovimi, regcesion.cgarant, regcontrato.scontra, w_fconini,
                            w_fconfin, regcontrato.nversio, regcesion.scumulo, NULL);
--                post;
            EXCEPTION
               WHEN OTHERS THEN
                  perr := 104676;
                  RETURN(perr);
            END;
         END IF;
      END LOOP;
   END LOOP;

---------------
-- CERCA B4...
-- ********
   FOR regcesion IN cur_cesaux   -- llegim les garanties sense contracte...
                              LOOP
      w_cgarant := regcesion.cgarant;
      w_volta := 0;

      FOR regcontrato IN cur_contra_b4 LOOP
         IF regcontrato.fconini <= fpolefe THEN
            w_fconini := fpolefe;
         ELSE
            w_fconini := regcontrato.fconini;
         END IF;

         IF regcontrato.fconfin IS NOT NULL
            AND regcontrato.fconfin <= fpolvto THEN
            w_fconfin := regcontrato.fconfin;
         ELSE
            w_fconfin := fpolvto;
         END IF;

         IF w_volta = 0 THEN   -- update amb el 1º contracte trovat...
            w_volta := 1;

            BEGIN
               UPDATE cesionesaux
                  SET scontra = regcontrato.scontra,
                      nversio = regcontrato.nversio,
                      fconini = w_fconini,
                      fconfin = w_fconfin
                WHERE nriesgo = regcesion.nriesgo
                  AND cgarant = regcesion.cgarant
                  AND sproces = psproces;
--                post;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  perr := 104677;
                  RETURN(perr);
               WHEN OTHERS THEN
                  perr := 104678;
                  RETURN(perr);
            END;
         ELSE
            BEGIN
               w_numlin := w_numlin + 1;

               INSERT INTO cesionesaux
                           (sproces, nnumlin, sseguro, iprirea,
                            icapital, cestado, cfacult, nriesgo,
                            nmovimi, cgarant, scontra, fconini,
                            fconfin, nversio, scumulo, nagrupa)
                    VALUES (psproces, w_numlin, psseguro, regcesion.iprirea,
                            regcesion.icapital, w_cestado, w_cfacult, regcesion.nriesgo,
                            pnmovimi, regcesion.cgarant, regcontrato.scontra, w_fconini,
                            w_fconfin, regcontrato.nversio, regcesion.scumulo, NULL);
--                post;
            EXCEPTION
               WHEN OTHERS THEN
                  perr := 104679;
                  RETURN(perr);
            END;
         END IF;
      END LOOP;
   END LOOP;

---------------
-- CERCA B5...
-- ********
   FOR regcesion IN cur_cesaux   -- llegim les garanties sense contracte...
                              LOOP
      w_cgarant := regcesion.cgarant;
      w_volta := 0;

      FOR regcontrato IN cur_contra_b5 LOOP
         IF regcontrato.fconini <= fpolefe THEN
            w_fconini := fpolefe;
         ELSE
            w_fconini := regcontrato.fconini;
         END IF;

         IF regcontrato.fconfin IS NOT NULL
            AND regcontrato.fconfin <= fpolvto THEN
            w_fconfin := regcontrato.fconfin;
         ELSE
            w_fconfin := fpolvto;
         END IF;

         IF w_volta = 0 THEN   -- update amb el 1º contracte trovat...
            w_volta := 1;

            BEGIN
               UPDATE cesionesaux
                  SET scontra = regcontrato.scontra,
                      nversio = regcontrato.nversio,
                      fconini = w_fconini,
                      fconfin = w_fconfin
                WHERE nriesgo = regcesion.nriesgo
                  AND cgarant = regcesion.cgarant
                  AND sproces = psproces;
--                post;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  perr := 104680;
                  RETURN(perr);
               WHEN OTHERS THEN
                  perr := 104681;
                  RETURN(perr);
            END;
         ELSE
            BEGIN
               w_numlin := w_numlin + 1;

               INSERT INTO cesionesaux
                           (sproces, nnumlin, sseguro, iprirea,
                            icapital, cestado, cfacult, nriesgo,
                            nmovimi, cgarant, scontra, fconini,
                            fconfin, nversio, scumulo, nagrupa)
                    VALUES (psproces, w_numlin, psseguro, regcesion.iprirea,
                            regcesion.icapital, w_cestado, w_cfacult, regcesion.nriesgo,
                            pnmovimi, regcesion.cgarant, regcontrato.scontra, w_fconini,
                            w_fconfin, regcontrato.nversio, regcesion.scumulo, NULL);
--                post;
            EXCEPTION
               WHEN OTHERS THEN
                  perr := 104682;
                  RETURN(perr);
            END;
         END IF;
      END LOOP;
   END LOOP;

---------------
-- CERCA B6...
-- ********
   FOR regcesion IN cur_cesaux   -- llegim les garanties sense contracte...
                              LOOP
      w_cgarant := regcesion.cgarant;
      w_volta := 0;

      FOR regcontrato IN cur_contra_b6 LOOP
         IF regcontrato.fconini <= fpolefe THEN
            w_fconini := fpolefe;
         ELSE
            w_fconini := regcontrato.fconini;
         END IF;

         IF regcontrato.fconfin IS NOT NULL
            AND regcontrato.fconfin <= fpolvto THEN
            w_fconfin := regcontrato.fconfin;
         ELSE
            w_fconfin := fpolvto;
         END IF;

         IF w_volta = 0 THEN   -- update amb el 1º contracte trovat...
            w_volta := 1;

            BEGIN
               UPDATE cesionesaux
                  SET scontra = regcontrato.scontra,
                      nversio = regcontrato.nversio,
                      fconini = w_fconini,
                      fconfin = w_fconfin
                WHERE nriesgo = regcesion.nriesgo
                  AND cgarant = regcesion.cgarant
                  AND sproces = psproces;
--                post;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  perr := 104683;
                  RETURN(perr);
               WHEN OTHERS THEN
                  perr := 104684;
                  RETURN(perr);
            END;
         ELSE
            BEGIN
               w_numlin := w_numlin + 1;

               INSERT INTO cesionesaux
                           (sproces, nnumlin, sseguro, iprirea,
                            icapital, cestado, cfacult, nriesgo,
                            nmovimi, cgarant, scontra, fconini,
                            fconfin, nversio, scumulo, nagrupa)
                    VALUES (psproces, w_numlin, psseguro, regcesion.iprirea,
                            regcesion.icapital, w_cestado, w_cfacult, regcesion.nriesgo,
                            pnmovimi, regcesion.cgarant, regcontrato.scontra, w_fconini,
                            w_fconfin, regcontrato.nversio, regcesion.scumulo, NULL);
--                post;
            EXCEPTION
               WHEN OTHERS THEN
                  perr := 104685;
                  RETURN(perr);
            END;
         END IF;
      END LOOP;
   END LOOP;

---------------
-- CERCA B7...
-- ********
   FOR regcesion IN cur_cesaux   -- llegim les garanties sense contracte...
                              LOOP
      w_cgarant := regcesion.cgarant;
      w_volta := 0;

      FOR regcontrato IN cur_contra_b7 LOOP
         IF regcontrato.fconini <= fpolefe THEN
            w_fconini := fpolefe;
         ELSE
            w_fconini := regcontrato.fconini;
         END IF;

         IF regcontrato.fconfin IS NOT NULL
            AND regcontrato.fconfin <= fpolvto THEN
            w_fconfin := regcontrato.fconfin;
         ELSE
            w_fconfin := fpolvto;
         END IF;

         IF w_volta = 0 THEN   -- update amb el 1º contracte trovat...
            w_volta := 1;

            BEGIN
               UPDATE cesionesaux
                  SET scontra = regcontrato.scontra,
                      nversio = regcontrato.nversio,
                      fconini = w_fconini,
                      fconfin = w_fconfin
                WHERE nriesgo = regcesion.nriesgo
                  AND cgarant = regcesion.cgarant
                  AND sproces = psproces;
--                post;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  perr := 104686;
                  RETURN(perr);
               WHEN OTHERS THEN
                  perr := 104687;
                  RETURN(perr);
            END;
         ELSE
            BEGIN
               w_numlin := w_numlin + 1;

               INSERT INTO cesionesaux
                           (sproces, nnumlin, sseguro, iprirea,
                            icapital, cestado, cfacult, nriesgo,
                            nmovimi, cgarant, scontra, fconini,
                            fconfin, nversio, scumulo, nagrupa)
                    VALUES (psproces, w_numlin, psseguro, regcesion.iprirea,
                            regcesion.icapital, w_cestado, w_cfacult, regcesion.nriesgo,
                            pnmovimi, regcesion.cgarant, regcontrato.scontra, w_fconini,
                            w_fconfin, regcontrato.nversio, regcesion.scumulo, NULL);
--                post;
            EXCEPTION
               WHEN OTHERS THEN
                  perr := 104688;
                  RETURN(perr);
            END;
         END IF;
      END LOOP;
   END LOOP;

---------------
-- CERCA B8...
-- ********
   FOR regcesion IN cur_cesaux   -- llegim les garanties sense contracte...
                              LOOP
      w_cgarant := regcesion.cgarant;
      w_volta := 0;

      FOR regcontrato IN cur_contra_b8 LOOP
         IF regcontrato.fconini <= fpolefe THEN
            w_fconini := fpolefe;
         ELSE
            w_fconini := regcontrato.fconini;
         END IF;

         IF regcontrato.fconfin IS NOT NULL
            AND regcontrato.fconfin <= fpolvto THEN
            w_fconfin := regcontrato.fconfin;
         ELSE
            w_fconfin := fpolvto;
         END IF;

         IF w_volta = 0 THEN   -- update amb el 1º contracte trovat...
            w_volta := 1;

            BEGIN
               UPDATE cesionesaux
                  SET scontra = regcontrato.scontra,
                      nversio = regcontrato.nversio,
                      fconini = w_fconini,
                      fconfin = w_fconfin
                WHERE nriesgo = regcesion.nriesgo
                  AND cgarant = regcesion.cgarant
                  AND sproces = psproces;
--                post;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  perr := 104689;
                  RETURN(perr);
               WHEN OTHERS THEN
                  perr := 104690;
                  RETURN(perr);
            END;
         ELSE
            BEGIN
               w_numlin := w_numlin + 1;

               INSERT INTO cesionesaux
                           (sproces, nnumlin, sseguro, iprirea,
                            icapital, cestado, cfacult, nriesgo,
                            nmovimi, cgarant, scontra, fconini,
                            fconfin, nversio, scumulo, nagrupa)
                    VALUES (psproces, w_numlin, psseguro, regcesion.iprirea,
                            regcesion.icapital, w_cestado, w_cfacult, regcesion.nriesgo,
                            pnmovimi, regcesion.cgarant, regcontrato.scontra, w_fconini,
                            w_fconfin, regcontrato.nversio, regcesion.scumulo, NULL);
--                post;
            EXCEPTION
               WHEN OTHERS THEN
                  perr := 104691;
                  RETURN(perr);
            END;
         END IF;
      END LOOP;
   END LOOP;

---------------
-------------------------------------------------------------------------
-- AL FINAL DE TOT, BUSQUEM SI HI HA ALGUN CONTRACTE "XL" O "SL" QUE
-- AMPARI EL RAM, O BE SI CAP GARANTIA TE CONTRACTE...
   FOR regcesion IN cur_cesaux   -- QUEDEN GARANTIES SENSE CONTRACTE...
                              LOOP
      perr := 104769;

      FOR regcontrato IN cur_contra_xlsl   -- PERÒ TENEN XL O SL QUE LES AMPARA...
                                        LOOP
         perr := 99;
      END LOOP;
   END LOOP;

   IF perr = 99 THEN
      ROLLBACK TO reaseguro;
   END IF;

   RETURN(perr);
END;

/

  GRANT EXECUTE ON "AXIS"."F_BUSCA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_BUSCA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_BUSCA" TO "PROGRAMADORESCSI";
