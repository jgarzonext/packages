--------------------------------------------------------
--  DDL for Package PAC_IAX_SUPLEMENTOS
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "PAC_IAX_SUPLEMENTOS" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_SUPLEMENTOS
   PROPÓSITO:  Permite crear suplementos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        07/02/2008   ACC                1. Creación del package.
   2.0        24/04/2009   RSC                2. Suplemento de cambio de forma de pago diferido
   3.0        21/01/2010   XPL                3. APR - En la consulta de pòlisses, fer que els motius de suplements permesos es recuperin dinàmicament de BD
  12.0        04/07/2011   JTS               12. 0017255: CRT003 - Definir propuestas de suplementos en productos
  13.0        03/12/2012   APD               13. 0024278: LCOL_T010 - Suplementos diferidos - Cartera - colectivos
  14.0        04/02/2013   DRA               14. 0024726: (POSDE600)-Desarrollo-GAPS Tecnico-Id 32 - Anexos de cambio de valor rentas e Inclusion de Beneficiario
  15.0        11/07/2013   RCL               15. 0023860: LCOL - Parametrización y suplementos - Vida Grupo
  16.0        23/01/2018   JLTS              16. BUG CONF-1243 QT_724 - 23/01/2018 - Grabar datos de fechas para Vigencia Amparos (SUPLEMENTO 918)
  17.0        16/04/2019   CJMR              17. IAXIS-3394:  Ajustes Traslado de vigencias
