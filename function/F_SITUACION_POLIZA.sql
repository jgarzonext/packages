--------------------------------------------------------
--  DDL for Function F_SITUACION_POLIZA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_SITUACION_POLIZA" (psseguro IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
   /****************************************************************************
     Retorna l'estat de la pòlissa:
      1.- vigent (no inclou proposta de suplement)
      2.- anul·lada (pòlissa o proposta d'alta tant si està anul·lada com rebutjada)
      3.- proposta d'alta (no anul·lada ni rebutjada)
      4.- proposta de suplement
       5 - Nota informativa

   *****************************************************************************/
   vestat         NUMBER;
   vcsituac       NUMBER;
   vcreteni       NUMBER;
BEGIN
   SELECT csituac, creteni
     INTO vcsituac, vcreteni
     FROM seguros
    WHERE sseguro = psseguro;

   IF vcsituac = 0 THEN
      --està vigent
      vestat := 1;
   ELSIF vcsituac = 2 THEN
      --està anulada
      vestat := 2;
   ELSIF vcsituac IN(4, 7) THEN --si es simulació el tractem com si fos una proposta
      --està en proposta d'alta
      IF vcreteni IN(3, 4) THEN
         --està anul·lada
         vestat := 2;
      ELSE
         vestat := 3;
      END IF;
   ELSIF vcsituac = 5 THEN
      --està en proposta de suplement
      vestat := 4;
   -- Bug 16800 - 15/12/2010 - AMC
   ELSIF vcsituac = 12 THEN
      vestat := 3;
   ELSIF vcsituac = 14 THEN
      vestat := 5;
   -- Fi Bug 16800 - 15/12/2010 - AMC
   END IF;

   RETURN vestat;
END;

/

  GRANT EXECUTE ON "AXIS"."F_SITUACION_POLIZA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_SITUACION_POLIZA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_SITUACION_POLIZA" TO "PROGRAMADORESCSI";
