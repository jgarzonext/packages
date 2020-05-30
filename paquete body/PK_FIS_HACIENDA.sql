--------------------------------------------------------
--  DDL for Package Body PK_FIS_HACIENDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_FIS_HACIENDA" IS
-- ****************************************************************
-- Justifico los NIF
-- ****************************************************************
/******************************************************************************
   NOMBRE:     PK_FIS_HACIENDA
   PROPÓSITO:

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        08/07/2009   DCT                1. 0010612: CRE - Error en la generació de pagaments automàtics.
                                              Canviar vista personas por tablas personas y añadir filtro de visión de agente
   2.0        02/11/2009  APD                 2. Bug 11595: CEM - Siniestros. Adaptación al nuevo módulo de siniestros
******************************************************************************/
   FUNCTION dni_pos(numnif IN VARCHAR2)
      RETURN VARCHAR2 IS
-- ------------------------------------------------------------
      xnumnif        VARCHAR2(14);
      xxnumnif       VARCHAR2(14);
      indice         NUMBER(1);
   BEGIN
      xnumnif := UPPER(LTRIM(RTRIM(numnif)));
      indice := 1;

      --
      IF LENGTH(xnumnif) > 9 THEN
         WHILE SUBSTR(indice, 1) = 0 LOOP
            indice := indice + 1;
         END LOOP;

         xnumnif := SUBSTR(xnumnif, indice + 1,(LENGTH(xnumnif) - indice));
      END IF;

      --
      IF SUBSTR(xnumnif, 1, 1) BETWEEN 'A' AND 'Z' THEN
         RETURN SUBSTR(xnumnif, 1, 1)
                || REPLACE(LPAD(SUBSTR(xnumnif, 2,(LENGTH(xnumnif) - 1)), 8), ' ', 0);
      ELSE
         RETURN REPLACE(LPAD(xnumnif, 9), ' ', 0);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
--   dbms_output.put_line('Error Calcula Nif:'||numnif||' Error:'||SQLERRM);
         RETURN numnif;
   END;

-- ****************************************************************
-- Busca el numero de orden sig. en FIS_ERROR_CARGA de una petición
-- ****************************************************************
   FUNCTION f_busca_num(psfiscab IN NUMBER, pnnumord OUT NUMBER)
      RETURN NUMBER IS
-- ------------------------------------------------------------
   BEGIN
      pnnumord := 0;

      SELECT NVL(MAX(nnumord), 0) + 1
        INTO pnnumord
        FROM fis_error_carga
       WHERE sfiscab = psfiscab;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pnnumord := 1;
   END;

-- ****************************************************************
-- Busca datos de una persona (NIF, TIDENTI, CPAIS)
-- ****************************************************************
   FUNCTION f_datos_personales(
      psperson IN NUMBER,
      pnnumnif OUT VARCHAR2,
      ptidenti OUT NUMBER,
      pcpais OUT NUMBER)
      RETURN NUMBER IS
      xnnumnif       VARCHAR2(14);
-- ------------------------------------------------------------
   BEGIN
      SELECT LTRIM(RTRIM(nnumnif)), tidenti, cpais
        INTO pnnumnif, ptidenti, pcpais
        FROM personas
       WHERE sperson = psperson;

      IF ptidenti IN(1, 4, 5, 6) THEN
         xnnumnif := dni_pos(pnnumnif);
         pnnumnif := RPAD(xnnumnif, 9);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
--        dbms_output.put_line('Error Personas:'||psperson||' Error:'||sqlerrm);
         pnnumnif := 0;
         ptidenti := 0;
         pcpais := 0;
         RETURN 1;
   END;

-- ****************************************************************
-- Cargar Registros
-- ****************************************************************
   PROCEDURE carga(
      pinicio IN NUMBER,   --YYYYMM
      pfinal IN NUMBER,   --YYYYMM
      ppetici IN NUMBER,   -- 1->Pagos,2->Cobros,3->Dos,4->347,5->345
      pcpagcob IN NUMBER,   -- 1->Cobros, 2->Pagos
      pempres IN NUMBER,
      pnumpet OUT NUMBER) IS
-- Definimos cursores
      CURSOR cur_prod IS
         SELECT   p.cramo, p.cmodali, p.ctipseg, p.ccolect, p.crepren
             FROM fis_producto p
            WHERE EXISTS(SELECT sproduc
                           FROM seguros
                          WHERE cramo = p.cramo
                            AND cmodali = p.cmodali
                            AND ctipseg = p.ctipseg
                            AND ccolect = p.ccolect)
              AND p.cempres = pempres
         ORDER BY p.cramo, p.cmodali, p.ctipseg, p.ccolect;

-- Definimos  campos
      prod           cur_prod%ROWTYPE;
      xinicio        NUMBER;
      xfinal         NUMBER;
      xnumpet        NUMBER;
      xnnumord       NUMBER;
      xsfiscab       NUMBER;
      xleidos        NUMBER;
      xgrabados      NUMBER;
      xcommit        NUMBER;
      error          NUMBER;
      num_err        NUMBER;
-- ------------------------------------------------------------
   BEGIN
      xinicio := pinicio;
      xfinal := pfinal;

--
      BEGIN
         SELECT MAX(nnumpet)
           INTO xnumpet
           FROM fis_cabcierre
          WHERE cempres = pempres
            AND nanyo = SUBSTR(pinicio, 1, 4)
            AND cpagcob = pcpagcob;
      EXCEPTION
         WHEN OTHERS THEN
            xnumpet := 0;
      END;

--
      IF xnumpet = 0
         OR xnumpet IS NULL THEN
         xnumpet := 1;
      ELSE
         xnumpet := xnumpet + 1;
      END IF;

--
      pnumpet := xnumpet;
--
      error := 0;

      SELECT sfiscab.NEXTVAL
        INTO xsfiscab
        FROM DUAL;

--
--
      BEGIN
         INSERT INTO fis_cabcierre
                     (sfiscab, cempres, nanyo, nnumpet,
                      mesini, mesfin, cpagcob, ccierre, fpeticion)
              VALUES (xsfiscab, pempres, SUBSTR(pinicio, 1, 4), xnumpet,
                      SUBSTR(pinicio, 5, 2), SUBSTR(pfinal, 5, 2), pcpagcob, 0, TRUNC(SYSDATE));

         COMMIT;
      EXCEPTION
         WHEN OTHERS THEN
            error := 1;
--     Error al insertar en la tabla FIS_CABCIERRE
            num_err := graba_error(xsfiscab, 140580, NULL, NULL, 1, NULL, 2, xnnumord);
--               DBMS_OUTPUT.PUT_LINE (' Error:'||SQLERRM);
      END;

--
      FOR i IN xinicio .. xfinal LOOP
--
         FOR prod IN cur_prod LOOP
            IF error = 0 THEN
               IF pcpagcob = 2 THEN
                  pk_fis_hacienda.carga_prestaciones(prod.cramo, prod.cmodali, prod.ctipseg,
                                                     prod.ccolect,
                                                     TO_DATE(xinicio || '01', 'yyyymmdd'),
                                                     LAST_DAY(TO_DATE(xinicio || '01',
                                                                      'yyyymmdd')),
                                                     xsfiscab, xnumpet, pempres, prod.crepren);
                  pk_fis_hacienda.carga_rentas(prod.cramo, prod.cmodali, prod.ctipseg,
                                               prod.ccolect,
                                               TO_DATE(xinicio || '01', 'yyyymmdd'),
                                               LAST_DAY(TO_DATE(xinicio || '01', 'yyyymmdd')),
                                               xsfiscab, xnumpet, pempres, prod.crepren);
                  pk_fis_hacienda.carga_siniestros(prod.cramo, prod.cmodali, prod.ctipseg,
                                                   prod.ccolect,
                                                   TO_DATE(xinicio || '01', 'yyyymmdd'),
                                                   LAST_DAY(TO_DATE(xinicio || '01',
                                                                    'yyyymmdd')),
                                                   xsfiscab, xnumpet, pempres, prod.crepren);
                  pk_fis_hacienda.carga_vencimientos(prod.cramo, prod.cmodali, prod.ctipseg,
                                                     prod.ccolect,
                                                     TO_DATE(xinicio || '01', 'yyyymmdd'),
                                                     LAST_DAY(TO_DATE(xinicio || '01',
                                                                      'yyyymmdd')),
                                                     xsfiscab, xnumpet, pempres, prod.crepren);
               ELSE
                  IF prod.cramo NOT IN(1) THEN
                     pk_fis_hacienda.carga_aporta_347(prod.cramo, prod.cmodali, prod.ctipseg,
                                                      prod.ccolect,
                                                      TO_DATE(xinicio || '01', 'yyyymmdd'),
                                                      LAST_DAY(TO_DATE(xinicio || '01',
                                                                       'yyyymmdd')),
                                                      xsfiscab, xnumpet, pempres,
                                                      prod.crepren);
                  END IF;

                  IF prod.cramo = 1 THEN
                     pk_fis_hacienda.carga_aporta_345(prod.cramo, prod.cmodali, prod.ctipseg,
                                                      prod.ccolect,
                                                      TO_DATE(xinicio || '01', 'yyyymmdd'),
                                                      LAST_DAY(TO_DATE(xinicio || '01',
                                                                       'yyyymmdd')),
                                                      xsfiscab, xnumpet, pempres,
                                                      prod.crepren);
                  END IF;
               END IF;
            END IF;
         END LOOP;

         xinicio := xinicio + 1;
      END LOOP;
   END;

-- ****************************************************************
-- Carga Aportaciones para modelo 347
-- ****************************************************************
   PROCEDURE carga_aporta_347(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pinicio IN DATE,
      pfinal IN DATE,
      psfiscab IN NUMBER,
      pnumpet IN NUMBER,
      pempres IN NUMBER,
      preprese IN NUMBER) IS
      -- Cursor de MERITACION
      CURSOR c_merita IS
         SELECT   m.cramo, m.cmodali, m.ctipseg, m.ccolect, m.nrecibo, m.sseguro, m.fefecto,
                  m.fcierre,
                  SUM(NVL(prima_meritada, 0) + NVL(prima_meritada_cia, 0)
                      -(NVL(prima_extornada, 0) - NVL(prima_extornada_cia, 0))
                      - NVL(prima_merit_anul, 0) - NVL(prima_merit_anul_cia, 0)
                      + NVL(prima_extorn_anul, 0) + NVL(prima_extorn_anul_cia, 0)) importe
             --SUM((NVL(PRIMA_MERITADA,0)    + NVL(PRIMA_MERITADA_CIA,0))) IMeritada,
             --SUM((NVL(PRIMA_EXTORNADA,0)   + NVL(PRIMA_EXTORNADA_CIA,0))) IExtorno,
             --SUM((NVL(PRIMA_MERIT_ANUL,0)  + NVL(PRIMA_MERIT_ANUL_CIA,0))) IMeranul,
             --SUM((NVL(PRIMA_EXTORN_ANUL,0) + NVL(PRIMA_EXTORN_ANUL_CIA ,0))) IExtanul
         FROM     meritacion m
            WHERE m.cempres = pempres
              AND m.cramo = pcramo
              AND m.cmodali BETWEEN NVL(pcmodali, 0) AND NVL(pcmodali, 99)
              AND m.ctipseg BETWEEN NVL(pctipseg, 0) AND NVL(pctipseg, 99)
              AND m.ccolect BETWEEN NVL(pccolect, 0) AND NVL(pccolect, 99)
              AND m.fcierre BETWEEN pinicio AND pfinal
         GROUP BY m.cramo, m.cmodali, m.ctipseg, m.ccolect, m.nrecibo, m.sseguro, m.fefecto,
                  m.fcierre
         ORDER BY m.sseguro, m.nrecibo;

      sel            c_merita%ROWTYPE;
      error          NUMBER;
      xssegant       seguros.sseguro%TYPE;
--
      xnasegur       NUMBER;
      xasegpol       NUMBER;
--
      xsperson1      personas.sperson%TYPE;
      xnnumnif1      personas.nnumnif%TYPE;
      xtidenti1      personas.tidenti%TYPE;
      xcdomici1      asegurados.cdomici%TYPE;
      xfmuerte1      asegurados.ffecmue%TYPE;
      xcpais1        personas.cpais%TYPE;
      xcprovin1      direcciones.cprovin%TYPE;
      no_1aseg       NUMBER(1);
--
      xsperson2      personas.sperson%TYPE;
      xnnumnif2      personas.nnumnif%TYPE;
      xtidenti2      personas.tidenti%TYPE;
      xcdomici2      asegurados.cdomici%TYPE;
      xfmuerte2      asegurados.ffecmue%TYPE;
      xcpais2        personas.cpais%TYPE;
      xcprovin2      direcciones.cprovin%TYPE;
      no_2aseg       NUMBER(1);
--
      xcestrec       NUMBER(01);
      xctiprec       NUMBER(02);
      ximporte       meritacion.prima_meritada%TYPE;
      xnorden        asegurados.norden%TYPE;
      xfmovimi       DATE;
      xsfisdco       NUMBER;
--
      xnnumord       NUMBER;
      num_err        NUMBER;
      xleidos        NUMBER;
      xgrabados      NUMBER;
      xcommit        NUMBER;
   BEGIN
      xssegant := 0;
      xleidos := 0;
      xgrabados := 0;
      xcommit := 0;

      FOR sel IN c_merita LOOP
--
         BEGIN
            xleidos := xleidos + 1;
            xcommit := xcommit + 1;
            no_2aseg := 0;
            no_1aseg := 0;
            error := 0;

            IF xssegant <> sel.sseguro THEN
               xsperson1 := NULL;
               xnnumnif1 := NULL;
               xtidenti1 := NULL;
               xcdomici1 := NULL;
               xfmuerte1 := NULL;
               xcpais1 := NULL;
               xcprovin1 := NULL;
               xsperson2 := NULL;
               xnnumnif2 := NULL;
               xtidenti2 := NULL;
               xcdomici2 := NULL;
               xfmuerte2 := NULL;
               xcpais2 := NULL;
               xcprovin2 := NULL;
--
               xnasegur := 0;
               xnorden := 1;

--
-- Busco los asegurados de la póliza.
--
               FOR per IN (SELECT   *
                               FROM asegurados
                              WHERE sseguro = sel.sseguro
                           ORDER BY norden) LOOP
                  IF xnorden = 1 THEN
                     error := f_datos_personales(per.sperson, xnnumnif1, xtidenti1, xcpais1);

                     IF error = 0 THEN
                        xsperson1 := per.sperson;
                        xnasegur := 1;
                        xasegpol := 1;
                        xcdomici1 := per.cdomici;
                        xfmuerte1 := per.ffecmue;

                        BEGIN
                           SELECT cprovin
                             INTO xcprovin1
                             FROM direcciones
                            WHERE sperson = per.sperson
                              AND cdomici = per.cdomici;
                        EXCEPTION
                           WHEN OTHERS THEN
                              xcprovin1 := NULL;
                        END;
                     ELSE
           --  Error al leer la tabla personas
--DBMS_OUTPUT.put_line('APORTACIONES 347 ERROR:'||SQLERRM);
                        num_err := graba_error(psfiscab, 104389, per.sperson, sel.sseguro, 1,
                                               sel.nrecibo, 3, xnnumord);
                     END IF;
                  ELSE
                     error := f_datos_personales(per.sperson, xnnumnif2, xtidenti2, xcpais2);

                     IF error = 0 THEN
                        xsperson2 := per.sperson;
                        xnasegur := 2;
                        xasegpol := 2;
                        xcdomici2 := per.cdomici;
                        xfmuerte2 := per.ffecmue;

                        BEGIN
                           SELECT cprovin
                             INTO xcprovin2
                             FROM direcciones
                            WHERE sperson = per.sperson
                              AND cdomici = per.cdomici;
                        EXCEPTION
                           WHEN OTHERS THEN
                              xcprovin2 := NULL;
                        END;

                        IF xcprovin2 IS NULL
                           OR xcprovin2 = 0 THEN
                           xcprovin2 := xcprovin1;
                        END IF;
                     ELSE
           --  Error al leer la tabla personas
--DBMS_OUTPUT.put_line('APORTACIONES 347 ERROR:'||SQLERRM);
                        num_err := graba_error(psfiscab, 104389, per.sperson, sel.sseguro, 1,
                                               sel.nrecibo, 3, xnnumord);
                     END IF;
                  END IF;

                  xnorden := xnorden + 1;
               END LOOP;
            END IF;   -- Otro sseguro

--
--  Inserto los recibos
--
--    IF sel.imeritada <> 0  THEN
--     xctiprec := 3; ximporte := sel.imeritada; xcestrec := 1;
--    ELSIF sel.imeranul <> 0 THEN
--     xctiprec := 3; ximporte := sel.imeranul * -1; xcestrec := 2;
--    ELSIF sel.iextorno <> 0 THEN
--     xctiprec := 9; ximporte := sel.iextorno * -1; xcestrec := 1;
--    ELSIF sel.iextanul <> 0 THEN
--     xctiprec := 9; ximporte := sel.iextanul;  xcestrec := 2;
--    ELSE
            ximporte := sel.importe;

            IF sel.importe > 0 THEN
               xctiprec := 3;
               xcestrec := 0;
            ELSIF sel.importe < 0 THEN
               xctiprec := 3;
               xcestrec := 2;
            ELSE
               xctiprec := 0;
               ximporte := 0;
               xcestrec := 0;
               error := 1;   -- No grabo recibo
            END IF;

