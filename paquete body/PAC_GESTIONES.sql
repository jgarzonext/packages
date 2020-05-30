--------------------------------------------------------
--  DDL for Package Body PAC_GESTIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_GESTIONES" AS
/******************************************************************************
   NOMBRE:    PAC_GESTIONES
   PROPÓSITO: Funciones para gestiones en siniestros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
    1.0       24/08/2011   ASN             Creacion
    2.0       02/12/2011   JMP             0018423: LCOL000 - Multimoneda
    3.0       19/07/2012   ASN             0023035: Cambiar calculo coeficiente carga de trabajo en la asignacion de profesionales
    4.0       03/04/2013   ASN             0026592: LCOL_S010-SIN - Gestiones de talleres (autos) y repuestos
    5.0       24/07/2014   JTT             0029801/0179742: Modificacion AXIS_CORE corresponde con LCOL_4940
    6.0       09/09/2014   JTT             0031364: Modificacion F_ajusta_reserva para actualizar el estado del siniestro
    7.0       01/04/2015   JTT             0035278: Correcciones de errores diversos
	8.0       19/01/2018   ACL             0000511: Se quita condición del valor "Límite cuantía peritable" en la función f_lstprofesional.
******************************************************************************/
   vtraza         NUMBER := 0;

   FUNCTION f_gestiones(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
      /*************************************************************************
         Devuelve query para la lista de gestiones del bloque en tramitacion
         param in  pnsinies : numero de siniestro
         param in  pntramit : numero de tramitacion
         param in  pcidioma : codigo idioma
         param out pquery   : select de sin_tramita_gestion
         return             : number
      *************************************************************************/
      cod_profesional sin_prof_profesionales.sprofes%TYPE;
   BEGIN
      -- 23182:ASN:30/07/2012 ini
      /*
         pquery := 'select g.sseguro, g.nsinies, g.ntramit, null, g.cgarant, g.sgestio, '
                   || '      g.ctipreg, g.ctipges, ff_desvalorfijo(722, ' || pcidioma
                   || ' , g.ctipges), ' || ' g.sprofes, f_nombre(pr.sperson, 1), '
                   || '      g.ctippro, g.csubpro, ff_desvalorfijo(725, ' || pcidioma
                   || ' , g.csubpro), ' || '      g.spersed, f_nombre(g.spersed, 3), g.sconven, '
                   || '      g.ccancom, g.ccomdef, g.trefext '
                   || ' from sin_tramita_gestion g, sin_prof_profesionales pr '
                   || ' where pr.sprofes = g.sprofes ' || '  and g.nsinies = ' || pnsinies
                   || '  and g.ntramit = ' || pntramit || '  order by g.sgestio';
       */
      BEGIN
         SELECT p.sprofes
           INTO cod_profesional
           FROM usuarios u, sin_prof_profesionales p
          WHERE u.sperson = p.sperson
            AND u.cusuari = f_user();
      EXCEPTION
         WHEN OTHERS THEN
            cod_profesional := NULL;
      END;

      pquery := 'select g.sseguro, g.nsinies, g.ntramit, null, g.cgarant, g.sgestio, '
                || '      g.ctipreg, g.ctipges, ff_desvalorfijo(722, ' || pcidioma
                || ' , g.ctipges), ' || ' g.sprofes, f_nombre(pr.sperson, 1), '
                || '      g.ctippro, g.csubpro, ff_desvalorfijo(725, ' || pcidioma
                || ' , g.csubpro), ' || '      g.spersed, f_nombre(g.spersed, 3), g.sconven, '
                || '      g.ccancom, g.ccomdef, g.trefext, '
                || ' g.fgestio '   -- 26630:NSS;12/07/2013
                || ' from sin_tramita_gestion g, sin_prof_profesionales pr '
                || ' where pr.sprofes = g.sprofes ' || '  and g.nsinies = ' || pnsinies
                || '  and g.ntramit = ' || pntramit;

      IF cod_profesional IS NOT NULL THEN
         pquery := pquery || '  and g.sprofes = ' || cod_profesional || '  order by g.sgestio';
      ELSE
         pquery := pquery || '  order by g.sgestio';
      END IF;

      -- 23182:ASN:30/07/2012 fin
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_GESTIONES.F_GESTIONES ', vtraza,
                     'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_gestiones;

   FUNCTION f_servicios(
      psgestio IN sin_tramita_gestion.sgestio%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
   /*************************************************************************
      Devuelve query de sin_tramita_detgestion
      param in  psgestio : clave de gestion
      param in  pcidioma : codigo de idioma
      param out pquery   : select de sin_tramita_localiza
      return             : number
   *************************************************************************/
   BEGIN
      pquery :=
         'select dg.sgestio, dg.ndetges, dg.sservic, '
         || '       dt.tdescri, dg.nvalser, dg.ncantid, dg.cnocarg, '
         || '       dg.cunimed, ff_desvalorfijo(734, ' || pcidioma || ' , dg.cunimed),'
         || '       dg.itotal, dg.ccodmon, null , dg.fcambio, dg.falta '   -- 25913:ASN:11/02/13
         || ' from sin_tramita_detgestion dg, sin_dettarifas dt, sin_prof_tarifa pt, eco_codmonedas m '
         || ' where dg.sservic = dt.sservic ' || ' and dg.sgestio = ' || psgestio
         || ' and pt.sconven = (select sconven from sin_tramita_gestion g where g.sgestio = dg.sgestio) '
         || ' and dt.starifa = pt.starifa ' || ' and dg.ccodmon = m.cmoneda(+)';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_GESTIONES.F_SERVICIOS', vtraza,
                     'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_servicios;

   FUNCTION f_movimientos(
      psgestio IN sin_tramita_gestion.sgestio%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
   /*************************************************************************
      Devuelve query para sin_tramita_movgestion
      param in  psgestio : clave de gestion
      param in  pcidioma : codigo de idioma
      param ou8t pquery   : select de sin_tramita_localiza
      return             : number
   *************************************************************************/
   BEGIN
      pquery := 'select sgestio, nmovges, ' || ' ctipmov, ff_desvalorfijo(723, ' || pcidioma
                || ' , ctipmov), ' || ' cestges, ff_desvalorfijo(736, ' || pcidioma
                || ' , cestges), ' || ' csubges, ff_desvalorfijo(727, ' || pcidioma
                || ' , csubges), '
                || ' tcoment, fmovini, fmovfin, finicio, fproxim, flimite, '
                || ' faccion, caccion, ntotava, nmaxava, cusualt '
                || ' from sin_tramita_movgestion ' || ' where sgestio = ' || psgestio;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_GESTIONES.F_MOVIMIENTOS', vtraza,
                     'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_movimientos;

   FUNCTION f_lstlocalizacion(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
   /*************************************************************************
      Devuelve query para la lista de localizaciones
      param in  pnsinies : numero de siniestro
      param in  pntramit : numero de tramitacion
      param out pquery   : select de sin_tramita_localiza
      return             : number
   *************************************************************************/
   BEGIN
      pquery :=
         'select nlocali, f_despoblac2(cpoblac, cprovin) || ''-'' || '   --bug 27487/183043:NSS:04/09/2014
         || ' pac_persona.f_tdomici(csiglas, tnomvia, nnumvia, tcomple) TLOCALI'
         || ' from sin_tramita_localiza ' || ' where nsinies = ' || pnsinies
         || ' and ntramit = ' || pntramit;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_GESTIONES.F_LSTLOCALIZACION', vtraza,
                     'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_lstlocalizacion;

   FUNCTION f_lsttipgestion(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
/*************************************************************************
  Devuelve query para carga lista de tipos de gestion
  param in  pnsinies  : numero de siniestro
  param in  pctramit  : tipo de tramitacion
  param in  pcidioma  : codigo idioma
  param out pquery    : select de listvalores
  return              : NUMBER 0 / 1
*************************************************************************/
      vsseguro       seguros.sseguro%TYPE;
      vsproduc       seguros.sproduc%TYPE;
      vcactivi       seguros.cactivi%TYPE;
      vfsinies       sin_siniestro.fsinies%TYPE;
      vnriesgo       sin_siniestro.nriesgo%TYPE;
      vnmovimi       movseguro.nmovimi%TYPE;
      vctramit       sin_tramitacion.ctramit%TYPE;
   BEGIN
      vtraza := 1;

      SELECT s.sseguro, s.sproduc, s.cactivi, si.nriesgo, si.fsinies
        INTO vsseguro, vsproduc, vcactivi, vnriesgo, vfsinies
        FROM seguros s, sin_siniestro si
       WHERE si.sseguro = s.sseguro
         AND si.nsinies = pnsinies;

      vtraza := 2;

      SELECT MAX(g.nmovimi)
        INTO vnmovimi
        FROM garanseg g
       WHERE g.sseguro = vsseguro
         AND g.finiefe = (SELECT MAX(g1.finiefe)
                            FROM garanseg g1
                           WHERE g1.sseguro = g.sseguro
                             AND g1.finiefe <= vfsinies);

      vtraza := 3;

      SELECT ctramit
        INTO vctramit
        FROM sin_tramitacion
       WHERE nsinies = pnsinies
         AND ntramit = pntramit;

      vtraza := 4;
      pquery :=
         'select catribu,tatribu from detvalores where cidioma =' || pcidioma
         || ' and cvalor = 722 and catribu in ('
         || 'select  ctipges from  sin_parges_tip_gestion where ctipreg in ('
         || 'select pg.ctipreg from sin_parges_tramitacion pg, sin_codtramitacion t'
         || ' where pg.ctiptra = t.ctiptra  and  t.ctramit = ' || vctramit || ') '
         || '  and ctipreg in (select ctipreg from sin_parges_garantias where sproduc = '
         || vsproduc || '  and (cactivi = ' || vcactivi || ' or cactivi is null)'
         || '  and (cgarant in (select cgarant from garanseg where sseguro = ' || vsseguro
         || '  and nriesgo = ' || vnriesgo || '  and nmovimi = ' || vnmovimi
         || ') or cgarant is null) ) )';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_GESTIONES.F_LSTTIPGESTION', vtraza,
                     'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_lsttipgestion;

   FUNCTION f_lsttipprof(
      pctipges IN sin_tramita_gestion.ctipges%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
/*************************************************************************
  Devuelve query para carga lista de tipos de profesional
  param in  pctipges  : tipo de gestion
  param in  pcidioma  : codigo idioma
  param out pquery    : select de listvalores
  return              : NUMBER 0 / 1
*************************************************************************/
   BEGIN
      pquery := 'select catribu,tatribu from detvalores where cidioma =' || pcidioma
                || ' and cvalor = 724 and catribu in ('
                || 'select ctippro from sin_parges_profesional ' || 'where ctipges = '
                || pctipges || ')';
      RETURN 0;
   END f_lsttipprof;

   FUNCTION f_lstsubprof(
      pctipges IN sin_tramita_gestion.ctipges%TYPE,
      pctippro IN sin_tramita_gestion.ctippro%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
/*************************************************************************
  Devuelve query para carga lista de subtipos de profesional
  param in  pctipges  : tipo de gestion
  param in  pctippro  : tipo de profesional
  param in  pcidioma  : codigo idioma
  param out pquery    : select de listvalores
  return              : NUMBER 0 / 1
*************************************************************************/
   BEGIN
      pquery := 'select catribu,tatribu from detvalores where cidioma =' || pcidioma
                || ' and cvalor = 725 and catribu in ('
                || 'select csubpro from sin_parges_profesional ' || 'where ctipges = '
                || pctipges || 'and ctippro = ' || pctippro || ')';
      RETURN 0;
   END f_lstsubprof;

   FUNCTION f_lstprofesional(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pnlocali IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      psgestio IN NUMBER DEFAULT NULL,   --26630
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
/*************************************************************************
  Devuelve query para carga lista de profesionales
  param in  pnsinies  : numero de siniestro
  param in  pntramit  : numero de tramitacion
  param in  pnlocali  : numero de localizacion
  param in  pctippro  : tipo de profesional
  param in  pcsubpro  : subtipo de profesional
  param out pquery    : select
  return              : NUMBER 0 / 1
*************************************************************************/
      vcpais         NUMBER;
      vcprovin       NUMBER;
      vcpoblac       NUMBER;
      vcpostal       NUMBER;
      vsproduc       NUMBER;
      vccausin       NUMBER;
      v_coste        NUMBER;
   BEGIN
      vtraza := 1;

      SELECT cpais, cprovin, cpoblac, cpostal
        INTO vcpais, vcprovin, vcpoblac, vcpostal
        FROM sin_tramita_localiza
       WHERE nsinies = pnsinies
         AND ntramit = pntramit
         AND nlocali = pnlocali;

      vtraza := 2;

      SELECT s.sproduc, si.ccausin
        INTO vsproduc, vccausin
        FROM sin_siniestro si, seguros s
       WHERE si.sseguro = s.sseguro
         AND si.nsinies = pnsinies;


      vtraza := 3;


            SELECT SUM(NVL(R1.IRESERVA_MONCIA, 0) +
                       NVL(R1.IPAGO_MONCIA, 0)) INTO v_coste
              FROM SIN_TRAMITA_RESERVA R1
             WHERE R1.NSINIES = pnsinies
               AND R1.CTIPRES = 1 -- Indemnizatoria
               AND R1.NMOVRES = (SELECT MAX(R2.NMOVRES)
                                   FROM SIN_TRAMITA_RESERVA R2
                                  WHERE R2.NSINIES = R1.NSINIES
                                    AND R2.IDRES = R1.IDRES);

/*      pquery :=
         'select p.sprofes, f_nombre(p.sperson, 1) nombre, 5 - z.ctpzona orden1, pac_gestiones.f_coef_pro(p.sprofes) orden2, dbms_random.value(1,1000) orden3 '
         || ' from sin_prof_profesionales p, sin_prof_rol r, sin_prof_zonas z, sin_prof_estados e '
         || ' where r.sprofes = p.sprofes' || '  and r.ctippro = ' || pctippro
         || '  and r.csubpro = ' || pcsubpro || '  and z.sprofes = p.sprofes'
         || '  and ((z.ctpzona = 4 and ' || NVL(vcpostal, -1)
         || ' between z.cposini and z.cposfin)'
         || '         or (z.ctpzona = 3 and z.cpoblac =  ' || NVL(vcpoblac, -1) || ' )'
         || '         or (z.ctpzona = 2 and z.cprovin = ' || vcprovin || ')'
         || '         or (z.ctpzona = 1 and z.cpais = ' || vcpais || '))'
         || '   and p.sprofes not in (select sprofes from sin_prof_descartados d'
         || '                         where d.sprofes = p.sprofes'
         || '                           and (sproduc = ' || vsproduc || ' or ccausin = '
         || vccausin || ')' || '                           and f_sysdate >= fdesde'
         || '                           and (f_sysdate < fhasta or fhasta is null))'
         || ' and e.sprofes = p.sprofes' || ' and e.cestado = 1'
         || ' and e.festado = (select max(festado) from sin_prof_estados e1 where sprofes = p.sprofes and festado <= f_sysdate)'
         || ' and pac_gestiones.f_coef_pro(p.sprofes) <> 9999 '
         || ' order by orden1, orden2, orden3, nombre';
*/
      pquery :=
         'select p.sprofes, f_nombre(p.sperson, 1) nombre, 5 - zo.ctpzona orden1, pac_gestiones.f_coef_pro(p.sprofes) orden2, dbms_random.value(1,1000) orden3 '
         || ' from sin_prof_profesionales p, sin_prof_rol r, sin_prof_estados e, '
         || ' (select z.sprofes, max(z.ctpzona) ctpzona from sin_prof_zonas z '
         || ' where ((z.ctpzona = 4 and ' || NVL(vcpostal, -1)
         || ' between z.cposini and z.cposfin) '
         || '         or (z.ctpzona = 3 and z.cpoblac = ' || NVL(vcpoblac, -1)
         || ' and z.cprovin = ' || vcprovin || ' )'
         || '         or (z.ctpzona = 2 and z.cprovin = ' || vcprovin || ')'
         || '         or (z.ctpzona = 1 and z.cpais = ' || vcpais || '))'
         || ' group by z.sprofes )zo' || ' where r.sprofes = p.sprofes' || '  and r.ctippro = '
         || pctippro || '  and r.csubpro = ' || pcsubpro || '  and zo.sprofes = p.sprofes'
         || '   and p.sprofes not in (select sprofes from sin_prof_descartados d'
         || '                         where d.sprofes = p.sprofes'
         || '                           and (sproduc = ' || vsproduc || ' or ccausin = '
         || vccausin || ')' || '                           and f_sysdate >= fdesde'
         || '                           and (f_sysdate < fhasta or fhasta is null))'
         || ' and e.sprofes = p.sprofes' || ' and e.cestado = 1'
         || ' and e.festado = (select max(festado) from sin_prof_estados e1 where sprofes = p.sprofes and festado <= f_sysdate)'
         || ' and pac_gestiones.f_coef_pro(p.sprofes) <> 9999 ';
      -- INI BUG 511 - CONF-1139 ACL 19/01/2018
      /*IF pac_md_common.f_get_cxtempresa = 24 THEN
         pquery := pquery || ' and NVL(p.nlimite,0) >= '|| v_coste || '  ';
      END IF;*/
	  -- FIN BUG 511 - CONF-1139 ACL 19/01/2018
      IF psgestio IS NOT NULL THEN
         pquery :=
            pquery || ' UNION '   --26630
            || ' select p.sprofes, f_nombre(p.sperson, 1) nombre, NULL, NULL, NULL '   --26630
            || ' from sin_prof_profesionales p '   --26630
                                                || ' where p.sgestio = ' || psgestio;   --26630;
      END IF;

      pquery := pquery || ' order by orden1, orden2, orden3, nombre';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_GESTIONES.F_LSTPROFESIONALES', vtraza,
                     'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_lstprofesional;

   FUNCTION f_coef_pro(psprofes IN NUMBER)
      RETURN NUMBER IS
/*************************************************************************
  Devuelve  total_gestiones_abiertas / carga_diaria
  param in  psprofes  : codigo de profesional
  return              : NUMBER
 *************************************************************************/
      vdividendo     NUMBER;
      vdivisor       NUMBER;
   BEGIN
      SELECT COUNT(g.sgestio)
--        INTO vdividendo
      INTO   vdivisor   -- 23035
        FROM sin_tramita_gestion g, sin_tramita_movgestion m
       WHERE m.sgestio = g.sgestio
         AND m.fmovfin IS NULL
         AND m.cestges = 0
         AND g.sprofes = psprofes;

      IF vdivisor = 0 THEN   -- 23035
         RETURN 0;
      END IF;

      SELECT c1.ncardia
--        INTO vdivisor
      INTO   vdividendo   -- 23035
        FROM sin_prof_carga_real c1
       WHERE c1.sprofes = psprofes
         AND c1.fdesde = (SELECT MAX(c2.fdesde)
                            FROM sin_prof_carga_real c2
                           WHERE c2.sprofes = c1.sprofes);

      IF vdividendo = 0 THEN   -- 23035
         RETURN 9999;
      END IF;

      RETURN vdividendo / vdivisor;
   END f_coef_pro;

   FUNCTION f_lstsedes(psprofes IN sin_prof_profesionales.sprofes%TYPE, pquery OUT VARCHAR2)
      RETURN NUMBER IS
/*************************************************************************
  Devuelve query para carga lista de sedes de un profesional
  param in  psprofes  : codigo profesional
  param out pquery    : select
  return              : NUMBER 0 / 1
*************************************************************************/
   BEGIN
      pquery :=
         'select p.sperson,tapelli1 tnombre from per_personas_rel r, per_detper p, sin_prof_profesionales pr '
         || 'where pr.sprofes = ' || psprofes || ' and  r.sperson = pr.sperson'
         || ' and r.sperson_rel = p.sperson and r.ctipper_rel = 2 '
         || ' and r.cagente in (select cagente from agentes_agente)'
         || ' and r.cagente = p.cagente';   --Bug 21192:NSS:06/06/2013
      RETURN 0;
   END f_lstsedes;

   FUNCTION f_lsttarifas(
      psprofes IN sin_prof_tarifa.sprofes%TYPE,
      pspersed IN sin_prof_tarifa.spersed%TYPE,
      pfecha IN sin_prof_tarifa.festado%TYPE,
      pcconven IN sin_codtramitador.cconven%TYPE,   --26630
      pcidioma IN idiomas.cidioma%TYPE,   --26630
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
/*************************************************************************
  Devuelve query para carga lista de los convenios/baremos de un profesional
  param in  psprofes  : codigo profesional
  param in  pspersed  : sede (sperson)
  param in  pfecha    : fecha de vigencia
  param out pquery    : select
  return              : NUMBER 0 / 1
*************************************************************************/
   BEGIN
      --26630
      pquery :=
         'select * from ( ' || ' select 1, t.sconven, tt.tdescri  '
         || ' from sin_prof_tarifa t, sin_prof_conv_estados e, sin_tarifas tt '
         || ' where tt.starifa = t.starifa  ' || '   and e.sconven = t.sconven'
         || '   and TRUNC(e.festado) = (select TRUNC(max(e1.festado))
                                          from sin_prof_conv_estados e1 '
         || '           where e1.sconven = e.sconven'
         || '                      and TRUNC(e1.festado) <=  to_date('''
         || TO_CHAR(pfecha, 'DD/MM/YYYY') || ''', ''DD/MM/YYYY'')  )' || ' and t.sprofes = '
         || psprofes || ' and (t.spersed = ' || NVL(pspersed, -1) || ' or t.spersed is null)'
         || ' and e.cestado = 1 ' || ' UNION     '
         || ' select 2, t.sconven, tt.tdescri|| ''( ''||v.tatribu||'')'' '
         || ' from sin_prof_tarifa t, sin_prof_conv_estados e, sin_tarifas tt, detvalores v'
         || ' where tt.starifa = t.starifa  ' || ' and e.sconven = t.sconven'
         || ' and TRUNC(e.festado) = (select TRUNC(max(e1.festado))
                                        from sin_prof_conv_estados e1 '
         || '                   where e1.sconven = e.sconven'
         || '                     and TRUNC(e1.festado) <=  to_date('''
         || TO_CHAR(pfecha, 'DD/MM/YYYY') || ''', ''DD/MM/YYYY'')  )'
         || ' and v.cvalor = 742        ' || ' and v.catribu = e.cestado'
         || ' and v.cidioma = ' || pcidioma || ' and t.sprofes = ' || psprofes
         || ' and (t.spersed = ' || NVL(pspersed, -1) || ' or t.spersed is null)'
         || ' and e.cestado <> 1' || ' and ' || pcconven || ' = 1)' || ' order by 1,2';
      RETURN 0;
   END f_lsttarifas;

   FUNCTION f_lstgarantias(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pctipges IN sin_tramita_gestion.ctipges%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
/*************************************************************************
  Devuelve query para carga lista de garantias contratadas
  param in  pnsinies  : numero de siniestro
  param in  pctipges  : tipo de gestion
  param in  pcidioma  : codigo idioma
  param out pquery    : select de listvalores
  return              : NUMBER 0 / 1
*************************************************************************/
      vsseguro       seguros.sseguro%TYPE;
      vsproduc       seguros.sproduc%TYPE;
      vcactivi       seguros.cactivi%TYPE;
      vfsinies       sin_siniestro.fsinies%TYPE;
      vnriesgo       sin_siniestro.nriesgo%TYPE;
      vnmovimi       movseguro.nmovimi%TYPE;
      vccausin       sin_siniestro.ccausin%TYPE;
      vcmotsin       sin_siniestro.cmotsin%TYPE;
   BEGIN
      vtraza := 1;

      SELECT s.sseguro, s.sproduc, s.cactivi, si.nriesgo, si.fsinies, si.ccausin, si.cmotsin
        INTO vsseguro, vsproduc, vcactivi, vnriesgo, vfsinies, vccausin, vcmotsin
        FROM seguros s, sin_siniestro si
       WHERE si.sseguro = s.sseguro
         AND si.nsinies = pnsinies;

      vtraza := 2;

      SELECT MAX(g.nmovimi)
        INTO vnmovimi
        FROM garanseg g
       WHERE g.sseguro = vsseguro
         AND g.finiefe = (SELECT MAX(g1.finiefe)
                            FROM garanseg g1
                           WHERE g1.sseguro = g.sseguro
                             AND g1.finiefe <= vfsinies);

      pquery := 'select gg.cgarant, gg.tgarant from garanseg gs, garangen gg '
                || ' where gs.cgarant = gg.cgarant and gg.cidioma = ' || pcidioma
                || ' and gs.sseguro = ' || vsseguro || ' and gs.nriesgo = ' || vnriesgo
                || ' and gs.nmovimi = ' || vnmovimi
                || ' and gs.cgarant in (select cgarant from sin_gar_causa where sproduc = '
                || vsproduc || ' and ccausin = ' || vccausin || ' and cmotsin = ' || vcmotsin
                || ') ' || ' and exists (select 1 from sin_parges_res_garantia '
                || ' where ctipges = ' || pctipges || ' and cresgar = 1 )';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_GESTIONES.F_LSTTIPGESTION', vtraza,
                     'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_lstgarantias;

   FUNCTION f_lstestados(
      pctipges IN sin_parges_movimientos.ctipges%TYPE,
      pctipmov IN sin_parges_movimientos.ctipmov%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
/*************************************************************************
  Devuelve query para carga lista de estados
  param in  pctipges  : tipo de gestion
  param in  pctipmov  : moviento
  param in  pcidioma  : codigo idioma
  param out pquery    : select de listvalores
  return              : NUMBER 0 / 1
*************************************************************************/
      vcestges       NUMBER;
   BEGIN
      BEGIN
         SELECT cestges
           INTO vcestges
           FROM sin_parges_movimientos
          WHERE ctipges = pctipges
            AND ctipmov = pctipmov;

         pquery := 'select catribu,tatribu from detvalores where cidioma =' || pcidioma
                   || ' and cvalor = 736 and catribu in ('
                   || 'select cestges from sin_parges_movimientos  ' || 'where ctipges = '
                   || pctipges || ' AND ctipmov = ' || pctipmov || ')';   -- si el movimiento esta parametrizado, la lista tendra una sola entrada
      EXCEPTION
         WHEN NO_DATA_FOUND THEN   -- si el movimiento no esta parametrizado, listamos todos los estados permitidos para el tipo de gestion
            pquery := 'select catribu,tatribu from detvalores where cidioma =' || pcidioma
                      || ' and cvalor = 736 and catribu in ('
                      || 'select cestges from sin_parges_est_permitidos  '
                      || 'where ctipges = ' || pctipges || ' )';
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_GESTIONES.F_LSTESTADOS', vtraza,
                        'error recuperando datos', SQLERRM);
            RETURN 1000455;
      END;

      RETURN 0;
   END f_lstestados;

   FUNCTION f_lstsubestados(
      pctipges IN sin_parges_movimientos.ctipges%TYPE,
      pcestges IN sin_parges_movimientos.cestges%TYPE,
      pctipmov IN sin_parges_movimientos.ctipmov%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
/*************************************************************************
  Devuelve query para carga lista de subestados
  param in  pctipges  : tipo de gestion
  param in  pcestges  : estado gestion
  param in  pctipmov  : moviento
  param in  pcidioma  : codigo idioma
  param out pquery    : select de listvalores
  return              : NUMBER 0 / 1
*************************************************************************/
      vcestges       NUMBER;
   BEGIN
      BEGIN
         SELECT csubges
           INTO vcestges
           FROM sin_parges_movimientos
          WHERE ctipges = pctipges
            AND ctipmov = pctipmov;

         pquery := 'select catribu,tatribu from detvalores where cidioma =' || pcidioma
                   || ' and cvalor = 727 and catribu in ('
                   || 'select csubges from sin_parges_movimientos  ' || 'where ctipges = '
                   || pctipges || ' and ctipmov = ' || pctipmov || ')';
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pquery := 'select catribu,tatribu from detvalores where cidioma =' || pcidioma
                      || ' and cvalor = 727 and catribu in ('
                      || 'select csubges from sin_parges_est_permitidos  '
                      || 'where ctipges = ' || pctipges || ' and cestges =' || pcestges
                      || ' )';
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_GESTIONES.F_LSTESTADOS', vtraza,
                        'error recuperando datos', SQLERRM);
            RETURN 1000455;
      END;

      RETURN 0;
   END f_lstsubestados;

   FUNCTION f_lstmovimientos(
      pctipges IN sin_parges_mov_permitidos.ctipges%TYPE,
      pcestges IN sin_parges_mov_permitidos.cestges%TYPE,
      pcsubges IN sin_parges_mov_permitidos.csubges%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
/*************************************************************************
  Devuelve query para carga lista de movimientos permitidos
  param in  pctipges  : tipo de gestion
  param in  pcestges  : estado gestion
  param in  pctipmov  : moviento
  param in  pcidioma  : codigo idioma
  param out pquery    : select de listvalores
  return              : NUMBER 0 / 1
*************************************************************************/
   BEGIN
      pquery := 'select catribu,tatribu from detvalores where cidioma =' || pcidioma
                || ' and cvalor = 723 and catribu in ('
                || 'select ctipmov from sin_parges_mov_permitidos ' || ' where ctipges = '
                || pctipges || ' and cestges = ' || pcestges || ' and csubges = ' || pcsubges
                || ')';
      RETURN 0;
   END f_lstmovimientos;

   FUNCTION f_lstservicios(
      psservic IN NUMBER,
      ptdescri IN VARCHAR2,
      psconven IN NUMBER,
      pfecha IN DATE,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
/*************************************************************************
   Devuelve query de servicios que cumplen una condicion
   param in  sservic  : codigo de servicio
   param in  tdescri  : descripcion de servicio
   param in  sconven  : numero de convenio/baremo
   param in  fecha    : fecha de vigencia
   param out pquery   : select de sin_dettarifas
   return             : NUMBER 0/1
 *************************************************************************/
      vsservic       NUMBER;
      vtdescri       VARCHAR2(100);
   BEGIN
      -- 23182:ASN:30/07/2012 ini
      /*
      pquery :=
         'select d.starifa, d.nlinea, d.sservic, d.tdescri, d.cunimed, d.iprecio, d.cmagnit, d.iminimo, d.ccodcup, d.ccodmon, d.ctipcal '
         || ' from sin_dettarifas d, sin_prof_tarifa t'
         || ' where t.starifa = d.starifa and t.sconven = ' || psconven
         || ' and finivig <= to_date(''' || TO_CHAR(pfecha, 'DD/MM/YYYY')
         || ''', ''DD/MM/YYYY'') and (ffinvig >  to_date(''' || TO_CHAR(pfecha, 'DD/MM/YYYY')
         || ''', ''DD/MM/YYYY'')  or ffinvig is null) ';
      */
      pquery :=
         'select d.starifa, d.nlinea, d.sservic, d.tdescri, d.cunimed, NVL(d.iprecio,0) iprecio, d.cmagnit, NVL(d.iminimo,0) iminimo, d.ccodcup, NVL(d.ccodmon, '' ''), NVL(d.ctipcal,-1) ctipcal '
         || ' from sin_dettarifas d, sin_prof_tarifa t'
         || ' where t.starifa = d.starifa and t.sconven = ' || psconven
         || ' and d.cselecc = 1 ' || ' and TRUNC(finivig) <= to_date('''
         || TO_CHAR(pfecha, 'DD/MM/YYYY')
         || ''', ''DD/MM/YYYY'') and (TRUNC(ffinvig) >  to_date('''
         || TO_CHAR(pfecha, 'DD/MM/YYYY') || ''', ''DD/MM/YYYY'')  or ffinvig is null) ';

      -- 23182:ASN:30/07/2012 fin
      IF psservic IS NOT NULL THEN
         pquery := pquery || ' and sservic like ''' || psservic || '%''';
      END IF;

      IF ptdescri IS NOT NULL THEN
         IF SUBSTR(ptdescri, -1) = '%' THEN
            vtdescri := ptdescri;
         ELSE
            vtdescri := ptdescri || '%';
         END IF;

         -- 25913:ASN:08/02/2013 ini
         IF SUBSTR(ptdescri, 1, 1) = '%' THEN
            NULL;
         ELSE
            vtdescri := '%' || vtdescri;
         END IF;

         -- 25913:ASN:08/02/2013 fin
         pquery := pquery || ' and upper(d.tdescri) like ' || CHR(39) || UPPER(vtdescri)
                   || CHR(39);
      END IF;

      pquery := pquery || ' order by 3';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END f_lstservicios;

   FUNCTION f_ins_gestion(
      psseguro IN sin_tramita_gestion.sseguro%TYPE,
      pnsinies IN sin_tramita_gestion.nsinies%TYPE,
      pntramit IN sin_tramita_gestion.ntramit%TYPE,
      pcgarant IN sin_tramita_gestion.cgarant%TYPE,
      pctipreg IN sin_tramita_gestion.ctipreg%TYPE,   -- este campo no se tiene en cuenta
      pctipges IN sin_tramita_gestion.ctipges%TYPE,
      psprofes IN sin_tramita_gestion.sprofes%TYPE,
      pctippro IN sin_tramita_gestion.ctippro%TYPE,
      pcsubpro IN sin_tramita_gestion.csubpro%TYPE,
      pspersed IN sin_tramita_gestion.spersed%TYPE,
      psconven IN sin_tramita_gestion.sconven%TYPE,
      pccancom IN sin_tramita_gestion.ccancom%TYPE,
      pccomdef IN sin_tramita_gestion.ccomdef%TYPE,
      ptrefext IN sin_tramita_gestion.trefext%TYPE,
      pnlocali IN sin_tramita_gestion.nlocali%TYPE,   -- 27276
      pfgestio IN sin_tramita_gestion.fgestio%TYPE,   -- 26630
      psgestio OUT sin_tramita_gestion.sgestio%TYPE)
      RETURN NUMBER IS
/*************************************************************************
  Graba una fila en SIN_TRAMITA_GESTION
  return              : NUMBER 0 / 1
*************************************************************************/
      vctipreg       sin_tramita_gestion.ctipreg%TYPE;
      vpasexec       NUMBER;
      vparam         VARCHAR2(500)
         := 'parametros psseguro=' || psseguro || ' pnsinies=' || pnsinies || ' pntramit='
            || pntramit || ' pcgarant=' || pcgarant || ' pctipreg=' || pctipreg
            || ' pctipges=' || pctipges || ' psprofes=' || psprofes || ' pctippro='
            || pctippro || ' pcsubpro=' || pcsubpro || ' pspersed=' || pspersed
            || ' psconven=' || psconven || ' pccancom=' || pccancom || ' pccomdef='
            || pccomdef || ' ptrefext=' || ptrefext || ' pnlocali=' || pnlocali
            || ' pfgestio=' || pfgestio;
      hay_garantia   NUMBER;
      num_err        NUMBER;
   BEGIN
      vpasexec := 1;

      IF pcgarant IS NULL THEN   -- Si no hay garantia seleccionada, comprobamos si deberia haberla
         SELECT COUNT(*)
           INTO hay_garantia
           FROM sin_parges_res_garantia
          WHERE ctipges = pctipges
            AND cresgar = 1;

         IF hay_garantia > 0 THEN
            RETURN 9902630;
         END IF;
      END IF;

      SELECT sgestio.NEXTVAL
        INTO psgestio
        FROM DUAL;

      vpasexec := 2;

      SELECT ctipreg
        INTO vctipreg
        FROM sin_parges_tip_gestion
       WHERE ctipges = pctipges;

      vpasexec := 3;

      INSERT INTO sin_tramita_gestion
                  (sseguro, nsinies, ntramit, sgestio, cgarant, ctipreg, ctipges,
                   sprofes, ctippro, csubpro, spersed, sconven, ccancom, ccomdef,
                   trefext, nlocali, fgestio)   --26630
           VALUES (psseguro, pnsinies, pntramit, psgestio, pcgarant, vctipreg, pctipges,
                   psprofes, pctippro, pcsubpro, pspersed, psconven, pccancom, pccomdef,
                   ptrefext, pnlocali, pfgestio);   --26630

      --Ini Bug 26630:NSS:15/07/2013
      UPDATE sin_prof_profesionales
         SET sgestio = psgestio
       WHERE sgestio =(pnsinies *(-1));

      UPDATE sin_prof_tarifa
         SET sgestio = psgestio
       WHERE sgestio =(pnsinies *(-1));

      --Fin Bug 26630:NSS:15/07/2013
      vpasexec := 3;
      num_err := f_profesional_destinatario(pnsinies, pntramit, psprofes);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_gestiones.f_ins_gestion', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9902386;
   END f_ins_gestion;

   FUNCTION f_ins_detgestion(
      psgestio IN sin_tramita_detgestion.sgestio%TYPE,
      psservic IN sin_tramita_detgestion.sservic%TYPE,
      pncantid IN sin_tramita_detgestion.ncantid%TYPE,
      pcunimed IN sin_tramita_detgestion.cunimed%TYPE,
      pnvalser IN sin_tramita_detgestion.nvalser%TYPE,
      pcnocarg IN sin_tramita_detgestion.cnocarg%TYPE,
      pitotal IN sin_tramita_detgestion.itotal%TYPE,
      pccodmon IN sin_tramita_detgestion.ccodmon%TYPE,
      pfcambio IN sin_tramita_detgestion.fcambio%TYPE,
      pfalta IN sin_tramita_detgestion.falta%TYPE)
      RETURN NUMBER IS
/*************************************************************************
  Graba una linea de detalle en SIN_TRAMITA_DETGESTION
  return              : NUMBER 0 / 1
*************************************************************************/
      vparam         VARCHAR2(500)
         := 'parametros psgestio=' || psgestio || ' psservic=' || psservic || ' pncantid='
            || pncantid || ' pcunimed=' || pcunimed || ' pnvalser=' || pnvalser || ' pitotal='
            || pitotal || ' pccodmon=' || pccodmon || ' pfcambio=' || pfcambio;
      vpasexec       NUMBER := 0;
      vndetges       NUMBER := 0;
   BEGIN
      BEGIN
         SELECT NVL(MAX(ndetges), 0) + 1
           INTO vndetges
           FROM sin_tramita_detgestion
          WHERE sgestio = psgestio;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vndetges := 1;
      END;

      INSERT INTO sin_tramita_detgestion
                  (sgestio, sservic, ncantid, cunimed, nvalser, itotal, ccodmon,
                   fcambio, ndetges, falta, cnocarg)
           VALUES (psgestio, psservic, pncantid, pcunimed, pnvalser, pitotal, pccodmon,
                   pfcambio, vndetges, NVL(pfalta, f_sysdate), pcnocarg);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_gestiones.f_ins_detgestion', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9902387;
   END f_ins_detgestion;

   FUNCTION f_ins_movgestion(
      psgestio IN sin_tramita_movgestion.sgestio%TYPE,
      pctipmov IN sin_tramita_movgestion.ctipmov%TYPE,
      pctipges IN sin_tramita_gestion.ctipges%TYPE,
      ptcoment IN sin_tramita_movgestion.tcoment%TYPE,
      pcestges IN sin_tramita_movgestion.cestges%TYPE,
      pcsubges IN sin_tramita_movgestion.csubges%TYPE)
      RETURN NUMBER IS
/*************************************************************************
  Graba un movimiento de gestion en SIN_TRAMITA_MOVGESTION
  param in  psgestio  : clave de sin_tramita_gestion
  param in  pctipmov  : moviento
  param in  pctipges  : tipo de gestion
  return              : NUMBER 0 / 1
*************************************************************************/
      vnmovges       NUMBER;   -- movimiento anterior
      vfmovini       DATE;
      vfprxbs        DATE;
      -- campos movimiento anterior
      vfinicio       DATE;
      vfproxim       DATE;
      vflimite       DATE;
      vfaccion       DATE;
      vcaccion       NUMBER;
      vnmaxava       NUMBER;
      vntotava       NUMBER;
      -- parametrizacion
      vcestges       NUMBER;   -- estado de la gestion despues del movimiento
      vcsubges       NUMBER;   -- subestado despues
      vnfprxbs       NUMBER;   -- fecha proximo a partir de f_sysdate(1) o finicio(2)
      vnfprxum       NUMBER;   -- calculo proximo horas/dias
      vnfprxnd       NUMBER;   -- numero de dias (o horas) a sumar
      vnflimit       NUMBER;   -- dias a sumar para calculo flimite
      vnfaccio       NUMBER;   -- dias a sumar a fproximo para calcular faccion
      vnavaper       NUMBER;   -- Total avances permitidos
      vnavance       NUMBER;   -- El movimiento es entrega de avance si/no
      vnaccion       NUMBER;   -- Carga de trabajo ajustada si se alcanza la fecha de faccion
      vcreserv       NUMBER;   -- Indica si se ha de ajustar la reserva null=no 0=liberar 1=constituir
      vcevento       sin_parges_movimientos.cevento%TYPE;   -- Apuntes automaticos en agenda
      --
      vitotal        NUMBER;
      vccodmon       VARCHAR2(3);
      --
      vnerror        NUMBER;
      vpasexec       NUMBER;
      vparam         VARCHAR2(500)
         := 'psgestio=' || psgestio || ' pctipmov=' || pctipmov || ' pctipges=' || pctipges
            || ' tcoment=' || SUBSTR(ptcoment, 1, 100);
   BEGIN
      vpasexec := 1;

      SELECT MAX(nmovges)
        INTO vnmovges
        FROM sin_tramita_movgestion
       WHERE sgestio = psgestio;

      vpasexec := 2;

      IF vnmovges IS NULL THEN
         vnmovges := 0;
         vfinicio := f_sysdate;
         vnmaxava := 0;
         vntotava := 0;
      ELSE
         SELECT finicio, fproxim, flimite, faccion, caccion, nmaxava, ntotava
           INTO vfinicio, vfproxim, vflimite, vfaccion, vcaccion, vnmaxava, vntotava
           FROM sin_tramita_movgestion
          WHERE sgestio = psgestio
            AND nmovges = vnmovges;
      END IF;

      vpasexec := 3;

      SELECT nfprxbs, nfprxum, nfprxnd, nflimit, nfaccio, naccion, navaper, navance,
             creserv, cestges, csubges, cevento
        INTO vnfprxbs, vnfprxum, vnfprxnd, vnflimit, vnfaccio, vnaccion, vnavaper, vnavance,
             vcreserv, vcestges, vcsubges, vcevento
        FROM sin_parges_movimientos
       WHERE ctipges = pctipges
         AND ctipmov = pctipmov;

      -- avances permitidos
      IF vnavaper IS NULL THEN
         vnavaper := vnmaxava;
      END IF;

      -- Fecha del movimiento
      vfmovini := f_sysdate;
      vpasexec := 4;

      -- Calculo fecha proximo movimiento
      IF NVL(vnfprxbs, 0) = 1 THEN   -- Fecha proximo en funcion de f_sysdate
         vfprxbs := f_sysdate;
      ELSE   -- Fecha proximo en funcion de finicio
         vfprxbs := vfinicio;
      END IF;

      IF vnfprxnd IS NOT NULL THEN   -- Si hay que calcular nueva fecha proximo
         IF vnfprxum = 1 THEN   -- dias naturales
            NULL;
         ELSIF vnfprxum = 2 THEN   -- dias reales
            vfproxim := vfprxbs + vnfprxnd;
         ELSIF vnfprxum = 3 THEN   -- horas naturales
            NULL;
         ELSIF vnfprxum = 4 THEN   -- horas reales
            vfproxim := vfprxbs +(vnfprxnd / 24);
         END IF;
      END IF;

      vpasexec := 5;

      -- Calculo fecha limite de la gestion
      IF vnflimit IS NOT NULL THEN   -- Se recalcula la fecha limite
         vflimite := vfinicio + vnflimit;   -- ATENCION SON DIAS NATURALES!!
      END IF;

      -- Calculo fecha de accion
      IF vnfaccio IS NOT NULL THEN   -- Se calcula
         vfaccion := vfproxim + vnfaccio;   -- ATENCION SON DIAS NATURALES!!
      END IF;

      IF vnaccion IS NOT NULL THEN
         vcaccion := vnaccion;
      END IF;

      -- Si el movimiento es de avance, actualizamos el numero de avances consumidos
      IF NVL(vnavance, 0) = 1 THEN
         vntotava := vntotava + 1;

         IF vntotava > vnmaxava THEN   -- si ha superado el numero de avances permitidos
            vntotava := 99;
         END IF;
      END IF;

      vpasexec := 6;

      UPDATE sin_tramita_movgestion
         SET fmovfin = f_sysdate
       WHERE sgestio = psgestio
         AND nmovges = vnmovges;

      vpasexec := 7;

      IF vcestges = -1 THEN   -- es un movimiento de observacion, que no cambia ningun estado ni fecha solo el comentario
         INSERT INTO sin_tramita_movgestion
                     (sgestio, nmovges, ctipmov, cestges, csubges, tcoment, fmovini, fmovfin,
                      finicio, fproxim, flimite, faccion, caccion, nmaxava, ntotava)
            SELECT sgestio, vnmovges + 1, pctipmov, cestges, csubges, ptcoment, fmovini,
                   fmovfin, finicio, fproxim, flimite, faccion, caccion, nmaxava, ntotava
              FROM sin_tramita_movgestion
             WHERE sgestio = psgestio
               AND nmovges = vnmovges;
      ELSE
         INSERT INTO sin_tramita_movgestion
                     (sgestio, nmovges, ctipmov, cestges,
                      csubges, tcoment, fmovini, fmovfin, finicio, fproxim,
                      flimite, faccion, caccion, nmaxava, ntotava)
              VALUES (psgestio, vnmovges + 1, pctipmov, NVL(pcestges, vcestges),
                      NVL(pcsubges, vcsubges), ptcoment, vfmovini, NULL, vfinicio, vfproxim,
                      vflimite, vfaccion, vcaccion, vnmaxava, vntotava);
      END IF;

      vpasexec := 8;

      IF NVL(vcreserv, 99) IN(0, 1, 2) THEN   -- si hay que ajustar la reserva -- 26592
         SELECT SUM(itotal), MAX(ccodmon)
           INTO vitotal, vccodmon
           FROM sin_tramita_detgestion
          WHERE sgestio = psgestio;

         --  26592 ini
         /*
         IF NVL(vcreserv, 2) = 1 THEN   -- constituir reserva
            vnerror :=
            (psgestio, vitotal, vccodmon, 1);
         ELSIF NVL(vcreserv, 2) = 0 THEN   -- liberar reserva
            vnerror := f_ajusta_reserva(psgestio, vitotal, vccodmon, 0);
         END IF;   -- llamar a pac_siniestros.f_ins_reserva para grabar/modificar
         */
         vnerror := f_ajusta_reserva(psgestio, vitotal, vccodmon, vcreserv);
      -- 26592 fin
      END IF;

      IF vcevento IS NOT NULL THEN
        IF UPPER(SUBSTR(vcevento, 0,6)) = 'CORREO' THEN

          vnerror := f_agenda_asignacion(psgestio, vcevento);

        ELSE
          vnerror := f_apunte_agenda(psgestio, vcevento, ptcoment);
        END IF;
        IF vnerror <> 0 THEN
          RETURN vnerror;
        END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_gestiones.f_ins_movgestion', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9902635;
   END f_ins_movgestion;

   FUNCTION f_nom_prof(psprofes IN NUMBER)
      RETURN VARCHAR2 IS
/*************************************************************************
  Devuelve el nombre de un profesional
  return              : VARCHAR2
*************************************************************************/
      vsperson       NUMBER;
      vnombre        VARCHAR2(200);
   BEGIN
      SELECT sperson
        INTO vsperson
        FROM sin_prof_profesionales
       WHERE sprofes = psprofes;

      vnombre := f_nombre(vsperson, 1);
      RETURN vnombre;
   END f_nom_prof;

   FUNCTION f_ajusta_reserva(
      psgestio IN NUMBER,
      pitotal IN NUMBER,
      pccodmon IN VARCHAR2,
      pmodo IN NUMBER)
      RETURN NUMBER IS
/*************************************************************************
  Graba un movimiento de reserva
  param in sgestio    : clave de gestion
  param in itotal     : importe del movimiento
  param in ccodmon    : codigo de moneda
  param in modo       : 0-disminuye 1-aumenta 2-Actualiza con el valor actual
  return              : Number
*************************************************************************/-- INPUESTOS ini
      vnerror        NUMBER;
      vnsinies       sin_siniestro.nsinies%TYPE;
      vntramit_gestion sin_tramita_reserva.ntramit%TYPE;
--      vntramit_reserva sin_tramita_reserva.ntramit%TYPE;
      vctipgas       sin_tramita_reserva.ctipgas%TYPE;
      vcgarant       sin_tramita_reserva.cgarant%TYPE;
      vsgestio       sin_tramita_gestion.sgestio%TYPE;
      vsprofes       sin_tramita_gestion.sprofes%TYPE;
      vsperson       per_personas.sperson%TYPE;
      vireserv       sin_tramita_reserva.ireserva%TYPE;
      vicaprie       sin_tramita_reserva.icaprie%TYPE;
      vipago         sin_tramita_reserva.ipago%TYPE;
      vipenali       sin_tramita_reserva.ipenali%TYPE;
      viingreso      sin_tramita_reserva.iingreso%TYPE;
      virecobro      sin_tramita_reserva.irecobro%TYPE;
      vfresini       sin_tramita_reserva.fresini%TYPE;
      vfresfin       sin_tramita_reserva.fresfin%TYPE;
      vfultpag       sin_tramita_reserva.fultpag%TYPE;
      vsidepag       sin_tramita_reserva.sidepag%TYPE;
      viprerec       sin_tramita_reserva.iprerec%TYPE;
      vifranq        sin_tramita_reserva.ifranq%TYPE;
      vctipper       per_personas.ctipper%TYPE;
      vcregfiscal    per_regimenfiscal.cregfiscal%TYPE;
      vcprofes       per_detper.cprofes%TYPE;
      vcpais         provincias.cpais%TYPE;
      vcprovin       provincias.cprovin%TYPE;
      vcpoblac       poblaciones.cpoblac%TYPE;
      vnewtotal      NUMBER;
      vnmovres       NUMBER;
      vctipges       NUMBER;
      hay_garantia   NUMBER;
      cuantas_hay    NUMBER;
      vmodo          NUMBER;
      vtotal_gas     NUMBER;
      vbase          NUMBER;
      vtot_imp       NUMBER;
      vsimplog       NUMBER;
      calcula_impuestos NUMBER;   -- 1:si 0:No
      hay_reserva    NUMBER;
      leer_otro      EXCEPTION;
      -- IMPUESTOS fin
      vitotimp       NUMBER;   --------------- IMPUESTOS2 (recoge el valor en la tabla)
      vtotal_imp     NUMBER;   --------------- IMPUESTOS2 (acumula los impestos de un registro)
      vcmovres       NUMBER;   --Bug 31294/174788:NSS:22/05/2014
      vdummy         NUMBER;
      vcestsin       NUMBER;
   BEGIN
      vmodo := pmodo;

      SELECT g.nsinies, g.ntramit, g.cgarant, g.ctipges, g.sgestio, g.sprofes
        INTO vnsinies, vntramit_gestion, vcgarant, vctipges, vsgestio, vsprofes
        FROM sin_tramita_gestion g
       WHERE g.sgestio = psgestio;

      IF vcgarant IS NULL THEN   -- Si no hay garantia seleccionada, comprobamos si deberia haberla
         SELECT COUNT(*)
           INTO hay_garantia
           FROM sin_parges_res_garantia
          WHERE ctipges = vctipges
            AND cresgar = 1;

         IF hay_garantia > 0 THEN
            RETURN 9902630;
         END IF;
      END IF;

-- 29801:ASN:14/02/2014 ini
/*
      IF vmodo = 2 THEN   -- Si se ha de sustituir la reserva inicial
         SELECT COUNT(*)
           INTO cuantas_hay
           FROM sin_tramita_gestion g, sin_tramita_movgestion m
          WHERE m.sgestio = g.sgestio
            AND g.nsinies = vnsinies
            AND g.ctipges =
                           vctipges   -- si va por tipo gestion el tipo de reserva ha de ser unico
            AND m.ctipmov IN(SELECT ctipmov
                               FROM sin_parges_movimientos
                              WHERE ctipges = vctipges
                                AND creserv = 2)   -- buscamos si hay movimientos que sustituyan la reserva inicial
            AND m.nmovges <
                   (SELECT MAX(nmovges)   -- sin contar el movimiento que acabamos de dar de alta
                      FROM sin_tramita_movgestion m1
                     WHERE m1.sgestio = m.sgestio);

         IF cuantas_hay = 0 THEN   -- Si aun no se ha sustituido la reserva inicial
                                   -- buscamos la tramitacion donde se creo la reserva en el alta (la que vamos a dar de baja)
--            vntramit_gestion := vntramit;
            SELECT MIN(ntramit)
              INTO vntramit_reserva
              FROM sin_tramita_reserva
             WHERE nsinies = vnsinies
               AND ctipres = 3
               AND(((vctipges = 200
                     AND ctipgas = 30)
                    OR(vctipges = 201
                       AND ctipgas = 31))   -- IMPUESTOS
                   OR(vctipges = 202
                      AND ctipgas IN(30, 31)));
         ELSE
            vmodo := 1;   -- si no es la primera vez, simplememte se acumula la reserva como en los casos 'normales'
            vntramit_reserva := vntramit_gestion;
         END IF;
      ELSE
         vntramit_reserva := vntramit_gestion;
      END IF;
*/
-- 29801:ASN:14/02/2014 fin

      -- Comprobamos si se han de calcular los impuestos
      SELECT pac_parametros.f_parempresa_n(cempres, 'CALCULO_IMP')
        INTO calcula_impuestos
        FROM seguros se, sin_siniestro si
       WHERE si.sseguro = se.sseguro
         AND nsinies = vnsinies;

      IF calcula_impuestos = 1 THEN
         -- recuperamos datos fiscales del profesional
         SELECT sperson
           INTO vsperson
           FROM sin_prof_profesionales
          WHERE sprofes = vsprofes;

         vnerror := pac_sin_impuestos.f_destinatario(vsperson, NULL, f_sysdate, psgestio,
                                                     vctipper, vcregfiscal, vcprofes, vcpais,
                                                     vcprovin, vcpoblac);

         IF vnerror <> 0 THEN
            RETURN vnerror;
         END IF;
      END IF;

      FOR i IN (SELECT   pg.ctipgas, g.ctipges, t.starifa, MAX(g.sprofes) sprofes,
                         MAX(nsinies) nsinies, MAX(ntramit) ntramit, MAX(nlocali) nlocali
                    FROM sin_tramita_gestion g, sin_tramita_detgestion dg, sin_dettarifas dt,
                         sin_parges_reserva pg, sin_prof_tarifa t
                   WHERE dg.sgestio = g.sgestio
                     AND dg.sservic = dt.sservic
                     AND g.sgestio = psgestio
                     AND g.ctipges = pg.ctipges
                     AND dt.ctipser = pg.ctipser
                     AND t.sconven = g.sconven
                     AND dt.starifa = t.starifa
                GROUP BY pg.ctipgas, g.ctipges, t.starifa) LOOP   -- por cada tipo de gasto en reservas (por cada registro de reserva que se creara/modificara)
         BEGIN   -- LOOP
            vtotal_gas := 0;
            vtotal_imp := 0;   --------------- IMPUESTOS2

            -- calculamos los impuestos (cada tipo de servicio puede tener un tratamiento fiscal diferente. Leemos por tipo de calculo)
            FOR j IN (SELECT   NVL(si.cconcep, -1) cconcep, SUM(dg.itotal) itotal,
                               MAX(dg.ccodmon) ccodmon
                          FROM sin_tramita_detgestion dg, sin_dettarifas dt,
                               sin_parges_reserva pg, sin_imp_servicios si
                         WHERE dg.sservic = dt.sservic
                           AND dt.starifa = i.starifa
                           AND pg.ctipges = i.ctipges
                           AND pg.ctipgas = i.ctipgas
                           AND pg.ctipser = dt.ctipser
                           AND dt.ctipser = si.ctipser(+)
                           AND dg.sgestio = psgestio
                      GROUP BY NVL(si.cconcep, -1)) LOOP
               vbase := j.itotal;
               vtot_imp := 0;

               IF calcula_impuestos = 1 THEN
                  -- llamada al calculo para j.itotal
                  vnerror := pac_sin_impuestos.f_calc_tot_imp(f_sysdate, NULL, psgestio,
                                                              i.ctipgas, j.cconcep, vbase,
                                                              vctipper, vcregfiscal, vcprofes,
                                                              vcpais, vcprovin, vcpoblac,
                                                              vsimplog, vtot_imp);

                  IF vnerror <> 0 THEN
                     RETURN vnerror;
                  END IF;
               END IF;

               -- acumular importe para i.ctipgas
--               vtotal_gas := vtotal_gas + vbase + vtot_imp;  --------------- IMPUESTOS2
               vtotal_gas := vtotal_gas + vbase;   --------------- IMPUESTOS2
               vtotal_imp := vtotal_imp + vtot_imp;   --------------- IMPUESTOS2
            END LOOP;

            BEGIN
               SELECT ireserva, ipago, icaprie, ipenali, iingreso, irecobro, fresini,
                      fresfin, fultpag, NULL, iprerec,
                      itotimp   --------------- IMPUESTOS2
                 INTO vireserv, vipago, vicaprie, vipenali, viingreso, virecobro, vfresini,
                      vfresfin, vfultpag, vsidepag, viprerec,
                      vitotimp   --------------- IMPUESTOS2
                 FROM sin_tramita_reserva str
                WHERE str.nsinies = vnsinies
                  AND str.ntramit = vntramit_gestion
                  AND str.cmonres = pccodmon
                  AND str.ctipres = 3
                  AND str.ctipgas = i.ctipgas
                  AND NVL(str.cgarant, -1) = NVL(vcgarant, -1)
                  AND str.nmovres = (SELECT MAX(nmovres)
                                       FROM sin_tramita_reserva
                                      WHERE nsinies = str.nsinies
                                        AND ntramit = str.ntramit
                                        AND cmonres = str.cmonres
                                        AND ctipres = str.ctipres
                                        AND ctipgas = str.ctipgas
                                        AND NVL(cgarant, -1) = NVL(vcgarant, -1)
                                        AND fmovres <= f_sysdate);
            EXCEPTION
               WHEN OTHERS THEN
                  IF pmodo = 0 THEN
--               RETURN 9901216;
                     RAISE leer_otro;
                  END IF;

                  vireserv := 0;
                  vicaprie := NULL;
                  vipenali := NULL;
                  viingreso := NULL;
                  virecobro := NULL;
                  vfresini := NULL;
                  vfresfin := NULL;
                  vfultpag := NULL;
                  vsidepag := NULL;
                  viprerec := NULL;
                  vnmovres := NULL;
            END;

            -- insert/update reserva
            IF vmodo = 0 THEN
               vnewtotal := vireserv - vtotal_gas;
               vitotimp := vitotimp - vtotal_imp;   --------------- IMPUESTOS2
            ELSIF vmodo = 1 THEN
               vnewtotal := vireserv + vtotal_gas;
               vitotimp := vitotimp + vtotal_imp;   --------------- IMPUESTOS2
            ELSE
               vnewtotal := vtotal_gas;
               vitotimp := vtotal_imp;   --------------- IMPUESTOS2
-- 29801:ASN:14/02/2014 ini
            END IF;

/*
               SELECT COUNT(*)
                 INTO hay_reserva
                 FROM sin_tramita_reserva
                WHERE nsinies = vnsinies
                  AND ntramit = vntramit_reserva
                  AND ctipres = 3
                  AND ctipgas = i.ctipgas;

               IF hay_reserva > 0 THEN
                  -- anulamos la reserva del alta
                  vnerror := pac_siniestros.f_ins_reserva(vnsinies, vntramit_reserva, 3,
                                                          vcgarant, 0, f_sysdate, pccodmon, 0,
                                                          vipago, 0, vipenali, viingreso,
                                                          virecobro, vfresini, vfresfin,
                                                          vfultpag, NULL, viprerec, i.ctipgas,
                                                          vnmovres, NULL,
                                                          0   --------------- IMPUESTOS2
                                                           );
               END IF;
--               vntramit := vntramit_gestion;   -- Recuperamos la tramitacion donde se ha creado la gestion
            END IF;

*/
-- 29801:ASN:14/02/2014 fin
            IF vnewtotal < 0 THEN   --  El importe no puede ser superior al importe de la reserva ????????????
               RETURN 9901216;
            END IF;

            IF vnewtotal = vicaprie
               AND vmodo = 2 THEN
               RAISE leer_otro;
            END IF;

            IF vnewtotal <> vireserv THEN
               vnmovres := NULL;

               --INI Bug 31294/174788:NSS:22/05/2014
               IF vnewtotal > vireserv THEN
                  vcmovres := 2;
               ELSIF vnewtotal < vireserv THEN
                  vcmovres := 3;
               END IF;

               --FIN Bug 31294/174788:NSS:22/05/2014
               vnerror :=
                  pac_siniestros.f_ins_reserva(vnsinies, vntramit_gestion, 3, vcgarant, 1,   -- Bug 29801 - 24/07/2014 - JTT
                                               f_sysdate, pccodmon, vnewtotal, vipago,
                                               vnewtotal,   --vicaprie,
                                               vipenali, viingreso, virecobro, vfresini,
                                               vfresfin, vfultpag, NULL, viprerec, i.ctipgas,
                                               vnmovres, vcmovres,   --Bug 31294/174788:NSS:22/05/2014
                                               NULL, vitotimp   --------------- IMPUESTOS2
                                                             );
            END IF;
         EXCEPTION
            WHEN leer_otro THEN
               NULL;
         END;   -- loop
      END LOOP;

      -- IMPUESTOS fin

      -- Bug 31364 - 09/09/2014 - JTT: Si el estado del siniestro es PRESINIESTRO llamamos a la funcion  -- DEMO PSN
      -- de cambio de estado a siniestro.
      SELECT m.cestsin
        INTO vcestsin
        FROM sin_movsiniestro m
       WHERE m.nsinies = vnsinies
         AND m.nmovsin = (SELECT MAX(nmovsin)
                            FROM sin_movsiniestro a
                           WHERE a.nsinies = m.nsinies);

      IF vcestsin = 5 THEN
         vnerror := pac_siniestros.f_estado_final(vnsinies, vdummy);
      END IF;

      -- Fi bug 31364
      RETURN 0;
   END f_ajusta_reserva;

   FUNCTION f_val_gestiones_abiertas(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE)
      RETURN NUMBER IS
      /*************************************************************************
          Comprueba si hay gestiones pendientes en una tramitacion
          param in  pnsinies : numero de siniestro
          param in  pntramit : numero de tramitacion
          return             : number (total tramitaciones abiertas)
       *************************************************************************/
      vtot_gestiones NUMBER;
   BEGIN
      SELECT COUNT(*)
        INTO vtot_gestiones
        FROM sin_tramita_movgestion m, sin_tramita_gestion g
       WHERE m.sgestio = g.sgestio
         AND m.fmovfin IS NULL
         AND g.nsinies = pnsinies
         AND g.ntramit = pntramit
         AND m.cestges = 0;

      RETURN vtot_gestiones;
   END f_val_gestiones_abiertas;

   FUNCTION f_profesional_destinatario(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      psprofes IN sin_prof_profesionales.sprofes%TYPE)
      RETURN NUMBER IS
      /*************************************************************************
          Da de alta como destinatario al profesional asignado
          param in  pnsinies : numero de siniestro
          param in  pntramit : numero de tramitacion
          param in  psprofes : clave de proveedor
          return             : number
       *************************************************************************/
      v_sperson      per_personas.sperson%TYPE;
      v_cnordban     sin_prof_ccc.cnordban%TYPE;
      v_cbancar      per_ccc.cbancar%TYPE;
      v_ctipban      per_ccc.ctipban%TYPE;
      v_cramo        seguros.cramo%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      v_cactivi      seguros.cactivi%TYPE;
      v_sperson_prof per_personas.sperson%TYPE;
      v_sperson_empresa per_personas.sperson%TYPE;
      vpasexec       NUMBER;
      vparam         VARCHAR2(500)
            := 'pnsinies=' || pnsinies || ' pntramit=' || pntramit || ' psprofes=' || psprofes;
      num_err        NUMBER;
   BEGIN
      vpasexec := 10;

      SELECT sperson
        INTO v_sperson_prof
        FROM sin_prof_profesionales
       WHERE sprofes = psprofes;

      vpasexec := 11;

      SELECT sperson
        INTO v_sperson_empresa
        FROM empresas
       WHERE cempres = f_empres;

      IF v_sperson_prof = v_sperson_empresa THEN
         RETURN 0;
      END IF;

      vpasexec := 1;

      SELECT se.cramo, se.cactivi, se.sproduc
        INTO v_cramo, v_cactivi, v_sproduc
        FROM seguros se, sin_siniestro si
       WHERE si.sseguro = se.sseguro
         AND si.nsinies = pnsinies;

      vpasexec := 2;

      SELECT sperson
        INTO v_sperson
        FROM sin_prof_profesionales
       WHERE sprofes = psprofes;

      vpasexec := 3;

      BEGIN
         SELECT cnordban
           INTO v_cnordban
           FROM sin_prof_ccc
          WHERE sprofes = psprofes
            AND cramo = v_cramo
            AND sproduc = v_sproduc
            AND cactivi = v_cactivi;
      EXCEPTION
         WHEN OTHERS THEN
            BEGIN
               SELECT cnordban
                 INTO v_cnordban
                 FROM sin_prof_ccc
                WHERE sprofes = psprofes
                  AND cramo = v_cramo
                  AND sproduc = v_sproduc;
            EXCEPTION
               WHEN OTHERS THEN
                  BEGIN
                     SELECT cnordban
                       INTO v_cnordban
                       FROM sin_prof_ccc
                      WHERE sprofes = psprofes
                        AND cramo = v_cramo;
                  EXCEPTION
                     WHEN OTHERS THEN
                        BEGIN
                           SELECT cnordban
                             INTO v_cnordban
                             FROM sin_prof_ccc
                            WHERE sprofes = psprofes;
                        EXCEPTION
                           WHEN OTHERS THEN
                              v_cnordban := NULL;
                        END;
                  END;
            END;
      END;

      vpasexec := 4;

      IF v_cnordban IS NOT NULL THEN
         SELECT cbancar, ctipban
           INTO v_cbancar, v_ctipban
           FROM per_ccc
          WHERE sperson = v_sperson
            AND cnordban = v_cnordban;
      END IF;

      vpasexec := 5;
      num_err := pac_siniestros.f_ins_destinatario(pnsinies, pntramit, v_sperson, v_cbancar,
                                                   v_ctipban, NULL, NULL, 53, 1, NULL, NULL,
                                                   NULL, psprofes);   -- 22/07/2014 -  JTT: ctipdes = 53
                                                                      -- 01/04/2015 -  JTT: sprofes = psprofes

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_gestiones.f_ins_profesional_destinatario',
                     vpasexec, vparam, 'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 102696;   -- Error al grabar en destinatarios
   END f_profesional_destinatario;

   FUNCTION f_apunte_agenda(
      psgestio IN sin_tramita_gestion.sgestio%TYPE,
      pcevento IN sin_prof_apuntes.cevento%TYPE,
      ptcoment IN sin_tramita_movgestion.tcoment%TYPE)
      RETURN NUMBER IS
/*************************************************************************
    Da de alta apuntes predefinidos en agenda
    param in  psgestio : clave de gestiones
    param in  pcevento : clave de evento SIN_PROF_APUNTES
    return             : number
 *************************************************************************/
      vpasexec       NUMBER;
      vparam         VARCHAR2(500) := 'psgestio=' || psgestio || ' pcevento=' || pcevento;
      num_err        NUMBER;
      vidapunte      NUMBER;
      vcempres       NUMBER;
      vcidioma       NUMBER;
      vtitulo        VARCHAR2(100);
      vcuerpo        VARCHAR2(2000);
      vsprofes       NUMBER;
      vctipges       NUMBER;
      vcusuari       usuarios.cusuari%TYPE;
      vsconven       sin_tramita_gestion.sconven%TYPE;
      vnsinies       sin_siniestro.nsinies%TYPE;
      vntramit       sin_tramita_movimiento.ntramit%TYPE;
      vctramitad     sin_tramita_movimiento.ctramitad%TYPE;
      vslittit       NUMBER;
      vslitbod       NUMBER;
      vctipage       NUMBER;
      vctpdest       NUMBER;
      vmail_from     per_contactos.tvalcon%TYPE;
      vmail_to       per_contactos.tvalcon%TYPE;
   BEGIN
      vpasexec := 1;

      SELECT slittit, slitbod, ctipage, ctpdest
        INTO vslittit, vslitbod, vctipage, vctpdest
        FROM sin_prof_apuntes
       WHERE cevento = pcevento;

      vpasexec := 2;

      SELECT nsinies, ntramit, sprofes, ctipges, sconven
        INTO vnsinies, vntramit, vsprofes, vctipges, vsconven
        FROM sin_tramita_gestion
       WHERE sgestio = psgestio;

      IF vctipage = 2
         --AND vctpdest = 1 THEN   -- apunte para el profesional  -- 26592
         AND vctpdest IN(1, 3) THEN   -- apunte para el profesional/Taller  --26592
         vpasexec := 3;

         BEGIN
            SELECT cusuari
              INTO vcusuari
              FROM sin_prof_profesionales p, usuarios u
             WHERE p.sperson = u.sperson
               AND p.sprofes = vsprofes;
         EXCEPTION
            WHEN OTHERS THEN
               vcusuari := NULL;   -- si el profesional no tiene usuario no enviamos apunte a la agenda
         END;
      ELSIF vctipage = 2
            AND vctpdest = 2 THEN   -- apunte para el tramitador
         -- 23182:ASN:30/07/2012 ini
         vpasexec := 21;

         SELECT ctramitad
           INTO vctramitad
           FROM sin_tramita_movimiento m
          WHERE nsinies = vnsinies
            AND ntramit = vntramit
            AND nmovtra = (SELECT MAX(nmovtra)
                             FROM sin_tramita_movimiento m1
                            WHERE m1.nsinies = m.nsinies
                              AND m1.ntramit = m.ntramit);

         vpasexec := 22;

         SELECT cusuari
           INTO vcusuari
           FROM sin_codtramitador
          WHERE ctramitad = vctramitad;
      -- 23182:ASN:30/07/2012 fin
      ELSE
         RETURN 0;
      END IF;

      vcempres := pac_md_common.f_get_cxtempresa;
      vcidioma := pac_md_common.f_get_cxtidioma;
      vpasexec := 23;

      SELECT f_axis_literales(vslittit, vcidioma)
        INTO vtitulo
        FROM DUAL;

      SELECT f_axis_literales(vslitbod, vcidioma)
        INTO vcuerpo
        FROM DUAL;

      -- 26592 ini
      IF vctpdest = 3 THEN   -- Taller  (descripcion vehiculo y documentacion requerida)
         vpasexec := 24;

         SELECT vcuerpo || CHR(10) || f_axis_literales(9001045, vcidioma) || ': ' || cmatric
                || CHR(10) || (SELECT tmarca
                                 FROM aut_marcas
                                WHERE cmarca = dv.cmarca) || ' '
                || (SELECT tmodelo
                      FROM aut_modelos
                     WHERE cmodelo = dv.smodelo
                       AND cmarca = dv.cmarca) || ' ' || (SELECT tversion
                                                            FROM aut_versiones
                                                           WHERE cversion = dv.cversion)
                || CHR(10)
           INTO vcuerpo
           FROM sin_tramita_detvehiculo dv
          WHERE nsinies = vnsinies
            AND ntramit = vntramit;

         vpasexec := 25;

         FOR i IN (SELECT tdocume, ROWNUM
                     FROM sin_tramita_documento td, doc_desdocumento dd
                    WHERE dd.cdocume = td.cdocume
                      AND dd.cidioma = vcidioma
                      AND td.nsinies = vnsinies
                      AND(td.ntramit = vntramit
                          OR td.ntramit = 0)
                      AND td.cobliga = 1) LOOP
            IF i.ROWNUM = 1 THEN
               vcuerpo := vcuerpo || CHR(10) || f_axis_literales(9901998, vcidioma) || ':';   -- Documentacion obligatoria
            END IF;

            vcuerpo := vcuerpo || CHR(10) || '- ' || i.tdocume;
         END LOOP;
      ELSE
         -- 26592 fin
         vpasexec := 4;

         SELECT vcuerpo || ' (' || psgestio || ' - ' || tatribu
                || ')'   -- descripcion de la gestion
           INTO vcuerpo
           FROM detvalores
          WHERE cvalor = 722
            AND catribu = vctipges
            AND cidioma = vcidioma;

         vcuerpo := vcuerpo || CHR(10);
         vpasexec := 5;

         FOR i IN (SELECT d.tdescri
                     FROM sin_dettarifas d, sin_prof_tarifa t
                    WHERE t.starifa = d.starifa
                      AND t.sconven = vsconven
                      AND d.sservic IN(SELECT sservic
                                         FROM sin_tramita_detgestion
                                        WHERE sgestio = psgestio)) LOOP
            vcuerpo := vcuerpo || CHR(10) || '    - ' || i.tdescri;   -- detalle de servicios solicitados
         END LOOP;
      END IF;   -- 26592

      vcuerpo := vcuerpo || CHR(10) || CHR(10) || ptcoment;

      IF vcusuari IS NOT NULL THEN
         vpasexec := 6;
         num_err := pac_agenda.f_set_apunte(NULL, NULL, 0,   -- Código Clave Agenda 0:siniestro / 1:poliza
                                            vnsinies, 0, 0, NULL,   -- tipo de grupo
                                            NULL,   -- grupo asignado
                                            vtitulo, vcuerpo, 0, 0, NULL, NULL, f_user, NULL,
                                            f_sysdate, f_sysdate, NULL, vidapunte);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         vpasexec := 7;
         num_err := pac_agenda.f_set_agenda(vidapunte, NULL, vcusuari, NULL, NULL, 0, vnsinies,
                                            NULL, NULL, NULL, NULL, vcempres, vcidioma, NULL,
                                            vntramit   -- 20/11/2012
                                                    );

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      IF vctpdest IN(1, 3) THEN   -- Si el recipiente es un prof. externo enviamos tambien un e-mail
         vpasexec := 8;

         FOR i IN (SELECT   tvalcon
                       FROM (SELECT tvalcon, 1 orden
                               FROM sin_prof_profesionales p, per_contactos c
                              WHERE c.sperson = p.sperson
                                AND c.ctipcon = 3
                                AND c.cmodcon = p.cmodcon
                                AND sprofes = vsprofes
                             UNION
                             SELECT tvalcon, 2 orden
                               FROM sin_prof_profesionales p, per_contactos c
                              WHERE c.sperson = p.sperson
                                AND c.ctipcon = 3
                                AND sprofes = vsprofes)
                   ORDER BY orden) LOOP
            vmail_to := i.tvalcon;
            EXIT;
         END LOOP;

         IF vmail_to IS NULL THEN
            RETURN 9905253;   -- No se ha encontrado el correo del profesional
         END IF;

         BEGIN
            SELECT tvalpar
              INTO vmail_from
              FROM parempresas
             WHERE cempres = vcempres
               AND cparam = 'EMAIL_SINIS';
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 0;   -- Error al enviar correo
         END;

         p_enviar_correo(vmail_from, vmail_to, vmail_from, vmail_to, vtitulo, vcuerpo);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_gestiones.f_apunte agenda', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9903168;
   END f_apunte_agenda;

   FUNCTION f_crea_gestion(
      psseguro IN sin_tramita_gestion.sseguro%TYPE,
      pnsinies IN sin_tramita_gestion.nsinies%TYPE,
      pntramit IN sin_tramita_gestion.ntramit%TYPE,
      pnlocali IN sin_tramita_localiza.nlocali%TYPE,
      pcgarant IN sin_tramita_gestion.cgarant%TYPE,
      pctipges IN sin_tramita_gestion.ctipges%TYPE,
      pctippro IN sin_tramita_gestion.ctippro%TYPE,
      pcsubpro IN sin_tramita_gestion.csubpro%TYPE,
      psservic IN sin_dettarifas.sservic%TYPE,
      psgestio OUT sin_tramita_gestion.sgestio%TYPE)
      RETURN NUMBER IS
/*************************************************************************
  Crea una gestion y la asigna automaticamente a un profesional
  return              : NUMBER 0 / 1
*************************************************************************/
      vpasexec       NUMBER;
      vparam         VARCHAR2(500)
         := 'psseguro=' || psseguro || ' pnsinies=' || pnsinies || ' pntramit=' || pntramit
            || ' pnlocali=' || pnlocali || ' pcgarant=' || pcgarant || ' pctipges='
            || pctipges || ' pctippro=' || pctippro || ' pcsubpro=' || pcsubpro
            || ' psservic=' || psservic;
      vnum_err       NUMBER;
      vquery         VARCHAR2(4000);
      vcur           sys_refcursor;
      vsprofes       NUMBER;
      dummy1         VARCHAR2(200);
      dummy2         NUMBER;
      dummy3         NUMBER;
      dummy4         NUMBER;
      vsconven       NUMBER;
      vstarifa       NUMBER;
      vcunimed       NUMBER;
      viprecio       NUMBER;
      vccodmon       VARCHAR2(3);
      vcestges       NUMBER;
      vcsubges       NUMBER;
      otro           EXCEPTION;
   BEGIN
      vpasexec := 1;
      -- Obtenemos la lista de profesionales
      vnum_err := f_lstprofesional(pnsinies, pntramit, pnlocali, pctippro, pcsubpro, NULL,
                                   vquery);   --26630

      IF vnum_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'pac_gestiones.f_crea_gestion', vpasexec, vparam,
                     'num_err: ' || vnum_err);
         RETURN vnum_err;
      END IF;

      vpasexec := 2;

      OPEN vcur FOR vquery;

      LOOP
         BEGIN
            -- como la lista esta ordenada, el primero es el mas optimo
            FETCH vcur
             INTO vsprofes, dummy1, dummy2, dummy3, dummy4;

            -- Buscamos el baremo vigente para el profesional
            vpasexec := 3;

            BEGIN
               SELECT sconven, starifa
                 INTO vsconven, vstarifa
                 FROM sin_prof_tarifa
                WHERE sprofes = vsprofes
                  AND cestado = 1;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RAISE otro;
            END;

            -- Obtenemos el precio del servicio
            vpasexec := 4;

            BEGIN
               SELECT cunimed, GREATEST(iprecio, NVL(iminimo, 0)), ccodmon
                 INTO vcunimed, viprecio, vccodmon
                 FROM sin_dettarifas
                WHERE starifa = vstarifa
                  AND sservic = psservic;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RAISE otro;
            END;
         EXCEPTION
            WHEN otro THEN   -- si hay algun problema al recuperar la tarifa o el servicio leemos el siguiente de la lista
               NULL;
         END;

         EXIT WHEN vcur%NOTFOUND;
      END LOOP;

      CLOSE vcur;

       /*
      -- como la lista esta ordenada, el primero es el mas optimo
      OPEN vcur FOR vquery;

      FETCH vcur
       INTO vsprofes, dummy1, dummy2, dummy3, dummy4;

      CLOSE vcur;

      vpasexec := 2;

      -- Buscamos el baremo vigente para el profesional
      SELECT sconven, starifa
        INTO vsconven, vstarifa
        FROM sin_prof_tarifa
       WHERE sprofes = vsprofes
         AND cestado = 1;

      vpasexec := 3;

      -- Obtenemos el precio del servicio
      SELECT cunimed, GREATEST(iprecio, NVL(iminimo, 0)), ccodmon
        INTO vcunimed, viprecio, vccodmon
        FROM sin_dettarifas
       WHERE starifa = vstarifa
         AND sservic = psservic;
      */
      IF vstarifa IS NULL
         OR viprecio IS NULL THEN   -- si no ha sido capaz de encontrar la tarifa no damos de alta la gestion
         vnum_err := pac_tramitadores.f_msg_tramitador_global(pnsinies, NULL, pntramit, 1,
                                                              9904463, 9904463);

         IF vnum_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'pac_gestiones.f_crea_gestion', vpasexec, vparam,
                        'num_err: ' || vnum_err);
            RETURN vnum_err;
         END IF;

         RETURN 0;
      END IF;

      vpasexec := 5;

      -- Obtenemos el estado en el que ha de quedar la gestion
      SELECT cestges, csubges
        INTO vcestges, vcsubges
        FROM sin_parges_movimientos
       WHERE ctipges = pctipges
         AND ctipmov = 1;   -- alta

      vpasexec := 6;
      -- Creamos la gestion
      vnum_err := f_ins_gestion(psseguro, pnsinies, pntramit, pcgarant, NULL, pctipges,
                                vsprofes, pctippro, pcsubpro, NULL, vsconven, 1, 1, NULL,
                                pnlocali,   -- 27276,
                                NULL,   --26630
                                psgestio);

      IF vnum_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'pac_gestiones.f_crea_gestion', vpasexec, vparam,
                     'num_err: ' || vnum_err);
         RETURN vnum_err;
      END IF;

      vpasexec := 7;
      -- Creamos el detalle de la gestion
      vnum_err := f_ins_detgestion(psgestio, psservic, 1, vcunimed, viprecio, 1, viprecio,
                                   vccodmon, f_sysdate, f_sysdate);

      IF vnum_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'pac_gestiones.f_crea_gestion', vpasexec, vparam,
                     'num_err: ' || vnum_err);
         RETURN vnum_err;
      END IF;

      vpasexec := 8;
      vnum_err := f_ins_movgestion(psgestio, 1, pctipges, 'Asignación automática', vcestges,
                                   vcsubges);

      IF vnum_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'pac_gestiones.f_crea_gestion', vpasexec, vparam,
                     'num_err: ' || vnum_err);
         RETURN vnum_err;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_gestiones.f_crea_gestion', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9902386;
   END f_crea_gestion;

   FUNCTION f_gestion_modificable(psgestio IN NUMBER, psi_o_no OUT NUMBER)
      RETURN NUMBER IS
/*************************************************************************
   Decide si una gestion esta en un estado modificable
*************************************************************************/
      vpasexec       NUMBER;
      vparam         VARCHAR2(500);
      vcestges       sin_tramita_movgestion.cestges%TYPE;   --BUG 25913/176102:NSS:28/05/2014
      vctipges       sin_parges_movimientos.ctipges%TYPE;   --BUG 25913/176102:NSS:28/05/2014
   BEGIN
      --BUG 25913/176102:NSS:28/05/2014
      BEGIN
         SELECT cmodifi
           INTO psi_o_no
           FROM sin_parges_validacion
          WHERE ctipges = (SELECT ctipges
                             FROM sin_tramita_gestion
                            WHERE sgestio = psgestio);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            psi_o_no := 0;
      END;

      IF psi_o_no = 1 THEN
         SELECT cestges
           INTO vcestges
           FROM sin_tramita_movgestion
          WHERE nmovges = (SELECT MAX(nmovges)
                             FROM sin_tramita_movgestion
                            WHERE sgestio = psgestio)
            AND sgestio = psgestio;

         IF vcestges <> 0 THEN
            psi_o_no := 0;
         END IF;
      END IF;

      IF psi_o_no = 1 THEN
         BEGIN
            SELECT ctipges
              INTO vctipges
              FROM sin_parges_movimientos
             WHERE ctipges = (SELECT ctipges
                                FROM sin_tramita_gestion
                               WHERE sgestio = psgestio)
               AND ctipmov = 99;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               psi_o_no := 0;
         END;
      END IF;

      --FIN BUG 25913/176102:NSS:28/05/2014
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_gestiones.f_gestion_modificable', vpasexec,
                     vparam, 'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_gestion_modificable;

   FUNCTION f_lstprofesional1(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pnlocali IN NUMBER,
      pctippro IN NUMBER,
      pcsubpro IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
/*************************************************************************
  Devuelve query para carga lista de profesionales (cquery = 1)
  (solo filtra por zona)
  param in  pnsinies  : numero de siniestro
  param in  pntramit  : numero de tramitacion
  param in  pnlocali  : numero de localizacion
  param in  pctippro  : tipo de profesional
  param in  pcsubpro  : subtipo de profesional
  param out pquery    : select
  return              : NUMBER 0 / 1
*************************************************************************/
      vcpais         NUMBER;
      vcprovin       NUMBER;
      vcpoblac       NUMBER;
      vcpostal       NUMBER;
      vsproduc       NUMBER;
      vccausin       NUMBER;
      v_coste        NUMBER;
   BEGIN
      vtraza := 1;

      SELECT cpais, cprovin, cpoblac, cpostal
        INTO vcpais, vcprovin, vcpoblac, vcpostal
        FROM sin_tramita_localiza
       WHERE nsinies = pnsinies
         AND ntramit = pntramit
         AND nlocali = pnlocali;

      vtraza := 2;

      SELECT s.sproduc, si.ccausin
        INTO vsproduc, vccausin
        FROM sin_siniestro si, seguros s
       WHERE si.sseguro = s.sseguro
         AND si.nsinies = pnsinies;

      vtraza := 3;


            SELECT NVL(SUM(NVL(R1.IRESERVA_MONCIA, 0) +
                   NVL(R1.IPAGO_MONCIA, 0)),0)
              INTO v_coste
              FROM SIN_TRAMITA_RESERVA R1
             WHERE R1.NSINIES = pnsinies
              -- AND R1.CTIPRES = 1 Indemnizatoria INC 511 Y 782 CONF-1139 KJSC
               AND R1.NMOVRES = (SELECT MAX(R2.NMOVRES)
                                   FROM SIN_TRAMITA_RESERVA R2
                                  WHERE R2.NSINIES = R1.NSINIES
                                    AND R2.IDRES = R1.IDRES);

      pquery :=
         'select p.sprofes, f_nombre(p.sperson, 1) nombre '
         || ' from sin_prof_profesionales p, sin_prof_rol r, sin_prof_estados e, '
         || ' (select z.sprofes, max(z.ctpzona) ctpzona from sin_prof_zonas z '
         || ' where ((z.ctpzona = 4 and ' || NVL(vcpostal, -1)
         || ' between z.cposini and z.cposfin) '
         || '         or (z.ctpzona = 3 and z.cpoblac = ' || NVL(vcpoblac, -1)
         || ' and z.cprovin = ' || vcprovin || ' )'
         || '         or (z.ctpzona = 2 and z.cprovin = ' || vcprovin || ')'
         || '         or (z.ctpzona = 1 and z.cpais = ' || vcpais || '))'
         || ' group by z.sprofes ) zo' || ' where r.sprofes = p.sprofes'
         || '  and r.ctippro = ' || pctippro || '  and r.csubpro = ' || pcsubpro
         || '  and zo.sprofes = p.sprofes'
         || '   and p.sprofes not in (select sprofes from sin_prof_descartados d'
         || '                         where d.sprofes = p.sprofes'
         || '                           and (sproduc = ' || vsproduc || ' or ccausin = '
         || vccausin || ')' || '                           and f_sysdate >= fdesde'
         || '                           and (f_sysdate < fhasta or fhasta is null))'
         || ' and e.sprofes = p.sprofes' || ' and e.cestado = 1'
         || ' and e.festado = (select max(festado) from sin_prof_estados e1 where sprofes = p.sprofes and festado <= f_sysdate) ';

      -- INI BUG 511 - CONF-1139 ACL 19/01/2018
      /*IF pac_md_common.f_get_cxtempresa = 24 THEN
         pquery := pquery || ' and NVL(p.nlimite,0) >= '|| v_coste || '  ';
      END IF; */
      -- INI BUG 511 - CONF-1139 ACL 19/01/2018
      pquery := pquery || ' order by nombre';

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_GESTIONES.F_LSTPROFESIONALES', vtraza,
                     'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_lstprofesional1;

   FUNCTION f_borra_detalle(psgestio IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      DELETE      sin_tramita_detgestion
            WHERE sgestio = psgestio;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_gestiones.f_borra_detalle', 1,
                     'param - psgestio = ' || psgestio,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_borra_detalle;

   FUNCTION f_gestion_permitida(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pctipges IN NUMBER,
      pcidioma IN NUMBER,
      ptlitera OUT VARCHAR2)
      RETURN NUMBER IS
/*************************************************************************
   Decide si una gestion se puede dar de alta
*************************************************************************/
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500);
      vcuantos_hay   NUMBER;
      vnmaximo       NUMBER;
      vcgesprv       NUMBER;
   BEGIN
      BEGIN
         SELECT nmaximo, cgesprv   -- 26630:NSS:04/07/2013
           INTO vnmaximo, vcgesprv   --26630:NSS:04/072013
           FROM sin_parges_validacion
          WHERE ctipges = pctipges;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF vnmaximo IS NOT NULL THEN
         SELECT COUNT(*)
           INTO vcuantos_hay
           FROM sin_tramita_gestion g, sin_tramita_movgestion m
          WHERE m.sgestio = g.sgestio
            AND m.nmovges = (SELECT MAX(nmovges)
                               FROM sin_tramita_movgestion m1
                              WHERE m1.sgestio = m.sgestio)
            AND nsinies = pnsinies
            AND ntramit = pntramit
            AND ctipges = pctipges
            AND cestges = 0;

         IF vcuantos_hay >= vnmaximo THEN
            ptlitera := f_axis_literales(9905781, pcidioma);
            RETURN 0;
         END IF;
      END IF;

      --INI 26630:NSS:04/07/2013
      IF vcgesprv IS NOT NULL THEN
         vcuantos_hay := 0;

         SELECT COUNT(*)
           INTO vcuantos_hay
           FROM sin_tramita_gestion g, sin_tramita_movgestion m
          WHERE m.sgestio = g.sgestio
            AND m.nmovges = (SELECT MAX(nmovges)
                               FROM sin_tramita_movgestion m1
                              WHERE m1.sgestio = m.sgestio)
            AND nsinies = pnsinies
            AND ntramit = pntramit
            AND ctipges = vcgesprv
            AND cestges = 0;

         IF vcuantos_hay = 0 THEN
            ptlitera := REPLACE(f_axis_literales(9905758, pcidioma), '#1#',
                                ff_desvalorfijo(722, pcidioma, vcgesprv));
            RETURN 0;
         END IF;
      END IF;

      --FIN 26630:NSS:04/07/2013
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_gestiones.f_gestion_permitida', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_gestion_permitida;

   FUNCTION f_estado_valoracion(psgestio IN NUMBER, pcsubges OUT NUMBER)
      RETURN NUMBER IS
      cuantos_hay    NUMBER;
   BEGIN
      SELECT COUNT(sservic)
        INTO cuantos_hay
        FROM sin_tramita_detgestion
       WHERE sgestio = psgestio
         AND nvalser = 0;

      IF cuantos_hay = 0 THEN
         pcsubges := 9;   -- valorado
      ELSE
         pcsubges := 8;   -- pendiente valorar
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_gestiones.f_borra_detalle', 1,
                     'param - psgestio = ' || psgestio,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_estado_valoracion;

--Bug 26630:NSS:10/07/2013
   FUNCTION f_get_servicios(
      psconven IN NUMBER,
      pstarifa IN NUMBER,
      pnlinea IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
/*************************************************************************
    Devuelve el servicio seleccionado o la lista, si es un servicio empaquetado
*************************************************************************/
   BEGIN
      vtraza := 1;
        /*SELECT sservic, tdescri, ccodmon, ctipcal,
             decode(ctipcal,1, iprecio
                           ,3, iprecio * (select valor
                                            from sgt_parm_formulas f
                                           where codigo = (select termino from sin_prof_tarifa where sconven = psconven)
                                             and fecha_efecto = (select max(fecha_efecto)
                                                                   from sgt_parm_formulas f1
                                                                  where f1.codigo=f.codigo
                                                                    and fecha_efecto < f_sysdate ) )
                             , 0) precio_uni,
             NVL(iminimo,0) iminimo
       FROM sin_dettarifas d
      WHERE (starifa, nlinea) IN (select starifa, nlinea from sin_dettarifas WHERE starifa = pstarifa AND nlinea = pnlinea AND iprecio IS NOT NULL
                                   UNION
                                  select starifa1, nlinea1
                                    from sin_dettarifas_pack
                                   where starifa = pstarifa
                                     and nlinea  = pnlinea)*/
      pquery :=
         'SELECT sservic, tdescri, ccodmon, ctipcal,
                        decode(nvl(ctipcal,1),1, iprecio
                              ,3, iprecio * (select valor
                                               from sgt_parm_formulas f
                                              where codigo = (select termino from sin_prof_tarifa where sconven = '
         || psconven
         || ')
                                                and fecha_efecto = (select max(fecha_efecto)
                                                                      from sgt_parm_formulas f1
                                                                     where f1.codigo=f.codigo
                                                                       and fecha_efecto < f_sysdate ) )
                                , 0) precio_uni,
                NVL(iminimo,0) iminimo
          FROM sin_dettarifas d
         WHERE (starifa, nlinea) IN (select starifa, nlinea from sin_dettarifas WHERE starifa = '
         || pstarifa || ' AND nlinea = ' || pnlinea
         || ' AND iprecio IS NOT NULL
                                      UNION
                                     select starifa1, nlinea1
                                       from sin_dettarifas_pack
                                      where starifa = '
         || pstarifa || '
                                        and nlinea  = ' || pnlinea || ')';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_GESTIONES.F_get_servicios', vtraza,
                     'error recuperando datos', SQLERRM);
         RETURN 1000455;
   END f_get_servicios;

   --INI bug 26630
   FUNCTION f_get_cfecha(pctipges IN NUMBER, pcfecha OUT NUMBER)
      RETURN NUMBER IS
/*************************************************************************
   Devuelve si se debe mostrar la fecha o no
*************************************************************************/
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500);
   BEGIN
      BEGIN
         SELECT NVL(cfecha, 0)
           INTO pcfecha
           FROM sin_parges_validacion
          WHERE ctipges = pctipges;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_gestiones.f_get_cfecha', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_get_cfecha;

   FUNCTION f_usuario_permitido(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      psgestio IN NUMBER,
      pctipmov IN NUMBER,
      pcpermit OUT NUMBER)
      RETURN NUMBER IS
/*************************************************************************
   Decide si una gestion se puede dar de alta
*************************************************************************/
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500);
      vcautori       NUMBER;
      vcautori2      NUMBER;
   BEGIN
      BEGIN
         SELECT NVL(cautori, 0)
           INTO vcautori
           FROM sin_parges_movimientos m, sin_tramita_gestion g
          WHERE m.ctipmov = pctipmov
            AND g.sgestio = psgestio
            AND g.ctipges = m.ctipges;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF vcautori IS NOT NULL THEN
         BEGIN
            SELECT NVL(ct.cautori, 0)
              INTO vcautori2
              FROM sin_codtramitador ct, sin_tramita_movimiento tm
             WHERE ct.ctramitad = tm.ctramitad
               AND tm.nsinies = pnsinies
               AND tm.ntramit = pntramit
               AND tm.nmovtra = (SELECT MAX(nmovtra)
                                   FROM sin_tramita_movimiento tm2
                                  WHERE tm2.nsinies = tm.nsinies
                                    AND tm2.ntramit = tm.ntramit);
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      END IF;

      IF vcautori2 >= vcautori THEN
         pcpermit := 1;
      ELSE
         pcpermit := 0;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_gestiones.f_usuario_permitido', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_usuario_permitido;

   FUNCTION f_cancela_pantalla(
      psconven IN NUMBER,
      psprofes IN NUMBER,
      pnsinies IN NUMBER,
      pntramit IN NUMBER)
      RETURN NUMBER IS
/*************************************************************************
   Si se ha dado de alta algun convio temporal, se eliminan esos datos.
*************************************************************************/
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500);
      vsgestio       NUMBER;
      vsprofes       NUMBER;
      vsperson       NUMBER;
   BEGIN
      BEGIN
         SELECT sgestio
           INTO vsgestio
           FROM sin_prof_tarifa
          WHERE sgestio =(pnsinies *(-1))
            AND sconven = psconven;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 0;
      END;

      vpasexec := 2;

      IF vsgestio IS NOT NULL THEN
         DELETE FROM sin_prof_conv_estados
               WHERE sconven = psconven;

         vpasexec := 3;

         DELETE FROM sin_prof_tarifa
               WHERE sgestio =(pnsinies *(-1));

         vpasexec := 4;
         COMMIT;

         BEGIN
            SELECT sgestio, sprofes, sperson
              INTO vsgestio, vsprofes, vsperson
              FROM sin_prof_profesionales
             WHERE sgestio =(pnsinies *(-1))
               AND sprofes = psprofes;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 0;
         END;

         vpasexec := 5;

         IF vsgestio IS NOT NULL THEN
            DELETE FROM sin_prof_zonas
                  WHERE sprofes = vsprofes;

            vpasexec := 6;

            DELETE FROM sin_prof_estados
                  WHERE sprofes = vsprofes;

            vpasexec := 7;

            DELETE FROM sin_prof_rol
                  WHERE sprofes = vsprofes;

            vpasexec := 8;

            DELETE FROM sin_prof_profesionales
                  WHERE sprofes = vsprofes;

            vpasexec := 9;

            DELETE FROM per_personas_rel
                  WHERE sperson = vsperson
                    AND sperson_rel = vsperson
                    AND ctipper_rel = 2;

            vpasexec := 10;

            DELETE FROM per_contactos
                  WHERE sperson = vsperson
                    AND ctipcon = 3
                    AND cusuari = f_user
                    AND TRUNC(fmovimi) = TRUNC(f_sysdate);

            vpasexec := 11;
            COMMIT;

            BEGIN
               SELECT sperson
                 INTO vsperson
                 FROM per_personas
                WHERE sperson = vsperson
                  AND TRUNC(fmovimi) = TRUNC(f_sysdate)
                  AND cusuari = f_user;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 0;
            END;

            vpasexec := 12;

            IF vsperson IS NOT NULL THEN
               DELETE FROM per_contactos
                     WHERE sperson = vsperson;

               DELETE FROM per_documentos
                     WHERE sperson = vsperson;

               DELETE FROM per_documentos_lopd
                     WHERE sperson = vsperson;

               DELETE FROM per_direcciones
                     WHERE sperson = vsperson;

               DELETE FROM per_identificador
                     WHERE sperson = vsperson;

               DELETE FROM per_identifica
                     WHERE sperson = vsperson;

               DELETE FROM per_irpf
                     WHERE sperson = vsperson;

               DELETE FROM per_irpfdescen
                     WHERE sperson = vsperson;

               DELETE FROM per_irpfmayores
                     WHERE sperson = vsperson;

               DELETE FROM per_lopd
                     WHERE sperson = vsperson;

               DELETE FROM per_nacionalidades
                     WHERE sperson = vsperson;

               DELETE FROM per_parpersonas
                     WHERE sperson = vsperson;

               DELETE FROM per_potencial
                     WHERE sperson = vsperson;

               DELETE FROM per_sarlaft
                     WHERE sperson = vsperson;

               DELETE FROM per_vinculos
                     WHERE sperson = vsperson;

               DELETE FROM per_regimenfiscal
                     WHERE sperson = vsperson;

               DELETE FROM per_ccc
                     WHERE sperson = vsperson;

               DELETE FROM per_detper
                     WHERE sperson = vsperson;

               DELETE FROM per_personas
                     WHERE sperson = vsperson
                       AND cusuari = f_user
                       AND TRUNC(fmovimi) = TRUNC(f_sysdate);
            END IF;

            vpasexec := 13;
         END IF;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_gestiones.f_cancela_pantalla', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_cancela_pantalla;

   FUNCTION f_get_acceso_tramitador(pnsinies IN NUMBER, pntramit IN NUMBER, pcconven OUT NUMBER)
      RETURN NUMBER IS
/*************************************************************************
   Devuelve si el tramitador tiene acceso a convenios inactivos y temporales (0-No, 1-Si)
*************************************************************************/
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500);
   BEGIN
      BEGIN
         SELECT NVL(ct.cconven, 0)
           INTO pcconven
           FROM sin_codtramitador ct, sin_tramita_movimiento tm
          WHERE ct.ctramitad = tm.ctramitad
            AND tm.nsinies = pnsinies
            AND tm.ntramit = pntramit
            AND tm.nmovtra = (SELECT MAX(nmovtra)
                                FROM sin_tramita_movimiento tm2
                               WHERE tm2.nsinies = tm.nsinies
                                 AND tm2.ntramit = tm.ntramit);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_gestiones.f_get_acceso_tramitador', vpasexec,
                     vparam, 'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_get_acceso_tramitador;

--FIN bug 26630
   FUNCTION f_reserva_autos(psgestio IN NUMBER)
      RETURN NUMBER IS
/*************************************************************************
   Anula la reserva inicial
*************************************************************************/
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'sgestio=' || psgestio;
      verror         NUMBER;
      vnmovres       NUMBER;
   BEGIN
      FOR i IN (SELECT *
                  FROM sin_tramita_reserva r
                 WHERE (r.nsinies, r.cgarant) = (SELECT nsinies, cgarant
                                                   FROM sin_tramita_gestion
                                                  WHERE sgestio = psgestio)
                   AND r.ntramit = 0
                   AND r.ctipres = 3
                   AND r.ctipgas IN(30, 31)
                   AND r.nmovres = (SELECT MAX(nmovres)
                                      FROM sin_tramita_reserva r1
                                     WHERE r1.nsinies = r.nsinies
                                       AND r1.ntramit = r.ntramit
                                       AND r1.ctipres = r.ctipres
                                       AND r1.ctipgas = r.ctipgas
                                       AND r1.cgarant = r.cgarant)) LOOP
         vnmovres := NULL;

         IF i.ireserva > 0 THEN
            verror := pac_siniestros.f_ins_reserva(i.nsinies, 0, 3, i.cgarant, 0, f_sysdate,
                                                   i.cmonres, 0, i.ipago, 0, i.ipenali,
                                                   i.iingreso, i.irecobro, i.fresini,
                                                   i.fresfin, i.fultpag, NULL, i.iprerec,
                                                   i.ctipgas, vnmovres, NULL, 0);

            IF verror <> 0 THEN
               RETURN verror;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_gestiones.f_reserva_autos', vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_reserva_autos;

   FUNCTION f_agenda_asignacion(
      psgestio IN NUMBER,
      pcevento IN VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER;
      vobjectname    VARCHAR2(500) := 'PAC_GESTIONES.f_agenda_asignacion';
      vparam         VARCHAR2(500) := 'psgestio=' || psgestio || ' pcevento=' || pcevento;
      num_err        NUMBER;
      vidapunte      NUMBER;
      vcempres       NUMBER;
      vcidioma       NUMBER;
      vasunto        VARCHAR2(100);
      vcuerpo        VARCHAR2(4000);
      vsprofes       NUMBER;
      vctipges       NUMBER;
      vcusuari       usuarios.cusuari%TYPE;
      vsconven       sin_tramita_gestion.sconven%TYPE;
      vnsinies       sin_siniestro.nsinies%TYPE;
      vntramit       sin_tramita_movimiento.ntramit%TYPE;
      vctramitad     sin_tramita_movimiento.ctramitad%TYPE;
      vslittit       NUMBER;
      vslitbod       NUMBER;
      vctipage       NUMBER;
      vctpdest       NUMBER;
      vmail_from     per_contactos.tvalcon%TYPE;
      vmail_to       per_contactos.tvalcon%TYPE;
      vposicion      NUMBER;
      vscorreo       NUMBER;
      vfecha         DATE;
      vnombre        VARCHAR2(2000);
      vfsuscrpol     DATE;
      vtriesgo       VARCHAR2(2000);
      vtlugar        VARCHAR2(2000);
      vdirectorio    VARCHAR2(100);
      vconn          UTL_SMTP.connection;
      vfrom          VARCHAR2(2000);
      vctipo         NUMBER;
      vto            VARCHAR2(2000);
      vcont          NUMBER := 0;
      vsecuen        NUMBER;
      pos            NUMBER;
      vsseguro       NUMBER;
      vfile          VARCHAR2(2000);
      vcount_doc     NUMBER;
      vesfinal       BOOLEAN;
      vcontador      NUMBER;
      FUNCTION f_converthtml(cadena VARCHAR2)
         RETURN VARCHAR2 IS
         caracter       VARCHAR2(1);
         resultado      VARCHAR2(3000);
      BEGIN
         FOR x IN 1 .. LENGTH(cadena) LOOP
            caracter := SUBSTR(cadena, x, 1);

            IF ASCII(caracter) >= 160 THEN
               resultado := resultado || CHR(38) || '#' || ASCII(caracter) || ';';
            ELSE
               resultado := resultado || caracter;
            END IF;
         END LOOP;

         RETURN resultado;
      END f_converthtml;
      BEGIN
     vpasexec := 1;
      SELECT slittit, slitbod, ctipage, ctpdest
        INTO vslittit, vslitbod, vctipage, vctpdest
        FROM sin_prof_apuntes
       WHERE cevento = pcevento;

      vpasexec := 2;

      SELECT nsinies, ntramit, sprofes, ctipges, sconven, falta,
            (SELECT f_despoblac2(cpoblac, cprovin) || '-' ||pac_persona.f_tdomici(csiglas, tnomvia, nnumvia, tcomple)
               FROM sin_tramita_localiza l
              WHERE l.nsinies = g.nsinies
                AND l.ntramit = g.ntramit
                AND l.nlocali = (SELECT MAX(nlocali)
                                     FROM sin_tramita_localiza l1
                                    WHERE l1.nsinies = g.nsinies
                                      AND l1.ntramit = g.ntramit))
        INTO vnsinies, vntramit, vsprofes, vctipges, vsconven, vfecha, vtlugar
        FROM sin_tramita_gestion g
       WHERE sgestio = psgestio;

      IF vctipage = 2
         --AND vctpdest = 1 THEN   -- apunte para el profesional  -- 26592
         AND vctpdest IN(1, 3) THEN   -- apunte para el profesional/Taller  --26592
         vpasexec := 3;

         BEGIN
            SELECT f_nombre(p.sperson,3) , (select tvalcon from per_contactos where ctipcon = 3 and  sperson = p.sperson and rownum =1)
              INTO vnombre, vto
              FROM sin_prof_profesionales s, per_personas p
             WHERE s.sperson = p.sperson
               AND s.sprofes = vsprofes;
         EXCEPTION
            WHEN OTHERS THEN
               vcusuari := NULL;   -- si el profesional no tiene usuario no enviamos apunte a la agenda
         END;
      ELSIF vctipage = 2
            AND vctpdest = 2 THEN   -- apunte para el tramitador
         -- 23182:ASN:30/07/2012 ini
         vpasexec := 21;

         SELECT ctramitad
           INTO vctramitad
           FROM sin_tramita_movimiento m
          WHERE nsinies = vnsinies
            AND ntramit = vntramit
            AND nmovtra = (SELECT MAX(nmovtra)
                             FROM sin_tramita_movimiento m1
                            WHERE m1.nsinies = m.nsinies
                              AND m1.ntramit = m.ntramit);

         vpasexec := 22;

         SELECT cusuari
           INTO vcusuari
           FROM sin_codtramitador
          WHERE ctramitad = vctramitad;

      SELECT mail_usu
        INTO vto
        FROM usuarios
       WHERE cusuari = vcusuari;
      ELSE

         RETURN 0;
      END IF;


      IF vsprofes IS NOT NULL THEN


      vcempres := pac_md_common.f_get_cxtempresa;
      vcidioma := pac_md_common.f_get_cxtidioma;
      vpasexec := 23;

      vposicion := instr(pcevento, '-',1,1);
      vscorreo :=  substr(pcevento, vposicion+1, LENGTH(pcevento)-1);
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, 'vscorreo ='||vscorreo,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      SELECT asunto, cuerpo
        INTO vasunto, vcuerpo
        FROM DESMENSAJE_CORREO
       WHERE scorreo = vscorreo
         AND cidioma = vcidioma;

      --Cargamos el remitente y el tipo
      SELECT remitente, ctipo
        INTO vfrom, vctipo
        FROM mensajes_correo
       WHERE scorreo = vscorreo;

      vpasexec := 5;

      SELECT FEMISIO ,
            (SELECT TNATRIE
               FROM RIESGOS
              WHERE SSEGURO = SIN.SSEGURO
                AND NRIESGO = SIN.NRIESGO) , s.sseguro
      INTO vfsuscrpol, vtriesgo, vsseguro
      FROM SIN_SINIESTRO SIN, SEGUROS S
     WHERE SIN.SSEGURO = S.SSEGURO
       AND SIN.NSINIES = vnsinies;

      ------ Sustitiucion Cuerpo del correo por variables
      vpasexec := 31;

      pos := INSTR(vcuerpo, '#LUGAR#', 1);
      vpasexec := 32;

      IF pos > 0 THEN
         vcuerpo := REPLACE(vcuerpo, '#LUGAR#', vtlugar);
      END IF;

      vpasexec := 33;

      pos := INSTR(vcuerpo, '#FECHA#', 1);
      vpasexec := 34;

      IF pos > 0 THEN
         vcuerpo := REPLACE(vcuerpo, '#FECHA#', vfecha);
      END IF;

       vpasexec := 35;

      pos := INSTR(vcuerpo, '#NOMBRE_PROVEEDOR#', 1);
      vpasexec := 36;

      IF pos > 0 THEN
         vcuerpo := REPLACE(vcuerpo, '#NOMBRE_PROVEEDOR#', vnombre);
      END IF;

      vpasexec := 37;

      pos := INSTR(vcuerpo, '#NOMBRE_CASO#', 1);
      vpasexec := 38;

      IF pos > 0 THEN
         vcuerpo := REPLACE(vcuerpo, '#NOMBRE_CASO#', vnsinies || '-' || vntramit);
      END IF;

      vpasexec := 39;

      pos := INSTR(vcuerpo, '#FSUSCRPOL#', 1);
      vpasexec := 40;

      IF pos > 0 THEN
         vcuerpo := REPLACE(vcuerpo, '#FSUSCRPOL#', VFSUSCRPOL);
      END IF;

      vpasexec := 41;

      pos := INSTR(vcuerpo, '#DESC_RIESGO#', 1);
      vpasexec := 42;

      IF pos > 0 THEN
         vcuerpo := REPLACE(vcuerpo, '#DESC_RIESGO#', vtriesgo);
      END IF;

      vpasexec := 43;

      pos := INSTR(vcuerpo, '#LISTADO_ADJUNTOS#', 1);
      vpasexec := 44;

      IF pos > 0 THEN
         vcuerpo := REPLACE(vcuerpo, '#LISTADO_ADJUNTOS#', '');
      END IF;
      -- PREAPRACION PARA ENVIO DE CORREO
      vpasexec := 7;
      vconn := pac_send_mail.begin_mail(sender => vfrom, recipients => vto,
                                        subject => f_converthtml(vasunto),
                                        mime_type => pac_send_mail.multipart_mime_type);
      vpasexec := 8;
      pac_send_mail.attach_text(conn => vconn, DATA => f_converthtml(vcuerpo),
                                mime_type => 'text/html');
      vdirectorio := 'GEDOXTEMPORAL';
      vpasexec := 9;


      -- DOCUMENTOS ADJUNTOS

      vpasexec := 11;

      SELECT COUNT(1)
        INTO vcount_doc
        FROM SIN_TRAMITA_DOCUMENTO
       WHERE nsinies = vnsinies
         AND ntramit = vntramit;
      /*
      FOR i IN (SELECT IDDOC
                  FROM SIN_TRAMITA_DOCUMENTO
                 WHERE nsinies = vnsinies
                   AND ntramit = vntramit) LOOP
        vcontador := NVL(vcontador,0)+1;
        pac_axisgedox.verdoc(i.iddoc, vfile, num_err);
        vesfinal := FALSE;
        IF vcontador = vcount_doc THEN
          vesfinal := TRUE;
        END IF;
        pac_send_mail.attach_base64_readfile(conn => vconn,
                                              DIRECTORY => vdirectorio,
                                              filename => vfile,
                                              mime_type => 'PDF',
                                              inline => FALSE, LAST => vesfinal);
      END LOOP;
      */
      vpasexec := 12;
      pac_send_mail.end_mail(conn => vconn);
      vpasexec := 13;


         --Inserción en la tabla de LOG, aunque haya
         --habido error al enviar el correo
         SELECT seqlogcorreo.NEXTVAL
           INTO vsecuen
           FROM DUAL;

         INSERT INTO log_correo
                     (seqlogcorreo, fevento, cmailrecep, asunto, error, coficina, cterm,
                      cusuenvio, sseguro)
              VALUES (vsecuen, f_sysdate, vto, vasunto, 1, NULL, NULL,
                      f_user, vsseguro);

         vcont := 0;

        COMMIT;
      END IF;
    RETURN 0;


   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN num_err;
   END f_agenda_asignacion;
END pac_gestiones;

/

  GRANT EXECUTE ON "AXIS"."PAC_GESTIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_GESTIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_GESTIONES" TO "PROGRAMADORESCSI";
