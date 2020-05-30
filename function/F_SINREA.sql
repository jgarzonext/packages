--------------------------------------------------------
--  DDL for Function F_SINREA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_SINREA" (
   psidepag IN NUMBER,
   pmoneda IN NUMBER,
   pnsinies IN NUMBER DEFAULT NULL,
   pctippag IN NUMBER DEFAULT NULL,
   pfefepag IN DATE DEFAULT NULL,
   pcpagcoa IN NUMBER DEFAULT NULL)
   RETURN NUMBER AUTHID CURRENT_USER IS
   /***********************************************************************
      F_SINREA:    Aquesta funció permet crear moviments d'abonament, per
                      part de les companyies de reassegurança, en concepte dels
                      pagaments de sinistres.
                      Busca el desglos d'un pagament en seguro/riscos/garanties
                      i, per cada garantia, crida a la funció F_PAGSINREA.
      ALLIBREA
   ***********************************************************************/
   codi_error     NUMBER := 0;
   w_nsinies      pagosini.nsinies%TYPE;   --    w_nsinies      NUMBER(8); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_sseguro      siniestros.sseguro%TYPE;   --    w_sseguro      NUMBER(6); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_nriesgo      siniestros.nriesgo%TYPE;   --    w_nriesgo      NUMBER(6); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_fsinies      siniestros.fsinies%TYPE;   --    w_fsinies      DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_ctippag      pagosini.ctippag%TYPE;   --    w_ctippag      NUMBER(1); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_cramo        seguros.cramo%TYPE;   --    w_cramo        NUMBER(8); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_cmodali      seguros.cmodali%TYPE;   --    w_cmodali      NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_ctipseg      seguros.ctipseg%TYPE;   --    w_ctipseg      NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_ccolect      seguros.ccolect%TYPE;   --    w_ccolect      NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_cactivi      seguros.cactivi%TYPE;   --    w_cactivi      NUMBER(4); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_creaseg      NUMBER(1);
   w_ctipcoa      seguros.ctipcoa%TYPE;   --    w_ctipcoa      NUMBER(1); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_plocal       coacuadro.ploccoa%TYPE;   --    w_plocal       NUMBER(5, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_ncuadro      NUMBER(6);
   w_isinret      NUMBER(13, 2);
   w_fefepag      pagosini.fordpag%TYPE;   --    w_fefepag      DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_ctiprea      seguros.ctiprea%TYPE;   --    w_ctiprea      NUMBER(1); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_cpagcoa      pagosini.cpagcoa%TYPE;   --    w_cpagcoa      NUMBER(2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   hiha           NUMBER := 0;
   --
   w_sproduc      seguros.sproduc%TYPE;

   CURSOR cur_gar IS
      SELECT cgarant, isinret
        FROM pagogarantia
       WHERE sidepag = psidepag;
BEGIN
   -- ES BUSCA EL Nº DE SINISTRE DEL PAGAMENT...
   IF pnsinies IS NOT NULL THEN
      w_nsinies := pnsinies;
      w_ctippag := pctippag;
      w_fefepag := pfefepag;
      w_cpagcoa := pcpagcoa;
   ELSE
      BEGIN
         SELECT nsinies, ctippag, fordpag, cpagcoa
           INTO w_nsinies, w_ctippag, w_fefepag, w_cpagcoa
           FROM pagosini
          WHERE sidepag = psidepag;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            codi_error := 104756;
            RETURN(codi_error);
         WHEN OTHERS THEN
            codi_error := 102697;
            RETURN(codi_error);
      END;
   END IF;

   -- ES BUSCA EL SEGURO, EL RISC DEL SINISTRE I LA DATA DEL SINISTRE...
   BEGIN
      SELECT sseguro, nriesgo, fsinies
        INTO w_sseguro, w_nriesgo, w_fsinies
        FROM siniestros
       WHERE nsinies = w_nsinies;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         codi_error := 104755;
         RETURN(codi_error);
      WHEN OTHERS THEN
         codi_error := 102694;
         RETURN(codi_error);
   END;

   -- AQUI ES MIRA SI EL PRODUCTE GLOBAL ES REASSEGURA, O BE SI LA REASSEGURANÇA
   -- INDIVIDUALMENT ES REASSEGURA...
   BEGIN
      SELECT cramo, cmodali, ctipseg, ccolect, cactivi, ctipcoa, ctiprea,
             sproduc
        INTO w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi, w_ctipcoa, w_ctiprea,
             w_sproduc
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

   IF w_ctiprea = 2 THEN
      RETURN(0);   -- Seguro no reassegurat...
   END IF;

   -- Mantis 11845.12/2009.NMM.CRE - Ajustar reassegurança d'estalvi .i.
   IF pac_cesionesrea.producte_reassegurable(w_sproduc) = 0 THEN
      /*BEGIN
         SELECT creaseg
           INTO w_creaseg
           FROM productos
          WHERE cramo = w_cramo
            AND cmodali = w_cmodali
            AND ctipseg = w_ctipseg
            AND ccolect = w_ccolect;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            codi_error := 104347;
            RETURN(codi_error);
         WHEN OTHERS THEN
            codi_error := 102705;
            RETURN(codi_error);
      END;

      IF w_creaseg = 0 THEN*/
      RETURN(0);   -- Producte no reassegurat...
   END IF;

   -- AQUI ES MIRA SI L'ASSEGURANÇA ES DE COASSEGURO...
   w_plocal := 100;

   IF w_ctipcoa = 1
      OR w_ctipcoa = 2 THEN
      -- Es de coasseguro cedit (l'acceptat s'entra només la nostra part)
      -- Cal comprovar si el pagament és o no per la totalitat
      IF w_cpagcoa = 1 THEN   -- Pagament pel total
         BEGIN
            SELECT ploccoa
              INTO w_plocal
              FROM coacuadro
             WHERE sseguro = w_sseguro
               AND w_fsinies >= finicoa
               AND(w_fsinies < ffincoa
                   OR ffincoa IS NULL);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               w_plocal := 100;
            WHEN OTHERS THEN
               codi_error := 105447;
               RETURN(codi_error);
         END;
      ELSE
         -- cpagcoa = 2 ( El pagament és per la nostra part)
         w_plocal := 100;
      END IF;
   END IF;

   -- ES BUSQUEN LES GARANTIES I IMPORTS AFECTADES PER EL PAGAMENT...
   FOR reggar IN cur_gar LOOP
      w_isinret := (reggar.isinret * w_plocal) / 100;

      IF reggar.cgarant = 9999 THEN   -- Garantía 9999(despeses sinistre),
         w_creaseg := 1;   -- es reassegura sempre...
      ELSE
         -- BUG 11100 - 16/09/2009 - FAL - Crida a la pac_cesionesrea.f_gar_rea per si garantia reasegurable
         codi_error := pac_cesionesrea.f_gar_rea(w_cramo, w_cmodali, w_ctipseg, w_ccolect,
                                                 w_cactivi, reggar.cgarant, w_creaseg);

         /*
         BEGIN                                 -- Aquí es mira si la garantía
            SELECT creaseg                                 -- es reassegura...
              INTO w_creaseg
              FROM garanpro
             WHERE cramo = w_cramo
               AND cmodali = w_cmodali
               AND ctipseg = w_ctipseg
               AND ccolect = w_ccolect
               AND cactivi = w_cactivi
               AND cgarant = reggar.cgarant;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               BEGIN
                  SELECT creaseg
                    INTO w_creaseg
                    FROM garanpro
                   WHERE cramo = w_cramo
                     AND cmodali = w_cmodali
                     AND ctipseg = w_ctipseg
                     AND ccolect = w_ccolect
                     AND cactivi = 0
                     AND cgarant = reggar.cgarant;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     codi_error := 104110;
                     RETURN (codi_error);
                  WHEN OTHERS
                  THEN
                     codi_error := 103503;
                     RETURN (codi_error);
               END;
            WHEN OTHERS
            THEN
               codi_error := 103503;
               RETURN (codi_error);
         END;
         */
         IF codi_error <> 0 THEN
            RETURN codi_error;
         END IF;
      --FI BUG 11100 - 16/09/2009 – FAL
      END IF;

      IF w_creaseg <> 0 THEN   -- Garantía que es reassegura...
         -- BUG 11051 - 22/09/2009 - FAL - Afegir control de existència del pagament a PAGOSSINCES
         SELECT COUNT(*)
           INTO hiha
           FROM pagossinces
          WHERE sidepag = psidepag;

         IF hiha = 0 THEN
            codi_error := f_pagsinrea(w_sseguro, w_nriesgo, reggar.cgarant, w_nsinies,
                                      w_fsinies, w_isinret, pmoneda, w_ctippag, w_fefepag,
                                      psidepag);
         ELSE
            p_tab_error(f_sysdate, f_user, 'f_sin_rea', 1,
                        'parámetros - psidepag:' || psidepag, 'Pago ya existe en pagossinces');
         END IF;

         --FI BUG 11051 - 22/09/2009 – FAL
         IF codi_error = 105595 THEN   -- No s´ha trovat cap cessió de prima.
            --           ALTA A TAULA...
            BEGIN
               INSERT INTO pagossinces
                           (sidepag, nsinies, fsinies, sseguro, nriesgo,
                            cgarant, ctippag, fefepag, isinret, fgenera,
                            crevisi, frevisi, cusuari)
                    VALUES (psidepag, w_nsinies, w_fsinies, w_sseguro, w_nriesgo,
                            reggar.cgarant, w_ctippag, w_fefepag, reggar.isinret, f_sysdate,
                            1, NULL, NULL);
            EXCEPTION
               WHEN OTHERS THEN
                  codi_error := 105612;
                  RETURN(codi_error);
            END;

            codi_error := 0;
         ELSIF codi_error <> 0 THEN
            RETURN(codi_error);
         END IF;
      END IF;
   END LOOP;

   RETURN(codi_error);
END f_sinrea;

/

  GRANT EXECUTE ON "AXIS"."F_SINREA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_SINREA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_SINREA" TO "PROGRAMADORESCSI";
