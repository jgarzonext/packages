--------------------------------------------------------
--  DDL for Function F_DESFRAC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESFRAC" (
   pcramo IN NUMBER,
   pcmodali IN NUMBER,
   pctipseg IN NUMBER,
   pccolect IN NUMBER,
   pcactivi IN NUMBER,
   pcgarant IN NUMBER,
   pcrecfra IN NUMBER,
   pcforpag IN NUMBER,
   psseguro IN NUMBER,
   pnriesgo IN NUMBER,
   piprianu IN NUMBER,
   ptablas IN VARCHAR2
                         /* *************************************************************************
                            Función que te retorna el descuento por la forma de pago.
                           Este descuento se calcula a nivel de garantía.

                           Parámetros:

                             --> PTABLAS ::  Si es nulo vamos sobre las tablas normales si no vamos sobre las
                                tablas 'EST'
                             --> Si informamos del sseguro  y ya esta:
                                Devolvemos el sumatori del descuento que se aplica a todas las garantías vigentes
                               que hay en la póliza.

                             --> Si informamos del sseguro  y del riesgo:
                                Devolvemos el sumatori del descuento que se aplica a todas las garantías vigentes
                               que hay en la póliza a nivel de riesgo.

                             --> Si no informamos del sseguro, es obligatorio informar del ramo, modalidad, tipo , colectivo
                                el código del recargo por fraccionamiento (crecfra de la tabla Seguros) y la forma de pago (cforpag de la tabla SEGUROS.)

                      ***********************************************************************************************/
)
   RETURN NUMBER IS
   vcramo         NUMBER;
   vcmodali       NUMBER;
   vctipseg       NUMBER;
   vccolect       NUMBER;
   vcactivi       NUMBER;
   vcrecfra       NUMBER;
   vcforpag       NUMBER;
   viprianu       NUMBER;
   xprecarg_1     NUMBER := 0;
   xprecarg       NUMBER := 0;
   error          NUMBER;

   --
   -- Garantías a nivel de Póliza o de riesgo dependiendo del parámetro pnriesgo.
   CURSOR cur_garantias(par_sseguro IN NUMBER, par_nriesgo IN NUMBER) IS
      SELECT cgarant, iprianu
        FROM garanseg
       WHERE sseguro = par_sseguro
         AND ffinefe IS NULL   -- Que este vigente
         AND nriesgo = NVL(par_nriesgo, nriesgo);

   --
   -- Garantías a nivel de Póliza o de riesgo dependiendo del parámetro pnriesgo.
   CURSOR cur_garantias_est(par_sseguro IN NUMBER, par_nriesgo IN NUMBER) IS
      SELECT cgarant, iprianu
        FROM estgaranseg
       WHERE sseguro = par_sseguro
         AND ffinefe IS NULL   -- Que este vigente
         AND nriesgo = NVL(par_nriesgo, nriesgo);
