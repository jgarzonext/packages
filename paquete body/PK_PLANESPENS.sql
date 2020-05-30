--------------------------------------------------------
--  DDL for Package Body PK_PLANESPENS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_PLANESPENS" AS
---------------------------------------------------------------------------
   PROCEDURE lee AS
      leido          BOOLEAN := FALSE;
   BEGIN
      IF NOT seg_cv%ISOPEN THEN
         OPEN seg_cv;
      END IF;

      FETCH seg_cv
       INTO regpila;

      IF seg_cv%NOTFOUND THEN
         leido := FALSE;
         regpila.sseguro := -1;

         CLOSE seg_cv;
      ELSE
         leido := TRUE;
         tratamiento;

         UPDATE pila_planes
            SET fecha_envio = f_sysdate
          WHERE sseguro = regpila.sseguro
            AND ID = regpila.ID
            AND id2 = regpila.id2
            AND segmento = regpila.segmento
            AND benef IS NULL;

         UPDATE pila_planes
            SET fecha_envio = f_sysdate
          WHERE sseguro = regpila.sseguro
            AND TO_CHAR(pila_planes.fecha, 'YYYYMMDD') BETWEEN TO_CHAR(fecha_desde, 'YYYYMMDD')
                                                           AND TO_CHAR(fecha_hasta, 'YYYYMMDD')
            AND benef IS NOT NULL;
      END IF;
   -- BUG -21546_108724- 09/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
   EXCEPTION
      WHEN OTHERS THEN
         IF seg_cv%ISOPEN THEN
            CLOSE seg_cv;
         END IF;
   END lee;

-------------------------------------------------------------------------
   PROCEDURE tratamiento IS
      v_cempres      seguros.cempres%TYPE;   --       v_cempres      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   BEGIN
      -- Inicializar variables
      num_certificado := NULL;
      moneda := '???';
      subproducto := 0;
      cod_oficina := 0;
      codconting := NULL;
      fpasben := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      fjub := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      aport_periodica := 0;
      aport_inicial := 0;
      sitpart := NULL;
      faport_periodica := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      tipo_crecimiento := ' ';
      fcrecimiento := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      fultaport := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      pcrec := 0;
      forma_crecimiento := ' ';
      percre := ' ';
      cta_prestamo := NULL;
      resguardo := NULL;
      ipresta := 0;
      clavefondo := 0;
      claveplan := 0;
      idseq1 := 0;
      idseq2 := NULL;
      faltaplan := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      faltagest := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      siglascom := NULL;
      domicilio := NULL;
      numero := NULL;
      emplaza := NULL;
      codpostal := NULL;
      municipio := NULL;
      tipopers := NULL;
      --********* Asignación Alberto *********************************************
      ivalorp := 0;
      nparpla := 0;
      fpago := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      iretenc := 0;
      codcon := NULL;
      tippresta := 0;
      mmonpro := 0;
      ccont1 := NULL;
      ccont2 := NULL;
      ccont3 := NULL;
      tipcap := 0;
      contin := 0;
      fvalmov := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      imovimi := 0;
      cmovimi := NULL;
      ctipapor := NULL;
      conind := NULL;
      codsperson := NULL;
      nporcen := 0;
      faccion := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      finibloq := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      ffinbloq := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      numbloq := 0;
      nparret := 0;
      codbloq := NULL;
      ibloq := 0;
      cbancar := NULL;
      finicio := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      cperiod := 0;
      fprorev := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      prevalo := 0;
      nrevanu := 0;
      ctiprev := NULL;
      cestado := NULL;
      cdivisa := NULL;
      ireducsn := 0;
      via := 0;
      nanos := 0;

