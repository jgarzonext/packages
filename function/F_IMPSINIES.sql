--------------------------------------------------------
--  DDL for Function F_IMPSINIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_IMPSINIES" (
   psseguro IN NUMBER,
   pfcaranuant IN DATE,
   pfcaranu IN DATE,
   ptotsinies OUT NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/****************************************************************************
   F_IMPSINIES: Calcula el importe total de los siniestros de un seguro
          desde una fecha determinada.
   ALLIBCTR.
          Se añade otro parámetro de entrada en la función
                      para que tome los siniestros que están entre la fecha
                      de última renovación y próxima cartera.
****************************************************************************/
   v_cempres      NUMBER;
BEGIN
   -- BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
   SELECT cempres
     INTO v_cempres
     FROM seguros
    WHERE sseguro = psseguro;

   IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
      SELECT SUM(NVL(v1.ivalora, 0))
        INTO ptotsinies
        FROM siniestros, valorasini v1
       WHERE siniestros.sseguro = psseguro
         AND TRUNC(siniestros.fnotifi) >= TRUNC(pfcaranuant)
         AND TRUNC(siniestros.fnotifi) < TRUNC(pfcaranu)
         AND v1.nsinies = siniestros.nsinies
         AND v1.fvalora = (SELECT MAX(v2.fvalora)
                             FROM valorasini v2
                            WHERE v2.cgarant = v1.cgarant
                              AND v2.nsinies = v1.nsinies)
         AND v1.cgarant <> 9999;
   ELSE
      SELECT SUM(NVL(v1.ireserva, 0))
        INTO ptotsinies
        FROM sin_siniestro, sin_tramitacion, sin_tramita_reserva v1
       WHERE sin_siniestro.sseguro = psseguro
         AND TRUNC(sin_siniestro.fnotifi) >= TRUNC(pfcaranuant)
         AND TRUNC(sin_siniestro.fnotifi) < TRUNC(pfcaranu)
         AND sin_siniestro.nsinies = sin_tramitacion.nsinies
         AND v1.nsinies = sin_tramitacion.nsinies
         AND v1.ntramit = sin_tramitacion.ntramit
         AND v1.fmovres = (SELECT MAX(v2.fmovres)
                             FROM sin_tramita_reserva v2
                            WHERE v2.cgarant = v1.cgarant
                              AND v2.nsinies = v1.nsinies)
         AND v1.cgarant <> 9999;
   END IF;

   -- Fin BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      RETURN 102784;   -- Error al calcular la valoración del siniestro
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_IMPSINIES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_IMPSINIES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_IMPSINIES" TO "PROGRAMADORESCSI";
