--------------------------------------------------------
--  DDL for Package Body PAC_INFORMES_CONF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_INFORMES_CONF" IS
   v_txt          VARCHAR2(32000);

/******************************************************************************
 NOMBRE: PAC_INFORMES_conf


   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        04/02/2013  ETM              1.0024776: (confDE500)-Desarrollo-GAPS - Siniestros - Id 173 - Criterios de filtro listados
   2.0        04/03/2013  JGR              2.0025615: confPG100-(confPG100)-Parametrizacion- Administracion y Finanzas- Parametrizacion Cierres
   3.0        18/04/2013  ETM              3.0024933: confRE100-(confR100)-Informes y reportes-Administracion y finanzas
   4.0        02/05/2013  JMF              4.0025623 (confDE200)-Desarrollo-GAPS - Comercial - Id 56
   5.0        18/09/2012  ETM              5.0025615: confPG100-(confPG100)-Parametrizacion- Administracion y Finanzas- Parametrizacion Cierres
   6.0        04/11/2013  JGR              6.0028785: Error en los c¿lculos de D¿as Amortizados y D¿as por Amortizar
   7.0        19/02/2014  JTT              7.0024936: Listado del libro radicador de sinietros MAP 518
   8.0        26/02/2014  JTT              8.0034909: Listado del libro radicador de sinietros MAP 518
   9.0        16/04/2015  JDS              9.0035599: confES400-FUNCIONALIDAD LIBRO RADICADOR Y LIBROS AUXILIARES
  10.0        10/05/2015  JTT             10.0035599: Listado del libro radicador de sinietros MAP 518
  11.0        28/05/2015  JTT             11.0035599: Listado del libro radicador de sinietros MAP 518 - Reaseguro
  12.0        03/06/2015  IPH             12.0035149  0035149: confADM Reporte de Provisi¿n - modificaci¿m maps 662 y 664
  13.0        08/02/2016  ACL             13.0035599: confES400-FUNCIONALIDAD LIBRO RADICADOR Y LIBROS AUXILIARES - Modificaci¿n camconf 34 y 48
  14.0        22/02/2016  VCG             14.0040577: confES100-confACT REPORTES PROVISIONES IAXIS-Modificaci¿n maps 661 y 663
  15.0        27/06/2016  JTT             15.confINS-33: Listado del libro radicador de siniestros MAP518

******************************************************************************/

   /******************************************************************************************
     Descripci¿: Funci¿ que genera texte cap¿elera per llistat dinamic siniestros abiertos en un periodo
     Par¿metres entrada:    - p_cidioma     -> codigo idioma
                            - p_cempres     -> codigo empresa
                            - p_cagrpro     ->
                            - p_cramo       -> ramo
                            - p_sproduc     -> Producto
                            - p_fdesde      -> fecha ini
                            - p_fhasta      -> fecha fin
                            - p_sucursal    -> Codigos de sucursal
                            - p_ccausin     -> codigo causa siniestro
                            - p_cmotsin     -> codigo motivo siniestro
                            - p_sprofes     -> codigo profesional
                            - p_tipoper     -> codigo tipo per, 1 tomador y 2 asegurado
                            - p_sperson     -> codigo sperson

     return:             texte cap¿elera

   ******************************************************************************************/
