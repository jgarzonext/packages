--------------------------------------------------------
--  DDL for Package Body PAC_MD_CTACLIENTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_CTACLIENTE" AS
	/*****************************************************************************
	NAME:       PAC_MD_CTACLIENTE
	PURPOSE:    Funciones de obtención de datos de CTACLIENTE
	REVISIONS:
	Ver        Date        Author           Description
	---------  ----------  ---------------  ------------------------------------
	1.0        25/02/2013   AFM             1. Creación del package.
	3.0        28/04/2015   YDA             3. Se crea la función f_crea_rec_gasto
	4.0        06/05/2015   YDA             4. Se crean las funciones f_get_nroreembolsos y f_actualiza_nroreembol
	******************************************************************************/
	e_object_error EXCEPTION;e_param_error  EXCEPTION;mensajes t_iax_mensajes := NULL;gidioma NUMBER := pac_md_common.f_get_cxtidioma;gempres NUMBER := pac_md_common.f_get_cxtempresa;
	/*----- Funciones internes*/
	/*************************************************************************
	Obtiene los registros de movimientos en CTACLIENTE
	param in psperson  : persona
	param in psseguro  : poliza
	param in fechaIni  : fecha Inicio movimientos
	param in fechaFin  : fecha Final movimientos
	datctacli out sys_refcursor : Collection con datos CTACLIENTE
	param out mensajes : mensajes de error
	return             : 0 si todo ha ido bien o 1
	*************************************************************************/
	FUNCTION f_obtenermovimientos(
			pcempres	IN	NUMBER,
			psperson	IN	NUMBER,
			psseguro	IN	NUMBER,
			psproduc	IN	NUMBER,
			pfechaini	IN	DATE DEFAULT NULL,
			pfechafin	IN	DATE DEFAULT NULL,
			pcmovimi	IN	NUMBER DEFAULT NULL,
			pcmedmov	IN	NUMBER DEFAULT NULL,
			pimporte	IN	NUMBER,
			datctacli	IN	OUT SYS_REFCURSOR,
			mensajes	IN	OUT T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vpasexec  NUMBER(8):=1;
	  vparam    VARCHAR2(200):='pcempres:'
	                        || pcempres
	                        || ' psseguro= '
	                        || psseguro
	                        || ' psperson= '
	                        || psperson
	                        || ' pfechaini= '
	                        || pfechaini
	                        || ' pfechaFin= '
	                        || pfechafin
	                        || ' pcmovimi='
	                        || pcmovimi
	                        || ' pcmedmov= '
	                        || pcmedmov
	                        || ' pimporte= '
	                        || pimporte;
	  vobject   VARCHAR2(200):='PAC_MD_CTACLIENTE.f_obtenerMovimientos';
	  reg_seg   seguros%ROWTYPE;
	  v_norden  NUMBER;
	  tmovimi   VARCHAR2(400);
	  tmedmov   VARCHAR2(400);
	  cuantos   NUMBER;
	  cur       SYS_REFCURSOR;
	  v_sproduc seguros.sseguro%TYPE;
	  vnumerr   NUMBER;
	/**/
	BEGIN
	    IF psperson IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    /**/
	    vpasexec:=2;

	    /**/
	    IF psproduc IS NULL THEN
	      /**/
	      vnumerr:=pac_seguros.f_get_sproduc(psseguro, 'POL', v_sproduc);
	    /**/
	    ELSE
	      /**/
	      v_sproduc:=psproduc;
	    /**/
	    END IF;

	    /**/
	    IF nvl(f_parproductos_v(v_sproduc, 'HAYCTACLIENTE'), 0)=2 THEN
	      OPEN cur FOR
	        SELECT nvl(cd.nrefdeposito, 0) nrefdeposito,nvl(c.seqcaja, 0) seqcaja,c.cempres,c.sperson,c.sseguro,c.sproduc,(SELECT max(nnumlin)
	                                                                                                                         FROM ctacliente
	                                                                                                                        WHERE cempres=c.cempres AND
	                                                                                                                              sperson=c.sperson AND
	                                                                                                                              sseguro=c.sseguro AND
	                                                                                                                              ffecmov=c.ffecmov AND
	                                                                                                                              ffecval=c.ffecval AND
	                                                                                                                              cmovimi=c.cmovimi AND
	                                                                                                                              tdescri=c.tdescri AND
	                                                                                                                              fcambio=c.fcambio AND
	                                                                                                                              (sproces=c.sproces  OR
	                                                                                                                               sproces IS NULL)) nnumlin,c.ffecmov,nvl(cd.fautori, c.ffecval) ffecval,c.cmovimi,c.tdescri,cd.cmedmov,pac_eco_monedas.f_obtener_moneda_seguro2(c.sseguro) cmonedapro,SUM(c.iimppro) iimppro,pac_eco_monedas.f_obtener_cmonint(c.cmoneda) cmoneda,SUM(c.iimpope) iimpope,pac_eco_monedas.f_obtener_moneda_defecto() cmonedains,SUM(c.iimpins) iimpins,c.fcambio,pac_monedas.f_round (((SELECT max(isaldo_prod)
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       FROM ctacliente
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      WHERE cempres=c.cempres AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            sperson=c.sperson AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            sseguro=c.sseguro AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            ffecmov=c.ffecmov AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            ffecval=c.ffecval AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            cmovimi=c.cmovimi AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            tdescri=c.tdescri AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            fcambio=c.fcambio AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            (sproces=c.sproces  OR
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             sproces IS NULL))*(pac_eco_tipocambio.f_cambio (pac_eco_monedas.f_obtener_moneda_seguro2(c.sseguro), pac_eco_monedas.f_obtener_moneda_defecto, trunc(f_sysdate)))), pac_eco_monedas.f_obtener_cmoneda (pac_eco_monedas.f_obtener_moneda_defecto)) isaldo,pac_md_ctacliente.f_getdescripval(480, c.cmovimi, c.nrecibo) tmovimi,ff_desvalorfijo(481, pac_md_common.f_get_cxtidioma, cd.cmedmov) tmedmov,nvl(cd.nnumlin, 1) nnumlin2
	          FROM ctacliente c,caja_datmedio cd
	         WHERE c.cempres=pcempres AND
	               c.sperson=psperson AND
	               c.cmovimi<>6 AND
	               (c.cmovimi<>2  OR
	                c.seqcaja IS NOT NULL) AND
	               c.sproduc=nvl(v_sproduc, c.sproduc) AND
	               nvl(c.nrecibo, 1)<>0 AND
	               c.sseguro BETWEEN nvl(psseguro, 0) AND nvl(psseguro, 99999999) AND
	               c.ffecmov BETWEEN nvl(pfechaini, to_date('01/01/1001', 'dd/mm/yyyy')) AND nvl(pfechafin, to_date('01/01/8001', 'dd/mm/yyyy')) AND
	               nvl(c.cmovimi, -1) BETWEEN nvl(pcmovimi, -1) AND nvl(pcmovimi, 9999)
	               /*AND NVL(c.iimpope, 0) BETWEEN NVL(pimporte, -999999999999999999)*/
	               /*                         AND NVL(pimporte, 999999999999999999)*/
	               AND
	               cd.seqcaja(+)=c.seqcaja
	         GROUP BY nvl(cd.nrefdeposito, 0),nvl(c.seqcaja, 0),c.cempres,c.sperson,c.sseguro,c.sproduc,c.nnumlin,c.ffecmov,nvl(cd.fautori, c.ffecval),c.ffecval,c.cmovimi,c.tdescri,cd.cmedmov,pac_eco_monedas.f_obtener_moneda_seguro2(c.sseguro),c.cmoneda,pac_eco_monedas.f_obtener_moneda_defecto,c.fcambio,pac_md_ctacliente.f_getdescripval(480, c.cmovimi, c.nrecibo),ff_desvalorfijo(481, pac_md_common.f_get_cxtidioma, cd.cmedmov),c.sproces,nvl(cd.nnumlin, 1)
	        HAVING SUM(nvl(c.iimpope, 0)) BETWEEN nvl(pimporte, -999999999999999999) AND nvl(pimporte, 999999999999999999)
	        UNION
	        SELECT nvl(cd.nrefdeposito, 0) nrefdeposito,nvl(c.seqcaja, 0) seqcaja,c.cempres,c.sperson,c.sseguro,c.sproduc,(SELECT max(nnumlin)
	                                                                                                                         FROM ctacliente
	                                                                                                                        WHERE cempres=c.cempres AND
	                                                                                                                              sperson=c.sperson AND
	                                                                                                                              sseguro=c.sseguro AND
	                                                                                                                              ffecmov=c.ffecmov AND
	                                                                                                                              ffecval=c.ffecval AND
	                                                                                                                              cmovimi=c.cmovimi AND
	                                                                                                                              tdescri=c.tdescri AND
	                                                                                                                              fcambio=c.fcambio AND
	                                                                                                                              (sproces=c.sproces  OR
	                                                                                                                               sproces IS NULL)) nnumlin,c.ffecmov,nvl(cd.fautori, c.ffecval) ffecval,c.cmovimi,c.tdescri,cd.cmedmov,pac_eco_monedas.f_obtener_moneda_seguro2(c.sseguro) cmonedapro,SUM(c.iimppro) iimppro,pac_eco_monedas.f_obtener_cmonint(c.cmoneda) cmoneda,SUM(c.iimpope) iimpope,pac_eco_monedas.f_obtener_moneda_defecto() cmonedains,SUM(c.iimpins) iimpins,c.fcambio,pac_monedas.f_round (((SELECT max(isaldo_prod)
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       FROM ctacliente
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      WHERE cempres=c.cempres AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            sperson=c.sperson AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            sseguro=c.sseguro AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            ffecmov=c.ffecmov AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            ffecval=c.ffecval AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            cmovimi=c.cmovimi AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            tdescri=c.tdescri AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            fcambio=c.fcambio AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            (sproces=c.sproces  OR
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             sproces IS NULL))*(pac_eco_tipocambio.f_cambio (pac_eco_monedas.f_obtener_moneda_seguro2(c.sseguro), pac_eco_monedas.f_obtener_moneda_defecto, trunc(f_sysdate)))), pac_eco_monedas.f_obtener_cmoneda (pac_eco_monedas.f_obtener_moneda_defecto)) isaldo,pac_md_ctacliente.f_getdescripval(480, c.cmovimi, c.nrecibo) tmovimi,ff_desvalorfijo(481, pac_md_common.f_get_cxtidioma, cd.cmedmov) tmedmov,nvl(cd.nnumlin, 1) nnumlin2
	          FROM ctacliente c,caja_datmedio cd,tomadores t
	         WHERE c.cempres=pcempres AND
	               c.sperson=t.sperson AND
	               c.cmovimi<>6 AND
	               (c.cmovimi<>2  OR
	                c.seqcaja IS NOT NULL) AND
	               c.sproduc=nvl(v_sproduc, c.sproduc) AND
	               nvl(c.nrecibo, 1)<>0 AND
	               t.sseguro BETWEEN nvl(psseguro, 0) AND nvl(psseguro, 99999999) AND
	               c.sseguro BETWEEN nvl(psseguro, 0) AND nvl(psseguro, 99999999) AND
	               c.ffecmov BETWEEN nvl(pfechaini, to_date('01/01/1001', 'dd/mm/yyyy')) AND nvl(pfechafin, to_date('01/01/8001', 'dd/mm/yyyy')) AND
	               nvl(c.cmovimi, -1) BETWEEN nvl(pcmovimi, -1) AND nvl(pcmovimi, 9999)
	               /*AND NVL(c.iimpope, 0) BETWEEN NVL(pimporte, -999999999999999999)*/
	               /*                         AND NVL(pimporte, 999999999999999999)*/
	               AND
	               cd.seqcaja(+)=c.seqcaja
	         GROUP BY nvl(cd.nrefdeposito, 0),nvl(c.seqcaja, 0),c.cempres,c.sperson,c.sseguro,c.sproduc,c.nnumlin,c.ffecmov,nvl(cd.fautori, c.ffecval),c.ffecval,c.cmovimi,c.tdescri,cd.cmedmov,pac_eco_monedas.f_obtener_moneda_seguro2(c.sseguro),c.cmoneda,pac_eco_monedas.f_obtener_moneda_defecto,c.fcambio,pac_md_ctacliente.f_getdescripval(480, c.cmovimi, c.nrecibo),ff_desvalorfijo(481, pac_md_common.f_get_cxtidioma, cd.cmedmov),c.sproces,nvl(cd.nnumlin, 1)
	        HAVING SUM(nvl(c.iimpope, 0)) BETWEEN nvl(pimporte, -999999999999999999) AND nvl(pimporte, 999999999999999999)
	         ORDER BY nnumlin DESC;

	    ELSE
	      OPEN cur FOR
	        SELECT nvl(cd.nrefdeposito, 0) nrefdeposito,nvl(c.seqcaja, 0) seqcaja,c.cempres,c.sperson,c.sseguro,c.sproduc,(SELECT max(nnumlin)
	                                                                                                                         FROM ctacliente
	                                                                                                                        WHERE cempres=c.cempres AND
	                                                                                                                              sperson=c.sperson AND
	                                                                                                                              sseguro=c.sseguro AND
	                                                                                                                              ffecmov=c.ffecmov AND
	                                                                                                                              ffecval=c.ffecval AND
	                                                                                                                              cmovimi=c.cmovimi AND
	                                                                                                                              tdescri=c.tdescri AND
	                                                                                                                              fcambio=c.fcambio AND
	                                                                                                                              (sproces=c.sproces  OR
	                                                                                                                               sproces IS NULL)) nnumlin,c.ffecmov,nvl(cd.fautori, c.ffecval) ffecval,c.cmovimi,c.tdescri,cd.cmedmov,pac_eco_monedas.f_obtener_moneda_seguro2(c.sseguro) cmonedapro,SUM(c.iimppro) iimppro,pac_eco_monedas.f_obtener_cmonint(c.cmoneda) cmoneda,SUM(c.iimpope) iimpope,pac_eco_monedas.f_obtener_moneda_defecto() cmonedains,SUM(c.iimpins) iimpins,c.fcambio,pac_monedas.f_round (((SELECT max(isaldo_prod)
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       FROM ctacliente
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      WHERE cempres=c.cempres AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            sperson=c.sperson AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            sseguro=c.sseguro AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            ffecmov=c.ffecmov AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            ffecval=c.ffecval AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            cmovimi=c.cmovimi AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            tdescri=c.tdescri AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            fcambio=c.fcambio AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            (sproces=c.sproces  OR
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             sproces IS NULL))*(pac_eco_tipocambio.f_cambio (pac_eco_monedas.f_obtener_moneda_seguro2(c.sseguro), pac_eco_monedas.f_obtener_moneda_defecto, trunc(f_sysdate)))), pac_eco_monedas.f_obtener_cmoneda (pac_eco_monedas.f_obtener_moneda_defecto)) isaldo,pac_md_ctacliente.f_getdescripval(480, c.cmovimi, c.nrecibo) tmovimi,ff_desvalorfijo(481, pac_md_common.f_get_cxtidioma, cd.cmedmov) tmedmov,nvl(cd.nnumlin, 1) nnumlin2
	          FROM ctacliente c,caja_datmedio cd
	         WHERE c.cempres=pcempres AND
	               c.sperson=psperson AND
	               c.cmovimi<>6 AND
	               c.sproduc=nvl(v_sproduc, c.sproduc)
	               /*AND NVL(c.nrecibo, 1) <> 0*/
	               AND
	               c.sseguro BETWEEN nvl(psseguro, 0) AND nvl(psseguro, 99999999) AND
	               c.ffecmov BETWEEN nvl(pfechaini, to_date('01/01/1001', 'dd/mm/yyyy')) AND nvl(pfechafin, to_date('01/01/8001', 'dd/mm/yyyy')) AND
	               nvl(c.cmovimi, -1) BETWEEN nvl(pcmovimi, -1) AND nvl(pcmovimi, 9999)
	               /*AND NVL(c.iimpope, 0) BETWEEN NVL(pimporte, -999999999999999999)*/
	               /*                         AND NVL(pimporte, 999999999999999999)*/
	               AND
	               cd.seqcaja(+)=c.seqcaja
	         GROUP BY nvl(cd.nrefdeposito, 0),nvl(c.seqcaja, 0),c.cempres,c.sperson,c.sseguro,c.sproduc,c.nnumlin,c.ffecmov,nvl(cd.fautori, c.ffecval),c.ffecval,c.cmovimi,c.tdescri,cd.cmedmov,pac_eco_monedas.f_obtener_moneda_seguro2(c.sseguro),c.cmoneda,pac_eco_monedas.f_obtener_moneda_defecto,c.fcambio,pac_md_ctacliente.f_getdescripval(480, c.cmovimi, c.nrecibo),ff_desvalorfijo(481, pac_md_common.f_get_cxtidioma, cd.cmedmov),c.sproces,nvl(cd.nnumlin, 1)
	        HAVING SUM(nvl(c.iimpope, 0)) BETWEEN nvl(pimporte, -999999999999999999) AND nvl(pimporte, 999999999999999999)
	         ORDER BY c.nnumlin DESC;
	    END IF;

	    vpasexec:=20;

	    datctacli:=cur;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN 1;
	END f_obtenermovimientos;
	FUNCTION f_obtenerpolizas(
			sperson per_personas.sperson%TYPE,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN SYS_REFCURSOR
	IS
	  vpasexec NUMBER(8):=1;
	  vparam   VARCHAR2(2000):='sperson= '
	                         || sperson;
	  vobject  VARCHAR2(200):='pac_md_ctacliente.f_obtenerpolizas';
	  cur      SYS_REFCURSOR;
	BEGIN
	    cur:=pac_ctacliente.f_obtenerpolizas(sperson, mensajes);

	    RETURN cur;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

	             RETURN NULL; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

	             RETURN NULL; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN cur;
	END f_obtenerpolizas;
	FUNCTION f_obtenerpersonas(
			psseguro seguros.sseguro%TYPE,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN SYS_REFCURSOR
	IS
	  vpasexec NUMBER(8):=1;
	  vparam   VARCHAR2(2000):='psseguro= '
	                         || psseguro;
	  vobject  VARCHAR2(200):='pac_md_ctacliente.f_obtenerpolizas';
	  cur      SYS_REFCURSOR;
	BEGIN
	    cur:=pac_ctacliente.f_obtenerpersonas(psseguro, mensajes);

	    RETURN cur;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

	             RETURN NULL; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

	             RETURN NULL; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN cur;
	END f_obtenerpersonas;
	FUNCTION f_getdescripval(
			clave	IN	NUMBER,
			valor	IN	NUMBER,
			pnrecibo	IN	NUMBER DEFAULT NULL
	) RETURN VARCHAR2
	IS
	  mensajes  T_IAX_MENSAJES:=t_iax_mensajes();
	  v_ret     VARCHAR2(500):=NULL;
	  v_ctiprec NUMBER;
	  v_valor   NUMBER:=valor;
    V_SPRODUC NUMBER;
    V_IMPORTE NUMBER;
  BEGIN
	    IF pnrecibo IS NOT NULL THEN
        SELECT S.SPRODUC
          INTO V_SPRODUC
          FROM SEGUROS S, RECIBOS R
          WHERE S.SSEGURO = R.SSEGURO
            AND R.NRECIBO = pnrecibo;

        BEGIN
	          SELECT r.ctiprec
	            INTO v_ctiprec
	            FROM recibos r
	           WHERE r.nrecibo=pnrecibo;

	           IF v_ctiprec=12 THEN
                SELECT SUM(NVL(vm.itotalr, v.itotalr))
                   INTO v_importe
                   FROM vdetrecibos v, vdetrecibos_monpol vm
                  WHERE v.nrecibo = pnrecibo
                    AND vm.nrecibo(+) = v.nrecibo;

                IF V_IMPORTE = NVL(PAC_PARAMETROS.F_PARPRODUCTO_N(V_SPRODUC, 'REFUND_FEE_POLICY'), 200)/100 THEN
                   v_ctiprec := 11;
                END IF;
                v_valor:=v_ctiprec;
            END IF;
	      EXCEPTION
	          WHEN OTHERS THEN
	            v_valor:=valor;
	      END;
	    END IF;
	    v_ret:=pac_md_listvalores.f_getdescripvalores(clave, v_valor, mensajes);

	    RETURN v_ret;
	END f_getdescripval;

	/*BUG: 33886/199827*/
	FUNCTION f_transferible_spl(
			psseguro NUMBER,
			mensajes	OUT	T_IAX_MENSAJES
	) /*RDD 22/04/2015*/
	RETURN NUMBER
	IS
	  vnumerr  NUMBER;
	  vpasexec NUMBER(8):=1;
	  vobject  VARCHAR2(200):='PAC_MD_CAJA.f_upd_pagos_masivo';
	  vtmsg    VARCHAR2(4000);
	  vparam   VARCHAR2(1000):='sseguro'
	                         || psseguro;
	BEGIN
	    vpasexec:=1;

	    vnumerr:=pac_ctacliente.f_transferible_spl(psseguro);

	    RETURN vnumerr;
	EXCEPTION
	  WHEN e_param_error THEN
	             ROLLBACK;

	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);

	             RETURN vnumerr; WHEN OTHERS THEN
	             ROLLBACK;

	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_transferible_spl;
	FUNCTION f_apunte_pago_spl(
			pcempres	IN	NUMBER,
			psseguro	IN	NUMBER,
			pimporte	IN	NUMBER,
			pncheque	IN	VARCHAR2 DEFAULT NULL,
			pcestchq	IN	NUMBER DEFAULT NULL,
			pcbanco	IN	NUMBER DEFAULT NULL,
			pccc	IN	VARCHAR2 DEFAULT NULL,
			pctiptar	IN	NUMBER DEFAULT NULL,
			pntarget	IN	NUMBER DEFAULT NULL,
			pfcadtar	IN	VARCHAR2 DEFAULT NULL,
			pcmedmov	IN	NUMBER DEFAULT NULL,
			pcmoneop	IN	NUMBER DEFAULT 1,
			pnrefdeposito	IN	NUMBER DEFAULT NULL,
			pcautoriza	IN	NUMBER DEFAULT NULL,
			pnultdigtar	IN	NUMBER DEFAULT NULL,
			pncuotas	IN	NUMBER DEFAULT NULL,
			pccomercio	IN	NUMBER DEFAULT NULL,
			pdsbanco	IN	VARCHAR2 DEFAULT NULL,
			pctipche	IN	NUMBER DEFAULT NULL,
			pctipched	IN	NUMBER DEFAULT NULL,
			pcrazon	IN	NUMBER DEFAULT NULL,
			pdsmop	IN	VARCHAR2 DEFAULT NULL,
			pfautori	IN	DATE DEFAULT NULL,
			pcestado	IN	NUMBER DEFAULT NULL,
			psseguro_d	IN	NUMBER DEFAULT NULL,
			pseqcaja_o	IN	NUMBER DEFAULT NULL,
			psperson	IN	NUMBER DEFAULT NULL,
			mensajes	IN	OUT T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vnumerr   NUMBER;
	  vpasexec  NUMBER(8):=1;
	  vparam    VARCHAR2(2000):='';
	  vobject   VARCHAR2(200):='pac_iax_caja.f_apunte_pago_spl';
	  v_seqcaja NUMBER;
	BEGIN
	    vpasexec:=2;

	    vnumerr:=pac_ctacliente.f_apunte_pago_spl(pcempres, psseguro, pimporte, pncheque, pcestchq, pcbanco, pccc, pctiptar, pntarget, pfcadtar, pcmedmov, pcmoneop, pnrefdeposito, pcautoriza, pnultdigtar, pncuotas, pccomercio, pdsbanco, pctipche, pctipched, pcrazon, pdsmop, pfautori, pcestado, psseguro_d, pseqcaja_o, psperson, v_seqcaja);

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    RETURN vnumerr;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

	             RETURN NULL; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);

	             RETURN NULL; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             RETURN NULL;
	END f_apunte_pago_spl;

	/*Bug 33886/199825 ACL*/
	FUNCTION f_lee_ult_re(
			pnpoliza	IN	seguros.npoliza%TYPE,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN SYS_REFCURSOR
	IS
	  vpasexec  NUMBER(8):=1;
	  vparam    VARCHAR2(2000):=' NPOLIZA ='
	                         || pnpoliza;
	  vobject   VARCHAR2(200):='pac_ctacliente.f_lee_ult_re';
	  cur       SYS_REFCURSOR;
	  v_sseguro NUMBER;
	BEGIN
	    cur:=pac_ctacliente.f_lee_ult_re(pnpoliza);

	    RETURN cur;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

	             RETURN NULL; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

	             RETURN NULL; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN cur;
	END f_lee_ult_re;

	/* Funcion que genera un recibo de gasto cuando se supere el max No de devoluciones*/
	FUNCTION f_crea_rec_gasto(
			psseguro	IN	seguros.sseguro%TYPE,
			pimonto	IN	NUMBER,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vpasexec NUMBER(8);
	  vparam   VARCHAR2(2000):='psseguro = '
	                         || psseguro
	                         || ' pimonto = '
	                         || pimonto;
	  terror   VARCHAR2(2000);
	  vobject  VARCHAR2(200):='PAC_MD_CTACLIENTE.f_crea_rec_gasto';
	  num_err  axis_literales.slitera%TYPE:=0;
	BEGIN
	    vpasexec:=1;

	    IF psseguro IS NULL  OR
	       pimonto IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=2;

	    num_err:=pac_ctacliente.f_crea_rec_gasto(psseguro, pimonto);

	    IF num_err!=0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);

	      RAISE e_object_error;
	    END IF;

	    RETURN num_err;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             RETURN 1;
	END f_crea_rec_gasto;

	/*Bug 33886/199825 ACL*/
	FUNCTION f_upd_nre(
			pcempres	IN	NUMBER,
			psperson	IN	NUMBER,
			psseguro	IN	NUMBER,
			pnnumlin	IN	NUMBER,
			pnreembo	IN	NUMBER,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vnumerr  NUMBER;
	  vpasexec NUMBER(8):=1;
	  vparam   VARCHAR2(2000):='CEMPRES = '
	                         || pcempres
	                         || ' SPERSON = '
	                         || psperson
	                         || ' SSEGURO ='
	                         || psseguro
	                         || ' nnumlin = '
	                         || pnnumlin;
	  vobject  VARCHAR2(200):='pac_ctacliente.f_upd_nre';
	BEGIN
	    vpasexec:=1;

	    vnumerr:=pac_ctacliente.f_upd_nre(pcempres, psperson, psseguro, pnnumlin, pnreembo);

	    IF vnumerr<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);

	      RAISE e_object_error;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);

	             RETURN vnumerr; WHEN OTHERS THEN
	             ROLLBACK;

	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_upd_nre;

	/* Bug 33886/202377*/
	/* Función que recupera el numero de reembolsos de una poliza*/
	FUNCTION f_get_nroreembolsos(
			psseguro	IN	caja_datmedio.sseguro%TYPE,
			pnumreembo	OUT	NUMBER,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vpasexec NUMBER(8);
	  vparam   VARCHAR2(2000):='psseguro = '
	                         || psseguro;
	  terror   VARCHAR2(2000);
	  vobject  VARCHAR2(200):='PAC_MD_CTACLIENTE.f_get_nroreembolsos';
	  num_err  axis_literales.slitera%TYPE:=0;
	BEGIN
	    vpasexec:=1;

	    IF psseguro IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=2;

	    num_err:=pac_ctacliente.f_get_nroreembolsos(psseguro, pnumreembo);

	    IF num_err!=0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);

	      RAISE e_object_error;
	    END IF;

	    RETURN num_err;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             RETURN 1;
	END f_get_nroreembolsos;

	/* Bug 33886/202377*/
	/* Función que actualiza el numero de reembolsos de una poliza*/
	FUNCTION f_actualiza_nroreembol(
			psseguro	IN	caja_datmedio.sseguro%TYPE,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vpasexec NUMBER(8);
	  vparam   VARCHAR2(2000):='psseguro = '
	                         || psseguro;
	  terror   VARCHAR2(2000);
	  vobject  VARCHAR2(200):='PAC_MD_CTACLIENTE.f_actualiza_nroreembol';
	  num_err  axis_literales.slitera%TYPE:=0;
	BEGIN
	    vpasexec:=1;

	    IF psseguro IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=2;

	    num_err:=pac_ctacliente.f_actualiza_nroreembol(psseguro);

	    IF num_err!=0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);

	      RAISE e_object_error;
	    END IF;

	    RETURN num_err;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             RETURN 1;
	END f_actualiza_nroreembol;
	FUNCTION f_obtener_movimientos_cmovimi6(
			pseqcaja	IN	NUMBER,
			datctacli	IN	OUT SYS_REFCURSOR,
			mensajes	IN	OUT T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vpasexec NUMBER(8):=1;
	  vparam   VARCHAR2(200):='pseqcaja:'
	                        || pseqcaja;
	  vobject  VARCHAR2(200):='PAC_MD_CTACLIENTE.f_obtener_movimientos_cmovimi6';
	  reg_seg  seguros%ROWTYPE;
	  v_norden NUMBER;
	  tmovimi  VARCHAR2(400);
	  tmedmov  VARCHAR2(400);
	  cuantos  NUMBER;
	  cur      SYS_REFCURSOR;
	BEGIN
	    IF pseqcaja IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=2;

	    OPEN cur FOR
	      SELECT nvl(cd.nrefdeposito, 0) nrefdeposito,nvl(c.seqcaja, 0) seqcaja,c.cempres,c.sperson,c.sseguro,c.sproduc,(SELECT max(nnumlin)
	                                                                                                                       FROM ctacliente
	                                                                                                                      WHERE cempres=c.cempres AND
	                                                                                                                            sperson=c.sperson AND
	                                                                                                                            sseguro=c.sseguro AND
	                                                                                                                            ffecmov=c.ffecmov AND
	                                                                                                                            ffecval=c.ffecval AND
	                                                                                                                            cmovimi=c.cmovimi AND
	                                                                                                                            tdescri=c.tdescri AND
	                                                                                                                            fcambio=c.fcambio AND
	                                                                                                                            (sproces=c.sproces  OR
	                                                                                                                             sproces IS NULL)) nnumlin,c.ffecmov,nvl(cd.fautori, c.ffecval) ffecval,c.cmovimi,c.tdescri,cd.cmedmov,pac_eco_monedas.f_obtener_moneda_seguro2(c.sseguro) cmonedapro,SUM(c.iimppro) iimppro,pac_eco_monedas.f_obtener_cmonint(c.cmoneda) cmoneda,SUM(c.iimpope) iimpope,pac_eco_monedas.f_obtener_moneda_defecto () cmonedains,SUM(c.iimpins) iimpins,c.fcambio,pac_monedas.f_round (((SELECT max(isaldo_prod)
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      FROM ctacliente
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     WHERE cempres=c.cempres AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           sperson=c.sperson AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           sseguro=c.sseguro AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           ffecmov=c.ffecmov AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           ffecval=c.ffecval AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           cmovimi=c.cmovimi AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           tdescri=c.tdescri AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           fcambio=c.fcambio AND
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           (sproces=c.sproces  OR
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            sproces IS NULL))*(pac_eco_tipocambio.f_cambio (pac_eco_monedas.f_obtener_moneda_seguro2(c.sseguro), pac_eco_monedas.f_obtener_moneda_defecto, trunc(f_sysdate)))), pac_eco_monedas.f_obtener_cmoneda (pac_eco_monedas.f_obtener_moneda_defecto)) isaldo,pac_md_ctacliente.f_getdescripval(480, c.cmovimi, c.nrecibo) tmovimi,ff_desvalorfijo(481, pac_md_common.f_get_cxtidioma, cd.cmedmov) tmedmov,nvl(cd.nnumlin, 1) nnumlin2
	        FROM ctacliente c,caja_datmedio cd
	       WHERE c.seqcaja=pseqcaja AND
	             c.cmovimi=6 AND
	             nvl(c.nrecibo, 1)<>0 AND
	             cd.seqcaja(+)=c.seqcaja
	       GROUP BY nvl(cd.nrefdeposito, 0),nvl(c.seqcaja, 0),c.cempres,c.sperson,c.sseguro,c.sproduc,c.nnumlin,c.ffecmov,nvl(cd.fautori, c.ffecval),c.ffecval,c.cmovimi,c.tdescri,cd.cmedmov,pac_eco_monedas.f_obtener_moneda_seguro2(c.sseguro),c.cmoneda,pac_eco_monedas.f_obtener_moneda_defecto,c.fcambio,pac_md_ctacliente.f_getdescripval(480, c.cmovimi, c.nrecibo),ff_desvalorfijo(481, pac_md_common.f_get_cxtidioma, cd.cmedmov),c.sproces,nvl(cd.nnumlin, 1)
	       ORDER BY nnumlin DESC;

	    vpasexec:=20;

	    datctacli:=cur;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN 1;
	END f_obtener_movimientos_cmovimi6;

END pac_md_ctacliente;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_CTACLIENTE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CTACLIENTE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CTACLIENTE" TO "PROGRAMADORESCSI";
