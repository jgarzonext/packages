--------------------------------------------------------
--  DDL for Function F_CONSORANUL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CONSORANUL" (
   psseguro IN NUMBER,
   pfanulac IN DATE,
   pnrecibo IN NUMBER,
   pmoneda IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
-- Función utilizada en el cálculo del recibo de extorno en las anulaciones de póliza.
-- Inserta en el recibo especificado los conceptos de consorcio calculados para una póliza
-- en función de su fecha de anulación.
   xffinanu       DATE;
   xfinianu       DATE;
   xproxren       DATE;

   CURSOR dets IS
      SELECT   pnrecibo, con, gar, ries, SUM(cons) consor
          FROM (SELECT d.cconcep con, d.cgarant gar, d.nriesgo ries,   -- rebuts de l'anual.litat
                       iconcep * DECODE(ctiprec, 9, -1, 1)
                       * TO_NUMBER(xffinanu - pfanulac)
                       / TO_NUMBER(xffinanu - DECODE(ctiprec, 3, xfinianu, r.fefecto)) cons
                  FROM detrecibos d, recibos r, movseguro m, movrecibo mr
                 WHERE d.nrecibo = r.nrecibo
                   AND r.fefecto >= xfinianu
                   AND r.fefecto < xffinanu
                   AND d.cconcep IN(2, 52)
                   AND r.sseguro = psseguro
                   AND r.sseguro = m.sseguro
                   AND m.cmovseg <> 6
                   AND r.nmovimi = m.nmovimi
                   AND r.nrecibo = mr.nrecibo
                   AND cestrec = 1
                   AND fmovfin IS NULL
                UNION ALL   -- No regularització posterior a l'anul.litat des de la que s'anul.la
                SELECT d.cconcep con, d.cgarant gar, d.nriesgo ries,
                       iconcep * DECODE(ctiprec, 9, -1, 1) cons
                  FROM detrecibos d, recibos r, movseguro m, movrecibo mr
                 WHERE d.nrecibo = r.nrecibo
                   AND r.fefecto >= xffinanu
                   AND d.cconcep IN(2, 52)
                   AND r.sseguro = psseguro
                   AND r.sseguro = m.sseguro
                   AND r.nmovimi = m.nmovimi
                   AND cmovseg <> 6
                   AND r.nrecibo = mr.nrecibo
                   AND cestrec = 1
                   AND fmovfin IS NULL
                UNION ALL   -- Regularització d'efecte posterior a la data d'anul.lació
                SELECT d.cconcep con, d.cgarant gar, d.nriesgo ries,
                       iconcep * DECODE(ctiprec, 9, -1, 1) cons
                  FROM detrecibos d, recibos r, movseguro m, movrecibo mr
                 WHERE d.nrecibo = r.nrecibo
                   AND r.fefecto >= pfanulac
                   AND d.cconcep IN(2, 52)
                   AND r.sseguro = psseguro
                   AND r.sseguro = m.sseguro
                   AND r.nmovimi = m.nmovimi
                   AND cmovseg = 6
                   AND r.nrecibo = mr.nrecibo
                   AND cestrec = 1
                   AND fmovfin IS NULL
                UNION ALL   -- regularitzacions d'efecte anterior a la de l'anulació que vencen
                SELECT d.cconcep con, d.cgarant gar, d.nriesgo ries,   -- després de l'anul.lació
                       iconcep * DECODE(ctiprec, 9, -1, 1)
                       * TO_NUMBER(r.fvencim - pfanulac)
                       / TO_NUMBER(r.fvencim - r.fefecto) cons
                  FROM detrecibos d, recibos r, movseguro m, movrecibo mr
                 WHERE d.nrecibo = r.nrecibo
                   AND r.fvencim >= pfanulac
                   AND r.fefecto < pfanulac
                   AND d.cconcep IN(2, 52)
                   AND r.sseguro = psseguro
                   AND r.sseguro = m.sseguro
                   AND r.nmovimi = m.nmovimi
                   AND cmovseg = 6
                   AND r.nrecibo = mr.nrecibo
                   AND cestrec = 1
                   AND fmovfin IS NULL)
      GROUP BY pnrecibo, con, gar, ries;
BEGIN
   SELECT NVL(fcarpro, fvencim)
     INTO xproxren
     FROM seguros
    WHERE sseguro = psseguro;

   SELECT NVL(MIN(m.fefecto), xproxren)   -- fi de l'anualitat a la que pertany el rebut
     INTO xffinanu
     FROM movseguro m
    WHERE m.sseguro = psseguro
      AND pfanulac < fefecto
      AND cmovseg IN(0, 2);

   SELECT MAX(fefecto)   -- Inici de l'anualitat a la que pertany el rebut
     INTO xfinianu
     FROM movseguro
    WHERE sseguro = psseguro
      AND fefecto <= pfanulac
      AND cmovseg IN(0, 2);

   FOR a IN dets LOOP
      INSERT INTO detrecibos
                  (nrecibo, cconcep, cgarant, nriesgo, iconcep)
           VALUES (pnrecibo, a.con, a.gar, a.ries, f_round(a.consor, pmoneda));
   END LOOP;

   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'F_CONSORANUL', 1,
                  'Error no controlado psseguro:' || psseguro || ' pfanulac:' || pfanulac
                  || ' pnrecibo:' || pnrecibo || ' pmoneda:' || pmoneda,
                  SQLERRM);
      RETURN 109242;
END;
 

/

  GRANT EXECUTE ON "AXIS"."F_CONSORANUL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CONSORANUL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CONSORANUL" TO "PROGRAMADORESCSI";