--*************************************************************************
--  Datos de seguro
      SELECT sseguro,
             cramo,
             cmodali,
             ctipseg,
             ccolect,
             npoliza,
             fefecto,
             fanulac,
             DECODE(fanulac, NULL, 'A', 'V'),
             NVL(fvencim, TO_DATE('0001-01-01', 'yyyy-mm-dd')),
             DECODE(cforpag, 1, 'A', 2, 'S', 3, 'C', 4, 'T', 6, 'B', 12, 'M', 0, 'U'),
             cbancar
        INTO regseg
        FROM seguros
       WHERE sseguro = regpila.sseguro;

      -- *** Calculamos la moneda del producto
      BEGIN
         SELECT cdivisa
           INTO cdivisa
           FROM productos, seguros
          WHERE seguros.sseguro = regpila.sseguro
            AND seguros.cramo = productos.cramo
            AND seguros.cmodali = productos.cmodali
            AND seguros.ctipseg = productos.ctipseg
            AND seguros.ccolect = productos.ccolect;
      EXCEPTION
         WHEN OTHERS THEN
            cdivisa := NULL;
      END;

      -- Datos de fondo y plan
      BEGIN
         SELECT clapla, planpensiones.ccodpla
           INTO claveplan, PLAN
           FROM proplapen, planpensiones
          WHERE sproduc = (SELECT sproduc
                             FROM productos
                            WHERE cramo = regseg.cramo
                              AND cmodali = regseg.cmodali
                              AND ctipseg = regseg.ctipseg
                              AND ccolect = regseg.ccolect)
            AND proplapen.ccodpla = planpensiones.ccodpla;
      EXCEPTION
         WHEN OTHERS THEN
            claveplan := NULL;
      END;

      BEGIN
         SELECT fp.clafon
           INTO clavefondo
           FROM planpensiones pp, fonpensiones fp
          WHERE pp.ccodfon = fp.ccodfon
            AND pp.ccodpla = PLAN;
      EXCEPTION
         WHEN OTHERS THEN
            clavefondo := NULL;
      END;

      -- Determinar tipo de producto
      BEGIN
         SELECT clase, DECODE(cmoneda, 2, 'PTA', 3, 'EUR', '???')
           INTO t_producto, moneda
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
         SELECT LPAD(polissa_ini, 10, '0')
           INTO num_certificado
           FROM cnvpolizas
          WHERE sseguro = regseg.sseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            num_certificado := '0000000000000';
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'Pk_Planespens.Tratamiento', 1,
                        'Error no controlado',
                        '(CnvPolizas) 1sseguro = ' || TO_CHAR(regseg.sseguro) || ' - '
                        || SQLERRM);
      END;

      idseq1 := 0900000000 + num_certificado;   -- N. de cliente de la Caja
      idseq2 := RPAD(TO_NUMBER(num_certificado), 25, ' ');   -- En principio = a idseq2

      /*
      *  Si hay cambio de participe a beneficiario componer valor de idseq1
      */
      -- Fecha alta gestora
      BEGIN
         SELECT MIN(fantigi)
           INTO faltagest
           FROM trasplainout
          WHERE sseguro = regseg.sseguro
            AND cinout = 1;
      EXCEPTION
         WHEN OTHERS THEN
            faltagest := NULL;
      END;

      IF moneda = 'PTA'
         OR moneda = '???' THEN
         -- Determinar código de subproducto
         BEGIN
            SELECT producte_mu, NVL(numpol, 0)
              INTO subproducto, regseg.npoliza
              FROM cnvproductos
             WHERE TO_NUMBER(num_certificado) BETWEEN NVL(npolini, 0) AND NVL(npolfin,
                                                                              99999999)
               AND cramo = regseg.cramo
               AND cmodal = regseg.cmodali
               AND ctipseg = regseg.ctipseg
               AND ccolect = regseg.ccolect;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               subproducto := 0;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'Pk_Planespens.Tratamiento', 2,
                           'Error no controlado',
                           '(CnvProductos 1) sseguro = ' || TO_CHAR(regseg.sseguro) || ' - '
                           || SQLERRM);
         END;
      ELSIF moneda = 'EUR' THEN
         -- Determinar código de subproducto
         BEGIN
            SELECT producte_mu, NVL(numpol, 0)
              INTO subproducto, regseg.npoliza
              FROM cnvproductos
             WHERE TO_NUMBER(num_certificado) BETWEEN NVL(npolini, 0) AND NVL(npolfin,
                                                                              99999999)
               AND cramo_e = regseg.cramo
               AND cmodali_e = regseg.cmodali
               AND ctipseg_e = regseg.ctipseg
               AND ccolect_e = regseg.ccolect;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               subproducto := 0;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'Pk_Planespens.Tratamiento', 3,
                           'Error no controlado',
                           '(CnvProductos 1) sseguro = ' || TO_CHAR(regseg.sseguro) || ' - '
                           || SQLERRM);
         END;
      END IF;

      IF regseg.estado = 'F' THEN
         regmovseg.finisus := regseg.fanulac;
         regseg.fanulac := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      ELSE
         regmovseg.finisus := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      END IF;

      IF regmovseg.finisus IS NULL THEN
         regmovseg.finisus := TO_DATE('0001-01-01', 'yyyy-mm-dd');
      END IF;

      -- Lectura del tipo de crecimiento y %
      BEGIN
         SELECT DECODE(crevali, 1, 'L', 2, 'A', NULL), NVL(prevali, 0),
                NVL(fpprev, TO_DATE('00010101', 'yyyymmdd')),
                DECODE(percre, 1, 'A', 2, 'S', 3, 'C', 4, 'T', 6, 'B', 12, 'M', 0, 'U')
           INTO tipo_crecimiento, pcrec,
                fcrecimiento,
                percre
           FROM garanseg
          WHERE sseguro = regseg.sseguro
            AND cgarant = 48
            AND f_sysdate BETWEEN finiefe AND NVL(ffinefe, TO_DATE('21001231', 'yyyymmdd'));
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            tipo_crecimiento := NULL;
            pcrec := 0;
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'Pk_Planespens.Tratamiento', 1,
                        'Error no controlado',
                        '(Garanseg prueba) 1sseguro = ' || TO_CHAR(regseg.sseguro) || ' - '
                        || SQLERRM);
      END;

      IF regseg.cforpag = ' ' THEN
         aport_periodica := 0;
         faport_periodica := TO_DATE('0001-01-01', 'yyyy-mm-dd');
         tipo_crecimiento := NULL;
         pcrec := 0;
      ELSE
         BEGIN
            SELECT icapital, finiefe
              INTO aport_periodica, faport_periodica
              FROM garanseg
             WHERE sseguro = regseg.sseguro
               AND cgarant = 48
               AND f_sysdate BETWEEN finiefe AND NVL(ffinefe, TO_DATE('21001231', 'yyyymmdd'));
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT itotalr, f_sysdate
                    INTO aport_periodica, faport_periodica
                    FROM vdetrecibos
                   WHERE nrecibo = (SELECT MAX(nrecibo)
                                      FROM recibos
                                     WHERE sseguro = regseg.sseguro);
               EXCEPTION
                  WHEN OTHERS THEN
                     aport_periodica := 0;
                     faport_periodica := TO_DATE('0001-01-01', 'yyyy-mm-dd');
               END;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'Pk_Planespens.Tratamiento', 1,
                           'Error no controlado', SQLERRM);
         END;
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
            p_tab_error(f_sysdate, f_user, 'Pk_Planespens.Tratamiento', 1,
                        'Error no controlado',
                        '(HistOficinas) 1sseguro = ' || TO_CHAR(regseg.sseguro) || ' - '
                        || SQLERRM);
      END;

      -- Datos de Persona
      -- *** En caso de que el tipo de Segmento sea ( N )
      -- *** la persona a buscar es el campo ID
      -- *** en caso contrario es el asegurado del seguro.
      IF regpila.segmento IN('N', 'D') THEN
         codsperson := regpila.id2;

         -- Situacion del registro ( Alta / Modificacion )
         IF regpila.ID = 1 THEN
            tratreg := regpila.cambio;
         ELSE
            tratreg := 'M';
         END IF;
      ELSIF regpila.segmento = 'B'
            AND regpila.benef IS NOT NULL THEN
         BEGIN
            SELECT sperson
              INTO codsperson
              FROM asegurados
             WHERE sseguro = regseg.sseguro
               AND norden = 1;
         EXCEPTION
            WHEN OTHERS THEN
               codsperson := NULL;
         END;

         -- Situacion del registro ( Alta / Modificacion )
         IF codsperson <> regpila.benef THEN   --Nou beneficiari
            tratreg := 'A';
         ELSE
            tratreg := 'M';
         END IF;

         codsperson := regpila.benef;
      ELSE
         BEGIN
            SELECT sperson
              INTO codsperson
              FROM asegurados
             WHERE sseguro = regseg.sseguro
               AND norden = 1;
         EXCEPTION
            WHEN OTHERS THEN
               codsperson := NULL;
         END;

         -- Situacion del registro ( Alta / Modificacion )
         IF regpila.ID = 1 THEN
            tratreg := regpila.cambio;
         ELSE
            tratreg := 'M';
         END IF;
      END IF;

      -- Situacion del registro ( Alta / Modificacion )
      /**********
      IF REGPILA.ID = 1 THEN
         tratreg := regpila.cambio;
      ELSE
         tratreg := 'M';
      END IF;
      **********/
      BEGIN
         SELECT sperson,
                RTRIM(tapelli),
                RTRIM(tnombre),
                DECODE(csexper, 1, 'V', 'M'),
                nnumnif,
                DECODE(cestciv, 1, 'S', 2, 'C', 3, 'V', 4, 'D', 5, 'E', 6, 'C', 7, 'C', 'S'),
                DECODE(tidenti, 1, '1', 2, '1', 3, '7', 4, '2', 5, '2', 6, '0', '1'),
                fnacimi,
                NVL(fjubila, ADD_MONTHS(fnacimi, 65 * 12))
           INTO persona
           FROM personas
          WHERE sperson = codsperson;
      EXCEPTION
         WHEN OTHERS THEN
            persona.tapelli := '';
            persona.tnombre := '';
            persona.sperson := -1;
      END;

      nom := SUBSTR(persona.tnombre, 1, 20);
      ape := SUBSTR(persona.tapelli, 1, 40);
      -- Partícipe beneficiario
      sitpart := 'A';

      IF regpila.benef IS NOT NULL
         AND regpila.segmento = 'B' THEN
         --  Codi de contingència ha de ser el que toca segons com es paga
         DECLARE
            vccont1        NUMBER(2);
            vccont2        NUMBER(2);
         BEGIN
