--------------------------------------------------------
--  DDL for Package Body PAC_PP_OPE_ECO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PP_OPE_ECO" IS
   FUNCTION f_sup_aportacion(
      p_sseguro IN NUMBER,
      p_imovimi IN NUMBER,
      p_fvalor IN DATE,
      p_nmovimi OUT NUMBER)
      RETURN NUMBER IS
      suplemento     NUMBER;
      num_err        NUMBER;
      num_movimi     NUMBER;
      aux_conta      NUMBER;
      pnorden        NUMBER;
      pctarifa       NUMBER;
      pcformul       NUMBER;
      movimiento     NUMBER;
      fecha          DATE;
      ttexto         VARCHAR(100);
      fondocuenta    NUMBER;
      linea          NUMBER(4);
   BEGIN
      --Se genera un movimiento de seguro de suplemento
      SELECT (NVL(MAX(nsuplem), 0) + 1)
        INTO suplemento
        FROM movseguro
       WHERE sseguro = p_sseguro;

      num_err := f_movseguro(p_sseguro, NULL, 500, 1, p_fvalor, NULL, suplemento, 0, NULL,
                             num_movimi);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      num_err := f_dupgaran(p_sseguro, p_fvalor, num_movimi);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      --Miramos si ya tenia alguna aportacion extraordinaria
      --como garantia
      BEGIN
         SELECT COUNT(*)
           INTO aux_conta
           FROM garanseg
          WHERE sseguro = p_sseguro
            AND nmovimi = num_movimi
            AND cgarant = 282;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 101959;
      END;

      IF aux_conta = 0 THEN
         BEGIN
            SELECT norden, ctarifa, cformul
              INTO pnorden, pctarifa, pcformul
              FROM garanpro, seguros
             WHERE seguros.sseguro = p_sseguro
               AND garanpro.cramo = seguros.cramo
               AND garanpro.cmodali = seguros.cmodali
               AND garanpro.ctipseg = seguros.ctipseg
               AND garanpro.ccolect = seguros.ccolect
               AND garanpro.cgarant = 282;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 101959;
         END;

         BEGIN
            INSERT INTO garanseg
                        (cgarant, sseguro, nriesgo, finiefe, norden, crevali, ctarifa,
                         icapital, precarg, iprianu, iextrap, ffinefe, cformul, ctipfra,
                         ifranqu, irecarg, ipritar, pdtocom, idtocom, prevali, irevali,
                         itarifa, nmovimi, itarrea, ipritot, icaptot)
                 VALUES (282, p_sseguro, 1, p_fvalor, pnorden, 4, pctarifa,
                         p_imovimi, NULL, 0, NULL, NULL, pcformul, NULL,
                         NULL, 0, 0, NULL, 0, NULL, NULL,
                         NULL, num_movimi, NULL, 0, p_imovimi);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 101959;
         END;
      ELSE   --- Si ya existe la garantia 282
         BEGIN
            UPDATE garanseg
               SET icapital = p_imovimi,
                   icaptot = p_imovimi
             WHERE sseguro = p_sseguro
               AND nmovimi = num_movimi
               AND cgarant = 282;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 101959;
         END;
      END IF;

      --Cambiamos el numero de suplemento en SEGUROS y la situacion
      BEGIN
         UPDATE seguros
            SET nsuplem = suplemento,
                csituac = 5
          WHERE sseguro = p_sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 101992;
      END;

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      p_nmovimi := num_movimi;
      RETURN 0;
   END f_sup_aportacion;

   FUNCTION f_emitir(p_sseguro IN NUMBER, p_cidioma IN NUMBER)
      RETURN NUMBER IS
      v_npoliza      seguros.npoliza%TYPE;
      v_ncertif      seguros.ncertif%TYPE;
      v_cramo        seguros.cramo%TYPE;
      v_cmodali      seguros.cmodali%TYPE;
      v_ccolect      seguros.ccolect%TYPE;
      v_ctipseg      seguros.ctipseg%TYPE;
      v_cempres      seguros.cempres%TYPE;
      indice         NUMBER;
      indice_e       NUMBER;
      indice_t       NUMBER;
      -- JLB - I - BUG 18423 COjo la moneda del producto
      vsproduc       seguros.sproduc%TYPE;
      -- JLB - f - BUG 18423 COjo la moneda del producto
      pmensaje       VARCHAR2(500);   -- BUG 27642 - FAL - 30/04/2014
   BEGIN
      SELECT s.cempres, s.npoliza, s.ncertif, s.cramo, s.cmodali, s.ctipseg, s.ccolect
                                                                                      -- JLB - I - BUG 18423 COjo la moneda del producto
      ,
             sproduc
        -- JLB - F - BUG 18423 COjo la moneda del producto
      INTO   v_cempres, v_npoliza, v_ncertif, v_cramo, v_cmodali, v_ctipseg, v_ccolect
                                                                                      -- JLB - I - BUG 18423 COjo la moneda del producto
      ,
             vsproduc
        -- JLB - F - BUG 18423 COjo la moneda del producto
      FROM   seguros s
       WHERE s.sseguro = p_sseguro;

      p_emitir_propuesta(v_cempres, v_npoliza, v_ncertif, v_cramo, v_cmodali, v_ctipseg,
                         v_ccolect, NULL,
                         -- JLB - I - BUG 18423 COjo la moneda del producto
                             --null,
                         pac_monedas.f_moneda_producto(vsproduc),
                         -- JLB - f - BUG 18423 COjo la moneda del producto
                         p_cidioma, indice, indice_e, indice_t, pmensaje,   -- BUG 27642 - FAL - 30/04/2014
                         NULL, NULL, 1);

      IF indice_e > 0 THEN
         RETURN 151840;
      ELSE
         RETURN 0;
      END IF;
   END f_emitir;

   FUNCTION f_upd_recibo(
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER,
      p_cestrec IN NUMBER,
      p_nrecibo IN OUT NUMBER)
      RETURN NUMBER IS
      v_cerror       NUMBER;
      v_smovagr      NUMBER := 0;
      v_nliqmen      NUMBER;
      v_nliqlin      NUMBER;
   BEGIN
      IF p_nrecibo IS NULL THEN
         SELECT r.nrecibo
           INTO p_nrecibo
           FROM recibos r
          WHERE r.sseguro = p_sseguro
            AND r.nmovimi = p_nmovimi;
      END IF;

      v_cerror := f_movrecibo(p_nrecibo, p_cestrec, NULL, 1, v_smovagr, v_nliqmen, v_nliqlin,
                              TRUNC(f_sysdate), NULL, NULL, NULL, NULL);
      RETURN v_cerror;
   END f_upd_recibo;

   FUNCTION f_aportacion(
      p_sseguro IN NUMBER,
      p_cidioma IN NUMBER,
      p_imovimi IN NUMBER,
      p_nrecibo OUT NUMBER,
      p_cerror OUT NUMBER)
      RETURN NUMBER IS
      v_nmovimi      NUMBER;
      retval         NUMBER;
   BEGIN
      retval := f_sup_aportacion(p_sseguro, p_imovimi, TRUNC(f_sysdate), v_nmovimi);

      IF retval = 0 THEN
         retval := f_emitir(p_sseguro, p_cidioma);

         IF NVL(retval, 0) = 0 THEN
            retval := f_upd_recibo(p_sseguro, v_nmovimi, 1, p_nrecibo);
         END IF;
      END IF;

      IF NVL(retval, 0) != 0 THEN
         p_cerror := retval;
         RETURN NULL;
      ELSE
         RETURN 0;
      END IF;
   END f_aportacion;

   FUNCTION f_anul_aport(
      p_sseguro IN NUMBER,
      p_cidioma IN NUMBER,
      p_nrecibo IN NUMBER,
      p_imovimi IN NUMBER,
      p_cerror OUT NUMBER)
      RETURN NUMBER IS
      v_cestrec      NUMBER;
      v_imovimi      NUMBER;
      v_nrecibo      recibos.nrecibo%TYPE;
      retval         NUMBER;
   BEGIN
      SELECT m.cestrec, v.itotalr
        INTO v_cestrec, v_imovimi
        FROM movrecibo m, vdetrecibos v
       WHERE m.nrecibo = p_nrecibo
         AND m.nrecibo = v.nrecibo
         AND m.fmovfin IS NULL;

      IF v_cestrec = 1 THEN   -- el rebut esta cobrat
         IF p_imovimi = v_imovimi THEN
            BEGIN
               v_nrecibo := p_nrecibo;
               retval := f_upd_recibo(p_sseguro, NULL, 0, v_nrecibo);   -- Pendent.

               IF retval = 0 THEN
                  retval := f_upd_recibo(p_sseguro, NULL, 2, v_nrecibo);   -- Anula rebut.

                  IF retval != 0 THEN
                     p_cerror := retval;
                  END IF;
               ELSE
                  p_cerror := retval;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  p_cerror := 152106;   -- Les dades del rebut no concideixen
            END;
         ELSE
            p_cerror := 152106;   -- Les dades del rebut no concideixen
         END IF;
      ELSE
         p_cerror := 110602;   -- El rebut ha d'estar cobrat
      END IF;

      IF p_cerror != NULL THEN
         RETURN NULL;
      ELSE
         RETURN 0;
      END IF;
   END f_anul_aport;
END pac_pp_ope_eco;

/

  GRANT EXECUTE ON "AXIS"."PAC_PP_OPE_ECO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PP_OPE_ECO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PP_OPE_ECO" TO "PROGRAMADORESCSI";