--
            IF error = 0 THEN
               IF preprese = 1 THEN   -- Hay representante grabo el titular y represent.
                  BEGIN
                     SELECT sfisdco.NEXTVAL
                       INTO xsfisdco
                       FROM DUAL;

                     INSERT INTO fis_detcierrecobro
                                 (sfiscab, sfisdco, cramo, cmodali, ctipseg,
                                  ccolect, nnumpet,
                                  pfiscal, sseguro,
                                  spersonp, nnumnifp, tidentip, cdomicip, sperson1,
                                  nnumnif1, tidenti1, cdomici1, nrecibo, ctiprec,
                                  cestrec, fefecto, fvencim, fanurec, iimporte,
                                  cprovin, cpaisret,
                                  csubtipo)
                          VALUES (psfiscab, xsfisdco, sel.cramo, sel.cmodali, sel.ctipseg,
                                  sel.ccolect, pnumpet,
                                  TO_NUMBER(TO_CHAR(sel.fcierre, 'yyyymm')), sel.sseguro,
                                  xsperson1, xnnumnif1, xtidenti1, xcdomici1, xsperson2,
                                  xnnumnif2, xtidenti2, xcdomici2, sel.nrecibo, xctiprec,
                                  xcestrec, sel.fefecto, NULL, NULL, ximporte,
                                  REPLACE(LPAD(xcprovin1, 2), ' ', '0'), xcpais1,
                                  DECODE(xcpais1, 100, 347, 3471));

                     xgrabados := xgrabados + 1;
                  EXCEPTION
                     WHEN OTHERS THEN
           --  Error al insertar en la tabla FIS_DETCIERREPAGO
--DBMS_OUTPUT.put_line('APORTACIONES 347 ERROR:'||SQLERRM);
                        num_err := graba_error(psfiscab, 140582, xsperson1, sel.sseguro, 1,
                                               sel.nrecibo, 3, xnnumord);
                  END;
--
               ELSE   -- No hay representante
                  IF xfmuerte1 IS NOT NULL THEN   -- Esta muerto el 1er. Asegurado
                     IF sel.fefecto > xfmuerte1 THEN   -- El recibo es post. a la muerte
                        no_1aseg := 1;
                        xnasegur := 1;
                     ELSE   -- El recibo es anterior a la muerte
                        no_1aseg := 0;
                     END IF;
                  ELSE   -- No esta muerto
                     no_1aseg := 0;

                     IF xfmuerte2 IS NOT NULL THEN   -- Esta muerto el 2on. Asegurado
                        IF sel.fefecto > xfmuerte2 THEN   -- El recibo es post. a la muerte
                           no_2aseg := 1;
                           xnasegur := 1;
                        ELSE   -- El recibo es anterior a la muerte
                           no_2aseg := 0;
                        END IF;
                     ELSE   -- No esta muerto
                        no_2aseg := 0;
                     END IF;
                  END IF;

--
                  IF no_1aseg = 0 THEN
                     BEGIN
                        SELECT sfisdco.NEXTVAL
                          INTO xsfisdco
                          FROM DUAL;

                        INSERT INTO fis_detcierrecobro
                                    (sfiscab, sfisdco, cramo, cmodali, ctipseg,
                                     ccolect, nnumpet,
                                     pfiscal, sseguro,
                                     spersonp, nnumnifp, tidentip, cdomicip, sperson1,
                                     nnumnif1, tidenti1, cdomici1, nrecibo, ctiprec, cestrec,
                                     fefecto, fvencim, fanurec, iimporte,
                                     cprovin, cpaisret,
                                     csubtipo)
                             VALUES (psfiscab, xsfisdco, sel.cramo, sel.cmodali, sel.ctipseg,
                                     sel.ccolect, pnumpet,
                                     TO_NUMBER(TO_CHAR(sel.fcierre, 'yyyymm')), sel.sseguro,
                                     xsperson1, xnnumnif1, xtidenti1, xcdomici1, NULL,
                                     NULL, NULL, NULL, sel.nrecibo, xctiprec, xcestrec,
                                     sel.fefecto, NULL, NULL, ROUND((ximporte / xnasegur), 2),
                                     REPLACE(LPAD(xcprovin1, 2), ' ', '0'), xcpais1,
                                     DECODE(xcpais1, 100, 347, 3471));

                        xgrabados := xgrabados + 1;
                     EXCEPTION
                        WHEN OTHERS THEN
           -- Error al insertar en la tabla FIS_DETCIERRECOBRO
--DBMS_OUTPUT.put_line('APORTACIONES 347 ERROR:'||SQLERRM);
                           num_err := graba_error(psfiscab, 140582, xsperson1, sel.sseguro, 1,
                                                  sel.nrecibo, 3, xnnumord);
                     END;
                  END IF;

-- Si hay otro asegurado
                  IF xasegpol = 2 THEN
                     IF no_2aseg = 0 THEN
                        BEGIN
                           SELECT sfisdco.NEXTVAL
                             INTO xsfisdco
                             FROM DUAL;

                           INSERT INTO fis_detcierrecobro
                                       (sfiscab, sfisdco, cramo, cmodali,
                                        ctipseg, ccolect, nnumpet,
                                        pfiscal,
                                        sseguro, spersonp, nnumnifp, tidentip,
                                        cdomicip, sperson1, nnumnif1, tidenti1, cdomici1,
                                        nrecibo, ctiprec, cestrec, fefecto, fvencim,
                                        fanurec,
                                        iimporte,
                                        cprovin, cpaisret,
                                        csubtipo)
                                VALUES (psfiscab, xsfisdco, sel.cramo, sel.cmodali,
                                        sel.ctipseg, sel.ccolect, pnumpet,
                                        TO_NUMBER(TO_CHAR(sel.fcierre, 'yyyymm')),
                                        sel.sseguro, xsperson2, xnnumnif2, xtidenti2,
                                        xcdomici2, NULL, NULL, NULL, NULL,
                                        sel.nrecibo, xctiprec, xcestrec, sel.fefecto, NULL,
                                        NULL,
                                        DECODE(xnasegur,
                                               1, ximporte,
                                               (ximporte - ROUND((ximporte / xnasegur), 2))),
                                        REPLACE(LPAD(xcprovin2, 2), ' ', '0'), xcpais2,
                                        DECODE(xcpais2, 100, 347, 3471));

                           xgrabados := xgrabados + 1;
                        EXCEPTION
                           WHEN OTHERS THEN
               -- Error al Insertar en la tabla FIS_DETCIERRECOBRO
--DBMS_OUTPUT.put_line('APORTACIONES 347 ERROR:'||SQLERRM);
                              num_err := graba_error(psfiscab, 140582, xsperson1, sel.sseguro,
                                                     1, sel.nrecibo, 3, xnnumord);
                        END;
                     END IF;
                  END IF;   --  Si hay otro asegurado
               END IF;   --  Hay Representante

               IF xcommit > 400 THEN
                  xcommit := 0;
                  COMMIT;
               END IF;
            END IF;   -- Hay Error

            xssegant := sel.sseguro;
         EXCEPTION
            WHEN OTHERS THEN
               xssegant := sel.sseguro;
       -- Error no controlado
--DBMS_OUTPUT.put_line('APORTACIONES 347 ERROR:'||SQLERRM);
               num_err := graba_error(psfiscab, 111250, xsperson1, sel.sseguro, 1,
                                      sel.nrecibo, 3, xnnumord);
         END;
      END LOOP;   -- recibos

      COMMIT;
   END;

-- ****************************************************************
-- Carga Aportaciones para modelo 345
-- ****************************************************************
   PROCEDURE carga_aporta_345(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pinicio IN DATE,
      pfinal IN DATE,
      psfiscab IN NUMBER,
      pnumpet IN NUMBER,
      pempres IN NUMBER,
      preprese IN NUMBER) IS
      CURSOR c_seguros IS
         SELECT   cramo, cmodali, ctipseg, ccolect, sseguro, fefecto
             FROM seguros
            WHERE cramo = pcramo
              AND cmodali BETWEEN NVL(pcmodali, 0) AND NVL(pcmodali, 99)
              AND ctipseg BETWEEN NVL(pctipseg, 0) AND NVL(pctipseg, 99)
              AND ccolect BETWEEN NVL(pccolect, 0) AND NVL(pccolect, 99)
              AND(fanulac >= pinicio
                  OR fanulac IS NULL)
              AND fefecto <= pfinal
              AND(fefecto <> fanulac
                  OR fanulac IS NULL)
              AND csituac IN(0, 1, 2, 3)
         ORDER BY cramo, cmodali, ctipseg, ccolect, sseguro;

      sel            c_seguros%ROWTYPE;
      error          NUMBER;
      xssegant       seguros.sseguro%TYPE;
--
      xnasegur       NUMBER;
      xsfisdco       NUMBER;
--
      xsperson1      personas.sperson%TYPE;
      xnnumnif1      personas.nnumnif%TYPE;
      xtidenti1      personas.tidenti%TYPE;
      xcdomici1      asegurados.cdomici%TYPE;
      xcpais1        personas.cpais%TYPE;
      xcprovin1      direcciones.cprovin%TYPE;
      no_1aseg       NUMBER(1);
--
      xsperson2      personas.sperson%TYPE;
      xnnumnif2      personas.nnumnif%TYPE;
      xtidenti2      personas.tidenti%TYPE;
      xcdomici2      asegurados.cdomici%TYPE;
      xcpais2        personas.cpais%TYPE;
      xcprovin2      direcciones.cprovin%TYPE;
      no_2aseg       NUMBER(1);
--
      xcestrec       NUMBER(01);
      xctiprec       NUMBER(02);
      ximporte       meritacion.prima_meritada%TYPE;
      xnorden        asegurados.norden%TYPE;
      xfmovimi       DATE;
--
      xnnumord       NUMBER;
      num_err        NUMBER;
      xleidos        NUMBER;
      xgrabados      NUMBER;
      xcommit        NUMBER;
      xcsubtipo      fis_detcierrecobro.csubtipo%TYPE;
   BEGIN
      xssegant := 0;
      xleidos := 0;
      xgrabados := 0;
      xcommit := 0;

      FOR sel IN c_seguros LOOP
--
         BEGIN
            xleidos := xleidos + 1;
            error := 0;

            IF xssegant <> sel.sseguro THEN
--
               xsperson1 := NULL;
               xnnumnif1 := NULL;
               xtidenti1 := NULL;
               xcdomici1 := NULL;
               xcpais1 := NULL;
               xcprovin1 := NULL;
               xsperson2 := NULL;
               xnnumnif2 := NULL;
               xtidenti2 := NULL;
               xcdomici2 := NULL;
               xcpais2 := NULL;
               xcprovin2 := NULL;
--
               xnasegur := 0;

--
-- Busco los asegurados de la póliza.
--
               FOR per IN (SELECT   *
                               FROM asegurados
                              WHERE sseguro = sel.sseguro
                           ORDER BY norden) LOOP
                  error := f_datos_personales(per.sperson, xnnumnif1, xtidenti1, xcpais1);

                  IF error = 0 THEN
                     xsperson1 := per.sperson;
                     xnasegur := 1;
                     xcdomici1 := per.cdomici;

                     BEGIN
                        SELECT cprovin
                          INTO xcprovin1
                          FROM direcciones
                         WHERE sperson = per.sperson
                           AND cdomici = per.cdomici;
                     EXCEPTION
                        WHEN OTHERS THEN
                           xcprovin1 := NULL;
                     END;
                  ELSE
            -- Error al leer la tabla de Personas
--DBMS_OUTPUT.put_line('APORTACIONES 345 ERROR:'||SQLERRM);
                     num_err := graba_error(psfiscab, 104389, per.sperson, sel.sseguro, 1,
                                            NULL, 4, xnnumord);
                  END IF;
               END LOOP;
            END IF;   -- Otro sseguro

-- Busco las aportaciones de la póliza
            FOR cta IN (SELECT sseguro, fvalmov, imovimi, cmovimi, spermin, nrecibo
                          FROM ctaseguro
                         WHERE cmovimi IN(1, 2, 4, 10, 49, 51)
--               AND NVL(cmovanu, 0) = 0
                           AND imovimi > 0
                           AND sseguro = sel.sseguro
                           AND TRUNC(fvalmov) BETWEEN pinicio AND pfinal) LOOP
--
               BEGIN
                  IF cta.spermin IS NOT NULL THEN   -- Las aportaciones las ha hecho otro
                     xnnumnif2 := xnnumnif1;
                     xtidenti2 := xtidenti1;
                     xcpais2 := xcpais1;
                     xcdomici2 := xcdomici1;
                     xsperson2 := xsperson1;
                     xcprovin2 := xcprovin1;
--
                     xsperson1 := NULL;
                     xnnumnif1 := NULL;
                     xtidenti1 := NULL;
                     xcdomici1 := NULL;
                     xcpais1 := NULL;
                     xcprovin1 := NULL;
                     error := f_datos_personales(cta.spermin, xnnumnif1, xtidenti1, xcpais1);

                     IF error = 0 THEN
                        xsperson1 := cta.spermin;
                        xcprovin1 := xcprovin2;
                     ELSE
         -- Error al leer la tabla de Personas
--DBMS_OUTPUT.put_line('APORTACIONES 345 ERROR:'||SQLERRM);
                        num_err := graba_error(psfiscab, 104389, xsperson1, sel.sseguro, 1,
                                               cta.nrecibo, 4, xnnumord);
                     END IF;
                  END IF;

--
                  IF xcpais1 = 100 THEN
                     xcsubtipo := 345;
                  ELSE
                     xcsubtipo := 3451;
                  END IF;

--
                  IF cta.cmovimi IN(1, 2, 4) THEN
                     xctiprec := 3;
                     ximporte := cta.imovimi;
                     xcestrec := 1;
                  ELSE
                     xctiprec := 9;
                     ximporte := cta.imovimi * -1;
                     xcestrec := 2;
                  END IF;

--
--  Inserto los recibos
--
                  IF error = 0 THEN
                     BEGIN
                        SELECT sfisdco.NEXTVAL
                          INTO xsfisdco
                          FROM DUAL;

                        INSERT INTO fis_detcierrecobro
                                    (sfiscab, sfisdco, cramo, cmodali, ctipseg,
                                     ccolect, nnumpet,
                                     pfiscal, sseguro,
                                     spersonp, nnumnifp, tidentip, cdomicip, sperson1,
                                     nnumnif1, tidenti1, cdomici1, nrecibo,
                                     ctiprec, cestrec, fefecto, fvencim, fanurec, iimporte,
                                     cprovin, cpaisret, csubtipo)
                             VALUES (psfiscab, xsfisdco, sel.cramo, sel.cmodali, sel.ctipseg,
                                     sel.ccolect, pnumpet,
                                     TO_NUMBER(TO_CHAR(cta.fvalmov, 'yyyymm')), sel.sseguro,
                                     xsperson1, xnnumnif1, xtidenti1, xcdomici1, xsperson2,
                                     xnnumnif2, xtidenti2, xcdomici2, NVL(cta.nrecibo, 0),
                                     xctiprec, xcestrec, cta.fvalmov, NULL, NULL, ximporte,
                                     REPLACE(LPAD(xcprovin1, 2), ' ', '0'), xcpais1, xcsubtipo);

                        xgrabados := xgrabados + 1;
                        xcommit := xcommit + 1;
                     EXCEPTION
                        WHEN OTHERS THEN
            -- Error al Insertar en FIS_DETCIERRECOBRO
--DBMS_OUTPUT.put_line('APORTACIONES 345 ERROR:'||SQLERRM);
                           num_err := graba_error(psfiscab, 140582, xsperson1, sel.sseguro, 1,
                                                  cta.nrecibo, 4, xnnumord);
                     END;

                     IF xcommit > 400 THEN
                        xcommit := 0;
                        COMMIT;
                     END IF;

                     IF cta.spermin IS NOT NULL THEN   -- Las aportaciones las ha hecho otro
                        xnnumnif1 := xnnumnif2;
                        xtidenti1 := xtidenti2;
                        xcpais1 := xcpais2;
                        xcdomici1 := xcdomici2;
                        xsperson1 := xsperson2;
                        xcprovin1 := xcprovin2;
                     END IF;
                  END IF;   -- Hay Error
               END;
--
            END LOOP;   -- ctaseguro

            xssegant := sel.sseguro;

            IF xcommit > 400 THEN
               xcommit := 0;
               COMMIT;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               xssegant := sel.sseguro;
         -- Error No controlado
--DBMS_OUTPUT.put_line('APORTACIONES 345 ERROR:'||SQLERRM);
               num_err := graba_error(psfiscab, 111250, xsperson1, sel.sseguro, 1, NULL, 4,
                                      xnnumord);
         END;
      END LOOP;   -- seguros

