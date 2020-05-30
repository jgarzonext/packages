--------------------------------------------------------
--  DDL for Function F_COSTESEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_COSTESEG" (psseguro IN NUMBER, psuma IN OUT NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***********************************************************
   F_COSTESEG  Dado un seguro, calcula la suma de los
         importes de la última fecha de cada
         garantía de VALORASINI
         Devuelve 1 si hay error y 0 sino.
*************************************************************/
   CURSOR siniestro IS
      SELECT nsinies
        FROM siniestros
       WHERE sseguro = psseguro
         AND cestsin <> 0;

   -- BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
   -- se añade el cursor con el nuevo modelo
   CURSOR cur_siniestro IS
      SELECT s.nsinies
        FROM sin_siniestro s, sin_movsiniestro m
       WHERE sseguro = psseguro
         AND s.nsinies = m.nsinies
         AND m.nmovsin = (SELECT MAX(nmovsin)
                            FROM sin_movsiniestro
                           WHERE nsinies = m.nsinies)
         AND m.cestsin <> 0;

   suma           NUMBER;
   total          NUMBER;
   v_cempres      NUMBER;
BEGIN
   -- BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
   SELECT cempres
     INTO v_cempres
     FROM seguros
    WHERE sseguro = psseguro;

   total := 0;

   -- Si se está en el moddelo antiguo de siniestros
   IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
      FOR valor IN siniestro LOOP
         BEGIN
            SELECT SUM(ivalora)
              INTO suma
              FROM valorasini v,
                   (SELECT   MAX(fvalora) f, cgarant
                        FROM valorasini
                       WHERE nsinies = valor.nsinies
                    GROUP BY cgarant) s
             WHERE v.fvalora = s.f
               AND v.cgarant = s.cgarant
               AND v.nsinies = valor.nsinies;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN(1);
         END;

         total := total + suma;
      END LOOP;
   ELSE   -- Si se está en el moddelo nuevo de siniestros
      FOR valor IN cur_siniestro LOOP
         BEGIN
            SELECT SUM(ireserva)
              INTO suma
              FROM sin_tramita_reserva v,
                   (SELECT   MAX(fmovres) f, cgarant
                        FROM sin_tramita_reserva
                       WHERE nsinies = valor.nsinies
                    GROUP BY cgarant) s
             WHERE v.fmovres = s.f
               AND v.cgarant = s.cgarant
               AND v.nsinies = valor.nsinies;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN(1);
         END;

         total := total + suma;
      END LOOP;
   END IF;

   -- Fin BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
   psuma := total;
   RETURN 0;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_COSTESEG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_COSTESEG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_COSTESEG" TO "PROGRAMADORESCSI";
