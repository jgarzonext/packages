--------------------------------------------------------
--  DDL for Function F_XL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_XL" (
   psproces IN NUMBER,
   pnsinies IN NUMBER,
   pfefepag IN DATE,
   pmoneda IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***********************************************************************
   F_XL   :    AQUESTA FUNCIÓ PERMET CREAR MOVIMENTS DE CÀRREC PER
                  SINISTRES A COMPANYIES REASSEGURADORES QUAN EXISTEIXI
                  UN CONTRACTE DE TIPUS XL QUE CUBREIXI LA NOSTRE PART.
                  S'EXECUTA QUAN ES CONFIRMA UN PAGAMENT DE SINISTRE...
                  CADA COP ES CONSIDEREN TOTS EL PAGAMENTS EFECTUATS PER
                  EL SINISTRE, INCLÒS EL QUE S'ACABA DE CONFIRMAR...
   ALLIBREA

***********************************************************************/
   codi_error     NUMBER := 0;
   avui           DATE;
   w_sseguro      cesionesrea.sseguro%TYPE;   --    w_sseguro      NUMBER(6); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_nriesgo      cesionesrea.nriesgo%TYPE;   --    w_nriesgo      NUMBER(6); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_fsinies      siniestros.fsinies%TYPE;   --    w_fsinies      DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_festsin      siniestros.festsin%TYPE;   --    w_festsin      DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_cramo        seguros.cramo%TYPE;   --    w_cramo        NUMBER(8); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_cmodali      seguros.cmodali%TYPE;   --    w_cmodali      NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_ctipseg      seguros.ctipseg%TYPE;   --    w_ctipseg      NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_ccolect      seguros.ccolect%TYPE;   --    w_ccolect      NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_cactivi      NUMBER(4);
   w_scontraxl    contratos.scontra%TYPE;   --    w_scontraxl    NUMBER(6); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_nversioxl    contratos.nversio%TYPE;   --    w_nversioxl    NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_iprioxl      contratos.iprioxl%TYPE;   --    w_iprioxl      NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_scontra      NUMBER(6);
   w_nversio      NUMBER(2);
   w_sfacult      cesionesrea.sfacult%TYPE;   --    w_sfacult      NUMBER(6); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_scumulo      cesionesrea.scumulo%TYPE;   --    w_scumulo      NUMBER(6); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_tram         NUMBER(2);
   w_ctiprea      codicontratos.ctiprea%TYPE;   --    w_ctiprea      NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_plocal       tramos.plocal%TYPE;   /* NUMBER(5, 2);          */
   w_volta        NUMBER(1);
   w_assumit      cesionesrea.icesion%TYPE;   /* NUMBER(13, 2);  */
   w_aplicar      cesionesrea.icesion%TYPE;   --    w_aplicar      NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_scesrea      cesionesrea.scesrea%TYPE;   --    w_scesrea      NUMBER(8); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   repetit        NUMBER(1);

   CURSOR cur_carrecs IS
      SELECT *
        FROM cesionesrea
       WHERE nsinies = pnsinies
         AND sseguro = w_sseguro
         AND nriesgo = w_nriesgo
         AND scontra <> w_scontraxl
         AND cgenera = 2;

   CURSOR cur_tramsxl IS
      SELECT   *
          FROM tramos
         WHERE scontra = w_scontraxl
           AND nversio = w_nversioxl
      ORDER BY norden;

-- **********************************************************************
-- **********************************************************************
-- **********************************************************************
   FUNCTION f_repe(prepe OUT NUMBER)
      RETURN NUMBER IS
/***********************************************************************
   F_REPE :    AQUESTA FUNCIÓ MIRA SI HI HAN CÀRRECS JA FETS CONTRA
                  EL MATEIX CONTRACTE DE XL PER EL SINISTRE EN QUESTIÓ...
***********************************************************************/
      codi_error     NUMBER := 0;
      w_suma         NUMBER;   /* NUMBER(13, 2);    */
      w_afegir       cesionesrea.icesion%TYPE;   --       w_afegir       NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_tramo        tramos.ctramo%TYPE;   --       w_tramo        NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_nces         tramos.ncesion%TYPE;   --       w_nces         NUMBER(6); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_restar       cesionesrea.icesion%TYPE;   /* NUMBER(13, 2);      */