--DBMS_OUTPUT.put_line('Leidos:'||xleidos||' Comit:'||xcommit||' Grabados:'||xgrabados);
      COMMIT;
--
   END;

-- ****************************************************************
-- Carga Rentas
-- ****************************************************************
   PROCEDURE carga_rentas(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pinicio IN DATE,
      pfinal IN DATE,
      psfiscab IN NUMBER,
      pnumpet IN NUMBER,
      pempres IN NUMBER,
      preprese IN NUMBER) IS
      -- Cursor de RECIBOS de Rentas
      CURSOR c_pagren IS
         SELECT   p.srecren, p.sseguro, p.sperson, p.ffecpag, p.isinret, p.pretenc, p.iretenc,
                  p.iconret, p.ibase, s.cramo, s.cmodali, s.ctipseg, s.ccolect
             FROM pagosrenta p, seguros s
            WHERE p.sseguro = s.sseguro
              AND s.cramo = pcramo
              AND s.cmodali BETWEEN NVL(pcmodali, 0) AND NVL(pcmodali, 99)
              AND s.ctipseg BETWEEN NVL(pctipseg, 0) AND NVL(pctipseg, 99)
              AND s.ccolect BETWEEN NVL(pccolect, 0) AND NVL(pccolect, 99)
              AND p.ffecpag BETWEEN pinicio AND pfinal
         ORDER BY p.sseguro;

      CURSOR c_paganu IS
         SELECT   p.srecren, p.sseguro, p.sperson, m.cestrec, p.isinret, p.pretenc, p.iretenc,
                  p.iconret, p.ibase, m.fmovini, s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                  m.fefecto
             FROM pagosrenta p, movpagren m, seguros s
            WHERE p.srecren = m.srecren
              AND m.cestrec = 2
              AND p.sseguro = s.sseguro
              AND s.cramo = pcramo
              AND s.cmodali BETWEEN NVL(pcmodali, 0) AND NVL(pcmodali, 99)
              AND s.ctipseg BETWEEN NVL(pctipseg, 0) AND NVL(pctipseg, 99)
              AND s.ccolect BETWEEN NVL(pccolect, 0) AND NVL(pccolect, 99)
              AND TRUNC(m.fefecto) BETWEEN pinicio AND pfinal
         ORDER BY p.sseguro;

      ren            c_pagren%ROWTYPE;   -- Previstos pagar
      anu            c_paganu%ROWTYPE;   -- Pagos Anulados
      error          NUMBER;
      xssegant       seguros.sseguro%TYPE;
      xcsubtipo      fis_detcierrepago.csubtipo%TYPE;
      xsigno         CHAR(1);
--
      xnasegur       NUMBER;
--
      xsperson1      personas.sperson%TYPE;
      xnnumnif1      personas.nnumnif%TYPE;
      xtidenti1      personas.tidenti%TYPE;
      xcdomici1      asegurados.cdomici%TYPE;
      xcpais1        personas.cpais%TYPE;
      xcprovin1      direcciones.cprovin%TYPE;
--
      xsperson2      personas.sperson%TYPE;
      xnnumnif2      personas.nnumnif%TYPE;
      xtidenti2      personas.tidenti%TYPE;
      xcdomici2      asegurados.cdomici%TYPE;
      xcpais2        personas.cpais%TYPE;
      xcprovin2      direcciones.cprovin%TYPE;
--
      xspersonp      personas.sperson%TYPE;
      xnnumnifp      personas.nnumnif%TYPE;
      xtidentip      personas.tidenti%TYPE;
      xcdomicip      asegurados.cdomici%TYPE;
      xcpaisp        personas.cpais%TYPE;
      xcprovinp      direcciones.cprovin%TYPE;
--
      xspersonr      personas.sperson%TYPE;
      xnnumnifr      personas.nnumnif%TYPE;
      xtidentir      personas.tidenti%TYPE;
      xcdomicir      asegurados.cdomici%TYPE;
      xcpaisr        personas.cpais%TYPE;
      xcprovinr      direcciones.cprovin%TYPE;
--
      xcestrec       NUMBER(01);
      xfmovimi       DATE;
--
      xsfisdpa       NUMBER;
      xleidos        NUMBER;
      xgrabados      NUMBER;
      xnnumord       NUMBER;
      num_err        NUMBER;
-- ------------------------------------------------------------
   BEGIN
      xssegant := 0;
      xleidos := 0;
      xgrabados := 0;

--  dbms_output.put_line('*************** Rentas *************');
      FOR ren IN c_pagren LOOP
--
         BEGIN
            xleidos := xleidos + 1;
            error := 0;

            IF xssegant <> ren.sseguro THEN
               xsperson1 := NULL;
               xnnumnif1 := NULL;
               xtidenti1 := NULL;
               xcdomici1 := NULL;
               xcpais1 := NULL;
               xcprovin1 := NULL;
               xsperson2 := NULL;
               xnnumnif2 := NULL;
               xtidenti2 := NULL;
               xcdomici2 := NULL;
               xcpais2 := NULL;
               xcprovin2 := NULL;

-- Busco los asegurados de la póliza
               FOR per IN (SELECT *
                             FROM asegurados
                            WHERE sseguro = ren.sseguro) LOOP
                  IF per.norden = 1 THEN
                     error := f_datos_personales(per.sperson, xnnumnif1, xtidenti1, xcpais1);

                     IF error = 0 THEN
                        xsperson1 := per.sperson;
                        xnasegur := 1;
                        xcdomici1 := per.cdomici;

                        BEGIN
                           SELECT cprovin
                             INTO xcprovin1
                             FROM direcciones
                            WHERE sperson = per.sperson
                              AND cdomici = per.cdomici;
                        EXCEPTION
                           WHEN OTHERS THEN
                              xcprovin1 := NULL;
                        END;
                     ELSE
--DBMS_OUTPUT.put_line('RENTAS ERROR:'||SQLERRM);
                        num_err := graba_error(psfiscab, 104389, per.sperson, ren.sseguro, 1,
                                               ren.srecren, 5, xnnumord);
                     END IF;
                  ELSE
                     error := f_datos_personales(per.sperson, xnnumnif2, xtidenti2, xcpais2);

                     IF error = 0 THEN
                        xsperson2 := per.sperson;
                        xnasegur := 2;
                        xcdomici2 := per.cdomici;

                        BEGIN
                           SELECT cprovin
                             INTO xcprovin2
                             FROM direcciones
                            WHERE sperson = per.sperson
                              AND cdomici = per.cdomici;
                        EXCEPTION
                           WHEN OTHERS THEN
                              xcprovin2 := NULL;
                        END;

                        -- No tiene Direccion hay que poner la del 1er Asegurado
                        IF xcprovin2 IS NULL
                           OR xcprovin2 = 0 THEN
                           xcprovin2 := xcprovin1;
                        END IF;
                     ELSE
--DBMS_OUTPUT.put_line('RENTAS ERROR:'||SQLERRM);
                        num_err := graba_error(psfiscab, 104389, per.sperson, ren.sseguro, 1,
                                               ren.srecren, 5, xnnumord);
                     END IF;
                  END IF;
               END LOOP;
            END IF;

--
            xspersonp := NULL;
            xnnumnifp := NULL;
            xtidentip := NULL;
            xcdomicip := NULL;
            xcpaisp := NULL;
            xcprovinp := NULL;
            xspersonr := NULL;
            xnnumnifr := NULL;
            xtidentir := NULL;
            xcdomicir := NULL;
            xcpaisr := NULL;
            xcprovinr := NULL;

            IF xsperson1 = ren.sperson
               OR xsperson2 = ren.sperson THEN
               IF xsperson1 = ren.sperson THEN
                  xspersonp := xsperson1;
                  xnnumnifp := xnnumnif1;
                  xtidentip := xtidenti1;
                  xcdomicip := xcdomici1;
                  xcpaisp := xcpais1;
                  xcprovinp := xcprovin1;

                  IF preprese = 1 THEN
                     xspersonr := xsperson2;
                     xnnumnifr := xnnumnif2;
                     xtidentir := xtidenti2;
                     xcdomicir := xcdomici2;
                     xcpaisr := xcpais2;
                     xcprovinr := xcprovin2;
                  END IF;
               ELSE
                  xspersonp := xsperson2;
                  xnnumnifp := xnnumnif2;
                  xtidentip := xtidenti2;
                  xcdomicip := xcdomici2;
                  xcpaisp := xcpais2;
                  xcprovinp := xcprovin2;
               END IF;
            END IF;

--
            IF error = 0 THEN
               IF ren.pretenc < 1 THEN
                  ren.pretenc := ren.pretenc * 100;
               END IF;

-- Decidimos el subtipo que es
               xcsubtipo := NULL;

               IF ren.ibase <> 0
                  AND ren.iretenc = 0
                  AND ren.pretenc = 0 THEN
                  xcsubtipo := 296;
               ELSIF ren.ibase = 0
                     AND ren.iretenc = 0 THEN
                  xcsubtipo := 999;
               ELSIF ren.ibase <> 0
                     AND ren.iretenc <> 0
                     AND ren.pretenc <> 0 THEN
                  IF xcpais1 = 100 THEN
                     xcsubtipo := 188;
                  ELSE
                     xcsubtipo := 296;
                  END IF;
               END IF;

--
               IF ren.ibase < 0 THEN
                  xsigno := 'N';
               ELSE
                  xsigno := 'P';
               END IF;

--
               IF ren.pretenc <> 0
                  AND ren.iretenc = 0 THEN
                  ren.pretenc := 0;
               END IF;

--
               BEGIN
                  SELECT sfisdpa.NEXTVAL
                    INTO xsfisdpa
                    FROM DUAL;

                  INSERT INTO fis_detcierrepago
                              (sfiscab, sfisdpa, cramo, cmodali, ctipseg,
                               ccolect, nnumpet,
                               pfiscal, sseguro,
                               spersonp, nnumnifp, tidentip, cdomicip, sperson1,
                               nnumnif1, tidenti1, cdomici1, ctipo, ndocum, cestrec,
                               fpago, ibruto, iresrcm, iresred, ibase, pretenc,
                               iretenc, ineto, cpaisret, csubtipo, csigbase,
                               cprovin)
                       VALUES (psfiscab, xsfisdpa, ren.cramo, ren.cmodali, ren.ctipseg,
                               ren.ccolect, pnumpet,
                               TO_NUMBER(TO_CHAR(ren.ffecpag, 'YYYYMM')), ren.sseguro,
                               xspersonp, xnnumnifp, xtidentip, xcdomicip, xspersonr,
                               xnnumnifr, xtidentir, xcdomicir, 'REN', ren.srecren, 1,
                               ren.ffecpag, ren.isinret, 0, 0, ren.ibase, ren.pretenc,
                               ren.iretenc, ren.iconret, xcpaisp, xcsubtipo, xsigno,
                               REPLACE(LPAD(xcprovinp, 2), ' ', '0'));

                  xgrabados := xgrabados + 1;
               EXCEPTION
                  WHEN OTHERS THEN
             -- Error al leer la tabla FIS_DETCIERREPAGO
--DBMS_OUTPUT.put_line('RENTAS ERROR:'||SQLERRM);
                     num_err := graba_error(psfiscab, 140581, xsperson1, ren.sseguro, 1,
                                            ren.srecren, 5, xnnumord);
               END;

               COMMIT;
            END IF;

            xssegant := ren.sseguro;
         EXCEPTION
            WHEN OTHERS THEN
               xssegant := ren.sseguro;
         -- Error no controlado
--DBMS_OUTPUT.put_line('RENTAS ERROR:'||SQLERRM);
               num_err := graba_error(psfiscab, 111250, ren.sperson, ren.sseguro, 1,
                                      ren.srecren, 5, xnnumord);
         END;
      END LOOP;   -- rentas

--
-- Anulados
--
      xssegant := 0;
      xleidos := 0;
      xgrabados := 0;
      xsigno := NULL;

      FOR anu IN c_paganu LOOP
--
         BEGIN
            xleidos := xleidos + 1;
            error := 0;

            IF xssegant <> anu.sseguro THEN
               xsperson1 := NULL;
               xnnumnif1 := NULL;
               xtidenti1 := NULL;
               xcdomici1 := NULL;
               xcpais1 := NULL;
               xcprovin1 := NULL;
               xsperson2 := NULL;
               xnnumnif2 := NULL;
               xtidenti2 := NULL;
               xcdomici2 := NULL;
               xcpais2 := NULL;
               xcprovin2 := NULL;

-- Busco los asegurados de la póliza
               FOR per IN (SELECT *
                             FROM asegurados
                            WHERE sseguro = anu.sseguro) LOOP
                  IF per.norden = 1 THEN
                     error := f_datos_personales(per.sperson, xnnumnif1, xtidenti1, xcpais1);

                     IF error = 0 THEN
                        xsperson1 := per.sperson;
                        xnasegur := 1;
                        xcdomici1 := per.cdomici;

                        BEGIN
                           SELECT cprovin
                             INTO xcprovin1
                             FROM direcciones
                            WHERE sperson = per.sperson
                              AND cdomici = per.cdomici;
                        EXCEPTION
                           WHEN OTHERS THEN
                              xcprovin1 := NULL;
                        END;
                     ELSE
--DBMS_OUTPUT.put_line('ANU-REN ERROR:'||SQLERRM);
                        num_err := graba_error(psfiscab, 104389, per.sperson, anu.sseguro, 1,
                                               anu.srecren, 5, xnnumord);
                     END IF;
                  ELSE
                     error := f_datos_personales(per.sperson, xnnumnif2, xtidenti2, xcpais2);

                     IF error = 0 THEN
                        xsperson2 := per.sperson;
                        xnasegur := 2;
                        xcdomici2 := per.cdomici;

                        BEGIN
                           SELECT cprovin
                             INTO xcprovin2
                             FROM direcciones
                            WHERE sperson = per.sperson
                              AND cdomici = per.cdomici;
                        EXCEPTION
                           WHEN OTHERS THEN
                              xcprovin2 := NULL;
                        END;

                        -- No tiene Direccion hay que poner la del 1er Asegurado
                        IF xcprovin2 IS NULL
                           OR xcprovin2 = 0 THEN
                           xcprovin2 := xcprovin1;
                        END IF;
                     ELSE
--DBMS_OUTPUT.put_line('ANU-REN ERROR:'||SQLERRM);
                        num_err := graba_error(psfiscab, 104389, per.sperson, anu.sseguro, 1,
                                               anu.srecren, 5, xnnumord);
                     END IF;
                  END IF;
               END LOOP;
            END IF;

--
            xspersonp := NULL;
            xnnumnifp := NULL;
            xtidentip := NULL;
            xcdomicip := NULL;
            xcpaisp := NULL;
            xcprovinp := NULL;
            xspersonr := NULL;
            xnnumnifr := NULL;
            xtidentir := NULL;
            xcdomicir := NULL;
            xcpaisr := NULL;
            xcprovinr := NULL;

            IF xsperson1 = anu.sperson
               OR xsperson2 = anu.sperson THEN
               IF xsperson1 = anu.sperson THEN
                  xspersonp := xsperson1;
                  xnnumnifp := xnnumnif1;
                  xtidentip := xtidenti1;
                  xcdomicip := xcdomici1;
                  xcpaisp := xcpais1;
                  xcprovinp := xcprovin1;

                  IF preprese = 1 THEN
                     xspersonr := xsperson2;
                     xnnumnifr := xnnumnif2;
                     xtidentir := xtidenti2;
                     xcdomicir := xcdomici2;
                     xcpaisr := xcpais2;
                     xcprovinr := xcprovin2;
                  END IF;
               ELSE
                  xspersonp := xsperson2;
                  xnnumnifp := xnnumnif2;
                  xtidentip := xtidenti2;
                  xcdomicip := xcdomici2;
                  xcpaisp := xcpais2;
                  xcprovinp := xcprovin2;
               END IF;
            END IF;

--
            IF error = 0 THEN
--
               IF anu.pretenc < 1 THEN
                  anu.pretenc := anu.pretenc * 100;
               END IF;

               xcsubtipo := NULL;

-- Decidimos el subtipo que es
               IF anu.ibase <> 0
                  AND anu.iretenc = 0
                  AND anu.pretenc = 0 THEN
                  xcsubtipo := 296;
               ELSIF anu.ibase = 0
                     AND anu.iretenc = 0 THEN
                  xcsubtipo := 999;
               ELSIF anu.ibase <> 0
                     AND anu.iretenc <> 0
                     AND anu.pretenc <> 0 THEN
                  xcsubtipo := 188;
               END IF;

--
               IF anu.ibase < 0 THEN
                  xsigno := 'N';
               ELSE
                  xsigno := 'P';
               END IF;

--
               IF anu.pretenc <> 0
                  AND anu.iretenc = 0 THEN
                  anu.pretenc := 0;
               END IF;

