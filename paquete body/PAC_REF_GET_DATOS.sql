--------------------------------------------------------
--  DDL for Package Body PAC_REF_GET_DATOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_REF_GET_DATOS" AS
/****************************************************************************

   NOM:       pac_ref_get_datos
   PROPÒSIT:

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   1.0        23/11/2010   SRA              1.0016790 - CRT - Modificació package per 11gR2: se substituye el uso
                                            de JOIN...USING por JOIN...ON en la unión de tablas para adaptar el código a la versión de bbdd 11gR2
   1.1.       29/11/2011   NMM              1.1. Canvis per la versió 11g. d' Oracle
****************************************************************************/
   FUNCTION f_datos_titulares(
      psseguro IN seguros.sseguro%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      ocoderror OUT literales.slitera%TYPE,
      omsgerror OUT literales.tlitera%TYPE)
      RETURN ct_datos_titulares IS
      v_cursor       ct_datos_titulares;
      v_texto        VARCHAR2(2000);
      v_error        literales.slitera%TYPE;
      v_traza        tab_error.ntraza%TYPE := 1;
      v_date         DATE := f_sysdate;
   BEGIN
      ocoderror := NULL;
      omsgerror := NULL;

      OPEN v_cursor FOR
--         WITH x AS
         SELECT   titular, cod_ident, cod_nacionalidad, pn.tpais nacionalidad, cod_residencia,
                  residencia, nombre, apellido1, apellido2, cod_sexo, sexo, fnacimiento,
                  domicilio, poblacion, cpostal
             FROM (SELECT a.norden titular, p.nnumnif cod_ident, pr.cpais cod_residencia,
                          pr.tpais residencia, p.csexper cod_sexo, d.tatribu sexo,
                          p.fnacimi fnacimiento, p.tnombre nombre, p.tapelli1 apellido1,
                          p.tapelli2 apellido2,
                          pac_personas.ff_nacionalidad_principal(a.sperson) cod_nacionalidad,
                          d.tdomici domicilio, po.tpoblac poblacion, d.cpostal cpostal
                     FROM asegurados a JOIN personas p ON(a.sperson = p.sperson)
                          LEFT JOIN direcciones d
                          ON(d.sperson = a.sperson
                             AND d.cdomici = a.cdomici)
                          LEFT JOIN poblaciones po
                          ON(po.cpoblac = d.cpoblac
                             AND po.cprovin = d.cprovin)
                          LEFT JOIN despaises pr ON(p.cpais = pr.cpais)
                          LEFT JOIN detvalores d
                          ON(d.cvalor = 11
                             AND d.cidioma = pcidioma
                             AND p.csexper = d.catribu)
                    WHERE a.sseguro = psseguro) x
                  LEFT JOIN
                  despaises pn ON(x.cod_nacionalidad = pn.cpais)
         ORDER BY titular;

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         ocoderror := 103212;
         omsgerror := f_axis_literales(ocoderror, pcidioma);
         p_tab_error(f_sysdate, f_user, 'PAC_REF_GET_DATOS.f_Datos_Titulares', v_traza,
                     'psseguro=' || psseguro || ' pcidioma=' || pcidioma, SQLERRM);

         CLOSE v_cursor;

         RETURN v_cursor;
   END f_datos_titulares;

   FUNCTION f_datos_gestion(
      psseguro IN seguros.sseguro%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      ocoderror OUT literales.slitera%TYPE,
      omsgerror OUT literales.tlitera%TYPE)
      RETURN ct_datos_gestion IS
      v_cursor       ct_datos_gestion;
      v_texto        VARCHAR2(2000);
      v_error        literales.slitera%TYPE;
      v_traza        tab_error.ntraza%TYPE := 1;
      v_date         DATE := f_sysdate;
   BEGIN
      ocoderror := NULL;
      omsgerror := NULL;

      OPEN v_cursor FOR
         SELECT s.npoliza, s.ncertif, s.cidioma, i.tidioma idioma,
                s.cagente cod_oficina_gestion,
                o.tapelli || NVL2(o.tnombre, ' ,' || o.tnombre, NULL) oficina_gestion,
                s.fefecto, sa.frevisio frenovacion, s.cbancar ccc, ms.fmovimi falta,
                s.fanulac fanulacion, s.cforpag cod_forma_pago, dv.tatribu forma_pago,
                r.cforpag cod_forma_pago_renta, dv1.tatribu forma_pago_renta
           FROM seguros s LEFT JOIN seguros_aho sa ON(sa.sseguro = s.sseguro)
                LEFT JOIN idiomas i
                ON(i.cidioma = s.cidioma)   -- Idioma 0 significa idioma del titular
                -- Ini Bug 16790 - SRA - 23/11/2010
                JOIN agentes a ON s.cagente = a.cagente
                JOIN personas o ON a.sperson = o.sperson
                -- Fin Bug 16790 - SRA - 23/11/2010
                JOIN movseguro ms ON(ms.sseguro = s.sseguro)
                JOIN detvalores dv
                ON(s.cforpag = dv.catribu
                   AND dv.cidioma = pcidioma
                   AND dv.cvalor = 17)
                LEFT JOIN seguros_ren r ON(r.sseguro = s.sseguro)
                LEFT JOIN detvalores dv1
                ON(r.cforpag = dv1.catribu
                   AND dv1.cidioma = pcidioma
                   AND dv1.cvalor = 17)
          WHERE s.sseguro = psseguro
            AND nmovimi = 1;

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         ocoderror := 103212;
         omsgerror := f_axis_literales(ocoderror, pcidioma);
         p_tab_error(f_sysdate, f_user, 'PAC_REF_GET_DATOS.f_Datos_Gestion', v_traza,
                     'psseguro=' || psseguro || ' pcidioma=' || pcidioma, SQLERRM);

         CLOSE v_cursor;

         RETURN v_cursor;
   END f_datos_gestion;

   FUNCTION f_datos_primas(
      psseguro IN seguros.sseguro%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      ocoderror OUT literales.slitera%TYPE,
      omsgerror OUT literales.tlitera%TYPE)
      RETURN ct_datos_primas IS
      v_cursor       ct_datos_primas;
      v_texto        VARCHAR2(2000);
      v_error        literales.slitera%TYPE;
      v_traza        tab_error.ntraza%TYPE := 1;
      v_date         DATE := f_sysdate;
      v_garant_final_periodo NUMBER;
      v_garant_vencimiento NUMBER;
      v_valor_provision NUMBER;
      v_fallecimiento NUMBER;
      xcactivi       NUMBER;
      xfefecto       DATE;
      v_sproduc      NUMBER;
   BEGIN
      ocoderror := NULL;
      omsgerror := NULL;

      BEGIN
         SELECT sproduc, cactivi, fefecto
           INTO v_sproduc, xcactivi, xfefecto
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN v_cursor;
      END;

      IF (NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
          AND NVL(f_parproductos_v(v_sproduc, 'PRODUCTO_MIXTO'), 0) <> 1) THEN   -- Unit Linked (excepto Ibex 35 Garantizado)
         BEGIN
            -- Posat dins el bucle, perquè si psSeguro no existís no cridi les funcions
            v_valor_provision := pac_provmat_formul.f_calcul_formulas_provi(psseguro,
                                                                            f_sysdate,
                                                                            'IPROVAC');
            v_fallecimiento := pac_provmat_formul.f_calcul_formulas_provi(psseguro, f_sysdate,
                                                                          'ICFALLAC');
            v_garant_vencimiento := pac_provmat_formul.f_calcul_formulas_provi(psseguro,
                                                                               f_sysdate,
                                                                               'ICGARAC');

            OPEN v_cursor FOR
               SELECT pac_calc_comu.ff_prima_inicial(psseguro, s.cforpag,
                                                     1) aportacion_inicial,
                      CASE s.cforpag
                         WHEN 0 THEN 0
                         ELSE pac_calc_aho.ff_get_aportacion_per
                                                               ('SEG',
                                                                psseguro,
                                                                v_date)
                      END aportacion_periodica,
                      CASE crevali
                         WHEN 1 THEN NVL(irevali, 0)
                         ELSE NVL(prevali, 0)
                      END porc_revalorizacion,
                      pac_inttec.ff_int_seguro('SEG', psseguro, v_date) porc_interes_tecnico,
                      v_valor_provision valor_provision,
                      v_garant_vencimiento garant_final_periodo,
                      v_garant_vencimiento garant_vencimiento, v_fallecimiento fallecimiento,
                      xfefecto falta, f_sysdate fcalculo, 0 rentabrutamens
                 FROM seguros s
                WHERE sseguro = psseguro;
         END;
      ELSIF(NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1) THEN
         DECLARE
            xcramo         NUMBER;
            xcmodali       NUMBER;
            xctipseg       NUMBER;
            xccolect       NUMBER;
            xclave         NUMBER;
            xcgarant       NUMBER;
            v_ctipgar      NUMBER;
            e              NUMBER;
            val            NUMBER;
         BEGIN
            FOR r IN (SELECT sa.frevisio, s.fvencim
                        FROM seguros s LEFT JOIN seguros_aho sa ON(sa.sseguro = s.sseguro)
                       WHERE s.sseguro = psseguro) LOOP
               -- Calculs aquí perquè la funció PAC_PROVMAT_FORMUL.F_CALCUL_FORMULAS_PROVI no pot ser
               -- cridada des del SELECT perquè fa INSERTs
               v_garant_final_periodo :=
                  pac_provmat_formul.f_calcul_formulas_provi(psseguro, r.frevisio - 1,
                                                             'IPROVAC');
               v_garant_vencimiento := pac_provmat_formul.f_calcul_formulas_provi(psseguro,
                                                                                  f_sysdate,
                                                                                  'ICGARAC');
               -- Posat dins el bucle, perquè si psSeguro no existís no cridi les funcions
               v_fallecimiento := pac_provmat_formul.f_calcul_formulas_provi(psseguro,
                                                                             f_sysdate,
                                                                             'ICFALLAC');
               v_valor_provision := pac_provmat_formul.f_calcul_formulas_provi(psseguro,
                                                                               f_sysdate,
                                                                               'IPROVAC');
               /*xcgarant := pac_calc_comu.f_cod_garantia(v_sproduc, 8, NULL,v_ctipgar); --garantia asociada a rentas
                    if xcgarant is null then
                           ocoderror := 153052;
                        omsgerror := F_AXIS_LITERALES (ocoderror, pcidioma);
                           RETURN v_cursor;
                    end if;


               SELECT CRAMO, CMODALI, CTIPSEG, CCOLECT
                     INTO xcramo, xcmodali, xctipseg, xccolect
                     FROM PRODUCTOS
                     WHERE sproduc = v_sproduc;

               select clave --Buscamos la fórmula para el cálculo de la renta
                    into xclave
                    from garanformula
                    where
                    cramo=xcramo
                    and ccampo='ICAPCAL'
                    and cmodali = xcmodali
                    and ctipseg = xctipseg
                    and ccolect = xccolect
                    and cactivi = xcactivi
                    and cgarant = xcgarant;*/
               val := pk_rentas.f_buscarentabruta(1, psseguro, TO_CHAR(f_sysdate, 'yyyymmdd'),
                                                  2);

               --e:=Pac_Calculo_Formulas.CALC_FORMUL ( F_SYSDATE, v_sproduc, xcactivi, NULL, 1, Psseguro, xclave, val, NULL, NULL, 2, r.frevisio, 'R' );
               IF val IS NULL THEN
                  ocoderror := 151836;
                  omsgerror := f_axis_literales(ocoderror, pcidioma);
                  RETURN v_cursor;
               END IF;
            END LOOP;

            v_traza := 2;

            OPEN v_cursor FOR
               SELECT pac_calc_comu.ff_prima_inicial(psseguro, s.cforpag,
                                                     1) aportacion_inicial,
                      CASE s.cforpag
                         WHEN 0 THEN 0
                         ELSE pac_calc_aho.ff_get_aportacion_per
                                                               ('SEG',
                                                                psseguro,
                                                                v_date)
                      END aportacion_periodica,
                      CASE crevali
                         WHEN 1 THEN NVL(irevali, 0)
                         ELSE NVL(prevali, 0)
                      END porc_revalorizacion,
                      pac_inttec.ff_int_seguro('SEG', psseguro, v_date) porc_interes_tecnico,
                      v_valor_provision valor_provision,
                      v_garant_final_periodo garant_final_periodo,
                      v_garant_vencimiento garant_vencimiento, v_fallecimiento fallecimiento,
                      xfefecto falta, f_sysdate fcalculo, val rentabrutamens
                 FROM seguros s
                WHERE s.sseguro = psseguro;
         END;
      ELSE
         BEGIN
            FOR r IN (SELECT pp.cvalpar, sa.frevisio, s.fvencim
                        -- Ini Bug 16790 - SRA - 02/02/2011
                      FROM   seguros s JOIN seguros_aho sa ON s.sseguro = sa.sseguro
                             LEFT JOIN parproductos pp
                             ON(s.sproduc = pp.sproduc
                                AND pp.cparpro = 'EVOLUPROVMATSEG')
                       WHERE s.sseguro = psseguro) LOOP
                      -- Fin Bug 16790 - SRA - 02/02/2011
               -- Calculs aquí perquè la funció PAC_PROVMAT_FORMUL.F_CALCUL_FORMULAS_PROVI no pot ser
               -- cridada des del SELECT perquè fa INSERTs
               IF r.cvalpar = 1 THEN
                  v_garant_final_periodo :=
                     pac_provmat_formul.f_calcul_formulas_provi(psseguro, f_sysdate,
                                                                'ICGARAC');
                  v_garant_vencimiento :=
                     pac_provmat_formul.f_calcul_formulas_provi(psseguro, r.fvencim,
                                                                'IPROVAC');
               ELSE
                  v_garant_final_periodo :=
                     pac_provmat_formul.f_calcul_formulas_provi(psseguro, r.frevisio - 1,
                                                                'IPROVAC');
                  v_garant_vencimiento :=
                     pac_provmat_formul.f_calcul_formulas_provi(psseguro, f_sysdate,
                                                                'ICGARAC');
               END IF;

               -- Posat dins el bucle, perquè si psSeguro no existís no cridi les funcions
               v_fallecimiento := pac_provmat_formul.f_calcul_formulas_provi(psseguro,
                                                                             f_sysdate,
                                                                             'ICFALLAC');
               v_valor_provision := pac_provmat_formul.f_calcul_formulas_provi(psseguro,
                                                                               f_sysdate,
                                                                               'IPROVAC');
            END LOOP;

            v_traza := 2;

            OPEN v_cursor FOR
               SELECT pac_calc_comu.ff_prima_inicial(psseguro, s.cforpag,
                                                     1) aportacion_inicial,
                      CASE s.cforpag
                         WHEN 0 THEN 0
                         ELSE pac_calc_aho.ff_get_aportacion_per
                                                               ('SEG',
                                                                psseguro,
                                                                v_date)
                      END aportacion_periodica,
                      CASE crevali
                         WHEN 1 THEN NVL(irevali, 0)
                         ELSE NVL(prevali, 0)
                      END porc_revalorizacion,
                      pac_inttec.ff_int_seguro('SEG', psseguro, v_date) porc_interes_tecnico,
                      v_valor_provision valor_provision,
                      v_garant_final_periodo garant_final_periodo,
                      v_garant_vencimiento garant_vencimiento, v_fallecimiento fallecimiento,
                      xfefecto falta, f_sysdate fcalculo, 0 rentabrutamens
                 FROM seguros s LEFT JOIN parproductos pp
                      ON(s.sproduc = pp.sproduc
                         AND pp.cparpro = 'EVOLUPROVMATSEG')
                WHERE sseguro = psseguro;
         END;
      END IF;

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         ocoderror := 103212;
         omsgerror := f_axis_literales(ocoderror, pcidioma);
         p_tab_error(f_sysdate, f_user, 'PAC_REF_GET_DATOS.f_Datos_Primas', v_traza,
                     'psseguro=' || psseguro || ' pcidioma=' || pcidioma, SQLERRM);

         CLOSE v_cursor;

         RETURN v_cursor;
   END f_datos_primas;

   FUNCTION f_datos_beneficiarios(
      psseguro IN seguros.sseguro%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      ocoderror OUT literales.slitera%TYPE,
      omsgerror OUT literales.tlitera%TYPE)
      RETURN ct_datos_beneficiarios IS
      v_cursor       ct_datos_beneficiarios;
      v_texto        VARCHAR2(2000);
      v_error        literales.slitera%TYPE;
      v_traza        tab_error.ntraza%TYPE := 1;
      v_date         DATE := f_sysdate;
   BEGIN
      ocoderror := NULL;
      omsgerror := NULL;

      OPEN v_cursor FOR
         -- Agafem de claubenseg si no existeix a clausuesp
         SELECT NVL((SELECT tclaesp
                       FROM clausuesp
                      WHERE ffinclau IS NULL
                        AND nriesgo = (SELECT MIN(riesgos.nriesgo)
                                         FROM riesgos
                                        WHERE riesgos.sseguro = clausuesp.sseguro
                                          AND riesgos.fanulac IS NULL)
                        AND sseguro = psseguro
                        AND cclaesp = 1),
                    (SELECT tclaben
                       FROM claubenseg, clausuben
                      WHERE claubenseg.sseguro = psseguro
                        AND clausuben.sclaben = claubenseg.sclaben
                        AND cidioma = pcidioma
                        AND ffinclau IS NULL
                        AND nriesgo = (SELECT MIN(riesgos.nriesgo)
                                         FROM riesgos
                                        WHERE riesgos.sseguro = claubenseg.sseguro
                                          AND riesgos.fanulac IS NULL))) beneficiaris
           FROM DUAL;

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         ocoderror := 103212;
         omsgerror := f_axis_literales(ocoderror, pcidioma);
         p_tab_error(f_sysdate, f_user, 'PAC_REF_GET_DATOS.f_Datos_Beneficiarios', v_traza,
                     'psseguro=' || psseguro || ' pcidioma=' || pcidioma, SQLERRM);

         CLOSE v_cursor;

         RETURN v_cursor;
   END f_datos_beneficiarios;

   FUNCTION f_datos_cumulos(
      psseguro IN seguros.sseguro%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      ocoderror OUT literales.slitera%TYPE,
      omsgerror OUT literales.tlitera%TYPE)
      RETURN ct_datos_cumulos IS
      v_cursor       ct_datos_cumulos;
      v_texto        VARCHAR2(2000);
      v_error        literales.slitera%TYPE;
      v_traza        tab_error.ntraza%TYPE := 1;
      v_date         DATE := f_sysdate;
   BEGIN
      ocoderror := NULL;
      omsgerror := NULL;
      v_error := pac_tfv.f_cumulos_pp(psseguro, v_texto);

      OPEN v_cursor FOR
         SELECT   SUBSTR(s, 1, c1 - 1) desctipo,
                  TO_NUMBER(SUBSTR(s, c1 + 1, c2 - c1 - 1)) numseg,
                  TO_NUMBER(SUBSTR(s, c2 + 1, c3 - c2 - 1), 'FM999G999G990D00') anual,
                  TO_NUMBER(SUBSTR(s, c3 + 1), 'FM999G999G990D00') importe
             FROM (
                   -- Obtenim on són els separadors dels camps
                   SELECT x, s, INSTR(s, ';', 1, 1) c1, INSTR(s, ';', 1, 2) c2,
                          INSTR(s, ';', 1, 3) c3
                     FROM (
                           -- Obtenim les linies amb els camps separats per punt i coma
                           SELECT x, SUBSTR(y, i + 1, f - i - 1) s
                             FROM (SELECT x, y, INSTR(y, '|', 1, x) i,
                                          INSTR(y, '|', 1, x + 1) f
                                     FROM (
                                           -- Convertim la linea en registres utilitzant el separador | que ha d'estar també al final
                                           SELECT fila x, '|' || v_texto y
                                             FROM numero
                                            WHERE fila BETWEEN 1
                                                           AND LENGTH(v_texto)
                                                               - LENGTH(REPLACE(v_texto, '|'))))))
         ORDER BY x;

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         ocoderror := 103212;
         omsgerror := f_axis_literales(ocoderror, pcidioma);
         p_tab_error(f_sysdate, f_user, 'PAC_REF_GET_DATOS.f_Datos_Cumulos', v_traza,
                     'psseguro=' || psseguro || ' pcidioma=' || pcidioma, SQLERRM);

         CLOSE v_cursor;

         RETURN v_cursor;
   END f_datos_cumulos;

   FUNCTION f_datos_operaciones(
      psseguro IN seguros.sseguro%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      ocoderror OUT literales.slitera%TYPE,
      omsgerror OUT literales.tlitera%TYPE)
      RETURN ct_datos_operaciones IS
      v_cursor       ct_datos_operaciones;
      v_texto        VARCHAR2(2000);
      v_error        literales.slitera%TYPE;
      v_traza        tab_error.ntraza%TYPE := 1;
      v_date         DATE := f_sysdate;
   BEGIN
      ocoderror := NULL;
      omsgerror := NULL;

      OPEN v_cursor FOR
         SELECT   ROWNUM linea, x.fcontab fefecto, x.fvalmov fvalor, dv.tatribu operacion,
                  x.cmovanu cod_anulado,
                  CASE x.cmovanu
                     WHEN 1 THEN f_axis_literales(103638, pcidioma)
                     ELSE f_axis_literales(103639, pcidioma)
                  END anulado,
                  x.imovimi importe, DECODE(x.sreimpre, NULL, 'N', 'S')
             FROM detvalores dv
                  RIGHT JOIN
                  (SELECT c.nnumlin, c.cmovimi,
                          CASE
                             WHEN c.cmovimi <= 9 THEN c.imovimi
                             ELSE -c.imovimi
                          END imovimi, c.fcontab, c.fvalmov, c.cmovanu, cl.sreimpre
                     FROM seguros s, ctaseguro c, ctaseguro_libreta cl
                    WHERE s.sseguro = psseguro
                      AND c.sseguro = s.sseguro
                      AND cl.sseguro = c.sseguro
                      AND TRUNC(cl.fcontab) = TRUNC(c.fcontab)
                      AND cl.nnumlin = c.nnumlin) x
                  ON(dv.cvalor = 83
                     AND dv.cidioma = pcidioma
                     AND dv.catribu = x.cmovimi)
         ORDER BY nnumlin DESC;

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         ocoderror := 103212;
         omsgerror := f_axis_literales(ocoderror, pcidioma);
         p_tab_error(f_sysdate, f_user, 'PAC_REF_GET_DATOS.f_Datos_Operaciones', v_traza,
                     'psseguro=' || psseguro || ' pcidioma=' || pcidioma, SQLERRM);

         CLOSE v_cursor;

         RETURN v_cursor;
   END f_datos_operaciones;

   FUNCTION f_datos_evolucion(
      psseguro IN seguros.sseguro%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      ocoderror OUT literales.slitera%TYPE,
      omsgerror OUT literales.tlitera%TYPE)
      RETURN ct_datos_evolucion IS
      v_cursor       ct_datos_evolucion;
   BEGIN
      OPEN v_cursor FOR
         SELECT   nanyo + 1, iprovmat, prescate, icapfall
             FROM evoluprovmatseg
            WHERE sseguro = psseguro
              AND nmovimi = (SELECT MAX(nmovimi)
                               FROM evoluprovmatseg
                              WHERE sseguro = psseguro)
         ORDER BY 1 ASC;

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         ocoderror := 103212;
         omsgerror := f_axis_literales(ocoderror, pcidioma);
         p_tab_error(f_sysdate, f_user, 'PAC_REF_GET_DATOS.f_Datos_evolucion', 1,
                     'psseguro=' || psseguro || ' pcidioma=' || pcidioma, SQLERRM);

         CLOSE v_cursor;

         RETURN v_cursor;
   END f_datos_evolucion;

   --JRH 11/2007 Devuelve los datos de una póliza de HI pdte. de completar.
   FUNCTION f_datos_poliza_hi(
      psseguro IN seguros.sseguro%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      ocoderror OUT literales.slitera%TYPE,
      omsgerror OUT literales.tlitera%TYPE)
      RETURN ct_datos_poliza_hi IS
      v_cursor       ct_datos_poliza_hi;
      v_garant_vencimiento NUMBER;
      v_garant_final_periodo NUMBER;
      v_fallecimiento NUMBER;
      v_valor_provision NUMBER;
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
                a2.norden titular2, p2.sperson sperson_2, p2.nnumnif nnumnif_2,   -- Cod. Identificacion
                LTRIM(p2.tnombre || ' ' || p2.tapelli) nombre2,   -- Titular
                                                               p2.fnacimi fnacim2,
                a2.cdomici domicilio2,
                pac_personas.ff_direccion(1, p2.sperson, a2.cdomici) descdomicilio2,
                p2.cpais pais2,   -- Pais residència
                               pa2.tpais descpais2,   -- Nom del país
                pac_personas.ff_nacionalidad_principal(p2.sperson) nacionalidad2,
                s.cagente cagente, s.cidioma cidioma, s.cforpag cforpag, s.cbancar cbancar,
                (SELECT MAX(preg.crespue)
                   FROM pregunseg preg
                  WHERE preg.sseguro = s.sseguro
                    AND preg.nriesgo = 1
                    AND preg.nmovimi = 1
                    AND preg.cpregun = 100) tasinmuebhi,   --Los max es para que no devuelva el NDF
                (SELECT MAX(preg.crespue)
                   FROM pregunseg preg
                  WHERE preg.sseguro = s.sseguro
                    AND preg.nriesgo = 1
                    AND preg.nmovimi = 1
                    AND preg.cpregun = 101) pcttasinmuebhi,
                (SELECT MAX(preg.crespue)
                   FROM pregunseg preg
                  WHERE preg.sseguro = s.sseguro
                    AND preg.nriesgo = 1
                    AND preg.nmovimi = 1
                    AND preg.cpregun = 102) capitaldisphi,
                (SELECT MAX(TO_DATE(LPAD(preg.crespue, 8, 0), 'dd/mm/yyyy'))
                   FROM pregunseg preg
                  WHERE preg.sseguro = s.sseguro
                    AND preg.nriesgo = 1
                    AND preg.nmovimi = 1
                    AND preg.cpregun = 103) fecoperhi,
                (SELECT MAX(preg.trespue)
                   FROM pregunseg preg
                  WHERE preg.sseguro = s.sseguro
                    AND preg.nriesgo = 1
                    AND preg.nmovimi = 1
                    AND preg.cpregun = 104) cccrhi
           FROM seguros s JOIN asegurados a1 ON(s.sseguro = a1.sseguro
                                                AND a1.norden = 1)
                JOIN personas p1 ON(a1.sperson = p1.sperson)
                LEFT JOIN despaises pa1 ON(p1.cpais = pa1.cpais)
                LEFT JOIN asegurados a2 ON(s.sseguro = a2.sseguro
                                           AND a2.norden = 2)
                LEFT JOIN personas p2 ON(a2.sperson = p2.sperson)
                LEFT JOIN despaises pa2 ON(p2.cpais = pa2.cpais)
          WHERE s.sseguro = psseguro
            AND s.csituac = 4;

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         ocoderror := 103212;
         omsgerror := f_axis_literales(ocoderror, pcidioma);
         p_tab_error(f_sysdate, f_user, 'PAC_REF_GET_DATOS.f_Datos_Operaciones', 1,
                     'psseguro=' || psseguro || ' pcidioma=' || pcidioma, SQLERRM);

         CLOSE v_cursor;

         RETURN v_cursor;
   END f_datos_poliza_hi;

   --JRH 11/2007 Devuelve los datos de una póliza
   FUNCTION f_datos_poliza(
      psseguro IN seguros.sseguro%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      ocoderror OUT literales.slitera%TYPE,
      omsgerror OUT literales.tlitera%TYPE)
      RETURN ct_datos_poliza IS
      v_cursor       ct_datos_poliza;
      v_garant_vencimiento NUMBER;
      v_garant_final_periodo NUMBER;
      v_fallecimiento NUMBER;
      v_valor_provision NUMBER;
   BEGIN
      ocoderror := NULL;
      omsgerror := NULL;

      FOR r IN (SELECT pp.cvalpar, sa.frevisio, s.fvencim
                  -- Ini bug 16790 - SRA - 02/02/2011
                FROM   seguros s JOIN seguros_aho sa ON s.sseguro = sa.sseguro
                       LEFT JOIN parproductos pp
                       ON(s.sproduc = pp.sproduc
                          AND pp.cparpro = 'EVOLUPROVMATSEG')
                 WHERE s.sseguro = psseguro) LOOP
              -- Fin bug 16790 - SRA - 02/02/2011
         -- Calculs aquí perquè la funció PAC_PROVMAT_FORMUL.F_CALCUL_FORMULAS_PROVI no pot ser
         -- cridada des del SELECT perquè fa INSERTs
         IF r.cvalpar = 1 THEN
            v_garant_final_periodo := pac_provmat_formul.f_calcul_formulas_provi(psseguro,
                                                                                 f_sysdate,
                                                                                 'ICGARAC');
            v_garant_vencimiento := pac_provmat_formul.f_calcul_formulas_provi(psseguro,
                                                                               r.fvencim,
                                                                               'IPROVAC');
         ELSE
            v_garant_final_periodo :=
               pac_provmat_formul.f_calcul_formulas_provi(psseguro, r.frevisio - 1, 'IPROVAC');
            v_garant_vencimiento := pac_provmat_formul.f_calcul_formulas_provi(psseguro,
                                                                               f_sysdate,
                                                                               'ICGARAC');
         END IF;

         -- Posat dins el bucle, perquè si psSeguro no existís no cridi les funcions
         v_fallecimiento := pac_provmat_formul.f_calcul_formulas_provi(psseguro, f_sysdate,
                                                                       'ICFALLAC');
         v_valor_provision := pac_provmat_formul.f_calcul_formulas_provi(psseguro, f_sysdate,
                                                                         'IPROVAC');
      END LOOP;

      OPEN v_cursor FOR
         SELECT s.sseguro psseguro, s.sproduc psproduc, s.fefecto pfefecto, a1.norden titular1,
                p1.sperson sperson_1, p1.nnumnif nnumnif_1,   -- Cod. Identificacion
                LTRIM(p1.tnombre || ' ' || p1.tapelli) nombre1,   -- Titular
                                                               p1.fnacimi fnacim1,
                a1.cdomici domicilio1,
                pac_personas.ff_direccion(1, p1.sperson, a1.cdomici) descdomicilio1,
                p1.cpais pais1,   -- Pais residència
                               pa1.tpais descpais1,   -- Nom del país
                pac_personas.ff_nacionalidad_principal(p1.sperson) nacionalidad1,
                a2.norden titular2, p2.sperson sperson_2, p2.nnumnif nnumnif_2,   -- Cod. Identificacion
                LTRIM(p2.tnombre || ' ' || p2.tapelli) nombre2,   -- Titular
                                                               p2.fnacimi fnacim2,
                a2.cdomici domicilio2,
                pac_personas.ff_direccion(1, p2.sperson, a2.cdomici) descdomicilio2,
                p2.cpais pais2,   -- Pais residència
                               pa2.tpais descpais2,   -- Nom del país
                pac_personas.ff_nacionalidad_principal(p2.sperson) nacionalidad2,
                s.cagente cagente, s.cidioma cidioma, s.cforpag cforpag, s.cbancar cbancar,
                v_garant_vencimiento capgarvto, v_valor_provision valorprov,
                v_fallecimiento capfallec
           FROM seguros s JOIN asegurados a1 ON(s.sseguro = a1.sseguro
                                                AND a1.norden = 1)
                JOIN personas p1 ON(a1.sperson = p1.sperson)
                LEFT JOIN despaises pa1 ON(p1.cpais = pa1.cpais)
                LEFT JOIN asegurados a2 ON(s.sseguro = a2.sseguro
                                           AND a2.norden = 2)
                LEFT JOIN personas p2 ON(a2.sperson = p2.sperson)
                LEFT JOIN despaises pa2 ON(p2.cpais = pa2.cpais)
          WHERE s.sseguro = psseguro;

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         ocoderror := 103212;
         omsgerror := f_axis_literales(ocoderror, pcidioma);
         p_tab_error(f_sysdate, f_user, 'PAC_REF_GET_DATOS.f_Datos_Operaciones', 1,
                     'psseguro=' || psseguro || ' pcidioma=' || pcidioma, SQLERRM);

         CLOSE v_cursor;

         RETURN v_cursor;
   END f_datos_poliza;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_REF_GET_DATOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REF_GET_DATOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REF_GET_DATOS" TO "PROGRAMADORESCSI";
