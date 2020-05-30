--------------------------------------------------------
--  DDL for Package Body PAC_CAJA_CHEQUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CAJA_CHEQUE" IS
   FUNCTION f_lee_cheques(
      sperson IN NUMBER,
      ncheque IN VARCHAR2,
      pseqcaja IN NUMBER,
      ptselect OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'sperson= ' || sperson || ' ncheque: ' || ncheque;
      terror         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'pac_caja_cheque.f_lee_cheques';
   BEGIN
      ptselect :=
         '   SELECT d.seqcaja AS scaja, d.ncheque AS ncheque,
       pac_persona.f_format_nif(p.nnumide, p.ctipide, p.sperson, ''SEG'') AS rut,
       f_nombre(c.sperson,1) AS nombre,
       d.cestchq AS cestado,
       ff_desvalorfijo(483, pac_md_common.f_get_cxtidioma(), d.cestchq) AS estado,
       d.festchq AS fecha,
       d.nnumlin AS nnumlin
  FROM caja_datmedio d, cajamov c, per_personas p
 WHERE d.seqcaja = c.seqcaja
   AND p.sperson = c.sperson
   AND d.cmedmov = 1
   AND d.cestchq IS NOT NULL
   AND d.cestado IS NULL';

      IF sperson IS NOT NULL THEN
         ptselect := ptselect || '  AND C.SPERSON=' || sperson;
      END IF;

      IF ncheque IS NOT NULL THEN
         ptselect := ptselect || ' AND D.NCHEQUE LIKE ''%' || ncheque || '%''';
      END IF;

      IF pseqcaja IS NOT NULL THEN
         ptselect := ptselect || ' AND D.SEQCAJA = ' || pseqcaja;
      END IF;

      ptselect := ptselect || ' ORDER BY D.FESTCHQ DESC';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1;
   END f_lee_cheques;

   FUNCTION f_set_estadocheques(pscaja IN NUMBER, pestado IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                      := 'pscaja=' || pscaja || ' pestado=' || pestado || ' pfecha=' || pfecha;
      vobject        VARCHAR2(200) := 'pac_caja_cheque.f_set_estadocheques';
      vcreccob       NUMBER;
      vcempres       NUMBER;
      resultado      NUMBER;
      vcestchq       NUMBER;
      v_cestchq      NUMBER;
      v_sproduc      NUMBER;
      v_cempres      NUMBER;
      v_sperson      NUMBER;
      v_sseguro      NUMBER;
      v_imovimi      NUMBER;
      v_tdescri      ctacliente.tdescri%TYPE;
      num_err        NUMBER;
      v_seqcajanew   NUMBER;
      -- v_sseguroc      number;
      v_cmedmov      NUMBER;
      v_smovagr      NUMBER := 0;
      vnliqmen       NUMBER;
      vnliqlin       NUMBER;
      v_importe      NUMBER := 0;
      v_itotalr      NUMBER:=0;
      --
      v_fecha_rec    DATE;
      --
   BEGIN
      vpasexec := 2;

      IF pscaja IS NULL
         OR pestado IS NULL
         OR pfecha IS NULL THEN
         RETURN 9000505;
      END IF;

      vpasexec := 3;

      SELECT cestchq, sseguro, cmedmov
        INTO vcestchq, v_sseguro, v_cmedmov
        FROM caja_datmedio
       WHERE seqcaja = pscaja;

      BEGIN
         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = v_sseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END;

      --v_sseguro := NULL;
      IF vcestchq = 2 THEN
         RETURN 110300;
      END IF;

      UPDATE caja_datmedio
         SET cestchq = pestado,
             festchq = pfecha
       WHERE seqcaja = pscaja;

      vpasexec := 4;
      vpasexec := 5;   --Bug 33886/199825 ACL

      IF NVL(f_parproductos_v(v_sproduc, 'HAYCTACLIENTE'), 0) = 2 OR v_sseguro = 0 THEN
         SELECT mov.cempres, mov.sperson, dat.sseguro, dat.cestchq, mov.imovimi
           INTO v_cempres, v_sperson, v_sseguro, v_cestchq, v_imovimi
           FROM caja_datmedio dat, cajamov mov
          WHERE dat.seqcaja = pscaja
            AND mov.seqcaja = dat.seqcaja;

         IF v_cestchq = 2 THEN
            vpasexec := 10;

            FOR rec IN (SELECT DISTINCT r.nrecibo
                                   FROM ctacliente c, caja_datmedio cd, recibos r
                                  WHERE cd.seqcaja = pscaja
                                    AND c.seqcaja = cd.seqcaja
                                    AND c.nrecibo IS NOT NULL
                                    AND r.nrecibo = c.nrecibo
                               ORDER BY r.nrecibo) LOOP
               SELECT SUM(NVL(vm.itotalr, v.itotalr))
                 INTO v_itotalr
                 FROM vdetrecibos v, vdetrecibos_monpol vm
                WHERE v.nrecibo = rec.nrecibo
                  AND vm.nrecibo(+) = v.nrecibo;


               v_importe := v_importe + NVL(v_itotalr, 0);
            END LOOP;

            vpasexec := 11;

            IF (v_imovimi - v_importe) > 0 THEN
               -- Si la cancelación de los recibos no llega al total del recibo, apuntamos la diferencia
               num_err :=
                  pac_ctacliente.f_apunte_pago_spl(pcempres => v_cempres,
                                                   psseguro => v_sseguro,
                                                   pcmedmov => v_cmedmov,
                                                   pimporte =>(v_imovimi - v_importe) * -1,
                                                   pdsmop => f_axis_literales(9908511,
                                                                              f_usu_idioma),
                                                   pseqcaja => v_seqcajanew,
                                                   psperson => v_sperson);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;

            FOR rec IN (SELECT DISTINCT r.nrecibo
                                   FROM ctacliente c, caja_datmedio cd, recibos r
                                  WHERE cd.seqcaja = pscaja
                                    AND c.seqcaja = cd.seqcaja
                                    AND c.nrecibo IS NOT NULL
                                    AND r.nrecibo = c.nrecibo
                               ORDER BY r.nrecibo) LOOP

               v_smovagr := 0;
               --
               BEGIN
                  SELECT m.fmovini
                    INTO v_fecha_rec
                    FROM movrecibo m
                   WHERE m.nrecibo = rec.nrecibo
                     AND m.smovrec = (SELECT MAX(m1.smovrec)
                                        FROM movrecibo m1
                                       WHERE m1.nrecibo = m.nrecibo
                                         AND m1.cestant = 0
                                         AND m1.cestrec = 1);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     v_fecha_rec := f_sysdate;
                  WHEN TOO_MANY_ROWS THEN
                     v_fecha_rec := f_sysdate;
                  WHEN OTHERS THEN
                     v_fecha_rec := f_sysdate;
               END;
               --
               num_err := f_movrecibo(rec.nrecibo, 0, v_fecha_rec, 2, v_smovagr, vnliqmen,
                                      vnliqlin, v_fecha_rec, NULL, NULL, NULL, NULL);

               IF num_err <> 0 THEN
                  p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam || '-' ||
                              rec.nrecibo || '-' || num_err, f_axis_literales(num_err, f_usu_idioma));
                  RETURN num_err;
               END IF;

            END LOOP;

         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 108469;
   END f_set_estadocheques;

   FUNCTION f_protestado(pscaja IN NUMBER)
      RETURN NUMBER IS
      resultado      NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pscaja=' || pscaja;
      vobject        VARCHAR2(200) := 'pac_caja_cheque.f_protestado';
      vcreccob       NUMBER;
      vcempres       NUMBER;
   BEGIN
      IF pscaja IS NULL THEN
         RETURN 9000505;
      END IF;

      vpasexec := 3;

      SELECT COUNT(*)
        INTO resultado
        FROM pagos_masivos
       WHERE seqcaja = pscaja;

      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 108469;
   END f_protestado;

   FUNCTION f_cambiar_recibos(pscaja IN NUMBER)
      RETURN NUMBER IS
      resultado      NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pscaja=' || pscaja;
      vobject        VARCHAR2(200) := 'pac_caja_cheque.f_cambiar_recibos';
      xsmovrec       NUMBER := 0;
      xnliqmen       NUMBER;
      xcestrec       NUMBER;
      dummy          NUMBER;
      v_rec          recibos.nrecibo%TYPE;
      vnrecibo       NUMBER;
      vccobban       NUMBER;

      CURSOR cur_recibos IS
         SELECT cta.*, r.ccobban
           FROM ctacliente cta, recibos r
          WHERE seqcaja = pscaja
            AND cta.nrecibo = r.nrecibo;

      CURSOR cur_recunif(snrecibo NUMBER) IS
         SELECT r.nrecibo, r.ccobban
           FROM adm_recunif ar, recibos r
          WHERE nrecunif = snrecibo
            AND ar.nrecibo = r.nrecibo;
   BEGIN
      vpasexec := 90;

      FOR r IN cur_recibos LOOP
         vpasexec := 91;
         v_rec := r.nrecibo;
         resultado := f_situarec(r.nrecibo, f_sysdate, xcestrec);

         IF resultado = 0
            AND xcestrec = 1 THEN
            vpasexec := 92;
            resultado := f_movrecibo(r.nrecibo, 0, NULL, NULL, xsmovrec, xnliqmen, dummy,
                                     f_sysdate, r.ccobban, NULL, NULL, NULL);
            -- Bug 0032663 Ini considerar los recibos agruopados
            vpasexec := 921;

            FOR runif IN cur_recunif(r.nrecibo) LOOP
               vpasexec := 923;
               resultado := f_movrecibo(runif.nrecibo, 0, NULL, NULL, xsmovrec, xnliqmen,
                                        dummy, f_sysdate, runif.ccobban, NULL, NULL, NULL);
            END LOOP;
         -- Bug 0032663 Fin
         END IF;
      --
      END LOOP;

      vpasexec := 93;
      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     vparam || ' recibo=' || v_rec || ' resultado=' || resultado, SQLERRM);
         RETURN 108469;
   END f_cambiar_recibos;

   FUNCTION f_insert_historico(
      seqcaja NUMBER,
      ncheque VARCHAR2,
      cstchq NUMBER,
      cstchq_ant NUMBER,
      festado DATE)
      RETURN NUMBER IS
      resultado      NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'seqcaja=' || seqcaja || ' ncheque=' || ncheque || ' cstchq=' || cstchq
            || ' cstchq_ant=' || cstchq_ant || ' festado=' || festado;
      vobject        VARCHAR2(200) := 'pac_caja_cheque.f_insert_historico';
      vcreccob       NUMBER;
      vcempres       NUMBER;
   BEGIN
      vpasexec := 2;

      IF seqcaja IS NULL
         OR ncheque IS NULL
         OR cstchq IS NULL
         OR cstchq_ant IS NULL
         OR festado IS NULL THEN
         RETURN 9000505;
      END IF;

      vpasexec := 3;

      INSERT INTO his_est_cheque
                  (seqcaja, ncheque, cestchq, cestchq_ant, fmovimiento, festado)
           VALUES (seqcaja, ncheque, cstchq, cstchq_ant, f_sysdate, festado);

      RETURN resultado;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 108469;
   END f_insert_historico;

   FUNCTION f_genera_archivo_cheque(
      fini DATE,
      ffin DATE,
      pcregenera IN NUMBER,
      p_directorio OUT VARCHAR2)
      RETURN NUMBER IS
      v_archivo      VARCHAR2(250);
      vpasexec       NUMBER(8) := 1;
      vnum_err       NUMBER;
      v_numerr       NUMBER;
      vparam         VARCHAR2(200)
                        := 'fini=' || fini || ' ffin=' || ffin || ' pcregenera=' || pcregenera;
      v_directorio   VARCHAR2(300);
      vobject        VARCHAR2(200) := 'pac_caja_cheque.f_genera_archivo_cheque ';
      vl_sql         VARCHAR2(4000);
      e_object_error EXCEPTION;
   BEGIN
      vpasexec := 2;

      IF fini IS NULL
         OR ffin IS NULL THEN
         RETURN 9000505;
      END IF;

      vpasexec := 3;

      SELECT 'cheque_' || TO_CHAR(f_sysdate, 'MMDDYYYYHH24MISS') || '.txt'
        INTO v_archivo
        FROM DUAL;

      vpasexec := 4;

      EXECUTE IMMEDIATE 'select pac_propio.f_genera_archivo_cheque(to_date(' || '''' || fini
                        || '''' || ') , to_date(' || '''' || ffin || '''' || ')' || ',' || ''''
                        || v_archivo || '''' || ',' || pcregenera || ') from dual'
                   INTO v_numerr;

      IF v_numerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 5;

      IF NVL(pcregenera, 0) = 0 THEN
         EXECUTE IMMEDIATE 'select pac_propio.f_actualiza_estado_cheque(to_date(' || ''''
                           || fini || '''' || '),to_date(' || '''' || ffin || ''''
                           || ')) from dual'
                      INTO vnum_err;

         IF vnum_err <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 6;
      p_directorio := f_parinstalacion_t('TABEXT_C') || '\' || v_archivo;
      vpasexec := 7;
      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 108469;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 108469;
   END f_genera_archivo_cheque;
END pac_caja_cheque;

/

  GRANT EXECUTE ON "AXIS"."PAC_CAJA_CHEQUE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CAJA_CHEQUE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CAJA_CHEQUE" TO "PROGRAMADORESCSI";