--
               BEGIN
                  SELECT sfisdpa.NEXTVAL
                    INTO xsfisdpa
                    FROM DUAL;

                  INSERT INTO fis_detcierrepago
                              (sfiscab, sfisdpa, cramo, cmodali, ctipseg,
                               ccolect, nnumpet,
                               pfiscal, sseguro,
                               spersonp, nnumnifp, tidentip, cdomicip, sperson1,
                               nnumnif1, tidenti1, cdomici1, ctipo, ndocum,
                               cestrec, fpago, ibruto, iresrcm, iresred,
                               ibase, pretenc, iretenc, ineto, cpaisret,
                               csubtipo, csigbase, cprovin)
                       VALUES (psfiscab, xsfisdpa, anu.cramo, anu.cmodali, anu.ctipseg,
                               anu.ccolect, pnumpet,
                               TO_NUMBER(TO_CHAR(anu.fefecto, 'YYYYMM')), anu.sseguro,
                               xspersonp, xnnumnifp, xtidentip, xcdomicip, xspersonr,
                               xnnumnifr, xtidentir, xcdomicir, 'REN', anu.srecren,
                               anu.cestrec, TRUNC(anu.fefecto), -anu.isinret, 0, 0,
                               -anu.ibase, anu.pretenc, -anu.iretenc, -anu.iconret, xcpaisp,
                               xcsubtipo, xsigno, REPLACE(LPAD(xcprovinp, 2), ' ', '0'));

                  xgrabados := xgrabados + 1;
               EXCEPTION
                  WHEN OTHERS THEN
            -- Error al Insertar FIS_DETCIERREPAGO
--DBMS_OUTPUT.put_line('ANU-REN ERROR:'||SQLERRM);
                     num_err := graba_error(psfiscab, 140581, anu.sperson, anu.sseguro, 1,
                                            anu.srecren, 5, xnnumord);
               END;

               COMMIT;
            END IF;

            xssegant := anu.sseguro;
         EXCEPTION
            WHEN OTHERS THEN
               xssegant := anu.sseguro;
            -- Error NO CONTROLADO
--DBMS_OUTPUT.put_line('ANU-REN ERROR:'||SQLERRM);
               num_err := graba_error(psfiscab, 111250, anu.sperson, anu.sseguro, 1,
                                      anu.srecren, 5, xnnumord);
         END;
      END LOOP;   -- anulaciones
   END;

-- ****************************************************************
-- Carga Prestaciones Plan Pensión
-- ****************************************************************
   PROCEDURE carga_prestaciones(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pinicio IN DATE,
      pfinal IN DATE,
      psfiscab IN NUMBER,
      pnumpet IN NUMBER,
      pempres IN NUMBER,
      preprese IN NUMBER) IS
      -- Cursor de RECIBOS
      CURSOR c_pagpre IS
         -- BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
         -- se añade la SELECT FROM para poder añadir la UNION con las tablas nuevas de siniestros
         SELECT   a.sperson, a.iretenc, a.iconret, a.ireduc, a.isinret, a.iimpsin, a.pretenc,
                  a.sidepag, a.cestpag, a.sseguro, a.fefepag, a.fpago, a.cramo, a.cmodali,
                  a.ctipseg, a.ccolect, a.ctipcap
             FROM (SELECT ip.sperson, pag.iretenc, pag.iconret, ip.ireduc, pag.isinret,
                          pag.iimpsin, pag.pretenc, pag.sidepag, pag.cestpag, s.sseguro,
                          pag.fefepag, ip.fpago, s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                          ip.ctipcap
                     FROM irpf_prestaciones ip, prestaplan pr, pagosini pag, seguros s
                    WHERE pr.sseguro = s.sseguro
                      AND ip.fpago BETWEEN pinicio AND pfinal
                      AND pr.sprestaplan = ip.sprestaplan
                      AND pag.sidepag = ip.sidepag
                      AND s.cramo = pcramo
                      AND s.cmodali BETWEEN NVL(pcmodali, 0) AND NVL(pcmodali, 99)
                      AND s.ctipseg BETWEEN NVL(pctipseg, 0) AND NVL(pctipseg, 99)
                      AND s.ccolect BETWEEN NVL(pccolect, 0) AND NVL(pccolect, 99)
                      AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 0
                   UNION
                   SELECT ip.sperson, pag.iretenc,(pag.isinret - pag.iretenc) iconret,
                          ip.ireduc, pag.isinret,
                          (pag.isinret - pag.iretenc - pag.iiva) iimpsin, g.pretenc,
                          pag.sidepag, m.cestpag, s.sseguro, m.fefepag, ip.fpago, s.cramo,
                          s.cmodali, s.ctipseg, s.ccolect, ip.ctipcap
                     FROM irpf_prestaciones ip, prestaplan pr, sin_tramita_pago pag,
                          sin_tramita_movpago m, sin_tramita_pago_gar g, seguros s
                    WHERE pr.sseguro = s.sseguro
                      AND ip.fpago BETWEEN pinicio AND pfinal
                      AND pr.sprestaplan = ip.sprestaplan
                      AND pag.sidepag = ip.sidepag
                      AND m.sidepag = pag.sidepag
                      AND m.nmovpag = (SELECT MAX(nmovpag)
                                         FROM sin_tramita_movpago
                                        WHERE sidepag = m.sidepag)
                      AND g.sidepag = pag.sidepag
                      AND g.ctipres = 1
                      AND s.cramo = pcramo
                      AND s.cmodali BETWEEN NVL(pcmodali, 0) AND NVL(pcmodali, 99)
                      AND s.ctipseg BETWEEN NVL(pctipseg, 0) AND NVL(pctipseg, 99)
                      AND s.ccolect BETWEEN NVL(pccolect, 0) AND NVL(pccolect, 99)
                      AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 1) a
         ORDER BY a.sperson;

      pre            c_pagpre%ROWTYPE;
      error          NUMBER;
      xssegant       seguros.sseguro%TYPE;
      xsperant       personas.sperson%TYPE;
--
      xnasegur       NUMBER;
--
      xsperson1      personas.sperson%TYPE;
      xnnumnif1      personas.nnumnif%TYPE;
      xtidenti1      personas.tidenti%TYPE;
      xcpais1        personas.cpais%TYPE;
      xcdomici1      asegurados.cdomici%TYPE;
      xcprovin1      direcciones.cprovin%TYPE;
--
      xcsubtipo      fis_detcierrepago.csubtipo%TYPE;
      xcestrec       NUMBER(01);
      xfmovimi       DATE;
      xsigno         CHAR(1);
--
      xleidos        NUMBER;
      xgrabados      NUMBER;
      num_err        NUMBER;
      xnnumord       NUMBER;
      -- Variables de IRPFPERSONAS
      xnifcon        VARCHAR2(10);   -- Nif Conyuge del perceptor
      xcsitfam       NUMBER(1);   -- Código Situación Familiar
      xcgradop       NUMBER(1);   -- Grado de discapacidad perceptor
      xipension      NUMBER(25, 10);   -- Pensión Compensatoria al conyuge
      xianuhijos     NUMBER(25, 10);   -- Anualidades por alimentos Hijos
      xnanynac       NUMBER(4);   -- Año de nacimiento del perceptor
      -- Variables de DECENDIENTES
      xndecmen25     VARCHAR2(8);   -- Descendientes < 25
      -- (1-2p)--> < 3años
      -- (3-4p)--> >=3 a < 16
      -- (5-6p)--> < 25 años
      xndecdisto     NUMBER(2);   -- Total de descendientes discapap.
      xndecdisca     VARCHAR2(8);   -- Nro. Dec. Discapacitados por grado
      -- (1-2p)--> 33% a < 65%
      -- (3-4p)--> 65%
      xndecdisen     NUMBER(2);   -- Nro. Dec. Discapacitados comput.por Entero.
      xxndecdisca    VARCHAR2(8);
      -- Variables de ASCENDENTES
      xnasctotal     NUMBER(1);   -- Total de Ascendentes discapa.
      xnascenter     NUMBER(1);   -- Nro. Asc. Discapacitados comput.por Entero.
      xnascdisca     VARCHAR2(8);   -- Nro. Asc. Discapacitados por grado
      -- (1-1p)--> 33% a < 65%
      -- (2-2p)--> 65%
      xxnascdisca    VARCHAR2(8);
      -- Otras Variables
      xnanyo         NUMBER(4);
      xanys          NUMBER(3);
      paso           NUMBER(2);
      xsfisdpa       NUMBER;
      vagente_poliza seguros.cagente%TYPE;
      vcempres       seguros.cempres%TYPE;
-- ------------------------------------------------------------
   BEGIN
      xssegant := 0;
      xsperant := 0;
      xleidos := 0;
      xgrabados := 0;

--  dbms_output.put_line('*************** Prestaciones P.P. *************');
      FOR pre IN c_pagpre LOOP
--
         BEGIN
            xleidos := xleidos + 1;
            error := 0;

            IF xssegant <> pre.sseguro THEN
               xsperson1 := NULL;
               xnnumnif1 := NULL;
               xtidenti1 := NULL;
               xcdomici1 := NULL;
               xcpais1 := NULL;

--
               BEGIN
                  --Bug10612 - 08/07/2009 - DCT (canviar vista personas)
                  --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
                  SELECT cagente, cempres
                    INTO vagente_poliza, vcempres
                    FROM seguros
                   WHERE sseguro = pre.sseguro;

                  SELECT p.sperson, LTRIM(RTRIM(p.nnumide)), p.ctipide, a.cdomici, d.cpais
                    INTO xsperson1, xnnumnif1, xtidenti1, xcdomici1, xcpais1
                    FROM per_personas p, per_detper d, asegurados a
                   WHERE d.sperson = p.sperson
                     AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres)
                     AND p.sperson = pre.sperson
                     AND p.sperson = a.sperson
                     AND a.sseguro = pre.sseguro;

                  /*SELECT p.sperson, LTRIM(RTRIM(p.nnumnif)), p.tidenti, a.cdomici, p.cpais
                    INTO xsperson1, xnnumnif1, xtidenti1, xcdomici1, xcpais1
                    FROM personas p, asegurados a
                   WHERE p.sperson = pre.sperson
                     AND p.sperson = a.sperson
                     AND a.sseguro = pre.sseguro;*/

                  --FI Bug10612 - 08/07/2009 - DCT (canviar vista personas)
                  IF xtidenti1 IN(1, 4, 5, 6) THEN
                     xnnumnif1 := dni_pos(xnnumnif1);
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
-- Si no existe no es un asegurado de la póliza es un Beneficiario
                     BEGIN
                        --Bug10612 - 08/07/2009 - DCT (canviar vista personas)
                        SELECT p.sperson, LTRIM(RTRIM(p.nnumide)), p.ctipide, d.cpais
                          INTO xsperson1, xnnumnif1, xtidenti1, xcpais1
                          FROM per_personas p, per_detper d
                         WHERE d.sperson = p.sperson
                           AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate,
                                                               vcempres)
                           AND p.sperson = pre.sperson;

                        /*SELECT p.sperson, LTRIM(RTRIM(p.nnumnif)), p.tidenti, p.cpais
                          INTO xsperson1, xnnumnif1, xtidenti1, xcpais1
                          FROM personas p
                         WHERE p.sperson = pre.sperson;*/

                        --FI Bug10612 - 08/07/2009 - DCT (canviar vista personas)
                        IF xtidenti1 IN(1, 4, 5, 6) THEN
                           xnnumnif1 := dni_pos(xnnumnif1);
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
              --  Error al leer la tabla personas
--DBMS_OUTPUT.put_line('PRESTACIONES ERROR:'||SQLERRM);
                           num_err := graba_error(psfiscab, 104389, pre.sperson, pre.sseguro,
                                                  1, pre.sidepag, 6, xnnumord);
                     END;
               END;

               BEGIN
                  SELECT cprovin
                    INTO xcprovin1
                    FROM direcciones
                   WHERE sperson = xsperson1
                     AND cdomici = xcdomici1;
               EXCEPTION
                  WHEN OTHERS THEN
                     xcprovin1 := NULL;
               END;
            END IF;

--
            IF error = 0 THEN
               IF pre.ireduc IS NULL THEN
                  pre.ireduc := 0;
               END IF;

               IF pre.iconret IS NULL THEN
                  pre.iconret := 0;
               END IF;

               IF pre.iretenc IS NULL THEN
                  pre.iretenc := 0;
               END IF;

               xcsubtipo := 190;

               IF xcpais1 = 100 THEN
                  xcsubtipo := 190;
               ELSE
                  xcsubtipo := 1901;
               END IF;

--
               IF pre.iconret < 0 THEN
                  xsigno := 'N';
               ELSE
                  xsigno := 'P';
               END IF;

--
               BEGIN
                  SELECT sfisdpa.NEXTVAL
                    INTO xsfisdpa
                    FROM DUAL;

                  INSERT INTO fis_detcierrepago
                              (sfiscab, sfisdpa, cramo, cmodali, ctipseg,
                               ccolect, nnumpet, pfiscal,
                               sseguro, spersonp, nnumnifp, tidentip, cdomicip, sperson1,
                               nnumnif1, tidenti1, cdomici1, ctipo, ndocum, cestrec,
                               fpago, ibruto, iresrcm, iresred, ibase,
                               pretenc, iretenc, ineto, cpaisret,
                               csubtipo, csigbase, cprovin,
                               ctipcap)
                       VALUES (psfiscab, xsfisdpa, pre.cramo, pre.cmodali, pre.ctipseg,
                               pre.ccolect, pnumpet, TO_NUMBER(TO_CHAR(pre.fpago, 'YYYYMM')),
                               pre.sseguro, xsperson1, xnnumnif1, xtidenti1, xcdomici1, NULL,
                               NULL, NULL, NULL, 'PRE', pre.sidepag, pre.cestpag,
                               TRUNC(pre.fpago), pre.isinret, 0, pre.ireduc, pre.iconret,
                               pre.pretenc, pre.iretenc,(pre.isinret - pre.iretenc), xcpais1,
                               xcsubtipo, xsigno, REPLACE(LPAD(xcprovin1, 2), ' ', '0'),
                               pre.ctipcap);

                  xgrabados := xgrabados + 1;
               EXCEPTION
                  WHEN OTHERS THEN
             -- Error al leer la tabla FIS_DETCIERREPAGO
--DBMS_OUTPUT.put_line('PRESTACIONES ERROR:'||SQLERRM);
                     num_err := graba_error(psfiscab, 140581, xsperson1, pre.sseguro, 1,
                                            pre.sidepag, 6, xnnumord);
               END;

--
-- Busco datos para cargar FIS_IRFPPP
--
               IF xsperson1 <> xsperant THEN
                  xnanyo := TO_NUMBER(TO_CHAR(pinicio, 'YYYY'));

                  BEGIN
                     SELECT csitfam, LTRIM(RTRIM(cnifcon)), cgrado, ipension, ianuhijos
                       INTO xcsitfam, xnifcon, xcgradop, xipension, xianuhijos
                       FROM per_irpf
                      WHERE sperson = xsperson1
                        AND cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres);

                     xnifcon := dni_pos(xnifcon);
                  EXCEPTION
                     WHEN OTHERS THEN
                        xcsitfam := 0;
                        xnifcon := NULL;
                        xcgradop := 0;
                        xipension := 0;
                        xianuhijos := 0;
                  END;

                  paso := 1;

