--------------------------------------------------------
--  DDL for Package Body PAC_CAMBIOCARTERA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CAMBIOCARTERA" IS
/****************************************************************************

   NOMBRE:       PAC_CAMBIOCARTERA
   PROPÓSITO:  Funciones para cambios en la cartera

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   1.0           -          -               Creació del package
   2.0        17/04/2009   APD              Bug 9685 - primero se ha de buscar para la actividad en concreto
                                            y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
****************************************************************************/
-------------------------------------------------------------------------------
   FUNCTION garanties_noves(
      psproduc_des IN NUMBER,
      pcactivi_des IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pfcaranu IN DATE)
      RETURN NUMBER IS
/******************************************************************************
Només dupliquem les garanties que estiguin en la nova activitat
*******************************************************************************/
      l_c            NUMBER;
      lcactivi       NUMBER;
      l_algun        NUMBER;
      num_err        NUMBER := 0;

      CURSOR c_garpro(wsproduc NUMBER, wcactivi NUMBER) IS
         SELECT cgarant
           FROM garanpro
          WHERE sproduc = wsproduc
            AND cactivi = wcactivi;

      CURSOR c_gar(psseguro NUMBER, pcgarant NUMBER) IS
         SELECT *
           FROM garanseg
          WHERE sseguro = psseguro
            AND cgarant = pcgarant
            AND ffinefe IS NULL;
   BEGIN
      -- Bug 9685 - APD - 17/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
      BEGIN
--     SELECT COUNT(*) INTO l_c
         SELECT cactivi
           INTO lcactivi
           FROM garanpro
          WHERE sproduc = psproduc_des
            AND cactivi = pcactivi_des;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
--       SELECT COUNT(*) INTO l_c
            SELECT cactivi
              INTO lcactivi
              FROM garanpro
             WHERE sproduc = psproduc_des
               AND cactivi = 0;
      END;

      -- Bug 9685 - APD - 17/04/2009 - Fin

      /*
         IF l_c = 0 THEN
            lcactivi := 0;
         ELSE
            lcactivi := pcactivi_des;
         END IF;
      */
      l_algun := 0;

      FOR v_garpro IN c_garpro(psproduc_des, lcactivi) LOOP
         FOR v_gar IN c_gar(psseguro, v_garpro.cgarant) LOOP
            BEGIN
               INSERT INTO garanseg
                           (cgarant, nriesgo, nmovimi, sseguro, finiefe,
                            norden, crevali, ctarifa, icapital,
                            precarg, iextrap, iprianu, ffinefe, cformul,
                            ctipfra, ifranqu, irecarg, ipritar,
                            pdtocom, idtocom, prevali, irevali,
                            itarifa, itarrea, ipritot, icaptot,
                            pdtoint, idtoint, ftarifa, feprev,
                            fpprev, percre, crevalcar, cmatch,
                            tdesmat, pintfin, cref, cintref,
                            pdif, pinttec, nparben, nbns,
                            tmgaran, cderreg, ccampanya, nversio,
                            nmovima, cageven, nfactor, nlinea)
                    VALUES (v_gar.cgarant, v_gar.nriesgo, pnmovimi, v_gar.sseguro, pfcaranu,
                            v_gar.norden, v_gar.crevali, v_gar.ctarifa, v_gar.icapital,
                            v_gar.precarg, v_gar.iextrap, v_gar.iprianu, NULL, v_gar.cformul,
                            v_gar.ctipfra, v_gar.ifranqu, v_gar.irecarg, v_gar.ipritar,
                            v_gar.pdtocom, v_gar.idtocom, v_gar.prevali, v_gar.irevali,
                            v_gar.itarifa, v_gar.itarrea, v_gar.ipritot, v_gar.icaptot,
                            v_gar.pdtoint, v_gar.idtoint, v_gar.ftarifa, v_gar.feprev,
                            v_gar.fpprev, v_gar.percre, v_gar.crevalcar, v_gar.cmatch,
                            v_gar.tdesmat, v_gar.pintfin, v_gar.cref, v_gar.cintref,
                            v_gar.pdif, v_gar.pinttec, v_gar.nparben, v_gar.nbns,
                            v_gar.tmgaran, v_gar.cderreg, v_gar.ccampanya, v_gar.nversio,
                            v_gar.nmovima, v_gar.cageven, v_gar.nfactor, v_gar.nlinea);

               l_algun := 1;
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := 101951;
            END;
         END LOOP;
      END LOOP;

      IF l_algun = 1 THEN
         --
         UPDATE seguros
            SET cactivi = NVL(pcactivi_des, cactivi)
          WHERE sseguro = psseguro;

         --
         UPDATE garanseg
            SET ffinefe = pfcaranu
          WHERE sseguro = psseguro
            AND nmovimi <> pnmovimi
            AND ffinefe IS NULL;
      END IF;

      RETURN num_err;
   END garanties_noves;

