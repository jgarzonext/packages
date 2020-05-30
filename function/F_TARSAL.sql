--------------------------------------------------------
--  DDL for Function F_TARSAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TARSAL" (
   pctarifa IN NUMBER,
   pccolum IN NUMBER,
   pcfila IN NUMBER,
   pctipatr IN NUMBER,
   picapital IN NUMBER,
   piextrap IN NUMBER,
   ppreg59 IN NUMBER,
   ppreg94 IN NUMBER,
   ppreg95 IN NUMBER,
   ppreg103 IN NUMBER,
   ppreg109 IN NUMBER,
   ppreg116 IN NUMBER,
   ppreg117 IN NUMBER,
   priesgo IN NUMBER,
   psexe IN NUMBER,
   pedad IN NUMBER,
   pram IN NUMBER,
   ptarifar IN NUMBER,
   pipritar IN OUT NUMBER,
   atribu IN OUT NUMBER,
   piprima IN OUT NUMBER,
   moneda IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***********************************************************************
   F_TARSAL: Calcula la prima anual d'una garantía de salud
   ALLIBCTR
   Modificació: Afegim més paràmetres (PDTOCOM, IPRITAR, IRECARG, IDTOCOM)
   Modificació: Els descomptes i els recàrrecs es faràn fora d'aquesta
      funció
   Modificació: Afegim la moneda
   Modificació: Afegim les preguntes 94 i 95
   Modificació: No arrodonim la tarifa. Afegim la preg. 103
   Modificació: Afegim el sexe
   Modificació: Añadimos el parámetro ptarifar, que nos indica si
           pasa por tarifar o no
   Modificació: Añadimos las preguntas 116 y 117
***********************************************************************/
   pvcolum        NUMBER;
   pvfila         NUMBER;
   error          NUMBER := 0;
   porcen117      NUMBER;
BEGIN
   IF ptarifar = 1 THEN   -- si tarifa
      IF pccolum IS NULL THEN
         pvcolum := 0;
      ELSIF pccolum = 1 THEN
         pvcolum := psexe;
      ELSIF pccolum = 6 THEN
         pvcolum := ppreg59;
      ELSIF pccolum = 10 THEN
         pvcolum := ppreg109;
      ELSIF pccolum = 15 THEN
         pvcolum := ppreg116;
      ELSE
         error := 101950;
      END IF;

      IF pcfila IS NULL THEN
         pvfila := 0;
      ELSIF pcfila = 1 THEN
         pvfila := pedad;
      ELSIF pcfila = 2 THEN
         IF pram = 40 THEN
            IF pedad >= 0
               AND pedad <= 24 THEN
               pvfila := 1;
            ELSIF pedad > 24
                  AND pedad <= 34 THEN
               pvfila := 2;
            ELSIF pedad > 34
                  AND pedad <= 44 THEN
               pvfila := 3;
            ELSIF pedad > 44
                  AND pedad <= 54 THEN
               pvfila := 4;
            ELSIF pedad > 54
                  AND pedad <= 65 THEN
               pvfila := 5;
            END IF;
         -- Afegim una garantia amb intervals d'edats diferents
         ELSIF pctarifa = 214 THEN
            IF pedad >= 0
               AND pedad <= 15 THEN
               pvfila := 1;
            ELSIF pedad > 15
                  AND pedad <= 45 THEN
               pvfila := 2;
            ELSIF pedad > 45
                  AND pedad <= 59 THEN
               pvfila := 3;
            ELSIF pedad > 59 THEN
               pvfila := 4;
            END IF;
         ELSE
            IF pedad >= 0
               AND pedad <= 30 THEN
               pvfila := 1;
            ELSIF pedad > 30
                  AND pedad <= 45 THEN
               pvfila := 2;
            ELSIF pedad > 45
                  AND pedad <= 55 THEN
               pvfila := 3;
            ELSIF pedad > 55
                  AND pedad <= 65 THEN
               pvfila := 4;
            ELSIF pedad > 65 THEN
               pvfila := 5;
            END IF;
         END IF;
      ELSE
         error := 101950;
      END IF;

      -- No cambiamos la pregunta porque ya vendrà cambiado
/*    IF ppreg59 = 2 THEN
         IF priesgo = 1 THEN pvcolum := 2;
         ELSE pvcolum := 5;
         END IF;
      END IF;
*/
      IF error = 0 THEN
         IF pctarifa IS NOT NULL THEN
            error := f_tarifas(pctarifa, pvcolum, pvfila, pctipatr, picapital, piextrap,
                               pipritar, atribu, piprima,
-- JLB - I - BUG 18423 COjo la moneda del producto
            --0
                               moneda
-- JLB - F - BUG 18423 COjo la moneda del producto
                    );
         ELSE
            piprima := 0;
         END IF;
      END IF;
   END IF;

   IF pctarifa = 114 THEN
      piprima := piprima * NVL(ppreg94, 100);
      pipritar := pipritar * NVL(ppreg94, 100);
   END IF;

   IF pctarifa = 115 THEN
      piprima := piprima * NVL(ppreg95, 100);
      pipritar := pipritar * NVL(ppreg95, 100);
   END IF;

   IF pctarifa = 116 THEN
      piprima := piprima * NVL(ppreg103, 100);
      pipritar := pipritar * NVL(ppreg103, 100);
   END IF;

   IF pctarifa = 507
      OR pctarifa = 530 THEN
      porcen117 := f_prespuesta(117, ppreg117, NULL);
      piprima := piprima * NVL(porcen117, 0) / 100;
   END IF;

   -- Arrodonim a partir de la moneda
   piprima := f_round(piprima, moneda);
   pipritar := f_round(pipritar, moneda);
   RETURN error;
END;

/

  GRANT EXECUTE ON "AXIS"."F_TARSAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TARSAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TARSAL" TO "PROGRAMADORESCSI";
