--------------------------------------------------------
--  DDL for Package Body PAC_REF_GET_INFORMES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_REF_GET_INFORMES" AS
/****************************************************************************

   NOM:       pac_ref_get_datos
   PROPÒSIT:

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   1.0        --/--/----   ---               ---
   1.1.       29/11/2011   NMM              1.1. Canvis per la versió 11g. d' Oracle
****************************************************************************/--  MSR 31/7/2007
   -- Torna les pòlisses a mostrar per la consulta abans d'imprimir
   --
   --  Paràmetres
   --    pfDesde   Obligatori
   --    pfHasta   Obligatori
   --    pcEmpresa Opcional
   --    pcAgrpro  Opcional
   --    pcRamo    Opcional
   --    psProduc  Opcional
   --    pnNumnif  Opcional
   --    ptBuscar  Opcional
   --    pcAgente  NULL per totes les oficines, altrament ha de venir informat
   --    pConsultaReport  'C' quan es crida per la consulta, 'R' quan es crida pel report, 'V' quan es crida pel llistat de pòlisses a vèncer
   --    pMultilinia   'S' si la pòlissa te 2 titulars tornar-los en 2 linies
   --                  'N' si la pòlissa te 2 titulars tornar-los en 1 linia
   --                  Si s'envia a NULL: quan pConsultaReport = 'C' val 'S', quan pConsultaReport = 'R' val 'N', quan pConsultaReport = 'V' val 'N'
   --
   --  Dades tornades :
   --  Falta_NIE / Baixa_Titular con consultas que devuelven un solo titular
   --               0 - No falta
   --               1 - Falta primer titular
   --               2 - Falta segundo titular
   --               3 - Faltan ambos titulares
   --
   --  Falta_NIE / Baixa_Titular con consultas y reports que devuelven todos los titulares
   --               0 - No falta
   --               1 - Falta
   --
   -- Ordenació per
   --         Report   : Agrpro / Producte / Data / Polissa
   --         Consulta : Nif / Agrpro / Producte / Data / Polissa
   --         Venciment: Agrpro / Producte / Data / Polissa
   -- Agrupació del report
   --         Report   : Producte +  Totals finals
   --         Consulta : Totals finals
   --         Venciment: Producte +  Totals finals
   --
   --
   -- Bug 35888 - 2015/05/21 - CJMR: Realizar la substitución del upper nnumnif
   FUNCTION f_polizas_a_vencer(
      pcidioma IN seguros.cidioma%TYPE,
      pfdesde IN DATE,
      pfhasta IN DATE,
      pcempresa IN seguros.cempres%TYPE,
      pcagrpro IN seguros.cagrpro%TYPE,
      pcramo IN ramos.cramo%TYPE,
      psproduc IN productos.sproduc%TYPE,
      pnnumnif IN VARCHAR2,
      ptbuscar IN VARCHAR2,
      pcagente IN seguros.cagente%TYPE,
      pconsultareport IN VARCHAR2,
      pmultilinia IN VARCHAR2)
      RETURN ct_polizas_a_vencer IS
      v_cursor       ct_polizas_a_vencer;
      v_tots_els_titulars CONSTANT VARCHAR2(1)
         := CASE ptbuscar IS NOT NULL
                 OR pnnumnif IS NOT NULL
                 OR pconsultareport IN('R', 'V')
         WHEN TRUE THEN 'S'
         ELSE 'N'
      END;
      v_multilinia CONSTANT VARCHAR2(1)
                        := NVL(pmultilinia, CASE
                                  WHEN pconsultareport IN('R', 'V') THEN 'N'
                                  ELSE 'S'
                               END);   -- 'S' si els 2 titulars són tornats a 2 linies diferents
   BEGIN
      OPEN v_cursor FOR
         SELECT   y.ordre_client, y.cagrpro, y.cramo, y.sproduc, y.fecha, y.ordre_polissa,
                  RANK() OVER(PARTITION BY y.ordre_client, y.sproduc, y.fecha, y.poliza ORDER BY y.norden_1)
                                                                                orden_titular,
                  y.agrupacio_1, y.ttitulo, y.poliza, y.nsolici, y.fefecto, y.cagente,
                  y.tipus, y.provision, y.capgar, TO_CHAR(NULL) descuadre, y.sseguro,
                  y.frevisio, y.fvencim, y.sperson_1, y.nnumnif_1, y.titular_1, y.cpais_1,
                  y.tpais_1, y.sperson_2, y.nnumnif_2, y.titular_2, y.cpais_2, y.tpais_2,
                  CASE v_multilinia
                     WHEN 'S' THEN pac_calc_comu.ff_falta_nie(y.sseguro,
                                                              y.sperson_1, y.fecha)
                     -- Quan només hi ha un titular per línia sempre és el sperson_1
                  ELSE pac_calc_comu.ff_falta_nie(y.sseguro, NULL, y.fecha)
                  END falta_nie,
                  CASE v_multilinia
                     WHEN 'S' THEN pac_calc_comu.ff_baixa_titular(y.sseguro,
                                                                  y.sperson_1,
                                                                  y.fecha)
                     -- Quan només hi ha un titular per línia sempre és el sperson_1
                  ELSE pac_calc_comu.ff_baixa_titular(y.sseguro, NULL, y.fecha)
                  END baixa_titular
             FROM (SELECT x.*, CASE
                             WHEN x.tipus = 'R' THEN x.frevisio
                             ELSE x.fvencim
                          END fecha,
                          fbuscasaldo(NULL, x.sseguro,
                                      TO_CHAR(f_sysdate, 'YYYYMMDD')) provision,
                          f_capgar_ult_act(x.sseguro, f_sysdate) capgar
                     FROM (SELECT   ROWNUM ordre_polissa,

                                    -- En el cas de la consulta per pantalla cal ordenar per client però no pel report
                                    CASE pconsultareport
                                       WHEN 'C' THEN p1.nnumnif
                                       ELSE '.'
                                    END ordre_client,

                                    -- En el cas del report voldrem que aquests agrupi per producte mentre que no si es la consulta
                                    CASE pconsultareport
                                       WHEN 'C' THEN 0
                                       ELSE sproduc
                                    END agrupacio_1, sproduc, s.cagrpro, s.cramo, s.sseguro,
                                    s.nsolici, t.ttitulo,

                                    -- Desc produc
                                    f_formatopol(s.npoliza, s.ncertif, 1) poliza,   -- Polissa / CErtificat
                                                                                 s.fefecto,   -- Data d'efecte
                                    p1.sperson sperson_1, p1.nnumnif nnumnif_1,   -- Cod. Identificacion
                                    LTRIM(p1.tnombre || ' ' || p1.tapelli) titular_1,   -- Titular
                                    p1.cpais cpais_1,   -- Pais residència
                                                     pa1.tpais tpais_1,   -- Nom del país
                                                                       p2.sperson sperson_2,
                                    p2.nnumnif nnumnif_2,

                                    -- Cod. Identificacion
                                    LTRIM(p2.tnombre || ' ' || p2.tapelli) titular_2,   -- Titular
                                    p2.cpais cpais_2,
                                                     -- Pais residència
                                                     pa2.tpais tpais_2,   -- Nom del país
                                                                       s.cagente,   -- Oficina
                                                                                 sa.frevisio,
                                    s.fvencim, a1.norden norden_1,
                                    CASE
                                       WHEN NVL(f_parproductos_v(sproduc, 'DURPER'), 0) =
                                                                                       1
                                       AND s.fvencim <> sa.frevisio THEN 'R'
                                       ELSE 'V'
                                    END tipus
                               FROM productos pr JOIN seguros s USING(sproduc)
                                    LEFT JOIN seguros_aho sa
                                    ON(s.sseguro = sa.sseguro)   -- LEFT per incloure Assegurances de Rendes
                                    JOIN titulopro t
                                    ON(t.ctipseg = pr.ctipseg
                                       AND t.cramo = pr.cramo
                                       AND t.cmodali = pr.cmodali
                                       AND t.ccolect = pr.ccolect)
                                    JOIN asegurados a1
                                    ON(s.sseguro = a1.sseguro
                                       AND((a1.norden = 1
                                            AND v_multilinia = 'N')
                                           OR v_multilinia = 'S'))
                                    JOIN personas p1 ON(a1.sperson = p1.sperson)
                                    LEFT JOIN despaises pa1 ON(p1.cpais = pa1.cpais)
                                    LEFT JOIN asegurados a2
                                    ON(s.sseguro = a2.sseguro
                                       AND(a2.norden = 2
                                           AND v_multilinia = 'N'))
                                    LEFT JOIN personas p2 ON(a2.sperson = p2.sperson)
                                    LEFT JOIN despaises pa2 ON(p2.cpais = pa2.cpais)
                              WHERE t.cidioma = pcidioma
                                AND s.csituac IN(0, 5)
                                AND(s.cempres = pcempresa
                                    OR pcempresa IS NULL)
                                AND(s.cramo = pcramo
                                    OR pcramo IS NULL)
                                AND(sproduc = psproduc
                                    OR psproduc IS NULL)
                                AND(s.cagente = pcagente
                                    OR pcagente IS NULL)
                                AND(pr.cagrpro = pcagrpro
                                    OR pcagrpro IS NULL)
                                AND pr.cagrpro IN
                                                (2, 10, 21)   -- Seguro Ahorro / Multilink / Renta
                                AND(p1.tbuscar LIKE '%' || UPPER(ptbuscar) || '%'
                                    OR p2.tbuscar LIKE '%' || UPPER(ptbuscar) || '%')
                                AND(p1.nnumnif LIKE '%' || pnnumnif || '%'
                                    OR p2.nnumnif LIKE '%' || pnnumnif || '%')   -- Bug 35888 - 2015/05/21 - CJMR
                           ORDER BY s.npoliza, s.ncertif, a1.norden) x
                    WHERE tipus = 'V'
                       OR pconsultareport <> 'V') y
            WHERE y.fecha >= pfdesde
              AND y.fecha <= pfhasta
         ORDER BY y.ordre_client, y.cagrpro, y.sproduc, y.fecha, y.ordre_polissa;

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_REF_GET_DATOS.f_Polizas_a_Vencer', 1,
                     ' pfDesde=' || pfdesde || ' pfHasta=' || pfhasta || 'pcAgrpro='
                     || pcagrpro || ' pcRamo=' || pcramo || ' psProduc=' || psproduc
                     || ' pnNumnif=' || pnnumnif || ' ptBuscar=' || ptbuscar || ' pcAgente='
                     || pcagente || ' pConsultaReport=' || pconsultareport,
                     SQLERRM);

         CLOSE v_cursor;

         RETURN v_cursor;
   END;

   --  MSR 31/7/2007
   -- Torna les pòlisses a mostrar per la consulta abans d'imprimir
   --
   --  Paràmetres
   --    pfDesde   Obligatori
   --    pfHasta   Obligatori
   --    pcEmpresa Opcional
   --    pcAgrpro  Opcional
   --    pcRamo    Opcional
   --    psProduc  Opcional
   --    pcAgente  NULL per totes les oficines, altrament ha de venir informat
   --    pMultilinia   'S' si la pòlissa te 2 titulars tornar-los en 2 linies
   --                  'N' si la pòlissa te 2 titulars tornar-los en 1 linia
   --
   --
   -- Ordenació per
   --         Empresa / Agrpro / Ram / Producte / Pòlissa / Certificat / Titular
   --
   FUNCTION f_contratos_a_revisar(
      pcidioma IN seguros.cidioma%TYPE,
      pfdesde IN DATE,
      pfhasta IN DATE,
      pcempresa IN seguros.cempres%TYPE,
      pcagrpro IN seguros.cagrpro%TYPE,
      pcramo IN ramos.cramo%TYPE,
      psproduc IN productos.sproduc%TYPE,
      pcagente IN seguros.cagente%TYPE,
      pmultilinia IN VARCHAR2)
      RETURN ct_contratos_a_revisar IS
      v_cursor       ct_contratos_a_revisar;
      v_multilinia CONSTANT VARCHAR2(1) := pmultilinia;
   -- 'S' si els 2 titulars són tornats a 2 linies diferents
   BEGIN
            -- Calculs aquí perquè la funció PAC_PROVMAT_FORMUL.F_CALCUL_FORMULAS_PROVI no pot ser
            -- cridada des del SELECT perquè fa INSERTs