BEGIN
   --
   -- Si el sseguro esta informado recurperamos los datos que necesitamos
   IF psseguro IS NOT NULL THEN
      BEGIN
         IF ptablas IS NULL THEN
            SELECT cramo, cmodali, ctipseg, ccolect,
                   pac_seguros.ff_get_actividad(sseguro, pnriesgo), crecfra, cforpag
              INTO vcramo, vcmodali, vctipseg, vccolect,
                   vcactivi, vcrecfra, vcforpag
              FROM seguros
             WHERE sseguro = psseguro;
         ELSE
            SELECT cramo, cmodali, ctipseg, ccolect,
                   pac_seguros.ff_get_actividad(sseguro, pnriesgo, 'EST'), crecfra, cforpag
              INTO vcramo, vcmodali, vctipseg, vccolect,
                   vcactivi, vcrecfra, vcforpag
              FROM estseguros
             WHERE sseguro = psseguro;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            error := 1;
            RETURN 0;
      END;
   --
   -- Si el sseguro no esta informado es obligatorio que la llamada
   -- pasen estos parámetros.
   ELSE
      vcramo := pcramo;
      vcmodali := pcmodali;
      vctipseg := pctipseg;
      vccolect := pccolect;
      vcactivi := pcactivi;
      vcrecfra := pcrecfra;
      vcforpag := pcforpag;
   END IF;

   IF vcrecfra = 1
      AND vcforpag IS NOT NULL THEN
      -- Queremos saber el dto. a nivel de garantía.
      IF psseguro IS NULL
         AND pnriesgo IS NULL THEN
         BEGIN
            SELECT precarg
              INTO xprecarg
              FROM forpagrecgaran
             WHERE cforpag = vcforpag
               AND cramo = vcramo
               AND cmodali = vcmodali
               AND ctipseg = vctipseg
               AND ccolect = vccolect
               AND cactivi = vcactivi
               AND cgarant = pcgarant;

            RETURN ((xprecarg * piprianu) / 100) / vcforpag;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT precarg
                    INTO xprecarg
                    FROM forpagrecacti
                   WHERE cforpag = vcforpag
                     AND cramo = vcramo
                     AND cmodali = vcmodali
                     AND ctipseg = vctipseg
                     AND ccolect = vccolect
                     AND cactivi = vcactivi;

                  RETURN ((xprecarg * piprianu) / 100) / vcforpag;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                        SELECT precarg
                          INTO xprecarg
                          FROM forpagrecprod
                         WHERE cforpag = vcforpag
                           AND cramo = vcramo
                           AND cmodali = vcmodali
                           AND ctipseg = vctipseg
                           AND ccolect = vccolect;

                        RETURN ((xprecarg * piprianu) / 100) / vcforpag;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           BEGIN
                              SELECT precarg
                                INTO xprecarg
                                FROM forpagrec
                               WHERE cforpag = vcforpag;

                              RETURN ((xprecarg * piprianu) / 100) / vcforpag;
                           EXCEPTION
                              WHEN NO_DATA_FOUND THEN
                                 error := 0;   -- FORMA PAG. NO TROBADA A FORPAGREC
                                 RETURN error;
                              WHEN OTHERS THEN
                                 error := 0;   -- ERROR AL LLEGIR DE FORPAGREC
                                 RETURN error;
                           END;
                        WHEN OTHERS THEN
                           error := 0;   -- ERROR AL LLEGIR DE FORPAGREC
                           RETURN error;
                     END;
                  WHEN OTHERS THEN
                     error := 0;   -- ERROR AL LLEGIR DE FORPAGREC
                     RETURN error;
               END;
            WHEN OTHERS THEN
               error := 0;   -- ERROR AL LLEGIR DE FORPAGREC
               RETURN error;
         END;
       --
      -- Si el seguro esta informado y el riesgo no, significa que queremos saber el
      -- dto que hemos de aplicar a nivel de póliza.
      ELSIF psseguro IS NOT NULL
            AND pnriesgo IS NULL THEN
         xprecarg := 0;

         IF ptablas = 'EST' THEN
            FOR cursor1 IN cur_garantias_est(psseguro, NULL) LOOP
               xprecarg_1 := f_desfrac(vcramo, vcmodali, vctipseg, vccolect, vcactivi,
                                       cursor1.cgarant, vcrecfra, vcforpag, NULL, NULL,
                                       cursor1.iprianu, 'EST');
               xprecarg := xprecarg + xprecarg_1;
            END LOOP;
         ELSE
            FOR cursor1 IN cur_garantias(psseguro, NULL) LOOP
               xprecarg_1 := f_desfrac(vcramo, vcmodali, vctipseg, vccolect, vcactivi,
                                       cursor1.cgarant, vcrecfra, vcforpag, NULL, NULL,
                                       cursor1.iprianu, NULL);
               xprecarg := xprecarg + xprecarg_1;
            END LOOP;
         END IF;

         RETURN xprecarg;
       --
      -- Si el seguro esta informado y el riesgo también, significa que queremos saber el
      -- dto que hemos de aplicar a nivel de póliza y riesgo.
      ELSIF psseguro IS NOT NULL
            AND pnriesgo IS NOT NULL THEN
         xprecarg := 0;

         IF ptablas = 'EST' THEN
            FOR cursor1 IN cur_garantias_est(psseguro, pnriesgo) LOOP
               xprecarg_1 := f_desfrac(vcramo, vcmodali, vctipseg, vccolect, vcactivi,
                                       cursor1.cgarant, vcrecfra, vcforpag, NULL, NULL,
                                       cursor1.iprianu, 'EST');
               xprecarg := xprecarg + xprecarg_1;
            END LOOP;
         ELSE
            FOR cursor1 IN cur_garantias(psseguro, pnriesgo) LOOP
               xprecarg_1 := f_desfrac(vcramo, vcmodali, vctipseg, vccolect, vcactivi,
                                       cursor1.cgarant, vcrecfra, vcforpag, NULL, NULL,
                                       cursor1.iprianu, NULL);
               xprecarg := xprecarg + xprecarg_1;
            END LOOP;
         END IF;

         RETURN xprecarg;
      END IF;
   ELSE
      RETURN 0;
   END IF;

   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line(SQLERRM);
      RETURN 0;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESFRAC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESFRAC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESFRAC" TO "PROGRAMADORESCSI";
