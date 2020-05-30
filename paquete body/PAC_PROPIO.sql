--------------------------------------------------------
--  DDL for Package Body PAC_PROPIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PROPIO" IS
	/******************************************************************************
	NOMBRE:     PAC_PROPIO
	PROP¿SITO:  Package que contiene las funciones propias de cada instalaci¿n.
	REVISIONES:
	Ver    Fecha        Autor     Descripci¿n
	------ ----------  -------- ------------------------------------
	2.0    03/03/2009   DRA        2. BUG0009297: IAX - Gesti¿ de propostes - Revisi¿ punts pendents
	3.0    30/03/2009   JTS        3. BUG9402: CIV - TAR - Domiciliaciones
	4.0    03/04/2009   DRA        4. BUG0009423: IAX - Gesti¿ propostes retingudes: detecci¿ difer¿ncies al modificar capitals o afegir garanties
	5.0    21/04/2009   YIL        5. Bug 9794 - Se crea la funci¿n f_restar_limite_anual
	6.0    11/05/2009   APD        6. Bug 9685 - en lugar de coger la actividad de la tabla seguros,
	llamar a la funci¿n pac_seguros.ff_get_actividad
	7.0    01/05/2009   JRH        7. Bug 0009172: CRE055 - Rentas regulares e irregulares con c¿lculos a partir de renta
	8.0    27/05/2009   ETM        8. 0010231: APR - L¿mite de aportaciones en productos fiscales
	9.0    30/06/2009   SMF        9. BUG 10231.Correcci¿n de los limites fiscales (solo si Forfait esta seleccionado)
	10.0   29/05/2009   JTS       10. BUG 9658 - JTS - APR - Desarrollo PL de comisiones de adquisi¿n.#6.
	11.0   01/06/2009   RSC       11. 0010468 - APR - polizas con garantias reducidas
	12.0   13/07/2009   RSC       12. Bug 10350 - APR: Detalle de garant¿as (Tarificaci¿n)
	13.0   02/08/2009   ASN       13. 0010838: CRE070 - texto en recibos en producto decesos
	13.1   07/08/2009   ASN       13.1 0010888: APR - estandarizaci¿n de los codigos de error a retornar
	14.0   01/08/2009   NMM       14. Bug 10864: CEM - Tasa aplicable en Consorcio
	15.0   30/09/2009   AMC       15. Bug 11284 - N¿ DE CONTRATO FORMATO CEM. Se crea la funci¿n f_calc_contrato_interno
	16.0   09/10/2009   FAL       16. Bug 11424: CEM - N¿ de referencia cuestionario de salud. Se crea la funci¿n f_get_id_cuestsalud
	17.0   05/11/2009   APD       17. Bug 11595: CEM - Siniestros. Adaptaci¿n al nuevo m¿dulo de siniestros
	18.0   01/12/2009   AMC       18 bug 11308.Se a¿ade la funci¿n f_extrae_npoliza
	19.0   31/12/2009   NMM       19. 12442: ADAPTACI¿ PPJ (CAGRPRO 11).
	20.0   05/02/2010   AVT       20. 0012971: Incidencia cierre reaseguro producto 244 (Credit Vida Host)
	21.0   10/02/2010   AVT       21. 13047: CRE - Se detectan p¿lizas del PPJ Din¿mic que no tienen calcula la provisi¿n matem¿tica de Enero
	Per defecte les p¿lisses retingudes per rescat parcial Si generaran PM
	22.0   19/02/2010   JMF       22. 0012803 AGA - Acceso a la vista PERSONAS
	23.0   10/03/2010   RSC       23. 13515: APR - Error en el calculo de comisiones
	24.0   11/03/2010   ASN       24. 13607: APR - Comisiones de adquisi¿n en previo de cartera
	25.0   23/03/2010   ICV       25. 0013781: CEM - Modificaci¿n fichero de transferencias
	26.0   23/03/2010   JRH       26. 0013933: CEM - Recibos de comisiones
	27.0   19/04/2010   DRA       27. 0014071: CEM - Problema al volver a generar fichero de domiciliaciones
	28.0   16/04/2010   RSC       26. 0014160: CEM800 - Adaptar packages de productos de inversi¿n al nuevo m¿dulo de siniestros
	29.0   10/06/2010   RSC       27. 0013832: APRS015 - suplemento de aportaciones ¿nicas
	30.0   13/09/2010   ETM       28. 0015884: CEM - Fe de Vida. Nueva funci¿n que devolver¿ un REF CURSOR con las p¿lizas que deben enviar la carta de fe de vida.
	31.0   04/11/2010   APD       31. 0016095: Implementacion y parametrizacion del producto GROUPLIFE
	32.0   01/12/2010   RSC       32. 0016095: APR - Implementaci¿n y parametrizaci¿n del producto GROUPLIFE
	33.0   15/12/2010   JMP       33. 0017008: GRC - A¿adimos la funci¿n F_CONTADOR2
	34.0   30/06/2010   RSC       34. 0015057: field capital by provisions SRD
	35.0   24/01/2010   JMP       35. 0017341: APR703 - Suplemento de preguntas - FlexiLife
	36.0   10/02/2011   APD       36. 0017567: GRC003 - Funci¿n para n¿mero propio de siniestro
	37.0   10/02/2011   RSC       37. 0017633: field capital by provisions SRD
	38.0   28/02/2011   AMC       38. 17806: CRT003 - Traspaso de gen¿rico a especifico
	39.0   05/04/2011   SRA       39. 0017922: AGM701 - Consulta p¿lizas. Modificaci¿n de las fuciones de DDBB para que incluyan las p¿lizas externas.
	40.0   30/08/2011   JMF       40. 0019332: LCOL001 -numeraci¿n de p¿lizas y de solicitudes
	41.0   17/11/2011   ANS       41. 0019416: LCOL_S001-Siniestros y exoneraci¿n de pago de primas
	42.0   24/11/2011   APD       42. 0020153: LCOL_C001: Ajuste en el c¿lculo del recibo
	43.0   22/11/2011   RSC       43. 0020241: LCOL_T004-Parametrizaci¿n de Rescates (retiros)
	44.0   17/11/2011   JMC       44. 0019303: LCOL_T003-Analisis Polissa saldada/prorrogada. LCOL_TEC_ProductosBrechas04
	45.0   14/11/2011   JMP       45. 0018423: LCOL000 - Multimoneda
	46.0   29/11/2011   FAL       46. 0020314: GIP003 - Modificar el c¿lculo del Selo
	47.0   26/01/2012   JMP       47. 0018423/104212: LCOL705 - Multimoneda
	48.0   23/03/2012   RSC       48. 0021863: LCOL - Incidencias Reservas
	49.0   06/09/2012   MDS       49. 0023254: LCOL - qtrackers 4806 / 4808. M¿xim dels prestecs.
	50.0   25/09/2012   AVT       50. 0023644: LCOL_A002-Qtracker: 0004565: Cesion de Siniestro no descuenta reserva matematica
	51.0   02/10/2012   JGR       51. 0023864: LCOL_A003-Terminacion por convenios - descuadre entre rescate y recibo - 0124752
	52.0   17/12/2012   JMF       0025087 MDP_T001-Ajustes de PSU R2
	53.0   02/01/2013   APD       0023940: LCOL_T010-LCOL - Certificado 0 renovable - Renovaci?n colectivos
	54.0   14/01/2013   ECP       54. 0023644: LCOL_A002-Qtracker: 0004565: Cesion de Siniestro no descuenta reserva matematica
	55.0   26/04/2013   NSS       55. 0026472: LCOL_S001-SIN - Param. Acciones Vida Grupo (Id=6857-6861-6868-6871)
	56.0   13/05/2013   APD       56. 0026898: LCOL_T031-Fase 3 - Id 18 - Polizas proximas a renovar
	57.0   14/05/2013   ECP       57. 0026676: LCOL_T001- QT 7040: Error cierre de provisiones por c?digo de transacci?n en movimiento de anulaciones errado. Nota 144248
	58.0   28/05/2013   NSS       58. 0026962: LCOL_S010-SIN - Autos - Acciones iniciar/terminar siniestro
	59.0   01/08/2013   MMM       59. 0027750: LCOL_A003-Error en cargue de archivo de respuesta debito automatico (VISA) - QT-6189
	60.0   02/09/2013   FAL       60. 0025720: RSAG998 - Numeraci¿n de p¿lizas por rangos
	61.0   14/01/2014   JDS       61. 0029659: LCOL_T031-Migraci¿n autos
	62.0   19/02/2014   JDS       62. 0030256: LCOL999-Modificar modelo autos a?adiendo : CPESO, CTRANSMISION, NPUERTAS
	63.0   06/03/2014   NSS       63. 0029224: (POSAN500)-Analisis-Siniestros-Nuevos Desarrollos
	64.0   04/06/2014   JTT       64. 0029943: Tratamiento de PBs, se corrige gestion de fechas en F_alta_detalle_gar
	65.0   25/06/2014   AGG       65. 0029943: POSRA200 - Gaps 27,28 Anexos de PU en VI
	66.0   15/07/2014   AFM       66. 0032058: GAP. Prima de Riesgo, gastos y comisiones prepagables
	67.0   18/08/2014   MMS       67. 0031135: Montar Entorno Colmena en VAL
	68.0   25/09/2014   RDD       68. 0028974: MSV0003-Desarrollo de Comisiones (COM04-Commercial Network Management)
	69.0   06/05/2015   VCG       69. 0035288  INT033-Controlar longitud de observaciones al autorizar o rechazar una propuesta
	70.0   15/10/2015   BLA       70. 0033515/215632 MSV se  adicionan parametros pnnumvia, potros a la f_valdireccion
	71.0   16/10/2015   JCP       71. 0033886: Creacion funcion f_genera_archivo_cheque
	72.0   27/10/2014   YDA       72. 0033886: Creaci¿n de la funci¿n f_gen_rec_informe
	******************************************************************************/
	e_param_error EXCEPTION;
	FUNCTION f_cierre_ahorro(
			pmodo	IN	VARCHAR2,
			pfcierre	IN	DATE,
			pcidioma	IN	NUMBER,
			pcempres	IN	NUMBER,
			pcagrpro	IN	NUMBER,
			psproduc	IN	NUMBER,
			psseguro	IN	NUMBER,
			psproces	IN	NUMBER,
			indice	OUT	NUMBER,
			indice_error	OUT	NUMBER
	) RETURN NUMBER
	IS
	CURSOR c_cierre(

	    fcierre IN DATE) IS
	    SELECT seguros.sseguro,seguros.cramo,seguros.cmodali,seguros.ccolect,seguros.ctipseg,seguros.npoliza,seguros.iprianu,productos.cagrpro,seguros.fefecto,seguros.cforpag,productos.pinttec,seguros.fcaranu,seguros.fvencim,seguros.sproduc,seguros.cempres
	      FROM codiram,seguros,productos
	     WHERE (((pcagrpro IS NOT NULL) AND
	             (productos.cagrpro=pcagrpro))  OR
	            ((pcagrpro IS NULL) AND
	             (productos.cagrpro IN(2, 10, 11, 21)))) -- 12442.NMM.12/2009.Afegim l'11.
	           AND
	           productos.sproduc=seguros.sproduc AND
	           codiram.cempres=pcempres AND
	           codiram.cramo=seguros.cramo AND
	           productos.sproduc=nvl(psproduc, productos.sproduc) AND
	           seguros.sseguro=nvl(psseguro, seguros.sseguro) AND
	           f_situacion_v(seguros.sseguro, pfcierre)=1 AND
	           seguros.fefecto<pfcierre+1 AND
	           pac_propio.f_esta_retenica_sin_resc(seguros.sseguro, seguros.sproduc, pfcierre)=1
	     /* Bug 21808 - RSC - 04/05/2012*/
	     ORDER BY seguros.cramo,seguros.cmodali,seguros.npoliza;

	  reg         c_cierre%ROWTYPE;
	  contador    NUMBER;
	  algun_error NUMBER;
	  num_err     NUMBER:=0;
	  pnnumlin    NUMBER;
	  v_sysdate   DATE;
	  texto       VARCHAR2(400);
	  aux         NUMBER;
	  /* dra 21-1-09: bug mantis 8757*/
	  vpasexec    NUMBER:=0;
	  vtobjeto    VARCHAR2(500):='PAC_PROPIO.F_CIERRE_AHORRO';
	  v_cuenta    NUMBER;
	BEGIN
	    indice:=0;

	    indice_error:=0;

	    contador:=0;

	    vpasexec:=1;

	    /*-Seleccionamos los seguros vigentes----------------------*/
	    FOR reg IN c_cierre(pfcierre) LOOP
	        BEGIN
	            contador:=contador+1;

	            indice:=indice+1;

	            algun_error:=0;

	            vpasexec:=2;

	            /*v_numlin := f_numlin_next(reg.sseguro);*/
	            /* En el cierre s¿lo calcularemos el 'saldo', es decir, la nueva provisi¿n matem¿tica a final de mes*/
	            /* adem¿s, calcularemos las comisiones sobre provisi¿n. (Estas comisiones se grabar¿n en un recibo*/
	            /* de tipo 'I' (intereses).*/
	            /****** dE MOMENTO NO SE PODR¿ CERRAR DOS VECES una misma p¿liza******/
	            /*Si existen cierres anteriores en la misma fecha*/
	            /* no se procesa esta p¿liza y se da unmensaje de error------se borran*/
	            SELECT count(1)
	              INTO v_cuenta
	              FROM ctaseguro cta
	             WHERE cta.sseguro=reg.sseguro AND
	                   cta.cmovimi IN(0, 9, 21, 28,
	                                  29, 30) AND
	                   to_char(cta.fvalmov, 'yyyymmdd')=to_char(pfcierre, 'yyyymmdd');

	            /* BUG8757:DRA:23-01-2009*/
	            /* Si ya se ha hecho el cierre de esta p¿liza se devuelve error*/
	            IF v_cuenta<>0 THEN
	              ROLLBACK;

	              num_err:=151376;

	              texto:=f_axis_literales(num_err, pcidioma);

	              algun_error:=1;

	              indice_error:=indice_error+1;

	              pnnumlin:=NULL;

	              /*vpasexec := 4;*/
	              p_tab_error(f_sysdate, f_user, vtobjeto, vpasexec, 'Error: '
	                                                                 || num_err
	                                                                 || ' - seguro: '
	                                                                 || reg.sseguro
	                                                                 || '- fecha: '
	                                                                 || pfcierre
	                                                                 || ' modo: '
	                                                                 || pmodo
	                                                                 || ' sproces: '
	                                                                 || psproces
	                                                                 || ' v_cuenta: '
	                                                                 || v_cuenta, SQLCODE
	                                                                              || '-'
	                                                                              || SQLERRM);

	              num_err:=f_proceslin(psproces, texto
	                                             || '. Paso: '
	                                             || vpasexec, reg.sseguro, pnnumlin);
	            ELSE
	              num_err:=pac_ctaseguro.f_inscta_prov_cap(reg.sseguro, pfcierre, pmodo, psproces);

	              IF pac_ctaseguro.f_tiene_ctashadow(reg.sseguro, reg.sproduc)=1 THEN
	                num_err:=pac_ctaseguro.f_inscta_prov_cap_shw(reg.sseguro, pfcierre, pmodo, psproces);
	              END IF;

	              vpasexec:=3;

	              /* num_err := Pac_Ctaseguro.f_inscta_prov_cap (reg.sseguro,  to_date(to_char(pfcierre,'dd/mm/yyyy')||' 23:59:59','dd/mm/yyyy hh24:mi:ss'),  pmodo,  psproces);*/
	              IF num_err<>0 THEN
	                ROLLBACK;

	                texto:=f_axis_literales(num_err, pcidioma);

	                algun_error:=1;

	                indice_error:=indice_error+1;

	                pnnumlin:=NULL;

	                /*vpasexec := 4;*/
	                p_tab_error(f_sysdate, f_user, vtobjeto, vpasexec, 'Error: '
	                                                                   || num_err
	                                                                   || ' - seguro: '
	                                                                   || reg.sseguro
	                                                                   || '- fecha: '
	                                                                   || pfcierre
	                                                                   || ' modo: '
	                                                                   || pmodo
	                                                                   || ' sproces: '
	                                                                   || psproces, SQLCODE
	                                                                                || '-'
	                                                                                || SQLERRM);

	                num_err:=f_proceslin(psproces, texto
	                                               || '. Paso: '
	                                               || vpasexec, reg.sseguro, pnnumlin);
	              ELSIF algun_error=0 THEN
	                vpasexec:=5;

	              /**/
	              /* Si es un producto de planes o ULK y la comisi¿n es 0 no se genera recibo de comisi¿n*/
	                /**/
	                IF reg.cagrpro IN(11, 21) AND
	                   nvl(f_parproductos_v(reg.sproduc, 'PERIODICI_COMISION'), 0)=0 THEN -- Bug 20309 - RSC - 28/11/2011
	                  COMMIT;
	                ELSE
	                  vpasexec:=13;

	                  num_err:=f_graba_rec_comision(pmodo, pfcierre, reg.cagrpro, reg.sproduc, psseguro, reg.fefecto, reg.fcaranu);

	                  IF num_err<>0 THEN
	                    ROLLBACK;

	                    texto:=f_axis_literales(num_err, pcidioma);

	                    algun_error:=1;

	                    indice_error:=indice_error+1;

	                    pnnumlin:=NULL;

	                    p_tab_error(f_sysdate, f_user, vtobjeto, vpasexec, 'Error: '
	                                                                       || num_err
	                                                                       || ' - seguro: '
	                                                                       || psseguro
	                                                                       || '- fecha: '
	                                                                       || pfcierre
	                                                                       || ' modo: '
	                                                                       || pmodo
	                                                                       || ' sproces: '
	                                                                       || psproces, SQLCODE
	                                                                                    || '-'
	                                                                                    || SQLERRM);

	                    num_err:=f_proceslin(psproces, texto
	                                                   || '. Paso: '
	                                                   || vpasexec, psseguro, pnnumlin);
	                  ELSE
	                    COMMIT;
	                  END IF;
	                END IF;
	              END IF;
	            END IF;
	        EXCEPTION
	            WHEN OTHERS THEN
	              ROLLBACK;

	              texto:=f_axis_literales(102556, pcidioma);

	              algun_error:=1;

	              indice_error:=indice_error+1;

	              pnnumlin:=NULL;

	              /*vpasexec := 33;*/
	              p_tab_error(f_sysdate, f_user, vtobjeto, vpasexec, 'Error: '
	                                                                 || num_err
	                                                                 || ' - seguro: '
	                                                                 || reg.sseguro
	                                                                 || '- fecha: '
	                                                                 || pfcierre
	                                                                 || ' modo: '
	                                                                 || pmodo
	                                                                 || ' sproces: '
	                                                                 || psproces, SQLCODE
	                                                                              || '-'
	                                                                              || SQLERRM);

	              num_err:=f_proceslin(psproces, texto
	                                             || '. Paso: '
	                                             || vpasexec, reg.sseguro, pnnumlin);
	        END;
	    END LOOP;

	    RETURN 0;
	END f_cierre_ahorro;
	FUNCTION f_graba_rec_comision(
			pmodo	IN	VARCHAR2,
			pfecha	IN	DATE,
			pcagrpro	IN	NUMBER,
			psproduc	IN	NUMBER,
			psseguro	IN	NUMBER,
			pfefecto	IN	DATE DEFAULT NULL,
			pfcaranu	IN	DATE DEFAULT NULL
	) RETURN NUMBER
	IS
	  /**/
	  num_err    NUMBER;
	  xccomisi   NUMBER;
	  xcretenc   recibos.cretenc%TYPE;
	  wnmovimi   recibos.nmovimi%TYPE;
	  wnrecibo   recibos.nrecibo%TYPE;
	  aux        NUMBER;
	  wcdelega   recibos.cdelega%TYPE;
	  wsmovagr   movrecibo.nrecibo%TYPE;
	  wliqmen    NUMBER;
	  wliqlin    NUMBER;
	  /* Bug 20309 - RSC - 28/11/2011 - LCOL_T004-Parametrizaci¿n Fondos*/
	  v_q        NUMBER;
	  v_desde    DATE;
	  v_hasta    DATE;
	  /* Fin Bug 20309*/
	  igastosext NUMBER;
	  v_cmodcom  comisionprod.cmodcom%TYPE;
	  v_percomis NUMBER;
	  v_fefecto  DATE;
	  v_fcaranu  DATE;
	BEGIN
	    wnrecibo:=NULL;

	    v_percomis:=nvl(f_parproductos_v(psproduc, 'PERIODICI_COMISION'), 12);

	    /**/
	    IF pfefecto IS NULL THEN BEGIN
	          SELECT fefecto,fcaranu
	            INTO v_fefecto, v_fcaranu
	            FROM seguros
	           WHERE sseguro=psseguro;
	      EXCEPTION
	          WHEN no_data_found THEN
	            RETURN 101919; /* Error al leer datos de la tabla SEGUROS*/
	      END;
	    ELSE
	      v_fefecto:=pfefecto;

	      v_fcaranu:=pfcaranu;
	    END IF;

	    /* GRABAMOS LA COMISI¿N EN UN RECIBO DE TIPO COMISI¿N*/
	    IF pmodo='R' THEN
	    /* Bug 20309 - RSC - 28/11/2011 - LCOL_T004-Parametrizaci¿n Fondos*/
	    BEGIN
	          /* El -1 es por si el cierre lo hacen el d¿a 1.*/
	          SELECT q,add_months(dt, (q-1)*vtramo(NULL, 291, v_percomis)) desde,last_day(add_months(dt, (q-1)*vtramo(NULL, 291, v_percomis)+(vtramo(NULL, 291, v_percomis)-1))) hasta
	            INTO v_q, v_desde, v_hasta
	            FROM (SELECT to_date('31/12/'||(to_number(to_char(pfecha, 'YYYY')) - 1), 'dd/mm/yyyy')
	                         +1 dt,ROWNUM q
	                    FROM parproductos
	                   WHERE ROWNUM<=v_percomis)
	           WHERE last_day(pfecha-1)=last_day(add_months(dt, (q-1)*vtramo(NULL, 291, v_percomis)+(vtramo(NULL, 291, v_percomis)-1)));

	          /* Primero mirar si se ha grabado importe mayor que 0 en el registro de saldo*/
	          igastosext:=f_igasext_ult_act(psseguro, pfecha);

	          /* BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda*/
	          IF f_round(igastosext, pac_monedas.f_moneda_producto(psproduc))>=0.01 THEN
	            /* Bug 19777/95194 - 26/10/2011 -AMC*/
	            IF f_es_renovacion(psseguro)=0 THEN /* es cartera*/
	              v_cmodcom:=2;
	            ELSE /* si es 1 es nueva produccion*/
	              v_cmodcom:=1;
	            END IF;

	          /*Miramos si el agente tiene comision para grabar el recibo*/
	          /* Bug 20153 - APD - 24/11/2011 - se informa el parametro pfecha la fecha*/
	            /* efecto de la poliza*/
	            num_err:=f_pcomisi(psseguro, v_cmodcom, pfecha, xccomisi, xcretenc, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'CAR', v_fefecto);

	          /* fin Bug 20153 - APD - 24/11/2011*/
	            /*Fi Bug 19777/95194 - 26/10/2011 -AMC*/
	            IF num_err<>0 THEN
	              RETURN num_err;
	            END IF;

	            /* BUG 13933- 03/2010 - JRH  - Ha de enerar la comisi¿n si exsite*/
	            IF ((nvl(f_parproductos_v(psproduc, 'COMISION_AHORRO'), 0)=1 AND
	                 xccomisi<>0)  OR
	                (nvl(f_parproductos_v(psproduc, 'COMISION_AHORRO'), 0)=0)) THEN
	              /* Se graba el recibo*/
	              num_err:=f_buscanmovimi(psseguro, 1, 1, wnmovimi);

	              num_err:=f_insrecibo(psseguro, NULL, pfecha, pfecha, pfecha+1, 5, NULL, NULL, NULL, 0, NULL, wnrecibo, 'R', NULL, NULL, wnmovimi, f_sysdate);

	              IF num_err<>0 THEN
	                RETURN num_err;
	              END IF;

	              num_err:=f_detrecibo(NULL, psseguro, wnrecibo, NULL, 'I', v_cmodcom, f_sysdate, pfecha, pfecha+1, v_fcaranu, igastosext, NULL, wnmovimi, 1, aux);

	              IF num_err<>0 THEN
	                RETURN num_err;
	              END IF;

	              BEGIN
	                  SELECT cdelega
	                    INTO wcdelega
	                    FROM recibos
	                   WHERE nrecibo=wnrecibo;
	              EXCEPTION
	                  WHEN OTHERS THEN
	                    wcdelega:=NULL;
	              END;

	              wsmovagr:=0;

	            /* 5644 jdomingo 6/6/2008*/
	            /* el ctiprec del rebut ¿s 5 (ho hem passat com par¿metre a f_insrecibo),*/
	              /* aix¿ que posem el ctipcob=0*/
	              num_err:=f_movrecibo(wnrecibo, 1, NULL, NULL, wsmovagr, wliqmen, wliqlin, f_sysdate, NULL, wcdelega, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0);

	              IF num_err<>0 THEN
	                RETURN num_err;
	              END IF;
	            END IF;
	          END IF;
	      EXCEPTION
	          WHEN no_data_found THEN
	            NULL;
	      END;
	    END IF;

	    /**/
	    RETURN num_err;
	/**/
	END f_graba_rec_comision;
	FUNCTION f_permite_alta_siniestro(
			psseguro	IN	NUMBER,
			pnriesgo	IN	NUMBER,
			pfsinies	IN	DATE,
			pfnotifi	IN	DATE
	) RETURN NUMBER
	IS
	  v_resp        NUMBER;
	  vfefecto      seguros.fefecto%TYPE;
	  vfvencim      seguros.fvencim%TYPE;
	  vfcaranu      seguros.fcaranu%TYPE;
	  vfcarpro      seguros.fcarpro%TYPE;
	  vcsituac      seguros.csituac%TYPE;
	  vfanulac      seguros.fanulac%TYPE;
	  vsproduc      seguros.sproduc%TYPE;
	  v_fsuspens    suspensionseg.finicio%TYPE;
	  vcount        NUMBER;
	  vsseguro      NUMBER;
	  v_fsinies_val NUMBER;
	BEGIN
	    SELECT fefecto,fvencim,csituac,fanulac,sproduc,fcaranu,fcarpro
	      INTO vfefecto, vfvencim, vcsituac, vfanulac,
	    vsproduc, vfcaranu, vfcarpro
	      FROM seguros
	     WHERE sseguro=psseguro;

	    v_fsinies_val:=pac_parametros.f_parproducto_n(vsproduc, 'FSINIES_VALIDA');

	    IF v_fsinies_val=1 THEN
	      IF trunc(pfsinies)>trunc(vfcaranu) THEN
	        RETURN 9906339;
	      END IF;
	    ELSIF v_fsinies_val=2 THEN
	      IF trunc(pfsinies)>trunc(vfcaranu)  OR
	         trunc(pfsinies)>trunc(vfcarpro) THEN
	        RETURN 9906340;
	      END IF;
	    END IF;

	    IF (trunc(pfsinies)>trunc(pfnotifi)) THEN
	      RETURN 109923;
	    /*La fecha de siniestro no puede ser posterior que la fecha de notificaci¿n.*/
	    ELSIF(trunc(pfnotifi)>trunc(f_sysdate)) THEN
	      RETURN 109924;
	    /*La fecha de notificaci¿n no puede ser posterior que la fecha de entrada.*/
	    ELSIF(trunc(pfsinies)<trunc(vfefecto)) THEN
	      RETURN 109925;
	    /*La fecha del siniestro no puede ser anterior a la fecha de efecto de la p¿liza.*/
	    ELSIF(trunc(pfsinies)>trunc(vfvencim
	                                +nvl(f_parproductos_v(vsproduc, 'DIASANUL'), 0))) THEN
	      RETURN 110490;
	    /*La fecha del siniestro no puede ser posterior a la fecha de vencimiento de la p¿liza.*/
	    END IF;

	    /* BUG 0024450/0129646 - FAL - 15/11/2012*/
	    IF f_parproductos_v(vsproduc, 'PERMITE_SUSPENSION')=1 THEN
	    /* BEGIN
	        SELECT finicio
	          INTO v_fsuspens
	          FROM suspensionseg
	         WHERE sseguro = psseguro
	           AND ffinal IS NULL
	           AND cmotmov = 391
	           AND   -- suspension
	              nmovimi = (SELECT MAX(nmovimi)
	                           FROM suspensionseg
	                          WHERE sseguro = psseguro
	                            AND cmotmov = 391);
	     EXCEPTION
	        WHEN NO_DATA_FOUND THEN
	           v_fsuspens := NULL;
	     END;

	     IF v_fsuspens IS NOT NULL THEN   -- existe una suspension vigente
	        IF TRUNC(pfsinies) > v_fsuspens THEN
	           RETURN 9904537;   -- Siniestro no permitido. P¿liza suspendida en la fecha de ocurrencia del siniestro
	        END IF;
	     END IF;*/
       -- CONF-274-25/11/2016-JLTS- Ini
       IF vcount>0 THEN
            IF nvl(f_parproductos_v(vsproduc, 'SINI_ESTAD_SUSP'), 0)=0
            THEN
              RETURN 9904537;
            END IF;
	        /* Siniestro no permitido. P¿liza suspendida en la fecha de ocurrencia del siniestro*/
       END IF;
       -- CONF-274-25/11/2016-JLTS- Ini
	      /* Bug 28224/153119 - 19/09/2013 - AMC*/
	      SELECT count(1)
	        INTO vcount
	        FROM suspensionseg
	       WHERE sseguro=psseguro AND
	             cmotmov=391 AND
	             ((pfsinies>=finicio AND
	               pfsinies<ffinal)  OR
	              (pfsinies>=finicio AND
	               ffinal IS NULL));

	      IF vcount>0 THEN
	        RETURN 9904537;
	      /* Siniestro no permitido. P¿liza suspendida en la fecha de ocurrencia del siniestro*/
	      END IF;

	    /*Ini Bug 28224/0156851:NSS:31/10/2013*/
	      /*Cuando la p¿liza es un certificado, se ha de mirar si est¿ suspendida (como est¿ haciendo ahora) pero si no lo est¿,
	        adem¿s tenemos que mirar si est¿ suspendido el certificado 0*/
	      BEGIN
	          SELECT s2.sseguro
	            INTO vsseguro
	            FROM seguros s1,seguros s2
	           WHERE s1.npoliza=s2.npoliza AND
	                 s1.sseguro=psseguro AND
	                 s1.sseguro<>s2.sseguro AND
	                 s2.ncertif=0;
	      EXCEPTION
	          WHEN no_data_found THEN
	            NULL;
	      END;

	      IF vsseguro IS NOT NULL THEN
	        SELECT count(1)
	          INTO vcount
	          FROM suspensionseg
	         WHERE sseguro=vsseguro AND
	               cmotmov=391 AND
	               ((pfsinies>=finicio AND
	                 pfsinies<ffinal)  OR
	                (pfsinies>=finicio AND
	                 ffinal IS NULL));

	        IF vcount>0 THEN
	          RETURN 9904537;
	        /* Siniestro no permitido. P¿liza suspendida en la fecha de ocurrencia del siniestro*/
	        END IF;
	      END IF;
	    /*Fin Bug 28224/0156851:NSS:31/10/2013*/
	    /* Fi Bug 28224/153119 - 19/09/2013 - AMC*/
	    END IF;

	    /* FI BUG 0024450/0129646*/
	    v_resp:=f_vigente(psseguro, NULL, pfsinies);

	    IF v_resp<>0 AND
	       trunc(vfanulac)<>trunc(pfsinies) THEN
	      /* no est¿ vigente en la fecha del siniestro*/
	      RETURN 111012;
	    END IF;

	    /*INI BUG:25562/176061:NSS:28/05/2014 permitir crear siniestro si la poliza esta en propuesta de suplemento*/
	    /*
	    IF vcsituac = 5 THEN
	       -- si est¿ en propuesta de suplemento tampoco dejamos
	       RETURN 101481;
	    END IF;
	    */
	    /*FIN BUG:25562/176061:NSS:28/05/2014 permitir crear siniestro si la poliza esta en propuesta de suplemento*/
	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_sin.f_permite_alta_siniestro', 1, 'error no controlat', SQLERRM);

	             RETURN 140999;
	END f_permite_alta_siniestro;
	FUNCTION f_aceptar_propuesta(
			psseguro	IN	NUMBER,
			pnmovimi	IN	NUMBER,
			pnriesgo	IN	NUMBER,
			pfecha	IN	DATE DEFAULT NULL,
			ptobserv	IN	VARCHAR2 DEFAULT NULL
	) RETURN NUMBER
	IS
	  /**/
	  CURSOR c_riesgos IS
	    SELECT nriesgo
	      FROM riesgos
	     WHERE sseguro=psseguro AND
	           fanulac IS NULL;

	  v_fefecto      seguros.fefecto%TYPE;
	  /* v_tobser       VARCHAR2(300);  -- BUG9297:DRA:03-03-2009*/
	  num_err        NUMBER;
	  v_sperson_risc riesgos.sperson%TYPE;
	  vsproduc       seguros.sproduc%TYPE;
	  vparampsu      NUMBER;
	  /* BUG23911:DRA:19/10/2012:Inici*/
	  v_cempres      seguros.cempres%TYPE;
	  v_ss           VARCHAR2(4000);
	  /* BUG 0035288-0203030 - 06/05/2015-VCG- Aumentar la variable 4000 posiciones*/
	  v_cursor       NUMBER;
	  v_filas        NUMBER;
	  v_propio       VARCHAR2(50);
	  v_retorno      NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	  vpasexec       NUMBER:=0;
	  /* BUG23911:DRA:19/10/2012:Fi*/
	  /* Se debe declarar el componente*/
	  vfefectoant    DATE; /* BUG 0035409 - FAL - 14/04/2015*/
	BEGIN
	    vpasexec:=1;

	    /* BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda*/
	    SELECT cempres,sproduc
	      INTO v_cempres, vsproduc
	      FROM seguros
	     WHERE sseguro=psseguro;

	    /* BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda*/
	    vpasexec:=2;

	    /* BUG23911:DRA:19/10/2012:Inici*/
	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    vpasexec:=3;

	    v_ss:='BEGIN '
	          || ' :RETORNO := '
	          || v_propio
	          || '.'
	          || 'f_aceptar_propuesta('
	          || psseguro
	          || ','
	          || pnmovimi
	          || ','
	          || pnriesgo
	          || ',TO_DATE('''
	          || to_char(pfecha, 'DD/MM/YYYY')
	          || ''', ''DD/MM/YYYY''),'''
	          || ptobserv
	          || ''')'
	          || ';'
	          || 'END;';

	    vpasexec:=4;

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    vpasexec:=5;

	    v_cursor:=dbms_sql.open_cursor;

	    vpasexec:=6;

	    dbms_sql.parse(v_cursor, v_ss, dbms_sql.native);

	    vpasexec:=7;

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', v_retorno);

	    vpasexec:=8;

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    vpasexec:=9;

	    dbms_sql.variable_value(v_cursor, 'RETORNO', v_retorno);

	    vpasexec:=10;

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN v_retorno;
	/* BUG23911:DRA:19/10/2012:Fi*/
	EXCEPTION
	  WHEN ex_nodeclared THEN
	           /*  Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada*/
	             /*  a una funci¿n, procedimiento, etc. inexistente o no declarado.*/
	             vpasexec:=11;

	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             /* Si la funci¿n no existe para la empresa, ejecutamos la f_aceptar_propuesta gen¿rica*/
	             BEGIN
	             /* primero modificamos la fecha de efecto de la p¿liza (siempre el d¿a 1 del mes siguiente*/
	                 /* a la aceptaci¿n de la propuesta)*/
	                 vpasexec:=12;

	                 /* BUG 0035409 - FAL - 14/04/2015*/
	                 SELECT fefecto
	                   INTO vfefectoant
	                   FROM movseguro
	                  WHERE sseguro=psseguro
	                        /*cmovseg!= 52*/
	                        AND
	                        nmovimi=pnmovimi;

	                 /* FI BUG 0035409*/
	                 IF pfecha IS NOT NULL THEN
	                   v_fefecto:=pfecha;
	                 ELSE
	                   v_fefecto:=last_day(trunc(f_sysdate))+1;
	                 /*to_date('01'||to_char(add_months(f_sysdate,1), 'mmyyyy'), 'ddmmyyyy');*/
	                 /*v_fefecto := add_months(last_day(trunc(f_sysdate)) + 1,-1); --to_date('01'||to_char(add_months(f_sysdate,1), 'mmyyyy'), 'ddmmyyyy');*/
	                 END IF;

	                 vpasexec:=13;

	                 IF v_fefecto<>vfefectoant THEN
	                   /* BUG 0035409 - FAL - 14/04/2015 - Evita retarifar si efecto no ha cambiado*/
	                   pk_nueva_produccion.p_modificar_fefecto_seg(psseguro, v_fefecto, pnmovimi, 'SEG');

	                   vpasexec:=14;

	                   /* retarifamos la propuesta*/
	                   FOR reg IN c_riesgos LOOP
	                       num_err:=pac_tarifas.f_tarifar_riesgo_tot (NULL, psseguro, reg.nriesgo, pnmovimi,
	                                /* BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda*/
	                                /*1,*/
	                                pac_monedas.f_moneda_producto(vsproduc),
	                                /* BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda*/
	                                v_fefecto);

	                       IF num_err<>0 THEN
	                         RETURN num_err;
	                       END IF;
	                   END LOOP;
	                 END IF;

	                 vpasexec:=15;

	                 UPDATE seguros
	                    SET iprianu=f_segprima(psseguro, v_fefecto),cagente=cagente
	                  /* para que se dispare el trigguer SEGUREDCOM y actualice la tabla*/
	                  WHERE sseguro=psseguro;

	                 vpasexec:=16;

	                 vparampsu:=pac_parametros.f_parproducto_n(vsproduc, 'PSU');

	                 IF nvl(vparampsu, 0)=0 THEN
	                   vpasexec:=17;

	                 /* desretenmos la propuesta*/
	                   /* BUG9297:DRA:03-03-2009*/
	                   num_err:=pac_motretencion.f_desretener(psseguro, pnmovimi, ptobserv);

	                   /* BUG9423:DRA:03/04/2009*/
	                   IF num_err<>0 THEN
	                     RETURN num_err;
	                   END IF;
	                 ELSIF nvl(vparampsu, 0)=1 THEN
	                   vpasexec:=18;

	                   UPDATE seguros
	                      SET creteni=0
	                    WHERE sseguro=psseguro;
	                 END IF;

	                 vpasexec:=19;

	                 /* hacemos un apunte en la agenda*/
	                 BEGIN
	                     SELECT sperson
	                       INTO v_sperson_risc
	                       FROM riesgos
	                      WHERE sseguro=psseguro AND
	                            nriesgo=pnriesgo;
	                 EXCEPTION
	                     WHEN OTHERS THEN
	                       v_sperson_risc:=NULL;
	                 END;

	                 vpasexec:=20;

	                 /*BUG9208-28052009-XVM*/
	                 num_err:=pac_agensegu.f_set_datosapunte(NULL, psseguro, NULL, f_axis_literales(9908190, pac_md_common.f_get_cxtidioma), f_axis_literales(9908191, pac_md_common.f_get_cxtidioma), 5, 1, trunc(f_sysdate), trunc(f_sysdate), 0, 0);

	                 IF num_err<>0 THEN
	                   RETURN num_err;
	                 END IF;

	                 RETURN 0;
	             EXCEPTION
	                 WHEN OTHERS THEN
	                   p_tab_error(f_sysdate, f_user, 'pk_gestion_retenidas.f_aceptar_propuesta', vpasexec, 'error no controlat', SQLERRM);

	                   RETURN 140999;
	             END; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pk_gestion_retenidas.f_aceptar_propuesta', vpasexec, 'error no controlat', SQLERRM);

	             RETURN 140999;
	END f_aceptar_propuesta;
	FUNCTION f_rechazar_propuesta(
			psseguro	IN	NUMBER,
			pnmovimi	IN	NUMBER,
			pnriesgo	IN	NUMBER,
			pcmotmov	IN	NUMBER,
			pnsuplem	IN	NUMBER,
			ptobserv	IN	VARCHAR2
	) RETURN NUMBER
	IS
	  num_err        NUMBER;
	  v_sperson_risc riesgos.sperson%TYPE;
	BEGIN
	    num_err:=pk_rechazo_movimiento.f_rechazo(psseguro, pcmotmov, pnsuplem, 3, ptobserv);

	    IF num_err<>0 THEN
	      RETURN num_err;
	    END IF;

	    /* hacemos un apunte en la agenda*/
	    BEGIN
	        SELECT sperson
	          INTO v_sperson_risc
	          FROM riesgos
	         WHERE sseguro=psseguro AND
	               nriesgo=pnriesgo;
	    EXCEPTION
	        WHEN OTHERS THEN
	          v_sperson_risc:=NULL;
	    END;

	    /*BUG9208-28052009-XVM*/
	    num_err:=pac_agensegu.f_set_datosapunte(NULL, psseguro, NULL, 'RECHAZO PROPUESTA', 'Se rechaza la propuesta de alta. Observaciones: '
	                                                                                       || ptobserv, 5, 1, trunc(f_sysdate), trunc(f_sysdate), 0, 0);

	    IF num_err<>0 THEN
	      RETURN num_err;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pk_gestion_retenidas.f_rechazar', 1, 'error no controlat', SQLERRM);

	             RETURN 140999;
	END f_rechazar_propuesta;
	FUNCTION f_cambio_fcancel(
			psseguro	IN	NUMBER,
			pnmovimi	IN	NUMBER,
			pfcancel_nou	IN	DATE
	) RETURN NUMBER
	IS
	  num_err NUMBER;
	BEGIN
	    BEGIN
	        UPDATE seguros
	           SET fcancel=pfcancel_nou
	         WHERE sseguro=psseguro;
	    EXCEPTION
	        WHEN OTHERS THEN
	          RETURN 102361;
	    END;

	    /*BUG9208-28052009-XVM*/
	    num_err:=pac_agensegu.f_set_datosapunte(NULL, psseguro, NULL, 'CAMBIO F. CANCEL', 'NUEVA FECHA CANCELACI¿N: '
	                                                                                      || to_char(pfcancel_nou, 'dd/mm/yyyy'), 5, 1, trunc(f_sysdate), trunc(f_sysdate), 0, 0);

	    IF num_err<>0 THEN
	      RETURN num_err;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pk_gestion_retenidas.f_cambio_fcancel', 1, 'error no controlat', SQLERRM);

	             RETURN 140999;
	END f_cambio_fcancel;
	FUNCTION f_cambio_sobreprima(
			psseguro	IN	NUMBER,
			pnmovimi	IN	NUMBER,
			pnriesgo	IN	NUMBER
	) RETURN NUMBER
	IS
	  num_err        NUMBER;
	  hay_sobrepr    NUMBER;
	  v_sperson_risc riesgos.sperson%TYPE;
	BEGIN
	    SELECT count(*)
	      INTO hay_sobrepr
	      FROM garanseg
	     WHERE sseguro=psseguro AND
	           nmovimi=pnmovimi AND
	           (precarg IS NOT NULL  OR
	            precarg<>0);

	    IF hay_sobrepr>0 THEN
	    /* hacemos un apunte en la agenda*/
	    BEGIN
	          SELECT sperson
	            INTO v_sperson_risc
	            FROM riesgos
	           WHERE sseguro=psseguro AND
	                 nriesgo=pnriesgo;
	      EXCEPTION
	          WHEN OTHERS THEN
	            v_sperson_risc:=NULL;
	      END;

	    /* ha cambiado la sobreprima y hacemos un apunte en la agenda*/
	    /*BUG9208-28052009-XVM*/
	    num_err := pac_agensegu.f_set_datosapunte(NULL, psseguro, NULL, 'CAMBIO SOBREPRIMA', 'Se aplica sobreprima', 5, 1, trunc(f_sysdate), trunc(f_sysdate), 0, 0); IF num_err <> 0 THEN RETURN num_err; END IF;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pk_gestion_retenidas.f_cambio_sobreprima', 1, 'error no controlat', SQLERRM);

	             RETURN 140999;
	END f_cambio_sobreprima;
	FUNCTION f_cambio_clausulas(
			psseguro	IN	NUMBER,
			pnmovimi	IN	NUMBER,
			pnriesgo	IN	NUMBER
	) RETURN NUMBER
	IS
	  num_err        NUMBER;
	  hay_clausulas  NUMBER;
	  v_sperson_risc riesgos.sperson%TYPE;
	BEGIN
	    SELECT count(*)
	      INTO hay_clausulas
	      FROM clausuesp
	     WHERE sseguro=psseguro AND
	           nmovimi=pnmovimi AND
	           cclaesp=2 AND
	           ffinclau IS NULL;

	    IF hay_clausulas>0 THEN
	    /* hacemos un apunte en la agenda*/
	    BEGIN
	          SELECT sperson
	            INTO v_sperson_risc
	            FROM riesgos
	           WHERE sseguro=psseguro AND
	                 nriesgo=pnriesgo;
	      EXCEPTION
	          WHEN OTHERS THEN
	            v_sperson_risc:=NULL;
	      END;

	    /* ha cambiado la sobreprima y hacemos un apunte en la agenda*/
	    /*BUG9208-28052009-XVM*/
	    num_err := pac_agensegu.f_set_datosapunte(NULL, psseguro, NULL, 'CAMBIO CLAUSULA', 'Se a¿aden cl¿usulas', 5, 1, trunc(f_sysdate), trunc(f_sysdate), 0, 0); IF num_err <> 0 THEN RETURN num_err; END IF;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pk_gestion_retenidas.f_cambio_clausulas', 1, 'error no controlat', SQLERRM);

	             RETURN 140999;
	END f_cambio_clausulas;
	FUNCTION f_provmat(
			psesion	IN	NUMBER,
			psseguro NUMBER,
			pfecha NUMBER,
			pmodo	IN	NUMBER
	) RETURN NUMBER
	IS
	/*******************************************************************************
	  CPM 29/9/2004
	  Funci¿ per l'SGT que crida al c¿lcul provmat propi de cada instal¿laci¿.
	  Per evitar aquesta funci¿, es podria cridar a la funci¿ directament des de
	  l'SGT, per¿ es tindria que fer el camp 'termino' de la taula SGT_TERM_FORM
	  m¿s gran.
	*******************************************************************************/
	BEGIN
	    RETURN pac_provi_mv.f_calculos_provmat(pmodo, psseguro, to_date(pfecha, 'yyyymmdd'));
	END f_provmat;

	/*
	   FUNCTION f_irescate(psseguro IN NUMBER, pfecha IN DATE)
	      RETURN NUMBER
	   IS

	      --  { funci¿n que retorna el importe de la provisi¿n matematica
	      --   menos el importe de los recibos de gesti¿n
	      --  }
	      xireserva   NUMBER;
	      xigestion   NUMBER;
	   BEGIN
	      --{calculem la reserva en aquest moment}
	      xireserva := pac_provi_mv.f_calculos_provmat (0, psseguro, pfecha);

	      --{restem el import dels rebuts que est¿n en gesti¿ }
	      SELECT NVL (SUM (itotalr), 0)
	        INTO xigestion
	        FROM vdetrecibos v, recibos r
	       WHERE r.sseguro = psseguro
	         AND r.nrecibo = v.nrecibo
	         AND f_cestrec_mv (r.nrecibo, 1) = 3;

	      RETURN NVL (xireserva, 0) - xigestion;
	   EXCEPTION
	      WHEN OTHERS
	      THEN
	         RETURN 0;
	   END f_irescate;
	*/
	FUNCTION f_permite_alta_siniestro(
			psseguro	IN	NUMBER,
	pnriesgo	IN	NUMBER,
	pfsinies	IN	DATE,
	pfnotifi	IN	DATE,
	pccausin	IN	NUMBER,
	pcmotsin	IN	NUMBER,
			 /* Ini Bug 26676 -- ECP -- 14/05/2013*/
			 pskipfanulac NUMBER DEFAULT 0
			/* Fin Bug 26676 -- ECP -- 14/05/2013*/

	)
	RETURN NUMBER
	IS
	  v_resp          NUMBER;
	  vfefecto        seguros.fefecto%TYPE;
	  vfvencim        seguros.fvencim%TYPE;
	  vcsituac        seguros.csituac%TYPE;
	  vfanulac        seguros.fanulac%TYPE;
	  v_num_reg       NUMBER;
	  v_sproduc       seguros.sproduc%TYPE;
	  vcreteni        seguros.creteni%TYPE;
	  v_error_rescate NUMBER; /* Bug 16095 - APD - 04/11/2010*/
	BEGIN
	/* Primero se valida que la p¿liza permite dar de alta un siniestro*/
	/* Despu¿s se valida si se permite dar de alta un siniestro en concreto*/
	/*----------------------------------*/
	/* Validaciones a nivel de p¿liza*/
	    /*----------------------------------*/
	    SELECT fefecto,fvencim,csituac,fanulac,sproduc,creteni
	      INTO vfefecto, vfvencim, vcsituac, vfanulac,
	    v_sproduc, vcreteni
	      FROM seguros
	     WHERE sseguro=psseguro;

	    /* Si la p¿liza est¿ bloqueada o pignorada no se permite la apertura de un siniestro o rescate.*/
	    IF f_bloquea_pignorada(psseguro, f_sysdate)<>0 THEN
	      RETURN 180471;
	    /* P¿liza bloqueada. Consulte con la C¿a. Aseguradora.*/
	    END IF;

	    IF vcsituac=5 THEN
	      /* si est¿ en propuesta de suplemento tampoco dejamos*/
	      RETURN 101481;
	    END IF;

	    IF vcreteni=1 THEN
	      /* P¿liza retenida. Consulte con la C¿a. Aseguradora.*/
	      RETURN 180530;
	    END IF;

	    /* Bug 16095 - 04/11/2010 - APD - No se puede hacer un rescate antes de los 60 a¿os*/
	    v_error_rescate:=pac_propio.f_permite_edad_rescate(psseguro, pnriesgo, pfsinies, pccausin);

	    IF v_error_rescate<>0 THEN
	      RETURN v_error_rescate;
	    END IF;

	    /* Fin Bug 16095 - 04/11/2010 - APD*/
	    /*------------------------------------*/
	    /* Validaciones a nivel de siniestro*/
	    /*------------------------------------*/
	    IF pfsinies IS NOT NULL THEN
	    /* Si pfsinies is not null se entiende que el resto de par¿metros de entrada tambi¿n son Not Null y*/
	    /* por lo tanto se quiere hacer la validaci¿n a nivel de siniestro*/
	    /* Si pfsinies is null (y por lo tanto el resto de par¿metros de entrada tambi¿n, excepto el psseguro),*/
	    /* se entiende que s¿lo se quiere hacer la validaci¿n a nivel de p¿liza*/
	      /* Se debe validar que si s¿lo hay un asegurado vigente, no se seleccione el motivo de siniestro 4. Baja 1 asegurado)*/
	      IF pccausin=1 AND
	         pcmotsin=4 THEN
	        SELECT count(1)
	          INTO v_num_reg
	          FROM asegurados
	         WHERE sseguro=psseguro AND
	               ffecfin IS NULL
	         /* El Asegurado debe estar vigente (si ffecfin is not null, entonces asegurado fallecido)*/
	         ORDER BY norden;

	        IF v_num_reg=1 THEN
	          RETURN 180515; /*Se debe seleccionar otro motivo de siniestro.*/
	        END IF;
	      END IF;

	      /* Validar que el Asegurado debe estar vigente a fecha del siniestro (si ffecfin is not null, entonces asegurado fallecido)*/
	      IF nvl(f_parproductos_v(v_sproduc, '2_CABEZAS'), 0)=1 THEN
	        SELECT count(1)
	          INTO v_num_reg
	          FROM asegurados
	         WHERE sseguro=psseguro AND
	               norden=pnriesgo AND
	               ffecfin IS NOT NULL;

	        IF nvl(v_num_reg, 0)<>0 THEN
	          RETURN 180838;
	        /* Asegurado no vigente a la fecha del siniestro (Antes: Persona fallecida)*/
	        END IF;
	      ELSE
	        SELECT count(1)
	          INTO v_num_reg
	          FROM riesgos
	         WHERE sseguro=psseguro AND
	               nriesgo=pnriesgo AND
	               fanulac<pfsinies;

	        IF nvl(v_num_reg, 0)<>0 THEN
	          RETURN 151381; /* Persona no operativa*/
	        END IF;
	      END IF;

	      IF pccausin NOT IN(3, 4, 5) THEN /* rescates y vencimientos*/
	        IF (trunc(pfsinies)>trunc(pfnotifi)) THEN
	          RETURN 109923;
	        /*La fecha de siniestro no puede ser posterior que la fecha de notificaci¿n.*/
	        ELSIF(trunc(pfnotifi)>trunc(f_sysdate)) THEN
	          RETURN 109924;
	        /*La fecha de notificaci¿n no puede ser posterior que la fecha de entrada.*/
	        ELSIF(trunc(pfsinies)<trunc(vfefecto)) THEN
	          RETURN 109925;
	        /*La fecha del siniestro no puede ser anterior a la fecha de efecto de la p¿liza.*/
	        ELSIF(trunc(pfsinies)>trunc(vfvencim)) THEN
	          RETURN 110490;
	        /*La fecha del siniestro no puede ser posterior a la fecha de vencimiento de la p¿liza.*/
	        END IF;
	      END IF;

	      /* Ini Bug 26676 -- ECP -- 14/05/2013*/
	      IF pskipfanulac=0 THEN
	        /* Fin  Bug 26676 -- ECP -- 14/05/2013*/
	        v_resp:=f_vigente(psseguro, NULL, pfsinies);

	        IF v_resp<>0 AND
	           vfanulac<>pfsinies THEN
	          /* no est¿ vigente en la fecha del siniestro*/
	          RETURN 111012;
	        END IF;
	      END IF;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, getuser, 'pac_propio.f_permite_alta_siniestro', 1, 'error no controlat', SQLERRM);

	             RETURN 140999;
	END f_permite_alta_siniestro;
	FUNCTION f_texto_libre_siniestros(
			pnsinies	IN	NUMBER,
			pnlitera	OUT	NUMBER
	) RETURN NUMBER
	IS
	  v_sseguro siniestros.sseguro%TYPE;
	  num_err   NUMBER;
	  v_resul   NUMBER:=0;
	BEGIN
	/* si tiene  Beneficiario irrevocable daremos este mensaje*/
	/* BUG 11595 - 06/11/2009 - APD - Adaptaci¿n al nuevo m¿dulo de siniestros*/
	/* Para este caso, en vez de buscar por el parempresa 'MODULO_SINI' para saber si se*/
	/* est¿ en el m¿dulo antiguo o nuevo de siniestros (ya que se necesita la empresa del*/
	/* seguro para buscar el valor del parempresa) se parte de que por defecto se est¿*/
	    /* en el modelo nuevo, y si no hay datos se busca en el modelo antiguo.*/
	    BEGIN
	        SELECT sseguro
	          INTO v_sseguro
	          FROM sin_siniestro
	         WHERE nsinies=pnsinies;
	    EXCEPTION
	        WHEN no_data_found THEN BEGIN
	              SELECT sseguro
	                INTO v_sseguro
	                FROM siniestros
	               WHERE nsinies=pnsinies;
	          EXCEPTION
	              WHEN OTHERS THEN
	                RETURN NULL;
	          END;
	        WHEN OTHERS THEN
	          RETURN NULL;
	    END;

	    /* Fin BUG 11595 - 02/11/2009 - APD - Adaptaci¿n al nuevo m¿dulo de siniestros*/
	    num_err:=f_es_vinculada(v_sseguro);

	    IF num_err=1 THEN
	      pnlitera:=152120; /* Tiene beneficiario irrevocable*/
	    ELSE
	      pnlitera:=NULL;
	    END IF;

	    IF pnlitera IS NULL THEN
	    /*Comprobamos si tiene alguna cl¿usula especial*/
	    BEGIN
	          SELECT count(*)
	            INTO v_resul
	            FROM clausuesp
	           WHERE sseguro=v_sseguro;

	          IF v_resul>0 THEN
	            pnlitera:=9002180; /*P¿liza con cl¿usulas especiales*/
	          END IF;
	      EXCEPTION
	          WHEN no_data_found THEN
	            pnlitera:=NULL;
	      END;
	    END IF;

	    RETURN 0;
	END f_texto_libre_siniestros;
	FUNCTION f_post_rehabilitacion(
			psseguro	IN	NUMBER
	) RETURN NUMBER
	IS
	  v_cempres empresas.cempres%TYPE;
	  v_propio  VARCHAR2(50);
	  v_cursor  NUMBER;
	  ss        VARCHAR2(3000);
	  retorno   NUMBER;
	  v_filas   NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	BEGIN
	    SELECT cempres
	      INTO v_cempres
	      FROM seguros
	     WHERE sseguro=psseguro;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'f_post_rehabilitacion('
	        || psseguro
	        || ');'
	        || ' '
	        || 'END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF; WHEN OTHERS THEN
	             RETURN 9907089;
	END f_post_rehabilitacion;
	FUNCTION f_post_anulacion(
			psseguro	IN	NUMBER,
			pfanulac	IN	DATE,
			pnmovimi	IN	NUMBER
	) RETURN NUMBER
	IS
	  v_fefepol       seguros.fefecto%TYPE;
	  num_err         NUMBER;
	  v_sproduc       seguros.sproduc%TYPE;
	  v_cactivi       seguros.cactivi%TYPE;
	  v_nnumpag       productos.nnumpag%TYPE;
	  v_cbancar       seguros.cbancar%TYPE;
	  v_nsinies       sin_tramitacion.nsinies%TYPE;
	  v_ivalora       NUMBER;
	  v_ipenali       NUMBER;
	  v_icaprisc      NUMBER;
	  v_fsinies       sin_siniestro.fsinies%TYPE;
	  v_fnotifi       DATE;
	  anyos           NUMBER;
	  ptraza          NUMBER;
	  v_cmotmov       movseguro.cmotmov%TYPE;
	  es_de_anulacion NUMBER;
	  v_descri        VARCHAR2(1000);
	  v_benefi        NUMBER;
	  v_asegu         NUMBER;
	  v_cempres       seguros.cempres%TYPE;
	  v_nmovimi       NUMBER;
	  v_ntramit       sin_tramitacion.ntramit%TYPE;
	  v_ctramit       sin_tramitacion.ctramit%TYPE;
	  v_nmovres       NUMBER;
	  v_ifranq        NUMBER; /*Bug 27059:NSS:03/06/2013*/

	  CURSOR rie IS
	    SELECT *
	      FROM riesgos
	     WHERE sseguro=psseguro AND
	           fanulac IS NULL
	     ORDER BY nriesgo;

	  /*(JAS)04.04.07 - Afegim par¿metre sproduc al cursor, ja que sin¿ ens retorna garanties*/
	  /*duplicades (la mateixa garantia pot estar definida per m¿s d'un producte).*/
	CURSOR gar(

	    pnriesgo                    IN NUMBER,psproduc IN NUMBER) IS
	    SELECT g.cgarant
	      FROM garanseg g,prodcaumotsin p
	     WHERE g.sseguro=psseguro AND
	           g.nriesgo=pnriesgo AND
	           g.ffinefe IS NULL AND
	           p.cgarant=g.cgarant AND
	           p.ccausin=310 AND
	           p.sproduc=psproduc
	     ORDER BY g.cgarant;

	  /*(JAS)04.04.07 - Afegim par¿metre sproduc al cursor, ja que sin¿ ens retorna garanties*/
	  /*duplicades (la mateixa garantia pot estar definida per m¿s d'un producte).*/
	  /* BUG 11595 - 03/11/2009 - APD - Adaptaci¿n al nuevo m¿dulo de siniestros*/
	  /* se duplica el cursor con las tablas nuevas de siniestros*/
	CURSOR gar2(

	    pnriesgo                    IN NUMBER,psproduc IN NUMBER) IS
	    SELECT g.cgarant
	      FROM garanseg g,sin_gar_causa_motivo p,sin_causa_motivo m
	     WHERE g.sseguro=psseguro AND
	           g.nriesgo=pnriesgo AND
	           g.ffinefe IS NULL AND
	           p.cgarant=g.cgarant AND
	           p.scaumot=m.scaumot AND
	           m.ccausin=310 AND
	           p.sproduc=psproduc
	     ORDER BY g.cgarant;

	  /* BUG 11595 - 03/11/2009 - APD - Fin Adaptaci¿n al nuevo m¿dulo de siniestros*/
	  /* Bug 19312 - RSC - 22/11/2011 - LCOL_T004 - Parametrizaci¿n Anulaciones*/
	  ss              VARCHAR2(3000);
	  v_cursor        NUMBER;
	  v_filas         NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	  v_propio        VARCHAR2(50);
	  retorno         NUMBER;
	/* Fin Bug 19312*/
	/* INI BUG 19303 - 20/11/2011 - JMC - Adaptacion llamada dinamica.*/
	BEGIN
	    SELECT cempres
	      INTO v_cempres
	      FROM seguros
	     WHERE sseguro=psseguro;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'f_post_anulacion('''
	        || psseguro
	        || ''','
	        || to_char(pfanulac, 'YYYYMMDD')
	        || ','
	        || pnmovimi
	        || ')'
	        || ';'
	        || 'END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             /*
	               Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
	               a una funci¿n, procedimiento, etc. inexistente o no declarado. En este
	               caso a continaci¿n ejecutamos el c¿digo tradicional para determinar
	               si la p¿liza est¿ o no reducida.
	             */
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             SELECT s.fefecto,s.sproduc,s.cactivi,nnumpag,s.cbancar,m.cmotmov
	               INTO v_fefepol, v_sproduc, v_cactivi, v_nnumpag,
	             v_cbancar, v_cmotmov
	               FROM seguros s,productos p,movseguro m
	              WHERE m.sseguro=psseguro AND
	                    p.sproduc=s.sproduc AND
	                    m.sseguro=s.sseguro AND
	                    m.nmovimi=nvl(pnmovimi, 1);

	             /* BUG 11595 - 03/11/2009 - APD - Adaptaci¿n al nuevo m¿dulo de siniestros*/
	             /* En funci¿n del parempresa 'MODULO_SINI' si = 0, entonces se est¿ en el*/
	             /* modulo antiguo (se ejecutar¿ la primera parte del IF); si = 1, entonces*/
	             /* se est¿ en el modulo nuevo (se ejecutar¿ la segunda parte del IF)*/
	             /* Hay que tener en cuenta que cuando se modifique alguna parte de un IF*/
	             /* se debe modificar tambi¿n la otra (es decir, cuando se haga una modificacion*/
	             /* para el modelo antiguo de siniestros, por ejemplo, el mismo cambio se debe*/
	             /* replicar para el modelo nuevo de siniestros)*/
	             SELECT cempres
	               INTO v_cempres
	               FROM seguros
	              WHERE sseguro=psseguro;

	             /* Modelo antiguo de siniestros*/
	             IF nvl(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0)=0 THEN
	               SELECT count(*)
	                 INTO es_de_anulacion
	                 FROM prodcaumotsin pr,seguros s
	                WHERE pr.sproduc=s.sproduc AND
	                      (cmotmov=v_cmotmov  OR
	                       cmotfin=v_cmotmov) AND
	                      s.sseguro=psseguro;

	               IF es_de_anulacion=0 THEN
	                 /* no es un motivo de anulaci¿n por siniestro*/
	                 num_err:=f_difdata(v_fefepol, pfanulac, 1, 1, anyos);

	                 IF num_err<>0 THEN
	                   RETURN num_err;
	                 END IF;

	                 ptraza:=1;

	                 IF anyos>=2 THEN
	                 /* if pfanulac < trunc(f_sysdate) then*/
	                 /*   v_fsinies := pfanulac;*/
	                 /*   v_fnotifi := trunc(f_sysdate);*/
	                   /*else*/
	                   v_fsinies:=pfanulac;

	                   v_fnotifi:=trunc(f_sysdate);

	                 /*end if;*/
	                   /* abrimos un siniestro de rescate total para cada riesgo*/
	                   FOR i IN rie LOOP
	                       v_descri:=f_desriesgo_t(psseguro, i.nriesgo, NULL, 2);

	                       ptraza:=2;

	                       num_err:=pac_sin.f_inicializar_siniestro(psseguro, i.nriesgo, v_fsinies, v_fnotifi, 'Vencimiento de la p¿liza: '
	                                                                                                           || v_descri, 310, 0, 20, v_nsinies, NULL);

	                       IF num_err<>0 THEN
	                         RETURN num_err;
	                       END IF;

	                       /* marcamos el siniestro con el nmovimi de la anulaci¿n*/
	                       IF pnmovimi IS NOT NULL THEN
	                         UPDATE siniestros
	                            SET nmovimi=pnmovimi
	                          WHERE nsinies=v_nsinies;
	                       END IF;

	                       /* VALORACIONES*/
	                       /*(JAS)04.04.07 - Afegim par¿metre sproduc al cursor, ja que sin¿ ens retorna garanties*/
	                       /*duplicades (la mateixa garantia pot estar definida per m¿s d'un producte).*/
	                       FOR ii IN gar(i.nriesgo, v_sproduc) LOOP
	                           ptraza:=3;

	                           /* Bug 9685 - APD - 11/05/2009 - en lugar de coger la actividad de la tabla seguros,*/
	                           /* llamar a la funci¿n pac_seguros.ff_get_actividad*/
	                           num_err:=pk_cal_sini.valo_pagos_sini (v_fsinies, psseguro, v_nsinies, v_sproduc, pac_seguros.ff_get_actividad(psseguro, i.nriesgo), ii.cgarant, 310, 0, v_fnotifi, v_ivalora, v_ipenali, v_icaprisc);

	                           /* Bug 9685 - APD - 11/05/2009 - fin*/
	                           IF num_err<>0 THEN
	                             RETURN num_err;
	                           END IF;

	                           ptraza:=4;

	                           IF v_ivalora>0  OR
	                              v_icaprisc>0 THEN
	                             num_err:=pac_sin_insert.f_insert_valoraciones(v_nsinies, ii.cgarant, v_fnotifi, v_ivalora, v_ipenali, v_icaprisc);

	                             IF num_err<>0 THEN
	                               RETURN num_err;
	                             END IF;
	                           END IF;
	                       END LOOP;

	                       /* 26/1/06: Miramos si tenemos el mismo asegurado que el tomador*/
	                       SELECT count(1)
	                         INTO v_asegu
	                         FROM asegurados a,tomadores t
	                        WHERE a.sseguro=psseguro AND
	                              t.sseguro=a.sseguro AND
	                              t.sperson=a.sperson;

	                       /* 26/1/06: Miramos si tenemos clausulas de beneficiario especiales*/
	                       SELECT count(1)
	                         INTO v_benefi
	                         FROM clausuesp
	                        WHERE sseguro=psseguro AND
	                              cclaesp=1 /* Cl¿usula de beneficiario*/
	                              AND
	                              (ffinclau<v_fnotifi  OR
	                               ffinclau IS NULL);

	                       IF v_benefi=0 AND
	                          v_asegu=1 THEN /* La cl¿usula es la est¿ndar*/
	                         /* DESTINATARIOS*/
	                         ptraza:=5;

	                         num_err:=pac_sin_insert.f_insert_destinatarios(v_nsinies, psseguro, i.nriesgo, v_nnumpag, 1, 1, NULL, NULL, v_cbancar, NULL);

	                         IF num_err<>0 THEN
	                           RETURN num_err;
	                         END IF;
	                       /*
	                       --<Comentado para Cr¿dit Andorra: pues el 100 de Mvida corresponde a Espa¿a y 100 en Credit es Andorra>--
	                       --<29 de enero de 2008>--

	                                   --CPM 17/1/06: PAGOS
	                                   ptraza := 6;
	                                   IF Pac_Cuadre_Adm.f_LPS_pais(psseguro) = 100 THEN -- Es residente

	                                      num_Err := Pk_Cal_Sini.gen_pag_sini (v_fsinies,
	                                                                            psseguro,
	                                                                            v_nsinies,
	                                                                            v_sproduc,
	                                                                            v_cactivi,
	                                                                            310,
	                                                                            0,
	                                                                            v_fnotifi,
	                                                                            i.nriesgo
	                                                                           );

	                                      num_err := Pk_Cal_Sini.insertar_pagos (v_nsinies);

	                                        IF num_err <> 0
	                                        THEN
	                                            RETURN num_err;
	                                        END IF;

	                                   END IF;
	                       */
	                       END IF;
	                   END LOOP;
	                 END IF;
	               END IF;
	             /****************************************************************************/
	             ELSE /* Modelo nuevo de siniestros*/
	               SELECT count(*)
	                 INTO es_de_anulacion
	                 FROM sin_gar_causa_motivo gcm,sin_causa_motivo cm,seguros s
	                WHERE gcm.sproduc=s.sproduc AND
	                      gcm.scaumot=cm.scaumot AND
	                      (cm.cmotmov=v_cmotmov  OR
	                       cm.cmotfin=v_cmotmov) AND
	                      s.sseguro=psseguro;

	               IF es_de_anulacion=0 THEN
	                 /* no es un motivo de anulaci¿n por siniestro*/
	                 num_err:=f_difdata(v_fefepol, pfanulac, 1, 1, anyos);

	                 IF num_err<>0 THEN
	                   RETURN num_err;
	                 END IF;

	                 ptraza:=1;

	                 IF anyos>=2 THEN
	                 /* if pfanulac < trunc(f_sysdate) then*/
	                 /*   v_fsinies := pfanulac;*/
	                 /*   v_fnotifi := trunc(f_sysdate);*/
	                   /*else*/
	                   v_fsinies:=pfanulac;

	                   v_fnotifi:=trunc(f_sysdate);

	                 /*end if;*/
	                   /* abrimos un siniestro de rescate total para cada riesgo*/
	                   FOR i IN rie LOOP
	                       v_descri:=f_desriesgo_t(psseguro, i.nriesgo, NULL, 2);

	                       ptraza:=2;

	                       num_err:=pac_siniestros.f_inicializa_sin(psseguro, i.nriesgo, NULL, v_fsinies, v_fnotifi, 'Rescate Asegurado: '
	                                                                                                                 || v_descri, 310, 0, 20, v_nsinies, v_nmovimi, v_ntramit);

	                       IF num_err<>0 THEN
	                         RETURN num_err;
	                       END IF;

	                       /* marcamos el siniestro con el nmovimi de la anulaci¿n*/
	                       IF pnmovimi IS NOT NULL THEN
	                         UPDATE sin_siniestro
	                            SET nmovimi=pnmovimi
	                          WHERE nsinies=v_nsinies;
	                       END IF;

	                       /* VALORACIONES*/
	                       /*(JAS)04.04.07 - Afegim par¿metre sproduc al cursor, ja que sin¿ ens retorna garanties*/
	                       /*duplicades (la mateixa garantia pot estar definida per m¿s d'un producte).*/
	                       FOR ii IN gar2(i.nriesgo, v_sproduc) LOOP
	                           BEGIN
	                               SELECT ctramit
	                                 INTO v_ctramit
	                                 FROM sin_tramitacion
	                                WHERE nsinies=v_nsinies AND
	                                      ntramit=v_ntramit;
	                           EXCEPTION
	                               WHEN OTHERS THEN
	                                 RETURN 9000859;
	                           /* Error al leer de la tabla SIN_TRAMITACION*/
	                           END;

	                           ptraza:=3;

	                           /* Bug 9685 - APD - 11/05/2009 - en lugar de coger la actividad de la tabla seguros,*/
	                           /* llamar a la funci¿n pac_seguros.ff_get_actividad*/
	                           num_err:=pac_sin_formula.f_cal_valora (v_fsinies, psseguro, NULL, v_nsinies, v_ntramit, v_ctramit, v_sproduc, pac_seguros.ff_get_actividad(psseguro, i.nriesgo), ii.cgarant, 310, 0, v_fnotifi, f_sysdate, NULL, NULL, v_ivalora, v_ipenali, v_icaprisc, v_ifranq /* Bug 27059 : NSS : 03/06/2013*/
	                                    );

	                           /* Bug 9685 - APD - 11/05/2009 - fin*/
	                           IF num_err<>0 THEN
	                             RETURN num_err;
	                           END IF;

	                           ptraza:=4;

	                           IF v_ivalora>0  OR
	                              v_icaprisc>0 THEN
	                             num_err:=pac_siniestros.f_ins_reserva(v_nsinies, v_ntramit, 1, ii.cgarant, 1, v_fnotifi, NULL,
	                                      /* BUG 18423 - 14/11/2011 - JMP - Pasamos moneda reserva NULL para que la coja en funci¿n*/
	                                      /* de si es multimoneda o no*/
	                                      nvl(v_ivalora, 0)-nvl(v_ipenali, 0), NULL, v_icaprisc, v_ipenali, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, v_nmovres, 1,
	                                      /*cmovres --0031294/0174788: NSS:23/05/2014*/
	                                      v_ifranq /*Bug 27059:NSS:03/06/2013*/
	                                      );

	                             IF num_err<>0 THEN
	                               RETURN num_err;
	                             END IF;
	                           END IF;
	                       END LOOP;

	                       /* 26/1/06: Miramos si tenemos el mismo asegurado que el tomador*/
	                       SELECT count(1)
	                         INTO v_asegu
	                         FROM asegurados a,tomadores t
	                        WHERE a.sseguro=psseguro AND
	                              t.sseguro=a.sseguro AND
	                              t.sperson=a.sperson;

	                       /* 26/1/06: Miramos si tenemos clausulas de beneficiario especiales*/
	                       SELECT count(1)
	                         INTO v_benefi
	                         FROM clausuesp
	                        WHERE sseguro=psseguro AND
	                              cclaesp=1 /* Cl¿usula de beneficiario*/
	                              AND
	                              (ffinclau<v_fnotifi  OR
	                               ffinclau IS NULL);

	                       IF v_benefi=0 AND
	                          v_asegu=1 THEN /* La cl¿usula es la est¿ndar*/
	                         /* DESTINATARIOS*/
	                         ptraza:=5;

	                         num_err:=pac_sin_rescates.f_ins_destinatario(v_nsinies, v_ntramit, psseguro, i.nriesgo, v_nnumpag, 1, 1, NULL, NULL, v_cbancar, NULL);

	                         IF num_err<>0 THEN
	                           RETURN num_err;
	                         END IF;
	                       END IF;
	                   END LOOP;
	                 END IF;
	               END IF;
	             END IF;

	             RETURN 0; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_propio.f_post_anulacion', ptraza, 'error no controlat', SQLERRM);

	             RETURN 140999;
	END f_post_anulacion;
	FUNCTION f_generar_fichero(
			pnremesa	IN	NUMBER
	) RETURN NUMBER
	IS
	  w_fichero    utl_file.file_type;
	  w_rutaout    VARCHAR2(100);
	  w_nomfichero VARCHAR2(100);
	  w_prelinea   VARCHAR2(80);
	  w_linea      VARCHAR2(1000);
	  w_benefici   per_personas.nnumide%TYPE;
	  w_nombre     VARCHAR2(100);
	  w_tempres    empresas.tempres%TYPE;
	  w_tdomici    direcciones.tdomici%TYPE;
	  w_tipo       VARCHAR2(30);
	  w_mes        VARCHAR2(15);
	  w_grupo      VARCHAR2(20):='0';
	  w_tpoblac    poblaciones.tpoblac%TYPE;
	  w_nnumnif    cobbancario.nnumnif%TYPE;
	  w_total      NUMBER;
	  w_cuantos    NUMBER;
	  w_bruto      pagosrenta.iconret%TYPE;
	  w_empresa    remesas.cempres%TYPE:=0;
	  w_cpostal    direcciones.cpostal%TYPE;
	  w_cpoblac    direcciones.cpoblac%TYPE;
	  w_cprovin    direcciones.cprovin%TYPE;
	  num_err      NUMBER;

	  CURSOR remesa IS
	    SELECT *
	      FROM remesas
	     WHERE nremesa=pnremesa;
	BEGIN
	    w_rutaout:=f_parinstalacion_t('PATH_INTMV');

	    /* Bucle para cada pago.*/
	    w_total:=0;

	    w_cuantos:=0;

	    FOR r IN remesa LOOP
	        IF r.cobliga=1 THEN
	          IF w_empresa<>r.cempres THEN
	          /* datos de la empresa*/
	          BEGIN
	                w_empresa:=r.cempres;

	                SELECT e.tempres,d.tdomici,cpostal,cpoblac,cprovin
	                  INTO w_tempres, w_tdomici, w_cpostal, w_cpoblac, w_cprovin
	                  FROM empresas e,direcciones d
	                 WHERE e.cempres=r.cempres AND
	                       d.sperson=e.sperson AND
	                       d.cdomici=(SELECT min(cdomici)
	                                    FROM direcciones dd
	                                   WHERE dd.sperson=d.sperson);
	            EXCEPTION
	                WHEN OTHERS THEN
	                  RETURN 120135;
	            END; BEGIN SELECT tpoblac INTO w_tpoblac FROM poblaciones WHERE cpoblac = w_cpoblac AND cprovin = w_cprovin; EXCEPTION WHEN OTHERS THEN RETURN 120135; END;
	          END IF;

	          IF w_grupo<>r.ccc THEN
	            w_grupo:=r.ccc;

	            w_nomfichero:=f_parinstalacion_t('FILE_TRANS');

	            IF w_nomfichero IS NULL THEN
	              w_nomfichero:='CSB34_'
	                            || r.ccc
	                            || '_'
	                            || to_char(f_sysdate, 'DDMMYYYY')
	                            || '.TXT';
	            END IF;

	            BEGIN
	                SELECT nnumnif
	                  INTO w_nnumnif
	                  FROM cobbancario
	                 WHERE ncuenta=r.ccc;
	            END;

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
	            w_prelinea:='0356'
	                        || rpad(w_nnumnif, 10, ' ')
	                        || '            ';

	            /*
	            {linea 1= prefijo cab + 001+fecha envio + fecha orden + entidad destino + oficina destino +
	            ccuenta cargo+detalle de cargo+3_+dc cuenta cargo
	            */
	            w_linea:=w_prelinea
	                     || '001'
	                     || to_char(f_sysdate, 'DDMMYY')
	                     /* Fecha de Envio del Fichero*/
	                     || to_char(f_sysdate, 'DDMMYY')
	                     /* Fecha de EMisi¿n de las ordenes*/
	                     || substr(lpad(r.ccc, 20, '0'), 1, 4) -- Banco
	                     || substr(lpad(r.ccc, 20, '0'), 5, 4) -- Oficina
	                     || substr(lpad(r.ccc, 20, '0'), 11, 10) -- Cuenta
	                     || '1' -- Detalle del cargo.
	                     || '   ' -- libre
	                     || substr(lpad(r.ccc, 20, '0'), 9, 2);

	            /* D¿gito Control*/
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
	          /* extornos y anulaciones de aprotaci¿n*/
	          BEGIN
	            /* ini Bug 0012803 - 19/02/2010 - JMF*/
	            /* SELECT tapelli1 || ' ' || tapelli2 || ',' || tnombre,*/
	            /*        RPAD(nnumnif, 12, ' '), r.iimport,*/
	            /*        TO_CHAR(recibos.femisio, 'FMMONTH')*/
	            /*   INTO w_nombre,*/
	            /*        w_benefici, w_bruto,*/
	            /*        w_mes*/
	            /*   FROM personas, recibos, riesgos*/
	            /*  WHERE recibos.nrecibo = r.nrecibo*/
	            /*    AND recibos.sseguro = riesgos.sseguro*/
	            /*    AND NVL(recibos.nriesgo, 1) = riesgos.nriesgo*/
	            /*    AND riesgos.sperson = personas.sperson;*/
	                /* Bug 0012803 - 26/03/2010 - JMF*/
	                SELECT d.tapelli1
	                       || ' '
	                       || d.tapelli2
	                       || ','
	                       || d.tnombre,rpad(c.nnumide, 12, ' '),r.iimport,to_char(a.femisio, 'FMMONTH')
	                  INTO w_nombre, w_benefici, w_bruto, w_mes
	                  FROM recibos a,riesgos b,per_personas c,per_detper d,seguros x
	                 WHERE a.nrecibo=r.nrecibo AND
	                       b.sseguro=a.sseguro AND
	                       b.nriesgo=nvl(a.nriesgo, 1) AND
	                       c.sperson=b.sperson AND
	                       d.sperson=c.sperson AND
	                       x.sseguro=a.sseguro AND
	                       d.cagente=ff_agente_cpervisio(x.cagente, f_sysdate, x.cempres);
	            /* fin Bug 0012803 - 19/02/2010 - JMF*/
	            EXCEPTION
	                WHEN no_data_found THEN
	                  RETURN 120135;
	            END;
	          ELSE BEGIN
	            /* BUG 11595 - 05/11/2009 - APD - Adaptaci¿n al nuevo m¿dulo de siniestros*/
	            /* Para este caso, en vez de buscar por el parempresa 'MODULO_SINI' para saber si se*/
	            /* est¿ en el m¿dulo antiguo o nuevo de siniestros (ya que se necesita la empresa del*/
	            /* seguro para buscar el valor del parempresa) se a¿aden las tablas siniestros (o*/
	            /* sin_siniestro) y seguros para obtener as¿ la empresa.*/
	            /* Se a¿ade la UNION con las tablas nuevas de siniestros*/
	                /* ini Bug 0012803 - 19/02/2010 - JMF*/
	                SELECT a.nombre,a.benefici,a.iimpsin,a.mes
	                  INTO w_nombre, w_benefici, w_bruto, w_mes
	                  FROM (
	                       /* SELECT tapelli1 || ' ' || tapelli2 || ',' || tnombre nombre,*/
	                       /*         RPAD(nnumnif, 12, ' ') benefici, iimpsin,*/
	                       /*         TO_CHAR(fordpag, 'FMMONTH') mes*/
	                       /*    FROM personas, pagosini, siniestros, seguros*/
	                       /*   WHERE pagosini.sidepag = r.sidepag*/
	                       /*     AND pagosini.sperson = personas.sperson*/
	                       /*     AND pagosini.nsinies = siniestros.nsinies*/
	                       /*     AND siniestros.sseguro = seguros.sseguro*/
	                       /*     AND NVL(pac_parametros.f_parempresa_n(seguros.cempres,'MODULO_SINI'),0) = 0*/
	                       /*  UNION*/
	                       /*  SELECT tapelli1 || ' ' || tapelli2 || ',' || tnombre nombre,*/
	                       /*         RPAD(nnumnif, 12, ' ') benefici,*/
	                       /*         (sin_tramita_pago.isinret- sin_tramita_pago.iretenc-sin_tramita_pago.iiva) iimpsin,*/
	                       /*         TO_CHAR(fordpag, 'FMMONTH') mes*/
	                       /*    FROM personas, sin_tramita_pago, sin_tramitacion, sin_siniestro, seguros*/
	                       /*   WHERE sin_tramita_pago.sidepag = r.sidepag*/
	                       /*     AND sin_tramita_pago.sperson = personas.sperson*/
	                       /*     AND sin_tramita_pago.nsinies = sin_tramitacion.nsinies*/
	                       /*     AND sin_tramita_pago.ntramit = sin_tramitacion.ntramit*/
	                       /*     AND sin_tramitacion.nsinies = sin_siniestro.nsinies*/
	                       /*     AND sin_siniestro.sseguro = seguros.sseguro*/
	                       /*     AND NVL(pac_parametros.f_parempresa_n(seguros.cempres,'MODULO_SINI'),0) = 1*/
	                       /* Bug 0012803 - 26/03/2010 - JMF*/
	                       SELECT d.tapelli1
	                              || ' '
	                              || d.tapelli2
	                              || ','
	                              || d.tnombre nombre,rpad(c.nnumide, 12, ' ') benefici,a.iimpsin,to_char(a.fordpag, 'FMMONTH') mes
	                         FROM pagosini a,siniestros b,seguros s,per_personas c,per_detper d
	                        WHERE a.sidepag=r.sidepag AND
	                              b.nsinies=a.nsinies AND
	                              s.sseguro=b.sseguro AND
	                              nvl(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0)=0 AND
	                              c.sperson=a.sperson AND
	                              d.sperson=c.sperson AND
	                              d.cagente=ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres)
	                        UNION
	                        SELECT d.tapelli1
	                               || ' '
	                               || d.tapelli2
	                               || ','
	                               || d.tnombre nombre,rpad(c.nnumide, 12, ' ') benefici,(nvl(a.isinret, 0)-nvl(a.iretenc, 0)-nvl(a.iiva, 0)) iimpsin,to_char(a.fordpag, 'FMMONTH') mes
	                          FROM sin_tramita_pago a,sin_tramitacion b,sin_siniestro i,seguros s,per_personas c,per_detper d
	                         WHERE a.sidepag=r.sidepag AND
	                               b.nsinies=a.nsinies AND
	                               b.ntramit=a.ntramit AND
	                               i.nsinies=b.nsinies AND
	                               s.sseguro=i.sseguro AND
	                               c.sperson=a.sperson AND
	                               d.sperson=c.sperson AND
	                               d.cagente=ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres) AND
	                               nvl(pac_parametros.f_parempresa_n(s.cempres, 'MODULO_SINI'), 0)=1) a;
	            /* fin Bug 0012803 - 19/02/2010 - JMF*/
	            EXCEPTION
	                WHEN no_data_found THEN BEGIN
	                  /* ini Bug 0012803 - 19/02/2010 - JMF*/
	                  /* SELECT tapelli1 || ' ' || tapelli2 || ',' || tnombre,*/
	                  /*        RPAD(nnumnif, 12, ' '), iconret, TO_CHAR(ffecpag, 'FMMONTH')*/
	                  /*   INTO w_nombre,*/
	                  /*        w_benefici, w_bruto, w_mes*/
	                  /*   FROM personas, pagosrenta p*/
	                  /*  WHERE p.srecren = r.nrentas*/
	                  /*    AND p.sperson = personas.sperson;*/
	                      /* Bug 0012803 - 26/03/2010 - JMF*/
	                      SELECT d.tapelli1
	                             || ' '
	                             || d.tapelli2
	                             || ','
	                             || d.tnombre,rpad(c.nnumide, 12, ' '),a.iconret,to_char(a.ffecpag, 'FMMONTH')
	                        INTO w_nombre, w_benefici, w_bruto, w_mes
	                        FROM pagosrenta a,seguros b,per_personas c,per_detper d
	                       WHERE a.srecren=r.nrentas AND
	                             b.sseguro=a.sseguro AND
	                             c.sperson=a.sperson AND
	                             d.sperson=c.sperson AND
	                             d.cagente=ff_agente_cpervisio(b.cagente, f_sysdate, b.cempres);
	                  /* fin Bug 0012803 - 19/02/2010 - JMF*/
	                  EXCEPTION
	                      WHEN no_data_found THEN
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
	          w_prelinea:='0656'
	                      || rpad(w_nnumnif, 10, ' ')
	                      || w_benefici;

	          /*
	            linea 1 = prefijo bene + 010 + importe + cod. banco + ofic. bancaria + cuenta corriente +
	                      1 (gastos a cuenta del ordenante) + 8 (concepto pension)+2_+dc cuenta
	          */
	          w_linea:=w_prelinea
	                   || '010'
	                   || to_char(r.iimport*100, 'FM000000000000')
	                   || substr(lpad(r.cabono, 20, '0'), 1, 4)
	                   || substr(lpad(r.cabono, 20, '0'), 5, 4)
	                   || substr(lpad(r.cabono, 20, '0'), 11, 10)
	                   || '1'
	                   || '9'
	                   || '  '
	                   || substr(lpad(r.cabono, 20, '0'), 9, 2);

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
	            w_tipo:='DEVOLUCI¿N';
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
	        /*  linea := RPAD (prelinea || '017', 72, '=');*/
	        /* UTL_FILE.put_line (fichero, SUBSTR (linea, 1, 72));*/
	        END IF;

	        IF w_grupo<>r.ccc AND
	           w_cuantos>0 THEN
	          /* TOTALES*/
	          w_linea:='0856'
	                   || rpad(w_nnumnif, 10, ' ')
	                   || '            '
	                   || '   '
	                   || to_char(w_total*100, 'FM000000000000')
	                   || to_char(w_cuantos, 'FM00000000')
	                   || to_char(w_cuantos*3+5, 'FM0000000000');

	          utl_file.put_line(w_fichero, substr(w_linea, 1, 72));

	          /* Cerramos el fichero*/
	          utl_file.fclose(w_fichero);

	          w_total:=0;

	          w_cuantos:=0;
	        END IF;
	    END LOOP;

	    IF w_cuantos>0 THEN
	      /* TOTALES*/
	      w_linea:='0856'
	               || rpad(w_nnumnif, 10, ' ')
	               || '            '
	               || '   '
	               || to_char(w_total*100, 'FM000000000000')
	               || to_char(w_cuantos, 'FM00000000')
	               || to_char(w_cuantos*3+5, 'FM0000000000');

	      utl_file.put_line(w_fichero, substr(w_linea, 1, 72));

	      utl_file.fclose(w_fichero);
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_propio.f_genera_fichero', 1, 'error no controlado', SQLERRM);

	             RETURN 140999; /*error no controlado*/
	END f_generar_fichero;
	FUNCTION f_retener(
			ptablas	IN	VARCHAR2,
			psseguro	IN	NUMBER,
			pnriesgo	IN	NUMBER,
			pnmovimi	IN	NUMBER,
			pfecha	IN	DATE
	) RETURN NUMBER
	IS
	/* CPM 11/7/2005: Deixem la p¿lissa retinguda. Aquest funci¿ est¿ preparada*/
	  /* per a que es cridi des de el proc¿s de cartera.*/
	  num_err NUMBER;
	BEGIN
	    num_err:=pac_emision_mv.f_retener_poliza(ptablas, psseguro, pnriesgo, pnmovimi, 5, 1, pfecha);

	    UPDATE seguros
	       SET csituac=5
	     WHERE sseguro=psseguro;

	    UPDATE movseguro
	       SET femisio=NULL
	     WHERE nmovimi=pnmovimi AND
	           sseguro=psseguro;

	    RETURN num_err;
	END f_retener;
	PROCEDURE f_renova_cesiones_pu(
			psproces	IN	NUMBER,
			pmes	IN	NUMBER,
			panyo	IN	NUMBER,
			pramo	IN	NUMBER,
			pmodali	IN	NUMBER,
			ptipseg	IN	NUMBER,
			pcolect	IN	NUMBER,
			psseguro	IN	NUMBER DEFAULT NULL
	) IS
	  /******************************************************************************
	     NAME:        f_renova_cesiones_PU
	     Descripci¿n: Procedimiento para calcular las cesiones anuales en las p¿lizas
	                 que s¿n de Prima Unica (PU)

	     REVISIONS:
	     Ver        Date        Author           Description
	     ---------  ----------  ---------------  ------------------------------------
	     1.0        28/02/2006  CPM              1. Created this procedure.
	     2.0        26/04/2010  AVT              2. 13964: CEM800 - Renovaci¿ de Cartera del producte ESCUT BASIC

	  ******************************************************************************/
	  CURSOR c_seg_pu IS
	    SELECT s.sseguro,s.sproduc,s.ctiprea,s.cempres,to_date(panyo
	                                                           || lpad(s.nrenova, 4, '0'), 'yyyymmdd') fefecmov,(SELECT max(nmovimi)
	                                                                                                               FROM garanseg m
	                                                                                                              WHERE m.sseguro=s.sseguro) nmovimi
	      FROM seguros s
	     WHERE (trunc(nrenova/100)<=pmes  OR
	            pmes IS NULL) AND
	           ((csituac=5)  OR
	            (creteni=0 AND
	             csituac NOT IN(7, 8, 9, 10))) AND
	           NOT EXISTS(SELECT 1
	                        FROM cesionesrea c
	                       WHERE cgenera IN(3, 5) AND
	                             c.sseguro=s.sseguro AND
	                             to_char(fvencim, 'yyyy')=panyo+1)
	           /*AND(fvencim > TO_DATE(panyo || LPAD(s.nrenova, 4, '0'), 'yyyymmdd') -- 13964 AVT 26-04-2010*/
	           AND
	           (fvencim>f_fecha_renova(panyo, lpad(s.nrenova, 4, '0'))  OR
	            fvencim IS NULL) AND
	           f_parproductos_v(sproduc, 'REASEGURO')=1
	           /* Reaseguro a la renovaci¿n*/
	           AND
	           (s.cforpag=0  OR
	            nvl(f_parproductos_v(sproduc, 'REAS_PU'), 0)=1) -- BUG: 12971 AVT 05-02-2010
	           AND
	           s.ctiprea<>2
	           /*AND s.fefecto < TO_DATE(panyo || LPAD(s.nrenova, 4, '0'), 'yyyymmdd') -- 13964 AVT 26-04-2010*/
	           AND
	           s.fefecto<f_fecha_renova(panyo, lpad(s.nrenova, 4, '0'))
	           /* AND(s.fanulac > TO_DATE(panyo || LPAD(s.nrenova, 4, '0'), 'yyyymmdd') -- 13964 AVT 26-04-2010*/
	           AND
	           (s.fanulac>f_fecha_renova(panyo, lpad(s.nrenova, 4, '0'))  OR
	            s.fanulac IS NULL) AND
	           s.femisio IS NOT NULL AND
	           s.cramo=nvl(pramo, s.cramo) AND
	           s.cmodali=nvl(pmodali, s.cmodali) AND
	           s.ctipseg=nvl(ptipseg, s.ctipseg) AND
	           s.ccolect=nvl(pcolect, s.ccolect) AND
	           s.sseguro=nvl(psseguro, s.sseguro)
	     ORDER BY s.nrenova;

	  lfini    DATE;
	  lffi     DATE;
	  num_err  NUMBER;
	  lorigen  NUMBER;
	  ldetces  NUMBER;
	  ltexto   VARCHAR2(1000);
	  lmotiu   NUMBER;
	  nprolin  NUMBER;
	  v_idioma NUMBER;
	BEGIN
	    FOR v_pol IN c_seg_pu LOOP
	        /* Cal obtenir les dates d'inici i final de cessi¿*/
	        lfini:=v_pol.fefecmov;

	        /*3793 jdomingo 17/12/2007*/
	        lffi:=add_months(lfini, 12); /* Calculem cessions anuals*/

	        /*lffi := lfini + 365;          -- Calculem cessions anuals*/
	        /* No sumem 365 per evitar problemes amb els anys bisiestos*/
	        /* Rectificaci¿n generada inicialemente para MVida --> MV_1087*/
	        IF v_pol.ctiprea<>2 THEN
	          lmotiu:=5; /* Renovaci¿n*/

	          lorigen:=1;

	          ldetces:=NULL;

	          num_err:=f_parproductos(v_pol.sproduc, 'REASEGURO', ldetces);

	          num_err:=f_buscactrrea(v_pol.sseguro, v_pol.nmovimi, psproces, lmotiu,
	                   /* BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda*/
	                   /*1,*/
	                   pac_monedas.f_moneda_producto(v_pol.sproduc),
	                   /* BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda*/
	                   lorigen, lfini, lffi);

	          IF num_err<>0 AND
	             num_err<>99 THEN
	            v_idioma:=pac_parametros.f_parempresa_n(v_pol.cempres, 'IDIOMA_DEF');

	            ltexto:=f_axis_literales(num_err, v_idioma);

	            num_err:=f_proceslin(psproces, ltexto, v_pol.sseguro, nprolin);
	          ELSIF num_err=99 THEN
	            /* no troba contracte ???*/
	            num_err:=0;
	          ELSE
	            num_err:=f_cessio(psproces, lmotiu, 1, f_sysdate);

	            /*v_pol.fdatagen);*/
	            IF num_err<>0 AND
	               num_err<>99 THEN
	              v_idioma:=pac_parametros.f_parempresa_n(v_pol.cempres, 'IDIOMA_DEF');

	              ltexto:=f_axis_literales(num_err, v_idioma);

	              num_err:=f_proceslin(psproces, ltexto, v_pol.sseguro, nprolin);
	            ELSIF num_err=99 THEN
	              num_err:=105382; /*No te facultatiu*/

	              v_idioma:=pac_parametros.f_parempresa_n(v_pol.cempres, 'IDIOMA_DEF');

	              ltexto:=f_axis_literales(num_err, v_idioma);

	              num_err:=f_proceslin(psproces, ltexto, v_pol.sseguro, nprolin);
	            ELSE
	            /* Si ¿s emissio d una p¿lissa que es reassegura en*/
	            /* el q.amortitzaci¿ :Cal calcular el detall de cessions*/
	              /* pel periode de la emissi¿*/
	              IF nvl(lorigen, 1)=2 THEN
	                num_err:=pac_cesionesrea.f_cessio_det_per(v_pol.sseguro, lfini, lffi, psproces);

	                IF num_err<>0 THEN
	                  v_idioma:=pac_parametros.f_parempresa_n(v_pol.cempres, 'IDIOMA_DEF');

	                  ltexto:=f_axis_literales(num_err, v_idioma);

	                  num_err:=f_proceslin(psproces, ltexto, v_pol.sseguro, nprolin);
	                /*COMMIT;*/
	                ELSE
	                  num_err:=f_proceslin(psproces, 'OK', v_pol.sseguro, nprolin);
	                END IF;
	              ELSE
	                num_err:=f_proceslin(psproces, 'OK', v_pol.sseguro, nprolin);
	              END IF;
	            END IF;
	          END IF;
	        END IF;
	    END LOOP;
	END f_renova_cesiones_pu;
	FUNCTION ff_capital_pu(
			psseguro	IN	NUMBER,
			pfecha	IN	DATE
	) RETURN NUMBER
	IS
	  /******************************************************************************
	     NAME:        ff_capital_PU
	     Descripci¿n: Funci¿n que devuelve el capital para calcular las cesiones
	                 anuales en las p¿lizas que s¿n de Prima Unica (PU)

	     REVISIONS:
	     Ver        Date        Author           Description
	     ---------  ----------  ---------------  ------------------------------------
	     1.0        07/03/2006  CPM              1. Created this procedure.

	  ******************************************************************************/
	  xcapital NUMBER;
	BEGIN
	    xcapital:=pac_vinculados.f_cap_prestcuadroseg(psseguro, pfecha);

	    RETURN(xcapital);
	END ff_capital_pu;
	FUNCTION f_valida_estriesgo_producto(
			psseguro	IN	NUMBER,
			psproduc	IN	NUMBER,
			psperson	IN	NUMBER
	) RETURN NUMBER
	IS
	  cuantos_menores NUMBER;
	  cuantos_mayores NUMBER;
	BEGIN
	    IF psproduc IN(41, 42) THEN
	      /* por cada 2 riesgos < 65 a¿os y > de 15 a¿os se puede dar de alta un riesgo > 65 a¿os*/
	      SELECT count(*)
	        INTO cuantos_menores
	        FROM estriesgos r,per_personas p /* Bug 0012803 - 19/02/2010 - JMF*/
	       WHERE r.sseguro=psseguro AND
	             p.sperson=r.sperson AND
	             fedad(1, to_char(p.fnacimi, 'yyyymmdd'), to_char(r.fefecto, 'yyyymmdd'), 2)<=65 AND
	             fedad(1, to_char(p.fnacimi, 'yyyymmdd'), to_char(r.fefecto, 'yyyymmdd'), 2)>=15;

	      SELECT count(*)
	        INTO cuantos_mayores
	        FROM estriesgos r,per_personas p /* Bug 0012803 - 19/02/2010 - JMF*/
	       WHERE r.sseguro=psseguro AND
	             p.sperson=r.sperson AND
	             fedad(1, to_char(p.fnacimi, 'yyyymmdd'), to_char(r.fefecto, 'yyyymmdd'), 2)>65;

	      IF cuantos_menores/2<cuantos_mayores THEN
	        RETURN 152488; /*edad no se cumple*/
	      END IF;
	    END IF;

	    RETURN 0;
	END f_valida_estriesgo_producto;
	FUNCTION f_validar_edad_prod(
			pssolicit	IN	NUMBER,
			psproduc	IN	NUMBER,
			pfnacimi	IN	DATE
	) RETURN NUMBER
	IS
	  es_mayor        NUMBER:=0;
	  es_menor        NUMBER:=0;
	  v_falta         solseguros.falta%TYPE;
	  cuantos_menores NUMBER;
	  cuantos_mayores NUMBER;
	BEGIN
	    IF psproduc IN(41, 42) THEN
	      /* por cada 2 riesgos < 65 a¿os y > 15 a¿os se puede dar de alta un riesgo > 65 a¿os*/
	      SELECT falta
	        INTO v_falta
	        FROM solseguros
	       WHERE ssolicit=pssolicit;

	      SELECT count(*)
	        INTO cuantos_menores
	        FROM solriesgos r
	       WHERE r.ssolicit=pssolicit AND
	             r.fnacimi IS NOT NULL AND
	             fedad(1, to_char(r.fnacimi, 'yyyymmdd'), to_char(v_falta, 'yyyymmdd'), 2)<=65 AND
	             fedad(1, to_char(r.fnacimi, 'yyyymmdd'), to_char(v_falta, 'yyyymmdd'), 2)>=15;

	      SELECT count(*)
	        INTO cuantos_mayores
	        FROM solriesgos r
	       WHERE r.ssolicit=pssolicit AND
	             r.fnacimi IS NOT NULL AND
	             fedad(1, to_char(r.fnacimi, 'yyyymmdd'), to_char(v_falta, 'yyyymmdd'), 2)>65;

	      IF fedad(1, to_char(pfnacimi, 'yyyymmdd'), to_char(v_falta, 'yyyymmdd'), 2)>65 THEN
	        es_mayor:=1;
	      ELSIF fedad(1, to_char(pfnacimi, 'yyyymmdd'), to_char(v_falta, 'yyyymmdd'), 2)<=65 AND
	            fedad(1, to_char(pfnacimi, 'yyyymmdd'), to_char(v_falta, 'yyyymmdd'), 2)>=15 THEN
	        es_menor:=1;
	      END IF;

	      IF (cuantos_menores+es_menor)/2<cuantos_mayores+es_mayor THEN
	        RETURN 152488; /*edad no se cumple*/
	      END IF;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_validar_edad_prod', 1, 'pssolicit: '
	                                                                                 || pssolicit
	                                                                                 || ' psproduc: '
	                                                                                 || psproduc
	                                                                                 || ' pfnacimi: '
	                                                                                 || pfnacimi, SQLCODE
	                                                                                              || '-'
	                                                                                              || SQLERRM);

	             RETURN 1;
	END f_validar_edad_prod;
	FUNCTION f_suplem_cartera(
			pmodo	IN	NUMBER,
			psproces	IN	NUMBER,
			pmes	IN	NUMBER,
			panyo	IN	NUMBER,
			pcramo	IN	NUMBER,
			pcactivi	IN	NUMBER,
			psproduc	IN	NUMBER,
			psseguro	IN	NUMBER,
			pcidioma NUMBER DEFAULT 2
	) RETURN NUMBER
	IS
	  /*******************************************************************************************************************************************
	        pmodo : 0 .- REAL
	                       1.- PREVIO
	       psseguro: puede ser NULL; si est¿ informado s¿lo se har¿ el suplemento a esa p¿liza
	  *************************************************************************************************************************************/
	  pliniaini VARCHAR2(500);
	  vmodo     VARCHAR2(30);
	  num_err   NUMBER;
	  psmapead  NUMBER;
	BEGIN
	    IF pmodo=0 THEN
	      vmodo:='REAL';
	    ELSE
	      vmodo:='PREVIO';
	    END IF;

	    pliniaini:=''
	               || psproces
	               || '|'
	               || lpad(pmes, 2, '0')
	               || panyo
	               || '|'
	               || vmodo
	               || '|'
	               || pcramo
	               || '|'
	               || pcactivi
	               || '|'
	               || psproduc
	               || '|'
	               || psseguro
	               || '|'
	               || pcidioma
	               || '';

	    pac_map.p_carga_parametros_fichero('136', pliniaini);

	    num_err:=pac_map.carga_map('136', psmapead);

	    RETURN num_err;
	END f_suplem_cartera;
	PROCEDURE p_predomiciliacion(
			psproces	IN	NUMBER,
			pcempres	IN	NUMBER,
			pcidioma	IN	NUMBER,
			pcramo	IN	NUMBER,
			pcmodali	IN	NUMBER,
			pctipseg	IN	NUMBER,
			pccolect	IN	NUMBER
	) IS
	  /********************************************************************************************************************

	     En nuestro caso el tratamiento de predomiciliacion ser¿ anular los recibos pendientes de p¿lizas

	     anuladas en la fecha de cobro.

	     Estos recibos se 'marcar¿n' para poder impromirlos en un listado

	  **************************************************************************************************************/
	  CURSOR rec IS
	    SELECT r.nrecibo,m.fmovini,r.fefecto,r.fvencim,s.csituac,s.fanulac,s.sseguro,s.sproduc,ROWNUM-1 contad
	      FROM seguros s,recibos r,movrecibo m
	     WHERE /*f_vigente(s.sseguro, NULL, TRUNC(f_sysdate)) <> 0 AND*/
	      s.sseguro=r.sseguro AND
	      r.nrecibo=m.nrecibo AND
	      s.cempres=pcempres AND
	      m.fmovfin IS NULL AND
	      r.fefecto<trunc(f_sysdate) /*JRH Tares 6966*/
	      AND
	      m.cestrec=0 AND
	      nvl(f_parproductos_v(s.sproduc, 'DOMANULAREC'), 0)=1 AND
	      (pcramo IS NULL  OR
	       s.cramo=pcramo) AND
	      (pcmodali IS NULL  OR
	       s.cmodali=pcmodali) AND
	      (pctipseg IS NULL  OR
	       s.ctipseg=pctipseg) AND
	      (pccolect IS NULL  OR
	       s.ccolect=pccolect)
	     ORDER BY contad;

	  cont_malos NUMBER:=0;
	  error      NUMBER;
	  num_err    NUMBER;
	  v_sproces  predomiciliaciones.sproces%TYPE;
	  v_smovagr  predomiciliaciones.smovagr%TYPE;
	  nprolin    NUMBER;
	  texto      VARCHAR2(100);
	BEGIN
	    IF psproces IS NULL THEN
	      error:=f_procesini(f_user, pcempres, 'Domiciliaciones', 'P_PREDOMICILIACION', v_sproces);
	    ELSE
	      v_sproces:=psproces;
	    END IF;

	    /* Pondremos a todos los recibos anulados el mismo smovagr*/
	    SELECT smovagr.NEXTVAL
	      INTO v_smovagr
	      FROM dual;

	    /* Insertamos en la tabla PREDOMICILIACIONES*/
			INSERT INTO predomiciliaciones
		           (sproces,smovagr)
		    VALUES
		           (v_sproces,v_smovagr);


	    /*  {anulamos todos los recibos seleccionados}*/
	    FOR c IN rec LOOP
	        IF f_vigente(c.sseguro, NULL, trunc(f_sysdate))<>0 THEN
	          num_err:=f_anula_rec(c.nrecibo, trunc(f_sysdate), 0, v_smovagr);

	          IF num_err=0 THEN
	            error:=f_proceslin(v_sproces, 'PREDOMICILIACI¿N.Se anula el recibo: '
	                                          || c.nrecibo, num_err, nprolin, 4); /* Correcto*/
	          ELSE
	            cont_malos:=cont_malos+1;

	            texto:=f_axis_literales(num_err, 1);

	            error:=f_proceslin(v_sproces, 'Error '
	                                          || texto
	                                          || 'rec. '
	                                          || c.nrecibo, num_err, nprolin, 1); /* Error*/
	          END IF;
	        END IF;
	    END LOOP;

	    num_err:=f_procesfin(v_sproces, cont_malos);
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_propio.p_predomiciliar', NULL, 'error al anular recibos', SQLERRM);
	END p_predomiciliacion;
	FUNCTION f_validar_aport_max(
			pmodo	IN	VARCHAR2,
			psseguro	IN	NUMBER,
			pnriesgo	IN	NUMBER,
			pnmovimi	IN	NUMBER,
			pfefepol	IN	DATE,
			psperson	IN	NUMBER,
			pcforpag	IN	NUMBER,
			pnrenova	IN	VARCHAR2,
			psproduc	IN	NUMBER,
			pfcarpro	IN	DATE
	) RETURN NUMBER
	IS
	BEGIN
	    RETURN 0;
	END f_validar_aport_max;
	FUNCTION f_anulacion_reemplazo(
			psseguro	IN	NUMBER,
			psreempl	IN	NUMBER,
			pcagente	IN	NUMBER DEFAULT NULL
	) RETURN NUMBER
	IS
	  /******************************************************************************************
	     Esta funci¿n implementa el circuito de anulaci¿n por reemplazo
	  ********************************************************************************************/
	  num_err          NUMBER:=0;
	  v_nriesgo        riesgos.nriesgo%TYPE;
	  v_cidioma        seguros.cidioma%TYPE;
	  v_mail           desmensaje_correo.cuerpo%TYPE;
	  v_asunto         desmensaje_correo.asunto%TYPE;
	  v_from           mensajes_correo.remitente%TYPE;
	  v_to             destinatarios_correo.direccion%TYPE;
	  v_to2            destinatarios_correo.direccion%TYPE;
	  v_error          VARCHAR2(300);
	  v_nsolicitreempl seguros.nsolici%TYPE;
	  v_nsolicit       seguros.nsolici%TYPE;
	  v_texto          VARCHAR2(300);
	  v_npoliza        seguros.npoliza%TYPE;
	  v_ncertif        seguros.ncertif%TYPE;
	  vttitulo         VARCHAR2(100);
	BEGIN
	    SELECT max(nriesgo)
	      INTO v_nriesgo
	      FROM riesgos
	     WHERE sseguro=psseguro;

	    SELECT cidioma,nsolici,npoliza,ncertif
	      INTO v_cidioma, v_nsolicit, v_npoliza, v_ncertif
	      FROM seguros
	     WHERE sseguro=psseguro;

	    num_err:=pac_correo.f_mail(21, psseguro, v_nriesgo, v_cidioma, NULL, v_mail, v_asunto, v_from, v_to, v_to2, v_error, NULL, NULL, NULL);

	    /* anotamos en la agenda poliza a reemplazar*/
	    SELECT nsolici
	      INTO v_nsolicitreempl
	      FROM seguros
	     WHERE sseguro=psreempl;

	    IF v_nsolicitreempl IS NULL THEN
	      v_texto:='Generada Solicitud Anulaci¿n por Reemplazo. N¿ Solicitud nuevo riesgo: XXXXXXXXX'
	               || '. Usuario: '
	               || f_user
	               || '. Oficina: '
	               || pcagente;
	    ELSE
	      v_texto:='Generada Solicitud Anulaci¿n por Reemplazo. N¿ Solicitud nuevo riesgo: '
	               || v_nsolicitreempl
	               || '. Usuario: '
	               || f_user
	               || '. Oficina: '
	               || pcagente;
	    END IF;

	    vttitulo:='Solicitud de anulaci¿n por reemplazo '
	              || v_nsolicitreempl;

	    /* BUG9208-28052009-XVM*/
	    num_err:=pac_agensegu.f_set_datosapunte(NULL, psseguro, NULL, vttitulo, v_texto, 5, 1, trunc(f_sysdate), trunc(f_sysdate), 0, 0);

	    IF num_err<>0 THEN
	      RETURN num_err;
	    END IF;

	    /* anotamos en la agenda poliza que reemplaza*/
	    v_texto:='Reemplaza al contrato '
	             || v_npoliza
	             || '/'
	             || v_ncertif;

	    /*BUG9208-28052009-XVM*/
	    num_err:=pac_agensegu.f_set_datosapunte(NULL, psseguro, NULL, v_asunto, v_texto, 5, 1, trunc(f_sysdate), trunc(f_sysdate), 0, 0);

	    IF num_err<>0 THEN
	      RETURN num_err;
	    END IF;

	    RETURN num_err;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'pac_propio.f_anulacion_reemplazo', 1, SQLERRM, SQLERRM);

	             RETURN 140999; /*{Error no controlat}*/
	END f_anulacion_reemplazo;
	FUNCTION f_irescate(
			psseguro	IN	NUMBER,
			pfecha	IN	DATE,
			psituac	IN	NUMBER DEFAULT 1
	) RETURN NUMBER
	IS
	  /*
	    { funci¿n que retorna el importe de la provisi¿n matematica
	     menos el importe de los recibos de gesti¿n
	    }
	  */
	  xireserva       NUMBER;
	  xigestion       NUMBER;
	  xffecmue        DATE;
	  /*     xireserva_mort NUMBER := 0;*/
	  importe         NUMBER;
	  primasaportadas NUMBER;
	  /* RSC 08/04/2008*/
	  vsproduc        seguros.sproduc%TYPE;
	BEGIN
	    xireserva:=pac_provmat_formul.f_calcul_formulas_provi(psseguro, pfecha, 'IPROVAC', NULL, NULL, psituac);

	    xigestion:=calc_rescates.frecgestion(psseguro, 2);

	    RETURN xireserva-nvl(xigestion, 0);
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, getuser, 'pac_propio.f_irescate', NULL, 'psseguro = '
	                                                                            || psseguro
	                                                                            || ' pfecha ='
	                                                                            || pfecha, SQLERRM);

	             RETURN NULL;
	END f_irescate;
	FUNCTION f_ivencimiento(
			psseguro	IN	NUMBER,
			pfecha	IN	DATE
	) RETURN NUMBER
	IS
	  /*
	    { funci¿n que retorna el importe de la provisi¿n matematica
	     menos el importe de los recibos de gesti¿n
	    }
	  */
	  xireserva      NUMBER;
	  xigestion      NUMBER;
	  xffecmue       asegurados.ffecmue%TYPE;
	  xireserva_mort NUMBER:=0;
	  /* RSC 08/04/2008*/
	  vsproduc       seguros.sproduc%TYPE;
	BEGIN
	/* Miramos si hay alg¿n asegurado fallecido. Si es as¿ el importe de rescate*/
	/* ser¿ igual al la provisi¿n actual - el 50% de la provisi¿n en el momento del*/
	/* fallecimiento del otro asegurado. El otro 50% se imputar¿ a un siniestro*/
	    /* de fallecimiento*/
	    BEGIN
	        SELECT ffecmue
	          INTO xffecmue
	          FROM asegurados
	         WHERE sseguro=psseguro AND
	               ffecmue IS NOT NULL;
	    EXCEPTION
	        WHEN no_data_found THEN
	          xffecmue:=NULL;
	        WHEN OTHERS THEN
	          RETURN NULL;
	    END;

	    SELECT sproduc
	      INTO vsproduc
	      FROM seguros
	     WHERE sseguro=psseguro;

	    IF xffecmue IS NOT NULL THEN
	    /* Miramos si ya tiene un siniestro de fallecimiento aperturado por baja de*/
	    /* 1 titular y qu¿ valoraci¿n tiene*/
	    /* Bug 9685 - APD - 11/05/2009 - en lugar de coger la actividad de la tabla seguros,*/
	    /* llamar a la funci¿n pac_seguros.ff_get_actividad*/
	    /* BUG 11595 - 03/11/2009 - APD - Adaptaci¿n al nuevo m¿dulo de siniestros*/
	      /* se a¿ade la UNION con las tablas nuevas de siniestros*/
	      FOR reg IN (SELECT to_char(s.nsinies) nsinies,cestsin,s.nasegur,s.fsinies,v.ivalora,seg.sproduc,pac_seguros.ff_get_actividad(seg.sseguro, s.nriesgo) cactivi
	                    FROM siniestros s,valorasini v,seguros seg
	                   WHERE s.sseguro=psseguro AND
	                         s.nsinies=v.nsinies AND
	                         seg.sseguro=s.sseguro AND
	                         s.ccausin=1 /* muerte*/
	                         AND
	                         s.cmotsin=4 /* baja 1 titular*/
	                         AND
	                         s.cestsin=0 /* pendiente o finalizado*/
	                         AND
	                         v.cgarant=1 /* cobertura de muerte*/
	                         AND
	                         v.fvalora=(SELECT max(fvalora)
	                                      FROM valorasini vv
	                                     WHERE vv.nsinies=v.nsinies) AND
	                         nvl(pac_parametros.f_parempresa_n(seg.cempres, 'MODULO_SINI'), 0)=0
	                  UNION
	                  SELECT s.nsinies,m.cestsin,s.nasegur,s.fsinies,v.ireserva,seg.sproduc,pac_seguros.ff_get_actividad(seg.sseguro, s.nriesgo) cactivi
	                    FROM sin_siniestro s,sin_movsiniestro m,sin_tramitacion t,sin_tramita_reserva v,seguros seg
	                   WHERE s.sseguro=psseguro AND
	                         s.nsinies=t.nsinies AND
	                         t.nsinies=v.nsinies AND
	                         t.ntramit=v.ntramit AND
	                         seg.sseguro=s.sseguro AND
	                         s.nsinies=m.nsinies AND
	                         m.nsinies=(SELECT max(nmovsin)
	                                      FROM sin_movsiniestro
	                                     WHERE nsinies=m.nsinies) AND
	                         s.ccausin=1 /* muerte*/
	                         AND
	                         s.cmotsin=4 /* baja 1 titular*/
	                         AND
	                         m.cestsin=0 /* pendiente o finalizado*/
	                         AND
	                         v.cgarant=1 /* cobertura de muerte*/
	                         AND
	                         v.ctipres=1 /* jlb - 18423#c105054*/
	                         AND
	                         v.fmovres=(SELECT max(fmovres)
	                                      FROM sin_tramita_reserva vv
	                                     WHERE vv.nsinies=v.nsinies AND
	                                           vv.ctipres=1 /* jlb - 18423#c105054*/
	                                   ) AND
	                         nvl(pac_parametros.f_parempresa_n(seg.cempres, 'MODULO_SINI'), 0)=1
	                   ORDER BY nsinies DESC) LOOP
	          /* Bug 9685 - APD - 11/05/2009 - fin*/
	          xireserva_mort:=reg.ivalora;
	      END LOOP;

	    /* Si no hay siniestro abierto calculamos la provisi¿n a fecha de fallecimiento*/
	    /* en este caso como no estamos seguros de que la formulaci¿n funcione correctamente para*/
	    /* para a¿os anteriores (sobre todo Pla d'Estalvi, Ahorro Seguro y PPA) cogemos*/
	      /* el ¿ltimo saldo calculado antes de la fecha de fallecimiento*/
	      IF xireserva_mort=0 THEN
	        xireserva_mort:=pac_provmat_formul.f_calcul_formulas_provi(psseguro, xffecmue, 'IPROVAC')/2;
	      /*xireserva_mort := round(fbuscasaldo(null, psseguro, to_CHAR(xffecmue,'yyyymmdd'))/2,2);*/
	      END IF;
	    END IF;

	    /*{calculem la reserva en aquest moment} ---------------------------------*/
	    xireserva:=pac_provmat_formul.f_calcul_formulas_provi(psseguro, pfecha, 'IPROVAC');

	    /*------------------------------------------------------------------------*/
	    /*{restem el import dels rebuts que est¿n en gesti¿ }*/
	    xigestion:=calc_rescates.frecgestion(psseguro, 2);

	    RETURN xireserva-xigestion-xireserva_mort;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, getuser, 'pac_propio.f_ivencimiento', NULL, 'psseguro = '
	                                                                                || psseguro
	                                                                                || ' pfecha ='
	                                                                                || pfecha, SQLERRM);

	             RETURN NULL;
	END f_ivencimiento;
	FUNCTION f_irendimiento(
			psseguro	IN	NUMBER,
			pfecha	IN	DATE
	) RETURN NUMBER
	IS
	  /*
	     { funci¿n que retorna el importe de la provisi¿n matematica
	      menos el importe de los recibos cobrados
	     }
	   */
	  xireserva NUMBER;
	  xicobrado NUMBER;
	BEGIN
	    /*{calculem la reserva en aquest moment}*/
	    xireserva:=pac_provi_mv.f_calculos_provmat(0, psseguro, pfecha);

	    /*{restem el import dels rebuts que est¿n en gesti¿ o cobrats}*/
	    SELECT nvl(SUM(itotalr), 0)
	      INTO xicobrado
	      FROM movrecibo m,vdetrecibos v,recibos r
	     WHERE r.sseguro=psseguro AND
	           m.nrecibo=r.nrecibo AND
	           m.nrecibo=v.nrecibo AND
	           m.fmovfin IS NULL AND
	           f_cestrec_mv(r.nrecibo, 1) IN(1, 3);

	    RETURN nvl(xireserva, 0)-xicobrado;
	END f_irendimiento;

	/*******************************************************************************
	  JTS 12/03/2009
	  Funci¿ que genera el text d'un rebut rebut per par¿metre
	*******************************************************************************/
	FUNCTION f_trecibo_aux(
			 pnrecibo	IN	NUMBER,
			 pcidioma	IN	NUMBER,
			 ptlin1	OUT	VARCHAR2,
			 ptlin2	OUT	VARCHAR2,
			 ptlin3	OUT	VARCHAR2,
			 ptlin4	OUT	VARCHAR2,
			 ptlin5	OUT	VARCHAR2,
			 ptlin6	OUT	VARCHAR2,
			 ptlin7	OUT	VARCHAR2,
			 ptlin8	OUT	VARCHAR2
	)   RETURN NUMBER
	IS
	  v_npoliza seguros.npoliza%TYPE;
	  v_validez VARCHAR2(40);
	  v_producto titulopro.ttitulo%TYPE;
	  v_asegurado VARCHAR2(40);
	  v_fpago detvalores.tatribu%TYPE;
	  v_agrupacion seguros.cagrpro%TYPE;
	  v_lit1  VARCHAR2(400);
	  v_lit2  VARCHAR2(400);
	  v_lit3  VARCHAR2(400);
	  v_lit4  VARCHAR2(400);
	  v_lit5  VARCHAR2(400);
	  v_lit6  VARCHAR2(400);
	  v_lit7  VARCHAR2(400);
	  v_lit8  VARCHAR2(400);
	  v_lit9  VARCHAR2(400);
	  v_lit10 VARCHAR2(400);
	  v_lit11 VARCHAR2(400);
	  v_lit12 VARCHAR2(400);
	  v_lit13 VARCHAR2(400);
	  efecto recibos.fefecto%TYPE;
	  pseguro seguros.sseguro%TYPE;
	  vsproduc seguros.sproduc%TYPE;
	  saldoant NUMBER;
	  saldoact NUMBER;
	  apor     NUMBER;
	  v_fcaranu seguros.fcaranu%TYPE;
	  cont NUMBER;
	  /*     v_capital      VARCHAR2(100);*/
	  /* 59. 0027750 LCOL_A003-Error en cargue de archivo de respuesta debito automatico (VISA) - QT-6189 - Inicio*/
	  /* Se cambian los tipos de las siguientes variables para dejarlas como un VARCHAR2(100), como estaban antes*/
	  /*v_prima, v_icons, v_iclea, v_ips, v_rec*/
	  v_prima VARCHAR2(100);
	  v_icons VARCHAR2(100);
	  v_ips   VARCHAR2(100);
	  v_iclea VARCHAR2(100);
	  v_rec   VARCHAR2(100);
	  /* 59. 0027750 LCOL_A003-Error en cargue de archivo de respuesta debito automatico (VISA) - QT-6189 - Final*/
	  v_itotalr vdetrecibos.itotalr%TYPE;
	  v_itotimp vdetrecibos.itotimp%TYPE;
	  v_itotcon vdetrecibos.itotcon%TYPE;
	  /*v_prima        vdetrecibos.itotpri%TYPE;*/
	  /*     v_impuestos    VARCHAR2(100);*/
	  /*     v_consorcio    VARCHAR2(100);*/
	  /*     v_numpol       VARCHAR2(15);*/
	  v_ncertif seguros.ncertif%TYPE;
	  v_fvencim_rec recibos.fvencim%TYPE;
	  /*     v_valpar       NUMBER(1);*/
	  /*      v_retval       NUMBER;*/
	  /*BUG 9402 - 12/03/2009 - JTS*/
	  /*v_icons        vdetrecibos.iconsor%TYPE;*/
	  /*v_ips          vdetrecibos.iips%TYPE;*/
	  /*v_iclea        vdetrecibos.idgs%TYPE;*/
	  /*v_rec          vdetrecibos.irecfra%TYPE;*/
	  v_t1 VARCHAR2(40);
	  v_t2 VARCHAR2(40);
	  v_t3 VARCHAR2(40);
	  v_t4 VARCHAR2(40);
	  v_t5 VARCHAR2(40);
	  /*Fi BUG 9402*/
	  cta_lineas NUMBER;
	  v_numerr   NUMBER;
	  /* BUG14071:DRA:19/04/2010*/
	CURSOR c_garantias(psseguro
	IN    NUMBER,
	fecha IN
	DATE)

	  IS
	    /* Bug 9685 - APD - 11/05/2009 - en lugar de coger la actividad de la tabla seguros,*/
	    /* llamar a la funci¿n pac_seguros.ff_get_actividad*/
	    SELECT   tgarant,
	             icaptot,
	             s.cramo,
	             s.cmodali,
	             s.ctipseg,
	             s.ccolect,
	             pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo) cactivi,
	             g.cgarant
	    FROM     garanseg g,
	             garangen gg,
	             seguros s
	    WHERE    g.sseguro = psseguro
	    AND      g.sseguro = s.sseguro
	    AND      g.cgarant = gg.cgarant
	    AND      gg.cidioma = pcidioma
	    AND      g.finiefe <= fecha
	    AND     (
	                      g.ffinefe > fecha
	             OR       g.ffinefe IS NULL)
	    AND      nriesgo = 1
	    ORDER BY g.cgarant;

	/* Bug 9685 - APD - 11/05/2009 - fin*/
	FUNCTION f_periodo_recibo(
			pnrecibo	IN	NUMBER,
			 pcidioma	IN	NUMBER
	)   RETURN VARCHAR2
	IS
	  v_periodo VARCHAR2(100);
	  v_agr seguros.cagrpro%TYPE;
	  v_lit1 VARCHAR2(400);
	  v_lit2 VARCHAR2(400);
	  v_lit3 VARCHAR2(400);
	  v_lit4 VARCHAR2(400);
	  /*LOS RAMOS DE AHORRO SOLO DEBEN MOSTRAR LA FECHA DE EFECTO, Y LOS DE RIESGO LA VALIDEZ*/
	BEGIN
	  BEGIN
	    SELECT cagrpro
	    INTO   v_agr
	    FROM   recibos r,
	           seguros s
	    WHERE  r.nrecibo = pnrecibo
	    AND    s.sseguro = r.sseguro;

	  EXCEPTION
	  WHEN OTHERS THEN
	    p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_trecibo.f_periodo_recibo', 1, 'pnrecibo: '
	    || pnrecibo
	    || ' pcidioma: '
	    || pcidioma, SQLCODE
	    || '-'
	    || SQLERRM);
	    NULL;
	  END;
	  BEGIN
	    /* Literales fijos*/
	    v_lit1 := f_axis_literales(105280, pcidioma); -- 'Periodo: '
	    v_lit2 := f_axis_literales(112475, pcidioma);
	    /* 'Fecha de efecto: '*/
	    v_lit3 := f_axis_literales(180821, pcidioma);
	    /* 'Aseguran¿a de Renda Vitalicia'*/
	    v_lit4 := f_axis_literales(9000636, pcidioma); -- 'VALIDEZ
	    IF v_agr = 1 THEN
	      /* RIESGO / VIDA*/
	      SELECT v_lit1
	                    || ' '
	                    || to_char(fefecto, 'DD/MM/YYYY')
	                    || ' a: '
	                    || to_char(fvencim, 'DD/MM/YYYY')
	      INTO   v_periodo
	      FROM   recibos
	      WHERE  nrecibo = pnrecibo;

	    ELSIF v_agr = 2 THEN
	      /* AHORRO*/
	      SELECT v_lit2
	                    || ' '
	                    || to_char(fefecto, 'DD/MM/YYYY')
	      INTO   v_periodo
	      FROM   recibos
	      WHERE  nrecibo = pnrecibo;

	    ELSIF v_agr = 10 THEN
	      /* RENTA PLUS*/
	      v_periodo := v_lit3;
	    ELSE
	      v_periodo := v_lit4
	      || ' *****************';
	    END IF;
	    /*v_periodo := REPLACE (v_periodo, CHR (39), CHR (39) || CHR (39));*/
	    RETURN v_periodo;
	  EXCEPTION
	  WHEN OTHERS THEN
	    p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_trecibo.f_periodo_recibo', 2, 'pnrecibo: '
	    || pnrecibo
	    || ' pcidioma: '
	    || pcidioma, SQLCODE
	    || '-'
	    || SQLERRM);
	    RETURN NULL;
	  END;
	END f_periodo_recibo;
	BEGIN
	  IF pnrecibo IS NOT NULL
	    AND
	    pcidioma IS NOT NULL THEN
	    /* Seleccion de valores:*/
	    BEGIN
	      /* Bug 0012803 - 19/02/2010 - JMF: Vista personas*/
	      /* Bug 0012803 - 26/03/2010 - JMF: Vista personas*/
	      SELECT s.sproduc,
	             s.sseguro,
	             s.cagrpro,
	             t.ttitulo,
	             (
	                    SELECT tatribu
	                    FROM   detvalores
	                    WHERE  catribu = r.cforpag
	                    AND    cidioma = pcidioma
	                    AND    cvalor = 17),
	             s.npoliza,
	             NULL,
	             /*       Pac_Isqlfor.f_periodo_recibo(pnrecibo),*/
	             substr(p.tnombre
	                    || ' '
	                    || p.tapelli1
	                    || ' '
	                    || p.tapelli2, 1, 40),
	             r.fefecto,
	             s.fcaranu,
	             nvl(v.itotalr, 0),
	             nvl(v.itotimp, 0),
	             nvl(v.itotcon, 0),
	             s.ncertif,
	             r.fvencim
	      INTO   vsproduc,
	             pseguro,
	             v_agrupacion,
	             v_producto,
	             v_fpago,
	             v_npoliza,
	             v_validez,
	             v_asegurado,
	             efecto,
	             v_fcaranu,
	             v_itotalr,
	             v_itotimp,
	             v_itotcon,
	             v_ncertif,
	             v_fvencim_rec
	      FROM   titulopro t,
	             seguros s,
	             recibos r,
	             asegurados a,
	             per_detper p,
	             empresas,
	             vdetrecibos v
	      WHERE  s.cramo = t.cramo
	      AND    s.cmodali = t.cmodali
	      AND    s.ctipseg = t.ctipseg
	      AND    s.ccolect = t.ccolect
	      AND    s.sseguro = r.sseguro
	      AND    s.sseguro = a.sseguro
	      AND    a.sperson = p.sperson
	      AND    p.cagente = ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres)
	      AND    empresas.cempres = s.cempres
	      AND    a.norden = 1
	             /*> Solo sale el primer asegurado*/
	      AND    t.cidioma = pcidioma
	      AND    v.nrecibo = r.nrecibo
	      AND    r.nrecibo = pnrecibo;

	    EXCEPTION
	    WHEN OTHERS THEN
	      p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_trecibo', 1, 'pnrecibo: '
	      || pnrecibo
	      || ' pcidioma: '
	      || pcidioma, SQLCODE
	      || '-'
	      || SQLERRM);
	    END;
	    /* Composicion de la lineas*/
	    BEGIN
	      /* Literales fijos*/
	      /* BUG14071:DRA:19/04/2010:Inici*/
	      /* v_lit1 := f_axis_literales(102829, pcidioma);   --> n¿ poliza (102829)*/
	      v_numerr := f_caracter_esp(f_axis_literales(102829, pcidioma), v_lit1);
	      /* BUG14071:DRA:19/04/2010:Fi*/
	      v_lit2 := f_axis_literales(100864, pcidioma);
	      /*> n¿ recibo (100864)*/
	      v_lit3 := f_axis_literales(101371, pcidioma);
	      /*> Asegurado (101371)*/
	      v_lit4 := f_axis_literales(102719, pcidioma);
	      /*> Forma de pago (102719)*/
	      v_lit5 := f_axis_literales(100681, pcidioma);
	      /*> Producto (100681)*/
	      v_lit6 := f_axis_literales(112616, pcidioma);
	      /*>CERTIFICADO INDIVIDUAL*/
	      v_lit7 := f_axis_literales(112372, pcidioma);
	      /*>GARANTIAS:*/
	      v_lit8 := f_axis_literales(111796, pcidioma);
	      /*>COBERTURA:*/
	      v_lit9 := f_axis_literales(140773, pcidioma);
	      /*>HASTA*/
	      v_lit10 := f_axis_literales(152341, pcidioma);
	      /*>PRIMA MENSUAL*/
	      v_lit11 := f_axis_literales(109989, pcidioma);
	      /*>IMPUESTOS:*/
	      v_lit12 := f_axis_literales(102707, pcidioma);
	      /*>POLIZA COLECTIVA*/
	      v_lit13 := f_axis_literales(100936, pcidioma);
	      /*>CONSORCIO:*/
	      /*    p_literal2(112475, pcidioma, v_lit6); --> Fecha de efecto (112475)*/
	      /*    p_literal2(151338, pcidioma, v_lit7); --> Periodo de cobertura (151338)*/
	      /* Lineas del recibo*/
	      IF v_agrupacion = 11 THEN
	        ptlin1 := v_producto;
	        saldoant := f_saldo_pp(pseguro, to_date('31/12/'
	        || to_char(add_months(efecto - 1, -12), 'yyyy'), 'dd/mm/yyyy'), 1);
	        IF saldoant = -1 THEN
	          saldoant := 0;
	        END IF;
	        ptlin2 := 'DERECHOS CONSOLIDADOS AL 31-12-'
	        || to_char(add_months(efecto - 1, -12), 'YYYY')
	        || lpad(to_char(nvl(saldoant, 0), 'FM999G999G990D00')
	        || ' EUR', 23, ' ');
	        apor := pac_tfv.f_aportaciones_anuales_pp(pseguro, to_number(to_char(efecto, 'yyyy')), efecto);
	        IF apor = -1 THEN
	          apor := 0;
	        END IF;
	        ptlin3 := 'APORTACIONES AL '
	        || to_char(efecto, 'DD-MM-YYYY')
	        || lpad(to_char(nvl(apor, 0), 'FM999G999G990D00')
	        || ' EUR', 32, ' ');
	        saldoact := f_saldo_pp(pseguro, efecto - 1, 1);
	        IF saldoact = -1 THEN
	          saldoact := 0;
	        END IF;
	        ptlin4 := 'DERECHOS CONSOLIDADOS AL '
	        || to_char(efecto - 1, 'DD-MM-YYYY')
	        || lpad(to_char(nvl(saldoact, 0), 'FM999G999G990D00')
	        || ' EUR', 23, ' ');
	      ELSIF v_agrupacion = 1 THEN
	        /*Bug 9402 - 12/03/2009 - JTS - Nou format per a CIV*/
	        SELECT decode(ltrim(to_char(v.iconsor, '999990D00')),
	                      '0,00', '',
	                      ltrim(to_char(v.iconsor, '999990D00'))) "PAR_ICONS",
	               decode(ltrim(to_char(v.iips, '999990D00')),
	                      '0,00', '',
	                      ltrim(to_char(v.iips, '999990D00'))) "PAR_IPS",
	               decode(ltrim(to_char(v.idgs, '999990D00')),
	                      '0,00', '',
	                      ltrim(to_char(v.idgs, '999990D00'))) "PAR_ICLEA",
	               decode(ltrim(to_char(v.irecfra, '999990D00')),
	                      '0,00', '',
	                      ltrim(to_char(v.irecfra, '999990D00'))) "PAR_REC",
	               decode(ltrim(to_char(v.itotpri, '999990D00')),
	                      '0,00', '',
	                      ltrim(to_char(v.itotpri, '999990D00'))) "PAR_PRIMA"
	        INTO   v_icons,
	               v_ips,
	               v_iclea,
	               v_rec,
	               v_prima
	        FROM   vdetrecibos v
	        WHERE  v.nrecibo = pnrecibo;

	        v_lit6 := f_axis_literales(102003, pcidioma);
	        /*> Prima*/
	        v_lit7 := f_axis_literales(102832, pcidioma);
	        /*> Consorcio*/
	        v_lit8 := f_axis_literales(801270, pcidioma);
	        /*> CLEA*/
	        v_lit9 := f_axis_literales(103395, pcidioma);
	        /*> IPS*/
	        /* BUG14071:DRA:19/04/2010:Inici*/
	        /* v_lit10 := f_axis_literales(180270, pcidioma);   --> REC*/
	        v_numerr := f_caracter_esp(f_axis_literales(180270, pcidioma), v_lit10);
	        /* BUG14071:DRA:19/04/2010:Fi*/
	        SELECT decode(v_prima,
	                      NULL, NULL,
	                      rpad(ltrim(v_lit6)
	                             || ' '
	                             || v_prima, 40, ' ')),
	               decode(v_icons,
	                      NULL, NULL,
	                      rpad(ltrim(v_lit7)
	                             || ' '
	                             || v_icons, 40, ' ')),
	               decode(v_iclea,
	                      NULL, NULL,
	                      rpad(v_lit8
	                             || ': '
	                             || v_iclea, 40, ' ')),
	               decode(v_ips,
	                      NULL, NULL,
	                      rpad(v_lit9
	                             || ' '
	                             || v_ips, 40, ' ')),
	               decode(v_rec,
	                      NULL, NULL,
	                      rpad(v_lit10
	                             || ' '
	                             || v_rec, 40, ' '))
	        INTO   v_prima,
	               v_icons,
	               v_iclea,
	               v_ips,
	               v_rec
	        FROM   dual;

	        DECLARE
	          /* Asignaci¿n de v_t1..v_t5 para informar solo mayores de ZERO i en orden de v_t1 hacia v_t5.*/
	          v_conta NUMBER(1) := 1;
	        BEGIN
	          IF v_prima IS NOT NULL THEN
	            v_t1 := trim(v_prima);
	            v_conta := v_conta + 1;
	          END IF;
	          IF v_icons IS NOT NULL THEN
	            IF v_conta = 1 THEN
	              v_t1 := trim(v_icons);
	            END IF;
	            IF v_conta = 2 THEN
	              v_t2 := trim(v_icons);
	            END IF;
	            v_conta := v_conta + 1;
	          END IF;
	          IF v_iclea IS NOT NULL THEN
	            IF v_conta = 1 THEN
	              v_t1 := trim(v_iclea);
	            END IF;
	            IF v_conta = 2 THEN
	              v_t2 := trim(v_iclea);
	            END IF;
	            IF v_conta = 3 THEN
	              v_t3 := trim(v_iclea);
	            END IF;
	            v_conta := v_conta + 1;
	          END IF;
	          IF v_ips IS NOT NULL THEN
	            IF v_conta = 1 THEN
	              v_t1 := trim(v_ips);
	            END IF;
	            IF v_conta = 2 THEN
	              v_t2 := trim(v_ips);
	            END IF;
	            IF v_conta = 3 THEN
	              v_t3 := trim(v_ips);
	            END IF;
	            IF v_conta = 4 THEN
	              v_t4 := trim(v_ips);
	            END IF;
	            v_conta := v_conta + 1;
	          END IF;
	          IF v_rec IS NOT NULL THEN
	            IF v_conta = 1 THEN
	              v_t1 := trim(v_rec);
	            END IF;
	            IF v_conta = 2 THEN
	              v_t2 := trim(v_rec);
	            END IF;
	            IF v_conta = 3 THEN
	              v_t3 := trim(v_rec);
	            END IF;
	            IF v_conta = 4 THEN
	              v_t4 := trim(v_rec);
	            END IF;
	            IF v_conta = 5 THEN
	              v_t5 := trim(v_rec);
	            END IF;
	          END IF;
	        END;
	        ptlin1 := rpad(v_lit1
	        || ' '
	        || v_npoliza, 40, ' ')
	        || rpad(v_lit2
	        || ' '
	        || pnrecibo, 40, ' ');
	        ptlin2 := rpad(v_lit5
	        || ' '
	        || v_producto, 40, ' ')
	        || rpad(v_lit4
	        || ' '
	        || v_fpago, 40, ' ');
	        ptlin3 := rpad(v_lit3
	        || ' '
	        || v_asegurado, 40, ' ');
	        ptlin4 := rpad(f_periodo_recibo(pnrecibo, pcidioma), 40, ' ')
	        || rpad(v_t1, 40, ' ');
	        ptlin5 := rpad(v_t2, 40, ' ')
	        || rpad(v_t3, 40, ' ');
	        ptlin6 := rpad(v_t4, 40, ' ')
	        || rpad(v_t5, 40, ' ');
	        ptlin7 := NULL;
	        /*Fi bug 9402 - JTS - 12/03/2009*/
	      ELSE
	        ptlin1 := rpad(v_lit1
	        || ' '
	        || v_npoliza, 40, ' ')
	        || rpad(v_lit2
	        || ' '
	        || pnrecibo, 40, ' ');
	        ptlin2 := rpad(v_lit5
	        || ' '
	        || v_producto, 40, ' ')
	        || rpad(v_lit4
	        || ' '
	        || v_fpago, 40, ' ');
	        ptlin3 := rpad(v_lit3
	        || ' '
	        || v_asegurado, 40, ' ');
	        /*ptlin4 := v_validez;*/
	        ptlin4 := f_periodo_recibo(pnrecibo, pcidioma);
	      END IF;
	      /* Bug 10838 inicio*/
	      /*               IF vsproduc IN(41, 42) THEN
	SELECT mensaje
	INTO ptlin7
	FROM mensarecibos
	WHERE mensarecibos.sproduc = vsproduc
	AND cidioma = pcidioma
	AND nlinea = 1;
	SELECT mensaje
	INTO ptlin8
	FROM mensarecibos
	WHERE mensarecibos.sproduc = vsproduc
	AND cidioma = pcidioma
	AND nlinea = 2;
	ELSE
	SELECT mensaje
	INTO ptlin8
	FROM mensarecibos
	WHERE mensarecibos.sproduc = vsproduc
	AND cidioma = pcidioma
	AND nlinea = 1;
	END IF;*/
	      SELECT count(*)
	      INTO   cta_lineas
	      FROM   mensarecibos
	      WHERE  mensarecibos.sproduc = vsproduc
	      AND    cidioma = pcidioma;

	      IF cta_lineas = 2 THEN
	        SELECT mensaje
	        INTO   ptlin7
	        FROM   mensarecibos
	        WHERE  mensarecibos.sproduc = vsproduc
	        AND    cidioma = pcidioma
	        AND    nlinea = 1;

	        SELECT mensaje
	        INTO   ptlin8
	        FROM   mensarecibos
	        WHERE  mensarecibos.sproduc = vsproduc
	        AND    cidioma = pcidioma
	        AND    nlinea = 2;

	      ELSIF cta_lineas = 1 THEN
	        SELECT mensaje
	        INTO   ptlin8
	        FROM   mensarecibos
	        WHERE  mensarecibos.sproduc = vsproduc
	        AND    cidioma = pcidioma
	        AND    nlinea = 1;

	      END IF;
	      /* Bug 10838 fin*/
	      RETURN 0;
	    EXCEPTION
	    WHEN OTHERS THEN
	      p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_trecibo_aux', 2, 'pnrecibo: '
	      || pnrecibo
	      || ' pcidioma: '
	      || pcidioma, SQLCODE
	      || '-'
	      || SQLERRM);
	      RETURN 1;
	    END;
	  END IF;
	  RETURN 0;
	END f_trecibo_aux;
	/***********************************************************************
	FUNCTION f_trecibo
	Devuelve las lineas para la domicilaci¿n de recibos
	Bug 19837/95292 24/10/2011 - AMC
	***********************************************************************/
	FUNCTION f_trecibo(
			pnrecibo	IN	NUMBER,
			pcidioma	IN	NUMBER,
			ptlin1	OUT	VARCHAR2,
			ptlin2	OUT	VARCHAR2,
			ptlin3	OUT	VARCHAR2,
			ptlin4	OUT	VARCHAR2,
			ptlin5	OUT	VARCHAR2,
			ptlin6	OUT	VARCHAR2,
			ptlin7	OUT	VARCHAR2,
			ptlin8	OUT	VARCHAR2
	) RETURN NUMBER
	IS
	  v_ss      VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_retorno NUMBER;
	  /**/
	  vtlin1    VARCHAR2(80);
	  vtlin2    VARCHAR2(80);
	  vtlin3    VARCHAR2(80);
	  vtlin4    VARCHAR2(80);
	  vtlin5    VARCHAR2(80);
	  vtlin6    VARCHAR2(80);
	  vtlin7    VARCHAR2(80);
	  vtlin8    VARCHAR2(80);
	  /**/
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	  /* Se debe declarar el componente*/
	  v_cempres seguros.cempres%TYPE;
	BEGIN
	    BEGIN
	        SELECT s.cempres
	          INTO v_cempres
	          FROM seguros s,recibos r
	         WHERE r.nrecibo=pnrecibo AND
	               s.sseguro=r.sseguro;
	    EXCEPTION
	        WHEN OTHERS THEN
	          RETURN 0; /* si no la encontramos no esta reducida*/
	    END;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    v_ss:='DECLARE vtlin1 varchar2(80); vtlin2 varchar2(80); vtlin3 varchar2(80); vtlin4 varchar2(80);'
	          || ' vtlin5 varchar2(80); vtlin6 varchar2(80); vtlin7 varchar2(80); vtlin8 varchar2(80);'
	          || ' BEGIN '
	          || ' :v_retorno := '
	          || v_propio
	          || '.'
	          || 'f_trecibo('''
	          || pnrecibo
	          || ''','
	          || pcidioma
	          || ',:vtlin1, :vtlin2, :vtlin3, :vtlin4, :vtlin5, :vtlin6, :vtlin7, :vtlin8 )'
	          || ';'
	          || 'END;';

	    EXECUTE IMMEDIATE v_ss
	    USING OUT v_retorno, OUT ptlin1, OUT ptlin2, OUT ptlin3, OUT ptlin4, OUT ptlin5, OUT ptlin6, OUT ptlin7, OUT ptlin8;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	           /*  Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada*/
	           /*  a una funci¿n, procedimiento, etc. inexistente o no declarado.*/
	             /* Si la funci¿n no existe para la empresa, llamamos a la F_CONTADOR gen¿rica*/
	             RETURN f_trecibo_aux(pnrecibo, pcidioma, ptlin1, ptlin2, ptlin3, ptlin4, ptlin5, ptlin6, ptlin7, ptlin8); WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_trecibo', 2, 'pnrecibo: '
	                                                                       || pnrecibo
	                                                                       || ' pcidioma: '
	                                                                       || pcidioma, SQLCODE
	                                                                                    || '-'
	                                                                                    || SQLERRM);

	             RETURN 140999; /* Error no controlado*/
	END f_trecibo;

	/*******************************************************************************
	  Bug 9794 - YIL - 21/04/2009
	  Funci¿n calcula los impuestos y recargos a restar al l¿mite anual de prima.
	*******************************************************************************/
	FUNCTION f_restar_limite_anual(
			ptablas	IN	VARCHAR2,
			psseguro	IN	NUMBER,
			pcgarant	IN	NUMBER,
			plimite	IN	NUMBER,
			pfecha	IN	DATE,
			imp_restar	OUT	NUMBER,
			pforfait	IN	NUMBER DEFAULT 1
	) RETURN NUMBER
	IS
	  v_sproduc     productos.sproduc%TYPE;
	  v_crecfra     seguros.crecfra%TYPE;
	  v_cramo       productos.cramo%TYPE;
	  v_cmodali     productos.cmodali%TYPE;
	  v_ctipseg     productos.cmodali%TYPE;
	  v_ccolect     productos.ccolect%TYPE;
	  v_fecha       DATE;
	  v_cforpag     seguros.cforpag%TYPE;
	  v_cforpag_aux seguros.cforpag%TYPE;
	  v_ctipcon     imprec.ctipcon%TYPE;
	  v_nvalcon     imprec.nvalcon%TYPE;
	  v_cfracci     imprec.cfracci%TYPE;
	  v_cbonifi     imprec.cbonifi%TYPE;
	  tasas         imprec.nvalcon%TYPE;
	  num_err       NUMBER;
	  recfrac       imprec.nvalcon%TYPE;
	  v_fefecto     seguros.fefecto%TYPE;
	  v_traza       NUMBER;
	  v_cforfait    NUMBER;
	  v_iforfait    NUMBER;
	  itasas        NUMBER;
	  irecfrac      NUMBER;
	  error EXCEPTION;
	  x_crecfra     seguros.crecfra%TYPE;
	  /* Bug 10864.NMM.01/08/2009.*/
	  w_climit      NUMBER;
	  v_cmonimp     imprec.cmoneda%TYPE;
	  /* BUG 18423 - LCOL000 - Multimoneda*/
	  vcderreg      NUMBER; /* Bug 0020314 - FAL - 29/11/2011*/
	BEGIN
	    v_traza:=1;

	    IF ptablas='EST' THEN BEGIN
	          SELECT sproduc,crecfra,cforpag,fefecto
	            INTO v_sproduc, v_crecfra, v_cforpag, v_fefecto
	            FROM estseguros
	           WHERE sseguro=psseguro;
	      EXCEPTION
	          WHEN OTHERS THEN
	            num_err:=101919; /* Error al leer datos de la tabla SEGUROS*/

	            RAISE error;
	      END;
	    ELSE BEGIN
	          SELECT sproduc,crecfra,cforpag,fefecto
	            INTO v_sproduc, v_crecfra, v_cforpag, v_fefecto
	            FROM seguros
	           WHERE sseguro=psseguro;
	      EXCEPTION
	          WHEN OTHERS THEN
	            num_err:=101919; /* Error al leer datos de la tabla SEGUROS*/

	            RAISE error;
	      END;
	    END IF;

	    /* El l¿mite establecido es con impuestos, tasas y forfait. Hay que descontarlo*/
	    v_traza:=2;

	    /* Recuperamos las tasas a aplicar*/
	    num_err:=f_def_producto(v_sproduc, v_cramo, v_cmodali, v_ctipseg, v_ccolect);

	    num_err:=f_concepto(5, 2, pfecha, v_cforpag, v_cramo, v_cmodali, v_ctipseg, v_ccolect, 0, pcgarant, v_ctipcon, v_nvalcon, v_cfracci, v_cbonifi, x_crecfra, w_climit, /* Bug 10864.NMM.01/08/2009.*/
	             v_cmonimp, /* BUG 18423 - LCOL000 - Multimoneda*/
	             vcderreg); /* Bug 0020314 - FAL - 29/11/2011*/

	    tasas:=v_nvalcon;

	    v_traza:=3;

	    /* Recuperamos el recargo por fraccionamiento*/
	    IF v_crecfra<>0 THEN
	      num_err:=f_concepto(8, 2, pfecha, v_cforpag, v_cramo, v_cmodali, v_ctipseg, v_ccolect, 0, pcgarant, v_ctipcon, v_nvalcon, v_cfracci, v_cbonifi, x_crecfra, w_climit, /* Bug 10864.NMM.01/08/2009.*/
	               v_cmonimp, /* BUG 18423 - LCOL000 - Multimoneda*/
	               vcderreg); /* Bug 0020314 - FAL - 29/11/2011*/

	      IF x_crecfra<>0 THEN
	        recfrac:=v_nvalcon;
	      ELSE
	        recfrac:=0;
	      END IF;
	    ELSE
	      recfrac:=0;
	    END IF;

	    v_traza:=4;

	    /* Recuperamos el forfait*/
	    IF ptablas='EST' THEN
	      SELECT decode(min(cgarant), 2116, 1,
	                                  0)
	        INTO v_cforfait
	        FROM estgaranseg
	       WHERE sseguro=psseguro AND
	             cgarant=2116 /* garant¿a forfait*/
	             AND
	             ffinefe IS NULL
	             /* BUG 10231 - 30/06/2009 - SMF - Correcci¿n l¿mite de aportaciones en productos fiscales --INI*/
	             AND
	             cobliga=1
	      /* BUG 10231.fi.*/
	      ;
	    ELSE
	      SELECT decode(min(cgarant), 2116, 1,
	                                  0)
	        INTO v_cforfait
	        FROM garanseg
	       WHERE sseguro=psseguro AND
	             cgarant=2116 /* garant¿a forfait*/
	             AND
	             ffinefe IS NULL;
	    END IF;

	    v_traza:=5;

	    /* BUG 10231 - 30/06/2009 - SMF - Correcci¿n l¿mite de aportaciones en productos fiscales --INI*/
	    /* Bug 10350 - 13/07/2009 - RSC - Detalle de garant¿as (Tarificaci¿n)*/
	    /* Se a¿ade par¿metro pforfait*/
	    IF nvl(v_cforfait, 0)=0  OR
	       pforfait=0 THEN /* no aplican forfait*/
	    /* BUG 10231.fi.*/
	      /* Fin Bug 10350*/
	      v_iforfait:=0;
	    ELSE
	      v_iforfait:=f_gettramo1(v_fefecto, vtramo(NULL, 1580, v_sproduc), v_cforpag);
	    END IF;

	    /* BUG 00000 - 30/06/2009 - SMF - Correcci¿n l¿mite de aportaciones en productos fiscales --FIN*/
	    IF v_cforpag=0 THEN
	      v_cforpag_aux:=1;
	    ELSE
	      v_cforpag_aux:=v_cforpag;
	    END IF;

	    itasas:=round(plimite-(plimite/(1+tasas/100)), 2);

	    irecfrac:=round(plimite-itasas-((plimite-itasas)/(1+recfrac/100)), 2);

	    /*BUG 10231 - 27/05/2009 - ETM --antes
	    imp_restar := itasas - irecfrac - v_iforfait;*/
	    imp_restar:=itasas+irecfrac+v_iforfait;

	    RETURN 0;
	EXCEPTION
	  WHEN error THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_restar_limite_anual', 1, 'psseguro: '
	                                                                                   || psseguro
	                                                                                   || '; pcgarant: '
	                                                                                   || pcgarant
	                                                                                   || '; plimite: '
	                                                                                   || plimite
	                                                                                   || '; pfecha : '
	                                                                                   || pfecha, SQLCODE
	                                                                                              || '-'
	                                                                                              || SQLERRM);

	             RETURN num_err; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_restar_limite_anual', 2, 'psseguro: '
	                                                                                   || psseguro
	                                                                                   || '; pcgarant: '
	                                                                                   || pcgarant
	                                                                                   || '; plimite: '
	                                                                                   || plimite
	                                                                                   || '; pfecha : '
	                                                                                   || pfecha, SQLCODE
	                                                                                              || '-'
	                                                                                              || SQLERRM);

	             RETURN 140999; /* Error no controlado*/
	END f_restar_limite_anual;

	/*************************************************************************
	   f_inscta_prov_cap_det: Inserta los detalles de CTASEGURO
	   Param IN psseguro: Seguro
	   Param IN pfecha: Fecha
	   Param IN pfechaContable: Fecha Contable
	   Param IN pnumLinea: Numero de linea
	   Param IN pmodo : Modo ('P'revio o 'R'eal)
	   Param IN ppsproces : Proceso
	   Param IN pffecmov : Fecha efecto movimiento (puede ser nulo)
	   return : 0 Si todo ha ido bien, si no el c¿digo de error
	****************************************************************************************/
	/* Bug 0009172 - JRH - 01/05/2009 - Nueva Funci¿n : Bug 0009172: CRE055 - Rentas regulares e irregulares con c¿lculos a partir de renta*/
	FUNCTION f_inscta_prov_cap_det(
			psseguro	IN	NUMBER,
			pfecha	IN	DATE,
			pfechacontable	IN	DATE,
			pnumlinea	IN	NUMBER,
			pmodo	IN	VARCHAR2,
			ppsproces	IN	NUMBER,
			pffecmov	IN	DATE DEFAULT NULL
	) RETURN NUMBER
	IS
	  verr   NUMBER:=0;
	  vpm    NUMBER;
	  vcampo codcampo.ccampo%TYPE;
	BEGIN
	    vcampo:='PROVACX';

	    vpm:=pac_provmat_formul.f_calcul_formulas_provi(psseguro, pfecha, vcampo);

	    IF vpm IS NOT NULL AND
	       vpm>=0 THEN
	      verr:=pac_ctaseguro.f_insctasegurodetalle(psseguro, pfechacontable, pnumlinea, vcampo, vpm, pmodo, ppsproces);

	      IF verr<>0 THEN
	        RETURN verr;
	      END IF;
	    ELSE
	      RETURN 151377;
	    END IF;

	    vcampo:='PROVACY';

	    vpm:=pac_provmat_formul.f_calcul_formulas_provi(psseguro, pfecha, vcampo);

	    IF vpm IS NOT NULL AND
	       vpm>=0 THEN
	      verr:=pac_ctaseguro.f_insctasegurodetalle(psseguro, pfechacontable, pnumlinea, vcampo, vpm, pmodo, ppsproces);

	      IF verr<>0 THEN
	        RETURN verr;
	      END IF;
	    ELSE
	      RETURN 151377;
	    END IF;

	    vcampo:='PROVACXY';

	    vpm:=pac_provmat_formul.f_calcul_formulas_provi(psseguro, pfecha, vcampo);

	    IF vpm IS NOT NULL THEN
	      verr:=pac_ctaseguro.f_insctasegurodetalle(psseguro, pfechacontable, pnumlinea, vcampo, vpm, pmodo, ppsproces);

	      IF verr<>0 THEN
	        RETURN verr;
	      END IF;
	    ELSE
	      RETURN 151377;
	    END IF;

	    vcampo:='PROVACR';

	    vpm:=pac_provmat_formul.f_calcul_formulas_provi(psseguro, pfecha, vcampo);

	    IF vpm IS NOT NULL AND
	       vpm>=0 THEN
	      verr:=pac_ctaseguro.f_insctasegurodetalle(psseguro, pfechacontable, pnumlinea, vcampo, vpm, pmodo, ppsproces);

	      IF verr<>0 THEN
	        RETURN verr;
	      END IF;
	    ELSE
	      RETURN 151377;
	    END IF;

	    RETURN 0;
	END f_inscta_prov_cap_det;

	/*************************************************************************
	   FUNCTION f_esta_reducida
	     Indica si una p¿liza esta o no reducida.

	   param in psseguro  : Identificador de seguro.
	   return             : NUMBER (1 --> Reducida / 0 --> No reducida)
	*************************************************************************/
	/* Bug 10468 - 01/06/2009 - RSC - APR - polizas con garantias reducidas*/
	FUNCTION f_esta_reducida(
			psseguro	IN	NUMBER
	) RETURN NUMBER
	IS
	  i_capital NUMBER;
	  c_forpag  seguros.cforpag%TYPE;
	  c_ramo    seguros.cramo%TYPE;
	  c_modali  seguros.cmodali%TYPE;
	  c_tipseg  seguros.ctipseg%TYPE;
	  c_colect  seguros.ccolect%TYPE;
	  ss        VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_cempres seguros.cempres%TYPE;
	  retorno   NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	/* Se debe declarar el componente*/
	BEGIN
	    BEGIN
	        SELECT cempres
	          INTO v_cempres
	          FROM seguros
	         WHERE sseguro=psseguro;
	    EXCEPTION
	        WHEN OTHERS THEN
	          RETURN 0; /* si no la encontramos no esta reducida*/
	    END;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'f_esta_reducida('
	        || psseguro
	        || ')'
	        || ';'
	        || 'END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             /*
	               Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
	               a una funci¿n, procedimiento, etc. inexistente o no declarado. En este
	               caso a continaci¿n ejecutamos el c¿digo tradicional para determinar
	               si la p¿liza est¿ o no reducida.
	             */
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             /*{Obtenemos la forma de pago de la poliza}*/
	             BEGIN
	                 SELECT cforpag,cramo,cmodali,ccolect,ctipseg
	                   INTO c_forpag, c_ramo, c_modali, c_colect, c_tipseg
	                   FROM seguros
	                  WHERE sseguro=psseguro;
	             EXCEPTION
	                 WHEN OTHERS THEN
	                   RETURN 0; /* si no la encontramos no esta reducida*/
	             END;

	             /*{Obtenemos el capital de la polzia}*/
	             /* Bug 9685 - APD - 30/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la funci¿n pac_seguros.ff_get_actividad*/
	             SELECT SUM(icapital)
	               INTO i_capital
	               FROM garanseg g
	              WHERE sseguro=psseguro AND
	                    ffinefe IS NULL AND
	                    f_pargaranpro_v(c_ramo, c_modali, c_tipseg, c_colect, pac_seguros.ff_get_actividad(g.sseguro, g.nriesgo), g.cgarant, 'TIPO')=3;

	             /* Bug 9685 - APD - 30/04/2009 - Fin*/
	             IF c_forpag=0 AND
	                i_capital=0 THEN
	               RETURN 1; /*{poliza reducida}*/
	             END IF;

	             RETURN 0;
	END f_esta_reducida;

	/* Fin Bug 10468*/
	/*************************************************************************
	   FUNCTION f_validaposttarif
	   Validaciones despues de tarifar
	   Param IN psproduc: producto
	   Param IN psseguro: sseguro
	   Param IN pnriesgo: nriesgo
	   Param IN pfefecto: Fecha
	   return : 0 Si todo ha ido bien, si no el c¿digo de error

	*************************************************************************/
	/* Bug 11771 - 04/11/2009 - RSC - CRE - Ajustes en simulaci¿n y contrataci¿n PPJ Din¿mico/Pla Estudiant*/
	/* Reubicamos esta funci¿n - Ver PAC_PROPIO_XXX*/
	FUNCTION f_validaposttarif(
			psproduc	IN	NUMBER,
			psseguro	IN	NUMBER,
			pnriesgo	IN	NUMBER,
			pfefecto	IN	DATE
	) RETURN NUMBER
	IS
	  nerror    NUMBER;
	  num_err   NUMBER;
	  /*  imp_restar     NUMBER;*/
	  /*  importe_limite NUMBER;*/
	  /*   v_tot_prima    NUMBER;*/
	  /*  v_limite       NUMBER;*/
	  v_garant  garanseg.cgarant%TYPE;
	  v_ret     NUMBER:=0;
	  v_cursor  NUMBER;
	  ss        VARCHAR2(3000);
	  funcion   detparpro.tvalpar%TYPE;
	  v_filas   NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	  /* Se debe declarar el componente*/
	  v_cempres seguros.cempres%TYPE;
	  v_propio  VARCHAR2(50);
	BEGIN
	    IF nvl(f_parproductos_v(psproduc, 'F_VALIDA_POSTTARIF'), 0)!=0 THEN --JTS - 02/11/2010 - BUG 16106
	      SELECT max(tvalpar)
	        INTO funcion
	        FROM detparpro
	       WHERE cparpro='F_VALIDA_POSTTARIF' AND
	             cidioma=2 AND
	             cvalpar=(SELECT cvalpar
	                        FROM parproductos
	                       WHERE sproduc=psproduc AND
	                             cparpro='F_VALIDA_POSTTARIF');

	      IF funcion IS NOT NULL THEN
	        ss:='begin :v_ret := '
	            || funcion
	            || '; end;';

	        IF dbms_sql.is_open(v_cursor) THEN
	          dbms_sql.close_cursor(v_cursor);
	        END IF;

	        v_cursor:=dbms_sql.open_cursor;

	        dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	        IF instr(ss, ':SPRODUC')>0 THEN
	          dbms_sql.bind_variable(v_cursor, ':SPRODUC', psproduc);
	        END IF;

	        IF instr(ss, ':SSEGURO')>0 THEN
	          dbms_sql.bind_variable(v_cursor, ':SSEGURO', psseguro);
	        END IF;

	        IF instr(ss, ':NRIESGO')>0 THEN
	          dbms_sql.bind_variable(v_cursor, ':NRIESGO', pnriesgo);
	        END IF;

	        IF instr(ss, ':FECHA')>0 THEN
	          dbms_sql.bind_variable(v_cursor, ':FECHA', pfefecto);
	        END IF;

	        IF instr(ss, ':v_ret')>0 THEN
	          dbms_sql.bind_variable(v_cursor, ':v_ret', num_err);
	        END IF;

	        v_filas:=dbms_sql.EXECUTE(v_cursor);

	        dbms_sql.variable_value(v_cursor, 'v_ret', v_ret);

	        IF dbms_sql.is_open(v_cursor) THEN
	          dbms_sql.close_cursor(v_cursor);
	        END IF;
	      END IF;
	    ELSE BEGIN
	          BEGIN
	              SELECT cempres
	                INTO v_cempres
	                FROM seguros
	               WHERE sseguro=psseguro;
	          EXCEPTION
	              WHEN OTHERS THEN
	                RETURN 0; /* si no la encontramos no esta reducida*/
	          END;

	          SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	            INTO v_propio
	            FROM dual;

	          ss:='BEGIN '
	              || ' :RETORNO := '
	              || v_propio
	              || '.'
	              || 'f_validaposttarif('
	              || psproduc
	              || ','
	              || psseguro
	              || ','
	              || pnriesgo
	              || ','
	              || pfefecto
	              || ')'
	              || ';'
	              || 'END;';

	          IF dbms_sql.is_open(v_cursor) THEN
	            dbms_sql.close_cursor(v_cursor);
	          END IF;

	          v_cursor:=dbms_sql.open_cursor;

	          dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	          dbms_sql.bind_variable(v_cursor, ':RETORNO', v_ret);

	          v_filas:=dbms_sql.EXECUTE(v_cursor);

	          dbms_sql.variable_value(v_cursor, 'RETORNO', v_ret);

	          IF dbms_sql.is_open(v_cursor) THEN
	            dbms_sql.close_cursor(v_cursor);
	          END IF;
	      EXCEPTION
	          WHEN ex_nodeclared THEN
	            /*
	              Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
	              a una funci¿n, procedimiento, etc. inexistente o no declarado. En este
	              caso a continaci¿n ejecutamos el c¿digo tradicional para determinar
	              si una garant¿a est¿ o no reducida.
	            */
	            IF dbms_sql.is_open(v_cursor) THEN
	              dbms_sql.close_cursor(v_cursor);
	            END IF;

	            RETURN 0;
	      END;
	    END IF;

	    RETURN v_ret;
	END f_validaposttarif;

	/* Fin Bug 11771*/
	/*************************************************************************
	    FUNCTION f_esta_reducida
	      Indica si una p¿liza esta o no reducida.

	    param in psseguro  : Identificador de seguro.
	       return             : NUMBER (1 --> Reducida / 0 --> No reducida)
	    *************************************************************************/
	/* Bug 10350 - 01/06/2009 - RSC - APR: Detalle de garant¿as (Tarificaci¿n)*/
	/* Bug 11232 - 23/10/2009 - RSC - 11232: APR - estado de las garantias ya pagadas (a¿adimos ptablas)*/
	FUNCTION f_garan_reducida(
			psseguro	IN	NUMBER,
			pcgarant	IN	NUMBER,
			pndetgar	IN	NUMBER DEFAULT NULL,
			ptablas	IN	VARCHAR2 DEFAULT NULL
	) RETURN NUMBER
	IS
	  /*
	  i_capital      NUMBER;
	  c_forpag       NUMBER;
	  c_ramo         NUMBER;
	  c_modali       NUMBER;
	  c_tipseg       NUMBER;
	  c_colect       NUMBER;
	  */
	  ss        VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_cempres seguros.cempres%TYPE;
	  retorno   NUMBER;
	  v_ndetgar VARCHAR2(4);
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	  /* Se debe declarar el componente*/
	  /* Bug 11232 - 23/10/2009 - RSC - 11232: APR - estado de las garantias ya pagadas*/
	  v_ptablas VARCHAR2(10);
	/* Fin Bug 11232*/
	BEGIN
	    BEGIN
	        /* Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones ¿nicas*/
	        IF ptablas='EST' THEN
	          SELECT cempres
	            INTO v_cempres
	            FROM estseguros
	           WHERE sseguro=psseguro;
	        ELSE
	          /* Fin Bug 13832*/
	          SELECT cempres
	            INTO v_cempres
	            FROM seguros
	           WHERE sseguro=psseguro;
	        /* Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones ¿nicas*/
	        END IF;
	    /* Fin Bug 13832*/
	    EXCEPTION
	        WHEN OTHERS THEN
	          RETURN 0; /* si no la encontramos no esta reducida*/
	    END;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    IF pndetgar IS NULL THEN
	      v_ndetgar:='NULL';
	    ELSE
	      v_ndetgar:=pndetgar;
	    END IF;

	    /* Bug 11232 - 23/10/2009 - RSC - 11232: APR - estado de las garantias ya pagadas*/
	    IF ptablas IS NULL THEN
	      v_ptablas:='NULL';

	      ss:='BEGIN '
	          || ' :RETORNO := '
	          || v_propio
	          || '.'
	          || 'f_garan_reducida('
	          || psseguro
	          || ','
	          || pcgarant
	          || ','
	          || v_ndetgar
	          || ','
	          || v_ptablas
	          || ')'
	          || ';'
	          || 'END;';
	    ELSE
	      v_ptablas:=ptablas;

	      ss:='BEGIN '
	          || ' :RETORNO := '
	          || v_propio
	          || '.'
	          || 'f_garan_reducida('
	          || psseguro
	          || ','
	          || pcgarant
	          || ','
	          || v_ndetgar
	          || ','''
	          || v_ptablas
	          || ''')'
	          || ';'
	          || 'END;';
	    END IF;

	    /* Fin Bug 11232*/
	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             /*
	               Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
	               a una funci¿n, procedimiento, etc. inexistente o no declarado. En este
	               caso a continaci¿n ejecutamos el c¿digo tradicional para determinar
	               si una garant¿a est¿ o no reducida.
	             */
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN 0;
	END f_garan_reducida;

	/* Fin Bug 10350*/
	/*BUG 9658 - JTS - 29/05/2009 - 9658: APR - Desarrollo PL de comisiones de adquisi¿n*/
	/*************************************************************************
	  f_pcom_adquisition : retorna la comision de adquisici¿n
	  param out : p_comisi comision
	  return : 0 Si todo ha ido bien, si no el c¿digo de error
	****************************************************************************************/
	FUNCTION f_pcom_adquisition(
			p_cramo	IN	NUMBER,
	p_cmodali	IN	NUMBER,
	p_ctipseg	IN	NUMBER,
	p_ccolect	IN	NUMBER,
	p_cactivi	IN	NUMBER,
	p_cgarant	IN	NUMBER,
	p_fefecto	IN	DATE,
	p_sseguro	IN	NUMBER,
	p_nriesgo	IN	NUMBER,
	p_fvencim	IN	DATE,
	p_cforpag	IN	NUMBER,
	p_pfefecto_det	IN	DATE,
			 /* Bug 13515 - RSC - 10/03/2010 - APR - Error en el calculo de comisiones*/
			 p_fvencim_det	IN	DATE,
			 /* Bug 13515 - RSC - 10/03/2010 - APR - Error en el calculo de comisiones*/
			 p_comisi	OUT	NUMBER
	)
	RETURN NUMBER
	IS
	  v_numerr     NUMBER(10);
	  v_valpar     NUMBER(3);
	  v_nedad      NUMBER(3);
	  /* Bug 13515 - RSC - 10/03/2010 - APR - Error en el calculo de comisiones*/
	  v_nedad_venc NUMBER(3);
	/* Fin Bug 13515*/
	BEGIN
	/* Bug 10888 - RSC - 11/08/2009 - APR: estandarizaci¿n de los codigos de error a retornar*/
	/*v_numerr := f_pargaranpro(p_cramo, p_cmodali, p_ctipseg, p_ccolect, p_cactivi,*/
	    /*                          p_cgarant, 'COMISIADQ', v_valpar);*/
	    v_numerr:=f_pargaranpro(p_cramo, p_cmodali, p_ctipseg, p_ccolect, p_cactivi, p_cgarant, 'TIP_COM_ADQUI', v_valpar);

	    /* Fin Bug 10888*/
	    IF v_numerr<>0 THEN
	      RETURN v_numerr;
	    END IF;

	    IF v_numerr=0 AND
	       v_valpar IS NULL THEN
	      RETURN 0;
	    END IF;

	    IF v_valpar IN(1, 2) THEN
	      SELECT trunc(months_between(p_fefecto, fnacimi)/12)
	        INTO v_nedad
	        FROM per_personas p,riesgos r
	       WHERE p.sperson=r.sperson AND
	             r.sseguro=p_sseguro AND
	             r.nriesgo=p_nriesgo;

	      SELECT pcomisi
	        INTO p_comisi
	        FROM comidef
	       WHERE ctipo=v_valpar AND
	             v_nedad BETWEEN ndesde AND nhasta;
	    ELSIF v_valpar=3 THEN
	      SELECT trunc(months_between(p_fvencim_det, fnacimi)/12)
	        INTO v_nedad
	        FROM per_personas p,riesgos r
	       WHERE p.sperson=r.sperson AND
	             r.sseguro=p_sseguro AND
	             nriesgo=p_nriesgo;

	      /* Bug 13515 - RSC - 10/03/2010 - APR - Error en el calculo de comisiones*/
	      SELECT trunc(months_between(p_fvencim_det, p_pfefecto_det)/12)
	        INTO v_nedad_venc
	        FROM per_personas p,riesgos r
	       WHERE p.sperson=r.sperson AND
	             r.sseguro=p_sseguro AND
	             nriesgo=p_nriesgo;

	    /* Fin Bug 13515*/
	      /* Bug 13515 - RSC - 10/03/2010 - APR - Error en el calculo de comisiones*/
	      IF v_nedad>=65 THEN
	        /* Usamos v_nedad_venc*/
	        SELECT pcomisi
	          INTO p_comisi
	          FROM comidef
	         WHERE ctipo=v_valpar AND
	               v_nedad_venc BETWEEN ndesde AND nhasta AND
	               cforpag=decode(p_cforpag, 0, 0,
	                                         1);
	      ELSE
	      /* El cuadro con vencimiento a los 60 a¿os es el mismo que a los 65*/
	      /* pero corrido cinco a¿os.*/
	        /* Usamos v_nedad_venc*/
	        SELECT pcomisi
	          INTO p_comisi
	          FROM comidef
	         WHERE ctipo=v_valpar AND
	               (v_nedad_venc+5) BETWEEN ndesde AND nhasta AND
	               cforpag=decode(p_cforpag, 0, 0,
	                                         1);
	      END IF;
	    /* Fin Bug 13515*/
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN no_data_found THEN
	             RETURN 100933; /* comision inexistente*/
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_pcom_adquisicion', 2, 'pcramo:'
	                                                                                || p_cramo
	                                                                                || '  pcmodali:'
	                                                                                || p_cmodali
	                                                                                || 'p_ctipseg:'
	                                                                                || p_ctipseg
	                                                                                || ' p_ccolect:'
	                                                                                || p_ccolect
	                                                                                || ' p_cactivi:'
	                                                                                || p_cactivi
	                                                                                || ' p_cgarant:'
	                                                                                || p_cgarant
	                                                                                || ' p_fefecto:'
	                                                                                || p_fefecto
	                                                                                || ' p_sseguro:'
	                                                                                || p_sseguro
	                                                                                || ' p_nriesgo:'
	                                                                                || p_nriesgo
	                                                                                || ' p_fvencim:'
	                                                                                || p_fvencim
	                                                                                || ' p_cforpag:'
	                                                                                || p_cforpag, SQLCODE
	                                                                                              || '-'
	                                                                                              || SQLERRM);

	             RETURN 140999; /* Error no controlado*/
	END f_pcom_adquisition;

	/*************************************************************************
	   f_graba_com_adq : graba la comision de adquisici¿n
	   param in : p_sseguro
	   param in : p_nmovimi
	   param in : pmodo -- BUG 13607 - ASN - 11/03/2010 : Comisiones de adquisi¿n en previo de cartera
	   param in : psproces -- BUG 13607 - ASN - 11/03/2010 : Comisiones de adquisi¿n en previo de cartera
	   return : 0 Si todo ha ido bien, si no el c¿digo de error
	****************************************************************************************/
	FUNCTION f_graba_com_adq(
			p_sseguro	IN	NUMBER,
			p_nmovimi	IN	NUMBER,
			p_modo	IN	VARCHAR2,
			p_sproces	IN	NUMBER
	) RETURN NUMBER
	IS
	  v_sproduc seguros.sproduc%TYPE;
	  v_cvalpar NUMBER(10);
	  v_numerr  NUMBER(10):=0;
	  v_comisi  comidef.pcomisi%TYPE;

	  CURSOR cur_garanseg IS
	    SELECT g.cgarant,g.nriesgo,g.nmovimi,d.iprianu,g.finiefe,d.ndetgar,s.cramo,s.cmodali,s.cactivi,s.ctipseg,s.ccolect,s.fefecto,s.fvencim,s.cforpag,s.npoliza,least(s.fvencim, d.fvencim, add_months(g.finiefe, 120)) finiefe10,d.fefecto fefecto_det,d.fvencim fvencim_det
	      FROM garanseg g,seguros s,detgaranseg d
	     WHERE g.sseguro=p_sseguro AND
	           g.nmovimi=p_nmovimi AND
	           g.sseguro=s.sseguro AND
	           d.sseguro=g.sseguro AND
	           d.nriesgo=g.nriesgo AND
	           d.cgarant=g.cgarant AND
	           d.nmovimi=g.nmovimi AND
	           d.finiefe=g.finiefe AND
	           g.cgarant IN(SELECT cgarant
	                          FROM detgaranseg
	                         WHERE sseguro=p_sseguro AND
	                               nmovimi=p_nmovimi AND
	                               ndetgar=d.ndetgar
	                        MINUS
	                        SELECT cgarant
	                          FROM detgaranseg
	                         WHERE sseguro=p_sseguro AND
	                               nmovimi=(p_nmovimi-1) AND
	                               ndetgar=d.ndetgar);

	  CURSOR cur_garancar IS /* Bug 13607 ASN 11/03/2010*/
	    SELECT g.cgarant,g.nriesgo,g.iprianu,g.finiefe,g.ndetgar,s.cramo,s.cmodali,s.cactivi,s.ctipseg,s.ccolect,s.fefecto,s.fvencim,s.cforpag,s.npoliza,least(s.fvencim, g.fvencim, add_months(g.finiefe, 120)) finiefe10,g.fefecto fefecto_det,g.fvencim fvencim_det
	      FROM garancar g,seguros s
	     WHERE g.sseguro=p_sseguro AND
	           g.sproces=p_sproces AND
	           g.sseguro=s.sseguro AND
	           (g.sseguro, g.cgarant, g.ndetgar) NOT IN(SELECT sseguro,cgarant,ndetgar
	                                                      FROM detgaranseg
	                                                     WHERE sseguro=p_sseguro);
	BEGIN
	    SELECT sproduc
	      INTO v_sproduc
	      FROM seguros
	     WHERE sseguro=p_sseguro;

	    v_numerr:=f_parproductos(v_sproduc, 'COM_ADQUI', v_cvalpar);

	    IF v_cvalpar=1 AND
	       v_numerr=0 THEN
	      /* Bug 13607 ASN 11/03/2010 ini*/
	      IF p_modo='P' THEN
			INSERT INTO comisigaransegcar
		           (sproces,sseguro,nriesgo,cgarant,finiefe,ndetgar,
		           ffinpg,iprianu,pcomisi,icomanu,itotcom)

		    SELECT
		           p_sproces,sseguro,nriesgo,cgarant,finiefe,ndetgar,
		           ffinpg,iprianu,pcomisi,icomanu,itotcom

		      FROM
		           comisigaranseg
		     WHERE
		           sseguro=p_sseguro;


	        FOR i IN cur_garancar LOOP
	            v_numerr:=f_pcom_adquisition(i.cramo, i.cmodali, i.ctipseg, i.ccolect, i.cactivi, i.cgarant, i.fefecto, p_sseguro, i.nriesgo, i.fvencim, i.cforpag, i.fefecto_det, i.fvencim_det, v_comisi);

	            EXIT WHEN v_numerr<>0;

	            IF v_numerr=0 AND
	               (v_comisi IS NOT NULL  OR
	                v_comisi>0) THEN
			INSERT INTO comisigaransegcar
		           (sproces,sseguro,nriesgo,cgarant,finiefe,ndetgar,
		           ffinpg,iprianu,pcomisi,icomanu,itotcom)

		    VALUES
		           (p_sproces,p_sseguro,i.nriesgo,i.cgarant,i.finiefe,i.ndetgar,
		           i.finiefe10,i.iprianu,v_comisi,((i.iprianu*v_comisi)/10),(i.iprianu*v_comisi));

	            END IF;
	        END LOOP;
	      ELSE
	        /* Bug 13607 ASN 11/03/2010 fin*/
	        FOR i IN cur_garanseg LOOP
	            v_numerr:=f_pcom_adquisition(i.cramo, i.cmodali, i.ctipseg, i.ccolect, i.cactivi, i.cgarant, i.fefecto, p_sseguro, i.nriesgo, i.fvencim, i.cforpag, i.fefecto_det, i.fvencim_det, v_comisi);

	            EXIT WHEN v_numerr<>0;

	            IF v_numerr=0 AND
	               (v_comisi IS NOT NULL  OR
	                v_comisi>0) THEN
			INSERT INTO comisigaranseg
		           (sseguro,nriesgo,cgarant,nmovimi,finiefe,ndetgar,
		           ffinpg,iprianu,pcomisi,icomanu,itotcom)

		    VALUES
		           (p_sseguro,i.nriesgo,i.cgarant,p_nmovimi,i.finiefe,i.ndetgar,
		           i.finiefe10,i.iprianu,v_comisi,((i.iprianu*v_comisi)/10),(i.iprianu*v_comisi));

	            END IF;
	        END LOOP;
	      END IF;
	    END IF;

	    RETURN v_numerr;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_graba_com_adq', 2, 'p_sseguro:'
	                                                                             || p_sseguro
	                                                                             || ' p_nmovimi:'
	                                                                             || p_nmovimi, SQLCODE
	                                                                                           || '-'
	                                                                                           || SQLERRM);

	             RETURN 140999; /* Error no controlado*/
	END f_graba_com_adq;

	/*Fi BUG 9658 - JTS - 29/05/2009 - 9658: APR - Desarrollo PL de comisiones de adquisi¿n*/
	/* Bug 11284 - 30/09/2009 - AMC - N¿ DE CONTRATO FORMATO CEM*/
	/*************************************************************************
	  FUNCTION f_calc_contrato_interno
	    Calcula el c¿digo de cuenta interno de CEM
	    param in pcagente   : Identificador del agente
	    param in psseguro  : Identificador de seguro.
	    return             : C¿digo contrato

	    Bug 11284 - 30/09/2009 - AMC - N¿ DE CONTRATO FORMATO CEM
	*************************************************************************/
	FUNCTION f_calc_contrato_interno(
			pcagente	IN	NUMBER,
			psseguro	IN	NUMBER
	) RETURN VARCHAR2
	IS
	  v_propio  VARCHAR2(100);
	  ss        VARCHAR2(2000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_cempres seguros.cempres%TYPE;
	  retorno   VARCHAR2(20);
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	  /* Se debe declarar el componente*/
	  vcagente  historicoseguros.cagente%TYPE;
	BEGIN
	    BEGIN
	        SELECT cagente
	          INTO vcagente
	          FROM historicoseguros
	         WHERE nmovimi=1 AND
	               sseguro=psseguro;

	        SELECT cempres
	          INTO v_cempres
	          FROM seguros
	         WHERE sseguro=psseguro;
	    EXCEPTION
	        WHEN OTHERS THEN BEGIN
	              SELECT cempres,cagente
	                INTO v_cempres, vcagente
	                FROM seguros
	               WHERE sseguro=psseguro;
	          EXCEPTION
	              WHEN OTHERS THEN
	                RETURN 0; /* si no la encontramos no esta reducida*/
	          END;
	    END;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'f_calc_contrato_interno('
	        || nvl(vcagente, pcagente)
	        || ','
	        || psseguro
	        || ')'
	        || ';'
	        || 'END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno, 20);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             /*
	               Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
	               a una funci¿n, procedimiento, etc. inexistente o no declarado.
	             */
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN NULL; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_calc_contrato_interno', 2, 'psseguro:'
	                                                                                     || psseguro
	                                                                                     || ' pcagente:'
	                                                                                     || pcagente, SQLCODE
	                                                                                                  || '-'
	                                                                                                  || SQLERRM);

	             RETURN NULL;
	END f_calc_contrato_interno;

	/*Fi BUG 11284 - AMC - 30/09/2009*/
	/*Bug 11424 - 09/10/2009 - FAL - N¿ de referencia cuestionario de salud*/
	/*************************************************************************
	      FUNCTION f_get_id_cuestsalud
	        Calcula el N¿ de referencia cuestionario de salud
	        param in pmodo     : modo de acceso EST: estudio POL: p¿lizas
	        param in psseguro  : Identificador de seguro.
	        param in pnriesgo  : Identificador de riesgo.
	        return             : N¿ de referencia cuestionario de salud
	   *************************************************************************/
	FUNCTION f_get_id_cuestsalud(
			pmodo	IN	VARCHAR,
			psseguro	IN	NUMBER,
			pnriesgo	IN	NUMBER
	) RETURN VARCHAR2
	IS
	  wssegpol estseguros.ssegpol%TYPE;
	  wnmovimi movseguro.nmovimi%TYPE;
	  result   VARCHAR2(12);
	BEGIN
	    IF pmodo='EST' THEN
	      SELECT ssegpol
	        INTO wssegpol
	        FROM estseguros
	       WHERE sseguro=psseguro;

	      SELECT nvl(max(nmovimi), 0)+1
	        INTO wnmovimi
	        FROM movseguro
	       WHERE sseguro=wssegpol;

	      result:=lpad(wssegpol, 6, '0')
	              || lpad(wnmovimi, 3, '0')
	              || lpad(pnriesgo, 3, '0');

	      RETURN result;
	    ELSIF pmodo='SEG' THEN
	      SELECT max(nmovimi)
	        INTO wnmovimi
	        FROM movseguro
	       WHERE sseguro=psseguro;

	      result:=lpad(psseguro, 6, '0')
	              || lpad(wnmovimi, 3, '0')
	              || lpad(pnriesgo, 3, '0');

	      RETURN result;
	    END IF;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_get_id_cuestsalud', 2, 'pmodo:'
	                                                                                 || pmodo
	                                                                                 || ' psseguro:'
	                                                                                 || psseguro
	                                                                                 || ' pnriesgo:'
	                                                                                 || pnriesgo, SQLCODE
	                                                                                              || '-'
	                                                                                              || SQLERRM);

	             RETURN NULL;
	END f_get_id_cuestsalud;

	/*Fi BUG 11424 - FAL - 09/10/2009*/
	/* Bug 11308 - 01/12/2009 - AMC*/
	/*************************************************************************
	    FUNCTION f_extrae_npoliza
	      Extrae el n¿ de poliza del c¿digo de cuenta interno
	      param in pncontinter   : C¿digo de cuenta interno
	      param in pcempres     : Codigo de la empresa
	      return             : N¿ poliza
	 *************************************************************************/
	FUNCTION f_extrae_npoliza(
			pncontinter	IN	VARCHAR2,
			pcempres NUMBER
	) RETURN NUMBER
	IS
	  v_propio VARCHAR2(100);
	  ss       VARCHAR2(2000);
	  v_cursor NUMBER;
	  v_filas  NUMBER;
	  retorno  NUMBER;
	BEGIN
	    IF pncontinter IS NULL  OR
	       pcempres IS NULL THEN
	      RETURN NULL;
	    END IF;

	    SELECT pac_parametros.f_parempresa_t(pcempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'f_extrae_npoliza('''
	        || pncontinter
	        || ''')'
	        || ';'
	        || 'END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_extrae_npoliza', 2, 'pncontinter:'
	                                                                              || pncontinter
	                                                                              || ' pcempres:'
	                                                                              || pcempres, SQLCODE
	                                                                                           || '-'
	                                                                                           || SQLERRM);

	             RETURN NULL;
	END f_extrae_npoliza;

	/*Fi Bug 11308 - 01/12/2009 - AMC*/

--Ini CONF-219 AP
	  /*************************************************************************
	FUNCTION f_extrae_npoliza
	Extrae el n¿ de poliza del codigo de contrato (preguntas 4097)
	param in pncontinter  : C¿digo de contrato
	param in pcempres     : Codigo de la empresa
	return             : N¿ poliza
	*************************************************************************/
	FUNCTION F_EXTRAE_NPOLCONTRA (
			PNCONTRATO	IN	VARCHAR2,
			pcempres IN NUMBER
	) RETURN NUMBER
	IS
	  v_propio VARCHAR2(100);
	  ss       VARCHAR2(2000);
	  v_cursor NUMBER;
	  v_filas  NUMBER;
	  retorno  NUMBER;
	BEGIN
	    IF pncontrato IS NULL  OR
	       pcempres IS NULL THEN
	      RETURN NULL;
	    END IF;

	    SELECT pac_parametros.f_parempresa_t(pcempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'f_extrae_npolcontra('''
	        || pncontrato
          || ''','
          || pcempres
	        || ')'
	        || ';'
	        || 'END;';
	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_extrae_npolcontra', 2, 'pncontrato:'
	                                                                              || pncontrato
	                                                                              || ' pcempres:'
	                                                                              || pcempres, SQLCODE
	                                                                                           || '-'
	                                                                                           || SQLERRM);

	             RETURN NULL;
	END F_EXTRAE_NPOLCONTRA;
--Fi CONF-219 AP

	/*Ini Bug.: 0013781 - ICV - 23/03/2010*/
	/*************************************************************************
	    FUNCTION f_nif_transf
	      Funci¿n que devuelve el nif del cobrador para transferencias, siendo el estandard RPAD(pnnumnif, 10, ' ').
	      Excepto para rentas de CEM, en este caso devuelve el nif  RPAD(pnnumnif, 9, ' ')|| tsufijo
	      return             : Nif del cobrador para transferencias.
	 *************************************************************************/
	FUNCTION f_nif_transf(
			psseguro	IN	NUMBER,
			pnnumnif	IN	VARCHAR2,
			pccobban	IN	NUMBER,
			pcatribu	IN	NUMBER
	) RETURN VARCHAR2
	IS
	  v_tsufijo cobbancario.tsufijo%TYPE;
	  v_propio  VARCHAR2(50);
	  v_cempres seguros.cempres%TYPE;
	  retorno   VARCHAR2(10);
	  ss        VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	/* Se debe declarar el componente*/
	BEGIN
	    BEGIN
	        SELECT cempres
	          INTO v_cempres
	          FROM seguros
	         WHERE sseguro=psseguro;
	    EXCEPTION
	        WHEN OTHERS THEN
	          RETURN 0; /* si no la encontramos no esta reducida*/
	    END;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'F_NIF_TRANSF('
	        || psseguro
	        || ','
	        || chr(39)
	        || pnnumnif
	        || chr(39)
	        || ','
	        || pccobban
	        || ','
	        || pcatribu
	        || ')'
	        || ';'
	        || 'END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno, 10);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             /*
	               Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
	               a una funci¿n, procedimiento, etc. inexistente o no declarado. En este
	               caso a continaci¿n ejecutamos el c¿digo tradicional para determinar
	               si la p¿liza est¿ o no reducida.
	             */
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN rpad(pnnumnif, 10, ' ');
	END f_nif_transf;

	/*Fin Bug.: 0013781 - ICV - 23/03/2010*/
	/* Ini bug: 0013946 AVT 27-04-2010*/
	/******************************************************************************
	   NOMBRE:       f_fecha_anyo_renova
	   PROP¿SITO:    Devuelve una fecha partir del a¿o y la renovaci¿n
	******************************************************************************/
	FUNCTION f_fecha_renova(
			wanyo	IN	NUMBER,
			wnrenova	IN	NUMBER
	) RETURN DATE
	IS
	  wfecha_renova DATE;
	  wrenova_feb   NUMBER(4);
	BEGIN
	    BEGIN
	        wfecha_renova:=to_date(wanyo
	                               || lpad(wnrenova, 4, '0'), 'yyyymmdd');
	    EXCEPTION
	        WHEN OTHERS THEN
	          wrenova_feb:=0228;

	          wfecha_renova:=to_date(wanyo
	                                 || lpad(wrenova_feb, 4, '0'), 'yyyymmdd');
	    END;

	    RETURN wfecha_renova;
	END f_fecha_renova;

	/* Fi bug: 0013946 AVT 27-04-2010*/
	/*************************************************************************
	    C¿lculo de valoraci¿n de reserva en siniestros de muerte (garant¿s de riesgo)

	    param in psseguro          : Sseguro
	    param in pfecha          : Fecha de rescate
	    param in pcgarant          : Identificador de garant¿a
	    return                     : N¿mero de a¿o dentro de periodo de revisi¿n /
	                                               hasta periodo de revisi¿n.
	*************************************************************************/
	/* Bug 14160 - RSC - 16/04/2010 - CEM800 - Adaptar packages de productos de inversi¿n al nuevo m¿dulo de siniestros*/
	FUNCTION f_irescate_finv(
			psseguro	IN	NUMBER,
			pfecha	IN	DATE,
			pcgarant	IN	NUMBER
	) RETURN NUMBER
	IS
	  /*
	    { funci¿n que retorna el importe de la provisi¿n matematica
	     menos el importe de los recibos de gesti¿n
	    }
	  */
	  xireserva        NUMBER;
	  xigestion        NUMBER;
	  /*     xffecmue       DATE;*/
	  /*    xireserva_mort NUMBER := 0;*/
	  /*    importe        NUMBER;*/
	  /*    primasaportadas NUMBER;*/
	  /* RSC 08/04/2008*/
	  /*    vsproduc       NUMBER;*/
	  /* Bug 14072 - RSC - 09/04/2010*/
	  v_capital_riesgo garanseg.icapital%TYPE:=0;
	/* Fin Bug 14072*/
	BEGIN
	    /* Parte de ahorro*/
	    xireserva:=pac_provmat_formul.f_calcul_formulas_provi(psseguro, pfecha, 'IPROVAC');

	    xigestion:=calc_rescates.frecgestion(psseguro, 2);

	    /* Parte de riesgo*/
	    IF pcgarant IS NOT NULL THEN
	      SELECT icapital
	        INTO v_capital_riesgo
	        FROM garanseg
	       WHERE sseguro=psseguro AND
	             ((finiefe<=pfecha) AND
	              (ffinefe IS NULL  OR
	               ffinefe>pfecha)) AND
	             cgarant=pcgarant;
	    END IF;

	    RETURN(v_capital_riesgo+xireserva-nvl(xigestion, 0));
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, getuser, 'pac_propio.f_irescate_finv', NULL, 'psseguro = '
	                                                                                 || psseguro
	                                                                                 || ' pfecha ='
	                                                                                 || pfecha, SQLERRM);

	             RETURN NULL;
	END f_irescate_finv;

	/* Fin Bug 14160*/
	/*************************************************************************
	    Determina si debe o no debe grabar objeto de tarificaci¿n
	    param in pcmotmov
	    param in out mensajes  : mensajes de error
	    return                 : 0 todo correcto
	                             1 ha habido un error
	*************************************************************************/
	/* Bug 13832 - RSC - 10/06/2010 -  APRS015 - suplemento de aportaciones ¿nicas*/
	FUNCTION f_bloqueo_grabarobjectodb(
			psseguro	IN	NUMBER,
			pcmotmov	IN	NUMBER
	) RETURN NUMBER
	IS
	  /*
	  i_capital      NUMBER;
	  c_forpag       NUMBER;
	  c_ramo         NUMBER;
	  c_modali       NUMBER;
	  c_tipseg       NUMBER;
	  c_colect       NUMBER;
	  */
	  ss        VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_cempres seguros.cempres%TYPE;
	  v_sproduc seguros.sproduc%TYPE;
	  retorno   NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	/* Se debe declarar el componente*/
	BEGIN
	    BEGIN
	        SELECT cempres,sproduc
	          INTO v_cempres, v_sproduc
	          FROM seguros
	         WHERE sseguro=psseguro;
	    EXCEPTION
	        WHEN OTHERS THEN
	          RETURN 0; /* si no la encontramos no esta reducida*/
	    END;

	    IF nvl(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) NOT IN(1, 2) THEN
	      RETURN 0;
	    END IF;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'f_bloqueo_grabarobjectodb('
	        || pcmotmov
	        || ')'
	        || ';'
	        || 'END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             /*
	               Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
	               a una funci¿n, procedimiento, etc. inexistente o no declarado. En este
	               caso a continaci¿n ejecutamos el c¿digo tradicional para determinar
	               si la p¿liza est¿ o no reducida.
	             */
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN 0;
	END f_bloqueo_grabarobjectodb;

	/* Fin Bug 10468*/
	/*************************************************************************
	    FUNCTION f_prima_cero
	    Indica si una p¿liza esta o no reducida. (prima cero)

	    param in psseguro  : Identificador de seguro.
	       return             : NUMBER (1 --> prima cero / 0 --> No prima cero)
	*************************************************************************/
	/* Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones ¿nicas*/
	FUNCTION f_prima_cero(
			psseguro	IN	NUMBER,
			pcgarant	IN	NUMBER,
			pndetgar	IN	NUMBER DEFAULT NULL,
			ptablas	IN	VARCHAR2 DEFAULT NULL
	) RETURN NUMBER
	IS
	  /*
	  i_capital      NUMBER;
	  c_forpag       NUMBER;
	  c_ramo         NUMBER;
	  c_modali       NUMBER;
	  c_tipseg       NUMBER;
	  c_colect       NUMBER;
	  */
	  ss        VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_cempres seguros.cempres%TYPE;
	  retorno   NUMBER;
	  v_ndetgar VARCHAR2(4);
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	  /* Se debe declarar el componente*/
	  /* Bug 11232 - 23/10/2009 - RSC - 11232: APR - estado de las garantias ya pagadas*/
	  v_ptablas VARCHAR2(10);
	/* Fin Bug 11232*/
	BEGIN
	    BEGIN
	        /* Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones ¿nicas*/
	        IF ptablas='EST' THEN
	          SELECT cempres
	            INTO v_cempres
	            FROM estseguros
	           WHERE sseguro=psseguro;
	        ELSE
	          /* Fin Bug 13832*/
	          SELECT cempres
	            INTO v_cempres
	            FROM seguros
	           WHERE sseguro=psseguro;
	        /* Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones ¿nicas*/
	        END IF;
	    /* Fin Bug 13832*/
	    EXCEPTION
	        WHEN OTHERS THEN
	          RETURN 0; /* si no la encontramos no esta reducida*/
	    END;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    IF pndetgar IS NULL THEN
	      v_ndetgar:='NULL';
	    ELSE
	      v_ndetgar:=pndetgar;
	    END IF;

	    /* Bug 11232 - 23/10/2009 - RSC - 11232: APR - estado de las garantias ya pagadas*/
	    IF ptablas IS NULL THEN
	      v_ptablas:='NULL';

	      ss:='BEGIN '
	          || ' :RETORNO := '
	          || v_propio
	          || '.'
	          || 'f_prima_cero('
	          || psseguro
	          || ','
	          || pcgarant
	          || ','
	          || v_ndetgar
	          || ','
	          || v_ptablas
	          || ')'
	          || ';'
	          || 'END;';
	    ELSE
	      v_ptablas:=ptablas;

	      ss:='BEGIN '
	          || ' :RETORNO := '
	          || v_propio
	          || '.'
	          || 'f_prima_cero('
	          || psseguro
	          || ','
	          || pcgarant
	          || ','
	          || v_ndetgar
	          || ','''
	          || v_ptablas
	          || ''')'
	          || ';'
	          || 'END;';
	    END IF;

	    /* Fin Bug 11232*/
	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             /*
	               Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
	               a una funci¿n, procedimiento, etc. inexistente o no declarado. En este
	               caso a continaci¿n ejecutamos el c¿digo tradicional para determinar
	               si una garant¿a est¿ o no reducida.
	             */
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN 0;
	END f_prima_cero;

	/* Fin Bug 10350*/
	/* INI--Bug 15884 - ETM - 13/09/2010 - CEM - Fe de Vida.*/
	/**********************************************************************
	FUNCTION F_GET_DATOS_FE_VIDA
	 -- Nueva funci¿n que devolver¿ un REF CURSOR con las p¿lizas que deben enviar la carta de fe de vida.
	Par¿metros
	 1.   psproces. Identificador del proceso.
	 2.   pcempres. Identificador de la empresa. Obligatorio.
	 3.   pcramo. Identificador del ramo.
	 4.   psproduc. Identificador del producto.
	 5.   pcagente. Identificador del agente.
	 6.   pnpoliza. N¿mero de p¿liza.
	 7.   pncertif. N¿mero de certificado.
	 8.   pfhasta. Fecha hasta la cual se realiza la solicitud de fe de vida. Obligatorio.
	 9.   pngenerar. Identificador de generaci¿n de cartas. 0.-Se generan las cartas por primera vez;1.-Se vuelve a reimprimir el listado (map). Obligatorio (valor por defecto 0)


	**********************************************************************/
	/* BUG 21546_108727- 23/02/2012 - JLTS - Se elimina el env¿o de mensajes*/
	FUNCTION f_get_datos_fe_vida(
			psproces	IN	NUMBER,
			pcempres	IN	NUMBER,
			pcramo	IN	NUMBER,
			psproduc	IN	NUMBER,
			pcagente	IN	NUMBER,
			pnpoliza	IN	NUMBER,
			pncertif	IN	NUMBER,
			pfhasta	IN	DATE,
			pngenerar	IN	NUMBER DEFAULT 0,
			pnpantalla	IN	NUMBER DEFAULT 0
	) RETURN SYS_REFCURSOR
	IS
	  v_psproces VARCHAR2(50);
	  v_pcramo   VARCHAR2(50);
	  v_psproduc VARCHAR2(50);
	  v_pcagente VARCHAR2(50);
	  v_pnpoliza VARCHAR2(50);
	  v_pncertif VARCHAR2(50);
	  v_propio   VARCHAR2(50);
	  ss         VARCHAR2(10000);
	  v_cursor   NUMBER;
	  v_filas    NUMBER;
	  v_squery   VARCHAR2(10000);
	  retorno    SYS_REFCURSOR;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	  /* Se debe declarar el componente*/
	  vpasexec   NUMBER(8):=1;
	  vparam     VARCHAR2(4000):='psproces='
	                         || psproces
	                         || ' pcempres='
	                         || pcempres
	                         || ' pcramo='
	                         || pcramo
	                         || ' psproduc='
	                         || psproduc
	                         || ' pcagente='
	                         || pcagente
	                         || ' pnpoliza='
	                         || pnpoliza
	                         || ' pncertif='
	                         || pncertif
	                         || ' pfhasta='
	                         || pfhasta
	                         || ' pngenerar='
	                         || pngenerar
	                         || ' pnpantalla= '
	                         || pnpantalla;
	  vobject    VARCHAR2(200):='PAC_PROPIO.F_GET_DATOS_FE_VIDA';
	BEGIN
	    /* comprobar campos obligatorios*/
	    IF pngenerar=0 THEN
	      IF pcempres IS NULL  OR
	         pfhasta IS NULL THEN
	        RAISE e_param_error;
	      END IF;
	    ELSIF pngenerar=1 THEN
	      IF psproces IS NULL THEN
	        RAISE e_param_error;
	      END IF;
	    END IF;

	    SELECT pac_parametros.f_parempresa_t(pcempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    IF psproces IS NULL THEN
	      v_psproces:='null';
	    ELSE
	      v_psproces:=psproces;
	    END IF;

	    IF pcramo IS NULL THEN
	      v_pcramo:='null';
	    ELSE
	      v_pcramo:=pcramo;
	    END IF;

	    IF psproduc IS NULL THEN
	      v_psproduc:='null';
	    ELSE
	      v_psproduc:=psproduc;
	    END IF;

	    IF pcagente IS NULL THEN
	      v_pcagente:='null';
	    ELSE
	      v_pcagente:=pcagente;
	    END IF;

	    IF pnpoliza IS NULL THEN
	      v_pnpoliza:='null';
	    ELSE
	      v_pnpoliza:=pnpoliza;
	    END IF;

	    IF pncertif IS NULL THEN
	      v_pncertif:='null';
	    ELSE
	      v_pncertif:=pncertif;
	    END IF;

	    ss:='BEGIN '
	        || ' :V_SQUERY := '
	        || v_propio
	        || '.'
	        || 'f_get_datos_fe_vida ('
	        || v_psproces
	        || ','
	        || pcempres
	        || ','
	        || v_pcramo
	        || ','
	        || v_psproduc
	        || ','
	        || v_pcagente
	        || ','
	        || v_pnpoliza
	        || ','
	        || v_pncertif
	        || ','
	        || chr(39)
	        || to_char(pfhasta, 'dd/mm/yyyy')
	        || chr(39)
	        || ','
	        || pngenerar
	        || ','
	        || pnpantalla
	        || ')'
	        || ';'
	        || 'END;';

	    vpasexec:=2;

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    vpasexec:=3;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':V_SQUERY', v_squery, 10000);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'V_SQUERY', v_squery);

	    vpasexec:=4;

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    vpasexec:=5;

	    OPEN retorno FOR v_squery;

	    vpasexec:=6;

	    RETURN retorno;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'PARAMETROS OBLIGATORIOS NO INFORMADOS '
	                                                               || vparam, SQLERRM);

	             RETURN NULL; WHEN ex_nodeclared THEN
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN NULL; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'parametros: '
	                                                               || vparam, SQLERRM);

	             RETURN NULL; /* Error no controlado*/
	END f_get_datos_fe_vida;

	/**********************************************************************
	FUNCTION F_GET_DATOS_APUNTE_FE_VIDA
	 -- Nueva funci¿n que devolver¿ un REF CURSOR con las p¿lizas que deben enviar la carta de fe de vida
	 Par¿metros
	Par¿metros
	 1.   psproces. Identificador del proceso.
	 2.   pcempres. Identificador de la empresa. Obligatorio.
	 3.   pcramo. Identificador del ramo.
	 4.   psproduc. Identificador del producto.
	 5.   pcagente. Identificador del agente.
	 6.   pnpoliza. N¿mero de p¿liza.
	 7.   pncertif. N¿mero de certificado.
	 8.   pfhasta. Fecha hasta la cual se realiza la solicitud de fe de vida. Obligatorio.
	 9.   pngenerar. Identificador de generaci¿n de cartas. 0.-Se generan las cartas por primera vez;1.-Se vuelve a reimprimir el listado (map). Obligatorio (valor por defecto 0)

	**********************************************************************/
	FUNCTION f_get_datos_apunte_fe_vida(
			psproces	IN	NUMBER,
			pcempres	IN	NUMBER,
			pcramo	IN	NUMBER,
			psproduc	IN	NUMBER,
			pcagente	IN	NUMBER,
			pnpoliza	IN	NUMBER,
			pncertif	IN	NUMBER,
			pfhasta	IN	DATE,
			pngenerar	IN	NUMBER DEFAULT 0
	) RETURN SYS_REFCURSOR
	IS
	  v_propio   VARCHAR2(50);
	  ss         VARCHAR2(10000);
	  v_cursor   NUMBER;
	  v_filas    NUMBER;
	  v_squery   VARCHAR2(10000);
	  retorno    SYS_REFCURSOR;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	  /* Se debe declarar el componente*/
	  vpasexec   NUMBER(8):=1;
	  vparam     VARCHAR2(4000):='psproces='
	                         || psproces
	                         || ' pcempres='
	                         || pcempres
	                         || ' pcramo='
	                         || pcramo
	                         || ' psproduc='
	                         || psproduc
	                         || ' pcagente='
	                         || pcagente
	                         || ' pnpoliza='
	                         || pnpoliza
	                         || ' pncertif='
	                         || pncertif
	                         || ' pfhasta='
	                         || to_char(pfhasta, 'dd/mm/yyyy')
	                         || ' pngenerar='
	                         || pngenerar;
	  vobject    VARCHAR2(200):='PAC_PROPIO. F_GET_DATOS_APUNTE_FE_VIDA';
	  v_psproces VARCHAR2(50);
	  v_pcramo   VARCHAR2(50);
	  v_psproduc VARCHAR2(50);
	  v_pcagente VARCHAR2(50);
	  v_pnpoliza VARCHAR2(50);
	  v_pncertif VARCHAR2(50);
	BEGIN
	    /* comprobar campos obligatorios*/
	    IF pngenerar=0 THEN
	      IF pcempres IS NULL  OR
	         pfhasta IS NULL THEN
	        RAISE e_param_error;
	      END IF;
	    ELSIF pngenerar=1 THEN
	      IF psproces IS NULL THEN
	        RAISE e_param_error;
	      END IF;
	    END IF;

	    SELECT pac_parametros.f_parempresa_t(pcempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    IF psproces IS NULL THEN
	      v_psproces:='null';
	    ELSE
	      v_psproces:=psproces;
	    END IF;

	    IF pcramo IS NULL THEN
	      v_pcramo:='null';
	    ELSE
	      v_pcramo:=pcramo;
	    END IF;

	    IF psproduc IS NULL THEN
	      v_psproduc:='null';
	    ELSE
	      v_psproduc:=psproduc;
	    END IF;

	    IF pcagente IS NULL THEN
	      v_pcagente:='null';
	    ELSE
	      v_pcagente:=pcagente;
	    END IF;

	    IF pnpoliza IS NULL THEN
	      v_pnpoliza:='null';
	    ELSE
	      v_pnpoliza:=pnpoliza;
	    END IF;

	    IF pncertif IS NULL THEN
	      v_pncertif:='null';
	    ELSE
	      v_pncertif:=pncertif;
	    END IF;

	    ss:='BEGIN '
	        || ' :V_SQUERY := '
	        || v_propio
	        || '.'
	        || 'f_get_datos_apuntes_fe_vida ('
	        || v_psproces
	        || ','
	        || pcempres
	        || ','
	        || v_pcramo
	        || ','
	        || v_psproduc
	        || ','
	        || v_pcagente
	        || ','
	        || v_pnpoliza
	        || ','
	        || v_pncertif
	        || ','
	        || chr(39)
	        || to_char(pfhasta, 'dd/mm/yyyy')
	        || chr(39)
	        || ','
	        || pngenerar
	        || ')'
	        || ';'
	        || 'END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':V_SQUERY', v_squery, 10000);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'V_SQUERY', v_squery);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    OPEN retorno FOR v_squery;

	    RETURN retorno;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'PARAMETROS OBLIGATORIOS NO INFORMADOS '
	                                                               || vparam, SQLERRM);

	             RETURN NULL; WHEN ex_nodeclared THEN
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN NULL; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'parametros: '
	                                                               || vparam, SQLERRM);

	             RETURN NULL;
	END f_get_datos_apunte_fe_vida;

	/*FIN -Bug 15884 - ETM - 13/09/2010 - CEM - Fe de Vida.*/
	/**********************************************************************
	  FUNCTION F_PERMITE_EDAD_RESCATE
	   -- Funci¿n que valida si se puede hacer un rescate antes de cierta edad
	  Par¿metros
	   1.   psseguro. Identificador del seguro.
	   2.   pnriesgo. Identificador del riesgo.
	   3.   pfsinies. Fecha del siniestro.
	   4.   pccausin. Causa del siniestro
	   5.   ptablas. Identificador de tablas (EST, SEG)
	  **********************************************************************/
	/* Bug 16095 - APD - 04/11/2010*/
	/* se crea la funcion f_permite_edad_rescate*/
	FUNCTION f_permite_edad_rescate(
			psseguro	IN	NUMBER,
			pnriesgo	IN	NUMBER,
			pfsinies	IN	DATE,
			pccausin	IN	NUMBER,
			ptablas	IN	VARCHAR2 DEFAULT NULL
	) RETURN NUMBER
	IS
	  ss        VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_cempres seguros.cempres%TYPE;
	  retorno   NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	  /* Se debe declarar el componente*/
	  /* Bug 11232 - 23/10/2009 - RSC - 11232: APR - estado de las garantias ya pagadas*/
	  v_nriesgo VARCHAR2(100);
	BEGIN
	    IF psseguro IS NULL  OR
	       pnriesgo IS NULL  OR
	       pfsinies IS NULL  OR
	       pccausin IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    BEGIN
	        IF ptablas='EST' THEN
	          SELECT cempres
	            INTO v_cempres
	            FROM estseguros
	           WHERE sseguro=psseguro;
	        ELSE
	          SELECT cempres
	            INTO v_cempres
	            FROM seguros
	           WHERE sseguro=psseguro;
	        END IF;
	    EXCEPTION
	        WHEN OTHERS THEN
	          RETURN 140999;
	    END;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'f_permite_edad_rescate('
	        || psseguro
	        || ','
	        || pnriesgo
	        || ','
	        || to_char(pfsinies, 'YYYYMMDD')
	        || ','
	        || pccausin
	        || ')'
	        || ';'
	        || 'END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.F_PERMITE_EDAD_RESCATE', 1, 'PARAMETROS OBLIGATORIOS NO INFORMADOS '
	                                                                                    || 'psseguro = '
	                                                                                    || psseguro
	                                                                                    || ' pnriesgo ='
	                                                                                    || pnriesgo
	                                                                                    || ' pfsinies ='
	                                                                                    || pfsinies
	                                                                                    || ' pccausin ='
	                                                                                    || pccausin, SQLERRM);

	             RETURN 180261; /* Faltan datos obligatorios*/
	  WHEN ex_nodeclared THEN
	             /*
	               Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
	               a una funci¿n, procedimiento, etc. inexistente o no declarado.
	             */
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             /* Bug 16095 - RSC - 01/12/2010 - APR - Implementaci¿n y parametrizaci¿n del producto GROUPLIFE*/
	             RETURN 0; /* Error al llamar procedimiento o funci¿n/SQL*/
	/* Fin Bug 16095*/
	END f_permite_edad_rescate;

	/**********************************************************************
	  FUNCTION F_VALIDAGARANTIA
	  Validaciones garantias
	   Param IN psseguro: sseguro
	   Param IN pnriesgo: nriesgo
	   Param IN pcgarant: cgarant
	  **********************************************************************/--BUG 16106 - 05/11/2010 - JTS
	FUNCTION f_validagarantia(
			psseguro	IN	NUMBER,
			pnmovimi	IN	NUMBER,
			pnriesgo	IN	NUMBER,
			pcgarant	IN	NUMBER
	) RETURN NUMBER
	IS
	  ss        VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_cempres seguros.cempres%TYPE;
	  retorno   NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	  /* Se debe declarar el componente*/
	  v_nriesgo VARCHAR2(100);
	BEGIN
	    IF psseguro IS NULL  OR
	       pnriesgo IS NULL  OR
	       pnmovimi IS NULL  OR
	       pcgarant IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    BEGIN
	        SELECT cempres
	          INTO v_cempres
	          FROM estseguros
	         WHERE sseguro=psseguro;
	    EXCEPTION
	        WHEN OTHERS THEN BEGIN
	              SELECT cempres
	                INTO v_cempres
	                FROM seguros
	               WHERE sseguro=psseguro;
	          EXCEPTION
	              WHEN OTHERS THEN
	                RETURN 140999;
	          END;
	    END;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'f_validagarantia('
	        || psseguro
	        || ','
	        || pnmovimi
	        || ','
	        || pnriesgo
	        || ','
	        || pcgarant
	        || ')'
	        || ';'
	        || 'END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.F_VALIDAGARANTIA', 1, 'PARAMETROS OBLIGATORIOS NO INFORMADOS '
	                                                                              || 'psseguro = '
	                                                                              || psseguro
	                                                                              || ' pnriesgo ='
	                                                                              || pnriesgo
	                                                                              || ' pnmovimi ='
	                                                                              || pnmovimi
	                                                                              || ' pcgarant ='
	                                                                              || pcgarant, SQLERRM);

	             RETURN 180261; /* Faltan datos obligatorios*/
	  WHEN ex_nodeclared THEN
	             /*
	               Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
	               a una funci¿n, procedimiento, etc. inexistente o no declarado.
	             */
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN 0;
	END f_validagarantia;

	/***********************************************************************
	       FUNCTION f_contador2
	       Devuelve un nuevo valor del contador.
	       param in p_cempres: c¿digo de la empresa
	       param in p_tipo: tipo  -> '01': siniestro
	                              -> '02': poliza
	                              -> '03': recibos
	                              -> '04': recibos pruebas
	       param in p_caux: c¿digo de empresa para los recibos y c¿digo de ramo
	                        para el resto
	       param in p_exp: n¿mero de d¿gitos a concatenar a p_caux
	       return:         nuevo n¿mero de secuencia
	***********************************************************************/
	/* BUG 17008 - 15/12/2010 - JMP - Se a¿ade la funci¿n*/
	FUNCTION f_contador2(
			p_cempres	IN	NUMBER,
			p_tipo	IN	VARCHAR2,
			p_caux	IN	NUMBER,
			p_exp	IN	NUMBER DEFAULT 6
	) RETURN NUMBER
	IS
	  v_ss      VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_retorno NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	/* Se debe declarar el componente*/
	BEGIN
	    IF p_cempres IS NULL  OR
	       p_tipo IS NULL  OR
	       p_caux IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    SELECT pac_parametros.f_parempresa_t(p_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    v_ss:='BEGIN '
	          || ' :RETORNO := '
	          || v_propio
	          || '.'
	          || 'f_contador2('''
	          || p_tipo
	          || ''','
	          || p_caux
	          || ','
	          || p_exp
	          || ')'
	          || ';'
	          || 'END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, v_ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', v_retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', v_retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.F_CONTADOR2', 1, 'PARAMETROS OBLIGATORIOS NO INFORMADOS - '
	                                                                         || 'p_cempres = '
	                                                                         || p_cempres
	                                                                         || '; p_tipo = '
	                                                                         || p_tipo
	                                                                         || '; p_caux = '
	                                                                         || p_caux
	                                                                         || '; p_exp = '
	                                                                         || p_exp, SQLERRM);

	             RETURN NULL; WHEN ex_nodeclared THEN
	           /*  Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada*/
	             /*  a una funci¿n, procedimiento, etc. inexistente o no declarado.*/
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             /* Si la funci¿n no existe para la empresa, llamamos a la F_CONTADOR gen¿rica*/
	             RETURN f_contador(p_tipo, p_caux);
	END f_contador2;

	/*************************************************************************
	   FUNCTION f_cuadro_amortizacion
	     Obtiene el capital en funci¿n del cuadro de amortizaci¿n a una fecha

	   param in psseguro  : Identificador de seguro.
	   param in pfefecto  : Fecha efecto del prestamo
	   param in pfvencim  : Fecha de vencimiento del prestamo
	   param in pfecha    : Fecha de c¿lculo de obtenci¿n del valor
	   param in pmodo     : Par¿metro de garan¿a PRESTA_VINC.
	   return             : NUMBER
	*************************************************************************/
	/* Bug 15057 - RSC - 30/06/2010 - field capital by provisions SRD*/
	FUNCTION f_cuadro_amortizacion(
			psseguro	IN	NUMBER,
			pfefecto	IN	DATE,
			pfvencim	IN	DATE,
			pfecha	IN	DATE,
			pcgarant	IN	NUMBER,
			picapital	IN	NUMBER,
			pmodo	IN	NUMBER
	) RETURN NUMBER
	IS
	  ss        VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_cempres seguros.cempres%TYPE;
	  retorno   NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	/* Se debe declarar el componente*/
	BEGIN
	    BEGIN
	        SELECT cempres
	          INTO v_cempres
	          FROM seguros
	         WHERE sseguro=psseguro;
	    EXCEPTION
	        WHEN OTHERS THEN
	          RETURN 0; /* si no la encontramos no esta reducida*/
	    END;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    /* Bug 17633 - RSC - 10/02/2011 - field capital by provisions SRD (a¿ado REPLACE)*/
	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'f_cuadro_amortizacion('
	        || psseguro
	        || ', '
	        || to_number(to_char(pfefecto, 'YYYYMMDD'))
	        || ', '
	        || to_number(to_char(pfvencim, 'YYYYMMDD'))
	        || ', '
	        || to_number(to_char(pfecha, 'YYYYMMDD'))
	        || ', '
	        || pcgarant
	        || ', '
	        || replace(picapital, ',', '.')
	        || ', '
	        || pmodo
	        || ')'
	        || ';'
	        || 'END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             /*
	               Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
	               a una funci¿n, procedimiento, etc. inexistente o no declarado. En este
	               caso a continaci¿n ejecutamos el c¿digo tradicional para determinar
	               si la p¿liza est¿ o no reducida.
	             */
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN NULL;
	END f_cuadro_amortizacion;

	/* Fin Bug 15057*/
	/*************************************************************************
	    FUNCTION f_grabargar_modifdb
	    Determina si debe o no debe grabar el objeto garant¿as a BDD para el
	    motivo de movimiento indicado.
	    param in psseguro      : c¿digo del seguro
	    param in pcmotmov      : motivo de movimiento
	    return                 : 0 no grabar el objeto
	                             1 grabar el objeto
	*************************************************************************/
	/* Bug 17341 - 24/01/2011 - JMP - Se crea la funci¿n*/
	FUNCTION f_grabargar_modifdb(
			psseguro	IN	NUMBER,
			pcmotmov	IN	NUMBER
	) RETURN NUMBER
	IS
	  ss        VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_cempres seguros.cempres%TYPE;
	  v_sproduc seguros.sproduc%TYPE;
	  retorno   NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	/* Se debe declarar el componente*/
	BEGIN
	    BEGIN
	        SELECT cempres,sproduc
	          INTO v_cempres, v_sproduc
	          FROM seguros
	         WHERE sseguro=psseguro;
	    EXCEPTION
	        WHEN OTHERS THEN
	          RETURN 0; /* si no la encontramos no esta reducida*/
	    END;

	    IF nvl(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) NOT IN(1, 2) THEN
	      RETURN 0;
	    END IF;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'f_bloqueo_grabarobjectodb('
	        || pcmotmov
	        || ')'
	        || ';'
	        || 'END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             /*
	               Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
	               a una funci¿n, procedimiento, etc. inexistente o no declarado. En este
	               caso a continaci¿n ejecutamos el c¿digo tradicional para determinar
	               si la p¿liza est¿ o no reducida.
	             */
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN 0;
	END f_grabargar_modifdb;

	/*************************************************************************
	   FUNCTION f_calc_siniestro_interno
	   Calcula el n¿mero de siniestro interno de GRC
	   param in p_cagente  : Identificador del agente
	   param in p_nsinies  : Identificador de siniestro
	   return              : N¿mero de siniestro formato GRC
	   *************************************************************************/-- BUG 17567 - 07/02/2011 - APD - Se a¿ade la funci¿n
	FUNCTION f_calc_siniestro_interno(
			pcagente	IN	NUMBER,
			pnsinies	IN	NUMBER
	) RETURN VARCHAR2
	IS
	  v_propio  VARCHAR2(100);
	  ss        VARCHAR2(2000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_cempres seguros.cempres%TYPE;
	  retorno   VARCHAR2(20);
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	  /* Se debe declarar el componente*/
	  vcagente  historicoseguros.cagente%TYPE;
	  vsseguro  seguros.sseguro%TYPE;
	BEGIN
	    BEGIN
	        SELECT sseguro
	          INTO vsseguro
	          FROM sin_siniestro
	         WHERE nsinies=pnsinies;
	    EXCEPTION
	        WHEN OTHERS THEN
	          RETURN NULL;
	    END;

	    BEGIN
	        SELECT cagente
	          INTO vcagente
	          FROM historicoseguros
	         WHERE nmovimi=1 AND
	               sseguro=vsseguro;

	        SELECT cempres
	          INTO v_cempres
	          FROM seguros
	         WHERE sseguro=vsseguro;
	    EXCEPTION
	        WHEN OTHERS THEN BEGIN
	              SELECT cempres,cagente
	                INTO v_cempres, vcagente
	                FROM seguros
	               WHERE sseguro=vsseguro;
	          EXCEPTION
	              WHEN OTHERS THEN
	                RETURN NULL;
	          END;
	    END;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'f_calc_siniestro_interno('
	        || nvl(vcagente, pcagente)
	        || ','
	        || pnsinies
	        || ')'
	        || ';'
	        || 'END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno, 20);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             /*
	               Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
	               a una funci¿n, procedimiento, etc. inexistente o no declarado.
	             */
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN NULL; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_calc_siniestro_interno', 2, 'pnsinies:'
	                                                                                      || pnsinies
	                                                                                      || ' pcagente:'
	                                                                                      || pcagente, SQLCODE
	                                                                                                   || '-'
	                                                                                                   || SQLERRM);

	             RETURN NULL;
	END f_calc_siniestro_interno;

	/* Fin BUG 17567 - 10/02/2011 - APD*/
	/*************************************************************************
	   FUNCTION f_url_prodexterno
	   Devuelve la url del producto
	   param in psproduc : Identificador del producto
	   param in pcaccio : C¿digo de l'acci¿
	   param in pidpoliza  : Identificador de siniestro
	   return              : URL de la poliza

	   Bug 17806 - 28/02/2011 - AMC
	*************************************************************************/
	FUNCTION f_url_prodexterno(
			psproduc	IN	NUMBER,
			pcaccio	IN	VARCHAR2,
			pidpoliza	IN	VARCHAR2
	) RETURN VARCHAR2
	IS
	  v_cempres seguros.cempres%TYPE;
	  v_propio  VARCHAR2(100);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  ex_nodeclared EXCEPTION;
	  retorno   VARCHAR2(500);
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	  /* Se debe declarar el componente*/
	  ss        VARCHAR2(2000);
	  v_traza   NUMBER:=1;
	BEGIN
	    IF psproduc IS NOT NULL THEN BEGIN
	          SELECT c.cempres
	            INTO v_cempres
	            FROM codiram c,productos p
	           WHERE p.sproduc=psproduc AND
	                 c.cramo=p.cramo;
	      EXCEPTION
	          WHEN OTHERS THEN
	            p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_url_prodexterno', v_traza, 'psproduc: '
	                                                                                    || psproduc
	                                                                                    || ' no existe', SQLCODE
	                                                                                                     || '-'
	                                                                                                     || SQLERRM);

	            RETURN NULL;
	      END;
	    ELSIF pidpoliza IS NOT NULL THEN BEGIN
	          SELECT s.cempres
	            INTO v_cempres
	            FROM seguros s
	           WHERE s.npoliza=pidpoliza;
	      EXCEPTION
	          WHEN OTHERS THEN
	            p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_url_prodexterno', v_traza, 'pidpoliza: '
	                                                                                    || pidpoliza
	                                                                                    || ' no existe', SQLCODE
	                                                                                                     || '-'
	                                                                                                     || SQLERRM);

	            RETURN NULL;
	      END;
	    ELSE
	      p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_url_prodexterno', v_traza, 'faltan parametros', '');

	      RETURN NULL;
	    END IF;

	    v_traza:=2;

	    IF pcaccio IS NULL THEN
	      p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_url_prodexterno', v_traza, 'faltan parametros', '');

	      RETURN NULL;
	    END IF;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    v_traza:=3;

	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'f_url_prodexterno('
	        || psproduc
	        || ','''
	        || pcaccio
	        || ''','''
	        || pidpoliza
	        || ''')'
	        || ';'
	        || ' END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_traza:=4;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno, 500);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             /*
	               Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
	               a una funci¿n, procedimiento, etc. inexistente o no declarado. En este
	               caso a continaci¿n ejecutamos el c¿digo tradicional para determinar
	               si la p¿liza est¿ o no reducida.
	             */
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN NULL; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_url_prodexterno', v_traza, 'psproduc:'
	                                                                                     || psproduc
	                                                                                     || ' pcaccio:'
	                                                                                     || pcaccio
	                                                                                     || ' pidpoliza:'
	                                                                                     || pidpoliza, SQLCODE
	                                                                                                   || '-'
	                                                                                                   || SQLERRM);

	             RETURN NULL;
	END f_url_prodexterno;

	/*************************************************************************
	   FUNCTION f_get_planpoliza
	   Extrae el plan de la p¿lliza a partir del idproduc de ¿sta
	   param in pidproduc : identificador del producto
	   param in pccompani : identificador de la compa¿¿a
	   param in pcempres  : identificador de la empresa
	   return             : plan de la p¿liza

	   Bug 17922 - 05/04/2011 - SRA
	*************************************************************************/
	FUNCTION f_get_planpoliza(
			pidproduc	IN	NUMBER,
			pccompani	IN	NUMBER,
			psproduc	IN	NUMBER
	) RETURN VARCHAR2
	IS
	  vcempres seguros.cempres%TYPE;
	  vpropio  VARCHAR2(100);
	  vpasexec NUMBER:=1;
	  vcplan   VARCHAR2(3);
	BEGIN
	    vpasexec:=1;

	    BEGIN
	        SELECT c.cempres
	          INTO vcempres
	          FROM codiram c,productos p
	         WHERE p.sproduc=psproduc AND
	               c.cramo=p.cramo;
	    EXCEPTION
	        WHEN OTHERS THEN
	          p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_get_planpoliza', vpasexec, 'psproduc: '
	                                                                                  || psproduc
	                                                                                  || ' no existe', SQLCODE
	                                                                                                   || '-'
	                                                                                                   || SQLERRM);

	          RETURN NULL;
	    END;

	    vpasexec:=2;

	    SELECT pac_parametros.f_parempresa_t(vcempres, 'PAC_PROPIO')
	      INTO vpropio
	      FROM dual;

	    vpasexec:=3;

	    EXECUTE IMMEDIATE ('BEGIN :vplan := '|| vpropio|| '.f_get_planpoliza(:pidproduc, :pccompani); END;')
	    USING OUT vcplan, IN pidproduc, IN pccompani;

	    RETURN vcplan;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_get_planpoliza', vpasexec, 'psproduc:'
	                                                                                     || psproduc
	                                                                                     || ' pccompani:'
	                                                                                     || pccompani
	                                                                                     || ' psproduc:'
	                                                                                     || psproduc, SQLCODE
	                                                                                                  || '-'
	                                                                                                  || SQLERRM);

	             RETURN NULL;
	END f_get_planpoliza;

	/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
	/*************************************************************************
	   FUNCTION f_get_planpoliza
	   Extrae el plan de la p¿lliza a partir del idproduc de ¿sta
	   param in pidproduc : identificador del producto
	   param in pccompani : identificador de la compa¿¿a
	   param in pcempres  : identificador de la empresa
	   return             : plan de la p¿liza

	   Bug 17922 - 05/04/2011 - SRA
	*************************************************************************/
	FUNCTION f_get_lineapoliza(
			pidproduc	IN	NUMBER,
			pccompani	IN	NUMBER,
			psproduc	IN	NUMBER
	) RETURN VARCHAR2
	IS
	  vcempres seguros.cempres%TYPE;
	  vpropio  VARCHAR2(100);
	  vpasexec NUMBER:=1;
	  vclinea  VARCHAR2(10);
	BEGIN
	    vpasexec:=1;

	    BEGIN
	        SELECT c.cempres
	          INTO vcempres
	          FROM codiram c,productos p
	         WHERE p.sproduc=psproduc AND
	               c.cramo=p.cramo;
	    EXCEPTION
	        WHEN OTHERS THEN
	          p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_get_lineapoliza', vpasexec, 'psproduc: '
	                                                                                   || psproduc
	                                                                                   || ' no existe', SQLCODE
	                                                                                                    || '-'
	                                                                                                    || SQLERRM);

	          RETURN NULL;
	    END;

	    vpasexec:=2;

	    SELECT pac_parametros.f_parempresa_t(vcempres, 'PAC_PROPIO')
	      INTO vpropio
	      FROM dual;

	    vpasexec:=3;

	    EXECUTE IMMEDIATE ('BEGIN :vplan := '|| vpropio|| '.f_get_lineapoliza(:pidproduc, :pccompani); END;')
	    USING OUT vclinea, IN pidproduc, IN pccompani;

	    RETURN vclinea;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_get_lineapoliza', vpasexec, 'psproduc:'
	                                                                                      || psproduc
	                                                                                      || ' pccompani:'
	                                                                                      || pccompani
	                                                                                      || ' psproduc:'
	                                                                                      || psproduc, SQLCODE
	                                                                                                   || '-'
	                                                                                                   || SQLERRM);

	             RETURN NULL;
	END f_get_lineapoliza;

	/***********************************************************************
	       FUNCTION f_numero_solici,
	       Devuelve un nuevo solicitud.
	       param in p_cempres: c¿digo de la empresa
	       param in p_cramo: c¿digo de ramo
	       return:         nuevo n¿mero de secuencia
	***********************************************************************/
	/* BUG 0019332 - 30/08/2011 - JMF*/
	FUNCTION f_numero_solici(
			p_cempres	IN	NUMBER,
			p_cramo	IN	NUMBER
	) RETURN NUMBER
	IS
	  v_propio  VARCHAR2(50);
	  v_ss      VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_retorno NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	/* Se debe declarar el componente*/
	BEGIN
	    IF p_cempres IS NULL  OR
	       p_cramo IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    SELECT pac_parametros.f_parempresa_t(p_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    v_ss:='BEGIN '
	          || ' :RETORNO := '
	          || v_propio
	          || '.'
	          || 'f_nsolici('
	          || p_cramo
	          || ')'
	          || ';'
	          || ' END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, v_ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', v_retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', v_retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.F_NUMERO_SOLICI', 1, 'PARAMETROS OBLIGATORIOS NO INFORMADOS - '
	                                                                             || 'p_cempres = '
	                                                                             || p_cempres
	                                                                             || '; p_cramo = '
	                                                                             || p_cramo, SQLERRM);

	             RETURN NULL; WHEN ex_nodeclared THEN
	           /*  Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada*/
	             /*  a una funci¿n, procedimiento, etc. inexistente o no declarado.*/
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             /* Si la funci¿n no existe para la empresa, llamamos a la F_CONTADOR gen¿rica*/
	             SELECT (p_cramo*1000000)+ssolicit.NEXTVAL
	               INTO v_retorno
	               FROM dual;

	             RETURN v_retorno;
	END f_numero_solici;

	/***********************************************************************
	   Mira si una poliza tiene un siniestro de exoneracion de primas
	   param in psseguro      : Clave de Seguros
	   return                 : Number 0=no 1=si
	***********************************************************************/
	/* Bug 0019416:ASN:08/11/2011*/
	FUNCTION f_esta_en_exoneracion(
			p_sseguro	IN	seguros.sseguro%TYPE
	) RETURN NUMBER
	IS
	  v_cont    NUMBER;
	  v_ss      VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_retorno NUMBER;
	  ex_nodeclared EXCEPTION;
	  e_param_error EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	/* Se debe declarar el componente*/
	BEGIN
	    IF p_sseguro IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    v_ss:='BEGIN '
	          || ' :RETORNO := '
	          || v_propio
	          || '.'
	          || 'f_esta_en_exoneracion('
	          || p_sseguro
	          || ')'
	          || ';'
	          || 'END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, v_ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', v_retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', v_retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.F_ESTA_EN_EXONERACION', 1, 'PARAMETROS OBLIGATORIOS NO INFORMADOS - '
	                                                                                   || '; p_sseguro = '
	                                                                                   || p_sseguro, SQLERRM);

	             RETURN NULL; WHEN ex_nodeclared THEN
	           /*  Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada*/
	             /*  a una funci¿n, procedimiento, etc. inexistente o no declarado.*/
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             /* Si la funci¿n no existe para la empresa, tratamiento gen¿rico*/
	             SELECT decode(count(*), 0, 0,
	                                     1)
	               INTO v_cont
	               FROM sin_siniestro s,sin_movsiniestro m,seguros seg
	              WHERE s.sseguro=p_sseguro AND
	                    s.sseguro=seg.sseguro AND
	                    m.nsinies=s.nsinies AND
	                    m.nmovsin=(SELECT max(nmovsin)
	                                 FROM sin_movsiniestro m1
	                                WHERE m1.nsinies=m.nsinies) AND
	                    ccausin=nvl(pac_parametros.f_parproducto_n(seg.sproduc, 'CCAUSIN_EXONERACION'), 2410) AND
	                    cmotsin=nvl(pac_parametros.f_parproducto_n(seg.sproduc, 'CMOTSIN_EXONERACION'), 1) AND
	                    cestsin IN(0, 4);

	             RETURN v_cont;
	END f_esta_en_exoneracion;

	/*************************************************************************
	   FUNCTION f_exonera_recibos
	     Da por cobrados los recibos generados en cartera
	     y crea un pago de siniestro para compensar estos recibos
	     param in psseguro  : Identificador de seguro.
	     param in pfecha    : Fecha de cartera
	     return             : number

	   Bug 19416 - 02/10/2011 - ASN - LCOL_S001-Siniestros y exoneraci¿n de pago de primas
	*************************************************************************/
	FUNCTION f_exonera_recibos(
			p_sseguro	IN	seguros.sseguro%TYPE,
			p_fecha_cartera	IN	DATE,
			p_envio	IN	NUMBER DEFAULT 0
	) RETURN NUMBER
	IS
	  v_cont    NUMBER;
	  v_ss      VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_retorno NUMBER;
	  ex_nodeclared EXCEPTION;
	  e_param_error EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	/* Se debe declarar el componente*/
	BEGIN
	    IF p_sseguro IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    v_ss:='BEGIN '
	          || ' :RETORNO := '
	          || v_propio
	          || '.'
	          || 'f_exonera_recibos('
	          || p_sseguro
	          || ','
	          || 'to_date('''
	          || to_char(p_fecha_cartera, 'ddmmyyyy')
	          || ''', ''ddmmyyyy'')'
	          || ','
	          || p_envio
	          || ')'
	          || ';'
	          || 'END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, v_ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', v_retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', v_retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.F_EXONERA_RECIBOS', 1, 'PARAMETROS OBLIGATORIOS NO INFORMADOS - '
	                                                                               || '; p_sseguro = '
	                                                                               || p_sseguro, SQLERRM);

	             RETURN NULL; WHEN ex_nodeclared THEN
	           /*  Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada*/
	             /*  a una funci¿n, procedimiento, etc. inexistente o no declarado.*/
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN 0;
	END f_exonera_recibos;
	FUNCTION f_irescate_rie(
			psseguro	IN	NUMBER,
			pfecha	IN	DATE,
			pcgarant	IN	NUMBER DEFAULT NULL
	) RETURN NUMBER
	IS
	  xireserva NUMBER;
	BEGIN
	    xireserva:=pac_provmat_formul.f_calcul_formulas_provi(psseguro, pfecha, 'IPROVRES', pcgarant);

	    RETURN xireserva;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, getuser, 'pac_propio.f_irescate_rie', NULL, 'psseguro = '
	                                                                                || psseguro
	                                                                                || ' pfecha ='
	                                                                                || pfecha, SQLERRM);

	             RETURN NULL;
	END f_irescate_rie;

	/*Ini Bug: 20254 - 24/11/2011 - JMC*/
	/*************************************************************************
	   FUNCTION f_pago_renta_aut
	   Crea un pago de renta autom¿tico
	   param in pmes    : mes de la reserva
	   param in panyo   : a¿o de la reserva
	   param out psproces : Num. proceso
	   return           : c¿digo de error
	   Bug 0014347 - 07/06/2010 - FAL
	*************************************************************************/
	FUNCTION f_pago_renta_aut(pmes	IN	NUMBER,panyo	IN	NUMBER,pcgarant	IN	NUMBER,pncobros	OUT	NUMBER,pwhere	IN	VARCHAR2 DEFAULT NULL,pcempres	IN	NUMBER DEFAULT NULL,/* Bug 15044 - 08/11/2010 - XPL*/psproces	IN	OUT NUMBER /* Bug 16580 - 15/11/2010 - AMC*/

	)
	RETURN NUMBER
	IS
	CURSOR c_sinies(

	    v_sproduc IN NUMBER) IS
	    SELECT s.fsinies,s.nsinies,v.cgarant,v.fmovres,s.falta,s.sseguro,s.ccausin,s.cmotsin,s.fnotifi,s.nriesgo,sg.sproduc,pac_seguros.ff_get_actividad(s.sseguro, s.nriesgo) cactivi,v.fultpag,v.fresini,v.fresfin,v.ireserva,pr.nnumpag,sg.cbancar,sg.ctipban,sm.ntramit,v.ctipres,v.nmovres,sg.cempres,v.cmonres
	      FROM sin_siniestro s,sin_tramita_movimiento sm,sin_tramita_reserva v,seguros sg,productos pr,sin_movsiniestro m
	     WHERE s.nsinies=m.nsinies AND
	           m.nmovsin=(SELECT max(nmovsin)
	                        FROM sin_movsiniestro
	                       WHERE nsinies=s.nsinies) AND
	           m.cestsin IN(0, 4) AND
	           sm.csubtra=27 AND
	           sm.nmovtra=(SELECT max(nmovtra)
	                         FROM sin_tramita_movimiento
	                        WHERE nsinies=s.nsinies AND
	                              ntramit=sm.ntramit) AND
	           s.nsinies=v.nsinies AND
	           s.sseguro=sg.sseguro AND
	           pr.cramo=sg.cramo AND
	           pr.ctipseg=sg.ctipseg AND
	           pr.ccolect=sg.ccolect AND
	           (pcempres IS NULL  OR
	            sg.cempres=pcempres) AND
	           pr.cmodali=sg.cmodali AND
	           s.nsinies=sm.nsinies AND
	           sm.ntramit=v.ntramit AND
	           v.ctipres=1 /* jlb - 18423#c105054*/
	           AND
	           ((v.fresini<=last_day(to_date('01/'
	                                         || to_char(pmes)
	                                         || '/'
	                                         || to_char(panyo))) AND
	             v.fultpag IS NULL)  OR
	            (v.fultpag<=last_day(to_date('01/'
	                                         || to_char(pmes)
	                                         || '/'
	                                         || to_char(panyo))) AND
	             v.fultpag IS NOT NULL AND
	             v.fresfin<>v.fultpag)) AND
	           (v.cgarant=pcgarant  OR
	            pcgarant IS NULL) AND
	           nvl(pac_parametros.f_pargaranpro_n(sg.sproduc, sg.cactivi, v.cgarant, 'GARRENTA'), 0)=1 AND
	           v.nmovres=(SELECT max(nmovres)
	                        FROM sin_tramita_reserva r
	                       WHERE r.nsinies=v.nsinies AND
	                             r.ctipres=v.ctipres AND
	                             r.ntramit=v.ntramit AND
	                             r.cgarant=v.cgarant AND
	                             r.fresini=v.fresini)
	           /* AND r.fresfin = v.fresfin)  -- BUG18502:DRA:12/05/2011*/
	           AND
	           ((v_sproduc IS NOT NULL AND
	             pr.sproduc=v_sproduc)  OR
	            v_sproduc IS NULL) /*-- Bug 15044 - 08/11/2010 - XPL*/
	     ORDER BY s.nsinies ASC;

	  v_cgarant      sin_tramita_reserva.cgarant%TYPE;
	  v_error        NUMBER;
	  v_provisio     sin_tramita_reserva.ireserva%TYPE;
	  v_fresini      DATE;
	  v_fresfin      DATE;
	  v_destinatario NUMBER;
	  v_ctipdes      sin_det_causa_motivo.ctipdes%TYPE;
	  /*    v_movimi       NUMBER(4);*/
	  v_ccc          VARCHAR2(4000);
	  n_error        NUMBER;
	  v_ctipban      sin_tramita_destinatario.ctipban%TYPE;
	  vsidepag       sin_tramita_pago.sidepag%TYPE;
	  vipago         NUMBER;
	  vsperson       asegurados.sperson%TYPE;
	  vcpaisre       per_detper.cpais%TYPE;
	  vcagente       seguros.cagente%TYPE;
	  vcobros        NUMBER:=0;
	  vquery         VARCHAR2(4000);
	  pos            NUMBER;
	  tipo           VARCHAR2(2000);
	  posdp          NUMBER;
	  vsproduc       NUMBER;
	  vwhere         VARCHAR2(2000):='||';
	  vsprogar       sin_tramita_pago.sproces%TYPE;
	  /*Ini Bug: 20254 - 24/11/2011 - JMC - Variables para la llamada dinamica*/
	  v_ss           VARCHAR2(3000);
	  v_cursor       NUMBER;
	  v_filas        NUMBER;
	  v_propio       VARCHAR2(50);
	  v_retorno      NUMBER;
	  v_pncobros     NUMBER;
	  v_psproces     NUMBER;
	  x_cgarant      VARCHAR2(10);
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	  /* Se debe declarar el componente*/
	  /*Fin Bug: 20254 - 24/11/2011 - JMC*/
	  v_cempres      seguros.cempres%TYPE;
	  v_cmultimon    parempresas.nvalpar%TYPE;
	BEGIN
	    /*Ini Bug: 20254 - 24/11/2011 - JMC - Llamada din¿mica a f_pago_renta_aut*/
	    SELECT pac_parametros.f_parempresa_t(pcempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    IF pcgarant IS NULL THEN
	      x_cgarant:='NULL';
	    ELSE
	      x_cgarant:=to_char(pcgarant);
	    END IF;

	    v_ss:='BEGIN '
	          || ' :RETORNO := '
	          || v_propio
	          || '.'
	          || 'f_pago_renta_aut('
	          || pmes
	          || ','
	          || panyo
	          || ','
	          || x_cgarant
	          || ', :pncobros, '''
	          || pwhere
	          || ''','
	          || pcempres
	          || ', :psproces)'
	          || ';'
	          || 'END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, v_ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', v_retorno);

	    dbms_sql.bind_variable(v_cursor, ':pncobros', v_pncobros);

	    dbms_sql.bind_variable(v_cursor, ':psproces', v_psproces);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', v_retorno);

	    dbms_sql.variable_value(v_cursor, 'pncobros', v_pncobros);

	    dbms_sql.variable_value(v_cursor, 'psproces', v_psproces);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    pncobros:=v_pncobros;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	           /*  Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada*/
	             /*  a una funci¿n, procedimiento, etc. inexistente o no declarado.*/
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             BEGIN
	                 /*Fin Bug: 20254 - 24/11/2011 - JMC*/
	                 IF pwhere IS NOT NULL THEN
	                   vwhere:=pwhere;
	                 END IF;

	                 SELECT sprogar.NEXTVAL
	                   INTO vsprogar
	                   FROM dual;

	                 FOR i IN 1 .. length(vwhere) LOOP
	                     IF pwhere IS NOT NULL THEN
	                       pos:=instr(pwhere, '|', 1, i);

	                       posdp:=instr(pwhere, '|', 1, i+1);

	                       vsproduc:=substr(pwhere, pos+1, (posdp-pos)-1);
	                     END IF;

	                     IF vsproduc IS NOT NULL  OR
	                        pwhere IS NULL THEN
	                       FOR sini IN c_sinies(vsproduc) LOOP
	                           /* BUG 18423 - 16/01/2012 - JMP - Multimoneda*/
	                           IF v_cempres IS NULL  OR
	                              sini.cempres<>v_cempres THEN
	                             v_cempres:=sini.cempres;

	                             v_cmultimon:=nvl(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);
	                           END IF;

	                           /* FIN BUG 18423 - 16/01/2012 - JMP - Multimoneda*/
	                           BEGIN
	                               SELECT ireserva
	                                 INTO v_provisio
	                                 FROM sin_tramita_reserva
	                                WHERE nsinies=sini.nsinies AND
	                                      ntramit=sini.ntramit AND
	                                      ctipres=sini.ctipres AND
	                                      cgarant=sini.cgarant AND
	                                      nmovres=(SELECT max(nmovres)
	                                                 FROM sin_tramita_reserva
	                                                WHERE nsinies=sini.nsinies AND
	                                                      ntramit=sini.ntramit AND
	                                                      ctipres=sini.ctipres AND
	                                                      cgarant=sini.cgarant);
	                           EXCEPTION
	                               WHEN no_data_found THEN
	                                 v_provisio:=0;
	                           END;

	                           /* BUG 17677 - 24/02/2011 - JMP - Aunque la provisi¿n sea 0, se debe actualizar la FULTPAG de la reserva*/
	                           /*                                para que el proceso no la vuelva a tratar.*/
	                           IF v_provisio=0 THEN
	                             UPDATE sin_tramita_reserva
	                                SET fultpag=sini.fresfin,ipago=0,ipago_moncia=decode(v_cmultimon, 0, NULL,
	                                                                                                  0)
	                              /* BUG 18423 - 16/01/2012 - JMP - Multimoneda*/
	                              WHERE nsinies=sini.nsinies AND
	                                    ntramit=sini.ntramit AND
	                                    ctipres=sini.ctipres AND
	                                    nmovres=sini.nmovres;
	                           ELSIF v_provisio>0
	                                 /* FIN BUG 17677 - 24/02/2011 - JMP*/
	                                 AND
	                                 sini.fresini<=sini.fresfin THEN
	                             IF sini.fultpag IS NULL THEN
	                               v_fresini:=sini.fresini;
	                             ELSE
	                               v_fresini:=sini.fultpag+1;
	                             END IF;

	                             IF sini.fresfin<=last_day(to_date('01/'
	                                                               || to_char(pmes)
	                                                               || '/'
	                                                               || to_char(panyo))) THEN
	                               v_fresfin:=sini.fresfin;
	                             ELSE
	                               v_fresfin:=last_day(to_date('01/'
	                                                           || to_char(pmes)
	                                                           || '/'
	                                                           || to_char(panyo)));
	                             END IF;

	                             SELECT count(1)
	                               INTO v_destinatario
	                               FROM sin_tramita_destinatario
	                              WHERE nsinies=sini.nsinies AND
	                                    ntramit=sini.ntramit;

	                             IF v_destinatario=0 THEN
	                               SELECT DISTINCT (ctipdes)
	                                 INTO v_ctipdes
	                                 FROM sin_det_causa_motivo
	                                WHERE ctipdes<>0 AND
	                                      scaumot IN(SELECT sg.scaumot
	                                                   FROM sin_gar_causa_motivo sg,sin_causa_motivo sc
	                                                  WHERE sg.sproduc=sini.sproduc AND
	                                                        sg.cgarant=sini.cgarant AND
	                                                        sg.cactivi=sini.cactivi AND
	                                                        sg.scaumot=sc.scaumot AND
	                                                        sc.ccausin=sini.ccausin AND
	                                                        sc.cmotsin=sini.cmotsin);

	                             /* BUG14289:DRA:03/05/2010:Inici*/
	                             /*SELECT MAX(nmovimi)*/
	                             /*  INTO v_movimi*/
	                             /*  FROM movseguro*/
	                             /* WHERE sseguro = sini.sseguro;*/
	                               /*v_movimi := pac_movseguro.f_nmovimi_valido(sini.sseguro);*/
	                               v_ccc:=NULL;

	                               v_ctipban:=NULL;

	                               /* BUG14289:DRA:03/05/2010:Fi*/
	                               SELECT s.cagente
	                                 INTO vcagente
	                                 FROM seguros s,sin_siniestro si
	                                WHERE s.sseguro=si.sseguro AND
	                                      si.nsinies=sini.nsinies;

	                               SELECT a.sperson,p.cpais
	                                 INTO vsperson, vcpaisre
	                                 FROM asegurados a,per_detper p
	                                WHERE a.sseguro=sini.sseguro AND
	                                      a.norden=1 AND
	                                      p.sperson=a.sperson AND
	                                      p.cagente=ff_agente_cpervisio(vcagente);

	                               v_error:=pac_siniestros.f_ins_destinatario(sini.nsinies, sini.ntramit, vsperson,
	                                        /*                                             NVL(v_ccc, sini.cbancar),*/
	                                        sini.cbancar,
	                                        /*                                             NVL(v_ctipban, sini.ctipban), 100, vcpaisre,*/
	                                        sini.ctipban, 100, vcpaisre, v_ctipdes, 1, NULL);

	                               IF v_error<>0 THEN
	                                 RETURN v_error;
	                               END IF;
	                             END IF;

	                             v_error:=pac_sin_formula.f_genera_pago(sini.sseguro, sini.nriesgo,
	                                      /* Bug 16219. FAL. 06/10/2010. Parametrizar que la generaci¿n del pago sea por garantia*/
	                                      sini.cgarant,
	                                      /* Fi Bug 16219*/
	                                      sini.sproduc, sini.cactivi, sini.nsinies, sini.ntramit, sini.ccausin, sini.cmotsin, sini.fsinies, sini.fnotifi, v_fresini, v_fresfin);

	                             IF v_error<>0 THEN
	                               RETURN v_error;
	                             END IF;

	                             v_error:=pac_sin_formula.f_inserta_pago(sini.nsinies, sini.ntramit, sini.ctipres, sini.cgarant, vsidepag, vipago);

	                             IF v_error=0 THEN
	                               UPDATE sin_tramita_reserva
	                                  SET fultpag=least(v_fresfin, fresfin)
	                                WHERE nsinies=sini.nsinies AND
	                                      cgarant=sini.cgarant AND
	                                      ctipres=sini.ctipres /* jlb moneda.*/
	                                      AND
	                                      ntramit=sini.ntramit /* jlb moneda.*/
	                                      AND
	                                      (v_fresini BETWEEN fresini AND fresfin  OR
	                                       v_fresfin BETWEEN fresini AND fresfin) AND
	                                      nmovres=(SELECT max(nmovres)
	                                                 FROM sin_tramita_reserva r
	                                                WHERE nsinies=sini.nsinies AND
	                                                      ctipres=sini.ctipres AND
	                                                      ntramit=sini.ntramit AND
	                                                      cgarant=sini.cgarant AND
	                                                      fresini=sini.fresini);

	                               /* AND r.fresfin = v.fresfin)  -- BUG18502:DRA:12/05/2011*/
	                               UPDATE sin_tramita_pago
	                                  SET sproces=vsprogar
	                                WHERE sidepag=vsidepag;

	                               vcobros:=vcobros+1;

	                               psproces:=vsprogar;
	                             ELSE
	                               RETURN v_error;
	                             END IF;
	                           END IF;
	                       END LOOP;
	                     END IF;
	                 END LOOP;

	                 pncobros:=vcobros;

	                 RETURN 0;
	             EXCEPTION
	                 WHEN no_data_found THEN
	                   p_tab_error(f_sysdate, f_user, 'pac_propio.f_pago_renta_aut', 1, 'Error no controlado', SQLERRM);

	                   RETURN 101667;
	                 WHEN OTHERS THEN
	                   p_tab_error(f_sysdate, f_user, 'pac_propio.f_pago_renta_aut', 1, 'Error no controlado', SQLERRM);

	                   RETURN SQLCODE;
	             END;
	END f_pago_renta_aut;

	/*Fin Bug: 20254 - 24/11/2011 - JMC*/
	FUNCTION f_get_param_salpro(
			psseguro	IN	NUMBER,
			pnriesgo	IN	NUMBER,
			pmode	IN	VARCHAR2,
			pirescate	IN	NUMBER,
			piprovi	IN	NUMBER,
			pimprecpen	IN	NUMBER,
			pisaldoprest	IN	NUMBER,
			piprimafinan_pen	IN	NUMBER,
			piprima_np	OUT	NUMBER,
			picapfall_np	OUT	NUMBER,
			pfvencim_np	OUT	DATE
	) RETURN NUMBER
	IS
	  v_cont    NUMBER;
	  v_ss      VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_retorno NUMBER;
	  ex_nodeclared EXCEPTION;
	  e_param_error EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	/* Se debe declarar el componente*/
	BEGIN
	    IF psseguro IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    v_ss:='BEGIN '
	          || ' :RETORNO := '
	          || v_propio
	          || '.'
	          || 'f_get_param_salpro('
	          || psseguro
	          || ','
	          || pnriesgo
	          || ','
	          || chr(39)
	          || pmode
	          || chr(39)
	          || ','
	          || chr(39)
	          || pirescate
	          || chr(39)
	          || ','
	          || chr(39)
	          || piprovi
	          || chr(39)
	          || ','
	          || chr(39)
	          || pimprecpen
	          || chr(39)
	          || ','
	          || chr(39)
	          || pisaldoprest
	          || chr(39)
	          || ','
	          || chr(39)
	          || piprimafinan_pen
	          || chr(39)
	          || ', :piprima_np, :picapfall_np, :pfvencim_np)'
	          || ';'
	          || 'END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, v_ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', v_retorno);

	    dbms_sql.bind_variable(v_cursor, ':piprima_np', piprima_np);

	    dbms_sql.bind_variable(v_cursor, ':picapfall_np', picapfall_np);

	    dbms_sql.bind_variable(v_cursor, ':pfvencim_np', pfvencim_np);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', v_retorno);

	    dbms_sql.variable_value(v_cursor, 'piprima_np', piprima_np);

	    dbms_sql.variable_value(v_cursor, 'picapfall_np', picapfall_np);

	    dbms_sql.variable_value(v_cursor, 'pfvencim_np', pfvencim_np);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.F_f_get_param_salpro', 1, 'PARAMETROS OBLIGATORIOS NO INFORMADOS - '
	                                                                                  || '; p_sseguro = '
	                                                                                  || psseguro, SQLERRM);

	             RETURN NULL; WHEN ex_nodeclared THEN
	           /*  Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada*/
	             /*  a una funci¿n, procedimiento, etc. inexistente o no declarado.*/
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN 0;
	END f_get_param_salpro;

	/*************************************************************************
	   FUNCTION f_valdireccion
	     param in pcsiglas : Tipo de via
	     param in ptnomvia : Nombre o numero via
	     param in pcdet1ia : detalle 1
	     param in ptnum1ia : numero 1
	     param in pcdet2ia : detalle 2
	     param in ptnum2ia : numero 2
	     param in pcdet3ia : detalle 3
	     param in ptnum3ia : numero 3
	     return           : c¿digo de error
	   Bug 20612/101253 - 21/12/2011 - AMC
	*************************************************************************/
	FUNCTION f_valdireccion(
			pcviavp	IN	estper_direcciones.cviavp%TYPE,
	ptnomvia	IN	VARCHAR2,
	pcdet1ia	IN	estper_direcciones.cdet1ia%TYPE,
	ptnum1ia	IN	estper_direcciones.tnum1ia%TYPE,
	pcdet2ia	IN	estper_direcciones.cdet2ia%TYPE,
	ptnum2ia	IN	estper_direcciones.tnum2ia%TYPE,
	pcdet3ia	IN	estper_direcciones.cdet3ia%TYPE,
	ptnum3ia	IN	estper_direcciones.tnum3ia%TYPE,
	pnnumvia	IN	NUMBER DEFAULT NULL,
			 /*Mantis 33515/215632 - BLA - DD15/MM10/2015.*/
			 potros	IN	VARCHAR2 DEFAULT NULL /*Mantis 33515/215632 - BLA - DD15/MM10/2015.*/

	)
	RETURN NUMBER
	IS
	  v_cont         NUMBER;
	  v_ss           VARCHAR2(3000);
	  v_cursor       NUMBER;
	  v_filas        NUMBER;
	  v_propio       VARCHAR2(50);
	  v_retorno      NUMBER;
	  ex_nodeclared EXCEPTION;
	  e_param_error EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	  v_dum_argument VARCHAR2(50);
	/* Se debe declarar el componente*/
	BEGIN
	    SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    v_ss:='BEGIN '
	          || ' :RETORNO := '
	          || v_propio
	          || '.'
	          || 'f_valdireccion('''
	          || pcviavp
	          || ''','''
	          || ptnomvia
	          || ''','''
	          || pcdet1ia
	          || ''','''
	          || ptnum1ia
	          || ''','''
	          || pcdet2ia
	          || ''','''
	          || ptnum2ia
	          || ''','''
	          || pcdet3ia
	          || ''','''
	          || ptnum3ia;

	    /*Inicio Mantis 33515/215632  - BLA - DD15/MM10/2015.*/
	    BEGIN
	        SELECT argument_name
	          INTO v_dum_argument
	          FROM user_arguments
	         WHERE object_id=(SELECT object_id
	                            FROM user_objects
	                           WHERE object_name=v_propio AND
	                                 object_type='PACKAGE') AND
	               lower(object_name)='f_valdireccion' AND
	               in_out='IN' AND
	               lower(argument_name)='pnnumvia';

	        v_ss:=v_ss
	              || ''','''
	              || pnnumvia;
	    EXCEPTION
	        WHEN no_data_found THEN
	          NULL;
	    END;

	    BEGIN
	        SELECT argument_name
	          INTO v_dum_argument
	          FROM user_arguments
	         WHERE object_id=(SELECT object_id
	                            FROM user_objects
	                           WHERE object_name=v_propio AND
	                                 object_type='PACKAGE') AND
	               lower(object_name)='f_valdireccion' AND
	               in_out='IN' AND
	               lower(argument_name)='potros';

	        v_ss:=v_ss
	              || ''','''
	              || potros;
	    EXCEPTION
	        WHEN no_data_found THEN
	          NULL;
	    END;

	    v_ss:=v_ss
	          || ''')'
	          || ';'
	          || 'END;';

	    /*Fin Mantis 33515/215632  - BLA - DD15/MM10/2015.*/
	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, v_ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', v_retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', v_retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_valdireccion', 1, 'PARAMETROS OBLIGATORIOS NO INFORMADOS  ', SQLERRM);

	             RETURN 103135; WHEN ex_nodeclared THEN
	           /*  Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada*/
	             /*  a una funci¿n, procedimiento, etc. inexistente o no declarado.*/
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN 0;
	END f_valdireccion;

	/***********************************************************************
	    FUNCTION f_tdomici

	    Bug 21703/110272 - 15/03/2012 - AMC
	***********************************************************************/
	FUNCTION f_tdomici(
			pcsiglas	IN	per_direcciones.csiglas%TYPE,
	ptnomvia	IN	per_direcciones.tnomvia%TYPE,
	pnnumvia	IN	per_direcciones.nnumvia%TYPE,
	ptcomple	IN	per_direcciones.tcomple%TYPE,
			 /* Bug 18940/92686 - 27/09/2011 - AMC*/
			 pcviavp	IN	per_direcciones.cviavp%TYPE DEFAULT NULL,
	pclitvp	IN	per_direcciones.clitvp%TYPE DEFAULT NULL,
	pcbisvp	IN	per_direcciones.cbisvp%TYPE DEFAULT NULL,
	pcorvp	IN	per_direcciones.corvp%TYPE DEFAULT NULL,
	pnviaadco	IN	per_direcciones.nviaadco%TYPE DEFAULT NULL,
	pclitco	IN	per_direcciones.clitco%TYPE DEFAULT NULL,
	pcorco	IN	per_direcciones.corco%TYPE DEFAULT NULL,
	pnplacaco	IN	per_direcciones.nplacaco%TYPE DEFAULT NULL,
	pcor2co	IN	per_direcciones.cor2co%TYPE DEFAULT NULL,
	pcdet1ia	IN	per_direcciones.cdet1ia%TYPE DEFAULT NULL,
	ptnum1ia	IN	per_direcciones.tnum1ia%TYPE DEFAULT NULL,
	pcdet2ia	IN	per_direcciones.cdet2ia%TYPE DEFAULT NULL,
	ptnum2ia	IN	per_direcciones.tnum2ia%TYPE DEFAULT NULL,
	pcdet3ia	IN	per_direcciones.cdet3ia%TYPE DEFAULT NULL,
	ptnum3ia	IN	per_direcciones.tnum3ia%TYPE DEFAULT NULL,
			 /* Fi Bug 18940/92686 - 27/09/2011 - AMC*/
			 plocalidad	IN	per_direcciones.localidad%TYPE DEFAULT NULL /* Bug 24780/130907 - 05/12/2012 - AMC*/

	)
	RETURN VARCHAR2
	IS
	  v_propio  VARCHAR2(100);
	  v_retorno VARCHAR2(2000);
	  /**/
	  vtraza    NUMBER;
	  /**/
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	  /* Se debe declarar el componente*/
	  v_cempres seguros.cempres%TYPE;
	BEGIN
	    vtraza:=1;

	    SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    vtraza:=2;

	    EXECUTE IMMEDIATE (' BEGIN '|| ' :v_retorno := '|| v_propio|| '.'|| 'f_tdomici('''|| pcsiglas|| ''','''|| ptnomvia|| ''','''|| pnnumvia|| ''','''|| ptcomple|| ''','''|| pcviavp|| ''','''|| pclitvp|| ''','''|| pcbisvp|| ''','''|| pcorvp|| ''','''|| pnviaadco|| ''','''|| pclitco|| ''','''|| pcorco|| ''','''|| pnplacaco|| ''','''|| pcor2co|| ''','''|| pcdet1ia|| ''','''|| ptnum1ia|| ''','''|| pcdet2ia|| ''','''|| ptnum2ia|| ''','''|| pcdet3ia|| ''','''|| ptnum3ia|| ''','''|| plocalidad /* Bug 24780/130907 - 05/12/2012 - AMC*/
	    || '''); END;')
	    USING OUT v_retorno;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	           /*  Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada*/
	           /*  a una funci¿n, procedimiento, etc. inexistente o no declarado.*/
	             /* Si la funci¿n no existe para la empresa, llamamos a la F_CONTADOR gen¿rica*/
	             RETURN f_tdomici_aux(pcsiglas, ptnomvia, pnnumvia, ptcomple, pcviavp, pclitvp, pcbisvp, pcorvp, pnviaadco, pclitco, pcorco, pnplacaco, pcor2co, pcdet1ia, ptnum1ia, pcdet2ia, ptnum2ia, pcdet3ia, ptnum3ia, plocalidad /* Bug 24780/130907 - 05/12/2012 - AMC*/
	                    ); WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_tdomici', vtraza, SQLCODE, SQLERRM);

	             RETURN 140999; /* Error no controlado*/
	END f_tdomici;

	/***********************************************************************
	    FUNCTION f_tdomici_aux

	    Bug 21703/110272 - 15/03/2012 - AMC
	***********************************************************************/
	FUNCTION f_tdomici_aux(
			pcsiglas	IN	per_direcciones.csiglas%TYPE,
	ptnomvia	IN	per_direcciones.tnomvia%TYPE,
	pnnumvia	IN	per_direcciones.nnumvia%TYPE,
	ptcomple	IN	per_direcciones.tcomple%TYPE,
			 /* Bug 18940/92686 - 27/09/2011 - AMC*/
			 pcviavp	IN	per_direcciones.cviavp%TYPE DEFAULT NULL,
	pclitvp	IN	per_direcciones.clitvp%TYPE DEFAULT NULL,
	pcbisvp	IN	per_direcciones.cbisvp%TYPE DEFAULT NULL,
	pcorvp	IN	per_direcciones.corvp%TYPE DEFAULT NULL,
	pnviaadco	IN	per_direcciones.nviaadco%TYPE DEFAULT NULL,
	pclitco	IN	per_direcciones.clitco%TYPE DEFAULT NULL,
	pcorco	IN	per_direcciones.corco%TYPE DEFAULT NULL,
	pnplacaco	IN	per_direcciones.nplacaco%TYPE DEFAULT NULL,
	pcor2co	IN	per_direcciones.cor2co%TYPE DEFAULT NULL,
	pcdet1ia	IN	per_direcciones.cdet1ia%TYPE DEFAULT NULL,
	ptnum1ia	IN	per_direcciones.tnum1ia%TYPE DEFAULT NULL,
	pcdet2ia	IN	per_direcciones.cdet2ia%TYPE DEFAULT NULL,
	ptnum2ia	IN	per_direcciones.tnum2ia%TYPE DEFAULT NULL,
	pcdet3ia	IN	per_direcciones.cdet3ia%TYPE DEFAULT NULL,
	ptnum3ia	IN	per_direcciones.tnum3ia%TYPE DEFAULT NULL,
			 /* Fi Bug 18940/92686 - 27/09/2011 - AMC*/
			 plocalidad	IN	per_direcciones.localidad%TYPE DEFAULT NULL /* Bug 24780/130907 - 05/12/2012 - AMC*/

	)
	RETURN VARCHAR2
	IS
	  vtsiglas tipos_via.tsiglas%TYPE:=NULL;
	  vnnomvia NUMBER;
	  vnnumvia NUMBER;
	  vncomple NUMBER;
	  vtdomici per_direcciones.tdomici%TYPE; /*JMC- 01/10/2010 - Bug 15495*/
	  tviavp   detvalores.tatribu%TYPE;
	  tdet1ia  detvalores.tatribu%TYPE;
	  tdet2ia  detvalores.tatribu%TYPE;
	  tdet3ia  detvalores.tatribu%TYPE;
	  tclitvp  detvalores.tatribu%TYPE;
	  tbisvp   detvalores.tatribu%TYPE;
	  tcorvp   detvalores.tatribu%TYPE;
	  tlitco   detvalores.tatribu%TYPE;
	  tcorco   detvalores.tatribu%TYPE;
	  tor2co   detvalores.tatribu%TYPE;
	BEGIN
	    IF pcsiglas IS NOT NULL THEN
	      /* Bug 20893/111636 - 02/05/2012 - AMC*/
	      IF nvl(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'GEODIRECCION'), 0)=0 THEN BEGIN
	            SELECT tsiglas
	              INTO vtsiglas
	              FROM tipos_via
	             WHERE csiglas=pcsiglas;

	            vtdomici:=vtsiglas
	                      || ' ';
	        EXCEPTION
	            WHEN OTHERS THEN
	              vtsiglas:=NULL;
	        END;
	      ELSE BEGIN
	            SELECT csiglas
	              INTO vtsiglas
	              FROM tiposvias
	             WHERE ctipvia=pcsiglas;

	            vtdomici:=vtsiglas
	                      || ' ';
	        EXCEPTION
	            WHEN OTHERS THEN
	              vtsiglas:=NULL;
	        END;
	      END IF;
	    /* Fi Bug 20893/111636 - 02/05/2012 - AMC*/
	    END IF;

	    /* Bug 21094/105198 - 27/01/2012 - AMC*/
	    IF pcviavp IS NOT NULL THEN
	      /* Bug 20893/111636 - 02/05/2012 - AMC*/
	      IF nvl(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'GEODIRECCION'), 0)=0 THEN BEGIN
	            SELECT tsiglas
	              INTO vtsiglas
	              FROM tipos_via
	             WHERE csiglas=pcviavp;

	            vtdomici:=vtsiglas
	                      || ' ';
	        EXCEPTION
	            WHEN OTHERS THEN
	              vtsiglas:=NULL;
	        END;
	      ELSE BEGIN
	            SELECT csiglas
	              INTO vtsiglas
	              FROM tiposvias
	             WHERE ctipvia=pcviavp;

	            vtdomici:=vtsiglas
	                      || ' ';
	        EXCEPTION
	            WHEN OTHERS THEN
	              vtsiglas:=NULL;
	        END;
	      END IF;
	    /* Fi Bug 20893/111636 - 02/05/2012 - AMC*/
	    END IF;

	    /* Fi Bug 21094/105198 - 27/01/2012 - AMC*/
	    /* Bug 18940/92686 - 27/09/2011 - AMC*/
	    /*      IF ptnomvia IS NOT NULL THEN*/
	    vnnomvia:=nvl(length(ptnomvia), 0);

	    vnnumvia:=nvl(length(pnnumvia), 0);

	    vncomple:=nvl(length(ptcomple), 0);

	    /* BUG 18507 - 11/05/2011- ETM--se modifica la concatenacion de la direccion*/
	    IF (vnnomvia+vnnumvia+vncomple+8)<500 THEN
	      SELECT vtdomici
	             || ptnomvia
	             || decode(pnnumvia, NULL, ' '
	                                       || f_axis_literales(9001323, f_usu_idioma),
	                                 ', ')
	             || pnnumvia
	             || decode(ptcomple, NULL, NULL,
	                                 ', ')
	             || ptcomple
	        INTO vtdomici
	        FROM dual;
	    ELSE
	      SELECT vtdomici
	             || substr(ptnomvia, 0, 500-(vnnumvia+vncomple+8))
	             || decode(pnnumvia, NULL, ' '
	                                       || f_axis_literales(9001323, f_usu_idioma),
	                                 ', ')
	             || pnnumvia
	             || decode(ptcomple, NULL, NULL,
	                                 ', ')
	             || ptcomple
	        INTO vtdomici
	        FROM dual;
	    END IF;

	    /* Bug 18940/92686 - 27/09/2011 - AMC*/
	    IF pclitvp IS NOT NULL THEN BEGIN
	          SELECT tatribu
	            INTO tclitvp
	            FROM detvalores
	           WHERE cidioma=f_usu_idioma AND
	                 cvalor=800043 AND
	                 catribu=pclitvp;

	          IF vtdomici IS NULL THEN
	            vtdomici:=tclitvp;
	          ELSE
	            vtdomici:=vtdomici
	                      || ', '
	                      || tclitvp;
	          END IF;
	      EXCEPTION
	          WHEN OTHERS THEN
	            NULL;
	      END;
	    END IF;

	    IF pcbisvp IS NOT NULL THEN BEGIN
	          SELECT tatribu
	            INTO tbisvp
	            FROM detvalores
	           WHERE cidioma=f_usu_idioma AND
	                 cvalor=800044 AND
	                 catribu=pcbisvp;

	          IF vtdomici IS NULL THEN
	            vtdomici:=tbisvp;
	          ELSE
	            vtdomici:=vtdomici
	                      || ', '
	                      || tbisvp;
	          END IF;
	      EXCEPTION
	          WHEN OTHERS THEN
	            NULL;
	      END;
	    END IF;

	    IF pcorvp IS NOT NULL THEN BEGIN
	          SELECT tatribu
	            INTO tcorvp
	            FROM detvalores
	           WHERE cidioma=f_usu_idioma AND
	                 cvalor=800045 AND
	                 catribu=pcorvp;

	          IF vtdomici IS NULL THEN
	            vtdomici:=tcorvp;
	          ELSE
	            vtdomici:=vtdomici
	                      || ', '
	                      || tcorvp;
	          END IF;
	      EXCEPTION
	          WHEN OTHERS THEN
	            NULL;
	      END;
	    END IF;

	    IF pnviaadco IS NOT NULL THEN
	      vtdomici:=vtdomici
	                || ', '
	                || pnviaadco;
	    END IF;

	    IF pclitco IS NOT NULL THEN BEGIN
	          SELECT tatribu
	            INTO tlitco
	            FROM detvalores
	           WHERE cidioma=f_usu_idioma AND
	                 cvalor=800043 AND
	                 catribu=pclitco;

	          IF vtdomici IS NULL THEN
	            vtdomici:=tlitco;
	          ELSE
	            vtdomici:=vtdomici
	                      || ', '
	                      || tlitco;
	          END IF;
	      EXCEPTION
	          WHEN OTHERS THEN
	            NULL;
	      END;
	    END IF;

	    IF pcorco IS NOT NULL THEN BEGIN
	          SELECT tatribu
	            INTO tcorco
	            FROM detvalores
	           WHERE cidioma=f_usu_idioma AND
	                 cvalor=800045 AND
	                 catribu=pcorco;

	          IF vtdomici IS NULL THEN
	            vtdomici:=tcorco;
	          ELSE
	            vtdomici:=vtdomici
	                      || ', '
	                      || tcorco;
	          END IF;
	      EXCEPTION
	          WHEN OTHERS THEN
	            NULL;
	      END;
	    END IF;

	    /*  vtdomici := vtdomici || ' ' || pnviaadco || ' ' || tlitco || ' ' || tcorco;*/
	    IF pnplacaco IS NOT NULL THEN
	      vtdomici:=vtdomici
	                || ', '
	                || pnplacaco;
	    END IF;

	    IF pcor2co IS NOT NULL THEN BEGIN
	          SELECT tatribu
	            INTO tor2co
	            FROM detvalores
	           WHERE cidioma=f_usu_idioma AND
	                 cvalor=800045 AND
	                 catribu=pcor2co;

	          IF vtdomici IS NULL THEN
	            vtdomici:=tor2co;
	          ELSE
	            vtdomici:=vtdomici
	                      || ', '
	                      || tor2co;
	          END IF;
	      EXCEPTION
	          WHEN OTHERS THEN
	            NULL;
	      END;
	    END IF;

	    IF pcdet1ia IS NOT NULL THEN BEGIN
	          SELECT tatribu
	            INTO tdet1ia
	            FROM detvalores
	           WHERE cidioma=f_usu_idioma AND
	                 cvalor=800047 AND
	                 catribu=pcdet1ia;

	          IF vtdomici IS NULL THEN
	            vtdomici:=tdet1ia;
	          ELSE
	            vtdomici:=vtdomici
	                      || ', '
	                      || tdet1ia;
	          END IF;
	      EXCEPTION
	          WHEN OTHERS THEN
	            NULL;
	      END;
	    END IF;

	    IF ptnum1ia IS NOT NULL THEN
	      IF vtdomici IS NULL THEN
	        vtdomici:=ptnum1ia;
	      ELSE
	        vtdomici:=vtdomici
	                  || ', '
	                  || ptnum1ia;
	      END IF;
	    END IF;

	    IF pcdet2ia IS NOT NULL THEN BEGIN
	          SELECT tatribu
	            INTO tdet2ia
	            FROM detvalores
	           WHERE cidioma=f_usu_idioma AND
	                 cvalor=800047 AND
	                 catribu=pcdet2ia;

	          IF vtdomici IS NULL THEN
	            vtdomici:=tdet2ia;
	          ELSE
	            vtdomici:=vtdomici
	                      || ', '
	                      || tdet2ia;
	          END IF;
	      EXCEPTION
	          WHEN OTHERS THEN
	            NULL;
	      END;
	    END IF;

	    IF ptnum2ia IS NOT NULL THEN
	      IF vtdomici IS NULL THEN
	        vtdomici:=ptnum2ia;
	      ELSE
	        vtdomici:=vtdomici
	                  || ', '
	                  || ptnum2ia;
	      END IF;
	    END IF;

	    IF pcdet3ia IS NOT NULL THEN BEGIN
	          SELECT tatribu
	            INTO tdet3ia
	            FROM detvalores
	           WHERE cidioma=f_usu_idioma AND
	                 cvalor=800047 AND
	                 catribu=pcdet3ia;

	          IF vtdomici IS NULL THEN
	            vtdomici:=tdet3ia;
	          ELSE
	            vtdomici:=vtdomici
	                      || ', '
	                      || tdet3ia;
	          END IF;
	      EXCEPTION
	          WHEN OTHERS THEN
	            NULL;
	      END;
	    END IF;

	    IF ptnum3ia IS NOT NULL THEN
	      IF vtdomici IS NULL THEN
	        vtdomici:=ptnum3ia;
	      ELSE
	        vtdomici:=vtdomici
	                  || ', '
	                  || ptnum3ia;
	      END IF;
	    END IF;

	    /* Bug 24780/130907 - 05/12/2012 - AMC*/
	    IF plocalidad IS NOT NULL THEN
	      IF vtdomici IS NULL THEN
	        vtdomici:=plocalidad;
	      ELSE
	        vtdomici:=vtdomici
	                  || ', '
	                  || plocalidad;
	      END IF;
	    END IF;

	    /* Fi Bug 24780/130907 - 05/12/2012 - AMC*/
	    /* Fi Bug 18940/92686 - 27/09/2011 - AMC*/
	    RETURN vtdomici;
	EXCEPTION
	  WHEN OTHERS THEN
	             RETURN NULL;
	END f_tdomici_aux;

	/*************************************************************************
	    FUNCTION f_retenida_siniestro

	    param in psseguro  : Identificador de seguro.
	       return             : NUMBER (1  / 0)
	*************************************************************************/
	/* Bug 21863 - RSC - 29/03/2012 - LCOL - Incidencias Reservas*/
	FUNCTION f_retenida_siniestro(
			psseguro	IN	NUMBER,
			pfecha	IN	DATE,
			pcgarant	IN	NUMBER,
			pctipo	IN	NUMBER
	) RETURN NUMBER
	IS
	  /*
	       i_capital      NUMBER;
	        c_forpag       NUMBER;
	        c_ramo         NUMBER;
	        c_modali       NUMBER;
	        c_tipseg       NUMBER;
	        c_colect       NUMBER;

	  */
	  ss        VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_cempres seguros.cempres%TYPE;
	  retorno   NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	/* Se debe declarar el componente*/
	BEGIN
	    BEGIN
	        SELECT cempres
	          INTO v_cempres
	          FROM seguros
	         WHERE sseguro=psseguro;
	    EXCEPTION
	        WHEN OTHERS THEN
	          RETURN 0;
	    END;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'f_retenida_siniestro('
	        || psseguro
	        || ','''
	        || to_char(pfecha, 'YYYYMMDD')
	        || ''','
	        || pcgarant
	        || ','
	        || pctipo
	        || ')'
	        || ';'
	        || ' END;';

	    /* Fin Bug 11232*/
	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             /*
	               Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
	               a una funci¿n, procedimiento, etc. inexistente o no declarado. En este
	               caso a continaci¿n ejecutamos el c¿digo tradicional para determinar
	               si una garant¿a est¿ o no reducida.
	             */
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN 0;
	END f_retenida_siniestro;

	/* Fin Bug 21863*/
	/*************************************************************************
	    FUNCTION f_esta_retenica_sin_resc

	    param in psseguro  : Identificador de seguro.
	    param in psproduc  : Identificador de producto.
	    param in pfecha  : Identificador de fecha.
	       return             : NUMBER (1  / 0)
	*************************************************************************/
	/* Bug 21808 - RSC - 04/05/2012 - LCOL - UAT - Revisi¿n de Listados Producci¿n*/
	FUNCTION f_esta_retenica_sin_resc(
			psseguro	IN	NUMBER,
			psproduc	IN	NUMBER,
			pfecha	IN	DATE
	) RETURN NUMBER
	IS
	/*    i_capital      NUMBER;*/
	/*    c_forpag       NUMBER;*/
	/*    c_ramo         NUMBER;*/
	/*   c_modali       NUMBER;*/
	/*    c_tipseg       NUMBER;*/
	  /*    c_colect       NUMBER;*/
	  ss        VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_cempres seguros.cempres%TYPE;
	  retorno   NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	  /* Se debe declarar el componente*/
	  v_conta   NUMBER;
	BEGIN
	    BEGIN
	        SELECT cempres
	          INTO v_cempres
	          FROM seguros
	         WHERE sseguro=psseguro;
	    EXCEPTION
	        WHEN OTHERS THEN
	          RETURN 0;
	    END;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'f_esta_retenica_sin_resc('
	        || psseguro
	        || ','
	        || psproduc
	        || ','''
	        || to_char(pfecha, 'YYYYMMDD')
	        || ''')'
	        || ';'
	        || ' END;';

	    /* Fin Bug 11232*/
	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             /*
	               Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
	               a una funci¿n, procedimiento, etc. inexistente o no declarado. En este
	               caso a continaci¿n ejecutamos el c¿digo tradicional para determinar
	               si una garant¿a est¿ o no reducida.
	             */
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             IF nvl(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0)=0 THEN
	               /* Bug 22942 - APD - 17/07/2012 - el siniestro debe estar abierto (cestsin = 0)*/
	               SELECT count(1)
	                 INTO v_conta
	                 FROM siniestros
	                WHERE ccausin=5 AND
	                      sseguro=psseguro AND
	                      cestsin=0;
	             /* fin Bug 22942 - APD - 17/07/2012*/
	             ELSIF nvl(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0)=1 THEN
	               /* Bug 22942 - APD - 17/07/2012 - el siniestro debe estar abierto (cestsin = 0)*/
	               SELECT count(1)
	                 INTO v_conta
	                 FROM sin_siniestro s,sin_movsiniestro m
	                WHERE s.ccausin=5 AND
	                      s.sseguro=psseguro AND
	                      s.nsinies=m.nsinies AND
	                      m.nmovsin=(SELECT max(nmovsin)
	                                   FROM sin_movsiniestro m1
	                                  WHERE m1.nsinies=m.nsinies) AND
	                      m.cestsin=0;
	             /* Bug 22942 - APD - 17/07/2012*/
	             END IF;

	             IF (pac_motretencion.f_esta_retenica_sin_resc(psseguro, pfecha)=0  OR
	                 nvl(f_parproductos_v(psproduc, 'NO_RESCAT_RETENI'), 0)=0 AND
	                 v_conta>=1) THEN
	               RETURN 1;
	             END IF;

	             RETURN 0;
	END f_esta_retenica_sin_resc;

	/* Fin bug 21808*/
	/*************************************************************************
	    FUNCTION f_hay_peritaje

	    param in psseguro  : Identificador de seguro.
	       return             : NUMBER (1  / 0)
	*************************************************************************/
	/* Bug 21863 - RSC - 29/03/2012 - LCOL - Incidencias Reservas*/
	FUNCTION f_hay_peritaje(
			pnsinies	IN	VARCHAR2
	) RETURN NUMBER
	IS
	  v_propio  VARCHAR2(50);
	  v_cempres seguros.cempres%TYPE;
	  ss        VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  retorno   NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	/* Se debe declarar el componente*/
	BEGIN
	    BEGIN
	        SELECT cempres
	          INTO v_cempres
	          FROM seguros se,sin_siniestro si
	         WHERE si.sseguro=se.sseguro AND
	               si.nsinies=pnsinies;
	    EXCEPTION
	        WHEN OTHERS THEN
	          RETURN 0;
	    END;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'f_hay_peritaje('
	        || pnsinies
	        || ')'
	        || ';'
	        || ' END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             /*
	               Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
	               a una funci¿n, procedimiento, etc. inexistente o no declarado. En este
	               caso a continaci¿n ejecutamos el c¿digo tradicional para determinar
	               si hay peritaje o no.
	             */
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN 0;
	END f_hay_peritaje;

	/*************************************************************************
	    FUNCTION f_hay_peritaje

	    param in psseguro  : Identificador de seguro.
	       return             : NUMBER (1  / 0)
	*************************************************************************/
	/* Bug 21863 - RSC - 29/03/2012 - LCOL - Incidencias Reservas*/
	FUNCTION f_obt_primas_financiadas(
			psseguro	IN	NUMBER,
			ptablas	IN	VARCHAR2,
			pimporte	OUT	NUMBER
	) RETURN NUMBER
	IS
	  v_propio  VARCHAR2(50);
	  v_cempres seguros.cempres%TYPE;
	  ss        VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  retorno   NUMBER:=0;
	  v_sproduc seguros.sproduc%TYPE;
	  v_importe NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	/* Se debe declarar el componente*/
	BEGIN
	    IF ptablas='EST' THEN BEGIN
	          SELECT cempres,sproduc
	            INTO v_cempres, v_sproduc
	            FROM estseguros se
	           WHERE se.sseguro=psseguro;
	      EXCEPTION
	          WHEN OTHERS THEN
	            RETURN 0;
	      END;
	    ELSE BEGIN
	          SELECT cempres,sproduc
	            INTO v_cempres, v_sproduc
	            FROM seguros se
	           WHERE se.sseguro=psseguro;
	      EXCEPTION
	          WHEN OTHERS THEN
	            RETURN 0;
	      END;
	    END IF;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    IF (nvl(f_parproductos_v(v_sproduc, 'PERMITE_FINAN_PRIMAS'), 0)=1) THEN
	      ss:='BEGIN '
	          || ' :RETORNO := '
	          || v_propio
	          || '.'
	          || 'f_obt_primas_financiadas ('
	          || psseguro
	          || ','
	          || v_cempres
	          || ',:IMPORTE)'
	          || ';'
	          || ' END;';

	      IF dbms_sql.is_open(v_cursor) THEN
	        dbms_sql.close_cursor(v_cursor);
	      END IF;

	      v_cursor:=dbms_sql.open_cursor;

	      dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	      dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

	      dbms_sql.bind_variable(v_cursor, ':IMPORTE', v_importe);

	      v_filas:=dbms_sql.EXECUTE(v_cursor);

	      dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	      dbms_sql.variable_value(v_cursor, 'IMPORTE', v_importe);

	      IF dbms_sql.is_open(v_cursor) THEN
	        dbms_sql.close_cursor(v_cursor);
	      END IF;
	    END IF;

	    pimporte:=v_importe;

	    RETURN retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             /*
	               Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
	               a una funci¿n, procedimiento, etc. inexistente o no declarado. En este
	               caso a continaci¿n ejecutamos el c¿digo tradicional para determinar
	               si hay peritaje o no.
	             */
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN 0;
	END f_obt_primas_financiadas;

	/* Ini Bug 23254 - MDS - 06/09/2012*/
	FUNCTION f_calc_prov_migrada(
			psseguro NUMBER,
			pnriesgo	IN	NUMBER
	) RETURN NUMBER
	IS
	  ss        VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_cempres seguros.cempres%TYPE;
	  retorno   NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	/* Se debe declarar el componente*/
	BEGIN
	    BEGIN
	        SELECT cempres
	          INTO v_cempres
	          FROM seguros
	         WHERE sseguro=psseguro;
	    EXCEPTION
	        WHEN OTHERS THEN
	          RETURN 0;
	    END;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'f_calc_prov_migrada('
	        || psseguro
	        || ','
	        || pnriesgo
	        || ')'
	        || ';'
	        || ' END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             /*
	               Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
	               a una funci¿n, procedimiento, etc. inexistente o no declarado. En este
	               caso a continaci¿n ejecutamos el c¿digo tradicional para determinar
	               el importe.
	             */
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN pac_provmat_formul.f_calcul_formulas_provi(psseguro, to_date(frenovacion(NULL, psseguro, 2)-1, 'yyyymmdd'), 'IPROVRES');
	END f_calc_prov_migrada;

	/* Fin Bug 23254 - MDS - 06/09/2012*/
	/* Ini Bug 23644 - AVT - 25/09/2012*/
	/* Ini Bug 23644 - ECP - 14/01/2013*/
	FUNCTION f_calc_perc_reserva_pm(
			psseguro NUMBER,
			psidepag	IN	NUMBER,
			porigen	IN	NUMBER,
			pcgarant	IN	NUMBER
	) RETURN NUMBER
	IS
	  ss        VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_cempres seguros.cempres%TYPE;
	  retorno   NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	/* Se debe declarar el componente*/
	BEGIN
	    BEGIN
	        SELECT cempres
	          INTO v_cempres
	          FROM seguros
	         WHERE sseguro=psseguro;
	    EXCEPTION
	        WHEN OTHERS THEN
	          RETURN 0;
	    END;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'f_calc_perc_reserva_pm('
	        || psseguro
	        || ','
	        || psidepag
	        || ','
	        || porigen
	        || ','
	        || pcgarant
	        || ')'
	        || ';'
	        || ' END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             /*
	               Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
	               a una funci¿n, procedimiento, etc. inexistente o no declarado. En este
	               caso a continaci¿n ejecutamos el c¿digo tradicional para determinar
	               el importe.
	             */
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN 0;
	END f_calc_perc_reserva_pm;

	/* Fin Bug 23644 - ECP - 14/01/2013*/
	/* Fin Bug 23644 - AVT - 25/09/2012*/
	/* Ini Bug 23864/124752 - JGR - 02/10/2012*/
	FUNCTION f_devolu_accion_7(
			pcactimp	IN	NUMBER,
	pnrecibo	IN	NUMBER,
	pffejecu	IN	DATE,
	psseguro	IN	NUMBER,
	pcmotivo	IN	NUMBER,
	pffecalt	IN	DATE,
	piprovis	IN	OUT NUMBER,
			 /*> Parte del importe que no cubre la provisi¿n*/
			 pcidioma	IN	NUMBER,
	psproces	IN	NUMBER
	)
	RETURN NUMBER
	IS
	  ss         VARCHAR2(3000);
	  v_cursor   NUMBER;
	  v_filas    NUMBER;
	  v_propio   VARCHAR2(50);
	  v_pacname  VARCHAR2(50):='PAC_PROPIO';
	  v_procname VARCHAR2(50):='F_DEVOLU_ACCION_7';
	  v_cempres  seguros.cempres%TYPE;
	  vtraza     NUMBER:=0;
	  retorno    NUMBER;
	BEGIN
	    vtraza:=10;

	    BEGIN
	        SELECT cempres
	          INTO v_cempres
	          FROM recibos
	         WHERE nrecibo=pnrecibo;
	    EXCEPTION
	        WHEN OTHERS THEN
	          RETURN 0;
	    END;

	    vtraza:=20;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    vtraza:=30;

	    ss:='BEGIN '
	        || ' :V_RETORNO := '
	        || v_propio
	        || '.'
	        || v_procname
	        || '('
	        || pcactimp
	        || ','
	        || pnrecibo
	        || ','''
	        || pffejecu
	        || ''','
	        || psseguro
	        || ','
	        || pcmotivo
	        || ','''
	        || pffecalt
	        || ''', :PIPROVIS, '
	        || nvl(pcidioma, pac_md_common.f_get_cxtidioma)
	        || ', '
	        || psproces
	        || ')'
	        || ';'
	        || ' END;';

	    vtraza:=40;

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    vtraza:=50;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':V_RETORNO', retorno);

	    dbms_sql.bind_variable(v_cursor, ':PIPROVIS', piprovis);

	    vtraza:=60;

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'V_RETORNO', retorno);

	    dbms_sql.variable_value(v_cursor, 'PIPROVIS', piprovis);

	    vtraza:=70;

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    vtraza:=80;

	    RETURN retorno;
	EXCEPTION
	  WHEN OTHERS THEN
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             p_tab_error(f_sysdate, f_user, v_pacname
	                                            || '.'
	                                            || v_procname, vtraza, SQLCODE, SQLERRM);

	             RETURN 140999; /* Error no controlado*/
	END f_devolu_accion_7;

	/* Fin Bug 23864/124752 - JGR - 02/10/2012*/
	/*************************************************************************
	    FUNCTION f_prod_usu_esp
	    Producto usuario especial
	    param in psproduc : identificador del producto
	    param in pcagente : identificador del agente
	    param in pctipo   : identificador del tipo
	    return            :

	    -- Bug 0025087 - JMF - 17/12/2012
	 *************************************************************************/
	FUNCTION f_prod_usu_esp(
			psproduc	IN	NUMBER,
			pcagente	IN	NUMBER,
			pctipo	IN	NUMBER
	) RETURN NUMBER
	IS
	  vobj     VARCHAR2(500):='PAC_PROPIO.f_prod_usu_esp';
	  vpar     VARCHAR2(500):='p='
	                      || psproduc
	                      || ' a='
	                      || pcagente
	                      || ' t='
	                      || pctipo;
	  vpasexec NUMBER:=1;
	  vcempres codiram.cempres%TYPE;
	  vpropio  VARCHAR2(100);
	  vreturn  NUMBER;
	BEGIN
	    vpasexec:=1;

	    BEGIN
	        SELECT c.cempres
	          INTO vcempres
	          FROM codiram c,productos p
	         WHERE p.sproduc=psproduc AND
	               c.cramo=p.cramo;
	    EXCEPTION
	        WHEN OTHERS THEN
	          p_tab_error(f_sysdate, f_user, vobj, vpasexec, vpar, SQLCODE
	                                                               || '-'
	                                                               || SQLERRM);

	          RETURN NULL;
	    END;

	    vpasexec:=2;

	    SELECT pac_parametros.f_parempresa_t(vcempres, 'PAC_PROPIO')
	      INTO vpropio
	      FROM dual;

	    vpasexec:=3;

	    EXECUTE IMMEDIATE ('BEGIN :vreturn := '|| vpropio|| '.f_prod_usu_esp(:psproduc, :pcagente, :pctipo); END;')
	    USING OUT vreturn, IN psproduc, IN pcagente, IN pctipo;

	    RETURN vreturn;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobj, vpasexec, vpar, SQLCODE
	                                                                  || '-'
	                                                                  || SQLERRM);

	             RETURN NULL;
	END f_prod_usu_esp;

	/*************************************************************************
	    FUNCTION f_valida_juicio
	    Validaciones tramitacion judicial
	************************************************************************/
	FUNCTION f_valida_juicio(
			pnsinies	IN	VARCHAR2,
			pfnotiase	IN	DATE,
			pfrecpdem	IN	DATE,
			pfnoticia	IN	DATE,
			pfcontase	IN	DATE,
			pfcontcia	IN	DATE,
			pfaudprev	IN	DATE,
			pfjuicio	IN	DATE,
			pntipopro	IN	NUMBER,
			pcresplei	IN	NUMBER,
			pnclasede	IN	NUMBER,
			pcorgjud	IN	NUMBER
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_propio.f_valida_juicio';
	  vparam      VARCHAR2(2000):='par¿metros - pctiptra: '
	                         || ' pnsinies : '
	                         || pnsinies
	                         || ' pfnotiase : '
	                         || pfnotiase
	                         || ' pfrecpdem : '
	                         || pfrecpdem
	                         || ' pfnoticia : '
	                         || pfnoticia
	                         || ' pfcontase : '
	                         || pfcontase
	                         || ' pfcontcia : '
	                         || pfcontcia
	                         || ' pfaudprev : '
	                         || pfaudprev
	                         || ' pfjuicio : '
	                         || pfjuicio
	                         || ' pntipopro : '
	                         || pntipopro
	                         || ' pcresplei : '
	                         || pcresplei
	                         || ' pnclasede : '
	                         || pnclasede
	                         || ' pcorgjud : '
	                         || pcorgjud;
	  vpasexec    NUMBER(5):=1;
	  v_cont      NUMBER;
	  v_ss        VARCHAR2(3000);
	  v_cursor    NUMBER;
	  v_filas     NUMBER;
	  v_propio    VARCHAR2(50);
	  v_retorno   NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	BEGIN
	    IF pnsinies IS NULL THEN
	      RETURN 0;
	    END IF;

	    SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    SELECT 'BEGIN '
	           || ' :RETORNO := '
	           || v_propio
	           || '.'
	           || 'f_valida_juicio('''
	           || pnsinies
	           || ''', TO_DATE('''
	           || to_char(pfnotiase, 'DD/MM/YYYY')
	           || ''', ''DD/MM/YYYY''), TO_DATE('''
	           || to_char(pfrecpdem, 'DD/MM/YYYY')
	           || ''', ''DD/MM/YYYY''), TO_DATE('''
	           || to_char(pfnoticia, 'DD/MM/YYYY')
	           || ''', ''DD/MM/YYYY''), TO_DATE('''
	           || to_char(pfcontase, 'DD/MM/YYYY')
	           || ''', ''DD/MM/YYYY''), TO_DATE('''
	           || to_char(pfcontcia, 'DD/MM/YYYY')
	           || ''', ''DD/MM/YYYY''), TO_DATE('''
	           || to_char(pfaudprev, 'DD/MM/YYYY')
	           || ''', ''DD/MM/YYYY''), TO_DATE('''
	           || to_char(pfjuicio, 'DD/MM/YYYY')
	           || ''', ''DD/MM/YYYY''), '
	           || decode(pntipopro, NULL, 'NULL',
	                                pntipopro)
	           || ','
	           || decode(pcresplei, NULL, 'NULL',
	                                pcresplei)
	           || ','
	           || decode(pnclasede, NULL, 'NULL',
	                                pnclasede)
	           || ','
	           || decode(pcorgjud, NULL, 'NULL',
	                               pcorgjud)
	           || '); END;'
	      INTO v_ss
	      FROM dual;

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, v_ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', v_retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', v_retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	           /*  Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada*/
	             /*  a una funci¿n, procedimiento, etc. inexistente o no declarado.*/
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             /* Si la funci¿n no existe para la empresa, tratamiento gen¿rico*/
	             /* Tipo Juzgado*/
	             IF pcorgjud=10 THEN
	               IF pntipopro IN(25, 29) THEN
	                 RETURN 9904659;
	               /*  Procedimiento no valido para este tipo de demanda*/
	               END IF;
	             ELSIF pcorgjud=11 THEN
	               IF pntipopro NOT IN(26, 29) THEN
	                 RETURN 9904659;
	               END IF;
	             ELSIF pcorgjud=12 THEN
	               IF pntipopro NOT IN(24, 26) THEN
	                 RETURN 9904659;
	               END IF;
	             ELSIF pcorgjud=13 THEN
	               IF pntipopro IN(21, 22, 23, 24) THEN
	                 RETURN 9904659;
	               END IF;
	             END IF;

	             /* Resultado pleito*/
	             IF pnclasede=4 THEN
	               IF pcresplei=12 THEN
	                 RETURN 9902804;
	               END IF;
	             END IF;

	             /* Fecha de recepcion ha de ser nula si fecha de emplazamiento lo es*/
	             IF pfnotiase IS NULL AND
	                pfrecpdem IS NOT NULL THEN
	               RETURN 9902805;
	             END IF;

	             RETURN 0; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 9001449; /*Error validar tramitaci¿n siniestro*/
	END f_valida_juicio;

	/*************************************************************************
	    FUNCTION f_mensajes_axissin049
	    Validaciones (informativas) tramitacion judicial
	    Devuelve un texto con los mensajes informativos.
	************************************************************************/
	FUNCTION f_mensajes_axissin049(
			pnsinies	IN	VARCHAR2,
			pntramit	IN	NUMBER,
			pnlinjuz	IN	NUMBER,
			pcorgjud	IN	NUMBER,
			pnorgjud	IN	VARCHAR2,
			ptrefjud	IN	VARCHAR2,
			pcsiglas	IN	NUMBER,
			ptnomvia	IN	VARCHAR2,
			pnnumvia	IN	NUMBER,
			ptcomple	IN	VARCHAR2,
			ptdirec	IN	VARCHAR2,
			pcpais	IN	NUMBER,
			pcprovin	IN	NUMBER,
			pcpoblac	IN	NUMBER,
			pcpostal	IN	VARCHAR2,
			ptasunto	IN	VARCHAR2,
			pnclasede	IN	NUMBER,
			pntipopro	IN	NUMBER,
			pnprocedi	IN	VARCHAR2,
			pfnotiase	IN	DATE,
			pfrecpdem	IN	DATE,
			pfnoticia	IN	DATE,
			pfcontase	IN	DATE,
			pfcontcia	IN	DATE,
			pfaudprev	IN	DATE,
			pfjuicio	IN	DATE,
			pcmonjuz	IN	VARCHAR2,
			pcpleito	IN	NUMBER,
			pipleito	IN	NUMBER,
			piallana	IN	NUMBER,
			pisentenc	IN	NUMBER,
			pisentcap	IN	NUMBER,
			pisentind	IN	NUMBER,
			pisentcos	IN	NUMBER,
			pisentint	IN	NUMBER,
			pisentotr	IN	NUMBER,
			pcargudef	IN	NUMBER,
			pcresplei	IN	NUMBER,
			pcapelant	IN	NUMBER,
			pthipoase	IN	VARCHAR2,
			pthipoter	IN	VARCHAR2,
			pttipresp	IN	VARCHAR2,
			pcopercob	IN	NUMBER,
			ptreasmed	IN	VARCHAR2,
			pcestproc	IN	NUMBER,
			pcetaproc	IN	NUMBER,
			ptconcjur	IN	VARCHAR2,
			ptestrdef	IN	VARCHAR2,
			 ptrecomen	IN	VARCHAR2,
			ptobserv	IN	VARCHAR2,
			pfcancel	IN	DATE,
			otexto	OUT	VARCHAR2
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_propio.f_mensajes_axissin049';
	  vparam      VARCHAR2(2000):='par¿metros - pctiptra: '
	                         || ' pnsinies : '
	                         || pnsinies
	                         || ' pfnotiase : '
	                         || pfnotiase
	                         || ' pfrecpdem : '
	                         || pfrecpdem
	                         || ' pfnoticia : '
	                         || pfnoticia
	                         || ' pfcontase : '
	                         || pfcontase
	                         || ' pfcontcia : '
	                         || pfcontcia
	                         || ' pfaudprev : '
	                         || pfaudprev
	                         || ' pfjuicio : '
	                         || pfjuicio
	                         || ' pntipopro : '
	                         || pntipopro
	                         || ' pcresplei : '
	                         || pcresplei
	                         || ' pnclasede : '
	                         || pnclasede
	                         || ' pcorgjud : '
	                         || pcorgjud;
	  vpasexec    NUMBER(5):=0;
	  v_fsinies   sin_siniestro.fsinies%TYPE;
	  v_cont      NUMBER;
	  v_ss        VARCHAR2(3000);
	  v_cursor    NUMBER;
	  v_filas     NUMBER;
	  v_propio    VARCHAR2(50);
	  v_retorno   NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	BEGIN
	    SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    SELECT 'BEGIN '
	           || ' :RETORNO := '
	           || v_propio
	           || '.'
	           || 'f_mensajes_axissin049('''
	           || pnsinies
	           || ''','
	           || pntramit
	           || ','
	           || pnlinjuz
	           || ','
	           || decode(pcorgjud, NULL, 'NULL',
	                               pcorgjud)
	           || ','''
	           || pnorgjud
	           || ''','''
	           || ptrefjud
	           || ''','
	           || decode(pcsiglas, NULL, 'NULL',
	                               pcsiglas)
	           || ','''
	           || ptnomvia
	           || ''','
	           || decode(pnnumvia, NULL, 'NULL',
	                               pnnumvia)
	           || ','''
	           || ptcomple
	           || ''','''
	           || ptdirec
	           || ''','
	           || decode(pcpais, NULL, 'NULL',
	                             pcpais)
	           || ','
	           || decode(pcprovin, NULL, 'NULL',
	                               pcprovin)
	           || ','
	           || decode(pcpoblac, NULL, 'NULL',
	                               pcpoblac)
	           || ','''
	           || pcpostal
	           || ''','''
	           || ptasunto
	           || ''','
	           || decode(pnclasede, NULL, 'NULL',
	                                pnclasede)
	           || ','
	           || decode(pntipopro, NULL, 'NULL',
	                                pntipopro)
	           || ','''
	           || pnprocedi
	           || ''', TO_DATE('''
	           || to_char(pfnotiase, 'DD/MM/YYYY')
	           || ''', ''DD/MM/YYYY''), '
	           || 'TO_DATE('''
	           || to_char(pfrecpdem, 'DD/MM/YYYY')
	           || ''', ''DD/MM/YYYY''), '
	           || 'TO_DATE('''
	           || to_char(pfnoticia, 'DD/MM/YYYY')
	           || ''', ''DD/MM/YYYY''), '
	           || 'TO_DATE('''
	           || to_char(pfcontase, 'DD/MM/YYYY')
	           || ''', ''DD/MM/YYYY''), '
	           || 'TO_DATE('''
	           || to_char(pfcontcia, 'DD/MM/YYYY')
	           || ''', ''DD/MM/YYYY''), '
	           || 'TO_DATE('''
	           || to_char(pfaudprev, 'DD/MM/YYYY')
	           || ''', ''DD/MM/YYYY''), '
	           || 'TO_DATE('''
	           || to_char(pfjuicio, 'DD/MM/YYYY')
	           || ''', ''DD/MM/YYYY''), '''
	           || pcmonjuz
	           || ''','
	           || decode(pcpleito, NULL, 'NULL',
	                               pcpleito)
	           || ','
	           || decode(pipleito, NULL, 'NULL',
	                               pipleito)
	           || ','
	           || decode(piallana, NULL, 'NULL',
	                               piallana)
	           || ','
	           || decode(pisentenc, NULL, 'NULL',
	                                pisentenc)
	           || ','
	           || decode(pisentcap, NULL, 'NULL',
	                                pisentcap)
	           || ','
	           || decode(pisentind, NULL, 'NULL',
	                                pisentind)
	           || ','
	           || decode(pisentcos, NULL, 'NULL',
	                                pisentcos)
	           || ','
	           || decode(pisentint, NULL, 'NULL',
	                                pisentint)
	           || ','
	           || decode(pisentotr, NULL, 'NULL',
	                                pisentotr)
	           || ','
	           || decode(pcargudef, NULL, 'NULL',
	                                pcargudef)
	           || ','
	           || decode(pcresplei, NULL, 'NULL',
	                                pcresplei)
	           || ','
	           || decode(pcapelant, NULL, 'NULL',
	                                pcapelant)
	           || ','''
	           || pthipoase
	           || ''','''
	           || pthipoter
	           || ''','''
	           || pttipresp
	           || ''','
	           || decode(pcopercob, NULL, 'NULL',
	                                pcopercob)
	           || ','''
	           || ptreasmed
	           || ''','
	           || decode(pcestproc, NULL, 'NULL',
	                                pcestproc)
	           || ','
	           || decode(pcetaproc, NULL, 'NULL',
	                                pcetaproc)
	           || ','''
	           || ptconcjur
	           || ''','''
	           || ptestrdef
	           || ''','''
	           || ptrecomen
	           || ''','''
	           || ptobserv
	           || ''','
	           || 'TO_DATE('''
	           || to_char(pfcancel, 'DD/MM/YYYY')
	           || ''', ''DD/MM/YYYY''), :otexto ); END;'
	      INTO v_ss
	      FROM dual;

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, v_ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', v_retorno);

	    dbms_sql.bind_variable(v_cursor, ':otexto', otexto);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', v_retorno);

	    dbms_sql.variable_value(v_cursor, 'otexto', otexto);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	           /*  Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada*/
	             /*  a una funci¿n, procedimiento, etc. inexistente o no declarado.*/
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             /* Si la funci¿n no existe para la empresa, tratamiento gen¿rico*/
	             vpasexec:=1;

	             SELECT fsinies
	               INTO v_fsinies
	               FROM sin_siniestro
	              WHERE nsinies=pnsinies;

	             vpasexec:=2;

	             IF ((pfnotiase IS NOT NULL) AND
	                 NOT(pfnotiase>v_fsinies)) THEN
	               SELECT otexto
	                      || tlitera
	                      || chr(10)
	                 INTO otexto
	                 FROM axis_literales
	                WHERE slitera=9902796 AND
	                      cidioma=f_usu_idioma;
	             END IF;

	             vpasexec:=3;

	             IF ((pfnotiase IS NOT NULL) AND
	                 NOT(pfnotiase>v_fsinies))  OR
	                ((pfrecpdem IS NOT NULL) AND
	                 NOT(pfrecpdem>v_fsinies) AND
	                 NOT(pfrecpdem>=pfnotiase))  OR
	                ((pfrecpdem IS NOT NULL) AND
	                 NOT(pfrecpdem>v_fsinies) AND
	                 NOT(pfrecpdem>=pfnotiase)) THEN
	               SELECT otexto
	                      || tlitera
	                      || chr(10)
	                 INTO otexto
	                 FROM axis_literales
	                WHERE slitera=9902797 AND
	                      cidioma=f_usu_idioma;
	             END IF;

	             vpasexec:=4;

	             /**/
	             IF (pfnotiase IS NULL) AND
	                (pfrecpdem IS NOT NULL) THEN
	               SELECT otexto
	                      || tlitera
	                      || chr(10)
	                 INTO otexto
	                 FROM axis_literales
	                WHERE slitera=9902805 AND
	                      cidioma=f_usu_idioma;
	             END IF;

	             vpasexec:=6;

	             /**/
	             IF (pfnoticia IS NOT NULL) AND
	                NOT(pfnoticia>v_fsinies) THEN
	               SELECT otexto
	                      || tlitera
	                      || chr(10)
	                 INTO otexto
	                 FROM axis_literales
	                WHERE slitera=9902798 AND
	                      cidioma=f_usu_idioma;
	             END IF;

	             vpasexec:=7;

	             /**/
	             IF (pfcontase IS NOT NULL) AND
	                NOT(pfcontase>pfrecpdem) THEN
	               SELECT otexto
	                      || tlitera
	                      || chr(10)
	                 INTO otexto
	                 FROM axis_literales
	                WHERE slitera=9902799 AND
	                      cidioma=f_usu_idioma;
	             END IF;

	             vpasexec:=8;

	             /**/
	             IF (pfcontcia IS NOT NULL) AND
	                NOT(pfcontcia>pfrecpdem) THEN
	               SELECT otexto
	                      || tlitera
	                      || chr(10)
	                 INTO otexto
	                 FROM axis_literales
	                WHERE slitera=9902800 AND
	                      cidioma=f_usu_idioma;
	             END IF;

	             vpasexec:=9;

	             /**/
	             IF (pfaudprev IS NOT NULL) AND
	                NOT(pfaudprev>pfrecpdem) THEN
	               SELECT otexto
	                      || tlitera
	                      || chr(10)
	                 INTO otexto
	                 FROM axis_literales
	                WHERE slitera=9902801 AND
	                      cidioma=f_usu_idioma;
	             END IF;

	             vpasexec:=10;

	             /**/
	             IF (pfjuicio IS NOT NULL) AND
	                NOT(pfjuicio>pfrecpdem) THEN
	               SELECT otexto
	                      || tlitera
	                      || chr(10)
	                 INTO otexto
	                 FROM axis_literales
	                WHERE slitera=9902802 AND
	                      cidioma=f_usu_idioma;
	             END IF;

	             vpasexec:=11;

	             /**/
	             IF (pfjuicio IS NULL) AND
	                (pntipopro IS NOT NULL) AND
	                (pntipopro IN(4, 9)) THEN
	               SELECT otexto
	                      || tlitera
	                      || chr(10)
	                 INTO otexto
	                 FROM axis_literales
	                WHERE slitera=9902803 AND
	                      cidioma=f_usu_idioma;
	             END IF;

	             vpasexec:=12;

	             IF (pcresplei IS NOT NULL) AND
	                (pnclasede IS NOT NULL) AND
	                (pcresplei=6 AND
	                 pnclasede=4) THEN
	               SELECT otexto
	                      || tlitera
	                      || chr(10)
	                 INTO otexto
	                 FROM axis_literales
	                WHERE slitera=9902804 AND
	                      cidioma=f_usu_idioma;
	             END IF;

	             IF otexto IS NOT NULL THEN
	               SELECT otexto
	                      || chr(10)
	                      || tlitera
	                 INTO otexto
	                 FROM axis_literales
	                WHERE slitera=9904675 AND
	                      cidioma=f_usu_idioma;
	             END IF;

	             RETURN 0; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 9001449; /*Error validar tramitaci¿n siniestro*/
	END f_mensajes_axissin049;

	/*************************************************************************
	    Actualiza el campo cbloqueocol de seguros
	    param in psseguro
	    return                 : 0 todo correcto
	                             1 ha habido un error
	*************************************************************************/
	/* Bug 23940 - APD - 02/01/2013 -  se crea la funcion*/
	FUNCTION f_act_cbloqueocol(
			psseguro	IN	NUMBER
	) RETURN NUMBER
	IS
	  vobjectname  VARCHAR2(500):='pac_propio.f_act_cbloqueocol';
	  vparam       VARCHAR2(2000):='par¿metros - psseguro : '
	                         || psseguro;
	  vpasexec     NUMBER(5):=1;
	  ss           VARCHAR2(3000);
	  v_cursor     NUMBER;
	  v_filas      NUMBER;
	  v_propio     VARCHAR2(50);
	  v_cempres    seguros.cempres%TYPE;
	  v_sproduc    seguros.sproduc%TYPE;
	  retorno      NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	  vcbloqueocol seguros.cbloqueocol%TYPE;
	/* Se debe declarar el componente*/
	BEGIN
	    BEGIN
	        SELECT cempres
	          INTO v_cempres
	          FROM seguros
	         WHERE sseguro=psseguro;
	    EXCEPTION
	        WHEN OTHERS THEN
	          RETURN 0;
	    END;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'f_act_cbloqueocol('
	        || psseguro
	        || ')'
	        || ';'
	        || 'END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             /*
	               Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
	               a una funci¿n, procedimiento, etc. inexistente o no declarado. En este
	               caso a continaci¿n ejecutamos el c¿digo tradicional para determinar
	               si la p¿liza est¿ o no reducida.
	             */
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             BEGIN
	                 vpasexec:=1;

	                 BEGIN
	                     SELECT sproduc
	                       INTO v_sproduc
	                       FROM seguros
	                      WHERE sseguro=psseguro;
	                 EXCEPTION
	                     WHEN OTHERS THEN
	                       RETURN 0;
	                 END;

	                 vpasexec:=2;

	                 vcbloqueocol:=nvl(f_parproductos_v(v_sproduc, 'DEF_BLOQUEO_CARTERA'), 0);

	                 vpasexec:=3;

	                 /* cbloqueocol v.f. 1111*/
	                 /* Si cbloqueocol = 0.-No bloqueo:*/
	                 /* . no se bloquea la poliza (valor por defecto del parproducto)*/
	                 /* Si cbloqueocol = 1.-Bloqueo Cartera y:*/
	                 /* . poliza administrada y ncertif = 0 --> se bloquea la poliza (valor por defecto del parproducto)*/
	                 /* . poliza NO administrada --> se bloquea la poliza (valor por defecto del parproducto)*/
	                 /* Si cbloqueocol = 2.-Bloqueo Renovacion y:*/
	                 /* . poliza administrada y ncertif = 0 --> se bloquea la poliza (valor por defecto del parproducto)*/
	                 /* . poliza NO administrada y ncertif = 0 --> se bloquea la poliza (valor por defecto del parproducto)*/
	                 /* Cualquier otro caso:*/
	                 /* . no se bloquea la poliza*/
	                 IF vcbloqueocol=0 THEN
	                   NULL;
	                 ELSIF vcbloqueocol=1 AND
	                       ((pac_seguros.f_es_col_admin(psseguro)=1 AND
	                         pac_seguros.f_get_escertifcero(NULL, psseguro)=1)  OR
	                        pac_seguros.f_es_col_admin(psseguro)=0) THEN
	                   NULL;
	                 ELSIF vcbloqueocol=2 AND
	                       ((pac_seguros.f_es_col_admin(psseguro)=1 AND
	                         pac_seguros.f_get_escertifcero(NULL, psseguro)=1)  OR
	                        (pac_seguros.f_es_col_admin(psseguro)=0 AND
	                         pac_seguros.f_get_escertifcero(NULL, psseguro)=1)) THEN
	                   NULL;
	                 ELSE
	                   vcbloqueocol:=0;
	                 END IF;

	                 vpasexec:=5;

	                 UPDATE seguros
	                    SET cbloqueocol=vcbloqueocol
	                  WHERE sseguro=psseguro;

	                 RETURN 0;
	             EXCEPTION
	                 WHEN OTHERS THEN
	                   p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, SQLCODE
	                                                                                 || ' '
	                                                                                 || SQLERRM);

	                   RETURN 1;
	             END;
	END f_act_cbloqueocol;

	/* Fin Bug 23940*/
	/* Bug 26472 - NSS - 04/04/2013*/
	FUNCTION f_acciones_cierre(
			pnsinies	IN	VARCHAR2
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_propio.f_acciones_cierre';
	  vparam      VARCHAR2(2000):='par¿metros -  pnsinies : '
	                         || pnsinies;
	  vpasexec    NUMBER(5):=1;
	  v_cont      NUMBER;
	  v_ss        VARCHAR2(3000);
	  v_cursor    NUMBER;
	  v_filas     NUMBER;
	  v_propio    VARCHAR2(50);
	  v_retorno   NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	BEGIN
	    IF pnsinies IS NULL THEN
	      RETURN 0;
	    END IF;

	    SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    SELECT 'BEGIN '
	           || ' :RETORNO := '
	           || v_propio
	           || '.'
	           || 'f_acciones_cierre('''
	           || pnsinies
	           || '''); END;'
	      INTO v_ss
	      FROM dual;

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, v_ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', v_retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', v_retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             RETURN 0;
	END f_acciones_cierre;

	/* Fin Bug 26472 - NSS - 04/04/2013*/
	/* Bug 26989 - APD - 09/05/2013 -  se crea la funcion*/
	FUNCTION f_valor_asegurado(
			psseguro	IN	NUMBER,
			pnriesgo	IN	NUMBER,
			pnmovimi	IN	NUMBER
	) RETURN NUMBER
	IS
	  vobjectname  VARCHAR2(500):='pac_propio.f_valor_asegurado';
	  vparam       VARCHAR2(2000):='par¿metros - psseguro : '
	                         || psseguro
	                         || ' - pnriesgo : '
	                         || pnriesgo
	                         || ' - pnmovimi : '
	                         || pnmovimi;
	  vpasexec     NUMBER(5):=1;
	  ss           VARCHAR2(3000);
	  v_cursor     NUMBER;
	  v_filas      NUMBER;
	  v_propio     VARCHAR2(50);
	  v_cempres    seguros.cempres%TYPE;
	  v_sproduc    seguros.sproduc%TYPE;
	  retorno      NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	  vcbloqueocol seguros.cbloqueocol%TYPE;
	/* Se debe declarar el componente*/
	BEGIN
	    BEGIN
	        SELECT cempres
	          INTO v_cempres
	          FROM seguros
	         WHERE sseguro=psseguro;
	    EXCEPTION
	        WHEN OTHERS THEN
	          RETURN 0;
	    END;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'f_valor_asegurado('
	        || psseguro
	        || ','
	        || pnriesgo
	        || ','
	        || pnmovimi
	        || ')'
	        || ';'
	        || 'END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             /*
	               Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
	               a una funci¿n, procedimiento, etc. inexistente o no declarado. En este
	               caso a continaci¿n ejecutamos el c¿digo tradicional para determinar
	               si la p¿liza est¿ o no reducida.
	             */
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             BEGIN
	                 vpasexec:=1;

	                 SELECT SUM(g.icaptot)
	                   INTO retorno
	                   FROM seguros s,garanseg g
	                  WHERE s.sseguro=g.sseguro AND
	                        s.sseguro=psseguro AND
	                        (g.nriesgo=pnriesgo  OR
	                         pnriesgo IS NULL) AND
	                        ((g.nmovimi=pnmovimi AND
	                          pnmovimi IS NOT NULL)  OR
	                         (g.ffinefe IS NULL AND
	                          pnmovimi IS NULL));

	                 RETURN retorno;
	             EXCEPTION
	                 WHEN OTHERS THEN
	                   p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, SQLCODE
	                                                                                 || ' '
	                                                                                 || SQLERRM);

	                   RETURN 0;
	             END;
	END f_valor_asegurado;

	/* Fin Bug 23940*/
	/* Bug 26962 - NSS - 17/05/2013*/
	FUNCTION f_acciones_apertura(
			pnsinies	IN	VARCHAR2
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_propio.f_acciones_apertura';
	  vparam      VARCHAR2(2000):='par¿metros -  pnsinies : '
	                         || pnsinies;
	  vpasexec    NUMBER(5):=1;
	  v_cont      NUMBER;
	  v_ss        VARCHAR2(3000);
	  v_cursor    NUMBER;
	  v_filas     NUMBER;
	  v_propio    VARCHAR2(50);
	  v_retorno   NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	BEGIN
	    IF pnsinies IS NULL THEN
	      RETURN 0;
	    END IF;

	    SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    SELECT 'BEGIN '
	           || ' :RETORNO := '
	           || v_propio
	           || '.'
	           || 'f_acciones_apertura('''
	           || pnsinies
	           || '''); END;'
	      INTO v_ss
	      FROM dual;

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, v_ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', v_retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', v_retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             RETURN 0;
	END f_acciones_apertura;

	/* Fin Bug 26962 - NSS - 17/05/2013*/
	/* Bug 26675 - JRH - 13/08/2013*/
	FUNCTION f_get_provision(
			p_nsinies	IN	VARCHAR2,
			p_ntramte	IN	NUMBER,
			p_ntramit	IN	NUMBER,
			p_fecha	IN	DATE,
			pcgarant	IN	NUMBER,
			p_iprovis	OUT	NUMBER
	) RETURN NUMBER
	IS
	  v_objectname VARCHAR2(500):='pac_propio.f_get_provision';
	  v_param      VARCHAR2(500):='par¿metros - pnsinies: '
	                         || p_nsinies
	                         || ' pntramte:'
	                         || p_ntramte
	                         || ' p_ntramit:'
	                         || p_ntramit;
	  v_pasexec    NUMBER:=1;
	  v_ntramte    NUMBER;
	  leer_tramite NUMBER;
	  v_fcambio    DATE;
	BEGIN
	    p_iprovis:=0;

	    /* Primero buscamos la reserva global.*/
	    SELECT nvl(SUM(nvl(str.ireserva_moncia, str.ireserva)), 0)
	      INTO p_iprovis
	      FROM sin_tramita_reserva str
	     WHERE nsinies=p_nsinies AND
	           str.cgarant=nvl(pcgarant, str.cgarant) AND
	           str.cgarant NOT IN(283, 282, 48) AND
	           ntramit=(SELECT min(ntramit)
	                      FROM sin_tramitacion ta,sin_tramite te
	                     WHERE ta.ntramte=te.ntramte AND
	                           te.ctramte=9999 AND
	                           ta.nsinies=te.nsinies AND
	                           ta.nsinies=str.nsinies) AND
	           str.nmovres=(SELECT max(nmovres)
	                          FROM sin_tramita_reserva str1
	                         WHERE str1.nsinies=str.nsinies AND
	                               str1.ntramit=str.ntramit AND
	                               str1.cgarant=nvl(pcgarant, str1.cgarant) AND
	                               str1.cgarant NOT IN(283, 282, 48) AND
	                               fmovres<p_fecha+1);

	    v_pasexec:=2;

	    /* Si no hay reserva global, buscamos la de la tramitacion o el tramite*/
	    IF p_iprovis=0 THEN
	      IF p_ntramit IS NULL THEN
	        v_ntramte:=p_ntramte;

	        leer_tramite:=1;
	      ELSIF pac_sin_tramite.ff_hay_tramites(p_nsinies)=1 THEN
	        SELECT ntramte
	          INTO v_ntramte
	          FROM sin_tramitacion
	         WHERE nsinies=p_nsinies AND
	               ntramit=p_ntramit;

	        leer_tramite:=1;
	      ELSE
	        leer_tramite:=0;
	      END IF;

	      v_pasexec:=3;

	    /* 23741:ASN:03/10/2012 ini*/
	    /*
	             FOR tr IN (SELECT ntramit
	                          FROM sin_tramitacion
	                         WHERE nsinies = p_nsinies
	                           AND ntramte = v_ntramte
	                           AND leer_tramite = 1   -- todas las tramitaciones de un tramite
	                        UNION
	                        SELECT p_ntramit
	                        SELECT ntramit
	                          FROM DUAL
	                         WHERE leer_tramite = 0   -- solo una tramitacion en concreto
	                        -- 23741:ASN:28/09/2012 ini
	                        UNION
	                        SELECT ntramit
	                          FROM sin_tramitacion
	                         WHERE nsinies = p_nsinies
	                           AND p_ntramit = 99)   -- todo el siniestro
	    */ -- 23741:ASN:28/09/2012 fin
	      FOR tr IN (SELECT ntramit
	                   FROM sin_tramitacion
	                  WHERE nsinies=p_nsinies AND
	                        ntramte=v_ntramte AND
	                        leer_tramite=1
	                 /* todas las tramitaciones de un tramite*/
	                 UNION
	                 SELECT ntramit
	                   FROM sin_tramitacion
	                  WHERE leer_tramite=0
	                        /* solo una tramitacion en concreto*/
	                        AND
	                        ntramit=p_ntramit
	                 UNION
	                 SELECT ntramit
	                   FROM sin_tramitacion
	                  WHERE nsinies=p_nsinies AND
	                        p_ntramit=99 /* todo el siniestro*/
	                )
	      /* 23741:ASN:03/10/2012 fin*/
	      LOOP
	          v_pasexec:=4;

	          SELECT p_iprovis
	                 +nvl(SUM(nvl(r1.ireserva_moncia, nvl(r1.ireserva, 0)) + 0 - 0 - 0), 0)
	            INTO p_iprovis
	            FROM sin_tramita_reserva r1
	           WHERE r1.nsinies=p_nsinies AND
	                 r1.ntramit=tr.ntramit AND
	                 r1.cgarant=nvl(pcgarant, r1.cgarant) AND
	                 r1.cgarant NOT IN(283, 282, 48) AND
	                 r1.ctipres=1 /* Indemnizatoria*/
	                 AND
	                 (r1.cgarant, nvl(r1.fresini, f_sysdate), r1.nmovres) IN(SELECT r2.cgarant,max(nvl(r2.fresini, f_sysdate)),max(r2.nmovres)
	                                                                           FROM sin_tramita_reserva r2
	                                                                          WHERE r2.nsinies=r1.nsinies AND
	                                                                                r2.ntramit=r1.ntramit AND
	                                                                                r2.cgarant=nvl(pcgarant, r2.cgarant) AND
	                                                                                r2.cgarant NOT IN(283, 282, 48) AND
	                                                                                r2.ctipres=r1.ctipres AND
	                                                                                fmovres<p_fecha+1
	                                                                          GROUP BY cgarant);
	      END LOOP;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_objectname, v_pasexec, v_param, 'SQLERROR: '
	                                                                              || SQLCODE
	                                                                              || ' - '
	                                                                              || SQLERRM);

	             RETURN 1;
	END f_get_provision;
	FUNCTION f_get_pagos(
			p_nsinies	IN	VARCHAR2,
			p_fechafin	IN	DATE,
			p_fechaini	IN	DATE,
			pcgarant	IN	NUMBER
	) RETURN NUMBER
	IS
	  v_objectname VARCHAR2(500):='pac_propio.f_get_pagos';
	  v_param      VARCHAR2(500):='par¿metros - pnsinies: '
	                         || p_nsinies
	                         || ' p_fechafin:'
	                         || p_fechafin
	                         || ' p_fechaini:'
	                         || p_fechaini;
	  v_pasexec    NUMBER:=1;
	  v_ntramte    NUMBER;
	  leer_tramite NUMBER;
	  v_fcambio    DATE;
	  vpagos       NUMBER;
	BEGIN
	    SELECT nvl(SUM(decode(m.cestpag, 8, -1,
	                                     1)*p.isinret), 0)
	      INTO vpagos
	      FROM sin_siniestro si,sin_tramita_pago p,sin_tramita_movpago m,seguros se,sin_tramita_pago_gar pg
	     WHERE nvl(m.fcontab, m.fefepag) BETWEEN p_fechaini AND p_fechafin AND
	           p.nsinies=si.nsinies AND
	           m.sidepag=p.sidepag AND
	           se.sseguro=si.sseguro AND
	           pg.sidepag=p.sidepag AND
	           pg.cgarant NOT IN(283, 282, 48) AND
	           pg.cgarant=nvl(pcgarant, pg.cgarant) AND
	           m.cestpag IN(2, 8) AND
	           si.nsinies=p_nsinies;

	    RETURN vpagos;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_objectname, v_pasexec, v_param, 'SQLERROR: '
	                                                                              || SQLCODE
	                                                                              || ' - '
	                                                                              || SQLERRM);

	             RETURN 1;
	END f_get_pagos;
	FUNCTION f_get_recibos(
			psseguro	IN	NUMBER,
			pcconcep	IN	NUMBER,
			p_fechafin	IN	DATE,
			p_fechaini	IN	DATE,
			pcgarant	IN	NUMBER
	) RETURN NUMBER
	IS
	  v_objectname VARCHAR2(500):='pac_propio.f_get_recibos';
	  v_param      VARCHAR2(500):='par¿metros - psseguro: '
	                         || psseguro
	                         || ' p_fechafin:'
	                         || p_fechafin
	                         || ' p_fechaini:'
	                         || p_fechaini;
	  v_pasexec    NUMBER:=1;
	  v_ntramte    NUMBER;
	  leer_tramite NUMBER;
	  v_fcambio    DATE;
	  vrecaudo     NUMBER:=0;
	  vrecaudo2    NUMBER:=0;
	  vnpoliza     NUMBER;
	  vreb         NUMBER;
	  v_coacedido  NUMBER:=0;
	  v_coacedido2 NUMBER:=0;
	BEGIN
	    SELECT count(*)
	      INTO vreb
	      FROM recibos
	     WHERE sseguro=psseguro;

	    IF vreb>=1 THEN
	      SELECT nvl(SUM(decode(r.ctiprec, 9, -v.iconcep,
	                                       13, -v.iconcep,
	                                       v.iconcep)), 0)
	        INTO vrecaudo
	        FROM recibos r,detrecibos v,movrecibo m
	       WHERE r.sseguro=psseguro
	             /*  AND f_cestrec(r.nrecibo, NULL) = 1*/
	             AND
	             m.nrecibo=r.nrecibo AND
	             m.fmovfin IS NULL
	             /*   AND m.fcontab BETWEEN p_fechaini AND p_fechafin*/
	             AND
	             m.fefeadm BETWEEN p_fechaini AND p_fechafin AND
	             m.cestrec=1 AND
	             pac_adm.f_es_recibo_riesgo(r.nrecibo)=1 AND
	             r.nrecibo=v.nrecibo AND
	             v.cgarant=nvl(pcgarant, v.cgarant) AND
	             v.cconcep=pcconcep;

	      /*Primas coaseguro cedido. Siempres es el N¿ de concepto + 50*/
	      SELECT nvl(SUM(decode(r.ctiprec, 9, -v.iconcep,
	                                       13, -v.iconcep,
	                                       v.iconcep)), 0)
	        INTO v_coacedido
	        FROM recibos r,detrecibos v,movrecibo m
	       WHERE r.sseguro=psseguro AND
	             m.nrecibo=r.nrecibo AND
	             m.fmovfin IS NULL AND
	             m.fefeadm BETWEEN p_fechaini AND p_fechafin AND
	             m.cestrec=1 AND
	             pac_adm.f_es_recibo_riesgo(r.nrecibo)=1 AND
	             r.nrecibo=v.nrecibo AND
	             v.cgarant=nvl(pcgarant, v.cgarant) AND
	             v.cconcep=pcconcep+50;

	      vrecaudo:=vrecaudo+v_coacedido;
	    ELSE
	      SELECT npoliza
	        INTO vnpoliza
	        FROM seguros
	       WHERE sseguro=psseguro;

	      FOR reg IN (SELECT * /*Miramos el colectivo*/
	                    FROM seguros
	                   WHERE npoliza=vnpoliza) LOOP
	          SELECT nvl(SUM(decode(r.ctiprec, 9, -v.iconcep,
	                                           13, -v.iconcep,
	                                           v.iconcep)), 0)
	            INTO vrecaudo2
	            FROM recibos r,detrecibos v,movrecibo m
	           WHERE r.sseguro=reg.sseguro
	                 /*  AND f_cestrec(r.nrecibo, NULL) = 1*/
	                 AND
	                 m.nrecibo=r.nrecibo AND
	                 m.fmovfin IS NULL
	                 /*   AND m.fcontab BETWEEN p_fechaini AND p_fechafin*/
	                 AND
	                 m.fefeadm BETWEEN p_fechaini AND p_fechafin AND
	                 m.cestrec=1 AND
	                 pac_adm.f_es_recibo_riesgo(r.nrecibo)=1 AND
	                 r.nrecibo=v.nrecibo AND
	                 v.cgarant=nvl(pcgarant, v.cgarant) AND
	                 v.cconcep=pcconcep;

	          /*Primas coaseguro cedido. Siempres es el N¿ de concepto + 50*/
	          SELECT nvl(SUM(decode(r.ctiprec, 9, -v.iconcep,
	                                           13, -v.iconcep,
	                                           v.iconcep)), 0)
	            INTO v_coacedido2
	            FROM recibos r,detrecibos v,movrecibo m
	           WHERE r.sseguro=reg.sseguro
	                 /*  AND f_cestrec(r.nrecibo, NULL) = 1*/
	                 AND
	                 m.nrecibo=r.nrecibo AND
	                 m.fmovfin IS NULL
	                 /*   AND m.fcontab BETWEEN p_fechaini AND p_fechafin*/
	                 AND
	                 m.fefeadm BETWEEN p_fechaini AND p_fechafin AND
	                 m.cestrec=1 AND
	                 pac_adm.f_es_recibo_riesgo(r.nrecibo)=1 AND
	                 r.nrecibo=v.nrecibo AND
	                 v.cgarant=nvl(pcgarant, v.cgarant) AND
	                 v.cconcep=pcconcep+50;

	          vrecaudo:=vrecaudo+vrecaudo2+v_coacedido2;
	      END LOOP;
	    END IF;

	    /* AND fefecto >= vfrenova*/
	    RETURN vrecaudo;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_objectname, v_pasexec, v_param, 'SQLERROR: '
	                                                                              || SQLCODE
	                                                                              || ' - '
	                                                                              || SQLERRM);

	             RETURN 1;
	END f_get_recibos;
	FUNCTION f_get_pagos_provis_pol(
			psseguro NUMBER,
			pfechafin DATE,
			wfechaini	IN	DATE,
			pcgarant NUMBER,
			pprovis	OUT	NUMBER,
			ppagos	OUT	NUMBER
	) RETURN NUMBER
	IS
	  vcempres     NUMBER;
	  v_objectname VARCHAR2(500):='pac_propio_pos.f_get_pagos_provis_pol';
	  v_param      VARCHAR2(500):='par¿metros - psseguro: '
	                         || psseguro
	                         || ' wfechaini:'
	                         || wfechaini
	                         || ' pfechafin:'
	                         || pfechafin;
	  vpagos       NUMBER:=0;
	  v_iprovis    NUMBER:=0;
	  vfreservas   NUMBER:=0;
	  vnpoliza     NUMBER:=0;
	  v_pasexec    NUMBER;
	  verr         NUMBER;
	BEGIN
	    SELECT npoliza
	      INTO vnpoliza
	      FROM seguros
	     WHERE sseguro=psseguro;

	    FOR reg IN (SELECT sseguro
	                  FROM seguros
	                 WHERE npoliza=vnpoliza) LOOP /*Sacamos todo el colectivo*/
	        FOR reg2 IN (SELECT *
	                       FROM sin_siniestro s
	                      WHERE s.sseguro=reg.sseguro) LOOP
	            v_pasexec:=4;

	            vpagos:=vpagos
	                    +f_get_pagos(reg2.nsinies, pfechafin, wfechaini, pcgarant);

	            v_pasexec:=5;

	            /*verr := f_get_provision(reg2.nsinies, NULL, 99, pfechafin, pcgarant, v_iprovis);*/
	            verr:=f_provisio(reg2.nsinies, v_iprovis, pfechafin, 1);

	            v_pasexec:=6;

	            IF verr<0 THEN
	              RAISE no_data_found;
	            END IF;

	            v_pasexec:=7;

	            vfreservas:=vfreservas+v_iprovis;
	        END LOOP;
	    END LOOP;

	    pprovis:=vfreservas;

	    ppagos:=vpagos;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_objectname, v_pasexec, v_param, 'SQLERROR: '
	                                                                              || SQLCODE
	                                                                              || ' - '
	                                                                              || SQLERRM);

	             RETURN 1;
	END f_get_pagos_provis_pol;
	FUNCTION f_get_siniestralidad(
			pnsesion NUMBER,
			psseguro	IN	NUMBER,
			pnriesgo	IN	NUMBER DEFAULT 1,
			pcgarant	IN	NUMBER DEFAULT NULL,
			parfechafin	IN	DATE DEFAULT NULL,
			pfechaini	IN	DATE DEFAULT NULL
	) RETURN NUMBER
	IS
	  vcempres        NUMBER;
	  v_objectname    VARCHAR2(500):='pac_propio_pos.f_get_siniestralidad';
	  v_param         VARCHAR2(500):='par¿metros - psseguro: '
	                         || psseguro
	                         || ' pnriesgo:'
	                         || pnriesgo
	                         || ' pfechafin:'
	                         || parfechafin;
	  wfechaini       DATE;
	  vpagos          NUMBER:=0;
	  vfreservas      NUMBER:=0;
	  vrecaudo        NUMBER;
	  pfechafin       DATE;
	  v_iprovis       NUMBER;
	  verr            NUMBER;
	  vnpoliza        NUMBER;
	  v_pasexec       NUMBER;
	  vsiniestralidad NUMBER;
	BEGIN
	    IF psseguro IS NULL  OR
	       pnriesgo IS NULL THEN
	      RAISE no_data_found;
	    END IF;

	    v_pasexec:=1;

	    SELECT npoliza
	      INTO vnpoliza
	      FROM seguros
	     WHERE sseguro=psseguro;

	    v_pasexec:=2;

	    pfechafin:=nvl(parfechafin, f_sysdate);

	    wfechaini:=nvl(pfechaini, add_months(pfechafin, -12));

	    v_pasexec:=3;

	    verr:=f_get_pagos_provis_pol(psseguro, pfechafin, wfechaini, pcgarant, vfreservas, vpagos);

	    IF verr<>0 THEN
	      RAISE no_data_found;
	    END IF;

	    v_pasexec:=8;

	    vrecaudo:=f_get_recibos(psseguro, 0, pfechafin, wfechaini, pcgarant);

	    v_pasexec:=10;

	    /*      DBMS_OUTPUT.put_line('wfechaini:' || wfechaini);*/
	    /*      DBMS_OUTPUT.put_line('pfechafin:' || pfechafin);*/
	    /*      DBMS_OUTPUT.put_line('vpagos:' || vpagos);*/
	    /*      DBMS_OUTPUT.put_line('vfreservas:' || vfreservas);*/
	    /*      DBMS_OUTPUT.put_line('vrecaudo:' || vrecaudo);*/
	    /*--*/
	    IF vrecaudo=0 THEN
	      vsiniestralidad:=0;
	    ELSE
	      vsiniestralidad:=100*((vpagos+vfreservas)/vrecaudo);
	    END IF;

	    RETURN vsiniestralidad;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_objectname, v_pasexec, v_param, 'SQLERROR: '
	                                                                              || SQLCODE
	                                                                              || ' - '
	                                                                              || SQLERRM);

	             RETURN -1;
	END f_get_siniestralidad;
	FUNCTION f_get_pb(
			pnsesion NUMBER,
			psseguro	IN	NUMBER,
			parfechafin	IN	DATE DEFAULT NULL,
			pfechaini	IN	DATE DEFAULT NULL
	) RETURN NUMBER
	IS
	  vcempres         NUMBER;
	  v_objectname     VARCHAR2(500):='pac_propio.f_get_pb';
	  v_param          VARCHAR2(500):='par¿metros - psseguro: '
	                         || psseguro
	                         || ' parfechafin:'
	                         || parfechafin
	                         || ' pfechaini:'
	                         || pfechaini;
	  wfechaini        DATE;
	  vpagos           NUMBER:=0;
	  vfreservas       NUMBER:=0;
	  vrecaudo         NUMBER:=0;
	  vpctutili        NUMBER;
	  vcomision        NUMBER:=0;
	  vgastos          NUMBER:=0;
	  vgastosrea       NUMBER:=0;
	  pfechafin        DATE;
	  v_siniestralidad NUMBER;
	  verr             NUMBER;
	  vnpoliza         NUMBER;
	  v_pasexec        NUMBER;
	  vsiniestralidad  NUMBER;
	  vutilidad        NUMBER;
	  v_iprovis        NUMBER;
	BEGIN
	    IF psseguro IS NULL THEN
	      RAISE no_data_found;
	    END IF;

	    v_pasexec:=1;

	    SELECT npoliza
	      INTO vnpoliza
	      FROM seguros
	     WHERE sseguro=psseguro;

	    v_pasexec:=2;

	    pfechafin:=nvl(parfechafin, f_sysdate);

	    wfechaini:=nvl(pfechaini, add_months(pfechafin, -12));

	    v_pasexec:=3;

	    vgastos:=vgastos; /*JRH IMP*/

	    vgastosrea:=vgastosrea; /*JRH IMP*/

	    verr:=f_get_pagos_provis_pol(psseguro, pfechafin, wfechaini, NULL, vfreservas, vpagos);

	    IF verr<>0 THEN
	      RAISE no_data_found;
	    END IF;

	    v_pasexec:=8;

	    vrecaudo:=pac_propio.f_get_recibos(psseguro, 0, pfechafin, wfechaini, NULL);

	    vcomision:=pac_propio.f_get_recibos(psseguro, 11, pfechafin, wfechaini, NULL);

	    v_siniestralidad:=pac_propio.f_get_siniestralidad(-1, psseguro, 1, NULL, pfechafin, wfechaini);

	    v_pasexec:=10;

	    vutilidad:=vrecaudo-vcomision-vpagos-vfreservas-vgastos-vgastosrea;

	    /*      DBMS_OUTPUT.put_line('wfechaini:' || wfechaini);*/
	    /*      DBMS_OUTPUT.put_line('pfechafin:' || pfechafin);*/
	    /*      DBMS_OUTPUT.put_line('vpagos:' || vpagos);*/
	    /*      DBMS_OUTPUT.put_line('vfreservas:' || vfreservas);*/
	    /*      DBMS_OUTPUT.put_line('vrecaudo:' || vrecaudo);*/
	    /* DBMS_OUTPUT.put_line('v_siniestralidad :' || v_siniestralidad );*/
	    /*  DBMS_OUTPUT.put_line('vutilidad :' || vutilidad );*/
	    vpctutili:=0;

	    /*JRH Substituir por una subtabs*/
	    IF vsiniestralidad BETWEEN -1 AND 30 THEN
	      vpctutili:=15;
	    ELSIF vsiniestralidad BETWEEN 30 AND 40 THEN
	      vpctutili:=10;
	    ELSIF vsiniestralidad BETWEEN 40 AND 50 THEN
	      vpctutili:=5;
	    ELSIF vsiniestralidad>50 THEN
	      vpctutili:=0;
	    ELSE
	      vpctutili:=0;
	    END IF;

	    /*       DBMS_OUTPUT.put_line('vpctutili :' || vpctutili );*/
	    /*  DBMS_OUTPUT.put_line('vutilidad * vpctutili / 100 :' || to_char(vutilidad * vpctutili / 100 ));*/
	    RETURN vutilidad*vpctutili/100;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_objectname, v_pasexec, v_param, 'SQLERROR: '
	                                                                              || SQLCODE
	                                                                              || ' - '
	                                                                              || SQLERRM);

	             RETURN -1;
	END f_get_pb;

	/*Fi  Bug 26675 - JRH*/
	/* BUG 25720 - FAL - 02/09/2013*/
	FUNCTION f_get_numpol_dispo(
			p_cempres	IN	NUMBER,
			p_tipo	IN	VARCHAR2,
			p_caux	IN	NUMBER,
			p_exp	IN	NUMBER DEFAULT 6
	) RETURN NUMBER
	IS
	  v_ss      VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_retorno NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	/* Se debe declarar el componente*/
	BEGIN
	    IF p_cempres IS NULL  OR
	       p_tipo IS NULL  OR
	       p_caux IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    SELECT pac_parametros.f_parempresa_t(p_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    v_ss:='BEGIN '
	          || ' :RETORNO := '
	          || v_propio
	          || '.'
	          || 'f_get_numpol_dispo('''
	          || p_tipo
	          || ''','
	          || p_caux
	          || ','
	          || p_exp
	          || ')'
	          || ';'
	          || 'END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, v_ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', v_retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', v_retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.F_GET_NUMPOL_DISPO', 1, 'PARAMETROS OBLIGATORIOS NO INFORMADOS - '
	                                                                                || 'p_cempres = '
	                                                                                || p_cempres
	                                                                                || '; p_tipo = '
	                                                                                || p_tipo
	                                                                                || '; p_caux = '
	                                                                                || p_caux
	                                                                                || '; p_exp = '
	                                                                                || p_exp, SQLERRM);

	             RETURN NULL; WHEN ex_nodeclared THEN
	           /*  Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada*/
	             /*  a una funci¿n, procedimiento, etc. inexistente o no declarado.*/
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             /* Si la funci¿n no existe para la empresa, llamamos a la F_CONTADOR gen¿rica*/
	             RETURN f_contador(p_tipo, p_caux);
	END f_get_numpol_dispo;

	/* FI BUG 25720 - FAL - 02/09/2013*/
	/* BUG 27909 - NSS - 04/09/2013*/
	FUNCTION f_get_lstcconpag(
			psproduc	IN	NUMBER DEFAULT NULL,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN SYS_REFCURSOR
	IS
	  v_psproduc NUMBER;
	  v_propio   VARCHAR2(50);
	  ss         VARCHAR2(10000);
	  v_cursor   NUMBER;
	  v_filas    NUMBER;
	  v_squery   VARCHAR2(10000);
	  retorno    SYS_REFCURSOR;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	  /* Se debe declarar el componente*/
	  vpasexec   NUMBER(8):=1;
	  vparam     VARCHAR2(4000):=' psproduc='
	                         || psproduc;
	  vobject    VARCHAR2(200):='PAC_PROPIO.f_get_lstcconpag';
	BEGIN
	    SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    IF psproduc IS NULL THEN
	      v_psproduc:='null';
	    ELSE
	      v_psproduc:=psproduc;
	    END IF;

	    ss:='BEGIN '
	        || ' :V_SQUERY := '
	        || v_propio
	        || '.'
	        || 'f_get_lstcconpag ('
	        || v_psproduc
	        || ')'
	        || ';'
	        || 'END;';

	    vpasexec:=2;

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    vpasexec:=3;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':V_SQUERY', v_squery, 10000);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'V_SQUERY', v_squery);

	    vpasexec:=4;

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    vpasexec:=5;

	    retorno:=pac_md_listvalores.f_opencursor(v_squery, mensajes);

	    vpasexec:=6;

	    RETURN retorno;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'PARAMETROS OBLIGATORIOS NO INFORMADOS '
	                                                               || vparam, SQLERRM);

	             RETURN NULL; WHEN ex_nodeclared THEN
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             retorno:=pac_md_listvalores.f_detvalores(803, mensajes);

	             RETURN retorno; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'parametros: '
	                                                               || vparam, SQLERRM);

	             RETURN NULL; /* Error no controlado*/
	END f_get_lstcconpag;
	FUNCTION f_get_lstcconpag_dep(
			pctippag	IN	NUMBER,
			psproduc	IN	NUMBER DEFAULT NULL,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN SYS_REFCURSOR
	IS
	  v_psproduc NUMBER;
	  v_propio   VARCHAR2(50);
	  ss         VARCHAR2(10000);
	  v_cursor   NUMBER;
	  v_squery   VARCHAR2(10000);
	  v_filas    NUMBER;
	  retorno    SYS_REFCURSOR;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	  /* Se debe declarar el componente*/
	  vpasexec   NUMBER(8):=1;
	  vparam     VARCHAR2(4000):=' psproduc='
	                         || psproduc;
	  vobject    VARCHAR2(200):='PAC_PROPIO.f_get_lstcconpag_dep';
	BEGIN
	    SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    /* comprobar campos obligatorios*/
	    IF pctippag IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    IF psproduc IS NULL THEN
	      v_psproduc:='null';
	    ELSE
	      v_psproduc:=psproduc;
	    END IF;

	    ss:='BEGIN '
	        || ' :V_SQUERY := '
	        || v_propio
	        || '.'
	        || 'f_get_lstcconpag_dep ('
	        || pac_md_common.f_get_cxtempresa
	        || ','
	        || pctippag
	        || ','
	        || v_psproduc
	        || ')'
	        || ';'
	        || 'END;';

	    vpasexec:=2;

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    vpasexec:=3;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':V_SQUERY', v_squery, 10000);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'V_SQUERY', v_squery);

	    vpasexec:=4;

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    vpasexec:=5;

	    retorno:=pac_md_listvalores.f_opencursor(v_squery, mensajes);

	    /*OPEN retorno FOR v_squery;*/
	    vpasexec:=6;

	    RETURN retorno;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'PARAMETROS OBLIGATORIOS NO INFORMADOS '
	                                                               || vparam, SQLERRM);

	             RETURN NULL; WHEN ex_nodeclared THEN
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             retorno:=pac_md_listvalores.f_detvalores_dep(pac_md_common.f_get_cxtempresa, 2, pctippag, 803, mensajes);

	             RETURN retorno; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'parametros: '
	                                                               || vparam, SQLERRM);

	             RETURN NULL; /* Error no controlado*/
	END f_get_lstcconpag_dep;

	/* FI BUG 27909 - NSS - 04/09/2013*/
	/*INI BUG 29659#c163123 - JDS - 14/01/2014*/
	FUNCTION f_mig_autos(
			p_cempres	IN	NUMBER,
			p_cmatric	IN	VARCHAR2,
			p_sseguro	IN	NUMBER,
			pqueryaut	OUT	VARCHAR2,
			pqueryaccesorios	OUT	VARCHAR2,
			pquerydispositivos	OUT	VARCHAR2
	) RETURN NUMBER
	IS
	  v_propio  VARCHAR2(50);
	  v_ss      VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_retorno NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	/* Se debe declarar el componente*/
	BEGIN
	    IF p_cempres IS NULL  OR
	       p_cmatric IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    SELECT pac_parametros.f_parempresa_t(p_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    v_ss:='BEGIN '
	          || ' :RETORNO := '
	          || v_propio
	          || '.'
	          || 'f_mig_autos('''
	          || p_cmatric
	          || ''','
	          || p_sseguro
	          || ' , :QUERYAUTOS , :QUERYACC, :QUERYDISP )'
	          || ';'
	          || ' END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, v_ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', v_retorno);

	    dbms_sql.bind_variable(v_cursor, ':QUERYAUTOS', pqueryaut, 1000);

	    dbms_sql.bind_variable(v_cursor, ':QUERYACC', pqueryaccesorios, 1000);

	    dbms_sql.bind_variable(v_cursor, ':QUERYDISP', pquerydispositivos, 1000);

	    v_retorno:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', v_retorno);

	    dbms_sql.variable_value(v_cursor, 'QUERYAUTOS', pqueryaut);

	    dbms_sql.variable_value(v_cursor, 'QUERYACC', pqueryaccesorios);

	    dbms_sql.variable_value(v_cursor, 'QUERYDISP', pquerydispositivos);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_mig_autos', 1, 'PARAMETROS OBLIGATORIOS NO INFORMADOS - '
	                                                                         || 'p_cempres = '
	                                                                         || p_cempres
	                                                                         || '; p_cmatric = '
	                                                                         || p_cmatric, SQLERRM);

	             RETURN NULL; WHEN ex_nodeclared THEN
	           /* Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada*/
	             /* a una funci¿n, procedimiento, etc. inexistente o no declarado.*/
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             pqueryaut:=' UNION SELECT NULL, NULL, p.cmatric, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
	             to_char(p.cmodelo), p.cmarca, to_char(p.ctipveh), NULL, NULL, NULL, p.cchasis, NULL, NULL, NULL, p.cmotor, NULL, NULL, NULL, NULL,
	             NULL, NULL, NULL, p.anyo, NULL, NULL, NULL , NULL, NULL, NULL FROM aut_mig_matriculas p where p.cmatric like '''
	                        || p_cmatric
	                        || ''' and rownum = 1';

	             RETURN 0;
	END f_mig_autos;

	/*FI BUG 29659#c163123 - JDS - 14/01/2014*/
	/* Bug 29943 - 19/02/2014 - SHA*/
	/*************************************************************************
	    FUNCTION f_alta_poliza_pu

	 *************************************************************************/
	FUNCTION f_alta_poliza_pu(
			psseguro	IN	NUMBER,
			pfefecto	IN	DATE,
			ppu	IN	NUMBER,
			pcempres	IN	NUMBER,
			pnew_npoliza	OUT	NUMBER
	) RETURN NUMBER
	IS
	  v_propio      VARCHAR2(100);
	  ss            VARCHAR2(2000);
	  v_cursor      NUMBER;
	  v_filas       NUMBER;
	  retorno       NUMBER;
	  v_new_npoliza NUMBER;
	BEGIN
	    IF psseguro IS NULL  OR
	       pfefecto IS NULL  OR
	       ppu IS NULL  OR
	       pcempres IS NULL THEN
	      RETURN NULL;
	    END IF;

	    SELECT pac_parametros.f_parempresa_t(pcempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'f_alta_poliza_pu('''
	        || psseguro
	        || ''', TO_DATE('''
	        || to_char(pfefecto, 'DD/MM/YYYY')
	        || '''), '''
	        || ppu
	        || ''',:NEW_NPOLIZA)'
	        || ';'
	        || 'END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

	    dbms_sql.bind_variable(v_cursor, ':NEW_NPOLIZA', v_new_npoliza);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    dbms_sql.variable_value(v_cursor, 'NEW_NPOLIZA', v_new_npoliza);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    pnew_npoliza:=v_new_npoliza;

	    RETURN retorno;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_alta_poliza_pu', 2, 'psseguro:'
	                                                                              || psseguro
	                                                                              || ' pfefecto:'
	                                                                              || pfefecto
	                                                                              || ' ppu:'
	                                                                              || ppu
	                                                                              || ' pcempres:'
	                                                                              || pcempres, SQLCODE
	                                                                                           || '-'
	                                                                                           || SQLERRM);

	             RETURN NULL;
	END f_alta_poliza_pu;

	/*************************************************************************
	    FUNCTION f_alta_detalle_gar

	 *************************************************************************/
	FUNCTION f_alta_detalle_gar(psseguro	IN	NUMBER,pfefecto	IN	DATE,ppu	IN	NUMBER,pcempres	IN	NUMBER /*, pnew_npoliza	OUT	NUMBER*/

	)
	RETURN NUMBER
	IS
	  v_propio      VARCHAR2(100);
	  ss            VARCHAR2(2000);
	  v_cursor      NUMBER;
	  v_filas       NUMBER;
	  retorno       NUMBER;
	  v_new_npoliza NUMBER;
	BEGIN
	    IF psseguro IS NULL  OR
	       pfefecto IS NULL  OR
	       ppu IS NULL  OR
	       pcempres IS NULL THEN
	      RETURN NULL;
	    END IF;

	    SELECT pac_parametros.f_parempresa_t(pcempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'f_alta_detalle_gar('''
	        || psseguro
	        || ''', TO_DATE('''
	        || to_char(pfefecto, 'DD/MM/YYYY')
	        || ''',''DD/MM/YYYY''), '''
	        || ppu
	        || ''')'
	        || ';'
	        || 'END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_alta_detalle_gar', 2, 'psseguro:'
	                                                                                || psseguro
	                                                                                || ' pfefecto:'
	                                                                                || pfefecto
	                                                                                || ' ppu:'
	                                                                                || ppu
	                                                                                || ' pcempres:'
	                                                                                || pcempres, SQLCODE
	                                                                                             || '-'
	                                                                                             || SQLERRM);

	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_alta_detalle_gar', 2, 'ss = '
	                                                                                || ss, SQLCODE
	                                                                                       || '-'
	                                                                                       || SQLERRM);

	             RETURN NULL;
	END f_alta_detalle_gar;

	/*Fi Bug 29943 - 19/02/2014 - SHA*/
	/*Ini Bug 29224 - 24/02/2014 - NSS*/
	/*************************************************************************
	    FUNCTION f_get_municipios_pagos

	 *************************************************************************/
	FUNCTION f_get_municipios_pagos(
			pcempres	IN	NUMBER,
			pquery	OUT	VARCHAR2
	) RETURN NUMBER
	IS
	  v_propio  VARCHAR2(100);
	  v_ss      VARCHAR2(4000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_retorno NUMBER;
	  v_pquery  VARCHAR2(1000);
	  vpasexec  NUMBER:=0;
	BEGIN
	    IF pcempres IS NULL THEN
	      RETURN NULL;
	    END IF;

	    vpasexec:=1;

	    SELECT pac_parametros.f_parempresa_t(pcempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    vpasexec:=2;

	    v_ss:='DECLARE v_pquery varchar2(2000);'
	          || ' BEGIN '
	          || ' :v_retorno := '
	          || v_propio
	          || '.'
	          || 'f_get_municipios_pagos('
	          || ':vtlin1)'
	          || ';'
	          || 'END;';

	    EXECUTE IMMEDIATE v_ss
	    USING OUT v_retorno, OUT pquery;

	    vpasexec:=3;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_get_municipios_pagos', vpasexec, ' pcempres:'
	                                                                                           || pcempres, SQLCODE
	                                                                                                        || '-'
	                                                                                                        || SQLERRM);

	             RETURN NULL;
	END f_get_municipios_pagos;

	/*Fi Bug 29224 - 24/02/2014 - NSS*/
	/***********************************************************************
	     FUNCTION f_porcomision
	     Calcula porcentaje comision de un recibo

	     Bug 0031510 - 27/05/2014 - JMF
	***********************************************************************/
	FUNCTION f_porcomision(
			pnrecibo	IN	NUMBER
	) RETURN NUMBER
	IS
	  v_obj     VARCHAR2(200):='PAC_PROPIO.f_porcomision';
	  v_par     VARCHAR2(200):='r='
	                       || pnrecibo;
	  v_pas     NUMBER(4):=0;
	  /**/
	  v_cempres seguros.cempres%TYPE;
	  v_propio  VARCHAR2(50);
	  v_ss      VARCHAR2(3000);
	  v_retorno NUMBER;
	  /**/
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	/* Se debe declarar el componente*/
	BEGIN
	    v_pas:=10;

	    BEGIN
	        SELECT s.cempres
	          INTO v_cempres
	          FROM seguros s,recibos r
	         WHERE r.nrecibo=pnrecibo AND
	               s.sseguro=r.sseguro;
	    EXCEPTION
	        WHEN OTHERS THEN
	          RETURN NULL;
	    END;

	    v_pas:=20;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    v_pas:=30;

	    v_ss:='BEGIN '
	          || ' :v_retorno := '
	          || v_propio
	          || '.'
	          || 'f_porcomision('''
	          || pnrecibo
	          || ''' )'
	          || ';'
	          || 'END;';

	    v_pas:=40;

	    EXECUTE IMMEDIATE v_ss
	    USING OUT v_retorno;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	           /*  Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada*/
	           /*  a una funci¿n, procedimiento, etc. inexistente o no declarado.*/
	             /* Si la funci¿n no existe para la empresa, llamamos a la funci¿n gen¿rica*/
	             v_pas:=50;

	             BEGIN
	                 IF nvl(pac_parametros.f_parempresa_n(v_cempres, 'COMISION_LISTADO'), 0)=0 THEN
	                   v_pas:=60;

	                   SELECT (icombru*100)/nvl(iprinet+irecfra, 1)
	                     INTO v_retorno
	                     FROM vdetrecibos
	                    WHERE nrecibo=pnrecibo;
	                 ELSE
	                   v_pas:=70;

	                   SELECT (icombru*100)/nvl(iprinet, 1)
	                     INTO v_retorno
	                     FROM vdetrecibos
	                    WHERE nrecibo=pnrecibo;
	                 END IF;

	                 RETURN v_retorno;
	             EXCEPTION
	                 WHEN OTHERS THEN
	                   p_tab_error(f_sysdate, f_user, v_obj, v_pas, v_par, SQLCODE
	                                                                       || '-'
	                                                                       || SQLERRM);

	                   RETURN NULL; /* Error no controlado*/
	             END; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, v_obj, v_pas, v_par, SQLCODE
	                                                                 || '-'
	                                                                 || SQLERRM);

	             RETURN NULL; /* Error no controlado*/
	END f_porcomision;
	FUNCTION f_psu_retroactividad(
			pcempres	IN	NUMBER,
			psseguro	IN	NUMBER,
			pnmovimi	IN	NUMBER
	) RETURN NUMBER
	IS
	  v_propio  VARCHAR2(50);
	  v_cursor  NUMBER;
	  v_ss      VARCHAR2(10000);
	  v_filas   NUMBER;
	  v_squery  VARCHAR2(10000);
	  v_retorno NUMBER;
	  vpasexec  NUMBER(8):=1;
	  vparam    VARCHAR2(4000):=' pcempres='
	                         || pcempres
	                         || ' psseguro='
	                         || psseguro
	                         || ' pnmovimi='
	                         || pnmovimi;
	  vobject   VARCHAR2(200):='PAC_PROPIO.f_psu_retroactividad';
	BEGIN
	    SELECT pac_parametros.f_parempresa_t(pcempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    vpasexec:=2;

	    v_ss:='BEGIN '
	          || ' :RETORNO := '
	          || v_propio
	          || '.'
	          || 'f_psu_retroactividad('
	          || psseguro
	          || ','
	          || pnmovimi
	          || ')'
	          || ';'
	          || 'END;';

	    vpasexec:=4;

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    vpasexec:=5;

	    v_cursor:=dbms_sql.open_cursor;

	    vpasexec:=6;

	    dbms_sql.parse(v_cursor, v_ss, dbms_sql.native);

	    vpasexec:=7;

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', v_retorno);

	    vpasexec:=8;

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    vpasexec:=9;

	    dbms_sql.variable_value(v_cursor, 'RETORNO', v_retorno);

	    vpasexec:=10;

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_psu_retroactividad', vpasexec, ' pcempres:'
	                                                                                         || pcempres, SQLCODE
	                                                                                                      || '-'
	                                                                                                      || SQLERRM);

	             RETURN NULL;
	END f_psu_retroactividad;

	/* 0032511: SIN - retencion poliza al cambiar reserva*/
	FUNCTION f_accion_cambio_reserva(
			pcempres	IN	NUMBER,
			pnsinies	IN	VARCHAR2
	) RETURN NUMBER
	IS
	  v_propio  VARCHAR2(50);
	  v_cursor  NUMBER;
	  v_ss      VARCHAR2(10000);
	  v_filas   NUMBER;
	  v_squery  VARCHAR2(10000);
	  v_retorno NUMBER;
	  v_error   NUMBER;
	  vpasexec  NUMBER(8):=1;
	  vobject   VARCHAR2(200):='PAC_SINIESTROS.f_accion_cambio_reserva';
	  vparam    VARCHAR2(1000):='pnsinies = '
	                         || pnsinies;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	BEGIN
	    SELECT pac_parametros.f_parempresa_t(pcempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    vpasexec:=2;

	    v_ss:='BEGIN '
	          || ' :RETORNO := '
	          || v_propio
	          || '.'
	          || 'f_accion_cambio_reserva('
	          || pcempres
	          || ','
	          || pnsinies
	          || ')'
	          || ';'
	          || 'END;';

	    vpasexec:=4;

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    vpasexec:=5;

	    v_cursor:=dbms_sql.open_cursor;

	    vpasexec:=6;

	    dbms_sql.parse(v_cursor, v_ss, dbms_sql.native);

	    vpasexec:=7;

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', v_retorno);

	    vpasexec:=8;

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    vpasexec:=9;

	    dbms_sql.variable_value(v_cursor, 'RETORNO', v_retorno);

	    vpasexec:=10;

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             vpasexec:=11;

	             v_error:=pac_propio.f_acciones_apertura(pnsinies);

	             IF v_error<>0 THEN
	               p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_accion_cambio_reserva', vpasexec, vparam, v_error);
	             END IF;

	             RETURN v_error; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_accion_cambio_reserva', vpasexec, vparam, SQLCODE
	                                                                                                    || '-'
	                                                                                                    || SQLERRM);

	             RETURN NULL;
	END f_accion_cambio_reserva;

	/*Inicio Bug 0031135 20140818   MMS*/
	FUNCTION f_comi_ces(
			pscomrea	IN	NUMBER,
			psseguro	IN	NUMBER,
			pcgarant	IN	NUMBER,
			pcomisi	IN	NUMBER,
			pfefecto	IN	DATE
	) RETURN NUMBER
	IS
	  ss        VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_cempres seguros.cempres%TYPE;
	  retorno   NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	BEGIN
	    BEGIN
	        SELECT cempres
	          INTO v_cempres
	          FROM seguros
	         WHERE sseguro=psseguro;
	    EXCEPTION
	        WHEN OTHERS THEN
	          RETURN 0;
	    END;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'f_comi_ces('
	        || pscomrea
	        || ', '
	        || psseguro
	        || ', '
	        || pcgarant
	        || ', '
	        || pcomisi
	        || ', '
	        || pfefecto
	        || ')'
	        || ';'
	        || 'END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             /*
	                Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
	                a una funci¿n, procedimiento, etc. inexistente o no declarado. En este
	                caso a continaci¿n ejecutamos el c¿digo tradicional para determinar
	                si la p¿liza est¿ o no reducida.
	              */
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN 0;
	END f_comi_ces;

	/*************************************************************************
	   FUNCTION f_imp_cobpar
	    Calcula la parte proporcional de los cobros parciales de los diferentes conceptos
	    param in pnrecibo    : n¿mero de recibo
	    param in pnorden     : n¿mero de orden del cobro parcial
	    param in pcobparc    : importe del cobro parcial
	    param in pimporco    : importe total del concepto
	    param in pimpreci    : importe total del recibo
	*************************************************************************/
	FUNCTION f_imp_cobpar(
			pnrecibo	IN	NUMBER,
			pnorden	IN	NUMBER,
			pcobparc	IN	NUMBER,
			pimporco	IN	NUMBER,
			pimpreci	IN	NUMBER
	) RETURN NUMBER
	IS
	  ss        VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_cempres seguros.cempres%TYPE;
	  retorno   NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	BEGIN
	    BEGIN
	        SELECT cempres
	          INTO v_cempres
	          FROM recibos
	         WHERE nrecibo=pnrecibo;
	    EXCEPTION
	        WHEN OTHERS THEN
	          RETURN 0;
	    END;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'f_imp_cobpar('
	        || pnrecibo
	        || ', '
	        || pnorden
	        || ', '
	        || pcobparc
	        || ', '
	        || pimporco
	        || ', '
	        || pimpreci
	        || ')'
	        || ';'
	        || 'END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             /*
	                Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
	                a una funci¿n, procedimiento, etc. inexistente o no declarado. En este
	                caso a continaci¿n ejecutamos el c¿digo tradicional para determinar
	                si la p¿liza est¿ o no reducida.
	              */
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN 0;
	END f_imp_cobpar;

	/* Funcion para saber si el agente es de tipo corredor (de agentes_comp VF 371 )*/
	FUNCTION f_agentecorredor(
			p_ctipint	IN	NUMBER
	) RETURN NUMBER
	IS
	  ss        VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_cempres seguros.cempres%TYPE;
	  retorno   NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	BEGIN
	    BEGIN
	        SELECT f_parinstalacion_n('EMPRESADEF')
	          INTO v_cempres
	          FROM dual;
	    EXCEPTION
	        WHEN OTHERS THEN
	          RETURN 0;
	    END;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'f_agentecorredor('
	        || p_ctipint
	        || ')'
	        || ';'
	        || 'END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             /*
	                Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
	                a una funci¿n, procedimiento, etc. inexistente o no declarado. En este
	                caso a continaci¿n ejecutamos el c¿digo tradicional para determinar
	                si la p¿liza est¿ o no reducida.
	              */
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN 0;
	END f_agentecorredor;

	/*Fin Bug 0031135 20140818   MMS*/
	/*************************************************************************
	    FUNCTION f_acciones_post_movimientos

	    param in psseguro  : Identificador de seguro.
	    param in psaccion  : 0(No bloqueo) 1(Bloqueo)
	    param in pcmotmov  : movimiento
	       return             : NUMBER (1  / 0)
	*************************************************************************/
	/* Bug 29817 - MSV - 06/11/2014 - Listas Restringidas (Acciones post inserci¿n de movimientos)*/
	FUNCTION f_acciones_post_movimientos(
			psseguro	IN	NUMBER,
			psaccion	IN	NUMBER,
			pcmotmov	IN	NUMBER
	) RETURN NUMBER
	IS
	  ss        VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_cempres seguros.cempres%TYPE;
	  retorno   NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	BEGIN
	    BEGIN
	        SELECT cempres
	          INTO v_cempres
	          FROM seguros
	         WHERE sseguro=psseguro;
	    EXCEPTION
	        WHEN OTHERS THEN
	          RETURN 0;
	    END;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'f_acciones_post_movimientos('
	        || psseguro
	        || ','
	        || psaccion
	        || ','
	        || pcmotmov
	        || ')'
	        || ';'
	        || ' END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             /*
	               Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
	               a una funci¿n, procedimiento, etc. inexistente o no declarado. En este
	               caso a continaci¿n ejecutamos el c¿digo tradicional para determinar
	               si una garant¿a est¿ o no reducida.
	             */
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN 0;
	END f_acciones_post_movimientos;

	/*************************************************************************
	    FUNCTION f_acciones_post_rescate

	    param in psseguro  : Identificador de seguro.
	    param in psaccion  : 0(No bloqueo) 1(Bloqueo)
	       return             : NUMBER (1  / 0)
	*************************************************************************/
	/* Bug 29817 - MSV - 06/11/2014 - Listas Restringidas (Acciones post rescate de polizas)*/
	FUNCTION f_acciones_post_rescate(
			psseguro	IN	NUMBER,
			psaccion	IN	NUMBER
	) RETURN NUMBER
	IS
	  ss        VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_cempres seguros.cempres%TYPE;
	  retorno   NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	BEGIN
	    BEGIN
	        SELECT cempres
	          INTO v_cempres
	          FROM seguros
	         WHERE sseguro=psseguro;
	    EXCEPTION
	        WHEN OTHERS THEN
	          RETURN 0;
	    END;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'f_acciones_post_rescate('
	        || psseguro
	        || ','
	        || psaccion
	        || ')'
	        || ';'
	        || ' END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             /*
	               Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
	               a una funci¿n, procedimiento, etc. inexistente o no declarado. En este
	               caso a continaci¿n ejecutamos el c¿digo tradicional para determinar
	               si una garant¿a est¿ o no reducida.
	             */
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN 0;
	END f_acciones_post_rescate;

	/*************************************************************************
	    FUNCTION f_acciones_post_siniestro

	    param in psseguro  : Identificador de seguro.
	    param in psaccion  : 0(No bloqueo) 1(Bloqueo)
	    param in psccausin : Causa del siniestro
	       return             : NUMBER (1  / 0)
	*************************************************************************/
	/* Bug 29817 - MSV - 06/11/2014 - Listas Restringidas (Acciones post siniestro)*/
	FUNCTION f_acciones_post_siniestro(
			psseguro	IN	NUMBER,
			psaccion	IN	NUMBER,
			psccausin	IN	NUMBER
	) RETURN NUMBER
	IS
	  ss        VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_cempres seguros.cempres%TYPE;
	  retorno   NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	BEGIN
	    BEGIN
	        SELECT cempres
	          INTO v_cempres
	          FROM seguros
	         WHERE sseguro=psseguro;
	    EXCEPTION
	        WHEN OTHERS THEN
	          RETURN 0;
	    END;

	    SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    ss:='BEGIN '
	        || ' :RETORNO := '
	        || v_propio
	        || '.'
	        || 'f_acciones_post_siniestro('
	        || psseguro
	        || ','
	        || psaccion
	        || ','
	        || psccausin
	        || ')'
	        || ';'
	        || ' END;';

	    p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_acciones_post_siniestro', 1, 1, ss);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             /*
	               Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
	               a una funci¿n, procedimiento, etc. inexistente o no declarado. En este
	               caso a continaci¿n ejecutamos el c¿digo tradicional para determinar
	               si una garant¿a est¿ o no reducida.
	             */
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN 0;
	END f_acciones_post_siniestro;

	/*Shadow acounts CMP:20141031*/
	FUNCTION f_usar_shw(
			psseguro	IN	NUMBER,
			pffecmov DATE
	) RETURN NUMBER
	IS
	  vpasexec  NUMBER:=1;
	  v_propio  VARCHAR2(200);
	  v_cursor  NUMBER;
	  v_ss      VARCHAR2(10000);
	  v_retorno NUMBER;
	  v_error   NUMBER:=0;
	  v_filas   NUMBER;
	  vobject   VARCHAR2(200):='PAC_PROPIO.f_usar_shw';
	  vparam    VARCHAR2(1000):='psseguro = '
	                         || psseguro;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	BEGIN
	    SELECT pac_parametros.f_parempresa_t(f_empres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    vpasexec:=2;

	    v_ss:='BEGIN '
	          || ' :RETORNO := '
	          || v_propio
	          || '.'
	          || 'f_usar_shw('
	          || psseguro
	          || ',to_date('''
	          || to_char(pffecmov, 'ddmmyyyy')
	          || ''', ''ddmmyyyy''))'
	          || ';'
	          || 'END;';

	    vpasexec:=4;

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    vpasexec:=5;

	    v_cursor:=dbms_sql.open_cursor;

	    vpasexec:=6;

	    dbms_sql.parse(v_cursor, v_ss, dbms_sql.native);

	    vpasexec:=7;

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', v_retorno);

	    vpasexec:=8;

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    vpasexec:=9;

	    dbms_sql.variable_value(v_cursor, 'RETORNO', v_retorno);

	    vpasexec:=10;

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             RETURN v_error; WHEN OTHERS THEN
	             RETURN -1;
	END f_usar_shw;
	FUNCTION f_reparto_shadow(
			psseguro	IN	NUMBER,
			pfecha	IN	DATE,
			pcesta	IN	NUMBER,
			picaprisc	IN	NUMBER,
			picaprisc_pa	OUT	NUMBER,
			picaprisc_shw	OUT	NUMBER
	) RETURN NUMBER
	IS
	  v_cont    NUMBER;
	  v_ss      VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_retorno NUMBER;
	  ex_nodeclared EXCEPTION;
	  e_param_error EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	/* Se debe declarar el componente*/
	BEGIN
	    picaprisc_pa:=picaprisc;

	    picaprisc_shw:=picaprisc;

	    IF psseguro IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    v_ss:='BEGIN '
	          || ' :RETORNO := '
	          || v_propio
	          || '.'
	          || 'f_reparto_shadow('
	          || psseguro
	          || ',to_date('''
	          || to_char(pfecha, 'ddmmyyyy')
	          || ''',''ddmmyyyy''),'
	          || nvl(to_char(pcesta), 'NULL')
	          || ','
	          || picaprisc
	          || ', :picaprisc_pa, :picaprisc_shw)'
	          || ';'
	          || 'END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, v_ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', v_retorno);

	    dbms_sql.bind_variable(v_cursor, ':picaprisc_pa', picaprisc_pa);

	    dbms_sql.bind_variable(v_cursor, ':picaprisc_shw', picaprisc_shw);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', v_retorno);

	    dbms_sql.variable_value(v_cursor, 'picaprisc_pa', picaprisc_pa);

	    dbms_sql.variable_value(v_cursor, 'picaprisc_shw', picaprisc_shw);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_reparto_shadow', 1, 'PARAMETROS OBLIGATORIOS NO INFORMADOS - '
	                                                                              || '; p_sseguro = '
	                                                                              || psseguro, SQLERRM);

	             RETURN NULL; WHEN ex_nodeclared THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_reparto_shadow', 1, 'EX_NO_DECLARED - '
	                                                                              || '; retorno '
	                                                                              || v_retorno, SQLERRM);

	             /*  Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada*/
	             /*  a una funci¿n, procedimiento, etc. inexistente o no declarado.*/
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN 0; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_reparto_shadow', 1, 'PARAMETROS OBLIGATORIOS NO INFORMADOS - '
	                                                                              || '; p_sseguro = '
	                                                                              || psseguro
	                                                                              || 'pfecha '
	                                                                              || pfecha
	                                                                              || 'pcesta'
	                                                                              || pcesta
	                                                                              || 'picaprisc'
	                                                                              || picaprisc
	                                                                              || 'picaprisc_pa'
	                                                                              || picaprisc_pa
	                                                                              || 'picaprisc_shw'
	                                                                              || picaprisc_shw, SQLERRM);

	             RETURN 140999;
	END f_reparto_shadow;

	/*fin Shadow acounts CMP:20141031*/
	/* ini bug: 35101*/
	FUNCTION f_valida_fiscalidad(
			sperson	IN	NUMBER,
			pnsinies	IN	VARCHAR2
	) RETURN NUMBER
	IS
	  vpasexec  NUMBER:=1;
	  v_cont    NUMBER;
	  v_ss      VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_retorno NUMBER;
	  ex_nodeclared EXCEPTION;
	  e_param_error EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	BEGIN
	    SELECT pac_parametros.f_parempresa_t(f_empres, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    vpasexec:=2;

	    v_ss:='BEGIN '
	          || ' :RETORNO := '
	          || v_propio
	          || '.'
	          || 'f_valida_fiscalidad('
	          || sperson
	          || ','
	          || pnsinies
	          || ');'
	          || 'END;';

	    vpasexec:=4;

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    vpasexec:=5;

	    v_cursor:=dbms_sql.open_cursor;

	    vpasexec:=6;

	    dbms_sql.parse(v_cursor, v_ss, dbms_sql.native);

	    vpasexec:=7;

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', v_retorno);

	    vpasexec:=8;

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    vpasexec:=9;

	    dbms_sql.variable_value(v_cursor, 'RETORNO', v_retorno);

	    vpasexec:=10;

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             RETURN 0; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_valida_fiscalidad', 1, 'PARAMETROS OBLIGATORIOS NO INFORMADOS - ', SQLERRM);

	             RETURN 140999;
	END f_valida_fiscalidad;

	/* fin bug: 35101*/
	FUNCTION f_proy_aho_resc(
			psseguro	IN	NUMBER,
			pnriesgo	IN	NUMBER,
			pnmovimi	IN	NUMBER,
			pfecha	IN	NUMBER,
			piimpsin	IN	NUMBER,
			picapesp	OUT	NUMBER
	) RETURN NUMBER
	IS
	  v_cont    NUMBER;
	  v_ss      VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_retorno NUMBER;
	  ex_nodeclared EXCEPTION;
	  e_param_error EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	/* Se debe declarar el componente*/
	BEGIN
	    IF psseguro IS NULL  OR
	       pnriesgo IS NULL  OR
	       pnmovimi IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    v_ss:='BEGIN '
	          || ' :RETORNO := '
	          || v_propio
	          || '.'
	          || 'f_proy_aho_resc('
	          || psseguro
	          || ','
	          || pnriesgo
	          || ','
	          || pnmovimi
	          || ','
	          || pfecha
	          || ',to_number('''
	          || nvl(piimpsin, 0)
	          || '''), :picapesp)'
	          || ';'
	          || 'END;';

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, v_ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', v_retorno);

	    dbms_sql.bind_variable(v_cursor, ':picapesp', picapesp);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', v_retorno);

	    dbms_sql.variable_value(v_cursor, 'picapesp', picapesp);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_proy_aho_resc', 1, 'PARAMETROS OBLIGATORIOS NO INFORMADOS - '
	                                                                             || '; psseguro = '
	                                                                             || psseguro
	                                                                             || '; pnriesgo = '
	                                                                             || pnriesgo
	                                                                             || '; pnmovimi = '
	                                                                             || pnmovimi, SQLERRM);

	             RETURN NULL; WHEN ex_nodeclared THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_proy_aho_resc', 1, 'EX_NO_DECLARED - '
	                                                                             || '; retorno '
	                                                                             || v_retorno, SQLERRM);

	             /*  Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada*/
	             /*  a una funci¿n, procedimiento, etc. inexistente o no declarado.*/
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN 0; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_proy_aho_resc', 1, 'PARAMETROS OBLIGATORIOS NO INFORMADOS - '
	                                                                             || '; psseguro = '
	                                                                             || psseguro
	                                                                             || 'pfecha='
	                                                                             || pfecha
	                                                                             || ' pnriesgo='
	                                                                             || pnriesgo
	                                                                             || ' pnmovimi='
	                                                                             || pnmovimi
	                                                                             || ' piimpsin='
	                                                                             || piimpsin, SQLERRM);

	             RETURN 140999;
	END f_proy_aho_resc;
	FUNCTION f_genera_archivo_cheque(
			fini DATE,
			ffin DATE,
			p_directorio	IN	VARCHAR2,
			pcregenera	IN	NUMBER
	) RETURN NUMBER
	IS
	  v_cont    NUMBER;
	  v_ss      VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_retorno NUMBER;
	  ex_nodeclared EXCEPTION;
	  e_param_error EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	/* Se debe declarar el componente*/
	BEGIN
	    IF fini IS NULL  OR
	       ffin IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    v_ss:='BEGIN '
	          || ' :RETORNO := '
	          || v_propio
	          || '.'
	          || 'f_genera_archivo_cheque('''
	          || fini
	          || ''','''
	          || ffin
	          || ''','''
	          || p_directorio
	          || ''','''
	          || pcregenera
	          || ''')'
	          || ';'
	          || 'END;';

	    p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_genera_archivo_cheque', 1, v_ss, SQLERRM);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, v_ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', v_retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', v_retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_genera_archivo_cheque', 1, 'PARAMETROS OBLIGATORIOS NO INFORMADOS - '
	                                                                                     || '; fini = '
	                                                                                     || fini
	                                                                                     || 'ffin='
	                                                                                     || ffin, SQLERRM);

	             RETURN NULL; WHEN ex_nodeclared THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_genera_archivo_cheque', 1, 'EX_NO_DECLARED - '
	                                                                                     || '; retorno '
	                                                                                     || v_retorno, SQLERRM);

	             /*  Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada*/
	             /*  a una funci¿n, procedimiento, etc. inexistente o no declarado.*/
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN 0; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_genera_archivo_cheque', 1, 'PARAMETROS OBLIGATORIOS NO INFORMADOS - '
	                                                                                     || '; fini = '
	                                                                                     || fini
	                                                                                     || 'ffin='
	                                                                                     || ffin, SQLERRM);

	             RETURN 140999;
	END f_genera_archivo_cheque;
	FUNCTION f_actualiza_estado_cheque(
			fini DATE,
			ffin DATE
	) RETURN NUMBER
	IS
	  v_cont    NUMBER;
	  v_ss      VARCHAR2(3000);
	  v_cursor  NUMBER;
	  v_filas   NUMBER;
	  v_propio  VARCHAR2(50);
	  v_retorno NUMBER;
	  ex_nodeclared EXCEPTION;
	  e_param_error EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	/* Se debe declarar el componente*/
	BEGIN
	    IF fini IS NULL  OR
	       ffin IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    v_ss:='BEGIN '
	          || ' :RETORNO := '
	          || v_propio
	          || '.'
	          || 'f_actualiza_estado_cheque('''
	          || fini
	          || ''','''
	          || ffin
	          || ''')'
	          || ';'
	          || 'END;';

	    p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_actualiza_estado_cheque', 1, v_ss, SQLERRM);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, v_ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', v_retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', v_retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_actualiza_estado_cheque', 1, 'PARAMETROS OBLIGATORIOS NO INFORMADOS - '
	                                                                                       || '; fini = '
	                                                                                       || fini
	                                                                                       || 'ffin='
	                                                                                       || ffin, SQLERRM);

	             RETURN NULL; WHEN ex_nodeclared THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_actualiza_estado_cheque', 1, 'EX_NO_DECLARED - '
	                                                                                       || '; retorno '
	                                                                                       || v_retorno, SQLERRM);

	             /*  Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada*/
	             /*  a una funci¿n, procedimiento, etc. inexistente o no declarado.*/
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             RETURN 0; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_actualiza_estado_cheque', 1, 'PARAMETROS OBLIGATORIOS NO INFORMADOS - '
	                                                                                       || '; fini = '
	                                                                                       || fini
	                                                                                       || 'ffin='
	                                                                                       || ffin, SQLERRM);

	             RETURN 140999;
	END f_actualiza_estado_cheque;
	FUNCTION f_gen_rec_informe(
			pcmap	IN	VARCHAR2,
			pparams	IN	T_IAX_INFO
	) RETURN NUMBER
	IS
	  v_ss      VARCHAR2(3000);
	  v_propio  VARCHAR2(50);
	  v_retorno NUMBER;
	  ex_nodeclared EXCEPTION;
	  e_param_error EXCEPTION;
	  v_param   VARCHAR2(2000):='PARAMETROS OBLIGATORIOS NO INFORMADOS - '
	                          || ' pcmap = '
	                          || pcmap;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	BEGIN
	    IF pcmap IS NULL  OR
	       pparams IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    v_ss:='BEGIN :v_retorno := '
	          || v_propio
	          || '.f_gen_rec_informe('
	          || ':pcmap, :pparams); END;';

	    EXECUTE IMMEDIATE v_ss
	    USING OUT v_retorno, IN pcmap, IN pparams;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN e_param_error THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_gen_rec_informe', 1, v_param, SQLERRM);

	             RETURN NULL; WHEN ex_nodeclared THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_gen_rec_informe', 1, 'EX_NO_DECLARED - '
	                                                                               || '; retorno '
	                                                                               || v_retorno, SQLERRM);

	             RETURN 0; WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, 'PAC_PROPIO.f_gen_rec_informe', 1, v_param, SQLERRM);

	             RETURN 140999;
	END f_gen_rec_informe;

	/*INI RAL BUG 0038881   */
	FUNCTION f_inireserva_gasto(
			pnsinies	IN	VARCHAR2
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_propio.f_inireserva_gasto';
	  vparam      VARCHAR2(2000):='par¿metros -  pnsinies : '
	                         || pnsinies;
	  vpasexec    NUMBER(5):=1;
	  v_cont      NUMBER;
	  v_ss        VARCHAR2(3000);
	  v_cursor    NUMBER;
	  v_filas     NUMBER;
	  v_propio    VARCHAR2(50);
	  v_retorno   NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	BEGIN
	    IF pnsinies IS NULL THEN
	      RETURN 0;
	    END IF;

	    SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    p_tab_error(f_sysdate, f_user, 'PAC_siniestros', 1, 'DENTRO DE PROPIO PARA LLAMAR', 'debug');

	    SELECT 'BEGIN '
	           || ' :RETORNO := '
	           || 'PAC_PROPIO_RSA'
	           || '.'
	           || 'f_inireserva_gasto('''
	           || pnsinies
	           || '''); END;'
	      INTO v_ss
	      FROM dual;

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, v_ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', v_retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', v_retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             RETURN 0;
	END f_inireserva_gasto;
	/*FIN BUG 0038881*/
	FUNCTION f_accion_siniestro(
			paccion	IN	NUMBER,
			pnsinies sin_siniestro.nsinies%TYPE,
			pctipsin sin_causa_motivo.ctipsin%TYPE,
			pccausin sin_siniestro.ccausin%TYPE,
			psseguro sin_siniestro.sseguro%TYPE,
			pnriesgo sin_siniestro.nriesgo%TYPE,
			pfsinies sin_siniestro.fsinies%TYPE
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_propio.f_accion_siniestro';
	  vparam      VARCHAR2(2000):='par¿metros -  pnsinies : '
	                         || pnsinies;
	  v_ss        VARCHAR2(3000);
	  v_cursor    NUMBER;
	  v_filas     NUMBER;
	  v_propio    VARCHAR2(50);
	  v_retorno   NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	BEGIN
	    /**/
	    SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    /**/
	    SELECT 'BEGIN '
	           || ' :RETORNO := '
	           || v_propio
	           || '.'
	           || 'f_accion_siniestro('
	           || paccion
	           || ','
	           || pnsinies
	           || ','
	           || pctipsin
	           || ','
	           || pccausin
	           || ','
	           || psseguro
	           || ','
	           || pnriesgo
	           || ','''
	           || pfsinies
	           || '''); END;'
	      INTO v_ss
	      FROM dual;

	    /**/
	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, v_ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', v_retorno);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', v_retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             /**/
	             RETURN 0;
	END f_accion_siniestro;
	FUNCTION f_ustrid_sepa_transf(
			pcatribu	IN	NUMBER,
			pidentifica	IN	NUMBER
	) RETURN VARCHAR2
	IS
	  vobjectname VARCHAR2(500):='pac_propio.f_ustrid_sepa_transf';
	  vparam      VARCHAR2(2000):='par¿metros -  pcatribu : '
	                         || pcatribu
	                         || ' - pidentifica : '
	                         || pidentifica;
	  v_ss        VARCHAR2(3000);
	  v_cursor    NUMBER;
	  v_filas     NUMBER;
	  v_propio    VARCHAR2(50);
	  v_retorno   VARCHAR2(4000);
	  v_retcur    NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	BEGIN
	    /**/
	    SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    /**/
	    SELECT 'BEGIN '
	           || ' :RETORNO := '
	           || v_propio
	           || '.'
	           || 'f_ustrid_sepa_transf('
	           || pcatribu
	           || ','
	           || pidentifica
	           || '); END;'
	      INTO v_ss
	      FROM dual;

	    /**/
	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, v_ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', v_retorno, 4000);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', v_retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             /**/
	             RETURN 0;
	END f_ustrid_sepa_transf;

  FUNCTION f_accion_post_rechazo(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pnsuplem IN NUMBER,
      paccion NUMBER,
      pnmovimi IN NUMBER DEFAULT NULL,
      pnorec IN NUMBER DEFAULT 0
  )   RETURN NUMBER IS
	  vobjectname VARCHAR2(500):='pac_propio.f_accion_post_rechazo';
	  vparam      VARCHAR2(2000):='par¿metros -  psseguro : '
	                         || psseguro
	                         || ' - pcmotmov : '
	                         || pcmotmov
	                         || ' - pnsuplem : '
	                         || pnsuplem
	                         || ' - paccion : '
	                         || paccion
	                         || ' - pnmovimi : '
	                         || pnmovimi
	                         || ' - pnorec : '
	                         || pnorec;
	  v_ss        VARCHAR2(3000);
	  v_cursor    NUMBER;
	  v_filas     NUMBER;
	  v_propio    VARCHAR2(50);
	  v_retorno   VARCHAR2(4000);
	  v_retcur    NUMBER;
	  ex_nodeclared EXCEPTION;
	  PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	BEGIN
	    /**/
	    SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    /**/
	    SELECT 'BEGIN '
	           || ' :RETORNO := '
	           || v_propio
	           || '.'
	           || 'f_accion_post_rechazo('
	           || psseguro
	           || ','
	           || pcmotmov
	           || ','
	           || pnsuplem
	           || ','
	           || paccion
	           || ','
	           || pnmovimi
	           || ','
	           || pnorec
	           || '); END;'
	      INTO v_ss
	      FROM dual;

	    /**/
	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    v_cursor:=dbms_sql.open_cursor;

	    dbms_sql.parse(v_cursor, v_ss, dbms_sql.native);

	    dbms_sql.bind_variable(v_cursor, ':RETORNO', v_retorno, 4000);

	    v_filas:=dbms_sql.EXECUTE(v_cursor);

	    dbms_sql.variable_value(v_cursor, 'RETORNO', v_retorno);

	    IF dbms_sql.is_open(v_cursor) THEN
	      dbms_sql.close_cursor(v_cursor);
	    END IF;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
	             IF dbms_sql.is_open(v_cursor) THEN
	               dbms_sql.close_cursor(v_cursor);
	             END IF;

	             /**/
	             RETURN 0;
  END f_accion_post_rechazo;

  FUNCTION f_desc_movres (
     pnsinies IN sin_tramita_reserva.nsinies%TYPE,
     pntramit IN sin_tramita_reserva.ntramit%TYPE,
     pctipres IN sin_tramita_reserva.ctipres%TYPE,
     pnmovres IN sin_tramita_reserva.nmovres%TYPE,
     pcmovres IN sin_tramita_reserva.cmovres%TYPE,
     pcsolidaridad IN sin_tramita_reserva.csolidaridad%TYPE DEFAULT NULL,
     pcidioma IN	NUMBER )
     RETURN VARCHAR2 IS
     v_obj     VARCHAR2(200):='PAC_PROPIO.f_desc_movres';
	   v_par     VARCHAR2(200):='pnsinies = '|| pnsinies || ' pntramit: ' || pntramit || ' pctipres: ' || pctipres
                              || ' pnmovres: ' || pnmovres || ' pcmovres: ' || pcmovres || ' pcsolidaridad: ' || pcsolidaridad || ' pcidioma: ' || pcidioma;
	   v_pas     NUMBER(4):=0;
     v_propio  VARCHAR2(50);
     v_ss      VARCHAR2(3000);
     v_retorno VARCHAR2(500);
     ex_nodeclared EXCEPTION;
     PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
	BEGIN
	    v_pas:=10;

	    SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa(), 'PAC_PROPIO')
	      INTO v_propio
	      FROM dual;

	    v_pas:=30;

	    v_ss:='BEGIN '
	          || ' :v_retorno := '
	          || v_propio
	          || '.'
	          || 'f_desc_movres('
	          || pnsinies || ','
            || pntramit || ','
            || pctipres || ','
            || pnmovres || ','
            || pcmovres || ','
            || NVL(pcsolidaridad,1) || ','
            || pcidioma
	          || ')'
	          || ';'
	          || 'END;';

	    v_pas:=40;

	    EXECUTE IMMEDIATE v_ss
	    USING OUT v_retorno;

	    RETURN v_retorno;
	EXCEPTION
	  WHEN ex_nodeclared THEN
      v_pas:=50;

      BEGIN
        SELECT c.tmovres
          INTO v_retorno
          FROM sin_desmovres c
         WHERE c.cmovres = pcmovres
           AND c.cidioma = pcidioma;
        --
        RETURN v_retorno;
      EXCEPTION
         WHEN OTHERS THEN
           p_tab_error(f_sysdate, f_user, v_obj, v_pas, v_par, SQLCODE
                                                               || '-'
                                                               || SQLERRM);

           RETURN NULL;
      END;
   END f_desc_movres;

END pac_propio;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROPIO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO" TO "PROGRAMADORESCSI";
