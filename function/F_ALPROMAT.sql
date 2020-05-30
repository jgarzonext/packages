--------------------------------------------------------
--  DDL for Function F_ALPROMAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ALPROMAT" (psseguro IN NUMBER, pfecha IN DATE, ppromat IN OUT NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/**************************************************************************
   ALPROMAT Función que calcula la provisión matemática
         Devuelve 0 si todo va bien, y un entero de 1 a 9 sino.
   ALLIBCTR Biblioteca de contratos
**************************************************************************/
   person         NUMBER;
   nacimi         DATE;
   efecto         DATE;
   duraci         NUMBER;
   durcob         NUMBER;
   prima          NUMBER;
   edad           NUMBER;
   error          NUMBER;
   k              NUMBER;
   r1             NUMBER;
   r2             NUMBER;
   p              NUMBER;
   f1             NUMBER;
   f2             NUMBER;
   vagente_poliza seguros.cagente%TYPE;
   vcempres       seguros.cempres%TYPE;
BEGIN
   BEGIN
      -- Bug10612 - 06/07/2009 - DCT (Canviar vista personas por tablas personas y añadir filtro de visión de agente)
      SELECT fefecto, nduraci, ndurcob, iprianu, cagente, cempres
        INTO efecto, duraci, durcob, prima, vagente_poliza, vcempres
        FROM seguros
       WHERE sseguro = psseguro;

      SELECT sperson
        INTO person
        FROM riesgos
       WHERE sseguro = psseguro
         AND nriesgo = 1;

      SELECT p.fnacimi
        INTO nacimi
        FROM per_personas p
       WHERE p.sperson = person;
   /*SELECT fnacimi
     INTO nacimi
     FROM personas
    WHERE sperson = person;*/

   -- FI Bug10612 - 06/07/2009 - DCT (Canviar vista personas por tablas personas y añadir filtro de visión de agente)
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1;
   END;

   IF duraci IS NULL
      OR duraci = 0 THEN
      RETURN 9;
   END IF;

   -- Cálculo de la edad del asegurado en años actuariales
   error := f_difdata(nacimi, pfecha, 2, 1, edad);

   IF error <> 0 THEN
      RETURN 2;
   END IF;

   error := f_difdata(efecto, pfecha, 3, 3, k);

   IF error <> 0 THEN
      RETURN 3;
   END IF;

   k := TRUNC(k / 360);
   error := f_alctrf_1(edad, duraci, k, durcob, r1);

   IF error <> 0 THEN
      RETURN 4;
   END IF;

   r1 := r1 *(1 +(0.1 / 0.76));
   error := f_alctrf_1(edad, duraci, k + 1, durcob, r2);

   IF error <> 0 THEN
      RETURN 5;
   END IF;

   r2 := r2 *(1 +(0.1 / 0.76));
   -- Llamamos a alprima con capital=1 para que devuelva el %
   error := f_alprima(edad, duraci, 0, durcob, 1, p);

   IF error <> 0 THEN
      RETURN 6;
   END IF;

   p := p / 0.9;
   -- Diferencia en días naturales
   error := f_difdata(efecto, pfecha, 1, 3, f1);

   IF error <> 0 THEN
      RETURN 7;
   END IF;

   -- Diferencia en días naturales
   error := f_difdata(pfecha, ADD_MONTHS(efecto, 12), 1, 3, f2);

   IF error <> 0 THEN
      RETURN 8;
   END IF;

   ppromat := ((r1 * f1) +(r2 * f2) +(p * f1)) * prima;
   RETURN 0;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_ALPROMAT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ALPROMAT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ALPROMAT" TO "PROGRAMADORESCSI";