/*         DECODE(ctipcap,1,'K','R') ||DECODE(ctipren,1,'J'
                                                   ,2,'I'
                                                   ,3,'F'
                                                   ,4,'D'
                                                   ,5,'E','Z')
codconting                                                   */
            SELECT 'B', ctipren, fcreacion, faccion, ctipcap, ctipren
              INTO sitpart, tippresta, fpasben, fjub, vccont1, vccont2
              FROM prestaplan p, benefprestaplan b
             WHERE p.sprestaplan = b.sprestaplan
               AND p.sseguro = regpila.sseguro
               AND b.sperson = regpila.benef;

            IF NVL(vccont1, 1) = 1 THEN
               SELECT 'K' || DECODE(vccont2, 1, 'J', 2, 'I', 3, 'F', 4, 'D', 5, 'E', 'Z')
                 INTO codconting
                 FROM DUAL;
            ELSE
               ccont1 := 'R';

               SELECT 'R'
                      || DECODE(vccont2, 1, 'J', 2, 'I', 3, 'Z'   ---Canvi
                                                               , 4, 'D', 5, 'E', 'Z')
                 INTO codconting
                 FROM DUAL;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         --14/11
         IF tippresta = 3 THEN
            idseq1 := 0800000000 + regpila.benef;
         --idseq1 := 0800000000 + num_certificado; -- N. de cliente de la Caja
         END IF;
      END IF;

      -- Domicilio
      BEGIN
         domicilio := NULL;

         SELECT DECODE(tnomvia, NULL, SUBSTR(UPPER(tdomici), 0, 25), tnomvia), cprovin,
                cpoblac, cpostal, nnumvia   --  canvi format codi postal
           INTO domicilio, provincia,
                poblac, codpostal, via
           FROM direcciones
          WHERE sperson = codsperson
            AND cdomici = (SELECT cdomici
                             FROM riesgos
                            WHERE sseguro = regseg.sseguro
                                                          --and riesgos.cdomici = direcciones.cdomici
                         );

         SELECT SUBSTR(UPPER(tpoblac), 1, 10)
           INTO municipio
           FROM poblaciones
          WHERE cprovin = provincia
            AND cpoblac = poblac;
      EXCEPTION
         WHEN OTHERS THEN
--         DBMS_OUTPUT.PUT_LINE ( sqlerrm || 'muni ' || provincia || '  pob ' || poblac );
         --domicilio  := REGSEG.SSEGURO;
            municipio := 'error';
            provincia := 0;
            poblac := 0;
      END;

      BEGIN
         SELECT tsiglas
           INTO siglascom
           FROM tipos_via
          WHERE csiglas = via;
      EXCEPTION
         WHEN OTHERS THEN
            siglascom := 'CL';
      END;

      -- Datos de Personas_ulk
      BEGIN
         SELECT sperson,
                cperhos,
                cnifhos
           INTO personaulk
           FROM personas_ulk
          WHERE sperson = codsperson;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            personaulk.sperson := 0;
            personaulk.cperhos := 0;
            personaulk.cnifhos := NULL;
      END;

      -- Hijos a efectos de IRPF
      SELECT COUNT(*)
        INTO nhijos
        FROM irpfdescendientes
       WHERE sperson = codsperson;

      --***************************** DATOS DE PRESTACIONES
      IF regpila.segmento = 'R' THEN
         pk_autom.traza(pk_autom.trazas, pk_autom.depurar,
                        'entrada ' || regpila.ID || ' id2 ' || regpila.id2 || ' sseguro '
                        || regseg.sseguro);
