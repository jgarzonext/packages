CREATE OR REPLACE PACKAGE BODY pac_ctacliente IS
   /******************************************************************************
     NOMBRE:     PAC_CTACLIENTE
     PROPOSITO:  Funciones de la cuenta de cliente

     REVISIONES:
     Ver        Fecha        Autor             Descripcion
     ---------  ----------  ---------------  ------------------------------------
     1.0        20/02/2013   XXX                1. Creacion del package.
     2.0        04/02/2015   MDS                2. 0032674: COLM004-Guardar los importes de recaudo a la fecha de recaudo
     3.0        28/04/2015   YDA                3. Se crea la funcion f_crea_rec_gasto
     4.0        06/05/2015   YDA                4. Se crean las funciones f_get_nroreembolsos y f_actualiza_nroreembol
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   gidioma        NUMBER := pac_md_common.f_get_cxtidioma;
   gcempres       NUMBER := pac_md_common.f_get_cxtempresa;

   FUNCTION f_numlin_next(
      pcempres IN NUMBER,
      psperson IN NUMBER,
      psseguro IN NUMBER,
      psproduc IN NUMBER)
      RETURN NUMBER IS
      lnumlin        ctacliente.nnumlin%TYPE;
      vhayctacli     NUMBER := NVL (f_parproductos_v (psproduc, 'HAYCTACLIENTE'), 0);
   BEGIN
      IF vhayctacli = 2 THEN
        SELECT NVL(MAX(nnumlin), 0)
          INTO lnumlin
          FROM ctacliente
         WHERE sseguro = psseguro
           AND cempres = pcempres
           AND sproduc = psproduc;
      ELSE
        SELECT NVL(MAX(nnumlin), 0)
          INTO lnumlin
          FROM ctacliente
         WHERE sperson = psperson
           AND sseguro = psseguro
           AND cempres = pcempres
           AND sproduc = psproduc;
      END IF;

      lnumlin := lnumlin + 1;
      RETURN lnumlin;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1;
   END f_numlin_next;

   /******************************************************************************
      NOMBRE:     F_RECALCUL_SALDO
      PROPoSITO:  Funcion que recalcula el SALDO en CTACLIENTE.

      PARAMETROS:

           return            : 0 -> Todo correcto
                               1 -> Se ha producido un error

    *****************************************************************************/
   FUNCTION f_recalcul_saldo(
      pcempres IN NUMBER,
      psperson IN NUMBER,
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pffecmov IN DATE DEFAULT NULL,
      pnnumlin IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      --
      lnnumlin       ctacliente.nnumlin%TYPE;
      lisaldo        ctacliente.isaldo%TYPE := NULL;
      lisaldo_prod   ctacliente.isaldo_prod%TYPE;
      --
      vparam         VARCHAR2(2000)
         := 'PCEMPRES = ' || pcempres || ' SPERSON = ' || psperson || ' SSEGURO =' || psseguro
            || ' FECMOV =' || pffecmov || ' nnumlin = ' || pnnumlin;
      --
      vobject        VARCHAR2(200) := 'PAC_CTACLIENTE.f_recalcul_saldo';
      terror         VARCHAR2(200);
      vpasexec       NUMBER(8) := 1;
      num_err        axis_literales.slitera%TYPE := 0;
      ind            NUMBER;
      --
      vhayctacli     NUMBER := NVL (f_parproductos_v (psproduc, 'HAYCTACLIENTE'), 0);
   BEGIN
      --
      ind := 0;

      IF vhayctacli = 2 THEN
        FOR reg IN (SELECT   *
                        FROM ctacliente
                       WHERE sseguro = psseguro
                         AND sproduc = psproduc
                         AND ffecmov BETWEEN NVL(pffecmov, '01/01/1900')
                                         AND NVL(pffecmov, '31/12/2999')
                         AND nnumlin BETWEEN NVL(pnnumlin, 0) AND NVL(pnnumlin, 999999)
                    ORDER BY nnumlin) LOOP
           IF ind = 0 THEN
              BEGIN
                 SELECT isaldo, isaldo_prod
                   INTO lisaldo, lisaldo_prod
                   FROM ctacliente
                  WHERE sseguro = psseguro
                    AND sproduc = psproduc
                    AND nnumlin =(reg.nnumlin - 1);
              EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    lisaldo := NULL;
                    lisaldo_prod := NULL;
              END;
           END IF;

           --
           IF lisaldo IS NULL THEN
              --lisaldo := REG.IIMPINS;
              lisaldo_prod := reg.iimppro;
           ELSE
              --lisaldo := lisaldo + REG.IIMPINS;
              lisaldo_prod := lisaldo_prod + reg.iimppro;
           END IF;

           --
           UPDATE ctacliente
              SET isaldo = lisaldo,
                  isaldo_prod = lisaldo_prod
            WHERE sseguro = reg.sseguro
              AND sproduc = reg.sproduc
              AND nnumlin = reg.nnumlin;
        --
        END LOOP;
      ELSE
        FOR reg IN (SELECT   *
                        FROM ctacliente
                       WHERE sseguro = psseguro
                         AND sperson = psperson
                         AND sproduc = psproduc
                         AND ffecmov BETWEEN NVL(pffecmov, '01/01/1900')
                                         AND NVL(pffecmov, '31/12/2999')
                         AND nnumlin BETWEEN NVL(pnnumlin, 0) AND NVL(pnnumlin, 999999)
                    ORDER BY nnumlin) LOOP
           IF ind = 0 THEN
              BEGIN
                 SELECT isaldo, isaldo_prod
                   INTO lisaldo, lisaldo_prod
                   FROM ctacliente
                  WHERE sseguro = psseguro
                    AND sperson = psperson
                    AND sproduc = psproduc
                    AND nnumlin =(reg.nnumlin - 1);
              EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    lisaldo := NULL;
                    lisaldo_prod := NULL;
              END;
           END IF;

           --
           IF lisaldo IS NULL THEN
              --lisaldo := REG.IIMPINS;
              lisaldo_prod := reg.iimppro;
           ELSE
              --lisaldo := lisaldo + REG.IIMPINS;
              lisaldo_prod := lisaldo_prod + reg.iimppro;
           END IF;

           --
           UPDATE ctacliente
              SET isaldo = lisaldo,
                  isaldo_prod = lisaldo_prod
            WHERE sseguro = reg.sseguro
              AND sperson = reg.sperson
              AND sproduc = reg.sproduc
              AND nnumlin = reg.nnumlin;
        --
        END LOOP;
      END IF;

      --
      RETURN 0;
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1;
   --
   END f_recalcul_saldo;

   /******************************************************************************
      NOMBRE:     F_SALDO_CTACLIENTE
      PROPoSITO:  Funcion que mira el saldo de un sseguro/sperson en CTACLIENTE.

      PARAMETROS:

           return            : 0 -> Todo correcto
                               1 -> Se ha producido un error

    *****************************************************************************/
   FUNCTION f_saldo_ctacliente(
      pcempres IN NUMBER,
      psperson IN NUMBER,
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pssaldo OUT NUMBER,
      pssaldo_pro OUT NUMBER)
      RETURN NUMBER IS
      --
      lnnumlin       ctacliente.nnumlin%TYPE;
      --
      vparam         VARCHAR2(2000)
         := 'PCEMPRES = ' || pcempres || ' SPERSON = ' || psperson || ' SSEGURO =' || psseguro;
      --
      vobject        VARCHAR2(200) := 'PAC_CTACLIENTE.f_saldo_ctacliente';
      terror         VARCHAR2(200);
      vpasexec       NUMBER(8) := 1;
      num_err        axis_literales.slitera%TYPE := 0;
      --
      vhayctacli     NUMBER := NVL (f_parproductos_v (psproduc, 'HAYCTACLIENTE'), 0);
   BEGIN
      --
      IF vhayctacli = 2 THEN
        BEGIN
           SELECT isaldo, isaldo_prod
             INTO pssaldo, pssaldo_pro
             FROM ctacliente
            WHERE sseguro = psseguro
              AND cempres = pcempres
              AND sproduc = psproduc
              AND nnumlin = (SELECT MAX(nnumlin)
                               FROM ctacliente
                              WHERE sseguro = psseguro
                                AND cempres = pcempres
                                AND sproduc = psproduc);
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              pssaldo := 0;
              pssaldo_pro := 0;
        END;
      ELSE
        BEGIN
           SELECT isaldo, isaldo_prod
             INTO pssaldo, pssaldo_pro
             FROM ctacliente
            WHERE sseguro = psseguro
              AND sperson = psperson
              AND cempres = pcempres
              AND sproduc = psproduc
              AND nnumlin = (SELECT MAX(nnumlin)
                               FROM ctacliente
                              WHERE sseguro = psseguro
                                AND sperson = psperson
                                AND cempres = pcempres
                                AND sproduc = psproduc);
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              pssaldo := 0;
              pssaldo_pro := 0;
        END;
      END IF;
      --
      RETURN 0;
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1;
   --
   END f_saldo_ctacliente;

   /******************************************************************************
      NOMBRE:     F_INSCTACLIENTE
      PROPoSITO:  Funcion gonerica que Inserta un registro en cuenta cliente.

      PARAMETROS:

           return            : 0 -> Todo correcto
                               1 -> Se ha producido un error

    *****************************************************************************/
   FUNCTION f_insctacliente(
      pcempres IN NUMBER,
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pnnumlin IN NUMBER,
      pffecmov IN DATE,
      pffecval IN DATE,
      pcmovimi IN NUMBER,
      ptdescri IN VARCHAR2,
      piimppro IN NUMBER,
      pcmoneda IN VARCHAR2,
      piimpope IN NUMBER,
      piimpins IN NUMBER,
      pfcambio IN DATE,
      pnrecibo IN NUMBER,
      psproces IN NUMBER DEFAULT NULL,
      psproduc IN NUMBER DEFAULT NULL,
      pseqcaja IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      --
      lnnumlin       ctacliente.nnumlin%TYPE;
      lisaldo        ctacliente.isaldo%TYPE;
      lisaldo_prod   ctacliente.isaldo_prod%TYPE;
      lnrecibo       recibos.nrecibo%TYPE;
      lfin           NUMBER;
      --
      vparam         VARCHAR2(2000)
         := 'PCEMPRES = ' || pcempres || ' SPERSON = ' || psperson || ' SSEGURO =' || psseguro
            || ' PNNUMLIN=' || lnnumlin || ' PFFECMOV =' || pffecmov || ' PFFECVAL ='
            || pffecval || ' PCMOVIMI =' || pcmovimi || ' ptdescri =' || ptdescri
            || ' PIIMPPRO =' || piimppro || ' PCMONEDA =' || pcmoneda || ' PIIMPOPE ='
            || piimpope || ' PIIMPINS =' || piimpins || ' PFCAMBIO =' || pfcambio
            || ' PNRECIBO =' || pnrecibo || ' PSPROCES =' || psproces || ' PSPRODUC ='
            || psproduc || ' PSEQCAJA =' || pseqcaja;
      --
      vobject        VARCHAR2(200) := 'PAC_CTACLIENTE.f_insctacliente';
      terror         VARCHAR2(200);
      vpasexec       NUMBER(8) := 1;
      num_err        axis_literales.slitera%TYPE := 0;
      ligenera       NUMBER;
      lfcobrado      DATE;
   --
   BEGIN
      --
      IF pcmovimi = 1 THEN   -- Movimiento Emision Cuota
         --
         num_err := pac_ctacliente.f_saldo_ctacliente(pcempres, psperson, psseguro, psproduc,
                                                      lisaldo, lisaldo_prod);

         --
         IF lisaldo_prod > 0 THEN
            -- Si el saldo ant es positivo, se paga parte o totalmente el recibo
              --
            num_err := f_pagar_recibo_consaldo(pcempres, psperson, psseguro, pcmovimi,
                                               pnrecibo, ABS(piimppro), lisaldo_prod);

            IF num_err <> 0 THEN
               RAISE e_param_error;
            END IF;
         --
         END IF;
      --
      END IF;

      --
      num_err := pac_ctacliente.f_saldo_ctacliente(pcempres, psperson, psseguro, psproduc,
                                                   lisaldo, lisaldo_prod);

      IF num_err <> 0 THEN
         RAISE e_param_error;
      END IF;

      --
      IF pnnumlin IS NULL THEN
         lnnumlin := pac_ctacliente.f_numlin_next(pcempres, psperson, psseguro, psproduc);
      ELSE
         lnnumlin := pnnumlin;
      END IF;

      --
      --lisaldo := lisaldo + piimpins;
      lisaldo_prod := lisaldo_prod + piimppro;

      --
      INSERT INTO ctacliente
                  (cempres, sperson, sseguro, nnumlin, ffecmov, ffecval,
                   cmovimi, tdescri, iimppro, cmoneda, iimpope, iimpins, fcambio,
                   isaldo, cusuari, falta, sproces, sproduc, seqcaja, nrecibo,
                   isaldo_prod)
           VALUES (NVL(pcempres, gcempres), psperson, psseguro, lnnumlin, pffecmov, pffecval,
                   pcmovimi, ptdescri, piimppro, pcmoneda, piimpope, piimpins, pfcambio,
                   lisaldo, f_user, f_sysdate, psproces, psproduc, pseqcaja, pnrecibo,
                   lisaldo_prod);

      --
      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN SQLCODE;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN SQLCODE;
   --
   END f_insctacliente;

   /******************************************************************************
      NOMBRE:     F_TITULAR_CTACLIENTE
      PROPoSITO:  Funcion que captura el titular de la cuenta cliente, en funcion
                   del tipo de recibo.

      PARAMETROS:

           return            : 0 -> Todo correcto
                               1 -> Se ha producido un error

    *****************************************************************************/
   FUNCTION f_titular_ctacliente(
      psseguro IN NUMBER,
      pctipreb IN NUMBER,
      pnrecibo IN NUMBER,
      psperson IN OUT NUMBER)
      RETURN NUMBER IS
      --
      lcexistepagador tomadores.cexistepagador%TYPE;
      lsperson       ctacliente.sperson%TYPE;
      lnriesgo       riesgos.nriesgo%TYPE;
      --
      vparam         VARCHAR2(2000)
         := 'Paso de parametros SSEGURO =' || psseguro || ' CTIPREB =' || pctipreb
            || ' NRECIBO =' || pnrecibo || ' SPERSON =' || psperson;
      vobject        VARCHAR2(200) := 'PAC_CTACLIENTE.f_titular_ctacliente';
      terror         VARCHAR2(200);
      vpasexec       NUMBER(8) := 1;
      num_err        axis_literales.slitera%TYPE := 0;
   --
   BEGIN
      IF psperson IS NULL THEN
         IF pnrecibo IS NOT NULL THEN
            BEGIN
               SELECT sperson
                 INTO lsperson
                 FROM recibos
                WHERE nrecibo = pnrecibo;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 101902;   -- Recibo no encontrado en la tabla RECIBOS
                  RAISE e_param_error;
               WHEN OTHERS THEN
                  RETURN 102367;   -- Error al leer datos de la tabla RECIBOS
                  RAISE e_param_error;
            END;
         END IF;

         --
         IF lsperson IS NULL THEN
            BEGIN
               SELECT sperson, cexistepagador
                 INTO lsperson, lcexistepagador
                 FROM tomadores
                WHERE sseguro = psseguro
                  AND nordtom = 1;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 105112;   -- Error al leer tabla TOMADORES
                  RAISE e_param_error;
               WHEN OTHERS THEN
                  num_err := 105112;   -- Error al leer tabla TOMADORES
                  RAISE e_param_error;
            END;

            --
            IF lcexistepagador = 1 THEN
               BEGIN
                  SELECT g.sperson
                    INTO lsperson
                    FROM gescobros g
                   WHERE g.sseguro = psseguro;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     num_err := 9904084;
                     -- Gestor de cobro / Pagador no encontrado en la tabla ESTGESCOBROS.
                     RAISE e_param_error;
                  WHEN OTHERS THEN
                     num_err := 9904085;
                     -- Error al leer en la tabla ESTGESCOBROS.
                     RAISE e_param_error;
               END;
            END IF;
         --
         END IF;
      --
      END IF;

      --
      psperson := lsperson;
      --
      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, num_err);
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 151327;   -- error al Buscar Persona
   END f_titular_ctacliente;

   /******************************************************************************
      NOMBRE:     F_INS_MOVPAPCTACLI
      PROPoSITO:  Funcion que inserta PAGOS MASIVOS en CUENTA CLIENTE

      PARAMETROS:

           return            : 0 -> Todo correcto
                               1 -> Se ha producido un error

    *****************************************************************************/
   FUNCTION f_ins_movpapctacli(
      pcempres IN NUMBER,
      psperson IN NUMBER,
      psseguro IN NUMBER,
      psproces IN NUMBER,
      piimppro IN NUMBER,
      pcmoneda IN NUMBER,
      piimpope IN NUMBER,
      pitasa IN NUMBER,
      piimpins IN NUMBER,
      pfmovto IN DATE,
      pctipreb IN NUMBER,
      pnrecibo IN NUMBER,
      pseqcaja IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      --
      lcmovimi       ctacliente.cmovimi%TYPE;
      ltdescri       ctacliente.tdescri%TYPE;
      --
      vparam         VARCHAR2(2000)
         := 'PCEMPRES = ' || pcempres || ' PSPERSON=' || psperson || ' PSSEGURO =' || psseguro
            || ' PSPROCES =' || psproces || ' PIIMPPRO =' || piimppro || ' PCMONEDA ='
            || pcmoneda || ' PIIMPOPE =' || piimpope || ' PITASA =' || pitasa || ' PIIMPINS ='
            || piimpins || ' PFMOVTO =' || pfmovto || ' PCTIPREB =' || pctipreb
            || ' PNRECIBO =' || pnrecibo;
      --
      vobject        VARCHAR2(200) := 'PAC_CTACLIENTE.f_ins_movpapctacli';
      terror         VARCHAR2(200);
      vpasexec       NUMBER(8) := 1;
      num_err        axis_literales.slitera%TYPE := 0;
      lsproduc       seguros.sproduc%TYPE;
      lsperson       riesgos.sperson%TYPE;
   --
   BEGIN
      --
      lcmovimi := 2;
      ltdescri := psproces || ' ' || TO_CHAR(pfmovto, 'DD/MM/YYYY');

      --
      BEGIN
         SELECT sproduc
           INTO lsproduc
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            lsproduc := NULL;
      END;

      --
      IF psperson IS NULL THEN
         num_err := f_titular_ctacliente(psseguro, NULL, pnrecibo, lsperson);

         IF num_err <> 0 THEN
            RAISE e_param_error;
         END IF;
      ELSE
         lsperson := psperson;
      END IF;

      --
      num_err := f_insctacliente(NVL(pcempres, gcempres), lsperson, psseguro, NULL,
                                 TRUNC(f_sysdate), pfmovto, lcmovimi, ltdescri, piimppro,
                                 pcmoneda, piimpope, piimpins, pfmovto, pnrecibo, psproces,
                                 lsproduc, pseqcaja);

      --
      IF num_err <> 0 THEN
         RAISE e_param_error;
      END IF;

      --
      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, num_err);
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN SQLCODE;
   END f_ins_movpapctacli;

   /******************************************************************************
       NOMBRE:     F_INS_MOVPATCTACLI
       PROPoSITO:  Funcion que inserta CUENTA CLIENTE el COBRO TOTAL DE UN RECIBO
                   que se cobran a traves del modulo de caja

       PARAMETROS:

            return            : 0 -> Todo correcto
                                1 -> Se ha producido un error

     *****************************************************************************/
   FUNCTION f_ins_movpatctacli(
      pcempres IN NUMBER,
      psperson IN NUMBER,
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      piimppro IN NUMBER,
      pcmoneda IN NUMBER,
      piimpope IN NUMBER,
      piimpins IN NUMBER,
      pfmovto IN DATE,
      pnrecibo IN NUMBER,
      pseqcaja IN NUMBER DEFAULT NULL,
      pfefecto IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      --
      lcmovimi       ctacliente.cmovimi%TYPE;
      ltdescri       ctacliente.tdescri%TYPE;
      --
      vparam         VARCHAR2(2000)
         := 'PCEMPRES  =' || pcempres || ' PSPERSON =' || psperson || ' PSSEGURO ='
            || psseguro || ' PSPRODUC =' || psproduc || ' PIIMPPRO =' || piimppro
            || ' PCMONEDA =' || pcmoneda || ' PIIMPOPE =' || piimpope || ' PIIMPINS ='
            || piimpins || ' PFMOVTO  =' || pfmovto || ' PNRECIBO =' || pnrecibo
            || ' PSEQCAJA =' || pseqcaja;
      --
      vobject        VARCHAR2(200) := 'PAC_CTACLIENTE.f_ins_movpatctacli';
      terror         VARCHAR2(200);
      vpasexec       NUMBER(8) := 1;
      num_err        axis_literales.slitera%TYPE := 0;
      lsproduc       seguros.sproduc%TYPE;
      lsperson       riesgos.sperson%TYPE;
   --
   BEGIN
      --
      lcmovimi := 2;
      ltdescri := pseqcaja || ' ' || TO_CHAR(pfmovto, 'DD/MM/YYYY');

      --
      IF psperson IS NULL THEN
         num_err := f_titular_ctacliente(psseguro, NULL, pnrecibo, lsperson);

         IF num_err <> 0 THEN
            RAISE e_param_error;
         END IF;
      ELSE
         lsperson := psperson;
      END IF;

      --
      num_err := f_insctacliente(NVL(pcempres, gcempres), lsperson, psseguro, NULL,
                                 TRUNC(f_sysdate), pfmovto, lcmovimi, ltdescri, piimppro,
                                 pcmoneda, piimpope, piimpins, NVL(pfefecto, pfmovto),
                                 pnrecibo, NULL, psproduc, pseqcaja);

      --
      IF num_err <> 0 THEN
         RAISE e_param_error;
      END IF;

      --
      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, num_err);
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN SQLCODE;
   END f_ins_movpatctacli;

   /******************************************************************************
      NOMBRE:     F_INS_MOVRECCTACLI
      PROP¿SITO:  Funcion que inserta los movimientos de un recibo, es llamada por:
                   - PAC_ANULACION
                      - F_RECRIES
                      - F_MOVRECIBO

      PARAMETROS:

        PCEMPRES  NUMBER       C¿digo de empresa Empresa
        PSSEGURO  NUMBER       Clave del seguros
        PNMOVIMI  NUMBER       N¿mero de movimiento
        PNRECIBO  NUMBER       N¿mero de recibo.
        PCORIGEN  NUMBER       Origen de la llamada (NO SE USA) :
                               0 - Emisi¿n (se llama desde F_RECRIES)
                                      1 - Anulaci¿n
                               2 - Cobro/Descobro(se llama desde F_MOVRECIBO)


           return            : 0 -> Todo correcto
                               1 -> Se ha producido un error

    *****************************************************************************/
   FUNCTION f_ins_movrecctacli(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnrecibo IN NUMBER,
      pcorigen IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      --
      lsperson       ctacliente.sperson%TYPE := NULL;
      lcmovimi       ctacliente.cmovimi%TYPE;
      ltdescri       ctacliente.tdescri%TYPE;
      liimppro       ctacliente.iimppro%TYPE;
      liimppro_cuota ctacliente.iimppro%TYPE;
      lcmoneda       ctacliente.cmoneda%TYPE;
      liimpins       ctacliente.iimpins%TYPE;
      liimpins_cuota ctacliente.iimpins%TYPE;
      lfcambio       ctacliente.fcambio%TYPE;
      lnnumlin       ctacliente.nnumlin%TYPE := NULL;
      lfecpag_cuota  ctacliente.ffecmov%TYPE;
      lsum_iimpins_cuota ctacliente.iimpins%TYPE;
      lsum_iimppro_cuota ctacliente.iimppro%TYPE;
      lmonedainst    parinstalacion.nvalpar%TYPE;
      --
      lctipreb       seguros.ctipreb%TYPE;
      lsproduc       seguros.sproduc%TYPE;
      lnmescob       seguros.nmescob%TYPE;
      lpimport       aportaseg.pimport%TYPE;
      lfefecto       recibos.fefecto%TYPE;
      lfvencim       recibos.fvencim%TYPE;
      lctiprec       recibos.ctiprec%TYPE;
      lcestrec       movrecibo.cestrec%TYPE;
      lcestant       movrecibo.cestant%TYPE;
      lfmovini       movrecibo.fmovini%TYPE;
      lnriesgo       detrecibos.nriesgo%TYPE;
      vparam         VARCHAR2(2000)
         := ' CEMPRES = ' || pcempres || ' SSEGURO =' || psseguro || ' NMOVIMI=' || pnmovimi
            || ' CTIPREC =' || lctiprec || ' CESTREC =' || lcestrec || ' NRECIBO ='
            || pnrecibo || ' FVALMOV =' || lfefecto || ' FMOVINI =' || lfmovini;
      --
      vobject        VARCHAR2(200) := 'PAC_CTACLIENTE.f_ins_movrecctacli';
      terror         VARCHAR2(200);
      vpasexec       NUMBER(8) := 1;
      num_err        axis_literales.slitera%TYPE := 0;
      vimpcobpar     NUMBER;
                        -- Importe de los cobros parciales.   33921 23/12/2014
   --
   BEGIN
      --
      vpasexec := 1;

      -- Control para que no se dupliquen movimientos
      IF ggrabar = 1 THEN
         IF pnrecibo IS NOT NULL THEN
            --
            BEGIN
               SELECT r.fefecto, r.fvencim, r.ctiprec, s.ctipreb, s.sproduc, m.cestrec,
                      m.cestant, v.itotalr, vm.itotalr, TRUNC(m.fmovdia), p.cdivisa,
                      s.nmescob, r.sperson
                 INTO lfefecto, lfvencim, lctiprec, lctipreb, lsproduc, lcestrec,
                      lcestant, liimppro, liimpins, lfmovini, lcmoneda,
                      lnmescob, lsperson
                 FROM recibos r, movrecibo m, vdetrecibos v, vdetrecibos_monpol vm, seguros s,
                      productos p
                WHERE s.sseguro = r.sseguro
                  AND p.sproduc = s.sproduc
                  AND r.nrecibo = m.nrecibo
                  AND v.nrecibo = r.nrecibo
                  AND v.nrecibo = vm.nrecibo
                  AND r.nrecibo = pnrecibo
                  AND m.fmovfin IS NULL;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  num_err := 105031;
                  RAISE e_object_error;
               WHEN OTHERS THEN
                  num_err := 1000005;
                  RAISE e_param_error;
            END;
         ELSE
            num_err := 1000005;
            RAISE e_param_error;
         END IF;

         --
         vpasexec := 2;

         -- Busco la fecha de cambio que ha aplicado en el recibo.
         BEGIN
            -- Bug 33399  Ajuste para recuperar la fcambio
            SELECT   MAX(fcambio)
                INTO lfcambio
                FROM (SELECT   TRUNC(fcambio) fcambio
                          FROM vdetrecibos_monpol vd, detrecibos d
                         WHERE vd.nrecibo = d.nrecibo
                           AND d.nrecibo = pnrecibo
                           AND vd.itotalr <> 0
                      GROUP BY fcambio)
            GROUP BY fcambio;
         --  Fin Bug 33399
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 0;
            WHEN OTHERS THEN
               num_err := 1000005;
               RAISE e_param_error;
         END;

         --
         vpasexec := 3;

         --
         IF lsperson IS NULL THEN
            num_err := pac_ctacliente.f_titular_ctacliente(psseguro, lctipreb, pnrecibo,
                                                           lsperson);

            IF num_err <> 0 THEN
               RAISE e_object_error;
            END IF;
         END IF;

         --
         vpasexec := 5;

         --
         -- Si est¿ remesado no actualizamos CTACLIENTE solo cuando den contestaci¿n Pagado.
         IF lcestrec = 3
            OR(lcestant = 3
               -- MMS 20150304 Bug 32654 --> agregamos lcestant
               AND lcestrec <> 1) THEN   -- PPP   Bug 35499 --> agregamos AND
            RETURN 0;
         END IF;

         --
         IF lcestant = 0 THEN   -- Pendiente
            ltdescri := pnrecibo || ' ' || TO_CHAR(lfefecto, 'DD/MM/YYYY') || ' - '
                        || TO_CHAR(lfvencim, 'DD/MM/YYYY');

            IF lcestrec = 0 THEN   -- Pendiente --> Emision
               lcmovimi := 1;

               IF lctiprec IN(9, 10, 13) THEN
                  liimppro := liimppro;
                  liimpins := liimpins;
               ELSE   -- lctiprec IN(0, 1, 3, 4, 5, 14, 15) THEN
                  liimppro := liimppro * -1;
                  liimpins := liimpins * -1;
               END IF;
            ELSIF lcestrec = 1 THEN   -- Cobrado/ Remesado NO
               IF lctiprec IN(4, 10) THEN   -- Aportaci¿n Extra, Traspaso de Entrada
                  RETURN 9902693;
               ELSIF lctiprec = 9 THEN   -- Extorno
                  lcmovimi := 3;
               ELSE
-- lctiprec IN(0, 1, 3, 5, 13, 14, 15) THEN   -- Produccion, Suplemento, Cartera
                  -- Comision, Retorno, Tiempo transcurrido, Recobro del Retorno
                  lcmovimi := 2;
               END IF;

               --
               IF lctiprec IN(9, 10, 13) THEN
                  liimppro := liimppro * -1;
                  liimpins := liimpins * -1;
               ELSE   -- lctiprec IN(0, 1, 3, 4, 5, 14, 15) THEN
                  liimppro := liimppro;
                  liimpins := liimpins;
               END IF;
            ELSIF lcestrec = 2 THEN   -- Anulado
               lcmovimi := 5;   -- Anulaci¿n

               --
               IF lctiprec IN(9, 10, 13) THEN
                  liimppro := liimppro * -1;
                  liimpins := liimpins * -1;
               ELSE   -- lctiprec IN(0, 1, 3, 4, 5, 14, 15) THEN
                  liimppro := liimppro;
                  liimpins := liimpins;
               END IF;
            --
            END IF;
         ELSIF lcestant = 1 THEN   -- Cobrado
            ltdescri := pnrecibo || ' ' || TO_CHAR(lfefecto, 'DD/MM/YYYY') || ' - '
                        || TO_CHAR(lfvencim, 'DD/MM/YYYY');

            IF lcestrec = 0 THEN   -- Pendiente
               lcmovimi := 4;   -- Devoluci¿n

               --
               IF lctiprec IN(9, 10, 13) THEN
                  liimppro := liimppro;
                  liimpins := liimpins;
               ELSE   -- lctiprec IN(0, 1, 3, 4, 5, 14, 15) THEN
                  liimppro := liimppro * -1;
                  liimpins := liimpins * -1;
               END IF;
            END IF;
         ELSIF lcestant = 2 THEN   -- Anulado
            ltdescri := pnrecibo || ' ' || TO_CHAR(lfefecto, 'DD/MM/YYYY') || ' - '
                        || TO_CHAR(lfvencim, 'DD/MM/YYYY');

            IF lcestrec = 0 THEN   -- Pendiente
               lcmovimi := 1;   -- Devoluci¿n

               IF lctiprec IN(9, 10, 13) THEN
                  liimppro := liimppro;
                  liimpins := liimpins;
               ELSE   -- lctiprec IN(0, 1, 3, 4, 5, 14, 15) THEN
                  liimppro := liimppro * -1;
                  liimpins := liimpins * -1;
               END IF;
            END IF;
         -- PPP   Bug 35499 --> Se agrega tratamiento del estado anterior del recibo REMESADO.
         ELSIF lcestant = 3 THEN   -- Remesado
            -- Solo puede ser la opci¿n >> lcestrec =  1 (COBRADO)
            -- C¿digo igual al estado anterior: pendiente y el actual: cobrado
            ltdescri := pnrecibo || ' ' || TO_CHAR(lfefecto, 'DD/MM/YYYY') || ' - '
                        || TO_CHAR(lfvencim, 'DD/MM/YYYY');

            IF lctiprec IN(4, 10) THEN   -- Aportaci¿n Extra, Traspaso de Entrada
               RETURN 9902693;
            ELSIF lctiprec = 9 THEN   -- Extorno
               lcmovimi := 3;
            ELSE
-- lctiprec IN(0, 1, 3, 5, 13, 14, 15) THEN   -- Produccion, Suplemento, Cartera
               -- Comision, Retorno, Tiempo transcurrido, Recobro del Retorno
               lcmovimi := 2;
            END IF;

            --
            IF lctiprec IN(9, 10, 13) THEN
               liimppro := liimppro * -1;
               liimpins := liimpins * -1;
            ELSE   -- lctiprec IN(0, 1, 3, 4, 5, 14, 15) THEN
               liimppro := liimppro;
               liimpins := liimpins;
            END IF;
         END IF;

         --
         vpasexec := 6;

         --
         IF lcmovimi IS NOT NULL THEN
            --
            IF lnmescob IS NULL THEN   -- No es Pago por cuotas.
--33921   23/12/2014
               vimpcobpar := pac_adm_cobparcial.f_get_importe_cobro_parcial(pnrecibo, NULL,
                                                                            NULL, 0);

               IF vimpcobpar = liimppro THEN   --Es el ¿ltimo pago parcial
--Recuperamos el importe del ¿ltimo pago parcial, que ser¿ el que se grabe en ctacliente
                  BEGIN
                     SELECT d.iimporte, d.iimporte_moncon
                       INTO liimppro, liimpins
                       FROM detmovrecibo d
                      WHERE d.nrecibo = pnrecibo
                        AND norden = (SELECT MAX(norden)
                                        FROM detmovrecibo
                                       WHERE nrecibo = pnrecibo
                                         AND smovrec =
                                               (SELECT MAX(smovrec)
                                                  FROM movrecibo mm
                                                 WHERE nrecibo = pnrecibo
                                                   AND EXISTS(
                                                         SELECT 1
                                                           FROM detmovrecibo
                                                          WHERE nrecibo = pnrecibo
                                                            AND smovrec = mm.smovrec)));

                     lmonedainst := f_parinstalacion_n('MONEDAINST');
                     liimppro := pac_monedas.f_round((liimppro), lcmoneda);
                     liimpins := pac_monedas.f_round((liimpins), lmonedainst);
                  EXCEPTION
                     WHEN OTHERS THEN
                        --Si no encuentra nada o hay otro error dejamos el importe como est¿.
                        NULL;
                  END;
               END IF;

--33921   23/12/2014  FIN
               num_err := f_insctacliente(NVL(pcempres, gcempres), lsperson, psseguro, NULL,
                                          lfmovini, lfefecto, lcmovimi, ltdescri, liimppro,
                                          lcmoneda, liimppro, liimpins,
                                          NVL(lfcambio, TRUNC(f_sysdate)), pnrecibo, NULL,
                                          lsproduc);
            ELSE
               -- PAGO DE CUOTAS
               -- Busco la fecha de la primera cuota
               BEGIN
                  SELECT TO_DATE(TO_CHAR(crespue, 'yyyymmdd'), 'ddmmyyyy')
                    INTO lfecpag_cuota
                    FROM pregunseg
                   WHERE sseguro = psseguro
                     AND nmovimi = pnmovimi
                     AND cpregun = 8806;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     RAISE e_object_error;
               END;

               --
               lmonedainst := f_parinstalacion_n('MONEDAINST');
               lsum_iimppro_cuota := 0;
               lsum_iimpins_cuota := 0;

               --
               -- Genero tantas emisiones de cuotas como numero de cuotas tengo.
               FOR i IN 1 .. lnmescob LOOP
                  IF i = lnmescob THEN
                     liimppro_cuota := liimppro - lsum_iimppro_cuota;
                     liimpins_cuota := liimpins - lsum_iimpins_cuota;
                  ELSE
                     liimppro_cuota := pac_monedas.f_round((liimppro / lnmescob), lcmoneda);
                     liimpins_cuota := pac_monedas.f_round((liimpins / lnmescob), lmonedainst);
                     lsum_iimppro_cuota := lsum_iimppro_cuota + liimppro_cuota;
                     lsum_iimpins_cuota := lsum_iimpins_cuota + liimpins_cuota;
                  END IF;

                  --
                  num_err := f_insctacliente(NVL(pcempres, gcempres), lsperson, psseguro, NULL,
                                             lfecpag_cuota, lfecpag_cuota, lcmovimi, ltdescri,
                                             liimppro_cuota, lcmoneda, liimppro_cuota,
                                             liimpins_cuota, NVL(lfcambio, TRUNC(f_sysdate)),
                                             pnrecibo, NULL, lsproduc);
                  --
                  lfecpag_cuota := ADD_MONTHS(lfecpag_cuota, 1);
               --
               END LOOP;
            --
            END IF;

            --
            IF num_err <> 0 THEN
               RAISE e_object_error;
            END IF;
         --
         ELSE
            p_tab_error(f_sysdate, f_user, 'PAC_CTACLIENTE.f_ins_movrecctacli', 1,
                        'Falta Tipificaci�n CMOVIMI.',
                        'Tipificaci�n no contemplada.' || ' CTIPREC =' || lctiprec
                        || ' CESTREC =' || lcestrec || ' CESTANT =' || lcestant);
         END IF;
      END IF;

      --
      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, num_err);
         RETURN num_err;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, num_err);
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN SQLCODE;
   END f_ins_movrecctacli;

   /******************************************************************************
      NOMBRE:     F_OBTENERPOLIZAS
      PROP¿SITO:  Funcion que obtiene las polizas asociadas a un cliente que han
                  generado movimientos en CTACLIENTE.

      PARAMETROS:

           return            : 0 -> Todo correcto
                               1 -> Se ha producido un error

   *****************************************************************************/
   FUNCTION f_obtenerpolizas(psperson per_personas.sperson%TYPE, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psperson= ' || psperson;
      vobject        VARCHAR2(200) := 'pac_ctacliente.f_obtenerpolizas';
      cur            sys_refcursor;
   BEGIN
      vpasexec := 2;

      OPEN cur FOR
         SELECT   s.sseguro, s.npoliza, s.ncertif, s.fefecto, s.cagente,
                  pac_redcomercial.ff_desagente(s.cagente, gidioma) tagente, t.ttitulo
             FROM seguros s, titulopro t
            WHERE s.sseguro IN(
                     SELECT DISTINCT (c.sseguro)
                                FROM ctacliente c
                               WHERE c.sperson = psperson
                                 AND c.sseguro <> 0
                            GROUP BY c.sseguro
                     UNION
                     SELECT DISTINCT (tm.sseguro)
                                FROM tomadores tm, seguros sg
                               WHERE tm.sperson = psperson
                                 AND sg.sseguro = tm.sseguro
                                 AND NVL
                                       (f_parproductos_v
                                                     (pac_productos.f_get_sproduc(sg.cramo,
                                                                                  sg.cmodali,
                                                                                  sg.ctipseg,
                                                                                  sg.ccolect),
                                                      'HAYCTACLIENTE'),
                                        0) = 2)
              AND s.cramo = t.cramo
              AND s.cmodali = t.cmodali
              AND s.ctipseg = t.ctipseg
              AND s.ccolect = t.ccolect
              AND t.cidioma = gidioma
         UNION ALL
         SELECT   cta.sproduc * -1, 0, 0, NULL, NULL, NULL, t.ttitulo || ' - ' || cta.tdescri
             FROM ctacliente cta, titulopro t, productos p
            WHERE cta.sperson = psperson
              AND cta.sseguro = 0
              AND cta.sproduc = p.sproduc
              AND p.cramo = t.cramo
              AND p.cmodali = t.cmodali
              AND p.ctipseg = t.ctipseg
              AND p.ccolect = t.ccolect
              AND t.cidioma = gidioma
         GROUP BY cta.sproduc, 0, 0, t.ttitulo || ' - ' || cta.tdescri
         ORDER BY 1;

      vpasexec := 3;
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_obtenerpolizas;

   /******************************************************************************
      NOMBRE:    F_OBTENERPERSONAS
      PROP¿SITO: Funci¿n que obtiene las personas asociadas a una poliza que han
                 generado movimientos CTACLIENTE

      PARAMETROS:

           return            : 0 -> Todo correcto
                               1 -> Se ha producido un error

   *****************************************************************************/
   FUNCTION f_obtenerpersonas(psseguro seguros.sseguro%TYPE, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psseguro= ' || psseguro;
      vobject        VARCHAR2(200) := 'pac_ctacliente.f_obtenerpersonas';
      cur            sys_refcursor;
   BEGIN
      vpasexec := 2;

      OPEN cur FOR
         SELECT   p.sperson, pac_isqlfor.f_dades_persona(p.sperson, 8, f_usu_idioma) tide,
                  pac_persona.f_format_nif(p.nnumide, p.ctipide, p.sperson,
                                           'POL') identificacion,
                  pac_isqlfor.ff_nombre(p.sperson, 3) nombre,
                  pac_isqlfor.f_dades_persona(p.sperson, 2) fnac
             FROM per_personas p
            WHERE p.sperson IN(
                    SELECT DISTINCT (c.sperson)
                               FROM ctacliente c, seguros sg
                              WHERE sg.sseguro = psseguro
                                AND c.sseguro = sg.sseguro
                                AND c.sperson <> 0
                                AND NVL (f_parproductos_v
                                                     (pac_productos.f_get_sproduc(sg.cramo,
                                                                                  sg.cmodali,
                                                                                  sg.ctipseg,
                                                                                  sg.ccolect),
                                                      'HAYCTACLIENTE'),
                                       0) <> 2
                    UNION
                    SELECT DISTINCT (tm.sperson)
                               FROM tomadores tm, seguros sg
                              WHERE sg.sseguro = psseguro
                                AND tm.sseguro = sg.sseguro
                                AND NVL (f_parproductos_v
                                                     (pac_productos.f_get_sproduc(sg.cramo,
                                                                                  sg.cmodali,
                                                                                  sg.ctipseg,
                                                                                  sg.ccolect),
                                                      'HAYCTACLIENTE'),
                                       0) = 2)
         ORDER BY 1;

      vpasexec := 3;
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_obtenerpersonas;

   /******************************************************************************
      NOMBRE:     F_INS_PAGOINICTACLI
      PROP¿SITO:  Funcion que inserta el Mvto de pago Inicial en CTACLIENTE

      PARAMETROS:

           return            : 0 -> Todo correcto
                               1 -> Se ha producido un error

    *****************************************************************************/
   FUNCTION f_ins_pagoinictacli(
      pcempres IN NUMBER,
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pffecmov IN DATE,
      piimpope IN NUMBER,
      pcmoneda IN NUMBER,
      psproduc IN NUMBER,
      pseqcaja IN NUMBER,
      pfcambio IN DATE DEFAULT NULL,
      ptdescri IN VARCHAR2 DEFAULT NULL,   --BUG 32667:NSS:13/10/2014
      panula IN NUMBER DEFAULT 0)   --BUG 32667:NSS:13/10/2014)
      RETURN NUMBER IS
      --
      vcdivisa       productos.cdivisa%TYPE;
      lnnumlin       ctacliente.nnumlin%TYPE;
      vsmoneda       eco_tipocambio.cmondes%TYPE;
      vsdivisa       eco_tipocambio.cmondes%TYPE;
      viimppro       ctacliente.iimppro%TYPE;
      vitasa         eco_tipocambio.itasa%TYPE;
      vcmoneda       parinstalacion.nvalpar%TYPE;
      viimpins       ctacliente.iimpins%TYPE;
      ltdescri       ctacliente.tdescri%TYPE;
      num_error      NUMBER := 0;
      vparam         VARCHAR2(2000)
         := 'SPERSON = ' || psperson || ' SSEGURO =' || psseguro || ' pffecmov =' || pffecmov
            || ' pcmoneda =' || pcmoneda || ' piimpope =' || piimpope || ' psproduc ='
            || psproduc || ' pseqcaja =' || pseqcaja || ' fcambio =' || pfcambio
            || 'tdescri = ' || ptdescri || ' panula: ' || panula;
      vobject        VARCHAR2(200) := 'PAC_CTACLIENTE.f_ins_pagoinictacli';
      vpasexec       NUMBER(8) := 1;
      vcmovimi       NUMBER;   --BUG 32667:NSS:13/10/2014
   BEGIN
      --
      SELECT cdivisa
        INTO vcdivisa
        FROM productos
       WHERE sproduc = psproduc;

      --
      IF vcdivisa = pcmoneda THEN
         viimppro := piimpope;
      ELSE
         vpasexec := 2;
         vitasa := pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(pcmoneda),
                                               pac_monedas.f_cmoneda_t(vcdivisa),
                                               NVL(pfcambio, pffecmov));

         IF vitasa IS NOT NULL THEN
            vpasexec := 3;
            viimppro := pac_monedas.f_round(piimpope * vitasa, vcdivisa);
         ELSE
            num_error := 9902592;
         END IF;
      END IF;

      --
      vpasexec := 4;
      vcmoneda := pac_md_common.f_get_parinstalacion_n('MONEDAINST');

      --
      IF vcmoneda = pcmoneda THEN
         viimpins := piimpope;
      ELSE
         vpasexec := 5;
         vitasa := pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(pcmoneda),
                                               pac_monedas.f_cmoneda_t(vcmoneda),
                                               NVL(pfcambio, pffecmov));

         IF vitasa IS NOT NULL THEN
            vpasexec := 6;
            viimpins := pac_monedas.f_round(piimpope * vitasa, vcmoneda);
         ELSE
            num_error := 9902592;
         END IF;
      END IF;

      IF ptdescri IS NOT NULL   --BUG 32667:NSS:13/10/2014
                             THEN
         ltdescri := ptdescri;   --BUG 32667:NSS:13/10/2014
      ELSE
         ltdescri := 'Pago Inicial - ' || pseqcaja;
      END IF;   --BUG 32667:NSS:13/10/2014

      --
      IF num_error = 0 THEN
         vpasexec := 7;

         --ini BUG 32667:NSS:13/10/2014
         IF panula = 0 THEN
            vcmovimi := 0;
         ELSIF panula = 1 THEN
            vcmovimi := 6;
         END IF;

         --fin BUG 32667:NSS:13/10/2014
         num_error := f_insctacliente(pcempres, psperson, psseguro, NULL, pffecmov, pffecmov,
                                      vcmovimi,   --BUG 32667:NSS:13/10/2014
                                      ltdescri, viimppro, pcmoneda, piimpope, viimpins,
                                      NVL(pfcambio, pffecmov), NULL, NULL, psproduc, pseqcaja);
      END IF;

      --
      IF num_error <> 0 THEN
         RAISE e_param_error;
      END IF;

      --
      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, num_error);
         RETURN num_error;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN SQLCODE;
   END f_ins_pagoinictacli;

   --
   /******************************************************************************
      NOMBRE:     F_UNIR_CTACLIENTE_PINICIAL
      PROP¿SITO:  Funcion que une las cuentas Clientes entre el Mvto de pago Inicial
                  y el Generado al emitir la p¿liza. Dejando pagado el recibo

      PARAMETROS:

           return            : 0 -> Todo correcto
                               1 -> Se ha producido un error

    *****************************************************************************/
   FUNCTION f_unir_ctacliente_pinicial(
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pfecha IN DATE,
      pnmovimi IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
      vparam         VARCHAR2(2000)
          := 'PSSEGURO = ' || psseguro || ' pfecha = ' || pfecha || ' pnmovimi = ' || pnmovimi;
      vobject        VARCHAR2(200) := 'f_unir_ctacliente_pinicial';
      vpasexec       NUMBER(8) := 1;
      --
      lnnumlin       ctacliente.nnumlin%TYPE;
      lcmoneda       ctacliente.cmoneda%TYPE;
      ljiimppro      ctacliente.iimppro%TYPE;
      ljiimpins      ctacliente.iimpins%TYPE;
      ljiimpope      ctacliente.iimpope%TYPE;
      litasa         eco_tipocambio.itasa%TYPE;
      lisaldo        ctacliente.isaldo%TYPE;
      --
      texto          VARCHAR2(400);
      --
      lnumaportaciones NUMBER := 0;
      -- n¿mero de aportaciones iniciales del seguro
      lctacliffecmov ctacliente.ffecmov%TYPE;
-- fecha movimiento de la aportaci¿n inicial (me interesa en el caso de s¿lo haya una aportaci¿n, si hay m¿s me da igual)
      lrecfemisio    recibos.femisio%TYPE;
-- fecha emisi¿n del recibo (para las aportaciones iniciales s¿lo hay un recibo)
      lcmonedaprod   productos.cdivisa%TYPE;   -- moneda del producto
      --
   BEGIN
      --
      vpasexec := 1;
      lcmoneda := pac_md_common.f_get_parinstalacion_n('MONEDAINST');

      --
      -- Si existe m¿s de un riesgo y el pagador es cada riesgo o si un recibo esta realicionado con varios movimientos de caja
      -- tendremos que realizar la uni¿n de cada una de las ctacliente.
      FOR j IN (SELECT cta.*
                  FROM ctacliente cta, pregunpolsegtab pre
                 WHERE cta.sseguro = 0
                   AND cta.sproduc = psproduc
                   AND cta.seqcaja = pre.nvalor
                   AND pre.cpregun = 432
                   AND pre.nmovimi = pnmovimi
                   AND pre.sseguro = psseguro) LOOP
         ljiimppro := j.iimppro;
         ljiimpins := j.iimpins;
         ljiimpope := 0;
         -- n¿mero de aportaciones, y fecha en caso de que s¿lo hay una
         lnumaportaciones := lnumaportaciones + 1;
         lctacliffecmov := TRUNC(j.ffecmov);

         -- tasa de cambio de la moneda de la operaci¿n a la de instalaci¿n
         IF lcmoneda <> j.cmoneda THEN
            vpasexec := 2;
            litasa := pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(j.cmoneda),
                                                  pac_monedas.f_cmoneda_t(lcmoneda),
                                                  j.fcambio);

            --
            IF litasa IS NULL THEN
               vpasexec := 3;
               num_err := 9902592;
               texto := f_axis_literales(num_err, gidioma);
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                           texto || ' - ' || SQLERRM);
               EXIT;
            END IF;
         --
         ELSE
            litasa := 1;
         END IF;

         vpasexec := 4;

         --
         -- Solo se seleccionan los movimientos de cuotas, que no se han pagado
         FOR i IN (SELECT   sperson, sseguro, nrecibo, SUM(iimppro) iimppro,
                            SUM(iimpins) iimpins
                       FROM ctacliente c
                      WHERE sseguro = psseguro
                        AND cmovimi IN(1, 2)
                   GROUP BY sperson, sseguro, nrecibo) LOOP
            -- fecha emisi¿n del recibo
            SELECT TRUNC(femisio)
              INTO lrecfemisio
              FROM recibos
             WHERE nrecibo = i.nrecibo;

            --
            IF i.iimppro < 0 THEN
               --
               IF ljiimppro > ABS(i.iimppro)
                  AND ljiimppro > 0 THEN
                  --
                  IF j.cmoneda = lcmoneda THEN
                     ljiimpope := ABS(i.iimpins);
                  ELSE
                     ljiimpope := pac_monedas.f_round(ABS(i.iimpins) * litasa, lcmoneda);
                  END IF;

                  --
                  num_err := pac_ctacliente.f_insctacliente(gcempres, i.sperson, psseguro,
                                                            lnnumlin, j.ffecmov, j.ffecval,
                                                            j.cmovimi, j.tdescri,
                                                            ABS(i.iimppro), j.cmoneda,
                                                            ljiimpope, ABS(i.iimpins),
                                                            j.fcambio, i.nrecibo, NULL,
                                                            j.sproduc, j.seqcaja);
               --
               ELSIF ljiimppro = ABS(i.iimppro) THEN
                  --
                  num_err := pac_ctacliente.f_insctacliente(gcempres, i.sperson, psseguro,
                                                            lnnumlin, j.ffecmov, j.ffecval,
                                                            j.cmovimi, j.tdescri, j.iimppro,
                                                            j.cmoneda, j.iimpope, j.iimpins,
                                                            j.fcambio, i.nrecibo, NULL,
                                                            j.sproduc, j.seqcaja);
               --
               ELSIF ljiimppro < ABS(i.iimppro)
                     AND ljiimppro > 0 THEN
                  --
                  IF j.cmoneda = lcmoneda THEN
                     ljiimpope := ljiimpins;
                  ELSE
                     ljiimpope := pac_monedas.f_round(ljiimpins * litasa, lcmoneda);
                  END IF;

                  --
                  num_err := pac_ctacliente.f_insctacliente(gcempres, i.sperson, psseguro,
                                                            lnnumlin, j.ffecmov, j.ffecval,
                                                            j.cmovimi, j.tdescri, ljiimppro,
                                                            j.cmoneda, ljiimpope, ljiimpins,
                                                            j.fcambio, i.nrecibo, NULL,
                                                            j.sproduc, j.seqcaja);
               END IF;

               --
               ljiimppro := ljiimppro + i.iimppro;
               ljiimpins := ljiimpins + i.iimpins;

               --
               IF num_err <> 0
                  OR ljiimppro <= 0 THEN
                  EXIT;
               END IF;
            --
            END IF;
         --
         END LOOP;

         --
         vpasexec := 5;

         --
         IF num_err <> 0 THEN
            texto := f_axis_literales(num_err, gidioma);
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                        texto || ' - ' || SQLERRM);
            EXIT;
         END IF;

         -- Borramos la CTACLIENTE del pago inicial, pq ya se ha asignado a la persona/poliza.
         DELETE      ctacliente
               WHERE seqcaja = j.seqcaja
                 AND sseguro = 0;

         -- Actualizamos las CTACLIENTES de los pagos iniciales de la persona. Reconstruyendo el saldo.
         FOR k IN (SELECT   cta.*
                       FROM ctacliente cta
                      WHERE sseguro = 0
                        AND sproduc = j.sproduc
                        AND sperson = j.sperson
                   ORDER BY nnumlin) LOOP
            --
            lisaldo := 0;

            --
            SELECT SUM(iimppro)
              INTO lisaldo
              FROM ctacliente
             WHERE sperson = k.sperson
               AND sseguro = k.sseguro
               AND sproduc = k.sproduc
               AND nnumlin <= k.nnumlin;

            UPDATE ctacliente
               SET isaldo_prod = lisaldo
             WHERE sperson = k.sperson
               AND sseguro = k.sseguro
               AND sproduc = k.sproduc
               AND nnumlin = k.nnumlin;
         --
         END LOOP;
      --
      END LOOP;

      --
      vpasexec := 6;

      IF num_err = 0 THEN
         -- Cobro los recibos
         FOR j IN (SELECT   cta.nrecibo
                       FROM ctacliente cta, pregunpolsegtab pre
                      WHERE cta.sseguro = pre.sseguro
                        AND cta.seqcaja = pre.nvalor
                        AND pre.cpregun = 432
                        AND pre.nmovimi = pnmovimi
                        AND pre.sseguro = psseguro
                   GROUP BY cta.nrecibo) LOOP
            --
            pac_ctacliente.ggrabar := 0;
            num_err := pac_ctacliente.f_pago_recibo(j.nrecibo);
            pac_ctacliente.ggrabar := 1;
         --
         END LOOP;
      END IF;

      --
      vpasexec := 7;

      IF num_err = 0 THEN
         -- guardar en detmovrecibo, detmovrecibo_parcial s¿lo en caso que:
         --    si el n¿mero de aportaciones iniciales es 1 y la fecha del movimiento del recibo emitido no coincide con la fecha de la aportaci¿n
         --  ¿ si el n¿mero de aportaciones iniciales es > 1 (independientemente de si la fecha del recibo coincide o no con las fechas de las aportaciones)
         IF (lnumaportaciones = 1
             AND lctacliffecmov IS NOT NULL
             AND lrecfemisio IS NOT NULL
             AND lctacliffecmov <> lrecfemisio)
            OR(lnumaportaciones > 1) THEN
            -- moneda del producto
            SELECT cdivisa
              INTO lcmonedaprod
              FROM productos
             WHERE sproduc = psproduc;

            -- bucle de las aportaciones realizadas ya relacionadas con el recibo
            FOR j IN (SELECT cta.*
                        FROM ctacliente cta, pregunpolsegtab pre
                       WHERE cta.sseguro = pre.sseguro
                         AND cta.seqcaja = pre.nvalor
                         AND pre.cpregun = 432
                         AND pre.nmovimi = pnmovimi
                         AND pre.sseguro = psseguro) LOOP
               -- tasa de cambio de la moneda del producto a la de instalaci¿n
               IF lcmonedaprod <> lcmoneda THEN
                  litasa :=
                     pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(lcmonedaprod),
                                                 pac_monedas.f_cmoneda_t(lcmoneda), j.fcambio);
               ELSE
                  litasa := 1;
               END IF;

               --
               num_err := pac_adm_cobparcial.f_set_detmovrecibo(j.nrecibo,   -- nrecibo
                                                                NULL,   -- psmovrec
                                                                NULL,   -- pnorden
                                                                j.iimppro,
                                                                -- piimporte (en moneda del producto)
                                                                NULL,   -- pfmovimi
                                                                NULL,   -- pfefeadm
                                                                NULL,   -- pcusuari
                                                                NULL,   -- psdevolu
                                                                NULL,   -- pnnumnlin
                                                                NULL,   -- pcbancar1
                                                                NULL,   -- pnnumord
                                                                NULL,   -- psmovrecr
                                                                NULL,   -- pnordenr
                                                                j.seqcaja,   -- ptdescrip,
                                                                j.iimpins,
                                                                -- piimpmon (en moneda de la instalaci¿n)
                                                                NULL,   --psproces,
                                                                NULL,   --vimoncon,
                                                                litasa, j.fcambio);
               --
               vpasexec := 8;

               --
               IF num_err <> 0 THEN
                  texto := f_axis_literales(num_err, gidioma);
                  p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                              texto || ' - ' || SQLERRM);
                  EXIT;
               END IF;
            END LOOP;
         END IF;
      END IF;

      RETURN num_err;
   --
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, num_err);
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN SQLCODE;
   END f_unir_ctacliente_pinicial;

   --
   /******************************************************************************
      NOMBRE:     F_PAGO_RECIBO
      PROP¿SITO:  Funcion que genera el movimiento de pagado en un recibo

      PARAMETROS:

           return            : 0 -> Todo correcto
                               1 -> Se ha producido un error

    *****************************************************************************/
   FUNCTION f_pago_recibo(pnrecibo IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
      vparam         VARCHAR2(2000) := ' PNRECIBO = ' || pnrecibo;
      vobject        VARCHAR2(200) := 'PAC_CTACLIENTE.f_pago_recibo';
      vpasexec       NUMBER(8) := 1;
      --
      lsmovrec       NUMBER := 0;
      lnliqmen       NUMBER;
      lcestrec       NUMBER;
      lnliqlin       NUMBER;

      --
      CURSOR cur_recibos IS
         SELECT *
           FROM recibos
          WHERE nrecibo = pnrecibo;
   --
   BEGIN
      --
      FOR r IN cur_recibos LOOP
         num_err := f_situarec(r.nrecibo, TRUNC(f_sysdate), lcestrec);

         IF num_err = 0
            AND lcestrec = 0 THEN
            num_err := f_movrecibo(r.nrecibo, 1, NULL, NULL, lsmovrec, lnliqmen, lnliqlin,
                                   f_sysdate, r.ccobban, r.cdelega, NULL, NULL, NULL, NULL,
                                   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                   NULL, NULL, NULL, NULL, NULL, NULL, 0);
         END IF;

         --
         IF num_err <> 0 THEN
            EXIT;
         END IF;
      --
      END LOOP;

      --
      RETURN num_err;
   --
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, num_err);
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN SQLCODE;
   END f_pago_recibo;

   /******************************************************************************
      NOMBRE:     F_PAGAR_RECIBO_CONSALDO
      PROP¿SITO:  Funcion que al emitir un recibo de cuota, si hay saldo lo paga.

      PARAMETROS:

           return            : 0 -> Todo correcto
                               1 -> Se ha producido un error

   *****************************************************************************/
   FUNCTION f_pagar_recibo_consaldo(
      pcempres IN NUMBER,
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pcmovimi IN NUMBER,
      pnrecibo IN NUMBER,
      piimppro IN NUMBER,
      pisaldo_prod IN NUMBER)
      RETURN NUMBER IS
      --
      lisaldo        ctacliente.isaldo%TYPE;
      --
      vparam         VARCHAR2(2000)
         := 'PCEMPRES = ' || pcempres || ' SPERSON = ' || psperson || ' SSEGURO =' || psseguro
            || ' PCMOVIMI =' || pcmovimi || ' pisaldo_prod = ' || pisaldo_prod;
      --
      vobject        VARCHAR2(200) := 'PAC_CTACLIENTE.f_pagar_recibo_conSaldo';
      terror         VARCHAR2(200);
      vpasexec       NUMBER(8) := 1;
      num_err        axis_literales.slitera%TYPE := 0;
      ligenera       NUMBER;
      lfcobrado      DATE;
      lisobrante     NUMBER;
      lpago          NUMBER;
      lmonedainst    NUMBER;
   --
   BEGIN
      --
      lmonedainst := f_parinstalacion_n('MONEDAINST');

      --
      IF pisaldo_prod > piimppro THEN
         lisaldo := piimppro;
         lisobrante := pisaldo_prod - piimppro;
      ELSE
         lisaldo := pisaldo_prod;
         lisobrante := 0;
      END IF;

      --
      IF pcmovimi = 1 THEN   -- Movimiento Emisi¿n Cuota
         --
         IF pisaldo_prod > 0 THEN
            -- Si el saldo ant es positivo, se paga parte o totalmente el recibo
            --
            FOR i IN (SELECT   cta.cempres,cta.sperson,cta.sseguro,cta.nnumlin,cta.ffecmov,cta.ffecval,
                               cta.cmovimi,cta.tdescri,cta.iimppro,cta.cmoneda,cta.iimpope,cta.iimpins,
                               cta.fcambio,cta.isaldo,cta.seqcaja,cta.cusuari,cta.falta,cta.sproces,
                               cta.sproduc,cta.nrecibo,cta.isaldo_prod,cta.nreembo, p.cdivisa
                          FROM ctacliente cta, seguros s, productos p
                         WHERE cta.sseguro = psseguro
                           AND cta.sperson = psperson
                           AND cta.sseguro = s.sseguro
                           AND s.sproduc = p.sproduc
                           AND cta.nrecibo IS NULL
                           AND cta.cmovimi = 2
                           AND cta.isaldo_prod > 0
                           AND NVL (f_parproductos_v (s.sproduc, 'HAYCTACLIENTE'), 0) <> 2
                    UNION ALL
                      SELECT   cta.cempres,cta.sperson,cta.sseguro,cta.nnumlin,cta.ffecmov,cta.ffecval,
                               cta.cmovimi,cta.tdescri,cta.iimppro,cta.cmoneda,cta.iimpope,cta.iimpins,
                               cta.fcambio,cta.isaldo,cta.seqcaja,cta.cusuari,cta.falta,cta.sproces,
                               cta.sproduc,cta.nrecibo,cta.isaldo_prod,cta.nreembo, p.cdivisa
                          FROM ctacliente cta, seguros s, productos p
                         WHERE cta.sseguro = psseguro
                           AND cta.sseguro = s.sseguro
                           AND s.sproduc = p.sproduc
                           AND cta.nrecibo IS NULL
                           AND cta.cmovimi = 2
                           AND cta.isaldo_prod > 0
                           AND NVL (f_parproductos_v (s.sproduc, 'HAYCTACLIENTE'), 0) = 2
                      ORDER BY 4) LOOP
               --
               IF lisaldo > i.iimppro THEN
                  lpago := i.iimppro;
               ELSE
                  lpago := lisaldo;
               END IF;

               -- Inserto para compensar el pago, es decir, matar el pago original no asignado
               num_err := pac_ctacliente.f_insctacliente(i.cempres, i.sperson, i.sseguro, NULL,
                                                         i.ffecmov, i.ffecval, 6, i.tdescri,
                                                         i.iimppro * -1, i.cmoneda,
                                                         i.iimpope * -1, i.iimpins * -1,
                                                         i.fcambio, 0, i.sproces, i.sproduc,
                                                         i.seqcaja);

               IF num_err <> 0 THEN
                  RAISE e_param_error;
               END IF;

               UPDATE ctacliente
                  SET nrecibo = 0
                WHERE sseguro = i.sseguro
                  AND sperson = i.sperson
                  AND nnumlin = i.nnumlin;

               --
               IF lpago != 0 THEN
                  pac_ctacliente.ggrabar := 0;
                  -- Insertar pagos parciales. Si el importe enviado es igual al importe pendiente da el recibo por cobrado.
		  -- INI -IAXIS-4153 - JLTS - 07/06/2019 Se incluyen los nuevos par�metros en null
                  num_err := pac_adm_cobparcial.f_cobro_parcial_recibo(pnrecibo, 3, lpago,
                                                                       i.cdivisa, ligenera,
                                                                       lfcobrado, 0,
                                                                       i.sproces, i.fcambio,null,null);
                  -- FIN -IAXIS-4153 - JLTS - 07/06/2019 Se incluyen los nuevos par�metros en null
                  pac_ctacliente.ggrabar := 1;
                  lisaldo := lisaldo - lpago;

                  --
                  IF lisaldo = 0 THEN
                     -- Inserto el movimiento de pago con la fecha movimiento en la que se produce el pago (para contabilidad)
                     -- y asigno el recibo que se va ha pagado
                     num_err :=
                        pac_ctacliente.f_insctacliente
                           (i.cempres, i.sperson, i.sseguro, NULL, TRUNC(f_sysdate),
                            i.ffecval, i.cmovimi, i.tdescri, lpago, i.cmoneda,
                            pac_monedas.f_round
                               ((lpago
                                 * pac_eco_tipocambio.f_cambio
                                                           (pac_monedas.f_cmoneda_t(i.cdivisa),
                                                            pac_monedas.f_cmoneda_t(i.cmoneda),
                                                            i.fcambio)),
                                i.cmoneda),
                            pac_monedas.f_round
                               ((lpago
                                 * pac_eco_tipocambio.f_cambio
                                                         (pac_monedas.f_cmoneda_t(i.cdivisa),
                                                          pac_monedas.f_cmoneda_t(lmonedainst),
                                                          i.fcambio)),
                                lmonedainst),
                            i.fcambio, pnrecibo, i.sproces, i.sproduc, i.seqcaja);

                     IF num_err <> 0 THEN
                        RAISE e_param_error;
                     END IF;

                     --
                     IF lisobrante > 0 THEN
                        -- Inserto el movimiento de pago con la fecha movimiento en la que se produce el pago
                        num_err :=
                           pac_ctacliente.f_insctacliente
                              (i.cempres, i.sperson, i.sseguro, NULL, i.ffecmov,
                               TRUNC(f_sysdate), i.cmovimi, i.tdescri, lisobrante, i.cmoneda,
                               pac_monedas.f_round
                                  ((lisobrante
                                    * pac_eco_tipocambio.f_cambio
                                                           (pac_monedas.f_cmoneda_t(i.cdivisa),
                                                            pac_monedas.f_cmoneda_t(i.cmoneda),
                                                            i.fcambio)),
                                   i.cmoneda),
                               pac_monedas.f_round
                                  ((lisobrante
                                    * pac_eco_tipocambio.f_cambio
                                                         (pac_monedas.f_cmoneda_t(i.cdivisa),
                                                          pac_monedas.f_cmoneda_t(lmonedainst),
                                                          i.fcambio)),
                                   lmonedainst),
                               i.fcambio, NULL, i.sproces, i.sproduc, i.seqcaja);

                        IF num_err <> 0 THEN
                           RAISE e_param_error;
                        END IF;
                     END IF;
                  --

                  --EXIT; rdd y jmg
                  --
                  ELSE
                     -- Inserto el movimiento de pago con la fecha movimiento en la que se produce el pago (para contabilidad)
                     -- y asigno el recibo que se va ha pagado
                     num_err := pac_ctacliente.f_insctacliente(i.cempres, i.sperson,
                                                               i.sseguro, NULL,
                                                               TRUNC(f_sysdate), i.ffecval,
                                                               i.cmovimi, i.tdescri,
                                                               i.iimppro, i.cmoneda,
                                                               i.iimpope, i.iimpins,
                                                               i.fcambio, pnrecibo, i.sproces,
                                                               i.sproduc, i.seqcaja);

                     IF num_err <> 0 THEN
                        RAISE e_param_error;
                     END IF;
                  END IF;
               END IF;
            --
            END LOOP;
         --
         END IF;
      --
      END IF;

      --
      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, num_err);
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN SQLCODE;
   --
   END f_pagar_recibo_consaldo;

