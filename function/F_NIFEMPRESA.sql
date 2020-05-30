--------------------------------------------------------
--  DDL for Function F_NIFEMPRESA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_NIFEMPRESA" (pcempres IN OUT NUMBER, pnnumnif IN OUT VARCHAR2)
   RETURN NUMBER AUTHID CURRENT_USER IS
--   ALLIBMFM. Modificació del dia 23-07-98. A aquesta funció
-- s' hi podrà accedir per pcempres o per pnnumnif. Un dels dos paràmetres
-- ha d' estar informat, i la funció retornarà l' altre també informat.
   xcempres       NUMBER;
-- ini bug21003 - MDS - modificar tipo de la variable xnnumnif
   xnnumnif       empresas.nnumnif%TYPE;
-- fin bug21003 - MDS -
BEGIN
   IF pcempres IS NULL
      AND pnnumnif IS NULL THEN
      RETURN 101901;   -- Pas incorrecte de paràmetres a la funció
   ELSE
      IF pcempres IS NULL THEN
         BEGIN
            SELECT cempres
              INTO xcempres
              FROM empresas
             WHERE nnumnif = pnnumnif;

            pcempres := xcempres;
            RETURN 0;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               pcempres := NULL;
               RETURN 102554;   -- No hi ha cap empresa amb aquest NIF
            WHEN OTHERS THEN
               pcempres := NULL;
               RETURN 101916;   -- Error a la Base de Dades
         END;
      ELSE   -- pcempres is not null
         BEGIN
            SELECT nnumnif
              INTO xnnumnif
              FROM empresas
             WHERE cempres = pcempres;

            pnnumnif := xnnumnif;
            RETURN 0;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               pnnumnif := NULL;
               RETURN 100853;   -- Codi d' empresa inexistent
            WHEN OTHERS THEN
               pnnumnif := NULL;
               RETURN 101916;
         -- Error a la Base de Dades
         END;
      END IF;
   END IF;
END;

/

  GRANT EXECUTE ON "AXIS"."F_NIFEMPRESA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_NIFEMPRESA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_NIFEMPRESA" TO "PROGRAMADORESCSI";
