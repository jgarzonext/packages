--------------------------------------------------------
--  DDL for Function F_TAREMB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TAREMB" (
   pctarifa IN NUMBER,
   pccolum IN NUMBER,
   pcfila IN NUMBER,
   pctipatr IN NUMBER,
   picapital IN NUMBER,
   piextrap IN NUMBER,
   ppreg37 IN NUMBER,
   ppreg50 IN NUMBER,
   ppreg51 IN NUMBER,
   ppreg52 IN NUMBER,
   ppreg53 IN NUMBER,
   ppreg54 IN NUMBER,
   ppreg55 IN NUMBER,
   ppreg56 IN NUMBER,
   ppreg57 IN NUMBER,
   ppreg58 IN NUMBER,
   ptarifar IN NUMBER,
   pipritar IN OUT NUMBER,
   atribu IN OUT NUMBER,
   piprima IN OUT NUMBER,
   moneda IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***********************************************************************
   F_TAREMB: Calcula la prima anual d'una garantía d'una embarcació
   ALLIBCTR
   Modificació: Afegim més paràmetres (PDTOCOM, IPRITAR, IRECARG, IDTOCOM)
   Modificació: Els descomptes i els recàrrecs es faràn fora d'aquesta funció
   Modificació: Afegim la moneda
   Modificació: Se añade el parámetro ptarifar, que nos indica si se tarifa o no
***********************************************************************/
   pvcolum        NUMBER;
   pvfila         NUMBER;
   piprima1       NUMBER := 0;   -- NUMBER(13, 2) := 0;
   piprima2       NUMBER := 0;   -- NUMBER(13, 2) := 0;
   error          NUMBER := 0;
   porcen54       NUMBER;
   porcen55       NUMBER;
   porcen56       NUMBER;
   porcen57       NUMBER;
   porcen58       NUMBER;
BEGIN
   IF ptarifar = 1 THEN
      IF pccolum IS NULL THEN
         pvcolum := 0;
      ELSIF pccolum = 5 THEN
         pvcolum := ppreg51;
      ELSE
         error := 101950;
      END IF;

      IF pcfila IS NULL THEN
         pvfila := 0;
      ELSIF pcfila = 9 THEN
         pvfila := ppreg52;
      ELSIF pcfila = 10 THEN
         pvfila := ppreg53;
      ELSE
         error := 101950;
      END IF;

      IF error = 0 THEN
         error := f_tarifas(pctarifa, pvcolum, pvfila, pctipatr, picapital, piextrap,
                            pipritar, atribu, piprima, moneda);
      END IF;
   END IF;

----------- RECÀRRECS
      -- El recargo de 15 millas se tiene que aplicar
      -- en todas las garantías excepto Asistencia Naútica.
   IF pctarifa IN(123, 125, 126, 134, 400) THEN
      porcen56 := f_prespuesta(56, ppreg56, NULL);
      piprima1 := piprima * NVL(porcen56 / 100, 0);
   END IF;

   IF pctarifa >= 125
      AND pctarifa <= 133 THEN
      porcen54 := f_prespuesta(54, ppreg54, NULL);
      piprima2 := piprima * NVL(porcen54 / 100, 0);
   ELSIF pctarifa = 134 THEN
      -- Dejamos de mutiplicar por el numero de personas, ya
      -- que el usuario introducirá el capital teniéndolo en cuenta.
      --    piprima := piprima * nvl(ppreg37,1);
         -- Protegim el valor NULL
      porcen55 := f_prespuesta(55, ppreg55, NULL);
--    porcen56 := f_prespuesta (56, ppreg56, null);
      piprima2 := piprima * NVL(porcen55 / 100, 0);
   END IF;

   piprima := piprima + NVL(piprima1, 0) + NVL(piprima2, 0);

----------- DESCOMPTES
   IF pctarifa <> 135 THEN
      porcen57 := f_prespuesta(57, ppreg57, NULL);
      piprima := piprima - piprima * NVL(porcen57 / 100, 0);
      porcen58 := f_prespuesta(58, ppreg58, NULL);
      piprima := piprima * NVL(porcen58 / 100, 1);
   END IF;

   -- Arrodonim a partir de la moneda
   piprima := f_round(piprima, moneda);
   RETURN error;
END;

/

  GRANT EXECUTE ON "AXIS"."F_TAREMB" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TAREMB" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TAREMB" TO "PROGRAMADORESCSI";
