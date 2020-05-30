--------------------------------------------------------
--  DDL for Package Body PAC_INFORMES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_INFORMES" IS

/******************************************************************************
   NOMBRE:      PAC_INFORMES


   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        29/11/2010   JMF               1. 0016529 CRT003 - Análisis listados
   2.0        28/12/2010   JMF               2. 0016529 CRT003 - Análisis listados
   3.0        21/02/2011   JMF               3. 0016529 CRT003 - Análisis listados
   4.0        16/06/2011   JMF               3. 0016529 CRT003 - Análisis listados
   5.0        26/07/2011   JMF               4. 0018819 CRT003 - Corrección Listados Administración y producción
   6.0        24/10/2011   JMC               6. 0019844: AGM003-Listado Indicadores de Negocio
   7.0        08/11/2011   APD               7. 0018946: LCOL_P001 - PER - Visibilidad en personas
   8.0        18/11/2011   FAL               8. 0019794: 0019794: CRT003 - Informes de Negocio
   9.0        12/12/2011   MDS               9. 0020101: LCOL898 - Financiero - Producci?n Mensual de comisiones
  10.0        14/12/2011   FAL              10. 0020531: facturación de previsión( planes de pensiones y ppa)
  11.0        15/12/2011   MDS              11. 0020102: LCOL898 - Interface - Financiero - Carga de Comisiones Liquidadas
  12.0        10/01/2012   MDS              12. 0020105: LCOL898 - Interfaces - Regulatorio - Reporte Encuesta Fasecolda
  13.0        10/01/2012   MDS              13. 0020106: LCOL898 - Interfaces - Regulatorio - Reporte Siniestros Radicados Fasecolda
  14.0        01/02/2012   MDS              14. 0021128: LCOL898- UAT - Errores Interfase Produccion Mensual de Comisiones
  15.0        17/02/2012   ETM              15. 0020107: LCOL898 - Interfaces - Regulatorio - Reporte Reservas Superfinanciera
  16.0        06/03/2012   MDS              16. 0021587: LCOL898- UAT - Errores Interfase Produccion Mensual de Comisiones
  17.0        16/04/2012   JMF              0021974: LCOL898-UAT- error en la interficie de comisiones liquidadas
  18.0        15/06/2012   ETM              18.0022517: MdP - TEC - Listado de detalle de primas
  19.0        14/08/2012   MCA              19.0023361: LCOL-Interface de comisiones
  20.0        04/09/2012   MCA              20.0023591: LCOL-Interface de comisiones
  21.0        07/12/2012   ECP              21.0025024: LCOL897- QT4345 - Reporte Supefinanciera
  22.0        15/01/2013   ECP              22.0025688: LCOL: Q-trackers de Fase 2. Liquidación de comisiones.
  23.0        03/04/2013   ECP              23.0026315: LCOL: Interface de producci?n de comisiones
  24.0        13/05/2013   MCA              24.0026911: lcol: Ajuste ejecución Comisiones liquidadas y producción de comisiones Bug 26904
  25.0        26/08/2014   JMG              25.0032496:0014037 LCOL896-Soporte a cliente en Liberty (Agosto 2014)- : INFORME DE PRODUCCION
  26.0        25/11/2014   AQ               26.0033287: CALI300-CALI - Revisions comptabilitat
  27.0        09/12/2014   RDD              27.0032603: MSV0003-MSV : nombre de ficheros en castellano
  28.0        15/05/2015   KJSC             28.0035181: PROCESO ESPECIFICO DE LA EMPRESA
  29.0        27/05/2015   KJSC             29.0036231 205726 Listado administraciòn
  30.0        10/11/2015   KJSC             30.0038508 Agregar campo CLEA
  31.0        12/04/2016   ACL              31.0040364 Soporte Positiva, Ajuste en informes Listado previo cartera y Listado previo renovación cartera
******************************************************************************/

   /******************************************************************************************
     Descripció: Funció que genera texte select detall per llistat (map 415 dinamic)
     Paràmetres entrada: - p_cinforme    -> codigo informe (detvalor 1021)
                         - p_cidioma     -> codigo idioma
                         - p_cempres     -> codigo empresa
                         - p_finiefe     -> fecha inicio
                         - p_ffinefe     -> fecha final
                         - p_ctipage     -> Tipo (detvalor 1022) (tipo agente)
                         - p_cagente     -> codigo en funcion del tipo (zona, oficina, agente)
                         - p_sperson     -> codigo cliente
                         - p_cnegocio    -> Negocio (detvalor 1023)
                         - p_codigosn    -> Codigos de negocio (separados por comas)
                         - p_sproduc     -> Producto de la actividad
     return:             texte select detall
   ******************************************************************************************/
   v_ttexto       VARCHAR2(32000);
   v_text_total   VARCHAR2(32000);   /* Bug 0019794 - 18/11/2011 - FAL*/
   v_ttexto_exclu VARCHAR2(32000);   /* 19794*/


	FUNCTION f_lis457_cab(
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_producto	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL,
			p_cramo	IN	NUMBER DEFAULT NULL,
			p_cagente	IN	NUMBER DEFAULT NULL,
			p_cagrupa	IN	NUMBER DEFAULT NULL,
			p_ccompani	IN	NUMBER DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto  VARCHAR2(100):='PAC_INFORMES.f_lis457_cab';
	  v_tparam   VARCHAR2(1000):=' i='
	                           || p_cidioma
	                           || ' e='
	                           || p_cempres
	                           || ' i='
	                           || p_finiefe
	                           || ' f='
	                           || p_ffinefe
	                           || ' a='
	                           || p_cagente
	                           || 'ccom='
	                           || p_ccompani;
	  v_ntraza   NUMBER:=0;
	  v_sep      VARCHAR2(1):=';';
	  v_init     VARCHAR2(32000);
	  v_idioma   NUMBER:=p_cidioma;
	  v_tcompani VARCHAR2(3000);
	  vtagrupa   VARCHAR2(3000);
	  v_tramo    VARCHAR2(3000);
	  v_producto VARCHAR2(3000);
	BEGIN
	    v_ntraza:=1040;

	    v_init:=f_axis_literales(102172, v_idioma)
	            || ';'
	            || chr(10);

	    v_init:=v_init
	            || f_axis_literales(9901223, v_idioma)
	            || ';';

	    IF p_ccompani IS NULL THEN
	      v_init:=v_init
	              || f_axis_literales(103233, v_idioma)
	              || ';';
	    ELSE
	      SELECT tcompani
	        INTO v_tcompani
	        FROM companias c
	       WHERE c.ccompani=p_ccompani;

	      v_init:=v_init
	              || v_tcompani
	              || ';';
	    END IF;

	    v_init:=v_init
	            || f_axis_literales(101836, v_idioma)
	            || ';';

	    /*           || TO_DATE('0' || p_finiefe, 'dd/mm/yyyy') || ';'
	               || f_axis_literales(101837, v_idioma) || ';'
	               || TO_DATE('0' || p_ffinefe, 'dd/mm/yyyy');*/
	    IF length(p_finiefe)<8 THEN
	      v_init:=v_init
	              || to_date('0'
	                         || p_finiefe, 'dd/mm/yyyy')
	              || ';';
	    ELSE
	      v_init:=v_init
	              || to_date(p_finiefe, 'dd/mm/yyyy')
	              || ';';
	    END IF;

	    v_init:=v_init
	            || f_axis_literales(101837, v_idioma)
	            || ';';

	    IF length(p_ffinefe)<8 THEN
	      v_init:=v_init
	              || to_date('0'
	                         || p_ffinefe, 'dd/mm/yyyy');
	    ELSE
	      v_init:=v_init
	              || to_date(p_ffinefe, 'dd/mm/yyyy');
	    END IF;

	    v_init:=v_init
	            || chr(10)
	            || f_axis_literales(100706, v_idioma)
	            || ';';

	    IF p_cagrupa IS NULL THEN
	      v_init:=v_init
	              || f_axis_literales(103233, v_idioma)
	              || ';';
	    ELSE
	      SELECT DISTINCT r.tagrpro
	        INTO vtagrupa
	        FROM agrupapro r
	       WHERE r.cidioma=v_idioma AND
	             r.cagrpro=p_cagrupa;

	      v_init:=v_init
	              || vtagrupa
	              || ';';
	    END IF;

	    v_init:=v_init
	            || f_axis_literales(100765, v_idioma)
	            || ';';

	    IF p_cramo IS NULL THEN
	      v_init:=v_init
	              || f_axis_literales(103233, v_idioma)
	              || ';';
	    ELSE
	      SELECT tramo
	        INTO v_tramo
	        FROM ramos
	       WHERE cidioma=v_idioma AND
	             cramo=p_cramo;

	      v_init:=v_init
	              || v_tramo
	              || ';';
	    END IF;

	    v_init:=v_init
	            || chr(10)
	            || f_axis_literales(100681, v_idioma)
	            || ';';

	    IF p_producto IS NULL THEN
	      v_init:=v_init
	              || f_axis_literales(100934, v_idioma)
	              || ';';
	    ELSE
	      SELECT ttitulo
	        INTO v_producto
	        FROM productos p,titulopro t
	       WHERE t.cramo=p.cramo AND
	             t.cmodali=p.cmodali AND
	             t.ctipseg=p.ctipseg AND
	             t.ccolect=p.ccolect AND
	             p.sproduc=p_producto AND
	             t.cidioma=v_idioma;

	      v_init:=v_init
	              || v_producto
	              || ';';
	    END IF;

	    v_init:=v_init
	            || f_axis_literales(100584, v_idioma)
	            || ';';

	    IF p_cagente IS NULL THEN
	      v_init:=v_init
	              || f_axis_literales(100934, v_idioma)
	              || ';';
	    ELSE
	      v_init:=v_init
	              || pac_isqlfor.f_agente(p_cagente)
	              || ';';
	    END IF;

	    /* select * from axis_literales where slitera = 101836*/
	    v_ttexto:=f_axis_literales(9901223, v_idioma)
	              || ';'
	              || f_axis_literales(100784, v_idioma)
	              || ';'
	              || f_axis_literales(100829, v_idioma)
	              || ';'
	              || f_axis_literales(103481, v_idioma)
	              || ';'
	              || f_axis_literales(102347, v_idioma)
	              || ';'
	              || f_axis_literales(101027, v_idioma)
	              || ';'
	              || f_axis_literales(111324, v_idioma)
	              || ';'
	              || f_axis_literales(9901675, v_idioma)
	              || ';'
	              || f_axis_literales(9901776, v_idioma)
	              || ';'
	              || f_axis_literales(109528, v_idioma)
	              || ';'
	              || f_axis_literales(100877, v_idioma)
	              || ';'
	              || f_axis_literales(100883, v_idioma)
	              || ';'
	              || f_axis_literales(105887, v_idioma)
	              || ';'
	              || f_axis_literales(140214, v_idioma)
	              || ';'
	              || f_axis_literales(9901373, v_idioma)
	              || ';'
	              || f_axis_literales(100895, v_idioma)
	              || ';'
	              || f_axis_literales(9001763, v_idioma)
	              || ';'
	              || f_axis_literales(800358, v_idioma);

	    RETURN v_init
	           || chr(10)
	           || chr(10)
	           || v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_lis457_cab;
	FUNCTION f_list457_det(
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_producto	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL,
			p_cramo	IN	NUMBER DEFAULT NULL,
			p_cagente	IN	NUMBER DEFAULT NULL,
			p_cagrupa	IN	NUMBER DEFAULT NULL,
			p_ccompani	IN	NUMBER DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.list457_det';
	  v_tparam  VARCHAR2(1000):=' i='
	                           || p_cidioma
	                           || ' e='
	                           || p_cempres
	                           || ' i='
	                           || p_finiefe
	                           || ' f='
	                           || p_ffinefe
	                           || ' a='
	                           || p_cagente
	                           || 'ccom='
	                           || p_ccompani;
	  v_ntraza  NUMBER:=0;
	  v_finiefe VARCHAR2(100);
	  v_ffinefe VARCHAR2(100);
	  v_espacio VARCHAR2(100):='_';
	  v_cagente NUMBER;
	BEGIN
	    v_ntraza:=1040;

	    SELECT cdelega
	      INTO v_cagente
	      FROM usuarios
	     WHERE cusuari=f_user;

	    IF length(p_finiefe)<8 THEN
	      v_finiefe:='to_date('''
	                 || '0'
	                 || p_finiefe
	                 || ''',''ddmmyyyy'')';
	    ELSE
	      v_finiefe:='to_date('''
	                 || p_finiefe
	                 || ''',''ddmmyyyy'')';
	    END IF;

	    IF length(p_ffinefe)<8 THEN
	      v_ffinefe:='to_date('''
	                 || '0'
	                 || p_ffinefe
	                 || ''',''ddmmyyyy'')';
	    ELSE
	      v_ffinefe:='to_date('''
	                 || p_ffinefe
	                 || ''',''ddmmyyyy'')';
	    END IF;

	    v_ttexto:='SELECT  c.tcompani, r.tramo,f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1,'
	              || p_cidioma
	              || ') ,
	         ff_desactividad(s.cactivi, s.cramo,'
	              || p_cidioma
	              || '), s.cagente || '' - '' || ff_desagente(s.cagente),
	          f_nombre(t.sperson,2,9216), s.npoliza || '' - '' || s.ncertif,TO_CHAR(s.cpolcia||''.''),ff_desvalorfijo(61, '
	              || p_cidioma
	              || ' ,s.csituac) ,
	          s.nsolici , s.femisio , s.fefecto, m.fmovimi , s.fanulac, DECODE(s.fanulac,
	                 NULL, NULL,
	                 NVL((SELECT ''S''
	                        FROM movseguro m
	                       WHERE m.sseguro = s.sseguro
	                         AND cmotmov = 306
	                         AND m.fefecto = s.fanulac), ''N'')),r.nrecibo,  r.creccia ,v.itotalr
	    FROM seguros s,
	         movseguro m,
	(SELECT sseguro, nrecibo, creccia
	            FROM recibos rec
	           WHERE   /*rec.nmovimi = 1*/
	/*and*/
	                 nrecibo = (SELECT MIN(nrecibo)
	                              FROM recibos rec2
	                             WHERE rec2.sseguro = rec.sseguro
	/*and rec2.nmovimi = 1*/
	                          )) r,
	         tomadores t,
	         per_detper p,
	         vdetrecibos v,
	         companias c,
	         ramos r
	   WHERE s.sseguro = m.sseguro
	   and r.cramo = s.cramo
	   and r.cidioma = '
	              || p_cidioma
	              || '
	     AND t.sseguro = s.sseguro
	     AND p.sperson = t.sperson
	     AND p.cagente = 9216
	     AND r.sseguro(+) = s.sseguro
	     AND(s.cagente, s.cempres) IN(SELECT     r.cagente, r.cempres
	                                        FROM redcomercial r
	                                       WHERE r.fmovfin IS NULL
	                                         AND LEVEL =
	                                               DECODE(1,
	                                                      1, LEVEL,
	                                                      1)
	                                  START WITH r.cagente =
	                                                NVL('''
	              || p_cagente
	              || ''',
	                                                    '''
	              || v_cagente
	              || ''')
	                                  CONNECT BY PRIOR r.cagente = r.cpadre
	                                         AND PRIOR r.fmovfin IS NULL)
	     AND v.nrecibo(+) = r.nrecibo
	     AND(TRUNC(s.fefecto) BETWEEN '
	              || v_finiefe
	              || '
	          AND '
	              || v_ffinefe
	              || ')
	     AND m.cmovseg = 0
	      AND c.ccompani(+) = s.ccompani
	     AND s.cempres = '
	              || p_cempres;

	    IF p_cagrupa IS NOT NULL THEN
	      v_ttexto:=v_ttexto
	                || ' and s.cagrpro = '
	                || p_cagrupa;
	    END IF;

	    IF p_producto IS NOT NULL THEN
	      v_ttexto:=v_ttexto
	                || ' and s.sproduc = '
	                || p_producto;
	    END IF;

	    IF p_cramo IS NOT NULL THEN
	      v_ttexto:=v_ttexto
	                || ' and s.cramo = '
	                || p_cramo;
	    END IF;

	    IF p_ccompani IS NOT NULL THEN
	      v_ttexto:=v_ttexto
	                || ' and c.ccompani = '
	                || p_ccompani;
	    END IF;

	    v_ttexto:=v_ttexto
	              || ' ORDER BY s.cagente, s.cramo, r.nrecibo';

	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list457_det;

	/* Bug 0016529 - 29/11/2010 - JMF*/
	FUNCTION f_list001_det01_facturacion(
			 p_cinforme	IN	NUMBER,
			 p_cidioma	IN	NUMBER DEFAULT NULL,
			 p_cempres	IN	NUMBER DEFAULT NULL,
			 p_finiefe	IN	NUMBER DEFAULT NULL,
			 p_ffinefe	IN	NUMBER DEFAULT NULL,
			 p_ctipage	IN	NUMBER DEFAULT NULL,
			 p_cagente	IN	NUMBER DEFAULT NULL,
			 p_sperson	IN	NUMBER DEFAULT NULL,
			 p_cnegocio	IN	NUMBER DEFAULT NULL,
			 p_codigosn	IN	VARCHAR2 DEFAULT NULL,
			 p_sproduc	IN	VARCHAR2 DEFAULT NULL
	)   RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100) := 'PAC_INFORMES.F_LIST001_DET01_FACTURACION';
	  v_tparam  VARCHAR2(1000) := 'c='
	  || p_cinforme
	  || ' i='
	  || p_cidioma
	  || ' e='
	  || p_cempres
	  || ' i='
	  || p_finiefe
	  || ' f='
	  || p_ffinefe
	  || ' t='
	  || p_ctipage
	  || ' a='
	  || p_cagente
	  || ' p='
	  || p_sperson
	  || ' n='
	  || p_cnegocio
	  || ' p='
	  || p_sproduc
	  || ' c='
	  || p_codigosn;
	  v_ntraza  NUMBER := 0;
	  v_finiefe VARCHAR2(100);
	  v_ffinefe VARCHAR2(100);
	PROCEDURE afegir_condicions(
			p_txtage	IN	VARCHAR2 DEFAULT NULL
	) IS
	BEGIN
	  IF p_sperson IS NULL THEN
	    IF p_txtage = 'SEG' THEN
	      v_ntraza := 1000;
	      v_ttexto := v_ttexto
	      || ' AND '
	      || p_ctipage
	      || ' IN (0,2,4,5)'
	      || ' AND seg.cagente IN (SELECT rc.cagente';
	      /* 19794*/
	      v_ttexto_exclu := v_ttexto_exclu
	      || ' AND '
	      || p_ctipage
	      || ' IN (0,2,4,5)'
	      || ' AND seg.cagente IN (SELECT rc.cagente';
	      /* Fi 19794*/
	    ELSE
	      v_ntraza := 1002;
	      v_ttexto := v_ttexto
	      || ' AND '
	      || p_ctipage
	      || ' IN (0,2,4,5)'
	      || ' AND rec.cagente IN (SELECT rc.cagente';
	      /* 19794*/
	      v_ttexto_exclu := v_ttexto_exclu
	      || ' AND '
	      || p_ctipage
	      || ' IN (0,2,4,5)'
	      || ' AND rec.cagente IN (SELECT rc.cagente';
	      /* Fi 19794*/
	    END IF;
	    v_ntraza := 1004;
	    v_ttexto := v_ttexto
	    || '     FROM redcomercial rc'
	    || '     WHERE rc.cempres = '
	    || p_cempres
	    || '     START WITH rc.ctipage = '
	    || p_ctipage;
	    /* 19794*/
	    v_ttexto_exclu := v_ttexto_exclu
	    || '     FROM redcomercial rc'
	    || '     WHERE rc.cempres = '
	    || p_cempres
	    || '     START WITH rc.ctipage = '
	    || p_ctipage;
	    /* Fi 19794*/
	    IF p_cagente IS NOT NULL
	      AND
	      p_cagente <> -1
	      /* Bug 0016529 - 29/12/2010 - JMF*/
	      THEN
	      v_ttexto := v_ttexto
	      || ' AND rc.cagente = '
	      || p_cagente;
	      /* 19794*/
	      v_ttexto_exclu := v_ttexto_exclu
	      || ' AND rc.cagente = '
	      || p_cagente;
	      /* Fi 19794*/
	    END IF;
	    v_ntraza := 1005;
	    v_ttexto := v_ttexto
	    || ' CONNECT BY PRIOR rc.cagente = rc.cpadre and PRIOR fmovfin IS NULL)';
	    /* 19794*/
	    v_ttexto_exclu := v_ttexto_exclu
	    || ' CONNECT BY PRIOR rc.cagente = rc.cpadre and PRIOR fmovfin IS NULL)';
	    /* Fi 19794*/
	  END IF;
	  IF p_sperson IS NOT NULL THEN
	    v_ntraza := 1010;
	    v_ttexto := v_ttexto
	    || ' AND '
	    || p_sperson
	    || ' IN (SELECT sperson FROM tomadores WHERE sseguro = seg.sseguro'
	    || ' UNION'
	    || ' SELECT sperson FROM asegurados WHERE sseguro = seg.sseguro)';
	    /* 19794*/
	    v_ttexto_exclu := v_ttexto_exclu
	    || ' AND '
	    || p_sperson
	    || ' IN (SELECT sperson FROM tomadores WHERE sseguro = seg.sseguro'
	    || ' UNION'
	    || ' SELECT sperson FROM asegurados WHERE sseguro = seg.sseguro)';
	    /* Fi 19794*/
	  END IF;
	  IF p_codigosn IS NOT NULL THEN
	    /* Bug 0016529 - 16/06/2011 - JMF: quito coma final*/
	    IF p_cnegocio = 2 THEN
	      /* 2.- Agrupación Productos*/
	      v_ntraza := 1015;
	      v_ttexto := v_ttexto
	      || ' AND seg.cagrpro in ('
	      || rtrim(p_codigosn, ',')
	      || ')';
	      /* 19794*/
	      v_ttexto_exclu := v_ttexto_exclu
	      || ' AND seg.cagrpro in ('
	      || rtrim(p_codigosn, ',')
	      || ')';
	      /* Fi 19794*/
	    ELSIF p_cnegocio = 3 THEN
	      /* 3.- Ramos*/
	      v_ntraza := 1020;
	      v_ttexto := v_ttexto
	      || ' AND seg.cramo in ('
	      || rtrim(p_codigosn, ',')
	      || ')';
	      /* 19794*/
	      v_ttexto_exclu := v_ttexto_exclu
	      || ' AND seg.cramo in ('
	      || rtrim(p_codigosn, ',')
	      || ')';
	      /* Fi 19794*/
	    ELSIF p_cnegocio = 4 THEN
	      /* 4.- Productos*/
	      v_ntraza := 1025;
	      v_ttexto := v_ttexto
	      || ' AND seg.sproduc in ('
	      || rtrim(p_codigosn, ',')
	      || ')';
	      /* 19794*/
	      v_ttexto_exclu := v_ttexto_exclu
	      || ' AND seg.sproduc in ('
	      || rtrim(p_codigosn, ',')
	      || ')';
	      /* Fi 19794*/
	    ELSIF p_cnegocio = 5
	      AND
	      p_sproduc IS NOT NULL THEN
	      /* 5.- Actividad*/
	      v_ntraza := 1030;
	      v_ttexto := v_ttexto
	      || ' AND seg.sproduc = '
	      || p_sproduc
	      || ' AND seg.cactivi in ('
	      || rtrim(p_codigosn, ',')
	      || ')';
	      /* 19794*/
	      v_ttexto_exclu := v_ttexto_exclu
	      || ' AND seg.sproduc = '
	      || p_sproduc
	      || ' AND seg.cactivi in ('
	      || rtrim(p_codigosn, ',')
	      || ')';
	      /* Fi 19794*/
	    ELSIF p_cnegocio = 6 THEN
	      /* 6.- Compañías*/
	      v_ntraza := 1035;
	      v_ttexto := v_ttexto
	      || ' AND seg.ccompani in ('
	      || rtrim(p_codigosn, ',')
	      || ')';
	      /* 19794*/
	      v_ttexto_exclu := v_ttexto_exclu
	      || ' AND seg.ccompani in ('
	      || rtrim(p_codigosn, ',')
	      || ')';
	      /* Fi 19794*/
	    END IF;
	  END IF;
	END;
	BEGIN
	  v_ntraza := 1040;
	  v_ttexto := NULL;
	  v_ttexto_exclu := NULL;
	  /* 19794*/
	  /*------------------------------------------------------------------------*/
	  /*------------------------------------------------------------------------*/
	  /* INFORME 1.- Facturación*/
	  /*------------------------------------------------------------------------*/
	  /*------------------------------------------------------------------------*/
	  v_ntraza := 1045;
	  v_finiefe := 'to_date('
	  || p_finiefe
	  || ',''yyyymmdd'')';
	  v_ffinefe := 'to_date('
	  || p_ffinefe
	  || ',''yyyymmdd'')';
	  /* Bug 0016529 - 28/12/2010 - JMF: f_desproducto_t*/
	  /* ini lista de casos*/
	  /* 100 anterior nueva prod*/
	  /* 101 anterior cartera*/
	  /* 110 actual   nueva prod*/
	  /* 111 actual   cartera*/
	  /* 1AC PAC_AGENDA*/
	  /* fin lista de casos*/
	  v_ntraza := 1050;
	  v_ttexto := 'SELECT  TO_CHAR(CAGE, ''0009'') oficina ,  ff_desagente(CAGE) tagente,'
	  || ' DECODE('
	  || p_cnegocio
	  || ','
	  || '        1, ff_desvalorfijo(1023, '
	  || p_cidioma
	  || ', 1),'
	  || '        2, ff_desvalorfijo(283, '
	  || p_cidioma
	  || ', cagrpro),'
	  || '        3, ff_desramo(cramo, '
	  || p_cidioma
	  || '),'
	  || '        4, f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, '
	  || p_cidioma
	  || '),'
	  || '        5, FF_DESACTIVIDAD(cactivi, cramo, '
	  || p_cidioma
	  || ',2),'
	  || '        6, FF_DESCOMPANIA(ccompani)'
	  || '        ) descripcion,'
	  || ' SUM(DECODE(actual, 1, itotpri, 0)) total_actual,'
	  || ' SUM(DECODE(actual, 0, itotpri, 0)) total_anterior,'
	  || ' SUM(DECODE(actual, 1,1,0,-1,0)*itotpri) total_diferencia,'
	  || ' decode( SUM(DECODE(actual, 0, itotpri, 0)) ,0,0,'
	  || '    f_round( SUM(DECODE(actual, 1,1,0,-1,0)*itotpri)*100/SUM(DECODE(actual, 0, itotpri, 0)))) total_porcentaje,'
	  || ' SUM(DECODE(caso, 111, itotpri, 0)) total_act_cartera,'
	  || ' SUM(DECODE(caso, 101, itotpri, 0)) total_ant_cartera,'
	  || ' SUM(DECODE(caso, 111,1,101,-1,0)*itotpri) total_dif_cartera,'
	  || ' decode( SUM(DECODE(caso, 101, itotpri, 0)) ,0,0,'
	  || ' f_round( SUM(DECODE(caso, 111,1,101,-1,0)*itotpri) *100/ SUM(DECODE(caso, 101, itotpri, 0)) )) total_porcen_cartera,'
	  || ' SUM(DECODE(caso, 110, itotpri, 0)) total_act_nueva_produccion,'
	  || ' SUM(DECODE(caso, 100, itotpri, 0)) total_ant_nueva_produccion,'
	  || ' SUM(DECODE(caso, 110,1,100,-1,0)*itotpri) total_dif_nueva_produccion,'
	  || ' decode( SUM(DECODE(caso, 100, itotpri, 0)) ,0,0,'
	  || ' f_round( SUM(DECODE(caso, 110,1,100,-1,0)*itotpri)*100/SUM(DECODE(caso, 100, itotpri, 0)) )) total_porcen_nueva_produccion,'
	  || ' decode( SUM(DECODE(actual, 1, itotpri, 0)) , 0,0, f_round(SUM(DECODE(caso, 110, itotpri, 0)) * 100 / SUM(DECODE(actual, 1, itotpri, 0)))) Ratio_Actual,'
	  || ' decode( SUM(DECODE(actual, 0, itotpri, 0)) , 0,0, f_round(SUM(DECODE(caso, 100, itotpri, 0)) * 100 / SUM(DECODE(actual, 0, itotpri, 0)))) Ratio_Anterior' --,'
	  /* Bug 0019794 - 18/11/2011 - FAL*/
	  /*         || ' decode( SUM(DECODE(actual, 1, itotpri, 0)) , 0,0, f_round(SUM(DECODE(caso, 110, itotpri, 0)) * 100 / SUM(DECODE(actual, 1, itotpri, 0)))) -'*/
	  /*         || ' decode( SUM(DECODE(actual, 0, itotpri, 0)) , 0,0, f_round(SUM(DECODE(caso, 100, itotpri, 0)) * 100 / SUM(DECODE(actual, 0, itotpri, 0)))) Ratio_Diferencia'*/
	  || ' FROM ('
	  || ' SELECT 0 actual, FF_DESAGENTE(decode('
	  || p_ctipage
	  || ',0,'
	  || p_cagente
	  || ',rec.cagente)) cagente, rec.cagente cage,'
	  || '         rec.nrecibo, rec.nanuali, seg.cagrpro, seg.cramo, seg.cmodali,'
	  || '        seg.ctipseg, seg.ccolect, seg.cactivi, seg.ccompani'
	  || '        , nvl(decode(rec.ctiprec,9,-1,1)*vdr.itotpri,0) itotpri'
	  || '       , decode(greatest(11,months_between(rec.fefecto,seg.fefecto)),11,100,101) caso'
	  || '   FROM recibos rec, vdetrecibos vdr, seguros seg'
	  || '  WHERE rec.nrecibo = vdr.nrecibo'
	  || '    AND TRUNC(rec.femisio) >= ADD_MONTHS('
	  || v_finiefe
	  || ', -12)'
	  || '    AND TRUNC(rec.femisio) <= ADD_MONTHS('
	  || v_ffinefe
	  || ', -12)'
	  || '    AND rec.cempres = '
	  || p_cempres
	  || '    AND seg.sseguro = rec.sseguro'
	  /*|| '    AND F_CESTREC(rec.nrecibo, f_sysdate) = 1'*/
	  ;
	  /* 19794*/
	  v_ttexto_exclu := '(SELECT rec.cagente cage '
	  || '   FROM recibos rec, vdetrecibos vdr, seguros seg'
	  || '  WHERE rec.nrecibo = vdr.nrecibo'
	  || '    AND TRUNC(rec.femisio) >= ADD_MONTHS('
	  || v_finiefe
	  || ', -12)'
	  || '    AND TRUNC(rec.femisio) <= ADD_MONTHS('
	  || v_ffinefe
	  || ', -12)'
	  || '    AND rec.cempres = '
	  || p_cempres
	  || '    AND seg.sseguro = rec.sseguro';
	  /* Fi 19794*/
	  v_ntraza := 1055;
	  afegir_condicions;
	  v_ntraza := 1060;
	  v_ttexto := v_ttexto
	  || 'UNION ALL '
	  || 'SELECT 1 actual, FF_DESAGENTE(decode('
	  || p_ctipage
	  || ',0,'
	  || p_cagente
	  || ',rec.cagente)) cagente, rec.cagente cage,'
	  || '        rec.nrecibo, rec.nanuali, seg.cagrpro, seg.cramo, seg.cmodali,'
	  || '       seg.ctipseg, seg.ccolect, seg.cactivi, seg.ccompani'
	  || '        , nvl(decode(rec.ctiprec,9,-1,1)*vdr.itotpri,0) itotpri'
	  || '        , decode(greatest(11,months_between(rec.fefecto,seg.fefecto)),11,110,111) caso'
	  || '  FROM recibos rec, vdetrecibos vdr, seguros seg'
	  || ' WHERE rec.nrecibo = vdr.nrecibo'
	  || '   AND TRUNC(rec.femisio) >= '
	  || v_finiefe
	  || '   AND TRUNC(rec.femisio) <= '
	  || v_ffinefe
	  || '   AND rec.cempres = '
	  || p_cempres
	  || '   AND seg.sseguro = rec.sseguro'
	  /*|| '   AND F_CESTREC(rec.nrecibo, f_sysdate) = 1'*/
	  ;
	  /* 19794*/
	  v_ttexto_exclu := v_ttexto_exclu
	  || 'UNION ALL '
	  || 'SELECT rec.cagente cage '
	  || '  FROM recibos rec, vdetrecibos vdr, seguros seg'
	  || ' WHERE rec.nrecibo = vdr.nrecibo'
	  || '   AND TRUNC(rec.femisio) >= '
	  || v_finiefe
	  || '   AND TRUNC(rec.femisio) <= '
	  || v_ffinefe
	  || '   AND rec.cempres = '
	  || p_cempres
	  || '   AND seg.sseguro = rec.sseguro';
	  /* Fi 19794*/
	  v_ntraza := 1065;
	  afegir_condicions;
	  /* Restamos traspasos de salida de planes pensiones*/
	  v_ntraza := 1070;
	  v_ttexto := v_ttexto
	  || 'UNION ALL '
	  || 'SELECT 0 actual, FF_DESAGENTE(decode('
	  || p_ctipage
	  || ',0,'
	  || p_cagente
	  || ',seg.cagente)) cagente, seg.cagente cage,'
	  || '       cta.nnumlin, seg.nanuali, seg.cagrpro, seg.cramo, seg.cmodali,'
	  || '       seg.ctipseg, seg.ccolect, seg.cactivi, seg.ccompani'
	  || '        , (-1)*nvl(decode(cta.cmovimi,10,-1,1)*cta.imovimi,0) itotalr'
	  || '        , decode(greatest(11,months_between(cta.fvalmov,seg.fefecto)),11,100,101) caso'
	  || '  FROM ctaseguro cta, seguros  seg'
	  || ' WHERE cta.cmovimi in (47,10)'
	  || '   AND TRUNC(cta.fvalmov) >= ADD_MONTHS('
	  || v_finiefe
	  || ', -12)'
	  || '   AND TRUNC(cta.fvalmov) <= ADD_MONTHS('
	  || v_ffinefe
	  || ', -12)'
	  || '   AND seg.cempres = '
	  || p_cempres
	  || '   AND seg.sseguro = cta.sseguro and seg.cagrpro = 2';
	  /* 19794*/
	  v_ttexto_exclu := v_ttexto_exclu
	  || 'UNION ALL '
	  || 'SELECT seg.cagente cage '
	  || '  FROM ctaseguro cta, seguros  seg'
	  || ' WHERE cta.cmovimi in (47,10)'
	  || '   AND TRUNC(cta.fvalmov) >= ADD_MONTHS('
	  || v_finiefe
	  || ', -12)'
	  || '   AND TRUNC(cta.fvalmov) <= ADD_MONTHS('
	  || v_ffinefe
	  || ', -12)'
	  || '   AND seg.cempres = '
	  || p_cempres
	  || '   AND seg.sseguro = cta.sseguro and seg.cagrpro = 2';
	  /* Fi 19794*/
	  v_ntraza := 1075;
	  afegir_condicions('SEG');
	  /* Restamos traspasos de salida de planes pensiones*/
	  v_ntraza := 1080;
	  v_ttexto := v_ttexto
	  || 'UNION ALL '
	  || 'SELECT 1 actual, FF_DESAGENTE(decode('
	  || p_ctipage
	  || ',0,'
	  || p_cagente
	  || ',seg.cagente)) cagente, seg.cagente cage,'
	  || '       cta.nnumlin, seg.nanuali, seg.cagrpro, seg.cramo, seg.cmodali,'
	  || '       seg.ctipseg, seg.ccolect, seg.cactivi, seg.ccompani'
	  || '        , (-1)*nvl(decode(cta.cmovimi,10,-1,1)*cta.imovimi,0) itotalr'
	  || '        , decode(greatest(11,months_between(cta.fvalmov,seg.fefecto)),11,110,111) caso'
	  || '  FROM ctaseguro cta, seguros  seg'
	  || ' WHERE cta.cmovimi in (47,10)'
	  || '   AND TRUNC(cta.fvalmov) >= '
	  || v_finiefe
	  || '   AND TRUNC(cta.fvalmov) <= '
	  || v_ffinefe
	  || '   AND seg.cempres = '
	  || p_cempres
	  || '   AND seg.sseguro = cta.sseguro and seg.cagrpro = 2';
	  /* 19794*/
	  v_ttexto_exclu := v_ttexto_exclu
	  || 'UNION ALL '
	  || 'SELECT seg.cagente cage '
	  || '  FROM ctaseguro cta, seguros  seg'
	  || ' WHERE cta.cmovimi in (47,10)'
	  || '   AND TRUNC(cta.fvalmov) >= '
	  || v_finiefe
	  || '   AND TRUNC(cta.fvalmov) <= '
	  || v_ffinefe
	  || '   AND seg.cempres = '
	  || p_cempres
	  || '   AND seg.sseguro = cta.sseguro and seg.cagrpro = 2';
	  /* Fi 19794*/
	  v_ntraza := 1085;
	  afegir_condicions('SEG');
	  v_ntraza := 1090;
	  v_ttexto := v_ttexto
	  || 'UNION ALL  SELECT 1 actual, FF_DESAGENTE(decode('
	  || p_ctipage
	  || ',0,'
	  || p_cagente
	  || ',rc.cagente)) cagente, rc.cagente cage,'
	  || '       0, 0, null, null, null,'
	  || '       null, null, null, null'
	  || '        ,0 itotalr'
	  || '        , 1 caso
	FROM redcomercial rc
	WHERE rc.cempres = '
	  || p_cempres
	  || ' and rc.cagente not in '
	  || v_ttexto_exclu
	  || ')' -- 19794
	  ;
	  IF p_cnegocio = 6 THEN
	    v_ttexto := v_ttexto
	    || ' and (rc.cagente NOT IN (select distinct(cagente) from seguros where  ccompani in ('
	    || rtrim(p_codigosn, ',')
	    || ') ) )';
	    /*
	OR RC.CAGENTE NOT IN (SELECT distinct(cagente) from seguros where cempres = '
	|| p_cempres || ')) ';*/
	  END IF;
	  v_ttexto := v_ttexto
	  || ' START WITH rc.ctipage = '
	  || p_ctipage
	  || '         AND rc.cagente = '
	  || p_cagente
	  || ' CONNECT BY PRIOR rc.cagente = rc.cpadre
	AND PRIOR fmovfin IS NULL '; -- Bug 0016529 - 28/12/2010 - JMF: f_desproducto_t
	  /* Bug 0019794 - 18/11/2011 - FAL*/
	  v_text_total := v_ttexto
	  || ')))';
	  /* Fi Bug 0019794*/
	  v_ttexto := v_ttexto
	  || ')'
	  || ' GROUP BY f_buscazona( '
	  || p_cempres
	  || ', cage,'
	  || p_ctipage
	  || ', f_sysdate),CAGE,DECODE('
	  || p_cagente
	  || ','
	  || '-1, ff_desagente(f_buscazona( '
	  || p_cempres
	  || ', cage,'
	  || p_ctipage
	  || ', f_sysdate)), cagente),'
	  || ' DECODE('
	  || p_cnegocio
	  || ','
	  || ' 1, ff_desvalorfijo(1023, '
	  || p_cidioma
	  || ', 1),'
	  || ' 2, ff_desvalorfijo(283, '
	  || p_cidioma
	  || ', cagrpro),'
	  || ' 3, ff_desramo(cramo, '
	  || p_cidioma
	  || '),'
	  || ' 4, f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, '
	  || p_cidioma
	  || '),'
	  || ' 5, FF_DESACTIVIDAD(cactivi, cramo, '
	  || p_cidioma
	  || ',2),'
	  || ' 6, FF_DESCOMPANIA(ccompani))';
	  /* Bug 0019794 - 18/11/2011 - FAL*/
	  v_ttexto := v_ttexto
	  || ' UNION ALL (select null oficina, null tagente ,null descripcion, sum(total_actual), sum(total_anterior), sum(total_diferencia), null, sum(total_act_cartera),
	sum(total_ant_cartera), sum(total_dif_cartera), null, sum(total_act_nueva_produccion), sum(total_ant_nueva_produccion),
	sum(total_dif_nueva_produccion), null, null, null from ('
	  || v_text_total
	  || ' order by oficina asc';
	  /* Fi Bug 0019794*/
	  v_ntraza := 9999;
	  RETURN v_ttexto;
	EXCEPTION
	WHEN OTHERS THEN
	  p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	  || ': Error'
	  || SQLCODE, SQLERRM);
	  RETURN 'select 1 from dual';
	END f_list001_det01_facturacion;
	/* Bug 0016529 - 29/11/2010 - JMF*/
	FUNCTION f_list002_cab(
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_filtro	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL,
			p_ctiprec	IN	NUMBER DEFAULT NULL,
			p_cestrec	IN	NUMBER DEFAULT NULL,
			p_cestado	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_ccompani	IN	NUMBER DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto    VARCHAR2(100):='PAC_INFORMES.F_LIST002_CAB';
	  v_tparam     VARCHAR2(1000):=' i='
	                           || p_cidioma
	                           || ' e='
	                           || p_cempres;
	  v_ntraza     NUMBER:=0;
	  v_ini        VARCHAR2(32000);
	  v_idioma     NUMBER;
	  v_tproduc    VARCHAR2(500);
	  verror       NUMBER;
	  cad1         VARCHAR2(1000);
	  cad2         VARCHAR2(10);
	  vtactivi     VARCHAR2(40);
	  vcad         NUMBER:=1;
	  v_parcompani NUMBER;
	  v_sep        VARCHAR2(1):=';';
	  v_tcompani   VARCHAR2(400);
	BEGIN
	    v_ntraza:=1000;

	    v_ttexto:=NULL;

	    IF p_cidioma IS NULL THEN
	      SELECT max(nvalpar)
	        INTO v_idioma
	        FROM parinstalacion
	       WHERE cparame='IDIOMARTF';
	    ELSE
	      v_idioma:=p_cidioma;
	    END IF;

	    v_ini:=''
	           || f_axis_literales(9901788, v_idioma)
	           || ';'
	           || chr(10)
	           || f_axis_literales(9000526, v_idioma)
	           || ';'
	           || to_date(ltrim(to_char(p_finiefe, '09999999')), 'ddmmrrrr')
	           || ';' -- fecha inicio
	           || f_axis_literales(9000527, v_idioma)
	           || ';'
	           || to_date(ltrim(to_char(p_ffinefe, '09999999')), 'ddmmrrrr')
	           || ';' -- fecha final
	           || chr(10);

	    IF p_filtro=0 THEN
	      v_ini:=v_ini
	             || f_axis_literales(1000178, v_idioma)
	             || ';'
	             || f_axis_literales(100883, v_idioma)
	             || ';';
	    ELSIF p_filtro=1 THEN
	      v_ini:=v_ini
	             || f_axis_literales(1000178, v_idioma)
	             || ';'
	             || f_axis_literales(101006, v_idioma)
	             || ';';
	    ELSIF p_filtro=2 THEN
	      v_ini:=v_ini
	             || f_axis_literales(1000178, v_idioma)
	             || ';'
	             || f_axis_literales(9901778, v_idioma)
	             || ';';
	    END IF;

	    IF p_ctiprec IS NOT NULL THEN
	      v_ini:=v_ini
	             || chr(10)
	             || f_axis_literales(102302, v_idioma)
	             || ';'
	             || ff_desvalorfijo(8, v_idioma, p_ctiprec)
	             || ';';
	    END IF;

	    IF p_cestrec IS NOT NULL THEN
	      v_ini:=v_ini
	             || chr(10)
	             || f_axis_literales(1000553, v_idioma)
	             || ';'
	             || ff_desvalorfijo(3, v_idioma, p_cestrec)
	             || ';';
	    END IF;

	    IF p_ccompani IS NOT NULL THEN BEGIN
	          SELECT tcompani
	            INTO v_tcompani
	            FROM companias
	           WHERE ccompani=p_ccompani;

	          v_ini:=v_ini
	                 || chr(10)
	                 || f_axis_literales(9000600, v_idioma)
	                 || ';'
	                 || v_tcompani
	                 || ';';
	      EXCEPTION
	          WHEN OTHERS THEN
	            NULL;
	      END;
	    END IF;

	    IF p_cestado IS NOT NULL THEN
	      v_ini:=v_ini
	             || chr(10)
	             || f_axis_literales(1000553, v_idioma)
	             || ';'
	             || ff_desvalorfijo(61, v_idioma, p_cestado)
	             || ';';
	    END IF;

	    v_ini:=v_ini
	           || chr(10);

	    v_parcompani:=pac_parametros.f_parlistado_n(p_cempres, 'CCOMPANI');

	    v_ttexto:=NULL;

	    IF v_parcompani=1 THEN
	      v_ttexto:=v_ttexto
	                || f_axis_literales(9901223, v_idioma)
	                || v_sep; /* Compañía*/
	    END IF;

	    v_ttexto:=v_ttexto
	              || f_axis_literales(100784, v_idioma)
	              || v_sep; /* Ramo*/

	    v_ttexto:=v_ttexto
	              || f_axis_literales(100829, v_idioma)
	              || v_sep /* Producto*/
	              || f_axis_literales(103481, v_idioma)
	              || v_sep /* Actividad*/
	              || f_axis_literales(102347, v_idioma)
	              || v_sep
	              || f_axis_literales(101027, v_idioma)
	              || v_sep
	              || f_axis_literales(9001875, v_idioma)
	              || v_sep;

	    IF v_parcompani=1 THEN
	      v_ttexto:=v_ttexto
	                || f_axis_literales(9901675, v_idioma)
	                || v_sep;
	    END IF;

	    v_ttexto:=v_ttexto
	              || f_axis_literales(100883, v_idioma)
	              || ' '
	              || f_axis_literales(9001875, v_idioma)
	              || v_sep
	              || f_axis_literales(109716, v_idioma)
	              || v_sep
	              || f_axis_literales(101516, v_idioma)
	              || v_sep;

	    IF v_parcompani=1 THEN
	      v_ttexto:=v_ttexto
	                || f_axis_literales(9901670, v_idioma)
	                || v_sep;
	    END IF;

	    v_ttexto:=v_ttexto
	              || f_axis_literales(100895, v_idioma)
	              || v_sep
	              || f_axis_literales(100883, v_idioma)
	              || ' '
	              || f_axis_literales(100895, v_idioma)
	              || v_sep
	              || f_axis_literales(1000562, v_idioma)
	              || ' '
	              || f_axis_literales(100895, v_idioma)
	              || v_sep
	              || f_axis_literales(100885, v_idioma)
	              || ' '
	              || f_axis_literales(100895, v_idioma)
	              || v_sep
	              || f_axis_literales(102302, v_idioma)
	              || v_sep
	              || f_axis_literales(9000842, v_idioma)
	              || v_sep
	              || f_axis_literales(100563, v_idioma)
	              || v_sep
	              || f_axis_literales(1000553, v_idioma)
	              || v_sep
	              || f_axis_literales(100587, 2)
	              || ' '
	              || f_axis_literales(9001875, 2)
	              || '';

	    RETURN v_ini
	           || v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN NULL;
	END f_list002_cab;

	/******************************************************************************************
	  Descripció: Funció que genera texte select detall per llistat (map 415 dinamic)
	  Paràmetres entrada: - p_cinforme    -> codigo informe (detvalor 1021)
	                      - p_cidioma     -> codigo idioma
	                      - p_cempres     -> codigo empresa
	                      - p_finiefe     -> fecha inicio
	                      - p_ffinefe     -> fecha final
	                      - p_ctipage     -> Tipo (detvalor 1022) (tipo agente)
	                      - p_cagente     -> codigo en funcion del tipo (zona, oficina, agente)
	                      - p_sperson     -> codigo cliente
	                      - p_cnegocio    -> Negocio (detvalor 1023)
	                      - p_codigosn    -> Codigos de negocio (separados por comas)
	                      - p_sproduc     -> Producto de la actividad
	  return:             texte select detall
	******************************************************************************************/
	/* Bug 0016529 - 29/11/2010 - JMF*/
	FUNCTION f_list001_det02_polizas(
			p_cinforme	IN	NUMBER,
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL,
			p_ctipage	IN	NUMBER DEFAULT NULL,
			p_cagente	IN	NUMBER DEFAULT NULL,
			p_sperson	IN	NUMBER DEFAULT NULL,
			p_cnegocio	IN	NUMBER DEFAULT NULL,
			p_codigosn	IN	VARCHAR2 DEFAULT NULL,
			p_sproduc	IN	VARCHAR2 DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list001_det02_Polizas';
	  v_tparam  VARCHAR2(1000):='c='
	                           || p_cinforme
	                           || ' i='
	                           || p_cidioma
	                           || ' e='
	                           || p_cempres
	                           || ' i='
	                           || p_finiefe
	                           || ' f='
	                           || p_ffinefe
	                           || ' t='
	                           || p_ctipage
	                           || ' a='
	                           || p_cagente
	                           || ' p='
	                           || p_sperson
	                           || ' n='
	                           || p_cnegocio
	                           || ' p='
	                           || p_sproduc
	                           || ' c='
	                           || p_codigosn;
	  v_ntraza  NUMBER:=0;
	  v_ini12   DATE; /*VARCHAR2(100);*/
	  v_fin12   DATE; /* VARCHAR2(100);*/
	  v_ffinefe DATE; /* VARCHAR2(100);*/
	  v_finiefe DATE; /*VARCHAR2(100);*/
	BEGIN
	    v_ntraza:=1000;

	    v_ttexto:=NULL;

	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 2.- Pólizas/planes*/
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    v_ntraza:=1100;

	    /*  v_ini12 := 'to_char(ADD_MONTHS(to_date(' || p_finiefe*/
	    /*           || ',''yyyymmdd''),-12),''yyyymmdd'')';*/
	    v_ini12:=add_months(to_date(p_finiefe, 'yyyymmdd'), -12);

	    /*v_fin12 := 'to_char(ADD_MONTHS(to_date(' || p_ffinefe*/
	    /*         || ',''yyyymmdd''),-12),''yyyymmdd'')';*/
	    v_fin12:=add_months(to_date(p_ffinefe, 'yyyymmdd'), -12);

	    /*      v_feact := 'to_date(' || p_ffinefe || ',''yyyymmdd'')';*/
	    v_ffinefe:=to_date(p_ffinefe, 'yyyymmdd');

	    /*v_feant := 'ADD_MONTHS(to_date(' || p_ffinefe || ',''yyyymmdd''),-12)';*/
	    v_finiefe:=to_date(p_finiefe, 'yyyymmdd');

	    v_ntraza:=1110;

	    /* Bug 0016529 - 28/12/2010 - JMF: f_desproducto_t*/
	    /* Bug 0016529 - 21/02/2011 - JMF: Canvi criteris dades (vigencia, anulació, captades, etc).*/
	    v_ttexto:='SELECT cage oficina'
	              || ', ff_desagente(cage) tagente,'
	              || 'DECODE('
	              || p_cnegocio
	              || ','
	              || '        1, ff_desvalorfijo(1023, '
	              || p_cidioma
	              || ', 1),'
	              || '        2, ff_desvalorfijo(283, '
	              || p_cidioma
	              || ', cagrpro),'
	              || '        3, ff_desramo(cramo, '
	              || p_cidioma
	              || '),'
	              || '        4, f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, '
	              || p_cidioma
	              || '),'
	              || '        5, FF_DESACTIVIDAD(cactivi, cramo, '
	              || p_cidioma
	              || ',2),'
	              || '        6, FF_DESCOMPANIA(ccompani)'
	              || ') descripcion,'
	              || 'sum( vigente ) vigor_actual,'
	              || 'sum( vigente_ant ) vigor_anterior,'
	              || 'sum( vigente ) - sum(vigente_ant  ) vigor_diferencia,'
	              || 'decode(nvl(sum(vigente_ant),0),0,0,round(((sum( vigente ) / sum(vigente_ant))-1)*100,2)) vigor_porcentaje,'
	              || 'sum(captada) captada_actual,'
	              || 'sum(captada_Ant) captada_anterior,'
	              || 'sum(captada) - sum(captada_Ant) captada_diferencia,'
	              || 'decode(nvl(sum(captada_Ant),0),0,0,round(((sum( captada ) / sum(captada_Ant))-1)*100,2)) captada_porcentaje,'
	              || 'sum( decode(Anulada,1,1,0) ) anulada_actual,'
	              || 'sum( decode(Anulada_Ant,1,1,0) ) anulada_anterior,'
	              || 'sum( decode(Anulada,1,1,0) ) - sum( decode(Anulada_Ant,1,1,0) ) anulada_diferencia,'
	              || 'decode( sum( decode(Anulada_Ant,1,1,0) ), 0, 0,'
	              || '       f_round('
	              || '              (sum( decode(Anulada,1,1,0) ) - sum( decode(Anulada_Ant,1,1,0) ) )*100 / sum( decode(Anulada_Ant,1,1,0) )'
	              || '              )'
	              || '      ) anulada_porcentaje'
	              || ' FROM ('
	              || ' ( SELECT FF_DESAGENTE(decode('
	              || p_ctipage
	              || ',0,'
	              || p_cagente
	              || ',age.cagente)) cagente, age.cagente cage,'
	              || '        seg.cagrpro, seg.cramo, seg.cmodali,'
	              || '        seg.ctipseg, seg.ccolect, seg.cactivi, seg.ccompani,'
	              || ' (select count(1) from movseguro where sseguro = seg.sseguro   and nmovimi = 1 and trunc(nvl(mov.femisio,mov.fmovimi)) between  '''
	              || v_finiefe
	              || ''' and '''
	              || v_ffinefe
	              || ''') Captada, '
	              || ' (select count(1) from movseguro where sseguro = seg.sseguro   and nmovimi = 1 and trunc(nvl(mov.femisio,mov.fmovimi)) between  '''
	              || v_ini12
	              || ''' and '''
	              || v_fin12
	              || ''') Captada_Ant, '
	              || ' (select count(1) from seguros where sseguro = seg.sseguro and csituac in (0,2,3,15)
	               and nvl(fanulac,fvencim) between  '''
	              || v_finiefe
	              || ''' and '''
	              || v_ffinefe
	              || ''') Anulada, '
	              || '        decode(seg.csituac,12,0,13,0,15,0,decode(f_vigente(seg.sseguro,null,'''
	              || v_ffinefe
	              || '''),0,1,0)) + (SELECT COUNT(1) FROM DUAL WHERE SEG.CSITUAC = 14 AND SEG.FEFECTO<='''
	              || v_ffinefe
	              || ''')  Vigente,'
	              || ' (select count(1) from seguros where sseguro = seg.sseguro and csituac in (0,2,3,15)
	               and nvl(fanulac,fvencim) between  '''
	              || v_ini12
	              || ''' and '''
	              || v_fin12
	              || ''') Anulada_Ant, '
	              || '        decode(seg.csituac,12,0,13,0,15,0,decode(f_vigente(seg.sseguro,null,'''
	              || v_fin12
	              || '''),0,1,0)) + (SELECT COUNT(1) FROM DUAL WHERE SEG.CSITUAC = 14 AND SEG.FEFECTO<='''
	              || v_fin12
	              || ''')  vigente_ant'
	              || ' FROM seguros seg, agentes age, movseguro mov'
	              || ' WHERE seg.csituac in (0,2,3,14,15)' -- 0 vigente, 2 anulada, 3 vencida, 14 prepoliza, 15 anul-.prepoliza
	              || ' AND seg.sseguro = mov.sseguro AND mov.nmovimi = 1  '
	              || ' AND seg.cempres = '
	              || p_cempres
	              || ' AND seg.cagente(+) = age.cagente ';

	    IF p_sperson IS NULL THEN
	      v_ntraza:=1115;

	      v_ttexto:=v_ttexto
	                || ' AND '
	                || p_ctipage
	                || ' IN (0,2,4,5)'
	                || ' AND age.cagente IN (SELECT rc.cagente'
	                || '     FROM redcomercial rc'
	                || '     WHERE rc.cempres = '
	                || p_cempres
	                || '     START WITH rc.ctipage = '
	                || p_ctipage;

	      IF p_cagente IS NOT NULL AND
	         p_cagente<>-1 /* Bug 0016529 - 29/12/2010 - JMF*/
	      THEN
	        v_ttexto:=v_ttexto
	                  || ' AND rc.cagente = '
	                  || p_cagente;
	      END IF;

	      v_ntraza:=1120;

	      v_ttexto:=v_ttexto
	                || ' CONNECT BY PRIOR rc.cagente = rc.cpadre and PRIOR fmovfin IS NULL)';
	    END IF;

	    IF p_sperson IS NOT NULL THEN
	      v_ntraza:=1125;

	      v_ttexto:=v_ttexto
	                || ' AND '
	                || p_sperson
	                || ' IN (SELECT sperson FROM tomadores WHERE sseguro = seg.sseguro'
	                || ' UNION '
	                || ' SELECT sperson FROM asegurados WHERE sseguro = seg.sseguro)';
	    END IF;

	    IF p_codigosn IS NOT NULL THEN
	      /* Bug 0016529 - 16/06/2011 - JMF: quito coma final*/
	      IF p_cnegocio=2 THEN
	        /* 2.- Agrupación Productos*/
	        v_ntraza:=1130;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.cagrpro(+) in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=3 THEN
	        /* 3.- Ramos*/
	        v_ntraza:=1135;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.cramo(+) in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=4 THEN
	        /* 4.- Productos*/
	        v_ntraza:=1140;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.sproduc(+) in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=5 AND
	            p_sproduc IS NOT NULL THEN
	        /* 5.- Actividad*/
	        v_ntraza:=1145;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.sproduc(+) = '
	                  || p_sproduc
	                  || ' AND seg.cactivi(+) in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=6 THEN
	        /* 6.- Compañías*/
	        v_ntraza:=1150;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.ccompani(+) in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      END IF;
	    END IF;

	    v_ttexto:=v_ttexto
	              || ')';

	    /*
	          v_ttexto :=
	             v_ttexto
	             || ') UNION ALL  (SELECT FF_DESAGENTE(rc.cagente) tagente, cagente cage, NULL cagrpro, '
	             || '               NULL cramo, NULL cmodali,NULL ctipseg, NULL ccolect, NULL cactivi,NULL ccompani,  '
	             || '                0 Captada, 0 Captada_Ant,0 Anulada,0 Anulada_Ant '
	             || '                                       FROM redcomercial rc '
	             || '                            WHERE rc.cempres = ' || p_cempres
	             || ' START WITH rc.ctipage = ' || p_ctipage || '         AND rc.cagente = '
	             || p_cagente
	             || ' CONNECT BY PRIOR rc.cagente = rc.cpadre
	                                            AND PRIOR fmovfin IS NULL )';
	    */
	    v_ntraza:=1155;

	    v_ttexto:=v_ttexto
	              || ')';

	    /* Bug 0019794 - 18/11/2011 - FAL*/
	    v_text_total:=v_ttexto
	                  || '))';

	    /* Fi Bug 0019794*/
	    v_ttexto:=v_ttexto
	              || ' GROUP BY cage, ff_desagente(cage),'
	              || ' DECODE('
	              || p_cnegocio
	              || ','
	              || ' 1, ff_desvalorfijo(1023, '
	              || p_cidioma
	              || ', 1),'
	              || ' 2, ff_desvalorfijo(283, '
	              || p_cidioma
	              || ', cagrpro),'
	              || ' 3, ff_desramo(cramo, '
	              || p_cidioma
	              || '),'
	              || ' 4, f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, '
	              || p_cidioma
	              || '),'
	              || ' 5, FF_DESACTIVIDAD(cactivi, cramo, '
	              || p_cidioma
	              || ',2),'
	              || ' 6, FF_DESCOMPANIA(ccompani)'
	              || ' )';

	    /* Bug 0019794 - 18/11/2011 - FAL*/
	    v_ttexto:=v_ttexto
	              || ' UNION ALL (select null oficina, null tagente ,null descripcion, sum(vigor_actual), sum(vigor_anterior), sum(vigor_diferencia), null, sum(captada_actual),
	        sum(captada_anterior), sum(captada_diferencia), null, sum(anulada_actual), sum(anulada_anterior),
	        sum(anulada_diferencia), null from ('
	              || v_text_total
	              || ' order by oficina asc';

	    /* Fi Bug 0019794*/
	    v_ntraza:=9999;

	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list001_det02_polizas;

	/******************************************************************************************
	  Descripció: Funció que genera texte select detall per llistat (map 415 dinamic)
	  Paràmetres entrada: - p_cinforme    -> codigo informe (detvalor 1021)
	                      - p_cidioma     -> codigo idioma
	                      - p_cempres     -> codigo empresa
	                      - p_finiefe     -> fecha inicio
	                      - p_ffinefe     -> fecha final
	                      - p_ctipage     -> Tipo (detvalor 1022) (tipo agente)
	                      - p_cagente     -> codigo en funcion del tipo (zona, oficina, agente)
	                      - p_sperson     -> codigo cliente
	                      - p_cnegocio    -> Negocio (detvalor 1023)
	                      - p_codigosn    -> Codigos de negocio (separados por comas)
	                      - p_sproduc     -> Producto de la actividad
	  return:             texte select detall
	******************************************************************************************/
	/* Bug 0016529 - 29/11/2010 - JMF*/
	FUNCTION f_list001_det03_comisiones(
			p_cinforme	IN	NUMBER,
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL,
			p_ctipage	IN	NUMBER DEFAULT NULL,
			p_cagente	IN	NUMBER DEFAULT NULL,
			p_sperson	IN	NUMBER DEFAULT NULL,
			p_cnegocio	IN	NUMBER DEFAULT NULL,
			p_codigosn	IN	VARCHAR2 DEFAULT NULL,
			p_sproduc	IN	VARCHAR2 DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.F_LIST001_DET03_COMISIONES';
	  v_tparam  VARCHAR2(1000):='c='
	                           || p_cinforme
	                           || ' i='
	                           || p_cidioma
	                           || ' e='
	                           || p_cempres
	                           || ' i='
	                           || p_finiefe
	                           || ' f='
	                           || p_ffinefe
	                           || ' t='
	                           || p_ctipage
	                           || ' a='
	                           || p_cagente
	                           || ' p='
	                           || p_sperson
	                           || ' n='
	                           || p_cnegocio
	                           || ' p='
	                           || p_sproduc
	                           || ' c='
	                           || p_codigosn;
	  v_ntraza  NUMBER:=0;
	  v_finiefe VARCHAR2(100);
	  v_ffinefe VARCHAR2(100);
	BEGIN
	    v_ntraza:=1000;

	    v_ttexto:=NULL;

	    v_ttexto_exclu:=NULL; /* 19794*/

	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 3.- Comisiones pagadas*/
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    v_ntraza:=1205;

	    v_finiefe:='to_date('
	               || p_finiefe
	               || ',''yyyymmdd'')';

	    v_ffinefe:='to_date('
	               || p_ffinefe
	               || ',''yyyymmdd'')';

	    v_ntraza:=1210;

	    /* Bug 0016529 - 28/12/2010 - JMF: f_desproducto_t*/
	    v_ttexto:='SELECT cage oficina'
	              || ',ff_desagente(CAGE) tagente,'
	              || 'DECODE('
	              || p_cnegocio
	              || ','
	              || '        1, ff_desvalorfijo(1023, '
	              || p_cidioma
	              || ', 1),'
	              || '        2, ff_desvalorfijo(283, '
	              || p_cidioma
	              || ', cagrpro),'
	              || '        3, ff_desramo(cramo, '
	              || p_cidioma
	              || '),'
	              || '        4, f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, '
	              || p_cidioma
	              || '),'
	              || '        5, FF_DESACTIVIDAD(cactivi, cramo, '
	              || p_cidioma
	              || ',2),'
	              || '        6, FF_DESCOMPANIA(ccompani)'
	              || '        ) descripcion,'
	              || ' sum( decode(actual,1,iliquida,0) ) Pagadas_Actual,'
	              || ' sum( decode(actual,0,iliquida,0) ) Pagadas_Anterior,'
	              || ' sum( decode(actual,1,iliquida,0) )'
	              || '    - sum( decode(actual,0,iliquida,0) ) Pagadas_Diferencia,'
	              || ' decode( sum( decode(actual,0,iliquida,0) ),0,0, '
	              || '    f_round((sum( decode(actual,1,iliquida,0) )'
	              || '    - sum( decode(actual,0,iliquida,0) ))*100'
	              || '    / sum( decode(actual,0,iliquida,0) ))) Pagadas_Porcentaje,'
	              || ' sum( decode(actual,1,decode(ctiprec,0,0,iliquida),0) ) Cartera_Actual,'
	              || ' sum( decode(actual,0,decode(ctiprec,0,0,iliquida),0) ) Cartera_Anterior,'
	              || ' sum( decode(actual,1,decode(ctiprec,0,0,iliquida),0) ) '
	              || '    - sum( decode(actual,0,decode(ctiprec,0,0,iliquida),0) ) Cartera_Diferencia,'
	              || ' decode( sum( decode(actual,0,decode(ctiprec,0,0,iliquida),0) ),0,0,'
	              || '    f_round((sum( decode(actual,1,decode(ctiprec,0,0,iliquida),0) ) '
	              || '    - sum( decode(actual,0,decode(ctiprec,0,0,iliquida),0) ))*100 '
	              || '    / sum( decode(actual,0,decode(ctiprec,0,0,iliquida),0) ))) Cartera_Porcentaje,'
	              || ' sum( decode(actual,1,decode(ctiprec,0,iliquida,0),0) ) Produccion_Actual,'
	              || ' sum( decode(actual,0,decode(ctiprec,0,iliquida,0),0) ) Produccion_Anterior,'
	              || ' sum( decode(actual,1,decode(ctiprec,0,iliquida,0),0) ) '
	              || ' - sum( decode(actual,0,decode(ctiprec,0,iliquida,0),0) ) Produccion_Diferencia,'
	              || ' decode( sum( decode(actual,0,decode(ctiprec,0,iliquida,0),0) ),0,0, '
	              || '    f_round((sum( decode(actual,1,decode(ctiprec,0,iliquida,0),0) ) '
	              || '    - sum( decode(actual,0,decode(ctiprec,0,iliquida,0),0) ))*100'
	              || '    / sum( decode(actual,0,decode(ctiprec,0,iliquida,0),0) ))) Produccion_Porcentaje'
	              || ' FROM ('
	              || ' SELECT 0 actual, FF_DESAGENTE(decode('
	              || p_ctipage
	              || ',0,'
	              || p_cagente
	              || ',rec.cagente)) cagente, rec.cagente cage,'
	              || '         rec.nrecibo, rec.ctiprec, seg.cagrpro, seg.cramo, seg.cmodali,'
	              || '        seg.ctipseg, seg.ccolect, seg.cactivi, seg.ccompani'
	              || '        , decode(rec.ctiprec,9,-1,1)*nvl(imp.icombru,0) iliquida'
	              || '   FROM vdetrecibos imp, recibos rec, seguros seg'
	              || '  WHERE TRUNC(rec.fefecto) >= ADD_MONTHS('
	              || v_finiefe
	              || ', -12)'
	              || '    AND TRUNC(rec.fefecto) <= ADD_MONTHS('
	              || v_ffinefe
	              || ', -12)'
	              || '    AND seg.cempres = '
	              || p_cempres
	              || '    and rec.nrecibo = imp.nrecibo'
	              || '    and seg.sseguro = rec.sseguro';

	    /* 19794*/
	    v_ttexto_exclu:='(SELECT rec.cagente cage '
	                    || '   FROM vdetrecibos imp, recibos rec, seguros seg'
	                    || '  WHERE TRUNC(rec.fefecto) >= ADD_MONTHS('
	                    || v_finiefe
	                    || ', -12)'
	                    || '    AND TRUNC(rec.fefecto) <= ADD_MONTHS('
	                    || v_ffinefe
	                    || ', -12)'
	                    || '    AND seg.cempres = '
	                    || p_cempres
	                    || '    and rec.nrecibo = imp.nrecibo'
	                    || '    and seg.sseguro = rec.sseguro';

	    /* Fi 19794*/
	    IF p_sperson IS NULL THEN
	      v_ntraza:=1215;

	      v_ttexto:=v_ttexto
	                || ' AND '
	                || p_ctipage
	                || ' IN (0,2,4,5)'
	                || ' AND rec.cagente IN (SELECT rc.cagente'
	                || '     FROM redcomercial rc'
	                || '     WHERE rc.cempres = '
	                || p_cempres
	                || '     START WITH rc.ctipage = '
	                || p_ctipage;

	      /* 19794*/
	      v_ttexto_exclu:=v_ttexto_exclu
	                      || ' AND '
	                      || p_ctipage
	                      || ' IN (0,2,4,5)'
	                      || ' AND rec.cagente IN (SELECT rc.cagente'
	                      || '     FROM redcomercial rc'
	                      || '     WHERE rc.cempres = '
	                      || p_cempres
	                      || '     START WITH rc.ctipage = '
	                      || p_ctipage;

	      /* Fi 19794*/
	      IF p_cagente IS NOT NULL AND
	         p_cagente<>-1 /* Bug 0016529 - 29/12/2010 - JMF*/
	      THEN
	        v_ttexto:=v_ttexto
	                  || ' AND rc.cagente = '
	                  || p_cagente;

	        /* 19794*/
	        v_ttexto_exclu:=v_ttexto_exclu
	                        || ' AND rc.cagente = '
	                        || p_cagente;
	      /* Fi 19794*/
	      END IF;

	      v_ntraza:=1220;

	      v_ttexto:=v_ttexto
	                || ' CONNECT BY PRIOR rc.cagente = rc.cpadre and PRIOR fmovfin IS NULL)';

	      /* 19794*/
	      v_ttexto_exclu:=v_ttexto_exclu
	                      || ' CONNECT BY PRIOR rc.cagente = rc.cpadre and PRIOR fmovfin IS NULL)';
	    /* Fi 19794*/
	    END IF;

	    IF p_sperson IS NOT NULL THEN
	      v_ntraza:=1225;

	      v_ttexto:=v_ttexto
	                || ' AND '
	                || p_sperson
	                || ' IN (SELECT sperson FROM tomadores WHERE sseguro = seg.sseguro'
	                || ' UNION'
	                || ' SELECT sperson FROM asegurados WHERE sseguro = seg.sseguro)';

	      /* 19794*/
	      v_ttexto_exclu:=v_ttexto_exclu
	                      || ' AND '
	                      || p_sperson
	                      || ' IN (SELECT sperson FROM tomadores WHERE sseguro = seg.sseguro'
	                      || ' UNION'
	                      || ' SELECT sperson FROM asegurados WHERE sseguro = seg.sseguro)';
	    /* Fi 19794*/
	    END IF;

	    IF p_codigosn IS NOT NULL THEN
	      /* Bug 0016529 - 16/06/2011 - JMF: quito coma final*/
	      IF p_cnegocio=2 THEN
	        /* 2.- Agrupación Productos*/
	        v_ntraza:=1230;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.cagrpro in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';

	        /* 19794*/
	        v_ttexto_exclu:=v_ttexto_exclu
	                        || ' AND seg.cagrpro in ('
	                        || rtrim(p_codigosn, ',')
	                        || ')';
	      /* Fi 19794*/
	      ELSIF p_cnegocio=3 THEN
	        /* 3.- Ramos*/
	        v_ntraza:=1235;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.cramo in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';

	        /* 19794*/
	        v_ttexto_exclu:=v_ttexto_exclu
	                        || ' AND seg.cramo in ('
	                        || rtrim(p_codigosn, ',')
	                        || ')';
	      /* Fi 19794*/
	      ELSIF p_cnegocio=4 THEN
	        /* 4.- Productos*/
	        v_ntraza:=1240;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.sproduc in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';

	        /* 19794*/
	        v_ttexto_exclu:=v_ttexto_exclu
	                        || ' AND seg.sproduc in ('
	                        || rtrim(p_codigosn, ',')
	                        || ')';
	      /* Fi 19794*/
	      ELSIF p_cnegocio=5 AND
	            p_sproduc IS NOT NULL THEN
	        /* 5.- Actividad*/
	        v_ntraza:=1245;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.sproduc = '
	                  || p_sproduc
	                  || ' AND seg.cactivi in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';

	        /* 19794*/
	        v_ttexto_exclu:=v_ttexto_exclu
	                        || ' AND seg.sproduc = '
	                        || p_sproduc
	                        || ' AND seg.cactivi in ('
	                        || rtrim(p_codigosn, ',')
	                        || ')';
	      /* Fi 19794*/
	      ELSIF p_cnegocio=6 THEN
	        /* 6.- Compañías*/
	        v_ntraza:=1250;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.ccompani in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';

	        /* 19794*/
	        v_ttexto_exclu:=v_ttexto_exclu
	                        || ' AND seg.ccompani in ('
	                        || rtrim(p_codigosn, ',')
	                        || ')';
	      /* Fi 19794*/
	      END IF;
	    END IF;

	    v_ntraza:=1255;

	    v_ttexto:=v_ttexto
	              || 'UNION ALL '
	              || ' SELECT 1 actual, FF_DESAGENTE(decode('
	              || p_ctipage
	              || ',0,'
	              || p_cagente
	              || ',rec.cagente)) cagente, rec.cagente cage,'
	              || '         rec.nrecibo, rec.ctiprec, seg.cagrpro, seg.cramo, seg.cmodali,'
	              || '        seg.ctipseg, seg.ccolect, seg.cactivi, seg.ccompani'
	              || '        , decode(rec.ctiprec,9,-1,1)*nvl(imp.icombru,0) iliquida'
	              || '   FROM vdetrecibos imp, recibos rec, seguros seg'
	              || '  WHERE TRUNC(rec.fefecto) >= '
	              || v_finiefe
	              || '    AND TRUNC(rec.fefecto) <= '
	              || v_ffinefe
	              || '    AND seg.cempres = '
	              || p_cempres
	              || '    and rec.nrecibo = imp.nrecibo'
	              || '    and seg.sseguro = rec.sseguro';

	    /* 19794*/
	    v_ttexto_exclu:=v_ttexto_exclu
	                    || 'UNION ALL '
	                    || 'SELECT rec.cagente cage '
	                    || '   FROM vdetrecibos imp, recibos rec, seguros seg'
	                    || '  WHERE TRUNC(rec.fefecto) >= '
	                    || v_finiefe
	                    || '    AND TRUNC(rec.fefecto) <= '
	                    || v_ffinefe
	                    || '    AND seg.cempres = '
	                    || p_cempres
	                    || '    and rec.nrecibo = imp.nrecibo'
	                    || '    and seg.sseguro = rec.sseguro';

	    /* Fi 19794*/
	    IF p_sperson IS NULL THEN
	      v_ntraza:=1260;

	      v_ttexto:=v_ttexto
	                || ' AND  '
	                || p_ctipage
	                || ' IN(0,2,4,5)'
	                || ' AND rec.cagente IN(SELECT rc.cagente'
	                || '     FROM redcomercial rc'
	                || '     WHERE rc.cempres = '
	                || p_cempres
	                || '     START WITH rc.ctipage = '
	                || p_ctipage;

	      /* 19794*/
	      v_ttexto_exclu:=v_ttexto_exclu
	                      || ' AND  '
	                      || p_ctipage
	                      || ' IN(0,2,4,5)'
	                      || ' AND rec.cagente IN(SELECT rc.cagente'
	                      || '     FROM redcomercial rc'
	                      || '     WHERE rc.cempres = '
	                      || p_cempres
	                      || '     START WITH rc.ctipage = '
	                      || p_ctipage;

	      /* Fi 19794*/
	      IF p_cagente IS NOT NULL AND
	         p_cagente<>-1 /* Bug 0016529 - 29/12/2010 - JMF*/
	      THEN
	        v_ttexto:=v_ttexto
	                  || ' AND rc.cagente = '
	                  || p_cagente;

	        /* 19794*/
	        v_ttexto_exclu:=v_ttexto_exclu
	                        || ' AND rc.cagente = '
	                        || p_cagente;
	      /* Fi 19794*/
	      END IF;

	      v_ntraza:=1265;

	      v_ttexto:=v_ttexto
	                || ' CONNECT BY PRIOR rc.cagente = rc.cpadre and PRIOR fmovfin IS NULL)';

	      /* 19794*/
	      v_ttexto_exclu:=v_ttexto_exclu
	                      || ' CONNECT BY PRIOR rc.cagente = rc.cpadre and PRIOR fmovfin IS NULL)';
	    /* Fi 19794*/
	    END IF;

	    IF p_sperson IS NOT NULL THEN
	      v_ntraza:=1270;

	      v_ttexto:=v_ttexto
	                || ' AND '
	                || p_sperson
	                || ' IN(SELECT sperson FROM tomadores WHERE sseguro = seg.sseguro'
	                || ' UNION'
	                || ' SELECT sperson FROM asegurados WHERE sseguro = seg.sseguro)';

	      /* 19794*/
	      v_ttexto_exclu:=v_ttexto_exclu
	                      || ' AND '
	                      || p_sperson
	                      || ' IN(SELECT sperson FROM tomadores WHERE sseguro = seg.sseguro'
	                      || ' UNION'
	                      || ' SELECT sperson FROM asegurados WHERE sseguro = seg.sseguro)';
	    /* Fi 19794*/
	    END IF;

	    IF p_codigosn IS NOT NULL THEN
	      /* Bug 0016529 - 16/06/2011 - JMF: quito coma final*/
	      IF p_cnegocio=2 THEN
	        /* 2.- Agrupación Productos*/
	        v_ntraza:=1275;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.cagrpro in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';

	        /* 19794*/
	        v_ttexto_exclu:=v_ttexto_exclu
	                        || ' AND seg.cagrpro in ('
	                        || rtrim(p_codigosn, ',')
	                        || ')';
	      /* Fi 19794*/
	      ELSIF p_cnegocio=3 THEN
	        /* 3.- Ramos*/
	        v_ntraza:=1280;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.cramo in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';

	        /* 19794*/
	        v_ttexto_exclu:=v_ttexto_exclu
	                        || ' AND seg.cramo in ('
	                        || rtrim(p_codigosn, ',')
	                        || ')';
	      /* Fi 19794*/
	      ELSIF p_cnegocio=4 THEN
	        /* 4.- Productos*/
	        v_ntraza:=1285;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.sproduc in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';

	        /* 19794*/
	        v_ttexto_exclu:=v_ttexto_exclu
	                        || ' AND seg.sproduc in ('
	                        || rtrim(p_codigosn, ',')
	                        || ')';
	      /* Fi 19794*/
	      ELSIF p_cnegocio=5 AND
	            p_sproduc IS NOT NULL THEN
	        /* 5.- Actividad*/
	        v_ntraza:=1290;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.sproduc = '
	                  || p_sproduc
	                  || ' AND seg.cactivi in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';

	        /* 19794*/
	        v_ttexto_exclu:=v_ttexto_exclu
	                        || ' AND seg.sproduc = '
	                        || p_sproduc
	                        || ' AND seg.cactivi in ('
	                        || rtrim(p_codigosn, ',')
	                        || ')';
	      /* Fi 19794*/
	      ELSIF p_cnegocio=6 THEN
	        /* 6.- Compañías*/
	        v_ntraza:=1295;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.ccompani in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';

	        /* 19794*/
	        v_ttexto_exclu:=v_ttexto_exclu
	                        || ' AND seg.ccompani in ('
	                        || rtrim(p_codigosn, ',')
	                        || ')';
	      /* Fi 19794*/
	      END IF;
	    END IF;

	    v_ntraza:=1297;

	    v_ttexto:=v_ttexto
	              || ' UNION ALL  SELECT 1 actual, FF_DESAGENTE(rc.cagente) tagente, cagente cage, '
	              || ' null nrecibo ,null ctiprec, NULL cagrpro, '
	              || '               NULL cramo, NULL cmodali,NULL ctipseg, NULL ccolect, NULL cactivi,NULL ccompani,  '
	              || '                0 iliquida '
	              || '                                       FROM redcomercial rc '
	              || '                            WHERE rc.cempres = '
	              || p_cempres
	              || ' and rc.cagente not in '
	              || v_ttexto_exclu
	              || ')' -- 19794
	              || ' START WITH rc.ctipage = '
	              || p_ctipage
	              || '         AND rc.cagente = '
	              || p_cagente
	              || ' CONNECT BY PRIOR rc.cagente = rc.cpadre
	                                        AND PRIOR fmovfin IS NULL ';

	    /* Bug 0016529 - 28/12/2010 - JMF: f_desproducto_t*/
	    v_ttexto:=v_ttexto
	              || ')';

	    /* Bug 0019794 - 18/11/2011 - FAL*/
	    v_text_total:=v_ttexto
	                  || '))';

	    /* Fi Bug 0019794*/
	    v_ttexto:=v_ttexto
	              ||
	              /* Bug 0019794 - 18/11/2011 - FAL*/
	              ' GROUP BY cage, ff_desagente(cage),'
	              /*                        f_buscazona(' || p_cempres || ', cage,'*/
	              /*                  || p_ctipage || ', f_sysdate)' || ',cage,DECODE(' || p_cagente || ','*/
	              /*                  || '-1, ff_desagente(f_buscazona( ' || p_cempres || ', cage,' || p_ctipage*/
	              /*                  || ', f_sysdate)), cagente),'*/
	              /* Fi Bug 19794*/
	              || ' DECODE('
	              || p_cnegocio
	              || ','
	              || ' 1, ff_desvalorfijo(1023, '
	              || p_cidioma
	              || ', 1),'
	              || ' 2, ff_desvalorfijo(283, '
	              || p_cidioma
	              || ', cagrpro),'
	              || ' 3, ff_desramo(cramo, '
	              || p_cidioma
	              || '),'
	              || ' 4, f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, '
	              || p_cidioma
	              || '),'
	              || ' 5, FF_DESACTIVIDAD(cactivi, cramo, '
	              || p_cidioma
	              || ',2),'
	              || ' 6, FF_DESCOMPANIA(ccompani)'
	              || ' )';

	    /* Bug 0019794 - 18/11/2011 - FAL*/
	    v_ttexto:=v_ttexto
	              || ' UNION ALL (select null oficina, null tagente ,null descripcion, sum(pagadas_actual), sum(pagadas_anterior), sum(pagadas_diferencia), null, sum(cartera_actual),
	        sum(cartera_anterior), sum(cartera_diferencia), null, sum(produccion_actual), sum(produccion_anterior),
	        sum(produccion_diferencia),null from ('
	              || v_text_total
	              || ' order by oficina asc';

	    /* Fi Bug 0019794*/
	    v_ntraza:=9999;

	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list001_det03_comisiones;

	/******************************************************************************************
	  Descripció: Funció que genera texte select detall per llistat (map 415 dinamic)
	  Paràmetres entrada: - p_cinforme    -> codigo informe (detvalor 1021)
	                      - p_cidioma     -> codigo idioma
	                      - p_cempres     -> codigo empresa
	                      - p_finiefe     -> fecha inicio
	                      - p_ffinefe     -> fecha final
	                      - p_ctipage     -> Tipo (detvalor 1022) (tipo agente)
	                      - p_cagente     -> codigo en funcion del tipo (zona, oficina, agente)
	                      - p_sperson     -> codigo cliente
	                      - p_cnegocio    -> Negocio (detvalor 1023)
	                      - p_codigosn    -> Codigos de negocio (separados por comas)
	                      - p_sproduc     -> Producto de la actividad
	  return:             texte select detall
	******************************************************************************************/
	/* Bug 0016529 - 29/11/2010 - JMF*/
	FUNCTION f_list001_det04_negocio(
			p_cinforme	IN	NUMBER,
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL,
			p_ctipage	IN	NUMBER DEFAULT NULL,
			p_cagente	IN	NUMBER DEFAULT NULL,
			p_sperson	IN	NUMBER DEFAULT NULL,
			p_cnegocio	IN	NUMBER DEFAULT NULL,
			p_codigosn	IN	VARCHAR2 DEFAULT NULL,
			p_sproduc	IN	VARCHAR2 DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.F_LIST001_DET04_NEGOCIO';
	  v_tparam  VARCHAR2(1000):='c='
	                           || p_cinforme
	                           || ' i='
	                           || p_cidioma
	                           || ' e='
	                           || p_cempres
	                           || ' i='
	                           || p_finiefe
	                           || ' f='
	                           || p_ffinefe
	                           || ' t='
	                           || p_ctipage
	                           || ' a='
	                           || p_cagente
	                           || ' p='
	                           || p_sperson
	                           || ' n='
	                           || p_cnegocio
	                           || ' p='
	                           || p_sproduc
	                           || ' c='
	                           || p_codigosn;
	  v_ntraza  NUMBER:=0;
	  v_finiefe VARCHAR2(100);
	  v_ffinefe VARCHAR2(100);
	BEGIN
	    v_ntraza:=1000;

	    v_ttexto:=NULL;

	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 4.- Volumen de negocio*/
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    v_ntraza:=1305;

	    v_finiefe:='to_date('
	               || p_finiefe
	               || ',''yyyymmdd'')';

	    v_ffinefe:='to_date('
	               || p_ffinefe
	               || ',''yyyymmdd'')';

	    v_ntraza:=1310;

	    /* Bug 0016529 - 28/12/2010 - JMF: f_desproducto_t*/
	    v_ttexto:='SELECT cage oficina'
	              || ',ff_desagente(CAGE) tagente,'
	              || 'DECODE('
	              || p_cnegocio
	              || ','
	              || '        1, ff_desvalorfijo(1023, '
	              || p_cidioma
	              || ', 1),'
	              || '        2, ff_desvalorfijo(283, '
	              || p_cidioma
	              || ', cagrpro),'
	              || '        3, ff_desramo(cramo, '
	              || p_cidioma
	              || '),'
	              || '        4, f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, '
	              || p_cidioma
	              || '),'
	              || '        5, FF_DESACTIVIDAD(cactivi, cramo, '
	              || p_cidioma
	              || ',2),'
	              || '        6, FF_DESCOMPANIA(ccompani)'
	              || '        ) descripcion,'
	              || ' sum( decode(actual,1,negocio,0) ) negocio_actual,'
	              || ' sum( decode(actual,0,negocio,0) ) negocio_anterior,'
	              || ' sum( decode(actual,1,negocio,0) )'
	              || '    - sum( decode(actual,0,negocio,0) ) negocio_diferencia,'
	              || ' decode( sum( decode(actual,0,negocio,0) ),0,0,'
	              || '    f_round( (sum( decode(actual,1,negocio,0) )'
	              || '    - sum( decode(actual,0,negocio,0) ))*100'
	              || '    / sum( decode(actual,0,negocio,0) ))) negocio_porcentaje,'
	              || ' sum( decode(actual,1,participe,0) ) participe_actual,'
	              || ' sum( decode(actual,0,participe,0) ) participe_anterior,'
	              || ' sum( decode(actual,1,participe,0) )'
	              || '    - sum( decode(actual,0,participe,0) ) participe_diferencia,'
	              || ' decode( sum( decode(actual,0,participe,0) ),0,0,'
	              || '    f_round( (sum( decode(actual,1,participe,0) )'
	              || '    - sum( decode(actual,0,participe,0) ))*100'
	              || '    / sum( decode(actual,0,participe,0) ) )) participe_porcentaje'
	              || ' FROM ('
	              || ' select 0 actual, FF_DESAGENTE(decode('
	              || p_ctipage
	              || ',0,'
	              || p_cagente
	              || ',seg.cagente)) cagente, seg.cagente cage,'
	              || '        seg.cagrpro, seg.cramo, seg.cmodali, seg.ctipseg, seg.ccolect, seg.cactivi, seg.ccompani,'
	              || '  decode(seg.cagrpro'
	              || '        ,14,'
	              || '            (select sum(nvl(gar.iprianu, 0))'
	              || '            from  movseguro mov, garanseg gar'
	              || '            where seg.cagrpro = 14'
	              || '            AND   trunc(mov.fefecto) >= ADD_MONTHS('
	              || v_finiefe
	              || ', -12)'
	              || '            AND   trunc(mov.fefecto) <= ADD_MONTHS('
	              || v_ffinefe
	              || ', -12)'
	              || '            AND mov.sseguro = seg.sseguro'
	              || '            AND mov.cmovseg = 0'
	              || '            AND gar.sseguro = mov.sseguro'
	              || '            AND gar.nmovimi = mov.nmovimi'
	              || '            AND gar.iprianu > 0'
	              || '            )'
	              || '        ,21,'
	              || '            (select sum(nvl(c1.imovimi,0))'
	              || '            from   ctaseguro c1'
	              || '            where  c1.sseguro = seg.sseguro'
	              || '            and    seg.cagrpro = 21'
	              || '            and    fvalmov = (select max(fvalmov) from ctaseguro c2'
	              || '            where c2.sseguro = c1.sseguro'
	              || '            AND   trunc(c2.fvalmov) >= ADD_MONTHS('
	              || v_finiefe
	              || ', -12)'
	              || '            AND   trunc(c2.fvalmov) <= ADD_MONTHS('
	              || v_ffinefe
	              || ', -12)'
	              || '            and   cmovimi = 0)'
	              || '            and   cmovimi in (0,9)'
	              || '            )'
	              || '        ,02,'
	              || '           (select sum(nvl(imovimi,0))'
	              || '            from ctaseguro c1'
	              || '            where c1.sseguro = seg.sseguro'
	              || '            and seg.cagrpro = 2'
	              || '            and fvalmov = (select max(fvalmov) from ctaseguro c2'
	              || '            where c2.sseguro = c1.sseguro'
	              || '            AND   trunc(c2.fvalmov) >= ADD_MONTHS('
	              || v_finiefe
	              || ', -12)'
	              || '            AND   trunc(c2.fvalmov) <= ADD_MONTHS('
	              || v_ffinefe
	              || ', -12)'
	              || '            and cmovimi = 0)'
	              || '            and cmovimi = 0'
	              || '           )'
	              || '       ,0 ) negocio,'
	              || ' decode(f_vigente(seg.sseguro,null, ADD_MONTHS('
	              || v_ffinefe
	              || ', -12)),0,1,0) participe'
	              || '  from  seguros seg'
	              || '  where seg.cempres = '
	              || p_cempres;

	    IF p_sperson IS NULL THEN
	      v_ntraza:=1315;

	      v_ttexto:=v_ttexto
	                || ' AND '
	                || p_ctipage
	                || ' IN (0,2,4,5)'
	                || ' AND seg.cagente IN (SELECT rc.cagente'
	                || '     FROM redcomercial rc'
	                || '     WHERE rc.cempres = '
	                || p_cempres
	                || '     START WITH rc.ctipage = '
	                || p_ctipage;

	      IF p_cagente IS NOT NULL AND
	         p_cagente<>-1 /* Bug 0016529 - 29/12/2010 - JMF*/
	      THEN
	        v_ttexto:=v_ttexto
	                  || ' AND rc.cagente = '
	                  || p_cagente;
	      END IF;

	      v_ntraza:=1320;

	      v_ttexto:=v_ttexto
	                || ' CONNECT BY PRIOR rc.cagente = rc.cpadre and PRIOR fmovfin IS NULL)';
	    END IF;

	    IF p_sperson IS NOT NULL THEN
	      v_ntraza:=1325;

	      v_ttexto:=v_ttexto
	                || ' AND '
	                || p_sperson
	                || ' IN (SELECT sperson FROM tomadores WHERE sseguro = seg.sseguro'
	                || ' UNION'
	                || ' SELECT sperson FROM asegurados WHERE sseguro = seg.sseguro)';
	    END IF;

	    IF p_codigosn IS NOT NULL THEN
	      /* Bug 0016529 - 16/06/2011 - JMF: quito coma final*/
	      IF p_cnegocio=2 THEN
	        /* 2.- Agrupación Productos*/
	        v_ntraza:=1330;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.cagrpro in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=3 THEN
	        /* 3.- Ramos*/
	        v_ntraza:=1335;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.cramo in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=4 THEN
	        /* 4.- Productos*/
	        v_ntraza:=1340;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.sproduc in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=5 AND
	            p_sproduc IS NOT NULL THEN
	        /* 5.- Actividad*/
	        v_ntraza:=1345;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.sproduc = '
	                  || p_sproduc
	                  || ' AND seg.cactivi in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=6 THEN
	        /* 6.- Compañías*/
	        v_ntraza:=1350;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.ccompani in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      END IF;
	    END IF;

	    v_ntraza:=1355;

	    v_ttexto:=v_ttexto
	              || 'UNION ALL '
	              || ' select 1 actual, FF_DESAGENTE(decode('
	              || p_ctipage
	              || ',0,'
	              || p_cagente
	              || ',seg.cagente)) cagente, seg.cagente cage,'
	              || '        seg.cagrpro, seg.cramo, seg.cmodali, seg.ctipseg, seg.ccolect, seg.cactivi, seg.ccompani,'
	              || '  decode(seg.cagrpro'
	              || '        ,14,'
	              || '            (select sum(nvl(gar.iprianu, 0))'
	              || '            from  movseguro mov, garanseg gar'
	              || '            where seg.cagrpro = 14'
	              || '            AND   trunc(mov.fefecto) >= '
	              || v_finiefe
	              || '            AND   trunc(mov.fefecto) <= '
	              || v_ffinefe
	              || '            AND mov.sseguro = seg.sseguro'
	              || '            AND mov.cmovseg = 0'
	              || '            AND gar.sseguro = mov.sseguro'
	              || '            AND gar.nmovimi = mov.nmovimi'
	              || '            AND gar.iprianu > 0'
	              || '            )'
	              || '        ,21,'
	              || '            (select sum(nvl(c1.imovimi,0))'
	              || '            from   ctaseguro c1'
	              || '            where  c1.sseguro = seg.sseguro'
	              || '            and    seg.cagrpro = 21'
	              || '            and    fvalmov = (select max(fvalmov) from ctaseguro c2'
	              || '            where c2.sseguro = c1.sseguro'
	              || '            AND   trunc(c2.fvalmov) >= '
	              || v_finiefe
	              || '            AND   trunc(c2.fvalmov) <= '
	              || v_ffinefe
	              || '            and   cmovimi = 0)'
	              || '            and   cmovimi in (0,9)'
	              || '            )'
	              || '        ,02,'
	              || '           (select sum(nvl(imovimi,0))'
	              || '            from ctaseguro c1'
	              || '            where c1.sseguro = seg.sseguro'
	              || '            and seg.cagrpro = 2'
	              || '            and fvalmov = (select max(fvalmov) from ctaseguro c2'
	              || '            where c2.sseguro = c1.sseguro'
	              || '            AND   trunc(c2.fvalmov) >= '
	              || v_finiefe
	              || '            AND   trunc(c2.fvalmov) <= '
	              || v_ffinefe
	              || '            and cmovimi = 0)'
	              || '            and cmovimi = 0'
	              || '           )'
	              || '       ,0 ) negocio,'
	              || 'decode(f_vigente(seg.sseguro,null, '
	              || v_ffinefe
	              || '),0,1,0) participe'
	              || '  from  seguros seg'
	              || '  where seg.cempres = '
	              || p_cempres;

	    IF p_sperson IS NULL THEN
	      v_ntraza:=1360;

	      v_ttexto:=v_ttexto
	                || ' AND  '
	                || p_ctipage
	                || ' IN(0,2,4,5)'
	                || ' AND seg.cagente IN(SELECT rc.cagente'
	                || '     FROM redcomercial rc'
	                || '     WHERE rc.cempres = '
	                || p_cempres
	                || '     START WITH rc.ctipage = '
	                || p_ctipage;

	      IF p_cagente IS NOT NULL AND
	         p_cagente<>-1 /* Bug 0016529 - 29/12/2010 - JMF*/
	      THEN
	        v_ttexto:=v_ttexto
	                  || ' AND rc.cagente = '
	                  || p_cagente;
	      END IF;

	      v_ntraza:=1365;

	      v_ttexto:=v_ttexto
	                || ' CONNECT BY PRIOR rc.cagente = rc.cpadre and PRIOR fmovfin IS NULL)';
	    END IF;

	    IF p_sperson IS NOT NULL THEN
	      v_ntraza:=1370;

	      v_ttexto:=v_ttexto
	                || ' AND '
	                || p_sperson
	                || ' IN(SELECT sperson FROM tomadores WHERE sseguro = seg.sseguro'
	                || ' UNION'
	                || ' SELECT sperson FROM asegurados WHERE sseguro = seg.sseguro)';
	    END IF;

	    IF p_codigosn IS NOT NULL THEN
	      /* Bug 0016529 - 16/06/2011 - JMF: quito coma final*/
	      IF p_cnegocio=2 THEN
	        /* 2.- Agrupación Productos*/
	        v_ntraza:=1375;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.cagrpro in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=3 THEN
	        /* 3.- Ramos*/
	        v_ntraza:=1380;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.cramo in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=4 THEN
	        /* 4.- Productos*/
	        v_ntraza:=1385;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.sproduc in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=5 AND
	            p_sproduc IS NOT NULL THEN
	        /* 5.- Actividad*/
	        v_ntraza:=1390;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.sproduc = '
	                  || p_sproduc
	                  || ' AND seg.cactivi in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=6 THEN
	        /* 6.- Compañías*/
	        v_ntraza:=1395;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.ccompani in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      END IF;
	    END IF;

	    v_ttexto:=v_ttexto
	              || ' UNION ALL  SELECT 1 actual, FF_DESAGENTE(rc.cagente) tagente, cagente cage, '
	              || '              NULL cagrpro, '
	              || '               NULL cramo, NULL cmodali,NULL ctipseg, NULL ccolect, NULL cactivi,NULL ccompani,  '
	              || '                0 negocio , 0 participe'
	              || '                                       FROM redcomercial rc '
	              || '                            WHERE rc.cagente not in (select cagente from seguros) and rc.cempres = '
	              || p_cempres
	              || ' START WITH rc.ctipage = '
	              || p_ctipage
	              || '         AND rc.cagente = '
	              || p_cagente
	              || ' CONNECT BY PRIOR rc.cagente = rc.cpadre
	                                        AND PRIOR fmovfin IS NULL ';

	    v_ntraza:=1397;

	    /* Bug 0019794 - 18/11/2011 - FAL*/
	    v_ttexto:=v_ttexto
	              || ' )';

	    v_text_total:=v_ttexto
	                  || '))';

	    /* Fi Bug 0019794*/
	    /* Bug 0016529 - 28/12/2010 - JMF: f_desproducto_t*/
	    v_ttexto:=v_ttexto
	              || ' GROUP BY f_buscazona('
	              || p_cempres
	              || ', cage,'
	              || p_ctipage
	              || ', f_sysdate) '
	              || ' ,CAGE, DECODE('
	              || p_cagente
	              || ','
	              || '-1, ff_desagente(f_buscazona( '
	              || p_cempres
	              || ', cage,'
	              || p_ctipage
	              || ', f_sysdate)), cagente),'
	              || ' DECODE('
	              || p_cnegocio
	              || ','
	              || ' 1, ff_desvalorfijo(1023, '
	              || p_cidioma
	              || ', 1),'
	              || ' 2, ff_desvalorfijo(283, '
	              || p_cidioma
	              || ', cagrpro),'
	              || ' 3, ff_desramo(cramo, '
	              || p_cidioma
	              || '),'
	              || ' 4, f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, '
	              || p_cidioma
	              || '),'
	              || ' 5, FF_DESACTIVIDAD(cactivi, cramo, '
	              || p_cidioma
	              || ',2),'
	              || ' 6, FF_DESCOMPANIA(ccompani)'
	              || ')';

	    /* Bug 0019794 - 18/11/2011 - FAL*/
	    v_ttexto:=v_ttexto
	              || ' UNION ALL (select null oficina, null tagente ,null descripcion, sum(negocio_actual), sum(negocio_anterior), sum(negocio_diferencia), null, sum(participe_actual),
	        sum(participe_anterior), sum(participe_diferencia), null from ('
	              || v_text_total
	              || ' order by oficina asc';

	    /* Fi Bug 0019794*/
	    v_ntraza:=9999;

	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list001_det04_negocio;

	/******************************************************************************************
	  Descripció: Funció que genera texte select detall per llistat (map 415 dinamic)
	  Paràmetres entrada: - p_cinforme    -> codigo informe (detvalor 1021)
	                      - p_cidioma     -> codigo idioma
	                      - p_cempres     -> codigo empresa
	                      - p_finiefe     -> fecha inicio
	                      - p_ffinefe     -> fecha final
	                      - p_ctipage     -> Tipo (detvalor 1022) (tipo agente)
	                      - p_cagente     -> codigo en funcion del tipo (zona, oficina, agente)
	                      - p_sperson     -> codigo cliente
	                      - p_cnegocio    -> Negocio (detvalor 1023)
	                      - p_codigosn    -> Codigos de negocio (separados por comas)
	                      - p_sproduc     -> Producto de la actividad
	  return:             texte select detall
	******************************************************************************************/
	/* Bug 0016529 - 29/11/2010 - JMF*/
	FUNCTION f_list001_det05_expedientes(
			p_cinforme	IN	NUMBER,
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL,
			p_ctipage	IN	NUMBER DEFAULT NULL,
			p_cagente	IN	NUMBER DEFAULT NULL,
			p_sperson	IN	NUMBER DEFAULT NULL,
			p_cnegocio	IN	NUMBER DEFAULT NULL,
			p_codigosn	IN	VARCHAR2 DEFAULT NULL,
			p_sproduc	IN	VARCHAR2 DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.F_LIST001_DET05_EXPEDIENTES';
	  v_tparam  VARCHAR2(1000):='c='
	                           || p_cinforme
	                           || ' i='
	                           || p_cidioma
	                           || ' e='
	                           || p_cempres
	                           || ' i='
	                           || p_finiefe
	                           || ' f='
	                           || p_ffinefe
	                           || ' t='
	                           || p_ctipage
	                           || ' a='
	                           || p_cagente
	                           || ' p='
	                           || p_sperson
	                           || ' n='
	                           || p_cnegocio
	                           || ' p='
	                           || p_sproduc
	                           || ' c='
	                           || p_codigosn;
	  v_ntraza  NUMBER:=0;
	  v_finiefe VARCHAR2(100);
	  v_ffinefe VARCHAR2(100);
	BEGIN
	    v_ntraza:=1000;

	    v_ttexto:=NULL;

	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 5.- Siniestros - Número de expedientes*/
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    v_ntraza:=1405;

	    v_finiefe:='to_date('
	               || p_finiefe
	               || ',''yyyymmdd'')';

	    v_ffinefe:='to_date('
	               || p_ffinefe
	               || ',''yyyymmdd'')';

	    v_ntraza:=1410;

	    /* Bug 0016529 - 28/12/2010 - JMF: f_desproducto_t*/
	    v_ttexto:='SELECT cage oficina'
	              || ',ff_desagente(CAGE) tagente,'
	              || 'DECODE('
	              || p_cnegocio
	              || ','
	              || '        1, ff_desvalorfijo(1023, '
	              || p_cidioma
	              || ', 1),'
	              || '        2, ff_desvalorfijo(283, '
	              || p_cidioma
	              || ', cagrpro),'
	              || '        3, ff_desramo(cramo, '
	              || p_cidioma
	              || '),'
	              || '        4, f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, '
	              || p_cidioma
	              || '),'
	              || '        5, FF_DESACTIVIDAD(cactivi, cramo, '
	              || p_cidioma
	              || ',2),'
	              || '        6, FF_DESCOMPANIA(ccompani)'
	              || '        ) descripcion,'
	              || ' SUM( abierto ) siniestro_abierto,'
	              || ' SUM( cerrado ) siniestro_cerrado'
	              || ' FROM ('
	              || ' (SELECT 0 actual, FF_DESAGENTE(decode('
	              || p_ctipage
	              || ',0,'
	              || p_cagente
	              || ',seg.cagente)) cagente, seg.cagente cage,'
	              || '         seg.cagrpro, seg.cramo, seg.cmodali,'
	              || '        seg.ctipseg, seg.ccolect, seg.cactivi, seg.ccompani,'
	              || '        decode(mov.cestsin,0,1,0) abierto, decode(mov.cestsin,1,1,0) cerrado'
	              || '   FROM seguros seg, sin_siniestro sin, sin_movsiniestro mov'
	              || '  WHERE seg.cempres = '
	              || p_cempres
	              || '    AND TRUNC(mov.festsin) >= '
	              || v_finiefe
	              || '    AND TRUNC(mov.festsin) <= '
	              || v_ffinefe
	              || '    AND sin.sseguro = seg.sseguro'
	              || '    AND mov.nsinies = sin.nsinies';

	    IF p_sperson IS NULL THEN
	      v_ntraza:=1415;

	      v_ttexto:=v_ttexto
	                || ' AND '
	                || p_ctipage
	                || ' IN (0,2,4,5)'
	                || ' AND seg.cagente IN (SELECT rc.cagente'
	                || '     FROM redcomercial rc'
	                || '     WHERE rc.cempres = '
	                || p_cempres
	                || '     START WITH rc.ctipage = '
	                || p_ctipage;

	      IF p_cagente IS NOT NULL AND
	         p_cagente<>-1 /* Bug 0016529 - 29/12/2010 - JMF*/
	      THEN
	        v_ttexto:=v_ttexto
	                  || ' AND rc.cagente = '
	                  || p_cagente;
	      END IF;

	      v_ntraza:=1420;

	      v_ttexto:=v_ttexto
	                || ' CONNECT BY PRIOR rc.cagente = rc.cpadre and PRIOR fmovfin IS NULL)';
	    END IF;

	    IF p_sperson IS NOT NULL THEN
	      v_ntraza:=1425;

	      v_ttexto:=v_ttexto
	                || ' AND '
	                || p_sperson
	                || ' IN (SELECT sperson FROM tomadores WHERE sseguro = seg.sseguro'
	                || ' UNION'
	                || ' SELECT sperson FROM asegurados WHERE sseguro = seg.sseguro)';
	    END IF;

	    IF p_codigosn IS NOT NULL THEN
	      /* Bug 0016529 - 16/06/2011 - JMF: quito coma final*/
	      IF p_cnegocio=2 THEN
	        /* 2.- Agrupación Productos*/
	        v_ntraza:=1430;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.cagrpro in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=3 THEN
	        /* 3.- Ramos*/
	        v_ntraza:=1435;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.cramo in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=4 THEN
	        /* 4.- Productos*/
	        v_ntraza:=1440;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.sproduc in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=5 AND
	            p_sproduc IS NOT NULL THEN
	        /* 5.- Actividad*/
	        v_ntraza:=1445;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.sproduc = '
	                  || p_sproduc
	                  || ' AND seg.cactivi in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=6 THEN
	        /* 6.- Compañías*/
	        v_ntraza:=1450;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.ccompani in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      END IF;
	    END IF;

	    v_ttexto:=v_ttexto
	              || ') UNION ALL  (SELECT 0 actual, FF_DESAGENTE(rc.cagente) tagente, cagente cage, '
	              || '              NULL cagrpro, '
	              || '               NULL cramo, NULL cmodali,NULL ctipseg, NULL ccolect, NULL cactivi,NULL ccompani,  '
	              || '                0 abierto , 0 cerrado'
	              || '                                       FROM redcomercial rc '
	              || '                            WHERE rc.cagente NOT IN(SELECT s.cagente
	                                          FROM seguros s, sin_siniestro ss where ss.sseguro = s.sseguro) and rc.cempres = '
	              || p_cempres
	              || ' START WITH rc.ctipage = '
	              || p_ctipage
	              || '         AND rc.cagente = '
	              || p_cagente
	              || ' CONNECT BY PRIOR rc.cagente = rc.cpadre
	                                        AND PRIOR fmovfin IS NULL) ';

	    v_ntraza:=1455;

	    /* Bug 0019794 - 18/11/2011 - FAL*/
	    v_ttexto:=v_ttexto
	              || ' )';

	    v_text_total:=v_ttexto
	                  || '))';

	    /* Fi Bug 0019794*/
	    /* Bug 0016529 - 28/12/2010 - JMF: f_desproducto_t*/
	    v_ttexto:=v_ttexto
	              || ' GROUP BY f_buscazona('
	              || p_cempres
	              || ', cage,'
	              || p_ctipage
	              || ', f_sysdate) '
	              || ',CAGE,DECODE('
	              || p_cagente
	              || ','
	              || '-1, ff_desagente(f_buscazona( '
	              || p_cempres
	              || ', cage,'
	              || p_ctipage
	              || ', f_sysdate)), cagente),'
	              || 'DECODE('
	              || p_cnegocio
	              || ','
	              || ' 1, ff_desvalorfijo(1023, '
	              || p_cidioma
	              || ', 1),'
	              || ' 2, ff_desvalorfijo(283, '
	              || p_cidioma
	              || ', cagrpro),'
	              || ' 3, ff_desramo(cramo, '
	              || p_cidioma
	              || '),'
	              || ' 4, f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, '
	              || p_cidioma
	              || '),'
	              || ' 5, FF_DESACTIVIDAD(cactivi, cramo, '
	              || p_cidioma
	              || ',2),'
	              || ' 6, FF_DESCOMPANIA(ccompani)'
	              || ')';

	    /* Bug 0019794 - 18/11/2011 - FAL*/
	    v_ttexto:=v_ttexto
	              || ' UNION ALL (select null oficina, null tagente ,null descripcion, sum(siniestro_abierto), sum(siniestro_cerrado) from ('
	              || v_text_total
	              || ' order by oficina asc';

	    /* Fi Bug 0019794*/
	    v_ntraza:=9999;

	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list001_det05_expedientes;

	/******************************************************************************************
	  Descripció: Funció que genera texte select detall per llistat (map 415 dinamic)
	  Paràmetres entrada: - p_cinforme    -> codigo informe (detvalor 1021)
	                      - p_cidioma     -> codigo idioma
	                      - p_cempres     -> codigo empresa
	                      - p_finiefe     -> fecha inicio
	                      - p_ffinefe     -> fecha final
	                      - p_ctipage     -> Tipo (detvalor 1022) (tipo agente)
	                      - p_cagente     -> codigo en funcion del tipo (zona, oficina, agente)
	                      - p_sperson     -> codigo cliente
	                      - p_cnegocio    -> Negocio (detvalor 1023)
	                      - p_codigosn    -> Codigos de negocio (separados por comas)
	                      - p_sproduc     -> Producto de la actividad
	  return:             texte select detall
	******************************************************************************************/
	/* Bug 0019794 - 26/11/2011 - FAL*/
	FUNCTION f_list001_det06_exped_no_vida(
			p_cinforme	IN	NUMBER,
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL,
			p_ctipage	IN	NUMBER DEFAULT NULL,
			p_cagente	IN	NUMBER DEFAULT NULL,
			p_sperson	IN	NUMBER DEFAULT NULL,
			p_cnegocio	IN	NUMBER DEFAULT NULL,
			p_codigosn	IN	VARCHAR2 DEFAULT NULL,
			p_sproduc	IN	VARCHAR2 DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.F_LIST001_DET06_EXPED_NO_VIDA';
	  v_tparam  VARCHAR2(1000):='c='
	                           || p_cinforme
	                           || ' i='
	                           || p_cidioma
	                           || ' e='
	                           || p_cempres
	                           || ' i='
	                           || p_finiefe
	                           || ' f='
	                           || p_ffinefe
	                           || ' t='
	                           || p_ctipage
	                           || ' a='
	                           || p_cagente
	                           || ' p='
	                           || p_sperson
	                           || ' n='
	                           || p_cnegocio
	                           || ' p='
	                           || p_sproduc
	                           || ' c='
	                           || p_codigosn;
	  v_ntraza  NUMBER:=0;
	  v_finiefe VARCHAR2(100);
	  v_ffinefe VARCHAR2(100);
	BEGIN
	    v_ntraza:=1000;

	    v_ttexto:=NULL;

	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 6.- Siniestros - Número de expedientes ramo no vida*/
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    v_ntraza:=1405;

	    v_finiefe:='to_date('
	               || p_finiefe
	               || ',''yyyymmdd'')';

	    v_ffinefe:='to_date('
	               || p_ffinefe
	               || ',''yyyymmdd'')';

	    v_ntraza:=1410;

	    v_ttexto:='SELECT cage oficina'
	              || ',ff_desagente(CAGE) tagente,'
	              || 'DECODE('
	              || p_cnegocio
	              || ','
	              || '        1, ff_desvalorfijo(1023, '
	              || p_cidioma
	              || ', 1),'
	              || '        2, ff_desvalorfijo(283, '
	              || p_cidioma
	              || ', cagrpro),'
	              || '        3, ff_desramo(cramo, '
	              || p_cidioma
	              || '),'
	              || '        4, f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, '
	              || p_cidioma
	              || '),'
	              || '        5, FF_DESACTIVIDAD(cactivi, cramo, '
	              || p_cidioma
	              || ',2),'
	              || '        6, FF_DESCOMPANIA(ccompani)'
	              || '        ) descripcion,'
	              || ' SUM( abierto ) siniestro_abierto,'
	              || ' SUM( cerrado ) siniestro_cerrado,'
	              || ' SUM(rechazado) siniestro_rechazado'
	              || ' FROM ('
	              || ' (SELECT 0 actual, FF_DESAGENTE(decode('
	              || p_ctipage
	              || ',0,'
	              || p_cagente
	              || ',seg.cagente)) cagente, seg.cagente cage,'
	              || '         seg.cagrpro, seg.cramo, seg.cmodali,'
	              || '        seg.ctipseg, seg.ccolect, seg.cactivi, seg.ccompani,'
	              || '        decode(mov.cestsin,0,1,0) abierto, decode(mov.cestsin,1,1,0) cerrado, DECODE(mov.cestsin, 3, 1, 0) rechazado'
	              || '   FROM seguros seg, sin_siniestro sin, sin_movsiniestro mov'
	              || '  WHERE seg.cempres = '
	              || p_cempres
	              || '    AND TRUNC(mov.festsin) between '
	              || v_finiefe
	              || ' AND '
	              || v_ffinefe
	              || '    AND sin.sseguro = seg.sseguro'
	              || '    AND mov.nsinies = sin.nsinies'
	              || ' AND seg.cagrpro = 14';

	    IF p_sperson IS NULL THEN
	      v_ntraza:=1415;

	      v_ttexto:=v_ttexto
	                || ' AND '
	                || p_ctipage
	                || ' IN (0,2,4,5)'
	                || ' AND seg.cagente IN (SELECT rc.cagente'
	                || '     FROM redcomercial rc'
	                || '     WHERE rc.cempres = '
	                || p_cempres
	                || '     START WITH rc.ctipage = '
	                || p_ctipage;

	      IF p_cagente IS NOT NULL AND
	         p_cagente<>-1 /* Bug 0016529 - 29/12/2010 - JMF*/
	      THEN
	        v_ttexto:=v_ttexto
	                  || ' AND rc.cagente = '
	                  || p_cagente;
	      END IF;

	      v_ntraza:=1420;

	      v_ttexto:=v_ttexto
	                || ' CONNECT BY PRIOR rc.cagente = rc.cpadre and PRIOR fmovfin IS NULL)';
	    END IF;

	    IF p_sperson IS NOT NULL THEN
	      v_ntraza:=1425;

	      v_ttexto:=v_ttexto
	                || ' AND '
	                || p_sperson
	                || ' IN (SELECT sperson FROM tomadores WHERE sseguro = seg.sseguro'
	                || ' UNION'
	                || ' SELECT sperson FROM asegurados WHERE sseguro = seg.sseguro)';
	    END IF;

	    IF p_codigosn IS NOT NULL THEN
	      /* Bug 0016529 - 16/06/2011 - JMF: quito coma final*/
	      IF p_cnegocio=2 THEN
	        /* 2.- Agrupación Productos*/
	        v_ntraza:=1430;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.cagrpro in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=3 THEN
	        /* 3.- Ramos*/
	        v_ntraza:=1435;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.cramo in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=4 THEN
	        /* 4.- Productos*/
	        v_ntraza:=1440;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.sproduc in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=5 AND
	            p_sproduc IS NOT NULL THEN
	        /* 5.- Actividad*/
	        v_ntraza:=1445;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.sproduc = '
	                  || p_sproduc
	                  || ' AND seg.cactivi in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=6 THEN
	        /* 6.- Compañías*/
	        v_ntraza:=1450;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.ccompani in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      END IF;
	    END IF;

	    v_ttexto:=v_ttexto
	              || ') UNION ALL  (SELECT 0 actual, FF_DESAGENTE(rc.cagente) tagente, cagente cage, '
	              || '              NULL cagrpro, '
	              || '               NULL cramo, NULL cmodali,NULL ctipseg, NULL ccolect, NULL cactivi,NULL ccompani,  '
	              || '                0 abierto , 0 cerrado, 0 rechazado'
	              || '                                       FROM redcomercial rc '
	              || '                            WHERE rc.cagente NOT IN(SELECT s.cagente
	                                          FROM seguros s, sin_siniestro ss where ss.sseguro = s.sseguro) and rc.cempres = '
	              || p_cempres
	              || ' START WITH rc.ctipage = '
	              || p_ctipage
	              || '         AND rc.cagente = '
	              || p_cagente
	              || ' CONNECT BY PRIOR rc.cagente = rc.cpadre
	                                        AND PRIOR fmovfin IS NULL) ';

	    v_ntraza:=1455;

	    /* Bug 0019794 - 18/11/2011 - FAL*/
	    v_ttexto:=v_ttexto
	              || ' )';

	    v_text_total:=v_ttexto
	                  || '))';

	    /* Fi Bug 0019794*/
	    v_ttexto:=v_ttexto
	              || ' GROUP BY f_buscazona('
	              || p_cempres
	              || ', cage,'
	              || p_ctipage
	              || ', f_sysdate) '
	              || ',CAGE,DECODE('
	              || p_cagente
	              || ','
	              || '-1, ff_desagente(f_buscazona( '
	              || p_cempres
	              || ', cage,'
	              || p_ctipage
	              || ', f_sysdate)), cagente),'
	              || 'DECODE('
	              || p_cnegocio
	              || ','
	              || ' 1, ff_desvalorfijo(1023, '
	              || p_cidioma
	              || ', 1),'
	              || ' 2, ff_desvalorfijo(283, '
	              || p_cidioma
	              || ', cagrpro),'
	              || ' 3, ff_desramo(cramo, '
	              || p_cidioma
	              || '),'
	              || ' 4, f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, '
	              || p_cidioma
	              || '),'
	              || ' 5, FF_DESACTIVIDAD(cactivi, cramo, '
	              || p_cidioma
	              || ',2),'
	              || ' 6, FF_DESCOMPANIA(ccompani)'
	              || ')';

	    /* Bug 0019794 - 18/11/2011 - FAL*/
	    v_ttexto:=v_ttexto
	              || ' UNION ALL (select null oficina, null tagente ,null descripcion, sum(siniestro_abierto), sum(siniestro_cerrado), sum(siniestro_rechazado) from ('
	              || v_text_total
	              || ' order by oficina asc';

	    /* Fi Bug 0019794*/
	    v_ntraza:=9999;

	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list001_det06_exped_no_vida;

	/******************************************************************************************
	  Descripció: Funció que genera texte select detall per llistat (map 415 dinamic)
	  Paràmetres entrada: - p_cinforme    -> codigo informe (detvalor 1021)
	                      - p_cidioma     -> codigo idioma
	                      - p_cempres     -> codigo empresa
	                      - p_finiefe     -> fecha inicio
	                      - p_ffinefe     -> fecha final
	                      - p_ctipage     -> Tipo (detvalor 1022) (tipo agente)
	                      - p_cagente     -> codigo en funcion del tipo (zona, oficina, agente)
	                      - p_sperson     -> codigo cliente
	                      - p_cnegocio    -> Negocio (detvalor 1023)
	                      - p_codigosn    -> Codigos de negocio (separados por comas)
	                      - p_sproduc     -> Producto de la actividad
	  return:             texte select detall
	******************************************************************************************/
	FUNCTION f_list001_det07_volsin_no_vida(
			p_cinforme	IN	NUMBER,
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL,
			p_ctipage	IN	NUMBER DEFAULT NULL,
			p_cagente	IN	NUMBER DEFAULT NULL,
			p_sperson	IN	NUMBER DEFAULT NULL,
			p_cnegocio	IN	NUMBER DEFAULT NULL,
			p_codigosn	IN	VARCHAR2 DEFAULT NULL,
			p_sproduc	IN	VARCHAR2 DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.F_LIST001_DET07_VOLSIN_NO_VIDA';
	  v_tparam  VARCHAR2(1000):='c='
	                           || p_cinforme
	                           || ' i='
	                           || p_cidioma
	                           || ' e='
	                           || p_cempres
	                           || ' i='
	                           || p_finiefe
	                           || ' f='
	                           || p_ffinefe
	                           || ' t='
	                           || p_ctipage
	                           || ' a='
	                           || p_cagente
	                           || ' p='
	                           || p_sperson
	                           || ' n='
	                           || p_cnegocio
	                           || ' p='
	                           || p_sproduc
	                           || ' c='
	                           || p_codigosn;
	  v_ntraza  NUMBER:=0;
	  v_finiefe VARCHAR2(100);
	  v_ffinefe VARCHAR2(100);
	BEGIN
	    v_ntraza:=1000;

	    v_ttexto:=NULL;

	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 7.- Siniestros - Volumen siniestralidad ramo no vida*/
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    v_ntraza:=1405;

	    v_finiefe:='to_date('
	               || p_finiefe
	               || ',''yyyymmdd'')';

	    v_ffinefe:='to_date('
	               || p_ffinefe
	               || ',''yyyymmdd'')';

	    v_ntraza:=1410;

	    v_ttexto:='SELECT cage oficina'
	              || ',ff_desagente(CAGE) tagente,'
	              || 'DECODE('
	              || p_cnegocio
	              || ','
	              || '        1, ff_desvalorfijo(1023, '
	              || p_cidioma
	              || ', 1),'
	              || '        2, ff_desvalorfijo(283, '
	              || p_cidioma
	              || ', cagrpro),'
	              || '        3, ff_desramo(cramo, '
	              || p_cidioma
	              || '),'
	              || '        4, f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, '
	              || p_cidioma
	              || '),'
	              || '        5, FF_DESACTIVIDAD(cactivi, cramo, '
	              || p_cidioma
	              || ',2),'
	              || '        6, FF_DESCOMPANIA(ccompani)'
	              || '        ) descripcion,'
	              || ' SUM( isinret ) vol_sini,'
	              || ' SUM( iprianu ) prima_emit,'
	              || ' decode(sum(iprianu),0,0,(SUM(isinret)*100)/SUM(iprianu)) procen_siniestral'
	              || ' FROM ('
	              || ' (SELECT 0 actual, FF_DESAGENTE(decode('
	              || p_ctipage
	              || ',0,'
	              || p_cagente
	              || ',seg.cagente)) cagente, seg.cagente cage,'
	              || '         seg.cagrpro, seg.cramo, seg.cmodali,'
	              || '        seg.ctipseg, seg.ccolect, seg.cactivi, seg.ccompani,'
	              || '        nvl(pag.isinret,0) isinret, NVL(seg.iprianu,0) iprianu'
	              || ' FROM seguros seg, sin_siniestro sin, sin_tramita_pago PAG'
	              || ' WHERE seg.cempres = '
	              || p_cempres
	              || ' AND sin.sseguro = seg.sseguro'
	              || ' AND pag.nsinies = sin.nsinies'
	              || ' AND seg.cagrpro = 14'
	              || ' AND TRUNC(PAG.fordpag) between '
	              || v_finiefe
	              || ' AND '
	              || v_ffinefe;

	    IF p_sperson IS NULL THEN
	      v_ntraza:=1415;

	      v_ttexto:=v_ttexto
	                || ' AND '
	                || p_ctipage
	                || ' IN (0,2,4,5)'
	                || ' AND seg.cagente IN (SELECT rc.cagente'
	                || '     FROM redcomercial rc'
	                || '     WHERE rc.cempres = '
	                || p_cempres
	                || '     START WITH rc.ctipage = '
	                || p_ctipage;

	      IF p_cagente IS NOT NULL AND
	         p_cagente<>-1 /* Bug 0016529 - 29/12/2010 - JMF*/
	      THEN
	        v_ttexto:=v_ttexto
	                  || ' AND rc.cagente = '
	                  || p_cagente;
	      END IF;

	      v_ntraza:=1420;

	      v_ttexto:=v_ttexto
	                || ' CONNECT BY PRIOR rc.cagente = rc.cpadre and PRIOR fmovfin IS NULL)';
	    END IF;

	    IF p_sperson IS NOT NULL THEN
	      v_ntraza:=1425;

	      v_ttexto:=v_ttexto
	                || ' AND '
	                || p_sperson
	                || ' IN (SELECT sperson FROM tomadores WHERE sseguro = seg.sseguro'
	                || ' UNION'
	                || ' SELECT sperson FROM asegurados WHERE sseguro = seg.sseguro)';
	    END IF;

	    IF p_codigosn IS NOT NULL THEN
	      /* Bug 0016529 - 16/06/2011 - JMF: quito coma final*/
	      IF p_cnegocio=2 THEN
	        /* 2.- Agrupación Productos*/
	        v_ntraza:=1430;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.cagrpro in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=3 THEN
	        /* 3.- Ramos*/
	        v_ntraza:=1435;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.cramo in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=4 THEN
	        /* 4.- Productos*/
	        v_ntraza:=1440;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.sproduc in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=5 AND
	            p_sproduc IS NOT NULL THEN
	        /* 5.- Actividad*/
	        v_ntraza:=1445;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.sproduc = '
	                  || p_sproduc
	                  || ' AND seg.cactivi in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=6 THEN
	        /* 6.- Compañías*/
	        v_ntraza:=1450;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.ccompani in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      END IF;
	    END IF;

	    v_ttexto:=v_ttexto
	              || ') UNION ALL  (SELECT 0 actual, FF_DESAGENTE(rc.cagente) tagente, cagente cage, '
	              || '              NULL cagrpro, '
	              || '               NULL cramo, NULL cmodali,NULL ctipseg, NULL ccolect, NULL cactivi,NULL ccompani,  '
	              || '                0 isinret , 0 iprianu'
	              || '                                       FROM redcomercial rc '
	              || '                            WHERE rc.cagente NOT IN(SELECT s.cagente
	                                          FROM seguros s, sin_siniestro ss where ss.sseguro = s.sseguro) and rc.cempres = '
	              || p_cempres
	              || ' START WITH rc.ctipage = '
	              || p_ctipage
	              || '         AND rc.cagente = '
	              || p_cagente
	              || ' CONNECT BY PRIOR rc.cagente = rc.cpadre
	                                        AND PRIOR fmovfin IS NULL) ';

	    v_ntraza:=1455;

	    /* Bug 0019794 - 18/11/2011 - FAL*/
	    v_ttexto:=v_ttexto
	              || ' )';

	    v_text_total:=v_ttexto
	                  || '))';

	    /* Fi Bug 0019794*/
	    v_ttexto:=v_ttexto
	              || ' GROUP BY f_buscazona('
	              || p_cempres
	              || ', cage,'
	              || p_ctipage
	              || ', f_sysdate) '
	              || ',CAGE,DECODE('
	              || p_cagente
	              || ','
	              || '-1, ff_desagente(f_buscazona( '
	              || p_cempres
	              || ', cage,'
	              || p_ctipage
	              || ', f_sysdate)), cagente),'
	              || 'DECODE('
	              || p_cnegocio
	              || ','
	              || ' 1, ff_desvalorfijo(1023, '
	              || p_cidioma
	              || ', 1),'
	              || ' 2, ff_desvalorfijo(283, '
	              || p_cidioma
	              || ', cagrpro),'
	              || ' 3, ff_desramo(cramo, '
	              || p_cidioma
	              || '),'
	              || ' 4, f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, '
	              || p_cidioma
	              || '),'
	              || ' 5, FF_DESACTIVIDAD(cactivi, cramo, '
	              || p_cidioma
	              || ',2),'
	              || ' 6, FF_DESCOMPANIA(ccompani)'
	              || ')';

	    /* Bug 0019794 - 18/11/2011 - FAL*/
	    v_ttexto:=v_ttexto
	              || ' UNION ALL (select null oficina, null tagente ,null descripcion, sum(vol_sini), sum(prima_emit), null procen_siniestral from ('
	              || v_text_total
	              || ' order by oficina asc';

	    /* Fi Bug 0019794*/
	    v_ntraza:=9999;

	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list001_det07_volsin_no_vida;

	/******************************************************************************************
	  Descripció: Funció que genera texte select detall per llistat (map 415 dinamic)
	  Paràmetres entrada: - p_cinforme    -> codigo informe (detvalor 1021)
	                      - p_cidioma     -> codigo idioma
	                      - p_cempres     -> codigo empresa
	                      - p_finiefe     -> fecha inicio
	                      - p_ffinefe     -> fecha final
	                      - p_ctipage     -> Tipo (detvalor 1022) (tipo agente)
	                      - p_cagente     -> codigo en funcion del tipo (zona, oficina, agente)
	                      - p_sperson     -> codigo cliente
	                      - p_cnegocio    -> Negocio (detvalor 1023)
	                      - p_codigosn    -> Codigos de negocio (separados por comas)
	                      - p_sproduc     -> Producto de la actividad
	  return:             texte select detall
	******************************************************************************************/
	FUNCTION f_list001_det08_exped_vida(
			p_cinforme	IN	NUMBER,
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL,
			p_ctipage	IN	NUMBER DEFAULT NULL,
			p_cagente	IN	NUMBER DEFAULT NULL,
			p_sperson	IN	NUMBER DEFAULT NULL,
			p_cnegocio	IN	NUMBER DEFAULT NULL,
			p_codigosn	IN	VARCHAR2 DEFAULT NULL,
			p_sproduc	IN	VARCHAR2 DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.F_LIST001_DET08_EXPED_VIDA';
	  v_tparam  VARCHAR2(1000):='c='
	                           || p_cinforme
	                           || ' i='
	                           || p_cidioma
	                           || ' e='
	                           || p_cempres
	                           || ' i='
	                           || p_finiefe
	                           || ' f='
	                           || p_ffinefe
	                           || ' t='
	                           || p_ctipage
	                           || ' a='
	                           || p_cagente
	                           || ' p='
	                           || p_sperson
	                           || ' n='
	                           || p_cnegocio
	                           || ' p='
	                           || p_sproduc
	                           || ' c='
	                           || p_codigosn;
	  v_ntraza  NUMBER:=0;
	  v_finiefe VARCHAR2(100);
	  v_ffinefe VARCHAR2(100);
	BEGIN
	    v_ntraza:=1000;

	    v_ttexto:=NULL;

	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 8.- Siniestros - Nº expedientes ramo vida*/
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    v_ntraza:=1405;

	    v_finiefe:='to_date('
	               || p_finiefe
	               || ',''yyyymmdd'')';

	    v_ffinefe:='to_date('
	               || p_ffinefe
	               || ',''yyyymmdd'')';

	    v_ntraza:=1410;

	    v_ttexto:='SELECT cage oficina'
	              || ',ff_desagente(CAGE) tagente,'
	              || 'DECODE('
	              || p_cnegocio
	              || ','
	              || '        1, ff_desvalorfijo(1023, '
	              || p_cidioma
	              || ', 1),'
	              || '        2, ff_desvalorfijo(283, '
	              || p_cidioma
	              || ', cagrpro),'
	              || '        3, ff_desramo(cramo, '
	              || p_cidioma
	              || '),'
	              || '        4, f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, '
	              || p_cidioma
	              || '),'
	              || '        5, FF_DESACTIVIDAD(cactivi, cramo, '
	              || p_cidioma
	              || ',2),'
	              || '        6, FF_DESCOMPANIA(ccompani)'
	              || '        ) descripcion,'
	              || ' SUM( abierto ) siniestro_abierto,'
	              || ' SUM( cerrado ) siniestro_cerrado,'
	              || ' SUM(rechazado) siniestro_rechazado, SUM(DECODE(ccausin, 3, 1, 0)) vencimientos, SUM(DECODE(ccausin, 4, 1, 5, 1, 0)) rescates,'
	              || ' SUM(DECODE(ccausin, 13, 1, 0)) rentas, SUM(DECODE(ccausin, 8, 1, 0)) traspasos, SUM(DECODE(ccausin, 3, 0, 4, 0, 5, 0, 8, 0, 13, 0, NULL,0, 1)) siniestros'
	              || ' FROM ('
	              || ' (SELECT distinct sin.nsinies, 0 actual, FF_DESAGENTE(decode('
	              || p_ctipage
	              || ',0,'
	              || p_cagente
	              || ',seg.cagente)) cagente, seg.cagente cage,'
	              || '         seg.cagrpro, seg.cramo, seg.cmodali,'
	              || '        seg.ctipseg, seg.ccolect, seg.cactivi, seg.ccompani,decode(mov.cestsin,0,SIN.ccausin,null) ccausin, '
	              || ' sum(decode(mov.cestsin,0,1,0)) abierto,'
	              || ' sum(decode(mov.cestsin,1,1,0)) cerrado,'
	              || ' sum(DECODE(mov.cestsin, 3, 1, 0)) rechazado '
	              /*     || ' DECODE(sin.ccausin, 3, 1, 0) vencimientos, '*/
	              /*   || ' DECODE(sin.ccausin, 4, 1, 5, 1, 0) rescates,'*/
	              /* || ' DECODE(sin.ccausin, 13, 1, 0) rentas, '*/
	              /* || ' DECODE(sin.ccausin, 8, 1, 0) traspasos,'*/
	              /* || ' DECODE(sin.ccausin, 3, 0, 4, 0, 5, 0, 8, 0, 13, 0, 1) siniestros'*/
	              || ' FROM seguros seg, sin_siniestro sin , sin_movsiniestro mov'
	              || ' WHERE seg.cempres = '
	              || p_cempres
	              || ' AND TRUNC(mov.festsin) between '
	              || v_finiefe
	              || ' AND '
	              || v_ffinefe
	              || ' AND sin.sseguro = seg.sseguro'
	              || ' AND mov.nsinies = sin.nsinies'
	              || ' AND seg.cagrpro = 21';

	    IF p_sperson IS NULL THEN
	      v_ntraza:=1415;

	      v_ttexto:=v_ttexto
	                || ' AND '
	                || p_ctipage
	                || ' IN (0,2,4,5)'
	                || ' AND seg.cagente IN (SELECT rc.cagente'
	                || '     FROM redcomercial rc'
	                || '     WHERE rc.cempres = '
	                || p_cempres
	                || '     START WITH rc.ctipage = '
	                || p_ctipage;

	      IF p_cagente IS NOT NULL AND
	         p_cagente<>-1 /* Bug 0016529 - 29/12/2010 - JMF*/
	      THEN
	        v_ttexto:=v_ttexto
	                  || ' AND rc.cagente = '
	                  || p_cagente;
	      END IF;

	      v_ntraza:=1420;

	      v_ttexto:=v_ttexto
	                || ' CONNECT BY PRIOR rc.cagente = rc.cpadre and PRIOR fmovfin IS NULL)';
	    END IF;

	    IF p_sperson IS NOT NULL THEN
	      v_ntraza:=1425;

	      v_ttexto:=v_ttexto
	                || ' AND '
	                || p_sperson
	                || ' IN (SELECT sperson FROM tomadores WHERE sseguro = seg.sseguro'
	                || ' UNION'
	                || ' SELECT sperson FROM asegurados WHERE sseguro = seg.sseguro)';
	    END IF;

	    IF p_codigosn IS NOT NULL THEN
	      /* Bug 0016529 - 16/06/2011 - JMF: quito coma final*/
	      IF p_cnegocio=2 THEN
	        /* 2.- Agrupación Productos*/
	        v_ntraza:=1430;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.cagrpro in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=3 THEN
	        /* 3.- Ramos*/
	        v_ntraza:=1435;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.cramo in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=4 THEN
	        /* 4.- Productos*/
	        v_ntraza:=1440;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.sproduc in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=5 AND
	            p_sproduc IS NOT NULL THEN
	        /* 5.- Actividad*/
	        v_ntraza:=1445;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.sproduc = '
	                  || p_sproduc
	                  || ' AND seg.cactivi in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=6 THEN
	        /* 6.- Compañías*/
	        v_ntraza:=1450;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.ccompani in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      END IF;
	    END IF;

	    v_ttexto:=v_ttexto
	              || '  group by sin.nsinies,0, seg.cagente, seg.cagrpro, seg.cramo, seg.cmodali,seg.ctipseg, seg.ccolect, seg.cactivi, seg.ccompani, decode(mov.cestsin,0,SIN.ccausin,null) ';

	    v_ttexto:=v_ttexto
	              || ') UNION ALL  (SELECT null nsinies, 0 actual, FF_DESAGENTE(rc.cagente) tagente, cagente cage, '
	              || '              NULL cagrpro, '
	              || '               NULL cramo, NULL cmodali,NULL ctipseg, NULL ccolect, NULL cactivi,NULL ccompani, null ccausin, '
	              || '                0 abierto , 0 cerrado, 0 rechazado ' --', 0 vencimientos, 0 rescates, 0 rentas, 0 traspasos, 0 siniestros'
	              || '                                       FROM redcomercial rc '
	              || '                            WHERE rc.cagente NOT IN(SELECT s.cagente
	                                          FROM seguros s, sin_siniestro ss where ss.sseguro = s.sseguro) and rc.cempres = '
	              || p_cempres
	              || ' START WITH rc.ctipage = '
	              || p_ctipage
	              || '         AND rc.cagente = '
	              || p_cagente
	              || ' CONNECT BY PRIOR rc.cagente = rc.cpadre
	                                        AND PRIOR fmovfin IS NULL) ';

	    v_ntraza:=1455;

	    /* Bug 0019794 - 18/11/2011 - FAL*/
	    v_ttexto:=v_ttexto
	              || ' )';

	    v_text_total:=v_ttexto
	                  || '))';

	    /* Fi Bug 0019794*/
	    v_ttexto:=v_ttexto
	              || ' GROUP BY f_buscazona('
	              || p_cempres
	              || ', cage,'
	              || p_ctipage
	              || ', f_sysdate) '
	              || ',CAGE,DECODE('
	              || p_cagente
	              || ','
	              || '-1, ff_desagente(f_buscazona( '
	              || p_cempres
	              || ', cage,'
	              || p_ctipage
	              || ', f_sysdate)), cagente),'
	              || 'DECODE('
	              || p_cnegocio
	              || ','
	              || ' 1, ff_desvalorfijo(1023, '
	              || p_cidioma
	              || ', 1),'
	              || ' 2, ff_desvalorfijo(283, '
	              || p_cidioma
	              || ', cagrpro),'
	              || ' 3, ff_desramo(cramo, '
	              || p_cidioma
	              || '),'
	              || ' 4, f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, '
	              || p_cidioma
	              || '),'
	              || ' 5, FF_DESACTIVIDAD(cactivi, cramo, '
	              || p_cidioma
	              || ',2),'
	              || ' 6, FF_DESCOMPANIA(ccompani)'
	              || ')';

	    /* Bug 0019794 - 18/11/2011 - FAL*/
	    v_ttexto:=v_ttexto
	              || ' UNION ALL (select null oficina, null tagente ,null descripcion, sum(siniestro_abierto), sum(siniestro_cerrado),'
	              || ' sum(siniestro_rechazado), sum(vencimientos), sum(rescates), sum(rentas), sum(traspasos), sum(siniestros) from ('
	              || v_text_total
	              || ' order by oficina asc';

	    /* Fi Bug 0019794*/
	    v_ntraza:=9999;

	    p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                        || ': Error'
	                                                        || SQLCODE, 'Ini efe:'
	                                                                    || v_finiefe
	                                                                    || 'Fin efe:'
	                                                                    || v_ffinefe);

	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list001_det08_exped_vida;

	/******************************************************************************************
	  Descripció: Funció que genera texte select detall per llistat (map 415 dinamic)
	  Paràmetres entrada: - p_cinforme    -> codigo informe (detvalor 1021)
	                      - p_cidioma     -> codigo idioma
	                      - p_cempres     -> codigo empresa
	                      - p_finiefe     -> fecha inicio
	                      - p_ffinefe     -> fecha final
	                      - p_ctipage     -> Tipo (detvalor 1022) (tipo agente)
	                      - p_cagente     -> codigo en funcion del tipo (zona, oficina, agente)
	                      - p_sperson     -> codigo cliente
	                      - p_cnegocio    -> Negocio (detvalor 1023)
	                      - p_codigosn    -> Codigos de negocio (separados por comas)
	                      - p_sproduc     -> Producto de la actividad
	  return:             texte select detall
	******************************************************************************************/
	FUNCTION f_list001_det09_volsini_vida(
			p_cinforme	IN	NUMBER,
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL,
			p_ctipage	IN	NUMBER DEFAULT NULL,
			p_cagente	IN	NUMBER DEFAULT NULL,
			p_sperson	IN	NUMBER DEFAULT NULL,
			p_cnegocio	IN	NUMBER DEFAULT NULL,
			p_codigosn	IN	VARCHAR2 DEFAULT NULL,
			p_sproduc	IN	VARCHAR2 DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.F_LIST001_DET09_VOLSINI_VIDA';
	  v_tparam  VARCHAR2(1000):='c='
	                           || p_cinforme
	                           || ' i='
	                           || p_cidioma
	                           || ' e='
	                           || p_cempres
	                           || ' i='
	                           || p_finiefe
	                           || ' f='
	                           || p_ffinefe
	                           || ' t='
	                           || p_ctipage
	                           || ' a='
	                           || p_cagente
	                           || ' p='
	                           || p_sperson
	                           || ' n='
	                           || p_cnegocio
	                           || ' p='
	                           || p_sproduc
	                           || ' c='
	                           || p_codigosn;
	  v_ntraza  NUMBER:=0;
	  v_finiefe VARCHAR2(100);
	  v_ffinefe VARCHAR2(100);
	BEGIN
	    v_ntraza:=1000;

	    v_ttexto:=NULL;

	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 9.- Siniestros - Volumen siniestralidad ramo vida*/
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    v_ntraza:=1405;

	    v_finiefe:='to_date('
	               || p_finiefe
	               || ',''yyyymmdd'')';

	    v_ffinefe:='to_date('
	               || p_ffinefe
	               || ',''yyyymmdd'')';

	    v_ntraza:=1410;

	    v_ttexto:='SELECT cage oficina'
	              || ',ff_desagente(CAGE) tagente,'
	              || 'DECODE('
	              || p_cnegocio
	              || ','
	              || '        1, ff_desvalorfijo(1023, '
	              || p_cidioma
	              || ', 1),'
	              || '        2, ff_desvalorfijo(283, '
	              || p_cidioma
	              || ', cagrpro),'
	              || '        3, ff_desramo(cramo, '
	              || p_cidioma
	              || '),'
	              || '        4, f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, '
	              || p_cidioma
	              || '),'
	              || '        5, FF_DESACTIVIDAD(cactivi, cramo, '
	              || p_cidioma
	              || ',2),'
	              || '        6, FF_DESCOMPANIA(ccompani)'
	              || '        ) descripcion,'
	              || ' SUM(vencimientos) vencimientos,'
	              || ' SUM(rescates) rescates,'
	              || ' SUM(rentas) rentas, SUM(traspasos) traspasos, SUM(siniestros) siniestros'
	              || ' FROM ('
	              || ' (SELECT 0 actual, FF_DESAGENTE(decode('
	              || p_ctipage
	              || ',0,'
	              || p_cagente
	              || ',seg.cagente)) cagente, seg.cagente cage,'
	              || '         seg.cagrpro, seg.cramo, seg.cmodali,'
	              || '        seg.ctipseg, seg.ccolect, seg.cactivi, seg.ccompani,'
	              || '        DECODE(sin.ccausin, 3, pag.isinret, 0) vencimientos, DECODE(sin.ccausin, 4, nvl(pag.isinret,0), 5, nvl(pag.isinret,0), 0) rescates,'
	              || '        DECODE(sin.ccausin, 13, nvl(pag.isinret,0), 0) rentas, DECODE(sin.ccausin, 8, nvl(pag.isinret,0), 0) traspasos,'
	              || '        DECODE(sin.ccausin, 3, 0, 4, 0, 5, 0, 8, 0, 13, 0, nvl(pag.isinret,0)) siniestros'
	              || ' FROM seguros seg, sin_siniestro sin, sin_tramita_pago PAG '
	              || ' WHERE seg.cempres = '
	              || p_cempres
	              || ' AND sin.sseguro = seg.sseguro'
	              || ' AND sin.nsinies = PAG.nsinies'
	              || ' AND TRUNC(PAG.fordpag) between '
	              || v_finiefe
	              || ' AND '
	              || v_ffinefe
	              || ' AND seg.cagrpro = 21';

	    IF p_sperson IS NULL THEN
	      v_ntraza:=1415;

	      v_ttexto:=v_ttexto
	                || ' AND '
	                || p_ctipage
	                || ' IN (0,2,4,5)'
	                || ' AND seg.cagente IN (SELECT rc.cagente'
	                || '     FROM redcomercial rc'
	                || '     WHERE rc.cempres = '
	                || p_cempres
	                || '     START WITH rc.ctipage = '
	                || p_ctipage;

	      IF p_cagente IS NOT NULL AND
	         p_cagente<>-1 /* Bug 0016529 - 29/12/2010 - JMF*/
	      THEN
	        v_ttexto:=v_ttexto
	                  || ' AND rc.cagente = '
	                  || p_cagente;
	      END IF;

	      v_ntraza:=1420;

	      v_ttexto:=v_ttexto
	                || ' CONNECT BY PRIOR rc.cagente = rc.cpadre and PRIOR fmovfin IS NULL)';
	    END IF;

	    IF p_sperson IS NOT NULL THEN
	      v_ntraza:=1425;

	      v_ttexto:=v_ttexto
	                || ' AND '
	                || p_sperson
	                || ' IN (SELECT sperson FROM tomadores WHERE sseguro = seg.sseguro'
	                || ' UNION'
	                || ' SELECT sperson FROM asegurados WHERE sseguro = seg.sseguro)';
	    END IF;

	    IF p_codigosn IS NOT NULL THEN
	      /* Bug 0016529 - 16/06/2011 - JMF: quito coma final*/
	      IF p_cnegocio=2 THEN
	        /* 2.- Agrupación Productos*/
	        v_ntraza:=1430;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.cagrpro in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=3 THEN
	        /* 3.- Ramos*/
	        v_ntraza:=1435;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.cramo in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=4 THEN
	        /* 4.- Productos*/
	        v_ntraza:=1440;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.sproduc in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=5 AND
	            p_sproduc IS NOT NULL THEN
	        /* 5.- Actividad*/
	        v_ntraza:=1445;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.sproduc = '
	                  || p_sproduc
	                  || ' AND seg.cactivi in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=6 THEN
	        /* 6.- Compañías*/
	        v_ntraza:=1450;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.ccompani in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      END IF;
	    END IF;

	    v_ttexto:=v_ttexto
	              || ') UNION ALL  (SELECT 0 actual, FF_DESAGENTE(rc.cagente) tagente, cagente cage, '
	              || '              NULL cagrpro, '
	              || '               NULL cramo, NULL cmodali,NULL ctipseg, NULL ccolect, NULL cactivi,NULL ccompani,  '
	              || '               0 vencimientos, 0 rescates, 0 rentas, 0 traspasos, 0 siniestros'
	              || '                                       FROM redcomercial rc '
	              || '                            WHERE rc.cagente NOT IN(SELECT s.cagente
	                                          FROM seguros s, sin_siniestro ss where ss.sseguro = s.sseguro) and rc.cempres = '
	              || p_cempres
	              || ' START WITH rc.ctipage = '
	              || p_ctipage
	              || '         AND rc.cagente = '
	              || p_cagente
	              || ' CONNECT BY PRIOR rc.cagente = rc.cpadre
	                                        AND PRIOR fmovfin IS NULL) ';

	    v_ntraza:=1455;

	    /* Bug 0019794 - 18/11/2011 - FAL*/
	    v_ttexto:=v_ttexto
	              || ' )';

	    v_text_total:=v_ttexto
	                  || '))';

	    /* Fi Bug 0019794*/
	    v_ttexto:=v_ttexto
	              || ' GROUP BY f_buscazona('
	              || p_cempres
	              || ', cage,'
	              || p_ctipage
	              || ', f_sysdate) '
	              || ',CAGE,DECODE('
	              || p_cagente
	              || ','
	              || '-1, ff_desagente(f_buscazona( '
	              || p_cempres
	              || ', cage,'
	              || p_ctipage
	              || ', f_sysdate)), cagente),'
	              || 'DECODE('
	              || p_cnegocio
	              || ','
	              || ' 1, ff_desvalorfijo(1023, '
	              || p_cidioma
	              || ', 1),'
	              || ' 2, ff_desvalorfijo(283, '
	              || p_cidioma
	              || ', cagrpro),'
	              || ' 3, ff_desramo(cramo, '
	              || p_cidioma
	              || '),'
	              || ' 4, f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, '
	              || p_cidioma
	              || '),'
	              || ' 5, FF_DESACTIVIDAD(cactivi, cramo, '
	              || p_cidioma
	              || ',2),'
	              || ' 6, FF_DESCOMPANIA(ccompani)'
	              || ')';

	    /* Bug 0019794 - 18/11/2011 - FAL*/
	    v_ttexto:=v_ttexto
	              || ' UNION ALL (select null oficina, null tagente ,null descripcion,'
	              || ' sum(vencimientos), sum(rescates), sum(rentas), sum(traspasos), sum(siniestros) from ('
	              || v_text_total
	              || ' order by oficina asc';

	    /* Fi Bug 0019794*/
	    v_ntraza:=9999;

	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list001_det09_volsini_vida;

	/******************************************************************************************
	  Descripció: Funció que genera texte select detall per llistat (map 415 dinamic)
	  Paràmetres entrada: - p_cinforme    -> codigo informe (detvalor 1021)
	                      - p_cidioma     -> codigo idioma
	                      - p_cempres     -> codigo empresa
	                      - p_finiefe     -> fecha inicio
	                      - p_ffinefe     -> fecha final
	                      - p_ctipage     -> Tipo (detvalor 1022) (tipo agente)
	                      - p_cagente     -> codigo en funcion del tipo (zona, oficina, agente)
	                      - p_sperson     -> codigo cliente
	                      - p_cnegocio    -> Negocio (detvalor 1023)
	                      - p_codigosn    -> Codigos de negocio (separados por comas)
	                      - p_sproduc     -> Producto de la actividad
	  return:             texte select detall
	******************************************************************************************/
	FUNCTION f_list001_det10_exped_pens(
			p_cinforme	IN	NUMBER,
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL,
			p_ctipage	IN	NUMBER DEFAULT NULL,
			p_cagente	IN	NUMBER DEFAULT NULL,
			p_sperson	IN	NUMBER DEFAULT NULL,
			p_cnegocio	IN	NUMBER DEFAULT NULL,
			p_codigosn	IN	VARCHAR2 DEFAULT NULL,
			p_sproduc	IN	VARCHAR2 DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.F_LIST001_DET10_EXPED_PENS';
	  v_tparam  VARCHAR2(1000):='c='
	                           || p_cinforme
	                           || ' i='
	                           || p_cidioma
	                           || ' e='
	                           || p_cempres
	                           || ' i='
	                           || p_finiefe
	                           || ' f='
	                           || p_ffinefe
	                           || ' t='
	                           || p_ctipage
	                           || ' a='
	                           || p_cagente
	                           || ' p='
	                           || p_sperson
	                           || ' n='
	                           || p_cnegocio
	                           || ' p='
	                           || p_sproduc
	                           || ' c='
	                           || p_codigosn;
	  v_ntraza  NUMBER:=0;
	  v_finiefe VARCHAR2(100);
	  v_ffinefe VARCHAR2(100);
	BEGIN
	    v_ntraza:=1000;

	    v_ttexto:=NULL;

	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 10.- Siniestros - Nº expedientes pensiones*/
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    v_ntraza:=1405;

	    v_finiefe:='to_date('
	               || p_finiefe
	               || ',''yyyymmdd'')';

	    v_ffinefe:='to_date('
	               || p_ffinefe
	               || ',''yyyymmdd'')';

	    v_ntraza:=1410;

	    v_ttexto:='SELECT cage oficina'
	              || ',ff_desagente(CAGE) tagente,'
	              || 'DECODE('
	              || p_cnegocio
	              || ','
	              || '        1, ff_desvalorfijo(1023, '
	              || p_cidioma
	              || ', 1),'
	              || '        2, ff_desvalorfijo(283, '
	              || p_cidioma
	              || ', cagrpro),'
	              || '        3, ff_desramo(cramo, '
	              || p_cidioma
	              || '),'
	              || '        4, f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, '
	              || p_cidioma
	              || '),'
	              || '        5, FF_DESACTIVIDAD(cactivi, cramo, '
	              || p_cidioma
	              || ',2),'
	              || '        6, FF_DESCOMPANIA(ccompani)'
	              || '        ) descripcion,'
	              || ' SUM(jubilacion) jubilacion,'
	              || ' SUM(enfermedad) enfermedad,'
	              || ' SUM(incapacidad) incapacidad, SUM(fallecimiento) fallecimiento, SUM(paro) paro'
	              || ' FROM ('
	              || ' (SELECT 0 actual, FF_DESAGENTE(decode('
	              || p_ctipage
	              || ',0,'
	              || p_cagente
	              || ',seg.cagente)) cagente, seg.cagente cage,'
	              || ' seg.cagrpro, seg.cramo, seg.cmodali,'
	              || ' seg.ctipseg, seg.ccolect, seg.cactivi, seg.ccompani,'
	              || ' DECODE(sin.ccausin, 7008, 1, 0) jubilacion, DECODE(sin.ccausin, 7014, 1, 0) enfermedad,'
	              || ' DECODE(sin.ccausin, 7012, 1, 0) incapacidad, DECODE(sin.ccausin, 7009, 1, 0) fallecimiento,'
	              || ' DECODE(sin.ccausin, 7013, 1, 0) paro'
	              || '   FROM seguros seg, sin_siniestro sin, sin_movsiniestro mov'
	              || '  WHERE seg.cempres = '
	              || p_cempres
	              || ' AND TRUNC(mov.festsin) between  '
	              || v_finiefe
	              || ' AND '
	              || v_ffinefe
	              || ' AND sin.sseguro = seg.sseguro'
	              || ' AND mov.nsinies = sin.nsinies '
	              || ' AND mov.cestsin = 0 '
	              || ' and (seg.cramo = 59 or seg.ccompani = 33)';

	    IF p_sperson IS NULL THEN
	      v_ntraza:=1415;

	      v_ttexto:=v_ttexto
	                || ' AND '
	                || p_ctipage
	                || ' IN (0,2,4,5)'
	                || ' AND seg.cagente IN (SELECT rc.cagente'
	                || '     FROM redcomercial rc'
	                || '     WHERE rc.cempres = '
	                || p_cempres
	                || '     START WITH rc.ctipage = '
	                || p_ctipage;

	      IF p_cagente IS NOT NULL AND
	         p_cagente<>-1 /* Bug 0016529 - 29/12/2010 - JMF*/
	      THEN
	        v_ttexto:=v_ttexto
	                  || ' AND rc.cagente = '
	                  || p_cagente;
	      END IF;

	      v_ntraza:=1420;

	      v_ttexto:=v_ttexto
	                || ' CONNECT BY PRIOR rc.cagente = rc.cpadre and PRIOR fmovfin IS NULL)';
	    END IF;

	    IF p_sperson IS NOT NULL THEN
	      v_ntraza:=1425;

	      v_ttexto:=v_ttexto
	                || ' AND '
	                || p_sperson
	                || ' IN (SELECT sperson FROM tomadores WHERE sseguro = seg.sseguro'
	                || ' UNION'
	                || ' SELECT sperson FROM asegurados WHERE sseguro = seg.sseguro)';
	    END IF;

	    IF p_codigosn IS NOT NULL THEN
	      /* Bug 0016529 - 16/06/2011 - JMF: quito coma final*/
	      IF p_cnegocio=2 THEN
	        /* 2.- Agrupación Productos*/
	        v_ntraza:=1430;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.cagrpro in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=3 THEN
	        /* 3.- Ramos*/
	        v_ntraza:=1435;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.cramo in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=4 THEN
	        /* 4.- Productos*/
	        v_ntraza:=1440;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.sproduc in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=5 AND
	            p_sproduc IS NOT NULL THEN
	        /* 5.- Actividad*/
	        v_ntraza:=1445;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.sproduc = '
	                  || p_sproduc
	                  || ' AND seg.cactivi in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=6 THEN
	        /* 6.- Compañías*/
	        v_ntraza:=1450;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.ccompani in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      END IF;
	    END IF;

	    v_ttexto:=v_ttexto
	              || ') UNION ALL  (SELECT 0 actual, FF_DESAGENTE(rc.cagente) tagente, cagente cage, '
	              || '              NULL cagrpro, '
	              || '               NULL cramo, NULL cmodali,NULL ctipseg, NULL ccolect, NULL cactivi,NULL ccompani,  '
	              || '               0 jubilacion, 0 enfermedad, 0 incapacidad, 0 fallecimiento, 0 paro'
	              || '                                       FROM redcomercial rc '
	              || '                            WHERE rc.cagente NOT IN(SELECT s.cagente
	                                          FROM seguros s, sin_siniestro ss where ss.sseguro = s.sseguro) and rc.cempres = '
	              || p_cempres
	              || ' START WITH rc.ctipage = '
	              || p_ctipage
	              || '         AND rc.cagente = '
	              || p_cagente
	              || ' CONNECT BY PRIOR rc.cagente = rc.cpadre
	                                        AND PRIOR fmovfin IS NULL) ';

	    v_ntraza:=1455;

	    /* Bug 0019794 - 18/11/2011 - FAL*/
	    v_ttexto:=v_ttexto
	              || ' )';

	    v_text_total:=v_ttexto
	                  || '))';

	    /* Fi Bug 0019794*/
	    v_ttexto:=v_ttexto
	              || ' GROUP BY f_buscazona('
	              || p_cempres
	              || ', cage,'
	              || p_ctipage
	              || ', f_sysdate) '
	              || ',CAGE,DECODE('
	              || p_cagente
	              || ','
	              || '-1, ff_desagente(f_buscazona( '
	              || p_cempres
	              || ', cage,'
	              || p_ctipage
	              || ', f_sysdate)), cagente),'
	              || 'DECODE('
	              || p_cnegocio
	              || ','
	              || ' 1, ff_desvalorfijo(1023, '
	              || p_cidioma
	              || ', 1),'
	              || ' 2, ff_desvalorfijo(283, '
	              || p_cidioma
	              || ', cagrpro),'
	              || ' 3, ff_desramo(cramo, '
	              || p_cidioma
	              || '),'
	              || ' 4, f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, '
	              || p_cidioma
	              || '),'
	              || ' 5, FF_DESACTIVIDAD(cactivi, cramo, '
	              || p_cidioma
	              || ',2),'
	              || ' 6, FF_DESCOMPANIA(ccompani)'
	              || ')';

	    /* Bug 0019794 - 18/11/2011 - FAL*/
	    v_ttexto:=v_ttexto
	              || ' UNION ALL (select null oficina, null tagente ,null descripcion,'
	              || ' sum(jubilacion), sum(enfermedad), sum(incapacidad), sum(fallecimiento), sum(paro) from ('
	              || v_text_total
	              || ' order by oficina asc';

	    /* Fi Bug 0019794*/
	    v_ntraza:=9999;

	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list001_det10_exped_pens;

	/******************************************************************************************
	  Descripció: Funció que genera texte select detall per llistat (map 415 dinamic)
	  Paràmetres entrada: - p_cinforme    -> codigo informe (detvalor 1021)
	                      - p_cidioma     -> codigo idioma
	                      - p_cempres     -> codigo empresa
	                      - p_finiefe     -> fecha inicio
	                      - p_ffinefe     -> fecha final
	                      - p_ctipage     -> Tipo (detvalor 1022) (tipo agente)
	                      - p_cagente     -> codigo en funcion del tipo (zona, oficina, agente)
	                      - p_sperson     -> codigo cliente
	                      - p_cnegocio    -> Negocio (detvalor 1023)
	                      - p_codigosn    -> Codigos de negocio (separados por comas)
	                      - p_sproduc     -> Producto de la actividad
	  return:             texte select detall
	******************************************************************************************/
	FUNCTION f_list001_det11_volsini_pens(
			p_cinforme	IN	NUMBER,
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL,
			p_ctipage	IN	NUMBER DEFAULT NULL,
			p_cagente	IN	NUMBER DEFAULT NULL,
			p_sperson	IN	NUMBER DEFAULT NULL,
			p_cnegocio	IN	NUMBER DEFAULT NULL,
			p_codigosn	IN	VARCHAR2 DEFAULT NULL,
			p_sproduc	IN	VARCHAR2 DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.F_LIST001_DET11_VOLSINI_PENS';
	  v_tparam  VARCHAR2(1000):='c='
	                           || p_cinforme
	                           || ' i='
	                           || p_cidioma
	                           || ' e='
	                           || p_cempres
	                           || ' i='
	                           || p_finiefe
	                           || ' f='
	                           || p_ffinefe
	                           || ' t='
	                           || p_ctipage
	                           || ' a='
	                           || p_cagente
	                           || ' p='
	                           || p_sperson
	                           || ' n='
	                           || p_cnegocio
	                           || ' p='
	                           || p_sproduc
	                           || ' c='
	                           || p_codigosn;
	  v_ntraza  NUMBER:=0;
	  v_finiefe VARCHAR2(100);
	  v_ffinefe VARCHAR2(100);
	BEGIN
	    v_ntraza:=1000;

	    v_ttexto:=NULL;

	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 11.- Siniestros - Volumen siniestralidad pensiones*/
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    v_ntraza:=1405;

	    v_finiefe:='to_date('
	               || p_finiefe
	               || ',''yyyymmdd'')';

	    v_ffinefe:='to_date('
	               || p_ffinefe
	               || ',''yyyymmdd'')';

	    v_ntraza:=1410;

	    v_ttexto:='SELECT cage oficina'
	              || ',ff_desagente(CAGE) tagente,'
	              || 'DECODE('
	              || p_cnegocio
	              || ','
	              || '        1, ff_desvalorfijo(1023, '
	              || p_cidioma
	              || ', 1),'
	              || '        2, ff_desvalorfijo(283, '
	              || p_cidioma
	              || ', cagrpro),'
	              || '        3, ff_desramo(cramo, '
	              || p_cidioma
	              || '),'
	              || '        4, f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, '
	              || p_cidioma
	              || '),'
	              || '        5, FF_DESACTIVIDAD(cactivi, cramo, '
	              || p_cidioma
	              || ',2),'
	              || '        6, FF_DESCOMPANIA(ccompani)'
	              || '        ) descripcion,'
	              || ' SUM(jubilacion) jubilacion,'
	              || ' SUM(enfermedad) enfermedad,'
	              || ' SUM(incapacidad) incapacidad, SUM(fallecimiento) fallecimiento, SUM(paro) paro'
	              || ' FROM ('
	              || ' (SELECT 0 actual, FF_DESAGENTE(decode('
	              || p_ctipage
	              || ',0,'
	              || p_cagente
	              || ',seg.cagente)) cagente, seg.cagente cage,'
	              || '  seg.cagrpro, seg.cramo, seg.cmodali,'
	              || ' seg.ctipseg, seg.ccolect, seg.cactivi, seg.ccompani,'
	              || ' DECODE(sin.ccausin, 7008, nvl(pag.isinret,0), 0) jubilacion, DECODE(sin.ccausin, 7014, nvl(pag.isinret,0), 0) enfermedad,'
	              || ' DECODE(sin.ccausin, 7012, nvl(pag.isinret,0), 0) incapacidad, DECODE(sin.ccausin, 7009, nvl(pag.isinret,0), 0) fallecimiento,'
	              || ' DECODE(sin.ccausin, 7013, nvl(pag.isinret,0), 0) paro'
	              || ' FROM seguros seg, sin_siniestro sin,  sin_tramita_pago PAG'
	              || ' WHERE seg.cempres = '
	              || p_cempres
	              || ' AND sin.sseguro = seg.sseguro'
	              || ' AND sin.nsinies = PAG.nsinies'
	              || ' AND TRUNC(pag.fordpag) between '
	              || v_finiefe
	              || ' AND '
	              || v_ffinefe
	              || ' and (seg.cramo = 59 or seg.ccompani = 33)';

	    IF p_sperson IS NULL THEN
	      v_ntraza:=1415;

	      v_ttexto:=v_ttexto
	                || ' AND '
	                || p_ctipage
	                || ' IN (0,2,4,5)'
	                || ' AND seg.cagente IN (SELECT rc.cagente'
	                || '     FROM redcomercial rc'
	                || '     WHERE rc.cempres = '
	                || p_cempres
	                || '     START WITH rc.ctipage = '
	                || p_ctipage;

	      IF p_cagente IS NOT NULL AND
	         p_cagente<>-1 /* Bug 0016529 - 29/12/2010 - JMF*/
	      THEN
	        v_ttexto:=v_ttexto
	                  || ' AND rc.cagente = '
	                  || p_cagente;
	      END IF;

	      v_ntraza:=1420;

	      v_ttexto:=v_ttexto
	                || ' CONNECT BY PRIOR rc.cagente = rc.cpadre and PRIOR fmovfin IS NULL)';
	    END IF;

	    IF p_sperson IS NOT NULL THEN
	      v_ntraza:=1425;

	      v_ttexto:=v_ttexto
	                || ' AND '
	                || p_sperson
	                || ' IN (SELECT sperson FROM tomadores WHERE sseguro = seg.sseguro'
	                || ' UNION'
	                || ' SELECT sperson FROM asegurados WHERE sseguro = seg.sseguro)';
	    END IF;

	    IF p_codigosn IS NOT NULL THEN
	      /* Bug 0016529 - 16/06/2011 - JMF: quito coma final*/
	      IF p_cnegocio=2 THEN
	        /* 2.- Agrupación Productos*/
	        v_ntraza:=1430;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.cagrpro in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=3 THEN
	        /* 3.- Ramos*/
	        v_ntraza:=1435;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.cramo in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=4 THEN
	        /* 4.- Productos*/
	        v_ntraza:=1440;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.sproduc in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=5 AND
	            p_sproduc IS NOT NULL THEN
	        /* 5.- Actividad*/
	        v_ntraza:=1445;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.sproduc = '
	                  || p_sproduc
	                  || ' AND seg.cactivi in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      ELSIF p_cnegocio=6 THEN
	        /* 6.- Compañías*/
	        v_ntraza:=1450;

	        v_ttexto:=v_ttexto
	                  || ' AND seg.ccompani in ('
	                  || rtrim(p_codigosn, ',')
	                  || ')';
	      END IF;
	    END IF;

	    v_ttexto:=v_ttexto
	              || ') UNION ALL  (SELECT 0 actual, FF_DESAGENTE(rc.cagente) tagente, cagente cage, '
	              || '              NULL cagrpro, '
	              || '               NULL cramo, NULL cmodali,NULL ctipseg, NULL ccolect, NULL cactivi,NULL ccompani,  '
	              || '               0 jubilacion, 0 enfermedad, 0 incapacidad, 0 fallecimiento, 0 paro'
	              || '                                       FROM redcomercial rc '
	              || '                            WHERE rc.cagente NOT IN(SELECT s.cagente
	                                          FROM seguros s, sin_siniestro ss where ss.sseguro = s.sseguro) and rc.cempres = '
	              || p_cempres
	              || ' START WITH rc.ctipage = '
	              || p_ctipage
	              || '         AND rc.cagente = '
	              || p_cagente
	              || ' CONNECT BY PRIOR rc.cagente = rc.cpadre
	                                        AND PRIOR fmovfin IS NULL) ';

	    v_ntraza:=1455;

	    /* Bug 0019794 - 18/11/2011 - FAL*/
	    v_ttexto:=v_ttexto
	              || ' )';

	    v_text_total:=v_ttexto
	                  || '))';

	    /* Fi Bug 0019794*/
	    v_ttexto:=v_ttexto
	              || ' GROUP BY f_buscazona('
	              || p_cempres
	              || ', cage,'
	              || p_ctipage
	              || ', f_sysdate) '
	              || ',CAGE,DECODE('
	              || p_cagente
	              || ','
	              || '-1, ff_desagente(f_buscazona( '
	              || p_cempres
	              || ', cage,'
	              || p_ctipage
	              || ', f_sysdate)), cagente),'
	              || 'DECODE('
	              || p_cnegocio
	              || ','
	              || ' 1, ff_desvalorfijo(1023, '
	              || p_cidioma
	              || ', 1),'
	              || ' 2, ff_desvalorfijo(283, '
	              || p_cidioma
	              || ', cagrpro),'
	              || ' 3, ff_desramo(cramo, '
	              || p_cidioma
	              || '),'
	              || ' 4, f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, '
	              || p_cidioma
	              || '),'
	              || ' 5, FF_DESACTIVIDAD(cactivi, cramo, '
	              || p_cidioma
	              || ',2),'
	              || ' 6, FF_DESCOMPANIA(ccompani)'
	              || ')';

	    /* Bug 0019794 - 18/11/2011 - FAL*/
	    v_ttexto:=v_ttexto
	              || ' UNION ALL (select null oficina, null tagente ,null descripcion,'
	              || ' sum(jubilacion), sum(enfermedad), sum(incapacidad), sum(fallecimiento), sum(paro) from ('
	              || v_text_total
	              || ' order by oficina asc';

	    /* Fi Bug 0019794*/
	    v_ntraza:=9999;

	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list001_det11_volsini_pens;

	/* Fi Bug 19794*/
	/* Bug 0020531 - 14/12/2011 - FAL*/
	/******************************************************************************************
	  Descripció: Funció que genera texte select detall per llistat (map 415 dinamic)
	  Paràmetres entrada: - p_cinforme    -> codigo informe (detvalor 1021)
	                      - p_cidioma     -> codigo idioma
	                      - p_cempres     -> codigo empresa
	                      - p_finiefe     -> fecha inicio
	                      - p_ffinefe     -> fecha final
	                      - p_ctipage     -> Tipo (detvalor 1022) (tipo agente)
	                      - p_cagente     -> codigo en funcion del tipo (zona, oficina, agente)
	                      - p_sperson     -> codigo cliente
	                      - p_cnegocio    -> Negocio (detvalor 1023)
	                      - p_codigosn    -> Codigos de negocio (separados por comas)
	                      - p_sproduc     -> Producto de la actividad
	  return:             texte select detall
	******************************************************************************************/
	FUNCTION f_list001_det12_fact_previs(
			 p_cinforme	IN	NUMBER,
			 p_cidioma	IN	NUMBER DEFAULT NULL,
			 p_cempres	IN	NUMBER DEFAULT NULL,
			 p_finiefe	IN	NUMBER DEFAULT NULL,
			 p_ffinefe	IN	NUMBER DEFAULT NULL,
			 p_ctipage	IN	NUMBER DEFAULT NULL,
			 p_cagente	IN	NUMBER DEFAULT NULL,
			 p_sperson	IN	NUMBER DEFAULT NULL,
			 p_cnegocio	IN	NUMBER DEFAULT NULL,
			 p_codigosn	IN	VARCHAR2 DEFAULT NULL,
			 p_sproduc	IN	VARCHAR2 DEFAULT NULL
	)   RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100) := 'PAC_INFORMES.F_LIST001_DET11_VOLSINI_PENS';
	  v_tparam  VARCHAR2(1000) := 'c='
	  || p_cinforme
	  || ' i='
	  || p_cidioma
	  || ' e='
	  || p_cempres
	  || ' i='
	  || p_finiefe
	  || ' f='
	  || p_ffinefe
	  || ' t='
	  || p_ctipage
	  || ' a='
	  || p_cagente
	  || ' p='
	  || p_sperson
	  || ' n='
	  || p_cnegocio
	  || ' p='
	  || p_sproduc
	  || ' c='
	  || p_codigosn;
	  v_ntraza  NUMBER := 0;
	  v_finiefe VARCHAR2(100);
	  v_ffinefe VARCHAR2(100);
	PROCEDURE afegir_condicions(
			p_txtage	IN	VARCHAR2 DEFAULT NULL
	) IS
	BEGIN
	  IF p_sperson IS NULL THEN
	    IF p_txtage = 'SEG' THEN
	      v_ntraza := 1000;
	      v_ttexto := v_ttexto
	      || ' AND '
	      || p_ctipage
	      || ' IN (0,2,4,5)'
	      || ' AND seg.cagente IN (SELECT rc.cagente';
	      /* 19794*/
	      v_ttexto_exclu := v_ttexto_exclu
	      || ' AND '
	      || p_ctipage
	      || ' IN (0,2,4,5)'
	      || ' AND seg.cagente IN (SELECT rc.cagente';
	      /* Fi 19794*/
	    ELSE
	      v_ntraza := 1002;
	      v_ttexto := v_ttexto
	      || ' AND '
	      || p_ctipage
	      || ' IN (0,2,4,5)'
	      || ' AND rec.cagente IN (SELECT rc.cagente';
	      /* 19794*/
	      v_ttexto_exclu := v_ttexto_exclu
	      || ' AND '
	      || p_ctipage
	      || ' IN (0,2,4,5)'
	      || ' AND rec.cagente IN (SELECT rc.cagente';
	      /* Fi 19794*/
	    END IF;
	    v_ntraza := 1004;
	    v_ttexto := v_ttexto
	    || '     FROM redcomercial rc'
	    || '     WHERE rc.cempres = '
	    || p_cempres
	    || '     START WITH rc.ctipage = '
	    || p_ctipage;
	    /* 19794*/
	    v_ttexto_exclu := v_ttexto_exclu
	    || '     FROM redcomercial rc'
	    || '     WHERE rc.cempres = '
	    || p_cempres
	    || '     START WITH rc.ctipage = '
	    || p_ctipage;
	    /* Fi 19794*/
	    IF p_cagente IS NOT NULL
	      AND
	      p_cagente <> -1
	      /* Bug 0016529 - 29/12/2010 - JMF*/
	      THEN
	      v_ttexto := v_ttexto
	      || ' AND rc.cagente = '
	      || p_cagente;
	      /* 19794*/
	      v_ttexto_exclu := v_ttexto_exclu
	      || ' AND rc.cagente = '
	      || p_cagente;
	      /* Fi 19794*/
	    END IF;
	    v_ntraza := 1005;
	    v_ttexto := v_ttexto
	    || ' CONNECT BY PRIOR rc.cagente = rc.cpadre and PRIOR fmovfin IS NULL)';
	    /* 19794*/
	    v_ttexto_exclu := v_ttexto_exclu
	    || ' CONNECT BY PRIOR rc.cagente = rc.cpadre and PRIOR fmovfin IS NULL)';
	    /* Fi 19794*/
	  END IF;
	  IF p_sperson IS NOT NULL THEN
	    v_ntraza := 1010;
	    v_ttexto := v_ttexto
	    || ' AND '
	    || p_sperson
	    || ' IN (SELECT sperson FROM tomadores WHERE sseguro = seg.sseguro'
	    || ' UNION'
	    || ' SELECT sperson FROM asegurados WHERE sseguro = seg.sseguro)';
	    /* 19794*/
	    v_ttexto_exclu := v_ttexto_exclu
	    || ' AND '
	    || p_sperson
	    || ' IN (SELECT sperson FROM tomadores WHERE sseguro = seg.sseguro'
	    || ' UNION'
	    || ' SELECT sperson FROM asegurados WHERE sseguro = seg.sseguro)';
	    /* Fi 19794*/
	  END IF;
	  IF p_codigosn IS NOT NULL THEN
	    /* Bug 0016529 - 16/06/2011 - JMF: quito coma final*/
	    IF p_cnegocio = 2 THEN
	      /* 2.- Agrupación Productos*/
	      v_ntraza := 1015;
	      v_ttexto := v_ttexto
	      || ' AND seg.cagrpro in ('
	      || rtrim(p_codigosn, ',')
	      || ')';
	      /* 19794*/
	      v_ttexto_exclu := v_ttexto_exclu
	      || ' AND seg.cagrpro in ('
	      || rtrim(p_codigosn, ',')
	      || ')';
	      /* Fi 19794*/
	    ELSIF p_cnegocio = 3 THEN
	      /* 3.- Ramos*/
	      v_ntraza := 1020;
	      v_ttexto := v_ttexto
	      || ' AND seg.cramo in ('
	      || rtrim(p_codigosn, ',')
	      || ')';
	      /* 19794*/
	      v_ttexto_exclu := v_ttexto_exclu
	      || ' AND seg.cramo in ('
	      || rtrim(p_codigosn, ',')
	      || ')';
	      /* Fi 19794*/
	    ELSIF p_cnegocio = 4 THEN
	      /* 4.- Productos*/
	      v_ntraza := 1025;
	      v_ttexto := v_ttexto
	      || ' AND seg.sproduc in ('
	      || rtrim(p_codigosn, ',')
	      || ')';
	      /* 19794*/
	      v_ttexto_exclu := v_ttexto_exclu
	      || ' AND seg.sproduc in ('
	      || rtrim(p_codigosn, ',')
	      || ')';
	      /* Fi 19794*/
	    ELSIF p_cnegocio = 5
	      AND
	      p_sproduc IS NOT NULL THEN
	      /* 5.- Actividad*/
	      v_ntraza := 1030;
	      v_ttexto := v_ttexto
	      || ' AND seg.sproduc = '
	      || p_sproduc
	      || ' AND seg.cactivi in ('
	      || rtrim(p_codigosn, ',')
	      || ')';
	      /* 19794*/
	      v_ttexto_exclu := v_ttexto_exclu
	      || ' AND seg.sproduc = '
	      || p_sproduc
	      || ' AND seg.cactivi in ('
	      || rtrim(p_codigosn, ',')
	      || ')';
	      /* Fi 19794*/
	    ELSIF p_cnegocio = 6 THEN
	      /* 6.- Compañías*/
	      v_ntraza := 1035;
	      v_ttexto := v_ttexto
	      || ' AND seg.ccompani in ('
	      || rtrim(p_codigosn, ',')
	      || ')';
	      /* 19794*/
	      v_ttexto_exclu := v_ttexto_exclu
	      || ' AND seg.ccompani in ('
	      || rtrim(p_codigosn, ',')
	      || ')';
	      /* Fi 19794*/
	    END IF;
	  END IF;
	END;
	BEGIN
	  v_ntraza := 1040;
	  v_ttexto := NULL;
	  v_ttexto_exclu := NULL;
	  /* 19794*/
	  /*------------------------------------------------------------------------*/
	  /*------------------------------------------------------------------------*/
	  /* INFORME 1.- Facturación previsión*/
	  /*------------------------------------------------------------------------*/
	  /*------------------------------------------------------------------------*/
	  v_ntraza := 1045;
	  v_finiefe := 'to_date('
	  || p_finiefe
	  || ',''yyyymmdd'')';
	  v_ffinefe := 'to_date('
	  || p_ffinefe
	  || ',''yyyymmdd'')';
	  /* Bug 0016529 - 28/12/2010 - JMF: f_desproducto_t*/
	  /* ini lista de casos*/
	  /* 100 anterior nueva prod*/
	  /* 101 anterior cartera*/
	  /* 110 actual   nueva prod*/
	  /* 111 actual   cartera*/
	  /* 1AC PAC_AGENDA*/
	  /* fin lista de casos*/
	  v_ntraza := 1050;
	  v_ttexto := 'SELECT  TO_CHAR(CAGE, ''0009'') oficina ,  ff_desagente(CAGE) tagente,'
	  || ' DECODE('
	  || p_cnegocio
	  || ','
	  || '        1, ff_desvalorfijo(1023, '
	  || p_cidioma
	  || ', 1),'
	  || '        2, ff_desvalorfijo(283, '
	  || p_cidioma
	  || ', cagrpro),'
	  || '        3, ff_desramo(cramo, '
	  || p_cidioma
	  || '),'
	  || '        4, f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, '
	  || p_cidioma
	  || '),'
	  || '        5, FF_DESACTIVIDAD(cactivi, cramo, '
	  || p_cidioma
	  || ',2),'
	  || '        6, FF_DESCOMPANIA(ccompani)'
	  || '        ) descripcion,'
	  || ' (sum(decode(ctiprec, 4, decode(actual, 1, itotpri, 0), 0)) + sum(decode(ctiprec, 3, decode(actual, 1, itotpri, 0), 0)) + '
	  || ' sum(decode(ctiprec, 10, decode(actual, 1, itotpri, 0), 0))) - '
	  || ' sum(decode(cmotsin, 1, decode(actual, 1, itotpri, 0), 2, decode(actual, 1, itotpri, 0), 0)) total_fact_actual,'
	  || ' (sum(decode(ctiprec, 4, decode(actual, 0, itotpri, 0), 0)) + sum(decode(ctiprec, 3, decode(actual, 0, itotpri, 0), 0)) + '
	  || ' sum(decode(ctiprec, 10, decode(actual, 0, itotpri, 0), 0))) - '
	  || ' sum(decode(cmotsin, 1, decode(actual, 0, itotpri, 0), 2, decode(actual, 0, itotpri, 0), 0)) total_fact_ant, '
	  || ' decode( (sum(decode(ctiprec, 4, decode(actual, 0, itotpri, 0), 0)) + sum(decode(ctiprec, 3, decode(actual, 0, itotpri, 0), 0)) + '
	  || ' sum(decode(ctiprec, 10, decode(actual, 0, itotpri, 0), 0))) - sum(decode(cmotsin, 1, decode(actual, 0, itotpri, 0), 2, decode(actual, 0, itotpri, 0), 0)),0,0,((((sum(decode(ctiprec, 4, decode(actual, 1, itotpri, 0), 0)) + '
	  || ' sum(decode(ctiprec, 3, decode(actual, 1, itotpri, 0), 0)) +  sum(decode(ctiprec, 10, decode(actual, 1, itotpri, 0), 0))) - sum(decode(cmotsin, 1, '
	  || ' decode(actual, 1, itotpri, 0), 2, decode(actual, 1, itotpri, 0), 0)) /(sum(decode(ctiprec, 4, decode(actual, 0, itotpri, 0), 0)) + sum(decode(ctiprec, 3, decode(actual, 0, itotpri, 0), 0)) + sum(decode(ctiprec, 10, decode(actual, 0, itotpri, 0), 0))) - sum(decode(cmotsin, 1, decode(actual, 0, itotpri, 0), 2, decode(actual, 0, itotpri, 0), 0)))-1)*100)) total_porcen_fact,'
	  || ' sum(decode(ctiprec, 4, decode(actual, 1, itotpri, 0), 0)) total_aport_extra_actual,'
	  || ' sum(decode(ctiprec, 4, decode(actual, 0, itotpri, 0), 0)) total_aport_extra_anterior,'
	  || ' decode(sum(decode(actual, 0, decode(ctiprec,4,itotpri,0), 0)), 0, 0, '
	  || ' f_round(sum(decode(actual, 1, 1, 0, -1, 0) * decode(ctiprec,4,itotpri,0)) * 100'
	  || ' / sum(decode(actual, 0, decode(ctiprec,4,itotpri,0), 0)))) porcen_aport_extra,'
	  || ' sum(decode(ctiprec, 3, decode(actual, 1, itotpri, 0), 0)) total_aport_period_actual,'
	  || ' sum(decode(ctiprec, 3, decode(actual, 0, itotpri, 0), 0)) total_aport_period_anterior,'
	  || ' decode(sum(decode(actual, 0, decode(ctiprec,3,itotpri,0), 0)), 0, 0,'
	  || ' f_round(sum(decode(actual, 1, 1, 0, -1, 0) * decode(ctiprec,3,itotpri,0)) * 100'
	  || ' / sum(decode(actual, 0, decode(ctiprec,3,itotpri,0), 0)))) porcen_aport_period,'
	  || ' sum(decode(ctiprec, 10, decode(actual, 1, itotpri, 0), 0)) total_trasp_entr_actual,'
	  || ' sum(decode(ctiprec, 10, decode(actual, 0, itotpri, 0), 0)) total_trasp_entr_anterior,'
	  || ' decode(sum(decode(actual, 0, decode(ctiprec,10,itotpri,0), 0)), 0, 0,'
	  || ' f_round(sum(decode(actual, 1, 1, 0, -1, 0) * decode(ctiprec,10,itotpri,0)) * 100'
	  || ' / sum(decode(actual, 0, decode(ctiprec,10,itotpri,0), 0)))) porcen_trasp_entr,'
	  || ' sum(decode(cmotsin, 1, decode(actual, 1, itotpri, 0), 2, decode(actual, 1, itotpri, 0), 0)) total_trasp_sali_actual,'
	  || ' sum(decode(cmotsin, 1, decode(actual, 0, itotpri, 0), 2, decode(actual, 0, itotpri, 0), 0)) total_trasp_sali_anterior,'
	  || ' decode(sum(decode(actual, 0, decode(cmotsin,1,itotpri,2,itotpri,0), 0)), 0, 0,'
	  || ' f_round(sum(decode(actual, 1, 1, 0, -1, 0) * decode(cmotsin,1,itotpri,2,itotpri,0)) * 100'
	  || ' / sum(decode(actual, 0, decode(cmotsin,1,itotpri,2,itotpri,0), 0)))) porcen_trasp_sali,'
	  || ' sum(decode(cmotsin, 1, decode(actual, 1, itotpri, 0), 0)) total_trasp_inter_actual,'
	  || ' sum(decode(cmotsin, 1, decode(actual, 0, itotpri, 0), 0)) total_trasp_inter_anterior,'
	  || ' decode(sum(decode(actual, 0, decode(cmotsin,1,itotpri,0), 0)), 0, 0,'
	  || ' f_round(sum(decode(actual, 1, 1, 0, -1, 0) * decode(cmotsin,1,itotpri,0)) * 100'
	  || ' / sum(decode(actual, 0, decode(cmotsin,1,itotpri,0), 0)))) porcen_trasp_inter'
	  || ' FROM ('
	  || ' SELECT 0 actual, FF_DESAGENTE(decode('
	  || p_ctipage
	  || ',0,'
	  || p_cagente
	  || ',rec.cagente)) cagente, rec.cagente cage,'
	  || '         seg.cagrpro, seg.cramo, seg.cmodali,'
	  || '        seg.ctipseg, seg.ccolect, seg.cactivi, seg.ccompani,'
	  || ' rec.ctiprec, NVL(DECODE(rec.ctiprec, 9, -1, 1) * vdr.itotpri, 0) itotpri,'
	  || ' NULL ccausin, NULL cmotsin'
	  || '   from recibos rec, ctaseguro cta, seguros seg, vdetrecibos vdr'
	  || ' where rec.nrecibo = cta.nrecibo and rec.nrecibo = vdr.nrecibo'
	  || ' AND rec.cempres = '
	  || p_cempres
	  || '    AND TRUNC(rec.fefecto) >= ADD_MONTHS('
	  || v_finiefe
	  || ', -12)'
	  || '    AND TRUNC(rec.fefecto) <= ADD_MONTHS('
	  || v_ffinefe
	  || ', -12)'
	  || ' and rec.sseguro = cta.sseguro and cta.sseguro = seg.sseguro'
	  /*|| ' and seg.ccompani in (33,42,43,44)'*/
	  || ' and seg.cagrpro = 2';
	  v_ttexto_exclu := '(SELECT rec.cagente cage '
	  || '   FROM recibos rec, ctaseguro cta, seguros seg, vdetrecibos vdr'
	  || '  where rec.nrecibo = cta.nrecibo and rec.nrecibo = vdr.nrecibo'
	  || ' AND rec.cempres = '
	  || p_cempres
	  || '    AND TRUNC(rec.fefecto) >= ADD_MONTHS('
	  || v_finiefe
	  || ', -12)'
	  || '    AND TRUNC(rec.fefecto) <= ADD_MONTHS('
	  || v_ffinefe
	  || ', -12)'
	  || ' and rec.sseguro = cta.sseguro and cta.sseguro = seg.sseguro'
	  || ' and rec.sseguro = cta.sseguro and cta.sseguro = seg.sseguro'
	  /*|| ' and seg.ccompani in (33,42,43,44)'*/
	  || ' and seg.cagrpro = 2';
	  v_ntraza := 1055;
	  afegir_condicions;
	  v_ntraza := 1060;
	  v_ttexto := v_ttexto
	  || 'UNION ALL '
	  || 'SELECT 1 actual, FF_DESAGENTE(decode('
	  || p_ctipage
	  || ',0,'
	  || p_cagente
	  || ',rec.cagente)) cagente, rec.cagente cage,'
	  || '        seg.cagrpro, seg.cramo, seg.cmodali,'
	  || '       seg.ctipseg, seg.ccolect, seg.cactivi, seg.ccompani,'
	  || ' rec.ctiprec, NVL(DECODE(rec.ctiprec, 9, -1, 1) * vdr.itotpri, 0) itotpri,'
	  || ' NULL ccausin, NULL cmotsin'
	  || '   from recibos rec, ctaseguro cta, seguros seg, vdetrecibos vdr'
	  || ' where rec.nrecibo = cta.nrecibo and rec.nrecibo = vdr.nrecibo'
	  || ' AND rec.cempres = '
	  || p_cempres
	  || '    AND TRUNC(rec.fefecto) >= '
	  || v_finiefe
	  || ' AND TRUNC(rec.fefecto) <= '
	  || v_ffinefe
	  || ' and rec.sseguro = cta.sseguro and cta.sseguro = seg.sseguro'
	  || ' and seg.ccompani in (33,42,43,44)';
	  v_ttexto_exclu := v_ttexto_exclu
	  || 'UNION ALL SELECT rec.cagente cage '
	  || '   FROM recibos rec, ctaseguro cta, seguros seg, vdetrecibos vdr'
	  || '  where rec.nrecibo = cta.nrecibo and rec.nrecibo = vdr.nrecibo'
	  || ' AND rec.cempres = '
	  || p_cempres
	  || '    AND TRUNC(rec.fefecto) >= '
	  || v_finiefe
	  || ' AND TRUNC(rec.fefecto) <= '
	  || v_ffinefe
	  || ' and rec.sseguro = cta.sseguro and cta.sseguro = seg.sseguro'
	  /*|| ' and seg.ccompani in (33,42,43,44)'*/
	  || ' and seg.cagrpro = 2';
	  v_ntraza := 1065;
	  afegir_condicions;
	  /* Restamos traspasos de salida de planes pensiones*/
	  v_ntraza := 1070;
	  v_ttexto := v_ttexto
	  || 'UNION ALL '
	  || 'SELECT 0 actual, FF_DESAGENTE(decode('
	  || p_ctipage
	  || ',0,'
	  || p_cagente
	  || ',seg.cagente)) cagente, seg.cagente cage,'
	  || '       seg.cagrpro, seg.cramo, seg.cmodali,'
	  || '       seg.ctipseg, seg.ccolect, seg.cactivi, seg.ccompani,'
	  || ' NULL ctiprec, (-1) * NVL(DECODE(cta.cmovimi, 10, -1, 1) * cta.imovimi, 0) itotpri,'
	  || ' sin.ccausin, sin.cmotsin'
	  || '  FROM ctaseguro cta, seguros seg, sin_siniestro sin'
	  || ' WHERE cta.sseguro = seg.sseguro'
	  || ' and sin.sseguro = cta.sseguro and sin.sseguro = seg.sseguro and cta.nsinies = sin.nsinies'
	  || '   AND TRUNC(cta.fvalmov) >= ADD_MONTHS('
	  || v_finiefe
	  || ', -12)'
	  || '   AND TRUNC(cta.fvalmov) <= ADD_MONTHS('
	  || v_ffinefe
	  || ', -12)'
	  || '   AND seg.cempres = '
	  || p_cempres
	  || '   AND sin.ccausin = 8 AND sin.cmotsin in (1,2) '
	  /*|| '   and seg.ccompani in (33,42,43,44)'*/
	  || '   and seg.cagrpro = 2';
	  v_ttexto_exclu := v_ttexto_exclu
	  || 'UNION ALL '
	  || 'SELECT seg.cagente cage '
	  || '  FROM ctaseguro cta, seguros seg, sin_siniestro sin'
	  || ' WHERE cta.sseguro = seg.sseguro'
	  || ' and sin.sseguro = cta.sseguro and sin.sseguro = seg.sseguro and cta.nsinies = sin.nsinies'
	  || '   AND TRUNC(cta.fvalmov) >= ADD_MONTHS('
	  || v_finiefe
	  || ', -12)'
	  || '   AND TRUNC(cta.fvalmov) <= ADD_MONTHS('
	  || v_ffinefe
	  || ', -12)'
	  || '   AND seg.cempres = '
	  || p_cempres
	  || '   AND sin.ccausin = 8 AND sin.cmotsin in (1,2) '
	  /*         || '   and seg.ccompani in (33,42,43,44)'*/
	  || '   and seg.cagrpro = 2';
	  v_ntraza := 1075;
	  afegir_condicions('SEG');
	  /* Restamos traspasos de salida de planes pensiones*/
	  v_ntraza := 1080;
	  v_ttexto := v_ttexto
	  || 'UNION ALL '
	  || 'SELECT 1 actual, FF_DESAGENTE(decode('
	  || p_ctipage
	  || ',0,'
	  || p_cagente
	  || ',seg.cagente)) cagente, seg.cagente cage,'
	  || '       seg.cagrpro, seg.cramo, seg.cmodali,'
	  || '       seg.ctipseg, seg.ccolect, seg.cactivi, seg.ccompani,'
	  || ' NULL ctiprec, (-1) * NVL(DECODE(cta.cmovimi, 10, -1, 1) * cta.imovimi, 0) itotpri,'
	  || ' sin.ccausin, sin.cmotsin'
	  || '  FROM ctaseguro cta, seguros seg, sin_siniestro sin'
	  || ' WHERE cta.sseguro = seg.sseguro'
	  || ' and sin.sseguro = cta.sseguro and sin.sseguro = seg.sseguro and cta.nsinies = sin.nsinies'
	  || '   AND TRUNC(cta.fvalmov) >= '
	  || v_finiefe
	  || '   AND TRUNC(cta.fvalmov) <= '
	  || v_ffinefe
	  || '   AND seg.cempres = '
	  || p_cempres
	  || '   AND sin.ccausin = 8 AND sin.cmotsin in (1,2) '
	  /*|| ' and seg.ccompani in (33,42,43,44)'*/
	  || ' and seg.cagrpro = 2';
	  v_ttexto_exclu := v_ttexto_exclu
	  || 'UNION ALL '
	  || 'SELECT seg.cagente cage '
	  || ' FROM ctaseguro cta, seguros seg, sin_siniestro sin'
	  || ' WHERE cta.sseguro = seg.sseguro'
	  || ' and sin.sseguro = cta.sseguro and sin.sseguro = seg.sseguro and cta.nsinies = sin.nsinies'
	  || '   AND TRUNC(cta.fvalmov) >= '
	  || v_finiefe
	  || '   AND TRUNC(cta.fvalmov) <= '
	  || v_ffinefe
	  || '   AND seg.cempres = '
	  || p_cempres
	  || '   AND sin.ccausin = 8 AND sin.cmotsin in (1,2) '
	  /*         || '   and seg.ccompani in (33,42,43,44)'*/
	  || ' and seg.cagrpro = 2';
	  v_ntraza := 1085;
	  afegir_condicions('SEG');
	  v_ntraza := 1090;
	  v_ttexto := v_ttexto
	  || 'UNION ALL  SELECT 1 actual, FF_DESAGENTE(decode('
	  || p_ctipage
	  || ',0,'
	  || p_cagente
	  || ',rc.cagente)) cagente, rc.cagente cage,'
	  || '       null, null, null, null,'
	  || '       null, null, null,'
	  || ' NULL ctiprec, 0 itotpri,'
	  || ' NULL ccausin, NULL cmotsin'
	  || '                           FROM redcomercial rc
	WHERE rc.cempres = '
	  || p_cempres
	  || ' and rc.cagente not in '
	  || v_ttexto_exclu
	  || ')' -- 19794
	  ;
	  IF p_cnegocio = 6 THEN
	    v_ttexto := v_ttexto
	    || ' and (rc.cagente NOT IN (select distinct(cagente) from seguros where  ccompani in ('
	    || rtrim(p_codigosn, ',')
	    || ') ) )';
	    /*
	OR RC.CAGENTE NOT IN (SELECT distinct(cagente) from seguros where cempres = '
	|| p_cempres || ')) ';*/
	  END IF;
	  v_ttexto := v_ttexto
	  || ' START WITH rc.ctipage = '
	  || p_ctipage
	  || '         AND rc.cagente = '
	  || p_cagente
	  || ' CONNECT BY PRIOR rc.cagente = rc.cpadre
	AND PRIOR fmovfin IS NULL '; -- Bug 0016529 - 28/12/2010 - JMF: f_desproducto_t
	  /* Bug 0019794 - 18/11/2011 - FAL*/
	  v_text_total := v_ttexto
	  || ')))';
	  /* Fi Bug 0019794*/
	  v_ttexto := v_ttexto
	  || ')'
	  || ' GROUP BY f_buscazona( '
	  || p_cempres
	  || ', cage,'
	  || p_ctipage
	  || ', f_sysdate),CAGE,DECODE('
	  || p_cagente
	  || ','
	  || '-1, ff_desagente(f_buscazona( '
	  || p_cempres
	  || ', cage,'
	  || p_ctipage
	  || ', f_sysdate)), cagente),'
	  || ' DECODE('
	  || p_cnegocio
	  || ','
	  || ' 1, ff_desvalorfijo(1023, '
	  || p_cidioma
	  || ', 1),'
	  || ' 2, ff_desvalorfijo(283, '
	  || p_cidioma
	  || ', cagrpro),'
	  || ' 3, ff_desramo(cramo, '
	  || p_cidioma
	  || '),'
	  || ' 4, f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, '
	  || p_cidioma
	  || '),'
	  || ' 5, FF_DESACTIVIDAD(cactivi, cramo, '
	  || p_cidioma
	  || ',2),'
	  || ' 6, FF_DESCOMPANIA(ccompani))';
	  /* Bug 0019794 - 18/11/2011 - FAL*/
	  v_ttexto := v_ttexto
	  || ' UNION ALL (select null oficina, null tagente ,null descripcion, sum(total_fact_actual), sum(total_fact_ant), null total_porcen_fact, sum(total_aport_extra_actual),
	sum(total_aport_extra_anterior), null porcen_aport_extra, sum(total_aport_period_actual), sum(total_aport_period_anterior), null porcen_aport_period,
	sum(total_trasp_entr_actual), sum(total_trasp_entr_anterior), null porcen_trasp_entr, sum(total_trasp_sali_actual), sum(total_trasp_sali_anterior), null porcen_trasp_sali,
	sum(total_trasp_inter_actual), sum(total_trasp_inter_anterior), null porcen_trasp_inter from ('
	  || v_text_total
	  || ' order by oficina asc';
	  /* Fi Bug 0019794*/
	  v_ntraza := 9999;
	  RETURN v_ttexto;
	EXCEPTION
	WHEN OTHERS THEN
	  p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	  || ': Error'
	  || SQLCODE, SQLERRM);
	  RETURN 'select 1 from dual';
	END f_list001_det12_fact_previs;
	/* Fi Bug 0020531*/
	/******************************************************************************************
	Descripció: Funció que genera texte capçelera per llistat (map 415 dinamic)
	Paràmetres entrada: - p_cinforme    -> codigo informe (detvalor 1021)
	- p_cidioma     -> codigo idioma
	- p_cempres     -> codigo empresa
	- p_finiefe     -> fecha inicio
	- p_ffinefe     -> fecha final
	- p_ctipage     -> Tipo (detvalor 1022) (tipo agente)
	- p_cagente     -> codigo en funcion del tipo (zona, oficina, agente)
	- p_sperson     -> codigo cliente
	- p_cnegocio    -> Negocio (detvalor 1023)
	- p_codigosn    -> Codigos de negocio (separados por comas)
	- p_sproduc     -> Producto de la actividad
	return:             texte capçelera
	******************************************************************************************/
	/* Bug 0016529 - 29/11/2010 - JMF*/
	/* Bug 17710 - 03/06/2011 - AMC - Se modifica la visualización de la cabecera*/
	FUNCTION f_list001_cab(
			p_cinforme	IN	NUMBER,
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL,
			p_ctipage	IN	NUMBER DEFAULT NULL,
			p_cagente	IN	NUMBER DEFAULT NULL,
			p_sperson	IN	NUMBER DEFAULT NULL,
			p_cnegocio	IN	NUMBER DEFAULT NULL,
			p_codigosn	IN	VARCHAR2 DEFAULT NULL,
			p_sproduc	IN	VARCHAR2 DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.F_LIST001_CAB';
	  v_tparam  VARCHAR2(1000):='c='
	                           || p_cinforme
	                           || ' i='
	                           || p_cidioma
	                           || ' e='
	                           || p_cempres
	                           || ' i='
	                           || p_finiefe
	                           || ' f='
	                           || p_ffinefe
	                           || ' t='
	                           || p_ctipage
	                           || ' a='
	                           || p_cagente
	                           || ' p='
	                           || p_sperson
	                           || ' n='
	                           || p_cnegocio
	                           || ' p='
	                           || p_sproduc
	                           || ' c='
	                           || p_codigosn;
	  v_ntraza  NUMBER:=0;
	  v_ini     VARCHAR2(32000);
	  v_idioma  NUMBER;
	  v_tproduc VARCHAR2(500);
	  verror    NUMBER;
	  cad1      VARCHAR2(1000);
	  cad2      VARCHAR2(10);
	  vtactivi  VARCHAR2(40);
	  vcad      NUMBER:=1;
	BEGIN
	    v_ntraza:=1000;

	    v_ttexto:=NULL;

	    IF p_cidioma IS NULL THEN
	      SELECT max(nvalpar)
	        INTO v_idioma
	        FROM parinstalacion
	       WHERE cparame='IDIOMARTF';
	    ELSE
	      v_idioma:=p_cidioma;
	    END IF;

	    IF p_sproduc IS NOT NULL THEN
	      verror:=f_dessproduc(p_sproduc, 2, v_idioma, v_tproduc);
	    END IF;

	    v_ntraza:=1010;

	    /* Bug 0016529 - 29/12/2010 - JMF*/
	    /* Bug 0016529 - 16/06/2011 - JMF: formato fecha.*/
	    v_ini:=f_axis_literales(9001754, v_idioma)
	           || chr(10)
	           || f_axis_literales(0108525, v_idioma)
	           || ';'
	           || ff_desvalorfijo(1021, v_idioma, p_cinforme)
	           || ';'
	           || f_axis_literales(9000526, v_idioma)
	           || ';'
	           || to_date(p_finiefe, 'rrrrmmdd')
	           || ';'
	           || -- fecha inicio
	           f_axis_literales(9000527, v_idioma)
	           || ';'
	           || to_date(p_ffinefe, 'rrrrmmdd')
	           || chr(10)
	           || /* fecha final*/
	           f_axis_literales(0100565, v_idioma)
	           || ';'
	           || ff_desvalorfijo(1022, v_idioma, p_ctipage)
	           || ';'
	           || /* Tipo*/
	           f_axis_literales(1000109, v_idioma)
	           || ';';

	    /* codigo en funcion del tipo (zona, oficina, agente)*/
	    IF p_cagente=-1 THEN
	      v_ini:=v_ini
	             || f_axis_literales(100934, v_idioma)
	             || chr(10);
	    ELSE
	      v_ini:=v_ini
	             || f_desagente_t(p_cagente)
	             || chr(10);
	    END IF;

	    v_ini:=v_ini
	           || f_axis_literales(0105330, v_idioma)
	           || ';';

	    IF p_sperson IS NOT NULL THEN
	      v_ini:=v_ini
	             || f_nombre(p_sperson, 1)
	             || ';'; -- codigo cliente
	    ELSE
	      v_ini:=v_ini
	             || ';';
	    END IF;

	    v_ini:=v_ini
	           || f_axis_literales(9901646, v_idioma)
	           || ';'
	           || ff_desvalorfijo(1023, v_idioma, p_cnegocio)
	           || chr(10)
	           || /* Negocio*/
	           f_axis_literales(0100829, v_idioma)
	           || ';'
	           || v_tproduc
	           || chr(10)
	           || /* Producto de la actividad*/
	           f_axis_literales(1000113, v_idioma)
	           || ';';

	    cad1:=p_codigosn
	          || ',';

	    WHILE instr(cad1, ',')!=0 LOOP
	        cad2:=substr(cad1, 1, instr(cad1, ',')-1);

	        cad1:=substr(cad1, instr(cad1, ',')+1);

	        IF p_cnegocio=2 THEN /* Agrupacion productos*/
	          IF vcad<5 THEN
	            v_ini:=v_ini
	                   || ff_desvalorfijo(283, v_idioma, cad2)
	                   || ';';
	          ELSE
	            v_ini:=v_ini
	                   || ff_desvalorfijo(283, v_idioma, cad2)
	                   || chr(10)
	                   || ';';
	          END IF;
	        ELSIF p_cnegocio=3 THEN /* Ramos*/
	          IF vcad<5 THEN
	            v_ini:=v_ini
	                   || ff_desramo(cad2, v_idioma)
	                   || ';';
	          ELSE
	            v_ini:=v_ini
	                   || ff_desramo(cad2, v_idioma)
	                   || chr(10)
	                   || ';';
	          END IF;
	        ELSIF p_cnegocio=4 THEN /* Productos*/
	          verror:=f_dessproduc(cad2, 1, v_idioma, v_tproduc);

	          IF vcad<5 THEN
	            v_ini:=v_ini
	                   || v_tproduc
	                   || ';';
	          ELSE
	            v_ini:=v_ini
	                   || v_tproduc
	                   || chr(10)
	                   || ';';
	          END IF;
	        ELSIF p_cnegocio=5 THEN /* Actividad*/
	          SELECT s.ttitulo
	            INTO vtactivi
	            FROM activisegu s,activiprod p,productos pr
	           WHERE s.cidioma=v_idioma AND
	                 s.cactivi=cad2 AND
	                 s.cramo=p.cramo AND
	                 pr.ctipseg=p.ctipseg AND
	                 pr.ccolect=p.ccolect AND
	                 pr.cmodali=p.cmodali AND
	                 pr.cramo=p.cramo AND
	                 p.cactivi=s.cactivi AND
	                 pr.sproduc=p_sproduc;

	          IF vcad<5 THEN
	            v_ini:=v_ini
	                   || vtactivi
	                   || ';';
	          ELSE
	            v_ini:=v_ini
	                   || vtactivi
	                   || chr(10)
	                   || ';';
	          END IF;
	        ELSIF p_cnegocio=6 THEN /* Compañias*/
	          IF vcad<5 THEN
	            v_ini:=v_ini
	                   || ff_descompania(cad2)
	                   || ';';
	          ELSE
	            v_ini:=v_ini
	                   || ff_descompania(cad2)
	                   || chr(10)
	                   || ';';
	          END IF;
	        END IF;

	        IF vcad<5 THEN
	          vcad:=vcad+1;
	        ELSE
	          vcad:=1;
	        END IF;
	    END LOOP;

	    v_ini:=v_ini
	           || chr(10)
	           || chr(10);

	    /*|| SUBSTR(p_codigosn, 1, 100)*/
	    /*|| CHR(10)   -- Codigos de negocio (separados por comas)*/
	    /*          || CHR(10);*/
	    IF p_cinforme=1 THEN
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 1.- Facturación*/
	    /*------------------------------------------------------------------------*/
	      /*------------------------------------------------------------------------*/
	      v_ttexto:=';'
	                || ';'
	                || ';'
	                || -- Facturación
	                f_axis_literales(9901636, v_idioma)
	                || ';'
	                || ';'
	                || ';'
	                || ';'
	                || -- Cartera
	                f_axis_literales(103074, v_idioma)
	                || ';'
	                || ';'
	                || ';'
	                || ';'
	                || -- Nueva Producción
	                f_axis_literales(102172, v_idioma)
	                || ';'
	                || ';'
	                || ';'
	                || ';';

	      v_ini:=v_ini
	             || v_ttexto
	             || chr(10);

	      /*   edit axis_literales where slitera =    101467*/
	      v_ttexto:=f_axis_literales(0100565, v_idioma)
	                || ';'
	                || ';'
	                || /* Tipo*/
	                f_axis_literales(100588, v_idioma)
	                || ';'
	                || /* DESCRIPCION*/
	                f_axis_literales(9901677, v_idioma)
	                || ';'
	                || /* TOTAL_ACTUAL*/
	                f_axis_literales(9901678, v_idioma)
	                || ';'
	                || /* TOTAL_ANTERIOR*/
	                f_axis_literales(9901680, v_idioma)
	                || ';'
	                || -- TOTAL_DIFERENCIA
	                '%;'
	                || /* PORCENTAJE*/
	                f_axis_literales(9901677, v_idioma)
	                || ';'
	                || /* TOTAL_ACT_CARTERA*/
	                f_axis_literales(9901678, v_idioma)
	                || ';'
	                || /* TOTAL_ANT_CARTERA*/
	                f_axis_literales(9901680, v_idioma)
	                || ';'
	                || -- TOTAL_DIF_CARTERA
	                '%;'
	                || /* CARTERA PORCENTAJE*/
	                f_axis_literales(9901677, v_idioma)
	                || ';'
	                || /* TOTAL_ACT_NUEVA_PRODUCCION*/
	                f_axis_literales(9901678, v_idioma)
	                || ';'
	                || /* TOTAL_ANT_NUEVA_PRODUCCION*/
	                f_axis_literales(9901680, v_idioma)
	                || ';'
	                || -- TOTAL_DIF_NUEVA_PRODUCCION
	                '%;'
	                || /* PRODUCCION PORCENTAJE*/
	                f_axis_literales(9902156, v_idioma)
	                || ';'
	                || /* Ratio Prod/Fact. actual*/
	                f_axis_literales(9902157, v_idioma)
	                || ';'
	                /* Bug 0020531 - 14/12/2011 - FAL*/
	                /*
	                                     ||   -- Ratio Prod/Fact. anterior
	                                       f_axis_literales(9902158, v_idioma) || ';' */
	                || /* Fi Bug 20531*/
	                '';
	    ELSIF p_cinforme=2 THEN
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 2.- Pólizas/planes*/
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	      /*  v_ttexto := f_axis_literales(0100565, v_idioma) || ';' || ';'
	                    ||   -- Tipo
	                      f_axis_literales(100588, v_idioma) || ';'
	                    ||   -- DESCRIPCION
	                      f_axis_literales(9901688, v_idioma) || ';'
	                    ||   -- VIGOR_ACTUAL
	                      f_axis_literales(9901689, v_idioma) || ';'
	                    ||   -- VIGOR_ANTERIOR
	                      f_axis_literales(9901690, v_idioma) || ';'
	                    ||   -- VIGOR_DIFERENCIA
	                      f_axis_literales(9901691, v_idioma) || ';'
	                    ||   -- VIGOR_PORCENTAJE
	                      f_axis_literales(9901692, v_idioma) || ';'
	                    ||   -- CAPTADA_ACTUAL
	                      f_axis_literales(9901693, v_idioma) || ';'
	                    ||   -- CAPTADA_ANTERIOR
	                      f_axis_literales(9901694, v_idioma) || ';'
	                    ||   -- CAPTADA_DIFERENCIA
	                      f_axis_literales(9901695, v_idioma) || ';'
	                    ||   -- CAPTADA_PORCENTAJE
	                      f_axis_literales(9901696, v_idioma) || ';'
	                    ||   -- ANULADA_ACTUAL
	                      f_axis_literales(9901697, v_idioma) || ';'
	                    ||   -- ANULADA_ANTERIOR
	                      f_axis_literales(9901698, v_idioma) || ';'
	                    ||   -- ANULADA_DIFERENCIA
	                      f_axis_literales(9901699, v_idioma) || ';'   -- ANULADA_PORCENTAJE
	                                                                ;*/
	      v_ttexto:=';'
	                || ';'
	                || ';'
	                || -- Pólizas vigentes
	                f_axis_literales(9902454, v_idioma)
	                || ';'
	                || ';'
	                || ';'
	                || ';'
	                || -- Captadas en el periodo
	                f_axis_literales(9902473, v_idioma)
	                || ';'
	                || ';'
	                || ';'
	                || ';'
	                || -- Anulades en el periodo
	                f_axis_literales(9902474, v_idioma)
	                || ';'
	                || ';'
	                || ';'
	                || ';';

	      v_ini:=v_ini
	             || v_ttexto
	             || chr(10);

	      v_ttexto:=f_axis_literales(0100565, v_idioma)
	                || ';'
	                || ';'
	                || /* Tipo*/
	                f_axis_literales(100588, v_idioma)
	                || ';'
	                || /* DESCRIPCION*/
	                f_axis_literales(9901677, v_idioma)
	                || ';'
	                || /* TOTAL_ACTUAL*/
	                f_axis_literales(9901678, v_idioma)
	                || ';'
	                || /* TOTAL_ANTERIOR*/
	                f_axis_literales(9901680, v_idioma)
	                || ';'
	                || -- TOTAL_DIFERENCIA
	                '%;'
	                || /* PORCENTAJE*/
	                f_axis_literales(9901677, v_idioma)
	                || ';'
	                || /* TOTAL_ACT_CARTERA*/
	                f_axis_literales(9901678, v_idioma)
	                || ';'
	                || /* TOTAL_ANT_CARTERA*/
	                f_axis_literales(9901680, v_idioma)
	                || ';'
	                || -- TOTAL_DIF_CARTERA
	                '%;'
	                || /* CARTERA PORCENTAJE*/
	                f_axis_literales(9901677, v_idioma)
	                || ';'
	                || /* TOTAL_ACT_NUEVA_PRODUCCION*/
	                f_axis_literales(9901678, v_idioma)
	                || ';'
	                || /* TOTAL_ANT_NUEVA_PRODUCCION*/
	                f_axis_literales(9901680, v_idioma)
	                || ';'
	                || -- TOTAL_DIF_NUEVA_PRODUCCION
	                '%;'
	                || '';
	    ELSIF p_cinforme=3 THEN
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 3.- Comisiones pagadas*/
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	      /*   v_ttexto := f_axis_literales(0100565, v_idioma) || ';' || ';'
	                     ||   -- Tipo
	                       f_axis_literales(100588, v_idioma) || ';'
	                     ||   -- DESCRIPCION
	                       f_axis_literales(9901700, v_idioma) || ';'
	                     ||   -- PAGADAS ACTUAL
	                       f_axis_literales(9901701, v_idioma) || ';'
	                     ||   -- PAGADAS ANTERIOR
	                       f_axis_literales(9901702, v_idioma) || ';'
	                     ||   -- PAGADAS DIFERENCIA
	                       f_axis_literales(9901703, v_idioma) || ';'
	                     ||   -- PAGADAS PORCENTAJE
	                       f_axis_literales(9901704, v_idioma) || ';'
	                     ||   -- CARTERA ACTUAL
	                       f_axis_literales(9901705, v_idioma) || ';'
	                     ||   -- CARTERA ANTERIOR
	                       f_axis_literales(9901706, v_idioma) || ';'
	                     ||   -- CARTERA DIFERENCIA
	                       f_axis_literales(9901707, v_idioma) || ';'
	                     ||   -- CARTERA PORCENTAJE
	                       f_axis_literales(9901708, v_idioma) || ';'
	                     ||   -- PRODUCCION ACTUAL
	                       f_axis_literales(9901709, v_idioma) || ';'
	                     ||   -- PRODUCCION ANTERIOR
	                       f_axis_literales(9901710, v_idioma) || ';'
	                     ||   -- PRODUCCION DIFERENCIA
	                       f_axis_literales(9901711, v_idioma) || ';'   -- PRODUCCION PORCENTAJE
	                                                                 ;*/
	      v_ttexto:=';'
	                || ';'
	                || ';'
	                || -- Comisiones pagadas
	                f_axis_literales(9901638, v_idioma)
	                || ';'
	                || ';'
	                || ';'
	                || ';'
	                || -- Comisiones cartera
	                f_axis_literales(9902475, v_idioma)
	                || ';'
	                || ';'
	                || ';'
	                || ';'
	                || -- Anulades en el periodo
	                f_axis_literales(9902476, v_idioma)
	                || ';'
	                || ';'
	                || ';'
	                || ';';

	      v_ini:=v_ini
	             || v_ttexto
	             || chr(10);

	      v_ttexto:=f_axis_literales(0100565, v_idioma)
	                || ';'
	                || ';'
	                || /* Tipo*/
	                f_axis_literales(100588, v_idioma)
	                || ';'
	                || /* DESCRIPCION*/
	                f_axis_literales(9901677, v_idioma)
	                || ';'
	                || /* TOTAL_ACTUAL*/
	                f_axis_literales(9901678, v_idioma)
	                || ';'
	                || /* TOTAL_ANTERIOR*/
	                f_axis_literales(9901680, v_idioma)
	                || ';'
	                || -- TOTAL_DIFERENCIA
	                '%;'
	                || /* PORCENTAJE*/
	                f_axis_literales(9901677, v_idioma)
	                || ';'
	                || /* TOTAL_ACT_CARTERA*/
	                f_axis_literales(9901678, v_idioma)
	                || ';'
	                || /* TOTAL_ANT_CARTERA*/
	                f_axis_literales(9901680, v_idioma)
	                || ';'
	                || -- TOTAL_DIF_CARTERA
	                '%;'
	                || /* CARTERA PORCENTAJE*/
	                f_axis_literales(9901677, v_idioma)
	                || ';'
	                || /* TOTAL_ACT_NUEVA_PRODUCCION*/
	                f_axis_literales(9901678, v_idioma)
	                || ';'
	                || /* TOTAL_ANT_NUEVA_PRODUCCION*/
	                f_axis_literales(9901680, v_idioma)
	                || ';'
	                || -- TOTAL_DIF_NUEVA_PRODUCCION
	                '%;'
	                || '';
	    ELSIF p_cinforme=4 THEN
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 4.- Volumen de negocio*/
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	      /* v_ttexto := f_axis_literales(0100565, v_idioma) || ';' || ';'
	                   ||   -- Tipo
	                     f_axis_literales(100588, v_idioma) || ';'
	                   ||   -- DESCRIPCION
	                     f_axis_literales(9901712, v_idioma) || ';'
	                   ||   -- NEGOCIO ACTUAL
	                     f_axis_literales(9901713, v_idioma) || ';'
	                   ||   -- NEGOCIO ANTERIOR
	                     f_axis_literales(9901714, v_idioma) || ';'
	                   ||   -- NEGOCIO DIFERENCIA
	                     f_axis_literales(9901715, v_idioma) || ';'
	                   ||   -- NEGOCIO PORCENTAJE
	                     f_axis_literales(9901716, v_idioma) || ';'
	                   ||   -- PARTICIPE ACTUAL
	                     f_axis_literales(9901717, v_idioma) || ';'
	                   ||   -- PARTICIPE ANTERIOR
	                     f_axis_literales(9901718, v_idioma) || ';'
	                   ||   -- PARTICIPE DIFERENCIA
	                     f_axis_literales(9901719, v_idioma) || ';'   -- PARTICIPE PORCENTAJE
	                                                               ;*/
	      v_ttexto:=';'
	                || ';'
	                || ';'
	                || -- Negoci gestionat
	                f_axis_literales(9902477, v_idioma)
	                || ';'
	                || ';'
	                || ';'
	                || ';'
	                || -- polizas participes vigor
	                f_axis_literales(9902478, v_idioma)
	                || ';'
	                || ';'
	                || ';'
	                || ';'
	                || ';'
	                || ';'
	                || ';'
	                || ';';

	      v_ini:=v_ini
	             || v_ttexto
	             || chr(10);

	      v_ttexto:=f_axis_literales(0100565, v_idioma)
	                || ';'
	                || ';'
	                || /* Tipo*/
	                f_axis_literales(100588, v_idioma)
	                || ';'
	                || /* DESCRIPCION*/
	                f_axis_literales(9901677, v_idioma)
	                || ';'
	                || /* TOTAL_ACTUAL*/
	                f_axis_literales(9901678, v_idioma)
	                || ';'
	                || /* TOTAL_ANTERIOR*/
	                f_axis_literales(9901680, v_idioma)
	                || ';'
	                || -- TOTAL_DIFERENCIA
	                '%;'
	                || /* PORCENTAJE*/
	                f_axis_literales(9901677, v_idioma)
	                || ';'
	                || /* TOTAL_ACT_CARTERA*/
	                f_axis_literales(9901678, v_idioma)
	                || ';'
	                || /* TOTAL_ANT_CARTERA*/
	                f_axis_literales(9901680, v_idioma)
	                || ';'
	                || -- TOTAL_DIF_CARTERA
	                '%;'
	                || '';
	    ELSIF p_cinforme=5 THEN
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 5.- Siniestros - Número de expedientes*/
	    /*------------------------------------------------------------------------*/
	      /*------------------------------------------------------------------------*/
	      v_ttexto:=f_axis_literales(0100565, v_idioma)
	                || ';'
	                || ';'
	                || /* Tipo*/
	                f_axis_literales(100588, v_idioma)
	                || ';'
	                || /* DESCRIPCION*/
	                f_axis_literales(9901720, v_idioma)
	                || ';'
	                || /* SINIESTROS ABIERTOS*/
	                f_axis_literales(9901721, v_idioma)
	                || ';'; -- SINIESTROS CERRADOS
	    /* Bug 0019794 - 26/11/2011 - FAL*/
	    ELSIF p_cinforme=6 THEN
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 6.- Siniestros - Número de expedientes ramo no vida*/
	    /*------------------------------------------------------------------------*/
	      /*------------------------------------------------------------------------*/
	      v_ttexto:=f_axis_literales(0100565, v_idioma)
	                || ';'
	                || ';'
	                || /* Tipo*/
	                f_axis_literales(100588, v_idioma)
	                || ';'
	                || /* DESCRIPCION*/
	                f_axis_literales(9901720, v_idioma)
	                || ';'
	                || /* SINIESTROS ABIERTOS*/
	                f_axis_literales(9901721, v_idioma)
	                || ';' -- SINIESTROS CERRADOS
	                || f_axis_literales(9902828, v_idioma)
	                || ';'; -- SINIESTROS RECHAZADOS
	    ELSIF p_cinforme=7 THEN
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 7.- Siniestros - Volumen siniestralidad ramo no vida*/
	    /*------------------------------------------------------------------------*/
	      /*------------------------------------------------------------------------*/
	      v_ttexto:=f_axis_literales(0100565, v_idioma)
	                || ';'
	                || ';'
	                || /* Tipo*/
	                f_axis_literales(100588, v_idioma)
	                || ';'
	                || /* DESCRIPCION*/
	                f_axis_literales(9902829, v_idioma)
	                || ';'
	                || /* VOLUMEN SINIESTRALIDAD*/
	                upper(f_axis_literales(105830, v_idioma))
	                || ';' -- PRIMAS EMITIDAS
	                || upper(f_axis_literales(9902725, v_idioma))
	                || ';'; -- % SINIESTRALIDAD
	    ELSIF p_cinforme=8 THEN
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 8.- Siniestros - Número de expedientes ramo vida*/
	    /*------------------------------------------------------------------------*/
	      /*------------------------------------------------------------------------*/
	      v_ttexto:=f_axis_literales(0100565, v_idioma)
	                || ';'
	                || ';'
	                || /* Tipo*/
	                f_axis_literales(100588, v_idioma)
	                || ';'
	                || /* DESCRIPCION*/
	                f_axis_literales(9902830, v_idioma)
	                || ';'
	                || /* SINIESTROS/PRESTACIONES ABIERTAS*/
	                f_axis_literales(9902831, v_idioma)
	                || ';' -- SINIESTROS/PRESTACIONES CERRADAS
	                || f_axis_literales(9902832, v_idioma)
	                || ';' -- PRESTACIONES ABIERTAS: RECHAZADAS
	                || f_axis_literales(9902833, v_idioma)
	                || ';' -- PRESTACIONES ABIERTAS: VENCIMIENTOS
	                || f_axis_literales(9902834, v_idioma)
	                || ';' -- PRESTACIONES ABIERTAS: RESCATES
	                || f_axis_literales(9902835, v_idioma)
	                || ';' -- PRESTACIONES ABIERTAS: RENTAS
	                || f_axis_literales(9902836, v_idioma)
	                || ';' -- PRESTACIONES ABIERTAS: TRASPASOS PPA
	                || f_axis_literales(9902837, v_idioma)
	                || ';'; -- PRESTACIONES ABIERTAS: SINIESTROS
	    ELSIF p_cinforme=9 THEN
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 9.- Siniestros - Volumen siniestralidad ramo vida*/
	    /*------------------------------------------------------------------------*/
	      /*------------------------------------------------------------------------*/
	      v_ttexto:=f_axis_literales(0100565, v_idioma)
	                || ';'
	                || ';'
	                || /* Tipo*/
	                f_axis_literales(100588, v_idioma)
	                || ';'
	                || /* DESCRIPCION*/
	                f_axis_literales(9902838, v_idioma)
	                || ';'
	                || /* PAGOS: VENCIMIENTOS*/
	                f_axis_literales(9902839, v_idioma)
	                || ';' -- PAGOS: RESCATES
	                || f_axis_literales(9902840, v_idioma)
	                || ';' -- PAGOS: RENTAS
	                || f_axis_literales(9902841, v_idioma)
	                || ';' -- PAGOS: TRASPASOS PPA
	                || f_axis_literales(9902842, v_idioma)
	                || ';'; -- PAGOS: SINIESTROS
	    ELSIF p_cinforme=10 THEN
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 10.- Siniestros - Número de expedientes pensiones*/
	    /*------------------------------------------------------------------------*/
	      /*------------------------------------------------------------------------*/
	      v_ttexto:=f_axis_literales(0100565, v_idioma)
	                || ';'
	                || ';'
	                || /* Tipo*/
	                f_axis_literales(100588, v_idioma)
	                || ';'
	                || /* DESCRIPCION*/
	                f_axis_literales(9902843, v_idioma)
	                || ';'
	                || /* PRESTACIONES ABIERTAS: JUBILACIÓN*/
	                f_axis_literales(9902844, v_idioma)
	                || ';' -- PRESTACIONES ABIERTAS: ENFERMEDAD
	                || f_axis_literales(9902845, v_idioma)
	                || ';' -- PRESTACIONES ABIERTAS: INCAPACIDAD
	                || f_axis_literales(9902846, v_idioma)
	                || ';' -- PRESTACIONES ABIERTAS: FALLECIMIENTO
	                || f_axis_literales(9902847, v_idioma)
	                || ';'; -- PRESTACIONES ABIERTAS: PARO
	    ELSIF p_cinforme=11 THEN
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 11.- Siniestros - Volumen siniestralidad pensiones*/
	    /*------------------------------------------------------------------------*/
	      /*------------------------------------------------------------------------*/
	      v_ttexto:=f_axis_literales(0100565, v_idioma)
	                || ';'
	                || ';'
	                || /* Tipo*/
	                f_axis_literales(100588, v_idioma)
	                || ';'
	                || /* DESCRIPCION*/
	                f_axis_literales(9902848, v_idioma)
	                || ';'
	                || /* PAGOS: JUBILACIÓN*/
	                f_axis_literales(9902849, v_idioma)
	                || ';' -- PAGOS: ENFERMEDAD
	                || f_axis_literales(9902850, v_idioma)
	                || ';' -- PAGOS: INCAPACIDAD
	                || f_axis_literales(9902851, v_idioma)
	                || ';' -- PAGOS: FALLECIMIENTO
	                || f_axis_literales(9902852, v_idioma)
	                || ';'; -- PAGOS: PARO
	    /* Fi Bug 0019794*/
	    /* Bug 0020531 - 14/12/2011 - FAL*/
	    ELSIF p_cinforme=12 THEN
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 12.- Facturacion prevision*/
	    /*------------------------------------------------------------------------*/
	      /*------------------------------------------------------------------------*/
	      v_ttexto:=';'
	                || ';'
	                || ';'
	                || -- Facturación
	                f_axis_literales(9901636, v_idioma)
	                || ';'
	                || ';'
	                || ';'
	                || -- Aportaciones extraordinarias
	                f_axis_literales(9902898, v_idioma)
	                || ';'
	                || ';'
	                || ';'
	                || /* Aportaciones periódicas*/
	                f_axis_literales(9902899, v_idioma)
	                || ';'
	                || ';'
	                || ';'
	                || /* Traspasos entrada*/
	                f_axis_literales(9902900, v_idioma)
	                || ';'
	                || ';'
	                || ';'
	                || /* Traspasos salida*/
	                f_axis_literales(9902901, v_idioma)
	                || ';'
	                || ';'
	                || ';'
	                || /* Traspasos internos*/
	                f_axis_literales(9902902, v_idioma)
	                || ';'
	                || ';'
	                || ';';

	      v_ini:=v_ini
	             || v_ttexto
	             || chr(10);

	      v_ttexto:=f_axis_literales(0100565, v_idioma)
	                || ';'
	                || ';'
	                || /* Tipo*/
	                f_axis_literales(100588, v_idioma)
	                || ';'
	                || /* DESCRIPCION*/
	                f_axis_literales(9901677, v_idioma)
	                || ';'
	                || /* TOTAL_ACTUAL*/
	                f_axis_literales(9901678, v_idioma)
	                || ';'
	                || -- TOTAL_ANTERIOR
	                '%;'
	                || /* PORCENTAJE*/
	                f_axis_literales(9901677, v_idioma)
	                || ';'
	                || /* TOTAL_ACT_CARTERA*/
	                f_axis_literales(9901678, v_idioma)
	                || ';'
	                || -- TOTAL_ANT_CARTERA
	                '%;'
	                || /* CARTERA PORCENTAJE*/
	                f_axis_literales(9901677, v_idioma)
	                || ';'
	                || /* TOTAL_ACT_NUEVA_PRODUCCION*/
	                f_axis_literales(9901678, v_idioma)
	                || ';'
	                || -- TOTAL_ANT_NUEVA_PRODUCCION
	                '%;'
	                || /* PRODUCCION PORCENTAJE*/
	                f_axis_literales(9901677, v_idioma)
	                || ';'
	                || /* TOTAL_ACTUAL*/
	                f_axis_literales(9901678, v_idioma)
	                || ';'
	                || -- TOTAL_ANTERIOR
	                '%;'
	                || /* PORCENTAJE*/
	                f_axis_literales(9901677, v_idioma)
	                || ';'
	                || /* TOTAL_ACT_CARTERA*/
	                f_axis_literales(9901678, v_idioma)
	                || ';'
	                || -- TOTAL_ANT_CARTERA
	                '%;'
	                || /* CARTERA PORCENTAJE*/
	                f_axis_literales(9901677, v_idioma)
	                || ';'
	                || /* TOTAL_ACT_NUEVA_PRODUCCION*/
	                f_axis_literales(9901678, v_idioma)
	                || ';'
	                || -- TOTAL_ANT_NUEVA_PRODUCCION
	                '%;'
	                || ';'
	                || -- PRODUCCION PORCENTAJE
	                '';
	    /* Fi Bug 0020531*/
	    ELSE
	      /* Informe no controlado.*/
	      v_ttexto:='Error;';
	    END IF;

	    RETURN v_ini
	           || v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN NULL;
	END f_list001_cab;

	/******************************************************************************************
	  Descripció: Funció que genera texte select detall per llistat (map 415 dinamic)
	  Paràmetres entrada: - p_cinforme    -> codigo informe (detvalor 1021)
	                      - p_cidioma     -> codigo idioma
	                      - p_cempres     -> codigo empresa
	                      - p_finiefe     -> fecha inicio
	                      - p_ffinefe     -> fecha final
	                      - p_ctipage     -> Tipo (detvalor 1022) (tipo agente)
	                      - p_cagente     -> codigo en funcion del tipo (zona, oficina, agente)
	                      - p_sperson     -> codigo cliente
	                      - p_cnegocio    -> Negocio (detvalor 1023)
	                      - p_codigosn    -> Codigos de negocio (separados por comas)
	                      - p_sproduc     -> Producto de la actividad
	  return:             texte select detall
	******************************************************************************************/
	/* Bug 0016529 - 29/11/2010 - JMF*/
	FUNCTION f_list001_det(
			p_cinforme	IN	NUMBER,
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL,
			p_ctipage	IN	NUMBER DEFAULT NULL,
			p_cagente	IN	NUMBER DEFAULT NULL,
			p_sperson	IN	NUMBER DEFAULT NULL,
			p_cnegocio	IN	NUMBER DEFAULT NULL,
			p_codigosn	IN	VARCHAR2 DEFAULT NULL,
			p_sproduc	IN	VARCHAR2 DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.F_LIST001_DET';
	  v_tparam  VARCHAR2(1000):='c='
	                           || p_cinforme
	                           || ' i='
	                           || p_cidioma
	                           || ' e='
	                           || p_cempres
	                           || ' i='
	                           || p_finiefe
	                           || ' f='
	                           || p_ffinefe
	                           || ' t='
	                           || p_ctipage
	                           || ' a='
	                           || p_cagente
	                           || ' p='
	                           || p_sperson
	                           || ' n='
	                           || p_cnegocio
	                           || ' p='
	                           || p_sproduc
	                           || ' c='
	                           || p_codigosn;
	  v_ntraza  NUMBER:=0;
	  v_finiefe VARCHAR2(100);
	  v_ffinefe VARCHAR2(100);
	BEGIN
	    v_ntraza:=1000;

	    v_ttexto:=NULL;

	    IF p_cinforme=1 THEN
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 1.- Facturación*/
	    /*------------------------------------------------------------------------*/
	      /*------------------------------------------------------------------------*/
	      v_ntraza:=1005;

	      v_ttexto:=f_list001_det01_facturacion(p_cinforme, p_cidioma, p_cempres, p_finiefe, p_ffinefe, p_ctipage, p_cagente, p_sperson, p_cnegocio, p_codigosn, p_sproduc);
	    ELSIF p_cinforme=2 THEN
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 2.- Pólizas/planes*/
	    /*------------------------------------------------------------------------*/
	      /*------------------------------------------------------------------------*/
	      v_ntraza:=1100;

	      v_ttexto:=f_list001_det02_polizas(p_cinforme, p_cidioma, p_cempres, p_finiefe, p_ffinefe, p_ctipage, p_cagente, p_sperson, p_cnegocio, p_codigosn, p_sproduc);
	    ELSIF p_cinforme=3 THEN
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 3.- Comisiones pagadas*/
	    /*------------------------------------------------------------------------*/
	      /*------------------------------------------------------------------------*/
	      v_ntraza:=1205;

	      v_ttexto:=f_list001_det03_comisiones(p_cinforme, p_cidioma, p_cempres, p_finiefe, p_ffinefe, p_ctipage, p_cagente, p_sperson, p_cnegocio, p_codigosn, p_sproduc);
	    ELSIF p_cinforme=4 THEN
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 4.- Volumen de negocio*/
	    /*------------------------------------------------------------------------*/
	      /*------------------------------------------------------------------------*/
	      v_ntraza:=1305;

	      v_ttexto:=f_list001_det04_negocio(p_cinforme, p_cidioma, p_cempres, p_finiefe, p_ffinefe, p_ctipage, p_cagente, p_sperson, p_cnegocio, p_codigosn, p_sproduc);
	    ELSIF p_cinforme=5 THEN
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 5.- Siniestros - Número de expedientes*/
	    /*------------------------------------------------------------------------*/
	      /*------------------------------------------------------------------------*/
	      v_ntraza:=1405;

	      v_ttexto:=f_list001_det05_expedientes(p_cinforme, p_cidioma, p_cempres, p_finiefe, p_ffinefe, p_ctipage, p_cagente, p_sperson, p_cnegocio, p_codigosn, p_sproduc);
	    /* Bug 0019794 - 26/11/2011 - FAL*/
	    ELSIF p_cinforme=6 THEN
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 6.- Siniestros - Número de expedientes ramo No vida*/
	    /*------------------------------------------------------------------------*/
	      /*------------------------------------------------------------------------*/
	      v_ntraza:=1405;

	      v_ttexto:=f_list001_det06_exped_no_vida(p_cinforme, p_cidioma, p_cempres, p_finiefe, p_ffinefe, p_ctipage, p_cagente, p_sperson, p_cnegocio, p_codigosn, p_sproduc);
	    ELSIF p_cinforme=7 THEN
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 7.- Siniestros - Volumen siniestralidad ramo No vida*/
	    /*------------------------------------------------------------------------*/
	      /*------------------------------------------------------------------------*/
	      v_ntraza:=1405;

	      v_ttexto:=f_list001_det07_volsin_no_vida(p_cinforme, p_cidioma, p_cempres, p_finiefe, p_ffinefe, p_ctipage, p_cagente, p_sperson, p_cnegocio, p_codigosn, p_sproduc);
	    ELSIF p_cinforme=8 THEN
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 8.- Siniestros - Número de expedientes ramo vida*/
	    /*------------------------------------------------------------------------*/
	      /*------------------------------------------------------------------------*/
	      v_ntraza:=1405;

	      v_ttexto:=f_list001_det08_exped_vida(p_cinforme, p_cidioma, p_cempres, p_finiefe, p_ffinefe, p_ctipage, p_cagente, p_sperson, p_cnegocio, p_codigosn, p_sproduc);
	    ELSIF p_cinforme=9 THEN
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 9.- Siniestros - Volumen siniestralidad ramo vida*/
	    /*------------------------------------------------------------------------*/
	      /*------------------------------------------------------------------------*/
	      v_ntraza:=1405;

	      v_ttexto:=f_list001_det09_volsini_vida(p_cinforme, p_cidioma, p_cempres, p_finiefe, p_ffinefe, p_ctipage, p_cagente, p_sperson, p_cnegocio, p_codigosn, p_sproduc);
	    ELSIF p_cinforme=10 THEN
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 10.- Siniestros - Número de expedientes pensiones*/
	    /*------------------------------------------------------------------------*/
	      /*------------------------------------------------------------------------*/
	      v_ntraza:=1405;

	      v_ttexto:=f_list001_det10_exped_pens(p_cinforme, p_cidioma, p_cempres, p_finiefe, p_ffinefe, p_ctipage, p_cagente, p_sperson, p_cnegocio, p_codigosn, p_sproduc);
	    ELSIF p_cinforme=11 THEN
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 11.- Siniestros - Volumen siniestralidad pensiones*/
	    /*------------------------------------------------------------------------*/
	      /*------------------------------------------------------------------------*/
	      v_ntraza:=1405;

	      v_ttexto:=f_list001_det11_volsini_pens(p_cinforme, p_cidioma, p_cempres, p_finiefe, p_ffinefe, p_ctipage, p_cagente, p_sperson, p_cnegocio, p_codigosn, p_sproduc);
	    /* Fi Bug 0019794*/
	    /* Bug 0020531 - 14/12/2011 - FAL*/
	    ELSIF p_cinforme=12 THEN
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 12.- Facturación previsión*/
	    /*------------------------------------------------------------------------*/
	      /*------------------------------------------------------------------------*/
	      v_ntraza:=1405;

	      v_ttexto:=f_list001_det12_fact_previs(p_cinforme, p_cidioma, p_cempres, p_finiefe, p_ffinefe, p_ctipage, p_cagente, p_sperson, p_cnegocio, p_codigosn, p_sproduc);
	    /* Fi Bug 0020531*/
	    ELSE
	      v_ntraza:=1500;

	      /* codigo informe no controlado*/
	      v_ttexto:='select 1 from dual';
	    END IF;

	    v_ntraza:=9999;

	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list001_det;

	/* Bug 0018819 - 08/07/2011 - JMF*/
	FUNCTION f_list002_det(
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_filtro	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL,
			p_ctiprec	IN	NUMBER DEFAULT NULL,
			p_cestrec	IN	NUMBER DEFAULT NULL,
			p_cestado	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_ccompani	IN	NUMBER DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.F_LIST002_DET';
	  v_tparam  VARCHAR2(1000):=' i='
	                           || p_cidioma
	                           || ' f='
	                           || p_filtro
	                           || ' i='
	                           || p_finiefe
	                           || ' f='
	                           || p_ffinefe
	                           || ' t='
	                           || p_ctiprec
	                           || ' c='
	                           || p_cestrec
	                           || ' e='
	                           || p_cestado
	                           || ' m='
	                           || p_cempres
	                           || ' c='
	                           || p_ccompani;
	  v_ntraza  NUMBER:=0;
	  v_finiefe VARCHAR2(100);
	  v_ffinefe VARCHAR2(100);
	  v_sep     VARCHAR2(1):=';';
	BEGIN
	    v_ntraza:=1040;

	    v_ttexto:=NULL;

	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 2.- Listado Recibos*/
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    v_ntraza:=1045;

	    /*v_finiefe := 'to_date(' || p_finiefe || ',''ddmmyyyy'')';*/
	    /*v_ffinefe := 'to_date(' || p_ffinefe || ',''ddmmyyyy'')';*/
	    v_finiefe:=ltrim(to_char(p_finiefe, '09999999'));

	    v_finiefe:='to_date('
	               || chr(39)
	               || v_finiefe
	               || chr(39)
	               || ',''ddmmyyyy'')';

	    v_ffinefe:=ltrim(to_char(p_ffinefe, '09999999'));

	    v_ffinefe:='to_date('
	               || chr(39)
	               || v_ffinefe
	               || chr(39)
	               || ',''ddmmyyyy'')';

	    v_ntraza:=1050;

	    /* Bug 18946 - APD - 28/10/2011 - se sustituye la vista agentes_agente por agentes_agente_pol*/
	    v_ttexto:='SELECT /*+ INDEX_JOIN(S) */'
	              || ' c.tcompani ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| ff_desramo(s.cramo, '
	              || p_cidioma
	              || ') || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ''
	              || ' || f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, '
	              || p_cidioma
	              || ')'
	              || ' || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || ff_desactividad(s.cactivi, s.cramo, '
	              || p_cidioma
	              || ') || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' '
	              || ' || s.cagente || '' - '' || ff_desagente(s.cagente) || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ''
	              || ' || f_nombre(g.sperson, 2, ff_agente_cpervisio(s.cagente)) || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || s.npoliza'
	              || ' || '' - '' || s.ncertif || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || s.cpolcia || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| s.fefecto || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ''
	              || ' || s.fcarpro || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || ff_desvalorfijo(17, '
	              || p_cidioma
	              || ', s.cforpag) || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || r.nrecibo || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || r.creccia || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || r.fefecto || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || r.femisio'
	              || '      || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || r.fvencim || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || ff_desvalorfijo(8, '
	              || p_cidioma
	              || ', r.ctiprec) || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ''
	              || ' || (SELECT COUNT(1) FROM movrecibo WHERE cestrec = 0 AND cestant = 1 AND nrecibo = r.nrecibo)'
	              || ' || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || v.itotpri || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ''
	              || ' || ff_desvalorfijo(1, '
	              || p_cidioma
	              /*         || ', f_cestrec(r.nrecibo, f_sysdate)) || ' || CHR(39) || v_sep || CHR(39)*/
	              || ', x.cestrec) || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || ff_desvalorfijo(61, '
	              || p_cidioma
	              || ', s.csituac) || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || NULL'
	              || ' linea'
	              || ' FROM seguros s, agentes_agente_pol a, recibos r, vdetrecibos v, empresas e, companias c, tomadores g, movrecibo x'
	              || ' WHERE s.sseguro = r.sseguro'
	              || '  AND v.nrecibo = r.nrecibo'
	              || '  AND r.cagente = a.cagente'
	              || '  AND r.cempres = a.cempres'
	              || '  AND (s.cagente, s.cempres)'
	              || '      IN (SELECT r.cagente, r.cempres FROM redcomercial r'
	              || '           WHERE r.fmovfin IS NULL'
	              || '           AND LEVEL = DECODE(ff_agente_cpernivel(s.cagente), 1, LEVEL, 1) '
	              || '           START WITH r.cagente = pac_user.ff_get_cagente(f_user)'
	              || '           CONNECT BY PRIOR r.cagente = r.cpadre AND PRIOR r.fmovfin IS NULL)'
	              || '  and x.nrecibo = r.nrecibo and x.fmovfin is null';

	    v_ntraza:=1050;

	    IF p_filtro=1 THEN
	      IF p_finiefe IS NOT NULL THEN
	        v_ttexto:=v_ttexto
	                  || ' AND TRUNC(x.fmovdia) >= '
	                  || v_finiefe;
	      END IF;

	      IF p_ffinefe IS NOT NULL THEN
	        v_ttexto:=v_ttexto
	                  || ' AND TRUNC(x.fmovdia) <= '
	                  || v_ffinefe;
	      END IF;
	    ELSIF p_filtro=2 THEN
	      IF p_finiefe IS NOT NULL THEN
	        v_ttexto:=v_ttexto
	                  || ' AND TRUNC(NVL(x.fcontab, x.fefeadm)) >= '
	                  || v_finiefe;
	      END IF;

	      IF p_ffinefe IS NOT NULL THEN
	        v_ttexto:=v_ttexto
	                  || ' AND TRUNC(NVL(x.fcontab, x.fefeadm)) <= '
	                  || v_ffinefe;
	      END IF;
	    ELSIF nvl(p_filtro, 0)=0 THEN
	      IF p_finiefe IS NOT NULL THEN
	        v_ttexto:=v_ttexto
	                  || ' AND r.fefecto >= '
	                  || v_finiefe;
	      END IF;

	      IF p_ffinefe IS NOT NULL THEN
	        v_ttexto:=v_ttexto
	                  || ' AND r.fefecto <= '
	                  || v_ffinefe;
	      END IF;
	    END IF;

	    IF p_ctiprec IS NOT NULL THEN
	      v_ttexto:=v_ttexto
	                || ' AND r.ctiprec = '
	                || p_ctiprec;
	    END IF;

	    IF p_cestrec IS NOT NULL THEN
	      IF p_cestrec=0 THEN
	        v_ttexto:=v_ttexto
	                  || ' AND to_char(x.cestrec)||to_char(x.cestant) = '
	                  || chr(39)
	                  || '00'
	                  || chr(39);
	      ELSIF p_cestrec=1 THEN
	        v_ttexto:=v_ttexto
	                  || ' AND x.cestrec) = 1';
	      ELSIF p_cestrec=2 THEN
	        v_ttexto:=v_ttexto
	                  || ' AND x.cestrec) = 2';
	      ELSIF p_cestrec=3 THEN
	        v_ttexto:=v_ttexto
	                  || ' AND x.cestrec) = 3';
	      ELSIF p_cestrec=4 THEN
	        v_ttexto:=v_ttexto
	                  || ' AND to_char(x.cestrec)||to_char(x.cestant) = '
	                  || chr(39)
	                  || '01'
	                  || chr(39);
	      END IF;
	    END IF;

	    IF p_cestado IS NOT NULL THEN
	      v_ttexto:=v_ttexto
	                || ' AND s.csituac = '
	                || p_cestado;
	    END IF;

	    v_ttexto:=v_ttexto
	              || ' AND r.cempres = '
	              || p_cempres
	              || ' AND e.cempres = r.cempres'
	              || ' AND c.ccompani = s.ccompani'
	              || ' AND g.sseguro = s.sseguro';

	    IF p_ccompani IS NOT NULL THEN
	      v_ttexto:=v_ttexto
	                || ' AND s.ccompani =  '
	                || p_ccompani;
	    END IF;

	    v_ttexto:=v_ttexto
	              || ' order by 1';

	    v_ntraza:=9999;

	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list002_det;
	FUNCTION f_list003_cab(
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_filtro	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL,
			p_ctiprec	IN	NUMBER DEFAULT NULL,
			p_cestrec	IN	NUMBER DEFAULT NULL,
			p_cestado	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_ccompani	IN	NUMBER DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto    VARCHAR2(100):='PAC_INFORMES.F_LIST003_CAB';
	  v_tparam     VARCHAR2(1000):=' i='
	                           || p_cidioma
	                           || ' e='
	                           || p_cempres;
	  v_ntraza     NUMBER:=0;
	  v_ini        VARCHAR2(32000);
	  v_idioma     NUMBER;
	  v_tproduc    VARCHAR2(500);
	  verror       NUMBER;
	  cad1         VARCHAR2(1000);
	  cad2         VARCHAR2(10);
	  vtactivi     VARCHAR2(40);
	  vcad         NUMBER:=1;
	  v_parcompani NUMBER;
	  v_sep        VARCHAR2(1):=';';
	  v_tcompani   VARCHAR2(400);
	BEGIN
	    v_ntraza:=1000;

	    v_ttexto:=NULL;

	    IF p_cidioma IS NULL THEN
	      SELECT max(nvalpar)
	        INTO v_idioma
	        FROM parinstalacion
	       WHERE cparame='IDIOMARTF';
	    ELSE
	      v_idioma:=p_cidioma;
	    END IF;

	    /* Bug 0018819 - 26/07/2011 - JMF*/
	    v_ini:=''
	           || f_axis_literales(9901789, v_idioma)
	           || ';'
	           || chr(10)
	           || f_axis_literales(9000526, v_idioma)
	           || ';'
	           || to_date(ltrim(to_char(p_finiefe, '09999999')), 'ddmmrrrr')
	           || ';' -- fecha inicio
	           || f_axis_literales(9000527, v_idioma)
	           || ';'
	           || to_date(ltrim(to_char(p_ffinefe, '09999999')), 'ddmmrrrr')
	           || ';' -- fecha final
	           || chr(10);

	    IF p_filtro=0 THEN
	      v_ini:=v_ini
	             || f_axis_literales(1000178, v_idioma)
	             || ';'
	             || f_axis_literales(100883, v_idioma)
	             || ';';
	    ELSIF p_filtro=1 THEN
	      v_ini:=v_ini
	             || f_axis_literales(1000178, v_idioma)
	             || ';'
	             || f_axis_literales(101006, v_idioma)
	             || ';';
	    ELSIF p_filtro=2 THEN
	      v_ini:=v_ini
	             || f_axis_literales(1000178, v_idioma)
	             || ';'
	             || f_axis_literales(9901778, v_idioma)
	             || ';';
	    END IF;

	    IF p_ctiprec IS NOT NULL THEN
	      v_ini:=v_ini
	             || chr(10)
	             || f_axis_literales(102302, v_idioma)
	             || ';'
	             || ff_desvalorfijo(8, v_idioma, p_ctiprec)
	             || ';';
	    END IF;

	    IF p_cestrec IS NOT NULL THEN
	      v_ini:=v_ini
	             || chr(10)
	             || f_axis_literales(1000553, v_idioma)
	             || ';'
	             || ff_desvalorfijo(3, v_idioma, p_cestrec)
	             || ';';
	    END IF;

	    IF p_ccompani IS NOT NULL THEN BEGIN
	          SELECT tcompani
	            INTO v_tcompani
	            FROM companias
	           WHERE ccompani=p_ccompani;

	          v_ini:=v_ini
	                 || chr(10)
	                 || f_axis_literales(9000600, v_idioma)
	                 || ';'
	                 || v_tcompani
	                 || ';';
	      EXCEPTION
	          WHEN OTHERS THEN
	            NULL;
	      END;
	    END IF;

	    IF p_cestado IS NOT NULL THEN
	      v_ini:=v_ini
	             || chr(10)
	             || f_axis_literales(1000553, v_idioma)
	             || ';'
	             || ff_desvalorfijo(61, v_idioma, p_cestado)
	             || ';';
	    END IF;

	    v_ini:=v_ini
	           || chr(10);

	    v_parcompani:=pac_parametros.f_parlistado_n(p_cempres, 'CCOMPANI');

	    v_ttexto:='';

	    IF v_parcompani=1 THEN
	      v_ttexto:=v_ttexto
	                || f_axis_literales(9901223, v_idioma)
	                || v_sep; /* Compañia*/
	    END IF;

	    v_ttexto:=v_ttexto
	              || f_axis_literales(100784, v_idioma)
	              || v_sep; /* ramo*/

	    v_ttexto:=v_ttexto
	              || f_axis_literales(100829, v_idioma)
	              || v_sep /* Producto*/
	              || f_axis_literales(103481, v_idioma)
	              || v_sep /* actividad*/
	              || f_axis_literales(102347, v_idioma)
	              || v_sep
	              || f_axis_literales(101027, v_idioma)
	              || v_sep
	              || f_axis_literales(9001875, v_idioma)
	              || v_sep;

	    IF v_parcompani=1 THEN
	      v_ttexto:=v_ttexto
	                || f_axis_literales(9901675, v_idioma)
	                || v_sep;
	    END IF;

	    v_ttexto:=v_ttexto
	              || f_axis_literales(100883, v_idioma)
	              || ' '
	              || f_axis_literales(9001875, v_idioma)
	              || v_sep
	              || f_axis_literales(109716, v_idioma)
	              || v_sep
	              || f_axis_literales(103313, v_idioma)
	              || v_sep
	              || f_axis_literales(101516, v_idioma)
	              || v_sep;

	    IF v_parcompani=1 THEN
	      v_ttexto:=v_ttexto
	                || f_axis_literales(9901670, v_idioma)
	                || v_sep;
	    END IF;

	    v_ttexto:=v_ttexto
	              || f_axis_literales(100895, v_idioma)
	              || v_sep
	              || f_axis_literales(100883, v_idioma)
	              || v_sep /* Fecha efecto*/
	              || f_axis_literales(1000562, v_idioma)
	              || v_sep
	              || f_axis_literales(100885, v_idioma)
	              || v_sep
	              || f_axis_literales(102302, v_idioma)
	              || v_sep
	              || f_axis_literales(9000842, v_idioma)
	              || v_sep
	              || f_axis_literales(100563, v_idioma)
	              || v_sep
	              || f_axis_literales(1000553, v_idioma)
	              || v_sep
	              || f_axis_literales(100874, v_idioma)
	              || '';

	    RETURN v_ini
	           || v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN NULL;
	END f_list003_cab;

	/* Bug 0018819 - 08/07/2011 - JMF*/
	FUNCTION f_list003_det(
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_filtro	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL,
			p_ctiprec	IN	NUMBER DEFAULT NULL,
			p_cestrec	IN	NUMBER DEFAULT NULL,
			p_cestado	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_ccompani	IN	NUMBER DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.F_LIST003_DET';
	  v_tparam  VARCHAR2(1000):=' i='
	                           || p_cidioma
	                           || ' f='
	                           || p_filtro
	                           || ' i='
	                           || p_finiefe
	                           || ' f='
	                           || p_ffinefe
	                           || ' t='
	                           || p_ctiprec
	                           || ' c='
	                           || p_cestrec
	                           || ' e='
	                           || p_cestado
	                           || ' m='
	                           || p_cempres
	                           || ' c='
	                           || p_ccompani;
	  v_ntraza  NUMBER:=0;
	  v_finiefe VARCHAR2(100);
	  v_ffinefe VARCHAR2(100);
	  v_sep     VARCHAR2(1):=';';
	BEGIN
	    v_ntraza:=1040;

	    v_ttexto:=NULL;

	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 3.- Listado Recibos pendientes por póliza*/
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    v_ntraza:=1045;

	    /* Bug 0018819 - 26/07/2011 - JMF*/
	    /*v_finiefe := 'to_date(' || p_finiefe || ',''ddmmyyyy'')';*/
	    /*v_ffinefe := 'to_date(' || p_ffinefe || ',''ddmmyyyy'')';*/
	    v_finiefe:=ltrim(to_char(p_finiefe, '09999999'));

	    v_finiefe:='to_date('
	               || chr(39)
	               || v_finiefe
	               || chr(39)
	               || ',''ddmmyyyy'')';

	    v_ffinefe:=ltrim(to_char(p_ffinefe, '09999999'));

	    v_ffinefe:='to_date('
	               || chr(39)
	               || v_ffinefe
	               || chr(39)
	               || ',''ddmmyyyy'')';

	    v_ntraza:=1050;

	    /* Bug 18946 - APD - 28/10/2011 - se sustituye la vista agentes_agente por agentes_agente_pol*/
	    v_ttexto:=' SELECT DECODE(pac_parametros.f_parlistado_n('
	              || p_cempres
	              || ', ''CCOMPANI''), 1, c.tcompani , NULL)|| '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || ff_desramo(s.cramo, '
	              || p_cidioma
	              || ') || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, '
	              || p_cidioma
	              || ') || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || ff_desactividad(s.cactivi, s.cramo, '
	              || p_cidioma
	              || ') || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || s.cagente || '' - '' || ff_desagente(s.cagente) || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || f_nombre(g.sperson, 2, ff_agente_cpervisio(s.cagente)) || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || s.npoliza || '' - '' || s.ncertif || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || DECODE(pac_parametros.f_parlistado_n('
	              || p_cempres
	              || ', ''CCOMPANI''), 1, s.cpolcia || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ', NULL)'
	              || ' || s.fefecto || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || s.fcarpro || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || ff_desvalorfijo(17, '
	              || p_cidioma
	              || ', s.cforpag) || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || pac_isqlfor.f_formapagorecibo(r.nrecibo, '
	              || p_cidioma
	              || ') || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || r.nrecibo || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || DECODE(pac_parametros.f_parlistado_n('
	              || p_cempres
	              || ', ''CCOMPANI''), 1, r.creccia || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ', NULL)'
	              || ' || r.fefecto || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || r.femisio || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || r.fvencim || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || ff_desvalorfijo(8, '
	              || p_cidioma
	              || ', r.ctiprec) || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || (SELECT COUNT(1) FROM movrecibo WHERE (cestrec = 0 AND cestant = 1) AND nrecibo = r.nrecibo) || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || v.itotpri || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || ff_desvalorfijo(383, '
	              || p_cidioma
	              || ', decode( to_char(x.cestrec)||to_char(x.cestant),'
	              || chr(39)
	              || '01'
	              || chr(39)
	              || ',4,x.cestrec)'
	              || ') || '
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || ff_desvalorfijo(61, '
	              || p_cidioma
	              || ', s.csituac) linea'
	              || ' FROM seguros s, agentes_agente_pol a, recibos r, vdetrecibos v, empresas e, companias c, tomadores g, movrecibo x'
	              || ' WHERE s.sseguro = r.sseguro'
	              || ' AND v.nrecibo = r.nrecibo'
	              || '  AND r.cagente = a.cagente'
	              || '  AND r.cempres = a.cempres'
	              || '  AND (s.cagente, s.cempres)'
	              || '      IN (SELECT r.cagente, r.cempres FROM redcomercial r'
	              || '           WHERE r.fmovfin IS NULL'
	              || '           AND LEVEL = DECODE(ff_agente_cpernivel(s.cagente), 1, LEVEL, 1) '
	              || '           START WITH r.cagente = pac_user.ff_get_cagente(f_user)'
	              || '           CONNECT BY PRIOR r.cagente = r.cpadre AND PRIOR r.fmovfin IS NULL)'
	              || '  and x.nrecibo = r.nrecibo and x.fmovfin is null';

	    v_ntraza:=1050;

	    IF p_filtro=1 THEN
	      IF p_finiefe IS NOT NULL THEN
	        v_ttexto:=v_ttexto
	                  || ' AND TRUNC(x.fmovdia) >= '
	                  || v_finiefe;
	      END IF;

	      IF p_ffinefe IS NOT NULL THEN
	        v_ttexto:=v_ttexto
	                  || ' AND TRUNC(x.fmovdia) <= '
	                  || v_ffinefe;
	      END IF;
	    ELSIF p_filtro=2 THEN
	      IF p_finiefe IS NOT NULL THEN
	        v_ttexto:=v_ttexto
	                  || ' AND TRUNC(NVL(x.fcontab, x.fefeadm)) >= '
	                  || v_finiefe;
	      END IF;

	      IF p_ffinefe IS NOT NULL THEN
	        v_ttexto:=v_ttexto
	                  || ' AND TRUNC(NVL(x.fcontab, x.fefeadm)) <= '
	                  || v_ffinefe;
	      END IF;
	    ELSIF nvl(p_filtro, 0)=0 THEN
	      IF p_finiefe IS NOT NULL THEN
	        v_ttexto:=v_ttexto
	                  || ' AND r.fefecto >= '
	                  || v_finiefe;
	      END IF;

	      IF p_ffinefe IS NOT NULL THEN
	        v_ttexto:=v_ttexto
	                  || ' AND r.fefecto <= '
	                  || v_ffinefe;
	      END IF;
	    END IF;

	    IF p_ctiprec IS NOT NULL THEN
	      v_ttexto:=v_ttexto
	                || ' AND r.ctiprec = '
	                || p_ctiprec;
	    END IF;

	    IF p_cestrec IS NOT NULL THEN
	      IF p_cestrec=0 THEN
	        v_ttexto:=v_ttexto
	                  || ' AND to_char(x.cestrec)||to_char(x.cestant) = '
	                  || chr(39)
	                  || '00'
	                  || chr(39);
	      ELSIF p_cestrec=1 THEN
	        v_ttexto:=v_ttexto
	                  || ' AND x.cestrec) = 1';
	      ELSIF p_cestrec=2 THEN
	        v_ttexto:=v_ttexto
	                  || ' AND x.cestrec) = 2';
	      ELSIF p_cestrec=3 THEN
	        v_ttexto:=v_ttexto
	                  || ' AND x.cestrec) = 3';
	      ELSIF p_cestrec=4 THEN
	        v_ttexto:=v_ttexto
	                  || ' AND to_char(x.cestrec)||to_char(x.cestant) = '
	                  || chr(39)
	                  || '01'
	                  || chr(39);
	      END IF;
	    END IF;

	    IF p_cestado IS NOT NULL THEN
	      v_ttexto:=v_ttexto
	                || ' AND s.csituac = '
	                || p_cestado;
	    END IF;

	    v_ttexto:=v_ttexto
	              || ' AND r.cempres = '
	              || p_cempres
	              || ' AND e.cempres = r.cempres'
	              || ' AND c.ccompani = s.ccompani'
	              || ' AND g.sseguro = s.sseguro';

	    IF p_ccompani IS NOT NULL THEN
	      v_ttexto:=v_ttexto
	                || ' AND s.ccompani =  '
	                || p_ccompani;
	    END IF;

	    v_ttexto:=v_ttexto
	              || ' order by 1';

	    v_ntraza:=9999;

	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list003_det;

	/* INI Bug 0019844 - 24/10/2011 - JMC*/
	FUNCTION f_list470_cab(
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.F_LIST470_CAB';
	  v_tparam  VARCHAR2(1000):=' idioma='
	                           || p_cidioma
	                           || ' fecini='
	                           || p_finiefe
	                           || ' fecfin='
	                           || p_ffinefe;
	  v_ntraza  NUMBER:=0;
	  v_idioma  NUMBER;
	  verror    NUMBER;
	  v_sep     VARCHAR2(1):=';';
	BEGIN
	    v_ntraza:=1000;

	    v_ttexto:=NULL;

	    IF p_cidioma IS NULL THEN
	      SELECT max(nvalpar)
	        INTO v_idioma
	        FROM parinstalacion
	       WHERE cparame='IDIOMARTF';
	    ELSE
	      v_idioma:=p_cidioma;
	    END IF;

	    v_ttexto:=f_axis_literales(9000526, v_idioma)
	              || v_sep
	              || to_date(ltrim(to_char(p_finiefe, '09999999')), 'ddmmrrrr')
	              || v_sep
	              || f_axis_literales(9000527, v_idioma)
	              || v_sep
	              || to_date(ltrim(to_char(p_ffinefe, '09999999')), 'ddmmrrrr')
	              || chr(10);

	    v_ttexto:=v_ttexto
	              || f_axis_literales(9901223, v_idioma)
	              || v_sep
	              || f_axis_literales(100829, v_idioma)
	              || v_sep
	              || f_axis_literales(100561, v_idioma)
	              || v_sep
	              || f_axis_literales(100756, v_idioma)
	              || v_sep
	              || f_axis_literales(100823, v_idioma)
	              || v_sep
	              || f_axis_literales(9901930, v_idioma)
	              || v_sep
	              || f_axis_literales(9901931, v_idioma)
	              || v_sep
	              || f_axis_literales(9902516, v_idioma)
	              || v_sep
	              || f_axis_literales(9902520, v_idioma)
	              || v_sep
	              || f_axis_literales(9902517, v_idioma)
	              || v_sep
	              || f_axis_literales(9902518, v_idioma)
	              || v_sep
	              || f_axis_literales(9902519, v_idioma)
	              || v_sep
	              || f_axis_literales(9902521, v_idioma)
	              || v_sep
	              || f_axis_literales(9902522, v_idioma)
	              || v_sep
	              || f_axis_literales(9902523, v_idioma)
	              || v_sep
	              || f_axis_literales(9902524, v_idioma)
	              || v_sep
	              || f_axis_literales(9902525, v_idioma);

	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN NULL;
	END f_list470_cab;
	FUNCTION f_list470_det(
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.F_LIST470_DET';
	  v_tparam  VARCHAR2(1000):=' i='
	                           || p_cidioma
	                           || ' i='
	                           || p_finiefe
	                           || ' f='
	                           || p_ffinefe;
	  v_ntraza  NUMBER:=0;
	  v_finiefe VARCHAR2(100);
	  v_ffinefe VARCHAR2(100);
	  v_sep     VARCHAR2(1):=';';
	BEGIN
	    v_ntraza:=1040;

	    v_ttexto:=NULL;

	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    /* INFORME 470.- Indicadores de Negocio*/
	    /*------------------------------------------------------------------------*/
	    /*------------------------------------------------------------------------*/
	    v_ntraza:=1045;

	    v_finiefe:=ltrim(to_char(p_finiefe, '09999999'));

	    v_finiefe:='to_date('
	               || chr(39)
	               || v_finiefe
	               || chr(39)
	               || ',''ddmmyyyy'')';

	    v_ffinefe:=ltrim(to_char(p_ffinefe, '09999999'));

	    v_ffinefe:='to_date('
	               || chr(39)
	               || v_ffinefe
	               || chr(39)
	               || ',''ddmmyyyy'')';

	    v_ntraza:=1050;

	    v_ttexto:='SELECT det.compani||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||det.sproduc || ''-'' || det.ttitulo||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||det.cgarant || ''-'' || det.tgarant||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||det.tprovin||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||det.cpostal||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||det.cmediad || '' - '' || det.tmediad||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||det.ccolabo || '' - '' || det.tcolabo||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||NVL(SUM(det.vig), 0)||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||NVL(SUM(det.ipri), 0)||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NVL(SUM(det.anul), 0) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||NVL(SUM(det.np), 0)||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||NVL(SUM(det.car), 0)||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||NVL(SUM(det.sini), 0)||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||NVL(SUM(det.icomisi), 0)||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||NVL(SUM(det.idto), 0)||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NVL(SUM(det.irecarg), 0) linea'
	              || ' FROM (SELECT agrup.tempres compani, agrup.sproduc sproduc, agrup.ttitulo ttitulo,'
	              || ' agrup.cgarant, agrup.tgarant, agrup.tprovin, agrup.cpostal, agrup.cmediad,'
	              || ' agrup.tmediad, agrup.ccolabo, agrup.tcolabo, NVL(polvig.vig, 0) vig,'
	              || ' NVL(polvig.iprianu, 0) ipri, NVL(polanul.anul, 0) anul, NVL(polvig.np, 0) np,'
	              || ' NVL(polvig.car, 0) car, NVL(polsin.sini, 0) sini, NVL(comisi.icomisi,0) icomisi,'
	              || ' NVL(dto.idto, 0) idto, NVL(recarg.irecarg, 0) irecarg'
	              || ' FROM (SELECT tempres, sproduc, ttitulo, gs.cgarant, gg.tgarant,'
	              || ' NVL(rc.cpadre, rc.cagente) cmediad,'
	              || ' f_nombre(a2.sperson, 1, pac_md_common.f_get_cxtagente) tmediad,'
	              || ' s.cagente ccolabo,'
	              || ' f_nombre(a.sperson, 1, pac_md_common.f_get_cxtagente) tcolabo, s.sseguro,'
	              || ' d.cpostal, p.tprovin, p.cprovin, gs.nriesgo'
	              || ' FROM seguros s, empresas e, titulopro tp, garanseg gs, garangen gg, agentes a,'
	              || ' redcomercial rc, agentes a2, tomadores t, direcciones d, provincias p'
	              || ' WHERE e.cempres = s.cempres'
	              || ' AND tp.cramo = s.cramo'
	              || ' AND tp.cmodali = s.cmodali'
	              || ' AND tp.ctipseg = s.ctipseg'
	              || ' AND tp.ccolect = s.ccolect'
	              || ' AND tp.cidioma = pac_md_common.f_get_cxtidioma'
	              || ' AND gs.sseguro = s.sseguro'
	              || ' AND(gs.ffinefe > '
	              || v_finiefe
	              || /*:pfecini*/
	              ' OR gs.ffinefe IS NULL)'
	              || ' AND gs.finiefe < '
	              || v_ffinefe
	              || /*:pfecfin*/
	              ' AND gg.cgarant = gs.cgarant'
	              || ' AND gg.cidioma = pac_md_common.f_get_cxtidioma'
	              || ' AND a.cagente = s.cagente'
	              || ' AND rc.cagente = s.cagente'
	              || ' AND(rc.fmovfin > '
	              || v_finiefe
	              || --:pfecini
	              ' OR rc.fmovfin IS NULL)'
	              || ' AND rc.fmovini < '
	              || v_ffinefe
	              || /*:pfecfin*/
	              ' AND rc.cempres = pac_parametros.f_parinstalacion_n(''EMPRESADEF'')'
	              || ' AND a2.cagente = NVL(rc.cpadre, rc.cagente)'
	              || ' AND t.sseguro = s.sseguro'
	              || ' AND d.sperson = t.sperson'
	              || ' AND p.cprovin = d.cprovin'
	              || ' AND s.cempres = pac_parametros.f_parinstalacion_n(''EMPRESADEF'')'
	              || ' and s.csituac in (0,2)) agrup,'
	              || ' (SELECT s.sseguro, gs.cgarant, NVL(rc.cpadre, rc.cagente) cmediad, s.cagente ccolabo,'
	              || ' s.csituac, s.creteni, 1 vig, gs.nriesgo, s.iprianu, decode(s.nanuali,1,1,0) np, decode(s.nanuali,1,0,1) car'
	              || ' FROM seguros s, garanseg gs, redcomercial rc'
	              || ' WHERE gs.sseguro = s.sseguro'
	              || ' AND(gs.ffinefe > '
	              || v_finiefe
	              || --:pfecini
	              ' OR gs.ffinefe IS NULL)'
	              || ' AND gs.finiefe < '
	              || v_ffinefe
	              || --:pfecfin
	              ' AND rc.cagente = s.cagente'
	              || ' AND(rc.fmovfin > '
	              || v_finiefe --:pfecini
	              || ' OR rc.fmovfin IS NULL)'
	              || ' AND rc.fmovini < '
	              || v_ffinefe
	              || --:pfecfin
	              ' AND s.csituac = 0'
	              || ' AND creteni = 0'
	              || ' AND s.cempres = pac_parametros.f_parinstalacion_n(''EMPRESADEF'')) polvig,'
	              || ' (SELECT s.sseguro, gs.cgarant, NVL(rc.cpadre, rc.cagente) cmediad, s.cagente ccolabo,'
	              || ' s.csituac, s.creteni, 1 anul, gs.nriesgo'
	              || ' FROM seguros s, garanseg gs, redcomercial rc'
	              || ' WHERE gs.sseguro = s.sseguro'
	              || ' AND(gs.ffinefe > '
	              || v_finiefe
	              || --:pfecini
	              ' OR gs.ffinefe IS NULL)'
	              || ' AND gs.finiefe < '
	              || v_ffinefe
	              || --:pfecfin
	              ' AND rc.cagente = s.cagente'
	              || ' AND(rc.fmovfin > '
	              || v_finiefe --:pfecini
	              || ' OR rc.fmovfin IS NULL)'
	              || ' AND rc.fmovini < '
	              || v_ffinefe
	              || --:pfecfin
	              ' AND s.csituac = 2'
	              || ' AND s.cempres = pac_parametros.f_parinstalacion_n(''EMPRESADEF'')) polanul,'
	              || ' (SELECT s.sseguro, gs.cgarant, NVL(rc.cpadre, rc.cagente) cmediad, s.cagente ccolabo,'
	              || ' s.csituac, s.creteni, 1 sini, gs.nriesgo'
	              || ' FROM seguros s, garanseg gs, redcomercial rc'
	              || ' WHERE gs.sseguro = s.sseguro'
	              || ' AND(gs.ffinefe > '
	              || v_finiefe
	              || --:pfecini
	              ' OR gs.ffinefe IS NULL)'
	              || ' AND gs.finiefe < '
	              || v_ffinefe
	              || ' AND rc.cagente = s.cagente'
	              || ' AND(rc.fmovfin > '
	              || v_finiefe --:pfecini
	              || ' OR rc.fmovfin IS NULL)'
	              || ' AND rc.fmovini < '
	              || v_ffinefe
	              || --:pfecfin
	              ' AND EXISTS(SELECT ''*'''
	              || ' FROM sin_movsiniestro ms, sin_siniestro sini, sin_tramita_reserva str'
	              || ' WHERE sini.sseguro = s.sseguro'
	              || ' AND sini.nriesgo = gs.nriesgo'
	              || ' AND str.nsinies = sini.nsinies'
	              || ' AND str.cgarant = gs.cgarant'
	              || ' AND ms.nsinies = sini.nsinies'
	              || ' AND nmovsin >= (SELECT MAX(nmovsin)'
	              || ' FROM sin_movsiniestro'
	              || ' WHERE nsinies = sini.nsinies'
	              || ' AND TRUNC(festsin) <= '
	              || v_ffinefe
	              || ')'
	              || ' AND nmovsin <= (SELECT MAX(nmovsin)'
	              || ' FROM sin_movsiniestro'
	              || ' WHERE nsinies = sini.nsinies'
	              || ' AND TRUNC(festsin) <= '
	              || v_finiefe
	              || ')'
	              || ' AND cestsin IN(0, 4))'
	              || ' AND s.cempres = pac_parametros.f_parinstalacion_n(''EMPRESADEF'')) polsin, '
	              || ' (SELECT s.sseguro, gs.cgarant, NVL(rc.cpadre, rc.cagente) cmediad, s.cagente ccolabo,'
	              || '         gs.nriesgo, iconcep icomisi'
	              || '    FROM seguros s, garanseg gs, redcomercial rc, recibos r, detrecibos dr'
	              || '   WHERE gs.sseguro = s.sseguro'
	              || '     AND(gs.ffinefe > '
	              || v_finiefe
	              || '         OR gs.ffinefe IS NULL)'
	              || '     AND gs.finiefe < '
	              || v_ffinefe
	              || ' AND rc.cagente = s.cagente'
	              || ' AND(rc.fmovfin > '
	              || v_finiefe
	              || '  OR rc.fmovfin IS NULL)'
	              || ' AND rc.fmovini < '
	              || v_ffinefe
	              || ' AND r.sseguro = s.sseguro'
	              || ' AND r.fefecto BETWEEN '
	              || v_finiefe
	              || '   AND '
	              || v_ffinefe
	              || ' AND dr.nrecibo = r.nrecibo'
	              || ' and dr.nriesgo = gs.nriesgo'
	              || ' and dr.cgarant = gs.cgarant'
	              || ' and cconcep in (11,17)'
	              || ' AND s.cempres = pac_parametros.f_parinstalacion_n(''EMPRESADEF'')) comisi,'
	              || ' (SELECT s.sseguro, gs.cgarant, NVL(rc.cpadre, rc.cagente) cmediad, s.cagente ccolabo,'
	              || '         gs.nriesgo, iconcep idto'
	              || '    FROM seguros s, garanseg gs, redcomercial rc, recibos r, detrecibos dr'
	              || '   WHERE gs.sseguro = s.sseguro'
	              || '     AND(gs.ffinefe > '
	              || v_finiefe
	              || '         OR gs.ffinefe IS NULL)'
	              || '     AND gs.finiefe < '
	              || v_ffinefe
	              || ' AND rc.cagente = s.cagente'
	              || ' AND(rc.fmovfin > '
	              || v_finiefe
	              || '  OR rc.fmovfin IS NULL)'
	              || ' AND rc.fmovini < '
	              || v_ffinefe
	              || ' AND r.sseguro = s.sseguro'
	              || ' AND r.fefecto BETWEEN '
	              || v_finiefe
	              || '   AND '
	              || v_ffinefe
	              || ' AND dr.nrecibo = r.nrecibo'
	              || ' and dr.nriesgo = gs.nriesgo'
	              || ' and dr.cgarant = gs.cgarant'
	              || ' and cconcep in (9,10)'
	              || ' AND s.cempres = pac_parametros.f_parinstalacion_n(''EMPRESADEF'')) dto,'
	              || ' (SELECT s.sseguro, gs.cgarant, NVL(rc.cpadre, rc.cagente) cmediad, s.cagente ccolabo,'
	              || '         gs.nriesgo, iconcep irecarg'
	              || '    FROM seguros s, garanseg gs, redcomercial rc, recibos r, detrecibos dr'
	              || '   WHERE gs.sseguro = s.sseguro'
	              || '     AND(gs.ffinefe > '
	              || v_finiefe
	              || '         OR gs.ffinefe IS NULL)'
	              || '     AND gs.finiefe < '
	              || v_ffinefe
	              || ' AND rc.cagente = s.cagente'
	              || ' AND(rc.fmovfin > '
	              || v_finiefe
	              || '  OR rc.fmovfin IS NULL)'
	              || ' AND rc.fmovini < '
	              || v_ffinefe
	              || ' AND r.sseguro = s.sseguro'
	              || ' AND r.fefecto BETWEEN '
	              || v_finiefe
	              || '   AND '
	              || v_ffinefe
	              || ' AND dr.nrecibo = r.nrecibo'
	              || ' and dr.nriesgo = gs.nriesgo'
	              || ' and dr.cgarant = gs.cgarant'
	              || ' and cconcep in (1,3,8)'
	              || ' AND s.cempres = pac_parametros.f_parinstalacion_n(''EMPRESADEF'')) recarg'
	              || ' WHERE polvig.sseguro(+) = agrup.sseguro'
	              || ' AND polvig.cgarant(+) = agrup.cgarant'
	              || ' AND polvig.nriesgo(+) = agrup.nriesgo'
	              || ' AND polanul.sseguro(+) = agrup.sseguro'
	              || ' AND polanul.cgarant(+) = agrup.cgarant'
	              || ' AND polanul.nriesgo(+) = agrup.nriesgo'
	              || ' AND polsin.sseguro(+) = agrup.sseguro'
	              || ' AND polsin.nriesgo(+) = agrup.nriesgo'
	              || ' AND polsin.cgarant(+) = agrup.cgarant'
	              || ' AND comisi.sseguro(+) = agrup.sseguro'
	              || ' AND comisi.nriesgo(+) = agrup.nriesgo'
	              || ' AND comisi.cgarant(+) = agrup.cgarant'
	              || ' AND dto.sseguro(+) = agrup.sseguro'
	              || ' AND dto.nriesgo(+) = agrup.nriesgo'
	              || ' AND dto.cgarant(+) = agrup.cgarant'
	              || ' AND recarg.sseguro(+) = agrup.sseguro'
	              || ' AND recarg.nriesgo(+) = agrup.nriesgo'
	              || ' AND recarg.cgarant(+) = agrup.cgarant'
	              || ' UNION'
	              || ' SELECT c.tcompani compani, s.sproduc, tp.ttitulo, NULL cgarant, NULL tgarant, tprovin,'
	              || ' LPAD(s.cpostal, 5, ''0'') cpostal, cmediad,'
	              || ' f_nombre(a1.sperson, 1, pac_md_common.f_get_cxtagente) tmediad, ccolabo,'
	              || ' f_nombre(a2.sperson, 1, pac_md_common.f_get_cxtagente) tcolabo,'
	              || ' DECODE(s.ctipmov, ''A'', 1, ''C'', 1, 0) vig,'
	              || ' DECODE(s.ctipmov, ''A'', s.iprianu, 0) ipri, DECODE(s.ctipmov, ''B'', 1, 0) anul,'
	              || ' DECODE(s.ctipmov, ''A'', 1, 0) np, DECODE(s.ctipmov, ''C'', 1, 0) car,'
	              || ' NVL(s.csinies, 0) sini, NVL(s.icomisi, 0) icomisi, NVL(s.idescue, 0) idto,'
	              || ' NVL(s.irecarg, 0) irecarg'
	              || ' FROM ext_seguros s, companias c, productos p, titulopro tp, provincias pv,'
	              || ' agentes a1, agentes a2'
	              || ' WHERE c.ccompani = s.ccompani'
	              || ' AND p.sproduc = s.sproduc'
	              || ' AND tp.cramo = p.cramo'
	              || ' AND tp.cmodali = p.cmodali'
	              || ' AND tp.ctipseg = p.ctipseg'
	              || ' AND tp.ccolect = p.ccolect'
	              || ' AND tp.cidioma = pac_md_common.f_get_cxtidioma'
	              || ' AND pv.cprovin = s.cprovin'
	              || ' AND a1.cagente = cmediad'
	              || ' AND a2.cagente = ccolabo'
	              || ' AND((s.ctipmov IN(''A'', ''C'')'
	              || ' AND s.fefecto BETWEEN '
	              || v_finiefe
	              || ' AND '
	              || v_ffinefe
	              || ' )'
	              || ' OR(s.ctipmov = ''B'' AND s.fanulac BETWEEN '
	              || v_finiefe
	              || ' AND '
	              || v_ffinefe
	              || '))) det'
	              || ' GROUP BY det.compani, det.sproduc, det.ttitulo, det.cgarant, det.tgarant,'
	              || ' det.cmediad, det.tmediad, det.ccolabo, det.tcolabo, det.cpostal,'
	              || ' det.tprovin'
	              || ' ORDER BY det.compani, det.sproduc, det.cgarant, det.tprovin, det.cpostal,'
	              || ' det.cmediad, det.ccolabo';

	    v_ntraza:=1050;

	    v_ntraza:=9999;

	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list470_det;

	/* FIN Bug 0019844 - 24/10/2011 - JMC*/
	/* INI Bug 0020101 - 12/12/2011 - MDS*/
	FUNCTION f_list478_cab1(
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list478_cab1';
	  v_tparam  VARCHAR2(1000):=' idioma='
	                           || p_cidioma
	                           || ' cempres='
	                           || p_cempres
	                           || ' finiefe='
	                           || p_finiefe
	                           || ' ffinefe='
	                           || p_ffinefe;
	  v_ntraza  NUMBER:=0;
	  v_idioma  NUMBER;
	  verror    NUMBER;
	  v_sep     VARCHAR2(1):=',';
	BEGIN
	    v_ntraza:=1000;

	    v_ttexto:=f_axis_literales(9902907, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902908, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902909, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902910, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902911, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902912, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902913, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902914, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902915, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902916, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902917, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902918, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902919, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902920, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902921, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902922, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902923, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902924, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902925, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902926, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902927, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902928, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902929, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902930, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902931, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902932, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902933, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902934, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902935, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902936, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902937, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902938, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902939, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902940, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902941, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902942, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902943, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902944, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902945, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902946, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902947, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902948, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902949, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902950, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902951, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902952, p_cidioma);

	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN NULL;
	END f_list478_cab1;
	FUNCTION f_list478_cab2(
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list478_cab2';
	  v_tparam  VARCHAR2(1000):=' idioma='
	                           || p_cidioma
	                           || ' cempres='
	                           || p_cempres
	                           || ' finiefe='
	                           || p_finiefe
	                           || ' ffinefe='
	                           || p_ffinefe;
	  v_ntraza  NUMBER:=0;
	  v_idioma  NUMBER;
	  verror    NUMBER;
	  v_sep     VARCHAR2(1):=',';
	BEGIN
	    v_ntraza:=1000;

	    v_ttexto:='SELECT '
	              || ' f_axis_literales(9902907,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902908,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902909,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902910,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902911,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902912,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902913,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902914,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902915,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902916,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902917,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902918,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902919,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902920,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902921,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902922,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902923,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902924,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902925,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902926,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902927,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902928,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902929,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902930,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902931,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902932,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902933,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902934,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902935,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902936,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902937,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902953,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902954,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902955,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902956,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902957,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902958,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902959,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902960,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902961,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902962,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902963,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902964,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902948,'
	              || p_cidioma
	              || ')'
	              || ' from dual';

	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list478_cab2;
	FUNCTION f_list478_cab3(
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list478_cab3';
	  v_tparam  VARCHAR2(1000):=' idioma='
	                           || p_cidioma
	                           || ' cempres='
	                           || p_cempres
	                           || ' finiefe='
	                           || p_finiefe
	                           || ' ffinefe='
	                           || p_ffinefe;
	  v_ntraza  NUMBER:=0;
	  v_idioma  NUMBER;
	  verror    NUMBER;
	  v_sep     VARCHAR2(1):=',';
	BEGIN
	    v_ntraza:=1000;

	    v_ttexto:='SELECT '
	              || ' f_axis_literales(9902907,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902965,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902966,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902967,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902968,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902969,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902970,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902971,'
	              || p_cidioma
	              || ') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||'
	              || ' f_axis_literales(9902972,'
	              || p_cidioma
	              || ')'
	              || ' from dual';

	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list478_cab3;
	FUNCTION f_list478_det1(
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list478_det1';
	  v_tparam  VARCHAR2(1000):=' idioma='
	                           || p_cidioma
	                           || ' cempres='
	                           || p_cempres
	                           || ' finiefe='
	                           || p_finiefe
	                           || ' ffinefe='
	                           || p_ffinefe;
	  v_ntraza  NUMBER:=0;
	  v_finiefe VARCHAR2(100);
	  v_ffinefe VARCHAR2(100);
	  v_idioma  NUMBER;
	  verror    NUMBER;
	  v_sep     VARCHAR2(1):=',';
	  v_periodo VARCHAR2(100);
	  v_per     DATE;
	BEGIN
	    v_ntraza:=1000;

	    v_finiefe:=ltrim(to_char(p_finiefe, '09999999'));

	    v_finiefe:='to_date('
	               || chr(39)
	               || v_finiefe
	               || chr(39)
	               || ',''ddmmyyyy'')'; -- desde

	    v_ffinefe:=ltrim(to_char(p_ffinefe, '09999999'));

	    v_per:=to_date(v_ffinefe, 'ddmmyyyy');

	    v_periodo:=to_char(v_per, 'yyyymm');

	    v_ffinefe:='to_date('
	               || chr(39)
	               || v_ffinefe
	               || chr(39)
	               || ',''ddmmyyyy'')'; -- hasta

	    v_ntraza:=1005;

	    v_ttexto:='SELECT 1 ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(ramo),'' ''),3,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(producto),'' ''),6,'' '')   ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(nro_poliza),'' ''),8,'' '') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(nro_certificado),'' ''),7,'' '') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(nro_suplemento),'' ''),7,'' '')  ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(nro_recibo),'' ''),9,'' '')      ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(tipo_poliza),'' ''),1,'' '') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(tipoid),'' ''),1,'' '')     ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(nrodi),'' ''),13,'' '')     ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(compania),'' ''),1,'' '')   ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(fecha_expedicion),'' ''),8,'' '')  ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(fecha_inivigencia),'' ''),8,'' '') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(fecha_finvigencia),'' ''),8,'' '') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(fecha_inipoliza),'' ''),8,'' '')   ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(fecha_finpoliza),'' ''),8,'' '')   ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(sucursal),'' ''),3,'' '')          ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(valor_asegurado),'' ''),13,'' '')  ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(valor_aseg_acumulado),'' ''),13,'' '') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(valor_prima_neta),'' ''),11,'' '') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(valor_gastos_exp),'' ''),11,'' '') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(CASE WHEN((valor_prima_neta < 0 AND valor_iva > 0)'
	              || ' OR(valor_prima_neta > 0 AND valor_iva < 0)) THEN valor_iva *(-1) ELSE valor_iva END),'' ''),11,'' '')        ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR('
	              || v_periodo
	              || '),'' ''),6,'' '')  ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(SUBSTR(intermediario,-5)),'' ''),5,'' '')     ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(replace(TO_CHAR(particip_intermediario,''990D00''),'','',''.''),'' ''),7,'' '') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(replace(TO_CHAR(comision_intermediario,''990D00''),'','',''.''),'' ''),7,'' '') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(sucursal_lider),'' ''),3,'' '')          ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(replace(TO_CHAR(particip_sucursal_lider,''990D00''),'','',''.''),'' ''),7,'' '') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(tipo_coaseguro),'' ''),1,'' '')          ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(replace(TO_CHAR(percent_liberty,''990D00''),'','',''.''),'' ''),7,'' '')         ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(coaseguradora),'' ''),3,'' '')           ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(forma_pago),'' ''),1,'' '')   ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(contri_soat),'' ''),7,'' '')  ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(comision_liquidada),'' ''),11,'' '') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(tipo_expedicion),'' ''),1,'' '')     ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(nombre_inspector),'' ''),30,'' '')   ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(idtransaccion),'' ''),15,'' '')     ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(replace(nombre_tomador,'','','' '')),'' ''),40,'' '')    ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(replace(translate(direccion,''ÚÓ?É?úóíéá'',''UOIEAuoiea''),'','','' '')),'' ''),30,'' '')         ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(replace(ciudad,'','','' '')),'' ''),15,'' '')         ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(codtransaccion),'' ''),3,'' '') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(usuario),'' ''),10,'' '')        ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(fecha_emision),'' ''),14,'' '')  ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(indica_proteccion),'' ''),1,'' '') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(ind_reaseguro),'' ''),1,'' '')     ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(replace(TO_CHAR(reaseguro,''990D00''),'','',''.''),'' ''),7,'' '')'
	              || ' FROM ('
	              || ' SELECT P_EMPRESA, P_ANYMES, P_FMOVINI, P_FMOVFIN, P_CESTREC, P_CESTANT, P_SMOVREC, P_SSEGURO, P_NMOVIMI, P_FEMISIO, '
	              || ' P_SIGNO_IMPORTE, P_FECHA_CONTABILIZACION, RAMO, PRODUCTO, NRO_POLIZA, NRO_CERTIFICADO, NRO_SUPLEMENTO, NRO_RECIBO, TIPO_POLIZA, '
	              || ' TIPOID, NRODI, COMPANIA, FECHA_EXPEDICION, FECHA_INIVIGENCIA, FECHA_FINVIGENCIA, FECHA_INIPOLIZA, FECHA_FINPOLIZA, SUCURSAL, VALOR_ASEGURADO, '
	              || ' VALOR_ASEG_ACUMULADO, VALOR_PRIMA_NETA, VALOR_GASTOS_EXP, VALOR_IVA, PERIODO_CONTABLE, INTERMEDIARIO, PARTICIP_INTERMEDIARIO, (COMISION_INTERMEDIARIO + PORCONVOLEODUCTO) COMISION_INTERMEDIARIO, '
	              || ' SUCURSAL_LIDER, PARTICIP_SUCURSAL_LIDER, TIPO_COASEGURO, PERCENT_LIBERTY, COASEGURADORA, FORMA_PAGO, CONTRI_SOAT, (COMISION_LIQUIDADA + NVL(ICONVOLEODUCTO,0)) COMISION_LIQUIDADA, TIPO_EXPEDICION, '
	              || ' NOMBRE_INSPECTOR, IDTRANSACCION, NOMBRE_TOMADOR, DIRECCION, CIUDAD, CODTRANSACCION, USUARIO, FECHA_EMISION, INDICA_PROTECCION, IND_REASEGURO, REASEGURO '
	              || ' FROM v_detalle_produc_poliza_lcol v'
	              || ' WHERE p_empresa='
	              || p_cempres
	              || '  AND p_cestrec = 0 AND p_cestant = 0 '
	              || '  AND p_ctiprec not in (13,15) AND p_cestaux = 0 '
	              || '  AND TO_DATE(p_fecha_contabilizacion, ''yyyymmdd'') BETWEEN '
	              || v_finiefe
	              || '  AND '
	              || v_ffinefe
	              || '  UNION ALL '
	              || ' SELECT P_EMPRESA, P_ANYMES, P_FMOVINI, P_FMOVFIN, P_CESTREC, P_CESTANT, P_SMOVREC, P_SSEGURO, P_NMOVIMI, P_FEMISIO, '
	              || ' P_SIGNO_IMPORTE, P_FECHA_CONTABILIZACION, RAMO, PRODUCTO, NRO_POLIZA, NRO_CERTIFICADO, NRO_SUPLEMENTO, NRO_RECIBO, TIPO_POLIZA, '
	              || ' TIPOID, NRODI, COMPANIA, FECHA_EXPEDICION, FECHA_INIVIGENCIA, FECHA_FINVIGENCIA, FECHA_INIPOLIZA, FECHA_FINPOLIZA, SUCURSAL, VALOR_ASEGURADO, '
	              || ' VALOR_ASEG_ACUMULADO, (-1)*VALOR_PRIMA_NETA, (-1)*VALOR_GASTOS_EXP, (-1)*VALOR_IVA, PERIODO_CONTABLE, INTERMEDIARIO, PARTICIP_INTERMEDIARIO, (COMISION_INTERMEDIARIO + PORCONVOLEODUCTO) COMISION_INTERMEDIARIO, '
	              || ' SUCURSAL_LIDER, PARTICIP_SUCURSAL_LIDER, TIPO_COASEGURO, PERCENT_LIBERTY, COASEGURADORA, FORMA_PAGO, CONTRI_SOAT, (-1)*(COMISION_LIQUIDADA + NVL(ICONVOLEODUCTO,0)) COMISION_LIQUIDADA, TIPO_EXPEDICION, '
	              || ' NOMBRE_INSPECTOR, IDTRANSACCION, NOMBRE_TOMADOR, DIRECCION, CIUDAD, CODTRANSACCION, USUARIO, FECHA_EMISION, INDICA_PROTECCION, IND_REASEGURO, REASEGURO '
	              || ' FROM v_detalle_produc_poliza_lcol v'
	              || ' WHERE p_empresa='
	              || p_cempres
	              || '  AND p_cestrec = 2 AND p_ctiprec not in (13,15) '
	              || '  AND p_cestaux = 0 '
	              || '  AND TO_DATE(p_fecha_contabilizacion, ''yyyymmdd'') BETWEEN '
	              || v_finiefe
	              || '  AND '
	              || v_ffinefe
	              || ')  ORDER BY nro_poliza, nro_recibo';

	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list478_det1;
	FUNCTION f_list478_det2(
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list478_det2';
	  v_tparam  VARCHAR2(1000):=' idioma='
	                           || p_cidioma
	                           || ' cempres='
	                           || p_cempres
	                           || ' finiefe='
	                           || p_finiefe
	                           || ' ffinefe='
	                           || p_ffinefe;
	  v_ntraza  NUMBER:=0;
	  v_finiefe VARCHAR2(100);
	  v_ffinefe VARCHAR2(100);
	  v_idioma  NUMBER;
	  verror    NUMBER;
	  v_sep     VARCHAR2(1):=',';
	  v_periodo VARCHAR2(100);
	  v_per     DATE;
	BEGIN
	    v_ntraza:=1000;

	    v_finiefe:=ltrim(to_char(p_finiefe, '09999999'));

	    v_finiefe:='to_date('
	               || chr(39)
	               || v_finiefe
	               || chr(39)
	               || ',''ddmmyyyy'')'; -- desde

	    v_ffinefe:=ltrim(to_char(p_ffinefe, '09999999'));

	    v_per:=to_date(v_ffinefe, 'ddmmyyyy');

	    v_periodo:=to_char(v_per, 'yyyymm');

	    v_ffinefe:='to_date('
	               || chr(39)
	               || v_ffinefe
	               || chr(39)
	               || ',''ddmmyyyy'')'; -- hasta

	    v_ntraza:=1005;

	    v_ttexto:='SELECT 2 ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(ramo),'' ''),3,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(producto),'' ''),6,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(nro_poliza),'' ''),8,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(nro_certificado),'' ''),7,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(nro_suplemento),'' ''),7,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(nro_recibo),'' ''),9,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(tipo_poliza),'' ''),1,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(tipoid),'' ''),1,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(nrodi),'' ''),13,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(compania),'' ''),1,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(fecha_expedicion),'' ''),8,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(fecha_inivigencia),'' ''),8,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(fecha_finvigencia),'' ''),8,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(fecha_inipoliza),'' ''),8,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(fecha_finpoliza),'' ''),8,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(sucursal),'' ''),3,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(valor_asegurado),'' ''),13,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(valor_aseg_acumulado),'' ''),13,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(valor_prima_neta),'' ''),11,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(valor_gastos_exp),'' ''),11,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(CASE WHEN((valor_prima_neta < 0 AND valor_iva > 0)'
	              || ' OR(valor_prima_neta > 0 AND valor_iva < 0)) THEN valor_iva *(-1) ELSE valor_iva END),'' ''),11,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR('
	              || v_periodo
	              || '),'' ''),6,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(SUBSTR(intermediario,-5)),'' ''),5,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(replace(TO_CHAR(particip_intermediario,''990D00''),'','',''.''),'' ''),7,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(replace(TO_CHAR(comision_intermediario,''990D00''),'','',''.''),'' ''),7,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(sucursal_lider),'' ''),3,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(replace(TO_CHAR(particip_sucursal_lider,''990D00''),'','',''.''),'' ''),7,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(tipo_coaseguro),'' ''),1,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(replace(TO_CHAR(percent_liberty,''990D00''),'','',''.''),'' ''),7,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(coaseguradora),'' ''),3,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(forma_pago),'' ''),1,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(tipo_expedicion),'' ''),1,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(nombre_inspector),'' ''),30,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(idtransaccion),'' ''),15,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(codtransaccion),'' ''),3,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(sucursal_origen),'' ''),3,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(codgarantia),'' ''),5,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(replace(nomgarantia,'','','' '')),'' ''),50,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(indica_proteccion),'' ''),1,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(indica_asistencia),'' ''),1,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(fecha_contabilizacion),'' ''),8,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(valor_comision),'' ''),11,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| RPAD(NVL(TO_CHAR(usuario),'' ''),10,'' '')'
	              || ' FROM ('
	              || ' SELECT P_EMPRESA, P_ANYMES, P_IDIOMA, P_FMOVINI, P_FMOVFIN, P_CESTREC, P_CESTANT, P_SMOVREC, P_SSEGURO, P_FEMISIO, RAMO, PRODUCTO, '
	              || ' NRO_POLIZA, NRO_CERTIFICADO, NRO_SUPLEMENTO, NRO_RECIBO, TIPO_POLIZA, TIPOID, NRODI, COMPANIA, FECHA_EXPEDICION, FECHA_INIVIGENCIA, '
	              || ' FECHA_FINVIGENCIA, FECHA_INIPOLIZA, FECHA_FINPOLIZA, SUCURSAL, VALOR_ASEGURADO, VALOR_ASEG_ACUMULADO, VALOR_PRIMA_NETA, VALOR_GASTOS_EXP, '
	              || ' VALOR_IVA, PERIODO_CONTABLE, INTERMEDIARIO, PARTICIP_INTERMEDIARIO, (COMISION_INTERMEDIARIO + PORCONVOLEODUCTO + PORSOBRECOMISION) COMISION_INTERMEDIARIO, SUCURSAL_LIDER, PARTICIP_SUCURSAL_LIDER, TIPO_COASEGURO, '
	              || ' PERCENT_LIBERTY, COASEGURADORA, FORMA_PAGO, TIPO_EXPEDICION, NOMBRE_INSPECTOR, IDTRANSACCION, CODTRANSACCION, SUCURSAL_ORIGEN, CODGARANTIA, NOMGARANTIA, '
	              || ' INDICA_PROTECCION, INDICA_ASISTENCIA, FECHA_CONTABILIZACION, (VALOR_COMISION + NVL(ICONVOLEODUCTO,0)) VALOR_COMISION, USUARIO '
	              || ' FROM v_detalle_produc_garantia_lcol v '
	              || ' WHERE p_empresa='
	              || p_cempres
	              || '  AND p_idioma='
	              || p_cidioma
	              || '  AND p_cestrec = 0 AND p_cestant = 0 '
	              || '  AND TO_DATE(fecha_contabilizacion, ''yyyymmdd'') BETWEEN '
	              || v_finiefe
	              /* Ini Bug 26315 -- ECP -- 03/04/2013*/
	              || '  AND '
	              || v_ffinefe
	              || ' AND codgarantia <> 718 AND p_ctiprec not in (13,15) AND p_cestaux = 0  UNION ALL '
	              /* Fin Bug 26315 -- ECP -- 03/04/2013*/
	              || ' SELECT P_EMPRESA, P_ANYMES, P_IDIOMA, P_FMOVINI, P_FMOVFIN, P_CESTREC, P_CESTANT, P_SMOVREC, P_SSEGURO, P_FEMISIO, RAMO, PRODUCTO, '
	              || ' NRO_POLIZA, NRO_CERTIFICADO, NRO_SUPLEMENTO, NRO_RECIBO, TIPO_POLIZA, TIPOID, NRODI, COMPANIA, FECHA_EXPEDICION, FECHA_INIVIGENCIA, '
	              || ' FECHA_FINVIGENCIA, FECHA_INIPOLIZA, FECHA_FINPOLIZA, SUCURSAL, VALOR_ASEGURADO, VALOR_ASEG_ACUMULADO, (-1)*VALOR_PRIMA_NETA, (-1)*VALOR_GASTOS_EXP, '
	              || ' (-1)*VALOR_IVA, PERIODO_CONTABLE, INTERMEDIARIO, PARTICIP_INTERMEDIARIO, (COMISION_INTERMEDIARIO + PORCONVOLEODUCTO + PORSOBRECOMISION) COMISION_INTERMEDIARIO, SUCURSAL_LIDER, PARTICIP_SUCURSAL_LIDER, TIPO_COASEGURO, '
	              || ' PERCENT_LIBERTY, COASEGURADORA, FORMA_PAGO, TIPO_EXPEDICION, NOMBRE_INSPECTOR, IDTRANSACCION, CODTRANSACCION, SUCURSAL_ORIGEN, CODGARANTIA, NOMGARANTIA, '
	              || ' INDICA_PROTECCION, INDICA_ASISTENCIA, FECHA_CONTABILIZACION, (-1)*(VALOR_COMISION + NVL(ICONVOLEODUCTO,0)) VALOR_COMISION, USUARIO '
	              || ' FROM v_detalle_produc_garantia_lcol v '
	              || ' WHERE p_empresa='
	              || p_cempres
	              || '  AND p_idioma='
	              || p_cidioma
	              || '  AND p_cestrec = 2 '
	              || '  AND TO_DATE(fecha_contabilizacion, ''yyyymmdd'') BETWEEN '
	              || v_finiefe
	              /* Ini Bug 26315 -- ECP -- 03/04/2013*/
	              || '  AND '
	              || v_ffinefe
	              || ' AND codgarantia <> 718 AND p_ctiprec not in (13,15) AND p_cestaux = 0 '
	              /* Fin Bug 26315 -- ECP -- 03/04/2013*/
	              || ') ORDER BY nro_poliza, nro_recibo, codgarantia';

	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list478_det2;
	FUNCTION f_list478_det3(
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list478_det3';
	  v_tparam  VARCHAR2(1000):=' idioma='
	                           || p_cidioma
	                           || ' cempres='
	                           || p_cempres
	                           || ' finiefe='
	                           || p_finiefe
	                           || ' ffinefe='
	                           || p_ffinefe;
	  v_ndecima NUMBER:=0;
	  v_ntraza  NUMBER:=0;
	  v_finiefe VARCHAR2(100);
	  v_ffinefe VARCHAR2(100);
	  v_idioma  NUMBER;
	  verror    NUMBER;
	  v_sep     VARCHAR2(1):=',';
	BEGIN
	    /* obtener los decimales de la moneda*/
	    v_ntraza:=1000;

	    /*
	          SELECT ndecima
	            INTO v_ndecima
	            FROM monedas
	           WHERE cmoneda = f_parinstalacion_n('MONEDAINST')
	             AND cidioma = NVL(p_cidioma, pac_md_common.f_get_cxtidioma);
	    */
	    v_ntraza:=1005;

	    v_finiefe:=ltrim(to_char(p_finiefe, '09999999'));

	    v_finiefe:='to_date('
	               || chr(39)
	               || v_finiefe
	               || chr(39)
	               || ',''ddmmyyyy'')'; -- desde

	    v_ffinefe:=ltrim(to_char(p_ffinefe, '09999999'));

	    v_ffinefe:='to_date('
	               || chr(39)
	               || v_ffinefe
	               || chr(39)
	               || ',''ddmmyyyy'')'; -- hasta

	    v_ntraza:=1010;

	    v_ttexto:='SELECT 3 ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(SUM(v1.total_reg_tipo_1)),'' ''),13,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(SUM(v1.total_prima_neta_1)*POWER(10,'
	              || v_ndecima
	              || ')'
	              || '),'' ''),13,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(SUM(v1.total_gastos_exp_1)*POWER(10,'
	              || v_ndecima
	              || ')'
	              || '),'' ''),13,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(SUM(v1.total_iva_1)*POWER(10,'
	              || v_ndecima
	              || ')'
	              || '),'' ''),13,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(SUM(v1.total_reg_tipo_2)),'' ''),13,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(SUM(v1.total_prima_neta_2)*POWER(10,'
	              || v_ndecima
	              || ')'
	              || '),'' ''),13,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(SUM(v1.total_gastos_exp_2)*POWER(10,'
	              || v_ndecima
	              || ')'
	              || '),'' ''),13,'' '')       ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| LPAD(NVL(TO_CHAR(SUM(v1.total_iva_2)*POWER(10,'
	              || v_ndecima
	              || ')'
	              || '),'' ''),13,'' '')'
	              || ' FROM (SELECT COUNT(*) total_reg_tipo_1, sum(nvl(valor_prima_neta,0)) total_prima_neta_1, sum(nvl(valor_gastos_exp,0)) total_gastos_exp_1, sum(nvl(valor_iva,0)) total_iva_1,
	               0 total_reg_tipo_2, 0 total_prima_neta_2, 0 total_gastos_exp_2, 0 total_iva_2
	          FROM v_detalle_produc_poliza_lcol v
	         WHERE p_empresa='
	              || p_cempres
	              || ' AND p_cestrec = 0 AND p_cestant = 0 '
	              || ' AND p_ctiprec not in (13,15) AND p_cestaux = 0 '
	              || ' AND TO_DATE(p_fecha_contabilizacion, ''yyyymmdd'') BETWEEN '
	              || v_finiefe
	              || ' AND '
	              || v_ffinefe
	              || ' UNION ALL SELECT COUNT(*) total_reg_tipo_1, sum(nvl(valor_prima_neta,0)) total_prima_neta_1, sum(nvl(valor_gastos_exp,0)) total_gastos_exp_1, sum(nvl(valor_iva,0)) total_iva_1,
	               0 total_reg_tipo_2, 0 total_prima_neta_2, 0 total_gastos_exp_2, 0 total_iva_2
	          FROM (SELECT 1, (-1)*valor_prima_neta valor_prima_neta, (-1)*valor_gastos_exp valor_gastos_exp,
	                       valor_iva, p_empresa, p_cestrec, p_fecha_contabilizacion, p_ctiprec, p_cestaux, intermediario FROM v_detalle_produc_poliza_lcol) v
	         WHERE p_empresa='
	              || p_cempres
	              || ' AND p_cestrec = 2 AND p_ctiprec not in (13,15) AND p_cestaux = 0 '
	              || ' AND TO_DATE(p_fecha_contabilizacion, ''yyyymmdd'') BETWEEN '
	              || v_finiefe
	              || ' AND '
	              || v_ffinefe
	              || ' UNION ALL SELECT 0 total_reg_tipo_1, 0 total_prima_neta_1, 0 total_gastos_exp_1, 0 total_iva_1,
	               COUNT(*) total_reg_tipo_2, sum(nvl(valor_prima_neta,0)) total_prima_neta_2, sum(nvl(valor_gastos_exp,0)) total_gastos_exp_2, sum(nvl(valor_iva,0)) total_iva_2
	          FROM v_detalle_produc_garantia_lcol v
	         WHERE p_empresa='
	              || p_cempres
	              || ' AND p_idioma='
	              || p_cidioma
	              || ' AND p_cestrec = 0 AND p_cestant = 0 '
	              || ' AND TO_DATE(fecha_contabilizacion, ''yyyymmdd'') BETWEEN '
	              || v_finiefe
	              /* Ini Bug 26315 -- ECP -- 03/04/2013*/
	              || ' AND '
	              || v_ffinefe
	              || ' AND codgarantia <> 718 AND p_ctiprec not in (13,15) AND p_cestaux = 0 '
	              /* Fin Bug 26315 -- ECP -- 03/04/2013*/
	              || ' UNION ALL SELECT 0 total_reg_tipo_1, 0 total_prima_neta_1, 0 total_gastos_exp_1, 0 total_iva_1,
	               COUNT(*) total_reg_tipo_2, sum(nvl(valor_prima_neta,0)) total_prima_neta_2, sum(nvl(valor_gastos_exp,0)) total_gastos_exp_2, sum(nvl(valor_iva,0)) total_iva_2
	          FROM (SELECT 1, (-1)*valor_prima_neta valor_prima_neta, (-1)*valor_gastos_exp valor_gastos_exp,
	                       valor_iva, p_empresa, p_idioma, p_cestrec, fecha_contabilizacion, codgarantia, intermediario FROM v_detalle_produc_garantia_lcol WHERE p_ctiprec not in (13,15) AND p_cestaux = 0) v
	         WHERE p_empresa='
	              || p_cempres
	              || ' AND p_idioma='
	              || p_cidioma
	              || ' AND p_cestrec = 2 '
	              || ' AND TO_DATE(fecha_contabilizacion, ''yyyymmdd'') BETWEEN '
	              || v_finiefe
	              /* Ini Bug 26315 -- ECP -- 03/04/2013*/
	              || ' AND '
	              || v_ffinefe
	              || ' AND codgarantia <> 718 '
	              || ') v1';

	    /* Fin Bug 26315 -- ECP -- 03/04/2013*/
	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list478_det3;

	/* FIN Bug 0020101 - 12/12/2011 - MDS*/
	/* INI Bug 0020102 - 15/12/2011 - MDS*/
	FUNCTION f_list480_cab1(
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list480_cab1';
	  v_tparam  VARCHAR2(1000):=' idioma='
	                           || p_cidioma
	                           || ' cempres='
	                           || p_cempres
	                           || ' finiefe='
	                           || p_finiefe
	                           || ' ffinefe='
	                           || p_ffinefe;
	  v_ntraza  NUMBER:=0;
	  v_idioma  NUMBER;
	  verror    NUMBER;
	  v_sep     VARCHAR2(1):=',';
	BEGIN
	    v_ntraza:=1000;

	    v_ttexto:=f_axis_literales(9902908, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902909, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902910, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902911, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902912, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902913, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902917, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902933, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902926, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902929, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902930, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902931, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902932, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902943, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902959, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902960, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902961, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902962, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902981, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902982, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902983, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902984, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902985, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902986, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902987, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902988, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902989, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902990, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902991, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902992, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902993, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902994, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902995, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902996, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902997, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902998, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902999, p_cidioma)
	              || v_sep
	              || f_axis_literales(9903000, p_cidioma)
	              || v_sep
	              || f_axis_literales(9902948, p_cidioma);

	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN NULL;
	END f_list480_cab1;

	/* INI Bug 0020105 - 10/01/2012 - MDS*/
	FUNCTION f_list493_cab1(
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list493_cab1';
	  v_tparam  VARCHAR2(1000):=' idioma='
	                           || p_cidioma
	                           || ' cempres='
	                           || p_cempres
	                           || ' finiefe='
	                           || p_finiefe
	                           || ' ffinefe='
	                           || p_ffinefe;
	  v_ntraza  NUMBER:=0;
	  v_idioma  NUMBER;
	  verror    NUMBER;
	  v_sep     VARCHAR2(1):=';';
	BEGIN
	    v_ntraza:=1000;

	    v_ttexto:=f_axis_literales(9903074, p_cidioma)
	              || v_sep
	              || f_axis_literales(9903075, p_cidioma)
	              || v_sep
	              || f_axis_literales(9903076, p_cidioma)
	              || v_sep
	              || f_axis_literales(9903077, p_cidioma)
	              || v_sep
	              || f_axis_literales(9903078, p_cidioma);

	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN NULL;
	END f_list493_cab1;
	FUNCTION f_list493_det1(
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list493_det1';
	  v_tparam  VARCHAR2(1000):=' idioma='
	                           || p_cidioma
	                           || ' cempres='
	                           || p_cempres
	                           || ' finiefe='
	                           || p_finiefe
	                           || ' ffinefe='
	                           || p_ffinefe;
	  v_ntraza  NUMBER:=0;
	  v_finiefe VARCHAR2(100);
	  v_ffinefe VARCHAR2(100);
	  v_idioma  NUMBER;
	  verror    NUMBER;
	  v_sep     VARCHAR2(1):=';';
	BEGIN
	    v_ntraza:=1000;

	    v_finiefe:=ltrim(to_char(p_finiefe, '09999999'));

	    v_finiefe:='to_date('
	               || chr(39)
	               || v_finiefe
	               || chr(39)
	               || ',''ddmmyyyy'')'; -- desde

	    v_ffinefe:=ltrim(to_char(p_ffinefe, '09999999'));

	    v_ffinefe:='to_date('
	               || chr(39)
	               || v_ffinefe
	               || chr(39)
	               || ',''ddmmyyyy'')'; -- hasta

	    v_ntraza:=1005;

	    v_ttexto:='select concepto||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||a||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||b||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||c||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '||d '
	              || 'from (
	 SELECT 1 posicion,f_axis_literales(9903079,'
	              || p_cidioma
	              || ') concepto, pac_propio_lcol.f_numerovidas_aseguradas(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) a,
	       pac_propio_lcol.f_numerovidas_aseguradas(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) b,
	       pac_propio_lcol.f_numerovidas_aseguradas(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) c,
	       pac_propio_lcol.f_numerovidas_aseguradas(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) d
	  FROM DUAL UNION '
	              || 'SELECT 2 posicion,f_axis_literales(9903080,'
	              || p_cidioma
	              || ') concepto, pac_propio_lcol.f_numerovidas_aseguradas_mes(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) a,
	       pac_propio_lcol.f_numerovidas_aseguradas_mes(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) b,
	       pac_propio_lcol.f_numerovidas_aseguradas_mes(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) c,
	       pac_propio_lcol.f_numerovidas_aseguradas_mes(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) d
	  FROM DUAL UNION '
	              || 'SELECT 3 posicion,f_axis_literales(9903081,'
	              || p_cidioma
	              || ') concepto,
	         pac_propio_lcol.f_primasahorro_emitidas_mes(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL)
	       + pac_propio_lcol.f_primasriesgo_emitidas_mes(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) a,
	         pac_propio_lcol.f_primasahorro_emitidas_mes(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL)
	       + pac_propio_lcol.f_primasriesgo_emitidas_mes(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) b,
	         pac_propio_lcol.f_primasahorro_emitidas_mes(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL)
	       + pac_propio_lcol.f_primasriesgo_emitidas_mes(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) c,
	         pac_propio_lcol.f_primasahorro_emitidas_mes(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL)
	       + pac_propio_lcol.f_primasriesgo_emitidas_mes(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) d
	  FROM DUAL UNION '
	              || 'SELECT 4 posicion,f_axis_literales(9903082,'
	              || p_cidioma
	              || ') concepto, pac_propio_lcol.f_primasahorro_emitidas_mes(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) a,
	       pac_propio_lcol.f_primasahorro_emitidas_mes(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) b,
	       pac_propio_lcol.f_primasahorro_emitidas_mes(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) c,
	       pac_propio_lcol.f_primasahorro_emitidas_mes(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) d
	  FROM DUAL UNION '
	              || 'SELECT 5 posicion,f_axis_literales(9903083,'
	              || p_cidioma
	              || ') concepto, pac_propio_lcol.f_primasriesgo_emitidas_mes(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) a,
	       pac_propio_lcol.f_primasriesgo_emitidas_mes(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) b,
	       pac_propio_lcol.f_primasriesgo_emitidas_mes(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) c,
	       pac_propio_lcol.f_primasriesgo_emitidas_mes(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) d
	  FROM DUAL UNION '
	              || 'SELECT 6 posicion,f_axis_literales(9903084,'
	              || p_cidioma
	              || ') concepto,
	         pac_propio_lcol.f_primasahorro_renovadas_mes(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL)
	       + pac_propio_lcol.f_primasriesgo_renovadas_mes(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) a,
	         pac_propio_lcol.f_primasahorro_renovadas_mes(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL)
	       + pac_propio_lcol.f_primasriesgo_renovadas_mes(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) b,
	         pac_propio_lcol.f_primasahorro_renovadas_mes(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL)
	       + pac_propio_lcol.f_primasriesgo_renovadas_mes(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) c,
	         pac_propio_lcol.f_primasahorro_renovadas_mes(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL)
	       + pac_propio_lcol.f_primasriesgo_renovadas_mes(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) d
	  FROM DUAL UNION '
	              || 'SELECT 7 posicion,f_axis_literales(9903085,'
	              || p_cidioma
	              || ') concepto,
	       pac_propio_lcol.f_primasahorro_renovadas_mes(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) a,
	       pac_propio_lcol.f_primasahorro_renovadas_mes(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) b,
	       pac_propio_lcol.f_primasahorro_renovadas_mes(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) c,
	       pac_propio_lcol.f_primasahorro_renovadas_mes(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) d
	  FROM DUAL UNION '
	              || 'SELECT 8 posicion,f_axis_literales(9903086,'
	              || p_cidioma
	              || ') concepto,
	       pac_propio_lcol.f_primasriesgo_renovadas_mes(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) a,
	       pac_propio_lcol.f_primasriesgo_renovadas_mes(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) b,
	       pac_propio_lcol.f_primasriesgo_renovadas_mes(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) c,
	       pac_propio_lcol.f_primasriesgo_renovadas_mes(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) d
	  FROM DUAL UNION '
	              || 'SELECT 9 posicion,f_axis_literales(9903087,'
	              || p_cidioma
	              || ') concepto,
	       pac_propio_lcol.f_primas_emitidas_anyo(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) a,
	       pac_propio_lcol.f_primas_emitidas_anyo(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) b,
	       pac_propio_lcol.f_primas_emitidas_anyo(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) c,
	       pac_propio_lcol.f_primas_emitidas_anyo(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) d
	  FROM DUAL UNION '
	              || 'SELECT 10 posicion,f_axis_literales(9903088,'
	              || p_cidioma
	              || ') concepto,
	       pac_propio_lcol.f_valoraseg_vidas_aseg(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) a,
	       pac_propio_lcol.f_valoraseg_vidas_aseg(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) b,
	       pac_propio_lcol.f_valoraseg_vidas_aseg(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) c,
	       pac_propio_lcol.f_valoraseg_vidas_aseg(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) d
	  FROM DUAL UNION '
	              || 'SELECT 11 posicion,f_axis_literales(9903089,'
	              || p_cidioma
	              || ') concepto,
	       pac_propio_lcol.f_valoraseg_vidas_aseg_mes(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) a,
	       pac_propio_lcol.f_valoraseg_vidas_aseg_mes(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) b,
	       pac_propio_lcol.f_valoraseg_vidas_aseg_mes(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) c,
	       pac_propio_lcol.f_valoraseg_vidas_aseg_mes(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) d
	  FROM DUAL UNION '
	              || 'SELECT 12 posicion,f_axis_literales(9903090,'
	              || p_cidioma
	              || ') concepto,
	       pac_propio_lcol.f_numerosiniestros_mes(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) a,
	       pac_propio_lcol.f_numerosiniestros_mes(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) b,
	       pac_propio_lcol.f_numerosiniestros_mes(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) c,
	       pac_propio_lcol.f_numerosiniestros_mes(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) d
	  FROM DUAL UNION '
	              || 'SELECT 13 posicion,f_axis_literales(9903091,'
	              || p_cidioma
	              || ') concepto,
	       pac_propio_lcol.f_valorsiniestros_mes(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) a,
	       pac_propio_lcol.f_valorsiniestros_mes(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) b,
	       pac_propio_lcol.f_valorsiniestros_mes(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) c,
	       pac_propio_lcol.f_valorsiniestros_mes(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) d
	  FROM DUAL UNION '
	              || 'SELECT 20 posicion,f_axis_literales(9903092,'
	              || p_cidioma
	              || ') concepto,
	       pac_propio_lcol.f_numerovidas_aseguradas_mes(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6005) a,
	       pac_propio_lcol.f_numerovidas_aseguradas_mes(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6005) b,
	       pac_propio_lcol.f_numerovidas_aseguradas_mes(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6005) c,
	       pac_propio_lcol.f_numerovidas_aseguradas_mes(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6005) d
	  FROM DUAL UNION '
	              || 'SELECT 21 posicion,f_axis_literales(9903093,'
	              || p_cidioma
	              || ') concepto,
	       pac_propio_lcol.f_primasriesgo_emitidas_mes(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6005) a,
	       pac_propio_lcol.f_primasriesgo_emitidas_mes(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6005) b,
	       pac_propio_lcol.f_primasriesgo_emitidas_mes(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6005) c,
	       pac_propio_lcol.f_primasriesgo_emitidas_mes(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6005) d
	  FROM DUAL UNION '
	              || 'SELECT 22 posicion,f_axis_literales(9903094,'
	              || p_cidioma
	              || ') concepto,
	       pac_propio_lcol.f_primasahorro_emitidas_mes(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6005) a,
	       pac_propio_lcol.f_primasahorro_emitidas_mes(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6005) b,
	       pac_propio_lcol.f_primasahorro_emitidas_mes(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6005) c,
	       pac_propio_lcol.f_primasahorro_emitidas_mes(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6005) d
	  FROM DUAL UNION '
	              || 'SELECT 30 posicion,f_axis_literales(9903095,'
	              || p_cidioma
	              || ') concepto,
	       pac_propio_lcol.f_numerovidas_aseguradas_mes(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6009) +
	       pac_propio_lcol.f_numerovidas_aseguradas_mes(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6010) a,
	       pac_propio_lcol.f_numerovidas_aseguradas_mes(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6009) +
	       pac_propio_lcol.f_numerovidas_aseguradas_mes(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6010) b,
	       pac_propio_lcol.f_numerovidas_aseguradas_mes(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6009) +
	       pac_propio_lcol.f_numerovidas_aseguradas_mes(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6010) c,
	       pac_propio_lcol.f_numerovidas_aseguradas_mes(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6009) +
	       pac_propio_lcol.f_numerovidas_aseguradas_mes(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6010) d
	  FROM DUAL UNION '
	              || 'SELECT 31 posicion,f_axis_literales(9903096,'
	              || p_cidioma
	              || ') concepto,
	       pac_propio_lcol.f_primasriesgo_emitidas_mes(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6009) +
	       pac_propio_lcol.f_primasriesgo_emitidas_mes(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6010) a,
	       pac_propio_lcol.f_primasriesgo_emitidas_mes(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6009) +
	       pac_propio_lcol.f_primasriesgo_emitidas_mes(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6010) b,
	       pac_propio_lcol.f_primasriesgo_emitidas_mes(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6009) +
	       pac_propio_lcol.f_primasriesgo_emitidas_mes(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6010) c,
	       pac_propio_lcol.f_primasriesgo_emitidas_mes(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6009) +
	       pac_propio_lcol.f_primasriesgo_emitidas_mes(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6010) d
	  FROM DUAL UNION '
	              || 'SELECT 32 posicion,f_axis_literales(9903097,'
	              || p_cidioma
	              || ') concepto,
	       pac_propio_lcol.f_primasahorro_emitidas_mes(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6009) +
	       pac_propio_lcol.f_primasahorro_emitidas_mes(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6010) a,
	       pac_propio_lcol.f_primasahorro_emitidas_mes(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6009) +
	       pac_propio_lcol.f_primasahorro_emitidas_mes(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6010) b,
	       pac_propio_lcol.f_primasahorro_emitidas_mes(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6009) +
	       pac_propio_lcol.f_primasahorro_emitidas_mes(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6010) c,
	       pac_propio_lcol.f_primasahorro_emitidas_mes(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6009) +
	       pac_propio_lcol.f_primasahorro_emitidas_mes(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6010) d
	  FROM DUAL UNION '
	              || 'SELECT 40 posicion,f_axis_literales(9903098,'
	              || p_cidioma
	              || ') concepto,
	       pac_propio_lcol.f_numerovidas_aseguradas_mes(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6006) a,
	       pac_propio_lcol.f_numerovidas_aseguradas_mes(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6006) b,
	       pac_propio_lcol.f_numerovidas_aseguradas_mes(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6006) c,
	       pac_propio_lcol.f_numerovidas_aseguradas_mes(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6006) d
	  FROM DUAL UNION '
	              || 'SELECT 41 posicion,f_axis_literales(9903099,'
	              || p_cidioma
	              || ') concepto,
	       pac_propio_lcol.f_primasriesgo_emitidas_mes(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6006) a,
	       pac_propio_lcol.f_primasriesgo_emitidas_mes(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6006) b,
	       pac_propio_lcol.f_primasriesgo_emitidas_mes(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6006) c,
	       pac_propio_lcol.f_primasriesgo_emitidas_mes(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6006) d
	  FROM DUAL UNION '
	              || 'SELECT 42 posicion,f_axis_literales(9903100,'
	              || p_cidioma
	              || ') concepto,
	       pac_propio_lcol.f_primasahorro_emitidas_mes(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6006) a,
	       pac_propio_lcol.f_primasahorro_emitidas_mes(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6006) b,
	       pac_propio_lcol.f_primasahorro_emitidas_mes(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6006) c,
	       pac_propio_lcol.f_primasahorro_emitidas_mes(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6006) d
	  FROM DUAL UNION '
	              || 'SELECT 50 posicion,f_axis_literales(9903101,'
	              || p_cidioma
	              || ') concepto,
	       pac_propio_lcol.f_numerovidas_aseguradas_mes(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6007) a,
	       pac_propio_lcol.f_numerovidas_aseguradas_mes(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6007) b,
	       pac_propio_lcol.f_numerovidas_aseguradas_mes(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6007) c,
	       pac_propio_lcol.f_numerovidas_aseguradas_mes(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6007) d
	  FROM DUAL UNION '
	              || 'SELECT 51 posicion,f_axis_literales(9903102,'
	              || p_cidioma
	              || ') concepto,
	       pac_propio_lcol.f_primasriesgo_emitidas_mes(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6007) a,
	       pac_propio_lcol.f_primasriesgo_emitidas_mes(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6007) b,
	       pac_propio_lcol.f_primasriesgo_emitidas_mes(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6007) c,
	       pac_propio_lcol.f_primasriesgo_emitidas_mes(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6007) d
	  FROM DUAL UNION '
	              || 'SELECT 52 posicion,f_axis_literales(9903103,'
	              || p_cidioma
	              || ') concepto,
	       pac_propio_lcol.f_primasahorro_emitidas_mes(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6007) a,
	       pac_propio_lcol.f_primasahorro_emitidas_mes(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6007) b,
	       pac_propio_lcol.f_primasahorro_emitidas_mes(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6007) c,
	       pac_propio_lcol.f_primasahorro_emitidas_mes(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', 6007) d
	  FROM DUAL UNION '
	              || 'SELECT 60 posicion,f_axis_literales(9903104,'
	              || p_cidioma
	              || ') concepto,
	       pac_propio_lcol.f_numsinis_muertenatural(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) a,
	       pac_propio_lcol.f_numsinis_muertenatural(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) b,
	       pac_propio_lcol.f_numsinis_muertenatural(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) c,
	       pac_propio_lcol.f_numsinis_muertenatural(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) d
	  FROM DUAL UNION '
	              || 'SELECT 70 posicion,f_axis_literales(9903105,'
	              || p_cidioma
	              || ') concepto,
	       pac_propio_lcol.f_numsinis_invalidezenfermedad(''1A'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) a,
	       pac_propio_lcol.f_numsinis_invalidezenfermedad(''1B'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) b,
	       pac_propio_lcol.f_numsinis_invalidezenfermedad(''1C'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) c,
	       pac_propio_lcol.f_numsinis_invalidezenfermedad(''1D'', '
	              || p_cempres
	              || ', '
	              || v_finiefe
	              || ', '
	              || v_ffinefe
	              || ', NULL) d
	  FROM DUAL
	)
	order by posicion';

	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list493_det1;

	/* FIN Bug 0020105 - 10/01/2012 - MDS*/
	/* INI Bug 0020106 - 10/01/2012 - MDS*/
	FUNCTION f_list494_cab1(
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list494_cab1';
	  v_tparam  VARCHAR2(1000):=' idioma='
	                           || p_cidioma
	                           || ' cempres='
	                           || p_cempres
	                           || ' finiefe='
	                           || p_finiefe
	                           || ' ffinefe='
	                           || p_ffinefe;
	  v_ntraza  NUMBER:=0;
	  v_idioma  NUMBER;
	  verror    NUMBER;
	  v_sep     VARCHAR2(2):='||';
	BEGIN
	    v_ntraza:=1000;

	    v_ttexto:=' ';

	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN NULL;
	END f_list494_cab1;
	FUNCTION f_list494_det1(
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_finiefe	IN	NUMBER DEFAULT NULL,
			p_ffinefe	IN	NUMBER DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list494_det1';
	  v_tparam  VARCHAR2(1000):=' idioma='
	                           || p_cidioma
	                           || ' cempres='
	                           || p_cempres
	                           || ' finiefe='
	                           || p_finiefe
	                           || ' ffinefe='
	                           || p_ffinefe;
	  v_ntraza  NUMBER:=0;
	  v_finiefe VARCHAR2(100);
	  v_ffinefe VARCHAR2(100);
	  v_idioma  NUMBER;
	  verror    NUMBER;
	  v_sep     VARCHAR2(2):='||';
	BEGIN
	    v_ntraza:=1000;

	    v_finiefe:=ltrim(to_char(p_finiefe, '09999999'));

	    v_finiefe:='to_date('
	               || chr(39)
	               || v_finiefe
	               || chr(39)
	               || ',''ddmmyyyy'')'; -- desde

	    v_ffinefe:=ltrim(to_char(p_ffinefe, '09999999'));

	    v_ffinefe:='to_date('
	               || chr(39)
	               || v_ffinefe
	               || chr(39)
	               || ',''ddmmyyyy'')'; -- hasta

	    v_ntraza:=1005;

	    v_ttexto:=' SELECT 1418 ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || DECODE(c.ctipide, 36, 1, 37, 2, 39, 2, 33, 3, 34, 4, 5) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || RPAD(c.nnumide,20) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || DECODE(c.cramo, 101, 33, 30) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || TO_CHAR(c.fnotifi, ''DDMMYYYY'') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || TO_CHAR(c.fsinies, ''DDMMYYYY'') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || TO_CHAR(c.fefepag, ''DDMMYYYY'') ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || RPAD(TRUNC(c.isinretpag_tot),15) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || RPAD(c.cestsin,10)               ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || RPAD((SELECT UPPER(tatribu)
	          FROM detvalores
	         WHERE cvalor = 6
	           AND cidioma = '
	              || p_cidioma
	              || '     AND catribu = c.cestsin),15) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || RPAD(c.cgarant,10)          ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || RPAD(UPPER(c.tgarant),50)   ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || ' || RPAD(TRUNC(c.icaprie),20) '
	              || ' FROM (SELECT   b.nsinies, b.cramo, b.cestsin, b.icaprie, b.cgarant, gg.tgarant, b.ctipide,
	                 b.nnumide, b.fnotifi, b.fsinies, SUM(pag.isinretpag) AS isinretpag_tot,
	                 MAX(pag.fefepag) AS fefepag
	            FROM (SELECT   a.nsinies, a.cramo, a.cestsin, SUM(a.icaprie) AS icaprie,
	                           MAX(a.cgarant) AS cgarant, a.ctipide, a.nnumide, a.fnotifi,
	                           a.fsinies
	                      FROM (SELECT s.nsinies, seg.cramo, movs.cestsin, str.ntramit,
	                                   str.ctipres, str.nmovres,
	                                   pac_eco_tipocambio.f_importe_cambio
	                                      (pac_monedas.f_cmoneda_t
	                                          (pac_monedas.f_moneda_divisa
	                                                                 ((SELECT pr.cdivisa
	                                                                     FROM productos pr
	                                                                    WHERE pr.sproduc =
	                                                                             seg.sproduc))),
	                                       pac_monedas.f_cmoneda_t(seg.cmoneda),
	                                       pac_eco_tipocambio.f_fecha_max_cambio
	                                          (pac_monedas.f_cmoneda_t
	                                              (pac_monedas.f_moneda_divisa
	                                                                 ((SELECT pr.cdivisa
	                                                                     FROM productos pr
	                                                                    WHERE pr.sproduc =
	                                                                             seg.sproduc))),
	                                           pac_monedas.f_cmoneda_t(seg.cmoneda),
	                                           str.fmovres),
	                                       str.icaprie, 1) icaprie,
	                                   str.cgarant, pp.ctipide, pp.nnumide, s.fnotifi, s.fsinies
	                              FROM seguros seg, sin_siniestro s, asegurados aseg,
	                                   per_personas pp, sin_tramita_reserva str,
	                                   sin_movsiniestro movs, agentes_agente_pol ap
	                             WHERE seg.cempres = '
	              || p_cempres
	              || ' AND seg.cramo = 101 AND seg.CEMPRES = ap.CEMPRES AND seg.cagente = ap.cagente
	                               AND s.sseguro = seg.sseguro
	                               AND s.falta BETWEEN '
	              || v_finiefe
	              || ' AND '
	              || v_ffinefe
	              || ' AND aseg.sseguro = s.sseguro
	                               AND aseg.nriesgo = s.nriesgo
	                               AND pp.sperson = aseg.sperson
	                               AND movs.nsinies = s.nsinies
	                               AND movs.nmovsin =
	                                     (SELECT MAX(movs2.nmovsin)
	                                        FROM sin_movsiniestro movs2
	                                       WHERE movs2.nsinies = movs.nsinies
	                                         AND movs2.falta BETWEEN '
	              || v_finiefe
	              || ' AND '
	              || v_ffinefe
	              || ')'
	              || ' AND str.nsinies = s.nsinies
	                               AND str.fmovres BETWEEN '
	              || v_finiefe
	              || ' AND '
	              || v_ffinefe
	              || ' AND(str.nsinies, str.ntramit, str.ctipres, str.nmovres) IN(
	                                     SELECT   str2.nsinies, str2.ntramit, str2.ctipres,
	                                              MAX(str2.nmovres)
	                                         FROM sin_tramita_reserva str2
	                                        WHERE str2.nsinies = str.nsinies
	                                     GROUP BY str2.nsinies, str2.ntramit, str2.ctipres)) a
	                  GROUP BY a.nsinies, a.cramo, a.cestsin, a.ctipide, a.nnumide, a.fnotifi,
	                           a.fsinies) b,
	                 (SELECT stp.nsinies, stp.isinretpag, stmp.fefepag
	                    FROM sin_tramita_pago stp, sin_tramita_movpago stmp
	                   WHERE stmp.sidepag = stp.sidepag
	                     AND stmp.cestpag = 2
	                     AND stmp.nmovpag = (SELECT   MAX(stmp2.nmovpag)
	                                             FROM sin_tramita_movpago stmp2
	                                            WHERE stmp2.sidepag = stmp.sidepag
	                                              AND stmp2.cestpag = 2
	                                              AND stmp2.falta BETWEEN '
	              || v_finiefe
	              || ' AND '
	              || v_ffinefe
	              || '  GROUP BY stmp2.sidepag)) pag,
	                 garangen gg
	           WHERE pag.nsinies(+) = b.nsinies
	             AND gg.cgarant(+) = b.cgarant
	             AND gg.cidioma(+) = '
	              || p_cidioma
	              || ' GROUP BY b.nsinies, b.cramo, b.cestsin, b.icaprie, b.cgarant, gg.tgarant, b.ctipide,
	                 b.nnumide, b.fnotifi, b.fsinies) c';

	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list494_det1;

	/* FIN Bug 0020106 - 10/01/2012 - MDS*/
	/* INI Bug 20107  - 07/02/2012 - ETM*/
	FUNCTION f_list509_cab(
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_mes	IN	NUMBER DEFAULT NULL,
			p_ano	IN	NUMBER DEFAULT NULL
	) RETURN CLOB
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list509_cab';
	  v_tparam  VARCHAR2(1000):=' idioma='
	                           || p_cidioma
	                           || ' cempres='
	                           || p_cempres
	                           || ' mes='
	                           || p_mes
	                           || ' año='
	                           || p_ano;
	  v_ntraza  NUMBER:=0;
	  v_idioma  NUMBER;
	  verror    NUMBER;
	  v_sep     VARCHAR2(1):=';';
	BEGIN
	    v_ntraza:=1000;

	    v_ttexto:=NULL;

	    /*   IF p_cidioma IS NULL THEN
	          SELECT MAX(nvalpar)
	            INTO v_idioma
	            FROM parinstalacion
	           WHERE cparame = 'IDIOMARTF';
	       ELSE
	          v_idioma := p_cidioma;
	       END IF;*/--  v_ttexto := f_axis_literales(xxxxx, v_idioma) || v_sep
	    v_ttexto:='Código de la Compañía'
	              || v_sep
	              || 'Código Producto'
	              || v_sep
	              || 'Nombre Producto'
	              || v_sep
	              || 'Código Plan'
	              || v_sep
	              || 'Nombre Plan'
	              || v_sep
	              || 'Estado Plan'
	              || v_sep
	              || 'Identificación Única de la Póliza'
	              || v_sep
	              || 'Sucursal'
	              || v_sep
	              || 'Póliza Número'
	              || v_sep
	              || 'Moneda'
	              || v_sep
	              || 'Equivalencia'
	              || v_sep
	              || 'Clase de Seguro'
	              || v_sep
	              || 'Tabla de Mortalidad'
	              || v_sep
	              || 'Estado'
	              || v_sep
	              || 'Fecha Expedición Inicial'
	              || v_sep
	              || 'Fecha Inicio Vigencia Última Renovación'
	              || v_sep
	              || 'Cobertura Hasta'
	              || v_sep
	              || 'Altura Año'
	              || v_sep
	              || 'Altura Mes'
	              || v_sep
	              || 'Interés Técnico Prima Amparo Básico'
	              || v_sep
	              || 'Interés Técnico Reserva Amparo Básico'
	              || v_sep
	              || 'Factor de Reducción'
	              || v_sep
	              || 'Tiempo de Reducción'
	              || v_sep
	              || 'Tipo de Prima'
	              || v_sep
	              || 'Periodicidad de Pago de Prima'
	              || v_sep
	              || 'Pago de Prima Hasta'
	              || v_sep
	              || 'Tipo de identificación Asegurado Principal'
	              || v_sep
	              || 'Número de Identificación Asegurado Principal'
	              || v_sep
	              || 'Sexo Asegurado Principal'
	              || v_sep
	              || 'Fecha de nacimiento del Asegurado Principal'
	              || v_sep
	              || 'Edad ingreso Asegurado Principal'
	              || v_sep
	              || 'Tipo de Crecimiento del Valor Asegurado del Amparo Básico (Muerte)'
	              || v_sep
	              || '% Crecimiento del Valor Asegurado del Amparo Básico (Muerte)'
	              || v_sep
	              || 'Periodicidad de Crecimiento del Valor Asegurado del Amparo Básico (Muerte)'
	              || v_sep
	              || 'Crecimiento Hasta (Básico - Muerte)'
	              || v_sep
	              || 'Gastos sobre el Valor Asegurado Primer Año'
	              || v_sep
	              || 'Gastos sobre el Valor Asegurado Segundo Año'
	              || v_sep
	              || 'Gastos sobre el Valor Asegurado Tercer Año y Siguientes'
	              || v_sep
	              || 'Gastos Sobre la Prima Primer Año'
	              || v_sep
	              || 'Gastos Sobre la Prima Segundo Año'
	              || v_sep
	              || 'Gastos Sobre la Prima Tercer Año y Siguientes'
	              || v_sep
	              || 'Valor Asegurado Inicial (Básico- Muerte)'
	              || v_sep
	              || 'Valor Asegurado Alcanzado (Básico -I Muerte)'
	              || v_sep
	              || 'Prima de Riesgo (Básico-Muerte)'
	              || v_sep
	              || 'Valor Reserva (Básico-Muerte)'
	              || v_sep
	              || 'Tipo de Crecimiento (Sobrevivencia)'
	              || v_sep;

	    v_ttexto:=v_ttexto
	              || '% Crecimiento (Sobrevivencia)'
	              || v_sep
	              || 'Periodicidad de Crecimiento (Sobrevivencia)'
	              || v_sep
	              || 'Crecimiento Hasta (Sobrevivencia)'
	              || v_sep
	              || 'Interés Técnico Prima (Sobrevivencia)'
	              || v_sep
	              || 'Interés Técnico Reserva (Sobrevivencia)'
	              || v_sep
	              || 'Fecha Inicio Vigencia (Sobrevivencia)'
	              || v_sep
	              || 'Cobertura Hasta (Sobrevivencia)'
	              || v_sep
	              || 'Edad Dote'
	              || v_sep
	              || 'Gastos sobre el Valor Asegurado Primer Año (Sobrevivencia)'
	              || v_sep
	              || 'Gastos sobre el Valor Asegurado Segundo Año (Sobrevivencia)'
	              || v_sep
	              || 'Gastos sobre el Valor Asegurado Tercer Año y Siguientes (Sobrevivencia)'
	              || v_sep
	              || 'Gastos Sobre la Prima Primer Año (Sobrevivencia)'
	              || v_sep
	              || 'Gastos Sobre la Prima Segundo Año (Sobrevivencia)'
	              || v_sep
	              || 'Gastos Sobre la Prima Tercer Año y Siguientes (Sobrevivencia)'
	              || v_sep
	              || 'Valor Asegurado Inicial (Sobrevivencia)'
	              || v_sep
	              || 'Valor Asegurado Alcanzado (Sobrevivencia)'
	              || v_sep
	              || 'Prima de Riesgo (Sobrevivencia)'
	              || v_sep
	              || 'Valor Reserva (Sobrevivencia)'
	              || v_sep
	              || 'Código Cobertura (Prorrogado - Saldado)'
	              || v_sep
	              || 'Tipo de Crecimiento (Prorrogado - Saldado)'
	              || v_sep
	              || '% Crecimiento (Prorrogado - Saldado)'
	              || v_sep
	              || 'Periodicidad de Crecimiento (Prorrogado - Saldado)'
	              || v_sep;

	    v_ttexto:=v_ttexto
	              || 'Crecimiento Hasta (Prorrogado - Saldado)'
	              || v_sep
	              || 'Interés Técnico Prima (Prorrogado - Saldado)'
	              || v_sep
	              || 'Interés Técnico Reserva (Prorrogado - Saldado)'
	              || v_sep
	              || 'Fecha Inicio Vigencia (Prorrogado - Saldado)'
	              || v_sep
	              || 'Cobertura Hasta (Prorrogado - Saldado)'
	              || v_sep
	              || 'Edad Inicial Prorrogado - Saldado)'
	              || v_sep
	              || 'Gastos sobre el Valor Asegurado Primer Año (Prorrogado - Saldado)'
	              || v_sep
	              || 'Gastos sobre el Valor Asegurado Segundo Año (Prorrogado - Saldado)'
	              || v_sep
	              || 'Gastos sobre el Valor Asegurado Tercer Año y Siguientes (Prorrogado - Saldado)'
	              || v_sep
	              || 'Gastos Sobre fa Prima Primer Año (Prorrogado - Saldado)'
	              || v_sep
	              || 'Gastos Sobre la Prima Segundo Año (Prorrogado - Saldado)'
	              || v_sep
	              || 'Gastos Sobre la Prima Tercer Año y Siguientes (Prorrogado - Saldado)'
	              || v_sep
	              || 'Valor Asegurado Inicial (Prorrogado - Saldado)'
	              || v_sep
	              || 'Valor Asegurado Alcanzado (Prorrogado - Saldado)'
	              || v_sep
	              || 'Prima Única (Prorrogado - Saldado)'
	              || v_sep
	              || 'Valor Reserva (Prorrogado - Saldado)'
	              || v_sep
	              || 'Código Cobertura'
	              || v_sep
	              || 'Tipo de identificación (Segundo Asegurado)'
	              || v_sep
	              || 'Número de Identificación (Segundo Asegurado)'
	              || v_sep
	              || 'Sexo (Segundo Asegurado)'
	              || v_sep
	              || 'Fecha de Nacimiento (Segundo Asegurado)'
	              || v_sep
	              || 'Tipo de Crecimiento (Segundo Asegurado)'
	              || v_sep
	              || '% Crecimiento (Segundo Asegurado)'
	              || v_sep
	              || 'Periodicidad de Crecimiento (Segundo Asegurado)'
	              || v_sep;

	    v_ttexto:=v_ttexto
	              || 'Crecimiento Hasta (Segundo Asegurado)'
	              || v_sep
	              || 'Interés Técnico Prima (Segundo Asegurado)'
	              || v_sep
	              || 'Interés Técnico Reserva (Segundo Asegurado)'
	              || v_sep
	              || 'Fecha Inicio Vigencia (Segundo Asegurado)'
	              || v_sep
	              || 'Cobertura Hasta (Segundo Asegurado)'
	              || v_sep
	              || 'Edad Inicial (Segundo Asegurado)'
	              || v_sep
	              || 'Gastos sobre el Valor Asegurado Primer Año (Segundo Asegurado)'
	              || v_sep
	              || 'Gastos sobre el Valor Asegurado Segundo Año (Segundo Asegurado)'
	              || v_sep
	              || 'Gastos sobre el Valor Asegurado Tercer Año y Siguientes (Segundo Asegurado)'
	              || v_sep
	              || 'Gastos Sobre la Prima Primer Año (Segundo Asegurado)'
	              || v_sep
	              || 'Gastos Sobre la Prima Segundo Año (Segundo Asegurado)'
	              || v_sep
	              || 'Gastos Sobre la Prima Tercer Año y Siguientes (Segundo Asegurado)'
	              || v_sep
	              || 'Valor Asegurado Inicial (Segundo Asegurado)'
	              || v_sep
	              || 'Valor Asegurado Alcanzado (Segundo Asegurado)'
	              || v_sep
	              || 'Prima de Riesgo (Segundo Asegurado)'
	              || v_sep
	              || 'Valor Reserva Matemática (Segundo Asegurado)'
	              || v_sep
	              || 'Código Cobertura (Cobertura Adicional)'
	              || v_sep
	              || 'Tipo de Crecimiento (Cobertura Adicional)'
	              || v_sep
	              || '% Crecimiento (Cobertura Adicional)'
	              || v_sep
	              || 'Periodicidad de Crecimiento (Cobertura Adicional)'
	              || v_sep;

	    v_ttexto:=v_ttexto
	              || 'Crecimiento Hasta (Cobertura Adicional)'
	              || v_sep
	              || 'Interés Técnico Prima (Cobertura Adicional)'
	              || v_sep
	              || 'Interés Técnico Reserva (Cobertura Adicional)'
	              || v_sep
	              || 'Fecha Inicio Vigencia (Cobertura Adicional)'
	              || v_sep
	              || 'Cobertura Hasta (Cobertura Adicional)'
	              || v_sep
	              || 'Edad Inicial (Cobertura Adicional)'
	              || v_sep
	              || 'Gastos sobre el Valor Asegurado Primer Año (Cobertura Adicional)'
	              || v_sep
	              || 'Gastos sobre el Valor Asegurado Segundo Año (Cobertura Adicional)'
	              || v_sep
	              || 'Gastos sobre el Valor Asegurado Tercer .Año y Siguientes (Cobertura Adicional)'
	              || v_sep
	              || 'Gastos Sobre la Prima Primer Año (Cobertura Adicional)'
	              || v_sep
	              || 'Gastos Sobre la Prima Segundo Año (Cobertura Adicional)'
	              || v_sep
	              || 'Gastos Sobre la Prima Tercer Año y Siguientes (Cobertura Adicional)'
	              || v_sep
	              || 'Valor Asegurado lnicial (Cobertura Adicional)'
	              || v_sep
	              || 'Valor Asegurado Alcanzado (Cobertura Adicional)'
	              || v_sep
	              || 'Prima de Riesgo (Cobertura Adicional)'
	              || v_sep
	              || 'Valor Reserva (Cobertura Adicional)'
	              || v_sep
	              || 'Valor Reserva (Demás Coberturas Adicionales)'
	              || v_sep
	              || 'Valor Reserva Participación de Utilidades'
	              || v_sep
	              || 'Reserva Ahorro'
	              || v_sep
	              || 'Reserva Total'
	              || v_sep
	              || 'Reserva Total Pesos'
	              || v_sep
	              || 'Observaciones';

	    RETURN to_clob(v_ttexto);
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN NULL;
	END f_list509_cab;
	FUNCTION f_list509_det(
			p_cidioma	IN	NUMBER DEFAULT NULL,
			p_cempres	IN	NUMBER DEFAULT NULL,
			p_mes	IN	NUMBER DEFAULT NULL,
			p_ano	IN	NUMBER DEFAULT NULL
	) RETURN CLOB
	IS
	  v_tobjeto   VARCHAR2(100):='PAC_INFORMES.f_list509_det';
	  v_tparam    VARCHAR2(1000):=' idioma='
	                           || p_cidioma
	                           || ' cempres='
	                           || p_cempres
	                           || ' p_mes ='
	                           || p_mes
	                           || '  p_ano='
	                           || ' p_ano';
	  v_ntraza    NUMBER:=0;
	  v_finiefe   VARCHAR2(100);
	  v_ffinefe   VARCHAR2(100);
	  v_idioma    NUMBER;
	  verror      NUMBER;
	  v_sep       VARCHAR2(2):=';';
	  v_comilllas VARCHAR2(2):='"';
	BEGIN
	    v_ntraza:=1000;

	    /* BUG 25024/140487 - JLTS - 15/03/2013 - Se modifica la consulta por rendimiento*/
	    /* BUG 27076/146754 - JLTS - 27/06/2013 - Se modifica la consulta adicionando dos campos nulos para*/
	    /*        los enbabezados Factor de Reducción y Tiempo de Reducción y se elimina el último campo de las SELECT*/
	    /*        ff_desgarantia(q11.gar_adicional, ' || p_cidioma || ')*/
	    v_ttexto:='SELECT q11.c1 ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.sproduc ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.c2 ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.sproduc ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.c2 ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.c3 ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.cramo ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.c4 ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.npoliza ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.c5 ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.c6 ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.c7 ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.c8 ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.c9 ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.c10 ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.c11 ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              /*BUG 29952/169039 - 17/03/2014 - RCL*/
	              || '|| DECODE(q11.fvencim, NULL, TO_CHAR(q11.fcaranu, ''dd/mm/yyyy''), TO_CHAR(q11.fvencim - 1, ''dd/mm/yyyy'')) ||' --BUG 29952/167822 - 27/02/2014 - RCL
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.c13 ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.c14 ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.c15 ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.c15 ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.c16 ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.c17 ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.c18 ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.c19 ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.nnumide ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.csexper ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.c20 ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.c21 ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.c22a ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.c23||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.c22b ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.c24 ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.saldo_prorrogado,
	              1, NULL,
	              2, NULL,
	              pac_superfinan.ff_gastos_adquis(q11.sseguro, q11.nriesgo, q11.garantia_basica,
	                                              q11.fefecto)) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.saldo_prorrogado,
	              1, NULL,
	              2, NULL,
	              pac_superfinan.ff_gastos_adquis(q11.sseguro, q11.nriesgo, q11.garantia_basica,
	                                              ADD_MONTHS(q11.fefecto, 12))) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.saldo_prorrogado,
	              1, NULL,
	              2, NULL,
	              pac_superfinan.ff_gastos_adquis(q11.sseguro, q11.nriesgo, q11.garantia_basica,
	                                              ADD_MONTHS(q11.fefecto, 24))) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.saldo_prorrogado,
	              1, NULL,
	              2, NULL,
	              pac_superfinan.ff_gastos_admin_tot(q11.sseguro, q11.nriesgo, q11.garantia_basica,
	                                                 q11.fefecto)) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.saldo_prorrogado,
	              1, NULL,
	              2, NULL,
	              pac_superfinan.ff_gastos_admin_tot(q11.sseguro, q11.nriesgo, q11.garantia_basica,
	                                                 ADD_MONTHS(q11.fefecto, 12))) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.saldo_prorrogado,
	              1, NULL,
	              2, NULL,
	              pac_superfinan.ff_gastos_admin_tot(q11.sseguro, q11.nriesgo, q11.garantia_basica,
	                                                 ADD_MONTHS(q11.fefecto, 24))) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.saldo_prorrogado,
	              1, NULL,
	              2, NULL,
	              (SELECT SUM(pv.icapgar)
	                 FROM provmat pv
	                WHERE pv.sseguro = q11.sseguro
	                  AND pv.nriesgo = q11.nriesgo
	                  AND pv.cgarant = q11.garantia_basica
	                  AND fcalcul = q11.fechacorte)) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.saldo_prorrogado,
	              1, NULL,
	              2, NULL,
	              (SELECT SUM(pv.ivalact)
	                 FROM provmat pv
	                WHERE pv.sseguro = q11.sseguro
	                  AND pv.nriesgo = q11.nriesgo
	                  AND pv.cgarant = q11.garantia_basica
	                  AND fcalcul = q11.fechacorte)) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.saldo_prorrogado,
	              1, NULL,
	              2, NULL,
	              pac_superfinan.ff_prima_riesgo_basico(q11.sseguro, q11.nriesgo, q11.fechacorte))  ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.saldo_prorrogado,
	              1, NULL,
	              2, NULL,
	              (SELECT SUM(pv.ipromat)
	                 FROM provmat pv
	                WHERE pv.sseguro = q11.sseguro
	                  AND pv.cgarant = q11.garantia_basica
	                  AND pv.nriesgo = q11.nriesgo
	                  AND fcalcul = q11.fechacorte)) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| pac_superfinan.ff_codigo_cobertura(q11.sproduc) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.saldo_prorrogado, 1, 9, 2, 9, NULL) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.saldo_prorrogado, 1, 0, 2, 0, NULL) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.saldo_prorrogado, 1, 1, 2, 1, NULL) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.saldo_prorrogado,
	              1, NULL,
	              2, NULL,
	              TO_CHAR(pac_superfinan.ff_fecha_crecimiento(q11.sseguro, q11.nriesgo,
	                                                          q11.fcalcul, 6901, 2),
	                      ''DD/MM/RRRR'')) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.saldo_prorrogado, 1, q11.c15a, 2, q11.c15a, NULL) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.saldo_prorrogado, 1, q11.c15a, 2, q11.c15a, NULL) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.saldo_prorrogado,
	              1, TO_CHAR(q11.fefecto, ''DD/MM/RRRR''),
	              2, TO_CHAR(q11.fefecto, ''DD/MM/RRRR''),
	              NULL) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.saldo_prorrogado, 1, TO_CHAR(q11.fvencim, ''DD/MM/RRRR''), NULL)  ||'
	              || chr(39)
	              || v_sep /*BUG 29952/167822 - 27/02/2014 - RCL*/
	              || chr(39)
	              || '|| q11.c21 ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| 0||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| 0||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| 0||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| 0||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| 0||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| 0||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.saldo_prorrogado, 1, q11.icapgar, 2, q11.icapgar, NULL) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.saldo_prorrogado, 1, q11.ivalact, 2, q11.ivalact, NULL) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.saldo_prorrogado, 1, q11.prima_unica, 2, q11.prima_unica, NULL) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.saldo_prorrogado, 1, q11.ipromat, 2, q11.ipromat, NULL) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.gar_adicional,
	              2, 5,
	              702, 7,
	              709, 7,
	              711, 7,
	              10, 8,
	              703, 9,
	              700, 10,
	              8, 4,
	              701, 4,
	              6901, NULL,
	              718, NULL,
	              DECODE(q11.gar_adicional, 0, NULL, 11)) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.gar_adicional, 0, NULL, q11.c22a) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.gar_adicional,
	              0, NULL,
	              DECODE(q11.saldo_prorrogado, 1, NULL, 2, NULL, q11.prevali)) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.gar_adicional, 0, NULL, q11.c22b) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.gar_adicional,
	              0, NULL,
	              TO_CHAR(q11.crecimhasta_adicional, ''DD/MM/RRRR'')) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.gar_adicional, 0, NULL, q11.c15b) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.gar_adicional, 0, NULL, q11.c15b) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.gar_adicional,
	              0, NULL,
	              TO_CHAR(pac_superfinan.ff_fecinivig_adicional(q11.sseguro, q11.nriesgo, q11.fcalcul), ''DD/MM/RRRR'')) ||' --BUG 29952/167822 - 27/02/2014 - RCL
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.gar_adicional,
	              0, NULL,
	              TO_CHAR(q11.crecimhasta_adicional, ''DD/MM/RRRR'')) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.gar_adicional,
	              0, NULL,
	              pac_superfinan.ff_edadinicial_adicional(q11.sseguro, q11.nriesgo, q11.fcalcul)) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.gar_adicional,
	              0, NULL,
	              DECODE(q11.saldo_prorrogado,
	                     1, NULL,
	                     2, NULL,
	                     pac_superfinan.ff_gastos_adquis(q11.sseguro, q11.nriesgo,
	                                                     q11.gar_adicional, q11.fefecto))) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.gar_adicional,
	              0, NULL,
	              DECODE(q11.saldo_prorrogado,
	                     1, NULL,
	                     2, NULL,
	                     pac_superfinan.ff_gastos_adquis(q11.sseguro, q11.nriesgo,
	                                                     q11.gar_adicional,
	                                                     ADD_MONTHS(q11.fefecto, 12)))) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.gar_adicional,
	              0, NULL,
	              DECODE(q11.saldo_prorrogado,
	                     1, NULL,
	                     2, NULL,
	                     pac_superfinan.ff_gastos_adquis(q11.sseguro, q11.nriesgo,
	                                                     q11.gar_adicional,
	                                                     ADD_MONTHS(q11.fefecto, 24)))) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.gar_adicional,
	              0, NULL,
	              DECODE(q11.saldo_prorrogado,
	                     1, NULL,
	                     2, NULL,
	                     pac_superfinan.ff_gastos_admin_tot(q11.sseguro, q11.nriesgo,
	                                                        q11.gar_adicional, q11.fefecto))) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.gar_adicional,
	              0, NULL,
	              DECODE(q11.saldo_prorrogado,
	                     1, NULL,
	                     2, NULL,
	                     pac_superfinan.ff_gastos_admin_tot(q11.sseguro, q11.nriesgo,
	                                                        q11.gar_adicional,
	                                                        ADD_MONTHS(q11.fefecto, 12)))) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.gar_adicional,
	              0, NULL,
	              DECODE(q11.saldo_prorrogado,
	                     1, NULL,
	                     2, NULL,
	                     pac_superfinan.ff_gastos_admin_tot(q11.sseguro, q11.nriesgo,
	                                                        q11.gar_adicional,
	                                                        ADD_MONTHS(q11.fefecto, 24)))) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.gar_adicional,
	              0, NULL,
	              pac_superfinan.ff_valase_inicial_adicional(q11.sseguro, q11.nriesgo, q11.fcalcul))
	                                                                                           ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.gar_adicional,
	              0, NULL,
	              pac_superfinan.ff_valase_alcanzado_adicional(q11.sseguro, q11.nriesgo,
	                                                           q11.fcalcul)) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.gar_adicional,
	              0, NULL,
	              pac_superfinan.ff_prima_riesgo_adicional(q11.sseguro, q11.nriesgo, q11.fcalcul)) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.gar_adicional,
	              0, NULL,
	              pac_superfinan.ff_reserva_adicional(q11.sseguro, q11.nriesgo, q11.fcalcul)) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| DECODE(q11.gar_adicional,
	              0, NULL,
	              pac_superfinan.ff_reserva_demasadicionales(q11.sseguro, q11.nriesgo, q11.fcalcul)) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| NULL||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.c69||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| f_round(q11.reserva_total, pac_monedas.f_moneda_producto(q11.sproduc)) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| f_round
	          (q11.reserva_total
	           *(pac_eco_tipocambio.f_cambio
	                (pac_monedas.f_cmoneda_t(NVL(q11.cdivisa, f_parinstalacion_n(''MONEDAINST''))),
	                 ''COP'',
	                 NVL
	                    (pac_eco_tipocambio.f_fecha_max_cambio
	                               (pac_monedas.f_cmoneda_t(NVL(q11.cdivisa,
	                                                            f_parinstalacion_n(''MONEDAINST''))),
	                                ''COP'', q11.fechacorte),
	                     q11.fechacorte))),
	           pac_monedas.f_moneda_producto(q11.sproduc)) ||'
	              || chr(39)
	              || v_sep
	              || chr(39)
	              || '|| q11.c72'
	              /*         || CHR(39) || v_sep || CHR(39) || '|| q11.c72||' || CHR(39) || v_sep || CHR(39)*/
	              /*         || '|| ff_desgarantia(q11.gar_adicional, ' || p_cidioma || ') '*/
	              || ' FROM (SELECT pac_superfinan.ff_codigo_compania(q1.sseguro) c1, '
	              || '    pac_superfinan.ff_titulo_prod(q1.sseguro) c2, q1.sproduc, '
	              || '    pac_superfinan.ff_estado_plan(q1.sseguro) c3, '
	              /*BUG 29952/169039 - 17/03/2014 - RCL*/
	              || '    DECODE(q1.cagente, ''12000'', ''12000'', pac_redcomercial.f_busca_padre(q1.cempres, q1.cagente, null, null)) c4, q1.cramo, '
	              || '    q1.npoliza, DECODE(q1.cdivisa, 8, 1, 6, 2, 1, 3, 4) c5, '
	              || '    (pac_eco_tipocambio.f_cambio '
	              || '        (pac_monedas.f_cmoneda_t(NVL(q1.cdivisa, f_parinstalacion_n(''MONEDAINST''))), '
	              || '         ''COP'', '
	              || '         NVL '
	              || '            (pac_eco_tipocambio.f_fecha_max_cambio '
	              || '                    (pac_monedas.f_cmoneda_t(NVL(q1.cdivisa, '
	              || '                                                 f_parinstalacion_n(''MONEDAINST''))), '
	              || '                     ''COP'', q1.fechacorte), '
	              || '             q1.fechacorte))) c6, '
	              || '    pac_superfinan.ff_clase_seguro(q1.sseguro, q1.sproduc) c7, '
	              || '    pac_superfinan.ff_tabla_mortalidad(q1.sseguro) c8, '
	              || '    pac_superfinan.ff_estado_poliza(q1.sproduc) c9, '
	              || '    pac_superfinan.F_GET_FEXPEDICION(q1.sseguro) c10, '
	              || '    (SELECT TO_CHAR( max(fefecto), ''dd/mm/yyyy'') FROM movseguro '
	              || '       WHERE sseguro = q1.sseguro AND cmovseg = 2 AND cmotmov IN (404,406,407)) c11, ' --BUG 29952/167822 - 27/02/2014 - RCL
	              || ' NVL(q1.fvencim, (SELECT fvencim FROM seguros WHERE sseguro = q1.sseguro)) fvencim, ' --BUG 29952/167822 - 27/02/2014 - RCL
	              || ' pac_superfinan.ff_altura(q1.sseguro, q1.fechacorte, q1.fefecto) c13, '
	              || ' pac_superfinan.ff_altura_mes(q1.fefecto, q1.fechacorte) c14, '
	              || ' pac_inttec.ff_int_seguro(''SEG'', q1.sseguro, q1.fefecto, 0, 0) c15, '
	              || ' pac_inttec.ff_int_seguro(''SEG'', q1.sseguro, q1.fechacorte, 0, 0) c15a, '
	              || ' pac_inttec.ff_int_seguro(''SEG'', q1.sseguro, q1.fcalcul, 0, 0) c15b, '
	              || ' DECODE(q1.cforpag, '
	              || ' 0, ''  No Fraccionada '', '
	              || ' 12, '' No Fraccionada '', '
	              || ' '' Fraccionada '') c16, '
	              || ' DECODE(q1.cforpag, 0, 5, 1, 1, 2, 2, 3, 6, 4, 3, 6, 6, 12, 4) c17, '
	              || ' (pac_superfinan.ff_fecha_pago_prima(q1.sseguro, q1.fefecto)) c18, '
	              || ' DECODE(q1.ctipide, 33, 2, 34, 4, 36, 1, 37, 3, 38, 9, 35, 9, 40, 5, 10) c19, '
	              || ' q1.nnumide, q1.csexper, TO_CHAR(q1.fnacimi, ''dd/mm/yyyy'') c20, '
	              || ' pac_superfinan.ff_edad_ingaseg_principal(q1.sseguro,q1.fnacimi,q1.fefecto) c21, '
	              || ' pac_superfinan.ff_crecvalor_aseg(q1.sseguro, 1) c22a, '
	              || ' pac_superfinan.ff_crecvalor_aseg(q1.sseguro, 2) c22b, NVL(q1.prevali, 0) c23, '
	              || ' TO_CHAR(pac_superfinan.ff_fecha_crecimiento(q1.sseguro, q1.nriesgo, '
	              || ' q1.fcalcul, 6901, 1), '
	              || ' ''DD/MM/RRRR'') c24, '
	              || ' (pac_superfinan.ff_saldado_prorrogado(q1.sproduc)) saldo_prorrogado, '
	              || ' (pac_superfinan.ff_garantia_basica(q1.sseguro, q1.nriesgo, q1.fechacorte)) '
	              || ' garantia_basica, '
	              || ' q1.fefecto, q1.nriesgo, q1.sseguro, q1.fechacorte, q1.fcalcul, q1.icapgar, '
	              || ' q1.ivalact, '
	              || ' pac_superfinan.ff_prima_unica(q1.sseguro, q1.cgarant, q1.sproduc) prima_unica, '
	              || ' q1.ipromat, '
	              || ' pac_superfinan.ff_gar_adicional(q1.sseguro, q1.nriesgo, '
	              || ' q1.fechacorte) gar_adicional, '
	              || ' q1.prevali, '
	              || ' pac_superfinan.ff_crecimhasta_adicional(q1.sseguro, '
	              || ' q1.nriesgo, '
	              || ' q1.fcalcul) crecimhasta_adicional, '
	              || ' pac_superfinan.ff_reserva_total(q1.sseguro, q1.nriesgo, '
	              || ' q1.fcalcul) reserva_total, '
	              || ' q1.cdivisa, '
	              || ' NVL(fbuscasaldo(NULL, q1.sseguro, '
	              || ' TO_NUMBER(TO_CHAR(q1.fechacorte, ''YYYYMMDD''))), '
	              || ' 0) c69, '
	              || ' pac_seguros.ff_situacion_poliza(q1.sseguro, '
	              || p_cidioma
	              || ', 2, NULL, NULL, '
	              || ' q1.fcalcul) c72, q1.fcaranu '
	              || ' FROM (SELECT s.sseguro, s.sproduc, s.cramo, s.cagente, s.cempres, s.npoliza, '
	              || ' p.cdivisa, f.fechacorte, s.fvencim, s.fefecto, s.cforpag, per.ctipide, '
	              || ' per.nnumide, per.csexper, per.fnacimi, s.prevali, pm.nriesgo, '
	              || ' pm.fcalcul, pm.icapgar, pm.ivalact, gar.cgarant, pm.ipromat, s.fcaranu '
	              || ' FROM provmat pm, '
	              || ' seguros s, '
	              || ' productos p, '
	              || ' riesgos r, '
	              || ' per_personas per, '
	              || ' garanpro gar, '
	              || ' (SELECT LAST_DAY(TO_DATE( '
	              || chr(39)
	              || lpad(p_mes, 2, 0)
	              || p_ano
	              || chr(39)
	              || ', ''mmyyyy'')) fechacorte'
	              || ' FROM DUAL)  f, agentes_agente_pol ap '
	              || ' WHERE s.sseguro = pm.sseguro '
	              || ' AND s.cempres = ap.cempres AND s.cagente = ap.cagente' -- Bug 30393/173881 - 08/05/2014 - AMC
	              || ' AND s.sproduc = p.sproduc '
	              || ' AND s.sseguro = r.sseguro '
	              || ' AND per.sperson = r.sperson '
	              || ' AND p.sproduc = gar.sproduc '
	              || ' AND r.sseguro = pm.sseguro '
	              || ' AND r.nriesgo = pm.nriesgo '
	              || ' AND gar.cmodali = pm.cmodali '
	              || ' AND gar.ccolect = pm.ccolect '
	              || ' AND gar.cramo = pm.cramo '
	              || ' AND gar.ctipseg = pm.ctipseg '
	              || ' AND gar.cgarant = pm.cgarant '
	              || ' AND pm.fcalcul = f.fechacorte '
	              || ' AND pm.cempres = '
	              || p_cempres
	              || ' AND NVL(gar.cbasica, 0) = 1 '
	              || ' AND NOT (s.csituac = 0 and s.creteni = 2) ' --BUG 29952/167822 - 27/02/2014 - RCL
	              || ' AND 1 = f_situacion_v(s.sseguro, f.fechacorte)) q1) q11';

	    /*

	    SELECT  pac_superfinan.ff_codigo_compania(s.sseguro) ||','|| s.sproduc ||','|| pac_superfinan.ff_titulo_prod(s.sseguro)||','||  s.sproduc ||','||  pac_superfinan.ff_titulo_prod(s.sseguro)||','||pac_superfinan.ff_estado_plan(s.sseguro)||','||s.cramo||','||(pac_agentes.f_get_cageliq(s.cempres, 2, s.cagente)) ||','||  s.npoliza  ||','|| DECODE(p.cdivisa, 8, 1, 6, 2, 1, 3, 4) ||','||'"'||  (pac_eco_tipocambio.f_cambio
	               (pac_monedas.f_cmoneda_t(NVL(p.cdivisa, f_parinstalacion_n('MONEDAINST'))), 'COP',
	                NVL
	                   (pac_eco_tipocambio.f_fecha_max_cambio
	                                   (pac_monedas.f_cmoneda_t(NVL(p.cdivisa,
	                                                                f_parinstalacion_n('MONEDAINST'))),
	                                    'COP', f.fechacorte),
	                    f.fechacorte))) ||'"'||','|| pac_superfinan.ff_clase_seguro(s.sseguro, s.sproduc)||','||(pac_superfinan.ff_tabla_mortalidad(s.sseguro))||','||pac_superfinan.ff_estado_poliza(s.sproduc)||','|| TO_CHAR(s.fefecto, 'dd/mm/yyyy')||','|| to_char(to_date(frenovacion(NULL, s.sseguro, 2),'yyyymmdd'),'dd/mm/yyyy')||','||decode(pac_superfinan.ff_clase_seguro(s.sseguro, s.sproduc),1,' ',DECODE(s.fvencim, NULL, ' ', TO_CHAR(s.fvencim - 1, 'dd/mm/yyyy')))||','|| pac_superfinan.ff_altura(s.sseguro, f.fechacorte, s.fefecto) ||','|| pac_superfinan.ff_altura_mes(f.fechacorte,s.fefecto)||','||'"'|| pac_inttec.ff_int_seguro('SEG', s.sseguro, s.fefecto, 0, 0)||'"'||','||'"'|| pac_inttec.ff_int_seguro('SEG', s.sseguro, s.fefecto, 0, 0) ||'"'||','||NULL ||','||NULL ||','||NULL ||','||DECODE(s.cforpag, 0, 5, 1, 1, 2, 2, 3, 6, 4, 3, 6, 6, 12, 4)||','||(pac_superfinan.ff_fecha_pago_prima(s.sseguro, s.fefecto)) ||','||DECODE(per.ctipide, 33, 2, 34, 4, 36, 1, 37, 3, 38, 9, 35, 9, 40, 5, 10) ||','|| per.nnumide ||','|| per.csexper ||','||TO_CHAR(per.fnacimi, 'dd/mm/yyyy')||','||  (fedad(NULL, TO_CHAR(per.fnacimi, 'yyyymmdd'), TO_CHAR(s.fefecto, 'yyyymmdd'), 1))||','||pac_superfinan.ff_crecvalor_aseg(s.sseguro, 1) ||','||'"'||DECODE(pac_superfinan.ff_saldado_prorrogado(p.sproduc),
	                  1, NULL,
	                  2, NULL,
	                  s.prevali)||'"'||','|| pac_superfinan.ff_crecvalor_aseg(s.sseguro, 2) ||','|| TO_CHAR(pac_superfinan.ff_crecimhasta_adicional(pm.sseguro, pm.nriesgo,
	                                                   pm.fcalcul), 'DD/MM/RRRR')||','||'"'|| DECODE(pac_superfinan.ff_saldado_prorrogado(s.sproduc),
	                  1, NULL,
	                  2, NULL,pac_superfinan.ff_gastos_adquis
	                             (s.sseguro, r.nriesgo,
	                              pac_superfinan.ff_garantia_basica(s.sseguro,
	                                                                r.nriesgo,
	                                                                f.fechacorte),
	                              s.fefecto))||'"'||','||'"'|| DECODE(pac_superfinan.ff_saldado_prorrogado(s.sproduc),
	                  1, NULL,
	                  2, NULL,pac_superfinan.ff_gastos_adquis
	                             (s.sseguro, r.nriesgo,
	                              pac_superfinan.ff_garantia_basica(s.sseguro,
	                                                                r.nriesgo,
	                                                                f.fechacorte),
	                              ADD_MONTHS(s.fefecto, 12))) ||'"'||','||'"'|| DECODE(pac_superfinan.ff_saldado_prorrogado(s.sproduc),
	                  1, NULL,
	                  2, NULL,pac_superfinan.ff_gastos_adquis
	                             (s.sseguro, r.nriesgo,
	                              pac_superfinan.ff_garantia_basica(s.sseguro,
	                                                                r.nriesgo,
	                                                                f.fechacorte),
	                              ADD_MONTHS(s.fefecto, 24)))||'"'||','||'"'|| DECODE(pac_superfinan.ff_saldado_prorrogado(s.sproduc),
	                  1, NULL,
	                  2, NULL,pac_superfinan.ff_gastos_admin
	                               (s.sseguro, r.nriesgo,
	                                pac_superfinan.ff_garantia_basica(s.sseguro,
	                                                                  r.nriesgo,
	                                                                  f.fechacorte),
	                                s.fefecto))||'"'||','||'"'|| DECODE(pac_superfinan.ff_saldado_prorrogado(s.sproduc),
	                  1, NULL,
	                  2, NULL,pac_superfinan.ff_gastos_admin
	                               (s.sseguro, r.nriesgo,
	                                pac_superfinan.ff_garantia_basica(s.sseguro,
	                                                                  r.nriesgo,
	                                                                  f.fechacorte),
	                                ADD_MONTHS(s.fefecto, 12)))||'"'||','||'"'|| DECODE(pac_superfinan.ff_saldado_prorrogado(s.sproduc),
	                  1, NULL,
	                  2, NULL,pac_superfinan.ff_gastos_admin
	                               (s.sseguro, r.nriesgo,
	                                pac_superfinan.ff_garantia_basica(s.sseguro,
	                                                                  r.nriesgo,
	                                                                  f.fechacorte),
	                                ADD_MONTHS(s.fefecto, 24)))||'"'||','||'"'|| DECODE(pac_superfinan.ff_saldado_prorrogado(s.sproduc),
	                  1, NULL,
	                  2, NULL,
	                  (SELECT SUM(pv.icapgar)
	                     FROM provmat pv
	                    WHERE pv.sseguro = s.sseguro
	                      AND pv.nriesgo = r.nriesgo
	                      AND pv.cgarant=pac_superfinan.ff_garantia_basica(s.sseguro,
	                                                                r.nriesgo,
	                                                                f.fechacorte)
	                      AND fcalcul = f.fechacorte))||'"'||','||'"'||   DECODE(pac_superfinan.ff_saldado_prorrogado(s.sproduc),
	                  1, NULL,
	                  2, NULL,
	                  (SELECT SUM(pv.ivalact)
	                     FROM provmat pv
	                    WHERE pv.sseguro = s.sseguro
	                      AND pv.nriesgo = r.nriesgo
	                      AND pv.cgarant=pac_superfinan.ff_garantia_basica(s.sseguro,
	                                                                r.nriesgo,
	                                                                f.fechacorte)
	                      AND fcalcul = f.fechacorte))||'"'||','||'"'|| DECODE(pac_superfinan.ff_saldado_prorrogado(s.sproduc),
	                  1, NULL,
	                  2, NULL,
	                  pac_superfinan.ff_prima_riesgo_basico(s.sseguro, r.nriesgo, f.fechacorte))||'"'||','||'"'|| DECODE(pac_superfinan.ff_saldado_prorrogado(s.sproduc),
	                  1, NULL,
	                  2, NULL,
	                  (SELECT SUM(pv.ipromat)
	                     FROM provmat pv
	                    WHERE pv.sseguro = s.sseguro
	                    AND pv.cgarant=pac_superfinan.ff_garantia_basica(s.sseguro,
	                                                                r.nriesgo,
	                                                                f.fechacorte)
	                      AND pv.nriesgo = r.nriesgo
	                      AND fcalcul = f.fechacorte)) ||'"'||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||  pac_superfinan.ff_codigo_cobertura(p.sproduc) ||','|| DECODE(pac_superfinan.ff_saldado_prorrogado(p.sproduc), 1, 9, 2, 9, NULL) ||','|| DECODE(pac_superfinan.ff_saldado_prorrogado(p.sproduc), 1, 0, 2, 0, NULL) ||','|| DECODE(pac_superfinan.ff_saldado_prorrogado(p.sproduc), 1, 1, 2, 1, NULL)||','|| TO_CHAR(pac_superfinan.ff_crecimhasta_adicional(pm.sseguro, pm.nriesgo,
	                                                   pm.fcalcul), 'DD/MM/RRRR')||','||'"'|| DECODE(pac_superfinan.ff_saldado_prorrogado(p.sproduc), 1,pac_inttec.ff_int_seguro('SEG', s.sseguro, f.fechacorte, 0, 0) ,2,pac_inttec.ff_int_seguro('SEG', s.sseguro, f.fechacorte, 0, 0),null) ||'"'||','||'"'|| DECODE(pac_superfinan.ff_saldado_prorrogado(p.sproduc), 1,pac_inttec.ff_int_seguro('SEG', s.sseguro, f.fechacorte, 0, 0) ,2,pac_inttec.ff_int_seguro('SEG', s.sseguro, f.fechacorte, 0, 0),null)||'"'||','||  DECODE(pac_superfinan.ff_saldado_prorrogado(p.sproduc),
	                  1, TO_CHAR(s.fefecto ,'DD/MM/RRRR'),
	                  2, TO_CHAR(s.fefecto,'DD/MM/RRRR'),
	                  NULL)||','|| DECODE(pac_superfinan.ff_saldado_prorrogado(p.sproduc), 1, s.fvencim, NULL) ||','|| (fedad(NULL, TO_CHAR(per.fnacimi, 'yyyymmdd'), TO_CHAR(s.fefecto, 'yyyymmdd'), 1))||','||0||','||0||','||0||','||0||','||0||','||0||','|| DECODE(pac_superfinan.ff_saldado_prorrogado(p.sproduc),
	                  1, pm.icapgar,
	                  2, pm.icapgar,
	                  NULL) ||','|| DECODE(pac_superfinan.ff_saldado_prorrogado(p.sproduc),
	                  1, pm.ivalact,
	                  2, pm.ivalact,
	                  NULL) ||','|| pac_superfinan.ff_prima_unica(s.sseguro, gar.cgarant, p.sproduc)||','|| DECODE(pac_superfinan.ff_saldado_prorrogado(p.sproduc),
	                  1, pm.ipromat,
	                  2, pm.ipromat,
	                  NULL)||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','||NULL||','|| DECODE(pac_superfinan.ff_gar_adicional(s.sseguro, r.nriesgo, f.fechacorte),
	                  2, 5,
	                  702, 7,
	                  709, 7,
	                  711, 7,
	                  10, 8,
	                  703, 9,
	                  700, 10,
	                  8, 4,
	                  701, 4,
	                  6901, NULL,
	                  718, NULL,
	                  11)||','|| pac_superfinan.ff_crecvalor_aseg(s.sseguro, 1) ||','||'"'|| DECODE(pac_superfinan.ff_saldado_prorrogado(p.sproduc), 1, NULL, 2, NULL, s.prevali) ||'"'||','|| pac_superfinan.ff_crecvalor_aseg(s.sseguro, 2) ||','|| decode(pac_superfinan.ff_gar_adicional(S.SSEGURO, r.nriesgo,  f.fechacorte),0,NULL,to_char(pac_superfinan.ff_crecimhasta_adicional(pm.sseguro, pm.nriesgo, pm.fcalcul), 'DD/MM/RRRR'))||','||'"'||   pac_inttec.ff_int_seguro('SEG', pm.sseguro, pm.fcalcul, 0, 0) ||'"'||','||'"'||  pac_inttec.ff_int_seguro('SEG', pm.sseguro, pm.fcalcul, 0, 0)||'"'||','||  pac_superfinan.ff_fecinivig_adicional(pm.sseguro, pm.nriesgo, pm.fcalcul)||','|| decode(pac_superfinan.ff_gar_adicional(S.SSEGURO, r.nriesgo,  f.fechacorte),0,NULL,to_char(pac_superfinan.ff_crecimhasta_adicional(pm.sseguro, pm.nriesgo, pm.fcalcul), 'DD/MM/RRRR'))||','||   pac_superfinan.ff_edadinicial_adicional(pm.sseguro, pm.nriesgo, pm.fcalcul) ||','|| DECODE(pac_superfinan.ff_saldado_prorrogado(s.sproduc),
	                  1, NULL,
	                  2, NULL,pac_superfinan.ff_gastos_adquis
	                             (s.sseguro, r.nriesgo,
	                              pac_superfinan.ff_gar_adicional(s.sseguro,
	                                                                r.nriesgo,
	                                                                f.fechacorte),
	                              s.fefecto)) ||','||  DECODE(pac_superfinan.ff_saldado_prorrogado(s.sproduc),
	                  1, NULL,
	                  2, NULL,pac_superfinan.ff_gastos_adquis
	                             (s.sseguro, r.nriesgo,
	                              pac_superfinan.ff_gar_adicional(s.sseguro,
	                                                                r.nriesgo,
	                                                                f.fechacorte),
	                              ADD_MONTHS(s.fefecto, 12))) ||','||  DECODE(pac_superfinan.ff_saldado_prorrogado(s.sproduc),
	                  1, NULL,
	                  2, NULL,pac_superfinan.ff_gastos_adquis
	                             (s.sseguro, r.nriesgo,
	                              pac_superfinan.ff_gar_adicional(s.sseguro,
	                                                                r.nriesgo,
	                                                                f.fechacorte),
	                              ADD_MONTHS(s.fefecto, 24)))||','|| DECODE(pac_superfinan.ff_saldado_prorrogado(s.sproduc),
	                  1, NULL,
	                  2, NULL,pac_superfinan.ff_gastos_admin
	                               (s.sseguro, r.nriesgo,
	                                pac_superfinan.ff_gar_adicional(s.sseguro,
	                                                                  r.nriesgo,
	                                                                  f.fechacorte),
	                                s.fefecto)) ||','|| DECODE(pac_superfinan.ff_saldado_prorrogado(s.sproduc),
	                  1, NULL,
	                  2, NULL,pac_superfinan.ff_gastos_admin
	                               (s.sseguro, r.nriesgo,
	                                pac_superfinan.ff_gar_adicional(s.sseguro,
	                                                                  r.nriesgo,
	                                                                  f.fechacorte),
	                                ADD_MONTHS(s.fefecto, 12))) ||','||   DECODE(pac_superfinan.ff_saldado_prorrogado(s.sproduc),
	                  1, NULL,
	                  2, NULL,pac_superfinan.ff_gastos_admin
	                               (s.sseguro, r.nriesgo,
	                                pac_superfinan.ff_gar_adicional(s.sseguro,
	                                                                  r.nriesgo,
	                                                                  f.fechacorte),
	                                ADD_MONTHS(s.fefecto, 24)))||','||'"'||  pac_superfinan.ff_valase_inicial_adicional(pm.sseguro, pm.nriesgo, pm.fcalcul)||'"'||','||'"'||  pac_superfinan.ff_valase_alcanzado_adicional(pm.sseguro, pm.nriesgo,
	                                                        pm.fcalcul) ||'"'||','||'"'|| pac_superfinan.ff_prima_riesgo_adicional(pm.sseguro, pm.nriesgo, pm.fcalcul)||'"'||','||'"'|| pac_superfinan.ff_reserva_adicional(pm.sseguro, pm.nriesgo, pm.fcalcul) ||'"'||','||'"'|| pac_superfinan.ff_reserva_demasadicionales(pm.sseguro, pm.nriesgo, pm.fcalcul) ||'"'||','|| NULL ||','||'"'|| NVL(pac_operativa_finv.ff_provmat(NULL, pm.sseguro, TO_NUMBER(TO_CHAR(f.fechacorte, 'YYYYMMDD'))), 0)||'"'||','||'"'|| f_round(pac_superfinan.ff_reserva_total(pm.sseguro, pm.nriesgo, pm.fcalcul), pac_monedas.f_moneda_producto(s.sproduc))||'"'||','||'"'|| f_round(pac_superfinan.ff_reserva_total(pm.sseguro, pm.nriesgo, pm.fcalcul) * (pac_eco_tipocambio.f_cambio
	               (pac_monedas.f_cmoneda_t(NVL(p.cdivisa, f_parinstalacion_n('MONEDAINST'))), 'COP',
	                NVL
	                   (pac_eco_tipocambio.f_fecha_max_cambio
	                                   (pac_monedas.f_cmoneda_t(NVL(p.cdivisa,
	                                                                f_parinstalacion_n('MONEDAINST'))),
	                                    'COP', f.fechacorte),
	                    f.fechacorte))), pac_monedas.f_moneda_producto(s.sproduc)) ||'"'||','||'"'|| pac_seguros.ff_situacion_poliza(pm.sseguro, 2, 2, NULL, NULL, pm.fcalcul) ||'.' ||'"'|| ff_desgarantia(pac_superfinan.ff_gar_adicional(s.sseguro, r.nriesgo, f.fechacorte), 2) FROM provmat pm,
	           seguros s,
	           productos p,
	           riesgos r,
	           per_personas per,
	           garanpro gar, (SELECT LAST_DAY(TO_DATE( '022011', 'mmyyyy')) fechacorte FROM DUAL)  f WHERE s.sseguro = pm.sseguro
	       AND pm.fcalcul = f.fechacorte
	       AND pm.cempres = 12 AND s.ctipseg = p.ctipseg
	       AND s.ccolect = p.ccolect
	       AND s.cramo = p.cramo
	       AND s.cmodali = p.cmodali
	       AND r.sseguro = pm.sseguro
	       AND r.nriesgo = pm.nriesgo
	       AND per.sperson = r.sperson
	       AND gar.cmodali = pm.cmodali
	       AND gar.ccolect = pm.ccolect
	       AND gar.cramo = pm.cramo
	       AND gar.ctipseg = pm.ctipseg
	       AND gar.cgarant = pm.cgarant
	       AND NVL(gar.cbasica, 0) = 1


	    */
	    /*    v_ttexto := 'MI SELECT';--ETM PENDIENTE--***************************/
	    RETURN to_clob(v_ttexto);
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list509_det;

	/* FIN Bug 20107  - 07/02/2012 - ETM*/
	/* INI Bug 21838 - 14/05/2012 - JLTS*/
	FUNCTION f_list526_det(p_idioma NUMBER DEFAULT NULL,p_fradica_ini VARCHAR2 DEFAULT NULL,/* DDMMYYYY*/p_fradica_fin VARCHAR2 DEFAULT NULL,/* DDMMYYYY*/p_focurren_ini VARCHAR2 DEFAULT NULL,/* DDMMYYYY*/p_focurren_fin VARCHAR2 DEFAULT NULL,/* DDMMYYYY*/p_faviso_ini VARCHAR2 DEFAULT NULL,/* DDMMYYYY*/p_faviso_fin VARCHAR2 DEFAULT NULL,/* DDMMYYYY*/p_fcontab_ini VARCHAR2 DEFAULT NULL,/* DDMMYYYY*/p_fcontab_fin VARCHAR2 DEFAULT NULL,/* DDMMYYYY*/p_cusuari sin_codtramitador.cusuari%TYPE DEFAULT NULL,p_ctramitad sin_tramita_movimiento.ctramitad%TYPE DEFAULT NULL,p_ramo siniestros.cramo%TYPE DEFAULT NULL,p_sproduc seguros.sproduc%TYPE DEFAULT NULL,p_ccausin sin_siniestro.ccausin%TYPE DEFAULT NULL,p_asistencia sin_tramitacion.ctramit%TYPE DEFAULT NULL,p_proveedor sin_tramita_gestion.sprofes%TYPE DEFAULT NULL,p_departamento sin_tramita_localiza.cprovin%TYPE DEFAULT NULL,p_ciudad sin_tramita_localiza.cpoblac%TYPE DEFAULT NULL)
	RETURN CLOB
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list526_det';
	  v_tparam  VARCHAR2(1000):='f_idioma ='
	                           || p_idioma
	                           || ' p_fradic_ini='
	                           || p_fradica_ini
	                           || ' p_fradic_fin='
	                           || p_fradica_fin
	                           || ' p_ffocurren_ini='
	                           || p_focurren_ini
	                           || ' p_focurren_fin='
	                           || p_focurren_fin
	                           || ' p_faviso_ini='
	                           || p_faviso_ini
	                           || ' p_faviso_fin='
	                           || p_faviso_fin
	                           || ' p_fcontab_ini='
	                           || p_fcontab_ini
	                           || ' p_fcontab_fin='
	                           || p_fcontab_fin
	                           || ' p_cusuari='
	                           || p_cusuari
	                           || ' p_ctramitar='
	                           || p_ctramitad
	                           || ' p_ramo='
	                           || p_ramo
	                           || ' p_sproduc='
	                           || p_sproduc
	                           || ' p_causin='
	                           || p_ccausin
	                           || ' p_asistencia='
	                           || p_asistencia
	                           || ' p_proveedor='
	                           || p_proveedor
	                           || ' p_departamento='
	                           || p_departamento
	                           || ' p_ciudad='
	                           || p_ciudad;
	  v_ntraza  NUMBER:=0;
	  v_finiefe VARCHAR2(100);
	  v_ffinefe VARCHAR2(100);
	  v_idioma  NUMBER;
	  verror    NUMBER;
	  v_sep     VARCHAR2(2):='||';
	BEGIN
	    v_ntraza:=1000;

	    v_ttexto:=NULL;

	    v_idioma:=p_idioma;

	    IF p_idioma IS NULL THEN
	      v_idioma:=f_parinstalacion_n('IDIOMARTF');
	    END IF;

	    v_ttexto:=v_ttexto
	              || 'SELECT   tramitador || '';'' || no_gestion || '';'' || q1.nsinies || '';'' || ramo || '';'' || producto ';

	    v_ttexto:=v_ttexto
	              || '         || '';'' || poliza || '';'' || des_causa || '';'' || asistencia || '';'' ';

	    v_ttexto:=v_ttexto
	              || '         || (SELECT p.tprovin ';

	    v_ttexto:=v_ttexto
	              || '               FROM provincias p ';

	    v_ttexto:=v_ttexto
	              || '              WHERE p.cprovin = t.cprovin) || '';'' ';

	    v_ttexto:=v_ttexto
	              || '         || (SELECT p.tpoblac ';

	    v_ttexto:=v_ttexto
	              || '               FROM poblaciones p ';

	    v_ttexto:=v_ttexto
	              || '              WHERE p.cprovin = t.cprovin ';

	    v_ttexto:=v_ttexto
	              || '                AND p.cpoblac = t.cpoblac) ';

	    v_ttexto:=v_ttexto
	              || '         || '';'' || proveedor Linea ';

	    v_ttexto:=v_ttexto
	              || '    FROM sin_tramita_localiza t, ';

	    v_ttexto:=v_ttexto
	              || '         (SELECT tramitador, no_gestion, nsinies, ramo, producto, poliza, des_causa, ';

	    v_ttexto:=v_ttexto
	              || '                 asistencia, proveedor, nlocali, ntramit, nmovtra ';

	    v_ttexto:=v_ttexto
	              || '            FROM (SELECT ss.nsinies, st.ntramit, stm.ctramitad tramitador, ';

	    v_ttexto:=v_ttexto
	              || '                         stg.sgestio no_gestion, stm.nmovtra, ';

	    v_ttexto:=v_ttexto
	              || '                         ff_desramo(s.cramo, '
	              || v_idioma
	              || ') ramo, ';

	    v_ttexto:=v_ttexto
	              || '                         f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, '
	              || v_idioma
	              || ') producto, ';

	    v_ttexto:=v_ttexto
	              || '                         s.npoliza poliza, ';

	    v_ttexto:=v_ttexto
	              || '                         (SELECT sd.tcausin ';

	    v_ttexto:=v_ttexto
	              || '                            FROM sin_descausa sd ';

	    v_ttexto:=v_ttexto
	              || '                           WHERE sd.ccausin = ss.ccausin ';

	    v_ttexto:=v_ttexto
	              || '                             AND sd.cidioma = '
	              || v_idioma
	              || ') des_causa, ';

	    v_ttexto:=v_ttexto
	              || '                         ff_desvalorfijo(108, '
	              || v_idioma
	              || ', ';

	    v_ttexto:=v_ttexto
	              || '                                         (CASE ';

	    v_ttexto:=v_ttexto
	              || '                                             WHEN st.ctramit = 15 THEN 1 ';

	    v_ttexto:=v_ttexto
	              || '                                             ELSE 0 ';

	    v_ttexto:=v_ttexto
	              || '                                          END)) asistencia, ';

	    v_ttexto:=v_ttexto
	              || '                         (SELECT MIN(t1.nlocali) ';

	    v_ttexto:=v_ttexto
	              || '                            FROM sin_tramita_localiza t1 ';

	    v_ttexto:=v_ttexto
	              || '                           WHERE t1.nsinies = ss.nsinies ';

	    v_ttexto:=v_ttexto
	              || '                             AND t1.ntramit = st.ntramit) nlocali, ';

	    v_ttexto:=v_ttexto
	              || '                         (f_nombre((SELECT sperson ';

	    v_ttexto:=v_ttexto
	              || '                                      FROM sin_prof_profesionales spp ';

	    v_ttexto:=v_ttexto
	              || '                                     WHERE spp.sprofes = stg.sprofes), 1)) proveedor ';

	    v_ttexto:=v_ttexto
	              || '                    FROM sin_siniestro ss, sin_tramitacion st, sin_tramita_movimiento stm, ';

	    v_ttexto:=v_ttexto
	              || '                         sin_tramita_gestion stg, seguros s ';

	    v_ttexto:=v_ttexto
	              || '                   WHERE ss.sseguro = s.sseguro ';

	    v_ttexto:=v_ttexto
	              || '                     AND ss.nsinies = st.nsinies(+) ';

	    v_ttexto:=v_ttexto
	              || '                     AND(st.nsinies = stm.nsinies(+) ';

	    v_ttexto:=v_ttexto
	              || '                         AND st.ntramit = stm.ntramit(+) ';

	    v_ttexto:=v_ttexto
	              || '                         AND st.ntramit = (SELECT MAX(stm1.ntramit) ';

	    v_ttexto:=v_ttexto
	              || '                                             FROM sin_tramita_movimiento stm1 ';

	    v_ttexto:=v_ttexto
	              || '                                            WHERE stm1.nsinies = st.nsinies) ';

	    v_ttexto:=v_ttexto
	              || '                         AND stm.nmovtra = (SELECT MAX(stm2.nmovtra) ';

	    v_ttexto:=v_ttexto
	              || '                                              FROM sin_tramita_movimiento stm2 ';

	    v_ttexto:=v_ttexto
	              || '                                             WHERE stm2.nsinies = st.nsinies ';

	    v_ttexto:=v_ttexto
	              || '                                               AND stm2.ntramit = st.ntramit)) ';

	    v_ttexto:=v_ttexto
	              || '                     AND(st.ntramit = stg.ntramit(+) ';

	    v_ttexto:=v_ttexto
	              || '                         AND st.nsinies = stg.nsinies(+)) ';

	    IF p_proveedor IS NOT NULL THEN
	      v_ttexto:=v_ttexto
	                || '                     AND(stg.sprofes = '
	                || p_proveedor
	                || ')';
	    END IF;

	    IF p_ctramitad IS NOT NULL AND
	       p_cusuari IS NOT NULL THEN
	      v_ttexto:=v_ttexto
	                || '               AND  stm.ctramitad = (SELECT ctramitad ';

	      v_ttexto:=v_ttexto
	                || '                                       FROM sin_codtramitador scodtrm ';

	      v_ttexto:=v_ttexto
	                || '                                       WHERE scodtrm.cusuari = '
	                || chr(39)
	                || p_cusuari
	                || chr(39);

	      v_ttexto:=v_ttexto
	                || '                                         AND scodtrm.ctramitad ='
	                || chr(39)
	                || p_ctramitad
	                || chr(39)
	                || ')';
	    ELSIF p_ctramitad IS NOT NULL AND
	          p_cusuari IS NULL THEN
	      v_ttexto:=v_ttexto
	                || '                 AND stm.ctramitad = '
	                || chr(39)
	                || p_ctramitad
	                || chr(39);
	    ELSIF p_ctramitad IS NULL AND
	          p_cusuari IS NOT NULL THEN
	      v_ttexto:=v_ttexto
	                || '                 AND stm.ctramitad = (SELECT ctramitad ';

	      v_ttexto:=v_ttexto
	                || '                                        FROM sin_codtramitador scodtrm ';

	      v_ttexto:=v_ttexto
	                || '                                       WHERE scodtrm.cusuari = '
	                || chr(39)
	                || p_cusuari
	                || chr(39)
	                || ')';
	    END IF;

	    IF p_ccausin IS NOT NULL THEN
	      v_ttexto:=v_ttexto
	                || '                     AND ss.ccausin = '
	                || p_ccausin;
	    END IF;

	    v_ttexto:=v_ttexto
	              || '                     AND s.cidioma = '
	              || v_idioma;

	    IF p_asistencia IS NOT NULL THEN
	      v_ttexto:=v_ttexto
	                || '                  AND st.ctramit = NVL( CASE WHEN '
	                || p_asistencia
	                || ' = 1 THEN 15 ELSE NULL END, st.ctramit) ';
	    END IF;

	    IF p_sproduc IS NOT NULL THEN
	      v_ttexto:=v_ttexto
	                || '                     AND s.sproduc = '
	                || p_sproduc;
	    END IF;

	    IF p_ramo IS NOT NULL THEN
	      v_ttexto:=v_ttexto
	                || '                     AND s.cramo = '
	                || p_ramo;
	    END IF;

	    IF p_fradica_ini IS NOT NULL AND
	       p_fradica_fin IS NOT NULL THEN
	      v_ttexto:=v_ttexto
	                || '                     AND ss.falta BETWEEN TO_DATE('
	                || chr(39)
	                || p_fradica_ini
	                || chr(39)
	                || ', ''DDMMYYYY'') ';

	      v_ttexto:=v_ttexto
	                || '                                      AND TO_DATE('
	                || chr(39)
	                || p_fradica_fin
	                || chr(39)
	                || ', ''DDMMYYYY'') ';
	    END IF;

	    IF p_focurren_ini IS NOT NULL AND
	       p_focurren_fin IS NOT NULL THEN
	      v_ttexto:=v_ttexto
	                || '                     AND ss.fsinies BETWEEN TO_DATE('
	                || chr(39)
	                || p_focurren_ini
	                || chr(39)
	                || ', ''DDMMYYYY'') ';

	      v_ttexto:=v_ttexto
	                || '                                        AND TO_DATE('
	                || chr(39)
	                || p_focurren_fin
	                || chr(39)
	                || ', ''DDMMYYYY'') ';
	    END IF;

	    IF p_faviso_ini IS NOT NULL AND
	       p_faviso_fin IS NOT NULL THEN
	      v_ttexto:=v_ttexto
	                || '                     AND ss.fnotifi BETWEEN TO_DATE('
	                || chr(39)
	                || p_faviso_ini
	                || chr(39)
	                || ', ''DDMMYYYY'') ';

	      v_ttexto:=v_ttexto
	                || '                                        AND TO_DATE('
	                || chr(39)
	                || p_faviso_fin
	                || chr(39)
	                || ', ''DDMMYYYY'') ';
	    END IF;

	    IF p_fcontab_ini IS NOT NULL AND
	       p_fcontab_fin IS NOT NULL THEN
	      v_ttexto:=v_ttexto
	                || '                     AND((st.nsinies, st.ntramit) IN( ';

	      v_ttexto:=v_ttexto
	                || '                            SELECT str.nsinies, str.ntramit ';

	      v_ttexto:=v_ttexto
	                || '                              FROM sin_tramita_reserva str ';

	      v_ttexto:=v_ttexto
	                || '                             WHERE str.fcontab BETWEEN TO_DATE('
	                || chr(39)
	                || p_fcontab_ini
	                || chr(39)
	                || ', ''DDMMYYYY'') ';

	      v_ttexto:=v_ttexto
	                || '                                            AND TO_DATE('
	                || chr(39)
	                || p_fcontab_fin
	                || chr(39)
	                || ', ''DDMMYYYY'')) ';

	      v_ttexto:=v_ttexto
	                || '                         OR (SELECT COUNT(1) ';

	      v_ttexto:=v_ttexto
	                || '                               FROM sin_tramita_reserva str ';

	      v_ttexto:=v_ttexto
	                || '                              WHERE str.fcontab BETWEEN TO_DATE('
	                || chr(39)
	                || p_fcontab_ini
	                || chr(39)
	                || ', ''DDMMYYYY'') ';

	      v_ttexto:=v_ttexto
	                || '                                                    AND TO_DATE('
	                || chr(39)
	                || p_fcontab_fin
	                || chr(39)
	                || ', ''DDMMYYYY'')) > 0)';
	    END IF;

	    v_ttexto:=v_ttexto
	              || ')) q1 ';

	    IF p_departamento IS NOT NULL AND
	       p_ciudad IS NOT NULL THEN
	      v_ttexto:=v_ttexto
	                || '   WHERE t.cprovin = '
	                || p_departamento;

	      v_ttexto:=v_ttexto
	                || '     AND t.cpoblac = '
	                || p_ciudad;

	      v_ttexto:=v_ttexto
	                || '     AND t.nsinies(+) = q1.nsinies ';

	      v_ttexto:=v_ttexto
	                || '     AND t.ntramit(+) = q1.ntramit ';

	      v_ttexto:=v_ttexto
	                || '     AND t.nlocali(+) = q1.nlocali ';
	    ELSIF p_departamento IS NOT NULL AND
	          p_ciudad IS NULL THEN
	      v_ttexto:=v_ttexto
	                || '   WHERE t.cprovin = '
	                || p_departamento;

	      v_ttexto:=v_ttexto
	                || '     AND t.nsinies(+) = q1.nsinies ';

	      v_ttexto:=v_ttexto
	                || '     AND t.ntramit(+) = q1.ntramit ';

	      v_ttexto:=v_ttexto
	                || '     AND t.nlocali(+) = q1.nlocali ';
	    ELSIF p_departamento IS NULL AND
	          p_ciudad IS NOT NULL THEN
	      v_ttexto:=v_ttexto
	                || '   WHERE t.cpoblac = '
	                || p_ciudad;

	      v_ttexto:=v_ttexto
	                || '     AND t.nsinies(+) = q1.nsinies ';

	      v_ttexto:=v_ttexto
	                || '     AND t.ntramit(+) = q1.ntramit ';

	      v_ttexto:=v_ttexto
	                || '     AND t.nlocali(+) = q1.nlocali ';
	    ELSE
	      v_ttexto:=v_ttexto
	                || '   WHERE t.nsinies(+) = q1.nsinies ';

	      v_ttexto:=v_ttexto
	                || '     AND t.ntramit(+) = q1.ntramit ';

	      v_ttexto:=v_ttexto
	                || '     AND t.nlocali(+) = q1.nlocali ';
	    END IF;

	    v_ttexto:=v_ttexto
	              || 'ORDER BY q1.nsinies, q1.ntramit, nmovtra ';

	    RETURN to_clob(v_ttexto);
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list526_det;

	/* INI Bug 21838 - 14/05/2012 - JLTS*/
	/* INI Bug 22517  - 15/06/2012 - ETM*/
	FUNCTION f_list532_cab(
			p_sseguro	IN	NUMBER DEFAULT NULL,
			p_nriesgo	IN	NUMBER DEFAULT NULL,
			p_tablas	IN	VARCHAR DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list532_cab';
	  v_tparam  VARCHAR2(1000):=' sseguro='
	                           || p_sseguro
	                           || ' nriesgo='
	                           || p_nriesgo
	                           || ' tablas='
	                           || p_tablas;
	  v_ntraza  NUMBER:=0;
	  v_idioma  NUMBER;
	  verror    NUMBER;
	  v_sep     VARCHAR2(1):=';';

	  CURSOR cab_est IS
	    SELECT DISTINCT d.cconcep,d.ccampo,d.norden
	      FROM detgaranformula d,estseguros s
	     WHERE s.sseguro=p_sseguro AND
	           s.sproduc=d.sproduc
	     ORDER BY decode(d.ccampo, 'TASA', 1,
	                               2),d.norden;

	  CURSOR cab_real IS
	    SELECT DISTINCT d.cconcep,d.ccampo,d.norden
	      FROM detgaranformula d,seguros s
	     WHERE s.sseguro=p_sseguro AND
	           s.sproduc=d.sproduc
	     ORDER BY decode(d.ccampo, 'TASA', 1,
	                               2),d.norden;
	BEGIN
	    v_ntraza:=1000;

	    v_ttexto:=NULL;

	    IF p_tablas='EST' THEN
	      v_ttexto:=v_ttexto
	                || 'GARANTIA '
	                || v_sep
	                || 'DESCRIPCION '
	                || v_sep;

	      FOR reg IN cab_est LOOP
	          v_ttexto:=v_ttexto
	                    || reg.cconcep
	                    || v_sep;
	      END LOOP;
	    ELSE
	      v_ttexto:=v_ttexto
	                || 'GARANTIA '
	                || v_sep
	                || 'DESCRIPCION '
	                || v_sep;

	      FOR reg IN cab_real LOOP
	          v_ttexto:=v_ttexto
	                    || reg.cconcep
	                    || v_sep;
	      END LOOP;
	    END IF;

	    IF nvl(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'LIST_IMP_DETPRIMAS'), 0)=1 THEN
	      v_ttexto:=v_ttexto
	                || f_axis_literales(100916, pac_md_common.f_get_cxtidioma())
	                || v_sep;

	      v_ttexto:=v_ttexto
	                || f_axis_literales(1000341, pac_md_common.f_get_cxtidioma())
	                || v_sep;

	      v_ttexto:=v_ttexto
	                || f_axis_literales(1000253, pac_md_common.f_get_cxtidioma())
	                || v_sep;

	      v_ttexto:=v_ttexto
	                || f_axis_literales(9903065, pac_md_common.f_get_cxtidioma())
	                || v_sep;

	      v_ttexto:=v_ttexto
	                || f_axis_literales(101705, pac_md_common.f_get_cxtidioma())
	                || v_sep;
	    END IF;

	    RETURN upper(v_ttexto);
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN NULL;
	END f_list532_cab;
	FUNCTION f_list532_det(
			p_sseguro	IN	NUMBER DEFAULT NULL,
			p_nriesgo	IN	NUMBER DEFAULT NULL,
			p_tablas	IN	VARCHAR DEFAULT NULL
	) RETURN CLOB
	IS
	  v_tobjeto    VARCHAR2(500):='PAC_INFORMES.f_list532_det';
	  v_tparam     VARCHAR2(1000):=' sseguro='
	                           || p_sseguro
	                           || ' nriesgo='
	                           || p_nriesgo
	                           || ' tablas='
	                           || p_tablas;
	  v_ntraza     NUMBER:=0;
	  v_idioma     NUMBER;
	  verror       NUMBER;
	  v_sep        VARCHAR2(1):=';';
	  v_gartexto   VARCHAR2(32000);
	  v_iconcep    NUMBER;
	  v_garant     NUMBER;
	  v_descgarant VARCHAR2(150);
	  prima        OB_IAX_PRIMAS:=NEW ob_iax_primas();

	  CURSOR garan_est IS
	    SELECT g.sseguro,g.cgarant,g.nmovimi,g.nriesgo,s.sproduc
	      FROM estgaranseg g,estseguros s
	     WHERE g.sseguro=p_sseguro AND
	           s.sseguro=g.sseguro AND
	           g.nriesgo=nvl(p_nriesgo, g.nriesgo) AND
	           g.ffinefe IS NULL AND
	           EXISTS(SELECT 1
	                    FROM estdetprimas
	                   WHERE sseguro=g.sseguro AND
	                         nmovimi=g.nmovimi AND
	                         nriesgo=g.nriesgo AND
	                         cgarant=g.cgarant)
	     ORDER BY g.sseguro,g.cgarant;

	  CURSOR garan_real IS
	    SELECT g.sseguro,g.cgarant,g.nmovimi,g.nriesgo,s.sproduc
	      FROM garanseg g,seguros s
	     WHERE g.sseguro=p_sseguro AND
	           s.sseguro=g.sseguro AND
	           g.nriesgo=nvl(p_nriesgo, g.nriesgo) AND
	           g.ffinefe IS NULL AND
	           EXISTS(SELECT 1
	                    FROM detprimas
	                   WHERE sseguro=g.sseguro AND
	                         nmovimi=g.nmovimi AND
	                         nriesgo=g.nriesgo AND
	                         cgarant=g.cgarant)
	     ORDER BY g.sseguro,g.cgarant;

	  CURSOR concep_real IS
	    SELECT DISTINCT d.cconcep,d.ccampo,d.norden
	      FROM detgaranformula d,seguros s
	     WHERE s.sseguro=p_sseguro AND
	           s.sproduc=d.sproduc
	     ORDER BY decode(d.ccampo, 'TASA', 1,
	                               2),d.norden;

	  CURSOR concep_est IS
	    SELECT DISTINCT d.cconcep,d.ccampo,d.norden
	      FROM detgaranformula d,estseguros s
	     WHERE s.sseguro=p_sseguro AND
	           s.sproduc=d.sproduc
	     ORDER BY decode(d.ccampo, 'TASA', 1,
	                               2),d.norden;
	BEGIN
	    v_ntraza:=1000;

	    v_ttexto:=NULL;

	    IF p_tablas='EST' THEN
	      v_ntraza:=1;

	      FOR reg1 IN garan_est LOOP
	          v_ttexto:=NULL;

	          FOR reg2 IN concep_est LOOP
	              BEGIN
	                  SELECT cgarant,iconcep
	                    INTO v_garant, v_iconcep
	                    FROM estdetprimas
	                   WHERE sseguro=p_sseguro AND
	                         cgarant=reg1.cgarant AND
	                         nmovimi=reg1.nmovimi AND
	                         nriesgo=reg1.nriesgo AND
	                         cconcep=reg2.cconcep;

	                  v_ntraza:=2;

	                  v_ttexto:=v_ttexto
	                            || replace (nvl (replace (trim(to_char(v_iconcep, '99999999999999999999999999999999.999999')), '.000000', ''), 0), '.', ',')
	                            || v_sep;
	              EXCEPTION
	                  WHEN no_data_found THEN
	                    v_ttexto:=v_ttexto
	                              || '0'
	                              || v_sep;
	              END;
	          END LOOP;

	          IF nvl(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'LIST_IMP_DETPRIMAS'), 0)=1 THEN
	            prima:=NEW ob_iax_primas();

	            prima.needtarifar:=0;

	            pac_mdobj_prod.p_get_prigarant(prima, p_sseguro, reg1.nmovimi, 'EST', reg1.nriesgo, reg1.cgarant, 0, 0);

	            v_ttexto:=v_ttexto
	                      || replace (nvl (replace(trim(to_char(prima.iconsor, '99999999999999999999999999999999.999999')), '.000000', ''), 0), '.', ',')
	                      || v_sep;

	            v_ttexto:=v_ttexto
	                      || replace (nvl (replace(trim(to_char(prima.irecfra, '99999999999999999999999999999999.999999')), '.000000', ''), 0), '.', ',')
	                      || v_sep;

	            v_ttexto:=v_ttexto
	                      || replace (nvl (replace(trim(to_char(prima.iips, '99999999999999999999999999999999.999999')), '.000000', ''), 0), '.', ',')
	                      || v_sep;

	            v_ttexto:=v_ttexto
	                      || replace (nvl (replace(trim(to_char(prima.idgs, '99999999999999999999999999999999.999999')), '.000000', ''), 0), '.', ',')
	                      || v_sep;

	            v_ttexto:=v_ttexto
	                      || replace (nvl (replace(trim(to_char(prima.iarbitr, '99999999999999999999999999999999.999999')), '.000000', ''), 0), '.', ',')
	                      || v_sep;
	          END IF;

	          v_ntraza:=3;

	          v_descgarant:=ff_desgarantia(reg1.cgarant, pac_md_common.f_get_cxtidioma);

	          v_gartexto:=v_gartexto
	                      || chr(10)
	                      || reg1.cgarant
	                      || v_sep
	                      || v_descgarant
	                      || v_sep
	                      || v_ttexto;
	      END LOOP;
	    ELSE
	      v_ntraza:=4;

	      FOR reg1 IN garan_real LOOP
	          v_ttexto:=NULL;

	          FOR reg2 IN concep_real LOOP
	              BEGIN
	                  SELECT cgarant,iconcep
	                    INTO v_garant, v_iconcep
	                    FROM detprimas
	                   WHERE sseguro=p_sseguro AND
	                         cgarant=reg1.cgarant AND
	                         nmovimi=reg1.nmovimi AND
	                         nriesgo=reg1.nriesgo AND
	                         cconcep=reg2.cconcep;

	                  v_ntraza:=5;

	                  v_ttexto:=v_ttexto
	                            || replace (nvl (replace (trim(to_char(v_iconcep, '99999999999999999999999999999999.999999')), '.000000', ''), 0), '.', ',')
	                            || v_sep;
	              EXCEPTION
	                  WHEN no_data_found THEN
	                    v_ttexto:=v_ttexto
	                              || '0'
	                              || v_sep;
	              END;
	          END LOOP;

	          IF nvl(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'LIST_IMP_DETPRIMAS'), 0)=1 THEN
	            prima:=NEW ob_iax_primas();

	            prima.needtarifar:=0;

	            pac_mdobj_prod.p_get_prigarant(prima, p_sseguro, reg1.nmovimi, 'POL', reg1.nriesgo, reg1.cgarant, 0, 0);

	            v_ttexto:=v_ttexto
	                      || replace (nvl (replace(trim(to_char(prima.iconsor, '99999999999999999999999999999999.999999')), '.000000', ''), 0), '.', ',')
	                      || v_sep;

	            v_ttexto:=v_ttexto
	                      || replace (nvl (replace(trim(to_char(prima.irecfra, '99999999999999999999999999999999.999999')), '.000000', ''), 0), '.', ',')
	                      || v_sep;

	            v_ttexto:=v_ttexto
	                      || replace (nvl (replace(trim(to_char(prima.iips, '99999999999999999999999999999999.999999')), '.000000', ''), 0), '.', ',')
	                      || v_sep;

	            v_ttexto:=v_ttexto
	                      || replace (nvl (replace(trim(to_char(prima.idgs, '99999999999999999999999999999999.999999')), '.000000', ''), 0), '.', ',')
	                      || v_sep;

	            v_ttexto:=v_ttexto
	                      || replace (nvl (replace(trim(to_char(prima.iarbitr, '99999999999999999999999999999999.999999')), '.000000', ''), 0), '.', ',')
	                      || v_sep;
	          END IF;

	          v_ntraza:=6;

	          v_descgarant:=ff_desgarantia(reg1.cgarant, pac_md_common.f_get_cxtidioma);

	          v_gartexto:=v_gartexto
	                      || chr(10)
	                      || reg1.cgarant
	                      || v_sep
	                      || v_descgarant
	                      || v_sep
	                      || v_ttexto;
	      END LOOP;
	    END IF;

	    RETURN to_clob(v_gartexto);
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list532_det;

	/* FIN Bug 22517  - 15/06/2012 - ETM*/
	FUNCTION f_list344_cab(
			p_cidioma NUMBER DEFAULT NULL,
			p_cempres NUMBER DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list344_cab';
	  v_tparam  VARCHAR2(1000);
	  v_ntraza  NUMBER:=0;
	  v_sep     VARCHAR2(1):=';';
	  v_ret     VARCHAR2(1):=chr(10);
	  v_init    VARCHAR2(32000);
	  v_ttexto  VARCHAR2(32000);
	BEGIN
	    v_ttexto:='select  '' '' || f_axis_literales(9001875,'
	              || p_cidioma
	              || ') || '';'' ||
	                    f_axis_literales(101168,'
	              || p_cidioma
	              || ') || '';'' ||
	                    f_axis_literales(100883,'
	              || p_cidioma
	              || ') || '' '' ||  f_axis_literales(9001875,'
	              || p_cidioma
	              || ') || '';''||
	                    f_axis_literales(109716,'
	              || p_cidioma
	              || ')|| '';''||';

	    v_ttexto:=v_ttexto
	              || ' f_axis_literales(103313,'
	              || p_cidioma
	              || ') || '';''||';

	    v_ttexto:=v_ttexto
	              || ' f_axis_literales(101516,'
	              || p_cidioma
	              || ') || '';''||';

	    v_ttexto:=v_ttexto
	              || ' f_axis_literales(101619,'
	              || p_cidioma
	              || ') || '';''||';

	    v_ttexto:=v_ttexto
	              || ' f_axis_literales(100895,'
	              || p_cidioma
	              || ') || '';''||';

	    IF nvl(pac_parametros.f_parlistado_n(p_cempres, 'MONEDAINFORME'), 0)=1 THEN
	      v_ttexto:=v_ttexto
	                || ' f_axis_literales(9902210,'
	                || p_cidioma
	                || ') || '';''||';

	      v_ttexto:=v_ttexto
	                || ' f_axis_literales(9901501,'
	                || p_cidioma
	                || ') || '';''||';
	    END IF;

	    v_ttexto:=v_ttexto
	              || ' f_axis_literales(100584,'
	              || p_cidioma
	              || ') || '';''||';

	    v_ttexto:=v_ttexto
	              || ' f_axis_literales(100883,'
	              || p_cidioma
	              || ') || '' ''||';

	    v_ttexto:=v_ttexto
	              || ' f_axis_literales(100895,'
	              || p_cidioma
	              || ') || '';''||';

	    v_ttexto:=v_ttexto
	              || ' f_axis_literales(1000562,'
	              || p_cidioma
	              || ') || '' ''||';

	    v_ttexto:=v_ttexto
	              || ' f_axis_literales(100895,'
	              || p_cidioma
	              || ') || '';''||';

	    v_ttexto:=v_ttexto
	              || ' f_axis_literales(100885,'
	              || p_cidioma
	              || ') || '' ''||';

	    v_ttexto:=v_ttexto
	              || ' f_axis_literales(100895,'
	              || p_cidioma
	              || ') || '';''||';

	    IF nvl(pac_parametros.f_parlistado_n(p_cempres, 'MONEDAINFORME'), 0)=1 THEN
	      v_ttexto:=v_ttexto
	                || ' f_axis_literales(9906064,'
	                || p_cidioma
	                || ') || '';''||';
	    ELSE
	      v_ttexto:=v_ttexto
	                || ' f_axis_literales(102302,'
	                || p_cidioma
	                || ') || '';''||';
	    END IF;

	    v_ttexto:=v_ttexto
	              || ' f_axis_literales(9000842,'
	              || p_cidioma
	              || ') || '';''||';

	    v_ttexto:=v_ttexto
	              || ' f_axis_literales(100563,'
	              || p_cidioma
	              || ') || '';''||';

	    IF nvl(pac_parametros.f_parlistado_n(p_cempres, 'PRIMAEMITIDA_344'), 0)=1 THEN
	      v_ttexto:=v_ttexto
	                || ' f_axis_literales(9905567,'
	                || p_cidioma
	                || ') || '';''||';
	    END IF;

	    IF nvl(pac_parametros.f_parlistado_n(p_cempres, 'RECARGOFRACC_344'), 0)=1 THEN
	      v_ttexto:=v_ttexto
	                || ' f_axis_literales(9905568,'
	                || p_cidioma
	                || ') || '';''||';
	    END IF;

	    IF nvl(pac_parametros.f_parlistado_n(p_cempres, 'RECARGORIESGOS_344'), 0)=1 THEN
	      v_ttexto:=v_ttexto
	                || ' f_axis_literales(9905569,'
	                || p_cidioma
	                || ') || '';''||';
	    END IF;

	    IF nvl(pac_parametros.f_parlistado_n(p_cempres, 'RECARGOLIQUID_344'), 0)=1 THEN
	      v_ttexto:=v_ttexto
	                || ' f_axis_literales(9905570,'
	                || p_cidioma
	                || ') || '';''||';
	    END IF;

	    IF nvl(pac_parametros.f_parlistado_n(p_cempres, 'IMPPRIMASSEGUROS_344'), 0)=1 THEN
	      v_ttexto:=v_ttexto
	                || ' f_axis_literales(9905571,'
	                || p_cidioma
	                || ') || '';''||';
	    END IF;

	    IF nvl(pac_parametros.f_parlistado_n(p_cempres, 'PRIMAREASEGUROC_344'), 0)=1 THEN
	      v_ttexto:=v_ttexto
	                || ' f_axis_literales(9905572,'
	                || p_cidioma
	                || ') || '';''||';
	    END IF;

	    IF nvl(pac_parametros.f_parlistado_n(p_cempres, 'COMISIONPRIMAVID_344'), 0)=1 THEN
	      v_ttexto:=v_ttexto
	                || ' f_axis_literales(9905573,'
	                || p_cidioma
	                || ') || '';''||';
	    END IF;

	    IF nvl(pac_parametros.f_parlistado_n(p_cempres, 'OTROSRECARGOS_344'), 0)=1 THEN
	      v_ttexto:=v_ttexto
	                || ' f_axis_literales(9905574,'
	                || p_cidioma
	                || ') || '';''||';
	    END IF;

	    v_ttexto:=v_ttexto
	              || ' f_axis_literales(1000553,'
	              || p_cidioma
	              || ') || '';''||';

	    v_ttexto:=v_ttexto
	              || ' f_axis_literales(100874,'
	              || p_cidioma
	              || ') || '' '' || f_axis_literales(9001875,'
	              || p_cidioma
	              || ') || '';''||';

	    IF nvl(pac_parametros.f_parlistado_n(p_cempres, 'PRIMADEV_344'), 0)=1 THEN
	      v_ttexto:=v_ttexto
	                || ' f_axis_literales(9904028,'
	                || p_cidioma
	                || ') || '';''||';
	    END IF;

	    IF p_cempres=5 THEN
	      v_ttexto:=v_ttexto
	                || ' f_axis_literales(9901743,'
	                || p_cidioma
	                || ') || '';''||';
	    END IF;

	    IF nvl(pac_parametros.f_parlistado_n(p_cempres, 'VER_FONDO_ENMAPS'), 0)=1 THEN
	      v_ttexto:=v_ttexto
	                || ' f_axis_literales(1000179,'
	                || p_cidioma
	                || ') || '';''||';
	    END IF;

	    IF nvl(pac_parametros.f_parlistado_n(p_cempres, 'VER_FECHACOB_ENMAPS'), 0)=1 THEN
	      v_ttexto:=v_ttexto
	                || ' f_axis_literales(9000805,'
	                || p_cidioma
	                || ') || '' '' || f_axis_literales(100895,'
	                || p_cidioma
	                || ') || '';''||';
	    END IF;

	    IF nvl(pac_parametros.f_parlistado_n(p_cempres, 'MONEDAINFORME'), 0)=1 THEN
	      v_ttexto:=v_ttexto
	                || ' f_axis_literales(108645,'
	                || p_cidioma
	                || ') || '';''||';
	    END IF;

	    v_ttexto:=v_ttexto
	              || ''' '' linea from dual ';

	    RETURN(v_ttexto);
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list344_cab;
	FUNCTION f_list344_det(
			p_cidioma NUMBER,
			p_cempres NUMBER,
			p_cestrec	IN	NUMBER DEFAULT NULL,
			p_fechadesde	IN	NUMBER DEFAULT NULL,
			p_fechahasta	IN	NUMBER DEFAULT NULL,
			p_ctiprec	IN	NUMBER DEFAULT NULL,
			p_cagente	IN	NUMBER DEFAULT NULL,
			p_cestado	IN	NUMBER DEFAULT NULL,
			p_cfiltro	IN	NUMBER DEFAULT NULL,
			p_compani	IN	NUMBER DEFAULT NULL,
			p_sproduc	IN	NUMBER DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list344_det';
	  v_tparam  VARCHAR2(1000);
	  v_ntraza  NUMBER:=0;
	  v_sep     VARCHAR2(1):=';';
	  v_ret     VARCHAR2(1):=chr(10);
	  v_init    VARCHAR2(32000);
	  v_ttexto  VARCHAR2(32000);
	  /*BUG 0036231-205726 KJSC Listado administraciòn 27/05/2015*/
	  v_where   VARCHAR2(32000);
	BEGIN
	    /*Bug 0027666-XVM-01/08/2013*/
	    v_ttexto:='SELECT se.npoliza ||  '';'' || se.ncertif || '';'' ||  se.fefecto || '';'' || se.fcarpro || '';''
	       || ff_desvalorfijo(17,'
	              || p_cidioma
	              || ', se.cforpag) || '';''
	       || ff_desvalorfijo(1026,'
	              || p_cidioma
	              || ', NVL(m.ctipcob, nvl(re.ctipcob, nvl(se.ctipcob, 2)))) || '';'' || e.tempres|| '';''
	       || re.nrecibo|| '';'' || ';

	    IF nvl(pac_parametros.f_parlistado_n(p_cempres, 'MONEDAINFORME'), 0)=1 THEN
	      v_ttexto:=v_ttexto
	                || ' (SELECT pac_isqlfor.f_persona (ss.sseguro, 1) FROM seguros ss WHERE ss.npoliza = se.npoliza AND ss.ncertif = 0) || '';'' || ';

	      v_ttexto:=v_ttexto
	                || ' (pac_isqlfor.f_persona(se.sseguro, 2)) || '';'' || ';
	    END IF;

	    v_ttexto:=v_ttexto
	              || 'ff_desagente(re.cagente) || '';'' || re.fefecto || '';''
	         || re.femisio || '';'' || re.fvencim || '';'' || ';

	    IF nvl(pac_parametros.f_parlistado_n(p_cempres, 'MONEDAINFORME'), 0)=1 THEN
	      v_ttexto:=v_ttexto
	                || 'pac_propio_ensa.f_get_lit_cont(re.ctiprec, re.ctipapor, re.ctipaportante, 2)';
	    ELSE
	      v_ttexto:=v_ttexto
	                || 'ff_desvalorfijo(8,'
	                || p_cidioma
	                || ', re.ctiprec)';
	    END IF;

	    /*BUG 0036231-205726 KJSC Listado administraciòn para que filtre por fechas 27/05/2015*/
	    IF p_cfiltro=0 THEN
	      v_where:='re.fefecto >= NVL(TO_DATE(LTRIM(TO_CHAR('
	               || p_fechadesde
	               || ', ''09999999'')), ''ddmmrrrr''), re.fefecto)
	                     AND re.fefecto <= NVL(TO_DATE(LTRIM(TO_CHAR('
	               || p_fechahasta
	               || ', ''09999999'')), ''ddmmrrrr''), re.fefecto)';
	    ELSIF p_cfiltro=1 THEN
	      /* bug 36231-0207147  09/06/2015*/
	      v_where:='trunc(m.fmovdia) >= NVL(TO_DATE(LTRIM(TO_CHAR('
	               || p_fechadesde
	               || ', ''09999999'')), ''ddmmrrrr''), trunc(m.fmovdia))
	                     AND trunc(m.fmovdia) <= NVL(TO_DATE(LTRIM(TO_CHAR('
	               || p_fechahasta
	               || ', ''09999999'')), ''ddmmrrrr''), trunc(m.fmovdia))';
	    ELSIF p_cfiltro=2 THEN
	      v_where:='m.fcontab >= NVL(TO_DATE(LTRIM(TO_CHAR('
	               || p_fechadesde
	               || ', ''09999999'')), ''ddmmrrrr''), m.fcontab)
	                     AND m.fcontab <= NVL(TO_DATE(LTRIM(TO_CHAR('
	               || p_fechahasta
	               || ', ''09999999'')), ''ddmmrrrr''), m.fcontab)';
	    END IF;

	    v_ttexto:=v_ttexto
	              || ' || '';'' || (SELECT COUNT(*)
	                    FROM movrecibo
	                   WHERE (cestrec = 0
	                          AND cestant = 1)
	                     AND nrecibo = re.nrecibo) || '';'' || v.itotalr || '';'' ||
	        DECODE(NVL(pac_parametros.f_parlistado_n('
	              || p_cempres
	              || ', ''PRIMAEMITIDA_344''), 0),
	                 1, det.iprinet || '';''
	                 ,NULL) ||
	       DECODE(NVL(pac_parametros.f_parlistado_n('
	              || p_cempres
	              || ', ''RECARGOFRACC_344''), 0),
	                 1, det.irecfra || '';'',
	                 NULL)  ||
	       DECODE(NVL(pac_parametros.f_parlistado_n('
	              || p_cempres
	              || ', ''RECARGORIESGOS_344''), 0),
	                 1, det.iconsor || '';'',
	                 NULL) ||
	       DECODE(NVL(pac_parametros.f_parlistado_n('
	              || p_cempres
	              || ', ''RECARGOLIQUID_344''), 0),
	                 1, det.idgs || '';'',
	                 NULL) ||
	       DECODE(NVL(pac_parametros.f_parlistado_n('
	              || p_cempres
	              || ', ''IMPPRIMASSEGUROS_344''), 0),
	                 1, det.iips || '';'',
	                 NULL) ||
	 DECODE (NVL(pac_parametros.f_parlistado_n('
	              || p_cempres
	              || ', ''PRIMAREASEGUROC_344''), 0),1 ,
	        (select sum(icesion) || '';''
	        from reasegemi r, detreasegemi d
	        where cmotces = 1
	        and nrecibo = re.nrecibo
	        and r.sreaemi = d.sreaemi
	        ),NULL)  ||
	       DECODE(NVL(pac_parametros.f_parlistado_n('
	              || p_cempres
	              || ', ''COMISIONPRIMAVID_344''), 0),
	                 1, det.icombru - det.icomret || '';'',
	                 NULL) ||
	       DECODE(NVL(pac_parametros.f_parlistado_n('
	              || p_cempres
	              || ', ''OTROSRECARGOS_344''), 0),
	                 1, det.iderreg + det.icomret || '';'',
	                 NULL)
	       || ff_desvalorfijo(1,'
	              || p_cidioma
	              || ', f_cestrec(re.nrecibo, f_sysdate)) || '';''
	       || ff_desvalorfijo(61,'
	              || p_cidioma
	              || ', se.csituac) || '';''
	       || DECODE(NVL(pac_parametros.f_parlistado_n('
	              || p_cempres
	              || ', ''PRIMADEV_344''), 0),
	                 1, v.ipridev || '';'',
	                 NULL)
	        || DECODE(NVL(pac_parametros.f_parlistado_n('
	              || p_cempres
	              || ', ''VER_FONDO_ENMAPS''), 0),
	                  0, NULL,
	                  f_desproducto_t(se.cramo, se.cmodali, se.ctipseg, se.ccolect, 1,'
	              || p_cidioma
	              || ') || '';'')
	        || DECODE
	                (NVL(pac_parametros.f_parlistado_n('
	              || p_cempres
	              || ', ''VER_FECHACOB_ENMAPS''),
	                     0),
	                 0, NULL,
	                 DECODE(f_cestrec(re.nrecibo, f_sysdate), 1, TRUNC(m.fmovini) || '';'', '';''))
	        || DECODE
	                (NVL(pac_parametros.f_parlistado_n('
	              || p_cempres
	              || ', ''MONEDAINFORME''),
	                     0),
	                 0, NULL,
	                 pac_eco_monedas.f_obtener_moneda_informe(null, se.sproduc) || '';'') linea
	  FROM seguros se,
	       agentes_agente a,
	       recibos re,
	       movrecibo m,
	       (SELECT nrecibo, ipridev, itotalr
	          FROM vdetrecibos
	         WHERE NVL(pac_parametros.f_parempresa_n('
	              || p_cempres
	              || ', ''MULTIMONEDA''), 0) = 0
	        UNION
	        SELECT nrecibo, ipridev, itotalr
	          FROM vdetrecibos_monpol
	         WHERE NVL(pac_parametros.f_parempresa_n('
	              || p_cempres
	              || ', ''MULTIMONEDA''), 0) = 1
	          AND NVL(pac_parametros.f_parlistado_n('
	              || p_cempres
	              || ', ''MONEDAINFORME''), 0) = 0
	        UNION
	        SELECT nrecibo, ipridev, itotalr
	          FROM vdetrecibos
	         WHERE NVL(pac_parametros.f_parlistado_n('
	              || p_cempres
	              || ', ''MONEDAINFORME''), 0) = 1) v,
	         vdetrecibos det,
	       empresas e
	 WHERE se.sseguro = re.sseguro
	   AND se.sproduc = NVL('''
	              || p_sproduc
	              || ''', se.sproduc)
	   AND re.nrecibo = m.nrecibo
	   AND v.nrecibo = m.nrecibo
	   AND v.nrecibo =  det.nrecibo
	   AND m.fmovfin IS NULL
	   AND re.cagente = a.cagente
	   AND re.cempres = a.cempres
	   AND(re.cagente, re.cempres)
	   IN(
	         SELECT rc.cagente, rc.cempres
	           FROM (SELECT     rc.cagente, rc.cempres
	                       FROM redcomercial rc
	                      WHERE rc.fmovfin IS NULL
	                 START WITH rc.cagente =
	                               NVL('''
	              || p_cagente
	              || ''',
	                                   ff_agente_cpolvisio(pac_user.ff_get_cagente(f_user)))
	                 CONNECT BY PRIOR rc.cagente = rc.cpadre
	                        AND PRIOR rc.fmovfin IS NULL) rc,
	                agentes_agente_pol a
	          WHERE rc.cagente = a.cagente)
	            AND '
	              || v_where
	              || '
	            AND re.ctiprec = NVL('''
	              || p_ctiprec
	              || ''', re.ctiprec)
	            AND f_cestrec_mv(re.nrecibo, '
	              || p_cidioma
	              || ',f_sysdate) = NVL('''
	              || p_cestrec
	              || ''', f_cestrec_mv(re.nrecibo,'
	              || p_cidioma
	              || ',f_sysdate))
	            AND se.csituac = NVL('''
	              || p_cestado
	              || ''', se.csituac)
	            AND re.cempres = '
	              || p_cempres
	              || 'AND e.cempres = re.cempres';

	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list344_det;
	FUNCTION f_ins_codiplantilla(
			pccodplan	IN	codiplantillas.ccodplan%TYPE,
			pidconsulta	IN	codiplantillas.idconsulta%TYPE,
			pgedox	IN	codiplantillas.gedox%TYPE,
			pidcat	IN	codiplantillas.idcat%TYPE,
			pcgenfich	IN	codiplantillas.cgenfich%TYPE DEFAULT NULL,
			pcgenpdf	IN	codiplantillas.cgenpdf%TYPE DEFAULT NULL,
			pcgenrep	IN	codiplantillas.cgenrep%TYPE DEFAULT NULL,
			pctipodoc	IN	codiplantillas.ctipodoc%TYPE DEFAULT NULL,
			pcfdigital	IN	codiplantillas.cfdigital%TYPE DEFAULT NULL
	) RETURN NUMBER
	IS
	  vpasexec NUMBER;
	  vparam   VARCHAR2(500):='parametros pccodplan='
	                        || pccodplan
	                        || ' pidconsulta='
	                        || pidconsulta
	                        || ' pgedox='
	                        || pgedox
	                        || ' pidcat='
	                        || pidcat
	                        || ' pcgenfich='
	                        || pcgenfich
	                        || ' pcgenpdf='
	                        || pcgenpdf
	                        || ' pcgenrep='
	                        || pcgenrep
	                        || ' pctipodoc='
	                        || pctipodoc
	                        || ' pcfdigital='
	                        || pcfdigital;
	BEGIN
	    vpasexec:=1;

			INSERT INTO codiplantillas
		           (ccodplan,idconsulta,gedox,idcat,cgenfich,cgenpdf,
		           cgenrep,ctipodoc,cfdigital)
		    VALUES
		           (pccodplan,pidconsulta,pgedox,pidcat,pcgenfich,pcgenpdf,
		           pcgenrep,pctipodoc,pcfdigital);


	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_informes.f_ins_codiplantilla', vpasexec, vparam, 'SQLERROR: '
	                                                                                                  || SQLCODE
	                                                                                                  || ' - '
	                                                                                                  || SQLERRM);

	             RETURN 1;
	END f_ins_codiplantilla;
	FUNCTION f_ins_detplantillas(
			pccodplan	IN	detplantillas.ccodplan%TYPE,
			pcidioma	IN	detplantillas.cidioma%TYPE,
			ptdescrip	IN	detplantillas.tdescrip%TYPE,
			pcinforme	IN	detplantillas.cinforme%TYPE,
			pcpath	IN	detplantillas.cpath%TYPE,
			pcmapead	IN	detplantillas.cmapead%TYPE DEFAULT NULL,
			pcfirma	IN	detplantillas.cfirma%TYPE DEFAULT 0,
			ptconfirma	IN	detplantillas.tconffirma%TYPE DEFAULT NULL
	) RETURN NUMBER
	IS
	  vpasexec NUMBER;
	  vparam   VARCHAR2(500):='parametros pccodplan='
	                        || pccodplan
	                        || ' pcidioma='
	                        || pcidioma
	                        || ' ptdescrip='
	                        || ptdescrip
	                        || ' ptdescrip='
	                        || ptdescrip
	                        || ' pcinforme='
	                        || pcinforme
	                        || ' pcpath='
	                        || pcpath
	                        || ' pcfirma='
	                        || pcfirma
	                        || ' ptconfirma='
	                        || ptconfirma;
	BEGIN
	    vpasexec:=1;

			INSERT INTO detplantillas
		           (ccodplan,cidioma,tdescrip,cinforme,cpath,cmapead,
		           cfirma,tconffirma)
		    VALUES
		           (pccodplan,pcidioma,ptdescrip,pcinforme,pcpath,pcmapead,
		           pcfirma,ptconfirma);


	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_informes.f_ins_detplantilla', vpasexec, vparam, 'SQLERROR: '
	                                                                                                 || SQLCODE
	                                                                                                 || ' - '
	                                                                                                 || SQLERRM);

	             RETURN 1;
	END f_ins_detplantillas;
	FUNCTION f_ins_cfglanzarinformes(
			pcempres	IN	cfg_lanzar_informes.cempres%TYPE,
			pcform	IN	cfg_lanzar_informes.cform%TYPE,
			pcmap	IN	cfg_lanzar_informes.cmap%TYPE,
			ptevento	IN	cfg_lanzar_informes.tevento%TYPE,
			psproduc	IN	cfg_lanzar_informes.sproduc%TYPE,
			pslitera	IN	cfg_lanzar_informes.slitera%TYPE,
			plparams	IN	cfg_lanzar_informes.lparams%TYPE,
			pgenerareport	IN	cfg_lanzar_informes.genera_report%TYPE,
			pccfgform	IN	cfg_lanzar_informes.ccfgform%TYPE,
			plexport	IN	cfg_lanzar_informes.lexport%TYPE,
			pctipo	IN	cfg_lanzar_informes.ctipo%TYPE
	) RETURN NUMBER
	IS
	  vpasexec NUMBER;
	  vparam   VARCHAR2(500):='parametros pcempres='
	                        || pcempres
	                        || ' pcform = '
	                        || pcform
	                        || ' pcmap='
	                        || pcmap
	                        || ' ptevento='
	                        || ptevento
	                        || ' psproduc='
	                        || psproduc
	                        || ' pslitera='
	                        || pslitera
	                        || ' plparams='
	                        || plparams
	                        || ' pgenerareport='
	                        || pgenerareport
	                        || ' pccfgform='
	                        || pccfgform
	                        || ' plexport='
	                        || plexport
	                        || ' pctipo='
	                        || pctipo;
	BEGIN
	    vpasexec:=1;

			INSERT INTO cfg_lanzar_informes
		           (cempres,cform,cmap,tevento,sproduc,slitera,
		           lparams,genera_report,ccfgform,lexport,ctipo)

		    VALUES
		           (pcempres,pcform,pcmap,ptevento,psproduc,pslitera,
		           plparams,pgenerareport,pccfgform,plexport,pctipo);


	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_informes.f_ins_cfglanzarinformes', vpasexec, vparam, 'SQLERROR: '
	                                                                                                      || SQLCODE
	                                                                                                      || ' - '
	                                                                                                      || SQLERRM);

	             RETURN 1;
	END f_ins_cfglanzarinformes;
	FUNCTION f_upd_cfglanzarinformes(
			pcempres	IN	cfg_lanzar_informes.cempres%TYPE,
			pcmap	IN	cfg_lanzar_informes.cmap%TYPE,
			ptevento	IN	cfg_lanzar_informes.tevento%TYPE,
			psproduc	IN	cfg_lanzar_informes.sproduc%TYPE,
			pccfgform	IN	cfg_lanzar_informes.ccfgform%TYPE,
			plexport	IN	cfg_lanzar_informes.lexport%TYPE,
			pslitera	IN	cfg_lanzar_informes.slitera%TYPE
	) RETURN NUMBER
	IS
	  vselect  VARCHAR2(2500);
	  vpasexec NUMBER;
	  vparam   VARCHAR2(500):='parametros pcempres='
	                        || pcempres
	                        || ' pcmap='
	                        || pcmap
	                        || ' ptevento='
	                        || ptevento
	                        || ' psproduc='
	                        || psproduc
	                        || ' pccfgform='
	                        || pccfgform
	                        || ' plexport='
	                        || plexport
	                        || ' pslitera= '
	                        || pslitera;
	BEGIN
	    vpasexec:=1;

	    UPDATE cfg_lanzar_informes
	       SET lexport=plexport,slitera=pslitera
	     WHERE cempres=pcempres AND
	           cmap=pcmap AND
	           tevento=ptevento AND
	           sproduc=psproduc AND
	           ccfgform=pccfgform;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_informes.f_upd_cfglanzarinformes', vpasexec, vparam, 'SQLERROR: '
	                                                                                                      || SQLCODE
	                                                                                                      || ' - '
	                                                                                                      || SQLERRM);

	             RETURN 1;
	END f_upd_cfglanzarinformes;
	FUNCTION f_del_detalleplantillas(
			pccodplan	IN	detplantillas.ccodplan%TYPE
	) RETURN NUMBER
	IS
	  vselect  VARCHAR2(2500);
	  vpasexec NUMBER;
	  vparam   VARCHAR2(2000):='parametros pccodplan='
	                         || pccodplan;
	  vtotal   NUMBER:=0;
	BEGIN
	    vpasexec:=1;

	    DELETE detplantillas
	     WHERE ccodplan=pccodplan;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_informes.f_upd_cfglanzarinformes', vpasexec, vparam, 'SQLERROR: '
	                                                                                                      || SQLCODE
	                                                                                                      || ' - '
	                                                                                                      || SQLERRM);

	             RETURN 1;
	END f_del_detalleplantillas;
	FUNCTION f_ins_cfglanzarinformesparams(
			pcempres	IN	cfg_lanzar_informes_params.cempres%TYPE,
			pcform	IN	cfg_lanzar_informes_params.cform%TYPE,
			pcmap	IN	cfg_lanzar_informes_params.cmap%TYPE,
			ptevento	IN	cfg_lanzar_informes_params.tevento%TYPE,
			psproduc	IN	cfg_lanzar_informes_params.sproduc%TYPE,
			pccfgform	IN	cfg_lanzar_informes_params.ccfgform%TYPE,
			ptparam	IN	cfg_lanzar_informes_params.tparam%TYPE,
			pctipo	IN	cfg_lanzar_informes_params.ctipo%TYPE,
			pnorder	IN	cfg_lanzar_informes_params.norder%TYPE DEFAULT NULL,
			pslitera	IN	cfg_lanzar_informes_params.slitera%TYPE DEFAULT NULL,
			pnotnull	IN	cfg_lanzar_informes_params.notnull%TYPE DEFAULT NULL,
			plvalor	IN	cfg_lanzar_informes_params.lvalor%TYPE DEFAULT NULL
	) RETURN NUMBER
	IS
	  vpasexec NUMBER;
	  vparam   VARCHAR2(500):='parametros pcempres='
	                        || pcempres
	                        || ' pcform='
	                        || pcform
	                        || ' pcmap='
	                        || pcmap
	                        || ' ptevento='
	                        || ptevento
	                        || ' psproduc='
	                        || psproduc
	                        || ' pccfgform='
	                        || pccfgform
	                        || ' ptparam='
	                        || ptparam
	                        || ' pctipo='
	                        || pctipo
	                        || ' pnorder='
	                        || pnorder
	                        || ' pslitera='
	                        || pslitera
	                        || ' pnotnull='
	                        || pnotnull
	                        || ' plvalor  '
	                        || plvalor;
	BEGIN
	    vpasexec:=1;

			INSERT INTO cfg_lanzar_informes_params
		           (cempres,cform,cmap,tevento,sproduc,ccfgform,
		           tparam,ctipo,norder,slitera,notnull,
		           lvalor)
		    VALUES
		           (pcempres,pcform,pcmap,ptevento,psproduc,pccfgform,
		           ptparam,pctipo,pnorder,pslitera,pnotnull,
		           plvalor);


	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_informes.f_ins_cfglanzarinformesparams', vpasexec, vparam, 'SQLERROR: '
	                                                                                                            || SQLCODE
	                                                                                                            || ' - '
	                                                                                                            || SQLERRM);

	             RETURN 1;
	END;
	FUNCTION f_del_cfglanzarinformesparams(
			pcempres	IN	cfg_lanzar_informes_params.cempres%TYPE,
			pcform	IN	cfg_lanzar_informes_params.cform%TYPE,
			pcmap	IN	cfg_lanzar_informes_params.cmap%TYPE,
			ptevento	IN	cfg_lanzar_informes_params.tevento%TYPE,
			psproduc	IN	cfg_lanzar_informes_params.sproduc%TYPE,
			pccfgform	IN	cfg_lanzar_informes_params.ccfgform%TYPE
	) RETURN NUMBER
	IS
	  vpasexec NUMBER;
	  vparam   VARCHAR2(500):='parametros pcempres='
	                        || pcempres
	                        || ' pcform='
	                        || pcform
	                        || ' pcmap='
	                        || pcmap
	                        || ' ptevento='
	                        || ptevento
	                        || ' psproduc='
	                        || psproduc
	                        || ' pccfgform='
	                        || pccfgform;
	BEGIN
	    vpasexec:=1;

	    DELETE cfg_lanzar_informes_params
	     WHERE cempres=pcempres AND
	           cform=pcform AND
	           cmap=pcmap AND
	           tevento=ptevento AND
	           sproduc=psproduc AND
	           ccfgform=pccfgform;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_informes.f_del_cfglanzarinformesparams', vpasexec, vparam, 'SQLERROR: '
	                                                                                                            || SQLCODE
	                                                                                                            || ' - '
	                                                                                                            || SQLERRM);

	             RETURN 1;
	END;
	FUNCTION f_list366_cab(
			p_cidioma NUMBER DEFAULT NULL,
			p_cempres NUMBER DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list366_cab';
	  v_tparam  VARCHAR2(1000);
	  v_ntraza  NUMBER:=0;
	  v_sep     VARCHAR2(1):=';';
	  v_ret     VARCHAR2(1):=chr(10);
	  v_init    VARCHAR2(32000);
	  v_ttexto  VARCHAR2(32000);
	BEGIN
	    v_ttexto:='select f_axis_literales(111471, '
	              || p_cidioma
	              || ')||'';''||'';''||'
	              || ' f_axis_literales(100784,  '
	              || p_cidioma
	              || ')||'';''||'';''||'
	              || ' f_axis_literales(100943,  '
	              || p_cidioma
	              || ')||'';''||'
	              || ' f_axis_literales(102098, '
	              || p_cidioma
	              || ')||'';''||'
	              || ' f_axis_literales(102424,'
	              || p_cidioma
	              || ')||'';''||'
	              || ' f_axis_literales(100829,'
	              || p_cidioma
	              || ')||'';''||'
	              || ' f_axis_literales(101273, '
	              || p_cidioma
	              || ')||'';''||'
	              || 'decode(pac_parametros.f_parlistado_n('
	              || p_cempres
	              || ',''CCOMPANI''),1,'
	              || 'f_axis_literales(9901675,'
	              || p_cidioma
	              || ')||'';'',null)||'
	              || ' f_axis_literales(101168, '
	              || p_cidioma
	              || ')||'';''|| '
	              || ' f_axis_literales(9901052, '
	              || p_cidioma
	              || ')||'';''||'
	              || ' f_axis_literales(100584, '
	              || p_cidioma
	              || ')||'';''||'
	              || ' f_axis_literales(100883, '
	              || p_cidioma
	              || ')||'';''||'
	              || ' f_axis_literales(100885, '
	              || p_cidioma
	              || ')||'';''||'
	              || ' f_axis_literales(105904, '
	              || p_cidioma
	              || ')||'';''||'
	              || ' f_axis_literales(105940, '
	              || p_cidioma
	              || ')||'';''||'
	              || ' f_axis_literales(100816, '
	              || p_cidioma
	              || ')||'';''||'
	              || ' f_axis_literales(9901053, '
	              || p_cidioma
	              || ')||'';''||'
	              || ' f_axis_literales(105904, '
	              || p_cidioma
	              || ')||'';''||'
	              || ' f_axis_literales(105940, '
	              || p_cidioma
	              || ')||'';''||'
	              || ' f_axis_literales(100816,'
	              || p_cidioma
	              || ')||'';''||'
	              || ' f_axis_literales(9901053, '
	              || p_cidioma
	              || ')||'';''||'
	              || ' f_axis_literales(1000518,'
	              || p_cidioma
	              || ')||'';''||'
	              || ' f_axis_literales(107118, '
	              || p_cidioma
	              || ')||'';''|| '
	              || ' decode(pac_parametros.f_parlistado_n('
	              || p_cempres
	              || ','
	              || '''CCOMPANI''),1,f_axis_literales(9901223,'
	              || p_cidioma
	              || ')||'';'',n'
	              || 'ull)||'
	              || ' decode(nvl(pac_parametros.f_parlistado_n('
	              || ''
	              || p_cempres
	              || ',''VER_FONDO_ENMAPS''),0),0,NULL,f_axis_literales'
	              || '(1000179, '
	              || p_cidioma
	              || ')||'';'') ||'
	              || 'decode(nvl(pac_parametros.f_parlistado_n(pac_md_common.'
	              || 'f_get_cxtempresa,''MONEDAINFORME''),0),0,NULL, f_axis_literales(108645,'
	              || p_cidioma
	              || ')||'';'')'
	              || ' Linea from dual';

	    RETURN(v_ttexto);
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list366_cab;
	FUNCTION f_list366_det(
			p_cidioma NUMBER,
			p_cempres NUMBER,
			p_cproduc	IN	NUMBER DEFAULT NULL,
			p_fechadesde	IN	VARCHAR2 DEFAULT NULL,
			p_fechahasta	IN	VARCHAR2 DEFAULT NULL,
			p_cramo	IN	NUMBER DEFAULT NULL,
			p_cagente	IN	NUMBER DEFAULT NULL,
			p_cgrpro	IN	NUMBER DEFAULT NULL,
			p_compani	IN	NUMBER DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list344_det';
	  v_tparam  VARCHAR2(1000);
	  v_ntraza  NUMBER:=0;
	  v_sep     VARCHAR2(1):=';';
	  v_ret     VARCHAR2(1):=chr(10);
	  v_init    VARCHAR2(32000);
	  v_ttexto  VARCHAR2(32000);
	BEGIN
	    /*Bug 0027666-XVM-01/08/2013*/
	    v_ttexto:='select s.cagrpro||'';''||ag.tagrpro||'';''||s.cramo|'
	              || '|'';''||ff_desramo(s.cramo,'
	              || p_cidioma
	              || ')||'';''||
	    '
	              || chr(10)
	              || 's.cmodali||'''
	              || ';''||s.ctipseg||'';''||s.ccolect||'';''||
	    '
	              || chr(10)
	              || 'f_desproducto_t(s.cramo,s.cmodali,s.ctipseg,s.ccolect,1,'
	              || p_cidioma
	              || ')||'
	              || ''';''||
	    '
	              || chr(10)
	              || 's.npoliza||'';''||decode(pac_parametros.f_par'
	              || 'listado_n('
	              || p_cempres
	              || ',''CCOMPANI''),1,s.cpolcia||'';'',null) |'
	              || '|s.ncertif||'';''||c.polissa_ini||'';''||s.cagente||'';'
	              || '''||s.fefecto||'';''||s.fvencim||'';''||
	    '
	              || chr(10)
	              || '(select p.nnumide from per_personas p, asegurados a
	    '
	              || chr(10)
	              || 'where a.sseguro = s.sseguro and a.norden = 1 and p.sperson ='
	              || ' a.sperson)||'';''||
	    '
	              || chr(10)
	              || '(select f_nombre(sperson,1,ff_'
	              || 'agente_cpervisio(s.cagente))
	    '
	              || chr(10)
	              || 'from asegurados a where a.sseguro = s.sseguro and a.norden = 1 )||'';''|'
	              || '|
	    '
	              || chr(10)
	              || '(select ff_despais('
	              || p_cidioma
	              || ')
	    '
	              || chr(10)
	              || 'from per_detper p,asegurados a
	    '
	              || chr(10)
	              || 'where a.sseguro = s.sseguro and '
	              || 'a.norden = 1 and p.sperson = a.sperson
	    '
	              || chr(10)
	              || 'and p.cagente = ff_agente_cpervisio(s.cagente))||'';''||
	    '
	              || chr(10)
	              || '(select ffecmue from asegurados a where a.sseguro = s.'
	              || 'sseguro and a.norden = 1 )||'';''||
	    '
	              || chr(10)
	              || '(select p.nnumide from per_personas p, asegurados a
	    '
	              || chr(10)
	              || 'where a.sseguro = s.sseguro and a.norden = 2 and p.sperson = a'
	              || '.sperson)||'';''||
	    '
	              || chr(10)
	              || '(select f_nombre(sperson,1,ff_agente_cpervisio(s.cagente))
	    '
	              || chr(10)
	              || 'from asegurados a where a.sseguro = s.sseguro and a.norden = 2 )||'';''||
	    '
	              || ''
	              || chr(10)
	              || '(select ff_despais('
	              || p_cidioma
	              || ')
	    '
	              || chr(10)
	              || 'from per_detper p,asegurados a
	    '
	              || chr(10)
	              || 'where a.sseguro = s.sseguro and a.norden = 2 and p.sperson = a.sperson
	    '
	              || chr(10)
	              || 'and p.cagente = ff_agente_cpervisio(s.cagente))||'';''||
	    '
	              || chr(10)
	              || '(select ffecmue from asegurados a where a.sseguro = s.s'
	              || 'seguro and a.norden = 2 )||'';''||
	    '
	              || chr(10)
	              || 'fbuscasaldo (null, s.sseguro, to_char (f_sysdate, ''yyyymmdd''))||'';'
	              || '''||
	    '
	              || chr(10)
	              || 'f_capgar_ult_act (s.sseguro, f_sysdate) ||'';'''
	              || '||
	    '
	              || chr(10)
	              || 'decode(pac_parametros.f_parlistado_n('
	              || p_cidioma
	              || ',''CCOM'
	              || 'PANI''),1,c.tcompani||'';'',null) ||
	    '
	              || chr(10)
	              || 'decode(nvl(pac_parametros.f_parlistado_n(s.cempres,''VER_FONDO_ENM'
	              || 'APS''),0),0,NULL,
	    '
	              || chr(10)
	              || '  (SELECT c.tmodinv FROM codimod'
	              || 'elosinversion c, seguros se, seguros_ulk sk
	    '
	              || chr(10)
	              || '   WHERE c.cmodinv = sk.cmodinv AND c.cramo = se.cramo '
	              || 'AND c.cmodali = se.cmodali AND c.ctipseg = se.ctipseg
	    '
	              || chr(10)
	              || '     AND c.ccolect = se.ccolect AND se.ssegur'
	              || 'o = sk.sseguro AND se.sseguro = s.sseguro AND c.cidioma ='
	              || p_cidioma
	              || ')|| decode(nvl(pac_parametros.f_parlistado_n('
	              || 'pac_md_common.f_get_cxtempresa,''MONEDAINFORME''),0),0,NULL,'
	              || 'pac_eco_monedas.f_obtener_moneda_informe(null,s.sproduc)||'';'')
	                      ||'';'')
	    '
	              || chr(10)
	              || 'Linea
	    '
	              || chr(10)
	              || 'from seguros s, cnvpolizas c,agrupapro ag, companias c, agentes_agente_pol ap
	    '
	              || chr(10)
	              || 'where s.csituac in (0, 5)
	    '
	              || chr(10)
	              || 'AND s.cempres = ap.cempres AND s.cagente = ap.cagente
	    '
	              || chr(10)
	              || 'AND (s.cagente, s.cempres) IN
	    '
	              || chr(10)
	              || '(SELECT rc.cagente, rc.cempres
	    '
	              || chr(10)
	              || '  FROM (SELECT     rc.cagente, rc.cempres
	    '
	              || chr(10)
	              || '              FROM redcomercial rc'
	              || '
	    '
	              || chr(10)
	              || '             WHERE rc.fmovfin IS NULL
	    '
	              || chr(10)
	              || '        START WITH rc.cagente = NVL('
	              || nvl (to_char(p_cagente), 'null')
	              || ',ff_agente_cpolvisio(pac_user.ff_get_cagente(f_user)))
	    '
	              || chr(10)
	              || '        CONNECT BY PRIOR rc.cagente = rc.cpadre
	    '
	              || chr(10)
	              || '               AND PRIOR rc.fmovfin IS NULL) rc,
	    '
	              || chr(10)
	              || '       agentes_agente_pol a
	    '
	              || chr(10)
	              || ' WHERE rc.cagente = a.cagente)
	    '
	              || chr(10)
	              || 'and s.npoliza = c.npoliza(+)
	    '
	              || chr(10)
	              || 'and ag.cagrpro = s.cagrpro
	    '
	              || chr(10)
	              || 'and ag.cidioma = '
	              || p_cidioma
	              || '
	    '
	              || chr(10)
	              || 'and s.cagrpro = decode('
	              || nvl(p_cgrpro, 0)
	              || '
	                      ,0,s.cagrpro,'
	              || nvl(p_cgrpro, 0)
	              || ')
	    '
	              || chr(10)
	              || 'and (trunc(s.fvencim) between to_date('''
	              || nvl(p_fechadesde, '01011111')
	              || ''',''ddmmrrrr'')
	    '
	              || chr(10)
	              || 'and to_date('''
	              || nvl(p_fechahasta, '31129999')
	              || ''',''ddmmrrrr'''
	              || '))
	    '
	              || chr(10)
	              || 'and s.cempres =  '
	              || p_cempres
	              || '
	    '
	              || chr(10)
	              || 'and s.sproduc = decode('
	              || nvl(p_cproduc, 0)
	              || ',0,'
	              || 's.sproduc,'
	              || nvl(p_cproduc, 0)
	              || ')
	    '
	              || chr(10)
	              || 'and s.cramo = decode('
	              || nvl(p_cramo, 0)
	              || ',0,s.cramo,'
	              || nvl(p_cramo, 0)
	              || ')
	    '
	              || chr(10)
	              || 'and ('
	              || nvl(p_compani, 0)
	              || ' = 0 or
	    '
	              || chr(10)
	              || 'c.ccompani ='
	              || nvl(p_compani, 0)
	              || ')
	    '
	              || chr(10)
	              || 'and c.ccompani('
	              || '+) = s.ccompani
	    '
	              || chr(10)
	              || 'order by s.cramo, s.cmodali, s.ct'
	              || 'ipseg, s.ccolect, s.npoliza, s.ncertif';

	    RETURN v_ttexto;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list366_det;

	/*

	*/
	FUNCTION f_list320_cab(
			p_sproces NUMBER DEFAULT NULL,
			p_cempres NUMBER DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list320_cab';
	  v_tparam  VARCHAR2(1000);
	  v_ntraza  NUMBER:=0;
	  v_sep     VARCHAR2(1):=';';
	  v_ret     VARCHAR2(1):=chr(10);
	  v_init    VARCHAR2(32000);
	  v_ttexto  VARCHAR2(32000);
	BEGIN
	    v_ttexto:='select f_axis_literales(100836, f_idiomauser) || '';''
	          || f_axis_literales(100784, f_idiomauser) || '';''
	          || f_axis_literales(100829, f_idiomauser) || '';''
	          || f_axis_literales(101027, f_idiomauser) || '';''
	          || f_axis_literales(100895, f_idiomauser) || '';''
	          || f_axis_literales(100712, f_idiomauser) || '';''
	          || f_axis_literales(101332, f_idiomauser) || '';''
	          || f_axis_literales(106053, f_idiomauser) || '';''
	          || DECODE(pac_parametros.f_parlistado_n(NVL(pac_md_common.f_get_cxtempresa,
	                                                      f_parinstalacion_n(''EMPRESADEF'')),
	                                                  ''SUCURSAL/ADN''),
	                    1, f_axis_literales(9903035, f_idiomauser) || '';'',
	                    NULL)
	          || f_axis_literales(100584, f_idiomauser) || '';''
	          || f_axis_literales(102995, f_idiomauser) || '';''
	          || f_axis_literales(105171, f_idiomauser) || '';''
	          || f_axis_literales(100916, f_idiomauser) || '';''
	          || f_axis_literales(101278, f_idiomauser) || '';''
	          || f_axis_literales(801270,f_idiomauser)  || '';''
	          || f_axis_literales(1000529, f_idiomauser) || '';''
	          || f_axis_literales(103170, f_idiomauser) || '';''
	          || f_axis_literales(9002214, f_idiomauser) || '';''
	          || f_axis_literales(101714, f_idiomauser) || '';''
	          || f_axis_literales(110332, f_idiomauser)';

	    IF nvl(pac_parametros.f_parlistado_n(p_cempres, 'LIST_PREVI_CARTERA'), 0)=1 THEN
	      v_ttexto:='select f_axis_literales(100836, f_idiomauser) || '';''
	          || f_axis_literales(9902911, f_idiomauser) || '';''
	          || f_axis_literales(100784, f_idiomauser) || '';''
	          || f_axis_literales(100829, f_idiomauser) || '';''
	          || f_axis_literales(101027, f_idiomauser) || '';''
	          || f_axis_literales(102999, f_idiomauser) || '';''
	          || f_axis_literales(100895, f_idiomauser) || '';''
	          || f_axis_literales(100712, f_idiomauser) || '';''
	          || f_axis_literales(101332, f_idiomauser) || '';''
	          || f_axis_literales(106053, f_idiomauser) || '';''
	          || DECODE(pac_parametros.f_parlistado_n(NVL(pac_md_common.f_get_cxtempresa,
	                                                      f_parinstalacion_n(''EMPRESADEF'')),
	                                                  ''SUCURSAL/ADN''),
	                    1, f_axis_literales(9903035, f_idiomauser) || '';'',
	                    NULL)
	          || f_axis_literales(100584, f_idiomauser) || '';''  -- AGENTE
	          || f_axis_literales(102995, f_idiomauser) || '';''  -- PRIMA NETA
	          || f_axis_literales(105171, f_idiomauser) || '';''   -- RECARGOS
	          || f_axis_literales(100916, f_idiomauser) || '';''
	          || f_axis_literales(101278, f_idiomauser) || '';''
	          || f_axis_literales(801270, f_idiomauser) || '';''
	          || f_axis_literales(1000529, f_idiomauser) || '';''
	          || f_axis_literales(103170, f_idiomauser) || '';''
	          || f_axis_literales(9002214, f_idiomauser) || '';''
	          || f_axis_literales(101714, f_idiomauser) || '';''
	          || f_axis_literales(110332, f_idiomauser)'
	                || ' || '';''
	          || f_axis_literales(9002202, f_idiomauser)|| '';''
	          || f_axis_literales(102999, f_idiomauser)|| '';''
	          || f_axis_literales(101028, f_idiomauser)|| '';''
	          || f_axis_literales(9000531, f_idiomauser)|| '';''
	          || f_axis_literales(9906787, f_idiomauser)|| '';''
	          || f_axis_literales(9906788, f_idiomauser) || '';''
	          || f_axis_literales(9906789, f_idiomauser)|| '';''
	          || f_axis_literales(9906790, f_idiomauser)|| '';''
	          || f_axis_literales(9000477, f_idiomauser)|| '';''
	          || f_axis_literales(9904804, f_idiomauser)|| '';''
	          || f_axis_literales(9902924, f_idiomauser)|| '';''
	          || f_axis_literales(9902716, f_idiomauser)|| '';''
	          || f_axis_literales(9001954, f_idiomauser)|| '';''
	          || f_axis_literales(102421, f_idiomauser)|| '';''
	          || f_axis_literales(101040, f_idiomauser)|| '';''
	          || f_axis_literales(100877, f_idiomauser)|| '';''
	          || f_axis_literales(9902048, f_idiomauser)|| '';''
	          || f_axis_literales(9903807, f_idiomauser)|| '';''
	          || f_axis_literales(9902122, f_idiomauser)|| '';''
	          || f_axis_literales(9903395, f_idiomauser)|| '';''
	          || f_axis_literales(9001923, f_idiomauser)|| '';''
	          || f_axis_literales(9905833, f_idiomauser)|| '';''
	          || f_axis_literales(9902935, f_idiomauser)|| '';''
	          || f_axis_literales(9906959, f_idiomauser)|| '';''  -- Fecha inicio vigencia
	          || f_axis_literales(9000875, f_idiomauser)|| '';''
	          || f_axis_literales(9906957, f_idiomauser)|| '';''
	          || f_axis_literales(9906958, f_idiomauser)|| ';
	    END IF;

	    v_ttexto:=v_ttexto
	              || '
	            Linea from dual';

	    RETURN(v_ttexto);
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list320_cab;
	FUNCTION f_list320_det(
			p_sproces NUMBER DEFAULT NULL,
			p_cempres NUMBER DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list320_det';
	  v_tparam  VARCHAR2(1000);
	  v_ntraza  NUMBER:=0;
	  v_sep     VARCHAR2(1):=';';
	  v_ret     VARCHAR2(1):=chr(10);
	  v_init    VARCHAR2(32000);
	  v_ttexto  VARCHAR2(32000);
	BEGIN
	    IF nvl(pac_parametros.f_parlistado_n(p_cempres, 'LIST_PREVI_CARTERA'), 0)=1 THEN
	      v_ttexto:='SELECT   s.npoliza || '';'' || s.ncertif || '';'' || s.cramo || ''-'' || r.tramo
	        || '';'' || s.sproduc || ''-''
	        || f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, f_idiomauser)
	        || '';'' || f_nombre(tomadores.sperson, 1, s.cagente) || '';''
	        || p.NNUMIDE || '';''
	        || reciboscar.nrecibo || '';''
	        || CASE
	        WHEN s.cforpag = 0 THEN ''U''
	        WHEN s.cforpag = 1 THEN ''A''
	        WHEN s.cforpag IN(2, 6) THEN ''S''
	        WHEN s.cforpag = 3 THEN ''C''
	        WHEN s.cforpag = 4 THEN ''T''
	        WHEN s.cforpag = 12 THEN ''M''
	        END
	        || '';'' || TO_CHAR(s.fefecto, ''dd-mm-yyyy'') || '';''
	        || TO_CHAR(reciboscar.fefecto, ''dd-mm-yyyy'') || '' / ''
	        || TO_CHAR(reciboscar.fvencim - 1, ''dd-mm-yyyy'') || '';''
	        || DECODE(pac_parametros.f_parlistado_n(reciboscar.cempres, ''SUCURSAL/ADN''),
	        1, NVL(pac_redcomercial.f_busca_padre(reciboscar.cempres,
	        reciboscar.cagente, NULL, f_sysdate),''0'')|| '';'',NULL)
	        || reciboscar.cagente || '';''
	        ||(DECODE(s.ctipcoa, 1, v.iprinet + v.icednet, v.iprinet)) || '';''||
	        (DECODE(s.ctipcoa, 1, v.irecfra + v.icedrfr, v.irecfra)) || '';'' ||
	        v.itotcon || '';''||
	        v.itotimp || '';'' ||
	        v.idgs||'';''||
	        v.itotalr || '';''||
	        (DECODE(s.ctipcoa, 1,(v.icombru + v.icedcbr), v.icombru)) || '';''||
	        (DECODE(s.ctipcoa, 1,(v.icombrui + v.icedcbr), v.icombrui)) || '';''||
	        (DECODE(s.ctipcoa, 1, v.icomret + v.icedcrt, v.icomret)) || '';''||
	        CASE s.ctipcoa
	        WHEN 1 THEN v.iprinet + v.icednet + v.irecfra + v.icedrfr - v.icombru + v.icedcbr
	        - v.icomret + v.icedcrt
	        ELSE v.iprinet + v.irecfra - v.icombru - v.icomret
	        END
	        || '';''||
	        pac_redcomercial.ff_desagente(NVL(pac_redcomercial.f_busca_padre(s.cempres, s.cagente, 2,
	                                                          TRUNC(s.fefecto)),
	                           s.cagente),'
	                || p_cempres
	                || ',1)
	        || '';''||
	        p.NNUMIDE
	        || '';''||
	        pac_isqlfor.ff_nombre(p.sperson,1)
	        || '';''||
	        s.cagente
	        || '';''||
	        decode((select count(1) from garanseg where sseguro = s.sseguro and cgarant = 48 and icapital > 0),0,''No'',''Si'')
	        || '';''||
	        s.ndurcob
	        || '';''||
	        nvl(trunc(months_between(s.fefecto,s.fvencim)/12),1)
	        || '';''||
	        (select crespue from pregunpolseg where cpregun = 4103 and sseguro = s.sseguro and nmovimi = (select max(nmovimi) from pregunpolseg where sseguro = s.sseguro))
	        || '';''||
	        pac_isqlfor.f_respuesta (s.sseguro, m.nmovimi, 4086, f_idiomauser)|| '';''||
	        pac_isqlfor.f_respuesta (s.sseguro, m.nmovimi, 4113, f_idiomauser)|| '';''||
	        (select sum(icapital) from garanseg gar, seguros seg where gar.sseguro = seg.sseguro and gar.sseguro = s.sseguro and (gar.cgarant,seg.sproduc) in (select cgarant, sproduc from garanpro where cbasica = 1))|| '';''||
	        s.fvencim || '';''||
	        m.nmovimi || '';''||
	        md.tatribu || '';''||
	        mm.tmotmov || '';''||
	        m.fmovimi || '';''||
	        v.itotpri || '';''||
	        v.itotdto || '';''||
	        v.iprinet || '';''||
	        ad.tatribu || '';''||
	        nvl(ff_pcomisi(-1,s.sseguro,decode(f_es_renovacion(s.sseguro),0,2,1),reciboscar.fefecto),0) || '';''||
	        decode((select count(1) from psucontrolseg where sseguro = s.sseguro and ccontrol =526031),0,''NO'',''SI'') || '';''||
	        cd.tatribu || '';''||
	        NVL(s.fcarant, s.fefecto) || '';''||
	        s.nsolici|| '';''||
	        (SELECT SUM(G.ICAPITAL)
	        FROM GARANSEG G, SEGUROS SEG
	        WHERE G.SSEGURO = S.SSEGURO
	        AND G.SSEGURO =  SEG.SSEGURO
	        AND G.NMOVIMI = (SELECT MIN(NMOVIMI) FROM GARANSEG WHERE SSEGURO = G.SSEGURO)
	        AND (G.CGARANT, SEG.SPRODUC) IN (SELECT CGARANT, SPRODUC FROM GARANPRO WHERE CBASICA=1))|| '';''||
	        CASE
	        WHEN s.sproduc IN(7029,702, 7030,7036,7035,7053,7037) THEN
	        (SELECT DECODE(1, 2, nfactor, pipc)
	          FROM ipc
	         WHERE nanyo = (SELECT TO_NUMBER(SUBSTR(MAX(LPAD(TO_CHAR(nanyo), 4, ''0'')
	                                                    || LPAD(TO_CHAR(nmes), 2, ''0'')),
	                                                1, 4)) anyo
	                          FROM ipc
	                         WHERE ctipo = 1
	                           AND((nmes = 0
	                                AND nanyo <= TO_NUMBER(TO_CHAR(m.femisio, ''YYYY''))
	                                AND 1 = 0)
	                               OR(nmes <> 0
	                                  AND(LPAD(TO_CHAR(nanyo), 4, ''0'') || LPAD(TO_CHAR(nmes), 2, ''0'')) <=
	                                        (LPAD(TO_CHAR(m.femisio, ''YYYY''), 4, ''0'')
	                                         || LPAD(TO_CHAR(m.femisio, ''MM''), 2, ''0''))
	                                  AND 1 = 1)))
	           AND nmes = (SELECT TO_NUMBER(SUBSTR(MAX(LPAD(TO_CHAR(nanyo), 4, ''0'')
	                                                   || LPAD(TO_CHAR(nmes), 2, ''0'')),
	                                               5, 7))
	                         FROM ipc
	                        WHERE ctipo = 1
	                          AND((nmes = 0
	                               AND nanyo <= TO_NUMBER(TO_CHAR(m.femisio, ''YYYY''))
	                               AND 1 = 0)
	                              OR(nmes <> 0
	                                 AND(LPAD(TO_CHAR(nanyo), 4, ''0'') || LPAD(TO_CHAR(nmes), 2, ''0'')) <=
	                                       (LPAD(TO_CHAR(m.femisio, ''YYYY''), 4, ''0'')
	                                        || LPAD(TO_CHAR(m.femisio, ''MM''), 2, ''0''))
	                                 AND 1 = 1)))
	           AND ctipo = 1)
	        ELSE s.prevali
	        END
		|| '';''
	        linea
	        FROM tomadores, seguros s, vdetreciboscar v, reciboscar, ramos r, agentes_agente_pol ap,
	        per_personas p, asegurados ag,
	        per_personas p2, movseguro m, motmovseg mm, detvalores md, detvalores ad, agentes a, detvalores cd
	        WHERE reciboscar.sproces = '
	                || p_sproces
	                || '
	        AND reciboscar.sproces = v.sproces
	        AND reciboscar.nrecibo = v.nrecibo
	        AND s.cramo = r.cramo
	        AND r.cidioma = f_idiomauser
	        AND reciboscar.sseguro = s.sseguro
	        AND tomadores.sseguro = s.sseguro
	        AND tomadores.nordtom = 1
	        and ag.sseguro = s.sseguro
	        and ag.norden = 1
	        and p.sperson = ag.sperson
	        AND s.CEMPRES = ap.CEMPRES
	        AND s.cagente = ap.cagente
	        AND m.sseguro = s.sseguro
	        AND m.nmovimi = (select max(nmovimi) from movseguro where sseguro = s.sseguro)
	        AND m.cmotmov = mm.cmotmov
	        AND mm.cidioma = f_idiomauser
	        and md.cvalor = 16
	        and md.cidioma = f_idiomauser
	        and md.catribu = m.cmovseg
	        and a.cagente = s.cagente
	        and ad.cvalor = 30
	        and ad.cidioma = f_idiomauser
	        and ad.catribu = a.ctipage
	        and cd.cvalor = 800109
	        and cd.cidioma = f_idiomauser
	        and cd.catribu = s.ctipcoa
	        AND tomadores.sperson = p2.sperson
	        AND s.CEMPRES = ap.CEMPRES
	        AND s.cagente = ap.cagente
	        ORDER BY s.cramo, s.cmodali, s.npoliza';
	    ELSE
	      v_ttexto:='SELECT   f_formatopol(s.npoliza, s.ncertif, 1) || '';'' || s.cramo || ''-'' || r.tramo
	        || '';'' || s.sproduc || ''-''
	        || f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, f_idiomauser)
	        || '';'' || f_nombre(tomadores.sperson, 1, s.cagente) || '';''
	        || reciboscar.nrecibo || '';''
	        || CASE
	        WHEN s.cforpag = 0 THEN ''U''
	        WHEN s.cforpag = 1 THEN ''A''
	        WHEN s.cforpag IN(2, 6) THEN ''S''
	        WHEN s.cforpag = 3 THEN ''C''
	        WHEN s.cforpag = 4 THEN ''T''
	        WHEN s.cforpag = 12 THEN ''M''
	        END
	        || '';'' || TO_CHAR(s.fefecto, ''dd-mm-yyyy'') || '';''
	        || TO_CHAR(reciboscar.fefecto, ''dd-mm-yyyy'') || '' / ''
	        || TO_CHAR(reciboscar.fvencim - 1, ''dd-mm-yyyy'') || '';''
	        || DECODE(pac_parametros.f_parlistado_n(reciboscar.cempres, ''SUCURSAL/ADN''),
	        1, NVL(pac_redcomercial.f_busca_padre(reciboscar.cempres,
	        reciboscar.cagente, NULL, f_sysdate),''0'')|| '';'',NULL)
	        || reciboscar.cagente || '';''
	        ||(DECODE(s.ctipcoa, 1, v.iprinet + v.icednet, v.iprinet)) || '';''||
	        (DECODE(s.ctipcoa, 1, v.irecfra + v.icedrfr, v.irecfra)) || '';'' ||
	        v.itotcon || '';''||
	        v.itotimp || '';'' ||
	        v.idgs||'';''||
	        v.itotalr || '';''||
	        (DECODE(s.ctipcoa, 1,(v.icombru + v.icedcbr), v.icombru)) || '';''||
	        (DECODE(s.ctipcoa, 1,(v.icombrui + v.icedcbr), v.icombrui)) || '';''||
	        (DECODE(s.ctipcoa, 1, v.icomret + v.icedcrt, v.icomret)) || '';''||
	        CASE s.ctipcoa
	        WHEN 1 THEN v.iprinet + v.icednet + v.irecfra + v.icedrfr - v.icombru + v.icedcbr
	        - v.icomret + v.icedcrt
	        ELSE v.iprinet + v.irecfra - v.icombru - v.icomret
	        END || '';''
	        linea
	        FROM tomadores, seguros s, vdetreciboscar v, reciboscar, ramos r, agentes_agente_pol ap
	        WHERE reciboscar.sproces = '
	                || p_sproces
	                || '
	        AND reciboscar.sproces = v.sproces
	        AND reciboscar.nrecibo = v.nrecibo
	        AND s.cramo = r.cramo
	        AND r.cidioma = f_idiomauser
	        AND reciboscar.sseguro = s.sseguro
	        AND tomadores.sseguro = s.sseguro
	        AND tomadores.nordtom = 1
	        AND s.CEMPRES = ap.CEMPRES
	        AND s.cagente = ap.cagente
	        ORDER BY s.cramo, s.cmodali, s.npoliza';
	    END IF;

	    RETURN(v_ttexto);
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list320_det;

	/*----------------*/
	/* Bug 0031584 - 20/06/2014 - JMF*/
	/******************************************************************************************
	  Descripció: Funció que genera texte select titols per llistat (map 316 dinamic APR-Previo a domiciliaciones)
	  return:     texte select titols
	******************************************************************************************/
	FUNCTION f_list316_cab
	RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list316_cab';
	  v_tparam  VARCHAR2(1000);
	  v_ntraza  NUMBER:=0;
	  v_ttexto  VARCHAR2(32000);
	BEGIN
	    v_ntraza:=10;

	    v_ttexto:='Select
	        f_axis_literales(101619,nvalpar)||'';''|| -- Empresa
	        f_axis_literales(100829,nvalpar)||'';''|| -- Producto
	        f_axis_literales(9001036,nvalpar)||'';''|| -- Cobrador
	        f_axis_literales(9001627,nvalpar)||'';''|| -- C.C. Recibo
	        f_axis_literales(9001875,nvalpar)||'';''|| -- Póliza
	        f_axis_literales(100565,nvalpar)||'';''|| -- Tipo
	        f_axis_literales(101027,nvalpar)||'';''|| -- Tomador
	        f_axis_literales(100582,nvalpar)||'';''|| -- Efecto
	        f_axis_literales(100885,nvalpar)||'';''|| -- Fecha vencimiento
	        f_axis_literales(9001628,nvalpar)||'';''|| -- C.C. cobrador
	        f_axis_literales( 100563,nvalpar)||'';''|| -- Importe
	        f_axis_literales(1000553,nvalpar)||'';''|| -- Estado recibo
	        f_axis_literales(102104,nvalpar)||'';''|| -- Subestado recibo
	        f_axis_literales(9000531,nvalpar)||'';''|| -- Código agente
	        f_axis_literales(100584,nvalpar)||'';''||  -- Agente
	        f_axis_literales(9902457,nvalpar)||'';''|| -- Anualidad
	        f_axis_literales(9903786,nvalpar) /* Nº de fracción */
	        Linea
	        from parinstalacion
	        where CPARAME = ''IDIOMARTF''
	        ';

	    v_ntraza:=30;

	    RETURN(v_ttexto);
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list316_cab;

	/* Bug 0031584 - 20/06/2014 - JMF*/
	/******************************************************************************************
	  Descripció: Funció que genera texte select detall per llistat (map 316 dinamic APR-Previo a domiciliaciones)
	  return:     texte select detall
	******************************************************************************************/
	FUNCTION f_list316_det(
			p_ffecha	IN	VARCHAR2,
			p_cramo	IN	VARCHAR2,
			p_sproduc	IN	VARCHAR2,
			p_cempres	IN	VARCHAR2,
			p_sprodcom	IN	VARCHAR2,
			p_ccobban	IN	VARCHAR2,
			p_cbanco	IN	VARCHAR2,
			p_ctipcuenta	IN	VARCHAR2,
			p_fventar	IN	VARCHAR2,
			p_creferencia	IN	VARCHAR2,
			p_dffecha	IN	VARCHAR2
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list316_det';
	  v_tparam  VARCHAR2(1000):=' fec='
	                           || p_ffecha
	                           || ' ram='
	                           || p_cramo
	                           || ' pro='
	                           || p_sproduc
	                           || ' emp='
	                           || p_cempres
	                           || ' dom='
	                           || p_sprodcom
	                           || ' cob='
	                           || p_ccobban
	                           || ' ban='
	                           || p_cbanco
	                           || ' tip='
	                           || p_ctipcuenta
	                           || ' ven='
	                           || p_fventar
	                           || ' ref='
	                           || p_creferencia
	                           || ' dfe='
	                           || p_dffecha;
	  v_ntraza  NUMBER:=0;
	  v_ttexto  VARCHAR2(32000);
	BEGIN
	    v_ntraza:=10;

	    /* p_FFECHA, p_FVENTAR, p_DFFECHA son fechas que llegan en formato ddmmyyyy*/
	    v_ttexto:='select empresa, producto, cobrador, nrecibo, npoliza, tipo_recibo,'
	              || '       tomador, fefecto, fvencim, cbancar,  itotalr,'
	              || '       estado, testimp, cagente, tagente'
	              || '       nanuali, nfracci'
	              || ' from ( '
	              || pac_domis.f_retorna_query(p_ffecha, to_number(p_cramo), to_number(p_sproduc), to_number(p_cempres), to_number(p_sprodcom), FALSE, to_number(p_ccobban), to_number(p_cbanco), to_number(p_ctipcuenta), p_fventar, p_creferencia, p_dffecha)
	              || ')';

	    v_ntraza:=30;

	    RETURN(v_ttexto);
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list316_det;
	FUNCTION f_list323_cab(
			p_sproces NUMBER DEFAULT NULL,
			p_cempres NUMBER DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list323_cab';
	  v_tparam  VARCHAR2(1000);
	  v_ntraza  NUMBER:=0;
	  v_sep     VARCHAR2(1):=';';
	  v_ret     VARCHAR2(1):=chr(10);
	  v_init    VARCHAR2(32000);
	  v_ttexto  VARCHAR2(32000);
	BEGIN
	    v_ttexto:='Select f_axis_literales(101274,f_idiomauser) || '';''
	            || f_axis_literales(9000493,f_idiomauser) || '';''
	            || f_axis_literales(100836,f_idiomauser) || '';''
	            || f_axis_literales(100784,f_idiomauser) || '';''
	            || f_axis_literales(100829,f_idiomauser) || '';''
	            || f_axis_literales(9000875,f_idiomauser) || '';''  -- nº solicitud
	            || f_axis_literales(109604,f_idiomauser) || '';''  -- Riesgo
	            || f_axis_literales(101027,f_idiomauser) || '';''
	            || f_axis_literales(101332,f_idiomauser) || '';''
	            || DECODE(pac_parametros.f_parlistado_n(NVL(pac_md_common.f_get_cxtempresa,
	                                                      f_parinstalacion_n(''EMPRESADEF'')),
	                                                  ''SUCURSAL/ADN''),
	                    1, f_axis_literales(9903035, f_idiomauser) || '';'',
	                    NULL)
	            || f_axis_literales(100584,f_idiomauser) || '';''
	            || DECODE(pac_parametros.f_parlistado_n(NVL(pac_md_common.f_get_cxtempresa,
	                                                      f_parinstalacion_n(''EMPRESADEF'')),
	                                                  ''INFO_AGENTE_COMERC''),
	                    1, f_axis_literales(9908737, f_idiomauser) || '';''
	                    || f_axis_literales(9900822, f_idiomauser) || '';''
	                    || f_axis_literales(9903393, f_idiomauser) || '';'',
	                    NULL)
	            || f_axis_literales(9000719,f_idiomauser) || '';''
	            || f_axis_literales(9902088,f_idiomauser) || '';''
	            || f_axis_literales(100895,f_idiomauser)|| '';''
	            || f_axis_literales(100561,f_idiomauser) || '';''
	            || f_axis_literales(805907,f_idiomauser) || '';''
	            || f_axis_literales(9001793,f_idiomauser) || '';''
	            || f_axis_literales(1000516,f_idiomauser) || '';''
	            || f_axis_literales(9001792,f_idiomauser) || '';''
	            || f_axis_literales(101432,f_idiomauser) || '';''
	            || f_axis_literales(9001317,f_idiomauser) || '';''
	            || f_axis_literales(102995,f_idiomauser) || '';''
	            || f_axis_literales(101369,f_idiomauser) || '';''
	            || f_axis_literales(100916,f_idiomauser) || '';''
	            || f_axis_literales(800422,f_idiomauser) || '';''
	            || f_axis_literales(801270,f_idiomauser) || '';''
	            || f_axis_literales(140531,f_idiomauser) || '';''
	            || f_axis_literales(103170,f_idiomauser) || '';''
	            || f_axis_literales(9002214,f_idiomauser) || '';''
	            || f_axis_literales(101714,f_idiomauser) || '';''
	            || f_axis_literales(110332,f_idiomauser) || '';''
	            || decode(nvl(pac_parametros.f_parlistado_n(pac_md_common.f_get_cxtempresa,''INDICE_SINIES''),0),0,NULL,f_axis_literales(9904847, f_idiomauser))';

	    IF nvl(pac_parametros.f_parlistado_n(p_cempres, 'LIST_PREVI_CARTERA'), 0)=1 THEN
	      v_ttexto:='Select f_axis_literales(101274,f_idiomauser) || '';''
	            || f_axis_literales(9000493,f_idiomauser) || '';''
	            || f_axis_literales(100836,f_idiomauser) || '';''
	            || f_axis_literales(100784,f_idiomauser) || '';''
	            || f_axis_literales(100829,f_idiomauser) || '';''
	            || f_axis_literales(102999, f_idiomauser) || '';''
	            || f_axis_literales(101027,f_idiomauser) || '';''
	            || f_axis_literales(101332,f_idiomauser) || '';''
	          || DECODE(pac_parametros.f_parlistado_n(NVL(pac_md_common.f_get_cxtempresa,
	                                                      f_parinstalacion_n(''EMPRESADEF'')),
	                                                  ''SUCURSAL/ADN''),
	                    1, f_axis_literales(9903035, f_idiomauser) || '';'',
	                    NULL)
	            || f_axis_literales(9000531,f_idiomauser) || '';'' -- CODIGO AGENTE
	            || f_axis_literales(100584, f_idiomauser) || '';''  -- AGENTE
	            || f_axis_literales(9000719,f_idiomauser) || '';''
	            || f_axis_literales(9902088,f_idiomauser) || '';''
	            || f_axis_literales(100895,f_idiomauser)|| '';''
	            || f_axis_literales(100561,f_idiomauser) || '';''
	            || f_axis_literales(805907,f_idiomauser) || '';''
	            || f_axis_literales(9001793,f_idiomauser) || '';''
	            || f_axis_literales(1000516,f_idiomauser) || '';''
	            || f_axis_literales(9001792,f_idiomauser) || '';''
	            || f_axis_literales(101432,f_idiomauser) || '';''
	            || f_axis_literales(9001317,f_idiomauser) || '';''
	            || f_axis_literales(102995,f_idiomauser) || '';''
	            || f_axis_literales(101369,f_idiomauser) || '';''
	            || f_axis_literales(100916,f_idiomauser) || '';''
	            || f_axis_literales(800422,f_idiomauser) || '';''
	            || f_axis_literales(801270,f_idiomauser) || '';''
	            || f_axis_literales(140531,f_idiomauser) || '';''
	            || f_axis_literales(103170,f_idiomauser) || '';''
	            || f_axis_literales(9002214,f_idiomauser) || '';''
	            || f_axis_literales(101714,f_idiomauser) || '';''
	            || f_axis_literales(110332,f_idiomauser) || '';''
	            || decode(nvl(pac_parametros.f_parlistado_n(pac_md_common.f_get_cxtempresa,''INDICE_SINIES''),0),0,NULL,f_axis_literales(9904847, f_idiomauser)) || '';''
	            || f_axis_literales(9002202,f_idiomauser)  || '';''  -- sucursal
	            || f_axis_literales(102999, f_idiomauser) || '';''  -- Nº ident asegurado
	            || f_axis_literales(101028, f_idiomauser) || '';''  -- Nombre asegurado
	            || f_axis_literales(9906787,f_idiomauser) || '';'' -- MARCA AHORRO
	            || f_axis_literales(9906788, f_idiomauser) || '';'' -- aHORRO PAGO DE PRIMA
	            || f_axis_literales(9906789, f_idiomauser)|| '';''  -- AYOS COBERTURA
	            || f_axis_literales(9906790, f_idiomauser)|| '';''  -- % DOTE RECIBIIR
	            || f_axis_literales(9000477, f_idiomauser) || '';'' -- Nº asegurados
	            || f_axis_literales(9904804, f_idiomauser) || '';'' -- Ocupacion
	            || f_axis_literales(9902911, f_idiomauser) || '';'' -- Numero de certificado
	            || f_axis_literales(9902924, f_idiomauser) || '';'' -- Valor asegurado
	            || f_axis_literales(9902716, f_idiomauser) || '';'' -- Fecha fin vigencia
	            || f_axis_literales(9001954, f_idiomauser) || '';'' -- Número movimiento
	            || f_axis_literales(102421, f_idiomauser) || '';'' -- Tipo movimiento
	            || f_axis_literales(101040, f_idiomauser) || '';'' -- Causa
	            || f_axis_literales(100877, f_idiomauser) || '';'' -- Fecha emision movimiento
	            || f_axis_literales(9902048, f_idiomauser) || '';'' -- Prima anual neta
	            || f_axis_literales(9903807, f_idiomauser) || '';'' -- Descuento
	            || f_axis_literales(9902122, f_idiomauser)|| '';''  -- Recibo fraccionados
	            || f_axis_literales(9903395, f_idiomauser) || '';'' -- Tipo intermediario
	            || f_axis_literales(9001923, f_idiomauser) || '';'' -- % comision
	            || f_axis_literales(9905833, f_idiomauser) || '';'' -- Reaseguro facultativo
	            || f_axis_literales(9902935, f_idiomauser)|| '';''  -- Tipo Coaseguro
	            || f_axis_literales(9906959, f_idiomauser)|| '';''  -- Fecha inicio vigencia
	            || f_axis_literales(9000875, f_idiomauser)|| '';''
	            || f_axis_literales(9906957, f_idiomauser)|| '';''
	            || f_axis_literales(9906958, f_idiomauser)|| ';
	    END IF;

	    v_ttexto:=v_ttexto
	              || '
	            Linea from dual';

	    RETURN(v_ttexto);
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list323_cab;
	FUNCTION f_list323_det(
			p_sproces NUMBER DEFAULT NULL,
			p_cempres NUMBER DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list323_det';
	  v_tparam  VARCHAR2(1000);
	  v_ntraza  NUMBER:=0;
	  v_sep     VARCHAR2(1):=';';
	  v_ret     VARCHAR2(1):=chr(10);
	  v_init    VARCHAR2(32000);
	  v_ttexto  VARCHAR2(32000);
	BEGIN
	    IF nvl(pac_parametros.f_parlistado_n(p_cempres, 'LIST_PREVI_CARTERA'), 0)=1 THEN
	      v_ttexto:='SELECT
	        trunc(r.femisio)||'';''|| --femisio
	        G.SPROCES||'';''|| --num. proceso
	        f_formatopol(s.npoliza,s.ncertif,1)||'';''|| --polcertif
	        S.CRAMO||''-''||m.tramo||'';''||
	        S.SPRODUC||''-''||F_DESPRODUCTO_T(s.cramo,s.cmodali,s.ctipseg,s.ccolect,1,f_idiomauser)||'';''
	        /*--*/
	        ||(select pers1.nnumide
	                from seguros ss,tomadores tt, per_personas pers1
	                where ss.sseguro=tt.sseguro
	                and tt.sperson = pers1.sperson
	                and ss.sseguro= s.sseguro)||'';''
	        ||(select f_nombre(tt.sperson,1,ss.cagente)
	                from seguros ss,tomadores tt
	                where ss.sseguro=tt.sseguro
	                and ss.sseguro= s.sseguro)||'';''||
	        /*--*/
	        s.fcaranu||'';''|| --fefecto
	        DECODE(pac_parametros.f_parlistado_n(r.cempres, ''SUCURSAL/ADN''),
	        1, NVL(pac_redcomercial.f_busca_padre(r.cempres,
	        r.cagente, NULL, f_sysdate),''0'')|| '';'',NULL)
	        || s.cagente || '';'' ||
	        ff_desagente(s.cagente) || '';'' ||
	        ff_desvalorfijo(17, f_idiomauser, s.cforpag)||'';''|| --forma pago
	        r.fvencim||'';''|| -- fecha vencimiento recibo
	        r.nrecibo||'';''|| -- rebut
	        FF_DESGARANTIA(g.cgarant, f_idiomauser)||'';''|| --garant
	        g2.icaptot ||'';''|| --Capital Actual
	        g.icaptot ||'';''|| --Capital Futur
	        g2.iprianu ||'';''|| --Prima Actual
	        g.iprianu ||'';''|| --Prima Futura
	        ff_desvalorfijo(62, f_idiomauser, g.crevali)||'';''|| -- Tipo revalorización
	        g.prevali||'';''|| --Porc. revalorizacion
	        f_impgarant_car (r.sproces,r.nrecibo,''PRIMA TARIFA'',g.cgarant) ||'';''|| --Prima Neta
	        f_impgarant_car (r.sproces,r.nrecibo,''REC FPAGO'',g.cgarant) ||'';''|| --Recargo
	        f_impgarant_car (r.sproces,r.nrecibo,''CONSORCIO'',g.cgarant) ||'';''|| --Consorcio
	        f_impgarant_car (r.sproces,r.nrecibo,''IMPUESTO'',g.cgarant) ||'';''|| -- Impost
	        f_impgarant_car (r.sproces,r.nrecibo,''CLEA'',g.cgarant) ||'';''|| -- CLEA
	        f_impgarant_car (r.sproces,r.nrecibo,''PRIMA TOTAL'',g.cgarant) ||'';''|| --Prima Total
	        f_impgarant_car (r.sproces,r.nrecibo,''COMISION'',g.cgarant) ||'';''|| --Comision bruta
	        f_impgarant_car (r.sproces,r.nrecibo,''COMISION IND'',g.cgarant) ||'';''|| --Comision indirecta
	        f_impgarant_car (r.sproces,r.nrecibo,''IRPF'',g.cgarant) ||'';''|| --Retencion
	        f_impgarant_car (r.sproces,r.nrecibo,''LIQUIDO'',g.cgarant) ||'';''|| --Liquido
	        decode(nvl(pac_parametros.f_parlistado_n(pac_md_common.f_get_cxtempresa,''INDICE_SINIES''),0),0,NULL,
	        PAC_SINIESTROS.f_indice_siniestralidad(s.sseguro,g2.nriesgo,g2.cgarant,trunc(last_day(r.femisio)))
	         ||'';'')
	                    || pac_redcomercial.ff_desagente(NVL(pac_redcomercial.f_busca_padre(s.cempres, s.cagente, 2,
	                                                          TRUNC(s.fefecto)),
	                           s.cagente),'
	                || p_cempres
	                || ',1)  || '';''  -- sucursal
	                    || p.NNUMIDE || '';''  -- Nº ident asegurado
	                    || pac_isqlfor.ff_nombre(p.sperson,1) || '';''  -- Nombre asegurado
	                    || decode((select count(1) from garanseg where sseguro = s.sseguro and cgarant = 48 and icapital > 0),0,''No'',''Si'')
	        || '';''||
	        s.ndurcob
	        || '';''||
	        nvl(trunc(months_between(s.fefecto,s.fvencim)/12),1)
	        || '';''||
	        (select crespue from pregunpolseg where cpregun = 4103 and sseguro = s.sseguro and nmovimi = (select max(nmovimi) from pregunpolseg where sseguro = s.sseguro))
	        || '';''
	                    || pac_isqlfor.f_respuesta(s.sseguro, mv.nmovimi, 4086, f_idiomauser) || '';'' -- Nº asegurados
	                    || pac_isqlfor.f_respuesta(s.sseguro, mv.nmovimi, 4113, f_idiomauser) || '';'' -- Ocupacion
	                    || s.ncertif || '';'' -- Numero de certificado
	                    || (SELECT SUM(icapital)
	                       FROM garanseg gar, seguros seg
	                      WHERE gar.sseguro = seg.sseguro
	                        AND gar.sseguro = s.sseguro
	                        AND(gar.cgarant, seg.sproduc) IN(SELECT cgarant, sproduc
	                                                           FROM garanpro
	                                                          WHERE cbasica = 1)) || '';'' -- Valor asegurado
	                    || s.fvencim || '';'' -- Fecha fin vigencia
	                    || mv.nmovimi || '';'' -- Número movimiento
	                    || md.tatribu || '';'' -- Tipo movimiento
	                    || mm.tmotmov || '';'' -- Causa
	                    || mv.FEMISIO || '';'' -- Fecha emision movimiento
	                    || (select v.itotpri from vdetreciboscar v where r.sproces = v.sproces AND r.nrecibo = v.nrecibo) || '';'' -- Prima anual neta
	                    || (select v.itotdto from vdetreciboscar v where r.sproces = v.sproces AND r.nrecibo = v.nrecibo) || '';'' -- Descuento
	                    || (select v.iprinet from vdetreciboscar v where r.sproces = v.sproces AND r.nrecibo = v.nrecibo) || '';'' -- Prima faccionada, recibo fraccionado
	                    || ad.tatribu || '';'' -- Tipo Intermediario
	                    || NVL(ff_pcomisi(-1, s.sseguro, DECODE(f_es_renovacion(s.sseguro), 0, 2, 1),
	                                   r.fefecto),
	                        0) || '';'' -- % comision
	                    || DECODE((SELECT COUNT(1)
	                                     FROM psucontrolseg
	                                    WHERE sseguro = s.sseguro
	                                      AND ccontrol = 526031), 0, ''NO'', ''SI'') || '';'' -- Reaseguro facultativo
	                    || cd.tatribu || '';''  -- Tipo Coaseguro
	                    || NVL(s.fcarant, s.fefecto) || '';''
	                    || S.nsolici|| '';''||
	        (SELECT SUM(G.ICAPITAL)
	        FROM GARANSEG G, SEGUROS SEG
	        WHERE G.SSEGURO = S.SSEGURO
	        AND G.SSEGURO =  SEG.SSEGURO
	        AND G.NMOVIMI = (SELECT MIN(NMOVIMI) FROM GARANSEG WHERE SSEGURO = G.SSEGURO)
	        AND (G.CGARANT, SEG.SPRODUC) IN (SELECT CGARANT, SPRODUC FROM GARANPRO WHERE CBASICA=1))|| '';''||
	        CASE
	        WHEN S.sproduc IN(7029,702, 7030,7036,7035,7053,7037) THEN
	        (SELECT DECODE(1, 2, nfactor, pipc)
	          FROM ipc
	         WHERE nanyo = (SELECT TO_NUMBER(SUBSTR(MAX(LPAD(TO_CHAR(nanyo), 4, ''0'')
	                                                    || LPAD(TO_CHAR(nmes), 2, ''0'')),
	                                                1, 4)) anyo
	                          FROM ipc
	                         WHERE ctipo = 1
	                           AND((nmes = 0
	                                AND nanyo <= TO_NUMBER(TO_CHAR(mv.femisio, ''YYYY''))
	                                AND 1 = 0)
	                               OR(nmes <> 0
	                                  AND(LPAD(TO_CHAR(nanyo), 4, ''0'') || LPAD(TO_CHAR(nmes), 2, ''0'')) <=
	                                        (LPAD(TO_CHAR(mv.femisio, ''YYYY''), 4, ''0'')
	                                         || LPAD(TO_CHAR(mv.femisio, ''MM''), 2, ''0''))
	                                  AND 1 = 1)))
	           AND nmes = (SELECT TO_NUMBER(SUBSTR(MAX(LPAD(TO_CHAR(nanyo), 4, ''0'')
	                                                   || LPAD(TO_CHAR(nmes), 2, ''0'')),
	                                               5, 7))
	                         FROM ipc
	                        WHERE ctipo = 1
	                          AND((nmes = 0
	                               AND nanyo <= TO_NUMBER(TO_CHAR(mv.femisio, ''YYYY''))
	                               AND 1 = 0)
	                              OR(nmes <> 0
	                                 AND(LPAD(TO_CHAR(nanyo), 4, ''0'') || LPAD(TO_CHAR(nmes), 2, ''0'')) <=
	                                       (LPAD(TO_CHAR(mv.femisio, ''YYYY''), 4, ''0'')
	                                        || LPAD(TO_CHAR(mv.femisio, ''MM''), 2, ''0''))
	                                 AND 1 = 1)))
	           AND ctipo = 1)
	        ELSE S.prevali
	        END
		|| '';''
	        Linea
	        FROM SEGUROS S,  RECIBOSCAR R, GARANCAR G, garanseg g2,ramos m, garanpro gg, DETRECIBOSCAR d, agentes_agente_pol ap,
	        per_personas p, asegurados ag, tomadores t,
	        per_personas p2, movseguro mv, motmovseg mm, detvalores md, detvalores ad, agentes a, detvalores cd
	        WHERE
	        R.SSEGURO(+) = S.SSEGURO AND
	        G.SSEGURO = S.SSEGURO AND
	        G.SPROCES = '
	                || p_sproces
	                || ' AND
	        R.SPROCES(+) = '
	                || p_sproces
	                || ' AND
	        S.sproduc = gg.sproduc AND
	        G.cgarant = gg.cgarant AND
	        s.CEMPRES = ap.CEMPRES AND
	        s.cagente = ap.cagente AND
	        gg.ctipgar  <> 8 AND
	        R.fefecto(+) = s.fcaranu AND
	        m.cramo = s.cramo and m.cidioma = F_IdiomaUser and
	        g2.cgarant = g.cgarant and
	        g2.sseguro = g.sseguro and
	        g2.nmovimi = (select max(nmovimi) from garanseg g3 where g3.sseguro= s.sseguro) AND
	        d.sproces(+) = r.sproces AND
	        d.nrecibo(+) = r.nrecibo AND
	        NVL(d.cconcep,0) = 0 AND
	        NVL(d.cgarant,g.cgarant) =  g.cgarant AND
	        NVL(d.nriesgo,g.nriesgo) =  g.nriesgo AND
	        g.sproces = NVL(d.sproces,g.sproces) AND
	         g2.cgarant  = NVL(d.cgarant,g2.cgarant) AND
	         g2.nriesgo = nvl(d.nriesgo,g2.nriesgo) AND
	         gg.cgarant  =nvl( d.cgarant,gg.cgarant)

	        and ag.sseguro = s.sseguro
	        and ag.norden = 1
	        and p.sperson = ag.sperson
	        AND mv.sseguro = s.sseguro
	        AND mv.nmovimi = (select max(nmovimi) from movseguro where sseguro = s.sseguro)
	        AND mv.cmotmov = mm.cmotmov
	        AND mm.cidioma = f_idiomauser
	        and md.cvalor = 16
	        and md.cidioma = f_idiomauser
	        and md.catribu = mv.cmovseg
	        and a.cagente = s.cagente
	        and ad.cvalor = 30
	        and ad.cidioma = f_idiomauser
	        and ad.catribu = a.ctipage
	        and cd.cvalor = 800109
	        and cd.cidioma = f_idiomauser
	        and cd.catribu = s.ctipcoa
	        AND t.sperson = p2.sperson
	        and t.sseguro = s.sseguro

	        ORDER BY s.cramo,S.sproduc, fcaranu, npoliza,ncertif, r.nrecibo, gg.norden';
	    ELSE
	    /* decode(pac_parametros.f_parlistado_n(S.CEMPRES,''INFO_AGENTE_COMERC''),1,f_desagente_t(r.cagente)|| '';'' ,chr(39)||chr(39))||                                                                                                                        */
	    /*     (select ctipage from agentes where cagente = s.cagente)||'';''|| */
	      /*                                                                        pac_redcomercial.f_get_desnivel((select ctipage from agentes where cagente = s.cagente), r.cempres, f_idiomauser)||'';''||  */

	      v_ttexto:='SELECT
	        trunc(r.femisio)||'';''|| --femisio
	        G.SPROCES||'';''|| --n.proceso
	        f_formatopol(s.npoliza,s.ncertif,1)||'';''|| --pcertif
	        S.CRAMO||''-''||m.tramo||'';''||
	        S.SPRODUC||''-''||F_DESPRODUCTO_T(s.cramo,s.cmodali,s.ctipseg,s.ccolect,1,f_idiomauser)||'';''||
	        s.nsolici||'';''
	        ||(select to_char(count(r.nriesgo))
	          from riesgos r
	          where r.sseguro=s.sseguro)||'';''
	        ||(select f_nombre(tt.sperson,1,ss.cagente)
	          from seguros ss,tomadores tt
	          where ss.sseguro=tt.sseguro
	          and ss.sseguro= s.sseguro)||'';''||
	        s.fcaranu||'';''|| --fefecto
	        decode(pac_parametros.f_parlistado_n(S.CEMPRES,''SUCURSAL/ADN''),1,nvl(pac_redcomercial.f_busca_padre(S.cempres,nvl(R.cagente,S.cagente),null,f_sysdate),''0'') || '';'' ,chr(39)||chr(39))||
	        s.cagente||'';''|| --cagente
	        decode(pac_parametros.f_parlistado_n(S.CEMPRES,''INFO_AGENTE_COMERC''),1,f_desagente_t(r.cagente)||'';''||
	        F_BUSCAZONA(s.cempres, r.cagente, 3, f_sysdate)||'';''||ff_desagente(F_BUSCAZONA(s.cempres, r.cagente, 3, f_sysdate))||'';'' ,chr(39)||chr(39))||
	        ff_desvalorfijo(17, f_idiomauser, s.cforpag)||'';''|| --forma pago
	        r.fvencim||'';''|| -- fecha vencim.
	        r.nrecibo||'';''|| -- rebut
	        FF_DESGARANTIA(g.cgarant, f_idiomauser)||'';''|| --garant
	        g2.icaptot ||'';''|| --CapitalActual
	        g.icaptot ||'';''|| --CapitalFutur
	        g2.iprianu ||'';''|| --PrimaActual
	        g.iprianu ||'';''|| --PrimaFutura
	        ff_desvalorfijo(62, f_idiomauser, g.crevali)||'';''|| --T.revaloriz
	        g.prevali||'';''|| --Porc. revalorizacion
	        f_impgarant_car (r.sproces,r.nrecibo,''PRIMA TARIFA'',g.cgarant) ||'';''|| --Prima Neta
	        f_impgarant_car (r.sproces,r.nrecibo,''REC FPAGO'',g.cgarant) ||'';''|| --Recargo
	        f_impgarant_car (r.sproces,r.nrecibo,''CONSORCIO'',g.cgarant) ||'';''|| --Consorcio
	        f_impgarant_car (r.sproces,r.nrecibo,''IMPUESTO'',g.cgarant) ||'';''|| -- Impost
	        f_impgarant_car (r.sproces,r.nrecibo,''CLEA'',g.cgarant) ||'';''|| --CLEA
	        f_impgarant_car (r.sproces,r.nrecibo,''PRIMA TOTAL'',g.cgarant) ||'';''|| --Prima Total
	        f_impgarant_car (r.sproces,r.nrecibo,''COMISION'',g.cgarant) ||'';''|| --Comision bruta
	        f_impgarant_car (r.sproces,r.nrecibo,''COMISION IND'',g.cgarant) ||'';''|| --Comision indirecta
	        f_impgarant_car (r.sproces,r.nrecibo,''IRPF'',g.cgarant) ||'';''|| --Retencion
	        f_impgarant_car (r.sproces,r.nrecibo,''LIQUIDO'',g.cgarant) ||'';''|| --Liquido
	        decode(nvl(pac_parametros.f_parlistado_n(pac_md_common.f_get_cxtempresa,''INDICE_SINIES''),0),0,NULL,
	        PAC_SINIESTROS.f_indice_siniestralidad(s.sseguro,g2.nriesgo,g2.cgarant,trunc(last_day(r.femisio)))
	        || '';'')
	        Linea
	        FROM SEGUROS S,  RECIBOSCAR R, GARANCAR G, garanseg g2,ramos m, garanpro gg, DETRECIBOSCAR d, agentes_agente_pol ap
	        WHERE
	        R.SSEGURO(+) = S.SSEGURO AND
	        G.SSEGURO = S.SSEGURO AND
	        G.SPROCES = '
	                || p_sproces
	                || ' AND
	        R.SPROCES(+) = '
	                || p_sproces
	                || ' AND
	        S.sproduc = gg.sproduc AND
	        G.cgarant = gg.cgarant AND
	        s.CEMPRES = ap.CEMPRES AND
	        s.cagente = ap.cagente AND
	        gg.ctipgar  <> 8 AND
	        R.fefecto(+) = s.fcaranu AND
	        m.cramo = s.cramo and m.cidioma = F_IdiomaUser and
	        g2.cgarant = g.cgarant and
	        g2.sseguro = g.sseguro and
	        g2.nmovimi = (select max(nmovimi) from garanseg g3 where g3.sseguro= s.sseguro) AND
	        d.sproces(+) = r.sproces AND
	        d.nrecibo(+) = r.nrecibo AND
	        NVL(d.cconcep,0) = 0 AND
	        NVL(d.cgarant,g.cgarant) =  g.cgarant AND
	        NVL(d.nriesgo,g.nriesgo) =  g.nriesgo AND
	        g.sproces = NVL(d.sproces,g.sproces) AND
	        g2.cgarant  = NVL(d.cgarant,g2.cgarant) AND
	        g2.nriesgo = nvl(d.nriesgo,g2.nriesgo) AND
	        gg.cgarant  =nvl( d.cgarant,gg.cgarant)
	        ORDER BY s.cramo,S.sproduc, fcaranu, npoliza,ncertif, r.nrecibo, gg.norden';
	    END IF;

	    RETURN(v_ttexto);
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list323_det;
	FUNCTION f_list324_cab(
			p_cempres NUMBER DEFAULT NULL,
			p_fecha VARCHAR2 DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list324_cab';
	  v_tparam  VARCHAR2(1000);
	  v_ntraza  NUMBER:=0;
	  v_sep     VARCHAR2(1):=';';
	  v_ret     VARCHAR2(1):=chr(10);
	  v_init    VARCHAR2(32000);
	  v_ttexto  VARCHAR2(32000);
	BEGIN
	    IF nvl(pac_parametros.f_parlistado_n(p_cempres, 'LIST_PREVI_CARTERA'), 0)=1 THEN
	      v_ttexto:='Select f_axis_literales(100836,f_idiomauser)||'';''||
	            f_axis_literales(100784,f_idiomauser)||'';''||
	            f_axis_literales(100829,f_idiomauser)||'';''||
	            f_axis_literales(102999, f_idiomauser) ||'';''|| -- Número documento tomador
	            f_axis_literales(101027,f_idiomauser)||'';''||
	            f_axis_literales(100895,f_idiomauser)||'';''||
	            f_axis_literales(100712,f_idiomauser)||'';''||
	            f_axis_literales(101332,f_idiomauser)||'';''||
	            f_axis_literales(101274,f_idiomauser)||'';''||
	            f_axis_literales(106053,f_idiomauser)||'';''||
	            decode(pac_parametros.f_parlistado_n(NVL(pac_md_common.f_get_cxtempresa,
	                                                                  f_parinstalacion_n(''EMPRESADEF'')),
	                                                              ''SUCURSAL/ADN''),1,f_axis_literales(9903035,f_idiomauser),null)||
	            f_axis_literales(100584,f_idiomauser)||'';''||
	            f_axis_literales(102995, f_idiomauser)||'';''||
	            f_axis_literales(105171,f_idiomauser)||'';''||
	            f_axis_literales(100916,f_idiomauser)||'';''||
	            f_axis_literales(101278,f_idiomauser)||'';''||
	            f_axis_literales(801270,f_idiomauser) ||'';''||
	            f_axis_literales(1000529,f_idiomauser)||'';''||
	            f_axis_literales(103170,f_idiomauser)||'';''||
	            f_axis_literales(9002214,f_idiomauser)||'';''|| -- Otras comisiones
	            f_axis_literales(101714,f_idiomauser)||'';''||
	            f_axis_literales(110332,f_idiomauser)||'';''||
	            f_axis_literales(1000553,f_idiomauser) ||'';'' -- Estado recibo
	            || f_axis_literales(9002202, f_idiomauser)|| '';'' --Sucursal
	            || f_axis_literales(9000875, f_idiomauser)|| '';'' -- Numero de solicitud
	            || f_axis_literales(9000477, f_idiomauser)|| '';'' -- numero asegurados
	            || f_axis_literales(102999, f_idiomauser)|| '';'' -- Número documento asegurado
	            || f_axis_literales(101028, f_idiomauser)|| '';'' -- Nombre asegurado
	            || f_axis_literales(9902911, f_idiomauser) || '';'' -- Número certificado
	            || f_axis_literales(9906957, f_idiomauser)|| '';'' -- valor asegurado inicial
	            || f_axis_literales(9902924, f_idiomauser)|| '';'' -- Valor asegurado actual
	            || f_axis_literales(9906959, f_idiomauser)|| '';''  -- Fecha inicio vigencia
	            || f_axis_literales(9902716, f_idiomauser)|| '';'' -- Fecha fin vigencia
	            || f_axis_literales(9001954, f_idiomauser)|| '';''  -- N  Movimiento
	            || f_axis_literales(102421, f_idiomauser)|| '';''   -- Tipo Movimiento
	            || f_axis_literales(101040, f_idiomauser)|| '';''   -- Causa  Movimiento
	            || f_axis_literales(9902048, f_idiomauser)|| '';'' -- Prima anual
	            || f_axis_literales(9002032, f_idiomauser)|| '';'' -- Sobreprima
	            || f_axis_literales(9902964, f_idiomauser)|| '';'' -- Valor comisión
	            || f_axis_literales(140531,f_idiomauser) || '';'' --Prima total
	            || f_axis_literales(9902122, f_idiomauser)|| '';'' -- Prima fraccionada(recibios fraccionados)
	            || f_axis_literales(9903395, f_idiomauser)|| '';'' -- Tipo intermediario
	            || f_axis_literales(9000531,f_idiomauser) || '';'' -- Clave Agente (Código)
	            || f_axis_literales(100584, f_idiomauser) || '';''  -- Nombre Agente
	            || f_axis_literales(9905833, f_idiomauser)|| '';'' -- Facultativo
	            || f_axis_literales(9902935, f_idiomauser)|| '';'' -- Tipo coaseguro
	            || f_axis_literales(9906787, f_idiomauser)|| '';'' -- Marca ahorro
	            || f_axis_literales(9906788, f_idiomauser) || '';'' --Años pago de prima
	            || f_axis_literales(9906790, f_idiomauser)|| '';'' -- %dote a recibir
	            || f_axis_literales(9001923, f_idiomauser) '; -- % comisión
	    ELSE
	      v_ttexto:='Select f_axis_literales(100836,f_idiomauser)||'';''||
	            f_axis_literales(100784,f_idiomauser)||'';''||
	            f_axis_literales(100829,f_idiomauser)||'';''||
	            f_axis_literales(101027,f_idiomauser)||'';''||
	            f_axis_literales(100895,f_idiomauser)||'';''||
	            f_axis_literales(100712,f_idiomauser)||'';''||
	            f_axis_literales(101332,f_idiomauser)||'';''||
	            f_axis_literales(101274,f_idiomauser)||'';''||
	            f_axis_literales(106053,f_idiomauser)||'';''||
	            decode(pac_parametros.f_parlistado_n(NVL(pac_md_common.f_get_cxtempresa,
	                                                                  f_parinstalacion_n(''EMPRESADEF'')),
	                                                              ''SUCURSAL/ADN''),1,f_axis_literales(9903035,f_idiomauser),null)||
	            f_axis_literales(100584,f_idiomauser)||'';''||
	            f_axis_literales(102995, f_idiomauser)||'';''||
	            f_axis_literales(105171,f_idiomauser)||'';''||
	            f_axis_literales(100916,f_idiomauser)||'';''||
	            f_axis_literales(101278,f_idiomauser)||'';''||
	            f_axis_literales(801270,f_idiomauser) ||'';''||
	            f_axis_literales(1000529,f_idiomauser)||'';''||
	            f_axis_literales(103170,f_idiomauser)||'';''||
	            f_axis_literales(9002214,f_idiomauser)||'';''|| -- Otras comisiones
	            f_axis_literales(101714,f_idiomauser)||'';''||
	            f_axis_literales(110332,f_idiomauser)||'';''||
	            f_axis_literales(1000553,f_idiomauser) -- Estado rec';
	    END IF;

	    v_ttexto:=v_ttexto
	              || '
	            Linea from dual';

	    RETURN(v_ttexto);
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list324_cab;
	FUNCTION f_list324_det(
			p_cempres NUMBER DEFAULT NULL,
			p_fecha VARCHAR2 DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list324_det';
	  v_tparam  VARCHAR2(1000);
	  v_ntraza  NUMBER:=0;
	  v_sep     VARCHAR2(1):=';';
	  v_ret     VARCHAR2(1):=chr(10);
	  v_init    VARCHAR2(32000);
	  v_ttexto  VARCHAR2(32000);
	BEGIN
	    IF nvl(pac_parametros.f_parlistado_n(p_cempres, 'LIST_PREVI_CARTERA'), 0)=1 THEN -- A esta select faltan anadir los nuevos campos
	      v_ttexto:='SELECT
	        f_formatopol(s.npoliza,s.ncertif,1)||'';''||
	        S.CRAMO||''-''||m.tramo||'';''||
	        S.SPRODUC||''-''||F_DESPRODUCTO_T(s.cramo,s.cmodali,s.ctipseg,s.ccolect,1,f_idiomauser)||'';''||
	        (select pers1.nnumide
	                from per_personas pers1
	                where TOMADORES.sperson = pers1.sperson)||'';''|| -- Documento tomador
	        f_nombre(TOMADORES.SPERSON,3,S.cagente)||'';''||
	        r.nrecibo||'';''||
	        decode(S.CFORPAG, 0,''U'', 1,''A'',2,''S'',3,''C'',4,''T'',6,''S'',12,''M'')||'';''||
	        to_char(S.FEFECTO,''dd-mm-yyyy'')||'';''||
	        to_char(R.FEMISIO,''dd-mm-yyyy'')||'';''||
	        to_char(r.fefecto,''dd-mm-yyyy'')||''/''||to_char(r.fvencim-1,''dd-mm-yyyy'')||'';''||
	        decode(pac_parametros.f_parlistado_n(S.CEMPRES,''SUCURSAL/ADN''),1,nvl(pac_redcomercial.f_busca_padre(S.cempres,nvl(R.cagente,S.cagente),null,f_sysdate),''0'') || '';'' ,chr(39)||chr(39))||
	        r.cagente||'';''||
	        (decode(s.ctipcoa,1,v.iprinet + v.icednet,v.iprinet))||'';''|| --PrimaNeta
	        (decode(s.ctipcoa,1,v.irecfra + v.icedrfr,v.irecfra))||'';''|| --Recargos
	        v.itotcon||'';''|| --Consorcio
	        v.itotimp||'';''|| --Impuestos
	        v.idgs||'';''|| --CLEA
	        v.itotalr||'';''|| --Total
	        (decode(s.ctipcoa,1,v.icombru + v.icedcbr,v.icombru))||'';''|| --ComiBruta normal
	        (decode(s.ctipcoa,1,v.icombrui + v.icedcbr,v.icombrui))||'';''|| --ComiBruta indirecta
	        (decode(s.ctipcoa,1,v.icomret + v.icedcrt,v.icomret))||'';''|| --retencion
	            (
	            (
	             (decode(s.ctipcoa,1,v.iprinet + v.icednet,v.iprinet))+
	             (decode(s.ctipcoa,1,v.irecfra + v.icedrfr,v.irecfra))
	            ) /* PrimaNeta+Recargo*/
	             -
	            decode(s.ctipcoa,1,v.icombru + v.icedcbr,v.icombru) -
	            decode(s.ctipcoa,1,v.icomret + v.icedcrt,v.icomret) -
	            v.itotcon -
	            v.itotimp) ||'';''|| --Liquido

	        ff_desvalorfijo(1, f_idiomauser, f_cestrec(r.nrecibo, f_sysdate)) /* Estado recibo  */

	        || '';''||
	        REPLACE(pac_redcomercial.ff_desagente(NVL(pac_redcomercial.f_busca_padre(s.cempres, s.cagente, 2,
	                                                          TRUNC(s.fefecto)),
	                           s.cagente),'
	                || p_cempres
	                || ',1),'','','''')
	        || '';''|| --sucursal
	        s.nsolici|| '';''|| -- numero de solicitud
	        pac_isqlfor.f_respuesta (s.sseguro, mv.nmovimi, 4086, f_idiomauser)|| '';''|| --n asegurados
	        (select pers1.nnumide
	                from  per_personas pers1
	                where ASEGURADOS.sperson = pers1.sperson)||'';''|| -- Documento Asegurado
	        f_nombre(ASEGURADOS.sperson,3,S.cagente)||'';''||-- nombre segurado
	        s.ncertif || '';'' ||   -- numero de certificado
	        (SELECT SUM(G.ICAPITAL)
	        FROM GARANSEG G, SEGUROS SEG
	        WHERE G.SSEGURO = s.SSEGURO
	        AND G.SSEGURO =  SEG.SSEGURO
	        AND G.NMOVIMI = (SELECT MIN(NMOVIMI) FROM GARANSEG WHERE SSEGURO = G.SSEGURO)
	        AND (G.CGARANT, SEG.SPRODUC) IN (SELECT CGARANT, SPRODUC FROM GARANPRO WHERE CBASICA=1))|| '';''|| -- valor asegurado inicial
	        (select sum(icapital)
	         from garanseg gar, seguros seg
	        where gar.sseguro = s.sseguro
	        and gar.sseguro = seg.sseguro
	        and (gar.cgarant,seg.sproduc) in (select cgarant, sproduc from garanpro where cbasica = 1))|| '';''|| -- Valor asegurado
	        NVL(s.fcarant, s.fefecto) || '';''|| -- Fecha inicio vigencia
	        s.fvencim || '';''|| --FECHA FIN vigencia
	        mv.nmovimi || '';''||-- numero de movimiento
	        md.tatribu || '';''|| --tipo movimiento
	        mm.tmotmov || '';''|| -- causa movimiento
	        v.itotpri || '';''|| -- prima anual
	        v.it1rec || '';'' || -- valor sobreprima
	        v.icombru || '';'' || -- valor comision
	        v.itotalr ||'';''|| -- Prima Total
	        v.iprinet || '';''|| -- recibos fraccionados
	        ad.tatribu || '';''|| -- tipo intermediario
	        s.cagente || '';'' ||
	        REPLACE(ff_desagente(s.cagente),'','','''') || '';'' ||
	        decode((select count(1) from psucontrolseg where sseguro = s.sseguro and ccontrol =526031),0,''NO'',''SI'') || '';''|| --facultativo
	        cd.tatribu || '';''|| --tipo coaseguro
	        decode((select count(1) from garanseg where sseguro = s.sseguro and cgarant = 48 and icapital > 0),0,''No'',''Si'')
	        || '';''|| --marca ahorro
	        s.ndurcob|| '';''|| -- años pagos prima
	        (select crespue from pregunpolseg where cpregun = 4103
	        and sseguro = s.sseguro and nmovimi = (select max(nmovimi)
	         from pregunpolseg where sseguro = s.sseguro))
	        || '';''||  -- %dortes recibir
	        nvl(ff_pcomisi(-1,s.sseguro,decode(f_es_renovacion(s.sseguro),0,2,1),r.fefecto),0) || '';'' --porc comcion
	        Linea
	        FROM TOMADORES, ASEGURADOS, SEGUROS s, VDETRECIBOS v, RECIBOS r, ramos m, agentes_agente_pol ap, movseguro mv, motmovseg mm, detvalores md,detvalores cd,detvalores ad,agentes a
	        WHERE mv.sseguro = s.sseguro
	        AND mv.nmovimi = (select max(nmovimi) from movseguro where sseguro = s.sseguro)
	        AND mv.cmotmov = mm.cmotmov
	        AND mm.cidioma = f_idiomauser
	        and md.cvalor = 16
	        and md.cidioma = f_idiomauser
	        and md.catribu = mv.cmovseg
	        and R.SSEGURO = S.SSEGURO AND
	        S.CEMPRES = '
	                || p_cempres
	                || ' AND s.CEMPRES = ap.CEMPRES AND
	        s.cagente = ap.cagente AND
	        R.FEMISIO = to_date('''
	                || p_fecha
	                || ''',''ddmmyyyy'') AND
	        R.CTIPREC = 3 AND
	        R.NRECIBO = V.NRECIBO AND
	        TOMADORES.SSEGURO=S.SSEGURO AND
	        m.cramo = s.cramo and m.cidioma = F_IdiomaUser  and
	        TOMADORES.NORDTOM=1 AND
	        ASEGURADOS.SSEGURO(+)= S.SSEGURO AND
	        ASEGURADOS.NORDEN (+)= 1 AND
	        R.CTIPREC = 3
	        and cd.cvalor = 800109
	        and cd.cidioma = f_idiomauser
	        and cd.catribu = s.ctipcoa
	        and ad.cvalor = 30
	        and ad.cidioma = f_idiomauser
	        and ad.catribu = a.ctipage
	        and a.cagente = s.cagente
	        and (r.sseguro, r.nmovimi) not in
	        (select sseguro, nmovimi from movseguro where cmovseg = 52)
	        ORDER BY
	           S.CRAMO, S.CMODALI,S.NPOLIZA,S.NCERTIF';
	    ELSE
	      v_ttexto:='SELECT
	        f_formatopol(s.npoliza,s.ncertif,1)||'';''||
	        S.CRAMO||''-''||m.tramo||'';''||
	        S.SPRODUC||''-''||F_DESPRODUCTO_T(s.cramo,s.cmodali,s.ctipseg,s.ccolect,1,f_idiomauser)||'';''||
	        f_nombre(TOMADORES.SPERSON,1,S.cagente)||'';''||
	        r.nrecibo||'';''||
	        decode(S.CFORPAG, 0,''U'', 1,''A'',2,''S'',3,''C'',4,''T'',6,''S'',12,''M'')||'';''||
	        to_char(S.FEFECTO,''dd-mm-yyyy'')||'';''||
	        to_char(R.FEMISIO,''dd-mm-yyyy'')||'';''||
	        to_char(r.fefecto,''dd-mm-yyyy'')||''/''||to_char(r.fvencim-1,''dd-mm-yyyy'')||'';''||
	        decode(pac_parametros.f_parlistado_n(S.CEMPRES,''SUCURSAL/ADN''),1,nvl(pac_redcomercial.f_busca_padre(S.cempres,nvl(R.cagente,S.cagente),null,f_sysdate),''0'') || '';'' ,chr(39)||chr(39))||
	        r.cagente||'';''||
	        (decode(s.ctipcoa,1,v.iprinet + v.icednet,v.iprinet))||'';''|| --PrimaNeta
	        (decode(s.ctipcoa,1,v.irecfra + v.icedrfr,v.irecfra))||'';''|| --Recargos
	        v.itotcon||'';''|| --Consorcio
	        v.itotimp||'';''|| --Impuestos
	        v.idgs||'';''|| --CLEA
	        v.itotalr||'';''|| --Total
	        (decode(s.ctipcoa,1,v.icombru + v.icedcbr,v.icombru))||'';''|| --ComiBruta normal
	        (decode(s.ctipcoa,1,v.icombrui + v.icedcbr,v.icombrui))||'';''|| --ComiBruta indirecta
	        (decode(s.ctipcoa,1,v.icomret + v.icedcrt,v.icomret))||'';''|| --retencion
	            (
	            (
	             (decode(s.ctipcoa,1,v.iprinet + v.icednet,v.iprinet))+
	             (decode(s.ctipcoa,1,v.irecfra + v.icedrfr,v.irecfra))
	            ) /* PrimaNeta+Recargo*/
	             -
	            decode(s.ctipcoa,1,v.icombru + v.icedcbr,v.icombru) -
	            decode(s.ctipcoa,1,v.icomret + v.icedcrt,v.icomret) -
	            v.itotcon -
	            v.itotimp) ||'';''|| --Liquido

	        ff_desvalorfijo(1, f_idiomauser, f_cestrec(r.nrecibo, f_sysdate)) /* Estado recibo    */
	        Linea
	        FROM TOMADORES, ASEGURADOS, SEGUROS s, VDETRECIBOS v, RECIBOS r, ramos m, agentes_agente_pol ap
	        WHERE
	        R.SSEGURO = S.SSEGURO AND
	        S.CEMPRES = '
	                || p_cempres
	                || ' AND s.CEMPRES = ap.CEMPRES AND
	        s.cagente = ap.cagente AND
	        R.FEMISIO = to_date('''
	                || p_fecha
	                || ''',''ddmmyyyy'') AND
	        R.CTIPREC = 3 AND
	        R.NRECIBO = V.NRECIBO AND
	        TOMADORES.SSEGURO=S.SSEGURO AND
	        m.cramo = s.cramo and m.cidioma = F_IdiomaUser  and
	        TOMADORES.NORDTOM=1 AND
	        ASEGURADOS.SSEGURO(+)= S.SSEGURO AND
	        ASEGURADOS.NORDEN (+)= 1 AND
	        R.CTIPREC = 3 AND
	        (r.sseguro, r.nmovimi) not in
	        (select sseguro, nmovimi from movseguro where cmovseg = 52)
	        ORDER BY
	           S.CRAMO, S.CMODALI,S.NPOLIZA,S.NCERTIF';
	    END IF;

	    RETURN(v_ttexto);
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list324_det;

	/*
	   FUNCTION f_list325_cab(p_cempres NUMBER DEFAULT NULL, p_fecha VARCHAR2 DEFAULT NULL)
	      RETURN VARCHAR2 IS
	      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES.f_list325_cab';
	      v_tparam       VARCHAR2(1000);
	      v_ntraza       NUMBER := 0;
	      v_sep          VARCHAR2(1) := ';';
	      v_ret          VARCHAR2(1) := CHR(10);
	      v_init         VARCHAR2(32000);
	      v_ttexto       VARCHAR2(32000);
	   BEGIN
	      IF NVL(pac_parametros.f_parlistado_n(p_cempres, 'LIST_PREVI_CARTERA'), 0) = 1 THEN
	         v_ttexto :=
	            'Select
	        f_axis_literales(101274,f_idiomauser)||'';''|| -- F. Emisión
	        f_axis_literales(100836,f_idiomauser)||'';''|| -- Núm. póliza
	        f_axis_literales(100784,f_idiomauser)||'';''|| -- Ramo
	        f_axis_literales(100829,f_idiomauser)||'';''|| -- Producto
	        f_axis_literales(9000875,f_idiomauser)||'';''|| -- Nº Solicitud
	        f_axis_literales(109604,f_idiomauser)||'';''|| -- Nº Riesgos:
	        f_axis_literales(101027,f_idiomauser)||'';''||-- Tomador
	        f_axis_literales(101332,f_idiomauser)||'';''|| -- F.efecto

	                    decode(pac_parametros.f_parlistado_n(NVL(pac_md_common.f_get_cxtempresa,
	                                                                          f_parinstalacion_n(''EMPRESADEF'')),
	                                                                      ''SUCURSAL/ADN''),1,f_axis_literales(9903035,f_idiomauser),null)||
	        f_axis_literales(100584,f_idiomauser)||'';''|| -- Agente
	        f_axis_literales(9000719,f_idiomauser)||'';''|| -- forma pago
	        f_axis_literales(9902088,f_idiomauser)||'';''|| -- F. venc. rec.
	        f_axis_literales(100895,f_idiomauser)||'';''|| -- Recibo
	        f_axis_literales(100561,f_idiomauser)||'';''||-- Garantía
	        f_axis_literales(805908,f_idiomauser)||'';''|| -- Capital ant.:
	        f_axis_literales(805907,f_idiomauser)||'';''|| -- Capital act.:
	        f_axis_literales(152178,f_idiomauser)||'';''|| -- Prima anterior
	        f_axis_literales(1000516,f_idiomauser)||'';''|| -- Prima actual
	        f_axis_literales(102995,f_idiomauser)||'';''|| -- Prima neta
	        f_axis_literales(101432,f_idiomauser)||'';''|| -- Tipo de crecimiento;
	        f_axis_literales(9001317,f_idiomauser)||'';''|| -- Valor revalorización (Porcentaje)
	        f_axis_literales(101369,f_idiomauser) ||'';''|| -- Recargo
	        f_axis_literales(100916,f_idiomauser) ||'';''||-- Consorcio
	        f_axis_literales(800422,f_idiomauser) ||'';''|| -- Impuesto
	        f_axis_literales(140531,f_idiomauser) ||'';''||-- Prima total
	        f_axis_literales(103170,f_idiomauser)||'';''||-- Comis. bruta
	        f_axis_literales(9002214,f_idiomauser)||'';''|| -- Otras comisiones
	        f_axis_literales(101714,f_idiomauser) ||'';''||-- Retención
	        f_axis_literales(110332,f_idiomauser) ||'';''|| -- Líquido
	        decode(nvl(pac_parametros.f_parlistado_n(pac_md_common.f_get_cxtempresa,''INDICE_SINIES''),0),0,NULL,f_axis_literales(9904847, f_idiomauser))||'';''||
	        f_axis_literales(1000553,f_idiomauser) -- Estado recibo

	         || f_axis_literales(9002202, f_idiomauser)|| '';'' --Sucursal
	        || f_axis_literales(9000875, f_idiomauser)|| '';'' -- Numero de solicitud
	        || f_axis_literales(9000477, f_idiomauser)|| '';'' -- numero asegurados
	        || f_axis_literales(9904804, f_idiomauser)|| '';'' -- ocupacion
	        || f_axis_literales(102999, f_idiomauser)|| '';'' -- Número documento asegurado
	        || f_axis_literales(101028, f_idiomauser)|| '';'' -- Nombre asegurado
	        || f_axis_literales(9902911, f_idiomauser) || '';'' -- Número certificado
	        || f_axis_literales(9906957, f_idiomauser)|| '';'' -- valor asegurado inicial
	        || f_axis_literales(9902924, f_idiomauser)|| '';'' -- Valor asegurado actual
	        || f_axis_literales(9906959, f_idiomauser)|| '';''  -- Fecha inicio vigencia
	        || f_axis_literales(9902716, f_idiomauser)|| '';'' -- Fecha fin vigencia
	        || f_axis_literales(9001954, f_idiomauser)|| '';''  -- N  Movimiento
	        || f_axis_literales(102421, f_idiomauser)|| '';''   -- Tipo Movimiento
	        || f_axis_literales(101040, f_idiomauser)|| '';''   -- Causa  Movimiento
	        || f_axis_literales(9902048, f_idiomauser)|| '';'' -- Prima anual
	        || f_axis_literales(9002032, f_idiomauser)|| '';'' -- Sobreprima
	        || f_axis_literales(9902964, f_idiomauser)|| '';'' -- Valor comisión
	        || f_axis_literales(140531,f_idiomauser) || '';'' --Prima total
	        || f_axis_literales(9902122, f_idiomauser)|| '';'' -- Prima fraccionada(recibios fraccionados)
	        || f_axis_literales(9903395, f_idiomauser)|| '';'' -- Tipo intermediario
	        || f_axis_literales(9000531,f_idiomauser) || '';'' -- Clave Agente (Código)
	        || f_axis_literales(100584, f_idiomauser) || '';''  -- Nombre Agente
	        || f_axis_literales(9905833, f_idiomauser)|| '';'' -- Facultativo
	        || f_axis_literales(9902935, f_idiomauser)|| '';'' -- Tipo coaseguro
	        || f_axis_literales(9906787, f_idiomauser)|| '';'' -- Marca ahorro
	        || f_axis_literales(9906788, f_idiomauser) || '';'' --Años pago de prima
	        || f_axis_literales(9906790, f_idiomauser)|| '';'' -- %dote a recibir
	        || f_axis_literales(9001923, f_idiomauser) ';   -- % comisión
	      -- ALTAN LOS CAMPOS NUEVOS
	      ELSE
	         v_ttexto :=
	            'Select
	        f_axis_literales(101274,f_idiomauser)||'';''|| -- F. Emisión
	        f_axis_literales(100836,f_idiomauser)||'';''|| -- Núm. póliza
	        f_axis_literales(100784,f_idiomauser)||'';''|| -- Ramo
	        f_axis_literales(100829,f_idiomauser)||'';''|| -- Producto
	        f_axis_literales(9000875,f_idiomauser)||'';''|| -- Nº Solicitud
	        f_axis_literales(109604,f_idiomauser)||'';''|| -- Nº Riesgos:
	        f_axis_literales(101027,f_idiomauser)||'';''||-- Tomador
	        f_axis_literales(101332,f_idiomauser)||'';''|| -- F.efecto

	                    decode(pac_parametros.f_parlistado_n(NVL(pac_md_common.f_get_cxtempresa,
	                                                                          f_parinstalacion_n(''EMPRESADEF'')),
	                                                                      ''SUCURSAL/ADN''),1,f_axis_literales(9903035,f_idiomauser),null)||
	        f_axis_literales(100584,f_idiomauser)||'';''|| -- Agente
	        f_axis_literales(9000719,f_idiomauser)||'';''|| -- forma pago
	        f_axis_literales(9902088,f_idiomauser)||'';''|| -- F. venc. rec.
	        f_axis_literales(100895,f_idiomauser)||'';''|| -- Recibo
	        f_axis_literales(100561,f_idiomauser)||'';''||-- Garantía
	        f_axis_literales(805908,f_idiomauser)||'';''|| -- Capital ant.:
	        f_axis_literales(805907,f_idiomauser)||'';''|| -- Capital act.:
	        f_axis_literales(152178,f_idiomauser)||'';''|| -- Prima anterior
	        f_axis_literales(1000516,f_idiomauser)||'';''|| -- Prima actual
	        f_axis_literales(102995,f_idiomauser)||'';''|| -- Prima neta
	        f_axis_literales(101432,f_idiomauser)||'';''|| -- Tipo de crecimiento;
	        f_axis_literales(9001317,f_idiomauser)||'';''|| -- Valor revalorización (Porcentaje)
	        f_axis_literales(101369,f_idiomauser) ||'';''|| -- Recargo
	        f_axis_literales(100916,f_idiomauser) ||'';''||-- Consorcio
	        f_axis_literales(800422,f_idiomauser) ||'';''|| -- Impuesto
	        f_axis_literales(140531,f_idiomauser) ||'';''||-- Prima total
	        f_axis_literales(103170,f_idiomauser)||'';''||-- Comis. bruta
	        f_axis_literales(9002214,f_idiomauser)||'';''|| -- Otras comisiones
	        f_axis_literales(101714,f_idiomauser) ||'';''||-- Retención
	        f_axis_literales(110332,f_idiomauser) ||'';''|| -- Líquido
	        decode(nvl(pac_parametros.f_parlistado_n(pac_md_common.f_get_cxtempresa,''INDICE_SINIES''),0),0,NULL,f_axis_literales(9904847, f_idiomauser))||'';''||
	        f_axis_literales(1000553,f_idiomauser) -- Estado recibo';
	      END IF;

	      v_ttexto := v_ttexto || '
	            Linea from dual';
	      RETURN(v_ttexto);
	   EXCEPTION
	      WHEN OTHERS THEN
	         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
	                     SQLERRM);
	         RETURN 'select 1 from dual';
	   END f_list325_cab;

	   FUNCTION f_list325_det(p_cempres NUMBER DEFAULT NULL, p_fecha VARCHAR2 DEFAULT NULL)
	      RETURN VARCHAR2 IS
	      v_tobjeto      VARCHAR2(100) := 'PAC_INFORMES.f_list325_det';
	      v_tparam       VARCHAR2(1000);
	      v_ntraza       NUMBER := 0;
	      v_sep          VARCHAR2(1) := ';';
	      v_ret          VARCHAR2(1) := CHR(10);
	      v_init         VARCHAR2(32000);
	      v_ttexto       VARCHAR2(32000);
	   BEGIN
	      IF NVL(pac_parametros.f_parlistado_n(p_cempres, 'LIST_PREVI_CARTERA'), 0) = 1 THEN   -- A esta select faltan anadir los nuevos campos
	         v_ttexto :=
	            ' SELECT
	        --SSEGURO
	        s.sseguro||'';'' ||
	        trunc(r.femisio)||'';''|| --femisio
	        f_formatopol(s.npoliza,s.ncertif,1)||'';''|| --polcertif
	        S.CRAMO||''-''||m2.tramo||'';''||
	        S.SPRODUC||''-''||F_DESPRODUCTO_T(s.cramo,s.cmodali,s.ctipseg,s.ccolect,1,f_idiomauser)||'';'' ||
	        s.nsolici||'';'' ||
	        s.fcaranu||'';'' ||  --fefecto
	        decode(pac_parametros.f_parlistado_n(S.CEMPRES,''SUCURSAL/ADN''),1,nvl(pac_redcomercial.f_busca_padre(S.cempres,nvl(R.cagente,S.cagente),null,f_sysdate),''0'')) || '';'' ||
	        s.cagente||'';''|| --cagente
	        ff_desvalorfijo(17, f_idiomauser, s.cforpag)||'';''||--forma pago
	        r.fvencim||'';'' ||  -- fecha vencimiento recibo
	        r.nrecibo||'';'' || -- rebut
	        FF_DESGARANTIA(g.cgarant, f_idiomauser)||'';'' || --garant
	        g2.icaptot||'';'' || -- Capital Actual
	        g.icaptot||'';'' || -- Capital Futur
	        g2.iprianu||'';'' ||  --Prima Actual
	        g.iprianu ||'';'' ||  --Prima Futura
	        f_impgarant (r.nrecibo,''PRIMA TARIFA'',g.cgarant)||'';'' || --Prima Neta
	        ff_desvalorfijo(62, f_idiomauser, g.crevali)||'';'' ||  -- Tipo revalorización
	        g.prevali||'';'' || --Porc. revalorizacion
	        f_impgarant (r.nrecibo,''REC FPAGO'',g.cgarant)||'';'' ||  --Recargo
	        f_impgarant (r.nrecibo,''CONSORCIO'',g.cgarant) ||'';'' || --Consorcio
	        f_impgarant (r.nrecibo,''IMPUESTO'',g.cgarant)||'';'' ||  -- Impost
	        f_impgarant (r.nrecibo,''PRIMA TOTAL'',g.cgarant)||'';'' || --Prima Total
	        f_impgarant (r.nrecibo,''COMISION'',g.cgarant)||'';''||--Comision normal
	        f_impgarant (r.nrecibo,''COMISIONIND'',g.cgarant) ||'';''|| --Comision indirecta
	        f_impgarant (r.nrecibo,''IRPF'',g.cgarant)||'';''|| --Retencion
	        f_impgarant (r.nrecibo,''LIQUIDO'',g.cgarant)  ||'';''||--Liquido
	        decode(nvl(pac_parametros.f_parlistado_n(pac_md_common.f_get_cxtempresa,''INDICE_SINIES''),0),0,NULL,
	        PAC_SINIESTROS.f_indice_siniestralidad(s.sseguro,g2.nriesgo,g2.cgarant,last_day(to_date(substr('''
	            || p_fecha
	            || ''',3,7), ''mmyyyy'')))
	        ||'';'') ||
	        ff_desvalorfijo(1, f_idiomauser, f_cestrec(r.nrecibo, f_sysdate)) -- Estado recibo
	        || '';''||
	        pac_redcomercial.ff_desagente(NVL(pac_redcomercial.f_busca_padre(s.cempres, s.cagente, 2,
	                                                          TRUNC(s.fefecto)),
	                           s.cagente),'
	            || p_cempres
	            || ',1)
	        || '';''|| --sucursal
	        s.nsolici|| '';''|| -- numero de solicitud
	        pac_isqlfor.f_respuesta (s.sseguro, m.nmovimi, 4086, f_idiomauser)|| '';''|| --n asegurados
	        (select pers1.nnumide
	                from  per_personas pers1
	                where ag.sperson = pers1.sperson)||'';''|| -- Documento Asegurado
	        f_nombre(ag.sperson,1,S.cagente)||'';''||-- nombre segurado
	        s.ncertif || '';'' ||   -- numero de certificado
	        (SELECT SUM(G.ICAPITAL)
	        FROM GARANSEG G, SEGUROS SEG
	        WHERE G.SSEGURO = s.SSEGURO
	        AND G.SSEGURO =  SEG.SSEGURO
	        AND G.NMOVIMI = (SELECT MIN(NMOVIMI) FROM GARANSEG WHERE SSEGURO = G.SSEGURO)
	        AND (G.CGARANT, SEG.SPRODUC) IN (SELECT CGARANT, SPRODUC FROM GARANPRO WHERE CBASICA=1))
	        || '';''|| -- valor asegurado inicial
	        (select sum(icapital)
	         from garanseg gar, seguros seg
	        where gar.sseguro = s.sseguro
	        and gar.sseguro = seg.sseguro
	        and gar.NMOVIMI = (SELECT max(NMOVIMI) FROM GARANSEG WHERE SSEGURO = G.SSEGURO)
	        and (gar.cgarant,seg.sproduc) in (select cgarant, sproduc from garanpro where cbasica = 1))|| '';''|| -- Valor asegurado
	        NVL(s.fcarant, s.fefecto) || '';''|| -- Fecha inicio vigencia
	        s.fvencim || '';''|| --FECHA FIN vigencia
	        m.nmovimi || '';''||-- numero de movimiento
	        md.tatribu || '';''|| --tipo movimiento
	        mm.tmotmov || '';''|| -- causa movimiento
	        v.itotpri || '';''|| -- prima anual
	        g.precarg || '';'' || -- valor sobreprima
	        v.icombru || '';'' || -- valor comision
	        f_impgarant (r.nrecibo,''PRIMA TOTAL'',g.cgarant) ||'';''|| -- Prima Total
	        v.iprinet || '';''|| -- recibos fraccionados
	        ad.tatribu || '';''|| -- tipo intermediario
	        s.cagente || '';'' ||
	        ff_desagente(s.cagente) || '';'' ||
	        decode((select count(1) from psucontrolseg where sseguro = s.sseguro and ccontrol =526031),0,''NO'',''SI'') || '';''|| --facultativo
	        cd.tatribu || '';''|| --tipo coaseguro
	        decode((select count(1) from garanseg where sseguro = s.sseguro and cgarant = 48 and icapital > 0),0,''No'',''Si'')
	        || '';''|| --marca ahorro
	        s.ndurcob|| '';''|| -- años pagos prima
	        (select crespue from pregunpolseg where cpregun = 4103
	        and sseguro = s.sseguro and nmovimi = (select max(nmovimi)
	         from pregunpolseg where sseguro = s.sseguro))
	        || '';''||  -- %dortes recibir
	        nvl(ff_pcomisi(-1,s.sseguro,decode(f_es_renovacion(s.sseguro),0,2,1),r.fefecto),0) || '';'' --porc comcion
	        Linea
	        FROM SEGUROS S, MOVSEGURO M, RECIBOS R, GARANSEG G, garanseg g2,ramos m2, GARANPRO gg, DETRECIBOS d, agentes_agente_pol ap, asegurados ag, tomadores tm,
	        detvalores md,detvalores cd,detvalores ad, agentes a, motmovseg mm, vdetrecibos v
	        --G (actual),g2 (anterior)
	        WHERE S.SSEGURO = M.SSEGURO AND
	        R.SSEGURO(+) = M.SSEGURO AND
	        R.NMOVIMI(+) = M.NMOVIMI AND
	        G.NMOVIMI = M.NMOVIMI AND
	        G.SSEGURO = S.SSEGURO AND
	        s.CEMPRES = ap.CEMPRES AND
	        s.cagente = ap.cagente AND
	        m2.cramo = s.cramo and
	        m2.cidioma = F_IdiomaUser and
	        NVL(R.FEMISIO,M.FEMISIO ) = M.FEMISIO AND
	        s.fcarpro = s.fcaranu AND
	        g2.cgarant = g.cgarant and
	        g2.sseguro = g.sseguro and
	        g2.nmovimi = (select max(nmovimi) from garanseg g3 where g3.sseguro= s.sseguro and g3.nmovimi <> G.NMOVIMI) AND
	        M.CMOVSEG = 2 AND     --movimiento de renovacion
	        NVL(R.CTIPREC,3) = 3 AND        --recibos de cartera/renovacion
	        s.CEMPRES = '
	            || p_cempres
	            || ' AND
	        s.sproduc = gg.sproduc AND
	        g.cgarant = gg.cgarant AND
	        gg.ctipgar <> 8 AND
	        TRUNC(M.FEMISIO) BETWEEN
	        TO_DATE('''
	            || p_fecha || ''',''DDMMRRRR'') AND
	        last_day(to_date(substr(''' || p_fecha
	            || ''',3,7), ''mmyyyy'')) AND
	        d.nrecibo(+) = r.nrecibo AND
	        NVL(d.cconcep,0) = 0 AND
	        NVL(d.cgarant,g.cgarant) =  g.cgarant AND
	        NVL(d.nriesgo,g.nriesgo) =  g.nriesgo AND
	         g2.cgarant  = NVL(d.cgarant,g2.cgarant) AND
	         g2.nriesgo = nvl(d.nriesgo,g2.nriesgo) AND
	         gg.cgarant  =nvl( d.cgarant,gg.cgarant) AND
	         ag.sseguro = s.sseguro and
	         tm.sseguro = s.sseguro and
	         md.cvalor = 16
	        and md.cidioma = f_idiomauser
	        and md.catribu = m.cmovseg
	        and cd.cvalor = 800109
	        and cd.cidioma = f_idiomauser
	        and cd.catribu = s.ctipcoa
	        and ad.cvalor = 30
	        and ad.cidioma = f_idiomauser
	        and ad.catribu = a.ctipage
	        and s.cagente = a.cagente
	        AND m.cmotmov = mm.cmotmov
	        AND mm.cidioma = f_idiomauser
	        and v.nrecibo(+) = r.nrecibo
	        ORDER BY s.cramo,s.sproduc, m.femisio,npoliza,ncertif, r.nrecibo, gg.norden';
	      ELSE
	         v_ttexto :=
	            ' SELECT
	            --SSEGURO
	            s.sseguro||'';'' ||
	            trunc(r.femisio)||'';''|| --femisio
	            f_formatopol(s.npoliza,s.ncertif,1)||'';''|| --polcertif
	            S.CRAMO||''-''||m2.tramo||'';''||
	            S.SPRODUC||''-''||F_DESPRODUCTO_T(s.cramo,s.cmodali,s.ctipseg,s.ccolect,1,f_idiomauser)||'';'' ||
	            s.nsolici||'';'' ||
	            s.fcaranu||'';'' ||  --fefecto
	            decode(pac_parametros.f_parlistado_n(S.CEMPRES,''SUCURSAL/ADN''),1,nvl(pac_redcomercial.f_busca_padre(S.cempres,nvl(R.cagente,S.cagente),null,f_sysdate),''0'') || '';'' ,chr(39)||chr(39))||
	            s.cagente||'';''|| --cagente
	            ff_desvalorfijo(17, f_idiomauser, s.cforpag)||'';''||--forma pago
	            r.fvencim||'';'' ||  -- fecha vencimiento recibo
	            r.nrecibo||'';'' || -- rebut
	            FF_DESGARANTIA(g.cgarant, f_idiomauser)||'';'' || --garant
	            g2.icaptot||'';'' || --Capital Actual
	            g.icaptot||'';'' || --Capital Futur
	            g2.iprianu||'';'' ||  --Prima Actual
	            g.iprianu ||'';'' ||  --Prima Futura
	            f_impgarant (r.nrecibo,''PRIMA TARIFA'',g.cgarant)||'';'' || --Prima Neta
	            ff_desvalorfijo(62, f_idiomauser, g.crevali)||'';'' ||  -- Tipo revalorización
	            g.prevali||'';'' || --Porc. revalorizacion
	            f_impgarant (r.nrecibo,''REC FPAGO'',g.cgarant)||'';'' ||  --Recargo
	            f_impgarant (r.nrecibo,''CONSORCIO'',g.cgarant) ||'';'' || --Consorcio
	            f_impgarant (r.nrecibo,''IMPUESTO'',g.cgarant)||'';'' ||  -- Impost
	            f_impgarant (r.nrecibo,''PRIMA TOTAL'',g.cgarant)||'';'' || --Prima Total
	            f_impgarant (r.nrecibo,''COMISION'',g.cgarant)||'';''||--Comision normal
	            f_impgarant (r.nrecibo,''COMISIONIND'',g.cgarant) ||'';''|| --Comision indirecta
	            f_impgarant (r.nrecibo,''IRPF'',g.cgarant)||'';''|| --Retencion
	            f_impgarant (r.nrecibo,''LIQUIDO'',g.cgarant)  ||'';''||--Liquido
	            decode(nvl(pac_parametros.f_parlistado_n(pac_md_common.f_get_cxtempresa,''INDICE_SINIES''),0),0,NULL,
	            PAC_SINIESTROS.f_indice_siniestralidad(s.sseguro,g2.nriesgo,g2.cgarant,last_day(to_date(substr('''
	            || p_fecha
	            || ''',3,7), ''mmyyyy'')))
	            ||'';'') ||
	            ff_desvalorfijo(1, f_idiomauser, f_cestrec(r.nrecibo, f_sysdate)) -- Estado recibo
	            Linea
	            FROM SEGUROS S, MOVSEGURO M, RECIBOS R, GARANSEG G, garanseg g2,ramos m2, GARANPRO gg, DETRECIBOS d, agentes_agente_pol ap
	            --G (actual),g2 (anterior)
	            WHERE S.SSEGURO = M.SSEGURO AND
	            R.SSEGURO(+) = M.SSEGURO AND
	            R.NMOVIMI(+) = M.NMOVIMI AND
	            G.NMOVIMI = M.NMOVIMI AND
	            G.SSEGURO = S.SSEGURO AND
	            s.CEMPRES = ap.CEMPRES AND
	            s.cagente = ap.cagente AND
	            m2.cramo = s.cramo and m2.cidioma = F_IdiomaUser and
	            NVL(R.FEMISIO,M.FEMISIO ) = M.FEMISIO AND
	            s.fcarpro = s.fcaranu AND
	            g2.cgarant = g.cgarant and
	            g2.sseguro = g.sseguro and
	            g2.nmovimi = (select max(nmovimi) from garanseg g3 where g3.sseguro= s.sseguro and g3.nmovimi <> G.NMOVIMI) AND
	            M.CMOVSEG = 2 AND     --movimiento de renovacion
	            NVL(R.CTIPREC,3) = 3 AND        --recibos de cartera/renovacion
	            s.CEMPRES = '
	            || p_cempres
	            || ' AND
	            s.sproduc = gg.sproduc AND
	            g.cgarant = gg.cgarant AND
	            gg.ctipgar <> 8 AND
	            TRUNC(M.FEMISIO) BETWEEN
	            TO_DATE('''
	            || p_fecha || ''',''DDMMRRRR'') AND
	            last_day(to_date(substr(''' || p_fecha
	            || ''',3,7), ''mmyyyy'')) AND
	            d.nrecibo(+) = r.nrecibo AND
	            NVL(d.cconcep,0) = 0 AND
	            NVL(d.cgarant,g.cgarant) =  g.cgarant AND
	            NVL(d.nriesgo,g.nriesgo) =  g.nriesgo AND
	             g2.cgarant  = NVL(d.cgarant,g2.cgarant) AND
	             g2.nriesgo = nvl(d.nriesgo,g2.nriesgo) AND
	             gg.cgarant  =nvl( d.cgarant,gg.cgarant)
	            ORDER BY s.cramo,s.sproduc, m.femisio,npoliza,ncertif, r.nrecibo, gg.norden';
	      END IF;

	      RETURN(v_ttexto);
	   EXCEPTION
	      WHEN OTHERS THEN
	         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam || ': Error' || SQLCODE,
	                     SQLERRM);
	         RETURN 'select 1 from dual';
	   END f_list325_det;
	*/
	FUNCTION f_list325_cab(
			p_cempres NUMBER DEFAULT NULL,
			p_fecha VARCHAR2 DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list325_cab';
	  v_tparam  VARCHAR2(1000);
	  v_ntraza  NUMBER:=0;
	  v_sep     VARCHAR2(1):=';';
	  v_ret     VARCHAR2(1):=chr(10);
	  v_init    VARCHAR2(32000);
	  v_ttexto  VARCHAR2(32000);
	BEGIN
	    IF nvl(pac_parametros.f_parlistado_n(p_cempres, 'LIST_PREVI_CARTERA'), 0)=1 THEN
	      v_ttexto:='Select
	        f_axis_literales(101274,f_idiomauser)||'';''|| -- F. Emisión
	        f_axis_literales(100836,f_idiomauser)||'';''|| -- Núm. póliza
	        f_axis_literales(100784,f_idiomauser)||'';''|| -- Ramo
	        f_axis_literales(100829,f_idiomauser)||'';''|| -- Producto
	        f_axis_literales(9000875,f_idiomauser)||'';''|| -- Nº Solicitud
	        f_axis_literales(102626,f_idiomauser)||'';''|| -- F. Renovacion
	        f_axis_literales(100584,f_idiomauser)||'';''|| -- Agente
	        f_axis_literales(9000719,f_idiomauser)||'';''|| -- forma pago
	        f_axis_literales(9902088,f_idiomauser)||'';''|| -- F. venc. rec.
	        f_axis_literales(100895,f_idiomauser)||'';''|| -- Recibo
	        f_axis_literales(100561,f_idiomauser)||'';''||-- Garantía
	        f_axis_literales(805908,f_idiomauser)||'';''|| -- Capital ant.:
	        f_axis_literales(805907,f_idiomauser)||'';''|| -- Capital act.:
	        f_axis_literales(152178,f_idiomauser)||'';''|| -- Prima anterior
	        f_axis_literales(1000516,f_idiomauser)||'';''|| -- Prima actual
	        f_axis_literales(102995,f_idiomauser)||'';''|| -- Prima neta
	        f_axis_literales(101432,f_idiomauser)||'';''|| -- Tipo de crecimiento;
	        f_axis_literales(9001317,f_idiomauser)||'';''|| -- Valor revalorización (Porcentaje)
	        f_axis_literales(101369,f_idiomauser) ||'';''|| -- Recargo
	        f_axis_literales(100916,f_idiomauser) ||'';''||-- Consorcio
	        f_axis_literales(800422,f_idiomauser) ||'';''|| -- Impuesto
	        f_axis_literales(801270,f_idiomauser) ||'';''|| -- Clea
	        f_axis_literales(140531,f_idiomauser) ||'';''||-- Prima total
	        f_axis_literales(103170,f_idiomauser)||'';''||-- Comis. bruta
	        f_axis_literales(9002214,f_idiomauser)||'';''|| -- Otras comisiones
	        f_axis_literales(101714,f_idiomauser) ||'';''||-- Retención
	        f_axis_literales(110332,f_idiomauser) ||'';''|| -- Líquido
	        f_axis_literales(1000553,f_idiomauser) ||'';''|| -- Estado recibo
	        decode(nvl(pac_parametros.f_parlistado_n(pac_md_common.f_get_cxtempresa,''INDICE_SINIES''),0),0,NULL,f_axis_literales(9904847, f_idiomauser))||'';''||
	        f_axis_literales(9002202, f_idiomauser) ||'';''|| --Sucursal
	        f_axis_literales(9000875, f_idiomauser) ||'';''|| -- Numero de solicitud
	        f_axis_literales(9000477, f_idiomauser) ||'';''|| -- numero asegurados
	        f_axis_literales(102999, f_idiomauser) ||'';''|| -- Número documento asegurado
	        f_axis_literales(101028, f_idiomauser) ||'';''|| -- Nombre asegurado
	        f_axis_literales(9902911, f_idiomauser) ||'';'' -- Número certificado
	        || f_axis_literales(9906957, f_idiomauser)|| '';'' -- valor asegurado inicial
	        || f_axis_literales(9902924, f_idiomauser)|| '';'' -- Valor asegurado actual
	        || f_axis_literales(9906959, f_idiomauser)|| '';''  -- Fecha inicio vigencia
	        || f_axis_literales(9902716, f_idiomauser)|| '';'' -- Fecha fin vigencia
	        || f_axis_literales(9001954, f_idiomauser)|| '';''  -- N  Movimiento
	        || f_axis_literales(102421, f_idiomauser)|| '';''   -- Tipo Movimiento
	        || f_axis_literales(101040, f_idiomauser)|| '';''   -- Causa  Movimiento
	        || f_axis_literales(9902048, f_idiomauser)|| '';'' -- Prima anual
	        || f_axis_literales(9002032, f_idiomauser)|| '';'' -- Sobreprima
	        || f_axis_literales(9902964, f_idiomauser)|| '';'' -- Valor comisión
	        || f_axis_literales(140531,f_idiomauser) || '';'' --Prima total
	        || f_axis_literales(9902122, f_idiomauser)|| '';'' -- Prima fraccionada(recibios fraccionados)
	        || f_axis_literales(9903395, f_idiomauser)|| '';'' -- Tipo intermediario
	        || f_axis_literales(9000531,f_idiomauser) || '';'' -- Clave Agente (Código)
	        || f_axis_literales(100584, f_idiomauser) || '';''  -- Nombre Agente
	        || f_axis_literales(9905833, f_idiomauser)|| '';'' -- Facultativo
	        || f_axis_literales(9902935, f_idiomauser)|| '';'' -- Tipo coaseguro
	        || f_axis_literales(9906787, f_idiomauser)|| '';'' -- Marca ahorro
	        || f_axis_literales(9906788, f_idiomauser) || '';'' --Años pago de prima
	        || f_axis_literales(9906790, f_idiomauser)|| '';'' -- %dote a recibir
	        || f_axis_literales(9001923, f_idiomauser) '; -- % comisión
	    /*

	            decode(pac_parametros.f_parlistado_n(NVL(pac_md_common.f_get_cxtempresa,
	                                                                              f_parinstalacion_n(''EMPRESADEF'')),
	                                                                          ''SUCURSAL/ADN''),1,f_axis_literales(9903035,f_idiomauser),null)||
	            f_axis_literales(100584,f_idiomauser)||'';''|| -- Agente
	            f_axis_literales(101027,f_idiomauser)||'';''||-- Tomador
	            f_axis_literales(101332,f_idiomauser)||'';''|| -- F.efecto
	            || f_axis_literales(9904804, f_idiomauser)|| '';'' -- ocupacion
	          -- ALTAN LOS CAMPOS NUEVOS
	    */
	    ELSE
	      v_ttexto:='Select
	        f_axis_literales(101274,f_idiomauser)||'';''|| -- F. Emisión
	        f_axis_literales(100836,f_idiomauser)||'';''|| -- Núm. póliza
	        f_axis_literales(100784,f_idiomauser)||'';''|| -- Ramo
	        f_axis_literales(100829,f_idiomauser)||'';''|| -- Producto
	        f_axis_literales(9000875,f_idiomauser)||'';''|| -- Nº Solicitud
	        f_axis_literales(102626,f_idiomauser)||'';''|| -- F. Renovacion
	        f_axis_literales(100584,f_idiomauser)||'';''|| -- Agente
	        f_axis_literales(9000719,f_idiomauser)||'';''|| -- forma pago
	        f_axis_literales(9902088,f_idiomauser)||'';''|| -- F. venc. rec.
	        f_axis_literales(100895,f_idiomauser)||'';''|| -- Recibo
	        f_axis_literales(100561,f_idiomauser)||'';''||-- Garantía
	        f_axis_literales(805908,f_idiomauser)||'';''|| -- Capital ant.:
	        f_axis_literales(805907,f_idiomauser)||'';''|| -- Capital act.:
	        f_axis_literales(152178,f_idiomauser)||'';''|| -- Prima anterior
	        f_axis_literales(1000516,f_idiomauser)||'';''|| -- Prima actual
	        f_axis_literales(102995,f_idiomauser)||'';''|| -- Prima neta
	        f_axis_literales(101432,f_idiomauser)||'';''|| -- Tipo de crecimiento;
	        f_axis_literales(9001317,f_idiomauser)||'';''|| -- Valor revalorización (Porcentaje)
	        f_axis_literales(101369,f_idiomauser) ||'';''|| -- Recargo
	        f_axis_literales(100916,f_idiomauser) ||'';''||-- Consorcio
	        f_axis_literales(800422,f_idiomauser) ||'';''|| -- Impuesto
	        f_axis_literales(801270,f_idiomauser) ||'';''|| -- Clea
	        f_axis_literales(140531,f_idiomauser) ||'';''||-- Prima total
	        f_axis_literales(103170,f_idiomauser)||'';''||-- Comis. bruta
	        f_axis_literales(9002214,f_idiomauser)||'';''|| -- Otras comisiones
	        f_axis_literales(101714,f_idiomauser) ||'';''||-- Retención
	        f_axis_literales(110332,f_idiomauser) ||'';''|| -- Líquido
	        f_axis_literales(1000553,f_idiomauser) ||'';''|| -- Estado recibo
	        decode(nvl(pac_parametros.f_parlistado_n(pac_md_common.f_get_cxtempresa,''INDICE_SINIES''),0),0,NULL,f_axis_literales(9904847, f_idiomauser))';
	    /*
	     ||'';''||

	    f_axis_literales(101027,f_idiomauser)||'';''||-- Tomador
	    f_axis_literales(101332,f_idiomauser)||'';''|| -- F.efecto

	                decode(pac_parametros.f_parlistado_n(NVL(pac_md_common.f_get_cxtempresa,
	                                                                      f_parinstalacion_n(''EMPRESADEF'')),
	                                                                  ''SUCURSAL/ADN''),1,f_axis_literales(9903035,f_idiomauser),null)||
	    f_axis_literales(100584,f_idiomauser)||'';''|| -- Agente
	    */
	    END IF;

	    v_ttexto:=v_ttexto
	              || '
	            Linea from dual';

	    RETURN(v_ttexto);
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list325_cab;
	FUNCTION f_list325_det(
			p_cempres NUMBER DEFAULT NULL,
			p_fecha VARCHAR2 DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_list325_det';
	  v_tparam  VARCHAR2(1000);
	  v_ntraza  NUMBER:=0;
	  v_sep     VARCHAR2(1):=';';
	  v_ret     VARCHAR2(1):=chr(10);
	  v_init    VARCHAR2(32000);
	  v_ttexto  VARCHAR2(32000);
	BEGIN
	    IF nvl(pac_parametros.f_parlistado_n(p_cempres, 'LIST_PREVI_CARTERA'), 0)=1 THEN -- A esta select faltan anadir los nuevos campos
	      v_ttexto:=' SELECT
	        trunc(r.femisio)||'';''|| --femisio
	        f_formatopol(s.npoliza,s.ncertif,1)||'';''|| --polcertif
	        S.CRAMO||''-''||m2.tramo||'';''||
	        S.SPRODUC||''-''||F_DESPRODUCTO_T(s.cramo,s.cmodali,s.ctipseg,s.ccolect,1,f_idiomauser)||'';'' ||
	        s.nsolici||'';'' ||
	        s.fcaranu||'';'' ||  --fefecto
	        s.cagente||'';''|| --cagente
	        ff_desvalorfijo(17, f_idiomauser, s.cforpag)||'';''||--forma pago
	        r.fvencim||'';'' ||  -- fecha vencimiento recibo
	        r.nrecibo||'';'' || -- rebut
	        FF_DESGARANTIA(g.cgarant, f_idiomauser)||'';'' || --garant
	        g2.icaptot||'';'' || -- Capital Actual
	        g.icaptot||'';'' || -- Capital Futur
	        g2.iprianu||'';'' ||  --Prima Actual
	        g.iprianu ||'';'' ||  --Prima Futura
	        f_impgarant (r.nrecibo,''PRIMA TARIFA'',g.cgarant)||'';'' || --Prima Neta
	        ff_desvalorfijo(62, f_idiomauser, g.crevali)||'';'' ||  -- Tipo revalorización
	        g.prevali||'';'' || --Porc. revalorizacion
	        f_impgarant (r.nrecibo,''REC FPAGO'',g.cgarant)||'';'' ||  --Recargo
	        f_impgarant (r.nrecibo,''CONSORCIO'',g.cgarant) ||'';'' || --Consorcio
	        f_impgarant (r.nrecibo,''IMPUESTO'',g.cgarant)||'';'' ||  -- Impost
	        f_impgarant (r.nrecibo,''CLEA'',g.cgarant)||'';'' ||  -- Impost
	        f_impgarant (r.nrecibo,''PRIMA TOTAL'',g.cgarant)||'';'' || --Prima Total
	        f_impgarant (r.nrecibo,''COMISION'',g.cgarant)||'';''||--Comision normal
	        f_impgarant (r.nrecibo,''COMISIONIND'',g.cgarant) ||'';''|| --Comision indirecta
	        f_impgarant (r.nrecibo,''IRPF'',g.cgarant)||'';''|| --Retencion
	        f_impgarant (r.nrecibo,''LIQUIDO'',g.cgarant)  ||'';''||--Liquido
	        ff_desvalorfijo(1, f_idiomauser, f_cestrec(r.nrecibo, f_sysdate)) ||'';''|| -- Estado recibo
	        decode(nvl(pac_parametros.f_parlistado_n(pac_md_common.f_get_cxtempresa,''INDICE_SINIES''),0),0,NULL,
	        PAC_SINIESTROS.f_indice_siniestralidad(s.sseguro,g2.nriesgo,g2.cgarant,last_day(to_date(substr('''
	                || p_fecha
	                || ''',3,7), ''mmyyyy''))))
	            || '';''||
	        REPLACE(pac_redcomercial.ff_desagente(NVL(pac_redcomercial.f_busca_padre(s.cempres, s.cagente, 2,
	                                                          TRUNC(s.fefecto)),
	                           s.cagente),'
	                || p_cempres
	                || ',1),'','','''')
	        || '';''|| --sucursal
	        s.nsolici|| '';''|| -- numero de solicitud
	        pac_isqlfor.f_respuesta (s.sseguro, m.nmovimi, 4086, f_idiomauser)|| '';''|| --n asegurados
	        (select pers1.nnumide
	                from  per_personas pers1
	                where ag.sperson = pers1.sperson)||'';''|| -- Documento Asegurado
	        f_nombre(ag.sperson,3,S.cagente)||'';''||-- nombre segurado
	        s.ncertif || '';'' ||   -- numero de certificado
	        (SELECT SUM(G.ICAPITAL)
	        FROM GARANSEG G, SEGUROS SEG
	        WHERE G.SSEGURO = s.SSEGURO
	        AND G.SSEGURO =  SEG.SSEGURO
	        AND G.NMOVIMI = (SELECT MIN(NMOVIMI) FROM GARANSEG WHERE SSEGURO = G.SSEGURO)
	        AND (G.CGARANT, SEG.SPRODUC) IN (SELECT CGARANT, SPRODUC FROM GARANPRO WHERE CBASICA=1))
	        || '';''|| -- valor asegurado inicial
	        (select sum(icapital)
	         from garanseg gar, seguros seg
	        where gar.sseguro = s.sseguro
	        and gar.sseguro = seg.sseguro
	        and gar.NMOVIMI = (SELECT max(NMOVIMI) FROM GARANSEG WHERE SSEGURO = G.SSEGURO)
	        and (gar.cgarant,seg.sproduc) in (select cgarant, sproduc from garanpro where cbasica = 1))|| '';''|| -- Valor asegurado
	        NVL(s.fcarant, s.fefecto) || '';''|| -- Fecha inicio vigencia
	        s.fvencim || '';''|| --FECHA FIN vigencia
	        m.nmovimi || '';''||-- numero de movimiento
	        md.tatribu || '';''|| --tipo movimiento
	        mm.tmotmov || '';''|| -- causa movimiento
	        v.itotpri || '';''|| -- prima anual
	        g.precarg || '';'' || -- valor sobreprima
	        v.icombru || '';'' || -- valor comision
	        f_impgarant (r.nrecibo,''PRIMA TOTAL'',g.cgarant) ||'';''|| -- Prima Total
	        v.iprinet || '';''|| -- recibos fraccionados
	        ad.tatribu || '';''|| -- tipo intermediario
	        s.cagente || '';'' ||
          REPLACE(ff_desagente(s.cagente),'','','''') || '';'' ||
	        decode((select count(1) from psucontrolseg where sseguro = s.sseguro and ccontrol =526031),0,''NO'',''SI'') || '';''|| --facultativo
	        cd.tatribu || '';''|| --tipo coaseguro
	        decode((select count(1) from garanseg where sseguro = s.sseguro and cgarant = 48 and icapital > 0),0,''No'',''Si'')
	        || '';''|| --marca ahorro
	        s.ndurcob|| '';''|| -- años pagos prima
	        (select crespue from pregunpolseg where cpregun = 4103
	        and sseguro = s.sseguro and nmovimi = (select max(nmovimi)
	         from pregunpolseg where sseguro = s.sseguro))
	        || '';''||  -- %dortes recibir
	        nvl(ff_pcomisi(-1,s.sseguro,decode(f_es_renovacion(s.sseguro),0,2,1),r.fefecto),0) || '';'' --porc comcion
	        Linea
	        FROM SEGUROS S, MOVSEGURO M, RECIBOS R, GARANSEG G, garanseg g2,ramos m2, GARANPRO gg, DETRECIBOS d, agentes_agente_pol ap, asegurados ag, tomadores tm,
	        detvalores md,detvalores cd,detvalores ad, agentes a, motmovseg mm, vdetrecibos v
	        /*G (actual),g2 (anterior)*/
	        WHERE S.SSEGURO = M.SSEGURO AND
	        R.SSEGURO(+) = M.SSEGURO AND
	        R.NMOVIMI(+) = M.NMOVIMI AND
	        G.NMOVIMI = M.NMOVIMI AND
	        G.SSEGURO = S.SSEGURO AND
	        s.CEMPRES = ap.CEMPRES AND
	        s.cagente = ap.cagente AND
	        m2.cramo = s.cramo and
	        m2.cidioma = F_IdiomaUser and
	        NVL(R.FEMISIO,M.FEMISIO ) = M.FEMISIO AND
	       /* s.fcarpro = s.fcaranu AND*/
	        g2.cgarant = g.cgarant and
	        g2.sseguro = g.sseguro and
	        g2.nmovimi = (select max(nmovimi) from garanseg g3 where g3.sseguro= s.sseguro and g3.nmovimi <> G.NMOVIMI) AND
	        M.CMOVSEG = 2 AND     /*movimiento de renovacion*/
	        NVL(R.CTIPREC,3) = 3 AND        /*recibos de cartera/renovacion*/
	        s.CEMPRES = '
	                || p_cempres
	                || ' AND
	        s.sproduc = gg.sproduc AND
	        g.cgarant = gg.cgarant AND
	        gg.ctipgar <> 8 AND
	        TRUNC(M.FEMISIO) BETWEEN
	        TO_DATE('''
	                || p_fecha
	                || ''',''DDMMRRRR'') AND
	        last_day(to_date(substr('''
	                || p_fecha
	                || ''',3,7), ''mmyyyy'')) AND
	        d.nrecibo(+) = r.nrecibo AND
	        NVL(d.cconcep,0) = 0 AND
	        NVL(d.cgarant,g.cgarant) =  g.cgarant AND
	        NVL(d.nriesgo,g.nriesgo) =  g.nriesgo AND
	         g2.cgarant  = NVL(d.cgarant,g2.cgarant) AND
	         g2.nriesgo = nvl(d.nriesgo,g2.nriesgo) AND
	         gg.cgarant  =nvl( d.cgarant,gg.cgarant) AND
	         ag.sseguro = s.sseguro and
	         tm.sseguro = s.sseguro and
	         md.cvalor = 16
	        and md.cidioma = f_idiomauser
	        and md.catribu = m.cmovseg
	        and cd.cvalor = 800109
	        and cd.cidioma = f_idiomauser
	        and cd.catribu = s.ctipcoa
	        and ad.cvalor = 30
	        and ad.cidioma = f_idiomauser
	        and ad.catribu = a.ctipage
	        and s.cagente = a.cagente
	        AND m.cmotmov = mm.cmotmov
	        AND mm.cidioma = f_idiomauser
	        and v.nrecibo(+) = r.nrecibo
	        ORDER BY s.cramo,s.sproduc, m.femisio,npoliza,ncertif, r.nrecibo, gg.norden';
	    ELSE
	      v_ttexto:=' SELECT
	            trunc(r.femisio)||'';''|| --femisio
	            f_formatopol(s.npoliza,s.ncertif,1)||'';''|| --polcertif
	            S.CRAMO||''-''||m2.tramo||'';''||
	            S.SPRODUC||''-''||F_DESPRODUCTO_T(s.cramo,s.cmodali,s.ctipseg,s.ccolect,1,f_idiomauser)||'';'' ||
	            s.nsolici||'';'' ||
	            s.fcaranu||'';'' ||  --fefecto
	            s.cagente||'';''|| --cagente
	            ff_desvalorfijo(17, f_idiomauser, s.cforpag)||'';''||--forma pago
	            r.fvencim||'';'' ||  -- fecha vencimiento recibo
	            r.nrecibo||'';'' || -- rebut
	            FF_DESGARANTIA(g.cgarant, f_idiomauser)||'';'' || --garant
	            g2.icaptot||'';'' || --Capital Actual
	            g.icaptot||'';'' || --Capital Futur
	            g2.iprianu||'';'' ||  --Prima Actual
	            g.iprianu ||'';'' ||  --Prima Futura
	            f_impgarant (r.nrecibo,''PRIMA TARIFA'',g.cgarant)||'';'' || --Prima Neta
	            ff_desvalorfijo(62, f_idiomauser, g.crevali)||'';'' ||  -- Tipo revalorización
	            g.prevali||'';'' || --Porc. revalorizacion
	            f_impgarant (r.nrecibo,''REC FPAGO'',g.cgarant)||'';'' ||  --Recargo
	            f_impgarant (r.nrecibo,''CONSORCIO'',g.cgarant) ||'';'' || --Consorcio
	            f_impgarant (r.nrecibo,''IMPUESTO'',g.cgarant)||'';'' ||  -- Impost
	            f_impgarant (r.nrecibo,''CLEA'',g.cgarant)||'';'' ||  -- Impost
	            f_impgarant (r.nrecibo,''PRIMA TOTAL'',g.cgarant)||'';'' || --Prima Total
	            f_impgarant (r.nrecibo,''COMISION'',g.cgarant)||'';''||--Comision normal
	            f_impgarant (r.nrecibo,''COMISIONIND'',g.cgarant) ||'';''|| --Comision indirecta
	            f_impgarant (r.nrecibo,''IRPF'',g.cgarant)||'';''|| --Retencion
	            f_impgarant (r.nrecibo,''LIQUIDO'',g.cgarant)  ||'';''||--Liquido
	            ff_desvalorfijo(1, f_idiomauser, f_cestrec(r.nrecibo, f_sysdate)) ||'';''|| -- Estado recibo
	            decode(nvl(pac_parametros.f_parlistado_n(pac_md_common.f_get_cxtempresa,''INDICE_SINIES''),0),0,NULL,
	            PAC_SINIESTROS.f_indice_siniestralidad(s.sseguro,g2.nriesgo,g2.cgarant,last_day(to_date(substr('''
	                || p_fecha
	                || ''',3,7), ''mmyyyy'')))
	            ||'';'') Linea
	            FROM SEGUROS S, MOVSEGURO M, RECIBOS R, GARANSEG G, garanseg g2,ramos m2, GARANPRO gg, DETRECIBOS d, agentes_agente_pol ap
	            /*G (actual),g2 (anterior)*/
	            WHERE S.SSEGURO = M.SSEGURO AND
	            R.SSEGURO(+) = M.SSEGURO AND
	            R.NMOVIMI(+) = M.NMOVIMI AND
	            G.NMOVIMI = M.NMOVIMI AND
	            G.SSEGURO = S.SSEGURO AND
	            s.CEMPRES = ap.CEMPRES AND
	            s.cagente = ap.cagente AND
	            m2.cramo = s.cramo and m2.cidioma = F_IdiomaUser and
	            NVL(R.FEMISIO,M.FEMISIO ) = M.FEMISIO AND
	          /*  s.fcarpro = s.fcaranu AND*/
	            g2.cgarant = g.cgarant and
	            g2.sseguro = g.sseguro and
	            g2.nmovimi = (select max(nmovimi) from garanseg g3 where g3.sseguro= s.sseguro and g3.nmovimi <> G.NMOVIMI) AND
	            M.CMOVSEG = 2 AND     /*movimiento de renovacion*/
	            NVL(R.CTIPREC,3) = 3 AND        /*recibos de cartera/renovacion*/
	            s.CEMPRES = '
	                || p_cempres
	                || ' AND
	            s.sproduc = gg.sproduc AND
	            g.cgarant = gg.cgarant AND
	            gg.ctipgar <> 8 AND
	            TRUNC(M.FEMISIO) BETWEEN
	            TO_DATE('''
	                || p_fecha
	                || ''',''DDMMRRRR'') AND
	            last_day(to_date(substr('''
	                || p_fecha
	                || ''',3,7), ''mmyyyy'')) AND
	            d.nrecibo(+) = r.nrecibo AND
	            NVL(d.cconcep,0) = 0 AND
	            NVL(d.cgarant,g.cgarant) =  g.cgarant AND
	            NVL(d.nriesgo,g.nriesgo) =  g.nriesgo AND
	             g2.cgarant  = NVL(d.cgarant,g2.cgarant) AND
	             g2.nriesgo = nvl(d.nriesgo,g2.nriesgo) AND
	             gg.cgarant  =nvl( d.cgarant,gg.cgarant)
	            ORDER BY s.cramo,s.sproduc, m.femisio,npoliza,ncertif, r.nrecibo, gg.norden';
	    END IF;

	    RETURN(v_ttexto);
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_list325_det;

	/*26. AQ Start*/
	FUNCTION f_907_cab
	RETURN VARCHAR2
	IS
	  v_tobjeto VARCHAR2(100):='PAC_INFORMES.f_907_CAB';
	  v_tparam  VARCHAR2(1000);
	  v_ntraza  NUMBER:=0;
	  v_sep     VARCHAR2(1):=';';
	  v_ret     VARCHAR2(1):=chr(10);
	  v_init    VARCHAR2(32000);
	  v_ttexto  VARCHAR2(32000);
	BEGIN
	    /*BUG 35181 -203898 KJSC 15/05/2015 PROCESO ESPECIFICO DE LA EMPRESA*/
	    DECLARE
	        v_emp     NUMBER;
	        v_sufijo  VARCHAR2(100);
	        v_ss      VARCHAR2(2000);
	        v_retorno VARCHAR2(2000);
	    BEGIN
	        v_emp:=nvl(pac_parametros.f_parinstalacion_n('EMPRESADEF'), f_empres);

	        v_sufijo:=pac_parametros.f_parempresa_t(v_emp, 'SUFIJO_EMP');

	        v_ss:='DECLARE '
	              || ' BEGIN '
	              || ' :v_retorno := PAC_INFORMES_'
	              || v_sufijo
	              || '.'
	              || 'f_907_cab;'
	              || 'END;';

	        EXECUTE IMMEDIATE v_ss
	        USING OUT v_retorno;

	        RETURN v_retorno;
	    EXCEPTION
	        WHEN OTHERS THEN
	          NULL;
	    END;

	    v_ttexto:='SELECT
	         '' ''||f_axis_literales(111324,x.idi)  /*POLIZA*/
	        || '';'' || f_axis_literales(100895, x.idi) /*RECIBO*/
	        || '';'' ||f_axis_literales(9903661, x.idi) /*DOCUMENTO*/
	        || '';'' || f_axis_literales(9903314, x.idi) /*LIBRO*/
	        || '';'' || f_axis_literales(9000533, x.idi) /*CUENTA*/
	        || '';'' || f_axis_literales(9001948, x.idi) /*DEBE/HABER*/
	        || '';'' || f_axis_literales(9904351, x.idi) /*IMPORTE*/
	        || '';'' || f_axis_literales(1000576, x.idi) /*PROCESO*/
	        || '';'' || f_axis_literales(1000575, x.idi) /*FECHA CONTABLE*/
	        || '';'' || f_axis_literales(1000596,x.idi) /*FECHA ADMINISTRACION*/
	        || '';'' || f_axis_literales(100816, x.idi) /*PAIS*/
	        || '';'' || f_axis_literales(9000600, x.idi) /*COMPANIA*/
	        || '';'' || f_axis_literales(1000109, x.idi) /*CODIGO SNIP*/
	        || '';'' || f_axis_literales(9000600, x.idi) /*COMPANIA*/
	        || '';'' || f_axis_literales(100784, x.idi) /*RAMO*/
	        || '';'' || f_axis_literales(9002202, x.idi) /*SUCURSAL*/
	        || '';'' || f_axis_literales(101761, x.idi) /*DESCRIPCION*/
	        || '';''
	        || '' '' linea
	   FROM (SELECT NVL(f_usu_idioma, 1) idi FROM DUAL) x,
	   DUAL
	   ';

	    RETURN(v_ttexto);
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END;
	FUNCTION f_907_det(pfcalculi VARCHAR2,/*fecha inicial --pantalla*/pfcalculf VARCHAR2,/*fecha final --pantalla*/pcorasuc VARCHAR2,/*compañia, ramo contable, sucursal, todo contcatenado --pantalla*/pcempres NUMBER,/*empresa --pantalla*/pnpoliza NUMBER,/*poliza*/pnrecibo NUMBER,/*recibo*/pnsinies NUMBER,/*siniestro*/pccuenta VARCHAR2,/*cuenta*/ppendient NUMBER) /*1 incluir sólo lo pendiente, 0 rango de fechas*/
	RETURN VARCHAR2
	IS
	  v_tobjeto      VARCHAR2(100):='PAC_INFORMES.f_907_det';
	  v_tparam       VARCHAR2(1000);
	  v_ntraza       NUMBER:=0;
	  v_sep          VARCHAR2(1):=';';
	  v_ret          VARCHAR2(1):=chr(10);
	  v_fevaluar     VARCHAR2(10);

	CURSOR c1(

	    pc_ccuenta                                                              VARCHAR2,pc_coletilla                                        VARCHAR2,pc_smodcon                    NUMBER,pc_fevaluar DATE) IS
	    SELECT d2.claenlace,d1.smodcon,d2.nlinea,d2.ccuenta,d1.tcuenta,c.cgroup,c.tdescri,d2.tseldia
	      FROM descuenta c,detmodconta d1,detmodconta_dia d2,(SELECT DISTINCT cad1.cempres,cad1.nasient,cad1.nlinea,cad1.fconta
	              FROM contab_asient_dia cad1
	             WHERE fconta=pc_fevaluar) cad
	     WHERE d1.smodcon=d2.smodcon AND
	           d1.ccuenta=d2.ccuenta AND
	           d1.cempres=d2.cempres AND
	           d1.nlinea=d2.nlinea AND
	           c.ccuenta=d1.ccuenta AND
	           d1.cempres=pcempres AND
	           d2.ccuenta LIKE nvl(pccuenta
	                               || '%', d2.ccuenta) AND
	           d2.tseldia LIKE pc_coletilla AND
	           d2.smodcon=nvl(pc_smodcon, d2.smodcon) AND
	           d2.smodcon<100 AND
	           v_fevaluar IS NOT NULL AND
	           d1.nlinea=cad.nlinea AND
	           d1.smodcon=cad.nasient AND
	           d1.cempres=cad.cempres
	           /* Ajuste para restringir las consultas - Inicio*/
	           AND
	           ((pnpoliza IS NOT NULL AND
	             d1.smodcon IN(1, 2, 3, 5,
	                           8, 9, 11, 12))  OR
	            pnpoliza IS NULL) AND
	           ((pnrecibo IS NOT NULL AND
	             d1.smodcon IN(1, 2, 3, 5))  OR
	            pnrecibo IS NULL) AND
	           ((pnsinies IS NOT NULL AND
	             d1.smodcon IN(9))  OR
	            pnsinies IS NULL)
	     ORDER BY 2,3;

	  TYPE t_cursor IS ref CURSOR;

	  c_rec          T_CURSOR;
	  vl_npoliza     NUMBER;
	  vl_nrecibo     NUMBER;
	  vl_fcontab     DATE;
	  vl_coletilla   VARCHAR2(100);
	  vl_importe     NUMBER;
	  vl_producto    VARCHAR2(32000);
	  vl_proces      NUMBER;
	  vl_fadm        DATE;
	  vl_pais        NUMBER;
	  vl_descri      VARCHAR2(32000);
	  vl_fcontab8    DATE;
	  vl_tipo        NUMBER;
	  p_coletilla    VARCHAR2(32767);
	  p_comple_query VARCHAR2(32767);
	  v_tseldia      VARCHAR2(32767);
	  v_linea        VARCHAR2(10);
	  v_cual         NUMBER(10);
	  v_nlinea       NUMBER;
	  v_sproces      NUMBER;
	  v_tcuenta      VARCHAR2(1);
	  v_total        NUMBER(3);
	  v_tmp_cuenta   NUMBER;
	  v_fsysdate     DATE;
	BEGIN
	    /*BUG 35181 -203898 KJSC 15/05/2015 PROCESO ESPECIFICO DE LA EMPRESA*/
	    DECLARE
	        v_sufijo  VARCHAR2(100);
	        v_ss      VARCHAR2(2000);
	        v_retorno VARCHAR2(2000);
	    BEGIN
	        v_sufijo:=pac_parametros.f_parempresa_t(pcempres, 'SUFIJO_EMP');

	        v_ss:='DECLARE '
	              || ' BEGIN '
	              || ' :v_retorno := PAC_INFORMES_'
	              || v_sufijo
	              || '.'
	              || 'f_907_det('
	              || chr(39)
	              || pfcalculi
	              || chr(39)
	              || ','
	              || chr(39)
	              || pfcalculf
	              || chr(39)
	              || ','
	              || chr(39)
	              || pcorasuc
	              || chr(39)
	              || ','
	              || chr(39)
	              || pcempres
	              || chr(39)
	              || ','
	              || chr(39)
	              || pnpoliza
	              || chr(39)
	              || ','
	              || chr(39)
	              || pnrecibo
	              || chr(39)
	              || ','
	              || chr(39)
	              || pnsinies
	              || chr(39)
	              || ','
	              || chr(39)
	              || pccuenta
	              || chr(39)
	              || ','
	              || chr(39)
	              || ppendient
	              || chr(39)
	              || ');'
	              || 'END;';

	        EXECUTE IMMEDIATE v_ss
	        USING OUT v_retorno;

	        RETURN v_retorno;
	    EXCEPTION
	        WHEN OTHERS THEN
	          NULL;
	    END;

	    SELECT seqcontabdet.NEXTVAL
	      INTO v_sproces /*VOLVER A DESTAPAR AL ENVIAR CONTAB_ASIENT_DET*/
	      FROM dual;

	    v_fsysdate:=f_sysdate;

	    p_tab_error(f_sysdate, f_user, v_tobjeto, 0, pfcalculi
	                                                 || '-'
	                                                 || pfcalculf
	                                                 || '-'
	                                                 || pcorasuc
	                                                 || '-'
	                                                 || pcempres
	                                                 || '-'
	                                                 || pnpoliza
	                                                 || '-'
	                                                 || pnrecibo
	                                                 || '-'
	                                                 || pnsinies
	                                                 || '-'
	                                                 || pccuenta
	                                                 || '-'
	                                                 || ppendient, SQLERRM);

	    v_ntraza:=1;

	    v_nlinea:=0;

	    p_coletilla:='%'; --PARAMETRO COLETILLA

	    p_comple_query:=' ';

	    v_ntraza:=2;

	    /*('npoliza;nrecibo;tipodoc;libro;smodcon;linea;cuenta;coletilla;tcuenta;cgroup;tdescri;importe;proceso;fecha;fcontab;pais;compania;snip;compania2;ramo;sucursal;descripcion;');*/
	    /*hago un cursor con las fechas de contabilidad debido a que necesito la fecha exacta de cuando entra en vigencia algo para hacer*/
	    /*la sustitución en el trend #fecha*/
	    v_fevaluar:=to_char(to_date(pfcalculi, 'ddmmyyyy'), 'dd/mm/yyyy');

	    LOOP
	        FOR i IN c1(pccuenta, p_coletilla, NULL, to_date(v_fevaluar, 'dd/mm/yyyy')) LOOP
	            BEGIN
	                v_linea:='0';

	                v_ntraza:=3;

	                v_tseldia:=replace(replace(rtrim(ltrim(i.tseldia))
	                                           || ' '
	                                           || ' 1 = 1 ', '#fecha', nvl(v_fevaluar, to_char(f_sysdate, 'dd/mm/yyyy'))), '#ccuenta', i.ccuenta)
	                           || ' '
	                           || nvl(p_comple_query, ' ');

	                v_ntraza:=4;

	                IF pnpoliza IS NOT NULL THEN
	                  v_tseldia:=v_tseldia
	                             || ' AND s.npoliza = '
	                             || pnpoliza;
	                END IF;

	                IF pnrecibo IS NOT NULL AND
	                   i.smodcon IN(1, 2, 3, 5) THEN
	                  v_tseldia:=v_tseldia
	                             || ' and r.nrecibo = '
	                             || to_char(pnrecibo)
	                             || ' ';
	                END IF;

	                IF pnsinies IS NOT NULL THEN
	                  IF i.smodcon IN(9) AND
	                     upper(v_tseldia) LIKE '%SS.NSINIES%' THEN
	                    v_tseldia:=v_tseldia
	                               || ' and ss.nsinies = '
	                               || to_char(pnsinies)
	                               || ' ';
	                  ELSIF i.smodcon IN(9) AND
	                        upper(v_tseldia) LIKE '%SI.NSINIES%' THEN
	                    v_tseldia:=v_tseldia
	                               || ' and si.nsinies = '
	                               || to_char(pnsinies)
	                               || ' ';
	                  END IF;
	                END IF;

	                v_ntraza:=5;

	                IF ((pfcalculi IS NULL AND
	                     pfcalculf IS NULL)) THEN
	                  RETURN 'SELECT 1 FROM DUAL'; --tomar en cuenta todo
	                END IF; /*no debería ser permitido*/

	                v_ntraza:=6;

	                IF (pfcalculi IS NOT NULL  OR
	                    pfcalculf IS NOT NULL) THEN
	                  v_tseldia:=v_tseldia
	                             || ' and fcontab = '
	                             || 'TO_DATE('
	                             || chr(39)
	                             || v_fevaluar
	                             || chr(39)
	                             || ','
	                             || chr(39)
	                             || 'DD/MM/YYYY'
	                             || chr(39)
	                             || ')';
	                END IF;

	                v_ntraza:=7;

	                IF (pfcalculi IS NULL AND
	                    pfcalculf IS NULL) THEN
	                  v_tseldia:=v_tseldia
	                             || ' and fcontab is null';
	                END IF;

	                v_ntraza:=8;

	                IF i.smodcon IN(1, 2, 3, 5) THEN
	                  v_tseldia:='select S.NPOLIZA,R.NRECIBO,FCONTAB FCTA2,'
	                             || substr(v_tseldia, 7);
	                ELSIF i.smodcon=8 THEN
	                  v_tseldia:='select NPOLIZA, 0 NRECIBO,FCONTAB FCTA2,'
	                             || substr(v_tseldia, 7);

	                  v_tseldia:='select condensa.npoliza,condensa.nrecibo,fcta2,sum(condensa.importe) importe, condensa.coletilla coletilla, condensa.proceso, condensa.fecha, condensa.pais, condensa.descrip,condensa.fcontab from ('
	                             || v_tseldia
	                             || ' )condensa group by condensa.npoliza,condensa.nrecibo,condensa.fcta2,condensa.coletilla, condensa.proceso, condensa.fecha, condensa.pais, descrip,condensa.fcontab';
	                ELSIF i.smodcon IN(9, 11) THEN
	                  v_tseldia:='select S.NPOLIZA,0 NRECIBO,FCONTAB FCTA2,'
	                             || substr(v_tseldia, 7);
	                ELSE
	                  v_tseldia:='select 0 NPOLIZA, 0 NRECIBO,FCONTAB FCTA2,'
	                             || substr(v_tseldia, 7);
	                END IF;

	                v_tseldia:=replace(upper(v_tseldia), 'TRUNC(NULL)', 'NULL');

	                v_ntraza:=9;

	                v_linea:='1';

	                v_cual:=0;

	                BEGIN
	                    v_tmp_cuenta:=0;

	                    OPEN c_rec FOR v_tseldia;

	                    v_ntraza:=10;

	                    BEGIN
	                        FETCH c_rec INTO vl_npoliza, vl_nrecibo, vl_fcontab, vl_importe, vl_coletilla, vl_proces, vl_fadm, vl_pais, vl_descri;

	                        vl_tipo:=1;
	                    EXCEPTION
	                        WHEN OTHERS THEN
	                          CLOSE c_rec;

	                          OPEN c_rec FOR v_tseldia;

	                          FETCH c_rec INTO vl_npoliza, vl_nrecibo, vl_fcontab, vl_importe, vl_coletilla, vl_proces, vl_fadm, vl_pais, vl_descri, vl_fcontab8;

	                          vl_tipo:=2;
	                    END;

	                    v_ntraza:=11;

	                    LOOP
	                        IF c_rec%NOTFOUND THEN
	                          IF v_tmp_cuenta=0 THEN
			INSERT INTO contab_asient_det
		           (sproces,nlinea,toutdia,fproceso,nasient,nlinea_conta,
		           ccuenta,tapunte,iapunte,cproces,fcontab,
		           fefeadm,npoliza,nrecibo,nsinies,cenlace,
		           cpais)
		    VALUES
		           (v_sproces,v_nlinea,';;'

	                                                            || substr(i.claenlace, 1, 2)
	                                                            || ';'
	                                                            || substr(i.claenlace, 3, 2)
	                                                            || ';'
	                                                            || i.smodcon
	                                                            || ';'
	                                                            || i.nlinea
	                                                            || ';'
	                                                            || i.ccuenta
	                                                            || ';;'
	                                                            || i.tcuenta
	                                                            || ';'
	                                                            || i.cgroup
	                                                            || ';'
	                                                            || i.tdescri
	                                                            || ' '
	                                                            || ' '
	                                                            || ';'
	                                                            || ' '
	                                                            || ';'
	                                                            || ' '
	                                                            || ';;'
	                                                            || ' '
	                                                            || ';'
	                                                            || ' '
	                                                            || ';'
	                                                            || ' '
	                                                            || ';;;;;;',v_fsysdate,i.smodcon,i.nlinea,i.ccuenta,i.tcuenta,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

	                            v_nlinea:=v_nlinea+1;
	                          END IF;

	                          EXIT;
	                        ELSE
	                          v_tmp_cuenta:=v_tmp_cuenta+1;

	                          v_tcuenta:=i.tcuenta;

	                          IF sign(vl_importe)=-1 THEN
	                            IF v_tcuenta='H' THEN
	                              v_tcuenta:='D';
	                            ELSE
	                              v_tcuenta:='H';
	                            END IF;
	                          END IF;

	                          v_ntraza:=12;

			INSERT INTO contab_asient_det
		           (sproces,nlinea,toutdia,fproceso,nasient,nlinea_conta,
		           ccuenta,tapunte,iapunte,cproces,fcontab,
		           fefeadm,npoliza,nrecibo,nsinies,cenlace,
		           cpais)
		    VALUES
		           (v_sproces,v_nlinea,vl_npoliza || ';'

	                                                          || vl_nrecibo
	                                                          || ';'
	                                                          || substr(i.claenlace, 1, 2)
	                                                          || ';'
	                                                          || substr(i.claenlace, 3, 2)
	                                                          || ';'
	                                                          || i.smodcon
	                                                          || ';'
	                                                          || i.nlinea
	                                                          || ';'
	                                                          || i.ccuenta
	                                                          || ';'
	                                                          || vl_coletilla
	                                                          || ';'
	                                                          || v_tcuenta
	                                                          || ';'
	                                                          || i.cgroup
	                                                          || ';'
	                                                          || i.tdescri
	                                                          || ';'
	                                                          || abs(vl_importe)
	                                                          || ';'
	                                                          || vl_proces
	                                                          || ';'
	                                                          || vl_fcontab
	                                                          || ';'
	                                                          || vl_fadm
	                                                          || ';'
	                                                          || vl_pais
	                                                          || ';'
	                                                          || substr(vl_proces, 1, 1)
	                                                          || ';'
	                                                          || substr(vl_proces, 2, 8)
	                                                          || ';'
	                                                          || substr(vl_descri, 1, 2)
	                                                          || ';'
	                                                          || substr(vl_descri, 3, 3)
	                                                          || ';'
	                                                          || substr(vl_descri, 6, 3)
	                                                          || ';'
	                                                          || substr(vl_descri, 9, 75)
	                                                          || ';',v_fsysdate,i.smodcon,i.nlinea,i.ccuenta
	                                                                                               || vl_coletilla,v_tcuenta,abs(vl_importe),vl_proces,vl_fcontab,vl_fadm,vl_npoliza,vl_nrecibo,pnsinies,i.claenlace,vl_pais);

	                          v_nlinea:=v_nlinea+1;

	                          v_ntraza:=13;

	                          IF vl_tipo=1 THEN
	                            FETCH c_rec INTO vl_npoliza, vl_nrecibo, vl_fcontab, vl_importe, vl_coletilla, vl_proces, vl_fadm, vl_pais, vl_descri;
	                          ELSIF vl_tipo=2 THEN
	                            FETCH c_rec INTO vl_npoliza, vl_nrecibo, vl_fcontab, vl_importe, vl_coletilla, vl_proces, vl_fadm, vl_pais, vl_descri, vl_fcontab8;
	                          END IF;

	                          v_ntraza:=14;
	                        END IF;
	                    END LOOP;
	                EXCEPTION
	                    WHEN OTHERS THEN
	                      p_tab_error(f_sysdate, f_user, v_tobjeto, NULL, ';;'
	                                                                      || substr(i.claenlace, 1, 2)
	                                                                      || ';'
	                                                                      || substr(i.claenlace, 3, 2)
	                                                                      || ';'
	                                                                      || i.smodcon
	                                                                      || ';'
	                                                                      || i.nlinea
	                                                                      || ';'
	                                                                      || i.ccuenta
	                                                                      || ';;'
	                                                                      || i.tcuenta
	                                                                      || ';'
	                                                                      || i.cgroup
	                                                                      || ';'
	                                                                      || i.tdescri
	                                                                      || ' '
	                                                                      || ' '
	                                                                      || ';'
	                                                                      || to_char(SQLCODE)
	                                                                      || '-'
	                                                                      || replace(SQLERRM, ';', ' ')
	                                                                      || ' '
	                                                                      || 'FATAL 0 IMPOSIBLE EJECUTAR - PASO '
	                                                                      || v_ntraza, SQLERRM);
	                END;
	            EXCEPTION
	                WHEN OTHERS THEN
	                  p_tab_error(f_sysdate, f_user, v_tobjeto, NULL, ';;;'
	                                                                  || i.smodcon
	                                                                  || ';'
	                                                                  || i.nlinea
	                                                                  || ';'
	                                                                  || i.ccuenta
	                                                                  || ';;'
	                                                                  || i.tcuenta
	                                                                  || ';'
	                                                                  || i.cgroup
	                                                                  || ';'
	                                                                  || i.tdescri
	                                                                  || ' '
	                                                                  || ' '
	                                                                  || ';'
	                                                                  || 'FATAL 1 IMPOSIBLE EJECUTAR - PASO '
	                                                                  || v_ntraza, SQLERRM);
	            END;
	        END LOOP;

	        IF pfcalculi IS NULL  OR
	           pfcalculf IS NULL THEN
	          EXIT;
	        END IF;

	        v_ntraza:=20;

	        p_tab_error(f_sysdate, f_user, v_tobjeto, 0, 'Finaliza 1 '
	                                                     || v_fevaluar
	                                                     || ' final '
	                                                     || pfcalculf, SQLERRM);

	        v_fevaluar:=to_char(to_date(v_fevaluar, 'dd/mm/yyyy')+1, 'DD/MM/YYYY');

	        IF (to_date(v_fevaluar, 'dd/mm/yyyy')>to_date(pfcalculf, 'DDMMYYYY')) THEN
	          EXIT;
	        END IF;

	        p_tab_error(f_sysdate, f_user, v_tobjeto, 0, 'Finaliza 2'
	                                                     || v_fevaluar, SQLERRM);
	    END LOOP;

	    v_ntraza:=21;

	    COMMIT;

	    RETURN('select ''"''||REGEXP_SUBSTR(s, ''[^;]*'', 1, 1)||''"'' npoliza,
	       ''"''||REGEXP_SUBSTR(s, ''[^;]*'', 1, 3)||''"'' nrecibo,
	       ''"''||REGEXP_SUBSTR(s, ''[^;]*'', 1, 5)||''"'' docto,
	       ''"''||REGEXP_SUBSTR(s, ''[^;]*'', 1, 7)||''"'' libro,
	       /*REGEXP_SUBSTR(s, ''[^;]*'', 1, 9) smodcon,*/
	       /*REGEXP_SUBSTR(s, ''[^;]*'', 1, 11) nlinea,*/
	       ''"''||CHR(39)||REGEXP_SUBSTR(s, ''[^;]*'', 1, 13)||REGEXP_SUBSTR(s, ''[^;]*'', 1, 15)||''"'' ccuenta,
	       ''"''||REGEXP_SUBSTR(s, ''[^;]*'', 1, 17)||''"'' tcuenta,
	       ''"''||REGEXP_SUBSTR(s, ''[^;]*'', 1, 23)||''"'' importe,
	       ''"''||CHR(39)||REGEXP_SUBSTR(s, ''[^;]*'', 1, 25)||''"'' proceso,
	       ''"''||REGEXP_SUBSTR(s, ''[^;]*'', 1, 27)||''"'' fcontab,
	       ''"''||REGEXP_SUBSTR(s, ''[^;]*'', 1, 29)||''"'' fecha_admin,
	       ''"''||REGEXP_SUBSTR(s, ''[^;]*'', 1, 31)||''"'' pais,
	       ''"''||REGEXP_SUBSTR(s, ''[^;]*'', 1, 33)||''"'' compania,
	       ''"''||REGEXP_SUBSTR(s, ''[^;]*'', 1, 35)||''"'' snip,
	       ''"''||REGEXP_SUBSTR(s, ''[^;]*'', 1, 37)||''"'' compania2,
	       ''"''||REGEXP_SUBSTR(s, ''[^;]*'', 1, 39)||''"'' ramo,
	       ''"''||REGEXP_SUBSTR(s, ''[^;]*'', 1, 41)||''"'' sucursal,
	       ''"''||REGEXP_SUBSTR(s, ''[^;]*'', 1, 43)||''"'' descripcion
	from (select toutdia s from contab_asient_det where nvl(iapunte,0) <> 0 and sproces = '
	           || v_sproces
	           || ')
	where REGEXP_SUBSTR(s, ''[^;]*'', 1, 15) is not null
	and REGEXP_SUBSTR(s, ''[^;]*'', 1, 25) like '''
	           || nvl(pcorasuc, '%')
	           || ''' ');
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam
	                                                                 || ': Error'
	                                                                 || SQLCODE, SQLERRM);

	             RETURN 'select 1 from dual';
	END f_907_det;
	FUNCTION f_list271_cab(
			p_nidioma NUMBER,
			 p_sproduc NUMBER,
			 p_nlinea NUMBER
	)   RETURN STRINGTABLE
	IS
	  aux_table STRINGTABLE := stringtable();
	  n       INTEGER := 0;
	  v_cramo NUMBER;
	PROCEDURE p_aberto_linea1
	IS
	BEGIN
	    FOR r IN (SELECT f_axis_literales(100784, p_nidioma) /*Ramo*/
	                     || ';'
	                     || f_axis_literales(100829, p_nidioma) /*Producto*/
	                     || ';'
	                     || f_axis_literales(9001875, p_nidioma) /*Plano*/
	                     || ';'
	                     || f_axis_literales(108021, p_nidioma) /*Simulación*/
	                     || ';'
	                     || 'Escrit.;'
	                     || f_axis_literales(100577, p_nidioma) /*NIF*/
	                     || ';'
	                     || f_axis_literales(101027, p_nidioma) /*Tomador*/
	                     || ';'
	                     || f_axis_literales(120459, p_nidioma) /*Participante*/
	                     || ';'
	                     || f_axis_literales(100562, p_nidioma) /*Data*/
	                     || ';'
	                     || f_axis_literales(107116, p_nidioma) /*Prima inicial*/
	                     || ';;'
	                     || f_axis_literales (9906078, p_nidioma) /*Nº unidades de participaçao da prima inicial*/
	                     || ';;'
	                     || f_axis_literales(9906079, p_nidioma) /*Renovaçao de carteira*/
	                     || ';;'
	                     || f_axis_literales (9906080, p_nidioma) /*Nº unidades de participação da renovação de carteira*/
	                     || ';;'
	                     || f_axis_literales(180435, p_nidioma) /*Contribuição extraordinária*/
	                     || ';;'
	                     || f_axis_literales (9906081, p_nidioma) /*Nº unidades de participação da Contribuição extraordinária*/
	                     || ';;'
	                     || f_axis_literales(9907227, p_nidioma) --Pago sinistro
	                     || ';'
	                     || f_axis_literales (9907228, p_nidioma) /*Nº unidades de participação da Pago sinitro*/
	                     || ';'
	                     || f_axis_literales(9907230, p_nidioma) --Pago prestação
	                     || ';'
	                     || f_axis_literales (9907229, p_nidioma) /*Nº unidades de participação da Pago prestação*/
	                     || ';'
	                     || f_axis_literales(9907231, p_nidioma) --Anulaçao de apolice
	                     || ';'
	                     || f_axis_literales (9907232, p_nidioma) /*Nº unidades de participação da anulaçao de apolice*/
	                     || ';'
	                     || f_axis_literales(9906082, p_nidioma) --Provisão
	                     || ';'
	                     || f_axis_literales (9906083, p_nidioma) /*Total de unidades de participação existentes*/
	                     || ';'
	                     || f_axis_literales(108645, p_nidioma) --Moeda
	                     linea
	                FROM dual) LOOP
	        aux_table.extend;

	        n:=n+1;

	        aux_table(n):=r.linea;
	    END LOOP;
	END p_aberto_linea1;
	PROCEDURE p_fechado_linea1
	IS
	BEGIN
	    FOR r IN (SELECT f_axis_literales(100784, p_nidioma) /*Ramo*/
	                     || ';'
	                     || f_axis_literales(100829, p_nidioma) /*Producto*/
	                     || ';'
	                     || f_axis_literales(9001875, p_nidioma) /*Plano*/
	                     || ';'
	                     || f_axis_literales(100577, p_nidioma) /*NIF*/
	                     || ';'
	                     || f_axis_literales(120459, p_nidioma) /*Participante*/
	                     || ';'
	                     || f_axis_literales(100562, p_nidioma) /*Data*/
	                     || ';'
	                     || f_axis_literales(108230, p_nidioma) /*Contribuições*/
	                     || ';;'
	                     || f_axis_literales (9907736, p_nidioma) /*Nº unidades de participação das aportaciones*/
	                     || ';;'
	                     || f_axis_literales(180435, p_nidioma) /*Contribuição extraordinária*/
	                     || ';;'
	                     || f_axis_literales (9906081, p_nidioma) /*Nº unidades de participação da Contribuição extraordinária*/
	                     || ';;'
	                     || f_axis_literales(9907227, p_nidioma) --Pago sinistro
	                     || ';'
	                     || f_axis_literales (9907228, p_nidioma) /*Nº unidades de participação da Pago sinitro*/
	                     || ';'
	                     || f_axis_literales(9907231, p_nidioma) --Anulaçao de apolice
	                     || ';'
	                     || f_axis_literales (9907232, p_nidioma) /*Nº unidades de participação da anulaçao de apolice*/
	                     || ';'
	                     || f_axis_literales(9906082, p_nidioma) --Provisão
	                     || ';'
	                     || f_axis_literales(9907737, p_nidioma) /*Unidades de Participação*/
	                     || ';;'
	                     || f_axis_literales (9906083, p_nidioma) /*Total de unidades de participação existentes*/
	                     || ';'
	                     || f_axis_literales(108645, p_nidioma) --Moeda
	                     linea
	                FROM dual) LOOP
	        aux_table.extend;

	        n:=n+1;

	        aux_table(n):=r.linea;
	    END LOOP;
	END p_fechado_linea1;
	PROCEDURE p_aberto_linea2
	IS
	BEGIN
	    FOR r IN (SELECT ';;;;;;;;;'
	                     || f_axis_literales(9903053, p_nidioma)
	                     || ';'
	                     || /*Valor Líquido*/
	                     f_axis_literales(9906102, p_nidioma)
	                     || ';'
	                     || /*Valor iLíquido*/
	                     f_axis_literales(9903053, p_nidioma)
	                     || ';'
	                     || f_axis_literales(9906102, p_nidioma)
	                     || ';'
	                     || f_axis_literales(9903053, p_nidioma)
	                     || ';'
	                     || f_axis_literales(9906102, p_nidioma)
	                     || ';'
	                     || f_axis_literales(9903053, p_nidioma)
	                     || ';'
	                     || f_axis_literales(9906102, p_nidioma)
	                     || ';'
	                     || f_axis_literales(9903053, p_nidioma)
	                     || ';'
	                     || f_axis_literales(9906102, p_nidioma)
	                     || ';'
	                     || f_axis_literales(9903053, p_nidioma)
	                     || ';'
	                     || f_axis_literales(9906102, p_nidioma)
	                     || ';'
	                     || f_axis_literales(9903053, p_nidioma)
	                     || ';'
	                     || f_axis_literales(9903053, p_nidioma)
	                     || ';'
	                     || f_axis_literales(9903053, p_nidioma)
	                     || ';'
	                     || f_axis_literales(9903053, p_nidioma)
	                     || ';'
	                     || f_axis_literales(9903053, p_nidioma)
	                     || ';'
	                     || f_axis_literales(9903053, p_nidioma)
	                     || ';' linea
	                FROM dual) LOOP
	        aux_table.extend;

	        n:=n+1;

	        aux_table(n):=r.linea;
	    END LOOP;
	END p_aberto_linea2;
	PROCEDURE p_fechado_linea2
	IS
	BEGIN
	  FOR r IN
	  (
	         SELECT ';;;;;;'
	                       || f_axis_literales(120459, p_nidioma)
	                       || ';'
	                       ||
	                /*Participante*/
	                f_axis_literales(101619, p_nidioma)
	                       || ';'
	                       ||
	                /*Empresa*/
	                f_axis_literales(120459, p_nidioma)
	                       || ';'
	                       ||
	                /*Participante*/
	                f_axis_literales(101619, p_nidioma)
	                       || ';'
	                       ||
	                /*Empresa*/
	                f_axis_literales(120459, p_nidioma)
	                       || ';'
	                       ||
	                /*Participante*/
	                f_axis_literales(101619, p_nidioma)
	                       || ';'
	                       ||
	                /*Empresa*/
	                f_axis_literales(120459, p_nidioma)
	                       || ';'
	                       ||
	                /*Participante*/
	                f_axis_literales(101619, p_nidioma)
	                       || ';;;;;;'
	                       ||
	                /*Empresa*/
	                f_axis_literales(120459, p_nidioma)
	                       || ';'
	                       ||
	                /*Participante*/
	                f_axis_literales(101619, p_nidioma)
	                       || ';' --Empresa
	                linea
	         FROM   dual)
	  LOOP
	    aux_table.extend;
	    n := n + 1;
	    aux_table(n) := r.linea;
	  END LOOP;
	END p_fechado_linea2;
	BEGIN
	  SELECT cramo
	  INTO   v_cramo
	  FROM   productos
	  WHERE  sproduc = p_sproduc;

	  IF v_cramo = 6
	    AND
	    p_nlinea = 1 THEN
	    /*fondos abiertos*/
	    p_aberto_linea1;
	  ELSIF v_cramo <> 6
	    AND
	    p_nlinea = 1 THEN
	    /*fondos fechados*/
	    p_fechado_linea1;
	  ELSIF v_cramo = 6
	    AND
	    p_nlinea = 2 THEN
	    /*fondos abiertos*/
	    p_aberto_linea2;
	  ELSIF v_cramo <> 6
	    AND
	    p_nlinea = 2 THEN
	    /*fondos fechados*/
	    p_fechado_linea2;
	  END IF;
	  RETURN aux_table;
	END f_list271_cab;
	FUNCTION f_list271_det(
			 p_nidioma NUMBER,
			 p_sproduc NUMBER,
			 p_fdesde VARCHAR2,
			 p_fhasta VARCHAR2
	)   RETURN STRINGTABLE
	IS
	  aux_table STRINGTABLE := stringtable();
	  n       INTEGER := 0;
	  v_cramo NUMBER;
	PROCEDURE p_aberto_det
	IS
	BEGIN
	    FOR r IN (SELECT cramo
	                     || ' '
	                     || ff_desramo(cramo, 4)
	                     || ';'
	                     || sproduc
	                     || ' '
	                     || f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, 4)
	                     || ';'
	                     || poliza
	                     || ';'
	                     || simulacion
	                     || ';'
	                     || escrit
	                     || ';'
	                     || nnumide
	                     || ';'
	                     || tomador
	                     || ';'
	                     || asegurado
	                     || ';'
	                     || to_char(fefecto, 'DD/MM/YYYY')
	                     || ';'
	                     || to_char(SUM(nvl(priliq, 0)), 'FM999G999G999G990D00')
	                     || ';'
	                     || to_char(SUM(nvl(priiliq, 0)), 'FM999G999G999G990D00')
	                     || ';'
	                     || to_char(SUM(nvl(priuni, 0)), 'FM999G999G999G990D00')
	                     || ';'
	                     || to_char(SUM(nvl(priiuni, 0)), 'FM999G999G999G990D00')
	                     || ';'
	                     || to_char(SUM(nvl(carliq, 0)), 'FM999G999G999G990D00')
	                     || ';'
	                     || to_char(SUM(nvl(cariliq, 0)), 'FM999G999G999G990D00')
	                     || ';'
	                     || to_char(SUM(nvl(caruni, 0)), 'FM999G999G999G990D00')
	                     || ';'
	                     || to_char(SUM(nvl(cariuni, 0)), 'FM999G999G999G990D00')
	                     || ';'
	                     || to_char(SUM(nvl(extliq, 0)), 'FM999G999G999G990D00')
	                     || ';'
	                     || to_char(SUM(nvl(extiliq, 0)), 'FM999G999G999G990D00')
	                     || ';'
	                     || to_char(SUM(nvl(extuni, 0)), 'FM999G999G999G990D00')
	                     || ';'
	                     || to_char(SUM(nvl(extiuni, 0)), 'FM999G999G999G990D00')
	                     || ';'
	                     || to_char(SUM(nvl(sinliq, 0)), 'FM999G999G999G990D00')
	                     || ';'
	                     || to_char(SUM(nvl(sinuni, 0)), 'FM999G999G999G990D00')
	                     || ';'
	                     || to_char(SUM(nvl(preliq, 0)), 'FM999G999G999G990D00')
	                     || ';'
	                     || to_char(SUM(nvl(preuni, 0)), 'FM999G999G999G990D00')
	                     || ';'
	                     || to_char(SUM(nvl(anuliq, 0)), 'FM999G999G999G990D00')
	                     || ';'
	                     || to_char(SUM(nvl(anuuni, 0)), 'FM999G999G999G990D00')
	                     || ';'
	                     || to_char(SUM(nvl(priiuni, 0)+nvl(cariuni, 0)
	                                    +nvl(extiuni, 0)+nvl(sinliq, 0)+nvl(preliq, 0)
	                                    +nvl(anuliq, 0))*(SELECT iuniact
	                                                        FROM tabvalces
	                                                       WHERE ccesta=cesta AND
	                                                             fvalor=(SELECT max(fvalor)
	                                                                       FROM tabvalces
	                                                                      WHERE ccesta=cesta AND
	                                                                            fvalor<=f_sysdate)), 'FM999G999G999G990D00')
	                     || ';'
	                     || to_char(SUM(nvl(priiuni, 0)+nvl(cariuni, 0)
	                                    +nvl(extiuni, 0)+nvl(sinuni, 0)+nvl(preuni, 0)
	                                    +nvl(anuuni, 0)), 'FM999G999G999G990D00')
	                     || ';'
	                     || pac_eco_monedas.f_obtener_moneda_informe(NULL, sproduc) linea
	                FROM (SELECT ctiprec,cramo,s.sproduc,cmodali,ctipseg,ccolect,npoliza
	                                                                             || '-'
	                                                                             || ncertif poliza,nsolici simulacion,s.cagente escrit,p.nnumide,trim(i.tnombre)
	                                                                                                                                             || ' '
	                                                                                                                                             || trim(i.tapelli1) tomador,trim(u.tnombre)
	                                                                                                                                                                         || ' '
	                                                                                                                                                                         || trim(u.tapelli1) asegurado,s.fefecto,-SUM(decode(c.cmovimi, 54, nvl(abs(c.imovimi), 0))) anuliq,-SUM(decode(c.cmovimi, 54, nvl(abs(c.nunidad), 0))) anuuni,decode(si.sseguro, NULL, NULL,
	                                                                                                                                                                                                                                                                                                                                                          0, NULL,
	                                                                                                                                                                                                                                                                                                                                                          -SUM(decode(c.cmovimi, 91, nvl(abs(c.imovimi), 0)))+SUM(decode(c.cmovimi, 90, nvl(abs(c.imovimi), 0)))) sinliq,decode(si.sseguro, NULL, NULL,
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            0, NULL,
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            -SUM(decode(c.cmovimi, 91, nvl(abs(c.nunidad), 0)))+SUM(decode(c.cmovimi, 90, nvl(abs(c.nunidad), 0)))) sinuni,decode(pr.sseguro, NULL, NULL,
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              0, NULL,
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              -SUM(decode(c.cmovimi, 92, nvl(abs(c.nunidad), 0)))+SUM(decode(c.cmovimi, 90, nvl(abs(c.nunidad), 0)))) preuni,decode(pr.sseguro, NULL, NULL,
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                0, NULL,
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                -SUM(decode(c.cmovimi, 92, nvl(abs(c.imovimi), 0)))+SUM(decode(c.cmovimi, 90, nvl(abs(c.imovimi), 0)))) preliq,decode(ctiprec, 0, SUM(decode(c.cmovimi, 45, nvl(c.imovimi, 0),
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        0)),
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               NULL) priliq,decode(r.ctiprec, 0, SUM(decode(c.cmovimi, 45, nvl(c.imovimi, 0),
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       0))-SUM(decode(c.cmovimi, 88, nvl(c.imovimi, 0),
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 0)),
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              NULL) priiliq,decode(ctiprec, 0, SUM(decode(c.cmovimi, 45, nvl(c.nunidad, 0),
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     0)),
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            NULL) priuni,decode(ctiprec, 0, SUM(decode(c.cmovimi, 45, nvl(c.nunidad, 0)
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            , 0)
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            )
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            +SUM(decode(c.cmovimi, 88, nvl(c.nunidad, 0
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            ), 0
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            )),
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         NULL) priiuni,decode(ctiprec, 3, SUM(
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       decode(c.cmovimi, 45,
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       nvl(c.imovimi, 0),
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         0)),
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       NULL) carliq,
	                             decode(ctiprec, 3, SUM(
	                                     decode(c.cmovimi, 45, nvl(c.imovimi, 0),
	                                                       0))-
	                                     SUM(
	                                             decode(c.cmovimi, 88, nvl(c.imovimi, 0),
	                                                               0)),
	                                                         NULL) cariliq,decode(ctiprec, 3, SUM(decode(c.cmovimi, 45, nvl(c.nunidad, 0),
	                                                                                                                0)),
	                                                                                       NULL) caruni,decode(ctiprec, 3, SUM(decode(c.cmovimi, 45, nvl(c.nunidad, 0), 0))
	                                                                                                                       +SUM(decode(c.cmovimi, 88, nvl(c.nunidad, 0), 0)),
	                                                                                                                    NULL) cariuni,decode(ctiprec, 4, SUM(decode(c.cmovimi, 45, nvl(c.imovimi, 0),
	                                                                                                                                                                           0)),
	                                                                                                                                                  NULL) extliq,decode(ctiprec, 4, SUM(decode(c.cmovimi, 45, nvl(c.imovimi, 0),
	                                                                                                                                                                                                        0))-SUM(decode(c.cmovimi, 88, nvl(c.imovimi, 0),
	                                                                                                                                                                                                                                  0)),
	                                                                                                                                                                               NULL) extiliq,decode(ctiprec, 4, SUM(decode(c.cmovimi, 45, nvl(c.nunidad, 0),
	                                                                                                                                                                                                                                      0)),
	                                                                                                                                                                                                             NULL) extuni,decode(ctiprec, 4, SUM(decode(c.cmovimi, 45, nvl(c.nunidad, 0), 0))
	                                                                                                                                                                                                                                             +SUM(decode(c.cmovimi, 88, nvl(c.nunidad, 0), 0)),
	                                                                                                                                                                                                                                          NULL) extiuni,max(cesta) cesta
	                        FROM ctaseguro c
	                             inner join seguros s ON s.sseguro=c.sseguro
	                             inner join tomadores t ON t.sseguro=c.sseguro
	                             inner join asegurados a ON a.sseguro=c.sseguro
	                             inner join per_detper i ON t.sperson=i.sperson
	                             inner join per_personas p ON p.sperson=i.sperson
	                             inner join per_detper u ON u.cagente=i.cagente AND
	                                                        u.sperson=a.sperson
	                             left outer join recibos r ON r.nrecibo=c.nrecibo
	                             left outer join sin_siniestro si ON si.nsinies=c.nsinies
	                             left outer join pagosrenta pr ON pr.srecren=c.srecren
	                       WHERE s.sproduc=p_sproduc AND
	                             c.fcontab BETWEEN to_date(p_fdesde, 'ddmmyyyy') AND to_date(p_fhasta, 'ddmmyyyy') AND
	                             t.nordtom=1 AND
	                             a.norden=1 AND
	                             c.cmovanu=0 AND
	                             i.fmovimi=(SELECT max(fmovimi)
	                                          FROM per_detper o
	                                         WHERE o.sperson=t.sperson) AND
	                             ((nvl(f_parproductos_v(s.sproduc, 'ES_PRODUCTO_INDEXADO'), 0)=1 AND
	                               c.cesta IS NOT NULL)  OR
	                              (nvl(f_parproductos_v(s.sproduc, 'ES_PRODUCTO_INDEXADO'), 0)=1 AND
	                               c.cmovimi=0)  OR
	                              (nvl(f_parproductos_v(s.sproduc, 'ES_PRODUCTO_INDEXADO'), 0)<>1)) AND
	                             ((r.sseguro IS NOT NULL  OR
	                               pr.sseguro IS NOT NULL  OR
	                               si.sseguro IS NOT NULL)  OR
	                              c.cmovimi=54)
	                       GROUP BY ctiprec,cramo,s.sproduc,cmodali,ctipseg,ccolect,npoliza
	                                || '-'
	                                || ncertif,nsolici,s.cagente,p.nnumide,trim(i.tnombre)
	                                || ' '
	                                || trim(i.tapelli1),trim(u.tnombre)
	                                || ' '
	                                || trim(u.tapelli1),s.fefecto,si.sseguro,pr.sseguro)
	               GROUP BY cramo,sproduc,cmodali,ctipseg,ccolect,poliza,simulacion,escrit,nnumide,tomador,asegurado,fefecto,cesta
	               ORDER BY cramo,sproduc,poliza) LOOP
	        aux_table.extend;

	        n:=n+1;

	        aux_table(n):=r.linea;
	    END LOOP;
	END p_aberto_det;
	PROCEDURE p_fechado_det
	IS
	BEGIN
	  FOR r IN
	  (
	           SELECT   cramo
	                             || ' '
	                             || ff_desramo(cramo, 4)
	                             || ';'
	                             || sproduc
	                             || ' '
	                             || f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1, 4)
	                             || ';'
	                             || poliza
	                             || ';'
	                             || nnumide
	                             || ';'
	                             || asegurado
	                             || ';'
	                             || to_char(fefecto, 'DD/MM/YYYY')
	                             || ';'
	                             || to_char(SUM(nvl(contrapor, 0)), 'FM999G999G999G990D00')
	                             || ';'
	                             || to_char(SUM(nvl(contremp, 0)), 'FM999G999G999G990D00')
	                             || ';'
	                             || to_char(SUM(nvl(contruniapor, 0)), 'FM999G999G999G990D00')
	                             || ';'
	                             || to_char(SUM(nvl(contruniemp, 0)), 'FM999G999G999G990D00')
	                             || ';'
	                             || to_char(SUM(nvl(contrextapor, 0)), 'FM999G999G999G990D00')
	                             || ';'
	                             || to_char(SUM(nvl(contrextemp, 0)), 'FM999G999G999G990D00')
	                             || ';'
	                             || to_char(SUM(nvl(contruniextapor, 0)), 'FM999G999G999G990D00')
	                             || ';'
	                             || to_char(SUM(nvl(contruniextemp, 0)), 'FM999G999G999G990D00')
	                             || ';'
	                             || to_char(SUM(nvl(sinliq, 0)), 'FM999G999G999G990D00')
	                             || ';'
	                             || to_char(SUM(nvl(sinuni, 0)), 'FM999G999G999G990D00')
	                             || ';'
	                             || to_char(SUM(nvl(anuliq, 0)), 'FM999G999G999G990D00')
	                             || ';'
	                             || to_char(SUM(nvl(anuuni, 0)), 'FM999G999G999G990D00')
	                             || ';'
	                             || to_char(SUM(nvl(contruniapor, 0) + nvl(contruniemp, 0) + nvl(contruniextapor, 0) + nvl(contruniextemp, 0) + nvl(sinuni, 0) + nvl(anuuni, 0)) *
	                    (
	                           SELECT iuniact
	                           FROM   tabvalces
	                           WHERE  ccesta = cesta
	                           AND    fvalor =
	                                  (
	                                         SELECT max(fvalor)
	                                         FROM   tabvalces
	                                         WHERE  ccesta = cesta
	                                         AND    fvalor <= f_sysdate)), 'FM999G999G999G990D00')
	                             || ';'
	                             || to_char(SUM(nvl(contruniapor, 0) + nvl(contruniextapor, 0)), 'FM999G999G999G990D00')
	                             || ';'
	                             || to_char(SUM(nvl(contruniemp, 0) + nvl(contruniextemp, 0)), 'FM999G999G999G990D00')
	                             || ';'
	                             || to_char(SUM(nvl(contruniapor, 0) + nvl(contruniemp, 0) + nvl(contruniextapor, 0) + nvl(contruniextemp, 0) + nvl(sinuni, 0) + nvl(anuuni, 0)), 'FM999G999G999G990D00')
	                             || ';'
	                             || pac_eco_monedas.f_obtener_moneda_informe(NULL, sproduc) linea
	           FROM     (
	                                    SELECT          ctiprec,
	                                                    cramo,
	                                                    s.sproduc,
	                                                    cmodali,
	                                                    ctipseg,
	                                                    ccolect,
	                                                    npoliza
	                                                                    || '-'
	                                                                    || ncertif poliza,
	                                                    nsolici                    simulacion,
	                                                    p.nnumide,
	                                                    trim(i.tnombre)
	                                                                    || ' '
	                                                                    || trim(i.tapelli1) tomador,
	                                                    trim(u.tnombre)
	                                                                    || ' '
	                                                                    || trim(u.tapelli1) asegurado,
	                                                    s.fefecto,
	                                                    -SUM(decode(c.cmovimi,
	                                                                54, nvl(abs(c.imovimi), 0))) anuliq,
	                                                    -SUM(decode(c.cmovimi,
	                                                                54, nvl(abs(c.nunidad), 0))) anuuni,
	                                                    decode(si.sseguro,
	                                                           NULL, NULL,
	                                                           0, NULL,
	                                                                                                    -SUM(decode(c.cmovimi,
	                                                                       91, nvl(abs(c.imovimi), 0))) + SUM(decode(c.cmovimi,
	                                                                                                                 90, nvl(abs(c.imovimi), 0)))) sinliq,
	                                                    decode(si.sseguro,
	                                                           NULL, NULL,
	                                                           0, NULL,
	                                                                                                    -SUM(decode(c.cmovimi,
	                                                                       91, nvl(abs(c.nunidad), 0))) + SUM(decode(c.cmovimi,
	                                                                                                                 90, nvl(abs(c.nunidad), 0)))) sinuni,
	                                                    CASE
	                                                                    WHEN ctiprec = 3
	                                                                    AND             r.ctipapor = 1
	                                                                    AND             r.ctipaportante = 1 THEN SUM (decode(c.cmovimi,
	                                                                                                                         45, nvl(c.imovimi, 0),
	                                                                                                                         0))
	                                                                                    /*cont per par*/
	                                                                    ELSE NULL
	                                                    END contrapor,
	                                                    CASE
	                                                                    WHEN ctiprec = 3
	                                                                    AND             r.ctipapor = 4
	                                                                    AND             r.ctipaportante = 4 THEN SUM (decode(c.cmovimi,
	                                                                                                                         45, nvl(c.imovimi, 0),
	                                                                                                                         0))
	                                                                                    /*cont per emp*/
	                                                                    ELSE NULL
	                                                    END contremp,
	                                                    CASE
	                                                                    WHEN ctiprec = 3
	                                                                    AND             r.ctipapor = 1
	                                                                    AND             r.ctipaportante = 1 THEN SUM(decode(c.cmovimi,
	                                                                                                                        45, nvl(c.nunidad, 0),
	                                                                                                                        0))
	                                                                    ELSE NULL
	                                                    END contruniapor,
	                                                    CASE
	                                                                    WHEN ctiprec = 3
	                                                                    AND             r.ctipapor = 4
	                                                                    AND             r.ctipaportante = 4 THEN SUM(decode(c.cmovimi,
	                                                                                                                        45, nvl(c.nunidad, 0),
	                                                                                                                        0))
	                                                                    ELSE NULL
	                                                    END contruniemp,
	                                                    CASE
	                                                                    WHEN ctiprec = 4
	                                                                    AND             r.ctipapor = 1
	                                                                    AND             r.ctipaportante = 1 THEN SUM (decode(c.cmovimi,
	                                                                                                                         45, nvl(c.imovimi, 0),
	                                                                                                                         0))
	                                                                                    /*cont ext par*/
	                                                                    ELSE NULL
	                                                    END contrextapor,
	                                                    CASE
	                                                                    WHEN ctiprec = 4
	                                                                    AND             r.ctipapor = 4
	                                                                    AND             r.ctipaportante = 4 THEN SUM (decode(c.cmovimi,
	                                                                                                                         45, nvl(c.imovimi, 0),
	                                                                                                                         0))
	                                                                                    /*cont ext emp*/
	                                                                    WHEN ctiprec = 4
	                                                                    AND             r.ctipapor = 6
	                                                                    AND             r.ctipaportante = 4 THEN SUM (decode(c.cmovimi,
	                                                                                                                         45, nvl(c.imovimi, 0),
	                                                                                                                         0))
	                                                                                    /*cont ext serv pas*/
	                                                                    WHEN ctiprec = 4
	                                                                    AND             r.ctipapor = 7
	                                                                    AND             r.ctipaportante = 4 THEN SUM (decode(c.cmovimi,
	                                                                                                                         45, nvl(c.imovimi, 0),
	                                                                                                                         0))
	                                                                                    /*cont ext benef*/
	                                                                    ELSE NULL
	                                                    END contrextemp,
	                                                    CASE
	                                                                    WHEN ctiprec = 4
	                                                                    AND             r.ctipapor = 1
	                                                                    AND             r.ctipaportante = 1 THEN SUM(decode(c.cmovimi,
	                                                                                                                        45, nvl(c.nunidad, 0),
	                                                                                                                        0))
	                                                                    ELSE NULL
	                                                    END contruniextapor,
	                                                    CASE
	                                                                    WHEN ctiprec = 4
	                                                                    AND             r.ctipapor = 4
	                                                                    AND             r.ctipaportante = 4 THEN SUM (decode(c.cmovimi,
	                                                                                                                         45, nvl(c.nunidad, 0),
	                                                                                                                         0))
	                                                                                    /*cont ext emp*/
	                                                                    WHEN ctiprec = 4
	                                                                    AND             r.ctipapor = 6
	                                                                    AND             r.ctipaportante = 4 THEN SUM (decode(c.cmovimi,
	                                                                                                                         45, nvl(c.nunidad, 0),
	                                                                                                                         0))
	                                                                                    /*cont ext serv pas*/
	                                                                    WHEN ctiprec = 4
	                                                                    AND             r.ctipapor = 7
	                                                                    AND             r.ctipaportante = 4 THEN SUM (decode(c.cmovimi,
	                                                                                                                         45, nvl(c.nunidad, 0),
	                                                                                                                         0))
	                                                                                    /*cont ext benef*/
	                                                                    ELSE NULL
	                                                    END        contruniextemp,
	                                                    max(cesta) cesta
	                                    FROM            ctaseguro c
	                                    inner join      seguros s
	                                    ON              s.sseguro = c.sseguro
	                                    inner join      tomadores t
	                                    ON              t.sseguro = c.sseguro
	                                    inner join      asegurados a
	                                    ON              a.sseguro = c.sseguro
	                                    inner join      per_detper i
	                                    ON              t.sperson = i.sperson
	                                    inner join      per_personas p
	                                    ON              p.sperson = i.sperson
	                                    inner join      per_detper u
	                                    ON              u.cagente = i.cagente
	                                    AND             u.sperson = a.sperson
	                                    left outer join recibos r
	                                    ON              r.nrecibo = c.nrecibo
	                                    left outer join sin_siniestro si
	                                    ON              si.nsinies = c.nsinies
	                                    WHERE           s.sproduc = p_sproduc
	                                    AND             c.fcontab BETWEEN to_date(p_fdesde, 'ddmmyyyy') AND             to_date(p_fhasta, 'ddmmyyyy')
	                                    AND             t.nordtom = 1
	                                    AND             a.norden = 1
	                                    AND             c.cmovanu = 0
	                                    AND             i.fmovimi =
	                                                    (
	                                                           SELECT max(fmovimi)
	                                                           FROM   per_detper o
	                                                           WHERE  o.sperson = t.sperson)
	                                    AND            ((
	                                                                                    nvl(f_parproductos_v(s.sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
	                                                                    AND             c.cesta IS NOT NULL)
	                                                    OR             (
	                                                                                    nvl(f_parproductos_v(s.sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
	                                                                    AND             c.cmovimi = 0)
	                                                    OR             (
	                                                                                    nvl(f_parproductos_v(s.sproduc, 'ES_PRODUCTO_INDEXADO'), 0) <> 1))
	                                    AND            ((
	                                                                                    r.sseguro IS NOT NULL
	                                                                    OR              si.sseguro IS NOT NULL)
	                                                    OR              c.cmovimi = 54)
	                                    GROUP BY        ctiprec,
	                                                    r.ctipapor,
	                                                    r.ctipaportante,
	                                                    cramo,
	                                                    s.sproduc,
	                                                    cmodali,
	                                                    ctipseg,
	                                                    ccolect,
	                                                    npoliza
	                                                                    || '-'
	                                                                    || ncertif,
	                                                    nsolici,
	                                                    s.cagente,
	                                                    p.nnumide,
	                                                    trim(i.tnombre)
	                                                                    || ' '
	                                                                    || trim(i.tapelli1),
	                                                    trim(u.tnombre)
	                                                                    || ' '
	                                                                    || trim(u.tapelli1),
	                                                    s.fefecto,
	                                                    si.sseguro)
	           GROUP BY cramo,
	                    sproduc,
	                    cmodali,
	                    ctipseg,
	                    ccolect,
	                    poliza,
	                    simulacion,
	                    nnumide,
	                    tomador,
	                    asegurado,
	                    fefecto,
	                    cesta
	           ORDER BY cramo,
	                    sproduc,
	                    poliza)
	  LOOP
	    aux_table.extend;
	    n := n + 1;
	    aux_table(n) := r.linea;
	  END LOOP;
	END p_fechado_det;
	BEGIN
	  SELECT cramo
	  INTO   v_cramo
	  FROM   productos
	  WHERE  sproduc = p_sproduc;

	  IF v_cramo = 6 THEN
	    /*fondos abiertos*/
	    p_aberto_det;
	  ELSIF v_cramo <> 6 THEN
	    /*fondos fechados*/
	    p_fechado_det;
	  END IF;
	  RETURN aux_table;
	END f_list271_det;

   FUNCTION f_list1001001(linea VARCHAR2)
      RETURN stringtable IS
      aux_table      stringtable := stringtable();
      n              INTEGER := 0;
      v_sseguro      VARCHAR2(200) := NVL(pac_map.f_valor_parametro('|', linea, 4, '271'), '');
      v_sperson      VARCHAR2(200) := NVL(pac_map.f_valor_parametro('|', linea, 5, '271'), '');
   BEGIN

         dbms_output.put_line('v_sseguro: ' || v_sseguro );
         dbms_output.put_line('v_sperson: ' || v_sperson );

      FOR r IN (SELECT DISTINCT telefono || '|' || mail linea
                           FROM v_personas_poliza
                          WHERE codigoseguro = v_sseguro
                            AND codigopersona = v_sperson
                        ORDER BY linea DESC) LOOP

         aux_table.EXTEND;
         n := n + 1;
         aux_table(n) := r.linea;
      END LOOP;

      RETURN aux_table;
   END f_list1001001;

   FUNCTION f_list1001003(linea VARCHAR2)
      RETURN stringtable IS
      aux_table      stringtable := stringtable();
      n              INTEGER := 0;
      d              INTEGER := 0;
      v_sseguro      VARCHAR2(200) := NVL(pac_map.f_valor_parametro('|', linea, 3, '271'), '');
	    v_nrecibo      VARCHAR2(200) := NVL(pac_map.f_valor_parametro('|', linea, 4, '271'), '');
      v_poliza      VARCHAR2(20);
      v_ctipeve     VARCHAR2(5) := NVL(pac_map.f_valor_parametro('|', linea, 2, '271'), '');
      nlinea        VARCHAR2(200) := NULL;
	    vruta			VARCHAR2(200);
	    i				INTEGER := 1;
		mensajes t_iax_mensajes;

   BEGIN

       dbms_output.put_line('f_list1001003 ctipeve: ' || v_ctipeve );

       SELECT NPOLIZA||'-'||NCERTIF
       INTO v_poliza
       FROM SEGUROS
       WHERE SSEGURO = v_sseguro;

       --Cursor de documentos del tipo
       FOR c IN (SELECT CVALEMP, CVALDEF
                  FROM INT_CODIGOS_EMP
                 WHERE CCODIGO = 'DOCUMENTO_MAILING'
                  AND CVALAXIS = v_ctipeve) LOOP

          --Montar la ruta donde se guarda
          IF c.CVALDEF IN ('RECIBO','DOCPOL') THEN
              SELECT CVALEMP||'\'||c.CVALEMP||'_'||v_poliza||'_'||v_nrecibo||'.pdf' linea
					   INTO vruta
					  FROM INT_CODIGOS_EMP
					   WHERE CCODIGO = 'RUTA_PLANTILLA';
          ELSE
            SELECT CVALEMP||'\'||c.CVALEMP||'_'||v_poliza||'.pdf' linea
             INTO vruta
            FROM INT_CODIGOS_EMP
             WHERE CCODIGO = 'RUTA_PLANTILLA';
          END IF;

          IF vruta IS NOT NULL THEN
            IF i = 1 THEN
              nlinea := vruta;
            ELSE
              nlinea := nlinea ||'#'|| vruta;
            END IF;
          END IF;

          i := i + 1;

          dbms_output.put_line('f_list1001003 nlinea: ' || nlinea );

        END LOOP;

        dbms_output.put_line('FINAL f_list1001003 nlinea: ' || nlinea );

        aux_table.EXTEND;
        n := n + 1;
        aux_table(n) := nlinea;


      RETURN aux_table;
   END f_list1001003;

    --Inicio Tarea 4136 Kaio
    -- INI IAXIS-4136 JRVG  23/04/2020
     function f_ins_obs_cuentacobro(
     pobservacion IN obs_cuentacobro.observacion%TYPE,
      psseguro IN obs_cuentacobro.sseguro%TYPE,
      pnrecibo IN obs_cuentacobro.nrecibo%TYPE,
      pmarca  IN  obs_cuentacobro.cmarca%TYPE,
      mensajes IN OUT t_iax_mensajes)

      RETURN NUMBER IS


      vobservacion   VARCHAR2(200) := pobservacion;
     -- vsseguro       NUMBER := psseguro;
      vnrecibo        NUMBER := pnrecibo;
      vmarca          NUMBER := pmarca;
      vobject    VARCHAR2(500) := 'PAC_INFORMES.f_ins_obs_cuentacobro';
      vparam         VARCHAR2(2000)
         := 'parametros pobservacion = ' || pobservacion || ' psseguro=' || psseguro || ' pnrecibo='
            || pnrecibo;
      vpasexec       NUMBER(5) := 1;
      OBSCC_ID NUMBER;
      vobsvacia VARCHAR2(200):='';
      vsseguro NUMBER := 0;
      
   BEGIN
     
    -- INI IAXIS-4136 JRVG  05/05/2020
      SELECT R.SSEGURO
        INTO vsseguro
        FROM RECIBOS R 
       WHERE R.NRECIBO = pnrecibo;
     -- FIN IAXIS-4136 JRVG  05/05/2020

      IF (vobservacion IS NOT NULL) THEN   

        BEGIN
            SELECT COBSERVACION INTO OBSCC_ID FROM OBS_CUENTACOBRO where SSEGURO = vsseguro and NRECIBO = pnrecibo;
            UPDATE OBS_CUENTACOBRO set OBSERVACION = pobservacion , CMARCA= pmarca where COBSERVACION = OBSCC_ID;
            commit;

        EXCEPTION WHEN NO_DATA_FOUND THEN  
            INSERT INTO OBS_CUENTACOBRO
                        (COBSERVACION, SSEGURO, NRECIBO, OBSERVACION, CMARCA)
                 VALUES (obs_cuentacobro_seq.nextval, vsseguro, pnrecibo, pobservacion, pmarca);
            COMMIT;
        END;    

         ELSE 
             BEGIN
                SELECT COBSERVACION INTO OBSCC_ID FROM OBS_CUENTACOBRO where SSEGURO = vsseguro and NRECIBO = pnrecibo;
                UPDATE OBS_CUENTACOBRO set OBSERVACION = vobsvacia, CMARCA= vmarca where COBSERVACION = OBSCC_ID;
                commit;

            EXCEPTION WHEN NO_DATA_FOUND THEN  
                INSERT INTO OBS_CUENTACOBRO
                            (COBSERVACION, SSEGURO, NRECIBO, OBSERVACION, CMARCA)
                     VALUES (obs_cuentacobro_seq.nextval, vsseguro, pnrecibo, vobsvacia, vmarca);
                COMMIT;
            END; 

      END IF;
      RETURN 0;

   END f_ins_obs_cuentacobro;
 -- FIN IAXIS-4136 JRVG  23/04/2020
 -- FIN Tarea 4136 Kaio

  -- INI IAXIS-10514 JRVG 02/04/2020
  PROCEDURE SET_OBS_CONSORCIO(PI_SPERSON IN NUMBER) IS
    DES_CONSORCIO PER_DETPER.TSIGLAS%TYPE;
    PERSONA_CONS     NUMBER;
    V_COUNT          NUMBER := 0;
    P_PASEXEC  NUMBER(8) := 0;
  -- INI IAXIS-4136 JRVG  23/04/2020
    CURSOR C_OBSERVACIONES IS
     SELECT DISTINCT
            TOMA.SPERSON,
            SEGU.SSEGURO,
            RC.NRECIBO,
            OBS.OBSERVACION,
            SEGU.CAGENTE
       FROM SEGUROS SEGU
       JOIN TOMADORES TOMA
         ON TOMA.SSEGURO = SEGU.SSEGURO
       JOIN RECIBOS RC
         ON RC.SSEGURO = SEGU.SSEGURO
       JOIN MOVRECIBO MV
         ON MV.NRECIBO = RC.NRECIBO
        AND MV.SMOVREC = (SELECT MAX(MR.SMOVREC)
                            FROM MOVRECIBO MR
                           WHERE MR.NRECIBO = MV.NRECIBO)
       JOIN DETRECIBOS SDR
         ON SDR.NRECIBO = RC.NRECIBO
       JOIN VDETRECIBOS DETRC
         ON DETRC.NRECIBO = RC.NRECIBO
       JOIN VDETRECIBOS_MONPOL DETRCMON
         ON DETRCMON.NRECIBO = RC.NRECIBO
       LEFT JOIN AGENTES AG
         ON AG.CAGENTE = SEGU.CAGENTE
       LEFT JOIN RANGO_DIAN_MOVSEGURO DIAN
         ON DIAN.SSEGURO = RC.SSEGURO
       LEFT JOIN OBS_CUENTACOBRO OBS
         ON RC.SSEGURO = OBS.SSEGURO
        AND RC.NRECIBO = OBS.NRECIBO
      WHERE (TOMA.SPERSON = PI_SPERSON OR TOMA.SPERSON IN (SELECT SPERSON FROM PER_PERSONAS_REL WHERE SPERSON_REL = PI_SPERSON))
        AND MV.SMOVREC = (SELECT MAX(MV2.SMOVREC) FROM MOVRECIBO MV2 WHERE MV2.NRECIBO = MV.NRECIBO)
        AND MV.CESTREC = 0
        AND SDR.NRECIBO = DETRC.NRECIBO
        AND SDR.NRECIBO = DETRCMON.NRECIBO
        AND SDR.CCONCEP = 0
        AND RC.CTIPREC <> 9;

  BEGIN

   FOR OBS IN C_OBSERVACIONES LOOP
     
    SELECT COUNT(*)
      INTO V_COUNT
      FROM OBS_CUENTACOBRO OB
     WHERE OB.SSEGURO = OBS.SSEGURO
       AND OB.NRECIBO = OBS.NRECIBO;
       
    SELECT COUNT(*)
      INTO PERSONA_CONS
      FROM PER_PERSONAS_REL
     WHERE SPERSON = OBS.SPERSON;
     P_PASEXEC := 1;
     
     IF V_COUNT = 0 THEN
       INSERT INTO OBS_CUENTACOBRO (COBSERVACION, SSEGURO, NRECIBO, OBSERVACION,CAGENTE,CMARCA)
            VALUES (NVL((SELECT MAX(COBSERVACION)+1 FROM OBS_CUENTACOBRO ),1), OBS.SSEGURO, OBS.NRECIBO,NULL,OBS.CAGENTE,0);
       COMMIT;
     END IF;

     IF PERSONA_CONS >= 1 THEN

        SELECT P.Tapelli1
          INTO DES_CONSORCIO
          FROM PER_DETPER P
         WHERE P.SPERSON = OBS.SPERSON ;

       UPDATE OBS_CUENTACOBRO 
          SET OBSERVACION = DES_CONSORCIO, 
              CMARCA = 0 -- Actualiza flag 
        WHERE SSEGURO = OBS.SSEGURO
          AND NRECIBO = OBS.NRECIBO ;   
       COMMIT;

      ELSE 

      UPDATE OBS_CUENTACOBRO 
          SET OBSERVACION = ''
        WHERE SSEGURO = OBS.SSEGURO
          AND NRECIBO = OBS.NRECIBO ;
        COMMIT;

      END IF;

   END LOOP;
-- FIN IAXIS-4136 JRVG  23/04/2020
  EXCEPTION
    WHEN OTHERS THEN
      P_TAB_ERROR(F_SYSDATE,
                  F_USER,
                  'SET_OBS_CONSORCIO' || '-' || PI_SPERSON,
                  P_PASEXEC,
                  SQLCODE,
                  SQLERRM);

  END SET_OBS_CONSORCIO;
  --FIN IAXIS-10514 JRVG 02/04/2020
  
END pac_informes;

/

  GRANT EXECUTE ON "AXIS"."PAC_INFORMES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_INFORMES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_INFORMES" TO "PROGRAMADORESCSI";
