--------------------------------------------------------
--  DDL for Package Body PAC_CIERREFISCAL_PP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CIERREFISCAL_PP" IS
/******************************************************************************
   NOMBRE:     Pac_Cierrefiscal_Pp
   PROPÓSITO:  Package que contiene la función para realizar el cierre fiscal de P.Pensiones

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        20/12/2005   MCA                1.Creación Package
   2.0        09/07/2009   DCT                2. 0010612: CRE - Error en la generació de pagaments automàtics.
                                              Canviar vista personas por tablas personas y añadir filtro de visión de agente
   3.0        02/11/2009   APD                3. Bug 11595: CEM - Siniestros. Adaptación al nuevo módulo de siniestros
   4.0        27/09/2010  RSC                 4. Bug 15702 - Models Fiscals: 347
******************************************************************************/
   FUNCTION cierre_pp(
      pany IN VARCHAR2,
      pempres IN NUMBER,
      psfiscab IN NUMBER,
      pfperfin IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      -- RSC 18/04/2008
      -- Añado el cagrpro = 11 si no estaremos cogiendo las aportaciones de todos
      -- los productos
      CURSOR aportaciones IS
         SELECT   c.sseguro, s.cramo, s.cmodali, s.ctipseg, s.ccolect, c.nrecibo,
                  TRUNC(c.fvalmov) fvalmov, r.sperson
             FROM ctaseguro c, seguros s, riesgos r
            WHERE s.sseguro = c.sseguro
              AND s.sseguro = r.sseguro
              AND c.imovimi > 0
              AND c.cmovimi IN(1, 2)
              AND c.cmovanu = 0
              AND TO_CHAR(c.fvalmov, 'YYYY') = pany
              AND TRUNC(c.fvalmov) <=
                    NVL(pfperfin, c.fvalmov)   -- Bug 15702 - RSC - 27/09/2010 - Models Fiscals: 347
              AND s.cempres = pempres
              AND s.cagrpro = 11
         ORDER BY c.sseguro;

      CURSOR prestaciones IS
         -- BUG 11595 - 04/11/2009 - APD - Adaptación al nuevo módulo de siniestros
         SELECT   s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro, p.sperson,
                  TRUNC(i.fpago) fpago, i.sidepag, i.iretenc, i.ireduc, i.iimporte
             FROM irpf_prestaciones i, seguros s, siniestros si, pagosini p
            WHERE s.sseguro = si.sseguro
              AND si.nsinies = p.nsinies
              AND p.sidepag = i.sidepag
              AND TO_CHAR(i.fpago, 'yyyy') = pany
              AND TRUNC(i.fpago) <=
                    NVL(pfperfin, i.fpago)   -- Bug 15702 - RSC - 27/09/2010 - Models Fiscals: 347
              AND s.cempres = pempres
              AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 0
         UNION
         SELECT   s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro, p.sperson,
                  TRUNC(i.fpago) fpago, i.sidepag, i.iretenc, i.ireduc, i.iimporte
             FROM irpf_prestaciones i, seguros s, sin_siniestro si, sin_tramitacion t,
                  sin_tramita_pago p
            WHERE s.sseguro = si.sseguro
              AND si.nsinies = t.nsinies
              AND t.nsinies = p.nsinies
              AND t.ntramit = t.ntramit
              AND p.sidepag = i.sidepag
              AND TO_CHAR(i.fpago, 'yyyy') = pany
              AND TRUNC(i.fpago) <=
                    NVL(pfperfin, i.fpago)   -- Bug 15702 - RSC - 27/09/2010 - Models Fiscals: 347
              AND s.cempres = pempres
              AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 1
         UNION
         SELECT   s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro, p.sperson,
                  TRUNC(e.fvalor) fpago, e.sidepag,
                  NVL(e.iretencion,((e.importe * e.retencion) / 100)) iretenc,
                  e.ireduccion ireduc, e.importe iimporte
             FROM prestaextrapp e, seguros s, siniestros si, pagosini p
            WHERE s.sseguro = si.sseguro
              AND si.nsinies = p.nsinies
              AND p.sidepag = e.sidepag
              AND TO_CHAR(e.fvalor, 'yyyy') = pany
              AND TRUNC(e.fvalor) <=
                    NVL(pfperfin, e.fvalor)   -- Bug 15702 - RSC - 27/09/2010 - Models Fiscals: 347
              AND s.cempres = pempres
              AND e.concepto IN(1, 2)   --Concepto de prestación riesgo CS
              AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 0
         UNION
         SELECT   s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro, p.sperson,
                  TRUNC(e.fvalor) fpago, e.sidepag,
                  NVL(e.iretencion,((e.importe * e.retencion) / 100)) iretenc,
                  e.ireduccion ireduc, e.importe iimporte
             FROM prestaextrapp e, seguros s, sin_siniestro si, sin_tramitacion t,
                  sin_tramita_pago p
            WHERE s.sseguro = si.sseguro
              AND si.nsinies = t.nsinies
              AND t.nsinies = p.nsinies
              AND t.ntramit = t.ntramit
              AND p.sidepag = e.sidepag
              AND TO_CHAR(e.fvalor, 'yyyy') = pany
              AND TRUNC(e.fvalor) <=
                    NVL(pfperfin, e.fvalor)   -- Bug 15702 - RSC - 27/09/2010 - Models Fiscals: 347
              AND s.cempres = pempres
              AND e.concepto IN(1, 2)   --Concepto de prestación riesgo CS
              AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 1
         ORDER BY sseguro;

      CURSOR sinoperaciones(fecha DATE) IS
         SELECT s.sseguro, s.cramo, s.cmodali, s.ctipseg, s.ccolect
           FROM seguros s
          WHERE (s.fanulac IS NULL
                 OR(TRUNC(s.fanulac) <= fecha
                    AND TO_CHAR(s.fanulac, 'YYYY') = pany))
            AND s.cagrpro = 11
            AND NOT EXISTS(SELECT DISTINCT f.sseguro
                                      FROM fis_detcierrecobro f
                                     WHERE f.pfiscal = pany
                                       AND f.sseguro = s.sseguro);

      vcobropart     NUMBER;
      vcobroprom     NUMBER;
      vcobrosp       NUMBER;
      vcobroprima    NUMBER;
      vcobroapor     NUMBER;
      vpais          NUMBER;
      vnumnif        VARCHAR2(14);
      --vsfiscab          NUMBER;
      vsseguro       NUMBER;
      vtipoaport     VARCHAR2(2);
      vispfinanc     NUMBER;
      vispnofinanc   NUMBER;
      vfechaaux      DATE;
      vispnofinanc_aux NUMBER;
      vsperson       NUMBER;
      -- 4/5/06 CPM Es crea la variable per recollir el resultat
      vresul         NUMBER;
      vagente_poliza seguros.cagente%TYPE;
      vcempres       seguros.cempres%TYPE;
   BEGIN
      --Inserción de la tabla FIS_DETCIERRECOBRO
      FOR apor IN aportaciones LOOP
         --Aportaciones
         SELECT SUM(NVL(imovimi, 0))
           INTO vcobropart
           FROM ctaseguro
          WHERE sseguro = apor.sseguro
            AND nrecibo = apor.nrecibo
            AND TO_CHAR(fvalmov, 'yyyy') = TO_CHAR(pany)
            AND cmovimi IN(1, 2)
            AND NVL(RTRIM(ctipapor), 'X') IN('X', 'O', 'V')
            AND spermin IS NULL   --Partícipe
            AND cmovanu = 0;

         IF (apor.cramo = 10
             AND apor.cmodali = 2
             AND apor.ctipseg = 1
             AND apor.ccolect = 0) THEN
            --Plan Emaya para extraer el tipo de Aportación del partícipe
            BEGIN
               SELECT ctipapor
                 INTO vtipoaport
                 FROM ctaseguro
                WHERE sseguro = apor.sseguro
                  AND nrecibo = apor.nrecibo
                  AND TO_CHAR(fvalmov, 'yyyy') = TO_CHAR(pany)
                  AND cmovimi IN(1, 2)
                  AND NVL(RTRIM(ctipapor), 'X') IN('X', 'O', 'V')
                  AND spermin IS NULL;   --Tipo de aportación del partícipe
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vtipoaport := NULL;
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'CIERRE FISCAL', NULL,
                              'when others del cierre seguro/recibo =' || apor.sseguro || '/'
                              || apor.nrecibo,
                              SQLERRM);
            END;
         END IF;

         SELECT SUM(NVL(imovimi, 0))
           INTO vcobroprom
           FROM ctaseguro
          WHERE sseguro = apor.sseguro
            AND nrecibo = apor.nrecibo
            AND TO_CHAR(fvalmov, 'yyyy') = TO_CHAR(pany)
            AND cmovimi IN(1, 2)
            AND cmovanu = 0
            AND NVL(RTRIM(ctipapor), 'X') IN('X', 'O')
            AND spermin IS NOT NULL;   --Promotor

         SELECT SUM(NVL(imovimi, 0))
           INTO vcobrosp
           FROM ctaseguro
          WHERE sseguro = apor.sseguro
            AND nrecibo = apor.nrecibo
            AND TO_CHAR(fvalmov, 'yyyy') = TO_CHAR(pany)
            AND cmovimi IN(1, 2)
            AND cmovanu = 0
            AND ctipapor = 'SP';   --Servicios Pasados

         BEGIN
            --Bug10612 - 09/07/2009 - DCT (canviar vista personas)
            --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
            SELECT cagente, cempres
              INTO vagente_poliza, vcempres
              FROM seguros
             WHERE sseguro = apor.sseguro;

            SELECT p.nnumide, d.cpais
              INTO vnumnif, vpais
              FROM per_personas p, per_detper d
             WHERE d.sperson = p.sperson
               AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres)
               AND p.sperson = apor.sperson;
         /*SELECT nnumnif,cpais INTO vnumnif,vpais
         FROM personas
         WHERE sperson=apor.sperson;*/
         EXCEPTION
            WHEN OTHERS THEN
               vnumnif := NULL;
               vpais := NULL;
         END;

         INSERT INTO fis_detcierrecobro
                     (sfiscab, sfisdco, cramo, cmodali, ctipseg,
                      ccolect, pfiscal, sseguro, spersonp, nnumnifp, nrecibo,
                      fefecto, cpaisret, csubtipo, iaporpart, iaporprom, iaporsp, ctipapor)
              VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali, apor.ctipseg,
                      apor.ccolect, pany, apor.sseguro, apor.sperson, vnumnif, apor.nrecibo,
                      apor.fvalmov, vpais, '345', vcobropart, vcobroprom, vcobrosp, vtipoaport);

         IF (apor.cramo = 10
             AND apor.cmodali = 2
             AND apor.ctipseg = 1
             AND apor.ccolect = 0)
            AND(NVL(vsseguro, 0) <> apor.sseguro) THEN
            --Aportaciones que se han de sumar a las del promotor en Plan EMAYA
            /*select sum(greatest(nvl(iprianu,0),nvl(ipritar,0))) into vcobroprima
            from garanseg where sseguro=apor.sseguro and cgarant in (500,502) and ffinefe is null;*/
            BEGIN
               /*SELECT primmue + priminv INTO vcobroprima
                 FROM primariesgo
                WHERE sseguro = apor.sseguro;*/
               SELECT SUM(NVL(imovimi, 0))
                 INTO vcobroprima
                 FROM ctaseguro
                WHERE sseguro = apor.sseguro
                  AND TO_CHAR(fvalmov, 'yyyy') = TO_CHAR(pany)
                  AND ctipapor = 'P';   -- prima riesgo
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vcobroprima := 0;
            END;

            IF vcobroprima > 0 THEN
               --Se graba como recibo 0
               INSERT INTO fis_detcierrecobro
                           (sfiscab, sfisdco, cramo, cmodali,
                            ctipseg, ccolect, pfiscal, sseguro, spersonp,
                            nnumnifp, nrecibo, fefecto, cpaisret, csubtipo, iaporprima)
                    VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali,
                            apor.ctipseg, apor.ccolect, pany, apor.sseguro, apor.sperson,
                            vnumnif, 0, apor.fvalmov, vpais, '345', vcobroprima);
            END IF;

            --Aportaciones que se han de sumar a las del promotor en Plan EMAYA, aportaciones extra
            SELECT ROUND(SUM((NVL(importe, 0) -((importe * retencion) / 100))), 2)
              INTO vcobroapor   --A la aportación le resto la retención
              FROM prestaextrapp
             WHERE sseguro = apor.sseguro
               AND TO_CHAR(fvalor, 'yyyy') = TO_CHAR(pany)
               AND concepto = 2;   --Concepto de aportación del promotor

            IF vcobroapor > 0 THEN
               --Se graba como recibo 0
               INSERT INTO fis_detcierrecobro
                           (sfiscab, sfisdco, cramo, cmodali,
                            ctipseg, ccolect, pfiscal, sseguro, spersonp,
                            nnumnifp, nrecibo, fefecto, cpaisret, csubtipo, iaporprom)
                    VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali,
                            apor.ctipseg, apor.ccolect, pany, apor.sseguro, apor.sperson,
                            vnumnif, 0, apor.fvalmov, vpais, '345', vcobroapor);
            END IF;

            --SP Financiados y no Financiados del ejercicio anterior

            -- Total de aportaciones por SP hasta pany
            BEGIN
               SELECT NVL(SUM(imovimi), 0)
                 INTO vispfinanc
                 FROM ctaseguro
                WHERE sseguro = apor.sseguro
                  AND UPPER(TRIM(ctipapor)) = 'SP'
                  AND TO_NUMBER(TO_CHAR(fvalmov, 'YYYY')) <= pany
                  AND cmovanu = 0;
            EXCEPTION
               WHEN OTHERS THEN
                  vispfinanc := 0;
            END;

            -- Total de aportaciones por SP despues de pany. Para calcular correctamente los SP pedientes
            -- de financiar una vez que se han generado más aportaciones y no se ha cerrado.
            BEGIN
               SELECT NVL(SUM(imovimi), 0)
                 INTO vispnofinanc_aux
                 FROM ctaseguro
                WHERE sseguro = apor.sseguro
                  AND UPPER(TRIM(ctipapor)) = 'SP'
                  AND TO_NUMBER(TO_CHAR(fvalmov, 'YYYY')) > pany
                  AND cmovanu = 0;
            EXCEPTION
               WHEN OTHERS THEN
                  vispnofinanc_aux := 0;
            END;

            BEGIN
               SELECT NVL(apejeantspnofin, 0)
                 INTO vispnofinanc
                 FROM planseguros
                WHERE sseguro = apor.sseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  vispnofinanc := 0;
            END;

            vispnofinanc := vispnofinanc + vispnofinanc_aux;

            INSERT INTO fis_detcierrecobro
                        (sfiscab, sfisdco, cramo, cmodali, ctipseg,
                         ccolect, pfiscal, sseguro, spersonp, nnumnifp, nrecibo,
                         fefecto, cpaisret, csubtipo, ispfinanc, ispnofinanc)
                 VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali, apor.ctipseg,
                         apor.ccolect, pany, apor.sseguro, apor.sperson, vnumnif, 0,
                         apor.fvalmov, vpais, '345', vispfinanc, vispnofinanc);
         END IF;

         vcobroprima := NULL;
         vcobroapor := NULL;
         vtipoaport := NULL;
         vispfinanc := NULL;
         vispnofinanc := NULL;
         vsseguro := apor.sseguro;
      END LOOP;