-----------------------------------------------------------------------------------
   FUNCTION comprobar_condicion(
      psseguro IN NUMBER,
      psperson IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      pcclave IN NUMBER,
      plimit IN NUMBER,
      pfcaranu IN DATE,
      pdcambio IN VARCHAR2,
      pcumple OUT NUMBER)
      RETURN NUMBER IS
-----------------------------------------------------------------------------------
      num_err        NUMBER := 0;
      lsesion        NUMBER;
      valor          NUMBER;
      formula        VARCHAR2(100);
      parms_transitorios pac_parm_tarifas.parms_transitorios_tabtyb;
      l_sn           NUMBER;
      l_sseguro      NUMBER;
      l_csituac      NUMBER;
      l_pol          VARCHAR2(15);

--lproducte VARCHAR2(4);
--lproducte_dos VARCHAR2(4);
--lmoneda  NUMBER;

      /****
         Ho fem a pinyó amb el texte de la taula, ja ho implementarem més endavant
      ***/
      CURSOR c_rie(wsseguro NUMBER) IS
         SELECT nriesgo
           FROM riesgos
          WHERE sseguro = wsseguro
            AND fanulac IS NULL;
   BEGIN
      pcumple := 0;

      IF pdcambio = 'ANUALIDAD' THEN
         -- Si renova, segur que ja no és la primera anualitat, i per tant ja no entraria
         -- amb aquesta activitat
         pcumple := 1;
      ELSIF pdcambio = 'OTROSEGURO' THEN
         -- Cal mirar si te contractada una altra pòlissa
         -- Aixó s'informa a unes preguntes , que de moment  informem el codi a cclave i nlimit
         -- La resposta es el número de certificat
         FOR v_rie IN c_rie(psseguro) LOOP
            BEGIN
               SELECT crespue
                 INTO l_sn
                 FROM pregunseg
                WHERE sseguro = psseguro
                  AND nriesgo = v_rie.nriesgo
                  AND cpregun = pcclave
                  AND nmovimi = (SELECT MAX(nmovimi)
                                   FROM pregunseg
                                  WHERE sseguro = psseguro
                                    AND nriesgo = v_rie.nriesgo);

               IF l_sn = 0 THEN   -- 0-Si/1-No
                  SELECT crespue
                    INTO l_pol
                    FROM pregunseg
                   WHERE sseguro = psseguro
                     AND nriesgo = v_rie.nriesgo
                     AND cpregun = plimit
                     AND nmovimi = (SELECT MAX(nmovimi)
                                      FROM pregunseg
                                     WHERE sseguro = psseguro
                                       AND nriesgo = v_rie.nriesgo);

                  -- Convertir
                  BEGIN
                     SELECT sseguro
                       INTO l_sseguro
                       FROM cnvpolizas
                      WHERE ram = pcramo
                        AND moda = pcmodali
                        AND tipo = pctipseg
                        AND cole = pccolect
                        AND polissa_ini = l_pol
                        AND EXISTS(SELECT sseguro
                                     FROM seguros
                                    WHERE sseguro = cnvpolizas.sseguro
                                      AND csituac >= 7);

                     BEGIN
                        IF l_sseguro IS NOT NULL THEN
                           SELECT csituac
                             INTO l_csituac
                             FROM seguros
                            WHERE sseguro = l_sseguro;

                           IF l_csituac IN(2, 3) THEN
                              -- Esta anulada, per tant canviem la pòlissa
                              pcumple := 1;
                           END IF;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
                           pcumple := 0;
                     END;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        -- Si no trobem la conversió, no podem obtenir el certificat associat
                        pcumple := 0;
                     WHEN OTHERS THEN
                        num_err := 110420;
                  END;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  pcumple := 0;
               WHEN OTHERS THEN
                  num_err := 110420;
            END;
         END LOOP;
      END IF;

      RETURN num_err;
   END comprobar_condicion;