--
                  BEGIN
                     SELECT NVL(TO_NUMBER(TO_CHAR(fnacimi, 'YYYY')), 0)
                       INTO xnanynac
                       FROM per_personas
                      WHERE sperson = xsperson1;
                  EXCEPTION
                     WHEN OTHERS THEN
                        xnanynac := 0000;
                  END;

                  paso := 2;
                  xndecmen25 := '00000000';
                  xndecdisto := 0;
                  xndecdisca := '00000000';
                  xndecdisen := 0;

                  FOR i IN (SELECT fnacimi, cgrado, center
                              FROM irpfdescendientes
                             WHERE sperson = xsperson1) LOOP
                     xanys := xnanyo - TO_NUMBER(TO_CHAR(i.fnacimi, 'YYYY'));

                     IF i.cgrado IS NULL THEN
                        IF xanys < 3 THEN
                           xndecmen25 := REPLACE(LPAD(SUBSTR(xndecmen25, 1, 2) + 1
                                                      || SUBSTR(xndecmen25, 3),
                                                      8),
                                                 ' ', '0');
                        ELSIF xanys >= 3
                              AND xanys < 16 THEN
                           xndecmen25 := REPLACE(LPAD(SUBSTR(xndecmen25, 1, 2)
                                                      || SUBSTR(xndecmen25, 3, 2) + 1
                                                      || SUBSTR(xndecmen25, 5),
                                                      8),
                                                 ' ', '0');
                        ELSIF xanys < 25 THEN
                           xndecmen25 := REPLACE(LPAD(SUBSTR(xndecmen25, 1, 4)
                                                      || SUBSTR(xndecmen25, 5, 2) + 1
                                                      || SUBSTR(xndecmen25, 7),
                                                      8),
                                                 ' ', '0');
                        END IF;
                     ELSE
                        IF i.cgrado = 1 THEN
                           xndecdisca := REPLACE(LPAD(SUBSTR(xndecdisca, 1, 2) + 1
                                                      || SUBSTR(xndecdisca, 3),
                                                      8),
                                                 ' ', '0');
                        ELSIF i.cgrado = 2 THEN
                           xndecdisca := REPLACE(LPAD(SUBSTR(xndecdisca, 1, 2)
                                                      || SUBSTR(xndecdisca, 3, 2) + 1
                                                      || SUBSTR(xndecdisca, 5),
                                                      8),
                                                 ' ', '0');
                        ELSE
                           xndecdisca := REPLACE(LPAD(SUBSTR(xndecdisca, 1, 4)
                                                      || SUBSTR(xndecdisca, 5, 2) + 1
                                                      || SUBSTR(xndecdisca, 7),
                                                      8),
                                                 ' ', '0');
                        END IF;
                     END IF;

                     xndecdisto := xndecdisto + 1;
                     xndecdisen := xndecdisen + NVL(i.center, 0);
                  END LOOP;

                  xnascdisca := '00000000';
                  xnascenter := 0;
                  xnasctotal := 0;
                  paso := 3;

                  FOR i IN (SELECT fnacimi, cgrado, crenta, nviven
                              FROM irpfmayores
                             WHERE sperson = xsperson1) LOOP
                     xanys := xnanyo - TO_NUMBER(TO_CHAR(i.fnacimi, 'YYYY'));
                     xnasctotal := xnasctotal + 1;

                     IF i.nviven IS NULL
                        OR i.nviven = 0 THEN
                        xnascenter := xnascenter + 1;
                     END IF;

                     IF i.cgrado IS NOT NULL THEN
                        xxnascdisca := xnascdisca;

                        IF i.cgrado = 1 THEN
                           xnascdisca := REPLACE(LPAD(SUBSTR(xnascdisca, 1, 1) + 1
                                                      || SUBSTR(xnascdisca, 2),
                                                      8),
                                                 ' ', '0');
                        ELSIF i.cgrado = 2 THEN
                           xnascdisca := REPLACE(LPAD(SUBSTR(xnascdisca, 1)
                                                      || SUBSTR(xnascdisca, 2, 1) + 1
                                                      || SUBSTR(xnascdisca, 3),
                                                      8),
                                                 ' ', '0');
                        ELSE
                           xnascdisca := REPLACE(LPAD(SUBSTR(xnascdisca, 1, 2)
                                                      || SUBSTR(xnascdisca, 3, 1) + 1
                                                      || SUBSTR(xnascdisca, 4),
                                                      8),
                                                 ' ', '0');
                        END IF;
                     END IF;
                  END LOOP;

                  paso := 4;

-- Grabo los datos
                  BEGIN
                     INSERT INTO fis_irpfpp
                                 (sfiscab, sperson, nnifper, nnifcon, csitfam,
                                  nanynac, cgradop, ipension, ianuhijos, ndecmen25,
                                  ndecdisto, ndecdisca, ndecdisen, nasctotal, nascenter,
                                  nascdisca)
                          VALUES (psfiscab, xsperson1, xnnumnif1, xnifcon, xcsitfam,
                                  xnanynac, xcgradop, xipension, xianuhijos, xndecmen25,
                                  xndecdisto, xndecdisca, xndecdisen, xnasctotal, xnascenter,
                                  xnascdisca);
                  EXCEPTION
                     WHEN OTHERS THEN
                        BEGIN
                           UPDATE fis_irpfpp
                              SET nnifper = xnnumnif1,
                                  nnifcon = xnifcon,
                                  csitfam = xcsitfam,
                                  nanynac = xnanynac,
                                  cgradop = xcgradop,
                                  ipension = xipension,
                                  ianuhijos = xianuhijos,
                                  ndecmen25 = xndecmen25,
                                  ndecdisto = xndecdisto,
                                  ndecdisca = xndecdisca,
                                  ndecdisen = xndecdisen,
                                  nasctotal = xnasctotal,
                                  nascenter = xnascenter,
                                  nascdisca = xnascdisca
                            WHERE sfiscab = psfiscab
                              AND sperson = xsperson1;
                        EXCEPTION
                           WHEN OTHERS THEN
           --  Error al Insertar en tabla FIS_IRPFPP
--DBMS_OUTPUT.put_line('PRESTA IRPFPP ERROR:'||SQLERRM);
                              num_err := graba_error(psfiscab, 108468, xsperson1, pre.sseguro,
                                                     1, pre.sidepag, 6, xnnumord);
                        END;
                  END;

                  COMMIT;
               END IF;
            END IF;

            xsperant := xsperson1;
            xssegant := pre.sseguro;
         EXCEPTION
            WHEN OTHERS THEN
               xssegant := pre.sseguro;
          --   Error No controlado
--DBMS_OUTPUT.put_line('PRESTACIONES ERROR:'||SQLERRM);
               num_err := graba_error(psfiscab, 111250, xsperson1, pre.sseguro, 1,
                                      pre.sidepag, 6, xnnumord);
         END;
      END LOOP;   -- pagos prestaciones
   END;

-- ****************************************************************
-- Carga Siniestros
-- ****************************************************************
   PROCEDURE carga_siniestros(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pinicio IN DATE,
      pfinal IN DATE,
      psfiscab IN NUMBER,
      pnumpet IN NUMBER,
      pempres IN NUMBER,
      preprese IN NUMBER) IS
      -- Cursor de SINIESTROS
      CURSOR c_pagsin IS
         -- BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
         -- se añade la SELECT FROM para poder añadir la UNION con las tablas nuevas de siniestros
         SELECT   a.ccausin, a.sseguro, a.cramo, a.cmodali, a.ctipseg, a.ccolect, a.sidepag,
                  a.sperson, a.iresrcm, a.iresred, a.iconret, a.iretenc, a.iimpsin, a.isinret,
                  a.pretenc, a.fefepag, a.cestpag
             FROM (SELECT si.ccausin, si.sseguro, s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                          p.sidepag, p.sperson, p.iresrcm, p.iresred, p.iconret, p.iretenc,
                          p.iimpsin, p.isinret, p.pretenc, p.fefepag, p.cestpag
                     FROM siniestros si, pagosini p, seguros s
                    WHERE si.nsinies = p.nsinies
                      AND p.cestpag = 2
                      AND si.ccausin NOT IN(205, 505, 108, 109, 110)
                      AND si.sseguro = s.sseguro
                      AND s.cramo = pcramo
                      AND s.cmodali BETWEEN NVL(pcmodali, 0) AND NVL(pcmodali, 99)
                      AND s.ctipseg BETWEEN NVL(pctipseg, 0) AND NVL(pctipseg, 99)
                      AND s.ccolect BETWEEN NVL(pccolect, 0) AND NVL(pccolect, 99)
                      AND TRUNC(p.fefepag) BETWEEN pinicio AND pfinal
                      AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 0
                   UNION
                   SELECT si.ccausin, si.sseguro, s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                          p.sidepag, p.sperson, p.iresrcm, p.iresred,
                          (p.isinret - p.iretenc) iconret, p.iretenc,
                          (p.isinret - p.iretenc - p.iiva) iimpsin, p.isinret, g.pretenc,
                          m.fefepag, m.cestpag
                     FROM sin_siniestro si, sin_tramitacion t, sin_tramita_pago p,
                          sin_tramita_movpago m, sin_tramita_pago_gar g, seguros s
                    WHERE si.nsinies = t.nsinies
                      AND t.nsinies = p.nsinies
                      AND t.ntramit = p.ntramit
                      AND m.sidepag = p.sidepag
                      AND m.nmovpag = (SELECT MAX(nmovpag)
                                         FROM sin_tramita_movpago
                                        WHERE sidepag = m.sidepag)
                      AND m.cestpag = 2
                      AND p.sidepag = g.sidepag
                      AND g.ctipres = 1
                      AND si.ccausin NOT IN(205, 505, 108, 109, 110)
                      AND si.sseguro = s.sseguro
                      AND s.cramo = pcramo
                      AND s.cmodali BETWEEN NVL(pcmodali, 0) AND NVL(pcmodali, 99)
                      AND s.ctipseg BETWEEN NVL(pctipseg, 0) AND NVL(pctipseg, 99)
                      AND s.ccolect BETWEEN NVL(pccolect, 0) AND NVL(pccolect, 99)
                      AND TRUNC(m.fefepag) BETWEEN pinicio AND pfinal
                      AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 1) a
         ORDER BY a.sseguro, a.sidepag;

      SIN            c_pagsin%ROWTYPE;
      error          NUMBER;
      xssegant       seguros.sseguro%TYPE;
--
      xnasegur       NUMBER;
      xsigno         CHAR(1);
--
      xspersonp      personas.sperson%TYPE;
      xnnumnifp      personas.nnumnif%TYPE;
      xtidentip      personas.tidenti%TYPE;
      xcdomicip      asegurados.cdomici%TYPE;
      xcpaisp        personas.cpais%TYPE;
      xcprovinp      direcciones.cprovin%TYPE;
--
      xsperson1      personas.sperson%TYPE;
      xnnumnif1      personas.nnumnif%TYPE;
      xtidenti1      personas.tidenti%TYPE;
      xcdomici1      asegurados.cdomici%TYPE;
      xcpais1        personas.cpais%TYPE;
      xcprovin1      direcciones.cprovin%TYPE;
--
      xsperson2      personas.sperson%TYPE;
      xnnumnif2      personas.nnumnif%TYPE;
      xtidenti2      personas.tidenti%TYPE;
      xcdomici2      asegurados.cdomici%TYPE;
      xcpais2        personas.cpais%TYPE;
      xcprovin2      direcciones.cprovin%TYPE;
--
      xcsubtipo      fis_detcierrepago.csubtipo%TYPE;
      xcestrec       NUMBER(01);
      xfmovimi       DATE;
      xtipo          CHAR(3);
--
      xleidos        NUMBER;
      xgrabados      NUMBER;
      xcommit        NUMBER;
      num_err        NUMBER;
      xnnumord       NUMBER;
      xsfisdpa       NUMBER;
      vagente_poliza seguros.cagente%TYPE;
      vcempres       seguros.cempres%TYPE;
-- ------------------------------------------------------------
   BEGIN
      xssegant := 0;
      xleidos := 0;
      xgrabados := 0;
      xcommit := 0;

--  dbms_output.put_line('*************** Siniestros *************');
      FOR SIN IN c_pagsin LOOP
--
         BEGIN
            xleidos := xleidos + 1;
            error := 0;
--
            xtipo := NULL;

            IF SIN.ccausin IN(201, 202, 501, 901, 1501, 1502, 3501) THEN
               xtipo := 'SIN';
            ELSIF SIN.ccausin IN(203, 503, 3503) THEN
               xtipo := 'RPA';
            ELSIF SIN.ccausin IN(204, 504, 3504, 904) THEN
               xtipo := 'RTO';
            ELSE
               xtipo := '???';
            END IF;

            IF xssegant <> SIN.sseguro THEN
               xsperson1 := NULL;
               xnnumnif1 := NULL;
               xtidenti1 := NULL;
               xcdomici1 := NULL;
               xcpais1 := NULL;
               xcprovin1 := NULL;
               xsperson2 := NULL;
               xnnumnif2 := NULL;
               xtidenti2 := NULL;
               xcdomici2 := NULL;
               xcpais2 := NULL;
               xcprovin2 := NULL;
--
               xnasegur := 0;

               FOR per IN (SELECT *
                             FROM asegurados
                            WHERE sseguro = SIN.sseguro) LOOP
                  IF per.norden = 1 THEN
                     error := f_datos_personales(per.sperson, xnnumnif1, xtidenti1, xcpais1);

                     IF error = 0 THEN
                        xsperson1 := per.sperson;
                        xnasegur := 1;
                        xcdomici1 := per.cdomici;

                        BEGIN
                           SELECT cprovin
                             INTO xcprovin1
                             FROM direcciones
                            WHERE sperson = per.sperson
                              AND cdomici = per.cdomici;
                        EXCEPTION
                           WHEN OTHERS THEN
                              xcprovin1 := NULL;
                        END;
                     ELSE
              --  Error al leer Personas
--DBMS_OUTPUT.put_line('SINIESTROS ERROR:'||SQLERRM);
                        num_err := graba_error(psfiscab, 104389, per.sperson, SIN.sseguro, 1,
                                               SIN.sidepag, 7, xnnumord);
                     END IF;
                  ELSE
                     error := f_datos_personales(per.sperson, xnnumnif2, xtidenti2, xcpais2);

                     IF error = 0 THEN
                        xsperson2 := per.sperson;
                        xnasegur := 2;
                        xcdomici2 := per.cdomici;

                        BEGIN
                           SELECT cprovin
                             INTO xcprovin2
                             FROM direcciones
                            WHERE sperson = per.sperson
                              AND cdomici = per.cdomici;
                        EXCEPTION
                           WHEN OTHERS THEN
                              xcprovin2 := NULL;
                        END;

                        -- Si no tiene domicilio ponemos la del primer asegurado
                        IF xcprovin2 IS NULL
                           OR xcprovin2 = 0 THEN
                           xcprovin2 := xcprovin1;
                        END IF;
                     ELSE
              --  Error al leer Personas
--DBMS_OUTPUT.put_line('PRESTACIONES ERROR:'||SQLERRM);
                        num_err := graba_error(psfiscab, 104389, per.sperson, SIN.sseguro, 1,
                                               SIN.sidepag, 7, xnnumord);
                     END IF;
                  END IF;
               END LOOP;
            END IF;

--
            xspersonp := NULL;
            xnnumnifp := NULL;
            xtidentip := NULL;
            xcdomicip := NULL;
            xcpaisp := NULL;

-- Si el que percibe el pago es un asegurado.
            IF xsperson1 = SIN.sperson
               OR xsperson2 = SIN.sperson THEN
               IF xsperson1 = SIN.sperson THEN
                  xspersonp := xsperson1;
                  xnnumnifp := xnnumnif1;
                  xtidentip := xtidenti1;
                  xcdomicip := xcdomici1;
                  xcpaisp := xcpais1;
                  xcprovinp := xcprovin1;
               ELSE
                  xspersonp := xsperson2;
                  xnnumnifp := xnnumnif2;
                  xtidentip := xtidenti2;
                  xcdomicip := xcdomici2;
                  xcpaisp := xcpais2;
                  xcprovinp := xcprovin2;
               END IF;
-- El que percibe el pago es un Beneficiario
            ELSE
               BEGIN
                  --Bug10612 - 08/07/2009 - DCT (canviar vista personas)
                  --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
                  SELECT cagente, cempres
                    INTO vagente_poliza, vcempres
                    FROM seguros
                   WHERE sseguro = SIN.sseguro;

                  SELECT p.sperson, LTRIM(RTRIM(p.nnumide)), p.ctipide, a.cdomici, d.cpais
                    INTO xspersonp, xnnumnifp, xtidentip, xcdomicip, xcpaisp
                    FROM per_personas p, per_detper d, asegurados a
                   WHERE d.sperson = p.sperson
                     AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres)
                     AND p.sperson = SIN.sperson
                     AND p.sperson = a.sperson
                     AND a.sseguro = SIN.sseguro;

                  /*SELECT p.sperson, LTRIM(RTRIM(p.nnumnif)), p.tidenti, a.cdomici, p.cpais
                    INTO xspersonp, xnnumnifp, xtidentip, xcdomicip, xcpaisp
                    FROM personas p, asegurados a
                   WHERE p.sperson = SIN.sperson
                     AND p.sperson = a.sperson
                     AND a.sseguro = SIN.sseguro;*/

                  --FI Bug10612 - 08/07/2009 - DCT (canviar vista personas)
                  IF xtidentip IN(1, 4, 5, 6) THEN
                     xnnumnifp := dni_pos(xnnumnifp);
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     error := f_datos_personales(SIN.sperson, xnnumnifp, xtidentip, xcpaisp);
                     xspersonp := SIN.sperson;

                     IF error <> 0 THEN
              --  Error al leer Personas
--DBMS_OUTPUT.put_line('SINIESTROS ERROR:'||SQLERRM);
                        num_err := graba_error(psfiscab, 104389, SIN.sperson, SIN.sseguro, 1,
                                               SIN.sidepag, 7, xnnumord);
                     END IF;
               END;

               -- Si no tiene domicilio ponemos el del 1er asegurado
               BEGIN
                  SELECT cprovin
                    INTO xcprovinp
                    FROM direcciones
                   WHERE sperson = xspersonp
                     AND cdomici = xcdomicip;
               EXCEPTION
                  WHEN OTHERS THEN
                     xcprovinp := xcprovin1;
               END;
            END IF;

--
            IF error = 0 THEN
-- Decidimos el subtipo(Modelo) que es
               IF SIN.iresrcm IS NULL THEN
                  SIN.iresrcm := 0;
               END IF;

               IF SIN.iresred IS NULL THEN
                  SIN.iresred := 0;
               END IF;

               IF SIN.iconret IS NULL THEN
                  SIN.iconret := 0;
               END IF;

               IF SIN.iretenc IS NULL THEN
                  SIN.iretenc := 0;
               END IF;

               IF SIN.iimpsin IS NULL THEN
                  SIN.iimpsin := SIN.isinret - SIN.iconret;
               END IF;

