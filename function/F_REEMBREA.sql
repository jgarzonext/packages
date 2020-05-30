--------------------------------------------------------
--  DDL for Function F_REEMBREA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_REEMBREA" (
   psseguro IN NUMBER,
   pnriesgo IN NUMBER,
   pcgarant IN NUMBER,
   pnreemb IN NUMBER,
   pnfact IN NUMBER,
   pnlinea IN NUMBER,
   pfacto IN DATE,
   pipago IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
   /***********************************************************************
      F_REEMBREA:     Aquesta funció permet crear moviments d'abonament, per
                      part de les companyies de reassegurança, en concepte dels
                      pagaments de Reembossaments.
                      Busca el desglos d'un pagament en seguro/riscos/garanties
                      i, per cada garantia, crida a la funció F_PAGSINREA.
      ALLIBREA
   ***********************************************************************/
   w_cramo        seguros.cramo%TYPE;
   w_cmodali      seguros.cmodali%TYPE;
   w_ctipseg      seguros.ctipseg%TYPE;
   w_ccolect      seguros.ccolect%TYPE;
   w_cactivi      garanpro.cactivi%TYPE;
   w_creaseg      productos.creaseg%TYPE;
   w_ctipcoa      seguros.ctipcoa%TYPE;
   w_isinret      NUMBER;
   w_plocal       coacuadro.ploccoa%TYPE;
   w_ctiprea      seguros.ctiprea%TYPE;
   w_cpagcoa      NUMBER(2);
   codi_error     NUMBER := 0;
   --
   w_sproduc      productos.sproduc%TYPE;
--
BEGIN
   -- AQUI ES MIRA SI EL PRODUCTE GLOBAL ES REASSEGURA, O BE SI LA REASSEGURANÇA
   -- INDIVIDUALMENT ES REASSEGURA...
   BEGIN
      SELECT cramo, cmodali, ctipseg, ccolect,
             pac_seguros.ff_get_actividad(sseguro, pnriesgo), ctipcoa, ctiprea, sproduc
        INTO w_cramo, w_cmodali, w_ctipseg, w_ccolect,
             w_cactivi, w_ctipcoa, w_ctiprea, w_sproduc
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
             WHERE sseguro = psseguro
               AND pfacto >= finicoa
               AND(pfacto < ffincoa
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
   BEGIN
      w_isinret := (pipago * w_plocal) / 100;
      --DBMS_OUTPUT.put_line('cramo = ' || w_cramo || ' cmodali = ' || w_cmodali
      --                     || ' ctipseg = ' || w_ctipseg || ' ccolect = ' || w_ccolect
      --                     || ' cactivi = ' || w_cactivi || ' cgarant = ' || pcgarant);

      -- BUG 11100 - 16/09/2009 - FAL - Crida a la pac_cesionesrea.f_gar_rea per si garantia reasegurable
      codi_error := pac_cesionesrea.f_gar_rea(w_cramo, w_cmodali, w_ctipseg, w_ccolect,
                                              w_cactivi, pcgarant, w_creaseg);

      /*
      BEGIN   -- Aquí es mira si la garantía
         SELECT creaseg   -- es reassegura...
           INTO w_creaseg
           FROM garanpro
          WHERE cramo = w_cramo
            AND cmodali = w_cmodali
            AND ctipseg = w_ctipseg
            AND ccolect = w_ccolect
            AND cactivi = w_cactivi
            AND cgarant = pcgarant;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT creaseg
                 INTO w_creaseg
                 FROM garanpro
                WHERE cramo = w_cramo
                  AND cmodali = w_cmodali
                  AND ctipseg = w_ctipseg
                  AND ccolect = w_ccolect
                  AND cactivi = 0
                  AND cgarant = pcgarant;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  codi_error := 104110;
                  RETURN(codi_error);
               WHEN OTHERS THEN
                  codi_error := 103503;
                  RETURN(codi_error);
            END;
         WHEN OTHERS THEN
            codi_error := 103503;
            RETURN(codi_error);
      END;
      */
      IF codi_error <> 0 THEN
         RETURN codi_error;
      END IF;

      --FI BUG 11100 - 16/09/2009 – FAL
      IF w_creaseg <> 0 THEN   -- Garantía que es reassegura...
         codi_error := f_pagreembrea(psseguro, pnriesgo, pcgarant, pnreemb, pnfact, pnlinea,
                                     pfacto, pipago);

         -- BUG 20836 - 04/04/2012 - JMP - Error cessions reemborsaments
         IF codi_error = 105595 THEN
            INSERT INTO reembsinces
                        (sseguro, nriesgo, cgarant, nreemb, nfact, nlinea, fefecto,
                         ipago, fgenera, crevisi, frevisi, cusuari)
                 VALUES (psseguro, pnriesgo, pcgarant, pnreemb, pnfact, pnlinea, pfacto,
                         pipago, f_sysdate, 1, NULL, NULL);
         END IF;

         -- FIN BUG 20836 - 04/04/2012 - JMP -
         IF codi_error <> 0 THEN
            RETURN(codi_error);
         END IF;
      END IF;
   END;

   RETURN(codi_error);
END f_reembrea;

/

  GRANT EXECUTE ON "AXIS"."F_REEMBREA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_REEMBREA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_REEMBREA" TO "PROGRAMADORESCSI";
