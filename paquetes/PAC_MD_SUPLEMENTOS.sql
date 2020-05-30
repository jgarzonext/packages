--------------------------------------------------------
--  DDL for Package PAC_MD_SUPLEMENTOS
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE PAC_MD_SUPLEMENTOS AS
/******************************************************************************
   NOMBRE:       PAC_MD_SUPLEMENTOS
   PROPÓSITO:  Permite crear suplementos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        07/02/2008   ACC                1. Creación del package.
   2.0        24/04/2009   RSC                2. Suplemento de cambio de forma de pago diferido
   3.0        10/11/2009   AMC                3. 0011695: CEM - Fecha de efecto de los suplementos por defecto
   4.0        21/01/2010   XPL                4. APR - En la consulta de pòlisses, fer que els motius de suplements permesos es recuperin dinàmicament de BD
   12.0       04/07/2011   JTS               12. 0017255: CRT003 - Definir propuestas de suplementos en productos
   13.0       15/07/2011   JTS               13. 0018926: MSGV003- Activar el suplement de canvi de forma de pagament
   14.0       06/11/2012   MDS               14. 0024278: LCOL_T010 - Suplementos diferidos - Cartera - colectivos
   15.0       13/11/2012   DRA               15. 0024271: LCOL_T010-LCOL - SUPLEMENTO DE TRASLADO DE VIGENCIA
   16.0       03/12/2012   APD               16. 0024278: LCOL_T010 - Suplementos diferidos - Cartera - colectivos
   17.0       21/02/2013   ECP               17. 0026070: LCOL_T010-LCOL - Revision incidencias qtracker (V) Nota 138777
   18.0       11/07/2013   RCL               18. 0023860: LCOL - Parametrización y suplementos - Vida Grupo
******************************************************************************/

   /*************************************************************************
      Borra los registros de las tablas est y cancela suplemento
      param in pestsseguro : código seguro en est
      param in pnmovimi    : número de movimiento nuevo
      parma in psseguro    : código seguro real
   *************************************************************************/
   PROCEDURE limpiartemporales(pestsseguro IN NUMBER, pnmovimi IN NUMBER, psseguro IN NUMBER);

   /*************************************************************************
      Función que valida si una póliza permite realizar un suplemento a una fecha determinada
      param in psseguro      : código del seguro
      param in pfefecto      : fecha efecto
      param in pcmotmov      : código movimiento
      param in out mensajes  : colección de mensajes
      return                 : 0 todo ha ido bien
                               1 se ha producido un error
   *************************************************************************/
   FUNCTION f_valida_poliza_permite_supl(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pcmotmov IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Función que obtiene la fecha de efecto del suplemento, y comprueba si
      un determinado usuario puede modificar dicga fecha de fefecto
      (por defecto F_SYSDATE y no modificable).
      Está comprobación se realiza según perfil del usuario.
      param in psseguro      : código del seguro
      param in pusuario      : usuario
      param out pmodfefe     : permite modificar fecha de efecto (0/1 -> No/Sí)
      param in out mensajes  : colección de mensajes
      return                 : 0 todo ha ido bien
                               1 se ha producido un error
   *************************************************************************/
   FUNCTION f_calc_fefecto_supl(
      psseguro IN NUMBER,
      pusuario IN VARCHAR2,
      pcmotmov IN NUMBER,   --JAMF 11695
      pfefecto OUT DATE,
      pmodfefe OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Función que obtiene la fecha de efecto del suplemento, préviamente calculada
      param in psseguro      : código del seguro
      param in pnmovimi      : Número de movimiento
      param out pfefecto     : fecha de efecto del suplemento
      param in out mensajes  : colección de mensajes
      return                 : 0 todo ha ido bien
                               1 se ha producido un error
   *************************************************************************/
   FUNCTION f_get_fefecto_supl(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto OUT DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Nos permite validar los cambios realizados en el suplemento
      param in psseguro      : código del seguro
      param in pnmovimi      : número movimiento
      param in      : código del seguro
      param in out mensajes  : colección de mensajes
      return                 : 0 todo ha ido bien
                               1 se ha producido un error
   *************************************************************************/
   FUNCTION f_validar_cambios(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      mensajes OUT t_iax_mensajes,
      pcmotmov IN NUMBER DEFAULT NULL)   -- Bug 20672 - RSC - 14/02/2012 - LCOL_T001-LCOL - UAT - TEC: Suplementos
      RETURN NUMBER;

   /*************************************************************************
      Nos permite editar una poliza en modo suplemento
      param in psseguro      : código del seguro
      param in pcmotmov      : código motivo de movimiento
      param in pfefecto      : fecha efecto suplemento
      param out onmovimi     : número movimiento
      param out osseguro     : código del seguro
      param in out mensajes  : colección de mensajes
      return                 : 0 todo ha ido bien
                               1 se ha producido un error
   *************************************************************************/
   FUNCTION f_editarsuplemento(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pfefecto IN DATE,
      onmovimi OUT NUMBER,
      osseguro OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Traspasa los datos de una propuesta de suplemento de las tablas EST a las REALES
      param in psseguro      : código del seguro
      param in out mensajes  : colección de mensajes
      return                 : 0 todo ha ido bien
                               1 se ha producido un error
   *************************************************************************/
   FUNCTION f_traspasarsuplemento(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Recupera el detalle del movimiento
      param in psseguro      : código del seguro
      param in pnmovimi      : número de movimiento
      param in pcidioma      : código idioma
      param in out mensajes  : colección de mensajes
      return                 : objeto detalle movimientos
   *************************************************************************/
   FUNCTION f_get_detailmov(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_detmovseguro;

   /*************************************************************************
      Recupera el detalle del movimiento
      param in psseguro      : código del seguro
      param in pnmovimi      : número de movimiento
      param in pfefecto      : fecha efecto suplemento se pasa para
                               devolverlo a JAVA pero puede ser nulo
      param in pcidioma      : código idioma
      param in out mensajes  : colección de mensajes
      return                 : objeto detalle movimientos
   *************************************************************************/
   FUNCTION f_get_detailmovsupl(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto IN DATE,
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_detmovseguro;

   /*************************************************************************
      Preproceso del suplemento
      param in plstmotmov    : lista motivos suplemento
      param in psseguro      : código del seguro
      param in out mensajes  : colección de mensajes
      return                 : 0 = todo ha ido bien
                               1 = se ha producido un error
   *************************************************************************/
   FUNCTION f_preprocesarsuplemento(
      plstmotmov IN OUT t_iax_motmovsuple,
      psseguro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Suplemento de canvio de forma de pago
      param in psseguro      : código del seguro
      param in out mensajes  : colección de mensajes
      return                 : 0 = todo ha ido bien
                               1 = se ha producido un error
   *************************************************************************/
   FUNCTION f_canvi_forpag(
      psseguro IN NUMBER,
      pcontrol OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Emitir suplemento
      param in psseguro      : código del seguro
      param in out mensajes  : colección de mensajes
      return                 : 0 = todo ha ido bien
                               1 = se ha producido un error
   *************************************************************************/
   FUNCTION f_emitir_suplemento(
      psseguro IN NUMBER,
      pvsseguro IN NUMBER,
      pemitesol IN BOOLEAN,   --BUG18926 - JTS - 15/07/2011
      pnmovimi OUT NUMBER,
      ponpoliza OUT NUMBER,
      posseguro OUT NUMBER,
      mensajes OUT t_iax_mensajes,
      pcommit NUMBER DEFAULT 1   -- Bug 26070 --ECP -- 21/02/2013
                              )
      RETURN NUMBER;

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
      Determina si dos códigos de movimiento son compatibles o no.

      param in pcmotmov1   : Código de movimiento 1
      param in pcmotmov2   : Código de movimiento 2

      return              : 0 no son compatibles
                            1 son compatibles
   *************************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_cmotmov_compatibles(pcmotmov1 IN NUMBER, pcmotmov2 IN NUMBER)
      RETURN NUMBER;

   -- Fin Bug 9905

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
      Obtiene de seguros el valor parametrizado en el campo
      PDS_SUPL_DIF_CONFIG.TFECREC. Si F_FCARPRO, obtendrá fcarpro, si
      F_FCARANU obtendrá fcaranu.

      param in ptfecrec   : Identificador de fecha de suplemento diferido.
      param in psseguro   : Identificador de seguro

      return              : DATE (fcaranu o fcarpro)
   *************************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_fecha_diferido(ptfecrec IN VARCHAR2, psseguro IN NUMBER)
      RETURN DATE;

   -- Fin Bug 9905

   /*************************************************************************
      Función que realiza el diferimiento de cambio de forma de pago.

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA de la selección
      param out mensajes   : Mensajes

      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_diferir_spl_formapago(
      poliza IN ob_iax_detpoliza,
      pfdifer IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Fin Bug 9905

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
      ppoliza IN ob_iax_detpoliza,
      ptexto OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Fin Bug 9905

   /*************************************************************************
      Función que realiza el diferimiento de modificación de garantias.

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA de la selección
      param out mensajes   : Mensajes

      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   -- Bug 9905 - 24/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_diferir_spl_garantias(
      poliza IN ob_iax_detpoliza,
      pfdifer IN VARCHAR2,
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


      param in psseguro     : Identificador de seguro
      param in pfecha       :
      param out mensajes    : Mensajes

      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   -- Bug 9905 - 30/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_habilita_diferir(
      psseguro IN NUMBER,
      pcmotmovs IN t_lista_id,
      pmostrar OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Fin Bug 9905

   /*************************************************************************
      Función que realiza el diferimiento de cambio de revalorización.

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA de la selección
      param out mensajes   : Mensajes

      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   -- Bug 9905 - 30/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_diferir_spl_revali(
      poliza IN ob_iax_detpoliza,
      pfdifer IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Fin Bug 9905

   /*************************************************************************
      Función que realiza el diferimiento de cambio de agente.

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA de la selección
      param out mensajes   : Mensajes

      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   -- Bug 9905 - 30/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_diferir_spl_agente(
      poliza IN ob_iax_detpoliza,
      pfdifer IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Fin Bug 9905

   /***********************************************************************
      Recupera los movimientos de suplementos diferidos de la póliza.

      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   -- Bug 9905 - 04/05/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_get_mvtdiferidos(psolicit IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

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
      pcmotmovs IN t_lista_id,
      pfechap OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       Función para averiguar si el botón Diferir debe o no debe mostrarse.

       param in psseguro     : Identificador de seguro
       param out mensajes    : Mensajes

       return              : 0 --> OK, <> 0 --> Error
    *************************************************************************/-- Bug 9905 - 30/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_mostrar_diferir(
      pcempres IN NUMBER,
      pmostrar OUT NUMBER,
      mensajes OUT t_iax_mensajes)
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
    Funcion para saber si un suplemento es incompatible
    param in psseguro : codigo del seguro
    param in pcmotmov : codigo del motivo del suplemento
    param out pcestado : estado del suplemento
    param out mensajes    : Mensajes
    retorno : 0 ok
              1 error

   -- Bug 116595 - 10/11/2009 - AMC
   *************************************************************************/
   FUNCTION f_supl_incompatible(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pcestado OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Funcion para buscar la fecha del suplemento de la configuración indicada en las PDS
    param in psproduc : codigo del producto
    param in psseguro : codigo del seguro
    param in pcmotmov : codigo del motivo del suplemento
    param out pfefecto : fecha de efecto
    param out mensajes    : Mensajes
    retorno : 0 ok
              1 error

   -- Bug 116595 - 10/11/2009 - AMC
   *************************************************************************/
   FUNCTION f_get_fsupl_pds(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pfefecto OUT DATE,
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
      mensajes IN OUT t_iax_mensajes,
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_traslado_vigencia(
      psseguro IN NUMBER,
      pcontrol OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-- Bug 24278 - APD - 03/11/2012 - se crea la funcion
/*******************************************************************************
   Funcion que ejecuta los suplementos diferidos/automaticos programados para
   un colectivo para un movimiento determinado
   psseguro PARAM IN : Seguro
   pnmovimi PARAM IN : Movimiento del suplemento
   psproces PARAM OUT : Proceso generado.
********************************************************************************/
   FUNCTION f_ejecuta_supl_certifs(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      psproces IN OUT NUMBER,
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
   opropaga PARAM OUT: 0.-No se propaga ningún suplemento
                       1.-Si se propaga algún suplemento
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
      mensajes IN OUT t_iax_mensajes)
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
      mensajes IN OUT t_iax_mensajes)
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
      mensajes IN OUT t_iax_mensajes)
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
      pcmotmov IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

     /*************************************************************************
    FUNCTION f_get_existe_garantia
    param out mensajes    : Mensajes
    retorno : 0 ok
              1 error
   *************************************************************************/
   FUNCTION f_get_existe_garantia(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      pmodo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

     /*************************************************************************
    FUNCTION f_get_nmovima_garantia
    param out mensajes    : Mensajes
    retorno : 0 ok
              1 error
   *************************************************************************/
   FUNCTION f_get_nmovima_garantia(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      pmodo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Función que realiza el diferimiento de la Alta de Amparos  (237)

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA de la selección
      param out mensajes   : Mensajes

      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   FUNCTION f_diferir_spl_alta_garan(
      poliza IN ob_iax_detpoliza,
      pfdifer IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

     /*************************************************************************
      Función que realiza el diferimiento de la Baja de Amparos  (239)

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA de la selección
      param out mensajes   : Mensajes

      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   FUNCTION f_diferir_spl_baja_garan(
      poliza IN ob_iax_detpoliza,
      pfdifer IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

       /*************************************************************************
      Función que realiza el diferimiento de modificación de garantias. (aumento de capitales 355)

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA de la selección
      param out mensajes   : Mensajes

      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   FUNCTION f_diferir_spl_aumento_cap(
      poliza IN ob_iax_detpoliza,
      pfdifer IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

      /*************************************************************************
      Función que realiza el diferimiento de modificación de garantias. (Disminución de capitales 356)

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA de la selección
      param out mensajes   : Mensajes

      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   FUNCTION f_diferir_spl_disminucion_cap(
      poliza IN ob_iax_detpoliza,
      pfdifer IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

     /*************************************************************************
      Función que realiza el diferimiento de modificación de preguntas de riesgo.

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA de la selección
      param out mensajes   : Mensajes

      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   FUNCTION f_diferir_spl_preguntas(
      poliza IN ob_iax_detpoliza,
      pfdifer IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

     /*************************************************************************
      Función que realiza el diferimiento de modificación de sobreprimas.

      param in ppoliza     : Objeto OB_IAX_DETPOLIZA de la selección
      param out mensajes   : Mensajes

      return              : 0 --> OK, <> 0 --> Error
   *************************************************************************/
   FUNCTION f_diferir_spl_sobreprimas(
      poliza IN ob_iax_detpoliza,
      pfdifer IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
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
END pac_md_suplementos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_SUPLEMENTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SUPLEMENTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SUPLEMENTOS" TO "PROGRAMADORESCSI";
