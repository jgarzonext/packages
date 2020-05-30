--------------------------------------------------------
--  DDL for Package Body PAC_CUADRE_CC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CUADRE_CC" IS
-----------------------------------------------------------------------
   FUNCTION f_moviments_corredoria(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pdata_ini IN DATE,
      pdata_fi IN DATE,
      ptext OUT VARCHAR2)
      RETURN NUMBER IS
-----------------------------------------------------------------------
   BEGIN
      -- Es la query liq_corr_aamm_no_compensat. Moviments de rebut amb efecte
      -- És diferent a corredoria pq la comissió que ens interessa és la que ens paga la
      -- cia d'assegurances (icomcia)
      INSERT INTO cuadre_cc
                  (cempres, fcierre, fcalcul, sproces, cramo, cmodali, ctipseg, ccolect,
                   sproduc, polissa_ini, npoliza, nrecibo, smovrec, fefecto, fvencim, cforpag,
                   ccompani, cgescob, ctiprec, cestrec, fmovini, fmovfin, fmovdia, itotalr,
                   iprinet, icomis, sseguro)
         SELECT pcempres, pdata_fi, f_sysdate, psproces, s.cramo, s.cmodali, s.ctipseg,
                s.ccolect, s.sproduc, c.polissa_ini, s.npoliza, m.nrecibo, m.smovrec,
                r.fefecto, r.fvencim, s.cforpag, NVL(s.ccompani, p.ccompani), r.cgescob,
                r.ctiprec, m.cestrec, m.fmovini, m.fmovfin, m.fmovdia,
                DECODE(r.ctiprec,
                       9, DECODE(m.cestrec, 0, itotalr, -itotalr),
                       DECODE(m.cestrec, 0, -itotalr, itotalr)) bruta,
                DECODE(r.ctiprec,
                       9, DECODE(m.cestrec, 0, iprinet, -iprinet),
                       DECODE(m.cestrec, 0, -iprinet, iprinet)) neta,
                DECODE(r.ctiprec,
                       9, DECODE(m.cestrec, 0, icomcia, -icomcia),
                       DECODE(m.cestrec, 0, -icomcia, icomcia)) comisio,
                s.sseguro
           FROM movrecibo m, vdetrecibos v, recibos r, seguros s, cnvpolizas c, productos p
          WHERE s.cempres = pcempres
            AND s.sproduc = p.sproduc
            AND s.sseguro = c.sseguro
            AND s.sseguro = r.sseguro
            AND r.nrecibo = m.nrecibo
            AND m.nrecibo = v.nrecibo
            AND TRUNC(m.fmovini) BETWEEN pdata_ini AND pdata_fi
            AND(m.cestrec = 1
                OR(m.cestrec = 0
                   AND m.cestant = 1));

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         ptext := SQLERRM;
         RETURN 111348;
   END f_moviments_corredoria;

-----------------------------------------------------------------------
   FUNCTION f_moviments_vida(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pdata_ini IN DATE,
      pdata_fi IN DATE,
      ptext OUT VARCHAR2)
      RETURN NUMBER IS
-----------------------------------------------------------------------
   BEGIN
      --Es la query liq_corr_aamm_no_compensat. Moviments de rebut amb efecte
      INSERT INTO cuadre_cc
                  (cempres, fcierre, fcalcul, sproces, cramo, cmodali, ctipseg, ccolect,
                   sproduc, polissa_ini, npoliza, nrecibo, smovrec, fefecto, fvencim, cforpag,
                   ccompani, cgescob, ctiprec, cestrec, fmovini, fmovfin, fmovdia, itotalr,
                   iprinet, icomis, sseguro)
         SELECT pcempres, pdata_fi, f_sysdate, psproces, s.cramo ram, s.cmodali modalitat,
                s.ctipseg tipseg, s.ccolect colec, s.sproduc, c.polissa_ini polissa,
                s.npoliza polissa, m.nrecibo rebut, m.smovrec, r.fefecto efecte,
                r.fvencim venciment, s.cforpag forma_pagament, NULL companyia, r.cgescob,
                r.ctiprec, m.cestrec, m.fmovini, m.fmovfin, m.fmovdia,
                DECODE(r.ctiprec,
                       9, DECODE(m.cestrec, 0, itotalr, -itotalr),
                       DECODE(m.cestrec, 0, -itotalr, itotalr)) bruta,
                DECODE(r.ctiprec,
                       9, DECODE(m.cestrec, 0, iprinet, -iprinet),
                       DECODE(m.cestrec, 0, -iprinet, iprinet)) neta,
                DECODE(r.ctiprec,
                       9, DECODE(m.cestrec, 0, icombru, -icombru),
                       DECODE(m.cestrec, 0, -icombru, icombru)) comisio,
                s.sseguro
           FROM movrecibo m, vdetrecibos v, recibos r, seguros s, cnvpolizas c
          WHERE s.cempres = pcempres
            AND s.sseguro = c.sseguro
            AND s.sseguro = r.sseguro
            AND r.nrecibo = m.nrecibo
            AND m.nrecibo = v.nrecibo
            AND TRUNC(m.fmovini) BETWEEN pdata_ini AND pdata_fi
            AND(m.cestrec = 1
                OR(m.cestrec = 0
                   AND m.cestant = 1));

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         ptext := SQLERRM;
         RETURN 111348;
   END f_moviments_vida;

