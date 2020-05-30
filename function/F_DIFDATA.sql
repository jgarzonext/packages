--------------------------------------------------------
--  DDL for Function F_DIFDATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DIFDATA" (
   pdatain IN DATE,
   pdatafin IN DATE,
   ptipo IN NUMBER,
   punid IN NUMBER,
   pdifdata IN OUT NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/******************************************************************************
   NOMBRE:       F_DIFDATA
   PROPÓSITO:  Calcula la diferencia real (ptipo=1) o actuarial (ptipo=2) entre
               dos fechas; en días (punid=3), meses (punid=2) o años (punid=1).

   ALLIBCTR

   Se ha añadido un tipo de diferencia
   diferencia en días módulo 360 (ptipo=3) donde ha de ser punid=3
   Error paso incorrecto de parámetros
   Cambio de un día en la dif. actuarial
   Cambio en meses Febrero en dif. mod. 360
   Se termina de arreglar dif. mod. 360 cuando tenemos el mes de febrero
   Se restablece el cálculo original de la edad actuarial. No se quita 1 día

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  -----------------------------------------------------------------------------------
   1.0        30/04/2010   JGR             1. AXIS1858 - 14346: CRE201 - Validación de recién nacidos en el suplemento de alta
******************************************************************************/
   error          NUMBER;
   dini           NUMBER;
   dfin           NUMBER;
   mesini         NUMBER;
   mesfin         NUMBER;
BEGIN
   IF pdatafin IS NULL
      OR pdatain IS NULL
      OR ptipo IS NULL
      OR punid IS NULL THEN
      RETURN 101901;   --Paso incorrecto de parámetros a la función
   END IF;

   IF pdatafin < pdatain
      -- Bug 14346 - 30/04/2010 - JGR - INI
      -- La fecha inicial puede superar en un mes a la fecha final cuando se calcule en años es
      -- especial para permitir el alta de recien nacidos en una fecha posterior al efecto de la póliza
      AND(punid != 1
          OR MONTHS_BETWEEN(pdatain, pdatafin) > 1)
                                                   -- Bug 14346 - 30/04/2010 - JGR - FIN
   THEN
      RETURN 101922;   -- Fecha inicial mayor que la final
   ELSE
      error := 0;

      IF punid = 1 THEN
         IF ptipo = 1 THEN
            pdifdata := TRUNC(MONTHS_BETWEEN(pdatafin, pdatain) / 12);
         ELSIF ptipo = 2 THEN
            pdifdata := TRUNC(MONTHS_BETWEEN(pdatafin,(ADD_MONTHS(pdatain, -6))) / 12);
         ELSIF ptipo = 3 THEN
            error := 101923;   -- La dif. ha de ser en dias (punid=3)
         ELSE
            error := 101416;   -- Tipo de diferencia incorrecta
         END IF;
      ELSIF punid = 2 THEN
         IF ptipo = 1 THEN
            pdifdata := TRUNC(MONTHS_BETWEEN(pdatafin, pdatain));
         ELSIF ptipo = 2 THEN
            pdifdata := TRUNC(MONTHS_BETWEEN(pdatafin, TRUNC(pdatain - 15 + 1)));
         ELSIF ptipo = 3 THEN
            error := 101923;   -- La dif. ha de ser en dias (punid=3)
         ELSE
            error := 101416;   -- Tipo de diferencia incorrecta
         END IF;
      ELSIF punid = 3 THEN
         IF ptipo = 1
            OR ptipo = 2 THEN
            pdifdata := TRUNC(pdatafin - pdatain);
         ELSIF ptipo = 3 THEN
            dfin := TO_NUMBER(TO_CHAR(pdatafin, 'DD'));
            dini := TO_NUMBER(TO_CHAR(pdatain, 'DD'));
            mesini := TO_NUMBER(TO_CHAR(pdatain, 'MM'));
            mesfin := TO_NUMBER(TO_CHAR(pdatafin, 'MM'));

            IF mesfin = 2
               AND dfin IN(28, 29)
               AND mesini <> 2
               AND dini >= 28 THEN
               dini := dfin;
            ELSIF mesini = 2
                  AND dini IN(28, 29)
                  AND mesfin <> 2
                  AND dfin >= 28 THEN
               dfin := dini;
            ELSE
               IF LAST_DAY(pdatain) = pdatain THEN
                  dini := 30;
               END IF;

               IF LAST_DAY(pdatafin) = pdatafin THEN
                  dfin := 30;
               END IF;
            END IF;

            pdifdata := ((TO_NUMBER(TO_CHAR(pdatafin, 'YYYY'))
                          - TO_NUMBER(TO_CHAR(pdatain, 'YYYY')))
                         * 360)
                        +((TO_NUMBER(TO_CHAR(pdatafin, 'MM'))
                           - TO_NUMBER(TO_CHAR(pdatain, 'MM')))
                          * 30)
                        + dfin - dini;
         ELSE
            error := 101416;   -- Tipo de diferencia incorrecta
         END IF;
      ELSE
         error := 101417;   -- Unidad de diferencia incorrecta
      END IF;

      RETURN error;
   END IF;
END f_difdata;

/

  GRANT EXECUTE ON "AXIS"."F_DIFDATA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DIFDATA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DIFDATA" TO "PROGRAMADORESCSI";
