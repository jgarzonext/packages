--------------------------------------------------------
--  DDL for Function F_ACPROXCAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ACPROXCAR" (
   psseguro IN NUMBER,
   pfcarant IN OUT DATE,
   pfcarpro IN OUT DATE,
   pfcaranu IN OUT DATE,
   pnanuali IN OUT NUMBER,
   pnfracci IN OUT NUMBER,
   pfrenova IN OUT DATE)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***********************************************************************
   F_ACPROXCAR : Actualiza los campos fcarpro, fcaranu, nanuali, nfracci,
pfcarant de la tabla SEGUROS para la próxima cartera.
   ALLIBCTR - Gestión de datos referentes a los seguros
Si pfcarpro es null se buscan los datos de SEGUROS
Si no es null sólo se busca cforpag(inform.prev.carter)
Se pasa el parámetro 'dia' a la funcion f_summeses
************************************************************************/
   pcforpag       NUMBER;
   meses          NUMBER;
   pndurcob       NUMBER;
   max_nfracci    NUMBER;
   dia            VARCHAR2(2);
   pnrenova       NUMBER;
   vmeses         NUMBER;
   vfrenova       DATE;
   verror         NUMBER;
   vnmovimi       NUMBER;
   vsproduc       NUMBER;
   vcduraci       NUMBER;
   vnpoliza       NUMBER;
   vresp4092      NUMBER;
   vresp4790      NUMBER;
   vsseguropad    NUMBER;
BEGIN
   IF pfcarpro IS NULL THEN
      BEGIN
         SELECT DECODE(cforpag, 0, 1, cforpag), fcarpro, fcaranu, nanuali, nfracci, ndurcob,
                nrenova, frenova, sproduc, npoliza
           INTO pcforpag, pfcarpro, pfcaranu, pnanuali, pnfracci, pndurcob,
                pnrenova, pfrenova, vsproduc, vnpoliza
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 101867;   --Error en la funcion acproxcar
      END;
   ELSE
      BEGIN
         SELECT DECODE(cforpag, 0, 1, cforpag), nrenova, sproduc, npoliza
           INTO pcforpag, pnrenova, vsproduc, vnpoliza
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 101867;   --Error en la funcion acproxcar
      END;
   END IF;

   meses := 12 / pcforpag;
   max_nfracci := pcforpag;

   IF pnrenova IS NULL THEN
      RETURN 104510;   -- Fecha de renovacion (mmyy)incorrecta
   ELSE
      dia := SUBSTR(LPAD(pnrenova, 4, '0'), 3, 2);
   END IF;

   pfcarant := pfcarpro;

   IF pfcarpro = pfcaranu THEN
      IF pfrenova IS NOT NULL THEN
         IF pfrenova <> pfcaranu THEN   -- Se ha hecho suplementos de renovación
            pfcarpro := f_summeses(pfcarpro, meses, dia);

            IF pfcarpro > pfrenova THEN
               pfcarpro := pfrenova;
            END IF;

            pnanuali := NVL(pnanuali, 0) + 1;
            pfcaranu := pfrenova;
            pnfracci := 0;
         ELSE
            pfcarpro := f_summeses(pfcarpro, meses, dia);
            pnanuali := NVL(pnanuali, 0) + 1;
            --JRH 0029386: POSRA300-Permitir la renovaci?n de la p?liza seg?n la ?ltima vigencia
            vmeses := NVL(pac_parametros.f_parproducto_n(vsproduc, 'PER_PROX_RENOV'), 12);

            IF vmeses = 0 THEN   --Según última renovación
               SELECT cduraci, sseguro
                 INTO vcduraci, vsseguropad
                 FROM seguros
                WHERE npoliza = vnpoliza
                  AND NVL(ncertif, 0) = 0;

               vresp4092 := NVL(pac_preguntas.ff_buscapregunpolseg(psseguro, 4092, NULL), 0);
               vresp4790 := NVL(pac_preguntas.ff_buscapregunpolseg(psseguro, 4790, NULL), 0);

               IF ((vcduraci = 6
                    AND vresp4092 = 1)
                   OR(vcduraci = 6
                      AND vresp4092 = 2
                      AND vresp4790 = 1)) THEN
                  verror := f_ultrenova(vsseguropad, pfcaranu - 1, vfrenova, vnmovimi);

                  IF verror <> 0 THEN
                     p_tab_error(f_sysdate, f_user, 'F_ACPROXCAR', 1, psseguro, SQLERRM);
                     RAISE NO_DATA_FOUND;
                  END IF;

                  vmeses := CEIL(MONTHS_BETWEEN(pfcaranu, vfrenova));
                  pfcaranu := f_summeses(pfcaranu, vmeses, dia);
                  pfcarpro := LEAST(pfcarpro, pfcaranu);
               ELSIF((vcduraci = 6
                      AND vresp4092 = 0)
                     OR(vcduraci = 6
                        AND vresp4092 = 2
                        AND vresp4790 = 2)) THEN
                  verror := f_ultrenova(psseguro, pfcaranu - 1, vfrenova, vnmovimi);

                  IF verror <> 0 THEN
                     p_tab_error(f_sysdate, f_user, 'F_ACPROXCAR', 1, psseguro, SQLERRM);
                     RAISE NO_DATA_FOUND;
                  END IF;

                  vmeses := CEIL(MONTHS_BETWEEN(pfcaranu, vfrenova));
                  pfcaranu := f_summeses(pfcaranu, vmeses, dia);
                  pfcarpro := LEAST(pfcarpro, pfcaranu);
               ELSE
                  pfcaranu := f_summeses(pfcaranu, 12, dia);
               END IF;
            ELSE
               --pfcaranu := f_summeses(pfcaranu, 12, dia);
               pfcaranu := f_summeses(pfcaranu, vmeses, dia);
            END IF;

            --Fin JRH 0029386: POSRA300-Permitir la renovaci?n de la p?liza seg?n la ?ltima vigencia
            pfrenova := pfcaranu;
            pnfracci := 0;
         END IF;
      ELSE
         pfcarpro := f_summeses(pfcarpro, meses, dia);
         pnanuali := NVL(pnanuali, 0) + 1;
         pfcaranu := f_summeses(pfcaranu, 12, dia);
         pnfracci := 0;
      END IF;
   ELSE
      pnfracci := NVL(pnfracci, 0) + 1;

      IF pfcaranu IS NULL
         AND pnfracci >= max_nfracci THEN
         pfcarpro := NULL;
      ELSE
         IF pfrenova IS NOT NULL THEN
            pfcarpro := f_summeses(pfcarpro, meses, dia);

            IF pfcarpro > pfrenova THEN
               pfcarpro := pfrenova;
            END IF;
         ELSE
            pfcarpro := f_summeses(pfcarpro, meses, dia);
         END IF;
      END IF;
   END IF;

   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      RETURN 105002;
END;

/

  GRANT EXECUTE ON "AXIS"."F_ACPROXCAR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ACPROXCAR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ACPROXCAR" TO "PROGRAMADORESCSI";
