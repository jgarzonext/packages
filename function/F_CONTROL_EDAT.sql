--------------------------------------------------------
--  DDL for Function F_CONTROL_EDAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CONTROL_EDAT" (psperson NUMBER, pfecha IN DATE, pnedamic IN NUMBER,
   pciedmic IN NUMBER, pnedamac IN NUMBER, pciedmac IN NUMBER,
   pnsedmac IN NUMBER, pcisemac IN NUMBER, psperson2 IN NUMBER,porigen in number  default 2)
   RETURN NUMBER IS
   n_ciedamic     NUMBER;
   n_ciedamac     NUMBER;
   n_ciedamac2    NUMBER;
   num_err        NUMBER;
   suma_edades    NUMBER;
BEGIN
   num_err := 0;


--Edat màxima
--mirem l'edat segons CIEDMIC,CIEMAC (1 Real ,0 Actuarial)
   IF    psperson IS NULL
      OR pfecha IS NULL
      OR pnedamic IS NULL
      OR pciedmic IS NULL
      OR pnedamac IS NULL
      OR pciedmac IS NULL THEN
      num_err := 140999; -- error no controlado
   ELSE
      IF pciedmac = 0 THEN -- edad actuarial
         n_ciedamac :=
                      fedadaseg (0, psperson, TO_CHAR (pfecha, 'YYYYMMDD'), 2,porigen);
      ELSIF pciedmac = 1 THEN -- edad real
         n_ciedamac :=
                      fedadaseg (0, psperson, TO_CHAR (pfecha, 'YYYYMMDD'), 1,porigen);
      END IF;

      IF pciedmic = 0 THEN -- edad actuarial
         n_ciedamic :=
                      fedadaseg (0, psperson, TO_CHAR (pfecha, 'YYYYMMDD'), 2,porigen);
      ELSIF pciedmic = 1 THEN --edad real
         n_ciedamic :=
                      fedadaseg (0, psperson, TO_CHAR (pfecha, 'YYYYMMDD'), 1,porigen);
      END IF;

      IF      (   n_ciedamic < pnedamic
               OR n_ciedamac > pnedamac)
          AND (    n_ciedamac IS NOT NULL
               AND n_ciedamic IS NOT NULL) THEN
         num_err := 103366; -- edad no se cumple
      END IF;

      IF      psperson2 IS NOT NULL
          AND num_err = 0 THEN -- VALIDAR LA SUMA DE EDADES
         IF pcisemac = 0 THEN -- edad actuarial
            n_ciedamac2 :=
                     fedadaseg (0, psperson2, TO_CHAR (pfecha, 'YYYYMMDD'), 2,porigen);
            suma_edades := n_ciedamac + n_ciedamac2;
         ELSIF pcisemac = 1 THEN -- edad real
            n_ciedamac2 :=
                     fedadaseg (0, psperson2, TO_CHAR (pfecha, 'YYYYMMDD'), 1,porigen);
            suma_edades := n_ciedamac + n_ciedamac2;
         END IF;

         IF suma_edades > pnsedmac THEN
            num_err := 103366; -- SUMA EDADES NO SE CUMPLE
         END IF;
      END IF;
   END IF;

   RETURN num_err;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_CONTROL_EDAT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CONTROL_EDAT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CONTROL_EDAT" TO "PROGRAMADORESCSI";
