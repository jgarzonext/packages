--------------------------------------------------------
--  DDL for Package Body PAC_REDCOMERCIAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_REDCOMERCIAL" IS


	   /******************************************************************************
	      NOMBRE:      PAC_REDCOMERCIAL


	      REVISIONES:
	      Ver        Fecha        Autor             Descripci¿n
	      ---------  ----------  ---------------  ------------------------------------
	      1.0        23/02/2012   JMF             0021432: MDP - COM - C¿digo de agente semiautomatico dependiendo del nivel jerarquico.
	      2.0        29/02/2012   APD             0021421: LCOL_C001: Incidencia en el traspaso de cartera
	      3.0        07/03/2012   MDS             0021597: LCOL898-Enviar rebuts en Trasllats i canvis de sucursal
	      4.0        17/05/2012   JMF             0021672 MDP - COM - Red comercial en malla
	      5.0        24/05/2012   APD             0021841: LCOL_C001: Recuperar validacions existents en la Xarxa comercial
	      6.0        29/05/2012   APD             0021682: MDP - COM - Transiciones de estado de agente.
	      7.0        28/11/2012   JMF             0024871 LCOL_C001-LCOL - PER - CAMBIO DE VISIN EN RED COMERCIAL
	      8.0        13/05/2013   dlF             0026880: AGM800 - Incidencias en los listado de administraci¿n
	      9.0        04/06/2013   ETM             0026318: POSS038-(POSIN011)-Interfaces:IAXIS-SAP: Interfaz de Personas
	     10.0        07/06/2013   APD             0026923: LCOL - TEC - Revisi¿n Q-Trackers Fase 3A
	     11.0        21/08/2013   MMM             0027951: LCOL: Mejora de Red Comercial
	     12.0        21/05/2014   FAL             0031489: TRQ003-TRQ: Gap de comercial. Liquidaci¿n a nivel de Banco
		 13.0        16/01/2019   ACL             TCS_1: En la función f_set_agente se agrega el campo claveinter para la tabla agentes.
		 14.0 		 01/02/2019   ACL             TCS_1569B: Se modifica la función f_set_agente con los parámetros de impuestos.
		 15.0        27/02/2019   DFR             IAXIS-2415: FICHA RED COMERCIAL
		 16.0		 19/07/2019	  PK		Cambio de IAXIS-4844 - Optimizar Petición Servicio I017
	   ******************************************************************************/

	   /* cursor que dado un agente, una empresa, una fecha inicial y una final
	    selecciona los diferentes dias de inicio de la red comercial del agente para
	    la empresa, en el intervalo dado */
	CURSOR dias_cambio(fini
	IN    DATE,
	ffin  IN
	DATE, cemp
	IN    NUMBER,
	cage  IN
	NUMBER)

	IS
	  SELECT DISTINCT (greatest(fmovini, fini)) fmvini
	  FROM            redcomercial
	  WHERE           cempres = cemp
	                  START WITH cempres = cemp
	  AND             cagente = cage
	  AND            ((
	                                                  trunc(fini) <= trunc(fmovini)
	                                  AND             nvl(trunc(ffin), trunc(fmovini) + 1) > trunc(fmovini))
	                  OR             (
	                                                  trunc(fini) >= trunc(fmovini)
	                                  AND             trunc(fini) < nvl(trunc(fmovfin), trunc(fini + 1))))
	                  CONNECT BY PRIOR cempres = cempres
	  AND             PRIOR cpadre = cagente
	  AND            (
	                                  fmovfin IS NULL
	                  OR              fmovfin > PRIOR greatest(fmovini, fini))
	  AND            (
	                                  fmovini < ffin
	                  OR              ffin IS NULL)
	  ORDER BY        1;

	/* cursor que dado un agente, una empresa y un dia selecciona la red
		comercial del
	agente para
	la    empresa
	en    la
	fecha */CURSOR
	rc_dia(dia IN
	DATE, cemp
	IN    NUMBER,
	cage  IN
	NUMBER)

	IS
	  SELECT cagente,
	         ctipage
	  FROM   redcomercial
	  WHERE  cempres = cemp
	  AND   (
	                trunc(dia) >= trunc(fmovini))
	  AND   (
	                trunc(dia) < nvl(trunc(fmovfin), trunc(dia + 1)))
	         CONNECT BY PRIOR cpadre = cagente
	  AND    PRIOR cempres = cempres
	  AND   (
	                trunc(dia) >= trunc(fmovini))
	  AND   (
	                trunc(dia) < nvl(trunc(fmovfin), trunc(dia + 1)))
	         START WITH cagente = cage
	  AND    cempres = cemp
	  AND   (
	                trunc(dia) >= trunc(fmovini))
	  AND   (
	                trunc(dia) < nvl(trunc(fmovfin), trunc(dia + 1)));

	/* ini Bug 0021672 - 17/05/2012 - JMF*/
	/*************************************************************************
	Funci¿n para evitar que existan 2 tipos de agente iguales en una rama del agente.
	Busca el tipo agente, en la redcomercial en jerarquia sentido hacia abajo.
	param in p_emp  : c¿digo de la empresa
	param in p_age  : c¿digo del agente
	param in p_tip  : tipo agente a buscar
	return          : Tipo encontrado (0=No, 1=Si)
	*************************************************************************/
	FUNCTION f_tip_ageredcom_down(
			p_emp	IN	NUMBER,
			 p_age	IN	NUMBER,
			 p_tip	IN	NUMBER
	)   RETURN NUMBER
	IS
	  n_encontrado NUMBER(1);
	CURSOR c1(pc_age1
	IN    NUMBER)

	  IS
	    SELECT *
	    FROM   redcomercial
	    WHERE  cempres = p_emp
	    AND    cpadre = pc_age1
	    AND    fmovfin IS NULL;
	PROCEDURE p_loc_busca(
			p_cagente	IN	NUMBER
	) IS
	CURSOR c2(pc_age2
	IN    NUMBER)

	  IS
	    SELECT *
	    FROM   redcomercial
	    WHERE  cempres = p_emp
	    AND    cpadre = pc_age2
	    AND    fmovfin IS NULL;

	BEGIN
	  FOR f2 IN c2(p_cagente)
	  LOOP
	    IF f2.ctipage = p_tip THEN
	      n_encontrado := 1;
	    END IF;
	    IF n_encontrado = 0 THEN
	      p_loc_busca(f2.cagente);
	    END IF;
	  END LOOP;
	END;
	BEGIN
	  n_encontrado := 0;
	  SELECT nvl(max(1), 0)
	  INTO   n_encontrado
	  FROM   redcomercial
	  WHERE  cempres = p_emp
	  AND    cagente = p_age
	  AND    ctipage = p_tip
	  AND    fmovfin IS NULL;

	  IF n_encontrado = 0 THEN
	    FOR f1 IN c1(p_age)
	    LOOP
	      IF f1.ctipage = p_tip THEN
	        n_encontrado := 1;
	      END IF;
	      IF n_encontrado = 0 THEN
	        p_loc_busca(f1.cagente);
	      END IF;
	    END LOOP;
	  END IF;
	  RETURN n_encontrado;
	END f_tip_ageredcom_down;
	/* fin Bug 0021672 - 17/05/2012 - JMF*/
	/* ini Bug 0021672 - 17/05/2012 - JMF*/
	/*************************************************************************
	Funci¿n para evitar que existan 2 tipos de agente iguales en una rama del agente.
	Busca el tipo agente, en la redcomercial en jerarquia sentido hacia arriba.
	param in p_emp  : c¿digo de la empresa
	param in p_age  : c¿digo del agente
	param in p_tip  : tipo agente a buscar
	param in p_pad  : c¿digo del agente padre.
	return          : Tipo encontrado (0=No, 1=Si)
	*************************************************************************/
	FUNCTION f_tip_ageredcom_up(
			p_emp	IN	NUMBER,
			p_age	IN	NUMBER,
			p_tip	IN	NUMBER,
			p_pad	IN	NUMBER
	) RETURN NUMBER
	IS
	  v_pad redcomercial.cpadre%TYPE;
	  v_reg ageredcom.c00%TYPE;
	  v_enc redcomercial.cenlace%TYPE;
	BEGIN
	    v_reg:=0;

	    IF p_pad IS NULL THEN
	      SELECT max(cpadre)
	        INTO v_pad
	        FROM redcomercial a
	       WHERE a.cempres=p_emp AND
	             a.cagente=p_age AND
	             a.fmovfin IS NULL;
	    ELSE
	      v_pad:=p_pad;
	    END IF;

	    IF v_pad IS NOT NULL THEN
	      SELECT nvl(max(decode(p_tip, 0, c00,
	                                   1, c01,
	                                   2, c02,
	                                   3, c03,
	                                   4, c04,
	                                   5, c05,
	                                   6, c06,
	                                   7, c07,
	                                   8, c08,
	                                   9, c09,
	                                   10, c10,
	                                   11, c11,
	                                   12, c12,
	                                   NULL)), 0)
	        INTO v_reg
	        FROM ageredcom
	       WHERE cagente=v_pad AND
	             cempres=p_emp AND
	             fmovfin IS NULL;
	    END IF;

	    IF v_reg=0 THEN
	      /*BUG21672 - JTS - 13/06/2012 - ahora comprobaremos si es un agente de enlace*/
	      FOR i IN (SELECT cagente
	                  FROM redcomercial
	                 WHERE cenlace=p_age AND
	                       cempres=p_emp) LOOP
	          /*Para cada agente del que es enlace comprobamos si las nuevas ramas son compatibles*/
	          SELECT nvl(max(decode(p_tip,
	                         /*0, c00,*/
	                         1, c01, 2, c02,
	                                 3, c03,
	                                 4, c04,
	                                 5, c05,
	                                 6, c06,
	                                 7, c07,
	                                 8, c08,
	                                 9, c09,
	                                 10, c10,
	                                 11, c11,
	                                 12, c12,
	                                 NULL)), 0) cc
	            INTO v_reg
	            FROM ageredcom
	           WHERE cagente=i.cagente AND
	                 cempres=p_emp AND
	                 fmovfin IS NULL;
	      END LOOP;

	      /*SELECT NVL(SUM(1), 0)
	        INTO v_reg
	        FROM (SELECT     ctipage, COUNT(1) c
	                    FROM redcomercial
	                   WHERE fmovfin IS NULL
	              START WITH cagente = p_age
	                     AND cempres = p_emp
	              CONNECT BY (cagente = PRIOR cpadre
	                          OR cagente = PRIOR cenlace)
	                     AND cempres = PRIOR cempres
	                     AND fmovfin IS NULL
	                GROUP BY ctipage)
	       WHERE c > 1;*/
	      IF v_reg=0 THEN
	        RETURN 0;
	      ELSE
	        RETURN 1;
	      END IF;
	    /*Fi BUG21672 - JTS - 13/06/2012*/
	    ELSE
	      RETURN 1;
	    END IF;
	END f_tip_ageredcom_up;

	/* fin Bug 0021672 - 17/05/2012 - JMF*/
	FUNCTION f_act_ageredcom(
			pcagente	IN	NUMBER,
			pcempres	IN	NUMBER,
			pfmovini	IN	DATE
	) RETURN NUMBER
	IS
	  vcagente   NUMBER;
	  vcempres   NUMBER;
	  vctipage   NUMBER;
	  vfmovini   DATE;
	  vfmovfin   DATE;
	  vfbaja     DATE;
	  vc00       NUMBER;
	  vc01       NUMBER;
	  vc02       NUMBER;
	  vc03       NUMBER;
	  vc04       NUMBER;
	  vc05       NUMBER;
	  vc06       NUMBER;
	  vc07       NUMBER;
	  vc08       NUMBER;
	  vc09       NUMBER;
	  vc10       NUMBER;
	  vc11       NUMBER;
	  vc12       NUMBER;
	  vcpervisio NUMBER;
	  vcpernivel NUMBER;
	  vcpolvisio NUMBER;
	  vcpolnivel NUMBER;
	  votro      NUMBER:=0;
	  vcount     NUMBER;

	  CURSOR c_ageact IS
	    (SELECT cagente,cempres,fmovini
	       FROM ageredcom
	      WHERE cempres=pcempres AND
	            fmovfin IS NULL AND
	            (c00=pcagente  OR
	             c01=pcagente  OR
	             c02=pcagente  OR
	             c03=pcagente  OR
	             c04=pcagente  OR
	             c05=pcagente  OR
	             c06=pcagente  OR
	             c07=pcagente  OR
	             c08=pcagente  OR
	             c09=pcagente  OR
	             c10=pcagente  OR
	             c11=pcagente  OR
	             c12=pcagente));

	  /* Bug 0024871 - 28/11/2012 - JMF*/
	  d_calfec   ageredcom.fmovini%TYPE;
	BEGIN
	    SELECT count(1)
	      INTO vcount
	      FROM ageredcom
	     WHERE cagente=pcagente;

	    IF vcount>0 THEN
	      FOR i IN c_ageact LOOP
	      /* ini Bug 0024871 - 28/11/2012 - JMF*/
	          /* Evitar que la fecha fin sea inferior a fecha inicial*/
	          IF i.fmovini>pfmovini THEN
	            d_calfec:=i.fmovini+1;
	          ELSE
	            d_calfec:=pfmovini;
	          END IF;

	          /* fin Bug 0024871 - 28/11/2012 - JMF*/
	          /* Bug 0024871 - 28/11/2012 - JMF: d_calfec*/
	          UPDATE ageredcom
	             SET fmovfin=d_calfec
	           WHERE cagente=i.cagente AND
	                 cempres=i.cempres AND
	                 fmovini=i.fmovini;

	          FOR c IN (SELECT a.cagente,a.fbajage,r.fmovini,r.cempres
	                      FROM agentes a,redcomercial r
	                     WHERE a.cagente=r.cagente AND
	                           a.cagente=i.cagente AND
	                           r.cempres=i.cempres AND
	                           r.fmovfin IS NULL) LOOP
	              vcagente:=NULL;

	              vcempres:=NULL;

	              vctipage:=NULL;

	              vfmovini:=NULL;

	              vfmovfin:=NULL;

	              vfbaja:=NULL;

	              vc00:=0;

	              vc01:=0;

	              vc02:=0;

	              vc03:=0;

	              vc04:=0;

	              vc05:=0;

	              vc06:=0;

	              vc07:=0;

	              vc08:=0;

	              vc09:=0;

	              vc10:=0;

	              vc11:=0;

	              vc12:=0;

	              vcpervisio:=NULL;

	              vcpernivel:=NULL;

	              vcpolvisio:=NULL;

	              vcpolnivel:=NULL;

	              /* Bug 0024871 - 28/11/2012 - JMF: d_calfec en lugar de pfmovini*/
	              FOR rc IN (SELECT cempres,cagente,d_calfec fmovini,fmovfin,ctipage,cpervisio,cpernivel,cpolvisio,cpolnivel
	                           FROM redcomercial
	                          WHERE fmovfin IS NULL
	                         START WITH cagente=c.cagente AND
	                                    fmovini=c.fmovini AND
	                                    cempres=c.cempres
	                         CONNECT BY (cagente=PRIOR cpadre  OR
	                                                   cagente=PRIOR cenlace) AND
	                                    cempres=PRIOR cempres AND
	                                                  fmovfin IS NULL) LOOP
	                  IF rc.cagente=c.cagente THEN
	                    vcagente:=rc.cagente;

	                    vcempres:=rc.cempres;

	                    vfmovini:=rc.fmovini;

	                    vfmovfin:=rc.fmovfin;

	                    vctipage:=rc.ctipage;

	                    vcpervisio:=rc.cpervisio;

	                    vcpernivel:=rc.cpernivel;

	                    vcpolvisio:=rc.cpolvisio;

	                    vcpolnivel:=rc.cpolnivel;

	                    vfbaja:=c.fbajage;
	                  END IF;

	                  IF votro=1 THEN
	                    IF rc.ctipage=0 THEN
	                      NULL;
	                    ELSIF rc.ctipage=1 THEN
	                      vc00:=0;
	                    ELSIF rc.ctipage=2 THEN
	                      vc00:=0;

	                      vc01:=0;
	                    ELSIF rc.ctipage=3 THEN
	                      vc00:=0;

	                      vc01:=0;

	                      vc02:=0;
	                    ELSIF rc.ctipage=4 THEN
	                      vc00:=0;

	                      vc01:=0;

	                      vc02:=0;

	                      vc03:=0;
	                    ELSIF rc.ctipage=5 THEN
	                      vc00:=0;

	                      vc01:=0;

	                      vc02:=0;

	                      vc03:=0;

	                      vc04:=0;
	                    ELSIF rc.ctipage=6 THEN
	                      vc00:=0;

	                      vc01:=0;

	                      vc02:=0;

	                      vc03:=0;

	                      vc04:=0;

	                      vc05:=0;
	                    ELSIF rc.ctipage=7 THEN
	                      vc00:=0;

	                      vc01:=0;

	                      vc02:=0;

	                      vc03:=0;

	                      vc04:=0;

	                      vc05:=0;

	                      vc06:=0;
	                    ELSIF rc.ctipage=8 THEN
	                      vc00:=0;

	                      vc01:=0;

	                      vc02:=0;

	                      vc03:=0;

	                      vc04:=0;

	                      vc05:=0;

	                      vc06:=0;

	                      vc07:=0;
	                    ELSIF rc.ctipage=9 THEN
	                      vc00:=0;

	                      vc01:=0;

	                      vc02:=0;

	                      vc03:=0;

	                      vc04:=0;

	                      vc05:=0;

	                      vc06:=0;

	                      vc07:=0;

	                      vc08:=0;
	                    ELSIF rc.ctipage=10 THEN
	                      vc00:=0;

	                      vc01:=0;

	                      vc02:=0;

	                      vc03:=0;

	                      vc04:=0;

	                      vc05:=0;

	                      vc06:=0;

	                      vc07:=0;

	                      vc08:=0;

	                      vc09:=0;
	                    ELSIF rc.ctipage=11 THEN
	                      vc00:=0;

	                      vc01:=0;

	                      vc02:=0;

	                      vc03:=0;

	                      vc04:=0;

	                      vc05:=0;

	                      vc06:=0;

	                      vc07:=0;

	                      vc08:=0;

	                      vc09:=0;

	                      vc10:=0;
	                    ELSIF rc.ctipage=12 THEN
	                      vc00:=0;

	                      vc01:=0;

	                      vc02:=0;

	                      vc03:=0;

	                      vc04:=0;

	                      vc05:=0;

	                      vc06:=0;

	                      vc07:=0;

	                      vc08:=0;

	                      vc09:=0;

	                      vc10:=0;

	                      vc11:=0;
	                    ELSE
	                      NULL;
	                    END IF;
	                  END IF;

	                  IF rc.fmovfin IS NOT NULL  OR
	                     votro=1 THEN
	                    vfmovini:=rc.fmovini;

	                    vfmovfin:=rc.fmovfin;

	                    votro:=0;
	                  END IF;

	                  IF rc.ctipage=0 THEN
	                    vc00:=rc.cagente;
	                  ELSIF rc.ctipage=1 THEN
	                    vc01:=rc.cagente;
	                  ELSIF rc.ctipage=2 THEN
	                    vc02:=rc.cagente;
	                  ELSIF rc.ctipage=3 THEN
	                    vc03:=rc.cagente;
	                  ELSIF rc.ctipage=4 THEN
	                    vc04:=rc.cagente;
	                  ELSIF rc.ctipage=5 THEN
	                    vc05:=rc.cagente;
	                  ELSIF rc.ctipage=6 THEN
	                    vc06:=rc.cagente;
	                  ELSIF rc.ctipage=7 THEN
	                    vc07:=rc.cagente;
	                  ELSIF rc.ctipage=8 THEN
	                    vc08:=rc.cagente;
	                  ELSIF rc.ctipage=9 THEN
	                    vc09:=rc.cagente;
	                  ELSIF rc.ctipage=10 THEN
	                    vc10:=rc.cagente;
	                  ELSIF rc.ctipage=11 THEN
	                    vc11:=rc.cagente;
	                  ELSIF rc.ctipage=12 THEN
	                    vc12:=rc.cagente;
	                  ELSE
	                    NULL;
	                  END IF;
	              END LOOP;

	              IF vcagente IS NOT NULL AND
	                 vcempres IS NOT NULL AND
	                 vfmovini IS NOT NULL THEN BEGIN
			INSERT INTO ageredcom
		           (cagente,cempres,ctipage,fmovini,fmovfin,fbaja,
		           c00,c01,c02,c03,c04,
		           c05,c06,c07,c08,c09,
		           c10,c11,c12,cpervisio,cpernivel,
		           cpolvisio,cpolnivel)
		    VALUES
		           (vcagente,vcempres,vctipage,vfmovini,vfmovfin,vfbaja,
		           vc00,vc01,vc02,vc03,vc04,
		           vc05,vc06,vc07,vc08,vc09,
		           vc10,vc11,vc12,vcpervisio,vcpernivel,
		           vcpolvisio,vcpolnivel);

	                EXCEPTION
	                    WHEN dup_val_on_index THEN
	                      NULL;
	                END; votro := 1;
	              END IF;
	          END LOOP;
	      END LOOP;
	    ELSE
	      FOR c IN (SELECT a.cagente,a.fbajage,r.fmovini,r.cempres
	                  FROM agentes a,redcomercial r
	                 WHERE a.cagente=r.cagente AND
	                       a.cagente=pcagente AND
	                       r.cempres=pcempres AND
	                       r.fmovfin IS NULL) LOOP
	          vcagente:=NULL;

	          vcempres:=NULL;

	          vctipage:=NULL;

	          vfmovini:=NULL;

	          vfmovfin:=NULL;

	          vfbaja:=NULL;

	          vc00:=0;

	          vc01:=0;

	          vc02:=0;

	          vc03:=0;

	          vc04:=0;

	          vc05:=0;

	          vc06:=0;

	          vc07:=0;

	          vc08:=0;

	          vc09:=0;

	          vc10:=0;

	          vc11:=0;

	          vc12:=0;

	          vcpervisio:=NULL;

	          vcpernivel:=NULL;

	          vcpolvisio:=NULL;

	          vcpolnivel:=NULL;

	          FOR rc IN (SELECT cempres,cagente,pfmovini fmovini,fmovfin,ctipage,cpervisio,cpernivel,cpolvisio,cpolnivel
	                       FROM redcomercial
	                      WHERE fmovfin IS NULL
	                     START WITH cagente=c.cagente AND
	                                fmovini=c.fmovini AND
	                                cempres=c.cempres
	                     CONNECT BY (cagente=PRIOR cpadre  OR
	                                               cagente=PRIOR cenlace) AND
	                                cempres=PRIOR cempres AND
	                                              fmovfin IS NULL) LOOP
	              IF rc.cagente=c.cagente THEN
	                vcagente:=rc.cagente;

	                vcempres:=rc.cempres;

	                vfmovini:=rc.fmovini;

	                vfmovfin:=rc.fmovfin;

	                vctipage:=rc.ctipage;

	                vcpervisio:=rc.cpervisio;

	                vcpernivel:=rc.cpernivel;

	                vcpolvisio:=rc.cpolvisio;

	                vcpolnivel:=rc.cpolnivel;

	                vfbaja:=c.fbajage;
	              END IF;

	              IF votro=1 THEN
	                IF rc.ctipage=0 THEN
	                  NULL;
	                ELSIF rc.ctipage=1 THEN
	                  vc00:=0;
	                ELSIF rc.ctipage=2 THEN
	                  vc00:=0;

	                  vc01:=0;
	                ELSIF rc.ctipage=3 THEN
	                  vc00:=0;

	                  vc01:=0;

	                  vc02:=0;
	                ELSIF rc.ctipage=4 THEN
	                  vc00:=0;

	                  vc01:=0;

	                  vc02:=0;

	                  vc03:=0;
	                ELSIF rc.ctipage=5 THEN
	                  vc00:=0;

	                  vc01:=0;

	                  vc02:=0;

	                  vc03:=0;

	                  vc04:=0;
	                ELSIF rc.ctipage=6 THEN
	                  vc00:=0;

	                  vc01:=0;

	                  vc02:=0;

	                  vc03:=0;

	                  vc04:=0;

	                  vc05:=0;
	                ELSIF rc.ctipage=7 THEN
	                  vc00:=0;

	                  vc01:=0;

	                  vc02:=0;

	                  vc03:=0;

	                  vc04:=0;

	                  vc05:=0;

	                  vc06:=0;
	                ELSIF rc.ctipage=8 THEN
	                  vc00:=0;

	                  vc01:=0;

	                  vc02:=0;

	                  vc03:=0;

	                  vc04:=0;

	                  vc05:=0;

	                  vc06:=0;

	                  vc07:=0;
	                ELSIF rc.ctipage=9 THEN
	                  vc00:=0;

	                  vc01:=0;

	                  vc02:=0;

	                  vc03:=0;

	                  vc04:=0;

	                  vc05:=0;

	                  vc06:=0;

	                  vc07:=0;

	                  vc08:=0;
	                ELSIF rc.ctipage=10 THEN
	                  vc00:=0;

	                  vc01:=0;

	                  vc02:=0;

	                  vc03:=0;

	                  vc04:=0;

	                  vc05:=0;

	                  vc06:=0;

	                  vc07:=0;

	                  vc08:=0;

	                  vc09:=0;
	                ELSIF rc.ctipage=11 THEN
	                  vc00:=0;

	                  vc01:=0;

	                  vc02:=0;

	                  vc03:=0;

	                  vc04:=0;

	                  vc05:=0;

	                  vc06:=0;

	                  vc07:=0;

	                  vc08:=0;

	                  vc09:=0;

	                  vc10:=0;
	                ELSIF rc.ctipage=12 THEN
	                  vc00:=0;

	                  vc01:=0;

	                  vc02:=0;

	                  vc03:=0;

	                  vc04:=0;

	                  vc05:=0;

	                  vc06:=0;

	                  vc07:=0;

	                  vc08:=0;

	                  vc09:=0;

	                  vc10:=0;

	                  vc11:=0;
	                ELSE
	                  NULL;
	                END IF;
	              END IF;

	              IF rc.fmovfin IS NOT NULL  OR
	                 votro=1 THEN
	                vfmovini:=rc.fmovini;

	                vfmovfin:=rc.fmovfin;

	                votro:=0;
	              END IF;

	              IF rc.ctipage=0 THEN
	                vc00:=rc.cagente;
	              ELSIF rc.ctipage=1 THEN
	                vc01:=rc.cagente;
	              ELSIF rc.ctipage=2 THEN
	                vc02:=rc.cagente;
	              ELSIF rc.ctipage=3 THEN
	                vc03:=rc.cagente;
	              ELSIF rc.ctipage=4 THEN
	                vc04:=rc.cagente;
	              ELSIF rc.ctipage=5 THEN
	                vc05:=rc.cagente;
	              ELSIF rc.ctipage=6 THEN
	                vc06:=rc.cagente;
	              ELSIF rc.ctipage=7 THEN
	                vc07:=rc.cagente;
	              ELSIF rc.ctipage=8 THEN
	                vc08:=rc.cagente;
	              ELSIF rc.ctipage=9 THEN
	                vc09:=rc.cagente;
	              ELSIF rc.ctipage=10 THEN
	                vc10:=rc.cagente;
	              ELSIF rc.ctipage=11 THEN
	                vc11:=rc.cagente;
	              ELSIF rc.ctipage=12 THEN
	                vc12:=rc.cagente;
	              ELSE
	                NULL;
	              END IF;
	          END LOOP;

	          IF vcagente IS NOT NULL AND
	             vcempres IS NOT NULL AND
	             vfmovini IS NOT NULL THEN BEGIN
			INSERT INTO ageredcom
		           (cagente,cempres,ctipage,fmovini,fmovfin,fbaja,
		           c00,c01,c02,c03,c04,
		           c05,c06,c07,c08,c09,
		           c10,c11,c12,cpervisio,cpernivel,
		           cpolvisio,cpolnivel)
		    VALUES
		           (vcagente,vcempres,vctipage,vfmovini,vfmovfin,vfbaja,
		           vc00,vc01,vc02,vc03,vc04,
		           vc05,vc06,vc07,vc08,vc09,
		           vc10,vc11,vc12,vcpervisio,vcpernivel,
		           vcpolvisio,vcpolnivel);

	            EXCEPTION
	                WHEN dup_val_on_index THEN
	                  NULL;
	            END; votro := 1;
	          END IF;
	      END LOOP;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_act_ageredcom', 2, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_act_ageredcom;
	FUNCTION f_del_ultageredcom(
			pcagente	IN	NUMBER,
			pcempres	IN	NUMBER,
			pfmovini	IN	DATE
	) RETURN NUMBER
	IS
	  CURSOR c_ageact IS
	    (SELECT cagente,cempres,fmovini
	       FROM ageredcom
	      WHERE cempres=pcempres AND
	            fmovfin IS NULL AND
	            (c00=pcagente  OR
	             c01=pcagente  OR
	             c02=pcagente  OR
	             c03=pcagente  OR
	             c04=pcagente  OR
	             c05=pcagente  OR
	             c06=pcagente  OR
	             c07=pcagente  OR
	             c08=pcagente  OR
	             c09=pcagente  OR
	             c10=pcagente  OR
	             c11=pcagente  OR
	             c12=pcagente));
	BEGIN
	    FOR i IN c_ageact LOOP
	        DELETE ageredcom
	         WHERE cagente=i.cagente AND
	               cempres=i.cempres AND
	               fmovini=i.fmovini;

	        UPDATE ageredcom
	           SET fmovfin=NULL
	         WHERE cagente=i.cagente AND
	               cempres=i.cempres AND
	               fmovfin=i.fmovini;
	    END LOOP;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_del_ultageredcom', 2, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_del_ultageredcom;

	/*------------------------------------------------------------------------------------------*/
	/* F.1*/
	FUNCTION calcul_redcomseg(
			pcemp	IN	NUMBER,
			pcage	IN	NUMBER,
			psseg	IN	NUMBER,
			pfini	IN	DATE,
			pffin	IN	DATE
	) RETURN NUMBER
	IS
	  /* Bug 18225 - APD - 11/04/2011 - la precisi¿n debe ser NUMBER*/
	  TYPE redcom
	    IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

	  c_grab        REDCOM;
	  /* el indice es el nivel en la red comercial y el contenido*/
	  /* es el agente que tiene el rol, 0 si no hay agente para ese nivel.*/
	  c_ant         REDCOM; /*auxiliar*/
	  c_nou         REDCOM; /*auxiliar*/
	  c_ini         REDCOM; /* inicial*/
	  agent_inicial BOOLEAN:=TRUE;
	  finigrab      DATE;
	  ffingrab      DATE;
	  finiage       DATE;
	  finiant       DATE;
	  finiper       DATE;
	  finiseg       DATE;
	  num_err       NUMBER:=0;
	  linea         NUMBER;
	  algun_gravat  NUMBER:=0;
	BEGIN
	    /* seleccionamos la fecha inicial del seguro para poder grabar fefecto*/
	    BEGIN
	        SELECT least(trunc(fmovimi), trunc(fefecto))
	          INTO finiseg
	          FROM movseguro
	         WHERE sseguro=psseg AND
	               nmovimi=1;

	        finigrab:=finiseg;
	    EXCEPTION
	        WHEN no_data_found THEN
	        /*  Agafem la mes petita entre la data d'efecte del*/
	          /* seguro i la data del dia.*/
	          IF f_sysdate<pfini THEN
	            finiseg:=f_sysdate;
	          ELSE
	            finiseg:=pfini;
	          /* Cambio debido a la modificacion del trigger ACTUALIZ_SEGUREDCOM*/
	          END IF;
	        WHEN OTHERS THEN
	          num_err:=104349; /*  error al leer de la tabla movseguro*/

	          RETURN(num_err);
	    END;

	    /* seleccionamos la fecha inicial del agente en la red comercial para la empresa*/
	    SELECT min(fmovini)
	      INTO finiage
	      FROM redcomercial
	     WHERE cempres=pcemp AND
	           cagente=pcage;

	    IF finiage IS NOT NULL THEN
	    /* existe este agente en esta empresa*/
	    /* cogemos como fecha inicial la m¿xima entre la fecha inicial que llega*/
	    /* por parametro (la de emisi¿n, la de suplemento, ...) y la inicial del agente*/
	      /* en la empresa.*/
	      IF pfini<finiage THEN
	        finiper:=finiage;
	      ELSE
	        finiper:=pfini;
	      END IF;

	      FOR i IN 0 .. 12 LOOP
	          c_ant(i):=0;

	          c_nou(i):=0;

	          c_grab(i):=0;
	      END LOOP;

	    /*  Obtenir l'estat inicial, per no grabar repetits,*/
	      /*               i l'assignem com a anterior*/
	      BEGIN
	          SELECT c00,c10,c11,c12,c06,c01,c09,c07,c04,c05,c08,c02,c03
	            INTO c_ini(0), c_ini(10), c_ini(11), c_ini(12),
	          c_ini(6), c_ini(1), c_ini(9), c_ini(7),
	          c_ini(4), c_ini(5), c_ini(8), c_ini(2), c_ini(3)
	            FROM seguredcom
	           WHERE sseguro=psseg AND
	                 nlinea=(SELECT max(nlinea)
	                           FROM seguredcom
	                          WHERE sseguro=psseg);

	          FOR i IN 0 .. 12 LOOP
	              c_ant(i):=c_ini(i);
	          END LOOP;
	      EXCEPTION
	          WHEN no_data_found THEN
	            FOR i IN 0 .. 12 LOOP
	                c_ini(i):=0;
	            END LOOP;
	      END;

	    /*dbms_output.put_line('ini '||c_ini(0)||'-'||c_ini(10)||'-'||c_ini(11)||'-'||c_ini(12)||'-'||c_ini(6)||'-'||c_ini(1)||'-'||c_ini(9)||'-'||*/
	    /*            c_ini(7)||'-'||c_ini(4)||'-'||c_ini(5)||'-'||c_ini(8)||'-'||c_ini(2)||'-'||c_ini(3));*/
	    /*dbms_output.put_line('ant '||c_ant(0)||'-'||c_ant(10)||'-'||c_ant(11)||'-'||c_ant(12)||'-'||c_ant(6)||'-'||c_ant(1)||'-'||c_ant(9)||'-'||*/
	    /*            c_ant(7)||'-'||c_ant(4)||'-'||c_ant(5)||'-'||c_ant(8)||'-'||c_ant(2)||'-'||c_ant(3));*/
	      /* Obtenim el n¿mero de l¿nia*/
	      SELECT nvl(max(nlinea), 0)+1
	        INTO linea
	        FROM seguredcom
	       WHERE sseguro=psseg;

	      /*dbms_output.put_line(' INICI DEL BUCLE ');*/
	      FOR dc IN dias_cambio(finiper, pffin, pcemp, pcage) LOOP
	          FOR rcd IN rc_dia(dc.fmvini, pcemp, pcage) LOOP
	              IF rcd.ctipage IN(13, 14, 15, 19) THEN
	                c_nou(2):=rcd.cagente;
	              ELSIF rcd.ctipage IN(16, 17, 18) THEN
	                c_nou(5):=rcd.cagente;
	              ELSE
	                c_nou(rcd.ctipage):=rcd.cagente;
	              END IF;
	          END LOOP;

	          /*dbms_output.put_line('actualitza NOU  '||c_nou(0)||'-'||c_nou(10)||'-'||c_nou(11)||'-'||c_nou(12)||'-'||c_nou(6)||'-'||c_nou(1)||'-'||c_nou(9)||'-'||*/
	          /*            c_nou(7)||'-'||c_nou(4)||'-'||c_nou(5)||'-'||c_nou(8)||'-'||c_nou(2)||'-'||c_nou(3));*/
	          IF agent_inicial THEN
	            agent_inicial:=FALSE;

	          /*dbms_output.put_line('DC.FMVINI '||DC.FMVINI);*/
	            /*dbms_output.put_line('PFINI '||PFINI);*/
	            IF pfini<dc.fmvini THEN
	              finiant:=pfini;

	            /* Per calcular correctament la data d'inici que s'ha de grabar*/
	              /* en el cas d'un sol registre en la modificacio*/
	              finigrab:=pfini;
	            ELSE
	              finiant:=dc.fmvini;

	            /* Per calcular correctament la data d'inici que s'ha de grabar*/
	              /* en el cas d'un sol registre en la modificacio*/
	              finigrab:=dc.fmvini;
	            END IF;

	          /*dbms_output.put_line('FINIANT ---------------->'||FINIANT);*/
	            /*dbms_output.put_line('FINIGRAB ---------------->'||FINIGRAB);*/
	            FOR i IN 0 .. 12 LOOP
	                c_grab(i):=c_nou(i);
	            END LOOP;
	          /*dbms_output.put_line('GUARDEM grab '||c_grab(0)||'-'||c_grab(10)||'-'||c_grab(11)||'-'||c_grab(12)||'-'||c_grab(6)||'-'||c_grab(1)||'-'||c_grab(9)||'-'||*/
	          /*           c_grab(7)||'-'||c_grab(4)||'-'||c_grab(5)||'-'||c_grab(8)||'-'||c_grab(2)||'-'||c_grab(3));*/
	          ELSE
	            IF c_ant(0)<>c_nou(0)  OR
	               c_ant(1)<>c_nou(1)  OR
	               c_ant(2)<>c_nou(2)  OR
	               c_ant(3)<>c_nou(3)  OR
	               c_ant(4)<>c_nou(4)  OR
	               c_ant(5)<>c_nou(5)  OR
	               c_ant(6)<>c_nou(6)  OR
	               c_ant(7)<>c_nou(7)  OR
	               c_ant(8)<>c_nou(8)  OR
	               c_ant(9)<>c_nou(9)  OR
	               c_ant(10)<>c_nou(10)  OR
	               c_ant(11)<>c_nou(11)  OR
	               c_ant(12)<>c_nou(12) THEN
	              /* Cal mirar si ¿s diferent a l'inicial*/
	              ffingrab:=dc.fmvini;

	              /*dbms_output.put_line('FFINGRAB ---------------->'||FFINGRAB);*/
	              IF c_grab(0)<>c_ini(0)  OR
	                 c_grab(1)<>c_ini(1)  OR
	                 c_grab(2)<>c_ini(2)  OR
	                 c_grab(3)<>c_ini(3)  OR
	                 c_grab(4)<>c_ini(4)  OR
	                 c_grab(5)<>c_ini(5)  OR
	                 c_grab(6)<>c_ini(6)  OR
	                 c_grab(7)<>c_ini(7)  OR
	                 c_grab(8)<>c_ini(8)  OR
	                 c_grab(9)<>c_ini(9)  OR
	                 c_grab(10)<>c_ini(10)  OR
	                 c_grab(11)<>c_ini(11)  OR
	                 c_grab(12)<>c_ini(12) THEN
	              /*dbms_output.put_line(' grab ¿s diferen de ini ');*/
	              BEGIN
			INSERT INTO seguredcom
		           (sseguro,cempres,cageseg,fefecto,fanulac,fmovini,
		           fmovfin,fproces,c00,c10,c11,
		           c12,c06,c01,c09,c07,
		           c04,c05,c08,c02,c03,
		           nlinea)
		    VALUES
		           (psseg,pcemp,pcage,finiseg,NULL,trunc(finigrab),
		           trunc(ffingrab),f_sysdate,c_grab(0),c_grab(10),c_grab(11),
		           c_grab(12),c_grab(6),c_grab(1),c_grab(9),c_grab(7),
		           c_grab(4),c_grab(5),c_grab(8),c_grab(2),c_grab(3),
		           linea);


	                    /*            dbms_output.put_line('inserto grab '||c_grab(0)||'-'||c_grab(10)||'-'||c_grab(11)||'-'||c_grab(12)||'-'||c_grab(6)||'-'||c_grab(1)||'-'||c_grab(9)||'-'||*/
	                    /*           c_grab(7)||'-'||c_grab(4)||'-'||c_grab(5)||'-'||c_grab(8)||'-'||c_grab(2)||'-'||c_grab(3));*/
	                    algun_gravat:=1;

	                    linea:=linea+1;
	                EXCEPTION
	                    WHEN OTHERS THEN
	                      /*dbms_output.put_line(sqlerrm);*/
	                      num_err:=107977;

	                      /* error al insertar en seguredcom;*/
	                      RETURN(num_err);
	                END; finigrab := ffingrab;
	              END IF;

	            /* nom¿s actualitzo si grabo  finigrab := ffingrab;*/
	              /*dbms_output.put_line('FINIGRAB PEL SEGUENT---------------->'||FfINGRAB);*/
	              FOR i IN 0 .. 12 LOOP
	                  c_grab(i):=c_nou(i);
	              END LOOP;
	            /*                dbms_output.put_line('guardo a grab el nou '||c_grab(0)||'-'||c_grab(10)||'-'||c_grab(11)||'-'||c_grab(12)||'-'||c_grab(6)||'-'||c_grab(1)||'-'||c_grab(9)||'-'||*/
	            /*               c_grab(7)||'-'||c_grab(4)||'-'||c_grab(5)||'-'||c_grab(8)||'-'||c_grab(2)||'-'||c_grab(3));*/
	            END IF; /* if de si son diferentes*/
	          END IF; /* if de si es el agente inicial*/

	          finiant:=dc.fmvini;

	          /*dbms_output.put_line('FINIant ---------------->'||FINIANT);*/
	          FOR i IN 0 .. 12 LOOP
	              c_ant(i):=c_nou(i);

	              c_nou(i):=0;
	          END LOOP;
	      /*dbms_output.put_line('guardo a ant el nou '||c_ant(0)||'-'||c_ant(10)||'-'||c_ant(11)||'-'||c_ant(12)||'-'||c_ant(6)||'-'||c_ant(1)||'-'||c_ant(9)||'-'||*/
	      /*            c_ant(7)||'-'||c_ant(4)||'-'||c_ant(5)||'-'||c_ant(8)||'-'||c_ant(2)||'-'||c_ant(3));*/
	      END LOOP; /* acaba el for de los dias de cambio*/

	      BEGIN
	      /*dbms_output.put_line('DESPRES DEL LOOP ');*/
	      /*dbms_output.put_line('grab '||c_grab(0)||'-'||c_grab(10)||'-'||c_grab(11)||'-'||c_grab(12)||'-'||c_grab(6)||'-'||c_grab(1)||'-'||c_grab(9)||'-'||*/
	          /*            c_grab(7)||'-'||c_grab(4)||'-'||c_grab(5)||'-'||c_grab(8)||'-'||c_grab(2)||'-'||c_grab(3));*/
	          IF c_ini(0)<>c_grab(0)  OR
	             c_ini(1)<>c_grab(1)  OR
	             c_ini(2)<>c_grab(2)  OR
	             c_ini(3)<>c_grab(3)  OR
	             c_ini(4)<>c_grab(4)  OR
	             c_ini(5)<>c_grab(5)  OR
	             c_ini(6)<>c_grab(6)  OR
	             c_ini(7)<>c_grab(7)  OR
	             c_ini(8)<>c_grab(8)  OR
	             c_ini(9)<>c_grab(9)  OR
	             c_ini(10)<>c_grab(10)  OR
	             c_ini(11)<>c_grab(11)  OR
	             c_ini(12)<>c_grab(12) THEN
	          /*dbms_output.put_line('son diferents, grabar l ultim ');*/
	            /* insert del ¿ltimo registro*/
			INSERT INTO seguredcom
		           (sseguro,cempres,cageseg,fefecto,fanulac,fmovini,
		           fmovfin,fproces,c00,c10,c11,
		           c12,c06,c01,c09,c07,
		           c04,c05,c08,c02,c03,
		           nlinea)
		    VALUES
		           (psseg,pcemp,pcage,finiseg, /* La data d'inici a de ser el de acabament de l'anterior registre.*/ /* pffin, finiant,
		           null, f_sysdate,*/ trunc(pffin),trunc(finigrab),NULL,
		           f_sysdate,c_grab(0),c_grab(10),c_grab(11),c_grab(12),
		           c_grab(6),c_grab(1),c_grab(9),c_grab(7),c_grab(4),
		           c_grab(5),c_grab(8),c_grab(2),c_grab(3),linea);


	            linea:=linea+1;

	            algun_gravat:=1;
	          END IF;
	      EXCEPTION
	          WHEN OTHERS THEN
	            num_err:=107977; /* error al insertar en seguredcom;*/

	            RETURN(num_err);
	      END;

	      agent_inicial:=TRUE;

	      IF algun_gravat=0 THEN
	        UPDATE seguredcom
	           SET fmovfin=NULL
	         WHERE sseguro=psseg AND
	               nlinea=linea-1;
	      END IF;
	    ELSE
	      num_err:=107988; /* no existe el agente para esta empresa*/
	    END IF;

	    RETURN(num_err);
	END calcul_redcomseg;

	/*-----------------------------------------------------------------------------------------------*/
	/* F.2*/
	FUNCTION cambio_redcom_seguro(
			psseg	IN	NUMBER,
			pcemp	IN	NUMBER,
			pcage	IN	NUMBER,
			pfmov	IN	DATE,
			pfanulac	IN	DATE
	) RETURN NUMBER
	IS
	  /***********************************************************************
	     Esta funci¿n se llamar¿ cuando se hayan producido cambios en la tabla
	    redcomercial, y deba actualizarse la tabla seguredcom.
	     Los cambios en la redcomercial pueden ser dos:
	       1. Cambio de agente: en pcage tendremos el codigo del agente nuevo, y
	       2. Cambio de fecha de inicio: en pfmov recibiremos la fecha de inicio
	            del pen¿ltimo registro de la redcomercial para el agente, y empresa
	  ***********************************************************************/
	  wffin   DATE;
	  num_err NUMBER:=0;
	BEGIN
	/* eliminamos la red que ha quedado invalida, copiando los registro a una tabla*/
	    /* de seguridad*/
	    BEGIN
			INSERT INTO seguredcom2
		           (
		    SELECT
		           *
		      FROM
		           seguredcom
		     WHERE
		           sseguro=psseg
		       AND
		           cempres=pcemp
		       AND
		           fmovini>pfmov);

	    EXCEPTION
	        WHEN OTHERS THEN
	          num_err:=107978; /* error al insertar en seguredcom2*/

	          RETURN(num_err);
	    END;

	    DELETE FROM seguredcom
	     WHERE sseguro=psseg AND
	           cempres=pcemp AND
	           fmovini>pfmov;

	    /* cambiamos fmovfin del registro con mayor fmovini a la fecha del movimiento*/
	    /* Actualitzava m¿s d'un registre, i per tant alterava l'hist¿ric*/
	    /*        (s'ha afegit el camp nlinea a seguredcom)*/
	    /*        AND (fmovini, fproces) = (SELECT MAX(fmovini), MAX(fproces)*/
	    BEGIN
	        UPDATE seguredcom
	           SET fmovfin=trunc(pfmov)
	         WHERE sseguro=psseg AND
	               cempres=pcemp AND
	               nlinea=(SELECT max(nlinea)
	                         FROM seguredcom
	                        WHERE sseguro=psseg AND
	                              cempres=pcemp);
	    EXCEPTION
	        WHEN OTHERS THEN
	          num_err:=107980; /* error al modificar la tabla seguredcom*/

	          RETURN(num_err);
	    END;

	    /*  -- recuperamos la fanulac del seguro para calcular su red comercial hasta la fecha
	      No es pot fer, pq les regularitzacions es fan tamb¿ despr¿s de l'anulaci¿
	      BEGIN
	        SELECT  fanulac
	          INTO  wffin
	          FROM  seguros
	          WHERE sseguro = psseg;
	      EXCEPTION
	        WHEN OTHERS THEN
	          num_err := 103286; -- este seguro no existe
	          RETURN(num_err);
	      END;
	    */
	    num_err:=calcul_redcomseg(pcemp, pcage, psseg, pfmov, wffin);

	    IF num_err<>0 THEN
	      RETURN(num_err);
	    END IF;

	    RETURN(num_err);
	END cambio_redcom_seguro;

	/*-----------------------------------------------------------------------------------------------*/
	/* F.3*/
	FUNCTION cambio_seguredcom(
			pcage	IN	NUMBER,
			pcemp	IN	NUMBER,
			fini_nueva	IN	DATE
	) RETURN NUMBER
	IS
	  num_err NUMBER:=0;

	CURSOR segs(

	    pcage                 IN NUMBER,pcemp IN NUMBER) IS
	    /*    SELECT sseguro, fanulac*/
	    SELECT sseguro
	      FROM seguredcom
	     WHERE cempres=pcemp AND
	           (c00=pcage  OR
	            c10=pcage  OR
	            c11=pcage  OR
	            c12=pcage  OR
	            c06=pcage  OR
	            c01=pcage  OR
	            c09=pcage  OR
	            c07=pcage  OR
	            c04=pcage  OR
	            c05=pcage  OR
	            c08=pcage  OR
	            c02=pcage  OR
	            c03=pcage) AND
	           fmovfin IS NULL AND
	           fanulac IS NULL;
	BEGIN
	    FOR s IN segs(pcage, pcemp) LOOP
	        /*    num_err := cambio_redcom_seguro (s.sseguro, pcemp, pcage, fini_nueva, s.fanulac);*/
	        num_err:=cambio_redcom_seguro(s.sseguro, pcemp, pcage, fini_nueva, NULL);

	        IF num_err<>0 THEN
	          RETURN(num_err);
	        END IF;
	    END LOOP;

	    RETURN(num_err);
	END cambio_seguredcom;

	/*-----------------------------------------------------------------------------------------------*/
	/* Bug 21421 - APD - 28/02/2012 - se crea la funcion*/
	FUNCTION cambio_recibosredcom(
			pcage	IN	NUMBER,
			pcemp	IN	NUMBER,
			fini_nueva	IN	DATE
	) RETURN NUMBER
	IS
	  num_err  NUMBER:=0;
	  vcdelega recibos.cdelega%TYPE;

	CURSOR cur_recibos(

	    pcage                 IN NUMBER,pcemp IN NUMBER) IS
	    SELECT nrecibo
	      FROM recibosredcom rrc
	     WHERE cempres=pcemp AND
	           cagente=pcage AND
	           nrecibo IN(SELECT r.nrecibo
	                        FROM recibos r,movrecibo m
	                       WHERE r.nrecibo=m.nrecibo AND
	                             r.cempres=rrc.cempres AND
	                             m.cestrec IN(0, 3) AND
	                             fmovfin IS NULL);
	BEGIN
	    FOR r IN cur_recibos(pcage, pcemp) LOOP
	        DELETE FROM recibosredcom
	         WHERE nrecibo=r.nrecibo;

	        num_err:=f_insrecibor(r.nrecibo, pcemp, pcage, fini_nueva);

	        IF num_err<>0 THEN
	          RETURN(num_err);
	        END IF;

	        vcdelega:=pac_redcomercial.f_busca_padre(pcemp, pcage, 1, fini_nueva);

	        UPDATE recibos
	           SET cdelega=nvl(vcdelega, 0)
	         WHERE nrecibo=r.nrecibo;
	    END LOOP;

	    RETURN(num_err);
	END cambio_recibosredcom;

	/* fin Bug 21421 - APD - 28/02/2012*/
	/*-----------------------------------------------------------------------------------------------*/
	/* F.5*/
	FUNCTION actualiza_anulacion_seguredcom(
			psseg	IN	NUMBER,
			pfanul	IN	DATE
	) RETURN NUMBER
	IS
	  num_err NUMBER:=0;
	BEGIN
	    BEGIN
	        UPDATE seguredcom
	           SET fanulac=pfanul
	         WHERE sseguro=psseg AND
	               fmovfin IS NULL;
	    EXCEPTION
	        WHEN OTHERS THEN
	          num_err:=107980; /* error al modificar la tabla seguredcom*/

	          RETURN(num_err);
	    END;

	    RETURN(num_err);
	END actualiza_anulacion_seguredcom;

	/*-----------------------------------------------------------------------------------------------*/
	/* F.6*/
	FUNCTION valida_agenterehabilitacion(
			pcage_ant	IN	NUMBER,
			pcemp	IN	NUMBER,
			frehab	IN	DATE,
			pcage_nou	IN	NUMBER,
			pcorrecto	OUT	NUMBER
	) RETURN NUMBER
	IS
	  pcorr1   NUMBER;
	  wfbajage DATE;
	  num_err  NUMBER:=0;
	BEGIN
	    IF pcage_nou IS NULL THEN
	      num_err:=agente_valido(pcage_ant, pcemp, frehab, NULL, pcorr1);

	      IF num_err<>0 THEN
	        RETURN(num_err);
	      END IF;
	    ELSE BEGIN
	          SELECT rc.fmovfin
	            INTO wfbajage
	            FROM redcomercial rc
	           WHERE rc.cagente=pcage_ant AND
	                 rc.cempres=pcemp AND
	                 rc.fmovini=(SELECT max(rc2.fmovini)
	                               FROM redcomercial rc2
	                              WHERE rc2.cagente=rc.cagente AND
	                                    rc2.cempres=rc.cempres);
	      EXCEPTION
	          WHEN OTHERS THEN
	            num_err:=104358; /*  error en la tabla redcomercial*/

	            RETURN(num_err);
	      END; num_err := agente_valido(pcage_ant, pcemp, frehab, wfbajage, pcorr1); IF num_err <> 0 THEN RETURN(num_err); END IF; IF pcorr1 = 0 THEN num_err := agente_valido(pcage_nou, pcemp, wfbajage, NULL, pcorr1); IF num_err <> 0 THEN RETURN(num_err); END IF; END IF;
	    END IF;

	    IF pcorr1>0 THEN
	      pcorrecto:=1;
	    ELSE
	      pcorrecto:=0;
	    END IF;

	    RETURN(num_err);
	END valida_agenterehabilitacion;

	/*-----------------------------------------------------------------------------------------------*/
	/* F.7*/
	FUNCTION rehabilitacion_seguro(
			psseg	IN	NUMBER,
			pcage_act	IN	NUMBER,
			pcemp	IN	NUMBER,
			frehab	IN	DATE,
			pcage_ant	IN	NUMBER
	) RETURN NUMBER
	IS
	  pcorr1   NUMBER;
	  wfiniage DATE;
	  wfbajage DATE;
	  num_err  NUMBER:=0;
	BEGIN
	    BEGIN
	        SELECT rc.fmovfin
	          INTO wfbajage
	          FROM redcomercial rc
	         WHERE rc.cagente=pcage_ant AND
	               rc.cempres=pcemp AND
	               rc.fmovini=(SELECT max(rc2.fmovini)
	                             FROM redcomercial rc2
	                            WHERE rc2.cagente=rc.cagente AND
	                                  rc2.cempres=rc.cempres);
	    EXCEPTION
	        WHEN OTHERS THEN
	          num_err:=104358; /*  error en la tabla redcomercial*/

	          RETURN(num_err);
	    END;

	    BEGIN
	        SELECT fmovini
	          INTO wfiniage
	          FROM seguredcom
	         WHERE sseguro=psseg AND
	               cempres=pcemp AND
	               fmovfin IS NULL;
	    EXCEPTION
	        WHEN OTHERS THEN
	          num_err:=8888; /* error en la tabla seguredcom*/

	          RETURN(num_err);
	    END;

	    IF pcage_ant=pcage_act THEN
	      num_err:=valida_agenterehabilitacion(pcage_act, pcemp, frehab, NULL, pcorr1);

	      IF num_err<>0 THEN
	        RETURN(num_err);
	      END IF;

	      IF pcorr1>0 THEN
	        num_err:=107981; /*  error al validar el agente*/
	      ELSE
	        num_err:=cambio_redcom_seguro(psseg, pcemp, pcage_act, wfiniage, NULL);

	        IF num_err<>0 THEN
	          RETURN(num_err);
	        END IF;
	      END IF;
	    ELSE
	      num_err:=valida_agenterehabilitacion(pcage_ant, pcemp, frehab, pcage_act, pcorr1);

	      IF num_err<>0 THEN
	        RETURN(num_err);
	      END IF;

	      IF pcorr1>0 THEN
	        num_err:=107981; /*  error al validar el agente*/
	      ELSE
	        num_err:=cambio_redcom_seguro(psseg, pcemp, pcage_ant, wfiniage, NULL);

	        IF num_err<>0 THEN
	          RETURN(num_err);
	        END IF;

	        BEGIN
	            UPDATE seguredcom
	               SET fmovfin=trunc(wfbajage)
	             WHERE sseguro=psseg AND
	                   cempres=pcemp AND
	                   fmovfin IS NULL;
	        EXCEPTION
	            WHEN OTHERS THEN
	              num_err:=107980;

	              RETURN(num_err);
	        END;

	        num_err:=calcul_redcomseg(pcemp, pcage_act, psseg, wfbajage, NULL);

	        IF num_err<>0 THEN
	          RETURN(num_err);
	        END IF;
	      END IF;
	    END IF;

	    RETURN(num_err);
	END rehabilitacion_seguro;

	/*-----------------------------------------------------------------------------------------------*/
	/* F.8*/
	FUNCTION valida_fechacambio_tipo(
			pcage	IN	NUMBER,
			pfcambio	IN	DATE,
			pcorrecto	OUT	NUMBER
	) RETURN NUMBER
	IS
	  /***********************************************************************
	    pcorrecto:   0 cuando la fecha sea correcta
	        1 cuando la fecha no sea correcta ya que en alguna de las
	          empresas en que esta definido el agente el ¿ltimo registro
	          est¿ acabado o tiene fecha inicio mayor que la fecha de cambio
	  ***********************************************************************/
	CURSOR emp_fechafinage(

	    pcage IN NUMBER) IS
	    SELECT cempres,fmovini fini,fmovfin ffin
	      FROM redcomercial
	     WHERE cagente=pcage AND
	           (cempres, fmovini) IN(SELECT cempres,max(fmovini)
	                                   FROM redcomercial
	                                  WHERE cagente=pcage
	                                  GROUP BY cempres);

	  num_err       NUMBER:=0;
	  existe_agente BOOLEAN:=FALSE;
	BEGIN
	    pcorrecto:=0;

	    FOR emp IN emp_fechafinage(pcage) LOOP
	        existe_agente:=TRUE;

	        /*posat el <=*/
	        IF emp.ffin IS NOT NULL  OR
	           pfcambio<=emp.fini THEN
	          pcorrecto:=1;
	        END IF;
	    END LOOP;

	    /* IF not existe_agente THEN
	         pcorrecto := 2;
	         num_err := 6666;  -- no existe el agente en ninguna empresa
	       END IF;
	    */
	    RETURN(num_err);
	END valida_fechacambio_tipo;

	/*-----------------------------------------------------------------------------------------------*/
	/* F.9*/
	FUNCTION actualiza_tipoagente(
			pcage	IN	NUMBER,
			pctip_nou	IN	NUMBER,
			fmov	IN	DATE
	) RETURN NUMBER
	IS
	  /***********************************************************************
	     Esta funci¿n actualiza el tipo de agente en la red comercial, es decir,
	    a¿ade un registro para cada empresa en la que este definido el agente con
	    el nuevo tipo.
	    Validamos que el agente est¿ acivo en todas las empresas en las que est¿
	    definido.
	  ***********************************************************************/
	CURSOR emp(

	    pcage IN NUMBER) IS
	    SELECT cempres,cpadre,ccomindt,cpervisio,cpernivel,cageind,cpolvisio,cpolnivel,cenlace
	      FROM redcomercial
	     WHERE cagente=pcage AND
	           fmovfin IS NULL;

	  pcorr1  NUMBER;
	  num_err NUMBER:=0;
	BEGIN
	    num_err:=valida_fechacambio_tipo(pcage, fmov, pcorr1);

	    IF num_err<>0 THEN
	      RETURN(num_err);
	    END IF;

	    /* ini Bug 0021672 - 17/05/2012 - JMF*/
	    /* Validar tipo agente ¿nico en rama del agente de su redcomercial*/
	    FOR f1 IN emp(pcage) LOOP
	        num_err:=f_tip_ageredcom_down(f1.cempres, pcage, pctip_nou);

	        IF num_err=1 THEN
	          /* Existe otro agente del mismo tipo definido en la red comercial.*/
	          RETURN 9903706;
	        END IF;

	        /* busca ctipage del agente, en jerarqu¿a del nuevo padre hacia arriba.*/
	        num_err:=f_tip_ageredcom_up(f1.cempres, pcage, pctip_nou, NULL);

	        IF num_err=1 THEN
	          /* Existe otro agente del mismo tipo definido en la red comercial.*/
	          RETURN 9903706;
	        END IF;
	    END LOOP;

	    /* fin Bug 0021672 - 17/05/2012 - JMF*/
	    IF pcorr1>0 THEN
	    /* num_err := 107982;   --  error al validar el cambio de tipo*/
	    /* Bug 11444 - 20/10/2009 - AMC - Si se intenta cambiar el tipo de agente el mismo dia de la creaci¿n se actualiza*/
	    /* el ctipage de agentes y de  redcomarcial pero sin crear una nueva red.*/
	    BEGIN
	          UPDATE agentes
	             SET ctipage=pctip_nou
	           WHERE cagente=pcage;
	      EXCEPTION
	          WHEN OTHERS THEN
	            num_err:=104581; /* error al modificar al tabla agentes*/

	            RETURN(num_err);
	      END; BEGIN UPDATE redcomercial SET ctipage = pctip_nou WHERE cagente = pcage AND fmovfin IS NULL; EXCEPTION WHEN OTHERS THEN num_err := 104558; /* error al modificar la tabla redcomercial*/
	    RETURN(num_err); END;
	    /* Fi Bug 11444 - 20/10/2009 - AMC*/
	    /* ini Bug 0024871 - 28/11/2012 - JMF*/
	    /* Si se actualiza el tipo agente, se debe regenerar ageredcom*/
	    FOR f2 IN emp(pcage) LOOP
	    /* recalculamos ageredcom*/
	    num_err := f_act_ageredcom(pcage, f2.cempres, fmov); IF num_err <> 0 THEN RETURN(num_err); END IF; END LOOP;
	    /* fin Bug 0024871 - 28/11/2012 - JMF*/
	    ELSE BEGIN
	          UPDATE agentes
	             SET ctipage=pctip_nou
	           WHERE cagente=pcage;
	      EXCEPTION
	          WHEN OTHERS THEN
	            num_err:=104581; /* error al modificar al tabla agentes*/

	            RETURN(num_err);
	      END; FOR e IN emp(pcage) LOOP BEGIN UPDATE redcomercial SET fmovfin = trunc(fmov) WHERE cagente = pcage AND cempres = e.cempres AND fmovfin IS NULL; EXCEPTION WHEN OTHERS THEN num_err := 104558;
	    /* error al modificar la tabla redcomercial*/
			           RETURN
		(num_err); END; BEGIN INSERT INTO redcomercial (cempres, cagente, fmovini, fmovfin, ctipage, cpadre,
		           ccomindt, cpervisio, cpernivel, cageind, cpolvisio,
		           cpolnivel, cenlace)
		    VALUES
		           (e.cempres, pcage, fmov, NULL, pctip_nou, e.cpadre,
		           e.ccomindt, e.cpervisio, e.cpernivel, e.cageind, e.cpolvisio,
		           e.cpolnivel, e.cenlace); EXCEPTION WHEN OTHERS THEN num_err := 107979;

	    /* error al insertar en la tabla redcomercial*/
	    RETURN(num_err); END;
	    /* recalculamos seguredcom desde la fecha inicio del pen¿ltimo registro*/
	    num_err := cambio_seguredcom(pcage, e.cempres, fmov); IF num_err <> 0 THEN RETURN(num_err); END IF;
	    /* recalculamos ageredcom*/
	    num_err := f_act_ageredcom(pcage, e.cempres, fmov); IF num_err <> 0 THEN RETURN(num_err); END IF; END LOOP;
	    END IF;

	    RETURN(num_err);
	END actualiza_tipoagente;

	/*-----------------------------------------------------------------------------------------------*/
	/* F.10*/
	FUNCTION valida_fechabaja_agente(
			pcage	IN	NUMBER,
			pfbaja	IN	DATE,
			pcorrecto	OUT	NUMBER
	) RETURN NUMBER
	IS
	  /***********************************************************************
	    pcorrecto:   0 cuando la fecha sea correcta
	        1 cuando no sea correcta por tener seguros vigentes
	        2 cuando no lo sea por tenerlos anulados o vencidos
	           con fecha posterior
	        3 cuando no lo sea por tener "hijos" en la red comercial
	           vigentes a dia de la baja
	        4 cuando el agente ya no est¿ vigente en ninguna de las
	           empresas
	        5 cuando en alguna empresa en la que el agente est¿ activo
	           la fecha de inicio del ¿ltimo registro sea mayor a la
	           fecha de baja
	  ***********************************************************************/
	  nseg_vigente_Csituac4  NUMBER:=0;
	  nseg_vigente_CReteni4  NUMBER:=0;
	  nseg_anulpost NUMBER:=0;
	  nage_hijo     NUMBER:=0;
	  nage_activo   NUMBER:=0;
	  nage_inimayor NUMBER:=0;
	  num_err       NUMBER:=0;
	BEGIN
	    SELECT count(sseguro)
			INTO nseg_vigente_Csituac4
			FROM seguros
			WHERE cagente=pcage AND
	           csituac NOT IN(2, 3);
		pcorrecto := 0;
	    IF nseg_vigente_Csituac4>0 THEN
			-- Si tiene polizas vigentes como
			-- Propuesta de alta
			-- tiene polizas en CSITUAC <> 2 o 3
			-- y estan en ppat de Alta --> csituac 4

			-- Se verifica si las que estan en Propuesta de Alta (4)
			-- estan en calidad de anuladas (CRETENI in (3,4))
					  -- 3 No aceptada , 4 Anulada

			   -- De las vigentes, todas estan como Propuesta de Alta (4)
			SELECT COUNT(sseguro)
				   INTO nseg_vigente_CReteni4
			FROM seguros
			WHERE cagente = pcage
			 AND csituac IN(4)
			 AND creteni IN(3,4);
			IF nseg_vigente_Csituac4 <> nseg_vigente_CReteni4 then
				-- Si todas las polizas en Situacion Propuesta de Alta (4) NO estan retenidas como Anuladas.
				-- indica que tiene polizas vigentes en otra situacion.
				pcorrecto:=0; -- CELSO - IAXIS-4219 / 07-06-19    pcorrecto:=1 
			END IF;
		END IF;
	    IF pcorrecto = 0 THEN
	      SELECT count(sseguro)
	        INTO nseg_anulpost
	        FROM seguros
	       WHERE cagente=pcage AND
	             csituac IN(2, 3) AND
	             fanulac>pfbaja;

	      IF nseg_anulpost>0 THEN
	        pcorrecto:=2;
	      ELSE
	        SELECT count(cagente)
	          INTO nage_hijo
	          FROM redcomercial
	         WHERE cpadre=pcage AND
	               (fmovfin IS NULL  OR
	                fmovfin>pfbaja);

	        IF nage_hijo>0 THEN
	          pcorrecto:=3;
	        ELSE
	          SELECT count(cagente)
	            INTO nage_activo
	            FROM redcomercial
	           WHERE cagente=pcage AND
	                 fmovfin IS NULL;

	          IF nage_activo=0 THEN
	            pcorrecto:=4;
	          ELSE
	            SELECT count(cagente)
	              INTO nage_inimayor
	              FROM redcomercial
	             WHERE cagente=pcage AND
	                   fmovfin IS NULL AND
	                   fmovini>pfbaja;

	            IF nage_inimayor>0 THEN
	              pcorrecto:=5;
	            ELSE
	              pcorrecto:=0;
	            END IF;
	          END IF;
	        END IF;
	      END IF;
	    END IF;
		IF pcorrecto=0 THEN -- CELSO - 05/06-19 - IAXIS-4219 - Inicio
            pcorrecto:=4;
        END IF;-- CELSO - 05/06-19 - IAXIS-4219 - Fin
	    RETURN(num_err);
	END valida_fechabaja_agente;

	/*-----------------------------------------------------------------------------------------------*/
	/* F.11*/
	FUNCTION fin_agente(
			pcage	IN	NUMBER,
			pfbaja	IN	DATE
	) RETURN NUMBER
	IS
	  num_err   NUMBER:=0;
	  pcorrecto NUMBER;
	BEGIN
	    num_err:=valida_fechabaja_agente(pcage, pfbaja, pcorrecto);

	    IF num_err=0 AND
	       pcorrecto=0 THEN BEGIN
	          UPDATE agentes
	             SET fbajage=pfbaja,cactivo=0
	           WHERE cagente=pcage;
	      EXCEPTION
	          WHEN OTHERS THEN
	            num_err:=104581; /* error al modificar la tabla agentes*/

	            RETURN(num_err);
	      END; BEGIN UPDATE redcomercial SET fmovfin = pfbaja WHERE cagente = pcage AND fmovfin IS NULL; EXCEPTION WHEN OTHERS THEN num_err := 104558; /* error al modificar la tabla redcomercial*/
	    RETURN(num_err); END;
	    ELSE
	      /* Bug 23827/124559 - 02/10/2012 - AMC*/
	      IF pcorrecto=1 THEN
	        num_err:=9904273;
	      ELSIF pcorrecto=2 THEN
	        num_err:=9904274;
	      ELSIF pcorrecto=3 THEN
	        num_err:=9904275;
	      ELSIF pcorrecto=4 THEN
	        num_err:=0;
	      ELSIF pcorrecto=5 THEN
	        num_err:=9904276;
	      END IF;
	    /* Fi Bug 23827/124559 - 02/10/2012 - AMC*/
	    END IF;

	    RETURN(num_err);
	END fin_agente;

	/*-----------------------------------------------------------------------------------------------*/
	/* F.12*/
	FUNCTION rehabilita_agente(
			pcage	IN	NUMBER
	) RETURN NUMBER
	IS
	CURSOR emp(

	    pcage IN NUMBER) IS
	    SELECT cempres,max(fmovini) fini
	      FROM redcomercial
	     WHERE cagente=pcage
	     GROUP BY cempres;

	  num_err           NUMBER:=0;
	  situacion_erronea NUMBER;
	BEGIN
	    SELECT count(*)
	      INTO situacion_erronea
	      FROM redcomercial
	     WHERE cagente=pcage AND
	           fmovfin IS NULL;

	    IF situacion_erronea>0 THEN
	      num_err:=107976; /* conflicto con las fechas de baja del agente*/
	    ELSE BEGIN
	          UPDATE agentes
	             SET fbajage=NULL,cactivo=1
	           WHERE cagente=pcage;
	      EXCEPTION
	          WHEN OTHERS THEN
	            num_err:=104581; /* error al modificar la tabla agentes*/

	            RETURN(num_err);
	      END; BEGIN FOR e IN emp(pcage) LOOP UPDATE redcomercial SET fmovfin = NULL WHERE cagente = pcage AND fmovini = e.fini AND cempres = e.cempres; END LOOP; EXCEPTION WHEN OTHERS THEN num_err := 104558; /* error al modificar la tabla redcomercial*/
	    RETURN(num_err); END;
	    END IF;

	    RETURN(num_err);
	END rehabilita_agente;

	/*-----------------------------------------------------------------------------------------------*/
	/* F.13*/
	FUNCTION agente_valido(
			pcage	IN	NUMBER,
			pcemp	IN	NUMBER,
			fini	IN	DATE,
			ffin	IN	DATE,
			pcorrecto	OUT	NUMBER
	) RETURN NUMBER
	IS
	  /***********************************************************************
	    Esta funci¿n se llamar¿ desde distintos puntos, m¿nimo:
	      a. Nueva producci¿n: "el agente puede aceptar p¿lizas?", se le pasa fini f_sysdate, y
	           ffin a null.
	      b. Cambio de padre en el registro activo de la redcomercial: "el nuevo padre est¿
	           en situaci¿n de serlo?", se le pasa la fini del ¿ltimo registro de la redcomercial
	           y ffin a null.
	      c. Cambio de la fecha inicio del registro activo de la redcomercial: "el padre actual
	           sigue pudiendo aceptar como hijos a partir de la nueva fecha inicio?", se le pasa
	           la nueva fini del ¿ltimo registro de la redcomercial y ffin a null.
	           "el padre del registro anterior puede seguir siendo padre en el nuevo intervalo?",
	           se le pasa la fini del pen¿ltimo registro y la nueva fini del ¿ltimo.
	      d. Alta de un registro de la redcomercial: "el nuevo padre puede asumir el hijo?", se le
	            pasa fini la fecha del cambio y ffin a null
	      e. Baja de un registro de la redcomercial: "el padre anterior puede asumir el cambio?",
	            se le pasa fini la fecha inicio del registro anterior, y ffin a null.
	      f. Rehabilitaci¿n de una p¿liza: "el agente es valido?", se le pasa fini la fecha de
	            rehabilitaci¿n y ffin a null
	    pcorrecto:   0 cuando el agente est¿ activo durante todo el periodo
	                  1 cuando no lo sea por "empezar" despu¿s de la fecha inicio
	                       (primera fecha inicio en la red comercial para la empresa)
	                  2 cuando no lo sea por "terminar" antes de la fecha fin
	                       (fecha final del ultimo registro de la red comercial para la empresa)
	  ***********************************************************************/
	  inicio_valido NUMBER;
	  final_valido  NUMBER;
	  num_err       NUMBER:=0;
	BEGIN
	    SELECT count(*)
	      INTO inicio_valido
	      FROM redcomercial
	     WHERE cagente=pcage AND
	           cempres=pcemp AND
	           fmovini<=fini;

	    IF inicio_valido=0 THEN
	      pcorrecto:=1;
	    ELSE
	      SELECT count(*)
	        INTO final_valido
	        FROM redcomercial
	       WHERE cagente=pcage AND
	             cempres=pcemp AND
	             (fmovfin IS NULL  OR
	              ((fmovfin>=ffin  OR
	                fmovfin IS NULL) AND
	               ffin IS NOT NULL));

	      IF final_valido=0 THEN
	        pcorrecto:=2;
	      ELSE
	        pcorrecto:=0;
	      END IF;
	    END IF;

	    RETURN(num_err);
	END agente_valido;

	/*-----------------------------------------------------------------------------------------------*/
	/* F.14*/
	FUNCTION valida_cambiofechainicio(
			pcage	IN	NUMBER,
			pcemp	IN	NUMBER,
			fini_nueva	IN	DATE,
			pcorrecto	OUT	NUMBER
	) RETURN NUMBER
	IS
	  /***********************************************************************
	    pcorrecto:   0 cuando la fecha sea correcta
	        1 cuando no sea correcta ya que el padre del ¿ltimo registro
	           no puede asumir el cambio
	        2 cuando no sea correcta ya que la fecha es anterior a
	                          la fecha de inicio del pen¿ltimo registro
	                  3 cuando no sea correcta ya que el padre del pen¿ltimo registro
	                          no puede asumir el cambio
	  ***********************************************************************/
	  pcorr1         NUMBER;
	  padre_actual   NUMBER;
	  padre_anterior NUMBER;
	  fini_anterior  DATE;
	  existe_padre   BOOLEAN:=TRUE;
	  num_err        NUMBER:=0;
	BEGIN
	    BEGIN
	        SELECT cpadre
	          INTO padre_actual
	          FROM redcomercial
	         WHERE cempres=pcemp AND
	               cagente=pcage AND
	               fmovfin IS NULL;
	    EXCEPTION
	        WHEN OTHERS THEN
	          num_err:=104358; /*  error en la tabla redcomercial*/

	          RETURN(num_err);
	    END;

	    num_err:=agente_valido(padre_actual, pcemp, fini_nueva, NULL, pcorr1);

	    IF num_err<>0 THEN
	      RETURN(num_err);
	    END IF;

	    IF pcorr1>0 THEN
	      pcorrecto:=1;
	    ELSE BEGIN
	          SELECT fmovini,cpadre
	            INTO fini_anterior, padre_anterior
	            FROM redcomercial
	           WHERE cempres=pcemp AND
	                 cagente=pcage AND
	                 fmovfin=(SELECT fmovini
	                            FROM redcomercial
	                           WHERE cagente=pcage AND
	                                 cempres=pcemp AND
	                                 fmovfin IS NULL);
	      EXCEPTION
	          WHEN no_data_found THEN
	            existe_padre:=FALSE;
	          WHEN OTHERS THEN
	            num_err:=104358; /*  error en la tabla redcomercial*/

	            RETURN(num_err);
	      END; IF existe_padre THEN IF fini_anterior >= fini_nueva THEN pcorrecto := 2; ELSE num_err := agente_valido(padre_anterior, pcemp, fini_anterior, fini_nueva, pcorr1); IF num_err <> 0 THEN RETURN(num_err); END IF; IF pcorr1 > 0 THEN pcorrecto := 3; ELSE pcorrecto := 0; END IF; END IF; ELSE pcorrecto := 0; END IF;
	    END IF;

	    RETURN(num_err);
	END valida_cambiofechainicio;

	/*-----------------------------------------------------------------------------------------------*/
	/* F.15*/
	FUNCTION cambia_fechainicio_redcom(
			pcage	IN	NUMBER,
			pcemp	IN	NUMBER,
			fini_nueva	IN	DATE
	) RETURN NUMBER
	IS
	  pcorr1   NUMBER;
	  wfmovini DATE;
	  num_err  NUMBER:=0;
	BEGIN
	    num_err:=valida_cambiofechainicio(pcage, pcemp, fini_nueva, pcorr1);

	    IF num_err<>0 THEN
	      RETURN(num_err);
	    END IF;

	    IF pcorr1>0 THEN
	      num_err:=107987;
	    /* error al validar la fecha inicial en la red comercial*/
	    ELSE BEGIN
	          SELECT fmovini
	            INTO wfmovini
	            FROM redcomercial
	           WHERE cagente=pcage AND
	                 cempres=pcemp AND
	                 fmovfin=(SELECT fmovini
	                            FROM redcomercial
	                           WHERE cagente=pcage AND
	                                 cempres=pcemp AND
	                                 fmovfin IS NULL);
	      EXCEPTION
	          WHEN no_data_found THEN
	            /* no hay registro anterior*/
	            wfmovini:=NULL;
	          WHEN OTHERS THEN
	            num_err:=104358; /*  error en la tabla redcomercial*/

	            RETURN(num_err);
	      END; IF wfmovini IS NOT NULL THEN
	    /* actualizamos la fecha final del pen¿ltimo registro*/
	    BEGIN UPDATE redcomercial SET fmovfin = fini_nueva WHERE cagente = pcage AND cempres = pcemp AND fmovfin = (SELECT fmovini FROM redcomercial WHERE cagente = pcage AND cempres = pcemp AND fmovfin IS NULL); EXCEPTION WHEN OTHERS THEN num_err := 104558;
	    /* error al modificar la tabla redcomercial*/
	    RETURN(num_err); END; ELSE wfmovini := fini_nueva; END IF;
	    /* actualizamos la fecha inicial del ¿ltimo registro*/
	    BEGIN UPDATE redcomercial SET fmovini = fini_nueva WHERE cagente = pcage AND cempres = pcemp AND fmovfin IS NULL; EXCEPTION WHEN OTHERS THEN num_err := 104558; /* error al modificar la tabla redcomercial*/
	    RETURN(num_err); END;
	    /* recalculamos seguredcom desde la fecha inicio del pen¿ltimo registro*/
	    num_err := cambio_seguredcom(pcage, pcemp, wfmovini); IF num_err <> 0 THEN RETURN(num_err); END IF;
	    /* recalculamos ageredcom*/
	    num_err := f_act_ageredcom(pcage, pcemp, wfmovini); IF num_err <> 0 THEN RETURN(num_err); END IF;
	    END IF;

	    RETURN(num_err);
	END cambia_fechainicio_redcom;

	/*-----------------------------------------------------------------------------------------------*/
	/* F.16*/
	FUNCTION cambio_padre(
			pcage	IN	NUMBER,
			pcemp	IN	NUMBER,
			padre_nuevo	IN	NUMBER
	) RETURN NUMBER
	IS
	  fini           DATE;
	  pcorr1         NUMBER;
	  num_err        NUMBER:=0;
	  /* Bug 0021672 - 17/05/2012 - JMF*/
	  v_tipage_agent agentes.ctipage%TYPE;
	  v_tipage_padre agentes.ctipage%TYPE;
	BEGIN
	    BEGIN
	        SELECT fmovini
	          INTO fini
	          FROM redcomercial
	         WHERE cagente=pcage AND
	               cempres=pcemp AND
	               fmovfin IS NULL;
	    EXCEPTION
	        WHEN OTHERS THEN
	          num_err:=104358; /*  error en la tabla redcomercial*/

	          RETURN(num_err);
	    END;

	    num_err:=agente_valido(padre_nuevo, pcemp, fini, NULL, pcorr1);

	    IF num_err<>0 THEN
	      RETURN(num_err);
	    END IF;

	    /* ini Bug 0021672 - 17/05/2012 - JMF*/
	    /* Validar tipo agente ¿nico en rama del agente de su redcomercial*/
	    SELECT max(ctipage)
	      INTO v_tipage_padre
	      FROM agentes
	     WHERE cagente=padre_nuevo;

	    IF v_tipage_padre IS NULL THEN
	      /* C¿digo de agente incorrecto*/
	      RETURN 101378;
	    END IF;

	    SELECT max(ctipage)
	      INTO v_tipage_agent
	      FROM agentes
	     WHERE cagente=pcage;

	    IF v_tipage_agent IS NULL THEN
	      /* Agente inexistente*/
	      RETURN 100504;
	    END IF;

	    IF v_tipage_agent=v_tipage_padre THEN
	      /* Existe otro agente del mismo tipo definido en la red comercial.*/
	      RETURN 9903706;
	    END IF;

	    /* busca ctipage del nuevo padre, en jerarqu¿a del agente hacia abajo.*/
	    num_err:=f_tip_ageredcom_down(pcemp, pcage, v_tipage_padre);

	    IF num_err=1 THEN
	      /* Existe otro agente del mismo tipo definido en la red comercial.*/
	      RETURN 9903706;
	    END IF;

	    /* Validar tipo agente ¿nico en rama del agente de su redcomercial*/
	    /* busca ctipage del agente, en jerarqu¿a del nuevo padre hacia arriba.*/
	    num_err:=f_tip_ageredcom_up(pcemp, pcage, v_tipage_agent, padre_nuevo);

	    IF num_err=1 THEN
	      /* Existe otro agente del mismo tipo definido en la red comercial.*/
	      RETURN 9903706;
	    END IF;

	    /* fin Bug 0021672 - 17/05/2012 - JMF*/
	    IF pcorr1>0 THEN
	      num_err:=107983; /*  error al validar el padre*/
	    ELSE BEGIN
	          UPDATE redcomercial
	             SET cpadre=padre_nuevo
	           WHERE cagente=pcage AND
	                 cempres=pcemp AND
	                 fmovfin IS NULL;
	      EXCEPTION
	          WHEN OTHERS THEN
	            num_err:=104558; /* error al modificar la tabla redcomercial*/

	            RETURN(num_err);
	      END;

	    /* recalculamos seguredcom desde la fecha inicio ¿ltimo registro*/
	    num_err := cambio_seguredcom(pcage, pcemp, fini); IF num_err <> 0 THEN RETURN(num_err); END IF;
	    /* recalculamos ageredcom*/
	    num_err := f_act_ageredcom(pcage, pcemp, fini); IF num_err <> 0 THEN RETURN(num_err); END IF;
	    END IF;

	    RETURN(num_err);
	END cambio_padre;

	/*-----------------------------------------------------------------------------------------------*/
	/* F.17*/
	FUNCTION valida_fechainicial(
			pcage	IN	NUMBER,
			pcemp	IN	NUMBER,
			fini	IN	DATE,
			ppadre	IN	NUMBER,
			pcorrecto	OUT	NUMBER
	) RETURN NUMBER
	IS
	  /***********************************************************************
	     Esta funci¿n se llama cuando se inserta un nuevo registro en la redcomercial
	    de un agente, y debe validarse la fecha de inicio.
	    pcorrecto:   0 cuando la fecha sea correcta
	        1 cuando no sea correcta ya que la fecha es anterior a
	                          la fecha de inicio del registro actual
	        2 cuando no sea correcta ya que el nuevo padre no puede
	           asumir el cambio
	  ***********************************************************************/
	  fini_actual DATE;
	  pcorr1      NUMBER;
	  num_err     NUMBER:=0;
	BEGIN
	    BEGIN
	        SELECT fmovini
	          INTO fini_actual
	          FROM redcomercial
	         WHERE cagente=pcage AND
	               cempres=pcemp AND
	               fmovfin IS NULL;
	    EXCEPTION
	        WHEN no_data_found THEN BEGIN
	              SELECT fmovini
	                INTO fini_actual
	                FROM redcomercial
	               WHERE cagente=pcage AND
	                     cempres=pcemp AND
	                     fmovfin IS NOT NULL;

	              pcorrecto:=1;

	              RETURN(num_err);
	          EXCEPTION
	              WHEN no_data_found THEN
	                fini_actual:=to_date('01/01/1900', 'dd/mm/yyyy');
	              WHEN OTHERS THEN
	                num_err:=104358; /*  error en la tabla redcomercial*/

	                RETURN(num_err);
	          END;
	        WHEN OTHERS THEN
	          num_err:=104358; /*  error en la tabla redcomercial*/

	          RETURN(num_err);
	    END;

	    IF fini<=fini_actual THEN
	      pcorrecto:=1;
	    ELSE
	      num_err:=agente_valido(ppadre, pcemp, fini, NULL, pcorr1);

	      IF num_err<>0 THEN
	        RETURN(num_err);
	      END IF;

	      IF pcorr1>0 THEN
	        pcorrecto:=2;
	      ELSE
	        pcorrecto:=0;
	      END IF;
	    END IF;

	    RETURN(num_err);
	END valida_fechainicial;

	/*-----------------------------------------------------------------------------------------------*/
	/* F.18*/
	FUNCTION nuevo_padre(
			pcage	IN	NUMBER,
			pcemp	IN	NUMBER,
			padre_nuevo	IN	NUMBER,
			fini_nueva	IN	DATE
	) RETURN NUMBER
	IS
	  pcorr1   NUMBER;
	  wctipage NUMBER;
	  num_err  NUMBER:=0;
	BEGIN
	    num_err:=valida_fechainicial(pcage, pcemp, fini_nueva, padre_nuevo, pcorr1);

	    IF num_err<>0 THEN
	      RETURN(num_err);
	    END IF;

	    IF pcorr1>0 THEN
	      num_err:=107986;
	    /* error al validar la fecha de inicio, o el padre del nuevo registro*/
	    ELSE BEGIN
	          SELECT ctipage
	            INTO wctipage
	            FROM redcomercial
	           WHERE cagente=pcage AND
	                 cempres=pcemp AND
	                 fmovfin IS NULL;
	      EXCEPTION
	          WHEN no_data_found THEN BEGIN
	                SELECT ctipage
	                  INTO wctipage
	                  FROM agentes
	                 WHERE cagente=pcage;
	            EXCEPTION
	                WHEN OTHERS THEN
	                  num_err:=108094;

	                  RETURN(num_err);
	            END;
	          WHEN OTHERS THEN
	            num_err:=104358; /*  error en la tabla redcomercial*/

	            RETURN(num_err);
	      END; BEGIN UPDATE redcomercial SET fmovfin = fini_nueva WHERE cagente = pcage AND cempres = pcemp AND fmovfin IS NULL; EXCEPTION WHEN OTHERS THEN num_err := 104558; /* error al modificar la tabla redcomercial*/
			           RETURN
		(num_err); END; BEGIN INSERT INTO redcomercial (cempres, cagente, fmovini, fmovfin, ctipage, cpadre)

		    VALUES
		           (pcemp, pcage, fini_nueva, NULL, wctipage, padre_nuevo); EXCEPTION WHEN OTHERS THEN num_err := 107979;

	    /* error al insertar en la tabla redcomercial*/
	    RETURN(num_err); END; num_err := cambio_seguredcom(pcage, pcemp, fini_nueva); IF num_err <> 0 THEN RETURN(num_err); END IF;
	    /* recalculamos ageredcom*/
	    num_err := f_act_ageredcom(pcage, pcemp, fini_nueva); IF num_err <> 0 THEN RETURN(num_err); END IF;
	    END IF;

	    RETURN(num_err);
	END nuevo_padre;

	/*-----------------------------------------------------------------------------------------------*/
	/* F.19*/
	FUNCTION valida_borraultimoredcom(
			pcage	IN	NUMBER,
			pcemp	IN	NUMBER,
			pcorrecto	OUT	NUMBER
	) RETURN NUMBER
	IS
	  /***********************************************************************
	     Esta funci¿n se llama cuando se borra un registro en la redcomercial
	    de un agente. Comprueba que el registro anterior siga siendo valido.
	    pcorrecto:   0 cuando sea valido
	        1 no tenga registro anterior, por lo que no puede borrarse
	        2 cuando el registro anterior no puede asumir el cambio
	  ***********************************************************************/
	  padre_ant NUMBER;
	  fini_ant  DATE;
	  pcorr1    NUMBER;
	  num_err   NUMBER:=0;
	BEGIN
	    pcorrecto:=0;

	    BEGIN
	        SELECT cpadre,fmovini
	          INTO padre_ant, fini_ant
	          FROM redcomercial
	         WHERE cagente=pcage AND
	               cempres=pcemp AND
	               fmovfin=(SELECT fmovini
	                          FROM redcomercial
	                         WHERE cagente=pcage AND
	                               cempres=pcemp AND
	                               fmovfin IS NULL);
	    EXCEPTION
	        WHEN no_data_found THEN
	          pcorrecto:=1;
	        WHEN OTHERS THEN
	          num_err:=104358; /*  error en la tabla redcomercial*/

	          RETURN(num_err);
	    END;

	    IF pcorrecto=0 THEN
	      num_err:=agente_valido(padre_ant, pcemp, fini_ant, NULL, pcorr1);

	      IF num_err<>0 THEN
	        RETURN(num_err);
	      END IF;

	      IF pcorr1>0 THEN
	        pcorrecto:=2;
	      ELSE
	        pcorrecto:=0;
	      END IF;
	    END IF;

	    RETURN(num_err);
	END valida_borraultimoredcom;

	/*-----------------------------------------------------------------------------------------------*/
	/* F.20*/
	FUNCTION borra_ultimoredcom(
			pcage	IN	NUMBER,
			pcemp	IN	NUMBER
	) RETURN NUMBER
	IS
	  pcorr1     NUMBER;
	  fini_nueva DATE;
	  num_err    NUMBER:=0;
	BEGIN
	    num_err:=valida_borraultimoredcom(pcage, pcemp, pcorr1);

	    IF num_err<>0 THEN
	      RETURN(num_err);
	    END IF;

	    IF pcorr1>0 THEN
	      num_err:=107984; /* error al validar el padre anterior*/
	    ELSE BEGIN
	          DELETE FROM redcomercial
	           WHERE cagente=pcage AND
	                 cempres=pcemp AND
	                 fmovfin IS NULL;
	      EXCEPTION
	          WHEN OTHERS THEN
	            num_err:=104558; /* error al modificar la tabla redcomercial*/

	            RETURN(num_err);
	      END; BEGIN SELECT max(fmovini) INTO fini_nueva FROM redcomercial WHERE cagente = pcage AND cempres = pcemp; EXCEPTION WHEN OTHERS THEN num_err := 104358; /*  error en la tabla redcomercial*/
	    RETURN(num_err); END; BEGIN UPDATE redcomercial SET fmovfin = NULL WHERE cagente = pcage AND cempres = pcemp AND fmovini = fini_nueva; EXCEPTION WHEN OTHERS THEN num_err := 104558; /* error al modificar la tabla redcomercial*/
	    RETURN(num_err); END; num_err := cambio_seguredcom(pcage, pcemp, fini_nueva); IF num_err <> 0 THEN RETURN(num_err); END IF;
	    /* recalculamos ageredcom*/
	    num_err := f_del_ultageredcom(pcage, pcemp, fini_nueva); IF num_err <> 0 THEN RETURN(num_err); END IF;
	    END IF;

	    RETURN(num_err);
	END borra_ultimoredcom;

	/*-----------------------------------------------------------------------------------------------*/
	/* F.21*/
	FUNCTION ff_buscanivelredcom(
			psseguro	IN	NUMBER,
			pfecha	IN	DATE,
			pnivel	IN	NUMBER
	) RETURN agentes.cagente%TYPE
	IS
	  l_agente NUMBER;
	/* Bug 18225 - APD - 11/04/2011 - la precisi¿n debe ser NUMBER*/
	BEGIN
	    BEGIN
	        SELECT decode(pnivel, 0, c00,
	                              1, c01,
	                              2, c02,
	                              3, c03,
	                              4, c04,
	                              5, c05,
	                              6, c06,
	                              7, c07,
	                              8, c08,
	                              9, c09,
	                              10, c10,
	                              11, c11,
	                              12, c12)
	          INTO l_agente
	          FROM seguredcom
	         WHERE sseguro=psseguro AND
	               fmovini<=pfecha AND
	               (fmovfin>pfecha  OR
	                fmovfin IS NULL);
	    EXCEPTION
	        WHEN OTHERS THEN
	          l_agente:=NULL;
	    END;

	    RETURN l_agente;
	END ff_buscanivelredcom;

	/* F.22*/
	FUNCTION f_valida_agente(
			pcagente	IN	agentes.cagente%TYPE
	) RETURN NUMBER
	IS
	  v_count NUMBER;
	BEGIN
	    SELECT count(1)
	      INTO v_count
	      FROM agentes
	     WHERE cagente=pcagente;

	    IF v_count>1 THEN
	      v_count:=1;
	    END IF;

	    RETURN v_count;
	END f_valida_agente;

	/* F.23*/
	FUNCTION f_valida_agente_redcom(
			pcagente	IN	agentes.cagente%TYPE,
			pempresa	IN	NUMBER
	) RETURN NUMBER
	IS
	  v_count NUMBER;
	BEGIN
	    SELECT count(1)
	      INTO v_count
	      FROM redcomercial
	     WHERE cagente=pcagente AND
	           cempres=pempresa;

	    IF v_count>1 THEN
	      v_count:=1;
	    END IF;

	    RETURN v_count;
	END f_valida_agente_redcom;

	/*Copia f_set_agente*/
	/* Bug 19169 - APD - 16/09/2011 - se a¿¿aden los nuevos campos de la tabla agentes y agentes_comp*/
	/* Bug 27949 Funci¿¿n modificada para crear f_set_agentes_comp*/
	FUNCTION f_set_agente(pcagente	IN	agentes.cagente%TYPE,
  pcretenc	IN	agentes.cretenc%TYPE,
  pctipiva	IN	agentes.ctipiva%TYPE,
  psperson	IN	agentes.sperson%TYPE,
  pccomisi	IN	agentes.ccomisi%TYPE,
  pcdesc	IN	NUMBER,
  pctipage	IN	agentes.ctipage%TYPE,
  pcactivo	IN	agentes.cactivo%TYPE,
  pcdomici	IN	agentes.cdomici%TYPE,
  pcbancar	IN	agentes.cbancar%TYPE,
  pncolegi	IN	agentes.ncolegi%TYPE,
  pfbajage	IN	agentes.fbajage%TYPE,
  pctipban	IN	agentes.ctipban%TYPE,
  pfinivigcom	IN	DATE,
  pffinvigcom	IN	DATE,
  pfinivigdesc	IN	DATE,
  pffinvigdesc	IN	DATE,
  pcsobrecomisi	IN	agentes.csobrecomisi%TYPE,
  pfinivigsobrecom	IN	DATE,
  pffinvigsobrecom	IN	DATE,
  ptalias	IN	agentes.talias%TYPE,
  pcliquido	IN	agentes.cliquido%TYPE,
  pccomisi_indirect	IN	agentes.ccomisi_indirect%TYPE,
  /* Bug 20999 - APD - 25/01/2012*/
  pfinivigcom_indirect	IN	DATE,
  /* Bug 20999 - APD - 25/01/2012*/
			 /* bug 21425/109832 - 21/03/2012 - AMC*/
			 pffinvigcom_indirect	IN	DATE,
       /* Bug 20999 - APD - 25/01/2012*/
       pctipmed	IN	agentes.ctipmed%TYPE,
       ptnomcom	IN	agentes.tnomcom%TYPE,
       pcdomcom	IN	agentes.cdomcom%TYPE,
       pctipretrib	IN	agentes.ctipretrib%TYPE,
       pcmotbaja	IN	agentes.cmotbaja%TYPE,
       pcbloqueo	IN	agentes.cbloqueo%TYPE,
       pnregdgs	IN	agentes.nregdgs%TYPE,
       pfinsdgs	IN	agentes.finsdgs%TYPE,
       pcrebcontdgs	IN	agentes.crebcontdgs%TYPE,
			 /* fin bug 21425/109832 - 21/03/2012 - AMC*/
       --
			 pcoblccc	IN	NUMBER,
	pccodcon	IN	agentes.ccodcon%TYPE,
	pclaveinter IN  agentes.claveinter%TYPE,  -- TCS_1 - 15/01/2019 - ACL
	pcdescriiva  IN  agentes.cdescriiva%TYPE,	-- TCS_1569B - ACL - 01/02/2019
    pdescricretenc IN  agentes.descricretenc%TYPE,	-- TCS_1569B - ACL - 01/02/2019
    pdescrifuente  IN  agentes.descrifuente%TYPE,	-- TCS_1569B - ACL - 01/02/2019
    pcdescriica IN  agentes.cdescriica%TYPE,		-- TCS_1569B - ACL - 01/02/2019
    pmodifica IN NUMBER,
	pcagente_out	IN	OUT agentes.cagente%TYPE
	)
	RETURN NUMBER
	IS
	  vobj           VARCHAR2(200):='pac_redcomercial.f_set_agente';
	  vpas           NUMBER:=0;
	  vpar           VARCHAR2(500):=' a='
	                      || pcagente
	                      || ' r='
	                      || pcretenc
	                      || ' i='
	                      || pctipiva
	                      || ' p='
	                      || psperson
	                      || ' c='
	                      || pccomisi
	                      || ' t='
	                      || pctipage
	                      || ' a='
	                      || pcactivo
	                      || ' d='
	                      || pcdomici
	                      || ' b='
	                      || pcbancar
	                      || ' n='
	                      || pncolegi
	                      || ' f='
	                      || pfbajage
	                      || ' b='
	                      || pctipban
                        || 'pmodifica: '
                        || pmodifica;
	  vctipage_ant   agentes.ctipage%TYPE;
	  e_params EXCEPTION;
	  salir EXCEPTION;
	  num_err        NUMBER:=0;
	  vspercomp      agentes_comp.spercomp%TYPE;
	  vcagente       agentes.cagente%TYPE;
	  vcont          NUMBER;
	  /* Bug 0021432 - 23/02/2012 - JMF*/
	  v_codagenteaut parempresas.nvalpar%TYPE;
	  vcterminal     usuarios.cterminal%TYPE;
	  psinterf       NUMBER;
	  terror         VARCHAR2(300);
	  v_host         VARCHAR2(10);
	  v_tindica      tipos_indicadores.tindica%TYPE;    -- TCS_1569B - ACL - 01/02/2019
	  /* Cambios de IAXIS-4844 : start */
	  VPERSON_NUM_ID PER_PERSONAS.NNUMIDE%TYPE;    
      VDIGITOIDE     PER_PERSONAS.TDIGITOIDE%TYPE;	  
      VCTIPIDE       PER_PERSONAS.CTIPIDE%TYPE;
	  /* Cambios de IAXIS-4844 : end */
	BEGIN
	    vpas:=1000;

	    /* Bug 19169 - APD - 19/11/2011 - no se valida que el pcagente ya*/
	    /* que en funcion del PARINSTALACION 'CODAGENTEAUT' se obtendr¿*/
	    /* autom¿ticamente el valor del codigo del agente*/
	    /*
	          IF pcagente IS NULL THEN
	             RAISE e_params;
	          END IF;
	    */
	    /* ini Bug 0021432 - 23/02/2012 - JMF*/
	    vpas:=1010;

	    v_codagenteaut:=nvl(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'CODAGENTEAUT'), 0);
      if pmodifica = 0 then --Si no estamos modifiando no dejamos crear otro agente con la misma n¿meraci¿n si ya existe uno.

                 select count('1') into vcont from agentes a where a.cagente = pcagente;

                if vcont <> 0 then
                 return 9903706;
                end if;

          end if;
	    IF v_codagenteaut=1 AND
	       pcagente IS NULL THEN /* Solo si el agente no tiene c¿digo generado.*/
	      /* (1) = C¿digo automatico*/
	      vpas:=1020;

	      num_err:=pac_redcomercial.f_get_contador_agente(pac_md_common.f_get_cxtempresa, pctipage, vcagente);

	      IF num_err<>0 THEN
	        RAISE salir;
	      END IF;
	    ELSIF v_codagenteaut=2 AND
	          nvl(pcagente, 0)=0 THEN
	      /* (2)- Codigo semi-automatico (Si existe en la tabla contadores_agente es automatico, sino es manual)*/
	      vpas:=1030;

	      num_err:=pac_redcomercial.f_get_contador_agente(pac_md_common.f_get_cxtempresa, pctipage, vcagente);

	      IF num_err<>0 THEN
	        IF pcagente IS NOT NULL THEN
	          vcagente:=pcagente;
	        ELSE
	          /* Es obligatorio introducir el c¿digo del agente.*/
	          num_err:=101076;

	          RAISE salir;
	        END IF;
	      END IF;
	    ELSE
	      /* (0) = C¿digo manual*/
	      vcagente:=pcagente;
	    END IF;

	    /* fin Bug 0021432 - 23/02/2012 - JMF*/
	    /* fin Bug 19169 - APD - 19/11/2011*/
	    /* Bug 20474 - APD - 09/12/2011*/
	    /*Si el ctipage = 0, se valida que no exista otro agente con el mismo tipo*/
	    IF pctipage=0 THEN
	      vpas:=1040;

	      SELECT count(1)
	        INTO vcont
	        FROM agentes a,redcomercial r
	       WHERE a.cagente=r.cagente AND
	             r.cempres=pac_md_common.f_get_cxtempresa AND
	             r.fmovfin IS NULL AND
	             a.ctipage=pctipage AND
	             a.cagente<>vcagente AND
	             a.cactivo=1;

	      IF vcont<>0 THEN
	        num_err:=9902879; /* S¿lo se permite un agente de este nivel.*/

	        RAISE salir;
	      END IF;
	    END IF;

	    /* Fin Bug 20474 - APD - 09/12/2011*/
	    /* Bug 26923/0146086 - APD - 07/06/2013*/
	    IF pcactivo=0 THEN
	      IF pfbajage IS NULL THEN
	        num_err:=108005; /* Inactivo - Tiene que tener fecha de baja*/

	        RAISE salir;
	      END IF;
	    END IF;

		-- Ini TCS_1569B - ACL - 04/02/2019
		IF pcdomici IS NOT NULL THEN
		BEGIN
          -- select t.ctipind, t.tindica, i.cpostal
          -- into v_ctipind4, v_tindica4, v_cpostal
          select t.tindica
            into v_tindica
            from tipos_indicadores t, per_indicadores p, tipos_indicadores_det i
            where p.CTIPIND = t.CTIPIND
            and p.CTIPIND = i.ctipind
            and t.CIMPRET = 4
            and p.sperson = psperson
            and p.codvinculo = 3
            --and p.codsubvinculo = pctipage
            and i.cpostal = (SELECT C.CPOSTAL
                    FROM CODPOSTAL C, PER_DIRECCIONES D
                    WHERE D.SPERSON = psperson
                    AND C.CPOBLAC = D.CPOBLAC
                    AND C.CPROVIN = D.CPROVIN
                    AND D.CDOMICI = pcdomici);
		-- Inicio IAXIS-2415 27/02/2019
		EXCEPTION WHEN OTHERS THEN
          v_tindica := NULL;
        -- Fin IAXIS-2415 27/02/2019    
		END;

        END IF;

	    /* fin Bug 26923/0146086 - APD - 07/06/2013*/
		-- Inicio IAXIS-2415 27/02/2019
        -- No se incluye de momento la validación para los tipos:
        -- - 0 - Compañía
        -- - 1 - Zona
        -- - 2 - Sucursal
        -- - 3 - Agencias repre/Propia
        -- Tampoco se validará cuando el código de domicilio no venga informado, sin embargo,
        -- es de suponerse que siempre vendrá informado. Por otro lado, a la creación del agente,
        -- siempre se deberá guardar primero el agente sin necesidad de una red comercial o gestor
        -- asociado, por lo que, se validará la dirección siempre y cuando exista una red comercial
        -- asociada.
        IF pctipage NOT IN (0,1,2,3) AND pcdomici IS NOT NULL
          -- Validamos que también tenga red comercial asociada.
          AND f_valida_agente_redcom(vcagente, pac_md_common.f_get_cxtempresa) = 1 THEN
           /* --
           SELECT COUNT(*)
            INTO vcont
            FROM redcomercial a, agentes b, per_direcciones c
           WHERE a.cagente = (SELECT cpadre
	                            FROM redcomercial
	                           WHERE cempres = pac_md_common.f_get_cxtempresa 
                                 AND cagente = vcagente 
                                 AND fmovfin IS NULL)
             AND a.cagente = b.cagente
             AND b.sperson = c.sperson
             AND (c.cprovin, c.cpoblac) =
                 (SELECT d.cprovin, d.cpoblac -- Debe coincidir tanto Ciudad como Departamento
                    FROM per_direcciones d, agentes e
                   WHERE e.cagente = vcagente
                     AND d.sperson = e.sperson
                     AND d.cdomici = pcdomici);
          -- */
		  
		  ---- CELSO - 05/06/19 - IAXIS-4219 - Inicio
           SELECT COUNT(*)
            INTO vcont
            FROM redcomercial a, agentes b, per_direcciones c
           WHERE a.cagente = (SELECT cpadre
	                            FROM redcomercial
	                           WHERE cempres = pac_md_common.f_get_cxtempresa 
                                 AND cagente = vcagente  AND ROWNUM <= 1)
             AND a.cagente = b.cagente
             AND b.sperson = c.sperson
             AND c.cprovin = (SELECT d.cprovin -- Debe coincidir tanto Ciudad como Departamento 
                    FROM per_direcciones d, agentes e 
                   WHERE e.cagente = vcagente 
                     AND d.sperson = e.sperson
                     AND d.cdomici = pcdomici)
             AND c.cpoblac = (SELECT d.cpoblac 
                    FROM per_direcciones d, agentes e
                   WHERE e.cagente = vcagente
                     AND d.sperson = e.sperson
                     AND d.cdomici = pcdomici); 
          -- CELSO - 05/06/19 - IAXIS-4219 - Fin
		  
		  
		  
          IF vcont = 0 THEN
            --
            num_err := 89906228; /*El domicilio debe corresponder a la Ciudad del Gestor*/
            --
	          RAISE salir;  
            --
          END IF;  
        --  
      END IF;         
      -- Fin IAXIS-2415 27/02/2019
	    BEGIN
	        /* Bug 19169 - APD - 16/09/2011 - se a¿aden los nuevos campos de la tabla agentes*/
	        vpas:=1050;

	        /* bug 21425/109832 - 21/03/2012 - AMC*/

			INSERT INTO agentes
		           (cagente,cretenc,ctipiva,sperson,ccomisi,ctipage,
		           cactivo,cdomici,cbancar,ncolegi,fbajage,
		           ctipban,csobrecomisi,talias,cliquido,ccomisi_indirect,
		           ctipmed,tnomcom,cdomcom,ctipretrib,cmotbaja,
		           cbloqueo,nregdgs,finsdgs,crebcontdgs,coblccc,
		           ccodcon,claveinter,cdescriiva,descricretenc,
                   descrifuente,cdescriica) -- TCS_1 - 15/01/2018 - ACL
		    VALUES
		           (vcagente,pcretenc,pctipiva,psperson,pccomisi,pctipage,
		           pcactivo,pcdomici,pcbancar,pncolegi,pfbajage,
		           pctipban,pcsobrecomisi,ptalias,pcliquido,pccomisi_indirect,
		           pctipmed,ptnomcom,pcdomcom,pctipretrib,pcmotbaja,
		           pcbloqueo,pnregdgs,pfinsdgs,pcrebcontdgs,pcoblccc,
		           pccodcon,pclaveinter,pcdescriiva,pdescricretenc,
                   pdescrifuente, v_tindica);  -- TCS_1 - 15/01/2019 - ACL
		-- Fin TCS_1569B - ACL - 04/02/2019

	    /* Fi bug 21425/109832 - 21/03/2012 - AMC*/
	    EXCEPTION
	        WHEN dup_val_on_index THEN

            vpas:=1060;
	          SELECT ctipage
	            INTO vctipage_ant
	            FROM agentes
	           WHERE cagente=vcagente;

	          /* Bug 19169 - APD - 16/09/2011 - se a¿aden los nuevos campos de la tabla agentes*/
	          vpas:=1070;

	          /* bug 21425/109832 - 21/03/2012 - AMC*/
			  -- TCS_1 - ACL - 16/01/2019 Se agrega campo claveinter
			  -- Ini TCS_1569B - ACL - 04/02/2019
	          UPDATE agentes
	             SET cretenc=pcretenc,ctipiva=pctipiva,sperson=psperson,ccomisi=pccomisi,ctipage=pctipage,cactivo=pcactivo,cdomici=pcdomici,cbancar=pcbancar,ncolegi=pncolegi,fbajage=pfbajage,ctipban=pctipban,csobrecomisi=pcsobrecomisi,talias=ptalias,cliquido=pcliquido,ccomisi_indirect=pccomisi_indirect,ctipmed=pctipmed,tnomcom=ptnomcom,cdomcom=pcdomcom,ctipretrib=pctipretrib,cmotbaja=pcmotbaja,cbloqueo=pcbloqueo,nregdgs=pnregdgs,finsdgs=pfinsdgs,crebcontdgs=pcrebcontdgs,coblccc=pcoblccc,ccodcon=pccodcon,
				 claveinter=pclaveinter,cdescriiva=pcdescriiva,descricretenc=pdescricretenc,descrifuente=pdescrifuente,cdescriica=pcdescriica
	           WHERE cagente=vcagente;
			  -- Fin TCS_1569B - ACL - 04/02/2019
	          /* Fi bug 21425/109832 - 21/03/2012 - AMC*/
			  
			  -- CELSO - 05/06/19 - IAXIS-4219 - Inicio
              IF pcactivo IS NOT NULL AND pcactivo!=2 AND pcactivo!=1 THEN
                UPDATE agentes SET cactivo=pcactivo, fbajage=pfbajage  WHERE sperson=psperson;
              END IF;
              
              IF pcactivo IS NOT NULL AND pcactivo=1 THEN
                 UPDATE agentes SET cactivo=pcactivo WHERE sperson=psperson AND cactivo IN(0, 3, 4, 5, 6, 7);
              END IF;
              -- CELSO - 05/06/19 - IAXIS-4219 - Fin
			  
			  
			  
	          IF vctipage_ant!=pctipage THEN
	            IF vctipage_ant<>0 THEN /*jbn 20538 Si es companyia no ho canviem*/
	              vpas:=1080;

	              num_err:=pac_redcomercial.actualiza_tipoagente(vcagente, pctipage, f_sysdate);
	            ELSE
	              num_err:=9903054;
	            END IF;
	          END IF;

	          IF num_err<>0 THEN
	            RAISE salir;
	          END IF;
	    END;
     vpas:=1081;
	    /*Bug 29166/160004 - 29/11/2013 - AMC*/
	    /* Se convierte la persona a p¿blica*/
	    num_err:=pac_persona.f_convertir_apublica(psperson);

	    /* Bug 19169 - APD - 16/09/2011*/
	    /*Llamar a la funci¿n pac_redcomercial.f_set_comisionvig_agente para grabar/actualizar la comisi¿n/sobrecomisi¿n.*/
	    IF pfinivigcom IS NOT NULL THEN
	      /* Bug 20999 - APD - 26/01/2012 - se el pasa 0 (comision NO Indirecta) al parametro pccomind*/
	      vpas:=1120;

	      num_err:=pac_redcomercial.f_set_comisionvig_agente(vcagente, pccomisi, pfinivigcom, pffinvigcom, 0);
	    /* fin Bug 20999 - APD - 26/01/2012*/
	    ELSE
	      num_err:=0;
	    END IF;

	    IF num_err<>0 THEN
	      RAISE salir;
	    END IF;

	    IF pcsobrecomisi IS NOT NULL THEN
	      IF pfinivigsobrecom IS NOT NULL AND
	         pffinvigsobrecom IS NOT NULL THEN
	        /* Bug 20999 - APD - 26/01/2012 - se el pasa 0 (comision NO Indirecta) al parametro pccomind*/
	        vpas:=1130;

	        num_err:=pac_redcomercial.f_set_comisionvig_agente(vcagente, pcsobrecomisi, pfinivigsobrecom, pffinvigsobrecom, 0);
	      /* fin Bug 20999 - APD - 26/01/2012*/
	      /* control por cfg's*/
	      /*
	               ELSIF pfinivigsobrecom IS NULL THEN
	                  num_err := 9902711;   --  Fecha inicio vigencia obligatoria
	               ELSIF pffinvigsobrecom IS NULL THEN
	                  num_err := 9902712;   -- Fecha fin vigencia obligatoria
	      */
	      END IF;
	    ELSE
	      num_err:=0;
	    END IF;

	    IF num_err<>0 THEN
	      RAISE salir;
	    END IF;

	    /* Fin Bug 19169 - APD - 16/09/2011*/
	    /* Bug 20999 - APD - 25/01/2012*/
	    /*Llamar a la funci¿n pac_redcomercial.f_set_comisionvig_agente para grabar/actualizar la comisi¿n indirecta*/
	    IF pfinivigcom_indirect IS NOT NULL THEN
	      /* Bug 20999 - APD - 26/01/2012 - se el pasa 1 (comision Indirecta) al parametro pccomind*/
	      vpas:=1140;

	      num_err:=pac_redcomercial.f_set_comisionvig_agente(vcagente, pccomisi_indirect, pfinivigcom_indirect, pffinvigcom_indirect, 1);
	    /* fin Bug 20999 - APD - 26/01/2012*/
	    ELSE
	      num_err:=0;
	    END IF;

	    IF num_err<>0 THEN
	      RAISE salir;
	    END IF;

	    /* fin Bug 20999 - APD - 25/01/2012*/
	    vpas:=1150;

	    IF pcdesc IS NOT NULL AND
	       pfinivigdesc IS NULL THEN
	      num_err:=9904229; /*Si se informa el cuadro de descuentos es obligatorio informar la fecha de inicio de vigencia de descuentos*/

	      RAISE salir;
	    END IF;

	    IF pcdesc IS NULL AND
	       pfinivigdesc IS NOT NULL THEN
	      num_err:=9904230; /* Si se informa la fecha de inicio vigencia del cuadro de descuentos es obligatorio informar el cuadro de descuentos*/

	      RAISE salir;
	    END IF;

	    IF pfinivigdesc IS NOT NULL AND
	       pcdesc IS NOT NULL THEN
	      vpas:=1151;

	      num_err:=pac_redcomercial.f_set_descuentovig_agente(vcagente, pcdesc, pfinivigdesc, pffinvigdesc);
	    END IF;

	    IF num_err<>0 THEN
	      RAISE salir;
	    END IF;

	    vpas:=1152;

	    /* Bug 21841 - APD - 18/04/2012 - se valida si pfbajage es correcta*/
	    IF pfbajage IS NOT NULL THEN
	      num_err:=pac_redcomercial.fin_agente(vcagente, pfbajage);

	      IF num_err<>0 THEN
	        RAISE salir;
	      END IF;
	    END IF;

	    /* fin Bug 21841 - APD - 18/04/2012*/
	    vpas:=1160;

	    pcagente_out:=vcagente;
		/* Cambios de IAXIS-4844 : start */
		  BEGIN
			SELECT PP.NNUMIDE,PP.TDIGITOIDE
			  INTO VPERSON_NUM_ID,VDIGITOIDE
			  FROM PER_PERSONAS PP
			 WHERE PP.SPERSON = psperson
			   AND ROWNUM = 1;
		  EXCEPTION
			WHEN NO_DATA_FOUND THEN
			  SELECT PP.CTIPIDE, PP.NNUMIDE
				INTO VCTIPIDE, VPERSON_NUM_ID
				FROM PER_PERSONAS PP
			   WHERE PP.SPERSON = psperson;
			  VDIGITOIDE := PAC_IDE_PERSONA.F_DIGITO_NIF_COL(VCTIPIDE,
															 UPPER(VPERSON_NUM_ID));
		  END;
		/* Cambios de IAXIS-4844 : end */
	    /* ini BUG 0026318 -- ETM -- 28/05/2013*/
	    v_host:=pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'ALTA_INTERM_HOST');

	    IF v_host IS NOT NULL THEN
	      IF pac_persona.f_gubernamental(psperson)=1 THEN
	        v_host:=pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'DUPL_ACREEDOR_HOST');
	      END IF;

	      num_err:=pac_user.f_get_terminal(f_user, vcterminal);
		/* Cambios de IAXIS-4844 : start */
	      num_err:=pac_con.f_alta_persona(pac_md_common.f_get_cxtempresa, psperson, vcterminal, psinterf, terror, pac_md_common.f_get_cxtusuario, 1, 'ALTA', VDIGITOIDE, v_host);
		/* Cambios de IAXIS-4844 : end */

	      IF num_err<>0 THEN
	        RAISE salir;
	      END IF;
	    END IF;

	    /* 11.0 - 21/08/2013 - MMM - 0027951: LCOL: Mejora de Red Comercial - Inicio*/
	    /* Si est¿ inactivo y lo pasamos a activo, tenemos que poner a NULL la FMOVFIN en la tabla REDCOMERCIAL*/
	    IF pcactivo=1 THEN
	      SELECT count(1)
	        INTO vcont
	        FROM redcomercial
	       WHERE cagente=vcagente AND
	             cempres=pac_md_common.f_get_cxtempresa AND
	             fmovfin IS NULL;

	      IF vcont=0 THEN
	        UPDATE redcomercial r1
	           SET r1.fmovfin=NULL
	         WHERE r1.cagente=vcagente AND
	               cempres=pac_md_common.f_get_cxtempresa AND
	               (r1.fmovini) IN(SELECT max(r2.fmovini)
	                                 FROM redcomercial r2
	                                WHERE r2.cagente=r1.cagente AND
	                                      r2.cempres=r1.cempres
	                                GROUP BY r2.cagente) AND
	               ROWNUM=1;
			   
		UPDATE agentes SET fbajage=NULL WHERE cagente=pcagente; -- CELSO - 05/06/19 - IAXIS-4219 		   
				   
	      END IF;
	    END IF;

	    /* 11.0 - 21/08/2013 - MMM - 0027951: LCOL: Mejora de Red Comercial - Fin*/
	    /*fin BUG 0026318 -- ETM -- 28/05/2013*/
	    RETURN num_err;
	EXCEPTION
	  WHEN e_params THEN
	             p_tab_error(f_sysdate, f_user, vobj, vpas, f_axis_literales(103135), vpar);

	             RETURN 103135; WHEN salir THEN
	             p_tab_error(f_sysdate, f_user, vobj, vpas, f_axis_literales(num_err), vpar);

	             RETURN num_err; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE
	                                                              || ' '
	                                                              || SQLERRM);

	             RETURN 1;
	END f_set_agente;

	/* Bug 27949 Funci¿¿n modificada para crear f_set_agentes_comp*/
	FUNCTION f_set_agente_comp(
			pcagente	IN	agentes_comp.cagente%TYPE,
	pctipadn	IN	agentes_comp.ctipadn%TYPE,
	pcagedep	IN	agentes_comp.cagedep%TYPE,
	pctipint	IN	agentes_comp.ctipint%TYPE,
	pcageclave	IN	agentes_comp.cageclave%TYPE,
	pcofermercan	IN	agentes_comp.cofermercan%TYPE,
	pfrecepcontra	IN	agentes_comp.frecepcontra%TYPE,
	pcidoneidad	IN	agentes_comp.cidoneidad%TYPE,
	pccompani	IN	agentes_comp.ccompani%TYPE,
	pcofipropia	IN	agentes_comp.cofipropia%TYPE,
	pcclasif	IN	agentes_comp.cclasif%TYPE,
	pnplanpago	IN	agentes_comp.nplanpago%TYPE,
	pnnotaria	IN	agentes_comp.nnotaria%TYPE,
	pcprovin	IN	agentes_comp.cprovin%TYPE,
	pcpoblac	IN	agentes_comp.cpoblac%TYPE,
	pnescritura	IN	agentes_comp.nescritura%TYPE,
	pfaltasoc	IN	agentes_comp.faltasoc%TYPE,
	ptgerente	IN	agentes_comp.tgerente%TYPE,
	ptcamaracomercio	IN	agentes_comp.tcamaracomercio%TYPE,
	pagrupador	IN	agentes_comp.agrupador%TYPE,
	pcactividad	IN	agentes_comp.cactividad%TYPE,
	pctipoactiv	IN	agentes_comp.ctipoactiv%TYPE,
	ppretencion	IN	agentes_comp.pretencion%TYPE,
			pcincidencia	IN	agentes_comp.cincidencia%TYPE,
	pcrating	IN	agentes_comp.crating%TYPE,
	ptvaloracion	IN	agentes_comp.tvaloracion%TYPE,
	pcresolucion	IN	agentes_comp.cresolucion%TYPE,
	pffincredito	IN	agentes_comp.ffincredito%TYPE,
	pnlimcredito	IN	agentes_comp.nlimcredito%TYPE,
	ptcomentarios	IN	agentes_comp.tcomentarios%TYPE,
			 /*nuevos campos*/
			 pfultrev	IN	agentes_comp.fultrev%TYPE,pfultckc	IN	agentes_comp.fultckc%TYPE,pctipbang	IN	agentes_comp.ctipbang%TYPE,pcbanges	IN	agentes_comp.cbanges%TYPE,pcclaneg	IN	agentes_comp.cclaneg%TYPE,pctipage_liquida	IN	agentes_comp.ctipage_liquida%TYPE,piobjetivo	IN	agentes_comp.iobjetivo%TYPE,pibonifica	IN	agentes_comp.ibonifica%TYPE,ppcomextr	IN	agentes_comp.pcomextr%TYPE,pctipcal	IN	agentes_comp.ctipcal%TYPE,pcforcal	IN	agentes_comp.cforcal%TYPE,pcmespag	IN	agentes_comp.cmespag%TYPE,ppcomextrov	IN	agentes_comp.pcomextrov%TYPE,pppersisten	IN	agentes_comp.ppersisten%TYPE,ppcompers	IN	agentes_comp.pcompers%TYPE,pctipcalb	IN	agentes_comp.ctipcalb%TYPE,pcforcalb	IN	agentes_comp.cforcalb%TYPE,pcmespagb	IN	agentes_comp.cmespagb%TYPE,ppcombusi	IN	agentes_comp.pcombusi%TYPE,pilimiteb	IN	agentes_comp.ilimiteb%TYPE,pccexpide	IN	agentes_comp.cexpide%TYPE, /* BUG 31489 - FAL - 21/05/2014*/
	--AAC_INI-CONF_379-20160927
	pcorteprod	IN	agentes_comp. corteprod %TYPE
	--AAC_FI-CONF_379-20160927
	)
	RETURN NUMBER
	IS
	  vobj      VARCHAR2(200):='pac_redcomercial.f_set_agente_comp';
	  vpas      NUMBER:=0;
	  e_params EXCEPTION;
	  salir EXCEPTION;
	  num_err   NUMBER:=0;
	  vspercomp agentes_comp.spercomp%TYPE;
	  vpar      VARCHAR2(500):=' a='
	                      || pcagente;
	  v_errores VARCHAR2(500);
	BEGIN
	    vpas:=1000;

	    BEGIN
	    /* Bug 19169 - APD - 16/09/2011 - si el ccompani es no nulo, se busca el sperson*/
	        /* que tiene asociado*/
	        IF pccompani IS NOT NULL THEN BEGIN
	              vpas:=1010;

	              SELECT sperson
	                INTO vspercomp
	                FROM companias
	               WHERE ccompani=pccompani;
	          EXCEPTION
	              WHEN OTHERS THEN
	                vspercomp:=NULL;
	          END;
	        END IF;

	        /* Bug 19169 - APD - 16/09/2011 - se a¿¿aden el insert en la tabla agentes_comp*/
	        vpas:=1020;

	        /* bug 21425/109832 - 21/03/2012 - AMC*/
			INSERT INTO agentes_comp
		           (cagente,ctipadn,cagedep,ctipint,cageclave,cofermercan,
		           frecepcontra,cidoneidad,spercomp,ccompani,cofipropia,
		           cclasif,nplanpago,nnotaria,cprovin,cpoblac,
		           nescritura,faltasoc,tgerente,tcamaracomercio,agrupador,
		           cactividad,ctipoactiv,pretencion,cincidencia,crating,
		           tvaloracion,cresolucion,ffincredito,nlimcredito,tcomentarios,
		           fultrev,fultckc,ctipbang,cbanges,cclaneg,
		           ctipage_liquida,iobjetivo,ibonifica,pcomextr,ctipcal,
		           cforcal,cmespag,pcomextrov,ppersisten,pcompers,
		           ctipcalb,cforcalb,cmespagb,pcombusi,ilimiteb,
		           cexpide
               --AAC_INI-CONF_379-20160927
               ,corteprod
               --AAC_FI-CONF_379-20160927
               ) /* BUG 31489 - FAL - 21/05/2014*/
		    VALUES
		           (pcagente,pctipadn,pcagedep,pctipint,pcageclave,pcofermercan,
		           pfrecepcontra,pcidoneidad,vspercomp,pccompani,pcofipropia,
		           pcclasif,pnplanpago,pnnotaria,pcprovin,pcpoblac,
		           pnescritura,pfaltasoc,ptgerente,ptcamaracomercio,pagrupador,
		           pcactividad,pctipoactiv,ppretencion,pcincidencia,pcrating,
		           ptvaloracion,pcresolucion,pffincredito,pnlimcredito,ptcomentarios,
		           pfultrev,pfultckc,pctipbang,pcbanges,pcclaneg,
		           pctipage_liquida,piobjetivo,pibonifica,ppcomextr,pctipcal,
		           pcforcal,pcmespag,ppcomextrov,pppersisten,ppcompers,
		           pctipcalb,pcforcalb,pcmespagb,ppcombusi,pilimiteb,
		           pccexpide
               --AAC_INI-CONF_379-20160927
               ,pcorteprod

               --AAC_FI-CONF_379-20160927
               ); /* BUG 31489 - FAL - 21/05/2014*/

	    /* Fi bug 21425/109832 - 21/03/2012 - AMC*/
	    EXCEPTION
	        WHEN dup_val_on_index THEN
	          /* Bug 19169 - APD - 16/09/2011 - se a¿¿aden el update en la tabla agentes_comp*/
	          vpas:=1030;

	          /* bug 21425/109832 - 21/03/2012 - AMC*/
	          UPDATE agentes_comp
	             SET ctipadn=pctipadn,cagedep=pcagedep,ctipint=pctipint,cageclave=pcageclave,cofermercan=pcofermercan,frecepcontra=pfrecepcontra,cidoneidad=pcidoneidad,spercomp=vspercomp,ccompani=pccompani,cofipropia=pcofipropia,cclasif=pcclasif,nplanpago=pnplanpago,nnotaria=pnnotaria,cprovin=pcprovin,cpoblac=pcpoblac,nescritura=pnescritura,faltasoc=pfaltasoc,tgerente=ptgerente,tcamaracomercio=ptcamaracomercio,agrupador=pagrupador,cactividad=pcactividad,ctipoactiv=pctipoactiv,pretencion=ppretencion,cincidencia=pcincidencia,crating=pcrating,tvaloracion=ptvaloracion,cresolucion=pcresolucion,ffincredito=pffincredito,nlimcredito=pnlimcredito,tcomentarios=ptcomentarios,fultrev=pfultrev,fultckc=pfultckc,ctipbang=pctipbang,cbanges=pcbanges,cclaneg=pcclaneg,ctipage_liquida=pctipage_liquida,iobjetivo=piobjetivo,ibonifica=pibonifica,pcomextr=ppcomextr,ctipcal=pctipcal,cforcal=pcforcal,cmespag=pcmespag,ppersisten=pppersisten,pcompers=ppcompers,pcomextrov=ppcomextrov,ctipcalb=pctipcalb,cforcalb=
	                 pcforcalb
	                 ,
	                 cmespagb=
	                 pcmespagb,pcombusi=ppcombusi,ilimiteb=pilimiteb,/* BUG 31489 - FAL - 21/05/2014*/cexpide=pccexpide
                   --AAC_INI-CONF_379-20160927
                   ,corteprod = pcorteprod

                   --AAC_FI-CONF_379-20160927
	           WHERE cagente=pcagente;
	        WHEN OTHERS THEN
	          p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE
	                                                           || ' '
	                                                           || SQLERRM);

	          v_errores:=SQLCODE
	                     || ' '
	                     || SQLERRM;

	          RETURN 9906398;
	    /* Fi bug 21425/109832 - 21/03/2012 - AMC*/
	    END;

	    /*fin BUG 0026318 -- ETM -- 28/05/2013*/
	    RETURN num_err;
	EXCEPTION
	  WHEN e_params THEN
	             p_tab_error(f_sysdate, f_user, vobj, vpas, f_axis_literales(103135), vpar);

	             RETURN 103135; WHEN salir THEN
	             p_tab_error(f_sysdate, f_user, vobj, vpas, f_axis_literales(num_err), vpar);

	             RETURN num_err; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE
	                                                              || ' '
	                                                              || SQLERRM);

	             RETURN 9906398;
	END f_set_agente_comp;

	/* F.25*/
	FUNCTION f_set_contrato(
			pcempres	IN	NUMBER,
			pcagente	IN	NUMBER,
			pncontrato	IN	NUMBER,
			pffircon	IN	DATE
	) RETURN NUMBER
	IS
	  e_params EXCEPTION;
	BEGIN
	    IF pcempres IS NULL  OR
	       pcagente IS NULL THEN
	      RAISE e_params;
	    END IF;

	    BEGIN
			INSERT INTO contratosage
		           (cempres,cagente,ncontrato,ffircon)
		    VALUES
		           (pcempres,pcagente,pncontrato,pffircon);

	    EXCEPTION
	        WHEN dup_val_on_index THEN
	          UPDATE contratosage
	             SET ncontrato=pncontrato,ffircon=pffircon
	           WHERE cempres=pcempres AND
	                 cagente=pcagente;
	    END;

	    RETURN 0;
	EXCEPTION
	  WHEN e_params THEN
	             RETURN 103135;
	END f_set_contrato;

	/* Bug 18946 - APD - 16/11/2011 - se a¿aden los campos de vision por poliza*/
	/* cpolvisio, cpolnivel*/
	/*************************************************************************
	   Inserta la redcomercial
	   param in pcempres  : c¿digo de la empresa
	   param in pcagente  : c¿digo del agente
	   param in pfecha    : fecha
	   param in pcpadre   : codigo del padre
	   param in pccomindt :
	   param in pcprevisio : C¿digo del agente que nos indica el nivel de visi¿n de personas
	   param in pcprenivel : Nivel visi¿n personas
	   return             : 0 todo correcto
	                        1 ha habido un error
	*************************************************************************/
	FUNCTION f_set_redcomercial(pcempres IN	NUMBER,
	                            pcagente IN	NUMBER,
								pfecha IN	DATE,
								pcpadre	IN	NUMBER,
								pccomindt IN	NUMBER,
								pcprevisio	IN	NUMBER,
								pcprenivel	IN	NUMBER,
								pcageind	IN	NUMBER,
								pcpolvisio	IN	NUMBER,
								pcpolnivel	IN	NUMBER,
								pcenlace	IN	NUMBER, -- IAXIS-2415 27/02/2019
								pcdomiciage IN NUMBER /*Bug 21672 - JTS - 29/05/2012*/ -- IAXIS-2415 27/02/2019

	)
	RETURN NUMBER
	IS
	  e_params EXCEPTION;
	  v_comprobaciones          BOOLEAN:=TRUE;
	  v_resultado               BOOLEAN;
	  v_max_fec_ini             DATE;
	  v_fecha_fin               DATE;
	  vctipage                  NUMBER;
	  num_err                   NUMBER; /* Bug 21223 - APD - 13/02/2012*/
	  v_param_sincroagen_cobpag NUMBER; /* Bug 21597 - MDS - 08/03/2012*/
	  v_param_gestiona_cobpag   NUMBER; /* Bug 21597 - MDS - 08/03/2012*/
	  /* Bug 0021672 - 17/05/2012 - JMF*/
	  v_tipage_agent            agentes.ctipage%TYPE;
	  v_tipage_padre            agentes.ctipage%TYPE;
	  pcorr1                    NUMBER; /* Bug 21841 - APD - 17/04/2012*/
	  /* Bug 0024871 - 28/11/2012 - JMF*/
	  v_actageredcom            NUMBER(1):=0;
	   VSPERSON       NUMBER;
	   vcont          NUMBER; -- IAXIS-2415 27/02/2019
	BEGIN
	    IF pcempres IS NULL  OR
	       pcagente IS NULL  OR
	       pfecha IS NULL THEN
	      RAISE e_params;
	    END IF;

	    /* Bug 20474 - APD - 12/12/2011 - se valida que no se pueda poner el mismo*/
	    /* agente como padre en la redcomercial*/
	    IF pcpadre IS NOT NULL THEN
	      IF pcpadre=pcagente THEN
	        RETURN 110514; /*El agente no puede ser su propio gestor*/
	      END IF;
	    END IF;

		          IF NVL(PAC_PARAMETROS.F_PAREMPRESA_N(F_EMPRES, 'CREACION_AG_DUP'), 0) = 1 THEN
      	  SELECT COUNT(1)
          INTO VSPERSON
          FROM AGENTES A, REDCOMERCIAL R
          WHERE SPERSON IN (SELECT SPERSON FROM AGENTES WHERE CAGENTE=PCAGENTE)
          AND A.CAGENTE = R.CAGENTE
          AND R.CPADRE= PCPADRE
          AND A.CAGENTE <> PCAGENTE;
                 IF VSPERSON  <> 0 THEN
                     RETURN 9910955;

          END IF;
                  END IF;

	    /* Fin Bug 20474 - APD - 12/12/2011*/
	    /* Bug 21841 - APD - 17/04/2012 - se debe validar que no se pueda dar de alta*/
	    /* un agente con fmovini anterior a la fmovini de su padre*/
	    num_err:=pac_redcomercial.valida_fechainicial(pcagente, pcempres, pfecha, pcpadre, pcorr1);

	    IF num_err<>0 THEN
	      RETURN(num_err);
	    END IF;

	    /* Inicio Bug 41274/230805 - 23/03/2016 - AMC*/
	    IF pcorr1=1 THEN
	      RETURN 9903594; /* La fecha inicial del agente en la red comercial no puede ser menor que la fecha inicial de su gestor en la redcomercial.*/
	    ELSIF pcorr1=2 THEN
	      RETURN 9908941; -- La fecha inicial del agente en la red comercial es incompatible con las fechas de su gestor en la red comercial.'
	    END IF;

	    /* Fin Bug 41274/230805 - 23/03/2016 - AMC*/
	    /* fin Bug 21841 - APD - 17/04/2012*/
	    /* ini Bug 0021672 - 17/05/2012 - JMF*/
	    /* Validar tipo agente ¿nico en rama del agente de su redcomercial*/
	    SELECT max(ctipage)
	      INTO v_tipage_padre
	      FROM agentes
	     WHERE cagente=pcpadre;

	    IF v_tipage_padre IS NULL THEN
	      /* C¿digo de agente incorrecto*/
	      RETURN 101378;
	    END IF;

	    SELECT max(ctipage)
	      INTO v_tipage_agent
	      FROM agentes
	     WHERE cagente=pcagente;

	    IF v_tipage_agent IS NULL THEN
	      /* Agente inexistente*/
	      RETURN 100504;
	    END IF;

	    IF v_tipage_agent=v_tipage_padre THEN
	      /* Existe otro agente del mismo tipo definido en la red comercial.*/
	      RETURN 9903706;
	    END IF;

	    /* busca ctipage del nuevo padre, en jerarqu¿a del agente hacia abajo.*/
	    num_err:=f_tip_ageredcom_down(pcempres, pcagente, v_tipage_padre);

	    IF num_err=1 THEN
	      /* Existe otro agente del mismo tipo definido en la red comercial.*/
	      RETURN 9903706;
	    END IF;

	    /* Validar tipo agente ¿nico en rama del agente de su redcomercial*/
	    /* busca ctipage del agente, en jerarqu¿a del nuevo padre hacia arriba.*/
	    num_err:=f_tip_ageredcom_up(pcempres, pcagente, v_tipage_agent, pcpadre);

	    IF num_err=1 THEN
	      /* Existe otro agente del mismo tipo definido en la red comercial.*/
	      RETURN 9903706;
	    END IF;

	    /* fin Bug 0021672 - 17/05/2012 - JMF*/
	    /*BUG21672 - JTS - 14/03/2012*/
	    /*Comprobamos si el nuevo padre y enlace tiene ramas compatibles*/
	    IF pcpadre IS NOT NULL AND
	       pcenlace IS NOT NULL THEN
	      IF pcpadre!=pcenlace THEN
	        SELECT SUM(c00+c01+c02+c03+c04+c05+c06+c07+c08+c09+c10+c11+c12) suma
	          INTO num_err
	          FROM (SELECT decode(c00, 0, 0,
	                                   1, 0,
	                                   1) c00,decode(c01, 0, 0,
	                                                      1, 0,
	                                                      1) c01,decode(c02, 0, 0,
	                                                                         1, 0,
	                                                                         1) c02,decode(c03, 0, 0,
	                                                                                            1, 0,
	                                                                                            1) c03,decode(c04, 0, 0,
	                                                                                                               1, 0,
	                                                                                                               1) c04,decode(c05, 0, 0,
	                                                                                                                                  1, 0,
	                                                                                                                                  1) c05,decode(c06, 0, 0,
	                                                                                                                                                     1, 0,
	                                                                                                                                                     1) c06,decode(c07, 0, 0,
	                                                                                                                                                                        1, 0,
	                                                                                                                                                                        1) c07,decode(c08, 0, 0,
	                                                                                                                                                                                           1, 0,
	                                                                                                                                                                                           1) c08,decode(c09, 0, 0,
	                                                                                                                                                                                                              1, 0,
	                                                                                                                                                                                                              1) c09,decode(c10, 0, 0,
	                                                                                                                                                                                                                                 1, 0,
	                                                                                                                                                                                                                                 1) c10,decode(c11, 0, 0,
	                                                                                                                                                                                                                                                    1, 0,
	                                                                                                                                                                                                                                                    1) c11,decode(c12, 0, 0,
	                                                                                                                                                                                                                                                                       1, 0,
	                                                                                                                                                                                                                                                                       1) c12
	                  FROM (SELECT SUM(c00) c00,SUM(c01) c01,SUM(c02) c02,SUM(c03) c03,SUM(c04) c04,SUM(c05) c05,SUM(c06) c06,SUM(c07) c07,SUM(c08) c08,SUM(c09) c09,SUM(c10) c10,SUM(c11) c11,SUM(c12) c12
	                          FROM (SELECT 0 c00,decode(c01, 0, 0,
	                                                         1) c01,decode(c02, 0, 0,
	                                                                            1) c02,decode(c03, 0, 0,
	                                                                                               1) c03,decode(c04, 0, 0,
	                                                                                                                  1) c04,decode(c05, 0, 0,
	                                                                                                                                     1) c05,decode(c06, 0, 0,
	                                                                                                                                                        1) c06,decode(c07, 0, 0,
	                                                                                                                                                                           1) c07,decode(c08, 0, 0,
	                                                                                                                                                                                              1) c08,decode(c09, 0, 0,
	                                                                                                                                                                                                                 1) c09,decode(c10, 0, 0,
	                                                                                                                                                                                                                                    1) c10,decode(c11, 0, 0,
	                                                                                                                                                                                                                                                       1) c11,decode(c12, 0, 0,
	                                                                                                                                                                                                                                                                          1) c12
	                                  FROM ageredcom
	                                 WHERE cagente=pcpadre AND
	                                       cempres=pcempres AND
	                                       fmovfin IS NULL
	                                UNION
	                                SELECT 0 c00,decode(c01, 0, 0,
	                                                         1) c01,decode(c02, 0, 0,
	                                                                            1) c02,decode(c03, 0, 0,
	                                                                                               1) c03,decode(c04, 0, 0,
	                                                                                                                  1) c04,decode(c05, 0, 0,
	                                                                                                                                     1) c05,decode(c06, 0, 0,
	                                                                                                                                                        1) c06,decode(c07, 0, 0,
	                                                                                                                                                                           1) c07,decode(c08, 0, 0,
	                                                                                                                                                                                              1) c08,decode(c09, 0, 0,
	                                                                                                                                                                                                                 1) c09,decode(c10, 0, 0,
	                                                                                                                                                                                                                                    1) c10,decode(c11, 0, 0,
	                                                                                                                                                                                                                                                       1) c11,decode(c12, 0, 0,
	                                                                                                                                                                                                                                                                          1) c12
	                                  FROM ageredcom
	                                 WHERE cagente=pcenlace AND
	                                       cempres=pcempres AND
	                                       fmovfin IS NULL)));
	      ELSE /*El padre y el enlace no pueden ser iguales*/
	        num_err:=1;
	      END IF;

	      IF num_err>0 THEN
	        /* Existe otro agente del mismo tipo definido en la red comercial.*/
	        RETURN 9903706;
	      END IF;
	    END IF;

	    /*Fi BUG21672*/
	    /* Se obtiene la fecha fecha inicial mayor para todas las vigencias existentes para este agente en esta empresa.*/
	    SELECT max(fmovini)
	      INTO v_max_fec_ini
	      FROM redcomercial
	     WHERE cempres=pcempres AND
	           cagente=pcagente;

	    IF v_max_fec_ini IS NULL THEN
	      /* no hay registros con lo cual no debemos comprobar rangos ni nada.*/
	      v_comprobaciones:=FALSE;
	    ELSE
	      v_comprobaciones:=TRUE;
	    END IF;

	    /* ini Bug 0024871 - 28/11/2012 - JMF*/
	    /* Si han cambiado padre o enlace, debemos actualizar ageredcom del resto de agentes afectados,*/
	    /* en caso contrario solo el ageredcom del agente actual.*/
	    SELECT nvl(max(0), 1)
	      INTO v_actageredcom
	      FROM redcomercial
	     WHERE cempres=pcempres AND
	           cagente=pcagente AND
	           fmovini=v_max_fec_ini AND
	           nvl(cpadre, -1)=nvl(pcpadre, -1) AND
	           nvl(cenlace, -1)=nvl(pcenlace, -1);

	    /* fin Bug 0024871 - 28/11/2012 - JMF*/
	    IF v_comprobaciones THEN
	    /* tiene registros. Comprobaremos :*/
	    /* 1. Si la fecha de fin es nula tenemos un periodo abierto. Debemos tener una fecha de inicio mayor*/
	    /*    que la fecha de inicio del periodo abierto*/
	    /* 2. Si el ¿ltimo periodo est¿ cerrado, debemos tener una fecha de inicio mayor que la de fin del*/
	      /*    perdiodo cerrado.*/
	      SELECT fmovfin
	        INTO v_fecha_fin
	        FROM redcomercial
	       WHERE cempres=pcempres AND
	             cagente=pcagente AND
	             fmovini=v_max_fec_ini;

	      IF v_fecha_fin IS NULL THEN /* periodo abierto*/
	        IF v_max_fec_ini<pfecha THEN /* fecha propuesta posterior a fecha inicio periodo abierto*/
	          v_resultado:=TRUE;

	          /* se cierra el periodo abierto*/
	          UPDATE redcomercial
	             SET fmovfin=pfecha
	           WHERE cempres=pcempres AND
	                 cagente=pcagente AND
	                 fmovini=v_max_fec_ini;
	        ELSE
	          /* fecha propuesta anterior o igual a fecha inicio periodo abierto*/
	          v_resultado:=FALSE;
	        /* error : la fecha que se propone es anterior a la de inicio del periodo vigente*/
	        END IF;
	      ELSE /* periodo cerrado*/
	        IF v_fecha_fin<pfecha THEN /* fecha propuesta posterior a fecha cierre periodo*/
	          v_resultado:=TRUE;
	        ELSE
	          /* fecha propuesta anterior o igual a fecha de cierre de periodo*/
	          v_resultado:=FALSE;
	        /* error : la fecha que se propone esta dentro de un periodo ya cerrado*/
	        END IF;
	      END IF;
	    ELSE
	      v_resultado:=TRUE;
	    END IF;

	    IF v_resultado THEN
	    /* Bug 11444 - 20/10/2009 - AMC - En la redcomercial se inserta el ctipage del agente*/
	    BEGIN
	          SELECT ctipage
	            INTO vctipage
	            FROM agentes
	           WHERE cagente=pcagente;
	      EXCEPTION
	          WHEN OTHERS THEN
	            RETURN 104472; /*Agente no encontrado en la tabla AGENTES*/
	      END;

	    /* ini Bug 0021672 - 17/05/2012 - JMF*/
	    /* Validar tipo agente ¿nico en rama del agente de su redcomercial*/
	    num_err := f_tip_ageredcom_up(pcempres, pcagente, vctipage, NULL); IF num_err = 1 THEN
	    /* Existe otro agente del mismo tipo definido en la red comercial.*/
	    RETURN 9903706; END IF;
	    /* fin Bug 0021672 - 17/05/2012 - JMF*/
	    /* Bug 18946 - APD - 16/11/2011 - se a¿aden los campos de vision por poliza*/
	    /* cpolvisio, cpolnivel*/
			INSERT INTO redcomercial
		           (cempres, cagente, fmovini, fmovfin, ctipage, cpadre,
		           ccomindt, cpervisio, cpernivel, cageind, cpolvisio,
		           cpolnivel, cenlace)
		    VALUES
		           (pcempres, pcagente, pfecha, NULL, vctipage, pcpadre,
		           pccomindt, pcprevisio, pcprenivel, pcageind, pcpolvisio,
		           pcpolnivel, pcenlace);

	    /* fin Bug 18946 - APD - 16/11/2011*/
	    /* Fi Bug 11444 - 20/10/2009 - AMC - En la redcomercial se inserta el ctipage del agente*/
	    /* Bug 21223 - APD - 13/02/2012 - se actualiza la tabla seguredcom*/
	    num_err := cambio_seguredcom(pcagente, pcempres, pfecha); IF num_err <> 0 THEN RETURN(num_err); END IF;
	    /* fin Bug 21223 - APD - 13/02/2012*/
	    /* ini Bug 0024871 - 28/11/2012 - JMF*/
	    /* Si han cambiado padre o enlace, debemos actualizar ageredcom del resto de agentes afectados,*/
	    /* en caso contrario solo el ageredcom del agente actual.*/
	    IF v_actageredcom = 1 THEN
	    /* recalculamos ageredcom*/
			           num_err := f_act_ageredcom
		           (pcagente, pcempres, pfecha); IF num_err <> 0 THEN RETURN(num_err); END IF; ELSE DECLARE r1 ageredcom%ROWTYPE; BEGIN
		    SELECT
		           * INTO r1
		      FROM
		           ageredcom a
		     WHERE
		           fmovini = (
		    SELECT
		           max(b.fmovini)
		      FROM
		           ageredcom b
		     WHERE
		           b.cempres = pcempres
		       AND
		           b.cagente = pcagente)
		       AND
		           cempres = pcempres
		       AND
		           cagente = pcagente; UPDATE ageredcom SET fmovfin = pfecha
		     WHERE
		           cempres = pcempres
		       AND
		           cagente = pcagente
		       AND
		fmovini = r1.fmovini; INSERT INTO ageredcom (cagente, cempres, ctipage, fmovini, fmovfin, fbaja,
		           c00, c01, c02, c03, c04,
		           c05, c06, c07, c08, c09,
		           c10, c11, c12, cpervisio, cpernivel,
		           cpolvisio, cpolnivel)
		    VALUES
		           (r1.cagente, r1.cempres, r1.ctipage, pfecha, NULL, r1.fbaja,
		           r1.c00, r1.c01, r1.c02, r1.c03, r1.c04,
		           r1.c05, r1.c06, r1.c07, r1.c08, r1.c09,
		           r1.c10, r1.c11, r1.c12, pcprevisio, pcprenivel,
		           pcpolvisio, pcpolnivel); EXCEPTION WHEN dup_val_on_index THEN NULL; END; END IF;

	    /* fin Bug 0024871 - 28/11/2012 - JMF*/
	    /* Bug 21421 - APD - 28/02/2012 - se actualiza la tabla recibosredcom*/
	    num_err := cambio_recibosredcom(pcagente, pcempres, pfecha); IF num_err <> 0 THEN RETURN(num_err); END IF;
	    /* ini Bug 21597 - MDS - 08/03/2012*/
	    v_param_sincroagen_cobpag := nvl(pac_parametros.f_parempresa_n(pcempres, 'SINCROAGEN_COBPAG'), 0); v_param_gestiona_cobpag := nvl(pac_parametros.f_parempresa_n(pcempres, 'GESTIONA_COBPAG'), 0); IF (v_param_sincroagen_cobpag = 1) AND(v_param_gestiona_cobpag = 1) THEN num_err := f_sincroniza_recibos(pcagente, NULL, NULL); IF num_err <> 0 THEN RETURN(num_err); END IF; END IF;
	    /* fin Bug 21597 - MDS - 08/03/2012*/
	    /* fin Bug 21223 - APD - 13/02/2012*/
		-- Inicio IAXIS-2415 27/02/2019
        IF vctipage NOT IN (0,1,2,3) AND pcdomiciage IS NOT NULL THEN
          --
          SELECT COUNT(*)
            INTO vcont
            FROM redcomercial a, agentes b, per_direcciones c
           WHERE a.cagente = pcpadre
             AND a.cagente = b.cagente
             AND b.sperson = c.sperson
             AND (c.cprovin, c.cpoblac) =
                 (SELECT d.cprovin, d.cpoblac -- Debe coincidir tanto Ciudad como Departamento
                    FROM per_direcciones d, agentes e
                   WHERE e.cagente = pcagente
                     AND d.sperson = e.sperson
                     AND d.cdomici = pcdomiciage);
          --
          IF vcont = 0 THEN
            --
            return 89906228; /*El domicilio debe corresponder a la Ciudad del Gestor*/
            --
          ELSE 
            --
            UPDATE agentes a SET a.cdomici = pcdomiciage WHERE a.cagente = pcagente;
            --
          END IF;  
          --
        END IF;
        -- Fin IAXIS-2415 27/02/2019
	    RETURN 0;
	    ELSE
	      RETURN 107987;
	    END IF;
	EXCEPTION
	  WHEN e_params THEN
	             RETURN 103135;
	END f_set_redcomercial;

	/* dra 22-12-2008: bug mantis 8323*/
	FUNCTION ff_desagente(
			pcagente	IN	NUMBER,
			pcidioma	IN	NUMBER,
			pformato	IN	NUMBER DEFAULT 0
	) RETURN VARCHAR2
	IS
	  vobjectname VARCHAR2(500):='FF_DESAGENTE';
	  vparam      VARCHAR2(500):='par¿metros - pcagente:'
	                        || pcagente;
	  vpasexec    NUMBER(5):=1;
	  vdesagente  VARCHAR2(500);
	  vvalor      VARCHAR2(500);
	  vnum_err    NUMBER;
	  e_object_error EXCEPTION;
	  e_param_error EXCEPTION;
	BEGIN
	    /*Comprovaci¿ de par¿metres d'entrada*/
	    IF pcagente IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vnum_err:=f_desagente(pcagente, vdesagente);

	    IF vnum_err<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    IF pformato=1 THEN
	      SELECT f_get_desnivel(a.ctipage, NULL, pcidioma)
	        INTO vvalor
	        FROM agentes a
	       WHERE a.cagente=pcagente;

	      vdesagente:=vvalor
	                  || ' - '
	                  || vdesagente;
	    ELSIF pformato=2 THEN
	    /* Bug 18225 - APD - 12/04/2011 - si la longitud del pcagente es mayor que 6 no se debe*/
	    /* realizar el LPPAD*/
	    /* si la longitud en menor o igual que 6, debe realizar el LPAD, que es tal y como estaba*/
	      /* funcionando hasta ahora*/
	      IF length(pcagente)>6 THEN
	        SELECT a.cagente
	               || ' - '
	               || f_get_desnivel(a.ctipage, NULL, pcidioma)
	          /*ff_desvalorfijo(30, pcidioma, a.ctipage)*/
	          INTO vvalor
	          FROM agentes a
	         WHERE a.cagente=pcagente;
	      ELSE
	        SELECT lpad(a.cagente, 6, '0')
	               || ' - '
	               || f_get_desnivel(a.ctipage, NULL, pcidioma)
	          /*ff_desvalorfijo(30, pcidioma, a.ctipage)*/
	          INTO vvalor
	          FROM agentes a
	         WHERE a.cagente=pcagente;
	      END IF;

	      /* Fin Bug 18225 - APD - 12/04/2011*/
	      vdesagente:=vvalor
	                  || ' - '
	                  || vdesagente;
	    END IF;

	    RETURN vdesagente;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Objeto invocado con par¿metros erroneos');

	             RETURN '**'; WHEN e_object_error THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'Error F_DESAGENTE. Num_err:'
	                                                                           || vnum_err);

	             RETURN '**'; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN '**';
	END ff_desagente;
	FUNCTION f_buscatipage(
			pcempres	IN	NUMBER,
			pctipage	IN	NUMBER,
			pfbusca	IN	DATE DEFAULT NULL
	) RETURN NUMBER
	IS
	  /*****************************************************************
	      f_buscatipage:
	      Aquesta funci¿ t¿ el prop¿sit:
	      a)     Es retorna el codi d del agent que es
	          correspongui amb l'empresa, amb el tipus de agent
	          i el periode sol.licitat ( pctipage informat).
	          La idea principal es per exemple obtenir el nodo arrel
	       b) En cas d'error torna un n¿mero negatiu
	          -1 : Par¿metre obligatori ¿s a NULL
	          -2 : Depende de m¿s de un agente
	          -3 : No se ha encontrado el agente del que depende
	          -4 : Error en la tabla REDCOMERCIAL
	          -5 : La tabla REDCOMERCIAL no tiene estructura de arbol
	  *****************************************************************/
	  xfbusca DATE;
	  cagente redcomercial.cagente%TYPE;
	  ex_bad_structure EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_bad_structure, -1436);
	BEGIN
	    IF pcempres IS NULL  OR
	       pctipage IS NULL THEN
	      cagente:=-1;
	    ELSE
	      xfbusca:=nvl(pfbusca, f_sysdate);

	      BEGIN
	          SELECT cagente
	            INTO cagente
	            FROM redcomercial
	           WHERE cempres=pcempres AND
	                 ctipage=pctipage AND
	                 fmovini<=xfbusca AND
	                 (fmovfin>xfbusca  OR
	                  fmovfin IS NULL);
	      EXCEPTION
	          WHEN too_many_rows THEN
	            cagente:=-2; /*Depende de m¿s de un agente*/
	          WHEN no_data_found THEN
	            cagente:=-3; /*No se ha encontrado el agente del que depende*/
	          WHEN ex_bad_structure THEN
	            cagente:=-5;
	          /* La tabla REDCOMERCIAL no tiene estructura de arbol*/
	          WHEN OTHERS THEN
	            cagente:=-4; /*Error en la tabla REDCOMERCIAL*/
	      END;
	    END IF;

	    RETURN(cagente);
	END f_buscatipage;

	/*************************************************************************
	   Devuelve el numero de agente dependiendo del tipo de agente
	   param in pcempres  : c¿digo de la empresa
	   param in pctipage  : c¿digo del tipo de agente
	   param out pcontador : Numero de contador

	   return             : 0 - Ok , 1 Ko

	   bug 19049/89656 - 14/07/2011 - AMC
	*************************************************************************/
	FUNCTION f_get_contador_agente(
			pcempres	IN	NUMBER,
			pctipage	IN	NUMBER,
			pcontador	OUT	NUMBER
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_redcomercial.f_get_contador_agente';
	  vparam      VARCHAR2(500):='par¿metros - pcempres:'
	                        || pcempres
	                        || ' pctipage:'
	                        || pctipage;
	  vpasexec    NUMBER(5):=1;
	  v_ctipconta contadores_agente.ctipconta%TYPE;
	BEGIN
	    SELECT ctipage
	           || lpad(contador, 6, 0),ctipconta
	      INTO pcontador, v_ctipconta
	      FROM contadores_agente
	     WHERE cempres=pcempres AND
	           ctipage=pctipage
	    FOR UPDATE;

	    UPDATE contadores_agente
	       SET contador=contador+1
	     WHERE cempres=pcempres AND
	           ctipconta=v_ctipconta;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 9902733; -- 'Error al recuperar el c¿digo del agente.'
	END f_get_contador_agente;

	/*************************************************************************
	   Funci¿n que guardar la comisi¿n/sobrecomisi¿n del agente
	   param in pcagente  : c¿digo del agente
	   param in pccomisi    : C¿digo de la comisi¿n
	   param in pfinivig    : Fecha inicio vigencia
	   param in pffinvig    : Fecha fin vigencia
	   param in pccomind  : Indica si la comision es indirecta (1) o no (0)
	   return             : 0 todo correcto
	                        numero de error si ha habido un error
	 *************************************************************************/
	/* Bug 19169 - APD - 16/09/2011 - se crea la funcion*/
	FUNCTION f_set_comisionvig_agente(pcagente	IN	NUMBER,pccomisi	IN	NUMBER,pfinivig	IN	DATE,pffinvig	IN	DATE DEFAULT NULL,pccomind	IN	NUMBER DEFAULT 0) /* Bug 20999 - APD - 26/01/2012*/
	RETURN NUMBER
	IS
	  vctipo   codicomisio.ctipo%TYPE;
	  vfinivig comisionvig_agente.finivig%TYPE;
	  vffinvig comisionvig_agente.ffinvig%TYPE;
	  vccomisi comisionvig_agente.ccomisi%TYPE;
	  vncont   NUMBER;
	  vinsert  NUMBER:=0;
	BEGIN
	    IF pcagente IS NULL  OR
	       pccomisi IS NULL  OR
	       pfinivig IS NULL THEN
	      RETURN 103135; /* Faltan parametros*/
	    END IF;

	    /* Se busca el tipo de comisi¿n de la comisi¿n/sobrecomisi¿n que se quiere guardar/modificar.*/
	    SELECT ctipo
	      INTO vctipo
	      FROM codicomisio
	     WHERE ccomisi=pccomisi;

	    /* Si el tipo de comision es 2.-Sobrecomision y no est¿ informada la fecha fin vigencia --> error*/
	    IF vctipo=2 THEN
	      IF pffinvig IS NULL THEN
	        RETURN 103135; /* Faltan parametros*/
	      END IF;
	    END IF;

	    /* Se busca si ya existen comisiones en la tabla del tipo de comisi¿n de la comisi¿n/sobrecomisi¿n que se quiere guardar/modificar.*/
	    SELECT count(1)
	      INTO vncont
	      FROM comisionvig_agente ca,codicomisio c
	     WHERE ca.ccomisi=c.ccomisi AND
	           ca.cagente=pcagente AND
	           c.ctipo=vctipo AND
	           ca.ccomind=pccomind;

	    IF vncont>0 THEN
	      /* Comprobar que pfinivig es mayor que la ¿ltima finivig para el tipo de comisi¿n de la comisi¿n que se quiere guardar/modificar, si la comisi¿n que se quiere guardar no es la misma que la ¿ltima comisi¿n vigente.*/
	      IF vctipo=1 THEN /*Comision*/
	        SELECT ca.finivig,ca.ffinvig,ca.ccomisi
	          INTO vfinivig, vffinvig, vccomisi
	          FROM comisionvig_agente ca,codicomisio c
	         WHERE ca.ccomisi=c.ccomisi AND
	               ca.cagente=pcagente AND
	               c.ctipo=vctipo AND
	               ca.ffinvig IS NULL AND
	               ca.ccomind=pccomind;

	      /* No se pueden solapar fechas pero SI tienen que ser periodos consecutivos*/
	      /* por eso no se introduce la fecha fin, por defecto, la fecha fin de un periodo*/
	        /* sera la fecha inicio - 1 del periodo siguiente*/
	        IF vccomisi=pccomisi AND
	           pfinivig=vfinivig THEN
	          NULL; /* no se esta modificando la comision*/
	        ELSE
	          IF pfinivig<=vfinivig THEN
	            RETURN 9902365;
	          /* La fecha de inicio vigencia debe ser superior a la ¿ltima fecha de inicio vigencia*/
	          END IF;
	        END IF;
	      ELSIF vctipo=2 THEN /*Sobrecomisi¿n*/
	        SELECT ca.finivig,ca.ffinvig,ca.ccomisi
	          INTO vfinivig, vffinvig, vccomisi
	          FROM comisionvig_agente ca,codicomisio c
	         WHERE ca.ccomisi=c.ccomisi AND
	               ca.cagente=pcagente AND
	               c.ctipo=vctipo AND
	               ca.finivig=(SELECT max(ca1.finivig)
	                             FROM comisionvig_agente ca1,codicomisio c1
	                            WHERE ca1.cagente=ca.cagente AND
	                                  ca1.ccomisi=c1.ccomisi AND
	                                  c1.ctipo=c.ctipo) AND
	               ca.ccomind=pccomind;

	      /* No se pueden solapar fechas pero NO tienen por que ser periodos consecutivos*/
	      /* Es decir, puede haber sobrecomision un mes, pero al mes siguiente no, y al*/
	        /* siguiente volver a haber sobrecomision*/
	        IF vccomisi=pccomisi AND
	           pfinivig=vfinivig THEN
	          NULL; /* no se esta modificando la sobrecomision*/
	        ELSE
	          IF pfinivig<=vffinvig THEN
	            RETURN 109113;
	          /* La fecha de inicio no puede ser inferior a la m¿xima fecha de fin registrada.*/
	          END IF;
	        END IF;
	      END IF;
	    END IF;

	    IF vctipo=1 THEN /*Comisi¿n*/
	    BEGIN
			           /* se insertan
		(INSERT) los campos cagente, ccomisi y finivig*/ INSERT INTO comisionvig_agente (cagente,ccomisi,finivig,ccomind,falta,
		           cusualt) /*BUG 32540:NSS:12/08/2014*/
		    VALUES
		           (pcagente,pccomisi,pfinivig,pccomind,f_sysdate,f_user); /*BUG 32540:NSS:12/08/2014*/


	          vinsert:=1;
	      EXCEPTION
	          WHEN dup_val_on_index THEN
	            /* No se actualiza (UPDATE) ning¿n campo*/
	            NULL;
	      END;
	    ELSIF vctipo=2 THEN /*Sobrecomisi¿n -->*/
	      /* Control de fechas*/
	      IF pffinvig<pfinivig THEN
	        RETURN 9902126;
	      /* La fecha de inicio no puede ser m¿s grande que la fecha de fin*/
	      END IF;

	      BEGIN
			           /* se insertan
		(INSERT) los campos cagente, ccomisi, finivig y ffinvig*/ INSERT INTO comisionvig_agente (cagente,ccomisi,finivig,ffinvig,
		           ccomind,falta,cusualt) /*BUG 32540:NSS:12/08/2014*/
		    VALUES
		           (pcagente,pccomisi,pfinivig,pffinvig,pccomind,f_sysdate,
		           f_user); /*BUG 32540:NSS:12/08/2014*/

	      EXCEPTION
	          WHEN dup_val_on_index THEN
	            /* solo se actualiza (UPDATE) el campo ffinvig*/
	            UPDATE comisionvig_agente
	               SET ffinvig=pffinvig
	             WHERE cagente=pcagente AND
	                   ccomisi=pccomisi AND
	                   finivig=pfinivig AND
	                   ccomind=pccomind AND
	                   fmodif=f_sysdate /*BUG 32540:NSS:12/08/2014*/
	                   AND
	                   cusumod=f_user; /*BUG 32540:NSS:12/08/2014*/
	      END;
	    END IF;

			/*Si ya existen comisiones del mismo tipo de comisi¿n de la comisi¿n que se quiere guardar/modificar y se ha realizado un INSERT en la tabla COMISIONVIG_AGENTE, se actualiza la fecha fin vigencia del ¿ltimo registro vigente.*/ /* Si no hab¿a registros es porque se estaba insertando el primer registro del tipo de comisi¿n 1.-Comisi¿n o 2.-Sobrecomisi¿n*/ IF vncont>0
		       AND
		           vinsert=1
		       AND
		           vctipo=1 THEN /*Comisi¿n*/ UPDATE comisionvig_agente SET ffinvig=pfinivig-1,fmodif=f_sysdate,cusumod=f_user
		     WHERE
		           cagente=pcagente
		       AND
		           finivig<>pfinivig
		       AND
		           ffinvig IS NULL
		       AND
		           ccomisi IN
		           (
		    SELECT
		           ccomisi
		      FROM
		           codicomisio
		     WHERE
		           ctipo=vctipo)
		       AND
		           ccomind=pccomind;

	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_set_comisionvig_agente', 1, SQLCODE, SQLERRM);

	             RETURN 140999;
	END f_set_comisionvig_agente;

	/*************************************************************************
	   Funci¿n que guardar la descuento del agente
	   param in pcagente  : c¿digo del agente
	   param in pcdesc    : C¿digo de la descuento
	   param in pfinivig    : Fecha inicio vigencia
	   param in pffinvig    : Fecha fin vigencia
	   return             : 0 todo correcto
	                        numero de error si ha habido un error
	 *************************************************************************/
	FUNCTION f_set_descuentovig_agente(
			pcagente	IN	NUMBER,
			pcdesc	IN	NUMBER,
			pfinivig	IN	DATE,
			pffinvig	IN	DATE DEFAULT NULL
	) RETURN NUMBER
	IS
	  vctipo   codidesc.ctipo%TYPE;
	  vfinivig descvig_agente.finivig%TYPE;
	  /*vffinvig       descvig_agente.ffinvig%TYPE;*/
	  vcdesc   descvig_agente.cdesc%TYPE;
	  vncont   NUMBER;
	  vinsert  NUMBER:=0;
	BEGIN
	    IF pcagente IS NULL  OR
	       pcdesc IS NULL  OR
	       pfinivig IS NULL THEN
	      RETURN 103135; /* Faltan parametros*/
	    END IF;

	    /* Se busca si ya existen descuentos en la tabla del tipo de descuento del descuento que se quiere guardar/modificar.*/
	    SELECT count(1)
	      INTO vncont
	      FROM descvig_agente ca
	     WHERE ca.cagente=pcagente AND
	           ca.cdesc=pcdesc;

	    IF vncont>0 THEN
	      /* Comprobar que pfinivig es mayor que la ¿ltima finivig para el tipo de comisi¿n de la comisi¿n que se quiere guardar/modificar, si la comisi¿n que se quiere guardar no es la misma que la ¿ltima comisi¿n vigente.*/
	      SELECT ca.finivig,ca.cdesc
	        INTO vfinivig, vcdesc
	        FROM descvig_agente ca,codidesc c
	       WHERE ca.cdesc=c.cdesc AND
	             ca.cagente=pcagente AND
	             ca.finivig IN(SELECT max(finivig)
	                             FROM descvig_agente
	                            WHERE cdesc=c.cdesc AND
	                                  cagente=ca.cagente);

	      IF vcdesc=pcdesc AND
	         pfinivig=vfinivig THEN
	        NULL; /* no se esta modificando la sobrecomision*/
	      ELSE
	        IF pfinivig<=vfinivig THEN
	          RETURN 9902365;
	        /* La fecha de inicio vigencia debe ser superior a la ¿ltima fecha de inicio vigencia*/
	        END IF;
	      END IF;
	    END IF;

	    IF pffinvig<pfinivig THEN
	      RETURN 9902126;
	    /* La fecha de inicio no puede ser m¿s grande que la fecha de fin*/
	    END IF;

	    BEGIN
			           /* se insertan
		(INSERT) los campos cagente, ccomisi y finivig*/ INSERT INTO descvig_agente (cagente,cdesc,finivig,ffinvig)
		    VALUES
		           (pcagente,pcdesc,pfinivig,pffinvig);

	    EXCEPTION
	        WHEN dup_val_on_index THEN
	          /* solo se actualiza (UPDATE) el campo ffinvig*/
	          UPDATE descvig_agente
	             SET ffinvig=pffinvig
	           WHERE cagente=pcagente AND
	                 cdesc=pcdesc AND
	                 finivig=pfinivig;
	    END;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_set_descuentovig_agente', 1, SQLCODE, SQLERRM);

	             RETURN 140999;
	END f_set_descuentovig_agente;

	/*************************************************************************
	      Inserta un valor del producto de participaci¿n de utilidades para el agente
	      param in pcagente  : c¿digo del agente
	      param in psproduc    : C¿digo del producto
	      param in pcactivi   : C¿digo de la actividad
	      return             : 0 todo correcto
	                           numero de error si ha habido un error
	   *************************************************************************/
	/* Bug 19169 - APD - 16/09/2011 - se crea la funcion*/
	FUNCTION f_set_prodparticipacion(
			pcagente	IN	NUMBER,
			psproduc	IN	NUMBER,
			pcactivi	IN	NUMBER
	) RETURN NUMBER
	IS
	  e_params EXCEPTION;
	  salir EXCEPTION;
	  num_err NUMBER:=0;
	  vcont   NUMBER;
	BEGIN
	    IF pcagente IS NULL  OR
	       psproduc IS NULL  OR
	       pcactivi IS NULL THEN
	      RAISE e_params;
	    END IF;

	    SELECT count(1)
	      INTO vcont
	      FROM prodparticipacion_agente
	     WHERE cagente=pcagente AND
	           sproduc=psproduc AND
	           cactivi=pcactivi;

	    IF vcont<>0 THEN
	      num_err:=108959; /* Este registro ya existe*/

	      RAISE salir;
	    END IF;

	    /*BEGIN*/
			INSERT INTO prodparticipacion_agente
		           (cagente,sproduc,cactivi)
		    VALUES
		           (pcagente,psproduc,pcactivi);


	    /*EXCEPTION
	       WHEN DUP_VAL_ON_INDEX THEN
	          UPDATE prodparticipacion_agente
	             SET sproduc = psproduc,
	                 cactivi = pcactivi
	           WHERE cagente = pcagente;
	    END;*/
	    RETURN num_err;
	EXCEPTION
	  WHEN e_params THEN
	             p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_set_prodparticipacion', 1, 103135, f_axis_literales(103135));

	             RETURN 103135; WHEN salir THEN
	             p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_set_prodparticipacion', 2, num_err, f_axis_literales(num_err));

	             RETURN num_err; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_set_prodparticipacion', 3, SQLCODE, SQLERRM);

	             RETURN 140999;
	END f_set_prodparticipacion;

	/*************************************************************************
	      Inserta un valor del Soporte por ARP
	      param in pcmodo ; 1.-Alta; 2.-Modif
	      param in pcagente  : c¿digo del agente
	      param in piimporte    : Importe que se le asigna a algunas ADN's por dar soporte administrativo
	      param in pfinivig   : Fecha inicio vigencia
	      param in pffinvig   : Fecha fin vigencia
	      return             : 0 todo correcto
	                           numero de error si ha habido un error
	   *************************************************************************/
	/* Bug 19169 - APD - 16/09/2011 - se crea la funcion*/
	FUNCTION f_set_soportearp(
			pcmodo	IN	NUMBER,
			pcagente	IN	NUMBER,
			piimporte	IN	NUMBER,
			pfinivig	IN	DATE,
			pffinvig	IN	DATE
	) RETURN NUMBER
	IS
	  e_params EXCEPTION;
	  salir EXCEPTION;
	  num_err  NUMBER:=0;
	  vffinvig soportearp_agente.ffinvig%TYPE;
	  vpasexec NUMBER;
	  vcont    NUMBER;
	BEGIN
	    vpasexec:=1;

	    IF pcagente IS NULL  OR
	       piimporte IS NULL  OR
	       pfinivig IS NULL  OR
	       pffinvig IS NULL THEN
	      RAISE e_params;
	    END IF;

	    vpasexec:=2;

	    /*----------------------------*/
	    /* Se realizan validaciones --*/
	    /*----------------------------*/
	    /* se valida no exista el registro  si se est¿ realizando una Alta*/
	    IF pcmodo=1 THEN /* 1.-Alta, 2.-Modif.*/
	      SELECT count(1)
	        INTO vcont
	        FROM soportearp_agente
	       WHERE cagente=pcagente AND
	             trunc(finivig)=trunc(pfinivig);

	      IF vcont<>0 THEN
	        num_err:=108959; /* Este registro ya existe*/

	        RAISE salir;
	      END IF;
	    END IF;

	    /* Control de fechas*/
	    IF to_char(pffinvig, 'dd/mm/yyyy')<to_char(pfinivig, 'dd/mm/yyyy') THEN
	      num_err:=9902126;

	      /* La fecha de inicio no puede ser m¿s grande que la fecha de fin*/
	      RAISE salir;
	    END IF;

	    IF pcmodo=1 THEN /* 1.-Alta, 2.-Modif.*/
	    BEGIN
	          SELECT max(ffinvig)
	            INTO vffinvig
	            FROM soportearp_agente
	           WHERE cagente=pcagente;
	      EXCEPTION
	          WHEN OTHERS THEN
	            num_err:=140999;

	            RAISE salir;
	      END;

	    /* si vfinivig IS NULL es porque todavia no hay datos en soportearp_agente para ese agente*/
	    /* si vfinivig IS NOT NULL si se debe hacer la validacion de las fechas*/
	    IF vffinvig IS NOT NULL AND to_char(pfinivig, 'dd/mm/yyyy') <= to_char(vffinvig, 'dd/mm/yyyy') THEN num_err := 109113;
	    /* La fecha de inicio no puede ser inferior a la m¿xima fecha de fin registrada.*/
	    RAISE salir; END IF;
	    END IF;

	    vpasexec:=3;

	    BEGIN
			INSERT INTO soportearp_agente
		           (cagente,iimporte,finivig,ffinvig)
		    VALUES
		           (pcagente,piimporte,pfinivig,pffinvig);

	    EXCEPTION
	        WHEN dup_val_on_index THEN
	          vpasexec:=4;

	          UPDATE soportearp_agente
	             SET iimporte=piimporte,finivig=pfinivig,ffinvig=pffinvig
	           WHERE cagente=pcagente;
	    END;

	    RETURN num_err;
	EXCEPTION
	  WHEN e_params THEN
	             p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_set_soportearp', vpasexec, 103135, f_axis_literales(103135));

	             RETURN 103135; /* Faltan par¿metros*/
	  WHEN salir THEN
	             p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_set_soportearp', vpasexec, num_err, f_axis_literales(num_err));

	             RETURN num_err; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_set_soportearp', vpasexec, SQLCODE, SQLERRM);

	             RETURN 140999;
	END f_set_soportearp;

	/*************************************************************************
	      Inserta una subvenci¿n
	      param in pcmodo ; 1.-Alta; 2.-Modif
	      param in pcagente  : c¿digo del agente
	      param in psproduc    : C¿digo del producto
	      param in pcactivi   : C¿digo de la actividad
	      param in piimporte   : Importe de la subvenci¿n
	      return             : 0 todo correcto
	                           numero de error si ha habido un error
	   *************************************************************************/
	/* Bug 19169 - APD - 16/09/2011 - se crea la funcion*/
	FUNCTION f_set_subvencion(
			pcmodo	IN	NUMBER,
			pcagente	IN	NUMBER,
			psproduc	IN	NUMBER,
			pcactivi	IN	NUMBER,
			piimporte	IN	NUMBER
	) RETURN NUMBER
	IS
	  e_params EXCEPTION;
	  salir EXCEPTION;
	  num_err  NUMBER:=0;
	  vcont    NUMBER;
	  vcestado subvencion_agente.cestado%TYPE;
	BEGIN
	    IF pcagente IS NULL  OR
	       psproduc IS NULL  OR
	       piimporte IS NULL THEN
	      RAISE e_params;
	    END IF;

	    /*----------------------------*/
	    /* Se realizan validaciones --*/
	    /*----------------------------*/
	    /* se valida no exista el registro  si se est¿ realizando una Alta*/
	    IF pcmodo=1 THEN /* 1.-Alta, 2.-Modif.*/
	      SELECT count(1)
	        INTO vcont
	        FROM subvencion_agente
	       WHERE cagente=pcagente AND
	             sproduc=psproduc;

	      IF vcont<>0 THEN
	        num_err:=108959; /* Este registro ya existe*/

	        RAISE salir;
	      END IF;
	    ELSIF pcmodo=2 THEN /* 1.-Alta, 2.-Modif.*/
	    /* Bug 20287 - APD - 05/12/2011 - solo se permiten modificar aquellos*/
	    /* registros que aun no han sido traspasados (cestado = 0)*/
	    BEGIN
	          SELECT cestado
	            INTO vcestado
	            FROM subvencion_agente
	           WHERE cagente=pcagente AND
	                 sproduc=psproduc;
	      EXCEPTION
	          WHEN OTHERS THEN
	            num_err:=140999;

	            RAISE salir;
	      END; IF vcestado = 1 THEN num_err := 9902873;
	    /* Registro ya traspasado. No se puede modificar.*/
	    RAISE salir; END IF;
	    END IF;

	    BEGIN
	    /* Bug 20287 - APD - 05/12/2011 - se a¿ade el campo cestado*/
	        /* siempre se inserta 0.-Pendiente traspasar al insertar el registro*/
			INSERT INTO subvencion_agente
		           (cagente,sproduc,cactivi,iimporte,cestado)
		    VALUES
		           (pcagente,psproduc,pcactivi,piimporte,0);

	    /* Fin Bug 20287 - APD - 05/12/2011*/
	    EXCEPTION
	        WHEN dup_val_on_index THEN
	          UPDATE subvencion_agente
	             SET iimporte=piimporte
	           WHERE cagente=pcagente AND
	                 sproduc=psproduc;
	    END;

	    RETURN num_err;
	EXCEPTION
	  WHEN e_params THEN
	             p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_set_subvencion', 1, 103135, f_axis_literales(103135));

	             RETURN 103135; WHEN salir THEN
	             p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_set_subvencion', 1, num_err, f_axis_literales(num_err));

	             RETURN num_err; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_set_subvencion', 2, SQLCODE, SQLERRM);

	             RETURN 140999;
	END f_set_subvencion;

	/*************************************************************************
	      Elimina un registro del producto de participaci¿n de utilidades para el agente
	      param in pcagente  : c¿digo del agente
	      param in psproduc    : C¿digo del producto
	      param in pcactivi   : C¿digo de la actividad
	      return             : 0 todo correcto
	                           numero de error ha habido un error
	   *************************************************************************/
	/* Bug 19169 - APD - 16/09/2011 - se crea la funcion*/
	FUNCTION f_del_prodparticipacion(
			pcagente	IN	NUMBER,
			psproduc	IN	NUMBER,
			pcactivi	IN	NUMBER
	) RETURN NUMBER
	IS
	  e_params EXCEPTION;
	  num_err NUMBER:=0;
	BEGIN
	    IF pcagente IS NULL  OR
	       psproduc IS NULL  OR
	       pcactivi IS NULL THEN
	      RAISE e_params;
	    END IF;

	    DELETE FROM prodparticipacion_agente
	     WHERE cagente=pcagente AND
	           sproduc=psproduc AND
	           cactivi=pcactivi;

	    RETURN num_err;
	EXCEPTION
	  WHEN e_params THEN
	             p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_del_prodparticipacion', 1, 103135, f_axis_literales(103135));

	             RETURN 103135; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_del_prodparticipacion', 2, SQLCODE, SQLERRM);

	             RETURN 140999;
	END f_del_prodparticipacion;

	/*************************************************************************
	      Elimina un registro del Soporte por ARP
	      param in pcagente  : c¿digo del agente
	      param in pfinivig    : Fecha inicio vigencia
	      return             : 0 todo correcto
	                           numero de error ha habido un error
	   *************************************************************************/
	/* Bug 19169 - APD - 16/09/2011 - se crea la funcion*/
	FUNCTION f_del_soportearp(
			pcagente	IN	NUMBER,
			pfinivig	IN	DATE
	) RETURN NUMBER
	IS
	  e_params EXCEPTION;
	  num_err NUMBER:=0;
	BEGIN
	    IF pcagente IS NULL  OR
	       pfinivig IS NULL THEN
	      RAISE e_params;
	    END IF;

	    DELETE FROM soportearp_agente
	     WHERE cagente=pcagente AND
	           finivig=pfinivig;

	    RETURN num_err;
	EXCEPTION
	  WHEN e_params THEN
	             p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_del_soportearp', 1, 103135, f_axis_literales(103135));

	             RETURN 103135; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_del_soportearp', 2, SQLCODE, SQLERRM);

	             RETURN 140999;
	END f_del_soportearp;

	/*************************************************************************
	      Elimina un registro de una subvenci¿n
	      param in pcagente  : c¿digo del agente
	      param in psproduc    : C¿digo del producto
	      param in pcactivi    : C¿digo de la actividad
	      return             : 0 todo correcto
	                           numero de error ha habido un error
	   *************************************************************************/
	/* Bug 19169 - APD - 16/09/2011 - se crea la funcion*/
	FUNCTION f_del_subvencion(
			pcagente	IN	NUMBER,
			psproduc	IN	NUMBER,
			pcactivi	IN	NUMBER
	) RETURN NUMBER
	IS
	  e_params EXCEPTION;
	  num_err NUMBER:=0;
	BEGIN
	    IF pcagente IS NULL  OR
	       psproduc IS NULL THEN
	      RAISE e_params;
	    END IF;

	    DELETE FROM subvencion_agente
	     WHERE cagente=pcagente AND
	           sproduc=psproduc AND
	           cactivi=pcactivi;

	    RETURN num_err;
	EXCEPTION
	  WHEN e_params THEN
	             p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_del_subvencion', 1, 103135, f_axis_literales(103135));

	             RETURN 103135; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_del_subvencion', 2, SQLCODE, SQLERRM);

	             RETURN 140999;
	END f_del_subvencion;

	/*************************************************************************
	      Traspasa los registros de subvencion_agente a ctactes
	      param in pcagente  : c¿digo del agente
	      param in pnplanpago    : Indica los meses a los que se aplica la subvenci¿n en la liquidaci¿n
	      return             : 0 todo correcto
	                           numero de error ha habido un error
	   *************************************************************************/
	/* Bug 20287 - APD - 05/12/2011 - se crea la funcion*/
	FUNCTION f_traspasar_subvencion(
			pcagente	IN	NUMBER,
			pnplanpago	IN	NUMBER
	) RETURN NUMBER
	IS
	  e_params EXCEPTION;
	  num_err   NUMBER:=0;
	  vtdescrip VARCHAR2(1000);
	  vfvalor   DATE;
	  i         NUMBER;
	  vcont     NUMBER;
	  vprod     NUMBER;
	BEGIN
	    IF pcagente IS NULL  OR
	       pnplanpago IS NULL THEN
	      RAISE e_params;
	    END IF;

	    IF pnplanpago<=0 THEN
	      RETURN 9902895; /* El Plan de pago debe ser mayor de 0.*/
	    END IF;

	    /* variable para controlar si se han traspasado registros*/
	    vcont:=0;

	    /* Se buscan todos los registros pendientes de traspasar (cestato = 0)*/
	    FOR reg IN (SELECT cagente,sproduc,cactivi,iimporte,cestado,nplanpago
	                  FROM subvencion_agente
	                 WHERE cagente=pcagente AND
	                       cestado=0) LOOP
	        /* Recuperamos la descripcion del producto*/
	        num_err:=f_dessproduc(reg.sproduc, 1, pac_md_common.f_get_cxtidioma, vtdescrip);

	        IF num_err<>0 THEN
	          RETURN num_err;
	        END IF;

	        i:=1;

	        WHILE i<=pnplanpago LOOP
	            vfvalor:=add_months(trunc(f_sysdate), i-1);

	            SELECT decode (nvl(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'CTAPROD'), 0), 1, reg.sproduc,
	                                                                                                             0)
	              INTO vprod
	              FROM dual;

	            num_err:=pac_liquida.f_set_cta(pac_md_common.f_get_cxtempresa, reg.cagente, NULL, NULL, 1, reg.iimporte, NULL, vtdescrip, 1, NULL, NULL, 51, NULL, vfvalor, NULL, vprod);

	            IF num_err<>0 THEN
	              RETURN num_err;
	            END IF;

	            i:=i+1;
	        END LOOP;

	        /* Si el registro se ha traspasado, se marca como traspasado (cestado = 1)*/
	        /* Se informa el campo nplanpago para tener la informacion de con cual*/
	        /* nplanpago se ha traspasado el registro*/
	        UPDATE subvencion_agente
	           SET cestado=1,nplanpago=pnplanpago
	         WHERE cagente=reg.cagente AND
	               sproduc=reg.sproduc;

	        /* Se actualiza el nplanpago a nivel de agente*/
	        UPDATE agentes_comp
	           SET nplanpago=pnplanpago
	         WHERE cagente=reg.cagente;

	        vcont:=vcont+1;
	    END LOOP;

	    IF vcont=0 THEN
	      RETURN 9902896; /* Ning¿n registro traspasado.*/
	    END IF;

	    RETURN num_err;
	EXCEPTION
	  WHEN e_params THEN
	             p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_traspasar_subvencion', 1, 103135, f_axis_literales(103135));

	             RETURN 103135; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_traspasar_subvencion', 2, SQLCODE, SQLERRM);

	             RETURN 140999;
	END f_traspasar_subvencion;

	/*************************************************************************
	   Retorna el agente padre del agente que se especifica
	   O retorna el agente padre el tipo que se especifica del agente
	   return             : null error
	                        ID agente padre
	*************************************************************************/
	/* Bug 20071 - JTS - 23/12/2011 - se crea la funcion*/
	FUNCTION f_busca_padre(
			pcempres	IN	NUMBER,
			pcagente	IN	NUMBER,
			pctipage	IN	NUMBER,
			pfbusca	IN	DATE
	) RETURN NUMBER
	IS
	  v_padre   NUMBER;
	  v_padre2  NUMBER;
	  v_ctipage NUMBER:=pctipage;
	  v_fbusca  DATE:=pfbusca;
	BEGIN
	    IF pcempres IS NULL  OR
	       pcagente IS NULL THEN
	      p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_busca_padre', 1, 'Parametros incorrectos', '');

	      RETURN NULL;
	    END IF;

	    IF v_fbusca IS NULL THEN
	      v_fbusca:=trunc(f_sysdate);
	    END IF;

	    IF pctipage IS NULL THEN BEGIN
	          SELECT cpadre
	            INTO v_padre
	            FROM redcomercial
	           WHERE cagente=pcagente AND
	                 cempres=pcempres AND
	                 fmovini<=v_fbusca AND
	                 (fmovfin>v_fbusca  OR
	                  fmovfin IS NULL);
	      EXCEPTION
	          WHEN no_data_found THEN
	            /*No tiene padre*/
	            RETURN NULL;
	      END;
	    ELSE BEGIN
	          SELECT cpadre,ctipage
	            INTO v_padre, v_ctipage
	            FROM redcomercial
	           WHERE cagente=pcagente AND
	                 cempres=pcempres AND
	                 fmovini<=v_fbusca AND
	                 (fmovfin>v_fbusca  OR
	                  fmovfin IS NULL);

	          IF v_ctipage=pctipage THEN
	            RETURN v_padre;
	          END IF;

	          WHILE TRUE LOOP
	              SELECT cpadre,ctipage
	                INTO v_padre2, v_ctipage
	                FROM redcomercial
	               WHERE cagente=v_padre AND
	                     cempres=pcempres AND
	                     fmovini<=v_fbusca AND
	                     (fmovfin>v_fbusca  OR
	                      fmovfin IS NULL);

	              IF v_ctipage=pctipage THEN
	                RETURN v_padre;
	              ELSE
	                v_padre:=v_padre2;
	              END IF;
	          END LOOP;

	          v_padre:=NULL;
	      EXCEPTION
	          WHEN no_data_found THEN
	            /*No tiene padre de este tipo*/
	            RETURN NULL;
	      END;
	    END IF;

	    RETURN v_padre;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_busca_padre', 2, SQLCODE, SQLERRM);

	             RETURN NULL;
	END f_busca_padre;

	/*************************************************************************
	   Retorna el tipo de iva y de retencion de un regiment fiscal
	   param in  psperson
	   param in pcagente
	   param out piva
	   param out pretenc
	   return             : 0 - ok , 1 - Ko

	   Bug 20916/103702 - 13/01/2012 - AMC
	*************************************************************************/
	FUNCTION f_get_ivaagente(
			psperson	IN	NUMBER,
			pcagente	IN	NUMBER,
			piva	OUT	NUMBER,
			pretenc	OUT	NUMBER
	) RETURN NUMBER
	IS
	  vcregfiscal NUMBER;
	BEGIN
	    BEGIN
	        SELECT cregfiscal
	          INTO vcregfiscal
	          FROM per_regimenfiscal
	         WHERE sperson=psperson AND
	               fefecto=(SELECT max(fefecto)
	                          FROM per_regimenfiscal
	                         WHERE sperson=psperson AND
	                               fefecto<=trunc(f_sysdate));
	    EXCEPTION
	        WHEN no_data_found THEN
	          piva:=0;

	          pretenc:=0;

	          RETURN 0;
	    END;

	    BEGIN
	        SELECT ctipiva,cretenc
	          INTO piva, pretenc
	          FROM regfiscal_ivaretenc
	         WHERE cregfiscal=vcregfiscal;
	    EXCEPTION
	        WHEN no_data_found THEN
	          piva:=0;

	          pretenc:=0;

	          RETURN 0;
	    END;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_get_ivaagente', 2, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_get_ivaagente;
	FUNCTION f_get_desnivel(
			pctipage	IN	NUMBER,
			pcempres	IN	NUMBER,
			pcidioma	IN	NUMBER
	) RETURN VARCHAR2
	IS
	  vdescrip VARCHAR2(200);
	BEGIN
	    SELECT descrip
	      INTO vdescrip
	      FROM desnivelage
	     WHERE ctipage=pctipage AND
	           cempres=nvl(pcempres, pac_contexto.f_contextovalorparametro('IAX_EMPRESA')) AND
	           cidioma=pcidioma;

	    RETURN vdescrip;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_get_desnivel', 2, SQLCODE, SQLERRM);

	             RETURN '';
	END f_get_desnivel;
	FUNCTION f_get_niveles(
			pcempres	IN	NUMBER,
			pcidioma	IN	NUMBER
	) RETURN SYS_REFCURSOR
	IS
	  cur SYS_REFCURSOR;
	BEGIN
	    OPEN cur FOR
	      SELECT d.ctipage,d.descrip
	        FROM codnivelage c,desnivelage d
	       WHERE c.ctipage=d.ctipage AND
	             c.cempres=d.cempres AND
	             c.cempres=nvl(pcempres, pac_contexto.f_contextovalorparametro('IAX_EMPRESA')) AND
	             d.cidioma=nvl(pcidioma, pac_contexto.f_contextovalorparametro('IAX_IDIOMA')) AND
	             c.cbuscar=1
	       ORDER BY d.ctipage;

	    RETURN cur;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_get_niveles', 2, SQLCODE, SQLERRM);

	             RETURN NULL;
	END f_get_niveles;
	FUNCTION f_get_ageniveles(
			pcempres	IN	NUMBER,
			pcidioma	IN	NUMBER
	) RETURN SYS_REFCURSOR
	IS
	  cur SYS_REFCURSOR;
	BEGIN
	    OPEN cur FOR
	      SELECT d.ctipage catribu,d.descrip tatribu
	        FROM codnivelage c,desnivelage d
	       WHERE c.ctipage=d.ctipage AND
	             c.cempres=d.cempres AND
	             c.cempres=nvl(pcempres, pac_contexto.f_contextovalorparametro('IAX_EMPRESA')) AND
	             d.cidioma=nvl(pcidioma, pac_contexto.f_contextovalorparametro('IAX_IDIOMA'))
	       ORDER BY d.ctipage;

	    RETURN cur;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_redcomercial.f_get_ageniveles', 2, SQLCODE, SQLERRM);

	             RETURN NULL;
	END f_get_ageniveles;

	/*************************************************************************
	   Sincronizaci¿n de recibos (de una p¿liza, o un recibo) de un agente
	   con una aplicaci¿n externa
	   param in pcagente : obligatorio
	   param in psseguro : opcional
	   param in pnrecibo : opcional
	   return             : 0 - ok , 1 - Ko

	   Bug 21597 - 08/03/2012 - MDS
	*************************************************************************/
	FUNCTION f_sincroniza_recibos(
			pcagente	IN	NUMBER,
			psseguro	IN	NUMBER,
			pnrecibo	IN	NUMBER
	) RETURN NUMBER
	IS
	  CURSOR c_recibos IS
	    SELECT r.cempres,r.sseguro,r.nrecibo,mr.smovrec
	      FROM recibos r,movrecibo mr
	     WHERE r.nrecibo=mr.nrecibo AND
	           r.cagente=pcagente AND
	           r.sseguro=nvl(psseguro, r.sseguro) AND
	           r.nrecibo=nvl(pnrecibo, r.nrecibo) AND
	           mr.fmovfin IS NULL AND
	           mr.cestrec IN(0, 3);

	  verror      NUMBER;
	  vterminal   VARCHAR2(20);
	  perror      VARCHAR2(2000);
	  vtipoaccion NUMBER;
	  vtipopago   NUMBER;
	  vemitido    NUMBER;
	  vsinterf    NUMBER;
	BEGIN
	    vtipoaccion:=2; /* Consulta*/

	    vtipopago:=4; /* Pago*/

	    verror:=pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vterminal);

	    FOR c_rec IN c_recibos LOOP
	        verror:=pac_con.f_emision_pagorec(c_rec.cempres, vtipoaccion, /* Consulta*/
	                vtipopago, /* Pago*/
	                c_rec.nrecibo, c_rec.smovrec, vterminal, vemitido, vsinterf, perror, f_user);

	        IF verror<>0  OR
	           trim(perror) IS NOT NULL THEN
	          IF verror=0 THEN
	            verror:=151323;
	          END IF;

	          p_tab_error(f_sysdate, f_user, 'PAC_REDCOMERCIAL.f_sincroniza_recibos', 1, 'error no controlado: nrecibo='
	                                                                                     || c_rec.nrecibo
	                                                                                     || ' smovrec='
	                                                                                     || c_rec.smovrec, perror
	                                                                                                       || ' '
	                                                                                                       || verror);
	        END IF;
	    END LOOP;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_REDCOMERCIAL.f_sincroniza_recibos', 2, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_sincroniza_recibos;

	/*************************************************************************
	   Funcion que valida el cambio de estado de un agente
	   param in pcempres
	   param in pcagente
	   param in pctipage
	   param in pcestant : estado actual del agente (equivale al estado anterior)
	   param in pcestact : estado al cual se quiere pasar el agente (equivale al estado actual)
	   return             : 0 - ok , 1 - Ko
	*************************************************************************/
	/*Bug 21682 - APD - 25/04/2012*/
	FUNCTION f_valida_estado(
			pcempres	IN	NUMBER,
	pcagente	IN	agentes.cagente%TYPE,
	pctipage	IN	agentes.ctipage%TYPE,
			 /* pcestant	IN	agentes.cactivo%TYPE,*/
			 pcestact	IN	agentes.cactivo%TYPE,
	pctipmed	IN	agentes.ctipmed%TYPE,
	pnregdgs	IN	agentes.nregdgs%TYPE
	)
	RETURN NUMBER
	IS
	CURSOR c_transiciones(

	    p_cestant IN NUMBER) IS
	    SELECT at.tvalest
	      FROM age_transiciones at
	     WHERE at.cempres=pcempres AND
	           at.ctipage=pctipage AND
	           (at.crealiza=(SELECT crealiza
	                           FROM cfg_accion
	                          WHERE caccion='TRANS_ESTADO_AGE' AND
	                                ccfgacc=(SELECT ccfgacc
	                                           FROM cfg_user
	                                          WHERE cuser=pac_md_common.f_get_cxtusuario () AND
	                                                cempres=15))  OR
	            at.crealiza IS NULL) AND
	           (at.cestant=p_cestant  OR
	            (at.cestant IS NULL AND
	             p_cestant IS NULL)) AND
	           at.cestact=pcestact;

	  verror   NUMBER;
	  vselect  VARCHAR2(2000);
	  vselect2 VARCHAR2(2000);
	  vretorno NUMBER;
	  vcestant agentes.cactivo%TYPE;
	BEGIN
	    verror:=0;

	    BEGIN
	        SELECT cactivo
	          INTO vcestant
	          FROM agentes
	         WHERE cagente=pcagente;
	    EXCEPTION
	        WHEN OTHERS THEN
	          vcestant:=NULL;
	    END;

	    IF vcestant<>pcestact THEN
	      FOR reg IN c_transiciones(vcestant) LOOP
	          IF reg.tvalest IS NOT NULL THEN
	            vselect:=reg.tvalest;

	            vselect:=replace(vselect, ':PCEMPRES', nvl(to_char(pcempres), 'NULL'));

	            vselect:=replace(vselect, ':PCAGENTE', nvl(to_char(pcagente), 'NULL'));

	            vselect:=replace(vselect, ':PCTIPAGE', nvl(to_char(pctipage), 'NULL'));

	            vselect:=replace(vselect, ':PCESTANT', nvl(to_char(vcestant), 'NULL'));

	            vselect:=replace(vselect, ':PCESTACT', nvl(to_char(pcestact), 'NULL'));

	            vselect:=replace(vselect, ':PCTIPMED', nvl(to_char(pctipmed), 'NULL'));

	            /*Bug 24467 - XVM - 14/12/2012*/
	            vselect:=replace(vselect, ':PNREGDGS', nvl(to_char(chr(39)
	                                                               || pnregdgs
	                                                               || chr(39)), 'NULL'));

	            vselect2:=' begin :retorno := '
	                      || vselect
	                      || ' ; end;';

	            EXECUTE IMMEDIATE vselect2
	            USING OUT vretorno;

	            IF vretorno<>0 THEN
	              verror:=vretorno;

	              EXIT;
	            END IF;
	          END IF;
	      END LOOP;
	    END IF;

	    RETURN verror;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_REDCOMERCIAL.f_valida_estado', 2, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_valida_estado;

	/******************************************************************************
	 FUNCION: f_get_retencion
	 Funcion que devielve el tipo de retenci¿n segun la letra del cif.
	 Param in psperson
	 Param in pcidioma
	 Param out pcidioma
	 Param out pcidioma
	 Retorno 0- ok 1-ko

	 Bug 24514/128686 - 15/11/2012 - AMC
	******************************************************************************/
	FUNCTION f_get_retencion(
			psperson	IN	NUMBER,
			pcidioma	IN	NUMBER,
			pcempres	IN	NUMBER,
			pcretenc	OUT	NUMBER,
			pmensaje	OUT	VARCHAR2
	) RETURN NUMBER
	IS
	  vnumerr NUMBER;
	BEGIN
	    vnumerr:=pac_propio_age.f_get_retencion(psperson, pcidioma, pcempres, pcretenc, pmensaje);

	    RETURN vnumerr;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_REDCOMERCIAL.f_get_retencion', 2, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_get_retencion;

	/******************************************************************************
	  FUNCION: f_valida_regfiscal
	  Funcion que valida si el tipo de iva y regimen fiscal son introducidos correctamente.
	  Param in pcempres
	  Param in pcidioma
	  Param in psperson
	  Param in pctipage
	  Param in pctipiva
	  Param in pctipint
	  Param out
	  Retorno 0- ok 1-ko

	  Bug 27598-135742 - 28/01/2013 - ICG
	******************************************************************************/
	FUNCTION f_valida_regfiscal(
			pcempres	IN	NUMBER,
			pcidioma	IN	NUMBER,
			psperson	IN	NUMBER,
			pctipage	IN	NUMBER,
			pctipiva	IN	NUMBER,
			pctipint	IN	NUMBER,
			pmensaje	OUT	VARCHAR2
	) RETURN NUMBER
	IS
	  vnumerr NUMBER;
	BEGIN
	    vnumerr:=pac_propio_age.f_valida_regfiscal(pcempres, pcidioma, psperson, pctipage, pctipiva, pctipint, pmensaje);

	    RETURN vnumerr;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_REDCOMERCIAL.f_valida_regfiscal', 2, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_valida_regfiscal;

END pac_redcomercial;


/

  GRANT EXECUTE ON "AXIS"."PAC_REDCOMERCIAL" TO "AXIS00";
  GRANT EXECUTE ON "AXIS"."PAC_REDCOMERCIAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REDCOMERCIAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REDCOMERCIAL" TO "PROGRAMADORESCSI";
