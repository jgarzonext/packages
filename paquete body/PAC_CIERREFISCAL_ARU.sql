--------------------------------------------------------
--  DDL for Package Body PAC_CIERREFISCAL_ARU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CIERREFISCAL_ARU" IS
/******************************************************************************
   NAME:       PAC_CIERREFISCAL_ARU
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        ??/??/????  ???              1. Created this package body.
   2.0        22/09/2009  DRA              2. 0011183: CRE - Suplemento de alta de asegurado ya existente
   3.0        02/11/2009  APD              3. Bug 11595: CEM - Siniestros. Adaptación al nuevo módulo de siniestros
   4.0        24/02/2010  JMF              4. Bug 0012822: CEM - RT - Tratamiento fiscal rentas a 2 cabezas
   5.0        14/09/2010  ETM              5. BUG 15884 -CEM - Fe de Vida. Nuevos paquetes PLSQL
   6.0        27/09/2010  RSC              6. Bug 15702 - Models Fiscals: 347
   7.0        17/11/2010  RSC              7. Bug 16728 - 2010: Modelo 345
   8.0        23/12/2010  APD              8. Bug 17040 - 2010: Modelo 345
   9.0        14/01/2011  ICV              9. 0016708: 2010: Modelos 188 - 128
  10.0        03/12/2013  JMF              0029015: Modelo 346

******************************************************************************/
   FUNCTION f_modelos_afectados(psseguro IN NUMBER)
      RETURN NUMBER IS
      vresul         VARCHAR2(10) := '';
   BEGIN
      FOR regs IN (SELECT DISTINCT f.modhacienda
                              FROM fis_modhacienda f, seguros s
                             WHERE f.cramo = s.cramo
                               AND s.sseguro = psseguro) LOOP
         vresul := vresul || regs.modhacienda;
      END LOOP;

      RETURN TO_NUMBER(vresul);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   FUNCTION f_proces_modelosafectado(psproces IN NUMBER, pmodhacienda IN NUMBER)
      RETURN NUMBER IS
      vtprolin       VARCHAR2(120);
      car            VARCHAR2(1);
      vcount         NUMBER := 0;
      i              NUMBER;
      vmafectado     VARCHAR2(10);
      vhashcodeerr   pac_cierrefiscal_aru.assoc_array_error;
      vmod1          VARCHAR2(3);
      vmod2          VARCHAR2(3);
      vmod3          VARCHAR2(3);
   /**
       Retorna 0 = TRUE
               1 = FALSE;
   */
   BEGIN
      FOR regs IN (SELECT tprolin
                     FROM procesoslin
                    WHERE sproces = psproces) LOOP
         i := 1;
         vcount := 0;

         WHILE i < LENGTH(regs.tprolin) LOOP
            car := SUBSTR(regs.tprolin, i, 1);

            IF car = ',' THEN
               vcount := vcount + 1;
            END IF;

            i := i + 1;
         END LOOP;

         vmafectado := SUBSTR(pac_util.splitt(regs.tprolin,(vcount + 1), ','), 3,
                              LENGTH(pac_util.splitt(regs.tprolin,(vcount + 1), ',')));
         vmod1 := TO_NUMBER(SUBSTR(vmafectado, 1, 3));
         vmod2 := TO_NUMBER(SUBSTR(vmafectado, 4, 3));
         vmod3 := TO_NUMBER(SUBSTR(vmafectado, 7, 3));

         IF vhashcodeerr.EXISTS(vmod1) THEN
            NULL;
         ELSE
            vhashcodeerr(vmod1) := 0;
         END IF;

         IF vhashcodeerr.EXISTS(vmod2) THEN
            NULL;
         ELSE
            vhashcodeerr(vmod2) := 0;
         END IF;

         IF vhashcodeerr.EXISTS(vmod3) THEN
            NULL;
         ELSE
            vhashcodeerr(vmod3) := 0;
         END IF;
      END LOOP;

      IF vhashcodeerr.EXISTS(pmodhacienda) THEN
         RETURN 0;
      END IF;

      RETURN 1;
   END f_proces_modelosafectado;

   /***********************************************
    Función que valida el porcentaje de retención
   ***********************************************/
   FUNCTION f_valida_retencion(pretenc IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      -- El pretenc sólo puede ser 0, 18 (+-1) o 24 (+-1)
      IF pretenc = 0 THEN
         RETURN 0;   -- OK = Porcentaje de retención válido
      ELSIF pretenc BETWEEN 17 AND 19 THEN
         RETURN 0;   -- OK = Porcentaje de retención válido
      ELSIF pretenc BETWEEN 23 AND 25 THEN
         RETURN 0;   -- OK = Porcentaje de retención válido
      ELSE
         RETURN 1;   -- KO = Porcentaje de retención NO válido
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1;   -- KO = Porcentaje de retención NO válido
   END f_valida_retencion;

   /***********************************************
    Procedure privado del package para obtener
    los datos de los asegurados.
   ***********************************************/
   PROCEDURE f_datos_asegurado(
      psseguro IN NUMBER,
      pnorden IN NUMBER,
      vsperson1 IN OUT NUMBER,
      vnumnif1 IN OUT VARCHAR2,
      vfnacimi1 IN OUT DATE,
      vpais1 IN OUT NUMBER,
      vffecfin1 IN OUT DATE,
      vffecmue1 IN OUT DATE,
      vtidenti IN OUT NUMBER) IS
      vcagente       NUMBER;
      vpersona       personas%ROWTYPE;
      vresult        NUMBER;
   BEGIN
      -- RSC 13/01/2008 Ajustes
      SELECT cagente
        INTO vcagente
        FROM seguros
       WHERE sseguro = psseguro;

      SELECT sperson, ffecfin, ffecmue
        INTO vsperson1, vffecfin1, vffecmue1
        FROM asegurados
       WHERE sseguro = psseguro
         AND norden = pnorden;

      vresult := pac_persona.f_get_dadespersona(vsperson1, vcagente, vpersona);
      vnumnif1 := vpersona.nnumide;
      vfnacimi1 := vpersona.fnacimi;
      vpais1 := vpersona.cpais;
      vtidenti := vpersona.ctipide;
   EXCEPTION
      WHEN OTHERS THEN
         vsperson1 := NULL;
         vnumnif1 := NULL;
         vpais1 := NULL;
         vffecfin1 := NULL;
         vffecmue1 := NULL;
         vtidenti := NULL;
   END f_datos_asegurado;

   FUNCTION cierre_fis_aho(
      pany IN VARCHAR2,
      pempres IN NUMBER,
      psfiscab IN NUMBER,
      psproces IN NUMBER DEFAULT NULL,
      pfperfin IN DATE DEFAULT NULL)   -- Bug 15702 - RSC - 27/09/2010 - Models Fiscals: 347
      RETURN NUMBER IS
      CURSOR aportaciones IS
         SELECT   c.sseguro, c.fcontab, c.nnumlin, s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                  s.sproduc, c.nrecibo, TRUNC(c.fvalmov) fvalmov, c.cmovimi, c.imovimi
             FROM ctaseguro c, seguros s
            WHERE s.sseguro = c.sseguro
              --AND c.cmovimi IN (1, 2, 4, 51) -- RSC 07/01/2008 Excluimos mov 51
              AND c.cmovimi IN(1, 2, 4)
              AND NVL(c.cmovanu, 0) = 0
              AND c.imovimi > 0
              AND TO_CHAR(c.fvalmov, 'YYYY') = pany
              AND TRUNC(c.fvalmov) <=
                    NVL(pfperfin, c.fvalmov)   -- Bug 15702 - RSC - 27/09/2010 - Models Fiscals: 347
              AND s.cempres = NVL(pempres, 1)
              AND s.cagrpro = 2
              AND NOT EXISTS(SELECT *
                               FROM movseguro
                              WHERE sseguro = s.sseguro
                                AND cmotmov = 306)   -- RSC 07/01/2009 Excluimos las
                                                     -- pólizas anuladas al efecto
         ORDER BY c.sseguro;

      -- RSC 21/04/2008
      /***********************************************************************
        Nota: Cuando se traten prestaciones PPA en realidad la variable rcm no
              corresponde al rcm sino al rt. Se ha llamado así a la variable
              por que la mayoria cálculan el rcm.

       RSC 24/11/2008
       Por el programa de migración se ha grabado en iresrec un 0 para prestaciones
       PPA. En principio y por formulacion los PPA grabarán lo mismo en el campo
       IRESRCM y ICONRET, por eso en el cierre tomaremos el campo ICONRET de pagosini
       para guardar en la columna RCM.
      ************************************************************************/
      CURSOR pagos_sin IS
         -- BUG 11595 - 04/11/2009 - APD - Adaptación al nuevo módulo de siniestros
         -- se añade la SELECT FROM para poder añadir la UNION con las tablas nuevas de siniestros
         SELECT   a.npoliza npoliza, a.ncertif ncertif, a.nsolici nsolici, a.cagente cagente,
                  a.sperson, a.nsinies nsinies, a.nriesgo, NULL nombre_beneficiario,
                  a.cramo cramo, a.cmodali cmodali, a.ctipseg ctipseg, a.ccolect ccolect,
                  a.sproduc sproduc, a.sseguro sseguro, a.fefepag fpago,
                  (a.isinret - a.iretenc) importe, a.isinret impbruto, a.pretenc,
                  a.iretenc retencion,(NVL(a.iresred, 0) + NVL(a.ireg_trans, 0)) reduc,

                  -- Bug 17005 - RSC - 21/12/2010 - CEM800 - Ajustes modelos fiscales
                  --DECODE(NVL(f_parproductos_v(a.sproduc, 'PRESTACION'), 0),
                  --       1, a.iconret,
                  --       a.iresrcm) rcm,
                  -- Fin Bug 17005
                  a.iresrcm rcm, a.fsinies, a.fefecto, NULL nif_beneficiario, a.sidepag,
                  a.sperson_pagosini, a.ctipdes ctipdes_pagosini, a.cagrpro, a.ccausin,
                  a.cmotsin, a.cpaisresid
             FROM (SELECT s.npoliza npoliza, s.ncertif ncertif, s.nsolici nsolici,
                          s.cagente cagente, pac_sin.ff_sperson_sinies(si.nsinies) sperson,
                          TO_CHAR(si.nsinies) nsinies, si.nriesgo, s.cramo cramo,
                          s.cmodali cmodali, s.ctipseg ctipseg, s.ccolect ccolect,
                          s.sproduc sproduc, s.sseguro sseguro, pg.fefepag, pg.isinret,
                          pg.iretenc, pg.isinret impbruto, pg.pretenc, pg.iretenc retencion,
                          pg.iresred, pg.ireg_trans, pg.iconret, pg.iresrcm, si.fsinies,
                          s.fefecto, pg.sidepag, pg.sperson sperson_pagosini, pg.ctipdes,
                          s.cagrpro, si.ccausin, si.cmotsin, d.cpaisresid
                     FROM seguros s, siniestros si, /*codicausin c,*/ pagosini pg,
                          destinatarios d
                    WHERE s.sseguro = si.sseguro
                      AND s.cempres = NVL(pempres, 1)
                      AND pg.nsinies = si.nsinies
                      --AND si.ccausin = c.ccausin
                      AND d.nsinies = si.nsinies
                      AND d.sperson = pg.sperson
                      AND TO_CHAR(pg.fefepag, 'yyyy') = pany
                      AND TRUNC(pg.fefepag) <=
                            NVL
                               (pfperfin, pg.fefepag)   -- Bug 15702 - RSC - 27/09/2010 - Models Fiscals: 347
                      AND pg.cestpag = 2   --Pagos pagados
                      --AND c.catribu <> 10
                      AND s.cagrpro = 2   -- Ahorro
                      AND pg.ctippag = 2   -- RSC 07/01/2008 Excluimos pagos que tengan un
                                           -- pago de Anulación de pago
                      AND pg.sidepag NOT IN(SELECT NVL(pp.spganul, 0)
                                              FROM pagosini pp
                                             WHERE nsinies = pg.nsinies
                                               AND cestpag <> 8)   -- RSC 07/01/2008 Excluimos
                                                                   -- pagos que tengan un pago
                                                                   -- de Anulación de pago
                      AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 0
                   UNION
                   SELECT s.npoliza npoliza, s.ncertif ncertif, s.nsolici nsolici,
                          s.cagente cagente,
                          pac_siniestros.ff_sperson_sinies(si.nsinies) sperson,
                          si.nsinies nsinies, si.nriesgo, s.cramo cramo, s.cmodali cmodali,
                          s.ctipseg ctipseg, s.ccolect ccolect, s.sproduc sproduc,
                          s.sseguro sseguro, m.fefepag, pg.isinret, pg.iretenc,
                          pg.isinret impbruto, pgar.pretenc, pg.iretenc retencion, pg.iresred,
                          NULL ireg_trans,(pg.isinret - pg.iretenc) iconret, pg.iresrcm rcm,
                          si.fsinies, s.fefecto, pg.sidepag, pg.sperson sperson_pagosini,
                          pg.ctipdes, s.cagrpro, si.ccausin, si.cmotsin, pd.cpais cpaisresid
                     FROM seguros s, sin_siniestro si, sin_tramitacion t, sin_tramita_pago pg,
                          sin_tramita_movpago m, sin_tramita_pago_gar pgar,
                          sin_tramita_destinatario d, per_personas pp, per_detper pd
                    WHERE s.sseguro = si.sseguro
                      AND s.cempres = NVL(pempres, 1)
                      AND si.nsinies = t.nsinies
                      AND pg.nsinies = t.nsinies
                      AND pg.ntramit = t.ntramit
                      AND d.nsinies = t.nsinies
                      -- AND d.nsinies = t.ntramit  -- Bug 0013152. FAL. 23/02/2010. Join correcta d.ntramit = t.ntramit
                      AND d.ntramit = t.ntramit   -- Fi Bug 0013152. FAL. 23/02/2010
                      AND d.sperson = pg.sperson
                      AND pg.sidepag = m.sidepag
                      AND m.nmovpag = (SELECT MAX(nmovpag)
                                         FROM sin_tramita_movpago
                                        WHERE sidepag = m.sidepag
                                          AND TO_CHAR(m.fefepag, 'yyyy') = pany)   --Bug.: 16708- ICV
                      AND pg.sidepag = pgar.sidepag
                      AND pgar.ctipres = 1
                      AND d.sperson = pp.sperson
                      AND pp.sperson = pd.sperson
                      AND pd.cagente = ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres)
                      AND TO_CHAR(m.fefepag, 'yyyy') = pany
                      AND TRUNC(m.fefepag) <=
                            NVL(pfperfin, m.fefepag)   -- Bug 15702 - RSC - 27/09/2010 - Models Fiscals: 347
                      AND m.cestpag = 2   --Pagos pagados
                      AND s.cagrpro = 2   -- Ahorro
                      AND pg.ctippag = 2   -- RSC 07/01/2008 Excluimos pagos que tengan un
                                           -- pago de Anulación de pago
                      AND m.cestpag <> 8   -- Anulado -- RSC 07/01/2008 Excluimos
                                 -- pagos que tengan un pago
                                 -- de Anulación de pago
                      -- Para el nuevo modelo será excluir los pagos que estén anulados
                      AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 1) a
         ORDER BY a.cramo, a.cmodali, a.ctipseg, a.ccolect, a.nsinies, fpago;

      vcobropart     NUMBER;
      vpais          NUMBER;
      vnumnif        VARCHAR2(14);
      vtidenti       NUMBER;
      vsseguro       NUMBER;
      vfechaaux      DATE;
      vispnofinanc_aux NUMBER;
      vsperson       NUMBER;
      -- 4/5/06 CPM Es crea la variable per recollir el resultat
      vresul         NUMBER;
      -- RSC 03/11/2008
      vsperson1      NUMBER;
      vnumnif1       VARCHAR2(14);
      vpais1         NUMBER;
      vffecfin1      DATE;
      vffecmue1      DATE;
      vfnacimi1      DATE;
      vtidenti1      NUMBER;
      vtestnif1      NUMBER;
      vsperson2      NUMBER;
      vnumnif2       VARCHAR2(14);
      vpais2         NUMBER;
      vffecfin2      DATE;
      vffecmue2      DATE;
      vfnacimi2      DATE;
      vtidenti2      NUMBER;
      vtestnif2      NUMBER;
      vspersonrep    NUMBER;
      vnnumnifrep    VARCHAR2(14);
      vfpeticion     DATE;
      vfnacimi       DATE;
      -- RSC 10/12/2008
      vsproces       NUMBER;
      perror         NUMBER;
      vtexto         VARCHAR2(200);
      vnprolin       NUMBER;
      aport_execp    EXCEPTION;
      vcontaerr      NUMBER := 0;
      vcontador      NUMBER := 0;
      vsperson_ax1   NUMBER;
      -- RSC 16/12/2008
      do_nothing     EXCEPTION;
      vtcausin       VARCHAR2(100);
      -- RSC 19/12/2008
      vauxinif       VARCHAR2(14);
      vhashcodeerr   pac_cierrefiscal_aru.assoc_array_error;
      verrprolin     VARCHAR2(120);
      verrcode       NUMBER;
      -- RSC 07/01/2008
      vorden         NUMBER;
      vpconsum_ircm  NUMBER;
      vpconsum_ireduc NUMBER;
      vpconsum_ireg_transcomp NUMBER;
      -- RSC 14/01/2008
      vcagente       NUMBER;
      vpersona       personas%ROWTYPE;
      vresult        NUMBER;
      -- Bug 17005 - RSC - 15/12/2010 - CEM800 - Ajustes modelos fiscales
      v_clave        VARCHAR2(1);
      -- Fin Bug 17005
      vclave345      VARCHAR2(1);   -- Bug 17040 - APD - 23/12/2010 - 2010: Modelo 345
      vfval345       DATE := NULL;   -- Bug 17040 - APD - 23/12/2010 - 2010: Modelo 345
   BEGIN
      IF psproces IS NULL THEN
         perror := f_procesini(getuser, pempres,
                               'CIERREFIS:' || TO_CHAR(f_sysdate, 'yyyymmdd'),
                               'CIERRE FISCAL AHORRO', vsproces);
      ELSE
         vsproces := psproces;
      END IF;

      --Inserción de la tabla FIS_DETCIERRECOBRO
      FOR apor IN aportaciones LOOP
         BEGIN
            -- RSC 03/11/2008
            vcobropart := apor.imovimi;

            IF apor.cmovimi IN(1, 2, 4) THEN
               vcobropart := apor.imovimi;
            ELSE
               vcobropart := apor.imovimi * -1;
            END IF;

            -- 1 cabeza
            f_datos_asegurado(apor.sseguro, 1, vsperson1, vnumnif1, vfnacimi1, vpais1,
                              vffecfin1, vffecmue1, vtidenti1);
            -- 2 cabezas
            f_datos_asegurado(apor.sseguro, 2, vsperson2, vnumnif2, vfnacimi2, vpais2,
                              vffecfin2, vffecmue2, vtidenti2);

            -- Bug 17040 - APD - 23/12/2010 - Se busca el valor de la variabla vclave345
            -- necesario para insertarlo en la tabla FIS_DETCIERRECOBRO
            BEGIN
               SELECT DECODE(NVL(f_parproductos_v(f_sproduc_ret(apor.cramo, apor.cmodali,
                                                                apor.ctipseg, apor.ccolect),
                                                  'TIPO_LIMITE'),
                                 0),
                             1, 'I',
                             0, DECODE(NVL(f_parproductos_v(f_sproduc_ret(apor.cramo,
                                                                          apor.cmodali,
                                                                          apor.ctipseg,
                                                                          apor.ccolect),
                                                            'PRESTACION'),
                                           0),
                                       1, 'H',
                                       ' '))
                 INTO vclave345
                 FROM DUAL;
            EXCEPTION
               WHEN OTHERS THEN
                  vclave345 := ' ';
            END;

            -- Fin Bug 17040 - APD - 23/12/2010

            -- Bug 17040 - APD - 23/12/2010 - Se busca el valor de la variabla vfval345
            -- necesario para insertarlo en la tabla FIS_DETCIERRECOBRO
            -- Solo se busca el valor si vclave345 = 'I' (es decir, el producto es el PIAS (279))
            vfval345 := NULL;

            IF vclave345 = 'I' THEN
               BEGIN
                  SELECT fval
                    INTO vfval345
                    FROM (SELECT   pa.fvalmov fval, pa.nnumlin
                              FROM primas_aportadas pa
                             WHERE pa.sseguro = apor.sseguro
                               AND pa.iprima > (SELECT NVL(SUM(ircm), 0)
                                                  FROM primas_consumidas
                                                 WHERE sseguro = pa.sseguro
                                                   AND nnumlin = pa.nnumlin)
                               AND ROWNUM = 1
                          ORDER BY pa.nnumlin ASC);
               EXCEPTION
                  WHEN OTHERS THEN
                     vfval345 := NULL;
               END;
            END IF;

            -- Fin Bug 17040 - APD - 23/12/2010
            IF vsperson2 IS NULL THEN   -- 1 cabeza
               perror := f_valida_nif_1cabeza(vsperson1, vtidenti1, apor.sseguro, vsproces,
                                              vnumnif1, vhashcodeerr);

               IF perror <> 0 THEN
                  RAISE aport_execp;
               END IF;

               -- Bug 17040 - APD - 23/12/2010 - Se añade el campo clave345 y fval345
               -- a la tabla FIS_DETCIERRECOBRO
               INSERT INTO fis_detcierrecobro
                           (sfiscab, sfisdco, cramo, cmodali, ctipseg,
                            ccolect, pfiscal, sseguro, spersonp, nnumnifp,
                            nrecibo, fefecto, cpaisret, csubtipo, iaporpart,
                            iimporte, iaporprom, iaporsp, ctipapor, clave345, fval345)
                    VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali, apor.ctipseg,
                            apor.ccolect, pany, apor.sseguro, vsperson1, vnumnif1,
                            apor.nrecibo, apor.fvalmov, vpais1, NULL /*'345'*/, NULL,
                            vcobropart, NULL, NULL, NULL, vclave345, vfval345);
            -- Fin Bug 17040 - APD - 23/12/2010
            ELSE
               IF vffecmue1 IS NULL
                  AND vffecmue2 IS NULL THEN