--
-- Bug 31135  Movimiento de recibos unificados
   FUNCTION f_movctacliente_recunif(precunif IN NUMBER, pcmovimi IN NUMBER)
      RETURN NUMBER IS
      vparam         VARCHAR2(2000) := 'PRECUNIF = ' || precunif || ' CMOVIMI = ' || pcmovimi;
      --
      vobject        VARCHAR2(200) := 'PAC_CTACLIENTE.f_movctacliente_recunif';
      vpasexec       NUMBER(8) := 1;
      num_err        axis_literales.slitera%TYPE := 0;
      vcempres       NUMBER;
      vsperson       NUMBER;
      vsseguro       NUMBER;
      --vnnumlin       NUMBER;
      vffecmov       DATE;
      vffecval       DATE;
      vtdescri       VARCHAR2(100);
      viimppro       NUMBER;
      vcmoneda       NUMBER;
      viimpope       NUMBER;
      viimpins       NUMBER;
      vfcambio       DATE;
      vseqcaja       NUMBER;
      vsproces       NUMBER;
      vsproduc       NUMBER;
   BEGIN
      FOR i IN (SELECT nrecibo
                  FROM adm_recunif
                 WHERE nrecunif = precunif) LOOP
         SELECT cempres, sperson, sseguro, ffecmov, ffecval, tdescri, iimppro *(-1),
                cmoneda, iimpope *(-1), iimpins *(-1), fcambio, seqcaja, sproces, sproduc
           INTO vcempres, vsperson, vsseguro, vffecmov, vffecval, vtdescri, viimppro,
                vcmoneda, viimpope, viimpins, vfcambio, vseqcaja, vsproces, vsproduc
           FROM ctacliente
          WHERE nrecibo = i.nrecibo
            AND nnumlin = (SELECT MAX(nnumlin)
                             FROM ctacliente
                            WHERE nrecibo = i.nrecibo);

         num_err := f_insctacliente(vcempres, vsperson, vsseguro, NULL, vffecmov, vffecval,
                                    pcmovimi, vtdescri, viimppro, vcmoneda, viimpope, viimpins,
                                    vfcambio, i.nrecibo, vsproces, vsproduc, vseqcaja);

         IF num_err <> 0 THEN
            RAISE e_param_error;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, num_err);
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN SQLCODE;
   END f_movctacliente_recunif;

   FUNCTION f_insctacliente_spl(
      pcempres IN NUMBER,
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pnnumlin IN NUMBER,
      pffecmov IN DATE,
      pffecval IN DATE,
      pcmovimi IN NUMBER,
      ptdescri IN VARCHAR2,
      piimppro IN NUMBER,
      pcmoneda IN VARCHAR2,
      piimpope IN NUMBER,
      piimpins IN NUMBER,
      pfcambio IN DATE,
      pnrecibo IN NUMBER,
      psproces IN NUMBER DEFAULT NULL,
      psproduc IN NUMBER DEFAULT NULL,
      pseqcaja IN NUMBER DEFAULT NULL,
      pnreembo IN NUMBER DEFAULT NULL)
