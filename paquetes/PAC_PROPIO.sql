--------------------------------------------------------
--  DDL for Package PAC_PROPIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PROPIO" IS



	-- 16/9/2004 YIL, EAS, CPM
	--
	--   Package que contiene las funciones propias de cada instalaci¿n.
	--   Esto permite tener funciones comunes que podr¿n ser compartidas
	--   por todas las intalaciones.
	--   Este package no se compartir¿ y ser¿ diferente para cada instalaci¿n.
	--
	--  El objetivo final seria que no existieran funciones en este package, pues
	--  su c¿digo estuviera montado en un codigo MAP.
	--
	/******************************************************************************
	   NOMBRE:     PAC_PROPIO
	   PROP¿SITO:  Package que contiene las funciones propias de cada instalaci¿n.

	   REVISIONES:
	   Ver        Fecha        Autor             Descripci¿n
	   ---------  ----------  ---------------  ------------------------------------
	   2.0        03/03/2009   DRA                2. BUG0009297: IAX - Gesti¿ de propostes - Revisi¿ punts pendents
	   3.0        21/04/2009   YIL                3. Bug 9794 - Se crea la funci¿n f_restar_limite_anual
	   4.0        01/05/2009   JRH                7. Bug 0009172: CRE055 - Rentas regulares e irregulares con c¿lculos a partir de renta
	   5.0        30/09/2009   AMC                8. Bug 11284 - N¿ DE CONTRATO FORMATO CEM. Se crea la funci¿n f_calc_contrato_interno
	   6.0        09/10/2009   FAL                9. Bug 11424: CEM - N¿ de referencia cuestionario de salud. Se crea la funci¿n f_get_id_cuestsalud
	   7.0        01/12/2009   AMC                10 bug 11308.Se a¿ade la funci¿n f_extrae_npoliza
	   8.0        10/03/2010   RSC                11. 13515: APR - Error en el calculo de comisiones
	   9.0        23/03/2010   ICV                12. 0013781: CEM - Modificaci¿n fichero de transferencias
	  10.0        27/04/2010   AVT                13. 13946: CEM800 - Renovaci¿ de Cartera del producte ESCUT BASIC
	  11.0        16/04/2010   RSC                14. 0014160: CEM800 - Adaptar packages de productos de inversi¿n al nuevo m¿dulo de siniestros
	  12.0        10/06/2010   RSC                15. 0013832: APRS015 - suplemento de aportaciones ¿nicas
	  13.0        13/09/2010   ETM                13. 0015884: CEM - Fe de Vida. Nueva funci¿n que devolver¿ un REF CURSOR con las p¿lizas que deben enviar la carta de fe de vida.
	  14.0        04/11/2010   APD                14. 0016095: Implementacion y parametrizacion del producto GROUPLIFE
	  15.0        15/12/2010   JMP                15. 0017008: GRC - A¿adimos la funci¿n F_CONTADOR2
	  16.0        30/06/2010   RSC                16.0 0015057: field capital by provisions SRD
	  17.0        24/01/2010   JMP                17. 0017341: APR703 - Suplemento de preguntas - FlexiLife
	  18.0        10/02/2011   APD                18. 0017567: GRC003 - Funci¿n para n¿mero propio de siniestro
	  19.0        28/02/2011   AMC                19. 17806: CRT003 - Traspaso de gen¿rico a especifico
	  20.0        05/04/2011   SRA                20. 0017922: AGM701 - Consulta p¿lizas. Modificaci¿n de las fuciones de DDBB para que incluyan las p¿lizas externas.
	  21.0        30/08/2011   JMF                21. 0019332: LCOL001 -numeraci¿n de p¿lizas y de solicitudes
	  22.0        17/11/2011   ANS                22. 0019416: LCOL_S001-Siniestros y exoneraci¿n de pago de primas
	  23.0        24/11/2011   JMC                23. 0020254: LCOL_S001-SIN - Rentas de siniestros
	  24.0        23/03/2012   RSC                24. 0021863: LCOL - Incidencias Reservas
	  25.0        06/09/2012   MDS                25. 0023254: LCOL - qtrackers 4806 / 4808. M¿xim dels prestecs.
	  26.0        25/09/2012   AVT                26. 0023644: LCOL_A002-Qtracker: 0004565: Cesion de Siniestro no descuenta reserva matematica
	  27.0        17/12/2012   JMF                0025087 MDP_T001-Ajustes de PSU R2
	  28.0        02/01/2013   APD                0023940: LCOL_T010-LCOL - Certificado 0 renovable - Renovaci?n colectivos
	  29.0        14/01/2013   ECP                29. 0023644: LCOL_A002-Qtracker: 0004565: Cesion de Siniestro no descuenta reserva matematica
	  30.0        26/04/2013   NSS                30. 0026472: LCOL_S001-SIN - Param. Acciones Vida Grupo (Id=6857-6861-6868-6871)
	  31.0        13/05/2013   APD                31. 0026898: LCOL_T031-Fase 3 - Id 18 - Polizas proximas a renovar
	  32.0        14/05/2013   ECP                32. 0026676: LCOL_T001- QT 7040: Error cierre de provisiones por c?digo de transacci?n en movimiento de anulaciones errado. Nota 144248
	  33.0        28/05/2013   NSS                33. 0026962: LCOL_S010-SIN - Autos - Acciones iniciar/terminar siniestro
	  34.0        02/09/2013   FAL                34. 0025720: RSAG998 - Numeraci¿n de p¿lizas por rangos
	  35.0        14/01/2014   JDS                35. 0029659: LCOL_T031-Migraci¿n autos
	  36.0        24/02/2014   NSS                36. 0029224: (POSAN500)-Analisis-Siniestros-Nuevos Desarrollos
	  37.0        15/07/2014   AFM                37. 0032058: GAP. Prima de Riesgo, gastos y comisiones prepagables
	  38.0        15/10/2015   BLA                38  0033515/215632 MSV se  adicionan parametros pnnumvia, potros a la f_valdireccion
	  39.0        16/10/2015   JCP                39. 0033886: Creacion funcion f_genera_archivo_cheque
	  40.0        27/10/2014   YDA                40. 0033886: Creaci¿n de la funci¿n f_gen_rec_informe
	 ******************************************************************************/
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
	)   RETURN NUMBER;

	FUNCTION f_graba_rec_comision(
			 pmodo	IN	VARCHAR2,
			 pfecha	IN	DATE,
			 pcagrpro	IN	NUMBER,
			 psproduc	IN	NUMBER,
			 psseguro	IN	NUMBER,
			 pfefecto	IN	DATE DEFAULT NULL,
			 pfcaranu	IN	DATE DEFAULT NULL
	)   RETURN NUMBER;

	FUNCTION f_provmat(
			psesion	IN	NUMBER,
			 psseguro NUMBER,
			 pfecha NUMBER,
			 pmodo	IN	NUMBER
	)   RETURN NUMBER;

	FUNCTION f_irescate(
			psseguro	IN	NUMBER,
			 pfecha	IN	DATE,
			 psituac	IN	NUMBER DEFAULT 1
	)   RETURN NUMBER;

	FUNCTION f_irendimiento(
			psseguro	IN	NUMBER,
			 pfecha	IN	DATE
	)   RETURN NUMBER;

	FUNCTION f_permite_alta_siniestro(
			 psseguro	IN	NUMBER,
			 pnriesgo	IN	NUMBER,
			 pfsinies	IN	DATE,
			 pfnotifi	IN	DATE
	)   RETURN NUMBER;

	FUNCTION f_post_anulacion(
			psseguro	IN	NUMBER,
			 pfanulac	IN	DATE,
			 pnmovimi	IN	NUMBER
	)   RETURN NUMBER;

	FUNCTION f_texto_libre_siniestros(
			pnsinies	IN	NUMBER,
			 pnlitera	OUT	NUMBER
	)   RETURN NUMBER;

	FUNCTION f_cambio_sobreprima(
			psseguro	IN	NUMBER,
			 pnmovimi	IN	NUMBER,
			 pnriesgo	IN	NUMBER
	)   RETURN NUMBER;

	  --gneracion del fichero de transferencias, de una remesa espec¿fica
	FUNCTION f_generar_fichero(
			pnremesa	IN	NUMBER
	)   RETURN NUMBER;

	FUNCTION f_retener(
			 ptablas	IN	VARCHAR2,
			 psseguro	IN	NUMBER,
			 pnriesgo	IN	NUMBER,
			 pnmovimi	IN	NUMBER,
			 pfecha	IN	DATE
	)   RETURN NUMBER;

	PROCEDURE f_renova_cesiones_pu(
			 psproces	IN	NUMBER,
			 pmes	IN	NUMBER,
			 panyo	IN	NUMBER,
			 pramo	IN	NUMBER,
			 pmodali	IN	NUMBER,
			 ptipseg	IN	NUMBER,
			 pcolect	IN	NUMBER,
			 psseguro	IN	NUMBER DEFAULT NULL
	);


	FUNCTION ff_capital_pu(
			psseguro	IN	NUMBER,
			 pfecha	IN	DATE
	)   RETURN NUMBER;

	FUNCTION f_aceptar_propuesta(
			 psseguro	IN	NUMBER,
			 pnmovimi	IN	NUMBER,
			 pnriesgo	IN	NUMBER,
			 pfecha	IN	DATE DEFAULT NULL,
			 ptobserv	IN	VARCHAR2 DEFAULT NULL
	)   RETURN NUMBER;

	FUNCTION f_rechazar_propuesta(
			 psseguro	IN	NUMBER,
			 pnmovimi	IN	NUMBER,
			 pnriesgo	IN	NUMBER,
			 pcmotmov	IN	NUMBER,
			 pnsuplem	IN	NUMBER,
			 ptobserv	IN	VARCHAR2
	)   RETURN NUMBER;

	FUNCTION f_cambio_fcancel(
			psseguro	IN	NUMBER,
			 pnmovimi	IN	NUMBER,
			 pfcancel_nou	IN	DATE
	)   RETURN NUMBER;

	FUNCTION f_cambio_clausulas(
			psseguro	IN	NUMBER,
			 pnmovimi	IN	NUMBER,
			 pnriesgo	IN	NUMBER
	)   RETURN NUMBER;

	FUNCTION f_permite_alta_siniestro(
			 psseguro	IN	NUMBER,
			 pnriesgo	IN	NUMBER,
			 pfsinies	IN	DATE,
			 pfnotifi	IN	DATE,
			 pccausin	IN	NUMBER,
			 pcmotsin	IN	NUMBER,
			 -- Ini Bug 26676 -- ECP -- 14/05/2013
			 pskipfanulac NUMBER DEFAULT 0
			 -- Fin Bug 26676 -- ECP -- 14/05/2013

	)
	  RETURN NUMBER;

	FUNCTION f_valida_estriesgo_producto(
			 psseguro	IN	NUMBER,
			 psproduc	IN	NUMBER,
			 psperson	IN	NUMBER
	)   RETURN NUMBER;

	FUNCTION f_validar_edad_prod(
			pssolicit	IN	NUMBER,
			 psproduc	IN	NUMBER,
			 pfnacimi	IN	DATE
	)   RETURN NUMBER;

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
	)   RETURN NUMBER;

	PROCEDURE p_predomiciliacion(
			 psproces	IN	NUMBER,
			 pcempres	IN	NUMBER,
			 pcidioma	IN	NUMBER,
			 pcramo	IN	NUMBER,
			 pcmodali	IN	NUMBER,
			 pctipseg	IN	NUMBER,
			 pccolect	IN	NUMBER
	);


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
	)   RETURN NUMBER;

	FUNCTION f_anulacion_reemplazo(
			 psseguro	IN	NUMBER,
			 psreempl	IN	NUMBER,
			 pcagente	IN	NUMBER DEFAULT NULL
	)   RETURN NUMBER;

	  --JRH Tarea 6966
	FUNCTION f_ivencimiento(
			psseguro	IN	NUMBER,
			 pfecha	IN	DATE
	)   RETURN NUMBER;

	  -- APD Bug 7734
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
	)   RETURN NUMBER;

	  -- YIL. BUG 9794
	FUNCTION f_restar_limite_anual(
			 ptablas	IN	VARCHAR2,
			 psseguro	IN	NUMBER,
			 pcgarant	IN	NUMBER,
			 plimite	IN	NUMBER,
			 pfecha	IN	DATE,
			 imp_restar	OUT	NUMBER,
			 pforfait	IN	NUMBER DEFAULT 1
	)   RETURN NUMBER;

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
	  -- Bug 0009172 - JRH - 01/05/2009 - Nueva Funci¿n : Bug 0009172: CRE055 - Rentas regulares e irregulares con c¿lculos a partir de renta
	FUNCTION f_inscta_prov_cap_det(
			 psseguro	IN	NUMBER,
			 pfecha	IN	DATE,
			 pfechacontable	IN	DATE,
			 pnumlinea	IN	NUMBER,
			 pmodo	IN	VARCHAR2,
			 ppsproces	IN	NUMBER,
			 pffecmov	IN	DATE DEFAULT NULL
	)   RETURN NUMBER;

	  -- Bug 10101 - 01/06/2009 - RSC - Detalle de garant¿as (Consulta de p¿lizas)
	FUNCTION f_esta_reducida(
			psseguro	IN	NUMBER
	)   RETURN NUMBER;

	  -- Fin Bug 10101
	  /*************************************************************************
	FUNCTION f_validaposttarif
	Validaciones despues de tarifar
	Param IN psproduc: producto
	Param IN psseguro: sseguro
	Param IN pnriesgo: nriesgo
	Param IN pfefecto: Fecha
	return : 0 Si todo ha ido bien, si no el c¿digo de error
	*************************************************************************/
	  -- Bug 11771 - 04/11/2009 - RSC - CRE - Ajustes en simulaci¿n y contrataci¿n PPJ Din¿mico/Pla Estudiant
	FUNCTION f_validaposttarif(
			 psproduc	IN	NUMBER,
			 psseguro	IN	NUMBER,
			 pnriesgo	IN	NUMBER,
			 pfefecto	IN	DATE
	)   RETURN NUMBER;

	  --BUG 10231 - 27/05/2009 - ETM -L¿mite de aportaciones en productos fiscales --FIN
	  /*************************************************************************
	FUNCTION f_esta_reducida
	Indica si una garant¿a esta o no reducida para un contrato. Estar¿ reducida
	si todos los detalles de garant¿a tienen prima = 0.
	param in psseguro  : Identificador de seguro.
	return             : NUMBER (1 --> Reducida / 0 --> No reducida)
	*************************************************************************/
	  -- Bug 10350 - 20/07/2009 - RSC - Detalle de garant¿as (Tarificaci¿n)
	  -- Bug 11232 - 23/10/2009 - RSC - 11232: APR - estado de las garantias ya pagadas (a¿adimos ptablas)
	FUNCTION f_garan_reducida(
			 psseguro	IN	NUMBER,
			 pcgarant	IN	NUMBER,
			 pndetgar	IN	NUMBER DEFAULT NULL,
			 ptablas	IN	VARCHAR2 DEFAULT NULL
	)   RETURN NUMBER;

	  -- Fin Bug 10350
	  -- Fin Bug 11232
	  --BUG 10231 - 27/05/2009 - ETM -L¿mite de aportaciones en productos fiscales --FIN
	  --BUG 9658 - JTS - 29/05/2009 - 9658: APR - Desarrollo PL de comisiones de adquisi¿n
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
			 -- Bug 13515 - RSC - 10/03/2010 - APR - Error en el calculo de comisiones
			 p_fvencim_det	IN	DATE,
			 -- Bug 13515 - RSC - 10/03/2010 - APR - Error en el calculo de comisiones
			 p_comisi	OUT	NUMBER
	)
	  RETURN NUMBER;

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
	)   RETURN NUMBER;

	  --Fi BUG 9658 - JTS - 29/05/2009 - 9658: APR - Desarrollo PL de comisiones de adquisi¿n
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
	)   RETURN VARCHAR2;

	  --Fi BUG 11284 - AMC - 30/09/2009
	  --Bug 11424 - 09/10/2009 - FAL - N¿ de referencia cuestionario de salud
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
	)   RETURN VARCHAR2;

	  --Fi BUG 11424 - FAL - 09/10/2009
	  -- Bug 11308 - 01/12/2009 - AMC
	  /*************************************************************************
	FUNCTION f_extrae_npoliza
	Extrae el n¿ de poliza del c¿digo de cuenta interno de CEM
	param in pncontinter  : C¿digo de cuenta interno de CEM
	param in pcempres     : Codigo de la empresa
	return             : N¿ poliza
	*************************************************************************/
	FUNCTION f_extrae_npoliza(
			pncontinter	IN	VARCHAR2,
			 pcempres NUMBER
	)   RETURN NUMBER;

	  --Fi Bug 11308 - 01/12/2009 - AMC

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
			PCEMPRES IN NUMBER)
      RETURN NUMBER;
