CREATE OR REPLACE PACKAGE pac_gestion_rec AS
   /******************************************************************************
      NOMBRE:      PAC_GESTION_REC
      PROPÓSITO:   Impresion de recibos
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        28/01/2009                   1. Creación del package.
      1.1        11/02/2009   FAL             1. Añadir funcionalidades de gestión de recibos. Bug: 0007657
      1.2        27/02/2009   MCC             1. Excel para la impresion del docket. Bug 009005: APR - docket para los brokers
      1.3        27/04/2009   JTS             9006: APR - Plantilla RTF pra la impresión de recibos manuales
      1.4        15/06/2009   JTS             Bug 10069
      1.9        04/09/2009   JTS             1. Bug 10529: Pantallas de recibos
      2          30/03/2009   XPL             2 13850: APRM00 - Lista de recibos por personas
      3          29/04/2010   LCF             4 14302 Campo descripción traspaso saldo
      5          25/05/2010   ICV             5. 14586: CRT - Añadir campo recibo compañia
      6.0        03/01/2012   JMF             6. 0020761 LCOL_A001- Quotes targetes
      7.0        18/07/2012   ICV             7. 0022960: LCOL_A003-Modificacion contable de la fecha de administracion una vez cerrado el mes
      8.0        07/08/2012   APD             8. 0022342: MDP_A001-Devoluciones
      9.0        12/09/2012   JGR             9. 0022763: MDP_A001-Unificacion / Desunificacion de recibos - 0119028
      10.0       25/10/2012   DRA             10. 0023853: LCOL - PRIMAS MÍNIMAS PACTADAS POR PÓLIZA Y POR COBRO
      11.0       25/11/2012   ETM             11.0029009: POSRA100-POS - Pantalla manual de recibos
      12.0       21/01/2014   JDS             12.0029603: POSRA300-Texto en la columna Pagador del Recibo para recibos de Colectivos
      13.0       02/06/2014   MMM             13.0028551: LCOLF3BADM-Id. 162 - Terminacion por no pago por convenio a nivel de intermediario
      14.0       09/07/2019   DFR             14. IAXIS-3651 Proceso calculo de comisiones de outsourcing
      15.0       15/07/2019   Shakti          15. IAXIS-4753 Ajuste campos Servicio L003
      16.0       01/08/2019   Shakti          16. IAXIS-4944 TAREAS CAMPOS LISTENER
   ******************************************************************************/

   --AAC_INI-CONF_379-20160927
   k_empresaaxis CONSTANT empresas.cempres%TYPE
                      := NVL(pac_md_common.f_get_cxtempresa, f_parinstalacion_n('EMPRESADEF'));


   k_idiomaaaxis CONSTANT per_detper.cidioma%TYPE
              := pac_parametros.f_parempresa_n(f_parinstalacion_n('EMPRESADEF'), 'IDIOMA_DEF');


   k_paisdefaxis CONSTANT provincias.cpais%TYPE := f_parinstalacion_n('PAIS_DEF');


   k_para_carga   cfg_files.cpara_error%TYPE;
   --AAC_FI-CONF_379-20160927
   /*******************************************************************************
      PROCESO proceso_batch_cierre
   Se ejecuta en los cierres, actualiza la FEFEADM DE RECIBOS
   ********************************************************************************/
   PROCEDURE proceso_batch_cierre(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE);

   /*******************************************************************************
      FUNCION f_importe_recibo
    Devuelve el importe de un recibo
      param in pnrecibo : Recibo
      return : NUMBER
   ********************************************************************************/
   FUNCTION f_importe_recibo(pnrecibo IN NUMBER)
      RETURN NUMBER;

   /*******************************************************************************
      FUNCION f_adresa
    Devuelve la direccion de una persona
      param in psperson : persona
      param in pcdomici : Codigo domicilio
      return : NUMBER
   ********************************************************************************/
   FUNCTION f_adresa(psperson IN NUMBER, pcdomici IN NUMBER)
      RETURN VARCHAR2;

   /*******************************************************************************
      FUNCION f_nom
    Devuelve el nombre y apellidos de una persona
      param in psperson : persona
      param in pcagente : agente
      return : NUMBER
   ********************************************************************************/
   FUNCTION f_nom(psperson IN NUMBER, pcagente IN NUMBER)
      RETURN VARCHAR2;

   /*******************************************************************************
      FUNCION f_poblac
    Devuelve el CP y la poblacion de una persona
      param in psperson : persona
      param in pcdomici : codigo domicilio
      return : NUMBER
   ********************************************************************************/
   FUNCTION f_poblac(psperson IN NUMBER, pcdomici IN NUMBER)
      RETURN VARCHAR2;

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
      return: number con el código de error.
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
      psproimp2 OUT NUMBER)
      RETURN NUMBER;

   /*******************************************************************************
                              FUNCION F_GET_IMPR_PENDIENTE_MAN
   Esta función retornará el conteniendo de la tabla tmp_recgestion para el proceso solicitado.
      param in psproimp : Codigo proceso
      param in pcidioma : Idioma
      param in pitotalr : Total recibo
      return: ref_cursor con los registros que cumplan con el criterio
   ********************************************************************************/
   FUNCTION f_get_impr_pendiente_man(
      psproimp IN NUMBER,
      pcidioma IN NUMBER,
      pitotalr OUT NUMBER)
      RETURN sys_refcursor;

   /*******************************************************************************
      FUNCION F_SET_IMPR_PENDIENTE_MAN
   Se actualizará el cestado de la tabla tmp_recgestion para el recibo y proceso informado por parámetro.
      param in psproimp : Codigo proceso
      param in pnrecibo : Recibo
      param in pcestado : Estado
      param out pitotalr : Total recibo
      return: NUMBER
   ********************************************************************************/
   FUNCTION f_set_impr_pendiente_man(
      psproimp IN NUMBER,
      pnrecibo IN NUMBER,
      pcestado IN NUMBER,
      pitotalr OUT NUMBER)
      RETURN NUMBER;

   /*******************************************************************************
      FUNCION F_CANCEL_IMPRESION_MAN
   Se borrará la tabla tmp_recgestion para el sproimp informado
     param in psproimp : codigo proceso
     return : NUMBER , un número con el id del error, en caso de que todo vaya OK, retornará un cero
   ********************************************************************************/
   FUNCTION f_cancel_impresion_man(psproimp IN NUMBER)
      RETURN NUMBER;

   /*******************************************************************************
      FUNCION F_IMPRESION_RECIBOS_MAN
   Función que imprimirá los recibos seleccionados.
     param in psproimp : Codigo proceso
     param in pcidioma : Codigo idioma
     param out pfichero : Ruta del fichero generado
     return : number un número con el id del error, en caso de que todo vaya OK, retornará un cero.
   ********************************************************************************/
   FUNCTION f_impresion_recibos_man(
      psproimp IN NUMBER,
      pcidioma IN NUMBER,
      pfichero OUT VARCHAR2,
      pcreafich IN NUMBER DEFAULT 1)
      RETURN NUMBER;

   /*******************************************************************************
      FUNCION F_IMPRESION_REGISTRO_MAN
   Función que lanza los reports de agente.
     param in pcagente : Codigo agente
     param in pdataini : Fecha Inicio
     param in pdatafin : Fecha Fin
     param in pcidioma : Codigo idioma
     param out pfichero: ruta del fichero generado --BUg 9005-MCC-Creacion fichero
     return : number un número con el id del error, en caso de que todo vaya OK, retornará un cero.
   ********************************************************************************/
   FUNCTION f_impresion_registro_man(
      pcagente IN NUMBER,
      pdataini IN DATE,
      pdatafin IN DATE,
      pcidioma IN NUMBER,
      pfichero1 OUT VARCHAR2,
      pfichero2 OUT VARCHAR2)   --Bug 9005 -01/03/2009- MCC- Apertura de ficheros para "NL" y para "FR"
      RETURN NUMBER;

   /*******************************************************************************
       FUNCION F_SELEC_TODOS_RECIBOS
   Se actualizará el cestado a 1 de todos los recibos la tabla tmp_recgestion para un proceso psproimp por parámetro.
     param in psproimp : Codigo proceso
     param in pitotalr : Total recibos
     return : NUMBER
   ********************************************************************************/
   FUNCTION f_selec_todos_recibos(psproimp IN NUMBER, pitotalr OUT NUMBER)
      RETURN NUMBER;

   /*******************************************************************************
      FUNCION F_DESSELEC_TODOS_RECIBOS
   Se actualizará el cestado a 0 de todos los recibos de la tabla tmp_recgestion para un proceso psproimp por parámetro.
     param in psproimp : Codigo proceso
     param in pitotalr : Total recibos
     return : NUMBER
   ********************************************************************************/
   FUNCTION f_desselec_todos_recibos(psproimp IN NUMBER, pitotalr OUT NUMBER)
      RETURN NUMBER;