--lleva un seguimiento del n¿mero de reembolsos que se realizan a un cuenta-cliente
   RETURN NUMBER IS
      --
      lnnumlin       ctacliente.nnumlin%TYPE;
      lisaldo        ctacliente.isaldo%TYPE;
      lisaldo_prod   ctacliente.isaldo_prod%TYPE;
      lnrecibo       recibos.nrecibo%TYPE;
      lfin           NUMBER;
      --
      vparam         VARCHAR2(2000)
         := 'PCEMPRES = ' || pcempres || ' SPERSON = ' || psperson || ' SSEGURO =' || psseguro
            || ' PNNUMLIN=' || lnnumlin || ' PFFECMOV =' || pffecmov || ' PFFECVAL ='
            || pffecval || ' PCMOVIMI =' || pcmovimi || ' ptdescri =' || ptdescri
            || ' PIIMPPRO =' || piimppro || ' PCMONEDA =' || pcmoneda || ' PIIMPOPE ='
            || piimpope || ' PIIMPINS =' || piimpins || ' PFCAMBIO =' || pfcambio
            || ' PNRECIBO =' || pnrecibo || ' PSPROCES =' || psproces || ' PSPRODUC ='
            || psproduc || ' PSEQCAJA =' || pseqcaja || 'PNREEMBO = ' || pnreembo;
      --
      vobject        VARCHAR2(200) := 'PAC_CTACLIENTE.f_insctacliente_spl';
      terror         VARCHAR2(200);
      vpasexec       NUMBER(8) := 1;
      num_err        axis_literales.slitera%TYPE := 0;
      ligenera       NUMBER;
      lfcobrado      DATE;
   --
   BEGIN
      IF pcmovimi = 1 THEN   -- Movimiento Emisi¿n Cuota
         --
         NULL;
         /*num_err := pac_ctacliente.f_saldo_ctacliente(pcempres, psperson, psseguro, psproduc,
                                                      lisaldo, lisaldo_prod);

         --
         IF lisaldo_prod > 0 THEN   -- Si el saldo ant es positivo, se paga parte o totalmente el recibo
            --
            num_err := f_pagar_recibo_consaldo(pcempres, psperson, psseguro, pcmovimi,
                                               pnrecibo, ABS(piimppro), lisaldo_prod);

            IF num_err <> 0 THEN
               RAISE e_param_error;
            END IF;
         --
         END IF;*/
      --
      END IF;

      vpasexec := 2;
      --
      num_err := pac_ctacliente.f_saldo_ctacliente(pcempres, psperson, psseguro, psproduc,
                                                   lisaldo, lisaldo_prod);
      vpasexec := 3;

      IF num_err <> 0 THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 4;

      --
      IF pnnumlin IS NULL THEN
         lnnumlin := pac_ctacliente.f_numlin_next(pcempres, psperson, psseguro, psproduc);
      ELSE
         lnnumlin := pnnumlin;
      END IF;

      vpasexec := 5;
      --
      --lisaldo := lisaldo + piimpins;
      lisaldo_prod := lisaldo_prod + piimppro;
      vpasexec := 6;

      --
      INSERT INTO ctacliente
                  (cempres, sperson, sseguro, nnumlin, ffecmov, ffecval,
                   cmovimi, tdescri, iimppro, cmoneda, iimpope, iimpins, fcambio,
                   isaldo, cusuari, falta, sproces, sproduc, seqcaja, nrecibo,
                   isaldo_prod, nreembo)
           VALUES (NVL(pcempres, gcempres), psperson, psseguro, lnnumlin, pffecmov, pffecval,
                   pcmovimi, ptdescri, piimppro, pcmoneda, piimpope, piimpins, pfcambio,
                   lisaldo, f_user, f_sysdate, psproces, psproduc, pseqcaja, pnrecibo,
                   lisaldo_prod, pnreembo);

      vpasexec := 7;
      --
      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN SQLCODE;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN SQLCODE;
   --
   END f_insctacliente_spl;

   FUNCTION f_apunte_pago_spl(
      pcempres NUMBER,
      psseguro NUMBER,
      pimporte NUMBER,
      --v_seqcaja,   --pseqcaja IN NUMBER,
      pncheque IN VARCHAR2 DEFAULT NULL,
      --el n¿mero de cheque puede venir de parametro
      pcestchq IN NUMBER DEFAULT NULL,   --el estado del cheque
      pcbanco IN NUMBER DEFAULT NULL,
--si el pago fue porque el cliente acredit¿ a una cuenta bancaria, el codigo del banco
      pccc IN VARCHAR2 DEFAULT NULL,   --el n¿mero de cuenta
      pctiptar IN NUMBER DEFAULT NULL,
      --si fuera por tarjeta de credito el tipo de la tarjeta
      pntarget IN VARCHAR2 DEFAULT NULL,
      --el n¿mero de la tarjeta de cr¿dito
      pfcadtar IN VARCHAR2 DEFAULT NULL,
                                         --cuando caduca la tarjeta de cr¿dito
      --100,   --pimovimi IN NUMBER,     --el importe del movimiento
      pcmedmov IN NUMBER DEFAULT NULL,   -->detvalores 481
      pcmoneop IN NUMBER DEFAULT 1,
--> 1 EUROS  moneda en que se realiza la operaci¿n, debo convertir de esa moneda a la moneda del producto para ver si puedo pagar el recibo
      pnrefdeposito IN NUMBER DEFAULT NULL,   -->referencia del dep¿sito
      pcautoriza IN NUMBER DEFAULT NULL,
      -->codigo de autorizaci¿n si fuera tarjeta de cr¿dito
      pnultdigtar IN NUMBER DEFAULT NULL,
      -->cuatro ¿ltimos d¿gitos de la tarjeta de cr¿dito
      pncuotas IN NUMBER DEFAULT NULL,   -->no aplica para msv
      pccomercio IN NUMBER DEFAULT NULL,
                  --codigo de comecio no aplica para msv);)   --RDD 22/04/2015
      -- Bug 33886/199825 ACL 23/04/2015
      pdsbanco IN VARCHAR2 DEFAULT NULL,
      --banco si es que no est¿ listado y es un banco desconocido
      pctipche IN NUMBER DEFAULT NULL,
      --tipos de cheque (cheque personal, cheque TII, cheque corporativo)
      pctipched IN NUMBER DEFAULT NULL,
      --distintos tipos de cheques draft
      pcrazon IN NUMBER DEFAULT NULL,