--      DBMS_OUTPUT.PUT_LINE ( 'entrada ' || regpila.id || ' id2 ' || regpila.id2 || ' sseguro ' || regseg.sseguro);
         iretenc := 0;
         ccont2 := 'F';

         -- Importe de la prestación
         BEGIN
            IF regpila.benef IS NOT NULL
               AND(regpila.id2 IS NULL
                   OR regpila.ID IS NULL) THEN
               DECLARE
                  vnsinies       prestaplan.nsinies%TYPE;   --                   vnsinies       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
                  vspresta       benefprestaplan.sprestaplan%TYPE;   --                   vspresta       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
                  vnporcen       benefprestaplan.nporcen%TYPE;   --                   vnporcen       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
               BEGIN
                  SELECT b.nsinies, a.sprestaplan, a.nporcen
                    INTO vnsinies, vspresta, vnporcen
                    FROM benefprestaplan a, prestaplan b
                   WHERE a.sperson = regpila.benef
                     AND b.sseguro = regpila.sseguro
                     AND a.sprestaplan = b.sprestaplan;

                   -----
                  -- BUG 11595 - 04/11/2009 - APD - Adaptación al nuevo módulo de siniestros
                  SELECT cempres
                    INTO v_cempres
                    FROM seguros
                   WHERE sseguro = regpila.sseguro;

                  IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
                     SELECT ctaseguro.fvalmov, irpf_prestaciones.iretenc,
                            irpf_prestaciones.iimporte, ctaseguro.nparpla * vnporcen / 100,
                            irpf_prestaciones.ctipcap, prestaplan.ctipren,
                            irpf_prestaciones.ireduc
                       INTO fpago, iretenc,
                            ipresta, nparpla,
                            tipcap, contin,
                            ireducsn
                       FROM irpf_prestaciones, pagosini, ctaseguro, prestaplan
                      WHERE irpf_prestaciones.sidepag = pagosini.sidepag
                        AND pagosini.sidepag = ctaseguro.sidepag
                        AND ctaseguro.sseguro = regpila.sseguro
                        AND prestaplan.sprestaplan = vspresta
                        AND irpf_prestaciones.sprestaplan = prestaplan.sprestaplan
                        AND ctaseguro.nsinies = vnsinies
                        AND pagosini.sperson = regpila.benef;
                  ELSE
                     SELECT ctaseguro.fvalmov, irpf_prestaciones.iretenc,
                            irpf_prestaciones.iimporte, ctaseguro.nparpla * vnporcen / 100,
                            irpf_prestaciones.ctipcap, prestaplan.ctipren,
                            irpf_prestaciones.ireduc
                       INTO fpago, iretenc,
                            ipresta, nparpla,
                            tipcap, contin,
                            ireducsn
                       FROM irpf_prestaciones, sin_tramita_pago, ctaseguro, prestaplan
                      WHERE irpf_prestaciones.sidepag = sin_tramita_pago.sidepag
                        AND sin_tramita_pago.sidepag = ctaseguro.sidepag
                        AND ctaseguro.sseguro = regpila.sseguro
                        AND prestaplan.sprestaplan = vspresta
                        AND irpf_prestaciones.sprestaplan = prestaplan.sprestaplan
                        AND ctaseguro.nsinies = vnsinies
                        AND sin_tramita_pago.sperson = regpila.benef;
                  END IF;
               -- Fin BUG 11595 - 04/11/2009 - APD - Adaptación al nuevo módulo de siniestros
               END;
            ELSE
               IF regpila.id2 = 53 THEN
                  -- BUG 11595 - 04/11/2009 - APD - Adaptación al nuevo módulo de siniestros
                  SELECT cempres
                    INTO v_cempres
                    FROM seguros
                   WHERE sseguro = regseg.sseguro;

                  IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
                     SELECT ctaseguro.fvalmov, irpf_prestaciones.iretenc,
                            irpf_prestaciones.iimporte, ctaseguro.nparpla,
                            irpf_prestaciones.ctipcap, prestaplan.ctipren,
                            irpf_prestaciones.ireduc
                       INTO fpago, iretenc,
                            ipresta, nparpla,
                            tipcap, contin,
                            ireducsn
                       FROM irpf_prestaciones, pagosini, ctaseguro, prestaplan
                      WHERE irpf_prestaciones.sidepag = pagosini.sidepag
                        AND pagosini.sidepag = ctaseguro.sidepag
                        AND ctaseguro.sseguro = regseg.sseguro
                        AND prestaplan.sprestaplan = irpf_prestaciones.sprestaplan
                        AND ctaseguro.nnumlin = regpila.ID;
                  ELSE
                     SELECT ctaseguro.fvalmov, irpf_prestaciones.iretenc,
                            irpf_prestaciones.iimporte, ctaseguro.nparpla,
                            irpf_prestaciones.ctipcap, prestaplan.ctipren,
                            irpf_prestaciones.ireduc
                       INTO fpago, iretenc,
                            ipresta, nparpla,
                            tipcap, contin,
                            ireducsn
                       FROM irpf_prestaciones, sin_tramita_pago, ctaseguro, prestaplan
                      WHERE irpf_prestaciones.sidepag = sin_tramita_pago.sidepag
                        AND sin_tramita_pago.sidepag = ctaseguro.sidepag
                        AND ctaseguro.sseguro = regseg.sseguro
                        AND prestaplan.sprestaplan = irpf_prestaciones.sprestaplan
                        AND ctaseguro.nnumlin = regpila.ID;
                  END IF;
               -- Fin BUG 11595 - 04/11/2009 - APD - Adaptación al nuevo módulo de siniestros
               ELSE
                  SELECT ctaseguro.fvalmov, 0, ctaseguro.imovimi, ctaseguro.nparpla, NULL,
                         NULL
                    INTO fpago, iretenc, ipresta, nparpla, tipcap,
                         contin
                    FROM ctaseguro
                   WHERE ctaseguro.sseguro = regseg.sseguro
                     AND ctaseguro.nnumlin = regpila.ID;
               END IF;
            END IF;

            ----fpago := fvalmov;
            BEGIN
               IF tipcap = 1 THEN
                  SELECT TO_NUMBER(fefecto, 'YYYY') - TO_NUMBER(fpago, 'YYYY')
                    INTO nanos
                    FROM seguros
                   WHERE seguros.sseguro = regseg.sseguro;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  nanos := 0;
            END;

            -- Valor participación a dia de pago
            ivalorp := f_valor_participlan(fpago, regseg.sseguro, mmonpro);

            IF ivalorp = -1 THEN
               ivalorp := 0;
            END IF;

            IF mmonpro = 2 THEN   -- Pesetas
               ipresta := ROUND(NVL(ipresta, 0) / 166.386, 2);
               iretenc := ROUND(NVL(iretenc, 0) / 166.386, 2);
            END IF;

            IF regpila.id2 = 10 THEN
               ipresta := -ipresta;
               iretenc := -iretenc;
               nparpla := -nparpla;
            END IF;

            pres_r := pres_r + NVL(ipresta, 0);
            ret_r := ret_r + NVL(iretenc, 0);

