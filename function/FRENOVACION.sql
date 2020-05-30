--------------------------------------------------------
--  DDL for Function FRENOVACION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FRENOVACION" (pnsesion IN NUMBER, psseguro IN NUMBER, porigen NUMBER )
          RETURN VARCHAR2 authid current_user IS
----------------------------------------
-- Retorna la última renovació de la pòlissa .
-- Si no ha renovat mai retorna la data d'efecte
----------------------------------------
   lfecha   DATE;
   lcforpag NUMBER;
   lfefecto DATE;
   dd       VARCHAR2(2);
   ddmm     VARCHAR2(4);
   lnrenova NUMBER;
   lssegpol NUMBER;

BEGIN
   IF porigen = 0 THEN
      SELECT TRUNC(falta) INTO lfecha
      FROM solseguros
      WHERE sseguro = psseguro;
   ELSIF porigen = 1 THEN
      
      BEGIN
        SELECT NVL(sa.frevant,s.fefecto)
        INTO lfecha
        FROM estseguros_aho sa, estseguros s
        WHERE sa.sseguro = s.sseguro
          AND s.sseguro = psseguro;
        
      EXCEPTION
        WHEN OTHERS THEN
          SELECT ssegpol, fefecto INTO lssegpol, lfefecto
          FROM estseguros
          WHERE sseguro = psseguro;

          BEGIN
             SELECT MAX(fefecto) INTO lfecha
             FROM movseguro
             WHERE sseguro = lssegpol
               AND cmovseg IN (0,2);
             IF lfecha IS NULL THEN
                lfecha := lfefecto;
             END IF;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                lfecha := lfefecto;
          END;
      END;
/*      SELECT fcaranu, cforpag, fefecto, nrenova INTO lfecha, lcforpag, lfefecto, lnrenova
      FROM estseguros
      WHERE sseguro = psseguro;
      IF lfecha IS NULL THEN -- A nova producció encara no s'ha calculat fcaranu
         dd          := SUBSTR(LPAD(lnrenova,4,0), 3, 2);
         ddmm        := dd || SUBSTR(LPAD(lnrenova,4,0), 1, 2);
         IF TO_CHAR(lfefecto, 'DDMM') = ddmm OR LPAD(lnrenova, 4, 0) IS NULL THEN
            lfecha   := ADD_MONTHS(lfefecto, 12);
         ELSE
            BEGIN
             lfecha  := TO_DATE(ddmm ||TO_CHAR(lfefecto, 'YYYY'),'DDMMYYYY');
            EXCEPTION
               WHEN OTHERS THEN
                  IF ddmm = 2902 THEN
                     ddmm        := 2802;
                     lfecha      := TO_DATE(ddmm ||TO_CHAR(lfefecto, 'YYYY'),
                                                'DDMMYYYY');
                  ELSE
                     lfecha := NULL;
                  END IF;
            END;
            IF lfecha <= lfefecto THEN
               lfecha := ADD_MONTHS(lfecha, 12);
            END IF;
         END IF;
      END IF;
*/
   ELSIF porigen = 2 THEN
      BEGIN
        SELECT NVL(sa.frevant,s.fefecto)
        INTO lfecha
        FROM seguros_aho sa, seguros s
        WHERE sa.sseguro = s.sseguro
          AND s.sseguro = psseguro;
      EXCEPTION
        WHEN OTHERS THEN
          SELECT MAX(fefecto) INTO lfecha
          FROM movseguro
          WHERE sseguro = psseguro
            AND cmovseg IN (0,2);
      END;
/*      SELECT fcaranu INTO lfecha
      FROM seguros
      WHERE sseguro = psseguro; */
   END IF;
   RETURN TO_CHAR(lfecha,'yyyymmdd');
EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END; 
 
 

/

  GRANT EXECUTE ON "AXIS"."FRENOVACION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FRENOVACION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FRENOVACION" TO "PROGRAMADORESCSI";
