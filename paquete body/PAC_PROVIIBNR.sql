--------------------------------------------------------
--  DDL for Package Body PAC_PROVIIBNR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PROVIIBNR" IS
   CURSOR c_siniestros(fecha DATE, empresa NUMBER) IS
      -- BUG 11595 - 04/11/2009 - APD - Adaptación al nuevo módulo de siniestros
      SELECT c.cempres, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro, s.npoliza,
             s.ncertif, NVL(p.cramdgs, 0) cramdgs, TO_CHAR(sn.nsinies) nsinies
        FROM productos p, seguros s, siniestros sn, codiram c
       WHERE sn.fsinies <= fecha
         AND(sn.cestsin = 0
             OR(sn.cestsin <> 0
                AND sn.festsin > fecha))
         AND s.sseguro = sn.sseguro
         AND s.cramo = c.cramo
         AND c.cempres = empresa
         AND p.cramo = s.cramo
         AND p.cmodali = s.cmodali
         AND p.ctipseg = s.ctipseg
         AND p.ccolect = s.ccolect
         AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 0
      UNION
      SELECT c.cempres, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro, s.npoliza,
             s.ncertif, NVL(p.cramdgs, 0) cramdgs, sn.nsinies
        FROM productos p, seguros s, sin_siniestro sn, sin_movsiniestro m, codiram c
       WHERE sn.fsinies <= fecha
         AND(m.cestsin = 0
             OR(m.cestsin <> 0
                AND m.festsin > fecha))
         AND s.sseguro = sn.sseguro
         AND sn.nsinies = m.nsinies
         AND m.nmovsin = (SELECT MAX(nmovsin)
                            FROM sin_movsiniestro
                           WHERE nsinies = m.nsinies)
         AND s.cramo = c.cramo
         AND c.cempres = empresa
         AND p.cramo = s.cramo
         AND p.cmodali = s.cmodali
         AND p.ctipseg = s.ctipseg
         AND p.ccolect = s.ccolect
         AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 1;

-----------------------------------------------------------------------
   FUNCTION f_commit_calcul_ibnr(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER)
      RETURN NUMBER IS
      aux_fefeini    DATE;
      ttexto         VARCHAR2(400);
      nlin           NUMBER;
      num_err        NUMBER;
      conta_err      NUMBER := 0;
      provisio       NUMBER;
   BEGIN
      FOR reg IN c_siniestros(aux_factual, cempres) LOOP
         -- Esta función tiene en cuenta todos los pagos, tanto si están valorados como
         -- si no lo están.  El libor de siniestros, sólo tiene en cuenta los pagos
         -- que tienen valoración.
         num_err := f_provisio(reg.nsinies, provisio, aux_factual);

         IF num_err <> 0 THEN
            ROLLBACK;
            ttexto := f_axis_literales(num_err, pcidioma);
            num_err := f_proceslin(psproces, ttexto, reg.sseguro, nlin);
            conta_err := conta_err + 1;
            nlin := NULL;
            COMMIT;
         ELSE
            IF provisio <> 0 THEN
               BEGIN
                  INSERT INTO ibnr
                              (cempres, fcalcul, sproces, cramdgs, cramo,
                               cmodali, ctipseg, ccolect, sseguro,
                               nsinies, iibnrsd, iibnrrc, cerror)
                       VALUES (reg.cempres, aux_factual, psproces, reg.cramdgs, reg.cramo,
                               reg.cmodali, reg.ctipseg, reg.ccolect, reg.sseguro,
                               reg.nsinies, f_round((provisio * 5 / 100), pcmoneda), 0, 0);
               EXCEPTION
                  WHEN OTHERS THEN
                     ROLLBACK;
                     ttexto := f_axis_literales(103869, pcidioma);
                     num_err := f_proceslin(psproces, ttexto || ' IBNR', reg.sseguro, nlin);
                     conta_err := conta_err + 1;
                     nlin := NULL;
                     COMMIT;
               END;

               COMMIT;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   END f_commit_calcul_ibnr;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROVIIBNR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROVIIBNR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROVIIBNR" TO "PROGRAMADORESCSI";
