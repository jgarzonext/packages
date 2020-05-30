--------------------------------------------------------
--  DDL for Package Body IF_SEGUROS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."IF_SEGUROS" AS
/******************************************************************************
   NOM:       If_Seguros

   REVISIONS:
   Ver        Fecha       Autor  Descripción
   ---------  ----------  -----  ------------------------------------
   1.0        07/07/2009  DCT    0010612: CRE - Error en la generació de pagaments automàtics.
                                 Canviar vista personas por tablas personas y añadir filtro de visión de agente
******************************************************************************/
   PROCEDURE inicialitzar(diain IN DATE) IS
   BEGIN
      diaenv := TRUNC(diain);
   END;

   ----
   ----Funció per calcular l'edat a un dia que se li passa
   FUNCTION edat(dianaix IN DATE, diacalcul IN DATE)
      RETURN NUMBER IS
      retorn         NUMBER;
      aux            NUMBER;
      a1             NUMBER := 0;
      a2             NUMBER := 0;
   BEGIN
      retorn := TO_NUMBER(TO_CHAR(diacalcul, 'YYYY')) - TO_NUMBER(TO_CHAR(dianaix, 'YYYY'));
      a1 := TRUNC(dianaix) - TRUNC(dianaix, 'YYYY') + 1;   ----Dies transcorreguts des de cap d'any
      a2 := TRUNC(diacalcul) - TRUNC(diacalcul, 'YYYY') + 1;   ----Dies transcorreguts des de cap d'any

      IF a1 < a2 THEN
         retorn := retorn - 1;
      ELSE
         retorn := retorn;
      END IF;

      RETURN retorn;
   END;

   FUNCTION importdivisa(moneda IN VARCHAR2, import IN NUMBER)
      RETURN NUMBER IS
      impretorn      NUMBER;
   BEGIN
      IF moneda = 'PTA'
         OR moneda = '???' THEN
         impretorn := ROUND(import * 100);   ----Amb decimals
      ELSIF moneda = 'EUR' THEN
         impretorn := ROUND(import * 100);   ----Amb decimals
      END IF;

      RETURN impretorn;
   END importdivisa;

   PROCEDURE lee AS
      leido          BOOLEAN := FALSE;
      ncert          NUMBER;
      vagente_poliza seguros.cagente%TYPE;
      vcempres       seguros.cempres%TYPE;
   BEGIN
      IF NOT seg_cv%ISOPEN THEN
         IF diaenv IS NULL THEN
            diaenv := TRUNC(SYSDATE);
         END IF;

         OPEN seg_cv(diaenv);
      END IF;

      FETCH seg_cv
       INTO regseg;

      IF seg_cv%NOTFOUND THEN
         leido := FALSE;
         regseg.sseguro := -1;

         CLOSE seg_cv;
      ELSE
         pk_env_comu.traza(pk_autom.trazas, pk_autom.depurar,
                           'SSEGURO = ' || TO_CHAR(regseg.sseguro));
         leido := TRUE;
         -- Inicializar variables
         num_certificado := NULL;
         moneda := '???';
         subproducto := 0;
         cod_oficina := 0;
         aport_periodica := 0;
         aport_inicial := 0;
         faport_periodica := TO_DATE('0001-01-01', 'yyyy-mm-dd');
         tipo_crecimiento := ' ';
         fcrecimiento := TO_DATE('0001-01-01', 'yyyy-mm-dd');
         fultaport := TO_DATE('0001-01-01', 'yyyy-mm-dd');
         pcrec := 0;
         forma_crecimiento := ' ';
         percre := ' ';
         total_recibo_pagado := 0;
         capital_1 := 0;
         capital_2 := 0;
         capital_3 := 0;
         capital_4 := 0;
         capital_5 := 0;
         capital_mort := 0;
         capital_invalidesa := 0;
         capital_vida := 0;
         pm := 0;
         pm_dercons := 0;
         impmens1 := 0;
         cta_prestamo := NULL;

         -- Forma de Pago
         IF pk_autom.mensaje = 'FSE0620' THEN
            IF regseg.cforpag = 'U' THEN
               regseg.cforpag := ' ';
            END IF;
         END IF;

         ----
         ------pk_env_comu.hora (pk_autom.trazas);
         -- Estado
         r := f_estado_poliza(regseg.sseguro, NULL, SYSDATE, regseg.estado, regseg.fanulac);

         ---Sembla que hi ha algun problema per detectar als suspesos.
         IF pk_autom.mensaje = 'FSE0620'
            AND(regseg.estado = 'A'
                OR regseg.estado = 'F') THEN
            BEGIN
               SELECT DECODE(fsusapo, NULL, 'A', 'F'), fsusapo
                 INTO regseg.estado, regmovseg.finisus
                 FROM seguros_aho
                WHERE sseguro = regseg.sseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  regmovseg.finisus := TO_DATE('0001-01-01', 'yyyy-mm-dd');
            END;
         ELSE
            regmovseg.finisus := TO_DATE('0001-01-01', 'yyyy-mm-dd');
         END IF;

         IF regmovseg.finisus IS NULL THEN
            regmovseg.finisus := TO_DATE('0001-01-01', 'yyyy-mm-dd');
         END IF;

         IF regseg.estado = 'F' THEN
            regseg.fanulac := TO_DATE('0001-01-01', 'yyyy-mm-dd');
         END IF;

         ----PASSI A BENEFICIARI
         IF regseg.estado IN('A', 'F') THEN
            ----MIRAR A PRESTAPLAN SI EXISTEIX UN REGISTRE QUE ESTIUGUI SITUACIO 2 O 3
            DECLARE
               quants         NUMBER := 0;
            BEGIN
               SELECT COUNT(*)
                 INTO quants
                 FROM prestaplan
                WHERE sseguro = regseg.sseguro
                  AND cestado IN(2, 3);

               IF quants > 0 THEN
                  regseg.estado := 'B';
               END IF;
            END;
         END IF;

         IF regseg.cramo = 9
            AND regseg.estado = 'C'
            AND regseg.csituac = 0 THEN
            regseg.fanulac := TO_DATE('0001-01-01', 'yyyy-mm-dd');
            regseg.estado := 'A';
         END IF;

         IF regseg.estado IN('A', 'F')
            AND regseg.csituac = 2 THEN
            DECLARE
               vanul          DATE;
            BEGIN
               SELECT fanulac
                 INTO vanul
                 FROM seguros
                WHERE sseguro = regseg.sseguro;

               IF vanul < TRUNC(SYSDATE) THEN
                  regseg.estado := 'C';
                  regseg.fanulac := vanul;
               END IF;
            END;
         END IF;

         ------pk_env_comu.hora (pk_autom.trazas);
         -- Determinar tipo de producto y moneda
         BEGIN
            SELECT clase, DECODE(cmoneda, 2, 'PTA', 3, 'EUR', '???'), tipo_producto
              INTO t_producto, moneda, vtipoproducto
              FROM tipos_producto
             WHERE cramo = regseg.cramo
               AND cmodali = regseg.cmodali
               AND ctipseg = regseg.ctipseg
               AND ccolect = regseg.ccolect;
         EXCEPTION
            WHEN OTHERS THEN
               t_producto := NULL;
               moneda := '???';
         END;

         -- Lectura del numero de certificado
         BEGIN
            SELECT LPAD(polissa_ini, 13, '0')
              INTO num_certificado
              FROM cnvpolizas
             WHERE npoliza = regseg.npoliza;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               num_certificado := '0000000000000';
            WHEN OTHERS THEN
               pk_env_comu.traza(pk_autom.trazas, pk_autom.depurar,
                                 '(CnvPolizas) 1sseguro = ' || TO_CHAR(regseg.sseguro)
                                 || ' - ' || SQLERRM);
         END;

         IF moneda = 'PTA'
            OR moneda = '???' THEN
            -- Determinar código de subproducto
            BEGIN
               SELECT producte_mu, NVL(numpol, '0'), cia
                 INTO subproducto, regseg.npoliza, compania
                 FROM cnvproductos
                WHERE TO_NUMBER(num_certificado) BETWEEN NVL(npolini, 0)
                                                     AND NVL(npolfin, 9999999999999)
                  AND cramo = regseg.cramo
                  AND cmodal = regseg.cmodali
                  AND ctipseg = regseg.ctipseg
                  AND ccolect = regseg.ccolect;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  subproducto := 0;
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'If_Seguros.Lee', 1, 'Error no controlado',
                              '(CnvProductos 1) sseguro = ' || TO_CHAR(regseg.sseguro)
                              || ' - ' || SQLERRM);
            END;
         ELSIF moneda = 'EUR' THEN
            -- Determinar código de subproducto
            BEGIN
               SELECT producte_mu, NVL(numpol, '0'), cia
                 INTO subproducto, regseg.npoliza, compania
                 FROM cnvproductos
                WHERE TO_NUMBER(num_certificado) BETWEEN NVL(npolini, 0)
                                                     AND NVL(npolfin, 9999999999999)
                  AND cramo_e = regseg.cramo
                  AND cmodali_e = regseg.cmodali
                  AND ctipseg_e = regseg.ctipseg
                  AND ccolect_e = regseg.ccolect;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  subproducto := 0;
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'If_Seguros.Lee', 2, 'Error no controlado',
                              '(CnvProductos 1) sseguro = ' || TO_CHAR(regseg.sseguro)
                              || ' - ' || SQLERRM);
            END;
         END IF;

      ----