-- Dos asegurados vivos
-- A efectos fiscales se considerará que cada uno de ellos ha liquidado
-- el 50% de la prima. A cada titular se le remitirá la información
-- fiscal correspondiente, si el titular es menor de 14 años se
-- identifica en el modelo 188 identificando como representante del
-- mismo al primer titular.
-------------------------------------------------------------------
                  perror := f_trata_representante(vsperson1, vsperson2, vnumnif2,
                                                  apor.sseguro, apor.fvalmov, apor.sproduc,
                                                  vfnacimi1, vnumnif1, vtidenti1, vtidenti2,
                                                  vspersonrep, vnnumnifrep, vsproces,
                                                  vhashcodeerr);

                  IF perror <> 0 THEN
                     RAISE aport_execp;
                  END IF;

                  -- La mitad de la aportación para uno y la otra mitad para el otro
                  -- Bug 17040 - APD - 23/12/2010 - Se añade el campo clave345 y fval345
                  -- a la tabla FIS_DETCIERRECOBRO
                  INSERT INTO fis_detcierrecobro
                              (sfiscab, sfisdco, cramo, cmodali,
                               ctipseg, ccolect, pfiscal, sseguro, spersonp,
                               nnumnifp, sperson1, nnumnif1, nrecibo, fefecto,
                               cpaisret, csubtipo, iaporpart, iimporte, iaporprom, iaporsp,
                               ctipapor, clave345, fval345)
                       VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali,
                               apor.ctipseg, apor.ccolect, pany, apor.sseguro, vsperson1,
                               vnumnif1, vspersonrep, vnnumnifrep, apor.nrecibo, apor.fvalmov,
                               vpais1, NULL, NULL,(vcobropart / 2), NULL, NULL,
                               NULL, vclave345, vfval345);

                  -- Fin Bug 17040 - APD - 23/12/2010
                  -- Miramos si precisa representante (el otro titular en este caso)
                  perror := f_trata_representante(vsperson2, vsperson1, vnumnif1, apor.sseguro,
                                                  apor.fvalmov, apor.sproduc, vfnacimi2,
                                                  vnumnif2, vtidenti2, vtidenti1, vspersonrep,
                                                  vnnumnifrep, vsproces, vhashcodeerr);

                  IF perror <> 0 THEN
                     RAISE aport_execp;
                  END IF;

                  -- Bug 17040 - APD - 23/12/2010 - Se añade el campo clave345 y fval345
                  -- a la tabla FIS_DETCIERRECOBRO
                  INSERT INTO fis_detcierrecobro
                              (sfiscab, sfisdco, cramo, cmodali,
                               ctipseg, ccolect, pfiscal, sseguro, spersonp,
                               nnumnifp, sperson1, nnumnif1, nrecibo, fefecto,
                               cpaisret, csubtipo, iaporpart, iimporte, iaporprom, iaporsp,
                               ctipapor, clave345, fval345)
                       VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali,
                               apor.ctipseg, apor.ccolect, pany, apor.sseguro, vsperson2,
                               vnumnif2, vspersonrep, vnnumnifrep, apor.nrecibo, apor.fvalmov,
                               vpais2, NULL, NULL,(vcobropart / 2), NULL, NULL,
                               NULL, vclave345, vfval345);
               -- Fin Bug 17040 - APD - 23/12/2010
               ELSIF vffecmue1 IS NOT NULL THEN
                  IF vffecmue1 > apor.fvalmov THEN
                     perror := f_trata_representante(vsperson1, vsperson2, vnumnif2,
                                                     apor.sseguro, apor.fvalmov, apor.sproduc,
                                                     vfnacimi1, vnumnif1, vtidenti1,
                                                     vtidenti2, vspersonrep, vnnumnifrep,
                                                     vsproces, vhashcodeerr);

                     IF perror <> 0 THEN
                        RAISE aport_execp;
                     END IF;

                     -- La mitad de la aportación para uno y la otra mitad para el otro
                     -- Bug 17040 - APD - 23/12/2010 - Se añade el campo clave345 y fval345
                     -- a la tabla FIS_DETCIERRECOBRO
                     INSERT INTO fis_detcierrecobro
                                 (sfiscab, sfisdco, cramo, cmodali,
                                  ctipseg, ccolect, pfiscal, sseguro, spersonp,
                                  nnumnifp, sperson1, nnumnif1, nrecibo,
                                  fefecto, cpaisret, csubtipo, iaporpart, iimporte, iaporprom,
                                  iaporsp, ctipapor, clave345, fval345)
                          VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali,
                                  apor.ctipseg, apor.ccolect, pany, apor.sseguro, vsperson1,
                                  vnumnif1, vspersonrep, vnnumnifrep, apor.nrecibo,
                                  apor.fvalmov, vpais1, NULL, NULL,(vcobropart / 2), NULL,
                                  NULL, NULL, vclave345, vfval345);

                     -- Fin Bug 17040 - APD - 23/12/2010
                     -- Miramos si precisa representante (el otro titular en este caso)
                     perror := f_trata_representante(vsperson2, vsperson1, vnumnif1,
                                                     apor.sseguro, apor.fvalmov, apor.sproduc,
                                                     vfnacimi2, vnumnif2, vtidenti2, vtidenti1,
                                                     vspersonrep, vnnumnifrep, vsproces,
                                                     vhashcodeerr);

                     IF perror <> 0 THEN
                        RAISE aport_execp;
                     END IF;

                     -- Bug 17040 - APD - 23/12/2010 - Se añade el campo clave345 y fval345
                     -- a la tabla FIS_DETCIERRECOBRO
                     INSERT INTO fis_detcierrecobro
                                 (sfiscab, sfisdco, cramo, cmodali,
                                  ctipseg, ccolect, pfiscal, sseguro, spersonp,
                                  nnumnifp, sperson1, nnumnif1, nrecibo,
                                  fefecto, cpaisret, csubtipo, iaporpart, iimporte, iaporprom,
                                  iaporsp, ctipapor, clave345, fval345)
                          VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali,
                                  apor.ctipseg, apor.ccolect, pany, apor.sseguro, vsperson2,
                                  vnumnif2, vspersonrep, vnnumnifrep, apor.nrecibo,
                                  apor.fvalmov, vpais2, NULL, NULL,(vcobropart / 2), NULL,
                                  NULL, NULL, vclave345, vfval345);
                  -- Fin Bug 17040 - APD - 23/12/2010
                  ELSE
                     -- Bug 17040 - APD - 23/12/2010 - Se añade el campo clave345 y fval345
                     -- a la tabla FIS_DETCIERRECOBRO
                     INSERT INTO fis_detcierrecobro
                                 (sfiscab, sfisdco, cramo, cmodali,
                                  ctipseg, ccolect, pfiscal, sseguro, spersonp,
                                  nnumnifp, nrecibo, fefecto, cpaisret, csubtipo, iaporpart,
                                  iimporte, iaporprom, iaporsp, ctipapor, clave345, fval345)
                          VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali,
                                  apor.ctipseg, apor.ccolect, pany, apor.sseguro, vsperson2,
                                  vnumnif2, apor.nrecibo, apor.fvalmov, vpais2, NULL, NULL,
                                  vcobropart, NULL, NULL, NULL, vclave345, vfval345);
                  -- Fin Bug 17040 - APD - 23/12/2010
                  END IF;
               ELSIF vffecmue2 IS NOT NULL THEN
                  IF vffecmue2 > apor.fvalmov THEN
                     perror := f_trata_representante(vsperson1, vsperson2, vnumnif2,
                                                     apor.sseguro, apor.fvalmov, apor.sproduc,
                                                     vfnacimi1, vnumnif1, vtidenti1,
                                                     vtidenti2, vspersonrep, vnnumnifrep,
                                                     vsproces, vhashcodeerr);

                     IF perror <> 0 THEN
                        RAISE aport_execp;
                     END IF;

                     -- La mitad de la aportación para uno y la otra mitad para el otro
                     -- Bug 17040 - APD - 23/12/2010 - Se añade el campo clave345 y fval345
                     -- a la tabla FIS_DETCIERRECOBRO
                     INSERT INTO fis_detcierrecobro
                                 (sfiscab, sfisdco, cramo, cmodali,
                                  ctipseg, ccolect, pfiscal, sseguro, spersonp,
                                  nnumnifp, sperson1, nnumnif1, nrecibo,
                                  fefecto, cpaisret, csubtipo, iaporpart, iimporte, iaporprom,
                                  iaporsp, ctipapor, clave345, fval345)
                          VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali,
                                  apor.ctipseg, apor.ccolect, pany, apor.sseguro, vsperson1,
                                  vnumnif1, vspersonrep, vnnumnifrep, apor.nrecibo,
                                  apor.fvalmov, vpais1, NULL, NULL,(vcobropart / 2), NULL,
                                  NULL, NULL, vclave345, vfval345);

                     -- Fin Bug 17040 - APD - 23/12/2010
                     -- Miramos si precisa representante (el otro titular en este caso)
                     perror := f_trata_representante(vsperson2, vsperson1, vnumnif1,
                                                     apor.sseguro, apor.fvalmov, apor.sproduc,
                                                     vfnacimi2, vnumnif2, vtidenti2, vtidenti1,
                                                     vspersonrep, vnnumnifrep, vsproces,
                                                     vhashcodeerr);

                     IF perror <> 0 THEN
                        RAISE aport_execp;
                     END IF;

                     -- Bug 17040 - APD - 23/12/2010 - Se añade el campo clave345 y fval345
                     -- a la tabla FIS_DETCIERRECOBRO
                     INSERT INTO fis_detcierrecobro
                                 (sfiscab, sfisdco, cramo, cmodali,
                                  ctipseg, ccolect, pfiscal, sseguro, spersonp,
                                  nnumnifp, sperson1, nnumnif1, nrecibo,
                                  fefecto, cpaisret, csubtipo, iaporpart, iimporte, iaporprom,
                                  iaporsp, ctipapor, clave345, fval345)
                          VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali,
                                  apor.ctipseg, apor.ccolect, pany, apor.sseguro, vsperson2,
                                  vnumnif2, vspersonrep, vnnumnifrep, apor.nrecibo,
                                  apor.fvalmov, vpais2, NULL, NULL,(vcobropart / 2), NULL,
                                  NULL, NULL, vclave345, vfval345);
                  -- Fin Bug 17040 - APD - 23/12/2010
                  ELSE
                     -- Bug 17040 - APD - 23/12/2010 - Se añade el campo clave345 y fval345
                     -- a la tabla FIS_DETCIERRECOBRO
                     INSERT INTO fis_detcierrecobro
                                 (sfiscab, sfisdco, cramo, cmodali,
                                  ctipseg, ccolect, pfiscal, sseguro, spersonp,
                                  nnumnifp, nrecibo, fefecto, cpaisret, csubtipo, iaporpart,
                                  iimporte, iaporprom, iaporsp, ctipapor, clave345, fval345)
                          VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali,
                                  apor.ctipseg, apor.ccolect, pany, apor.sseguro, vsperson1,
                                  vnumnif1, apor.nrecibo, apor.fvalmov, vpais1, NULL, NULL,
                                  vcobropart, NULL, NULL, NULL, vclave345, vfval345);
                  -- Fin Bug 17040 - APD - 23/12/2010
                  END IF;
               END IF;
            END IF;
         EXCEPTION
            WHEN aport_execp THEN
               vcontaerr := vcontaerr + 1;
         END;
      END LOOP;

      -- Para aquellos contratos que no han generado cualquier tipo de aportacion se debe grabar un registro
      -- con importes a 0 para que conste la informacion fiscal.
      vfechaaux := LAST_DAY(TO_DATE(pany || '12', 'YYYYMM'));

      --Inserción de la tabla FIS_DETCIERREPAGO
      FOR cur_pags IN pagos_sin LOOP
         BEGIN
            BEGIN
               SELECT cagente
                 INTO vcagente
                 FROM seguros
                WHERE sseguro = cur_pags.sseguro;

               vresult := pac_persona.f_get_dadespersona(cur_pags.sperson_pagosini, vcagente,
                                                         vpersona);
               vnumnif := vpersona.nnumide;
               vfnacimi := vpersona.fnacimi;
               vpais := vpersona.cpais;
               vtidenti := vpersona.ctipide;
            EXCEPTION
               WHEN OTHERS THEN
                  vnumnif := NULL;
                  vpais := NULL;
            END;

            -- Guardamos una copia del NIF por si la necesitamos
            vauxinif := vnumnif;

            --Bug 0016708 -- 14/01/2011 - ICV
            IF cur_pags.ccausin IN(3, 4, 5) THEN
               BEGIN
                  SELECT norden
                    INTO vorden
                    FROM asegurados
                   WHERE sperson = cur_pags.sperson_pagosini
                     AND sseguro = cur_pags.sseguro   -- BUG11183:DRA:22/09/2009
                     AND ffecfin IS NULL;   -- BUG11183:DRA:22/09/2009
               EXCEPTION
                  WHEN OTHERS THEN
                     vorden := 1;
               END;

               BEGIN
                  SELECT SUM(ircm), SUM(ireduc), SUM(ireg_transcomp)
                    INTO vpconsum_ircm, vpconsum_ireduc, vpconsum_ireg_transcomp
                    FROM primas_consumidas
                   WHERE sseguro = cur_pags.sseguro
                     AND nriesgo = vorden
                     AND frescat = cur_pags.fsinies;   --Bug 0016708
               EXCEPTION
                  WHEN OTHERS THEN
                     vpconsum_ircm := 0;
                     vpconsum_ireduc := 0;
                     vpconsum_ireg_transcomp := 0;
               END;
            ELSE
               vpconsum_ircm := NULL;
               vpconsum_ireduc := NULL;
               vpconsum_ireg_transcomp := NULL;
            END IF;

            -- Bug 17005 - RSC - 15/12/2010 - CEM800 - Ajustes modelos fiscales
            SELECT DECODE(NVL(f_parproductos_v(cur_pags.sproduc, 'TIPO_LIMITE'), 0),
                          1, DECODE(NVL(cur_pags.reduc, 0), 0, ' ', 'B'),
                          DECODE(NVL((SUM(NVL(vpconsum_ircm, 0)) - SUM(NVL(vpconsum_ireduc, 0))
                                      - SUM(NVL(vpconsum_ireg_transcomp, 0))),
                                     0),
                                 0, ' ',
                                 'A'))
              INTO v_clave
              FROM DUAL;

            -- Fin Bug 17005
            INSERT INTO fis_detcierrepago
                        (sfiscab, sfisdpa, cramo, cmodali,
                         ctipseg, ccolect, pfiscal, sseguro,
                         spersonp, nnumnifp, fpago,
                         cpaisret, csubtipo, iresred, iresrcm,
                         pretenc, iretenc, ibruto,
                         ineto, ctipcap, sidepag,
                         csigbase,
                         ctipo,
                         pconsum_ircm, pconsum_ireduc, pconsum_ireg_transcomp, clave)   -- Bug 17005 - RSC - 15/12/2010 - CEM800 - Ajustes modelos fiscales
                 VALUES (psfiscab, sfisdpa.NEXTVAL, cur_pags.cramo, cur_pags.cmodali,
                         cur_pags.ctipseg, cur_pags.ccolect, pany, cur_pags.sseguro,
                         cur_pags.sperson_pagosini, vnumnif, cur_pags.fpago,
                         cur_pags.cpaisresid, NULL, cur_pags.reduc, cur_pags.rcm,
                         cur_pags.pretenc, cur_pags.retencion, cur_pags.impbruto,
                         cur_pags.importe, 1, cur_pags.sidepag,
                         DECODE(SIGN(cur_pags.rcm), -1, 'N', 'P'),
                         DECODE(cur_pags.ccausin,
                                1, DECODE(cur_pags.cmotsin, 0, 'SIN', NULL),
                                8, 'TRS',
                                3, 'VTO',
                                4, 'RTO',
                                5, 'RPA',
                                NULL),
                         vpconsum_ircm, vpconsum_ireduc, vpconsum_ireg_transcomp, v_clave);   -- Bug 17005 - RSC - 15/12/2010 - CEM800 - Ajustes modelos fiscales
         EXCEPTION
            WHEN aport_execp THEN
               vcontaerr := vcontaerr + 1;
            WHEN do_nothing THEN
               NULL;
         END;
      END LOOP;

      IF psproces IS NULL THEN
         -- Finalizamos proces
         perror := f_procesfin(vsproces, vcontaerr);
      END IF;

      -- 4/5/06 CPM: Es crida a la funció que recalcula la taula PLANFISCAL
      vresul := f_calculo_planfiscal_aho(pany);

      IF vresul = 0 THEN
         RETURN 0;
      END IF;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'CIERRE FISCAL Cierre_Fis_Aho', NULL,
                     'when others del cierre =' || psfiscab, SQLERRM);
   END cierre_fis_aho;

   FUNCTION cierre_fis_ren_ulk(
      pany IN VARCHAR2,
      pempres IN NUMBER,
      psfiscab IN NUMBER,
      psproces IN NUMBER DEFAULT NULL,
      pfperfin IN DATE DEFAULT NULL)   -- Bug 15702 - RSC - 27/09/2010 - Models Fiscals: 347
      RETURN NUMBER IS
      /*************************
        APORTACIONES REALIZADAS
      **************************/
      CURSOR aportaciones IS
         SELECT   c.sseguro, c.fcontab, c.nnumlin, s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                  s.sproduc, c.nrecibo, TRUNC(c.fvalmov) fvalmov, c.cmovimi, c.imovimi
             FROM ctaseguro c, seguros s
            WHERE s.sseguro = c.sseguro
              AND c.cmovimi IN(1, 2, 4)   -- RSC 07/01/2009 (Aportación y Extorno
                                          -- se contrarestan y fiscalmente no se presentan).
              AND NVL(c.cmovanu, 0) = 0
              AND c.imovimi > 0
              AND TO_CHAR(c.fvalmov, 'YYYY') = pany
              AND TRUNC(c.fvalmov) <=
                    NVL(pfperfin, c.fvalmov)   -- Bug 15702 - RSC - 27/09/2010 - Models Fiscals: 347
              AND s.cempres = NVL(pempres, 1)
              AND s.cagrpro IN(10, 21)
              AND NOT EXISTS(SELECT *
                               FROM movseguro
                              WHERE sseguro = s.sseguro
                                AND cmotmov = 306)   -- RSC 07/01/2009 Excluimos las pólizas
                                                     -- anuladas al efecto
         ORDER BY c.sseguro;

      -- RSC 21/04/2008
      -- Cursor similar/extraido de PAC_EXCEL.f_snsin005
      /*************************
       SINIESTROS, RESCATES, etc
      **************************/
      CURSOR pagos_sin IS
         -- BUG 11595 - 04/11/2009 - APD - Adaptación al nuevo módulo de siniestros
         -- se añade la SELECT FROM para poder añadir la UNION con las tablas nuevas de siniestros
         SELECT   a.npoliza npoliza, a.ncertif ncertif, a.nsolici nsolici, a.cagente cagente,
                  a.sperson, a.nsinies nsinies, a.nriesgo, a.nombre_beneficiario,
                  a.cramo cramo, a.cmodali cmodali, a.ctipseg ctipseg, a.ccolect ccolect,
                  a.sproduc sproduc, a.sseguro sseguro, a.fpago, a.importe, a.impbruto,
                  a.pretenc, a.retencion,(NVL(a.iresred, 0) + NVL(a.ireg_trans, 0)) reduc,
                  a.rcm, a.fsinies, a.fefecto, a.nif_beneficiario, a.sidepag,
                  a.sperson sperson_pagosini, a.ctipdes_pagosini, a.cagrpro, a.ccausin,
                  a.cpaisresid
             FROM (SELECT s.npoliza npoliza, s.ncertif ncertif, s.nsolici nsolici,
                          s.cagente cagente, pac_sin.ff_sperson_sinies(si.nsinies) sperson,
                          TO_CHAR(si.nsinies) nsinies, si.nriesgo, NULL nombre_beneficiario,
                          s.cramo cramo, s.cmodali cmodali, s.ctipseg ctipseg,
                          s.ccolect ccolect, s.sproduc sproduc, s.sseguro sseguro,
                          pg.fefepag fpago,(pg.isinret - pg.iretenc) importe,
                          pg.isinret impbruto, pg.pretenc, pg.iretenc retencion, pg.iresred,
                          pg.ireg_trans, pg.iresrcm rcm, si.fsinies, s.fefecto,
                          NULL nif_beneficiario, pg.sidepag, pg.sperson sperson_pagosini,
                          pg.ctipdes ctipdes_pagosini, s.cagrpro, si.ccausin, d.cpaisresid
                     FROM seguros s, siniestros si, /*codicausin c,*/ pagosini pg,
                          destinatarios d
                    WHERE s.sseguro = si.sseguro
                      AND s.cempres = NVL(pempres, 1)
                      AND pg.nsinies = si.nsinies
                      --AND si.ccausin = c.ccausin
                      AND d.nsinies = si.nsinies
                      AND d.sperson = pg.sperson
                      AND TO_CHAR(pg.fefepag, 'yyyy') = pany
                      AND TRUNC(pg.fefepag) <=
                            NVL
                               (pfperfin, pg.fefepag)   -- Bug 15702 - RSC - 27/09/2010 - Models Fiscals: 347
                      AND pg.cestpag = 2   --Pagos pagados
                      --AND c.catribu <> 10
                      AND s.cagrpro IN(10, 21)   -- Rentas / Unit Linked
                      AND pg.ctippag = 2   -- RSC 07/01/2008 Excluimos pagos que tengan un
                                           -- pago de Anulación de pago
                      AND pg.sidepag NOT IN(SELECT NVL(pp.spganul, 0)
                                              FROM pagosini pp
                                             WHERE nsinies = pg.nsinies
                                               AND cestpag <> 8)   -- RSC 07/01/2008 Excluimos
                                                                   -- pagos que tengan un pago
                                                                   -- de Anulación de pago
                      AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 0
                   UNION
                   SELECT s.npoliza npoliza, s.ncertif ncertif, s.nsolici nsolici,
                          s.cagente cagente,
                          pac_siniestros.ff_sperson_sinies(si.nsinies) sperson,
                          si.nsinies nsinies, si.nriesgo, NULL nombre_beneficiario,
                          s.cramo cramo, s.cmodali cmodali, s.ctipseg ctipseg,
                          s.ccolect ccolect, s.sproduc sproduc, s.sseguro sseguro,
                          m.fefepag fpago,(pg.isinret - pg.iretenc) importe,
                          pg.isinret impbruto, pgar.pretenc, pg.iretenc retencion, pg.iresred,
                          NULL ireg_trans, pg.iresrcm rcm, si.fsinies, s.fefecto,
                          NULL nif_beneficiario, pg.sidepag, pg.sperson sperson_pagosini,
                          pg.ctipdes ctipdes_pagosini, s.cagrpro, si.ccausin,
                          pd.cpais cpaisresid
                     FROM seguros s, sin_siniestro si, sin_tramitacion t, sin_tramita_pago pg,
                          sin_tramita_movpago m, sin_tramita_pago_gar pgar,
                          sin_tramita_destinatario d, per_personas pp, per_detper pd
                    WHERE s.sseguro = si.sseguro
                      AND s.cempres = NVL(pempres, 1)
                      AND si.nsinies = t.nsinies
                      AND pg.nsinies = t.nsinies
                      AND pg.ntramit = t.ntramit
                      AND d.nsinies = t.nsinies
                      --AND d.nsinies = t.ntramit -- Bug 16728 - RSC - 17/11/2010 - 2010: Modelo 345
                      AND d.ntramit =
                                    t.ntramit   -- Bug 16728 - RSC - 17/11/2010 - 2010: Modelo 345
                      AND d.sperson = pg.sperson
                      AND pg.sidepag = m.sidepag
                      AND m.nmovpag = (SELECT MAX(nmovpag)
                                         FROM sin_tramita_movpago
                                        WHERE sidepag = m.sidepag)
                      AND pg.sidepag = pgar.sidepag
                      AND pgar.ctipres = 1
                      AND d.sperson = pp.sperson
                      AND pp.sperson = pd.sperson
                      AND pd.cagente = ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres)
                      AND TO_CHAR(m.fefepag, 'yyyy') = pany
                      AND TRUNC(m.fefepag) <=
                            NVL(pfperfin, m.fefepag)   -- Bug 15702 - RSC - 27/09/2010 - Models Fiscals: 347
                      AND m.cestpag = 2   --Pagos pagados
                      AND s.cagrpro IN(10, 21)   -- Rentas / Unit Linked
                      AND pg.ctippag = 2   -- RSC 07/01/2008 Excluimos pagos que tengan un
                                           -- pago de Anulación de pago
                      AND m.cestpag <> 8   -- Anulado -- RSC 07/01/2008 Excluimos
                                 -- pagos que tengan un pago
                                 -- de Anulación de pago
                      -- Para el nuevo modelo será excluir los pagos que estén anulados
                      AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 1) a
         ORDER BY cramo, cmodali, ctipseg, ccolect, nsinies, fpago;

      /*****************
          RENTAS
      *****************/
      CURSOR pagos_ren IS
         SELECT s.npoliza npoliza, s.ncertif ncertif, s.nsolici nsolici, s.cagente cagente,
                p.sperson, s.cramo cramo, s.cmodali cmodali, s.ctipseg ctipseg,
                s.ccolect ccolect, s.sproduc sproduc, s.sseguro sseguro, p.ffecpag fpago,
                p.iconret impneto, p.isinret impbruto, p.pretenc, p.iretenc retencion,
                p.ibase rcm, p.srecren
           FROM pagosrenta p, seguros s, movpagren m
          WHERE p.sseguro = s.sseguro
            AND s.cempres = NVL(pempres, 1)
            AND s.cagrpro = 10
            AND p.nremesa IS NOT NULL   -- RSC 30/10/2008 Que se encuentren pagados y no anulados!
            AND p.fremesa IS NOT NULL   -- RSC 30/10/2008 Que se encuentren pagados y no anulados!
            AND p.srecren = m.srecren
            AND m.fmovfin IS NULL
            AND m.cestrec = 1
            AND TO_CHAR(GREATEST(p.ffecpag, m.fmovini), 'yyyy') = pany;   --etm --BUG 15884 -CEM - Fe de Vida. Nuevos paquetes PLSQL

       /*Se modifica el cursor de rentas para que fiscalmente las rentas pagadas se consideren del ejercicio del pago*/
      --AND TO_CHAR(p.ffecpag, 'yyyy') = pany;
      vcobropart     NUMBER;
      vpais          NUMBER;
      vnumnif        VARCHAR2(14);
      vtidenti       NUMBER;
      vsseguro       NUMBER;
      vfechaaux      DATE;
      vispnofinanc_aux NUMBER;
      vsperson       NUMBER;
      -- 4/5/06 CPM Es crea la variable per recollir el resultat
      vresul         NUMBER;
      -- RSC 03/11/2008
      vsperson1      NUMBER;
      vnumnif1       VARCHAR2(14);
      vpais1         NUMBER;
      vffecfin1      DATE;
      vffecmue1      DATE;
      vfnacimi1      DATE;
      vtidenti1      NUMBER;
      vtestnif1      NUMBER;
      vsperson2      NUMBER;
      vnumnif2       VARCHAR2(14);
      vpais2         NUMBER;
      vffecfin2      DATE;
      vffecmue2      DATE;
      vfnacimi2      DATE;
      vtidenti2      NUMBER;
      vtestnif2      NUMBER;
      vspersonrep    NUMBER;
      vnnumnifrep    VARCHAR2(14);
      vfpeticion     DATE;
      vfnacimi       DATE;
      -- RSC 27/11/2008
      vsumsinret_ren NUMBER := 0;
      vsumrcm_ren    NUMBER := 0;
      -- RSC 10/12/2008
      vsproces       NUMBER;
      perror         NUMBER;
      vtexto         VARCHAR2(200);
      vnprolin       NUMBER;
      aport_execp    EXCEPTION;
      rentas_excep   EXCEPTION;
      vcontaerr      NUMBER := 0;
      vcontador      NUMBER := 0;
      vsperson_ax1   NUMBER;
      -- RSC 16/12/2008
      do_nothing     EXCEPTION;
      vtcausin       VARCHAR2(100);
      -- RSC 19/12/2008
      vauxinif       VARCHAR2(14);
      vhashcodeerr   pac_cierrefiscal_aru.assoc_array_error;
      verrprolin     VARCHAR2(120);
      verrcode       NUMBER;
      -- RSC 07/01/2008
      vorden         NUMBER;
      vpconsum_ircm  NUMBER;
      vpconsum_ireduc NUMBER;
      vpconsum_ireg_transcomp NUMBER;
      -- RSC 14/01/2008
      vcagente       NUMBER;
      vpersona       personas%ROWTYPE;
      vresult        NUMBER;
      -- Bug 17005 - RSC - 15/12/2010 - CEM800 - Ajustes modelos fiscales
      v_clave        VARCHAR2(1);
   -- Fin Bug 17005
   BEGIN
      IF psproces IS NULL THEN
         perror := f_procesini(getuser, pempres,
                               'CIERREFIS:' || TO_CHAR(f_sysdate, 'yyyymmdd'),
                               'CIERRE FISCAL AHORRO', vsproces);
      ELSE
         vsproces := psproces;
      END IF;

      --Inserción de la tabla FIS_DETCIERRECOBRO
      FOR apor IN aportaciones LOOP
         BEGIN
            --Aportaciones
            IF apor.cmovimi IN(1, 2, 4) THEN
               vcobropart := apor.imovimi;
            ELSE
               vcobropart := apor.imovimi * -1;
            END IF;

            -- 1 cabeza
            f_datos_asegurado(apor.sseguro, 1, vsperson1, vnumnif1, vfnacimi1, vpais1,
                              vffecfin1, vffecmue1, vtidenti1);
            -- 2 cabezas
            f_datos_asegurado(apor.sseguro, 2, vsperson2, vnumnif2, vfnacimi2, vpais2,
                              vffecfin2, vffecmue2, vtidenti2);

            IF vsperson2 IS NULL THEN   -- 1 cabeza
               perror := f_valida_nif_1cabeza(vsperson1, vtidenti1, apor.sseguro, vsproces,
                                              vnumnif1, vhashcodeerr);

               IF perror <> 0 THEN
                  RAISE aport_execp;
               END IF;

               INSERT INTO fis_detcierrecobro
                           (sfiscab, sfisdco, cramo, cmodali, ctipseg,
                            ccolect, pfiscal, sseguro, spersonp, nnumnifp,
                            nrecibo, fefecto, cpaisret, csubtipo, iaporpart,
                            iimporte, iaporprom, iaporsp, ctipapor)
                    VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali, apor.ctipseg,
                            apor.ccolect, pany, apor.sseguro, vsperson1, vnumnif1,
                            apor.nrecibo, apor.fvalmov, vpais1, NULL /*'347'*/, NULL,
                            vcobropart, NULL, NULL, NULL);
            -- En csubtipo ponemos NULL ya que no se si en este punto igual
            -- se deben crear varios modelos
            ELSE
               IF vffecmue1 IS NULL
                  AND vffecmue2 IS NULL THEN   -- Dos asegurados vivos
                  perror := f_trata_representante(vsperson1, vsperson2, vnumnif2,
                                                  apor.sseguro, apor.fvalmov, apor.sproduc,
                                                  vfnacimi1, vnumnif1, vtidenti1, vtidenti2,
                                                  vspersonrep, vnnumnifrep, vsproces,
                                                  vhashcodeerr);

                  IF perror <> 0 THEN
                     RAISE aport_execp;
                  END IF;

                  -- La mitad de la aportación para uno y la otra mitad para el otro
                  INSERT INTO fis_detcierrecobro
                              (sfiscab, sfisdco, cramo, cmodali,
                               ctipseg, ccolect, pfiscal, sseguro, spersonp,
                               nnumnifp, sperson1, nnumnif1, nrecibo, fefecto,
                               cpaisret, csubtipo, iaporpart, iimporte, iaporprom, iaporsp,
                               ctipapor)
                       VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali,
                               apor.ctipseg, apor.ccolect, pany, apor.sseguro, vsperson1,
                               vnumnif1, vspersonrep, vnnumnifrep, apor.nrecibo, apor.fvalmov,
                               vpais1, NULL, NULL,(vcobropart / 2), NULL, NULL,
                               NULL);

                  perror := f_trata_representante(vsperson2, vsperson1, vnumnif1, apor.sseguro,
                                                  apor.fvalmov, apor.sproduc, vfnacimi2,
                                                  vnumnif2, vtidenti2, vtidenti1, vspersonrep,
                                                  vnnumnifrep, vsproces, vhashcodeerr);

                  IF perror <> 0 THEN
                     RAISE aport_execp;
                  END IF;

                  INSERT INTO fis_detcierrecobro
                              (sfiscab, sfisdco, cramo, cmodali,
                               ctipseg, ccolect, pfiscal, sseguro, spersonp,
                               nnumnifp, sperson1, nnumnif1, nrecibo, fefecto,
                               cpaisret, csubtipo, iaporpart, iimporte, iaporprom, iaporsp,
                               ctipapor)
                       VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali,
                               apor.ctipseg, apor.ccolect, pany, apor.sseguro, vsperson2,
                               vnumnif2, vspersonrep, vnnumnifrep, apor.nrecibo, apor.fvalmov,
                               vpais2, NULL, NULL,(vcobropart / 2), NULL, NULL,
                               NULL);
               ELSIF vffecmue1 IS NOT NULL THEN
                  IF vffecmue1 > apor.fvalmov THEN
                     perror := f_trata_representante(vsperson1, vsperson2, vnumnif2,
                                                     apor.sseguro, apor.fvalmov, apor.sproduc,
                                                     vfnacimi1, vnumnif1, vtidenti1,
                                                     vtidenti2, vspersonrep, vnnumnifrep,
                                                     vsproces, vhashcodeerr);

                     IF perror <> 0 THEN
                        RAISE aport_execp;
                     END IF;

                     -- La mitad de la aportación para uno y la otra mitad para el otro
                     INSERT INTO fis_detcierrecobro
                                 (sfiscab, sfisdco, cramo, cmodali,
                                  ctipseg, ccolect, pfiscal, sseguro, spersonp,
                                  nnumnifp, sperson1, nnumnif1, nrecibo,
                                  fefecto, cpaisret, csubtipo, iaporpart, iimporte, iaporprom,
                                  iaporsp, ctipapor)
                          VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali,
                                  apor.ctipseg, apor.ccolect, pany, apor.sseguro, vsperson1,
                                  vnumnif1, vspersonrep, vnnumnifrep, apor.nrecibo,
                                  apor.fvalmov, vpais1, NULL, NULL,(vcobropart / 2), NULL,
                                  NULL, NULL);

                     perror := f_trata_representante(vsperson2, vsperson1, vnumnif1,
                                                     apor.sseguro, apor.fvalmov, apor.sproduc,
                                                     vfnacimi2, vnumnif2, vtidenti2, vtidenti1,
                                                     vspersonrep, vnnumnifrep, vsproces,
                                                     vhashcodeerr);

                     IF perror <> 0 THEN
                        RAISE aport_execp;
                     END IF;

                     INSERT INTO fis_detcierrecobro
                                 (sfiscab, sfisdco, cramo, cmodali,
                                  ctipseg, ccolect, pfiscal, sseguro, spersonp,
                                  nnumnifp, sperson1, nnumnif1, nrecibo,
                                  fefecto, cpaisret, csubtipo, iaporpart, iimporte, iaporprom,
                                  iaporsp, ctipapor)
                          VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali,
                                  apor.ctipseg, apor.ccolect, pany, apor.sseguro, vsperson2,
                                  vnumnif2, vspersonrep, vnnumnifrep, apor.nrecibo,
                                  apor.fvalmov, vpais2, NULL, NULL,(vcobropart / 2), NULL,
                                  NULL, NULL);
                  ELSE
                     INSERT INTO fis_detcierrecobro
                                 (sfiscab, sfisdco, cramo, cmodali,
                                  ctipseg, ccolect, pfiscal, sseguro, spersonp,
                                  nnumnifp, nrecibo, fefecto, cpaisret, csubtipo, iaporpart,
                                  iimporte, iaporprom, iaporsp, ctipapor)
                          VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali,
                                  apor.ctipseg, apor.ccolect, pany, apor.sseguro, vsperson2,
                                  vnumnif2, apor.nrecibo, apor.fvalmov, vpais2, NULL, NULL,
                                  vcobropart, NULL, NULL, NULL);
                  END IF;
               ELSIF vffecmue2 IS NOT NULL THEN
                  IF vffecmue2 > apor.fvalmov THEN
                     perror := f_trata_representante(vsperson1, vsperson2, vnumnif2,
                                                     apor.sseguro, apor.fvalmov, apor.sproduc,
                                                     vfnacimi1, vnumnif1, vtidenti1,
                                                     vtidenti2, vspersonrep, vnnumnifrep,
                                                     vsproces, vhashcodeerr);

                     IF perror <> 0 THEN
                        RAISE aport_execp;
                     END IF;

                     -- La mitad de la aportación para uno y la otra mitad para el otro
                     INSERT INTO fis_detcierrecobro
                                 (sfiscab, sfisdco, cramo, cmodali,
                                  ctipseg, ccolect, pfiscal, sseguro, spersonp,
                                  nnumnifp, sperson1, nnumnif1, nrecibo,
                                  fefecto, cpaisret, csubtipo, iaporpart, iimporte, iaporprom,
                                  iaporsp, ctipapor)
                          VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali,
                                  apor.ctipseg, apor.ccolect, pany, apor.sseguro, vsperson1,
                                  vnumnif1, vspersonrep, vnnumnifrep, apor.nrecibo,
                                  apor.fvalmov, vpais1, NULL, NULL,(vcobropart / 2), NULL,
                                  NULL, NULL);

                     perror := f_trata_representante(vsperson2, vsperson1, vnumnif1,
                                                     apor.sseguro, apor.fvalmov, apor.sproduc,
                                                     vfnacimi2, vnumnif2, vtidenti2, vtidenti1,
                                                     vspersonrep, vnnumnifrep, vsproces,
                                                     vhashcodeerr);

                     IF perror <> 0 THEN
                        RAISE aport_execp;
                     END IF;

                     INSERT INTO fis_detcierrecobro
                                 (sfiscab, sfisdco, cramo, cmodali,
                                  ctipseg, ccolect, pfiscal, sseguro, spersonp,
                                  nnumnifp, sperson1, nnumnif1, nrecibo,
                                  fefecto, cpaisret, csubtipo, iaporpart, iimporte, iaporprom,
                                  iaporsp, ctipapor)
                          VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali,
                                  apor.ctipseg, apor.ccolect, pany, apor.sseguro, vsperson2,
                                  vnumnif2, vspersonrep, vnnumnifrep, apor.nrecibo,
                                  apor.fvalmov, vpais2, NULL, NULL,(vcobropart / 2), NULL,
                                  NULL, NULL);
                  ELSE
                     INSERT INTO fis_detcierrecobro
                                 (sfiscab, sfisdco, cramo, cmodali,
                                  ctipseg, ccolect, pfiscal, sseguro, spersonp,
                                  nnumnifp, nrecibo, fefecto, cpaisret, csubtipo, iaporpart,
                                  iimporte, iaporprom, iaporsp, ctipapor)
                          VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali,
                                  apor.ctipseg, apor.ccolect, pany, apor.sseguro, vsperson1,
                                  vnumnif1, apor.nrecibo, apor.fvalmov, vpais1, NULL, NULL,
                                  vcobropart, NULL, NULL, NULL);
                  END IF;
               END IF;
            END IF;
         EXCEPTION
            WHEN aport_execp THEN
               vcontaerr := vcontaerr + 1;
         END;
      END LOOP;

      -- Para aquellos contratos que no han generado cualquier tipo de aportacion se debe grabar un registro
      -- con importes a 0 para que conste la informacion fiscal.
      vfechaaux := LAST_DAY(TO_DATE(pany || '12', 'YYYYMM'));

      --Inserción de la tabla FIS_DETCIERREPAGO
      /*************************
       SINIESTROS, RESCATES, etc
      **************************/
      FOR cur_pags IN pagos_sin LOOP
         BEGIN
            -- Siniestros, Rescates, Vencimientos
            --RSC 14/01/2008
            BEGIN
               SELECT cagente
                 INTO vcagente
                 FROM seguros
                WHERE sseguro = cur_pags.sseguro;

               vresult := pac_persona.f_get_dadespersona(cur_pags.sperson_pagosini, vcagente,
                                                         vpersona);
               vnumnif := vpersona.nnumide;
               vfnacimi := vpersona.fnacimi;
               vpais := vpersona.cpais;
               vtidenti := vpersona.ctipide;
            EXCEPTION
               WHEN OTHERS THEN
                  vnumnif := NULL;
                  vpais := NULL;
            END;

            -- Guardamos una copia del nif por si la necesitamos
            vauxinif := vnumnif;

            /* RSC 15/01/2008
             Los siniestros de fallecimiento de cualquier asegurado tributan por impuesto de sucesiones por eso
             solo deben pasar los siniestros que sean de PPA, los cuales si deben tributar por el modelo 190.
             Por eso no tenemos que informar de ningún error para esos casos que tributan por impuesto de
             sucesiones. */

            -- Bug 15702 - RSC - 28/09/2010 - Models Fiscals: 347
            -- En el cierre lo ponemos todo. En los modelos debemos discriminar.
            --IF cur_pags.ccausin IN(1) THEN
            --   -- Solo cogeremos los Siniestros de Fallecimiento de PPA
            --   IF NVL(f_parproductos_v(cur_pags.sproduc, 'PRESTACION'), 0) = 0 THEN
            --      RAISE aport_execp;
            --   END IF;
            --END IF;
            -- Fin Bug 15702

            -- RSC 16/12/2008 ---------------------------------------------------
            IF cur_pags.ccausin IN(3, 4) THEN   -- Vencimiento/Rescate en que
                                                -- destinatarios no es un asegurado
               SELECT COUNT(*)
                 INTO vcontador
                 FROM asegurados a
                WHERE sseguro = cur_pags.sseguro
                  AND sperson = cur_pags.sperson_pagosini
                  AND ffecfin IS NULL;   -- BUG11183:DRA:22/09/2009

               IF vcontador = 0 THEN   -- El destinatario no es ningún asegurado de la póliza
                  SELECT tcausin
                    INTO vtcausin
                    FROM causasini
                   WHERE ccausin = cur_pags.ccausin
                     AND cidioma = f_idiomauser;

                  SELECT f_axis_literales(101512, f_idiomauser) || '(Ccausin='
                         || cur_pags.ccausin || ') '
                         || pac_util.splitt(f_axis_literales(107710, f_idiomauser), 2, ' ')
                         || ' '
                         || pac_util.splitt(f_axis_literales(107710, f_idiomauser), 3, ' ')
                         || ' '
                         || pac_util.splitt(f_axis_literales(112331, f_idiomauser), 4, ' ')
                         || ' '
                         || pac_util.splitt(f_axis_literales(112331, f_idiomauser), 5, ' ')
                         || '.' || 'Pol=' || f_formatopolseg(cur_pags.sseguro) || ','
                         || 'Nsinies=' || cur_pags.nsinies || ',' || 'NIF=' || vnumnif || ','
                         || 'M=' || f_modelos_afectados(cur_pags.sseguro)
                    INTO verrprolin
                    FROM DUAL;

                  SELECT DBMS_UTILITY.get_hash_value(verrprolin, 1000000000, POWER(2, 30))
                    INTO verrcode
                    FROM DUAL;

                  IF vhashcodeerr.EXISTS(verrcode) THEN
                     NULL;
                  ELSE
                     perror := f_proceslin(vsproces, verrprolin, cur_pags.sseguro, vnprolin);
                     vhashcodeerr(verrcode) := 0;
                  END IF;

                  RAISE aport_execp;
               END IF;
            END IF;

