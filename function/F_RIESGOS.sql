--------------------------------------------------------
--  DDL for Function F_RIESGOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_RIESGOS" (
   psseguro IN NUMBER,
   pnriesgo IN NUMBER,
   pasegurado IN OUT VARCHAR2)
   RETURN NUMBER AUTHID CURRENT_USER IS
/**********************************************************************
   F_ASEGURADO: Retorna el nombre del asegurado de la tabla RIESGOS
   ALLIBCTR - Gestión de datos referentes a los seguros
   Modificació: Es la misma función que antes se llamaba F_ASEGURADO.
***********************************************************************/
   CURSOR c_asegura IS
      SELECT f_nombre(r.sperson, 1, s.cagente)
        FROM riesgos r, seguros s
       WHERE r.sseguro = psseguro
         AND r.nriesgo = pnriesgo
         AND s.sseguro = psseguro;
BEGIN
   OPEN c_asegura;

   FETCH c_asegura
    INTO pasegurado;

   IF c_asegura%NOTFOUND THEN
      RETURN 100523;   -- L'assegurat no existeix
   ELSE
      RETURN 0;   -- Tot ha anat be
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      -- BUG 21546_108724 - 08/02/2012 - JLTS - Cierre de posibles cursores abiertos
      IF c_asegura%ISOPEN THEN
         CLOSE c_asegura;
      END IF;

      RETURN 100523;   -- L'assegurat no existeix
END f_riesgos;

/

  GRANT EXECUTE ON "AXIS"."F_RIESGOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_RIESGOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_RIESGOS" TO "PROGRAMADORESCSI";