--tipos de razones (¿top up¿, ¿reimburse by cheque¿, ¿reimburse by transfer¿,¿transfer to other prepayment account¿)
      pdsmop IN VARCHAR2 DEFAULT NULL,   --Texto libre
      pfautori DATE DEFAULT NULL,
      --Fecha en la cual se autoriza o se deniega el pago de un cheque a un cliente
      pcestado IN NUMBER DEFAULT NULL,
      --Estado Reembolso en CajaMov
      psseguro_d IN NUMBER DEFAULT NULL,
      --Numero de seguro para asociacion destino de dineros
      pseqcaja_o IN NUMBER DEFAULT NULL,
      psperson IN NUMBER DEFAULT NULL,
      --Secuencia de caja origen de reembolso
      pseqcaja OUT NUMBER,
      ptdescchk IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
      --lisaldo        NUMBER := 0;
      --lisaldo_prod   NUMBER := 0;
      lsmovrec       NUMBER := NULL;
      lnliqmen       NUMBER := NULL;
      lnliqlin       NUMBER := NULL;
      --v_iimppro      NUMBER := NULL;
      --v_iimpope      NUMBER := 0;
      v_iimpope      NUMBER := 0;
      --v_saldo        NUMBER := 0;
      v_sproduc      NUMBER := NULL;
      v_tdescri      ctacliente.tdescri%TYPE;
      v_sperson      NUMBER := NULL;
      v_importe      NUMBER := 0;
      v_disponible_actual NUMBER := 0;
      v_total_pagado NUMBER := 0;
      v_total_cobrado NUMBER := 0;
      v_seqcaja      NUMBER := 0;
      v_seqcaja_write_off NUMBER := 0;
      v_ultrecibo    recibos.nrecibo%TYPE;
      err_text       VARCHAR2(5000);
      e_errval       EXCEPTION;
      vobject        VARCHAR2(100) := 'pac_ctacliente.f_apunte_pago_spl';
      v_pnrefdeposito NUMBER;
      v_text         VARCHAR2(200);
      vctipmov       NUMBER;
      v_cashtoler    NUMBER
                     := NVL(pac_parametros.f_parempresa_n(pcempres, 'CASH_TOLERANCE'), 0)
                        / 100;
      v_porctoler    NUMBER
                := NVL(pac_parametros.f_parempresa_n(pcempres, 'CASH_TOLERANCE_PERC'), 0)
                   / 100;
      v_writeoff     NUMBER := 0;
   BEGIN
      v_importe :=
         pimporte
         * pac_eco_tipocambio.f_cambio
             (pac_eco_monedas.f_obtener_moneda_producto(v_sproduc),

              --MONEDA ORIGEN
              pac_eco_monedas.f_obtener_cmonint(pac_parametros.f_parempresa_n(pcempres,
                                                                              'MONEDACONTAB')),
              f_sysdate);

      IF pcmedmov = 0
         AND v_importe > pac_parametros.f_parempresa_n(pcempres, 'CASH_TR_FORM_L_LIMIT')
         AND v_importe <= pac_parametros.f_parempresa_n(pcempres, 'CASH_TR_FORM_U_LIMIT') THEN
         num_err := 9907934;
         err_text := f_axis_literales(9907934, f_usu_idioma);
      --WARNING rellenar este formulario
      --RAISE e_errval;
      END IF;   --si, rellenar formulario pero dejar continuar*/ --rdd07052015

      IF pcmedmov = 0
         AND v_importe > pac_parametros.f_parempresa_n(pcempres, 'CASH_TR_FORM_U_LIMIT') THEN
         num_err := 9907935;
         err_text := f_axis_literales(9907935, f_usu_idioma);
         --WARNING la cantidad supera el l¿mite de pago posible a recibir
         RAISE e_errval;
      END IF;

      IF psseguro <> 0 THEN
         SELECT sperson
           INTO v_sperson
           FROM tomadores
          WHERE sseguro = psseguro
            AND nordtom = 1;

         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      IF psseguro = 0 THEN
         v_sperson := 0;
         v_sproduc := 0;
      END IF;

      IF pnrefdeposito IS NULL THEN
         SELECT seqmovecash.NEXTVAL
           INTO v_pnrefdeposito
           FROM DUAL;
      END IF;

      --realizamos el pago
      IF v_importe <> 0 THEN
         num_err :=
            pac_caja.f_insmvtocaja(pcempres => pcempres, pcusuari => f_user,
                                   psperson => NVL(psperson, v_sperson),
                                   pffecmov => f_sysdate, pctipmov => 0,
                                   pimovimi => v_importe,
                                   pcmoneop => pac_parametros.f_parempresa_n(pcempres,
                                                                             'MONEDACONTAB'),
                                   pseqcaja => v_seqcaja, pcmanual => 0);
         pseqcaja := v_seqcaja;

         IF num_err <> 0 THEN
            RETURN num_err;   --error en cajamov
         END IF;

         num_err := pac_caja.f_inscajadatmedio(v_seqcaja,   --pseqcaja IN NUMBER,
                                               pncheque,
                                               --el n¿mero de cheque puede venir de parametro
                                               pcestchq,   --el estado del cheque
                                               pcbanco,
--si el pago fue porque el cliente acredit¿ a una cuenta bancaria, el codigo del banco
                                               pccc,   --el n¿mero de cuenta
                                               pctiptar,
                                               --si fuera por tarjeta de credito el tipo de la tarjeta
                                               pntarget,   --el n¿mero de la tarjeta de cr¿dito
                                               pfcadtar,
                                               --cuando caduca la tarjeta de cr¿dito
                                               v_importe,
                                               --pimovimi IN NUMBER,     --el importe del movimiento
                                               pcmedmov,

                                               --pcmedmov IN NUMBER,       -->detvalores 481
                                               pac_parametros.f_parempresa_n(pcempres,
                                                                             'MONEDACONTAB'),

                                               --pcmoneop IN NUMBER,       --> 1 EUROS
                                               NVL(pnrefdeposito, v_pnrefdeposito),
                                               -->referencia del dep¿sito
                                               pcautoriza,
                                               -->codigo de autorizaci¿n si fuera tarjeta de cr¿dito
                                               pnultdigtar,
                                               -->cuatro ¿ltimos d¿gitos de la tarjeta de cr¿dito
                                               pncuotas,   -->no aplica para msv
                                               pccomercio,
                                                          --codigo de comecio no aplica para msv);
                                               -- Bug 33886/199825 ACL 23/04/2015
                                               pdsbanco,
                                               --banco si es que no est¿ listado y es un banco desconocido
                                               pctipche,
                                               --tipos de cheque (cheque personal, cheque TII, cheque corporativo)
                                               pctipched,   --distintos tipos de cheques draft
                                               pcrazon,