--         DBMS_OUTPUT.PUT_LINE ( 'RETENCION ' || iretenc );
         -- Contingencia ( 1 - capital(K)   2 - renta(R) )
            IF regpila.id2 = 53 THEN
               --   Les prestacions de mort en forma de renda
               -- la contingència ha de ser RZ i no RF
               IF NVL(tipcap, 1) = 1 THEN
                  ccont1 := 'K';

                  SELECT DECODE(contin, 1, 'J', 2, 'I', 3, 'F', 4, 'D', 5, 'E', 'Z')
                    INTO ccont2
                    FROM DUAL;
               ELSE
                  ccont1 := 'R';

                  SELECT DECODE(contin, 1, 'J', 2, 'I', 3, 'Z'   ---Canvi
                                                              , 4, 'D', 5, 'E', 'Z')
                    INTO ccont2
                    FROM DUAL;
               END IF;

               IF ccont1 || ccont2 = 'KF'
                  OR ccont1 || ccont2 = 'RZ' THEN
                  -- BUG 11595 - 04/11/2009 - APD - Adaptación al nuevo módulo de siniestros
                  SELECT cempres
                    INTO v_cempres
                    FROM seguros
                   WHERE sseguro = regseg.sseguro;

                  IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
                     SELECT 0800000000 + pagosini.sperson
                       INTO idseq1
                       FROM ctaseguro, pagosini
                      WHERE sseguro = regseg.sseguro
                        AND nnumlin = regpila.ID
                        AND cmovimi = regpila.id2
                        AND ctaseguro.sidepag = pagosini.sidepag;
                  ELSE
                     SELECT 0800000000 + sin_tramita_pago.sperson
                       INTO idseq1
                       FROM ctaseguro, sin_tramita_pago
                      WHERE sseguro = regseg.sseguro
                        AND nnumlin = regpila.ID
                        AND cmovimi = regpila.id2
                        AND ctaseguro.sidepag = sin_tramita_pago.sidepag;
                  END IF;
               -- Fin BUG 11595 - 04/11/2009 - APD - Adaptación al nuevo módulo de siniestros
               END IF;
            ELSIF regpila.id2 = 49 THEN
               ccont1 := 'V';
               ccont2 := ' ';
            ELSE
               ccont1 := 'T';
               ccont2 := NULL;
            END IF;

            ccont3 := NULL;
         EXCEPTION
            WHEN OTHERS THEN
               pk_autom.traza(pk_autom.trazas, pk_autom.depurar, SQLERRM);
               NULL;
         END;
      END IF;

      --***************************** DATOS DE APORTACIONES
      IF regpila.segmento IN('S') THEN
         BEGIN
            IF regpila.benef IS NOT NULL
               AND regpila.ID IS NULL THEN
               DECLARE
                  vnsinies       prestaplan.nsinies%TYPE;   --                   vnsinies       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
                  vspresta       benefprestaplan.sprestaplan%TYPE;   --                   vspresta       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
                  vnporcen       benefprestaplan.nporcen%TYPE;   --                   vnporcen       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
               BEGIN
                  SELECT b.nsinies, a.sprestaplan, a.nporcen
                    INTO vnsinies, vspresta, vnporcen
                    FROM benefprestaplan a, prestaplan b
                   WHERE a.sperson = regpila.benef
                     AND b.sseguro = regpila.sseguro
                     AND a.sprestaplan = b.sprestaplan;

                  -----
                  -- BUG 11595 - 04/11/2009 - APD - Adaptación al nuevo módulo de siniestros
                  SELECT cempres
                    INTO v_cempres
                    FROM seguros
                   WHERE sseguro = regpila.sseguro;

                  IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
                     SELECT ctaseguro.fvalmov, ctaseguro.imovimi, ctaseguro.nparpla,
                            ctaseguro.cmovimi
                       INTO fvalmov, imovimi, nparpla,
                            cmovimi
                       FROM ctaseguro, pagosini
                      WHERE ctaseguro.sseguro = regpila.sseguro
                        AND ctaseguro.nsinies = pagosini.nsinies
                        AND ctaseguro.sidepag = pagosini.sidepag
                        AND pagosini.nsinies = vnsinies
                        AND pagosini.sperson = regpila.benef;
                  ELSE
                     SELECT ctaseguro.fvalmov, ctaseguro.imovimi, ctaseguro.nparpla,
                            ctaseguro.cmovimi
                       INTO fvalmov, imovimi, nparpla,
                            cmovimi
                       FROM ctaseguro, sin_tramita_pago
                      WHERE ctaseguro.sseguro = regpila.sseguro
                        AND ctaseguro.nsinies = sin_tramita_pago.nsinies
                        AND ctaseguro.sidepag = sin_tramita_pago.sidepag
                        AND sin_tramita_pago.nsinies = vnsinies
                        AND sin_tramita_pago.sperson = regpila.benef;
                  END IF;
               -- Fin BUG 11595 - 04/11/2009 - APD - Adaptación al nuevo módulo de siniestros
               END;
            ELSE
               SELECT ctaseguro.fvalmov, ctaseguro.imovimi, ctaseguro.nparpla,
                      ctaseguro.cmovimi
                 INTO fvalmov, imovimi, nparpla,
                      cmovimi
                 FROM ctaseguro
                WHERE ctaseguro.sseguro = regseg.sseguro
                  AND ctaseguro.nnumlin = regpila.ID;
            END IF;

            fpago := fvalmov;
            -- Valor participación a dia de pago
            ivalorp := f_valor_participlan(fvalmov, regseg.sseguro, mmonpro);

            IF ivalorp = -1 THEN
               ivalorp := 0;
            END IF;

            IF mmonpro = 2 THEN   -- Pesetas
               imovimi := ROUND(NVL(imovimi, 0) / 166.386, 2);
            END IF;

            --*** En caso de anulación los importes son en negativo
            IF cmovimi IN(51) THEN
               resguardo := 9999999;
            ELSE
               resguardo := NULL;
            END IF;

            bruto_s := bruto_s + NVL(imovimi, 0);
            -- Código del movimiento Contingencia
            --   En les anul·lacions d'aportacions no han de venir contingencies
            -- En les anul·lacions només s'ha d'enviar codi d'extraordinària en les d'extra
            -- Suposem que id2 és igual a cmovimi
            ctipapor := NULL;

            IF regpila.id2 = 8 THEN
               ccont1 := 'T';
            ELSE
               ccont1 := NULL;
            END IF;

            ccont2 := NULL;
            ccont3 := NULL;

            IF regpila.id2 = 1 THEN
               ctipapor := 'E';
            ELSIF regpila.id2 = 51 THEN
               DECLARE
                  vctiprec       recibos.ctiprec%TYPE;   --                   vctiprec       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
                  vimovimi       ctaseguro.imovimi%TYPE;   --                   vimovimi       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
                  vfvalmov       ctaseguro.fvalmov%TYPE;   --                   vfvalmov       DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
                  vcmovimi       ctaseguro.cmovimi%TYPE;   --                   vcmovimi       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
               BEGIN
                  SELECT ctiprec
                    INTO vctiprec
                    FROM recibos
                   WHERE nrecibo = (SELECT nrecibo
                                      FROM ctaseguro
                                     WHERE sseguro = regpila.sseguro
                                       AND nnumlin = regpila.ID);

                  IF vctiprec IN(0, 4) THEN
                     ctipapor := 'E';
                  ELSIF vctiprec = 3 THEN
                     ctipapor := ' ';
                  ELSIF vctiprec = 9 THEN
                     SELECT imovimi, fvalmov
                       INTO vimovimi, vfvalmov
                       FROM ctaseguro
                      WHERE sseguro = regpila.sseguro
                        AND nnumlin = regpila.ID;

                     SELECT cmovimi
                       INTO vcmovimi
                       FROM ctaseguro
                      WHERE sseguro = regpila.sseguro
                        AND TRUNC(fvalmov) = vfvalmov
                        AND cmovimi IN(1, 2)
                        AND cmovanu = 1
                        AND imovimi = vimovimi;

                     IF vcmovimi = 1 THEN
                        ctipapor := 'E';
                     ELSE
                        ctipapor := ' ';
                     END IF;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     ctipapor := ' ';
               END;
            -------ctipapor := 'E';
            ELSE
               ctipapor := ' ';
            END IF;

            IF regpila.id2 = 8 THEN
               BEGIN
                  SELECT 'I'
                    INTO conind
                    FROM trasplainout, seguros
                   WHERE trasplainout.sseguro = regpila.sseguro
                     AND nnumlin = regpila.ID
                     AND seguros.npoliza = TO_NUMBER(trasplainout.tpolext);
               EXCEPTION
                  WHEN OTHERS THEN
                     --DBMS_OUTPUT.PUT_LINE ( SQLERRM || 'ERR ' || REGPILA.ID );
                     NULL;
               END;
            END IF;

            /****************
            IF cmovimi IN ( 1,51 )  THEN
               ccont1 := 'R';
               ccont2 := 'Z';
            ELSIF cmovimi IN ( 2 ) THEN
               ccont1 := 'K';
               ccont2 := 'Z';
            ELSIF cmovimi IN ( 8 ) THEN
               ccont1 := 'T';
            END IF;
            -- Si es una aportación no enviamos contingencias
            IF regpila.id2 IN ( 1,2 ) THEN
               ccont1 := NULL;
               ccont2 := NULL;
               ccont3 := NULL;
            END IF;
            IF ccont1 IN ( NULL,' ','','R','K') THEN
                ctipapor := 'E';
            END IF;
            IF regpila.id2 = 1 THEN
                ctipapor := 'E';
            ELSIF regpila.id2 = 8  THEN
                BEGIN
                   SELECT 'I' INTO CONIND
                   FROM TRASPLAINOUT , SEGUROS
                   WHERE TRASPLAINOUT.SSEGURO = regpila.sseguro
                   and nnumlin = regpila.id
                   AND SEGUROS.NPOLIZA = TO_NUMBER(TRASPLAINOUT.TPOLEXT);
                EXCEPTION
                   WHEN OTHERS THEN
                      --DBMS_OUTPUT.PUT_LINE ( SQLERRM || 'ERR ' || REGPILA.ID );
                      NULL;
                 END;
                 ctipapor := '';
            ELSIF regpila.id2 = 2 THEN
               ctipapor := ' ';
            END IF;
            ***************/
            ccont3 := NULL;