--      w_cargo        NUMBER(13, 2);
      w_maxtram      cesionesrea.ctramo%TYPE;   --       w_maxtram      NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_impsup       cesionesrea.icesion%TYPE;   /*  NUMBER(13, 2);    */
      w_impsupya     cesionesrea.icesion%TYPE;   /*  NUMBER(13, 2); */
      w_prio         tramos.ixlprio%TYPE;   --       w_prio         NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_aux          cesionesrea.icesion%TYPE;   --       w_aux          NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---

      CURSOR cur_repe IS
         SELECT icesion
           FROM cesionesrea
          WHERE cgenera = 2
            AND nsinies = pnsinies
            AND scontra = w_scontraxl
            AND nversio = w_nversioxl;

      CURSOR cur_trams IS
         SELECT   *
             FROM tramos
            WHERE scontra = w_scontraxl
              AND nversio = w_nversioxl
              AND ctramo < w_maxtram
         ORDER BY ctramo DESC;

      CURSOR cur_max IS
         SELECT *
           FROM cesionesrea
          WHERE cgenera = 2
            AND nsinies = pnsinies
            AND scontra = w_scontraxl
            AND nversio = w_nversioxl
            AND ctramo = w_maxtram;

      CURSOR cur_mes IS
         SELECT   *
             FROM tramos
            WHERE scontra = w_scontraxl
              AND nversio = w_nversioxl
              AND ctramo > w_maxtram
         ORDER BY ctramo;
   BEGIN
      w_suma := 0;

      FOR regrepe IN cur_repe LOOP
         w_suma := w_suma + regrepe.icesion;
      END LOOP;

      IF w_suma = 0 THEN   -- NO HI HA RES...
         prepe := 0;
         RETURN(codi_error);
      END IF;

      w_aplicar := w_assumit - w_iprioxl;

      IF w_suma <> 0
         AND w_suma = w_aplicar THEN
         prepe := 1;
         RETURN(codi_error);   -- SÍ QUE HI HA PERÒ ES IDÈNTIC...
      END IF;

      BEGIN   -- AQUÍ ES BUSCA EL TRAM MÉS ALT DEL XL
         SELECT MAX(ctramo)   -- QUE HEM UTILITZAT...
           INTO w_maxtram
           FROM cesionesrea
          WHERE cgenera = 2
            AND nsinies = pnsinies
            AND scontra = w_scontraxl
            AND nversio = w_nversioxl;
      EXCEPTION
         WHEN OTHERS THEN
            codi_error := 105297;
            RETURN(codi_error);
      END;

      IF w_suma <> 0
         AND w_suma < w_aplicar THEN   -- HA AUGMENTAT...
         prepe := 1;   -- EL CÀRREC ES FA CONTRA
                       -- EL TRAM SUPERIOR...

         SELECT ctramo, ncesion, ixlprio
           INTO w_tramo, w_nces, w_prio
           FROM tramos
          WHERE scontra = w_scontraxl
            AND nversio = w_nversioxl
            AND ctramo = w_maxtram;

         w_afegir := w_aplicar - w_suma;
         w_impsupya := 0;   -- NOU IMPORT PER EL TRAM MÀXIM...

         FOR reg_max IN cur_max LOOP
            w_impsupya := w_impsupya + reg_max.icesion;
         END LOOP;

         w_impsup := w_impsupya + w_afegir;

         IF w_impsup <= w_prio THEN
            SELECT scesrea.NEXTVAL
              INTO w_scesrea
              FROM DUAL;

            BEGIN
               INSERT INTO cesionesrea
                           (scesrea, ncesion, icesion, icapces, sseguro, nversio,
                            scontra, ctramo, sfacult, nriesgo, scumulo, nsinies,
                            fefecto, fvencim, sproces, cgenera, fgenera)
                    VALUES (w_scesrea, w_nces, w_afegir, 0, w_sseguro, w_nversioxl,
                            w_scontraxl, w_tramo, w_sfacult, w_nriesgo, w_scumulo, pnsinies,
                            pfefepag, pfefepag, psproces, 02, avui);

               UPDATE tramos
                  SET ncesion = ncesion + 1
                WHERE scontra = w_scontraxl
                  AND nversio = w_nversioxl
                  AND ctramo = w_tramo;

               RETURN(codi_error);   -- JA ESTEM... SORTIM...
            EXCEPTION
               WHEN OTHERS THEN
                  codi_error := 104693;
                  RETURN(codi_error);
            END;
         ELSE
            w_aux := w_prio - w_impsupya;

            SELECT scesrea.NEXTVAL
              INTO w_scesrea
              FROM DUAL;

            BEGIN
               INSERT INTO cesionesrea
                           (scesrea, ncesion, icesion, icapces, sseguro, nversio, scontra,
                            ctramo, sfacult, nriesgo, scumulo, nsinies, fefecto,
                            fvencim, sproces, cgenera, fgenera)
                    VALUES (w_scesrea, w_nces, w_aux, 0, w_sseguro, w_nversioxl, w_scontraxl,
                            w_tramo, w_sfacult, w_nriesgo, w_scumulo, pnsinies, pfefepag,
                            pfefepag, psproces, 02, avui);

               UPDATE tramos
                  SET ncesion = ncesion + 1
                WHERE scontra = w_scontraxl
                  AND nversio = w_nversioxl
                  AND ctramo = w_tramo;
            EXCEPTION
               WHEN OTHERS THEN
                  codi_error := 104693;
                  RETURN(codi_error);
            END;

            w_aux := w_afegir - w_aux;

            FOR reg_mes IN cur_mes LOOP
               IF w_aux <= reg_mes.ixlprio THEN
                  SELECT scesrea.NEXTVAL
                    INTO w_scesrea
                    FROM DUAL;

                  BEGIN
                     INSERT INTO cesionesrea
                                 (scesrea, ncesion, icesion, icapces, sseguro,
                                  nversio, scontra, ctramo, sfacult,
                                  nriesgo, scumulo, nsinies, fefecto, fvencim,
                                  sproces, cgenera, fgenera)
                          VALUES (w_scesrea, reg_mes.ncesion + 1, w_aux, 0, w_sseguro,
                                  w_nversioxl, w_scontraxl, reg_mes.ctramo, w_sfacult,
                                  w_nriesgo, w_scumulo, pnsinies, pfefepag, pfefepag,
                                  psproces, 02, avui);

                     UPDATE tramos
                        SET ncesion = ncesion + 1
                      WHERE scontra = w_scontraxl
                        AND nversio = w_nversioxl
                        AND ctramo = reg_mes.ctramo;
                  EXCEPTION
                     WHEN OTHERS THEN
                        codi_error := 104693;
                        RETURN(codi_error);
                  END;

                  RETURN(codi_error);   -- JA ESTEM... SORTIM...
               ELSE
                  w_aux := reg_mes.ixlprio;

                  SELECT scesrea.NEXTVAL
                    INTO w_scesrea
                    FROM DUAL;

                  BEGIN
                     INSERT INTO cesionesrea
                                 (scesrea, ncesion, icesion, icapces, sseguro,
                                  nversio, scontra, ctramo, sfacult,
                                  nriesgo, scumulo, nsinies, fefecto, fvencim,
                                  sproces, cgenera, fgenera)
                          VALUES (w_scesrea, reg_mes.ncesion + 1, w_aux, 0, w_sseguro,
                                  w_nversioxl, w_scontraxl, reg_mes.ctramo, w_sfacult,
                                  w_nriesgo, w_scumulo, pnsinies, pfefepag, pfefepag,
                                  psproces, 02, avui);

                     UPDATE tramos
                        SET ncesion = ncesion + 1
                      WHERE scontra = w_scontraxl
                        AND nversio = w_nversioxl
                        AND ctramo = reg_mes.ctramo;
                  EXCEPTION
                     WHEN OTHERS THEN
                        codi_error := 104693;
                        RETURN(codi_error);
                  END;

                  w_aux := w_aux - reg_mes.ixlprio;
               END IF;
            END LOOP;
         END IF;

         RETURN(codi_error);
      END IF;

      IF w_suma <> 0
         AND w_suma > w_aplicar THEN   -- S'HA REDUIT...
         prepe := 1;   -- EL CÀRREC NEGATIU ES
                       -- VA REPARTINT DEL TRAM

         SELECT ctramo, ncesion, ixlprio   -- SUPERIOR EN AVALL...
           INTO w_tramo, w_nces, w_prio
           FROM tramos
          WHERE scontra = w_scontraxl
            AND nversio = w_nversioxl
            AND ctramo = w_maxtram;

         w_restar := w_suma - w_aplicar;
         w_impsupya := 0;   -- NOU IMPORT PER EL TRAM MÀXIM...

         FOR reg_max IN cur_max LOOP
            w_impsupya := w_impsupya + reg_max.icesion;
         END LOOP;

         w_impsup := w_impsupya - w_restar;

         IF w_impsup >= 0 THEN
            SELECT scesrea.NEXTVAL
              INTO w_scesrea
              FROM DUAL;

            BEGIN
               INSERT INTO cesionesrea
                           (scesrea, ncesion, icesion, icapces, sseguro, nversio,
                            scontra, ctramo, sfacult, nriesgo, scumulo,
                            nsinies, fefecto, fvencim, sproces, cgenera, fgenera)
                    VALUES (w_scesrea, w_nces, w_restar * -1, 0, w_sseguro, w_nversioxl,
                            w_scontraxl, w_maxtram, w_sfacult, w_nriesgo, w_scumulo,
                            pnsinies, pfefepag, pfefepag, psproces, 02, avui);

               UPDATE tramos
                  SET ncesion = ncesion + 1
                WHERE scontra = w_scontraxl
                  AND nversio = w_nversioxl
                  AND ctramo = w_maxtram;

               RETURN(codi_error);   -- JA ESTÀ...JA SORTIM...
            EXCEPTION
               WHEN OTHERS THEN
                  codi_error := 104693;
                  RETURN(codi_error);
            END;
         ELSE
            SELECT scesrea.NEXTVAL
              INTO w_scesrea
              FROM DUAL;

            BEGIN
               INSERT INTO cesionesrea
                           (scesrea, ncesion, icesion, icapces, sseguro, nversio,
                            scontra, ctramo, sfacult, nriesgo, scumulo,
                            nsinies, fefecto, fvencim, sproces, cgenera, fgenera)
                    VALUES (w_scesrea, w_nces, w_impsupya * -1, 0, w_sseguro, w_nversioxl,
                            w_scontraxl, w_maxtram, w_sfacult, w_nriesgo, w_scumulo,
                            pnsinies, pfefepag, pfefepag, psproces, 02, avui);

               UPDATE tramos
                  SET ncesion = ncesion + 1
                WHERE scontra = w_scontraxl
                  AND nversio = w_nversioxl
                  AND ctramo = w_maxtram;
            EXCEPTION
               WHEN OTHERS THEN
                  codi_error := 104693;
                  RETURN(codi_error);
            END;

            w_aux := w_restar - w_impsupya;

            FOR regtram IN cur_trams LOOP
               IF w_aux <= regtram.ixlprio THEN
                  SELECT scesrea.NEXTVAL
                    INTO w_scesrea
                    FROM DUAL;

                  BEGIN
                     INSERT INTO cesionesrea
                                 (scesrea, ncesion, icesion, icapces, sseguro,
                                  nversio, scontra, ctramo, sfacult,
                                  nriesgo, scumulo, nsinies, fefecto, fvencim,
                                  sproces, cgenera, fgenera)
                          VALUES (w_scesrea, regtram.ncesion, w_aux * -1, 0, w_sseguro,
                                  w_nversioxl, w_scontraxl, regtram.ctramo, w_sfacult,
                                  w_nriesgo, w_scumulo, pnsinies, pfefepag, pfefepag,
                                  psproces, 02, avui);

                     UPDATE tramos
                        SET ncesion = ncesion + 1
                      WHERE scontra = w_scontraxl
                        AND nversio = w_nversioxl
                        AND ctramo = regtram.ctramo;

                     RETURN(codi_error);   -- JA ESTÀ...SORTIM...
                  EXCEPTION
                     WHEN OTHERS THEN
                        codi_error := 104693;
                        RETURN(codi_error);
                  END;
               ELSE
                  SELECT scesrea.NEXTVAL
                    INTO w_scesrea
                    FROM DUAL;

                  BEGIN
                     INSERT INTO cesionesrea
                                 (scesrea, ncesion, icesion, icapces,
                                  sseguro, nversio, scontra, ctramo,
                                  sfacult, nriesgo, scumulo, nsinies, fefecto,
                                  fvencim, sproces, cgenera, fgenera)
                          VALUES (w_scesrea, regtram.ncesion, regtram.ixlprio * -1, 0,
                                  w_sseguro, w_nversioxl, w_scontraxl, regtram.ctramo,
                                  w_sfacult, w_nriesgo, w_scumulo, pnsinies, pfefepag,
                                  pfefepag, psproces, 02, avui);

                     UPDATE tramos
                        SET ncesion = ncesion + 1
                      WHERE scontra = w_scontraxl
                        AND nversio = w_nversioxl
                        AND ctramo = regtram.ctramo;
                  EXCEPTION
                     WHEN OTHERS THEN
                        codi_error := 104693;
                        RETURN(codi_error);
                  END;

                  w_aux := w_aux - regtram.ixlprio;
               END IF;
            END LOOP;
         END IF;

         RETURN(codi_error);
      END IF;
   END;