--
               xcsubtipo := NULL;

--
               IF xcpaisp = 100 THEN
                  xcsubtipo := 188;
               ELSE
                  xcsubtipo := 296;
               END IF;

               IF SIN.iconret = 0
                  AND SIN.iretenc = 0 THEN
                  xcsubtipo := 999;
               END IF;

--
               IF SIN.iconret < 0 THEN
                  xsigno := 'N';
               ELSE
                  xsigno := 'P';
               END IF;

--
               IF SIN.pretenc <> 0
                  AND SIN.iretenc = 0 THEN
                  SIN.pretenc := 0;
               END IF;

--
               IF preprese = 1 THEN
                  BEGIN
                     SELECT sfisdpa.NEXTVAL
                       INTO xsfisdpa
                       FROM DUAL;

                     INSERT INTO fis_detcierrepago
                                 (sfiscab, sfisdpa, cramo, cmodali, ctipseg,
                                  ccolect, nnumpet,
                                  pfiscal, sseguro,
                                  spersonp, nnumnifp, tidentip, cdomicip, sperson1,
                                  nnumnif1, tidenti1, cdomici1, ctipo, ndocum,
                                  cestrec, fpago, ibruto, iresrcm,
                                  iresred, ibase, pretenc, iretenc,
                                  ineto, cpaisret, csubtipo, csigbase,
                                  cprovin)
                          VALUES (psfiscab, xsfisdpa, SIN.cramo, SIN.cmodali, SIN.ctipseg,
                                  SIN.ccolect, pnumpet,
                                  TO_NUMBER(TO_CHAR(SIN.fefepag, 'YYYYMM')), SIN.sseguro,
                                  xspersonp, xnnumnifp, xtidentip, xcdomicip, xsperson2,
                                  xnnumnif2, xtidenti2, xcdomici2, xtipo, SIN.sidepag,
                                  SIN.cestpag, TRUNC(SIN.fefepag), SIN.isinret, SIN.iresrcm,
                                  SIN.iresred, SIN.iconret, SIN.pretenc, SIN.iretenc,
                                  SIN.iimpsin, xcpaisp, xcsubtipo, xsigno,
                                  REPLACE(LPAD(xcprovinp, 2), ' ', '0'));

                     xgrabados := xgrabados + 1;
                     xcommit := xcommit + 1;
                  EXCEPTION
                     WHEN OTHERS THEN
             -- Error al leer la tabla FIS_DETCIERREPAGO
--DBMS_OUTPUT.put_line('SINIESTROS ERROR:'||SQLERRM);
                        num_err := graba_error(psfiscab, 140581, xspersonp, SIN.sseguro, 1,
                                               SIN.sidepag, 7, xnnumord);
                  END;
               ELSE
                  BEGIN
                     SELECT sfisdpa.NEXTVAL
                       INTO xsfisdpa
                       FROM DUAL;

                     INSERT INTO fis_detcierrepago
                                 (sfiscab, sfisdpa, cramo, cmodali, ctipseg,
                                  ccolect, nnumpet,
                                  pfiscal, sseguro,
                                  spersonp, nnumnifp, tidentip, cdomicip, sperson1, nnumnif1,
                                  tidenti1, cdomici1, ctipo, ndocum, cestrec,
                                  fpago, ibruto, iresrcm, iresred,
                                  ibase, pretenc, iretenc, ineto, cpaisret,
                                  csubtipo, csigbase, cprovin)
                          VALUES (psfiscab, xsfisdpa, SIN.cramo, SIN.cmodali, SIN.ctipseg,
                                  SIN.ccolect, pnumpet,
                                  TO_NUMBER(TO_CHAR(SIN.fefepag, 'YYYYMM')), SIN.sseguro,
                                  xspersonp, xnnumnifp, xtidentip, xcdomicip, NULL, NULL,
                                  NULL, NULL, xtipo, SIN.sidepag, SIN.cestpag,
                                  TRUNC(SIN.fefepag), SIN.isinret, SIN.iresrcm, SIN.iresred,
                                  SIN.iconret, SIN.pretenc, SIN.iretenc, SIN.iimpsin, xcpaisp,
                                  xcsubtipo, xsigno, REPLACE(LPAD(xcprovinp, 2), ' ', '0'));

                     xgrabados := xgrabados + 1;
                     xcommit := xcommit + 1;
                  EXCEPTION
                     WHEN OTHERS THEN
             -- Error al leer la tabla FIS_DETCIERREPAGO
--DBMS_OUTPUT.put_line('SINIESTROS ERROR:'||SQLERRM);
                        num_err := graba_error(psfiscab, 140581, xspersonp, SIN.sseguro, 1,
                                               SIN.sidepag, 7, xnnumord);
                  END;
               END IF;

--
               IF xcommit > 400 THEN
                  xcommit := 0;
                  COMMIT;
               END IF;
--
            END IF;

            xssegant := SIN.sseguro;
         EXCEPTION
            WHEN OTHERS THEN
               xssegant := SIN.sseguro;
--DBMS_OUTPUT.put_line('SINIESTROS ERROR:'||SQLERRM);
               num_err := graba_error(psfiscab, 111250, SIN.sperson, SIN.sseguro, 1,
                                      SIN.sidepag, 7, xnnumord);
         END;
      END LOOP;   -- siniestros

      COMMIT;
   END;

-- ****************************************************************
-- Carga Vencimientos
-- ****************************************************************
   PROCEDURE carga_vencimientos(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pinicio IN DATE,
      pfinal IN DATE,
      psfiscab IN NUMBER,
      pnumpet IN NUMBER,
      pempres IN NUMBER,
      preprese IN NUMBER) IS
      -- Cursor de SINIESTROS
      CURSOR c_pagvto IS
         -- BUG 11595 - 03/11/2009 - APD - Adaptación al nuevo módulo de siniestros
         -- se añade la SELECT FROM para poder añadir la UNION con las tablas nuevas de siniestros
         SELECT   a.ccausin, a.sseguro, a.cramo, a.cmodali, a.ctipseg, a.ccolect, a.fvencim,
                  a.sidepag, a.sperson, a.iresrcm, a.iresred, a.iconret, a.iretenc, a.iimpsin,
                  a.isinret, a.pretenc, a.fefepag, a.cestpag
             FROM (SELECT si.ccausin, si.sseguro, s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                          s.fvencim, p.sidepag, p.sperson, p.iresrcm, p.iresred, p.iconret,
                          p.iretenc, p.iimpsin, p.isinret, p.pretenc, p.fefepag, p.cestpag
                     FROM siniestros si, pagosini p, seguros s
                    WHERE si.nsinies = p.nsinies
                      AND p.cestpag IN(0, 1, 2)
                      AND si.ccausin IN(205, 505)
                      AND si.sseguro = s.sseguro
                      AND s.cramo = pcramo
                      AND s.cmodali BETWEEN NVL(pcmodali, 0) AND NVL(pcmodali, 99)
                      AND s.ctipseg BETWEEN NVL(pctipseg, 0) AND NVL(pctipseg, 99)
                      AND s.ccolect BETWEEN NVL(pccolect, 0) AND NVL(pccolect, 99)
                      AND s.fvencim BETWEEN pinicio AND pfinal
                      AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 0
                   UNION
                   SELECT si.ccausin, si.sseguro, s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                          s.fvencim, p.sidepag, p.sperson, p.iresrcm, p.iresred,
                          (p.isinret - p.iretenc) iconret, p.iretenc,
                          (p.isinret - p.iretenc - p.iiva) iimpsin, p.isinret, g.pretenc,
                          m.fefepag, m.cestpag
                     FROM sin_siniestro si, sin_tramitacion t, sin_tramita_pago p,
                          sin_tramita_movpago m, sin_tramita_pago_gar g, seguros s
                    WHERE si.nsinies = t.nsinies
                      AND t.nsinies = p.nsinies
                      AND t.ntramit = p.ntramit
                      AND m.sidepag = p.sidepag
                      AND m.nmovpag = (SELECT MAX(nmovpag)
                                         FROM sin_tramita_movpago
                                        WHERE sidepag = m.sidepag)
                      AND m.cestpag IN(0, 1, 2)
                      AND p.sidepag = g.sidepag
                      AND g.ctipres = 1
                      AND si.ccausin IN(205, 505)
                      AND si.sseguro = s.sseguro
                      AND s.cramo = pcramo
                      AND s.cmodali BETWEEN NVL(pcmodali, 0) AND NVL(pcmodali, 99)
                      AND s.ctipseg BETWEEN NVL(pctipseg, 0) AND NVL(pctipseg, 99)
                      AND s.ccolect BETWEEN NVL(pccolect, 0) AND NVL(pccolect, 99)
                      AND s.fvencim BETWEEN pinicio AND pfinal
                      AND NVL(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0) = 1) a
         ORDER BY a.sseguro, a.sperson;

      vto            c_pagvto%ROWTYPE;
      error          NUMBER;
      xssegant       seguros.sseguro%TYPE;
--
      xspersonp      personas.sperson%TYPE;
      xnnumnifp      personas.nnumnif%TYPE;
      xtidentip      personas.tidenti%TYPE;
      xcdomicip      asegurados.cdomici%TYPE;
      xcpaisp        personas.cpais%TYPE;
      xcprovinp      direcciones.cprovin%TYPE;
--
      xspersonr      personas.sperson%TYPE;
      xnnumnifr      personas.nnumnif%TYPE;
      xtidentir      personas.tidenti%TYPE;
      xcdomicir      asegurados.cdomici%TYPE;
      xcpaisr        personas.cpais%TYPE;
      xcprovinr      direcciones.cprovin%TYPE;
--
      xsperson1      personas.sperson%TYPE;
      xnnumnif1      personas.nnumnif%TYPE;
      xtidenti1      personas.tidenti%TYPE;
      xcdomici1      asegurados.cdomici%TYPE;
      xcpais1        personas.cpais%TYPE;
      xcprovin1      direcciones.cprovin%TYPE;
--
      xsperson2      personas.sperson%TYPE;
      xnnumnif2      personas.nnumnif%TYPE;
      xtidenti2      personas.tidenti%TYPE;
      xcdomici2      asegurados.cdomici%TYPE;
      xcpais2        personas.cpais%TYPE;
      xcprovin2      direcciones.cprovin%TYPE;
--
      xcsubtipo      fis_detcierrepago.csubtipo%TYPE;
      xcestrec       NUMBER(01);
      xfmovimi       DATE;
      xtipo          CHAR(3);
      xnasegur       NUMBER;
      xsigno         CHAR(1);
--
      xleidos        NUMBER;
      xgrabados      NUMBER;
      xcommit        NUMBER;
      num_err        NUMBER;
      xnnumord       NUMBER;
      xsfisdpa       NUMBER;
      vagente_poliza seguros.cagente%TYPE;
      vcempres       seguros.cempres%TYPE;
-- ------------------------------------------------------------
   BEGIN
      xssegant := 0;
      xleidos := 0;
      xgrabados := 0;
      xcommit := 0;

--    dbms_output.put_line('*************** Vencimientos *************');
      FOR vto IN c_pagvto LOOP
--
         BEGIN
            xleidos := xleidos + 1;
            error := 0;

            IF xssegant <> vto.sseguro THEN
--
               xtipo := 'VTO';
--
               xsperson1 := NULL;
               xnnumnif1 := NULL;
               xtidenti1 := NULL;
               xcdomici1 := NULL;
               xcpais1 := NULL;
               xcprovin1 := NULL;
               xsperson2 := NULL;
               xnnumnif2 := NULL;
               xtidenti2 := NULL;
               xcdomici2 := NULL;
               xcpais2 := NULL;
               xcprovin2 := NULL;
--
               xnasegur := 0;

               FOR per IN (SELECT *
                             FROM asegurados
                            WHERE sseguro = vto.sseguro) LOOP
                  IF per.norden = 1 THEN
                     error := f_datos_personales(per.sperson, xnnumnif1, xtidenti1, xcpais1);

                     IF error = 0 THEN
                        xsperson1 := per.sperson;
                        xnasegur := 1;
                        xcdomici1 := per.cdomici;

                        BEGIN
                           SELECT cprovin
                             INTO xcprovin1
                             FROM direcciones
                            WHERE sperson = per.sperson
                              AND cdomici = per.cdomici;
                        EXCEPTION
                           WHEN OTHERS THEN
                              xcprovin1 := NULL;
                        END;
                     ELSE
--DBMS_OUTPUT.put_line('VTOS ERROR:'||SQLERRM);
                        num_err := graba_error(psfiscab, 104389, per.sperson, vto.sseguro, 1,
                                               vto.sidepag, 8, xnnumord);
                     END IF;
                  ELSE
                     error := f_datos_personales(per.sperson, xnnumnif2, xtidenti2, xcpais2);

                     IF error = 0 THEN
                        xsperson2 := per.sperson;
                        xnasegur := 2;
                        xcdomici2 := per.cdomici;

                        BEGIN
                           SELECT cprovin
                             INTO xcprovin2
                             FROM direcciones
                            WHERE sperson = per.sperson
                              AND cdomici = per.cdomici;
                        EXCEPTION
                           WHEN OTHERS THEN
                              xcprovin2 := NULL;
                        END;

                        -- No tiene Direccion hay que poner la del 1er Asegurado
                        IF xcprovin2 IS NULL
                           OR xcprovin2 = 0 THEN
                           xcprovin2 := xcprovin1;
                        END IF;
                     ELSE
--DBMS_OUTPUT.put_line('VTOS ERROR:'||SQLERRM);
                        num_err := graba_error(psfiscab, 104389, per.sperson, vto.sseguro, 1,
                                               vto.sidepag, 8, xnnumord);
                     END IF;
                  END IF;
               END LOOP;
            END IF;

--
            xspersonp := NULL;
            xnnumnifp := NULL;
            xtidentip := NULL;
            xcdomicip := NULL;
            xcpaisp := NULL;
            xcprovinp := NULL;
            xspersonr := NULL;
            xnnumnifr := NULL;
            xtidentir := NULL;
            xcdomicir := NULL;
            xcpaisr := NULL;
            xcprovinr := NULL;

            IF xsperson1 = vto.sperson
               OR xsperson2 = vto.sperson THEN
               IF xsperson1 = vto.sperson THEN
                  xspersonp := xsperson1;
                  xnnumnifp := xnnumnif1;
                  xtidentip := xtidenti1;
                  xcdomicip := xcdomici1;
                  xcpaisp := xcpais1;
                  xcprovinp := xcprovin1;

                  IF preprese = 1 THEN
                     xspersonr := xsperson2;
                     xnnumnifr := xnnumnif2;
                     xtidentir := xtidenti2;
                     xcdomicir := xcdomici2;
                     xcpaisr := xcpais2;
                     xcprovinr := xcprovin2;
                  END IF;
               ELSE
                  xspersonp := xsperson2;
                  xnnumnifp := xnnumnif2;
                  xtidentip := xtidenti2;
                  xcdomicip := xcdomici2;
                  xcpaisp := xcpais2;
                  xcprovinp := xcprovin2;
               END IF;
            ELSE
               BEGIN
                  --Bug10612 - 08/07/2009 - DCT (canviar vista personas)
                  --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
                  SELECT cagente, cempres
                    INTO vagente_poliza, vcempres
                    FROM seguros
                   WHERE sseguro = vto.sseguro;

                  SELECT p.sperson, LTRIM(RTRIM(p.nnumide)), p.ctipide, a.cdomici, d.cpais
                    INTO xspersonp, xnnumnifp, xtidentip, xcdomicip, xcpaisp
                    FROM per_personas p, per_detper d, asegurados a
                   WHERE d.sperson = p.sperson
                     AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres)
                     AND p.sperson = vto.sperson
                     AND p.sperson = a.sperson
                     AND a.sseguro = vto.sseguro;

                  /*SELECT p.sperson, LTRIM(RTRIM(p.nnumnif)), p.tidenti, a.cdomici, p.cpais
                    INTO xspersonp, xnnumnifp, xtidentip, xcdomicip, xcpaisp
                    FROM personas p, asegurados a
                   WHERE p.sperson = vto.sperson
                     AND p.sperson = a.sperson
                     AND a.sseguro = vto.sseguro;*/

                  --FI Bug10612 - 08/07/2009 - DCT (canviar vista personas)
                  IF xtidentip IN(1, 4, 5, 6) THEN
                     xnnumnifp := dni_pos(xnnumnifp);
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
--DBMS_OUTPUT.put_line('VTOS ERROR:'||SQLERRM);
                     num_err := graba_error(psfiscab, 104389, vto.sperson, vto.sseguro, 1,
                                            vto.sidepag, 8, xnnumord);
               END;

               BEGIN
                  SELECT cprovin
                    INTO xcprovinp
                    FROM direcciones
                   WHERE sperson = xspersonp
                     AND cdomici = xcdomicip;
               EXCEPTION
                  WHEN OTHERS THEN
                     xcprovinp := xcprovin1;
               END;
            END IF;