--         DBMS_OUTPUT.PUT_LINE('con' || fvalmov || 'sseguro = '|| TO_CHAR(Regseg.sseguro)||' - pase2');
         EXCEPTION
            WHEN OTHERS THEN
               imovimi := 0;
         END;
      END IF;

      IF regpila.segmento IN('R', 'S')
         AND regpila.benef IS NOT NULL THEN
         ccont1 := 'T';
         ccont2 := 'B';
         --IF REGPILA.SEGMENTO = 'S' THEN

         --  NOTA: Esta linea que coje el regpila.benef
         -- en realidad en el campo benef esta el sperson del muerto
         -- y no del beneficiario.
         idseq1 := 0800000000 + regpila.benef;

         IF regpila.segmento = 'R' THEN
            SELECT nparti
              INTO nparpla
              FROM prestaplan
             WHERE prestaplan.sseguro = regseg.sseguro
               AND sperson = regpila.benef;
         ELSE   -- rEGISTRO 'S'
            SELECT benefprestaplan.nparpla
              INTO nparpla
              FROM benefprestaplan, prestaplan
             WHERE benefprestaplan.sperson = regpila.benef
               AND prestaplan.sseguro = regseg.sseguro
               AND prestaplan.sprestaplan = benefprestaplan.sprestaplan;
         END IF;

         ----END IF;
         BEGIN
            /********14/11 Sobra
            SELECT fcreacion , b.nparpla
              INTO fvalmov,nparpla
              FROM prestaplan p, benefprestaplan b
             WHERE p.sprestaplan = b.sprestaplan
               AND p.sseguro = regpila.sseguro
               AND b.sperson = regpila.benef;
            fpago := fvalmov;
            ivalorp := F_Valor_Participlan(fvalmov,Regseg.sseguro,mmonpro);
            IF ivalorp = -1 THEN
               ivalorp := 0;
            END IF;
            *****/
            NULL;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      END IF;

      --***************************** DATOS DE POTENCIALES BENEFICIARIOS
      IF regpila.segmento = 'N' THEN
         BEGIN
            SELECT faccion
              INTO faccion
              FROM prestaplan
             WHERE sprestaplan = regpila.ID;

            SELECT nporcen
              INTO nporcen
              FROM benefprestaplan
             WHERE sprestaplan = regpila.ID
               AND sperson = codsperson;
         EXCEPTION
            WHEN OTHERS THEN
               faccion := NULL;
               nporcen := 0;
         END;
      END IF;

      --***************************** BLOQUEOS / INMOVILIZACIONES
      --*** En el caso de que ID2 sea 1 se trata de un bloqueo de póliza
      --*** En el caso de que ID2 sea 2 se trata de un fin de bloqueo de póliza
      --*** en caso de que ID2 sea 3 se trata de un bloqueo de participaciones
      --*** en caso de que ID2 sea 4 se trata de un fin de bloqueo de participaciones
      BEGIN
         IF regpila.segmento = 'M'
            AND regpila.id2 = 1 THEN
            SELECT finicio, NULL, 0, iimporte
              INTO finibloq, ffinbloq, nparret, ibloq
              FROM bloqueoseg
             WHERE sseguro = regseg.sseguro
               AND nbloqueo = regpila.ID;

            codbloq := 'B';
         ELSIF regpila.segmento = 'M'
               AND regpila.id2 = 2 THEN
            SELECT NULL, ffinal, 0, iimporte
              INTO finibloq, ffinbloq, nparret, ibloq
              FROM bloqueoseg
             WHERE sseguro = regseg.sseguro
               AND nbloqueo = regpila.ID;

            codbloq := 'A';
         ELSIF regpila.segmento = 'M'
               AND regpila.id2 = 3 THEN
            SELECT faccion, NULL, nparret, 0
              INTO finibloq, ffinbloq, nparret, ibloq
              FROM prestaplan
             WHERE sprestaplan = regpila.ID;

            codbloq := 'B';
         ELSIF regpila.segmento = 'M'
               AND regpila.id2 = 4 THEN
            SELECT NULL, faccion, nparret, 0
              INTO finibloq, ffinbloq, nparret, ibloq
              FROM prestaplan
             WHERE sprestaplan = regpila.ID;

            codbloq := 'A';
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            finibloq := NULL;
            ffinbloq := NULL;
            nparret := 0;
      END;

      --***************************** DATOS ECONOMICOS DE PARTÍCIPES
      --*** El Id1 es el prestaplan el Id2 es la persona y el Id3 el tipo de capital
      IF regpila.segmento = 'D' THEN
         BEGIN
            SELECT finicio, cbancar, importe, fprorev, prevalo,
                   DECODE(cperiod, 12, 30, 6, 60, 4, 90, 2, 180, 1, 360, 025),
                   DECODE(nrevanu, 1, 'A', 2, 'B', 3, 'T', NULL),
                   DECODE(ctiprev, 1, 'C', 2, 'L', NULL)
              INTO finicio, cbancar, ipresta, fprorev, prevalo,
                   cperiod,
                   nrevanu,
                   ctiprev
              FROM planbenefpresta
             WHERE sprestaplan = regpila.ID
               AND sperson = codsperson
               AND ctipcap = regpila.id3;

            cestado := regpila.estado;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      END IF;

      ----2/1/03. Canvis provisionals per als plans de promoció conjunta
      IF PLAN = 9887 THEN   ----Si es un pla de previsó conjunta
         /*****
         IF RegPila.segmento = 'D' THEN
            clau_promotor := '0000';
            apor_promotor := imovimi;
         ELSIF RegPila.segmento = 'S' THEN
         ********/
         IF regpila.segmento = 'S' THEN
            ccodapor := 'P';
         END IF;
      ELSE
         IF regpila.segmento = 'S' THEN
            ccodapor := ' ';
         END IF;
      END IF;

      --******* Registro total de contadores
      IF regpila.segmento = 'B' THEN
         total_b := total_b + 1;
      ELSIF regpila.segmento = 'D' THEN
         total_d := total_d + 1;
      ELSIF regpila.segmento = 'M' THEN
         total_m := total_m + 1;
      ELSIF regpila.segmento = 'N' THEN
         total_n := total_n + 1;
      ELSIF regpila.segmento = 'R' THEN
         total_r := total_r + 1;
      ELSIF regpila.segmento = 'S' THEN
         total_s := total_s + 1;
      END IF;
