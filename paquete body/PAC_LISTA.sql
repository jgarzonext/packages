--------------------------------------------------------
--  DDL for Package Body PAC_LISTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_LISTA" IS
/******************************************************************************
   NOM:       pac_lista

   REVISIONS:
   Ver        Fecha       Autor  Descripción
   ---------  ----------  -----  ------------------------------------
   1.0        06/07/2009  DCT    0010612: CRE - Error en la generació de pagaments automàtics.
                                 Canviar vista personas por tablas personas y añadir filtro de visión de agente
   2.0        10/10/2012  JLTS   0023869: En el Select del procedimiento query que realiza : ELSIF SUBSTR(codi_consulta, 1, 7) = 'CAGENTE' THEN
                                 se cambia contratosage por redcomercial
******************************************************************************/
   PROCEDURE QUERY(resultset IN OUT lista_ref) IS
   BEGIN
      IF codi_consulta = 'CSUBCOD' THEN
         OPEN resultset FOR
            SELECT csubcod codi, tsubcod texte, tsubcod || csubcod busqueda
              FROM subcodigo
             WHERE cidioma = var_idioma
               AND(UPPER(tsubcod || csubcod) LIKE UPPER(condicion)
                   OR condicion IS NULL);
      ELSIF codi_consulta = 'CESPECI' THEN
         OPEN resultset FOR
            SELECT cespeci codi, tespeci texte, tespeci || cespeci busqueda
              FROM especific
             WHERE cidioma = var_idioma
               AND(UPPER(tespeci || cespeci) LIKE UPPER(condicion)
                   OR condicion IS NULL);
      ELSIF codi_consulta = 'CCIPSAP' THEN
         OPEN resultset FOR
            SELECT ccipsap codi, tcipsap texte, tcipsap || ccipsap busqueda
              FROM cipsap
             WHERE cidioma = var_idioma
               AND(UPPER(tcipsap || ccipsap) LIKE UPPER(condicion)
                   OR condicion IS NULL);
      ELSIF codi_consulta = 'CBAREMO' THEN
         OPEN resultset FOR
            SELECT   d.cbaremo codi, tespeci || '-' || tbaremo texte,
                     tespeci || tbaremo || d.cbaremo busqueda
                FROM desbaremo d, codbaremo c, desespeci t
               WHERE d.cidioma = var_idioma
                 AND d.cidioma = t.cidioma
                 AND c.cespeci = t.cespeci
                 AND d.cbaremo = c.cbaremo
                 AND(UPPER(tespeci || tbaremo || d.cbaremo) LIKE UPPER(condicion)
                     OR condicion IS NULL)
            ORDER BY t.cespeci, d.cbaremo;
      ELSIF codi_consulta = 'NIF_PROVE' THEN
         OPEN resultset FOR
            SELECT r.cprovee codi,
                   LPAD(e.nnumnif, 10, ' ') || ' ' || e.tnombre || ' ' || e.tapelli texte,
                   r.cprovee || e.tnombre || ' ' || e.tapelli busqueda
              FROM personas e, proveedores r
             WHERE e.sperson = r.sperson
               AND(r.cprovee || UPPER(e.tnombre || ' ' || e.tapelli) LIKE UPPER(condicion)
                   OR condicion IS NULL);
      ELSIF codi_consulta = 'SPROFES' THEN
         OPEN resultset FOR
            SELECT e.nnumnif codi,
                   LPAD(e.nnumnif, 10, ' ') || ' ' || e.tnombre || ' ' || e.tapelli texte,
                   e.nnumnif || e.tnombre || ' ' || e.tapelli busqueda
              FROM personas e, profesionales r
             WHERE e.sperson = r.sperson
               AND r.cactpro IN(1, 3)
               AND(e.nnumnif = condicion
                   OR e.nnumnif || UPPER(e.tnombre || ' ' || e.tapelli) LIKE UPPER(condicion)
                   OR condicion IS NULL);
      ELSIF codi_consulta = 'SPEREMP' THEN
         OPEN resultset FOR
            SELECT e.nnumnif codi,
                   LPAD(e.nnumnif, 10, ' ') || ' ' || e.tnombre || ' ' || e.tapelli texte,
                   e.nnumnif || e.tnombre || ' ' || e.tapelli busqueda
              FROM personas e, profesionales r
             WHERE e.sperson = r.sperson
               AND r.cactpro IN(14)
               AND(e.nnumnif = condicion
                   OR e.nnumnif || UPPER(e.tnombre || ' ' || e.tapelli) LIKE UPPER(condicion)
                   OR condicion IS NULL);
      ELSIF SUBSTR(codi_consulta, 1, 7) = 'CPOBLAC' THEN
         OPEN resultset FOR
            SELECT cpoblac codi, tpoblac texte, tpoblac || cpoblac busqueda
              FROM poblaciones
             WHERE (UPPER(tpoblac || cpoblac) LIKE UPPER(condicion)
                    OR condicion IS NULL)
               AND cprovin = TO_NUMBER(SUBSTR(codi_consulta, 8, 3));
      ELSIF codi_consulta = 'SPERSON' THEN
         OPEN resultset FOR
            SELECT nnumnif codi,
                   LPAD(nnumnif, 10, ' ') || ' ' || tnombre || ' ' || tapelli texte,
                   nnumnif || tnombre || ' ' || tapelli busqueda
              FROM personas
             WHERE (UPPER(tapelli || nnumnif) LIKE UPPER(condicion)
                    OR condicion IS NULL);
      ELSIF codi_consulta = 'SPERMED' THEN
         OPEN resultset FOR
            SELECT nnumnif codi,
                   tnombre || ' ' || tapelli || '  ' || LPAD(nhismed, 10, ' ') texte,
                   nnumnif || tnombre || ' ' || tapelli busqueda
              FROM hismedica h, personas p
             WHERE (tbuscar LIKE UPPER(condicion)
                    OR condicion IS NULL)
               AND h.sperson = p.sperson;
      ELSIF codi_consulta = 'SCLAGEN' THEN
         OPEN resultset FOR
            SELECT   sclagen codi, tclatit texte, tclatit || sclagen busqueda
                FROM clausugen
               WHERE cidioma = var_idioma
                 AND(UPPER(tclatit || sclagen) LIKE UPPER(condicion)
                     OR condicion IS NULL)
            ORDER BY codi;
      ELSIF codi_consulta = 'SCLABEN' THEN
         OPEN resultset FOR
            SELECT   sclaben codi, tclaben texte, tclaben || sclaben busqueda
                FROM clausuben
               WHERE cidioma = var_idioma
                 AND(UPPER(tclaben || sclaben) LIKE UPPER(condicion)
                     OR condicion IS NULL)
            ORDER BY codi;
      ELSIF SUBSTR(codi_consulta, 1, 7) = 'CAGENTE' THEN
         OPEN resultset FOR
            SELECT   a.cagente codi, RTRIM(p.tnombre) || ' ' || p.tapelli texte,
                     p.tbuscar || a.cagente busqueda
                FROM personas p, agentes a, redcomercial r, codiram c
               WHERE (UPPER(p.tbuscar || a.cagente) LIKE UPPER(condicion)
                      OR condicion IS NULL)
                 AND p.sperson = a.sperson
                 AND a.cagente = r.cagente
                 AND r.cempres = c.cempres
                 AND r.fmovfin IS NULL
                 AND c.cramo = SUBSTR(codi_consulta, 8, 2)
            ORDER BY a.cagente;
      ELSIF SUBSTR(codi_consulta, 1, 7) = 'SCLAPRO' THEN
         OPEN resultset FOR
            SELECT DISTINCT g.sclagen codi, g.tclatit texte, g.tclatit || g.sclagen busqueda
                       FROM clausugen g, clausupro p
                      WHERE g.cidioma = var_idioma
                        AND(UPPER(g.tclatit || g.sclagen) LIKE UPPER(condicion)
                            OR condicion IS NULL)
                        AND g.sclagen = p.sclagen
                        AND p.cramo = SUBSTR(codi_consulta, 8, 2)
                   ORDER BY codi;
      ELSIF codi_consulta = 'CDOCUMENT' THEN
         OPEN resultset FOR
            SELECT   cdocument codi, tdocument texte, tdocument || cdocument busqueda
                FROM document
               WHERE cidioma = var_idioma
                 AND fbaja IS NULL
                 AND(UPPER(tdocument || cdocument) LIKE UPPER(condicion)
                     OR condicion IS NULL)
            ORDER BY codi;
      ELSIF codi_consulta = 'CMOTMOV' THEN
         OPEN resultset FOR
            SELECT   cmotmov codi, tmotmov texte, tmotmov || cmotmov busqueda
                FROM motmovseg
               WHERE cidioma = var_idioma
                 AND(UPPER(tmotmov || cmotmov) LIKE UPPER(condicion)
                     OR condicion IS NULL)
            ORDER BY codi;
      ELSIF SUBSTR(codi_consulta, 1, 7) = 'CGARANT' THEN
         OPEN resultset FOR
            SELECT   g.cgarant codi, g.tgarant texte, g.tgarant || g.cgarant busqueda
                FROM garangen g, garanpro gp
               WHERE g.cidioma = var_idioma
                 AND(UPPER(g.tgarant || g.cgarant) LIKE UPPER(condicion)
                     OR condicion IS NULL)
                 AND g.cgarant = gp.cgarant
                 AND gp.sproduc = SUBSTR(codi_consulta, 8, 6)
                 AND gp.cactivi = SUBSTR(codi_consulta, 14, 4)
            ORDER BY codi;
      ELSIF SUBSTR(codi_consulta, 1, 7) = 'GARANTR' THEN
         OPEN resultset FOR
            SELECT DISTINCT g.cgarant codi, g.tgarant texte, g.tgarant || g.cgarant busqueda
                       FROM garangen g, garanpro gp
                      WHERE g.cidioma = var_idioma
                        AND(UPPER(g.tgarant || g.cgarant) LIKE UPPER(condicion)
                            OR condicion IS NULL)
                        AND g.cgarant = gp.cgarant
                        AND gp.cramo = SUBSTR(codi_consulta, 8, 2)
                   ORDER BY codi;
      ELSIF SUBSTR(codi_consulta, 1, 7) = 'CCAUSIN' THEN
         OPEN resultset FOR
            SELECT   c.ccausin codi, c.tcausin texte, c.tcausin || c.ccausin busqueda
                FROM causasini c, causasingaran cg
               WHERE c.cidioma = var_idioma
                 AND(UPPER(c.tcausin || c.ccausin) LIKE UPPER(condicion)
                     OR condicion IS NULL)
                 AND c.ccausin = cg.ccausin
                 AND cg.cgarant = SUBSTR(codi_consulta, 8, 4)
            ORDER BY codi;
      ELSIF SUBSTR(codi_consulta, 1, 7) = 'CACTIVI' THEN
         OPEN resultset FOR
            SELECT   a.cactivi codi, a.tactivi texte, a.tactivi || a.cactivi busqueda
                FROM activisegu a, activiprod ap
               WHERE a.cidioma = var_idioma
                 AND(UPPER(a.tactivi || a.cactivi) LIKE UPPER(condicion)
                     OR condicion IS NULL)
                 AND a.cactivi = ap.cactivi
                 AND ap.cramo = SUBSTR(codi_consulta, 8, 2)
                 AND ap.cmodali = SUBSTR(codi_consulta, 10, 2)
                 AND ap.ctipseg = SUBSTR(codi_consulta, 12, 2)
                 AND ap.ccolect = SUBSTR(codi_consulta, 14, 2)
            ORDER BY codi;
      ELSIF codi_consulta IN('CVINCLE', 'CVINCLE_2') THEN
         OPEN resultset FOR
            SELECT   cvinclo codi, tvinclo texte, tvinclo || cvinclo busqueda
                FROM vinculos
               WHERE cidioma = var_idioma
                 AND(UPPER(tvinclo || cvinclo) LIKE UPPER(condicion)
                     OR condicion IS NULL)
            ORDER BY codi;
      END IF;
   END QUERY;

------------------------------------------------------------------
   PROCEDURE omplir_consulta(camp IN VARCHAR2, pidioma IN NUMBER) IS
   BEGIN
      codi_consulta := camp;
      var_idioma := pidioma;
   END omplir_consulta;

-------------------------------------------------
   PROCEDURE omplir_condicion(valor IN VARCHAR2) IS
   BEGIN
      condicion := valor;
   END omplir_condicion;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_LISTA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_LISTA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_LISTA" TO "PROGRAMADORESCSI";
