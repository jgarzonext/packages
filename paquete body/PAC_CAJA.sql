CREATE OR REPLACE PACKAGE BODY pac_caja IS

   /******************************************************************************
     NOMBRE:     PAC_CAJA
     PROPOSITO:  Funciones de la Gestion de Caja

     REVISIONES:
     Ver        Fecha        Autor             Descripcion
     ---------  ----------  ---------------  ------------------------------------
     1.0        20/02/2013   XXX                1. Creacion del package.
     2.0        10-10-2013   JMF              0028517: RSA998 - CAJA. Pago de recibos requiere recaudacion
     3.0        16-04-2015   YDA              Se crea la funcion f_lee_cajamov
     4.0        29/04/2015   YDA              Se crea la funcion f_delmovcaja_spl
     5.0        29/04/2015   YDA              Se crea la funcion f_insmovcaja_apply
     6.0        04/05/2015   YDA              Se crea la funcion f_lee_datmedio_reembolso
     7.0        25/06/2015   MMS              7. 0032660: COLM004-Permitir el pago por caja con tarjeta
     7.0        09/11/2015   BLA              7. 33886/216010 MSV se  adiciona select en la funcion f_lee_datmedio_reembolso.
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   gidioma        NUMBER := pac_md_common.f_get_cxtidioma;
   gempres        NUMBER := pac_md_common.f_get_cxtempresa;

   /* Bug 0032660/0190245 - 12/11/2014 - JMF*/
   /* Validar Si el importe supera los ingresos en efectivo realizados en la fecha y moneda de la operacion*/

	FUNCTION f_validaingresoefectivo(
			pffecmov	IN	DATE,
			pcmoneop	IN	NUMBER,
			pimovimi	IN	NUMBER
	) RETURN NUMBER
	IS
	  /**/
	  v_aux NUMBER;
	BEGIN
	    SELECT nvl(SUM(b.imovimi), 0)
	      INTO v_aux
	      FROM cajamov a,caja_datmedio b
	     WHERE a.ctipmov IN(0, 3) AND
	           a.ffecmov=pffecmov AND
	           a.cmoneop=pcmoneop AND
	           b.seqcaja=a.seqcaja AND
	           b.cmedmov=0;

	    IF pimovimi>v_aux THEN
	      RETURN 9907193;
	    ELSE
	      RETURN 0;
	    END IF;
	END;

	/******************************************************************************
	   NOMBRE:     F_INSMVTOCAJA
	   PROPOSITO:  Funcion que inserta movimientos en caja
	               Si es un pago que realiza un agente, es decir, MASIVO No grabará
	               en la CTACLIENTE de la persona.
	               Si viene infomado el sproduc o sseguro --> paga un cliente
	               Si no viene informado sproduc/sseguro --> paga agente
	   PARAMETROS:

	        return            : 0 -> Todo correcto
	                            1 -> Se ha producido un error

	 -- Bug 0032660/0190245 - 12/11/2014 - JMF : pcmanual
	 *****************************************************************************/
	FUNCTION f_insmvtocaja(
			pcempres	IN	NUMBER,
			pcusuari	IN	VARCHAR2,
			psperson	IN	NUMBER,
			pffecmov	IN	DATE,
			pctipmov	IN	NUMBER,
			pimovimi	IN	NUMBER,
			pcmoneop	IN	NUMBER,
			pseqcaja	OUT	NUMBER,
			piautliq	IN	NUMBER DEFAULT NULL,
			pipagsin	IN	NUMBER DEFAULT NULL,
			piautliqp	IN	NUMBER DEFAULT NULL,
			pidifcambio	IN	NUMBER DEFAULT NULL,
			pfcambio	IN	DATE DEFAULT NULL,
			pcmanual	IN	NUMBER DEFAULT 1,
			pcusuapunte	IN	VARCHAR2 DEFAULT NULL,
			ptmotapu	IN	VARCHAR2 DEFAULT NULL
	) RETURN NUMBER
	IS
	  /**/
	  vparam    VARCHAR2(2000):='CEMPRES='
	                         || pcempres
	                         || ' USUARI = '
	                         || pcusuari
	                         || ' SPERSON = '
	                         || psperson
	                         || ' FFECMOV ='
	                         || pffecmov
	                         || ' CTIPMOV ='
	                         || pctipmov
	                         || ' IMOVIMI ='
	                         || pimovimi
	                         || ' IAUTLIQ ='
	                         || piautliq
	                         || ' IPAGSIN ='
	                         || pipagsin
	                         || ' CMONEOP ='
	                         || pcmoneop
	                         || ' IAUTLIQ Partner ='
	                         || piautliqp
	                         || ' DifCambio = '
	                         || pidifcambio
	                         /* Bug 0032660/0190245 - 12/11/2014 - JMF*/
	                         || ' pcmanual = '
	                         || pcmanual
	                         || ' usuapu='
	                         || pcusuapunte
	                         || ' motapu='
	                         || ptmotapu;
	  vobject   VARCHAR2(200):='PAC_CAJA.f_insmvtocaja';
	  terror    VARCHAR2(200);
	  vpasexec  NUMBER(8):=1;
	  num_err   axis_literales.slitera%TYPE:=0;
	  /**/
	  lmoneinst seguros.cmoneda%TYPE;
	  litasa    eco_tipocambio.itasa%TYPE;
	  liimpins  cajamov.iimpins%TYPE;
	  liautins  cajamov.iautins%TYPE;
	  lipagins  cajamov.ipagins%TYPE;
	  liautinsp cajamov.iautinsp%TYPE;
	  d_cierre  cajamov.fcierre%TYPE;
	  v_fcierre cajamov.fcierre%TYPE;
	/**/
	BEGIN
	    vpasexec:=100;

	    /* Bug 0032660/0190245 - 12/11/2014 - JMF : saldoinicial*/
	    /* Bug 0032660/0190245 - 12/11/2014 - JMF : saldo para apuntes manuales*/
	    IF pcmanual=1 THEN
	      /*
	      Funcion que verifica si existe algún movimiento de tipo "Saldo inicial" (tipo movimiento = 3)
	      en la fecha de operacion actual y, si no existe, calcula el saldo del último día con operaciones
	      (anterior al actual) y, si es diferente de 0, inserta un registro en CAJAMOV de tipo movimiento 3
	      para la fecha de operacion actual.
	      */
	      vpasexec:=110;

	      num_err:=f_saldoinicial(pffecmov, pcmoneop, pcmanual, pcusuari); /* Bug 0032660 MMS 20150625*/

	      IF num_err<>0 THEN
	        RETURN num_err;
	      END IF;
	    END IF;

	    /* Bug 0032660/0190245 - 12/11/2014 - JMF : cierre*/
	    vpasexec:=120;

	    IF pctipmov=3 AND
	       pcmanual=0 THEN
	      d_cierre:=trunc(f_sysdate);
	    ELSE
	      d_cierre:=NULL;
	    END IF;

	    /**/
	    /* Si la moneda que nos pagan es diferente a la de la instalacion*/
	    /* buscamos el cambio a fecha movimiento*/
	    vpasexec:=130;

	    SELECT f_parinstalacion_n('MONEDAINST')
	      INTO lmoneinst
	      FROM dual;

	    IF lmoneinst<>pcmoneop THEN
	      vpasexec:=140;

	      litasa:=pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(pcmoneop), pac_monedas.f_cmoneda_t(lmoneinst), nvl(pfcambio, trunc(f_sysdate))); /*Bug.: 32665 - casanchez - 03/09/2014 - Se cambia el F_SYSDATE por el parametro pfcambio*/

	      IF litasa IS NULL THEN
	        RETURN 9902592;
	      /* RAISE e_param_error;*/
	      /* No se ha encontrado el tipo de cambio entre monedas*/
	      END IF;

	      vpasexec:=150;

	      liimpins:=pac_monedas.f_round(pimovimi*litasa, lmoneinst);

	      liautins:=pac_monedas.f_round(piautliq*litasa, lmoneinst);

	      lipagins:=pac_monedas.f_round(pipagsin*litasa, lmoneinst);

	      liautinsp:=pac_monedas.f_round(piautliqp*litasa, lmoneinst);
	    ELSE
	      vpasexec:=160;

	      liimpins:=pimovimi;

	      liautins:=piautliq;

	      lipagins:=pipagsin;

	      liautinsp:=piautliqp;
	    END IF;

	    /**/
	    vpasexec:=170;

	    SELECT seqcaja.NEXTVAL
	      INTO pseqcaja
	      FROM dual;

	    /**/
	    /* Bug 0032660/0190245 - 12/11/2014 - JMF : fcierre, CUSUAPUNTE, TMOTAPU*/
	    vpasexec:=180;

	    /* DCG 03/06/2015 INI*/
	    /*En el caso que tengamos un cierre realizado para el día del movimiento, el nuevo movimiento se insertará para el día siguiente;*/
	    BEGIN
	        SELECT nvl(max(ffecmov), pffecmov)
	          INTO v_fcierre
	          FROM cajamov
	         WHERE trunc(fcierre)=trunc(pffecmov) AND
	               cusuari=pcusuari;
	    EXCEPTION
	        WHEN OTHERS THEN
	          v_fcierre:=pffecmov;
	    END;

	    /* DCG 03/06/2015 FIN*/
			INSERT INTO cajamov
		           (seqcaja,cempres,cusuari,sperson,ffecmov,ctipmov,
		           imovimi,iautliq,ipagsin,cmoneop,iimpins,
		           fcambio,iautins,ipagins,iautliqp,iautinsp,
		           idifcambio,fcierre,cmanual,cusuapunte,tmotapu)

		    VALUES
		           (pseqcaja,pcempres,pcusuari,psperson,trunc(v_fcierre),pctipmov,
		           pimovimi,piautliq,pipagsin,pcmoneop,liimpins,
		           nvl(pfcambio, trunc(f_sysdate)),liautins,lipagins,piautliqp,
		           liautinsp,pidifcambio,d_cierre,pcmanual,pcusuapunte,
		           ptmotapu);


	    /**/
	    RETURN 0;
	/**/
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);

	             RETURN 102555; /* error al insertar el movimiento de caja*/
	END f_insmvtocaja;

	/* Bug 0032660/0190245 - 12/11/2014 - JMF*/
	FUNCTION f_saldoinicial(pfec	IN	DATE,pmon	IN	NUMBER,pman	IN	NUMBER,pcusuari	IN	VARCHAR2) /* Bug 0032660 MMS 20150625*/
	RETURN NUMBER
	IS
	  /**/
	  vobject   VARCHAR2(200):='PAC_CAJA.f_saldoinicial';
	  vparam    VARCHAR2(2000):='pfec='
	                         || pfec
	                         || ' pmon='
	                         || pmon
	                         || ' pman='
	                         || pman;
	  vpas      NUMBER:=1;
	  /**/
	  v_aux     NUMBER;
	  d_ult     DATE;
	  num_err   NUMBER;
	  v_seq     cajamov.seqcaja%TYPE;
	  /**/
	  lmoneinst seguros.cmoneda%TYPE;
	  litasa    eco_tipocambio.itasa%TYPE;
	  liimpins  cajamov.iimpins%TYPE;
	  liautins  cajamov.iautins%TYPE;
	  lipagins  cajamov.ipagins%TYPE;
	  liautinsp cajamov.iautinsp%TYPE;
	/**/
	BEGIN
	    /* Comprobar que no tenemos saldo para la fecha*/
	    vpas:=100;

	    SELECT count(1)
	      INTO v_aux
	      FROM cajamov
	     WHERE ctipmov=3 AND
	           cmanual=0 AND
	           trunc(ffecmov)>=trunc(pfec) AND
	           cmoneop=pmon AND
	           cusuari=pcusuari; /* Bug 0032660 MMS 20150625*/

	    IF v_aux>0 THEN
	      /* si existe, salimos*/
	      RETURN 0;
	    END IF;

	    /* Buscar el ultimo saldo anterior*/
	    vpas:=110;

	    SELECT nvl(max(ffecmov), to_date('20000101', 'yyyymmdd'))
	      INTO d_ult
	      FROM cajamov
	     WHERE ctipmov=3 AND
	           ffecmov<=pfec-1 AND
	           cmanual=0 AND
	           cmoneop=pmon AND
	           cusuari=pcusuari; /* Bug 0032660 MMS 20150625*/

	    /* Comprobar si tenemos algun movimiento entre las fechas*/
	    vpas:=120;

	    SELECT count(1)
	      INTO v_aux
	      FROM cajamov a,caja_datmedio b
	     WHERE a.ctipmov IN(0, 1, 2, 3, 4) AND
	           a.ffecmov BETWEEN d_ult AND pfec-1 AND
	           a.cmoneop=pmon AND
	           b.seqcaja=a.seqcaja AND
	           b.cmedmov=0 AND
	           a.cusuari=pcusuari; /* Bug 0032660 MMS 20150625*/

	    IF v_aux=0 THEN
	      /* no tenemos movimientos, salimos*/
	      RETURN 0;
	    END IF;

	    /* Calcular importe para efectivo*/
	    vpas:=130;

	    SELECT nvl(SUM(decode(a.ctipmov, 1, -1,
	                                     4, -1,
	                                     1)*b.imovimi), 0)
	      INTO v_aux
	      FROM cajamov a,caja_datmedio b
	     WHERE a.ctipmov IN(0, 1, 2, 3, 4) AND
	           a.ffecmov BETWEEN d_ult AND pfec-1 AND
	           a.cmoneop=pmon AND
	           b.seqcaja=a.seqcaja AND
	           b.cmedmov=0 AND
	           a.cusuari=pcusuari; /* Bug 0032660 MMS 20150625*/

	    IF v_aux=0 THEN
	      RETURN 0;
	    END IF;

	    /**/
	    /* Si la moneda que nos pagan es diferente a la de la instalacion*/
	    /* buscamos el cambio a fecha movimiento*/
	    vpas:=140;

	    SELECT f_parinstalacion_n('MONEDAINST')
	      INTO lmoneinst
	      FROM dual;

	    IF lmoneinst<>pmon THEN
	      vpas:=150;

	      litasa:=pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(pmon), pac_monedas.f_cmoneda_t(lmoneinst), trunc(f_sysdate)); /*Bug.: 32665 - casanchez - 03/09/2014 - Se cambia el F_SYSDATE por el parametro pfcambio*/

	      IF litasa IS NULL THEN
	        RETURN 9902592;
	      /* No se ha encontrado el tipo de cambio entre monedas*/
	      END IF;

	      vpas:=160;

	      liimpins:=pac_monedas.f_round(v_aux*litasa, lmoneinst);
	    /*liautins := pac_monedas.f_round(piautliq * litasa, lmoneinst);*/
	    /*lipagins := pac_monedas.f_round(pipagsin * litasa, lmoneinst);*/
	    /*liautinsp := pac_monedas.f_round(piautliqp * litasa, lmoneinst);*/
	    ELSE
	      liimpins:=v_aux;
	    /*liautins := piautliq;*/
	    /*lipagins := pipagsin;*/
	    /*liautinsp := piautliqp;*/
	    END IF;

	    vpas:=170;

	    SELECT seqcaja.NEXTVAL
	      INTO v_seq
	      FROM dual;

	    /**/
	    vpas:=180;

			INSERT INTO cajamov
		           (seqcaja,cempres,cusuari,sperson,ffecmov,ctipmov,
		           imovimi,iautliq,ipagsin,cmoneop,iimpins,
		           fcambio,iautins,ipagins,iautliqp,iautinsp,
		           idifcambio,cmanual)
		    VALUES
		           (v_seq,gempres,f_user,NULL,pfec,3,
		           v_aux,NULL,NULL,pmon,liimpins,
		           trunc(f_sysdate),NULL,NULL,NULL,NULL,
		           NULL,0);


	    vpas:=190;

	    num_err:=pac_caja.f_inscajadatmedio(v_seq, NULL, NULL, NULL, NULL, NULL, NULL, NULL, v_aux, 0, pmon, NULL);

	    RETURN num_err;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpas, vparam, SQLERRM);

	             RETURN 102555; /* error al insertar el movimiento de caja*/
	END f_saldoinicial;

	/******************************************************************************
	   NOMBRE:     F_INSCAJADATMEDIO
	   PROPOSITO:  Funcion que inserta el medio del movimientos en caja

	   PARAMETROS:

	        return            : 0 -> Todo correcto
	                            1 -> Se ha producido un error

	 *****************************************************************************/
	FUNCTION f_inscajadatmedio(
			pseqcaja	IN	NUMBER,
	pncheque	IN	VARCHAR2,
	pcestchq	IN	NUMBER,
	pcbanco	IN	NUMBER,
	pccc	IN	VARCHAR2,
	pctiptar	IN	NUMBER,
	pntarget	IN	VARCHAR2,
	pfcadtar	IN	VARCHAR2,
	pimovimi	IN	NUMBER DEFAULT NULL,
	pcmedmov	IN	NUMBER DEFAULT NULL,
	pcmoneop	IN	NUMBER DEFAULT NULL,
			 /* Bug 0032660/0190245 - 12/11/2014 - JMF*/
			 pnrefdeposito	IN	NUMBER DEFAULT NULL,
	pcautoriza	IN	NUMBER DEFAULT NULL,
	pnultdigtar	IN	NUMBER DEFAULT NULL,
	pncuotas	IN	NUMBER DEFAULT NULL,
	pccomercio	IN	NUMBER DEFAULT NULL,
			 /*33886/199825 ACL 23/04/2015*/
			 pdsbanco	IN	VARCHAR2 DEFAULT NULL,
	pctipche	IN	NUMBER DEFAULT NULL,
	pctipched	IN	NUMBER DEFAULT NULL,
	pcrazon	IN	NUMBER DEFAULT NULL,
	pdsmop	IN	VARCHAR2 DEFAULT NULL,
	pfautori	IN	DATE DEFAULT NULL,
	pcestado	IN	NUMBER DEFAULT NULL,
	psseguro	IN	NUMBER DEFAULT NULL,
	psseguro_d	IN	NUMBER DEFAULT NULL,
	pseqcaja_o	IN	NUMBER DEFAULT NULL,
	ptdescchk	IN	VARCHAR2 DEFAULT NULL
	)
	RETURN NUMBER
	IS
	  /**/
	  vparam    VARCHAR2(2000):='SEQCAJA='
	                         || pseqcaja
	                         || ' NCHEQUE = '
	                         || pncheque
	                         || ' CESTCHQ = '
	                         || pcestchq
	                         || ' CBANCO ='
	                         || pcbanco
	                         || ' CCC ='
	                         || pccc
	                         || ' CTIPTAR ='
	                         || pctiptar
	                         || ' NTARGET ='
	                         || pntarget
	                         || ' FCADTAR ='
	                         || pfcadtar
	                         || ' IMPORTE='
	                         || pimovimi
	                         || ' CMEDMOV ='
	                         || pcmedmov
	                         /* Bug 0032660/0190245 - 12/11/2014 - JMF*/
	                         || ' ref='
	                         || pnrefdeposito
	                         || ' aut='
	                         || pcautoriza
	                         || ' ult='
	                         || pnultdigtar
	                         || ' cuo='
	                         || pncuotas
	                         || ' com='
	                         || pccomercio
	                         /* Bug 33886/199825  ACL*/
	                         || 'PDSBANCO ='
	                         || pdsbanco
	                         || 'PCTIPCHED ='
	                         || pctipche
	                         || 'PCTIPCHED ='
	                         || pctipched
	                         || 'PCRAZON ='
	                         || pcrazon
	                         || 'PDSMOP ='
	                         || pdsmop
	                         || 'PFAUTORI ='
	                         || pfautori
	                         || 'CESTADO ='
	                         || pcestado
	                         || 'SSEGURO ='
	                         || psseguro
	                         || 'SSEGURO_D ='
	                         || psseguro_d
	                         || 'SEQCAJA_O ='
	                         || pseqcaja_o;
	  vobject   VARCHAR2(200):='PAC_CAJA.f_inscajadatmedio';
	  terror    VARCHAR2(200);
	  vpasexec  NUMBER(8):=1;
	  num_err   axis_literales.slitera%TYPE:=0;
	  lnnumlin  caja_datmedio.nnumlin%TYPE;
	  lmoneinst seguros.cmoneda%TYPE;
	  litasa    eco_tipocambio.itasa%TYPE;
	  liimpins  caja_datmedio.iimpins%TYPE;
	/**/
	BEGIN
	    vpasexec:=100;

	    /**/
	    BEGIN
	        SELECT nnumlin
	          INTO lnnumlin
	          FROM caja_datmedio
	         WHERE seqcaja=pseqcaja AND
	               nnumlin=(SELECT max(nnumlin)
	                          FROM caja_datmedio
	                         WHERE seqcaja=pseqcaja);
	    EXCEPTION
	        WHEN no_data_found THEN
	          lnnumlin:=0;
	        WHEN OTHERS THEN
	          lnnumlin:=0;
	    END;

	    vpasexec:=110;

	    SELECT f_parinstalacion_n('MONEDAINST')
	      INTO lmoneinst
	      FROM dual;

	    IF lmoneinst<>pcmoneop THEN
	      vpasexec:=120;

	      litasa:=pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(pcmoneop), pac_monedas.f_cmoneda_t(lmoneinst), trunc(f_sysdate));

	      IF litasa IS NULL THEN
	        num_err:=9902592;

	        RAISE e_object_error; /* Bug 0032660/0190245 - 12/11/2014 - JMF*/
	      /* No se ha encontrado el tipo de cambio entre monedas*/
	      END IF;

	      vpasexec:=130;

	      liimpins:=pac_monedas.f_round(pimovimi*litasa, lmoneinst);
	    ELSE
	      liimpins:=pimovimi;
	    END IF;

	    /**/
	    vpasexec:=140;

	    lnnumlin:=lnnumlin+1;

	    /**/
	    /* Bug 0032660/0190245 - 12/11/2014 - JMF : NREFDEPOSITO*/
	    vpasexec:=150;

			INSERT INTO caja_datmedio
		           (seqcaja,ncheque,cestchq,festchq,cbanco,ccc,
		           ctiptar,ntarget,fcadtar,imovimi,cmedmov,
		           nnumlin,iimpins,nrefdeposito,cautoriza,nultdigtar,
		           ncuotas,ccomercio,cestado,sseguro,sseguro_d,
		           crazon,seqcaja_o,dsmop,ctipche,dsbanco,
		           ctipched,fautori,tdescchk) /*RACS SE AÑ
		       AND
		E EL CAMPO FAUTORI*/
		    VALUES
		           (pseqcaja,pncheque,pcestchq,trunc(f_sysdate),pcbanco,pccc,
		           pctiptar,pntarget,pfcadtar,pimovimi,pcmedmov,
		           lnnumlin,liimpins,pnrefdeposito,pcautoriza,pnultdigtar,
		           pncuotas,pccomercio,pcestado,psseguro,psseguro_d,
		           pcrazon,pseqcaja_o,pdsmop,pctipche,pdsbanco,
		pctipched,pfautori,ptdescchk); /*RACS SE ENVIA EL PARAMETRO PFAUTORI*/


	    /* Si es un cheque, guardar estados*/
	    IF pcmedmov=1 AND
	       pncheque IS NOT NULL THEN
	      vpasexec:=160;

	      num_err:=pac_caja_cheque.f_insert_historico(pseqcaja, pncheque, pcestchq, 0, f_sysdate);

	      IF num_err<>0 THEN
	        RAISE e_object_error;
	      END IF;
	    END IF;

	    /**/
	    RETURN 0;
	/**/
	EXCEPTION
	  WHEN e_object_error THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, num_err
	                                                                       || f_axis_literales(num_err, gidioma));

	             RETURN num_err; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);

	             RETURN 102555; /* error al insertar el movimiento de caja*/
	END f_inscajadatmedio;

	/******************************************************************************
	   NOMBRE:     F_OBTENERMVTOCAJA
	   PROPOSITO:  Funcion que obtiene los movimientos de caja de un usuario en un
	               dia determinado

	   PARAMETROS:




	        return            : 0 -> Todo correcto
	                            1 -> Se ha producido un error

	 *****************************************************************************/
	FUNCTION f_obtenermvtocaja(
			pcusuari cajamov.cusuari%TYPE,
			pffecmov_ini cajamov.ffecmov%TYPE,
			pffecmov_fin cajamov.ffecmov%TYPE,
			pctipmov cajamov.ctipmov%TYPE,
			pcmedmov caja_datmedio.cmedmov%TYPE,
			pcidioma	IN	NUMBER,
			ptselect	OUT	VARCHAR2
	) RETURN NUMBER
	IS
	  vpasexec NUMBER(8):=1;
	  vparam   VARCHAR2(2000):='CUSUARI= '
	                         || pcusuari
	                         || ' Fecha_INI='
	                         || pffecmov_ini
	                         || ' Fecha_fin='
	                         || pffecmov_fin
	                         || ' ctipmov='
	                         || pctipmov
	                         || ' cmedmov='
	                         || pcmedmov;
	  vobject  VARCHAR2(200):='pac_caja.f_obtenermvtocaja';
	BEGIN
	/* Bug 32661/0189343 - 17/10/2014 - JMF : nrefdeposito*/
	/* Bug 32661/0189343 - 17/10/2014 - JMF : des cmoneop, des cestchq, TBANCO, cod_cmedmov*/
	    /* Bug 32661/0189343 - 17/10/2014 - JMF : clave, CAUTORIZA, NULTDIGTAR, NCUOTAS, CCOMERCIO*/
	    ptselect:='SELECT   t.seqcaja, t.cempres, t.cusuari, f_nombre(u.sperson,1) tusuari, t.ffecmov,
		                            ff_desvalorfijo(482, '
	              || pcidioma
	              || ', t.ctipmov) ctipmov,
		                            m.imovimi, t.iautliq, t.ipagsin,
		                            (select max(b.TMONEDA)
		                             from  monedas a, eco_desmonedas b
		                             where a.CMONEDA = t.cmoneop
		                             and   a.CIDIOMA = '
	              || pcidioma
	              || '
		                             and   b.CMONEDA = a.CMONINT
		                             and   b.CIDIOMA = a.CIDIOMA
		                            ) cmoneop,
		                            t.iimpins, t.fcambio,
		                            m.cmedmov cod_cmedmov,
		                            ff_desvalorfijo(481, '
	              || pcidioma
	              || ', m.cmedmov) cmedmov,
		                            t.fcierre, m.ncheque,
		                            ff_desvalorfijo(483, '
	              || pcidioma
	              || ', m.cestchq) cestchq,
		                            f_nombre(t.sperson,1) cliente, m.nrefdeposito,
		                            (select max(TBANCO) from bancos  where cbanco=m.CBANCO) TBANCO,
		                            t.seqcaja||''-''||m.NNUMLIN clave,
		                            m.CAUTORIZA, m.NULTDIGTAR, m.NCUOTAS, m.CCOMERCIO
		           FROM CAJAMOV t, CAJA_DATMEDIO m, usuarios u
		          WHERE t.cusuari = '''
	              || pcusuari
	              || '''
		            AND t.seqcaja = m.seqcaja
		            AND t.cusuari = u.cusuari ';

	    IF pffecmov_ini IS NOT NULL THEN
	      ptselect:=ptselect
	                || ' AND t.ffecmov >= TO_DATE('''
	                || pffecmov_ini
	                || ''', ''DD/MM/YY'')';
	    END IF;

	    IF pffecmov_fin IS NOT NULL THEN
	      ptselect:=ptselect
	                || ' AND t.ffecmov <= TO_DATE('''
	                || pffecmov_fin
	                || ''', ''DD/MM/YY'')';
	    END IF;

	    IF pctipmov IS NOT NULL THEN
	      ptselect:=ptselect
	                || ' AND t.ctipmov = '
	                || pctipmov;
	    END IF;

	    IF pcmedmov IS NOT NULL THEN
	      ptselect:=ptselect
	                || ' AND m.cmedmov = '
	                || pcmedmov;
	    END IF;

	    ptselect:=ptselect
	              || ' ORDER BY t.seqcaja';

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);

	             RETURN 'SELECT 1 FROM DUAL';
	END f_obtenermvtocaja;

	/******************************************************************************
	   NOMBRE:     F_INS_PAGOS_MASIVO
	   PROPOSITO:  Funcion que inserta totalizando para una misma carga (fichero)
	               los importes del pago por Agente, moneda de pago y fecha.

	   PARAMETROS:


	        return            : 0 -> Todo correcto
	                            1 -> Se ha producido un error

	 *****************************************************************************/
	FUNCTION f_ins_pagos_masivo(
			psproces	IN	NUMBER,
			pfcarga	IN	DATE,
			ptfichero	IN	VARCHAR2
	) RETURN NUMBER
	IS
	  /**/
	  vpasexec      NUMBER(8):=1;
	  vparam        VARCHAR2(2000):='SPROCES ='
	                         || psproces
	                         || ' FCARGA='
	                         || pfcarga
	                         || ' TFICHERO ='
	                         || ptfichero;
	  vobject       VARCHAR2(200):='pac_caja.f_ins_pagos_masivo';
	  terror        VARCHAR2(200);
	  num_err       axis_literales.slitera%TYPE:=0;
	  v_terror      VARCHAR2(2000);
	  /**/
	  v_isobrante   pagos_masivos_sobrante.saldo%TYPE;
	  v_seqcaja     cajamov.seqcaja%TYPE;
	  v_pag_antes   NUMBER;
	  v_pag_despues NUMBER;
	  v_pag_difer   NUMBER;
	  v_spagmas     NUMBER;
	  v_iimptot     pagos_masivos.iimptot%TYPE;

	  CURSOR c1 IS
	    SELECT spagmas,SUM(iimppro) iimppro,SUM(iimpope) iimpope,SUM(iimpins) iimpins
	      FROM pagos_masivosdet
	     WHERE spagmas IN(SELECT spagmas
	                        FROM pagos_masivos
	                       WHERE sproces=psproces AND
	                             trunc(fcarga)=trunc(pfcarga) AND
	                             tfichero=ptfichero)
	     GROUP BY spagmas;
	BEGIN
	    /* Bug 0028517 - JMF - 10-10-2013*/
	    vpasexec:=10;

	    SELECT SUM(it.campo07)
	      INTO v_iimptot
	      FROM int_carga_generico it,int_carga_ctrl_linea cl
	     WHERE tiporegistro=35 AND
	           proceso=psproces AND
	           it.proceso=cl.sproces AND
	           it.nlinea=cl.nlinea AND
	           cestado<>6;

	    /**/
	    FOR f1 IN c1 LOOP
	        vpasexec:=20;

	        UPDATE pagos_masivos
	           SET iimppro=f1.iimppro,iimpope=f1.iimpope,iimpins=f1.iimpins,iimptot=v_iimptot
	         WHERE spagmas=f1.spagmas;
	    /**/
	    END LOOP;

	    /**/
	    BEGIN
	        SELECT pms.saldo,pm.seqcaja,pm.spagmas
	          INTO v_isobrante, v_seqcaja, v_spagmas
	          FROM pagos_masivos_sobrante pms,pagos_masivos pm
	         WHERE pm.sproces=psproces AND
	               pm.spagmas=pms.spagmas AND
	               pms.numlin=(SELECT max(numlin)
	                             FROM pagos_masivos_sobrante
	                            WHERE spagmas=pm.spagmas);

	        /**/
	        IF nvl(v_isobrante, 0)>0 THEN
	          /*DC01-->*/
	          vpasexec:=50;

	          BEGIN
	              SELECT SUM(iimpins) iimpins
	                INTO v_pag_antes
	                FROM pagos_masivosdet
	               WHERE spagmas=v_spagmas AND
	                     ctratar=1;
	          EXCEPTION
	              WHEN no_data_found THEN
	                v_pag_antes:=0;
	          END;

	          /*DC01<--*/
	          num_err:=f_upd_pagos_masivo(psproces, v_seqcaja);

	          /*DC01-->*/
	          vpasexec:=60;

	          BEGIN
	              SELECT SUM(iimpins) iimpins
	                INTO v_pag_despues
	                FROM pagos_masivosdet
	               WHERE spagmas=v_spagmas AND
	                     ctratar=1;
	          EXCEPTION
	              WHEN no_data_found THEN
	                v_pag_despues:=0;
	          END;

	          /*DC01<--*/
	          v_pag_difer:=v_pag_despues-v_pag_antes;

	          IF v_pag_difer<>0 THEN
	            num_err:=f_ins_sobrante(v_spagmas, v_pag_difer, 2);
	          END IF;
	        END IF;
	    EXCEPTION
	        WHEN no_data_found THEN
	          RETURN 0;
	    END;

	    /**/
	    RETURN 0;
	/**/
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, v_terror
	                                                                       || ' '
	                                                                       || SQLERRM);

	             RETURN 102555; /* error al insertar en ctacliente*/
	END f_ins_pagos_masivo;

	/******************************************************************************
	   NOMBRE:     F_LEE_PAGOS_MAS_PDTES
	   PROPOSITO:  Extrae los registros de los ficheros que se han cargado previamente
	   y aún están pendientes de pago.

	   PARAMETROS:

	        return            : NOT NULL -> Todo correcto
	                            NULL -> Se ha producido un error

	 *****************************************************************************/
	FUNCTION f_lee_pagos_mas_pdtes(
			pcagente	IN	agentes.cagente%TYPE,
			pmoneprod	IN	NUMBER
	) RETURN SYS_REFCURSOR
	IS
	  vpasexec NUMBER(8):=1;
	  vparam   VARCHAR2(2000):='cagente= '
	                         || pcagente
	                         || ' pmoneprod: '
	                         || pmoneprod;
	  vobject  VARCHAR2(200):='pac_caja.f_lee_pagos_mas_pdtes';
	  terror   VARCHAR2(200);
	  num_err  axis_literales.slitera%TYPE:=0;
	  cur      SYS_REFCURSOR;
	BEGIN
	    OPEN cur FOR
	      SELECT p.sproces,p.fcarga,p.cagente,p.tfichero,p.sproduc,(SELECT cmonint
	                                                                  FROM monedas
	                                                                 WHERE cmoneda=(SELECT cdivisa
	                                                                                  FROM productos pro
	                                                                                 WHERE p.sproduc=pro.sproduc) AND
	                                                                       cidioma=pac_md_common.f_get_cxtidioma) cdivisa,p.iimppro,p.iimpope iimpopeori,p.cmoneop,pmoneprod cmoneop2,pac_monedas.f_cmoneda_t(p.cmoneop) cmonedaint,pac_monedas.f_cmoneda_t(pmoneprod) cmonedaint2,decode (p.cmoneop, pmoneprod, p.iimpope,
	                                                                                                                                                                                                                                                                                                  nvl (pac_monedas.f_round (p.iimpope*pac_eco_tipocambio.f_cambio (pac_monedas.f_cmoneda_t(p.cmoneop), pac_monedas.f_cmoneda_t(pmoneprod), f_sysdate), pmoneprod), 0)) iimpope,pac_redcomercial.ff_desagente(p.cagente, gidioma) tagente,iimptot
	        FROM pagos_masivos p
	       WHERE p.cagente=pcagente AND
	             p.seqcaja IS NULL AND
	             decode (p.cmoneop, pmoneprod, p.iimpope,
	                                nvl (pac_monedas.f_round (p.iimpope*pac_eco_tipocambio.f_cambio (pac_monedas.f_cmoneda_t(p.cmoneop), pac_monedas.f_cmoneda_t(pmoneprod), f_sysdate), pmoneprod), 0))<>0
	       ORDER BY fcarga;

	    vpasexec:=3;

	    RETURN cur;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN cur;
	END f_lee_pagos_mas_pdtes;

	/******************************************************************************
	  NOMBRE:     f_ins_det_autliq
	  PROPOSITO:  Funcion que inserta en la cuenta del agente la autoliquidacion
	  realizadas desde el pago masivo
	  PARAMETROS:
	       return            : 0 -> Todo correcto
	                           1 -> Se ha producido un error
	*****************************************************************************/
	FUNCTION f_ins_det_autliq(
			pcagente	IN	NUMBER,
			psproces	IN	NUMBER,
			pcmonope	IN	NUMBER,
			psproduc	IN	NUMBER,
			piautliq	IN	NUMBER
	) RETURN NUMBER
	IS
	  vpasexec NUMBER(8):=1;
	  vparam   VARCHAR2(2000):='pcagente - '
	                         || pcagente
	                         || ' psproces - '
	                         || psproces
	                         || ' pcmonope - '
	                         || pcmonope
	                         || ' piautliq - '
	                         || piautliq;
	  vobject  VARCHAR2(200):='pac_caja.f_ins_det_autliq';
	  terror   VARCHAR2(200);
	  num_err  axis_literales.slitera%TYPE:=0;
	  vnnumlin ctactes.nnumlin%TYPE;
	BEGIN
	    IF piautliq=0 THEN
	      RETURN 0;
	    END IF;

	    vpasexec:=2;

	    vpasexec:=3;

	    num_err:=pac_liquida.f_set_cta(pac_md_common.f_get_cxtempresa(), pcagente, NULL, NULL, 2, piautliq, '', '', 1, NULL, NULL, 10, f_sysdate, trunc(f_sysdate), NULL, psproduc);

	    vpasexec:=31;

	    IF num_err<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN e_object_error THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, num_err);

	             RETURN num_err; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);

	             RETURN 102555; /* error al insertar en ctacliente*/
	END f_ins_det_autliq;

	/*---------------------*/
	/******************************************************************************
	NAME:       F_COBRA_PAGOS_MASIVO
	PURPOSE:    Realiza el tratamiento de las polizas y el dinero ingresado,
	            que viene de los cobros de la carga Masiva, cargados previamente
	            en una tabla intermedia.
	            Se ingresan los pagos parciales o se cambia el recibo, cuando se
	            ingresa del dinero a través del modulo de caja:"Pagos Masivos".

	            El importe que nos viene puede ser para un recibo o varios.
	            Estos pagos pueden ser parciales, totales o para varios recibos.
	            El criterio de pago es siempre del recibo mas antigüo al mas reciente.

	BUG:        26301
	REVISIONS:
	Ver        Date        Author           Description
	---------  ----------  ---------------  ------------------------------------
	1.0        11/03/2013  afm              1. Created this function.

	PARAMETRES:
	   SPROCES  Nro de proceso
	   SEQCAJA  Justificante de caja.

	******************************************************************************/
	FUNCTION f_cobra_pagos_masivo(
			psproces	IN	NUMBER,
			pseqcaja	IN	NUMBER
	) RETURN NUMBER
	IS
	  /**/
	  vpasexec           NUMBER(8):=1;
	  vparam             VARCHAR2(2000):='SPROCES ='
	                         || psproces
	                         || ' PSEQCAJA='
	                         || pseqcaja;
	  vobject            VARCHAR2(200):='pac_caja.f_cobra_pagos_masivo';
	  terror             VARCHAR2(200);
	  num_err            axis_literales.slitera%TYPE:=0;
	  v_terror           VARCHAR2(2000);
	  vn_cempres         NUMBER:=pac_md_common.f_get_cxtempresa;
	  lhayctacliente     parempresas.nvalpar%TYPE;
	  /**/
	  vn_cdivisa         productos.cdivisa%TYPE;
	  vn_monins          monedas.cmoneda%TYPE;
	  vn_importep        ctacliente.iimppro%TYPE;
	  vn_importei        ctacliente.iimpins%TYPE;
	  vn_sperson         ctacliente.sperson%TYPE;
	  vn_itasao          eco_tipocambio.itasa%TYPE;
	  vn_itasains        eco_tipocambio.itasa%TYPE;
	  vparemp_monpol     NUMBER:=0;
	  /**/
	  vn_importe_parcial NUMBER:=0;
	  v_impope           NUMBER:=0;
	  v_impins           NUMBER:=0;
	  vn_a_pagar         NUMBER:=0;
	  vn_igenera         NUMBER:=0;
	  vf_fcobrado        DATE:=NULL;

	  /**/
	  CURSOR c1 IS
	    SELECT c.cdivisa,d.sproduc,a.cmoneop,d.ctipreb,b.*
	      FROM pagos_masivos a,pagos_masivosdet b,productos c,seguros d
	     WHERE a.sproces=psproces AND
	           b.spagmas=a.spagmas AND
	           c.sproduc=d.sproduc AND
	           d.sseguro=b.sseguro AND
	           nvl(b.ctratar, 0)=0;

	  /**/
	CURSOR cur_recibos(

	    pn_sseguro                                           IN NUMBER,pn_sperson                      IN NUMBER,pn_cmonpol IN NUMBER) IS
	  /**/
	    /* Busca todos los recibos, persona del recibo o persona de tomador*/
	    SELECT b.fefecto,b.nrecibo,d.itotalr,c.itotalr itotalr_monpol,b.nmovimi,nvl(b.sperson, e.sperson) sperson
	      FROM movrecibo a,recibos b,vdetrecibos_monpol c,vdetrecibos d,tomadores e
	     WHERE a.nrecibo=b.nrecibo AND
	           b.nrecibo=c.nrecibo AND
	           c.nrecibo=d.nrecibo AND
	           (pn_sperson IS NULL  OR
	            (b.sperson IS NOT NULL AND
	             b.sperson=pn_sperson)  OR
	            (b.sperson IS NULL AND
	             e.sperson=pn_sperson)) AND
	           a.cestrec=0 AND
	           b.ctiprec IN(0, 1, 3, 4) AND
	           a.fmovfin IS NULL AND
	           b.sseguro=pn_sseguro AND
	           e.sseguro=pn_sseguro AND
	           e.nordtom=(SELECT min(e1.nordtom)
	                        FROM tomadores e1
	                       WHERE e1.sseguro=pn_sseguro) AND
	           pn_cmonpol=1
	    UNION
	    SELECT b.fefecto,b.nrecibo,c.itotalr,0 itotalr_monpol,b.nmovimi,nvl(b.sperson, e.sperson) sperson
	      FROM movrecibo a,recibos b,vdetrecibos c,tomadores e
	     WHERE a.nrecibo=b.nrecibo AND
	           b.nrecibo=c.nrecibo AND
	           a.cestrec=0 AND
	           b.ctiprec IN(0, 1, 3, 4) AND
	           a.fmovfin IS NULL AND
	           b.sseguro=pn_sseguro AND
	           e.sseguro=pn_sseguro AND
	           e.nordtom=(SELECT min(e1.nordtom)
	                        FROM tomadores e1
	                       WHERE e1.sseguro=pn_sseguro) AND
	           (pn_sperson IS NULL  OR
	            (b.sperson IS NOT NULL AND
	             b.sperson=pn_sperson)  OR
	            (b.sperson IS NULL AND
	             e.sperson=pn_sperson)) AND
	           pn_cmonpol=0
	     ORDER BY fefecto,nrecibo;
	BEGIN
	    /**/
	    vpasexec:=100;

	    /**/
	    vparemp_monpol:=nvl(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'MONEDA_POL'), 0);

	    /**/
	    FOR f1 IN c1 LOOP
	        vpasexec:=110;

	        /* Recuperamos la moneda del producto para obtener los importes en la moneda del producto.*/
	        vpasexec:=120;

	        SELECT cdivisa
	          INTO vn_cdivisa
	          FROM productos
	         WHERE sproduc=f1.sproduc;

	        /* Trabajamos con la moneda del producto*/
	        vn_importep:=f1.iimppro;

	        vn_importei:=f1.iimpope;

	        /* Recuperamos tasa para moneda operacion*/
	        IF vn_cdivisa<>f1.cmoneop THEN
	          vpasexec:=130;

	          vn_itasao:=pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(vn_cdivisa), pac_monedas.f_cmoneda_t(f1.cmoneop), f1.fcambio);

	          IF vn_itasao IS NULL THEN
	            num_err:=9902592;

	            RAISE e_param_error;
	          /* No se ha encontrado el tipo de cambio entre monedas*/
	          END IF;
	        ELSE
	          vn_itasao:=1;
	        END IF;

	        /* Recuperar moneda instalacion*/
	        vpasexec:=140;

	        vn_monins:=f_parinstalacion_n('MONEDAINST');

	        IF vn_monins<>vn_cdivisa THEN
	          vpasexec:=150;

	          vn_itasains:=pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(vn_cdivisa), pac_monedas.f_cmoneda_t(vn_monins), f1.fcambio);

	          IF vn_itasains IS NULL THEN
	            num_err:=9902592;

	            RAISE e_param_error;
	          /* No se ha encontrado el tipo de cambio entre monedas*/
	          END IF;
	        ELSE
	          vn_itasains:=1;
	        END IF;

	        /**/
	        lhayctacliente:=nvl(f_parproductos_v(f1.sproduc, 'HAYCTACLIENTE'), 0);

	        /**/
	        FOR rec_recibos IN cur_recibos(f1.sseguro, NULL, vparemp_monpol) LOOP
	            vn_sperson:=rec_recibos.sperson;

	            /* Recuperar importe total de los pagos parciales que se han realizado en el recibo.*/
	            vpasexec:=160;

	            vn_importe_parcial:=pac_adm_cobparcial.f_get_importe_cobro_parcial(rec_recibos.nrecibo, NULL, NULL);

	            /* Calcular importe cobrado*/
	            vpasexec:=170;

	            vn_a_pagar:=nvl(rec_recibos.itotalr, 0)-nvl(vn_importe_parcial, 0);

	            vn_a_pagar:=least(vn_a_pagar, vn_importep);

	            IF vn_a_pagar>0 THEN
	              /* Calcular el importe en moneda operacion*/
	              IF vn_cdivisa<>f1.cmoneop THEN
	                vpasexec:=180;

	                v_impope:=pac_monedas.f_round(vn_a_pagar*vn_itasao, f1.cmoneop);
	              ELSE
	                v_impope:=vn_a_pagar;
	              END IF;

	              /* Calcular el importe en moneda instalacion*/
	              IF vn_cdivisa<>vn_monins THEN
	                vpasexec:=190;

	                v_impins:=pac_monedas.f_round(vn_a_pagar*vn_itasains, vn_monins);
	              ELSE
	                v_impins:=vn_a_pagar;
	              END IF;

	              /* Evaluar si queda importe para cancelar recibos de la poliza*/
	              vn_importep:=vn_importep-vn_a_pagar;

	              vn_importei:=vn_importei-v_impope;

	              /**/
	              pac_ctacliente.ggrabar:=0;

	              vpasexec:=200;
                      -- INI -IAXIS-4153 - JLTS - 07/06/2019 Se incluyen los nuevos parámetros en null
	              num_err:=pac_adm_cobparcial.f_cobro_parcial_recibo(rec_recibos.nrecibo, 3, vn_a_pagar, vn_cdivisa, vn_igenera, vf_fcobrado,0, psproces, f1.fcambio,null,null);
		      -- FIN -IAXIS-4153 - JLTS - 07/06/2019 Se incluyen los nuevos parámetros en null

	              pac_ctacliente.ggrabar:=1;

	              IF num_err<>0 THEN
	                p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam
	                                                                  || ' ERR='
	                                                                  || num_err, ' rec='
	                                                                              || f1.nrecibo
	                                                                              || ' imp='
	                                                                              || f1.iimppro
	                                                                              || ' div='
	                                                                              || f1.cdivisa
	                                                                              || ' cam='
	                                                                              || f1.fcambio);

	                EXIT;
	              END IF;

	            /* Si no hay error y se ha efectuado un cobro parcial y si admite movimiento en la cuenta del cliente,*/
	              /*   entonces se inserta registro en CTACLIENTE*/
	              vpasexec:=210;

	              IF lhayctacliente=1 THEN
	                vpasexec:=220;

	                num_err:=pac_ctacliente.f_ins_movpapctacli(vn_cempres, rec_recibos.sperson, f1.sseguro, psproces, vn_a_pagar, f1.cmoneop, v_impope, NULL, v_impins, f1.fcambio, f1.ctipreb, rec_recibos.nrecibo, pseqcaja);

	                IF num_err<>0 THEN
	                  p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam
	                                                                    || ' ERR='
	                                                                    || num_err, ' per='
	                                                                                || rec_recibos.sperson
	                                                                                || ' seg='
	                                                                                || f1.sseguro
	                                                                                || ' pro='
	                                                                                || vn_a_pagar
	                                                                                || ' mon='
	                                                                                || f1.cmoneop
	                                                                                || ' ope='
	                                                                                || vn_importep
	                                                                                || ' ins='
	                                                                                || vn_importei
	                                                                                || ' Rec='
	                                                                                || rec_recibos.nrecibo
	                                                                                || ' cam='
	                                                                                || f1.fcambio
	                                                                                || ' tip='
	                                                                                || f1.ctipreb);

	                  EXIT;
	                END IF;
	              END IF;

	              /**/
	              IF vn_importep=0 THEN
	                EXIT;
	              END IF;
	            /**/
	            ELSE
	              EXIT;
	            END IF; /*IF vn_a_pagar > 0 THEN*/
	        /**/
	        END LOOP;

	        /**/
	        IF vn_importep>0 THEN
	          IF lhayctacliente=1 THEN
	            /* Calcular el importe en moneda operacion*/
	            IF vn_cdivisa<>f1.cmoneop THEN
	              vpasexec:=180;

	              v_impope:=pac_monedas.f_round(vn_importep*vn_itasao, f1.cmoneop);
	            ELSE
	              v_impope:=vn_importep;
	            END IF;

	            /* Calcular el importe en moneda instalacion*/
	            IF vn_cdivisa<>vn_monins THEN
	              vpasexec:=190;

	              v_impins:=pac_monedas.f_round(vn_importep*vn_itasains, vn_monins);
	            ELSE
	              v_impins:=vn_importep;
	            END IF;

	            /* Bug 0025537 - JMF - 08-04-2014*/
	            vpasexec:=200;

	            SELECT max(e.sperson)
	              INTO vn_sperson
	              FROM tomadores e
	             WHERE e.sseguro=f1.sseguro AND
	                   e.nordtom=(SELECT min(e1.nordtom)
	                                FROM tomadores e1
	                               WHERE e1.sseguro=f1.sseguro);

	            /**/
	            vpasexec:=230;

	            num_err:=pac_ctacliente.f_ins_movpapctacli(vn_cempres, vn_sperson, f1.sseguro, psproces, vn_importep, f1.cmoneop, v_impope, NULL, v_impins, f1.fcambio, f1.ctipreb, NULL, pseqcaja);

	            /**/
	            IF num_err<>0 THEN
	              p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam
	                                                                || ' ERR='
	                                                                || num_err, ' per='
	                                                                            || vn_sperson
	                                                                            || ' seg='
	                                                                            || f1.sseguro
	                                                                            || ' pro='
	                                                                            || vn_a_pagar
	                                                                            || ' mon='
	                                                                            || f1.cmoneop
	                                                                            || ' ope='
	                                                                            || vn_importep
	                                                                            || ' ins='
	                                                                            || vn_importei
	                                                                            || ' cam='
	                                                                            || f1.fcambio
	                                                                            || ' tip='
	                                                                            || f1.ctipreb);

	              EXIT;
	            END IF;
	          /**/
	          END IF;
	        /**/
	        END IF;

	        /**/
	        UPDATE pagos_masivosdet
	           SET ctratar=1
	         WHERE spagmas=f1.spagmas AND
	               numlin=f1.numlin;
	    /**/
	    END LOOP;

	    /**/
	    vpasexec:=500;

	    /**/
	    RETURN num_err;
	/**/
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, v_terror
	                                                                       || ' '
	                                                                       || SQLERRM);

	             RETURN num_err; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, v_terror
	                                                                       || ' '
	                                                                       || SQLERRM);

	             RETURN 108468; /* error al insertar en la tabla*/
	END f_cobra_pagos_masivo;

	/******************************************************************************
	   NOMBRE:     f_recibosanualidad
	   PROPOSITO:  Acciones a realizar con los recibos de la anualidad,
	               cuando en el proceso de carga nos indican que el recibo es
	               ultimo pago.
	   PARAMETROS:
	       psproces : numero de proceso de la carga.
	        return  : 0 -> Todo correcto
	                  codigo -> Se ha producido un error
	 *****************************************************************************/
	FUNCTION f_recibosanualidad(
			psproces	IN	NUMBER
	) RETURN NUMBER
	IS
	  vpasexec  NUMBER(8):=1;
	  vparam    VARCHAR2(2000):='SPROCES= '
	                         || psproces;
	  vobject   VARCHAR2(200):='pac_caja.f_recibosanualidad';
	  num_err   axis_literales.slitera%TYPE:=0;
	  rcob      pac_anulacion.recibos_cob;
	  v_nmovimi movseguro.nmovimi%TYPE;
	  n_rec     NUMBER;

	  CURSOR c1 IS
	    SELECT b.fcambio,b.sseguro,c.cempres,c.nrecibo,c.ctipban,c.cbancar,c.ccobban,c.cdelega,c.ctipcob,c.fefecto,c.fvencim,d.cagente,e.cdivisa
	      FROM pagos_masivos a,pagos_masivosdet b,recibos c,seguros d,productos e
	     WHERE a.sproces=psproces AND
	           b.spagmas=a.spagmas AND
	           b.cultpag=1 AND
	           c.sseguro=b.sseguro AND
	           nvl(b.ctratar, 0)=0 AND
	           EXISTS(SELECT 1
	                    FROM movrecibo c
	                   WHERE c.nrecibo=b.nrecibo AND
	                         c.fmovfin IS NULL AND
	                         c.cestrec=0) AND
	           d.sseguro=b.sseguro;

	  CURSOR c2 IS
	    SELECT b.fcambio,c.cempres,c.nrecibo,c.ctipban,c.cbancar,c.ccobban,c.cdelega,c.ctipcob
	      FROM pagos_masivos a,pagos_masivosdet b,recibos c
	     WHERE a.sproces=psproces AND
	           b.spagmas=a.spagmas AND
	           b.cultpag=1 AND
	           c.sseguro=b.sseguro AND
	           c.ctiprec=9 AND
	           nvl(b.ctratar, 0)=0 AND
	           EXISTS(SELECT 1
	                    FROM movrecibo c
	                   WHERE c.nrecibo=b.nrecibo AND
	                         c.fmovfin IS NULL AND
	                         c.cestrec=0 AND
	                         trunc(c.fmovini)=trunc(b.fcambio));
	BEGIN
	    vpasexec:=1000;

	    rcob.DELETE;

	    n_rec:=0;

	    vpasexec:=1010;

	    FOR f1 IN c1 LOOP
	    /*--------------------------*/
	        /* cobrar recibos pendientes*/
	        vpasexec:=1020;

	        num_err:=pac_gestion_rec.f_cobro_recibo(f1.cempres, f1.nrecibo, f1.fcambio, f1.ctipban, f1.cbancar, f1.ccobban, f1.cdelega, f1.ctipcob);

	        IF num_err<>0 THEN
	          p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam
	                                                            || ' err='
	                                                            || num_err, 'rec='
	                                                                        || f1.nrecibo);

	          EXIT;
	        END IF;

	        /*-----------------------*/
	        /* extornar estos recibos*/
	        vpasexec:=1030;

	        SELECT max(nmovimi)
	          INTO v_nmovimi
	          FROM movseguro
	         WHERE sseguro=f1.sseguro;

	        vpasexec:=1040;

	        n_rec:=n_rec+1;

	        rcob(n_rec).nrecibo:=f1.nrecibo;

	        rcob(n_rec).fmovini:=f1.fcambio;

	        rcob(n_rec).fefecto:=f1.fefecto;

	        rcob(n_rec).fvencim:=f1.fvencim;

	        vpasexec:=1050;

	        num_err:=pac_anulacion.f_extorn_rec_cobrats(f1.sseguro, f1.cagente, v_nmovimi, f1.fcambio, f1.cdivisa, rcob, 0, 0);

	        IF num_err<>0 THEN
	          p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam
	                                                            || ' err='
	                                                            || num_err, 'seg='
	                                                                        || f1.sseguro);

	          EXIT;
	        END IF;
	    END LOOP;

	    /*------------------------------*/
	    /* cobrar los extornos generados*/
	    vpasexec:=1060;

	    FOR f2 IN c2 LOOP
	        vpasexec:=1070;

	        num_err:=pac_gestion_rec.f_cobro_recibo(f2.cempres, f2.nrecibo, f2.fcambio, f2.ctipban, f2.cbancar, f2.ccobban, f2.cdelega, f2.ctipcob);

	        IF num_err<>0 THEN
	          p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam
	                                                            || ' err='
	                                                            || num_err, 'rec='
	                                                                        || f2.nrecibo);

	          EXIT;
	        END IF;
	    END LOOP;

	    vpasexec:=1080;

	    RETURN num_err;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);

	             RETURN 9001589; /* Error en el cobro del recibo*/
	END f_recibosanualidad;

	/******************************************************************************
	   NOMBRE:     F_UPD_PAGOS_MASIVO
	   PROPOSITO:  Se informa el campo seqcaja, marcando aquellas cargas que entran
	   dentro del pago.

	   PARAMETROS:


	        return            : 0 -> Todo correcto
	                            1 -> Se ha producido un error

	 *****************************************************************************/
	FUNCTION f_upd_pagos_masivo(
			psproces	IN	NUMBER,
			pseqcaja	IN	NUMBER,
			piautoliq	IN	NUMBER DEFAULT NULL,
			piautoliqp	IN	NUMBER DEFAULT NULL,
			pidifcambio	IN	NUMBER DEFAULT NULL
	) RETURN NUMBER
	IS
	  /**/
	  vpasexec NUMBER(8):=1;
	  vparam   VARCHAR2(2000):='SPROCES= '
	                         || psproces
	                         || ' SEQCAJA='
	                         || pseqcaja;
	  vobject  VARCHAR2(200):='pac_caja.f_upd_pagos_masivo';
	  terror   VARCHAR2(200);
	  num_err  axis_literales.slitera%TYPE:=0;
	BEGIN
	    /* Bug 0028517 - JMF - 10-10-2013*/
	    vpasexec:=10;

	    num_err:=f_cobra_pagos_masivo(psproces, pseqcaja);

	    IF num_err=0 THEN
	      num_err:=f_recibosanualidad(psproces);
	    END IF;

	    IF num_err=0 THEN
	      vpasexec:=20;

	      UPDATE pagos_masivos
	         SET seqcaja=pseqcaja,iautoliq=nvl(piautoliq, iautoliq),iautoliqp=nvl(piautoliqp, iautoliqp),idifcambio=nvl(pidifcambio, idifcambio)
	       WHERE sproces=psproces;
	    END IF;

	    RETURN num_err;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);

	             RETURN 102555; /* error al insertar en ctacliente*/
	END f_upd_pagos_masivo;

	/**/
	/******************************************************************************
	   NOMBRE:     f_ins_sobrante
	   PROPOSITO:  Se graba un registro en pagos_masivos_sobrante si lo cargado no
	               corresponde con lo ingresado por caja. Siempre tiene que ser
	               mayor lo ingresado que lo cargado a través de la carga masiva.

	   PARAMETROS:


	        return            : 0 -> Todo correcto
	                            1 -> Se ha producido un error

	 *****************************************************************************/
	FUNCTION f_ins_sobrante(
			pspagmas	IN	NUMBER,
			pimporte	IN	NUMBER,
			pcmovimi	IN	NUMBER
	) RETURN NUMBER
	IS
	  /**/
	  vpasexec   NUMBER(8):=1;
	  vparam     VARCHAR2(2000):=' pspagmas='
	                         || pspagmas
	                         || ' pimporte= '
	                         || pimporte
	                         || ' pcmovimi='
	                         || pcmovimi;
	  vobject    VARCHAR2(200):='pac_caja.f_ins_sobrante';
	  terror     VARCHAR2(200);
	  v_numlin   NUMBER;
	  v_saldo    NUMBER;
	  v_fpago    DATE;
	  v_fmovimi  DATE;
	  v_cagente  NUMBER;
	  v_tfichero VARCHAR2(1000);
	  num_err    axis_literales.slitera%TYPE:=0;
	BEGIN
	    vpasexec:=10;

	    v_numlin:=0;

	    IF pcmovimi=1 THEN /*Alta*/
	    BEGIN
	          SELECT (numlin)
	            INTO v_numlin
	            FROM pagos_masivos_sobrante
	           WHERE spagmas=pspagmas AND
	                 pcmovimi=1;

	          IF v_numlin=1 THEN
	            num_err:=108959;

	            RAISE e_object_error;
	          END IF;
	      EXCEPTION
	          WHEN no_data_found THEN
	            vpasexec:=12;

	            SELECT cagente,tfichero
	              INTO v_cagente, v_tfichero
	              FROM pagos_masivos
	             WHERE spagmas=pspagmas;

	            vpasexec:=15;

	            v_fmovimi:=trunc(f_sysdate);

	            v_fpago:=v_fmovimi;

	            v_numlin:=1;

	            v_saldo:=pimporte;
	          WHEN OTHERS THEN
	            RETURN 104061; /* Error al llegir la seqüència (smovagr) de BD*/
	      END;
	    ELSE
	      vpasexec:=20;

	      SELECT max(numlin)
	        INTO v_numlin
	        FROM pagos_masivos_sobrante
	       WHERE spagmas=pspagmas;

	      vpasexec:=30;

	      SELECT saldo,fpago,cagente,tfichero
	        INTO v_saldo, v_fpago, v_cagente, v_tfichero
	        FROM pagos_masivos_sobrante
	       WHERE spagmas=pspagmas AND
	             numlin=v_numlin;

	      vpasexec:=40;

	      v_numlin:=v_numlin+1;

	      v_saldo:=v_saldo-pimporte;

	      v_fmovimi:=trunc(f_sysdate);

	      vpasexec:=50;

	      IF pcmovimi=2 THEN /*Reprocesar*/
	        v_fpago:=v_fpago;
	      ELSE /* Devolucion*/
	        v_fpago:=trunc(f_sysdate);
	      END IF;
	    END IF;

	    vpasexec:=54;

	    IF v_saldo<0 THEN
	      vpasexec:=55;

	      num_err:=9001935;

	      RAISE e_object_error;
	    END IF;

	    vpasexec:=57;

	    IF num_err=0 THEN
	      vpasexec:=60;

			INSERT INTO pagos_masivos_sobrante
		           (cagente,spagmas,numlin,tfichero,importe,saldo,
		           cmovimi,fmovimi,fpago,fcontab)
		    VALUES
		           (v_cagente,pspagmas,v_numlin,v_tfichero,pimporte,v_saldo,
		           pcmovimi,v_fmovimi,v_fpago,NULL);


	      vpasexec:=61;
	    END IF;

	    RETURN num_err;
	EXCEPTION
	  WHEN e_object_error THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, num_err);

	             RETURN num_err; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);

	             RETURN 102555; /* error al insertar en ctacliente*/
	END f_ins_sobrante;

	/******************************************************************************
	   NOMBRE:     F_LEE_PAGOS_PDTES
	   PROPOSITO:  Muestra los fichero que tiene sobrante un agente

	   PARAMETROS:


	        return            : 0 -> Todo correcto
	                            1 -> Se ha producido un error

	 *****************************************************************************/
	FUNCTION f_lee_pagos_pdtes(
			pcagente	IN	agentes.cagente%TYPE
	) RETURN SYS_REFCURSOR
	IS
	  vpasexec NUMBER(8):=1;
	  vparam   VARCHAR2(2000):='cagente= '
	                         || pcagente;
	  vobject  VARCHAR2(200):='pac_caja.f_lee_pagos_pdtes';
	  terror   VARCHAR2(200);
	  num_err  axis_literales.slitera%TYPE:=0;
	  cur      SYS_REFCURSOR;
	BEGIN
	    OPEN cur FOR
	      SELECT DISTINCT p.tfichero
	        FROM pagos_masivos_sobrante p
	       WHERE p.cagente=pcagente;

	    vpasexec:=3;

	    RETURN cur;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN cur;
	END f_lee_pagos_pdtes;

	/******************************************************************************
	   NOMBRE:     F_LEE_SOBRANTE
	   PROPOSITO:  Muestra los movimientos de sobrantes que tienen un agente por fichero.

	   PARAMETROS:


	        return            : 0 -> Todo correcto
	                            1 -> Se ha producido un error

	 *****************************************************************************/
	FUNCTION f_lee_sobrante(
			pcagente	IN	NUMBER,
			ptfichero	IN	VARCHAR2,
			ptselect	OUT	VARCHAR2
	) RETURN NUMBER
	IS
	  vpasexec NUMBER(8):=1;
	  vparam   VARCHAR2(2000):='pcagente = '
	                         || pcagente
	                         || ' ptfichero: '
	                         || ptfichero;
	  terror   VARCHAR2(200);
	  vobject  VARCHAR2(200):='pac_caja.f_lee_sobrante';
	  ptwhere  VARCHAR2(200);
	BEGIN
	    ptselect:='SELECT SPAGMAS AS SPAGMAS, NUMLIN AS NUMLIN, CAGENTE  ||'' - '' ||FF_DESAGENTE(CAGENTE) AS AGENTE, TFICHERO AS TFICHERO, SALDO AS SALDO, IMPORTE AS IMPORTE FROM PAGOS_MASIVOS_SOBRANTE
		            WHERE (SPAGMAS,NUMLIN) IN (
		            SELECT SPAGMAS, MAX(NUMLIN)
		            FROM PAGOS_MASIVOS_SOBRANTE
		            GROUP BY SPAGMAS) AND SALDO>0';

	    /*AND TFICHERO LIKE 'cay%'';*/
	    IF pcagente IS NOT NULL THEN
	      ptselect:=ptselect
	                || '  AND CAGENTE='
	                || pcagente;
	    END IF;

	    IF ptfichero IS NOT NULL THEN
	      ptselect:=ptselect
	                || '  AND  TFICHERO like '''
	                || ptfichero
	                || '%''  ';
	    END IF;

	    ptselect:=ptselect
	              || ' ORDER BY FPAGO DESC';

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, ptselect);

	             RETURN 'SELECT 1 FROM DUAL';
	END f_lee_sobrante;

	/**/
	/**/
	/*BUG 32661:NSS:03/11/2014*/
	/*************************************************************************
	   Valida valor ingresado
	   param in nrefdeposito        : numero de deposito
	   param in iimpins        : importe
	   param in out mensajes : mesajes de error
	   return                : descripcion del valor
	*************************************************************************/
	FUNCTION f_valida_valor_ingresado(
			pnrefdeposito	IN	NUMBER,
			pimovimi	IN	NUMBER,
			pcmoneop	IN	VARCHAR2,
			pcidioma	IN	NUMBER,
			pconfirm	OUT	VARCHAR2
	) RETURN NUMBER
	IS
	  vpasexec        NUMBER(8):=1;
	  vparam          VARCHAR2(2000):='pnrefdeposito = '
	                         || pnrefdeposito
	                         || ' pimovimi: '
	                         || pimovimi
	                         || ' pcmoneop: '
	                         || pcmoneop
	                         || ' pcidioma: '
	                         || pcidioma;
	  terror          VARCHAR2(200);
	  vobject         VARCHAR2(200):='pac_caja.f_valida_valor_ingresado';
	  vnumerr         NUMBER;
	  valor_ingresado caja_datmedio.imovimi%TYPE;
	  v_mon           monedas.cmoneda%TYPE;
	BEGIN
	    IF pnrefdeposito IS NULL  OR
	       pimovimi IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=1;

	    SELECT DISTINCT cmoneda
	      INTO v_mon
	      FROM monedas
	     WHERE cmonint=pcmoneop;

	    SELECT SUM(cdm.imovimi)
	      INTO valor_ingresado
	      FROM cajamov cm,caja_datmedio cdm
	     WHERE cm.seqcaja=cdm.seqcaja AND
	           cm.ctipmov IN(0, 3) /* ingreso, saldo inicial*/
	           AND
	           cdm.cmedmov=0 /* efectivo*/
	           AND
	           cdm.nrefdeposito=pnrefdeposito AND
	           cm.cmoneop=v_mon AND
	           trunc(cm.ffecmov)=trunc(f_sysdate);

	    IF valor_ingresado<pimovimi THEN
	      pconfirm:=f_axis_literales(9907193, pcidioma);
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);

	             RETURN vnumerr;
	END f_valida_valor_ingresado;

	/*************************************************************************
	   Obtiene "cheques" y "vales vista" entrados por caja por el propio usuario, con estado "Aceptado", en la moneda seleccionada por
	   pantalla y que no estén vinculados con ninguna referencia de deposito anterior, permitiendo su seleccion para ser incluidos en
	   la referencia de deposito
	   param in nrefdeposito        : numero de deposito
	   param in iimpins        : importe
	   param in out mensajes : mesajes de error
	   return                : descripcion del valor
	*************************************************************************/
	FUNCTION f_get_cheques(
			pnrefdeposito	IN	NUMBER,
			pimovimi	IN	NUMBER,
			pcmoneop	IN	VARCHAR2,
			pcidioma	IN	NUMBER,
			ptselect	OUT	VARCHAR2
	) RETURN NUMBER
	IS
	  vpasexec NUMBER(8):=1;
	  vparam   VARCHAR2(2000):='pnrefdeposito = '
	                         || pnrefdeposito
	                         || ' pimovimi: '
	                         || pimovimi
	                         || ' pcmoneop: '
	                         || pcmoneop;
	  terror   VARCHAR2(200);
	  vobject  VARCHAR2(200):='pac_caja.f_get_cheques';
	  ptwhere  VARCHAR2(200);
	  v_mon    monedas.cmoneda%TYPE;
	BEGIN
	    IF pcmoneop IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=1;

	    SELECT DISTINCT cmoneda
	      INTO v_mon
	      FROM monedas
	     WHERE cmonint=pcmoneop;

	    vpasexec:=2;

	    ptselect:='SELECT cdm.cmedmov,  ff_desvalorfijo(481, '
	              || pcidioma
	              || ', cdm.cmedmov) as tmedmov,
		                          cdm.ncheque, cdm.cbanco, b.tbanco, cdm.imovimi, cdm.festchq, cdm.cestchq,
		                          ff_desvalorfijo(483, '
	              || pcidioma
	              || ', cdm.cmedmov) as testchq, cdm.seqcaja,
		                          cdm.nnumlin
		                   FROM   caja_datmedio cdm, cajamov cm, bancos b
		                   WHERE  cdm.cestchq = 1
		                   AND    cdm.nrefdeposito IS NULL
		                   AND    cdm.cmedmov in (1,3)
		                   AND    cm.cmoneop = '
	              || v_mon
	              || '
		                   AND    cm.seqcaja = cdm.seqcaja
		                   AND    cm.cusuari = '''
	              || f_user
	              || '''
		                   AND    cdm.cbanco = b.cbanco(+)';

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, ptselect);

	             RETURN 1;
	END f_get_cheques;

	/* Bug 0032660/0190245 - 12/11/2014 - JMF*/
	/* inserta movimiento y medio (efectivo o actualiza cheques)*/
	/* en pCHEQUES llega clave de caja_datmedio, secuencia en nombre_columna y linea en valor_columna*/
	FUNCTION f_confirmadeposito(
			pctipmov	IN	NUMBER,
			pcusuari	IN	VARCHAR2,
			pcmoneop	IN	NUMBER,
			pimovimi	IN	NUMBER,
			pffecmov	IN	DATE,
			pnrefdeposito	IN	NUMBER,
			pcmedmov	IN	NUMBER,
			pcheques	IN	T_IAX_INFO
	) RETURN NUMBER
	IS
	  /**/
	  vobject   VARCHAR2(200):='PAC_CAJA.f_confirmadeposito';
	  vparam    VARCHAR2(2000):='tip='
	                         || pctipmov
	                         || ' usu='
	                         || pcusuari
	                         || ' mon='
	                         || pcmoneop
	                         || ' imp='
	                         || pimovimi
	                         || ' fec='
	                         || pffecmov
	                         || ' ref='
	                         || pnrefdeposito
	                         || ' med='
	                         || pcmedmov;
	  vparamaux VARCHAR2(2000);
	  vpasexec  NUMBER(3):=1;
	  num_err   NUMBER:=0;
	  /**/
	  v_seqcaja cajamov.seqcaja%TYPE;
	  v_seq     caja_datmedio.seqcaja%TYPE;
	  v_lin     caja_datmedio.nnumlin%TYPE;
	  v_sel     NUMBER(1);
	BEGIN
	    vpasexec:=100;

	    /* Validaciones*/
	    IF pctipmov IS NULL THEN
	      RETURN 9907185;
	    END IF;

	    IF pctipmov<>4 THEN
	      /* Cierre caja: confirmacion deposito*/
	      RETURN 9907186;
	    END IF;

	    IF pcusuari IS NULL THEN
	      RETURN 9904612;
	    END IF;

	    IF pcmoneop IS NULL THEN
	      RETURN 9905579;
	    END IF;

	    IF pimovimi IS NULL THEN
	      RETURN 9901337;
	    END IF;

	    IF pimovimi<=0 THEN
	      RETURN 9907187;
	    END IF;

	    IF pffecmov IS NULL THEN
	      RETURN 9907188;
	    END IF;

	    IF pnrefdeposito IS NULL THEN
	      RETURN 9907189;
	    END IF;

	    IF pcmedmov IS NULL THEN
	      RETURN 9907190;
	    END IF;

	    IF pcmedmov NOT IN(0, 1) THEN
	      /* Efectivo, Cheque*/
	      RETURN 9907190;
	    END IF;

	    /*      -- Bug 0032660/0190245 - 12/11/2014 - JMF
	          -- Si el importe supera los ingresos en efectivo realizados en la fecha y moneda de la operacion,
	          -- mostrar aviso "El importe excede el valor ingresado en efectivo"
	          -- y dar la opcion de cancelar o continuar.
	          IF pcmedmov = 0 THEN
	    -----------------------
	    -- Acciones Efectivo --
	    -----------------------
	             vpasexec := 110;
	             num_err := pac_caja.f_insmvtocaja(gempres, pcusuari, NULL, pffecmov, pctipmov,
	                                               pimovimi, pcmoneop, v_seqcaja, NULL, NULL, NULL,
	                                               NULL, NULL);

	             IF num_err <> 0 THEN
	                RETURN num_err;
	             END IF;

	             vpasexec := 120;
	             num_err := pac_caja.f_inscajadatmedio(v_seqcaja, NULL, NULL, NULL, NULL, NULL, NULL,
	                                                   NULL, pimovimi, pcmedmov, pcmoneop,
	                                                   pnrefdeposito);

	             IF num_err <> 0 THEN
	                RETURN num_err;
	             END IF;
	          ELSIF pcmedmov = 1 THEN
	    ----------------------
	    -- Acciones Cheques --
	    ----------------------
	             IF pcheques IS NULL THEN
	                -- error, sin cheques
	                RETURN 1;
	             END IF;

	             vpasexec := 129;

	             IF pcheques.COUNT = 0 THEN
	                -- error, sin cheques
	                RETURN 1;
	             END IF;

	             vpasexec := 130;
	             num_err := pac_caja.f_insmvtocaja(gempres, pcusuari, NULL, pffecmov, pctipmov,
	                                               pimovimi, pcmoneop, v_seqcaja, NULL, NULL, NULL,
	                                               NULL, NULL);

	             IF num_err <> 0 THEN
	                RETURN num_err;
	             END IF;

	             vpasexec := 140;
	             vparamaux := vparam;
	             v_sel := 0;

	             FOR i IN pcheques.FIRST .. pcheques.LAST LOOP
	                IF NVL(pcheques(i).seleccionado, 0) = 1 THEN
	                   v_sel := 1;
	                   vpasexec := 150;
	                   vparam := vparamaux || ' seq=' || pcheques(i).nombre_columna || ' lin='
	                             || pcheques(i).valor_columna;
	                   vpasexec := 160;
	                   v_seq := TO_NUMBER(pcheques(i).nombre_columna);
	                   vpasexec := 170;
	                   v_lin := TO_NUMBER(pcheques(i).valor_columna);
	                   vpasexec := 180;

	                   UPDATE caja_datmedio
	                      SET cestchq = 2,
	                          nrefdeposito = pnrefdeposito
	                    WHERE seqcaja = v_seq
	                      AND nnumlin = v_lin;
	                END IF;
	             END LOOP;

	             IF v_sel = 0 THEN
	                RETURN 9907191;
	             END IF;
	          END IF;*/
	    IF pcmedmov=1 THEN
	      IF pcheques IS NULL THEN
	        /* error, sin cheques*/
	        RETURN 1;
	      END IF;

	      vpasexec:=109;

	      IF pcheques.count=0 THEN
	        /* error, sin cheques*/
	        RETURN 1;
	      END IF;
	    END IF;

	    /* Bug 0032660/0190245 - 12/11/2014 - JMF*/
	    /* Si el importe supera los ingresos en efectivo realizados en la fecha y moneda de la operacion,*/
	    /* mostrar aviso "El importe excede el valor ingresado en efectivo"*/
	    /* y dar la opcion de cancelar o continuar.*/
	    /*---------------------*/
	    /* Acciones          --*/
	    /*---------------------*/
	    vpasexec:=110;

	    num_err:=pac_caja.f_insmvtocaja(gempres, pcusuari, NULL, pffecmov, pctipmov, pimovimi, pcmoneop, v_seqcaja, NULL, NULL, NULL, NULL, NULL);

	    IF num_err<>0 THEN
	      RETURN num_err;
	    END IF;

	    vpasexec:=120;

	    num_err:=pac_caja.f_inscajadatmedio(v_seqcaja, NULL, NULL, NULL, NULL, NULL, NULL, NULL, pimovimi, pcmedmov, pcmoneop, pnrefdeposito);

	    IF num_err<>0 THEN
	      RETURN num_err;
	    END IF;

	    IF pcmedmov=1 THEN
	    /*--------------------*/
	    /* Acciones Cheques --*/
	      /*--------------------*/
	      vpasexec:=140;

	      vparamaux:=vparam;

	      v_sel:=0;

	      FOR i IN pcheques.first .. pcheques.last LOOP
	          IF nvl(pcheques(i).seleccionado, 0)=1 THEN
	            v_sel:=1;

	            vpasexec:=150;

	            vparam:=vparamaux
	                    || ' seq='
	                    || pcheques(i).nombre_columna
	                    || ' lin='
	                    || pcheques(i).valor_columna;

	            vpasexec:=160;

	            v_seq:=to_number(pcheques(i).nombre_columna);

	            vpasexec:=170;

	            v_lin:=to_number(pcheques(i).valor_columna);

	            vpasexec:=180;

	            UPDATE caja_datmedio
	               SET cestchq=2,nrefdeposito=pnrefdeposito
	             WHERE seqcaja=v_seq AND
	                   nnumlin=v_lin;
	          END IF;
	      END LOOP;

	      IF v_sel=0 THEN
	        RETURN 9907191;
	      END IF;
	    END IF;

	    vpasexec:=200;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);

	             RETURN 102555; /* error al insertar el movimiento de caja*/
	END f_confirmadeposito;

	/*FIN BUG 32661:NSS:03/11/2014*/
	/* Bug 0032660/0190245 - 12/11/2014 - JMF*/
	/* Calcular el codigo comercio asociado al agente que tiene definido el usuario*/
	FUNCTION f_comercio_usuario(
			pcusuari	IN	VARCHAR2
	) RETURN NUMBER
	IS
	  /**/
	  v_emp usuarios.cempres%TYPE;
	  v_ret NUMBER;
	BEGIN
	    SELECT max(cempres)
	      INTO v_emp
	      FROM usuarios a
	     WHERE a.cusuari=pcusuari;

	    IF v_emp IS NULL THEN
	      v_ret:=NULL;
	    ELSE
	      v_ret:=nvl(pac_parametros.f_parempresa_n(v_emp, 'COMERCIO_DEF'), '99999999');
	    END IF;

	    RETURN v_ret;
	END f_comercio_usuario;

	/**/
	/*BUG 32667:NSS:13/10/2014*/
	/******************************************************************************
	  NOMBRE:     f_anula_aportini
	  PROPOSITO:  Funcion que dada la solicitud rechazada nos generará un apunte de devolucion del pago inicial,
	              si existe algún pago inicial para este cliente/producto.
	  PARAMETROS: sseguro
	              sproduc
	       return            : 0 -> Todo correcto
	                           1 -> Se ha producido un error
	*****************************************************************************/
	FUNCTION f_anula_aportini(
			psseguro	IN	NUMBER,
			psproduc	IN	NUMBER
	) RETURN NUMBER
	IS
	  vpasexec NUMBER(8):=1;
	  vparam   VARCHAR2(2000):='psseguro = '
	                         || psseguro
	                         || ' psproduc: '
	                         || psproduc;
	  terror   VARCHAR2(200);
	  vobject  VARCHAR2(200):='pac_caja.f_anula_aportini';
	  vsperson tomadores.sperson%TYPE;
	  vnumerr  NUMBER;
	  vncheque caja_datmedio.ncheque%TYPE;
	  vcestchq caja_datmedio.cestchq%TYPE;
	  vcbanco  caja_datmedio.cbanco%TYPE;
	  vccc     caja_datmedio.ccc%TYPE;
	  vctiptar caja_datmedio.ctiptar%TYPE;
	  vntarget caja_datmedio.ntarget%TYPE;
	  vfcadtar caja_datmedio.fcadtar%TYPE;
	  vcmedmov caja_datmedio.cmedmov%TYPE;
	  ltdescri ctacliente.tdescri%TYPE;
	  vnvalor  NUMBER;
	BEGIN
	    IF psseguro IS NULL  OR
	       psproduc IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vpasexec:=1;

	    SELECT sperson
	      INTO vsperson
	      FROM tomadores
	     WHERE sseguro=psseguro;

	    vpasexec:=101;

	    FOR z IN (SELECT nvalor
	                FROM pregunpolsegtab
	               WHERE sseguro=psseguro AND
	                     cpregun=432 AND
	                     ccolumna=1) LOOP
	        vpasexec:=2;

	        FOR x IN (SELECT cempres,cusuari,iimpope,cmoneda,seqcaja,nnumlin
	                    FROM ctacliente c1
	                   WHERE sperson=vsperson AND
	                         cmovimi=0 AND
	                         sproduc=psproduc AND
	                         seqcaja=z.nvalor AND
	                         NOT EXISTS(SELECT 1
	                                      FROM ctacliente c2
	                                     WHERE c2.cempres=c1.cempres AND
	                                           c2.sperson=c1.sperson AND
	                                           c2.sseguro=c1.sseguro AND
	                                           c2.sproduc=c1.sproduc AND
	                                           c2.cmovimi=6 AND
	                                           c2.iimpope=c1.iimpope*(-1))) LOOP
	            vpasexec:=3;

	            /* Inserta movimiento*/
	            vnumerr:=pac_caja.f_insmvtocaja(x.cempres, x.cusuari, vsperson, f_sysdate, 1, x.iimpope*(-1), x.cmoneda, x.seqcaja);

	            IF vnumerr<>0 THEN
	              RAISE e_object_error;
	            END IF;

	            vpasexec:=4;

	            BEGIN
	                SELECT ncheque,cestchq,cbanco,ccc,ctiptar,ntarget,fcadtar,cmedmov
	                  INTO vncheque, vcestchq, vcbanco, vccc,
	                vctiptar, vntarget, vfcadtar, vcmedmov
	                  FROM caja_datmedio
	                 WHERE seqcaja=z.nvalor AND
	                       nnumlin=x.nnumlin;
	            EXCEPTION
	                WHEN no_data_found THEN
	                  NULL;
	            END;

	            vpasexec:=5;

	            /* Inserta Datos del medio*/
	            vnumerr:=pac_caja.f_inscajadatmedio(x.seqcaja, vncheque, vcestchq, vcbanco, vccc, vctiptar, vntarget, vfcadtar, x.iimpope*(-1), vcmedmov, x.cmoneda);

	            IF vnumerr<>0 THEN
	              RAISE e_object_error;
	            END IF;

	            vpasexec:=6;

	            ltdescri:=f_axis_literales(9907491, gidioma)
	                      || z.nvalor;

	            vnumerr:=pac_ctacliente.f_ins_pagoinictacli(x.cempres, vsperson, 0, f_sysdate, x.iimpope*(-1), x.cmoneda, psproduc, x.seqcaja, NULL, ltdescri, 1);

	            IF vnumerr<>0 THEN
	              RAISE e_object_error;
	            END IF;

	            vpasexec:=7;
	        END LOOP;
	    END LOOP;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);

	             RETURN 'SELECT 1 FROM DUAL';
	END f_anula_aportini;

	/*-  3.6.1.2.4.2     PAC_IAX_CAJA.F_UPDATE_CAJA  ACL*/
	/******************************************************************************
	 NOMBRE:     F_UPDATE_CAJA
	 PROPOSITO:  Funcion que realiza un update de los campos CAJA_DATMEDIO.CESTCHE
	             y CAJA_DATMEDIO.FAUTORI.

	 PARAMETROS:

	      return            : 0 -> Todo correcto
	                          1 -> Se ha producido un error

	*****************************************************************************/
	FUNCTION f_update_caja(
			pseqcaja	IN	NUMBER
	) RETURN NUMBER
	IS
	  v_cestchq NUMBER;
	  vparam    VARCHAR2(2000):='PSEQCAJA = '
	                         || pseqcaja;
	  vobject   VARCHAR2(200):='PAC_CAJA.f_update_caja';
	  vpasexec  NUMBER(8):=1;
	BEGIN
	    SELECT cestchq
	      INTO v_cestchq
	      FROM caja_datmedio
	     WHERE seqcaja=pseqcaja;

	    vpasexec:=2;

	    IF v_cestchq=0 THEN
	      UPDATE caja_datmedio
	         SET cestchq=1,fautori=f_sysdate
	       WHERE seqcaja=pseqcaja;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);

	             RETURN SQLCODE;
	END f_update_caja;

	/* Fin de 3.6.1.2.4.2  Pac_caja.f_update_caja (NUEVA) ACL*/
	/* Bug 33886/202377 - 16/04/2015*/
		   /* Function que devuelve un cursor con los movimientos de caja*/
	FUNCTION f_lee_cajamov(
			psseguro	IN	seguros.sseguro%TYPE,
			pseqcaja	IN	cajamov.seqcaja%TYPE,
			pstatus	IN	NUMBER
	) RETURN SYS_REFCURSOR
	IS
	  vpasexec NUMBER(8):=1;
	  vparam   VARCHAR2(2000):='pseqcaja = '
	                         || pseqcaja
	                         || ' psseguro = '
	                         || psseguro
	                         || ' pstatus: '
	                         || pstatus;
	  terror   VARCHAR2(200);
	  vobject  VARCHAR2(200):='PAC_CAJA.f_lee_cajamov';
	  num_err  axis_literales.slitera%TYPE:=0;
	  cur      SYS_REFCURSOR;
	BEGIN
	    OPEN cur FOR
	      SELECT (SELECT segu.npoliza
	                FROM seguros segu
	               WHERE cd.sseguro=segu.sseguro) npoliza,(SELECT segu.npoliza
	                                                         FROM seguros segu
	                                                        WHERE nvl(sseguro_d, (SELECT max(z.sseguro)
	                                                                                FROM caja_datmedio z
	                                                                               WHERE z.seqcaja=cd.seqcaja_o))=segu.sseguro) npolizad,cd.sseguro sseguro,cm.sperson sperson,f_nombre(p.sperson, 3) tnombre,cd.imovimi,cd.cmedmov,ff_desvalorfijo(1903, pac_md_common.f_get_cxtidioma(), cd.crazon) tmedmov,nvl(sseguro_d, (SELECT max(z.sseguro)
	                                                                                                                                                                                                                                                                                                                    FROM caja_datmedio z
	                                                                                                                                                                                                                                                                                                                   WHERE z.seqcaja=cd.seqcaja_o)) sseguro_d,cd.nnumlin,cd.seqcaja
	        FROM cajamov cm,caja_datmedio cd,per_personas p
	       WHERE cm.seqcaja=nvl(pseqcaja, cm.seqcaja) AND
	             cd.seqcaja=cm.seqcaja AND
	             cd.sseguro=psseguro AND
	             cd.cestado=nvl(pstatus, cd.cestado) AND
	             p.sperson=cm.sperson AND
	             NOT EXISTS(SELECT 1 /*que no exista algo posterior, aplicas a una tranfer y despues en estado de autorizacion.*/
	                          FROM caja_datmedio z
	                         WHERE z.cestado>cd.cestado AND
	                               z.seqcaja_o=cd.seqcaja
	                        UNION
	                        SELECT 1 /*que no exista algo posterior, aplicas a una tranfer y despues en estado de autorizacion.*/
	                          FROM caja_datmedio z
	                         WHERE z.cestado>cd.cestado AND
	                               z.sseguro=cd.sseguro AND
	                               z.nrefdeposito=cd.seqcaja);
	             /*pd.cagente=ff_agente_cpervisio((SELECT s.cagente
	                                               FROM seguros s
	                                              WHERE s.sseguro=cd.sseguro));*/

	    vpasexec:=3;

	    RETURN cur;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN cur;
	END f_lee_cajamov;

	/* Bug 33886/202377 - 04/05/2015*/
	/* Funcion que devuelve datos de datmedio para la pantalla de reembolso*/
	FUNCTION f_lee_datmedio_reembolso(
			psseguro	IN	caja_datmedio.sseguro%TYPE,
			psperson	IN	cajamov.sperson%TYPE,
			pcestado	IN	caja_datmedio.cestado%TYPE
	) RETURN SYS_REFCURSOR
	IS
	  vpasexec NUMBER(8);
	  vsseguro NUMBER;
	  vparam   VARCHAR2(2000):='psseguro = '
	                         || psseguro
	                         || ' pcestado = '
	                         || pcestado;
	  terror   VARCHAR2(200);
	  vobject  VARCHAR2(200):='PAC_CAJA.f_lee_datmedio_reembolso';
	  num_err  axis_literales.slitera%TYPE:=0;
	  cur      SYS_REFCURSOR;
	  vidioma  detvalores.cidioma%TYPE:=pac_md_common.f_get_cxtidioma();
	BEGIN
	    vpasexec:=1;

	    OPEN cur FOR
	      SELECT cd.crazon tippag,cd.seqcaja,cd.nnumlin,cd.imovimi,
               NVL ((SELECT cm1.cusuari FROM cajamov cm1 WHERE cm1.seqcaja = cd.seqcaja_o AND ROWNUM = 1),cm.cusuari) cusuari,
               cm.sperson,f_nombre(p.sperson,3) tnombre,
               NVL ((SELECT cm1.ffecmov FROM cajamov cm1 WHERE cm1.seqcaja = cd.seqcaja_o AND ROWNUM = 1),cm.ffecmov) ffecmov,
               (SELECT npoliza
                    FROM seguros
                   WHERE sseguro=cd.sseguro) npoliza,
               cd.cestado,ff_desvalorfijo(8001015, vidioma, cd.cestado) estado,
               cd.cmedmov,ff_desvalorfijo(481, vidioma, cd.cmedmov) metodo,
               ff_desvalorfijo(1903, vidioma, cd.crazon) crazon,cd.sseguro,
               decode(cd.sseguro_d, NULL, '', (SELECT npoliza
                                                FROM seguros
                                               WHERE sseguro=cd.sseguro_d)) npolizad
	        FROM cajamov cm,caja_datmedio cd,per_personas p
	       WHERE cd.sseguro=nvl(psseguro, cd.sseguro) AND
	             cd.cestado=nvl(pcestado, cd.cestado) AND
	             cm.seqcaja=cd.seqcaja AND
	             cm.sperson=nvl(psperson, cm.sperson) AND
	             p.sperson=cm.sperson AND
	             cd.cestado!=1 AND
	             NOT EXISTS(SELECT 1 /*que no exista algo posterior, aplicas a una tranfer y despues en estado de autorizacion.*/
	                          FROM caja_datmedio z
	                         WHERE z.cestado>cd.cestado AND
	                               z.seqcaja_o=cd.seqcaja
	                        UNION
	                        SELECT 1 /*que no exista algo posterior, aplicas a una tranfer y despues en estado de autorizacion.*/
	                          FROM caja_datmedio z
	                         WHERE z.cestado>cd.cestado AND
	                               z.sseguro=cd.sseguro AND
	                               z.nrefdeposito=cd.seqcaja)
	             /* AND pd.cagente=ff_agente_cpervisio((SELECT s.cagente
	                                               FROM seguros s
	                                              WHERE s.sseguro=cd.sseguro))*/
	      /*Inicio Mantis 33886/216010  - BLA - DD09/MM11/2015.*/
	      UNION ALL
	      SELECT decode (s.ccausin, 3, 26,
	                                4, 25,
	                                5, 22,
	                                196, 23,
	                                1180, 23,
	                                1196, 23,
	                                1181, 24,
	                                1195, 24,
	                                190, 27,
	                                191, 27,
	                                192, 27,
	                                1190, 27,
	                                1191, 27,
	                                1192, 27,
	                                194, 28,
	                                1194, 28,
	                                20) tippag,stp.sidepag,to_number(stp.nsinies),stp.isinret,stp.cusualt,stp.sperson,f_nombre(p.sperson,3) tnombre,stmp.fefepag ffecmov,(SELECT npoliza
	                                                                                                                                                                           FROM seguros
	                                                                                                                                                                          WHERE sseguro=s.sseguro) npoliza,decode(stmp.cestpag, 0, 1,
	                                                                                                                                                                                                                                1, 3,
	                                                                                                                                                                                                                                8, 4,
	                                                                                                                                                                                                                                2, 5,
	                                                                                                                                                                                                                                stmp.cestpag) cestado,ff_desvalorfijo(3, vidioma, stmp.cestpag) estado,decode(stp.cforpag, 2, 1,
	                                                                                                                                                                                                                                                                                                                           stp.cforpag),ff_desvalorfijo(813, vidioma, stp.ctippag) metodo,nvl (ff_desvalorfijo(1903, vidioma, decode (s.ccausin, 3, 26,
	                                                                                                                                                                                                                                                                                                                                                                                                                                                     4, 25,
	                                                                                                                                                                                                                                                                                                                                                                                                                                                     5, 22,
	                                                                                                                                                                                                                                                                                                                                                                                                                                                     196, 23,
	                                                                                                                                                                                                                                                                                                                                                                                                                                                     1180, 23,
	                                                                                                                                                                                                                                                                                                                                                                                                                                                     1196, 23,
	                                                                                                                                                                                                                                                                                                                                                                                                                                                     1181, 24,
	                                                                                                                                                                                                                                                                                                                                                                                                                                                     1195, 24,
	                                                                                                                                                                                                                                                                                                                                                                                                                                                     190, 27,
	                                                                                                                                                                                                                                                                                                                                                                                                                                                     191, 27,
	                                                                                                                                                                                                                                                                                                                                                                                                                                                     192, 27,
	                                                                                                                                                                                                                                                                                                                                                                                                                                                     1190, 27,
	                                                                                                                                                                                                                                                                                                                                                                                                                                                     1191, 27,
	                                                                                                                                                                                                                                                                                                                                                                                                                                                     1192, 27,
	                                                                                                                                                                                                                                                                                                                                                                                                                                                     194, 28,
	                                                                                                                                                                                                                                                                                                                                                                                                                                                     1194, 28)), dc.tcausin) crazon,s.sseguro,NULL npolizad
	        FROM sin_siniestro s,sin_tramita_pago stp,per_personas p,sin_tramita_movpago stmp,sin_descausa dc
	       WHERE stp.cforpag=2 AND
	             s.nsinies=stp.nsinies AND
	             stmp.sidepag=stp.sidepag AND
	             stmp.nmovpag=(SELECT max(stmp1.nmovpag)
	                             FROM sin_tramita_movpago stmp1
	                            WHERE stmp1.sidepag=stp.sidepag) AND
	             p.sperson=stp.sperson AND
	             s.sseguro=nvl(psseguro, s.sseguro) AND
	             nvl(stmp.cestpag, 0) IN(1, 2, 8) AND
	             nvl(stmp.cestpag, 0)=nvl (decode(pcestado, 2, 1,
	                                                        4, 8,
	                                                        5, 2,
	                                                        pcestado), stmp.cestpag) /*> (8001015 --> 800057)  --> Realizar un DECODE porque cambian los CATRIBU de los DETVALORES (8001015 --> 800057)*/
	             AND
	             p.sperson=nvl(psperson, p.sperson) AND
	             dc.ccausin=s.ccausin AND
	             dc.cidioma=vidioma
	             /*AND pd.cagente=ff_agente_cpervisio((SELECT sg.cagente
	                                               FROM seguros sg
	                                              WHERE sg.sseguro=s.sseguro))*/
	       ORDER BY ffecmov DESC;

	    /*Fin Mantis 33886/216010  - BLA - DD09/MM11/2015.*/
	    RETURN cur;
	EXCEPTION
	  WHEN OTHERS THEN
       p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);

       IF cur%isopen THEN
         CLOSE cur;
       END IF;

       RETURN cur;
	END f_lee_datmedio_reembolso;
	FUNCTION f_insmovcaja_spl(
			pcempres NUMBER,
      psseguro NUMBER,
      pimporte NUMBER,
			 /*v_seqcaja, --pseqcaja	IN	NUMBER,*/
			 pncheque	IN	VARCHAR2 DEFAULT NULL,
			 /*el número de cheque puede venir de parametro*/
			 pcestchq	IN	NUMBER DEFAULT NULL,/*el estado del cheque*/pcbanco	IN	NUMBER DEFAULT NULL,
			 /*si el pago fue porque el cliente acredito a una cuenta bancaria, el codigo del banco*/
			 pccc	IN	VARCHAR2 DEFAULT NULL,/*el número de cuenta*/pctiptar	IN	NUMBER DEFAULT NULL,
			 /*si fuera por tarjeta de credito el tipo de la tarjeta*/
			 pntarget	IN	NUMBER DEFAULT NULL,
			 /*el número de la tarjeta de crédito*/
			 pfcadtar	IN	VARCHAR2 DEFAULT NULL,
			 /*cuando caduca la tarjeta de crédito*/
			 /*100, --pimovimi	IN	NUMBER, --el importe del movimiento*/
			 pcmedmov	IN	NUMBER DEFAULT NULL,/*>detvalores 841*/pcmoneop	IN	NUMBER DEFAULT 1,
			 /*> 1 EUROS moneda en que se realiza la operacion, debo convertir de esa moneda a la moneda del producto para ver si puedo pagar el recibo*/
			 pnrefdeposito	IN	NUMBER DEFAULT NULL,/*>referencia del deposito*/pcautoriza	IN	NUMBER DEFAULT NULL,
			 /*>codigo de autorizacion si fuera tarjeta de crédito*/
			 pnultdigtar	IN	NUMBER DEFAULT NULL,
			 /*>cuatro últimos dígitos de la tarjeta de crédito*/
			 pncuotas	IN	NUMBER DEFAULT NULL,/*>no aplica para msv*/pccomercio	IN	NUMBER DEFAULT NULL,
			 /*BUG 33886/199827 -JCP*/
			 pcestado	IN	NUMBER DEFAULT 3,
      psseguro_d	IN	NUMBER DEFAULT NULL,
      pcrazon	IN	NUMBER DEFAULT NULL,
      pseqcaja_o NUMBER DEFAULT NULL,
      PSPERSON	IN	NUMBER DEFAULT NULL,
      p_valida_saldo IN NUMBER DEFAULT 1
	)
	RETURN NUMBER
	IS
	  num_err             NUMBER:=0;
	  /*lisaldo        NUMBER := 0;*/
	  /*lisaldo_prod   NUMBER := 0;*/
	  lsmovrec            NUMBER:=NULL;
	  lnliqmen            NUMBER:=NULL;
	  lnliqlin            NUMBER:=NULL;
	  /*v_iimppro      NUMBER := NULL;*/
	  /*v_iimpope      NUMBER := 0;*/
	  v_iimpope           NUMBER:=0;
	  /*v_saldo        NUMBER := 0;*/
	  v_sproduc           NUMBER:=NULL;
	  v_tdescri           ctacliente.tdescri%TYPE;
	  v_sperson           NUMBER:=NULL;
	  v_importe           NUMBER:=0;
	  v_disponible_actual NUMBER:=0;
	  v_total_pagado      NUMBER:=0;
	  v_total_cobrado     NUMBER:=0;
	  v_seqcaja           NUMBER:=0;
	  vobject             VARCHAR2(200):='pac_caja.f_insmovcaja_spl';
	  vpasexec            NUMBER;
	  vparam              VARCHAR2(2000);
	  v_sum               NUMBER;
	  v_trans_sql         NUMBER;
	  v_cbancar           VARCHAR2(500);
	BEGIN
	    v_importe:=pimporte*pac_eco_tipocambio.f_cambio (pac_eco_monedas.f_obtener_moneda_producto(v_sproduc),
	                        /*MONEDA ORIGEN*/
	                        pac_eco_monedas.f_obtener_cmonint(pac_parametros.f_parempresa_n(pcempres, 'MONEDACONTAB')), f_sysdate);

	    /*BMS_OUTPUT.put_line('v_importe ' || v_importe);*/
	    vpasexec:=1;

	    IF psperson IS NULL THEN
	      /**/
	      SELECT sperson
	        INTO v_sperson
	        FROM tomadores
	       WHERE sseguro=psseguro AND
	             nordtom=1;
	    /**/
	    ELSE
	      /**/
	      v_sperson:=psperson;
	    /**/
	    END IF;

	    IF pcmedmov=2 THEN
        BEGIN
	          SELECT cbancar
	            INTO v_cbancar
	            FROM per_ccc p
	           WHERE p.sperson=v_sperson AND
	                 p.cagente=ff_agente_cpervisio((SELECT s.cagente FROM seguros s WHERE s.sseguro=psseguro)) AND
                   p.cdefecto=1;
	      EXCEPTION
          WHEN OTHERS THEN
            BEGIN
                SELECT cbancar
                  INTO v_cbancar
                  FROM per_ccc
                 WHERE sperson=v_sperson AND
                       cdefecto=1 AND
                       ROWNUM = 1;
            EXCEPTION
                WHEN OTHERS THEN
                  RETURN 120130;
            END;
        END;
	    END IF;

	    vpasexec:=2;

	    SELECT sproduc
	      INTO v_sproduc
	      FROM seguros
	     WHERE sseguro=psseguro;

	    /*BMS_OUTPUT.put_line('dos');*/
	    /*realizamos el pago*/
	    vpasexec:=3;

	    /*Validacion de error por sobrepasar montos*/
	    v_sum:=pac_caja.f_get_suma_caja(psseguro, v_sperson, 1);

	    v_trans_sql:=pac_ctacliente.f_transferible_spl(psseguro);

	    IF v_importe>v_trans_sql AND NVL (p_valida_saldo, 1) <> 0 THEN
	      RETURN 9907954;
	    END IF;

	    num_err:=pac_caja.f_insmvtocaja(pcempres=>pcempres, pcusuari=>f_user, psperson=>v_sperson, pffecmov=>f_sysdate, pctipmov=>0, pimovimi=>v_importe, pcmoneop=>pac_parametros.f_parempresa_n(pcempres, 'MONEDACONTAB'), pseqcaja=>v_seqcaja, pcmanual=>0);

	    IF num_err<>0 THEN
	      RETURN 1; /*error en cajamov*/
	    END IF;

	    vpasexec:=4;

	    num_err:=pac_caja.f_inscajadatmedio(pseqcaja=>v_seqcaja, /*pseqcaja IN NUMBER,*/
	             pncheque=>pncheque,
	             /*el número de cheque puede venir de parametro*/
	             pcestchq=>pcestchq, /*el estado del cheque*/
	             pcbanco=>pcbanco,
	             /*si el pago fue porque el cliente acredito a una cuenta bancaria, el codigo del banco*/
	             pccc=>pccc, /*el número de cuenta*/
	             pctiptar=>pctiptar,
	             /*si fuera por tarjeta de credito el tipo de la tarjeta*/
	             pntarget=>pntarget,
	             /*el número de la tarjeta de crédito*/
	             pfcadtar=>pfcadtar,
	             /*cuando caduca la tarjeta de crédito*/
	             pimovimi=>v_importe,
	             /*pimovimi IN NUMBER,     --el importe del movimiento*/
	             pcmedmov=>pcmedmov,
	             /*pcmedmov IN NUMBER,       -->detvalores 841*/
	             pcmoneop=>pac_parametros.f_parempresa_n(pcempres, 'MONEDACONTAB'),
	             /*pcmoneop IN NUMBER,       --> 1 EUROS*/
	             pnrefdeposito=>pnrefdeposito,
	             /*>referencia del deposito*/
	             pcautoriza=>pcautoriza,
	             /*>codigo de autorizacion si fuera tarjeta de crédito*/
	             pnultdigtar=>pnultdigtar,
	             /*>cuatro últimos dígitos de la tarjeta de crédito*/
	             pncuotas=>pncuotas, /*>no aplica para msv*/
	             pccomercio=>NULL, pcestado=>pcestado, psseguro=>psseguro, psseguro_d=>psseguro_d, pcrazon=>pcrazon, pseqcaja_o=>NULL); /*codigo de comecio no aplica para msv);*/

	    IF num_err<>0 THEN
	      RETURN 2; /*error en caja_datmedio*/
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);

	             RETURN 0;
	END f_insmovcaja_spl;
	FUNCTION f_get_suma_caja(
			psseguro	IN	seguros.sseguro%TYPE,
			psperson	IN	per_detper.sperson%TYPE,
			pcestado	IN	NUMBER
	) RETURN NUMBER
	IS
	  vobject  VARCHAR2(200):='pac_caja.f_insmovcaja_spl';
	  vpasexec NUMBER;
	  vparam   VARCHAR2(2000);
	  v_sum    NUMBER:=0;
	  v_seguro NUMBER;
	BEGIN
	    vpasexec:=1;

	    BEGIN
	        SELECT cd.sseguro,SUM(cd.imovimi)
	          INTO v_seguro, v_sum
	          FROM cajamov cm,caja_datmedio cd
	         WHERE cd.seqcaja=cm.seqcaja AND
	               cm.sperson=psperson AND
	               cd.sseguro=psseguro AND
	               cd.cestado=nvl(pcestado, cd.cestado) AND
	               NOT EXISTS(SELECT 1
	                            FROM caja_datmedio z
	                           WHERE z.sseguro=cd.sseguro AND
	                                 z.seqcaja_o=cd.seqcaja AND
	                                 z.cestado>cd.cestado)
	         GROUP BY cd.sseguro;
	    EXCEPTION
	        WHEN no_data_found THEN
	          v_sum:=0;

	          v_seguro:=psseguro;
	    END;

	    vpasexec:=2;

	    RETURN v_sum;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);

	             RETURN 0;
	END f_get_suma_caja;

	/* Funcion que borra de caja_detmedio*/
	FUNCTION f_delmovcaja_spl(
			psseguro	IN	caja_datmedio.sseguro%TYPE,
			pseqcaja	IN	caja_datmedio.seqcaja%TYPE,
			pnnumlin	IN	caja_datmedio.nnumlin%TYPE,
			pcestado	IN	caja_datmedio.cestado%TYPE
	) RETURN NUMBER
	IS
	  vpasexec NUMBER(8):=1;
	  vparam   VARCHAR2(2000):='psseguro = '
	                         || psseguro
	                         || ' pseqcaja = '
	                         || pseqcaja
	                         || ' pcestado: '
	                         || pcestado;
	  terror   VARCHAR2(2000);
	  vobject  VARCHAR2(200):='PAC_CAJA.f_delmovcaja_spl';
	  num_err  axis_literales.slitera%TYPE:=0;
	BEGIN
	    DELETE caja_datmedio
	     WHERE sseguro=psseguro AND
	           seqcaja=pseqcaja AND
	           nnumlin=pnnumlin AND
	           cestado=nvl(pcestado, cestado);

	    COMMIT;

	    RETURN num_err;
	EXCEPTION
	  WHEN OTHERS THEN
	             ROLLBACK;

	             num_err:=9907950;

	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);

	             RETURN num_err;
	END f_delmovcaja_spl;

	/* Funcion que cambia el estado de las transacciones de una caja*/
	FUNCTION f_insmovcaja_apply(
			psseguro	IN	caja_datmedio.sseguro%TYPE,
			psperson	IN	cajamov.sperson%TYPE
	) RETURN NUMBER
	IS
	  vpasexec    NUMBER(8):=1;
	  vparam      VARCHAR2(2000):='psseguro = '
	                         || psseguro
	                         || ' psperson = '
	                         || psperson;
	  terror      VARCHAR2(2000);
	  vobject     VARCHAR2(200):='PAC_CAJA.f_insmovcaja_apply';
	  num_err     axis_literales.slitera%TYPE:=0;
	  v_insertddl VARCHAR2(5000);
	  v_insertval VARCHAR2(32000);
	  v_seqcaja   cajamov.seqcaja%TYPE;
	  v_cajaerr   cajamov.seqcaja%TYPE;

	  /*v_nlinea       number := 0;*/
	  CURSOR cajas IS
	    SELECT s.cempres,s.cusuari,s.sperson,s.ffecmov,s.ctipmov,s.imovimi imovimicajamov,s.iautliq,s.ipagsin,s.cmoneop,s.iimpins iimpinscajamov,s.fcambio,s.fcierre,s.fcontab,s.iautins,s.ipagins,s.iautliqp,s.iautinsp,s.idifcambio,s.cusuapunte,s.cmanual,s.tmotapu,t.*
	      FROM cajamov s,caja_datmedio t
	     WHERE s.sperson=psperson AND
	           t.seqcaja=s.seqcaja AND
	           t.cestado=1 /* todo lo pendiente de aplicar*/
	           AND
	           t.sseguro=psseguro AND
	           NOT EXISTS(SELECT 1
	                        FROM caja_datmedio z
	                       WHERE z.sseguro=t.sseguro AND
	                             z.seqcaja_o=t.seqcaja AND
	                             z.cestado>t.cestado);
	/*and s.sseguro = psseguro
	AND EXISTS(SELECT 'X'
	             FROM caja_datmedio t
	            WHERE t.sseguro = psseguro
	              AND t.cestado = 1
	              AND t.seqcaja = s.seqcaja);*/
	/*CURSOR cajadet(p_seqcaja caja_datmedio.seqcaja%TYPE) IS
	   SELECT *
	     FROM caja_datmedio
	    WHERE seqcaja = p_seqcaja;*/
	BEGIN
	    vpasexec:=1;

	    FOR caj IN cajas LOOP
	        vpasexec:=2;

	        v_cajaerr:=caj.seqcaja;

	        SELECT seqcaja.NEXTVAL
	          INTO v_seqcaja
	          FROM dual;

	        vpasexec:=3;

	        /*select max(nlinea)+ 1
	        into v_nlinea
	        from cajamov
	        where seqcaja = caj.seqcaja;*/
			INSERT INTO cajamov
		           (seqcaja,cempres,cusuari,sperson,ffecmov,ctipmov,
		           imovimi,iautliq,ipagsin,cmoneop,iimpins,
		           fcambio,fcierre,fcontab,iautins,ipagins,
		           iautliqp,iautinsp,idifcambio,cusuapunte,tmotapu,
		           cmanual)
		    VALUES
		           (v_seqcaja,caj.cempres,caj.cusuari,caj.sperson,caj.ffecmov,caj.ctipmov,
		           caj.imovimicajamov,caj.iautliq,caj.ipagsin,caj.cmoneop,caj.iimpinscajamov,
		           caj.fcambio,caj.fcierre,caj.fcontab,caj.iautins,caj.ipagins,
		           caj.iautliqp,caj.iautinsp,caj.idifcambio,caj.cusuapunte,caj.tmotapu,
		           caj.cmanual);


	        vpasexec:=4;

	        /*FOR det IN cajadet(caj.seqcaja) LOOP*/
			INSERT INTO caja_datmedio
		           (seqcaja,dsbanco,ctipche,ctipched,crazon,dsmop,
		           fautori,cestado,sseguro,sseguro_d,seqcaja_o,
		           ncheque,cestchq,festchq,cbanco,ccc,
		           ctiptar,ntarget,fcadtar,nnumlin,cmedmov,
		           imovimi,iimpins,nrefdeposito,cautoriza,nultdigtar,
		           ncuotas)
		    VALUES
		           (v_seqcaja,caj.dsbanco,caj.ctipche,caj.ctipched,caj.crazon,caj.dsmop,
		           caj.fautori,2,caj.sseguro,caj.sseguro_d,caj.seqcaja,
		           caj.ncheque,caj.cestchq,caj.festchq,caj.cbanco,caj.ccc,
		           caj.ctiptar,caj.ntarget,caj.fcadtar,caj.nnumlin,caj.cmedmov,
		           caj.imovimi,caj.iimpins,caj.nrefdeposito,caj.cautoriza,caj.nultdigtar,
		           caj.ncuotas);


	        /*END LOOP;*/
	        vpasexec:=5;
	    /*DELETE      caja_datmedio
	          WHERE seqcaja = caj.seqcaja;

	    vpasexec := 6;

	    DELETE      cajamov
	          WHERE seqcaja = caj.seqcaja;*/
	    END LOOP;

	    /*COMMIT;*/
	    RETURN num_err;
	EXCEPTION
	  WHEN OTHERS THEN
	             ROLLBACK;

	             num_err:=9908000;

	             terror:='Error recreando la caja : '
	                     || v_cajaerr
	                     || ' con estado 2';

	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, terror
	                                                                       || ' - '
	                                                                       || SQLERRM);

	             RETURN num_err;
	END f_insmovcaja_apply;
	FUNCTION f_aprueba_caja_spl(
			psseguro	IN	caja_datmedio.sseguro%TYPE,
			psperson	IN	cajamov.sperson%TYPE,
			pseqcaja	IN	cajamov.seqcaja%TYPE,
			pautoriza	IN	NUMBER
	) RETURN NUMBER
	IS
	  vpasexec     NUMBER(8);
	  vparam       VARCHAR2(2000):='psseguro = '
	                         || psseguro
	                         || ' psperson = '
	                         || psperson
	                         || ' pseqcaja = '
	                         || pseqcaja;
	  terror       VARCHAR2(200);
	  vobject      VARCHAR2(200):='PAC_CAJA.f_aprueba_caja_spl';
	  num_err      axis_literales.slitera%TYPE:=0;
	  v_numlin     caja_datmedio.nnumlin%TYPE;
	  v_imovimi    caja_datmedio.imovimi%TYPE;
	  v_cmedmov    caja_datmedio.cmedmov%TYPE;
	  v_crazon     caja_datmedio.crazon%TYPE;
	  v_cusuario   cajamov.cusuari%TYPE;
	  v_ffecmov    cajamov.ffecmov%TYPE;
	  v_sseguro_d  caja_datmedio.sseguro_d%TYPE;
	  v_recidivism NUMBER:=pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'RECIDIVISM');
	  v_nreembolso NUMBER:=0;
	  v_cempres    NUMBER;
	  v_seqcaja2   NUMBER;
	  v_seqcaja    NUMBER;
	  v_sproduc    NUMBER;
	  v_ifee       NUMBER:=0;

	  CURSOR cajas IS
	    SELECT s.cempres,s.cusuari,s.sperson,s.ffecmov,
             s.ctipmov,s.imovimi imovimicajamov,s.iautliq,
             s.ipagsin,s.cmoneop,s.iimpins iimpinscajamov,
             s.fcambio,s.fcierre,s.fcontab,s.iautins,
             s.ipagins,s.iautliqp,s.iautinsp,s.idifcambio,
             s.cusuapunte,s.cmanual,s.tmotapu,t.*
	      FROM cajamov s,caja_datmedio t
	     WHERE s.sperson=psperson
         AND t.seqcaja=s.seqcaja
         AND t.cestado=2 /* todo lo pendiente de aprobar/denegar*/
	       AND t.sseguro=psseguro
         AND t.seqcaja=pseqcaja;
	BEGIN
	    vpasexec:=1;

	    IF pautoriza=1 THEN
	      SELECT cd.nnumlin,cd.imovimi,cm.cusuari,cm.ffecmov,cd.cmedmov,cd.crazon,cd.sseguro_d
	        INTO v_numlin, v_imovimi, v_cusuario, v_ffecmov,
	      v_cmedmov, v_crazon, v_sseguro_d
	        FROM cajamov cm,caja_datmedio cd
	       WHERE cd.sseguro=nvl(psseguro, cd.sseguro) AND
	             cm.seqcaja=pseqcaja AND
	             cm.seqcaja=cd.seqcaja AND
	             cm.sperson=nvl(psperson, cm.sperson);

	      vpasexec:=2;

	      SELECT cempres,sproduc
	        INTO v_cempres, v_sproduc
	        FROM seguros
	       WHERE sseguro=psseguro;

	      vpasexec:=3;

	      /*Validacion de cobros por transacciones maximas*/
	      num_err:=pac_ctacliente.f_get_nroreembolsos(psseguro, v_nreembolso);

	      IF num_err<>0 THEN
	        p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, f_axis_literales(num_err, f_usu_idioma));

	        RETURN num_err;
	      END IF;

	      vpasexec:=4;

	      IF (v_nreembolso+1>v_recidivism) THEN
	        v_ifee:=nvl(pac_parametros.f_parproducto_n(v_sproduc, 'REFUND_FEE_POLICY'), 200)/100;
	      ELSE
	        v_ifee:=0;
	      END IF;

	      vpasexec:=5;

	      IF psseguro<>v_sseguro_d THEN
	        v_imovimi:=v_imovimi*-1;

	        /*llamado ctacliente apunte spl*/
	        num_err:=pac_ctacliente.f_apunte_pago_spl(pcempres=>v_cempres, psseguro=>psseguro, pimporte=>v_imovimi,
	                 /*v_seqcaja,   --pseqcaja IN NUMBER,*/
	                 pncheque=>NULL,
	                 /*el número de cheque puede venir de parametro*/
	                 pcestchq=>NULL,
	                 /*el estado del cheque*/
	                 pcbanco=>NULL,
	                 /*si el pago fue porque el cliente acredito a una cuenta bancaria, el codigo del banco*/
	                 pccc=>NULL, /*el número de cuenta*/
	                 pctiptar=>NULL,
	                 /*si fuera por tarjeta de credito el tipo de la tarjeta*/
	                 pntarget=>NULL,
	                 /*el número de la tarjeta de crédito*/
	                 pfcadtar=>NULL,
	                 /*cuando caduca la tarjeta de crédito*/
	                 /*100,   --pimovimi IN NUMBER,     --el importe del movimiento*/
	                 pcmedmov=>v_cmedmov,
	                 /*>detvalores 841*/
	                 pcmoneop=>1,
	                 /*> 1 EUROS  moneda en que se realiza la operacion, debo convertir de esa moneda a la moneda del producto para ver si puedo pagar el recibo*/
	                 pnrefdeposito=>pseqcaja,
	                 /*>referencia del deposito*/
	                 pcautoriza=>NULL,
	                 /*>codigo de autorizacion si fuera tarjeta de crédito*/
	                 pnultdigtar=>NULL,
	                 /*>cuatro últimos dígitos de la tarjeta de crédito*/
	                 pncuotas=>NULL, /*>no aplica para msv*/
	                 pccomercio=>NULL, pdsbanco=>NULL,
	                 /*banco si es que no está listado y es un banco desconocido*/
	                 pctipche=>NULL,
	                 /*tipos de cheque (cheque personal, cheque TII, cheque corporativo)*/
	                 pctipched=>NULL,
	                 /*distintos tipos de cheques draft*/
	                 pcrazon=>v_crazon,
	                 /*tipos de razones (‘top up’, ‘reimburse by cheque’, ‘reimburse by transfer’,’transfer to other prepayment account’)*/
	                 pdsmop=>NULL, /*Texto libre*/
	                 pfautori=>f_sysdate,
	                 /*Fecha en la cual se autoriza o se deniega el pago de un cheque a un cliente*/
	                 pcestado=>3,
	                 /*Estado Reembolso en CajaMov*/
	                 psseguro_d=>v_sseguro_d,
	                 /*Numero de seguro para asociacion destino de dineros*/
	                 pseqcaja_o=>NULL, pseqcaja=>v_seqcaja, psperson=>psperson);

	        IF num_err<>0 THEN
	          p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, f_axis_literales(num_err, f_usu_idioma));

	          RETURN num_err;
	        END IF;

	        /**/
	        vpasexec:=6;

	        num_err:=pac_ctacliente.f_actualiza_nroreembol(psseguro);

	        IF num_err<>0 THEN
	          p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, f_axis_literales(num_err, f_usu_idioma));

	          RETURN num_err;
	        END IF;

          /**/
          /* Ramiro*/
          /* num_err := pac_caja.f_ins_pagoctacliente(psseguro, psperson, ABS(v_imovimi),*/
          /*                                          v_numlin);*/
	        /**/
	        vpasexec:=8;

	        v_imovimi:=v_imovimi*-1; /*SUMA A LA NUEVA POLIZA*/

	        num_err:=pac_ctacliente.f_apunte_pago_spl(pcempres=>v_cempres, psseguro=>v_sseguro_d, pimporte=>v_imovimi,
	                 /*v_seqcaja,   --pseqcaja IN NUMBER,*/
	                 pncheque=>NULL,
	                 /*el número de cheque puede venir de parametro*/
	                 pcestchq=>NULL,
	                 /*el estado del cheque*/
	                 pcbanco=>NULL,
	                 /*si el pago fue porque el cliente acredito a una cuenta bancaria, el codigo del banco*/
	                 pccc=>NULL,
	                 /*el número de cuenta*/
	                 pctiptar=>NULL,
	                 /*si fuera por tarjeta de credito el tipo de la tarjeta*/
	                 pntarget=>NULL,
	                 /*el número de la tarjeta de crédito*/
	                 pfcadtar=>NULL,
	                 /*cuando caduca la tarjeta de crédito*/
	                 /*100,   --pimovimi IN NUMBER,     --el importe del movimiento*/
	                 pcmedmov=>v_cmedmov,
	                 /*>detvalores 841*/
	                 pcmoneop=>1,
	                 /*> 1 EUROS  moneda en que se realiza la operacion, debo convertir de esa moneda a la moneda del producto para ver si puedo pagar el recibo*/
	                 pnrefdeposito=>pseqcaja,
	                 /*>referencia del deposito*/
	                 pcautoriza=>NULL,
	                 /*>codigo de autorizacion si fuera tarjeta de crédito*/
	                 pnultdigtar=>NULL,
	                 /*>cuatro últimos dígitos de la tarjeta de crédito*/
	                 pncuotas=>NULL,
	                 /*>no aplica para msv*/
	                 pccomercio=>NULL, pdsbanco=>NULL,
	                 /*banco si es que no está listado y es un banco desconocido*/
	                 pctipche=>NULL,
	                 /*tipos de cheque (cheque personal, cheque TII, cheque corporativo)*/
	                 pctipched=>NULL,
	                 /*distintos tipos de cheques draft*/
	                 pcrazon=>v_crazon,
	                 /*tipos de razones (‘top up’, ‘reimburse by cheque’, ‘reimburse by transfer’,’transfer to other prepayment account’)*/
	                 pdsmop=>NULL, /*Texto libre*/
	                 pfautori=>f_sysdate,
	                 /*Fecha en la cual se autoriza o se deniega el pago de un cheque a un cliente*/
	                 pcestado=>3,
	                 /*Estado Reembolso en CajaMov*/
	                 psseguro_d=>NULL,
	                 /*Numero de seguro para asociacion destino de dineros*/
	                 pseqcaja_o=>v_seqcaja, pseqcaja=>v_seqcaja2, psperson=>psperson);

	        IF num_err<>0 THEN
	          p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, f_axis_literales(num_err, f_usu_idioma));

	          RETURN num_err;
	        END IF;

          /*Ramiro*/
          /*num_err := pac_ctacliente.f_actualiza_nroreembol(v_sseguro_d);*/
          /*Ramiro*/
          /*num_err := pac_caja.f_ins_pagoctacliente(psseguro, psperson, ABS(v_imovimi),*/
	        /*                                        v_numlin);*/
	        vpasexec:=9;

	        UPDATE caja_datmedio
	           SET /*cestado = 5,*/
	        fautori=f_sysdate
	         WHERE seqcaja=pseqcaja;

	        vpasexec:=10;

	        UPDATE caja_datmedio
	           SET seqcaja_o=v_seqcaja2
	         WHERE seqcaja=v_seqcaja;
	      /* COMMIT;*/
	      ELSE
	        vpasexec:=11;

	        v_imovimi:=(v_imovimi-v_ifee)*-1; /*rEEMBOLSO POLIZA SSEGURO*/

	        IF v_cmedmov=2 THEN
	          vpasexec:=12;

	          num_err:=pac_ctacliente.f_apunte_pago_spl(pcempres=>v_cempres, psseguro=>psseguro, pimporte=>v_imovimi,
	                   /*v_seqcaja,   --pseqcaja IN NUMBER,*/
	                   pncheque=>NULL,
	                   /*el número de cheque puede venir de parametro*/
	                   pcestchq=>NULL,
	                   /*el estado del cheque*/
	                   pcbanco=>NULL,
	                   /*si el pago fue porque el cliente acredito a una cuenta bancaria, el codigo del banco*/
	                   pccc=>NULL, /*el número de cuenta*/
	                   pctiptar=>NULL,
	                   /*si fuera por tarjeta de credito el tipo de la tarjeta*/
	                   pntarget=>NULL,
	                   /*el número de la tarjeta de crédito*/
	                   pfcadtar=>NULL,
	                   /*cuando caduca la tarjeta de crédito*/
	                   /*100,   --pimovimi IN NUMBER,     --el importe del movimiento*/
	                   pcmedmov=>v_cmedmov,
	                   /*>detvalores 841*/
	                   pcmoneop=>1,
	                   /*> 1 EUROS  moneda en que se realiza la operacion, debo convertir de esa moneda a la moneda del producto para ver si puedo pagar el recibo*/
	                   pnrefdeposito=>pseqcaja,
	                   /*>referencia del deposito*/
	                   pcautoriza=>NULL,
	                   /*>codigo de autorizacion si fuera tarjeta de crédito*/
	                   pnultdigtar=>NULL,
	                   /*>cuatro últimos dígitos de la tarjeta de crédito*/
	                   pncuotas=>NULL, /*>no aplica para msv*/
	                   pccomercio=>NULL, pdsbanco=>NULL,
	                   /*banco si es que no está listado y es un banco desconocido*/
	                   pctipche=>NULL,
	                   /*tipos de cheque (cheque personal, cheque TII, cheque corporativo)*/
	                   pctipched=>NULL,
	                   /*distintos tipos de cheques draft*/
	                   pcrazon=>v_crazon,
	                   /*tipos de razones (‘top up’, ‘reimburse by cheque’, ‘reimburse by transfer’,’transfer to other prepayment account’)*/
	                   pdsmop=>NULL, /*Texto libre*/
	                   pfautori=>f_sysdate,
	                   /*Fecha en la cual se autoriza o se deniega el pago de un cheque a un cliente*/
	                   pcestado=>3,
	                   /*Estado Reembolso en CajaMov*/
	                   psseguro_d=>v_sseguro_d,
	                   /*Numero de seguro para asociacion destino de dineros*/
	                   pseqcaja_o=>pseqcaja, pseqcaja=>v_seqcaja, psperson=>psperson);

	          IF num_err<>0 THEN
	            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, f_axis_literales(num_err, f_usu_idioma));

	            RETURN num_err;
	          END IF;

	          /**/
	          vpasexec:=13;

	          num_err:=pac_ctacliente.f_actualiza_nroreembol(psseguro);

	          IF num_err<>0 THEN
	            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, f_axis_literales(num_err, f_usu_idioma));

	            RETURN num_err;
	          END IF;

	          /**/
	          vpasexec:=14;
            SELECT MAX(nnumlin)
              INTO v_numlin
              FROM ctacliente
             WHERE cempres = v_cempres
               AND sseguro = psseguro
               AND sperson = psperson;

	          vpasexec:=141;
	          num_err:=pac_caja.f_ins_pagoctacliente(psseguro, psperson, abs(v_imovimi), v_numlin);

	          IF num_err<>0 THEN
	            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, f_axis_literales(num_err, f_usu_idioma));

	            RETURN num_err;
	          END IF;

	          vpasexec:=15;

	          UPDATE caja_datmedio
	             SET /*cestado = 5,*/
                   fautori=f_sysdate
	           WHERE seqcaja=pseqcaja;
	        /*   COMMIT;*/
	        ELSE
	          vpasexec:=16;

	          num_err:=pac_ctacliente.f_apunte_pago_spl(pcempres=>v_cempres, psseguro=>psseguro, pimporte=>v_imovimi,
	                   /*v_seqcaja,   --pseqcaja IN NUMBER,*/
	                   pncheque=>NULL,
	                   /*el número de cheque puede venir de parametro*/
	                   pcestchq=>NULL,
	                   /*el estado del cheque*/
	                   pcbanco=>NULL,
	                   /*si el pago fue porque el cliente acredito a una cuenta bancaria, el codigo del banco*/
	                   pccc=>NULL, /*el número de cuenta*/
	                   pctiptar=>NULL,
	                   /*si fuera por tarjeta de credito el tipo de la tarjeta*/
	                   pntarget=>NULL,
	                   /*el número de la tarjeta de crédito*/
	                   pfcadtar=>NULL,
	                   /*cuando caduca la tarjeta de crédito*/
	                   /*100,   --pimovimi IN NUMBER,     --el importe del movimiento*/
	                   pcmedmov=>v_cmedmov,
	                   /*>detvalores 841*/
	                   pcmoneop=>1,
	                   /*> 1 EUROS  moneda en que se realiza la operacion, debo convertir de esa moneda a la moneda del producto para ver si puedo pagar el recibo*/
	                   pnrefdeposito=>pseqcaja,
	                   /*>referencia del deposito*/
	                   pcautoriza=>NULL,
	                   /*>codigo de autorizacion si fuera tarjeta de crédito*/
	                   pnultdigtar=>NULL,
	                   /*>cuatro últimos dígitos de la tarjeta de crédito*/
	                   pncuotas=>NULL, /*>no aplica para msv*/
	                   pccomercio=>NULL, pdsbanco=>NULL,
	                   /*banco si es que no está listado y es un banco desconocido*/
	                   pctipche=>NULL,
	                   /*tipos de cheque (cheque personal, cheque TII, cheque corporativo)*/
	                   pctipched=>NULL,
	                   /*distintos tipos de cheques draft*/
	                   pcrazon=>v_crazon,
	                   /*tipos de razones (‘top up’, ‘reimburse by cheque’, ‘reimburse by transfer’,’transfer to other prepayment account’)*/
	                   pdsmop=>NULL, /*Texto libre*/
	                   pfautori=>f_sysdate,
	                   /*Fecha en la cual se autoriza o se deniega el pago de un cheque a un cliente*/
	                   pcestado=>3,
	                   /*Estado Reembolso en CajaMov*/
	                   psseguro_d=>v_sseguro_d,
	                   /*Numero de seguro para asociacion destino de dineros*/
	                   pseqcaja_o=>pseqcaja, pseqcaja=>v_seqcaja, psperson=>psperson);

	          IF num_err<>0 THEN
	            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, f_axis_literales(num_err, f_usu_idioma));

	            RETURN num_err;
	          END IF;

	          /**/
	          vpasexec:=17;

	          num_err:=pac_ctacliente.f_actualiza_nroreembol(psseguro);

	          IF num_err<>0 THEN
	            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, f_axis_literales(num_err, f_usu_idioma));

	            RETURN num_err;
	          END IF;

	          vpasexec:=18;

	          UPDATE caja_datmedio
	             SET /*cestado = 5,*/
                   fautori=f_sysdate
	           WHERE seqcaja=pseqcaja;
	        /*   COMMIT;*/
	        END IF;

	        vpasexec:=19;

	        IF (v_nreembolso+1>v_recidivism) THEN
	          vpasexec:=20;

	          num_err:=pac_ctacliente.f_crea_rec_gasto(psseguro, v_ifee);

	          IF num_err<>0 THEN
	            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, f_axis_literales(num_err, f_usu_idioma));

	            RETURN num_err;
	          END IF;
	        END IF;
	      END IF;
	    ELSE
	      vpasexec:=21;

	    /*-denegado*/
	      /*UPDATE caja_datmedio
	         SET cestado = 4,
	             fautori = f_sysdate
	       WHERE seqcaja = pseqcaja;*/
	      FOR caj IN cajas LOOP
	          vpasexec:=22;

	          /*v_cajaerr := caj.seqcaja;*/
	          SELECT seqcaja.NEXTVAL
	            INTO v_seqcaja
	            FROM dual;

	          vpasexec:=23;

	          /*select max(nlinea)+ 1
	          into v_nlinea
	          from cajamov
	          where seqcaja = caj.seqcaja;*/
			INSERT INTO cajamov
		           (seqcaja,cempres,cusuari,sperson,ffecmov,ctipmov,
		           imovimi,iautliq,ipagsin,cmoneop,iimpins,
		           fcambio,fcierre,fcontab,iautins,ipagins,
		           iautliqp,iautinsp,idifcambio,cusuapunte,tmotapu,
		           cmanual)
		    VALUES
		           (v_seqcaja,caj.cempres,caj.cusuari,caj.sperson,caj.ffecmov,caj.ctipmov,
		           caj.imovimicajamov*-1,caj.iautliq*-1,caj.ipagsin*-1,caj.cmoneop,caj.iimpinscajamov*-1,
		           caj.fcambio,caj.fcierre,caj.fcontab,caj.iautins,caj.ipagins*-1,
		           caj.iautliqp*-1,caj.iautinsp*-1,caj.idifcambio*-1,caj.cusuapunte,caj.tmotapu,
		           caj.cmanual);


	          vpasexec:=24;

	          /*FOR det IN cajadet(caj.seqcaja) LOOP*/
			INSERT INTO caja_datmedio
		           (seqcaja,dsbanco,ctipche,ctipched,crazon,dsmop,
		           fautori,cestado,sseguro,sseguro_d,seqcaja_o,
		           ncheque,cestchq,festchq,cbanco,ccc,
		           ctiptar,ntarget,fcadtar,nnumlin,cmedmov,
		           imovimi,iimpins,nrefdeposito,cautoriza,nultdigtar,
		           ncuotas)
		    VALUES
		           (v_seqcaja,caj.dsbanco,caj.ctipche,caj.ctipched,caj.crazon,caj.dsmop,
		           caj.fautori,4,caj.sseguro,caj.sseguro_d,caj.seqcaja,
		           /*estado 4, denegado*/caj.ncheque,caj.cestchq,caj.festchq,caj.cbanco,
		           caj.ccc,caj.ctiptar,caj.ntarget,caj.fcadtar,caj.nnumlin,
		           caj.cmedmov,caj.imovimi*-1,caj.iimpins*-1,caj.seqcaja,caj.cautoriza,
		           caj.nultdigtar,caj.ncuotas);


	          /*END LOOP;*/
	          vpasexec:=25;
	      /*DELETE      caja_datmedio
	            WHERE seqcaja = caj.seqcaja;

	      vpasexec := 6;

	      DELETE      cajamov
	            WHERE seqcaja = caj.seqcaja;*/
	      END LOOP;
	    /*COMMIT;*/
	    END IF;

	    /*COMMIT;*/
	    RETURN num_err;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);

	             RETURN 102555;
	END f_aprueba_caja_spl;

	/*************************************************************************
	  funcion que inserta en pago cliente
	  param psseguro: codigo del seguro
	  param psperson : codigo de persona
	  return : resultado del proceso
	  Bug 33886/205948 mnustes
	*************************************************************************/
	FUNCTION f_ins_pagoctacliente(
			psseguro	IN	seguros.sseguro%TYPE,
			psperson	IN	per_personas.sperson%TYPE,
			piimporte	IN	pagoctacliente.iimporte%TYPE,
			pnnumlin	IN	pagoctacliente.nnumlin%TYPE
	) RETURN NUMBER
	IS
	  /**/
	  vpasexec  NUMBER(8):=0;
	  vparam    VARCHAR2(2000):='Parametros - psseguro = '
	                         || psseguro
	                         || ' psperson = '
	                         || psperson;
	  terror    VARCHAR2(200);
	  vobject   VARCHAR2(200):='PAC_CAJA.f_ins_pagoctacliente';
	  /**/
	  ctipban   per_ccc.ctipban%TYPE;
	  ccbancar  per_ccc.cbancar%TYPE;
	  cformapag pagoctacliente.cforpag%TYPE;
	  csproduc  seguros.sproduc%TYPE;
	/**/
	BEGIN
	    /**/
	    BEGIN
	        /**/
	        SELECT pc.ctipban,pc.cbancar,2
	          INTO ctipban, ccbancar, cformapag
	          FROM per_ccc pc
	         WHERE pc.sperson=psperson AND
                 pc.cagente=ff_agente_cpervisio ((SELECT s.cagente FROM seguros s WHERE s.sseguro = psseguro)) AND
	               pc.cdefecto=1;
	    /**/
	    EXCEPTION
        /**/
        WHEN no_data_found THEN
          BEGIN
              /**/
              SELECT pc.ctipban,pc.cbancar,2
                INTO ctipban, ccbancar, cformapag
                FROM per_ccc pc
               WHERE pc.sperson=psperson AND
                     pc.cdefecto=1 AND
                     ROWNUM = 1;
          /**/
          EXCEPTION
              /**/
              WHEN no_data_found THEN
                ctipban:=NULL;

                ccbancar:=NULL;

                cformapag:=NULL;
              WHEN too_many_rows THEN
                ctipban:=NULL;

                ccbancar:=NULL;

                cformapag:=2;
          /**/
          END;
      END;

	    /**/
	    BEGIN
	        /**/
	        SELECT sg.sproduc
	          INTO csproduc
	          FROM seguros sg
	         WHERE sg.sseguro=psseguro;
	    /**/
	    EXCEPTION
	        /**/
	        WHEN no_data_found THEN
	          csproduc:=NULL;
	    /**/
	    END;

	    /**/
			INSERT INTO pagoctacliente
		           (spago,cempres,sseguro,sperson,iimporte,cestado,
		           fliquida,cusuario,falta,cforpag,ctipopag,
		           nremesa,ftrans,nnumlin,ctipban,cbancar,
		           sproduc)
		    VALUES
		           (seqpago.NEXTVAL,pac_md_common.f_get_cxtempresa,psseguro,psperson,piimporte,0,
		           f_sysdate,f_user,f_sysdate,cformapag,1,
		           NULL,NULL,pnnumlin,ctipban,ccbancar,
		           csproduc);


	    /**/
	    RETURN 0;
	/**/
	EXCEPTION
	  WHEN OTHERS THEN
	             /**/
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);

	             RETURN 1;
	/**/
	END f_ins_pagoctacliente;

END pac_caja;

/