--*******************************************************************************
   EXCEPTION
      WHEN OTHERS THEN
         pk_autom.traza(pk_autom.trazas, pk_autom.depurar,
                        'sseguro = ' || TO_CHAR(regseg.sseguro) || ' - ' || SQLERRM);

--      DBMS_OUTPUT.PUT_LINE('sseguro = '|| TO_CHAR(Regseg.sseguro)||' - '||SQLERRM);
         IF regpila.segmento = 'B' THEN
            total_b := total_b + 1;
         ELSIF regpila.segmento = 'D' THEN
            total_d := total_d + 1;
         ELSIF regpila.segmento = 'M' THEN
            total_m := total_m + 1;
         ELSIF regpila.segmento = 'N' THEN
            total_n := total_n + 1;
         ELSIF regpila.segmento = 'R' THEN
            total_r := total_r + 1;
         ELSIF regpila.segmento = 'S' THEN
            total_s := total_s + 1;
         END IF;
   END tratamiento;

---------------------------------------------------------------------------
   FUNCTION fin
      RETURN BOOLEAN IS
      fins           BOOLEAN := FALSE;
   BEGIN
      IF regpila.sseguro = -1 THEN
         fins := TRUE;
      END IF;

      RETURN fins;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pk_Planespens.Fin', 1, 'Error no controlado',
                     'sseguro = ' || TO_CHAR(regseg.sseguro) || ' - ' || SQLERRM);
   END fin;