---------------------------------------------------------------------
            IF cur_pags.ccausin IN(3, 4) THEN   -- Vencimientos / Rescates
               BEGIN
                  SELECT SUM(p.isinret), SUM(p.ibase)
                    INTO vsumsinret_ren, vsumrcm_ren
                    FROM pagosrenta p
                   WHERE p.sseguro = cur_pags.sseguro
                     AND pk_rentas.f_ult_estado_pago(p.srecren) = 1;
               EXCEPTION
                  WHEN OTHERS THEN
                     vsumsinret_ren := 0;
                     vsumrcm_ren := 0;
               END;
            ELSE
               vsumsinret_ren := 0;
               vsumrcm_ren := 0;
            END IF;

            -- Pretencs solo puede ser 0, 18 o 24
            --IF cur_pags.pretenc <> 0 OR cur_pags.pretenc <> 18 OR cur_pags.pretenc <> 24 THEN

            -- Bug 15702 - RSC - 28/09/2010 - Models Fiscals: 347
            /*
            IF NVL(f_parproductos_v(cur_pags.sproduc, 'PRESTACION'), 0) = 0 THEN
               IF f_valida_retencion(cur_pags.pretenc) <> 0 THEN
                  SELECT f_axis_literales(101426, f_idiomauser) || ' '
                         || pac_util.splitt(f_axis_literales(105282, f_idiomauser), 2, ' ') || '.'
                         || 'Pol=' || f_formatopolseg(cur_pags.sseguro) || ',' || 'Nsinies='
                         || cur_pags.nsinies || ',' || 'NIF=' || vnumnif || ',' || 'M='
                         || f_modelos_afectados(cur_pags.sseguro)
                    INTO verrprolin
                    FROM DUAL;

                  SELECT DBMS_UTILITY.get_hash_value(verrprolin, 1000000000, POWER(2, 30))
                    INTO verrcode
                    FROM DUAL;

                  IF vhashcodeerr.EXISTS(verrcode) THEN
                     NULL;
                  ELSE
                     perror := f_proceslin(vsproces, verrprolin, cur_pags.sseguro, vnprolin);
                     vhashcodeerr(verrcode) := 0;
                  END IF;

                  RAISE aport_execp;
               END IF;
            END IF;
            */
            IF cur_pags.ccausin IN(3, 4) THEN
               BEGIN
                  SELECT norden
                    INTO vorden
                    FROM asegurados
                   WHERE sperson = cur_pags.sperson_pagosini
                     AND sseguro = cur_pags.sseguro   -- BUG11183:DRA:22/09/2009
                     AND ffecfin IS NULL;   -- BUG11183:DRA:22/09/2009
               EXCEPTION
                  WHEN OTHERS THEN
                     vorden := 1;
               END;

               BEGIN
                  SELECT SUM(ircm), SUM(ireduc), SUM(ireg_transcomp)
                    INTO vpconsum_ircm, vpconsum_ireduc, vpconsum_ireg_transcomp
                    FROM primas_consumidas
                   WHERE sseguro = cur_pags.sseguro
                     AND nriesgo = vorden;
               EXCEPTION
                  WHEN OTHERS THEN
                     vpconsum_ircm := NULL;
                     vpconsum_ireduc := NULL;
                     vpconsum_ireg_transcomp := NULL;
               END;
            ELSE
               vpconsum_ircm := NULL;
               vpconsum_ireduc := NULL;
               vpconsum_ireg_transcomp := NULL;
            END IF;

            -- Bug 17005 - RSC - 15/12/2010 - CEM800 - Ajustes modelos fiscales
            SELECT DECODE(NVL(f_parproductos_v(cur_pags.sproduc, 'TIPO_LIMITE'), 0),
                          1, DECODE(NVL(cur_pags.reduc, 0), 0, ' ', 'B'),
                          DECODE(NVL((SUM(NVL(vpconsum_ircm, 0)) - SUM(NVL(vpconsum_ireduc, 0))
                                      - SUM(NVL(vpconsum_ireg_transcomp, 0))),
                                     0),
                                 0, ' ',
                                 'A'))
              INTO v_clave
              FROM DUAL;

            -- Fin Bug 17005
            INSERT INTO fis_detcierrepago
                        (sfiscab, sfisdpa, cramo, cmodali,
                         ctipseg, ccolect, pfiscal, sseguro,
                         spersonp, nnumnifp, fpago,
                         cpaisret, csubtipo, iresred, iresrcm,
                         pretenc, iretenc, ibruto,
                         ineto, ctipcap, sidepag,
                         csigbase, rentastribut, rcmtribut,
                         ctipo,
                         pconsum_ircm, pconsum_ireduc, pconsum_ireg_transcomp, clave)
                 VALUES (psfiscab, sfisdpa.NEXTVAL, cur_pags.cramo, cur_pags.cmodali,
                         cur_pags.ctipseg, cur_pags.ccolect, pany, cur_pags.sseguro,
                         cur_pags.sperson_pagosini, vnumnif, cur_pags.fpago,
                         cur_pags.cpaisresid, NULL, cur_pags.reduc, cur_pags.rcm,
                         cur_pags.pretenc, cur_pags.retencion, cur_pags.impbruto,
                         cur_pags.importe, 1, cur_pags.sidepag,
                         DECODE(SIGN(cur_pags.rcm), -1, 'N', 'P'), vsumsinret_ren, vsumrcm_ren,
                         DECODE(cur_pags.ccausin,
                                1, 'SIN',
                                8, 'TRS',
                                3, 'VTO',
                                4, 'RTO',
                                5, 'RPA',
                                NULL),
                         vpconsum_ircm, vpconsum_ireduc, vpconsum_ireg_transcomp, v_clave);
         EXCEPTION
            WHEN aport_execp THEN
               vcontaerr := vcontaerr + 1;
         END;
      END LOOP;

      /*****************
            RENTAS
      *****************/
      FOR cur_pags_ren IN pagos_ren LOOP
         BEGIN
            -- 1 cabeza
            f_datos_asegurado(cur_pags_ren.sseguro, 1, vsperson1, vnumnif1, vfnacimi1, vpais1,
                              vffecfin1, vffecmue1, vtidenti1);
            -- 2 cabezas
            f_datos_asegurado(cur_pags_ren.sseguro, 2, vsperson2, vnumnif2, vfnacimi2, vpais2,
                              vffecfin2, vffecmue2, vtidenti2);

            -- ini Bug 0012822 - 24/02/2010 - JMF
            IF NVL(f_parproductos_v(cur_pags_ren.sproduc, 'FISCALIDAD_2_CABEZAS'), 0) = 1 THEN
               -- Para el caso de fiscalidad 2 cabezas, lo tratamos igual que 1 cabeza,
               -- ya que en el cursor ya tendremos la información correcta de persona e importes.
               DECLARE
                  n_numase       asegurados.norden%TYPE;
               BEGIN
                  SELECT MAX(norden)
                    INTO n_numase
                    FROM asegurados
                   WHERE sseguro = cur_pags_ren.sseguro
                     AND sperson = cur_pags_ren.sperson;

                  f_datos_asegurado(cur_pags_ren.sseguro, n_numase, vsperson1, vnumnif1,
                                    vfnacimi1, vpais1, vffecfin1, vffecmue1, vtidenti1);
                  vsperson2 := NULL;
               END;
            END IF;

            -- fin Bug 0012822 - 24/02/2010 - JMF

            -- Bug 17005 - RSC - 15/12/2010 - CEM800 - Ajustes modelos fiscales
            SELECT DECODE(NVL(f_parproductos_v(cur_pags_ren.sproduc, 'TIPO_LIMITE'), 0),
                          1, DECODE(NVL(NULL, 0), 0, ' ', 'B'),
                          DECODE(NVL((SUM(NVL(cur_pags_ren.rcm, 0)) - SUM(NVL(NULL, 0))
                                      - SUM(NVL(NULL, 0))),
                                     0),
                                 0, ' ',
                                 'A'))
              INTO v_clave
              FROM DUAL;

            -- Fin Bug 17005

            -- 1 cabeza
            IF vsperson2 IS NULL THEN
               perror := f_valida_nif_1cabeza(vsperson1, vtidenti1, cur_pags_ren.sseguro,
                                              vsproces, vnumnif1, vhashcodeerr);

               IF perror <> 0 THEN
                  RAISE rentas_excep;
               END IF;

               INSERT INTO fis_detcierrepago
                           (sfiscab, sfisdpa, cramo,
                            cmodali, ctipseg, ccolect,
                            pfiscal, sseguro, spersonp, nnumnifp,
                            fpago, cpaisret, csubtipo, iresred, pretenc,
                            iretenc, ibruto,
                            ineto, ibase, iresrcm, ctipcap,
                            sidepag, csigbase,
                            ctipo)
                    VALUES (psfiscab, sfisdpa.NEXTVAL, cur_pags_ren.cramo,
                            cur_pags_ren.cmodali, cur_pags_ren.ctipseg, cur_pags_ren.ccolect,
                            pany, cur_pags_ren.sseguro, vsperson1, vnumnif1,
                            cur_pags_ren.fpago, vpais1, NULL, NULL, cur_pags_ren.pretenc,
                            cur_pags_ren.retencion, cur_pags_ren.impbruto,
                            cur_pags_ren.impneto, cur_pags_ren.rcm, cur_pags_ren.rcm, 2,
                            cur_pags_ren.srecren, DECODE(SIGN(cur_pags_ren.rcm), -1, 'N', 'P'),
                            'REN');
            ELSE
               -- 2 cabezas
               IF vffecmue1 IS NULL
                  AND vffecmue2 IS NULL THEN   -- Dos asegurados vivos
                  perror := f_trata_representante(vsperson1, vsperson2, vnumnif2,
                                                  cur_pags_ren.sseguro, cur_pags_ren.fpago,
                                                  cur_pags_ren.sproduc, vfnacimi1, vnumnif1,
                                                  vtidenti1, vtidenti2, vspersonrep,
                                                  vnnumnifrep, vsproces, vhashcodeerr);

                  IF perror <> 0 THEN
                     RAISE rentas_excep;
                  END IF;

                  INSERT INTO fis_detcierrepago
                              (sfiscab, sfisdpa, cramo,
                               cmodali, ctipseg,
                               ccolect, pfiscal, sseguro, spersonp,
                               nnumnifp, sperson1, nnumnif1, fpago, cpaisret,
                               csubtipo, iresred, pretenc, iretenc,
                               ibruto, ineto,
                               ibase, iresrcm, ctipcap,
                               sidepag,
                               csigbase, ctipo)
                       VALUES (psfiscab, sfisdpa.NEXTVAL, cur_pags_ren.cramo,
                               cur_pags_ren.cmodali, cur_pags_ren.ctipseg,
                               cur_pags_ren.ccolect, pany, cur_pags_ren.sseguro, vsperson1,
                               vnumnif1, vspersonrep, vnnumnifrep, cur_pags_ren.fpago, vpais1,
                               NULL, NULL, cur_pags_ren.pretenc,(cur_pags_ren.retencion / 2),
                               (cur_pags_ren.impbruto / 2),(cur_pags_ren.impneto / 2),
                               (cur_pags_ren.rcm / 2),(cur_pags_ren.rcm / 2), 2,
                               cur_pags_ren.srecren,
                               DECODE(SIGN(cur_pags_ren.rcm), -1, 'N', 'P'), 'REN');

                  perror := f_trata_representante(vsperson2, vsperson1, vnumnif1,
                                                  cur_pags_ren.sseguro, cur_pags_ren.fpago,
                                                  cur_pags_ren.sproduc, vfnacimi2, vnumnif2,
                                                  vtidenti2, vtidenti1, vspersonrep,
                                                  vnnumnifrep, vsproces, vhashcodeerr);

                  IF perror <> 0 THEN
                     RAISE rentas_excep;
                  END IF;

                  INSERT INTO fis_detcierrepago
                              (sfiscab, sfisdpa, cramo,
                               cmodali, ctipseg,
                               ccolect, pfiscal, sseguro, spersonp,
                               nnumnifp, sperson1, nnumnif1, fpago, cpaisret,
                               csubtipo, iresred, pretenc, iretenc,
                               ibruto, ineto,
                               ibase, iresrcm, ctipcap,
                               sidepag,
                               csigbase, ctipo)
                       VALUES (psfiscab, sfisdpa.NEXTVAL, cur_pags_ren.cramo,
                               cur_pags_ren.cmodali, cur_pags_ren.ctipseg,
                               cur_pags_ren.ccolect, pany, cur_pags_ren.sseguro, vsperson2,
                               vnumnif2, vspersonrep, vnnumnifrep, cur_pags_ren.fpago, vpais1,
                               NULL, NULL, cur_pags_ren.pretenc,(cur_pags_ren.retencion / 2),
                               (cur_pags_ren.impbruto / 2),(cur_pags_ren.impneto / 2),
                               (cur_pags_ren.rcm / 2),(cur_pags_ren.rcm / 2), 2,
                               cur_pags_ren.srecren,
                               DECODE(SIGN(cur_pags_ren.rcm), -1, 'N', 'P'), 'REN');
               ELSIF vffecmue1 IS NOT NULL THEN
                  IF vffecmue1 > cur_pags_ren.fpago THEN
                     perror := f_trata_representante(vsperson1, vsperson2, vnumnif2,
                                                     cur_pags_ren.sseguro, cur_pags_ren.fpago,
                                                     cur_pags_ren.sproduc, vfnacimi1,
                                                     vnumnif1, vtidenti1, vtidenti2,
                                                     vspersonrep, vnnumnifrep, vsproces,
                                                     vhashcodeerr);

                     IF perror <> 0 THEN
                        RAISE rentas_excep;
                     END IF;

                     INSERT INTO fis_detcierrepago
                                 (sfiscab, sfisdpa, cramo,
                                  cmodali, ctipseg,
                                  ccolect, pfiscal, sseguro, spersonp,
                                  nnumnifp, sperson1, nnumnif1, fpago,
                                  cpaisret, csubtipo, iresred, pretenc,
                                  iretenc, ibruto,
                                  ineto, ibase,
                                  iresrcm, ctipcap, sidepag,
                                  csigbase, ctipo)
                          VALUES (psfiscab, sfisdpa.NEXTVAL, cur_pags_ren.cramo,
                                  cur_pags_ren.cmodali, cur_pags_ren.ctipseg,
                                  cur_pags_ren.ccolect, pany, cur_pags_ren.sseguro, vsperson1,
                                  vnumnif1, vspersonrep, vnnumnifrep, cur_pags_ren.fpago,
                                  vpais1, NULL, NULL, cur_pags_ren.pretenc,
                                  (cur_pags_ren.retencion / 2),(cur_pags_ren.impbruto / 2),
                                  (cur_pags_ren.impneto / 2),(cur_pags_ren.rcm / 2),
                                  (cur_pags_ren.rcm / 2), 2, cur_pags_ren.srecren,
                                  DECODE(SIGN(cur_pags_ren.rcm), -1, 'N', 'P'), 'REN');

                     perror := f_trata_representante(vsperson2, vsperson1, vnumnif1,
                                                     cur_pags_ren.sseguro, cur_pags_ren.fpago,
                                                     cur_pags_ren.sproduc, vfnacimi2, vnumnif2,
                                                     vtidenti2, vtidenti1, vspersonrep,
                                                     vnnumnifrep, vsproces, vhashcodeerr);

                     IF perror <> 0 THEN
                        RAISE rentas_excep;
                     END IF;

                     INSERT INTO fis_detcierrepago
                                 (sfiscab, sfisdpa, cramo,
                                  cmodali, ctipseg,
                                  ccolect, pfiscal, sseguro, spersonp,
                                  nnumnifp, sperson1, nnumnif1, fpago,
                                  cpaisret, csubtipo, iresred, pretenc,
                                  iretenc, ibruto,
                                  ineto, ibase,
                                  iresrcm, ctipcap, sidepag,
                                  csigbase, ctipo)
                          VALUES (psfiscab, sfisdpa.NEXTVAL, cur_pags_ren.cramo,
                                  cur_pags_ren.cmodali, cur_pags_ren.ctipseg,
                                  cur_pags_ren.ccolect, pany, cur_pags_ren.sseguro, vsperson2,
                                  vnumnif2, vspersonrep, vnnumnifrep, cur_pags_ren.fpago,
                                  vpais1, NULL, NULL, cur_pags_ren.pretenc,
                                  (cur_pags_ren.retencion / 2),(cur_pags_ren.impbruto / 2),
                                  (cur_pags_ren.impneto / 2),(cur_pags_ren.rcm / 2),
                                  (cur_pags_ren.rcm / 2), 2, cur_pags_ren.srecren,
                                  DECODE(SIGN(cur_pags_ren.rcm), -1, 'N', 'P'), 'REN');
                  ELSE
                     INSERT INTO fis_detcierrepago
                                 (sfiscab, sfisdpa, cramo,
                                  cmodali, ctipseg,
                                  ccolect, pfiscal, sseguro,
                                  spersonp, nnumnifp, fpago, cpaisret, csubtipo,
                                  iresred, pretenc, iretenc,
                                  ibruto, ineto,
                                  ibase, iresrcm, ctipcap,
                                  sidepag,
                                  csigbase, ctipo)
                          VALUES (psfiscab, sfisdpa.NEXTVAL, cur_pags_ren.cramo,
                                  cur_pags_ren.cmodali, cur_pags_ren.ctipseg,
                                  cur_pags_ren.ccolect, pany, cur_pags_ren.sseguro,
                                  vsperson2, vnumnif2, cur_pags_ren.fpago, vpais1, NULL,
                                  NULL, cur_pags_ren.pretenc, cur_pags_ren.retencion,
                                  cur_pags_ren.impbruto, cur_pags_ren.impneto,
                                  cur_pags_ren.rcm, cur_pags_ren.rcm, 2,
                                  cur_pags_ren.srecren,
                                  DECODE(SIGN(cur_pags_ren.rcm), -1, 'N', 'P'), 'REN');
                  END IF;
               ELSIF vffecmue2 IS NOT NULL THEN
                  IF vffecmue2 > cur_pags_ren.fpago THEN
                     perror := f_trata_representante(vsperson1, vsperson2, vnumnif2,
                                                     cur_pags_ren.sseguro, cur_pags_ren.fpago,
                                                     cur_pags_ren.sproduc, vfnacimi1,
                                                     vnumnif1, vtidenti1, vtidenti2,
                                                     vspersonrep, vnnumnifrep, vsproces,
                                                     vhashcodeerr);

                     IF perror <> 0 THEN
                        RAISE rentas_excep;
                     END IF;

                     INSERT INTO fis_detcierrepago
                                 (sfiscab, sfisdpa, cramo,
                                  cmodali, ctipseg,
                                  ccolect, pfiscal, sseguro, spersonp,
                                  nnumnifp, sperson1, nnumnif1, fpago,
                                  cpaisret, csubtipo, iresred, pretenc,
                                  iretenc, ibruto,
                                  ineto, ibase,
                                  iresrcm, ctipcap, sidepag,
                                  csigbase, ctipo)
                          VALUES (psfiscab, sfisdpa.NEXTVAL, cur_pags_ren.cramo,
                                  cur_pags_ren.cmodali, cur_pags_ren.ctipseg,
                                  cur_pags_ren.ccolect, pany, cur_pags_ren.sseguro, vsperson1,
                                  vnumnif1, vspersonrep, vnnumnifrep, cur_pags_ren.fpago,
                                  vpais1, NULL, NULL, cur_pags_ren.pretenc,
                                  (cur_pags_ren.retencion / 2),(cur_pags_ren.impbruto / 2),
                                  (cur_pags_ren.impneto / 2),(cur_pags_ren.rcm / 2),
                                  (cur_pags_ren.rcm / 2), 2, cur_pags_ren.srecren,
                                  DECODE(SIGN(cur_pags_ren.rcm), -1, 'N', 'P'), 'REN');

                     perror := f_trata_representante(vsperson2, vsperson1, vnumnif1,
                                                     cur_pags_ren.sseguro, cur_pags_ren.fpago,
                                                     cur_pags_ren.sproduc, vfnacimi2, vnumnif2,
                                                     vtidenti2, vtidenti1, vspersonrep,
                                                     vnnumnifrep, vsproces, vhashcodeerr);

                     IF perror <> 0 THEN
                        RAISE rentas_excep;
                     END IF;

                     INSERT INTO fis_detcierrepago
                                 (sfiscab, sfisdpa, cramo,
                                  cmodali, ctipseg,
                                  ccolect, pfiscal, sseguro, spersonp,
                                  nnumnifp, sperson1, nnumnif1, fpago,
                                  cpaisret, csubtipo, iresred, pretenc,
                                  iretenc, ibruto,
                                  ineto, ibase,
                                  iresrcm, ctipcap, sidepag,
                                  csigbase, ctipo)
                          VALUES (psfiscab, sfisdpa.NEXTVAL, cur_pags_ren.cramo,
                                  cur_pags_ren.cmodali, cur_pags_ren.ctipseg,
                                  cur_pags_ren.ccolect, pany, cur_pags_ren.sseguro, vsperson2,
                                  vnumnif2, vspersonrep, vnnumnifrep, cur_pags_ren.fpago,
                                  vpais1, NULL, NULL, cur_pags_ren.pretenc,
                                  (cur_pags_ren.retencion / 2),(cur_pags_ren.impbruto / 2),
                                  (cur_pags_ren.impneto / 2),(cur_pags_ren.rcm / 2),
                                  (cur_pags_ren.rcm / 2), 2, cur_pags_ren.srecren,
                                  DECODE(SIGN(cur_pags_ren.rcm), -1, 'N', 'P'), 'REN');
                  ELSE
                     INSERT INTO fis_detcierrepago
                                 (sfiscab, sfisdpa, cramo,
                                  cmodali, ctipseg,
                                  ccolect, pfiscal, sseguro,
                                  spersonp, nnumnifp, fpago, cpaisret, csubtipo,
                                  iresred, pretenc, iretenc,
                                  ibruto, ineto,
                                  ibase, iresrcm, ctipcap,
                                  sidepag,
                                  csigbase, ctipo)
                          VALUES (psfiscab, sfisdpa.NEXTVAL, cur_pags_ren.cramo,
                                  cur_pags_ren.cmodali, cur_pags_ren.ctipseg,
                                  cur_pags_ren.ccolect, pany, cur_pags_ren.sseguro,
                                  vsperson1, vnumnif1, cur_pags_ren.fpago, vpais1, NULL,
                                  NULL, cur_pags_ren.pretenc, cur_pags_ren.retencion,
                                  cur_pags_ren.impbruto, cur_pags_ren.impneto,
                                  cur_pags_ren.rcm, cur_pags_ren.rcm, 2,
                                  cur_pags_ren.srecren,
                                  DECODE(SIGN(cur_pags_ren.rcm), -1, 'N', 'P'), 'REN');
                  END IF;
               END IF;
            END IF;
         EXCEPTION
            WHEN rentas_excep THEN
               vcontaerr := vcontaerr + 1;
            WHEN do_nothing THEN
               NULL;
         END;
      END LOOP;

      IF psproces IS NULL THEN
         -- Finalizamos proces
         perror := f_procesfin(vsproces, vcontaerr);
      END IF;

      -- 21/4/08 RSC
      vresul := f_calculo_planfiscal_rentas(pany);

      IF vresul = 0 THEN
         RETURN 0;
      END IF;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'CIERRE FISCAL Cierre_Fis_Ren_Ulk', NULL,
                     'when others del cierre =' || psfiscab, SQLERRM);
         RETURN NULL;
   END cierre_fis_ren_ulk;

   /*------------------------------------------------------------------------------
     P_Caculo_PlanFiscal
     21/04/2008 RSC
     Procediment per calcular els registres fiscals definitius una vegada tancat
     l'any fiscal
   ------------------------------------------------------------------------------*/
   FUNCTION f_calculo_planfiscal_aho(pany IN VARCHAR2)
      RETURN NUMBER IS
      vprovmat       NUMBER;

      CURSOR cur_aho IS
         SELECT   x.sseguro, pany, SUM(NVL(iimporte, 0)) primas_anuales,
                  SUM(NVL(iaporprom, 0)), SUM(NVL(iaporsp, 0)), SUM(NVL(iaporpart, 0)),
                  SUM(NVL(iretenc, 0)) retenciones, SUM(NVL(iresred, 0)) reducciones,
                  SUM(NVL(iresrcm, 0)) rcm,
                  (SUM(NVL(ibruto, 0)) - SUM(NVL(iretenc, 0))) rescate
             FROM (SELECT sseguro, iimporte, iaporprom, iaporsp, iaporpart, 0 iretenc,
                          0 pretenc, 0 iresred, 0 iresrcm, 0 ibruto
                     FROM fis_detcierrecobro
                    WHERE pfiscal = pany
                   UNION ALL
                   SELECT sseguro, 0 iimporte, 0 iaporprom, 0 iaporsp, 0 iaporpart, iretenc,
                          pretenc, iresred, iresrcm, ibruto
                     FROM fis_detcierrepago
                    WHERE pfiscal = pany
                      AND ctipcap = 1) x
                  JOIN
                  seguros s ON x.sseguro = s.sseguro
            WHERE s.cagrpro = 2
         GROUP BY x.sseguro;
   BEGIN
      FOR regs IN cur_aho LOOP
         --vprovmat := PAC_PROVMAT_FORMUL.F_CALCUL_FORMULAS_PROVI(regs.sseguro,to_date('31/12/'||pany), 'IPROVAC');
         BEGIN
            SELECT p.ipromat
              INTO vprovmat
              FROM provmat p
             WHERE p.sseguro = regs.sseguro
               AND p.fcalcul = TO_DATE('31/12/' || pany, 'dd/mm/yyyy');
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               -- Todavia no se ha realizado el cierre de provisiones de Diciembre
               vprovmat := 0;
         END;

         INSERT INTO planfiscal
                     (sseguro, nano, derechos, aporprom, aporsp,
                      aporparti, retencion, ineto, iresred,
                      iresrcm, rentaneta_ren, iresrcm_ren, retencion_ren)
              VALUES (regs.sseguro, TO_NUMBER(pany), vprovmat, NULL, NULL,
                      regs.primas_anuales, regs.retenciones, regs.rescate, regs.reducciones,
                      regs.rcm, 0, 0, 0);
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'p_calculo_planfiscal', NULL,
                     'when others; pany =' || pany, SQLERRM);
         RETURN NULL;
   END f_calculo_planfiscal_aho;

   /*------------------------------------------------------------------------------
     P_Caculo_PlanFiscal_rentas
     21/04/2008 RSC
     Procediment per calcular els registres fiscals definitius una vegada tancat
     l'any fiscal per als productes de rentes.
   ------------------------------------------------------------------------------*/
   FUNCTION f_calculo_planfiscal_rentas(pany IN VARCHAR2)
      RETURN NUMBER IS
      vprovmat       NUMBER;

      CURSOR cur_rentas IS
         SELECT y.sseguro, pany, iaporprom, aportsp, primas_anuales, retenciones, rescates,
                reducciones, rcm, renta_anual, rcm_ren, retenciones_ren
           FROM (SELECT   x.sseguro, SUM(NVL(iimporte, 0)) primas_anuales,
                          SUM(NVL(iaporprom, 0)) iaporprom, SUM(NVL(iaporsp, 0)) aportsp,
                          SUM(NVL(iaporpart, 0)) iaporpart, SUM(NVL(iretenc, 0)) retenciones,
                          SUM(NVL(iresred, 0)) reducciones,
                          SUM(NVL(ibruto, 0)) - SUM(NVL(iretenc, 0)) rescates,
                          SUM(NVL(iresrcm, 0)) rcm
                     FROM (SELECT sseguro, iimporte, iaporprom, iaporsp, iaporpart, 0 iretenc,
                                  0 pretenc, 0 iresred, 0 iresrcm, 0 ibruto
                             FROM fis_detcierrecobro
                            WHERE pfiscal = pany
                           UNION ALL
                           SELECT sseguro, 0 iimporte, 0 iaporprom, 0 iaporsp, 0 iaporpart,
                                  iretenc, pretenc, iresred, iresrcm, ibruto
                             FROM fis_detcierrepago
                            WHERE pfiscal = pany
                              AND ctipcap = 1   -- ctipcap = 1 === Siniestros / Rescates
                                             ) x
                          JOIN
                          seguros s ON x.sseguro = s.sseguro
                    WHERE s.cagrpro IN(10, 21)
                 GROUP BY x.sseguro) y
                LEFT JOIN
                (SELECT   x.sseguro, SUM(NVL(iretenc, 0)) retenciones_ren,
                          SUM(NVL(iresred, 0)) reducciones_ren,
                          SUM(NVL(ibruto, 0)) - SUM(NVL(iretenc, 0)) renta_anual,
                          SUM(NVL(iresrcm, 0)) rcm_ren
                     FROM (SELECT sseguro, 0 iimporte, 0 iaporprom, 0 iaporsp, 0 iaporpart,
                                  iretenc, pretenc, iresred, iresrcm, ibruto
                             FROM fis_detcierrepago
                            WHERE pfiscal = pany
                              AND ctipcap = 2   -- ctipcap = 2 === Pagos de renta
                                             ) x
                          JOIN
                          seguros s ON x.sseguro = s.sseguro
                    WHERE s.cagrpro IN(10, 21)
                 GROUP BY x.sseguro) z ON y.sseguro = z.sseguro
                ;

      vtraza         NUMBER;
   BEGIN
      vtraza := 1;

      FOR regs IN cur_rentas LOOP
         vtraza := 2;

         --IF regs.renta_anual IS NOT NULL THEN

         --vprovmat := PAC_PROVMAT_FORMUL.F_CALCUL_FORMULAS_PROVI(regs.sseguro,to_date('31/12/'||pany), 'IPROVAC');
         BEGIN
            SELECT p.ipromat
              INTO vprovmat
              FROM provmat p
             WHERE p.sseguro = regs.sseguro
               AND p.fcalcul = TO_DATE('31/12/' || pany, 'dd/mm/yyyy');
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               -- Todavia no se ha realizado el cierre de provisiones de Diciembre
               vprovmat := 0;
         END;

         INSERT INTO planfiscal
                     (sseguro, nano, derechos, aporprom, aporsp,
                      aporparti, retencion, ineto, iresred,
                      iresrcm, rentaneta_ren, iresrcm_ren, retencion_ren)
              VALUES (regs.sseguro, TO_NUMBER(pany), vprovmat, NULL, NULL,
                      regs.primas_anuales, regs.retenciones, regs.rescates, regs.reducciones,
                      regs.rcm, regs.renta_anual, regs.rcm_ren, regs.retenciones_ren);
      --END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'p_calculo_planfiscal', vtraza,
                     'when others; pany =' || pany, SQLERRM);
         RETURN NULL;
   END f_calculo_planfiscal_rentas;

   FUNCTION f_trata_representante(
      vsperson1 IN NUMBER,
      vsperson2 IN NUMBER,
      vnumnif2 IN OUT VARCHAR2,
      psseguro IN NUMBER,
      pfvalmov IN DATE,
      psproduc IN NUMBER,
      vfnacimi1 IN DATE,
      vnumnif1 IN OUT VARCHAR2,
      vtidenti1 IN OUT VARCHAR2,
      vtidenti2 IN OUT VARCHAR2,
      vspersonrep IN OUT NUMBER,
      vnnumnifrep IN OUT VARCHAR2,
      vsproces IN NUMBER,
      vhashcodeerr IN OUT pac_cierrefiscal_aru.assoc_array_error)
      RETURN NUMBER IS
      perror         NUMBER;
      vnprolin       NUMBER;
      vauxnif        VARCHAR2(14);
      -- RSC 19/12/2008
      verrprolin     VARCHAR2(120);
      verrcode       NUMBER;
   BEGIN
      vauxnif := vnumnif1;
      vspersonrep := NULL;
      vnnumnifrep := NULL;

      IF vtidenti1 NOT IN(1, 4, 5) THEN
         BEGIN
            SELECT nnumide
              INTO vnumnif1
              FROM per_identifica
             WHERE sperson = vsperson1
               AND ctipide = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT nnumide
                    INTO vnumnif1
                    FROM per_identifica
                   WHERE sperson = vsperson1
                     AND ctipide = 4;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                        SELECT nnumide
                          INTO vnumnif1
                          FROM per_identifica
                         WHERE sperson = vsperson1
                           AND ctipide = 5;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           vnumnif1 := NULL;
                     END;
               END;
         END;

         IF f_nif(vnumnif1) <> 0 THEN
            IF fedad(1, TO_NUMBER(TO_CHAR(vfnacimi1, 'yyyymmdd')),
                     TO_NUMBER(TO_CHAR(pfvalmov, 'yyyymmdd')), 2) <
                                          NVL(f_parproductos_v(psproduc, 'EDADLIMFISCAL'), 14) THEN
               IF vnumnif2 IS NOT NULL THEN
                  perror := f_valida_nif_1cabeza(vsperson2, vtidenti2, psseguro, vsproces,
                                                 vnumnif2, vhashcodeerr);   -- Validamos el NIF del respresentante

                  IF perror <> 0 THEN
                     RETURN perror;
                  END IF;

                  vnumnif1 := NULL;   -- Si se informa representante legal el campo NNUMNIF debe ser blanco
                  vspersonrep := vsperson2;
                  vnnumnifrep := vnumnif2;
               ELSE
                  SELECT f_axis_literales(180905, f_idiomauser) || '.' || 'Pol='
                         || f_formatopolseg(psseguro) || ',' || 'NIF=' || vauxnif || ','
                         || 'M=' || f_modelos_afectados(psseguro)
                    INTO verrprolin
                    FROM DUAL;

                  SELECT DBMS_UTILITY.get_hash_value(verrprolin, 1000000000, POWER(2, 30))
                    INTO verrcode
                    FROM DUAL;

                  IF vhashcodeerr.EXISTS(verrcode) THEN
                     NULL;
                  ELSE
                     perror := f_proceslin(vsproces, verrprolin, psseguro, vnprolin);
                     vhashcodeerr(verrcode) := 0;
                  END IF;

                  RETURN 180905;
               END IF;
            ELSE
               SELECT f_axis_literales(180912, f_idiomauser) || 'Pol='
                      || f_formatopolseg(psseguro) || ',' || 'Fnacimi=' || vfnacimi1 || ','
                      || 'NIF=' || vauxnif || ',' || 'M=' || f_modelos_afectados(psseguro)
                 INTO verrprolin
                 FROM DUAL;

               SELECT DBMS_UTILITY.get_hash_value(verrprolin, 1000000000, POWER(2, 30))
                 INTO verrcode
                 FROM DUAL;

               IF vhashcodeerr.EXISTS(verrcode) THEN
                  NULL;
               ELSE
                  perror := f_proceslin(vsproces, verrprolin, psseguro, vnprolin);
                  vhashcodeerr(verrcode) := 0;
               END IF;

               RETURN 180907;
            END IF;
         END IF;
      ELSE
         IF f_nif(vnumnif1) <> 0 THEN   -- NIF o NIE
            BEGIN
               SELECT nnumide
                 INTO vnumnif1
                 FROM per_identifica
                WHERE sperson = vsperson1
                  AND ctipide = 1;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT nnumide
                       INTO vnumnif1
                       FROM per_identifica
                      WHERE sperson = vsperson1
                        AND ctipide = 4;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        BEGIN
                           SELECT nnumide
                             INTO vnumnif1
                             FROM per_identifica
                            WHERE sperson = vsperson1
                              AND ctipide = 5;
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              vnumnif1 := NULL;
                        END;
                  END;
            END;

            IF f_nif(vnumnif1) <> 0 THEN
               IF fedad(1, TO_NUMBER(TO_CHAR(vfnacimi1, 'yyyymmdd')),
                        TO_NUMBER(TO_CHAR(pfvalmov, 'yyyymmdd')), 2) <
                                          NVL(f_parproductos_v(psproduc, 'EDADLIMFISCAL'), 14) THEN
                  IF vnumnif2 IS NOT NULL THEN
                     perror := f_valida_nif_1cabeza(vsperson2, vtidenti2, psseguro, vsproces,
                                                    vnumnif2, vhashcodeerr);   -- Validamos el NIF del respresentante

                     IF perror <> 0 THEN
                        RETURN perror;
                     END IF;

                     vnumnif1 := NULL;   -- Si se informa representante legal el campo NNUMNIF debe ser blanco
                     vspersonrep := vsperson2;
                     vnnumnifrep := vnumnif2;
                  ELSE
                     SELECT f_axis_literales(180905, f_idiomauser) || '.' || 'Pol='
                            || f_formatopolseg(psseguro) || ',' || 'Fnacimi=' || vfnacimi1
                            || ',' || 'NIF=' || vauxnif || ',' || 'M='
                            || f_modelos_afectados(psseguro)
                       INTO verrprolin
                       FROM DUAL;

                     SELECT DBMS_UTILITY.get_hash_value(verrprolin, 1000000000, POWER(2, 30))
                       INTO verrcode
                       FROM DUAL;

                     IF vhashcodeerr.EXISTS(verrcode) THEN
                        NULL;
                     ELSE
                        perror := f_proceslin(vsproces, verrprolin, psseguro, vnprolin);
                        vhashcodeerr(verrcode) := 0;
                     END IF;

                     RETURN 180905;
                  END IF;
               ELSE
                  SELECT f_axis_literales(180912, f_idiomauser) || 'Pol='
                         || f_formatopolseg(psseguro) || ',' || 'Fnacimi=' || vfnacimi1 || ','
                         || 'NIF=' || vauxnif || ',' || 'M=' || f_modelos_afectados(psseguro)
                    INTO verrprolin
                    FROM DUAL;

                  SELECT DBMS_UTILITY.get_hash_value(verrprolin, 1000000000, POWER(2, 30))
                    INTO verrcode
                    FROM DUAL;

                  IF vhashcodeerr.EXISTS(verrcode) THEN
                     NULL;
                  ELSE
                     perror := f_proceslin(vsproces, verrprolin, psseguro, vnprolin);
                     vhashcodeerr(verrcode) := 0;
                  END IF;

                  RETURN 180907;
               END IF;
            END IF;
         ELSE
            vspersonrep := NULL;
            vnnumnifrep := NULL;
         END IF;
      END IF;

      RETURN 0;
   END f_trata_representante;

   FUNCTION f_valida_nif_1cabeza(
      vsperson1 IN NUMBER,
      vtidenti1 IN NUMBER,
      psseguro IN NUMBER,
      vsproces IN NUMBER,
      vnumnif1 IN OUT VARCHAR2,
      vhashcodeerr IN OUT pac_cierrefiscal_aru.assoc_array_error,
      writeerr IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      perror         NUMBER;
      vnprolin       NUMBER;
      vauxnif        VARCHAR2(14);
      -- RSC 19/12/2008
      verrprolin     VARCHAR2(120);
      verrcode       NUMBER;
   BEGIN
      vauxnif := vnumnif1;

      IF vtidenti1 NOT IN(1, 4, 5) THEN
         BEGIN
            SELECT nnumide
              INTO vnumnif1
              FROM per_identifica
             WHERE sperson = vsperson1
               AND ctipide = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT nnumide
                    INTO vnumnif1
                    FROM per_identifica
                   WHERE sperson = vsperson1
                     AND ctipide = 4;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                        SELECT nnumide
                          INTO vnumnif1
                          FROM per_identifica
                         WHERE sperson = vsperson1
                           AND ctipide = 5;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           vnumnif1 := NULL;
                     END;
               END;
         END;

         IF f_nif(vnumnif1) <> 0 THEN
            IF writeerr = 1 THEN
               SELECT f_axis_literales(180907, f_idiomauser) || '.' || 'Pol='
                      || f_formatopolseg(psseguro) || ',' || 'NIF=' || vauxnif || ',' || 'M='
                      || f_modelos_afectados(psseguro)
                 INTO verrprolin
                 FROM DUAL;

               SELECT DBMS_UTILITY.get_hash_value(verrprolin, 1000000000, POWER(2, 30))
                 INTO verrcode
                 FROM DUAL;

               IF vhashcodeerr.EXISTS(verrcode) THEN
                  NULL;
               ELSE
                  perror := f_proceslin(vsproces, verrprolin, psseguro, vnprolin);
                  vhashcodeerr(verrcode) := 0;
               END IF;
            END IF;

            RETURN 111650;
         END IF;
      ELSE
         IF f_nif(vnumnif1) <> 0 THEN
            BEGIN
               SELECT nnumide
                 INTO vnumnif1
                 FROM per_identifica
                WHERE sperson = vsperson1
                  AND ctipide = 1;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT nnumide
                       INTO vnumnif1
                       FROM per_identifica
                      WHERE sperson = vsperson1
                        AND ctipide = 4;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        BEGIN
                           SELECT nnumide
                             INTO vnumnif1
                             FROM per_identifica
                            WHERE sperson = vsperson1
                              AND ctipide = 5;
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              vnumnif1 := NULL;
                        END;
                  END;
            END;

            IF f_nif(vnumnif1) <> 0 THEN
               IF writeerr = 1 THEN
                  SELECT f_axis_literales(180907, f_idiomauser) || '.' || 'Pol='
                         || f_formatopolseg(psseguro) || ',' || 'NIF=' || vauxnif || ','
                         || 'M=' || f_modelos_afectados(psseguro)
                    INTO verrprolin
                    FROM DUAL;

                  SELECT DBMS_UTILITY.get_hash_value(verrprolin, 1000000000, POWER(2, 30))
                    INTO verrcode
                    FROM DUAL;

                  IF vhashcodeerr.EXISTS(verrcode) THEN
                     NULL;
                  ELSE
                     perror := f_proceslin(vsproces, verrprolin, psseguro, vnprolin);
                     vhashcodeerr(verrcode) := 0;
                  END IF;
               END IF;

               RETURN 111650;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   END f_valida_nif_1cabeza;

   -- Bug 15702 - RSC - 27/09/2010 - Models Fiscals: 347
   FUNCTION cierre_fis_riesgo(
      pany IN VARCHAR2,
      pempres IN NUMBER,
      psfiscab IN NUMBER,
      psproces IN NUMBER DEFAULT NULL,
      pfperfin IN DATE DEFAULT NULL)   -- Bug 15702 - RSC - 27/09/2010 - Models Fiscals: 347
      RETURN NUMBER IS
      --
      v_mod346       NUMBER(1);   -- Indica si la empresa dispone del modelo 346: Solo indemnizaciones

      CURSOR aportaciones IS
         SELECT   s.sseguro, c.fconta fcontab, NULL nnumlin, s.cramo, s.cmodali, s.ctipseg,
                  s.ccolect, c.nrecibo, c.fefecto fvalmov,
                  (SUM(iconsorcio) + SUM(iclea) + SUM(impuesto) + SUM(base) + SUM(rectifica))
                                                                                      imovimi,
                  a.sperson, a.cdomici, p.nnumide
             FROM (SELECT h.sseguro, h.nrecibo, h.fconta, h.fefecto, h.cgarant,
                          NVL(h.consorcio, 0) iconsorcio, NVL(h.clea, 0) iclea,
                          NVL(h.impuesto, 0) impuesto,
                          NVL(h.prima_tarifa + h.rec_fpago, 0) base, 0 rectifica
                     FROM his_cuadre05 h, seguros s   -- Cobrados este año
                    WHERE h.sseguro = s.sseguro
                      AND s.cagrpro = 1   -- Vida Riesgo
                      AND pac_anulacion.f_anulada_al_emitir(h.sseguro) = 0
                      AND TO_CHAR(h.fconta, 'yyyy') = pany
                      AND TRUNC(h.fconta) <=
                            NVL(pfperfin, h.fconta)   -- Bug 15702 - RSC - 27/09/2010 - Models Fiscals: 347
                   UNION ALL
                   SELECT h.sseguro, h.nrecibo, h.fconta, h.fefecto, h.cgarant,
                          0 - NVL(h.consorcio, 0) iconsorcio, 0 - NVL(h.clea, 0) iclea,
                          0 - NVL(h.impuesto, 0) impuesto,
                          0 - NVL(h.prima_tarifa + h.rec_fpago, 0) base, 0 rectifica
                     FROM his_cuadre04 h, seguros s   --Impagados de este año
                    WHERE h.sseguro = s.sseguro
                      AND s.cagrpro = 1   -- Vida Riesgo
                      AND pac_anulacion.f_anulada_al_emitir(h.sseguro) = 0
                      AND TO_CHAR(h.fconta, 'yyyy') = pany
                      AND TRUNC(h.fconta) <=
                            NVL(pfperfin, h.fconta)   -- Bug 15702 - RSC - 27/09/2010 - Models Fiscals: 347
                   UNION ALL
                   SELECT h.sseguro, h.nrecibo, h.fconta, h.fefecto, h.cgarant,
                          0 - NVL(h.consorcio, 0) iconsorcio, 0 - NVL(h.clea, 0) iclea,
                          0 - NVL(h.impuesto, 0) impuesto,
                          0 - NVL(h.prima_tarifa + h.rec_fpago, 0) base,
                          0 - NVL(h.impuesto, 0) rectifica
                     FROM his_cuadre003 h, seguros s   --Impagados del año pasado
                    WHERE h.sseguro = s.sseguro
                      AND s.cagrpro = 1   -- Vida Riesgo
                      AND pac_anulacion.f_anulada_al_emitir(h.sseguro) = 0
                      AND TO_CHAR(h.fconta, 'yyyy') = pany
                      AND TRUNC(h.fconta) <=
                            NVL(pfperfin, h.fconta)   -- Bug 15702 - RSC - 27/09/2010 - Models Fiscals: 347
                                                   ) c,
                  seguros s,
                  tomadores a,
                  per_personas p
            WHERE c.sseguro = s.sseguro
              AND a.sseguro = s.sseguro
              AND p.sperson = a.sperson
              AND s.cempres = NVL(pempres, 1)
         GROUP BY s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro, c.nrecibo, c.fconta,
                  c.fefecto, a.sperson, a.cdomici, p.nnumide;

      CURSOR pagos_sin IS
         -- BUG 11595 - 04/11/2009 - APD - Adaptación al nuevo módulo de siniestros
         -- se añade la SELECT FROM para poder añadir la UNION con las tablas nuevas de siniestros
         SELECT   a.npoliza npoliza, a.ncertif ncertif, a.nsolici nsolici, a.cagente cagente,
                  a.sperson, a.nsinies nsinies, a.nriesgo, NULL nombre_beneficiario,
                  a.cramo cramo, a.cmodali cmodali, a.ctipseg ctipseg, a.ccolect ccolect,
                  a.sproduc sproduc, a.sseguro sseguro, a.fefepag fpago,
                  (a.isinret - a.iretenc) importe, a.isinret impbruto, a.pretenc,
                  a.iretenc retencion,(NVL(a.iresred, 0) + NVL(a.ireg_trans, 0)) reduc,

                  -- Bug 17005 - RSC - 21/12/2010 - CEM800 - Ajustes modelos fiscales
                  --DECODE(NVL(f_parproductos_v(a.sproduc, 'PRESTACION'), 0),
                  --       1, a.iconret,
                  --       a.iresrcm) rcm,
                  a.iresrcm rcm,
                                -- Fin Bug 17005
                                a.fsinies, a.fefecto, NULL nif_beneficiario, a.sidepag,
                  a.sperson_pagosini, a.ctipdes ctipdes_pagosini, a.cagrpro, a.ccausin,
                  a.cmotsin, a.cpaisresid
             FROM (SELECT s.npoliza npoliza, s.ncertif ncertif, s.nsolici nsolici,
                          s.cagente cagente, pac_sin.ff_sperson_sinies(si.nsinies) sperson,
                          TO_CHAR(si.nsinies) nsinies, si.nriesgo, s.cramo cramo,
                          s.cmodali cmodali, s.ctipseg ctipseg, s.ccolect ccolect,
                          s.sproduc sproduc, s.sseguro sseguro, pg.fefepag, pg.isinret,
                          pg.iretenc, pg.isinret impbruto, pg.pretenc, pg.iretenc retencion,
                          pg.iresred, pg.ireg_trans, pg.iconret, pg.iresrcm, si.fsinies,
                          s.fefecto, pg.sidepag, pg.sperson sperson_pagosini, pg.ctipdes,
                          s.cagrpro, si.ccausin, si.cmotsin, d.cpaisresid
                     FROM seguros s, siniestros si, /*codicausin c,*/ pagosini pg,
                          destinatarios d
                    WHERE s.sseguro = si.sseguro
                      AND s.cempres = NVL(pempres, 1)
                      AND pg.nsinies = si.nsinies
                      --AND si.ccausin = c.ccausin
                      AND d.nsinies = si.nsinies
                      AND d.sperson = pg.sperson
                      AND TO_CHAR(pg.fefepag, 'yyyy') = pany
                      AND TRUNC(pg.fefepag) <=
                            NVL
                               (pfperfin, pg.fefepag)   -- Bug 15702 - RSC - 27/09/2010 - Models Fiscals: 347
                      AND pg.cestpag = 2   --Pagos pagados
                      AND(v_mod346 = 1
                          OR s.cagrpro IN(1, 24)   -- Vida Riesgo
                                                )
                      AND pg.ctippag = 2   -- RSC 07/01/2008 Excluimos pagos que tengan un
                                           -- pago de Anulación de pago
                      AND pg.sidepag NOT IN(SELECT NVL(pp.spganul, 0)
                                              FROM pagosini pp
                                             WHERE nsinies = pg.nsinies
                                               AND cestpag <> 8)   -- RSC 07/01/2008 Excluimos
                                                                   -- pagos que tengan un pago
                                                                   -- de Anulación de pago
                      AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 0
                   UNION
                   SELECT s.npoliza npoliza, s.ncertif ncertif, s.nsolici nsolici,
                          s.cagente cagente,
                          pac_siniestros.ff_sperson_sinies(si.nsinies) sperson,
                          si.nsinies nsinies, si.nriesgo, s.cramo cramo, s.cmodali cmodali,
                          s.ctipseg ctipseg, s.ccolect ccolect, s.sproduc sproduc,
                          s.sseguro sseguro, m.fefepag, pg.isinret, pg.iretenc,
                          pg.isinret impbruto, pgar.pretenc, pg.iretenc retencion, pg.iresred,
                          NULL ireg_trans,(pg.isinret - pg.iretenc) iconret, pg.iresrcm rcm,
                          si.fsinies, s.fefecto, pg.sidepag, pg.sperson sperson_pagosini,
                          pg.ctipdes, s.cagrpro, si.ccausin, si.cmotsin, pd.cpais cpaisresid
                     FROM seguros s, sin_siniestro si, sin_tramitacion t, sin_tramita_pago pg,
                          sin_tramita_movpago m, sin_tramita_pago_gar pgar,
                          sin_tramita_destinatario d, per_personas pp, per_detper pd
                    WHERE s.sseguro = si.sseguro
                      AND s.cempres = NVL(pempres, 1)
                      AND si.nsinies = t.nsinies
                      AND pg.nsinies = t.nsinies
                      AND pg.ntramit = t.ntramit
                      AND d.nsinies = t.nsinies
                      AND d.ntramit = t.ntramit   -- Fi Bug 0013152. FAL. 23/02/2010
                      AND d.sperson = pg.sperson
                      AND pg.sidepag = m.sidepag
                      AND m.nmovpag = (SELECT MAX(nmovpag)
                                         FROM sin_tramita_movpago
                                        WHERE sidepag = m.sidepag)
                      AND pg.sidepag = pgar.sidepag
                      AND pgar.ctipres = 1
                      AND d.sperson = pp.sperson
                      AND pp.sperson = pd.sperson
                      AND pd.cagente = ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres)
                      AND TO_CHAR(m.fefepag, 'yyyy') = pany
                      AND TRUNC(m.fefepag) <=
                            NVL(pfperfin, m.fefepag)   -- Bug 15702 - RSC - 27/09/2010 - Models Fiscals: 347
                      AND m.cestpag = 2   --Pagos pagados
                      AND(v_mod346 = 1
                          OR s.cagrpro IN(1, 24)   -- Vida Riesgo
                                                )
                      AND pg.ctippag = 2   -- RSC 07/01/2008 Excluimos pagos que tengan un
                                           -- pago de Anulación de pago
                      AND m.cestpag <> 8   -- Anulado -- RSC 07/01/2008 Excluimos
                                 -- pagos que tengan un pago
                                 -- de Anulación de pago
                      -- Para el nuevo modelo será excluir los pagos que estén anulados
                      AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 1) a
         ORDER BY a.cramo, a.cmodali, a.ctipseg, a.ccolect, a.nsinies, fpago;

      vcobropart     NUMBER;
      vpais          NUMBER;
      vnumnif        VARCHAR2(14);
      vtidenti       NUMBER;
      vsseguro       NUMBER;
      vfechaaux      DATE;
      vispnofinanc_aux NUMBER;
      vsperson       NUMBER;
      -- 4/5/06 CPM Es crea la variable per recollir el resultat
      vresul         NUMBER;
      -- RSC 03/11/2008
      vsperson1      NUMBER;
      vnumnif1       VARCHAR2(14);
      vpais1         NUMBER;
      vffecfin1      DATE;
      vffecmue1      DATE;
      vfnacimi1      DATE;
      vtidenti1      NUMBER;
      vtestnif1      NUMBER;
      vsperson2      NUMBER;
      vnumnif2       VARCHAR2(14);
      vpais2         NUMBER;
      vffecfin2      DATE;
      vffecmue2      DATE;
      vfnacimi2      DATE;
      vtidenti2      NUMBER;
      vtestnif2      NUMBER;
      vspersonrep    NUMBER;
      vnnumnifrep    VARCHAR2(14);
      vfpeticion     DATE;
      vfnacimi       DATE;
      -- RSC 10/12/2008
      vsproces       NUMBER;
      perror         NUMBER;
      vtexto         VARCHAR2(200);
      vnprolin       NUMBER;
      aport_execp    EXCEPTION;
      vcontaerr      NUMBER := 0;
      vcontador      NUMBER := 0;
      vsperson_ax1   NUMBER;
      -- RSC 16/12/2008
      do_nothing     EXCEPTION;
      vtcausin       VARCHAR2(100);
      -- RSC 19/12/2008
      vauxinif       VARCHAR2(14);
      vhashcodeerr   pac_cierrefiscal_aru.assoc_array_error;
      verrprolin     VARCHAR2(120);
      verrcode       NUMBER;
      -- RSC 07/01/2008
      vorden         NUMBER;
      vpconsum_ircm  NUMBER;
      vpconsum_ireduc NUMBER;
      vpconsum_ireg_transcomp NUMBER;
      -- RSC 14/01/2008
      vcagente       NUMBER;
      vpersona       personas%ROWTYPE;
      vresult        NUMBER;
      v_sproduc      NUMBER;
      -- Bug 17005 - RSC - 15/12/2010 - CEM800 - Ajustes modelos fiscales
      v_clave        VARCHAR2(1);
   -- Fin Bug 17005
   BEGIN
      IF psproces IS NULL THEN
         perror := f_procesini(getuser, pempres,
                               'CIERREFIS:' || TO_CHAR(f_sysdate, 'yyyymmdd'),
                               'CIERRE FISCAL AHORRO', vsproces);
      ELSE
         vsproces := psproces;
      END IF;

      -- Bug 0029015 - 03/12/2013 - JMF
      SELECT NVL(MAX(1), 0)
        INTO v_mod346
        FROM fis_modelosdet
       WHERE cmodelo = 'MOD_346'
         AND lactivo = 'S'
         AND cempresa = pempres;

      --Inserción de la tabla FIS_DETCIERRECOBRO
      FOR apor IN aportaciones LOOP
         v_sproduc := f_sproduc_ret(apor.cramo, apor.cmodali, apor.ctipseg, apor.ccolect);

         BEGIN
            -- RSC 03/11/2008
            vcobropart := apor.imovimi;
            -- 1 cabeza
            f_datos_asegurado(apor.sseguro, 1, vsperson1, vnumnif1, vfnacimi1, vpais1,
                              vffecfin1, vffecmue1, vtidenti1);
            -- 2 cabezas
            f_datos_asegurado(apor.sseguro, 2, vsperson2, vnumnif2, vfnacimi2, vpais2,
                              vffecfin2, vffecmue2, vtidenti2);

            IF vsperson2 IS NULL THEN   -- 1 cabeza
               perror := f_valida_nif_1cabeza(vsperson1, vtidenti1, apor.sseguro, vsproces,
                                              vnumnif1, vhashcodeerr);

               IF perror <> 0 THEN
                  RAISE aport_execp;
               END IF;

               INSERT INTO fis_detcierrecobro
                           (sfiscab, sfisdco, cramo, cmodali, ctipseg,
                            ccolect, pfiscal, sseguro, spersonp, nnumnifp,
                            nrecibo, fefecto, cpaisret, csubtipo, iaporpart,
                            iimporte, iaporprom, iaporsp, ctipapor)
                    VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali, apor.ctipseg,
                            apor.ccolect, pany, apor.sseguro, vsperson1, vnumnif1,
                            apor.nrecibo, apor.fvalmov, vpais1, NULL /*'345'*/, NULL,
                            vcobropart, NULL, NULL, NULL);
            ELSE
               IF vffecmue1 IS NULL
                  AND vffecmue2 IS NULL THEN
