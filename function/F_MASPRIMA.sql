--------------------------------------------------------
--  DDL for Function F_MASPRIMA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_MASPRIMA" (
   psproces IN NUMBER,
   psseguro IN NUMBER,
   pnmovimi IN NUMBER)
/***********************************************************************
   F_MASPRIMA    :  Permite crear cesiones de prima por regularizaciones
                       por "capitales eventuales".
                       Se crean movimientos 10 de cesión de más prima.
                       La distribución en tramos será la misma que para
                       la última cesión vigente del seguro.
                       Estos movimientos, como no afectan ni a capitales,
                       ni a nueva asignación de contrato ni a diferentes
                       distribuciones de tramos, no se considerarán para
                       las cesiones por pagos de siniestros.
   ALLIBREA
***********************************************************************/
RETURN NUMBER AUTHID CURRENT_USER IS
   codi_error     NUMBER := 0;
   w_nriesgo      cesionesrea.nriesgo%TYPE;
   w_cgarant      cesionesrea.cgarant%TYPE;
   w_finiefe      cesionesrea.fefecto%TYPE;
   w_trovat       NUMBER(1);
   w_scesrea      cesionesrea.scesrea%TYPE;
   w_ncesion      tramos.ncesion%TYPE;
   w_icesion      cesionesrea.icesion%TYPE;
   lcforpag       seguros.cforpag%TYPE;
   lsproduc       seguros.sproduc%TYPE;

   CURSOR cur_garant IS
      SELECT   *
          FROM garanseg
         WHERE sseguro = psseguro
           AND nmovimi = pnmovimi
      ORDER BY finiefe;

   CURSOR cur_ces1 IS
      SELECT *
        FROM cesionesrea
       WHERE sseguro = psseguro
         AND nriesgo = w_nriesgo
         AND cgarant = w_cgarant
         AND(cgenera = 01
             OR cgenera = 03
             OR cgenera = 04
             OR cgenera = 05
             OR cgenera = 09)
         AND fefecto <= w_finiefe
         AND fvencim > w_finiefe
         AND(fanulac > w_finiefe
             OR fanulac IS NULL)
         AND(fregula > w_finiefe
             OR fregula IS NULL);

   CURSOR cur_ces2 IS
      SELECT *
        FROM cesionesrea
       WHERE sseguro = psseguro
         AND nriesgo = w_nriesgo
         AND cgarant IS NULL
         AND(cgenera = 01
             OR cgenera = 03
             OR cgenera = 04
             OR cgenera = 05
             OR cgenera = 09)
         AND fefecto <= w_finiefe
         AND fvencim > w_finiefe
         AND(fanulac > w_finiefe
             OR fanulac IS NULL)
         AND(fregula > w_finiefe
             OR fregula IS NULL);

   CURSOR cur_ces3 IS
      SELECT *
        FROM cesionesrea
       WHERE sseguro = psseguro
         AND nriesgo = w_nriesgo
         AND(cgenera = 01
             OR cgenera = 03
             OR cgenera = 04
             OR cgenera = 05
             OR cgenera = 09)
         AND fefecto <= w_finiefe
         AND fvencim > w_finiefe
         AND(fanulac > w_finiefe
             OR fanulac IS NULL)
         AND(fregula > w_finiefe
             OR fregula IS NULL);
