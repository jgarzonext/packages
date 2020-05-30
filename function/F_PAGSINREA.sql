--------------------------------------------------------
--  DDL for Function F_PAGSINREA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PAGSINREA" (
   psseguro IN NUMBER,
   pnriesgo IN NUMBER,
   pcgarant IN NUMBER,
   pnsinies IN NUMBER,
   pfsinies IN DATE,
   pimportsin IN NUMBER,
   pmoneda IN NUMBER,
   pctippag IN NUMBER,
   pefepag IN DATE,
   psidepag IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***********************************************************************
   F_PAGSINREA: Aquesta funció permet crear moviments d'abonament, per
                   part de les companyies de reassegurança, en concepte dels
                   pagaments de sinistres.
                   Aquests moviments queden a CESIONESREA.
                   Es realitzen a partir de les dades i percentatges de
                   cessió que figuren en els moviments de cessions
                   efectuades, sempre en funció de les dates cobertes per la
                   cessió amb relació a la data en que s'ha produit el
                   sinistre.
                   Primer buscarem cessions de igual garantía i, si no en
                   trobem, buscarem cessions del risc afectat amb la garantía
                   a NULL.
                   Si pctippag = 3 (anul.lació pagament) o = 7 (recobrament),
                   es crea un moviment de signe contrari.
               Els tipus o motius de moviment considerats (cessions) son:
                   01 - regularització
                   03 - nova producció
                   04 - suplement
                   05 - cartera
                   09 - rehabilitació pòlissa
                   40 - canvi data renovació
               El tipus per pagament de sinistres es el 02.
               Casos especials:
                  - Si es una garantía 9999 ( despeses sinistre ), no
                    es té en compte la garantia de la cessió a CESIONESREA.
                  - Si es ram 40 o ram 51 ( Salut migrat de l'INFORMIX ),
                    no es té en compte el risc de la cessió perquè sempre
                    es 1.
   ALLIBREA

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        XX/XX/XXXX   XXX                1. Creación de la función.
   1.1        04/09/2009   FAL                2. 0011046: CRE - Pagos de siniestros. Se omite el uso de f_round_forpag
***********************************************************************/
   codi_error     NUMBER := 0;
   w_scesrea      cesionesrea.scesrea%TYPE;
   w_ncesion      NUMBER(6);
   w_icesion      cesionesrea.icesion%TYPE;
--   w_pcesion      NUMBER(5, 2);
   w_trovat       NUMBER(1);
   w_cgarant      cesionesrea.cgarant%TYPE;
   avui           cesionesrea.fgenera%TYPE;
   lcforpag       seguros.cforpag%TYPE;
   lsproduc       seguros.sproduc%TYPE;

   CURSOR cur_cesion1 IS
      SELECT *
        FROM cesionesrea
       WHERE sseguro = psseguro
         AND nriesgo = pnriesgo
         AND(cgarant IS NOT NULL
             AND cgarant = pcgarant)
         AND(cgenera = 01
             OR cgenera = 03
             OR cgenera = 04
             OR cgenera = 05
             OR cgenera = 09
             OR cgenera = 40)
         AND fefecto <= pfsinies
         AND fvencim > pfsinies
         AND(fanulac > pfsinies
             OR fanulac IS NULL)
         AND(fregula > pfsinies
             OR fregula IS NULL);

   CURSOR cur_cesion2 IS
      SELECT *
        FROM cesionesrea
       WHERE sseguro = psseguro
         AND nriesgo = pnriesgo
         AND cgarant IS NULL
         AND(cgenera = 01
             OR cgenera = 03
             OR cgenera = 04
             OR cgenera = 05
             OR cgenera = 09)
         AND fefecto <= pfsinies
         AND fvencim > pfsinies
         AND(fanulac > pfsinies
             OR fanulac IS NULL)
         AND(fregula > pfsinies
             OR fregula IS NULL);

   CURSOR cur_garant IS   -- Cursor per la garantia 9999...
      SELECT UNIQUE cgarant
               FROM cesionesrea
              WHERE sseguro = psseguro
                AND nriesgo = pnriesgo
                AND(cgenera = 01
                    OR cgenera = 03
                    OR cgenera = 04
                    OR cgenera = 05
                    OR cgenera = 09)
                AND fefecto <= pfsinies
                AND fvencim > pfsinies
                AND(fanulac > pfsinies
                    OR fanulac IS NULL)
                AND(fregula > pfsinies
                    OR fregula IS NULL);

   CURSOR cur_cesion6 IS   -- Cursor per la garantia 9999...
      SELECT *
        FROM cesionesrea
       WHERE sseguro = psseguro
         AND nriesgo = pnriesgo
         AND cgarant = w_cgarant
         AND(cgenera = 01
             OR cgenera = 03
             OR cgenera = 04
             OR cgenera = 05
             OR cgenera = 09)
         AND fefecto <= pfsinies
         AND fvencim > pfsinies
         AND(fanulac > pfsinies
             OR fanulac IS NULL)
         AND(fregula > pfsinies
             OR fregula IS NULL);
BEGIN
   avui := f_sysdate;

   BEGIN
      SELECT cforpag, sproduc
        INTO lcforpag, lsproduc
        FROM seguros
       WHERE sseguro = psseguro;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 101919;
   END;

   IF pcgarant = 9999 THEN
      w_trovat := 0;

      FOR regcesion IN cur_cesion2 LOOP
         w_trovat := 1;

         SELECT scesrea.NEXTVAL
           INTO w_scesrea
           FROM DUAL;

         w_icesion := (pimportsin * regcesion.pcesion) / 100;

         --w_icesion := f_round(w_icesion,pmoneda);

         -- BUG 0011046 - 04/09/2009 - FAL - Se omite el uso de f_round_forpag
             --w_icesion := F_Round_Forpag(w_icesion, lcforpag, NULL, lsproduc);
-- FI BUG 0011046 - 04/09/2009 - FAL
         IF pctippag = 3
            OR pctippag = 7 THEN
            w_icesion := w_icesion * -1;
         END IF;

         BEGIN
            INSERT INTO cesionesrea
                        (scesrea, ncesion, icesion, icapces, sseguro,
                         nversio, scontra, ctramo,
                         sfacult, nriesgo, scumulo, cgarant,
                         spleno, ccalif1, ccalif2, nmovimi,
                         nsinies, fefecto, fvencim, pcesion, sproces,
                         cgenera, fgenera, sidepag, nmovigen)
                 VALUES (w_scesrea, regcesion.ncesion, w_icesion, 0, psseguro,
                         regcesion.nversio, regcesion.scontra, regcesion.ctramo,
                         regcesion.sfacult, pnriesgo, regcesion.scumulo, 9999,
                         regcesion.spleno, regcesion.ccalif1, regcesion.ccalif2, NULL,
                         pnsinies, pefepag, pefepag, regcesion.pcesion, regcesion.scesrea,   -- scesrea original
                         02,   -- a sproces...
                            avui, psidepag, 0);
         EXCEPTION
            WHEN OTHERS THEN
               --dbms_output.put_line(SQLERRM);
               codi_error := 104747;
               RETURN(codi_error);
         END;
      END LOOP;

      IF w_trovat = 0 THEN
         w_cgarant := NULL;

         FOR reggar IN cur_garant   -- Es busca la 1ª garantia no null...
                                 LOOP
            w_cgarant := reggar.cgarant;
            EXIT;
         END LOOP;

         IF w_cgarant IS NOT NULL THEN
            FOR regcesion IN cur_cesion6 LOOP
               w_trovat := 1;

               SELECT scesrea.NEXTVAL
                 INTO w_scesrea
                 FROM DUAL;

               w_icesion := (pimportsin * regcesion.pcesion) / 100;

               --w_icesion := f_round(w_icesion,pmoneda);

               -- BUG 0011046 - 04/09/2009 - FAL - Se omite el uso de f_round_forpag
                       --w_icesion := F_Round_Forpag(w_icesion, lcforpag, NULL, lsproduc);
-- FI BUG 0011046 - 04/09/2009 - FAL
               IF pctippag = 3
                  OR pctippag = 7 THEN
                  w_icesion := w_icesion * -1;
               END IF;

               BEGIN
                  INSERT INTO cesionesrea
                              (scesrea, ncesion, icesion, icapces, sseguro,
                               nversio, scontra, ctramo,
                               sfacult, nriesgo, scumulo, cgarant,
                               spleno, ccalif1, ccalif2, nmovimi,
                               nsinies, fefecto, fvencim, pcesion,
                               sproces, cgenera, fgenera, sidepag, nmovigen)
                       VALUES (w_scesrea, regcesion.ncesion, w_icesion, 0, psseguro,
                               regcesion.nversio, regcesion.scontra, regcesion.ctramo,
                               regcesion.sfacult, pnriesgo, regcesion.scumulo, 9999,
                               regcesion.spleno, regcesion.ccalif1, regcesion.ccalif2, NULL,
                               pnsinies, pefepag, pefepag, regcesion.pcesion,
                               regcesion.scesrea,   -- scesrea original
                                                 02,   -- a sproces...
                                                    avui, psidepag, 0);
               EXCEPTION
                  WHEN OTHERS THEN
                     --dbms_output.put_line(SQLERRM);
                     codi_error := 104747;
                     RETURN(codi_error);
               END;
            END LOOP;
         END IF;
      END IF;
   ELSE
      w_trovat := 0;

      FOR regcesion IN cur_cesion1 LOOP
         w_trovat := 1;

         SELECT scesrea.NEXTVAL
           INTO w_scesrea
           FROM DUAL;

         w_icesion := (pimportsin * regcesion.pcesion) / 100;

         --w_icesion := f_round(w_icesion,pmoneda);

         -- BUG 0011046 - 04/09/2009 - FAL - Se omite el uso de f_round_forpag
                --w_icesion := F_Round_Forpag(w_icesion, lcforpag, NULL, lsproduc);
-- FI BUG 0011046 - 04/09/2009 - FAL
         IF pctippag = 3
            OR pctippag = 7 THEN
            w_icesion := w_icesion * -1;
         END IF;

         BEGIN
            INSERT INTO cesionesrea
                        (scesrea, ncesion, icesion, icapces, sseguro,
                         nversio, scontra, ctramo,
                         sfacult, nriesgo, scumulo, cgarant,
                         spleno, ccalif1, ccalif2, nmovimi,
                         nsinies, fefecto, fvencim, pcesion, sproces,
                         cgenera, fgenera, sidepag, nmovigen)
                 VALUES (w_scesrea, regcesion.ncesion, w_icesion, 0, psseguro,
                         regcesion.nversio, regcesion.scontra, regcesion.ctramo,
                         regcesion.sfacult, pnriesgo, regcesion.scumulo, regcesion.cgarant,
                         regcesion.spleno, regcesion.ccalif1, regcesion.ccalif2, NULL,
                         pnsinies, pefepag, pefepag, regcesion.pcesion, regcesion.scesrea,   -- scesrea original
                         02,   -- a sproces...
                            avui, psidepag, 0);
         EXCEPTION
            WHEN OTHERS THEN
               --dbms_output.put_line(SQLERRM);
               codi_error := 104747;
               RETURN(codi_error);
         END;
      END LOOP;

      IF w_trovat = 0 THEN
         FOR regcesion IN cur_cesion2 LOOP
            w_trovat := 1;

            SELECT scesrea.NEXTVAL
              INTO w_scesrea
              FROM DUAL;

            w_icesion := (pimportsin * regcesion.pcesion) / 100;

                   --w_icesion := f_round(w_icesion,pmoneda);
-- BUG 0011046 - 04/09/2009 - FAL - Se omite el uso de f_round_forpag
                   --w_icesion := F_Round_Forpag(w_icesion, lcforpag, NULL, lsproduc);
-- FI BUG 0011046 - 04/09/2009 - FAL
            IF pctippag = 3
               OR pctippag = 7 THEN
               w_icesion := w_icesion * -1;
            END IF;

            BEGIN
               INSERT INTO cesionesrea
                           (scesrea, ncesion, icesion, icapces, sseguro,
                            nversio, scontra, ctramo,
                            sfacult, nriesgo, scumulo, cgarant,
                            spleno, ccalif1, ccalif2, nmovimi,
                            nsinies, fefecto, fvencim, pcesion, sproces,
                            cgenera, fgenera, sidepag, nmovigen)
                    VALUES (w_scesrea, regcesion.ncesion, w_icesion, 0, psseguro,
                            regcesion.nversio, regcesion.scontra, regcesion.ctramo,
                            regcesion.sfacult, pnriesgo, regcesion.scumulo, pcgarant,
                            regcesion.spleno, regcesion.ccalif1, regcesion.ccalif2, NULL,
                            pnsinies, pefepag, pefepag, regcesion.pcesion, regcesion.scesrea,   -- scesrea original
                            02,   -- a sproces...
                               avui, psidepag, 0);
            EXCEPTION
               WHEN OTHERS THEN
                  --dbms_output.put_line(SQLERRM);
                  codi_error := 104747;
                  RETURN(codi_error);
            END;
         END LOOP;
      END IF;
--          END IF;
   END IF;

   IF w_trovat = 0 THEN   -- Si no es trova cap cessió en
      codi_error := 105595;   -- positiu, es torna situació especial...
   END IF;

   RETURN(codi_error);
END;

/

  GRANT EXECUTE ON "AXIS"."F_PAGSINREA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PAGSINREA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PAGSINREA" TO "PROGRAMADORESCSI";