--tipos de razones (¿top up¿, ¿reimburse by cheque¿, ¿reimburse by transfer¿,¿transfer to other prepayment account¿)
                                               pdsmop,   --Texto libre
                                               pfautori,
                                               --Fecha en la cual se autoriza o se deniega el pago de un cheque a un cliente
                                               pcestado,   --Estado Reembolso en CajaMov
                                               psseguro,
                                               -- Numero de seguro para asociacion de reembolosos
                                               psseguro_d,
                                               --Numero de seguro para asociacion destino de dineros
                                               pseqcaja_o, ptdescchk);   --Secuencia de caja origen de reembolso

         IF num_err <> 0 THEN
            RETURN num_err;   --error en caja_datmedio
         END IF;

         IF psseguro <> 0 THEN
            IF v_importe < 0 THEN
               IF NVL(pcmedmov, 0) = 1 AND NVL(pcestado,0) <> 3 THEN
                  vctipmov := 5;
                  v_text := UPPER(NVL(f_axis_literales(9908511, pac_md_common.f_get_cxtidioma),
                                      'FALTA LITERAL'))
                            || ' - '
                            || ff_desvalorfijo(481, pac_md_common.f_get_cxtidioma, pcmedmov);
               ELSIF NVL(pcmedmov, 0) <> 6 THEN
                  vctipmov := 2;
                  v_text := UPPER(NVL(f_axis_literales(9907908, pac_md_common.f_get_cxtidioma),
                                      'FALTA LITERAL'))
                            || ' - '
                            || ff_desvalorfijo(481, pac_md_common.f_get_cxtidioma, pcmedmov)
                            || ' ('
                            || ff_desvalorfijo(1903, pac_md_common.f_get_cxtidioma, pcrazon)
                            || ')';
               ELSIF NVL(pcmedmov, 0) = 6 THEN
                  vctipmov := 2;
                  v_text := UPPER(NVL(f_axis_literales(9908746, pac_md_common.f_get_cxtidioma),
                                      'FALTA LITERAL'))
                            || ' - '
                            || ff_desvalorfijo(481, pac_md_common.f_get_cxtidioma, pcmedmov)
                            || ' ('
                            || ff_desvalorfijo(1903, pac_md_common.f_get_cxtidioma, pcrazon)
                            || ')';
               END IF;
            ELSE
               IF pcmedmov IS NULL
                  AND pcrazon IS NULL THEN
                  vctipmov := 0;
                  v_text := UPPER(NVL(f_axis_literales(9908753, pac_md_common.f_get_cxtidioma),
                                      'FALTA LITERAL'));
               ELSE
                  vctipmov := 2;
                  v_text := UPPER(NVL(f_axis_literales(9907936, pac_md_common.f_get_cxtidioma),
                                      'FALTA LITERAL'))
                            || ' - '
                            || ff_desvalorfijo(481, pac_md_common.f_get_cxtidioma, pcmedmov)
                            || ' ('
                            || ff_desvalorfijo(1903, pac_md_common.f_get_cxtidioma, pcrazon)
                            || ')';
               END IF;
            END IF;

            num_err :=
               pac_ctacliente.f_insctacliente_spl
                                                (pcempres, v_sperson, psseguro, NULL,
                                                 f_sysdate, f_sysdate, vctipmov, v_text,
                                                 v_importe,
                                                 pac_parametros.f_parempresa_n(pcempres,
                                                                               'MONEDACONTAB'),
                                                 v_importe, v_importe, f_sysdate, NULL, NULL,
                                                 v_sproduc, v_seqcaja);
         END IF;
      END IF;

      IF v_importe = 0 THEN
         SELECT NVL(MAX(a.seqcaja), 0)
           INTO v_seqcaja
           FROM ctacliente a
          WHERE sseguro = psseguro
            AND nnumlin = (SELECT MAX(z.nnumlin)
                             FROM ctacliente z
                            WHERE z.sseguro = a.sseguro
                              AND seqcaja IS NOT NULL);
      END IF;

      FOR i IN
         (SELECT   r.fefecto, vdr.itotalr, vdr.nrecibo, r.cagente, r.ccobban
              FROM vdetrecibos_monpol vdr, recibos r
             WHERE NVL(f_cestrec_mv(vdr.nrecibo, pac_md_common.f_get_cxtidioma), 0) IN (0, 4)
               AND vdr.nrecibo = r.nrecibo
               AND vdr.itotalr <> 0
               AND r.sseguro = psseguro
               --AND r.ctiprec = DECODE(pcrazon,
               --                       0, 4,
               --                       5, 12,
               --                       r.ctiprec)   -- 0-->4 top up;  5-->12 fees; else is premium
          ORDER BY r.nrecibo ASC) LOOP
         --ver si el recibo se le cobra al cliente?
         v_tdescri := NULL;
         v_disponible_actual := pac_ctacliente.f_transferible_spl(psseguro);

         SELECT a.iimpope,
                SUBSTR(f_axis_literales(9907938, pac_md_common.f_get_cxtidioma) || ' '
                       || a.tdescri,
                       1, 100),
                a.sproduc
           INTO v_iimpope,
                v_tdescri,
                v_sproduc
           FROM ctacliente a
          WHERE a.sseguro = psseguro
            AND a.nrecibo = i.nrecibo
            AND nnumlin = (SELECT MIN(z.nnumlin)
                             FROM ctacliente z
                            WHERE z.sseguro = a.sseguro
                              AND z.nrecibo = a.nrecibo);

         v_writeoff := LEAST(i.itotalr *(v_porctoler / 100), v_cashtoler);

         IF (ABS(v_disponible_actual) + v_writeoff >= i.itotalr
             AND SIGN(v_iimpope) = -1) THEN
            IF ABS(v_disponible_actual) < i.itotalr
               AND(i.itotalr - v_disponible_actual) <= v_writeoff THEN
               num_err :=
                  pac_caja.f_insmvtocaja
                                   (pcempres => pcempres, pcusuari => f_user,
                                    psperson => NVL(psperson, v_sperson),
                                    pffecmov => f_sysdate, pctipmov => 0,
                                    pimovimi =>(i.itotalr - ABS(v_disponible_actual)),
                                    pcmoneop => pac_parametros.f_parempresa_n(pcempres,
                                                                              'MONEDACONTAB'),
                                    pseqcaja => v_seqcaja_write_off, pcmanual => 0);
               pseqcaja := v_seqcaja_write_off;

               IF num_err <> 0 THEN
                  RETURN num_err;   --error en cajamov
               END IF;

               num_err :=
                  pac_caja.f_inscajadatmedio
                                     (v_seqcaja_write_off,
                                      --pseqcaja IN NUMBER,
                                      pncheque,
                                      --el n¿mero de cheque puede venir de parametro
                                      pcestchq,
                                      --el estado del cheque
                                      pcbanco,
                                      --si el pago fue porque el cliente acredit¿ a una cuenta bancaria, el codigo del banco
                                      pccc,
                                      --el n¿mero de cuenta
                                      pctiptar,
                                      --si fuera por tarjeta de credito el tipo de la tarjeta
                                      pntarget,
                                      --el n¿mero de la tarjeta de cr¿dito
                                      pfcadtar,
                                               --cuando caduca la tarjeta de cr¿dito
                                      (i.itotalr - ABS(v_disponible_actual)),
                                      --pimovimi IN NUMBER, --el importe del movimiento
                                      6,   --pcmedmov IN NUMBER, -->detvalores 481 ---> WRITE OFFS
                                      pac_parametros.f_parempresa_n(pcempres, 'MONEDACONTAB'),

                                      --pcmoneop IN NUMBER, --> 1 EUROS
                                      NVL(pnrefdeposito, v_pnrefdeposito),
                                      -->referencia del dep¿sito
                                      pcautoriza,
                                      -->codigo de autorizaci¿n si fuera tarjeta de cr¿dito
                                      pnultdigtar,
                                      -->cuatro ¿ltimos d¿gitos de la tarjeta de cr¿dito
                                      pncuotas,   -->no aplica para msv
                                      pccomercio,
                                                 --codigo de comecio no aplica para msv);
                                      -- Bug 33886/199825 ACL 23/04/2015
                                      pdsbanco,
                                      --banco si es que no est¿ listado y es un banco desconocido
                                      pctipche,
                                      --tipos de cheque (cheque personal, cheque TII, cheque corporativo)
                                      pctipched,   --distintos tipos de cheques draft
                                      pcrazon,
                                      --tipos de razones (¿top up¿, ¿reimburse by cheque¿, ¿reimburse by transfer¿,¿transfer to other prepayment account¿)
                                      pdsmop,   --Texto libre
                                      pfautori,
                                      --Fecha en la cual se autoriza o se deniega el pago de un cheque a un cliente
                                      pcestado,   --Estado Reembolso en CajaMov
                                      psseguro,
                                      -- Numero de seguro para asociacion de reembolosos
                                      psseguro_d,
                                      --Numero de seguro para asociacion destino de dineros
                                      pseqcaja_o, ptdescchk);   --Secuencia de caja origen de reembolso

               IF num_err <> 0 THEN
                  RETURN num_err;   --error en caja_datmedio
               END IF;

               IF psseguro <> 0 THEN
                  num_err :=
                     pac_ctacliente.f_insctacliente_spl
                                       (pcempres, v_sperson, psseguro, NULL, f_sysdate,
                                        f_sysdate, 2,
                                        NVL(f_axis_literales(9908563,
                                                             pac_md_common.f_get_cxtidioma),
                                            'FALTA LITERAL'),
                                        (i.itotalr - ABS(v_disponible_actual)), 1,
                                        (i.itotalr - ABS(v_disponible_actual)),
                                        (i.itotalr - ABS(v_disponible_actual)), f_sysdate,
                                        NULL, NULL, v_sproduc, v_seqcaja_write_off);
               END IF;

               v_seqcaja := v_seqcaja_write_off;
            ELSIF v_disponible_actual > i.itotalr
                  AND(v_disponible_actual - i.itotalr) <= v_writeoff THEN
               num_err :=
                  pac_caja.f_insmvtocaja
                                   (pcempres => pcempres, pcusuari => f_user,
                                    psperson => NVL(psperson, v_sperson),
                                    pffecmov => f_sysdate, pctipmov => 0,
                                    pimovimi =>(i.itotalr - v_disponible_actual),
                                    pcmoneop => pac_parametros.f_parempresa_n(pcempres,
                                                                              'MONEDACONTAB'),
                                    pseqcaja => v_seqcaja_write_off, pcmanual => 0);
               pseqcaja := v_seqcaja_write_off;

               IF num_err <> 0 THEN
                  RETURN num_err;   --error en cajamov
               END IF;

               num_err :=
                  pac_caja.f_inscajadatmedio(v_seqcaja_write_off,
                                             --pseqcaja IN NUMBER,
                                             pncheque,
                                             --el n¿mero de cheque puede venir de parametro
                                             pcestchq,
                                             --el estado del cheque
                                             pcbanco,
                                             --si el pago fue porque el cliente acredit¿ a una cuenta bancaria, el codigo del banco
                                             pccc,
                                             --el n¿mero de cuenta
                                             pctiptar,
                                             --si fuera por tarjeta de credito el tipo de la tarjeta
                                             pntarget,
                                             --el n¿mero de la tarjeta de cr¿dito
                                             pfcadtar,
                                                      --cuando caduca la tarjeta de cr¿dito
                                             (i.itotalr - v_disponible_actual),
                                             --pimovimi IN NUMBER, --el importe del movimiento
                                             6,

                                             --pcmedmov IN NUMBER, -->detvalores 481 ---> WRITE OFFS
                                             pac_parametros.f_parempresa_n(pcempres,
                                                                           'MONEDACONTAB'),

                                             --pcmoneop IN NUMBER, --> 1 EUROS
                                             NVL(pnrefdeposito, v_pnrefdeposito),
                                             -->referencia del dep¿sito
                                             pcautoriza,
                                             -->codigo de autorizaci¿n si fuera tarjeta de cr¿dito
                                             pnultdigtar,
                                             -->cuatro ¿ltimos d¿gitos de la tarjeta de cr¿dito
                                             pncuotas,   -->no aplica para msv
                                             pccomercio,
                                                        --codigo de comecio no aplica para msv);
                                             -- Bug 33886/199825 ACL 23/04/2015
                                             pdsbanco,
                                             --banco si es que no est¿ listado y es un banco desconocido
                                             pctipche,
                                             --tipos de cheque (cheque personal, cheque TII, cheque corporativo)
                                             pctipched,   --distintos tipos de cheques draft
                                             pcrazon,
                                             --tipos de razones (¿top up¿, ¿reimburse by cheque¿, ¿reimburse by transfer¿,¿transfer to other prepayment account¿)
                                             pdsmop,   --Texto libre
                                             pfautori,
                                             --Fecha en la cual se autoriza o se deniega el pago de un cheque a un cliente
                                             pcestado,   --Estado Reembolso en CajaMov
                                             psseguro,
                                             -- Numero de seguro para asociacion de reembolosos
                                             psseguro_d,
                                             --Numero de seguro para asociacion destino de dineros
                                             pseqcaja_o, ptdescchk);   --Secuencia de caja origen de reembolso

               IF num_err <> 0 THEN
                  RETURN num_err;   --error en caja_datmedio
               END IF;

               IF psseguro <> 0 THEN
                  num_err :=
                     pac_ctacliente.f_insctacliente_spl
                                       (pcempres, v_sperson, psseguro, NULL, f_sysdate,
                                        f_sysdate, 2,
                                        NVL(f_axis_literales(9908746,
                                                             pac_md_common.f_get_cxtidioma),
                                            'FALTA LITERAL'),
                                        (i.itotalr - v_disponible_actual), 1,
                                        (i.itotalr - v_disponible_actual),
                                        (i.itotalr - v_disponible_actual), f_sysdate, NULL,
                                        NULL, v_sproduc, v_seqcaja_write_off);
               END IF;

               v_seqcaja := v_seqcaja_write_off;
            END IF;

            -- si hay saldo para cobrar un recibo y el tipo de recibo es uno que se le cobra al cliente lo daremos por cobrado.
            num_err := pac_ctacliente.f_insctacliente_spl(pcempres, v_sperson, psseguro, NULL,
                                                          f_sysdate, f_sysdate, 6, v_tdescri,
                                                          i.itotalr * -1, 1, i.itotalr * -1,
                                                          i.itotalr * -1, f_sysdate, i.nrecibo,
                                                          NULL, v_sproduc, v_seqcaja);
            num_err := pac_ctacliente.f_cobrecibos_spl(v_sproduc, psseguro, i.nrecibo, f_user,
                                                       f_sysdate);

            UPDATE ctacliente
               SET tdescri =
                      SUBSTR
                         (UPPER(f_axis_literales(9903876, pac_md_common.f_get_cxtidioma))
                          || ' ' || tdescri,
                          1, 100)   --COLLECTED LABEL
             WHERE sseguro = psseguro
               AND nrecibo = i.nrecibo
               AND nnumlin > (SELECT MAX(z.nnumlin)
                                FROM ctacliente z
                               WHERE z.sseguro = psseguro
                                 AND seqcaja = v_seqcaja);

            UPDATE ctacliente
               SET cmovimi = 6,
                   seqcaja = v_seqcaja
             WHERE sseguro = psseguro
               AND nrecibo = i.nrecibo
               AND nnumlin >= (SELECT MAX(z.nnumlin)
                                 FROM ctacliente z
                                WHERE z.sseguro = psseguro
                                  AND seqcaja = v_seqcaja);

            v_disponible_actual := v_disponible_actual - i.itotalr;
         END IF;
      END LOOP;

      RETURN(0);
   EXCEPTION
      WHEN e_errval THEN
         p_tab_error(f_sysdate, f_user, vobject, 1, '0',
                     'Error : ' || num_err || ' - ' || err_text);
         RETURN num_err;
   END f_apunte_pago_spl;

   FUNCTION f_transferible_spl(psseguro NUMBER)   --RDD 22/04/2015
      RETURN NUMBER IS
      v_total_pagado NUMBER;
      v_total_cobrado NUMBER := 0;
      v_floating     NUMBER := 0;

      CURSOR c1 IS
         SELECT a.nrecibo, a.iimppro, r.fefecto   --NVL(SUM(iimpope), 0)
           --INTO v_total_cobrado
         FROM   ctacliente a, recibos r
          WHERE a.sseguro = psseguro
            AND a.cmovimi IN(1, 6)
            --AND SIGN(a.iimpope) = -1
            AND r.sseguro = a.sseguro
            AND r.nrecibo = a.nrecibo;

      v_fefecto_c    DATE;
      v_ret          NUMBER;
   BEGIN
      /*select nvl(sum(iimppro),0)
      into v_total_pagado
          from ctacliente
          where sseguro = psseguro;
          if v_total_pagado <0 then
          v_total_pagado := 0;
          end if;
          return v_total_pagado;*/

      --calculamos ahora cuando ha pagado en totalidad el cliente
      SELECT NVL(SUM(iimpope), 0)
        INTO v_total_pagado
        FROM ctacliente
       WHERE sseguro = psseguro
         AND cmovimi IN(2, 3, 4, 5);

      FOR i IN c1 LOOP
         -- Eliminamos la fecha de la llamada porque los recibos a futuro siempre devolv�a NULL
         --   estuviese cobrado o no
         /*IF f_sysdate < i.fefecto THEN
            v_fefecto_c := i.fefecto;
         ELSE
            v_fefecto_c := f_sysdate;
         END IF;*/

         IF NVL(f_cestrec_mv(i.nrecibo, f_usu_idioma), 0) IN(1, 2, 3) THEN
            v_total_cobrado := v_total_cobrado + i.iimppro;
         END IF;
      END LOOP;

      SELECT NVL(SUM(imovimi), 0)
        INTO v_floating
        FROM (SELECT a.imovimi
                FROM caja_datmedio a
               WHERE a.sseguro = psseguro
                 AND a.cestado = 1
                 AND NOT EXISTS(SELECT 1
                                  FROM caja_datmedio z
                                 WHERE z.sseguro = a.sseguro
                                   AND z.cestado > a.cestado
                                   AND z.seqcaja_o = a.seqcaja)
              UNION ALL
              SELECT a.imovimi
                FROM caja_datmedio a
               WHERE a.sseguro = psseguro
                 AND a.cestado = 2
                 AND NOT EXISTS(SELECT 1
                                  FROM caja_datmedio z
                                 WHERE z.sseguro = a.sseguro
                                   AND z.cestado > a.cestado
                                   AND z.nrefdeposito = a.seqcaja)) q;

      v_ret := ABS(NVL(v_total_pagado, 0)) - ABS(NVL(v_total_cobrado, 0))
               - ABS(NVL(v_floating, 0));

      IF v_ret < 0 THEN
         RETURN 0;
      END IF;

      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_ctacliente.f_transferible_spl', 1, 'error',
                     'error ' || TO_CHAR(SQLCODE) || ' ' || SQLERRM);
         RETURN 0;
   END f_transferible_spl;

   FUNCTION f_cobrecibos_spl(   --RDD 22/04/2015
      psproduc NUMBER,
      psseguro NUMBER,
      pnrecibo NUMBER,
      pusucobro VARCHAR2,
      pfcobro DATE)
      RETURN NUMBER IS
