--------------------------------------------------------
--  DDL for Function F_CAPITAL_CUMUL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CAPITAL_CUMUL" (
   pctiprea IN NUMBER,
   pscumulo IN NUMBER,
   pfecini IN DATE,
   pcgarant IN NUMBER,
   pcapital IN OUT NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***********************************************************************
   f_capital_cumul        : Buscar el capital d'un cumul.
***********************************************************************/
   perr           NUMBER := 0;
   w_sseguro      NUMBER;
   w_nriesgo      NUMBER(6);
   w_cgarant      NUMBER(4);
   w_cramo        NUMBER(8);
   w_cmodali      NUMBER(2);
   w_ctipseg      NUMBER(2);
   w_ccolect      NUMBER(2);
   w_creaseg      NUMBER(1);
   w_cactivi      NUMBER(4);
   v_fefecto      DATE;   --29011 AVT 13/11/13

   CURSOR cur_reariesgos IS
      SELECT sseguro, nriesgo, cgarant, freaini
        FROM reariesgos
       WHERE scumulo = pscumulo
         AND freaini <= NVL(v_fefecto, pfecini)   --29011 AVT 13/11/13
         AND(freafin IS NULL
             OR freafin > pfecini)
         AND(cgarant = pcgarant
             OR cgarant IS NULL);   -- 13195 01-03-2010 AVT

   CURSOR cur_garanseg IS
      SELECT icapital, cgarant
        FROM garanseg
       WHERE sseguro = w_sseguro
         AND nriesgo = w_nriesgo
         AND(cgarant = w_cgarant
             OR w_cgarant IS NULL)
         AND ffinefe IS NULL;
BEGIN
   IF pctiprea = 1 THEN
      pcapital := 0;

      -- 29011 AVT 13/11/13
      SELECT MAX(freaini)
        INTO v_fefecto
        FROM reariesgos r
       WHERE r.scumulo = pscumulo
         AND(r.freafin > pfecini
             OR r.freafin IS NULL);

      FOR regcumul IN cur_reariesgos LOOP
         w_sseguro := regcumul.sseguro;
         w_nriesgo := regcumul.nriesgo;
         w_cgarant := regcumul.cgarant;

         BEGIN
            SELECT cramo, cmodali, ctipseg, ccolect,
                   pac_seguros.ff_get_actividad(sseguro, w_nriesgo)
              INTO w_cramo, w_cmodali, w_ctipseg, w_ccolect,
                   w_cactivi
              FROM seguros
             WHERE sseguro = w_sseguro;
         EXCEPTION
            WHEN OTHERS THEN
               perr := 101919;
         END;

         FOR reggaranseg IN cur_garanseg LOOP
-- BUG 11100 - 16/09/2009 - FAL - Crida a la pac_cesionesrea.f_gar_rea per si garantia reasegurable
            perr := pac_cesionesrea.f_gar_rea(w_cramo, w_cmodali, w_ctipseg, w_ccolect,
                                              w_cactivi, reggaranseg.cgarant, w_creaseg);

            IF w_creaseg = 1
               OR w_creaseg = 3 THEN
               pcapital := pcapital + NVL(reggaranseg.icapital, 0);
            END IF;
         END LOOP;
      END LOOP;
   ELSE   -- tipus de contracte amb import propi fixe, no cal sumar capitals per trobar
          -- les proporcions
      --DBMS_OUTPUT.PUT_LINE(' ------------ f_capital_cumul RETORNA NULL -----------');
      NULL;
   END IF;

   RETURN(perr);
END f_capital_cumul;

/

  GRANT EXECUTE ON "AXIS"."F_CAPITAL_CUMUL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CAPITAL_CUMUL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CAPITAL_CUMUL" TO "PROGRAMADORESCSI";