--BUG 24776 -- 04/02/2013--ETM --INI
   FUNCTION f_list655_cab(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_cagrpro IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_sproduc IN NUMBER DEFAULT NULL,
      p_fdesde IN VARCHAR2 DEFAULT NULL,
      p_fhasta IN VARCHAR2 DEFAULT NULL,
      p_sucursal IN NUMBER DEFAULT NULL,
      p_ccausin IN NUMBER DEFAULT NULL,
      p_cmotsin IN NUMBER DEFAULT NULL,
      p_sprofes IN NUMBER DEFAULT NULL,
      p_tipoper IN NUMBER DEFAULT 1,
      p_sperson IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_conf.f_list655_cab';
      v_tparam       VARCHAR2(1000)
         := ' idioma=' || p_cidioma || ' e=' || p_cempres || ' cagrpro=' || p_cagrpro
            || ' cramo=' || p_cramo || ' p_sproduc=' || p_sproduc || ' p_fdesde=' || p_fdesde
            || ' p_fhasta=' || p_fhasta || ' sucursal=' || p_sucursal || ' p_ccausin='
            || p_ccausin || ' p_cmotsin=' || p_cmotsin || ' p_sprofes=' || p_sprofes
            || ' p_tipoper=' || p_tipoper || ' p_sperson=' || p_sperson;
      v_ntraza       NUMBER := 0;
      v_idioma       NUMBER;
      v_sep          VARCHAR2(1) := ';';
   BEGIN
      v_ntraza := 1130;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      v_txt := NULL;
      v_txt := v_txt || f_axis_literales(111471, v_idioma) || v_sep || v_sep
               || f_axis_literales(100784, v_idioma) || v_sep || v_sep
               || f_axis_literales(100829, v_idioma) || v_sep || v_sep
               || f_axis_literales(111324, v_idioma) || v_sep
               || f_axis_literales(104595, v_idioma) || v_sep
               || f_axis_literales(102347, v_idioma) || v_sep || v_sep
               || f_axis_literales(800279, v_idioma) || v_sep
               || f_axis_literales(9000526, v_idioma) || v_sep
               || f_axis_literales(110521, v_idioma) || v_sep
               || f_axis_literales(101027, v_idioma) || v_sep   --tom
               || f_axis_literales(109774, v_idioma) || v_sep   --tipo
               || f_axis_literales(105330, v_idioma) || v_sep   --doc
               || f_axis_literales(109651, v_idioma) || v_sep
               || f_axis_literales(100852, v_idioma) || v_sep
               || f_axis_literales(1000112, v_idioma) || v_sep   ---desc sini
               || f_axis_literales(9904824, v_idioma) || v_sep   --aseg
               || f_axis_literales(109774, v_idioma) || ' '
               || f_axis_literales(9904824, v_idioma) || v_sep
               || f_axis_literales(9001630, v_idioma) || v_sep
               || f_axis_literales(1000561, v_idioma) || v_sep
               || f_axis_literales(102075, v_idioma) || v_sep
               || f_axis_literales(9001911, v_idioma);
      v_ntraza := 1130;
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN NULL;
   END f_list655_cab;

   FUNCTION f_list655_det(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_cagrpro IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_sproduc IN NUMBER DEFAULT NULL,
      p_fdesde IN VARCHAR2 DEFAULT NULL,
      p_fhasta IN VARCHAR2 DEFAULT NULL,
      p_sucursal IN NUMBER DEFAULT NULL,
      p_ccausin IN NUMBER DEFAULT NULL,
      p_cmotsin IN NUMBER DEFAULT NULL,
      p_sprofes IN NUMBER DEFAULT NULL,
      p_tipoper IN NUMBER DEFAULT 1,
      p_sperson IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_conf.f_list655_det';
      v_tparam       VARCHAR2(1000)
         := ' idioma=' || p_cidioma || ' e=' || p_cempres || ' cagrpro=' || p_cagrpro
            || ' cramo=' || p_cramo || ' p_sproduc=' || p_sproduc || ' p_fdesde=' || p_fdesde
            || ' p_fhasta=' || p_fhasta || ' sucursal=' || p_sucursal || ' p_ccausin='
            || p_ccausin || ' p_cmotsin=' || p_cmotsin || ' p_sprofes=' || p_sprofes
            || ' p_tipoper=' || p_tipoper || ' p_sperson=' || p_sperson;
      v_ntraza       NUMBER := 0;
      v_idioma       NUMBER;
      v_sperson_aseg NUMBER;
      v_sep          VARCHAR2(1) := ';';
      v_sep2         VARCHAR2(9) := '||' || CHR(39) || ';' || CHR(39) || '||';
      v_finiefe      VARCHAR2(100);
      v_ffinefe      VARCHAR2(100);
      v_sep3         VARCHAR2(9) := '||' || CHR(39) || ';' || CHR(39);
   BEGIN
      v_ntraza := 1040;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      v_txt := NULL;
      v_txt := v_txt || 'SELECT   s.cagrpro' || v_sep2 || ' ag.tagrpro ' || v_sep2
               || ' s.cramo ' || v_sep2 || ' ff_desramo(s.cramo, ' || v_idioma || ')' || v_sep2
               || ' s.sproduc ' || v_sep2
               || 'f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1,  ' || v_idioma
               || ')' || v_sep2 || ' s.npoliza ' || v_sep2 || 's.ncertif ' || v_sep2
               || ' s.cagente ' || v_sep2 || ' ff_desagente(s.cagente) ' || v_sep2
               || ' si.nsinies ' || v_sep2 || ' TO_CHAR(si.falta, ''dd/mm/yyyy'')' || v_sep2
               || ' TO_CHAR(si.fsinies, ''dd/mm/yyyy'')' || v_sep2;
      --  IF p_sperson IS NULL THEN
      v_txt := v_txt || ' pac_isqlfor.f_dades_persona( t.sperson,4, ' || v_idioma || ')||'
               || CHR(39) || ' ' || CHR(39) || '|| pac_isqlfor.f_dades_persona(t.sperson,5, '
               || v_idioma || ')' || v_sep2;
      /*  ELSIF p_sperson IS NOT NULL THEN
           v_txt := v_txt || ' pac_isqlfor.f_dades_persona(' || CHR(39) || p_sperson || CHR(39)
                    || ',4, ' || v_idioma || ')||' || CHR(39) || ' ' || CHR(39)
                    || '|| pac_isqlfor.f_dades_persona(' || CHR(39) || p_sperson || CHR(39)
                    || ',5, ' || v_idioma || ')' || v_sep2;
        END IF;*/
      v_txt :=
         v_txt || 'ff_desvalorfijo(672,' || v_idioma || ', pp.ctipide)' || v_sep2
         || ' pp.nnumide' || v_sep2 || ' dm.tmotsin ' || v_sep2 || ' dc.tcausin ' || v_sep2
         || ' si.tsinies ' || v_sep2   --asegurado
         || ' pac_isqlfor.f_dades_persona( a.sperson,4, ' || v_idioma || ')||' || CHR(39)
         || ' ' || CHR(39) || '|| pac_isqlfor.f_dades_persona(a.sperson,5, ' || v_idioma || ')'
         || v_sep2 || ' pac_isqlfor.f_dades_persona( a.sperson,1, ' || v_idioma || ')'
         || v_sep2 || ' si.cusualt ' || v_sep2 || ' u.cdelega ' || v_sep2
         || ' decode(sp.sperson,NULL,NULL,f_nombre(sp.sperson, 1))' || v_sep2
         || ' DECODE( std.sperson, NULL ,''-'', pac_isqlfor.f_dades_persona(std.sperson, 1, '
         || v_idioma || ')||' || CHR(39) || ' ' || CHR(39)
         || '||  pac_isqlfor.f_dades_persona( std.sperson,4, ' || v_idioma || ')||' || CHR(39)
         || ' ' || CHR(39) || '|| pac_isqlfor.f_dades_persona(std.sperson,5, ' || v_idioma
         || ')) ' || v_sep3 || ' linea '
         || ' FROM seguros s, sin_siniestro si, riesgos r, per_personas pp, per_detper pd, sin_tramita_destinatario std, '
         || '  usuarios u, sin_desmotcau dm, sin_descausa dc, agrupapro ag, sin_prof_profesionales sp, sin_tramita_gestion st, tomadores t ,asegurados a  ';

      IF p_tipoper = 1 THEN
         v_sperson_aseg := NULL;
      ELSE
         v_sperson_aseg := p_sperson;
      END IF;

      v_txt :=
         v_txt || ' WHERE u.cusuari = si.cusualt' || ' AND pp.sperson = nvl(' || CHR(39)
         || p_sperson || CHR(39) || ', t.sperson )' || ' AND  t.sseguro = s.sseguro '
         || ' AND t.sperson= nvl(' || CHR(39) || p_sperson || CHR(39) || ', t.sperson )'
         || ' AND a.sseguro = s.sseguro ' || ' AND a.sperson= nvl(' || CHR(39)
         || v_sperson_aseg || CHR(39) || ', a.sperson )' || ' AND si.nriesgo = r.nriesgo '
         || ' AND r.sseguro = s.sseguro ' || ' AND s.sseguro = si.sseguro '
         || ' and std.NSINIES(+)= si.nsinies ' || ' AND pp.sperson = pd.sperson '
         || ' AND ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres) = pd.cagente '
         || ' AND dm.ccausin = si.ccausin ' || '  AND dm.ccausin = dc.ccausin '
         || ' AND si.ccausin NOT IN(3, 4, 5)' || ' AND(si.ccausin = ' || CHR(39) || p_ccausin
         || CHR(39) || ' OR ' || CHR(39) || p_ccausin || CHR(39) || ' IS NULL) '
         || ' AND dm.cmotsin = si.cmotsin ' || ' AND(dm.cmotsin = ' || CHR(39) || p_cmotsin
         || CHR(39) || ' OR ' || CHR(39) || p_cmotsin || CHR(39) || 'IS NULL) '
         || ' AND dm.cidioma = dc.cidioma ' || ' AND dm.cidioma = ' || v_idioma
         || ' AND(s.cramo = ' || CHR(39) || p_cramo || CHR(39) || '  OR ' || CHR(39) || p_cramo
         || CHR(39) || ' IS NULL)' || ' AND(s.cempres = ' || CHR(39) || p_cempres || CHR(39)
         || ' OR' || CHR(39) || p_cempres || CHR(39) || ' IS NULL) '
         || ' AND s.cagrpro = NVL( ' || CHR(39) || p_cagrpro || CHR(39) || ', s.cagrpro) '
         || ' AND(s.sproduc =' || CHR(39) || p_sproduc || CHR(39) || ' OR ' || CHR(39)
         || p_sproduc || CHR(39) || ' IS NULL)' || 'AND(TRUNC(si.falta) >= TO_DATE(' || CHR(39)
         || p_fdesde || CHR(39) || ', ''ddmmrrrr'') ' || ' OR ' || CHR(39) || p_fdesde
         || CHR(39) || 'IS NULL) ' || ' AND(TRUNC(si.falta) <= TO_DATE(' || CHR(39) || p_fhasta
         || CHR(39) || ', ''ddmmrrrr'')' || ' OR ' || CHR(39) || p_fhasta || CHR(39)
         || ' IS NULL)' || ' AND ag.cagrpro = s.cagrpro ' || ' AND ag.cidioma =' || v_idioma
         || ' AND(pac_redcomercial.f_busca_padre(s.cempres, s.cagente, NULL, r.fefecto) ='
         || CHR(39) || p_sucursal || CHR(39) || ' OR' || CHR(39) || p_sucursal || CHR(39)
         || ' IS NULL)' || ' AND st.nsinies(+) = si.nsinies '
         || ' AND sp.sprofes(+) = st.sprofes ' || ' AND(st.sprofes = ' || CHR(39) || p_sprofes
         || CHR(39) || ' OR ' || CHR(39) || p_sprofes || CHR(39) || 'IS NULL)'
         || ' AND(st.sprofes IS NOT NULL ' || ' AND st.sgestio = (SELECT MAX(sg.sgestio) '
         || '  FROM sin_tramita_gestion sg ' || '  WHERE sg.nsinies(+) = si.nsinies) '
         || ' OR st.sprofes IS NULL)'
         || ' ORDER BY si.falta, si.ccausin, si.cmotsin, si.nsinies';
      v_ntraza := 9999;

      IF v_txt IS NULL THEN
         v_txt := 'select 0 from dual';
      END IF;

      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_list655_det;

    /******************************************************************************************
        Descripci¿: Funci¿ que genera texte cap¿elera per llistat dinamic SINIESTROS SEGUN SITUACION
        Par¿metres entrada:    - p_cidioma     -> codigo idioma
                               - p_cempres     -> codigo empresa
                               - p_cagrpro     ->
                               - p_cramo       -> ramo
                               - p_sproduc     -> Producto
                               - p_cestsin     -> estado siniestro
                               - p_fdesde      -> fecha ini
                               - p_fhasta      -> fecha fin
                               - p_sucursal    -> Codigos de sucursal
                               - p_ccausin     -> codigo causa siniestro
                               - p_cmotsin     -> codigo motivo siniestro
                               - p_sprofes     -> codigo profesional
                               - p_tipoper     -> codigo tipo per, 1 tomador y 2 asegurado
                               - p_sperson     -> codigo sperson

        return:             texte cap¿elera
   ':CIDIOMA|:CEMPRES|:CAGRPRO|:CRAMO|:SPRODUC|:CESTSIN|:FDESDE|:FHASTA|:SUCURSAL|:CCAUSIN|:CMOTSIN|:SPROFES|:TIPO_PERS|:SPERSON|',

      ******************************************************************************************/
   FUNCTION f_list656_cab(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_cagrpro IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_sproduc IN NUMBER DEFAULT NULL,
      p_cestsin IN NUMBER DEFAULT NULL,
      p_fdesde IN VARCHAR2 DEFAULT NULL,
      p_fhasta IN VARCHAR2 DEFAULT NULL,
      p_sucursal IN NUMBER DEFAULT NULL,
      p_ccausin IN NUMBER DEFAULT NULL,
      p_cmotsin IN NUMBER DEFAULT NULL,
      p_sprofes IN NUMBER DEFAULT NULL,
      p_tipoper IN NUMBER DEFAULT 1,
      p_sperson IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_conf.f_list656_cab';
      v_tparam       VARCHAR2(1000)
         := ' idioma=' || p_cidioma || ' e=' || p_cempres || ' cagrpro=' || p_cagrpro
            || ' cramo=' || p_cramo || ' p_sproduc=' || p_sproduc || ' p_cestsin= '
            || p_cestsin || ' p_fdesde=' || p_fdesde || ' p_fhasta=' || p_fhasta
            || ' sucursal=' || p_sucursal || ' p_ccausin=' || p_ccausin || ' p_cmotsin='
            || p_cmotsin || ' p_sprofes=' || p_sprofes || ' p_tipoper=' || p_tipoper
            || ' p_sperson=' || p_sperson;
      v_ntraza       NUMBER := 0;
      v_idioma       NUMBER;
      v_sep          VARCHAR2(1) := ';';
   BEGIN
      v_ntraza := 1130;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      v_txt := NULL;
      v_txt := v_txt || f_axis_literales(111471, v_idioma) || v_sep || v_sep
               || f_axis_literales(100784, v_idioma) || v_sep || v_sep
               || f_axis_literales(100829, v_idioma) || v_sep || v_sep
               || f_axis_literales(111324, v_idioma) || v_sep
               || f_axis_literales(104595, v_idioma) || v_sep
               || f_axis_literales(102347, v_idioma) || v_sep || v_sep
               || f_axis_literales(800279, v_idioma) || v_sep
               || f_axis_literales(9000526, v_idioma) || v_sep
               || f_axis_literales(110521, v_idioma) || v_sep
               || f_axis_literales(101027, v_idioma) || v_sep
               || f_axis_literales(109774, v_idioma) || v_sep
               || f_axis_literales(105330, v_idioma) || v_sep
               || f_axis_literales(109651, v_idioma) || v_sep
               || f_axis_literales(100852, v_idioma) || v_sep
               || f_axis_literales(1000112, v_idioma) || v_sep
               || f_axis_literales(112259, v_idioma) || v_sep
               || f_axis_literales(9904824, v_idioma) || v_sep   --aseg
               || f_axis_literales(109774, v_idioma) || ' '
               || f_axis_literales(9904824, v_idioma) || v_sep
               || f_axis_literales(102075, v_idioma) || v_sep
               || f_axis_literales(9001911, v_idioma);   --benef
      v_ntraza := 1130;
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN NULL;
   END f_list656_cab;

   FUNCTION f_list656_det(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_cagrpro IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_sproduc IN NUMBER DEFAULT NULL,
      p_cestsin IN NUMBER DEFAULT NULL,
      p_fdesde IN VARCHAR2 DEFAULT NULL,
      p_fhasta IN VARCHAR2 DEFAULT NULL,
      p_sucursal IN NUMBER DEFAULT NULL,
      p_ccausin IN NUMBER DEFAULT NULL,
      p_cmotsin IN NUMBER DEFAULT NULL,
      p_sprofes IN NUMBER DEFAULT NULL,
      p_tipoper IN NUMBER DEFAULT 1,
      p_sperson IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_conf.f_list655_det';
      v_tparam       VARCHAR2(1000)
         := ' idioma=' || p_cidioma || ' e=' || p_cempres || ' cagrpro=' || p_cagrpro
            || ' cramo=' || p_cramo || ' p_sproduc=' || p_sproduc || ' p_fdesde=' || p_fdesde
            || ' p_fhasta=' || p_fhasta || ' sucursal=' || p_sucursal || ' p_ccausin='
            || p_ccausin || ' p_cmotsin=' || p_cmotsin || ' p_sprofes=' || p_sprofes
            || ' p_tipoper=' || p_tipoper || ' p_sperson=' || p_sperson;
      v_ntraza       NUMBER := 0;
      v_idioma       NUMBER;
      v_sperson_aseg NUMBER;
      v_sep          VARCHAR2(1) := ';';
      v_sep2         VARCHAR2(9) := '||' || CHR(39) || ';' || CHR(39) || '||';
      v_finiefe      VARCHAR2(100);
      v_ffinefe      VARCHAR2(100);
      v_sep3         VARCHAR2(9) := '||' || CHR(39) || ';' || CHR(39);
   BEGIN
      v_ntraza := 1040;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      IF p_tipoper = 1 THEN
         v_sperson_aseg := NULL;
      ELSE
         v_sperson_aseg := p_sperson;
      END IF;

      v_txt := NULL;
      v_txt :=
         v_txt || ' SELECT s.cagrpro' || v_sep2 || ' ag.tagrpro ' || v_sep2 || ' s.cramo '
         || v_sep2 || ' ff_desramo(s.cramo,' || v_idioma || ') ' || v_sep2 || ' s.sproduc '
         || v_sep2 || ' f_desproducto_t(s.cramo,s.cmodali,s.ctipseg,s.ccolect,1,' || v_idioma
         || ') ' || v_sep2 || ' s.npoliza ' || v_sep2 || ' s.ncertif ' || v_sep2
         || ' s.cagente ' || v_sep2 || ' ff_desagente(s.cagente) ' || v_sep2 || ' ss.nsinies '
         || v_sep2 || ' to_char(ss.falta,''dd/mm/yyyy'') ' || v_sep2
         || ' to_char(ss.fsinies,''dd/mm/yyyy'') ' || v_sep2
         || ' pd.tnombre  || '' '' || pd.tapelli1 || '' '' || pd.tapelli2 ' || v_sep2
         || ' ff_desvalorfijo(672,' || v_idioma || ',pp.ctipide) ' || v_sep2 || ' pp.nnumide '
         || v_sep2 || ' dm.tmotsin ' || v_sep2 || ' dc.tcausin ' || v_sep2 || ' ss.tsinies '
         || v_sep2 || ' ff_desvalorfijo(6,' || v_idioma || ',sm.cestsin) ' || v_sep2
         --aseg
         || ' pac_isqlfor.f_dades_persona(a.sperson, 4,' || v_idioma || ')||' || CHR(39) || ' '
         || CHR(39) || '|| pac_isqlfor.f_dades_persona(a.sperson, 5,' || v_idioma || ')'
         || v_sep2 || '  pac_isqlfor.f_dades_persona(a.sperson, 1, ' || v_idioma || ')'
         || v_sep2 || ' decode(sp.sperson,NULL,NULL,f_nombre(sp.sperson, 1))' || v_sep2
         --benef
         || ' DECODE(std.sperson, NULL, ''-'', pac_isqlfor.f_dades_persona(std.sperson, 1, '
         || v_idioma || ')||' || CHR(39) || ' ' || CHR(39)
         || '||  pac_isqlfor.f_dades_persona(std.sperson, 4,' || v_idioma || ')||' || CHR(39)
         || ' ' || CHR(39) || '||  pac_isqlfor.f_dades_persona(std.sperson, 5, ' || v_idioma
         || '))';
      v_txt :=
         v_txt || v_sep3 || ' linea '
         || ' FROM seguros s,sin_siniestro ss, sin_movsiniestro sm, riesgos r, per_personas pp, per_detper pd, sin_desmotcau dm, '
         || ' sin_descausa dc, agrupapro ag, tomadores t, sin_prof_profesionales sp, sin_tramita_gestion st, asegurados a, sin_tramita_destinatario std '
         || ' where pp.sperson = NVL(' || CHR(39) || p_sperson || CHR(39) || ', t.sperson)'
         || ' AND t.sseguro = s.sseguro ' || ' AND t.sperson = NVL(' || CHR(39) || p_sperson
         || CHR(39) || ', t.sperson) ' || ' AND a.sseguro = s.sseguro '
         || ' AND a.sperson = NVL(' || CHR(39) || v_sperson_aseg || CHR(39) || ', a.sperson)'
         || ' and pd.sperson = pp.sperson '
         || ' and ff_agente_cpervisio(s.cagente,f_sysdate,s.cempres) = pd.cagente '
         || ' and r.nriesgo = ss.nriesgo ' || ' and r.sseguro = ss.sseguro '
         || ' and s.sseguro = ss.sseguro ' || ' and ss.nsinies = sm.nsinies '
         || ' and ss.ccausin not in (3,4,5) ' || ' and (ss.ccausin = ' || CHR(39) || p_ccausin
         || CHR(39) || ' or ' || CHR(39) || p_ccausin || CHR(39) || ' is null) '
         || ' and dm.ccausin = ss.ccausin ' || ' and dm.cmotsin = ss.cmotsin '
         || ' and dm.cidioma = ' || v_idioma || ' and (dm.cmotsin = ' || CHR(39) || p_cmotsin
         || CHR(39) || ' or ' || CHR(39) || p_cmotsin || CHR(39) || ' is null) '
         || ' and dc.ccausin = dm.ccausin ' || ' and dc.cidioma = dm.cidioma '
         || ' AND std.nsinies(+) = ss.nsinies ' || ' and (s.cramo =' || CHR(39) || p_cramo
         || CHR(39) || ' or ' || CHR(39) || p_cramo || CHR(39) || ' is null) '
         || ' and (s.cempres = ' || CHR(39) || p_cempres || CHR(39) || ' or ' || CHR(39)
         || p_cempres || CHR(39) || ' is null) ' || ' and s.cagrpro = nvl(' || CHR(39)
         || p_cagrpro || CHR(39) || ',s.cagrpro) ' || ' and (s.sproduc = ' || CHR(39)
         || p_sproduc || CHR(39) || ' or ' || CHR(39) || p_sproduc || CHR(39) || ' is null) '
         || ' and sm.cestsin = NVL(' || CHR(39) || p_cestsin || CHR(39) || ' ,sm.cestsin) '
         || ' and trunc(sm.festsin) >= to_date(' || CHR(39) || p_fdesde || CHR(39)
         || ',''ddmmrrrr'') ' || ' and trunc(sm.festsin) <= to_date(' || CHR(39) || p_fhasta
         || CHR(39) || ',''ddmmrrrr'') ' || ' and sm.nmovsin = (select max(mm.nmovsin) '
         || ' from sin_movsiniestro mm ' || ' where mm.nsinies = sm.nsinies) '
         || ' and ag.cagrpro = s.cagrpro ' || ' and ag.cidioma =' || v_idioma
         || ' and (pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, r.fefecto) = '
         || CHR(39) || p_sucursal || CHR(39) || ' or ' || CHR(39) || p_sucursal || CHR(39)
         || ' is null) ' || ' AND st.nsinies(+) = ss.nsinies '
         || ' AND sp.sprofes(+) = st.sprofes ' || ' AND (st.sprofes = ' || CHR(39) || p_sprofes
         || CHR(39) || ' or  ' || CHR(39) || p_sprofes || CHR(39) || ' is null) '
         || ' AND (st.sprofes is not null and st.sgestio = (SELECT MAX(sg.sgestio) '
         || ' FROM sin_tramita_gestion sg ' || ' WHERE sg.nsinies(+) = ss.nsinies) '
         || ' or st.sprofes is null )'
         || ' order by ss.falta, ss.ccausin, ss.cmotsin,ss.nsinies ';
      v_ntraza := 9999;

      IF v_txt IS NULL THEN
         v_txt := 'select 0 from dual';
      END IF;

      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_list656_det;

   /******************************************************************************************
       Descripci¿: Funci¿ que genera texte cap¿elera per llistat de pagos de sinestros por estado
       Par¿metres entrada:    - p_cidioma     -> codigo idioma
                              - p_cempres     -> codigo empresa
                              - p_cagrpro     ->
                              - p_cramo       -> ramo
                              - p_sproduc     -> Producto
                              - p_cagente     -> codigo de agente
                              - p_fdesde      -> fecha ini
                              - p_fhasta      -> fecha fin
                              - p_sucursal    -> Codigos de sucursal
                              - p_ccausin     -> codigo causa siniestro
                              - p_cmotsin     -> codigo motivo siniestro
                              - p_sprofes     -> codigo profesional
                              - p_tipoper     -> codigo tipoper,1 tomador , 2 asegurado y 3 benef
                              - p_sperson     -> codigo sperson

       return:             texte cap¿elera
   ':CIDIOMA|:CEMPRES|:CAGRPRO|:CRAMO|:SPRODUC|:CAGENTE|:FDESDE|:FHASTA|:SUCURSAL|:CCAUSIN|:CMOTSIN|:SPROFES|:TIPO_PERS|:SPERSON',

     ******************************************************************************************/
   FUNCTION f_list657_cab(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_cagrpro IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_sproduc IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL,
      p_fdesde IN VARCHAR2 DEFAULT NULL,
      p_fhasta IN VARCHAR2 DEFAULT NULL,
      p_sucursal IN NUMBER DEFAULT NULL,
      p_ccausin IN NUMBER DEFAULT NULL,
      p_cmotsin IN NUMBER DEFAULT NULL,
      p_sprofes IN NUMBER DEFAULT NULL,
      p_tipoper IN NUMBER DEFAULT 1,
      p_sperson IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_conf.f_list657_cab';
      v_tparam       VARCHAR2(1000)
         := ' idioma=' || p_cidioma || ' e=' || p_cempres || ' cagrpro=' || p_cagrpro
            || ' cramo=' || p_cramo || ' p_sproduc=' || p_sproduc || ' p_cagente= '
            || p_cagente || ' p_fdesde=' || p_fdesde || ' p_fhasta=' || p_fhasta
            || ' sucursal=' || p_sucursal || ' p_ccausin=' || p_ccausin || ' p_cmotsin='
            || p_cmotsin || ' p_sprofes=' || p_sprofes || ' p_tipoper=' || p_tipoper
            || ' p_sperson=' || p_sperson;
      v_ntraza       NUMBER := 0;
      v_idioma       NUMBER;
      v_sep          VARCHAR2(1) := ';';
   BEGIN
      v_ntraza := 1130;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      v_txt := NULL;
      v_txt := v_txt || f_axis_literales(111471, v_idioma) || v_sep || v_sep
               || f_axis_literales(100784, v_idioma) || v_sep || v_sep
               || f_axis_literales(100829, v_idioma) || v_sep || v_sep
               || f_axis_literales(111324, v_idioma) || v_sep
               || f_axis_literales(104595, v_idioma) || v_sep
               || f_axis_literales(102347, v_idioma) || v_sep || v_sep
               || f_axis_literales(9001911, v_idioma) || v_sep
               || f_axis_literales(109774, v_idioma) || v_sep
               || f_axis_literales(105330, v_idioma) || v_sep
               || f_axis_literales(9000759, v_idioma) || v_sep
               || f_axis_literales(101298, v_idioma) || v_sep
               || f_axis_literales(9001946, v_idioma) || v_sep
               || f_axis_literales(100563, v_idioma) || v_sep
               || f_axis_literales(9900777, v_idioma) || v_sep
               || f_axis_literales(9001030, v_idioma) || v_sep
               || f_axis_literales(1000525, v_idioma) || v_sep
               || f_axis_literales(110278, v_idioma) || v_sep
               || f_axis_literales(9001909, v_idioma) || v_sep
               ||   --numero pago
                 f_axis_literales(109360, v_idioma) || v_sep
               ||   --toma
                 f_axis_literales(109774, v_idioma) || ' '
               ||   --doc tom
                 f_axis_literales(109360, v_idioma) || v_sep
               ||   --doc tom
                 f_axis_literales(9904824, v_idioma) || v_sep
               ||   --aseg
                 f_axis_literales(109774, v_idioma) || ' '
               ||   --doc aseg
                 f_axis_literales(9904824, v_idioma) || v_sep
               ||   --doc aseg
                 f_axis_literales(102075, v_idioma) || v_sep
               || f_axis_literales(109651, v_idioma) || v_sep
               || f_axis_literales(100852, v_idioma);
      v_ntraza := 1130;
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN NULL;
   END f_list657_cab;

   /******************************************************************************************
        Descripci¿: Funci¿ que genera el contigut per  llistat de pagos liquidados en un periodo (map 657 dinamic)
        Par¿metres entrada:  - p_cidioma     -> codigo idioma
                            - p_cempres     -> codigo empresa
                            - p_cagrpro     ->
                            - p_cramo       -> ramo
                            - p_sproduc     -> Producto
                            - p_cagente     -> codigo en funcion del tipo (zona, oficina, agente)
                            - p_fdesde      -> fecha ini
                            - p_fhasta      -> fecha fin
                            - p_sucursal    -> Codigos de sucursal
                            - p_ccausin     -> codigo causa siniestro
                            - p_cmotsin     -> codigo motivo siniestro
                            - p_sprofes     -> codigo profesional
                            - p_tipoper     -> codigo tipo per, 1 tomador , 2 asegurado y 3 benef
                            - p_sperson     -> codigo sperson
   :CIDIOMA|:CEMPRES|:CAGRPRO|:CRAMO|:SPRODUC|:CAGENTE|:FDESDE|:FHASTA|:SUCURSAL|:CCAUSIN|:CMOTSIN|:SPROFES|:TIPO_PERS|:SPERSON',
        return:              texte select detall
      ******************************************************************************************/
   FUNCTION f_list657_det(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_cagrpro IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,   --4
      p_sproduc IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL,   --6
      p_fdesde IN VARCHAR2 DEFAULT NULL,
      p_fhasta IN VARCHAR2 DEFAULT NULL,
      p_sucursal IN NUMBER DEFAULT NULL,
      p_ccausin IN NUMBER DEFAULT NULL,   --10
      p_cmotsin IN NUMBER DEFAULT NULL,
      p_sprofes IN NUMBER DEFAULT NULL,
      p_tipoper IN NUMBER DEFAULT 1,
      p_sperson IN NUMBER DEFAULT NULL,
      p_ctipdes IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      -- ':CIDIOMA|:CEMPRES|:CAGRPRO|:CRAMO|:SPRODUC|:CAGENTE|:FDESDE|:FHASTA|:SUCURSAL|:CCAUSIN|:CMOTSIN|:SPROFES|:TIPO_PERS|:SPERSON',
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_conf.f_list657_det';
      v_tparam       VARCHAR2(1000)
         := ' idioma=' || p_cidioma || ' e=' || p_cempres || ' cagrpro=' || p_cagrpro
            || ' cramo=' || p_cramo || ' p_sproduc=' || p_sproduc || ' p_cagente='
            || p_cagente || ' p_fdesde=' || p_fdesde || ' p_fhasta=' || p_fhasta
            || ' sucursal=' || p_sucursal || ' p_ccausin=' || p_ccausin || ' p_cmotsin='
            || p_cmotsin || ' p_sprofes=' || p_sprofes;
      v_ntraza       NUMBER := 0;
      v_finiefe      VARCHAR2(100);
      v_ffinefe      VARCHAR2(100);
      v_sep          VARCHAR2(1) := ';';
      v_sep3         VARCHAR2(9) := '||' || CHR(39) || ';' || CHR(39);
      v_sep2         VARCHAR2(9) := '||' || CHR(39) || ';' || CHR(39) || '||';
      v_idioma       NUMBER;
      v_sperson_benef NUMBER;
      v_sperson_aseg NUMBER;
      v_sperson_tom  NUMBER;
   BEGIN
      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      /* v_fdesde := LPAD(p_fdesde, 8, '0');
       v_fdesde := 'to_date(' || CHR(39) || v_fdesde || CHR(39) || ',''ddmmyyyy'')';
       v_fhasta := LPAD(p_fhasta, 8, '0');
       v_fhasta := 'to_date(' || CHR(39) || v_fhasta || CHR(39) || ',''ddmmyyyy'')';*/
      v_ntraza := 1000;

      IF p_tipoper = 1 THEN
         v_sperson_tom := p_sperson;
         v_sperson_aseg := NULL;
         v_sperson_benef := NULL;
      ELSIF p_tipoper = 2 THEN
         v_sperson_aseg := p_sperson;
         v_sperson_benef := NULL;
         v_sperson_tom := NULL;
      ELSE
         v_sperson_tom := NULL;
         v_sperson_aseg := NULL;
         v_sperson_benef := p_sperson;
      END IF;

--' || v_idioma || '
      v_txt := NULL;
      v_txt :=
         ' SELECT   s.cagrpro ' || v_sep2 || ' ag.tagrpro ' || v_sep2 || ' s.cramo ' || v_sep2
         || ' ff_desramo(s.cramo, ' || v_idioma || ') ' || v_sep2 || ' s.sproduc ' || v_sep2
         || ' f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1,' || v_idioma || ')'
         || v_sep2 || ' s.npoliza ' || v_sep2 || ' s.ncertif ' || v_sep2 || ' s.cagente '
         || v_sep2 || ' ff_desagente(s.cagente) ' || v_sep2
         || ' DECODE(f_es_vinculada(s.sseguro), 0, ''no'', 1, ''si'') ' || v_sep2
         || ' ff_desvalorfijo(672,' || v_idioma || ', pp.ctipide) ' || v_sep2 || ' pp.nnumide '
         || v_sep2 || ' pd.tnombre || '' '' || pd.tapelli1  || '' '' || pd.tapelli2 ' || v_sep2
         || ' si.nsinies ' || v_sep2   --benef /destina
         || ' TO_CHAR(stm.fefepag, ''dd/mm/yyyy'') ' || v_sep2
         || ' (stp.isinret - NVL(stp.iretenc, 0)) ' || v_sep2 || ' stp.isinret ' || v_sep2
         || ' stp.iretenc ' || v_sep2 || ' stp.iresred ' || v_sep2
         || ' TO_CHAR(si.fsinies, ''dd/mm/yyyy'') ' || v_sep2 || ' stp.sidepag ' || v_sep2
         || ' pac_isqlfor.f_dades_persona(t.sperson, 4,' || v_idioma || ')||' || CHR(39)
         || ' '   --tomador
               || CHR(39) || '|| pac_isqlfor.f_dades_persona(t.sperson, 5, ' || v_idioma || ')'
         || v_sep2 || ' pac_isqlfor.f_dades_persona(t.sperson, 1, ' || v_idioma || ') '
         || v_sep2 || ' pac_isqlfor.f_dades_persona(a.sperson, 4,' || v_idioma || ')||'
         || CHR(39) || ' '   --aseg
                          || CHR(39) || '|| pac_isqlfor.f_dades_persona(a.sperson, 5, '
         || v_idioma || ') ' || v_sep2 || ' pac_isqlfor.f_dades_persona(a.sperson, 1, '
         || v_idioma || ') ' || v_sep2
         || ' decode(sp.sperson,NULL,NULL,f_nombre(sp.sperson, 1)) ' || v_sep2
         || ' dm.tmotsin ' || v_sep2 || ' dc.tcausin' || v_sep3 || ' linea '
         || ' FROM seguros s, sin_siniestro si, sin_tramita_pago stp, sin_tramita_movpago stm, '
         || ' per_personas pp, per_detper pd,  tomadores t, asegurados a, agrupapro ag,  sin_prof_profesionales sp, '
         || ' sin_tramita_gestion st, sin_desmotcau dm, sin_descausa dc, '
         || ' (SELECT rc.cagente, rc.cempres ' || ' FROM (SELECT     rc.cagente, rc.cempres '
         || ' FROM redcomercial rc ' || ' WHERE rc.fmovfin IS NULL '
         || ' START WITH rc.cagente = NVL(' || CHR(39) || p_cagente || CHR(39)
         || ',ff_agente_cpolvisio(pac_user.ff_get_cagente(f_user)))'
         || ' CONNECT BY PRIOR rc.cagente = rc.cpadre '
         || ' AND PRIOR rc.fmovfin IS NULL) rc, ' || ' agentes_agente_pol a '
         || ' WHERE rc.cagente = a.cagente) v ' || ' WHERE s.sseguro = si.sseguro '
         || ' AND s.cramo = NVL(' || CHR(39) || p_cramo || CHR(39) || ', s.cramo) '
         || ' AND s.cempres = ' || CHR(39) || p_cempres || CHR(39) || ' AND s.sproduc = NVL('
         || CHR(39) || p_sproduc || CHR(39) || ', s.sproduc) ' || ' AND s.cagrpro = NVL('
         || CHR(39) || p_cagrpro || CHR(39) || ', s.cagrpro) ' || ' AND v.cagente = s.cagente '
         || ' AND v.cempres = s.cempres ' || ' AND stp.nsinies = si.nsinies '
         || ' AND stp.sidepag = stm.sidepag ' || ' AND pp.sperson = stp.sperson '
         || ' AND ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres) = pd.cagente '
         || ' AND pp.sperson = pd.sperson ' || ' AND stp.sperson = NVL(' || CHR(39)
         || v_sperson_benef || CHR(39) || ', stp.sperson) ' || ' AND t.sseguro = s.sseguro '
         || ' AND t.sperson = NVL(' || CHR(39) || v_sperson_tom || CHR(39) || ', t.sperson) '
         || ' AND a.sseguro = s.sseguro ' || ' AND a.sperson = NVL(' || CHR(39)
         || v_sperson_aseg || CHR(39) || ', a.sperson) ' || ' AND ag.cagrpro = s.cagrpro '
         || ' AND ag.cidioma = ' || CHR(39) || v_idioma || CHR(39)
         || ' AND stm.nmovpag = (SELECT MAX(nmovpag) ' || ' FROM sin_tramita_movpago '
         || ' WHERE sidepag = stm.sidepag) ' || ' AND stm.fefepag BETWEEN TO_DATE(' || CHR(39)
         || p_fdesde || CHR(39) || ', ''ddmmrrrr'') AND TO_DATE(' || CHR(39) || p_fhasta
         || CHR(39) || ', ''ddmmrrrr'')' || ' AND stm.cestpag = 2 '
         || ' AND dm.ccausin = si.ccausin ' || ' AND dm.ccausin = dc.ccausin '
         || ' AND si.ccausin NOT IN(3, 4, 5) ' || ' AND(si.ccausin = ' || CHR(39) || p_ccausin
         || CHR(39) || ' OR ' || CHR(39) || p_ccausin || CHR(39) || ' IS NULL) '
         || ' AND dm.cmotsin = si.cmotsin ' || ' AND(dm.cmotsin = ' || CHR(39) || p_cmotsin
         || CHR(39) || ' OR ' || CHR(39) || p_cmotsin || CHR(39) || ' IS NULL) '
         || ' AND dm.cidioma = dc.cidioma ' || ' AND dm.cidioma =' || CHR(39) || v_idioma
         || CHR(39) || ' AND st.nsinies(+) = si.nsinies ' || ' AND sp.sprofes(+) = st.sprofes '
         || ' AND(st.sprofes = ' || CHR(39) || p_sprofes || CHR(39) || ' OR ' || CHR(39)
         || p_sprofes || CHR(39) || ' IS NULL) ' || ' AND(stp.ctipdes = ' || CHR(39)
         || p_ctipdes || CHR(39) || ' OR ' || CHR(39) || p_ctipdes || CHR(39) || ' IS NULL) '
         || ' AND(st.sprofes IS NOT NULL ' || ' AND st.sgestio = (SELECT MAX(sg.sgestio) '
         || ' FROM sin_tramita_gestion sg ' || ' WHERE sg.nsinies(+) = si.nsinies) '
         || ' OR st.sprofes IS NULL) '
         || ' AND(pac_redcomercial.f_busca_padre(s.cempres, s.cagente, NULL, NULL) = '
         || CHR(39) || p_sucursal || CHR(39) || ' OR ' || CHR(39) || p_sucursal || CHR(39)
         || ' IS NULL) '
         || ' ORDER BY s.cramo, s.cmodali, s.ctipseg, s.ccolect, si.nsinies, stm.fefepag ';
             /*SELECT   s.cagrpro || ';' || ag.tagrpro || ';' || s.cramo || ';'
               || ff_desramo(s.cramo, :p_cidioma) || ';' || s.sproduc || ';'
               || f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, :p_cidioma)
               || ';' || s.npoliza || ';' || s.ncertif || ';' || s.cagente || ';'
               || ff_desagente(s.cagente) || ';'
               || DECODE(f_es_vinculada(s.sseguro), 0, 'no', 1, 'si') || ';'
               || ff_desvalorfijo(672, :p_cidioma, pp.ctipide) || ';' || pp.nnumide || ';'
               || pd.tnombre || ' ' || pd.tapelli1 || ' ' || pd.tapelli2 || ';' || si.nsinies
               || ';' || TO_CHAR(stm.fefepag, 'dd/mm/yyyy') || ';'
               ||(stp.isinret - NVL(stp.iretenc, 0)) || ';' || stp.isinret || ';'
               || stp.iretenc || ';' || stp.iresred || ';'
               || TO_CHAR(si.fsinies, 'dd/mm/yyyy') || ';' || stp.sidepag || ';'
               || pac_isqlfor.f_dades_persona(t.sperson, 4, :v_idioma) || ' '
               ||   --tomador
                 pac_isqlfor.f_dades_persona(t.sperson, 5, :v_idioma) || ';'
               || pac_isqlfor.f_dades_persona(t.sperson, 1, :v_idioma) || ';'
               || pac_isqlfor.f_dades_persona(a.sperson, 4, :v_idioma) || ' '
               ||   --aseg
                 pac_isqlfor.f_dades_persona(a.sperson, 5, :v_idioma) || ';'
               || pac_isqlfor.f_dades_persona(a.sperson, 1, :v_idioma) || ';'
               || f_nombre(sp.sperson, 1) || ';' || dm.tmotsin || ';' || dc.tcausin || ';' linea
          FROM seguros s,
               sin_siniestro si,
               sin_tramita_pago stp,
               sin_tramita_movpago stm,
               per_personas pp,
               per_detper pd,
               tomadores t,
               asegurados a,
               agrupapro ag,
               sin_prof_profesionales sp,
               sin_tramita_gestion st,
               sin_desmotcau dm,
               sin_descausa dc,
               (SELECT rc.cagente, rc.cempres
                  FROM (SELECT     rc.cagente, rc.cempres
                              FROM redcomercial rc
                             WHERE rc.fmovfin IS NULL
                        START WITH rc.cagente =
                                      NVL(:p_cagente,
                                          ff_agente_cpolvisio(pac_user.ff_get_cagente(f_user)))
                        CONNECT BY PRIOR rc.cagente = rc.cpadre
                               AND PRIOR rc.fmovfin IS NULL) rc,
                       agentes_agente_pol a
                 WHERE rc.cagente = a.cagente) v
         WHERE s.sseguro = si.sseguro
           AND s.cramo = NVL(:p_cramo, s.cramo)
           AND s.cempres = :p_cempres
           AND s.sproduc = NVL(:p_sproduc, s.sproduc)
           AND s.cagrpro = NVL(:p_cagrpro, s.cagrpro)
           AND v.cagente = s.cagente
           AND v.cempres = s.cempres
           AND stp.nsinies = si.nsinies
           AND stp.sidepag = stm.sidepag
           AND pp.sperson = stp.sperson
           AND ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres) = pd.cagente
           AND pp.sperson = pd.sperson
           AND stp.sperson = NVL(:v_sperson_benef, stp.sperson)
           AND t.sseguro = s.sseguro
           AND t.sperson = NVL(:p_sperson, t.sperson)
           AND a.sseguro = s.sseguro
           AND a.sperson = NVL(:v_sperson_aseg, a.sperson)
           AND ag.cagrpro = s.cagrpro
           AND ag.cidioma = :p_cidioma
           AND stm.nmovpag = (SELECT MAX(nmovpag)
                                FROM sin_tramita_movpago
                               WHERE sidepag = stm.sidepag)
           AND stm.fefepag BETWEEN TO_DATE(:p_fdesde, 'ddmmyyyy') AND TO_DATE(:p_fhasta, 'ddmmyyyy')
           AND stm.cestpag = 2
           AND dm.ccausin = si.ccausin
           AND dm.ccausin = dc.ccausin
           AND si.ccausin NOT IN(3, 4, 5)
           AND(si.ccausin = :p_ccausin
               OR :p_ccausin IS NULL)
           AND dm.cmotsin = si.cmotsin
           AND(dm.cmotsin = :p_cmotsin
               OR :p_cmotsin IS NULL)
           AND dm.cidioma = dc.cidioma
           AND dm.cidioma = :p_cidioma
           AND st.nsinies(+) = si.nsinies
           AND sp.sprofes(+) = st.sprofes
           AND(st.sprofes = :p_sprofes
               OR :p_sprofes IS NULL)
           AND(st.sprofes IS NOT NULL
               AND st.sgestio = (SELECT MAX(sg.sgestio)
                                   FROM sin_tramita_gestion sg
                                  WHERE sg.nsinies(+) = si.nsinies)
               OR st.sprofes IS NULL)
           AND(pac_redcomercial.f_busca_padre(s.cempres, s.cagente, NULL, NULL) = :p_sucursal
               OR :p_sucursal IS NULL)
      ORDER BY s.cramo, s.cmodali, s.ctipseg, s.ccolect, si.nsinies, stm.fefepag*/
      v_ntraza := 9999;

      IF v_txt IS NULL THEN
         v_txt := 'select 0 from dual';
      END IF;

      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_list657_det;

   /******************************************************************************************
       Descripci¿: Funci¿ que genera la cebeceta per llistat pagos de siniestros por estado(map 658 dinamic)
       Par¿metres entrada:  - p_cidioma     -> codigo idioma
                           - p_cempres     -> codigo empresa
                           - p_cagrpro     -> codigo agrup produ
                           - p_cramo       -> codigo ramo
                           - p_sproduc     ->  codigo Producto
                           - p_cestpag     --> codigo estado pago
                           - p_fdesde      -> fecha ini
                           - p_fhasta      -> fecha fin
                           - p_cagente     -> codigo en funcion del tipo (zona, oficina, agente)
                           - p_sucursal    -> Codigos de sucursal
                           - p_ccausin     -> codigo causa siniestro
                           - p_cmotsin     -> codigo motivo siniestro
                           - p_sprofes     -> codigo profesional
                           - p_cestsin     -> codigo de estado
                           - p_tipoper     -> codigo tipo per, 1 tomador y 2 asegurado, y 3 benef
                           - p_sperson     -> codigo sperson
        ':CIDIOMA|:CEMPRES|:CAGRPRO|:CRAMO|:SPRODUC|:CESTPAG|:FDESDE|:FHASTA|:CAGENTE|:SUCURSAL|:CCAUSIN|:CMOTSIN|:SPROFES|:CESTSIN|:TIPO_PERS|:SPERSON|',

                 return:              text select cabecera
     ******************************************************************************************/
   FUNCTION f_list658_cab(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_cagrpro IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_sproduc IN NUMBER DEFAULT NULL,
      p_cestpag IN NUMBER DEFAULT NULL,
      p_fdesde IN VARCHAR2 DEFAULT NULL,
      p_fhasta IN VARCHAR2 DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL,
      p_sucursal IN NUMBER DEFAULT NULL,
      p_ccausin IN NUMBER DEFAULT NULL,
      p_cmotsin IN NUMBER DEFAULT NULL,
      p_sprofes IN NUMBER DEFAULT NULL,
      p_cestsin IN NUMBER DEFAULT NULL,
      p_tipoper IN NUMBER DEFAULT 1,
      p_sperson IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_conf.f_list658_cab';
      v_tparam       VARCHAR2(1000)
         := ' idioma=' || p_cidioma || ' e=' || p_cempres || ' cagrpro=' || p_cagrpro
            || ' cramo=' || p_cramo || ' p_sproduc=' || p_sproduc || ' p_cestpag='
            || p_cestpag || ' p_fdesde=' || p_fdesde || ' p_fhasta=' || p_fhasta
            || ' p_cagente=' || p_cagente || ' sucursal=' || p_sucursal || ' p_ccausin='
            || p_ccausin || ' p_cmotsin=' || p_cmotsin || ' p_sprofes=' || p_sprofes
            || ' p_cestsin=' || p_cestsin || ' p_tipoper=' || p_tipoper || ' p_sperson='
            || p_sperson;
      v_ntraza       NUMBER := 0;
      v_idioma       NUMBER;
      v_sep          VARCHAR2(1) := ';';
   BEGIN
      v_ntraza := 1130;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      v_txt := NULL;
      v_txt := v_txt || f_axis_literales(111471, v_idioma) || v_sep || v_sep
               || f_axis_literales(100784, v_idioma) || v_sep || v_sep
               || f_axis_literales(100829, v_idioma) || v_sep || v_sep
               || f_axis_literales(111324, v_idioma) || v_sep
               || f_axis_literales(104595, v_idioma) || v_sep
               || f_axis_literales(800279, v_idioma) || v_sep
               || f_axis_literales(110521, v_idioma) || v_sep
               || f_axis_literales(100852, v_idioma) || v_sep
               || f_axis_literales(109651, v_idioma) || v_sep
               || f_axis_literales(1000112, v_idioma) || v_sep
               ||   --
                 f_axis_literales(112259, v_idioma) || v_sep
               ||   --estado sini
                 f_axis_literales(101573, v_idioma) || v_sep
               || f_axis_literales(1000575, v_idioma) || v_sep
               || f_axis_literales(100563, v_idioma) || v_sep
               || f_axis_literales(101714, v_idioma) || v_sep
               || f_axis_literales(9001326, v_idioma) || v_sep
               ||   --estado pago
                 f_axis_literales(109360, v_idioma) || v_sep
               ||   --toma
                 f_axis_literales(109774, v_idioma) || ' '
               ||   --doc tom
                 f_axis_literales(109360, v_idioma) || v_sep
               ||   --doc tom
                 f_axis_literales(9904824, v_idioma) || v_sep
               ||   --aseg
                 f_axis_literales(109774, v_idioma) || ' '
               ||   --doc aseg
                 f_axis_literales(9904824, v_idioma) || v_sep
               ||   --doc aseg
                 f_axis_literales(9001911, v_idioma) || v_sep
               ||   --benef
                 f_axis_literales(102347, v_idioma) || v_sep
               || f_axis_literales(102075, v_idioma);
      v_ntraza := 1130;
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_list658_cab;

   /******************************************************************************************
         Descripci¿: Funci¿ que genera el contigut per llistat pagos de siniestros por estado(map 658 dinamic)(map 658 dinamic)
         Par¿metres entrada:  - p_cidioma     -> codigo idioma
                             - p_cempres     -> codigo empresa
                             - p_cagrpro     -> codigo agrup produ
                             - p_cramo       -> codigo ramo
                             - p_sproduc     ->  codigo Producto
                             - p_cestpag     --> codigo estado pago
                             - p_fdesde      -> fecha ini
                             - p_fhasta      -> fecha fin
                             - p_cagente     -> codigo en funcion del tipo (zona, oficina, agente)
                             - p_sucursal    -> Codigos de sucursal
                             - p_ccausin     -> codigo causa siniestro
                             - p_cmotsin     -> codigo motivo siniestro
                             - p_sprofes     -> codigo profesional
                             - p_cestsin     -> codigo de estado
                             - p_tipoper     -> codigo tipo per, 1 tomador y 2 asegurado, y 3 benef
                             - p_sperson     -> codigo sperson
          ':CIDIOMA|:CEMPRES|:CAGRPRO|:CRAMO|:SPRODUC|:CESTPAG|:FDESDE|:FHASTA|:CAGENTE|:SUCURSAL|:CCAUSIN|:CMOTSIN|:SPROFES|:CESTSIN|:TIPO_PERS|:SPERSON|',

                   return:              text select detall
       ******************************************************************************************/
   FUNCTION f_list658_det(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_cagrpro IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_sproduc IN NUMBER DEFAULT NULL,
      p_cestpag IN NUMBER DEFAULT NULL,
      p_fdesde IN VARCHAR2 DEFAULT NULL,
      p_fhasta IN VARCHAR2 DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL,
      p_sucursal IN NUMBER DEFAULT NULL,
      p_ccausin IN NUMBER DEFAULT NULL,
      p_cmotsin IN NUMBER DEFAULT NULL,
      p_sprofes IN NUMBER DEFAULT NULL,
      p_cestsin IN NUMBER DEFAULT NULL,
      p_tipoper IN NUMBER DEFAULT 1,
      p_sperson IN NUMBER DEFAULT NULL,
      p_ctipdes IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_conf.f_list658_det';
      v_tparam       VARCHAR2(1000)
         := ' idioma=' || p_cidioma || ' e=' || p_cempres || ' cagrpro=' || p_cagrpro
            || ' cramo=' || p_cramo || ' p_sproduc=' || p_sproduc || ' p_cestpag='
            || p_cestpag || ' p_fdesde=' || p_fdesde || ' p_fhasta=' || p_fhasta
            || ' p_cagente=' || p_cagente || ' sucursal=' || p_sucursal || ' p_ccausin='
            || p_ccausin || ' p_cmotsin=' || p_cmotsin || ' p_sprofes=' || p_sprofes
            || ' p_cestsin=' || p_cestsin || ' p_tipoper=' || p_tipoper || ' p_sperson='
            || p_sperson;
      v_ntraza       NUMBER := 0;
      v_finiefe      VARCHAR2(100);
      v_ffinefe      VARCHAR2(100);
      v_sep          VARCHAR2(1) := ';';
      v_idioma       NUMBER;
      v_sep3         VARCHAR2(9) := '||' || CHR(39) || ';' || CHR(39);
      v_sep2         VARCHAR2(9) := '||' || CHR(39) || ';' || CHR(39) || '||';
      v_sperson_tom  NUMBER;
      v_sperson_aseg NUMBER;
      v_sperson_benef NUMBER;
   BEGIN
      v_ntraza := 1000;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      IF p_tipoper = 1 THEN
         v_sperson_tom := p_sperson;
         v_sperson_aseg := NULL;
         v_sperson_benef := NULL;
      ELSIF p_tipoper = 2 THEN
         v_sperson_aseg := p_sperson;
         v_sperson_benef := NULL;
         v_sperson_tom := NULL;
      ELSE
         v_sperson_tom := NULL;
         v_sperson_aseg := NULL;
         v_sperson_benef := p_sperson;
      END IF;

      v_txt := NULL;
      --' || v_idioma || '
      v_txt :=
         ' SELECT ss.cagrpro ' || v_sep2 || ' ag.tagrpro ' || v_sep2 || ' ss.cramo ' || v_sep2
         || ' ff_desramo(ss.cramo, ' || v_idioma || ')' || v_sep2 || ' ss.sproduc ' || v_sep2
         || 'f_desproducto_t(ss.cramo, ss.cmodali, ss.ctipseg, ss.ccolect, 1,' || v_idioma
         || ')' || v_sep2 || ' ss.npoliza ' || v_sep2 || ' ss.ncertif ' || v_sep2
         || ' si.nsinies ' || v_sep2 || ' si.fsinies ' || v_sep2 || ' c.tcausin ' || v_sep2
         || ' d.tmotsin ' || v_sep2 || ' si.tsinies ' || v_sep2 || ' ff_desvalorfijo(6,'
         || v_idioma || ',s.cestsin) ' || v_sep2 || ' mv.fefepag ' || v_sep2 || ' mv.fcontab '
         || v_sep2 || ' pa.isinret ' || v_sep2 || ' pa.iretenc ' || v_sep2
         || ' ff_desvalorfijo(3, ' || v_idioma || ', mv.cestpag) ' || v_sep2
         || ' pac_isqlfor.f_dades_persona(t.sperson, 4,' || v_idioma || ')||' || CHR(39) || ' '
         || CHR(39)   --tomador
                   || '|| pac_isqlfor.f_dades_persona(t.sperson, 5,' || v_idioma || ') '
         || v_sep2 || ' pac_isqlfor.f_dades_persona(t.sperson, 1,' || v_idioma || ') '
         || v_sep2 || ' pac_isqlfor.f_dades_persona(a.sperson, 4,' || v_idioma || ')||'
         || CHR(39) || ' '   --aseg
                          || CHR(39) || '|| pac_isqlfor.f_dades_persona(a.sperson, 5, '
         || v_idioma || ' ) ' || v_sep2 || ' pac_isqlfor.f_dades_persona(a.sperson, 1,'
         || v_idioma || ') ' || v_sep2
         || ' DECODE( pa.sperson, NULL ,''-'', pac_isqlfor.f_dades_persona(pa.sperson, 1, '
         || v_idioma || ')||' || CHR(39) || ' ' || CHR(39)
         || '|| pac_isqlfor.f_dades_persona( pa.sperson,4,' || v_idioma || ')||' || CHR(39)
         || ' ' || CHR(39) || '|| pac_isqlfor.f_dades_persona(pa.sperson,5,' || v_idioma
         || ')) ' || v_sep2   --benef
                           || ' ss.cagente ' || v_sep2
         || ' decode(sp.sperson,NULL,NULL,f_nombre(sp.sperson, 1)) ' || v_sep3 || ' linea '
         || ' FROM sin_tramita_movpago mv, sin_tramita_pago pa, sin_siniestro si, seguros ss, agrupapro ag, '
         || ' sin_descausa c, sin_desmotcau d, sin_movsiniestro s, sin_prof_profesionales sp, '
         || ' sin_tramita_gestion st, tomadores t, asegurados a '
         || ' WHERE pa.nsinies = si.nsinies ' || ' AND mv.sidepag = pa.sidepag '
         || ' and pa.SPERSON= nvl( ' || CHR(39) || v_sperson_benef || CHR(39)
         || ', pa.SPERSON) ' || ' AND(mv.cestpag =  ' || CHR(39) || p_cestpag || CHR(39)
         || ' OR ' || CHR(39) || p_cestpag || CHR(39) || ' IS NULL) '
         || ' AND mv.fcontab BETWEEN TO_DATE(' || CHR(39) || p_fdesde || CHR(39)
         || ', ''ddmmrrrr'') AND TO_DATE(' || CHR(39) || p_fhasta || CHR(39)
         || ', ''ddmmrrrr'') ' || ' AND mv.nmovpag = (SELECT MAX(m2.nmovpag) '
         || ' FROM sin_tramita_movpago m2 ' || ' WHERE m2.sidepag = mv.sidepag '
         || ' AND fcontab <= TO_DATE(' || CHR(39) || p_fhasta || CHR(39) || ', ''ddmmrrrr'')) '
         || ' AND t.sseguro = ss.sseguro ' || ' AND t.sperson = NVL(' || CHR(39)
         || v_sperson_tom || CHR(39) || ', t.sperson) ' || ' AND a.sseguro = ss.sseguro '
         || ' AND a.sperson = NVL(' || CHR(39) || v_sperson_aseg || CHR(39) || ', a.sperson) '
         || ' AND ag.cidioma = ' || v_idioma || ' AND ag.cagrpro = ss.cagrpro '
         || ' AND(ag.cagrpro = ' || CHR(39) || p_cagrpro || CHR(39) || ' OR' || CHR(39)
         || p_cagrpro || CHR(39) || ' IS NULL) ' || ' AND si.sseguro = ss.sseguro '
         || ' AND(ss.cramo = ' || CHR(39) || p_cramo || CHR(39) || 'OR' || CHR(39) || p_cramo
         || CHR(39) || ' IS NULL) ' || ' AND(ss.sproduc = ' || CHR(39) || p_sproduc || CHR(39)
         || 'OR ' || CHR(39) || p_sproduc || CHR(39) || ' IS NULL) ' || ' AND ss.cempres = '
         || CHR(39) || p_cempres || CHR(39) || ' AND c.cidioma = ag.cidioma '
         || ' AND c.ccausin = si.ccausin ' || ' AND d.cidioma = ag.cidioma '
         || ' AND d.ccausin = si.ccausin ' || ' AND(si.ccausin = ' || CHR(39) || p_ccausin
         || CHR(39) || ' OR' || CHR(39) || p_ccausin || CHR(39) || 'IS NULL)'
         || ' AND d.cmotsin = si.cmotsin ' || ' AND(d.cmotsin = ' || CHR(39) || p_cmotsin
         || CHR(39) || ' OR ' || CHR(39) || p_cmotsin || CHR(39) || ' IS NULL) '
         || ' AND s.nsinies = si.nsinies ' || ' AND s.nmovsin = (SELECT MAX(s2.nmovsin) '
         || ' FROM sin_movsiniestro s2 ' || ' WHERE s2.nsinies = si.nsinies) '
         || ' AND(s.cestsin = ' || CHR(39) || p_cestsin || CHR(39) || ' OR ' || CHR(39)
         || p_cestsin || CHR(39) || ' IS NULL) ' || ' AND(ss.cagente, ss.cempres) IN( '
         || ' SELECT rc.cagente, rc.cempres ' || ' FROM (SELECT     rc.cagente, rc.cempres '
         || ' FROM redcomercial rc ' || ' WHERE rc.fmovfin IS NULL '
         || ' START WITH rc.cagente =  NVL(' || CHR(39) || p_cagente || CHR(39)
         || ', ff_agente_cpolvisio(pac_user.ff_get_cagente(f_user)))'
         || ' CONNECT BY PRIOR rc.cagente = rc.cpadre '
         || ' AND PRIOR rc.fmovfin IS NULL) rc, ' || ' agentes_agente_pol a '
         || ' WHERE rc.cagente = a.cagente) '
         || 'AND(pac_redcomercial.f_busca_padre(ss.cempres, ss.cagente, NULL, NULL) = '
         || CHR(39) || p_sucursal || CHR(39) || ' OR ' || CHR(39) || p_sucursal || CHR(39)
         || ' IS NULL)' || ' AND(pa.ctipdes = ' || CHR(39) || p_ctipdes || CHR(39) || ' OR '
         || CHR(39) || p_ctipdes || CHR(39) || ' IS NULL) '
         || ' AND st.nsinies(+) = si.nsinies ' || ' AND sp.sprofes(+) = st.sprofes '
         || ' AND(st.sprofes = ' || CHR(39) || p_sprofes || CHR(39) || ' OR ' || CHR(39)
         || p_sprofes || CHR(39) || ' IS NULL) ' || ' AND(st.sprofes IS NOT NULL '
         || ' AND st.sgestio = (SELECT MAX(sg.sgestio) ' || ' FROM sin_tramita_gestion sg '
         || ' WHERE sg.nsinies(+) = si.nsinies) ' || ' OR st.sprofes IS NULL)';
      v_ntraza := 9999;

               /*
               SELECT ss.cagrpro || ';' || ag.tagrpro || ';' || ss.cramo || ';'
                || ff_desramo(ss.cramo, :v_idioma) || ';' || ss.sproduc || ';'
                || f_desproducto_t(ss.cramo, ss.cmodali, ss.ctipseg, ss.ccolect, 1, :v_idioma)
                || ';' || ss.npoliza || ';' || ss.ncertif || ';' || si.nsinies || ';'
                || si.fsinies || ';' || c.tcausin || ';' || d.tmotsin || ';' || si.tsinies || ';'
                || ff_desvalorfijo(6, :v_idioma, NVL(:cestsin, s.cestsin)) || ';' || mv.fefepag
                || ';' || mv.fcontab || ';' || pa.isinret || ';' || pa.iretenc || ';'
                || ff_desvalorfijo(3, :v_idioma, mv.cestpag)|| ';'||
             pac_isqlfor.f_dades_persona(t.sperson, 4,:v_idioma) || ' '--tomador
            || pac_isqlfor.f_dades_persona(t.sperson, 5, :v_idioma)|| ';'||
              pac_isqlfor.f_dades_persona(t.sperson, 1,:v_idioma) || ';'||
             pac_isqlfor.f_dades_persona(a.sperson, 4,:v_idioma) || ' '--aseg
             || pac_isqlfor.f_dades_persona(a.sperson, 5, :v_idioma ) || ';'||
             pac_isqlfor.f_dades_persona(a.sperson, 1, :v_idioma)|| ';'||
      --benef
       DECODE( pa.sperson, NULL ,'-', pac_isqlfor.f_dades_persona(pa.sperson, 1, :v_idioma ) || ' '|| pac_isqlfor.f_dades_persona( pa.sperson,4, :v_idioma) ||' '|| pac_isqlfor.f_dades_persona(pa.sperson,5,:v_idioma))
          || ';' || ss.cagente
                || ';' || f_nombre(sp.sperson, 1) linea
           FROM sin_tramita_movpago mv, sin_tramita_pago pa, sin_siniestro si, seguros ss, agrupapro ag,
                sin_descausa c, sin_desmotcau d, sin_movsiniestro s, sin_prof_profesionales sp,
                sin_tramita_gestion st, tomadores t, asegurados a
          WHERE pa.nsinies = si.nsinies
            AND mv.sidepag = pa.sidepag
            and pa.SPERSON= nvl(:v_sperson_benef , pa.SPERSON)
            AND(mv.cestpag = :p_cestpag
                OR :p_cestpag IS NULL)
            AND mv.fcontab BETWEEN TO_DATE(:p_fdesde, 'ddmmyyyy') AND TO_DATE(:p_fhasta, 'ddmmyyyy')
            AND mv.nmovpag = (SELECT MAX(m2.nmovpag)
                                FROM sin_tramita_movpago m2
                               WHERE m2.sidepag = mv.sidepag
                                 AND fcontab <= TO_DATE(:p_fhasta, 'ddmmyyyy'))
            AND t.sseguro = ss.sseguro
              AND t.sperson = NVL(:v_sperson_tom, t.sperson)
             AND a.sseguro = ss.sseguro
              AND a.sperson = NVL(:v_sperson_aseg, a.sperson)
            AND ag.cidioma = :v_idioma
            AND ag.cagrpro = ss.cagrpro
            AND(ag.cagrpro = :p_cagrpro
                OR :p_cagrpro IS NULL)
            AND si.sseguro = ss.sseguro
            AND(ss.cramo = :p_cramo
                OR :p_cramo IS NULL)
            AND(ss.sproduc = :p_sproduc
                OR :p_sproduc IS NULL)
            AND ss.cempres = :p_cempres
            AND c.cidioma = ag.cidioma
            AND c.ccausin = si.ccausin
            AND d.cidioma = ag.cidioma
            AND d.ccausin = si.ccausin
            AND(si.ccausin = :p_ccausin
                OR :p_ccausin IS NULL)
            AND d.cmotsin = si.cmotsin
            AND(d.cmotsin = :p_cmotsin
                OR :p_cmotsin IS NULL)
            AND s.nsinies = si.nsinies
            AND s.nmovsin = (SELECT MAX(s2.nmovsin)
                               FROM sin_movsiniestro s2
                              WHERE s2.nsinies = si.nsinies)
            AND(s.cestsin = :p_cestsin
                OR :p_cestsin IS NULL)
            AND(ss.cagente, ss.cempres) IN(
                  SELECT rc.cagente, rc.cempres
                    FROM (SELECT     rc.cagente, rc.cempres
                                FROM redcomercial rc
                               WHERE rc.fmovfin IS NULL
                          START WITH rc.cagente =
                                        NVL(:p_cagente,
                                            ff_agente_cpolvisio(pac_user.ff_get_cagente(f_user)))
                          CONNECT BY PRIOR rc.cagente = rc.cpadre
                                 AND PRIOR rc.fmovfin IS NULL) rc,
                         agentes_agente_pol a
                   WHERE rc.cagente = a.cagente)
            AND(pac_redcomercial.f_busca_padre(ss.cempres, ss.cagente, NULL, NULL) = :p_sucursal
                OR :p_sucursal IS NULL)
            AND st.nsinies(+) = si.nsinies
            AND sp.sprofes(+) = st.sprofes
            AND(st.sprofes = :p_sprofes
                OR :p_sprofes IS NULL)
            AND(st.sprofes IS NOT NULL
                AND st.sgestio = (SELECT MAX(sg.sgestio)
                                    FROM sin_tramita_gestion sg
                                   WHERE sg.nsinies(+) = si.nsinies)
                OR st.sprofes IS NULL)


               */
      IF v_txt IS NULL THEN
         v_txt := 'select 0 from dual';
      END IF;

      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_list658_det;

--FIN BUG 24776 -- 04/02/2013--ETM --
   -- 2.0025615: confPG100-(confPG100)-Parametrizacion- Administracion y Finanzas- Parametrizacion Cierres - Inicio
   FUNCTION f_661_cab(pcempres IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_conf.f_661_cab';
      v_tparam       VARCHAR2(1000);
      v_ntraza       NUMBER := 0;
      v_sep          VARCHAR2(1) := ';';
      v_ret          VARCHAR2(1) := CHR(10);
      v_init         VARCHAR2(32000);
      v_ttexto       VARCHAR2(32000);
   BEGIN
      v_ttexto :=
         '
select
       '' ''||nvl(f_axis_literales(9002202,x.idi),''*'')||'';'' -- Sucursal
       ||f_axis_literales(9905164,x.idi)||'';'' -- Codigo Sucursal
       ||f_axis_literales(107248,x.idi)||'';'' -- Ramo DGS
       ||f_axis_literales(100784,x.idi)||'';'' -- Ramo
       ||f_axis_literales(100943,x.idi)||'';'' -- Modalidad
       ||f_axis_literales(102098,x.idi)||'';'' -- Tipo seguro
       ||f_axis_literales(9001021,x.idi)||'';'' -- Colectivo
       ||f_axis_literales(100829,x.idi)||'';'' -- Producto
       ||f_axis_literales(9002215,x.idi)||'';'' -- Seguro
       ||f_axis_literales(9001875,x.idi)||'';'' -- P¿liza
       ||f_axis_literales(101168,x.idi)||'';'' -- Certificado
       ||f_axis_literales(111274,x.idi)||'';'' -- Duraci¿n:
       ||f_axis_literales(100582,x.idi)||'';'' -- Efecte
       ||f_axis_literales(100829,x.idi)||'';'' -- Producto
       ||f_axis_literales(101672,x.idi)||'';'' -- Prima anual
       ||f_axis_literales(180063,x.idi)||'';'' -- Cap. Defunci¿
       ||f_axis_literales(107118,x.idi)||'';'' -- Capital garantit
       ||f_axis_literales(107120,x.idi)||'';'' -- Provisi¿ matem¿tica
       ||f_axis_literales(107049,x.idi)||'';'' -- Inter¿s T¿cnico
       ||decode(nvl(pac_parametros.f_parlistado_n('
         || pcempres
         || ',''GASTOS_PROVMAT''),0),1,f_axis_literales(9901665,x.idi),null)||'';''
       ||decode(nvl(pac_parametros.f_parlistado_n('
         || pcempres
         || ',''GASTOS_PROVMAT''),0),1,f_axis_literales(9901669,x.idi),null)||'';''
       ||decode(nvl(pac_parametros.f_parlistado_n('
         || pcempres
         || ',''GASTOS_PROVMAT''),0),1,f_axis_literales(9901666,x.idi),null)||'';''
       linea
from   (select nvl(f_usu_idioma,1) idi from dual) x,
       dual
';
      RETURN v_ttexto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END;

   FUNCTION f_661_det(
      pfcalcul IN VARCHAR2,
      psproces IN VARCHAR2,
      pcempres IN VARCHAR2,
      pcramo IN VARCHAR2,
      pcmodali IN VARCHAR2,
      pctipseg IN VARCHAR2,
      pccolect IN VARCHAR2,
      pcagente IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_conf.f_661_det';
      v_tparam       VARCHAR2(1000);
      v_ntraza       NUMBER := 0;
      v_sep          VARCHAR2(1) := ';';
      v_ret          VARCHAR2(1) := CHR(10);
      v_init         VARCHAR2(32000);
      v_ttexto       VARCHAR2(32000);
   BEGIN
      --BUG 0040577 -- 29/02/2016--VCG --INI-valida si es para confitiva
    IF pcempres = 17
     THEN
      v_ttexto :=
            'SELECT ff_desagente(pac_redcomercial.f_busca_padre(cempres, nvl(cagente,scagente), NULL, NULL))
         ||'';''||SUBSTR(pac_redcomercial.f_busca_padre(cempres, nvl(cagente,scagente), NULL, NULL),-3)
         ||'';''||cramdgs||'';''||cramo||'';''||cmodali||'';''||ctipseg||'';''||ccolect||'';''||f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, nvl(f_usu_idioma,1))||'';''
||sseguro||'';''||npoliza||'';''||ncertif||'';''||nduraci||'';''||fefecto||'';''||sproduc||'';''||ipriini||'';''||ivalact||'';''||icapgar||'';''||ipromat||'';''||nvl(PINTTEC,0)||'';''||
decode(nvl(pac_parametros.f_parlistado_n(cempres,''GASTOS_PROVMAT''),0),1,nvl(gprovi,0),null)||'';''||decode(nvl(pac_parametros.f_parlistado_n(cempres,''GASTOS_PROVMAT''),0),1,nvl(gprima,0),null)||'';''||
decode(nvl(pac_parametros.f_parlistado_n(cempres,''GASTOS_PROVMAT''),0),1,nvl(grentas,0),null)||'';''||'' '' linea from (
SELECT k.nmovimi_,agco.cagente,s.cagente scagente,p.cramdgs, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro, s.npoliza, s.ncertif,s.nduraci, s.fefecto, s.sproduc,
pac_corretaje.f_impcor_agente(SUM(p.ipriini),agco.cagente,s.sseguro,k.nmovimi_) ipriini,pac_corretaje.f_impcor_agente((SELECT ivalact FROM provmat WHERE fcalcul = to_date('''
         || pfcalcul
         || ''',''ddmmyyyy'')
AND sproces = '
         || psproces
         || '
AND cempres = '
         || pcempres
         || '
AND cgarant = 6901
AND sseguro = s.sseguro
UNION
SELECT ivalact FROM provmat_previo WHERE fcalcul = to_date('''
         || pfcalcul
         || ''',''ddmmyyyy'')
AND sproces = '
         || psproces
         || '
AND cempres = '
         || pcempres
         || '
AND cgarant = 6901
AND sseguro = s.sseguro
),agco.cagente,s.sseguro,k.nmovimi_) ivalact,
pac_corretaje.f_impcor_agente(sum(p.icapgar),agco.cagente,s.sseguro,k.nmovimi_) icapgar,pac_corretaje.f_impcor_agente(sum(p.ipromat),agco.cagente,s.sseguro,k.nmovimi_) ipromat,
pac_corretaje.f_impcor_agente(s.iprianu,agco.cagente,s.sseguro,k.nmovimi_) iprianu,ins.pinttec, s.cempres,
pac_corretaje.f_impcor_agente(SUM((SELECT crespue FROM pregunpolseg p WHERE p.cpregun IN(565) AND p.sseguro = s.sseguro AND p.nmovimi = ins.nmovimi)),agco.cagente,s.sseguro,k.nmovimi_) gprovi,
pac_corretaje.f_impcor_agente(SUM((SELECT crespue FROM pregunpolseg p WHERE p.cpregun IN(550) AND p.sseguro = s.sseguro AND p.nmovimi = ins.nmovimi)),agco.cagente,s.sseguro,k.nmovimi_) gprima,
pac_corretaje.f_impcor_agente(SUM((SELECT crespue FROM pregunpolseg p WHERE p.cpregun IN(564) AND p.sseguro = s.sseguro AND p.nmovimi = ins.nmovimi)),agco.cagente,s.sseguro,k.nmovimi_) grentas
FROM seguros s, (SELECT CEMPRES, FCALCUL, SPROCES, CRAMDGS, CRAMO, CMODALI, CTIPSEG, CCOLECT, SSEGURO, CGARANT, CPROVIS, nvl(IPRIINI_moncon,IPRIINI) IPRIINI, nvl(IVALACT_moncon,IVALACT) IVALACT, NVL(ICAPGAR_MONCON,ICAPGAR) ICAPGAR, NVL(IPROMAT_MONCON,IPROMAT) IPROMAT, CERROR, NRIESGO
FROM provmat WHERE fcalcul = to_date('''
         || pfcalcul
         || ''',''ddmmyyyy'')
AND sproces = '
         || psproces
         || '
AND cempres = '
         || pcempres
         || '
UNION ALL SELECT CEMPRES, FCALCUL, SPROCES, CRAMDGS, CRAMO, CMODALI, CTIPSEG, CCOLECT, SSEGURO, CGARANT, CPROVIS, NVL(IPRIINI_MONCON,IPRIINI) IPRIINI, NVL(IVALACT_MONCON,IVALACT) IVALACT, NVL(ICAPGAR_MONCON,ICAPGAR) ICAPGAR, NVL(IPROMAT_MONCON,IPROMAT) IPROMAT, CERROR, NRIESGO
FROM provmat_previo WHERE fcalcul = to_date('''
         || pfcalcul
         || ''',''ddmmyyyy'')
AND sproces = '
         || psproces
         || '
AND cempres = '
         || pcempres
         || ') p,
(select z.sseguro, max(z.nmovimi) nmovimi_ from movseguro z where z.fmovimi <= to_date('''
         || pfcalcul
         || ''',''ddmmyyyy'') group by z.sseguro) k, intertecseg ins,age_corretaje agco
WHERE p.sseguro = s.sseguro and k.sseguro = s.sseguro and agco.sseguro(+) = k.sseguro
and nvl(agco.nmovimi,-1) = (select nvl(max(z.nmovimi),-1) from age_corretaje z where z.sseguro = agco.sseguro and z.nmovimi <= k.nmovimi_)
AND s.cramo   = '
         || NVL (pcramo, 's.cramo')
         || '
AND s.cmodali = '
         || NVL (pcmodali, 's.cmodali')
         || '
AND s.ctipseg = '
         || NVL (pctipseg, 's.ctipseg')
         || '
AND s.ccolect = '
         || NVL (pccolect, 's.ccolect')
         || '
AND s.cagente = '
         || NVL (pcagente, 's.cagente')
         || '
and ins.sseguro(+) = s.sseguro
and (ins.sseguro is null or ins.nmovimi = (select max(nmovimi) from intertecseg ins2 where ins2.sseguro = ins.sseguro
and to_char(ins2.fefemov,''rrrrmm'') <= to_char(to_date('''
         || pfcalcul
         || ''',''ddmmyyyy''),''rrrrmm'')))
and p.cramo = 337
and p.cmodali <> 1
GROUP BY nmovimi_,agco.cagente,p.cramdgs, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro, s.npoliza, s.ncertif, s.nduraci, s.fefecto, s.sproduc, s.iprianu, s.cagente, ins.PINTTEC,  s.cempres
ORDER BY s.npoliza, s.ncertif)';
ELSE
       v_ttexto :=
         'SELECT ff_desagente(pac_redcomercial.f_busca_padre(cempres, nvl(cagente,scagente), NULL, NULL))
         ||'';''||SUBSTR(pac_redcomercial.f_busca_padre(cempres, nvl(cagente,scagente), NULL, NULL),-3)
         ||'';''||cramdgs||'';''||cramo||'';''||cmodali||'';''||ctipseg||'';''||ccolect||'';''||f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, nvl(f_usu_idioma,1))||'';''
||sseguro||'';''||npoliza||'';''||ncertif||'';''||nduraci||'';''||fefecto||'';''||sproduc||'';''||ipriini||'';''||ivalact||'';''||icapgar||'';''||ipromat||'';''||nvl(PINTTEC,0)||'';''||
decode(nvl(pac_parametros.f_parlistado_n(cempres,''GASTOS_PROVMAT''),0),1,nvl(gprovi,0),null)||'';''||decode(nvl(pac_parametros.f_parlistado_n(cempres,''GASTOS_PROVMAT''),0),1,nvl(gprima,0),null)||'';''||
decode(nvl(pac_parametros.f_parlistado_n(cempres,''GASTOS_PROVMAT''),0),1,nvl(grentas,0),null)||'';''||'' '' linea from (
SELECT k.nmovimi_,agco.cagente,s.cagente scagente,p.cramdgs, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro, s.npoliza, s.ncertif,s.nduraci, s.fefecto, s.sproduc,
pac_corretaje.f_impcor_agente(SUM(p.ipriini),agco.cagente,s.sseguro,k.nmovimi_) ipriini,pac_corretaje.f_impcor_agente(sum(p.ivalact),agco.cagente,s.sseguro,k.nmovimi_) ivalact,
pac_corretaje.f_impcor_agente(sum(p.icapgar),agco.cagente,s.sseguro,k.nmovimi_) icapgar,pac_corretaje.f_impcor_agente(sum(p.ipromat),agco.cagente,s.sseguro,k.nmovimi_) ipromat,
pac_corretaje.f_impcor_agente(s.iprianu,agco.cagente,s.sseguro,k.nmovimi_) iprianu,ins.pinttec, s.cempres,
pac_corretaje.f_impcor_agente(SUM((SELECT crespue FROM pregunpolseg p WHERE p.cpregun IN(565) AND p.sseguro = s.sseguro AND p.nmovimi = ins.nmovimi)),agco.cagente,s.sseguro,k.nmovimi_) gprovi,
pac_corretaje.f_impcor_agente(SUM((SELECT crespue FROM pregunpolseg p WHERE p.cpregun IN(550) AND p.sseguro = s.sseguro AND p.nmovimi = ins.nmovimi)),agco.cagente,s.sseguro,k.nmovimi_) gprima,
pac_corretaje.f_impcor_agente(SUM((SELECT crespue FROM pregunpolseg p WHERE p.cpregun IN(564) AND p.sseguro = s.sseguro AND p.nmovimi = ins.nmovimi)),agco.cagente,s.sseguro,k.nmovimi_) grentas
FROM seguros s, (SELECT CEMPRES, FCALCUL, SPROCES, CRAMDGS, CRAMO, CMODALI, CTIPSEG, CCOLECT, SSEGURO, CGARANT, CPROVIS, nvl(IPRIINI_moncon,IPRIINI) IPRIINI, nvl(IVALACT_moncon,IVALACT) IVALACT, NVL(ICAPGAR_MONCON,ICAPGAR) ICAPGAR, NVL(IPROMAT_MONCON,IPROMAT) IPROMAT, CERROR, NRIESGO
FROM provmat WHERE fcalcul = to_date('''
         || pfcalcul || ''',''ddmmyyyy'')
AND sproces = ' || psproces || '
AND cempres = ' || pcempres
         || '
UNION ALL SELECT CEMPRES, FCALCUL, SPROCES, CRAMDGS, CRAMO, CMODALI, CTIPSEG, CCOLECT, SSEGURO, CGARANT, CPROVIS, NVL(IPRIINI_MONCON,IPRIINI) IPRIINI, NVL(IVALACT_MONCON,IVALACT) IVALACT, NVL(ICAPGAR_MONCON,ICAPGAR) ICAPGAR, NVL(IPROMAT_MONCON,IPROMAT) IPROMAT, CERROR, NRIESGO
FROM provmat_previo WHERE fcalcul = to_date('''
         || pfcalcul || ''',''ddmmyyyy'')
AND sproces = ' || psproces || '
AND cempres = ' || pcempres
         || ') p,
(select z.sseguro, max(z.nmovimi) nmovimi_ from movseguro z where z.fmovimi <= to_date('''
         || pfcalcul
         || ''',''ddmmyyyy'') group by z.sseguro) k, intertecseg ins,age_corretaje agco
WHERE p.sseguro = s.sseguro and k.sseguro = s.sseguro and agco.sseguro(+) = k.sseguro
and nvl(agco.nmovimi,-1) = (select nvl(max(z.nmovimi),-1) from age_corretaje z where z.sseguro = agco.sseguro and z.nmovimi <= k.nmovimi_)
AND s.cramo   = '
         || NVL(pcramo, 's.cramo') || '
AND s.cmodali = ' || NVL(pcmodali, 's.cmodali') || '
AND s.ctipseg = ' || NVL(pctipseg, 's.ctipseg') || '
AND s.ccolect = ' || NVL(pccolect, 's.ccolect') || '
AND s.cagente = ' || NVL(pcagente, 's.cagente')
         || '
and ins.sseguro(+) = s.sseguro
and (ins.sseguro is null or ins.nmovimi = (select max(nmovimi) from intertecseg ins2 where ins2.sseguro = ins.sseguro
and to_char(ins2.fefemov,''rrrrmm'') <= to_char(to_date('''
         || pfcalcul
         || ''',''ddmmyyyy''),''rrrrmm'')))
GROUP BY nmovimi_,agco.cagente,p.cramdgs, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro, s.npoliza, s.ncertif, s.nduraci, s.fefecto, s.sproduc, s.iprianu, s.cagente, ins.PINTTEC,  s.cempres
ORDER BY s.npoliza, s.ncertif)';
END IF;
    --BUG 0040577 -- 29/02/2016--VCG --FIN-valida si es para confitiva

      RETURN v_ttexto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_661_det;

   /******************************************************************************************
     Descripci¿: f_662_det Detalle del map 662
     return:     texto cabecera
   ******************************************************************************************/
   FUNCTION f_662_det(fecha_calcul IN VARCHAR2, cproces IN VARCHAR2, cempres IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_conf.f_662_det';
      v_tparam       VARCHAR2(1000);
      v_ntraza       NUMBER := 0;
      v_sep          VARCHAR2(1) := ';';
      v_ret          VARCHAR2(1) := CHR(10);
      v_init         VARCHAR2(32000);
      v_ttexto       VARCHAR2(32000);
      v_pparcial     VARCHAR2(32000);
   BEGIN
      --IPH --bug 35149 nota 0205275 --se elimina substr para el cagente, se incluye outer join en bloque principal
      --entre seguros y asegurados(+)

      --KJSC BUG 35149_223596 El cliente espera ver el valor de la prima pendiente (se le ha de sacar el importe del pago parcial en caso de que tenga).
      v_pparcial :=
               '(1 - pac_adm_cobparcial.f_get_porcentaje_cobro_parcial(z.nrecibo, NULL,NULL))';
      --pac_corretaje.f_impcor_agente(vdr.iprinet + vdr.irecfra,agco.cagente,z.sseguro,z.nmovimi)|| '';'' || -- pneta, anterior
      v_ttexto :=
         'select
          pac_redcomercial.f_busca_padre(cempres,nvl(agco.cagente,z.cagente), 2, NULL)||'';''||
          z.numide||'';''||
          z.numide_aseg||'';''||
          z.npoliza||'';''||
          z.nrecibo||'';''||
          z.ncertif||'';''||
          z.fefecto||'';''||
          z.fvencim||'';''||
          z.femisio||'';''||
          To_char(ROUND(pac_corretaje.f_impcor_agente((vdr.iprinet + vdr.irecfra),agco.cagente,z.sseguro,z.nmovimi)),''999G999G999G999D99'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')||'';''||
          To_char(ROUND(pac_corretaje.f_impcor_agente(vdr.iips,agco.cagente,z.sseguro,z.nmovimi)),''999G999G999G999D99'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')||'';''||
          To_char(ROUND(pac_corretaje.f_impcor_agente(vdr.iips,agco.cagente,z.sseguro,z.nmovimi)),''999G999G999G999D99'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')||'';''||
          z.cramo||'';''||
          ROUND(z.fvencim-z.finiefe)||'';''||
          ROUND(z.fcalcul-z.finiefe)||'';''||
          (SELECT (case WHEN ROUND(z.fcalcul-z.finiefe) >= 75  THEN ''APTO''  ELSE ''NO APTO'' END) FROM DUAL)||'';''||
          ROUND(z.fvencim-z.femisio)||'';''||
          ROUND(z.fcalcul-z.femisio)||'';''||
          (SELECT (case WHEN ROUND(z.fcalcul-z.femisio) >= 75  THEN ''APTO''  ELSE ''NO APTO'' END) FROM DUAL)||'';''||
          To_char(ROUND(z.ipppc),''999G999G999G999D99'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')||'';''||
		      To_char(ROUND(z.ipppc_moncon),''999G999G999G999D99'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')||'';''||
		      To_char(ROUND(z.ipppc_coa),''999G999G999G999D99'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')||'';''||
		      To_char(ROUND(z.ipppc_moncon_coa),''999G999G999G999D99'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')
from
(
SELECT s.cempres,s.cagente,u.nmovimi,r.sseguro,r.ctipcoa,ff_descompania(pac_cuadre_adm.f_es_vida(s.sseguro)) tempres,  ff_desramo(u.cramo,8) cramo, u.cmodali,
       u.ctipseg, u.ccolect,
       pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL) delegacion,
       INITCAP(f_desagente_t(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL))) desc_delegacion,
       s.cagente agente, INITCAP(f_desagente_t(s.cagente)) desc_agente,
       s.sproduc producto,
       f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 8) desc_producto,
       s.npoliza, s.ncertif,
       p.ctipide ctipide, decode(p.ctipide, 37, substr(p.nnumide,-1)) tdigitoide,
       decode(p.ctipide, 37, substr(p.nnumide,1,length(p.nnumide)-1), p.nnumide) numide,
       f_nombre(nvl(r.sperson,t.sperson),1) pagador,
       p2.nnumide numide_aseg,
       f_nombre(nvl(a.sperson,t.sperson),1) nombre_aseg,
       u.nrecibo, SUM(nvl(u.ipppc_moncon,u.ipppc)) prim_por_c,
       0 iva_por_c, SUM(nvl(u.iderreg_moncon,u.iderreg)) gast_exp_por_c,
       0 runt_por_c, u.tedad edades,
       (select pac_adm_cobparcial.f_get_importe_cobro_parcial(u.nrecibo,null,null) from dual) vcobparc,
       r.femisio femisio, r.fefecto fefecto, r.fvencim fvencim, u.fcalcul fcalcul, u.finiefe finiefe, sum(u.iprovmora) iprovmora,nvl(r.sperson,t.sperson) sperson,
       (select sum(ipppc) from PPPC_CONF_PREVI where SPROCES = ' || cproces || ' and NRECIBO = u.nrecibo and CMETODO = 1) ipppc,
       (select sum(ipppc_moncon) from PPPC_CONF_PREVI where SPROCES = ' || cproces || ' and NRECIBO = u.nrecibo and CMETODO = 1) ipppc_moncon,
	     (select sum(ipppc_coa) from PPPC_CONF_PREVI where SPROCES = ' || cproces || ' and NRECIBO = u.nrecibo and CMETODO = 1) ipppc_coa,
	     (select sum(ipppc_moncon_coa) from PPPC_CONF_PREVI where SPROCES = ' || cproces || ' and NRECIBO = u.nrecibo and CMETODO = 1) ipppc_moncon_coa
        FROM pppc_conf u, seguros s, tomadores t, asegurados a, recibos r, empresas e, per_personas p, per_personas p2
        WHERE s.sseguro = u.sseguro
           AND u.nrecibo = r.nrecibo
           AND u.nrecibo not in(select nrecibo from exclus_provisiones where FBAJA >= (SELECT FPERFIN FROM CIERRES WHERE CEMPRES = ' || cempres || ' AND SPROCES = ' || cproces || '))
           AND u.fcalcul = TO_DATE(''' || fecha_calcul || ''', ''ddmmyyyy'')
           AND u.sproces = ' || cproces || '
           AND u.cempres = ' || cempres || '
           AND u.cerror = 0
           AND u.cempres = e.cempres
           AND r.ctiprec <> 9
           and t.sseguro = s.sseguro
           and a.sseguro(+) = s.sseguro
           and a.norden (+) = 1
           and nvl(a.sperson,t.sperson) = p2.sperson
           and p.sperson = nvl(r.sperson,t.sperson)
        GROUP BY s.cempres,s.cagente,u.nmovimi,r.sseguro,s.npoliza, u.nrecibo,
           u.cramo, u.cmodali, u.ctipseg, u.ccolect, s.sproduc,
           f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 8),
           s.ncertif,a.sperson,nvl(r.sperson,t.sperson),
           pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL),
           INITCAP(f_desagente_t(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL))),
           s.cagente, INITCAP(f_desagente_t(s.cagente)),
           u.tedad, r.femisio, r.fefecto, r.fvencim, r.sseguro, s.ctipcoa, s.sseguro
           ,r.ctipcoa, p.ctipide, p.nnumide,f_nombre(nvl(a.sperson,t.sperson),1), p2.nnumide, u.fcalcul, u.finiefe, p.tdigitoide, u.ipppc, u.ipppc_moncon, u.ipppc_coa, u.ipppc_moncon_coa
       UNION ALL
        SELECT
         s.cempres,s.cagente,u.nmovimi,r.sseguro,r.ctipcoa,ff_descompania(pac_cuadre_adm.f_es_vida(s.sseguro)) tempres, ff_desramo(u.cramo,8) cramo, u.cmodali,
         u.ctipseg, u.ccolect,
         --IPH: 35149  SUBSTR(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL),-3) delegacion,
         pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL) delegacion,
         INITCAP(f_desagente_t(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL))) desc_delegacion,
         s.cagente agente, INITCAP(f_desagente_t(s.cagente)) desc_agente,
         s.sproduc producto,
         f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 8) desc_producto,
         s.npoliza, s.ncertif,
         p.ctipide ctipide, decode(p.ctipide, 37, substr(p.nnumide,-1)) tdigitoide,
         decode(p.ctipide, 37, substr(p.nnumide,1,length(p.nnumide)-1), p.nnumide) numide,
         f_nombre(nvl(r.sperson,t.sperson),1) pagador, p2.nnumide numide_aseg, f_nombre(nvl(a.sperson,t.sperson),1) nombre_aseg,
         u.nrecibo, SUM(nvl(u.ipppc_moncon,u.ipppc)) prim_por_c,
         0 iva_por_c, SUM(nvl(u.iderreg_moncon,u.iderreg)) gast_exp_por_c,
         0 runt_por_c, u.tedad edades,
         (select pac_adm_cobparcial.f_get_importe_cobro_parcial(u.nrecibo,null,null) from dual) vcobparc,
         r.femisio, r.fefecto, r.fvencim, u.fcalcul, u.finiefe, sum(u.iprovmora),nvl(r.sperson,t.sperson) sperson,
         (select sum(ipppc) from PPPC_CONF_PREVI where SPROCES = ' || cproces || ' and NRECIBO = u.nrecibo and CMETODO = 1) ipppc,
		     (select sum(ipppc_moncon) from PPPC_CONF_PREVI where SPROCES = ' || cproces || ' and NRECIBO = u.nrecibo and CMETODO = 1) ipppc_moncon,
         (select sum(ipppc_coa) from PPPC_CONF_PREVI where SPROCES = ' || cproces || ' and NRECIBO = u.nrecibo and CMETODO = 1) ipppc_coa,
		     (select sum(ipppc_moncon_coa) from PPPC_CONF_PREVI where SPROCES = ' || cproces || ' and NRECIBO = u.nrecibo and CMETODO = 1) ipppc_moncon_coa
        FROM pppc_conf_previ u, seguros s, recibos r, tomadores t,asegurados a, empresas e, per_personas p, per_personas p2
        WHERE s.sseguro = u.sseguro
           AND u.nrecibo = r.nrecibo
           AND u.nrecibo not in(select nrecibo from exclus_provisiones where FBAJA >= (SELECT FPERFIN FROM CIERRES WHERE CEMPRES = ' || cempres || ' AND SPROCES = ' || cproces || '))
           AND u.sproces = ' || cproces || '
           AND u.cempres = ' || cempres || '
           AND u.cerror = 0
           AND u.cempres = e.cempres
           AND r.ctiprec <> 9
           and t.sseguro = s.sseguro
           and a.sseguro(+) = s.sseguro
           and a.norden (+) = 1
           and nvl(a.sperson,t.sperson) = p2.sperson
           and p.sperson = nvl(r.sperson,t.sperson)
        GROUP BY s.cempres,s.cagente,u.nmovimi,r.sseguro,s.npoliza, u.nrecibo,
           u.cramo, u.cmodali, u.ctipseg, u.ccolect, s.sproduc,
           f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 8),
           s.ncertif,a.sperson,nvl(r.sperson,t.sperson),
           pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL),
           INITCAP(f_desagente_t(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL))),
           s.cagente, INITCAP(f_desagente_t(s.cagente)),
           u.tedad, r.femisio, r.fefecto, r.fvencim, r.sseguro, s.ctipcoa, s.sseguro,r.ctipcoa, p.ctipide, p.nnumide, p2.nnumide,
           f_nombre(nvl(a.sperson,t.sperson),1), u.fcalcul, u.finiefe, p.tdigitoide, u.ipppc, u.ipppc_moncon, u.ipppc_coa, u.ipppc_moncon_coa)z,
    vdetrecibos vdr,
    age_corretaje agco,
    (select nvl(f_usu_idioma,2) v_idioma from dual) x,
    (select sseguro, nmovimi, min(ctipben) ctipben from benespseg group by sseguro, nmovimi) b ,
     agentes_comp a
where vdr.nrecibo = z.nrecibo
and agco.sseguro(+) = z.sseguro
and nvl(agco.nmovimi,-1) =  (select nvl(max(x.nmovimi),-1) from age_corretaje x where x.sseguro = z.sseguro and x.nmovimi <= z.nmovimi)
and b.sseguro (+) = z.sseguro
and b.nmovimi (+) = z.nmovimi
and a.cagente = nvl(agco.cagente,z.cagente)';
      RETURN v_ttexto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_662_det;


    /******************************************************************************************
     Descripci¿: f_662_det Detalle del map 662
     return:     texto cabecera
   ******************************************************************************************/
   FUNCTION f_662_det_copia(fecha_calcul IN VARCHAR2, cproces IN VARCHAR2, cempres IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_conf.f_662_det';
      v_tparam       VARCHAR2(1000);
      v_ntraza       NUMBER := 0;
      v_sep          VARCHAR2(1) := ';';
      v_ret          VARCHAR2(1) := CHR(10);
      v_init         VARCHAR2(32000);
      v_ttexto       VARCHAR2(32000);
      v_pparcial     VARCHAR2(32000);
   BEGIN
      --IPH --bug 35149 nota 0205275 --se elimina substr para el cagente, se incluye outer join en bloque principal
      --entre seguros y asegurados(+)

      --KJSC BUG 35149_223596 El cliente espera ver el valor de la prima pendiente (se le ha de sacar el importe del pago parcial en caso de que tenga).
      v_pparcial :=
               '(1 - pac_adm_cobparcial.f_get_porcentaje_cobro_parcial(z.nrecibo, NULL,NULL))';
      --pac_corretaje.f_impcor_agente(vdr.iprinet + vdr.irecfra,agco.cagente,z.sseguro,z.nmovimi)|| '';'' || -- pneta, anterior
      v_ttexto :=
         'select  ff_desagente(pac_redcomercial.f_busca_padre(cempres, nvl(agco.cagente,z.cagente), 1, NULL))||'';''||
          pac_redcomercial.f_busca_padre(cempres,nvl(agco.cagente,z.cagente), 2, NULL)||'';''||
          ff_desagente(pac_redcomercial.f_busca_padre(cempres, nvl(agco.cagente,z.cagente), 2, NULL))||'';''||
         nvl(agco.cagente,z.cagente)||'';''||
         ff_desagente(nvl(agco.cagente,z.cagente))||'';''||
         z.cramo||'';''||
         z.producto||'';''||
         z.desc_producto||'';''||
         ff_desvalorfijo(672,x.v_idioma,z.ctipide)||'';''||
         z.numide||'';''||
         z.tdigitoide||'';''||
         z.pagador||'';''||
         z.numide_aseg||'';''||
         z.nombre_aseg||'';''||
         z.npoliza||'';''||
         z.ncertif||'';''||
         z.nrecibo||'';''||
         z.femisio||'';''||
         z.fefecto||'';''||
         z.fvencim||'';''||
         pac_corretaje.f_impcor_agente((vdr.iprinet + vdr.irecfra),agco.cagente,z.sseguro,z.nmovimi)||'';''||
         pac_corretaje.f_impcor_agente(vdr.iips,agco.cagente,z.sseguro,z.nmovimi)||'';''||
         (z.fcalcul-z.finiefe)||'';''||
         pac_corretaje.f_impcor_agente(z.prim_por_c,agco.cagente,z.sseguro,z.nmovimi)||'';''||
         z.edades||'';''||
        pac_corretaje.f_impcor_agente(decode(z.ctipcoa,8,vdr.iprinet,9,vdr.iprinet,0),agco.cagente,z.sseguro,z.nmovimi)||'';''||
        pac_corretaje.f_impcor_agente(decode(z.ctipcoa,1,vdr.icednet,2,vdr.icednet,0),agco.cagente,z.sseguro,z.nmovimi)||'';''||
        pac_corretaje.f_impcor_agente(z.vcobparc,agco.cagente,z.sseguro,z.nmovimi)||'';''||
        pac_isqlfor.f_telefono(z.sperson)||'';''||
        pac_isqlfor_conf.f_direccion(z.sperson,1)||'';''||
        pac_isqlfor.f_dirpais(z.sperson,1,x.v_idioma)||'';''||
        pac_isqlfor.f_poblacion(z.sperson,1)||'';''||
        pac_isqlfor.f_provincia(z.sperson,1)||'';''||
        ff_desvalorfijo(371,x.v_idioma,a.ctipint)||'';''||
        nvl(agco.cagente,z.cagente)||'';''||
        pac_isqlfor.f_agente(nvl(agco.cagente,z.cagente))||'';''||
        nvl(agco.ppartici,100)||'';''||
        pac_propio_conf.ff_pcomisi_pcomisi(z.sseguro, z.nrecibo, NULL)||'';''||
        ff_desvalorfijo(1053,x.v_idioma,b.ctipben)||'';''||
        pac_isqlfor.f_per_contactos(z.sperson,3)||'';''||
        pac_corretaje.f_impcor_agente(z.iprovmora,agco.cagente,z.sseguro,z.nmovimi)
from
(
SELECT s.cempres,s.cagente,u.nmovimi,r.sseguro,r.ctipcoa,ff_descompania(pac_cuadre_adm.f_es_vida(s.sseguro)) tempres,  ff_desramo(u.cramo,8) cramo, u.cmodali,
       u.ctipseg, u.ccolect,
       pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL) delegacion,
       INITCAP(f_desagente_t(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL))) desc_delegacion,
       s.cagente agente, INITCAP(f_desagente_t(s.cagente)) desc_agente,
       s.sproduc producto,
       f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 8) desc_producto,
       s.npoliza, s.ncertif,
       p.ctipide ctipide, decode(p.ctipide, 37, substr(p.nnumide,-1)) tdigitoide,
       decode(p.ctipide, 37, substr(p.nnumide,1,length(p.nnumide)-1), p.nnumide) numide,
       f_nombre(nvl(r.sperson,t.sperson),1) pagador,
       p2.nnumide numide_aseg,
       f_nombre(nvl(a.sperson,t.sperson),1) nombre_aseg,
       u.nrecibo, SUM(nvl(u.ipppc_moncon,u.ipppc)) prim_por_c,
       0 iva_por_c, SUM(nvl(u.iderreg_moncon,u.iderreg)) gast_exp_por_c,
       0 runt_por_c, u.tedad edades,
       (select pac_adm_cobparcial.f_get_importe_cobro_parcial(u.nrecibo,null,null) from dual) vcobparc,
       r.femisio femisio, r.fefecto fefecto, r.fvencim fvencim, u.fcalcul fcalcul, u.finiefe finiefe, sum(u.iprovmora) iprovmora,nvl(r.sperson,t.sperson) sperson
        FROM pppc_conf u, seguros s, tomadores t, asegurados a, recibos r, empresas e, per_personas p, per_personas p2
        WHERE s.sseguro = u.sseguro
           AND u.nrecibo = r.nrecibo
           AND u.fcalcul = TO_DATE(''' || fecha_calcul || ''', ''ddmmyyyy'')
           AND u.sproces = ' || cproces || '
           AND u.cempres = ' || cempres || '
           AND u.cerror = 0
           AND u.cempres = e.cempres
           AND r.ctiprec <> 9
           and t.sseguro = s.sseguro
           and a.sseguro(+) = s.sseguro
           and a.norden (+) = 1
           and nvl(a.sperson,t.sperson) = p2.sperson
           and p.sperson = nvl(r.sperson,t.sperson)
        GROUP BY s.cempres,s.cagente,u.nmovimi,r.sseguro,s.npoliza, u.nrecibo,
           u.cramo, u.cmodali, u.ctipseg, u.ccolect, s.sproduc,
           f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 8),
           s.ncertif,a.sperson,nvl(r.sperson,t.sperson),
           pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL),
           INITCAP(f_desagente_t(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL))),
           s.cagente, INITCAP(f_desagente_t(s.cagente)),
           u.tedad, r.femisio, r.fefecto, r.fvencim, r.sseguro, s.ctipcoa, s.sseguro
           ,r.ctipcoa, p.ctipide, p.nnumide,f_nombre(nvl(a.sperson,t.sperson),1), p2.nnumide, u.fcalcul, u.finiefe, p.tdigitoide
       UNION ALL
        SELECT
         s.cempres,s.cagente,u.nmovimi,r.sseguro,r.ctipcoa,ff_descompania(pac_cuadre_adm.f_es_vida(s.sseguro)) tempres, ff_desramo(u.cramo,8) cramo, u.cmodali,
         u.ctipseg, u.ccolect,
         --IPH: 35149  SUBSTR(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL),-3) delegacion,
         pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL) delegacion,
         INITCAP(f_desagente_t(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL))) desc_delegacion,
         s.cagente agente, INITCAP(f_desagente_t(s.cagente)) desc_agente,
         s.sproduc producto,
         f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 8) desc_producto,
         s.npoliza, s.ncertif,
         p.ctipide ctipide, decode(p.ctipide, 37, substr(p.nnumide,-1)) tdigitoide,
         decode(p.ctipide, 37, substr(p.nnumide,1,length(p.nnumide)-1), p.nnumide) numide,
         f_nombre(nvl(r.sperson,t.sperson),1) pagador, p2.nnumide numide_aseg, f_nombre(nvl(a.sperson,t.sperson),1) nombre_aseg,
         u.nrecibo, SUM(nvl(u.ipppc_moncon,u.ipppc)) prim_por_c,
         0 iva_por_c, SUM(nvl(u.iderreg_moncon,u.iderreg)) gast_exp_por_c,
         0 runt_por_c, u.tedad edades,
         (select pac_adm_cobparcial.f_get_importe_cobro_parcial(u.nrecibo,null,null) from dual) vcobparc,
         r.femisio, r.fefecto, r.fvencim, u.fcalcul, u.finiefe, sum(u.iprovmora),nvl(r.sperson,t.sperson) sperson
        FROM pppc_conf_previ u, seguros s, recibos r, tomadores t,asegurados a, empresas e, per_personas p, per_personas p2
        WHERE s.sseguro = u.sseguro
           AND u.nrecibo = r.nrecibo
                      AND u.fcalcul = TO_DATE(''' || fecha_calcul || ''', ''ddmmyyyy'')
           AND u.sproces = ' || cproces || '
           AND u.cempres = ' || cempres || '
           AND u.cerror = 0
           AND u.cempres = e.cempres
           AND r.ctiprec <> 9
           and t.sseguro = s.sseguro
           and a.sseguro(+) = s.sseguro
           and a.norden (+) = 1
           and nvl(a.sperson,t.sperson) = p2.sperson
           and p.sperson = nvl(r.sperson,t.sperson)
        GROUP BY s.cempres,s.cagente,u.nmovimi,r.sseguro,s.npoliza, u.nrecibo,
           u.cramo, u.cmodali, u.ctipseg, u.ccolect, s.sproduc,
           f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 8),
           s.ncertif,a.sperson,nvl(r.sperson,t.sperson),
           pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL),
           INITCAP(f_desagente_t(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL))),
           s.cagente, INITCAP(f_desagente_t(s.cagente)),
           u.tedad, r.femisio, r.fefecto, r.fvencim, r.sseguro, s.ctipcoa, s.sseguro,r.ctipcoa, p.ctipide, p.nnumide, p2.nnumide,
           f_nombre(nvl(a.sperson,t.sperson),1), u.fcalcul, u.finiefe, p.tdigitoide)z,
    vdetrecibos vdr,
    age_corretaje agco,
    (select nvl(f_usu_idioma,2) v_idioma from dual) x,
    (select sseguro, nmovimi, min(ctipben) ctipben from benespseg group by sseguro, nmovimi) b ,
     agentes_comp a
