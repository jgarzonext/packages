--------------------------------------------------------
--  DDL for Package Body PAC_TRANSFERENCIAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_TRANSFERENCIAS" AS

   /******************************************************************************
      NOM:       PAC_TRANSFERENCIAS
      REVISIONS:
      Ver        Fecha       Autor  Descripción
      ---------  ----------  -----  ------------------------------------
      1.0        23/06/2009  XPL    0010317: IAX - Análisis de transferencias
      2.0        12/01/2010  DRA    0011396: CRE - Transferencias
      3.0        04/02/2010  DRA    0012913: CRE200 - Mejoras en Transferencias
      4.0        23/03/2010  ICV    4. 0013781: CEM - Modificación fichero de transferencias
      5.0        18/03/2010  FAL    0013153: CEM - Nombres de ficheros generados por AXIS
      6.0        25/03/2010  DRA    6. 0013820: CRE201 - Modificación fichero de transferencias
      7.0        29/04/2010  ICV    7. 0013830: APR707 - Adaptación de las transferencias
      8.0        04/05/2010  DRA    8. 0014344: APRA - Incorporar a transferencias los pagos de liquidación de comisiones
      9.0        18/05/2010  JGR    9. 0014570: AXIS1916 - Pasar a estado transferido
     10.0        10/06/2010  JGR   10. 0014570: AXIS1991 - Pasar a estado transferido II
     11.0        19/07/2010  JRH   11. 0015524: ENSA101 - Posada en marxa plans de pensió beneficiari
     12.0        17/01/2011  ICV   12. 0017289: ENSA101 - Nou cobrador bancari BANCO COMERCIAL ANGOLANO
     13.0        18/01/2011  DRA   13. 0017286: GRC003 - PAC_TRANSFERENCIAS y modelo nuevo siniestros
     14.0        24/01/2011  DRA   14. 0017340: AGA202 - Siniestros de bajas o rentas de invalidez no se pueden trapasar
     15.0        01/03/2011  DRA   15. 0017798: CRE800 - Error en transferències de sinistres de Baixes
     16.0        14/02/2011  JRH   16. 0017247: ENSA103 - Instalar els web-services als entorns CSI
     17.0        11/03/2011  RSC   17. 0017247: ENSA103 - Instalar els web-services als entorns CSI
     18.0        14/04/2011  APD   18. 0018225: AGM704 - Realizar la modificación de precisión el cagente
     19.0        26/09/2011  JMF   19. 0019583: AGA800 :Arxius remeses no passen pel banc
     20.0        03/11/2011  JMF   20. 0019791: LCOL_A001-Modificaciones de fase 0 en la consulta de recibos
     21.0        09/12/2011  JMC   21. 0019238: LCOL_T001- Prèstecs de pòlisses de vida
     22.0        11/01/2012  JMP   22. 0018423: LCOL705 - Multimoneda
     23.0        20/02/2012  JMP   23. 21148/107563: AGM - Buscador de transferencias - Añadir spago en insert remesas_previo
     24.0        18/06/2012  MDS   24. 0022439: AGM - Generación de transferencias
     25.0        11/07/2012  DRA   25. 0022807: CIV800-ERROR EN TRANSFERENCIAS PRODUCTO PIAS
     26.0        20/09/2012  ETM   26. 0023116: ENSA102-Comprobar la realización de pagos parciales en el ambiente de PRE de ENSA
     27.0        25/09/2013  dlF   27. 0028328: Error al crear una tansferencia en PROD
     28.0        04/10/2013  dlF   27. 0028328: Error al crear una tansferencia en PROD-Pago Gastos Mediadores FALTA IVA
     29.0        07/07/2014  AQ    29. 0032028: Transferencias - Error en el fichero de transferencias
     30.0        19/12/2014  RDD   30  0028974: MSV0003-Desarrollo de Comisiones (COM04-Commercial Network Management)
     31.0        27/03/2015  NMM   31. 35316: Error en el fichero de traspaso de siniestros.
     32.0        27/03/2015  NMM   32. 35302: error en la generación de transferencias para siniestros.
     33.0        07/05/2015  NMM   33. 35847: AGM301 - Corrección en transferencias SEPA
     34.0        21/04/2015  YDA   34. 33886/202377: Se modifica la fun. f_insert_remesas_previo para inlcuir el manejo del pago de cta de cliente
     35.0        21/04/2015  YDA   35. 33886/202377: Se modifica la fun. f_transferir para manejar la actualización en la pagoctacliente
     36.0        15/10/2015  IPH   36. 38089/215886 : Se modifica la func.f_get_ctacargo para evitar que se obtengan ccobban inválidos
     37.0        14/01/2016  MDS   37. 0039238/0223588: Liquidación de comisiones según nivel de red comercial (bug hermano interno)
     38.0        30/03/2016  MCA   38. 0041159: Se añade el destinatario del pago para mostrar en el listado de transferencias

   ******************************************************************************/

	PROCEDURE p_insert_ficherosremesa(
			pnremesa	IN	NUMBER,
			vcontrem	IN	NUMBER,
			w_nomfichero	IN	VARCHAR2,
			pncuenta	IN	VARCHAR2
	) IS
	BEGIN
	    BEGIN
			INSERT INTO ficherosremesa
		           (nremesa,nmovimi,nfichero,ncuenta)
		    VALUES
		           (pnremesa,vcontrem,w_nomfichero,pncuenta);

	    EXCEPTION
	        WHEN dup_val_on_index THEN
	          NULL; /* Si ya existe pues nada (no pasará nunca)*/
	    END;
	END p_insert_ficherosremesa;
	FUNCTION insertar_ctaseguro(
			psseguro	IN	NUMBER,
	pfefecto	IN	DATE,
	pnnumlin	IN	NUMBER,
	pffecmov	IN	DATE,
	pffvalmov	IN	DATE,
	pcmovimi	IN	NUMBER,
	pimovimi	IN	NUMBER,
	pimovimi2	IN	NUMBER,
	pnrecibo	IN	NUMBER,
	pccalint	IN	NUMBER,
	pcmovanu	IN	NUMBER,
	pnsinies	IN	NUMBER,
	psmovrec	IN	NUMBER,
	pcfeccob	IN	NUMBER,
			 /*vienen de fmovcta*/
			 pfmovini	IN	DATE,
	pfmovdia	IN	DATE DEFAULT NULL,
	psrecren	IN	NUMBER DEFAULT NULL
	)
	RETURN NUMBER
	IS
	/**/
	/*  DRA. De moment, no té importancia el que vingui*/
	/* pel pfvalmov. En el camp de CTASEGURO, grabem la data efecte (xfefecto).*/
	/**/
	/* Modifiquem la forma d'insertar, fent que la data de contabilitzacio*/
	/* del moviment sigui la data de creacio del rebut, de forma que*/
	/* es contabilitzi correctament el cas d'un cobrament d'un rebut que ens*/
	/* arriba despres del seu "tancament"*/
	/* Si els imports són 0, tornem sense fer rès*/
	  /*  pcfeccob = 1, les dates son les fmovini*/
	  aux_fmovdia DATE;
	  /*encontrado     NUMBER;*/
	  lffecmov    DATE;
	  lffvalmov   DATE;
	  /*v_nmovimi      NUMBER;*/
	  /*v_icapital     NUMBER;*/
	  v_sproduc   NUMBER;
	  num_err     NUMBER;
	BEGIN
	    /*  Si els imports són 0, tornem sense fer rès*/
	    IF nvl(pimovimi, 0)=0 AND
	       nvl(pimovimi2, 0)=0 THEN
	      RETURN 0;
	    END IF;

	    lffecmov:=pffecmov;

	    lffvalmov:=pffvalmov;

	    IF pcfeccob IS NULL THEN
	      aux_fmovdia:=nvl(pfmovdia, f_sysdate);
	    ELSIF pcfeccob=0 THEN
	      aux_fmovdia:=nvl(pfmovdia, f_sysdate);

	      lffecmov:=trunc(f_sysdate);

	      lffvalmov:=trunc(f_sysdate);
	    ELSE /* NP cal posar les dates de movrecibo*/
	      lffecmov:=pfmovini;

	      aux_fmovdia:=nvl(pfmovdia, f_sysdate);

	      lffvalmov:=lffecmov;
	    END IF;

	    num_err:=pac_ctaseguro.f_insctaseguro(psseguro, aux_fmovdia, pnnumlin, trunc(lffecmov), trunc(lffvalmov), pcmovimi, pimovimi, pimovimi2, pnrecibo, pccalint, pcmovanu, pnsinies, psmovrec, NULL, 'R', NULL, NULL, NULL, NULL, psrecren);

	    IF num_err<>0 THEN
	      RETURN num_err;
	    END IF;

	    BEGIN
	        SELECT sproduc
	          INTO v_sproduc
	          FROM seguros
	         WHERE sseguro=psseguro;
	    END;

	    /*  - Quan estem tractant una aportació periòdica o extraordiària*/
	    /* actualitzem la provisió matemàtica de l'assegurança. También en el caso de*/
	    /* anulación de aportación (51)*/
	    /*JRH Añadimos el movimiento 10*/
	    IF pcmovimi IN(1, 2, 10, 51, 53) AND
	       nvl(f_parproductos_v(v_sproduc, 'SALDO_AE'), 0)=1 THEN
	      num_err:=pac_ctaseguro.f_inscta_prov_cap(psseguro, trunc(f_sysdate), 'R', NULL);

	      IF num_err<>0 THEN
	        RETURN num_err;
	      END IF;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN dup_val_on_index THEN
	             RETURN 104879; /* Registre duplicat a CTASEGURO*/
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_transferencias.insertar_ctaseguro', 1, 'Error incontrolado al insertar en CTASEGURO-CTASEGURO_LIBRETA', SQLERRM);

	             RETURN 102555; /* Error al insertar a la taula CTASEGURO*/
	END insertar_ctaseguro;
	FUNCTION insertar_ctaseguro_shw(
			psseguro	IN	NUMBER,
	pfefecto	IN	DATE,
	pnnumlin	IN	NUMBER,
	pffecmov	IN	DATE,
	pffvalmov	IN	DATE,
	pcmovimi	IN	NUMBER,
	pimovimi	IN	NUMBER,
	pimovimi2	IN	NUMBER,
	pnrecibo	IN	NUMBER,
	pccalint	IN	NUMBER,
	pcmovanu	IN	NUMBER,
	pnsinies	IN	NUMBER,
	psmovrec	IN	NUMBER,
	pcfeccob	IN	NUMBER,
			 /*vienen de fmovcta*/
			 pfmovini	IN	DATE,
	pfmovdia	IN	DATE DEFAULT NULL,
	psrecren	IN	NUMBER DEFAULT NULL
	)
	RETURN NUMBER
	IS
	/**/
	/*  DRA. De moment, no té importancia el que vingui*/
	/* pel pfvalmov. En el camp de CTASEGURO, grabem la data efecte (xfefecto).*/
	/**/
	/* Modifiquem la forma d'insertar, fent que la data de contabilitzacio*/
	/* del moviment sigui la data de creacio del rebut, de forma que*/
	/* es contabilitzi correctament el cas d'un cobrament d'un rebut que ens*/
	/* arriba despres del seu "tancament"*/
	/* Si els imports són 0, tornem sense fer rès*/
	  /*  pcfeccob = 1, les dates son les fmovini*/
	  aux_fmovdia DATE;
	  /*encontrado     NUMBER;*/
	  lffecmov    DATE;
	  lffvalmov   DATE;
	  /*v_nmovimi      NUMBER;*/
	  /*v_icapital     NUMBER;*/
	  v_sproduc   NUMBER;
	  num_err     NUMBER;
	BEGIN
	    /*  Si els imports són 0, tornem sense fer rès*/
	    IF nvl(pimovimi, 0)=0 AND
	       nvl(pimovimi2, 0)=0 THEN
	      RETURN 0;
	    END IF;

	    lffecmov:=pffecmov;

	    lffvalmov:=pffvalmov;

	    IF pcfeccob IS NULL THEN
	      aux_fmovdia:=nvl(pfmovdia, f_sysdate);
	    ELSIF pcfeccob=0 THEN
	      aux_fmovdia:=nvl(pfmovdia, f_sysdate);

	      lffecmov:=trunc(f_sysdate);

	      lffvalmov:=trunc(f_sysdate);
	    ELSE /* NP cal posar les dates de movrecibo*/
	      lffecmov:=pfmovini;

	      aux_fmovdia:=nvl(pfmovdia, f_sysdate);

	      lffvalmov:=lffecmov;
	    END IF;

	    num_err:=pac_ctaseguro.f_insctaseguro_shw(psseguro, aux_fmovdia, pnnumlin, trunc(lffecmov), trunc(lffvalmov), pcmovimi, pimovimi, pimovimi2, pnrecibo, pccalint, pcmovanu, pnsinies, psmovrec, NULL, 'R', NULL, NULL, NULL, NULL, psrecren);

	    IF num_err<>0 THEN
	      RETURN num_err;
	    END IF;

	    BEGIN
	        SELECT sproduc
	          INTO v_sproduc
	          FROM seguros
	         WHERE sseguro=psseguro;
	    END;

	    /*  - Quan estem tractant una aportació periòdica o extraordiària*/
	    /* actualitzem la provisió matemàtica de l'assegurança. También en el caso de*/
	    /* anulación de aportación (51)*/
	    /*JRH Añadimos el movimiento 10*/
	    IF pcmovimi IN(1, 2, 10, 51, 53) AND
	       nvl(f_parproductos_v(v_sproduc, 'SALDO_AE'), 0)=1 THEN
	      num_err:=pac_ctaseguro.f_inscta_prov_cap_shw(psseguro, trunc(f_sysdate), 'R', NULL);

	      IF num_err<>0 THEN
	        RETURN num_err;
	      END IF;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN dup_val_on_index THEN
	             RETURN 104879; /* Registre duplicat a CTASEGURO*/
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_transferencias.insertar_ctaseguro_shw', 1, 'Error incontrolado al insertar en CTASEGURO-CTASEGURO_LIBRETA_SHW', SQLERRM);

	             RETURN 102555; /* Error al insertar a la taula CTASEGURO*/
	END insertar_ctaseguro_shw;
	FUNCTION f_transferir(pcempres	IN	NUMBER,pfabono	IN	DATE,/* BUG12913:DRA:04/02/2010*/pnremesa	OUT	NUMBER)
	RETURN NUMBER
	IS
	  w_error       NUMBER;
	  error         NUMBER;
	  /*w_tipoemp      NUMBER;*/
	  /*w_mes          NUMBER;*/
	  /*w_anyo         NUMBER;*/
	  w_ccobban     NUMBER;
	  w_cagente     NUMBER;
	  w_data        DATE;
	  vftransf      DATE;
	  w_moviment    NUMBER;
	  w_nliqmen     NUMBER;
	  w_pnliqlin    NUMBER;
	  num_err       NUMBER:=0;
	  w_smovpag     NUMBER;
	  /*vcontapagados  NUMBER;*/
	  /*vcontapagos    NUMBER;*/
	  vnsinies      NUMBER;
	  vcramo        NUMBER;
	  vcmodali      NUMBER;
	  vctipseg      NUMBER;
	  vccolect      NUMBER;
	  vcactivi      NUMBER;
	  vcgarant      NUMBER;
	  vcvalpar      NUMBER;
	  vntramit      NUMBER;
	  vestsin       NUMBER;
	  vcontapend    NUMBER;
	  vcontacexp    NUMBER;
	  vcontares0    NUMBER; /* BUG17798:DRA:28/02/2011*/
	  vexistrecibo  NUMBER;
	  vexistsini    NUMBER;
	  /*vexistrenta    NUMBER;*/
	  v_cfeccob     productos.cfeccob%TYPE;
	  vcunitra      sin_codtramitador.ctramitad%TYPE;
	  vctramitad    sin_codtramitador.ctramitad%TYPE;
	  vnmovpag      NUMBER;
	  /* Bug 17247 - RSC - 11/03/2011 - ENSA103 - Instalar els web-services als entorns CSI*/
	  vacumpercent  NUMBER:=0;
	  xidistrib     NUMBER;
	  vacumrounded  NUMBER:=0;
	  viuniact      tabvalces.iuniact%TYPE;
	  v_fcontab     ctaseguro.fcontab%TYPE;
	  v_fefecto     ctaseguro.ffecmov%TYPE;
	  v_fvalmov     ctaseguro.fvalmov%TYPE;
	  v_seqgrupo    ctaseguro.ccalint%TYPE; /* NUMBER;  */
	  /*vfdiahabil     DATE;*/
	  v_fcuenta     DATE;
	  xnnumlin      NUMBER;
	  xnnumlinshw   NUMBER;
	  v_ipenali     NUMBER;
	  v_isinret     NUMBER;
	  xcmovimi      NUMBER;
	  v_ipenali_cta NUMBER;
	  v_penali_dif  NUMBER;
	  v_sremesa     NUMBER;
	  vidremesasepa NUMBER(8):=0;
	  w_nomfichero  VARCHAR2(100);
	  v_ccc         VARCHAR2(50);
	  vpasexec      NUMBER:=0;
	  /*vclaveiprovac  NUMBER;*/
	  v_cmultimon   parempresas.nvalpar%TYPE:=nvl(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0);

	CURSOR cur_segdisin2_act(

	    seguro NUMBER) IS
	    SELECT sseguro,ccesta,pdistrec,pdistuni,pdistext
	      FROM segdisin2
	     WHERE sseguro=seguro AND
	           nmovimi=(SELECT max(nmovimi)
	                      FROM segdisin2
	                     WHERE sseguro=seguro AND
	                           ffin IS NULL) AND
	           ffin IS NULL;

	  /* Fin Bug 17247*/
	CURSOR c_remesas(

	    pcempres IN NUMBER) IS
	    /* Bug 10775 - APD - se añaden los campos NREEMB, NFACT, NLINEA y CTIPO al cursor*/
	    SELECT sremesa,cusuario,ccc,nrecibo,nsinies,sidepag,cabono,iimport,sseguro,sproduc,fabono,nremesa,ftransf,cmarcado,cempres,ctipban,ctipban_abono,sperson,nrentas,ccobban,falta,fmodifi,catribu,nreemb,nfact,nlinea,ctipo,spago,cestado,csubestado,descripcion,cmoneda,fcambio,ctapres
	      FROM remesas_previo
	     WHERE cempres=pcempres AND
	           cmarcado=1 AND
	           cusuario=f_user AND
	           (nremesa IS NULL  OR
	            ftransf IS NULL)
	     ORDER BY iimport DESC;
	BEGIN
	    vpasexec:=1;

	    BEGIN
	        SELECT count(1)
	          INTO w_error
	          FROM remesas_previo
	         WHERE cmarcado=1 AND
	               cusuario=f_user
	               /*agg para hacer pruebas con este taller hay que comentar esta linea*/
	               AND
	               (nremesa IS NULL  OR
	                ftransf IS NULL);
	    END;

	    IF w_error=0 THEN
	      p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_transferir', 1, 'NO SE ENCONTRARON REMESAS', 'Sesión Remesa :'
	                                                                                                        || pcempres);

	      RETURN 120135; /*> No hay seleccionado ningún registro.*/
	    END IF;

	    /*Seleccionem la sequencia per el numero de la remesa*/
	    SELECT sremeses.NEXTVAL
	      INTO pnremesa
	      FROM dual;

	    /* Fecha de la transferencia ftransf de remesas*/
	    vftransf:=f_sysdate;

	    vpasexec:=2;

	    FOR reg IN c_remesas(pcempres) LOOP
	    /*--------------------------------------------*/
	    /*--- RECIBOS  -------------------------------*/
	        /*--------------------------------------------*/
	        IF (reg.nrecibo IS NOT NULL) THEN /* Recibos*/
	          vpasexec:=3;

	          SELECT count(*)
	            INTO vexistrecibo
	            FROM remesas
	           WHERE nrecibo=reg.nrecibo AND
	                 ftransf IS NOT NULL AND
	                 nremesa IS NOT NULL; /* recibo ya transferido*/

	          vpasexec:=4;

	          IF vexistrecibo=0 THEN
	          /* Recibos*/
	          BEGIN
	                UPDATE recibos
	                   SET cestimp=8 /* transferido*/
	                 WHERE nrecibo=reg.nrecibo;

	                vpasexec:=5;

	                SELECT ccobban,cagente
	                  INTO w_ccobban, w_cagente
	                  FROM recibos
	                 WHERE nrecibo=reg.nrecibo;
	            EXCEPTION
	                WHEN OTHERS THEN
	                  p_tab_error(f_sysdate, f_user, 'pac_tranferencias.f_transferir', 2, 'Recibo = '
	                                                                                      || reg.nrecibo, SQLERRM);

	                  RETURN 109997;
	            END; vpasexec := 6; IF reg.catribu = 5 THEN /* extorno NO anulación de aportación*/
	          BEGIN SELECT fmovini INTO w_data FROM movrecibo WHERE nrecibo = reg.nrecibo AND cestrec = 0 AND fmovfin IS NULL; EXCEPTION WHEN OTHERS THEN w_data := f_sysdate; END;
	          /* HEM DE GENERAR EL MOVIMENT DE REBUT F_MOVRECIBO*/
	          w_moviment := 0; w_nliqmen := NULL; w_pnliqlin := NULL; vpasexec := 7; BEGIN IF (w_data >= f_sysdate) THEN vpasexec := 8; num_err := f_movrecibo(reg.nrecibo, 01, NULL, NULL, w_moviment, w_nliqmen, w_pnliqlin, w_data, w_ccobban, f_delega(reg.sseguro, w_data), NULL, w_cagente); ELSE vpasexec := 9; num_err := f_movrecibo(reg.nrecibo, 01, NULL, NULL, w_moviment, w_nliqmen, w_pnliqlin, f_sysdate, w_ccobban, f_delega(reg.sseguro, f_sysdate), NULL, w_cagente); END IF; EXCEPTION WHEN OTHERS THEN p_tab_error(f_sysdate, f_user, 'pac_tranferencias.f_transferir', 3, 'ERROR EN F_MOVRECIBO', SQLERRM); RETURN 109997; END; END IF; vpasexec := 10; UPDATE remesas_previo SET ftransf = vftransf, nremesa = pnremesa, fabono = pfabono WHERE nrecibo = reg.nrecibo AND nremesa IS NULL AND cmarcado = 1 AND cusuario = f_user;
	          ELSE
	            RETURN 180800;
	          /* Existen recibos ya transferidos en su selección. Refrescar busqueda de Transferencias.*/
	          END IF;
	        /*--------------------------------------------*/
	        /*--- SINIESTROS  ----------------------------*/
	        /*--------------------------------------------*/
	        ELSIF reg.sidepag IS NOT NULL THEN
	          /* AND reg.catribu <> 11)   -- BUG11396:DRA:20/01/2010*/
	          vpasexec:=11;

	          /* Nuevo modulo de siniestros*/
	          IF pac_parametros.f_parempresa_n(pcempres, 'MODULO_SINI')=1 THEN
	            SELECT s.nsinies,m.cesttra,seg.cramo,seg.cmodali,seg.ctipseg,seg.ccolect,seg.cactivi,p.ntramit
	              INTO vnsinies, vestsin, vcramo, vcmodali,
	            vctipseg, vccolect, vcactivi, vntramit
	              FROM sin_siniestro s,seguros seg,sin_tramita_pago p,sin_tramita_movimiento m
	             WHERE p.sidepag=reg.sidepag AND
	                   seg.sseguro=s.sseguro AND
	                   p.nsinies=s.nsinies AND
	                   m.nsinies=s.nsinies AND
	                   m.ntramit=p.ntramit AND
	                   m.nmovtra IN(SELECT max(nmovtra)
	                                  FROM sin_tramita_movimiento mm
	                                 WHERE mm.nsinies=m.nsinies AND
	                                       mm.ntramit=m.ntramit);

	            vpasexec:=12;

	            SELECT count(*)
	              INTO vexistsini
	              FROM remesas
	             WHERE sidepag=reg.sidepag AND
	                   nsinies=vnsinies AND
	                   ftransf IS NOT NULL AND
	                   nremesa IS NOT NULL;

	            vpasexec:=13;

	            /* pago de siniestros ya transferido*/
	            IF vexistsini=0 THEN BEGIN
	                  /* Siniestros*/
	                  UPDATE sin_tramita_pago
	                     SET ctransfer=2,fordpag=f_sysdate
	                   WHERE sidepag=reg.sidepag;

	                  vpasexec:=14;

	                  /* Cambiamos el estado a transferido del movimiento del pago.*/
	                  SELECT nvl(max(nmovpag), 0)+1
	                    INTO vnmovpag
	                    FROM sin_tramita_movpago
	                   WHERE sidepag=reg.sidepag;

	                  vpasexec:=15;

			INSERT INTO sin_tramita_movpago
		           (sidepag,nmovpag,cestpag,fefepag,cestval,fcontab,
		           sproces,cusualt,falta)
		    VALUES
		           (reg.sidepag,vnmovpag,2,f_sysdate,1,NULL,
		           NULL,f_user,f_sysdate);

	              EXCEPTION
	                  WHEN OTHERS THEN
	                    p_tab_error(f_sysdate, f_user, 'pac_tranferencias.f_transferir', 4, 'ERROR UPDATE SIN_TRAMITA_PAGO', SQLERRM);

	                    RETURN 109997;
	              END; vpasexec := 16;
	            /* BUG 23116:ETM:20/09/2012   --INI*/
	            IF nvl(pac_parametros.f_parempresa_n(reg.cempres, 'CTASEG_PAGO_PARCIAL'), 0) = 1 THEN SELECT scm.cmovimi, i.fsinies, nvl(str.ipenali, 0)
	            /*str.ipago,  NVL(str.icaprie, 0)*/
	            INTO xcmovimi, v_fcuenta, v_ipenali /*, xivalora, , v_icaprisc*/
	            FROM sin_siniestro i, seguros s, sin_causa_motivo scm, sin_gar_causa_motivo sgcm, sin_tramita_reserva str WHERE scm.ccausin = i.ccausin AND scm.cmotsin = i.cmotsin AND scm.scaumot = sgcm.scaumot AND s.sseguro = i.sseguro AND s.sproduc = sgcm.sproduc AND i.nsinies = reg.nsinies AND str.nsinies = i.nsinies AND str.cgarant = sgcm.cgarant AND str.ctipres = 1 AND scm.cmovimi IS NOT NULL AND nvl(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi, str.cgarant, 'GAR_CONTRA_CTASEGURO'), 1) = 1 AND str.nmovres = (SELECT max(nmovres) FROM sin_tramita_reserva WHERE nsinies = str.nsinies AND ntramit = str.ntramit AND cgarant = str.cgarant AND ctipres = 1); vpasexec := 17; SELECT isinret INTO v_isinret FROM sin_tramita_pago WHERE sidepag = reg.sidepag; vpasexec := 18; SELECT nvl(SUM(ipenali), 0) INTO v_ipenali FROM sin_tramita_reserva WHERE nsinies = reg.nsinies AND sidepag IS NULL; vpasexec := 19; SELECT scagrcta.NEXTVAL INTO v_seqgrupo FROM dual; vpasexec := 20;
	            xnnumlin
	            :=
	            pac_ctaseguro.f_numlin_next(reg.sseguro); xnnumlinshw := pac_ctaseguro.f_numlin_next_shw(reg.sseguro); vpasexec := 21; IF nvl(pac_parametros.f_parempresa_n(reg.cempres, 'FCUENTA_FIN_SINIES'), 0) = 1 THEN BEGIN SELECT max(fordpag) INTO v_fcuenta FROM sin_tramita_pago WHERE nsinies = reg.nsinies; EXCEPTION WHEN OTHERS THEN p_tab_error(f_sysdate, f_user, 'pac_tranferencias.f_transferir', 5, 'Error no controlado', SQLERRM); RETURN 140999; /* Error no controlado*/
	            END; END IF; vpasexec := 22; num_err := pac_ctaseguro.f_insctaseguro (reg.sseguro, f_sysdate, xnnumlin, f_sysdate, v_fcuenta, xcmovimi, f_round(v_isinret, pac_monedas.f_moneda_producto(reg.sproduc)), 0, NULL, v_seqgrupo, 0, reg.nsinies, NULL, NULL, 'R'); IF num_err <> 0 THEN RETURN 102555; END IF; vpasexec := 23; IF pac_ctaseguro.f_tiene_ctashadow(reg.sseguro, NULL) = 1 THEN num_err := pac_ctaseguro.f_insctaseguro_shw (reg.sseguro, f_sysdate, xnnumlinshw, f_sysdate, v_fcuenta, xcmovimi, f_round(v_isinret, pac_monedas.f_moneda_producto(reg.sproduc)), 0, NULL, v_seqgrupo, 0, reg.nsinies, NULL, NULL, 'R'); IF num_err <> 0 THEN RETURN 102555; END IF; END IF; vpasexec := 24; IF nvl(f_parproductos_v(reg.sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN IF nvl(v_isinret, 0) > 0 THEN xnnumlin := xnnumlin + 1; num_err := pac_sin_rescates.f_distribuye_ctaseguro(reg.sseguro, xnnumlin, v_fcuenta, xcmovimi, v_isinret, v_seqgrupo, reg.nsinies); vpasexec := 25; IF
	            pac_ctaseguro.f_tiene_ctashadow(reg.sseguro, NULL) = 1 THEN xnnumlinshw := xnnumlinshw + 1; num_err := pac_sin_rescates.f_distribuye_ctaseguro_shw(reg.sseguro, xnnumlinshw, v_fcuenta, xcmovimi, v_isinret, v_seqgrupo, reg.nsinies); END IF; END IF; IF num_err <> 0 THEN RETURN 102555; END IF; END IF; vpasexec := 26; SELECT nvl(SUM(imovimi), 0) INTO v_ipenali_cta FROM ctaseguro WHERE cmovimi = 27 AND sseguro = reg.sseguro AND nsinies = reg.nsinies; vpasexec := 27; IF (nvl(pac_parametros.f_parproducto_n(reg.sproduc, 'GRABA_PENALIZACION'), 0) IN(1, 2)) THEN IF v_ipenali <> v_ipenali_cta THEN IF v_ipenali > v_ipenali_cta THEN v_penali_dif := v_ipenali - v_ipenali_cta; xcmovimi := 27; /*{penalizaci?n (Cvalor = 83)}*/
	            num_err := pac_ctaseguro.f_insctaseguro (reg.sseguro, f_sysdate, xnnumlin, v_fcuenta, v_fcuenta, xcmovimi, f_round(nvl(v_penali_dif, 0), pac_monedas.f_moneda_producto(reg.sproduc)), 0, NULL, v_seqgrupo, 0, reg.nsinies, NULL, NULL); xnnumlin := xnnumlin + 1; vpasexec := 28; IF num_err <> 0 THEN RETURN 102555; END IF; IF pac_ctaseguro.f_tiene_ctashadow(reg.sseguro, NULL) = 1 THEN num_err := pac_ctaseguro.f_insctaseguro_shw (reg.sseguro, f_sysdate, xnnumlinshw, v_fcuenta, v_fcuenta, xcmovimi, f_round(nvl(v_penali_dif, 0), pac_monedas.f_moneda_producto(reg.sproduc)), 0, NULL, v_seqgrupo, 0, reg.nsinies, NULL, NULL); xnnumlinshw := xnnumlinshw + 1; IF num_err <> 0 THEN RETURN 102555; END IF; END IF; vpasexec := 29;
	            /* Generamos los movimientos de detalle en caso de producto Unit Linked*/
	            IF nvl(f_parproductos_v(reg.sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN num_err := pac_sin_rescates.f_distribuye_ctaseguro (reg.sseguro, xnnumlin, v_fcuenta, xcmovimi, nvl(v_penali_dif, 0), v_seqgrupo, reg.nsinies); IF num_err <> 0 THEN RETURN 102555; END IF; vpasexec := 30; IF pac_ctaseguro.f_tiene_ctashadow(reg.sseguro, NULL) = 1 THEN num_err := pac_sin_rescates.f_distribuye_ctaseguro_shw (reg.sseguro, xnnumlinshw, v_fcuenta, xcmovimi, nvl(v_penali_dif, 0), v_seqgrupo, reg.nsinies); IF num_err <> 0 THEN RETURN 102555; END IF; END IF; END IF; END IF; END IF; END IF; END IF; vpasexec := 31;
	            /* FIN--BUG 23116:ETM:20/09/2012*/
	            IF vestsin <> 1 THEN /* El siniestro no está ya finalizado*/
	            /* Si todos los pagos pendientes, no anulados, de un siniestro han*/
	            /* sido pagados y tiene la opcion cierre de expediente marcada,*/
	            /* entonces finalizamos el siniestro*/
	            SELECT count(*) INTO vcontapend FROM sin_tramita_pago p WHERE nsinies = vnsinies AND ctippag IN(2, 7) AND sidepag IN(SELECT sidepag FROM sin_tramita_movpago m WHERE m.cestpag NOT IN(2, 8) AND m.sidepag = p.sidepag AND m.nmovpag IN(SELECT max(nmovpag) FROM sin_tramita_movpago mm WHERE mm.sidepag = m.sidepag)); vpasexec := 32; IF vcontapend = 0 THEN
	            /*pagosini*/
	            /* BUG17340:DRA:24/1/2011:Inici*/
	            SELECT count(*) INTO vcontares0 FROM sin_tramita_pago p, sin_tramita_reserva r WHERE r.nsinies = vnsinies AND r.ireserva = 0 AND p.nsinies = r.nsinies AND p.sidepag = r.sidepag AND p.sidepag IN(SELECT m.sidepag FROM sin_tramita_movpago m WHERE m.cestpag = 2 AND m.sidepag = p.sidepag AND m.nmovpag IN(SELECT max(mm.nmovpag) FROM sin_tramita_movpago mm WHERE mm.sidepag = m.sidepag)) AND p.ctippag = 2;
	            /* BUG17798:DRA:28/02/2011:Fi*/
	            vpasexec := 33;
	            /* BUG17340:DRA:24/1/2011:Fi*/
	            IF vcontares0 >= 1 THEN
	            /* tiene al menos 1 pago con cierre expediente, de tipo pago, en estado pagado*/
	            /* y que no tengan pagos de anulación de pago*/
	            /* Bug 17781 - 25/02/2011 - AMC*/
	            /* Solo finalizamos el siniestros si no quedan recobros por cobrar*/
	            SELECT count(1) INTO vcontacexp FROM sin_tramita_reserva r WHERE r.nsinies = vnsinies AND r.nmovres = (SELECT max(r1.nmovres) FROM sin_tramita_reserva r1 WHERE r1.nsinies = vnsinies) AND((nvl(r.iprerec, 0) - nvl(r.irecobro, 0)) <= 0); vpasexec := 34; IF vcontacexp >= 1 THEN num_err := pac_siniestros.f_get_unitradefecte(pcempres, vcunitra, vctramitad); vpasexec := 35;
	            /* BUG17798:DRA:28/02/2011: Si es de BAJA no se finaliza el siniestro*/
	            BEGIN SELECT r.cgarant INTO vcgarant FROM sin_tramita_reserva r WHERE r.nsinies = vnsinies AND r.ntramit = vntramit AND r.ctipres = 1 /* jlb - 18423#c105054*/
	            AND r.nmovres = (SELECT max(r1.nmovres) FROM sin_tramita_reserva r1 WHERE r1.nsinies = r.nsinies AND r1.ntramit = r.ntramit AND r1.ctipres = r.ctipres
	            /* jlb - 18423#c105054*/
	            ); vpasexec := 36; num_err := f_pargaranpro(vcramo, vcmodali, vctipseg, vccolect, vcactivi, vcgarant, 'BAJA', vcvalpar); EXCEPTION WHEN no_data_found THEN vcvalpar := 0; END; vpasexec := 37; IF nvl(vcvalpar, 0) <> 1 THEN /* Si no es de BAJA entramos*/
	            num_err := pac_siniestros.f_estado_siniestro (vnsinies, 1, /* Estado finalizado.*/
	            NULL, /* pccauest IN NUMBER,*/
	            vcunitra, /*IN VARCHAR2,*/
	            vctramitad, /*IN VARCHAR2,*/
	            NULL, /*pcsubtra IN NUMBER,*/
	            trunc(f_sysdate)); /* pfsinfin IN DATE);*/

	            IF num_err <> 0 THEN p_tab_error(f_sysdate, f_user, 'pac_tranferencias.f_transferir', 41, 'Siniestro = '|| vnsinies|| ', error: '|| num_err|| ', vcunitra: '|| vcunitra|| ', vctramitad: '|| vctramitad, SQLERRM); RETURN num_err; END IF; END IF; END IF; END IF; END IF; END IF; vpasexec := 38; UPDATE remesas_previo SET ftransf = vftransf, nremesa = pnremesa, fabono = pfabono WHERE nsinies = reg.nsinies AND sidepag = reg.sidepag AND nremesa IS NULL AND cmarcado = 1 AND cusuario = f_user;
	            ELSE
	              RETURN 180799;
	            /* Existen pagos de siniestros ya transferidos en su selección. Refrescar busqueda de Transferencias.*/
	            END IF;
	          /* Modulo antiguo*/
	          ELSE
	            vpasexec:=39;

	            SELECT s.nsinies,s.cramo,s.cestsin
	              INTO vnsinies, vcramo, vestsin
	              FROM siniestros s,pagosini p
	             WHERE p.sidepag=reg.sidepag AND
	                   p.nsinies=s.nsinies;

	            vpasexec:=40;

	            SELECT count(*)
	              INTO vexistsini
	              FROM remesas
	             WHERE sidepag=reg.sidepag AND
	                   nsinies=vnsinies AND
	                   ftransf IS NOT NULL AND
	                   nremesa IS NOT NULL;

	            vpasexec:=41;

	            /* pago de siniestros ya transferido*/
	            IF vexistsini=0 THEN BEGIN
	                  UPDATE pagosinitrami
	                     SET cestpag=2,fefepag=f_sysdate
	                   WHERE pagosinitrami.sidepag=reg.sidepag;

	                  vpasexec:=42;

	                  /* Siniestros*/
	                  UPDATE pagosini
	                     SET ctransf=2,ctransfer=2,cestpag=2,fefepag=f_sysdate
	                   WHERE pagosini.sidepag=reg.sidepag;
	              EXCEPTION
	                  WHEN OTHERS THEN
	                    p_tab_error(f_sysdate, f_user, 'pac_tranferencias.f_transferir', 6, 'ERROR UPDATE PAGOSINI O PAGOSINITRAMI', SQLERRM);

	                    RETURN 109997;
	              END; vpasexec := 43; IF vestsin <> 1 THEN /* El siniestro no está ya finalizado*/
	            /* Si todos los pagos pendientes, no anulados, de un siniestro han*/
	            /* sido pagados y tiene la opcion cierre de expediente marcada,*/
	            /* entonces finalizamos el siniestro*/
	            SELECT count(*) INTO vcontapend FROM pagosini WHERE nsinies = vnsinies AND ctippag = 2 AND cestpag NOT IN(2, 8) AND pagosini.sidepag NOT IN( SELECT nvl(pp.spganul, 0) FROM pagosini pp WHERE nsinies = pagosini.nsinies AND cestpag <> 8); vpasexec := 44; IF vcontapend = 0 THEN SELECT count(*) INTO vcontacexp FROM pagosini WHERE nsinies = vnsinies AND cptotal = 1 AND cestpag = 2 AND pagosini.sidepag NOT IN( SELECT nvl(pp.spganul, 0) FROM pagosini pp WHERE nsinies = pagosini.nsinies AND cestpag <> 8) AND ctippag = 2; vpasexec := 45; IF vcontacexp >= 1 THEN
	            /* tiene al menos 1 pago con cierre expediente, de tipo pago, en estado pagado*/
	            /* y que no tengan pagos de anulación de pago*/
	            /* Finaliza siniestro: pac_sin.f_finalizar_sini*/
	            num_err := pac_sin.f_finalizar_sini(vnsinies, 1, vcramo|| '01', trunc(f_sysdate), 100832, f_idiomauser); IF num_err <> 0 THEN p_tab_error(f_sysdate, f_user, 'pac_tranferencias.f_transferir', 7, 'Siniestro = '|| vnsinies, num_err); RETURN num_err; END IF; END IF; END IF; END IF; vpasexec := 46; UPDATE remesas_previo SET ftransf = vftransf, nremesa = pnremesa, fabono = pfabono WHERE nsinies = reg.nsinies AND sidepag = reg.sidepag AND nremesa IS NULL AND cmarcado = 1 AND cusuario = f_user;
	            ELSE
	              RETURN 180799;
	            /* Existen pagos de siniestros ya transferidos en su selección. Refrescar busqueda de Transferencias.*/
	            END IF;
	          END IF;
	        /*--------------------------------------------*/
	        /*--- RENTAS  --------------------------------*/
	        /*--------------------------------------------*/
	        ELSIF reg.catribu=2 THEN
	        /* Bug 17247 - RSC - 11/03/2011 - ENSA103 - Instalar els web-services als entorns CSI*/
	        /* SELECT COUNT(*)*/
	        /* INTO vexistrenta*/
	        /* FROM remesas*/
	        /* WHERE sperson = reg.sperson*/
	        /*   AND nrentas = reg.nrentas*/
	        /*   AND ftransf IS NOT NULL*/
	          /*   AND nremesa IS NOT NULL;   -- pago de renta ya transferido*/
	          vpasexec:=47;

	        /*IF vexistrenta = 0 THEN*/
	          /* Fin Bug 17247*/
	          BEGIN
	              SELECT max(smovpag)+1
	                INTO w_smovpag
	                FROM movpagren
	               WHERE srecren=reg.nrentas;

	              vpasexec:=48;

	              DECLARE
	                  v_fecefec DATE;
	                  xnnumlin  NUMBER;
	                  vimporte  NUMBER;
	                  w_data    DATE;
	              BEGIN
	                  BEGIN
	                      SELECT trunc(fmovini)
	                        INTO w_data
	                        FROM movpagren
	                       WHERE srecren=reg.nrentas AND
	                             fmovfin IS NULL AND
	                             cestrec=0;
	                  EXCEPTION
	                      WHEN OTHERS THEN
	                        w_data:=f_sysdate;
	                  END;

	                  vpasexec:=49;

			INSERT INTO movpagren
		           (srecren,smovpag,cestrec,fmovini,fmovfin,fefecto)

		    VALUES
		           (reg.nrentas,w_smovpag,1,trunc(greatest(w_data, f_sysdate)),NULL,
		           f_sysdate);


	                  vpasexec:=50;

	                  UPDATE pagosrenta
	                     SET nremesa=pnremesa,fremesa=f_sysdate
	                   WHERE srecren=reg.nrentas;

	                  vpasexec:=51;

	                  UPDATE movpagren
	                     /*JRH IMP Yo creo que se debe actualizar la fecha del anterior movimiento*/
	                     SET fmovfin=trunc(greatest(w_data, f_sysdate))
	                   WHERE srecren=reg.nrentas AND
	                         smovpag=w_smovpag-1;

	                  vpasexec:=52;

	                  SELECT trunc(ffecefe),isinret
	                    INTO v_fecefec, vimporte
	                    FROM pagosrenta
	                   WHERE srecren=reg.nrentas;

	                  vpasexec:=53;

	                  SELECT max(nnumlin)
	                    INTO xnnumlin
	                    FROM ctaseguro
	                   WHERE sseguro=reg.sseguro;

	                  vpasexec:=54;

	                  IF pac_ctaseguro.f_tiene_ctashadow(reg.sseguro, NULL)=1 THEN
	                    SELECT max(nnumlin)
	                      INTO xnnumlinshw
	                      FROM ctaseguro_shadow
	                     WHERE sseguro=reg.sseguro;
	                  END IF;

	                  vpasexec:=55;

	                  UPDATE remesas_previo
	                     SET ftransf=vftransf,nremesa=pnremesa,fabono=pfabono
	                   WHERE nrentas=reg.nrentas AND
	                         nremesa IS NULL AND
	                         cmarcado=1 AND
	                         cusuario=f_user;

	                  vpasexec:=56;

	                  /*Ini Bug.: 10110 - ICV - 22/05/2009 - CRE066 - Modificación formulario de pago de rentas*/
	                  BEGIN
	                      SELECT cfeccob
	                        INTO v_cfeccob
	                        FROM productos
	                       WHERE sproduc=reg.sproduc;
	                  EXCEPTION
	                      WHEN OTHERS THEN
	                        v_cfeccob:=NULL;
	                  END;

	                  vpasexec:=57;

	                  /* Bug 17247 - RSC - 11/03/2011 - ENSA103 - Instalar els web-services als entorns CSI*/
	                  IF nvl(f_parproductos_v(reg.sproduc, 'ES_PRODUCTO_INDEXADO'), 0)=1 THEN
	                    SELECT scagrcta.NEXTVAL
	                      INTO v_seqgrupo
	                      FROM dual;
	                  ELSE
	                    v_seqgrupo:=0;
	                  END IF;

	                  /* Fin Bug 17247*/
	                  vpasexec:=58;

	                  /*Fi Bug.:10110*/
	                  num_err:=insertar_ctaseguro(reg.sseguro, f_sysdate, nvl(xnnumlin+1, 1), f_sysdate, f_sysdate, 53, vimporte, NULL, NULL, /*En lugar del recibo*/
	                           v_seqgrupo,
	                           /* Bug 17247 - RSC - 11/03/2011 - ENSA103 - Instalar els web-services als entorns CSI (seqgrupo)*/
	                           0, NULL, NULL, v_cfeccob,
	                           /*vienen de fmovcta*/
	                           greatest(w_data, f_sysdate), f_sysdate, reg.nrentas);

	                  IF num_err<>0 THEN
	                    RETURN num_err;
	                  END IF;

	                  vpasexec:=59;

	                  IF pac_ctaseguro.f_tiene_ctashadow(reg.sseguro, NULL)=1 THEN
	                    num_err:=insertar_ctaseguro_shw(reg.sseguro, f_sysdate, nvl(xnnumlinshw+1, 1), f_sysdate, f_sysdate, 53, vimporte, NULL, NULL, /*En lugar del recibo*/
	                             v_seqgrupo,
	                             /* Bug 17247 - RSC - 11/03/2011 - ENSA103 - Instalar els web-services als entorns CSI (seqgrupo)*/
	                             0, NULL, NULL, v_cfeccob,
	                             /*vienen de fmovcta*/
	                             greatest(w_data, f_sysdate), f_sysdate, reg.nrentas);

	                    IF num_err<>0 THEN
	                      RETURN num_err;
	                    END IF;
	                  END IF;

	                  vpasexec:=60;

	                  /* Bug 17247 - RSC - 11/03/2011 - ENSA103 - Instalar els web-services als entorns CSI*/
	                  IF nvl(f_parproductos_v(reg.sproduc, 'ES_PRODUCTO_INDEXADO'), 0)=1 THEN
	                    SELECT fcontab,ffecmov,fvalmov
	                      INTO v_fcontab, v_fefecto, v_fvalmov
	                      FROM ctaseguro
	                     WHERE sseguro=reg.sseguro AND
	                           nnumlin=nvl(xnnumlin+1, 1);

	                  /* Comprobamos si los fondos están cerrados en el*/
	                    /* momento de la generación del pago de renta.*/
	                    IF to_number(to_char(v_fefecto, 'd')) IN(6, 7) THEN
	                      v_fefecto:=f_diahabil(0, trunc(v_fefecto), NULL);
	                    END IF;

	                    IF to_number(to_char(v_fvalmov, 'd')) IN(6, 7) THEN
	                      v_fvalmov:=f_diahabil(0, trunc(v_fvalmov), NULL);
	                    END IF;

	                    vpasexec:=61;

	                    /* Verificació de fons tancats / oberts*/
	                    IF pac_mantenimiento_fondos_finv.f_get_estado_fondo(pcempres, v_fvalmov)=107742 THEN
	                      /* Obtenemos el siguiente dia habil*/
	                      v_fefecto:=f_diahabil(0, trunc(v_fefecto), NULL);

	                      v_fvalmov:=f_diahabil(0, trunc(v_fvalmov), NULL);
	                    ELSE
	                    /* Obtenemos el siguiente dia habil o la misma fecha si ya es habil!*/
	                    /* (Esto se debe hacer ya que si el fondo no se abre por defecto se considera*/
	                      /* abierto y se colarian rescates en dias no habiles!)*/
	                      v_fefecto:=f_diahabil(13, trunc(v_fefecto), NULL);

	                      v_fvalmov:=f_diahabil(13, trunc(v_fvalmov), NULL);
	                    END IF;

	                    vpasexec:=62;

	                    SELECT max(nnumlin)+1
	                      INTO xnnumlin
	                      FROM ctaseguro
	                     WHERE sseguro=reg.sseguro;

	                    vpasexec:=63;

	                    FOR valor IN cur_segdisin2_act(reg.sseguro) LOOP
	                        vacumpercent:=vacumpercent+(vimporte*valor.pdistrec)/100;

	                        xidistrib:=round(vacumpercent-vacumrounded, 2);

	                        vacumrounded:=vacumrounded
	                                      +round(vacumpercent - vacumrounded, 2);

	                        vpasexec:=64;

	                        BEGIN
	                            SELECT iuniact
	                              INTO viuniact
	                              FROM tabvalces
	                             WHERE ccesta=valor.ccesta AND
	                                   trunc(fvalor)=v_fvalmov;

	                            vpasexec:=65;

	                            BEGIN
			INSERT INTO ctaseguro
		           (sseguro,fcontab,nnumlin,ffecmov,fvalmov,cmovimi,
		           imovimi,imovim2,nrecibo,ccalint,cmovanu,
		           nsinies,smovrec,cesta,nunidad,cestado,
		           fasign,srecren)
		    VALUES
		           (reg.sseguro,v_fcontab,xnnumlin,v_fefecto,trunc(v_fvalmov),92,
		           xidistrib,NULL,NULL,v_seqgrupo,0,
		           NULL,NULL,valor.ccesta,xidistrib/viuniact,'2',
		           trunc(v_fvalmov),reg.nrentas);


	                                vpasexec:=66;

	                                /* BUG 18423 - 11/01/2012 - JMP - Multimoneda*/
	                                IF v_cmultimon=1 THEN
	                                  num_err:=pac_oper_monedas.f_update_ctaseguro_monpol (reg.sseguro, v_fcontab, xnnumlin, trunc(v_fvalmov));

	                                  IF num_err<>0 THEN
	                                    RETURN num_err;
	                                  END IF;
	                                END IF;
	                            /* FIN BUG 18423 - 11/01/2012 - JMP - Multimoneda*/
	                            EXCEPTION
	                                WHEN dup_val_on_index THEN
	                                  RETURN 104879;
	                                /* Registre duplicat a CTASEGURO*/
	                                WHEN OTHERS THEN
	                                  RETURN 102555;
	                            /* Error al insertar a la taula CTASEGURO*/
	                            END;

	                            vpasexec:=67;

	                            /* Para la impresión de libreta (para que los movimientos generales también tenga actualizada*/
	                            /* la fecha de asignación. Actualizamos el movimiento general anterior*/
	                            UPDATE ctaseguro
	                               SET cestado='2',fasign=trunc(f_sysdate),ffecmov=v_fefecto,fvalmov=v_fvalmov
	                             WHERE sseguro=reg.sseguro AND
	                                   cmovimi=53 AND
	                                   ccalint=v_seqgrupo AND
	                                   nnumlin<xnnumlin;

	                            vpasexec:=68;

	                            /* Incrementamos numero de linea (por movimiento 58)*/
	                            /* BUG 18423 - 11/01/2012 - JMP - Multimoneda*/
	                            IF v_cmultimon=1 THEN
	                              FOR reg1 IN (SELECT sseguro,fcontab,nnumlin,fvalmov
	                                             FROM ctaseguro
	                                            WHERE sseguro=reg.sseguro AND
	                                                  cmovimi=53 AND
	                                                  ccalint=v_seqgrupo AND
	                                                  nnumlin<xnnumlin) LOOP
	                                  num_err:=pac_oper_monedas.f_update_ctaseguro_monpol(reg1.sseguro, reg1.fcontab, reg1.nnumlin, reg1.fvalmov);

	                                  IF num_err<>0 THEN
	                                    RETURN num_err;
	                                  END IF;
	                              END LOOP;
	                            END IF;

	                            /* FIN BUG 18423 - 11/01/2012 - JMP - Multimoneda*/
	                            xnnumlin:=xnnumlin+1;

	                            vpasexec:=69;

	                            /* Aumentamos/Descontamos las participaciones asignadas al fondo en contratos*/
	                            UPDATE fondos
	                               SET fondos.nparasi=nvl(fondos.nparasi, 0)-(xidistrib/viuniact)
	                             WHERE fondos.ccodfon=valor.ccesta;
	                        EXCEPTION
	                            WHEN no_data_found THEN
	                              vpasexec:=70;

	                              /*Inserta registres a cuenta seguro.*/
	                              BEGIN
			INSERT INTO ctaseguro
		           (sseguro,fcontab,nnumlin,ffecmov,fvalmov,cmovimi,
		           imovimi,imovim2,nrecibo,ccalint,cmovanu,
		           nsinies,smovrec,cesta,cestado,srecren)

		    VALUES
		           (reg.sseguro,v_fcontab,xnnumlin,v_fefecto,trunc(v_fvalmov),92,
		           xidistrib,NULL,NULL,v_seqgrupo,0,
		           NULL,NULL,valor.ccesta,'1',reg.nrentas);


	                                  vpasexec:=71;

	                                  /* BUG 18423 - 11/01/2012 - JMP - Multimoneda*/
	                                  IF v_cmultimon=1 THEN
	                                    num_err:=pac_oper_monedas.f_update_ctaseguro_monpol (reg.sseguro, v_fcontab, xnnumlin, trunc(v_fvalmov));

	                                    IF num_err<>0 THEN
	                                      RETURN num_err;
	                                    END IF;
	                                  END IF;

	                                  /* FIN BUG 18423 - 11/01/2012 - JMP - Multimoneda*/
	                                  xnnumlin:=xnnumlin+1;
	                              EXCEPTION
	                                  WHEN dup_val_on_index THEN
	                                    RETURN 104879;
	                                  /* Registre duplicat a CTASEGURO*/
	                                  WHEN OTHERS THEN
	                                    RETURN 102555;
	                              /* Error al insertar a la taula CTASEGURO*/
	                              END;

	                              vpasexec:=72;

	                              /* Para la impresión de libreta (para que los movimientos generales también tenga actualizada*/
	                              /* la fecha de asignación. Actualizamos el movimiento general anterior*/
	                              UPDATE ctaseguro
	                                 SET ffecmov=v_fefecto,fvalmov=v_fvalmov
	                               WHERE sseguro=reg.sseguro AND
	                                     cmovimi=53 AND
	                                     ccalint=v_seqgrupo AND
	                                     nnumlin<xnnumlin;

	                              vpasexec:=73;

	                              /* BUG 18423 - 11/01/2012 - JMP - Multimoneda*/
	                              IF v_cmultimon=1 THEN
	                                FOR reg1 IN (SELECT sseguro,fcontab,nnumlin,fvalmov
	                                               FROM ctaseguro
	                                              WHERE sseguro=reg.sseguro AND
	                                                    cmovimi=53 AND
	                                                    ccalint=v_seqgrupo AND
	                                                    nnumlin<xnnumlin) LOOP
	                                    num_err:=pac_oper_monedas.f_update_ctaseguro_monpol (reg1.sseguro, reg1.fcontab, reg1.nnumlin, reg1.fvalmov);

	                                    IF num_err<>0 THEN
	                                      RETURN num_err;
	                                    END IF;
	                                END LOOP;
	                              END IF;
	                        /* FIN BUG 18423 - 11/01/2012 - JMP - Multimoneda*/
	                        END;

	                        vpasexec:=74;

	                        IF pac_ctaseguro.f_tiene_ctashadow(reg.sseguro, NULL)=1 THEN
	                          SELECT max(nnumlin)+1
	                            INTO xnnumlinshw
	                            FROM ctaseguro_shadow
	                           WHERE sseguro=reg.sseguro;

	                          vpasexec:=75;

	                          BEGIN
	                              SELECT iuniactvtashw
	                                INTO viuniact
	                                FROM tabvalces
	                               WHERE ccesta=valor.ccesta AND
	                                     trunc(fvalor)=v_fvalmov;

	                              vpasexec:=76;

	                              BEGIN
			INSERT INTO ctaseguro_shadow
		           (sseguro,fcontab,nnumlin,ffecmov,fvalmov,cmovimi,
		           imovimi,imovim2,nrecibo,ccalint,cmovanu,
		           nsinies,smovrec,cesta,nunidad,cestado,
		           fasign,srecren)
		    VALUES
		           (reg.sseguro,v_fcontab,xnnumlinshw,v_fefecto,trunc(v_fvalmov),92,
		           xidistrib,NULL,NULL,v_seqgrupo,0,
		           NULL,NULL,valor.ccesta,xidistrib/viuniact,'2',
		           trunc(v_fvalmov),reg.nrentas);


	                                  vpasexec:=77;

	                                  /* BUG 18423 - 11/01/2012 - JMP - Multimoneda*/
	                                  IF v_cmultimon=1 THEN
	                                    num_err:=pac_oper_monedas.f_update_ctaseguro_shw_monpol (reg.sseguro, v_fcontab, xnnumlinshw, trunc(v_fvalmov));

	                                    IF num_err<>0 THEN
	                                      RETURN num_err;
	                                    END IF;
	                                  END IF;
	                              /* FIN BUG 18423 - 11/01/2012 - JMP - Multimoneda*/
	                              EXCEPTION
	                                  WHEN dup_val_on_index THEN
	                                    RETURN 104879;
	                                  /* Registre duplicat a CTASEGURO*/
	                                  WHEN OTHERS THEN
	                                    RETURN 102555;
	                              /* Error al insertar a la taula CTASEGURO*/
	                              END;

	                              vpasexec:=78;

	                              /* Para la impresión de libreta (para que los movimientos generales también tenga actualizada*/
	                              /* la fecha de asignación. Actualizamos el movimiento general anterior*/
	                              UPDATE ctaseguro_shadow
	                                 SET cestado='2',fasign=trunc(f_sysdate),ffecmov=v_fefecto,fvalmov=v_fvalmov
	                               WHERE sseguro=reg.sseguro AND
	                                     cmovimi=53 AND
	                                     ccalint=v_seqgrupo AND
	                                     nnumlin<xnnumlinshw;

	                              vpasexec:=79;

	                              /* Incrementamos numero de linea (por movimiento 58)*/
	                              /* BUG 18423 - 11/01/2012 - JMP - Multimoneda*/
	                              IF v_cmultimon=1 THEN
	                                FOR reg1 IN (SELECT sseguro,fcontab,nnumlin,fvalmov
	                                               FROM ctaseguro_shadow
	                                              WHERE sseguro=reg.sseguro AND
	                                                    cmovimi=53 AND
	                                                    ccalint=v_seqgrupo AND
	                                                    nnumlin<xnnumlinshw) LOOP
	                                    num_err:=pac_oper_monedas.f_update_ctaseguro_shw_monpol (reg1.sseguro, reg1.fcontab, reg1.nnumlin, reg1.fvalmov);

	                                    IF num_err<>0 THEN
	                                      RETURN num_err;
	                                    END IF;
	                                END LOOP;
	                              END IF;

	                              /* FIN BUG 18423 - 11/01/2012 - JMP - Multimoneda*/
	                              xnnumlinshw:=xnnumlinshw+1;
	                          EXCEPTION
	                              WHEN no_data_found THEN
	                                vpasexec:=80;

	                                /*Inserta registres a cuenta seguro.*/
	                                BEGIN
			INSERT INTO ctaseguro_shadow
		           (sseguro,fcontab,nnumlin,ffecmov,fvalmov,cmovimi,
		           imovimi,imovim2,nrecibo,ccalint,cmovanu,
		           nsinies,smovrec,cesta,cestado,srecren)

		    VALUES
		           (reg.sseguro,v_fcontab,xnnumlinshw,v_fefecto,trunc(v_fvalmov),92,
		           xidistrib,NULL,NULL,v_seqgrupo,0,
		           NULL,NULL,valor.ccesta,'1',reg.nrentas);


	                                    vpasexec:=81;

	                                    /* BUG 18423 - 11/01/2012 - JMP - Multimoneda*/
	                                    IF v_cmultimon=1 THEN
	                                      num_err:=pac_oper_monedas.f_update_ctaseguro_shw_monpol (reg.sseguro, v_fcontab, xnnumlinshw, trunc(v_fvalmov));

	                                      IF num_err<>0 THEN
	                                        RETURN num_err;
	                                      END IF;
	                                    END IF;

	                                    /* FIN BUG 18423 - 11/01/2012 - JMP - Multimoneda*/
	                                    xnnumlinshw:=xnnumlinshw+1;
	                                EXCEPTION
	                                    WHEN dup_val_on_index THEN
	                                      RETURN 104879;
	                                    /* Registre duplicat a CTASEGURO*/
	                                    WHEN OTHERS THEN
	                                      RETURN 102555;
	                                /* Error al insertar a la taula CTASEGURO*/
	                                END;

	                                vpasexec:=82;

	                                /* Para la impresión de libreta (para que los movimientos generales también tenga actualizada*/
	                                /* la fecha de asignación. Actualizamos el movimiento general anterior*/
	                                UPDATE ctaseguro_shadow
	                                   SET ffecmov=v_fefecto,fvalmov=v_fvalmov
	                                 WHERE sseguro=reg.sseguro AND
	                                       cmovimi=53 AND
	                                       ccalint=v_seqgrupo AND
	                                       nnumlin<xnnumlinshw;

	                                vpasexec:=83;

	                                /* BUG 18423 - 11/01/2012 - JMP - Multimoneda*/
	                                IF v_cmultimon=1 THEN
	                                  FOR reg1 IN (SELECT sseguro,fcontab,nnumlin,fvalmov
	                                                 FROM ctaseguro_shadow
	                                                WHERE sseguro=reg.sseguro AND
	                                                      cmovimi=53 AND
	                                                      ccalint=v_seqgrupo AND
	                                                      nnumlin<xnnumlinshw) LOOP
	                                      num_err:=pac_oper_monedas.f_update_ctaseguro_shw_monpol (reg1.sseguro, reg1.fcontab, reg1.nnumlin, reg1.fvalmov);

	                                      IF num_err<>0 THEN
	                                        RETURN num_err;
	                                      END IF;
	                                  END LOOP;
	                                END IF;
	                          /* FIN BUG 18423 - 11/01/2012 - JMP - Multimoneda*/
	                          END;
	                        END IF;
	                    END LOOP;
	                  END IF;
	              /* Fin Bug 17247*/
	              EXCEPTION
	                  WHEN OTHERS THEN
	                    p_tab_error(f_sysdate, f_user, 'pac_tranferencias.f_transferir', 8, 'ERROR IMPOSIBLE DEFINIR ORIGEN', SQLERRM);

	                    RETURN 109997;
	              END;
	          END;
	        /* Bug 17247 - RSC - 11/03/2011 - ENSA103 - Instalar els web-services als entorns CSI*/
	        /*ELSE*/
	        /*   RETURN 180798;   -- Existen pagos de rentas ya transferidos en su selección. Refrescar busqueda de Transferencias.*/
	        /*END IF;*/
	        /* Fin Bug 17247*/
	        /*--------------------------------------------*/
	        /*--- REEMBOLSOS  ----------------------------*/
	        /*--------------------------------------------*/
	        ELSIF reg.catribu=11 THEN
	          vpasexec:=84;

	        /* BUG10604:DRA:02/07/2009:Inici*/
	        /* Si es un reembolso, el marcarem com transferit*/
	        /* Bug 10775 - APD - 29/07/2009 - Modificación fichero de transferencias para reembolsos*/
	          /* se añaden los campos nreemb, nfact, nlinea y ctipo a la llamada a la funcion f_act_reembacto*/
	          num_err:=pac_transferencias.f_act_reembacto(reg.nreemb, pnremesa, f_sysdate, reg.nfact, reg.nlinea, reg.ctipo);

	          vpasexec:=85;

	          UPDATE remesas_previo
	             SET ftransf=vftransf,nremesa=pnremesa,fabono=pfabono
	           WHERE nreemb=reg.nreemb AND
	                 nfact=reg.nfact AND
	                 nlinea=reg.nlinea AND
	                 ctipo=reg.ctipo AND
	                 nremesa IS NULL AND
	                 cmarcado=1 AND
	                 cusuario=f_user;

	          IF num_err<>0 THEN
	            RETURN 180831;
	          END IF;
	        /* BUG10604:DRA:02/07/2009:Fi*/
	        /*--------------------------------------------*/
	        /*--- PAGOSCOMISIONES ------------------------*/
	        /*--------------------------------------------*/
	        /*BUG14344:DRA:04/05/2010:Inici*/
	        ELSIF reg.catribu=12 THEN
	          vpasexec:=86;

	          UPDATE pagoscomisiones
	             SET cestado=1,nremesa=pnremesa,ftrans=vftransf
	           WHERE spago=reg.spago;

	          vpasexec:=87;

	          UPDATE remesas_previo
	             SET ftransf=vftransf,nremesa=pnremesa,fabono=pfabono
	           WHERE spago=reg.spago AND
	                 nremesa IS NULL AND
	                 cmarcado=1 AND
	                 cusuario=f_user;
	        /*BUG14344:DRA:04/05/2010:Fi*/
	        /* BUG 33427:NSS:12/11/2014:ini*/
	        /*--------------------------------------------*/
	        /*--- PAGOSCTATECREA------------------------*/
	        /*--------------------------------------------*/
	        ELSIF reg.catribu=14 THEN
	          vpasexec:=88;

	          UPDATE pagos_ctatec_rea
	             SET cestado=1,nremesa=pnremesa,ftrans=vftransf
	           WHERE spagrea=reg.spago;

	          vpasexec:=89;

	          UPDATE remesas_previo
	             SET ftransf=vftransf,nremesa=pnremesa,fabono=pfabono
	           WHERE spago=reg.spago AND
	                 nremesa IS NULL AND
	                 cmarcado=1 AND
	                 cusuario=f_user;
	        /*--------------------------------------------*/
	        /*--- PAGOSCTATECCOA------------------------*/
	        /*--------------------------------------------*/
	        ELSIF reg.catribu=15 THEN
	          vpasexec:=90;

	          UPDATE pagos_ctatec_coa
	             SET cestado=1,nremesa=pnremesa,ftrans=vftransf
	           WHERE spagcoa=reg.spago;

	          vpasexec:=91;

	          UPDATE remesas_previo
	             SET ftransf=vftransf,nremesa=pnremesa,fabono=pfabono
	           WHERE spago=reg.spago AND
	                 nremesa IS NULL AND
	                 cmarcado=1 AND
	                 cusuario=f_user;
	        /* BUG 33427:NSS:12/11/2014:Fi*/
	        /*--------------------------------------------*/
	        /*--- PRESTAMOPAGO ------------------------*/
	        /*--------------------------------------------*/
	        ELSIF reg.catribu=13 THEN
	          vpasexec:=92;

	          UPDATE prestamopago
	             SET nremesa=pnremesa,fremesa=vftransf
	           WHERE ctapres=reg.ctapres;

	          vpasexec:=93;

	          UPDATE prestamos
	             SET cestado=4
	           WHERE ctapres=reg.ctapres;

	          vpasexec:=94;

	          UPDATE remesas_previo
	             SET ftransf=vftransf,nremesa=pnremesa,fabono=pfabono
	           WHERE ctapres=reg.ctapres AND
	                 nremesa IS NULL AND
	                 cmarcado=1 AND
	                 cusuario=f_user;
	        /* BUG: 33886/202377*/
	        /*--------------------------------------------*/
	        /*--- PAGOSCTACLIENTE ------------------------*/
	        /*--------------------------------------------*/
	        ELSIF reg.catribu=16 THEN
	          vpasexec:=95;

	          UPDATE pagoctacliente
	             SET cestado=1,nremesa=pnremesa,ftrans=vftransf
	           WHERE spago=reg.spago;

	          vpasexec:=96;

	          UPDATE remesas_previo
	             SET ftransf=vftransf,nremesa=pnremesa,fabono=pfabono
	           WHERE spago=reg.spago AND
	                 nremesa IS NULL AND
	                 cmarcado=1 AND
	                 cusuario=f_user;
	        END IF;

	        SELECT sremesa.NEXTVAL
	          INTO v_sremesa
	          FROM dual;

	        vpasexec:=97;

	        /*Inserim un rebut*/
			INSERT INTO remesas
		           (sremesa,ccc,ctipban,nrecibo,nsinies,sidepag,
		           cabono,iimport,ctipban_abono,sseguro,catribu,
		           sproduc,fabono,nremesa,ftransf,ccausin,
		           cempres,sperson,sremsesion,ccobban,nreemb,
		           nfact,nlinea,ctipo,nrentas,cimpres,
		           spago,cestado,csubestado,descripcion,cmoneda,
		           fcambio)
		    VALUES
		           (v_sremesa,reg.ccc,reg.ctipban,reg.nrecibo,reg.nsinies,reg.sidepag,
		           reg.cabono,reg.iimport,reg.ctipban_abono,reg.sseguro,reg.catribu,
		           reg.sproduc,pfabono,/* BUG12913:DRA:04/02/2010*/pnremesa,vftransf,NULL,
		           reg.cempres,reg.sperson,NULL,reg.ccobban,reg.nreemb,
		           reg.nfact,reg.nlinea,reg.ctipo,reg.nrentas,1,
		           reg.spago,reg.cestado,reg.csubestado,reg.descripcion,reg.cmoneda,
		           reg.fcambio);


	        vpasexec:=98;

	        v_ccc:=reg.ccc;
	    END LOOP;

	    vpasexec:=99;

	    /*
	    -- Bug 0039238/0223588 - MDS - 14/01/2016
	    -- quitar esto de aqui, y ponerlo en una funcion a parte
	    -- en f_generacion_ficheros_sepa

	          --AGG MODIFICACIONES SEPA

	          IF NVL(pac_parametros.f_parempresa_n(pcempres, 'TRANSF_IBAN_XML'), 0) = 1 THEN
	             vpasexec := 100;
	             vidremesasepa := f_set_remesas_sepa(v_sremesa, pnremesa, pfabono);
	             vpasexec := 101;
	             error := pac_sepa.f_genera_xml_transferencias(vidremesasepa);
	             vpasexec := 102;
	             w_nomfichero := pac_nombres_ficheros.f_nom_transf(pnremesa, v_ccc);
	             vpasexec := 103;
	             p_insert_ficherosremesa(pnremesa, 1, REPLACE(w_nomfichero, 'TXT', 'XML'), v_ccc);
	             vpasexec := 104;
	             error := pac_sepa.f_genera_fichero_dom_trans('T', vidremesasepa,
	                                                          SUBSTR(w_nomfichero, 1,
	                                                                 INSTR(w_nomfichero, '.', -1) - 1));
	             vpasexec := 105;
	          END IF;
	    */
	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_tranferencias.f_transferir', 99, 'error no controlado', SQLERRM);

	             RETURN 109997;
	END f_transferir;

	/*JTS*/
	FUNCTION f_generacion_fichero(
			pnremesa	IN	NUMBER,
			pfabono	IN	DATE
	) /* BUG12913:DRA:04/02/2010*/
	RETURN NUMBER
	IS
	  w_fichero      utl_file.file_type;
	  w_rutaout      VARCHAR2(100);
	  w_nomfichero   VARCHAR2(100);
	  w_prelinea     VARCHAR2(80);
	  w_linea        VARCHAR2(1000);
	  w_benefici     VARCHAR2(12);
	  w_nombre       VARCHAR2(100);
	  w_tempres      VARCHAR2(200);
	  w_tdomici      VARCHAR2(40);
	  w_tipo         VARCHAR2(30);
	  w_mes          VARCHAR2(15);
	  w_grupo        seguros.cbancar%TYPE:=0;
	  /*  21-10-2011 JGR 0018944*/
	  w_tpoblac      VARCHAR2(40);
	  w_nnumnif      VARCHAR2(10);
	  w_nnumnif2     VARCHAR2(10);
	  w_total        NUMBER;
	  w_cuantos      NUMBER;
	  w_bruto        NUMBER;
	  w_empresa      NUMBER:=0;
	  w_cpostal      codpostal.cpostal%TYPE;
	  w_cpoblac      NUMBER;
	  w_cprovin      NUMBER;
	  w_ccobban      NUMBER;
	  w_sufijo       VARCHAR2(4);
	  num_err        NUMBER;
	  concep         VARCHAR2(1);
	  /*tipo           VARCHAR2(30);*/
	  /*linea          VARCHAR2(80);*/
	  vagente_poliza seguros.cagente%TYPE;
	  vcempres       seguros.cempres%TYPE;
	  /*d_avui         DATE;*/
	  vcontrem       NUMBER;
	  vcobjase       seguros.cobjase%TYPE; /* Bug 22439 - MDS - 18/06/2012*/
	  /* 35316.*/
	  wcabono_aux    remesas_previo.cabono%TYPE;

	  /**/
	  CURSOR remesa IS
	    SELECT r.*
	      FROM remesas_previo r
	     WHERE nremesa=pnremesa AND
	           cmarcado=1 AND
	           cusuario=f_user AND
	           ctipban=1 /* Cuenta española*/
	     ORDER BY cempres,ccc,sproduc,sseguro;
	BEGIN
	    /*d_avui := f_sysdate;*/
	    w_rutaout:=f_parinstalacion_t('TRANSFERENCIAS');

	    /* Bucle para cada pago.*/
	    w_total:=0;

	    w_cuantos:=0;

	    BEGIN
	        SELECT nvl(max(nmovimi), 0)
	          INTO vcontrem
	          FROM ficherosremesa
	         WHERE nremesa=pnremesa;

	        vcontrem:=vcontrem+1;
	    EXCEPTION
	        WHEN no_data_found THEN
	          vcontrem:=1;
	        WHEN OTHERS THEN
	          vcontrem:=1;
	    END;

	    FOR r IN remesa LOOP
	        /*message ( 'ini loop ' || :c_trans );pause;*/
	        IF r.cobliga=1 THEN
	          IF w_grupo<>r.ccc AND
	             w_cuantos>0 AND
	             w_grupo<>0 THEN
	          /* TOTALES*/
	            /* w_linea := '0856' || RPAD(w_nnumnif, 10, ' ') || '            ' || '   '*/
	            w_linea:='0856'
	                     || w_sufijo
	                     || w_nnumnif
	                     || '            '
	                     || '   '
	                     || to_char(w_total*100, 'FM000000000000')
	                     || to_char(w_cuantos, 'FM00000000')
	                     || to_char(w_cuantos*4+5, 'FM0000000000');

	            utl_file.put_line(w_fichero, substr(w_linea, 1, 72));

	            /* Cerramos el fichero*/
	            utl_file.fclose(w_fichero);

	            utl_file.frename(w_rutaout, w_nomfichero, w_rutaout, ltrim(w_nomfichero, '_'));

	            w_total:=0;

	            w_cuantos:=0;
	          END IF;

	          IF w_empresa<>r.cempres THEN
	          /* datos de la empresa*/
	          BEGIN
	                w_empresa:=r.cempres;

	                SELECT e.tempres,d.tdomici,cpostal,cpoblac,cprovin
	                  INTO w_tempres, w_tdomici, w_cpostal, w_cpoblac, w_cprovin
	                  FROM empresas e,per_direcciones d
	                 WHERE e.cempres=r.cempres AND
	                       d.sperson=e.sperson AND
	                       d.cdomici=(SELECT min(cdomici)
	                                    FROM per_direcciones dd
	                                   WHERE dd.sperson=d.sperson);
	            EXCEPTION
	                WHEN OTHERS THEN
	                  p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_generacion_fichero', 1, 'error al leer empresas o direcciones para empresa = '
	                                                                                               || r.cempres, SQLERRM);

	                  RETURN 120135;
	            END; BEGIN SELECT tpoblac INTO w_tpoblac FROM poblaciones WHERE cpoblac = w_cpoblac AND cprovin = w_cprovin; EXCEPTION WHEN OTHERS THEN p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_generacion_fichero', 1, 'error al leer tabla poblaciones para provincia = '|| w_cprovin|| ' poblacion = '|| w_cpoblac, SQLERRM); RETURN 120135; END;
	          END IF;

	          IF pac_parametros.f_parempresa_n(w_empresa, 'TRANS_SUFIJO')=1 THEN
	            IF w_ccobban<>r.ccobban  OR
	               w_ccobban IS NULL THEN
	              w_ccobban:=r.ccobban;

	              BEGIN
	                  SELECT substr(tsufijo, length(tsufijo), 1)
	                    INTO w_sufijo
	                    FROM cobbancario
	                   WHERE ccobban=r.ccobban;
	              EXCEPTION
	                  WHEN OTHERS THEN
	                    p_tab_error (f_sysdate, f_user, 'pac_transferencias.f_generacion_fichero', 1, 'error al leer tabla cobradores para código cobrador = '
	                                                                                                  || w_ccobban, SQLERRM);

	                    RETURN 120135;
	              END;
	            END IF;
	          ELSE
	            w_sufijo:='';
	          END IF;

	          IF w_grupo<>r.ccc THEN
	            w_grupo:=r.ccc;

	            w_nomfichero:=f_parinstalacion_t('FILE_TRANS');

	            /* Bug 0013153 - FAL - 18/03/2010 - Recuperar nombre fichero especifico si existe. Ó el standard de iAXIS si no definido.*/
	            w_nomfichero:=pac_nombres_ficheros.f_nom_transf(pnremesa, r.ccc);

	            IF w_nomfichero='-1' THEN
	              RETURN 9901092;
	            END IF;

	            /* AGG MODIFICACIONES SEPA*/
	            IF nvl(pac_parametros.f_parempresa_n(w_empresa, 'TRANSF_IBAN_XML'), 0)=0 THEN
	              p_insert_ficherosremesa(pnremesa, vcontrem, w_nomfichero, r.ccc);
	            END IF;

	            w_nomfichero:='_'
	                          || w_nomfichero;

	            /* Fi Bug 0013153*/
	            BEGIN
	                SELECT b.nnumnif
	                  INTO w_nnumnif
	                  FROM cobbancariosel a,cobbancario b,seguros s,productos p
	                 WHERE b.cbaja=0 AND
	                       a.ccobban=b.ccobban AND
	                       s.sseguro=r.sseguro AND
	                       p.sproduc=s.sproduc AND
	                       nvl(a.cramo, p.cramo)=p.cramo AND
	                       nvl(a.ctipseg, p.ctipseg)=p.ctipseg AND
	                       nvl(a.cmodali, p.cmodali)=p.cmodali AND
	                       nvl(a.ccolect, p.ccolect)=p.ccolect AND
	                       b.ncuenta=r.ccc AND
	                       (b.ccobban=r.ccobban  OR
	                        r.ccobban IS NULL);
	            /* BUG9693:DRA:19/05/2009*/
	            EXCEPTION
	                WHEN OTHERS THEN
	                  SELECT DISTINCT nnumnif
	                    INTO w_nnumnif
	                    FROM cobbancario
	                   WHERE ncuenta=r.ccc;
	            END;

	            /*Ini Bug.: 0013781 - ICV - 23/03/2010*/
	            w_nnumnif2:=pac_propio.f_nif_transf(r.sseguro, w_nnumnif, r.ccobban, r.catribu);

	            /*INI BUG: 0020136 - JMC - 11/11/2011 - Si retorno 0, que es error se mantiene en w_nnumnif*/
	            IF w_nnumnif2<>'0' THEN
	              /*Bug 26792-XVM-26/04/2013*/
	              w_nnumnif:=rpad(w_nnumnif, 10, ' ');
	            END IF;

	          /*Fin Bug.: 0013781*/
	            /* Bug 0013153 - FAL - 18/03/2010 - Renombrar nombre fichero para quitarle '_' cuando ya generado.*/
	            IF utl_file.is_open(w_fichero) THEN
	              utl_file.fclose(w_fichero);

	              utl_file.frename(w_rutaout, w_nomfichero, w_rutaout, ltrim(w_nomfichero, '_'));
	            END IF;

	            /* Fi Bug 0013153*/
	            w_fichero:=utl_file.fopen(w_rutaout, w_nomfichero, 'W');

	          /*
	           {calculo de los registros de  cabecera 4 lineas de cabcera obligatorias
	            1.- Fechas y cuentas de cargo
	            2.- nombre del ordenante
	            3.- direccion del ordenante
	            4.- plaza del ordenante
	            }
	          */
	            /* {prefijo de la cabecera : 03(obligatorio) + 56(indica euros ) + nif cobrador + 6_ }*/
	            IF pac_parametros.f_parempresa_n(w_empresa, 'TRANS_SUFIJO')=1 THEN
	              w_prelinea:='0356'
	                          || w_sufijo
	                          || w_nnumnif;
	            ELSE
	              w_prelinea:='0356'
	                          || w_nnumnif;
	            END IF;

	            w_prelinea:=rpad(w_prelinea, 26, ' ');

	            /*
	            {linea 1= prefijo cab + 001+fecha envio + fecha orden + entidad destino + oficina destino +
	            ccuenta cargo+detalle de cargo+3_+dc cuenta cargo
	            */
	            w_linea:=w_prelinea
	                     || '001'
	                     || to_char(f_sysdate, 'DDMMYY')
	                     /* Fecha de Envio del Fichero*/
	                     || to_char(nvl(pfabono, r.fabono), 'DDMMYY')
	                     /* BUG13931:ICV:29/03/2010 -- BUG12913:DRA:04/02/2010*/
	                     /* Fecha de EMisión de las ordenes*/
	                     || substr(lpad(r.ccc, 20, '0'), 1, 4) -- Banco
	                     || substr(lpad(r.ccc, 20, '0'), 5, 4) -- Oficina
	                     || substr(lpad(r.ccc, 20, '0'), 11, 10) -- Cuenta
	                     || '1' -- Detalle del cargo.
	                     || '   ' -- libre
	                     || substr(lpad(r.ccc, 20, '0'), 9, 2);

	            /* Dígito Control*/
	            utl_file.put_line(w_fichero, rpad(w_linea, 72, ' '));

	          /*> Primera linea cabecera*/
	            /*
	            linea 2 = prefijo cab + 002 + nombre ordenante(36)+7_
	            */
	            w_linea:=w_prelinea
	                     || '002'
	                     || w_tempres;

	            utl_file.put_line(w_fichero, rpad(w_linea, 72, ' '));

	          /*> Segunda linea cabecera*/
	            /*
	            linea 3 = prefijo cab + 003 + domicilio ordenante(36)+7_
	            */
	            w_linea:=w_prelinea
	                     || '003'
	                     || w_tdomici;

	            utl_file.put_line(w_fichero, rpad(w_linea, 72, ' '));

	          /*> Tercera linea cabecera*/
	            /*
	            linea 4 = prefijo cab + 004 + plaza ordenante (36)+7_
	            */
	            w_linea:=w_prelinea
	                     || '004'
	                     || lpad(w_cpostal, 4, '0')
	                     || '-'
	                     || w_tpoblac;

	            utl_file.put_line(w_fichero, rpad(w_linea, 72, ' '));
	          /*> Tercera linea cabecera*/
	          END IF;

	          w_cuantos:=w_cuantos+1;

	          w_total:=w_total+r.iimport;

	          w_nombre:=NULL;

	          w_benefici:=NULL;

	          w_bruto:=NULL;

	          w_mes:=NULL;

	          IF r.catribu IN(5, 6) THEN
	          /* extornos y anulaciones de aprotación*/
	          BEGIN
	            /*Bug10612 - 14/07/2009 - DCT (canviar vista personas)*/
	            /*Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro*/
	                /* Bug 22439 - MDS - 18/06/2012: añadir cobjase*/
	                SELECT cagente,cempres,nvl(cobjase, 0)
	                  INTO vagente_poliza, vcempres, vcobjase
	                  FROM seguros
	                 WHERE sseguro=r.sseguro;

	                /* Ini Bug 22439 - MDS - 18/06/2012*/
	                /* si el objeto asegurado SI es persona, la tabla de riesgos es RIESGOS*/
	                /* la SELECT es la que ya había*/
	                IF vcobjase=1 THEN
	                  SELECT DISTINCT substr(d.tapelli1, 0, 40) -- 06/06/2016 EDA JIRA-9  El agente no es restrictivo en generación de las transferencias
	                         || ' '
	                         || substr(d.tapelli2, 0, 20)
	                         || ','
	                         || substr(d.tnombre, 0, 20),rpad(p.nnumide, 12, ' '),r.iimport,to_char(re.femisio, 'FMMONTH')
	                    INTO w_nombre, w_benefici, w_bruto, w_mes
	                    FROM per_personas p,per_detper d,recibos re,riesgos ri
	                   WHERE re.nrecibo=r.nrecibo AND
	                         re.sseguro=ri.sseguro AND
	                         nvl(re.nriesgo, 1)=ri.nriesgo AND
	                         ri.sperson=p.sperson AND
	                         d.sperson=p.sperson  AND
	                         -- d.cagente=ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres);  -- 06/06/2016 EDA JIRA-9 El agente no es restrictivo en generación de las transferencias
                             rownum =1 ;
	                /* si el objeto asegurado NO es persona, la tabla de riesgos es ASEGURADOS*/
	                /* la SELECT es la nueva versión*/
	                ELSE
	                  SELECT DISTINCT substr(d.tapelli1, 0, 40) -- 06/06/2016 EDA JIRA-9 El agente no es restrictivo en las consultas de personas
	                         || ' '
	                         || substr(d.tapelli2, 0, 20)
	                         || ','
	                         || substr(d.tnombre, 0, 20),rpad(p.nnumide, 12, ' '),r.iimport,to_char(re.femisio, 'FMMONTH')
	                    INTO w_nombre, w_benefici, w_bruto, w_mes
	                    FROM per_personas p,per_detper d,recibos re,asegurados ri
	                   WHERE re.nrecibo=r.nrecibo AND
	                         re.sseguro=ri.sseguro AND
	                         nvl(re.nriesgo, 1)=nvl(ri.nriesgo, 1) AND
	                         ri.sperson=p.sperson AND
	                         d.sperson=p.sperson AND
	                         --d.cagente=ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres);  -- 06/06/2016 EDA JIRA-9  El agente no es restrictivo en generación de las transferencias
                           rownum =1 ; -- 06/06/2016 EDA JIRA-9 El agente no es restrictivo en las consultas de personas
	                END IF;
	            /* Fin Bug 22439 - MDS - 18/06/2012*/
	            /*FI Bug10612 - 14/07/2009 - DCT (canviar vista personas)*/
	            EXCEPTION
	                WHEN no_data_found THEN
	                  p_tab_error (f_sysdate, f_user, 'pac_transferencias.f_generacion_fichero', 1, 'error al leer tablas personas, recibos, riesgos para recibo = '
	                                                                                                || r.nrecibo, SQLERRM);

	                  RETURN 120135;
	            END;
	          ELSIF r.catribu=12 THEN
	            SELECT f_nombre(p.sperson, 1),rpad(p.nnumide, 12, ' '),pc.iimporte,to_char(pc.fliquida, 'FMMONTH')
	              INTO w_nombre, w_benefici, w_bruto, w_mes
	              FROM pagoscomisiones pc,agentes a,per_personas p
	             WHERE a.cagente=pc.cagente AND
	                   p.sperson=a.sperson AND
	                   pc.spago=r.spago;
	          ELSE BEGIN
	            /*Bug10612 - 14/07/2009 - DCT (canviar vista personas)*/
	                /*Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro*/
	                SELECT cagente,cempres
	                  INTO vagente_poliza, vcempres
	                  FROM seguros
	                 WHERE sseguro=r.sseguro;

	                /* BUG12913:DRA:23/02/2010:Inici: Nou modul de sinistres*/
	                IF pac_parametros.f_parempresa_n(vcempres, 'MODULO_SINI')=1 THEN
	                /* BUG22787:NSS:214/12/2012*/
	                /*SELECT SUBSTR(d.tapelli1, 0, 40) || ' ' || SUBSTR(d.tapelli2, 0, 20)
	                       || ',' || SUBSTR(d.tnombre, 0, 20),
	                       RPAD(p.nnumide, 12, ' '), NVL(pa.isinret, 0) - NVL(pa.iretenc, 0),
	                       TO_CHAR(pa.fordpag, 'FMMONTH')
	                  INTO w_nombre,
	                       w_benefici, w_bruto,
	                       w_mes
	                  FROM per_personas p, per_detper d, sin_tramita_pago pa
	                 WHERE pa.sidepag = r.sidepag
	                   AND pa.sperson = p.sperson
	                   AND d.sperson = p.sperson
	                   AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate,
	                                                       vcempres);*/
	                BEGIN
	                      SELECT DISTINCT substr(d.tapelli1, 0, 40) -- 06/06/2016 EDA JIRA-9 -- 06/06/2016 EDA JIRA-9 El agente no es restrictivo en generación de las transferencias
	                             || ' '
	                             || substr(d.tapelli2, 0, 20)
	                             || ','
	                             || substr(d.tnombre, 0, 20),rpad(p.nnumide, 12, ' '),
	                             /* Bug 28328 - 04-X-2013 - dlF - Error al crear una tansferencia en PROD*/
	                             /* hay que sumar el importe del IVA.*/
	                             /*NVL(pa.isinret, 0) - NVL(pa.iretenc, 0),*/
	                             nvl(pa.isinret, 0)-nvl(pa.iretenc, 0)+nvl(pa.iiva, 0),
	                             /* fin Bug 28328 - 04-X-2013 - dlF*/
	                             to_char(pa.fordpag, 'FMMONTH')
	                        INTO w_nombre, w_benefici, w_bruto, w_mes
	                        FROM per_personas p,per_detper d,sin_tramita_pago pa
	                       WHERE pa.sidepag=r.sidepag AND
	                             pa.sperson=p.sperson AND
	                             d.sperson=p.sperson AND
   	                             -- d.cagente=ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres);  -- 06/06/2016 EDA JIRA-9 El agente no es restrictivo en generación de las transferencias
                                 rownum =1 ; -- 06/06/2016 EDA JIRA-9 El agente no es restrictivo en las consultas de personas
	                  EXCEPTION
	                      WHEN no_data_found THEN
	                        SELECT substr(d.tapelli1, 0, 40)
	                               || ' '
	                               || substr(d.tapelli2, 0, 20)
	                               || ','
	                               || substr(d.tnombre, 0, 20),rpad(d.nnumide, 12, ' '),
	                               /* Bug 28328 - 04-X-2013 - dlF - Error al crear una tansferencia en PROD*/
	                               /* hay que sumar el importe del IVA.*/
	                               /*NVL(pa.isinret, 0) - NVL(pa.iretenc, 0),*/
	                               nvl(pa.isinret, 0)-nvl(pa.iretenc, 0)+nvl(pa.iiva, 0),
	                               /* fin Bug 28328 - 04-X-2013 - dlF*/
	                               to_char(pa.fordpag, 'FMMONTH')
	                          INTO w_nombre, w_benefici, w_bruto, w_mes
	                          FROM personas d,sin_tramita_pago pa
	                         WHERE pa.sidepag=r.sidepag AND
	                               pa.sperson=d.sperson;
	                  END;
	                /* FI BUG 22787:NSS:214/12/2012*/
	                ELSE
	                  SELECT DISTINCT substr(d.tapelli1, 0, 40) -- 06/06/2016 EDA JIRA-9 El agente no es restrictivo en las consultas de personas
	                         || ' '
	                         || substr(d.tapelli2, 0, 20)
	                         || ','
	                         || substr(d.tnombre, 0, 20),rpad(p.nnumide, 12, ' '),pa.iimpsin,to_char(pa.fordpag, 'FMMONTH')
	                    INTO w_nombre, w_benefici, w_bruto, w_mes
	                    FROM per_personas p,per_detper d,pagosini pa
	                   WHERE pa.sidepag=r.sidepag AND
	                         pa.sperson=p.sperson AND
	                         d.sperson=p.sperson AND
	                         -- d.cagente=ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres);  -- 06/06/2016 EDA JIRA-9 El agente no es restrictivo en generación de las transferencias
                             rownum =1 ; -- 06/06/2016 EDA JIRA-9 El agente no es restrictivo en generación de las transferencias
	                END IF;
	            /* BUG12913:DRA:23/02/2010:Fi*/
	            /*FI Bug10612 - 14/07/2009 - DCT (canviar vista personas)*/
	            EXCEPTION
	                WHEN no_data_found THEN BEGIN
	                      /*Bug10612 - 14/07/2009 - DCT (canviar vista personas)*/
	                      SELECT DISTINCT substr(d.tapelli1, 0, 40)
	                             || ' '
	                             || substr(d.tapelli2, 0, 20)
	                             || ','
	                             || substr(d.tnombre, 0, 20),rpad(p.nnumide, 12, ' '),pa.iconret,to_char(pa.ffecpag, 'FMMONTH')
	                        INTO w_nombre, w_benefici, w_bruto, w_mes
	                        FROM per_personas p,per_detper d,pagosrenta pa
	                       WHERE pa.srecren=r.nrentas AND
	                             pa.sperson=p.sperson AND
	                             d.sperson=p.sperson AND
	                            -- d.cagente=ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres); -- 06/06/2016 EDA JIRA-9 El agente no es restrictivo en generación de las transferencias
								 rownum =1 ; -- 06/06/2016 EDA JIRA-9 El agente no es restrictivo en generación de las transferencias
	                  /*FI Bug10612 - 14/07/2009 - DCT (canviar vista personas)*/
	                  EXCEPTION
	                      WHEN no_data_found THEN
	                        p_tab_error (f_sysdate, f_user, 'pac_transferencias.f_generacion_fichero', 2, 'error al leer tablas personas, detalle, pagosrenta para renta = '
	                                                                                                      || r.nrentas, SQLERRM);

	                        RETURN 120135;
	                  END;
	            END;
	          END IF;

	        /*
	        {calculo de los registros de  beneficiario,2 registros obligatorios
	          1.- Datos del abono : cuenta, importe (Obli.)
	          2.- Datos del beneficiario(Obli.)
	          3.- Concepto de la transferencia(Opc.)
	        }
	        */
	        /* {prefijo de la beneficiario : 06(obligatorio) + 56(indica euros ) + nif cobrador + nif beneficiario }*/
	          /*Bug 26792-XVM-26/04/2013*/
	          IF pac_parametros.f_parempresa_n(w_empresa, 'TRANS_SUFIJO')=1 THEN
	            w_prelinea:='0656'
	                        || w_sufijo
	                        || rpad(w_nnumnif, 9, ' ')
	                        || w_benefici;
	          ELSE
	            w_prelinea:='0656'
	                        || rpad(w_nnumnif, 10, ' ')
	                        || w_benefici;
	          END IF;

	        /*w_prelinea := '0656' || w_nnumnif || w_benefici;*/
	          /*
	            linea 1 = prefijo bene + 010 + importe + cod. banco + ofic. bancaria + cuenta corriente +
	                      1 (gastos a cuenta del ordenante) + 8 (concepto pension)+2_+dc cuenta
	          */
	          IF r.catribu IN(6, 8, 9, 10) THEN
	            concep:=8; /* pensión*/
	          ELSE
	            concep:=9; /*otros conceptos;*/
	          END IF;

	          /* #.35316.#*/
	          IF r.ctipban_abono=2 THEN
	            wcabono_aux:=substr(r.cabono, 5);
	          ELSE
	            wcabono_aux:=r.cabono;
	          END IF;

	          w_linea:=w_prelinea
	                   || '010'
	                   || to_char(r.iimport*100, 'FM000000000000')
	                   || substr(lpad(wcabono_aux, 20, '0'), 1, 4)
	                   || substr(lpad(wcabono_aux, 20, '0'), 5, 4)
	                   || substr(lpad(wcabono_aux, 20, '0'), 11, 10)
	                   || '1'
	                   || concep
	                   || '  '
	                   || substr(lpad(wcabono_aux, 20, '0'), 9, 2);

	          utl_file.put_line(w_fichero, w_linea);

	        /*
	          linea 2 = prefijo bene + 011 + Nombre del beneficiario
	        */-- Segunda linea del pago 2/4
	          w_linea:=w_prelinea
	                   || '011'
	                   || w_nombre;

	          utl_file.put_line(w_fichero, substr(w_linea, 1, 72));

	        /* Segunda linea del pago 3/4*/
	          /*
	            linea 2 = prefijo bene + 016 + concepto (texto libre)
	          */
	          IF r.catribu=8 THEN
	            w_tipo:='TRASPASO DE SALIDA';
	          ELSIF r.catribu=10 THEN
	            w_tipo:='PREST. '
	                    || w_mes;
	          ELSE
	            w_tipo:='DEVOLUCIÓN';

	            num_err:=f_desvalorfijo(701, 1, r.catribu, w_tipo);
	          END IF;

	          w_linea:=w_prelinea
	                   || '016'
	                   || w_tipo
	                   || ' '
	                   || to_char(w_bruto, 'FM999G999G990D00')
	                   || ' Euros';

	          utl_file.put_line(w_fichero, substr(w_linea, 1, 72));

	        /*
	          linea 4 = prefijo bene + 017 + concepto de la trasnferencia(ttexto libre)
	        */
	          /*BUG 26792-XVM-26/04/2013*/
	          IF nvl(pac_parametros.f_parempresa_n(w_empresa, 'AJUST_DOMTRANS'), 0)=0 THEN
	            w_linea:=rpad(w_prelinea
	                          || '017', 72, '=');
	          ELSE
	            w_linea:=rpad(w_prelinea
	                          || '017', 65, '=');
	          END IF;

	          utl_file.put_line(w_fichero, substr(w_linea, 1, 72));
	        END IF;
	    /* va arriba
	    IF     w_grupo <> r.ccc
	       AND w_cuantos > 0 THEN
	       -- TOTALES
	       w_linea :=
	          '0856' || RPAD (w_nnumnif, 10, ' ') || '            ' || '   '
	          || TO_CHAR (w_total * 100, 'FM000000000000')
	          || TO_CHAR (w_cuantos, 'FM00000000')
	          || TO_CHAR (w_cuantos * 3 + 5, 'FM0000000000');
	       UTL_FILE.PUT_LINE (w_fichero, SUBSTR (w_linea, 1, 72));
	       -- Cerramos el fichero
	       UTL_FILE.FCLOSE (w_fichero);
	       w_total := 0;
	       w_cuantos := 0;
	    END IF;*/
	    END LOOP;

	    IF w_cuantos>0 THEN
	    /* TOTALES*/
	      /*w_linea := '0856' || RPAD(w_nnumnif, 10, ' ') || '            ' || '   '*/
	      IF pac_parametros.f_parempresa_n(w_empresa, 'TRANS_SUFIJO')=1 THEN
	        w_linea:='0856'
	                 || w_sufijo
	                 || rpad(w_nnumnif, 24, ' ');
	      ELSE
	        w_linea:='0856'
	                 || rpad(w_nnumnif, 25, ' ');
	      END IF;

	      /*w_linea := RPAD(w_linea, 29, '');*/
	      w_linea:=w_linea
	               || to_char(w_total*100, 'FM000000000000')
	               || to_char(w_cuantos, 'FM00000000')
	               || to_char(w_cuantos*4+5, 'FM0000000000');

	      utl_file.put_line(w_fichero, substr(w_linea, 1, 72));

	      utl_file.fclose(w_fichero);
	    END IF;

	    IF utl_file.is_open(w_fichero) THEN
	      utl_file.fclose(w_fichero);
	    END IF;

	    /* Bug 0013153 - FAL - 18/03/2010 - Renombrar nombre fichero para quitarle '_' cuando ya generado.*/
	    IF NOT utl_file.is_open(w_fichero) THEN
	      utl_file.frename(w_rutaout, w_nomfichero, w_rutaout, ltrim(w_nomfichero, '_'));
	    END IF;

	    /* FI bug 0013153*/
	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             IF utl_file.is_open(w_fichero) THEN
	               utl_file.fclose(w_fichero);
	             END IF;

	             p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_genera_fichero', 2, 'error no controlado', SQLERRM);

	             RETURN 140999; /*error no controlado*/
	END f_generacion_fichero;

	/*JTS*/
	FUNCTION f_generacion_fichero_iban(
			pnremesa	IN	NUMBER,
			pfabono	IN	DATE
	) /* BUG12913:DRA:04/02/2010*/
	RETURN NUMBER
	IS
	  w_fichero      utl_file.file_type;
	  w_rutaout      VARCHAR2(100);
	  w_nomfichero   VARCHAR2(100);
	  w_cuantos      NUMBER;
	  w_linia        VARCHAR2(250);
	  n_lina         VARCHAR2(2);
	  /**/
	  /*xmonedainst    eco_codmonedas.cmoneda%TYPE := pac_monedas.obtener_moneda_defecto;*/
	  isomonedainst  VARCHAR2(3);
	  w_ident_emi    VARCHAR2(4);
	  w_cdoment      VARCHAR2(4);
	  w_cempres      NUMBER(2);
	  w_tempres      VARCHAR2(40);
	  w_cereceptora  VARCHAR2(2);
	  /*w_decima       NUMBER(2);*/
	  /*w_npoliza      NUMBER(10);*/
	  /*w_ncertif      NUMBER(4);*/
	  w_codisnip     VARCHAR2(50);
	  w_tnombre      VARCHAR2(50);
	  w_toficina     VARCHAR2(50);
	  w_diroficina   VARCHAR2(50);
	  w_poblac       VARCHAR2(50);
	  w_numcuenta    VARCHAR2(50);
	  w_codipaisiso  VARCHAR2(2);
	  w_cidioma      NUMBER;
	  w_sperson      NUMBER;
	  w_cdomici      NUMBER;
	  w_tiplin1      VARCHAR2(100);
	  w_tiplin2      VARCHAR2(100);
	  w_tiplin3      VARCHAR2(100);
	  w_total        NUMBER; /*NUMBER(12, 2) := 0;*/
	  /**/
	  d_avui         DATE;
	  num_err        NUMBER;
	  /*concep         VARCHAR2(1);*/
	  /*tipo           VARCHAR2(30);*/
	  /*linea          VARCHAR2(80);*/
	  v_grupoccc     remesas.ccc%TYPE:='0';
	  /* BUG9693:DRA:20/04/2009*/
	  vagente_poliza agentes.cagente%TYPE;
	  vcempres       empresas.cempres%TYPE;
	  w_ncass        reembfact.ncass%TYPE;
	  w_nfact_cli    reembfact.nfact_cli%TYPE;
	  w_nfactext     reembfact.nfactext%TYPE;
	  w_facto        reembactosfac.facto%TYPE;
	  vcontrem       NUMBER;
	  vcpolcia       VARCHAR2(40);
	  vnsincia       VARCHAR2(40);
	  vccompani      NUMBER;
	  vtcompani      VARCHAR2(300);
	  v_text         VARCHAR2(400);

	  CURSOR remesa IS
	    SELECT *
	      FROM remesas_previo
	     WHERE nremesa=pnremesa AND
	           cmarcado=1 AND
	           cusuario=f_user AND
	           ctipban=2 /* Cuenta Andorrana*/
	     ORDER BY cempres,ccc,sproduc,sseguro;
	BEGIN
	    d_avui:=f_sysdate;

	    w_rutaout:=f_parinstalacion_t('TRANSFERENCIAS');

	    w_cuantos:=0;

	    BEGIN
	        SELECT nvl(max(nmovimi), 0)
	          INTO vcontrem
	          FROM ficherosremesa
	         WHERE nremesa=pnremesa;

	        vcontrem:=vcontrem+1;
	    EXCEPTION
	        WHEN no_data_found THEN
	          vcontrem:=1;
	        WHEN OTHERS THEN
	          vcontrem:=1;
	    END;

	    BEGIN
	        SELECT ciso4217n
	          INTO isomonedainst
	          FROM monedas
	         WHERE cmoneda=f_parinstalacion_n('MONEDAINST') AND
	               ROWNUM=1;
	    EXCEPTION
	        WHEN OTHERS THEN
	          num_err:=101916; /* Error en la BD (MONEDA NO PERMITIDA)*/
	    /*raise others;*/
	    END;

	    FOR r IN remesa LOOP
	        IF r.cobliga=1 THEN
	          /* BUG9693:DRA:20/04/2009:Inici*/
	          IF v_grupoccc<>r.ccc THEN
	            IF w_cuantos>0 THEN
	              w_linia:='4'
	                       || w_ident_emi
	                       || lpad(substr(w_cdoment, 1, 2), 2, '0')
	                       /* Bug 0019583 - JMF - 26/09/2011 ||w_cereceptora*/
	                       || to_char(d_avui, 'ddmmrr')
	                       || 'A'
	                       || isomonedainst /*iso de moneda*/
	                       || lpad(to_char(w_total*100), 14, '0') --import total
	                       || lpad(w_cuantos, 5, '0') --Nro documents
	                       || lpad(' ', 92, ' '); --Espais

	              utl_file.put_line(w_fichero, w_linia);

	              utl_file.fclose(w_fichero);

	              utl_file.frename(w_rutaout, w_nomfichero, w_rutaout, ltrim(w_nomfichero, '_'));
	            END IF;

	            w_cuantos:=0;

	            w_total:=0;

	            v_grupoccc:=r.ccc;
	          END IF;

	        /* BUG9693:DRA:20/04/2009:Fi*/
	          /*Registre 1*/
	          IF w_cuantos=0 THEN
	          /* Bug 0013153 - FAL - 18/03/2010 - Recuperar nombre fichero especifico si existe. Ó el standard de iAXIS si no definido.*/
	            /*
	            -- BUG9693:DRA:20/04/2009:Inici
	            w_nomfichero := 'CSB34_' || r.ccc || '_' || TO_CHAR(f_sysdate, 'DDMMYYYY')
	                            || '_' || TO_CHAR(f_sysdate, 'hh24') || '_'
	                            || TO_CHAR(f_sysdate, 'mi') || '_' || TO_CHAR(f_sysdate, 'ss')
	                            || '.TXT';
	            -- BUG9693:DRA:20/04/2009:Fi
	            */
	            w_nomfichero:=pac_nombres_ficheros.f_nom_transf(pnremesa, r.ccc);

	            IF w_nomfichero='-1' THEN
	              RETURN 9901092;
	            END IF;

	            /* Fi Bug 0013153*/
	            p_insert_ficherosremesa(pnremesa, vcontrem, w_nomfichero, r.ccc);

	            w_nomfichero:='_'
	                          || w_nomfichero;

	            /* Bug 0013153 - FAL - 18/03/2010 - Renombrar nombre fichero para quitarle '_' cuando ya generado.*/
	            IF utl_file.is_open(w_fichero) THEN
	              utl_file.fclose(w_fichero);

	              utl_file.frename(w_rutaout, w_nomfichero, w_rutaout, ltrim(w_nomfichero, '_'));
	            END IF;

	            /* Fi Bug 0013153*/
	            w_fichero:=utl_file.fopen(w_rutaout, w_nomfichero, 'W');

	            BEGIN
	                SELECT DISTINCT lpad(tsufijo, 4, '0'),cdoment,cempres
	                  INTO w_ident_emi, w_cdoment, w_cempres
	                  FROM cobbancario
	                 WHERE ncuenta=r.ccc AND
	                       cempres=r.cempres
	                       /* BUG9693:DRA:29/04/2009*/
	                       AND
	                       cbaja=0 AND
	                       (ccobban=r.ccobban  OR
	                        r.ccobban IS NULL);
	            /* BUG9693:DRA:19/05/2009*/
	            EXCEPTION
	                WHEN OTHERS THEN
	                  p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_genera_fichero_iban', 111, 'CCC: '
	                                                                                                  || r.ccc, SQLERRM);

	                  w_ident_emi:='  ';

	                  w_cdoment:='  ';

	                  w_cempres:=NULL; /* BUG13820:DRA:25/03/2010:Fi*/

	                  RETURN 103941; /* BUG13820:DRA:25/03/2010:Fi*/
	            END;

	            num_err:=f_desempresa(w_cempres, NULL, w_tempres);

	            w_linia:='1'
	                     || w_ident_emi
	                     || lpad(w_cdoment, 2, '0')
	                     || to_char(d_avui, 'ddmmrr')
	                     || rpad(w_tempres, 30, ' ')
	                     || 'A'
	                     || rpad(isomonedainst, 3, '0')
	                     || to_char(nvl(pfabono, r.fabono), 'ddmmrr')
	                     /* BUG13931:ICV::29/03/2010*/
	                     || 'T' -- BUG12913:DRA:05/02/2010
	                     || rpad(substr(r.ccc, 1, 24), 24, ' ')
	                     || lpad(' ', 39, ' ')
	                     || to_char(d_avui, 'rr')
	                     || lpad(r.nremesa, 5, '0')
	                     || 'A010';

	            utl_file.put_line(w_fichero, w_linia);
	          END IF;

	        /*Registre 2*/
	          /*SELECT npoliza, ncertif
	            INTO w_npoliza, w_npoliza
	            FROM seguros
	           WHERE sseguro = r.sseguro;*/
	          num_err:=f_nomrecibo(r.sseguro, w_tnombre, w_cidioma, w_sperson, w_cdomici);

	          /* ini Bug 21502 - MDS - 28/02/2012 - codigo fuente recuperado*/
	          IF r.catribu=7 THEN
	          /* no cojemos el nombre del tomador, tomamops los datos del SIN_TRAMITA_DESTINATARIO*/
	            /*  wd_sperson:= r.sperson;*/
	            w_tnombre:=f_nombre(r.sperson, 1);
	          END IF;

	          /* fin Bug 21502 - MDS - 28/02/2012*/
	          num_err:=f_direccion(1, w_sperson, w_cdomici, 1, w_tiplin1, w_tiplin2, w_tiplin3);

	          BEGIN
	          /*Bug10612 - 14/07/2009 - DCT (canviar vista personas)*/
	              /*Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro*/
	              SELECT cagente,cempres
	                INTO vagente_poliza, vcempres
	                FROM seguros
	               WHERE sseguro=r.sseguro;

	              SELECT nvl(codisoiban, '  ')
	                INTO w_codipaisiso
	                FROM per_detper pd,paises p
	               WHERE p.cpais=pd.cpais AND
	                     pd.cagente=ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres) AND
	                     pd.sperson=w_sperson;
	          EXCEPTION
	              WHEN OTHERS THEN
	                w_codipaisiso:='  ';
	          END;

	          BEGIN
	          /* BUG 8217 - 07/05/2009 - SBG - Afegim un NVL perquè si és nul,*/
	              /* desquadra el fitxer*/
	              SELECT nvl(snip, '0') -- BUG13820:DRA:25/03/2010:Fi
	                INTO w_codisnip
	                FROM per_personas
	               WHERE sperson=w_sperson;
	          EXCEPTION
	              WHEN OTHERS THEN
	                w_codisnip:='0'; -- BUG13820:DRA:25/03/2010:Fi
	          END;

	          w_codisnip:=lpad(w_codisnip, 7, '0');

	          /* BUG13820:DRA:25/03/2010:Fi*/
	          IF w_tiplin1 IS NULL THEN
	            w_tiplin1:=' ';
	          END IF;

	          IF w_tiplin2 IS NULL THEN
	            w_tiplin2:=' ';
	          END IF;

	          /* ini Bug 21502 - MDS - 28/02/2012 - codigo fuente recuperado*/
	          IF r.catribu=11 THEN
	            n_lina:='04';
	          ELSIF r.catribu=7 THEN
	            SELECT cpolcia,nsincia,ccompani
	              INTO vcpolcia, vnsincia, vccompani
	              FROM sin_tramitacion st,sin_tramita_pago stp
	             WHERE st.nsinies=r.nsinies AND
	                   st.nsinies=stp.nsinies AND
	                   stp.sidepag=r.sidepag AND
	                   stp.ntramit=st.ntramit;

	            IF vcpolcia IS NOT NULL AND
	               vnsincia IS NOT NULL AND
	               vccompani IS NOT NULL THEN
	              n_lina:='04';
	            ELSE
	              n_lina:='01';
	            END IF;
	          ELSE
	            n_lina:='01';
	          END IF;

	          /* fin Bug 21502 - MDS - 28/02/2012*/
	          w_cereceptora:=rpad(substr(r.cabono, 7, 2), 2, '0');

	          /* ini Bug 21502 - MDS - 28/02/2012 - codigo fuente modificado*/
	          w_linia:='2'
	                   || w_ident_emi
	                   /*|| LPAD (w_npoliza, 10, ' ')
	                   || LPAD (SUBSTR (w_ncertif, 1, 4), 4, ' ')*/
	                   || rpad(w_codisnip, 14, ' ')
	                   || rpad(substr(w_tnombre, 1, 30), 30, ' ')
	                   || rpad(substr(w_tiplin1, 1, 30), 30, ' ')
	                   || rpad(substr(w_tiplin2, 1, 20), 20, ' ')
	                   || w_codipaisiso /*codipais iso*/
	                   || 'C'
	                   || lpad(to_char(r.iimport*100), 12, '0')
	                   || w_cereceptora
	                   || '  ' --Sucursal (opcional)
	                   || n_lina /*Número de registres de tipus 3*/
	                   || ' ' --Tipus document, no significatiu
	                   || lpad(' ', 7, ' '); --Espais

	          /* fin Bug 21502 - MDS - 28/02/2012*/
	          utl_file.put_line(w_fichero, w_linia);

	          w_total:=w_total+r.iimport;

	          /*Registre 2D*/
	          w_linia:='2'
	                   || w_ident_emi
	                   /*|| LPAD (w_npoliza, 10, ' ')
	                   || LPAD (SUBSTR (w_ncertif, 1, 4), 4, ' ')*/
	                   || rpad(w_codisnip, 14, ' ')
	                   || ' ' --Despeses a carrec del beneficiari?
	                   || rpad(r.cabono, 34, ' ') -- BUG11119:DRA:16/09/2009
	                   || lpad(' ', 30, ' ')
	                   /*Nom ordenant si es diferent del registre 1*/
	                   || lpad(' ', 35, ' ') --Motiu del pagament
	                   || lpad(' ', 8, ' ') --Espais
	                   || 'D'; --Tipus registre 2

	          utl_file.put_line(w_fichero, w_linia);

	        /*Registre 2E*/
	          /*SELECT descripcion
	            INTO w_tempres
	            FROM cobbancario
	           WHERE ncuenta = r.cabono AND cbaja = 0;*/
	          num_err:=f_domibanc_poliza(r.sseguro, w_tempres, w_toficina, w_diroficina, w_poblac, w_numcuenta);

	          BEGIN
	              SELECT nvl(ppp.codisoiban, '  ')
	                INTO w_codipaisiso
	                FROM paises ppp,provincias p,poblaciones pp
	               WHERE ppp.cpais=p.cpais AND
	                     pp.cprovin=p.cprovin AND
	                     upper(pp.tpoblac)=upper(w_poblac) AND
	                     ROWNUM=1;
	          EXCEPTION
	              WHEN OTHERS THEN
	                w_codipaisiso:='  ';
	          END;

	          IF w_codipaisiso!='AD' AND
	             w_codipaisiso!='  ' THEN
	            w_linia:='2'
	                     || w_ident_emi
	                     /*|| LPAD (w_npoliza, 10, ' ')
	                     || LPAD (SUBSTR (w_ncertif, 1, 4), 4, ' ')*/
	                     || rpad(w_codisnip, 14, ' ')
	                     || rpad(w_tempres, 35, ' ') --Nom banc beneficiari
	                     || rpad(w_diroficina, 35, ' ') --Adrça banc beneficiari
	                     || rpad(w_poblac, 27, ' ') --Poblacio ban beneficiari
	                     || lpad(' ', 8, ' ') --Codi CHIPS
	                     || lpad(w_codipaisiso, 2, ' ') --Codi pais banc beneficiari
	                     || lpad(' ', 1, ' ') --Espais
	                     || 'E'; --Tipus registre 2

	            utl_file.put_line(w_fichero, w_linia);
	          END IF;

	        /*Registre 3*/
	        /* Bug 10775 - APD - 30/07/2009 - Modificación fichero de transferencias para reembolsos*/
	        /* en el apartado de texto libre debe aparecer la siguiente informacion si catribu = 11:*/
	        /*    MALALT:XXXXXXX           FULL:XXXXXXXXXXXXXX NPAGAM:XXXXXXX*/
	        /*                             DATA      PAGAR*/
	        /*    NATURALESA ACTE          ACTE      IMPORT*/
	          /*    DESPESA SANITARIA      XX-XX-XX    XXXXX*/
	          IF r.catribu=11 THEN BEGIN
	                SELECT rf.ncass,rf.nfact_cli,rf.nfactext,raf.facto
	                  INTO w_ncass, w_nfact_cli, w_nfactext, w_facto
	                  FROM reembfact rf,reembactosfac raf
	                 WHERE rf.nreemb=raf.nreemb AND
	                       rf.nfact=raf.nfact AND
	                       raf.nreemb=r.nreemb AND
	                       raf.nfact=r.nfact AND
	                       raf.nlinea=r.nlinea;
	            EXCEPTION
	                WHEN OTHERS THEN
	                  w_ncass:=NULL;

	                  w_nfact_cli:=NULL;

	                  w_nfactext:=NULL;

	                  w_facto:=NULL;
	            END; w_linia := '3'|| w_ident_emi|| rpad(w_codisnip, 14, ' ')|| '01' -- BUG11119:DRA:14/09/2009
	          || rpad (rpad (upper (f_axis_literales(9002043, nvl(w_cidioma, pac_md_common.f_get_cxtidioma))) /* Malalt*/
	          || w_ncass, 21, ' ')|| rpad (upper (f_axis_literales(100855, nvl(w_cidioma, pac_md_common.f_get_cxtidioma))) /* Full*/
	          || w_nfact_cli, 24, ' ')|| rpad (upper (f_axis_literales(9002044, nvl(w_cidioma, pac_md_common.f_get_cxtidioma))) /* N.Pagam*/
	          || w_nfactext, 33, ' '), 78, ' ') --Format lliure
	          || rpad(' ', 29, ' '); --Espais
	          utl_file.put_line(w_fichero, w_linia); w_linia := '3'|| w_ident_emi|| rpad(w_codisnip, 14, ' ')|| '02' -- BUG11119:DRA:14/09/2009
	          || rpad (rpad(' ', 26, ' ')|| rpad (upper (f_axis_literales(100562, nvl(w_cidioma, pac_md_common.f_get_cxtidioma))) /* Data*/
	          || ' '|| ' ', 26, ' ')|| rpad (upper (f_axis_literales(9002045, nvl(w_cidioma, pac_md_common.f_get_cxtidioma))) /* Pagar*/
	          || ' '|| ' ', 26, ' '), 78, ' ') --Format lliure
	          || rpad(' ', 29, ' '); --Espais
	          utl_file.put_line(w_fichero, w_linia); w_linia := '3'|| w_ident_emi|| rpad(w_codisnip, 14, ' ')|| '03' -- BUG11119:DRA:14/09/2009
	          || rpad (rpad (upper (f_axis_literales(9002046, nvl(w_cidioma, pac_md_common.f_get_cxtidioma))) /* Naturalesa Acte*/
	          || ' '|| ' ', 26, ' ')|| rpad (upper (f_axis_literales(9000456, nvl(w_cidioma, pac_md_common.f_get_cxtidioma))) /* Acte*/
	          || ' '|| ' ', 26, ' ')|| rpad (upper (f_axis_literales(100563, nvl(w_cidioma, pac_md_common.f_get_cxtidioma))) /* Import*/
	          || ' '|| ' ', 26, ' '), 78, ' ') --Format lliure
	          || rpad(' ', 29, ' '); --Espais
	          utl_file.put_line(w_fichero, w_linia); w_linia := '3'|| w_ident_emi|| rpad(w_codisnip, 14, ' ')|| '04' -- BUG11119:DRA:14/09/2009
	          || rpad (rpad (upper (f_axis_literales(9002047, nvl(w_cidioma, pac_md_common.f_get_cxtidioma))) /* Despesa Sanitaria*/
	          || ' '|| ' ', 26, ' ')|| rpad(to_char(w_facto, 'dd-mm-yy'), 26, ' ')
	          /*fecha*/
	          || rpad(ltrim(to_char(r.iimport, '999G990D00')), 26, ' ') -- importe
	          , 78, ' ') --Format lliure
	          || rpad(' ', 29, ' '); --Espais
	          utl_file.put_line(w_fichero, w_linia);
	          /* Bug 10775 - APD - 30/07/2009 - Fin Modificación fichero de transferencias para reembolsos*/
	          ELSIF r.catribu=7 THEN /*Siniestros*/
	            w_linia:='3'
	                     || w_ident_emi
	                     /*|| LPAD (w_npoliza, 10, ' ')
	                     || LPAD (SUBSTR (w_ncertif, 1, 4), 4, ' ')*/
	                     || rpad(w_codisnip, 14, ' ')
	                     || '01' -- BUG11119:DRA:14/09/2009
	                     /*|| RPAD('Abonament al seu compte s/factura num. ' || r.nsinies, 78, ' ')   --Format lliure*/
	                     || rpad (f_axis_literales (9001804, nvl(w_cidioma, pac_md_common.f_get_cxtidioma)) /* BUG10442:DRA:15/06/2009*/
	                              || ' '
	                              || nvl(r.nsinies, r.nrecibo), --MCA 27/11/2009
	                        78, ' ') --Format lliure
	                     || rpad(' ', 29, ' '); --Espais

	            utl_file.put_line(w_fichero, w_linia);

	            IF vcpolcia IS NOT NULL  OR
	               vnsincia IS NOT NULL  OR
	               vccompani IS NOT NULL THEN
	              IF vccompani IS NOT NULL THEN
	                SELECT tcompani
	                  INTO vtcompani
	                  FROM companias comp
	                 WHERE comp.ccompani=vccompani;

	                v_text:=f_axis_literales (9901223, nvl(w_cidioma, pac_md_common.f_get_cxtidioma)) /* BUG10442:DRA:15/06/2009*/
	                        || ' '
	                        || vtcompani;

	                w_linia:='3'
	                         || w_ident_emi
	                         /*|| LPAD (w_npoliza, 10, ' ')
	                         || LPAD (SUBSTR (w_ncertif, 1, 4), 4, ' ')*/
	                         || rpad(w_codisnip, 14, ' ')
	                         || '02' -- BUG11119:DRA:14/09/2009
	                         /*|| RPAD('Abonament al seu compte s/factura num. ' || r.nsinies, 78, ' ')   --Format lliure*/
	                         || rpad(v_text, 78, ' ') --Format lliure
	                         || rpad(' ', 29, ' '); --Espais

	                utl_file.put_line(w_fichero, w_linia);
	              END IF;

	              IF vnsincia IS NOT NULL THEN
	                v_text:=v_text
	                        || ', '
	                        || f_axis_literales (101298, nvl(w_cidioma, pac_md_common.f_get_cxtidioma)) /* BUG10442:DRA:15/06/2009*/
	                        || ' '
	                        || vnsincia;

	                w_linia:='3'
	                         || w_ident_emi
	                         /*|| LPAD (w_npoliza, 10, ' ')
	                         || LPAD (SUBSTR (w_ncertif, 1, 4), 4, ' ')*/
	                         || rpad(w_codisnip, 14, ' ')
	                         || '03' -- BUG11119:DRA:14/09/2009
	                         /*|| RPAD('Abonament al seu compte s/factura num. ' || r.nsinies, 78, ' ')   --Format lliure*/
	                         || rpad(v_text, 78, ' ') --Format lliure
	                         || rpad(' ', 29, ' '); --Espais

	                utl_file.put_line(w_fichero, w_linia);
	              END IF;

	              IF vcpolcia IS NOT NULL THEN
	                v_text:=v_text
	                        || ', '
	                        || f_axis_literales (9001766, nvl(w_cidioma, pac_md_common.f_get_cxtidioma)) /* BUG10442:DRA:15/06/2009*/
	                        || ' '
	                        || vcpolcia;

	                w_linia:='3'
	                         || w_ident_emi
	                         /*|| LPAD (w_npoliza, 10, ' ')
	                         || LPAD (SUBSTR (w_ncertif, 1, 4), 4, ' ')*/
	                         || rpad(w_codisnip, 14, ' ')
	                         || '04' -- BUG11119:DRA:14/09/2009
	                         /*|| RPAD('Abonament al seu compte s/factura num. ' || r.nsinies, 78, ' ')   --Format lliure*/
	                         || rpad(v_text, 78, ' ') --Format lliure
	                         || rpad(' ', 29, ' '); --Espais

	                utl_file.put_line(w_fichero, w_linia);
	              END IF;
	            END IF;
	          ELSE
	            w_linia:='3'
	                     || w_ident_emi
	                     /*|| LPAD (w_npoliza, 10, ' ')
	                     || LPAD (SUBSTR (w_ncertif, 1, 4), 4, ' ')*/
	                     || rpad(w_codisnip, 14, ' ')
	                     || '01' -- BUG11119:DRA:14/09/2009
	                     /*|| RPAD('Abonament al seu compte s/factura num. ' || r.nsinies, 78, ' ')   --Format lliure*/
	                     || rpad (f_axis_literales (9001804, nvl(w_cidioma, pac_md_common.f_get_cxtidioma)) /* BUG10442:DRA:15/06/2009*/
	                              || ' '
	                              || nvl(r.nsinies, r.nrecibo), --MCA 27/11/2009
	                        78, ' ') --Format lliure
	                     || rpad(' ', 29, ' '); --Espais

	            utl_file.put_line(w_fichero, w_linia);
	          END IF;

	          w_cuantos:=w_cuantos+1;
	        END IF;
	    END LOOP;

	    /*Registre 4*/
	    IF w_cuantos>0 THEN
	      w_linia:='4'
	               || w_ident_emi
	               || lpad(substr(w_cdoment, 1, 2), 2, '0')
	               /* Bug 0019583 - JMF - 26/09/2011 ||w_cereceptora*/
	               || to_char(d_avui, 'ddmmrr')
	               || 'A'
	               || isomonedainst --iso de moneda
	               || lpad(to_char(w_total*100), 14, '0') --import total
	               || lpad(w_cuantos, 5, '0') --Nro documents
	               || lpad(' ', 92, ' '); --Espais

	      utl_file.put_line(w_fichero, w_linia);

	      utl_file.fclose(w_fichero);
	    END IF;

	    IF utl_file.is_open(w_fichero) THEN
	      utl_file.fclose(w_fichero);
	    END IF;

	    /* Bug 0013153 - FAL - 18/03/2010 - Renombrar nombre fichero para quitarle '_' cuando ya generado.*/
	    IF NOT utl_file.is_open(w_fichero) THEN
	      utl_file.frename(w_rutaout, w_nomfichero, w_rutaout, ltrim(w_nomfichero, '_'));
	    END IF;

	    /* FI bug 0013153*/
	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             IF utl_file.is_open(w_fichero) THEN
	               utl_file.fclose(w_fichero);
	             END IF;

	             p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_genera_fichero_iban', 1, 'error no controlado', SQLERRM);

	             RETURN 140999; /*error no controlado*/
	END f_generacion_fichero_iban;
	FUNCTION f_generar_fichero(
			pnremesa	IN	NUMBER,
			pfabono	IN	DATE
	) /* BUG12913:DRA:04/02/2010*/
	RETURN NUMBER
	IS
	  num_err NUMBER:=0;
	  vruta   VARCHAR2(100);
	BEGIN
	    /* Actualmente no estamos preparados para generar el fichero iban del tipo BElBA, nos falta*/
	    FOR reg IN (SELECT ctipban
	                  FROM remesas_previo
	                 WHERE nremesa=pnremesa AND
	                       cmarcado=1 AND
	                       cusuario=f_user
	                 GROUP BY ctipban) LOOP
	        /* como cada instalacion crea en el recibo las descripciones
	          y las lineas que le parece, encapsulamos la generación
	          del fichero en el PAC_PROPIO*/
	        IF reg.ctipban=1 THEN /* Cuenta española*/
	          num_err:=f_generacion_fichero(pnremesa, pfabono);

	          /* BUG12913:DRA:04/02/2010*/
	          IF num_err!=0 THEN
	            RETURN num_err;
	          END IF;
	        ELSIF reg.ctipban=2 THEN /* Formato iban andorra.*/
	          num_err:=f_generacion_fichero_iban(pnremesa, pfabono);

	          /* BUG12913:DRA:04/02/2010*/
	          IF num_err!=0 THEN
	            RETURN num_err;
	          END IF;
	        /*Ini Bug.: 13830 - ICV - 27/04/2010*/
	        ELSIF reg.ctipban=4 THEN /*Formato CCC Belgica*/
	          num_err:=f_generacion_fichero_apra(pnremesa, pfabono);

	          IF num_err!=0 THEN
	            RETURN num_err;
	          END IF;
	        /*Fin Bug.: 13830*/
	        ELSIF reg.ctipban=5 THEN /*Formato CCC Angola*/
	          num_err:=f_generacion_fichero_ensa(pnremesa, vruta);

	          IF num_err!=0 THEN
	            RETURN num_err;
	          END IF;
	        /*Fin Bug.: 13830*/
	        END IF;
	    END LOOP;

	    RETURN num_err;
	END f_generar_fichero;

	/*************************************************************************
	 FUNCTION f_act_reembacto
	 Actualitza els reembolsos marcant-los com transferits
	 param in p_nreemb    : código del reembolso
	 return             : NUMBER
	*************************************************************************/
	FUNCTION f_act_reembacto(
			p_nreemb	IN	NUMBER,
			p_sremesa	IN	NUMBER,
			p_ftrans	IN	DATE,
			p_nfact	IN	NUMBER,
			p_nlinea	IN	NUMBER,
			p_ctipo	IN	NUMBER
	) RETURN NUMBER
	IS
	  /**/
	  v_cestado  reembolsos.cestado%TYPE;
	  v_numlin   NUMBER;
	  v_numlin_2 NUMBER;
	BEGIN
	    IF p_ctipo=1 THEN /* Pago Normal*/
	      UPDATE reembactosfac
	         SET ftrans=p_ftrans,nremesa=p_sremesa /*BUG11285-XVM-02102009*/
	       WHERE nreemb=p_nreemb AND
	             nfact=p_nfact AND
	             nlinea=p_nlinea;

	      SELECT cestado
	        INTO v_cestado
	        FROM reembolsos
	       WHERE nreemb=p_nreemb;

	      SELECT count(1)
	        INTO v_numlin
	        FROM reembactosfac
	       WHERE nreemb=p_nreemb AND
	             ftrans IS NULL AND
	             nremesa IS NULL;

	      /* contamos cuantos quedan de importe 0 (los complementarios son ipago=0)*/
	      SELECT nvl(count(1), 0)
	        INTO v_numlin_2
	        FROM reembactosfac
	       WHERE nreemb=p_nreemb AND
	             ftrans IS NULL AND
	             ipago=0;

	    /* Bug 10775 - APD - 03/08/2009 - si el estado del reembolso es Aceptado o Gestión compañia*/
	    /* y no queda ningún acto por transferir, se marca el reembolso como transferido*/
	    /* Si el reembolso estaba aceptado también se marca como transferido*/
	      /* 10/06/2010 JGR 10. 0014570: AXIS1991 - Pasar a estado transferido- INI*/
	      IF (v_cestado=2 /* Aceptado*/
	           OR
	          v_cestado=1) /* Gestión compañía*/
	         AND
	         v_numlin=0  OR
	         (v_numlin>0 AND
	          v_numlin=v_numlin_2) THEN /*> Si lo que quedan son de importe 0*/
	      BEGIN
	            UPDATE reembolsos
	               SET cestado=3,festado=p_ftrans
	             WHERE nreemb=p_nreemb;
	        EXCEPTION
	            WHEN OTHERS THEN
	              p_tab_error (f_sysdate, f_user, 'pac_transferencias.f_act_reembacto(A)', 2, 'error no controlado. update reembolsos set cestado = 3 and festado = '
	                                                                                          || p_ftrans
	                                                                                          || ' where nreemb = '
	                                                                                          || p_nreemb
	                                                                                          || '. p_sremesa: '
	                                                                                          || p_sremesa, SQLERRM);

	              RETURN 140999; /*error no controlado*/
	        END;
	      END IF;
	    /* 10/06/2010 JGR 10. 0014570: AXIS1991 - Pasar a estado transferido- FI*/
	    /*         IF (v_cestado = 2   -- Aceptado*/
	    /*             OR v_cestado = 1)   -- Gestión compañía*/
	    /*            AND NVL(v_numlin, 0) = 0 THEN*/
	    /*            -- Si no queda ningún acto por transferir marcamos al reembolso como transferido*/
	    /*            -- Si el reembolso estaba aceptado también se marca como transferido*/
	    /*            UPDATE reembolsos*/
	    /*               SET cestado = 3,*/
	    /*                   festado = p_ftrans*/
	    /*             WHERE nreemb = p_nreemb;*/
	    /*         END IF;*/
	    ELSIF p_ctipo=2 THEN /* Pago Complemento*/
	      UPDATE reembactosfac
	         SET ftranscomp=p_ftrans,nremesacomp=p_sremesa /*BUG11285-XVM-02102009*/
	       WHERE nreemb=p_nreemb AND
	             nfact=p_nfact AND
	             nlinea=p_nlinea;

	      /* 18/05/2010 JGR 9. 0014570: AXIS1916 - Pasar a estado transferido- INI*/
	      SELECT nvl(count(1), 0)
	        INTO v_numlin
	        FROM reembactosfac
	       WHERE nreemb=p_nreemb AND
	             ftrans IS NULL;

	      SELECT nvl(count(1), 0)
	        INTO v_numlin_2
	        FROM reembactosfac
	       WHERE nreemb=p_nreemb AND
	             ftrans IS NULL AND
	             ipago=0;

	      IF v_numlin=0  OR
	         (v_numlin>0 AND
	          v_numlin=v_numlin_2) THEN BEGIN
	            UPDATE reembolsos
	               SET cestado=3,festado=p_ftrans
	             WHERE nreemb=p_nreemb;
	        EXCEPTION
	            WHEN OTHERS THEN
	              p_tab_error (f_sysdate, f_user, 'pac_transferencias.f_act_reembacto', 2, 'error no controlado. update reembolsos set cestado = 3 and festado = '
	                                                                                       || p_ftrans
	                                                                                       || ' where nreemb = '
	                                                                                       || p_nreemb
	                                                                                       || '. p_sremesa: '
	                                                                                       || p_sremesa, SQLERRM);

	              RETURN 140999; /*error no controlado*/
	        END;
	      END IF;
	    /* 18/05/2010 JGR 9. 0014570: AXIS1916 - Pasar a estado transferido- FIN*/
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_act_reembacto', 1, 'error no controlado. reemb: '
	                                                                                     || p_nreemb
	                                                                                     || '. p_sremesa: '
	                                                                                     || p_sremesa, SQLERRM);

	             RETURN 140999; /*error no controlado*/
	END f_act_reembacto;

	/* BUG10604:DRA:02/07/2009:Fi*/
	/***********************************************************************
	   Limpia de la tabla remesas_previo los registros de un usuario
	   param out mensajes : mensajes de error
	   return             : 0 OK, 1 Error
	***********************************************************************/
	FUNCTION f_limpia_remesasprevio
	RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_transferencias.f_limpia_remesasprevio';
	/*vparam         VARCHAR2(500) := 'parámetros - ';*/
	BEGIN
	    DELETE FROM remesas_previo
	     WHERE cusuario=f_user;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, 1, 'error no controlado', SQLERRM);

	             RETURN 9001841;
	END f_limpia_remesasprevio;

	/***********************************************************************
	   Función que nos dice si tenemos registros pendientes de gestionar por un usuario(f_user)
	   en el caso que haya registros para gestionar devolveremos en el param phayregistros un 1,
	   en el caso contrario phayregistros =  0
	   param out mensajes : mensajes de error
	   param out hayregistros : 0 no hay registros, n num. registros
	   return             : 0 OK , 1 error
	***********************************************************************/
	FUNCTION f_registros_pendientes(
			phayregistros	OUT	NUMBER
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_transferencias.f_registros_pendientes';
	/*vparam         VARCHAR2(500) := 'parámetros - ';*/
	BEGIN
	    SELECT count(1)
	      INTO phayregistros
	      FROM remesas_previo
	     WHERE cusuario=f_user AND
	           nremesa IS NULL AND
	           ftransf IS NULL;

	    DELETE FROM remesas_previo
	     WHERE cusuario=f_user AND
	           nremesa IS NOT NULL AND
	           ftransf IS NOT NULL;

	    /* COMMIT;*/
	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             /* ROLLBACK;*/
	             p_tab_error(f_sysdate, f_user, vobjectname, 1, 'error no controlado', SQLERRM);

	             RETURN 9001842;
	END f_registros_pendientes;

	/***********************************************************************
	      Función que nos dice si tenemos registros en las tablas que ya esten intentando transferir
	      otros usuarios, en este caso devolveremos una notificación y no dejaremos seguir. Ya que los registros
	      ya estaran siendo modificados.
	      param in  ptipobusqueda : varchar2, tots els tipus que hem marcat per fer la cerca
	      param out hayregistros : 0 no hay registros, 1 hay registros
	      return             : 0 OK , 1 error
	   ***********************************************************************/
	FUNCTION f_registros_duplicados(
			ptipobusqueda	IN	VARCHAR2,
			phayregistros	OUT	NUMBER
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_transferencias.f_registros_duplicados';
	  /*vparam         VARCHAR2(500) := 'parámetros -ptipobusqueda : ' || ptipobusqueda;*/
	  pos         NUMBER;
	  tipo        VARCHAR2(2000);
	  e_registro_duplicado EXCEPTION;
	  posdp       NUMBER;
	BEGIN
	    IF ptipobusqueda IS NOT NULL THEN
	      FOR i IN 1 .. length(ptipobusqueda) LOOP
	          pos:=instr(ptipobusqueda, '|', 1, i);

	          posdp:=instr(ptipobusqueda, '|', 1, i+1);

	          tipo:=substr(ptipobusqueda, pos+1, (posdp-pos)-1);

	          IF tipo IS NOT NULL THEN
	            SELECT count(1)
	              INTO phayregistros
	              FROM remesas_previo
	             WHERE cusuario!=f_user AND
	                   ctipoproceso=to_number(tipo);

	            IF phayregistros>0 THEN
	              RAISE e_registro_duplicado;
	            END IF;
	          END IF;
	      END LOOP;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN e_registro_duplicado THEN
	             RETURN 9001843; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, 1, 'error no controlado', SQLERRM);

	             RETURN 9001843;
	END f_registros_duplicados;

	/***********************************************************************
	      Función que nos dice si tenemos registros en las tablas que ya esten intentando transferir
	      otros usuarios, en este caso devolveremos una notificación y no dejaremos seguir. Ya que los registros
	      ya estaran siendo modificados.
	      param in  ptipobusqueda : varchar2, tots els tipus que hem marcat per fer la cerca
	      param int ptipo : 1 Rentas, 2 Recibos, 3 Siniestros y 4 Reembolsos
	      return             : 1 ENCONRADO , 0 no encontrado
	   ***********************************************************************/
	FUNCTION f_istipobusqueda(
			ptipobusqueda	IN	VARCHAR2,
			ptipo	IN	VARCHAR2
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_transferencias.f_isTipoBusqueda';
	/*vparam         VARCHAR2(500) := 'parámetros - ptipobusqueda : ' || ptipobusqueda || ', ptipo : ' || ptipo;*/
	/*pos            NUMBER;*/
	/*tipo           VARCHAR2(2000);*/
	/*posdp          NUMBER;*/
	BEGIN
	/* BUG17286:DRA:25/01/2011:Inici: Optimitzo la búsqueda de caràcters*/
	/*FOR i IN 1 .. LENGTH(ptipobusqueda) LOOP*/
	/*   pos := INSTR(ptipobusqueda, '|', 1, i);*/
	/*   posdp := INSTR(ptipobusqueda, '|', 1, i + 1);*/
	/*   tipo := SUBSTR(ptipobusqueda, pos + 1,(posdp - pos) - 1);*/
	/*   IF tipo IS NOT NULL THEN*/
	/*      IF tipo = ptipo THEN*/
	/*         RETURN 1;*/
	/*      END IF;*/
	/*   END IF;*/
	    /*END LOOP;*/
	    IF instr(ptipobusqueda, '|'
	                            || ptipo
	                            || '|')<>0 THEN
	      RETURN 1;
	    END IF;

	    /* BUG17286:DRA:25/01/2011:Fi*/
	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, 1, 'error no controlado', SQLERRM);

	             RETURN 0;
	END f_istipobusqueda;

	/***********************************************************************
	      Función que nos dice si tenemos registros en las tablas que ya esten intentando transferir
	      otros usuarios, en este caso devolveremos una notificación y no dejaremos seguir. Ya que los registros
	      ya estaran siendo modificados.
	      param in  ptipobusqueda : varchar2, tots els tipus que hem marcat per fer la cerca
	      param int ptipo : 1 Rentas, 2 Recibos, 3 Siniestros y 4 Reembolsos
	      return             : 1 ENCONRADO , 0 no encontrado
	   ***********************************************************************/
	FUNCTION f_get_wherecatribu(
			ptipobusqueda	IN	VARCHAR2
	) RETURN VARCHAR2
	IS
	  vobjectname VARCHAR2(500):='pac_transferencias.f_get_wherecatribu';
	  /*vparam         VARCHAR2(500) := 'parámetros - ptipobusqueda : ' || ptipobusqueda;*/
	  pos         NUMBER;
	  tipo        VARCHAR2(2000);
	  pwhere      VARCHAR2(2000);
	  vtipo       NUMBER;
	BEGIN
	    FOR i IN 0 .. length(ptipobusqueda) LOOP
	        pos:=instr(ptipobusqueda, '|', 1, i+1);

	        tipo:=substr(ptipobusqueda, pos-1, 1);

	        IF tipo IS NOT NULL THEN BEGIN
	              vtipo:=to_number(tipo);

	              IF pwhere IS NOT NULL THEN
	                pwhere:=pwhere
	                        || ' OR ';
	              END IF;

	              pwhere:=pwhere
	                      || ' CATRIBU = '
	                      || vtipo;
	          EXCEPTION
	              WHEN OTHERS THEN
	                NULL;
	          END;
	        END IF;
	    END LOOP;

	    IF pwhere IS NOT NULL THEN
	      pwhere:=' AND '
	              || pwhere;
	    END IF;

	    RETURN pwhere;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, 1, 'error no controlado', SQLERRM);

	             RETURN NULL;
	END f_get_wherecatribu;
	FUNCTION f_get_ctacargo_age(pcempres	IN	NUMBER,/* BUG14344:DRA:05/05/2010*/psseguro	IN	NUMBER,pcconcep	IN	NUMBER,p_ccc_abono	IN	VARCHAR2,/* BUG11396:DRA:14/01/2010*/p_ctipban_abono	IN	NUMBER,/* BUG11396:DRA:14/01/2010*/w_producto	OUT	NUMBER,w_cuenta	OUT	VARCHAR2,w_ctipban	OUT	VARCHAR2,v_ccobban	OUT	NUMBER,v_agente	OUT	NUMBER)
	RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_transferencias.f_get_ctacargo';
	  /*vparam         VARCHAR2(500) := 'parámetros - psseguro : ' || psseguro || ', p_ccc_abono: ' || p_ccc_abono || ', p_ctipban_abono: ' || p_ctipban_abono;*/
	  vcramo      NUMBER;
	  vcmodali    NUMBER;
	  vctipseg    NUMBER;
	  vccolect    NUMBER;
	  vcagente    NUMBER;
	  /* Bug 18225 - APD - 11/04/2011 - la precisión debe ser NUMBER*/
	  /*vcbancar       VARCHAR2(40);*/
	  /*vctipban       VARCHAR2(40);*/
	  /*vnum_err       NUMBER;*/
	  vtraza      NUMBER;
	BEGIN
	    BEGIN
	        vtraza:=1;

	        BEGIN
	            SELECT s.sproduc,cb.ncuenta,cb.ctipban,pc.ccobban,s.cagente
	              INTO w_producto, w_cuenta, w_ctipban, v_ccobban, v_agente
	              FROM seguros s,prodctacargo pc,cobbancario cb /* BUG11396:DRA:14/01/2010*/
	             WHERE s.sseguro=psseguro AND
	                   pc.sproduc=s.sproduc AND
	                   pc.cconcep=pcconcep AND
	                   cb.ccobban=pc.ccobban; /* BUG11396:DRA:14/01/2010*/
	        EXCEPTION
	            WHEN no_data_found THEN BEGIN
	                  /* Concepto generico*/
	                  SELECT s.sproduc,cb.ncuenta,cb.ctipban,pc.ccobban,s.cagente
	                    INTO w_producto, w_cuenta, w_ctipban, v_ccobban, v_agente
	                    FROM seguros s,prodctacargo pc,cobbancario cb /* BUG11396:DRA:14/01/2010*/
	                   WHERE s.sseguro=psseguro AND
	                         pc.sproduc=s.sproduc AND
	                         pc.cconcep=0 AND
	                         cb.ccobban=pc.ccobban; /* BUG11396:DRA:14/01/2010*/
	              EXCEPTION
	                  WHEN no_data_found THEN
	                    /* Concepto generico y producto generico*/
	                    SELECT s.sproduc,cb.ncuenta,cb.ctipban,pc.ccobban,s.cagente
	                      INTO w_producto, w_cuenta, w_ctipban, v_ccobban, v_agente
	                      FROM seguros s,prodctacargo pc,cobbancario cb /* BUG11396:DRA:14/01/2010*/
	                     WHERE s.sseguro=psseguro AND
	                           pc.sproduc=0 AND
	                           pc.cconcep=0 AND
	                           cb.ccobban=pc.ccobban;
	              /* BUG11396:DRA:14/01/2010*/
	              END;
	        END;

	        vtraza:=2;
	    EXCEPTION
	        WHEN OTHERS THEN
	          vtraza:=3;

	          BEGIN
	              SELECT cramo,cmodali,ctipseg,ccolect,cagente,s.ccobban,sproduc,cb.ncuenta,cb.ctipban,cagente
	                INTO vcramo, vcmodali, vctipseg, vccolect,
	              vcagente, v_ccobban, w_producto, w_cuenta,
	              w_ctipban, v_agente
	                FROM seguros s,cobbancario cb
	               WHERE sseguro=psseguro AND
	                     s.ccobban=cb.ccobban;
	          EXCEPTION
	              WHEN no_data_found THEN
	                vtraza:=4;

	                SELECT cbs.cramo,cbs.cmodali,cbs.ctipseg,cbs.ccolect,cbs.cagente,cb.ccobban,NULL,cb.ncuenta,cb.ctipban,cbs.cagente
	                  INTO vcramo, vcmodali, vctipseg, vccolect,
	                vcagente, v_ccobban, w_producto, w_cuenta,
	                w_ctipban, v_agente
	                  FROM cobbancariosel cbs,cobbancario cb
	                 WHERE cbs.cempres=pcempres AND
	                       cbs.cramo IS NULL AND
	                       cbs.cmodali IS NULL AND
	                       cbs.ctipseg IS NULL AND
	                       cbs.ccolect IS NULL AND
	                       cb.ccobban=cbs.ccobban
	                       /*BUG 38089/215886:IPH 15/10/2015*/
	                       AND
	                       cb.cbaja=0
	                       /*-------------------------------------*/
	                       AND
	                       ROWNUM=1;
	          /* BUG11396:DRA:27/01/2010:Inici*/
	          /*v_ccobban := f_buscacobban(vcramo, vcmodali, vctipseg, vccolect, vcagente,
	                                     p_ccc_abono, p_ctipban_abono, vnum_err);
	          vtraza := 5;
	          IF vnum_err <> 0 THEN
	             vtraza := 6;
	             p_tab_error(f_sysdate, f_user, vobjectname, 2,
	                         'Error buscando COBBANCARIOSEL para seguro =' || psseguro
	                         || ' - vtraza ' || vtraza || ' - vnum_err =' || vnum_err,
	                         SQLERRM);
	             RETURN 152055;
	          END IF;*/
	          /* BUG11396:DRA:27/01/2010:Fi*/
	          END;
	    END;

	    vtraza:=6;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, 1, f_axis_literales(102374, f_usu_idioma), SQLERRM);

	             RETURN 152055;
	END f_get_ctacargo_age;

	/***********************************************************************
	  Función que nos inserta en la tabla remesas_previo los registros que estamos buscando.
	  param in  pcempres
	  param in  pcidioma IN NUMBER,
	  param in  psremisesion IN NUMBER,   -- Identificador de la sesion de inserciones de la remesa
	  param in  ptipproceso IN VARCHAR2,   --1- Rentas 2- recibos 3- siniestros 4-Reembolsos
	  param in  pcramo IN NUMBER,
	  param in  psproduc IN NUMBER,
	  param in  pfabono IN DATE,
	  param in  pftransini IN DATE,
	  param in  pftransfin IN DATE,
	  param in  pctransferidos IN NUMBER,
	  param in  pprestacion IN NUMBER DEFAULT 0,
	  param in  pagrup IN NUMBER DEFAULT NULL,   --Agrupación
	  param in  pcausasin IN NUMBER DEFAULT NULL   --En el caso de siniestros, la causa del siniestro
	  return             : 0 OK , 1 error
	***********************************************************************/
	FUNCTION f_insert_remesas_previo(/*ozea*/
			pcempres	IN	NUMBER,
	pcidioma	IN	NUMBER,
	pagrupacion	IN	NUMBER,
	pcramo	IN	NUMBER,
	psproduc	IN	NUMBER,
	pfabonoini	IN	DATE,
	pfabonofin	IN	DATE,
	pftransini	IN	DATE,
	pftransfin	IN	DATE,
	pctransferidos	IN	NUMBER,
			/*Nos indica que el usuario quiere recuperar los registros que tenia ya previamente seleccionados.*/
			pnremesa	IN	NUMBER,
	ptipproceso	IN	VARCHAR2,
			/*1- Rentas 2- recibos 3- siniestros 4-Reembolsos*/
			piimportt	IN	NUMBER,
	psperson	IN	NUMBER,
	pprocesolin	OUT	NUMBER
	)
	/*
	  pctransferidos  0  No transferidos
	                  1 Transferidos
	                  2 Generación fichero.  obligatorio el parametro pnremesa
	*/
	RETURN NUMBER
	IS
	  param              VARCHAR2(1000):='param pcempres : '
	                        || pcempres
	                        || ', pcidioma : '
	                        || pcidioma
	                        || ' , psproduc : '
	                        || psproduc
	                        || ',ptipproceso : '
	                        || ptipproceso
	                        || ' , pagrup : '
	                        || pagrupacion
	                        || ' pnremesa : '
	                        || pnremesa
	                        || ', piimportt : '
	                        || piimportt
	                        || ', psperson : '
	                        || psperson;

	  /*pwhere         VARCHAR2(3000);*/
	  /*
	    {CURSOR RENTAS }
	  */
	  CURSOR c_rentas IS
	    SELECT /*+ CHOSSE */ pagosrenta.sseguro,pagosrenta.sperson,pagosrenta.srecren,pagosrenta.nctacor,pagosrenta.ffecpag,seguros.cempres,pagosrenta.isinret-pagosrenta.iretenc vimport,nvl(pagosrenta.ctipban, 1) ctipban
	      FROM pagosrenta,seguros
	     WHERE pagosrenta.fremesa IS NULL AND
	           f_istipobusqueda(ptipproceso, 2)=1
	           /*- añadimos el filtro por agrupación*/
	           AND
	           seguros.sseguro=pagosrenta.sseguro AND
	           ((pagrupacion IS NULL)  OR
	            (seguros.cagrpro=pagrupacion AND
	             pagrupacion IS NOT NULL)) AND
	           ((pcramo IS NULL)  OR
	            (seguros.cramo=pcramo AND
	             pcramo IS NOT NULL)) AND
	           ((psproduc IS NULL)  OR
	            (seguros.sproduc=psproduc AND
	             psproduc IS NOT NULL)) AND
	           ((psperson IS NULL)  OR
	            (EXISTS(SELECT '1'
	                      FROM asegurados a
	                     WHERE a.sseguro=seguros.sseguro AND
	                           a.sperson=psperson
	                    UNION
	                    SELECT '1'
	                      FROM tomadores t
	                     WHERE t.sseguro=seguros.sseguro AND
	                           t.sperson=psperson) AND
	             psperson IS NOT NULL)) AND
	           seguros.cempres=pcempres /* Parametro obligatorio*/
	           AND
	           pagosrenta.srecren IN(SELECT movpagren.srecren
	                                   FROM movpagren
	                                  WHERE movpagren.cestrec=0 AND
	                                        movpagren.fmovfin IS NULL AND
	                                        to_char(movpagren.fmovini, 'YYYYMMDD')<=to_char(add_months(f_sysdate, 1), 'YYYYMMDD'));

	  CURSOR c_rentas2 IS
	    SELECT ccc,r.ctipban,nrecibo,nsinies,sidepag,nrentas,cabono,iimport,ctipban_abono,r.sseguro,catribu,r.sproduc,fabono,nremesa,ftransf,r.cempres,sperson,r.ccobban,1,r.nreemb,r.nfact,r.nlinea,r.ctipo,pctransferidos,r.cestado,r.csubestado,r.descripcion,r.cmoneda,r.fcambio,r.sremesa,r.spago
	      FROM remesas r,seguros s
	     WHERE s.sseguro(+)=r.sseguro AND
	           r.cempres=pcempres AND
	           (r.nremesa=pnremesa  OR
	            pnremesa IS NULL) AND
	           (r.sproduc=psproduc /* BUG12913:DRA:08/02/2010*/
	             OR
	            psproduc IS NULL) AND
	           (s.cramo=pcramo /* BUG12913:DRA:08/02/2010*/
	             OR
	            pcramo IS NULL) AND
	           (s.cagrpro=pagrupacion
	             /* BUG12913:DRA:08/02/2010*/
	             OR
	            pagrupacion IS NULL) AND
	           (pctransferidos IS NOT NULL AND
	            ftransf IS NOT NULL  OR
	            pctransferidos IS NULL) AND
	           ((pftransini IS NOT NULL AND
	             ftransf>=pftransini)  OR
	            pftransini IS NULL) AND
	           ((pftransfin IS NOT NULL AND
	             ftransf<=pftransfin)  OR
	            pftransfin IS NULL) AND
	           ((pfabonoini IS NOT NULL AND
	             fabono>=pfabonoini)  OR
	            pfabonoini IS NULL) AND
	           ((psperson IS NOT NULL AND
	             sperson=psperson)  OR
	            psperson IS NULL) AND
	           ((piimportt IS NOT NULL AND
	             nremesa IN(SELECT nremesa
	                          FROM remesas
	                         GROUP BY nremesa
	                        HAVING SUM(iimport)=piimportt))  OR
	            piimportt IS NULL) AND
	           ((pfabonofin IS NOT NULL AND
	             fabono<=pfabonofin)  OR
	            pfabonofin IS NULL);

	  /*
	    {CURSOR RECIBOS }
	  */
	CURSOR c_recibos(

	    pcempres IN NUMBER) IS
	    SELECT recibos.nrecibo,seguros.sseguro,recibos.cbancar,recibos.ctipban,seguros.cempres,6 catribu
	      FROM recibos,seguros,cobbancario
	     WHERE recibos.cestimp=7 /* pte. de transferir*/
	           AND
	           recibos.ctipcob=2 /* Bug 0038162 - JMF - 15/10/2015*/
	           AND
	           recibos.cempres=nvl(pcempres, f_parinstalacion_n('EMPRESADEF')) AND
	           recibos.ctiprec IN(9, 13) /* extorno, retorno retorno (bug 0019791)*/
	           AND
	           recibos.ccobban=cobbancario.ccobban
	           /*AGG modificaciones SEPA*/
	           AND
	           (((nvl(pac_parametros.f_parempresa_n(pcempres, 'TRANSF_IBAN_XML'), 0)=1)
	             /*  AND(cobbancario.ctipban = 2)*/
	             /*#35847#.1*/
	             /*AND(pac_sepa.f_mandato_activo(seguros.sseguro, recibos.nrecibo) = 1)*/
	             AND
	             EXISTS(SELECT 1
	                      FROM tipos_cuenta t,bancos b,recibos r
	                     WHERE b.cbic IS NOT NULL AND
	                           t.ctipban=r.ctipban AND
	                           b.cbanco=substr(r.cbancar, nvl(t.pos_entidad, 1), nvl(t.long_entidad, 4)))/* parametro obligatorio*/
	            )  OR
	            (nvl(pac_parametros.f_parempresa_n(pcempres, 'TRANSF_IBAN_XML'), 0)=0))
	           /*fin modificaciones SEPA*/
	           AND
	           EXISTS(SELECT ctaseguro.nrecibo
	                    FROM ctaseguro
	                   WHERE ctaseguro.nrecibo=recibos.nrecibo)
	           /*-  añadimos el filtro por agrupación*/
	           AND
	           seguros.sseguro=recibos.sseguro AND
	           f_istipobusqueda(ptipproceso, 6)=1 AND
	           ((pagrupacion IS NULL)  OR
	            (seguros.cagrpro=pagrupacion AND
	             pagrupacion IS NOT NULL)) AND
	           ((pcramo IS NULL)  OR
	            (seguros.cramo=pcramo AND
	             pcramo IS NOT NULL)) AND
	           ((psperson IS NULL)  OR
	            (EXISTS(SELECT '1'
	                      FROM asegurados a
	                     WHERE a.sseguro=seguros.sseguro AND
	                           a.sperson=psperson
	                    UNION
	                    SELECT '1'
	                      FROM tomadores t
	                     WHERE t.sseguro=seguros.sseguro AND
	                           t.sperson=psperson) AND
	             psperson IS NOT NULL)) AND
	           ((psproduc IS NULL)  OR
	            (seguros.sproduc=psproduc AND
	             psproduc IS NOT NULL)) AND
	           seguros.cempres=pcempres /* parametro obligatorio*/
	    UNION
	    SELECT r.nrecibo,seguros.sseguro,r.cbancar,r.ctipban,seguros.cempres,5 catribu /* extornos*/
	      FROM recibos r,movrecibo m,seguros,cobbancario c
	     WHERE r.nrecibo=m.nrecibo AND
	           r.ctipcob=2 /* Bug 0038162 - JMF - 15/10/2015*/
	           AND
	           r.ccobban=c.ccobban
	           /*   AND c.ctipban = 2   --La cuenta debe ser de tipo IBAN*/
	           AND
	           r.cestimp=7 /* pdte. de transferir*/
	           AND
	           r.cempres=nvl(pcempres, f_parinstalacion_n('EMPRESADEF')) AND
	           r.ctiprec IN(9, 13) /* extorno, retorno retorno (bug 0019791)*/
	           AND
	           m.cestrec=0 /* pendiente*/
	           AND
	           r.fefecto<=trunc(f_sysdate) AND
	           m.fmovfin IS NULL AND
	           f_istipobusqueda(ptipproceso, 5)=1
	           /*AGG modificaciones SEPA*/
	           AND
	           (((nvl(pac_parametros.f_parempresa_n(pcempres, 'TRANSF_IBAN_XML'), 0)=1)
	             /*    AND(c.ctipban = 2)*/
	             /*#35847#.2*/
	             /*AND(pac_sepa.f_mandato_activo(seguros.sseguro, r.nrecibo) = 1)*/
	             AND
	             EXISTS(SELECT 1
	                      FROM tipos_cuenta t,bancos b,recibos r
	                     WHERE b.cbic IS NOT NULL AND
	                           t.ctipban=r.ctipban AND
	                           b.cbanco=substr(r.cbancar, nvl(t.pos_entidad, 1), nvl(t.long_entidad, 4)))/* parametro obligatorio*/
	            )  OR
	            (nvl(pac_parametros.f_parempresa_n(pcempres, 'TRANSF_IBAN_XML'), 0)=0))
	           /*fin modificaciones SEPA*/
	           /*-  añadimos el filtro por agrupación*/
	           AND
	           seguros.sseguro=r.sseguro AND
	           ((pagrupacion IS NULL)  OR
	            (seguros.cagrpro=pagrupacion AND
	             pagrupacion IS NOT NULL)) AND
	           ((pcramo IS NULL)  OR
	            (seguros.cramo=pcramo AND
	             pcramo IS NOT NULL)) AND
	           ((psproduc IS NULL)  OR
	            (seguros.sproduc=psproduc AND
	             psproduc IS NOT NULL)) AND
	           ((psperson IS NULL)  OR
	            (EXISTS(SELECT '1'
	                      FROM asegurados a
	                     WHERE a.sseguro=seguros.sseguro AND
	                           a.sperson=psperson
	                    UNION
	                    SELECT '1'
	                      FROM tomadores t
	                     WHERE t.sseguro=seguros.sseguro AND
	                           t.sperson=psperson) AND
	             psperson IS NOT NULL)) AND
	           seguros.cempres=pcempres;

	  /*AGG Modificaciones SEPA*/
	  /*Comprobamos que esté informado el código BIC*/
	  /*- añadimos el filtro por pagos de prestaciones*/
	  /*
	    {CURSOR SINIESTROS }
	    MODULO ANTIGUO
	  -- Bug 28328 - 04-X-2013 - dlF - Error al crear una tansferencia en PROD
	  -- hay que sumar el importe del IVA.
	  -- fin Bug 28328 - 04-X-2013 - dlF
	  */-- Pagos Pendientes sin transferir de domiciliación bancario y transferencia
	  CURSOR c_pagos_ant IS
	    SELECT /*+ CHOOSE */ pagosini.ROWID,pagosini.nsinies,pagosini.isinret,c.catribu,pagosini.iretenc,pagosini.sidepag,siniestros.sseguro,pagosini.fordpag,siniestros.ccausin,seguros.cempres,pagosini.iimpiva /*Bug 28328 - 04-X-2013 - dlF*/
	      FROM pagosini,siniestros,codicausin c,seguros
	     WHERE pagosini.nsinies=siniestros.nsinies AND
	           siniestros.ccausin=c.ccausin AND
	           seguros.sseguro=siniestros.sseguro AND
	           pagosini.cestpag=1 AND
	           (pagosini.ctransf=1  OR
	            pagosini.ctransf IS NULL) AND
	           pagosini.ctippag=2 AND
	           f_istipobusqueda(ptipproceso, c.catribu)=1
	           /* Estaba en la pantalla de sa nostra*/
	           AND
	           pagosini.sidepag NOT IN(SELECT nvl(pp.spganul, 0)
	                                     FROM pagosini pp
	                                    WHERE pp.nsinies=pagosini.nsinies AND
	                                          pp.cestpag<>8)
	           /* Estaba en la pantalla de sa nostra*/
	           AND
	           pagosini.cforpag=2
	           /*- añadimos el filtro por agrupación*/
	           AND
	           ((pagrupacion IS NULL)  OR
	            (seguros.cagrpro=pagrupacion AND
	             pagrupacion IS NOT NULL)) AND
	           ((pcramo IS NULL)  OR
	            (seguros.cramo=pcramo AND
	             pcramo IS NOT NULL)) AND
	           ((psproduc IS NULL)  OR
	            (seguros.sproduc=psproduc AND
	             psproduc IS NOT NULL)) AND
	           ((psperson IS NULL)  OR
	            (EXISTS(SELECT '1'
	                      FROM asegurados a
	                     WHERE a.sseguro=seguros.sseguro AND
	                           a.sperson=psperson
	                    UNION
	                    SELECT '1'
	                      FROM tomadores t
	                     WHERE t.sseguro=seguros.sseguro AND
	                           t.sperson=psperson) AND
	             psperson IS NOT NULL)) AND
	           seguros.cempres=pcempres;

	  /*  {CURSOR SINIESTROS } svj. modelo nuevo de siniestros.
	    MODULO NUEVO.
	  */-- Pagos Pendientes sin transferir de domiciliación bancario y transferencia*/

	  /* Bug 28328 - 25-IX-2013 - dlF - Error al crear una tansferencia en PROD*/
	  /* eliminamos la tabla sin_tramita_reserva de la query*/
	  /* fin Bug 28328 - 25-IX-2013 - dlF*/
	  /* Bug 28328 - 04-X-2013 - dlF - Error al crear una tansferencia en PROD*/
	  /* hay que sumar el importe del IVA.*/
	  /* fin Bug 28328 - 04-X-2013 - dlF*/
	  CURSOR c_pagos IS
	    SELECT /*+ CHOOSE */ p.ROWID,p.nsinies,p.isinret,c.catribu,p.iretenc,p.sidepag,s.sseguro,p.fordpag,s.ccausin,seg.cempres,p.iiva /* Bug 28328 - 04-X-2013 - dlF*/
	      FROM sin_tramita_pago p,sin_siniestro s,sin_codcausa c,seguros seg
	     WHERE p.nsinies=s.nsinies AND
	           s.ccausin=c.ccausin AND
	           seg.sseguro=s.sseguro AND
	           p.sidepag IN(SELECT m.sidepag
	                          FROM sin_tramita_movpago m
	                         WHERE m.cestpag=1 AND
	                               m.sidepag=p.sidepag AND
	                               m.nmovpag IN(SELECT max(mm.nmovpag)
	                                              FROM sin_tramita_movpago mm
	                                             WHERE mm.sidepag=m.sidepag)) AND
	           (p.ctransfer=1  OR
	            p.ctransfer IS NULL) AND
	           p.ctippag=2 AND
	           f_istipobusqueda(ptipproceso, c.catribu)=1 AND
	           p.cforpag=1
	           /* Por transferencia 1:transferencia , 5:metalico*/
	           AND
	           ((pagrupacion IS NULL)  OR
	            (seg.cagrpro=pagrupacion AND
	             pagrupacion IS NOT NULL)) AND
	           ((pcramo IS NULL)  OR
	            (seg.cramo=pcramo AND
	             pcramo IS NOT NULL)) AND
	           ((psproduc IS NULL)  OR
	            (seg.sproduc=psproduc AND
	             psproduc IS NOT NULL)) AND
	           ((psperson IS NULL)  OR
	            (EXISTS(SELECT '1'
	                      FROM asegurados a
	                     WHERE a.sseguro=seg.sseguro AND
	                           a.sperson=psperson
	                    UNION
	                    SELECT '1'
	                      FROM tomadores t
	                     WHERE t.sseguro=seg.sseguro AND
	                           t.sperson=psperson) AND
	             psperson IS NOT NULL)) AND
	           seg.cempres=pcempres;

	  /*
	    {CURSOR REEMBOLSOS }
	  */-- Pagos Pendientes sin transferir de domiciliación bancario y transferencia
	  CURSOR c_reembolsos IS
	    SELECT 11 AS tipo_transfer,r.sseguro,r.cbancar,r.ctipban,raf.nreemb,sperson,raf.nfact,raf.nlinea,ipago importe,1 ctipo,s.cempres
	      FROM reembolsos r,reembfact rf,reembactosfac raf,seguros s
	     WHERE r.nreemb=rf.nreemb AND
	           r.sseguro=s.sseguro AND
	           rf.nreemb=raf.nreemb AND
	           rf.nfact=raf.nfact AND
	           f_istipobusqueda(ptipproceso, 11)=1 AND
	           rf.fbaja IS NULL AND
	           raf.fbaja IS NULL AND
	           raf.ftrans IS NULL AND
	           raf.cerror=0 /* BUG10604:DRA:01/07/2009*/
	           AND
	           nvl(raf.ipago, 0)>0 /*BUG 11102 - 10/09/2009 - JRB*/
	           AND
	           r.cestado NOT IN(0, 4, 5)
	           /* 0 = Gestion oficinas, 4 = Anulado, 5 = Rechazado*/
	           /* BUG11396:DRA:12/01/2010:Inici: añadimos el filtro por agrupación*/
	           AND
	           ((pagrupacion IS NULL)  OR
	            (s.cagrpro=pagrupacion AND
	             pagrupacion IS NOT NULL)) AND
	           ((pcramo IS NULL)  OR
	            (s.cramo=pcramo AND
	             pcramo IS NOT NULL)) AND
	           ((psproduc IS NULL)  OR
	            (s.sproduc=psproduc AND
	             psproduc IS NOT NULL)) AND
	           ((psperson IS NULL)  OR
	            (EXISTS(SELECT '1'
	                      FROM asegurados a
	                     WHERE a.sseguro=s.sseguro AND
	                           a.sperson=psperson
	                    UNION
	                    SELECT '1'
	                      FROM tomadores t
	                     WHERE t.sseguro=s.sseguro AND
	                           t.sperson=psperson) AND
	             psperson IS NOT NULL)) AND
	           s.cempres=pcempres /* Parametro obligatorio*/
	    /* BUG11396:DRA:12/01/2010:Fi*/
	    UNION ALL
	    SELECT 11 AS tipo_transfer,r.sseguro,r.cbancar,r.ctipban,raf.nreemb,sperson,raf.nfact,raf.nlinea,ipagocomp importe,2 ctipo,s.cempres
	      FROM reembolsos r,reembfact rf,reembactosfac raf,seguros s
	     WHERE r.nreemb=rf.nreemb AND
	           rf.nreemb=raf.nreemb AND
	           r.sseguro=s.sseguro AND
	           rf.nfact=raf.nfact AND
	           f_istipobusqueda(ptipproceso, 11)=1 AND
	           rf.fbaja IS NULL AND
	           raf.fbaja IS NULL AND
	           raf.ftranscomp IS NULL AND
	           nvl(raf.ipagocomp, 0)>0 /* BUG 11102 - 10/09/2009 - JRB*/
	           AND
	           raf.cerror=0 /* BUG10604:DRA:01/07/2009*/
	           AND
	           r.cestado NOT IN(0, 4, 5)
	           /* BUG11396:DRA:12/01/2010:Inici: añadimos el filtro por agrupación*/
	           AND
	           ((pagrupacion IS NULL)  OR
	            (s.cagrpro=pagrupacion AND
	             pagrupacion IS NOT NULL)) AND
	           ((pcramo IS NULL)  OR
	            (s.cramo=pcramo AND
	             pcramo IS NOT NULL)) AND
	           ((psproduc IS NULL)  OR
	            (s.sproduc=psproduc AND
	             psproduc IS NOT NULL)) AND
	           ((psperson IS NULL)  OR
	            (EXISTS(SELECT '1'
	                      FROM asegurados a
	                     WHERE a.sseguro=s.sseguro AND
	                           a.sperson=psperson
	                    UNION
	                    SELECT '1'
	                      FROM tomadores t
	                     WHERE t.sseguro=s.sseguro AND
	                           t.sperson=psperson) AND
	             psperson IS NOT NULL)) AND
	           s.cempres=pcempres;

	  /* BUG11396:DRA:12/01/2010:Fi*/
	  /* BUG14344:DRA:04/05/2010:Inici*/
	  /*
	    {CURSOR PAGOSCOMISIONES }
	  */-- Pagos Pendientes sin transferir de domiciliación bancario y transferencia
	  CURSOR c_pagoscomisiones IS
	    SELECT 12 AS tipo_transfer,pc.spago,pc.cempres,pc.cagente,pc.iimporte,pc.cestado,pc.fliquida,pc.cusuario,pc.falta,pc.cforpag,pc.ctipopag,pc.nremesa,pc.ftrans,pc.nnumlin,pc.ctipban,pc.cbancar
	      FROM pagoscomisiones pc
	     WHERE pc.cempres=pcempres AND
	           pc.cestado=0 AND
	           pc.ftrans IS NULL AND
	           pc.cbancar IS NOT NULL /* Bug 0032079 - JMF - 15/07/2014*/
	           AND
	           f_istipobusqueda(ptipproceso, 12)=1;

	  /* BUG14344:DRA:04/05/2010:Fi*/
	  /* BUG 19238 - JMC - 09/12/2011*/
	  /*
	     {CURSOR PRÉSTAMOS}
	  */
	  CURSOR c_prestamopagos IS
	    SELECT 13 AS tipo_transfer,s.cempres,p.ctipban,p.cbancar,pp.icapital iimporte,p.ctapres
	      FROM prestamos p,prestamoseg ps,prestamopago pp,seguros s
	     WHERE ps.ctapres=p.ctapres AND
	           ps.falta=p.falta AND
	           pp.ctapres=p.ctapres AND
	           pp.falta=p.falta AND
	           s.sseguro=ps.sseguro AND
	           p.cestado=1 AND
	           p.cforpag=1 /*Transferencia bancaria*/
	           AND
	           f_istipobusqueda(ptipproceso, 13)=1 AND
	           pp.fefecto BETWEEN pfabonoini AND pfabonofin AND
	           pp.fremesa IS NULL;

	  /* Fin BUG 19238 - JMC - 09/12/2011*/
	  /*ini bug 33427/191636:NSS:12/11/2014*/
	  CURSOR c_pagosctatecrea IS
	    SELECT 14 AS tipo_transfer,pcr.spagrea,pcr.cempres,pcr.iimporte,pcr.cestado,pcr.fliquida,pcr.cusuario,pcr.falta,pcr.cforpag,pcr.ctipopag,pcr.nremesa,pcr.ftrans,pcr.ctipban,pcr.cbancar
	      FROM pagos_ctatec_rea pcr
	     WHERE pcr.cempres=pcempres AND
	           pcr.cestado=0 /*pendiente*/
	           AND
	           pcr.cbancar IS NOT NULL AND
	           pcr.cforpag=2 /* transferencia*/
	           AND
	           f_istipobusqueda(ptipproceso, 14)=1;

	  CURSOR c_pagosctateccoa IS
	    SELECT 15 AS tipo_transfer,pcc.spagcoa,pcc.cempres,pcc.iimporte,pcc.cestado,pcc.fliquida,pcc.cusuario,pcc.falta,pcc.cforpag,pcc.ctipopag,pcc.nremesa,pcc.ftrans,pcc.ctipban,pcc.cbancar
	      FROM pagos_ctatec_coa pcc
	     WHERE pcc.cempres=pcempres AND
	           pcc.cestado=0 /*pendiente*/
	           AND
	           pcc.cbancar IS NOT NULL AND
	           pcc.cforpag=2 /* transferencia*/
	           AND
	           f_istipobusqueda(ptipproceso, 15)=1;

	  /* Bug 33886/202377 Se crea cursor para el manejo de pagos cuenta cliente*/
	  /* Bug 33886/215876. Se agrega sseguro al select de este cursor*/
	  CURSOR c_pagoctacliente IS
	    SELECT 16 AS tipo_transfer,pce.spago,pce.cempres,pce.sperson,pce.iimporte,pce.cestado,pce.fliquida,pce.cusuario,pce.falta,pce.cforpag,pce.ctipopag,pce.nremesa,pce.ftrans,pce.nnumlin,pce.ctipban,pce.cbancar,pce.sseguro
	      FROM pagoctacliente pce
	     WHERE pce.cempres=pcempres AND
	           pce.cestado=0 AND
	           pce.ftrans IS NULL AND
	           pce.cbancar IS NOT NULL AND
	           f_istipobusqueda(ptipproceso, 16)=1;

	  /*fin bug 33427/191636:NSS:12/11/2014*/
	  w_control          NUMBER;
	  w_salida           seguros.cbancar%TYPE; /*  21-10-2011 JGR 0018944*/
	  w_ttexto           VARCHAR2(80);
	  w_cerror           NUMBER;
	  w_error            NUMBER;
	  w_sproces          NUMBER;
	  num_err            NUMBER;
	  w_secuencia        remesas_previo.sremesa%TYPE; /* NUMBER;        */
	  w_producto         NUMBER;
	  w_fecha            DATE;
	  w_import           NUMBER;
	  w_scuecar          seguros.cbancar%TYPE; /*  21-10-2011 JGR 0018944*/
	  w_cabono           seguros.cbancar%TYPE; /*  21-10-2011 JGR 0018944*/
	  w_ctipban          seguros.ctipban%TYPE; /*  21-10-2011 JGR 0018944*/
	  w_ctipban_abono    seguros.ctipban%TYPE; /*  21-10-2011 JGR 0018944*/
	  v_sperson          NUMBER;
	  v_ccobban          seguros.ccobban%TYPE; /* BUG9693:DRA:19/05/2009*/
	  v_duplicats        NUMBER:=0;
	  v_islisrest        NUMBER:=0;
	  v_agente           NUMBER;
	  w_secuencia_remesa NUMBER;
	  v_exis_resgistro   NUMBER:=0;
	  v_clisres          NUMBER:=0;
	  v_traza            NUMBER:=0;
	BEGIN
	    /********************************************************************
	        COMENÇO AMB LA SELECCIÓ DE TOTES LES TRANSFERÈNCIES PENDENTS
	    ********************************************************************/
	    w_cerror:=0;

	    BEGIN
	        w_fecha:=f_sysdate;

	        /* Cada vez que realizamos una selección grabamos en procesos para poder revisar si ha habído algún errro.*/
	        num_err:=f_procesini(f_user, pcempres, 'TRANSFERENCIAS', 'Selección de transferencias', w_sproces);

	        /********************************************************************
	                                    RENTAS
	         ********************************************************************/
	        v_traza:=1;

	        IF nvl(pctransferidos, 0) IN(1, 2) THEN /* Transferidos o generación de fichero (n.remesa)*/
	          /* BUG 36723*/
	          v_traza:=2;

	          FOR reg2 IN c_rentas2 LOOP
	              BEGIN
	                  SELECT ag.cagente
	                    INTO v_agente /* validamos si el agente existe en una lista restringida*/
	                    FROM lre_personas lre,agentes ag
	                   WHERE lre.sperson=ag.sperson AND
	                         lre.cclalis=2 AND
	                         lre.ctiplis=48 AND
	                         lre.finclus<f_sysdate AND
	                         lre.sperson=v_sperson;
	              EXCEPTION
	                  WHEN no_data_found THEN
	                    v_agente:=0;
	              END;

	              IF (v_agente>0) THEN /* si esta en lista restringida inserta en remesas_previo_lre, y si*/
	                SELECT count(sclave)
	                  INTO v_exis_resgistro
	                  FROM remesas_previo_lre rpl
	                 WHERE cabono=reg2.cabono AND
	                       iimport=reg2.iimport AND
	                       fabono=reg2.fabono AND
	                       cempres=reg2.cempres AND
	                       nrecibo=reg2.nrecibo AND
	                       nsinies=reg2.nsinies AND
	                       sidepag=reg2.sidepag;

	                v_traza:=25;

	                IF (v_exis_resgistro<=0) THEN /* si no existe previo el registrp se inserta*/
	                  v_traza:=26;

	                  SELECT sremesa_previo_lre.NEXTVAL
	                    INTO w_secuencia_remesa
	                    FROM dual;

	                  BEGIN
	                      v_traza:=27;

			INSERT INTO remesas_previo_lre
		           (sclave,cempres,cabono,iimport,fabono,nrecibo,
		           nsinies,sidepag,nrentas,sseguro,nreemb,
		           nfact,spago,ctapres,cagente,clisres,
		           flisres,ulisres)
		    VALUES
		           (w_secuencia_remesa,reg2.cempres,reg2.cabono,reg2.iimport,reg2.fabono,reg2.nrecibo,
		           reg2.nsinies,reg2.sidepag,reg2.nrentas,reg2.sseguro,reg2.nreemb,
		           reg2.nfact,reg2.spago,NULL,v_agente,1,
		           f_sysdate,f_user);

	                  EXCEPTION
	                      WHEN dup_val_on_index THEN /* BUG11396:DRA:20/01/2010*/
	                        w_ttexto:=f_axis_literales(9908574, pcidioma);

	                        p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 01, f_axis_literales(9001843, pcidioma)
	                                                                                                         || '. '
	                                                                                                         || f_axis_literales(9001850, pcidioma)
	                                                                                                         || '. '
	                                                                                                         || w_ttexto, SQLERRM);

	                        w_error:=f_proceslin(w_sproces, substr(f_axis_literales(9001843, pcidioma)
	                                                               || '. '
	                                                               || f_axis_literales(9001850, pcidioma)
	                                                               || '. '
	                                                               || SQLERRM, 1, 120), NULL, w_cerror);

	                        v_duplicats:=1;
	                      WHEN OTHERS THEN
	                        w_ttexto:=f_axis_literales(9908574, pcidioma);

	                        p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 02, f_axis_literales(9001843, pcidioma)
	                                                                                                         || '. '
	                                                                                                         || f_axis_literales(9001850, pcidioma)
	                                                                                                         || '. '
	                                                                                                         || w_ttexto, SQLERRM);

	                        w_error:=f_proceslin(w_sproces, substr(w_ttexto
	                                                               || '. Error ='
	                                                               || SQLERRM, 1, 120), NULL, w_cerror);
	                  END;
	                END IF;

	                v_islisrest:=0;
	              ELSE
	                v_traza:=28;

	                BEGIN
	                    SELECT nvl(clisres, 0)
	                      INTO v_clisres
	                      FROM remesas_previo_lre rpl
	                     WHERE cabono=reg2.cabono AND
	                           iimport=reg2.iimport AND
	                           fabono=reg2.fabono AND
	                           cempres=reg2.cempres AND
	                           nrecibo=reg2.nrecibo AND
	                           nsinies=reg2.nsinies AND
	                           sidepag=reg2.sidepag;
	                EXCEPTION
	                    WHEN OTHERS THEN
	                      v_clisres:=0;
	                END;

	                IF (v_clisres<>2) THEN /* se valida que la transferencia no este cancelada*/
	                  v_clisres:=0;

	                  v_traza:=29;

	                  BEGIN
			INSERT INTO remesas_previo
		           (sremesa,ccc,ctipban,nrecibo,nsinies,sidepag,
		           nrentas,cabono,iimport,ctipban_abono,sseguro,
		           catribu,sproduc,fabono,nremesa,ftransf,
		           cempres,sperson,ccobban,cmarcado,nreemb,
		           nfact,nlinea,ctipo,ctipoproceso,cestado,
		           csubestado,descripcion,cmoneda,fcambio,sremesa_orig,
		           spago)
		    VALUES
		           (sremesa_previo.NEXTVAL,reg2.ccc,reg2.ctipban,reg2.nrecibo,reg2.nsinies,reg2.sidepag,
		           reg2.nrentas,reg2.cabono,reg2.iimport,reg2.ctipban_abono,reg2.sseguro,
		           reg2.catribu,reg2.sproduc,reg2.fabono,reg2.nremesa,reg2.ftransf,
		           reg2.cempres,reg2.sperson,reg2.ccobban,1,reg2.nreemb,
		           reg2.nfact,reg2.nlinea,reg2.ctipo,reg2.pctransferidos,reg2.cestado,
		           reg2.csubestado,reg2.descripcion,reg2.cmoneda,reg2.fcambio,reg2.sremesa,
		           reg2.spago);


	                      v_traza:=30;
	                  EXCEPTION
	                      WHEN dup_val_on_index THEN /* BUG11396:DRA:20/01/2010*/
	                        w_ttexto:=f_axis_literales(9002226, pcidioma);

	                        p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 10, f_axis_literales(9001843, pcidioma)
	                                                                                                         || '. '
	                                                                                                         || f_axis_literales(9001850, pcidioma)
	                                                                                                         || '. '
	                                                                                                         || w_ttexto, SQLERRM);

	                        w_error:=f_proceslin(w_sproces, substr(f_axis_literales(9001843, pcidioma)
	                                                               || '. '
	                                                               || f_axis_literales(9001850, pcidioma)
	                                                               || '. '
	                                                               || SQLERRM, 1, 120), NULL, w_cerror);

	                        v_duplicats:=1;
	                      WHEN OTHERS THEN
	                        w_ttexto:=f_axis_literales(9002224, pcidioma);

	                        p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 11, f_axis_literales(9001843, pcidioma)
	                                                                                                         || '. '
	                                                                                                         || f_axis_literales(9001850, pcidioma)
	                                                                                                         || '. '
	                                                                                                         || w_ttexto, SQLERRM);

	                        w_error:=f_proceslin(w_sproces, substr(w_ttexto
	                                                               || '. Error ='
	                                                               || SQLERRM, 1, 120), NULL, w_cerror);
	                  END;
	                END IF;

	                v_islisrest:=0;
	              END IF;
	          END LOOP;
	        ELSE
	          v_traza:=3;

	          FOR reg IN c_rentas LOOP
	              num_err:=0;

	              /*Seleccionem el codi del producte i el codi de la compte corrent*/
	              num_err:=f_get_ctacargo(reg.cempres, reg.sseguro, 2, reg.nctacor, reg.ctipban, /* BUG11396:DRA:14/01/2010*/
	                       w_producto, w_scuecar, w_ctipban, v_ccobban);

	              IF num_err<>0 THEN
	                w_ttexto:=f_axis_literales(9002225, pcidioma);

	                w_error:=f_proceslin(w_sproces, f_axis_literales(109005, pcidioma)
	                                                || '. '
	                                                || w_ttexto, reg.sseguro, w_cerror);
	              END IF;

	              /* El cabono es reg.nctacor*/
	              /* El catribu es catribu = 2 per que són rentas ordre de priotitat*/
	              IF num_err=0 AND
	                 reg.vimport>0 THEN
	              /* BUG 36723*/
	              BEGIN
	                    SELECT ag.cagente
	                      INTO v_agente /* validamos si el agente existe en una lista restringida*/
	                      FROM lre_personas lre,agentes ag
	                     WHERE lre.sperson=ag.sperson AND
	                           lre.cclalis=2 AND
	                           lre.ctiplis=48 AND
	                           lre.finclus<f_sysdate AND
	                           lre.sperson=v_sperson;
	                EXCEPTION
	                    WHEN no_data_found THEN
	                      v_agente:=0;
	                END; IF (v_agente > 0) THEN /* si esta en lista restringida inserta en remesas_previo_lre, y si*/
	              SELECT count(sclave) INTO v_exis_resgistro FROM remesas_previo_lre rpl WHERE cabono = reg.nctacor AND iimport = reg.vimport AND fabono = w_fecha AND cempres = reg.cempres AND nrentas = reg.srecren AND sseguro = reg.sseguro; IF (v_exis_resgistro <= 0) THEN /* si no existe previo el registrp se inserta*/

		    SELECT
		           sremesa_previo_lre.NEXTVAL INTO w_secuencia_remesa
		      FROM
		dual; BEGIN INSERT INTO remesas_previo_lre
		           (sclave, cempres, cabono, iimport, fabono, nrecibo,
		           nsinies, sidepag, nrentas, sseguro, nreemb,
		           nfact, spago, ctapres, cagente, clisres,
		           flisres, ulisres)
		    VALUES
		           (w_secuencia_remesa, reg.cempres, reg.nctacor, reg.vimport, w_fecha, NULL,
		           NULL, NULL, reg.srecren, reg.sseguro, NULL,
		           NULL, NULL, NULL, v_agente, 1,
		           f_sysdate, f_user); EXCEPTION WHEN dup_val_on_index THEN /* BUG11396:DRA:20/01/2010*/

	              w_ttexto := f_axis_literales(9002226, pcidioma); p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 20, f_axis_literales(9001843, pcidioma)|| '. '|| f_axis_literales(109005, pcidioma)|| '. '|| w_ttexto, SQLERRM); w_error := f_proceslin(w_sproces, substr(f_axis_literales(9001843, pcidioma)|| '. '|| f_axis_literales(109005, pcidioma)|| ' -> '|| reg.srecren, 1, 120), reg.sseguro, w_cerror); v_duplicats := 1; WHEN OTHERS THEN w_ttexto := f_axis_literales(9002226, pcidioma); p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 21, f_axis_literales(109005, pcidioma)|| '. '|| w_ttexto, SQLERRM); w_error := f_proceslin(w_sproces, f_axis_literales(109005, pcidioma)|| '. '|| w_ttexto, reg.sseguro, w_cerror); END; END IF; ELSE BEGIN SELECT clisres INTO v_clisres FROM remesas_previo_lre rpl WHERE cabono = reg.nctacor AND iimport = reg.vimport AND fabono = w_fecha AND cempres = reg.cempres AND nrentas = reg.srecren AND sseguro =
	              reg.sseguro;
	              EXCEPTION WHEN OTHERS THEN v_clisres := 0; END; IF (v_clisres <> 2) THEN /* se valida que la transferencia no este cancelada*/
	              BEGIN
	              /*Seleccionem la sequencia per el numero de la remesa*/

		    SELECT
		           sremesa_previo.NEXTVAL INTO w_secuencia
		      FROM
		dual; INSERT INTO remesas_previo
		           (sremesa, ccc, ctipban, nrecibo, nsinies, sidepag,
		           nrentas, cabono, iimport, ctipban_abono, sseguro,
		           catribu, sproduc, fabono, nremesa, ftransf,
		           cempres, sperson, ccobban) /* BUG9693:DRA:19/05/2009*/

	              VALUES (w_secuencia, w_scuecar, w_ctipban, NULL, NULL, NULL, reg.srecren, reg.nctacor, reg.vimport, reg.ctipban, reg.sseguro, 2, w_producto, w_fecha, NULL, NULL, reg.cempres, reg.sperson, v_ccobban);
	              /* BUG9693:DRA:19/05/2009*/
	              EXCEPTION WHEN dup_val_on_index THEN /* BUG11396:DRA:20/01/2010*/
	              w_ttexto := f_axis_literales(9002226, pcidioma); p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 30, f_axis_literales(9001843, pcidioma)|| '. '|| f_axis_literales(109005, pcidioma)|| '. '|| w_ttexto, SQLERRM); w_error := f_proceslin(w_sproces, substr(f_axis_literales(9001843, pcidioma)|| '. '|| f_axis_literales(109005, pcidioma)|| ' -> '|| reg.srecren, 1, 120), reg.sseguro, w_cerror); v_duplicats := 1; WHEN OTHERS THEN w_ttexto := f_axis_literales(9002226, pcidioma); p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 31, f_axis_literales(109005, pcidioma)|| '. '|| w_ttexto, SQLERRM); w_error := f_proceslin(w_sproces, f_axis_literales(109005, pcidioma)|| '. '|| w_ttexto, reg.sseguro, w_cerror); END; END IF; END IF;
	              END IF;
	          END LOOP;

	          /********************************************************************
	                                       RECIBOS
	           ********************************************************************/
	          v_traza:=4;

	          FOR reg IN c_recibos(pcempres) LOOP
	              num_err:=0;

	              /*Seleccionem el codi del producte i el codi de la compte corrent*/
	              num_err:=f_get_ctacargo(reg.cempres, reg.sseguro, reg.catribu, reg.cbancar, reg.ctipban, /* BUG11396:DRA:14/01/2010*/
	                       w_producto, w_scuecar, w_ctipban, v_ccobban);

	              IF num_err<>0 THEN
	                w_ttexto:=f_axis_literales(9002225, pcidioma);

	                w_error:=f_proceslin(w_sproces, f_axis_literales(9000410, pcidioma)
	                                                || '. '
	                                                || w_ttexto, reg.sseguro, w_cerror);
	              END IF;

	              /* Buscamos el importe del recibo*/
	              BEGIN
	                  w_import:=0;

	                  /*Mirem si agafem la moneda del producte o la moneda de cobrament. XPL#03012011#20592*/
	                  IF nvl(pac_parametros.f_parempresa_n(pcempres, 'MONEDA_POL'), 0)=1 THEN
	                    SELECT itotalr
	                      INTO w_import
	                      FROM vdetrecibos_monpol
	                     WHERE nrecibo=reg.nrecibo;
	                  ELSE
	                    SELECT itotalr
	                      INTO w_import
	                      FROM vdetrecibos
	                     WHERE nrecibo=reg.nrecibo;
	                  END IF;
	              EXCEPTION
	                  WHEN OTHERS THEN
	                    num_err:=9002227;

	                    w_ttexto:=f_axis_literales(9002227, pcidioma);

	                    w_error:=f_proceslin(w_sproces, w_ttexto
	                                                    || '. Error ='
	                                                    || SQLERRM, reg.sseguro, w_cerror);
	              END;

	              BEGIN
	                  SELECT sperson
	                    INTO v_sperson
	                    FROM tomadores
	                   WHERE sseguro=reg.sseguro AND
	                         nordtom IN(SELECT min(nordtom)
	                                      FROM tomadores
	                                     WHERE sseguro=reg.sseguro);
	              EXCEPTION
	                  WHEN OTHERS THEN
	                    num_err:=100524;

	                    w_ttexto:=f_axis_literales(100524, pcidioma);

	                    p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 2, w_ttexto, SQLERRM);

	                    w_error:=f_proceslin(w_sproces, w_ttexto, reg.sseguro, w_cerror);
	              END;

	              IF (num_err=0 AND
	                  w_import>0) THEN
	                SELECT sremesa_previo.NEXTVAL
	                  INTO w_secuencia
	                  FROM dual;

	              /*Seleccionem l'import total per rebuts*/
	              /*AQ 0032028: Transferencias - Error en el fichero de transferencias*/
	                /*Miramos si la cuenta es IBAN , y si no tiene que ser IBAN, si es asi modificamos*/
	                IF nvl(pac_parametros.f_parempresa_n(pcempres, 'TRANSF_IBAN_XML'), 0)=0 AND
	                   reg.ctipban=2 THEN
	                  w_cabono:=substr(reg.cbancar, 5);

	                  w_ctipban_abono:=1;
	                ELSE
	                  w_cabono:=reg.cbancar;

	                  w_ctipban_abono:=reg.ctipban; /* BUG-40708 08/03/2016 EDDA Debe ser el tibo de cobrador bancario del recibo.*/
	                END IF;

	              /*FI AQ*/
	                /* BUG 36723*/
	                v_traza:=41;

	                BEGIN
	                    SELECT ag.cagente
	                      INTO v_agente /* validamos si el agente existe en una lista restringida*/
	                      FROM lre_personas lre,agentes ag
	                     WHERE lre.sperson=ag.sperson AND
	                           lre.cclalis=2 AND
	                           lre.ctiplis=48 AND
	                           lre.finclus<f_sysdate AND
	                           lre.sperson=v_sperson;
	                EXCEPTION
	                    WHEN no_data_found THEN
	                      v_agente:=0;
	                END;

	                IF (v_agente>0) THEN /* si esta en lista restringida inserta en remesas_previo_lre, y si*/
	                  v_traza:=43;

	                  SELECT count(sclave)
	                    INTO v_exis_resgistro
	                    FROM remesas_previo_lre rpl
	                   WHERE cabono=w_cabono AND
	                         iimport=w_import AND
	                         fabono=w_fecha AND
	                         cempres=reg.cempres /*ob*/
	                         AND
	                         nrecibo=reg.nrecibo;

	                  IF (v_exis_resgistro<=0) THEN /* si no existe previo el registrp se inserta*/
	                    v_traza:=44;

	                    SELECT sremesa_previo_lre.NEXTVAL
	                      INTO w_secuencia_remesa
	                      FROM dual;

	                    BEGIN
			INSERT INTO remesas_previo_lre
		           (sclave,cempres,cabono,iimport,fabono,nrecibo,
		           nsinies,sidepag,nrentas,sseguro,nreemb,
		           nfact,spago,ctapres,cagente,clisres,
		           flisres,ulisres)
		    VALUES
		           (w_secuencia_remesa,reg.cempres,w_cabono,w_import,w_fecha,NULL,
		           NULL,NULL,NULL,reg.sseguro,NULL,
		           NULL,NULL,NULL,v_agente,1,
		           f_sysdate,f_user);

	                    EXCEPTION
	                        WHEN dup_val_on_index THEN /* BUG11396:DRA:20/01/2010*/
	                          w_ttexto:=f_axis_literales(9908574, pcidioma);

	                          p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 30, f_axis_literales(9001843, pcidioma)
	                                                                                                           || '. '
	                                                                                                           || f_axis_literales(109005, pcidioma)
	                                                                                                           || '. '
	                                                                                                           || w_ttexto, SQLERRM);

	                          w_error:=f_proceslin(w_sproces, substr(f_axis_literales(9001843, pcidioma)
	                                                                 || '. '
	                                                                 || f_axis_literales(109005, pcidioma)
	                                                                 || ' -> '
	                                                                 || reg.nrecibo, 1, 120), reg.sseguro, w_cerror);

	                          v_duplicats:=1;
	                        WHEN OTHERS THEN
	                          w_ttexto:=f_axis_literales(9908574, pcidioma);

	                          p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 31, f_axis_literales(109005, pcidioma)
	                                                                                                           || '. '
	                                                                                                           || w_ttexto, SQLERRM);

	                          w_error:=f_proceslin(w_sproces, f_axis_literales(109005, pcidioma)
	                                                          || '. '
	                                                          || w_ttexto, reg.sseguro, w_cerror);
	                    END;
	                  END IF;
	                ELSE BEGIN
	                      SELECT clisres
	                        INTO v_clisres
	                        FROM remesas_previo_lre rpl
	                       WHERE cabono=w_cabono AND
	                             iimport=w_import AND
	                             fabono=w_fecha AND
	                             cempres=reg.cempres /*ob*/
	                             AND
	                             nrecibo=reg.nrecibo;
	                  EXCEPTION
	                      WHEN OTHERS THEN
	                        v_clisres:=0;
	                  END; IF (v_clisres <> 2) THEN /* se valida que la transferencia no este cancelada*/
	                /*Inserim un rebut*/
			BEGIN INSERT INTO remesas_previo
		           (sremesa, ccc, ctipban, nrecibo, nsinies, sidepag,
		           cabono, iimport, ctipban_abono, sseguro, catribu,
		           sproduc, fabono, nremesa, ftransf, cempres,
		           sperson, ccobban)
		    VALUES
		           (w_secuencia, w_scuecar, w_ctipban, reg.nrecibo, NULL, NULL,
		           w_cabono, w_import, w_ctipban_abono, reg.sseguro, reg.catribu,
		           w_producto, w_fecha, NULL, NULL, reg.cempres,
		           v_sperson, v_ccobban); EXCEPTION WHEN dup_val_on_index THEN /* BUG11396:DRA:20/01/2010*/

	                w_ttexto := f_axis_literales(9002226, pcidioma); p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 32, f_axis_literales(9001843, pcidioma)|| '. '|| f_axis_literales(9000410, pcidioma)|| '. '|| w_ttexto, SQLERRM); w_error := f_proceslin(w_sproces, substr(f_axis_literales(9001843, pcidioma)|| '. '|| f_axis_literales(9000410, pcidioma)|| ' -> '|| reg.nrecibo, 1, 120), reg.sseguro, w_cerror); v_duplicats := 1; WHEN OTHERS THEN
	                /* Bug 0038162 - JMF - 15/10/2015*/
	                w_ttexto := f_axis_literales(9002226, pcidioma)|| ' '|| reg.nrecibo; p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 33, f_axis_literales(9000410, pcidioma)|| '. '|| w_ttexto, SQLERRM); w_error := f_proceslin(w_sproces, f_axis_literales(9000410, pcidioma)|| '. '|| w_ttexto, reg.sseguro, w_cerror); END; END IF;
	                END IF;
	              END IF;
	          END LOOP;

	          /********************************************************************
	                                   SINIESTROS
	           ********************************************************************/
	          v_traza:=5;

	          IF pac_parametros.f_parempresa_n(pcempres, 'MODULO_SINI')=1 THEN
	            FOR reg IN c_pagos LOOP
	            /**/
	                /*Seleccionem el CABONO per sinistres(ccausin)*/
	                BEGIN
	                    w_cabono:=NULL;

	                    w_ctipban_abono:=NULL;

	                    /* BUG 17247-  02/2011 - JRH  - 0017247: Envio pagos SAP Cta del pago*/
	                    SELECT p.cbancar,p.ctipban
	                      INTO w_cabono, w_ctipban_abono
	                      FROM sin_tramita_pago p
	                     WHERE p.sidepag=reg.sidepag;

	                    IF w_cabono IS NULL  OR
	                       w_ctipban_abono IS NULL THEN /*Sólo buscamos si no tenemos en el pago*/
	                      /* BUG 17247-  02/2011 - JRH*/
	                      SELECT d.cbancar,d.ctipban
	                        INTO w_cabono, w_ctipban_abono
	                        FROM sin_tramita_destinatario d,sin_tramita_pago p
	                       WHERE d.sperson=p.sperson AND
	                             d.nsinies=p.nsinies AND
	                             p.ctipdes=d.ctipdes AND
	                             p.sidepag=reg.sidepag AND
	                             p.cbancar IS NOT NULL;
	                    END IF;

	                    /* BUG17286:DRA:25/01/2011:Inici*/
	                    IF w_ctipban_abono IS NULL  OR
	                       w_cabono IS NULL THEN BEGIN
	                          SELECT nvl(seguros.cbancar, 0),seguros.ctipban
	                            INTO w_cabono, w_ctipban_abono
	                            FROM seguros
	                           WHERE seguros.sseguro=reg.sseguro;
	                      EXCEPTION
	                          WHEN OTHERS THEN
	                            w_cabono:=lpad(0, 20, '0');
	                      END;
	                    END IF;
	                /* BUG17286:DRA:25/01/2011:Fi*/
	                EXCEPTION
	                    WHEN no_data_found THEN BEGIN
	                          SELECT nvl(seguros.cbancar, 0),seguros.ctipban
	                            INTO w_cabono, w_ctipban_abono
	                            FROM seguros
	                           WHERE seguros.sseguro=reg.sseguro;
	                      EXCEPTION
	                          WHEN OTHERS THEN
	                            w_cabono:=lpad(0, 20, '0');
	                      END;
	                    WHEN OTHERS THEN
	                      num_err:=110039;

	                      w_ttexto:=f_axis_literales(110039, pcidioma);

	                      p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 4, 'Siniestros. '
	                                                                                                      || w_ttexto, SQLERRM);

	                      w_error:=f_proceslin(w_sproces, f_axis_literales(100592, pcidioma)
	                                                      || '. '
	                                                      || w_ttexto, reg.sseguro, w_cerror);
	                END;

	                num_err:=0;

	                /*Seleccionem el codi del producte i el codi de la compte corrent*/
	                num_err:=f_get_ctacargo(reg.cempres, reg.sseguro, reg.catribu, w_cabono, w_ctipban_abono,
	                         /* BUG11396:DRA:14/01/2010*/
	                         w_producto, w_scuecar, w_ctipban, v_ccobban);

	                IF num_err<>0 THEN
	                  w_ttexto:=f_axis_literales(9002225, pcidioma);

	                  w_error:=f_proceslin(w_sproces, f_axis_literales(100592, pcidioma)
	                                                  || '. '
	                                                  || w_ttexto, reg.sseguro, w_cerror);
	                END IF;

	                /*importe para siniestros.*/
	                w_import:=0;

	                /* Bug 28328 - 04-X-2013 - dlF - Error al crear una tansferencia en PROD*/
	                /* hay que sumar el importe del IVA.*/
	                /*w_import := NVL(reg.isinret, 0) - NVL(reg.iretenc, 0);*/
	                w_import:=nvl(reg.isinret, 0)-nvl(reg.iretenc, 0)+nvl(reg.iiva, 0);

	                /* fin Bug 28328 - 04-X-2013 - dlF*/
	                /* BUG17286:DRA:25/01/2011:Inici*/
	                BEGIN
	                    w_cabono:=replace(w_cabono, '*', '0');

	                    /* #.35302.#*/
	                    w_salida:=NULL;

	                    num_err:=f_ccc(w_cabono, w_ctipban_abono, w_control, w_salida);

	                    w_cabono:=w_salida;

	                    IF num_err<>0 THEN
	                      w_ttexto:=f_axis_literales(num_err, pcidioma);

	                      p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 41, f_axis_literales(100592, pcidioma)
	                                                                                                       || '. '
	                                                                                                       || w_cabono
	                                                                                                       || '--'
	                                                                                                       || w_ctipban_abono
	                                                                                                       || ': '
	                                                                                                       || w_ttexto, SQLERRM);

	                      w_error:=f_proceslin(w_sproces, substr(f_axis_literales(100592, pcidioma)
	                                                             || ' -> '
	                                                             || reg.nsinies
	                                                             || '. '
	                                                             || w_cabono
	                                                             || '--'
	                                                             || w_ctipban_abono, 1, 120), reg.sseguro, w_cerror);
	                    END IF;
	                EXCEPTION
	                    WHEN OTHERS THEN
	                      num_err:=102494;

	                      w_ttexto:=f_axis_literales(num_err, pcidioma);

	                      p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 42, f_axis_literales(100592, pcidioma)
	                                                                                                       || '. '
	                                                                                                       || w_cabono
	                                                                                                       || '--'
	                                                                                                       || w_ctipban_abono
	                                                                                                       || ': '
	                                                                                                       || w_ttexto, SQLERRM);

	                      w_error:=f_proceslin(w_sproces, substr(f_axis_literales(100592, pcidioma)
	                                                             || ' -> '
	                                                             || reg.nsinies
	                                                             || '. '
	                                                             || w_cabono
	                                                             || '--'
	                                                             || w_ctipban_abono, 1, 120), reg.sseguro, w_cerror);
	                END;

	                /* BUG17286:DRA:25/01/2011:Fi*/
	                BEGIN
	                    SELECT sperson
	                      INTO v_sperson
	                      FROM sin_tramita_pago p
	                     WHERE sidepag=reg.sidepag;
	                EXCEPTION
	                    WHEN OTHERS THEN
	                      num_err:=-1;
	                END;

	                IF num_err=0 AND
	                   w_import>0 THEN
	                /* BUG 36723*/
	                BEGIN
	                      SELECT ag.cagente
	                        INTO v_agente /* validamos si el agente existe en una lista restringida*/
	                        FROM lre_personas lre,agentes ag
	                       WHERE lre.sperson=ag.sperson AND
	                             lre.cclalis=2 AND
	                             lre.ctiplis=48 AND
	                             lre.finclus<f_sysdate AND
	                             lre.sperson=v_sperson;
	                  EXCEPTION
	                      WHEN no_data_found THEN
	                        v_agente:=0;
	                  END; IF (v_agente > 0) THEN /* si esta en lista restringida inserta en remesas_previo_lre, y si*/
	                SELECT count(sclave) INTO v_exis_resgistro FROM remesas_previo_lre rpl WHERE cabono = w_cabono AND iimport = w_import AND fabono = w_fecha AND cempres = reg.cempres AND nsinies = reg.nsinies AND sidepag = reg.sidepag; IF (v_exis_resgistro <= 0) THEN /* si no existe previo el registrp se inserta*/

		    SELECT
		           sremesa_previo_lre.NEXTVAL INTO w_secuencia_remesa
		      FROM
		dual; BEGIN INSERT INTO remesas_previo_lre
		           (sclave, cempres, cabono, iimport, fabono, nrecibo,
		           nsinies, sidepag, nrentas, sseguro, nreemb,
		           nfact, spago, ctapres, cagente, clisres,
		           flisres, ulisres)
		    VALUES
		           (w_secuencia_remesa, reg.cempres, w_cabono, w_import, w_fecha, NULL,
		           reg.nsinies, reg.sidepag, NULL, reg.sseguro, NULL,
		           NULL, NULL, NULL, v_agente, 1,
		           f_sysdate, f_user); EXCEPTION WHEN dup_val_on_index THEN /* BUG11396:DRA:20/01/2010*/

	                w_ttexto := f_axis_literales(9908574, pcidioma); p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 50, f_axis_literales(9001843, pcidioma)|| '. '|| f_axis_literales(109005, pcidioma)|| '. '|| w_ttexto, SQLERRM); w_error := f_proceslin(w_sproces, substr(f_axis_literales(9001843, pcidioma)|| '. '|| f_axis_literales(100592, pcidioma)|| ' -> '|| reg.nsinies, 1, 120), reg.sseguro, w_cerror); v_duplicats := 1; WHEN OTHERS THEN w_ttexto := f_axis_literales(9908574, pcidioma); p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 51, f_axis_literales(100592, pcidioma)|| '. '|| w_ttexto, SQLERRM); w_error := f_proceslin(w_sproces, f_axis_literales(100592, pcidioma)|| '. '|| w_ttexto, reg.sseguro, w_cerror); END; END IF; ELSE BEGIN SELECT clisres INTO v_clisres FROM remesas_previo_lre rpl WHERE cabono = w_cabono AND iimport = w_import AND fabono = w_fecha AND cempres = reg.cempres AND nsinies = reg.nsinies AND sidepag =
	                reg.sidepag;
	                EXCEPTION
			           WHEN OTHERS THEN v_clisres := 0; END; IF
		           (v_clisres <> 2) THEN BEGIN
		    SELECT
		           sremesa_previo.NEXTVAL INTO w_secuencia
		      FROM
		dual; INSERT INTO remesas_previo (sremesa, ccc, ctipban, nrecibo, nsinies, sidepag,
		           cabono, ctipban_abono, iimport, sseguro, catribu,
		           sproduc, fabono, nremesa, ftransf, cempres,
		           sperson, ccobban)
		    VALUES
		           (w_secuencia, w_scuecar, w_ctipban, NULL, reg.nsinies, reg.sidepag,
		           w_cabono, w_ctipban_abono, w_import, reg.sseguro, reg.catribu,
		           w_producto, w_fecha, NULL, NULL, reg.cempres,
		           v_sperson, v_ccobban); EXCEPTION WHEN dup_val_on_index THEN /* BUG11396:DRA:20/01/2010*/

	                w_ttexto := f_axis_literales(9002226, pcidioma); p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 52, f_axis_literales(9001843, pcidioma)|| '. '|| f_axis_literales(100592, pcidioma)|| '. '|| w_ttexto, SQLERRM); w_error := f_proceslin(w_sproces, substr(f_axis_literales(9001843, pcidioma)|| '. '|| f_axis_literales(100592, pcidioma)|| ' -> '|| reg.nsinies, 1, 120), reg.sseguro, w_cerror); v_duplicats := 1; WHEN OTHERS THEN w_ttexto := f_axis_literales(9002226, pcidioma); p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 53, f_axis_literales(100592, pcidioma)|| '. '|| w_ttexto, SQLERRM); w_error := f_proceslin(w_sproces, f_axis_literales(100592, pcidioma)|| '. '|| w_ttexto, reg.sseguro, w_cerror); END; END IF; END IF;
	                END IF;
	            END LOOP;
	          ELSE
	            v_traza:=6;

	            FOR reg IN c_pagos_ant LOOP
	            /**/
	                /*Seleccionem el CABONO per sinistres(ccausin)*/
	                BEGIN
	                    w_cabono:=NULL;

	                    w_ctipban_abono:=NULL;

	                    SELECT destinatarios.cbancar,destinatarios.ctipban
	                      INTO w_cabono, w_ctipban_abono
	                      FROM destinatarios,pagosini
	                     WHERE destinatarios.sperson=pagosini.sperson AND
	                           destinatarios.nsinies=pagosini.nsinies AND
	                           pagosini.ctipdes=destinatarios.ctipdes AND
	                           pagosini.sidepag=reg.sidepag AND
	                           destinatarios.cbancar IS NOT NULL;

	                    /* BUG17286:DRA:25/01/2011:Inici*/
	                    IF w_ctipban_abono IS NULL  OR
	                       w_cabono IS NULL THEN BEGIN
	                          SELECT nvl(seguros.cbancar, 0),seguros.ctipban
	                            INTO w_cabono, w_ctipban_abono
	                            FROM seguros
	                           WHERE seguros.sseguro=reg.sseguro;
	                      EXCEPTION
	                          WHEN OTHERS THEN
	                            w_cabono:=lpad(0, 20, '0');
	                      END;
	                    END IF;
	                /* BUG17286:DRA:25/01/2011:Fi*/
	                EXCEPTION
	                    WHEN no_data_found THEN BEGIN
	                          SELECT nvl(seguros.cbancar, 0),seguros.ctipban
	                            INTO w_cabono, w_ctipban_abono
	                            FROM seguros
	                           WHERE seguros.sseguro=reg.sseguro;
	                      EXCEPTION
	                          WHEN OTHERS THEN
	                            w_cabono:=lpad(0, 20, '0');
	                      END;
	                    WHEN OTHERS THEN
	                      num_err:=110039;

	                      w_ttexto:=f_axis_literales(110039, pcidioma);

	                      p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 6, f_axis_literales(100592, pcidioma)
	                                                                                                      || '. '
	                                                                                                      || w_ttexto, SQLERRM);

	                      w_error:=f_proceslin(w_sproces, f_axis_literales(100592, pcidioma)
	                                                      || '. '
	                                                      || w_ttexto, reg.sseguro, w_cerror);
	                END;

	                num_err:=0;

	                /*Seleccionem el codi del producte i el codi de la compte corrent*/
	                num_err:=f_get_ctacargo(reg.cempres, reg.sseguro, reg.catribu, w_cabono, w_ctipban_abono,
	                         /* BUG11396:DRA:14/01/2010*/
	                         w_producto, w_scuecar, w_ctipban, v_ccobban);

	                IF num_err<>0 THEN
	                  w_ttexto:=f_axis_literales(9002225, pcidioma);

	                  w_error:=f_proceslin(w_sproces, f_axis_literales(100592, pcidioma)
	                                                  || '. '
	                                                  || w_ttexto, reg.sseguro, w_cerror);
	                END IF;

	                /*importe para siniestros.*/
	                w_import:=0;

	                /* Bug 28328 - 04-X-2013 - dlF - Error al crear una tansferencia en PROD*/
	                /* hay que sumar el importe del IVA.*/
	                /*w_import := NVL(reg.isinret, 0) - NVL(reg.iretenc, 0);*/
	                w_import:=nvl(reg.isinret, 0)-nvl(reg.iretenc, 0)+nvl(reg.iimpiva, 0);

	                /* fin Bug 28328 - 04-X-2013 - dlF*/
	                /* BUG17286:DRA:25/01/2011:Inici*/
	                BEGIN
	                    w_cabono:=replace(w_cabono, '*', '0');

	                    num_err:=f_ccc(w_cabono, w_ctipban_abono, w_control, w_salida);

	                    w_cabono:=w_salida;

	                    IF num_err<>0 THEN
	                      w_ttexto:=f_axis_literales(num_err, pcidioma);

	                      p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 61, f_axis_literales(100592, pcidioma)
	                                                                                                       || '. '
	                                                                                                       || w_cabono
	                                                                                                       || '--'
	                                                                                                       || w_ctipban_abono
	                                                                                                       || ': '
	                                                                                                       || w_ttexto, SQLERRM);

	                      w_error:=f_proceslin(w_sproces, substr(f_axis_literales(100592, pcidioma)
	                                                             || ' -> '
	                                                             || reg.nsinies
	                                                             || '. '
	                                                             || w_cabono
	                                                             || '--'
	                                                             || w_ctipban_abono, 1, 120), reg.sseguro, w_cerror);
	                    END IF;
	                EXCEPTION
	                    WHEN OTHERS THEN
	                      num_err:=102494;

	                      w_ttexto:=f_axis_literales(num_err, pcidioma);

	                      p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 62, f_axis_literales(100592, pcidioma)
	                                                                                                       || '. '
	                                                                                                       || w_cabono
	                                                                                                       || '--'
	                                                                                                       || w_ctipban_abono
	                                                                                                       || ': '
	                                                                                                       || w_ttexto, SQLERRM);

	                      w_error:=f_proceslin(w_sproces, substr(f_axis_literales(100592, pcidioma)
	                                                             || ' -> '
	                                                             || reg.nsinies
	                                                             || '. '
	                                                             || w_cabono
	                                                             || '--'
	                                                             || w_ctipban_abono, 1, 120), reg.sseguro, w_cerror);
	                END;

	                /* BUG17286:DRA:25/01/2011:Fi*/
	                BEGIN
	                    SELECT sperson
	                      INTO v_sperson
	                      FROM pagosini
	                     WHERE sidepag=reg.sidepag;
	                EXCEPTION
	                    WHEN OTHERS THEN
	                      num_err:=-1;
	                END;

	                IF num_err=0 AND
	                   w_import>0 THEN
	                /* BUG 36723*/
	                BEGIN
	                      SELECT ag.cagente
	                        INTO v_agente /* validamos si el agente existe en una lista restringida*/
	                        FROM lre_personas lre,agentes ag
	                       WHERE lre.sperson=ag.sperson AND
	                             lre.cclalis=2 AND
	                             lre.ctiplis=48 AND
	                             lre.finclus<f_sysdate AND
	                             lre.sperson=v_sperson;
	                  EXCEPTION
	                      WHEN no_data_found THEN
	                        v_agente:=0;
	                  END; IF (v_agente > 0) THEN /* si esta en lista restringida inserta en remesas_previo_lre, y si*/
	                SELECT count(sclave) INTO v_exis_resgistro FROM remesas_previo_lre rpl WHERE cabono = w_cabono AND iimport = w_import AND fabono = w_fecha AND cempres = reg.cempres AND nsinies = reg.nsinies AND sidepag = reg.sidepag; IF (v_exis_resgistro <= 0) THEN /* si no existe previo el registrp se inserta*/

		    SELECT
		           sremesa_previo_lre.NEXTVAL INTO w_secuencia_remesa
		      FROM
		dual; BEGIN INSERT INTO remesas_previo_lre
		           (sclave, cempres, cabono, iimport, fabono, nrecibo,
		           nsinies, sidepag, nrentas, sseguro, nreemb,
		           nfact, spago, ctapres, cagente, clisres,
		           flisres, ulisres)
		    VALUES
		           (w_secuencia_remesa, reg.cempres, w_cabono, w_import, w_fecha, NULL,
		           reg.nsinies, reg.sidepag, NULL, reg.sseguro, NULL,
		           NULL, NULL, NULL, v_agente, 1,
		           f_sysdate, f_user); EXCEPTION WHEN dup_val_on_index THEN /* BUG11396:DRA:20/01/2010*/

	                w_ttexto := f_axis_literales(9908574, pcidioma); p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 70, f_axis_literales(9001843, pcidioma)|| '. '|| f_axis_literales(109005, pcidioma)|| '. '|| w_ttexto, SQLERRM); w_error := f_proceslin(w_sproces, substr(f_axis_literales(9001843, pcidioma)|| '. '|| f_axis_literales(109005, pcidioma)|| ' -> '|| reg.nsinies, 1, 120), reg.sseguro, w_cerror); v_duplicats := 1; WHEN OTHERS THEN w_ttexto := f_axis_literales(9908574, pcidioma); p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 71, f_axis_literales(109005, pcidioma)|| '. '|| w_ttexto, SQLERRM); w_error := f_proceslin(w_sproces, f_axis_literales(109005, pcidioma)|| '. '|| w_ttexto, reg.sseguro, w_cerror); END; END IF; ELSE BEGIN SELECT clisres INTO v_clisres FROM remesas_previo_lre rpl WHERE cabono = w_cabono AND iimport = w_import AND fabono = w_fecha AND cempres = reg.cempres AND nsinies = reg.nsinies AND sidepag =
	                reg.sidepag;
	                EXCEPTION
			           WHEN OTHERS THEN v_clisres := 0; END; IF
		           (v_clisres <> 2) THEN BEGIN
		    SELECT
		           sremesa_previo.NEXTVAL INTO w_secuencia
		      FROM
		dual; INSERT INTO remesas_previo (sremesa, ccc, ctipban, nrecibo, nsinies, sidepag,
		           cabono, ctipban_abono, iimport, sseguro, catribu,
		           sproduc, fabono, nremesa, ftransf, cempres,
		           sperson, ccobban)
		    VALUES
		           (w_secuencia, w_scuecar, w_ctipban, NULL, reg.nsinies, reg.sidepag,
		           w_cabono, w_ctipban_abono, w_import, reg.sseguro, reg.catribu,
		           w_producto, w_fecha, NULL, NULL, reg.cempres,
		           v_sperson, v_ccobban); EXCEPTION WHEN dup_val_on_index THEN /* BUG11396:DRA:20/01/2010*/

	                w_ttexto := f_axis_literales(9002226, pcidioma); p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 72, f_axis_literales(9001843, pcidioma)|| '. '|| f_axis_literales(100592, pcidioma)|| '. '|| w_ttexto, SQLERRM); w_error := f_proceslin(w_sproces, substr(f_axis_literales(9001843, pcidioma)|| '. '|| f_axis_literales(100592, pcidioma)|| ' -> '|| reg.nsinies, 1, 120), reg.sseguro, w_cerror); v_duplicats := 1; WHEN OTHERS THEN w_ttexto := f_axis_literales(9002226, pcidioma); p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 73, f_axis_literales(100592, pcidioma)|| '. '|| w_ttexto, SQLERRM); w_error := f_proceslin(w_sproces, f_axis_literales(100592, pcidioma)|| '. '|| w_ttexto, reg.sseguro, w_cerror); END; END IF; END IF;
	                END IF;
	            END LOOP;
	          END IF;

	          /********************************************************************
	                                      REEMBOLSOS
	          ********************************************************************/
	          v_traza:=7;

	          FOR reg IN c_reembolsos LOOP
	              num_err:=0;

	              /*Seleccionem el codi del producte i el codi de la compte corrent*/
	              num_err:=f_get_ctacargo(reg.cempres, reg.sseguro, reg.tipo_transfer, reg.cbancar, reg.ctipban, /* BUG11396:DRA:14/01/2010*/
	                       w_producto, w_scuecar, w_ctipban, v_ccobban);

	              IF num_err<>0 THEN
	                w_ttexto:=f_axis_literales(9002225, pcidioma);

	                w_error:=f_proceslin(w_sproces, f_axis_literales(9000441, pcidioma)
	                                                || '. '
	                                                || w_ttexto, reg.sseguro, w_cerror);
	              END IF;

	              /*BUG 0010266: ETM: 02-06-2009 --FIN*/
	              IF num_err=0 AND
	                 reg.importe>0 THEN
	              /*Seleccionem la sequencia per el numero de la remesa*/
	              /* BUG 36723*/
	              BEGIN
	                    SELECT ag.cagente
	                      INTO v_agente /* validamos si el agente existe en una lista restringida*/
	                      FROM lre_personas lre,agentes ag
	                     WHERE lre.sperson=ag.sperson AND
	                           lre.cclalis=2 AND
	                           lre.ctiplis=48 AND
	                           lre.finclus<f_sysdate AND
	                           lre.sperson=v_sperson;
	                EXCEPTION
	                    WHEN no_data_found THEN
	                      v_agente:=0;
	                END; IF (v_agente > 0) THEN /* si esta en lista restringida inserta en remesas_previo_lre, y si*/
	              SELECT count(sclave) INTO v_exis_resgistro FROM remesas_previo_lre rpl WHERE cabono = reg.cbancar AND iimport = reg.importe AND fabono = w_fecha AND cempres = reg.cempres AND nreemb = reg.nreemb AND nfact = reg.nfact AND sseguro = reg.sseguro; IF (v_exis_resgistro <= 0) THEN /* si no existe previo el registrp se inserta*/

		    SELECT
		           sremesa_previo_lre.NEXTVAL INTO w_secuencia_remesa
		      FROM
		dual; BEGIN INSERT INTO remesas_previo_lre
		           (sclave, cempres, cabono, iimport, fabono, nrecibo,
		           nsinies, sidepag, nrentas, sseguro, nreemb,
		           nfact, spago, ctapres, cagente, clisres,
		           flisres, ulisres)
		    VALUES
		           (w_secuencia_remesa, reg.cempres, reg.cbancar, reg.importe, w_fecha, NULL,
		           NULL, NULL, NULL, reg.sseguro, reg.nreemb,
		           reg.nfact, NULL, NULL, v_agente, 1,
		           f_sysdate, f_user); EXCEPTION WHEN dup_val_on_index THEN /* BUG11396:DRA:20/01/2010*/

	              w_ttexto := f_axis_literales(9908574, pcidioma); p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 90, f_axis_literales(9001843, pcidioma)|| '. '|| f_axis_literales(109005, pcidioma)|| '. '|| w_ttexto, SQLERRM); w_error := f_proceslin(w_sproces, substr(f_axis_literales(9001843, pcidioma)|| '. '|| f_axis_literales(9000441, pcidioma)|| ' -> '|| reg.nlinea, 1, 120), reg.sseguro, w_cerror); v_duplicats := 1; WHEN OTHERS THEN w_ttexto := f_axis_literales(9908574, pcidioma); p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 91, f_axis_literales(9000441, pcidioma)|| '. '|| w_ttexto, SQLERRM); w_error := f_proceslin(w_sproces, f_axis_literales(9000441, pcidioma)|| '. '|| w_ttexto, reg.sseguro, w_cerror); END; END IF; ELSE BEGIN SELECT clisres INTO v_clisres FROM remesas_previo_lre rpl WHERE cabono = reg.cbancar AND iimport = reg.importe AND fabono = w_fecha AND cempres = reg.cempres AND nreemb = reg.nreemb AND nfact =
	              reg.nfact
	              AND
	              sseguro
	              = reg.sseguro; EXCEPTION WHEN OTHERS THEN v_clisres := 0; END; IF (v_clisres <> 2) THEN SELECT sremesa_previo.NEXTVAL INTO w_secuencia FROM dual; BEGIN
	              /* BUG10604:DRA:0/07/2009:Fi*/
			INSERT INTO remesas_previo
		           (sremesa, ccc, ctipban, nrecibo, nsinies, sidepag,
		           nrentas, cabono, iimport, ctipban_abono, sseguro,
		           catribu, sproduc, fabono, nremesa, ftransf,
		           cempres, sperson, ccobban, nreemb, nfact,
		           nlinea, ctipo)
		    VALUES
		           (w_secuencia, w_scuecar, w_ctipban, NULL, NULL, NULL,
		           NULL, reg.cbancar, reg.importe, reg.ctipban, reg.sseguro,
		           reg.tipo_transfer, w_producto, w_fecha, NULL, NULL,
		           reg.cempres, reg.sperson, v_ccobban, reg.nreemb, reg.nfact,
		           reg.nlinea, reg.ctipo); EXCEPTION WHEN dup_val_on_index THEN /* BUG11396:DRA:20/01/2010*/

	              w_ttexto := f_axis_literales(9002226, pcidioma); p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 92, f_axis_literales(9001843, pcidioma)|| '. '|| f_axis_literales(9000441, pcidioma)|| '. '|| w_ttexto, SQLERRM); w_error := f_proceslin(w_sproces, substr(f_axis_literales(9001843, pcidioma)|| '. '|| f_axis_literales(9000441, pcidioma)|| ' -> '|| reg.nreemb|| '-'|| reg.nfact|| '-'|| reg.nlinea, 1, 120), reg.sseguro, w_cerror); v_duplicats := 1; WHEN OTHERS THEN w_ttexto := f_axis_literales(9002226, pcidioma); p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 93, f_axis_literales(9000441, pcidioma)|| '. '|| w_ttexto, SQLERRM); w_error := f_proceslin(w_sproces, f_axis_literales(9000441, pcidioma)|| '. '|| w_ttexto, reg.sseguro, w_cerror); END; END IF; END IF;
	              END IF;
	          END LOOP;

	          /********************************************************************
	                                      PAGOSCOMISIONES
	          ********************************************************************/
	          v_traza:=8;

	          FOR reg IN c_pagoscomisiones LOOP
	              /* BUG14344:DRA:04/05/2010:Inici*/
	              IF reg.iimporte>0 THEN
	                num_err:=0;

	                /*miramos si el agente tiene datos de cobban en codnivelage, sino seguirá como hasta ahora*/
	                BEGIN
	                    SELECT NULL,cb.ncuenta,cb.ctipban,cb.ccobban
	                      INTO w_producto, w_scuecar, w_ctipban, v_ccobban
	                      FROM codnivelage pc,agentes a,cobbancario cb /* BUG11396:DRA:14/01/2010*/
	                     WHERE a.cagente=reg.cagente AND
	                           cb.ccobban=pc.ccobban AND
	                           a.ctipage=pc.ctipage AND
	                           pc.cempres=reg.cempres AND
	                           pc.ccobban IS NOT NULL;
	                EXCEPTION
	                    WHEN OTHERS THEN
	                      /*Seleccionem el codi del producte i el codi de la compte corrent*/
	                      num_err:=f_get_ctacargo(reg.cempres, NULL, reg.tipo_transfer, reg.cbancar, reg.ctipban, /* BUG11396:DRA:14/01/2010*/
	                               w_producto, w_scuecar, w_ctipban, v_ccobban);
	                END;

	                IF num_err<>0 THEN
	                  w_ttexto:=f_axis_literales(9002225, pcidioma);

	                  w_error:=f_proceslin(w_sproces, f_axis_literales(9001776, pcidioma)
	                                                  || '. '
	                                                  || w_ttexto, reg.spago, w_cerror);
	                END IF;

	                BEGIN
	                    SELECT sperson
	                      INTO v_sperson
	                      FROM agentes
	                     WHERE cagente=reg.cagente;
	                EXCEPTION
	                    WHEN OTHERS THEN
	                      num_err:=-1;
	                END;

	                /* BUG 36723*/
	                v_traza:=81;

	                BEGIN
	                    SELECT ag.cagente
	                      INTO v_agente /* validamos si el agente existe en una lista restringida*/
	                      FROM lre_personas lre,agentes ag
	                     WHERE lre.sperson=ag.sperson AND
	                           lre.cclalis=2 AND
	                           lre.ctiplis=48 AND
	                           lre.finclus<f_sysdate AND
	                           ag.cagente=reg.cagente;
	                EXCEPTION
	                    WHEN no_data_found THEN
	                      v_agente:=0;
	                END;

	                v_traza:=82;

	                IF (v_agente>0) THEN /* si esta en lista restringida inserta en remesas_previo_lre, y si*/
	                  SELECT count(sclave)
	                    INTO v_exis_resgistro
	                    FROM remesas_previo_lre rpl
	                   WHERE cabono=reg.cbancar AND
	                         iimport=reg.iimporte AND
	                         fabono=w_fecha AND
	                         cempres=reg.cempres AND
	                         spago=reg.spago;

	                  IF (v_exis_resgistro<=0) THEN /* si no existe previo el registrp se inserta*/
	                    SELECT sremesa_previo_lre.NEXTVAL
	                      INTO w_secuencia_remesa
	                      FROM dual;

	                    BEGIN
			INSERT INTO remesas_previo_lre
		           (sclave,cempres,cabono,iimport,fabono,nrecibo,
		           nsinies,sidepag,nrentas,sseguro,nreemb,
		           nfact,spago,ctapres,cagente,clisres,
		           flisres,ulisres)
		    VALUES
		           (w_secuencia_remesa,reg.cempres,reg.cbancar,reg.iimporte,w_fecha,NULL,
		           NULL,NULL,NULL,NULL,NULL,
		           NULL,reg.spago,NULL,reg.cagente,1,
		           f_sysdate,f_user);

	                    EXCEPTION
	                        WHEN dup_val_on_index THEN /* BUG11396:DRA:20/01/2010*/
	                          w_ttexto:=f_axis_literales(9908574, pcidioma);

	                          p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 100, f_axis_literales(9001843, pcidioma)
	                                                                                                            || '. '
	                                                                                                            || f_axis_literales(9001776, pcidioma)
	                                                                                                            || '. '
	                                                                                                            || w_ttexto, SQLERRM);

	                          w_error:=f_proceslin(w_sproces, substr(f_axis_literales(9001843, pcidioma)
	                                                                 || '. '
	                                                                 || f_axis_literales(9001776, pcidioma)
	                                                                 || ' -> '
	                                                                 || reg.spago, 1, 120), reg.spago, w_cerror);

	                          v_duplicats:=1;
	                        WHEN OTHERS THEN
	                          w_ttexto:=f_axis_literales(9908574, pcidioma);

	                          p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 101, f_axis_literales(9001776, pcidioma)
	                                                                                                            || '. '
	                                                                                                            || w_ttexto, SQLERRM);

	                          w_error:=f_proceslin(w_sproces, f_axis_literales(9001776, pcidioma)
	                                                          || '. '
	                                                          || w_ttexto, reg.spago, w_cerror);
	                    END;
	                  END IF;
	                ELSE BEGIN
	                      SELECT clisres
	                        INTO v_clisres
	                        FROM remesas_previo_lre rpl
	                       WHERE cabono=reg.cbancar AND
	                             iimport=reg.iimporte AND
	                             fabono=w_fecha AND
	                             cempres=reg.cempres AND
	                             spago=reg.spago;
	                  EXCEPTION
	                      WHEN OTHERS THEN
	                        v_clisres:=0;
	                  END; IF (v_clisres <> 2) THEN /* se valida que la transferencia no este cancelada*/
	                /*Seleccionem la sequencia per el numero de la remesa*/
	                SELECT sremesa_previo.NEXTVAL INTO w_secuencia FROM dual; BEGIN
	                /* BUG10604:DRA:0/07/2009:Fi*/
			INSERT INTO remesas_previo
		           (sremesa, ccc, ctipban, nrecibo, nsinies, sidepag,
		           nrentas, cabono, iimport, ctipban_abono, sseguro,
		           catribu, sproduc, fabono, nremesa, ftransf,
		           cempres, sperson, ccobban, nreemb, nfact,
		           nlinea, ctipo, spago)
		    VALUES
		           (w_secuencia, w_scuecar, w_ctipban, NULL, NULL, NULL,
		           NULL, reg.cbancar, reg.iimporte, reg.ctipban, NULL,
		           reg.tipo_transfer, NULL, w_fecha, NULL, NULL,
		           reg.cempres, NULL, v_ccobban, NULL, NULL,
		           NULL, NULL, reg.spago); EXCEPTION WHEN dup_val_on_index THEN /* BUG11396:DRA:20/01/2010*/

	                w_ttexto := f_axis_literales(9002226, pcidioma); p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 102, f_axis_literales(9001843, pcidioma)|| '. '|| f_axis_literales(9001776, pcidioma)|| '. '|| w_ttexto, SQLERRM); w_error := f_proceslin(w_sproces, substr(f_axis_literales(9001843, pcidioma)|| '. '|| f_axis_literales(9001776, pcidioma)|| ' -> '|| reg.spago, 1, 120), reg.spago, w_cerror); v_duplicats := 1; WHEN OTHERS THEN w_ttexto := f_axis_literales(9002226, pcidioma); p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 103, f_axis_literales(9001776, pcidioma)|| '. '|| w_ttexto, SQLERRM); w_error := f_proceslin(w_sproces, f_axis_literales(9001776, pcidioma)|| '. '|| w_ttexto, reg.spago, w_cerror); END; END IF;
	                END IF;
	              END IF;
	          END LOOP;

	        /* BUG14344:DRA:04/05/2010:Fi*/
	        /* BUG : 19238 - JMC - 09/11/2011*/
	        /*ini bug 33427/191636:NSS:12/11/2014*/
	          /********************************************************************
	                                      PAGOSCTATECREA
	          ********************************************************************/
	          v_traza:=9;

	          FOR reg IN c_pagosctatecrea LOOP
	              /* BUG14344:DRA:04/05/2010:Inici*/
	              IF reg.iimporte>0 THEN
	                num_err:=0;

	                /*Seleccionem el codi del producte i el codi de la compte corrent*/
	                num_err:=f_get_ctacargo_age(reg.cempres, NULL, reg.tipo_transfer, reg.cbancar, reg.ctipban, /* BUG11396:DRA:14/01/2010*/
	                         w_producto, w_scuecar, w_ctipban, v_ccobban, v_agente);

	                IF num_err<>0 THEN
	                  w_ttexto:=f_axis_literales(9002225, pcidioma);

	                  w_error:=f_proceslin(w_sproces, f_axis_literales(9001776, pcidioma)
	                                                  || '. '
	                                                  || w_ttexto, reg.spagrea, w_cerror);
	                END IF;

	                BEGIN
	                    SELECT sperson
	                      INTO v_sperson
	                      FROM agentes
	                     WHERE cagente=v_agente;
	                EXCEPTION
	                    WHEN OTHERS THEN
	                      num_err:=-1;
	                END;

	                /* BUG 36723*/
	                BEGIN
	                    SELECT ag.cagente
	                      INTO v_agente /* validamos si el agente existe en una lista restringida*/
	                      FROM lre_personas lre,agentes ag
	                     WHERE lre.sperson=ag.sperson AND
	                           lre.cclalis=2 AND
	                           lre.ctiplis=48 AND
	                           lre.finclus<f_sysdate AND
	                           lre.sperson=v_sperson;
	                EXCEPTION
	                    WHEN no_data_found THEN
	                      v_agente:=0;
	                END;

	                IF (v_agente>0) THEN /* si esta en lista restringida inserta en remesas_previo_lre, y si*/
	                  SELECT count(sclave)
	                    INTO v_exis_resgistro
	                    FROM remesas_previo_lre rpl
	                   WHERE cabono=reg.cbancar AND
	                         iimport=reg.iimporte AND
	                         fabono=w_fecha AND
	                         cempres=reg.cempres AND
	                         spago=reg.spagrea;

	                  IF (v_exis_resgistro<=0) THEN /* si no existe previo el registrp se inserta*/
	                    SELECT sremesa_previo_lre.NEXTVAL
	                      INTO w_secuencia_remesa
	                      FROM dual;

	                    BEGIN
			INSERT INTO remesas_previo_lre
		           (sclave,cempres,cabono,iimport,fabono,nrecibo,
		           nsinies,sidepag,nrentas,sseguro,nreemb,
		           nfact,spago,ctapres,cagente,clisres,
		           flisres,ulisres)
		    VALUES
		           (w_secuencia_remesa,reg.cempres,reg.cbancar,reg.iimporte,w_fecha,NULL,
		           NULL,NULL,NULL,NULL,NULL,
		           NULL,reg.spagrea,NULL,v_agente,1,
		           f_sysdate,f_user);

	                    EXCEPTION
	                        WHEN dup_val_on_index THEN
	                          w_ttexto:=f_axis_literales(9908574, pcidioma);

	                          p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 111, f_axis_literales(9001843, pcidioma)
	                                                                                                            || '. '
	                                                                                                            || f_axis_literales(109005, pcidioma)
	                                                                                                            || '. '
	                                                                                                            || w_ttexto, SQLERRM);

	                          w_error:=f_proceslin(w_sproces, substr(f_axis_literales(9001843, pcidioma)
	                                                                 || '. '
	                                                                 || f_axis_literales(109005, pcidioma)
	                                                                 || ' -> '
	                                                                 || reg.spagrea, 1, 120), reg.spagrea, w_cerror);

	                          v_duplicats:=1;
	                        WHEN OTHERS THEN
	                          w_ttexto:=f_axis_literales(9908574, pcidioma);

	                          p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 112, f_axis_literales(109005, pcidioma)
	                                                                                                            || '. '
	                                                                                                            || w_ttexto, SQLERRM);

	                          w_error:=f_proceslin(w_sproces, f_axis_literales(109005, pcidioma)
	                                                          || '. '
	                                                          || w_ttexto, reg.spagrea, w_cerror);
	                    END;
	                  END IF;
	                ELSE BEGIN
	                      SELECT clisres
	                        INTO v_clisres
	                        FROM remesas_previo_lre rpl
	                       WHERE cabono=reg.cbancar AND
	                             iimport=reg.iimporte AND
	                             fabono=w_fecha AND
	                             cempres=reg.cempres AND
	                             spago=reg.spagrea;
	                  EXCEPTION
	                      WHEN OTHERS THEN
	                        v_clisres:=0;
	                  END; IF (v_clisres <> 2) THEN /* se valida que la transferencia no este cancelada*/
	                /*Seleccionem la sequencia per el numero de la remesa*/
	                SELECT sremesa_previo.NEXTVAL INTO w_secuencia FROM dual; BEGIN
	                /* BUG10604:DRA:0/07/2009:Fi*/
			INSERT INTO remesas_previo
		           (sremesa, ccc, ctipban, nrecibo, nsinies, sidepag,
		           nrentas, cabono, iimport, ctipban_abono, sseguro,
		           catribu, sproduc, fabono, nremesa, ftransf,
		           cempres, sperson, ccobban, nreemb, nfact,
		           nlinea, ctipo, spago)
		    VALUES
		           (w_secuencia, w_scuecar, w_ctipban, NULL, NULL, NULL,
		           NULL, reg.cbancar, reg.iimporte, reg.ctipban, NULL,
		           reg.tipo_transfer, NULL, w_fecha, NULL, NULL,
		           reg.cempres, NULL, v_ccobban, NULL, NULL,
		           NULL, NULL, reg.spagrea); COMMIT; EXCEPTION WHEN dup_val_on_index THEN /* BUG11396:DRA:20/01/2010*/

	                w_ttexto := f_axis_literales(9002226, pcidioma); p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 113, f_axis_literales(9001843, pcidioma)|| '. '|| f_axis_literales(9001776, pcidioma)|| '. '|| w_ttexto, SQLERRM); w_error := f_proceslin(w_sproces, substr(f_axis_literales(9001843, pcidioma)|| '. '|| f_axis_literales(9001776, pcidioma)|| ' -> '|| reg.spagrea, 1, 120), reg.spagrea, w_cerror); v_duplicats := 1; WHEN OTHERS THEN w_ttexto := f_axis_literales(9002226, pcidioma); p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 113, f_axis_literales(9001776, pcidioma)|| '. '|| w_ttexto, SQLERRM); w_error := f_proceslin(w_sproces, f_axis_literales(9001776, pcidioma)|| '. '|| w_ttexto, reg.spagrea, w_cerror); END; END IF;
	                END IF;
	              END IF;
	          END LOOP;

	          /********************************************************************
	                          PAGOSCTATECCOA
	          ********************************************************************/
	          v_traza:=10;

	          FOR reg IN c_pagosctateccoa LOOP
	              /* BUG14344:DRA:04/05/2010:Inici*/
	              IF reg.iimporte>0 THEN
	                num_err:=0;

	                /*Seleccionem el codi del producte i el codi de la compte corrent*/
	                num_err:=f_get_ctacargo_age(reg.cempres, NULL, reg.tipo_transfer, reg.cbancar, reg.ctipban, /* BUG11396:DRA:14/01/2010*/
	                         w_producto, w_scuecar, w_ctipban, v_ccobban, v_agente);

	                IF num_err<>0 THEN
	                  w_ttexto:=f_axis_literales(9002225, pcidioma);

	                  w_error:=f_proceslin(w_sproces, f_axis_literales(9001776, pcidioma)
	                                                  || '. '
	                                                  || w_ttexto, reg.spagcoa, w_cerror);
	                END IF;

	                BEGIN
	                    SELECT sperson
	                      INTO v_sperson
	                      FROM agentes
	                     WHERE cagente=v_agente;
	                EXCEPTION
	                    WHEN OTHERS THEN
	                      num_err:=-1;
	                END;

	                /* BUG 36723*/
	                BEGIN
	                    SELECT ag.cagente
	                      INTO v_agente /* validamos si el agente existe en una lista restringida*/
	                      FROM lre_personas lre,agentes ag
	                     WHERE lre.sperson=ag.sperson AND
	                           lre.cclalis=2 AND
	                           lre.ctiplis=48 AND
	                           lre.finclus<f_sysdate AND
	                           lre.sperson=v_sperson;
	                EXCEPTION
	                    WHEN no_data_found THEN
	                      v_agente:=0;
	                END;

	                IF (v_agente>0) THEN /* si esta en lista restringida inserta en remesas_previo_lre, y si*/
	                  SELECT count(sclave)
	                    INTO v_exis_resgistro
	                    FROM remesas_previo_lre rpl
	                   WHERE cabono=reg.cbancar AND
	                         iimport=reg.iimporte AND
	                         fabono=w_fecha AND
	                         cempres=reg.cempres AND
	                         spago=reg.spagcoa;

	                  IF (v_exis_resgistro<=0) THEN /* si no existe previo el registrp se inserta*/
	                    SELECT sremesa_previo_lre.NEXTVAL
	                      INTO w_secuencia_remesa
	                      FROM dual;

	                    BEGIN
			INSERT INTO remesas_previo_lre
		           (sclave,cempres,cabono,iimport,fabono,nrecibo,
		           nsinies,sidepag,nrentas,sseguro,nreemb,
		           nfact,spago,ctapres,cagente,clisres,
		           flisres,ulisres)
		    VALUES
		           (w_secuencia_remesa,reg.cempres,reg.cbancar,reg.iimporte,w_fecha,NULL,
		           NULL,NULL,NULL,NULL,NULL,
		           NULL,reg.spagcoa,NULL,v_agente,1,
		           f_sysdate,f_user);

	                    EXCEPTION
	                        WHEN dup_val_on_index THEN
	                          w_ttexto:=f_axis_literales(9908574, pcidioma);

	                          p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 120, f_axis_literales(9001843, pcidioma)
	                                                                                                            || '. '
	                                                                                                            || f_axis_literales(109005, pcidioma)
	                                                                                                            || '. '
	                                                                                                            || w_ttexto, SQLERRM);

	                          w_error:=f_proceslin(w_sproces, substr(f_axis_literales(9001843, pcidioma)
	                                                                 || '. '
	                                                                 || f_axis_literales(109005, pcidioma)
	                                                                 || ' -> '
	                                                                 || reg.spagcoa, 1, 120), reg.spagcoa, w_cerror);

	                          v_duplicats:=1;
	                        WHEN OTHERS THEN
	                          w_ttexto:=f_axis_literales(9908574, pcidioma);

	                          p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 121, f_axis_literales(109005, pcidioma)
	                                                                                                            || '. '
	                                                                                                            || w_ttexto, SQLERRM);

	                          w_error:=f_proceslin(w_sproces, f_axis_literales(109005, pcidioma)
	                                                          || '. '
	                                                          || w_ttexto, reg.spagcoa, w_cerror);
	                    END;
	                  END IF;
	                ELSE BEGIN
	                      SELECT clisres
	                        INTO v_clisres
	                        FROM remesas_previo_lre rpl
	                       WHERE cabono=reg.cbancar AND
	                             iimport=reg.iimporte AND
	                             fabono=w_fecha AND
	                             cempres=reg.cempres AND
	                             spago=reg.spagcoa;
	                  EXCEPTION
	                      WHEN OTHERS THEN
	                        v_clisres:=0;
	                  END; IF (v_clisres <> 2) THEN /* se valida que la transferencia no este cancelada*/
	                /*Seleccionem la sequencia per el numero de la remesa*/
	                SELECT sremesa_previo.NEXTVAL INTO w_secuencia FROM dual; BEGIN
	                /* BUG10604:DRA:0/07/2009:Fi*/
			INSERT INTO remesas_previo
		           (sremesa, ccc, ctipban, nrecibo, nsinies, sidepag,
		           nrentas, cabono, iimport, ctipban_abono, sseguro,
		           catribu, sproduc, fabono, nremesa, ftransf,
		           cempres, sperson, ccobban, nreemb, nfact,
		           nlinea, ctipo, spago)
		    VALUES
		           (w_secuencia, w_scuecar, w_ctipban, NULL, NULL, NULL,
		           NULL, reg.cbancar, reg.iimporte, reg.ctipban, NULL,
		           reg.tipo_transfer, NULL, w_fecha, NULL, NULL,
		           reg.cempres, NULL, v_ccobban, NULL, NULL,
		           NULL, NULL, reg.spagcoa); COMMIT; EXCEPTION WHEN dup_val_on_index THEN /* BUG11396:DRA:20/01/2010*/

	                w_ttexto := f_axis_literales(9002226, pcidioma); p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 122, f_axis_literales(9001843, pcidioma)|| '. '|| f_axis_literales(9001776, pcidioma)|| '. '|| w_ttexto, SQLERRM); w_error := f_proceslin(w_sproces, substr(f_axis_literales(9001843, pcidioma)|| '. '|| f_axis_literales(9001776, pcidioma)|| ' -> '|| reg.spagcoa, 1, 120), reg.spagcoa, w_cerror); v_duplicats := 1; WHEN OTHERS THEN w_ttexto := f_axis_literales(9002226, pcidioma); p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 123, f_axis_literales(9001776, pcidioma)|| '. '|| w_ttexto, SQLERRM); w_error := f_proceslin(w_sproces, f_axis_literales(9001776, pcidioma)|| '. '|| w_ttexto, reg.spagcoa, w_cerror); END; END IF;
	                END IF;
	              END IF;
	          END LOOP;

	        /*fin bug 33427/191636:NSS:12/11/2014*/
	          /********************************************************************
	                          PRESTAMOPAGOS
	          ********************************************************************/
	          v_traza:=11;

	          FOR reg IN c_prestamopagos LOOP
	              /* BUG14344:DRA:04/05/2010:Inici*/
	              IF reg.iimporte>0 THEN
	                num_err:=0;

	                /*Seleccionem el codi del producte i el codi de la compte corrent*/
	                num_err:=f_get_ctacargo_age(reg.cempres, NULL, reg.tipo_transfer, reg.cbancar, reg.ctipban, /* BUG11396:DRA:14/01/2010*/
	                         w_producto, w_scuecar, w_ctipban, v_ccobban, v_agente);

	                IF num_err<>0 THEN
	                  w_ttexto:=f_axis_literales(9002225, pcidioma);

	                  w_error:=f_proceslin(w_sproces, f_axis_literales(9001776, pcidioma)
	                                                  || '. '
	                                                  || w_ttexto, reg.ctapres, w_cerror);
	                END IF;

	                BEGIN
	                    SELECT sperson
	                      INTO v_sperson
	                      FROM agentes
	                     WHERE cagente=v_agente;
	                EXCEPTION
	                    WHEN OTHERS THEN
	                      num_err:=-1;
	                END;

	                /* BUG 36723*/
	                BEGIN
	                    SELECT ag.cagente
	                      INTO v_agente /* validamos si el agente existe en una lista restringida*/
	                      FROM lre_personas lre,agentes ag
	                     WHERE lre.sperson=ag.sperson AND
	                           lre.cclalis=2 AND
	                           lre.ctiplis=48 AND
	                           lre.finclus<f_sysdate AND
	                           lre.sperson=v_sperson;
	                EXCEPTION
	                    WHEN no_data_found THEN
	                      v_agente:=0;
	                END;

	                IF (v_agente>0) THEN /* si esta en lista restringida inserta en remesas_previo_lre, y si*/
	                  SELECT count(sclave)
	                    INTO v_exis_resgistro
	                    FROM remesas_previo_lre rpl
	                   WHERE cabono=reg.cbancar AND
	                         iimport=reg.iimporte AND
	                         fabono=w_fecha AND
	                         cempres=reg.cempres AND
	                         ctapres=reg.ctapres;

	                  IF (v_exis_resgistro<=0) THEN /* si no existe previo el registrp se inserta*/
	                    SELECT sremesa_previo_lre.NEXTVAL
	                      INTO w_secuencia_remesa
	                      FROM dual;

	                    BEGIN
			INSERT INTO remesas_previo_lre
		           (sclave,cempres,cabono,iimport,fabono,nrecibo,
		           nsinies,sidepag,nrentas,sseguro,nreemb,
		           nfact,spago,ctapres,cagente,clisres,
		           flisres,ulisres)
		    VALUES
		           (w_secuencia_remesa,reg.cempres,reg.cbancar,reg.iimporte,w_fecha,NULL,
		           NULL,NULL,NULL,NULL,NULL,
		           NULL,NULL,reg.ctapres,v_agente,1,
		           f_sysdate,f_user);

	                    EXCEPTION
	                        WHEN dup_val_on_index THEN
	                          w_ttexto:=f_axis_literales(9908574, pcidioma);

	                          p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 130, f_axis_literales(9001843, pcidioma)
	                                                                                                            || '. '
	                                                                                                            || f_axis_literales(109005, pcidioma)
	                                                                                                            || '. '
	                                                                                                            || w_ttexto, SQLERRM);

	                          w_error:=f_proceslin(w_sproces, substr(f_axis_literales(9001843, pcidioma)
	                                                                 || '. '
	                                                                 || f_axis_literales(109005, pcidioma)
	                                                                 || ' -> '
	                                                                 || reg.ctapres, 1, 120), reg.ctapres, w_cerror);

	                          v_duplicats:=1;
	                        WHEN OTHERS THEN
	                          w_ttexto:=f_axis_literales(9908574, pcidioma);

	                          p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 131, f_axis_literales(109005, pcidioma)
	                                                                                                            || '. '
	                                                                                                            || w_ttexto, SQLERRM);

	                          w_error:=f_proceslin(w_sproces, f_axis_literales(109005, pcidioma)
	                                                          || '. '
	                                                          || w_ttexto, reg.ctapres, w_cerror);
	                    END;
	                  END IF;
	                ELSE BEGIN
	                      SELECT clisres
	                        INTO v_clisres
	                        FROM remesas_previo_lre rpl
	                       WHERE cabono=reg.cbancar AND
	                             iimport=reg.iimporte AND
	                             fabono=w_fecha AND
	                             cempres=reg.cempres AND
	                             ctapres=reg.ctapres;
	                  EXCEPTION
	                      WHEN OTHERS THEN
	                        v_clisres:=0;
	                  END; IF (v_clisres <> 2) THEN /* se valida que la transferencia no este cancelada*/
	                /*Seleccionem la sequencia per el numero de la remesa*/
	                SELECT sremesa_previo.NEXTVAL INTO w_secuencia FROM dual; BEGIN
	                /* BUG10604:DRA:0/07/2009:Fi*/
			INSERT INTO remesas_previo
		           (sremesa, ccc, ctipban, nrecibo, nsinies, sidepag,
		           nrentas, cabono, iimport, ctipban_abono, sseguro,
		           catribu, sproduc, fabono, nremesa, ftransf,
		           cempres, sperson, ccobban, nreemb, nfact,
		           nlinea, ctipo, ctapres)
		    VALUES
		           (w_secuencia, w_scuecar, w_ctipban, NULL, NULL, NULL,
		           NULL, reg.cbancar, reg.iimporte, reg.ctipban, NULL,
		           reg.tipo_transfer, NULL, w_fecha, NULL, NULL,
		           reg.cempres, NULL, v_ccobban, NULL, NULL,
		           NULL, NULL, reg.ctapres); EXCEPTION WHEN dup_val_on_index THEN /* BUG11396:DRA:20/01/2010*/

	                w_ttexto := f_axis_literales(9002226, pcidioma); p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 132, f_axis_literales(9001843, pcidioma)|| '. '|| f_axis_literales(9001776, pcidioma)|| '. '|| w_ttexto, SQLERRM); w_error := f_proceslin(w_sproces, substr(f_axis_literales(9001843, pcidioma)|| '. '|| f_axis_literales(9001776, pcidioma)|| ' -> '|| reg.ctapres, 1, 120), reg.ctapres, w_cerror); v_duplicats := 1; WHEN OTHERS THEN w_ttexto := f_axis_literales(9002226, pcidioma); p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 133, f_axis_literales(9001776, pcidioma)|| '. '|| w_ttexto, SQLERRM); w_error := f_proceslin(w_sproces, f_axis_literales(9001776, pcidioma)|| '. '|| w_ttexto, reg.ctapres, w_cerror); END; END IF;
	                END IF;
	              END IF;
	          END LOOP;

	        /* Fin BUG : 19238 - JMC - 09/11/2011*/
	        /* Fin BUG : 19238 - JMC - 09/11/2011*/
	        /* Bug: 33886/202377 se adiciona proceso para pagoctacliente*/
	          /********************************************************************
	                                      PAGOSCTACLIENTE
	          ********************************************************************/
	          v_traza:=12;

	          FOR reg IN c_pagoctacliente LOOP
	              IF reg.iimporte>0 THEN
	                num_err:=0;

	              /* 33886/215876*/
	                /*Seleccionem el codi del producte i el codi de la compte corrent*/
	                num_err:=f_get_ctacargo_age(reg.cempres, reg.sseguro, reg.tipo_transfer, reg.cbancar, reg.ctipban, /* BUG11396:DRA:14/01/2010*/
	                         w_producto, w_scuecar, w_ctipban, v_ccobban, v_agente);

	                IF num_err<>0 THEN
	                  w_ttexto:=f_axis_literales(9002225, pcidioma);

	                  w_error:=f_proceslin(w_sproces, f_axis_literales(9907896, pcidioma)
	                                                  || '. '
	                                                  || w_ttexto, reg.spago, w_cerror);
	                END IF;

	                /* BUG 36723*/
	                BEGIN
	                    SELECT ag.cagente
	                      INTO v_agente /* validamos si el agente existe en una lista restringida*/
	                      FROM lre_personas lre,agentes ag
	                     WHERE lre.sperson=ag.sperson AND
	                           lre.cclalis=2 AND
	                           lre.ctiplis=48 AND
	                           lre.finclus<f_sysdate AND
	                           lre.sperson=reg.sperson;
	                EXCEPTION
	                    WHEN no_data_found THEN
	                      v_agente:=0;
	                END;

	                IF (v_agente>0) THEN /* si esta en lista restringida inserta en remesas_previo_lre, y si*/
	                  SELECT count(sclave)
	                    INTO v_exis_resgistro
	                    FROM remesas_previo_lre rpl
	                   WHERE cabono=reg.cbancar AND
	                         iimport=reg.iimporte AND
	                         fabono=w_fecha AND
	                         cempres=reg.cempres AND
	                         spago=reg.spago;

	                  IF (v_exis_resgistro<=0) THEN /* si no existe previo el registrp se inserta*/
	                    SELECT sremesa_previo_lre.NEXTVAL
	                      INTO w_secuencia_remesa
	                      FROM dual;

	                    BEGIN
			INSERT INTO remesas_previo_lre
		           (sclave,cempres,cabono,iimport,fabono,nrecibo,
		           nsinies,sidepag,nrentas,sseguro,nreemb,
		           nfact,spago,ctapres,cagente,clisres,
		           flisres,ulisres)
		    VALUES
		           (w_secuencia_remesa,reg.cempres,reg.cbancar,reg.iimporte,w_fecha,NULL,
		           NULL,NULL,NULL,NULL,NULL,
		           NULL,reg.spago,NULL,v_agente,1,
		           f_sysdate,f_user);

	                    EXCEPTION
	                        WHEN dup_val_on_index THEN
	                          w_ttexto:=f_axis_literales(9908574, pcidioma);

	                          p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 140, f_axis_literales(9001843, pcidioma)
	                                                                                                            || '. '
	                                                                                                            || f_axis_literales(109005, pcidioma)
	                                                                                                            || '. '
	                                                                                                            || w_ttexto, SQLERRM);

	                          w_error:=f_proceslin(w_sproces, substr(f_axis_literales(9001843, pcidioma)
	                                                                 || '. '
	                                                                 || f_axis_literales(109005, pcidioma)
	                                                                 || ' -> '
	                                                                 || reg.spago, 1, 120), reg.spago, w_cerror);

	                          v_duplicats:=1;
	                        WHEN OTHERS THEN
	                          w_ttexto:=f_axis_literales(9908574, pcidioma);

	                          p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 141, f_axis_literales(109005, pcidioma)
	                                                                                                            || '. '
	                                                                                                            || w_ttexto, SQLERRM);

	                          w_error:=f_proceslin(w_sproces, f_axis_literales(109005, pcidioma)
	                                                          || '. '
	                                                          || w_ttexto, reg.spago, w_cerror);
	                    END;
	                  END IF;
	                ELSE BEGIN
	                      SELECT clisres
	                        INTO v_clisres
	                        FROM remesas_previo_lre rpl
	                       WHERE cabono=reg.cbancar AND
	                             iimport=reg.iimporte AND
	                             fabono=w_fecha AND
	                             cempres=reg.cempres AND
	                             spago=reg.spago;
	                  EXCEPTION
	                      WHEN OTHERS THEN
	                        v_clisres:=0;
	                  END; IF (v_clisres <> 2) THEN /* se valida que la transferencia no este cancelada*/
	                /*Seleccionem la sequencia per el numero de la remesa*/

		    SELECT
		           sremesa_previo.NEXTVAL INTO w_secuencia
		      FROM
		dual; BEGIN INSERT INTO remesas_previo
		           (sremesa, ccc, ctipban, nrecibo, nsinies, sidepag,
		           nrentas, cabono, iimport, ctipban_abono, sseguro,
		           catribu, sproduc, fabono, nremesa, ftransf,
		           cempres, sperson, ccobban, nreemb, nfact,
		           nlinea, ctipo, spago)
		    VALUES
		           (w_secuencia, w_scuecar, w_ctipban, NULL, NULL, NULL,
		           NULL, reg.cbancar, reg.iimporte, reg.ctipban, NULL,
		           reg.tipo_transfer, NULL, w_fecha, NULL, NULL,
		           reg.cempres, reg.sperson, v_ccobban, NULL, NULL,
		           NULL, NULL, reg.spago); EXCEPTION WHEN dup_val_on_index THEN w_ttexto := f_axis_literales(9002226, pcidioma); p_tab_error(f_sysdate, f_user,
		           'pac_transferencias.f_insert_remesas_previo', 142, f_axis_literales(9001843, pcidioma)|| '. '|| f_axis_literales(9907896, pcidioma)|| '. '|| w_ttexto,
		           SQLERRM); w_error := f_proceslin(w_sproces, substr(f_axis_literales(9001843, pcidioma)|| '. '|| f_axis_literales(9907896, pcidioma)|| ' -> '|| reg.spago, 1,
		           120), reg.spago, w_cerror)

	                ;
	                v_duplicats
	                := 1; WHEN OTHERS THEN w_ttexto := f_axis_literales(9002226, pcidioma); p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', 143, f_axis_literales(9907896, pcidioma)|| '. '|| w_ttexto, SQLERRM); w_error := f_proceslin(w_sproces, f_axis_literales(9907896, pcidioma)|| '. '|| w_ttexto, reg.spago, w_cerror); END; END IF;
	                END IF;
	              END IF;
	          END LOOP;
	        END IF;

	        v_traza:=13;

	        /* Solo devolvemos el númeor de proceso cuando detectamos que ha habído algún error, para avisar al usuario.*/
	        SELECT count(1)
	          INTO w_cerror
	          FROM procesoslin
	         WHERE sproces=w_sproces;

	        num_err:=f_procesfin(w_sproces, w_cerror);

	        IF w_cerror>0 THEN
	          pprocesolin:=w_sproces;
	        END IF;

	        v_traza:=14;

	        /* BUG11396:DRA:20/01/2010: Si hi han registres ja tractantse retornem -1*/
	        IF v_duplicats=1 THEN
	          num_err:=-1;
	        END IF;

	        RETURN num_err;
	    EXCEPTION
	        WHEN OTHERS THEN
	          p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_insert_remesas_previo', v_traza, 'error no controlado - '
	                                                                                                || param, SQLERRM);

	          SELECT count(1)
	            INTO w_cerror
	            FROM procesoslin
	           WHERE sproces=w_sproces;

	          num_err:=f_procesfin(w_sproces, w_cerror);

	          RETURN 140999;
	    END;
	END f_insert_remesas_previo; /*ozea*/

	/***********************************************************************
	  Función que nos devuelve los registros de la tabla remesas_previo por usuario
	  return             : 0 OK , 1 error
	***********************************************************************/
	FUNCTION f_get_transferencias(
			pcempres	IN	NUMBER,
			pagrupacion	IN	NUMBER,
			pcramo	IN	NUMBER,
			psproduc	IN	NUMBER,
			pfabonoini	IN	DATE,
			pfabonofin	IN	DATE,
			pftransini	IN	DATE,
			pftransfin	IN	DATE,
			pctransferidos	IN	NUMBER,
			pctipobusqueda	IN	VARCHAR2,
			pnremesa	IN	NUMBER,
			pccc	IN	VARCHAR2,
			pidioma	IN	NUMBER,
			psquery	OUT	VARCHAR2
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_transferencias.f_get_transferencias';
	  /*vparam         VARCHAR2(500) := 'parámetros - : ';*/
	  /*pos            NUMBER;*/
	  /*tipo           VARCHAR2(2000);*/
	  pwhere      VARCHAR2(4000):='';
	  /*vsquery        VARCHAR2(4000);*/
	  v_cmultimon parempresas.nvalpar%TYPE; /* Bug 19522 - APD - 11/01/2012*/
	BEGIN
	    IF pnremesa IS NOT NULL AND
	       pccc IS NOT NULL THEN
	      pwhere:=' and r.nremesa = '
	              || pnremesa
	              || ' and r.ccc = '
	              || chr(39)
	              || pccc
	              || chr(39);
	    END IF;

	    /* Bug 19522 - APD - 11/01/2012*/
	    v_cmultimon:=nvl(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0);

	    IF v_cmultimon=0 THEN /* No es multimoneda*/
	      psquery:='select sremesa, nremesa, sproduc, sseguro, npoliza, cmarcado,'
	               || 'catribu, tconcepte, fabono, ccc, cabono, iimport, ttitulo,'
	               || 'nrecibo, nsinies, sidepag, nreemb, nfact, nlinea, nrentas,'
	               || 'tfichero, ftransf, '
	               || 'cestado, csubestado, descripcion, cmoneda, fcambio, cmoneda_t, itasa, chiimport FROM ('
	               || 'select r.sremesa,  r.nremesa, r.sproduc, r.sseguro,'
	               || 'f_formatopol(s.npoliza , s.ncertif,1) npoliza, r.cmarcado,'
	               || 'r.catribu, ff_desvalorfijo(701,'
	               || pidioma
	               || ',r.catribu) tconcepte,'
	               || 'r.fabono, r.ccc, r.cabono, r.iimport,'
	               || 'f_desproducto_t(s.cramo,s.cmodali,s.ctipseg,s.ccolect,1,'
	               || pidioma
	               || ') ttitulo, r.nrecibo, r.nsinies, r.sidepag, r.nreemb,'
	               || 'r.nfact, r.nlinea, r.nrentas, r.tfichero, r.ftransf, '
	               || 'r.cestado, r.csubestado, r.descripcion, r.cmoneda, r.fcambio, '
	               || 'r.cmoneda CMONEDA_T, '
	               || '1 ITASA, '
	               || 'iimport CHIIMPORT'
	               || ' FROM remesas_previo r, seguros s'
	               || ' WHERE s.sseguro = r.sseguro and r.cusuario = '
	               || chr(39)
	               || f_user
	               || chr(39)
	               || pwhere
	               || ' UNION ALL '
	               || 'select r.sremesa,  r.nremesa, r.sproduc, r.sseguro,'
	               || 'NULL npoliza, r.cmarcado,'
	               || 'r.catribu, ff_desvalorfijo(701,'
	               || pidioma
	               || ',r.catribu) tconcepte,'
	               || 'r.fabono, r.ccc, r.cabono, r.iimport,'
	               || 'p.cagente||'''
	               || ' '
	               || '''||f_desagente_t (p.cagente) ttitulo, r.nrecibo,'
	               || 'r.nsinies, r.sidepag, r.nreemb,'
	               || 'r.nfact, r.nlinea, r.nrentas, r.tfichero, r.ftransf, '
	               || 'r.cestado, r.csubestado, r.descripcion, r.cmoneda, r.fcambio, '
	               || 'r.cmoneda CMONEDA_T, '
	               || '1 ITASA, '
	               || 'iimport CHIIMPORT'
	               || ' FROM remesas_previo r, pagoscomisiones p'
	               || ' WHERE p.spago = r.spago and r.cusuario = '
	               || chr(39)
	               || f_user
	               || chr(39)
	               || pwhere
	               || ' UNION ALL '
	               || 'select r.sremesa,  r.nremesa, r.sproduc, r.sseguro,'
	               || 'NULL npoliza, r.cmarcado,'
	               || 'r.catribu, ff_desvalorfijo(701,'
	               || pidioma
	               || ',r.catribu) tconcepte,'
	               || 'r.fabono, r.ccc, r.cabono, r.iimport,'
	               || 'NULL ttitulo, r.nrecibo,'
	               || 'r.nsinies, r.sidepag, r.nreemb,'
	               || 'r.nfact, r.nlinea, r.nrentas, r.tfichero, r.ftransf, '
	               || 'r.cestado, r.csubestado, r.descripcion, r.cmoneda, r.fcambio, '
	               || 'r.cmoneda CMONEDA_T, '
	               || '1 ITASA, '
	               || 'iimport CHIIMPORT'
	               || ' FROM remesas_previo r, pagos_ctatec_rea pr'
	               || ' WHERE pr.spagrea = r.spago and r.cusuario = '
	               || chr(39)
	               || f_user
	               || chr(39)
	               || pwhere
	               || ' UNION ALL '
	               || 'select r.sremesa,  r.nremesa, r.sproduc, r.sseguro,'
	               || 'NULL npoliza, r.cmarcado,'
	               || 'r.catribu, ff_desvalorfijo(701,'
	               || pidioma
	               || ',r.catribu) tconcepte,'
	               || 'r.fabono, r.ccc, r.cabono, r.iimport,'
	               || 'NULL ttitulo, r.nrecibo,'
	               || 'r.nsinies, r.sidepag, r.nreemb,'
	               || 'r.nfact, r.nlinea, r.nrentas, r.tfichero, r.ftransf, '
	               || 'r.cestado, r.csubestado, r.descripcion, r.cmoneda, r.fcambio, '
	               || 'r.cmoneda CMONEDA_T, '
	               || '1 ITASA, '
	               || 'iimport CHIIMPORT'
	               || ' FROM remesas_previo r, pagos_ctatec_coa pc'
	               || ' WHERE pc.spagcoa = r.spago and r.cusuario = '
	               || chr(39)
	               || f_user
	               || chr(39)
	               || pwhere
	               || ' UNION ALL '
	               || 'select r.sremesa,  r.nremesa, r.sproduc, r.sseguro,'
	               || 'NULL npoliza, r.cmarcado,'
	               || 'r.catribu, ff_desvalorfijo(701,'
	               || pidioma
	               || ',r.catribu) tconcepte,'
	               || 'r.fabono, r.ccc, r.cabono, r.iimport,'
	               || 'NULL ttitulo, r.nrecibo,'
	               || 'r.nsinies, r.sidepag, r.nreemb,'
	               || 'r.nfact, r.nlinea, r.nrentas, r.tfichero, r.ftransf, '
	               || 'r.cestado, r.csubestado, r.descripcion, r.cmoneda, r.fcambio, '
	               || 'r.cmoneda CMONEDA_T, '
	               || '1 ITASA, '
	               || 'iimport CHIIMPORT'
	               || ' FROM remesas_previo r, pagoctacliente pe'
	               || ' WHERE pe.spago = r.spago and r.cusuario = '
	               || chr(39)
	               || f_user
	               || chr(39)
	               || pwhere
	               || ')'; --33886
	    ELSE
	    /* fin Bug 19522 - APD - 11/01/2012*/
	      /* BUG14344:DRA:10/05/2010:Inici*/
	      psquery:='select sremesa, nremesa, sproduc, sseguro, npoliza, cmarcado,'
	               || 'catribu, tconcepte, fabono, ccc, cabono, iimport, ttitulo,'
	               || 'nrecibo, nsinies, sidepag, nreemb, nfact, nlinea, nrentas,'
	               || 'tfichero, ftransf, '
	               || 'cestado, csubestado, descripcion, cmoneda, fcambio, cmoneda_t, itasa, chiimport FROM ('
	               || 'select r.sremesa,  r.nremesa, r.sproduc, r.sseguro,'
	               || 'f_formatopol(s.npoliza , s.ncertif,1) npoliza, r.cmarcado,'
	               || 'r.catribu, ff_desvalorfijo(701,'
	               || pidioma
	               || ',r.catribu) tconcepte,'
	               || 'r.fabono, r.ccc, r.cabono, r.iimport,'
	               || 'f_desproducto_t(s.cramo,s.cmodali,s.ctipseg,s.ccolect,1,'
	               || pidioma
	               || ') ttitulo, r.nrecibo, r.nsinies, r.sidepag, r.nreemb,'
	               || 'r.nfact, r.nlinea, r.nrentas, r.tfichero, r.ftransf, '
	               || 'r.cestado, r.csubestado, r.descripcion, r.cmoneda, r.fcambio, '
	               || 'pac_monedas.f_cmoneda_t(NVL(r.cmoneda, f_parinstalacion_n(''MONEDAINST''))) CMONEDA_T, '
	               || 'pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(f_parinstalacion_n(''MONEDAINST'')), '
	               || 'pac_monedas.f_cmoneda_t(NVL(r.cmoneda, f_parinstalacion_n(''MONEDAINST''))), '
	               || 'pac_eco_tipocambio.f_fecha_max_cambio(pac_monedas.f_cmoneda_t(f_parinstalacion_n(''MONEDAINST'')), '
	               || 'pac_monedas.f_cmoneda_t(NVL(r.cmoneda, f_parinstalacion_n(''MONEDAINST''))), '
	               || 'r.fcambio)) ITASA, '
	               || 'iimport * pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(f_parinstalacion_n(''MONEDAINST'')), '
	               || 'pac_monedas.f_cmoneda_t(NVL(r.cmoneda, f_parinstalacion_n(''MONEDAINST''))), '
	               || 'pac_eco_tipocambio.f_fecha_max_cambio(pac_monedas.f_cmoneda_t(f_parinstalacion_n(''MONEDAINST'')), '
	               || 'pac_monedas.f_cmoneda_t(NVL(r.cmoneda, f_parinstalacion_n(''MONEDAINST''))), '
	               || 'r.fcambio)) CHIIMPORT'
	               || ' FROM remesas_previo r, seguros s'
	               || ' WHERE s.sseguro = r.sseguro and r.cusuario = '
	               || chr(39)
	               || f_user
	               || chr(39)
	               || pwhere
	               || ' UNION ALL '
	               || 'select r.sremesa,  r.nremesa, r.sproduc, r.sseguro,'
	               || 'NULL npoliza, r.cmarcado,'
	               || 'r.catribu, ff_desvalorfijo(701,'
	               || pidioma
	               || ',r.catribu) tconcepte,'
	               || 'r.fabono, r.ccc, r.cabono, r.iimport,'
	               || 'p.cagente||'''
	               || ' '
	               || '''||f_desagente_t (p.cagente) ttitulo, r.nrecibo,'
	               || 'r.nsinies, r.sidepag, r.nreemb,'
	               || 'r.nfact, r.nlinea, r.nrentas, r.tfichero, r.ftransf, '
	               || 'r.cestado, r.csubestado, r.descripcion, r.cmoneda, r.fcambio, '
	               || 'pac_monedas.f_cmoneda_t(NVL(r.cmoneda, f_parinstalacion_n(''MONEDAINST''))) CMONEDA_T, '
	               || 'pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(f_parinstalacion_n(''MONEDAINST'')), '
	               || 'pac_monedas.f_cmoneda_t(NVL(r.cmoneda, f_parinstalacion_n(''MONEDAINST''))), '
	               || 'pac_eco_tipocambio.f_fecha_max_cambio(pac_monedas.f_cmoneda_t(f_parinstalacion_n(''MONEDAINST'')), '
	               || 'pac_monedas.f_cmoneda_t(NVL(r.cmoneda, f_parinstalacion_n(''MONEDAINST''))), '
	               || 'r.fcambio)) ITASA, '
	               || 'iimport * pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(f_parinstalacion_n(''MONEDAINST'')), '
	               || 'pac_monedas.f_cmoneda_t(NVL(r.cmoneda, f_parinstalacion_n(''MONEDAINST''))), '
	               || 'pac_eco_tipocambio.f_fecha_max_cambio(pac_monedas.f_cmoneda_t(f_parinstalacion_n(''MONEDAINST'')), '
	               || 'pac_monedas.f_cmoneda_t(NVL(r.cmoneda, f_parinstalacion_n(''MONEDAINST''))), '
	               || 'r.fcambio)) CHIIMPORT'
	               || ' FROM remesas_previo r, pagoscomisiones p'
	               || ' WHERE p.spago = r.spago and r.cusuario = '
	               || chr(39)
	               || f_user
	               || chr(39)
	               || pwhere
	               || ' UNION ALL '
	               || 'select r.sremesa,  r.nremesa, r.sproduc, r.sseguro,'
	               || 'NULL npoliza, r.cmarcado,'
	               || 'r.catribu, ff_desvalorfijo(701,'
	               || pidioma
	               || ',r.catribu) tconcepte,'
	               || 'r.fabono, r.ccc, r.cabono, r.iimport,'
	               || 'null ttitulo, r.nrecibo,' --rdd
	               || 'r.nsinies, r.sidepag, r.nreemb,'
	               || 'r.nfact, r.nlinea, r.nrentas, r.tfichero, r.ftransf, '
	               || 'r.cestado, r.csubestado, r.descripcion, r.cmoneda, r.fcambio, '
	               || 'pac_monedas.f_cmoneda_t(NVL(r.cmoneda, f_parinstalacion_n(''MONEDAINST''))) CMONEDA_T, '
	               || 'pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(f_parinstalacion_n(''MONEDAINST'')), '
	               || 'pac_monedas.f_cmoneda_t(NVL(r.cmoneda, f_parinstalacion_n(''MONEDAINST''))), '
	               || 'pac_eco_tipocambio.f_fecha_max_cambio(pac_monedas.f_cmoneda_t(f_parinstalacion_n(''MONEDAINST'')), '
	               || 'pac_monedas.f_cmoneda_t(NVL(r.cmoneda, f_parinstalacion_n(''MONEDAINST''))), '
	               || 'r.fcambio)) ITASA, '
	               || 'iimport * pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(f_parinstalacion_n(''MONEDAINST'')), '
	               || 'pac_monedas.f_cmoneda_t(NVL(r.cmoneda, f_parinstalacion_n(''MONEDAINST''))), '
	               || 'pac_eco_tipocambio.f_fecha_max_cambio(pac_monedas.f_cmoneda_t(f_parinstalacion_n(''MONEDAINST'')), '
	               || 'pac_monedas.f_cmoneda_t(NVL(r.cmoneda, f_parinstalacion_n(''MONEDAINST''))), '
	               || 'r.fcambio)) CHIIMPORT'
	               || ' FROM remesas_previo r, pagos_ctatec_rea pr'
	               || ' WHERE pr.spagrea = r.spago and r.cusuario = '
	               || chr(39)
	               || f_user
	               || chr(39)
	               || pwhere
	               || ' UNION ALL '
	               || 'select r.sremesa,  r.nremesa, r.sproduc, r.sseguro,'
	               || 'NULL npoliza, r.cmarcado,'
	               || 'r.catribu, ff_desvalorfijo(701,'
	               || pidioma
	               || ',r.catribu) tconcepte,'
	               || 'r.fabono, r.ccc, r.cabono, r.iimport,'
	               || 'null ttitulo, r.nrecibo,' --rdd
	               || 'r.nsinies, r.sidepag, r.nreemb,'
	               || 'r.nfact, r.nlinea, r.nrentas, r.tfichero, r.ftransf, '
	               || 'r.cestado, r.csubestado, r.descripcion, r.cmoneda, r.fcambio, '
	               || 'pac_monedas.f_cmoneda_t(NVL(r.cmoneda, f_parinstalacion_n(''MONEDAINST''))) CMONEDA_T, '
	               || 'pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(f_parinstalacion_n(''MONEDAINST'')), '
	               || 'pac_monedas.f_cmoneda_t(NVL(r.cmoneda, f_parinstalacion_n(''MONEDAINST''))), '
	               || 'pac_eco_tipocambio.f_fecha_max_cambio(pac_monedas.f_cmoneda_t(f_parinstalacion_n(''MONEDAINST'')), '
	               || 'pac_monedas.f_cmoneda_t(NVL(r.cmoneda, f_parinstalacion_n(''MONEDAINST''))), '
	               || 'r.fcambio)) ITASA, '
	               || 'iimport * pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(f_parinstalacion_n(''MONEDAINST'')), '
	               || 'pac_monedas.f_cmoneda_t(NVL(r.cmoneda, f_parinstalacion_n(''MONEDAINST''))), '
	               || 'pac_eco_tipocambio.f_fecha_max_cambio(pac_monedas.f_cmoneda_t(f_parinstalacion_n(''MONEDAINST'')), '
	               || 'pac_monedas.f_cmoneda_t(NVL(r.cmoneda, f_parinstalacion_n(''MONEDAINST''))), '
	               || 'r.fcambio)) CHIIMPORT'
	               || ' FROM remesas_previo r, pagos_ctatec_coa pc'
	               || ' WHERE pc.spagcoa = r.spago and r.cusuario = '
	               || chr(39)
	               || f_user
	               || chr(39)
	               || pwhere
	               || ' UNION ALL '
	               || 'select r.sremesa,  r.nremesa, r.sproduc, r.sseguro,'
	               || 'to_char (s.npoliza) npoliza, r.cmarcado,'
	               || 'r.catribu, ff_desvalorfijo(701,'
	               || pidioma
	               || ',r.catribu) tconcepte,'
	               || 'r.fabono, r.ccc, r.cabono, r.iimport,'
	               || 'f_desproducto_t(s.cramo,s.cmodali,s.ctipseg,s.ccolect,1,'
	               || pidioma
	               || ') ttitulo, r.nrecibo,' --rdd
	               || 'r.nsinies, r.sidepag, r.nreemb,'
	               || 'r.nfact, r.nlinea, r.nrentas, r.tfichero, r.ftransf, '
	               || 'r.cestado, r.csubestado, r.descripcion, r.cmoneda, r.fcambio, '
	               || 'pac_monedas.f_cmoneda_t(NVL(r.cmoneda, f_parinstalacion_n(''MONEDAINST''))) CMONEDA_T, '
	               || 'pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(f_parinstalacion_n(''MONEDAINST'')), '
	               || 'pac_monedas.f_cmoneda_t(NVL(r.cmoneda, f_parinstalacion_n(''MONEDAINST''))), '
	               || 'pac_eco_tipocambio.f_fecha_max_cambio(pac_monedas.f_cmoneda_t(f_parinstalacion_n(''MONEDAINST'')), '
	               || 'pac_monedas.f_cmoneda_t(NVL(r.cmoneda, f_parinstalacion_n(''MONEDAINST''))), '
	               || 'r.fcambio)) ITASA, '
	               || 'iimport * pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(f_parinstalacion_n(''MONEDAINST'')), '
	               || 'pac_monedas.f_cmoneda_t(NVL(r.cmoneda, f_parinstalacion_n(''MONEDAINST''))), '
	               || 'pac_eco_tipocambio.f_fecha_max_cambio(pac_monedas.f_cmoneda_t(f_parinstalacion_n(''MONEDAINST'')), '
	               || 'pac_monedas.f_cmoneda_t(NVL(r.cmoneda, f_parinstalacion_n(''MONEDAINST''))), '
	               || 'r.fcambio)) CHIIMPORT'
	               || ' FROM remesas_previo r, pagoctacliente pe, seguros s '
	               || ' WHERE pe.spago = r.spago and s.sseguro(+) = pe.sseguro and r.cusuario = '
	               || chr(39)
	               || f_user
	               || chr(39)
	               || pwhere
	               || ')'; --3886
	    /* BUG14344:DRA:10/05/2010:Fi*/
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, 1, 'error no controlado', psquery
	                                                                                   || '  Error = '
	                                                                                   || SQLERRM);

	             RETURN 1;
	END f_get_transferencias;

	/***********************************************************************
	   Función que nos actualiza la tabla, si le pasamos un sremesa actualiza solo
	   el registro con marcado, si no le pasamos el sremesa se marcan o desmarcan todos
	   return             : 0 OK , 1 error
	***********************************************************************/
	FUNCTION f_actualiza_remesas_previo(
			psremesa	IN	NUMBER,
			pcmarcado	IN	NUMBER
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_transferencias.f_actualiza_remesas_previo';
	/*vparam         VARCHAR2(500) := 'parámetros - : ';*/
	BEGIN
	/*Bug 37495-212892 KJSC -28/08/2015- Al marcar la "check" va muy lento.*/
	    /*UPDATE remesas_previo
	       SET cmarcado = pcmarcado
	     WHERE (psremesa IS NULL
	            OR(psremesa IS NOT NULL
	               AND sremesa = psremesa));*/
	    IF psremesa IS NULL THEN
	      UPDATE remesas_previo
	         SET cmarcado=pcmarcado;
	    ELSE
	      UPDATE remesas_previo
	         SET cmarcado=pcmarcado
	       WHERE sremesa=psremesa;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, 1, 'error no controlado', SQLERRM);

	             RETURN 1;
	END f_actualiza_remesas_previo;

	/***********************************************************************
	  Función que nos devuelve el total de los registros marcados en remesas_previo
	  return             : 0 OK , 1 error
	***********************************************************************/
	FUNCTION f_get_total(
			pnremesa	IN	NUMBER,
			pccc	IN	VARCHAR2,
			ptotal	OUT	NUMBER
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_transferencias.f_get_total';
	  /*vparam         VARCHAR2(500) := 'parámetros - : ';*/
	  vsquery     VARCHAR2(500);
	  cur         SYS_REFCURSOR;
	BEGIN
	    /* Bug 21447/108362 - 27/02/2012 -AMC*/
	    vsquery:=' SELECT SUM(iimport)
	                   FROM remesas_previo
	                   WHERE cmarcado = 1
	                   AND cusuario ='
	             || chr(39)
	             || f_user
	             || chr(39);

	    IF pnremesa IS NOT NULL THEN
	      vsquery:=vsquery
	               || ' AND nremesa ='
	               || pnremesa;
	    END IF;

	    IF pccc IS NOT NULL THEN
	      vsquery:=vsquery
	               || ' AND ccc ='
	               || chr(39)
	               || pccc
	               || chr(39);
	    END IF;

	    OPEN cur FOR vsquery;

	    LOOP
	        FETCH cur INTO ptotal;

	        EXIT WHEN cur%NOTFOUND;
	    END LOOP;

	    CLOSE cur;

	    /* Fi Bug 21447/108362 - 27/02/2012 -AMC*/
	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, 1, 'error no controlado', SQLERRM);

	             RETURN 1;
	END f_get_total;
	FUNCTION f_cuenramo(
			pccobban	IN	NUMBER,
			psproduc	IN	NUMBER
	) RETURN NUMBER
	IS
	  /*JRH Hemos de distinguir el ramo puesto que las cuentas pueen ser iguales*/
	  xcramo   NUMBER;
	  xcmodali NUMBER;
	  xctipseg NUMBER;
	  xccolect NUMBER;
	  dummy    NUMBER;
	BEGIN
	    SELECT cramo,cmodali,ctipseg,ccolect
	      INTO xcramo, xcmodali, xctipseg, xccolect
	      FROM productos
	     WHERE sproduc=psproduc;

	    SELECT 1
	      INTO dummy
	      FROM cobbancariosel
	     WHERE ccobban=pccobban AND
	           ((cramo=xcramo AND
	             cramo IS NOT NULL)  OR
	            (cramo IS NULL)) AND
	           ((cmodali=xcmodali AND
	             cmodali IS NOT NULL)  OR
	            (cmodali IS NULL)) AND
	           ((ctipseg=xctipseg AND
	             ctipseg IS NOT NULL)  OR
	            (ctipseg IS NULL)) AND
	           ((ccolect=xccolect AND
	             ccolect IS NOT NULL)  OR
	            (ccolect IS NULL));

	    RETURN(1);
	EXCEPTION
	  WHEN no_data_found THEN
	             RETURN 0; WHEN too_many_rows THEN
	             RETURN(1); WHEN OTHERS THEN
	             RETURN 0;
	END;

	/***********************************************************************
	  Función que nos devuelve las descripciones de los bancos
	  return             : 0 OK , 1 error
	***********************************************************************/
	FUNCTION f_get_cuentas(
			pnremesa	IN	NUMBER,
			pccc	IN	VARCHAR2,
			vsquery	OUT	VARCHAR2
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_transferencias.f_get_cuentas';
	  /*vparam         VARCHAR2(500) := 'parámetros - : ';*/
	  vwhere      VARCHAR2(500):='';
	BEGIN
	    IF pnremesa IS NOT NULL AND
	       pccc IS NOT NULL THEN
	      vwhere:=' and r.nremesa = '
	              || pnremesa
	              || ' and r.ccc = '
	              || chr(39)
	              || pccc
	              || chr(39);
	    END IF;

	    vsquery:='SELECT ncuenta, descripcion, SUM(iimport) iimport, tfichero
	FROM (
	 SELECT sum(r.iimport) iimport, c.ncuenta, c.descripcion, NULL tfichero
	      FROM remesas_previo r, cobbancario c
	     WHERE r.cempres = pac_md_common.f_get_cxtempresa
	       AND r.cusuario = f_user
	       AND r.cmarcado = 1
	       AND r.ctipoproceso = 1 '
	             || vwhere
	             || ' AND c.ccobban = r.ccobban
	       AND c.cempres = r.cempres
	  GROUP BY c.ncuenta, c.descripcion
	 UNION
	 SELECT sum(r.iimport) iimport, c.ncuenta, c.descripcion, f_parinstalacion_t(''TRANSFERENCIAS_C'')||''\''||f.nfichero tfichero
	      FROM remesas_previo r, cobbancario c, ficherosremesa f
	     WHERE r.cempres = pac_md_common.f_get_cxtempresa
	       AND r.cusuario = f_user
	       AND r.cmarcado = 1 '
	             || vwhere
	             || ' AND NVL (r.ctipoproceso, 0) <> 1
	       AND c.ccobban = r.ccobban
	       AND c.cempres = r.cempres
	       AND f.ncuenta = r.ccc
	       AND f.nremesa = r.nremesa
	       AND f.nmovimi = (SELECT MAX(nmovimi)
	                          FROM ficherosremesa fr
	                         WHERE fr.nremesa = r.nremesa
	                           AND fr.ncuenta = r.ccc)
	  GROUP BY c.ncuenta, c.descripcion, f.nfichero
	 UNION
	 SELECT sum(r.iimport) iimport, c.ncuenta, c.descripcion, NULL tfichero
	      FROM remesas_previo r, cobbancario c
	     WHERE r.cempres = pac_md_common.f_get_cxtempresa
	       AND r.cusuario = f_user
	       AND r.cmarcado = 1 '
	             || vwhere
	             || ' AND NVL (r.ctipoproceso, 0) <> 1
	       AND c.ccobban = r.ccobban
	       AND c.cempres = r.cempres
	       AND (r.ccc, r.nremesa) NOT IN (SELECT fr.ncuenta, fr.nremesa
	                                       FROM ficherosremesa fr
	                                      WHERE fr.nremesa = r.nremesa)
	  GROUP BY c.ncuenta, c.descripcion
	 UNION
	  SELECT NULL iimport, c.ncuenta, c.descripcion, NULL tfichero
	    FROM cobbancario c
	   WHERE c.cempres = pac_md_common.f_get_cxtempresa
	     AND c.ncuenta NOT IN (SELECT r.ccc
	                             FROM remesas_previo r
	                             WHERE r.cempres = pac_md_common.f_get_cxtempresa '
	             || vwhere
	             || ' AND r.cusuario = f_user
	                               AND r.cmarcado = 1))
	GROUP BY ncuenta, descripcion, tfichero
	ORDER BY ncuenta, descripcion, tfichero';

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, 1, 'error no controlado', vsquery
	                                                                                   || '  Error =  '
	                                                                                   || SQLERRM);

	             RETURN 1;
	END f_get_cuentas;

	/***********************************************************************
	  Función que nos devuelve la cuenta de cargo, el producto, el tipo de banco y el ccobban
	  return             : 0 OK , 1 error
	***********************************************************************/
	FUNCTION f_get_ctacargo(pcempres	IN	NUMBER,/* BUG14344:DRA:05/05/2010*/psseguro	IN	NUMBER,pcconcep	IN	NUMBER,p_ccc_abono	IN	VARCHAR2,/* BUG11396:DRA:14/01/2010*/p_ctipban_abono	IN	NUMBER,/* BUG11396:DRA:14/01/2010*/w_producto	OUT	NUMBER,w_cuenta	OUT	VARCHAR2,w_ctipban	OUT	VARCHAR2,v_ccobban	OUT	NUMBER)
	RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_transferencias.f_get_ctacargo';
	  /*vparam         VARCHAR2(500) := 'parámetros - psseguro : ' || psseguro || ', p_ccc_abono: ' || p_ccc_abono || ', p_ctipban_abono: ' || p_ctipban_abono;*/
	  vcramo      NUMBER;
	  vcmodali    NUMBER;
	  vctipseg    NUMBER;
	  vccolect    NUMBER;
	  vcagente    NUMBER;
	  /* Bug 18225 - APD - 11/04/2011 - la precisión debe ser NUMBER*/
	  /*vcbancar       VARCHAR2(40);*/
	  /*vctipban       VARCHAR2(40);*/
	  /*vnum_err       NUMBER;*/
	  vtraza      NUMBER;
	BEGIN
	    BEGIN
	        vtraza:=1;

	        BEGIN
	            SELECT s.sproduc,cb.ncuenta,cb.ctipban,pc.ccobban
	              INTO w_producto, w_cuenta, w_ctipban, v_ccobban
	              FROM seguros s,prodctacargo pc,cobbancario cb /* BUG11396:DRA:14/01/2010*/
	             WHERE s.sseguro=psseguro AND
	                   pc.sproduc=s.sproduc AND
	                   pc.cconcep=pcconcep AND
	                   cb.ccobban=pc.ccobban; /* BUG11396:DRA:14/01/2010*/
	        EXCEPTION
	            WHEN no_data_found THEN BEGIN
	                  /* Concepto generico*/
	                  SELECT s.sproduc,cb.ncuenta,cb.ctipban,pc.ccobban
	                    INTO w_producto, w_cuenta, w_ctipban, v_ccobban
	                    FROM seguros s,prodctacargo pc,cobbancario cb /* BUG11396:DRA:14/01/2010*/
	                   WHERE s.sseguro=psseguro AND
	                         pc.sproduc=s.sproduc AND
	                         pc.cconcep=0 AND
	                         cb.ccobban=pc.ccobban; /* BUG11396:DRA:14/01/2010*/
	              EXCEPTION
	                  WHEN no_data_found THEN
	                    /* Concepto generico y producto generico*/
	                    SELECT s.sproduc,cb.ncuenta,cb.ctipban,pc.ccobban
	                      INTO w_producto, w_cuenta, w_ctipban, v_ccobban
	                      FROM seguros s,prodctacargo pc,cobbancario cb /* BUG11396:DRA:14/01/2010*/
	                     WHERE s.sseguro=psseguro AND
	                           pc.sproduc=0 AND
	                           pc.cconcep=0 AND
	                           cb.ccobban=pc.ccobban;
	              /* BUG11396:DRA:14/01/2010*/
	              END;
	        END;

	        vtraza:=2;
	    EXCEPTION
	        WHEN OTHERS THEN
	          vtraza:=3;

	          BEGIN
	              SELECT cramo,cmodali,ctipseg,ccolect,cagente,s.ccobban,sproduc,cb.ncuenta,cb.ctipban
	                INTO vcramo, vcmodali, vctipseg, vccolect,
	              vcagente, v_ccobban, w_producto, w_cuenta, w_ctipban
	                FROM seguros s,cobbancario cb
	               WHERE sseguro=psseguro AND
	                     s.ccobban=cb.ccobban;
	          EXCEPTION
	              WHEN no_data_found THEN
	                vtraza:=4;

	                SELECT cbs.cramo,cbs.cmodali,cbs.ctipseg,cbs.ccolect,cbs.cagente,cb.ccobban,NULL,cb.ncuenta,cb.ctipban
	                  INTO vcramo, vcmodali, vctipseg, vccolect,
	                vcagente, v_ccobban, w_producto, w_cuenta, w_ctipban
	                  FROM cobbancariosel cbs,cobbancario cb
	                 WHERE cbs.cempres=pcempres AND
	                       cbs.cramo IS NULL AND
	                       cbs.cmodali IS NULL AND
	                       cbs.ctipseg IS NULL AND
	                       cbs.ccolect IS NULL AND
	                       cb.ccobban=cbs.ccobban
	                       /*BUG 38089/215886:IPH 15/10/2015*/
	                       AND
	                       cb.cbaja=0
	                       /*-------------------------------------*/
	                       AND
	                       ROWNUM=1;
	          /* BUG11396:DRA:27/01/2010:Inici*/
	          /*v_ccobban := f_buscacobban(vcramo, vcmodali, vctipseg, vccolect, vcagente,
	                                     p_ccc_abono, p_ctipban_abono, vnum_err);
	          vtraza := 5;
	          IF vnum_err <> 0 THEN
	             vtraza := 6;
	             p_tab_error(f_sysdate, f_user, vobjectname, 2,
	                         'Error buscando COBBANCARIOSEL para seguro =' || psseguro
	                         || ' - vtraza ' || vtraza || ' - vnum_err =' || vnum_err,
	                         SQLERRM);
	             RETURN 152055;
	          END IF;*/
	          /* BUG11396:DRA:27/01/2010:Fi*/
	          END;
	    END;

	    vtraza:=6;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, 1, f_axis_literales(102374, f_usu_idioma), SQLERRM);

	             RETURN 152055;
	END f_get_ctacargo;

	/* BUG12913:DRA:04/02/2010:Inici*/
	/*************************************************************************
	      Función que valida que la fecha de abono para las transferencias sea correcta
	      param in fabono    : fecha de abono
	      return             : 0 la validación ha sido correcta
	                           1 la validación no ha sido correcta
	*************************************************************************/
	FUNCTION f_valida_fabono(
			pfabono	IN	DATE,
			pterror	OUT	VARCHAR2
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_transferencias.f_valida_fabono';
	  vparam      VARCHAR2(500):='parámetros - pfabono : '
	                        || pfabono;
	  v_terror    VARCHAR2(2000);
	  v_fecha     DATE;
	BEGIN
	    IF trunc(pfabono)<trunc(f_sysdate) THEN
	      RETURN 9900996;
	    END IF;

	    v_fecha:=trunc(f_sysdate)
	             +nvl(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'DIAS_FECHA_ABONO'), 0);

	    v_terror:=f_axis_literales(9900997, f_usu_idioma);

	    v_terror:=replace(v_terror, '#1', to_char(v_fecha, 'DD/MM/YYYY'));

	    IF pfabono>v_fecha THEN
	      pterror:=v_terror;

	      RETURN 9900997;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, 1, vparam, SQLERRM);

	             RETURN 140999;
	END f_valida_fabono;

	/* BUG12913:DRA:08/02/2010:Inici*/
	/***********************************************************************
	   Función que genera de nuevo el fichero excel
	   -- Bug 0032079 - JMF - 15/07/2014
	   pprevio             : 1 = Listado previo, resto valores listado normal
	   return             : 0 OK , 1 error
	***********************************************************************/
	FUNCTION f_generar_fichero_excel(
			params_out	OUT	VARCHAR2,
			pprevio	IN	NUMBER DEFAULT NULL
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_transferencias.f_generar_fichero_excel';
	  vparam      VARCHAR2(4000):='p='
	                         || pprevio;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  params_in   VARCHAR2(100);
	  v_nomfitx   VARCHAR2(100);
	  v_fecini    DATE;
	  v_fecfin    DATE;
	  v_fabonoi   DATE;
	  v_fabonof   DATE;
	  v_nremesa   NUMBER;
	  v_map       map_cabecera.cmapead%TYPE;
	BEGIN
	    vpasexec:=10;

	    vparam:=vparam
	            || ' u='
	            || f_user
	            || ' f='
	            || trunc(f_sysdate);

	    vpasexec:=15;

	    SELECT min(ftransf),max(ftransf),min(fabono),max(fabono)
	      INTO v_fecini, v_fecfin, v_fabonoi, v_fabonof
	      FROM remesas_previo
	     WHERE cusuario=f_user AND
	           trunc(falta)=trunc(f_sysdate);

	    /* BUG12913:DRA:22/03/2010:Inici*/
	    vpasexec:=20;

	    BEGIN
	        SELECT DISTINCT nremesa
	          INTO v_nremesa
	          FROM remesas_previo
	         WHERE cusuario=f_user AND
	               trunc(falta)=trunc(f_sysdate);
	    EXCEPTION
	        WHEN OTHERS THEN
	          v_nremesa:=NULL;
	    END;

	    /* Bug 0032079 - JMF - 15/07/2014*/
	    vpasexec:=25;

	    IF pprevio=1 THEN
	      v_map:='861';
	    ELSE
	      v_map:='354';
	    END IF;

	    /* BUG12913:DRA:22/03/2010:Fi*/
	    vpasexec:=30;

	    params_in:=pac_md_common.f_get_cxtidioma
	               || '|'
	               || to_char(v_fecini, 'YYYYMMDD')
	               || '|'
	               || to_char(v_fecfin, 'YYYYMMDD')
	               || '|'
	               || to_char(v_fabonoi, 'YYYYMMDD')
	               || '|'
	               || to_char(v_fabonof, 'YYYYMMDD')
	               || '|'
	               || v_nremesa
	               || '|'
	               || pac_md_common.f_get_cxtempresa;

	    /* BUG12913:DRA:08/02/2010:Inici*/
	    /* params_out := pac_md_map.f_ejecuta(v_map, params_in, mensajes);*/
	    vpasexec:=35;

	    v_nomfitx:=pac_map.f_get_nomfichero(v_map);

	    vpasexec:=40;

	    v_nomfitx:=substr(v_nomfitx, instr(v_nomfitx, '\', -1)+1);

	    vpasexec:=45;

	    v_nomfitx:=replace(v_nomfitx, '.csv', '_'
	                                          || to_char(f_sysdate, 'DDMMYYYY')
	                                          || '_'
	                                          || to_char(f_sysdate, 'HH24MISS')
	                                          || '.csv');

	    vpasexec:=50;

	    vnumerr:=pac_map.f_extraccion(v_map, params_in, v_nomfitx, params_out);

	    /* BUG12913:DRA:08/02/2010:Fi*/
	    RETURN vnumerr;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, 'e='
	                                                                   || vnumerr
	                                                                   || ' '
	                                                                   || vparam
	                                                                   || v_nomfitx, SQLERRM);

	             RETURN 140999;
	END f_generar_fichero_excel;

	/* BUG12913:DRA:04/02/2010:Fi*/
	/* BUG12913:DRA:22/03/2010:Inici*/
	/***********************************************************************
	   Función que retorna el numero de dias de fecha de abono
	   param in cempres   : codigo de empresa
	   param out pnumdias : numero de dias
	   param out mensajes : mensajes de error
	   return             : 0 OK , 1 error
	***********************************************************************/
	FUNCTION f_get_dias_abono(
			pcempres	IN	NUMBER,
			pnumdias	OUT	NUMBER
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_transferencias.f_get_dias_abono';
	  vparam      VARCHAR2(4000):='parámetros - pcempres: '
	                         || pcempres;
	  /*vpasexec       NUMBER(5) := 1;*/
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    pnumdias:=nvl(pac_parametros.f_parempresa_n(pcempres, 'DIAS_FECHA_ABONO'), 0);

	    RETURN vnumerr;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vnumerr, vparam, SQLERRM);

	             RETURN 9000505;
	/* Error falten parametres*/
	END f_get_dias_abono;

	/* BUG12913:DRA:22/03/2010:Fi*/
	/* Ini Bug.: 13830 - ICV - 27/04/2010*/
	FUNCTION f_generacion_fichero_apra(
			pnremesa	IN	NUMBER,
			pfabono	IN	DATE
	) RETURN NUMBER
	IS
	  /*Datos de cabecera del fichero tipo 128 transfe*/
	  v_ri         VARCHAR2(1):='1';
	  /*Record Identification*/
	  v_icc        VARCHAR2(1):='1';
	  /*Interbank Clearing Code*/
	  v_rf         VARCHAR2(1):='1'; --Reserved Field
	  v_op         VARCHAR2(2):='00'; --Object of Payment
	  v_cd         VARCHAR2(6); /*Creation Date*/
	  v_cna        VARCHAR2(3);
	  /*Code Number of the Addresse financial institution*/
	  v_ac         VARCHAR2(2):='01'; --Aplication Code
	  v_edr        VARCHAR2(6):='000000';
	  /*Execution date requested*/
	  v_dup        VARCHAR(2):=' '; --Duplicate
	  v_zeros3     VARCHAR2(3):='000'; --Zeros
	  v_ocan       VARCHAR2(12); --Ordering customer's account number
	  v_ocn        VARCHAR2(26); --Ordering customer's name
	  v_oca        VARCHAR2(26); --Ordering customer's address
	  v_ocpc       VARCHAR2(4); --Ordering customer's post code
	  v_occt       VARCHAR2(22); --Ordering customer's city/town
	  v_oclc       VARCHAR2(1):='1';
	  /*Ordering Customer's Language Code*/
	  v_ref        VARCHAR2(10); /*Reference of the file*/
	  v_vc         VARCHAR2(1):='5'; --Version Code
	  w_tempres    empresas.tempres%TYPE;
	  w_tdomici    direcciones.tdomici%TYPE;
	  w_cpostal    direcciones.cpostal%TYPE;
	  w_cpoblac    direcciones.cpoblac%TYPE;
	  w_cprovin    direcciones.cprovin%TYPE;
	  w_tpoblac    poblaciones.tpoblac%TYPE;
	  w_cagente    seguros.cagente%TYPE;
	  /*Variables registro de datos 1*/
	  v_rid1       VARCHAR2(1):='1';
	  /*Record Identification*/
	  v_sn         VARCHAR2(4); /*Sequence number*/
	  v_ocrn       VARCHAR2(8):='        ';
	  /*Ordering Customer's reference*/
	  v_blanks10   VARCHAR2(10):='          '; --Blanks
	  v_bcan       VARCHAR2(12); --Beneficiary Customer's Account
	  v_am         VARCHAR2(12); /*Amount*/
	  v_bcn        VARCHAR2(26); --Beneficiary customer's name
	  v_bcl        VARCHAR2(1); --Beneficiary customer's language code
	  v_bom        VARCHAR2(12); /*Beginning of the ordinary message*/
	  v_com        VARCHAR2(41); /*First Continuation*/
	  v_tc         VARCHAR2(1):='3';
	  /*Variables registro final*/
	  v_rit        VARCHAR2(1):='9';
	  /*Record identification*/
	  v_ndr        VARCHAR2(4); /*Number of data records*/
	  v_npo        VARCHAR2(4); /*Number of payment orders*/
	  v_tam        VARCHAR2(12); /*Total of amounts*/
	  v_tanc       VARCHAR2(15);
	  /*Total of the account numbers to be credited*/
	  v_sin        VARCHAR2(11); --Sender's identification number
	  v_frt        VARCHAR2(12); /*File reference*/
	  v_blanks49   VARCHAR2(49); /*Blanks*/
	  v_rfb        VARCHAR2(20); /*Reserved Field Blanks*/
	  w_total      NUMBER;
	  /*v_vspc65       VARCHAR2(65);   -- blancs*/
	  w_sumcuentas NUMBER;
	  /*Variables Generales*/
	  d_avui       DATE;
	  w_rutaout    VARCHAR2(100);
	  w_cuantos    NUMBER;
	  v_grupoccc   remesas.ccc%TYPE:='0';
	  /* BUG9693:DRA:20/04/2009*/
	  w_nomfichero VARCHAR2(100);
	  w_fichero    utl_file.file_type;
	  w_linia      VARCHAR2(1000);
	  /*num_err        NUMBER;*/
	  vcontrem     NUMBER;

	  CURSOR remesa IS
	    SELECT r.*
	      FROM remesas_previo r
	     WHERE nremesa=pnremesa AND
	           cmarcado=1 AND
	           cusuario=f_user AND
	           ctipban=4 /* Cuenta Belga*/
	     ORDER BY cempres,ccc,sproduc,sseguro;
	BEGIN
	    d_avui:=f_sysdate;

	    w_rutaout:=f_parinstalacion_t('TRANSFERENCIAS');

	    w_total:=0;

	    w_cuantos:=0;

	    BEGIN
	        SELECT nvl(max(nmovimi), 0)
	          INTO vcontrem
	          FROM ficherosremesa
	         WHERE nremesa=pnremesa;

	        vcontrem:=vcontrem+1;
	    EXCEPTION
	        WHEN no_data_found THEN
	          vcontrem:=1;
	        WHEN OTHERS THEN
	          vcontrem:=1;
	    END;

	    FOR r IN remesa LOOP
	        IF r.cobliga=1 THEN
	          /* BUG9693:DRA:20/04/2009:Inici*/
	          IF v_grupoccc<>r.ccc THEN
	            /*Registro final para cerrar el fichero y abrir uno nuevo en caso de diferentes cuentas bancarias*/
	            IF w_cuantos>0 THEN
	              /* Registre final (Trailer Record)*/
	              v_ndr:=nvl(lpad(w_cuantos, 4, '0'), lpad('0', 4, '0'));

	              v_npo:=v_ndr;

	              v_tam:=w_total*100;

	              v_tam:=replace(v_tam, ',');

	              v_tam:=nvl(lpad(v_tam, 12, '0'), lpad('0', 12, '0'));

	              v_tanc:=nvl(lpad(w_sumcuentas, 15, '0'), lpad('0', 15, '0'));

	              v_sin:='00000000001';

	              v_frt:=lpad(' ', 12, ' ');

	              v_blanks49:=lpad(' ', 49, ' ');

	              v_rfb:=lpad(' ', 20, ' ');

	              w_linia:=v_rit
	                       || v_ndr
	                       || v_npo
	                       || v_tam
	                       || v_tanc
	                       || v_sin
	                       || v_frt
	                       || v_blanks49
	                       || v_rfb;

	              utl_file.put_line(w_fichero, w_linia);

	              utl_file.fclose(w_fichero);
	            END IF;

	            w_total:=0;

	            w_sumcuentas:=0;

	            w_cuantos:=0;

	            v_grupoccc:=r.ccc;
	          END IF;

	        /* BUG9693:DRA:20/04/2009:Fi*/
	          /*Registre 1 --Registro de Cabecera*/
	          IF w_cuantos=0 THEN
	            w_nomfichero:=f_parinstalacion_t('FILE_TRANS');

	            w_nomfichero:=pac_nombres_ficheros.f_nom_transf(pnremesa, r.ccc);

	            IF w_nomfichero='-1' THEN
	              RETURN 9901092;
	            END IF;

	            /* Fi Bug 0013153*/
	            p_insert_ficherosremesa(pnremesa, vcontrem, w_nomfichero, r.ccc);

	            w_nomfichero:='_'
	                          || w_nomfichero;

	            w_fichero:=utl_file.fopen(w_rutaout, w_nomfichero, 'W');

	            v_cna:=lpad(nvl(r.ccobban, '0'), 3, '0');

	            v_cd:=to_char(nvl(nvl(r.fabono, pfabono), f_sysdate), 'ddmmyy');

	            BEGIN
	                SELECT e.tempres,d.tdomici,cpostal,cpoblac,cprovin
	                  INTO w_tempres, w_tdomici, w_cpostal, w_cpoblac, w_cprovin
	                  FROM empresas e,
	                       /* direcciones d*/
	                       per_direcciones d
	                 WHERE e.cempres=r.cempres AND
	                       d.sperson=e.sperson AND
	                       d.cdomici=(SELECT min(cdomici)
	                                    /*FROM direcciones dd*/
	                                    FROM per_direcciones dd
	                                   WHERE dd.sperson=d.sperson);
	            EXCEPTION
	                WHEN OTHERS THEN
	                  p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_generacion_fichero_80', 1, 'error al leer empresas o direcciones para empresa = '
	                                                                                                  || r.cempres, SQLERRM);

	                  RETURN 120135;
	            END;

	            BEGIN
	                SELECT tpoblac
	                  INTO w_tpoblac
	                  FROM poblaciones
	                 WHERE cpoblac=w_cpoblac AND
	                       cprovin=w_cprovin;
	            EXCEPTION
	                WHEN OTHERS THEN
	                  p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_generacion_fichero_80', 1, 'error al leer tabla poblaciones para provincia = '
	                                                                                                  || w_cprovin
	                                                                                                  || ' poblacion = '
	                                                                                                  || w_cpoblac, SQLERRM);

	                  RETURN 120135;
	            END;

	            v_ocan:=r.ccc;

	            v_ocn:=rpad(nvl(w_tempres, ' '), 26, ' ');

	            v_oca:=rpad(nvl(w_tdomici, ' '), 26, ' ');

	            v_ocpc:=rpad(nvl(substr(w_cpostal, 1, 4), ' '), 4, ' ');

	            v_occt:=rpad(nvl(w_tpoblac, ' '), 22, ' ');

	            v_ref:=lpad(nvl(r.ccobban, '0'), 3, '0')
	                   || lpad(nvl(r.nremesa, '0'), 7, '0');

	            /*v_ref := '000 0000000';   --ICV a falta de confirmar*/
	            w_linia:=v_ri
	                     || v_icc
	                     || v_rf
	                     || v_op
	                     || v_cd
	                     || v_cna
	                     || v_ac
	                     || v_edr
	                     || v_dup
	                     || v_zeros3
	                     || v_ocan
	                     || v_ocn
	                     || v_oca
	                     || v_ocpc
	                     || v_occt
	                     || v_oclc
	                     || v_ref
	                     || v_vc;

	            utl_file.put_line(w_fichero, w_linia);
	          END IF;

	          /*Registros de datos 1 (2ºRegistro)*/
	          w_cuantos:=w_cuantos+1;

	          w_total:=w_total+r.iimport;

	          w_sumcuentas:=w_sumcuentas
	                        +lpad(nvl(r.cabono, '0'), 12, '0');

	          v_sn:=lpad(w_cuantos, 4, '0');

	          v_bcan:=lpad(nvl(r.cabono, '0'), 12, '0');

	          v_am:=r.iimport*100;

	          v_am:=replace(v_am, ',');

	          v_am:=nvl(lpad(v_am, 12, '0'), lpad('0', 12, '0'));

	          BEGIN
	              SELECT cagente
	                INTO w_cagente
	                FROM seguros
	               WHERE sseguro=r.sseguro;

	              SELECT substr(nvl(p.tnombre, ' ')
	                            || ' '
	                            || nvl(p.tapelli1, ' ')
	                            || ' '
	                            || nvl(p.tapelli2, ' '), 1, 26),decode(nvl(p.cidioma, 0), 6, 1,
	                                                                                      7, 2,
	                                                                                      1) cidioma
	                INTO v_bcn, v_bcl
	                FROM per_detper p
	               WHERE p.sperson=r.sperson AND
	                     p.cagente=ff_agente_cpervisio(w_cagente, f_sysdate, r.cempres);
	          EXCEPTION
	              WHEN OTHERS THEN
	                v_bcn:=lpad(' ', 26, ' ');

	                v_bcl:=' ';
	          END;

	          v_bcn:=rpad(v_bcn, 26, ' ');

	          v_bom:='Saldo rekeni';

	          v_com:='ng per '
	                 || to_char(nvl(pfabono, r.fabono), 'dd.mm.rrrr');

	          v_com:=rpad(v_com, 41, ' ');

	          w_linia:=v_rid1
	                   || v_sn
	                   || v_ocrn
	                   || v_blanks10
	                   || v_bcan
	                   || v_am
	                   || v_bcn
	                   || v_bcl
	                   || v_bom
	                   || v_com
	                   || v_tc;

	          utl_file.put_line(w_fichero, w_linia);
	        END IF;
	    END LOOP;

	    /*Registre Final*/
	    IF w_cuantos>0 THEN
	      /* Registre final (Trailer Record)*/
	      v_ndr:=nvl(lpad(w_cuantos, 4, '0'), lpad('0', 4, '0'));

	      v_npo:=v_ndr;

	      v_tam:=w_total*100;

	      v_tam:=replace(v_tam, ',');

	      v_tam:=nvl(lpad(v_tam, 12, '0'), lpad('0', 12, '0'));

	      v_tanc:=nvl(lpad(w_sumcuentas, 15, '0'), lpad('0', 15, '0'));

	      v_sin:='00000000001';

	      v_frt:=lpad(' ', 12, ' ');

	      v_blanks49:=lpad(' ', 49, ' ');

	      v_rfb:=lpad(' ', 20, ' ');

	      w_linia:=v_rit
	               || v_ndr
	               || v_npo
	               || v_tam
	               || v_tanc
	               || v_sin
	               || v_frt
	               || v_blanks49
	               || v_rfb;

	      utl_file.put_line(w_fichero, w_linia);

	      utl_file.fclose(w_fichero);
	    END IF;

	    IF utl_file.is_open(w_fichero) THEN
	      utl_file.fclose(w_fichero);
	    END IF;

	    /* Bug 0013153 - FAL - 18/03/2010 - Renombrar nombre fichero para quitarle '_' cuando ya generado.*/
	    IF NOT utl_file.is_open(w_fichero) THEN
	      utl_file.frename(w_rutaout, w_nomfichero, w_rutaout, ltrim(w_nomfichero, '_'));
	    END IF;

	    /* FI bug 0013153*/
	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             IF utl_file.is_open(w_fichero) THEN
	               utl_file.fclose(w_fichero);
	             END IF;

	             p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_genera_fichero_80', 1, 'error no controlado', SQLERRM);

	             RETURN 140999;
	/*error no controlado*/
	END f_generacion_fichero_apra;

	/* Fin Bug.: 13830 - ICV - 27/04/2010*/
	/* BUG14344:DRA:17/05/2010:Inici*/
	/***********************************************************************
	   Función que el texto a mostrar en la columna de origen

	   param in ptipproceso IN VARCHAR2,   --1- Rentas 2- recibos 3- siniestros 4-Reembolsos
	   param out tliteral   OUT VARCHAR2
	***********************************************************************/
	FUNCTION f_get_desc_concepto(
			ptipproceso	IN	VARCHAR2,
			pcidioma	IN	NUMBER,
			ptlitera	OUT	VARCHAR2
	) RETURN NUMBER
	IS
	  /**/
	  v_tlitera VARCHAR2(1000);
	  v_trobat  BOOLEAN:=FALSE;
	BEGIN
	    v_trobat:=FALSE;

	    FOR cur IN (SELECT DISTINCT catribu
	                  FROM detvalores
	                 WHERE cvalor=701 AND
	                       catribu<>12) LOOP
	        IF f_istipobusqueda(ptipproceso, cur.catribu)=1 THEN
	          v_trobat:=TRUE;
	        END IF;
	    END LOOP;

	    IF v_trobat THEN
	      v_tlitera:=f_axis_literales(100829, pcidioma);
	    END IF;

	    v_trobat:=FALSE;

	    FOR cur IN (SELECT DISTINCT catribu
	                  FROM detvalores
	                 WHERE cvalor=701 AND
	                       catribu=12) LOOP
	        IF f_istipobusqueda(ptipproceso, cur.catribu)=1 THEN
	          v_trobat:=TRUE;
	        END IF;
	    END LOOP;

	    IF v_trobat THEN
	      IF v_tlitera IS NOT NULL THEN
	        v_tlitera:=v_tlitera
	                   || ' / ';
	      END IF;

	      v_tlitera:=v_tlitera
	                 || f_axis_literales(100584, pcidioma);
	    END IF;

	    ptlitera:=v_tlitera;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_get_desc_concepto', 1, 'error no controlado', SQLERRM);

	             RETURN 140999;
	/* error no controlado*/
	END f_get_desc_concepto;

	/* BUG14344:DRA:17/05/2010:Fi*/
	/* Bug.: 15118 - JRB - 21/06/2010*/
	FUNCTION f_generacion_fichero_ensa(
			pnremesa	IN	NUMBER,
			params_out	OUT	VARCHAR2
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_transferencias.f_generar_fichero_ensa';
	  vparam      VARCHAR2(4000):='parámetros - ';
	  /*vpasexec       NUMBER(5) := 1;*/
	  vnumerr     NUMBER(8):=0;
	  params_in   VARCHAR2(100);
	  v_nomfitx   VARCHAR2(100);
	  /*v_fecini       DATE;*/
	  /*v_fecfin       DATE;*/
	  /*v_fabonoi      DATE;*/
	  /*v_fabonof      DATE;*/
	  /*v_nremesa      NUMBER;*/
	  v_map       NUMBER:=388;
	  v_cuenta    VARCHAR2(40);

	  CURSOR c1 IS
	    SELECT DISTINCT (ccobban)
	      FROM remesas
	     WHERE nremesa=pnremesa
	     ORDER BY ccobban;

	  vcontrem    NUMBER;
	BEGIN
	/*SELECT MIN(ftransf), MAX(ftransf), MIN(fabono), MAX(fabono)
	  INTO v_fecini, v_fecfin, v_fabonoi, v_fabonof
	  FROM remesas_previo
	 WHERE cusuario = f_user
	   AND TRUNC(falta) = TRUNC(f_sysdate);

	-- BUG12913:DRA:22/03/2010:Inici
	BEGIN
	   SELECT DISTINCT nremesa
	              INTO v_nremesa
	              FROM remesas_previo
	             WHERE cusuario = f_user
	               AND TRUNC(falta) = TRUNC(f_sysdate);
	EXCEPTION
	   WHEN OTHERS THEN
	      v_nremesa := NULL;
	END;                        */
	    /* BUG12913:DRA:22/03/2010:Fi*/
	    FOR c IN c1 LOOP
	    /*
	    124 5/1/3/0 2 -> BANCO AFRICANO DE INVESTIMENTOS -> Mapa: SRL.mapa.pagamento_B.A.I.xls
	    125 5/1/2/0 3 -> BANCO FOMENTO ANGOLA -> Mapa: SRL.mapa.pagamento_B.F.A.xls
	    124 5/1/2/0 1 -> BANCO AFRICANO DE INVESTIMENTOS -> Mapa: SRL.mapa.pagamento_B.A.I.xls


	    Producto ENSA:

	    CCOBBAN PRODUCTO NORDEN
	    123 5/1/1/0 4 -> CAIXA GERAL DE DEPOSITO -> Mapa: Camps especificats en el mail.
	    122 5/1/1/0 3 -> BANCO INTERNACIONA DE CREDITO -> Mapa: Camps especificats en el mail.
	    121 5/1/1/0 2 -> BANCO ESPIRITU SANTO (Sobrevivencia)-> Mapa: Pestanya 2 de ENSA_mapa.pagamentos.BESA.xls
	    120 5/1/1/0 1 -> BANCO ESPIRITU SANTO (Reformados) -> Mapa: Pestanya 1 de ENSA_mapa.pagamentos.BESA.xls
	    */
	        /*params_in := pac_md_common.f_get_cxtidioma || '|' || TO_CHAR(v_fecini, 'YYYYMMDD') || '|'
	                     || TO_CHAR(v_fecfin, 'YYYYMMDD') || '|' || TO_CHAR(v_fabonoi, 'YYYYMMDD')
	                     || '|' || TO_CHAR(v_fabonof, 'YYYYMMDD') || '|' || v_nremesa || '|'
	                     || pac_md_common.f_get_cxtempresa;*/
	        params_in:=c.ccobban
	                   || '|'
	                   || pnremesa;

	        /* BUG12913:DRA:08/02/2010:Inici*/
	        /* params_out := pac_md_map.f_ejecuta(354, params_in, mensajes);*/
	        v_cuenta:=c.ccobban;

	        IF c.ccobban=125 THEN
	          /*v_map := 390;*/
	          v_map:=391;
	        ELSIF c.ccobban=124 THEN
	          v_map:=389;
	        ELSIF c.ccobban=121 THEN
	          v_map:=388;
	        ELSIF c.ccobban=120 THEN
	          v_map:=388;
	        ELSIF c.ccobban=126 THEN
	          v_map:=419;

	          SELECT ncuenta
	            INTO v_cuenta
	            FROM cobbancario
	           WHERE ccobban=c.ccobban;
	        END IF;

	        v_nomfitx:=pac_map.f_get_nomfichero(v_map);

	        v_nomfitx:=substr(v_nomfitx, instr(v_nomfitx, '\', -1)+1);

	        v_nomfitx:=replace(v_nomfitx, '.csv', '_'
	                                              || c.ccobban
	                                              || '_'
	                                              || to_char(f_sysdate, 'DDMMYYYY')
	                                              || '_'
	                                              || to_char(f_sysdate, 'HH24MISS')
	                                              || '.csv');

	        /* Bug 0015524 - JRH - 19/07/2010 - Informar ficheros por pantalla*/
	        BEGIN
	            SELECT nvl(max(nmovimi), 0)
	              INTO vcontrem
	              FROM ficherosremesa
	             WHERE nremesa=pnremesa;

	            vcontrem:=vcontrem+1;
	        EXCEPTION
	            WHEN no_data_found THEN
	              vcontrem:=1;
	            WHEN OTHERS THEN
	              vcontrem:=1;
	        END;

	        p_insert_ficherosremesa(pnremesa, vcontrem, v_nomfitx, v_cuenta);

	        /* Bug 0015524 - JRH - 19/07/2010 - Informar ficheros por pantalla*/
	        vnumerr:=pac_map.f_extraccion(v_map, params_in, v_nomfitx, params_out);
	    END LOOP;

	    /* BUG12913:DRA:08/02/2010:Fi*/
	    RETURN vnumerr;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vnumerr, vparam
	                                                                  || v_nomfitx, SQLERRM);

	             RETURN 140999;
	END f_generacion_fichero_ensa;

	/***********************************************************************
	   --BUG19522 - JTS - 28/10/2011
	   Función que nos devuelve los registros agrupados
	   de la tabla remesas_previo por usuario
	   return             : 0 OK , 1 error
	***********************************************************************/
	FUNCTION f_get_transferencias_agrup(
			pcempres	IN	NUMBER,
			pagrupacion	IN	NUMBER,
			pcramo	IN	NUMBER,
			psproduc	IN	NUMBER,
			pfabonoini	IN	DATE,
			pfabonofin	IN	DATE,
			pftransini	IN	DATE,
			pftransfin	IN	DATE,
			pctransferidos	IN	NUMBER,
			pctipobusqueda	IN	VARCHAR2,
			pnremesa	IN	NUMBER,
			pidioma	IN	NUMBER,
			psquery	OUT	VARCHAR2
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_transferencias.f_get_transferencias_agrup';
	/*vparam         VARCHAR2(500) := 'parámetros - : ';*/
	/*pos            NUMBER;*/
	/*tipo           VARCHAR2(2000);*/
	/*pwhere         VARCHAR2(4000);*/
	/*vsquery        VARCHAR2(4000);*/
	BEGIN
	    psquery:='select nremesa,ccc,iimport,transacciones,procesados,pagados, '
	             || 'iimpost,ideduccio FROM'
	             || '(select r.nremesa, r.ccc, '
	             || 'sum(r.iimport) iimport, '
	             || 'count(1) transacciones, '
	             || 'count(decode(r.cestado, 4, 1, null)) procesados, null pagados, '
	             || 'sum(r.iIVA + r.IICA + r.iAvisosTab + r.iGravamen) iimpost, '
	             || 'sum(r.iRetefuente + r.iReteIVA+ r.iReteRenta + r.iReteICA) ideduccio '
	             || ' FROM remesas_previo r , seguros s'
	             || ' WHERE s.sseguro = r.sseguro and r.cusuario = '
	             || chr(39)
	             || f_user
	             || chr(39)
	             || ' GROUP BY nremesa,ccc UNION ALL '
	             || 'select r.nremesa, r.ccc, '
	             || 'sum(r.iimport) iimport, '
	             || 'count(1) transacciones, '
	             || 'count(decode(r.cestado, 4, 1, null)) procesados, null pagados, '
	             || 'sum(r.iIVA + r.IICA + r.iAvisosTab + r.iGravamen) iimpost, '
	             || 'sum(r.iRetefuente + r.iReteIVA+ r.iReteRenta + r.iReteICA) ideduccio '
	             || ' FROM remesas_previo r, pagoscomisiones p'
	             || ' WHERE p.spago = r.spago and r.cusuario = '
	             || chr(39)
	             || f_user
	             || chr(39)
	             || ' GROUP BY r.nremesa,ccc
	             UNION ALL '
	             || 'select r.nremesa, r.ccc, '
	             || 'sum(r.iimport) iimport, '
	             || 'count(1) transacciones, '
	             || 'count(decode(r.cestado, 4, 1, null)) procesados, null pagados, '
	             || 'sum(r.iIVA + r.IICA + r.iAvisosTab + r.iGravamen) iimpost, '
	             || 'sum(r.iRetefuente + r.iReteIVA+ r.iReteRenta + r.iReteICA) ideduccio '
	             || ' FROM remesas_previo r, pagos_ctatec_rea pr'
	             || ' WHERE pr.spagrea = r.spago and r.cusuario = '
	             || chr(39)
	             || f_user
	             || chr(39)
	             || ' GROUP BY r.nremesa,ccc
	             UNION ALL '
	             || 'select r.nremesa, r.ccc, '
	             || 'sum(r.iimport) iimport, '
	             || 'count(1) transacciones, '
	             || 'count(decode(r.cestado, 4, 1, null)) procesados, null pagados, '
	             || 'sum(r.iIVA + r.IICA + r.iAvisosTab + r.iGravamen) iimpost, '
	             || 'sum(r.iRetefuente + r.iReteIVA+ r.iReteRenta + r.iReteICA) ideduccio '
	             || ' FROM remesas_previo r, pagos_ctatec_coa pc'
	             || ' WHERE pc.spagcoa = r.spago and r.cusuario = '
	             || chr(39)
	             || f_user
	             || chr(39)
	             || ' GROUP BY r.nremesa,ccc
	             UNION ALL '
	             || 'select r.nremesa, r.ccc, '
	             || 'sum(r.iimport) iimport, '
	             || 'count(1) transacciones, '
	             || 'count(decode(r.cestado, 4, 1, null)) procesados, null pagados, '
	             || 'sum(r.iIVA + r.IICA + r.iAvisosTab + r.iGravamen) iimpost, '
	             || 'sum(r.iRetefuente + r.iReteIVA+ r.iReteRenta + r.iReteICA) ideduccio '
	             || ' FROM remesas_previo r, pagoctacliente pc'
	             || ' WHERE pc.spago = r.spago and r.cusuario = '
	             || chr(39)
	             || f_user
	             || chr(39)
	             || ' GROUP BY r.nremesa,ccc) GROUP BY nremesa,ccc,iimport,transacciones,procesados,pagados, '
	             || 'iimpost,ideduccio ';

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, 1, 'error no controlado', psquery
	                                                                                   || '  Error = '
	                                                                                   || SQLERRM);

	             RETURN 1;
	END f_get_transferencias_agrup;

	/***********************************************************************
	   --BUG19522 - JTS - 10/11/2011
	   Función que actualiza la fecha de cambio
	   return             : 0 OK , 1 error
	***********************************************************************/
	FUNCTION f_set_fcambio(
			psremesa	IN	NUMBER,
			pfcambio	IN	DATE
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_transferencias.f_set_fcambio';
	  vsremesa    NUMBER;
	BEGIN
	    SELECT sremesa_orig
	      INTO vsremesa
	      FROM remesas_previo
	     WHERE sremesa=psremesa;

	    UPDATE remesas_previo
	       SET fcambio=pfcambio
	     WHERE sremesa=psremesa;

	    UPDATE remesas
	       SET fcambio=pfcambio
	     WHERE sremesa=vsremesa;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, 1, 'error no controlado', 'Error = '
	                                                                                   || SQLERRM);

	             RETURN 108469; /*Error al actualizar en la tabla*/
	END f_set_fcambio;
	FUNCTION f_get_ident_interv(
			pnif	IN	VARCHAR2,
			psufix	IN	VARCHAR2,
			pidpais	IN	VARCHAR2,
			pidinterv	OUT	VARCHAR2
	) RETURN NUMBER
	IS
	  wcheckdigit VARCHAR2(2);
	  wchkdigaux  VARCHAR2(35);
	/**/
	BEGIN
	    /* cobbancario.nnumnif -> V48148639*/
	    wchkdigaux:=pnif
	                || 'ES00';

	    /* A -> 10, B -> 11 ... Z -> 35*/
	    /* DBMS_OUTPUT.put_line('1.-' || wchkdigaux);*/
	    wchkdigaux:=replace(wchkdigaux, 'A', '10');

	    wchkdigaux:=replace(wchkdigaux, 'B', '11');

	    wchkdigaux:=replace(wchkdigaux, 'C', '12');

	    wchkdigaux:=replace(wchkdigaux, 'D', '13');

	    wchkdigaux:=replace(wchkdigaux, 'E', '14');

	    wchkdigaux:=replace(wchkdigaux, 'F', '15');

	    wchkdigaux:=replace(wchkdigaux, 'G', '16');

	    wchkdigaux:=replace(wchkdigaux, 'H', '17');

	    wchkdigaux:=replace(wchkdigaux, 'I', '18');

	    wchkdigaux:=replace(wchkdigaux, 'J', '19');

	    wchkdigaux:=replace(wchkdigaux, 'K', '20');

	    wchkdigaux:=replace(wchkdigaux, 'L', '21');

	    wchkdigaux:=replace(wchkdigaux, 'M', '22');

	    wchkdigaux:=replace(wchkdigaux, 'N', '23');

	    wchkdigaux:=replace(wchkdigaux, 'O', '24');

	    wchkdigaux:=replace(wchkdigaux, 'P', '25');

	    wchkdigaux:=replace(wchkdigaux, 'Q', '26');

	    wchkdigaux:=replace(wchkdigaux, 'R', '27');

	    wchkdigaux:=replace(wchkdigaux, 'S', '28');

	    wchkdigaux:=replace(wchkdigaux, 'T', '29');

	    wchkdigaux:=replace(wchkdigaux, 'U', '30');

	    wchkdigaux:=replace(wchkdigaux, 'V', '31');

	    wchkdigaux:=replace(wchkdigaux, 'W', '32');

	    wchkdigaux:=replace(wchkdigaux, 'X', '33');

	    wchkdigaux:=replace(wchkdigaux, 'Y', '34');

	    wchkdigaux:=replace(wchkdigaux, 'Z', '35');

	    /* MOD 97-10*/
	    /* Calcula el mòdul 97 i es resta el romanent de 98.*/
	    /* Si el resultat és un sol dígit, llavors s'afegeix un zero per l'esquerra.*/
	    /* El  romanent  de la divisió de 000300050000001012345101300 per 97  =  67*/
	    /* 98 - 67 = 31*/
	    wcheckdigit:=lpad(98-MOD(to_number(wchkdigaux), 97), 2, '0');

	    /*3148148639142800*/
	    /*DBMS_OUTPUT.put_line('2.-' || wchkdigaux);*/
	    /*wCheckDigit := mod(98 - mod(wChkDigAux * 100, 97), 97);*/
	    pidinterv:=pidpais
	               || wcheckdigit
	               || psufix
	               || pnif;

	    /**/
	    /*DBMS_OUTPUT.put_line('3.-' || wcheckdigit || ':::' || pidinterv);*/
	    RETURN(0);
	EXCEPTION
	  WHEN OTHERS THEN
	             RETURN(-1);
	END f_get_ident_interv;

	/*AGG modificaciones SEPA*/
	/*************************************************************************
	  FUNCTION f_set_remesas_sepa
	  Función que guarda los datos en las tablas de remesas_sepa

	  param in psremesa
	  param in pnremesa
	  param in pfabono
	  return             : Devuelve 0 si no ha habido ningún error, por lo contrario devuelve el número de error

	-- Bug 0039238/0223588 - MDS - 14/01/2016
	-- reutilizar el primer parámetro de la función
	-- de psremesa IN NUMBER
	-- a  pccc     IN VARCHAR2
	-- y darle funcionalidad, ya que no se utilizaba

	*************************************************************************/
	FUNCTION f_set_remesas_sepa(
			pccc	IN	VARCHAR2,
			pnremesa	IN	NUMBER,
			pfabono	IN	DATE
	) RETURN NUMBER
	IS
	  vidremesassepa          remesas_sepa.idremesassepa%TYPE;
	  vidremesassepa_pago     remesas_sepa_pago.idpago%TYPE;
	  vidremesassepa_pago_det remesas_sepa_pago_det.iddetalle%TYPE;
	  v_iimport               remesas.iimport%TYPE;
	  w_cuantos               NUMBER;
	  w_total                 NUMBER;
	  v_ftransf               DATE;
	  w_tempres               VARCHAR2(200);
	  xcempres                VARCHAR2(200);
	  v_numnif                VARCHAR2(50);
	  xccobban                cobbancario.ccobban%TYPE;
	  v_sufijo                cobbancario.tsufijo%TYPE;
	  v_cbic                  bancos.cbic%TYPE;
	  v_ccc                   remesas.ccc%TYPE;
	  v_inigtpty_id           VARCHAR2(35);
	  error                   NUMBER;
	  vpasexec                NUMBER;
	  w_grupo                 seguros.cbancar%TYPE:=0;
	  v_ctipban_abono         remesas.ctipban_abono%TYPE;
	  v_cabono                remesas.cabono%TYPE;
	  v_bic_beneficiario      VARCHAR2(11);
	  vagente_poliza          seguros.cagente%TYPE;
	  vcempres                seguros.cempres%TYPE;
	  vcobjase                seguros.cobjase%TYPE;
	  w_nombre                VARCHAR2(100);
	  w_tipo                  VARCHAR2(140);
	  w_mes                   VARCHAR2(15);
	  w_bruto                 NUMBER;
	  v_cobliga               NUMBER;
	  v_fabono                DATE;
	  v_catribu               remesas.catribu%TYPE;
	  v_sseguro               remesas.sseguro%TYPE;
	  v_nrecibo               remesas.nrecibo%TYPE;
	  v_spago                 remesas.spago%TYPE;
	  v_sidepag               remesas.sidepag%TYPE;
	  v_nrentas               remesas.nrentas%TYPE;
	  v_entbeneficiario       VARCHAR2(4);
	  w_prelinea              VARCHAR2(4000);
	  w_linea                 VARCHAR2(4000);
	  v_concep                NUMBER;
	  v_nempres               NUMBER;
	  v_ccobban               remesas.ccobban%TYPE;
	  v_numremesa             NUMBER:=0;
	  v_pos_entidad           tipos_cuenta.pos_entidad%TYPE;
	  v_long_entidad          tipos_cuenta.long_entidad%TYPE;
	  v_iban                  VARCHAR2(34);
	  v_iban_abono            VARCHAR2(34);
	  vcdoment                cobbancario.cdoment%TYPE;
	  v_ctipban               cobbancario.ctipban%TYPE; /*rdd*/
	  v_instrid               VARCHAR2(35);
	  v_npoliza               NUMBER;
      v_bicorbei              parempresas.NVALPAR%TYPE; -- BUG 0040690 - 26/04/16 - EDA
      v_numnif1               VARCHAR2(50);             -- BUG 0040690 - 26/04/16 - EDA



	  /* Bug 0039238/0223588 - MDS - 14/01/2016*/
	  /* modificado el cursor, darle funcionalidad a pccc*/
	  CURSOR cur_remesa IS
	    SELECT *
	      FROM remesas
	     WHERE nremesa=pnremesa AND
	           ccc=nvl(pccc, ccc);
	BEGIN
	    BEGIN
	        vpasexec:=1;

	        w_cuantos:=0;

	        w_total:=0;

	        SELECT seq_remesas_sepa.NEXTVAL
	          INTO vidremesassepa
	          FROM dual;

	        vpasexec:=2;

	        /* Bug 0039238/0223588 - MDS - 14/01/2016*/
	        /* modificado el cursor, darle funcionalidad a pccc*/
	        BEGIN
	            SELECT ftransf,cempres,ccobban,count(sremesa),SUM(iimport)
	              INTO v_ftransf, v_nempres, v_ccobban, w_cuantos, w_total
	              FROM remesas
	             WHERE nremesa=pnremesa AND
	                   ccc=nvl(pccc, ccc)
	             GROUP BY cempres,ftransf,ccobban;
	        END;

	        vpasexec:=3;

	        BEGIN
	            xcempres:=v_nempres;

	            error:=f_nifempresa(xcempres, v_numnif);

	            vpasexec:=80;
	        EXCEPTION
	            WHEN OTHERS THEN
	              v_numnif:=-1;
	        END;

	        vpasexec:=4;

	        BEGIN
	            SELECT e.tempres
	              INTO w_tempres
	              FROM empresas e,per_direcciones d
	             WHERE e.cempres=v_nempres AND
	                   d.sperson=e.sperson;
	        EXCEPTION
	            WHEN no_data_found THEN
	              w_tempres:='';
	        END;

	        vpasexec:=5;

	        BEGIN
	            SELECT tsufijo,ctipban /*rdd agregando ctipban*/
	              INTO v_sufijo, v_ctipban
	              FROM cobbancario
	             WHERE ccobban=v_ccobban;

	            vpasexec:=6;
	        EXCEPTION
	            WHEN no_data_found THEN
	              v_numnif:=1;
	        END;

	        vpasexec:=7;

	        IF v_ctipban IN(1, 2) THEN
	          /*si el tipo de cobrador bancario es español entonces si que hago y mando esta 'ES' hardcodeada , parece ser la validacion sepa español*/
	          error:=f_get_ident_interv(v_numnif, v_sufijo, 'ES', v_inigtpty_id);
	        END IF;

	        /*Controlamos si viene vacío*/
	        IF nvl(to_char(w_tempres), 'NA')='NA' THEN
	          w_tempres:='ERROR';
	        END IF;

	        /*Controlamos si viene vacío*/
	        IF nvl(to_char(v_inigtpty_id), 'NA')='NA' THEN
	          v_inigtpty_id:='ERROR';
	        END IF;

	        /*Controlamos si viene vacío*/
	        IF nvl(to_char(v_ftransf, 'MM/DD/YYYY'), 'NA')='NA' THEN
	          v_ftransf:=f_sysdate;
	        END IF;

	        vpasexec:=8;

			INSERT INTO remesas_sepa
		           (idremesassepa,msgid,credttm,nboftxs,ctrlsum,initgpty_nm_3,
		           othr_id_6)
		    VALUES
		           (vidremesassepa,pnremesa,v_ftransf,w_cuantos,w_total,w_tempres,
		           v_numnif);


	        vpasexec:=9;

	        FOR r IN cur_remesa LOOP
	            v_ccc:=r.ccc;

	            v_iimport:=r.iimport;

	            v_ctipban_abono:=r.ctipban_abono;

	            w_bruto:=r.iimport;

	            v_cabono:=r.cabono;

	            v_cobliga:=r.cobliga;

	            v_fabono:=r.fabono;

	            v_catribu:=r.catribu;

	            v_sseguro:=r.sseguro;

	            v_nrecibo:=r.nrecibo;

	            v_spago:=r.spago;

	            v_sidepag:=r.sidepag;

	            v_nrentas:=r.nrentas;

	            BEGIN
	                SELECT nvl(pos_entidad, 1),nvl(long_entidad, 4)
	                  INTO v_pos_entidad, v_long_entidad
	                  FROM tipos_cuenta
	                 WHERE ctipban=r.ctipban;

	                v_entbeneficiario:=substr(v_ccc, v_pos_entidad, v_long_entidad);
	            EXCEPTION
	                WHEN no_data_found THEN
	                  v_entbeneficiario:=substr(v_ccc, 1, 4);
	            END;

	            /* w_total := w_total + r.iimport;
	             w_cuantos := w_cuantos + 1;
	             vpasexec := 3;*/
	            vpasexec:=10;

	            IF (v_cobliga=1) THEN
	              IF w_grupo<>v_ccc THEN
	                w_grupo:=v_ccc;

	                v_numremesa:=v_numremesa+1;

	                SELECT seq_remesas_sepa_pago.NEXTVAL
	                  INTO vidremesassepa_pago
	                  FROM dual;

	                BEGIN
	                    SELECT cdoment
	                      INTO vcdoment
	                      FROM cobbancario
	                     WHERE ccobban=r.ccobban;

	                    BEGIN
	                        SELECT b.cbic
	                          INTO v_cbic
	                          FROM bancos b
	                         WHERE b.cbanco=vcdoment;

	                        vpasexec:=11;
	                    EXCEPTION
	                        WHEN no_data_found THEN
	                          v_cbic:=-1;

	                          p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_set_remesas_sepa', 1, 'No encontrado banco '
	                                                                                                     || vcdoment, SQLERRM);

	                          RETURN 120135;
	                    END;
	                EXCEPTION
	                    WHEN no_data_found THEN
	                      v_cbic:=-1;

	                      p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_set_remesas_sepa', 1, 'No encontrado cobrador bancario '
	                                                                                                 || r.ccobban, SQLERRM);

	                      RETURN 120135;
	                END;

	                vpasexec:=12;

	                /*v_inigtpty_id := v_inigtpty_id || '-' || v_numremesa;*/

                  -- INICIO 40690 DCT 26/04/16 EDA
                  -- Si el valor del parámetro BICOrBEI está a 1, entonces NIF || Secuencial de la remesa con 0 por la izquierda.
                  v_bicorbei := NVL(pac_parametros.f_parempresa_n(xcempres,'SEPA_BICORBEI_CHANGE'),0);

                  IF v_bicorbei = 0 THEN
                    v_numnif:=v_numnif
                              || '-'
                              || v_numremesa;
                  ELSE
                    v_numnif1:= v_numnif || LPAD(pnremesa, 5, 0);
                  END IF;

	                IF r.ctipban=1 THEN
	                  v_iban:=pac_domis.f_convertir_ccc_iban(v_ccc, 'ES');
	                ELSE
	                  v_iban:=v_ccc;
	                END IF;

			INSERT INTO remesas_sepa_pago
		           (idremesasepa,idpago,pmtinfid,pmtmtd,btchbookg,nboftxs,
		           ctrlsum,svclvl_cd_4,reqdexctndt,dbtr_nm_3,orgid_bicorbei_5,
		           id_iban_4,fininstnid_bic_4)
		    VALUES
		           (vidremesassepa,vidremesassepa_pago,DECODE(v_bicorbei,1,v_numnif1,v_numnif) /*v_inigtpty_id*/ ,'TRF','true',w_cuantos,
		           w_total,'SEPA',v_fabono,w_tempres,v_cbic,
		           v_iban,v_cbic);
            -- FIN 40690 DCT 26/04/2016


	                vpasexec:=13;
	              END IF;
	            END IF;

	            vpasexec:=14;

	            SELECT seq_remesas_sepa_pago_det.NEXTVAL
	              INTO vidremesassepa_pago_det
	              FROM dual;

	            IF nvl(to_char(v_ctipban_abono), 'NA')='NA' THEN
	              v_ctipban_abono:=2; /*si no viene nada por defecto ponemos 2*/
	            END IF;

	            BEGIN
	                SELECT cbic
	                  INTO v_bic_beneficiario
	                  FROM bancos
	                 WHERE cbanco=v_entbeneficiario;
	            EXCEPTION
	                WHEN no_data_found THEN
	                  v_bic_beneficiario:='-1';

	                  p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_set_remesas_sepa', 1, 'No hay código BIC de banco '
	                                                                                             || v_entbeneficiario
	                                                                                             || ' cuenta:'
	                                                                                             || v_ccc
	                                                                                             || ' tipo cuenta:'
	                                                                                             || r.ctipban, SQLERRM);
	            END;

	            vpasexec:=15;

	            IF v_catribu IN(5, 6) THEN
	            /* extornos y anulaciones de aprotación*/
	            BEGIN
	                  SELECT cagente,cempres,nvl(cobjase, 0)
	                    INTO vagente_poliza, vcempres, vcobjase
	                    FROM seguros
	                   WHERE sseguro=v_sseguro;

	                  IF vcobjase=1 THEN
	                    SELECT DISTINCT substr(d.tapelli1, 0, 40) -- 06/06/2016 EDA JIRA-9 El agente no es restrictivo en las consultas de personas
	                           || ' '
	                           || substr(d.tapelli2, 0, 20)
	                           || ','
	                           || substr(d.tnombre, 0, 20),to_char(re.femisio, 'FMMONTH')
	                      INTO w_nombre, w_mes
	                      FROM per_personas p,per_detper d,recibos re,riesgos ri
	                     WHERE re.nrecibo=v_nrecibo AND
	                           re.sseguro=ri.sseguro AND
	                           nvl(re.nriesgo, 1)=ri.nriesgo AND
	                           ri.sperson=p.sperson AND
	                           d.sperson=p.sperson AND
	                           -- d.cagente=ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres); -- 06/06/2016 EDA JIRA-9 El agente no es restrictivo en generación de las transferencias
							   rownum =1 ; -- 06/06/2016 EDA JIRA-9 El agente no es restrictivo en generación de las transferencias

	                    w_bruto:=v_iimport;
	                  /* si el objeto asegurado NO es persona, la tabla de riesgos es ASEGURADOS*/
	                  /* la SELECT es la nueva versión*/
	                  ELSE
	                    SELECT DISTINCT substr(d.tapelli1, 0, 40) -- 06/06/2016 EDA JIRA-9 El agente no es restrictivo en las consultas de personas
	                           || ' '
	                           || substr(d.tapelli2, 0, 20)
	                           || ','
	                           || substr(d.tnombre, 0, 20),to_char(re.femisio, 'FMMONTH')
	                      INTO w_nombre, w_mes
	                      FROM per_personas p,per_detper d,recibos re,asegurados ri
	                     WHERE re.nrecibo=v_nrecibo AND
	                           re.sseguro=ri.sseguro AND
	                           nvl(re.nriesgo, 1)=nvl(ri.nriesgo, 1) AND
	                           ri.sperson=p.sperson AND
	                           d.sperson=p.sperson AND
	                           -- d.cagente=ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres); -- 06/06/2016 EDA JIRA-9 El agente no es restrictivo en generación de las transferencias
							   rownum =1 ; -- 06/06/2016 EDA JIRA-9 El agente no es restrictivo en generación de las transferencias

	                    w_bruto:=v_iimport;
	                  END IF;
	              EXCEPTION
	                  WHEN no_data_found THEN
	                    p_tab_error (f_sysdate, f_user, 'pac_transferencias.f_set_remesas_sepa', 1, 'error al leer tablas personas, recibos, riesgos para recibo = '
	                                                                                                || v_nrecibo, SQLERRM);

	                    RETURN 120135;
	              END;
	            /*            ELSIF v_catribu = 8 THEN*/
	            /*               w_tipo := 'TRASPASO DE SALIDA';*/
	            /*            ELSIF v_catribu = 10 THEN*/
	            /*               w_tipo := 'PREST. ' || w_mes;*/
	            ELSIF v_catribu=12 THEN
	              SELECT f_nombre(p.sperson, 1),to_char(pc.fliquida, 'FMMONTH'),pc.iimporte
	                INTO w_nombre, w_mes, w_bruto
	                FROM pagoscomisiones pc,agentes a,per_personas p
	               WHERE a.cagente=pc.cagente AND
	                     p.sperson=a.sperson AND
	                     pc.spago=v_spago;
	            ELSIF v_catribu=16 THEN
	              SELECT f_nombre(p.sperson, 1),to_char(pc.fliquida, 'FMMONTH'),pc.iimporte
	                INTO w_nombre, w_mes, w_bruto
	                FROM pagoctacliente pc,per_personas p
	               WHERE p.sperson=pc.sperson AND
	                     pc.spago=v_spago;
	            ELSE BEGIN
	                  /*Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro*/
	                  SELECT cagente,cempres
	                    INTO vagente_poliza, vcempres
	                    FROM seguros
	                   WHERE sseguro=v_sseguro;

	                  w_tipo:='DEVOLUCIÓN';

	                  error:=f_desvalorfijo(701, 1, v_catribu, w_tipo);

	                  IF pac_parametros.f_parempresa_n(vcempres, 'MODULO_SINI')=1 THEN BEGIN
	                        SELECT DISTINCT substr(d.tapelli1, 0, 40) -- 06/06/2016 EDA JIRA-9 El agente no es restrictivo en generación de las transferencias
	                               || ' '
	                               || substr(d.tapelli2, 0, 20)
	                               || ','
	                               || substr(d.tnombre, 0, 20),to_char(pa.fordpag, 'FMMONTH'),nvl(pa.isinret, 0)-nvl(pa.iretenc, 0)+nvl(pa.iiva, 0)
	                          INTO w_nombre, w_mes, w_bruto
	                          FROM per_personas p,per_detper d,sin_tramita_pago pa
	                         WHERE pa.sidepag=v_sidepag AND
	                               pa.sperson=p.sperson AND
	                               d.sperson=p.sperson AND
	                               -- d.cagente=ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres); -- 06/06/2016 EDA JIRA-9 El agente no es restrictivo en generación de las transferencias
								   rownum =1 ; -- 06/06/2016 EDA JIRA-9 El agente no es restrictivo en generación de las transferencias
	                    EXCEPTION
	                        WHEN no_data_found THEN
	                          SELECT substr(d.tapelli1, 0, 40)
	                                 || ' '
	                                 || substr(d.tapelli2, 0, 20)
	                                 || ','
	                                 || substr(d.tnombre, 0, 20),to_char(pa.fordpag, 'FMMONTH'),nvl(pa.isinret, 0)-nvl(pa.iretenc, 0)+nvl(pa.iiva, 0)
	                            INTO w_nombre, w_mes, w_bruto
	                            FROM personas d,sin_tramita_pago pa
	                           WHERE pa.sidepag=v_sidepag AND
	                                 pa.sperson=d.sperson;
	                    END;
	                  ELSE
	                    SELECT DISTINCT substr(d.tapelli1, 0, 40)
	                           || ' '
	                           || substr(d.tapelli2, 0, 20)
	                           || ','
	                           || substr(d.tnombre, 0, 20),to_char(pa.fordpag, 'FMMONTH'),pa.iimpsin
	                      INTO w_nombre, w_mes, w_bruto
	                      FROM per_personas p,per_detper d,pagosini pa
	                     WHERE pa.sidepag=v_sidepag AND
	                           pa.sperson=p.sperson AND
	                           d.sperson=p.sperson AND
	                           -- d.cagente=ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres);  -- -- 06/06/2016 EDA JIRA-9 El agente no es restrictivo en generación de las transferencias
							   rownum =1 ; -- 06/06/2016 EDA JIRA-9 El agente no es restrictivo en generación de las transferencias
	                  END IF;
	              EXCEPTION
	                  WHEN no_data_found THEN BEGIN
	                        SELECT DISTINCT substr(d.tapelli1, 0, 40)
	                               || ' '
	                               || substr(d.tapelli2, 0, 20)
	                               || ','
	                               || substr(d.tnombre, 0, 20),to_char(pa.ffecpag, 'FMMONTH'),pa.iconret
	                          INTO w_nombre, w_mes, w_bruto
	                          FROM per_personas p,per_detper d,pagosrenta pa
	                         WHERE pa.srecren=v_nrentas AND
	                               pa.sperson=p.sperson AND
	                               d.sperson=p.sperson AND
	                               -- d.cagente=ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres); -- -- 06/06/2016 EDA JIRA-9 El agente no es restrictivo en generación de las transferencias
								                 rownum =1 ; -- 06/06/2016 EDA JIRA-9 El agente no es restrictivo en generación de las transferencias
	                    EXCEPTION
	                        WHEN no_data_found THEN
	                          p_tab_error (f_sysdate, f_user, 'pac_transferencias.f_set_remesas_sepa', 2, 'error al leer tablas personas, detalle, pagosrenta para renta = '
	                                                                                                      || v_nrentas, SQLERRM);

	                          RETURN 120135;
	                    END;
	              END;
	            END IF;

	            vpasexec:=16;

	            /*INI BUG 37233-211397 KJSC 04/08/2015 Buscaremos una descripción y una clave.*/
	            IF nvl(pac_parametros.f_parempresa_n(xcempres, 'TRANS_DESC_ALT'), 0)=1 THEN
	              error:=f_desvalorfijo(701, f_idiomauser, v_catribu, w_tipo);

	              IF v_catribu=2 THEN
	                w_tipo:=w_tipo
	                        || ' '
	                        || r.nrentas;
	              ELSIF v_catribu IN(3, 4, 7, 8, 10) THEN
	                w_tipo:=w_tipo
	                        || ' '
	                        || r.sidepag;
	              ELSIF v_catribu IN(5, 6) THEN
	                w_tipo:=w_tipo
	                        || ' '
	                        || r.nrecibo;
	              ELSIF v_catribu IN(11) THEN
	                w_tipo:=w_tipo
	                        || ' '
	                        || r.nreemb;
	              ELSIF v_catribu IN(12) THEN
	                w_tipo:=w_tipo
	                        || ' '
	                        || r.spago;
	              END IF;
	            ELSE
	              IF v_catribu=8 THEN
	                w_tipo:='TRASPASO DE SALIDA';
	              ELSIF v_catribu=10 THEN
	                w_tipo:='PREST. '
	                        || w_mes;
	              ELSE
	                w_tipo:='DEVOLUCIÓN';

	                error:=f_desvalorfijo(701, 1, v_catribu, w_tipo);
	              END IF;
	            END IF;

	            /**/
	            IF nvl(pac_parametros.f_parempresa_n(xcempres, 'USTRD_TRANSF_XML'), 0)=1 THEN
	              /**/
	              IF v_catribu IN (3, 4, 7, 8, 10) THEN
	                w_linea:=pac_propio.f_ustrid_sepa_transf(v_catribu, r.sidepag);
	              ELSIF v_catribu=2 THEN
	                w_linea:=pac_propio.f_ustrid_sepa_transf(v_catribu, r.nrentas);
	              ELSIF v_catribu IN (5, 6) THEN
	                w_linea:=pac_propio.f_ustrid_sepa_transf(v_catribu, r.nrecibo);
	              ELSIF v_catribu=11 THEN
	                w_linea:=pac_propio.f_ustrid_sepa_transf(v_catribu, r.nreemb);
	              ELSIF v_catribu=12 THEN
	                w_linea:=pac_propio.f_ustrid_sepa_transf(v_catribu, r.spago);
	              END IF;
	            /**/
	            ELSE
	              /**/
	              w_linea:=w_tipo
	                       || ' '
	                       || to_char(w_bruto, 'FM999G999G990D00')
	                       || ' Euros';
	            /**/
	            END IF;

	            IF r.ctipban_abono=1 THEN /* BUG-40708 08/03/2016 EDDA Debe ser el tipo de cobrador bancario del recibo donde ser realiza el abono. */
	              v_iban_abono:=pac_domis.f_convertir_ccc_iban(r.cabono, 'ES');
	            ELSIF r.ctipban=2 THEN
	              v_iban_abono:=r.cabono;
	            ELSE
	              v_iban_abono:=r.cabono; /*-el resto   rdd incluiría Malta*/
	            END IF;

	            IF r.sseguro IS NOT NULL THEN BEGIN
	                  SELECT npoliza
	                    INTO v_npoliza
	                    FROM seguros s
	                   WHERE sseguro=r.sseguro;
	              EXCEPTION
	                  WHEN OTHERS THEN
	                    v_npoliza:=NULL;
	              END;
	            END IF;

	            IF v_catribu IN (3, 4, 7) THEN /*siniestos*/
	              v_instrid:=v_npoliza
	                         ||'-'
	                         ||r.sidepag
	                         ||'-'
	                         ||r.nsinies;
	            ELSIF v_catribu IN (5) THEN
	              v_instrid:=v_npoliza
	                         ||'-'
	                         ||r.nrecibo;
	            ELSIF v_catribu IN (12) THEN BEGIN
	                  SELECT cagente
	                         ||'-'
	                         ||to_char(fliquida, 'dd/mm/yyyy')
	                    INTO v_instrid
	                    FROM pagoscomisiones
	                   WHERE spago=r.spago;
	              EXCEPTION
	                  WHEN OTHERS THEN
	                    v_instrid:=r.sremesa;
	              END;

	            ELSE
	              v_instrid:=r.sremesa;
	            END IF;

			INSERT INTO remesas_sepa_pago_det
		           (idremesasepa,idpago,iddetalle,instrid_endtoendid_4,amt_instdamt_4,fininstnid_bic_5,
		           cdtr_nm_4,id_iban_5,othr_id_6,rmtinf_ustrd_4,pmtid_instrid_4)

		    VALUES
		           (vidremesassepa,vidremesassepa_pago,vidremesassepa_pago_det,r.sremesa,v_iimport,v_bic_beneficiario,
		           w_nombre,v_iban_abono,v_numnif,w_linea,v_instrid );


	            vpasexec:=17;
	        END LOOP;

	        RETURN vidremesassepa;
	    EXCEPTION
	        WHEN OTHERS THEN
	          p_tab_error(f_sysdate, f_user, 'pac_transferencias.f_set_remesas_sepa', vpasexec, 'Error incontrolado en f_set_remesas_sepa', SQLERRM);

	          RETURN(-1);
	    END;
	END f_set_remesas_sepa;
	FUNCTION f_get_trans_retenida(
			pcagente	IN	NUMBER,
			psquery	OUT	VARCHAR2
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_transferencias.f_get_trans_retenida';
	  vparam      VARCHAR2(500):='parámetros - : pcagente --> '
	                        || pcagente;
	  pwhere      VARCHAR2(4000):='';
	BEGIN
	    IF pcagente IS NOT NULL THEN
	      pwhere:='and r.clisres = 1 and r.cagente = '
	              || pcagente
	              || ' ';
	    END IF;

	    psquery:='SELECT  sclave, sseguro, npoliza,fabono, cabono, iimport, ttitulo, nrecibo, '
	             || 'nsinies, sidepag, nreemb, nfact,nrentas,itasa, chiimport '
	             || 'FROM (SELECT r.sclave,r.sseguro, f_formatopol(s.npoliza, s.ncertif, 1) npoliza, r.fabono, r.cabono,'
	             || 'r.iimport, f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, 2) ttitulo,'
	             || 'r.nrecibo, r.nsinies, r.sidepag, r.nreemb, r.nfact, r.nrentas,'
	             || '1 itasa, iimport chiimport '
	             || 'FROM remesas_previo_lre r, seguros s '
	             || 'WHERE s.sseguro = r.sseguro '
	             || pwhere
	             || ' UNION ALL '
	             || 'SELECT r.sclave,r.sseguro, NULL npoliza, r.fabono, r.cabono,'
	             || 'r.iimport, p.cagente||'''
	             || ' '
	             || '''||f_desagente_t (p.cagente) ttitulo, r.nrecibo,'
	             || 'r.nsinies, r.sidepag, r.nreemb, r.nfact, r.nrentas,1 itasa, iimport chiimport '
	             || 'FROM remesas_previo_lre r, pagoscomisiones p '
	             || 'WHERE p.spago = r.spago '
	             || pwhere
	             || ' UNION ALL '
	             || 'SELECT r.sclave,r.sseguro, NULL npoliza,r.fabono,r.cabono, '
	             || 'r.iimport, NULL ttitulo, r.nrecibo, r.nsinies, r.sidepag, r.nreemb, r.nfact, '
	             || 'r.nrentas, 1 itasa, iimport chiimport '
	             || 'FROM remesas_previo_lre r, pagos_ctatec_rea pr '
	             || 'WHERE pr.spagrea = r.spago '
	             || pwhere
	             || ' UNION ALL '
	             || 'SELECT r.sclave,r.sseguro, NULL npoliza, r.fabono, r.cabono, '
	             || 'r.iimport, NULL ttitulo, r.nrecibo, r.nsinies, r.sidepag, r.nreemb, r.nfact, '
	             || 'r.nrentas, 1 itasa, iimport chiimport '
	             || 'FROM remesas_previo_lre r, pagos_ctatec_coa pc '
	             || 'WHERE pc.spagcoa = r.spago '
	             || pwhere
	             || ' UNION ALL '
	             || 'SELECT r.sclave,r.sseguro, NULL npoliza, r.fabono, r.cabono, '
	             || 'r.iimport, NULL ttitulo, r.nrecibo, r.nsinies, r.sidepag, r.nreemb, r.nfact,r.nrentas, 1 itasa, '
	             || 'iimport chiimport '
	             || 'FROM remesas_previo_lre r, pagoctacliente pe '
	             || 'WHERE pe.spago = r.spago '
	             || pwhere
	             || ') ';

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, 1, 'error no controlado', psquery
	                                                                                   || '  Error = '
	                                                                                   || SQLERRM);

	             RETURN 1;
	END f_get_trans_retenida;
	FUNCTION f_trans_ret_cancela(
			psclave	IN	NUMBER
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_transferencias.f_trans_ret_cancela';
	  vparam      VARCHAR2(500):='parámetros - : psclave -->'
	                        || psclave;
	  pwhere      VARCHAR2(4000):='';
	BEGIN
	    IF psclave IS NOT NULL THEN
	      UPDATE remesas_previo_lre
	         SET clisres=2,flisres=f_sysdate,ulisres=f_user
	       WHERE sclave=psclave;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, 1, vparam, '  Error = '
	                                                                    || SQLERRM);

	             RETURN 1;
	END f_trans_ret_cancela;
	FUNCTION f_trans_ret_desbloquea(
			psclave	IN	NUMBER
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_transferencias.f_trans_ret_desbloquea';
	  vparam      VARCHAR2(500):='parámetros - : psclave -->'
	                        || psclave;
	  pwhere      VARCHAR2(4000):='';
	  v_person    NUMBER;
	  vislisrest  NUMBER;
	BEGIN
	    IF psclave IS NOT NULL THEN
	      SELECT a.sperson
	        INTO v_person
	        FROM remesas_previo_lre lre,agentes a
	       WHERE lre.cagente=a.cagente AND
	             lre.sclave=psclave;

	      SELECT count(sperson)
	        INTO vislisrest /* validamos si el usuario existe en una lista restringida*/
	        FROM lre_personas
	       WHERE cclalis=2 AND
	             ctiplis=48 AND
	             finclus<=f_sysdate AND
	             (fexclus>=f_sysdate  OR
	              fexclus IS NULL) AND
	             sperson=v_person;

	      IF (vislisrest>0) THEN
	        RETURN 9908438; /*agente está retenido*/
	      END IF;

	      UPDATE remesas_previo_lre
	         SET clisres=3,flisres=f_sysdate,ulisres=f_user
	       WHERE sclave=psclave;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, 1, vparam, 'Error = '
	                                                                    || SQLERRM);

	             RETURN 1;
	END f_trans_ret_desbloquea;

	/* Bug 0039238/0223588 - MDS - 14/01/2016*/
	FUNCTION f_generacion_ficheros_sepa(
			pnremesa	IN	NUMBER,
			pfabono	IN	DATE
	) RETURN NUMBER
	IS
	  vobjectname   VARCHAR2(500):='pac_transferencias.f_generacion_ficheros_sepa';
	  vparam        VARCHAR2(4000):='parámetros - '
	                         || 'pnremesa='
	                         || pnremesa
	                         || ' pfabono='
	                         || pfabono;
	  vidremesasepa NUMBER(8):=0;
	  w_error       NUMBER;
	  w_nmovimi     NUMBER:=0;
	  w_nomfichero  VARCHAR2(100);

	  CURSOR c_remesas IS
	    SELECT DISTINCT ccc
	      FROM remesas
	     WHERE nremesa=pnremesa
	     ORDER BY ccc ASC;
	BEGIN
	    FOR reg IN c_remesas LOOP
	        /* genera información para el fichero*/
	        vidremesasepa:=f_set_remesas_sepa(reg.ccc, pnremesa, pfabono);

	        w_error:=pac_sepa.f_genera_xml_transferencias(vidremesasepa);

	        /* obtener nombre del fichero*/
	        w_nomfichero:=pac_nombres_ficheros.f_nom_transf(pnremesa, reg.ccc);

	        /* insertar registro en la tabla ficherosremesa*/
	        /*w_nmovimi := w_nmovimi + 1;*/
	        SELECT nvl(max(nmovimi), 0)+1
	          INTO w_nmovimi
	          FROM ficherosremesa
	         WHERE nremesa=pnremesa;

	        p_insert_ficherosremesa(pnremesa, w_nmovimi, replace(w_nomfichero, 'TXT', 'XML'), reg.ccc);

	        /* genera el fichero*/
	        w_error:=pac_sepa.f_genera_fichero_dom_trans('T', vidremesasepa, substr(w_nomfichero, 1, instr(w_nomfichero, '.', -1)-1));
	    END LOOP;

	    RETURN w_error;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, w_error, vparam
	                                                                  || w_nomfichero, SQLERRM);

	             RETURN 140999;
	END f_generacion_ficheros_sepa;

-- Bug 0041159 - MCA - 30/03/2016
   FUNCTION f_destinatario_pago(psremesa IN NUMBER, patribu IN NUMBER)
      RETURN VARCHAR2 IS

    vobjectname   VARCHAR2(500):='pac_transferencias.f_destinatario_pago';
	  vparam        VARCHAR2(4000):='parámetros - '
	                         || 'psremesa='
	                         || psremesa
	                         || ' patribu='
	                         || patribu;
    vpago         NUMBER;
    vnombre       VARCHAR2(400);
   BEGIN

   SELECT decode(patribu, 12, spago, sperson)
    INTO vpago
   FROM remesas
   WHERE sremesa = psremesa;

   IF patribu in (5,6,3,4,7,2,6,11) THEN  --Recibos, siniestros, rentas y reembolsos
      SELECT f_nombre(r.sperson,3,s.cagente) INTO vnombre
      FROM remesas r, seguros s
      WHERE s.sseguro(+) = r.sseguro
        AND r.sremesa = psremesa;
   ELSE
      SELECT f_nombre(a.sperson,3,a.cagente) INTO vnombre
      FROM  pagoscomisiones p, agentes a
      WHERE a.cagente=p.cagente
        AND p.spago = vpago;
   END IF;

   RETURN vnombre;

   EXCEPTION
	    WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, 1, vparam, SQLERRM);
	             RETURN '**';
	 END f_destinatario_pago;


END pac_transferencias;

/

  GRANT EXECUTE ON "AXIS"."PAC_TRANSFERENCIAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_TRANSFERENCIAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_TRANSFERENCIAS" TO "PROGRAMADORESCSI";