-------------------------------------------------------------------------------------------
   FUNCTION f_completa_dades(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pdata_fi IN DATE,
      ptext OUT VARCHAR2)
      RETURN NUMBER IS
-------------------------------------------------------------------------------------------
   BEGIN
      -- Cal veure el tipus de producte
      UPDATE cuadre_cc c
         SET ctipprod = (SELECT cvalpar
                           FROM parproductos
                          WHERE sproduc = c.sproduc
                            AND cparpro = 'TIPUSPRODCOR')
       WHERE c.cempres = pcempres
         AND c.fcierre = pdata_fi;

      -- Cal veure si el descobrament és d'un cobrament del periode actual
      UPDATE cuadre_cc c1
         SET cperact = 1
       WHERE c1.cempres = pcempres
         AND c1.fcierre = pdata_fi
         AND cestrec = 0   -- És un descobrament
         AND EXISTS(SELECT smovrec
                      FROM cuadre_cc c2
                     WHERE c2.cempres = pcempres
                       AND c2.fcierre = pdata_fi
                       AND c2.nrecibo = c1.nrecibo
                       AND c2.cestrec = 1   --cobrament
                       AND c2.fmovfin = c1.fmovini
                       AND c2.smovrec < c1.smovrec
                       AND TO_CHAR(c2.fmovini, 'mmyyyy') = TO_CHAR(c1.fmovini, 'mmyyyy'));   -- inici del mateix periode

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         ptext := SQLERRM;
         RETURN 111348;
   END f_completa_dades;

---------------------------------------------------------------------------------------------
   FUNCTION f_sinistres(
      pcempres IN NUMBER,
      pdata_ini IN DATE,
      pdata_fi IN DATE,
      psproces IN NUMBER,
      ptext OUT VARCHAR2)
      RETURN NUMBER IS
---------------------------------------------------------------------------------------------
   BEGIN
      -- BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'MODULO_SINI'), 0) = 0 THEN
         INSERT INTO siniestros_cc
                     (cempres, fcierre, fcalcul, sproces, cramo, cmodali, ctipseg, ccolect,
                      sproduc, polissa_ini, npoliza, nsinies, sidepag, fsinies, fordpag,
                      fefepag, cforpag, ccompani, isinret, sseguro)
            SELECT pcempres, pdata_fi, f_sysdate, psproces, s.cramo, s.cmodali, s.ctipseg,
                   s.ccolect, s.sproduc, c.polissa_ini, s.npoliza, si.nsinies, p.sidepag,
                   si.fsinies, p.fordpag, p.fefepag, p.cforpag, NVL(s.ccompani, pr.ccompani),
                   DECODE(p.ctippag, 3, -1, 1) * p.isinret, s.sseguro
              FROM pagosini p, siniestros si, seguros s, cnvpolizas c, productos pr
             WHERE s.cempres = pcempres
               AND s.sseguro = si.sseguro
               AND p.nsinies = si.nsinies
               AND c.sseguro(+) = s.sseguro
               AND pr.sproduc = s.sproduc
               AND p.fefepag BETWEEN pdata_ini AND pdata_fi
               AND p.cforpag <> 10
               AND p.cestpag = 2;
      ELSE
         INSERT INTO siniestros_cc
                     (cempres, fcierre, fcalcul, sproces, cramo, cmodali, ctipseg, ccolect,
                      sproduc, polissa_ini, npoliza, nsinies, sidepag, fsinies, fordpag,
                      fefepag, cforpag, ccompani, isinret, sseguro)
            SELECT pcempres, pdata_fi, f_sysdate, psproces, s.cramo, s.cmodali, s.ctipseg,
                   s.ccolect, s.sproduc, c.polissa_ini, s.npoliza, si.nsinies, p.sidepag,
                   si.fsinies, p.fordpag, m.fefepag, p.cforpag, NVL(s.ccompani, pr.ccompani),
                   DECODE(p.ctippag, 3, -1, 1) * p.isinret, s.sseguro
              FROM sin_tramita_movpago m, sin_tramita_pago p, sin_tramitacion t,
                   sin_siniestro si, seguros s, cnvpolizas c, productos pr
             WHERE s.cempres = pcempres
               AND s.sseguro = si.sseguro
               AND t.nsinies = si.nsinies
               AND p.nsinies = t.nsinies
               AND p.ntramit = t.ntramit
               AND c.sseguro(+) = s.sseguro
               AND pr.sproduc = s.sproduc
               AND m.fefepag BETWEEN pdata_ini AND pdata_fi
               AND p.cforpag <> 10
               AND m.nmovpag = (SELECT MAX(nmovpag)
                                  FROM sin_tramita_movpago
                                 WHERE sidepag = m.sidepag)
               AND m.cestpag = 2;
      END IF;

      -- Fin BUG 11595 - 02/11/2009 - APD - Adaptación al nuevo módulo de siniestros
      UPDATE siniestros_cc c
         SET ctipprod = (SELECT cvalpar
                           FROM parproductos
                          WHERE sproduc = c.sproduc
                            AND cparpro = 'TIPUSPRODCOR')
       WHERE c.cempres = pcempres
         AND c.fcierre = pdata_fi;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         ptext := SQLERRM;
         RETURN 111435;
   END f_sinistres;