where vdr.nrecibo = z.nrecibo
and agco.sseguro(+) = z.sseguro
and nvl(agco.nmovimi,-1) =  (select nvl(max(x.nmovimi),-1) from age_corretaje x where x.sseguro = z.sseguro and x.nmovimi <= z.nmovimi)
and b.sseguro (+) = z.sseguro
and b.nmovimi (+) = z.nmovimi
and a.cagente = nvl(agco.cagente,z.cagente)';
      RETURN v_ttexto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_662_det_copia;


   /******************************************************************************************
     Descripci¿: f_664_det Detalle del map 664
     return:     texto cabecera
   ******************************************************************************************/
   FUNCTION f_664_det(fecha_calcul IN VARCHAR2, cproces IN VARCHAR2, cempres IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_conf.f_664_det';
      v_tparam       VARCHAR2(1000);
      v_ntraza       NUMBER := 0;
      v_sep          VARCHAR2(1) := ';';
      v_ret          VARCHAR2(1) := CHR(10);
      v_init         VARCHAR2(32000);
      v_ttexto       VARCHAR2(32000);
      v_pparcial     VARCHAR2(32000);
   BEGIN
      --IPH --bug 35149 nota 0205275 --se elimina substr para el cagente, se incluye outer join en bloque principal
      --entre seguros y asegurados(+)

      --KJSC BUG 35149_223596 El cliente espera ver el valor de la prima pendiente (se le ha de sacar el importe del pago parcial en caso de que tenga).
      v_pparcial :=
               '(1 - pac_adm_cobparcial.f_get_porcentaje_cobro_parcial(z.nrecibo, NULL,NULL))';
      --pac_corretaje.f_impcor_agente(vdr.iprinet + vdr.irecfra,agco.cagente,z.sseguro,z.nmovimi)|| '';'' || -- pneta, anterior
      v_ttexto :=
         'select
          pac_redcomercial.f_busca_padre(cempres,nvl(agco.cagente,z.cagente), 2, NULL)||'';''||
          z.numide||'';''||
          z.numide_aseg||'';''||
          z.npoliza||'';''||
          z.nrecibo||'';''||
          z.ncertif||'';''||
          z.fefecto||'';''||
          z.fvencim||'';''||
          z.femisio||'';''||
          To_char(ROUND(pac_corretaje.f_impcor_agente((vdr.iprinet + vdr.irecfra),agco.cagente,z.sseguro,z.nmovimi)),''999G999G999G999D99'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')||'';''||
          To_char(ROUND(pac_corretaje.f_impcor_agente(vdr.iips,agco.cagente,z.sseguro,z.nmovimi)),''999G999G999G999D99'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')||'';''||
          To_char(ROUND(pac_corretaje.f_impcor_agente(vdr.iips,agco.cagente,z.sseguro,z.nmovimi)),''999G999G999G999D99'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')||'';''||
          z.cramo||'';''||
          ROUND(z.fvencim-z.finiefe)||'';''||
          ROUND(z.fcalcul-z.finiefe)||'';''||
          (SELECT (case WHEN ROUND(z.fcalcul-z.finiefe) >= 75  THEN ''APTO''  ELSE ''NO APTO'' END) FROM DUAL)||'';''||
          ROUND(z.fvencim-z.femisio)||'';''||
          ROUND(z.fcalcul-z.femisio)||'';''||
          (SELECT (case WHEN ROUND(z.fcalcul-z.femisio) >= 75  THEN ''APTO''  ELSE ''NO APTO'' END) FROM DUAL)||'';''||
          To_char(ROUND(z.ipppc),''999G999G999G999D99'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')||'';''||
		      To_char(ROUND(z.ipppc_moncon),''999G999G999G999D99'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')||'';''||
		      To_char(ROUND(z.ipppc_coa),''999G999G999G999D99'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')||'';''||
		      To_char(ROUND(z.ipppc_moncon_coa),''999G999G999G999D99'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')
from
(
SELECT s.cempres,s.cagente,u.nmovimi,r.sseguro,r.ctipcoa,ff_descompania(pac_cuadre_adm.f_es_vida(s.sseguro)) tempres,  ff_desramo(u.cramo,8) cramo, u.cmodali,
       u.ctipseg, u.ccolect,
       pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL) delegacion,
       INITCAP(f_desagente_t(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL))) desc_delegacion,
       s.cagente agente, INITCAP(f_desagente_t(s.cagente)) desc_agente,
       s.sproduc producto,
       f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 8) desc_producto,
       s.npoliza, s.ncertif,
       p.ctipide ctipide, decode(p.ctipide, 37, substr(p.nnumide,-1)) tdigitoide,
       decode(p.ctipide, 37, substr(p.nnumide,1,length(p.nnumide)-1), p.nnumide) numide,
       f_nombre(nvl(r.sperson,t.sperson),1) pagador,
       p2.nnumide numide_aseg,
       f_nombre(nvl(a.sperson,t.sperson),1) nombre_aseg,
       u.nrecibo, SUM(nvl(u.ipppc_moncon,u.ipppc)) prim_por_c,
       0 iva_por_c, SUM(nvl(u.iderreg_moncon,u.iderreg)) gast_exp_por_c,
       0 runt_por_c, u.tedad edades,
       (select pac_adm_cobparcial.f_get_importe_cobro_parcial(u.nrecibo,null,null) from dual) vcobparc,
       r.femisio femisio, r.fefecto fefecto, r.fvencim fvencim, u.fcalcul fcalcul, u.finiefe finiefe, sum(u.iprovmora) iprovmora,nvl(r.sperson,t.sperson) sperson,
       (select sum(ipppc) from PPPC_CONF_PREVI where SPROCES = ' || cproces || ' and NRECIBO = u.nrecibo and CMETODO = 2) ipppc,
       (select sum(ipppc_moncon) from PPPC_CONF_PREVI where SPROCES = ' || cproces || ' and NRECIBO = u.nrecibo and CMETODO = 2) ipppc_moncon,
	     (select sum(ipppc_coa) from PPPC_CONF_PREVI where SPROCES = ' || cproces || ' and NRECIBO = u.nrecibo and CMETODO = 2) ipppc_coa,
	     (select sum(ipppc_moncon_coa) from PPPC_CONF_PREVI where SPROCES = ' || cproces || ' and NRECIBO = u.nrecibo and CMETODO = 2) ipppc_moncon_coa
        FROM pppc_conf u, seguros s, tomadores t, asegurados a, recibos r, empresas e, per_personas p, per_personas p2
        WHERE s.sseguro = u.sseguro
           AND u.nrecibo = r.nrecibo
           AND u.nrecibo not in(select nrecibo from exclus_provisiones where FBAJA >= (SELECT FPERFIN FROM CIERRES WHERE CEMPRES = ' || cempres || ' AND SPROCES = ' || cproces || '))
           AND u.fcalcul = TO_DATE(''' || fecha_calcul || ''', ''ddmmyyyy'')
           AND u.sproces = ' || cproces || '
           AND u.cempres = ' || cempres || '
           AND u.cerror = 0
           AND u.cempres = e.cempres
           AND r.ctiprec <> 9
           and t.sseguro = s.sseguro
           and a.sseguro(+) = s.sseguro
           and a.norden (+) = 1
           and nvl(a.sperson,t.sperson) = p2.sperson
           and p.sperson = nvl(r.sperson,t.sperson)
        GROUP BY s.cempres,s.cagente,u.nmovimi,r.sseguro,s.npoliza, u.nrecibo,
           u.cramo, u.cmodali, u.ctipseg, u.ccolect, s.sproduc,
           f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 8),
           s.ncertif,a.sperson,nvl(r.sperson,t.sperson),
           pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL),
           INITCAP(f_desagente_t(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL))),
           s.cagente, INITCAP(f_desagente_t(s.cagente)),
           u.tedad, r.femisio, r.fefecto, r.fvencim, r.sseguro, s.ctipcoa, s.sseguro
           ,r.ctipcoa, p.ctipide, p.nnumide,f_nombre(nvl(a.sperson,t.sperson),1), p2.nnumide, u.fcalcul, u.finiefe, p.tdigitoide, u.ipppc, u.ipppc_moncon, u.ipppc_coa, u.ipppc_moncon_coa
       UNION ALL
        SELECT
         s.cempres,s.cagente,u.nmovimi,r.sseguro,r.ctipcoa,ff_descompania(pac_cuadre_adm.f_es_vida(s.sseguro)) tempres, ff_desramo(u.cramo,8) cramo, u.cmodali,
         u.ctipseg, u.ccolect,
         --IPH: 35149  SUBSTR(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL),-3) delegacion,
         pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL) delegacion,
         INITCAP(f_desagente_t(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL))) desc_delegacion,
         s.cagente agente, INITCAP(f_desagente_t(s.cagente)) desc_agente,
         s.sproduc producto,
         f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 8) desc_producto,
         s.npoliza, s.ncertif,
         p.ctipide ctipide, decode(p.ctipide, 37, substr(p.nnumide,-1)) tdigitoide,
         decode(p.ctipide, 37, substr(p.nnumide,1,length(p.nnumide)-1), p.nnumide) numide,
         f_nombre(nvl(r.sperson,t.sperson),1) pagador, p2.nnumide numide_aseg, f_nombre(nvl(a.sperson,t.sperson),1) nombre_aseg,
         u.nrecibo, SUM(nvl(u.ipppc_moncon,u.ipppc)) prim_por_c,
         0 iva_por_c, SUM(nvl(u.iderreg_moncon,u.iderreg)) gast_exp_por_c,
         0 runt_por_c, u.tedad edades,
         (select pac_adm_cobparcial.f_get_importe_cobro_parcial(u.nrecibo,null,null) from dual) vcobparc,
         r.femisio, r.fefecto, r.fvencim, u.fcalcul, u.finiefe, sum(u.iprovmora),nvl(r.sperson,t.sperson) sperson,
         (select sum(ipppc) from PPPC_CONF_PREVI where SPROCES = ' || cproces || ' and NRECIBO = u.nrecibo and CMETODO = 2) ipppc,
		     (select sum(ipppc_moncon) from PPPC_CONF_PREVI where SPROCES = ' || cproces || ' and NRECIBO = u.nrecibo and CMETODO = 2) ipppc_moncon,
         (select sum(ipppc_coa) from PPPC_CONF_PREVI where SPROCES = ' || cproces || ' and NRECIBO = u.nrecibo and CMETODO = 2) ipppc_coa,
		     (select sum(ipppc_moncon_coa) from PPPC_CONF_PREVI where SPROCES = ' || cproces || ' and NRECIBO = u.nrecibo and CMETODO = 2) ipppc_moncon_coa
        FROM pppc_conf_previ u, seguros s, recibos r, tomadores t,asegurados a, empresas e, per_personas p, per_personas p2
        WHERE s.sseguro = u.sseguro
           AND u.nrecibo = r.nrecibo
           AND u.nrecibo not in(select nrecibo from exclus_provisiones where FBAJA >= (SELECT FPERFIN FROM CIERRES WHERE CEMPRES = ' || cempres || ' AND SPROCES = ' || cproces || '))
                      AND u.fcalcul = TO_DATE(''' || fecha_calcul || ''', ''ddmmyyyy'')
           AND u.sproces = ' || cproces || '
           AND u.cempres = ' || cempres || '
           AND u.cerror = 0
           AND u.cempres = e.cempres
           AND r.ctiprec <> 9
           and t.sseguro = s.sseguro
           and a.sseguro(+) = s.sseguro
           and a.norden (+) = 1
           and nvl(a.sperson,t.sperson) = p2.sperson
           and p.sperson = nvl(r.sperson,t.sperson)
        GROUP BY s.cempres,s.cagente,u.nmovimi,r.sseguro,s.npoliza, u.nrecibo,
           u.cramo, u.cmodali, u.ctipseg, u.ccolect, s.sproduc,
           f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 8),
           s.ncertif,a.sperson,nvl(r.sperson,t.sperson),
           pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL),
           INITCAP(f_desagente_t(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL))),
           s.cagente, INITCAP(f_desagente_t(s.cagente)),
           u.tedad, r.femisio, r.fefecto, r.fvencim, r.sseguro, s.ctipcoa, s.sseguro,r.ctipcoa, p.ctipide, p.nnumide, p2.nnumide,
           f_nombre(nvl(a.sperson,t.sperson),1), u.fcalcul, u.finiefe, p.tdigitoide, u.ipppc, u.ipppc_moncon, u.ipppc_coa, u.ipppc_moncon_coa)z,
    vdetrecibos vdr,
    age_corretaje agco,
    (select nvl(f_usu_idioma,2) v_idioma from dual) x,
    (select sseguro, nmovimi, min(ctipben) ctipben from benespseg group by sseguro, nmovimi) b ,
     agentes_comp a
