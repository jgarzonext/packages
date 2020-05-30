--------------------------------------------------------
--  DDL for Function F_EDAD_SEXO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_EDAD_SEXO" (
   psseguro IN NUMBER,
   fecha IN DATE,
   ptipo IN NUMBER,
   edad OUT NUMBER,
   sexo OUT NUMBER,
   pnriesgo IN NUMBER DEFAULT 1)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***********************************************************************************************
   F_EDAD: Calcula la edad del asegurado de una poliza a una fecha determinada
      (Sólo sirve para pólizas de un riesgo personal, sino devuelve error)
      ptipo = 1 => edad real
      ptipo = 2 => edad actuarial
************************************************************************************************/
   fech_nacimi    DATE;
   num_err        NUMBER;
   vagente_poliza seguros.cagente%TYPE;
   vcempres       seguros.cempres%TYPE;
BEGIN
   BEGIN
      --Bug10612 - 07/07/2009 - DCT (canviar vista personas)
      --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
      SELECT cagente, cempres
        INTO vagente_poliza, vcempres
        FROM seguros
       WHERE sseguro = psseguro;

      SELECT fnacimi, csexper
        INTO fech_nacimi, sexo
        FROM per_personas p, riesgos
       WHERE riesgos.sseguro = psseguro
         AND riesgos.nriesgo = pnriesgo
         AND riesgos.sperson = p.sperson
         AND riesgos.fanulac IS NULL;
     /*SELECT fnacimi, csexper
   INTO fech_nacimi, sexo
   FROM PERSONAS, RIESGOS
   WHERE riesgos.sseguro = psseguro
               AND riesgos.nriesgo = pnriesgo
      AND riesgos.sperson = personas.sperson
      AND riesgos.fanulac is null;*/

   --FI Bug10612 - 07/07/2009 - DCT (canviar vista personas)
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 102819;
      WHEN OTHERS THEN
         RETURN 102819;
   END;

   IF ptipo = 1 THEN
      num_err := f_difdata(fech_nacimi, fecha, 1, 1, edad);
   ELSIF ptipo = 2 THEN
      num_err := f_difdata(fech_nacimi, fecha, 2, 1, edad);
   ELSE
      RETURN 101901;
   END IF;

   RETURN num_err;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_EDAD_SEXO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_EDAD_SEXO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_EDAD_SEXO" TO "PROGRAMADORESCSI";
