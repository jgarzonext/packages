--------------------------------------------------------
--  DDL for Function FF_RANK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_RANK" (psseguro IN NUMBER)
   RETURN NUMBER IS
   v_contador     NUMBER := 0;
   v_return       NUMBER := 0;

   CURSOR c_rank(p_seguro IN VARCHAR2) IS
      SELECT   NVL(nrango, 0) nrango
          FROM bloqueoseg
         WHERE sseguro = p_seguro
           AND cmotmov = 261
      ORDER BY sseguro, nrango;
BEGIN
   FOR x IN c_rank(psseguro) LOOP
      IF v_contador <> x.nrango THEN
         v_return := v_return + 1;
      END IF;

      v_contador := v_contador + 1;
   END LOOP;

   RETURN v_return;
EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END;

/

  GRANT EXECUTE ON "AXIS"."FF_RANK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_RANK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_RANK" TO "PROGRAMADORESCSI";