--Fi CONF-219 AP

	  --Ini Bug.: 0013781 - ICV - 23/03/2010
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
	)   RETURN VARCHAR2;

	  --Fin Bug 13781
	  -- Ini bug: 0013946 AVT 27-04-2010
	  /******************************************************************************
	NOMBRE:       f_fecha_anyo_renova
	PROP¿SITO:    Devuelve una fecha partir del a¿o y la renovaci¿n
	******************************************************************************/
	FUNCTION f_fecha_renova(
			wanyo	IN	NUMBER,
			 wnrenova	IN	NUMBER
	)   RETURN DATE;

	  -- fi bug: 0013946
	  /*************************************************************************
	C¿lculo de valoraci¿n de reserva en siniestros de muerte (garant¿s de riesgo)
	param in psseguro          : Sseguro
	param in pfecha          : Fecha de rescate
	param in pcgarant          : Identificador de garant¿a
	return                     : N¿mero de a¿o dentro de periodo de revisi¿n /
	hasta periodo de revisi¿n.
	*************************************************************************/
	  -- Bug 14160 - RSC - 16/04/2010 - CEM800 - Adaptar packages de productos de inversi¿n al nuevo m¿dulo de siniestros
	FUNCTION f_irescate_finv(
			psseguro	IN	NUMBER,
			 pfecha	IN	DATE,
			 pcgarant	IN	NUMBER
	)   RETURN NUMBER;

	  -- Fin Bug 14160
	  /*************************************************************************
	Determina si debe o no debe grabar objeto de tarificaci¿n
	param in pcmotmov
	param in out mensajes  : mensajes de error
	return                 : 0 todo correcto
	1 ha habido un error
	*************************************************************************/
	  -- Bug 13832 - RSC - 10/06/2010 -  APRS015 - suplemento de aportaciones ¿nicas
	FUNCTION f_bloqueo_grabarobjectodb(
			psseguro	IN	NUMBER,
			 pcmotmov	IN	NUMBER
	)   RETURN NUMBER;

	  /*************************************************************************
	FUNCTION f_prima_cero
	Indica si una p¿liza esta o no reducida. (prima cero)
	param in psseguro  : Identificador de seguro.
	return             : NUMBER (1 --> prima cero / 0 --> No prima cero)
	*************************************************************************/
	  -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones ¿nicas
	FUNCTION f_prima_cero(
			 psseguro	IN	NUMBER,
			 pcgarant	IN	NUMBER,
			 pndetgar	IN	NUMBER DEFAULT NULL,
			 ptablas	IN	VARCHAR2 DEFAULT NULL
	)   RETURN NUMBER;

	  -- INI--Bug 15884 - ETM - 13/09/2010 - CEM - Fe de Vida.
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
	9.   pngenerar. Identificador de generaci¿n de cartas. 0.-Se generan las cartas por primera vez;

