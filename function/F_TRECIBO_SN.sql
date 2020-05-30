--------------------------------------------------------
--  DDL for Function F_TRECIBO_SN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TRECIBO_SN" (
   pnrecibo IN NUMBER,
   pcidioma IN NUMBER,
   ptlin1 OUT VARCHAR2,
   ptlin2 OUT VARCHAR2,
   ptlin3 OUT VARCHAR2,
   ptlin4 OUT VARCHAR2,
   ptlin5 OUT VARCHAR2,
   ptlin6 OUT VARCHAR2,
   ptlin7 OUT VARCHAR2,
   ptlin8 OUT VARCHAR2)
   RETURN NUMBER AUTHID CURRENT_USER IS
   v_npoliza      NUMBER;
   v_validez      VARCHAR2(40);
   v_producto     VARCHAR2(40);
   v_asegurado    VARCHAR2(40);
   v_fpago        VARCHAR2(20);
   v_agrupacion   NUMBER;
   v_lit1         VARCHAR2(400);
   v_lit2         VARCHAR2(400);
   v_lit3         VARCHAR2(400);
   v_lit4         VARCHAR2(400);
   v_lit5         VARCHAR2(400);
   v_lit6         VARCHAR2(400);
   v_lit7         VARCHAR2(400);
   v_lit8         VARCHAR2(400);
   v_lit9         VARCHAR2(400);
   v_lit10        VARCHAR2(400);
   v_lit11        VARCHAR2(400);
   v_lit12        VARCHAR2(400);
   v_lit13        VARCHAR2(400);
   efecto         DATE;
   pseguro        NUMBER;
   vsproduc       NUMBER;
   saldoant       NUMBER;
   saldoact       NUMBER;
   apor           NUMBER;
   v_fcaranu      DATE;
   cont           NUMBER;
   v_capital      VARCHAR2(100);
   v_itotalr      NUMBER;
   v_itotimp      NUMBER;
   v_itotcon      NUMBER;
   v_prima        VARCHAR2(100);
   v_impuestos    VARCHAR2(100);
   v_consorcio    VARCHAR2(100);
   v_numpol       VARCHAR2(15);
   v_ncertif      NUMBER;
   v_fvencim_rec  DATE;
   v_valpar       NUMBER(1);
   v_retval       NUMBER;

   CURSOR c_garantias(psseguro IN NUMBER, fecha IN DATE) IS
      SELECT   tgarant, icaptot, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi,
               g.cgarant
          FROM garanseg g, garangen gg, seguros s
         WHERE g.sseguro = psseguro
           AND g.sseguro = s.sseguro
           AND g.cgarant = gg.cgarant
           AND gg.cidioma = pcidioma
           AND g.finiefe <= fecha
           AND(g.ffinefe > fecha
               OR g.ffinefe IS NULL)
           AND nriesgo = 1
      ORDER BY g.cgarant;
