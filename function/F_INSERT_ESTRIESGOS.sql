--------------------------------------------------------
--  DDL for Function F_INSERT_ESTRIESGOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_INSERT_ESTRIESGOS" (psseguro IN NUMBER,
   psperson IN NUMBER, pnmovima IN NUMBER, pfefecto IN DATE,
   pcdomici IN NUMBER, ptnombre IN VARCHAR2, pfnacimi IN DATE,
   pcsexper IN NUMBER)
   RETURN NUMBER IS

/******************************************************************************
 Función que inserta en las tablas estriesgos y estasegurados, con los datos
 pasados por parametros, esta función esta ideada para cuando se desea copiar
 un tomador a asegurado
******************************************************************************/
   vnriesgo    NUMBER;
BEGIN
   -- Miramos si la persona esta ya como riesgo, si no está entonces miramos
   -- que nriesgo le corresponde.
   SELECT MAX (nriesgo)
     INTO vnriesgo
     FROM estriesgos
    WHERE sseguro = psseguro
      AND sperson = sperson;

   IF vnriesgo IS NULL THEN
      SELECT MAX (nriesgo)
        INTO vnriesgo
        FROM estriesgos
       WHERE sseguro = psseguro;
   END IF;

   vnriesgo := NVL (vnriesgo, 0) + 1;

   --insertamos en la tabla de riesgos.
   BEGIN
      INSERT INTO estriesgos
                  (nriesgo, sseguro, nmovima, fefecto, sperson,
                   cdomici)
           VALUES (vnriesgo, psseguro, pnmovima, pfefecto, psperson,
                   pcdomici);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         UPDATE estriesgos
            SET nmovima = pnmovima,
                fefecto = pfefecto,
                cdomici = pcdomici
          WHERE sseguro = psseguro
            AND nriesgo = vnriesgo;
      WHEN OTHERS THEN
         RETURN 151096;--Error al insertar el riesgo
   END;

   vnriesgo := NULL;

   SELECT MAX (nriesgo)
     INTO vnriesgo
     FROM estasegurados
    WHERE sseguro = psseguro
      AND nriesgo = vnriesgo;

   IF vnriesgo IS NULL THEN
      SELECT MAX (nriesgo)
        INTO vnriesgo
        FROM estasegurados
       WHERE sseguro = psseguro;
   END IF;

   vnriesgo := NVL (vnriesgo, 0) + 1;

   BEGIN
      INSERT INTO estasegurados
                  (sseguro, nriesgo, tnombre, fnacimi, csexper)
           VALUES (psseguro, vnriesgo, ptnombre, pfnacimi, pcsexper);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         UPDATE estasegurados
            SET tnombre = ptnombre,
                fnacimi = pfnacimi,
                csexper = pcsexper
          WHERE sseguro = psseguro
            AND nriesgo = vnriesgo;
      WHEN OTHERS THEN
         RETURN 151097;-- Error al insertar el asegurado
   END;

   RETURN 0;
END f_insert_estriesgos;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_INSERT_ESTRIESGOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_INSERT_ESTRIESGOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_INSERT_ESTRIESGOS" TO "PROGRAMADORESCSI";