where vdr.nrecibo = z.nrecibo
and vdr.IPRINET > 0
and agco.sseguro(+) = z.sseguro
and nvl(agco.nmovimi,-1) =  (select nvl(max(x.nmovimi),-1) from age_corretaje x where x.sseguro = z.sseguro and x.nmovimi <= z.nmovimi)
and b.sseguro (+) = z.sseguro
and b.nmovimi (+) = z.nmovimi
and a.cagente = nvl(agco.cagente,z.cagente)';
      RETURN v_ttexto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_664_det;



   /******************************************************************************************
     Descripci¿: f_664_det Detalle del map 664
     return:     texto cabecera
   ******************************************************************************************/
   FUNCTION f_664_det_copia(fecha_calcul IN VARCHAR2, cproces IN VARCHAR2, cempres IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_conf.f_664_det';
      v_tparam       VARCHAR2(1000);
      v_ntraza       NUMBER := 0;
      v_sep          VARCHAR2(1) := ';';
      v_ret          VARCHAR2(1) := CHR(10);
      v_init         VARCHAR2(32000);
      v_ttexto       VARCHAR2(32000);
      v_pparcial     VARCHAR2(32000);
   BEGIN
      --IPH --bug 35149 nota 0205275 --se elimina substr para el cagente, se incluye outer join en bloque principal
      --entre seguros y asegurados(+)
      --KJSC BUG 35149_223596 El cliente espera ver el valor de la prima pendiente (se le ha de sacar el importe del pago parcial en caso de que tenga).
      v_pparcial :=
               '(1 - pac_adm_cobparcial.f_get_porcentaje_cobro_parcial(z.nrecibo, NULL,NULL))';
      --pac_corretaje.f_impcor_agente(vdr.iprinet + vdr.irecfra,agco.cagente,z.sseguro,z.nmovimi)|| '';'' || -- pneta, anterior
      v_ttexto :=
         'select
         ff_desagente(pac_redcomercial.f_busca_padre(cempres, nvl(agco.cagente,z.cagente), 1, NULL))|| '';'' ||
         --IPH 35149 SUBSTR(pac_redcomercial.f_busca_padre(cempres,nvl(agco.cagente,z.cagente), 2, NULL),-3)|| '';'' ||
         pac_redcomercial.f_busca_padre(cempres,nvl(agco.cagente,z.cagente), 2, NULL)|| '';'' ||
         ff_desagente(pac_redcomercial.f_busca_padre(cempres, nvl(agco.cagente,z.cagente), 2, NULL))|| '';'' ||
         nvl(agco.cagente,z.cagente)|| '';'' ||
         ff_desagente(nvl(agco.cagente,z.cagente))|| '';'' ||
       z.cramo|| '';'' ||z.producto|| '';'' ||z.desc_producto|| '';'' ||
 ff_desvalorfijo(672,x.v_idioma,z.ctipide) || '';'' || z.numide || '';'' || z.tdigitoide || '';'' || z.pagador|| '';'' ||
z.numide_aseg || '';'' ||z.nombre_aseg
|| '';'' ||z.npoliza|| '';'' ||z.ncertif|| '';'' ||z.nrecibo|| '';'' ||z.femisio|| '';'' ||z.fefecto|| '';'' ||z.fvencim|| '';''||
pac_corretaje.f_impcor_agente((vdr.iprinet + vdr.irecfra)*'
         || v_pparcial
         || ',agco.cagente,z.sseguro,z.nmovimi)|| '';'' || -- pneta,
pac_corretaje.f_impcor_agente(vdr.iips,agco.cagente,z.sseguro,z.nmovimi)|| '';'' || -- iva_por_c,
(z.fcalcul-z.finiefe) || '';'' ||
pac_corretaje.f_impcor_agente(z.prim_por_c,agco.cagente,z.sseguro,z.nmovimi)|| '';'' ||
z.edades|| '';'' ||
pac_corretaje.f_impcor_agente(decode(z.ctipcoa,8,vdr.iprinet,9,vdr.iprinet,0),agco.cagente,z.sseguro,z.nmovimi)|| '';'' || -- pnetacoa,
pac_corretaje.f_impcor_agente(decode(z.ctipcoa,1,vdr.icednet,2,vdr.icednet,0),agco.cagente,z.sseguro,z.nmovimi)|| '';'' || -- pcedicoa, -- 4. JGR bug.26018 - Fin
pac_corretaje.f_impcor_agente(z.vcobparc,agco.cagente,z.sseguro,z.nmovimi)|| '';'' || -- vcobparc,
pac_isqlfor.f_telefono(z.sperson)|| '';'' ||pac_isqlfor_conf.f_direccion(z.sperson,1)|| '';'' || pac_isqlfor.f_dirpais(z.sperson,1,x.v_idioma) || '';'' ||
pac_isqlfor.f_poblacion(z.sperson,1) || '';'' || pac_isqlfor.f_provincia(z.sperson,1) || '';'' ||
ff_desvalorfijo(371,x.v_idioma,a.ctipint)||'';''||nvl(agco.cagente,z.cagente)||'';''||pac_isqlfor.f_agente(nvl(agco.cagente,z.cagente))||'';''||
nvl(agco.ppartici,100)||'';''||pac_propio_conf.ff_pcomisi_pcomisi(z.sseguro, z.nrecibo, NULL)|| '';'' || ff_desvalorfijo(1053,x.v_idioma,b.ctipben)|| '';'' ||
pac_isqlfor.f_per_contactos(z.sperson,3)|| '';'' || pac_corretaje.f_impcor_agente(z.iprovmora,agco.cagente,z.sseguro,z.nmovimi)
|| '';'' || pac_corretaje.f_impcor_agente(z.imorac,agco.cagente,z.sseguro,z.nmovimi)
from
(
SELECT s.cempres,s.cagente,u.nmovimi,r.sseguro,r.ctipcoa,ff_descompania(pac_cuadre_adm.f_es_vida(s.sseguro)) tempres, ff_desramo(u.cramo,8) cramo, u.cmodali,
       u.ctipseg, u.ccolect,
       -- SUBSTR(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL),-3) delegacion,
       pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL) delegacion,
       INITCAP(f_desagente_t(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL))) desc_delegacion,
       s.cagente agente, INITCAP(f_desagente_t(s.cagente)) desc_agente,
       s.sproduc producto,
       f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 8) desc_producto,
       s.npoliza, s.ncertif,
       p.ctipide ctipide, decode(p.ctipide, 37, substr(p.nnumide,-1)) tdigitoide,
       decode(p.ctipide, 37, substr(p.nnumide,1,length(p.nnumide)-1), p.nnumide) numide,
       f_nombre(nvl(r.sperson,t.sperson),1) pagador,
       p2.nnumide numide_aseg,
       --IPH 35149--
       f_nombre(nvl(a.sperson,t.sperson),1) nombre_aseg,
       u.nrecibo, SUM(nvl(u.ipppc_moncon,u.ipppc)) prim_por_c,
       0 iva_por_c, SUM(nvl(u.iderreg_moncon,u.iderreg)) gast_exp_por_c,
       0 runt_por_c, u.tedad edades,
       (select pac_adm_cobparcial.f_get_importe_cobro_parcial(u.nrecibo,null,null) from dual) vcobparc,
       r.femisio femisio, r.fefecto fefecto, r.fvencim fvencim, u.fcalcul fcalcul, u.finiefe finiefe, sum(u.iprovmora) iprovmora,
       sum(u.iprovmora)-(select nvl(sum(iprovmora),0) from pppc_conf where nrecibo = u.nrecibo and fcalcul = (select max (fcalcul) from pppc_conf where fcalcul < u.fcalcul)) imorac, nvl(r.sperson,t.sperson) sperson
        FROM pppc_conf u, seguros s, tomadores t, asegurados a, recibos r, empresas e, per_personas p, per_personas p2
        WHERE s.sseguro = u.sseguro
           AND u.nrecibo = r.nrecibo
                      AND u.fcalcul = TO_DATE('''
         || fecha_calcul || ''', ''ddmmyyyy'')
           AND u.sproces = ' || cproces || '
           AND u.cempres = ' || cempres
         || ' AND u.cerror = 0
           AND u.cempres = e.cempres
           AND r.ctiprec <> 9
           --IPH 35149  and t.sseguro(+) = s.sseguro
           and t.sseguro = s.sseguro
           and a.sseguro(+) = s.sseguro
           and a.norden (+) = 1
           and nvl(a.sperson,t.sperson) = p2.sperson
           and p.sperson = nvl(r.sperson,t.sperson)
        GROUP BY s.cempres,s.cagente,u.nmovimi,r.sseguro,s.npoliza, u.nrecibo,
           u.cramo, u.cmodali, u.ctipseg, u.ccolect, s.sproduc,
           f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 8),
           s.ncertif,a.sperson,nvl(r.sperson,t.sperson),
           --IPH 35149 SUBSTR(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL),-3),
           pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL),
           INITCAP(f_desagente_t(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL))),
           s.cagente, INITCAP(f_desagente_t(s.cagente)),
           u.tedad, r.femisio, r.fefecto, r.fvencim, r.sseguro, s.ctipcoa, s.sseguro
           ,r.ctipcoa, p.ctipide, p.nnumide,f_nombre(nvl(a.sperson,t.sperson),1), p2.nnumide, u.fcalcul, u.finiefe, p.tdigitoide
       UNION ALL
        SELECT
         s.cempres,s.cagente,u.nmovimi,r.sseguro,r.ctipcoa,ff_descompania(pac_cuadre_adm.f_es_vida(s.sseguro)) tempres, ff_desramo(u.cramo,8) cramo, u.cmodali,
         u.ctipseg, u.ccolect,
         --IPH--35149 SUBSTR(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL),-3) delegacion,
         pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL) delegacion,
         INITCAP(f_desagente_t(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL))) desc_delegacion,
         s.cagente agente, INITCAP(f_desagente_t(s.cagente)) desc_agente,
         s.sproduc producto,
         f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 8) desc_producto,
         s.npoliza, s.ncertif,
         p.ctipide ctipide, decode(p.ctipide, 37, substr(p.nnumide,-1)) tdigitoide,
         decode(p.ctipide, 37, substr(p.nnumide,1,length(p.nnumide)-1), p.nnumide) numide,
         f_nombre(nvl(r.sperson,t.sperson),1) pagador, p2.nnumide numide_aseg, f_nombre(nvl(a.sperson,t.sperson),1) nombre_aseg,
         u.nrecibo, SUM(nvl(u.ipppc_moncon,u.ipppc)) prim_por_c,
         0 iva_por_c, SUM(nvl(u.iderreg_moncon,u.iderreg)) gast_exp_por_c,
         0 runt_por_c, u.tedad edades,
         (select pac_adm_cobparcial.f_get_importe_cobro_parcial(u.nrecibo,null,null) from dual) vcobparc,
         r.femisio, r.fefecto, r.fvencim, u.fcalcul, u.finiefe, sum(u.iprovmora),
         sum(u.iprovmora)-(select nvl(sum(iprovmora),0) from pppc_conf where nrecibo = u.nrecibo and fcalcul = (select max (fcalcul) from pppc_conf where fcalcul < u.fcalcul)) imorac, nvl(r.sperson,t.sperson) sperson
        FROM pppc_conf_previ u, seguros s, recibos r, tomadores t,asegurados a, empresas e, per_personas p, per_personas p2
        WHERE s.sseguro = u.sseguro
           AND u.nrecibo = r.nrecibo
                      AND u.fcalcul = TO_DATE('''
         || fecha_calcul || ''', ''ddmmyyyy'')
           AND u.sproces = ' || cproces || '
           AND u.cempres = ' || cempres
         || ' AND u.cerror = 0
           AND u.cempres = e.cempres
           AND r.ctiprec <> 9
           --IPH 35149   and t.sseguro = s.sseguro
           and t.sseguro = s.sseguro
           and a.sseguro(+) = s.sseguro
           and a.norden (+) = 1
           and nvl(a.sperson,t.sperson) = p2.sperson
           and p.sperson = nvl(r.sperson,t.sperson)
        GROUP BY s.cempres,s.cagente,u.nmovimi,r.sseguro,s.npoliza, u.nrecibo,
           u.cramo, u.cmodali, u.ctipseg, u.ccolect, s.sproduc,
           f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 8),
           s.ncertif,a.sperson,nvl(r.sperson,t.sperson),
           --IPH 35149  SUBSTR(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL),-3),
           pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL),
           INITCAP(f_desagente_t(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL))),
           s.cagente, INITCAP(f_desagente_t(s.cagente)),
           u.tedad, r.femisio, r.fefecto, r.fvencim, r.sseguro, s.ctipcoa, s.sseguro
           ,r.ctipcoa, p.ctipide, p.nnumide, p2.nnumide, f_nombre(nvl(a.sperson,t.sperson),1),u.fcalcul, u.finiefe, p.tdigitoide
       UNION ALL
           SELECT s.cempres,s.cagente,u.nmovimi,r.sseguro,r.ctipcoa,ff_descompania(pac_cuadre_adm.f_es_vida(s.sseguro)) tempres, ff_desramo(u.cramo,8) cramo, u.cmodali,
       u.ctipseg, u.ccolect,
       --IPH 35149 SUBSTR(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL),-3) delegacion,
       pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL) delegacion,
       INITCAP(f_desagente_t(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL))) desc_delegacion,
       s.cagente agente, INITCAP(f_desagente_t(s.cagente)) desc_agente,
       s.sproduc producto,
       f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 8) desc_producto,
       s.npoliza, s.ncertif,
       p.ctipide ctipide, decode(p.ctipide, 37, substr(p.nnumide,-1)) tdigitoide,
       decode(p.ctipide, 37, substr(p.nnumide,1,length(p.nnumide)-1), p.nnumide) numide,
       f_nombre(nvl(r.sperson,t.sperson),1) pagador,
       p2.nnumide numide_aseg,
       f_nombre(nvl(a.sperson,t.sperson),1) nombre_aseg,
       u.nrecibo, 0-SUM(nvl(u.ipppc_moncon,u.ipppc)) prim_por_c,
       0 iva_por_c, 0 gast_exp_por_c, -- SUM(nvl(u.iderreg_moncon,u.iderreg))
       0 runt_por_c, u.tedad edades,
       0 vcobparc,--(select pac_adm_cobparcial.f_get_importe_cobro_parcial(u.nrecibo,null,null) from dual)
       r.femisio femisio, r.fefecto fefecto, r.fvencim fvencim, TO_DATE('''
         || fecha_calcul
         || ''', ''ddmmyyyy'') fcalcul, u.finiefe finiefe, 0 iprovmora,
       0-sum(u.iprovmora) imorac, nvl(r.sperson,t.sperson) sperson
        FROM pppc_conf u, seguros s, tomadores t, asegurados a, recibos r, empresas e, per_personas p, per_personas p2
        WHERE s.sseguro = u.sseguro
           AND u.nrecibo = r.nrecibo
           AND u.fcalcul < TO_DATE('''
         || fecha_calcul
         || ''',''ddmmyyyy'')
             AND u.sproces = (select max(sproces) from pppc_conf where sproces < '
         || cproces
         || ')
           and r.nrecibo = (select nrecibo from movrecibo where fmovfin is null and cestrec = 1 and nrecibo = u.nrecibo and to_char(fmovini,''mmrrrr'')=substr('
         || fecha_calcul || ',3,6)  )
               AND u.cempres = ' || cempres
         || '  AND u.cerror = 0
               AND u.cempres = e.cempres
               AND r.ctiprec <> 9
               --IPH 35149   and t.sseguro(+) = s.sseguro
               and t.sseguro = s.sseguro
               and a.sseguro(+) = s.sseguro
               and a.norden (+) = 1
               and nvl(a.sperson,t.sperson) = p2.sperson
               and p.sperson = nvl(r.sperson,t.sperson)
            GROUP BY s.cempres,s.cagente,u.nmovimi,r.sseguro,s.npoliza, u.nrecibo,
               u.cramo, u.cmodali, u.ctipseg, u.ccolect, s.sproduc,
               f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 8),
               s.ncertif,a.sperson,nvl(r.sperson,t.sperson),
              --IPH 35149 SUBSTR(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL),-3),
               pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL),
               INITCAP(f_desagente_t(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL))),
               s.cagente, INITCAP(f_desagente_t(s.cagente)),
               u.tedad, r.femisio, r.fefecto, r.fvencim, r.sseguro, s.ctipcoa, s.sseguro
               ,r.ctipcoa, p.ctipide, p.nnumide, p2.nnumide,f_nombre(nvl(a.sperson,t.sperson),1), u.fcalcul, u.finiefe, p.tdigitoide
)z, vdetrecibos vdr, age_corretaje agco, (select nvl(f_usu_idioma,2) v_idioma from dual) x,
 (select sseguro, nmovimi, min(ctipben) ctipben from benespseg group by sseguro, nmovimi) b, agentes_comp a