/**********
      IF subproducto = 91 THEN
         compania := 'G038';
      ELSIF subproducto = 92 THEN
         compania := 'G069';
      ELSE
         compania := 'C569';
      END IF;
***********/
      ----
         IF subproducto IN(3, 4, 5) THEN
            BEGIN
               SELECT f1paren
                 INTO regseg.fvencim
                 FROM seguros_ren
                WHERE sseguro = regseg.sseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;
         END IF;

         -- Datos de Movseguro
         BEGIN
            SELECT fefecto
              INTO regmovseg.fmodifi
              FROM movseguro
             WHERE sseguro = regseg.sseguro
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM movseguro
                               WHERE sseguro = regseg.sseguro
                                 AND cmovseg = 1);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               regmovseg.fmodifi := TO_DATE('0001-01-01', 'yyyy-mm-dd');
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'If_Seguros.Lee', 3, 'Error no controlado',
                           '(MovSeguro) 1sseguro = ' || TO_CHAR(regseg.sseguro) || ' - '
                           || SQLERRM);
         END;

         DECLARE
            vprima_inicial NUMBER;
         BEGIN
            SELECT imovimi
              INTO vprima_inicial
              FROM ctaseguro
             WHERE sseguro = regseg.sseguro
               AND cmovimi IN(1, 4)
               AND fvalmov = (SELECT MIN(fvalmov)
                                FROM ctaseguro
                               WHERE sseguro = regseg.sseguro
                                 AND cmovimi IN(1, 4));

            regmovseg.prima_inicial := importdivisa(moneda, vprima_inicial);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               regmovseg.prima_inicial := 0;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'If_Seguros.Lee', 4, 'Error no controlado',
                           '(CtaSeguro) 1sseguro = ' || TO_CHAR(regseg.sseguro) || ' - '
                           || SQLERRM);
         END;

         ----
         aport_inicial := regmovseg.prima_inicial;

         IF pk_autom.mensaje = 'FSE0620' THEN
            IF regseg.estado = 'A' THEN
               IF regseg.fcarpro IS NULL THEN
                  ----
                  aport_periodica := 0;
                  faport_periodica := TO_DATE('0001-01-01', 'yyyy-mm-dd');
                  regseg.cforpag := ' ';
                  ----
                  tipo_crecimiento := NULL;
                  fcrecimiento := TO_DATE('0001-01-01', 'yyyy-mm-dd');
                  pcrec := 0;
                  percre := NULL;
               ----
               ELSE
                  faport_periodica := regseg.fcarpro;

                  DECLARE
                     vaport_periodica NUMBER;
                  BEGIN
                     IF regseg.ncforpag IS NOT NULL
                        AND regseg.ncforpag <> 0 THEN
                        SELECT iprianu / regseg.ncforpag
                          INTO vaport_periodica
                          FROM garanseg
                         WHERE sseguro = regseg.sseguro
                           AND nriesgo = 1
                           AND cgarant = 48
                           AND ffinefe IS NULL;

                        aport_periodica := importdivisa(moneda, vaport_periodica);
                     END IF;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        BEGIN
                           SELECT itotalr
                             INTO vaport_periodica
                             FROM vdetrecibos
                            WHERE nrecibo = (SELECT MAX(nrecibo)
                                               FROM recibos
                                              WHERE sseguro = regseg.sseguro);

                           aport_periodica := importdivisa(moneda, vaport_periodica);
                        EXCEPTION
                           WHEN OTHERS THEN
                              aport_periodica := 0;
                              faport_periodica := TO_DATE('0001-01-01', 'yyyy-mm-dd');
                        END;
                     WHEN OTHERS THEN
                        aport_periodica := 0;
                        faport_periodica := TO_DATE('0001-01-01', 'yyyy-mm-dd');
                  END;

                  -- Lectura del tipo de crecimiento y %
                  DECLARE
                     iprianu        NUMBER := 0;
                  BEGIN
                     SELECT DECODE(crevali, 1, 'L', 2, 'A', NULL),
                            DECODE(crevali, 1, 100 * irevali / iprianu, 2, prevali, 0)
                       INTO tipo_crecimiento,
                            pcrec
                       FROM garanseg
                      WHERE sseguro = regseg.sseguro
                        AND nriesgo = 1
                        AND cgarant = 48
                        AND ffinefe IS NULL;

                     IF tipo_crecimiento IS NOT NULL THEN
                        percre := 'A';
                        fcrecimiento := regseg.fcaranu;

                        IF tipo_crecimiento = 'L' THEN
                           BEGIN
                              IF pcrec >= 0
                                 AND pcrec < 0.130 THEN
                                 pcrec := 1;
                              ELSIF pcrec >= 0.130
                                    AND pcrec < 0.216 THEN
                                 pcrec := 2;
                              ELSIF pcrec >= 0.216
                                    AND pcrec < 0.260 THEN
                                 pcrec := 3;
                              ELSIF pcrec >= 0.260
                                    AND pcrec < 0.295 THEN
                                 pcrec := 4;
                              ELSE
                                 pcrec := 5;
                              END IF;
                           END;
                        ELSE
                           IF pcrec = 0
                              OR pcrec IS NULL THEN
                              pcrec := 5;
                           END IF;
                        END IF;
                     ELSE
                        percre := NULL;
                        fcrecimiento := TO_DATE('0001-01-01', 'yyyy-mm-dd');
                        pcrec := 0;
                     END IF;
                  ----
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        ---inicialitzar
                        aport_periodica := 0;
                        faport_periodica := TO_DATE('0001-01-01', 'yyyy-mm-dd');
                        tipo_crecimiento := NULL;
                        pcrec := 0;
                        fcrecimiento := TO_DATE('0001-01-01', 'yyyy-mm-dd');
                        percre := NULL;
                  END;
               END IF;
            ELSE
               ----
               aport_periodica := 0;
               faport_periodica := TO_DATE('0001-01-01', 'yyyy-mm-dd');
               regseg.cforpag := ' ';
               ----
               tipo_crecimiento := NULL;
               fcrecimiento := TO_DATE('0001-01-01', 'yyyy-mm-dd');
               pcrec := 0;
               percre := NULL;
            ----
            END IF;

            ----Si està suspès la data d'aportació és nul·la
            IF regseg.estado = 'F' THEN
               faport_periodica := TO_DATE('0001-01-01', 'yyyy-mm-dd');
               regseg.cforpag := ' ';
            END IF;
         END IF;

         IF t_producto = 'RENTAS' THEN
            DECLARE
               vibrure2       NUMBER;
               vibruren       NUMBER;
            BEGIN
               SELECT ibrure2, ibruren
                 INTO vibrure2, vibruren
                 FROM seguros_ren
                WHERE sseguro = regseg.sseguro;

               pm := importdivisa(moneda, vibrure2);
               impmens1 := importdivisa(moneda, vibruren);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  pm := 0;
                  impmens1 := 0;
            END;
         ELSIF t_producto = 'AHORRO'
               OR(t_producto = 'VINVER'
                  AND vtipoproducto = 'PIG') THEN
            ----ESTALVI I PIG CAPITAL AL VENCIMENT ------>
            DECLARE
               vcapalvencim   NUMBER;
            BEGIN
               SELECT icapital
                 INTO vcapalvencim
                 FROM garanseg
                WHERE sseguro = regseg.sseguro
                  AND cgarant = 283
                  AND SYSDATE BETWEEN finiefe AND NVL(ffinefe, TO_DATE('21001231', 'yyyymmdd'));

               pm := importdivisa(moneda, vcapalvencim);
            EXCEPTION
               WHEN OTHERS THEN
                  pm := 0;
            END;
         END IF;

         IF regseg.estado IN('A', 'F', 'B') THEN
            DECLARE
               vpm_dercons    NUMBER;
            BEGIN
               SELECT imovimi
                 INTO vpm_dercons
                 FROM ctaseguro
                WHERE sseguro = regseg.sseguro
                  AND cmovimi = 0
                  AND fvalmov = (SELECT MAX(fvalmov)
                                   FROM ctaseguro
                                  WHERE sseguro = regseg.sseguro
                                    AND cmovimi = 0);

               pm_dercons := importdivisa(moneda, vpm_dercons);
            EXCEPTION
               WHEN OTHERS THEN
                  pm_dercons := 0;
            END;
         ELSE
            pm_dercons := 0;
         END IF;

         -- Total recibo pagado
         DECLARE
            vtotal_recibo_pagado NUMBER;
         BEGIN
            SELECT itotalr
              INTO vtotal_recibo_pagado
              FROM vdetrecibos
             WHERE nrecibo = (SELECT nrecibo
                                FROM recibos
                               WHERE sseguro = regseg.sseguro
                                 AND ctiprec IN(0, 3)
                                 AND fefecto = (SELECT MAX(fefecto)
                                                  FROM recibos
                                                 WHERE sseguro = regseg.sseguro
                                                   AND ctiprec IN(0, 3)));

            total_recibo_pagado := importdivisa(moneda, vtotal_recibo_pagado);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               total_recibo_pagado := 0;
            WHEN OTHERS THEN
               pk_env_comu.traza(pk_autom.trazas, pk_autom.depurar,
                                 '(VdetRecibos) 1sseguro = ' || TO_CHAR(regseg.sseguro)
                                 || ' - ' || SQLERRM);
         END;

         IF pk_autom.mensaje = 'FSE0020' THEN
            -- Capitales
            BEGIN
               SELECT NVL(MAX(DECODE(cgarant, 1, icapital)), 0),
                      NVL(MAX(DECODE(cgarant, 2, icapital)), 0),
                      NVL(MAX(DECODE(cgarant, 283, icapital)), 0)
                 INTO capital_mort,
                      capital_invalidesa,
                      capital_vida
                 FROM garanseg
                WHERE sseguro = regseg.sseguro
                  AND nriesgo = 1
                  AND cgarant IN(1, 2, 283)
                  AND SYSDATE BETWEEN finiefe AND NVL(ffinefe, TO_DATE('21001231', 'yyyymmdd'));
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  capital_mort := 0;
                  capital_invalidesa := 0;
                  capital_vida := 0;
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'If_Seguros.Lee', 5, 'Error no controlado',
                              '(Garanseg) 1sseguro = ' || TO_CHAR(regseg.sseguro) || ' - '
                              || SQLERRM);
            END;

            IF t_producto = 'PFV' THEN
               capital_1 := importdivisa(moneda, capital_vida);
               capital_2 := importdivisa(moneda, capital_mort);
               capital_3 := 0;
            ELSIF t_producto = 'TAR' THEN
               capital_1 := importdivisa(moneda, capital_mort);
               capital_2 := importdivisa(moneda, capital_invalidesa);
               capital_3 := 0;
            ELSIF t_producto = 'ASSP' THEN
               BEGIN
                  SELECT iimppre, ctapres
                    INTO capital_1, cta_prestamo
                    FROM seguros_assp
                   WHERE sseguro = regseg.sseguro;
               EXCEPTION
                  WHEN OTHERS THEN
                     capital_1 := 0;
               END;

               capital_1 := importdivisa(moneda, capital_1);
               capital_2 := importdivisa(moneda, capital_mort);
               capital_3 := importdivisa(moneda, capital_invalidesa);
            ELSIF t_producto = 'VINVER'
                  AND vtipoproducto IN('CV5', 'CV10', 'CV15') THEN
               capital_1 := importdivisa(moneda, capital_vida);

               DECLARE
                  CURSOR saldos IS
                     SELECT   imovimi, fvalmov
                         FROM ctaseguro
                        WHERE sseguro = regseg.sseguro
                          AND cmovimi = 0
                     ORDER BY fvalmov DESC;

                  rsaldos        saldos%ROWTYPE;
               BEGIN
                  OPEN saldos;

                  FETCH saldos
                   INTO rsaldos;

                  capital_2 := importdivisa(moneda, rsaldos.imovimi);

                  CLOSE saldos;
               END;

               pk_env_comu.traza(pk_autom.trazas, pk_autom.depurar,
                                 'Capital 2 = ' || TO_CHAR(capital_2));
               capital_3 := 0;
            END IF;
         END IF;

         -- Oficina
         BEGIN
            SELECT coficin
              INTO cod_oficina
              FROM historicooficinas
             WHERE sseguro = regseg.sseguro
               AND finicio = (SELECT MAX(finicio)
                                FROM historicooficinas
                               WHERE sseguro = regseg.sseguro
                                 AND finicio <= regseg.fefecto);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               cod_oficina := 0;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'If_Seguros.Lee', 6, 'Error no controlado',
                           '(HistOficinas) 1sseguro = ' || TO_CHAR(regseg.sseguro) || ' - '
                           || SQLERRM);
         END;

         IF vtipoproducto IN('PIG', 'PEG')
            OR t_producto = 'RENTAS' THEN
            DECLARE
               CURSOR cass(vsseguro NUMBER) IS
                  SELECT   norden
                      FROM asegurados
                     WHERE sseguro = vsseguro
                  ORDER BY norden ASC;
            BEGIN
               OPEN cass(regseg.sseguro);

               FETCH cass
                INTO norden1;

               FETCH cass
                INTO norden2;

               CLOSE cass;
            END;
         ELSE
            DECLARE
               CURSOR cass(vsseguro NUMBER) IS
                  SELECT   norden
                      FROM asegurados
                     WHERE sseguro = vsseguro
                       AND ffecfin IS NULL
                  ORDER BY norden ASC;
            BEGIN
               OPEN cass(regseg.sseguro);

               FETCH cass
                INTO norden1;

               FETCH cass
                INTO norden2;

               CLOSE cass;
            END;
         END IF;

         IF pk_autom.mensaje = 'FSE0620' THEN
            -- Datos de Persona
            BEGIN
               --Bug10612 - 07/07/2009 - DCT (canviar vista personas)
               --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
               SELECT cagente, cempres
                 INTO vagente_poliza, vcempres
                 FROM seguros
                WHERE sseguro = regseg.sseguro;

               SELECT p.sperson,
                      SUBSTR(d.tapelli1, 0, 40) || ' ' || SUBSTR(d.tapelli2, 0, 20),
                      SUBSTR(d.tnombre, 0, 20),
                      DECODE(p.csexper, 1, 'V', 'M'),
                      p.fnacimi,
                      NVL(p.fjubila, ADD_MONTHS(p.fnacimi, 65 * 12)),
                      0
                 INTO persona
                 FROM per_personas p, per_detper d
                WHERE d.sperson = p.sperson
                  AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres)
                  AND p.sperson = (SELECT sperson
                                     FROM asegurados
                                    WHERE sseguro = regseg.sseguro
                                      AND norden = norden1);

               /*SELECT sperson, tapelli, tnombre,
                      DECODE (csexper, 1, 'V', 'M'), fnacimi,
                      NVL (fjubila, ADD_MONTHS (fnacimi, 65 * 12)), 0
                 INTO persona
                 FROM PERSONAS
                WHERE sperson = (SELECT sperson
                                   FROM ASEGURADOS
                                  WHERE sseguro = regseg.sseguro
                                    AND norden = norden1);*/--FI Bug10612 - 07/07/2009 - DCT (canviar vista personas)
               persona.ejubila := edat(persona.fnacimi, persona.fjubila);
            EXCEPTION
               WHEN OTHERS THEN
                  persona.tapelli := 'Desconocidos';
                  persona.tnombre := 'Desconocido';
                  persona.sperson := -1;
                  persona.csexper := NULL;
            END;

            IF norden2 IS NOT NULL THEN
               -- Datos de Persona2
               BEGIN
                  --Bug10612 - 07/07/2009 - DCT (canviar vista personas)
                  --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
                  SELECT cagente, cempres
                    INTO vagente_poliza, vcempres
                    FROM seguros
                   WHERE sseguro = regseg.sseguro;

                  SELECT p.sperson,
                         SUBSTR(d.tapelli1, 0, 40) || ' ' || SUBSTR(d.tapelli2, 0, 20),
                         SUBSTR(d.tnombre, 0, 20),
                         DECODE(p.csexper, 1, 'V', 'M'),
                         p.fnacimi,
                         NVL(p.fjubila, ADD_MONTHS(p.fnacimi, 65 * 12)),
                         0
                    INTO persona2
                    FROM per_personas p, per_detper d
                   WHERE d.sperson = p.sperson
                     AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres)
                     AND p.sperson = (SELECT sperson
                                        FROM asegurados
                                       WHERE sseguro = regseg.sseguro
                                         AND norden = norden2);

                  /*SELECT sperson, tapelli, tnombre,
                         DECODE (csexper, 1, 'V', 'M'), fnacimi,
                         NVL (fjubila, ADD_MONTHS (fnacimi, 65 * 12)), 0
                    INTO persona2
                    FROM PERSONAS
                   WHERE sperson = (SELECT sperson
                                      FROM ASEGURADOS
                                     WHERE sseguro = regseg.sseguro
                                       AND norden = norden2);*/
                  persona2.ejubila := edat(persona2.fnacimi, persona2.fjubila);
               EXCEPTION
                  WHEN OTHERS THEN
                     persona2.tapelli := 'Desconocidos';
                     persona2.tnombre := 'Desconocido';
                     persona2.sperson := -1;
                     persona2.fnacimi := TO_DATE('0001-01-01', 'yyyy-mm-dd');
                     persona2.csexper := NULL;
               END;
            ELSE
               persona2.tapelli := 'Desconocidos';
               persona2.tnombre := 'Desconocido';
               persona2.sperson := -1;
               persona2.fnacimi := TO_DATE('0001-01-01', 'yyyy-mm-dd');
               persona2.csexper := NULL;
            END IF;
         END IF;

         ----ja estan bé
         ------Mentre no estiguin ben migrats.
         --DECLARE
         --   aux   VARCHAR2 (1);
         --BEGIN
         --   aux := SUBSTR (personaulk.cnifhos, 1, 1);
         --   IF aux = 'D' THEN
         --      personaulk.cnifhos := aux || LPAD ( TRIM ( SUBSTR ( personaulk.cnifhos, 2, 10 ) ), 10, '0' ) || '00';
         --   END IF;
         --END;

         -- Datos de Personas_ulk
         BEGIN
            SELECT sperson,
                   LPAD(TO_CHAR(NVL(cperhos, 0)), 7, '0'),
                   cnifhos
              INTO personaulk
              FROM personas_ulk
             WHERE sperson = (SELECT sperson
                                FROM asegurados
                               WHERE sseguro = regseg.sseguro
                                 AND norden = norden1);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               personaulk.sperson := 0;
               personaulk.cperhos := NULL;
               personaulk.cnifhos := NULL;
            WHEN OTHERS THEN
               personaulk.sperson := 0;
               personaulk.cperhos := NULL;
               personaulk.cnifhos := NULL;
         END;

         -- Datos de Personas_ulk 2
         IF norden2 IS NOT NULL THEN
            BEGIN
               SELECT sperson,
                      LPAD(TO_CHAR(NVL(cperhos, 0)), 7, '0'),
                      cnifhos
                 INTO personaulk2
                 FROM personas_ulk
                WHERE sperson = (SELECT sperson
                                   FROM asegurados
                                  WHERE sseguro = regseg.sseguro
                                    AND norden = norden2);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  personaulk2.sperson := 0;
                  personaulk2.cperhos := NULL;
                  personaulk2.cnifhos := NULL;
               WHEN OTHERS THEN
                  personaulk2.sperson := 0;
                  personaulk2.cperhos := NULL;
                  personaulk2.cnifhos := NULL;