--            IF r.cvalpar = 1 THEN
--              v_garant_final_periodo := PAC_PROVMAT_FORMUL.F_CALCUL_FORMULAS_PROVI(psSeguro, F_SYSDATE,'ICGARAC');
--              v_garant_vencimiento := PAC_PROVMAT_FORMUL.F_CALCUL_FORMULAS_PROVI(psSeguro, r.fvencim,'IPROVAC');
--            ELSE
--              v_garant_final_periodo := PAC_PROVMAT_FORMUL.F_CALCUL_FORMULAS_PROVI(psSeguro, r.frevisio -1,'IPROVAC');
--              v_garant_vencimiento := PAC_PROVMAT_FORMUL.F_CALCUL_FORMULAS_PROVI(psSeguro, f_sysdate,'ICGARAC');
--            END IF;
-- F_CAPGAR_ULT_ACT ( r_dades.sseguro, LAST_DAY(pfDesde) ) <- Venciment per tots excepte revisio per 'DURPER'=1
      OPEN v_cursor FOR
         SELECT   s.cempres, s.cagrpro, s.cramo, pr.sproduc, sa.frevisio,
                  ROWNUM ordre_polissa,
                  RANK() OVER(PARTITION BY pr.sproduc, sa.frevisio, s.npoliza, s.ncertif ORDER BY a1.norden)
                                                                                orden_titular,
                  t.ttitulo,   -- Desc produc
                            s.sseguro, f_formatopol(s.npoliza, s.ncertif, 1) poliza,   -- Polissa / CErtificat
                  s.nsolici, s.cagente,   -- Oficina
                                       NVL(sa.ndurper, 1) duracion,
                  pac_inttec.ff_int_seguro('SEG', s.sseguro,
                                           sa.frevisio /*, NVL(sa.ndurper,1)*/) tipint,
                  TO_CHAR(NULL) desquadre, p1.sperson sperson_1, p1.nnumnif nnumnif_1,   -- Cod. Identificacion
                  LTRIM(p1.tnombre || ' ' || p1.tapelli) titular_1,   -- Titular
                                                                   p1.cpais cpais_1,   -- Pais residència
                  pa1.tpais tpais_1,   -- Nom del país
                                    p2.sperson sperson_2, p2.nnumnif nnumnif_2,   -- Cod. Identificacion
                  LTRIM(p2.tnombre || ' ' || p2.tapelli) titular_2,
                                                                   -- Titular
                                                                   p2.cpais cpais_2,   -- Pais residència
                  pa2.tpais tpais_2,   -- Nom del país
                                    pp.cvalpar, NVL(f_parproductos_v(s.sproduc, 'DURPER'), 0)
             FROM productos pr JOIN seguros s ON(pr.sproduc = s.sproduc)
                  JOIN seguros_aho sa
                  ON(s.sseguro = sa.sseguro)   -- LEFT per incloure Assegurances de Rendes
                  JOIN titulopro t
                  ON(t.ctipseg = pr.ctipseg
                     AND t.cramo = pr.cramo
                     AND t.cmodali = pr.cmodali
                     AND t.ccolect = pr.ccolect)
                  JOIN asegurados a1
                  ON(s.sseguro = a1.sseguro
                     AND((a1.norden = 1
                          AND v_multilinia = 'N')
                         OR v_multilinia = 'S'))
                  JOIN personas p1 ON(a1.sperson = p1.sperson)
                  LEFT JOIN despaises pa1 ON(p1.cpais = pa1.cpais)
                  LEFT JOIN asegurados a2
                  ON(s.sseguro = a2.sseguro
                     AND(a2.norden = 2
                         AND v_multilinia = 'N'))
                  LEFT JOIN personas p2 ON(a2.sperson = p2.sperson)
                  LEFT JOIN despaises pa2 ON(p2.cpais = pa2.cpais)
                  LEFT JOIN parproductos pp
                  ON(s.sproduc = pp.sproduc
                     AND pp.cparpro = 'EVOLUPROVMATSEG')
            WHERE t.cidioma = pcidioma
              AND s.csituac IN(0, 5)
              AND(s.cempres = pcempresa
                  OR pcempresa IS NULL)
              AND(s.sproduc = psproduc
                  OR psproduc IS NULL)
              AND(s.cramo = pcramo
                  OR pcramo IS NULL)
              AND(s.cagente = pcagente
                  OR pcagente IS NULL)
              AND(pr.cagrpro = pcagrpro
                  OR pcagrpro IS NULL)
              AND pr.cagrpro IN(2, 10, 21)   -- Seguro Ahorro / Multilink / Renta
              --AND sa.frevisio <> s.fvencim
              AND sa.frevisio BETWEEN pfdesde AND pfhasta
              AND((NVL(f_parproductos_v(s.sproduc, 'RENOVA_REVISA'), 0) = 1
                   AND sa.ndurrev IS NOT NULL
                   AND(s.fvencim = sa.frevisio
                       OR s.fvencim IS NULL))
                  OR(NVL(f_parproductos_v(s.sproduc, 'RENOVA_REVISA'), 0) = 2
                     AND(s.fvencim > sa.frevisio
                         OR s.fvencim IS NULL)))
              AND s.creteni = 0
         ORDER BY s.cempres, pr.cagrpro, pr.cramo, pr.sproduc, sa.frevisio, s.npoliza,
                  s.ncertif, a1.norden;

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_REF_GET_DATOS.f_Contratos_a_Revisar', 1,
                     ' pfDesde=' || pfdesde || ' pfHasta=' || pfhasta || 'pcAgrpro='
                     || pcagrpro || ' pcRamo=' || pcramo || ' psProduc=' || psproduc
                     || ' pcAgente=' || pcagente,
                     SQLERRM);

         CLOSE v_cursor;

         RETURN v_cursor;
   END;

     --  MSR 13/11/2007
   -- Torna les pòlisses amb 2 o més rebuts pendents
   --
   --  Paràmetres
   --    pcEmpresa Opcional
   --    pcAgrpro  Opcional
   --    pcRamo    Opcional
   --    psProduc  Opcional
   --    pcAgente  NULL per totes les oficines, altrament ha de venir informat
   --
   -- Ordenació per
   --         TF   : nNumnif / Producte
   --         Dpt. : Agrpro / Ram / Producte / Polissa
   -- Agrupació report
   --         TF  : No
   --         Dpt. : Agrpro / Ram / Producte
   --
   FUNCTION f_rfefecto(psseguro IN seguros.sseguro%TYPE, p_quin IN NUMBER)
      RETURN DATE IS
   BEGIN
      FOR r IN (SELECT fefecto
                  FROM (SELECT r.fefecto, DENSE_RANK() OVER(ORDER BY r.fefecto, nrecibo) r
                          FROM recibos r JOIN movrecibo mr USING(nrecibo)
                               JOIN vdetrecibos dr USING(nrecibo)
                         WHERE r.sseguro = psseguro
                           AND mr.fmovfin IS NULL
                           AND mr.cestrec = 0
                           AND mr.cestant <> 0)
                 WHERE r = p_quin) LOOP
         RETURN r.fefecto;
      END LOOP;

      RETURN NULL;
   END;

   FUNCTION f_rimporte(psseguro IN seguros.sseguro%TYPE, p_quin IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      FOR r IN (SELECT itotalr
                  FROM (SELECT dr.itotalr, DENSE_RANK() OVER(ORDER BY r.fefecto, nrecibo) r
                          FROM recibos r JOIN movrecibo mr USING(nrecibo)
                               JOIN vdetrecibos dr USING(nrecibo)
                         WHERE r.sseguro = psseguro
                           AND mr.fmovfin IS NULL
                           AND mr.cestrec = 0
                           AND mr.cestant <> 0)
                 WHERE r = p_quin) LOOP
         RETURN r.itotalr;
      END LOOP;

      RETURN NULL;
   END;

   FUNCTION f_2_recibos_pendientes(
      pcidioma IN seguros.cidioma%TYPE,
      pcempresa IN seguros.cempres%TYPE,
      pcagrpro IN seguros.cagrpro%TYPE,
      pcramo IN ramos.cramo%TYPE,
      psproduc IN productos.sproduc%TYPE,
      pcagente IN seguros.cagente%TYPE,
      ptfdpt IN VARCHAR2   -- 'T' o 'D'
                        )
      RETURN ct_2_recibos_pendientes IS
      v_cursor       ct_2_recibos_pendientes;
   BEGIN
      OPEN v_cursor FOR
         SELECT   --+ ORDERED
                  ROWNUM orden_report, s.cempres, s.cagrpro, cramo, s.sproduc, t.ttitulo,
                  s.cagente, sseguro, f_formatopol(s.npoliza, s.ncertif, 1) contrato,   -- Polissa / CErtificat
                                                                                     sperson,
                  p.nnumnif,   -- Cod. Identificacion
                            LTRIM(p.tnombre || ' ' || p.tapelli) titular,   -- Titular
                                                                         cpais cpais,   -- Pais residència
                  pa.tpais tpais,   -- Nom del país
                                 p.cbancar, f_recpen_pp(sseguro, 2) import_pendent,   -- Import total
                  f_rfefecto(sseguro, 1), f_rimporte(sseguro, 1), f_rfefecto(sseguro, 2),
                  f_rimporte(sseguro, 2)
             FROM seguros s JOIN asegurados a USING(sseguro)
                  JOIN personas p USING(sperson)
                  JOIN despaises pa USING(cpais)
                  JOIN titulopro t USING(ctipseg, cramo, cmodali, ccolect)
            WHERE s.csituac IN(0, 5)
              AND(s.cempres = pcempresa
                  OR pcempresa IS NULL)
              AND(cagrpro = pcagrpro
                  OR pcagrpro IS NULL)
              AND cagrpro IN(2, 10, 21)   -- Seguro Ahorro / Multilink / Renta
              AND(cramo = pcramo
                  OR pcramo IS NULL)
              AND(sproduc = psproduc
                  OR psproduc IS NULL)
              AND(s.cagente = pcagente
                  OR pcagente IS NULL)
              AND t.cidioma = pcidioma
              AND a.norden = 1
              AND f_situacion_v(sseguro, f_sysdate) =
                                                1   ---25803   Control del F_SYSDATE (Regla 6.2.d)
              AND f_recpen_pp(sseguro, 1) >= 2
         ORDER BY CASE
                     WHEN ptfdpt = 'T' THEN p.nnumnif
                     ELSE LPAD(s.cagrpro, 2, '0')
                  END, CASE
                     WHEN ptfdpt = 'T' THEN 0
                     ELSE cramo
                  END, s.sproduc, s.npoliza, s.ncertif;

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_REF_GET_DATOS.f_2_recibos_pendientes', 1,
                     ' pcEmpresa=' || pcempresa || 'pcAgrpro=' || pcagrpro || ' pcRamo='
                     || pcramo || ' psProduc=' || psproduc || ' pcAgente=' || pcagente,
                     SQLERRM);

         CLOSE v_cursor;

         RETURN v_cursor;
   END;

      --  RSC 03/01/2008
   -- Retorna un cursor amb els rebuts pendents d'una pólissa
   --
   --  Paràmetres
   --    psseguro  Obligatori
   --    pcidioma  Obligatori
   --
   FUNCTION f_recibos_impagados(
      psseguro IN seguros.sseguro%TYPE,
      pcidioma IN seguros.cidioma%TYPE)
      RETURN ct_recibos_impagados IS
      v_cursor       ct_recibos_impagados;
   BEGIN
      OPEN v_cursor FOR
         SELECT ROWNUM orden_report, s.cempres, s.cagrpro, cramo, s.sproduc, t.ttitulo,
                s.cagente, s.sseguro, f_formatopol(s.npoliza, s.ncertif, 1) contrato,
                s.fefecto, s.csituac, s.cbancar ccc,
                NVL2(a1.sperson, p1.tnombre || ' ' || p1.tapelli,
                     p2.tnombre || ' ' || p2.tapelli) titular1,
                NVL2(a1.sperson, p1.nnumnif, p2.nnumnif) nif1,
                NVL2(a1.sperson, p2.tnombre || ' ' || p2.tapelli, NULL) titular2,
                NVL2(a2.sperson, p2.nnumnif, NULL) nif2, m.nrecibo, r.fefecto rfefecto,
                v.itotalr, f_recpen_pp(s.sseguro, 2) import_pendent
           FROM movrecibo m, vdetrecibos v, recibos r, seguros s
                LEFT JOIN
                (asegurados a1 JOIN personas p1
                ON(a1.sperson = p1.sperson
                   AND a1.norden = 1
                   AND a1.ffecmue IS NULL))
                ON(s.sseguro = a1.sseguro)
                LEFT JOIN
                (asegurados a2 JOIN personas p2
                ON(a2.sperson = p2.sperson
                   AND a2.norden = 2
                   AND a2.ffecmue IS NULL))
                ON(s.sseguro = a2.sseguro)
                LEFT JOIN titulopro t USING(ctipseg, cramo, cmodali, ccolect)
          WHERE s.sseguro = psseguro
            AND r.sseguro = s.sseguro
            AND m.nrecibo = r.nrecibo
            AND m.nrecibo = v.nrecibo
            AND m.fmovfin IS NULL
            AND m.cestrec = 0
            AND m.cestant <> 0
            AND t.cidioma = pcidioma;

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_REF_GET_INFORMES.f_recibos_impagados', 1,
                     ' psseguro=' || psseguro || 'pcidioma=' || pcidioma, SQLERRM);

         CLOSE v_cursor;

         RETURN v_cursor;
   END;

   --JRH 11/2007 Devuelve los datos de una póliza de HI pdte. de completar.
   FUNCTION f_polizas_bloqu(
      psproduc IN seguros.sproduc%TYPE,
      pcagente IN seguros.cagente%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      ocoderror OUT literales.slitera%TYPE,
      omsgerror OUT literales.tlitera%TYPE)
      RETURN ct_datos_bloq IS
      v_cursor       ct_datos_bloq;
   BEGIN
      ocoderror := NULL;
      omsgerror := NULL;

      OPEN v_cursor FOR
         SELECT s.sseguro psseguro, s.sproduc psproduc, s.fefecto pfefecto,
                a1.norden titular1, p1.sperson sperson_1, p1.nnumnif nnumnif_1,   -- Cod. Identificacion
                LTRIM(p1.tnombre || ' ' || p1.tapelli) nombre1,   -- Titular
                                                               p1.fnacimi fnacim1,
                a1.cdomici domicilio1,
                pac_personas.ff_direccion(1, p1.sperson, a1.cdomici) descdomicilio1,
                p1.cpais pais1,   -- Pais residència
                               pa1.tpais descpais1,   -- Nom del país
                pac_personas.ff_nacionalidad_principal(p1.sperson) nacionalidad1,
                s.cagente cagente
           FROM seguros s JOIN asegurados a1 ON(s.sseguro = a1.sseguro
                                                AND a1.norden = 1)
                JOIN personas p1 ON(a1.sperson = p1.sperson)
                LEFT JOIN despaises pa1 ON(p1.cpais = pa1.cpais)
          WHERE ((s.sproduc = psproduc
                  AND psproduc IS NOT NULL)
                 OR(psproduc IS NULL))
            AND((s.cagente = pcagente
                 AND pcagente IS NOT NULL)
                OR(pcagente IS NULL))
            AND s.csituac = 4;

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         ocoderror := 103212;
         omsgerror := f_axis_literales(ocoderror, pcidioma);
         p_tab_error(f_sysdate, f_user, 'PAC_REF_GET_DATOS.f_poliza_Bloque', 1,
                     'psproduc=' || psproduc || ' pcidioma=' || pcidioma, SQLERRM);

         CLOSE v_cursor;

         RETURN v_cursor;
   END f_polizas_bloqu;

   FUNCTION f_interes_vigentes(
      psproduc IN seguros.sseguro%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      pvtramo IN intertecmovdet.ndesde%TYPE := NULL,
      ocoderror OUT literales.slitera%TYPE,
      omsgerror OUT literales.tlitera%TYPE)
      RETURN ct_interes_vigentes IS
      pfecha         DATE := f_sysdate;
      v_cursor       ct_interes_vigentes;
      pinttecmin     intertecmovdet.ninttec%TYPE;   --       pinttecmin     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   BEGIN
      SELECT ID.ninttec
        INTO pinttecmin
        FROM intertecprod ip, intertecmov im, intertecmovdet ID
       WHERE ip.sproduc = psproduc
         AND ip.ncodint = im.ncodint
         AND im.ctipo = 1
         AND im.finicio <= pfecha
         AND(im.ffin >= pfecha
             OR im.ffin IS NULL)
         AND im.ncodint = ID.ncodint
         AND im.finicio = ID.finicio
         AND im.ctipo = ID.ctipo
         AND(((ID.ndesde <= pvtramo
               AND ID.nhasta >= pvtramo)
              AND(pvtramo IS NOT NULL))
             OR(pvtramo IS NULL));

      OPEN v_cursor FOR
         SELECT   p.sproduc sproduc, t.ttitulo litproducte, pinttecmin porc_int_minimo,
                  ID.ninttec porc_int_garantizado, ID.ndesde tramo
             FROM titulopro t, productos p, intertecprod ip, intertecmov im, intertecmovdet ID
            WHERE p.sproduc = psproduc
              AND t.cramo = p.cramo
              AND t.cmodali = p.cmodali
              AND t.ccolect = p.ccolect
              AND t.ctipseg = p.ctipseg
              AND t.cidioma = pcidioma
              AND ip.sproduc = p.sproduc
              AND ip.ncodint = im.ncodint
              AND im.ctipo = 3
              AND im.finicio <= pfecha
              AND(im.ffin >= pfecha
                  OR im.ffin IS NULL)
              AND im.ncodint = ID.ncodint
              AND im.finicio = ID.finicio
              AND im.ctipo = ID.ctipo
              AND(((ID.ndesde <= pvtramo
                    AND ID.nhasta >= pvtramo)
                   AND(pvtramo IS NOT NULL))
                  OR(pvtramo IS NULL))
         ORDER BY ID.ndesde;

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         ocoderror := 103212;
         omsgerror := f_axis_literales(ocoderror, pcidioma);
         p_tab_error(f_sysdate, f_user, 'PAC_REF_GET_DATOS.f_interes_vigentes', 1,
                     'psproduc=' || psproduc || ' pcidioma=' || pcidioma, SQLERRM);

         CLOSE v_cursor;

         RETURN v_cursor;
   END f_interes_vigentes;

   --JRH 11/2007 Devuelve los datos de una póliza de HI pdte. de completar.
   FUNCTION f_polizas_rvd(
      psproduc IN seguros.sproduc%TYPE,
      pcagente IN seguros.cagente%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      ocoderror OUT literales.slitera%TYPE,
      omsgerror OUT literales.tlitera%TYPE,
      pestado IN NUMBER DEFAULT 0)
      RETURN ct_datos_bloq IS
      v_cursor       ct_datos_bloq;
   BEGIN
      ocoderror := NULL;
      omsgerror := NULL;

      OPEN v_cursor FOR
         SELECT s.sseguro psseguro, s.sproduc psproduc, s.fefecto pfefecto,
                a1.norden titular1, p1.sperson sperson_1, p1.nnumnif nnumnif_1,   -- Cod. Identificacion
                LTRIM(p1.tnombre || ' ' || p1.tapelli) nombre1,   -- Titular
                                                               p1.fnacimi fnacim1,
                a1.cdomici domicilio1,
                pac_personas.ff_direccion(1, p1.sperson, a1.cdomici) descdomicilio1,
                p1.cpais pais1,   -- Pais residència
                               pa1.tpais descpais1,   -- Nom del país
                pac_personas.ff_nacionalidad_principal(p1.sperson) nacionalidad1,
                s.cagente cagente
           FROM seguros s JOIN asegurados a1 ON(s.sseguro = a1.sseguro
                                                AND a1.norden = 1)
                JOIN personas p1 ON(a1.sperson = p1.sperson)
                LEFT JOIN despaises pa1 ON(p1.cpais = pa1.cpais)
          WHERE ((s.sproduc = psproduc
                  AND psproduc IS NOT NULL)
                 OR(psproduc IS NULL))
            AND((s.cagente = pcagente
                 AND pcagente IS NOT NULL)
                OR(pcagente IS NULL))
            AND NVL(s.csituac, 0) = pestado
            AND NOT EXISTS(SELECT 1
                             FROM seguros_ren ren
                            WHERE ren.sseguro = s.sseguro);

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         ocoderror := 103212;
         omsgerror := f_axis_literales(ocoderror, pcidioma);
         p_tab_error(f_sysdate, f_user, 'PAC_REF_GET_DATOS.f_poliza_Bloque', 1,
                     'psproduc=' || psproduc || ' pcidioma=' || pcidioma, SQLERRM);

         CLOSE v_cursor;

         RETURN v_cursor;
   END f_polizas_rvd;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_REF_GET_INFORMES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REF_GET_INFORMES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REF_GET_INFORMES" TO "PROGRAMADORESCSI";