-- **********************************************************************
-- **********************************************************************
-- **********************************************************************
BEGIN
   avui := f_sysdate;

-- BUSQUEM L'ASSEGURANÇA I EL RISC...
   BEGIN
      SELECT sseguro, nriesgo, fsinies, festsin
        INTO w_sseguro, w_nriesgo, w_fsinies, w_festsin
        FROM siniestros
       WHERE nsinies = pnsinies;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         codi_error := 104755;
         RETURN(codi_error);
      WHEN OTHERS THEN
         codi_error := 105144;
         RETURN(codi_error);
   END;

-- BUSQUEM EL RAM, EL PRODUCTE I L'ACTIVITAT...
   BEGIN
      SELECT cramo, cmodali, ctipseg, ccolect,
             pac_seguros.ff_get_actividad(sseguro, w_nriesgo)
        INTO w_cramo, w_cmodali, w_ctipseg, w_ccolect,
             w_cactivi
        FROM seguros
       WHERE sseguro = w_sseguro;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         codi_error := 101903;
         RETURN(codi_error);
      WHEN OTHERS THEN
         codi_error := 101919;
         RETURN(codi_error);
   END;

-- BUSQUEN SI EXISTEIX ALGUN CONTRACTE XL QUE HO CUBREIXI...
   BEGIN
      SELECT co.scontra, co.nversio, co.iprioxl
        INTO w_scontraxl, w_nversioxl, w_iprioxl
        FROM codicontratos c, contratos co, agr_contratos a
       WHERE c.scontra = co.scontra
         AND c.scontra = a.scontra   -- 14536 14-05-2010 AVT
         AND co.fconini <= w_fsinies
         AND(co.fconfin > w_fsinies
             OR co.fconfin IS NULL)
         AND c.ctiprea = 3
         AND(a.cramo = w_cramo
             AND a.cmodali = w_cmodali
             AND a.ctipseg = w_ctipseg
             AND a.ccolect = w_ccolect
             AND a.cactivi = w_cactivi);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         BEGIN
            SELECT co.scontra, co.nversio, co.iprioxl
              INTO w_scontraxl, w_nversioxl, w_iprioxl
              FROM codicontratos c, contratos co, agr_contratos a
             WHERE c.scontra = co.scontra
               AND c.scontra = a.scontra   -- 14536 14-05-2010 AVT
               AND co.fconini <= w_fsinies
               AND(co.fconfin > w_fsinies
                   OR co.fconfin IS NULL)
               AND c.ctiprea = 3
               AND(a.cramo = w_cramo
                   AND a.cmodali = w_cmodali
                   AND a.ctipseg = w_ctipseg
                   AND a.ccolect = w_ccolect
                   AND a.cactivi IS NULL);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT co.scontra, co.nversio, co.iprioxl
                    INTO w_scontraxl, w_nversioxl, w_iprioxl
                    FROM codicontratos c, contratos co, agr_contratos a
                   WHERE c.scontra = co.scontra
                     AND c.scontra = a.scontra   -- 14536 14-05-2010 AVT
                     AND co.fconini <= w_fsinies
                     AND(co.fconfin > w_fsinies
                         OR co.fconfin IS NULL)
                     AND c.ctiprea = 3
                     AND(a.cramo = w_cramo
                         AND a.cactivi = w_cactivi
                         AND a.cmodali IS NULL
                         AND a.ctipseg IS NULL
                         AND a.ccolect IS NULL);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                        SELECT co.scontra, co.nversio, co.iprioxl
                          INTO w_scontraxl, w_nversioxl, w_iprioxl
                          FROM codicontratos c, contratos co, agr_contratos a
                         WHERE c.scontra = co.scontra
                           AND c.scontra = a.scontra   -- 14536 14-05-2010 AVT
                           AND co.fconini <= w_fsinies
                           AND(co.fconfin > w_fsinies
                               OR co.fconfin IS NULL)
                           AND c.ctiprea = 3
                           AND(a.cramo = w_cramo
                               AND a.cactivi IS NULL
                               AND a.cmodali IS NULL
                               AND a.ctipseg IS NULL
                               AND a.ccolect IS NULL);
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           RETURN(0);   -- NO HI FHA CAP XL...
                        WHEN OTHERS THEN   -- NO ES FA RES...
                           codi_error := 104704;
                           RETURN(codi_error);
                     END;
                  WHEN OTHERS THEN
                     codi_error := 104704;
                     RETURN(codi_error);
               END;
            WHEN OTHERS THEN
               codi_error := 104704;
               RETURN(codi_error);
         END;
      WHEN OTHERS THEN
         codi_error := 104704;
         RETURN(codi_error);
   END;