/************** JA HO FAREM **********************************************
 comprobar_condicion
   -- Seleccionamos el número de sesión del proceso.
   SELECT sgt_sesiones.nextval
     INTO lsesion
   FROM dual;

   -- Guardem les dades del risc
   num_err := pac_parm_tarifas.insertar_parametros_riesgo(lsesion,psseguro,psperson,pcramo,
                                   pcmodali, pctipseg, pccolect, pcactivi, null ,null ,null,0,'SEG',
                                   parms_transitorios);
   -- Avaluem la formula
   IF pcclave IS NOT NULL THEN
      BEGIN
         SELECT formula
         INTO   formula
         FROM   sgt_formulas
         WHERE  clave = pcclave;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 108423;
      END;

      -- Inserto el parámetro de la fecha de efecto
      BEGIN
        -- INSERT INTO sgt_parms_transitorios(sesion,parametro,valor) VALUES
        --                                   (lsesion,'FECEFE',
        --                                    to_number(to_char(pfcaranu,'yyyymmdd')));
         vnerror := pac_sgt.put(lsesion, 'FECEFE', to_number(to_char(pfcaranu,'yyyymmdd')));

         IF vnerror <> 0 THEN
            RETURN 108438;
         END IF;
      EXCEPTION
         WHEN others THEN
            RETURN 108797;
      END;

      pac_parm_tarifas.inserta_parametro(lsesion, pcclave, 0,
                                        parms_transitorios,num_err);

      IF num_err = 0 THEN
         valor := pk_formulas.eval(formula,lsesion);
         IF valor > plimit THEN
            pcumple := 1;
         END IF;
      END IF;
      pac_parm_tarifas.borra_parametro(lsesion,pcclave);
   END IF;
************************ FI DE JA HO FAREM *******/

   -----------------------------------------------------------------------------------
   FUNCTION cambiocartera(
      pmodo IN VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      psseguro IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pfcaranu IN DATE,
      pnsuplem IN NUMBER,
      pcumple OUT NUMBER,
      pcactivides OUT NUMBER)
      RETURN NUMBER IS
-----------------------------------------------------------------------------------
      num_err        NUMBER := 0;
      ltrobat        NUMBER := 0;
      lsproddes      NUMBER;
      lcactivides    NUMBER;
      lcclave        NUMBER;
      lnlimit        NUMBER;
      lnmovimi       NUMBER;
      ldcambio       VARCHAR2(40);

      CURSOR c_rie(wsseguro IN NUMBER) IS
         SELECT nriesgo, sperson
           FROM riesgos
          WHERE sseguro = wsseguro
            AND fanulac IS NULL;
   BEGIN
      pcumple := 0;

      -- Veure si existeix la possibilitat de canvi
      BEGIN
         SELECT sproddes, cactivides, cclave, nlimit, dcambio
           INTO lsproddes, lcactivides, lcclave, lnlimit, ldcambio
           FROM cambiocartera
          WHERE sprodor = psproduc
            AND cactivior = pcactivi;

         ltrobat := 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            ltrobat := 0;
         WHEN OTHERS THEN
            ltrobat := 0;
            num_err := -1;
      END;

      IF ltrobat = 1 THEN
         -- Comprobar condición
         num_err := comprobar_condicion(psseguro, NULL, pcramo, pcmodali, pctipseg, pccolect,
                                        pcactivi, lcclave, lnlimit, pfcaranu, ldcambio,
                                        pcumple);

         IF pcumple = 1
            AND num_err = 0 THEN
--dbms_output.put_line(' CUMPLE ');
            IF pmodo = 'R' THEN
               -- Crear suplement de canvi d'activitat
               num_err := f_movseguro(psseguro, NULL, 295, 1, pfcaranu, NULL, pnsuplem + 1,
                                      NULL, NULL, lnmovimi, f_sysdate, NULL);

               IF num_err = 0 THEN
                  -- Duplicar garanties, i esborrar les que sobren ????
                  num_err := garanties_noves(lsproddes, lcactivides, psseguro, lnmovimi,
                                             pfcaranu);

                  IF num_err = 0 THEN
                     pcactivides := lcactivides;
                  END IF;
               END IF;
            ELSE   -- modo P
--dbms_output.put_line(' Previo ');
               pcactivides := lcactivides;
            END IF;
         END IF;
      END IF;

--dbms_output.put_line(' previo y actividad '||pcactivides);
      RETURN num_err;
   END cambiocartera;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_CAMBIOCARTERA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CAMBIOCARTERA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CAMBIOCARTERA" TO "PROGRAMADORESCSI";
