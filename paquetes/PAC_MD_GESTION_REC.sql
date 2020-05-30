--------------------------------------------------------
--  DDL for Package PAC_MD_GESTION_REC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_GESTION_REC" AS
   /******************************************************************************
      NOMBRE:      PAC_MD_GESTION_REC
      PROPÓSITO:   Impresion de recibos
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        28/01/2009                   1. Creación del package.
      1.1        11/02/2009   FAL             1. Añadir funcionalidades de gestión de recibos. Bug: 0007657
      1.2        27/02/2009   MCC             1. Excel para la impresion del docket. Bug 009005: APR - docket para los brokers
      1.3        15/06/2009   JTS             1. BUG 10069
      2          30/03/2009   XPL             2 13850: APRM00 - Lista de recibos por personas
      3          29/04/2010   LCF             4 14302 Campo descripción traspaso saldo
      4.0        25/05/2010   ICV             5. 14586: CRT - Añadir campo recibo compañia
      5.0        17/11/2010   ICV             6. 0016383: AGA003 - recargo por devolución de recibo (renegociación de recibos)
      6.0        03/01/2012   JMF             7. 0020761 LCOL_A001- Quotes targetes
      7.0        08/06/2012   APD             7. 0022342: MDP_A001-Devoluciones
      8.0        25/10/2012   DRA             8. 0023853: LCOL - PRIMAS MÍNIMAS PACTADAS POR PÓLIZA Y POR COBRO
      9.0        27/11/2012   ETM             9.0024854: ENSA998-Boton de refresco de datos de recibo online SAP
      10.0       25/11/2012   ETM             10.0029009: POSRA100-POS - Pantalla manual de recibos
      11.0       21/01/2014   JDS             11.0029603: POSRA300-Texto en la columna Pagador del Recibo para recibos de Colectivos
     12.0       02/06/2014   MMM             12.0028551: LCOLF3BADM-Id. 162 - Terminacion por no pago por convenio a nivel de intermediario
     13.0       09/07/2019   DFR              13. IAXIS-3651 Proceso calculo de comisiones de outsourcing 
   ******************************************************************************/

   /*******************************************************************************
      FUNCION F_IMPR_PENDIENTE_MAN
   la funcion se encargará de grabar en la tabla temporal de la impresión de recibos aquellos que cumplan con los criterios de búsqueda
      param in psproduc : Id. producto
      param in pcagente : Agente
      param in psproces : Proceso
      param in pnpoliza : Poliza
      param in pnrecibo : Recibo
      param in pdataini : Fecha inicio
      param in pdatafin : Fecha fin
      param in pcreimp  : Reimpresion
      param in psproimp : Codigo proceso
      param in pcreccia : Recibo compañia
      param out psproimp2 : Codigo proceso
      param out mensajes  : mensajes de error
      return : number con el código de proceso para la impresión.
   ********************************************************************************/
   FUNCTION f_impr_pendiente_man(
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      psproces IN NUMBER,
      pnpoliza IN NUMBER,
      pnrecibo IN NUMBER,
      pdataini IN DATE,
      pdatafin IN DATE,
      pcreimp IN NUMBER,
      psproimp IN NUMBER,
      pcreccia IN VARCHAR2,   --Bug 14586-PFA-25/05/2010- Añadir campo recibo compañia
      psproimp2 OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*******************************************************************************
                              FUNCION F_GET_IMPR_PENDIENTE_MAN
   Esta función retornará el conteniendo de la tabla tmp_recgestion para el proceso solicitado.
      param in psproimp : Codigo proceso
      param in pcidioma : Idioma
      param in pitotalr : Total recibo
      param out mensajes  : mensajes de error
      return: ref_cursor con los registros que cumplan con el criterio
   ********************************************************************************/
   FUNCTION f_get_impr_pendiente_man(
      psproimp IN NUMBER,
      pcidioma IN NUMBER,
      pitotalr OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*******************************************************************************
      FUNCION F_SET_IMPR_PENDIENTE_MAN
   Se actualizará el cestado de la tabla tmp_recgestion para el recibo y proceso informado por parámetro.
      param in psproimp : Codigo proceso
      param in pnrecibo : Recibo
      param in pcestado : Estado
      param out pitotalr : Total recibo
      param out mensajes  : mensajes de error
      return : NUMBER
   ********************************************************************************/
   FUNCTION f_set_impr_pendiente_man(
      psproimp IN NUMBER,
      pnrecibo IN NUMBER,
      pcestado IN NUMBER,
      pitotalr OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*******************************************************************************
      FUNCION F_CANCEL_IMPRESION_MAN
   Se borrará la tabla tmp_recgestion para el sproimp informado
      param in psproimp : codigo proceso
      param out mensajes  : mensajes de error
      return : NUMBER , un número con el id del error, en caso de que todo vaya OK, retornará un cero
   ********************************************************************************/
   FUNCTION f_cancel_impresion_man(psproimp IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*******************************************************************************
      FUNCION F_IMPRESION_RECIBOS_MAN
   Función que imprimirá los recibos seleccionados.
     param in psproimp : codigo proceso
     param in pcidioma : codigo idioma
     param out pfichero : ruta del fichero generado
     param out mensajes  : mensajes de error
     return : number un número con el id del error, en caso de que todo vaya OK, retornará un cero.
   ********************************************************************************/
   FUNCTION f_impresion_recibos_man(
      psproimp IN NUMBER,
      pcidioma IN NUMBER,
      pfichero OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*******************************************************************************
      FUNCION F_IMPRESION_REGISTRO_MAN
   Función que lanza los reports de agente.
     param in pcagente : Codigo agente
     param in pdataini : Fecha Inicio
     param in pdatafin : Fecha Fin
     param in pcidioma : Codigo idioma
     param out mensajes  : mensajes de error
     param out pfichero  : ruta del fichero generado --Bug 9005-MCC-Creación de fichero.
     return : number un número con el id del error, en caso de que todo vaya OK, retornará un cero.
   ********************************************************************************/
   FUNCTION f_impresion_registro_man(
      pcagente IN NUMBER,
      pdataini IN DATE,
      pdatafin IN DATE,
      pcidioma IN NUMBER,
      pfichero1 OUT VARCHAR2,
      pfichero2 OUT VARCHAR2,   --Bug 9005 -01/03/2009- MCC- Apertura de ficheros para "NL" y para "FR"
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*******************************************************************************
                                  FUNCION F_SELEC_TODOS_RECIBOS
   Se actualizará el cestado a 1 de todos los recibos la tabla tmp_recgestion para un proceso psproimp por parámetro.
     param in psproimp : Codigo proceso
     param in pitotalr : Total recibos
     param out mensajes  : mensajes de error
     return : NUMBER
   ********************************************************************************/
   FUNCTION f_selec_todos_recibos(
      psproimp IN NUMBER,
      pitotalr OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*******************************************************************************
      FUNCION F_DESSELEC_TODOS_RECIBOS
   Se actualizará el cestado a 0 de todos los recibos de la tabla tmp_recgestion para un proceso psproimp por parámetro.
     param in psproimp : Codigo proceso
     param in pitotalr : Total recibos
     param out mensajes  : mensajes de error
     return : NUMBER
   ********************************************************************************/
   FUNCTION f_desselec_todos_recibos(
      psproimp IN NUMBER,
      pitotalr OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*-----------------------------------------------------------------------*/
/* Gestión manual de recibos                                             */
/* Bug: 0007657: IAX - Gestión de recibos                                */
/* FAL                                              */
/*-----------------------------------------------------------------------*/

   --BUG 10069 - 15/06/2009 - JTS
   --BUG 11777 - 11/11/2009 - JRB - Se pasa el ctipban y cbancar para actualizarlo en el recibo.
   /*******************************************************************************
      FUNCION F_COBRO_RECIBO
   Función que realiza el cobro para usuarios de central (cobro manual)
      param in pcempres : empres
      param in pnrecibo : recibo
      param in pfmovini : fecha de cobro
      param in pctipban : Tipo de cuenta.
      param in pcbancar : Cuenta bancaria.
      param in pccobban : cobrador bancario
      param in pdelega : delegación
      param in phost : 1.- Cobro por host y manual 0.- Solo cobro manual
      param out mensajes  : mensajes de error
      return: 0.- OK, 1.- KO
   ********************************************************************************/
   FUNCTION f_cobro_recibo(
      pcempres IN NUMBER,
      pnrecibo IN NUMBER,
      pfmovini IN DATE,
      pctipban IN NUMBER,
      pcbancar IN VARCHAR2,
      pccobban IN NUMBER,
      pdelega IN NUMBER,
      phost IN NUMBER,
      pctipcob IN NUMBER DEFAULT 0,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   --Fi BUG 10069 - 15/06/2009 - JTS

   /*******************************************************************************
      FUNCION F_ANULA_RECIBO
   Función que realiza la anulación de un recibo.
      param in pnrecibo : recibo
      param in pfanulac : fecha anulación
      param in pcmotanu : motivo anulación
      param out mensajes  : mensajes de error
      return: number indicando código de error (0: sin errores)
   ********************************************************************************/
   FUNCTION f_anula_recibo(
      pnrecibo IN NUMBER,
      pfanulac IN DATE,
      pcmotanu IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*******************************************************************************
      FUNCION F_MODIFICA_RECIBO
   Función que realiza modificación en el recibo.
      param in pnrecibo : recibo
      param in pctipban : tipo cuenta
      param in pcbancar : cuenta bancaria
      param in pcgescob : gestor de cobro
      param in pcestimp : estado de impresión
      param in pcaccpre : código de acción preconcedida
      param in pcaccret : código de acción retenida
      param in ptobserv : texto de observaciones
      param out mensajes  : mensajes de error
      return: number indicando código de error (0: sin errores)
      -- BUG 0020761 - 03/01/2012 - JMF: ncuotar
      -- Bug 22342 - APD - 11/06/2012 - se añaden los parametros pcaccpre, pcaccret y ptobserv
   ********************************************************************************/
   FUNCTION f_modifica_recibo(
      pnrecibo IN NUMBER,
      pctipban IN NUMBER,
      pcbancar IN VARCHAR2,
      pcgescob IN NUMBER,
      pcestimp IN NUMBER,
      pccobban IN NUMBER,
      pncuotar IN NUMBER DEFAULT NULL,
      pcaccpre IN NUMBER DEFAULT NULL,
      pcaccret IN NUMBER DEFAULT NULL,
      ptobserv IN VARCHAR2 DEFAULT NULL,
      pctipcob IN NUMBER DEFAULT NULL,
      --AAC_INI-CONF_OUTSOURCING-20160906
      pcgescar IN NUMBER DEFAULT NULL,
      --AAC_FI-CONF_OUTSOURCING-20160906
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*******************************************************************************
      FUNCION F_ANULACION_PENDIENTE
   Función que marca un recibo como pendiente de anulación
      param in pnrecibo : recibo
      param out mensajes  : mensajes de error
      return: number indicando código de error (0: sin errores)
   ********************************************************************************/
   FUNCTION f_anulacion_pendiente(pnrecibo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*******************************************************************************
      FUNCION F_VALIDA_COBRO
   Función que valida si el recibo pertenece a la empresa: pempresa
      param in pempresa : empresa
      param in pnrecibo : recibo
      param out mensajes  : mensajes de error
      return: number indicando código de error (0: sin errores)
   ********************************************************************************/
   FUNCTION f_valida_cobro(
      pempresa IN NUMBER,
      pnrecibo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

      /*******************************************************************************
      FUNCION F_IMPAGO_RECIBO
   Función que realiza el impago o descobro de un recibo
      param in pnrecibo : recibo
      param in pfecha : fecha de descobro
      param in pccobban : cobrador bancario
      param in pcmotivo : motivo de descobro
      param out mensajes  : mensajes de error
      return: number indicando código de error (0: sin errores)
   ********************************************************************************/
   FUNCTION f_impago_recibo(
      pnrecibo IN NUMBER,
      pfecha IN DATE,
      pccobban IN NUMBER,
      pcmotivo IN NUMBER,
      pcrecimp IN NUMBER DEFAULT 0,   --Bug.: 16383 - ICV - 17/11/2010
      mensajes IN OUT t_iax_mensajes,
      pnpoliza IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*******************************************************************************
                                       FUNCION f_get_anula_pend
   Función que recupera si un recibo está marcado como pendiente de anulación ó está desmarcado
      param in pnrecibo : recibo
      param out mensajes : mensajes de error
      return: number indicando si el recibo esta marcado como pendiente de anulación
   ********************************************************************************/
   FUNCTION f_get_anula_pend(pnrecibo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*******************************************************************************
      FUNCION F_GET_ACCIONES
   Función que recupera las acciones posibles a realizar sobre un recibo en función del estado del recibo y configuración del usuario
      param in pnrecibo : recibo
      param out mensajes : t_iax_mensajes
      param in pavisos : Indica si se han de mostrar los avisos 1.- Sí 0.- No
      return: sysrefcursor con las posibles acciones a realizar
   ********************************************************************************/
   FUNCTION f_get_acciones(
      pnrecibo IN NUMBER,
      psaltar OUT NUMBER,
      pavisos IN NUMBER DEFAULT 0,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*******************************************************************************
      FUNCION F_get_saldo_inicial
   Función que recupera el saldo de un recibo
      param in pnrecibo : recibo
      param out pisaldo : importe total
      param out mensajes  : mensajes de error
      return: number, 0 OK 1 KO
   ********************************************************************************/
   FUNCTION f_get_saldo_inicial(
      pnrecibo IN NUMBER,
      pisaldo OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*******************************************************************************
      FUNCION f_transferir
   Función que se encarga de transferir el importe al recibo
   destino y de cobrar el recibo destino si fuese necesario
      param in pnrecibo_origen : recibo origen
      param in pnrecibo_destino : recibo destino
      param out pisaldo : importe total
      param in ptdescrip : descripción
      param in out mensajes  : mensajes de error
      return: number, 0 OK 1 KO
   ********************************************************************************/
   FUNCTION f_transferir(
      pnrecibo_origen IN NUMBER,
      pnrecibo_destino IN NUMBER,
      pisaldo IN NUMBER,
      ptdescrip IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*******************************************************************************
      FUNCION f_get_rebtom
   Función que se encarga de devolver los recibos del tomador en los ultimos 5 años
      param in sperson : seq. persona a buscar
      param out pipagado : importe de todos los recibos cobrados
      param out pipendiente : importe de todos los recibos pendientes
      param out pimpagados : importe de todos los recibos impagados
      param out precibos  : Cursos con los recibos a mostrar
      param in out mensajes  : mensajes de error
      return: number, 0 OK 1 KO
      30/03/2009#XPL#13850: APRM00 - Lista de recibos por personas
   ********************************************************************************/
   FUNCTION f_get_rebtom(
      psperson IN NUMBER,
      pipagado OUT NUMBER,
      pipendiente OUT NUMBER,
      pimpagado OUT NUMBER,
      pisaldo OUT NUMBER,
      precibos OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /**************************************************************************************
         F_REHABILITA_REC. Funci¿n que rehabilita un recibo.
         pnrecibo: Recibo que queremos anular
         pfrehabi: Fecha de efecto de rehabilitacion del recibo
         psmovagr: agrupaci¿n de recibos por remesa. Si es null se incrementa la secuencia
         param out mensajes  : mensajes de error
         return: number indicando código de error (0: sin errores)
         Bug 18908/93215 - 05/10/2011 - AMC
    ********************************************************************************/
   FUNCTION f_rehabilita_rec(
      pnrecibo IN NUMBER,
      pfrehabi IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*******************************************************************************
      FUNCION F_MODIFICA_ACCPRECONOCIDA
   Función que realiza modificación en el recibo complementario.
      param in pnrecibo : recibo
      param in pcaccpre : código de acción preconocida
      return: number indicando código de error (0: sin errores)
      Bug 22342 - 11/06/2012 - APD
   ********************************************************************************/
   FUNCTION f_modifica_accpreconocida(
      pnrecibo IN NUMBER,
      pcaccpre IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- BUG23853:DRA:25/10/2012:Inici
   FUNCTION f_genrec_primin_col(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pctiprec IN NUMBER,
      pfemisio IN DATE,
      pfefecto IN DATE,
      pfvencim IN DATE,
      piimprec IN NUMBER,
      pnrecibo IN OUT NUMBER,
      pmodo IN VARCHAR2,
      psproces IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_desctiprec(
      pnrecibo IN NUMBER,
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

   -- BUG23853:DRA:25/10/2012:Fi
   -- BUG24854 :ETM: 27/12/2012 : Inici
   FUNCTION f_sincroniza_sap(pnrecibo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- fIN BUG24854 :ETM: 27/12/2012

   -- JLB - I 23074
   FUNCTION f_genrec_gastos_expedicion(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pctiprec IN NUMBER,
      pfemisio IN DATE,
      pfefecto IN DATE,
      pfvencim IN DATE,
      piimprec IN NUMBER,
      pnrecibo IN OUT NUMBER,
      pmodo IN VARCHAR2,
      psproces IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-- BUG 29009 -- ETM -- 25/11/2013 -- INI
   FUNCTION f_recman_pens(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pctiprec IN NUMBER,
      pimporte IN NUMBER,
      pctipcob IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-- FIN  BUG 29009 -- ETM -- 25/11/2013

   -- BUG 29603 -- JDS -- 21/01/2014 -- INI
/*******************************************************************************
FUNCION f_desctippag
Función que devolverá el literal del pagador del recibo.
param in pnrecibo
param in pcidioma
********************************************************************************/
   FUNCTION f_desctippag(pnrecibo IN NUMBER, pcidioma IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

-- FIN  BUG 29603 -- JDS -- 21/01/2014

   -- 12.0 - 02/06/2014 - MMM - 0028551: LCOLF3BADM-Id. 162 - Terminacion por no pago por convenio a nivel de intermediario - Inicio

   /*******************************************************************************
   FUNCION f_get_lista_dias_gracia
   Función que devuelve un cursor con la lista de dias de gracia dado un
   agente / producto
   param in pcagente
   param in psproduc
   param out mensajes
   ********************************************************************************/
   FUNCTION f_get_lista_dias_gracia(
      pcagente IN NUMBER,
      psproduc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*******************************************************************************
   FUNCION f_set_dias_gracia_agente_prod
   Función que inserta / modifica los dias de gracia, dado un agente y prodcuto
   agente / producto
   param in pcagente
   param in psproduc
   param in pfini
   param in pdias
   param out mensajes
   ********************************************************************************/
   FUNCTION f_set_dias_gracia_agente_prod(
      pcagente IN NUMBER,
      psproduc IN NUMBER,
      pfini IN DATE,
      pdias IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*******************************************************************************
   FUNCION f_del_dias_gracia_agente_prod
   Función que borra un registro de parametrizacion de dias de gracia, dado un
   agente / producto
   param in pcagente
   param in psproduc
   param in pfini
   param out mensajes
   ********************************************************************************/
   FUNCTION f_del_dias_gracia_agente_prod(
      pcagente IN NUMBER,
      psproduc IN NUMBER,
      pfini IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
-- 12.0 - 02/06/2014 - MMM - 0028551: LCOLF3BADM-Id. 162 - Terminacion por no pago por convenio a nivel de intermediario - Fin

FUNCTION f_get_anula_x_no_pago(
			pcempres   IN     NUMBER,
			pcramo   IN     NUMBER,
			psproduc    IN     NUMBER,
			pcagente IN NUMBER,
			pnpoliza    IN     NUMBER,
			pncertif    IN     NUMBER,
            psucur    IN     NUMBER,
			pnrecibo IN NUMBER,
            pidtomador IN VARCHAR2,
            pntomador IN VARCHAR2,
			abrecibo  IN     NUMBER,
            soferta   IN     NUMBER,
            pcmodif   IN     NUMBER,
            ppdlegal  IN     NUMBER,
            ppjudi    IN     NUMBER,
            ppgunica  IN     NUMBER,
            ppestatal IN     NUMBER,
			cur OUT sys_refcursor,
         mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

FUNCTION f_set_anula_x_no_pago(
			pnrecibo IN NUMBER,
      pccheck IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
	RETURN NUMBER;
--   
--Inicio IAXIS-3651 09/07/2019
--
 FUNCTION f_get_liquidacion(
    pnumidetom IN VARCHAR2,
    pcestgest IN NUMBER,
    pfefeini IN DATE,
    pfefefin IN DATE,
    pcagente IN NUMBER,
      pnrecibo IN NUMBER,
    pctipoper  IN NUMBER,
    mensajes OUT t_iax_mensajes)
    RETURN sys_refcursor;
--    
--Fin IAXIS-3651 09/07/2019   
--
END pac_md_gestion_rec;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_GESTION_REC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_GESTION_REC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_GESTION_REC" TO "PROGRAMADORESCSI";