--
            xcsubtipo := NULL;

            IF error = 0 THEN
               IF xcpaisp = 100 THEN
                  xcsubtipo := 188;
               ELSE
                  xcsubtipo := 296;
               END IF;

--
               IF vto.pretenc <> 0
                  AND vto.iretenc = 0 THEN
                  vto.pretenc := 0;
               END IF;

--
               IF vto.iconret < 0 THEN
                  xsigno := 'N';
               ELSE
                  xsigno := 'P';
               END IF;

--
               BEGIN
                  SELECT sfisdpa.NEXTVAL
                    INTO xsfisdpa
                    FROM DUAL;

                  INSERT INTO fis_detcierrepago
                              (sfiscab, sfisdpa, cramo, cmodali, ctipseg,
                               ccolect, nnumpet,
                               pfiscal, sseguro,
                               spersonp, nnumnifp, tidentip, cdomicip, sperson1,
                               nnumnif1, tidenti1, cdomici1, ctipo, ndocum,
                               cestrec, fpago, ibruto, iresrcm,
                               iresred, ibase, pretenc, iretenc,
                               ineto, cpaisret, csubtipo, csigbase,
                               cprovin)
                       VALUES (psfiscab, xsfisdpa, vto.cramo, vto.cmodali, vto.ctipseg,
                               vto.ccolect, pnumpet,
                               TO_NUMBER(TO_CHAR(vto.fvencim, 'YYYYMM')), vto.sseguro,
                               xspersonp, xnnumnifp, xtidentip, xcdomicip, xspersonr,
                               xnnumnifr, xtidentir, xcdomicir, xtipo, vto.sidepag,
                               vto.cestpag, vto.fvencim, vto.isinret, vto.iresrcm,
                               vto.iresred, vto.iconret, vto.pretenc, vto.iretenc,
                               vto.iimpsin, xcpaisp, xcsubtipo, xsigno,
                               REPLACE(LPAD(xcprovinp, 2), ' ', '0'));

                  xgrabados := xgrabados + 1;
                  xcommit := xcommit + 1;
               EXCEPTION
                  WHEN OTHERS THEN
             -- Error al leer la tabla FIS_DETCIERREPAGO
--DBMS_OUTPUT.put_line('VTOS ERROR:'||SQLERRM);
                     num_err := graba_error(psfiscab, 140581, xspersonp, vto.sseguro, 1,
                                            vto.sidepag, 8, xnnumord);
               END;

--
               IF xcommit > 400 THEN
                  xcommit := 0;
                  COMMIT;
               END IF;
            END IF;

            xssegant := vto.sseguro;
         EXCEPTION
            WHEN OTHERS THEN
               xssegant := vto.sseguro;
--DBMS_OUTPUT.put_line('VTOS ERROR:'||SQLERRM);
               num_err := graba_error(psfiscab, 111250, vto.sperson, vto.sseguro, 1,
                                      vto.sidepag, 8, xnnumord);
         END;
      END LOOP;   -- VENCIMIENTOS

      COMMIT;
   END;

-- ****************************************************************
-- GRABA EL ERROR EN LA TABLA FIS_CARGA_ERROR
-- ****************************************************************
   FUNCTION graba_error(
      psfiscab IN NUMBER,
      pnumerr IN NUMBER,
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pcidioma IN NUMBER,
      pndocum IN NUMBER,
      ptipo IN NUMBER,
      pnumord OUT NUMBER)
      RETURN NUMBER IS
      texto          VARCHAR2(200);
      num_err        NUMBER;
      xnumord        NUMBER;
      xtipo          VARCHAR2(2);
   BEGIN
      num_err := f_busca_num(psfiscab, xnumord);

--
      IF pnumerr = 1 THEN
         texto :=('Asignado al modelo 188 o 190');
      ELSIF pnumerr = 2 THEN
         texto :=('Nif Incorrecto');
      ELSIF pnumerr = 4 THEN
         texto :=('Nombre o Apellidos No Informados');
      ELSIF pnumerr = 7 THEN   --3606 jdomingo 30/11/2007  canvi format codi postal (ja no pot ser 0)
         texto :=('Provincia a 0 o Codigo Postal no informado');
      ELSIF pnumerr = 9 THEN
         texto :=('Nif Representante Incorrecto');
      ELSIF pnumerr = 20 THEN
         texto :=('El Rendimiento Reducido > Rendimiento');
      ELSIF pnumerr = 21 THEN
         texto :=('El Rendimiento > Bruto');
      ELSIF pnumerr = 22 THEN
         texto :=('El Rendimiento Reducido > base');
      ELSIF pnumerr = 68 THEN
         texto :=('Error al grabar en FIS_IRPFPP');
      ELSE
         texto := f_axis_literales(pnumerr, pcidioma);
      END IF;

--
      IF ptipo = 1 THEN   -- Validación PAGOS
         xtipo := 'V1';
      ELSIF ptipo = 2 THEN   -- Validación PAGOS
         xtipo := 'V2';
      ELSIF ptipo = 3 THEN   -- CARGAS Aportaciones 347
         xtipo := 'C1';
      ELSIF ptipo = 4 THEN   -- CARGAS Aportaciones 345
         xtipo := 'C2';
      ELSIF ptipo = 5 THEN   -- CARGAS RENTAS
         xtipo := 'C3';
      ELSIF ptipo = 6 THEN   -- CARGAS PRESTACIONES
         xtipo := 'C4';
      ELSIF ptipo = 7 THEN   -- CARGAS SINIESTROS
         xtipo := 'C5';
      ELSIF ptipo = 8 THEN   -- CARGAS VENCIMIENTOS
         xtipo := 'C6';
      ELSIF ptipo = 9 THEN   -- CARGA IRPF
         xtipo := 'C7';
      ELSE
         xtipo := 'C';   -- OTRAS CARGA
      END IF;

--
      BEGIN
         pnumord := xnumord;

         INSERT INTO fis_error_carga
                     (sfiscab, nnumord, terror, corigen, cerror, sseguro, sperson, ndocum)
              VALUES (psfiscab, xnumord, texto, xtipo, pnumerr, psseguro, psperson, pndocum);

         COMMIT;
         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            pnumord := NULL;
--          DBMS_OUTPUT.PUT_LINE ('num_err:'||num_err||' Error:'||SQLERRM);
            RETURN 1;
      END;
   END graba_error;

-- ****************************************************************
-- Validaciones en la tabla de Pagos
-- ****************************************************************
   FUNCTION f_validar_pagos(psfiscab IN NUMBER, pcidioma IN NUMBER, pnumerr OUT NUMBER)
      RETURN NUMBER IS
      CURSOR cur_val IS
         SELECT   *
             FROM fis_detcierrepago
            WHERE sfiscab = psfiscab
         ORDER BY spersonp, sperson1;

      xsperantp      NUMBER(10);
      xsperant1      NUMBER(10);
      num_err        NUMBER;
      xnnumnifp      VARCHAR2(20);
      xnnumnif1      VARCHAR2(20);
      xtapelli       VARCHAR2(40);
      xtnombre       VARCHAR2(20);
      paso           NUMBER;
      xtdomici       VARCHAR2(40);
      xcpostal       codpostal.cpostal%TYPE;   --3606 jdomingo 30/11/2007  canvi format codi postal
      xcprovin       NUMBER(3);
      ulterror       NUMBER;
   BEGIN
      xsperantp := 0;
      xsperant1 := 0;
      pnumerr := 0;

      BEGIN
         DELETE FROM fis_error_carga
               WHERE sfiscab = psfiscab;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      --DBMS_OUTPUT.PUT_LINE (' Error:'||SQLERRM);
      END;

      COMMIT;

      FOR val IN cur_val LOOP
--   ********************************************************
--   Valido NIF del Perceptor
--   ********************************************************
         num_err := 0;
         ulterror := 0;

         IF xsperantp <> val.spersonp THEN
            IF val.csubtipo IN(188, 296, 190, 199) THEN
               paso := 0;

               -- Validación de que si es un extranjero no salga en los mod. 188 y 190
               IF val.tidentip IN(3, 7)
                  AND val.csubtipo IN(188, 190) THEN
                  pnumerr := pnumerr + 1;
                  num_err := graba_error(psfiscab, 1, val.spersonp, val.sseguro, pcidioma,
                                         NULL, 1, ulterror);
               END IF;

               paso := 1;

               IF val.tidentip IN(1, 2) THEN   -- Validación del Nif o Cif
                  xnnumnifp := val.nnumnifp;
                  paso := 2;
                  num_err := f_nif(xnnumnifp);
                  paso := 3;

                  IF num_err <> 0 THEN
                     paso := 4;
                     pnumerr := pnumerr + 1;
                     num_err := graba_error(psfiscab, num_err, val.spersonp, val.sseguro,
                                            pcidioma, NULL, 1, ulterror);
                  END IF;
               END IF;

--   ********************************************************
--   Valido Nombre del Perceptor
--   ********************************************************
               paso := 5;

               BEGIN
                  SELECT SUBSTR(d.tapelli1, 0, 40) || ' ' || SUBSTR(d.tapelli2, 0, 20),
                         SUBSTR(d.tnombre, 0, 20)
                    INTO xtapelli,
                         xtnombre
                    FROM per_personas p, per_detper d, seguros s
                   WHERE p.sperson = d.sperson
                     AND d.cagente = ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres)
                     AND s.sseguro = val.sseguro
                     AND p.sperson = val.spersonp;
               EXCEPTION
                  WHEN OTHERS THEN
                     paso := 6;
                     pnumerr := pnumerr + 1;
                     -- Error al leer Personas
                     num_err := graba_error(psfiscab, 104389, val.spersonp, val.sseguro,
                                            pcidioma, NULL, 1, ulterror);
               END;

--
               paso := 7;

               IF xtapelli IS NULL
                  OR xtnombre IS NULL THEN   -- Nombre no informado
                  paso := 8;
                  pnumerr := pnumerr + 1;
                  num_err := graba_error(psfiscab, 4, val.spersonp, val.sseguro, pcidioma,
                                         NULL, 1, ulterror);
               END IF;

               paso := 9;

--   ********************************************************
--   Valido IMPORTES
--   ********************************************************
-- El rendimiento reducido no puede ser menor que el rendimiento
               IF ABS(val.iresred) > ABS(val.iresrcm)
                  AND val.ctipo <> 'PRE' THEN
                  paso := 10;
                  pnumerr := pnumerr + 1;
                  num_err := graba_error(psfiscab, 20, val.spersonp, val.sseguro, pcidioma,
                                         NULL, 1, ulterror);
               END IF;

-- El rendimiento no puede ser mayor que el bruto
               IF (ABS(val.iresrcm) > ABS(val.ibruto)
                   AND val.iresrcm > 0
                   AND val.iresred > 0) THEN
                  paso := 11;
                  pnumerr := pnumerr + 1;
                  num_err := graba_error(psfiscab, 21, val.spersonp, val.sseguro, pcidioma,
                                         NULL, 1, ulterror);
               END IF;

-- La base de Retención no puede ser mayor que el rendimiento reducido
               IF (ABS(val.ibase) > ABS(val.iresred)
                   AND val.iresrcm > 0
                   AND val.iresred > 0) THEN
                  paso := 12;
                  pnumerr := pnumerr + 1;
                  num_err := graba_error(psfiscab, 22, val.spersonp, val.sseguro, pcidioma,
                                         NULL, 1, ulterror);
               END IF;

--   ********************************************************
--   Valido Dirección del Perceptor
--   ********************************************************
               IF val.cprovin IS NULL THEN
                  paso := 13;
                  pnumerr := pnumerr + 1;
                  -- PROVINCIA DESCONOCIDA
                  num_err := graba_error(psfiscab, 107752, val.spersonp, val.sseguro,
                                         pcidioma, NULL, 1, ulterror);
               END IF;
            END IF;   -- IF val.csubtipo in (188,296,190,199)
         END IF;   -- IF xsperantp <> val.spersonp

         paso := 16;

--   ********************************************************
--   Valido NIF del Representante si hay
--   ********************************************************
         IF val.sperson1 IS NOT NULL THEN
            IF xsperant1 <> val.sperson1 THEN
               IF val.tidenti1 IN(1, 2) THEN
                  paso := 17;
                  xnnumnif1 := val.nnumnif1;
                  num_err := f_nif(xnnumnif1);

                  IF num_err <> 0 THEN
                     num_err := graba_error(psfiscab, 9, val.spersonp, val.sseguro, pcidioma,
                                            NULL, 1, ulterror);
                     pnumerr := pnumerr + 1;
                  END IF;

                  paso := 18;
               END IF;
            END IF;
         END IF;

--
         IF ulterror > 0 THEN
            BEGIN
               UPDATE fis_detcierrepago
                  SET cerror = ulterror
                WHERE sfiscab = psfiscab
                  AND sfisdpa = val.sfisdpa;

               COMMIT;
            EXCEPTION
               WHEN OTHERS THEN
                  paso := 19;
--             DBMS_OUTPUT.PUT_LINE ('PASO:'||PASO||' Error:'||SQLERRM);
                  RETURN paso;
            END;
         END IF;

--
         xsperant1 := val.sperson1;
         xsperantp := val.spersonp;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
--       DBMS_OUTPUT.PUT_LINE ('PASO:'||PASO||' Error:'||SQLERRM);
         RETURN paso;
   END;

-- ****************************************************************
-- Validaciones en la tabla de Cobros
-- ****************************************************************
   FUNCTION f_validar_cobros(psfiscab IN NUMBER, pcidioma IN NUMBER, pnumerr OUT NUMBER)
      RETURN NUMBER IS
      CURSOR cur_val IS
         SELECT   *
             FROM fis_detcierrecobro
            WHERE sfiscab = psfiscab
         ORDER BY spersonp, sperson1;

      xsperantp      NUMBER(10);
      xsperant1      NUMBER(10);
      num_err        NUMBER;
      xnnumnifp      VARCHAR2(20);
      xnnumnif1      VARCHAR2(20);
      xtapelli       VARCHAR2(40);
      xtnombre       VARCHAR2(20);
      paso           NUMBER;
      xtdomici       VARCHAR2(40);
      xcpostal       codpostal.cpostal%TYPE;   --3606 jdomingo 30/11/2007  canvi format codi postal
      xcprovin       NUMBER(3);
      ulterror       NUMBER;
   BEGIN
      xsperantp := 0;
      xsperant1 := 0;
      pnumerr := 0;

      BEGIN
         DELETE FROM fis_error_carga
               WHERE sfiscab = psfiscab;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
--      DBMS_OUTPUT.PUT_LINE (' Error:'||SQLERRM);
      END;

      COMMIT;

      FOR val IN cur_val LOOP
--   ********************************************************
--   Valido NIF del Perceptor
--   ********************************************************
         num_err := 0;
         ulterror := 0;

         IF xsperantp <> val.spersonp THEN
            paso := 0;

            IF val.tidentip IN(1, 2) THEN   -- Validación del Nif o Cif
               xnnumnifp := val.nnumnifp;
               paso := 2;
               num_err := f_nif(xnnumnifp);
               paso := 3;

               IF num_err <> 0 THEN
                  paso := 4;
                  pnumerr := pnumerr + 1;
                  num_err := graba_error(psfiscab, num_err, val.spersonp, val.sseguro,
                                         pcidioma, NULL, 1, ulterror);
               END IF;
            END IF;

--   ********************************************************
--   Valido Nombre del Perceptor
--   ********************************************************
            paso := 5;

            BEGIN
               SELECT SUBSTR(d.tapelli1, 0, 40) || ' ' || SUBSTR(d.tapelli2, 0, 20),
                      SUBSTR(d.tnombre, 0, 20)
                 INTO xtapelli,
                      xtnombre
                 FROM per_personas p, per_detper d, seguros s
                WHERE p.sperson = d.sperson
                  AND d.cagente = ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres)
                  AND s.sseguro = val.sseguro
                  AND p.sperson = val.spersonp;
            EXCEPTION
               WHEN OTHERS THEN
                  paso := 6;
                  pnumerr := pnumerr + 1;
                  -- Error al leer Personas
                  num_err := graba_error(psfiscab, 104389, val.spersonp, val.sseguro,
                                         pcidioma, NULL, 1, ulterror);
            END;

--
            paso := 7;

            IF xtapelli IS NULL
               OR xtnombre IS NULL THEN   -- Nombre no informado
               paso := 8;
               pnumerr := pnumerr + 1;
               num_err := graba_error(psfiscab, 4, val.spersonp, val.sseguro, pcidioma, NULL,
                                      1, ulterror);
            END IF;

            paso := 9;

--   ********************************************************
--   Valido Dirección del Perceptor
--   ********************************************************
            IF val.cprovin IS NULL THEN
               paso := 13;
               pnumerr := pnumerr + 1;
               -- PROVINCIA DESCONOCIDA
               num_err := graba_error(psfiscab, 107752, val.spersonp, val.sseguro, pcidioma,
                                      NULL, 1, ulterror);
            END IF;
         END IF;   -- IF xsperantp <> val.spersonp

         paso := 16;