---------------------------------------------------------------------------
   FUNCTION datpartic
      RETURN BOOLEAN IS
      fins           BOOLEAN := FALSE;
   BEGIN
      IF regpila.segmento = 'B' THEN
         fins := TRUE;
      END IF;

      RETURN fins;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pk_Planespens.Datpartic', 1, 'Error no controlado',
                     'sseguro = ' || TO_CHAR(regseg.sseguro) || ' - ' || SQLERRM);
   END datpartic;

---------------------------------------------------------------------------
   FUNCTION datepartic
      RETURN BOOLEAN IS
      fins           BOOLEAN := FALSE;
   BEGIN
/*   IF RegPila.segmento = 'D'  AND agrupacion1 IN ( 20,9020)
                             AND agrupacion2 IN ( 20,9020) THEN*/
      IF regpila.segmento = 'D' THEN
         fins := TRUE;
      END IF;

      RETURN fins;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pk_Planespens.Datepartic', 1, 'Error no controlado',
                     'sseguro = ' || TO_CHAR(regseg.sseguro) || ' - ' || SQLERRM);
   END datepartic;

---------------------------------------------------------------------------
   FUNCTION datanula
      RETURN BOOLEAN IS
      fins           BOOLEAN := FALSE;
   BEGIN
      IF regpila.segmento = 'J' THEN
/*    AND agrupacion1 NOT IN ( 20,9020)
                             AND agrupacion2 NOT IN ( 20,9020) THEN
*/
         fins := TRUE;
      END IF;

      RETURN fins;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pk_Planespens.Datanula', 1, 'Error no controlado',
                     'sseguro = ' || TO_CHAR(regseg.sseguro) || ' - ' || SQLERRM);
   END datanula;

---------------------------------------------------------------------------
   FUNCTION bloqueos
      RETURN BOOLEAN IS
      fins           BOOLEAN := FALSE;
   BEGIN
      IF regpila.segmento = 'M' THEN
/*
    AND agrupacion1 NOT IN ( 20,9020)
                             AND agrupacion2 NOT IN ( 20,9020) THEN
*/
         fins := TRUE;
      END IF;

      RETURN fins;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pk_Planespens.Bloqueos', 1, 'Error no controlado',
                     'sseguro = ' || TO_CHAR(regseg.sseguro) || ' - ' || SQLERRM);
   END bloqueos;

---------------------------------------------------------------------------
   FUNCTION datbenef
      RETURN BOOLEAN IS
      fins           BOOLEAN := FALSE;
   BEGIN
      IF regpila.segmento = 'N' THEN
         fins := TRUE;
      END IF;

      RETURN fins;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pk_Planespens.Datbenef', 1, 'Error no controlado',
                     'sseguro = ' || TO_CHAR(regseg.sseguro) || ' - ' || SQLERRM);
   END datbenef;

---------------------------------------------------------------------------
   FUNCTION datprest
      RETURN BOOLEAN IS
      fins           BOOLEAN := FALSE;
   BEGIN
      IF regpila.segmento = 'R' THEN
/*   AND agrupacion1 IN ( 20,9020)
                             AND agrupacion2 IN ( 20,9020) THEN
*******/
         fins := TRUE;
      END IF;

      RETURN fins;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pk_Planespens.Datprest', 1, 'Error no controlado',
                     'sseguro = ' || TO_CHAR(regseg.sseguro) || ' - ' || SQLERRM);
   END datprest;

---------------------------------------------------------------------------
   FUNCTION dataport
      RETURN BOOLEAN IS
      fins           BOOLEAN := FALSE;
   BEGIN
      IF regpila.segmento = 'S' THEN
/*   AND agrupacion1 IN ( 20,9020)
                             AND agrupacion2 IN ( 20,9020) THEN
*****/
         fins := TRUE;
      END IF;

      IF regpila.segmento = 'S'
         AND regpila.id2 IN(1, 2) THEN
         fins := TRUE;
      END IF;

      RETURN fins;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pk_Planespens.Dataport', 1, 'Error no controlado',
                     'sseguro = ' || TO_CHAR(regseg.sseguro) || ' - ' || SQLERRM);
   END dataport;

---------------------------------------------------------------------------
   PROCEDURE marcar_pila IS
   BEGIN
      --UPDATE pila_planes SET
      --  fecha_envio = f_sysdate
      -- WHERE fecha_envio IS NULL
      -- AND ID
      -- and sseguro = ( select sseguro from seguros, productos, proplapen
      --                 where seguros.sseguro = pila_planes.sseguro
      --                 and seguros.cramo = productos.cramo
      --                 AND seguros.cmodali = productos.cmodali
      --                 AND seguros.ctipseg = productos.ctipseg
      --                 AND seguros.ccolect = productos.ccolect
      --                 AND proplapen.sproduc = productos.sproduc
      --                 AND proplapen.ccodpla IN ( AGRUPACION1, AGRUPACION2 ) ) ;
      COMMIT;
   END marcar_pila;
---------------------------------------------------------------------------
END pk_planespens;

/

  GRANT EXECUTE ON "AXIS"."PK_PLANESPENS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_PLANESPENS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_PLANESPENS" TO "PROGRAMADORESCSI";