-- S'HA TROVAT UN CONTRACTE XL...
   w_assumit := 0;
   w_volta := 0;

   FOR regcarrecs IN cur_carrecs LOOP
      IF w_volta = 0 THEN
         w_volta := 1;
         w_scumulo := regcarrecs.scumulo;
         w_sfacult := regcarrecs.sfacult;
         w_scontra := regcarrecs.scontra;
         w_nversio := regcarrecs.nversio;

         IF regcarrecs.scontra IS NULL
            AND regcarrecs.sfacult IS NOT NULL THEN
            w_sfacult := regcarrecs.sfacult;
            w_tram := 00;
         ELSE
            BEGIN
               SELECT ctiprea
                 INTO w_ctiprea
                 FROM codicontratos
                WHERE scontra = w_scontra;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  codi_error := 104697;
                  RETURN(codi_error);
               WHEN OTHERS THEN
                  codi_error := 104516;
                  RETURN(codi_error);
            END;

            IF w_ctiprea = 1 THEN
               w_tram := 01;
            ELSIF w_ctiprea = 2 THEN
               w_tram := 00;
            END IF;
         END IF;
      END IF;

      IF regcarrecs.ctramo = w_tram THEN
         IF regcarrecs.ctramo = 01 THEN
            BEGIN
               SELECT NVL(plocal, 0)
                 INTO w_plocal
                 FROM tramos
                WHERE scontra = w_scontra
                  AND nversio = w_nversio
                  AND ctramo = 01;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  codi_error := 104713;
                  RETURN(codi_error);
               WHEN OTHERS THEN
                  codi_error := 104714;
                  RETURN(codi_error);
            END;

            w_assumit := w_assumit +((regcarrecs.icesion * w_plocal) / 100);
         ELSIF regcarrecs.ctramo = 00 THEN
            w_assumit := w_assumit + NVL(regcarrecs.icesion, 0);
         END IF;
      END IF;
   END LOOP;

   w_assumit := f_round(w_assumit, pmoneda);
