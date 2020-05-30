CREATE OR REPLACE PACKAGE PAC_PROPIO_CONF IS
		   /******************************************************************************
		      NOMBRE:     PAC_PROPIO_CONF
		      PROPÓSITO:  Package que contiene las funciones propias de cada empresa.

		      REVISIONES:
		      Ver        Fecha        Autor             Descripción
		      ---------  ----------  ---------------  ------------------------------------
		      1.0        17/06/2011   DRA              1.0 0018790: LCOL001 - Alta empresa Liberty Colombia en DESA y TEST
		      2.0        30/09/2011   JMF              2.0 0018967 LCOL_T005 - Listas restringidas validaciones y controles
		      3.0        25/10/2011   JMF              3.0 0019791: LCOL_A001-Modificaciones de fase 0 en la consulta de recibos
		      4.0        17/11/2011   JMC              x.0 0019303: LCOL_T003-Analisis Polissa saldada/prorrogada. LCOL_TEC_ProductosBrechas04
		      5.0        14/12/2011   RSC              5. 0019715: LCOL: Migración de productos de Vida Individual
		      6.0        28/12/2011   JMC              6.0 0019238: LCOL_T001- Prèstecs de pòlisses de vida
		      7.0        05/01/2012   MDS              7.0 0020105: LCOL898 - Interfaces - Regulatorio - Reporte Encuesta Fasecolda
		      8.0        17/01/2012   MDS              8.  0020102: LCOL898 - Interface - Financiero - Carga de Comisiones Liquidadas
		      9.0        09/02/2012   MDS              9.  0021120: LCOL897-LCOL_A001-Resumen y detalle de las domiciliaciones y de las prenotificaciones
		     10.0        18/05/2012   JMF              0022302: LCOL_A001: Llistat de liquidacions
		     11.0        30/07/2012   JLTS             11. 0023175: LCOL897-LCOL - Listado prestamos saldo pendientes
		     12.0        06/09/2012   MDS              12. 0023254: LCOL - qtrackers 4806 / 4808. Màxim dels prestecs.
		     13.0        25/09/2012   AVT              13. 0023644: LCOL_A002-Qtracker: 0004565: Cesion de Siniestro no descuenta reserva matematica
		     14.0        19/10/2012   DRA              14. 0023911: LCOL: Añadir Retorno para los productos Colectivos
		     15.0        14/01/2013   ECP              15. 0023644: LCOL_A002-Qtracker: 0004565: Cesion de Siniestro no descuenta reserva matematica
		     16.0        24/02/2014   NSS              16. 0029224: (POSAN500)-Analisis-Siniestros-Nuevos Desarrollos
		     17.0        10/04/2014   JGR              17. 0025611#c171446 - En pruebas internas de cargas de ARL vemos que no se crean los recaudos
		     18.0        30/04/2014   FAL              18. 0027642: RSA102 - Producto Tradicional
		     19.0        25/06/2014   AGG              19. 0029943: POSRA200 - Gaps 27,28 Anexos de PU en VIb
             20.0        28/05/2019   ECP              20. IAXIS/3592. Proceso de Terminaci[on por no pago.
		   ******************************************************************************/

		--Fin Bug.: 10733

		   /***********************************************************************
		           FUNCTION f_nsolici,
		           Devuelve un nuevo solicitud.
		           param in p_cramo: código de ramo
		           return:         nuevo número de secuencia
		   ***********************************************************************/
		    -- BUG 0019332 - 30/08/2011 - JMF
	FUNCTION f_nsolici(
			 p_cramo	IN	NUMBER
	)   RETURN NUMBER;

  FUNCTION f_tdomici(
      pcsiglas IN per_direcciones.csiglas%TYPE,
      ptnomvia IN per_direcciones.tnomvia%TYPE,
      pnnumvia IN per_direcciones.nnumvia%TYPE,
      ptcomple IN per_direcciones.tcomple%TYPE,
      -- Bug 18940/92686 - 27/09/2011 - AMC
      pcviavp IN per_direcciones.cviavp%TYPE DEFAULT NULL,
      pclitvp IN per_direcciones.clitvp%TYPE DEFAULT NULL,
      pcbisvp IN per_direcciones.cbisvp%TYPE DEFAULT NULL,
      pcorvp IN per_direcciones.corvp%TYPE DEFAULT NULL,
      pnviaadco IN per_direcciones.nviaadco%TYPE DEFAULT NULL,
      pclitco IN per_direcciones.clitco%TYPE DEFAULT NULL,
      pcorco IN per_direcciones.corco%TYPE DEFAULT NULL,
      pnplacaco IN per_direcciones.nplacaco%TYPE DEFAULT NULL,
      pcor2co IN per_direcciones.cor2co%TYPE DEFAULT NULL,
      pcdet1ia IN per_direcciones.cdet1ia%TYPE DEFAULT NULL,
      ptnum1ia IN per_direcciones.tnum1ia%TYPE DEFAULT NULL,
      pcdet2ia IN per_direcciones.cdet2ia%TYPE DEFAULT NULL,
      ptnum2ia IN per_direcciones.tnum2ia%TYPE DEFAULT NULL,
      pcdet3ia IN per_direcciones.cdet3ia%TYPE DEFAULT NULL,
      ptnum3ia IN per_direcciones.tnum3ia%TYPE DEFAULT NULL,
      -- Fi Bug 18940/92686 - 27/09/2011 - AMC
      plocalidad IN per_direcciones.localidad%TYPE
            DEFAULT NULL   -- Bug 24780/130907 - 05/12/2012 - AMC
                        )
      RETURN VARCHAR2;
      --Ini CONF-219 AP
  /*************************************************************************
  FUNCTION F_EXTRAE_NPOLCONTRA
  Extrae el nº de poliza del codigo de contrato (preguntas 4097)
  param in pncontinter  : Código de contrato
  param in pcempres     : Codigo de la empresa
  return             : Nº poliza
  *************************************************************************/
  FUNCTION F_EXTRAE_NPOLCONTRA(PNCONTRATO IN VARCHAR2, PCEMPRES NUMBER)
    RETURN NUMBER;
    --Fi CONF-219 AP

  FUNCTION f_desc_movres (
      pnsinies IN sin_tramita_reserva.nsinies%TYPE,
      pntramit IN sin_tramita_reserva.ntramit%TYPE,
      pctipres IN sin_tramita_reserva.ctipres%TYPE,
      pnmovres IN sin_tramita_reserva.nmovres%TYPE,
      pcmovres IN sin_tramita_reserva.cmovres%TYPE,
      pcsolidaridad IN sin_tramita_reserva.csolidaridad%TYPE DEFAULT NULL,
      pcidioma IN	NUMBER
  )   RETURN VARCHAR2;

   --AAC_INI-CONF_OUTSOURCING-20160906
   FUNCTION p_personas_rel(
      psperson     NUMBER,
      pCTIPPER_REL NUMBER)
    RETURN VARCHAR2;
   --AAC_FI-CONF_OUTSOURCING-20160906
