--------------------------------------------------------
--  DDL for Package Body IMPRESION_LIBRETA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."IMPRESION_LIBRETA" AS
/******************************************************************************
   NOMBRE:     IMPRESION_LIBRETA
   PROPÓSITO:

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        10/07/2009   DCT                1. 0010612: CRE - Error en la generació de pagaments automàtics.
                                              Canviar vista personas por tablas personas y añadir filtro de visión de agente
   2.0        23/11/2010   SRA                1.0016790 - CRT - Modificació package per 11gR2: se substituye el uso
                                              de JOIN...USING por JOIN...ON en la unión de tablas para adaptar el código a la versión de bbdd 11gR2
   3.0        17/10/2011   JMP                3. 0019027: LCOL760 - Tamany del camp CRAMO
   4.0        23/10/2013   HRE                4. Bug 0028462: HRE - Cambio dimension campo sseguro
******************************************************************************/
   exerror        EXCEPTION;

   TYPE rt_detall IS RECORD(
      linia          detimplibreta.nnumlin%TYPE,
      columna        detimplibreta.nposcol%TYPE,
      text           detimplibreta.texto%TYPE
   );

   TYPE tt_detall IS TABLE OF rt_detall
      INDEX BY PLS_INTEGER;

   g_cidioma      personas.cidioma%TYPE;

   -- Variables per tornar a omplir les dades temporals quan es crida Visualizar
   TYPE tt_sesionseguro IS TABLE OF NUMBER
      INDEX BY VARCHAR2(40);   -- Bug 28462 - 07/10/2013 - HRE - Cambio de dimension SSEGURO

   g_sesionseguro tt_sesionseguro;

   -- Tipus a utilitzar pels beneficiaris dividir-los entre diverses línies
   TYPE tt_lineas IS TABLE OF VARCHAR2(80)
      INDEX BY PLS_INTEGER;

   -- Tipus diccionari
   TYPE rt_diccionari IS RECORD(
      paraula        VARCHAR2(80),
      valor          VARCHAR2(80)
   );

   TYPE tt_diccionari IS TABLE OF rt_diccionari
      INDEX BY PLS_INTEGER;

   --
   --  Funcions privades
   --

   -- Constructor per RT_DICCIONARI
   FUNCTION diccionari(pparaula IN VARCHAR2, pvalor IN VARCHAR2)
      RETURN rt_diccionari IS
      v              rt_diccionari;
   BEGIN
      v.paraula := pparaula;
      v.valor := pvalor;
      RETURN v;
   END;

   -- Traductos CMOVIMI --> CONCEPTO
   FUNCTION diccionaricmovimis(pparaula IN VARCHAR2, pcmovimi IN NUMBER)
      RETURN rt_diccionari IS
      v              rt_diccionari;
      pvalor         VARCHAR2(30);
   BEGIN
      v.paraula := pparaula;

      CASE
         WHEN pcmovimi IN(1, 2, 4) THEN
            pvalor := 'APORTACION';
         WHEN pcmovimi IN(0, 70) THEN
            pvalor := 'SALDO SEGU';
         WHEN pcmovimi = 51 THEN
            pvalor := 'ANULA APOR';
         WHEN pcmovimi = 82 THEN
            pvalor := 'GASTOS GES';
         WHEN pcmovimi = 21 THEN
            pvalor := 'SEG.COBERT';
         WHEN pcmovimi = 80 THEN
            pvalor := 'GASTOS RED';
         ELSE
            pvalor := LPAD(' ', 10);
      END CASE;

      v.valor := pvalor;
      RETURN v;
   END;

   -- Constructor per RT_DETALL
   FUNCTION detall(
      p_id detimplibreta.nnumlin%TYPE,
      p_columna detimplibreta.nposcol%TYPE,
      p_text detimplibreta.texto%TYPE)
      RETURN rt_detall IS
      v              rt_detall;
   BEGIN
      -- Columna sempre ha de ser 1, per tant posem tants espais com calen al Text
      v.linia := p_id;
      v.columna := 1;
      v.text := LPAD(' ', p_columna - 1) || p_text;
      RETURN v;
   END;

   --
   --    f_parlibretatextdet        (Funció privada)
   --        Torna totes les linies d'un paràmetre com a TT_LINEAS
   --
   FUNCTION f_parlibretatextdet(
      ptipolinea IN parlibretatextdet.tipolinea%TYPE,
      psproduc IN productos.sproduc%TYPE,
      pcidioma IN idiomas.cidioma%TYPE DEFAULT 2)
      RETURN tt_lineas IS
      v_lineas       tt_lineas;
   BEGIN
      FOR rdades IN (SELECT d.nlinea, d.ttexto
                       -- Ini bug 16790 - SRA - 02/02/2011
                     FROM   parlibretatext c JOIN parlibretatextdet d
                            ON c.tipolinea = d.tipolinea
                          AND c.sproduc = d.sproduc
                      WHERE c.tipolinea = ptipolinea
                        AND c.sproduc = psproduc) LOOP
         -- Fin bug 16790 - SRA - 02/02/2011
         v_lineas(rdades.nlinea) := CONVERT(rdades.ttexto, 'US7ASCII');
      END LOOP;

      RETURN v_lineas;
   END;

   --
   -- f_replace_parameters
   --    Donat un VARCHAR2 o un TT_DETALL substitueix al text tots les variables que s'han passat com TT_DICCIONARI
   --
   FUNCTION f_replace_parameters(plines IN tt_detall, pdiccionari IN tt_diccionari)
      RETURN tt_detall IS
      v_i            PLS_INTEGER;
      v_j            PLS_INTEGER;
      v_lines        tt_detall := plines;
   BEGIN
      v_i := v_lines.FIRST;

      WHILE v_i IS NOT NULL LOOP
         v_j := pdiccionari.FIRST;

         WHILE v_j IS NOT NULL LOOP
            v_lines(v_i).text := REPLACE(v_lines(v_i).text,
                                         '%' || pdiccionari(v_j).paraula || '%',
                                         pdiccionari(v_j).valor);
            v_j := pdiccionari.NEXT(v_j);
         END LOOP;

         v_i := v_lines.NEXT(v_i);
      END LOOP;

      RETURN v_lines;
   END;

   FUNCTION f_replace_parameters(plinia IN VARCHAR2, pdiccionari IN tt_diccionari)
      RETURN VARCHAR2 IS
      v_j            PLS_INTEGER;
      v_linia        VARCHAR2(1000) := plinia;
   BEGIN
      v_j := pdiccionari.FIRST;

      WHILE v_j IS NOT NULL LOOP
         v_linia := REPLACE(v_linia, '%' || pdiccionari(v_j).paraula || '%',
                            pdiccionari(v_j).valor);
         v_j := pdiccionari.NEXT(v_j);
      END LOOP;

      RETURN v_linia;
   END;

   --
   --  Esborra el contingut de les taules temporals per la sessió actual
   --
   PROCEDURE esborrartaulestemporals(psesion IN implibreta.sesion%TYPE DEFAULT NULL) IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      DELETE      detimplibreta
            WHERE sesion = NVL(psesion, USERENV('SESSIONID'));

      DELETE      implibreta
            WHERE sesion = NVL(psesion, USERENV('SESSIONID'));

      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'IMPRESION_LIBRETA.EsborrarTaulesTemporals', 1, '',
                     SQLERRM);
         RAISE;
   END;

   --
   --  Inserta el registre de la taula temporal IMPLIBRETA
   --
   PROCEDURE insertcapcalera(psseguro IN seguros.sseguro%TYPE) IS
      pnlinpagpor    NUMBER;
      pnpagporadici  NUMBER;
      pnlinpagporadi NUMBER;
      pnlinpag       NUMBER;
      pncarlin       NUMBER;
      err            NUMBER;
      numero         NUMBER;
      texto          VARCHAR2(100);
   BEGIN
      FOR rseguros IN (SELECT NVL(npagina, 0) pagina, NVL(nlinea, 0) linea
                         FROM seguros
                        WHERE seguros.sseguro = psseguro) LOOP
         err := f_parlibreta('PPNUMLINPAGDOC', numero, texto);
         pnlinpag := numero;
         err := f_parlibreta('PPNUMCARLIN', numero, texto);
         pncarlin := numero;
         err := f_parlibreta('PPLINPAGPORTADA', numero, texto);
         pnlinpagpor := numero;
         err := f_parlibreta('PPNUMPAGPORTADI', numero, texto);
         pnpagporadici := numero;
         err := f_parlibreta('PPLINPAGPORTADI', numero, texto);
         pnlinpagporadi := numero;

         INSERT INTO implibreta
                     (sesion, sseguro, nlinpag, ncarlin, nlinpagpor,
                      npagporadici, nlinpagporadi, npagactiva, nultlinimp)
              VALUES (USERENV('SESSIONID'), psseguro, pnlinpag, pncarlin, pnlinpagpor,
                      pnpagporadici, pnlinpagporadi, rseguros.pagina, rseguros.linea);
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'IMPRESION_LIBRETA.InsertCapcalera', 1,
                     'psSeguro =' || psseguro, SQLERRM);
         RAISE;
   END;

   --
   --  Insereix a DETIMPLIBRETA les línies enviades a pDetall
   --
   PROCEDURE inserir(
      psseguro IN seguros.sseguro%TYPE,
      pcagrup IN detimplibreta.cagrup%TYPE,
      pdetall IN tt_detall) IS
      v_i            PLS_INTEGER;
   BEGIN
      v_i := pdetall.FIRST;

      WHILE v_i IS NOT NULL LOOP
         INSERT INTO detimplibreta
                     (sesion, sseguro, fcontab, nnumlin,
                      nidlin, cagrup, nlinpag, nposcol,
                      texto)
              VALUES (USERENV('SESSIONID'), psseguro, f_sysdate, pdetall(v_i).linia,
                      pdetall(v_i).linia, pcagrup, v_i, pdetall(v_i).columna,
                      pdetall(v_i).text);

         v_i := pdetall.NEXT(v_i);
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'IMPRESION_LIBRETA.inserir', 1,
                     'p_cagrup =' || pcagrup, SQLERRM);

         IF v_i IS NOT NULL THEN
            p_tab_error(f_sysdate, f_user, 'IMPRESION_LIBRETA.inserir', 2,
                        'v_i=' || v_i || ' pDetall.id=' || pdetall(v_i).linia
                        || ' pDetall.columna=' || pdetall(v_i).columna || ' pDetall.text='
                        || pdetall(v_i).text,
                        SQLERRM);
         END IF;

         RAISE;
   END;

   --
   -- Converteix una taula de tipus TT_LINEAS a una de tipus TT_DETALL
   --
   FUNCTION castlineastodetall(plineas tt_lineas, pnumlin IN NUMBER)
      RETURN tt_detall IS
      v              tt_detall;
      v_i            PLS_INTEGER;
   BEGIN
      v_i := plineas.FIRST;

      WHILE v_i IS NOT NULL LOOP
         v( v_i) := detall(pnumlin - v_i + 1, 1, plineas(v_i));
         v_i := plineas.NEXT(v_i);
      END LOOP;

      RETURN v;
   END;

   --
   --  Obté el beneficiaris del text lliure i els converteix a paràmetres de substitució
   --      Permet fins a 5 línies de beneficiaris
   --
   PROCEDURE omplirbeneficiaris(
      psseguro IN seguros.sseguro%TYPE,
      plongitudmaxima IN NUMBER,
      pdiccionari IN OUT tt_diccionari) IS
      v_temp         VARCHAR2(32000);   --BUG 25583:NSS:09/02/2013
      v_existe       BOOLEAN;
      v_i            NUMBER;
      v_inici        NUMBER;
      v_final        NUMBER;
      v_i_beneficiari NUMBER := 0;
      v_char10       NUMBER;
      v_char13       NUMBER;

      PROCEDURE copiar(ptexto IN VARCHAR2) IS
         v_texto        VARCHAR2(1000);
      BEGIN
         -- Parteix el text perquè càpiga en 60 línies
         v_texto := ptexto;

         WHILE v_texto IS NOT NULL LOOP
            v_i_beneficiari := v_i_beneficiari + 1;
            pdiccionari(NVL(pdiccionari.LAST, 0) + 1) :=
               diccionari('BENEFICIARIO' || TO_CHAR(v_i_beneficiari),
                          CONVERT(SUBSTR(v_texto, 1, plongitudmaxima), 'US7ASCII'));
            v_texto := SUBSTR(v_texto, plongitudmaxima + 1);
         END LOOP;
      END;
   BEGIN
      v_existe := FALSE;

      FOR r IN (SELECT tclaesp
                  FROM clausuesp
                 WHERE ffinclau IS NULL
                   AND nriesgo = (SELECT MIN(riesgos.nriesgo)
                                    FROM riesgos
                                   WHERE riesgos.sseguro = clausuesp.sseguro
                                     AND riesgos.fanulac IS NULL)
                   AND sseguro = psseguro
                   AND cclaesp = 1) LOOP
         v_temp := r.tclaesp;
         v_existe := TRUE;
      END LOOP;

      IF NOT v_existe THEN
         FOR r IN (SELECT tclaben
                     FROM claubenseg, clausuben
                    WHERE claubenseg.sseguro = psseguro
                      AND clausuben.sclaben = claubenseg.sclaben
                      AND cidioma = g_cidioma
                      AND ffinclau IS NULL
                      AND nriesgo = (SELECT MIN(riesgos.nriesgo)
                                       FROM riesgos
                                      WHERE riesgos.sseguro = claubenseg.sseguro
                                        AND riesgos.fanulac IS NULL)) LOOP
            v_temp := r.tclaben;
         END LOOP;
      END IF;

      v_i := 1;
      v_inici := 1;

      LOOP
         -- Determina quin és el primer ASCII 13 o 10 de la línia i talla per allí
         v_char13 := INSTR(v_temp, CHR(13), 1, v_i);
         v_char10 := INSTR(v_temp, CHR(10), 1, v_i);
         v_final := CASE
                      WHEN v_char13 = 0 THEN v_char10
                      WHEN v_char10 = 0 THEN v_char13
                      ELSE LEAST(v_char13, v_char10)
                   END;
         EXIT WHEN v_final = 0;
         copiar(SUBSTR(v_temp, v_inici, v_final - v_inici));
         v_inici := v_final + 1;
         v_i := v_i + 1;
      END LOOP;

      copiar(SUBSTR(v_temp, v_inici));

      -- Fem que surtin en blanc els beneficiaris que no hem omplert
      FOR v_i IN v_i_beneficiari + 1 .. 5 LOOP
         pdiccionari(NVL(pdiccionari.LAST, 0) + 1) :=
                                                diccionari('BENEFICIARIO' || TO_CHAR(v_i), '');
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'IMPRESION_LIBRETA.Beneficiari', 1,
                     'psSeguro =' || psseguro, SQLERRM);
         RAISE;
   END;

   --
   --  Obté la descripció del producte
   --
   FUNCTION desproducte(psseguro IN seguros.sseguro%TYPE)
      RETURN VARCHAR2 IS
      v_nom_producte titulopro.ttitulo%TYPE;
      v_num_err      literales.slitera%TYPE;
   BEGIN
      FOR rproducto IN (SELECT p.cramo, p.cmodali, p.ctipseg, p.ccolect
                          -- Ini bug 16790 - SRA - 02/02/2011
                        FROM   seguros s JOIN productos p ON s.sproduc = p.sproduc
                         WHERE s.sseguro = psseguro) LOOP
         -- Fin bug 16790 - SRA - 02/02/2011
         v_num_err := f_desproducto(rproducto.cramo, rproducto.cmodali, 1, g_cidioma,
                                    v_nom_producte, rproducto.ctipseg, rproducto.ccolect);

         IF v_num_err <> 0 THEN
            RAISE exerror;
         END IF;
      END LOOP;

      RETURN v_nom_producte;
   EXCEPTION
      WHEN exerror THEN
         p_tab_error(f_sysdate, f_user, 'IMPRESION_LIBRETA.DesProducte', 1,
                     'psSeguro =' || psseguro,
                     v_num_err || '-' || f_axis_literales(v_num_err, f_idiomauser));
         RAISE;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'IMPRESION_LIBRETA.DesProducte', 1,
                     'parametros: psSeguro =' || psseguro, SQLERRM);
         RAISE;
   END;

   --
   --  Variables de substitució per POR, PAD i CAB
   --
   FUNCTION omplirdiccionari(psseguro IN seguros.sseguro%TYPE, pfreimp IN DATE)
      RETURN tt_diccionari IS
      v_diccionari   tt_diccionari;
      v_traza        tab_error.ntraza%TYPE;
      v_provmat      evoluprovmatseg.iprovmat%TYPE;
      v_capital      garanseg.icapital%TYPE;
      v_garantia_adicional garanseg.icapital%TYPE;
      v_contrato     VARCHAR2(20);
      v_titular      VARCHAR2(100);
      v_polini       VARCHAR2(30);
      v_oficina      VARCHAR2(80);
      v_titulars     NUMBER;
   BEGIN
      -- Portada  (POD)
      v_traza := 1;

      --Bug10612 - 10/07/2009 - DCT (canviar vista personas)
      FOR r IN (SELECT s.cagrpro,
                       TO_CHAR(s.cagente, 'FM0000') || ' - ' || RPAD(p.tapelli, 35) oficina,
                       s.npoliza || '-' || s.ncertif contrato
                  -- Ini Bug 16790 - SRA - 23/11/2010
                FROM   seguros s JOIN agentes a ON s.cagente = a.cagente
                       JOIN personas p ON a.sperson = p.sperson
                 -- Fin Bug 16790 - SRA - 23/11/2010
                WHERE  s.sseguro = psseguro) LOOP
         v_oficina := r.oficina;
         v_contrato := r.contrato;
         -- Buscamos el titular (plans de pensions)
         v_traza := 3;
         v_titulars := 0;

         IF r.cagrpro = 11 THEN   -- Plans pensions
            --Bug10612 - 10/07/2009 - DCT (canviar vista personas)
            FOR r IN (SELECT RPAD(SUBSTR(SUBSTR(d.tnombre, 0, 20) || ' '
                                         || SUBSTR(d.tapelli1, 0, 40) || ' '
                                         || SUBSTR(d.tapelli2, 0, 20),
                                         0, 42),
                                  42)
                             || 'DNI ' || p.nnumide titular
                        FROM seguros s, riesgos r, per_personas p, per_detper d
                       WHERE s.sseguro = psseguro
                         AND r.fanulac IS NULL
                         AND d.sperson = p.sperson
                         AND d.cagente = ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres)
                         AND r.sseguro = s.sseguro
                                                  /*SELECT    RPAD (SUBSTR (p.tnombre || ' ' || p.tapelli1 || ' ' || p.tapelli2, 0, 42 ), 42 )
                                                           || 'DNI '
                                                           || p.nnumnif  titular
                                                    FROM   SEGUROS s
                                                          JOIN RIESGOS r
                                                          USING (sseguro)
                                                          JOIN PERSONAS p
                                                          USING (sperson)
                                                    WHERE  sseguro = psseguro
                                                    AND    r.fanulac IS NULL*/

                    --FI Bug10612 - 10/07/2009 - DCT (canviar vista personas)
                    ) LOOP
               v_titulars := v_titulars + 1;
               v_diccionari(4 + v_titulars) := diccionari('TITULAR' || v_titulars, r.titular);
            END LOOP;
         ELSE
            -- Buscamos el titular (productes estalvi)
            --Bug10612 - 10/07/2009 - DCT (canviar vista personas)
            FOR r IN (SELECT   RPAD(SUBSTR(SUBSTR(d.tnombre, 0, 20) || ' '
                                           || SUBSTR(d.tapelli1, 0, 40) || ' '
                                           || SUBSTR(d.tapelli2, 0, 20),
                                           0, 42),
                                    42)
                               || 'DNI ' || p.nnumide titular,
                               ROWNUM - 1 n
                          FROM asegurados s, per_personas p, per_detper d, seguros se
                         WHERE s.sseguro = psseguro
                           AND s.ffecmue IS NULL
                           AND s.ffecfin IS NULL   --JRH Tarea 6966
                           AND s.sperson = p.sperson
                           AND d.sperson = p.sperson
                           AND d.cagente = ff_agente_cpervisio(se.cagente, f_sysdate,
                                                               se.cempres)
                           AND s.sseguro = se.sseguro
                      ORDER BY s.norden
                                       /*SELECT    RPAD (SUBSTR (p.tnombre || ' ' || p.tapelli1 || ' ' || p.tapelli2, 0, 42 ), 42 )
                                              || 'DNI '
                                              || p.nnumnif  titular, ROWNUM - 1 n
                                       FROM   ASEGURADOS s
                                             JOIN PERSONAS p
                                             USING (sperson)
                                       WHERE  s.sseguro = psseguro
                                       and s.ffecmue is null
                                          and s.ffecfin is null --JRH Tarea 6966
                                       ORDER BY s.norden*/
                                       --Bug10612 - 10/07/2009 - DCT (canviar vista personas)
                    ) LOOP
               v_titulars := v_titulars + 1;   --JRH Tarea 6966
               v_diccionari(4 + v_titulars) := diccionari('TITULAR' || TO_CHAR(v_titulars),
                                                          r.titular);
            END LOOP;
         END IF;

         v_traza := 4;
         v_diccionari(1) := diccionari('OFICINA', v_oficina);
         v_diccionari(2) := diccionari('CONTRATO', v_contrato);
         v_diccionari(3) := diccionari('POLINI', v_polini);
         v_diccionari(4) := diccionari('HOY', TO_CHAR(f_sysdate, 'DD MM YYYY'));
      END LOOP;

      v_traza := 2;

      --- Buscamos la póliza antigua
      FOR r IN (SELECT polissa_ini
                  FROM cnvpolizas
                 WHERE sseguro = psseguro) LOOP
         v_polini := r.polissa_ini;
      END LOOP;

      v_traza := 5;

      FOR v_i IN v_titulars + 1 .. 5 LOOP
         v_diccionari(NVL(v_diccionari.LAST, 0) + 1) :=
                                                    diccionari('TITULAR' || TO_CHAR(v_i), ' ');
      END LOOP;

      -- Portada adicional (PAD)
      v_traza := 11;

      FOR rseguro IN (SELECT s.fvencim, s.fefecto, s.sproduc,
                             TO_CHAR(TO_NUMBER(s.cbancar), '9999G9999G99G9999999999',
                                     'NLS_NUMERIC_CHARACTERS='',-''') ccc,
                             sa.frevisio, s.prevali
                        FROM seguros s LEFT JOIN seguros_aho sa
                                                               -- Ini bug 16790 - SRA - 02/02/2011
                                                               -- USING(sseguro)   -- RSC 09/11/2007 (LEFT JOIN por las pólizas Unit Linked)
                             ON s.sseguro = sa.sseguro
                       WHERE s.sseguro = psseguro) LOOP
         -- Fin bug 16790 - SRA - 02/02/2011
         v_traza := 12;
         -- Obtenir la provisió matemática del darrer any
         v_provmat := 0;

         IF pfreimp IS NULL THEN
            FOR rprovmat IN
               (SELECT iprovmat
                  FROM (SELECT LAST_VALUE(iprovmat) OVER(ORDER BY nanyo ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
                                                                                      iprovmat
                          FROM evoluprovmatseg
                         WHERE sseguro = psseguro
                           AND nmovimi = (SELECT MAX(nmovimi)
                                            FROM movseguro
                                           WHERE fefecto <= TRUNC(f_sysdate)
                                             AND sseguro = psseguro))
                 WHERE ROWNUM = 1) LOOP
               v_provmat := rprovmat.iprovmat;
            END LOOP;
         ELSE
            FOR rprovmat IN
               (SELECT iprovmat
                  FROM (SELECT LAST_VALUE(iprovmat) OVER(ORDER BY nanyo ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
                                                                                      iprovmat
                          FROM evoluprovmatseg
                         WHERE (sseguro, nmovimi) =
                                              (SELECT   sseguro, MAX(nmovimi)
                                                   FROM movseguro
                                                  WHERE fefecto <= pfreimp
                                                    AND sseguro = psseguro
                                               GROUP BY sseguro))
                 WHERE ROWNUM = 1) LOOP
               v_provmat := rprovmat.iprovmat;
            END LOOP;
         END IF;

         -- Obtenir el capital inicial
         v_traza := 13;
         v_capital := 0;

         FOR rcapital IN (SELECT g.icapital
                            FROM garanseg g
                           WHERE g.sseguro = psseguro
                             AND g.nriesgo = 1
                             AND g.cgarant = 48
                             AND g.nmovimi = 1) LOOP
            v_capital := rcapital.icapital;
         END LOOP;

         -- Obtenir la garantia adicional
         v_traza := 14;
         v_garantia_adicional := 0;

         FOR rcapital IN (SELECT g.icapital
                            FROM garanseg g
                           WHERE g.sseguro = psseguro
                             AND g.nriesgo = 1
                             AND g.cgarant = 102
                             AND g.nmovimi = 1) LOOP
            v_garantia_adicional := rcapital.icapital;
         END LOOP;

         v_traza := 15;
         -- Paràmetres calen pel producte
         v_diccionari(21) := diccionari('DESPRODUCTE', desproducte(psseguro));
         v_diccionari(22) := diccionari('CCC', rseguro.ccc);
         v_diccionari(23) := diccionari('FEFECTO', rseguro.fefecto);
         v_diccionari(24) := diccionari('FVENCIM', rseguro.fvencim);
         v_diccionari(25) := diccionari('CAPITAL',
                                        LPAD(TO_CHAR(v_capital, 'FM9G999G990D00'), 12));
         v_diccionari(26) := diccionari('PROVMAT',
                                        LPAD(TO_CHAR(v_provmat, 'FM9G999G990D00'), 12));
         v_diccionari(27) := diccionari('FREVISIO', rseguro.frevisio);
         v_diccionari(28) := diccionari('GARADICIONAL',
                                        LPAD(TO_CHAR(v_garantia_adicional, 'FM9G999G990D00'),
                                             12));
         v_diccionari(29) := diccionari('CRECIMIENTO', rseguro.prevali);

         -- Casos especials per rendes
         IF NVL(f_parproductos_v(rseguro.sproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN
            DECLARE
               v_rentabruta   NUMBER;
               v_rentamin     NUMBER;
               v_capfall      NUMBER;
               v_intgarant    NUMBER;
               v_num_err      NUMBER;
            BEGIN
               v_num_err := pac_calc_rentas.f_get_capitales_rentas(rseguro.sproduc, psseguro,
                                                                   rseguro.fefecto, 0, 1,
                                                                   1 /*pmovimi*/,
                                                                   v_rentabruta, v_rentamin,
                                                                   v_capfall, v_intgarant,
                                                                   'SEG');

               IF v_num_err <> 0 THEN
                  v_diccionari(30) := diccionari('RENDABRUTA',
                                                 LPAD('ERROR:' || v_num_err, 12));
                  v_diccionari(31) := diccionari('RENDAMINIMA',
                                                 LPAD('ERROR:' || v_num_err, 12));
                  v_diccionari(32) := diccionari('CAPFALLPAD',
                                                 LPAD('ERROR:' || v_num_err, 12));
               ELSE
                  v_diccionari(30) := diccionari('RENDABRUTA',
                                                 LPAD(TO_CHAR(v_rentabruta, 'FM9G999G990D00'),
                                                      12));
                  v_diccionari(31) := diccionari('RENDAMINIMA',
                                                 LPAD(TO_CHAR(v_rentamin, 'FM9G999G990D00'),
                                                      12));
                  v_diccionari(31) := diccionari('CAPFALLPAD',
                                                 LPAD(TO_CHAR(v_capfall, 'FM9G999G990D00'),
                                                      12));
               END IF;
            END;
         END IF;

         EXIT;   -- Només ha de tornar 1 registre el select
      END LOOP;

      omplirbeneficiaris(psseguro, 60, v_diccionari);
      RETURN v_diccionari;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'IMPRESION_LIBRETA.OmplirDiccionari', v_traza,
                     'psSeguro =' || psseguro, SQLERRM);
   END;

   --
   --
   --
   PROCEDURE generar_dat(
      psseguro IN seguros.sseguro%TYPE,
      pcagrpro IN codiagrupa.cagrpro%TYPE,
      pcramo IN ramos.cramo%TYPE,
      psproduc IN productos.sproduc%TYPE) IS
      v_tfecha       VARCHAR2(7);
      v_trescate     VARCHAR2(20);
      dat            tt_detall;
      v_traza        tab_error.ntraza%TYPE;
      v_lista        tt_lineas;
      v_diccionari   tt_diccionari;
   BEGIN
      v_lista := f_parlibretatextdet('DAT', psproduc, g_cidioma);
      -- DAT
      v_traza := 7;

      FOR rseguro IN (SELECT s.fefecto
                        FROM seguros s
                       WHERE sseguro = psseguro) LOOP
         FOR rdades IN
            (SELECT ROWNUM linea, x.*
               FROM (SELECT   c.nnumlin, c.cmovimi, cl.ccapfal, cl.ccapgar,
                              CASE
                                 WHEN c.cmovimi = 47 THEN c.fvalmov
                                 ELSE c.fcontab
                              END fecha,
                              CASE
                                 WHEN c.cmovimi <= 9 THEN c.imovimi
                                 ELSE -c.imovimi
                              END imovimi, cl.fimpres, c.ctipapor, c.fvalmov,
                              RANK() OVER(PARTITION BY c.cmovimi, c.fvalmov ORDER BY c.fvalmov,
                               c.nnumlin DESC) r
                         FROM seguros s, ctaseguro c, ctaseguro_libreta cl
                        WHERE s.sseguro = psseguro
                          AND c.sseguro = s.sseguro
                          AND cl.sseguro = c.sseguro
                          AND TRUNC(cl.fcontab) = TRUNC(c.fcontab)
                          AND cl.nnumlin = c.nnumlin
                          -- Si cmovimi = 0
                          --    només agafar final de mes + cmovanu = 0
                          -- També agafar si dia + mes de fecfecto es dia+mes de fvalmov però quan fvalmov = fefecto
                          AND(c.cmovimi <> 0
                              OR(c.cmovanu = 0
                                 AND LAST_DAY(c.fvalmov) = c.fvalmov)
                              OR(TO_CHAR(s.fefecto, 'MMDD') = TO_CHAR(c.fvalmov, 'MMDD')
                                 AND TRUNC(s.fefecto) <> TRUNC(c.fvalmov)))
                     ORDER BY nnumlin) x
              -- Per cmovimi=0 a final de mes eliminem les linies amb el mateix fvalmov excepte la última
             WHERE  r = 1
                 OR LAST_DAY(fvalmov) <> fvalmov
                 OR cmovimi <> 0) LOOP
            v_diccionari.DELETE;
            v_traza := 8;
            v_tfecha := TO_CHAR(rdades.fecha, 'DDMONYY',
                                'NLS_DATE_LANGUAGE='
                                || CASE g_cidioma
                                   WHEN 2 THEN 'Spanish'
                                   ELSE 'Catalan'
                                END);
            v_diccionari(1) := diccionari('FECHA', v_tfecha);
            v_diccionari(2) := diccionari('PRIMA',
                                          LPAD(TO_CHAR(rdades.imovimi, 'FM9G999G990D00'), 12));
            v_diccionari(3) := diccionari('PROVMAT',
                                          LPAD(TO_CHAR(rdades.imovimi, 'FM9G999G990D00'), 12));
            v_diccionari(4) := diccionari('CAPFALL',
                                          LPAD(TO_CHAR(rdades.ccapfal, 'FM9G999G990D00'), 12));
            v_diccionari(5) := diccionari('CAPGAR',
                                          LPAD(TO_CHAR(rdades.ccapgar, 'FM9G999G990D00'), 12));
            v_trescate := LPAD(' ', 7) || '%';

            FOR rrescate IN (SELECT prescate
                               FROM evoluprovmatseg
                                    JOIN
                                    (SELECT sseguro, nmovimi
                                       FROM (
                                             -- Ultim nmovimi per la darrera fefecto anterior a rDades.fecha
                                             SELECT sseguro,
                                                    LAST_VALUE(m.nmovimi) OVER(ORDER BY m.nmovimi ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
                                                                                       nmovimi
                                               FROM movseguro m
                                              WHERE m.fefecto <= rdades.fecha
                                                AND m.sseguro = psseguro
                                                AND m.cmovseg NOT IN(6, 52))
                                      -- Ini bug 16790 - SRA - 02/02/2011
                                     WHERE  ROWNUM = 1) t
                                    ON evoluprovmatseg.sseguro = t.sseguro
                                  AND evoluprovmatseg.nmovimi = t.nmovimi
                              -- Fin bug 16790 - SRA - 02/02/2011
                             WHERE  nanyo = TRUNC(MONTHS_BETWEEN(rdades.fecha, rseguro.fefecto)
                                                  / 12)
                                            + 1) LOOP
               v_trescate := LPAD(TO_CHAR(rrescate.prescate), 7) || '%';
            END LOOP;

            v_diccionari(99) := diccionari('RESCATE', v_trescate);

            CASE
               WHEN rdades.cmovimi IN(1, 2) THEN   -- Prima
                  dat(rdades.linea) := detall(rdades.linea, 1,
                                              f_replace_parameters(v_lista(1), v_diccionari));
               WHEN rdades.cmovimi = 0 THEN   -- Saldo
                  dat(rdades.linea) := detall(rdades.linea, 1,
                                              f_replace_parameters(v_lista(2), v_diccionari));
               ELSE   -- 8,32,33,34,47,49,51,52
                  dat(rdades.linea) := detall(rdades.linea, 1,
                                              f_replace_parameters(v_lista(1), v_diccionari));
            END CASE;
         END LOOP;
      END LOOP;

      inserir(psseguro, 'DAT', dat);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'IMPRESION_LIBRETA.generar_DAT', v_traza,
                     'psSeguro =' || psseguro || ' pcAgrpro=' || pcagrpro || ' pcRamo='
                     || pcramo || ' psProduc=' || psproduc,
                     SQLERRM);
         RAISE;
   END;

   -- RSC 08/11/2007 (Unit Linked)
   PROCEDURE generar_dat_ulk(
      psseguro IN seguros.sseguro%TYPE,
      pcagrpro IN codiagrupa.cagrpro%TYPE,
      pcramo IN ramos.cramo%TYPE,
      psproduc IN productos.sproduc%TYPE) IS
      v_tfecha       VARCHAR2(7);
      v_trescate     VARCHAR2(20);
      dat            tt_detall;
      v_traza        tab_error.ntraza%TYPE;
      v_lista        tt_lineas;
      v_diccionari   tt_diccionari;
   BEGIN
      v_lista := f_parlibretatextdet('DAT', psproduc, g_cidioma);
      -- DAT
      v_traza := 7;

      IF (NVL(f_parproductos_v(psproduc, 'PRODUCTO_MIXTO'), 0) = 1) THEN
         FOR rseguro IN (SELECT s.fefecto
                           FROM seguros s
                          WHERE sseguro = psseguro) LOOP
            FOR rdades IN
               (SELECT ROWNUM linea, x.*
                  FROM (SELECT   c.nnumlin, c.cmovimi, cl.ccapfal, cl.ccapgar,
                                 CASE
                                    WHEN c.cmovimi = 47 THEN c.fvalmov
                                    ELSE c.fcontab
                                 END fecha,
                                 CASE
                                    WHEN c.cmovimi IN
                                           (5, 6, 7, 21, 22, 23, 24, 26, 27, 28, 29,
                                            39, 60, 80, 51, 82) THEN -c.imovimi
                                    ELSE c.imovimi
                                 END imovimi,
                                 cl.fimpres, c.ctipapor, c.fvalmov,
                                 RANK() OVER(PARTITION BY c.cmovimi, c.fvalmov ORDER BY c.fvalmov,
                                  c.nnumlin DESC) r
                            FROM seguros s, ctaseguro c, ctaseguro_libreta cl
                           WHERE s.sseguro = psseguro
                             AND c.sseguro = s.sseguro
                             AND cl.sseguro = c.sseguro
                             AND TRUNC(cl.fcontab) = TRUNC(c.fcontab)
                             AND cl.nnumlin = c.nnumlin
                             --AND c.cmovimi NOT IN (60,70,80) -- Eso dependerá si queremos que aparezan en libreta o no (Redistribución)
                             AND c.cmovimi NOT IN
                                   (60)   -- De la redistribución cogemos el importe de compra y los gastos!
                             AND((SELECT c2.nunidad
                                    FROM ctaseguro c2
                                   WHERE c2.sseguro = cl.sseguro
                                     --AND trunc(c2.fcontab) = trunc(cl.fcontab)
                                     AND c2.nnumlin = cl.nnumlin + 1
                                     AND 0 <> (SELECT cmovimi   -- diferent de una linea de saldo
                                                 FROM ctaseguro
                                                WHERE sseguro = c2.sseguro
                                                  --and trunc(fcontab) = trunc(c2.fcontab)
                                                  AND nnumlin = c2.nnumlin - 1)) IS NOT NULL
                                 OR c.cmovimi = 0)   -- Con esto aseguramos que el movimiento esta consolidado
                                                     -- tiene participaciones asignadas (o se trata uno de saldo)
                             AND((c.cmovanu = 0
                                  AND LAST_DAY(c.fvalmov) = c.fvalmov)
                                 OR(TO_CHAR(s.fefecto, 'MMDD') = TO_CHAR(c.fvalmov, 'MMDD')
                                    AND TRUNC(s.fefecto) <> TRUNC(c.fvalmov)))
                        ORDER BY nnumlin) x
                 -- Per cmovimi=0 a final de mes eliminem les linies amb el mateix fvalmov excepte la última
                WHERE  r = 1
                    OR LAST_DAY(fvalmov) <> fvalmov
                    OR cmovimi <> 0) LOOP
               v_diccionari.DELETE;
               v_traza := 8;
               v_tfecha := TO_CHAR(rdades.fecha, 'DDMONYY',
                                   'NLS_DATE_LANGUAGE='
                                   || CASE g_cidioma
                                      WHEN 2 THEN 'Spanish'
                                      ELSE 'Catalan'
                                   END);
               v_diccionari(1) := diccionari('FECHA', v_tfecha);
               v_diccionari(2) := diccionari('PRIMA',
                                             LPAD(TO_CHAR(rdades.imovimi, 'FM9G999G990D00'),
                                                  12));
               v_diccionari(3) := diccionari('PROVMAT',
                                             LPAD(TO_CHAR(rdades.imovimi, 'FM9G999G990D00'),
                                                  12));

               -- RSC 12/11/2007 -----------------------------------------------------
               IF rdades.cmovimi = 70 THEN
                  v_diccionari(4) :=
                     diccionari('CAPFALL',
                                LPAD(TO_CHAR((rdades.imovimi + pac_operativa_ulk.k_extracapfall),
                                             'FM9G999G990D00'),
                                     12));
               ELSE
                  v_diccionari(4) := diccionari('CAPFALL',
                                                LPAD(TO_CHAR(rdades.ccapfal, 'FM9G999G990D00'),
                                                     12));
               END IF;

-----------------------------------------------------------------------
               v_diccionari(5) := diccionari('CAPGAR',
                                             LPAD(TO_CHAR(rdades.ccapgar, 'FM9G999G990D00'),
                                                  12));
               v_trescate := LPAD(' ', 7);
               v_diccionari(99) := diccionari('RESCATE', v_trescate);
----------------------------------------------------------------------
               v_diccionari(100) := diccionaricmovimis('CONCEPTO', rdades.cmovimi);

               CASE
                  WHEN rdades.cmovimi IN(1, 2, 4) THEN   -- Prima
                     dat(rdades.nnumlin) := detall(rdades.nnumlin, 1,
                                                   f_replace_parameters(v_lista(1),
                                                                        v_diccionari));
                  WHEN rdades.cmovimi IN(0, 70) THEN   -- Saldo
                     dat(rdades.nnumlin) := detall(rdades.nnumlin, 1,
                                                   f_replace_parameters(v_lista(2),
                                                                        v_diccionari));
                  ELSE   -- 8,32,33,34,47,49,51,52
                     dat(rdades.nnumlin) := detall(rdades.nnumlin, 1,
                                                   f_replace_parameters(v_lista(1),
                                                                        v_diccionari));
               END CASE;
            END LOOP;
         END LOOP;
      ELSE
         FOR rseguro IN (SELECT s.fefecto
                           FROM seguros s
                          WHERE sseguro = psseguro) LOOP
            FOR rdades IN
               (SELECT ROWNUM linea, x.*
                  FROM (SELECT   c.nnumlin, c.cmovimi, cl.ccapfal, cl.ccapgar,
                                                                              --CASE WHEN c.cmovimi = 47 THEN c.fvalmov ELSE c.fcontab END fecha,
                                                                              c.fasign fecha,
                                 CASE
                                    WHEN c.cmovimi IN
                                           (5, 6, 7, 21, 22, 23, 24, 26, 27, 28, 29,
                                            39, 60, 80, 51, 82) THEN -c.imovimi
                                    ELSE c.imovimi
                                 END imovimi,
                                 cl.fimpres, c.ctipapor, c.fvalmov,
                                 RANK() OVER(PARTITION BY c.cmovimi, c.fvalmov ORDER BY c.fvalmov,
                                  c.nnumlin DESC) r
                            FROM seguros s, ctaseguro c, ctaseguro_libreta cl
                           WHERE s.sseguro = psseguro
                             AND c.sseguro = s.sseguro
                             AND cl.sseguro = c.sseguro
                             AND TRUNC(cl.fcontab) = TRUNC(c.fcontab)
                             AND cl.nnumlin = c.nnumlin
                             --AND c.cmovimi NOT IN (60,70,80) -- Eso dependerá si queremos que aparezan en libreta o no (Redistribución)
                             AND c.cmovimi NOT IN
                                   (60)   -- De la redistribución cogemos el importe de compra y los gastos!
                             AND((SELECT c2.nunidad
                                    FROM ctaseguro c2
                                   WHERE c2.sseguro = cl.sseguro
                                     --AND trunc(c2.fcontab) = trunc(cl.fcontab)
                                     AND c2.nnumlin = cl.nnumlin + 1
                                     AND 0 <> (SELECT cmovimi   -- diferent de una linea de saldo
                                                 FROM ctaseguro
                                                WHERE sseguro = c2.sseguro
                                                  --and trunc(fcontab) = trunc(c2.fcontab)
                                                  AND nnumlin = c2.nnumlin - 1)) IS NOT NULL
                                 OR c.cmovimi = 0)   -- Con esto aseguramos que el movimiento esta consolidado
                                                     -- tiene participaciones asignadas (o se trata uno de saldo)
                             AND(c.cmovimi <> 0
                                 OR(c.cmovanu = 0
                                    AND LAST_DAY(c.fvalmov) = c.fvalmov)
                                 OR(TO_CHAR(s.fefecto, 'MMDD') = TO_CHAR(c.fvalmov, 'MMDD')
                                    AND TRUNC(s.fefecto) <> TRUNC(c.fvalmov)))
                        ORDER BY nnumlin) x
                 -- Per cmovimi=0 a final de mes eliminem les linies amb el mateix fvalmov excepte la última
                WHERE  r = 1
                    OR LAST_DAY(fvalmov) <> fvalmov
                    OR cmovimi <> 0) LOOP
               v_diccionari.DELETE;
               v_traza := 8;
               v_tfecha := TO_CHAR(rdades.fecha, 'DDMONYY',
                                   'NLS_DATE_LANGUAGE='
                                   || CASE g_cidioma
                                      WHEN 2 THEN 'Spanish'
                                      ELSE 'Catalan'
                                   END);
               v_diccionari(1) := diccionari('FECHA', v_tfecha);
               v_diccionari(2) := diccionari('PRIMA',
                                             LPAD(TO_CHAR(rdades.imovimi, 'FM9G999G990D00'),
                                                  12));
               v_diccionari(3) := diccionari('PROVMAT',
                                             LPAD(TO_CHAR(rdades.imovimi, 'FM9G999G990D00'),
                                                  12));

               -- RSC 12/11/2007 -----------------------------------------------------
               IF rdades.cmovimi = 70 THEN
                  v_diccionari(4) :=
                     diccionari('CAPFALL',
                                LPAD(TO_CHAR((rdades.imovimi + pac_operativa_ulk.k_extracapfall),
                                             'FM9G999G990D00'),
                                     12));
               ELSE
                  v_diccionari(4) := diccionari('CAPFALL',
                                                LPAD(TO_CHAR(rdades.ccapfal, 'FM9G999G990D00'),
                                                     12));
               END IF;

-----------------------------------------------------------------------
               v_diccionari(5) := diccionari('CAPGAR',
                                             LPAD(TO_CHAR(rdades.ccapgar, 'FM9G999G990D00'),
                                                  12));
               v_trescate := LPAD(' ', 7);
               v_diccionari(99) := diccionari('RESCATE', v_trescate);
----------------------------------------------------------------------
               v_diccionari(100) := diccionaricmovimis('CONCEPTO', rdades.cmovimi);

               CASE
                  WHEN rdades.cmovimi IN(1, 2, 4) THEN   -- Prima
                     dat(rdades.nnumlin) := detall(rdades.nnumlin, 1,
                                                   f_replace_parameters(v_lista(1),
                                                                        v_diccionari));
                  WHEN rdades.cmovimi IN(0, 70) THEN   -- Saldo
                     dat(rdades.nnumlin) := detall(rdades.nnumlin, 1,
                                                   f_replace_parameters(v_lista(2),
                                                                        v_diccionari));
                  ELSE   -- 8,32,33,34,47,49,51,52
                     dat(rdades.nnumlin) := detall(rdades.nnumlin, 1,
                                                   f_replace_parameters(v_lista(1),
                                                                        v_diccionari));
               END CASE;
            END LOOP;
         END LOOP;
      END IF;

      inserir(psseguro, 'DAT', dat);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'IMPRESION_LIBRETA.generar_DAT', v_traza,
                     'psSeguro =' || psseguro || ' pcAgrpro=' || pcagrpro || ' pcRamo='
                     || pcramo || ' psProduc=' || psproduc,
                     SQLERRM);
         RAISE;
   END;

   --
   --  Funció originalment a PAC_TFV
   --
   PROCEDURE generar_pla_pensions(psseguro IN NUMBER, pfreimp IN DATE DEFAULT NULL) IS
      numero         NUMBER;
      texto          VARCHAR2(100);
      linea          NUMBER;
      linreg         NUMBER;
      tmes           CHAR(3);
      pagina         NUMBER;
      fultimp        DATE;
      err            NUMBER;
      agrupacion     NUMBER;
--        cabeceralin1     VARCHAR2 (100);
--        cabeceralin2     VARCHAR2 (100);
      concepto       VARCHAR2(20);
      signo          NUMBER;
      contalin       NUMBER := 0;
      nomfondo       VARCHAR2(80);
      nomplan        VARCHAR2(80);
      contrato       VARCHAR2(20);
      efecto         VARCHAR2(10);
      oficina        VARCHAR2(80);
      saldo          NUMBER;
      valor_parti    NUMBER;
      importe        NUMBER;
      divisa         NUMBER;
      partis         NUMBER;
      entrada        NUMBER;
      titular        VARCHAR2(100);
      polini         VARCHAR2(30);
      numparti       NUMBER;
      pcramo         seguros.cramo%TYPE;
      pcmodali       NUMBER(2);
      v_traza        tab_error.ntraza%TYPE;
   BEGIN
      v_traza := 1;

      --Bug10612 - 10/07/2009 - DCT (canviar vista personas)
      SELECT TO_CHAR(seguros.fefecto, 'DD-MM-YYYY'),
             seguros.npoliza || '-' || seguros.ncertif, seguros.cagrpro,
             SUBSTR(d.tapelli1, 0, 40) || ' ' || SUBSTR(d.tapelli2, 0, 20),
             planpensiones.tnompla
        INTO efecto,
             contrato, agrupacion,
             nomfondo,
             nomplan
        FROM seguros, proplapen, planpensiones, fonpensiones, per_personas p, per_detper d
       WHERE seguros.sseguro = psseguro
         AND proplapen.sproduc = seguros.sproduc
         AND proplapen.ccodpla = planpensiones.ccodpla
         AND planpensiones.ccodfon = fonpensiones.ccodfon
         AND fonpensiones.sperson = p.sperson
         AND d.sperson = p.sperson
         AND d.cagente = ff_agente_cpervisio(seguros.cagente, f_sysdate, seguros.cempres);

      --FI Bug10612 - 10/07/2009 - DCT (canviar vista personas)

      /*SELECT TO_CHAR (SEGUROS.fefecto, 'DD-MM-YYYY'),
              npoliza || '-' || ncertif, cagrpro, PERSONAS.tapelli,
              PLANPENSIONES.tnompla, ccodsn
       INTO   efecto,
              contrato, agrupacion, nomfondo,
              nomplan, pccodsn
       FROM   SEGUROS, PROPLAPEN, PLANPENSIONES, FONPENSIONES, PERSONAS
       WHERE  SEGUROS.sseguro = psseguro
       AND    PROPLAPEN.sproduc = SEGUROS.sproduc
       AND    PROPLAPEN.ccodpla = PLANPENSIONES.ccodpla
       AND    PLANPENSIONES.ccodfon = FONPENSIONES.ccodfon
       AND    FONPENSIONES.sperson = PERSONAS.sperson;*/

      --- Buscamos la póliza antigua
      v_traza := 2;

      BEGIN
         SELECT polissa_ini
           INTO polini
           FROM cnvpolizas
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            --DBMS_OUTPUT.put_line(SQLERRM);
            NULL;
      END;

      v_traza := 3;

      -- Si la polini es nula ponemos solo el npoliza
      --Bug10612 - 10/07/2009 - DCT (canviar vista personas)
      SELECT TO_CHAR(seguros.cagente, 'FM0000') || ' - '
             || RPAD(SUBSTR(d.tapelli1, 0, 40) || ' ' || SUBSTR(d.tapelli2, 0, 20), 35)
        INTO oficina
        FROM seguros, agentes, personas p, per_detper d
       WHERE seguros.sseguro = psseguro
         AND seguros.cagente = agentes.cagente
         AND agentes.sperson = p.sperson
         AND d.sperson = p.sperson
         AND d.cagente = ff_agente_cpervisio(seguros.cagente, f_sysdate, seguros.cempres);

      SELECT TO_CHAR(seguros.fefecto, 'DD-MM-YYYY'),
             seguros.npoliza || '-' || seguros.ncertif, seguros.cagrpro,
             SUBSTR(d.tapelli1, 0, 40) || ' ' || SUBSTR(d.tapelli2, 0, 20),
             planpensiones.tnompla
        INTO efecto,
             contrato, agrupacion,
             nomfondo,
             nomplan
        FROM seguros, proplapen, planpensiones, fonpensiones, per_personas p, per_detper d
       WHERE seguros.sseguro = psseguro
         AND proplapen.sproduc = seguros.sproduc
         AND proplapen.ccodpla = planpensiones.ccodpla
         AND planpensiones.ccodfon = fonpensiones.ccodfon
         AND fonpensiones.sperson = p.sperson
         AND d.sperson = p.sperson
         AND d.cagente = ff_agente_cpervisio(seguros.cagente, f_sysdate, seguros.cempres);

      --FI Bug10612 - 10/07/2009 - DCT (canviar vista personas)

      /*SELECT TO_CHAR (SEGUROS.cagente, 'FM0000') || ' - '
             || RPAD (tapelli, 35)
      INTO   oficina
      FROM   SEGUROS, AGENTES, PERSONAS
      WHERE  SEGUROS.sseguro = psseguro
      AND    SEGUROS.cagente = AGENTES.cagente
      AND    AGENTES.sperson = PERSONAS.sperson;

      SELECT TO_CHAR (SEGUROS.fefecto, 'DD-MM-YYYY'),
             npoliza || '-' || ncertif, cagrpro, PERSONAS.tapelli,
             PLANPENSIONES.tnompla, ccodsn
      INTO   efecto,
             contrato, agrupacion, nomfondo,
             nomplan, pccodsn
      FROM   SEGUROS, PROPLAPEN, PLANPENSIONES, FONPENSIONES, PERSONAS
      WHERE  SEGUROS.sseguro = psseguro
      AND    PROPLAPEN.sproduc = SEGUROS.sproduc
      AND    PROPLAPEN.ccodpla = PLANPENSIONES.ccodpla
      AND    PLANPENSIONES.ccodfon = FONPENSIONES.ccodfon
      AND    FONPENSIONES.sperson = PERSONAS.sperson;*/
      v_traza := 4;

      --Bug10612 - 10/07/2009 - DCT (canviar vista personas)
      -- Buscamos el titular
      SELECT RPAD(SUBSTR(SUBSTR(d.tnombre, 0, 20) || ' ' || SUBSTR(d.tapelli1, 0, 40) || ' '
                         || SUBSTR(d.tapelli2, 0, 20),
                         0, 42),
                  42)
             || 'DNI ' || p.nnumide
        INTO titular
        FROM per_personas p, per_detper d, riesgos, seguros
       WHERE seguros.sseguro = psseguro
         AND seguros.sseguro = riesgos.sseguro
         AND riesgos.sperson = p.sperson
         AND riesgos.fanulac IS NULL
         AND d.sperson = p.sperson
         AND d.cagente = ff_agente_cpervisio(seguros.cagente, f_sysdate, seguros.cempres);

      /*SELECT    RPAD (SUBSTR (tnombre || ' ' || tapelli1 || ' ' || tapelli2,
                              0,
                              42
                             ),
                      42
                     )
             || 'DNI '
             || nnumnif
      INTO   titular
      FROM   PERSONAS, RIESGOS, SEGUROS
      WHERE  SEGUROS.sseguro = psseguro
      AND    SEGUROS.sseguro = RIESGOS.sseguro
      AND    RIESGOS.sperson = PERSONAS.sperson
      AND    RIESGOS.fanulac IS NULL;*/

      --FI Bug10612 - 10/07/2009 - DCT (canviar vista personas)

      -- buscamos los datos de la última impresión
      --       SELECT MAX (fimpres)
      --       INTO   fultimp
      --       FROM   CTASEGURO_LIBRETA
      --       WHERE  sseguro = psseguro;
      v_traza := 5;

      SELECT NVL(npagina, 0), NVL(nlinea, 0), cramo, cmodali
        INTO pagina, linea, pcramo, pcmodali
        FROM seguros
       WHERE seguros.sseguro = psseguro;

               -- La reimpresión implica una nueva libreta
      --          linea   := 0;
      --          pagina  := 0;
      --       ELSIF fultimp IS NOT NULL THEN                       -- IMPRESION NORMAL
      --          SELECT MAX (nnumlin)
      --          INTO   linreg
      --          FROM   CTASEGURO_LIBRETA
      --          WHERE  sseguro = psseguro
      --          AND    TRUNC (fimpres) = TRUNC (fultimp);
      --          -- AND    ROWNUM = 1;
      --
      --          SELECT npagina, nlinea
      --          INTO   pagina, linea
      --          FROM   CTASEGURO_LIBRETA
      --          WHERE  sseguro = psseguro
      --        AND  nnumlin = linreg;
      --          --AND    TRUNC (fimpres) = TRUNC (fultimp)
      --          --AND    ROWNUM = 1;
      --       ELSE             --> No se ha impreso nunca, por lo que es libreta nueva
      --          linea   := 0;
      --          pagina  := 0;
      --       END IF;

      --*************************************************************************************************************
-- LINEA DE PORTADA
--*************************************************************************************************************
      IF agrupacion = 11 THEN   --> Planes de Pensiones
         v_traza := 8;

         INSERT INTO detimplibreta
                     (sesion, sseguro, fcontab, nnumlin, nidlin, cagrup, nlinpag, nposcol,
                      texto)
              VALUES (USERENV('SESSIONID'), psseguro, f_sysdate, -100, -100, 'POR', 1, 1,
                      ' ' || oficina);

         INSERT INTO detimplibreta
                     (sesion, sseguro, fcontab, nnumlin, nidlin, cagrup, nlinpag, nposcol,
                      texto)
              VALUES (USERENV('SESSIONID'), psseguro, f_sysdate, -101, -101, 'POR', 2, 1,
                      '                                              ' || contrato);

         INSERT INTO detimplibreta
                     (sesion, sseguro, fcontab, nnumlin, nidlin, cagrup, nlinpag, nposcol,
                      texto)
              VALUES (USERENV('SESSIONID'), psseguro, f_sysdate, -102, -102, 'POR', 3, 1,
                      '                                              ' || polini);

         INSERT INTO detimplibreta
                     (sesion, sseguro, fcontab, nnumlin, nidlin, cagrup, nlinpag, nposcol,
                      texto)
              VALUES (USERENV('SESSIONID'), psseguro, f_sysdate, -103, -103, 'POR', 4, 1,
                      titular);

         INSERT INTO detimplibreta
                     (sesion, sseguro, fcontab, nnumlin, nidlin, cagrup, nlinpag, nposcol,
                      texto)
              VALUES (USERENV('SESSIONID'), psseguro, f_sysdate, -104, -104, 'POR', 9, 1,
                      LPAD(TO_CHAR(f_sysdate, 'DD MM YYYY'), 42));
      END IF;

 --*************************************************************************************************************
-- LINEA DE PORTADA ADICIONAL
--*************************************************************************************************************
      IF agrupacion = 11 THEN   --> Planes de Pensiones
         v_traza := 9;

-- Ini Bug 16790 - SRA - 23/11/2010
         INSERT INTO detimplibreta
                     (sesion, sseguro, fcontab, nnumlin, nidlin, cagrup, nlinpag, nposcol,
                      texto)
              VALUES (USERENV('SESSIONID'), psseguro, f_sysdate, -10, -10, 'PAD', 1, 1,
                      CHR(39) || nomfondo || CHR(39));

         INSERT INTO detimplibreta
                     (sesion, sseguro, fcontab, nnumlin, nidlin, cagrup, nlinpag, nposcol,
                      texto)
              VALUES (USERENV('SESSIONID'), psseguro, f_sysdate, -11, -11, 'PAD', 2, 1,
                      CHR(39) || nomplan || CHR(39));

-- FiN Bug 16790 - SRA - 23/11/2010
         INSERT INTO detimplibreta
                     (sesion, sseguro, fcontab, nnumlin, nidlin, cagrup, nlinpag, nposcol,
                      texto)
              VALUES (USERENV('SESSIONID'), psseguro, f_sysdate, -12, -12, 'PAD', 3, 1,
                      'PLAN: ');

         INSERT INTO detimplibreta
                     (sesion, sseguro, fcontab, nnumlin, nidlin, cagrup, nlinpag, nposcol,
                      texto)
              VALUES (USERENV('SESSIONID'), psseguro, f_sysdate, -13, -13, 'PAD', 4, 1,
                      'FECHAS: ');

         INSERT INTO detimplibreta
                     (sesion, sseguro, fcontab, nnumlin, nidlin, cagrup, nlinpag, nposcol,
                      texto)
              VALUES (USERENV('SESSIONID'), psseguro, f_sysdate, -14, -14, 'PAD', 5, 1,
                      ' EFECTO......:   ' || efecto);

         INSERT INTO detimplibreta
                     (sesion, sseguro, fcontab, nnumlin, nidlin, cagrup, nlinpag, nposcol,
                      texto)
              VALUES (USERENV('SESSIONID'), psseguro, f_sysdate, -15, -15, 'PAD', 10, 1,
                      'ENTIDAD DEPOSITARIA: "SA NOSTRA" CAIXA DE BALEARS');

         INSERT INTO detimplibreta
                     (sesion, sseguro, fcontab, nnumlin, nidlin, cagrup, nlinpag, nposcol,
                      texto)
              VALUES (USERENV('SESSIONID'), psseguro, f_sysdate, -16, -16, 'PAD', 11, 1,
                      'ENTIDAD GESTORA: SA NOSTRA COMPAÑIA DE SEGUROS DE VIDA,S.A');

         INSERT INTO detimplibreta
                     (sesion, sseguro, fcontab, nnumlin, nidlin, cagrup, nlinpag, nposcol,
                      texto)
              VALUES (USERENV('SESSIONID'), psseguro, f_sysdate, -17, -17, 'PAD', 14, 1,
                      'LA PRESTACIÓN  DERIVADA  DEL  PLAN DE PENSIONES  PUEDE SER');

         INSERT INTO detimplibreta
                     (sesion, sseguro, fcontab, nnumlin, nidlin, cagrup, nlinpag, nposcol,
                      texto)
              VALUES (USERENV('SESSIONID'), psseguro, f_sysdate, -18, -18, 'PAD', 17, 1,
                      'REALIZADA EN FORMA DE CAPITAL O DE RENTA.DISCRECIONALMENTE');

         INSERT INTO detimplibreta
                     (sesion, sseguro, fcontab, nnumlin, nidlin, cagrup, nlinpag, nposcol,
                      texto)
              VALUES (USERENV('SESSIONID'), psseguro, f_sysdate, -19, -19, 'PAD', 20, 1,
                      'PUEDEN SATISFACERSE APORTACIONES  AL  PLAN EN TODO MOMENTO');
      END IF;

   --*************************************************************************************************************
-- LINEA DE CABECERA
--*************************************************************************************************************
      IF agrupacion = 11 THEN
         v_traza := 10;

         FOR rtexto IN (SELECT t.nlinea, t.ttexto
                          -- Ini bug 16790 - SRA - 02/02/2011
                        FROM   parlibretatextdet t JOIN seguros s ON t.sproduc = s.sproduc
                         -- Fin bug 16790 - SRA - 02/02/2011
                        WHERE  t.tipolinea = 'CAB'
                           AND t.cidioma = 2
                           AND s.sseguro = psseguro) LOOP
            INSERT INTO detimplibreta
                        (sesion, sseguro, fcontab, nnumlin,
                         nidlin, cagrup, nlinpag, nposcol, texto)
                 VALUES (USERENV('SESSIONID'), psseguro, f_sysdate, -rtexto.nlinea,
                         -rtexto.nlinea, 'CAB', rtexto.nlinea, 1, rtexto.ttexto);
         END LOOP;
      END IF;

--*************************************************************************************************************
-- LINEA DE DATOS
--*************************************************************************************************************
      contalin := 0;
      --DBMS_OUTPUT.put_line('******** LINEA DE DATO ******');
      entrada := 0;
      v_traza := 11;

      SELECT SUM(DECODE(GREATEST(ctaseguro.cmovimi, 9),
                        9, ctaseguro.nparpla,
                        -ctaseguro.nparpla))
        INTO partis
        FROM ctaseguro
       WHERE ctaseguro.sseguro = psseguro
         AND ctaseguro.cmovimi NOT IN(0, 54)
         AND 0 = (SELECT COUNT(*)
                    FROM ctaseguro_libreta cl
                   WHERE cl.sseguro = ctaseguro.sseguro
                     AND TRUNC(cl.fcontab) = TRUNC(ctaseguro.fcontab)
                     AND cl.nnumlin = ctaseguro.nnumlin);

      partis := NVL(partis, 0);
      v_traza := 12;

      FOR lib IN (SELECT   c.nnumlin, c.cmovimi,
                           DECODE(GREATEST(c.cmovimi, 9), 9, c.imovimi, -c.imovimi) "IMOVIMI",
                           DECODE(GREATEST(c.cmovimi, 9), 9, c.nparpla, -c.nparpla) "NPARPLA",
                           c.fvalmov, c.fcontab, cl.fimpres, c.ctipapor
                      FROM ctaseguro c, ctaseguro_libreta cl
                     WHERE c.sseguro = psseguro
                       AND cl.sseguro = c.sseguro
                       AND TRUNC(cl.fcontab) = TRUNC(c.fcontab)
                       AND cl.nnumlin = c.nnumlin
                       AND c.nparpla IS NOT NULL
                  ORDER BY c.sseguro, c.nnumlin) LOOP
         IF lib.cmovimi NOT IN(0) THEN
            partis := NVL(partis, 0) + lib.nparpla;
         END IF;

         valor_parti := f_valor_participlan(lib.fvalmov, psseguro, divisa);

         /* Operacion con participaciones pero no hay valor de participacion. NO IMPRIMIR */
         IF (pcramo = 10
             AND pcmodali = 2
             AND valor_parti = -1) THEN
            EXIT;
         END IF;

         IF lib.cmovimi = 0
            AND valor_parti = -1 THEN
            importe := lib.imovimi;
         ELSE
            importe := ROUND(NVL(partis, 0) * valor_parti, 2);
         END IF;

         --  IF LIB.CMOVIMI NOT IN ( 0 ) THEN
         --  INSERT INTO INFORMES_ERR VALUES ( LIB.NPARPLA || 'linea ' || lib.nnumlin || ' partis ' || partis || ' valor parti ' || valor_parti );
         --  END IF;
         IF (lib.fimpres IS NULL
             AND pfreimp IS NULL)   --- > Impresion normal
            OR(pfreimp IS NOT NULL
               AND TRUNC(lib.fcontab) >= TRUNC(pfreimp)) THEN   --> Reimpresion-- > Imprimimos el movimiento
            IF lib.cmovimi = 1 THEN
               concepto := 'APORTACIÓN';
            ELSIF lib.cmovimi = 2
                  AND lib.ctipapor = 'P' THEN
               concepto := 'AP. RIESGO';
            ELSIF lib.cmovimi = 2
                  AND NVL(lib.ctipapor, 'X') <> 'P' THEN
               concepto := 'RECIBO';
            ELSIF lib.cmovimi = 0 THEN
               concepto := 'SALDO';
            ELSIF lib.cmovimi IN(8, 47) THEN
               concepto := 'TRASP.DERECHOS';
            ELSIF lib.cmovimi = 53 THEN
               concepto := 'PRESTACIÓN';
            ELSIF lib.cmovimi = 51
                  AND lib.ctipapor = 'P' THEN
               concepto := 'ANU AP. RIESGO';
            ELSIF lib.cmovimi = 51
                  AND NVL(lib.ctipapor, 'X') <> 'P' THEN
               concepto := 'ANU RECIBO';
            ELSIF lib.cmovimi = 10 THEN
               concepto := 'ANU PRESTACIÓN';
            END IF;

            --IF lib.cmovimi <= 10 THEN
            signo := 1;

            --ELSE
            --   signo  := -1;
            --END IF;

            --dbms_output.put_line ( lib.cmovimi  || ' concepto ' || concepto );
            -- SELECT DECODE (TO_CHAR (lib.fvalmov, 'MM'),
            IF (lib.cmovimi IN(47, 53)) THEN
               SELECT DECODE(TO_CHAR(lib.fvalmov, 'MM'),
                             '01', 'ENE',
                             '02', 'FEB',
                             '03', 'MAR',
                             '04', 'ABR',
                             '05', 'MAY',
                             '06', 'JUN',
                             '07', 'JUL',
                             '08', 'AGO',
                             '09', 'SEP',
                             '10', 'OCT',
                             '11', 'NOV',
                             '12', 'DIC')
                 INTO tmes
                 FROM DUAL;
            ELSE
               SELECT DECODE(TO_CHAR(lib.fcontab, 'MM'),
                             '01', 'ENE',
                             '02', 'FEB',
                             '03', 'MAR',
                             '04', 'ABR',
                             '05', 'MAY',
                             '06', 'JUN',
                             '07', 'JUL',
                             '08', 'AGO',
                             '09', 'SEP',
                             '10', 'OCT',
                             '11', 'NOV',
                             '12', 'DIC')
                 INTO tmes
                 FROM DUAL;
            END IF;

            -- TEXTO := TO_CHAR(LIB.FVALMOV,'DDMONYY')
            IF lib.cmovimi = 0 THEN
               texto := TO_CHAR(lib.fcontab, 'DD') || tmes || TO_CHAR(lib.fcontab, 'YY')
                        || '  '
                               /*                  TO_CHAR (lib.fvalmov, 'DD')
                                              || tmes
                                              || TO_CHAR (lib.fvalmov, 'YY')
                                              || '  '
                                              || RPAD (concepto, 15)
                                              || ' '
                                              || LPAD (TO_CHAR (null, 'FM999G999G990D00'), 14) */
                        || RPAD(concepto, 30) || ' '
                        || LPAD(TO_CHAR(NVL(importe, 0) * signo, 'FM999G990D00'), 18);
            ELSE
               IF (lib.cmovimi IN(47, 53)) THEN
                  texto := TO_CHAR(lib.fvalmov, 'DD') || tmes || TO_CHAR(lib.fvalmov, 'YY')
                           || '  ' || RPAD(concepto, 15) || ' '
                           || LPAD(TO_CHAR(lib.imovimi, 'FM999G999G990D00'), 14) || ' '
                           || LPAD(TO_CHAR(NVL(importe, 0) * signo, 'FM999G990D00'), 18);
               ELSE
                  texto := TO_CHAR(lib.fcontab, 'DD') || tmes || TO_CHAR(lib.fcontab, 'YY')
                           || '  ' || RPAD(concepto, 15) || ' '
                           || LPAD(TO_CHAR(lib.imovimi, 'FM999G999G990D00'), 14) || ' '
                           || LPAD(TO_CHAR(NVL(importe, 0) * signo, 'FM999G990D00'), 18);
               END IF;
            END IF;

            contalin := contalin + 1;

            --          IF entrada = 0 AND pfreimp IS NOT NULL
            --          THEN
            --             UPDATE implibreta
            --                SET npagactiva = lib.npagina,
            --                    nultlinimp = lib.nlinea
            --              WHERE sesion = USERENV ('SESSIONID');
            --          END IF;

            --         entrada := 1;
            INSERT INTO detimplibreta
                        (sesion, sseguro, fcontab, nnumlin, nidlin,
                         cagrup, nlinpag, nposcol, texto)
                 VALUES (USERENV('SESSIONID'), psseguro, lib.fcontab, lib.nnumlin, contalin,
                         'DAT', contalin, 1, texto);
         --DBMS_OUTPUT.put_line(texto);
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line('ERROR IMPRESION_LIBRETA: ' || SQLERRM);
         p_tab_error(f_sysdate, f_user, 'IMPRESION_LIBRETA.generar_pla_pensions', v_traza,
                     'psSeguro =' || psseguro || ' pfreimp=' || pfreimp, SQLERRM);
         RAISE;
   END;

   --
   --
   --
   FUNCTION guardar(
      psseguro IN NUMBER,
      psesion IN NUMBER,
      pcodlin IN NUMBER,
      ppagina IN NUMBER,
      plinea IN NUMBER)
      RETURN NUMBER IS
      v_traza        tab_error.ntraza%TYPE;
   BEGIN
-- Esta función deja las lineas del ctaseguro como impresas segun los parametros enviados.
      v_traza := 1;

      UPDATE ctaseguro_libreta
         SET fimpres = f_sysdate,
             npagina = ppagina,
             nlinea = plinea,
             sreimpre = DECODE(sreimpre, NULL, 0, NVL(sreimpre, 0) + 1)
       WHERE sseguro = psseguro
         AND fimpres IS NULL
         AND nnumlin <= pcodlin;

      v_traza := 2;

      UPDATE seguros
         SET npagina = ppagina,
             nlinea = plinea
       WHERE sseguro = psseguro;

      --- También eliminamos el detalle que se envia al applet para que no quede basura.
      v_traza := 3;

      DELETE      detimplibreta
            WHERE sesion = psesion;

      v_traza := 4;

      DELETE      implibreta
            WHERE sesion = psesion;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'IMPRESION_LIBRETA.guardar', 1,
                     'psSeguro =' || psseguro || ' psesion=' || psesion || ' pcodlin='
                     || pcodlin || ' ppagina=' || ppagina || ' plinea=' || plinea,
                     SQLERRM);
         ROLLBACK;
         RETURN -1;
   END;

   -- Determina quin producte s'ha de cridar
   FUNCTION generar(psseguro IN NUMBER, pfreimp IN DATE DEFAULT NULL, psesion OUT NUMBER)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      exnomovimientos EXCEPTION;
      exnoreimprimir EXCEPTION;
      v_error        literales.slitera%TYPE;
      v_existe       BOOLEAN;
      v_traza        tab_error.ntraza%TYPE;
      v_diccionari   tt_diccionari;
   BEGIN
      v_traza := 1;
      psesion := USERENV('SESSIONID');
      -- Esborra les taules IMPLIBRETA i DETIMPLIBRETA
      esborrartaulestemporals;
      -- Inserta a IMPLIBRETA
      insertcapcalera(psseguro);
      -- Obtenir l'idioma d'impressió
      v_traza := 2;
      --g_cidioma := NVL(F_IDIOMASEGURO(psSeguro),1);
      g_cidioma := 2;   -- Sempre en Espanyol
-- --------------------------------------------------------------
-- Validem la reimpressió
-- --------------------------------------------------------------
-- Si el pfreimp no es nulo es que estamos solicitando una reimpresion
-- y tenemos que comprobar que existen movimientos para la fecha solicitada (pfreimp) y que
-- todos los movimientos iguales o mayores a la fecha solicitada (pfreimp) esten impresos.
      v_traza := 3;

      IF pfreimp IS NOT NULL THEN
         v_existe := FALSE;

         FOR rexisten IN (SELECT 1
                            FROM ctaseguro_libreta
                           WHERE sseguro = psseguro
                             AND TRUNC(fcontab) = TRUNC(pfreimp)
                             AND ROWNUM = 1) LOOP
            v_existe := TRUE;
         END LOOP;

         IF NOT v_existe THEN
            RAISE exnomovimientos;
         END IF;

         -- Se busca si existe alguna linea de libreta no impresa desde la fecha solicitda (pfreimp)
         FOR rexisten IN (SELECT COUNT(1)
                            FROM ctaseguro_libreta
                           WHERE sseguro = psseguro
                             AND TRUNC(fcontab) >= TRUNC(pfreimp)
                             AND TRUNC(fimpres) IS NULL
                             AND ROWNUM = 1) LOOP
            -- Existen movimientos sin imprimir con lo que no podemos reimprimir
            RAISE exnoreimprimir;
         END LOOP;
      END IF;

-- --------------------------------------------------------------
-- Detectem si el producte es un Pla de Pensions o Ahorro Seguro
-- --------------------------------------------------------------
      v_traza := 4;

      -- Ini bug 16790 - SRA - 02/02/2011
      FOR rproducto IN (SELECT p.cramo, p.cagrpro, s.sproduc
                          FROM seguros s JOIN productos p ON s.sproduc = p.sproduc
                         WHERE s.sseguro = psseguro) LOOP
         -- Fin bug 16790 - SRA - 02/02/2011
         CASE
            WHEN rproducto.cagrpro = 11 THEN   -- Pla pensions
               generar_pla_pensions(psseguro, pfreimp);
            WHEN rproducto.cagrpro IN(2, 10) THEN   -- Vida Estalvi / Vida Ahorro
               -- Omplim el diccionari amb els paràmetres de substitució que utilitzarem a POR, PAD i CAB
               v_traza := 40;
               v_diccionari := omplirdiccionari(psseguro, pfreimp);
               -- POR
               v_traza := 41;
               inserir
                  (psseguro, 'POR',
                   f_replace_parameters
                                (castlineastodetall(f_parlibretatextdet('POR',
                                                                        rproducto.sproduc,
                                                                        g_cidioma),
                                                    -100),
                                 v_diccionari));
               -- PAD
               v_traza := 43;
               inserir
                  (psseguro, 'PAD',
                   f_replace_parameters
                                (castlineastodetall(f_parlibretatextdet('PAD',
                                                                        rproducto.sproduc,
                                                                        g_cidioma),
                                                    -10),
                                 v_diccionari));
               -- CAB
               v_traza := 44;
               inserir
                  (psseguro, 'CAB',
                   f_replace_parameters
                                (castlineastodetall(f_parlibretatextdet('CAB',
                                                                        rproducto.sproduc,
                                                                        g_cidioma),
                                                    -1),
                                 v_diccionari));
               -- DAT
               v_traza := 45;
               generar_dat(psseguro, rproducto.cagrpro, rproducto.cramo, rproducto.sproduc);
            WHEN rproducto.cagrpro = 21 THEN   -- Unit Linked
               -- Omplim el diccionari amb els paràmetres de substitució que utilitzarem a POR, PAD i CAB
               v_traza := 40;
               v_diccionari := omplirdiccionari(psseguro, pfreimp);
               -- POR
               v_traza := 41;
               inserir
                  (psseguro, 'POR',
                   f_replace_parameters
                                (castlineastodetall(f_parlibretatextdet('POR',
                                                                        rproducto.sproduc,
                                                                        g_cidioma),
                                                    -100),
                                 v_diccionari));
               -- PAD
               v_traza := 43;
               inserir
                  (psseguro, 'PAD',
                   f_replace_parameters
                                (castlineastodetall(f_parlibretatextdet('PAD',
                                                                        rproducto.sproduc,
                                                                        g_cidioma),
                                                    -10),
                                 v_diccionari));
               -- CAB
               v_traza := 44;
               inserir
                  (psseguro, 'CAB',
                   f_replace_parameters
                                (castlineastodetall(f_parlibretatextdet('CAB',
                                                                        rproducto.sproduc,
                                                                        g_cidioma),
                                                    -1),
                                 v_diccionari));
               -- DAT
               v_traza := 45;
               generar_dat_ulk(psseguro, rproducto.cagrpro, rproducto.cramo,
                               rproducto.sproduc);
            ELSE
               NULL;
         END CASE;

         EXIT;
      END LOOP;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN exnomovimientos THEN
         p_tab_error(f_sysdate, f_user, 'IMPRESION_LIBRETA.generar', 98,
                     'parametros: psSeguro =' || psseguro || ' pfReimp=' || pfreimp,
                     'No hay movimientos para el día seleccionado');
         ROLLBACK;
         RETURN -98;
      WHEN exnoreimprimir THEN
         p_tab_error(f_sysdate, f_user, 'IMPRESION_LIBRETA.generar', 99,
                     'parametros: psSeguro =' || psseguro || ' pfReimp=' || pfreimp,
                     'Existen movimientos sin imprimir con lo que no podemos reimprimir');
         ROLLBACK;
         RETURN -99;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'IMPRESION_LIBRETA.generar', v_traza,
                     'parametros: psSeguro =' || psseguro || ' pfReimp=' || pfreimp, SQLERRM);
         ROLLBACK;
         RETURN -1;
   END;

   --
   --  Visualizar
   --    Per cridar des de TF. Torna un cursor per mostrar la pàgina d'una llibreta
   --    Retorna 0 si tot és correcte o NULL si hi ha hagut un error
   --
   --  Paràmetres
   --    psSeguro  Identificador de la pòlissa
   --    pLibreta  Número de llibreta a mostrar
   --    pPagina   Número de pàgina a mostrar
   --    pCursor   Cursor amb les dades a mostrar
   --        Tipo    'CAB' o 'DAT' segons és la capçalera o les linies
   --        Linia   Número de linia dins de la cap o les linies
   --        Color   0: N/A, 1: Impresa, 2:Pendent imprimir
   --        Text    Text de la linia
   --        Nnumlin Número de linia respecte a tota la pòlissa
   --
   FUNCTION visualizar(
      psseguro IN seguros.sseguro%TYPE,
      plibreta IN NUMBER,
      ppagina IN NUMBER,
      pcursor OUT t_cursor)
      RETURN NUMBER IS
      v_sesion       implibreta.sesion%TYPE;
      v_error        literales.slitera%TYPE;
      v_traza        tab_error.ntraza%TYPE;
      k_linies_cap CONSTANT NUMBER(2) := 2;
      k_pagines_llibreta CONSTANT NUMBER(4) := 10;
      k_verd CONSTANT NUMBER(1) := 1;
      k_vermell CONSTANT NUMBER(1) := 2;
      k_blanc CONSTANT NUMBER(1) := 0;
      v_i            PLS_INTEGER;
      p_agrpro       NUMBER;
      p_sproduc      NUMBER;
   BEGIN
      -- Obtenemos la agrupación del producto
-- Ini bug 16790 - SRA - 02/02/2011
      SELECT p.cagrpro, p.sproduc
        INTO p_agrpro, p_sproduc
        FROM seguros s JOIN productos p ON s.sproduc = p.sproduc
       WHERE s.sseguro = psseguro;

-- Fin bug 16790 - SRA - 02/02/2011
      v_traza := 1;

      -- Aquest troç de codi es per evitar tornar a omplir la taula temporal si ja s'ha omplert anteriorment a la mateixa sessió
      IF g_sesionseguro.EXISTS(psseguro) THEN
         v_sesion := g_sesionseguro(psseguro);
      ELSE
         v_error := impresion_libreta.generar(psseguro, NULL, v_sesion);

         IF v_error <> 0 THEN
            RETURN NULL;
         END IF;

         -- Si estava la mateixa v_sesion asignada a un altre psSeguro l'esborrem, ja no el tindrà
         v_i := g_sesionseguro.FIRST;

         WHILE v_i IS NOT NULL LOOP
            IF g_sesionseguro(psseguro) = v_sesion THEN
               esborrartaulestemporals(v_sesion);
               g_sesionseguro.DELETE(v_sesion);
            END IF;

            v_i := g_sesionseguro.NEXT(v_i);
         END LOOP;

         -- Guardem la relació psSeguro - v_sesion
         g_sesionseguro(psseguro) := v_sesion;
      END IF;

      v_traza := 2;

      IF (p_agrpro <> 21) THEN   --> Ahorro
         OPEN pcursor FOR
            SELECT   'DAT' tipo, linia, DECODE(sintbatch, NULL, k_vermell, k_verd) color,
                     texto text, nnumlin
                FROM (SELECT cl.sintbatch, LPAD(' ', d.nposcol - 1) || d.texto texto,
                             d.nnumlin, MOD(d.nnumlin - 1, c.nlinpag - k_linies_cap) + 1 linia,
                             MOD(TRUNC((d.nnumlin - 1) /(c.nlinpag - k_linies_cap)),
                                 k_pagines_llibreta)
                             + 1 pagina,
                             TRUNC((d.nnumlin - 1) /(c.nlinpag - k_linies_cap)
                                   / k_pagines_llibreta)
                             + 1 llibreta
                        FROM implibreta c, detimplibreta d, ctaseguro_libreta cl
                       WHERE c.sesion = v_sesion
                         AND c.sesion = d.sesion
                         AND d.sseguro = cl.sseguro
                         AND d.nnumlin = cl.nnumlin
                         AND d.cagrup = 'DAT')
               WHERE pagina = ppagina
                 AND llibreta = plibreta
            UNION ALL
            SELECT   'CAB', -d.nnumlin, k_blanc, LPAD(' ', d.nposcol - 1) || d.texto texto,
                     -d.nnumlin
                FROM detimplibreta d
               WHERE d.sesion = v_sesion
                 AND d.cagrup = 'CAB'
            ORDER BY 1, 2;
      ELSE   -- Si es Unit Linked (excepto Ibex 35 Garantizado)
         OPEN pcursor FOR
            SELECT *
              FROM (SELECT ROWNUM lini, tipo, linia, color, text, nnumlin, x.sesion,
                           MOD(TRUNC((ROWNUM - 1) /(k.nlinpag - 2)), 10) + 1 pagina,
                           TRUNC((ROWNUM - 1) /(k.nlinpag - 2) / 10) + 1 llibreta
                      FROM (SELECT   'DAT' tipo, linia, DECODE(sintbatch, NULL, 2, 0) color,
                                     texto text, nnumlin, sesion
                                FROM (SELECT cl.sintbatch,
                                             LPAD(' ', d.nposcol - 1) || d.texto texto,
                                             d.nnumlin,
                                             MOD(d.nnumlin - 1, c.nlinpag - 2) + 1 linia,
                                             MOD(TRUNC((d.nnumlin - 1)
                                                       /(c.nlinpag - 2)),
                                                 10)
                                             + 1 pagina,
                                             TRUNC((d.nnumlin - 1) /(c.nlinpag - 2)
                                                   / 10)
                                             + 1 llibreta,
                                             c.sesion
                                        FROM implibreta c, detimplibreta d,
                                             ctaseguro_libreta cl
                                       WHERE c.sesion = v_sesion
                                         AND c.sesion = d.sesion
                                         AND d.sseguro = cl.sseguro
                                         AND d.nnumlin = cl.nnumlin
                                         AND d.cagrup = 'DAT')
                               WHERE 1 = 1
                            UNION ALL
                            SELECT   'CAB', -d.nnumlin, 0,
                                     LPAD(' ', d.nposcol - 1) || d.texto texto, -d.nnumlin,
                                     d.sesion
                                FROM detimplibreta d
                               WHERE d.sesion = v_sesion
                                 AND d.cagrup = 'CAB'
                            ORDER BY tipo, nnumlin) x
                           JOIN
                           implibreta k ON(x.sesion = k.sesion)
                           )
             WHERE pagina = ppagina
               AND llibreta = plibreta;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG -21546_108724- 08/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF pcursor%ISOPEN THEN
            CLOSE pcursor;
         END IF;

         p_tab_error(f_sysdate, f_user, 'IMPRESION_LIBRETA.Visualizar', v_traza,
                     'psSeguro =' || psseguro || ' pLibreta=' || plibreta || ' pPagina='
                     || ppagina,
                     SQLERRM);
         ROLLBACK;
         RETURN NULL;
   END;

   --
   --  Visualizar_BorrarTablas
   --    Per cridar des de TF per esborrar les taules temporals.
   --    Retorna 0 si tot és correcte o NULL si hi ha hagut un error
   --
   --  Paràmetres
   --    psSeguro  Identificador de la pòlissa
   --
   FUNCTION visualizar_borrartablas(psseguro IN seguros.sseguro%TYPE)
      RETURN NUMBER IS
      v_traza        tab_error.ntraza%TYPE;
      v_sesion       implibreta.sesion%TYPE;
   BEGIN
      IF g_sesionseguro.EXISTS(psseguro) THEN
         v_traza := 1;
         -- EsborrarTaulesTemporals és una Autonomous_Transaction i fa un commit després d'esborrar les taules
         esborrartaulestemporals(g_sesionseguro(psseguro));
         v_traza := 2;
         g_sesionseguro.DELETE(psseguro);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'IMPRESION_LIBRETA.Visualizar_BorrarTablas', v_traza,
                     'psSeguro =' || psseguro, SQLERRM);
         ROLLBACK;
         RETURN NULL;
   END;

   --
   --  Lineas_Pendientes
   --    Torna el nombre de línies pendent d'imprimir d'una llibreta
   --    En cas d'error torna NULL
   --
   FUNCTION f_lineas_pendientes(psseguro IN seguros.sseguro%TYPE)
      RETURN NUMBER IS
      v_lineas       NUMBER;
   BEGIN
      SELECT COUNT(1)
        INTO v_lineas
        FROM (SELECT c.cmovimi, c.fvalmov,
                     RANK() OVER(PARTITION BY c.cmovimi, c.fvalmov ORDER BY c.fvalmov,
                      c.nnumlin DESC) r
                FROM seguros s, ctaseguro c, ctaseguro_libreta cl
               WHERE s.sseguro = psseguro
                 AND c.sseguro = s.sseguro
                 AND cl.sseguro = c.sseguro
                 AND TRUNC(cl.fcontab) = TRUNC(c.fcontab)
                 AND cl.nnumlin = c.nnumlin
                 -- Si cmovimi = 0
                 --    només agafar final de mes + cmovanu = 0
                 -- També agafar si dia + mes de fecfecto es dia+mes de fvalmov però quan fvalmov = fefecto
                 AND(c.cmovimi <> 0
                     OR(c.cmovanu = 0
                        AND LAST_DAY(c.fvalmov) = c.fvalmov)
                     OR(TO_CHAR(s.fefecto, 'MMDD') = TO_CHAR(c.fvalmov, 'MMDD')
                        AND TRUNC(s.fefecto) <> TRUNC(c.fvalmov)))
                 -- Limitem a les línies no impresses
                 AND cl.nlinea IS NULL
                 AND cl.npagina IS NULL) x
       -- Per cmovimi=0 a final de mes eliminem les linies amb el mateix fvalmov excepte la última
      WHERE  r = 1
          OR LAST_DAY(fvalmov) <> fvalmov
          OR cmovimi <> 0;

      RETURN v_lineas;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'IMPRESION_LIBRETA.Lineas_Pendientes', 1,
                     'psSeguro =' || psseguro, SQLERRM);
         RETURN NULL;
   END;

   -- **************  Les funcions mostrar només són per testing
   --
   --  Procediments per mostrar les dades generades
   --
   PROCEDURE mostrar(psesion IN NUMBER, pcagrup IN VARCHAR2) IS
   BEGIN
      --DBMS_OUTPUT.put_line('.');
      FOR r IN (SELECT   x.r, d.texto
                    FROM (SELECT nlinpag, LPAD(' ', nposcol - 1) || texto texto
                            FROM detimplibreta d
                           WHERE d.sesion = psesion
                             AND cagrup = pcagrup) d
                         RIGHT JOIN
                         (SELECT ROWNUM r
                            FROM seguros
                           WHERE ROWNUM <= 20) x   -- Obtenim 20 linies
                                                ON(d.nlinpag = x.r)
                         JOIN
                         (SELECT MAX(nlinpag) m
                            FROM detimplibreta d
                           WHERE d.sesion = psesion
                             AND cagrup = pcagrup) m ON(x.r <= m.m)
                ORDER BY x.r) LOOP
         --DBMS_OUTPUT.put_line(pcagrup || ' ' || LPAD(r.r, 2) || ' ' || r.texto);
         NULL;
      END LOOP;
   END;

   PROCEDURE mostrar(psesion IN NUMBER) IS
   BEGIN
      --DBMS_OUTPUT.put_line(LPAD('-', 80, '-'));
      FOR r IN (SELECT sseguro, nlinpag, ncarlin, npagactiva, nultlinimp
                  FROM implibreta
                 WHERE sesion = psesion) LOOP
         --DBMS_OUTPUT.put_line('Dades pSesion=' || psesion || ' sSeguro=' || r.sseguro);
         --DBMS_OUTPUT.put_line('Tamany pàgina: nlinpag=' || r.nlinpag || ' ncarlin='
         --                     || r.ncarlin);
         --DBMS_OUTPUT.put_line('Impressió : npagactiva=' || r.npagactiva || ' nultlinimp='
         --                     || r.nultlinimp);
         NULL;
      END LOOP;

      --DBMS_OUTPUT.put_line(LPAD('-', 80, '-'));
      mostrar(psesion, 'POR');
      mostrar(psesion, 'PAD');
      mostrar(psesion, 'CAB');
      mostrar(psesion, 'DAT');
   --DBMS_OUTPUT.put_line(LPAD('-', 80, '-'));
   END;
END;

/

  GRANT EXECUTE ON "AXIS"."IMPRESION_LIBRETA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."IMPRESION_LIBRETA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."IMPRESION_LIBRETA" TO "PROGRAMADORESCSI";