-- CÀRRECS CONTRA EL CONTRACTE XL...
      -- PRIMER, MIREM SI JA EXISTEIXEN CÀRRECS CONTRA AQUEST XL PER EL
      -- SINISTRE AFECTAT ...
      -- FAREM ELS CÀRRECS PER LA DIFERENCIA I MARXEM...
      -- PER AIXÒ, CRIDEM A LA FUNCIÓ F_REPE...
   repetit := 0;
   codi_error := f_repe(repetit);

   IF codi_error <> 0 THEN
      RETURN(codi_error);
   END IF;

   IF repetit = 1 THEN   -- JA EXISTIEN CÀRRECS...NO ES FA RES MÉS...
      RETURN(codi_error);
   END IF;

   -- NO S'HAN TROBAT CÀRRECS ANTERIORS...
   IF w_assumit > w_iprioxl THEN   --ES SUPERA LA NOSTRE PRIORITAT...
      w_aplicar := w_assumit - w_iprioxl;   -- ES FA EL PRIMER CÀRREC
                                            -- CONTRA EL XL...

      FOR regtramsxl IN cur_tramsxl LOOP
         -- TRAMS XL...
         SELECT scesrea.NEXTVAL
           INTO w_scesrea
           FROM DUAL;

         IF w_aplicar <= regtramsxl.ixlprio THEN
            BEGIN
               INSERT INTO cesionesrea
                           (scesrea, ncesion, icesion, icapces, sseguro,
                            nversio, scontra, ctramo, sfacult,
                            nriesgo, scumulo, nsinies, fefecto, fvencim, sproces, cgenera,
                            fgenera)
                    VALUES (w_scesrea, regtramsxl.ncesion, w_aplicar, 0, w_sseguro,
                            w_nversioxl, w_scontraxl, regtramsxl.ctramo, w_sfacult,
                            w_nriesgo, w_scumulo, pnsinies, pfefepag, pfefepag, psproces, 02,
                            avui);

               UPDATE tramos
                  SET ncesion =(NVL(regtramsxl.ncesion, 0) + 1)
                WHERE scontra = w_scontraxl
                  AND nversio = w_nversioxl
                  AND ctramo = regtramsxl.ctramo;

               EXIT;   -- SORTIM DEL LOOP...
            EXCEPTION
               WHEN OTHERS THEN
                  codi_error := 104693;
                  RETURN(codi_error);
            END;
         ELSE
            BEGIN
               INSERT INTO cesionesrea
                           (scesrea, ncesion, icesion, icapces, sseguro,
                            nversio, scontra, ctramo, sfacult,
                            nriesgo, scumulo, nsinies, fefecto, fvencim, sproces, cgenera,
                            fgenera)
                    VALUES (w_scesrea, regtramsxl.ncesion, regtramsxl.ixlprio, 0, w_sseguro,
                            w_nversioxl, w_scontraxl, regtramsxl.ctramo, w_sfacult,
                            w_nriesgo, w_scumulo, pnsinies, pfefepag, pfefepag, psproces, 02,
                            avui);

               UPDATE tramos
                  SET ncesion =(NVL(regtramsxl.ncesion, 0) + 1)
                WHERE scontra = w_scontraxl
                  AND nversio = w_nversioxl
                  AND ctramo = regtramsxl.ctramo;
            EXCEPTION
               WHEN OTHERS THEN
                  codi_error := 104693;
                  RETURN(codi_error);
            END;

            w_aplicar := w_aplicar - regtramsxl.ixlprio;
         END IF;
      END LOOP;
   END IF;

-- SORTIM...
   RETURN(codi_error);
END;

/

  GRANT EXECUTE ON "AXIS"."F_XL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_XL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_XL" TO "PROGRAMADORESCSI";