BEGIN
   IF pnrecibo IS NOT NULL
      AND pcidioma IS NOT NULL THEN
      -- Seleccion de valores:
      BEGIN
         --Bug10612 - 07/07/2009 - DCT (canviar vista personas)
         SELECT s.sproduc, s.sseguro, s.cagrpro, t.ttitulo,
                DECODE(r.cforpag,
                       00, 'Única',
                       01, 'Anual',
                       02, 'Semestral',
                       04, 'Trimestral',
                       12, 'Mensual'),
                s.npoliza, NULL,
                --       Pac_Isqlfor.f_periodo_recibo(pnrecibo),
                SUBSTR(SUBSTR(d.tnombre, 0, 20) || ' ' || SUBSTR(d.tapelli1, 0, 40) || ' ' || SUBSTR(d.tapelli2, 0, 20), 1, 40), r.fefecto,
                s.fcaranu, NVL(v.itotalr, 0), NVL(v.itotimp, 0), NVL(v.itotcon, 0),
                s.ncertif, r.fvencim
           INTO vsproduc, pseguro, v_agrupacion, v_producto,
                v_fpago,
                v_npoliza, v_validez,
                v_asegurado, efecto,
                v_fcaranu, v_itotalr, v_itotimp, v_itotcon,
                v_ncertif, v_fvencim_rec
           FROM titulopro t, seguros s, recibos r, asegurados a, per_personas p, per_detper d, empresas,
                vdetrecibos v
          WHERE s.cramo = t.cramo
            AND s.cmodali = t.cmodali
            AND s.ctipseg = t.ctipseg
            AND s.ccolect = t.ccolect
            AND s.sseguro = r.sseguro
            AND s.sseguro = a.sseguro
            AND a.sperson = p.sperson
            AND empresas.cempres = s.cempres
            AND a.norden = 1   --> Solo sale el primer asegurado
            AND t.cidioma = 2
            AND v.nrecibo = r.nrecibo
            AND r.nrecibo = pnrecibo
            AND d.sperson = p.sperson
            AND d.cagente = ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres);
         /*SELECT s.sproduc, s.sseguro, s.cagrpro, t.ttitulo,
                DECODE(r.cforpag,
                       00, 'Única',
                       01, 'Anual',
                       02, 'Semestral',
                       04, 'Trimestral',
                       12, 'Mensual'),
                s.npoliza, NULL,
                --       Pac_Isqlfor.f_periodo_recibo(pnrecibo),
                SUBSTR(p.tnombre || ' ' || tapelli1 || ' ' || tapelli2, 1, 40), r.fefecto,
                s.fcaranu, NVL(v.itotalr, 0), NVL(v.itotimp, 0), NVL(v.itotcon, 0),
                s.ncertif, r.fvencim
           INTO vsproduc, pseguro, v_agrupacion, v_producto,
                v_fpago,
                v_npoliza, v_validez,
                v_asegurado, efecto,
                v_fcaranu, v_itotalr, v_itotimp, v_itotcon,
                v_ncertif, v_fvencim_rec
           FROM titulopro t, seguros s, recibos r, asegurados a, personas p, empresas,
                vdetrecibos v
          WHERE s.cramo = t.cramo
            AND s.cmodali = t.cmodali
            AND s.ctipseg = t.ctipseg
            AND s.ccolect = t.ccolect
            AND s.sseguro = r.sseguro
            AND s.sseguro = a.sseguro
            AND a.sperson = p.sperson
            AND empresas.cempres = s.cempres
            AND a.norden = 1   --> Solo sale el primer asegurado
            AND t.cidioma = 2
            AND v.nrecibo = r.nrecibo
            AND r.nrecibo = pnrecibo;*/
       --FI Bug10612 - 07/07/2009 - DCT (canviar vista personas)
      EXCEPTION
         WHEN OTHERS THEN
            --DBMS_OUTPUT.put_line('when othres then ' || SQLERRM);
            NULL;
      END;

      -- Composicion de la lineas
      BEGIN
         -- Literales fijos
         v_lit1 := f_axis_literales(102829, pcidioma);   --> nº poliza (102829)
         v_lit2 := f_axis_literales(100864, pcidioma);   --> nº recibo (100864)
         v_lit3 := f_axis_literales(101371, pcidioma);   --> Asegurado (101371)
         v_lit4 := f_axis_literales(102719, pcidioma);   --> Forma de pago (102719)
         v_lit5 := f_axis_literales(100681, pcidioma);   --> Producto (100681)
         v_lit6 := f_axis_literales(112616, pcidioma);   -->CERTIFICADO INDIVIDUAL
         v_lit7 := f_axis_literales(112372, pcidioma);   -->GARANTIAS:
         v_lit8 := f_axis_literales(111796, pcidioma);   -->COBERTURA:
         v_lit9 := f_axis_literales(140773, pcidioma);   -->HASTA
         v_lit10 := f_axis_literales(152341, pcidioma);   -->PRIMA MENSUAL
         v_lit11 := f_axis_literales(109989, pcidioma);   -->IMPUESTOS:
         v_lit12 := f_axis_literales(102707, pcidioma);   -->POLIZA COLECTIVA
         v_lit13 := f_axis_literales(100936, pcidioma);

         -->CONSORCIO:

         --    p_literal2(112475, pcidioma, v_lit6); --> Fecha de efecto (112475)
         --    p_literal2(151338, pcidioma, v_lit7); --> Periodo de cobertura (151338)
         -- Lineas del recibo
         IF v_agrupacion = 11 THEN
            ptlin1 := v_producto;
            saldoant := f_saldo_pp(pseguro,
                                   TO_DATE('31/12/'
                                           || TO_CHAR(ADD_MONTHS(efecto - 1, -12), 'yyyy'),
                                           'dd/mm/yyyy'),
                                   1);

            IF saldoant = -1 THEN
               saldoant := 0;
            END IF;

            ptlin2 := 'DERECHOS CONSOLIDADOS AL 31-12-'
                      || TO_CHAR(ADD_MONTHS(efecto - 1, -12), 'YYYY')
                      || LPAD(TO_CHAR(NVL(saldoant, 0), 'FM999G999G990D00') || ' EUR', 23, ' ');
            apor := pac_tfv.f_aportaciones_anuales_pp(pseguro,
                                                      TO_NUMBER(TO_CHAR(efecto, 'yyyy')),
                                                      efecto);

            IF apor = -1 THEN
               apor := 0;
            END IF;

            ptlin3 := 'APORTACIONES AL ' || TO_CHAR(efecto, 'DD-MM-YYYY')
                      || LPAD(TO_CHAR(NVL(apor, 0), 'FM999G999G990D00') || ' EUR', 32, ' ');
            saldoact := f_saldo_pp(pseguro, efecto - 1, 1);

            IF saldoact = -1 THEN
               saldoact := 0;
            END IF;

            ptlin4 := 'DERECHOS CONSOLIDADOS AL ' || TO_CHAR(efecto - 1, 'DD-MM-YYYY')
                      || LPAD(TO_CHAR(NVL(saldoact, 0), 'FM999G999G990D00') || ' EUR', 23, ' ');
         ELSIF v_agrupacion = 1 THEN
            BEGIN
               SELECT numpol
                 INTO v_numpol
                 FROM cnvproductos c, productos p
                WHERE p.sproduc = vsproduc
                  AND c.cramo = p.cramo
                  AND c.cmodal = p.cmodali
                  AND c.ctipseg = p.ctipseg
                  AND c.ccolect = p.ccolect;
            EXCEPTION
               WHEN OTHERS THEN
                  v_numpol := NULL;
            END;

            ptlin1 := RPAD(UPPER(v_producto), 54, ' ')
                      || RPAD(UPPER(v_lit12) || ': ' || v_numpol, 26, ' ');
            ptlin2 := RPAD(UPPER(v_lit6) || ': ' || v_npoliza || '-' || v_ncertif, 80, ' ');
            ptlin3 := RPAD(UPPER(v_lit7), 40, ' ');
            cont := 0;
            v_prima := LPAD(TO_CHAR(NVL(v_itotalr, 0), 'FM999G999G990D00') || 'EUR',
                            26 - LENGTH(v_lit10) - 1, ' ');
            v_impuestos := LPAD(TO_CHAR(NVL(v_itotimp, 0), 'FM999G999G990D00') || 'EUR',
                                26 - LENGTH(v_lit11), ' ');
            v_consorcio := LPAD(TO_CHAR(NVL(v_itotcon, 0), 'FM999G999G990D00') || 'EUR',
                                26 - LENGTH(v_lit13), ' ');

            FOR gar IN c_garantias(pseguro, efecto) LOOP
               v_retval := f_pargaranpro(gar.cramo, gar.cmodali, gar.ctipseg, gar.ccolect, 0,
                                         gar.cgarant, 'VISIBLERECIBO', v_valpar);
               v_valpar := NVL(v_valpar, 1);

               IF v_valpar = 1 THEN
                  v_capital := LPAD(TO_CHAR(NVL(gar.icaptot, 0), 'FM999G999G990D00') || 'EUR',
                                    35 - LENGTH(gar.tgarant) + 14, ' ');
                  cont := cont + 1;

                  IF cont = 1 THEN
                     ptlin4 := RPAD(' ' || UPPER(gar.tgarant) || ':' || v_capital, 54, ' ')
                               || RPAD(UPPER(v_lit10) || ':' || v_prima, 26, '-');
                  ELSIF cont = 2 THEN
                     ptlin5 := RPAD(' ' || UPPER(gar.tgarant) || ':' || v_capital, 54, ' ')
                               || RPAD(UPPER(v_lit11) || v_impuestos, 26, '-');
                  ELSIF cont = 3 THEN
                     ptlin6 := RPAD(' ' || UPPER(gar.tgarant) || ':' || v_capital, 54, ' ')
                               || RPAD(UPPER(v_lit13) || v_consorcio, 26, '-');
                  END IF;
               END IF;
            END LOOP;

            IF NVL(LENGTH(TRIM(ptlin4)), 0) = 0 THEN
               ptlin4 := LPAD(UPPER(v_lit10) || ':' || v_prima, 80, ' ');
            END IF;

            IF NVL(LENGTH(TRIM(ptlin5)), 0) = 0 THEN
               ptlin5 := LPAD(UPPER(v_lit11) || v_impuestos, 80, ' ');
            END IF;

            IF NVL(LENGTH(TRIM(ptlin6)), 0) = 0 THEN
               IF vsproduc IN(41, 42) THEN
                  ptlin6 := RPAD(UPPER(v_lit8) || ' ' || TO_CHAR(efecto, 'DD-MM-YYYY'), 25,
                                 ' ')
                            || RPAD(UPPER(v_lit9) || ' '
                                    || TO_CHAR(v_fvencim_rec, 'DD-MM-YYYY'),
                                    29, ' ')
                            || RPAD(UPPER(v_lit13) || v_consorcio, 26, '-');
               ELSE
                  ptlin6 := LPAD(UPPER(v_lit13) || v_consorcio, 80, ' ');
               END IF;
            END IF;

            IF vsproduc NOT IN(41, 42) THEN
               ptlin7 := RPAD(UPPER(v_lit8) || ' ' || TO_CHAR(efecto, 'DD-MM-YYYY'), 25, ' ')
                         || RPAD(UPPER(v_lit9) || ' ' || TO_CHAR(v_fvencim_rec, 'DD-MM-YYYY'),
                                 55, ' ');
            END IF;
         ELSE
            ptlin1 := RPAD(v_lit1 || ' ' || v_npoliza, 40, ' ')
                      || RPAD(v_lit2 || ' ' || pnrecibo, 40, ' ');
            ptlin2 := RPAD(v_lit5 || ' ' || v_producto, 40, ' ')
                      || RPAD(v_lit4 || ' ' || v_fpago, 40, ' ');
            ptlin3 := RPAD(v_lit3 || ' ' || v_asegurado, 40, ' ');
            ptlin4 := v_validez;
         END IF;

         BEGIN
            IF vsproduc IN(41, 42) THEN
               SELECT mensaje
                 INTO ptlin7
                 FROM mensarecibos
                WHERE mensarecibos.sproduc = vsproduc
                  AND cidioma = pcidioma
                  AND nlinea = 1;

               SELECT mensaje
                 INTO ptlin8
                 FROM mensarecibos
                WHERE mensarecibos.sproduc = vsproduc
                  AND cidioma = pcidioma
                  AND nlinea = 2;
            ELSE
               SELECT mensaje
                 INTO ptlin8
                 FROM mensarecibos
                WHERE mensarecibos.sproduc = vsproduc
                  AND cidioma = pcidioma
                  AND nlinea = 1;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               ptlin8 := NULL;
         END;

         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            --DBMS_OUTPUT.put_line(SQLERRM);
            RETURN 1;
            NULL;
      END;
   END IF;
END f_trecibo_sn;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_TRECIBO_SN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TRECIBO_SN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TRECIBO_SN" TO "PROGRAMADORESCSI";
