--------------------------------------------------------
--  DDL for Package Body PAC_AUTOLIQUIDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_AUTOLIQUIDA" AS

   /******************************************************************************
      NOMBRE:      PAC_AUTOLIQUIDA
      PROPÓSITO:   Nuevo paquete de la capa lógica que tendrá las funciones para
                   la liquidación de comisiones automáticas.

   --   REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        17/03/2015   JRB               1. Creación del package.

      ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /**/
   /* Bug 0029334 - JMF - 11/12/2013*/
   /* Genera desglose de una linea de liquidacion comisión directa, de algunos conceptos*/
   /**/
   /* Bug 0030978 - JMF - 28/04/2014*/


	FUNCTION f_get_autoliquidaciones(
			psproliq	IN	NUMBER,
			pcempres	IN	NUMBER,
			pfliquida	IN	DATE,
			piimporte	IN	NUMBER,
			pcagente	IN	NUMBER,
			pcusuario	IN	VARCHAR2,
			pcestado	IN	NUMBER,
			pfcobro	IN	DATE,
			psquery	OUT	VARCHAR2
	) RETURN NUMBER
	IS
	  v_pasexec NUMBER(4):=1;
	  v_object  VARCHAR2(500):='PAC_AUTOLIQUIDA.f_get_autoliquidaciones';
	  v_param   VARCHAR2(500):='psproliq='
	                         || psproliq
	                         || ' pcempres='
	                         || pcempres
	                         || ' pfliquida='
	                         || pfliquida
	                         || ' piimporte='
	                         || piimporte
	                         || ' pcagente='
	                         || pcagente
	                         || ' pcusuario='
	                         || pcusuario
	                         || ' pcestado='
	                         || pcestado
	                         || ' pfcobro='
	                         || pfcobro;
	  v_numerr  NUMBER;
	BEGIN
	    psquery:='SELECT ff_desagente(lc.cageclave) mediador , lc.cageclave cagente, lc.cempres cempres, lc.fliquid fliquid, lc.iimporte iimporte,
		       lc.cestautoliq cestautoliq,
		       lc.fcobro fcobro, lc.cusuari cusuari,
		       (select count(1) from liquidalin l, liquidacab lcc where l.nliqmen = lcc.nliqmen and lcc.sproliq = lc.sproliq and lcc.cagente = lc.cageclave and lcc.cempres = lc.cempres) recibos,
		       ff_desvalorfijo(32001,pac_md_common.f_get_cxtidioma,lc.cestautoliq) tcestautoliq,
		       lc.sproliq sproliq'
	             || ' FROM liquidaage lc'
	             || ' WHERE exists (select 1 from liquidacobros l where l.sproliq = lc.sproliq and l.cagente = lc.cagente
		         AND l.cempres = lc.cempres)';

	    IF psproliq IS NOT NULL THEN
	      psquery:=psquery
	               || ' and lc.sproliq = '
	               || psproliq;
	    END IF;

	    IF pcempres IS NOT NULL THEN
	      psquery:=psquery
	               || ' AND lc.cempres = '
	               || pcempres;
	    END IF;

	    IF pfliquida IS NOT NULL THEN
	      /*  psquery := psquery || ' AND lc.fliquid = ' || pfliquida;*/
	      psquery:=psquery
	               || ' AND lc.fliquid = '''
	               || pfliquida
	               || '''';
	    END IF;

	    IF piimporte IS NOT NULL THEN
	      psquery:=psquery
	               || ' and lc.iimporte = '
	               || piimporte;
	    END IF;

	    IF pcagente IS NOT NULL THEN
	      psquery:=psquery
	               || ' and lc.cagente = '
	               || pcagente;
	    END IF;

	    IF pcusuario IS NOT NULL THEN
	      /*psquery := psquery || ' and lc.cusuari = ' || pcusuario;*/
	      psquery:=psquery
	               || ' and upper(lc.cusuari) = '
	               || ''''
	               || upper(pcusuario)
	               || '''';
	    END IF;

	    IF pcestado IS NOT NULL THEN
	      psquery:=psquery
	               || ' and lc.cestautoliq = '
	               || pcestado;
	    END IF;

	    IF pfcobro IS NOT NULL THEN
	      /*  psquery := psquery || ' and lc.fcobro = ' || pfcobro;*/
	      psquery:=psquery
	               || ' AND lc.fcobro = '''
	               || pfcobro
	               || '''';
	    END IF;

	    psquery:=psquery
	             || ' group by lc.cageclave, lc.cempres, lc.fliquid, lc.iimporte, lc.cestautoliq, lc.fcobro, lc.cusuari, lc.sproliq';

	    psquery:=psquery
	             || ' order by lc.fliquid desc';

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);

	             RETURN 9001936;
	END f_get_autoliquidaciones;
	FUNCTION f_get_autoliquidacion(
			psproliq	IN	NUMBER,
			pcempres	IN	NUMBER,
			pcagente	IN	NUMBER,
			psqrycab	OUT	VARCHAR2,
			psqrycob	OUT	VARCHAR2,
			psqryrec	OUT	VARCHAR2,
			psqryapun	OUT	VARCHAR2
	) RETURN NUMBER
	IS
	  v_pasexec NUMBER(4):=1;
	  v_object  VARCHAR2(500):='PAC_AUTOLIQUIDA.f_get_autoliquidacion';
	  v_param   VARCHAR2(500):='psproliq='
	                         || psproliq
	                         || ' pcempres='
	                         || pcempres
	                         || ' pcagente='
	                         || pcagente;
	  v_numerr  NUMBER;
	BEGIN
	    v_numerr:=f_get_autoliquidacab(psproliq, pcempres, pcagente, psqrycab);

	    IF v_numerr<>0 THEN
	      RETURN v_numerr;
	    END IF;

	    v_pasexec:=2;

	    v_numerr:=f_get_cobros(psproliq, pcempres, pcagente, psqrycob);

	    IF v_numerr<>0 THEN
	      RETURN v_numerr;
	    END IF;

	    v_pasexec:=3;

	    v_numerr:=f_get_recibos(psproliq, pcempres, pcagente, psqryrec);

	    IF v_numerr<>0 THEN
	      RETURN v_numerr;
	    END IF;

	    v_pasexec:=4;

	    v_numerr:=f_get_ctas(psproliq, pcempres, pcagente, psqryapun);

	    IF v_numerr<>0 THEN
	      RETURN v_numerr;
	    END IF;

	    v_pasexec:=5;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);

	             RETURN 9001936;
	END f_get_autoliquidacion;
	FUNCTION f_get_autoliquidacab(
			psproliq	IN	NUMBER,
			pcempres	IN	NUMBER,
			pcagente	IN	NUMBER,
			psqrycab	OUT	VARCHAR2
	) RETURN NUMBER
	IS
	  v_pasexec NUMBER(4):=1;
	  v_object  VARCHAR2(500):='PAC_AUTOLIQUIDA.f_get_autoliquidacab';
	  v_param   VARCHAR2(500):='psproliq='
	                         || psproliq
	                         || ' pcempres='
	                         || pcempres
	                         || ' pcagente='
	                         || pcagente;
	  v_numerr  NUMBER;
	BEGIN
	    psqrycab:='SELECT lc.sproliq sproliq, lc.fliquid fliquid, lc.cageclave cagente, ff_desagente(lc.cageclave) mediador , lc.cusuari cusuari,
		         u.tusunom tusunom, lc.cestautoliq cestautoliq, lc.fcobro fcobro, lc.iimporte iimporte,
		         lc.iimporte - (select sum(iimporte) from liquidacobros l where l.cempres = lc.cempres and l.sproliq = lc.sproliq) diferencia,
		                 (
                SELECT Sum(i.itotalr)
                FROM   int_facturas_agentes i ,
                       liquidacab l
                WHERE  l.sproliq =lc.sproliq AND i.cagente = l.cagente
                AND    i.nliqmen =l.nliqmen
                AND    sproces =
                       (
                              SELECT max(sproces)
                              FROM   int_facturas_agentes i,
                                     liquidacab l
                              WHERE  l.sproliq =lc.sproliq
                              AND    i.cagente = l.cagente
                              AND    i.nliqmen =l.nliqmen )) - (select sum(iimporte) from liquidacobros l where l.cempres = lc.cempres and l.sproliq = lc.sproliq) idifglobal '
	              || ' FROM liquidaage lc, usuarios u'
	              || ' WHERE exists (select 1 from liquidacobros l2 where l2.sproliq = lc.sproliq  and lc.cusuari = u.cusuari'
	              || ' AND l2.cempres = lc.cempres)';

	    IF psproliq IS NOT NULL THEN
	      psqrycab:=psqrycab
	                || ' and lc.sproliq = '
	                || psproliq;
	    END IF;

	    IF pcempres IS NOT NULL THEN
	      psqrycab:=psqrycab
	                || ' AND lc.cempres = '
	                || pcempres;
	    END IF;

	    /*IF pcagente IS NOT NULL THEN
	       psqrycab := psqrycab || ' and lc.cageclave = ' || pcagente;
	    END IF;*/

	    psqrycab:=psqrycab
	              || ' and rownum = 1 order by 1';

	    /*p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, psqrycab);*/

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);

	             RETURN 9001936;
	END f_get_autoliquidacab;

	FUNCTION f_get_recibos(
			psproliq	IN	NUMBER,
			pcempres	IN	NUMBER,
			pcagente	IN	NUMBER,
			psqryrec	OUT	VARCHAR2
	) RETURN NUMBER
	IS
	  v_pasexec NUMBER(4):=1;
	  v_object  VARCHAR2(500):='PAC_AUTOLIQUIDA.f_get_recibos';
	  v_param   VARCHAR2(500):='psproliq='
	                         || psproliq
	                         || ' pcempres='
	                         || pcempres
	                         || ' pcagente='
	                         || pcagente;
	  v_numerr  NUMBER;
	BEGIN
	    /*Bug 34855-211477 KJSC 04/08/2015 Incluir en las selects recibos.cestaux=0*/
	    psqryrec:='select distinct 1 ch,r.ctiprec ctiprec, decode(r.ctiprec,9,''Extorno'',''Recibo'') ttiprec, l.nrecibo nrecibo,  ff_desvalorfijo(17,pac_md_common.f_get_cxtidioma,s.cforpag) fp, r.nfracci fra, r.fefecto fefecto, s.npoliza npoliza,
      l.itotalr itotalr,

      (select icomision from int_facturas_agentes where nrecibo = r.nrecibo AND cagente = lc.cagente  AND sproces = lc.sproliq) comision,

      CASE WHEN nvl((select icomision from int_facturas_agentes where nrecibo = r.nrecibo AND cagente = lc.cagente  AND sproces = lc.sproliq),l.icomisi)  <> l.icomisi THEN
       NVL(((SELECT SUM(ICONCEP) FROM DETRECIBOS WHERE CCONCEP IN(32,82) AND nrecibo =r.nrecibo )- nvl((SELECT SUM(ICONCEP)  FROM DETRECIBOS WHERE CCONCEP IN( 33,34,35, 83,84,85) AND nrecibo =r.nrecibo ), 0)),0) *(nvl((select icomision from int_facturas_agentes where nrecibo = r.nrecibo AND cagente = lc.cagente  AND sproces = lc.sproliq ),l.icomisi)/l.icomisi)
      ELSE
        NVL(((SELECT SUM(ICONCEP) FROM DETRECIBOS WHERE CCONCEP IN(32,82) AND nrecibo =r.nrecibo )- NVL((SELECT SUM(ICONCEP)  FROM DETRECIBOS WHERE CCONCEP IN( 33,34,35, 83,84,85) AND nrecibo =r.nrecibo ),0)),0) *(nvl((select itotalr from int_facturas_agentes where nrecibo = r.nrecibo AND cagente = lc.cagente  AND sproces = lc.sproliq),itotalr)/itotalr)
      END irpf,

      CASE WHEN nvl((select icomision from int_facturas_agentes where nrecibo = r.nrecibo AND cagente = lc.cagente  AND sproces = lc.sproliq),l.icomisi)  <> l.icomisi THEN
       (nvl((select dee.itotalr from int_facturas_agentes dee where dee.nrecibo = r.nrecibo AND dee.cagente = lc.cagente  AND dee.sproces = lc.sproliq),itotalr) -  (select dee1.icomision from int_facturas_agentes dee1 where dee1.nrecibo = r.nrecibo AND dee1.cagente = lc.cagente  AND dee1.sproces = lc.sproliq)  -  (NVL(((SELECT SUM(ICONCEP) FROM DETRECIBOS WHERE CCONCEP IN(32,82) AND nrecibo =r.nrecibo )- nvl((SELECT SUM(ICONCEP)  FROM DETRECIBOS WHERE CCONCEP IN( 33,34,35, 83,84,85) AND nrecibo =r.nrecibo ), 0)),0) *(nvl((select icomision from int_facturas_agentes where nrecibo = r.nrecibo AND cagente = lc.cagente  AND sproces = lc.sproliq ),l.icomisi)/l.icomisi)))
    ELSE
      (nvl((select dee.itotalr from int_facturas_agentes dee where dee.nrecibo = r.nrecibo AND dee.cagente = lc.cagente  AND dee.sproces = lc.sproliq),itotalr) -  (select dee1.icomision from int_facturas_agentes dee1 where dee1.nrecibo = r.nrecibo AND dee1.cagente = lc.cagente  AND dee1.sproces = lc.sproliq)  -  (NVL(((SELECT SUM(ICONCEP) FROM DETRECIBOS WHERE CCONCEP IN(32,82) AND nrecibo =r.nrecibo )- NVL((SELECT SUM(ICONCEP)  FROM DETRECIBOS WHERE CCONCEP IN( 33,34,35, 83,84,85) AND nrecibo =r.nrecibo ),0)),0) *(nvl((select itotalr from int_facturas_agentes where nrecibo = r.nrecibo AND cagente = lc.cagente  AND sproces = lc.sproliq),itotalr)/itotalr)))
    END  liquido,

    nvl(l.com_inc,0) pl,

     nvl((select itotalr from int_facturas_agentes where nrecibo = r.nrecibo AND cagente = lc.cagente  AND sproces = lc.sproliq),0) - l.itotalr dif, nvl(l.idiferpyg,0) difpyg, r.cagente cagente, ff_desagente(r.cagente) mediador,
      nvl((select itotalr from int_facturas_agentes where nrecibo = r.nrecibo AND cagente = lc.cagente  AND sproces = lc.sproliq),0) itotcarg,'


      --AAC_INI-CONF_379-20160927

      ||'l.imppend imppend, l.vabono vabono, l.fabono fabono,l.docrecau docrecau,l.corteprod corteprod, l.vpagout vpagout,'
      --AAC_FI-CONF_379-20160927
	              || pcagente
	              || ' cageliq, l.nliqlin nliqlin
		from liquidalin l, liquidacab lc, recibos r, seguros s
		where l.nliqmen = lc.nliqmen and l.cagente = lc.cagente and l.cempres = lc.cempres
		and l.nrecibo = r.nrecibo and r.sseguro = s.sseguro and r.cestaux = 0';

	    /*and exists (select 1 from liquidaage l2 where l2.nliqmen = lc.nliqmen and l2.cagente = lc.cagente AND l2.cempres = lc.cempres and l2.sproliq = lc.sproliq)';*/

	    psqryrec:=psqryrec
	              || ' and lc.sproliq = '
	              || psproliq;

	    psqryrec:=psqryrec
	              || ' AND lc.cempres = '
	              || pcempres;

	    /* psqryrec := psqryrec ||
	    ' and lc.cagente in (select cagente from liquidaage where sproliq = lc.sproliq and cempres = lc.cempres and cageclave = ' ||
	    pcagente || ')';

	    psqryrec:=psqryrec
	              || '
		union all
		select distinct 0 ch,r.ctiprec ctiprec, decode(r.ctiprec,9,''Extorno'',''Recibo'') ttiprec, r.nrecibo nrecibo,  ff_desvalorfijo(17,pac_md_common.f_get_cxtidioma,s.cforpag) fp, r.nfracci fra, r.fefecto fefecto, s.npoliza npoliza,
		decode(r.ctiprec,9,-1,1)*v.itotalr itotalr, decode(r.ctiprec,9,-1,1)*v.icombru comision, NVL(((SELECT SUM(ICONCEP) FROM DETRECIBOS WHERE CCONCEP IN(32,82) AND nrecibo =r.nrecibo )- (SELECT SUM(ICONCEP)  FROM DETRECIBOS WHERE CCONCEP IN( 33,34,35, 83,84,85) AND nrecibo =r.nrecibo )),0) irpf, ((decode(r.ctiprec,9,-1,1)*v.itotalr)-(decode(r.ctiprec,9,-1,1)*v.icombru)+(decode(r.ctiprec,9,-1,1)*NVL(((SELECT SUM(ICONCEP) FROM DETRECIBOS WHERE CCONCEP IN(32,82) AND nrecibo =r.nrecibo )- (SELECT SUM(ICONCEP)  FROM DETRECIBOS WHERE CCONCEP IN( 33,34,35, 83,84,85) AND nrecibo =r.nrecibo )),0))) liquido, 1 pl, 0 dif, 0 difpyg, r.cagente agente, ff_desagente(r.cagente) mediador,'
    --AAC_INI-CONF_379-20160927
    ||'null imppend, null vabono, null fabono,null docrecau, null corteprod, null vpagout,'
    --AAC_FI-CONF_379-20160927
	              || pcagente
	              || ' cageliq, null
		from recibos r, seguros s, vdetrecibos v, movrecibo m, liquidaage la, liquidacab lc
		where r.sseguro = s.sseguro and v.nrecibo = r.nrecibo and m.nrecibo = r.nrecibo and m.fmovfin is null and m.cestrec = 0 and r.cestaux = 0 AND r.ctipcob <> 2
		 	 and lc.sproliq = '
	              || psproliq
	              || '
		   and lc.cestautoliq = 1 and s.cempres = '
	              || pcempres;

	    /*and not exists (select 1 from liquidacab lc where lc.sproliq = ' ||
	    psproliq || ' and lc.cestautoliq <> 1)

	    psqryrec:=psqryrec
	              || 'and r.cagente = la.cagente and la.cageclave = '
	              || pcagente
	              || ' and la.sproliq = '
	              || psproliq
	              || ' and la.cempres = s.cempres';

	    /*IF (nvl(pac_parametros.f_parempresa_n(pcempres,
	                                          'LIQUIDA_AGECLAVE'),
	            0) = 1) THEN
	       psqryrec := psqryrec || 'and r.cagente = la.cagente and la.cageclave = ' ||
	                   pcagente || ' and sproliq = ' || psproliq ||
	                   ' and cempres = s.cempres';
	       /* psqryrec := psqryrec || ' and (s.cagente = ' || pcagente ||
	       ' OR s.cagente in (select cagente from agentes_comp where cageclave = ' ||
	       pcagente || '))';
	    ELSE
	       psqryrec := psqryrec ||
	                   ' and (s.cagente in (select cagente from liquidaage where cageclave = ' ||
	                   pcagente || ' and sproliq = ' || psproliq ||
	                   ' and cempres = s.cempres))';
	    END IF;

	    psqryrec:=psqryrec
	              || '
		and r.nrecibo not in (select distinct(nrecibo) from liquidalin l3 where ctipoliq = 1 and nliqmen in (select nliqmen from liquidacab where cestautoliq <> 3 AND sproliq = '
	              || psproliq
	              || ')  AND l3.cempres = '
	              || pcempres;

	    /*and r.nrecibo not in (select distinct(nrecibo) from liquidalin l2 where ';

	    psqryrec := psqryrec ||
	                ' l2.nliqmen in (select nliqmen from liquidacab where sproliq = ' ||
	                psproliq || ')';

	    psqryrec := psqryrec || ' AND l2.cempres = ' || pcempres;

	    psqryrec:=psqryrec
	              || ') order by cagente, nrecibo';

	    /*-pendiente de mirar: Contemplar la casuística de un impagado (en estado actual no domiciliado)  no liquidado, que también ha de ser mostrado. Siempre sobre el máximo movimiento del recibo.*/
	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);

	             RETURN 9001936;
	END f_get_recibos;
	FUNCTION f_get_new_recibos(
			psproliq	IN	NUMBER,
			pcempres	IN	NUMBER,
			pcagente	IN	NUMBER,
			pctomador	IN	NUMBER,
			pnrecibo	IN	NUMBER,
			psqryrec	OUT	VARCHAR2
	) RETURN NUMBER
	IS
	  v_pasexec NUMBER(4):=1;
	  v_object  VARCHAR2(500):='PAC_AUTOLIQUIDA.f_get_new_recibos';
	  v_param   VARCHAR2(500):='psproliq='
	                         || psproliq
	                         || ' pcempres='
	                         || pcempres
	                         || ' pcagente='
	                         || pcagente
	                         || ' pctomador='
	                         || pctomador
	                         || ' pnrecibo='
	                         || pnrecibo;
	  v_numerr  NUMBER;
	  vnrecibo  VARCHAR2(100);
	BEGIN
	    IF pnrecibo IS NULL THEN
	      vnrecibo:='NULL';
	    ELSE
	      vnrecibo:=pnrecibo;
	    END IF;

	    /*Bug 34855-211477 KJSC 04/08/2015 Incluir en las selects recibos.cestaux=0*/
	    /* psqryrec := 'select distinct decode(nvl(' || vnrecibo || ',0),r.nrecibo,1,0) ch,r.ctiprec ctiprec, decode(r.ctiprec,9,''Extorno'',''Recibo'') ttiprec, r.nrecibo nrecibo,  ff_desvalorfijo(17,pac_md_common.f_get_cxtidioma,s.cforpag) fp, r.nfracci fra, r.fefecto fefecto, s.npoliza npoliza,
	    decode(r.ctiprec,9,-1,1)*v.itotalr itotalr, decode(r.ctiprec,9,-1,1)*v.icombru comision, decode(r.ctiprec,9,-1,1)*v.icomret irpf, ((decode(r.ctiprec,9,-1,1)*v.itotalr)-(decode(r.ctiprec,9,-1,1)*v.icombru)+(decode(r.ctiprec,9,-1,1)*v.icomret)) liquido, 1 pl,
	    0 dif,
	    0 difpyg, s.cagente cagente, ff_desagente(s.cagente) mediador,
	    null cageliq, null nliqlin
	    from recibos r, seguros s, vdetrecibos v, movrecibo m, tomadores t
	    where r.sseguro = s.sseguro and v.nrecibo = r.nrecibo and m.nrecibo = r.nrecibo and m.fmovfin is null and m.cestrec = 0 and t.sseguro = s.sseguro AND r.ctipcob <> 2 and r.cestaux = 0
	    and r.nrecibo not in (select distinct(nrecibo) from liquidalin l3 where ctipoliq = 1 and nliqmen in (select nliqmen from liquidacab where cestautoliq <> 3))
	    and ';

	          psqryrec := psqryrec || ' s.cempres = ' || pcempres;

	          IF pcagente IS NOT NULL AND psproliq IS NOT NULL THEN
	             IF (nvl(pac_parametros.f_parempresa_n(pcempres,
	                                                   'LIQUIDA_AGECLAVE'),
	                     0) = 1) THEN
	                psqryrec := psqryrec || ' AND (s.cagente = ' || pcagente;

	                psqryrec := psqryrec ||
	                            ' OR s.cagente in (select cagente from agentes_comp where cageclave = ' ||
	                            pcagente || '))';
	             ELSE
	                psqryrec := psqryrec ||
	                            ' and s.cagente in (select cagente from liquidaage where sproliq = ' ||
	                            psproliq || ' and cempres = s.cempres and cageclave = ' ||
	                            pcagente || ')';
	             END IF;
	             /*psqryrec := psqryrec || ' AND (s.cagente = ' || pcagente;*/
	    /*  psqryrec :=
	          psqryrec
	          || ' OR s.cagente in (select cagente from agentes_comp where cageclave = '
	          || pcagente || '))';
	       ELSIF pcagente IS NOT NULL THEN
	          psqryrec := psqryrec || ' and s.cagente = ' || pcagente;
	       END IF;

	       IF pctomador IS NOT NULL THEN
	          psqryrec := psqryrec || ' and t.sperson = ' || pctomador;
	       END IF;
	       --psqryrec := psqryrec || ' and l.cagente=r.cagente ';
	       psqryrec := psqryrec || ' order by cagente,nrecibo';
	    */
	    psqryrec:='select distinct 1 ch,r.ctiprec ctiprec, decode(r.ctiprec,9,''Extorno'',''Recibo'') ttiprec, l.nrecibo nrecibo,  ff_desvalorfijo(17,pac_md_common.f_get_cxtidioma,s.cforpag) fp
      , r.nfracci fra, r.fefecto fefecto, s.npoliza npoliza,
		l.itotalr itotalr, l.icomisi comision, l.iretenccom irpf, (l.itotalr-l.icomisi+l.iretenccom) liquido, nvl(l.com_inc,0) pl, nvl(l.idiferencia,0) dif, nvl(l.idiferpyg,0) difpyg, r.cagente cagente
    , ff_desagente(r.cagente) mediador,
    ';

      /*LINEA dva INICIO*/
      IF nvl (pcagente,0) > 0 and nvl(psproliq,0) > 0 THEN
	      psqryrec := psqryrec
               || pcagente ;
             p_control_error('dva','f_l','parámetros - pcagente: ' || pcagente);
	    ELSE
	      psqryrec := psqryrec
	              || ' s.cagente ';
                 p_control_error('dva','f_l_else','parámetros - s.cagente: ');
	    END IF;
      /*LINEA dva FIN*/

    -- || pcagente ||

   psqryrec:=psqryrec
	              || '
     cageliq, l.nliqlin nliqlin


		from liquidalin l, liquidacab lc, recibos r, seguros s,TOMADORES T
		where l.nliqmen = lc.nliqmen and l.cagente = lc.cagente and l.cempres = lc.cempres
		and l.nrecibo = r.nrecibo and r.sseguro = s.sseguro and r.cestaux = 0 AND S.SSEGURO=T.SSEGURO ';

	    /*and exists (select 1 from liquidaage l2 where l2.nliqmen = lc.nliqmen and l2.cagente = lc.cagente AND l2.cempres = lc.cempres and l2.sproliq = lc.sproliq)';*/

	  --  psqryrec:=psqryrec
	  --            || ' and lc.sproliq = '
	  --            || psproliq;

	  --  psqryrec:=psqryrec
	  --            || ' AND lc.cempres = '
	  --            || pcempres;

     IF nvl (pcagente,0) > 0 and nvl(psproliq,0) > 0 THEN
	       psqryrec := psqryrec
                || ' and lc.sproliq = ' || psproliq
                || ' AND lc.cempres = ' || pcempres;
    else
        psqryrec := psqryrec
                 || ' and T.SPERSON = '
	              || pctomador
				 || ' AND lc.cempres = ' || pcempres;

    end if;

	    /* psqryrec := psqryrec ||
	    ' and lc.cagente in (select cagente from liquidaage where sproliq = lc.sproliq and cempres = lc.cempres and cageclave = ' ||
	    pcagente || ')';*/

	    psqryrec:=psqryrec
	              || '
		union all
		select distinct 0 ch,r.ctiprec ctiprec, decode(r.ctiprec,9,''Extorno'',''Recibo'') ttiprec, r.nrecibo nrecibo,  ff_desvalorfijo(17,pac_md_common.f_get_cxtidioma,s.cforpag) fp, r.nfracci fra, r.fefecto fefecto, s.npoliza npoliza,
		decode(r.ctiprec,9,-1,1)*v.itotalr itotalr, decode(r.ctiprec,9,-1,1)*v.icombru comision, decode(r.ctiprec,9,-1,1)*v.icomret irpf
    , ((decode(r.ctiprec,9,-1,1)*v.itotalr)-(decode(r.ctiprec,9,-1,1)*v.icombru)+(decode(r.ctiprec,9,-1,1)*v.icomret)) liquido, 1 pl, 0 dif, 0 difpyg, s.cagente agente
    , ff_desagente(s.cagente) mediador ,
    ';

      /*LINEA dva INICIO*/
      IF nvl (pcagente,0) > 0 and nvl(psproliq,0) > 0 THEN
	      psqryrec := psqryrec
               || pcagente || ' cageliq ';
	    ELSE
	      psqryrec := psqryrec
	              || ' s.cagente  cageliq ';
	    END IF;
      /*LINEA dva FIN*/

    -- ' || pcagente || ' cageliq

       psqryrec:=psqryrec
	              || '
      , null
		from recibos r, seguros s, vdetrecibos v, movrecibo m, liquidaage la, liquidacab lc,TOMADORES T
		where r.sseguro = s.sseguro and v.nrecibo = r.nrecibo and m.nrecibo = r.nrecibo and m.fmovfin is null and m.cestrec = 0 and r.cestaux = 0 AND r.ctipcob <> 2 AND S.SSEGURO=T.SSEGURO
		 	';

     	/*LINEA dva INICIO*/
       IF nvl (pcagente,0) > 0 and nvl(psproliq,0) > 0 THEN
	       psqryrec := psqryrec
                || ' and lc.sproliq = ' || psproliq ||
                ' and lc.cestautoliq = 1 and s.cempres = '
	              || pcempres;
	    ELSE
	       psqryrec := psqryrec
	               || ' and lc.cestautoliq = 1 and s.cempres = '
	              || pcempres;
	    END IF;
      /*LINEA dva FIN*/


     --  and lc.sproliq = '
	  --            || psproliq
	   --           || '
		 --  and lc.cestautoliq = 1 and s.cempres = '
	   --           || pcempres;

	    /*and not exists (select 1 from liquidacab lc where lc.sproliq = ' ||
	    psproliq || ' and lc.cestautoliq <> 1) */

		psqryrec:=psqryrec
	              || 'and r.cagente = la.cagente (+)';

  /*LINEA dva INICIO*/
       IF nvl (pcagente,0) > 0 and nvl(psproliq,0) > 0 THEN
	       psqryrec := psqryrec
                || ' and la.cageclave = '
	              || pcagente
                || ' and la.sproliq = '
	              || psproliq
	              || ' and la.cempres = s.cempres';
	    ELSE
	       psqryrec := psqryrec
	               || ' and T.SPERSON = '
	              || pctomador || ' and la.cempres = s.cempres';
	    END IF;
      /*LINEA dva FIN*/



	 --  psqryrec:=psqryrec
	 --             || 'and r.cagente = la.cagente and la.cageclave = '
	 --             || pcagente
	 --             || ' and la.sproliq = '
	 --             || psproliq
	 --             || ' and la.cempres = s.cempres';

	    /*IF (nvl(pac_parametros.f_parempresa_n(pcempres,
	                                          'LIQUIDA_AGECLAVE'),
	            0) = 1) THEN
	       psqryrec := psqryrec || 'and r.cagente = la.cagente and la.cageclave = ' ||
	                   pcagente || ' and sproliq = ' || psproliq ||
	                   ' and cempres = s.cempres';
	       /* psqryrec := psqryrec || ' and (s.cagente = ' || pcagente ||
	       ' OR s.cagente in (select cagente from agentes_comp where cageclave = ' ||
	       pcagente || '))';
	    ELSE
	       psqryrec := psqryrec ||
	                   ' and (s.cagente in (select cagente from liquidaage where cageclave = ' ||
	                   pcagente || ' and sproliq = ' || psproliq ||
	                   ' and cempres = s.cempres))';
	    END IF;*/

	    psqryrec:=psqryrec
	              || '
		and r.nrecibo not in (select distinct(nrecibo) from liquidalin l3 where ctipoliq = 1 and nliqmen in (select nliqmen from liquidacab where cestautoliq <> 3
    ';

    /*LINEA dva INICIO*/
       IF nvl (pcagente,0) > 0 and nvl(psproliq,0) > 0 THEN
	       psqryrec := psqryrec
                || ' AND sproliq = '
                || psproliq ||
                ')  AND l3.cempres = '
                 || pcempres;
	    ELSE
	       psqryrec := psqryrec
	               || ') AND l3.cempres = '
                 || pcempres;
	    END IF;
    /*LINEA dva FIN*/
   -- AND sproliq = '
	  --            || psproliq
	 --             || ')  AND l3.cempres = '
	 --             || pcempres;

	    /*and r.nrecibo not in (select distinct(nrecibo) from liquidalin l2 where ';

	    psqryrec := psqryrec ||
	                ' l2.nliqmen in (select nliqmen from liquidacab where sproliq = ' ||
	                psproliq || ')';

	    psqryrec := psqryrec || ' AND l2.cempres = ' || pcempres;*/

	    psqryrec:=psqryrec
	              || ') order by cagente, nrecibo';

	    /*-pendiente de mirar: Contemplar la casuística de un impagado (en estado actual no domiciliado)  no liquidado, que también ha de ser mostrado.*/
	    /*-Siempre sobre el máximo movimiento del recibo.*/
	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);

	             RETURN 9001936;
	END f_get_new_recibos;
	FUNCTION f_get_cobros(
			psproliq	IN	NUMBER,
			pcempres	IN	NUMBER,
			pcagente	IN	NUMBER,
			psqrycob	OUT	VARCHAR2
	) RETURN NUMBER
	IS
	  v_pasexec NUMBER(4):=1;
	  v_object  VARCHAR2(500):='PAC_AUTOLIQUIDA.f_get_cobros';
	  v_param   VARCHAR2(500):='psproliq='
	                         || psproliq
	                         || ' pcempres='
	                         || pcempres
	                         || ' pcagente='
	                         || pcagente;
	  v_numerr  NUMBER;
	BEGIN
	    psqrycob:='select idcobro nliqlin, l.ccobro ccobro, l.cdocumento documento, l.cbanco banco, l.iimporte importe, l.fdocumento fdocumento, l.tobserva observaciones, l.sproliq psproliq, ff_desvalorfijo(32002,pac_md_common.f_get_cxtidioma,l.ccobro) tcobro,
		             b.ccobban ||''-''|| b.descripcion tbanco
		              from liquidacobros l, cobbancario b
		              where l.cbanco = b.ccobban(+) and ';

	    psqrycob:=psqrycob
	              || ' l.sproliq = '
	              || psproliq;

	    psqrycob:=psqrycob
	              || ' AND l.cempres = '
	              || pcempres;

	    /*psqrycob := psqrycob || ' and l.cagente = ' || pcagente;*/

	    psqrycob:=psqrycob
	              || ' order by 1';

	    /*p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, psqrycob);*/

	    /*-pendiente de mirar: Contemplar la casuística de un impagado (en estado actual no domiciliado)  no liquidado, que también ha de ser mostrado.*/
	    /*-Siempre sobre el máximo movimiento del recibo.*/
	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);

	             RETURN 9001936;
	END f_get_cobros;
	FUNCTION f_get_ctas(
			psproliq	IN	NUMBER,
			pcempres	IN	NUMBER,
			pcagente	IN	NUMBER,
			psqryapun	OUT	VARCHAR2
	) RETURN NUMBER
	IS
	  v_pasexec NUMBER(4):=1;
	  v_object  VARCHAR2(500):='PAC_AUTOLIQUIDA.f_get_ctas';
	  v_param   VARCHAR2(500):='psproliq='
	                         || psproliq
	                         || ' pcempres='
	                         || pcempres
	                         || ' pcagente='
	                         || pcagente;
	  v_numerr  NUMBER;
	BEGIN
	    IF psproliq IS NOT NULL THEN
	      /*carga cuentas pendientes de liquidar o guardar*/
	      psqryapun:='SELECT DECODE(c.sproces, NULL, 0, 1) ch, c.nnumlin nnumlin,
		       ff_desvalorfijo(693, pac_md_common.f_get_cxtidioma, c.cmanual) tipo, s.npoliza poliza,
		       NVL(c.nsinies, c.nrecibo) referen, c.fvalor fvalor, d.tcconcta concepto,
		       DECODE(c.cdebhab, 1, c.iimport) debe, DECODE(c.cdebhab, 2, c.iimport) haber,
		       c.tdescrip descripcion, lc.cagente
		  FROM ctactes c, liquidacab lc, recibos r, seguros s, desctactes d
		 WHERE c.cagente = lc.cagente
		   AND lc.cempres = c.cempres
		   AND c.sproces IS NULL
		   AND r.nrecibo (+) = c.nrecibo
		   AND s.sseguro (+) = r.sseguro
		   and not exists (select 1 from liquidacab lc where lc.sproliq = '
	                 || psproliq
	                 || ' and lc.cestautoliq <> 1)
		   AND d.cconcta = c.cconcta
		   AND d.cidioma = pac_md_common.f_get_cxtidioma
		   AND c.cestado = 1';

	      psqryapun:=psqryapun
	                 || ' and lc.sproliq = '
	                 || psproliq;

	      psqryapun:=psqryapun
	                 || ' AND lc.cempres = '
	                 || pcempres;

	      psqryapun:=psqryapun
	                 || ' and lc.cagente in (select cagente from liquidaage where sproliq = lc.sproliq and cempres = lc.cempres and cageclave = '
	                 || pcagente
	                 || ')';

	      /*carga autoliquidacion liquidada o guardada*/
	      psqryapun:=psqryapun
	                 || '
		   union all
		   SELECT 1 ch, c.nnumlin nnumlin,
		       ff_desvalorfijo(693, pac_md_common.f_get_cxtidioma, c.cmanual) tipo, s.npoliza poliza,
		       NVL(c.nsinies, c.nrecibo) referen, c.fvalor fvalor, d.tcconcta concepto,
		       DECODE(c.cdebhab, 1, c.iimport) debe, DECODE(c.cdebhab, 2, c.iimport) haber,
		       c.tdescrip descripcion, lc.cagente
		  FROM ctactes c, liquidacab lc, recibos r, seguros s, desctactes d
		 WHERE c.cagente = lc.cagente
		   AND lc.cempres = c.cempres
		   AND lc.sproliq = c.sproces
		   AND r.nrecibo (+) = c.nrecibo
		   AND s.sseguro (+) = r.sseguro
		   and exists (select 1 from liquidalin where nliqmen = lc.nliqmen)
		   AND d.cconcta = c.cconcta
		   AND d.cidioma = pac_md_common.f_get_cxtidioma';

	      psqryapun:=psqryapun
	                 || ' and lc.sproliq = '
	                 || psproliq;

	      psqryapun:=psqryapun
	                 || ' AND lc.cempres = '
	                 || pcempres;

	      psqryapun:=psqryapun
	                 || ' and lc.cagente in (select cagente from liquidaage where sproliq = lc.sproliq and cempres = lc.cempres and cageclave = '
	                 || pcagente
	                 || ')';
	    ELSE
	      /*nueva autoliquidación*/
	      psqryapun:=psqryapun
	                 || 'select 0 ch, c.nnumlin nnumlin, ff_desvalorfijo(693, pac_md_common.f_get_cxtidioma, c.cmanual) tipo, (select npoliza from seguros where sseguro = c.sseguro) npoliza,
		NVL(c.nsinies, c.nrecibo) referen, c.fvalor fvalor, d.tcconcta concepto,
		       DECODE(c.cdebhab, 1, c.iimport) debe, DECODE(c.cdebhab, 2, c.iimport) haber,
		       c.tdescrip descripcion, c.cagente
		 from ctactes c, desctactes d
		 where d.cconcta = c.cconcta
		/* and  c.sproces is null*/
		/* and (c.sproces is null or (c.sproces is not null and c.cconcta = 32))*/
		 and c.cestado = 1
		   AND d.cidioma = pac_md_common.f_get_cxtidioma';

	      /* psqryapun := psqryapun || ' and lc.nliqmen = ' || pnliqmen;*/
	      psqryapun:=psqryapun
	                 || ' AND c.cempres = '
	                 || pcempres;

	      psqryapun:=psqryapun
	                 || ' and c.cagente = '
	                 || pcagente;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);

	             RETURN 9001936;
	END f_get_ctas;
	FUNCTION f_get_new_ctas(
			psproliq	IN	NUMBER,
			pcempres	IN	NUMBER,
			pcagente	IN	NUMBER,
			psqryapun	OUT	VARCHAR2
	) RETURN NUMBER
	IS
	  v_pasexec NUMBER(4):=1;
	  v_object  VARCHAR2(500):='PAC_AUTOLIQUIDA.f_get_new_ctas';
	  v_param   VARCHAR2(500):='psproliq='
	                         || psproliq
	                         || ' pcempres='
	                         || pcempres
	                         || ' pcagente='
	                         || pcagente;
	  v_numerr  NUMBER;
	BEGIN
	    psqryapun:='select 0 ch, c.nnumlin nnumlin, ff_desvalorfijo(693, pac_md_common.f_get_cxtidioma, c.cmanual) tipo, (select npoliza from seguros where sseguro = c.sseguro) npoliza,
		NVL(c.nsinies, c.nrecibo) referen, c.fvalor fvalor, d.tcconcta concepto,
		       DECODE(c.cdebhab, 1, c.iimport) debe, DECODE(c.cdebhab, 2, c.iimport) haber,
		       c.tdescrip descripcion
		 from ctactes c, desctactes d
		 where c.sproces is null
		 AND d.cconcta = c.cconcta
		   AND d.cidioma = pac_md_common.f_get_cxtidioma';

	    /* psqryapun := psqryapun || ' and lc.nliqmen = ' || pnliqmen;*/
	    psqryapun:=psqryapun
	               || ' AND c.cempres = '
	               || pcempres;

	    psqryapun:=psqryapun
	               || ' and c.cagente in (select cagente from liquidaage where sproliq = '
	               || psproliq
	               || ' and cempres = c.cempres and cageclave = '
	               || pcagente
	               || ')';

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);

	             RETURN 9001936;
	END f_get_new_ctas;
	FUNCTION f_get_autoliquidaage(
			psproliq	IN	NUMBER,
			pcempres	IN	NUMBER,
			pcageclave	IN	NUMBER
	) RETURN T_IAX_AUTOLIQUIDAAGE
	IS
	  v_pasexec NUMBER(4):=1;
	  v_object  VARCHAR2(500):='PAC_AUTOLIQUIDA.f_get_autoliquidaage';
	  v_param   VARCHAR2(500):='psproliq='
	                         || psproliq
	                         || ' pcempres='
	                         || pcempres
	                         || ' pcageclave='
	                         || pcageclave;
	  v_numerr  NUMBER;
	  vsproliq  NUMBER;

	CURSOR c_autoliquidaage(

	    tipoliquida NUMBER) IS
	    SELECT l.cempres,l.cageclave,ac.cagente,l.sproliq,l.nliqmen,l.cestautoliq,ff_desagente(ac.cagente) tagente,l.fliquid,l.iimporte,l.cusuari,l.fcobro,decode(nvl(cempres, 0), 0, 0,
	                                                                                                                                                                               1) marcado,(SELECT idifglobal
	                                                                                                                                                                                             FROM liquidacab
	                                                                                                                                                                                            WHERE nliqmen=l.nliqmen AND
	                                                                                                                                                                                                  cagente=l.cagente AND
	                                                                                                                                                                                                  cempres=l.cempres) idifglobal
	      FROM liquidaage l,(SELECT cagente
	              FROM agentes_comp
	             WHERE cageclave=pcageclave  OR
	                   cagente=pcageclave) ac
	     WHERE l.cagente(+)=ac.cagente AND
	           tipoliquida=2
	           /*AND nvl(pac_parametros.f_parempresa_n(pcempres,
	                                         'LIQUIDA_AGECLAVE'),
	           0) = 2*/
	           AND
	           l.sproliq(+)=vsproliq

	    UNION
	    SELECT l.cempres,l.cageclave,ac.cageclave,l.sproliq,l.nliqmen,l.cestautoliq,ff_desagente(ac.cageclave) tagente,l.fliquid,l.iimporte,l.cusuari,l.fcobro,decode(nvl(cempres, 0), 0, 0,
	                                                                                                                                                                                   1) marcado,(SELECT idifglobal
	                                                                                                                                                                                                 FROM liquidacab
	                                                                                                                                                                                                WHERE nliqmen=l.nliqmen AND
	                                                                                                                                                                                                      cagente=l.cagente AND
	                                                                                                                                                                                                      cempres=l.cempres) idifglobal
	      FROM liquidaage l,(SELECT min(cageclave) cageclave
	              FROM agentes_comp
	             WHERE cageclave=pcageclave) ac
	     WHERE l.cagente(+)=ac.cageclave AND
	           tipoliquida=1
	           /*AND nvl(pac_parametros.f_parempresa_n(pcempres,
	                                         'LIQUIDA_AGECLAVE'),
	           0) = 1*/
	           AND
	           l.sproliq(+)=vsproliq
	    UNION
	    SELECT l.cempres,l.cageclave,ac.cagente,l.sproliq,l.nliqmen,l.cestautoliq,ff_desagente(ac.cagente) tagente,l.fliquid,l.iimporte,l.cusuari,l.fcobro,decode(nvl(cempres, 0), 0, 0,
	                                                                                                                                                                               1) marcado,(SELECT idifglobal
	                                                                                                                                                                                             FROM liquidacab
	                                                                                                                                                                                            WHERE nliqmen=l.nliqmen AND
	                                                                                                                                                                                                  cagente=l.cagente AND
	                                                                                                                                                                                                  cempres=l.cempres) idifglobal
	      FROM liquidaage l,(SELECT min(cagente) cagente
	              FROM agentes_comp
	             WHERE cagente=pcageclave AND
	                   cageclave IS NULL) ac
	     WHERE l.cagente(+)=ac.cagente AND
	           l.sproliq(+)=vsproliq AND
	           tipoliquida=0;

	  autol     T_IAX_AUTOLIQUIDAAGE:=t_iax_autoliquidaage();
	BEGIN
	    IF psproliq=0 THEN
	      vsproliq:=NULL;
	    ELSE
	      vsproliq:=psproliq;
	    END IF;

	    FOR i IN c_autoliquidaage(nvl(pac_parametros.f_parempresa_n(pcempres, 'LIQUIDA_AGECLAVE'), 0)) LOOP
	        autol.extend;

	        autol(autol.last):=ob_iax_autoliquidaage();

	        autol(autol.last).cempres:=pcempres;

	        autol(autol.last).cageclave:=pcageclave;

	        autol(autol.last).cagente:=i.cagente;

	        /*p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, 'vsproliq '
	                                                                     || vsproliq);*/

	        autol(autol.last).sproliq:=vsproliq;

	       /* p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, 'nliqmen '
	                                                                     || i.nliqmen);*/

	        autol(autol.last).nliqmen:=i.nliqmen;

	        autol(autol.last).cestautoliq:=i.cestautoliq;

	        autol(autol.last).fliquida:=i.fliquid;

	        autol(autol.last).iimporte:=i.iimporte;

	        autol(autol.last).cusuari:=i.cusuari;

	        autol(autol.last).fcobro:=i.fcobro;

	        autol(autol.last).cmarcado:=i.marcado;

	        autol(autol.last).idifglobal:=i.idifglobal;

	        autol(autol.last).tagente:=i.tagente;
	    END LOOP;

	    /*-pendiente de mirar: Contemplar la casuística de un impagado (en estado actual no domiciliado)  no liquidado, que también ha de ser mostrado.*/
	    /*-Siempre sobre el máximo movimiento del recibo.*/
	    RETURN autol;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);

	             RETURN NULL;
	END f_get_autoliquidaage;
	FUNCTION f_set_autoliquidaage(
			pcagente	IN	NUMBER,
			pnliqmen	IN	NUMBER,
			pcestautoliq	IN	NUMBER,
			piimporte	IN	NUMBER,
			pcusuari	IN	VARCHAR2,
			pfcobro	IN	DATE,
			pcmarcado	IN	NUMBER,
			pidifglobal	IN	NUMBER,
			pfliquida	IN	DATE,
			pcempres	IN	NUMBER,
			pcageclave	IN	NUMBER,
			psproliq	IN	NUMBER,
			opsproliq	OUT	NUMBER
	) RETURN NUMBER
	IS
	  vnumerr     NUMBER:=0;
	  v_nliqmen   NUMBER:=NULL;
	  v_nliqaux2  NUMBER:=NULL;
	  v_object    VARCHAR2(500):='PAC_AUTOLIQUIDA.f_set_autoliquidaage';
	  v_param     VARCHAR2(500):='parámetros - pcageclave: '
	                         || pcageclave
	                         || ', pcempres: '
	                         || pcempres
	                         || ', psproliq: '
	                         || psproliq
	                         || ', pcagente: '
	                         || pcagente
	                         || ', pnliqmen: '
	                         || pnliqmen
	                         || ', pcestautoliq: '
	                         || pcestautoliq
	                         || ', piimporte: '
	                         || piimporte
	                         || ', pcusuari: '
	                         || pcusuari
	                         || ', pfcobro: '
	                         || pfcobro
	                         || ', pcmarcado: '
	                         || pcmarcado
	                         || ', pidifglobal: '
	                         || pidifglobal
	                         || ', pfliquida: '
	                         || pfliquida;
	  v_pasexec   NUMBER(5):=1;
	  vdiasliq    NUMBER(5):=0;
	  vcestado    NUMBER;
	  vcestadoliq NUMBER;
	  v_titulo    VARCHAR2(500);
	  v_modo      NUMBER;
	  vsproliq    NUMBER;
	  vageagrup   NUMBER:=0;
	BEGIN
	    v_titulo:='Proceso de Autoliquidaciones';

	    /*validamos que el agente no sea un agente agrupado*/
	    IF nvl(pac_parametros.f_parempresa_n(pcempres, 'LIQUIDA_AGECLAVE'), 0)=1 THEN
	      SELECT count(1)
	        INTO vageagrup
	        FROM agentes_comp
	       WHERE cagente=pcageclave AND
	             cageclave IS NOT NULL;

	      IF vageagrup>0 --and NVL(pac_parametros.f_parempresa_n(pempresa, 'LIQUIDA_AGECLAVE'), 0) =1
	      THEN
	        p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, 'Agente agrupado, seleccione el agente principal de la agrupación.');

	        RETURN 9908329;
	      END IF;
	    END IF;

	    /*Insertamos en la tabla PROCESOSCAB el registro identificativo de proceso -----*/
	    v_pasexec:=2;

	    /*p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, 'psproliq-> .'
	                                                                 || psproliq);*/

	    IF nvl(psproliq, 0)=0 THEN
	      vnumerr:=f_procesini(f_user, pcempres, 'AUTOLIQUIDACIONES', v_titulo, opsproliq);

	      /*p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, 'vnumerr_procces ini-> .'
	                                                                   || vnumerr);*/

	      COMMIT;
	    ELSE
	      opsproliq:=psproliq;
	    /*p_control_error('JRB', 'liquidaciones1', v_param);*/
	    END IF;

	    /*p_control_error('JRB', 'liquidaciones2', pnliqmen);*/
	    v_pasexec:=2;

	    /* IF autoliquidaage IS NOT NULL
	    AND autoliquidaage.COUNT > 0 THEN
	    FOR i IN autoliquidaage.FIRST .. autoliquidaage.LAST LOOP
	       v_pasexec := 15;

	       IF autoliquidaage.EXISTS(i) THEN*/
	    v_pasexec:=3;

	    IF pcmarcado=1 THEN
	    /*p_control_error('JRB', 'liquidaciones40', pidifglobal);*/
	    /* IF NVL(pnliqmen, 0) = 0 THEN*/
	      /*Creamos o modificamos la cabecera de liquidacion*/

	      vnumerr:=f_set_autoliquidacab('G', NULL, pcempres, pcagente, 1, nvl(pfliquida, f_sysdate), pfcobro, NULL, pcusuari, piimporte, opsproliq, pidifglobal, vsproliq, v_nliqmen, 1);

	    /*p_control_error('JRB', 'liquidaciones41', vnumerr);*/
	      /*  END IF;*/
	      BEGIN
			INSERT INTO liquidaage
		           (cempres,cageclave,cagente,sproliq,nliqmen,cestautoliq,
		           fliquid,iimporte,cusuari,fcobro)
		    VALUES
		           (pcempres,pcageclave,pcagente,opsproliq,nvl(v_nliqmen, pnliqmen),
		           pcestautoliq,nvl(pfliquida, f_sysdate),pidifglobal,nvl(pcusuari,
		           f_user),pfcobro); /* BUG 24714 - JLTS - Se adiciona el campo CTIPO*/


	         /* p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, 'VALUES  '
	                                                                       || pcempres
	                                                                       || ' '
	                                                                       || pcageclave
	                                                                       || ' '
	                                                                       || pcagente
	                                                                       || ' '
	                                                                       || opsproliq
	                                                                       || ' '
	                                                                       || nvl(v_nliqmen, pnliqmen)
	                                                                       || ' '
	                                                                       || pcestautoliq
	                                                                       || ' '
	                                                                       || nvl(pfliquida, f_sysdate)
	                                                                       || ' '
	                                                                       || pidifglobal
	                                                                       || ' '
	                                                                       || nvl(pcusuari, f_user)
	                                                                       || ' '
	                                                                       || f_sysdate
	                                                                       || ')');*/

	      EXCEPTION
	          WHEN dup_val_on_index THEN
	            UPDATE liquidaage
	               SET cestautoliq=pcestautoliq,fliquid=nvl(pfliquida, f_sysdate),iimporte=pidifglobal,cusuari=nvl(pcusuari, f_user),fcobro=pfcobro
	             WHERE cempres=pcempres AND
	                   cageclave=pcageclave AND
	                   cagente=pcagente AND
	                   sproliq=opsproliq AND
	                   fcobro=f_sysdate AND
	                   nliqmen=nvl(v_nliqmen, pnliqmen);
	      END;
	    ELSE
	     /* p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, 'Borrar con los datos   pnliqmen: '
	                                                                   || nvl(v_nliqmen, pnliqmen)
	                                                                   || ' pcagente: '
	                                                                   || pcagente
	                                                                   || ' pcempres: '
	                                                                   || pcempres
	                                                                   || ' psproliq: '
	                                                                   || psproliq);*/

	      /*borramos autoliquidación*/
	      DELETE FROM liquidalindet
	       WHERE nliqmen=nvl(v_nliqmen, pnliqmen) AND
	             cagente=pcagente AND
	             cempres=pcempres;

	      DELETE FROM liquidalin
	       WHERE nliqmen=nvl(v_nliqmen, pnliqmen) AND
	             cagente=pcagente AND
	             cempres=pcempres;

	      DELETE FROM ext_liquidalin
	       WHERE nliqmen=nvl(v_nliqmen, pnliqmen) AND
	             cagente=pcagente AND
	             cempres=pcempres;

	      DELETE FROM liquidacab
	       WHERE ctipoliq=1 AND
	             cagente=pcagente AND
	             cempres=pcempres AND
	             sproliq=psproliq AND
	             nliqmen=nvl(v_nliqmen, pnliqmen);

	      DELETE FROM liquidaage
	       WHERE cagente=pcagente AND
	             cempres=pcempres AND
	             sproliq=psproliq AND
	             nliqmen=nvl(v_nliqmen, pnliqmen);

	      /*  DELETE FROM liquidacobros
	              WHERE sproliq = opsproliq
	                AND cagente = pcagente
	                AND cempres = pcempres;
	      */
	      UPDATE ctactes
	         SET cestado=1,sproces=NULL
	       WHERE sproces=opsproliq AND
	             cagente=pcagente;
	    END IF;

	    /*    END IF;
	     END LOOP;
	    END IF;*/
	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, 'Parámetros incorrectos');

	             RETURN 1; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLCODE
	                                                                          || ' - '
	                                                                          || SQLERRM);

	             RETURN 1;
	END f_set_autoliquidaage;
	FUNCTION f_set_autoliquidacab(
			pcmodo	IN	VARCHAR2,
			pnliqmen	IN	NUMBER,
			pcempres	IN	NUMBER,
			pcagente	IN	NUMBER,
			pcestado	IN	NUMBER DEFAULT 1,
			pfliquida	IN	DATE,
			pfcobro	IN	DATE,
			pctomador	IN	NUMBER,
			pcusuario	IN	VARCHAR2,
			piimporte	IN	NUMBER,
			psproliq	IN	NUMBER,
			pidifglobal	IN	NUMBER,
			pcproces	OUT	NUMBER,
			ponliqmen	OUT	NUMBER,
			pcautoli	IN	NUMBER DEFAULT 0
	) RETURN NUMBER
	IS
	  vnumerr     NUMBER:=0;
	  v_nliqmen   NUMBER:=NULL;
	  v_nliqaux2  NUMBER:=NULL;
	  v_object    VARCHAR2(500):='PAC_AUTOLIQUIDA.f_set_autoliquidacab';
	  v_param     VARCHAR2(500):='parámetros - pcmodo: '
	                         || pcmodo
	                         || ', pnliqmen: '
	                         || pnliqmen
	                         || ', pcagente: '
	                         || pcagente
	                         || ', pcempres: '
	                         || pcempres
	                         || ', pcestado: '
	                         || pcestado
	                         || ', pfliquida: '
	                         || pfliquida
	                         || ', pfcobro: '
	                         || pfcobro
	                         || ', pctomador: '
	                         || pctomador
	                         || ', pcusuario: '
	                         || pcusuario
	                         || ', piimporte: '
	                         || piimporte
	                         || ', psproliq: '
	                         || psproliq
	                         || ', pidifglobal: '
	                         || pidifglobal;
	  v_pasexec   NUMBER(5):=1;
	  vdiasliq    NUMBER(5):=0;
	  vcestado    NUMBER;
	  vcestadoliq NUMBER:=pcestado;
	  v_titulo    VARCHAR2(500);
	  v_modo      NUMBER;
	  vsproliq    NUMBER;
	  vageagrup   NUMBER:=0;
	BEGIN
	    IF pcmodo='G' THEN
	      v_titulo:='Proceso de Autoliquidaciones - Previo';

	      v_modo:=1;
	    ELSE
	      v_titulo:='Proceso de Autoliquidaciones';

	      v_modo:=0;
	    END IF;

	    /*validamos que el agente no sea un agente agrupado*/
	    /*  SELECT COUNT(1)
	      INTO vageagrup
	      FROM agentes_comp
	     WHERE cagente = pcagente
	       AND cageclave IS NOT NULL;

	    IF vageagrup > 0 THEN
	       p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
	                   'Agente agrupado, seleccione el agente principal de la agrupación.');
	       RETURN 9908329;
	    END IF;*/
	    /*Insertamos en la tabla PROCESOSCAB el registro identificativo de proceso -----*/
	    /*  vnumerr := f_procesini(f_user, pcempres, 'AUTOLIQUIDACIONES', v_titulo, pcproces);*/
	    /*  COMMIT;*/
	    /*p_control_error('JRB', 'liquidaciones1', v_param);*/
	    IF nvl(pnliqmen, 0)=0 THEN
	      SELECT max(nliqmen)
	        INTO v_nliqaux2
	        FROM liquidacab
	       WHERE cagente=pcagente AND
	             fliquid<=pfliquida AND
	             ctipoliq=1 AND
	             cempres=pcempres;
	    ELSE
	      v_nliqaux2:=NULL;
	    END IF;

	    /*p_control_error('JRB', 'liquidaciones2', v_nliqaux2);*/
	    v_pasexec:=2;

	    /* Si existe algun previo, borramos el previo que existe.*/
	    IF pcautoli=0 AND
	       psproliq IS NOT NULL THEN
	    /* AND pcmodo = 'L' THEN*/
	    /* Bug 0029334 - JMF - 11/12/2013*/
	      /*   BEGIN
	         SELECT sproliq
	           INTO vsproliq
	           FROM liquidacab
	          WHERE nliqmen = v_nliqaux2
	            AND cagente = pcagente
	            AND fliquid <= pfliquida
	            AND ctipoliq = 1
	            AND cempres = pcempres;
	      EXCEPTION
	         WHEN OTHERS THEN*/
	      vsproliq:=psproliq;

	    /*  END;*/
	      /*p_control_error('JRB', 'liquidaciones3', vsproliq);*/
	      DELETE FROM liquidalindet
	       WHERE nliqmen=v_nliqaux2 AND
	             cagente=pcagente AND
	             cempres=pcempres;

	      DELETE FROM liquidalin
	       WHERE nliqmen=v_nliqaux2 AND
	             cagente=pcagente AND
	             cempres=pcempres;

	      DELETE FROM ext_liquidalin
	       WHERE nliqmen=v_nliqaux2 AND
	             cagente=pcagente AND
	             cempres=pcempres;

	    /*         DELETE FROM liquidacab
	                   WHERE ctipoliq = 1
	                     AND cagente = pcagente
	                     AND cempres = pcempres
	                     AND nliqmen = v_nliqaux2
	                     AND fliquid = pfliquida;
	    */ /*  DELETE FROM liquidacobros
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 WHERE nliqmen = v_nliqaux2
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   AND cagente = pcagente
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   AND cempres = pcempres;*/
	      UPDATE ctactes
	         SET cestado=1,sproces=NULL
	       /*fcobro  = f_sysdate*/
	       WHERE sproces=vsproliq AND
	             cagente=pcagente;
	    END IF;

	    v_pasexec:=3;

	    BEGIN
	        SELECT nliqmen
	          INTO v_nliqmen
	          FROM liquidacab
	         WHERE cempres=pcempres AND
	               sproliq=nvl(vsproliq, psproliq) AND
	               cagente=pcagente;
	    EXCEPTION
	        WHEN no_data_found THEN
	          SELECT nvl(max(nliqmen), 0)+1
	            INTO v_nliqmen
	            FROM liquidacab
	           WHERE cempres=pcempres AND
	                 cagente=pcagente;
	        WHEN OTHERS THEN
	          v_nliqmen:=1;
	    END;

	    /*p_control_error('JRB', 'liquidaciones4', v_nliqmen);*/
	    v_pasexec:=4;

	    IF pcmodo='L' THEN
	      /*Si es modo/liquidación REAL, el cestado = 1 de liquidacab*/
	      vcestado:=1;

	      vcestadoliq:=2; /*liquidacion cerrada*/
	    ELSE
	      vcestadoliq:=nvl(pcestado, 1);

	      vcestado:=1;
	    END IF;

	    /*Creamos la cabecera de liquidacab por agente*/
	    BEGIN
			INSERT INTO liquidacab
		           (cagente,nliqmen,fliquid,fmovimi,fcontab,cempres,
		           sproliq,ntalon,cctatalon,fingtalon,ctipoliq,
		           cestado,cusuari,fcobro,ctotalliq,iimporte,
		           cestautoliq,idifglobal)
		    VALUES
		           (pcagente,v_nliqmen,pfliquida,f_sysdate,NULL,pcempres,
		           psproliq,NULL,NULL,NULL,v_modo,
		           vcestado,f_user,pfcobro,NULL,piimporte,
		           vcestadoliq,nvl(pidifglobal, 0));


	       /* p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, 'VALUES  cab '
	                                                                     || pcagente
	                                                                     || ' '
	                                                                     || v_nliqmen
	                                                                     || ' '
	                                                                     || pfliquida
	                                                                     || ' '
	                                                                     || f_sysdate
	                                                                     || ' '
	                                                                     || NULL
	                                                                     || ' '
	                                                                     || pcempres
	                                                                     || ' '
	                                                                     || psproliq
	                                                                     || ' '
	                                                                     || NULL
	                                                                     || ' '
	                                                                     || NULL
	                                                                     || ' '
	                                                                     || NULL
	                                                                     || ' '
	                                                                     || v_modo
	                                                                     || ' '
	                                                                     || vcestado
	                                                                     || ' '
	                                                                     || f_user
	                                                                     || ' '
	                                                                     || f_sysdate
	                                                                     || ' '
	                                                                     --|| pfcobro,
	                                                                     NULL
	                                                                     || ' '
	                                                                     || piimporte
	                                                                     || ' '
	                                                                     || vcestadoliq
	                                                                     || ' '
	                                                                     || nvl(pidifglobal, 0)
	                                                                     || ')');*/
	    /*p_control_error('JRB', 'liquidaciones5', v_nliqmen);*/
	    EXCEPTION
	        WHEN dup_val_on_index THEN
	          UPDATE liquidacab
	             SET iimporte=piimporte,cestautoliq=vcestadoliq,fliquid=pfliquida,fmovimi=f_sysdate,sproliq=psproliq,cestado=vcestado,fcobro=pfcobro,ctipoliq=v_modo,idifglobal=nvl(pidifglobal, 0)
	           WHERE cagente=pcagente AND
	                 nliqmen=v_nliqmen AND
	                 cempres=pcempres;
	    /*p_control_error('JRB', 'liquidaciones6', v_nliqmen);*/
	    END;

	    UPDATE liquidaage
	       SET iimporte=piimporte
	     WHERE sproliq=psproliq AND
	           cagente=pcagente AND
	           nliqmen=v_nliqmen;

	    v_pasexec:=5;

	    ponliqmen:=v_nliqmen;

	    v_pasexec:=6;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, 'Parámetros incorrectos');

	             RETURN 1; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLCODE
	                                                                          || ' - '
	                                                                          || SQLERRM);

	             RETURN 1;
	END f_set_autoliquidacab;
	FUNCTION f_set_autoliquidacion(
			pcmodo	IN	VARCHAR2,
			pnliqmen	IN	NUMBER,
			pcempres	IN	NUMBER,
			pcagente	IN	NUMBER,
			psproces	IN	NUMBER,
			pocestado	OUT	NUMBER
	) RETURN NUMBER
	IS
	  vnumerr     NUMBER:=0;
	  v_nliqmen   NUMBER:=NULL;
	  v_nliqaux2  NUMBER:=NULL;
	  v_selec     CLOB;
	  v_object    VARCHAR2(500):='PAC_AUTOLIQUIDA.f_set_autoliquidacion';
	  v_param     VARCHAR2(500):='parámetros - pcmodo: '
	                         || pcmodo
	                         || ', pnliqmen: '
	                         || pnliqmen
	                         || ', pcagente: '
	                         || pcagente
	                         || ', pcempres: '
	                         || pcempres
	                         || ', psproces: '
	                         || psproces;
	  v_pasexec   NUMBER(5):=1;
	  vdiasliq    NUMBER(5):=0;
	  vcestado    NUMBER;
	  v_titulo    VARCHAR2(500);
	  v_modo      NUMBER;
	  vsproliq    NUMBER;
	  v_nnumlin   NUMBER;
	  vcomisiones NUMBER;
	  v_signo     NUMBER;
	  vidifglobal NUMBER;
	BEGIN
	    IF pcmodo='L' THEN
	      v_modo:=0;

	      SELECT nvl(max(nnumlin), 0)+1
	        INTO v_nnumlin
	        FROM ctactes
	       WHERE cagente=pcagente;

	      SELECT SUM(iimport*(decode(cdebhab, 2, 1,
	                                          -1)))
	        INTO vcomisiones
	        FROM ctactes
	       WHERE cagente=pcagente AND
	             sproces=psproces AND
	             cempres=pcempres AND
	             cestado=0;

	      IF vcomisiones>=0 THEN
	        v_signo:=1;
	      ELSE
	        v_signo:=2;
	      END IF;

	      IF nvl(vcomisiones, 0)<>0 THEN
			INSERT INTO ctactes
		           (cagente,nnumlin,cdebhab,cconcta,cestado,ndocume,
		           ffecmov,iimport,tdescrip,cmanual,cempres,
		           nrecibo,nsinies,sseguro,sproces,fvalor,
		           sproduc,ccompani)
		    VALUES
		           (pcagente,v_nnumlin,decode(v_signo, 1, 1, 2),
		           98,0,NULL,f_sysdate,abs(vcomisiones),
		           f_axis_literales(9002265, pac_md_common.f_get_cxtidioma),1,pcempres,NULL,
		           NULL,NULL,psproces,f_sysdate,0,
		           NULL);


	      END IF;

	      UPDATE liquidaage
	         SET cestautoliq=2
	       WHERE sproliq=psproces;

	      SELECT idifglobal
	        INTO vidifglobal
	        FROM liquidacab
	       WHERE cagente=pcagente AND
	             nliqmen=pnliqmen AND
	             cempres=pcempres;

	      IF nvl(vidifglobal, 0)<>0 THEN
	        /*cconcta 32 diferencia si liquida*/
	        IF vidifglobal>=0 THEN
	          v_signo:=1;
	        ELSE
	          v_signo:=2;
	        END IF;

	        SELECT nvl(max(nnumlin), 0)+1
	          INTO v_nnumlin
	          FROM ctactes
	         WHERE cagente=pcagente;

	        v_pasexec:=11;

			INSERT INTO ctactes
		           (cagente,nnumlin,cdebhab,cconcta,cestado,ndocume,
		           ffecmov,iimport,tdescrip,cmanual,cempres,
		           nrecibo,nsinies,sseguro,sproces,fvalor,
		           sproduc,ccompani)
		    VALUES
		           (pcagente,v_nnumlin,v_signo,32,1,NULL,
		           f_sysdate,abs(vidifglobal),f_axis_literales(9906899, pac_md_common.f_get_cxtidioma),0,
		           pcempres,NULL,NULL,NULL,NULL,
		           f_sysdate,0,NULL);


	      END IF;
	    END IF;

	    v_pasexec:=2;

	    SELECT cestautoliq
	      INTO pocestado
	      FROM liquidacab
	     WHERE nliqmen=pnliqmen AND
	           sproliq=psproces AND
	           cagente=pcagente;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, 'Parámetros incorrectos');

	             RETURN 9908232; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLCODE
	                                                                          || ' - '
	                                                                          || SQLERRM);

	             RETURN 9908232;
	END f_set_autoliquidacion;
	FUNCTION f_set_recibos(
			pcmodo	IN	VARCHAR2,
			pnliqmen	IN	NUMBER,
			pcempres	IN	NUMBER,
			pcagente	IN	NUMBER,
			pnliqlin	IN	NUMBER,
			pnrecibo	IN	NUMBER,
			pctiprec	IN	NUMBER,
			pnfrafec	IN	NUMBER,
			pfefecto	IN	DATE,
			pitotalr	IN	NUMBER,
			picomisi	IN	NUMBER,
			piretencom	IN	NUMBER,
			pidiferencia	IN	NUMBER,
			psproces	IN	NUMBER,
			ppl	IN	NUMBER,
			pidiferpyg	IN	NUMBER,
			--AAC_INI-CONF_379-20160927
			pimppend		IN	NUMBER,
			pvabono		IN	NUMBER,
			pfabono		IN	DATE,
			pdocreau		IN 	NUMBER,
			pcorteprod	IN	NUMBER
			--AAC_FI-CONF_379-20160927
	) RETURN NUMBER
	IS
	  vnumerr    NUMBER:=0;
	  v_nliqmen  NUMBER:=NULL;
	  v_nliqaux2 NUMBER:=NULL;
	  v_selec    CLOB;
	  v_object   VARCHAR2(500):='PAC_AUTOLIQUIDA.f_set_recibos';
	  v_param    VARCHAR2(500):='parámetros - pcmodo: '
	                         || pcmodo
	                         || ', pnliqmen: '
	                         || pnliqmen
	                         || ', pcempres: '
	                         || pcempres
	                         || ', pcagente: '
	                         || pcagente
	                         || ', pnliqlin: '
	                         || pnliqlin
	                         || ', pnrecibo: '
	                         || pnrecibo
	                         || ', pctiprec: '
	                         || pctiprec
	                         || ', pnfrafec: '
	                         || pnfrafec
	                         || ', pfefecto: '
	                         || pfefecto
	                         || ', pitotalr: '
	                         || pitotalr
	                         || ', picomisi: '
	                         || picomisi
	                         || ', piretencom: '
	                         || piretencom
	                         || ', pidiferencia: '
	                         || pidiferencia
	                         || ', psproces: '
	                         || psproces
	                         || ', ppl : '
	                         || ppl
	                         || ', pidiferpyg: '
	                         || pidiferpyg
							 --AAC_INI-CONF_379-20160927
							 || ', pimppend : ' || pimppend
							 || ', pvabono : ' || pvabono
							 || ', pfabono : ' || pfabono
							 || ', pdocreau : ' || pdocreau
							 || ', pcorteprod : ' || pcorteprod
							 --AAC_FI-CONF_379-20160927
							 ;
	  v_pasexec  NUMBER(5):=1;
	  vdiasliq   NUMBER(5):=0;
	  vcestado   NUMBER;
	  vpl        NUMBER:=1;
	  vctipoliq  NUMBER;
	  vigenera   NUMBER;
	  vfcobro    DATE;
	  vctipcob   recibos.ctipcob%TYPE;
	  vsmovrec   movrecibo.smovrec%TYPE;
	  vcmoneda   seguros.cmoneda%TYPE;
	  vsproduc   seguros.sproduc%TYPE;
	  vccompani  seguros.ccompani%TYPE;
	  vsseguro   seguros.sseguro%TYPE;
	  v_signo    NUMBER;
	  v_nnumlin  NUMBER;
	  --AAC_INI-CONF_379-20160927
	  v_corteprod NUMBER;
	  v_itotalr NUMBER;
	  v_cestado NUMBER;
	  --AAC_FII-CONF_379-20160927
	BEGIN
	    IF pcmodo='G' THEN
	      vctipoliq:=1;
	    ELSE
	      vctipoliq:=0;
	    END IF;

	    v_pasexec:=2;

	    IF pctiprec IN (9, 13) THEN
	      v_signo:=-1;
	    ELSE
	      v_signo:=1;
	    END IF;

		--AAC_INI-CONF_379-20160927
		IF pcorteprod is null then
			v_corteprod := 0;
		ELSE
			v_corteprod := pcorteprod;
		END if;
		--AAC_FI-CONF_379-20160927

	    v_pasexec:=3;

	    SELECT r.ctipcob,s.cmoneda,s.sproduc,s.ccompani,s.sseguro
	      INTO vctipcob, vcmoneda, vsproduc, vccompani, vsseguro
	      FROM recibos r,seguros s
	     WHERE s.sseguro=r.sseguro AND
	           r.nrecibo=pnrecibo;

	    v_pasexec:=4;

	    /*al dar liquidar se cobran los recibos*/
	    IF pcmodo='L' THEN
	      vnumerr:=pac_adm_cobparcial.f_cobro_parcial_recibo(pnrecibo, vctipcob, abs(pitotalr), vcmoneda, vigenera, vfcobro);

	      SELECT m.smovrec /* Cuando se cobra el recibo busco su smovrec, para contabilidad.*/
	        INTO vsmovrec
	        FROM movrecibo m
	       WHERE m.nrecibo=pnrecibo AND
	             m.fmovfin IS NULL;
	    END IF;

	    /*solo liquidar*/
	    IF vnumerr=0 AND
	       pcmodo='L'
		   --AAC_INI-CONF_379-20160927
			AND v_corteprod = 0
			--AAC_FI-CONF_379-20160927
		   THEN
	      v_pasexec:=5;

	      /*cconcta 99 Grabo la comision como pendiente*/
	      SELECT nvl(max(nnumlin), 0)+1
	        INTO v_nnumlin
	        FROM ctactes
	       WHERE cagente=pcagente;

	      v_pasexec:=6;

	      IF picomisi>=0 THEN
	        v_signo:=1;
	      ELSE
	        v_signo:=2;
	      END IF;

	      v_pasexec:=7;

	      /*cconcta 99 comisión del recibo del recibo*/
			INSERT INTO ctactes
		           (cagente,nnumlin,cdebhab,cconcta,cestado,ndocume,
		           ffecmov,iimport,tdescrip,cmanual,cempres,
		           nrecibo,nsinies,sseguro,sproces,fvalor,
		           sproduc,ccompani)
		    VALUES
		           (pcagente,v_nnumlin,v_signo,90,decode(ppl, 1,
		           0, 1),NULL,f_sysdate,abs(picomisi)-abs(nvl(piretencom,
		           0)),f_axis_literales(9901791, pac_md_common.f_get_cxtidioma),0,pcempres,
		           pnrecibo,NULL,vsseguro,decode(ppl, 1,
		           psproces, NULL),pfefecto,vsproduc,vccompani);


	      v_pasexec:=10;

	      IF nvl(pidiferencia, 0)<>0 THEN
	        /*cconcta 32 diferencia si liquida*/
	        IF pidiferencia>=0 THEN
	          v_signo:=1;
	        ELSE
	          v_signo:=2;
	        END IF;

	        SELECT nvl(max(nnumlin), 0)+1
	          INTO v_nnumlin
	          FROM ctactes
	         WHERE cagente=pcagente;

	        v_pasexec:=11;

			INSERT INTO ctactes
		           (cagente,nnumlin,cdebhab,cconcta,cestado,ndocume,
		           ffecmov,iimport,tdescrip,cmanual,cempres,
		           nrecibo,nsinies,sseguro,sproces,fvalor,
		           sproduc,ccompani)
		    VALUES
		           (pcagente,v_nnumlin,v_signo,32,1,NULL,
		           f_sysdate,abs(pidiferencia),f_axis_literales(9906899, pac_md_common.f_get_cxtidioma),0,
		           pcempres,pnrecibo,NULL,vsseguro,NULL,
		           pfefecto,vsproduc,vccompani);


	      END IF;

	      v_pasexec:=12;

	      /**/
	      IF nvl(pidiferpyg, 0)<>0 THEN
	        IF pidiferpyg>=0 THEN
	          v_signo:=2;
	        ELSE
	          v_signo:=1;
	        END IF;

	        v_pasexec:=13;

	        SELECT nvl(max(nnumlin), 0)+1
	          INTO v_nnumlin
	          FROM ctactes
	         WHERE cagente=pcagente;

			INSERT INTO ctactes
		           (cagente,nnumlin,cdebhab,cconcta,cestado,ndocume,
		           ffecmov,iimport,tdescrip,cmanual,cempres,
		           nrecibo,nsinies,sseguro,sproces,fvalor,
		           sproduc,ccompani)
		    VALUES
		           (pcagente,v_nnumlin,v_signo,31,0,NULL,
		           f_sysdate,abs(pidiferpyg),f_axis_literales(9906899, pac_md_common.f_get_cxtidioma),1,
		           pcempres,pnrecibo,NULL,vsseguro,psproces,
		           pfefecto,vsproduc,vccompani);


	        IF nvl(pidiferpyg, 0)>=0 THEN
	          v_signo:=1;
	        ELSE
	          v_signo:=2;
	        END IF;

	        v_pasexec:=14;

	        SELECT nvl(max(nnumlin), 0)+1
	          INTO v_nnumlin
	          FROM ctactes
	         WHERE cagente=pcagente;


			INSERT INTO ctactes
		           (cagente,nnumlin,cdebhab,cconcta,cestado,ndocume,
		           ffecmov,iimport,tdescrip,cmanual,cempres,
		           nrecibo,nsinies,sseguro,sproces,fvalor,
		           sproduc,ccompani)
		    VALUES
		           (pcagente,v_nnumlin,v_signo,33,0,NULL,
		           f_sysdate,abs(pidiferpyg),f_axis_literales(9906899, pac_md_common.f_get_cxtidioma),1,
		           pcempres,pnrecibo,NULL,vsseguro,psproces,
		           pfefecto,vsproduc,vccompani);
	      END IF;
		--AAC_INI-CONF_379-20160927
		ELSE IF v_corteprod = 1 THEN

		SELECT nvl(max(nnumlin), 0)+1
	          INTO v_nnumlin
	          FROM ctactes
	         WHERE cagente=pcagente;

		select itotalr into v_itotalr
		from vdetrecibos where nrecibo = pnrecibo;

		IF pimppend < v_itotalr then
			v_cestado := 1;
		ELSE
			v_cestado := 0;
		END IF;

		INSERT INTO ctactes
						   (cagente,nnumlin,cdebhab,cconcta,cestado,ndocume,
						   ffecmov,iimport,tdescrip,cmanual,cempres,
						   nrecibo,nsinies,sseguro,sproces,fvalor,
						   sproduc,ccompani)
					VALUES
						   (pcagente,v_nnumlin,3,95,v_cestado,NULL,
						   f_sysdate,abs(picomisi),f_axis_literales(9909766, pac_md_common.f_get_cxtidioma),1,
						   pcempres,pnrecibo,NULL,vsseguro,psproces,
						   pfefecto,vsproduc,vccompani);

		--AAC_FI-CONF_379-20160927

	    END IF;
      END IF;

	    v_pasexec:=15;

	    IF pnliqlin=0 THEN
	      SELECT nvl(max(nliqlin), 0)+1
	        INTO v_nnumlin
	        FROM liquidalin
	       WHERE nliqmen=pnliqmen AND
	             cempres=pcempres AND
	             cagente=pcagente;
	    ELSE
	      v_nnumlin:=pnliqlin;
	    END IF;
      BEGIN
        --Inicio Bug 42544  actualizar el movimiento de cobro
          INSERT INTO liquidalin
                   (cempres,nliqmen,cagente,nliqlin,nrecibo,smovrec,
                   itotimp,itotalr,iprinet,icomisi,iretenccom,
                   isobrecomision,iretencsobrecom,iconvoleducto,iretencoleoducto,ctipoliq,
                   itotimp_moncia,itotalr_moncia,iprinet_moncia,icomisi_moncia,iretenccom_moncia,
                   isobrecom_moncia,iretencscom_moncia,iconvoleod_moncia,iretoleod_moncia,fcambio,
                   idiferencia,com_inc,idiferpyg,
				   --AAC_INI-CONF_379-20160927
				   imppend,
				   vabono,
				   fabono,
				   DOCRECAU,
				   corteprod
				   --AAC_FI-CONF_379-20160927
				   )
            VALUES
                   (pcempres,pnliqmen,pcagente,v_nnumlin,pnrecibo,vsmovrec,
                   nvl(piretencom, 0),nvl(pitotalr, 0),(nvl(pitotalr,
                   0)-nvl(picomisi, 0)+nvl(piretencom, 0)),nvl(picomisi, 0),
                   nvl(piretencom, 0),NULL,NULL,NULL,
                   NULL,vctipoliq,/* Multimoneda*/NULL,NULL,NULL,
                   NULL,NULL,NULL,NULL,NULL,
                   NULL,/*DECODE(v_cmultimon, 0, NULL, NVL(v_fcambio,
                   f_sysdate))*/NULL,nvl(pidiferencia, 0),ppl,nvl(pidiferpyg,
                   0),
				   --AAC_INI-CONF_379-20160927
				   pimppend,
				   pvabono,
				   pfabono,
				   pdocreau,
				   pcorteprod
				   --AAC_FI-CONF_379-20160927
				   );
      EXCEPTION
          WHEN dup_val_on_index THEN
	             UPDATE liquidalin
	                SET idiferencia=nvl(pidiferencia, 0),idiferpyg=nvl(pidiferpyg, 0),
                      com_inc=ppl, smovrec=vsmovrec
	              WHERE cempres=pcempres AND
	                    nliqmen=pnliqmen AND
	                    cagente=pcagente AND
	                    nliqlin=pnliqlin AND
	                    nrecibo=pnrecibo;

	             RETURN 0;
      END;
      --Fin Bug 42544  actualizar el movimiento de cobro

	    RETURN 0;
	EXCEPTION
      WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, 'Parámetros incorrectos');

	             RETURN 1; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLCODE
	                                                                          || ' - '
	                                                                          || SQLERRM);

	             RETURN 1;
	END f_set_recibos;
	FUNCTION f_set_cobros(
			pidcobro	IN	NUMBER,
			pcagente	IN	NUMBER,
			pcempres	IN	NUMBER,
			psproliq	IN	NUMBER,
			pncobro	IN	NUMBER,
			pncdocu	IN	VARCHAR2,
			pfdocu	IN	DATE,
			pncban	IN	NUMBER,
			piimporte	IN	NUMBER,
			ptobserva	IN	VARCHAR2
	) RETURN NUMBER
	IS
	  vnumerr    NUMBER:=0;
	  v_nliqmen  NUMBER:=NULL;
	  v_nliqaux2 NUMBER:=NULL;
	  v_selec    CLOB;
	  v_object   VARCHAR2(500):='PAC_AUTOLIQUIDA.f_set_cobros';
	  v_param    VARCHAR2(3000):='parámetros - pcagente: '
	                          || pcagente
	                          || ', pcempres: '
	                          || pcempres
	                          || ', psproliq: '
	                          || psproliq
	                          || ', pncobro: '
	                          || pncobro
	                          || ', pncdocu: '
	                          || pncdocu
	                          || ', pfdocu: '
	                          || pfdocu
	                          || ', pncban: '
	                          || pncban
	                          || ', piimporte: '
	                          || piimporte
	                          || ', ptobserva: '
	                          || ptobserva;
	  v_pasexec  NUMBER(5):=1;
	  vdiasliq   NUMBER(5):=0;
	  vcestado   NUMBER;
	  v_titulo   VARCHAR2(500);
	  v_modo     NUMBER;
	  v_idcobro  NUMBER;
	  v_count    NUMBER;
	BEGIN
	/* alberto - Utilizamos el IDCOBRO para identificar el registro, si es nuevo creamos un IDCOBRO +1*/
	    /*           Si en IDCOBRO enviamos -1 estamos indicando que queremos eleiminar todos los registros de esa liquidacion*/

	    IF pidcobro=9999 THEN
	      DELETE liquidacobros
	       WHERE cagente=pcagente AND
	             cempres=pcempres AND
	             sproliq=psproliq;

	    ELSE
	      DELETE liquidacobros
	       WHERE idcobro=pidcobro AND
	             cagente=pcagente AND
	             cempres=pcempres AND
	             sproliq=psproliq;

	      SELECT count(1)
	        INTO v_count
	        FROM liquidacobros
	       WHERE cempres=pcempres AND
	             sproliq=psproliq AND
	             iimporte=piimporte;

	      IF v_count<1 THEN
			INSERT INTO liquidacobros
		           (idcobro,cagente,cempres,sproliq,ccobro,cdocumento,
		           fdocumento,cbanco,iimporte,tobserva)
		    VALUES
		           (pidcobro,pcagente,pcempres,psproliq,pncobro,pncdocu,
		           pfdocu,pncban,piimporte,ptobserva);


	        /*p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, pidcobro
	                                                                     || ','
	                                                                     || pcagente
	                                                                     || ','
	                                                                     || pcempres
	                                                                     || ','
	                                                                     || psproliq
	                                                                     || ','
	                                                                     || pncobro
	                                                                     || ','
	                                                                     || pncdocu
	                                                                     || ','
	                                                                     || pfdocu
	                                                                     || ','
	                                                                     || pncban
	                                                                     || ','
	                                                                     || piimporte
	                                                                     || ','
	                                                                     || ptobserva);*/
	      END IF;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN dup_val_on_index THEN
	             /* alberto - Al añadir el IDCOBRO por aqui nunca tiene que entrar*/
	             UPDATE liquidacobros
	                SET ccobro=pncobro,cdocumento=pncdocu,fdocumento=pfdocu,cbanco=pncban,iimporte=piimporte,tobserva=ptobserva
	              WHERE cagente=pcagente AND
	                    cempres=pcempres AND
	                    sproliq=psproliq;

	             RETURN 0; WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, 'Parámetros incorrectos');

	             RETURN 1; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLCODE
	                                                                          || ' - '
	                                                                          || SQLERRM);

	             RETURN 1;
	END f_set_cobros;
	FUNCTION f_set_ctas(
			pcmodo	IN	VARCHAR2,
			pcagente	IN	NUMBER,
			pcempres	IN	NUMBER,
			pnnumlin	IN	NUMBER,
			pcsproces	IN	NUMBER
	) RETURN NUMBER
	IS
	  vnumerr    NUMBER:=0;
	  v_nliqmen  NUMBER:=NULL;
	  v_nliqaux2 NUMBER:=NULL;
	  v_selec    CLOB;
	  v_object   VARCHAR2(500):='PAC_AUTOLIQUIDA.f_set_ctas';
	  v_param    VARCHAR2(500):='parámetros - pcmodo: '
	                         || pcmodo
	                         || ', pcagente: '
	                         || pcagente
	                         || ', pcempres: '
	                         || pcempres
	                         || ', pnnumlin: '
	                         || pnnumlin
	                         || ', pcsproces: '
	                         || pcsproces;
	  v_pasexec  NUMBER(5):=1;
	  vdiasliq   NUMBER(5):=0;
	  vcestado   NUMBER;
	  v_titulo   VARCHAR2(500);
	  v_modo     NUMBER;
	  vctipoliq  NUMBER;
	BEGIN
	    IF pcmodo='G' THEN
	      vctipoliq:=1;
	    ELSE
	      vctipoliq:=0;
	    END IF;

	    UPDATE ctactes
	       SET cestado=vctipoliq,sproces=pcsproces
	     WHERE cagente=pcagente AND
	           cempres=pcempres AND
	           nnumlin=pnnumlin;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, 'Parámetros incorrectos');

	             RETURN 1; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLCODE
	                                                                          || ' - '
	                                                                          || SQLERRM);

	             RETURN 1;
	END f_set_ctas;
	FUNCTION f_get_recibo(
			pnrecibo	IN	NUMBER,
			pcagente	IN	NUMBER,
			pctomador	IN	NUMBER,
			psqryrec	OUT	VARCHAR2
	) RETURN NUMBER
	IS
	  vnumerr    NUMBER:=0;
	  v_nliqmen  NUMBER:=NULL;
	  v_nliqaux2 NUMBER:=NULL;
	  v_selec    CLOB;
	  v_object   VARCHAR2(500):='PAC_AUTOLIQUIDA.f_get_recibo';
	  v_param    VARCHAR2(500):='parámetros - pnrecibo: '
	                         || pnrecibo
	                         || ', pcagente: '
	                         || pcagente
	                         || ', pctomador: '
	                         || pctomador;
	  v_pasexec  NUMBER(5):=1;
	  vdiasliq   NUMBER(5):=0;
	  vcestado   NUMBER;
	  v_titulo   VARCHAR2(500);
	  v_modo     NUMBER;
	BEGIN
--AAC_INI-CONF_379-20160927
	    psqryrec:='select 1 ch,r.ctiprec ctiprec, decode(r.ctiprec,9,''Extorno'',''Recibo'') ttiprec, r.nrecibo nrecibo,  ff_desvalorfijo(17,pac_md_common.f_get_cxtidioma,s.cforpag) fp, r.nfracci fra, r.fefecto fefecto, s.npoliza npoliza,
		v.itotalr itotalr, v.icombru comision, v.icomret irpf, (v.itotalr-v.icombru+v.icomret) liquido, 1 pl, 0 dif, 0 difpyg, s.cagente cagente, ff_desagente(s.cagente) mediador, r.cgescar cgescar
		from recibos r, seguros s, vdetrecibos v, movrecibo m, tomadores t
		where r.sseguro = s.sseguro and v.nrecibo = r.nrecibo and m.nrecibo = r.nrecibo and m.fmovfin is null and m.cestrec = 0 and r.ctipcob <> 2 and t.sseguro = s.sseguro
		AND r.cestaux = 0 and ';
--AAC_FI-CONF_379-20160927

	    psqryrec:=psqryrec
	              || ' r.nrecibo = '
	              || pnrecibo;

	    IF pcagente IS NOT NULL THEN
	      psqryrec:=psqryrec
	                || ' AND s.cagente = '
	                || pcagente;
	    END IF;

	    IF pctomador IS NOT NULL THEN
	      psqryrec:=psqryrec
	                || ' and t.sperson = '
	                || pctomador;
	    END IF;

	    psqryrec:=psqryrec
	              || ' order by 1';

	    /*-pendiente de mirar: Contemplar la casuística de un impagado (en estado actual no domiciliado)  no liquidado, que también ha de ser mostrado. Siempre sobre el máximo movimiento del recibo.*/
	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, 'Parámetros incorrectos');

	             RETURN NULL; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLCODE
	                                                                          || ' - '
	                                                                          || SQLERRM);

	             RETURN NULL;
	END f_get_recibo;

	FUNCTION f_del_recibos(
			pnliqmen	IN	NUMBER,
			pcempres	IN	NUMBER,
			pcagente	IN	NUMBER
	) RETURN NUMBER
	IS
	  vnumerr    NUMBER:=0;
	  v_nliqmen  NUMBER:=NULL;
	  v_nliqaux2 NUMBER:=NULL;
	  v_selec    CLOB;
	  v_object   VARCHAR2(500):='PAC_AUTOLIQUIDA.f_del_recibos';
	  v_param    VARCHAR2(500):='parámetros - pnliqmen: '
	                         || pnliqmen
	                         || ', pcempres: '
	                         || pcempres
	                         || ', pcagente: '
	                         || pcagente;
	  v_pasexec  NUMBER(5):=1;
	  vdiasliq   NUMBER(5):=0;
	  vcestado   NUMBER;
	  v_titulo   VARCHAR2(500);
	  v_modo     NUMBER;
	BEGIN
	    DELETE FROM liquidalin
	     WHERE nliqmen=pnliqmen AND
	           cempres=pcempres AND
	           cagente=pcagente;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, 'Parámetros incorrectos');

	             RETURN NULL; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLCODE
	                                                                          || ' - '
	                                                                          || SQLERRM);

	             RETURN NULL;
	END f_del_recibos;
	FUNCTION f_del_cobros(
			psproliq	IN	NUMBER,
			pcempres	IN	NUMBER,
			pcagente	IN	NUMBER
	) RETURN NUMBER
	IS
	  vnumerr    NUMBER:=0;
	  v_nliqmen  NUMBER:=NULL;
	  v_nliqaux2 NUMBER:=NULL;
	  v_selec    CLOB;
	  v_object   VARCHAR2(500):='PAC_AUTOLIQUIDA.f_del_cobros';
	  v_param    VARCHAR2(500):='parámetros - psproliq: '
	                         || psproliq
	                         || ', pcempres: '
	                         || pcempres
	                         || ', pcagente: '
	                         || pcagente;
	  v_pasexec  NUMBER(5):=1;
	  vdiasliq   NUMBER(5):=0;
	  vcestado   NUMBER;
	  v_titulo   VARCHAR2(500);
	  v_modo     NUMBER;
	BEGIN
	    DELETE FROM liquidacobros
	     WHERE sproliq=psproliq AND
	           cempres=pcempres AND
	           cagente=pcagente;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, 'Parámetros incorrectos');

	             RETURN NULL; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLCODE
	                                                                          || ' - '
	                                                                          || SQLERRM);

	             RETURN NULL;
	END f_del_cobros;
	FUNCTION f_del_liquidacion(
			psproliq	IN	NUMBER,
			pcempres	IN	NUMBER,
			pcagente	IN	NUMBER,
			pnliqmen	IN	NUMBER
	) RETURN NUMBER
	IS
	  vnumerr   NUMBER:=0;
	  v_pasexec NUMBER(5):=1;
	  v_selec   CLOB;
	  v_object  VARCHAR2(500):='PAC_AUTOLIQUIDA.f_del_liquidacion';
	  v_param   VARCHAR2(500):='parámetros - psproliq: '
	                         || psproliq
	                         || ', pcempres: '
	                         || pcempres
	                         || ', pcagente: '
	                         || pcagente;

	  vcount    NUMBER;
	BEGIN
	    DELETE FROM liquidacobros
	     WHERE sproliq=psproliq AND
	           cempres=pcempres;

	    DELETE FROM liquidalin
	     WHERE cempres=pcempres AND
	           cagente=pcagente AND
	           nliqmen=pnliqmen;

	    DELETE liquidacab
	     WHERE sproliq=psproliq AND
	           cempres=pcempres;

	    DELETE liquidaage
	     WHERE sproliq=psproliq AND
	           cempres=pcempres;

	    /* END IF;*/

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, 'Parámetros incorrectos');

	             RETURN NULL; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLCODE
	                                                                          || ' - '
	                                                                          || SQLERRM);

	             RETURN NULL;
	END f_del_liquidacion;
	FUNCTION f_del_agenteclave(
			psproliq	IN	NUMBER,
			pcempres	IN	NUMBER,
			pcagente	IN	NUMBER
	) RETURN NUMBER
	IS
	  vnumerr   NUMBER:=0;
	  v_pasexec NUMBER(5):=1;
	  v_selec   CLOB;
	  v_object  VARCHAR2(500):='PAC_AUTOLIQUIDA.f_del_agenteclave';
	  v_param   VARCHAR2(500):='parámetros - psproliq: '
	                         || psproliq
	                         || ', pcempres: '
	                         || pcempres
	                         || ', pcagente: '
	                         || pcagente;

	  vcount    NUMBER;
	BEGIN
	    DELETE liquidaage
	     WHERE sproliq=psproliq AND
	           cempres=pcempres AND
	           cageclave NOT IN (pcagente);

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, 'Parámetros incorrectos');

	             RETURN NULL; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLCODE
	                                                                          || ' - '
	                                                                          || SQLERRM);

	             RETURN NULL;
	END f_del_agenteclave;

	--AAC_INI-CONF_379-20160927
   FUNCTION f_pagos_gestion_outsourcing(pfecha	IN DATE,
										precaudo IN VARCHAR2,
										pproveedor IN VARCHAR2) RETURN NUMBER IS
BEGIN
        RETURN 0;
   END f_pagos_gestion_outsourcing;
--AAC_FI-CONF_379-20160927

	 FUNCTION f_update_irpf(
			v_psproliq	IN	NUMBER,
			v_pcempres	IN	NUMBER,
      v_pcagente IN NUMBER

	) RETURN NUMBER
	IS

    v_pasexec NUMBER(5) := 1;
    v_pretenc          NUMBER;
    new_vimpicomret    NUMBER;
    vimpicomret        NUMBER;
    v_signo          NUMBER := 1;
    v_nnumcom          NUMBER;
    v_nnumcom_c        NUMBER;
     num_err   NUMBER := 0;
     v_object       VARCHAR2(500) := 'PAC_AUTOLIQUIDA.F_UPDATE_IRPF';
      v_param        VARCHAR2(500):= 'cempres:' || v_pcempres || ' cagente:' || v_pcagente || ' psproliq:' || v_psproliq;
	 CURSOR c_rec IS
    select distinct 1 ch, l.nrecibo nrecibo, l.icomisi comision, l.iretenccom icomret,r.cagente cagente , ff_desagente(r.cagente) mediador,v_pcagente cageliq, r.nmovimi nmovimi
		from liquidalin l, liquidacab lc, recibos r
		where l.nliqmen = lc.nliqmen and l.cagente = lc.cagente and l.cempres = lc.cempres
		and l.nrecibo = r.nrecibo and r.cestaux = 0  and lc.sproliq = v_psproliq
    AND lc.cempres = v_pcempres
		union all
		select distinct 0 ch, r.nrecibo nrecibo, decode(r.ctiprec,9,-1,1)*v.icombru comision,  decode(r.ctiprec,9,-1,1)*v.icomret icomret,r.cagente agente, ff_desagente(r.cagente) mediador, v_pcagente
	   cageliq, r.nmovimi nmovimi
		from recibos r, vdetrecibos v, movrecibo m, liquidaage la, liquidacab lc
		where v.nrecibo = r.nrecibo and m.nrecibo = r.nrecibo and m.fmovfin is null and m.cestrec = 0 and r.cestaux = 0 AND r.ctipcob <> 2
      and lc.sproliq = v_psproliq

		   and lc.cestautoliq = 1 and lc.cempres =  v_pcempres
                and r.cagente = la.cagente and la.cageclave =  v_pcagente
                and la.sproliq = v_psproliq
     and la.cempres = lc.cempres
		and r.nrecibo not in (select distinct(nrecibo) from liquidalin l3 where ctipoliq = 1 and nliqmen in
    (select nliqmen from liquidacab where cestautoliq <> 3 AND sproliq =  v_psproliq
                )  AND l3.cempres = v_pcempres
                ) order by cagente, nrecibo;



	BEGIN
      FOR rc IN c_rec LOOP
        vimpicomret := NVL(rc.icomret, 0) * v_signo;
        PAC_LIQUIDA.proceso_update_irpf(rc.cagente , rc.comision , vimpicomret , rc.nrecibo , rc.nmovimi , rc.cagente , v_signo   , num_err);
      end loop;
       commit;
	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, 'Parámetros incorrectos');

	             RETURN NULL; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLCODE
	                                                                          || ' - '
	                                                                          || SQLERRM);



	             RETURN NULL;
	END f_update_irpf;

END pac_autoliquida;

/

  GRANT EXECUTE ON "AXIS"."PAC_AUTOLIQUIDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_AUTOLIQUIDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_AUTOLIQUIDA" TO "PROGRAMADORESCSI";