-- Dos asegurados vivos
-- A efectos fiscales se considerará que cada uno de ellos ha liquidado
-- el 50% de la prima. A cada titular se le remitirá la información
-- fiscal correspondiente, si el titular es menor de 14 años se
-- identifica en el modelo 188 identificando como representante del
-- mismo al primer titular.
-------------------------------------------------------------------
                  perror := f_trata_representante(vsperson1, vsperson2, vnumnif2,
                                                  apor.sseguro, apor.fvalmov, v_sproduc,
                                                  vfnacimi1, vnumnif1, vtidenti1, vtidenti2,
                                                  vspersonrep, vnnumnifrep, vsproces,
                                                  vhashcodeerr);

                  IF perror <> 0 THEN
                     RAISE aport_execp;
                  END IF;

                  -- La mitad de la aportación para uno y la otra mitad para el otro
                  INSERT INTO fis_detcierrecobro
                              (sfiscab, sfisdco, cramo, cmodali,
                               ctipseg, ccolect, pfiscal, sseguro, spersonp,
                               nnumnifp, sperson1, nnumnif1, nrecibo, fefecto,
                               cpaisret, csubtipo, iaporpart, iimporte, iaporprom, iaporsp,
                               ctipapor)
                       VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali,
                               apor.ctipseg, apor.ccolect, pany, apor.sseguro, vsperson1,
                               vnumnif1, vspersonrep, vnnumnifrep, apor.nrecibo, apor.fvalmov,
                               vpais1, NULL /*'345'*/, NULL,(vcobropart / 2), NULL, NULL,
                               NULL);

                  -- Miramos si precisa representante (el otro titular en este caso)
                  perror := f_trata_representante(vsperson2, vsperson1, vnumnif1, apor.sseguro,
                                                  apor.fvalmov, v_sproduc, vfnacimi2, vnumnif2,
                                                  vtidenti2, vtidenti1, vspersonrep,
                                                  vnnumnifrep, vsproces, vhashcodeerr);

                  IF perror <> 0 THEN
                     RAISE aport_execp;
                  END IF;

                  INSERT INTO fis_detcierrecobro
                              (sfiscab, sfisdco, cramo, cmodali,
                               ctipseg, ccolect, pfiscal, sseguro, spersonp,
                               nnumnifp, sperson1, nnumnif1, nrecibo, fefecto,
                               cpaisret, csubtipo, iaporpart, iimporte, iaporprom, iaporsp,
                               ctipapor)
                       VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali,
                               apor.ctipseg, apor.ccolect, pany, apor.sseguro, vsperson2,
                               vnumnif2, vspersonrep, vnnumnifrep, apor.nrecibo, apor.fvalmov,
                               vpais2, NULL /*'345'*/, NULL,(vcobropart / 2), NULL, NULL,
                               NULL);
               ELSIF vffecmue1 IS NOT NULL THEN
                  IF vffecmue1 > apor.fvalmov THEN
                     perror := f_trata_representante(vsperson1, vsperson2, vnumnif2,
                                                     apor.sseguro, apor.fvalmov, v_sproduc,
                                                     vfnacimi1, vnumnif1, vtidenti1,
                                                     vtidenti2, vspersonrep, vnnumnifrep,
                                                     vsproces, vhashcodeerr);

                     IF perror <> 0 THEN
                        RAISE aport_execp;
                     END IF;

                     -- La mitad de la aportación para uno y la otra mitad para el otro
                     INSERT INTO fis_detcierrecobro
                                 (sfiscab, sfisdco, cramo, cmodali,
                                  ctipseg, ccolect, pfiscal, sseguro, spersonp,
                                  nnumnifp, sperson1, nnumnif1, nrecibo,
                                  fefecto, cpaisret, csubtipo, iaporpart, iimporte,
                                  iaporprom, iaporsp, ctipapor)
                          VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali,
                                  apor.ctipseg, apor.ccolect, pany, apor.sseguro, vsperson1,
                                  vnumnif1, vspersonrep, vnnumnifrep, apor.nrecibo,
                                  apor.fvalmov, vpais1, NULL /*'345'*/, NULL,(vcobropart / 2),
                                  NULL, NULL, NULL);

                     -- Miramos si precisa representante (el otro titular en este caso)
                     perror := f_trata_representante(vsperson2, vsperson1, vnumnif1,
                                                     apor.sseguro, apor.fvalmov, v_sproduc,
                                                     vfnacimi2, vnumnif2, vtidenti2, vtidenti1,
                                                     vspersonrep, vnnumnifrep, vsproces,
                                                     vhashcodeerr);

                     IF perror <> 0 THEN
                        RAISE aport_execp;
                     END IF;

                     INSERT INTO fis_detcierrecobro
                                 (sfiscab, sfisdco, cramo, cmodali,
                                  ctipseg, ccolect, pfiscal, sseguro, spersonp,
                                  nnumnifp, sperson1, nnumnif1, nrecibo,
                                  fefecto, cpaisret, csubtipo, iaporpart, iimporte,
                                  iaporprom, iaporsp, ctipapor)
                          VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali,
                                  apor.ctipseg, apor.ccolect, pany, apor.sseguro, vsperson2,
                                  vnumnif2, vspersonrep, vnnumnifrep, apor.nrecibo,
                                  apor.fvalmov, vpais2, NULL /*'345'*/, NULL,(vcobropart / 2),
                                  NULL, NULL, NULL);
                  ELSE
                     INSERT INTO fis_detcierrecobro
                                 (sfiscab, sfisdco, cramo, cmodali,
                                  ctipseg, ccolect, pfiscal, sseguro, spersonp,
                                  nnumnifp, nrecibo, fefecto, cpaisret,
                                  csubtipo, iaporpart, iimporte, iaporprom, iaporsp, ctipapor)
                          VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali,
                                  apor.ctipseg, apor.ccolect, pany, apor.sseguro, vsperson2,
                                  vnumnif2, apor.nrecibo, apor.fvalmov, vpais2,
                                  NULL /*'345'*/, NULL, vcobropart, NULL, NULL, NULL);
                  END IF;
               ELSIF vffecmue2 IS NOT NULL THEN
                  IF vffecmue2 > apor.fvalmov THEN
                     perror := f_trata_representante(vsperson1, vsperson2, vnumnif2,
                                                     apor.sseguro, apor.fvalmov, v_sproduc,
                                                     vfnacimi1, vnumnif1, vtidenti1,
                                                     vtidenti2, vspersonrep, vnnumnifrep,
                                                     vsproces, vhashcodeerr);

                     IF perror <> 0 THEN
                        RAISE aport_execp;
                     END IF;

                     -- La mitad de la aportación para uno y la otra mitad para el otro
                     INSERT INTO fis_detcierrecobro
                                 (sfiscab, sfisdco, cramo, cmodali,
                                  ctipseg, ccolect, pfiscal, sseguro, spersonp,
                                  nnumnifp, sperson1, nnumnif1, nrecibo,
                                  fefecto, cpaisret, csubtipo, iaporpart, iimporte,
                                  iaporprom, iaporsp, ctipapor)
                          VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali,
                                  apor.ctipseg, apor.ccolect, pany, apor.sseguro, vsperson1,
                                  vnumnif1, vspersonrep, vnnumnifrep, apor.nrecibo,
                                  apor.fvalmov, vpais1, NULL /*'345'*/, NULL,(vcobropart / 2),
                                  NULL, NULL, NULL);

                     -- Miramos si precisa representante (el otro titular en este caso)
                     perror := f_trata_representante(vsperson2, vsperson1, vnumnif1,
                                                     apor.sseguro, apor.fvalmov, v_sproduc,
                                                     vfnacimi2, vnumnif2, vtidenti2, vtidenti1,
                                                     vspersonrep, vnnumnifrep, vsproces,
                                                     vhashcodeerr);

                     IF perror <> 0 THEN
                        RAISE aport_execp;
                     END IF;

                     INSERT INTO fis_detcierrecobro
                                 (sfiscab, sfisdco, cramo, cmodali,
                                  ctipseg, ccolect, pfiscal, sseguro, spersonp,
                                  nnumnifp, sperson1, nnumnif1, nrecibo,
                                  fefecto, cpaisret, csubtipo, iaporpart, iimporte,
                                  iaporprom, iaporsp, ctipapor)
                          VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali,
                                  apor.ctipseg, apor.ccolect, pany, apor.sseguro, vsperson2,
                                  vnumnif2, vspersonrep, vnnumnifrep, apor.nrecibo,
                                  apor.fvalmov, vpais2, NULL /*'345'*/, NULL,(vcobropart / 2),
                                  NULL, NULL, NULL);
                  ELSE
                     INSERT INTO fis_detcierrecobro
                                 (sfiscab, sfisdco, cramo, cmodali,
                                  ctipseg, ccolect, pfiscal, sseguro, spersonp,
                                  nnumnifp, nrecibo, fefecto, cpaisret,
                                  csubtipo, iaporpart, iimporte, iaporprom, iaporsp, ctipapor)
                          VALUES (psfiscab, sfisdco.NEXTVAL, apor.cramo, apor.cmodali,
                                  apor.ctipseg, apor.ccolect, pany, apor.sseguro, vsperson1,
                                  vnumnif1, apor.nrecibo, apor.fvalmov, vpais1,
                                  NULL /*'345'*/, NULL, vcobropart, NULL, NULL, NULL);
                  END IF;
               END IF;
            END IF;
         EXCEPTION
            WHEN aport_execp THEN
               vcontaerr := vcontaerr + 1;
         END;
      END LOOP;

      -- Para aquellos contratos que no han generado cualquier tipo de aportacion se debe grabar un registro
      -- con importes a 0 para que conste la informacion fiscal.
      vfechaaux := LAST_DAY(TO_DATE(pany || '12', 'YYYYMM'));

      --Inserción de la tabla FIS_DETCIERREPAGO
      FOR cur_pags IN pagos_sin LOOP
         BEGIN
            BEGIN
               SELECT cagente
                 INTO vcagente
                 FROM seguros
                WHERE sseguro = cur_pags.sseguro;

               vresult := pac_persona.f_get_dadespersona(cur_pags.sperson_pagosini, vcagente,
                                                         vpersona);
               vnumnif := vpersona.nnumide;
               vfnacimi := vpersona.fnacimi;
               vpais := vpersona.cpais;
               vtidenti := vpersona.ctipide;
            EXCEPTION
               WHEN OTHERS THEN
                  vnumnif := NULL;
                  vpais := NULL;
            END;

            -- Guardamos una copia del NIF por si la necesitamos
            vauxinif := vnumnif;

            -- RSC 16/12/2008
            IF cur_pags.ccausin IN(3, 4) THEN
               SELECT COUNT(*)
                 INTO vcontador
                 FROM asegurados a
                WHERE sseguro = cur_pags.sseguro
                  AND sperson = cur_pags.sperson_pagosini
                  AND ffecfin IS NULL;   -- BUG11183:DRA:22/09/2009

               IF vcontador = 0 THEN   -- El destinatario no es ningún asegurado de la póliza
                  -- BUG 11595 - 01/12/2009 - APD - Adaptación al nuevo módulo de siniestros
                  -- se añade la SELECT FROM para poder añadir la UNION con las tablas nuevas de siniestros
                  SELECT a.tcausin
                    INTO vtcausin
                    FROM (SELECT tcausin
                            FROM causasini
                           WHERE ccausin = cur_pags.ccausin
                             AND cidioma = f_idiomauser
                             AND NVL(pac_parametros.f_parempresa_n(NVL(pempres, 1),
                                                                   'MODULO_SINI'),
                                     0) = 0
                          UNION
                          SELECT tcausin
                            FROM sin_descausa
                           WHERE ccausin = cur_pags.ccausin
                             AND cidioma = f_idiomauser
                             AND NVL(pac_parametros.f_parempresa_n(NVL(pempres, 1),
                                                                   'MODULO_SINI'),
                                     0) = 1) a;

                  SELECT f_axis_literales(101512, f_idiomauser) || '(Ccausin='
                         || cur_pags.ccausin || ') '
                         || pac_util.splitt(f_axis_literales(107710, f_idiomauser), 2, ' ')
                         || ' '
                         || pac_util.splitt(f_axis_literales(107710, f_idiomauser), 3, ' ')
                         || ' '
                         || pac_util.splitt(f_axis_literales(112331, f_idiomauser), 4, ' ')
                         || ' '
                         || pac_util.splitt(f_axis_literales(112331, f_idiomauser), 5, ' ')
                         || '.' || 'Pol=' || f_formatopolseg(cur_pags.sseguro) || ','
                         || 'Nsinies=' || cur_pags.nsinies || ',' || 'NIF=' || vnumnif || ','
                         || 'M=' || f_modelos_afectados(cur_pags.sseguro)
                    INTO verrprolin
                    FROM DUAL;

                  SELECT DBMS_UTILITY.get_hash_value(verrprolin, 1000000000, POWER(2, 30))
                    INTO verrcode
                    FROM DUAL;

                  IF vhashcodeerr.EXISTS(verrcode) THEN
                     NULL;
                  ELSE
                     perror := f_proceslin(vsproces, verrprolin, cur_pags.sseguro, vnprolin);
                     vhashcodeerr(verrcode) := 0;
                  END IF;

                  RAISE aport_execp;
               END IF;
            END IF;

            IF cur_pags.ccausin IN(3, 4) THEN
               BEGIN
                  SELECT norden
                    INTO vorden
                    FROM asegurados
                   WHERE sperson = cur_pags.sperson_pagosini
                     AND sseguro = cur_pags.sseguro   -- BUG11183:DRA:22/09/2009
                     AND ffecfin IS NULL;   -- BUG11183:DRA:22/09/2009
               EXCEPTION
                  WHEN OTHERS THEN
                     vorden := 1;
               END;

               BEGIN
                  SELECT SUM(ircm), SUM(ireduc), SUM(ireg_transcomp)
                    INTO vpconsum_ircm, vpconsum_ireduc, vpconsum_ireg_transcomp
                    FROM primas_consumidas
                   WHERE sseguro = cur_pags.sseguro
                     AND nriesgo = vorden;
               EXCEPTION
                  WHEN OTHERS THEN
                     vpconsum_ircm := 0;
                     vpconsum_ireduc := 0;
                     vpconsum_ireg_transcomp := 0;
               END;
            ELSE
               vpconsum_ircm := NULL;
               vpconsum_ireduc := NULL;
               vpconsum_ireg_transcomp := NULL;
            END IF;

            -- Bug 17005 - RSC - 15/12/2010 - CEM800 - Ajustes modelos fiscales
            SELECT DECODE(NVL(f_parproductos_v(cur_pags.sproduc, 'TIPO_LIMITE'), 0),
                          1, DECODE(NVL(cur_pags.reduc, 0), 0, ' ', 'B'),
                          DECODE(NVL((SUM(NVL(vpconsum_ircm, 0)) - SUM(NVL(vpconsum_ireduc, 0))
                                      - SUM(NVL(vpconsum_ireg_transcomp, 0))),
                                     0),
                                 0, ' ',
                                 'A'))
              INTO v_clave
              FROM DUAL;

            -- Fin Bug 17005
            INSERT INTO fis_detcierrepago
                        (sfiscab, sfisdpa, cramo, cmodali,
                         ctipseg, ccolect, pfiscal, sseguro,
                         spersonp, nnumnifp, fpago,
                         cpaisret, csubtipo, iresred, iresrcm,
                         pretenc, iretenc, ibruto,
                         ineto, ctipcap, sidepag,
                         csigbase,
                         ctipo,
                         pconsum_ircm, pconsum_ireduc, pconsum_ireg_transcomp, clave)
                 VALUES (psfiscab, sfisdpa.NEXTVAL, cur_pags.cramo, cur_pags.cmodali,
                         cur_pags.ctipseg, cur_pags.ccolect, pany, cur_pags.sseguro,
                         cur_pags.sperson_pagosini, vnumnif, cur_pags.fpago,
                         cur_pags.cpaisresid, NULL, cur_pags.reduc, cur_pags.rcm,
                         cur_pags.pretenc, cur_pags.retencion, cur_pags.impbruto,
                         cur_pags.importe, 1, cur_pags.sidepag,
                         DECODE(SIGN(cur_pags.rcm), -1, 'N', 'P'),
                         DECODE(cur_pags.ccausin,
                                1, DECODE(cur_pags.cmotsin, 0, 'SIN', NULL),
                                8, 'TRS',
                                3, 'VTO',
                                4, 'RTO',
                                5, 'RPA',
                                NULL),
                         vpconsum_ircm, vpconsum_ireduc, vpconsum_ireg_transcomp, v_clave);
         EXCEPTION
            WHEN aport_execp THEN
               vcontaerr := vcontaerr + 1;
            WHEN do_nothing THEN
               NULL;
         END;
      END LOOP;

      IF psproces IS NULL THEN
         -- Finalizamos proces
         perror := f_procesfin(vsproces, vcontaerr);
      END IF;

      -- 4/5/06 CPM: Es crida a la funció que recalcula la taula PLANFISCAL
      vresul := f_calculo_planfiscal_riesgo(pany);

      IF vresul = 0 THEN
         RETURN 0;
      END IF;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'CIERRE FISCAL Cierre_Fis_Aho', NULL,
                     'when others del cierre =' || psfiscab, SQLERRM);
   END cierre_fis_riesgo;

   -- Bug 15702 - RSC - 28/09/2010 - Models Fiscals: 347
   FUNCTION f_calculo_planfiscal_riesgo(pany IN VARCHAR2)
      RETURN NUMBER IS
      vprovmat       NUMBER;

      CURSOR cur_aho IS
         SELECT   x.sseguro, pany, SUM(NVL(iimporte, 0)) primas_anuales,
                  SUM(NVL(iaporprom, 0)), SUM(NVL(iaporsp, 0)), SUM(NVL(iaporpart, 0)),
                  SUM(NVL(iretenc, 0)) retenciones, SUM(NVL(iresred, 0)) reducciones,
                  SUM(NVL(iresrcm, 0)) rcm,
                  (SUM(NVL(ibruto, 0)) - SUM(NVL(iretenc, 0))) rescate
             FROM (SELECT sseguro, iimporte, iaporprom, iaporsp, iaporpart, 0 iretenc,
                          0 pretenc, 0 iresred, 0 iresrcm, 0 ibruto
                     FROM fis_detcierrecobro
                    WHERE pfiscal = pany
                   UNION ALL
                   SELECT sseguro, 0 iimporte, 0 iaporprom, 0 iaporsp, 0 iaporpart, iretenc,
                          pretenc, iresred, iresrcm, ibruto
                     FROM fis_detcierrepago
                    WHERE pfiscal = pany
                      AND ctipcap = 1) x
                  JOIN
                  seguros s ON x.sseguro = s.sseguro
            WHERE s.cagrpro = 1
         GROUP BY x.sseguro;
   BEGIN
      FOR regs IN cur_aho LOOP
         BEGIN
            SELECT p.ipromat
              INTO vprovmat
              FROM provmat p
             WHERE p.sseguro = regs.sseguro
               AND p.fcalcul = TO_DATE('31/12/' || pany, 'dd/mm/yyyy');
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               -- Todavia no se ha realizado el cierre de provisiones de Diciembre
               vprovmat := 0;
         END;

         INSERT INTO planfiscal
                     (sseguro, nano, derechos, aporprom, aporsp,
                      aporparti, retencion, ineto, iresred,
                      iresrcm, rentaneta_ren, iresrcm_ren, retencion_ren)
              VALUES (regs.sseguro, TO_NUMBER(pany), vprovmat, NULL, NULL,
                      regs.primas_anuales, regs.retenciones, regs.rescate, regs.reducciones,
                      regs.rcm, 0, 0, 0);
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'p_calculo_planfiscal_riesgo', NULL,
                     'when others; pany =' || pany, SQLERRM);
         RETURN NULL;
   END f_calculo_planfiscal_riesgo;
-- Fin Bug 15702
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_CIERREFISCAL_ARU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CIERREFISCAL_ARU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CIERREFISCAL_ARU" TO "PROGRAMADORESCSI";