/*-----------------------------------------------------------------------*/
/* Gestión manual de recibos                                             */
/* Bug: 0007657: IAX - Gestión de recibos                                            */
/* FAL                                              */
/*-----------------------------------------------------------------------*/

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
      return: number indicando código de error (0: sin errores)
   ********************************************************************************/
   FUNCTION f_cobro_recibo(
      pcempres IN NUMBER,
      pnrecibo IN NUMBER,
      pfmovini IN DATE,
      pctipban IN NUMBER,
      pcbancar IN VARCHAR2,
      pccobban IN NUMBER,
      pdelega IN NUMBER,
      pctipcob IN NUMBER DEFAULT 0,   -- Bug 10019 22/07/2009 ASN - APR - cobro de recibos por broker)
      
      pnreccaj IN VARCHAR2 DEFAULT NULL, -- INI -IAXIS-4153 - JLTS - 07/06/2019 nuevo parámetro /* Cambios de IAXIS-4753 */ 
      pcmreca IN NUMBER DEFAULT NULL, -- INI -IAXIS-4153 - JLTS - 07/06/2019 nuevo parámetro
       PCINDICAF IN VARCHAR2 DEFAULT NULL ,------Changes for 4944
      PCSUCURSAL IN VARCHAR2 DEFAULT NULL ,------Changes for 4944
      PNDOCSAP IN VARCHAR2 DEFAULT NULL, ------Changes for 4944
      pcususap IN VARCHAR2 DEFAULT NULL)------Changes for 4944
      RETURN NUMBER;

   /*******************************************************************************
       FUNCION F_ANULA_RECIBO
   Función que realiza la anulación de un recibo.
      param in pnrecibo : recibo
      param in pfanulac : fecha anulación
      param in pcmotanu : motivo anulación
      return: number indicando código de error (0: sin errores)
   ********************************************************************************/
   FUNCTION f_anula_recibo(pnrecibo IN NUMBER, pfanulac IN DATE, pcmotanu IN NUMBER)
      RETURN NUMBER;

   /*******************************************************************************
      FUNCION F_MODIFICA_RECIBO
   Función que realiza modificación en el recibo.
      param in pnrecibo : recibo
      param in pccobban : cobrador bancario
      param in pcbancar : cuenta bancaria
      param in pcgescob : gestor de cobro
      param in pcestimp : estado de impresión
      param in pcaccpre : código de acción preconcedida
      param in pcaccret : código de acción retenida
      param in ptobserv : texto de observaciones
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
      pcgescar IN NUMBER DEFAULT NULL
      --AAC_FI-CONF_OUTSOURCING-20160906
      )
      RETURN NUMBER;

   /*******************************************************************************
      FUNCION F_ANULACION_PENDIENTE
   Función que marca un recibo como pendiente de anulación
      param in pnrecibo : recibo
      return: number indicando código de error (0: sin errores)
   ********************************************************************************/
   FUNCTION f_anulacion_pendiente(pnrecibo IN NUMBER)
      RETURN NUMBER;

   /*******************************************************************************
      FUNCION F_VALIDA_COBRO
   Función que valida si el recibo pertenece a la empresa: pempresa
      param in pempresa : empresa
      param in pnrecibo : recibo
      return: number indicando código de error (0: sin errores)
   ********************************************************************************/
   FUNCTION f_valida_cobro(pempresa IN NUMBER, pnrecibo IN NUMBER)
      RETURN NUMBER;

   /****************************************************************************
       Función para agrupar (unificar) recibos.
    Esta función tiene dos modalidades:
        1.- Agrupación de recibos de cartera con marcador CESTAUX = 2 anteriores
        a una fecha.
        2.- Agrupación de recibos pasados por parámetro (todavia sin desarrollar)
   ****************************************************************************/
   FUNCTION f_agruparecibo(
      psproduc IN NUMBER,
      pfecha IN DATE,
      pfemisio IN DATE,
      pcempres IN NUMBER,
      plistarec IN t_lista_id DEFAULT NULL,
      pctiprec IN NUMBER DEFAULT 3,
      pextornn IN NUMBER DEFAULT 0,
      pcommitpag IN NUMBER DEFAULT 1,
      pctipapor IN NUMBER DEFAULT NULL,
      pctipaportante IN NUMBER DEFAULT NULL)   --Bug.: 15708 - ICV - 08/06/2011 - Se añade el tipo de recibo para poder agrupar recibos que no sean de cartera
      RETURN NUMBER;

   /****************************************************************************
        Función que nos dirá si un recibo es o no agrupado.
   ****************************************************************************/
   FUNCTION f_recunif(pnrecibo IN NUMBER)
      RETURN NUMBER;

   /****************************************************************************
          Función que nos dirá si un recibo es padre o no
       param in pnrecibo  : Codigo de recibo
       return           : NUMBER
     ****************************************************************************/
   FUNCTION f_recunif_list(pnrecibo IN NUMBER)
      RETURN NUMBER;

   /*******************************************************************************
      FUNCION f_get_anula_pend
   Función que recupera si un recibo está marcado como pendiente de anulación ó está desmarcado
      param in pnrecibo : recibo
      return: number indicando si el recibo esta marcado como pendiente de anulación
   ********************************************************************************/
   FUNCTION f_get_anula_pend(pnrecibo IN NUMBER)
      RETURN NUMBER;

   /*******************************************************************************
      FUNCION F_GET_ACCIONES
   Función que recupera las acciones posibles a realizar sobre un recibo en función del estado del recibo y configuración del usuario
      param in pnrecibo : recibo
      param in psproduc : código producto
      return: sysrefcursor con las posibles acciones a realizar
   ********************************************************************************/
   FUNCTION f_get_acciones(
      pnrecibo IN NUMBER,
      psproduc IN NUMBER,
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      pcusuari IN VARCHAR2,
      psaltar OUT NUMBER)
      RETURN sys_refcursor;

   --BUG 10069 - 15/06/2009 - JTS
   /*******************************************************************************
      FUNCION F_COBRO_RECIBO_ONLINE
   Función que realiza el cobro online
      param in pcempres : empres
      param in pnrecibo : recibo
      param in pterminal : terminal
      param out pcobrado : cobrado
      param out psinterf : interficie
      param out perror : error
      return: 0.- OK, Otros.- KO
   ********************************************************************************/
   FUNCTION f_cobro_recibo_online(
      pcempresa IN NUMBER,
      pnrecibo IN NUMBER,
      pterminal IN VARCHAR2,
      pcobrado OUT NUMBER,
      psinterf OUT NUMBER,
      perror OUT VARCHAR2,
      pusuario IN VARCHAR2)
      RETURN NUMBER;

   --Fi BUG 10069 - 15/06/2009 - JTS

   /*******************************************************************************
       FUNCION F_COBRADOR_REC
    Función que retorna el cobrador bancario para un recibo
       param in pnrecibo : recibo
       param out pselect : select con los cobradores
       return: 0.- OK, Otros.- KO
    --BUG 10529 - 04/09/2009 - JTS
   ********************************************************************************/
   FUNCTION f_cobrador_rec(pnrecibo IN NUMBER, pselect OUT VARCHAR2)
      RETURN NUMBER;

   /*******************************************************************************
      FUNCION F_get_saldo_inicial
   Función que recupera el saldo de un recibo
      param in pnrecibo : recibo
      param out pisaldo : importe total
      return: number, 0 OK 1 KO
   ********************************************************************************/
   FUNCTION f_get_saldo_inicial(pnrecibo IN NUMBER, pisaldo OUT NUMBER)
      RETURN NUMBER;

   /*******************************************************************************
      FUNCION f_transferir
   Función que se encarga de transferir el importe al recibo
   destino y de cobrar el recibo destino si fuese necesario
      param in pnrecibo_origen : recibo origen
      param in pnrecibo_destino : recibo destino
      param out pisaldo : importe total
      return: number, 0 OK 1 KO
   ********************************************************************************/
   FUNCTION f_transferir(
      pnrecibo_origen IN NUMBER,
      pnrecibo_destino IN NUMBER,
      pisaldo IN NUMBER,
      ptdescrip IN VARCHAR2)   --BUG 14302 - 28/04/2010 - LCF
      RETURN NUMBER;

   /*******************************************************************************
       FUNCION f_get_rebtom
   Función que se encarga de devolver los recibos del tomador en los ultimos 5 años
      param in sperson : seq. persona a buscar
      param out pipagado : importe de todos los recibos cobrados
      param out pipendiente : importe de todos los recibos pendientes
      param out pimpagados : importe de todos los recibos impagados
      param out pquery  : Query a devolver
      return: number, 0 OK 1 KO
      30/03/2009#XPL#13850: APRM00 - Lista de recibos por personas
   ********************************************************************************/
   FUNCTION f_get_rebtom(
      psperson IN NUMBER,
      pcempres IN NUMBER,
      pidioma IN NUMBER,
      pipagado OUT NUMBER,
      pipendiente OUT NUMBER,
      pimpagado OUT NUMBER,
      pisaldo OUT NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

   --BUG16992 - JTS - 18/11/2010
   FUNCTION f_set_reccbancar(pnrecibo IN NUMBER, pcbancar IN VARCHAR2, pctipban IN NUMBER)
      RETURN NUMBER;

   --Bug.: 18632 - ICV - 07/06/2011
   FUNCTION f_set_aportante(
      pnrecibo IN NUMBER,
      pctipapor IN NUMBER,
      psperapor IN NUMBER,
      ptipoaportante IN NUMBER)
      RETURN NUMBER;

      /***********************************************************************************************************
           F_REHABILITA_REC. Funci¿n que rehabilita un recibo.
        pnrecibo: Recibo que queremos anular
        pfrehabi: Fecha de efecto de rehabilitacion del recibo
        psmovagr: agrupaci¿n de recibos por remesa. Si es null se incrementa la secuencia
        Bug 18908/93215 - 05/10/2011 - AMC
   **********************************************************************************************************/
   FUNCTION f_rehabilita_rec(
      pnrecibo IN NUMBER,
      pfrehabi IN DATE,
      psmovagr IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

      /*******************************************************************************
          FUNCION F_GET_TOMRECIBO
       Función que devuelve el tomador de un recibo
      param in pnrecibo : recibo
      param out pspertom   : identificador del tomador
      return: number indicando código de error (0: sin errores)
      Bug 20012/96897 - 11/11/2011 - AMC
   ********************************************************************************/
   FUNCTION f_get_tomrecibo(pnrecibo IN NUMBER, pspertom OUT NUMBER)
      RETURN NUMBER;

   /*******************************************************************************
      FUNCION F_MODIFICA_ACCPRECONOCIDA
   Función que realiza modificación en el recibo complementario.
      param in pnrecibo : recibo
      param in pcaccpre : código de acción preconocida
      return: number indicando código de error (0: sin errores)
      Bug 22342 - 11/06/2012 - APD
   ********************************************************************************/
   FUNCTION f_modifica_accpreconocida(pnrecibo IN NUMBER, pcaccpre IN NUMBER)
      RETURN NUMBER;

   -- 9. 0022763: MDP_A001-Unificacion / Desunificacion de recibos - 0119028 - Inicio
   /*******************************************************************************
      FUNCION PAC_GESTION_REC.F_DESAGRUPARECIBO
   Función que realiza la desunificación de recibos y opcionalmente anula el recibo.
   Cuando el PFANULAC está informado (IS NOT NULL).
   Parámetros:
     param in pnrecunif : Número del recibo agrupado
     param in pfanulac : Fecha de anulación
     param in pcidioma : Código de idioma
     return: number un número con el id del error, en caso de que todo vaya OK, retornará un cero.
   ********************************************************************************/
   FUNCTION f_desagruparecibo(
      pnrecunif IN NUMBER,
      pfanulac IN DATE DEFAULT NULL,
      pcidioma IN NUMBER DEFAULT NULL)
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
      ptablas IN VARCHAR2 DEFAULT 'SEG')
      RETURN NUMBER;

   FUNCTION f_desctiprec(pnrecibo IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- BUG23853:DRA:25/10/2012:Fi

   -- 23074 - JLB: 17/12/2012
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
      ptablas IN VARCHAR2 DEFAULT 'SEG')
      RETURN NUMBER;

   -- Bug 27057/0145439 - APD - 04/06/2013 - se crea la funcion
   FUNCTION f_borra_recibo(pnrecibo IN NUMBER, pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER;

   -- BUG 29009 -- ETM -- 25/11/2013 -- INI
   FUNCTION f_recman_pens(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pctiprec IN NUMBER,
      pimporte IN NUMBER,
      pctipcob IN NUMBER)
      RETURN NUMBER;

-- FIN  BUG 29009 -- ETM -- 25/11/2013

   -- BUG 29603 -- JDS -- 21/01/2014 -- INI
/*******************************************************************************
FUNCION f_desctippag
Función que devolverá el literal del pagador del recibo.
param in pnrecibo
param in pcidioma
********************************************************************************/
   FUNCTION f_desctippag(pnrecibo IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

-- FIN  BUG 29603 -- JDS -- 21/01/2014

   --BUG 0029706: ENSA998-Estancia en Luanda
   FUNCTION f_get_tipo_rec(piidioma IN NUMBER, pnrecibo IN NUMBER)
      RETURN VARCHAR2;

--FIn   BUG 0029706: ENSA998-Estancia en Luanda

   -- 13.0 - 02/06/2014 - MMM - 0028551: LCOLF3BADM-Id. 162 - Terminacion por no pago por convenio a nivel de intermediario - Inicio
   /*******************************************************************************
   FUNCION f_get_lista_dias_gracia
   Funcion que devuelve un cursor con los registros de parametrizacion de dias de gracia,
   dado un codigo de agente y producto
   param in pcagente
   param in psproduc
   ********************************************************************************/
   FUNCTION f_get_lista_dias_gracia(pcagente IN NUMBER, psproduc IN NUMBER)
      RETURN sys_refcursor;

   /*******************************************************************************
    FUNCION f_set_dias_gracia_agente_prod
    Funcion que inserta un registro de parametrizacion de dias de gracia, dado un
    agente y producto
    param in pcagente
    param in psproduc
    pfini in DATE
    pdias in NUMBER
    ********************************************************************************/
   FUNCTION f_set_dias_gracia_agente_prod(
      pcagente IN NUMBER,
      psproduc IN NUMBER,
      pfini IN DATE,
      pdias IN NUMBER)
      RETURN NUMBER;

   /*******************************************************************************
   FUNCION f_del_dias_gracia_agente_prod
   Funcion que borra un registro de parametrizacion de dias de gracia, dado un
   agente y producto, asi como fecha de inicio
   param in pcagente
   param in psproduc
   pfini in DATE
   ********************************************************************************/
   FUNCTION f_del_dias_gracia_agente_prod(
      pcagente IN NUMBER,
      psproduc IN NUMBER,
      pfini IN DATE)
      RETURN NUMBER;
-- 13.0 - 02/06/2014 - MMM - 0028551: LCOLF3BADM-Id. 162 - Terminacion por no pago por convenio a nivel de intermediario - Fin

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
			abrecibo    IN     NUMBER,
            soferta     IN     NUMBER,
            pcmodif     IN     NUMBER,
            ppdlegal    IN     NUMBER,
            ppjudi      IN     NUMBER,
            ppgunica    IN     NUMBER,
            ppestatal   IN     NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER;
FUNCTION F_ESTADO_RECIBO(
          pnrecibo IN NUMBER )
     RETURN VARCHAR2;


FUNCTION f_set_anula_x_no_pago(
			pnrecibo IN NUMBER,
      pccheck IN NUMBER)
	RETURN NUMBER;




	--AAC_INI-CONF_379-20160927
   FUNCTION f_liquidar_carga_corte_fac(
			 psproces	IN	NUMBER,
			 p_cproces	IN	NUMBER
	)   RETURN NUMBER;


  	PROCEDURE p_genera_logs(
			p_tabobj	IN	VARCHAR2,
			p_tabtra	IN	NUMBER,
			p_tabdes	IN	VARCHAR2,
			p_taberr	IN	VARCHAR2,
			p_propro	IN	NUMBER,
			p_protxt	IN	VARCHAR2
	);


  	FUNCTION p_marcalinea(
			p_pro	IN	NUMBER,
			p_lin	IN	NUMBER,
			p_tip	IN	NUMBER,
			p_est	IN	NUMBER,
			p_val	IN	NUMBER,
			p_seg	IN	NUMBER,
			p_id_ext	IN	VARCHAR2,
			p_ncarg	IN	NUMBER,
			p_sin	IN	NUMBER DEFAULT NULL,
			p_tra	IN	NUMBER DEFAULT NULL,
			p_per	IN	NUMBER DEFAULT NULL,
			p_rec	IN	NUMBER DEFAULT NULL
	) RETURN NUMBER;


  	FUNCTION p_marcalineaerror(
			p_pro	IN	NUMBER,
			p_lin	IN	NUMBER,
			p_ner	IN	NUMBER,
			p_tip	IN	NUMBER,
			p_cod	IN	NUMBER,
			p_men	IN	VARCHAR2
	) RETURN NUMBER;
--AAC_FI-CONF_379-20160927
--     
-- Inicio IAXIS-3651 09/07/2019
--
/*******************************************************************************
 FUNCION f_get_liquidacion
 Función que obtiene los recibos a liquidar para un outsourcing especificado.
 param in pnumide   -> Número de identificación del tomador/outsourcing
 param in pcestgest -> Estado de la liquidación liquidado/pendiente
 param in pfefeini  -> Fecha inicio de efecto
 param in pfefefin  -> Fecha fin de efecto
 param in pnrecibo  -> Número de recibo 
 param in pctipoper -> Tipo de persona tomador/outsourcing 
 ********************************************************************************/
FUNCTION f_get_liquidacion(
  pnumidetom IN VARCHAR2,
  pcestgest IN NUMBER,
  pfefeini IN DATE,
  pfefefin IN DATE,
  pcagente IN NUMBER,
  pnrecibo IN NUMBER,
  pctipoper  IN NUMBER,
  mensajes OUT t_iax_mensajes)
  RETURN VARCHAR2;

/*******************************************************************************
 FUNCION f_get_imp_pnd_liq
 Función que obtiene el importe gestionado por el outsourcing pendiente de liquidar
 param in pnrecibo  -> Número de recibo 
 param in pfgesrec  -> Fecha de primera gestión del outsourcing
 ******************************************************************************/
FUNCTION f_get_imp_pnd_liq(
   pnrecibo    IN NUMBER,
   pfgesrec    IN DATE)
   RETURN NUMBER;

/*******************************************************************************
 FUNCION f_get_imp_ges_out
 Función que obtiene el importe gestionado por el outsourcing
 param in pnrecibo  -> Número de recibo 
 param in pfgesrec  -> Fecha de primera gestión del outsourcing
 ******************************************************************************/
FUNCTION f_get_imp_ges_out(
   pnrecibo    IN NUMBER,
   pfgesrec    IN DATE)
   RETURN NUMBER;   
--     
-- Fin IAXIS-3651 09/07/2019
--
END pac_gestion_rec;
/