-- Para aquellos contratos que no han generado cualquier tipo de aportacion se debe grabar un registro
-- con importes a 0 para que conste la informacion fiscal.
      vfechaaux := LAST_DAY(TO_DATE(pany || '12', 'YYYYMM'));

      FOR sinop IN sinoperaciones(vfechaaux) LOOP
         BEGIN
            --Bug10612 - 09/07/2009 - DCT (canviar vista personas)
            --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
            SELECT cagente, cempres
              INTO vagente_poliza, vcempres
              FROM seguros
             WHERE sseguro = sinop.sseguro;

            SELECT p.nnumide, d.cpais, p.sperson
              INTO vnumnif, vpais, vsperson
              FROM per_personas p, per_detper d, riesgos r
             WHERE d.sperson = p.sperson
               AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres)
               AND r.sseguro = sinop.sseguro
               AND r.sperson = p.sperson;
         /*SELECT p.nnumnif,p.cpais, p.sperson INTO vnumnif,vpais,vsperson
         FROM personas p, riesgos r
         WHERE r.sseguro = sinop.sseguro
           AND r.sperson = p.sperson;*/--FI Bug10612 - 09/07/2009 - DCT (canviar vista personas)
         EXCEPTION
            WHEN OTHERS THEN
               vnumnif := NULL;
               vpais := NULL;
         END;

         INSERT INTO fis_detcierrecobro
                     (sfiscab, sfisdco, cramo, cmodali, ctipseg,
                      ccolect, pfiscal, sseguro, spersonp, nnumnifp, cpaisret, csubtipo)
              VALUES (psfiscab, sfisdco.NEXTVAL, sinop.cramo, sinop.cmodali, sinop.ctipseg,
                      sinop.ccolect, pany, sinop.sseguro, vsperson, vnumnif, vpais, '345');
      END LOOP;

      --Inserción de la tabla FIS_DETCIERREPAGO
      FOR presta IN prestaciones LOOP
         --Prestaciones
         BEGIN
            --Bug10612 - 09/07/2009 - DCT (canviar vista personas)
            --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
            SELECT cagente, cempres
              INTO vagente_poliza, vcempres
              FROM seguros
             WHERE sseguro = presta.sseguro;

            SELECT p.nnumide, d.cpais
              INTO vnumnif, vpais
              FROM per_personas p, per_detper d
             WHERE d.sperson = p.sperson
               AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres)
               AND p.sperson = presta.sperson;
           /*SELECT nnumnif,cpais INTO vnumnif,vpais
         FROM personas
         WHERE sperson=presta.sperson;*/

         --FI Bug10612 - 09/07/2009 - DCT (canviar vista personas)
         EXCEPTION
            WHEN OTHERS THEN
               vnumnif := NULL;
               vpais := NULL;
         END;

         INSERT INTO fis_detcierrepago
                     (sfiscab, sfisdpa, cramo, cmodali, ctipseg,
                      ccolect, pfiscal, sseguro, spersonp, nnumnifp,
                      fpago, cpaisret, csubtipo, iresred, iretenc,
                      ibruto, ctipcap, sidepag)
              VALUES (psfiscab, sfisdpa.NEXTVAL, presta.cramo, presta.cmodali, presta.ctipseg,
                      presta.ccolect, pany, presta.sseguro, presta.sperson, vnumnif,
                      presta.fpago, vpais, '190', presta.ireduc, presta.iretenc,
                      presta.iimporte, 1, presta.sidepag);
      END LOOP;

      -- 4/5/06 CPM: Es crida a la funció que recalcula la taula PLANFISCAL
      vresul := f_calculo_planfiscal(pany);

      IF vresul = 0 THEN
         RETURN 0;
      END IF;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'CIERRE FISCAL Cierre_PP', NULL,
                     'when others del cierre =' || psfiscab, SQLERRM);
         RETURN NULL;
   END cierre_pp;

   /*------------------------------------------------------------------------------
     P_Caculo_PlanFiscal
     04/05/2006 CPM
     Procediment per calcular els registres fiscals definitius una vegada tancat
     l'any fiscal
   ------------------------------------------------------------------------------*/
   FUNCTION f_calculo_planfiscal(pany IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      --DELETE FROM PLANFISCAL
      --WHERE nano = pany;
      INSERT INTO planfiscal
                  (sseguro, nano, derechos, aporprom, aporsp, aporparti, retencion)
         SELECT   x.sseguro, pany,
                  f_saldo_pp(x.sseguro, TO_DATE('31/12/' || pany, 'dd/mm/yyyy'), 1),
                  SUM(NVL(iaporprom, 0)), SUM(NVL(iaporsp, 0)), SUM(NVL(iaporpart, 0)),
                  SUM(NVL(iretenc, 0))
             FROM (SELECT sseguro, iaporprom, iaporsp, iaporpart, 0 iretenc
                     FROM fis_detcierrecobro
                    WHERE pfiscal = pany
                   UNION ALL
                   SELECT sseguro, 0 iaporprom, 0 iaporsp, 0 iaporpart, iretenc
                     FROM fis_detcierrepago
                    WHERE pfiscal = pany) x
                  JOIN
                  seguros s ON x.sseguro = s.sseguro
            WHERE s.cagrpro = 11
         GROUP BY x.sseguro;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'p_calculo_planfiscal', NULL,
                     'when others; pany =' || pany, SQLERRM);
         RETURN NULL;
   END f_calculo_planfiscal;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_CIERREFISCAL_PP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CIERREFISCAL_PP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CIERREFISCAL_PP" TO "PROGRAMADORESCSI";
