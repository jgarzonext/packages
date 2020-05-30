--------------------------------------------------------
--  DDL for Function F_RETARIFAR_RIESGO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_RETARIFAR_RIESGO" (
   psseguro IN NUMBER,
   pnriesgo IN NUMBER,
   pmoneda IN NUMBER,
   pmensa IN OUT VARCHAR2)
   RETURN NUMBER AUTHID CURRENT_USER IS
   num_err        NUMBER;
   ssproces       NUMBER;
   nnmovimi       NUMBER;
   ffefecto       DATE;
   pprima_minima  NUMBER;
   ptotal_prima   NUMBER;
   r_seguro       seguros%ROWTYPE;

   PROCEDURE p_borrado_tablas(psproces IN NUMBER, psseguro IN NUMBER) IS
   BEGIN
      DELETE      pregungarancar
            WHERE sseguro = psseguro
              AND sproces = psproces;

      DELETE      preguncar
            WHERE sseguro = psseguro
              AND sproces = psproces;

      DELETE      tmp_garancar
            WHERE sseguro = psseguro
              AND sproces = psproces;
   END p_borrado_tablas;

   PROCEDURE p_recuperar_resultado(
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER) IS
      CURSOR c(proces IN NUMBER) IS
         SELECT *
           FROM tmp_garancar
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND sproces = proces;

      CURSOR preguntas_riesgo(proces IN NUMBER) IS
         SELECT *
           FROM preguncar
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND sproces = proces
            AND crespue IS NOT NULL;
   BEGIN
      --{Traspasamos las preguntas a nivel de riesgo.}
      FOR h IN preguntas_riesgo(psproces) LOOP
         BEGIN
            INSERT INTO pregunseg
                        (sseguro, nriesgo, cpregun, nmovimi, crespue)
                 VALUES (h.sseguro, h.nriesgo, h.cpregun, pnmovimi, h.crespue);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE pregunseg
                  SET crespue = h.crespue
                WHERE sseguro = h.sseguro
                  AND nriesgo = h.nriesgo
                  AND nmovimi = h.nmovimi
                  AND cpregun = h.cpregun;
         END;
      END LOOP;

      FOR i IN c(psproces) LOOP
         BEGIN
            INSERT INTO garanseg
                        (iprianu, icapital, icaptot, ipritot,
                         ipritar, crevali, ctarifa, precarg, iextrap,
                         cformul, ctipfra, ifranqu, irecarg, pdtocom, idtocom,
                         prevali, irevali, itarifa, sseguro, nriesgo, cgarant,
                         finiefe, nmovimi, norden)
                 VALUES (NVL(i.iprianu, 0), i.icapital, i.icaptot, NVL(i.ipritot, 0),
                         NVL(i.ipritar, 0), i.crevali, i.ctarifa, i.precarg, i.iextrap,
                         i.cformul, i.ctipfra, i.ifranqu, i.irecarg, i.pdtocom, i.idtocom,
                         i.prevali, i.irevali, i.itarifa, i.sseguro, i.nriesgo, i.cgarant,
                         i.finiefe, pnmovimi, i.norden);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE garanseg
                  SET iprianu = NVL(i.iprianu, 0),
                      icapital = i.icapital,
                      icaptot = i.icapital,
                      ipritot = NVL(i.iprianu, 0),
                      ipritar = NVL(i.ipritar, 0),
                      crevali = i.crevali,
                      ctarifa = i.ctarifa,
                      precarg = i.precarg,
                      iextrap = i.iextrap,
                      cformul = i.cformul,
                      ctipfra = i.ctipfra,
                      ifranqu = i.ifranqu,
                      irecarg = i.irecarg,
                      pdtocom = i.pdtocom,
                      idtocom = i.idtocom,
                      prevali = i.prevali,
                      irevali = i.irevali,
                      itarifa = i.itarifa
                WHERE sseguro = i.sseguro
                  AND nriesgo = i.nriesgo
                  AND cgarant = i.cgarant
                  AND nmovimi = NVL(pnmovimi, 1);
         END;
      END LOOP;

      DELETE FROM pregungaranseg
            WHERE sseguro = psseguro
              AND nriesgo = pnriesgo
              AND nmovimi = NVL(pnmovimi, 1);

      INSERT INTO pregungaranseg
                  (sseguro, nriesgo, cgarant, nmovimi, cpregun, crespue, nmovima, finiefe,
                   trespue)
         SELECT sseguro, nriesgo, cgarant, nmovimi, cpregun, crespue, nmovima, finiefe,
                trespue
           FROM pregungarancar
          WHERE sproces = psproces
            AND crespue IS NOT NULL
            AND sseguro = psseguro
            AND nriesgo = pnriesgo;
   END p_recuperar_resultado;
BEGIN
   SELECT sproces.NEXTVAL
     INTO ssproces
     FROM DUAL;

   --{obtenemos los datos del seguro}
   BEGIN
      SELECT *
        INTO r_seguro
        FROM seguros
       WHERE sseguro = psseguro;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 101903;   --{Asegurança no trobada a la taula seguros}
   END;

   --{obtenemos el movimiento último de las grantias del riesgo}
   SELECT MAX(nmovimi)
     INTO nnmovimi
     FROM garanseg
    WHERE sseguro = psseguro
      AND nriesgo = pnriesgo;

   --{obtenemos la última fecha de efecto, del  movimiento último}
   SELECT MAX(fefecto)
     INTO ffefecto
     FROM movseguro
    WHERE sseguro = psseguro
      AND nmovimi = nnmovimi;

   num_err := pac_tarifas.f_tmpgarancar(NULL, ssproces, psseguro, pnriesgo, nnmovimi);

   IF num_err <> 0 THEN
      RETURN num_err;
   END IF;

   num_err := pac_tarifas.f_tarifar_126(ssproces, NULL, 'TAR', 'R', r_seguro.cramo,
                                        r_seguro.cmodali, r_seguro.ctipseg, r_seguro.ccolect,
                                        r_seguro.sproduc,
                                        pac_seguros.ff_get_actividad(r_seguro.sseguro,
                                                                     pnriesgo),
                                        NULL, NULL, r_seguro.sseguro, pnriesgo, ffefecto,
                                        ffefecto, 1, r_seguro.cobjase, r_seguro.cforpag, 1,
                                        TO_CHAR(ffefecto, 'MM'), TO_CHAR(ffefecto, 'YYYY'),
                                        pmoneda, NULL, pprima_minima, ptotal_prima, pmensa);

   --DBMS_OUTPUT.put_line('finalizado el proceso de tarifar ');
   IF num_err <> 0 THEN
      RETURN num_err;
   END IF;

   --{recuperamos los datos despues de haber tarifado}
   p_recuperar_resultado(ssproces, psseguro, pnriesgo, nnmovimi);
   --{borramos las tablas temporales}
   p_borrado_tablas(ssproces, psseguro);

   -- {Actualizamos el total del seguro, despues de tarifar}
   UPDATE seguros
      SET iprianu = f_segprima(psseguro, ffefecto)
    WHERE sseguro = psseguro;

   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'f_retarifar_riesgo', 1, SQLERRM, SQLERRM);
      RETURN 151626;   --{Error al re-tarifar}
END f_retarifar_riesgo;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_RETARIFAR_RIESGO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_RETARIFAR_RIESGO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_RETARIFAR_RIESGO" TO "PROGRAMADORESCSI";
