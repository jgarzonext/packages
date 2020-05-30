--------------------------------------------------------
--  DDL for Function F_VAL9998
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_VAL9998" (
   pnsinies IN NUMBER,
   ival9998 OUT NUMBER,
   DATA IN DATE,
   pmoneda IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
   xvaloracions   NUMBER;
   xpagaments     NUMBER;
   num_err        NUMBER;
   w_sseguro      sin_siniestro.sseguro%TYPE;   --    w_sseguro      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_ncuacoa      sin_siniestro.ncuacoa%TYPE;   --    w_ncuacoa      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   w_ctipcoa      NUMBER;
   w_ploccoa      coacuadro.ploccoa%TYPE;   /* NUMBER(5, 2);  */
   w_cpagcoa      NUMBER;
   apl_coa_prov   BOOLEAN;
   apl_coa_pag    BOOLEAN;
   v_cempres      seguros.cempres%TYPE;   --    v_cempres      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
BEGIN
   num_err := 105144;

   BEGIN
      -- BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
      -- Para este caso, en vez de buscar por el parempresa 'MODULO_SINI' para saber si se
      -- está en el módulo antiguo o nuevo de siniestros (ya que se necesita la empresa del
      -- seguro para buscar el valor del parempresa) se parte de que por defecto se está
      -- en el modelo nuevo, y si no hay datos se busca en el modelo antiguo.
      BEGIN
         SELECT sseguro, ncuacoa
           INTO w_sseguro, w_ncuacoa
           FROM sin_siniestro
          WHERE nsinies = pnsinies;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT sseguro, ncuacoa
              INTO w_sseguro, w_ncuacoa
              FROM siniestros
             WHERE nsinies = pnsinies;
      END;
   -- Fin BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
   END;

   -- BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
   -- Ahora que ya se tiene el sseguro se busca la empresa del seguro para buscar el
   -- valor del parempresa 'MODULO_SINI'
   SELECT cempres
     INTO v_cempres
     FROM seguros
    WHERE sseguro = w_sseguro;

   -- Fin BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
   num_err := pac_llibsin.datos_coa_sin(w_sseguro, w_ncuacoa, w_ctipcoa, w_ploccoa);
   num_err := pac_llibsin.valida_aplica_coa(w_ctipcoa, pnsinies, w_cpagcoa, apl_coa_prov,
                                            apl_coa_pag);
   num_err := 100539;   -- Error al calcular valoracions

   -- BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
   IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
      SELECT SUM(NVL(v1.ivalora, 0))
        INTO xvaloracions
        FROM valorasini v1
       WHERE v1.fvalora IN(SELECT MAX(v2.fvalora)
                             FROM valorasini v2
                            WHERE v2.cgarant = v1.cgarant
                              AND v2.nsinies = pnsinies
                              AND TRUNC(v2.fvalora) <= TRUNC(DATA))
         AND v1.nsinies = pnsinies;
   ELSE
      SELECT SUM(NVL(v1.ireserva, 0))
        INTO xvaloracions
        FROM sin_tramita_reserva v1
       WHERE v1.fmovres IN(SELECT MAX(v2.fmovres)
                             FROM sin_tramita_reserva v2
                            WHERE v2.cgarant = v1.cgarant
                              AND v2.nsinies = pnsinies
                              AND TRUNC(v2.fmovres) <= TRUNC(DATA))
         AND v1.nsinies = pnsinies;
   END IF;

   num_err := 100540;   -- Error al calcular pagaments

   -- BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
   IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
      SELECT NVL(SUM(DECODE(ctippag, 2, NVL(isinret, 0), 3, 0 - NVL(isinret, 0), 0)), 0)
        INTO xpagaments
        FROM pagosini
       WHERE nsinies = pnsinies
         AND TRUNC(fordpag) <= TRUNC(DATA)
         AND cestpag <> 8;
   ELSE
      SELECT NVL(SUM(DECODE(p.ctippag, 2, NVL(p.isinret, 0), 3, 0 - NVL(p.isinret, 0), 0)), 0)
        INTO xpagaments
        FROM sin_tramita_pago p, sin_tramita_movpago m
       WHERE p.nsinies = pnsinies
         AND p.sidepag = m.sidepag
         AND m.nmovpag = (SELECT MAX(nmovpag)
                            FROM sin_tramita_movpago
                           WHERE sidepag = m.sidepag)
         AND TRUNC(p.fordpag) <= TRUNC(DATA)
         AND m.cestpag <> 8;
   END IF;

   -- Fin BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
   IF w_ctipcoa IN(1, 2) THEN
      IF w_cpagcoa = 1 THEN
         ival9998 := xvaloracions - xpagaments;
      ELSE
         ival9998 := xvaloracions -(xpagaments /(w_ploccoa / 100));
      END IF;
   ELSE
      IF apl_coa_prov = TRUE THEN
         xvaloracions := xvaloracions * w_ploccoa / 100;
      END IF;

      IF apl_coa_pag = TRUE THEN
         xpagaments := xpagaments * w_ploccoa / 100;
      END IF;

      ival9998 := xvaloracions - xpagaments;
   END IF;

   ival9998 := f_round(ival9998, pmoneda);
   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      RETURN(num_err);
END;

/

  GRANT EXECUTE ON "AXIS"."F_VAL9998" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_VAL9998" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_VAL9998" TO "PROGRAMADORESCSI";