BEGIN
   BEGIN
      SELECT cforpag, sproduc
        INTO lcforpag, lsproduc
        FROM seguros
       WHERE sseguro = psseguro;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 101919;
   END;

   FOR reggar IN cur_garant LOOP
      w_nriesgo := reggar.nriesgo;
      w_cgarant := reggar.cgarant;
      w_finiefe := reggar.finiefe;
      w_trovat := 0;

      FOR regces IN cur_ces1 LOOP
         w_trovat := 1;

         SELECT scesrea.NEXTVAL
           INTO w_scesrea
           FROM DUAL;

         -- w_icesion := (NVL(reggar.itarrea, NVL(reggar.iprianu, 0)) * regces.pcesion) / 100;
         w_icesion := (NVL(reggar.iprianu, 0) * regces.pcesion) / 100;   -- BUG 0034505 - FAL - 27/03/2015
         w_icesion := f_round_forpag(w_icesion, lcforpag,

                                     -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                     --2,
                                     pac_monedas.f_moneda_producto(lsproduc),
                                     -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                     lsproduc);

         IF regces.ctramo <> 0
            AND regces.ctramo <> 5 THEN
            BEGIN
               SELECT ncesion
                 INTO w_ncesion
                 FROM tramos
                WHERE scontra = regces.scontra
                  AND nversio = regces.nversio
                  AND ctramo = regces.ctramo;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  codi_error := 104713;
                  RETURN(codi_error);
               WHEN OTHERS THEN
                  codi_error := 104714;
                  RETURN(codi_error);
            END;

            BEGIN
               UPDATE tramos
                  SET ncesion = w_ncesion + 1
                WHERE scontra = regces.scontra
                  AND nversio = regces.nversio
                  AND ctramo = regces.ctramo;
            EXCEPTION
               WHEN OTHERS THEN
                  codi_error := 103823;
                  RETURN(codi_error);
            END;
         ELSIF regces.ctramo = 0 THEN
            w_ncesion := 1;

            BEGIN
               UPDATE tramos
                  SET ncesion = w_ncesion + 1
                WHERE scontra = regces.scontra
                  AND nversio = regces.nversio
                  AND ctramo = regces.ctramo;
            EXCEPTION
               WHEN OTHERS THEN
                  codi_error := 103823;
                  RETURN(codi_error);
            END;
         ELSIF regces.ctramo = 5 THEN
            BEGIN
               SELECT ncesion
                 INTO w_ncesion
                 FROM cuafacul
                WHERE sfacult = regces.sfacult;

               UPDATE cuafacul
                  SET ncesion = w_ncesion + 1
                WHERE sfacult = regces.sfacult;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  w_ncesion := 1;
               WHEN OTHERS THEN
                  codi_error := 103823;
                  RETURN(codi_error);
            END;
         END IF;

         BEGIN
            INSERT INTO cesionesrea
                        (scesrea, ncesion, icesion, icapces, sseguro, nversio,
                         scontra, ctramo, sfacult, nriesgo, icomisi,
                         icomreg, scumulo, cgarant, spleno, ccalif1,
                         ccalif2, nsinies, fefecto, fvencim, fcontab,
                         pcesion, sproces, cgenera, fgenera, fregula, fanulac, nmovimi,
                         nmovigen)   -- Se añade campos para regularización
                 VALUES (w_scesrea, w_ncesion, w_icesion, 0, reggar.sseguro, regces.nversio,
                         regces.scontra, regces.ctramo, regces.sfacult, reggar.nriesgo, NULL,
                         NULL, regces.scumulo, reggar.cgarant, regces.spleno, regces.ccalif1,
                         regces.ccalif2, NULL, reggar.finiefe, reggar.ffinefe, NULL,
                         regces.pcesion, psproces, 10, f_sysdate, NULL, NULL, reggar.nmovimi,
                         reggar.nmovimi);   -- Se añade campos para regularización
         EXCEPTION
            WHEN OTHERS THEN
               codi_error := 105200;
               RETURN(codi_error);
         END;
      END LOOP;

      IF w_trovat = 0 THEN
         FOR regces IN cur_ces2 LOOP
            w_trovat := 1;

            SELECT scesrea.NEXTVAL
              INTO w_scesrea
              FROM DUAL;

            --w_icesion := (NVL(reggar.itarrea, NVL(reggar.iprianu, 0)) * regces.pcesion) / 100;
            w_icesion := (NVL(reggar.iprianu, 0) * regces.pcesion) / 100;   -- BUG 0034505 - FAL - 27/03/2015
            w_icesion := f_round_forpag(w_icesion, lcforpag,

                                        -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                                  --2,
                                        pac_monedas.f_moneda_producto(lsproduc),
                                        -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                        lsproduc);

            IF regces.ctramo <> 0
               AND regces.ctramo <> 5 THEN
               BEGIN
                  SELECT ncesion
                    INTO w_ncesion
                    FROM tramos
                   WHERE scontra = regces.scontra
                     AND nversio = regces.nversio
                     AND ctramo = regces.ctramo;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     codi_error := 104713;
                     RETURN(codi_error);
                  WHEN OTHERS THEN
                     codi_error := 104714;
                     RETURN(codi_error);
               END;

               BEGIN
                  UPDATE tramos
                     SET ncesion = w_ncesion + 1
                   WHERE scontra = regces.scontra
                     AND nversio = regces.nversio
                     AND ctramo = regces.ctramo;
               EXCEPTION
                  WHEN OTHERS THEN
                     codi_error := 103823;
                     RETURN(codi_error);
               END;
            ELSIF regces.ctramo = 0 THEN
               w_ncesion := 1;

               BEGIN
                  UPDATE tramos
                     SET ncesion = w_ncesion + 1
                   WHERE scontra = regces.scontra
                     AND nversio = regces.nversio
                     AND ctramo = regces.ctramo;
               EXCEPTION
                  WHEN OTHERS THEN
                     codi_error := 103823;
                     RETURN(codi_error);
               END;
            ELSIF regces.ctramo = 5 THEN
               BEGIN
                  SELECT ncesion
                    INTO w_ncesion
                    FROM cuafacul
                   WHERE sfacult = regces.sfacult;

                  UPDATE cuafacul
                     SET ncesion = w_ncesion + 1
                   WHERE sfacult = regces.sfacult;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     w_ncesion := 1;
                  WHEN OTHERS THEN
                     codi_error := 103823;
                     RETURN(codi_error);
               END;
            END IF;

            BEGIN
               INSERT INTO cesionesrea
                           (scesrea, ncesion, icesion, icapces, sseguro,
                            nversio, scontra, ctramo, sfacult,
                            nriesgo, icomisi, icomreg, scumulo, cgarant,
                            spleno, ccalif1, ccalif2, nsinies,
                            fefecto, fvencim, fcontab, pcesion, sproces,
                            cgenera, fgenera, fregula, fanulac, nmovimi, nmovigen)   -- Se añade campos para regularización
                    VALUES (w_scesrea, w_ncesion, w_icesion, 0, reggar.sseguro,
                            regces.nversio, regces.scontra, regces.ctramo, regces.sfacult,
                            reggar.nriesgo, NULL, NULL, regces.scumulo, reggar.cgarant,
                            regces.spleno, regces.ccalif1, regces.ccalif2, NULL,
                            reggar.finiefe, reggar.ffinefe, NULL, regces.pcesion, psproces,
                            10, f_sysdate, NULL, NULL, reggar.nmovimi, reggar.nmovimi);   -- Se añade campos para regularización
            EXCEPTION
               WHEN OTHERS THEN
                  codi_error := 105200;
                  RETURN(codi_error);
            END;

            BEGIN
               UPDATE tramos
                  SET ncesion = w_ncesion + 1
                WHERE scontra = regces.scontra
                  AND nversio = regces.nversio
                  AND ctramo = regces.ctramo;
            EXCEPTION
               WHEN OTHERS THEN
                  codi_error := 103823;
                  RETURN(codi_error);
            END;
         END LOOP;
      END IF;

      IF w_trovat = 0 THEN
         FOR regces IN cur_ces3 LOOP
            w_trovat := 1;

            SELECT scesrea.NEXTVAL
              INTO w_scesrea
              FROM DUAL;

            --w_icesion := (NVL(reggar.itarrea, NVL(reggar.iprianu, 0)) * regces.pcesion) / 100;
            w_icesion := (NVL(reggar.iprianu, 0) * regces.pcesion) / 100;   -- BUG 0034505 - FAL - 27/03/2015
            w_icesion := f_round_forpag(w_icesion, lcforpag,

                                        -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                                  --2,
                                        pac_monedas.f_moneda_producto(lsproduc),
                                        -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                        lsproduc);

            IF regces.ctramo <> 0
               AND regces.ctramo <> 5 THEN
               BEGIN
                  SELECT ncesion
                    INTO w_ncesion
                    FROM tramos
                   WHERE scontra = regces.scontra
                     AND nversio = regces.nversio
                     AND ctramo = regces.ctramo;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     codi_error := 104713;
                     RETURN(codi_error);
                  WHEN OTHERS THEN
                     codi_error := 104714;
                     RETURN(codi_error);
               END;

               BEGIN
                  UPDATE tramos
                     SET ncesion = w_ncesion + 1
                   WHERE scontra = regces.scontra
                     AND nversio = regces.nversio
                     AND ctramo = regces.ctramo;
               EXCEPTION
                  WHEN OTHERS THEN
                     codi_error := 103823;
                     RETURN(codi_error);
               END;
            ELSIF regces.ctramo = 0 THEN
               w_ncesion := 1;

               BEGIN
                  UPDATE tramos
                     SET ncesion = w_ncesion + 1
                   WHERE scontra = regces.scontra
                     AND nversio = regces.nversio
                     AND ctramo = regces.ctramo;
               EXCEPTION
                  WHEN OTHERS THEN
                     codi_error := 103823;
                     RETURN(codi_error);
               END;
            ELSIF regces.ctramo = 5 THEN
               BEGIN
                  SELECT ncesion
                    INTO w_ncesion
                    FROM cuafacul
                   WHERE sfacult = regces.sfacult;

                  UPDATE cuafacul
                     SET ncesion = w_ncesion + 1
                   WHERE sfacult = regces.sfacult;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     w_ncesion := 1;
                  WHEN OTHERS THEN
                     codi_error := 103823;
                     RETURN(codi_error);
               END;
            END IF;

            BEGIN
               INSERT INTO cesionesrea
                           (scesrea, ncesion, icesion, icapces, sseguro,
                            nversio, scontra, ctramo, sfacult,
                            nriesgo, icomisi, icomreg, scumulo, cgarant,
                            spleno, ccalif1, ccalif2, nsinies,
                            fefecto, fvencim, fcontab, pcesion, sproces,
                            cgenera, fgenera, fregula, fanulac, nmovimi, nmovigen)
                    VALUES (w_scesrea, w_ncesion, w_icesion, 0, reggar.sseguro,
                            regces.nversio, regces.scontra, regces.ctramo, regces.sfacult,
                            reggar.nriesgo, NULL, NULL, regces.scumulo, reggar.cgarant,
                            regces.spleno, regces.ccalif1, regces.ccalif2, NULL,
                            reggar.finiefe, reggar.ffinefe, NULL, regces.pcesion, psproces,
                            10, f_sysdate, NULL, NULL, reggar.nmovimi, reggar.nmovimi); -- BUG 0040860 - FAL - 01/03/2016 - Informar nmovigen
            EXCEPTION
               WHEN OTHERS THEN
                  codi_error := 105200;
                  RETURN(codi_error);
            END;

            BEGIN
               UPDATE tramos
                  SET ncesion = w_ncesion + 1
                WHERE scontra = regces.scontra
                  AND nversio = regces.nversio
                  AND ctramo = regces.ctramo;
            EXCEPTION
               WHEN OTHERS THEN
                  codi_error := 103823;
                  RETURN(codi_error);
            END;
         END LOOP;
      END IF;
   END LOOP;

   RETURN(codi_error);
END;

/

  GRANT EXECUTE ON "AXIS"."F_MASPRIMA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_MASPRIMA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_MASPRIMA" TO "PROGRAMADORESCSI";