/***********************************************************************
 F_COBRECIBOS: Rutina que genere el cobro de recibos de forma masiva.
    Par¿metros de entrada:
    - sproduc
    - npoliza
    - nrecibo
    - Usuario de cobro por defecto f_user.
    - Fecha cobro por defecto f_sysdate.
    Par¿metros de salida:
            0 Si todo correcto
     nocobrados N¿ Total de recibos con error.
     Inserta mensajes de error en TAB_ERROR
  CREACI¿N: JAMVER 31/01/2008
***********************************************************************/
      error_num      NUMBER := 0;
      w_smovrecibo   NUMBER := 0;
      w_nliqmen      NUMBER;
      w_nliqlin      NUMBER;
      nocobrados     NUMBER := 0;

      CURSOR tratar IS
         SELECT   r.nrecibo, r.cdelega, r.ccobban, s.sproduc, s.cramo, s.cmodali, s.ctipseg,
                  s.ccolect, m.fmovini, r.cagente, s.cagrpro, s.ccompani, r.cempres,
                  r.sseguro, r.ctiprec, r.cbancar, r.nmovimi, r.fefecto
             FROM seguros s, recibos r, movrecibo m
            WHERE s.sproduc = NVL(psproduc, s.sproduc)
              AND s.sseguro = NVL(psseguro, s.sseguro)
              AND r.nrecibo = NVL(pnrecibo, r.nrecibo)
              /*AND (   r.cestimp = 4
                   OR (r.cestimp = 11 AND TRUNC (r.festimp) <= TRUNC (F_SYSDATE)
                      )
                  )*/
              AND r.sseguro = s.sseguro
              AND r.nrecibo = m.nrecibo
              AND m.fmovfin IS NULL
              AND m.cestrec = 0   -- Rebuts pendents, Todos
         ORDER BY s.sproduc;
   BEGIN
      IF psproduc IS NULL
         AND pnrecibo IS NULL
         AND psseguro IS NULL THEN
         NULL;
      ELSE
         FOR reg IN tratar LOOP
            --IF TRUNC(reg.fefecto) <= TRUNC(NVL(pfcobro, F_SYSDATE)) THEN
            error_num := f_movrecibo(reg.nrecibo, 01, NULL, NULL, w_smovrecibo, w_nliqmen,
                                     w_nliqlin, reg.fmovini, reg.ccobban, reg.cdelega, NULL,
                                     NULL);

            IF error_num = 0 THEN
               RETURN 0;
            ELSE
               nocobrados := nocobrados + 1;
               ROLLBACK;
               RETURN error_num;
            END IF;
         --ELSE
            --error_num := 2;
         --END IF;
         END LOOP;
      END IF;

      RETURN(1);
   END f_cobrecibos_spl;

   --  Bug 33886/199825 ACL
   FUNCTION f_lee_ult_re(pnpoliza IN seguros.npoliza%TYPE)
      RETURN sys_refcursor IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' NPOLIZA =' || pnpoliza;
      vobject        VARCHAR2(200) := 'pac_ctacliente.f_lee_ult_re';
      cur            sys_refcursor;
      v_sseguro      NUMBER;
      v_numreembo    NUMBER;
   BEGIN
      SELECT sseguro
        INTO v_sseguro
        FROM seguros
       WHERE npoliza = pnpoliza;

      vpasexec := 2;
      vnumerr := pac_ctacliente.f_get_nroreembolsos(v_sseguro, v_numreembo);
      vpasexec := 3;

      OPEN cur FOR
         SELECT a.cempres, ff_tomador_per(s.sseguro, 1) nombre, v_numreembo nreembo, a.sperson,
                a.sseguro, s.npoliza, s.ncertif, a.nnumlin, a.sproduc
           FROM ctacliente a, seguros s
          WHERE a.sseguro = v_sseguro
            AND a.nnumlin = (SELECT MAX(z.nnumlin)
                               FROM ctacliente z
                              WHERE z.cempres = a.cempres
                                AND z.sperson = a.sperson
                                AND z.sseguro = a.sseguro)
            AND s.sseguro = a.sseguro
            AND NVL (f_parproductos_v (s.sproduc, 'HAYCTACLIENTE'), 0) <> 2
        UNION ALL
         SELECT a.cempres, ff_tomador_per(s.sseguro, 1) nombre, v_numreembo nreembo, a.sperson,
                a.sseguro, s.npoliza, s.ncertif, a.nnumlin, a.sproduc
           FROM ctacliente a, seguros s
          WHERE a.sseguro = v_sseguro
            AND a.nnumlin = (SELECT MAX(z.nnumlin)
                               FROM ctacliente z
                              WHERE z.cempres = a.cempres
                                AND z.sseguro = a.sseguro)
            AND s.sseguro = a.sseguro
            AND NVL (f_parproductos_v (s.sproduc, 'HAYCTACLIENTE'), 0) = 2;

      vpasexec := 4;
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_lee_ult_re;

   /******************************************************************************
      NOMBRE:     F_CREA_REC_GASTO
      PROPOSITO:  Funcion que genera un recibo de gasto cuando se supere el max No de devoluciones

      PARAMETROS:

           return            : 0 -> Todo correcto
                               1 -> Se ha producido un error

   *****************************************************************************/
   FUNCTION f_crea_rec_gasto(psseguro IN seguros.sseguro%TYPE, pimonto IN NUMBER)
      RETURN NUMBER IS
      vparam         VARCHAR2(2000) := ' PSSEGURO =' || psseguro || ' PIMONTO =' || pimonto;
      vobject        VARCHAR2(200) := 'PAC_CTACLIENTE.f_crea_rec_gasto';
      terror         VARCHAR2(200);
      vpasexec       NUMBER(8) := 1;
      num_err        NUMBER;
      v_cagente      recibos.cagente%TYPE;
      v_femisio      recibos.femisio%TYPE;
      v_fefecto      recibos.fefecto%TYPE;
      v_fvencim      recibos.fvencim%TYPE;
      v_ccobban      recibos.ccobban%TYPE;
      v_nrecibo      recibos.nrecibo%TYPE;
      v_nmovimi      recibos.nmovimi%TYPE;
      v_cempres      recibos.cempres%TYPE;
      v_cgarant      detrecibos.cgarant%TYPE := NULL;
      v_sproduc      seguros.sproduc%TYPE;
      v_ctipcoa      NUMBER;
      v_imonto       NUMBER;
      e_salir        EXCEPTION;
   BEGIN
      vpasexec := 1;

      SELECT MAX(nmovimi)
        INTO v_nmovimi
        FROM movseguro s
       WHERE sseguro = psseguro;

      vpasexec := 2;
      v_femisio := f_sysdate;

      SELECT cagente, ccobban, ctipcoa, sproduc
        INTO v_cagente, v_ccobban, v_ctipcoa, v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

      VPASEXEC := 3;
      num_err := f_insrecibo(psseguro, v_cagente, f_sysdate, f_sysdate, f_sysdate, 12, NULL,
                             NULL, v_ccobban, NULL, NULL, v_nrecibo, 'R', NULL, NULL,
                             v_nmovimi, TRUNC(f_sysdate));

      IF num_err <> 0 THEN
         RAISE e_salir;
      END IF;

      vpasexec := 4;

      BEGIN
         SELECT MAX(cgarant)
           INTO v_cgarant
           FROM garanpro
          WHERE sproduc = v_sproduc
            AND cbasica = 1;
      EXCEPTION
         WHEN OTHERS THEN
            v_cgarant := 0;
      END;

      vpasexec := 5;

      IF NVL(v_cgarant, 0) = 0 THEN
         num_err := 9903335;
         RAISE e_salir;
      END IF;

      vpasexec := 6;
      num_err :=
         F_INSDETREC
            (v_nrecibo, 14, pimonto, 100, v_cgarant, 1, v_ctipcoa, NULL, 1, 0, psseguro, 1,
             pimonto, f_sysdate,
             pac_eco_monedas.f_obtener_cmoneda
                                          (pac_eco_monedas.f_obtener_moneda_producto(v_sproduc)),
             pac_parametros.f_parempresa_n(v_cempres, 'MONEDACONTAB'));

      IF num_err <> 0 THEN
         RAISE e_salir;
      END IF;

      vpasexec := 7;

      DELETE FROM vdetrecibos_monpol
            WHERE nrecibo = v_nrecibo;

      vpasexec := 8;

      DELETE      vdetrecibos
            WHERE nrecibo = v_nrecibo;

      vpasexec := 9;
      num_err := f_vdetrecibos('R', v_nrecibo);
      vpasexec := 10;

      IF num_err <> 0 THEN
         RAISE e_salir;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_salir THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, num_err);
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 140999;
   END f_crea_rec_gasto;

   -- Bug 33886/199825 ACL
   FUNCTION f_upd_nre(
      pcempres IN NUMBER,
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pnnumlin IN NUMBER,
      pnreembo IN NUMBER)
      RETURN NUMBER IS
      v_nreembo      NUMBER := 0;
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'CEMPRES = ' || pcempres || ' SSEGURO =' || psseguro || 'SPERSON = ' || psperson
            || 'NNUMLIN = ' || pnnumlin || 'NREEMBO = ' || pnreembo;
      vobject        VARCHAR2(200) := 'pac_ctacliente.f_upd_nre';
      vsproduc       NUMBER;
   BEGIN
      vpasexec := 2;
      SELECT sproduc
        INTO vsproduc
        FROM seguros
        WHERE sseguro = psseguro;

      IF NVL (f_parproductos_v (vsproduc, 'HAYCTACLIENTE'), 0) = 2 THEN
        vpasexec := 3;
        UPDATE ctacliente
           SET nreembo = pnreembo
         WHERE cempres = pcempres
           AND sseguro = psseguro
           AND nnumlin = pnnumlin;
      ELSE
        vpasexec := 4;
        UPDATE ctacliente
           SET nreembo = pnreembo
         WHERE cempres = pcempres
           AND sseguro = psseguro
           AND sperson = psperson
           AND nnumlin = pnnumlin;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 0;
   END f_upd_nre;

   /*FUNCTION f_rechaza_reembolso(psseguro IN NUMBER, pseqcaja IN NUMBER, pnnumlin IN NUMBER)
      RETURN NUMBER IS
      vparam         VARCHAR2(2000)
         := ' psseguro =' || psseguro || ' pseqcaja =' || pseqcaja || ' pnnumlin = '
            || pnnumlin;
      vobject        VARCHAR2(200) := 'PAC_CTACLIENTE.f_rechaza_reembolso';
      terror         VARCHAR2(200);
      vpasexec       NUMBER(8);
      vnumerr        NUMBER;
      v_cempres      cajamov.cempres%TYPE;
      v_sseguro      seguros.sseguro%TYPE;
      v_imovimi      caja_datmedio.imovimi%TYPE;
      v_ccobban      seguros.ccobban%TYPE;
      v_cbancar      seguros.cbancar%TYPE;
      v_cmoneop      cajamov.cmoneop%TYPE;
      e_salir        EXCEPTION;
      v_seqcaja      NUMBER;
   BEGIN
      vpasexec := 1;

      UPDATE caja_datmedio
         SET cestchq = 2,
             cestado = 4,
             fautori = f_sysdate,
             festchq = f_sysdate
       WHERE sseguro = psseguro
         AND seqcaja = pseqcaja
         AND nnumlin = pnnumlin;

      vpasexec := 2;

      SELECT cm.cempres, se.sseguro, cd.imovimi, se.ccobban, se.cbancar, cm.cmoneop
        INTO v_cempres, v_sseguro, v_imovimi, v_ccobban, v_cbancar, v_cmoneop
        FROM cajamov cm, caja_datmedio cd, seguros se
       WHERE cd.sseguro = psseguro
         AND cd.seqcaja = pseqcaja
         AND cd.nnumlin = pnnumlin
         AND cm.seqcaja = cd.seqcaja
         AND se.sseguro = cd.sseguro;

      vpasexec := 3;
      vnumerr := pac_ctacliente.f_apunte_pago_spl(v_cempres, v_sseguro, v_imovimi, NULL, NULL,
                                                  v_ccobban, v_cbancar, NULL, NULL, NULL, 2,
                                                  v_cmoneop, NULL, NULL, NULL, NULL, NULL,
                                                  NULL, NULL, NULL, 3,
                                                  'Rejection of reimbursement', f_sysdate, 1,
                                                  NULL, pseqcaja, NULL, v_seqcaja);

      IF vnumerr != 0 THEN
         RAISE e_salir;
      ELSE
         RETURN(0);
      END IF;
   EXCEPTION
      WHEN e_salir THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, vnumerr);
         RETURN vnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN SQLCODE;
   END f_rechaza_reembolso;*/

   -- Bug 33886/202377
   -- Funci¿n que recupera el numero de reembolsos de una poliza
   FUNCTION f_get_nroreembolsos(psseguro IN NUMBER, pnumreembo OUT NUMBER)
      RETURN NUMBER IS
      vparam         VARCHAR2(2000) := ' psseguro =' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_CTACLIENTE.f_get_nrorembolsos';
      terror         VARCHAR2(200);
      vpasexec       NUMBER(8);
      vnumerr        NUMBER;
      v_numreembo    NUMBER;
      vsproduc       NUMBER;
   BEGIN
      vpasexec := 2;
      SELECT sproduc
        INTO vsproduc
        FROM seguros
        WHERE sseguro = psseguro;

      IF NVL (f_parproductos_v (vsproduc, 'HAYCTACLIENTE'), 0) = 2 THEN
        BEGIN
           SELECT NVL(c.nreembo, 0)
             INTO pnumreembo
             FROM ctacliente c
            WHERE c.cempres = pac_md_common.f_get_cxtempresa
              AND c.sseguro = psseguro
              AND c.nnumlin = (SELECT MAX(c1.nnumlin)
                                 FROM ctacliente c1
                                WHERE c1.cempres = c.cempres
                                  AND c1.sseguro = c.sseguro
                                  AND c1.sproduc = c.sproduc
                                  AND c1.nreembo IS NOT NULL);
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              pnumreembo := 0;
        END;
      ELSE
        BEGIN
           SELECT NVL(c.nreembo, 0)
             INTO pnumreembo
             FROM ctacliente c
            WHERE c.cempres = pac_md_common.f_get_cxtempresa
              AND c.sseguro = psseguro
              AND c.nnumlin = (SELECT MAX(c1.nnumlin)
                                 FROM ctacliente c1
                                WHERE c1.cempres = c.cempres
                                  AND c1.sperson = c.sperson
                                  AND c1.sseguro = c.sseguro
                                  AND c1.sproduc = c.sproduc
                                  AND c1.nreembo IS NOT NULL);
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              pnumreembo := 0;
        END;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN SQLCODE;
   END f_get_nroreembolsos;

   -- Bug 33886/202377
   -- Funci¿n que actualiza el numero de reembolsos de una poliza
   FUNCTION f_actualiza_nroreembol(psseguro IN NUMBER)
      RETURN NUMBER IS
      vparam         VARCHAR2(2000) := 'psseguro = ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_CTACLIENTE.f_actualiza_nroreembol';
      terror         VARCHAR2(200);
      vpasexec       NUMBER(8);
      vnumerr        NUMBER;
      v_numreembo    NUMBER;
      v_cempres      ctacliente.cempres%TYPE := pac_md_common.f_get_cxtempresa;
      v_nnumlin      ctacliente.nnumlin%TYPE;
      v_maxnumlin    ctacliente.nnumlin%TYPE;
   BEGIN
      vpasexec := 1;
      vnumerr := pac_ctacliente.f_get_nroreembolsos(psseguro, v_numreembo);

      UPDATE ctacliente c
         SET nreembo = v_numreembo + 1
       WHERE c.cempres = v_cempres
         AND c.sseguro = psseguro
         AND c.nnumlin = (SELECT MAX(c1.nnumlin)
                            FROM ctacliente c1
                           WHERE c1.sseguro = c.sseguro)
         -- que no sea una transferencia a otra poliza
         AND not exists (SELECT 1
                           FROM caja_datmedio cj
                          WHERE cj.seqcaja = c.seqcaja
                            AND cj.crazon = 21);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN SQLCODE;
   END f_actualiza_nroreembol;

   FUNCTION f_apunte_spl(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnrecibo IN NUMBER,
      pcorigen IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      --
      lsperson       ctacliente.sperson%TYPE := NULL;
      lcmovimi       ctacliente.cmovimi%TYPE;
      ltdescri       ctacliente.tdescri%TYPE;
      liimppro       ctacliente.iimppro%TYPE;
      liimppro_cuota ctacliente.iimppro%TYPE;
      lcmoneda       ctacliente.cmoneda%TYPE;
      liimpins       ctacliente.iimpins%TYPE;
      liimpins_cuota ctacliente.iimpins%TYPE;
      lfcambio       ctacliente.fcambio%TYPE;
      lnnumlin       ctacliente.nnumlin%TYPE := NULL;
      lfecpag_cuota  ctacliente.ffecmov%TYPE;
      lsum_iimpins_cuota ctacliente.iimpins%TYPE;
      lsum_iimppro_cuota ctacliente.iimppro%TYPE;
      lmonedainst    parinstalacion.nvalpar%TYPE;
      --
      lctipreb       seguros.ctipreb%TYPE;
      lsproduc       seguros.sproduc%TYPE;
      lnmescob       seguros.nmescob%TYPE;
      lpimport       aportaseg.pimport%TYPE;
      lfefecto       recibos.fefecto%TYPE;
      lfvencim       recibos.fvencim%TYPE;
      lctiprec       recibos.ctiprec%TYPE;
      lcestrec       movrecibo.cestrec%TYPE;
      lcestant       movrecibo.cestant%TYPE;
      lfmovini       movrecibo.fmovini%TYPE;
      lnriesgo       detrecibos.nriesgo%TYPE;
      vparam         VARCHAR2(2000)
         := ' CEMPRES = ' || pcempres || ' SSEGURO =' || psseguro || ' NMOVIMI=' || pnmovimi
            || ' CTIPREC =' || lctiprec || ' CESTREC =' || lcestrec || ' NRECIBO ='
            || pnrecibo || ' FVALMOV =' || lfefecto || ' FMOVINI =' || lfmovini;
      --
      vobject        VARCHAR2(200) := 'PAC_CTACLIENTE.f_apunte_spl';
      terror         VARCHAR2(200);
      vpasexec       NUMBER(8) := 1;
      num_err        axis_literales.slitera%TYPE := 0;
      vimpcobpar     NUMBER;
                     -- Importe de los cobros parciales.   33921 23/12/2014
--
   BEGIN
      --
      vpasexec := 1;

      -- Control para que no se dupliquen movimientos
      IF ggrabar = 1 THEN
         IF pnrecibo IS NOT NULL THEN
            --
            BEGIN
               SELECT r.fefecto, r.fvencim, r.ctiprec, s.ctipreb, s.sproduc, m.cestrec,
                      m.cestant, v.itotalr, vm.itotalr, TRUNC(m.fmovdia), p.cdivisa,
                      s.nmescob, r.sperson
                 INTO lfefecto, lfvencim, lctiprec, lctipreb, lsproduc, lcestrec,
                      lcestant, liimppro, liimpins, lfmovini, lcmoneda,
                      lnmescob, lsperson
                 FROM recibos r, movrecibo m, vdetrecibos v, vdetrecibos_monpol vm, seguros s,
                      productos p
                WHERE s.sseguro = r.sseguro
                  AND p.sproduc = s.sproduc
                  AND r.nrecibo = m.nrecibo
                  AND v.nrecibo = r.nrecibo
                  AND v.nrecibo = vm.nrecibo
                  AND r.nrecibo = pnrecibo
                  AND m.fmovfin IS NULL;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  num_err := 105031;
                  RAISE e_object_error;
               WHEN OTHERS THEN
                  num_err := 1000005;
                  RAISE e_param_error;
            END;
         ELSE
            num_err := 1000005;
            RAISE e_param_error;
         END IF;

         --
         vpasexec := 2;

         -- Busco la fecha de cambio que ha aplicado en el recibo.
         BEGIN
            -- Bug 33399  Ajuste para recuperar la fcambio
            SELECT   MAX(fcambio)
                INTO lfcambio
                FROM (SELECT   TRUNC(fcambio) fcambio
                          FROM vdetrecibos_monpol vd, detrecibos d
                         WHERE vd.nrecibo = d.nrecibo
                           AND d.nrecibo = pnrecibo
                           AND vd.itotalr <> 0
                      GROUP BY fcambio)
            GROUP BY fcambio;
         --  Fin Bug 33399
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 0;
            WHEN OTHERS THEN
               num_err := 1000005;
               RAISE e_param_error;
         END;

         --
         vpasexec := 3;

         --
         IF lsperson IS NULL THEN
            num_err := pac_ctacliente.f_titular_ctacliente(psseguro, lctipreb, pnrecibo,
                                                           lsperson);

            IF num_err <> 0 THEN
               RAISE e_object_error;
            END IF;
         END IF;

         --
         vpasexec := 5;

         --
         -- Si est¿ remesado no actualizamos CTACLIENTE solo cuando den contestaci¿n Pagado.
         IF lcestrec = 3
            OR lcestant = 3 THEN   -- MMS 20150304 Bug 32654 --> agregamos lcestant
            RETURN 0;
         END IF;

         --
         IF lcestant = 0 THEN   -- Pendiente
            ltdescri := pnrecibo || ' ' || TO_CHAR(lfefecto, 'DD/MM/YYYY') || ' - '
                        || TO_CHAR(lfvencim, 'DD/MM/YYYY');

            IF lcestrec = 0 THEN   -- Pendiente --> Emision
               lcmovimi := 1;

               IF lctiprec IN(9, 10, 13) THEN
                  liimppro := liimppro;
                  liimpins := liimpins;
               ELSE   -- lctiprec IN(0, 1, 3, 4, 5, 14, 15) THEN
                  liimppro := liimppro * -1;
                  liimpins := liimpins * -1;
               END IF;
            ELSIF lcestrec = 1 THEN   -- Cobrado/ Remesado NO
               IF lctiprec IN(4, 10) THEN   -- Aportaci¿n Extra, Traspaso de Entrada
                  lcmovimi := 2;   --RDD 29072015
               --RETURN 9902693;
               ELSIF lctiprec = 9 THEN   -- Extorno
                  lcmovimi := 3;
               ELSE
-- lctiprec IN(0, 1, 3, 5, 13, 14, 15) THEN   -- Produccion, Suplemento, Cartera
                  -- Comision, Retorno, Tiempo transcurrido, Recobro del Retorno
                  lcmovimi := 2;
               END IF;

               --
               IF lctiprec IN(9, 10, 13) THEN
                  liimppro := liimppro * -1;
                  liimpins := liimpins * -1;
               ELSE   -- lctiprec IN(0, 1, 3, 4, 5, 14, 15) THEN
                  liimppro := liimppro;
                  liimpins := liimpins;
               END IF;
            ELSIF lcestrec = 2 THEN   -- Anulado
               lcmovimi := 5;   -- Anulaci¿n

               --
               IF lctiprec IN(9, 10, 13) THEN
                  liimppro := liimppro * -1;
                  liimpins := liimpins * -1;
               ELSE   -- lctiprec IN(0, 1, 3, 4, 5, 14, 15) THEN
                  liimppro := liimppro;
                  liimpins := liimpins;
               END IF;
            --
            END IF;
         ELSIF lcestant = 1 THEN   -- Cobrado
            ltdescri := pnrecibo || ' ' || TO_CHAR(lfefecto, 'DD/MM/YYYY') || ' - '
                        || TO_CHAR(lfvencim, 'DD/MM/YYYY');

            IF lcestrec = 0 THEN   -- Pendiente
               lcmovimi := 4;   -- Devoluci¿n

               --
               IF lctiprec IN(9, 10, 13) THEN
                  liimppro := liimppro;
                  liimpins := liimpins;
               ELSE   -- lctiprec IN(0, 1, 3, 4, 5, 14, 15) THEN
                  liimppro := liimppro * -1;
                  liimpins := liimpins * -1;
               END IF;
            END IF;
         ELSIF lcestant = 2 THEN   -- Anulado
            ltdescri := pnrecibo || ' ' || TO_CHAR(lfefecto, 'DD/MM/YYYY') || ' - '
                        || TO_CHAR(lfvencim, 'DD/MM/YYYY');

            IF lcestrec = 0 THEN   -- Pendiente
               lcmovimi := 1;   -- Devoluci¿n

               IF lctiprec IN(9, 10, 13) THEN
                  liimppro := liimppro;
                  liimpins := liimpins;
               ELSE   -- lctiprec IN(0, 1, 3, 4, 5, 14, 15) THEN
                  liimppro := liimppro * -1;
                  liimpins := liimpins * -1;
               END IF;
            END IF;
         END IF;

         --
         vpasexec := 6;

         --
         IF lcmovimi IS NOT NULL THEN
            --
            IF lnmescob IS NULL THEN   -- No es Pago por cuotas.
--33921   23/12/2014
               vimpcobpar := pac_adm_cobparcial.f_get_importe_cobro_parcial(pnrecibo, NULL,
                                                                            NULL, 0);

               IF vimpcobpar = liimppro THEN   --Es el ¿ltimo pago parcial
--Recuperamos el importe del ¿ltimo pago parcial, que ser¿ el que se grabe en ctacliente
                  BEGIN
                     SELECT d.iimporte, d.iimporte_moncon
                       INTO liimppro, liimpins
                       FROM detmovrecibo d
                      WHERE d.nrecibo = pnrecibo
                        AND norden = (SELECT MAX(norden)
                                        FROM detmovrecibo
                                       WHERE nrecibo = pnrecibo
                                         AND smovrec =
                                               (SELECT MAX(smovrec)
                                                  FROM movrecibo mm
                                                 WHERE nrecibo = pnrecibo
                                                   AND EXISTS(
                                                         SELECT 1
                                                           FROM detmovrecibo
                                                          WHERE nrecibo = pnrecibo
                                                            AND smovrec = mm.smovrec)));

                     lmonedainst := f_parinstalacion_n('MONEDAINST');
                     liimppro := pac_monedas.f_round((liimppro), lcmoneda);
                     liimpins := pac_monedas.f_round((liimpins), lmonedainst);
                  EXCEPTION
                     WHEN OTHERS THEN
                        --Si no encuentra nada o hay otro error dejamos el importe como est¿.
                        NULL;
                  END;
               END IF;

--33921   23/12/2014  FIN
               num_err := f_insctacliente_spl(NVL(pcempres, gcempres), lsperson, psseguro,
                                              NULL,   --RDD 22042015
                                              lfmovini, lfefecto, lcmovimi, ltdescri, liimppro,
                                              lcmoneda, liimppro, liimpins,
                                              NVL(lfcambio, TRUNC(f_sysdate)), pnrecibo, NULL,
                                              lsproduc);
            ELSE
               -- PAGO DE CUOTAS
               -- Busco la fecha de la primera cuota
               BEGIN
                  SELECT TO_DATE(TO_CHAR(crespue, 'yyyymmdd'), 'ddmmyyyy')
                    INTO lfecpag_cuota
                    FROM pregunseg
                   WHERE sseguro = psseguro
                     AND nmovimi = pnmovimi
                     AND cpregun = 8806;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     RAISE e_object_error;
               END;

               --
               lmonedainst := f_parinstalacion_n('MONEDAINST');
               lsum_iimppro_cuota := 0;
               lsum_iimpins_cuota := 0;

               --
               -- Genero tantas emisiones de cuotas como numero de cuotas tengo.
               FOR i IN 1 .. lnmescob LOOP
                  IF i = lnmescob THEN
                     liimppro_cuota := liimppro - lsum_iimppro_cuota;
                     liimpins_cuota := liimpins - lsum_iimpins_cuota;
                  ELSE
                     liimppro_cuota := pac_monedas.f_round((liimppro / lnmescob), lcmoneda);
                     liimpins_cuota := pac_monedas.f_round((liimpins / lnmescob), lmonedainst);
                     lsum_iimppro_cuota := lsum_iimppro_cuota + liimppro_cuota;
                     lsum_iimpins_cuota := lsum_iimpins_cuota + liimpins_cuota;
                  END IF;

                  --
                  num_err := f_insctacliente_spl(NVL(pcempres, gcempres), lsperson, psseguro,
                                                 NULL,   --RDD  22042015
                                                 lfecpag_cuota, lfecpag_cuota, lcmovimi,
                                                 ltdescri, liimppro_cuota, lcmoneda,
                                                 liimppro_cuota, liimpins_cuota,
                                                 NVL(lfcambio, TRUNC(f_sysdate)), pnrecibo,
                                                 NULL, lsproduc);
                  --
                  lfecpag_cuota := ADD_MONTHS(lfecpag_cuota, 1);
               --
               END LOOP;
            --
            END IF;

            --
            IF num_err <> 0 THEN
               RAISE e_object_error;
            END IF;
         --
         ELSE
            p_tab_error(f_sysdate, f_user, 'PAC_CTACLIENTE.f_apunte_spl', 1,
                        'Falta Tipificacion CMOVIMI.',
                        'Tipificacion no contemplada.' || ' CTIPREC =' || lctiprec
                        || ' CESTREC =' || lcestrec || ' CESTANT =' || lcestant);
         END IF;
      END IF;

      --
      RETURN 0;
--
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, num_err);
         RETURN num_err;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, num_err);
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN SQLCODE;
   END f_apunte_spl;
END PAC_CTACLIENTE;
/