--                  DBMS_OUTPUT.put_line ('(PersonaULK2) 1sseguro = '|| TO_CHAR (regseg.sseguro)|| ' - '|| SQLERRM);
            END;
         ELSE
            personaulk2.sperson := 0;
            personaulk2.cperhos := NULL;
            personaulk2.cnifhos := NULL;
         END IF;

         ----ja estan bé
         ------Mentre no estiguin ben migrats.
         --DECLARE
         --   aux   VARCHAR2 (1);
         --BEGIN
         --   aux := SUBSTR (personaulk2.cnifhos, 1, 1);
         --   IF aux = 'D' THEN
         --      personaulk2.cnifhos :=    aux || LPAD ( TRIM ( SUBSTR ( personaulk2.cnifhos, 2, 10 ) ), 10, '0') || '00';
         --   END IF;
         --END;
         IF t_producto = 'TAR' THEN
            IF regseg.fvencim IS NULL
               OR regseg.fvencim = TO_DATE('0001-01-01', 'yyyy-mm-dd') THEN
               regseg.fvencim := ADD_MONTHS(regseg.fefecto, 12);
            END IF;

            persona.ejubila := 0;
            persona.fjubila := TO_DATE('01/01/0001', 'DD/MM/YYYY');
            persona2.ejubila := 0;
            persona2.fjubila := TO_DATE('01/01/0001', 'DD/MM/YYYY');
         ELSIF t_producto = 'PP'
               OR vtipoproducto = 'PPA' THEN
            IF persona.ejubila = 0 THEN
               persona.ejubila := 65;
               persona.fjubila := ADD_MONTHS(persona.fnacimi, 65 * 12);
            END IF;

            regseg.fvencim := persona.fjubila;
         ELSE
            persona.ejubila := 0;
            persona.fjubila := TO_DATE('01/01/0001', 'DD/MM/YYYY');
            persona2.ejubila := 0;
            persona2.fjubila := TO_DATE('01/01/0001', 'DD/MM/YYYY');
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'If_Seguros.Fin', 1, 'Error no controlado',
                     'sseguro = ' || TO_CHAR(regseg.sseguro) || ' - ' || SQLERRM);
   END lee;

   FUNCTION fin
      RETURN BOOLEAN IS
      fins           BOOLEAN := FALSE;
   BEGIN
      IF regseg.sseguro = -1 THEN
         fins := TRUE;
      END IF;

      RETURN fins;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'If_Seguros.Marca_pila', 1, 'Error no controlado',
                     'sseguro = ' || TO_CHAR(regseg.sseguro) || ' - ' || SQLERRM);
   END fin;

   PROCEDURE marcar_pila IS
   BEGIN
      UPDATE pila_ifases
         SET fecha_envio = SYSDATE
       WHERE fecha_envio IS NULL
         AND ifase = pk_autom.mensaje
         AND TRUNC(fecha) <= diaenv;

      COMMIT;
   END marcar_pila;
END if_seguros;

/

  GRANT EXECUTE ON "AXIS"."IF_SEGUROS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."IF_SEGUROS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."IF_SEGUROS" TO "PROGRAMADORESCSI";
