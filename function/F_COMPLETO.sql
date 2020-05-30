--------------------------------------------------------
--  DDL for Function F_COMPLETO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_COMPLETO" (
   psseguro IN NUMBER,
   pnriesgo IN NUMBER,
   psproduc IN NUMBER,
   pcactivi IN NUMBER)
   RETURN NUMBER IS
   CURSOR completo IS
      SELECT p.cgarant
        FROM garanpro p
       WHERE p.sproduc = psproduc
         AND p.ctipgar <> 8   --solo las visibles.
      MINUS
      SELECT g.cgarant
        FROM garanseg g
       WHERE g.sseguro = psseguro
         AND g.nriesgo = pnriesgo
         AND g.ffinefe IS NULL;

   num_err        NUMBER;
   v_nmovimi      NUMBER;
BEGIN
   SELECT MAX(nmovimi)
     INTO v_nmovimi
     FROM garanseg
    WHERE sseguro = psseguro
      AND nriesgo = pnriesgo;

   FOR c IN completo LOOP
      num_err :=
         pk_nueva_produccion.f_validar_edad_seg(psseguro, pnriesgo, psproduc,
                                                pac_seguros.ff_get_actividad(psseguro,
                                                                             pnriesgo),
                                                c.cgarant);

      IF num_err = 0
         AND pk_nueva_produccion.f_valida_exclugarseg('SEG', psseguro, pnriesgo, c.cgarant) = 0 THEN
         RETURN 0;   -- es básico no hace falta que busquemos más
      END IF;
   END LOOP;

   -- si no ha salido antes es porque tiene contratado todo aquello que se puede contratar.
   RETURN 1;   --Completo
EXCEPTION
   WHEN OTHERS THEN
      RETURN -1;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_COMPLETO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_COMPLETO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_COMPLETO" TO "PROGRAMADORESCSI";