where vdr.nrecibo = z.nrecibo
and b.sseguro (+) = z.sseguro
and b.nmovimi (+) = z.nmovimi
and agco.sseguro(+) = z.sseguro
and a.cagente = nvl(agco.cagente,z.cagente)
and nvl(agco.nmovimi,-1) =  (select nvl(max(x.nmovimi),-1) from age_corretaje x where x.sseguro = z.sseguro and x.nmovimi <= z.nmovimi)';
      RETURN v_ttexto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_664_det_copia;



    /******************************************************************************************
     Descripci¿: f_663_det Detalle del map 663
     return:     texto cabecera
   ******************************************************************************************/
   FUNCTION f_663_det(fecha_calcul IN VARCHAR2, cproces IN VARCHAR2, cempres IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_conf.f_663_det';
      v_tparam       VARCHAR2(1000);
      v_ntraza       NUMBER := 0;
      v_sep          VARCHAR2(1) := ';';
      v_ret          VARCHAR2(1) := CHR(10);
      v_init         VARCHAR2(32000);
      v_ttexto       VARCHAR2(32000);
      v_pparcial     VARCHAR2(32000);
   BEGIN
      --IPH --bug 35149 nota 0205275 --se elimina substr para el cagente, se incluye outer join en bloque principal
      --entre seguros y asegurados(+)

      --KJSC BUG 35149_223596 El cliente espera ver el valor de la prima pendiente (se le ha de sacar el importe del pago parcial en caso de que tenga).
      v_pparcial :=
               '(1 - pac_adm_cobparcial.f_get_porcentaje_cobro_parcial(z.nrecibo, NULL,NULL))';
      --pac_corretaje.f_impcor_agente(vdr.iprinet + vdr.irecfra,agco.cagente,z.sseguro,z.nmovimi)|| '';'' || -- pneta, anterior
      v_ttexto :=
         'select
          pac_redcomercial.f_busca_padre(cempres,nvl(agco.cagente,z.cagente), 2, NULL)||'';''||
          z.npoliza||'';''||
          z.ncertif||'';''||
          z.nrecibo||'';''||
          To_char(ROUND((SELECT  pac_corretaje.f_impcor_agente((vdr.iprinet + vdr.irecfra),agco.cagente,z.sseguro,z.nmovimi) * SUM(PCESCOA)/100 FROM SEGUROS S,COACEDIDO C WHERE S.SSEGURO=z.sseguro AND S.SSEGURO=C.SSEGURO AND S.CTIPCOA=1)),''999G999G999G999D99'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')||'';''||
          To_char(ROUND((SELECT  pac_corretaje.f_impcor_agente((vdr.iprinet + vdr.irecfra),agco.cagente,z.sseguro,z.nmovimi) * SUM(PCESCOA)/100 FROM SEGUROS S,COACEDIDO C WHERE S.SSEGURO=z.sseguro AND S.SSEGURO=C.SSEGURO AND S.CTIPCOA=8)),''999G999G999G999D99'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')||'';''||
          To_char(ROUND(pac_corretaje.f_impcor_agente((vdr.iprinet + vdr.irecfra),agco.cagente,z.sseguro,z.nmovimi)),''999G999G999G999D99'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')||'';''||
          null||'';''||
          To_char(ROUND(pac_corretaje.f_impcor_agente((vdr.iprinet + vdr.irecfra),agco.cagente,z.sseguro,z.nmovimi)),''999G999G999G999D99'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')||'';''||
          To_char(ROUND(pac_corretaje.f_impcor_agente(vdr.iips,agco.cagente,z.sseguro,z.nmovimi)),''999G999G999G999D99'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')||'';''||
          To_char(ROUND(pac_corretaje.f_impcor_agente(vdr.iips,agco.cagente,z.sseguro,z.nmovimi)),''999G999G999G999D99'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')||'';''||
          To_char(ROUND(((pac_corretaje.f_impcor_agente((vdr.iprinet + vdr.irecfra),agco.cagente,z.sseguro,z.nmovimi))
           + (pac_corretaje.f_impcor_agente(vdr.iips,agco.cagente,z.sseguro,z.nmovimi))
           + pac_corretaje.f_impcor_agente(vdr.iips,agco.cagente,z.sseguro,z.nmovimi))),''999G999G999G999D99'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')||'';''||
          z.producto||'';''||
          z.numide_aseg||'';''||
          (z.fcalcul-z.finiefe)||'';''||
          z.numide||'';''||
          z.ctipcoa||'';''||
          z.cramo||'';''||
          null||'';''||
          z.edades||'';''||
          z.fefecto||'';''||
          z.fvencim||'';''||
          z.femisio||'';''||
          ROUND(z.fvencim-z.finiefe)||'';''||
          ROUND(z.fcalcul-z.finiefe)||'';''||
          ROUND(z.fvencim-z.femisio)||'';''||
          ROUND(z.fcalcul-z.femisio)||'';''||
          (SELECT (case WHEN ROUND(z.fcalcul-z.finiefe) > 75  THEN ''VERDADERO''  ELSE ''FALSO'' END) FROM DUAL)||'';''||
          (SELECT (case WHEN ROUND(z.fcalcul-z.femisio) > 75  THEN ''VERDADERO''  ELSE ''FALSO'' END) FROM DUAL)||'';''||
          To_char(ROUND(z.iprovfecini),''999G999G999G999D99'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')||'';''||
          To_char(ROUND(z.iprovfecexp),''999G999G999G999D99'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')||'';''||
          To_char(ROUND(z.iprovfecini_veinte),''999G999G999G999D99'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')||'';''||
          To_char(ROUND(z.iprovfecexp_veinte),''999G999G999G999D99'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')||'';''||
          To_char(ROUND(z.iprovfecini_ochenta),''999G999G999G999D99'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')||'';''||
          To_char(ROUND(z.iprovfecexp_ochenta),''999G999G999G999D99'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')||'';''||
          To_char(ROUND(z.iprovfecoct),''999G999G999G999D99'',''NLS_NUMERIC_CHARACTERS = '''',.'''''')
from
(
SELECT s.cempres,s.cagente,u.nmovimi,r.sseguro,r.ctipcoa,ff_descompania(pac_cuadre_adm.f_es_vida(s.sseguro)) tempres,  ff_desramo(u.cramo,8) cramo, u.cmodali,
       u.ctipseg, u.ccolect,
       pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL) delegacion,
       INITCAP(f_desagente_t(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL))) desc_delegacion,
       s.cagente agente, INITCAP(f_desagente_t(s.cagente)) desc_agente,
       s.sproduc producto,
       f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 8) desc_producto,
       s.npoliza, s.ncertif,
       p.ctipide ctipide, decode(p.ctipide, 37, substr(p.nnumide,-1)) tdigitoide,
       decode(p.ctipide, 37, substr(p.nnumide,1,length(p.nnumide)-1), p.nnumide) numide,
       f_nombre(nvl(r.sperson,t.sperson),1) pagador,
       p2.nnumide numide_aseg,
       f_nombre(nvl(a.sperson,t.sperson),1) nombre_aseg,
       u.nrecibo, SUM(nvl(u.ipppc_moncon,u.ipppc)) prim_por_c,
       0 iva_por_c, SUM(nvl(u.iderreg_moncon,u.iderreg)) gast_exp_por_c,
       0 runt_por_c, u.tedad edades,
       (select pac_adm_cobparcial.f_get_importe_cobro_parcial(u.nrecibo,null,null) from dual) vcobparc,
       r.femisio femisio, r.fefecto fefecto, r.fvencim fvencim, u.fcalcul fcalcul, u.finiefe finiefe, sum(u.iprovmora) iprovmora,nvl(r.sperson,t.sperson) sperson,
       u.iprovfecini, u.iprovfecexp, u.iprovfecini_veinte, u.iprovfecexp_veinte, u.iprovfecini_ochenta, u.iprovfecexp_ochenta, u.iprovfecoct, u.itotaldoc
        FROM PPPC_CONF_OCT_PREVI u, seguros s, tomadores t, asegurados a, recibos r, empresas e, per_personas p, per_personas p2
        WHERE s.sseguro = u.sseguro
           AND u.nrecibo = r.nrecibo
           AND u.nrecibo not in(select nrecibo from exclus_provisiones where FBAJA >= (SELECT FPERFIN FROM CIERRES WHERE CEMPRES = ' || cempres || ' AND SPROCES = ' || cproces || '))
           AND u.fcalcul = TO_DATE(''' || fecha_calcul || ''', ''ddmmyyyy'')
           AND u.sproces = ' || cproces || '
           AND u.cempres = ' || cempres || '
           AND u.cerror = 0
           AND u.cempres = e.cempres
           AND r.ctiprec <> 9
           and t.sseguro = s.sseguro
           and a.sseguro(+) = s.sseguro
           and a.norden (+) = 1
           and nvl(a.sperson,t.sperson) = p2.sperson
           and p.sperson = nvl(r.sperson,t.sperson)
        GROUP BY s.cempres,s.cagente,u.nmovimi,r.sseguro,s.npoliza, u.nrecibo,
           u.cramo, u.cmodali, u.ctipseg, u.ccolect, s.sproduc,
           f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 8),
           s.ncertif,a.sperson,nvl(r.sperson,t.sperson),
           pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL),
           INITCAP(f_desagente_t(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL))),
           s.cagente, INITCAP(f_desagente_t(s.cagente)),
           u.tedad, r.femisio, r.fefecto, r.fvencim, r.sseguro, s.ctipcoa, s.sseguro
           ,r.ctipcoa, p.ctipide, p.nnumide,f_nombre(nvl(a.sperson,t.sperson),1), p2.nnumide, u.fcalcul, u.finiefe, p.tdigitoide,
           u.iprovfecini, u.iprovfecexp, u.iprovfecini_veinte, u.iprovfecexp_veinte, u.iprovfecini_ochenta, u.iprovfecexp_ochenta,
           u.iprovfecoct, u.itotaldoc
       UNION ALL
        SELECT
         s.cempres,s.cagente,u.nmovimi,r.sseguro,r.ctipcoa,ff_descompania(pac_cuadre_adm.f_es_vida(s.sseguro)) tempres, ff_desramo(u.cramo,8) cramo, u.cmodali,
         u.ctipseg, u.ccolect,
         --IPH: 35149  SUBSTR(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL),-3) delegacion,
         pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL) delegacion,
         INITCAP(f_desagente_t(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL))) desc_delegacion,
         s.cagente agente, INITCAP(f_desagente_t(s.cagente)) desc_agente,
         s.sproduc producto,
         f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 8) desc_producto,
         s.npoliza, s.ncertif,
         p.ctipide ctipide, decode(p.ctipide, 37, substr(p.nnumide,-1)) tdigitoide,
         decode(p.ctipide, 37, substr(p.nnumide,1,length(p.nnumide)-1), p.nnumide) numide,
         f_nombre(nvl(r.sperson,t.sperson),1) pagador, p2.nnumide numide_aseg, f_nombre(nvl(a.sperson,t.sperson),1) nombre_aseg,
         u.nrecibo, SUM(nvl(u.ipppc_moncon,u.ipppc)) prim_por_c,
         0 iva_por_c, SUM(nvl(u.iderreg_moncon,u.iderreg)) gast_exp_por_c,
         0 runt_por_c, u.tedad edades,
         (select pac_adm_cobparcial.f_get_importe_cobro_parcial(u.nrecibo,null,null) from dual) vcobparc,
         r.femisio, r.fefecto, r.fvencim, u.fcalcul, u.finiefe, sum(u.iprovmora),nvl(r.sperson,t.sperson) sperson,
         u.iprovfecini, u.iprovfecexp, u.iprovfecini_veinte, u.iprovfecexp_veinte, u.iprovfecini_ochenta, u.iprovfecexp_ochenta, u.iprovfecoct, u.itotaldoc
        FROM PPPC_CONF_OCT_PREVI u, seguros s, recibos r, tomadores t,asegurados a, empresas e, per_personas p, per_personas p2
        WHERE s.sseguro = u.sseguro
           AND u.nrecibo = r.nrecibo
           AND u.nrecibo not in(select nrecibo from exclus_provisiones where FBAJA >= (SELECT FPERFIN FROM CIERRES WHERE CEMPRES = ' || cempres || ' AND SPROCES = ' || cproces || '))
                      AND u.fcalcul = TO_DATE(''' || fecha_calcul || ''', ''ddmmyyyy'')
           AND u.sproces = ' || cproces || '
           AND u.cempres = ' || cempres || '
           AND u.cerror = 0
           AND u.cempres = e.cempres
           AND r.ctiprec <> 9
           and t.sseguro = s.sseguro
           and a.sseguro(+) = s.sseguro
           and a.norden (+) = 1
           and nvl(a.sperson,t.sperson) = p2.sperson
           and p.sperson = nvl(r.sperson,t.sperson)
        GROUP BY s.cempres,s.cagente,u.nmovimi,r.sseguro,s.npoliza, u.nrecibo,
           u.cramo, u.cmodali, u.ctipseg, u.ccolect, s.sproduc,
           f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 8),
           s.ncertif,a.sperson,nvl(r.sperson,t.sperson),
           pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL),
           INITCAP(f_desagente_t(pac_redcomercial.f_busca_padre(s.cempres,s.cagente, NULL, NULL))),
           s.cagente, INITCAP(f_desagente_t(s.cagente)),
           u.tedad, r.femisio, r.fefecto, r.fvencim, r.sseguro, s.ctipcoa, s.sseguro,r.ctipcoa, p.ctipide, p.nnumide, p2.nnumide,
           f_nombre(nvl(a.sperson,t.sperson),1), u.fcalcul, u.finiefe, p.tdigitoide, u.ipppc, u.ipppc_moncon, u.ipppc_coa, u.ipppc_moncon_coa,
           u.iprovfecini, u.iprovfecexp, u.iprovfecini_veinte, u.iprovfecexp_veinte, u.iprovfecini_ochenta, u.iprovfecexp_ochenta, u.iprovfecoct, u.itotaldoc)z,
    vdetrecibos vdr,
    age_corretaje agco,
    (select nvl(f_usu_idioma,2) v_idioma from dual) x,
    (select sseguro, nmovimi, min(ctipben) ctipben from benespseg group by sseguro, nmovimi) b ,
     agentes_comp a
where vdr.nrecibo = z.nrecibo
and agco.sseguro(+) = z.sseguro
and nvl(agco.nmovimi,-1) =  (select nvl(max(x.nmovimi),-1) from age_corretaje x where x.sseguro = z.sseguro and x.nmovimi <= z.nmovimi)
and b.sseguro (+) = z.sseguro
and b.nmovimi (+) = z.nmovimi
and a.cagente = nvl(agco.cagente,z.cagente)';
      RETURN v_ttexto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_663_det;


   /******************************************************************************************
     Descripci¿: f_perini_cab_det del map 663
     return:     texto cabecera
   ******************************************************************************************/
   FUNCTION f_perini_cab_det(fecha_calcul IN VARCHAR2, cproces IN VARCHAR2, cempres IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_conf.f_perini_cab_det';
      v_tparam       VARCHAR2(1000);
      v_ntraza       NUMBER := 0;
      v_sep          VARCHAR2(1) := ';';
      v_ret          VARCHAR2(1) := CHR(10);
      v_init         VARCHAR2(32000);
      v_ttexto       VARCHAR2(32000);
      v_pparcial     VARCHAR2(32000);
   BEGIN
      --IPH --bug 35149 nota 0205275 --se elimina substr para el cagente, se incluye outer join en bloque principal
      --entre seguros y asegurados(+)

      --KJSC BUG 35149_223596 El cliente espera ver el valor de la prima pendiente (se le ha de sacar el importe del pago parcial en caso de que tenga).
      v_pparcial :=
               '(1 - pac_adm_cobparcial.f_get_porcentaje_cobro_parcial(z.nrecibo, NULL,NULL))';
      --pac_corretaje.f_impcor_agente(vdr.iprinet + vdr.irecfra,agco.cagente,z.sseguro,z.nmovimi)|| '';'' || -- pneta, anterior

            SELECT FPERINI
              INTO v_ttexto
              FROM CIERRES
             WHERE CEMPRES = cempres AND SPROCES = cproces;

      RETURN v_ttexto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_perini_cab_det;

   /******************************************************************************************
     Descripci¿: f_perfin_cab_det del map 663
     return:     texto cabecera
   ******************************************************************************************/
   FUNCTION f_perfin_cab_det(fecha_calcul IN VARCHAR2, cproces IN VARCHAR2, cempres IN VARCHAR2)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_conf.f_perfin_cab_det';
      v_tparam       VARCHAR2(1000);
      v_ntraza       NUMBER := 0;
      v_sep          VARCHAR2(1) := ';';
      v_ret          VARCHAR2(1) := CHR(10);
      v_init         VARCHAR2(32000);
      v_ttexto       VARCHAR2(32000);
      v_pparcial     VARCHAR2(32000);
   BEGIN
      --IPH --bug 35149 nota 0205275 --se elimina substr para el cagente, se incluye outer join en bloque principal
      --entre seguros y asegurados(+)

      --KJSC BUG 35149_223596 El cliente espera ver el valor de la prima pendiente (se le ha de sacar el importe del pago parcial en caso de que tenga).
      v_pparcial :=
               '(1 - pac_adm_cobparcial.f_get_porcentaje_cobro_parcial(z.nrecibo, NULL,NULL))';
      --pac_corretaje.f_impcor_agente(vdr.iprinet + vdr.irecfra,agco.cagente,z.sseguro,z.nmovimi)|| '';'' || -- pneta, anterior

            SELECT FPERFIN
              INTO v_ttexto
              FROM CIERRES
             WHERE CEMPRES = cempres AND SPROCES = cproces;

      RETURN v_ttexto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_perfin_cab_det;


-- 2.0025615: CONFPG100-(CONFPG100)-Parametrizacion- Administracion y Finanzas- Parametrizacion Cierres - Fin
--BUG 24933 -- 18/04/2013--ETM --INI
-- BUG 0025623 - 02/05/2013 - JMF: afegir pperage
 /******************************************************************************************
       Descripci¿: Funci¿n que genera el texto cabecera para el Listado de Recibos segun situacion
       Par¿metres entrada:    - p_cidioma     -> codigo idioma
                              - p_cempres     -> codigo empresa
                              - p_cestrec     -> esstado de recibo
                              - p_fdesde       ->  fecha ini
                              - p_fhasta     -> fecha fin
                              - p_ctiprec     -> tipo de recibo
                              - p_cagente      -> codigo agente
                              - p_cestado      -> estado
                              - p_filtro    -> tipo filtro
                              - p_ccompani     -> codigo de compa¿ia
                              - p_perage       -> sperson del agente


       return:             texto cabecera
   'IDIOMA|EMPRESA|CESTREC|FDESDE|FHASTA|CTIPREC|AGENTE|CESTADO|FILTRO|CCOMPANI ',

     ******************************************************************************************/
   FUNCTION f_list733_cab(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_cestrec IN NUMBER DEFAULT NULL,
      p_fdesde IN VARCHAR2 DEFAULT NULL,
      p_fhasta IN VARCHAR2 DEFAULT NULL,
      p_ctiprec IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL,
      p_cestado IN NUMBER DEFAULT NULL,
      p_filtro IN NUMBER DEFAULT NULL,
      p_ccompani IN NUMBER DEFAULT NULL,
      p_perage IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_CONF.f_list733_cab';
      v_tparam       VARCHAR2(1000)
         := ' idioma=' || p_cidioma || ' empresa=' || p_cempres || ' cestrec=' || p_cestrec
            || ' fdesde=' || p_fdesde || ' p_fhasta=' || p_fhasta || ' p_ctiprec= '
            || p_ctiprec || ' p_cagente=' || p_cagente || ' p_cestado=' || p_cestado
            || ' filtro=' || p_filtro || ' p_ccompani=' || p_ccompani || ' perage='
            || p_perage;
      v_ntraza       NUMBER := 0;
      v_idioma       NUMBER;
      v_txt          VARCHAR2(32000);
   BEGIN
      v_ntraza := 1130;
      v_txt := NULL;
      v_txt :=
         ' SELECT '' '' || f_axis_literales(9001875, x.v_idioma) ||'';''
               || f_axis_literales(101168, x.v_idioma) ||'';''
               || f_axis_literales(100883, x.v_idioma) || '' ''
               || f_axis_literales(9001875, x.v_idioma) ||'';''
               || f_axis_literales(109716, x.v_idioma) || '';''
               || f_axis_literales(103313, x.v_idioma) || '';''
               || f_axis_literales(101516, x.v_idioma) || '';''
               || f_axis_literales(101619, x.v_idioma) || '';''
               || f_axis_literales(100895, x.v_idioma) || '';''
               || f_axis_literales(100584, x.v_idioma) || '';''
               || f_axis_literales(100883, x.v_idioma) || '' ''
               || f_axis_literales(100895, x.v_idioma) || '';''
               || f_axis_literales(1000562, x.v_idioma) || '' ''
               || f_axis_literales(100895, x.v_idioma) || '';''
               || f_axis_literales(100885, x.v_idioma) || '' ''
               || f_axis_literales(100895, x.v_idioma) || '';''
               || f_axis_literales(102302, x.v_idioma) || '';''
               || f_axis_literales(100874, x.v_idioma) || '' ''
               || f_axis_literales(9001875, x.v_idioma) || '';''
               || f_axis_literales(1000553, x.v_idioma) ||'';'' ';   --estado recibo

      IF NVL(pac_parametros.f_parlistado_n(p_cempres, 'PRIMADEV_344'), 0) = 1 THEN
         v_txt := v_txt || '|| f_axis_literales(9904028, x.v_idioma) || '';'' ';
      END IF;

      v_txt :=
         v_txt
         || '|| f_axis_literales(100784, x.v_idioma) || '';''   --ramo
               || f_axis_literales(9002202, x.v_idioma) || '';''  --sucursal
               || f_axis_literales(9904541, x.v_idioma) || '';''   --regional
               || f_axis_literales(109360, x.v_idioma) || '';''   --tomador
               || f_axis_literales(100577, x.v_idioma) || '';''   --nnumide
               || f_axis_literales(100829, x.v_idioma) || '';''   --producto
               || f_axis_literales(105830, x.v_idioma) || '';''   --prima emitida
               || f_axis_literales(101340, x.v_idioma) || '';''   --iva
               || f_axis_literales(108480, x.v_idioma) || '';''   --gastos
               || f_axis_literales(9903807, x.v_idioma) || '';''   --descuentos
               || f_axis_literales(102995, x.v_idioma) || '';''   --prima neta
               || f_axis_literales(9902731, x.v_idioma) || '';''   --prima recaudada
               || f_axis_literales(9905359, x.v_idioma) || '';''   --Diferencia/Saldo en cartera
               || f_axis_literales(101573, x.v_idioma) || '';''   --Fecha de pago
               || f_axis_literales(9905358, x.v_idioma) || '';''   --dias de cartera
               || f_axis_literales(9905357, x.v_idioma) || '';''   --antig¿edad de cartera
               || f_axis_literales(105387, x.v_idioma) || '';''   --coaseguro
               || f_axis_literales(9905356, x.v_idioma) || '';''   --valor coaseguro
               || f_axis_literales(100956, x.v_idioma) || '';'' || '' '' linea
            from   (select nvl(f_usu_idioma,2) v_idioma from dual) x,
       dual ';
      v_ntraza := 1130;

      IF v_txt IS NULL THEN
         v_txt := 'select 0 from dual';
      END IF;

      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_list733_cab;

   FUNCTION f_list733_det(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_cestrec IN NUMBER DEFAULT NULL,
      p_fdesde IN VARCHAR2 DEFAULT NULL,
      p_fhasta IN VARCHAR2 DEFAULT NULL,
      p_ctiprec IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL,
      p_cestado IN NUMBER DEFAULT NULL,
      p_filtro IN NUMBER DEFAULT NULL,
      p_ccompani IN NUMBER DEFAULT NULL,
      p_perage IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_CONF.f_list733_det';
      v_tparam       VARCHAR2(1000)
         := ' idioma=' || p_cidioma || ' empresa=' || p_cempres || ' cestrec=' || p_cestrec
            || ' fdesde=' || p_fdesde || ' p_fhasta=' || p_fhasta || ' p_ctiprec= '
            || p_ctiprec || ' p_cagente=' || p_cagente || ' p_cestado=' || p_cestado
            || ' filtro=' || p_filtro || ' p_ccompani=' || p_ccompani || ' perage='
            || p_perage;
      v_ntraza       NUMBER := 0;
      v_idioma       NUMBER;
      v_sperson_aseg NUMBER;
      v_sep          VARCHAR2(1) := ';';
      v_sep2         VARCHAR2(9) := '||' || CHR(39) || ';' || CHR(39) || '||';
      v_fdesde       VARCHAR2(10);
      v_fhasta       VARCHAR2(10);
      v_sep3         VARCHAR2(9) := '||' || CHR(39) || ';' || CHR(39);
      v_cagente2     VARCHAR2(100);
   BEGIN
      v_ntraza := 1040;
      v_fdesde := LPAD(p_fdesde, 8, '0');
      v_fhasta := LPAD(p_fhasta, 8, '0');

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      -- ini BUG 0025623 - 02/05/2013 - JMF
      IF p_perage IS NOT NULL THEN
         -- Buscar los agentes a partir de la persona
         v_cagente2 := ' rc.cagente in (select cagente from agentes where sperson='
                       || p_perage || ')';
      ELSIF p_cagente IS NOT NULL THEN
         -- Buscar un agente concreto
         v_cagente2 := ' rc.cagente=' || CHR(39) || p_cagente || CHR(39);
      ELSE
         -- Resto de casos
         v_cagente2 := ' rc.cagente=ff_agente_cpolvisio(pac_user.ff_get_cagente(f_user))';
      END IF;

      -- fin BUG 0025623 - 02/05/2013 - JMF
      v_txt := NULL;
--   ' || v_idioma || '
      v_txt :=
         v_txt || 'SELECT se.npoliza ' || v_sep2 || ' se.ncertif ' || v_sep2 || ' se.fefecto '
         || v_sep2 || ' se.fcarpro ' || v_sep2 || ' ff_desvalorfijo(17, ' || v_idioma
         || ', se.cforpag) ' || v_sep2 || ' ff_desvalorfijo(1026, ' || v_idioma
         || ', NVL(re.ctipcob, 2)) ' || v_sep2 || ' e.tempres ' || v_sep2 || ' re.nrecibo '
         || v_sep2 || ' ff_desagente(re.cagente) ' || v_sep2 || ' re.fefecto ' || v_sep2
         --INI RAL BUG 37852: CONF ADM Listado de Administraci¿n - Recibos por Estado Actual
            --|| ' re.femisio ' || v_sep2
         || '(SELECT FMOVDIA FROM MOVRECIBO WHERE NRECIBO = re.nrecibo AND cestrec=0 AND cestant=0)'
         || v_sep2
                  --FIN RAL BUG 37852: CONF ADM Listado de Administraci¿n - Recibos por Estado Actual
         || ' re.fvencim ' || v_sep2 || ' ff_desvalorfijo(8, ' || v_idioma || ', re.ctiprec) '
         || v_sep2 || ' ff_desvalorfijo(61, ' || v_idioma || ', se.csituac) ' || v_sep2
         || ' ff_desvalorfijo(1, ' || v_idioma || ', f_cestrec(re.nrecibo, f_sysdate)) '
         || v_sep2;

      IF NVL(pac_parametros.f_parlistado_n(p_cempres, 'PRIMADEV_344'), 0) = 1 THEN
         v_txt := v_txt || ' v.ipridev ' || v_sep2;
      END IF;

      v_txt :=
         v_txt || ' pac_isqlfor.f_ramo(se.cramo, ' || v_idioma || ') ' || v_sep2
         || ' pac_redcomercial.f_busca_padre(' || CHR(39) || p_cempres || CHR(39)
         || ', se.cagente, NULL, NULL) ' || v_sep2 || '  pac_redcomercial.f_busca_padre('
         || CHR(39) || p_cempres || CHR(39) || ', se.cagente, 1, NULL) ' || v_sep2
         || ' f_nombre(t.sperson, 1, NULL) ' || v_sep2
         || ' pac_isqlfor.f_dades_persona(t.sperson, 1, ' || v_idioma || ') ' || v_sep2
         || ' f_desproducto_t(se.cramo, se.cmodali, se.ctipseg, se.ccolect, 1, ' || v_idioma
         || ') ' || v_sep2 || ' v.itotalr ' || v_sep2 || ' v.iips ' || v_sep2 || ' v.iderreg  '
         || v_sep2 || ' v.itotdto ' || v_sep2 || ' nvl(v.iprinet,0) ' || v_sep2
         || ' nvl(DECODE(pac_adm_cobparcial.f_get_importe_cobro_parcial(v.nrecibo),0, (SELECT DECODE(COUNT(*), 0, 0, nvl(v.itotalr,0)) '
         || ' FROM movrecibo ' || ' WHERE cestrec = 1 ' || ' AND fmovfin IS NULL '
         || ' AND nrecibo = re.nrecibo), '
         || ' nvl(pac_adm_cobparcial.f_get_importe_cobro_parcial(re.nrecibo),0)),0) ' || v_sep2
         || ' ( nvl(v.itotalr,0)  - nvl(DECODE(pac_adm_cobparcial.f_get_importe_cobro_parcial(v.nrecibo),0, (SELECT DECODE(COUNT(*), 0, 0, nvl(v.itotalr,0)) '
         || ' FROM movrecibo ' || ' WHERE cestrec = 1 ' || ' AND fmovfin IS NULL '
         || ' AND nrecibo = re.nrecibo), '
         || ' nvl(pac_adm_cobparcial.f_get_importe_cobro_parcial(re.nrecibo),0)),0) ) '
         || v_sep2 || ' ( SELECT TO_CHAR(fmovini,''dd/mm/yyyy'') ' || ' FROM movrecibo '
         || ' WHERE cestrec = 1 ' || ' AND fmovfin IS NULL ' || ' AND nrecibo = re.nrecibo) '
         || v_sep2 || ' pac_devolu.f_numdias_periodo_gracia(re.sseguro)' || v_sep2
         || ' round((f_sysdate - re.fefecto),0) ' || v_sep2 || ' ff_desvalorfijo(800109,'
         || v_idioma || ', NVL(re.ctipcoa, 0)) ' || v_sep2 || ' v.icednet ' || v_sep2
         || ' (SELECT DECODE(NVL(p.creaseg, 0), 0, ''No'', ''Si'') ' || ' FROM productos p '
         || ' WHERE p.sproduc = se.sproduc) ' || v_sep3 || ' linea '
         || ' FROM seguros se, agentes_agente a, recibos re, movrecibo m, tomadores t, '
         || ' (SELECT nrecibo, ipridev, itotalr, icednet,icedpdv, iips, (iderreg+icedrfr) iderreg, itotdto, iprinet '
         || ' FROM vdetrecibos ' || ' WHERE NVL(pac_parametros.f_parempresa_n(' || CHR(39)
         || p_cempres || CHR(39) || ', ''MULTIMONEDA''), 0) = 0 ' || ' UNION '
         || ' SELECT nrecibo, ipridev, itotalr, icednet,icedpdv, iips, (iderreg+icedrfr) iderreg , itotdto, iprinet '
         || ' FROM vdetrecibos_monpol ' || ' WHERE NVL(pac_parametros.f_parempresa_n('
         || CHR(39) || p_cempres || CHR(39) || ', ''MULTIMONEDA''), 0) = 1) v, '
         || ' empresas e ' || ' WHERE se.sseguro = re.sseguro  AND re.nrecibo = m.nrecibo '
         || ' AND v.nrecibo = m.nrecibo AND m.fmovfin IS NULL '
         || ' AND re.cagente = a.cagente AND re.cempres = a.cempres '
         || ' AND(re.cagente, re.cempres) IN( SELECT rc.cagente, rc.cempres '
         || ' FROM (SELECT     rc.cagente, rc.cempres ' || ' FROM redcomercial rc '
         || ' WHERE rc.fmovfin IS NULL ' || ' START WITH ' || v_cagente2
         || ' CONNECT BY PRIOR rc.cagente = rc.cpadre '
         || ' AND PRIOR rc.fmovfin IS NULL) rc, ' || ' agentes_agente_pol a '
         || ' WHERE rc.cagente = a.cagente) ' || ' AND re.fefecto >= NVL(TO_DATE(' || CHR(39)
         || v_fdesde || CHR(39) || ', ''ddmmrrrr''), re.fefecto) '
         || ' AND re.fefecto <= NVL(TO_DATE(' || CHR(39) || v_fhasta || CHR(39)
         || ', ''ddmmrrrr''), re.fefecto) ' || ' AND re.ctiprec = NVL(' || CHR(39) || p_ctiprec
         || CHR(39) || ', re.ctiprec)  ' || ' AND f_cestrec(re.nrecibo, f_sysdate) = NVL('
         || CHR(39) || p_cestrec || CHR(39) || ', f_cestrec(re.nrecibo, f_sysdate)) '
         || ' AND se.csituac = NVL(' || CHR(39) || p_cestado || CHR(39) || ', se.csituac) '
         || ' AND  v.itotalr <>0 ' || ' AND ( re.cempres = ' || CHR(39) || p_cempres || CHR(39)
         || ' OR' || CHR(39) || p_cempres || CHR(39) || ' IS NULL) '
         || ' AND e.cempres = re.cempres ' || ' AND re.CESTAUX<>2 '
         || ' AND se.sseguro = t.sseguro ';
      v_ntraza := 9999;

      IF v_txt IS NULL THEN
         v_txt := 'select 0 from dual';
      END IF;

      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_list733_det;

-- BUG 0025623 - 02/05/2013 - JMF: afegir pperage
    /******************************************************************************************
       Descripci¿: Funci¿n que genera el texto cabecera para el Listado de Recibos pendientes por poliza
       Par¿metres entrada:    - p_cidioma     -> codigo idioma
                              - p_cempres     -> codigo empresa
                              - p_cestrec     -> esstado de recibo
                              - p_fdesde       ->  fecha ini
                              - p_fhasta     -> fecha fin
                              - p_ctiprec     -> tipo de recibo
                              - p_cagente      -> codigo agente
                              - p_cestado      -> estado
                              - p_perage       -> sperson del agente


       return:             texto cabecera
   'IDIOMA|EMPRESA|CESTREC|FDESDE|FHASTA|CTIPREC|AGENTE|CESTADO',

     ******************************************************************************************/
   FUNCTION f_list734_cab(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_cestrec IN NUMBER DEFAULT NULL,
      p_fdesde IN VARCHAR2 DEFAULT NULL,
      p_fhasta IN VARCHAR2 DEFAULT NULL,
      p_ctiprec IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL,
      p_cestado IN NUMBER DEFAULT NULL,
      p_perage IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_CONF.f_list734_cab';
      v_tparam       VARCHAR2(1000)
         := ' idioma=' || p_cidioma || ' empresa=' || p_cempres || ' cestrec=' || p_cestrec
            || ' fdesde=' || p_fdesde || ' p_fhasta=' || p_fhasta || ' p_ctiprec= '
            || p_ctiprec || ' p_cagente=' || p_cagente || ' p_cestado=' || p_cestado
            || ' perage=' || p_perage;
      v_ntraza       NUMBER := 0;
      v_idioma       NUMBER;
      v_txt          VARCHAR2(32000);
   BEGIN
      v_ntraza := 1130;
      v_txt := NULL;
      v_txt :=
         ' SELECT '' '' || f_axis_literales(9001875, x.v_idioma) ||'';''
               || f_axis_literales(101168, x.v_idioma) ||'';''
               || f_axis_literales(100883, x.v_idioma) || '' ''
               || f_axis_literales(9001875, x.v_idioma) ||'';''
               || f_axis_literales(109716, x.v_idioma) || '';''
               || f_axis_literales(103313, x.v_idioma) || '';'' --FORMA DE PAGO
               || f_axis_literales(101619, x.v_idioma) || '';''
               || f_axis_literales(100895, x.v_idioma) || '';''
               || f_axis_literales(100584, x.v_idioma) || '';''
               || f_axis_literales(100883, x.v_idioma) || '' ''
               || f_axis_literales(100895, x.v_idioma) || '';''
               || f_axis_literales(1000562, x.v_idioma) || '' ''
               || f_axis_literales(100895, x.v_idioma) || '';''
               || f_axis_literales(100885, x.v_idioma) || '' ''
               || f_axis_literales(100895, x.v_idioma) || '';''
               || f_axis_literales(102302, x.v_idioma) || '';''
               || f_axis_literales(9000842, x.v_idioma) || '';''
              || f_axis_literales(100563, x.v_idioma) || '';''
              || f_axis_literales(1000553, x.v_idioma) ||'';''    --estado recibo
              || f_axis_literales(100874, x.v_idioma) || '' ''
              || f_axis_literales(9001875, x.v_idioma) || '';'' ';

      IF NVL(pac_parametros.f_parlistado_n(p_cempres, 'VER_FECHACOB_ENMAPS'), 0) = 1 THEN
         v_txt :=
            v_txt
            || '|| f_axis_literales(9000805, x.v_idioma) || '' ''  || f_axis_literales(100895, x.v_idioma) || '';'' ';
      END IF;

      v_txt :=
         v_txt
         || '|| f_axis_literales(100784, x.v_idioma) || '';''   --ramo
               || f_axis_literales(9002202, x.v_idioma) || '';''  --sucursal
               || f_axis_literales(9904541, x.v_idioma) || '';''   --regional
               || f_axis_literales(109360, x.v_idioma) || '';''   --tomador
               || f_axis_literales(105830, x.v_idioma) || '';''   --prima emitida
               || f_axis_literales(101340, x.v_idioma) || '';''   --iva
               || f_axis_literales(108480, x.v_idioma) || '';''   --gastos
               || f_axis_literales(9903807, x.v_idioma) || '';''   --descuentos
               || f_axis_literales(102995, x.v_idioma) || '';''   --prima neta
               || f_axis_literales(9902731, x.v_idioma) || '';''   --prima recaudada
               || f_axis_literales(9905359, x.v_idioma) || '';''   --Diferencia/Saldo en cartera
               || f_axis_literales(101573, x.v_idioma) || '';''   --Fecha de pago
               || f_axis_literales(9902444, x.v_idioma) || '';'' -- medio de pago
               || f_axis_literales(100577, x.v_idioma) || '';''   --nnumide
               || f_axis_literales(100829, x.v_idioma) || '';''   --producto
               || f_axis_literales(105387, x.v_idioma) || '';''   --coaseguro
               || f_axis_literales(9905356, x.v_idioma) || '';''   --valor coaseguro
               || f_axis_literales(100956, x.v_idioma) || '';'' || '' '' linea
            from   (select nvl(f_usu_idioma,2) v_idioma from dual) x,
       dual ';
      v_ntraza := 1130;

      IF v_txt IS NULL THEN
         v_txt := 'select 0 from dual';
      END IF;

      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_list734_cab;

   FUNCTION f_list734_det(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_cestrec IN NUMBER DEFAULT NULL,
      p_fdesde IN VARCHAR2 DEFAULT NULL,
      p_fhasta IN VARCHAR2 DEFAULT NULL,
      p_ctiprec IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL,
      p_cestado IN NUMBER DEFAULT NULL,
      p_perage IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_CONF.f_list734_det';
      v_tparam       VARCHAR2(1000)
         := ' idioma=' || p_cidioma || ' empresa=' || p_cempres || ' cestrec=' || p_cestrec
            || ' fdesde=' || p_fdesde || ' p_fhasta=' || p_fhasta || ' p_ctiprec= '
            || p_ctiprec || ' p_cagente=' || p_cagente || ' p_cestado=' || p_cestado
            || ' perage=' || p_perage;
      v_ntraza       NUMBER := 0;
      v_idioma       NUMBER;
      v_sperson_aseg NUMBER;
      v_sep          VARCHAR2(1) := ';';
      v_sep2         VARCHAR2(9) := '||' || CHR(39) || ';' || CHR(39) || '||';
      v_sep3         VARCHAR2(9) := '||' || CHR(39) || ';' || CHR(39);
      v_fdesde       VARCHAR2(10);
      v_fhasta       VARCHAR2(10);
      v_cagente2     VARCHAR2(100);
   BEGIN
      v_ntraza := 1040;
      v_fdesde := LPAD(p_fdesde, 8, '0');
      v_fhasta := LPAD(p_fhasta, 8, '0');

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      -- ini BUG 0025623 - 02/05/2013 - JMF
      IF p_perage IS NOT NULL THEN
         -- Buscar los agentes a partir de la persona
         v_cagente2 := ' rc.cagente in (select cagente from agentes where sperson='
                       || p_perage || ')';
      ELSIF p_cagente IS NOT NULL THEN
         -- Buscar un agente concreto
         v_cagente2 := ' rc.cagente=' || CHR(39) || p_cagente || CHR(39);
      ELSE
         -- Resto de casos
         v_cagente2 := ' rc.cagente=ff_agente_cpolvisio(pac_user.ff_get_cagente(f_user))';
      END IF;

      -- fin BUG 0025623 - 02/05/2013 - JMF
      v_txt := NULL;
      v_txt := v_txt || ' SELECT se.npoliza ' || v_sep2 || ' se.ncertif ' || v_sep2
               || ' se.fefecto ' || v_sep2 || ' se.fcarpro ' || v_sep2
               || ' ff_desvalorfijo(17,' || v_idioma || ',se.cforpag)' || v_sep2
               || ' e.tempres ' || v_sep2 || ' re.nrecibo ' || v_sep2
               || ' ff_desagente(re.cagente) ' || v_sep2 || ' re.fefecto ' || v_sep2
               || ' re.femisio ' || v_sep2 || ' re.fvencim ' || v_sep2 || ' ff_desvalorfijo(8,'
               || v_idioma || ', re.ctiprec) ' || v_sep2 || ' (SELECT COUNT(*) FROM movrecibo '
               || ' WHERE (cestrec = 1)  AND nrecibo = re.nrecibo)' || v_sep2 || ' v.itotalr '
               || v_sep2 || ' ff_desvalorfijo(1,' || v_idioma
               || ',f_cestrec(re.nrecibo, f_sysdate)) ' || v_sep2 || ' ff_desvalorfijo(61, '
               || v_idioma || ', se.csituac) ' || v_sep2;

      IF NVL(pac_parametros.f_parlistado_n(p_cempres, 'VER_FECHACOB_ENMAPS'), 0) = 1 THEN
         v_txt := v_txt
                  || ' DECODE(f_cestrec(re.nrecibo, f_sysdate), 1, TRUNC(m.fmovini),null)  '
                  || v_sep2;
      END IF;

      v_txt :=
         v_txt || ' pac_isqlfor.f_ramo(se.cramo,' || v_idioma || ') ' || v_sep2
         || ' pac_redcomercial.f_busca_padre(' || CHR(39) || p_cempres || CHR(39)
         || ', se.cagente, NULL, NULL) ' || v_sep2 || ' pac_redcomercial.f_busca_padre('
         || CHR(39) || p_cempres || CHR(39) || ', se.cagente, 1, NULL) ' || v_sep2
         || ' f_nombre(t.sperson, 1, NULL) ' || v_sep2 || ' v.itotalr '
         || v_sep2   --prima emitida
                  || ' v.iips ' || v_sep2 || ' v.iderreg ' || v_sep2 || ' v.itotdto ' || v_sep2
         || ' v.iprinet ' || v_sep2   --prima neta
         || ' NVL(DECODE(pac_adm_cobparcial.f_get_importe_cobro_parcial(v.nrecibo),0, '
         || ' (SELECT DECODE(COUNT(*), 0, 0, nvl(v.itotalr,0)) ' || ' FROM movrecibo '
         || ' WHERE cestrec = 1 ' || ' AND fmovfin IS NULL ' || ' AND nrecibo = re.nrecibo), '
         || ' nvl(pac_adm_cobparcial.f_get_importe_cobro_parcial(re.nrecibo),0)), 0) '
         || v_sep2
         || ' ( nvl(v.itotalr,0) - NVL(DECODE(pac_adm_cobparcial.f_get_importe_cobro_parcial(v.nrecibo),0, '
         || ' (SELECT DECODE(COUNT(*), 0, 0, nvl(v.itotalr,0)) ' || ' FROM movrecibo '
         || ' WHERE cestrec = 1 ' || ' AND fmovfin IS NULL ' || ' AND nrecibo = re.nrecibo), '
         || ' nvl(pac_adm_cobparcial.f_get_importe_cobro_parcial(re.nrecibo),0)), 0) ) '
         || v_sep2 || ' (SELECT TO_CHAR(fmovini, ''dd/mm/yyyy'') ' || ' FROM movrecibo '
         || ' WHERE cestrec = 1 ' || ' AND fmovfin IS NULL ' || ' AND nrecibo = re.nrecibo) '
         || v_sep2   --FECHA PAGO
                  || ' ff_desvalorfijo( 1026,' || v_idioma || ', re.ctipcob) '
         || v_sep2   --MEDIO De pago
                  || ' pac_isqlfor.f_dades_persona(t.sperson, 1,' || v_idioma || ' ) '
         || v_sep2 || ' f_desproducto_t(se.cramo, se.cmodali, se.ctipseg, se.ccolect, 1,'
         || v_idioma || ') ' || v_sep2 || ' ff_desvalorfijo(800109, ' || v_idioma
         || ', NVL(re.ctipcoa, 0)) ' || v_sep2 || ' v.icednet ' || v_sep2
         || ' (SELECT DECODE(NVL(p.creaseg, 0), 0, ''No'', ''Si'') ' || ' FROM productos p '
         || ' WHERE p.sproduc = se.sproduc)  ' || v_sep3 || ' linea '
         || ' FROM seguros se, agentes_agente a, recibos re, movrecibo m, tomadores t, '
         || ' (SELECT nrecibo, ipridev, itotalr,icednet, icedpdv, iips, (iderreg+icedrfr) iderreg, itotdto, iprinet '
         || ' FROM vdetrecibos ' || ' WHERE NVL(pac_parametros.f_parempresa_n(' || CHR(39)
         || p_cempres || CHR(39) || ', ''MULTIMONEDA''), 0) = 0 ' || ' UNION '
         || ' SELECT nrecibo, ipridev, itotalr,icednet, icedpdv, iips, (iderreg+icedrfr) iderreg, itotdto, iprinet '
         || ' FROM vdetrecibos_monpol ' || ' WHERE NVL(pac_parametros.f_parempresa_n('
         || CHR(39) || p_cempres || CHR(39) || ', ''MULTIMONEDA''), 0) = 1) v, '
         || ' empresas e ' || ' WHERE se.sseguro = re.sseguro '
         || ' AND re.nrecibo = m.nrecibo ' || ' AND v.nrecibo = m.nrecibo '
         || ' AND m.fmovfin IS NULL '   -- el ¿ltimo movimiento
         || ' AND re.cagente = a.cagente '   -- filtramos que solo pueda ver por su nivel de visi¿n
         || ' AND re.cempres = a.cempres '   -- filtramos que solo pueda ver por su nivel de visi¿n
         || ' AND(re.cagente, re.cempres) IN( SELECT rc.cagente, rc.cempres '
         || ' FROM (SELECT rc.cagente, rc.cempres ' || ' FROM redcomercial rc '
         || ' WHERE rc.fmovfin IS NULL ' || ' START WITH ' || v_cagente2
         || ' CONNECT BY PRIOR rc.cagente = rc.cpadre '
         || ' AND PRIOR rc.fmovfin IS NULL) rc, ' || ' agentes_agente_pol a '
         || ' WHERE rc.cagente = a.cagente) ' || ' AND re.fefecto >= NVL(TO_DATE(' || CHR(39)
         || v_fdesde || CHR(39) || ',''ddmmrrrr''), re.fefecto) '   --desde
         || ' AND re.fefecto <= NVL(TO_DATE(' || CHR(39) || v_fhasta || CHR(39)
         || ',''ddmmrrrr''), re.fefecto) '   -- hasta
                                          || ' AND re.ctiprec = NVL(' || CHR(39) || p_ctiprec
         || CHR(39) || ',re.ctiprec) '   -- tipo de recibo
         || ' AND f_cestrec(re.nrecibo, f_sysdate) = NVL(' || CHR(39) || p_cestrec || CHR(39)
         || ' , f_cestrec(re.nrecibo, f_sysdate)) '   -- estado del recibo
         || ' AND v.itotalr <>0 ' || ' AND se.csituac = NVL(' || CHR(39) || p_cestado
         || CHR(39) || ',se.csituac) ' || ' AND ( re.cempres =  ' || CHR(39) || p_cempres
         || CHR(39) || ' OR' || CHR(39) || p_cempres || CHR(39) || ' IS NULL) '
         || ' AND e.cempres = re.cempres ' || ' AND re.CESTAUX<>2 '
         || ' AND se.sseguro = t.sseguro ';
      v_ntraza := 9999;

      IF v_txt IS NULL THEN
         v_txt := 'select 0 from dual';
      END IF;

      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_list734_det;

--FIN--BUG 24933 -- 18/04/2013--ETM --
   /******************************************************************************************
       Descripci¿: Funci¿ que genera la cap¿alera per llistat sobrecomisions
       Par¿metres entrada:  - p_cidioma     -> codigo idioma
                           - p_cempres     -> codigo empresa
                           - p_mes         -> mes
                           - p_anyo         -> a¿o
                           - p_cramo       -> codigo ramo
                           - p_cagente     -> codigo intermediario
         ':MES :ANYO'
        ':CIDIOMA|:CEMPRES|:MES|:CANYO|:CRAMO|:CAGENTE',

                 return:              text select cabecera
     ******************************************************************************************/
   FUNCTION f_list752_cab(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_mes IN NUMBER DEFAULT NULL,
      p_anyo IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_CONF.f_list752_cab';
      v_tparam       VARCHAR2(1000)
         := ' idioma=' || p_cidioma || ' e=' || p_cempres || ' mes=' || p_mes || ' any='
            || p_anyo || ' ramo=' || p_cramo || ' agente=' || p_cagente;
      v_ntraza       NUMBER := 0;
      v_idioma       NUMBER;
      v_sep          VARCHAR2(1) := ';';
   BEGIN
      v_ntraza := 1130;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      v_txt := f_axis_literales(9000495, v_idioma) || ': ' || p_mes || ' - '
               || f_axis_literales(101606, v_idioma) || ': ' || p_anyo || CHR(13) || CHR(13);
      v_txt := v_txt || f_axis_literales(9902363, v_idioma) || v_sep
               || f_axis_literales(100784, v_idioma) || v_sep
               || f_axis_literales(100829, v_idioma) || v_sep
               || f_axis_literales(9905762, v_idioma) || v_sep
               || f_axis_literales(9902731, v_idioma) || v_sep
               || f_axis_literales(105830, v_idioma) || v_sep
               || f_axis_literales(9904847, v_idioma) || v_sep
               || f_axis_literales(9905765, v_idioma) || v_sep
               || f_axis_literales(107870, v_idioma) || v_sep
               || f_axis_literales(9905764, v_idioma) || v_sep
               || f_axis_literales(9905765, v_idioma) || v_sep;
      v_ntraza := 1130;
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_list752_cab;

   /******************************************************************************************
         Descripci¿: Funci¿ que genera el contigut per llistat sobrecomisions
          Par¿metres entrada:  - p_cidioma     -> codigo idioma
                           - p_cempres     -> codigo empresa
                           - p_mes         -> mes
                           - p_anyo         -> a¿o
                           - p_cramo       -> codigo ramo
                           - p_cagente     -> codigo intermediario
         ':MES :ANYO'
        ':CIDIOMA|:CEMPRES|:MES|:CANYO|:CRAMO|:CAGENTE',
                   return:              text select detall
       ******************************************************************************************/
   FUNCTION f_list752_det(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_mes IN NUMBER DEFAULT NULL,
      p_anyo IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_CONF.f_list752_det';
      v_tparam       VARCHAR2(1000)
         := ' idioma=' || p_cidioma || ' e=' || p_cempres || ' mes=' || p_mes || ' any='
            || p_anyo || ' ramo=' || p_cramo || ' agente=' || p_cagente;
      v_ntraza       NUMBER := 0;
      v_finiefe      VARCHAR2(100);
      v_ffinefe      VARCHAR2(100);
      v_sep          VARCHAR2(1) := ';';
      v_idioma       NUMBER;
      v_sep3         VARCHAR2(9) := '||' || CHR(39) || ';' || CHR(39);
      v_sep2         VARCHAR2(9) := '||' || CHR(39) || ';' || CHR(39) || '||';
      v_fini         VARCHAR2(10);
      v_ffin         VARCHAR2(10);
      v_dia          NUMBER;
   BEGIN
      v_ntraza := 1000;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      v_fini := '01/' || p_mes || '/' || p_anyo;

      BEGIN
         SELECT EXTRACT(DAY FROM LAST_DAY(v_fini))
           INTO v_dia
           FROM DUAL;
      EXCEPTION
         WHEN OTHERS THEN
            v_dia := 1;
      END;

      v_ffin := v_dia || '/' || p_mes || '/' || p_anyo;
      v_txt := NULL;
      --' || v_idioma || '
      v_txt := ' select sp.CAGENTE' || v_sep2 || ' ra.TRAMO' || v_sep2 || 't.TTITULO' || v_sep2
               || 'sp.IPRIMPROD' || v_sep2 || 'sp.IPRIMREC' || v_sep2 || 'sp.IPRIMEMREC'
               || v_sep2
               || '(sp.ISINPAGADOS +sp.IRESSINPDTES -sp.IRESSINPDTESANT ) / sp.IPRIMEMREC'
               || v_sep2
               || '(sp.ISINPAGADOS +sp.IRESSINPDTES -sp.IRESSINPDTESANT ), sp.ISINPAGADOS'
               || v_sep2 || 'sp.IRESSINPDTES' || v_sep2 || 'sp.IRESSINPDTESANT' || v_sep3
               || ' linea ' || ' from calcsobrecomis sp, productos p, titulopro t, ramos ra '
               || ' where  sp.finicio between TO_DATE(' || CHR(39) || v_fini || CHR(39)
               || ', ''dd/mm/yyyy'')' || ' and TO_DATE(' || CHR(39) || v_ffin || CHR(39)
               || ', ''dd/mm/yyyy'')' || ' and   p.sproduc = sp.sproduc and t.cramo = p.cramo '
               || ' and t.cmodali = p.cmodali ' || ' and t.ctipseg = p.ctipseg '
               || ' and t.ccolect = p.ccolect ' || ' and t.cidioma = ' || v_idioma
               || ' and   ra.cramo = t.cramo ' || ' and   ra.cidioma = ' || v_idioma;

      -- Si el ramo est¿ informado
      IF p_cramo IS NOT NULL THEN
         v_txt := v_txt || ' and ra.cramo = ' || p_cramo;
      END IF;

      --si el agente est¿ informado
      IF p_cagente IS NOT NULL THEN
         v_txt := v_txt || ' and sp.cagente  = ' || p_cagente;
      END IF;

      v_ntraza := 9999;

      IF v_txt IS NULL THEN
         v_txt := 'select 0 from dual';
      END IF;

      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_list752_det;

--BUG 0025615 -- 18/09/2012--ETM --INI
   FUNCTION f_663_cab_borrar
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_CONF.f_663_cab';
      v_tparam       VARCHAR2(1000);
      v_ntraza       NUMBER := 0;
      v_sep          VARCHAR2(1) := ';';
      v_ret          VARCHAR2(1) := CHR(10);
      v_init         VARCHAR2(32000);
      v_ttexto       VARCHAR2(32000);
   BEGIN
      v_ttexto :=
         'SELECT '' '' ||f_axis_literales(9002202,x.idi) || '';''|| f_axis_literales(9905164, x.idi) || '';''
        || f_axis_literales(101619, x.idi) || '';'' || f_axis_literales(100784, x.idi)
        || '';'' || f_axis_literales(9903176, x.idi) || '';''
        || f_axis_literales(100943, x.idi) || '';'' || f_axis_literales(102098, x.idi)
        || '';''
        || f_axis_literales(9001021, x.idi) || '';'' || f_axis_literales(100829, x.idi)
        || '';'' || f_axis_literales(110994, x.idi)
        || '';'' ||f_axis_literales(111324,x.idi)||'';'' ||  f_axis_literales(103481, x.idi) || '';''
        || f_axis_literales(101168, x.idi) || '';'' || f_axis_literales(9002216, x.idi)
        --|| '';'' || f_axis_literales(9901010, x.idi)
        || '';'' || f_axis_literales(9901872, x.idi)
        || '';'' || f_axis_literales(9901873, x.idi)
        || '';'' || f_axis_literales(9000572, x.idi) || '';''
        || f_axis_literales(9902716, x.idi) || '';'' || f_axis_literales(9903177, x.idi)
        || '';'' || f_axis_literales(9903178, x.idi)
       --|| '';''
       -- || f_axis_literales(9903179, x.idi) || '';'' || f_axis_literales(9903180, x.idi)
       -- || '';'' || f_axis_literales(9904197, x.idi) || '';'' || f_axis_literales(9904196, x.idi)
        || '';'' || ''Provisi¿n Prima No devengada''
        --|| '';'' || f_axis_literales(9904500, x.idi) || '';'' || f_axis_literales(9904499, x.idi)
       -- || '';'' || f_axis_literales(9904194, x.idi) || '';'' || f_axis_literales(9904195, x.idi)
        || '';'' || '' '' linea
   FROM (SELECT NVL(f_usu_idioma, 1) idi
           FROM DUAL) x,
        DUAL';
      RETURN(v_ttexto);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_663_cab_borrar;

   FUNCTION f_663_det_borrar(pfcalcul VARCHAR2, psproces NUMBER, pcempres NUMBER)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_CONF.f_663_det';
      v_tparam       VARCHAR2(1000);
      v_ntraza       NUMBER := 0;
      v_sep          VARCHAR2(1) := ';';
      v_ret          VARCHAR2(1) := CHR(10);
      v_init         VARCHAR2(32000);
      v_ttexto       VARCHAR2(32000);
   BEGIN
      --BUG 0040577 -- 23/02/2016--VCG --INI-valida si es para CONFitiva
      IF pcempres = 17
      THEN
          v_ttexto :=
               'SELECT desc_cagente|| '';'' || sucursal || '';'' ||tempres || '';'' || cramo || '';'' || sproduc || '';'' || cmodali || '';'' || ctipseg
        || '';'' || ccolect || '';'' || producto || '';'' || garantia
        || '';'' || npoliza || '';''
        || cactivi || '';'' || ncertif || '';''
        || IGWP ||'';''
       -- || prim_no_con || '';''
        || icwp || '';''
        || inep || '';''
        || TO_CHAR(fini, ''dd-mm-rrrr'') || '';'' || TO_CHAR(ffin, ''dd-mm-rrrr'') || '';''
        || dias_amort || '';'' || dias_por_amort || '';''
       -- || prim_dev_coa  || '';''
       -- || prim_no_dev_coa || '';''
         || igupr || '';''
        --|| igupr_80 || '';''
        --|| igupr_20 || '';''
        -- || igupr|| '';''
       -- || icupr_80 || '';''
       -- || icupr_20 || '';''
       -- || icupr  || '';''
      --  || inupr  || '';''
        linea
        FROM (SELECT
        ff_desagente(pac_redcomercial.f_busca_padre(s.cempres, nvl(agco.cagente,s.cagente), NULL, NULL)) desc_cagente,
        s.npoliza, ff_desgarantia(u.cgarant,NVL(f_usu_idioma, 8)) garantia, u.sseguro,
        pac_corretaje.f_impcor_agente(nvl(u.iprianu_moncon,u.iprianu),agco.cagente,s.sseguro,u.nmovimi) iprianu,
        pac_corretaje.f_impcor_agente(nvl(u.igupr_moncon, u.igupr),agco.cagente,s.sseguro,u.nmovimi) igupr,
--        pac_corretaje.f_impcor_agente(nvl(u.igupr_moncon, u.igupr)*(80/100),agco.cagente,s.sseguro,u.nmovimi) igupr_80,
--        pac_corretaje.f_impcor_agente(nvl(u.igupr_moncon, u.igupr)*(20/100),agco.cagente,s.sseguro,u.nmovimi) igupr_20,
--        pac_corretaje.f_impcor_agente(nvl(u.icupr_moncon, u.icupr),agco.cagente,s.sseguro,u.nmovimi) icupr,
--        pac_corretaje.f_impcor_agente(nvl(u.icupr_moncon, u.icupr)*(80/100),agco.cagente,s.sseguro,u.nmovimi) icupr_80,
--        pac_corretaje.f_impcor_agente(nvl(u.icupr_moncon, u.icupr)*(20/100),agco.cagente,s.sseguro,u.nmovimi) icupr_20,
--        pac_corretaje.f_impcor_agente(nvl(u.inupr_moncon, u.inupr),agco.cagente,s.sseguro,u.nmovimi) inupr,
        pac_corretaje.f_impcor_agente(u.igwp,agco.cagente,s.sseguro,u.nmovimi) igwp,
        pac_corretaje.f_impcor_agente(nvl(u.inep_moncon, u.inep),agco.cagente,s.sseguro,u.nmovimi) inep,
        u.padq, --
        pac_corretaje.f_impcor_agente(u.ifactries,agco.cagente,s.sseguro,u.nmovimi) ifactries,
        u.cmoneda, pac_monedas.f_cmoneda_t(u.cmoneda) descmoneda,
        u.itasa, ff_descompania(pac_cuadre_adm.f_es_vida(s.sseguro)) tempres, u.cramo, s.sproduc, u.cmodali, u.ctipseg,
        SUBSTR(pac_redcomercial.f_busca_padre(s.cempres, nvl(agco.cagente,s.cagente), NULL, NULL),-3) sucursal, u.ccolect,
        f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 8) producto,
        s.cactivi, s.ncertif, 0 prim_no_con, pac_corretaje.f_impcor_agente(nvl(u.icwp_moncon, u.icwp),agco.cagente,s.sseguro,u.nmovimi) icwp, u.fini, u.ffin,'
            ||
               --6.0028785: Error en los c¿lculos de D¿as Amortizados y D¿as por Amortizar - Inicio
               --(s.fefecto - u.fcalcul) dias_amort,
               --(NVL(s.fvencim, s.fcaranu) - u.fcalcul) dias_por_amort,
               '(TRUNC(u.fini) - TRUNC(u.fcalcul)) dias_amort, '
            || '(TRUNC(u.ffin) - TRUNC(u.fcalcul)) dias_por_amort, '
            ||
               --6.0028785: Error en los c¿lculos de D¿as Amortizados y D¿as por Amortizar - Final
               '0 prim_dev_coa,
        0 prim_no_dev_coa
        FROM upr u, seguros s, empresas e,age_corretaje agco
        WHERE s.sseguro = u.sseguro
        AND u.fcalcul = TO_DATE('''
            || pfcalcul
            || ''',''ddmmyyyy'')
        AND u.sproces = '
            || psproces
            || '
        AND u.cempres = '
            || pcempres
            || '
        AND u.cempres = e.cempres
        AND agco.sseguro(+) = s.sseguro
        and nvl(agco.nmovimi,-1) = (select nvl(max(z.nmovimi),-1) from age_corretaje z where z.sseguro = agco.sseguro and z.nmovimi <= u.nmovimi)
        AND s.sproduc NOT IN (7061,7062,7063)
        UNION ALL
        SELECT
        ff_desagente(pac_redcomercial.f_busca_padre(s.cempres, nvl(agco.cagente,s.cagente), NULL, NULL)) desc_cagente,
        s.npoliza, ff_desgarantia(u.cgarant,NVL(f_usu_idioma, 8)) garantia, u.sseguro,
        pac_corretaje.f_impcor_agente(nvl(u.iprianu_moncon,u.iprianu),agco.cagente,s.sseguro,u.nmovimi) iprianu,
        pac_corretaje.f_impcor_agente(nvl(u.igupr_moncon, u.igupr),agco.cagente,s.sseguro,u.nmovimi) igupr,
--        pac_corretaje.f_impcor_agente(nvl(u.igupr_moncon, u.igupr)*(80/100),agco.cagente,s.sseguro,u.nmovimi) igupr_80,
--        pac_corretaje.f_impcor_agente(nvl(u.igupr_moncon, u.igupr)*(20/100),agco.cagente,s.sseguro,u.nmovimi) igupr_20,
--        pac_corretaje.f_impcor_agente(nvl(u.icupr_moncon, u.icupr),agco.cagente,s.sseguro,u.nmovimi) icupr,
--        pac_corretaje.f_impcor_agente(nvl(u.icupr_moncon, u.icupr)*(80/100),agco.cagente,s.sseguro,u.nmovimi) icupr_80,
--        pac_corretaje.f_impcor_agente(nvl(u.icupr_moncon, u.icupr)*(20/100),agco.cagente,s.sseguro,u.nmovimi) icupr_20,
--        pac_corretaje.f_impcor_agente(nvl(u.inupr_moncon, u.inupr),agco.cagente,s.sseguro,u.nmovimi) inupr,
        pac_corretaje.f_impcor_agente(u.igwp,agco.cagente,s.sseguro,u.nmovimi) igwp,
        pac_corretaje.f_impcor_agente(nvl(u.inep_moncon, u.inep),agco.cagente,s.sseguro,u.nmovimi) inep,
        u.padq, --
        pac_corretaje.f_impcor_agente(u.ifactries,agco.cagente,s.sseguro,u.nmovimi) ifactries,
        u.cmoneda, pac_monedas.f_cmoneda_t(u.cmoneda) descmoneda,
        u.itasa, ff_descompania(pac_cuadre_adm.f_es_vida(s.sseguro)) tempres, u.cramo, s.sproduc, u.cmodali, u.ctipseg,
        SUBSTR(pac_redcomercial.f_busca_padre(s.cempres, nvl(agco.cagente,s.cagente), NULL, NULL),-3) sucursal, u.ccolect,
        f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 8) producto,
        s.cactivi, s.ncertif, 0 prim_no_con, pac_corretaje.f_impcor_agente(nvl(u.icwp_moncon, u.icwp),agco.cagente,s.sseguro,u.nmovimi) icwp, u.fini, u.ffin, '
            ||
               --6.0028785: Error en los c¿lculos de D¿as Amortizados y D¿as por Amortizar - Inicio
               --(s.fefecto - u.fcalcul) dias_amort,
               --(NVL(s.fvencim, s.fcaranu) - u.fcalcul) dias_por_amort,
               '(TRUNC(u.fini) - TRUNC(u.fcalcul)) dias_amort, '
            || '(TRUNC(u.ffin) - TRUNC(u.fcalcul)) dias_por_amort, '
            ||
               --6.0028785: Error en los c¿lculos de D¿as Amortizados y D¿as por Amortizar - Final
               ' 0 prim_dev_coa,
        0 prim_no_dev_coa
        FROM upr_previo u, seguros s, empresas e,age_corretaje agco
        WHERE s.sseguro = u.sseguro
        AND u.fcalcul = TO_DATE('''
            || pfcalcul
            || ''',''ddmmyyyy'')
        AND u.sproces = '
            || psproces
            || '
        AND u.cempres = '
            || pcempres
            || '
        AND u.cempres = e.cempres
        AND agco.sseguro(+) = s.sseguro
        and nvl(agco.nmovimi,-1) = (select nvl(max(z.nmovimi),-1) from age_corretaje z where z.sseguro = agco.sseguro and z.nmovimi <= u.nmovimi)
        AND s.sproduc NOT IN (7061,7062,7063))';
      ELSE
      v_ttexto :=
         'SELECT desc_cagente|| '';'' || sucursal || '';'' ||tempres || '';'' || cramo || '';'' || sproduc || '';'' || cmodali || '';'' || ctipseg
        || '';'' || ccolect || '';'' || producto || '';'' || garantia
        || '';'' || npoliza || '';''
        || cactivi || '';'' || ncertif || '';''
        || IGWP ||'';''
       -- || prim_no_con || '';''
        || icwp || '';''
        || inep || '';''
        || TO_CHAR(fini, ''dd-mm-rrrr'') || '';'' || TO_CHAR(ffin, ''dd-mm-rrrr'') || '';''
        || dias_amort || '';'' || dias_por_amort || '';''
       -- || prim_dev_coa  || '';''
       -- || prim_no_dev_coa || '';''
         || igupr || '';''
        --|| igupr_80 || '';''
        --|| igupr_20 || '';''
        -- || igupr|| '';''
       -- || icupr_80 || '';''
       -- || icupr_20 || '';''
       -- || icupr  || '';''
      --  || inupr  || '';''
        linea
        FROM (SELECT
        ff_desagente(pac_redcomercial.f_busca_padre(s.cempres, nvl(agco.cagente,s.cagente), NULL, NULL)) desc_cagente,
        s.npoliza, ff_desgarantia(u.cgarant,NVL(f_usu_idioma, 8)) garantia, u.sseguro,
        pac_corretaje.f_impcor_agente(nvl(u.iprianu_moncon,u.iprianu),agco.cagente,s.sseguro,u.nmovimi) iprianu,
        pac_corretaje.f_impcor_agente(nvl(u.igupr_moncon, u.igupr),agco.cagente,s.sseguro,u.nmovimi) igupr,
--        pac_corretaje.f_impcor_agente(nvl(u.igupr_moncon, u.igupr)*(80/100),agco.cagente,s.sseguro,u.nmovimi) igupr_80,
--        pac_corretaje.f_impcor_agente(nvl(u.igupr_moncon, u.igupr)*(20/100),agco.cagente,s.sseguro,u.nmovimi) igupr_20,
--        pac_corretaje.f_impcor_agente(nvl(u.icupr_moncon, u.icupr),agco.cagente,s.sseguro,u.nmovimi) icupr,
--        pac_corretaje.f_impcor_agente(nvl(u.icupr_moncon, u.icupr)*(80/100),agco.cagente,s.sseguro,u.nmovimi) icupr_80,
--        pac_corretaje.f_impcor_agente(nvl(u.icupr_moncon, u.icupr)*(20/100),agco.cagente,s.sseguro,u.nmovimi) icupr_20,
--        pac_corretaje.f_impcor_agente(nvl(u.inupr_moncon, u.inupr),agco.cagente,s.sseguro,u.nmovimi) inupr,
        pac_corretaje.f_impcor_agente(u.igwp,agco.cagente,s.sseguro,u.nmovimi) igwp,
        pac_corretaje.f_impcor_agente(nvl(u.inep_moncon, u.inep),agco.cagente,s.sseguro,u.nmovimi) inep,
        u.padq, --
        pac_corretaje.f_impcor_agente(u.ifactries,agco.cagente,s.sseguro,u.nmovimi) ifactries,
        u.cmoneda, pac_monedas.f_cmoneda_t(u.cmoneda) descmoneda,
        u.itasa, ff_descompania(pac_cuadre_adm.f_es_vida(s.sseguro)) tempres, u.cramo, s.sproduc, u.cmodali, u.ctipseg,
        SUBSTR(pac_redcomercial.f_busca_padre(s.cempres, nvl(agco.cagente,s.cagente), NULL, NULL),-3) sucursal, u.ccolect,
        f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 8) producto,
        s.cactivi, s.ncertif, 0 prim_no_con, pac_corretaje.f_impcor_agente(nvl(u.icwp_moncon, u.icwp),agco.cagente,s.sseguro,u.nmovimi) icwp, u.fini, u.ffin,'
         ||
            --6.0028785: Error en los c¿lculos de D¿as Amortizados y D¿as por Amortizar - Inicio
            --(s.fefecto - u.fcalcul) dias_amort,
            --(NVL(s.fvencim, s.fcaranu) - u.fcalcul) dias_por_amort,
         '(TRUNC(u.fini) - TRUNC(u.fcalcul)) dias_amort, '
         || '(TRUNC(u.ffin) - TRUNC(u.fcalcul)) dias_por_amort, '
         ||
            --6.0028785: Error en los c¿lculos de D¿as Amortizados y D¿as por Amortizar - Final
         '0 prim_dev_coa,
        0 prim_no_dev_coa
        FROM upr u, seguros s, empresas e,age_corretaje agco
        WHERE s.sseguro = u.sseguro
        AND u.fcalcul = TO_DATE('''
         || pfcalcul || ''',''ddmmyyyy'')
        AND u.sproces = ' || psproces || '
        AND u.cempres = ' || pcempres
         || '
        AND u.cempres = e.cempres
        AND agco.sseguro(+) = s.sseguro
        and nvl(agco.nmovimi,-1) = (select nvl(max(z.nmovimi),-1) from age_corretaje z where z.sseguro = agco.sseguro and z.nmovimi <= u.nmovimi)
        UNION ALL
        SELECT
        ff_desagente(pac_redcomercial.f_busca_padre(s.cempres, nvl(agco.cagente,s.cagente), NULL, NULL)) desc_cagente,
        s.npoliza, ff_desgarantia(u.cgarant,NVL(f_usu_idioma, 8)) garantia, u.sseguro,
        pac_corretaje.f_impcor_agente(nvl(u.iprianu_moncon,u.iprianu),agco.cagente,s.sseguro,u.nmovimi) iprianu,
        pac_corretaje.f_impcor_agente(nvl(u.igupr_moncon, u.igupr),agco.cagente,s.sseguro,u.nmovimi) igupr,
--        pac_corretaje.f_impcor_agente(nvl(u.igupr_moncon, u.igupr)*(80/100),agco.cagente,s.sseguro,u.nmovimi) igupr_80,
--        pac_corretaje.f_impcor_agente(nvl(u.igupr_moncon, u.igupr)*(20/100),agco.cagente,s.sseguro,u.nmovimi) igupr_20,
--        pac_corretaje.f_impcor_agente(nvl(u.icupr_moncon, u.icupr),agco.cagente,s.sseguro,u.nmovimi) icupr,
--        pac_corretaje.f_impcor_agente(nvl(u.icupr_moncon, u.icupr)*(80/100),agco.cagente,s.sseguro,u.nmovimi) icupr_80,
--        pac_corretaje.f_impcor_agente(nvl(u.icupr_moncon, u.icupr)*(20/100),agco.cagente,s.sseguro,u.nmovimi) icupr_20,
--        pac_corretaje.f_impcor_agente(nvl(u.inupr_moncon, u.inupr),agco.cagente,s.sseguro,u.nmovimi) inupr,
        pac_corretaje.f_impcor_agente(u.igwp,agco.cagente,s.sseguro,u.nmovimi) igwp,
        pac_corretaje.f_impcor_agente(nvl(u.inep_moncon, u.inep),agco.cagente,s.sseguro,u.nmovimi) inep,
        u.padq, --
        pac_corretaje.f_impcor_agente(u.ifactries,agco.cagente,s.sseguro,u.nmovimi) ifactries,
        u.cmoneda, pac_monedas.f_cmoneda_t(u.cmoneda) descmoneda,
        u.itasa, ff_descompania(pac_cuadre_adm.f_es_vida(s.sseguro)) tempres, u.cramo, s.sproduc, u.cmodali, u.ctipseg,
        SUBSTR(pac_redcomercial.f_busca_padre(s.cempres, nvl(agco.cagente,s.cagente), NULL, NULL),-3) sucursal, u.ccolect,
        f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 8) producto,
        s.cactivi, s.ncertif, 0 prim_no_con, pac_corretaje.f_impcor_agente(nvl(u.icwp_moncon, u.icwp),agco.cagente,s.sseguro,u.nmovimi) icwp, u.fini, u.ffin, '
         ||
            --6.0028785: Error en los c¿lculos de D¿as Amortizados y D¿as por Amortizar - Inicio
            --(s.fefecto - u.fcalcul) dias_amort,
            --(NVL(s.fvencim, s.fcaranu) - u.fcalcul) dias_por_amort,
         '(TRUNC(u.fini) - TRUNC(u.fcalcul)) dias_amort, '
         || '(TRUNC(u.ffin) - TRUNC(u.fcalcul)) dias_por_amort, '
         ||
            --6.0028785: Error en los c¿lculos de D¿as Amortizados y D¿as por Amortizar - Final
         ' 0 prim_dev_coa,
        0 prim_no_dev_coa
        FROM upr_previo u, seguros s, empresas e,age_corretaje agco
        WHERE s.sseguro = u.sseguro
        AND u.fcalcul = TO_DATE('''
         || pfcalcul || ''',''ddmmyyyy'')
        AND u.sproces = ' || psproces || '
        AND u.cempres = ' || pcempres
         || '
        AND u.cempres = e.cempres
        AND agco.sseguro(+) = s.sseguro
        and nvl(agco.nmovimi,-1) = (select nvl(max(z.nmovimi),-1) from age_corretaje z where z.sseguro = agco.sseguro and z.nmovimi <= u.nmovimi))';
      END IF;
         --BUG 0040577 -- 23/02/2016--VCG --FIN-valida si es para CONFitiva

      RETURN v_ttexto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_663_det_borrar;

--FIN - BUG 0025615 -- 18/09/2012--ETM

   /******************************************************************************************
       Descripci¿: Funci¿ que genera la cap¿alera pel llistat de salaris
       Par¿metres entrada:  - p_cidioma     -> codigo idioma
                           - p_cempres     -> codigo empresa
                           - p_mes         -> mes
                           - p_anyo         -> a¿o
                           - p_cramo       -> codigo ramo
                           - p_cagente     -> codigo intermediario
         ':MES :ANYO'
        ':CIDIOMA|:CEMPRES|:MES|:CANYO|:CRAMO|:CAGENTE',

                 return:              text select cabecera
     ******************************************************************************************/
   FUNCTION f_list756_cab1(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_mes IN NUMBER DEFAULT NULL,
      p_anyo IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_CONF.f_list756_cab1';
      v_tparam       VARCHAR2(1000)
         := ' idioma=' || p_cidioma || ' e=' || p_cempres || ' mes=' || p_mes || ' any='
            || p_anyo || ' ramo=' || p_cramo || ' agente=' || p_cagente;
      v_ntraza       NUMBER := 0;
      v_idioma       NUMBER;
      v_sep          VARCHAR2(1) := ';';
   BEGIN
      v_ntraza := 1130;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      v_txt := f_axis_literales(9000495, v_idioma) || ': ' || p_mes || ' - '
               || f_axis_literales(101606, v_idioma) || ': ' || p_anyo || v_sep || CHR(13)
               || CHR(13);
      --Sacar res¿menes.
      v_txt := v_txt || f_axis_literales(9902363, v_idioma) || v_sep
               || f_axis_literales(9906059, v_idioma) || v_sep
               || f_axis_literales(9906060, v_idioma) || v_sep
               || f_axis_literales(9902725, v_idioma) || v_sep || '%'
               || f_axis_literales(9903066, v_idioma) || v_sep || '%'
               || f_axis_literales(9906059, v_idioma) || v_sep;
      v_ntraza := 1130;
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_list756_cab1;

   /******************************************************************************************
         Descripci¿: Funci¿ que genera el contigut pel llistat salaris
          Par¿metres entrada:  - p_cidioma     -> codigo idioma
                           - p_cempres     -> codigo empresa
                           - p_mes         -> mes
                           - p_anyo         -> a¿o
                           - p_cramo       -> codigo ramo
                           - p_cagente     -> codigo intermediario
         ':MES :ANYO'
        ':CIDIOMA|:CEMPRES|:MES|:CANYO|:CRAMO|:CAGENTE',
                   return:              text select detall
       ******************************************************************************************/
   FUNCTION f_list756_det1(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_mes IN NUMBER DEFAULT NULL,
      p_anyo IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_CONF.f_list756_det1';
      v_tparam       VARCHAR2(1000)
         := ' idioma=' || p_cidioma || ' e=' || p_cempres || ' mes=' || p_mes || ' any='
            || p_anyo || ' ramo=' || p_cramo || ' agente=' || p_cagente;
      v_ntraza       NUMBER := 0;
      v_finiefe      VARCHAR2(100);
      v_ffinefe      VARCHAR2(100);
      v_sep          VARCHAR2(1) := ';';
      v_idioma       NUMBER;
      v_sep3         VARCHAR2(9) := '||' || CHR(39) || ';' || CHR(39);
      v_sep2         VARCHAR2(9) := '||' || CHR(39) || ';' || CHR(39) || '||';
      v_fini         VARCHAR2(10);
      v_ffin         VARCHAR2(10);
      v_dia          NUMBER;
      v_txtramo      VARCHAR2(200) := NULL;
      v_txtagente    VARCHAR2(200) := NULL;
   BEGIN
      v_ntraza := 1000;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      v_fini := '01/' || p_mes || '/' || p_anyo;

      BEGIN
         SELECT EXTRACT(DAY FROM LAST_DAY(v_fini))
           INTO v_dia
           FROM DUAL;
      EXCEPTION
         WHEN OTHERS THEN
            v_dia := 1;
      END;

      v_ffin := v_dia || '/' || p_mes || '/' || p_anyo;
      v_txt := NULL;
      --' || v_idioma || '
      v_txt := ' select sp.CAGENTE' || v_sep2 || 'sp.ISALARIO' || v_sep2 || 'sp.PCUMPLI'
               || v_sep2 || 'sp.PSINIES' || v_sep2 || ' sp.PBONIF' || v_sep2 || ' sp.PPORSAL'
               || v_sep3 || ' linea ' || ' from CONF_sal_result_previo sp '
               || ' where  sp.fcierre between TO_DATE(' || CHR(39) || v_fini || CHR(39)
               || ', ''dd/mm/yyyy'')' || ' and TO_DATE(' || CHR(39) || v_ffin || CHR(39)
               || ', ''dd/mm/yyyy'') ';

      --si el agente est¿ informado
      IF p_cagente IS NOT NULL THEN
         v_txtagente := ' and sp.cagente  = ' || p_cagente;
      END IF;

      v_txt := v_txt || v_txtramo || v_txtagente;
      v_txt := v_txt || ' UNION  select sp.CAGENTE' || v_sep2 || 'sp.ISALARIO' || v_sep2
               || 'sp.PCUMPLI' || v_sep2 || 'sp.PSINIES' || v_sep2 || ' sp.PBONIF' || v_sep2
               || ' sp.PPORSAL' || v_sep3 || ' linea ' || ' from CONF_sal_result sp  '
               || ' where  sp.fcierre between TO_DATE(' || CHR(39) || v_fini || CHR(39)
               || ', ''dd/mm/yyyy'')' || ' and TO_DATE(' || CHR(39) || v_ffin || CHR(39)
               || ', ''dd/mm/yyyy'') ';
      v_txt := v_txt || v_txtagente;
      v_ntraza := 9999;

      IF v_txt IS NULL THEN
         v_txt := 'select 0 from dual';
      END IF;

      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_list756_det1;

   /******************************************************************************************
         Descripci¿: Funci¿ que genera el contigut pel llistat salaris
          Par¿metres entrada:  - p_cidioma     -> codigo idioma
                           - p_cempres     -> codigo empresa
                           - p_mes         -> mes
                           - p_anyo         -> a¿o
                           - p_cramo       -> codigo ramo
                           - p_cagente     -> codigo intermediario
         ':MES :ANYO'
        ':CIDIOMA|:CEMPRES|:MES|:CANYO|:CRAMO|:CAGENTE',
                   return:              text select detall
       ******************************************************************************************/
   FUNCTION f_list756_det2(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_mes IN NUMBER DEFAULT NULL,
      p_anyo IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_CONF.f_list756_det2';
      v_tparam       VARCHAR2(1000)
         := ' idioma=' || p_cidioma || ' e=' || p_cempres || ' mes=' || p_mes || ' any='
            || p_anyo || ' ramo=' || p_cramo || ' agente=' || p_cagente;
      v_ntraza       NUMBER := 0;
      v_finiefe      VARCHAR2(100);
      v_ffinefe      VARCHAR2(100);
      v_sep          VARCHAR2(1) := ';';
      v_idioma       NUMBER;
      v_sep3         VARCHAR2(9) := '||' || CHR(39) || ';' || CHR(39);
      v_sep2         VARCHAR2(9) := '||' || CHR(39) || ';' || CHR(39) || '||';
      v_fini         VARCHAR2(10);
      v_ffin         VARCHAR2(10);
      v_dia          NUMBER;
      v_txtramo      VARCHAR2(200) := NULL;
      v_txtagente    VARCHAR2(200) := NULL;
      v_cometes      VARCHAR2(5) := CHR(39);
   BEGIN
      v_ntraza := 1000;

      IF p_cidioma IS NULL THEN
         v_ntraza := 1010;

         SELECT MAX(nvalpar)
           INTO v_idioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      ELSE
         v_ntraza := 1020;
         v_idioma := p_cidioma;
      END IF;

      v_fini := '01/' || p_mes || '/' || p_anyo;

      BEGIN
         SELECT EXTRACT(DAY FROM LAST_DAY(v_fini))
           INTO v_dia
           FROM DUAL;
      EXCEPTION
         WHEN OTHERS THEN
            v_dia := 1;
      END;

      v_ffin := v_dia || '/' || p_mes || '/' || p_anyo;
      v_txt := NULL;
      --v_txt := CHR(13) || CHR(13) || CHR(13) || CHR(13);
      --Sacar res¿menes.
      v_txt := v_txt || ' Select ' || v_cometes || f_axis_literales(9902363, v_idioma) || v_sep
               || f_axis_literales(9901958, v_idioma) || v_sep
               || f_axis_literales(100784, v_idioma) || v_sep
               || f_axis_literales(100829, v_idioma) || v_sep
               || f_axis_literales(9904351, v_idioma) || v_cometes || 'from dual ';
      --' || v_idioma || '
      v_txt := v_txt || ' union all select sp.CAGENTE' || v_sep2 || ' sp.CAGEORI ' || v_sep2
               || ' ra.TRAMO' || v_sep2 || 't.TTITULO' || v_sep2 || ' sp.IIMPORTE ' || v_sep3
               || ' linea '
               || ' from CONF_sal_detalle_previo sp, productos p, titulopro t, ramos ra '
               || ' where  sp.fcierre between TO_DATE(' || CHR(39) || v_fini || CHR(39)
               || ', ''dd/mm/yyyy'')' || ' and TO_DATE(' || CHR(39) || v_ffin || CHR(39)
               || ', ''dd/mm/yyyy'')' || ' and sp.cramo = t.cramo and  t.cramo = p.cramo '
               || ' and t.cmodali = p.cmodali ' || ' and t.ctipseg = p.ctipseg '
               || ' and t.ccolect = p.ccolect ' || ' and t.cidioma = ' || v_idioma
               || ' and   ra.cramo = t.cramo ' || ' and   ra.cidioma = ' || v_idioma;

      -- Si el ramo est¿ informado
      IF p_cramo IS NOT NULL THEN
         v_txtramo := ' and ra.cramo = ' || p_cramo;
      --v_txt := v_txt || ' and ra.cramo = ' || p_cramo;
      END IF;

      --si el agente est¿ informado
      IF p_cagente IS NOT NULL THEN
         v_txtagente := ' and sp.cagente  = ' || p_cagente;
      --v_txt := v_txt || ' and sp.cagente  = ' || p_cagente;
      END IF;

      v_txt := v_txt || v_txtramo || v_txtagente;
      v_txt := v_txt || ' UNION all select sp.CAGENTE' || v_sep2 || ' sp.CAGEORI ' || v_sep2
               || ' ra.TRAMO' || v_sep2 || 't.TTITULO' || v_sep2 || ' sp.IIMPORTE ' || v_sep3
               || ' linea ' || ' from CONF_sal_detalle sp, productos p, titulopro t, ramos ra '
               || ' where  sp.fcierre between TO_DATE(' || CHR(39) || v_fini || CHR(39)
               || ', ''dd/mm/yyyy'')' || ' and TO_DATE(' || CHR(39) || v_ffin || CHR(39)
               || ', ''dd/mm/yyyy'')' || ' and sp.cramo = t.cramo and  t.cramo = p.cramo '
               || ' and t.cmodali = p.cmodali ' || ' and t.ctipseg = p.ctipseg '
               || ' and t.ccolect = p.ccolect ' || ' and t.cidioma = ' || v_idioma
               || ' and   ra.cramo = t.cramo ' || ' and   ra.cidioma = ' || v_idioma;
      v_txt := v_txt || v_txtramo || v_txtagente;
      v_txt := v_txt || ' order by 1';
      v_ntraza := 9999;

      IF v_txt IS NULL THEN
         v_txt := 'select 0 from dual';
      END IF;

      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_list756_det2;

   FUNCTION f_list777_cabecera1a(
      p_sproces IN NUMBER DEFAULT NULL,
      p_cgarant IN NUMBER DEFAULT 0,
      p_sproduc IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_CONF.f_list777_cabecera1a';
      v_tparam       VARCHAR2(1000)
         := ' sproces=' || p_sproces || ' cgarant=' || p_cgarant || ' p_sproduc=' || p_sproduc;
      v_ntraza       NUMBER := 0;
      v_finiefe      VARCHAR2(100);
      v_ffinefe      VARCHAR2(100);
      v_sep          VARCHAR2(1) := ';';
      v_idioma       NUMBER;
      v_sep3         VARCHAR2(9) := '||' || CHR(39) || ';' || CHR(39);
      v_sep2         VARCHAR2(9) := '||' || CHR(39) || ';' || CHR(39) || '||';
      v_sep4         VARCHAR2(9) := CHR(39) || ';' || CHR(39);
      v_fini         VARCHAR2(10);
      v_ffin         VARCHAR2(10);
      v_dia          NUMBER;
      v_txtramo      VARCHAR2(200) := NULL;
      v_txtagente    VARCHAR2(200) := NULL;
      v_cometes      VARCHAR2(5) := CHR(39);
      v_prim         NUMBER := 1;

      /* CURSOR calcul_i IS
          SELECT   fcalcul_i
              FROM ibnr_sam_tabdesa
             WHERE sproces = p_sproces
               AND ctipo = 0
               AND cmodo = p_cmodo
          -- AND fcalcul_i < TO_DATE('01012011', 'DDMMRRRR')
          GROUP BY fcalcul_i
          ORDER BY fcalcul_i;*/
      CURSOR calcul_j IS
         SELECT   fcalcul_i, ifactajus
             FROM ibnr_sam_tabdesa
            WHERE sproces = p_sproces
              AND ctipo = 0
              AND cgarant = p_cgarant
              AND sproduc = p_sproduc
         GROUP BY fcalcul_i, ifactajus
         ORDER BY fcalcul_i;
   BEGIN
      v_ntraza := 1000;
      --  v_txt := 'select ';
      v_txt := NULL;

      FOR i IN calcul_j LOOP
         v_txt := v_txt || v_prim || v_sep;
         --v_txt := v_txt || v_sep4 || ' from dual ';
         v_prim := v_prim + 1;
      END LOOP;

      -- v_txt := v_txt || v_sep4 || ' linea from dual';
      --v_txt := v_txt || v_sep4;
            /*v_txt := NULL;
            --v_txt := CHR(13) || CHR(13) || CHR(13) || CHR(13);
            --Sacar res¿menes.
            v_txt := v_txt || ' Select ' || v_cometes || f_axis_literales(9902363, v_idioma) || v_sep
                     || f_axis_literales(9901958, v_idioma) || v_sep
                     || f_axis_literales(100784, v_idioma) || v_sep
                     || f_axis_literales(100829, v_idioma) || v_sep
                     || f_axis_literales(9904351, v_idioma) || v_cometes || 'from dual ';
            --' || v_idioma || '
            v_txt := v_txt || ' union all select sp.CAGENTE' || v_sep2 || ' sp.CAGEORI ' || v_sep2
                     || ' ra.TRAMO' || v_sep2 || 't.TTITULO' || v_sep2 || ' sp.IIMPORTE ' || v_sep3
                     || ' linea '
                     || ' from CONF_sal_detalle_previo sp, productos p, titulopro t, ramos ra '
                     || ' where  sp.fcierre between TO_DATE(' || CHR(39) || v_fini || CHR(39)
                     || ', ''dd/mm/yyyy'')' || ' and TO_DATE(' || CHR(39) || v_ffin || CHR(39)
                     || ', ''dd/mm/yyyy'')' || ' and sp.cramo = t.cramo and  t.cramo = p.cramo '
                     || ' and t.cmodali = p.cmodali ' || ' and t.ctipseg = p.ctipseg '
                     || ' and t.ccolect = p.ccolect ' || ' and t.cidioma = ' || v_idioma
                     || ' and   ra.cramo = t.cramo ' || ' and   ra.cidioma = ' || v_idioma;

            -- Si el ramo est¿ informado
            IF p_cramo IS NOT NULL THEN
               v_txtramo := ' and ra.cramo = ' || p_cramo;
            --v_txt := v_txt || ' and ra.cramo = ' || p_cramo;
            END IF;

            --si el agente est¿ informado
            IF p_cagente IS NOT NULL THEN
               v_txtagente := ' and sp.cagente  = ' || p_cagente;
            --v_txt := v_txt || ' and sp.cagente  = ' || p_cagente;
            END IF;

            v_txt := v_txt || v_txtramo || v_txtagente;
            v_txt := v_txt || ' UNION all select sp.CAGENTE' || v_sep2 || ' sp.CAGEORI ' || v_sep2
                     || ' ra.TRAMO' || v_sep2 || 't.TTITULO' || v_sep2 || ' sp.IIMPORTE ' || v_sep3
                     || ' linea ' || ' from CONF_sal_detalle sp, productos p, titulopro t, ramos ra '
                     || ' where  sp.fcierre between TO_DATE(' || CHR(39) || v_fini || CHR(39)
                     || ', ''dd/mm/yyyy'')' || ' and TO_DATE(' || CHR(39) || v_ffin || CHR(39)
                     || ', ''dd/mm/yyyy'')' || ' and sp.cramo = t.cramo and  t.cramo = p.cramo '
                     || ' and t.cmodali = p.cmodali ' || ' and t.ctipseg = p.ctipseg '
                     || ' and t.ccolect = p.ccolect ' || ' and t.cidioma = ' || v_idioma
                     || ' and   ra.cramo = t.cramo ' || ' and   ra.cidioma = ' || v_idioma;
            v_txt := v_txt || v_txtramo || v_txtagente;
            v_txt := v_txt || ' order by 1';
            v_ntraza := 9999;

            IF v_txt IS NULL THEN
               v_txt := 'select 0 from dual';
            END IF;
      */
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_list777_cabecera1a;

   FUNCTION f_list777_linea1a(
      p_sproces IN NUMBER DEFAULT NULL,
      p_cgarant IN NUMBER DEFAULT 0,
      p_sproduc IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_CONF.f_list777_linea1a';
      v_tparam       VARCHAR2(1000)
         := ' sproces=' || p_sproces || ' cgarant=' || p_cgarant || ' p_sproduc=' || p_sproduc;
      v_ntraza       NUMBER := 0;
      v_finiefe      VARCHAR2(100);
      v_ffinefe      VARCHAR2(100);
      v_sep          VARCHAR2(1) := ';';
      v_idioma       NUMBER;
      v_sep3         VARCHAR2(9) := '||' || CHR(39) || ';' || CHR(39);
      v_sep2         VARCHAR2(9) := '||' || CHR(39) || ';' || CHR(39) || '||';
      v_sep4         VARCHAR2(9) := CHR(39) || ';' || CHR(39);
      v_fini         VARCHAR2(10);
      v_ffin         VARCHAR2(10);
      v_dia          NUMBER;
      v_txtramo      VARCHAR2(200) := NULL;
      v_txtagente    VARCHAR2(200) := NULL;
      v_cometes      VARCHAR2(5) := CHR(39);
      v_prim         NUMBER := 1;

      /* CURSOR calcul_i IS
          SELECT   fcalcul_i
              FROM ibnr_sam_tabdesa
             WHERE sproces = p_sproces
               AND ctipo = 0
               AND cmodo = p_cmodo
          -- AND fcalcul_i < TO_DATE('01012011', 'DDMMRRRR')
          GROUP BY fcalcul_i
          ORDER BY fcalcul_i;*/
      CURSOR calcul_j IS
         SELECT   fcalcul_i, ifactajus
             FROM ibnr_sam_tabdesa
            WHERE sproces = p_sproces
              AND ctipo = 0
              AND cgarant = p_cgarant
              AND sproduc = p_sproduc
         GROUP BY fcalcul_i, ifactajus
         ORDER BY fcalcul_i;
   BEGIN
      v_ntraza := 1000;
      --  v_txt := 'select ';
      v_txt := NULL;

      FOR i IN calcul_j LOOP
         v_txt := v_txt || i.ifactajus || v_sep;
      --v_txt := v_txt || v_sep4 || ' from dual ';
      END LOOP;

      -- v_txt := v_txt || v_sep4 || ' linea from dual';
      --v_txt := v_txt || v_sep4;
            /*v_txt := NULL;
            --v_txt := CHR(13) || CHR(13) || CHR(13) || CHR(13);
            --Sacar res¿menes.
            v_txt := v_txt || ' Select ' || v_cometes || f_axis_literales(9902363, v_idioma) || v_sep
                     || f_axis_literales(9901958, v_idioma) || v_sep
                     || f_axis_literales(100784, v_idioma) || v_sep
                     || f_axis_literales(100829, v_idioma) || v_sep
                     || f_axis_literales(9904351, v_idioma) || v_cometes || 'from dual ';
            --' || v_idioma || '
            v_txt := v_txt || ' union all select sp.CAGENTE' || v_sep2 || ' sp.CAGEORI ' || v_sep2
                     || ' ra.TRAMO' || v_sep2 || 't.TTITULO' || v_sep2 || ' sp.IIMPORTE ' || v_sep3
                     || ' linea '
                     || ' from CONF_sal_detalle_previo sp, productos p, titulopro t, ramos ra '
                     || ' where  sp.fcierre between TO_DATE(' || CHR(39) || v_fini || CHR(39)
                     || ', ''dd/mm/yyyy'')' || ' and TO_DATE(' || CHR(39) || v_ffin || CHR(39)
                     || ', ''dd/mm/yyyy'')' || ' and sp.cramo = t.cramo and  t.cramo = p.cramo '
                     || ' and t.cmodali = p.cmodali ' || ' and t.ctipseg = p.ctipseg '
                     || ' and t.ccolect = p.ccolect ' || ' and t.cidioma = ' || v_idioma
                     || ' and   ra.cramo = t.cramo ' || ' and   ra.cidioma = ' || v_idioma;

            -- Si el ramo est¿ informado
            IF p_cramo IS NOT NULL THEN
               v_txtramo := ' and ra.cramo = ' || p_cramo;
            --v_txt := v_txt || ' and ra.cramo = ' || p_cramo;
            END IF;

            --si el agente est¿ informado
            IF p_cagente IS NOT NULL THEN
               v_txtagente := ' and sp.cagente  = ' || p_cagente;
            --v_txt := v_txt || ' and sp.cagente  = ' || p_cagente;
            END IF;

            v_txt := v_txt || v_txtramo || v_txtagente;
            v_txt := v_txt || ' UNION all select sp.CAGENTE' || v_sep2 || ' sp.CAGEORI ' || v_sep2
                     || ' ra.TRAMO' || v_sep2 || 't.TTITULO' || v_sep2 || ' sp.IIMPORTE ' || v_sep3
                     || ' linea ' || ' from CONF_sal_detalle sp, productos p, titulopro t, ramos ra '
                     || ' where  sp.fcierre between TO_DATE(' || CHR(39) || v_fini || CHR(39)
                     || ', ''dd/mm/yyyy'')' || ' and TO_DATE(' || CHR(39) || v_ffin || CHR(39)
                     || ', ''dd/mm/yyyy'')' || ' and sp.cramo = t.cramo and  t.cramo = p.cramo '
                     || ' and t.cmodali = p.cmodali ' || ' and t.ctipseg = p.ctipseg '
                     || ' and t.ccolect = p.ccolect ' || ' and t.cidioma = ' || v_idioma
                     || ' and   ra.cramo = t.cramo ' || ' and   ra.cidioma = ' || v_idioma;
            v_txt := v_txt || v_txtramo || v_txtagente;
            v_txt := v_txt || ' order by 1';
            v_ntraza := 9999;

            IF v_txt IS NULL THEN
               v_txt := 'select 0 from dual';
            END IF;
      */
      RETURN v_txt;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_list777_linea1a;

   /*****************************************************************************************
      Descripcion: 518 - Listado radicador de siniestros

   *****************************************************************************************/
   FUNCTION f_518_cab
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_CONF.f_518_CAB';
      v_tparam       VARCHAR2(1000);
      v_ntraza       NUMBER := 0;
      v_sep          VARCHAR2(1) := ';';
      v_ret          VARCHAR2(1) := CHR(10);
      v_init         VARCHAR2(32000);
      v_ttexto       VARCHAR2(32000);
   BEGIN
      v_ttexto :=
         'SELECT
                f_axis_literales(800279 ,x.idi)  || '';'' || /* 1 N¿mero de siniestro */
                f_axis_literales(9906505 ,x.idi) || '';'' || /* 2 Numero de siniestros */
                f_axis_literales(101606 ,x.idi)  || '';'' || /* 3 A¿o ejercicio */
                f_axis_literales(9905622 ,x.idi) || '';'' || /* 4 N¿mero de P¿liza */
                f_axis_literales(9906506 ,x.idi) || '';'' || /* 5 Cod. Sucursal */
                f_axis_literales(9002202 ,x.idi) || '';'' || /* 6 Sucursal */
                f_axis_literales(100784  ,x.idi) || '';'' || /* 7 Ramo */
                f_axis_literales(9905562 ,x.idi) || '';'' || /* 8 Nombre Ramo */
                f_axis_literales(9906507 ,x.idi) || '';'' || /* 9 Cod. Ramo tecnico */
                f_axis_literales(9906508 ,x.idi) || '';'' || /* 10 Ramo tecnico */
                f_axis_literales(9906509 ,x.idi) || '';'' || /* 11 Cod. Ramo Super */
                f_axis_literales(101028 ,x.idi)  || '';'' || /* 12 Aseguado */
                f_axis_literales(9906510 ,x.idi) || '';'' || /* 13 Ide. Asegurado */
                f_axis_literales(101027 ,x.idi)  || '';'' || /* 14 Tomador */
                f_axis_literales(9906511 ,x.idi) || '';'' || /* 15 Ide. Tomador */
                f_axis_literales(9001911 ,x.idi) || '';'' || /* 16 Beneficiario */
                f_axis_literales(9906512 ,x.idi) || '';'' || /* 17 Ide. Beneficiario */
                f_axis_literales(9906513 ,x.idi) || '';'' || /* 18 Nombre del Siniestrado */
                f_axis_literales(9906514 ,x.idi) || '';'' || /* 19 Ide. del Siniestrado */
                f_axis_literales(9903363 ,x.idi) || '';'' || /* 20 Fecha aviso siniestro */
                f_axis_literales(110278 ,x.idi)  || '';'' || /* 21 Fecha de ocurrencia */
                f_axis_literales(9906515 ,x.idi) || '';'' || /* 22 Fecha de registro */
                f_axis_literales(9906516 ,x.idi) || '';'' || /* 23 Valor asegurado total */
                f_axis_literales(9906517 ,x.idi) || '';'' || /* 24 Vigencia afectada  */
                f_axis_literales(9903365 ,x.idi) || '';'' || /* 25 Amparo */
                f_axis_literales(108645 ,x.idi)  || '';'' || /* 26 Cod. Moneda  */
                f_axis_literales(9904960 ,x.idi) || '';'' || /* 27 Valor reserva  */
                f_axis_literales(100896 ,x.idi)  || '';'' || /* 28 Concepto  */
                f_axis_literales(9906518 ,x.idi) || '';'' || /* 29 Vlr. Calculado  */
                f_axis_literales(9907594, x.idi) || '';'' || /* 29b N¿ Movimientos del siniestro */
                f_axis_literales(9906519 ,x.idi) || '';'' || /* 30 Estado Movimiento  */
                f_axis_literales(9906520 ,x.idi) || '';'' || /* 31 Causa de Modificacion */
                f_axis_literales(9906521 ,x.idi) || '';'' || /* 32 Vlr pretension */
                f_axis_literales(9902930 ,x.idi) || '';'' || /* 33 Clave Intermediario */
                f_axis_literales(9906522 ,x.idi) || '';'' || /* 34 Reserva Parte Reaseg. */
                f_axis_literales(9906523 ,x.idi) || '';'' || /* 35 Reserva Parte Cia. */
                f_axis_literales(9906524 ,x.idi) || '';'' || /* 36 Tipo Exp. Pol. */
                f_axis_literales(9906525 ,x.idi) || '';'' || /* 37 Fec. Formalizado y/o Ult.Doc */
                f_axis_literales(101006 ,x.idi)  || '';'' || /* 38 Fec. Movimiento */
                f_axis_literales(9906526 ,x.idi) || '';'' || /* 39 Valor Movimiento */
                f_axis_literales(101573 ,x.idi)  || '';'' || /* 40 Fecha Pago */
                f_axis_literales(9906527 ,x.idi) || '';'' || /* 41 Valor Pago */
                f_axis_literales(9906528 ,x.idi) || '';'' || /* 42 Fecha Comp. Egreso */
                f_axis_literales(9906529 ,x.idi) || '';'' || /* 43 Nro. Comp. Egreso */
                f_axis_literales(9906530 ,x.idi) || '';'' || /* 44 Proceso S/N */
                f_axis_literales(9906531 ,x.idi) || '';'' || /* 45 Edad */
                f_axis_literales(100852 ,x.idi) || '';'' || /* 46 Causa del siniestro */
                f_axis_literales(109651 ,x.idi) || '';'' || /* 46b Motivo del siniestro */
                f_axis_literales(101162 ,x.idi)  || '';'' || /* 47 Observaciones */
                f_axis_literales(9906533 ,x.idi) || '';'' || /* 48 Vlr. Mvto. Reas. */
                f_axis_literales(100894 ,x.idi) || '';'' || /* 49 Usuario */
                f_axis_literales(9908108 ,x.idi) || '';'' || /* 50 Codigo Intermediario */
                f_axis_literales(9908109 ,x.idi) || '';'' || /* 51 Intermediario */
                ''''AS linea
                FROM (SELECT NVL(f_usu_idioma, 8) idi FROM DUAL) x, DUAL';
      RETURN v_ttexto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 from dual';
   END f_518_cab;

   /*****************************************************************************************
      Descripcion: 518 - Listado radicador de siniestros

      Par¿metres entrada:  - p_cidioma
                           - p_cempres
                           - fecha_desde
                           - fecha_hasta
                           - pcramo
                           - psproduc
         ':CEMPRES|:CIDIOMA|:FDESDE|:FHASTA|:CRAMO|:SPRODUC'
                  return:              text select detall
   *****************************************************************************************/
   FUNCTION f_518_det(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      fecha_desde IN VARCHAR2,
      fecha_hasta IN VARCHAR2,
      pcramo IN NUMBER,
      psproduc IN NUMBER)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_CONF.f_518_DET';
      v_tparam       VARCHAR2(1000)
         := 'pcempres : ' || pcempres || ' pcidioma: ' || pcidioma || ' fecha_desde= '
            || fecha_desde || ' fecha_hasta= ' || fecha_hasta || ' pcramo: ' || pcramo
            || ' psproduc: ' || psproduc;
      v_ntraza       NUMBER := 0;
      v_sep          VARCHAR2(50) := '||' || CHR(39) || ';' || CHR(39) || '||';
      v_ret          VARCHAR2(1) := CHR(10);
      v_ttexto       VARCHAR2(32000);
      v_mondes       VARCHAR2(50);
      v_emp          NUMBER;
      d_calini       DATE;
      d_calfin       DATE;
      v_fechaini     VARCHAR2(100);
      v_fechafin     VARCHAR2(100);
      v_tcramo       VARCHAR2(100);
      v_tsproduc     VARCHAR2(100);
   BEGIN
      v_ntraza := 1;
      v_ntraza := 2;
      -- PREPARAR FECHAS
      d_calini := TO_DATE(LPAD(fecha_desde, 8, '0'), 'ddmmyyyy');
      d_calfin := TO_DATE(LPAD(fecha_hasta, 8, '0'), 'ddmmyyyy');
      v_ntraza := 3;
      v_fechaini := 'to_date(' || CHR(39) || TO_CHAR(d_calini, 'ddmmyyyy') || CHR(39)
                    || ',''ddmmyyyy'')';
      v_fechafin := 'to_date(' || CHR(39) || TO_CHAR(d_calfin, 'ddmmyyyy') || CHR(39)
                    || ',''ddmmyyyy'')';
      v_ntraza := 4;

      -- Filtro por RAMO y PRODUCTO
      IF pcramo IS NOT NULL THEN
         v_tcramo := ' AND s.cramo = ' || pcramo;
      END IF;

      IF psproduc IS NOT NULL THEN
         v_tsproduc := ' AND s.sproduc = ' || psproduc;
      END IF;

      v_ntraza := 5;
      v_ttexto :=
         'SELECT TO_CHAR(si.NSINIES)' || v_sep
         || '(SELECT COUNT(DISTINCT x1.cgarant)
                      FROM sin_tramita_reserva x1
                     WHERE x1.nsinies = si.nsinies)'   /*2*/
         || v_sep || 'TO_CHAR(si.falta, ''yyyy'')' /*3*/ || v_sep
         || 'DECODE(s.ncertif, 0, to_char(s.npoliza), to_char(s.npoliza || ''-'' || s.ncertif))'   /*4*/
         || v_sep
         || 'DECODE(pac_redcomercial.f_busca_padre(s.cempres, s.cagente, 2, si.falta),
                     NULL, ''---'',
                     pac_redcomercial.f_busca_padre(s.cempres, s.cagente, 2, si.falta))'   /*5*/
         || v_sep
         || 'DECODE(pac_redcomercial.f_busca_padre(s.cempres, s.cagente, 2, si.falta),
                     NULL, ''---'',
                     ff_desagente(pac_redcomercial.f_busca_padre(s.cempres, s.cagente, 2, si.falta)))'   /*6*/
         || v_sep || 's.cramo' /*7*/ || v_sep || 'ff_desramo(s.cramo, ' || pcidioma || ')'   /*8*/
         || v_sep || 's.sproduc' || v_sep
         ||   /*9*/
           'f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, ' || pcidioma || ')'
         || v_sep ||   /*10*/
                    'SUBSTR(s.cramo, -2)' || v_sep
         ||   /*11*/
           'TRIM(dpa.TAPELLI1 || '' '' || dpa.TAPELLI2 || '', '' || dpa.TNOMBRE)' || v_sep
         ||   /*12*/
           'pa.nnumide' || v_sep
         ||   /*13*/
           'TRIM(dpt.TAPELLI1 || '' '' || dpt.TAPELLI2 || '', '' || dpt.TNOMBRE)' || v_sep
         ||   /*14*/
           'pt.nnumide' || v_sep
         ||   /*15*/
           'DECODE(pp.nnumide,
                NULL, NULL,
                TRIM(dpp.tapelli1 || '' '' || dpp.tapelli2 || '', '' || dpp.tnombre))'
         || v_sep ||   /*16*/
                    'pp.nnumide' || v_sep
         ||   /*17*/
           'DECODE(s.cobjase,
              1, (SELECT TRIM(pd1.TAPELLI1 || '' '' || pd1.TAPELLI2 || '', '' || pd1.TNOMBRE)
                    FROM per_personas p1, per_detper pd1
                   WHERE p1.sperson = r.sperson
                     AND pd1.sperson = r.sperson
                     AND pd1.cagente = ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres)),
              (SELECT TRIM(stpr.TAPELLI1 || '' '' || stpr.TAPELLI2 || '', '' || stpr.TNOMBRE)
                 FROM sin_tramita_personasrel stpr
                WHERE stpr.nsinies = si.nsinies
                  AND stpr.ctiprel = 4
                  AND stpr.ntramit = 0
                  AND stpr.npersrel = (SELECT MIN(npersrel)
                                         FROM sin_tramita_personasrel stpr2
                                        WHERE stpr2.nsinies = stpr.nsinies
                                          AND stpr2.ntramit = stpr.ntramit
                                          AND stpr2.ctiprel = stpr.ctiprel)))'
         || v_sep
         ||   /*18*/
           'DECODE(s.cobjase,
              1, (SELECT p1.nnumide
                    FROM per_personas p1, per_detper pd1
                   WHERE p1.sperson = r.sperson
                     AND pd1.sperson = r.sperson
                     AND pd1.cagente = ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres)),
              (SELECT stpr.nnumide
                 FROM sin_tramita_personasrel stpr
                WHERE stpr.nsinies = si.nsinies
                  AND stpr.ctiprel = 4
                  AND stpr.ntramit = 0
                  AND stpr.npersrel = (SELECT MIN(npersrel)
                                         FROM sin_tramita_personasrel stpr2
                                        WHERE stpr2.nsinies = stpr.nsinies
                                          AND stpr2.ntramit = stpr.ntramit
                                          AND stpr2.ctiprel = stpr.ctiprel)))'
         || v_sep ||   /*19*/
                    'TO_CHAR(si.fnotifi, ''dd/mm/yyyy'')' || v_sep
         ||   /*20*/
           'TO_CHAR(si.fsinies, ''dd/mm/yyyy hh24:mi'')' || v_sep
         ||   /*21*/
           'TO_CHAR(si.falta, ''dd/mm/yyyy'')' || v_sep
         ||   /*22*/
           '(SELECT aux_g.icapital
                     FROM garanseg aux_g
                    WHERE aux_g.cgarant = str.cgarant
                      AND aux_g.sseguro = si.sseguro
                      AND aux_g.nriesgo = si.nriesgo
                      AND aux_g.nmovimi IN(SELECT MIN(mm.nmovimi)
                                             FROM garanseg mm
                                            WHERE mm.cgarant = str.cgarant
                                              AND mm.sseguro = si.sseguro
                                              AND mm.nriesgo = si.nriesgo
                                              AND mm.finiefe < si.fsinies))'
         || v_sep ||   /*23*/
                    'ff_desvalorfijo(54, ' || pcidioma || ' , TO_CHAR(si.fsinies, ''mm''))'
         || v_sep ||   /*24*/
                    'ff_desgarantia(str.cgarant, ' || pcidioma
         || ')
                    || DECODE(NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi, str.cgarant, ''BAJA''),0), 1, '' ('' || str.fresini || '' al '' || str.fresfin || '')'', null)'
         || v_sep ||   /*25*/
                    'str.cmonres' || v_sep ||   /*26*/
                                             'str.ireserva_moncia' || v_sep
         ||   /*27*/
           'DECODE(str.ctipres,
                     3, ff_desvalorfijo(322, ' || pcidioma
         || ', str.ctipres) || '' - '' || ff_desvalorfijo(1047, ' || pcidioma
         || ', str.ctipgas),
                     ff_desvalorfijo(322, ' || pcidioma || ', str.ctipres))' || v_sep
         ||   /*28*/
           '(NVL(str.ireserva_moncia, 0)
              - NVL((SELECT NVL(ant.ireserva_moncia, 0)
                       FROM sin_tramita_reserva ant
                      WHERE ant.nsinies = str.nsinies
                        AND ant.idres = str.idres
                        AND ant.nmovres = (SELECT MAX(nmovres)
                                             FROM sin_tramita_reserva
                                            WHERE nsinies = ant.nsinies
                                              AND idres = ant.idres
                                              AND nmovres < str.nmovres)),0))'
         || v_sep ||   /*29*/
                    'str.nmovres' || v_sep ||   /*29b*/
                                             'ff_desvalorfijo(1142, ' || pcidioma
         || ', (pac_informes_CONF.F_GET_ESTADOMOVRESERVA(str.nsinies, str.ntramit, str.ctipres, str.nmovres, str.cgarant, str.idres)))'
         || v_sep ||   /*30*/
                    'ff_desvalorfijo(1143, ' || pcidioma
         || ', (pac_informes_CONF.F_GET_CAUSAMODRESERVA(str.nsinies, str.ntramit, str.ctipres, str.nmovres, str.cgarant, str.idres)))'
         || v_sep ||   /*31*/
                    'si.iperit' || v_sep ||   /*32*/
                                           'si.cagente' || v_sep
         ||   /*33*/
           'decode(s.ctiprea, 2, 0, f_round(str.ireserva_moncia * ((100 - pac_informes_CONF.f_plocal_rea_coa(si.sseguro, si.fsinies, si.nriesgo, str.cgarant)) / 100)))'
         || v_sep
         ||   /*34*/
           'f_round(str.ireserva_moncia * (pac_informes_CONF.f_plocal_rea_coa(si.sseguro, si.fsinies, si.nriesgo, str.cgarant) / 100))'
         || v_sep
         ||   /*35*/
           'DECODE (NVL(s.CTIPCOA,0), 1, ''Coaseguro cedido'', 8, ''Coaseguro aceptado'', ''Contratacion directa'')'
         || v_sep
         ||   /*36*/
           '(SELECT TO_CHAR(MAX(std.frecibe), ''dd/mm/yyyy'')
                     FROM SIN_TRAMITA_DOCUMENTO std
                    WHERE std.nsinies = str.nsinies
                      AND std.ntramit = str.ntramit
                      AND std.ndocume = (SELECT MAX(ndocume)
                                           FROM sin_tramita_documento
                                          WHERE nsinies = std.nsinies
                                            AND ntramit = std.ntramit
                                            AND cdocume = 521))'
         || v_sep ||   /*37*/
                    '(TO_CHAR(str.fmovres, ''dd/mm/yyyy'')' || v_sep
         ||   /*38*/
           'DECODE(str.CMOVRES, 6, 0
                           , 7, 0
                           , 8, 0
                           , 16, 0
                           , 17, 0
                           , 18, 0
                           , 19, 0
                           ,(ABS((NVL(str.ireserva_moncia, 0))
                         - NVL((SELECT NVL(ant.ireserva_moncia, 0)
                                   FROM sin_tramita_reserva ant
                                  WHERE ant.nsinies = str.nsinies
                                    AND ant.idres = str.idres
                                    AND ant.nmovres = (SELECT MAX(nmovres)
                                                         FROM sin_tramita_reserva
                                                        WHERE nsinies = ant.nsinies
                                                          AND idres = ant.idres
                                                          AND nmovres < str.nmovres)),0)
                                                          )) * DECODE(str.cmovres, 5, -1, 1)))'
         || v_sep ||   /*39*/
                    'TO_CHAR(stp_pagos.fordpag, ''dd/mm/yyyy'')' || v_sep
         ||   /*40*/
           'DECODE ((SELECT stmp.cestpag
                  FROM sin_tramita_movpago stmp
                 WHERE stmp.sidepag = str.sidepag
                   AND stmp.nmovpag IN(SELECT MAX(nmovpag)
                                         FROM sin_tramita_movpago
                                        WHERE sidepag = str.sidepag
                                          AND falta <= str.fmovres))
               , 8, 0
               , stp_pagos.isinret)'
         || v_sep ||   /*41*/
                    'TO_CHAR(stmp_confirmados.fefepag, ''dd/mm/yyyy'')' || v_sep
         ||   /*42*/
           'stp_pagos.sidepag' || v_sep ||   /*43*/
                                          'DECODE(st.ctramit, 11, ''PJ'', ''PN'')' || v_sep
         ||   /*44*/
           'DECODE(s.cobjase,
              1, (SELECT TRUNC(MONTHS_BETWEEN(si.fsinies, p1.fnacimi)/12,0)
                    FROM per_personas p1, per_detper pd1
                   WHERE p1.sperson = r.sperson
                     AND pd1.sperson = r.sperson
                     AND pd1.cagente = ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres)),
              (SELECT TRUNC(MONTHS_BETWEEN(si.fsinies, p2.fnacimi)/12,0)
                 FROM per_personas p2, sin_tramita_personasrel stpr
                WHERE p2.sperson = stpr.sperson
                  AND stpr.nsinies = si.nsinies
                  AND stpr.ctiprel = 4
                  AND stpr.ntramit = 0
                  AND stpr.npersrel = (SELECT MIN(npersrel)
                                         FROM sin_tramita_personasrel stpr2
                                        WHERE stpr2.nsinies = stpr.nsinies
                                          AND stpr2.ntramit = stpr.ntramit
                                          AND stpr2.ctiprel = stpr.ctiprel)))'
         || v_sep ||   /*45*/
                    'PAC_INFORMES_CONF.f_descausin(si.ccausin , ' || pcidioma || ')' || v_sep
         ||   /*46*/
           'PAC_INFORMES_CONF.f_desmotsin(si.ccausin , si.cmotsin, ' || pcidioma || ')' || v_sep
         ||   /*46b*/
           'stp_pagos.nfacref' || v_sep
         ||   /*47*/
           'NVL2(str.sidepag, (select F_ROUND(NVL(sum(icesion),0)) from cesionesrea where nsinies = str.nsinies and sidepag = str.sidepag and ncesion <> 0), NULL)'
         || v_sep ||   /*48*/
                    'str.cusualt '   /*49*/
                                  || v_sep || 'NVL(si.cagente, s.cagente)' || v_sep
         || /*50*/ 'f_desagente_t(NVL(si.cagente, s.cagente))' /*51*/;
      -- FROM
      v_ttexto :=
         v_ttexto
         || ' FROM
              SIN_SINIESTRO si,
              SEGUROS s,
              PRODUCTOS prod,
              RIESGOS r,
              PER_PERSONAS pa, PER_PERSONAS pt, PER_PERSONAS pp,
              PER_DETPER dpa, PER_DETPER dpt, PER_DETPER dpp,
              TOMADORES t,
              ASEGURADOS a,
              SIN_TRAMITACION st,
              SIN_TRAMITA_RESERVA str,
              SIN_TRAMITA_PAGO stp_pagos,
              SIN_TRAMITA_MOVPAGO stmp_confirmados
            ';
      -- JOIN
      v_ttexto :=
         v_ttexto || ' WHERE TRUNC(si.falta) >= ' || v_fechaini || ' AND TRUNC(si.falta) <= '
         || v_fechafin || ' AND s.sseguro = si.sseguro            /* join amb SEGUROS */'
         || v_tcramo || v_tsproduc
         || ' AND prod.sproduc = s.sproduc          /* joim amb PRODUCTOS */
             AND r.sseguro = si.sseguro            /* join amb RIESGOS */
             AND r.nriesgo = si.nriesgo            /* join amb ASSEGURAT */
             AND a.sseguro = si.sseguro
             AND a.norden = 1
             AND pa.sperson = a.sperson
             AND dpa.sperson = a.sperson
             AND dpa.cagente = ff_agente_cpervisio(s.cagente, f_sysdate, s.CEMPRES)
             AND t.sseguro = s.sseguro             /* join amb TOMADORES */
             AND t.nordtom = 1
             AND pt.sperson = t.sperson
             AND dpt.sperson = t.sperson
             AND dpt.cagente = ff_agente_cpervisio(s.cagente, f_sysdate, s.CEMPRES)
             AND st.nsinies = si.nsinies            /* join amb SIN_TRAMITA_RESERVAS */
             AND st.cinform = 0
             AND str.nsinies = st.nsinies
             AND str.ntramit = st.ntramit
             AND stp_pagos.sidepag (+) = str.sidepag     /* join amb la taula de PAGOS */
             AND pp.sperson(+) = stp_pagos.sperson   /* join amb DESTINATARI */
             AND dpp.sperson(+) = stp_pagos.sperson
             AND stmp_confirmados.sidepag (+) = str.sidepag      /* join amb la taula de PAGOS CONFIRMADOS */
             AND stmp_confirmados.cestpag (+) = 2 ORDER BY str.nsinies, str.idres, str.nmovres ';
      RETURN v_ttexto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 'select 1 linea from dual';
   END f_518_det;

   /*****************************************************************************************
      Descripcion: Develve la causa de modificacion/variacion de la reserva.

      A partir de los dos ultimos movimientos de la reserva y el estado del siniestro
      se determina que tipo de operaci¿n se ha realizado con la reserva.

      VALORES vf: 1143

   *****************************************************************************************/
   FUNCTION f_get_causamodreserva(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pctipres IN NUMBER,
      pnmovres IN NUMBER,
      pcgarant IN NUMBER,
      pidres IN NUMBER)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(500) := 'pac_informes_CONF.F_get_causamodreserva';
      v_tparam       VARCHAR2(500)
         := 'pnsinies: ' || pnsinies || ' pntramit ' || pntramit || ' pctipres ' || pctipres
            || ' pnmovres ' || pnmovres || ' pcgarant ' || pcgarant || ' pidres ' || pidres;
      v_ntraza       NUMBER := 0;
      v_movact       sin_tramita_reserva%ROWTYPE := NULL;
      v_movant       sin_tramita_reserva%ROWTYPE := NULL;
      v_aux          sin_tramita_reserva%ROWTYPE;
      v_cestsin      sin_movsiniestro.cestsin%TYPE;
      v_ccauest      sin_movsiniestro.ccauest%TYPE;
      v_cultpag      sin_tramita_pago.cultpag%TYPE;
      v_codi         NUMBER := NULL;
   BEGIN
      -- Recuperem el moviment actual
      v_ntraza := 1;

      -- Bug 35599 - 11/05/2015 - JTT: Usamos idres para acceder a la reserva en lugar de CTIPRES, CGARANT, ...
      BEGIN
         SELECT *
           INTO v_movact
           FROM sin_tramita_reserva
          WHERE nsinies = pnsinies
            AND nmovres = pnmovres
            AND idres = pidres;
      END;

      -- Recuperem el moviment anterior
      v_ntraza := 2;

      BEGIN
         SELECT s.*
           INTO v_movant
           FROM sin_tramita_reserva s
          WHERE s.nsinies = pnsinies
            AND s.nmovres IN(SELECT MAX(a.nmovres)
                               FROM sin_tramita_reserva a
                              WHERE a.nsinies = pnsinies
                                AND a.nmovres < pnmovres
                                AND a.idres = pidres)
            AND s.idres = pidres;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            -- Si no hay movimientos anterior se trata de constintucion de reserva (1)
            v_movant := NULL;
            RETURN 1;   -- Constitucion de reserva
      END;

      /*
         Obtenim l'estat i la causa del estat del sinistre
      */
      v_ntraza := 3;

      BEGIN
         -- Bug 35599 - 11/05/2015 - JTT: Buscamos si existe un movimiento del siniestro proximo en fechas al movimiento de la reserva
         SELECT s.cestsin, s.ccauest
           INTO v_cestsin, v_ccauest
           FROM sin_movsiniestro s
          WHERE s.nsinies = pnsinies
            AND s.nmovsin IN(SELECT MIN(nmovsin)
                               FROM sin_movsiniestro aux
                              WHERE aux.nsinies = s.nsinies
                                AND aux.festsin BETWEEN v_movact.fmovres
                                                    AND(v_movact.fmovres +(2 / 1440)));   -- +2 min.
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_cestsin := NULL;
            v_ccauest := NULL;
      END;

      /*
         Liberacion de reserva, cmovres = 6, 7 ¿ 8
      */
      v_ntraza := 5;

      IF v_movact.ireserva = 0
         AND v_movact.cmovres IN(6, 7, 8) THEN
         IF v_cestsin = 3 THEN   -- Rechazado del siniestro
            RETURN 40;
         ELSIF v_cestsin = 2 THEN   -- Anulacion del siniestro
            RETURN 21;
         ELSIF v_cestsin IN(1, 4) THEN   -- Finalizado
            v_codi := 10;   -- Cierre generico

            IF v_ccauest = 1 THEN
               v_codi := 31;   -- Liberacion por pago total
            ELSIF v_ccauest = 2 THEN
               v_codi := 32;   -- Liberacion por prescripcion
            ELSIF v_ccauest = 3 THEN
               v_codi := 33;   -- Liberacion por desistimiento
            END IF;

            RETURN v_codi;
         END IF;
      END IF;

      /*
         Disminucion de reserva
      */
      v_ntraza := 6;

      IF v_movact.ireserva < v_movant.ireserva THEN
         v_codi := 20;   -- Disminucion generica de la reserva

         IF (v_movact.sidepag IS NOT NULL
             AND v_movact.ipago > 0) THEN

            v_ntraza := 61;

            SELECT NVL(cultpag, 0)
              INTO v_cultpag
              FROM sin_tramita_pago
             WHERE nsinies = v_movact.nsinies
               AND sidepag = v_movact.sidepag;

             IF v_cultpag = 1 THEN
                v_codi := 24;   -- Disminucion por pago total
             ELSE
                v_codi := 22;   -- Disminucion por pago
             END IF;
         END IF;

         RETURN v_codi;
      END IF;

      /*
         Aumentos de reserva
      */
      v_ntraza := 7;

      IF v_movact.ireserva > v_movant.ireserva THEN
         v_codi := 02;   -- Aumento generico

         IF v_movact.ctipres = 3 THEN
            v_codi := 3;   -- Aumento por gastos
         ELSIF(v_movant.ireserva = 0
               AND v_cestsin = 4) THEN
            v_codi := 10;   -- Reapertura generica

            IF v_ccauest = 18 THEN
               v_codi := 11;   --  Reapertura per error
            ELSIF v_ccauest = 13 THEN
               v_codi := 12;   -- Reapertura por pago comercial
            ELSIF v_ccauest = 16 THEN
               v_codi := 13;   -- Reapertura por reconsideracion
            END IF;
         END IF;

         IF (v_movact.sidepag IS NOT NULL
             AND v_movact.ipago = 0) THEN
            v_codi := 14;   -- Aumento por anulacion del pago
         END IF;

         RETURN v_codi;
      END IF;

      /*
         Si no hay variacion de la reserva deberia tratarse de un movimiento de contravalor
         de la reserva, la fecha de cambio deberia ser diferente.
      */
      v_ntraza := 8;

      IF (v_movact.ireserva = v_movant.ireserva
          AND v_movact.fcambio <> v_movant.fcambio) THEN
         IF v_movact.ireserva_moncia >= v_movant.ireserva_moncia THEN
            RETURN 15;
         ELSE
            RETURN 23;
         END IF;
      END IF;

      RETURN v_codi;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN -1;
   END f_get_causamodreserva;

   /*****************************************************************************************
      Descripcion: Develve que ha causado el movimiento de la reserva.

      A partir de la causa de movimiento de la reserava se determina que ha causado esa
      variacion.

      VALORES vf: 1142

   *****************************************************************************************/
   FUNCTION f_get_estadomovreserva(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pctipres IN NUMBER,
      pnmovres IN NUMBER,
      pcgarant IN NUMBER,
      pidres IN NUMBER)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(500) := 'pac_informes_CONF.F_get_estadomovreserva';
      v_tparam       VARCHAR2(500)
         := 'pnsinies: ' || pnsinies || ' pntramit ' || pntramit || ' pctipres ' || pctipres
            || ' pnmovres ' || pnmovres || ' pcgarant ' || pcgarant || ' pidres ' || pidres;
      v_ntraza       NUMBER := 1;
      v_ccaumod      NUMBER;
      v_valor        NUMBER := 12;   -- Per defecte 'Modificaci¿n reserva'
   BEGIN
      v_ntraza := 1;
      v_ccaumod := f_get_causamodreserva(pnsinies, pntramit, pctipres, pnmovres, pcgarant,
                                         pidres);
      p_control_error('JORDI', 'f_get_estadomovreserva', 'v_ccaumod: ' || v_ccaumod);
      v_ntraza := 2;

      IF v_ccaumod = 1 THEN
         v_valor := 1;   -- Aviso
      ELSIF v_ccaumod IN(10, 11, 12, 13) THEN
         v_valor := 2;   -- Reactivacion
      ELSIF v_ccaumod = 22 THEN
         v_valor := 3;   -- Pago parcial
      ELSIF v_ccaumod = 24 THEN
         v_valor := 4;   -- Pago total
      ELSIF v_ccaumod = 14 THEN
         v_valor := 11;   -- Pago parcial
      ELSIF v_ccaumod IN(4, 31) THEN
         v_valor := 4;   -- Pago total
      ELSIF v_ccaumod IN(15, 23) THEN
         v_valor := 5;   -- Proceso automatico
      ELSIF v_ccaumod = 30 THEN
         v_valor := 6;   -- Finalizacion
      ELSIF v_ccaumod = 33 THEN
         v_valor := 7;   -- Desistido
      ELSIF v_ccaumod = 40 THEN
         v_valor := 8;   -- Objetado
      ELSIF v_ccaumod = 32 THEN
         v_valor := 9;   -- Precripcion
      ELSIF v_ccaumod = 21 THEN
         v_valor := 10;   -- Anulado
      END IF;

      RETURN v_valor;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN -1;
   END f_get_estadomovreserva;

   /*****************************************************************************************
      Descripcion: Indica si es un Amparao de muerte
   *****************************************************************************************/
   FUNCTION f_esamparodemuerte(psproduc IN NUMBER, pcgarant IN NUMBER)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(500) := 'pac_informes_CONF.F_esamparodemuerte';
      v_tparam       VARCHAR2(500) := 'psproduc: ' || psproduc || ' pcgarant' || pcgarant;
      v_ntraza       NUMBER := 1;
      v_count        NUMBER := 0;
   BEGIN
      SELECT COUNT(*)
        INTO v_count
        FROM pargaranpro
       WHERE cpargar = 'MUERTE'
         AND sproduc = psproduc
         AND cgarant = pcgarant;

      IF v_count > 0 THEN
         RETURN 1;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN -1;
   END f_esamparodemuerte;

   /*****************************************************************************************
      Descripcion: Devuelve la descripcion de la causa del siniestro
   *****************************************************************************************/
   FUNCTION f_descausin(pccausin IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(500) := 'pac_informes_CONF.F_descausin';
      v_tparam       VARCHAR2(500) := 'pccausin: ' || pccausin || ' pcidioma ' || pcidioma;
      v_ntraza       NUMBER := 1;
      vttexto        sin_descausa.tcausin%TYPE;
   BEGIN
      SELECT tcausin
        INTO vttexto
        FROM sin_descausa
       WHERE ccausin = pccausin
         AND cidioma = pcidioma;

      RETURN vttexto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN NULL;
   END f_descausin;

   /*****************************************************************************************
      Descripcion: Devuelve la descripcion del motivo del siniestro
   *****************************************************************************************/
   FUNCTION f_desmotsin(pccausin IN NUMBER, pcmotsin IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      v_tobjeto      VARCHAR2(500) := 'pac_informes_CONF.F_desmotsin';
      v_tparam       VARCHAR2(500)
         := 'pccausin: ' || pccausin || ' pcmotsin: ' || pcmotsin || ' pcidioma: ' || pcidioma;
      v_ntraza       NUMBER := 1;
      vttexto        sin_desmotcau.tmotsin%TYPE;
   BEGIN
      SELECT tmotsin
        INTO vttexto
        FROM sin_desmotcau
       WHERE ccausin = pccausin
         AND cmotsin = pcmotsin
         AND cidioma = pcidioma;

      RETURN vttexto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN NULL;
   END f_desmotsin;

   /*****************************************************************************************
      Descripcion: Devuelve la parte de la reserva (en la moneda de la Cia) reasegurada.

      Nota: Esta funcion ha sido copiada de PAC_INFORMES_RSA.f_get_cesiones_pesos_r que
      realiza la misma funcion.

   *****************************************************************************************/
   FUNCTION f_get_reserva_rea_moncia(
      pnsinies IN VARCHAR2,
      pcgarant IN NUMBER,
      pfdesde IN DATE,
      pfhasta IN DATE)
      RETURN NUMBER IS
      v_ttexto       VARCHAR2(100) := '';
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_CONF.f_get_reserva_rea_moncia';
      v_tparam       VARCHAR2(1000);
      v_ntraza       NUMBER := 0;
      vsum           NUMBER := 0;
      vtotal         NUMBER := 0;
   BEGIN
      SELECT NVL(SUM(icompan_moncon), 0)
        INTO vtotal
        FROM liqresreaaux lq
       WHERE nsinies = pnsinies
         AND cgarant = pcgarant
         AND fcierre = (SELECT MAX(fcierre)
                          FROM liqresreaaux lq1
                         WHERE nsinies = lq1.nsinies
                           AND cgarant = lq1.cgarant
                           AND fcierre BETWEEN pfdesde AND pfhasta);

      RETURN vtotal;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 0;
   END;

   /*****************************************************************************************
      Descripcion: Devuelve el valor cedido (en la moneda de la Cia) a al reasegurador.

      Nota: Esta funcion ha sido copiada de PAC_LISTADOS_RSA.f_get_cesiones_pesos que
      realiza la misma funcion.
   *****************************************************************************************/
   FUNCTION f_get_cesiones_moncia(pnsinies IN VARCHAR2, pfdesde IN DATE, pfhasta IN DATE)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_CONF.f_get_cesiones_moncia';
      v_tparam       VARCHAR2(1000);
      v_ntraza       NUMBER := 0;
      vsum           NUMBER := 0;
      vtotal         NUMBER := 0;
   BEGIN
      SELECT SUM(icesion_moncon)
        INTO vtotal
        FROM reaseguro
       WHERE nsinies = pnsinies
         AND fcierre BETWEEN pfdesde AND pfhasta
         AND cgenera = 2;

      RETURN vtotal;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         RETURN 0;
   END;

   /*****************************************************************************************
      Descripcion: Devuelve el % del coaseguro correspondiente a la Cia
   *****************************************************************************************/
   FUNCTION f_plocal_coa(
      psseguro IN sin_siniestro.sseguro%TYPE,
      pfsinies IN sin_siniestro.fsinies%TYPE,
      pnriesgo IN sin_siniestro.nriesgo%TYPE,
      pcgarant IN sin_tramita_reserva.cgarant%TYPE)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_CONF.f_plocal_coa';
      v_ntraza       NUMBER;
      v_tparam       VARCHAR2(1000)
         := 'psseguro: ' || psseguro || ' pfsinies: ' || pfsinies || ' pnriesgo: ' || pnriesgo
            || ' pcgarant: ' || pcgarant;
      v_plocal_coaseguro NUMBER;   -- Coaseuro
   BEGIN
      v_ntraza := 1;

      -- Calculo del % de Coaseguro correspondiente a la Cia
      -- Coaseguro cedido --> ploccoa
      -- Coaseguro aceptado --> 100%
      BEGIN
         SELECT DECODE(s.ctipcoa, 1, ploccoa, 8, 100, 0)
           INTO v_plocal_coaseguro
           FROM coacuadro c, seguros s
          WHERE c.sseguro = s.sseguro
            AND c.sseguro = psseguro
            AND c.ncuacoa = (SELECT MAX(ncuacoa)
                               FROM coacuadro
                              WHERE sseguro = c.sseguro
                                AND finicoa < pfsinies
                                AND(ffincoa IS NULL
                                    OR ffincoa > pfsinies));
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_plocal_coaseguro := 100;
      END;

      RETURN v_plocal_coaseguro;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza,
                     ' v_plocal_coaseguro: ' || v_plocal_coaseguro, SQLERRM);
         RETURN 0;
   END f_plocal_coa;

   /*****************************************************************************************
      Descripcion: Devuelve el % del reaseguro correspondiente a la Cia.
   *****************************************************************************************/
   FUNCTION f_plocal_rea(
      psseguro IN sin_siniestro.sseguro%TYPE,
      pfsinies IN sin_siniestro.fsinies%TYPE,
      pnriesgo IN sin_siniestro.nriesgo%TYPE,
      pcgarant IN sin_tramita_reserva.cgarant%TYPE)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_CONF.f_plocal_rea';
      v_ntraza       NUMBER;
      v_tparam       VARCHAR2(1000)
         := 'psseguro: ' || psseguro || ' pfsinies: ' || pfsinies || ' pnriesgo: ' || pnriesgo
            || ' pcgarant: ' || pcgarant;
      v_plocal_total NUMBER;   -- Total a retornar
      v_plocal_ctr_reten NUMBER;   -- Plen net de retenci¿
      v_plocal_facult NUMBER;   -- Facultatiu
      v_plocal_ctr_qp NUMBER;   -- contracte QT i d'altres amb retenci¿.
      v_plocal_coaseguro NUMBER;   -- Coaseuro

      CURSOR c_tramo(
         sseguro_c1 IN NUMBER,
         pfsinies_c1 IN DATE,
         pnriesgo_c1 IN NUMBER,
         pcgarant_c1 IN NUMBER) IS
         SELECT scontra, nversio, ctramo, sfacult, pcesion, sseguro
           FROM cesionesrea
          WHERE sseguro = sseguro_c1
            AND cgenera IN(1, 3, 4, 5, 9, 40)
            AND nriesgo = pnriesgo_c1
            AND cgarant IS NOT NULL
            AND cgarant = pcgarant_c1
            AND fefecto <= pfsinies_c1
            AND fvencim > pfsinies_c1
            AND(fregula IS NULL
                OR fregula > pfsinies_c1)
            AND(fanulac IS NULL
                OR fanulac > pfsinies_c1)
            AND ctramo < 6;
   BEGIN
      v_ntraza := 1;
      -- Calculo del % de reaseguro correspondiente a la Cia
      v_plocal_total := 100;
      v_plocal_ctr_reten := 0;
      v_plocal_facult := 0;
      v_plocal_ctr_qp := 0;

      FOR reg IN c_tramo(psseguro, pfsinies, pnriesgo, pcgarant) LOOP
         IF reg.ctramo = 0 THEN
            v_plocal_ctr_reten := reg.pcesion;
         ELSIF reg.ctramo = 5 THEN
            v_ntraza := 2;

            SELECT NVL(plocal, 0) * reg.pcesion / 100
              INTO v_plocal_facult
              FROM cuafacul
             WHERE sfacult = reg.sfacult;
         ELSE
            v_ntraza := 3;

            SELECT NVL(plocal, 0) * reg.pcesion / 100
              INTO v_plocal_ctr_qp
              FROM tramos
             WHERE scontra = reg.scontra
               AND nversio = reg.nversio
               AND ctramo = reg.ctramo;
         END IF;
      END LOOP;

      v_ntraza := 4;

      IF v_plocal_ctr_reten > 0
         OR v_plocal_facult > 0
         OR v_plocal_ctr_qp > 0 THEN
         v_plocal_total := v_plocal_ctr_reten + v_plocal_facult + v_plocal_ctr_qp;
      END IF;

      v_ntraza := 5;
      RETURN v_plocal_total;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza,
                     'v_plocal_ctr_reten: ' || v_plocal_ctr_reten || ' v_plocal_facult: '
                     || v_plocal_facult || ' v_plocal_ctr_qp: ' || v_plocal_ctr_qp
                     || ' v_plocal_coaseguro: ' || v_plocal_coaseguro,
                     SQLERRM);
         RETURN 0;
   END f_plocal_rea;

   /*****************************************************************************************
      Descripcion: Devuelve el % del reaseguro correspondiente a la Cia
      teniendo en centa la parte del Coaseguro local
   *****************************************************************************************/
   FUNCTION f_plocal_rea_coa(
      psseguro IN sin_siniestro.sseguro%TYPE,
      pfsinies IN sin_siniestro.fsinies%TYPE,
      pnriesgo IN sin_siniestro.nriesgo%TYPE,
      pcgarant IN sin_tramita_reserva.cgarant%TYPE)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES_CONF.f_plocal_rea_coa';
      v_ntraza       NUMBER;
      v_tparam       VARCHAR2(1000)
         := 'psseguro: ' || psseguro || ' pfsinies: ' || pfsinies || ' pnriesgo: ' || pnriesgo
            || ' pcgarant: ' || pcgarant;
      v_plocal_rea   NUMBER;   -- % Reaseguro local
      v_plocal_coa   NUMBER;   -- % Coaseguro local
      v_plocal_total NUMBER;
   BEGIN
      v_ntraza := 1;
      v_plocal_coa := f_plocal_coa(psseguro, pfsinies, pnriesgo, pcgarant);
      v_ntraza := 3;
      v_plocal_rea := f_plocal_rea(psseguro, pfsinies, pnriesgo, pcgarant);
      v_ntraza := 3;
      v_plocal_total := v_plocal_rea * v_plocal_coa / 100;
      RETURN v_plocal_total;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
                     SQLERRM);
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza,
                     'v_plocal_coa: ' || v_plocal_coa || ' v_plocal_rea: ' || v_plocal_rea,
                     SQLERRM);
         RETURN 0;
   END f_plocal_rea_coa;
END pac_informes_conf;

/

  GRANT EXECUTE ON "AXIS"."PAC_INFORMES_CONF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_INFORMES_CONF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_INFORMES_CONF" TO "PROGRAMADORESCSI";
