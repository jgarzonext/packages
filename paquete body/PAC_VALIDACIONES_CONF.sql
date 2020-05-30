--------------------------------------------------------
--  DDL for Package Body PAC_VALIDACIONES_CONF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_VALIDACIONES_CONF" IS
   /******************************************************************************
      NOMBRE:    pac_validaciones_conf
      PROPÓSITO: Funciones para validaciones

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        02/03/2016  JAE              1. Creación del objeto.

   ******************************************************************************/
   --
   vnnumide         VARCHAR2(50);
   vctipide         NUMBER;
   vctipide_tomador NUMBER;
   vnnumide_tomador VARCHAR2(50);
   vnombre_tomador  VARCHAR2(32000);
   --
   vcontrato     NUMBER;
   vcontrato_pol NUMBER;
   vcontrato_max NUMBER;
   vcontrato_min NUMBER;
   --
   vsumaaseg     NUMBER;
   vsumaaseg_pol NUMBER;
   vsumaaseg_max NUMBER;
   vsumaaseg_min NUMBER;
   --
	vssegpol        NUMBER;
   vrangaseg       NUMBER;
   vrangcont       NUMBER;
   vnumcontr       NUMBER;
   vnumnomcons     NUMBER;
   vnumnomcons_int NUMBER;
   vnum_nom        NUMBER;
   v_crel          NUMBER;
   v_resp_4097     VARCHAR2(200);
   --
   v_aux VARCHAR2(2000);
   --
   CURSOR c_pol_tomador_asegurado(psseguro         NUMBER,
                                  pctipide         NUMBER,
                                  pnnumide         VARCHAR2,
                                  pctipide_tomador NUMBER,
                                  pnnumide_tomador VARCHAR2) IS

      SELECT asegurado.*
        FROM (SELECT a.sseguro,
                     'POL' tabla,
                     s.npoliza
                FROM asegurados   a,
                     per_personas p,
                     seguros      s
               WHERE a.sperson = p.sperson
                 AND p.ctipide = pctipide
                 AND p.nnumide = pnnumide
                 AND a.sseguro = s.sseguro
                 AND a.sseguro NOT IN (psseguro, vssegpol)
              UNION
              SELECT e.sseguro,
                     'EST' tabla,
                     s.npoliza
                FROM estassegurats   e,
                     estper_personas p,
                     estseguros      s
               WHERE e.sperson = p.sperson
                 AND p.ctipide = pctipide
                 AND p.nnumide = pnnumide
                 AND e.sseguro = s.sseguro
                 AND e.sseguro != psseguro) asegurado,
             --
             (SELECT a.sseguro,
                     'POL' tabla,
                     s.npoliza
                FROM tomadores    a,
                     per_personas p,
                     seguros      s
               WHERE a.sperson = p.sperson
                 AND p.ctipide = pctipide_tomador
                 AND p.nnumide = pnnumide_tomador
                 AND a.sseguro = s.sseguro
                 AND a.sseguro NOT IN (psseguro, vssegpol)
              UNION
              SELECT e.sseguro,
                     'EST' tabla,
                     s.npoliza
                FROM tomadores       e,
                     estper_personas p,
                     estseguros      s
               WHERE e.sperson = p.sperson
                 AND p.ctipide = pctipide_tomador
                 AND p.nnumide = pnnumide_tomador
                 AND e.sseguro = s.sseguro
                 AND e.sseguro != psseguro) tomador
       WHERE asegurado.sseguro = tomador.sseguro;
   --
   CURSOR c_pol_asegurados(psseguro NUMBER,
                           pctipide NUMBER,
                           pnnumide VARCHAR2) IS
      SELECT a.sseguro,
             'POL' tabla,
             s.npoliza
        FROM asegurados   a,
             per_personas p,
             seguros      s
       WHERE a.sperson = p.sperson
         AND p.ctipide = pctipide
         AND p.nnumide = pnnumide
         AND a.sseguro = s.sseguro
         AND a.sseguro NOT IN (psseguro, vssegpol)
      UNION
      /*SELECT e.sseguro,
             'EST' tabla,
             s.npoliza
        FROM estassegurats   e,
             estper_personas p,
             estseguros      s
       WHERE e.sperson = p.sperson
         AND p.ctipide = pctipide
         AND p.nnumide = pnnumide
         AND e.sseguro = s.sseguro
         AND e.sseguro != psseguro*/
         SELECT e.sseguro,
             'EST' tabla,
             s.npoliza
        FROM asegurados   e,
             estper_personas p,
             seguros      s
       WHERE e.sperson = p.spereal
         AND p.ctipide = pctipide
         AND p.nnumide = pnnumide
         AND e.sseguro = s.sseguro;
   --
   CURSOR c_pol_tomadores(psseguro NUMBER,
                          pctipide NUMBER,
                          pnnumide VARCHAR2) IS
      SELECT a.sseguro,
             'POL' tabla,
             s.npoliza
        FROM tomadores    a,
             per_personas p,
             seguros      s
       WHERE a.sperson = p.sperson
         AND p.ctipide = pctipide
         AND p.nnumide = pnnumide
         AND a.sseguro = s.sseguro
         AND a.sseguro NOT IN (psseguro, vssegpol)
      UNION
      /*SELECT e.sseguro,
             'EST' tabla,
             s.npoliza
        FROM tomadores       e,
             estper_personas p,
             estseguros      s
       WHERE e.sperson = p.sperson
         AND p.ctipide = pctipide
         AND p.nnumide = pnnumide
         AND e.sseguro = s.sseguro
         AND e.sseguro != psseguro*/
         SELECT e.sseguro,
             'EST' tabla,
             s.npoliza
        FROM tomadores       e,
             estper_personas p,
             seguros      s
       WHERE p.ctipide = pctipide
         and p.nnumide = pnnumide
         and e.sperson = p.spereal
         AND e.sseguro = s.sseguro;
   --
   CURSOR c_pol_contratos(psseguro  NUMBER,
                          pcrespues VARCHAR2) IS
      SELECT p.sseguro,
             'EST' tabla,
             s.npoliza
        FROM estpregunpolseg p,
             estseguros      s
       WHERE p.cpregun = 4097
         AND p.sseguro != psseguro
         AND p.nmovimi = (SELECT MAX(nmovimi)
                            FROM estpregunpolseg p1
                           WHERE p.sseguro = p1.sseguro
                             AND p.cpregun = p1.cpregun)
         AND p.trespue = pcrespues
         AND s.sseguro = p.sseguro
      UNION
      SELECT p.sseguro,
             'EST' tabla,
             s.npoliza
        FROM pregunpolseg p,
             seguros      s
       WHERE p.cpregun = 4097
         AND p.sseguro NOT IN (psseguro, vssegpol)
         AND p.nmovimi = (SELECT MAX(nmovimi)
                            FROM pregunpolseg p1
                           WHERE p.sseguro = p1.sseguro
                             AND p.cpregun = p1.cpregun)
         AND p.trespue = pcrespues
         AND s.sseguro = p.sseguro;
   --
   CURSOR c_pol_contrato_seguro(psseguro  NUMBER,
                                pcrespues VARCHAR2) IS
      SELECT p.sseguro,
             'EST' tabla,
             s.npoliza
        FROM estpregunpolseg p,
             estseguros      s
       WHERE p.cpregun = 4097
         AND p.sseguro = psseguro
         AND p.nmovimi = (SELECT MAX(nmovimi)
                            FROM estpregunpolseg p1
                           WHERE p.sseguro = p1.sseguro
                             AND p.cpregun = p1.cpregun)
         AND p.trespue = pcrespues
         AND s.sseguro = p.sseguro
      UNION
      SELECT p.sseguro,
             'POL' tabla,
             s.npoliza
        FROM pregunpolseg p,
             seguros      s
       WHERE p.cpregun = 4097
         AND p.sseguro = psseguro
         AND p.nmovimi = (SELECT MAX(nmovimi)
                            FROM pregunpolseg p1
                           WHERE p.sseguro = p1.sseguro
                             AND p.cpregun = p1.cpregun)
         AND p.trespue = pcrespues
         AND s.sseguro = p.sseguro;
   --
   /*************************************************************************
      FUNCTION f_get_valor_asegurado: Obtiene el valor asegurado póliza

      param in psseguro : Identificador seguro
      return            : NUMBER
   *************************************************************************/
   FUNCTION f_get_valor_asegurado(psseguro NUMBER,
                                  ptablas  VARCHAR2) RETURN NUMBER IS
      --
      v_valor NUMBER;
      --
   BEGIN
      --
      IF ptablas = 'POL'
      THEN
         --
         SELECT SUM(icapital)
           INTO v_valor
           FROM garanseg g
          WHERE g.sseguro = psseguro
            AND g.ffinefe IS NULL;
         --
      ELSIF ptablas = 'EST'
      THEN
         --
         SELECT SUM(icapital)
           INTO v_valor
           FROM estgaranseg e
          WHERE e.sseguro = psseguro
            AND e.ffinefe IS NULL;
         --
      END IF;
      --
      RETURN v_valor;
      --
   EXCEPTION
      WHEN OTHERS THEN
         --
         RETURN 0;
         --
   END f_get_valor_asegurado;

   --
   /*************************************************************************
      FUNCTION f_get_valor_contrato: Obtiene el valor del contrato

      param in psseguro : Identificador seguro
      return            : NUMBER
   *************************************************************************/
   FUNCTION f_get_valor_contrato(psseguro NUMBER,
                                 ptablas  VARCHAR2) RETURN NUMBER IS
      --
      v_valor NUMBER;
      --
   BEGIN
      --
      IF ptablas = 'POL'
      THEN
         --
         SELECT p.crespue
           INTO v_valor
           FROM pregunseg p
          WHERE p.cpregun = 2883
            AND p.sseguro = psseguro
            AND p.nmovimi = (SELECT MAX(nmovimi)
                               FROM pregunseg p1
                              WHERE p.sseguro = p1.sseguro
                                AND p.nriesgo = p1.nriesgo
                                AND p.cpregun = p1.cpregun);
         --
      ELSIF ptablas = 'EST'
      THEN
         --
         SELECT e.crespue
           INTO v_valor
           FROM estpregunseg e
          WHERE e.cpregun = 2883
            AND e.sseguro = psseguro
            AND e.nmovimi = (SELECT MAX(nmovimi)
                               FROM estpregunseg e1
                              WHERE e.sseguro = e1.sseguro
                                AND e.nriesgo = e1.nriesgo
                                AND e.cpregun = e1.cpregun);
         --
      END IF;
      --
      RETURN v_valor;
      --
   EXCEPTION
      WHEN OTHERS THEN
         --
         RETURN 0;
         --
   END f_get_valor_contrato;

   --
   /*************************************************************************
      FUNCTION f_inicializa: Obtiene Inicializa valores
   *************************************************************************/
   PROCEDURE f_inicializa(psproduc IN NUMBER,
                          psseguro IN NUMBER) IS
   BEGIN
      --
      vnnumide         := NULL;
      vctipide         := NULL;
      vctipide_tomador := NULL;
      vnnumide_tomador := NULL;
      vnombre_tomador  := NULL;
      --
      vcontrato     := NULL;
      vcontrato_pol := NULL;
      vcontrato_max := NULL;
      vcontrato_min := NULL;
      --
      vsumaaseg     := NULL;
      vsumaaseg_pol := NULL;
      vsumaaseg_max := NULL;
      vsumaaseg_min := NULL;
      --
      vrangaseg       := NULL;
      vrangcont       := NULL;
      vnumcontr       := NULL;
      vnumnomcons     := NULL;
      vnumnomcons_int := NULL;
      vnum_nom        := NULL;
      v_crel          := NULL;
      v_resp_4097     := NULL;
      --
      v_aux := NULL;
      --
      vrangaseg := pac_parametros.f_parproducto_n(psproduc => psproduc,
                                                  pcparam => 'RANGO_VR_ASEGU');
      --
      vrangcont := pac_parametros.f_parproducto_n(psproduc => psproduc,
                                                  pcparam => 'RANGO_VR_CONTRATO');
      --
      vnumcontr := pac_parametros.f_parproducto_n(psproduc => psproduc,
                                                  pcparam => 'VAL_NUM_CONTRATO');
      --
      vnumnomcons := pac_parametros.f_parproducto_n(psproduc => psproduc,
                                                    pcparam => 'VAL_NOM_CONSOR');
      --
      vnumnomcons_int := pac_parametros.f_parproducto_n(psproduc => psproduc,
                                                        pcparam => 'VAL_NOMINT_CONSOR');
      --
		--Seguro tablas reales
      SELECT ssegpol
        INTO vssegpol
        FROM estseguros
       WHERE sseguro = psseguro;

      --Identificación del asegurado
      SELECT p.ctipide,
             p.nnumide
        INTO vctipide,
             vnnumide
        FROM estassegurats   e,
             estper_personas p
       WHERE e.sperson = p.sperson
         AND e.sseguro = psseguro;
      --
      --Identificación del tomador
      SELECT p.ctipide,
             p.nnumide,
             d.tnombre1 || ' ' || d.tnombre2 || ' ' || d.tapelli1 || ' ' ||
             d.tapelli2
        INTO vctipide_tomador,
             vnnumide_tomador,
             vnombre_tomador
        FROM esttomadores    e,
             estper_personas p,
             estper_detper   d
       WHERE e.sperson = p.sperson
         AND d.sperson = p.sperson
         AND e.sseguro = psseguro;
      --
      --Número de contrato
      SELECT trespue
        INTO v_resp_4097
        FROM estpregunpolseg s
       WHERE s.cpregun = 4097
         AND s.sseguro = psseguro
         AND s.nmovimi = (SELECT MAX(nmovimi)
                            FROM estpregunpolseg g1
                           WHERE s.sseguro = g1.sseguro
                             AND s.cpregun = g1.cpregun);
      --
      --Valor asegurado máximo - mínimo
      vcontrato_pol := f_get_valor_contrato(psseguro, 'EST');
      vcontrato_max := vcontrato_pol + ((vcontrato_pol * vrangcont) / 100);
      vcontrato_min := vcontrato_pol - ((vcontrato_pol * vrangcont) / 100);
      --
      --Valor asegurado máximo - mínimo
      vsumaaseg_pol := f_get_valor_asegurado(psseguro, 'EST');
      vsumaaseg_max := vsumaaseg_pol + ((vsumaaseg_pol * vrangaseg) / 100);
      vsumaaseg_min := vsumaaseg_pol - ((vsumaaseg_pol * vrangaseg) / 100);
      --
      --Miembro de consorcio
      BEGIN
         --
         SELECT COUNT(*)
           INTO v_crel
           FROM per_personas_rel r,
                esttomadores     t
          WHERE r.ctipper_rel = 3
            AND t.sperson = r.sperson
            AND t.sseguro = psseguro;
         --
      EXCEPTION
         --
         WHEN NO_DATA_FOUND THEN
            --
            v_crel := 0;
            --
      END;
      --
      IF v_crel != 0
      THEN
         --
         vnum_nom := vnumnomcons_int;
         --
      ELSE
         --
         vnum_nom := vnumnomcons;
         --
      END IF;
      --
   EXCEPTION
      WHEN OTHERS THEN
         --
         NULL;
         --
   END f_inicializa;

   /*************************************************************************
      FUNCTION f_duplicidad_riesgo_1: Valida duplicidad de riesgo
      param IN psproduc   : Código del producto
      param IN psseguro   : Número identificativo interno de SEGUROS
      param IN pcidioma   : Código del Idioma
      param OUT ptmensaje : Mensajes de salida
      Devuelve            : 0 => No duplicidad  1 => Duplicidad
   *************************************************************************/
   FUNCTION f_duplicidad_riesgo_1(psproduc  IN NUMBER,
                                  psseguro  IN NUMBER,
                                  pcidioma  IN NUMBER,
                                  ptmensaje IN OUT VARCHAR2) RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_VALIDACIONES_CONF.f_duplicidad_riesgo_1';
      vparam   VARCHAR2(300) := ' psproduc  =' || psproduc ||
                                ' - psseguro=' || psseguro ||
                                ' - pcidioma=' || pcidioma;
      --
   BEGIN
      --
      f_inicializa(psproduc, psseguro);
      --
      IF vctipide IS NULL OR
         vnnumide IS NULL
      THEN
         --
         RETURN 0;
         --
      END IF;
      --
      --Valida asegurados
      FOR c_pol IN c_pol_asegurados(psseguro, vctipide, vnnumide)
      LOOP
         --
         vsumaaseg := f_get_valor_asegurado(c_pol.sseguro, c_pol.tabla);
         --
         IF vsumaaseg BETWEEN vsumaaseg_min AND vsumaaseg_max
         THEN
            --
            v_aux := v_aux || '/' || c_pol.npoliza;
            --
         END IF;
         --
      END LOOP;
      --
      --Duplicado por asegurado y rango del valor asegurado
      IF v_aux IS NOT NULL
      THEN
         --
         ptmensaje := ptmensaje || ' ' || chr(13) || SUBSTR(v_aux, 2) || ': ' ||
                      f_axis_literales(9908871, pcidioma);
         --
         RETURN 1;
         --
      END IF;
      --
      RETURN 0;
      --
   EXCEPTION
      WHEN OTHERS THEN
         --
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         --
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     'ERROR: ' || ptmensaje);
         --
         RETURN 1;
         --
   END f_duplicidad_riesgo_1;

   /*************************************************************************
      FUNCTION f_duplicidad_riesgo_2: Valida duplicidad de riesgo
      param IN psproduc   : Código del producto
      param IN psseguro   : Número identificativo interno de SEGUROS
      param IN pcidioma   : Código del Idioma
      param OUT ptmensaje : Mensajes de salida
      Devuelve            : 0 => No duplicidad  1 => Duplicidad
   *************************************************************************/
   FUNCTION f_duplicidad_riesgo_2(psproduc  IN NUMBER,
                                  psseguro  IN NUMBER,
                                  pcidioma  IN NUMBER,
                                  ptmensaje IN OUT VARCHAR2) RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_VALIDACIONES_CONF.f_duplicidad_riesgo_2';
      vparam   VARCHAR2(300) := ' psproduc  =' || psproduc ||
                                ' - psseguro=' || psseguro ||
                                ' - pcidioma=' || pcidioma;
      --
   BEGIN
      --
      f_inicializa(psproduc, psseguro);
      --
      IF v_resp_4097 IS NULL
      THEN
         --
         RETURN 0;
         --
      END IF;
      --
      --Valida rango de valor de contrato
      FOR c_pol IN c_pol_contratos(psseguro, v_resp_4097)
      LOOP
         --
         vcontrato := f_get_valor_contrato(c_pol.sseguro, c_pol.tabla);
         --
         IF vcontrato BETWEEN vcontrato_min AND vcontrato_max
         THEN
            --
            v_aux := v_aux || '/' || c_pol.npoliza;
            --
         END IF;
         --
      END LOOP;
      --
      --Duplicado por nro. de contrato y valor de contrato
      IF v_aux IS NOT NULL
      THEN
         --
         ptmensaje := ptmensaje || ' ' || chr(13) || SUBSTR(v_aux, 2) || ': ' ||
                      f_axis_literales(9908872, pcidioma);
         --
         RETURN 1;
         --
      END IF;
      --
      RETURN 0;
      --
   EXCEPTION
      WHEN OTHERS THEN
         --
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         --
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     'ERROR: ' || ptmensaje);
         --
         RETURN 1;
         --
   END f_duplicidad_riesgo_2;

   /*************************************************************************
      FUNCTION f_duplicidad_riesgo_3: Valida duplicidad de riesgo
      param IN psproduc   : Código del producto
      param IN psseguro   : Número identificativo interno de SEGUROS
      param IN pcidioma   : Código del Idioma
      param OUT ptmensaje : Mensajes de salida
      Devuelve            : 0 => No duplicidad  1 => Duplicidad
   *************************************************************************/
   FUNCTION f_duplicidad_riesgo_3(psproduc  IN NUMBER,
                                  psseguro  IN NUMBER,
                                  pcidioma  IN NUMBER,
                                  ptmensaje IN OUT VARCHAR2) RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_VALIDACIONES_CONF.f_duplicidad_riesgo_3';
      vparam   VARCHAR2(300) := ' psproduc  =' || psproduc ||
                                ' - psseguro=' || psseguro ||
                                ' - pcidioma=' || pcidioma;
      --
   BEGIN
      --
      f_inicializa(psproduc, psseguro);
      --
      IF vctipide IS NULL OR
         vnnumide IS NULL
      THEN
         --
         RETURN 0;
         --
      END IF;
      --
      --Valida rango de valor de contrato
      FOR c_pol IN c_pol_asegurados(psseguro, vctipide, vnnumide)
      LOOP
         --
         vcontrato := f_get_valor_contrato(c_pol.sseguro, c_pol.tabla);
         --
         IF vcontrato BETWEEN vcontrato_min AND vcontrato_max
         THEN
            --
            v_aux := v_aux || '/' || c_pol.npoliza;
            --
         END IF;
         --
      END LOOP;
      --
      --Duplicado por asegurado y rango del valor contrato
      IF v_aux IS NOT NULL
      THEN
         --
         ptmensaje := ptmensaje || ' ' || chr(13) || SUBSTR(v_aux, 2) || ': ' ||
                      f_axis_literales(9908873, pcidioma);
         --
         RETURN 1;
         --
      END IF;
      --
      RETURN 0;
      --
   EXCEPTION
      WHEN OTHERS THEN
         --
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         --
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     'ERROR: ' || ptmensaje);
         --
         RETURN 1;
         --
   END f_duplicidad_riesgo_3;

   /*************************************************************************
      FUNCTION f_duplicidad_riesgo_4: Valida duplicidad de riesgo
      param IN psproduc   : Código del producto
      param IN psseguro   : Número identificativo interno de SEGUROS
      param IN pcidioma   : Código del Idioma
      param OUT ptmensaje : Mensajes de salida
      Devuelve            : 0 => No duplicidad  1 => Duplicidad
   *************************************************************************/
   FUNCTION f_duplicidad_riesgo_4(psproduc  IN NUMBER,
                                  psseguro  IN NUMBER,
                                  pcidioma  IN NUMBER,
                                  ptmensaje IN OUT VARCHAR2) RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_VALIDACIONES_CONF.f_duplicidad_riesgo_4';
      vparam   VARCHAR2(300) := ' psproduc  =' || psproduc ||
                                ' - psseguro=' || psseguro ||
                                ' - pcidioma=' || pcidioma;
      --
   BEGIN
      --
      f_inicializa(psproduc, psseguro);
      --
      IF v_resp_4097 IS NULL
      THEN
         --
         RETURN 0;
         --
      END IF;
      --
      --Valida rango de valor de contrato
      FOR c_pol IN c_pol_contratos(psseguro, v_resp_4097)
      LOOP
         --
         vsumaaseg := f_get_valor_asegurado(c_pol.sseguro, c_pol.tabla);
         --
         IF vsumaaseg BETWEEN vsumaaseg_min AND vsumaaseg_max
         THEN
            --
            v_aux := v_aux || '/' || c_pol.npoliza;
            --
         END IF;
         --
      END LOOP;
      --
      --Duplicado por tomador, rango del valor asegurado y coincidencia en el nro. de contrato
      IF v_aux IS NOT NULL
      THEN
         --
         ptmensaje := ptmensaje || ' ' || chr(13) || SUBSTR(v_aux, 2) || ': ' ||
                      f_axis_literales(9908866, pcidioma);
         --
         RETURN 1;
         --
      END IF;
      --
      RETURN 0;
      --
   EXCEPTION
      WHEN OTHERS THEN
         --
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         --
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     'ERROR: ' || ptmensaje);
         --
         RETURN 1;
         --
   END f_duplicidad_riesgo_4;

   /*************************************************************************
      FUNCTION f_duplicidad_riesgo_5: Valida duplicidad de riesgo
      param IN psproduc   : Código del producto
      param IN psseguro   : Número identificativo interno de SEGUROS
      param IN pcidioma   : Código del Idioma
      param OUT ptmensaje : Mensajes de salida
      Devuelve            : 0 => No duplicidad  1 => Duplicidad
   *************************************************************************/
   FUNCTION f_duplicidad_riesgo_5(psproduc  IN NUMBER,
                                  psseguro  IN NUMBER,
                                  pcidioma  IN NUMBER,
                                  ptmensaje IN OUT VARCHAR2) RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_VALIDACIONES_CONF.f_duplicidad_riesgo_5';
      vparam   VARCHAR2(300) := ' psproduc  =' || psproduc ||
                                ' - psseguro=' || psseguro ||
                                ' - pcidioma=' || pcidioma;
      --
      vnombre VARCHAR2(32000);
      --
   BEGIN
      --
      f_inicializa(psproduc, psseguro);
      --
      IF v_resp_4097 IS NULL
      THEN
         --
         RETURN 0;
         --
      END IF;
      --
      --Valida rango de valor de contrato
      FOR c_pol IN c_pol_contratos(psseguro, v_resp_4097)
      LOOP
         --
         IF c_pol.tabla = 'EST'
         THEN
            --
            --Consulta miembros de consorcio
            FOR c_miembros IN (SELECT DISTINCT r.sperson_rel
                                 FROM per_personas_rel r,
                                      esttomadores     t,
                                      estper_personas ep
                                WHERE r.ctipper_rel IN (0, 3)
                                  AND t.sperson = ep.sperson
                                  AND ep.spereal = r.sperson
                                  AND t.sseguro = psseguro/*SELECT DISTINCT r.sperson_rel
                                                             FROM per_personas_rel r,
                                                                  esttomadores     t
                                                            WHERE r.ctipper_rel = 3
                                                              AND t.sperson = r.sperson
                                                              AND t.sseguro = psseguro*/)

            LOOP
               --
               SELECT d.tnombre1 || ' ' || d.tnombre2 || ' ' || d.tapelli1 || ' ' ||
                      d.tapelli2
                 INTO vnombre
                 FROM per_detper d,
                      tomadores  t
                WHERE d.sperson = t.sperson
                  AND t.sseguro = c_pol.sseguro;
               --
               --Valida porcentaje de similitud
               IF utl_match.jaro_winkler_similarity(vnombre, vnombre_tomador) >=
                  vnumnomcons_int
               THEN
                  --
                  v_aux := v_aux || '/' || c_pol.npoliza;
                  --
               END IF;
               --
            END LOOP;
            --
            BEGIN
               --
               SELECT d.tnombre1 || ' ' || d.tnombre2 || ' ' || d.tapelli1 || ' ' ||
                      d.tapelli2
                 INTO vnombre
                 FROM estper_detper d,
                      esttomadores  t
                WHERE d.sperson = t.sperson
                  AND t.sseguro = c_pol.sseguro;
               --
            EXCEPTION
               WHEN OTHERS THEN
                  --
                  NULL;
                  --
            END;
				--
				--Valida porcentaje de similitud
				IF utl_match.jaro_winkler_similarity(vnombre, vnombre_tomador) >=
					vnum_nom
				THEN
					--
					v_aux := v_aux || '/' || c_pol.npoliza;
					--
				END IF;
				--
				--
         ELSIF c_pol.tabla = 'POL'
         THEN
            --
            --Consulta miembros de consorcio
            FOR c_miembros IN (SELECT DISTINCT r.sperson_rel
                                 FROM per_personas_rel r,
                                      tomadores     t
                                WHERE r.ctipper_rel = 3
                                  AND t.sperson = r.sperson
                                  AND t.sseguro = psseguro)
            LOOP
               --
               SELECT d.tnombre1 || ' ' || d.tnombre2 || ' ' || d.tapelli1 || ' ' ||
                      d.tapelli2
                 INTO vnombre
                 FROM per_detper d,
                      tomadores  t
                WHERE d.sperson = t.sperson
                  AND t.sseguro = c_pol.sseguro;
               --
               --Valida porcentaje de similitud
               IF utl_match.jaro_winkler_similarity(vnombre, vnombre_tomador) >=
                  vnumnomcons_int
               THEN
                  --
                  v_aux := v_aux || '/' || c_pol.npoliza;
                  --
               END IF;
               --
            END LOOP;
            --
            BEGIN
               --
               SELECT d.tnombre1 || ' ' || d.tnombre2 || ' ' || d.tapelli1 || ' ' ||
                      d.tapelli2
                 INTO vnombre
                 FROM per_detper d,
                      tomadores  t
                WHERE d.sperson = t.sperson
                  AND t.sseguro = c_pol.sseguro;
               --
            EXCEPTION
               WHEN OTHERS THEN
                  --
                  NULL;
                  --
            END;
				--
				--Valida porcentaje de similitud
				IF utl_match.jaro_winkler_similarity(vnombre, vnombre_tomador) >=
					vnum_nom
				THEN
					--
					v_aux := v_aux || '/' || c_pol.npoliza;
					--
				END IF;
				--
			END IF;
			--
      END LOOP;
      --
      --Duplicado por NIT o nombre de tomador y/o consorcio
      IF v_aux IS NOT NULL
      THEN
         --
         ptmensaje := ptmensaje || ' ' || chr(13) || SUBSTR(v_aux, 2) || ': ' ||
                      f_axis_literales(9908867, pcidioma);
         --
         RETURN 1;
         --
      END IF;
      --
      RETURN 0;
      --
   EXCEPTION
      WHEN OTHERS THEN
         --
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         --
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     'ERROR: ' || ptmensaje);
         --
         RETURN 1;
         --
   END f_duplicidad_riesgo_5;

   /*************************************************************************
      FUNCTION f_duplicidad_riesgo_6: Valida duplicidad de riesgo
      param IN psproduc   : Código del producto
      param IN psseguro   : Número identificativo interno de SEGUROS
      param IN pcidioma   : Código del Idioma
      param OUT ptmensaje : Mensajes de salida
      Devuelve            : 0 => No duplicidad  1 => Duplicidad
   *************************************************************************/
   FUNCTION f_duplicidad_riesgo_6(psproduc  IN NUMBER,
                                  psseguro  IN NUMBER,
                                  pcidioma  IN NUMBER,
                                  ptmensaje IN OUT VARCHAR2) RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_VALIDACIONES_CONF.f_duplicidad_riesgo_6';
      vparam   VARCHAR2(300) := ' psproduc  =' || psproduc ||
                                ' - psseguro=' || psseguro ||
                                ' - pcidioma=' || pcidioma;
      --
   BEGIN
      --
      f_inicializa(psproduc, psseguro);
      --
      IF vctipide_tomador IS NULL OR
         vnnumide_tomador IS NULL
      THEN
         --
         RETURN 0;
         --
      END IF;
      --
      --Valida rango de suma asegurada
      FOR c_pol IN c_pol_tomadores(psseguro, vctipide_tomador,
                                   vnnumide_tomador)
      LOOP
         --
         vsumaaseg := f_get_valor_asegurado(c_pol.sseguro, c_pol.tabla);
         --
         IF vsumaaseg BETWEEN vsumaaseg_min AND vsumaaseg_max
         THEN
            --
            v_aux := v_aux || '/' || c_pol.npoliza;
            --
         END IF;
         --
      END LOOP;
      --
      --Duplicado por tomador y rango del valor asegurado
      IF v_aux IS NOT NULL
      THEN
         --
         ptmensaje := ptmensaje || ' ' || chr(13) || SUBSTR(v_aux, 2) || ': ' ||
                      f_axis_literales(9908859, pcidioma);
         --
         RETURN 1;
         --
      END IF;
      --
      RETURN 0;
      --
   EXCEPTION
      WHEN OTHERS THEN
         --
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         --
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     'ERROR: ' || ptmensaje);
         --
         RETURN 1;
         --
   END f_duplicidad_riesgo_6;

   /*************************************************************************
      FUNCTION f_duplicidad_riesgo_7: Valida duplicidad de riesgo
      param IN psproduc   : Código del producto
      param IN psseguro   : Número identificativo interno de SEGUROS
      param IN pcidioma   : Código del Idioma
      param OUT ptmensaje : Mensajes de salida
      Devuelve            : 0 => No duplicidad  1 => Duplicidad
   *************************************************************************/
   FUNCTION f_duplicidad_riesgo_7(psproduc  IN NUMBER,
                                  psseguro  IN NUMBER,
                                  pcidioma  IN NUMBER,
                                  ptmensaje IN OUT VARCHAR2) RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_VALIDACIONES_CONF.f_duplicidad_riesgo_7';
      vparam   VARCHAR2(300) := ' psproduc  =' || psproduc ||
                                ' - psseguro=' || psseguro ||
                                ' - pcidioma=' || pcidioma;
      --
   BEGIN
      --
      f_inicializa(psproduc, psseguro);
      --
      IF vctipide IS NULL OR
         vnnumide IS NULL
      THEN
         --
         RETURN 0;
         --
      END IF;
      --
      --Valida asegurados
      FOR c_pol IN c_pol_asegurados(psseguro, vctipide, vnnumide)
      LOOP
         --
         FOR c_con IN c_pol_contrato_seguro(c_pol.sseguro, v_resp_4097)
         LOOP
            --
            v_aux := v_aux || '/' || c_pol.npoliza;
            --
         END LOOP;
         --
      END LOOP;
      --
      --Duplicado por NIT tomador y coincidencia en el nro. de contrato
      IF v_aux IS NOT NULL
      THEN
         --
         ptmensaje := ptmensaje || ' ' || chr(13) || SUBSTR(v_aux, 2) || ': ' ||
                      f_axis_literales(9908868, pcidioma);
         --
         RETURN 1;
         --
      END IF;
      --
      RETURN 0;
      --
   EXCEPTION
      WHEN OTHERS THEN
         --
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         --
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     'ERROR: ' || ptmensaje);
         --
         RETURN 1;
         --
   END f_duplicidad_riesgo_7;

   /*************************************************************************
      FUNCTION f_duplicidad_riesgo_8: Valida duplicidad de riesgo
      param IN psproduc   : Código del producto
      param IN psseguro   : Número identificativo interno de SEGUROS
      param IN pcidioma   : Código del Idioma
      param OUT ptmensaje : Mensajes de salida
      Devuelve            : 0 => No duplicidad  1 => Duplicidad
   *************************************************************************/
   FUNCTION f_duplicidad_riesgo_8(psproduc  IN NUMBER,
                                  psseguro  IN NUMBER,
                                  pcidioma  IN NUMBER,
                                  ptmensaje IN OUT VARCHAR2) RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_VALIDACIONES_CONF.f_duplicidad_riesgo_8';
      vparam   VARCHAR2(300) := ' psproduc  =' || psproduc ||
                                ' - psseguro=' || psseguro ||
                                ' - pcidioma=' || pcidioma;
      --
   BEGIN
      --
      f_inicializa(psproduc, psseguro);
      --
      IF vctipide IS NULL OR
         vnnumide IS NULL OR
         vctipide_tomador IS NULL OR
         vnnumide_tomador IS NULL
      THEN
         --
         RETURN 0;
         --
      END IF;
      --
      --Valida asegurados/tomadores
      FOR c_pol IN c_pol_tomador_asegurado(psseguro, vctipide, vnnumide,
                                           vctipide_tomador, vnnumide_tomador)
      LOOP
         --
         v_aux := v_aux || '/' || c_pol.npoliza;
         --
      END LOOP;
      --
      --Duplicado por NIT tomador y asegurado
      IF v_aux IS NOT NULL
      THEN
         --
         ptmensaje := ptmensaje || ' ' || chr(13) || SUBSTR(v_aux, 2) || ': ' ||
                      f_axis_literales(9908869, pcidioma);
         --
         RETURN 1;
         --
      END IF;
      --
      RETURN 0;
      --
   EXCEPTION
      WHEN OTHERS THEN
         --
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         --
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     'ERROR: ' || ptmensaje);
         --
         RETURN 1;
         --
   END f_duplicidad_riesgo_8;

   /*************************************************************************
      FUNCTION f_duplicidad_riesgo_9: Valida duplicidad de riesgo
      param IN psproduc   : Código del producto
      param IN psseguro   : Número identificativo interno de SEGUROS
      param IN pcidioma   : Código del Idioma
      param OUT ptmensaje : Mensajes de salida
      Devuelve            : 0 => No duplicidad  1 => Duplicidad
   *************************************************************************/
   FUNCTION f_duplicidad_riesgo_9(psproduc  IN NUMBER,
                                  psseguro  IN NUMBER,
                                  pcidioma  IN NUMBER,
                                  ptmensaje IN OUT VARCHAR2) RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_VALIDACIONES_CONF.f_duplicidad_riesgo_9';
      vparam   VARCHAR2(300) := ' psproduc  =' || psproduc ||
                                ' - psseguro=' || psseguro ||
                                ' - pcidioma=' || pcidioma;
      --
   BEGIN
      --
      f_inicializa(psproduc, psseguro);
      --
      IF vctipide_tomador IS NULL OR
         vnnumide_tomador IS NULL
      THEN
         --
         RETURN 0;
         --
      END IF;
      --
      --Valida rango de contrato
      FOR c_pol IN c_pol_tomadores(psseguro, vctipide_tomador,
                                   vnnumide_tomador)
      LOOP
         --
         vcontrato := f_get_valor_contrato(c_pol.sseguro, c_pol.tabla);
         --
         IF vcontrato BETWEEN vcontrato_min AND vcontrato_max
         THEN
            --
            v_aux := v_aux || '/' || c_pol.npoliza;
            --
         END IF;
         --
      END LOOP;
      --
      --Duplicado por tomador y rango del valor asegurado
      IF v_aux IS NOT NULL
      THEN
         --
         ptmensaje := ptmensaje || ' ' || chr(13) || SUBSTR(v_aux, 2) || ': ' ||
                      f_axis_literales(9908870, pcidioma);
         --
         RETURN 1;
         --
      END IF;
      --
      RETURN 0;
      --
   EXCEPTION
      WHEN OTHERS THEN
         --
         ptmensaje := SQLCODE || ' - ' || SQLERRM;
         --
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     'ERROR: ' || ptmensaje);
         --
         RETURN 1;
         --
   END f_duplicidad_riesgo_9;

END pac_validaciones_conf;

/

  GRANT EXECUTE ON "AXIS"."PAC_VALIDACIONES_CONF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_VALIDACIONES_CONF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_VALIDACIONES_CONF" TO "PROGRAMADORESCSI";