/*************************************************************************
  FUNCTION f_contador2
         Devuelve un nuevo valor del contador.
	       param in p_tipo: tipo  -> '01': siniestro
	                              -> '02': poliza
	                              -> '03': recibos
	                              -> '04': recibos pruebas
	       param in p_caux: código de empresa para los recibos y código de ramo
	                        para el resto
	       param in p_exp: número de dígitos a concatenar a p_caux
	       return:         nuevo número de secuencia
  *************************************************************************/
   FUNCTION f_contador2(
			p_tipo	IN	VARCHAR2,
			p_caux	IN	NUMBER,
			p_exp	IN	NUMBER DEFAULT 6
	) RETURN NUMBER;

	 /*************************************************************************
         FUNCTION    FF_PCOMISI_PCOMISI
         PROPÓSITO:  Función que llama a la función f_pcomisi,
                     calculando algunos de los parámetros de entrada,
                     y devuelve el valor ppcomisi de f_pcomisi

    *************************************************************************/
   FUNCTION ff_pcomisi_pcomisi(psseguro IN NUMBER, pnrecibo IN NUMBER, pcgarant IN NUMBER)
      RETURN NUMBER;

    /*************************************************************************
       FUNCTION proceso_liscomis_calcom
       Calcula la comisión para un producto
       param in psproduc    : codigo producto
       param out perror  : 0=bien, numero=codigo error
       param out pcomisi : porcentaje comisión
    *************************************************************************/
   PROCEDURE proceso_liscomis_calcom(psproduc IN NUMBER, perror OUT NUMBER, pcomisi OUT NUMBER);


      /*************************************************************************
       FUNCTION f_devolu_accion_7
       calcula valor de prorrata para recibos de polizas anuladas por no pago
       param in psproduc    : codigo producto
       param out perror  : 0=bien, numero=codigo error
       param out pcomisi : porcentaje comisiÃ³n
    *************************************************************************/
   	FUNCTION f_devolu_accion_7(
			 pcactimp	IN	NUMBER,
			 pnrecibo	IN	NUMBER,
			 pffejecu	IN	DATE,
			 psseguro	IN	NUMBER,
			 pcmotivo	IN	NUMBER,
			 pffecalt	IN	DATE,
			 piprovis	IN	OUT NUMBER,
			 --> Parte del importe que no cubre la provisión
			 pcidioma	IN	NUMBER DEFAULT pac_md_common.f_get_cxtidioma,
			 psproces	IN	NUMBER
	)
	  RETURN NUMBER;

       /*************************************************************************
       FUNCTION f_genera_recibo
       Crea recibo en estado pendiente con cobro para las polizas anuladas que se pasaron del periodo de gracia para recibos anulados por no pago
      param pcempres IN : Id de empresa
      param psseguro IN : id_de seguro
      param pnrecibo IN : id de recibo
      param pfefecto IN : fecha efecto de poliza
      param pfvencim IN : fecha vencimiento de poliza
      param pfgracia IN : fecha calculada del periodo de gracia
      param pnmovimi IN : id del movimiento de anulacion del recibo
      param ptipocert IN : tipo porcentaje
      param pcmoneda IN : moneda de seguro
      param pnrecibo_out : recibo de salida viene en NULL
      param pctiprec IN : tipo de recibo a crear
      param pnfactor IN : factor para realizar calculo de prorrata
      param pgasexp IN :
      param psmovagr IN :
    *************************************************************************/

   FUNCTION f_genera_recibo(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      pfefecto IN DATE,
      pfvencim IN DATE,
      pfgracia IN DATE,
      pnmovimi IN NUMBER,
      ptipocert IN VARCHAR2,
      pcmoneda IN NUMBER,
      pnrecibo_out OUT NUMBER,
      pctiprec IN NUMBER,
      pnfactor IN NUMBER,
      pgasexp IN NUMBER,
      psmovagr IN NUMBER DEFAULT 0)   --56. 0027378: LCOL_A005-Error en terminaciones por no pago ... - QT-7911
      RETURN NUMBER;

       /*************************************************************************
       FUNCTION f_genera_contabilidad_recibo
       Crea recibo en estado pendiente con cobro para las polizas anuladas que se pasaron del periodo de gracia para recibos anulados por no pago
      param pcempres IN : Id de empresa
      param psseguro IN : id_de seguro
      param pnrecibo IN : id de recibo
      param pfefecto IN : fecha efecto de poliza
      param pfvencim IN : fecha vencimiento de poliza
      param pfgracia IN : fecha calculada del periodo de gracia
      param pnmovimi IN : id del movimiento de anulacion del recibo
      param ptipocert IN : tipo porcentaje
      param pcmoneda IN : moneda de seguro
      param pnrecibo_out : recibo de salida viene en NULL
      param pctiprec IN : tipo de recibo a crear
      param pnfactor IN : factor para realizar calculo de prorrata
      param pgasexp IN :
      param psmovagr IN :
    *************************************************************************/
-- Ini IAXIS- 3592 -- ECP -- 23/05/2019
   FUNCTION f_genera_contabilidad_recibo(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      pfefecto IN DATE,
      pfvencim IN DATE,
      pfgracia IN DATE,
      pnmovimi IN NUMBER,
      ptipocert IN VARCHAR2,
      pcmoneda IN NUMBER,
      pnrecibo_out OUT NUMBER,
      pctiprec IN NUMBER,
      pnfactor IN NUMBER,
      pgasexp IN NUMBER,
      psmovagr IN NUMBER DEFAULT 0)   --56. 0027378: LCOL_A005-Error en terminaciones por no pago ... - QT-7911
      RETURN NUMBER;
-- Fin IAXIS- 3592 -- ECP -- 23/05/2019

END pac_propio_conf;


/