******************************************************************************/
   lstmotmov      t_iax_motmovsuple;

   /*************************************************************************
      Función que devuelve si el suplemento esta pendiente de emitir
      return : 1 esta pendiente de emitir
               0 ha sido emitido
   *************************************************************************/
   FUNCTION f_get_pendiente_emision
      RETURN NUMBER;

   /*************************************************************************
      Procedimiento que modifica si el suplemento esta pendiente de emitir
   *************************************************************************/
   PROCEDURE p_set_pendiente_emision(pvalue NUMBER);

   /*************************************************************************
      Borra los registros de las tablas est y cancela el suplemento
   *************************************************************************/
   PROCEDURE limpiartemporales;

   /*************************************************************************
      Nos permite inicializar un seguro para realizar suplementos
      param in psseguro    : código del seguro
      param in pcmotmov    : código movimiento           (puede ser nulo => validación genérica)
      param out pfefecto   : fecha de efecto del suplemento.
      param out pmodfefe   : permite modificar fecha efecto del suplemento (0/1).
      param out mensajes   : colección de mensajes
      return               : 0 todo ha ido bien
                             1 se ha producido un error
   *************************************************************************/
   FUNCTION f_inicializar_suplemento(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pfefecto OUT DATE,
      pmodfefe OUT NUMBER,
      pmodo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Nos permite editar una poliza en modo suplemento
      param in psseguro      : código del seguro
      param in pcmotmov      : código motivo de movimiento
      param in out mensajes  : colección de mensajes
      return                 : 0 todo ha ido bien
                               1 se ha producido un error
   *************************************************************************/
  FUNCTION f_editarsuplemento(psseguro IN NUMBER, pfefecto IN DATE, pcmotmov IN NUMBER, pestsseguro OUT NUMBER,
                              mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
      Emitimos la propuesta de suplemento
      param in out mensajes  : colección de mensajes
      return                 : 0 todo ha ido bien
                               1 se ha producido un error
   *************************************************************************/
   FUNCTION f_emitirpropuesta(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Recupera el detalle del movimiento
      param in psseguro      : código del seguro
      param in pnmovimi      : número de movimiento
      param in out mensajes  : colección de mensajes
      return                 : objeto detalle movimientos
   *************************************************************************/
   FUNCTION f_get_detailmov(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_detmovseguro;

   /*************************************************************************
      Recupera el detalle del movimiento del suplemento para tablas EST
      param in out mensajes  : colección de mensajes
      return                 : objeto detalle movimientos
   *************************************************************************/
   FUNCTION f_get_detailmovsupl(pcmotmov IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_detmovseguro;

   /*************************************************************************
      Recupera los motivos de retención de la póliza
      param out mensajes  : colección de mensajes
      return                 : objeto lista motivos póliza retenida
   *************************************************************************/
   FUNCTION f_get_mvtretencion(mensajes OUT t_iax_mensajes)
      RETURN t_iax_polmvtreten;

   --ACC 13122008
   /*************************************************************************
      Anula el riesgo especificado
      param in psseguro   : número seguro tablas est
      param in pnriesgo   : número de riesgo
      param in pfanulac   : fecha anulación
      param in pnmovimi   : número movimiento
      param in pssegpol   : número seguro real
      param out mensajes  : colección de mensajes
      return              : objeto lista motivos póliza retenida
      return              : 0 todo ha ido bien
                            1 se ha producido un error
   *************************************************************************/
   FUNCTION f_anular_riesgo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfanulac IN DATE,
      pnmovimi IN NUMBER,
      pssegpol IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

--ACC 13122008

   /*************************************************************************
      Obtiene la lista de motivos de movimiento implicados en una modificación
      generada por un suplemento seleccionado por pantalla.


      param in psseguro   : Identificador de seguro
      param in pnmovimi   : Identificador de movimiento (suplemento)
      param out pcmotmovs : Lista de motivos.
      param out mensajes  : Mensajes.

      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_get_diferir_cmotmovs(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pcmotmovs OUT t_lista_id,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Fin Bug 9905

   /*************************************************************************
      Determina si dos códigos de movimiento son compatibles o no.

      param in pcmotmov1   : Código de movimiento 1
      param in pcmotmov2   : Código de movimiento 2

      return              : 0 no son compatibles
                            1 son compatibles
   *************************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_cmotmov_compatibles(pcmotmovs IN t_lista_id, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Fin Bug 9905

   /*************************************************************************
      Realiza el diferimiento de suplemento tratando cada motivo de movimiento
      seleccionado y difiriendolo.

      param in pcmotmovs   : Lista de motivos de movimiento implicados.
      param in ppoliza     : Objeto OB_IAX_DETPOLIZA de la selección.
      param out mensajes   : Mensajes.
      return               : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_tratar_diferidos_motmov(
      pcmotmovs IN t_lista_id,
      ppoliza IN ob_iax_detpoliza,
      pfdifer IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Fin Bug 9905

   /*************************************************************************
      Funcion inicial que arranca todo el proceso de diferimiento de suplemento.

      param out mensajes   : Mensajes.
      return               : 0 no son compatibles
                             1 son compatibles
   *************************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_diferirpropuesta(pfdifer IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      A la hora de emitir un suplemento se debe validar si existen suplementos
      diferidos que coincidan con el suplemento que se está realizando, en cuyo caso,
      se deberá de informar un mensaje y revisar los suplemento diferidos.

      param in pcmotmovs   : Lista de motivos de movimiento.
      param in ppoliza     : Objeto OB_IAX_DETPOLIZA de la selección
      param out ptexto     : Variable que almacena todos los mensajes de incompatibilidad.
      param out mensajes  : Mensajes.

      return              : 0 --> OK, 1 --> Error
   *************************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_valida_emision_diferidos(
      pcmotmovs IN t_lista_id,
      ppoliza ob_iax_detpoliza,
      ptexto OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Fin Bug 9905

   /*************************************************************************
      Evalua si un seguro debe diferir algun suplemento en el futuro.

      param in psseguro     : Objeto OB_IAX_DETPOLIZA de la selección
      param in ppoliza     : Objeto OB_IAX_DETPOLIZA de la selección
      param out mensajes   : Mensajes

      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   -- Bug 9905 - 29/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_eval_diferidos_futuro(
      psseguro IN NUMBER,
      pfecha IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Fin Bug 9905

   /*************************************************************************
      Función para averiguar si el botón Diferir debe o no debe estar
      habilitado.

      param in psseguro     : Identificador de seguro
      param in pfecha       :
      param out mensajes    : Mensajes

      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   -- Bug 9905 - 30/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_habilita_diferir(
      psseguro IN NUMBER,
      pmostrar OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Fin Bug 9905

   /***********************************************************************
      Recupera los movimientos de suplementos diferidos de la póliza.

      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   -- Bug 9905 - 04/05/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_get_mvtdiferidos(psolicit IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- Fin Bug 9905

   /*************************************************************************
      Función para marcar el radio button de fecha de diferimiento por defecto
      al diferir.

      param in psseguro     : Identificador de seguro
      param in pfecha       :
      param out mensajes    : Mensajes

      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   -- Bug 9905 - 04/05/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_get_fecha_diferir(
      psseguro IN NUMBER,
      pfechap OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       Función para averiguar si el botón Diferir debe o no debe mostrarse.

       param out pmostrar    : Indicador de si debe o no mostrar el botón Diferir.
       param out mensajes    : Mensajes
       return              : 0 --> OK, <> 0 --> Error
    *************************************************************************/-- Bug 9905 - 05/05/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_mostrar_diferir(pmostrar OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       Función para realizar la anulación de un diferimiento previamente
       programado. (Desde consulta de póliza)

       param in pcmotmov     : Identificador de motivo de movimiento.
       param in psseguro     : Identificador de contrato
       param out mensajes    : Mensajes
       return              : 0 --> OK, <> 0 --> Error
    *************************************************************************/-- Bug 9905 - 05/05/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_anular_abrir_diferido(
      pcmotmov IN NUMBER,
      psseguro IN NUMBER,
      pestado IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Funcion que recupera los diferentes suplementos permitidos para cada producto y empresa
    param in psproduc : codigo del producto
    param out pcurconfigsupl : Cursor con los suplementos permitidos
    param out mensajes    : Mensajes
    param in psseguro   : sseguro (default NULL)
    param in ptablas    : tipo tablas (default NULL)
    retorno : 0 ok
              1 error
   -- Bug 10781 - 21/01/2010 - XPL
   *************************************************************************/
   FUNCTION f_get_suplementos(
      psproduc IN NUMBER,
      pcurconfigsupl OUT sys_refcursor,
      mensajes OUT t_iax_mensajes,
      psseguro IN NUMBER DEFAULT NULL,
      ptablas IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
    FUNCTION f_insdetmovseguro
    param out mensajes    : Mensajes
    retorno : 0 ok
              1 error
   -- Bug 17255 - 05/07/2011 - JTS
   *************************************************************************/
   FUNCTION f_insdetmovseguro(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pnmovimi IN NUMBER,
      pdespues IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- Bug 24278 - APD - 03/11/2012 - se crea la funcion
/*******************************************************************************
   Funcion que ejecuta los suplementos diferidos/automaticos programados para
   un colectivo para un movimiento determinado
   psseguro PARAM IN : Seguro
   pnmovimi PARAM IN : Movimiento del suplemento
 *******************************************************************************/
   FUNCTION f_ejecuta_supl_certifs(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Bug 24278 - APD - 10/12/2012 - se crea la funcion
/*******************************************************************************
   Funcion que pregunta si se existe algun suplemento que se debe propagar
   ptablas PARAM IN : EST o REA
   psseguro PARAM IN : Seguro
   pnmovimi PARAM IN : Movimiento del suplemento
   pcvalpar PARAM IN : Valor del parmotmov
   pcmotmov PARAM IN : Motivo
   pcidioma PARAM IN : Idioma
   opropaga PARAM OUT: 0.-No se propaga ning?plemento
                       1.-Si se propaga alg?plemento
   otexto PARAM OUT : Texto de la pregunta que se le realiza al usuario
                      (solo para el caso cvalpar = 2)
********************************************************************************/
   FUNCTION f_pregunta_propaga_suplemento(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pcmotmov IN NUMBER,
      pcidioma IN NUMBER,
      opropaga OUT NUMBER,
      otexto OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- Bug 24278 - APD - 11/12/2012 - se crea la funcion
/*******************************************************************************
   Funcion que actualiza el valor del campo detmovseguro.cpropagasupl
   ptablas PARAM IN : EST o REA
   psseguro PARAM IN : Seguro
   pnmovimi PARAM IN : Movimiento del suplemento
   pcmotmov PARAM IN : Motivo
   pcpropagasupl PARAM IN : Valor que indica si se propaga el suplemento a sus certificado
                            en funcion de la decision del usuario
********************************************************************************/
   FUNCTION f_set_propaga_suplemento(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pcmotmov IN NUMBER,
      pcpropagasupl IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
     FUNCTION f_instexmovseguro
     param out mensajes    : Mensajes
     retorno : 0 ok
               1 error
    *************************************************************************/
   FUNCTION f_instexmovseguro(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      ptmovimi IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    FUNCTION f_ins_est_suspension
    param out mensajes    : Mensajes
    retorno : 0 ok
              1 error
   *************************************************************************/
   FUNCTION f_ins_est_suspension(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pcmotmov IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    FUNCTION f_ins_est_suspension
    param in psseguro
    param in pnmovimi
    retorno : 0 ok 1 error

    Bug 29358/162059 - 24/12/2013 - AMC
   *************************************************************************/
   FUNCTION f_lanzaproceso_diferidos(psseguro IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    FUNCTION f_get_descmotmov
    param in pcmotmov
    param in pcidioma
    param out ptmotmov
    param out mensajes
    retorno : 0 ok 1 error

    Bug 36507  215507 - 16/10/2015 - KJSC
   *************************************************************************/
   FUNCTION f_get_descmotmov(
      pcmotmov IN NUMBER,
      pcidioma IN NUMBER,
      ptmotmov OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    FUNCTION f_traslada_vigencia
    Función que traslada la vigencia de una póliza de acuerdo a la nueva fecha de efecto
    param in pfefetrasvig
    retorno : 0 ok 1 error

    IAXIS-3394 CJMR 16/04/2019
   *************************************************************************/
   FUNCTION f_traslada_vigencia(
      pndias       IN NUMBER,
      pnmeses      IN NUMBER,
      pnanios      IN NUMBER,
      mensajes     OUT t_iax_mensajes)
      RETURN NUMBER;

END pac_iax_suplementos;

/