--------------------------------------------------------
--  DDL for Package Body PAC_PP_VALORLIQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PP_VALORLIQ" AS
/*
  Toni Torres.
  03 de Gener de 2007.
  Funció per actualitzar les linies de saldo.
  Només se crida quan es modifica un valor liquidatiu. No té sentit
  cridar-la quan sa inserta un registre ja que encara no existeix cap movimient de saldo.
*/
   /******************************************************************************
      NOMBRE:       PAC_PP_VALORLIQ
      PROPÓSITO:
      REVISIONES:

      Ver        Fecha        Autor     Descripción
      ---------  ----------  -------  ------------------------------------
       1.0       -            -       1. Creación de package
       2.0       15/12/2011  JMP      2. 0018423: LCOL705 - Multimoneda
   ******************************************************************************/
   FUNCTION f_actualizar_saldo(psseguro IN NUMBER, pfvalor IN DATE)
      RETURN NUMBER IS
      partis         NUMBER;
      valor_parti    NUMBER;
      isaldo         NUMBER;
      moneda         NUMBER;
      v_cempres      seguros.cempres%TYPE;
      num_err        axis_literales.slitera%TYPE;
   BEGIN
      SELECT cempres
        INTO v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      SELECT SUM(NVL(DECODE(GREATEST(cmovimi, 9), 9, ctaseguro.nparpla, -ctaseguro.nparpla), 0))
        INTO partis
        FROM ctaseguro
       WHERE ctaseguro.sseguro = psseguro
         AND ctaseguro.cmovimi != 0
         AND TRUNC(fvalmov) <= pfvalor;

      FOR saldo IN (SELECT   cmovimi, nnumlin, nparpla, TRUNC(fvalmov) "FVALMOV"
                        FROM ctaseguro
                       WHERE ctaseguro.sseguro = psseguro
                         AND TRUNC(fvalmov) >= pfvalor
                    ORDER BY ctaseguro.fvalmov, ctaseguro.nnumlin) LOOP
         IF saldo.cmovimi > 9 THEN
            saldo.nparpla := -saldo.nparpla;
         ELSIF saldo.cmovimi = 0 THEN
            saldo.nparpla := 0;
         END IF;

         partis := partis + NVL(saldo.nparpla, 0);

         IF saldo.cmovimi = 0 THEN
            valor_parti := f_valor_participlan(saldo.fvalmov, psseguro, moneda);
            isaldo := partis * valor_parti;

            UPDATE ctaseguro
               SET nparpla = partis,
                   imovimi = isaldo
             WHERE sseguro = psseguro
               AND nnumlin = saldo.nnumlin;

            -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
            IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0) = 1 THEN
               FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                             FROM ctaseguro
                            WHERE sseguro = psseguro
                              AND nnumlin = saldo.nnumlin) LOOP
                  num_err := pac_oper_monedas.f_update_ctaseguro_monpol(reg.sseguro,
                                                                        reg.fcontab,
                                                                        reg.nnumlin,
                                                                        reg.fvalmov);

                  IF num_err <> 0 THEN
                     RETURN 1;
                  END IF;
               END LOOP;
            END IF;
         -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1;
   END f_actualizar_saldo;

   FUNCTION f_introducir_valorliq(
      pccodpla IN NUMBER,
      pfvalor IN DATE,
      pivalor IN NUMBER,
      pcidioma IN NUMBER,
      pproces IN OUT NUMBER,
      pcerror OUT NUMBER)
      RETURN NUMBER IS
      aux_fecha      DATE;
      cont           NUMBER;
      modificacio    BOOLEAN;
      err            NUMBER;
      texto          VARCHAR2(100);
      proceso        NUMBER;
      prolin         NUMBER;
      ok_valliq      BOOLEAN := FALSE;
      nook_valant    BOOLEAN := FALSE;
   BEGIN
      IF pproces IS NULL THEN
         err := f_procesini(f_user, 1, 'PAC_PP_VALORLIQ', 'Carga Valor Liquidativo', proceso);
         num_err := 0;
      ELSE
         proceso := pproces;

         IF num_err IS NULL THEN
            num_err := 0;
         END IF;
      END IF;

      SELECT COUNT(1), MAX(fvalora)
        INTO cont, aux_fecha
        FROM valparpla
       WHERE ccodpla = pccodpla;

      IF NVL(cont, 0) = 0 THEN
         texto := f_axis_literales(500140, pcidioma);
         prolin := NULL;
         err := f_proceslin(proceso, texto || ' ' || pccodpla, 0, prolin, 1);
         num_err := num_err + 1;
      END IF;

      IF pfvalor > aux_fecha + 1 THEN
         texto := f_axis_literales(111893, pcidioma);
         texto := texto || ' ' || pccodpla || ' ' || TO_CHAR(pfvalor - 1, 'DD/MM/YYYY');
         prolin := NULL;
         err := f_proceslin(proceso, texto, 0, prolin, 1);
         num_err := num_err + 1;
         nook_valant := TRUE;
      END IF;

      IF NOT(nook_valant) THEN
         BEGIN
            INSERT INTO valparpla
                        (ccodpla, fvalora, ivalorp, username)
                 VALUES (pccodpla, pfvalor, pivalor, f_user);

            modificacio := FALSE;
            texto := f_axis_literales(500142, pcidioma);
            texto := texto || ' ' || pccodpla || ' ' || TO_CHAR(pfvalor, 'DD/MM/YYYY') || ' '
                     || pivalor;
            prolin := NULL;
            err := f_proceslin(proceso, texto, 0, prolin, 4);
            ok_valliq := TRUE;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN   -- el valor liquidatiu ja existeix, modificacio.
               UPDATE valparpla
                  SET ivalorp = pivalor,
                      username = f_user
                WHERE ccodpla = pccodpla
                  AND fvalora = pfvalor;

               modificacio := TRUE;
               texto := f_axis_literales(500143, pcidioma);
               texto := texto || ' ' || pccodpla || ' ' || TO_CHAR(pfvalor, 'DD/MM/YYYY')
                        || ' ' || pivalor;
               prolin := NULL;
               err := f_proceslin(proceso, texto, 0, prolin, 4);
               ok_valliq := TRUE;
            WHEN OTHERS THEN
               prolin := NULL;
               err := f_proceslin(proceso, SUBSTR(SQLERRM, 1, 100), 0, prolin, 4);
               ok_valliq := FALSE;
         END;

         IF ok_valliq = TRUE THEN
            COMMIT;
         ELSE
            ROLLBACK;
            RETURN -1;
         END IF;

         FOR reg IN (SELECT DISTINCT seguros.sseguro
                                FROM ctaseguro, seguros, proplapen, valparpla
                               WHERE ctaseguro.sseguro = seguros.sseguro
                                 AND seguros.sproduc = proplapen.sproduc
                                 AND proplapen.ccodpla = valparpla.ccodpla
                                 AND valparpla.ccodpla = pccodpla
                                 AND TRUNC(ctaseguro.fvalmov) = pfvalor
                                 AND ctaseguro.cmovimi != 0) LOOP
            -- Posam nparpla a NULL perque el trigger de ctaseguro torni a calcular les participaciones
            UPDATE ctaseguro
               SET nparpla = NULL,
                   fasign = NULL,
                   cestpar = 1
             WHERE ctaseguro.sseguro = reg.sseguro
               AND TRUNC(ctaseguro.fvalmov) = pfvalor;

            FOR tdc IN (SELECT nnumlin, imovimi
                          FROM ctaseguro
                         WHERE ctaseguro.sseguro = reg.sseguro
                           AND TRUNC(ctaseguro.fvalmov) = pfvalor
                           AND ctaseguro.cmovimi = 8) LOOP
               p_actualizar_tdc(reg.sseguro, tdc.nnumlin, pivalor, tdc.imovimi, proceso,
                                pcidioma);
            END LOOP;

            IF modificacio THEN
               -- Miram si te linies de saldo per actualitzar.
               SELECT COUNT(1)
                 INTO cont
                 FROM ctaseguro
                WHERE ctaseguro.sseguro = reg.sseguro
                  AND TRUNC(ctaseguro.fvalmov) >= pfvalor
                  AND ctaseguro.cmovimi = 0;

               IF cont > 0 THEN
                  IF f_actualizar_saldo(reg.sseguro, pfvalor) != 0 THEN
                     texto := f_axis_literales(102556, pcidioma);
                     prolin := NULL;
                     err := f_proceslin(proceso, texto, reg.sseguro, prolin, 1);
                     num_err := num_err + 1;
                  END IF;
               END IF;

               SELECT COUNT(1)
                 INTO cont
                 FROM prestaplan
                WHERE prestaplan.sseguro = reg.sseguro
                  AND prestaplan.cestado IN(1, 2);

               IF cont > 0 THEN
                  SELECT npoliza || '-' || ncertif
                    INTO texto
                    FROM seguros
                   WHERE sseguro = reg.sseguro;

                  texto := texto || ' ' || f_axis_literales(109432, pcidioma);
                  prolin := NULL;
                  err := f_proceslin(proceso, texto, reg.sseguro, prolin, 2);
               END IF;
            END IF;
         END LOOP;
      END IF;

      IF pproces IS NULL THEN
         err := f_procesfin(proceso, num_err);
         pproces := proceso;
      END IF;

      IF NVL(pcerror, 0) = 0 THEN
         COMMIT;
         RETURN 0;
      ELSE
         ROLLBACK;
         RETURN -1;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         pcerror := 500143;
         RETURN -1;
   END f_introducir_valorliq;

   PROCEDURE p_cargar_valorliq(
      pfitxer IN VARCHAR2,
      pcidioma IN NUMBER,
      pproces OUT NUMBER,
      pcerror OUT NUMBER) IS
      ruta           VARCHAR2(100);
      fitxer         UTL_FILE.file_type;
      err            NUMBER;
      registro       VARCHAR2(1000);
      fvalor         DATE;
      ccodpla        NUMBER;
      ivalor         NUMBER;
      texto          VARCHAR2(100);
      prolin         NUMBER;
   BEGIN
      err := f_procesini(f_user, 1, 'PAC_PP_VALORLIQ', 'Carga Fichero valor liquidativo',
                         pproces);

      BEGIN
         ruta := f_parinstalacion_t('R_DEVOLUC');
         fitxer := UTL_FILE.fopen(ruta, pfitxer, 'R');
         UTL_FILE.get_line(fitxer, registro);

         -- leemos la cabecera, no se procesa.
         LOOP
            BEGIN
               UTL_FILE.get_line(fitxer, registro);
               ccodpla := TO_NUMBER(RTRIM(f_texte(registro, '|', 7), ' '));
               fvalor := TO_DATE(f_texte(registro, '|', 11), 'DD/MM/YYYY');
               ivalor := TO_NUMBER(f_texte(registro, '|', 14), 'FM99999990D0999999999');
               prolin := NULL;
               err := f_introducir_valorliq(ccodpla, fvalor, ivalor, pcidioma, pproces,
                                            pcerror);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  EXIT;
               WHEN OTHERS THEN
                  texto := f_axis_literales(103187, pcidioma);
                  prolin := NULL;
                  num_err := NVL(num_err, 0) + 1;
                  err := f_proceslin(pproces, texto || ' ' || pfitxer, 0, prolin, 1);
                  pcerror := 103187;
            END;
         END LOOP;
      EXCEPTION
         WHEN OTHERS THEN
            texto := f_axis_literales(103187, 1);
            num_err := NVL(num_err, 0) + 1;
            prolin := NULL;
            err := f_proceslin(pproces, texto || ' ' || pfitxer, 0, prolin, 1);
            pcerror := 103187;
      END;

      err := f_procesfin(pproces, NVL(num_err, 0));
      COMMIT;
   END p_cargar_valorliq;

   PROCEDURE p_actualizar_tdc(
      psseguro IN NUMBER,
      pnnumlin IN NUMBER,
      pivalor IN NUMBER,
      pimovimi IN NUMBER,
      pproces IN NUMBER DEFAULT NULL,
      pcidioma IN NUMBER DEFAULT NULL) IS
      vstras         NUMBER;
      vnnumlin       NUMBER;
      vporcant2007   NUMBER;
      vporcpos2006   NUMBER;
      vpartis        NUMBER;
      texto          VARCHAR2(100);
      prolin         NUMBER;
      err            NUMBER;
      err_datos      EXCEPTION;
      err_grave      EXCEPTION;
   BEGIN
      BEGIN
         SELECT stras, porcant2007, porcpos2006
           INTO vstras, vporcant2007, vporcpos2006
           FROM trasplainout
          WHERE sseguro = psseguro
            AND nnumlin = pnnumlin;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RAISE err_datos;
         WHEN TOO_MANY_ROWS THEN
            RAISE err_grave;
      END;

      vpartis := ROUND(pimovimi / pivalor, 6);

      UPDATE trasplainout
         SET nparpla = vpartis,
             nparant2007 = ROUND(vpartis * vporcant2007 / 100, 6),
             nparpos2006 = ROUND(vpartis * vporcpos2006 / 100, 6)
       WHERE stras = vstras;
   EXCEPTION
      WHEN err_datos THEN
         IF pproces IS NOT NULL THEN
            texto := f_axis_literales(105419, pcidioma);
            num_err := NVL(num_err, 0) + 1;
            prolin := NULL;
            err := f_proceslin(pproces, texto, psseguro, prolin, 1);
         END IF;
      WHEN err_grave THEN
         IF pproces IS NOT NULL THEN
            texto := f_axis_literales(105419, pcidioma);
            num_err := NVL(num_err, 0) + 1;
            prolin := NULL;
            err := f_proceslin(pproces, texto, psseguro, prolin, 1);
         END IF;
   END p_actualizar_tdc;
END pac_pp_valorliq;

/

  GRANT EXECUTE ON "AXIS"."PAC_PP_VALORLIQ" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PP_VALORLIQ" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PP_VALORLIQ" TO "PROGRAMADORESCSI";
