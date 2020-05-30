--------------------------------------------------------
--  DDL for Package Body PAC_FRACC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_FRACC" AS
   /******************************************************************************
      NOMBRE:       PAC_FRACCIONARIOS
      PROPÓSITO:    Funciones para temas relacionados con los productos fraccionarios

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        08/09/2009   RSC               1. Creación del package.
   ******************************************************************************/
   FUNCTION f_revalcartera_frac(psseguro IN NUMBER, pfcarpro IN DATE)
      RETURN NUMBER IS
      resultado      NUMBER := 0;
      d_datadef      DATE := TO_DATE('01-01-1900', 'dd-mm-yyyy');
      d_fecmov       DATE;
      n_ini          NUMBER;
      n_fin          NUMBER;

      CURSOR c1 IS
         SELECT a.nriesgo, NVL(b.fnacimi, d_datadef) fecnac
           FROM riesgos a, per_personas b
          WHERE a.sseguro = psseguro
            AND a.fanulac IS NULL   -- Activas
            AND b.sperson = a.sperson
            AND b.ctipper = 1   -- Fisicas
                             ;
   BEGIN
      -- Le toca la renovación anual.
      SELECT DECODE(TO_CHAR(pfcarpro, 'mm'),
                    SUBSTR(LTRIM(TO_CHAR(nrenova, '0999')), 1, 2), 1,
                    0)
        INTO resultado
        FROM seguros
       WHERE sseguro = psseguro;

      IF resultado = 0 THEN
         -- Miramos si alguno de los asegurados ha cumplido años
         FOR f1 IN c1 LOOP
            SELECT MAX(fefecto)
              INTO d_fecmov
              FROM recibos
             WHERE sseguro = psseguro
               AND fefecto < pfcarpro
               AND ctiprec IN(0, 3)
               AND NVL(nriesgo, f1.nriesgo) = f1.nriesgo;

            n_ini := fedad(NULL, TO_NUMBER(TO_CHAR(f1.fecnac, 'yyyymmdd')),
                           TO_NUMBER(TO_CHAR(d_fecmov, 'yyyymmdd')), 2);
            n_fin := fedad(NULL, TO_NUMBER(TO_CHAR(f1.fecnac, 'yyyymmdd')),
                           TO_NUMBER(TO_CHAR(pfcarpro, 'yyyymmdd')), 2);

            IF n_fin > n_ini THEN
               resultado := 1;
            END IF;
         END LOOP;
      END IF;

      RETURN resultado;
   END f_revalcartera_frac;

   FUNCTION f_frac(psseguro IN NUMBER, pfcarpro IN DATE)
      RETURN NUMBER IS
   BEGIN
      RETURN 1;
   END f_frac;
END pac_fracc;

/

  GRANT EXECUTE ON "AXIS"."PAC_FRACC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FRACC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FRACC" TO "PROGRAMADORESCSI";