1.-Se vuelve a reimprimir el listado (map). Obligatorio (valor por defecto 0)
	10.  pnpantalla. Identificador de visualizaci¿n o no del resultado de la select por pantalla. 0.-No se visualiza el resultado de la select por pantalla (el resultado de la select se utiliza en el map);

1.-S¿ se visualiza el resultado de la select por pantalla. Obligatorio (valor por defecto 0)
	**********************************************************************/
	  -- BUG 21546_108727- 23/02/2012 - JLTS - Se elimina el env¿o de mensajes
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
	)   RETURN SYS_REFCURSOR;

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
	9.   pngenerar. Identificador de generaci¿n de cartas. 0.-Se generan las cartas por primera vez;

1.-Se vuelve a reimprimir el listado (map). Obligatorio (valor por defecto 0)
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
	)   RETURN SYS_REFCURSOR;

	  --FIN -Bug 15884 - ETM - 13/09/2010 - CEM - Fe de Vida.
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
	  -- Bug 16095 - APD - 04/11/2010
	  -- se crea la funcion f_permite_edad_rescate
	FUNCTION f_permite_edad_rescate(
			 psseguro	IN	NUMBER,
			 pnriesgo	IN	NUMBER,
			 pfsinies	IN	DATE,
			 pccausin	IN	NUMBER,
			 ptablas	IN	VARCHAR2 DEFAULT NULL
	)   RETURN NUMBER;

	  -- Fin Bug 16095 - APD - 04/11/2010
	  /**********************************************************************
	FUNCTION F_VALIDAGARANTIA
	Validaciones garantias
	Param IN psseguro: sseguro
	Param IN pnriesgo: nriesgo
	Param IN pcgarant: cgarant
	**********************************************************************/
	  --BUG 16106 - 05/11/2010 - JTS
	FUNCTION f_validagarantia(
			 psseguro	IN	NUMBER,
			 pnmovimi	IN	NUMBER,
			 pnriesgo	IN	NUMBER,
			 pcgarant	IN	NUMBER
	)   RETURN NUMBER;

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
	***********************************************************************/
	  -- BUG 17008 - 15/12/2010 - JMP - Se a¿ade la funci¿n
	FUNCTION f_contador2(
			 p_cempres	IN	NUMBER,
			 p_tipo	IN	VARCHAR2,
			 p_caux	IN	NUMBER,
			 p_exp	IN	NUMBER DEFAULT 6
	)   RETURN NUMBER;

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
	  -- Bug 15057 - RSC - 30/06/2010 - field capital by provisions SRD
	FUNCTION f_cuadro_amortizacion(
			 psseguro	IN	NUMBER,
			 pfefecto	IN	DATE,
			 pfvencim	IN	DATE,
			 pfecha	IN	DATE,
			 pcgarant	IN	NUMBER,
			 picapital	IN	NUMBER,
			 pmodo	IN	NUMBER
	)   RETURN NUMBER;

	  /*************************************************************************
	FUNCTION f_grabargar_modifdb
	Determina si debe o no debe grabar el objeto garant¿as a BDD para el
	motivo de movimiento indicado.
	param in psseguro      : c¿digo del seguro
	param in pcmotmov      : motivo de movimiento
	return                 : 0 no grabar el objeto
	1 grabar el objeto
	*************************************************************************/
	  -- Bug 17341 - 24/01/2011 - JMP - Se crea la funci¿n
	FUNCTION f_grabargar_modifdb(
			psseguro	IN	NUMBER,
			 pcmotmov	IN	NUMBER
	)   RETURN NUMBER;

	  /*************************************************************************
	FUNCTION f_calc_siniestro_interno
	Calcula el n¿mero de siniestro interno de GRC
	param in p_cagente  : Identificador del agente
	param in p_nsinies  : Identificador de siniestro
	return              : N¿mero de siniestro formato GRC
	*************************************************************************/
	  -- BUG 17567 - 10/02/2011 - APD - Se a¿ade la funci¿n
	FUNCTION f_calc_siniestro_interno(
			pcagente	IN	NUMBER,
			 pnsinies	IN	NUMBER
	)   RETURN VARCHAR2;

	  -- Fin BUG 17567 - 10/02/2011 - APD
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
	)   RETURN VARCHAR2;

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
	)   RETURN VARCHAR2;

	  /*************************************************************************
	FUNCTION f_get_lineapoliza
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
	)   RETURN VARCHAR2;

	  /***********************************************************************
	FUNCTION f_numero_solici,
	Devuelve un nuevo solicitud.
	param in p_cempres: c¿digo de la empresa
	param in p_cramo: c¿digo de ramo
	return:         nuevo n¿mero de secuencia
	***********************************************************************/
	  -- BUG 0019332 - 30/08/2011 - JMF
	FUNCTION f_numero_solici(
			p_cempres	IN	NUMBER,
			 p_cramo	IN	NUMBER
	)   RETURN NUMBER;

	  /***********************************************************************
	FUNCTION f_esta_en_exoneracion
	Mira si una poliza tiene un siniestro de exoneracion de primas
	param in psseguro      : Clave de Seguros
	return                 : Number 0=no 1=si
	***********************************************************************/
	  -- Bug 0019416:ASN:08/11/2011
	FUNCTION f_esta_en_exoneracion(
			p_sseguro	IN	seguros.sseguro%TYPE
	)   RETURN NUMBER;

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
	)   RETURN NUMBER;

	FUNCTION f_irescate_rie(
			psseguro	IN	NUMBER,
			 pfecha	IN	DATE,
			 pcgarant	IN	NUMBER DEFAULT NULL
	)   RETURN NUMBER;

	  --Ini Bug: 20254 - 24/11/2011 - JMC
	  /*************************************************************************
	FUNCTION f_pago_renta_aut
	Crea un pago de renta autom¿tico
	param in pmes    : mes de la reserva
	param in panyo   : a¿o de la reserva
	param out psproces : Num. proceso
	return           : c¿digo de error
	Bug 0014347 - 07/06/2010 - FAL
	*************************************************************************/
	FUNCTION f_pago_renta_aut(
			 pmes	IN	NUMBER,
			 panyo	IN	NUMBER,
			 pcgarant	IN	NUMBER,
			 pncobros	OUT	NUMBER,
			 pwhere	IN	VARCHAR2 DEFAULT NULL,
			 pcempres	IN	NUMBER DEFAULT NULL,
			 psproces	IN	OUT NUMBER
	)   RETURN NUMBER;

	  --Fin Bug: 20254 - 24/11/2011 - JMC
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
	)   RETURN NUMBER;

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
			 --Mantis 33515/215632 - BLA - DD15/MM10/2015.
			 potros	IN	VARCHAR2 DEFAULT NULL --Mantis 33515/215632 - BLA - DD15/MM10/2015.

	)
	  RETURN NUMBER;

	  /***********************************************************************
	FUNCTION f_tdomici
	Bug 21703/110272 - 15/03/2012 - AMC
	***********************************************************************/
	FUNCTION f_tdomici(
			 pcsiglas	IN	per_direcciones.csiglas%TYPE,
			 ptnomvia	IN	per_direcciones.tnomvia%TYPE,
			 pnnumvia	IN	per_direcciones.nnumvia%TYPE,
			 ptcomple	IN	per_direcciones.tcomple%TYPE,
			 -- Bug 18940/92686 - 27/09/2011 - AMC
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
			 -- Fi Bug 18940/92686 - 27/09/2011 - AMC
			 plocalidad	IN	per_direcciones.localidad%TYPE DEFAULT NULL -- Bug 24780/130907 - 05/12/2012 - AMC

	)
	  RETURN VARCHAR2;

	  /***********************************************************************
	FUNCTION f_tdomici_aux
	Bug 21703/110272 - 15/03/2012 - AMC
	***********************************************************************/
	FUNCTION f_tdomici_aux(
			 pcsiglas	IN	per_direcciones.csiglas%TYPE,
			 ptnomvia	IN	per_direcciones.tnomvia%TYPE,
			 pnnumvia	IN	per_direcciones.nnumvia%TYPE,
			 ptcomple	IN	per_direcciones.tcomple%TYPE,
			 -- Bug 18940/92686 - 27/09/2011 - AMC
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
			 -- Fi Bug 18940/92686 - 27/09/2011 - AMC
			 plocalidad	IN	per_direcciones.localidad%TYPE DEFAULT NULL -- Bug 24780/130907 - 05/12/2012 - AMC

	)
	  RETURN VARCHAR2;

	  -- Bug 21863 - RSC - 29/03/2012 - LCOL - Incidencias Reservas
	FUNCTION f_retenida_siniestro(
			 psseguro	IN	NUMBER,
			 pfecha	IN	DATE,
			 pcgarant	IN	NUMBER,
			 pctipo	IN	NUMBER
	)   RETURN NUMBER;

	  -- Fin bug 21863
	  -- Bug 21808 - RSC - 04/05/2012 - LCOL - UAT - Revisi¿n de Listados Producci¿n
	FUNCTION f_esta_retenica_sin_resc(
			psseguro	IN	NUMBER,
			 psproduc	IN	NUMBER,
			 pfecha	IN	DATE
	)   RETURN NUMBER;

	  -- Fin bUG 21808
	FUNCTION f_hay_peritaje(
			pnsinies	IN	VARCHAR2
	)   RETURN NUMBER;

	FUNCTION f_obt_primas_financiadas(
			 psseguro	IN	NUMBER,
			 ptablas	IN	VARCHAR2,
			 pimporte	OUT	NUMBER
	)   RETURN NUMBER;

	  -- Ini Bug 23254 - MDS - 06/09/2012
	FUNCTION f_calc_prov_migrada(
			psseguro NUMBER,
			 pnriesgo	IN	NUMBER
	)   RETURN NUMBER;

	  -- Fin Bug 23254 - MDS - 06/09/2012
	  -- Ini Bug 23644 - AVT - 25/09/2012
	  -- Ini Bug 23644 - ECP - 14/01/2013
	FUNCTION f_calc_perc_reserva_pm(
			 psseguro NUMBER,
			 psidepag	IN	NUMBER,
			 porigen	IN	NUMBER,
			 pcgarant	IN	NUMBER
	)   RETURN NUMBER;

	  -- Fin Bug 23644 - ECP - 14/01/2013
	  -- Fin Bug 23644 - AVT - 25/09/2012
	  -- Ini Bug 23864/124752 - JGR - 02/10/2012
	FUNCTION f_devolu_accion_7(
			 pcactimp	IN	NUMBER,
			 pnrecibo	IN	NUMBER,
			 pffejecu	IN	DATE,
			 psseguro	IN	NUMBER,
			 pcmotivo	IN	NUMBER,
			 pffecalt	IN	DATE,
			 piprovis	IN	OUT NUMBER,
			 --> Parte del importe que no cubre la provisi¿n
			 pcidioma	IN	NUMBER DEFAULT pac_md_common.f_get_cxtidioma,
			 psproces	IN	NUMBER
	)
	  RETURN NUMBER;

	  -- Fin Bug 23864/124752 - JGR - 02/10/2012
	  -- Bug 0025087 - JMF - 17/12/2012
	FUNCTION f_prod_usu_esp(
			psproduc	IN	NUMBER,
			 pcagente	IN	NUMBER,
			 pctipo	IN	NUMBER
	)   RETURN NUMBER;

	  -- bug 25204:ASN:19/12/2012
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
	)   RETURN NUMBER;

	  -- bug 25204:ASN:19/12/2012
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
	)   RETURN NUMBER;

	  /*************************************************************************
	Actualiza el campo cbloqueocol de seguros
	param in psseguro
	return                 : 0 todo correcto
	1 ha habido un error
	*************************************************************************/
	  -- Bug 23940 - APD - 02/01/2013 -  se crea la funcion
	FUNCTION f_act_cbloqueocol(
			psseguro	IN	NUMBER
	)   RETURN NUMBER;

	  -- Bug 26472 - NSS - 04/04/2013
	FUNCTION f_acciones_cierre(
			pnsinies	IN	VARCHAR2
	)   RETURN NUMBER;

	  -- Fin Bug 26472 - NSS - 04/04/2013
	  -- Bug 26989 - APD - 09/05/2013 -  se crea la funcion
	FUNCTION f_valor_asegurado(
			psseguro	IN	NUMBER,
			 pnriesgo	IN	NUMBER,
			 pnmovimi	IN	NUMBER
	)   RETURN NUMBER;

	  -- fin Bug 26989 - APD - 09/05/2013
	  -- Bug 26962 - NSS - 17/05/2013
	FUNCTION f_acciones_apertura(
			pnsinies	IN	VARCHAR2
	)   RETURN NUMBER;

	  -- Fin Bug 26962 - NSS - 17/05/2013
	  -- Bug 26675 - JRH - 13/08/2013
	FUNCTION f_get_provision(
			 p_nsinies	IN	VARCHAR2,
			 p_ntramte	IN	NUMBER,
			 p_ntramit	IN	NUMBER,
			 p_fecha	IN	DATE,
			 pcgarant	IN	NUMBER,
			 p_iprovis	OUT	NUMBER
	)   RETURN NUMBER;

	FUNCTION f_get_pagos(
			 p_nsinies	IN	VARCHAR2,
			 p_fechafin	IN	DATE,
			 p_fechaini	IN	DATE,
			 pcgarant	IN	NUMBER
	)   RETURN NUMBER;

	FUNCTION f_get_recibos(
			 psseguro	IN	NUMBER,
			 pcconcep	IN	NUMBER,
			 p_fechafin	IN	DATE,
			 p_fechaini	IN	DATE,
			 pcgarant	IN	NUMBER
	)   RETURN NUMBER;

	FUNCTION f_get_siniestralidad(
			 pnsesion NUMBER,
			 psseguro	IN	NUMBER,
			 pnriesgo	IN	NUMBER DEFAULT 1,
			 pcgarant	IN	NUMBER DEFAULT NULL,
			 parfechafin	IN	DATE DEFAULT NULL,
			 pfechaini	IN	DATE DEFAULT NULL
	)   RETURN NUMBER;

	FUNCTION f_get_pb(
			 pnsesion NUMBER,
			 psseguro	IN	NUMBER,
			 parfechafin	IN	DATE DEFAULT NULL,
			 pfechaini	IN	DATE DEFAULT NULL
	)   RETURN NUMBER;

	FUNCTION f_get_pagos_provis_pol(
			 psseguro NUMBER,
			 pfechafin DATE,
			 wfechaini	IN	DATE,
			 pcgarant NUMBER,
			 pprovis	OUT	NUMBER,
			 ppagos	OUT	NUMBER
	)   RETURN NUMBER;

	  --Fi  Bug 26675 - JRH
	  -- BUG 25720 - FAL - 02/09/2013
	FUNCTION f_get_numpol_dispo(
			 p_cempres	IN	NUMBER,
			 p_tipo	IN	VARCHAR2,
			 p_caux	IN	NUMBER,
			 p_exp	IN	NUMBER DEFAULT 6
	)   RETURN NUMBER;

	  -- FI BUG 25720 - FAL - 02/09/2013
	  -- BUG 27909 - NSS - 04/09/2013
	FUNCTION f_get_lstcconpag(
			psproduc	IN	NUMBER DEFAULT NULL,
			 mensajes	OUT	T_IAX_MENSAJES
	)   RETURN SYS_REFCURSOR;

	FUNCTION f_get_lstcconpag_dep(
			 pctippag	IN	NUMBER,
			 psproduc	IN	NUMBER DEFAULT NULL,
			 mensajes	OUT	T_IAX_MENSAJES
	)   RETURN SYS_REFCURSOR;

	  -- FI BUG 27909 - NSS - 04/09/2013
	  --INI BUG 29659#c163123 - JDS - 14/01/2014
	FUNCTION f_mig_autos(
			 p_cempres	IN	NUMBER,
			 p_cmatric	IN	VARCHAR2,
			 p_sseguro	IN	NUMBER,
			 pqueryaut	OUT	VARCHAR2,
			 pqueryaccesorios	OUT	VARCHAR2,
			 pquerydispositivos	OUT	VARCHAR2
	)   RETURN NUMBER;

	  --FIN BUG 29659#c163123 - JDS - 14/01/2014
	FUNCTION f_alta_poliza_pu(
			 psseguro	IN	NUMBER,
			 pfefecto	IN	DATE,
			 ppu	IN	NUMBER,
			 pcempres	IN	NUMBER,
			 pnew_npoliza	OUT	NUMBER
	)   RETURN NUMBER;

	FUNCTION f_alta_detalle_gar(
			 psseguro	IN	NUMBER,
			 pfefecto	IN	DATE,
			 ppu	IN	NUMBER,
			 pcempres	IN	NUMBER
	)   RETURN NUMBER;

	  --Ini Bug 29224 - 24/02/2014 - NSS
	  /*************************************************************************
	FUNCTION f_get_municipios_pagos
	*************************************************************************/
	FUNCTION f_get_municipios_pagos(
			pcempres	IN	NUMBER,
			 pquery	OUT	VARCHAR2
	)   RETURN NUMBER;

	  --Fin Bug 29224 - 24/02/2014 - NSS
	  /***********************************************************************
	FUNCTION f_porcomision
	Calcula porcentaje comision de un recibo
	Bug 0031510 - 27/05/2014 - JMF
	***********************************************************************/
	FUNCTION f_porcomision(
			pnrecibo	IN	NUMBER
	)   RETURN NUMBER;

	FUNCTION f_psu_retroactividad(
			pcempres	IN	NUMBER,
			 psseguro	IN	NUMBER,
			 pnmovimi	IN	NUMBER
	)   RETURN NUMBER;

	  -- 0032511: SIN - retencion poliza al cambiar reserva
	FUNCTION f_accion_cambio_reserva(
			pcempres	IN	NUMBER,
			 pnsinies	IN	VARCHAR2
	)   RETURN NUMBER;

	  --Inicio Bug 0031135 20140818   MMS
	FUNCTION f_comi_ces(
			 pscomrea	IN	NUMBER,
			 psseguro	IN	NUMBER,
			 pcgarant	IN	NUMBER,
			 pcomisi	IN	NUMBER,
			 pfefecto	IN	DATE
	)   RETURN NUMBER;

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
	)   RETURN NUMBER;

	  -- Funcion para saber si el agente es de tipo corredor (de agentes_comp VF 371 )
	FUNCTION f_agentecorredor(
			p_ctipint	IN	NUMBER
	)   RETURN NUMBER;

	  --Fin Bug 0031135 20140818   MMS
	FUNCTION f_post_rehabilitacion(
			psseguro	IN	NUMBER
	)   RETURN NUMBER;

	  -- Bug 29817 MSV - Acciones para las listas restringidas
	FUNCTION f_acciones_post_movimientos(
			 psseguro	IN	NUMBER,
			 psaccion	IN	NUMBER,
			 pcmotmov	IN	NUMBER
	)   RETURN NUMBER;

	  -- Bug 29817 MSV - Acciones para las listas restringidas
	FUNCTION f_acciones_post_rescate(
			psseguro	IN	NUMBER,
			 psaccion	IN	NUMBER
	)   RETURN NUMBER;

	  -- Bug 29817 MSV - Acciones para las listas restringidas
	FUNCTION f_acciones_post_siniestro(
			 psseguro	IN	NUMBER,
			 psaccion	IN	NUMBER,
			 psccausin	IN	NUMBER
	)   RETURN NUMBER;

	FUNCTION f_usar_shw(
			psseguro	IN	NUMBER,
			 pffecmov DATE
	)   RETURN NUMBER;

	FUNCTION f_reparto_shadow(
			 psseguro	IN	NUMBER,
			 pfecha	IN	DATE,
			 pcesta	IN	NUMBER,
			 picaprisc	IN	NUMBER,
			 picaprisc_pa	OUT	NUMBER,
			 picaprisc_shw	OUT	NUMBER
	)   RETURN NUMBER;

	  -- MNTIS 35101/199856 GSIN7. Solicitar datos para el modelo 145
	FUNCTION f_valida_fiscalidad(
			sperson	IN	NUMBER,
			 pnsinies	IN	VARCHAR2
	)   RETURN NUMBER;

	FUNCTION f_proy_aho_resc(
			 psseguro	IN	NUMBER,
			 pnriesgo	IN	NUMBER,
			 pnmovimi	IN	NUMBER,
			 pfecha	IN	NUMBER,
			 piimpsin	IN	NUMBER,
			 picapesp	OUT	NUMBER
	)   RETURN NUMBER;

	FUNCTION f_genera_archivo_cheque(
			 fini DATE,
			 ffin DATE,
			 p_directorio	IN	VARCHAR2,
			 pcregenera	IN	NUMBER
	)   RETURN NUMBER;

	FUNCTION f_actualiza_estado_cheque(
			fini DATE,
			 ffin DATE
	)   RETURN NUMBER;

	FUNCTION f_gen_rec_informe(
			pcmap	IN	VARCHAR2,
			 pparams	IN	T_IAX_INFO
	)   RETURN NUMBER;

	FUNCTION f_inireserva_gasto(
			pnsinies	IN	VARCHAR2
	)   RETURN NUMBER;

	FUNCTION f_accion_siniestro(
			 paccion	IN	NUMBER,
			 pnsinies sin_siniestro.nsinies%TYPE,
			 pctipsin sin_causa_motivo.ctipsin%TYPE,
			 pccausin sin_siniestro.ccausin%TYPE,
			 psseguro sin_siniestro.sseguro%TYPE,
			 pnriesgo sin_siniestro.nriesgo%TYPE,
			 pfsinies sin_siniestro.fsinies%TYPE
	)   RETURN NUMBER;

	FUNCTION f_ustrid_sepa_transf(
			 pcatribu	IN	NUMBER,
			 pidentifica	IN	NUMBER
	)   RETURN VARCHAR2;

  FUNCTION f_accion_post_rechazo(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pnsuplem IN NUMBER,
      paccion NUMBER,
      pnmovimi IN NUMBER DEFAULT NULL,
      pnorec IN NUMBER DEFAULT 0
  )   RETURN NUMBER;

  FUNCTION f_desc_movres (
      pnsinies IN sin_tramita_reserva.nsinies%TYPE,
      pntramit IN sin_tramita_reserva.ntramit%TYPE,
      pctipres IN sin_tramita_reserva.ctipres%TYPE,
      pnmovres IN sin_tramita_reserva.nmovres%TYPE,
      pcmovres IN sin_tramita_reserva.cmovres%TYPE,
      pcsolidaridad IN sin_tramita_reserva.csolidaridad%TYPE DEFAULT NULL,
      pcidioma IN	NUMBER
  )   RETURN VARCHAR2;
END pac_propio;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROPIO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO" TO "PROGRAMADORESCSI";
