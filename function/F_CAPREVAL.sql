--------------------------------------------------------
--  DDL for Function F_CAPREVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CAPREVAL" (
   psseguro IN NUMBER,
   pnmovimi IN NUMBER,
   pctipcoa IN NUMBER,
   pcapcontinente OUT NUMBER,
   pcapcontenido OUT NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
--
--
-- Librería ALLIABADM
--     Suma los capitales de garantías de continente y contenido.
--                (Se han especificado los códigos de garantía por no disponerse de
--                 información que las identifique)
--
   x_cramo        seguros.cramo%TYPE;
   x_cmodali      seguros.cmodali%TYPE;
   x_ctipseg      seguros.ctipseg%TYPE;
   x_ccolect      seguros.ccolect%TYPE;
   x_cactivi      seguros.cactivi%TYPE;
   cont           NUMBER;
BEGIN
   BEGIN
      -- Bug 9685 - APD - 17/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
      SELECT SUM(DECODE(pctipcoa, 2, icapital, icaptot))
        INTO pcapcontinente
        FROM garanseg g, seguros s
       WHERE g.sseguro = psseguro
         AND g.nmovimi = pnmovimi
         AND s.sseguro = psseguro
         AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                 pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo), g.cgarant,
                                 'TIPO'),
                 0) = 1;   -- continente

      -- Bug 9685 - APD - 17/04/2009 - Fin

      -- Bug 9685 - APD - 17/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
      SELECT SUM(DECODE(pctipcoa, 2, icapital, icaptot))
        INTO pcapcontenido
        FROM garanseg g, seguros s
       WHERE g.sseguro = psseguro
         AND g.nmovimi = pnmovimi
         AND s.sseguro = psseguro
         AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                 pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo), g.cgarant,
                                 'TIPO'),
                 0) = 2;   -- contenido

      -- Bug 9685 - APD - 17/04/2009 - Fin
      pcapcontinente := NVL(pcapcontinente, 0);
      pcapcontenido := NVL(pcapcontenido, 0);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 103500;   -- error al acceder a la tabla garanseg
   END;

   RETURN 0;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_CAPREVAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CAPREVAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CAPREVAL" TO "PROGRAMADORESCSI";
