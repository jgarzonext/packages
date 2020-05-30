--------------------------------------------------------
--  DDL for Function F_ESTADO_POLIZA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ESTADO_POLIZA" (
   psseguro IN NUMBER,
   pnpoliza IN NUMBER,
   pfecha IN DATE,
   pestado OUT VARCHAR2,
   pfestado OUT DATE)
   RETURN NUMBER AUTHID CURRENT_USER IS
/****************************************************************************
   F_ESTADO_POLIZA :
         Devuelve el estado y fecha correspondinte de una póliza.
         Se puede entrar por sseguro o por póliza
   19-5-2004. No se tienen en cunea los movimientos anulados o rechazados
              cmovseg = 52
****************************************************************************/
   ppsseguro      NUMBER;
   seguro         NUMBER;
   vencim         DATE;
   carpro         DATE;
   forpag         NUMBER;
BEGIN
   IF psseguro IS NULL
      AND pnpoliza IS NOT NULL THEN
      SELECT sseguro
        INTO ppsseguro
        FROM seguros
       WHERE npoliza = pnpoliza;
   ELSIF psseguro IS NOT NULL
         AND pnpoliza IS NULL THEN
      ppsseguro := psseguro;
   ELSIF psseguro IS NOT NULL
         AND pnpoliza IS NOT NULL THEN
      RETURN 1;
   END IF;

   SELECT fvencim
     INTO vencim
     FROM seguros
    WHERE sseguro = ppsseguro;

   IF pfecha > vencim THEN
      pfestado := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      pestado := 'V';
      RETURN 101484;   --La póliza ya ha vencido
   END IF;

   ------
   SELECT movseguro.sseguro
     INTO seguro
     FROM movseguro
    WHERE movseguro.nmovimi = (SELECT MAX(nmovimi)
                                 FROM movseguro m3
                                WHERE m3.sseguro = movseguro.sseguro
                                  AND TRUNC(m3.fefecto) <= TRUNC(pfecha)
                                  AND m3.cmovseg NOT IN(6, 52)
                                  AND m3.fmovimi = movseguro.fmovimi
                                  AND m3.fmovimi =
                                        (SELECT MAX(fmovimi)
                                           FROM movseguro m2
                                          WHERE m2.sseguro = movseguro.sseguro
                                            AND TRUNC(m2.fefecto) <= TRUNC(pfecha)
                                            AND cmovseg NOT IN(6, 52)))
      AND movseguro.cmovseg <> 3
      AND DECODE(movseguro.femisio, NULL, cmovseg, 1) <> 0
      AND movseguro.sseguro = ppsseguro;

   pfestado := TO_DATE('0001-01-01', 'yyyy-mm-dd');
   pestado := 'A';
   RETURN 0;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      DECLARE
         vcmotmov       NUMBER;
      BEGIN   -- Anulaciones
         SELECT movseguro.fefecto, movseguro.cmotmov
           INTO pfestado, vcmotmov
           FROM movseguro
          WHERE movseguro.nmovimi = (SELECT MAX(nmovimi)
                                       FROM movseguro m3
                                      WHERE m3.sseguro = movseguro.sseguro
                                        AND TRUNC(m3.fefecto) <= TRUNC(pfecha)
                                        AND m3.cmovseg NOT IN(6, 52)
                                        AND m3.fmovimi = movseguro.fmovimi
                                        AND m3.fmovimi =
                                              (SELECT MAX(fmovimi)
                                                 FROM movseguro m2
                                                WHERE m2.sseguro = movseguro.sseguro
                                                  AND TRUNC(m2.fefecto) <= TRUNC(pfecha)
                                                  AND cmovseg NOT IN(6, 52)))
            AND movseguro.cmovseg = 3
            AND DECODE(movseguro.femisio, NULL, cmovseg, 1) <> 0
            AND movseguro.sseguro = ppsseguro;

         IF vcmotmov = 511 THEN
            pestado := 'R';
         ELSE
            pestado := 'C';
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            pfestado := TO_DATE('0001-01-01', 'yyyy-mm-dd');
            pestado := 'C';
      END;

      RETURN 102607;   ---Esta póliza no está vigente
END f_estado_poliza;

/

  GRANT EXECUTE ON "AXIS"."F_ESTADO_POLIZA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ESTADO_POLIZA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ESTADO_POLIZA" TO "PROGRAMADORESCSI";