--   ********************************************************
--   Valido NIF del Representante si hay
--   ********************************************************
         IF val.sperson1 IS NOT NULL THEN
            IF xsperant1 <> val.sperson1 THEN
               IF val.tidenti1 IN(1, 2) THEN
                  paso := 17;
                  xnnumnif1 := val.nnumnif1;
                  num_err := f_nif(xnnumnif1);

                  IF num_err <> 0 THEN
                     num_err := graba_error(psfiscab, 9, val.spersonp, val.sseguro, pcidioma,
                                            NULL, 1, ulterror);
                     pnumerr := pnumerr + 1;
                  END IF;

                  paso := 18;
               END IF;
            END IF;
         END IF;

--
         IF ulterror > 0 THEN
            BEGIN
               UPDATE fis_detcierrecobro
                  SET cerror = ulterror
                WHERE sfiscab = psfiscab
                  AND sfisdco = val.sfisdco;

               COMMIT;
            EXCEPTION
               WHEN OTHERS THEN
                  paso := 19;
--           DBMS_OUTPUT.PUT_LINE ('PASO:'||PASO||' Error:'||SQLERRM);
                  RETURN paso;
            END;
         END IF;

--
         xsperant1 := val.sperson1;
         xsperantp := val.spersonp;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
--       DBMS_OUTPUT.PUT_LINE ('PASO:'||PASO||' Error:'||SQLERRM);
         RETURN paso;
   END;

--
--
-- ****************************************************************
-- Carga Cuadro de IRPF
-- ****************************************************************
   PROCEDURE carga_fis_irpf(
      psseguro IN NUMBER,
      psperson IN NUMBER,
      panyo IN NUMBER,
      psfiscab IN NUMBER,
      pnnumord IN OUT NUMBER) IS
      -- Variables de IRPFPERSONAS
      xnifcon        VARCHAR2(10);   -- Nif Conyuge del perceptor
      xcsitfam       NUMBER(1);   -- Código Situación Familiar
      xcgradop       NUMBER(1);   -- Grado de discapacidad perceptor
      xipension      NUMBER(25, 10);   -- Pensión Compensatoria al conyuge
      xrmovgeo       NUMBER(1);   -- Reducción Movilidad Geografica
      xprolon        NUMBER(1);   -- Prolongación Actividad Laboral
      xianuhijos     NUMBER(25, 10);   -- Anualidades por alimentos Hijos
      xnanynac       NUMBER(4);   -- Año de nacimiento del perceptor
      -- Variables de DECENDIENTES
      xndecmen25     VARCHAR2(8);   -- Descendientes < 25
                                    -- (1-2p)--> < 3años
                                    -- (3-4p)--> >=3 a < 16
                                    -- (5-6p)--> < 25 años
      xntdem25en     VARCHAR2(8);   -- Total Entero Descendientes < 25
                                    -- (1-2p)--> < 3años
                                    -- (3-4p)--> >=3 a < 16
                                    -- (5-6p)--> < 25 años
      xndecdisto     NUMBER(2);   -- Total de descendientes discapap.
      xndecdisca     VARCHAR2(8);   -- Nro. Dec. Discapacitados por grado
                                    -- (1-2p)--> 33% a < 65%
                                    -- (3-4p)--> 65%
      -- (5-6p)--> 33% a < 65% sin movilidad
      xntdedisen     VARCHAR2(8);   -- Total Entero Dec. Discapacitados por grado
                                    -- (1-2p)--> 33% a < 65%
                                    -- (3-4p)--> 65%
      -- (5-6p)--> 33% a < 65% sin movilidad
      xndecdisen     NUMBER(2);   -- Nro. Dec. comput.por Entero.
      xxndecdisca    VARCHAR2(8);
      -- Variables de ASCENDENTES
      xnasctotal     NUMBER(1);   -- Total de Ascendentes discapa.
      xnascenter     NUMBER(1);   -- Nro. Asc. Discapacitados comput.por Entero.
      xnascendie     VARCHAR2(8);   -- Nro. Ascendentes por edad
                                    -- (1-1p)--> <75 años
                                    -- (2-2p)--> >=75 años
      xntascenen     VARCHAR2(8);   -- Total Entero Nro. Asc. por edad
                                    -- (1-1p)--> <75 años
                                    -- (2-2p)--> >=75 años
      xnascdisca     VARCHAR2(8);   -- Nro. Asc. Discapacitados por grado
                                    -- (1-1p)--> 33% a < 65%
                                    -- (2-2p)--> 65%
      -- (3-3p)--> 33% a < 65% sin movilidad
      xntasdisen     VARCHAR2(8);   -- Total Entero Asc. Discapacitados por grado
                                    -- (1-1p)--> 33% a < 65%
                                    -- (2-2p)--> 65%
      -- (3-3p)--> 33% a < 65% sin movilidad
      xxnascdisca    VARCHAR2(8);
      -- Otras Variables
      xnanyo         NUMBER(4);
      xanys          NUMBER(3);
      paso           NUMBER(2);
      xsfisdpa       NUMBER;
      num_err        NUMBER;
      --
      xnnumnif       personas.nnumnif%TYPE;
      xtidenti       personas.tidenti%TYPE;
      xcpais         personas.cpais%TYPE;
      vcagente       agentes.cagente%TYPE;
      vcempres       empresas.cempres%TYPE;
   --
   BEGIN
      --
      num_err := f_datos_personales(psperson, xnnumnif, xtidenti, xcpais);

      --
      BEGIN
         SELECT cagente, cempres
           INTO vcagente, vcempres
           FROM seguros
          WHERE sseguro = psseguro;

         SELECT csitfam, LTRIM(RTRIM(cnifcon)), cgrado, ipension, ianuhijos, rmovgeo, prolon
           INTO xcsitfam, xnifcon, xcgradop, xipension, xianuhijos, xrmovgeo, xprolon
           FROM per_irpf
          WHERE sperson = psperson
            AND cagente = ff_agente_cpervisio(vcagente, f_sysdate, vcempres);

         xnifcon := dni_pos(xnifcon);
      EXCEPTION
         WHEN OTHERS THEN
            xcsitfam := 0;
            xnifcon := NULL;
            xcgradop := 0;
            xipension := 0;
            xianuhijos := 0;
            xrmovgeo := 0;
            xprolon := 0;
      END;

      --
      paso := 1;

      --
      BEGIN
         SELECT NVL(TO_NUMBER(TO_CHAR(fnacimi, 'YYYY')), 0)
           INTO xnanynac
           FROM per_personas
          WHERE sperson = psperson;
      EXCEPTION
         WHEN OTHERS THEN
            xnanynac := 0000;
      END;

      --
      paso := 2;
      xndecmen25 := '00000000';
      xntdem25en := '00000000';
      xndecdisca := '00000000';
      xntdedisen := '00000000';
      xndecdisto := 0;
      xndecdisen := 0;

      --
      FOR i IN (SELECT fnacimi, cgrado, center
                  FROM irpfdescendientes
                 WHERE sperson = psperson) LOOP
         xanys := panyo - TO_NUMBER(TO_CHAR(i.fnacimi, 'YYYY'));

         --IF I.CGRADO IS NULL THEN
            -- Descendientes
         IF xanys < 3 THEN
            xndecmen25 := REPLACE(LPAD(SUBSTR(xndecmen25, 1, 2) + 1 || SUBSTR(xndecmen25, 3),
                                       8),
                                  ' ', '0');

            IF NVL(i.center, 0) = 1 THEN
               xntdem25en := REPLACE(LPAD(SUBSTR(xntdem25en, 1, 2) + 1
                                          || SUBSTR(xntdem25en, 3),
                                          8),
                                     ' ', '0');
            END IF;
         ELSIF xanys >= 3
               AND xanys < 16 THEN
            xndecmen25 := REPLACE(LPAD(SUBSTR(xndecmen25, 1, 2) || SUBSTR(xndecmen25, 3, 2)
                                       + 1 || SUBSTR(xndecmen25, 5),
                                       8),
                                  ' ', '0');

            IF NVL(i.center, 0) = 1 THEN
               xntdem25en := REPLACE(LPAD(SUBSTR(xntdem25en, 1, 2) || SUBSTR(xntdem25en, 3, 2)
                                          + 1 || SUBSTR(xntdem25en, 5),
                                          8),
                                     ' ', '0');
            END IF;
         ELSE
            xndecmen25 := REPLACE(LPAD(SUBSTR(xndecmen25, 1, 4) || SUBSTR(xndecmen25, 5, 2)
                                       + 1 || SUBSTR(xndecmen25, 7),
                                       8),
                                  ' ', '0');

            IF NVL(i.center, 0) = 1 THEN
               xntdem25en := REPLACE(LPAD(SUBSTR(xntdem25en, 1, 4) || SUBSTR(xntdem25en, 5, 2)
                                          + 1 || SUBSTR(xntdem25en, 7),
                                          8),
                                     ' ', '0');
            END IF;
         END IF;

         -- Descendientes descapacitados
         IF i.cgrado = 1 THEN
            xndecdisca := REPLACE(LPAD(SUBSTR(xndecdisca, 1, 2) + 1 || SUBSTR(xndecdisca, 3),
                                       8),
                                  ' ', '0');

            IF NVL(i.center, 0) = 1 THEN
               xntdedisen := REPLACE(LPAD(SUBSTR(xntdedisen, 1, 2) + 1
                                          || SUBSTR(xntdedisen, 3),
                                          8),
                                     ' ', '0');
            END IF;
         ELSIF i.cgrado = 2 THEN
            xndecdisca := REPLACE(LPAD(SUBSTR(xndecdisca, 1, 2) || SUBSTR(xndecdisca, 3, 2)
                                       + 1 || SUBSTR(xndecdisca, 5),
                                       8),
                                  ' ', '0');

            IF NVL(i.center, 0) = 1 THEN
               xntdedisen := REPLACE(LPAD(SUBSTR(xntdedisen, 1, 2) || SUBSTR(xntdedisen, 3, 2)
                                          + 1 || SUBSTR(xntdedisen, 5),
                                          8),
                                     ' ', '0');
            END IF;
         ELSIF i.cgrado = 3 THEN
            xndecdisca := REPLACE(LPAD(SUBSTR(xndecdisca, 1, 4) || SUBSTR(xndecdisca, 5, 2)
                                       + 1 || SUBSTR(xndecdisca, 7),
                                       8),
                                  ' ', '0');

            IF NVL(i.center, 0) = 1 THEN
               xntdedisen := REPLACE(LPAD(SUBSTR(xntdedisen, 1, 4) || SUBSTR(xntdedisen, 5, 2)
                                          + 1 || SUBSTR(xntdedisen, 7),
                                          8),
                                     ' ', '0');
            END IF;
         END IF;

         --
         xndecdisto := xndecdisto + 1;
         xndecdisen := xndecdisen + NVL(i.center, 0);
      END LOOP;

      --
      xnascdisca := '00000000';
      xntasdisen := '00000000';
      xnascendie := '00000000';
      xntascenen := '00000000';
      xnascenter := 0;
      xnasctotal := 0;
      paso := 3;

      --
      FOR i IN (SELECT fnacimi, cgrado, crenta, nviven
                  FROM irpfmayores
                 WHERE sperson = psperson) LOOP
         xanys := xnanyo - TO_NUMBER(TO_CHAR(i.fnacimi, 'YYYY'));
         xnasctotal := xnasctotal + 1;

         -- Ascendientes
         IF xanys < 75 THEN
            xnascendie := REPLACE(LPAD(SUBSTR(xnascendie, 1, 1) + 1 || SUBSTR(xnascendie, 2),
                                       8),
                                  ' ', '0');
            xntascenen := REPLACE(LPAD(SUBSTR(xntascenen, 1, 1) + 1 || SUBSTR(xntascenen, 2),
                                       8),
                                  ' ', '0');
         ELSE
            xnascendie := REPLACE(LPAD(SUBSTR(xnascendie, 1, 1) || SUBSTR(xnascendie, 2, 1)
                                       + 1 || SUBSTR(xnascendie, 3),
                                       8),
                                  ' ', '0');
            xntascenen := REPLACE(LPAD(SUBSTR(xntascenen, 1, 1) || SUBSTR(xntascenen, 2, 1)
                                       + 1 || SUBSTR(xntascenen, 3),
                                       8),
                                  ' ', '0');
         END IF;

         IF i.nviven IS NULL
            OR i.nviven = 0 THEN
            xnascenter := xnascenter + 1;
         END IF;

         IF i.cgrado IS NOT NULL THEN
            xxnascdisca := xnascdisca;

            IF i.cgrado = 1 THEN
               xnascdisca := REPLACE(LPAD(SUBSTR(xnascdisca, 1, 1) + 1
                                          || SUBSTR(xnascdisca, 2),
                                          8),
                                     ' ', '0');

               IF i.nviven IS NULL
                  OR i.nviven = 0 THEN
                  xntasdisen := REPLACE(LPAD(SUBSTR(xntasdisen, 1, 1) + 1
                                             || SUBSTR(xntasdisen, 2),
                                             8),
                                        ' ', '0');
               END IF;
            ELSIF i.cgrado = 2 THEN
               xnascdisca := REPLACE(LPAD(SUBSTR(xnascdisca, 1, 1) || SUBSTR(xnascdisca, 2, 1)
                                          + 1 || SUBSTR(xnascdisca, 3),
                                          8),
                                     ' ', '0');

               IF i.nviven IS NULL
                  OR i.nviven = 0 THEN
                  xntasdisen := REPLACE(LPAD(SUBSTR(xntasdisen, 1, 1)
                                             || SUBSTR(xntasdisen, 2, 1) + 1
                                             || SUBSTR(xntasdisen, 3),
                                             8),
                                        ' ', '0');
               END IF;
            ELSIF i.cgrado = 3 THEN
               xnascdisca := REPLACE(LPAD(SUBSTR(xnascdisca, 1, 2) || SUBSTR(xnascdisca, 3, 1)
                                          + 1 || SUBSTR(xnascdisca, 4),
                                          8),
                                     ' ', '0');

               IF i.nviven IS NULL
                  OR i.nviven = 0 THEN
                  xntasdisen := REPLACE(LPAD(SUBSTR(xntasdisen, 1, 2)
                                             || SUBSTR(xntasdisen, 3, 1) + 1
                                             || SUBSTR(xntasdisen, 4),
                                             8),
                                        ' ', '0');
               END IF;
            END IF;
         END IF;
      END LOOP;

      paso := 4;

      -- Grabo los datos
      BEGIN
         INSERT INTO fis_irpfpp
                     (sfiscab, sperson, nnifper, nnifcon, csitfam, nanynac,
                      cgradop, ipension, ianuhijos, ndecmen25,
                      ndecdisto, ndecdisca, ndecdisen, nasctotal, nascenter, nascdisca,
                      ntdem25en, ntdedisen, nascendie, ntascenen, ntasdisen,
                      prolon, rmovgeo)
              VALUES (psfiscab, psperson, xnnumnif, xnifcon, xcsitfam, xnanynac,
                      NVL(xcgradop, 0), NVL(xipension, 0), NVL(xianuhijos, 0), xndecmen25,
                      xndecdisto, xndecdisca, xndecdisen, xnasctotal, xnascenter, xnascdisca,
                      xntdem25en, xntdedisen, xnascendie, xntascenen, xntasdisen,
                      NVL(xprolon, 0), NVL(xrmovgeo, 0));
      EXCEPTION
         WHEN OTHERS THEN
            BEGIN
               UPDATE fis_irpfpp
                  SET nnifper = xnnumnif,
                      nnifcon = xnifcon,
                      csitfam = xcsitfam,
                      nanynac = xnanynac,
                      cgradop = NVL(xcgradop, 0),
                      ipension = NVL(xipension, 0),
                      ianuhijos = NVL(xianuhijos, 0),
                      ndecmen25 = xndecmen25,
                      ndecdisto = xndecdisto,
                      ndecdisca = xndecdisca,
                      ndecdisen = xndecdisen,
                      nasctotal = xnasctotal,
                      nascenter = xnascenter,
                      nascdisca = xnascdisca,
                      ntdem25en = xntdem25en,
                      ntdedisen = xntdedisen,
                      nascendie = xnascendie,
                      ntascenen = xntascenen,
                      ntasdisen = xntasdisen,
                      prolon = NVL(xprolon, 0),
                      rmovgeo = NVL(xrmovgeo, 0)
                WHERE sfiscab = psfiscab
                  AND sperson = psperson;
            EXCEPTION
               WHEN OTHERS THEN
             -- Error al Insertar en tabla FIS_IRPFPP
--             DBMS_OUTPUT.put_line('PRESTA IRPFPP ERROR:'||SQLERRM);
                  num_err := graba_error(psfiscab, 68, psperson, psseguro, 1, 0, 6, pnnumord);
            END;
      END;
   END;
END pk_fis_hacienda;

/

  GRANT EXECUTE ON "AXIS"."PK_FIS_HACIENDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_FIS_HACIENDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_FIS_HACIENDA" TO "PROGRAMADORESCSI";