-------------------------------------------------------------------------------------------
   PROCEDURE proces_batch_quadre(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pfcierre IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE) IS
-------------------------------------------------------------------------------------------
--    Procés que llança el tancament del quadre del c.corrent
--
      num_err        NUMBER := 0;
      text_error     VARCHAR2(500);
      pnnumlin       NUMBER;
      texto          VARCHAR2(400);
      indice_error   NUMBER := 0;
      v_estado       NUMBER;
      v_titulo       VARCHAR2(50);
      lctipemp       NUMBER;
   BEGIN
      IF pmodo = 1 THEN
         v_titulo := 'Proceso Cierre Diario (empresa ' || pcempres || ')';
      ELSE
         v_titulo := 'Proceso Cierre Mensual';
      END IF;

      --Insertamos en la tabla PROCESOSCAB el registro identificativo de proceso -----
      num_err := f_procesini(f_user, pcempres, 'CUADRE', v_titulo, psproces);
      COMMIT;

--   set transaction use rollback segment rollbig;
      IF num_err <> 0 THEN
         pcerror := 1;
         texto := f_axis_literales(num_err, pcidioma);
         pnnumlin := NULL;
         num_err := f_proceslin(psproces, SUBSTR(texto || ' ' || text_error, 1, 120), 0,
                                pnnumlin);
         COMMIT;
         SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
      ELSE
         -- Borrado de los registros que se corresponden al mes y empresa que vamos a tratar
         DELETE FROM cuadre_cc
               WHERE fcierre = pfcierre
                 AND cempres = pcempres;

         COMMIT;
         SET TRANSACTION USE ROLLBACK SEGMENT rollbig;

         DELETE FROM siniestros_cc
               WHERE cempres = pcempres
                 AND fcierre = pfcierre;

         COMMIT;
         SET TRANSACTION USE ROLLBACK SEGMENT rollbig;

         -- Obtenim si es corredoria o companyia
         BEGIN
            SELECT ctipemp
              INTO lctipemp
              FROM empresas
             WHERE cempres = pcempres;

            IF NVL(lctipemp, 0) = 0 THEN
               num_err := f_moviments_vida(pcempres, psproces,
                                           TO_DATE('01' || TO_CHAR(pfcierre, 'mmyyyy'),
                                                   'ddmmyyyy'),
                                           pfcierre, text_error);
            ELSE
               num_err := f_moviments_corredoria(pcempres, psproces,
                                                 TO_DATE('01' || TO_CHAR(pfcierre, 'mmyyyy'),
                                                         'ddmmyyyy'),
                                                 pfcierre, text_error);

               IF num_err = 0 THEN
                  num_err := f_sinistres(pcempres,
                                         TO_DATE('01' || TO_CHAR(pfcierre, 'mmyyyy'),
                                                 'ddmmyyyy'),
                                         pfcierre, psproces, text_error);
               END IF;
            END IF;

            IF num_err = 0 THEN
               num_err := f_completa_dades(pcempres, psproces, pfcierre, text_error);
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               -- error al llegir d'empreses
               num_err := 103290;
               text_error := SQLERRM;
         END;

         IF num_err <> 0 THEN
            v_estado := 1;
            pcerror := 1;
            texto := f_axis_literales(num_err, pcidioma);
            pnnumlin := NULL;
            num_err := f_proceslin(psproces, SUBSTR(texto || ' ' || text_error, 1, 120), 0,
                                   pnnumlin);
            COMMIT;
            SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
         ELSE
            v_estado := 0;
            COMMIT;
            SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
            pcerror := 0;
         END IF;
      END IF;

      num_err := f_procesfin(psproces, pcerror);
      pfproces := f_sysdate;
      COMMIT;
      SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
   END proces_batch_quadre;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_CUADRE_CC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CUADRE_CC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CUADRE_CC" TO "PROGRAMADORESCSI";
