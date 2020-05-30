--------------------------------------------------------
--  DDL for Package Body PAC_COMCONVENIOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_COMCONVENIOS" AS
   /******************************************************************************
     NOMBRE:     pac_comconvenios
     PROPÓSITO:  Package para gestionar los convenios de sobrecomisión

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        11/02/2012   FAL             0025988: LCOL_C004: Realizar desarrollo Convenio Liberty web
     2.0        06/11/2013   RCL             2. 0028846: Se pudieron crear los convenios Liberty WEB con porcentaje 0
    ******************************************************************************/
   FUNCTION f_val_convenio(
      pcmodo IN NUMBER,
      pcempres IN NUMBER,
      pscomconv IN NUMBER,
      ptconvenio IN VARCHAR2,
      pcagente IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      piimporte IN NUMBER,
      pfanul IN DATE)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_comconvenios.f_val_convenio';
      vpar           VARCHAR2(500)
         := 'm=' || pcmodo || 'e=' || pcempres || 's=' || pscomconv || 't=' || ptconvenio
            || 'a=' || pcagente || 'f=' || pfinivig || 'ff=' || pffinvig || 'i=' || piimporte
            || 'fa=' || pfanul;
      v_cagente      agentes.cagente%TYPE;
      v_aux          NUMBER;
   BEGIN
      vpas := 1;

      IF pcempres IS NULL
         OR ptconvenio IS NULL
         OR pcagente IS NULL
         OR pfinivig IS NULL
         OR pffinvig IS NULL
         OR piimporte IS NULL THEN
         RAISE NO_DATA_FOUND;
      END IF;

      vpas := 2;

      IF pffinvig < pfinivig THEN
         RETURN 9904952;
      END IF;

      vpas := 3;

      BEGIN
         SELECT 1
           INTO v_aux
           FROM agentes
          WHERE cagente = pcagente;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 101842;
      END;

      vpas := 4;

      IF pcmodo = 2 THEN
         IF pscomconv IS NULL THEN
            RAISE NO_DATA_FOUND;
         END IF;

         vpas := 5;

         BEGIN
            SELECT 1
              INTO v_aux
              FROM comconvenios
             WHERE cempres = pcempres
               AND scomconv = pscomconv;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 9904954;
         END;

         IF pffinvig < f_sysdate THEN
            RETURN 9904955;
         END IF;

         vpas := 6;

         BEGIN
            SELECT COUNT(1)
              INTO v_aux
              FROM comconvenios_fec
             WHERE cempres = pcempres
               AND scomconv = pscomconv
               AND ffinvig > pffinvig;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_aux := 0;
         END;

         vpas := 7;

         IF v_aux > 0 THEN
            RETURN 9904956;
         END IF;

         SELECT cagente
           INTO v_cagente
           FROM comconvenios
          WHERE cempres = pcempres
            AND scomconv = pscomconv;

         vpas := 8;

         FOR reg_prod IN (SELECT sproduc
                            FROM comconvenios_prod
                           WHERE cempres = pcempres
                             AND scomconv = pscomconv) LOOP
            FOR reg_age IN (SELECT COUNT(DISTINCT c.scomconv) numcomconv
                              FROM comconvenios c, comconvenios_prod p, comconvenios_fec f
                             WHERE c.cempres = pcempres
                               AND c.cagente = v_cagente
                               AND c.scomconv = p.scomconv
                               AND c.scomconv != pscomconv
                               AND c.cempres = p.cempres
                               AND(c.fanul IS NULL
                                   OR c.fanul > f_sysdate)
                               AND p.cempres = f.cempres
                               AND p.scomconv = f.scomconv
                               AND((f.finivig BETWEEN TRUNC(f_sysdate) AND pffinvig)
                                   OR(f.ffinvig BETWEEN TRUNC(f_sysdate) AND pffinvig))
                               AND p.sproduc = reg_prod.sproduc) LOOP
               IF reg_age.numcomconv > 0 THEN
                  RETURN 9904957;
               END IF;
            END LOOP;
         END LOOP;
      ELSIF pcmodo = 3 THEN
         vpas := 9;

         IF pscomconv IS NULL THEN
            RAISE NO_DATA_FOUND;
         END IF;

         vpas := 10;

         BEGIN
            SELECT 1
              INTO v_aux
              FROM comconvenios
             WHERE cempres = pcempres
               AND scomconv = pscomconv;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 9904954;
         END;

         vpas := 11;

         IF pffinvig < pfinivig THEN
            RETURN 9904952;
         END IF;

         vpas := 12;

         BEGIN
            SELECT COUNT(1)
              INTO v_aux
              FROM comconvenios_fec
             WHERE cempres = pcempres
               AND scomconv = pscomconv
               AND(ffinvig >= pffinvig
                   OR finivig >= pfinivig);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_aux := 0;
         END;

         vpas := 13;

         IF v_aux > 0 THEN
            RETURN 9904958;
         END IF;

         vpas := 14;

         SELECT cagente
           INTO v_cagente
           FROM comconvenios
          WHERE cempres = pcempres
            AND scomconv = pscomconv;

         vpas := 15;

         FOR reg_prod IN (SELECT sproduc
                            FROM comconvenios_prod
                           WHERE cempres = pcempres
                             AND scomconv = pscomconv) LOOP
            FOR reg_age IN (SELECT COUNT(DISTINCT c.scomconv) numcomconv
                              FROM comconvenios c, comconvenios_prod p, comconvenios_fec f
                             WHERE c.cempres = pcempres
                               AND c.cagente = v_cagente
                               AND c.scomconv = p.scomconv
                               AND c.scomconv != pscomconv
                               AND c.cempres = p.cempres
                               AND(c.fanul IS NULL
                                   OR c.fanul > f_sysdate)
                               AND p.cempres = f.cempres
                               AND p.scomconv = f.scomconv
                               AND((f.finivig BETWEEN pfinivig AND pffinvig)
                                   OR(f.ffinvig BETWEEN pfinivig AND pffinvig))
                               AND p.sproduc = reg_prod.sproduc) LOOP
               IF reg_age.numcomconv > 0 THEN
                  RETURN 9904957;
               END IF;
            END LOOP;
         END LOOP;
      END IF;

      vpas := 16;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN NULL;
   END f_val_convenio;

   FUNCTION f_val_prod_convenio(
      pcempres IN NUMBER,
      pscomconv IN NUMBER,
      pcagente IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      psproduc IN NUMBER)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_comconvenios.f_val_prod_convenio';
      vpar           VARCHAR2(500)
         := 'e=' || pcempres || 's=' || pscomconv || 'a=' || pcagente || 'f=' || pfinivig
            || 'ff=' || pffinvig || 'p=' || psproduc;
      v_aux          NUMBER;
      v_cagente      agentes.cagente%TYPE;
   BEGIN
      vpas := 1;

      BEGIN
         SELECT 1
           INTO v_aux
           FROM productos
          WHERE sproduc = psproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 180387;
      END;

      /*    SELECT cagente
            INTO v_cagente
            FROM comconvenios
           WHERE cempres = pcempres
             AND scomconv = pscomconv;
      FOR reg_prod IN (SELECT sproduc
                         FROM comconvenios_prod
                        WHERE cempres = pcempres
                          AND scomconv = pscomconv) LOOP*/
      FOR reg_age IN (SELECT COUNT(DISTINCT c.scomconv) numcomconv
                        FROM comconvenios c, comconvenios_prod p, comconvenios_fec f
                       WHERE c.cempres = pcempres
                         AND c.cagente = pcagente   -- v_cagente
                         AND c.scomconv = p.scomconv
                         AND c.cempres = p.cempres
                         AND(c.fanul IS NULL
                             OR c.fanul > f_sysdate)
                         AND p.cempres = f.cempres
                         AND p.scomconv = f.scomconv
                         AND((pfinivig BETWEEN f.finivig AND f.ffinvig)
                             OR(pffinvig BETWEEN f.finivig AND f.ffinvig))
                         AND p.sproduc = psproduc   --reg_prod.sproduc
                                                 ) LOOP
         IF reg_age.numcomconv > 0 THEN
            RETURN 9904957;
         END IF;
      END LOOP;

      -- END LOOP;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN 1;
   END f_val_prod_convenio;

   FUNCTION f_val_modcom_convenio(
      pcempres IN NUMBER,
      pscomconv IN NUMBER,
      pcmodcom IN NUMBER,
      ppcomisi IN NUMBER)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_comconvenios.f_val_modcom_convenio';
      vpar           VARCHAR2(500)
              := 'e=' || pcempres || 's=' || pscomconv || 'c=' || pcmodcom || 'p=' || ppcomisi;
      v_aux          NUMBER;
   BEGIN
      vpas := 1;

      IF pcmodcom IS NULL
         OR ppcomisi IS NULL THEN
         RAISE NO_DATA_FOUND;
      END IF;

      --BUG 28846/158110 - RCL - 06/11/2013 - 0028846: Se pudieron crear los convenios Liberty WEB con porcentaje 0
      IF ppcomisi < 1
         OR ppcomisi > 100 THEN
         RETURN 9906245;
      END IF;

      v_aux := 0;

      SELECT COUNT(1)
        INTO v_aux
        FROM detvalores
       WHERE cvalor = 67
         AND catribu = pcmodcom;

      IF v_aux = 0 THEN
         RETURN 9904962;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN 1;
   END f_val_modcom_convenio;

   FUNCTION f_alta_convenio(
      pcempres IN NUMBER,
      pscomconv IN NUMBER,
      ptconvenio IN VARCHAR2,
      pcagente IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      piimporte IN NUMBER)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_comconvenios.f_alta_convenio';
      vpar           VARCHAR2(500)
         := 'e=' || pcempres || 's=' || pscomconv || 't=' || ptconvenio || 'a=' || pcagente
            || 'f=' || pfinivig || 'ff=' || pffinvig || 'i=' || piimporte;
   BEGIN
      vpas := 1;

      INSERT INTO comconvenios
                  (cempres, scomconv, tconvenio, cagente, fanul, falta, cusualt)
           VALUES (pcempres, pscomconv, ptconvenio, pcagente, NULL, f_sysdate, f_user);

      INSERT INTO comconvenios_fec
                  (cempres, scomconv, finivig, ffinvig, importe, cestado, falta, cusualt)
           VALUES (pcempres, pscomconv, pfinivig, pffinvig, piimporte, 0, f_sysdate, f_user);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN 1;
   END f_alta_convenio;

   FUNCTION f_alta_prod_convenio(pcempres IN NUMBER, pscomconv IN NUMBER, psproduc IN NUMBER)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_comconvenios.f_alta_prod_convenio';
      vpar           VARCHAR2(500)
                                  := 'e=' || pcempres || 's=' || pscomconv || 'p=' || psproduc;
   BEGIN
      vpas := 1;

      INSERT INTO comconvenios_prod
                  (cempres, scomconv, sproduc, falta, cusualt)
           VALUES (pcempres, pscomconv, psproduc, f_sysdate, f_user);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN 1;
   END f_alta_prod_convenio;

   FUNCTION f_alta_modcom_convenio(
      pcempres IN NUMBER,
      pscomconv IN NUMBER,
      pcmodcom IN NUMBER,
      pfinivig IN DATE,
      ppcomisi IN NUMBER)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_comconvenios.f_alta_modcom_convenio';
      vpar           VARCHAR2(500)
         := 'e=' || pcempres || 's=' || pscomconv || 'c=' || pcmodcom || 'f=' || pfinivig
            || 'p=' || ppcomisi;
   BEGIN
      vpas := 1;

      BEGIN
         INSERT INTO comconvenios_mod
                     (cempres, scomconv, finivig, cmodcom, pcomisi, falta, cusualt)
              VALUES (pcempres, pscomconv, pfinivig, pcmodcom, ppcomisi, f_sysdate, f_user);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE comconvenios_mod
               SET pcomisi = ppcomisi,
                   fmodifi = f_sysdate,
                   cusumod = f_user
             WHERE cempres = pcempres
               AND scomconv = pscomconv
               AND finivig = pfinivig
               AND cmodcom = pcmodcom;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN 1;
   END f_alta_modcom_convenio;

   FUNCTION f_set_convenio_fec(
      pcempres IN NUMBER,
      pcmodo IN NUMBER,
      pscomconv IN NUMBER,
      ptconvenio IN VARCHAR2,
      pcagente IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      piimporte IN NUMBER,
      pfanul IN DATE,
      pfinivig_out OUT DATE)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_comconvenios.f_set_convenio_fec';
      vpar           VARCHAR2(500)
         := 'e=' || pcempres || 'm=' || pcmodo || 's=' || pscomconv || 't=' || ptconvenio
            || 'a=' || pcagente || 'f=' || pfinivig || 'ff=' || pffinvig || 'i=' || piimporte
            || 'fa=' || pfanul;
      vcount         NUMBER;
   BEGIN
      vpas := 1;

      IF pcmodo = 2 THEN
         IF pfanul IS NULL THEN   -- modificacion
            pfinivig_out := TRUNC(f_sysdate);

            SELECT COUNT(1)
              INTO vcount
              FROM comconvenios_fec
             WHERE cempres = pcempres
               AND scomconv = pscomconv
               AND finivig = pfinivig_out;

            IF vcount > 0 THEN
               UPDATE comconvenios_fec
                  SET importe = piimporte
                WHERE cempres = pcempres
                  AND scomconv = pscomconv
                  AND finivig = pfinivig;
            ELSE
               UPDATE comconvenios_fec
                  SET cestado = 1,
                      ffinvig = pfinivig_out - 1
                WHERE cempres = pcempres
                  AND scomconv = pscomconv
                  AND finivig = pfinivig;

               INSERT INTO comconvenios_fec
                           (cempres, scomconv, finivig, ffinvig, importe, cestado,
                            falta, cusualt)
                    VALUES (pcempres, pscomconv, pfinivig_out, pffinvig, piimporte, 0,
                            f_sysdate, f_user);
            END IF;
         ELSE   -- anulacion
            UPDATE comconvenios_fec
               SET cestado = 1
             WHERE cempres = pcempres
               AND scomconv = pscomconv
               AND finivig = pfinivig;

            UPDATE comconvenios
               SET fanul = pfanul
             WHERE cempres = pcempres
               AND scomconv = pscomconv;
         END IF;
      ELSIF pcmodo = 3 THEN   -- nueva vigencia
         UPDATE comconvenios_fec
            SET cestado = 1
          WHERE cempres = pcempres
            AND scomconv = pscomconv;

         INSERT INTO comconvenios_fec
                     (cempres, scomconv, finivig, ffinvig, importe, cestado, falta, cusualt)
              VALUES (pcempres, pscomconv, pfinivig, pffinvig, piimporte, 0, f_sysdate, f_user);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN 1;
   END f_set_convenio_fec;

   FUNCTION f_sobrecomision_convenio(
      pnrecibo IN NUMBER,
      pcmodcom IN NUMBER,
      pcmodo IN VARCHAR2,
      ptipomovimiento IN NUMBER,
      pcomisi OUT NUMBER)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_comconvenios.f_sobrecomision_convenio';
      vpar           VARCHAR2(500)
         := 'r=' || pnrecibo || 'c=' || pcmodcom || 'p=' || pcomisi || ' m=' || pcmodo
            || ' t=' || ptipomovimiento;
      v_sseguro      recibos.sseguro%TYPE;
      v_cagente      recibos.cagente%TYPE;
      v_nmovimi      recibos.nmovimi%TYPE;
      v_femisio      recibos.femisio%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      v_cusumov      movseguro.cusumov%TYPE;
      v_cdelega      usuarios.cdelega%TYPE;
      v_pcomisi      comconvenios_mod.pcomisi%TYPE;
      v_ctiprec      recibos.ctiprec%TYPE;
      v_frenova      DATE;
      vnumerr        NUMBER;
      ves_migracion  NUMBER;
      v_buscar       VARCHAR2(1) := '0';
      v_hayconvenio  VARCHAR2(1) := '0';
      v_fmovimi      DATE := NULL;
      v_usuario      VARCHAR2(20);
      v_fefectopol   DATE;
   BEGIN
      vpas := 1;

      IF pcmodo IN('P', 'PRIE') THEN   -- Previo Cartera
         SELECT sseguro, cagente, femisio, ctiprec
           INTO v_sseguro, v_cagente, v_femisio, v_ctiprec
           FROM reciboscar
          WHERE nrecibo = pnrecibo;
      ELSE
         SELECT r.sseguro, r.cagente, mr.fmovdia, r.ctiprec
           INTO v_sseguro, v_cagente, v_femisio, v_ctiprec
           FROM recibos r, movrecibo mr
          WHERE r.nrecibo = pnrecibo
            AND mr.nrecibo = r.nrecibo
            AND mr.smovrec = (SELECT MAX(smovrec)
                                FROM movrecibo
                               WHERE nrecibo = pnrecibo);
      END IF;

      IF pcmodo IN('P', 'PRIE')
         AND ptipomovimiento = 22 THEN   -- Previo Cartera
         SELECT cdelega
           INTO v_cagente
           FROM usuarios
          WHERE cusuari = f_user;
      ELSE
         -- Obtener el agente.
         --1.- Si es migración el agente es el de la póliza.
         -- averiguar si se trata de una póliza de migración
         vnumerr := pac_seguros.f_es_migracion(v_sseguro, 'SEG', ves_migracion);

         IF vnumerr = 0
            AND ves_migracion = 1 THEN
            BEGIN
               SELECT sproduc, cagente
                 INTO v_sproduc, v_cagente
                 FROM seguros
                WHERE sseguro = v_sseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  v_cagente := NULL;
            END;
         ELSIF v_ctiprec IN(0, 1, 3) THEN
             --2.- Si es suplemento el agente es el de la fecha del último movimiento de producción o renovación
             --JLV bug 28964/158945 si la fecha renovación es futurible, no devuelve nada porque pasamos f_sysdate,
             -- por tanto recuperar fcaranu de seguros
            /* BEGIN
                SELECT fcaranu
                  INTO v_fefectopol
                  FROM seguros
                 WHERE sseguro = v_sseguro;
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   v_fefectopol := f_sysdate;
             END;

             vnumerr := f_ultrenova(v_sseguro, v_fefectopol, v_frenova, v_nmovimi);

             BEGIN
                SELECT cusumov, fmovimi
                  INTO v_usuario, v_fmovimi
                  FROM movseguro
                 WHERE sseguro = v_sseguro
                   AND nmovimi = v_nmovimi;
             EXCEPTION
                WHEN OTHERS THEN
                   v_usuario := NULL;
             END;*/

            --JLV bug 29362/161926 El agente del primer movimiento es el que prima en toda
            -- vida de la póliza
            BEGIN
               SELECT cusumov, fmovimi
                 INTO v_usuario, v_fmovimi
                 FROM movseguro
                WHERE sseguro = v_sseguro
                  AND nmovimi = (SELECT MIN(nmovimi)
                                   FROM movseguro
                                  WHERE sseguro = v_sseguro);
            EXCEPTION
               WHEN OTHERS THEN
                  v_usuario := NULL;
            END;

            BEGIN
               SELECT cdelega
                 INTO v_cagente
                 FROM usuarios
                WHERE cusuari = v_usuario;

               v_buscar := '1';
            EXCEPTION
               WHEN OTHERS THEN
                  v_cagente := NULL;
            END;
         END IF;
      END IF;

      BEGIN
         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = v_sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            v_sproduc := NULL;
            v_cagente := NULL;
      END;

      BEGIN
         SELECT m.pcomisi
           INTO v_pcomisi
           FROM comconvenios c, comconvenios_prod p, comconvenios_fec f, comconvenios_mod m
          WHERE p.sproduc = v_sproduc
            AND c.cempres = p.cempres
            AND c.scomconv = p.scomconv
            AND c.cagente = v_cagente
            AND(c.fanul IS NULL
                OR c.fanul > f_sysdate)
            AND f.cempres = p.cempres
            AND f.scomconv = p.scomconv
            --JLV bug 29362/161926 sólo si es producción se tiene en cuenta la vigencia
            AND((f.finivig <= v_femisio
                 AND f.ffinvig >= v_femisio)
                OR v_ctiprec <> 0)
            AND m.cempres = f.cempres
            AND m.scomconv = f.scomconv
            AND m.finivig = f.finivig
            AND m.cmodcom = pcmodcom;
      EXCEPTION
         WHEN TOO_MANY_ROWS THEN
            -- 29362/163745 JLV. Si entra en esta casuística, significa que ya le ha sido aplicado convenio.
            SELECT r.sseguro, r.cagente, mr.fmovdia, r.ctiprec
              INTO v_sseguro, v_cagente, v_femisio, v_ctiprec
              FROM recibos r, movrecibo mr
             WHERE r.nrecibo = pnrecibo
               AND mr.nrecibo = r.nrecibo
               AND mr.smovrec = (SELECT MIN(smovrec)
                                   FROM movrecibo
                                  WHERE nrecibo = pnrecibo);

            SELECT m.pcomisi
              INTO v_pcomisi
              FROM comconvenios c, comconvenios_prod p, comconvenios_fec f, comconvenios_mod m
             WHERE p.sproduc = v_sproduc
               AND c.cempres = p.cempres
               AND c.scomconv = p.scomconv
               AND c.cagente = v_cagente
               AND(c.fanul IS NULL
                   OR c.fanul > f_sysdate)
               AND f.cempres = p.cempres
               AND f.scomconv = p.scomconv
               AND f.finivig <= v_femisio
               AND f.ffinvig >= v_femisio
               AND m.cempres = f.cempres
               AND m.scomconv = f.scomconv
               AND m.finivig = f.finivig
               AND m.cmodcom = pcmodcom;
         WHEN NO_DATA_FOUND THEN
            v_pcomisi := 0;
      END;

      pcomisi := v_pcomisi;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' ' || SQLERRM);
         RETURN 1;
   END f_sobrecomision_convenio;

   FUNCTION f_get_next_conv
      RETURN NUMBER IS
      pccodconv_out  NUMBER;
   BEGIN
      SELECT seq_comconvenios_scomconv.NEXTVAL
        INTO pccodconv_out
        FROM DUAL;

      RETURN pccodconv_out;
   END f_get_next_conv;
END pac_comconvenios;

/

  GRANT EXECUTE ON "AXIS"."PAC_COMCONVENIOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_COMCONVENIOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_COMCONVENIOS" TO "PROGRAMADORESCSI";
