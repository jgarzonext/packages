--------------------------------------------------------
--  DDL for Function F_EXTRES_NETES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_EXTRES_NETES" (psseguro IN NUMBER, pdesde IN DATE, phasta IN DATE,
                      pextres_netes OUT NUMBER)
   RETURN NUMBER authid CURRENT_user IS
-----------------------------------------------------
-- Aportacions extres Netes d'anul.lacions i excessos
-----------------------------------------------------

l_extres     NUMBER;
l_traspasent NUMBER;
l_tdevol      NUMBER;
BEGIN
   -- Calcular sumatori d'extres o inicials
   BEGIN
      SELECT NVL(SUM(imovimi),0)
        INTO l_extres
      FROM ctaseguro
      WHERE sseguro = psseguro
        AND fvalmov BETWEEN pdesde AND phasta
        AND cmovimi =1
        AND cmovanu = 0 ;

   EXCEPTION
      WHEN OTHERS THEN
         RETURN 104882;
   END;

   -- Traspassos d'entrada externs
   BEGIN
      SELECT NVL(SUM(IMOVIMI),0)
        INTO l_traspasent
      FROM ctaseguro c, trasplainout t
      WHERE t.sseguro = psseguro
        AND c.sseguro = t.sseguro
        AND c.nnumlin = t.nnumlin
        AND t.ctiptras = 1
        AND t.cestado = 4
        AND NOT EXISTS (SELECT 1
                        FROM proplapen
                        WHERE ccodpla = t.ccodpla )
        AND fvalmov BETWEEN pdesde AND phasta
        AND cmovimi in (8);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 104882;
   END;
   -- Devolució per excés
   BEGIN
      SELECT NVL(SUM(imovimi),0)
        INTO l_tdevol
      FROM ctaseguro
      WHERE sseguro = psseguro
        AND fvalmov BETWEEN pdesde AND phasta
        AND cmovimi IN (49,52) ;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 104882;

   END;

   pextres_netes := l_extres + l_traspasent - l_tdevol;
   RETURN 0;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_EXTRES_NETES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_EXTRES_NETES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_EXTRES_NETES" TO "PROGRAMADORESCSI";
