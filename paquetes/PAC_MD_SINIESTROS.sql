create or replace PACKAGE "PAC_MD_SINIESTROS" AS
/******************************************************************************
   NOMBRE:     PAC_MD_SINIESTROS
   PROPÃƒâ€œSITO:  Funciones para la gestiÃƒÂ³n de siniestros

   REVISIONES:
   Ver        Fecha        Autor             DescripciÃƒÂ³n
   ---------  ----------  ---------------  ------------------------------------
   1.0        17/02/2009   XPL i XVM        1. CreaciÃƒÂ³n del package.
   2.0        28/09/2009   DCT              1. Bug 10393 Crear parametrizaciÃƒÂ³n de documentacion a solicitar por producto/causa/motivo
   3.0        23/11/2009   AMC              3. 0011847: AGA - Error al introducir detalle recobro en siniestro
   4.0        08/01/2010   AMC              4. 0012604: CEM - Agenda de siniestros da error
   5.0        15/01/2010   AMC              5. Bug 11945 - AGA - Crear columna PrevisiÃƒÂ³n Recobro para siniestros
   6.0        18/01/2010   AMC              6  Bug 12753 - CEM - CreaciÃƒÂ³n automÃƒÂ¡tica de destinatario
   7.0        20/01/2010   AMC              7. Bug 11849 - CEM - Crear botÃƒÂ³n generaciÃƒÂ³n pago automÃƒÂ¡tico en siniestros
   8.0        02/02/2010   LCF              8. Bug 10093 - CRE - Anyadir filtros ramo en buscadores pÃƒÂ³liza
   9.0        01/02/2010   AMC              9. Bug 12207 - AGA - IntroducciÃƒÂ³n de reservas en productos de Baja (Salud)
   10.0       15/02/2010   AMC              10. Bug 13166 - CRE - Se crea la funciÃƒÂ³n f_del_mov paggar para borrar el detalle de los pagos/recobros
   11.0       24/02/2010   AMC              11. Bug 12668 - AGA - NormalizaciÃƒÂ³n riesgo tipo direcciÃƒÂ³n
   12.0       18/05/2010   AMC              12. Bug 14490 - AGA - Se aÃƒÂ±ade los parametros pnmovres,psproduc,pcactivi
   13.0       31/05/2010   XPL              13. bug : 14607, AGA004 - Conceptos de pago a nivel de detalle del pago de un siniestro
   14.0       03/06/2010   AMC              14. Bug 14766 Se aÃƒÂ±aden nuevas funciones
   15.0       23/06/2010   AMC              15. Bug 15153 Se aÃƒÂ±aden nuevas funciones
   16.0       10/09/2010   SRA              16. Bug 15965 - CRT - Se crea nueva funciÃƒÂ³n PAC_IAX_SINIESTROS.F_CONSULTA_LSTSINI_RIESGO
   17.0       30/10/2010   JRH              17. BUG 15669 : Campos nuevos
   17.0       08/11/2010   XPL              17. 15044: AGA202 - Crear pantalla para pagos de rentas
   16.0       13/08/2010   PFA              16. 14587: CRT001 - AÃƒÂ±adir campo siniestro compaÃƒÂ±ia
   17.0       17/08/2010   PFA              17. 15006: MDP003 - Incluir nuevos campos en bÃƒÂºsqueda siniestros
   18.0       23/11/2010   ETM              27. 0016645: GRC - BÃƒÂºsqueda de siniestros
   19.0       15/12/2010   ICV              19. 0014587: CRT001 - AÃƒÂ±adir campo siniestro compaÃƒÂ±ia
   22.0       14/12/2010   DRA              22. 0016506: CRE - Pantallas de siniestros nuevo mÃƒÂ³dulo
   23.0       22/12/2010   ICV              23. 0015738: ENSA101 - Duplicat en PDF pagament en capital SONANGOL
   24.0       16/03/2011   JMF              24. 0017970: ENSA101- Campos pantallas de siniestros y mejoras
   25.0       04/05/2011   JMP              25. 0018336: LCOL701 - Desarrollo TrÃƒÂ¡mites Siniestros.
   26.0       14/06/2011   SRA              26. 0018554: LCOL701 - Desarrollo de ModificaciÃƒÂ³n de datos cabecera siniestro y ver histÃƒÂ³rico (BBDD).
   27.0       12/07/2011   ICV              27. 0018977: LCOL_S001 - SIN -AsignaciÃƒÂ³n automÃƒÂ¡tica de tramitadores
   28.0       21/06/2011   JMF              28. 0018812: ENSA102-Proceso de alta de prestaciÃƒÂ³n en forma de renta actuarial
   29.0       13/10/2011   JMC              29. 0019601: LCOL_S001-SIN - Subestado del pago
   30.0       07/11/2011   MDS              30. 0019981: LCOL_S001-SIN - ReteIVA y ReteICA en pagos
   31.0       21/10/2011   JMP              31. 0019832 LCOL_S001-SIN - Carpeta de siniestro
   32.0       10/11/2011   MDS              32. 0019821: LCOL_S001-SIN - TramitaciÃƒÂ³n judicial
   33.0       09/12/2011   JMF              33. 0020472: LCOL_TEST-SIN - Reserva aÃƒÂ±adida sobre garantÃƒÂ­a contratada (no siniestrada aÃƒÂºn)
   34.0       05/01/2012   ETM              34. 0019896: LCOL_S001-SIN - Declarante del siniestro
   35.0       02/03/2012   MDS              35. 0021172: LCOL_S001-SIN - Alta/ModificaciÃƒÂ³n masiva de reservas
   36.0       03/05/2012   ETM              36.0022048: LCOL_S001-SIN - NÃ‚Âº de juzgado cambiar tipo
   37.0       07/05/2012   MDS              37.0021855: MDP_S001-SIN - Detalle fraude
   38.0       16/05/2012   JMF              0022099: MDP_S001-SIN - TrÃƒÂ¡mite de asistencia
   38.0       22/05/2012   MDS              38. 0021817: MDP_S001-SIN - Agente en el alta de siniestros
   39.0       28/06/2012   ASN              39. 0022670: SIN - Mensajes en alta de siniestros (y nuevo parametro)
   40.0       05/07/2012   ASN              40. 0022603: MDP_S001-Reserva global
   41.0       09/07/2012   JMF              0022490: LCOL_S001-SIN - Poder indicar que se generen los pagos como el ÃƒÂºltimo (Id=4604)
   42.0       18/07/2012   ASN              0022603: MDP_S001-Reserva global
   43.0       19/07/2012   JMF              0022153 MDP_S001-SIN - NÃƒÂºmero de presiniestro y documentaciÃƒÂ³n
   44.0       31/08/2012   ASN              0023101: LCOL_S001-SIN - Apuntes de agenda automÃƒÂ¡ticos
   45.0       03/10/2012   MDS              0023805: MDP_S001-SIN - Visualizar/Ocultar casilla de asistencia en la pantalla de alta de siniestros
   46.0       24/10/2012   JMF              0023536 LCOL_S001-SIN - TramitaciÃƒÂ³n Otros
   47.0       24/10/2012   JMF              0023540 LCOL_S001-SIN - TramitaciÃƒÂ³n lesionados
   48.0       31/10/2012   ASN              0024491: MDP_S001-SIN - Control siniestros duplicados
   49.0       15/03/2013   ASN              0026108: LCOL_S010-SIN - LCOL Tipo de gasto en reservas
   50.0       23/08/2013   LPP              0027860: AGM800-En siniestras al a?adir documentos, no se guardan las descripciones de los documentos.
   51.0       30/10/2013   ASN              0024708: (POSPG500)- Parametrizacion - Sinestros/0157275 actualizar preguntas
   52.0       28/08/2013   NSS              0024637: (POSAN500-AN-Sin) Analisis Desarrollo: Siniestros IMPUESTOS
   53.0       04/02/2014   FAL              0025537: RSA000 - GestiÃƒÂ³n de incidencias
   54.0       26/02/2014   NSS              0028830/0166530: (POSND500)-N. Desarrollo: Siniestros: Compensaci?n cartera vs. Siniestros
   55.0       06/03/2014   NSS              0029224/0166661: (POSAN500)-Analisis-Siniestros-Nuevos Desarrollos
   56.0       07/03/2014   NSS              0024637/0147756: (POSAN500-AN-Sin) Analisis Desarrollo: Siniestros
   57.0       12/03/2014   DEV              0030342: POSPG500-Modulo de Autorizaciones para pagos de Siniestros
   58.0       16/04/2014   NSS              0031040: POSPG500-Crear un nuevo tipo de destinatario para los colectivos
   59.0       22/04/2014   NSS              0029989/165377: LCOL_S001-SIN - Rechazo de tramitaciÃƒÂ³n ÃƒÂºnica
   60.0       17/07/2014   JTT              0028830/179900: Revision del proceso de pago de compensaciones
   61.0       24/02/2015   FRC              0033345/0193484: GeneraciÃƒÂ³n de documentos en los eventos de siniestros.
   62.0       02/03/2015   JTT              0034622/0197860: Fecha de formalizaciÃƒÂ³n de siniestros
   63.0       17/03/2015   JCP              0035102/200437: Validacion de Innomidados, ff_hay_lista_innominados
   64.0       08/05/2015   VCG              0032470-0204062: AÃƒÂ±adir la referencia externa en el buscador de siniestros
   65.0       16/06/2015   CJMR             0036232/207513: AÃƒÂ±adir la referencia externa en el buscador de siniestros
   66.0       05/01/2016   JCP              0039475/222692: Modificar la select para recuperar tambiÃƒÂ©n el nuevo campo fdeteccion de sin_siniestro
   67.0       26/05/2016   ACL              Bug 41501: Soporte. Se crea la funciÃƒÂ³n f_anula_pago_sin.
   68.0       26/05/2016   ACL              Bug 41501: Soporte. Se modifica la funciÃƒÂ³n f_anula_pago_inicial por f_anula_pago.
   69.0       10/09/2016   JAEG             CONF-309: Desarrollo AT_CONF_SIN-07_ADAPTACION_CORE_SINIESTROS_BUSQUEDA_ANTECEDENTES
   70.0       02/05/2017   JGONZALEZ        CONF-693: Se incluyen campos de audiencia en agenda de citaciones
   71.0       11/08/2017   JGONZALEZ        CONF-1005: Desarrollo de GAP 67 solicitud de apoyo tecnico
   72.0       21/03/2019   AABC             IAXIS-2169 Adicion de fecha de alta.
   73.0       12/04/2019   AABC             IAXIS 3663 AABC 12/04/2019 Adicion campo observacion
******************************************************************************/

   /***********************************************************************
   -- BUG 9020 - 10/03/2009 - XPL I XVM - Nou model de dades del Sinistre
      /*************************************************************************
         Devuelve los siniestros que cumplan con el criterio de selecciÃƒÂ³n
         param in pnpoliza     : nÃƒÂºmero de pÃƒÂ³liza
         param in pncert       : nÃƒÂºmero de cerificado por defecto 0
         param in pnsinies     : nÃƒÂºmero del siniestro
         param in cestsin      : cÃƒÂ³digo situaciÃƒÂ³n del siniestro
         param in pnnumide     : nÃƒÂºmero identidad persona
         param in psnip        : nÃƒÂºmero identificador externo
         param in pbuscar      : nombre+apellidos a buscar de la persona
         param in ptipopersona : tipo de persona
                                  1 tomador
                                  2 asegurado
         param out mensajes    : mensajes de error
         return                : ref cursor
      *************************************************************************/
   FUNCTION f_consultasini_old(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER DEFAULT -1,
      pnsinies IN NUMBER,
      pcestsin IN NUMBER,
      pnnumide IN VARCHAR2,
      psnip IN VARCHAR2,
      pbuscar IN VARCHAR2,
      ptipopers IN NUMBER,
      pnsubest IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Recupera los datos del ÃƒÂºltimo recibo de la pÃƒÂ³liza
      param in psseguro  : cÃƒÂ³digo de seguro
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_pollastrecibo_old(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Recupera los datos de los recibos de la pÃƒÂ³liza
      param in psseguro  : cÃƒÂ³digo de seguro
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_polrecibos_old(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Recupera las garantia vigentes de una la pÃƒÂ³liza para un determinado riesgo,
      a fecha de ocurrencia del siniestro
      param in psseguro  : cÃƒÂ³digo de seguro
      param in pnriesgo  : nÃƒÂºmero de riesgo
      param in pfsinies  : fecha de ocurrencia del siniestro
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_polgarantias_old(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfsinies IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Recupera los documentos necesarios para poder realizar la apertura del siniestro.
      param in psseguro  : cÃƒÂ³digo de seguro
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_documentacion_old(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*
      Recupera los datos de un determinado siniestro
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param out mensajes  : mensajes de error
      return              : OB_IAX_SINIESTROS con la informaciÃƒÂ³n del siniestro
                            null -> Se ha producido un error
   ***********************************************************************/
   FUNCTION f_get_siniestro(
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pnsinies IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_siniestros;

   /***********************************************************************
      Recupera los datos generales de un determinado siniestro
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param out ob_iax_siniestro : ob_iax_siniestro
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_dades_sini(
      pnsinies IN VARCHAR2,
      pobsini IN OUT ob_iax_siniestros,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera los datos de una determinada localizacion
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
      param in  pnlocaliza  : nÃƒÂºmero de localizaciÃƒÂ³n
      param out  ob_iax_sin_trami_localiza :  ob_iax_sin_trami_localiza
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_localiza(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnlocali IN NUMBER,
      p_oblocaliza OUT ob_iax_sin_trami_localiza,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera la colecciÃƒÂ³n de tramitaciones por una tramitaciÃƒÂ³n
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
      param out  t_iax_sin_trami_localiza :  t_iax_sin_trami_localiza
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_localizaciones(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      t_localizaciones OUT t_iax_sin_trami_localiza,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera la colecciÃƒÂ³n de movimientos de siniestros
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param out  t_iax_sin_movsiniestro :  t_iax_sin_movsiniestro
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_movsiniestros(
      pnsinies IN VARCHAR2,
      t_movsiniestros OUT t_iax_sin_movsiniestro,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera los datos de un determinado movimiento de siniestro
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
      param in  pnmovsin  : nÃƒÂºmero de movimiento
      param out  ob_iax_sin_movsiniestro :  ob_iax_sin_movsiniestro
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_movsiniestro(
      pnsinies IN VARCHAR2,
      pnmovsin IN NUMBER,
      ob_movsiniestro OUT ob_iax_sin_movsiniestro,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera la colecciÃƒÂ³n de lineas de agenda
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
      param out  t_iax_sin_trami_agenda :  t_iax_sin_trami_agenda
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_listagenda(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      t_listagenda OUT t_iax_sin_trami_agenda,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera la colecciÃƒÂ³n de lineas de personas relacionadas
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
      param out  t_listapersrel :  t_iax_sin_trami_personarel
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_lista_personasrel(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      t_listapersrel OUT t_iax_sin_trami_personarel,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera los datos de un determinado agenda
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
      param in  pnlinage  : nÃƒÂºmero de linea de agenda
      param out  ob_iax_sin_trami_agenda :  ob_iax_sin_trami_agenda
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_agenda(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnlinage IN NUMBER,
      ob_agenda OUT ob_iax_sin_trami_agenda,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /***********************************************************************
      Recupera los datos de un determinado persona relacionada
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  ntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
      param in  pcpersrel  : nÃƒÂºmero de persona relacionada
      param out  ob_persrel :   ob_iax_sin_trami_personarel
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_personarel(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnpersrel IN NUMBER,
      ob_persrel OUT ob_iax_sin_trami_personarel,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera la colecciÃƒÂ³n de reservas
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
      param out  t_iax_sin_trami_reserva :  t_iax_sin_trami_reserva
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_reservas(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      t_reservas OUT t_iax_sin_trami_reserva,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
      
FUNCTION f_get_amparos(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      t_amparos OUT t_iax_sin_trami_amparo,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera los datos de un determinado reserva
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
      param in  pctipres  : nÃƒÂºmero de tipo de reserva
      param in  pnmovres  : nÃƒÂºmero de movimiento de reserva
      param out  ob_iax_sin_trami_reserva :  ob_iax_sin_trami_reserva
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_amparo(
      pnsinies IN VARCHAR2,		     
       pntramit IN NUMBER,		     
       pcgarant IN NUMBER,		     
       ob_amparo OUT ob_iax_sin_trami_amparo,
		mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
   FUNCTION f_get_reserva(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pctipres IN NUMBER,
      pnmovres IN NUMBER,
      pcgarant IN NUMBER,
      ob_reserva OUT ob_iax_sin_trami_reserva,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

      /***********************************************************************
      Recupera la colecciÃƒÂ³n de referencias
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param out  t_iax_siniestro_referencias :  t_iax_siniestro_referencias
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_referencias(
      pnsinies IN VARCHAR2,
      t_referencias OUT t_iax_siniestro_referencias,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera los datos de un determinado reserva
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  psrefext  : nÃƒÂºmero de referencia
      param out  ob_iax_siniestro_referencias :  ob_iax_siniestro_referencias
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_referencia(
      pnsinies IN VARCHAR2,
      psrefext IN NUMBER,
      ob_referencia OUT ob_iax_siniestro_referencias,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      FunciÃƒÂ³ que retorna una colÃ‚Â·lecciÃƒÂ³ de reserves amb els ultims moviments de cada una
      param       preservas IN t_iax_sin_trami_reserva,   : colÃ‚Â·lecciÃƒÂ³ original
      param       preservcalculada OUT t_iax_sin_trami_reserva : colÃ‚Â·lecciÃƒÂ³ resultant
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_objreservas_calc(
      preservas IN t_iax_sin_trami_reserva,
      preservcalculada OUT t_iax_sin_trami_reserva,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera la colecciÃƒÂ³n de tramitaciones
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param out  t_iax_sin_tramitacion :  t_iax_sin_tramitacion
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_tramitaciones(
      pnsinies IN VARCHAR2,
      t_tramitaciones OUT t_iax_sin_tramitacion,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera los datos de un determinado tramitacion
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param out  ob_iax_sin_tramitacion :  ob_iax_sin_tramitacion
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_tramitacion(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      ob_tramitacion OUT ob_iax_sin_tramitacion,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera los detalles de la tramitacion
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
      param in  pctramit  : nÃƒÂºmero de codi tramitacio
      param out  ob_iax_sin_trami_detalle :  ob_iax_sin_trami_detalle
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_detalltramitacio(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pctramit IN NUMBER,
      ob_detall OUT ob_iax_sin_trami_detalle,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera la colecciÃƒÂ³n de movimientos de tramitos
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
      param out  t_iax_sin_trami_movimiento :  t_iax_sin_trami_movimiento
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_movtramits(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      t_movtramits OUT t_iax_sin_trami_movimiento,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera los datos de un movimiento de tramitacion
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
      param in  pnmovtra  : nÃƒÂºmero de movimiento de tramitacion
      param out  ob_iax_sin_trami_movimiento :  ob_iax_sin_trami_movimiento
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_movtramit(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnmovtra IN NUMBER,
      ob_movtramit OUT ob_iax_sin_trami_movimiento,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera la colecciÃƒÂ³n de danyos
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
      param out  t_iax_sin_trami_dano :  t_iax_sin_trami_dano
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_danyos(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      t_danyos OUT t_iax_sin_trami_dano,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera los datos de un danyo
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
      param in  pndano  : nÃƒÂºmero danyo
      param out  ob_iax_sin_trami_dano :  ob_iax_sin_trami_dano
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_danyo(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pndano IN NUMBER,
      ob_danyo OUT ob_iax_sin_trami_dano,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/***********************************************************************
      Recupera la colecciÃƒÂ³n de danyos
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
      param out  t_iax_sin_trami_dano :  t_iax_sin_trami_dano
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_detdanyos(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pndano IN NUMBER,
      t_detdanyos OUT t_iax_sin_trami_detdano,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera los datos de un detdanyo
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
      param in  pndano  : nÃƒÂºmero danyo
      param out  ob_iax_sin_trami_dano :  ob_iax_sin_trami_dano
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_detdanyo(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pndano IN NUMBER,
      pndetdano IN NUMBER,
      ob_detdanyo OUT ob_iax_sin_trami_detdano,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera la colecciÃƒÂ³n de citaciones
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
      param out  t_iax_sin_trami_citaciones :  t_iax_sin_trami_citaciones
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_citaciones(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      t_citaciones OUT t_iax_sin_trami_citaciones,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera la colecciÃƒÂ³n de destinatarios
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
      param out  t_iax_sin_trami_destinatario :  t_iax_sin_trami_destinatario
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_destinatarios(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      t_destinatarios OUT t_iax_sin_trami_destinatario,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /***********************************************************************
      Recupera los datos de una citacion
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
      param in  pncitacion  : nÃƒÂºmero citacion
      param out  ob_iax_sin_trami_citacion :  ob_iax_sin_trami_citacion
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_citacion(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pncitacion IN NUMBER,
      ob_citacion OUT ob_iax_sin_trami_citacion,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

  /***********************************************************************
      Recupera los datos de persona por defecto
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
      param out mensajes  : mensajes de error
      return              : SYS_CURSOR
   ***********************************************************************/
   FUNCTION f_get_asiste_citacion_def(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /***********************************************************************
      Recupera los datos de un destinatario
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
      param in  psperson  : nÃƒÂºmero identificativo del destinatario
      param in  pctipdes  : nÃƒÂºmero tipo destinatario
      param out  ob_iax_sin_trami_dano :  ob_iax_sin_trami_dano
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_destinatario(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pctipdes IN NUMBER,
      ob_destinatario OUT ob_iax_sin_trami_destinatario,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
       Recupera la colecciÃƒÂ³n de pagos o recobros, dependiendo del ctippag
       ctippag = 2 --> pago
       ctippag = 7 --> recobro
       param in  pnsinies  : nÃƒÂºmero de siniestro
       param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
       param out  t_iax_sin_trami_destinatario :  t_iax_sin_trami_destinatario
       param out mensajes  : mensajes de error
       return              : 0 OK
                             1 Error
    ***********************************************************************/
   FUNCTION f_get_pagrecobs(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pctippag IN NUMBER,
      pperfil IN VARCHAR2,
      t_pagrecobs OUT t_iax_sin_trami_pago,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera los datos de un pago / recobro
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
      param in  psperson  : nÃƒÂºmero identificativo del destinatario
      param in  pctipdes  : nÃƒÂºmero tipo destinatario
      param out  ob_iax_sin_trami_dano :  ob_iax_sin_trami_dano
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_pagrecob(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      psidepag IN NUMBER,
      ob_pagrecob OUT ob_iax_sin_trami_pago,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera los datos del detalle de pagos / recobros
      param in  sidepag  : nÃƒÂºmero tipo pago
      param in  pnmovpag  : nÃƒÂºmero tipo movimiento pago
      param out  ob_iax_sin_trami_pago_gar :  ob_iax_sin_trami_pago_gar
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_pagogar(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      psidepag IN NUMBER,
      pctipres IN NUMBER,
      pnmovres IN NUMBER,
      pnorden IN NUMBER,
      ob_pagogar OUT ob_iax_sin_trami_pago_gar,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
       Recupera la colecciÃƒÂ³n de detalle de pagos / recobros
       param in  psidepag  : nÃƒÂºmero de pago
       param out  t_iax_sin_trami_pago_gar :  t_iax_sin_trami_pago_gar
       param out mensajes  : mensajes de error
       return              : 0 OK
                             1 Error
    ***********************************************************************/
   FUNCTION f_get_pagogars(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      psidepag IN NUMBER,
      t_pagogars OUT t_iax_sin_trami_pago_gar,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera los datos de movimiento de pago / recobro
      param in  sidepag  : nÃƒÂºmero tipo pago
      param in  pnmovpag  : nÃƒÂºmero tipo movimiento pago
      param out  ob_iax_sin_trami_movpago :  ob_iax_sin_trami_movpago
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_movpago(
      psidepag IN NUMBER,
      pnmovpag IN NUMBER,
      ob_movpag OUT ob_iax_sin_trami_movpago,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera la colecciÃƒÂ³n de movimientos de pagos o recobros, dependiendo del ctippag
      param in  psidepag  : nÃƒÂºmero de pago
      param out  t_iax_sin_trami_movpago :  t_iax_sin_trami_movpago
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_movpagos(
      psidepag IN NUMBER,
      t_movpagos OUT t_iax_sin_trami_movpago,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
   Ens retorna la ÃƒÂºltima reserva per un sinistre donat,
     param in  pnsinies  : nÃƒÂºmero de siniestro
     param out ult_reserva  : ÃƒÅ¡ltim moviment de la reserva del sinistre
     param IN out mensajes  : mensajes de error
     return              :  0 OK!
                            1 -> Se ha producido un error

   ***********************************************************************/
   FUNCTION f_get_ultimareserva(
      pnsinies IN VARCHAR2,
      ult_reserva OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
     Ens retorna tots els pagaments d'un sinistre idependentment de la tramitaciÃƒÂ³,
     param in  pnsinies  : nÃƒÂºmero de siniestro
     param in  pctippag  : tipo de pago 2--> pago, 7 --> recobro
     param out pagosporsinistro : CapÃƒÂ§alera del pagament
     param out mensajes  : mensajes de error
     return              :  0 OK!
                            1 -> Se ha producido un error

   ***********************************************************************/
   FUNCTION f_get_pagosporsiniestro(
      pnsinies IN VARCHAR2,
      pctippag IN NUMBER,
      pagosporsinistro OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
     Ens retorna tots els pagaments d'una reserva i una tramitaciÃƒÂ³ concreta,
     param in  pnsinies  : nÃƒÂºmero de siniestro
     param in  pctippag  : tipo de pago 2--> pago, 7 --> recobro
     param out detallespagos : CapÃƒÂ§alera del pagament
     param out mensajes  : mensajes de error
     return              :  0 OK!
                            1 -> Se ha producido un error

   ***********************************************************************/
   FUNCTION f_get_detallespagos(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pctipres IN NUMBER,
      pctippag IN NUMBER,
      pcgarant IN NUMBER,
      psidepag IN NUMBER,
      pnmovres IN NUMBER,
      detallespagos OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Devuelve los siniestros que cumplan con el criterio de selecciÃƒÂ³n
      param in pcramo       : nÃƒÂºmero de ramo
      param psproduc        : nÃƒÂºmero de producto
      param in pnpoliza     : nÃƒÂºmero de pÃƒÂ³liza
      param in pncert       : nÃƒÂºmero de cerificado por defecto 0
      param in pnsinies     : nÃƒÂºmero del siniestro
      param in cestsin      : cÃƒÂ³digo situaciÃƒÂ³n del siniestro
      param in pnnumide     : nÃƒÂºmero identidad persona
      param in psnip        : nÃƒÂºmero identificador externo
      param in pbuscar      : nombre+apellidos a buscar de la persona
      param in ptipopersona : tipo de persona
                               1 tomador
                               2 asegurado
      param in pnsubest
      param in pnsincia     : siniestro compaÃƒÂ±ia
      param in pccompani    : codigo compaÃƒÂ±ia
      param in pnpresin     : numero presiniestro
      param in pcsiglas     : tipo via
      param in ptnomvia     : nombre via
      param in pnnumvia     : numero via
      param in ptcomple     : datos complementarios
      param in pcpostal     : codigo postal
      param in pcpoblac     : ciudad
      param in pcprovin     : provincia
      param in pfgisx       : GIS X
      param in pfgisy       : GIS Y
      param in pfgisz       : GIS Z
      param in ptdescri     : descripcion
      param in pctipmat     : tipo matricula
      param in pcmatric     : matricula
      param in pctiporisc   : tipo riesgo
      param out mensajes    : mensajes de error
      return                : ref cursor
   *************************************************************************/
   FUNCTION f_consultasini(
      -- Bug 10093 - 02/02/2010 - LCF - Anyadir param busqueda siniestros
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      -- Fi Bug 10093 - 02/02/2010 - LCF
      pnpoliza IN NUMBER,
      pncertif IN NUMBER DEFAULT -1,
      pnsinies IN VARCHAR2,
      pcestsin IN NUMBER,
      pnnumide IN VARCHAR2,
      psnip IN VARCHAR2,
      pbuscar IN VARCHAR2,
      ptipopers IN NUMBER,
      pnsubest IN NUMBER,
      pnsincia IN VARCHAR2,   --BUG 14587 - PFA - 13/08/2010 - AÃƒÂ±adir campo siniestro compaÃƒÂ±ia
      pfalta    IN DATE,      --IAXIS-2169 AABC Adicion  de Fecha de Alta a la consulta de siniestro
      pccompani IN NUMBER,   -- Bug 15006 - PFA - 16/08/2010 - nuevos campos en bÃƒÂºsqueda siniestros
      pnpresin IN VARCHAR2,
      pcsiglas IN NUMBER,
      ptnomvia IN VARCHAR2,
      pnnumvia IN NUMBER,
      ptcomple IN VARCHAR2,
      pcpostal IN VARCHAR2,
      pcpoblac IN NUMBER,
      pcprovin IN NUMBER,
      pfgisx IN FLOAT,
      pfgisy IN FLOAT,
      pfgisz IN FLOAT,
      ptdescri IN VARCHAR2,
      pctipmat IN NUMBER,
      pcmatric IN VARCHAR2,
      ptiporisc IN NUMBER,
      -- Fi Bug 15006 - PFA - 16/08/2010 - nuevos campos en bÃƒÂºsqueda siniestros
      pcpolcia IN VARCHAR2,   --Bug.: 14587 - ICV - 14/12/2010
      pcactivi IN NUMBER,   --Bug 18749 - 28/06/2011 - AMC
      pfiltro IN NUMBER,
      pcagente IN NUMBER,   -- Bug 21817 - MDS - 2/05/2012
      pcmotor IN VARCHAR2,   -- Bug 25622/134589 - 06/02/2013 -AMC
      pcchasis IN VARCHAR2,   -- Bug 25622/134589 - 06/02/2013 -AMC
      pnbastid IN VARCHAR2,   -- Bug 25622/134589 - 06/02/2013 -AMC
      ptrefext IN VARCHAR2,   --Bug 32470/204062 - 08/05/2015-VCG
      pctipref IN NUMBER,   --Bug 32470/204062 - 08/05/2015-VCG
      ptdescrie IN VARCHAR2, -- BUG CONF_309 - 10/09/2016 - JAEG
      pncontrato IN VARCHAR2, --AP CONF-219
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Recupera los datos del ÃƒÂºltimo recibo de la pÃƒÂ³liza
      param in psseguro  : cÃƒÂ³digo de seguro
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_pollastrecibo(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
       Recupera los datos del ÃƒÂºltimo recibo de la pÃƒÂ³liza
       param in psseguro  : cÃƒÂ³digo de seguro
       param out mensajes : mensajes de error
       return             : ref cursor
    ***********************************************************************/
   FUNCTION f_get_pollastrecibo2(
      psseguro IN NUMBER,
      pfsinies IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Graba los datos del siniestro en la variable global objeto del paquete
      param in  psseguro  : cÃƒÂ³digo de seguro
      param in  pnriesgo  : nÃƒÂºmero de riesgo
      param in  nmovimi   : NÃƒÂºmero Movimiento Seguro
      param in  pfsinies  : fecha de ocurrencia del siniestro
      param in  phsinies  : hora de ocurrencia del siniestro
      param in  pfnotifi  : fecha de notificaciÃƒÂ³n del siniestro
      param in  pccausin   : CÃƒÂ³digo Causa Siniestro
      param in  pcmotsin  : cÃƒÂ³digo del motivo del siniestro
      param in  pcevento   : CÃƒÂ³digo Evento Siniestro
      param in  pcculpab  : cÃƒÂ³digo de la culpabilidad del siniestro
      param in  pcreclama  : CÃƒÂ³digo reclamaciÃƒÂ³n VF 200011
      param in  pnasegur   : NÃƒÂºmero asegurado (producto 2 cabezas)
      param in  pcmeddec   : CÃƒÂ³digo Medio declaraciÃƒÂ³n
      param in  pctipdec   : CÃƒÂ³digo Tipo Declarante
      param in  ptnomdec   : Nombre Declarante
      param in ptnom2dec : Nombre Declarante2
      param in  ptape1dec  : Primer Apellido Declarante
      param in  ptape2dec  : Segundo Apellido Declarante
      param in  ptteldec   : TelÃƒÂ©fono Declarante
      param in  ptmovildec : campo movil al declarante
      param in  ptemaildec :campo email  al declarante
      param in  ptsinies  : descripciÃƒÂ³n del siniestro
      param in  pcnivel  : Nivel Siniestro
      param in  psperson2  : Persona relacionada
      param in  pfechapp  : Fecha para planes pensiones
      param in  pasistencia : Asistencia (0=No, 1=Si)
      param out mensajes  : mensajes de error
      return              : 1 -> Todo correcto
                            0 -> Se ha producido un error
      -- Bug 0022099 - 16/05/2012 - JMF: aÃƒÂ±adir asistencia
   ***********************************************************************/
   FUNCTION f_set_cabecera_siniestro(
      pnsinies IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pfsinies IN DATE,
      phsinies IN VARCHAR2,
      pfnotifi IN DATE,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      pcevento IN VARCHAR2,
      pcculpab IN NUMBER,
      pcreclama IN NUMBER,
      pnasegur IN NUMBER,
      pcmeddec IN NUMBER,
      pctipdec IN NUMBER,
      ptnomdec IN VARCHAR2,
      ptnom1dec IN VARCHAR2,   --bug 19896 --ETM -- 20/12/2011--AÃƒÂ±adir el campo tnombre1 al declarante
      ptnom2dec IN VARCHAR2,   --bug 19896 --ETM -- 20/12/2011--AÃƒÂ±adir el campo tnombre2 al declarante
      ptape1dec IN VARCHAR2,
      ptape2dec IN VARCHAR2,
      ptteldec IN VARCHAR2,
      ptmovildec IN VARCHAR2,   -- bug 19896--ETM--20/12/2011--AÃƒÂ±adir campo movil al declarante
      ptemaildec IN VARCHAR2,   -- bug 19896--ETM--20/12/2011--AÃƒÂ±adir campo email  al declarante
      ptsinies IN VARCHAR2,
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      psperson_dec IN NUMBER,
      pnsincia IN VARCHAR2,   --BUG 14587 - PFA - 13/08/2010 - AÃƒÂ±adir campo siniestro compaÃƒÂ±ia
      pccompani IN NUMBER,
      pnpresin IN VARCHAR2,   -- Bug 15006 - PFA - 16/08/2010 - nuevos campos en bÃƒÂºsqueda siniestros
      -- Bug 0015669 - JRH - 30/09/2010 - Alta prestaciones
      pcnivel IN NUMBER,
      psperson2 IN NUMBER,
      pfechapp IN DATE,
      -- Fi Bug 0015669 - JRH - 30/09/2010
      pcpolcia IN VARCHAR2,   --BUG17539 - JTS - 10/02/2011
      piperit IN VARCHAR2,   --BUG17539 - JTS - 10/02/2011
      pcfraude IN NUMBER,   --BUG18748 - JBN
      pccarpeta IN NUMBER,   --BUG19832 - 21/10/2011 - JMP
      pasistencia IN NUMBER,
      pcagente IN NUMBER,   -- Bug 21817 - MDS - 2/05/2012
      pcsalvam IN NUMBER,   -- BUG 0024675 - 15/11/2012 - JMF
      --BUG 39475/222692
      pfdeteccion IN DATE DEFAULT NULL,
      vgobsiniestro IN OUT ob_iax_siniestros,
      mensajes IN OUT t_iax_mensajes,
      psolidaridad IN number default null,--CONF-249
      ptdetpreten IN VARCHAR2 default null) 
       RETURN NUMBER;

  /*************************************************************************
    funciÃƒÂ³n graba en una variable global de la capa IAX los valores del objeto
       nsinies        VARCHAR2(14),   --NÃƒÂºmero Siniestro
       ntramit        NUMBER(3),   --NÃƒÂºmero TramitaciÃƒÂ³n Siniestro
       ncitacion      NUMBER(3),   --NÃƒÂºmero citacion Siniestro
       sperson        NUMBER(6),   --Secuencia Persona
       fcitacion        VARCHAR2(100),--fecha citacion
       hcitacion        NUMBER(2),   --hora citacion
       cpais        VARCHAR2(100),   --cod pais
       cprovin        VARCHAR2(40),   --cod provincia
       cpoblac        NUMBER(5),   --cod poblacion
       tlugar       VARCHAR2(200) -- Lugar citacion
      pcitacion    OUT    ob_iax_sin_trami_citacion
   *************************************************************************/
   FUNCTION f_set_objeto_sintramicit(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pncitacion IN NUMBER,
      psperson IN NUMBER,
      pfcitacion IN DATE,
      phcitacion IN VARCHAR2,
      pcpais IN NUMBER,
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      ptlugar IN VARCHAR2,
      ptaudien IN VARCHAR2,
      pcoral IN NUMBER,
      pcestado IN NUMBER,
      pcresolu IN NUMBER,
      pfnueva IN DATE,
      ptresult IN VARCHAR2,
      pcmedio IN NUMBER,
      pcitacion IN OUT ob_iax_sin_trami_citacion,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    funciÃƒÂ³n graba en una variable global de la capa IAX los valores del objeto
    ob_iax_siniestros.localizacion
        nsinies        VARCHAR2(14),   --NÃƒÂºmero Siniestro
       ntramit        NUMBER(3),   --NÃƒÂºmero TramitaciÃƒÂ³n Siniestro
       nlocali        NUMBER(3),   --NÃƒÂºmero LocalizaciÃƒÂ³n Siniestro
       sperson        NUMBER(6),   --Secuencia Persona
       tnombre        VARCHAR2(100),--Nombre persona
       csiglas        NUMBER(2),   --CÃƒÂ³digo Tipo VÃƒÂ­a
       tsiglas        VARCHAR2(100),   --Des Siglas
       tnomvia        VARCHAR2(40),   --Nombre VÃƒÂ­a
       nnumvia        NUMBER(5),   --NÃƒÂºmero VÃƒÂ­a
       tcomple        VARCHAR2(15),   --DescripciÃƒÂ³n Complementaria
       tlocali        VARCHAR2(100),   --DirecciÃƒÂ³n no normalizada
       cpais          NUMBER(3),   --CÃƒÂ³digo PaÃƒÂ­s
       tpais          VARCHAR2(200),   -- Desc. Pais
       cprovin        NUMBER(5),   --CÃƒÂ³digo ProvÃƒÂ­ncia
       tprovin        VARCHAR2(200),   --Desc Provin
       cpoblac        NUMBER(5),   --CÃƒÂ³digo PoblaciÃƒÂ³n
       tpoblac        VARCHAR2(200),   --Desc Poblacio
       cpostal        VARCHAR2(30),   --CÃƒÂ³digo Postal
       -- Bug 20154/98048 - 15/11/2011 - AMC
        param in cviavp,    -- CÃƒÂ³digo de via predio - via principal
        param in clitvp,    -- CÃƒÂ³digo de literal predio - via principal
        param in cbisvp,    -- CÃƒÂ³digo BIS predio - via principal
        param in corvp,     -- CÃƒÂ³digo orientaciÃƒÂ³n predio - via principal
        param in nviaadco,  -- NÃƒÂºmero de via adyacente predio - coordenada
        param in clitco,    -- CÃƒÂ³digo de literal predio - coordenada
        param in corco,     -- CÃƒÂ³digo orientaciÃƒÂ³n predio - coordenada
        param in nplacaco,  -- NÃƒÂºmero consecutivo placa predio - ccordenada
        param in cor2co,    -- CÃƒÂ³digo orientaciÃƒÂ³n predio 2 - coordenada
        param in cdet1ia,   -- CÃƒÂ³digo detalle 1 - informaciÃƒÂ³n adicional
        param in tnum1ia,   -- NÃƒÂºmero predio 1 - informacion adicional
        param in cdet2ia,   -- CÃƒÂ³digo detalle 2 - informaciÃƒÂ³n adicional
        param in tnum2ia,   -- NÃƒÂºmero predio 2 - informacion adicional
        param in cdet3ia,   -- CÃƒÂ³digo detalle 3 - informaciÃƒÂ³n adicional
        param in tnum3ia    -- NÃƒÂºmero predio 3 - informacion adicional
      -- Fi Bug 20154/98048- 15/11/2011 - AMC
        param in plocalidad -- Descripcion de la localidad -- Bug 24780/130907 - 05/12/2012 - AMC
   *************************************************************************/
   FUNCTION f_set_objeto_sintramilocali(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnlocali IN NUMBER,
      psperson IN NUMBER,
      pcsiglas IN NUMBER,
      ptnomvia IN VARCHAR2,
      pnnumvia IN NUMBER,
      ptcomple IN VARCHAR2,
      ptlocali IN VARCHAR2,
      pcpais IN NUMBER,
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      pcpostal IN VARCHAR2,
      -- Bug 20154/98048 - 15/11/2011 - AMC
      pcviavp IN NUMBER,
      pclitvp IN NUMBER,
      pcbisvp IN NUMBER,
      pcorvp IN NUMBER,
      pnviaadco IN NUMBER,
      pclitco IN NUMBER,
      pcorco IN NUMBER,
      pnplacaco IN NUMBER,
      pcor2co IN NUMBER,
      pcdet1ia IN NUMBER,
      ptnum1ia IN VARCHAR2,
      pcdet2ia IN NUMBER,
      ptnum2ia IN VARCHAR2,
      pcdet3ia IN NUMBER,
      ptnum3ia IN VARCHAR2,
      -- Fi Bug 20154/98048- 15/11/2011 - AMC
      plocalidad IN VARCHAR2,   -- Bug 24780/130907 - 05/12/2012 - AMC
      vlocaliza IN OUT ob_iax_sin_trami_localiza,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    funciÃƒÂ³n graba en una variable global de la capa IAX los valores del objeto
    ob_iax_siniestros.localizacion
   nsinies        VARCHAR2(14),   --NÃƒÂºmero Siniestro
   ntramit        NUMBER(3),   --NÃƒÂºmero TramitaciÃƒÂ³n Siniestro
   ctramit        NUMBER(4),   --CÃƒÂ³digo tipus TramitaciÃƒÂ³n
   ttramit        VARCHAR2(100),   --Des tipus TramitaciÃƒÂ³n
   ctcausin       NUMBER(2),   --CÃƒÂ³digo Tipo DaÃƒÂ±o
   ttcausin       VARCHAR2(100),   --Des tipo daÃƒÂ±o
   cinform        NUMBER(1),   --Indicador TramitaciÃƒÂ³n Informativa
   tinform        VARCHAR2(100),   --Desc. INdicador tramitaciÃƒÂ³n Informativa
   cusualt        VARCHAR2(20),   --CÃƒÂ³digo Usuario Alta
   falta          DATE,   --Fecha Alta
   cusumod        VARCHAR2(20),   --CÃƒÂ³digo Usuario ModificaciÃƒÂ³n
   fmodifi        DATE,   --Fecha ModificaciÃƒÂ³n
   ctiptra        NUMBER,
   cborrab        NUMBER,
   ttiptra        VARCHAR2(200),
   detalle        ob_iax_sin_trami_detalle,-- detall de la tramitacio
   -- BUG 0023536 - 04/10/2012 - JMF: Afegir csubtiptra
   *************************************************************************/
   FUNCTION f_set_objeto_sintramitacion(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pctramit IN NUMBER,
      pctcausin IN NUMBER,
      pcinform IN NUMBER,
      pctiptra IN NUMBER,
      pcculpab IN NUMBER,
      pccompani IN NUMBER,
      pcpolcia IN VARCHAR2,
      piperit IN NUMBER,
      pnsincia IN VARCHAR2,
      vtramitacion IN OUT ob_iax_sin_tramitacion,
      mensajes IN OUT t_iax_mensajes,
      pntramte IN NUMBER DEFAULT NULL,   -- Bug : 0018336 - JMC - 02/05/2011
      pcsubtiptra IN NUMBER DEFAULT NULL,
      pnradica IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
    funciÃƒÂ³n graba en una variable global de la capa IAX los valores del objeto
    ob_iax_siniestros.tramitaciones(i).movimientos
   nsinies        VARCHAR2(14),   --NÃƒÂºmero Siniestro
   ntramit        NUMBER(3),   --NÃƒÂºmero TramitaciÃƒÂ³n Siniestro
   nmovtra        NUMBER(3),   --NÃƒÂºmero Movimiento TramitaciÃƒÂ³n
   cunitra        VARCHAR2(4),   --CÃƒÂ³digo Unidad TramitaciÃƒÂ³n
   tunitra        VARCHAR2(100),   -- desc. Unidad TramitaciÃƒÂ³n
   ctramitad      VARCHAR2(4),   --CÃƒÂ³digo Tramitador
   ttramitad      VARCHAR2(100),   --Desc. Tramitador
   cesttra        NUMBER(3),   --CÃƒÂ³digo Estado TramitaciÃƒÂ³n
   testtra        VARCHAR2(100),   --Desc. Estado TramitaciÃƒÂ³n
   csubtra        NUMBER(2),   --CÃƒÂ³digo Subestado TramitaciÃƒÂ³n
   tsubtra        VARCHAR2(100),   --Desc. Subestado TramitaciÃƒÂ³n
   festtra        DATE,   --Fecha Estado TramitaciÃƒÂ³n
   cusualt        VARCHAR2(500),   --CÃƒÂ³digo Usuario Alta
   falta          DATE,   --Fecha Alta
   *************************************************************************/
   FUNCTION f_set_objeto_sinmovtramit(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnmovtra IN NUMBER,
      pcunitra IN VARCHAR2,
      pctramitad IN VARCHAR2,
      pcesttra IN NUMBER,
      pcsubtra IN NUMBER,
      pfesttra IN DATE,
      pccauest IN NUMBER,   -- bug21196:ASN:26/03/2012
      vmovtramit IN OUT ob_iax_sin_trami_movimiento,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

      /*************************************************************************
       funciÃƒÂ³n graba en una variable global de la capa IAX los valores del objeto
       ob_iax_siniestros.tramitaciones(i).movimientos
      nsinies        VARCHAR2(14),   --NÃƒÂºmero Siniestro
      ntramit        NUMBER(3),   --NÃƒÂºmero TramitaciÃƒÂ³n Siniestro
      ctramit        NUMBER(4),   --CÃƒÂ³digo tipus TramitaciÃƒÂ³n
      ttramit        VARCHAR2(200),   --Des tipus TramitaciÃƒÂ³n
      ctiptra        NUMBER(4),   --codi tipus tramitaciÃƒÂ³
      ttiptra        VARCHAR2(200),   --Des tipus TramitaciÃƒÂ³n
      ccompani       NUMBER(4),   --codi companyia
      tcompani       VARCHAR2(200),   --desc. companyia
      npoliza        NUMBER(8),   --num. polissa
      cpolcia        NUMBER(8),   -- num.polissa contraria
      iperit         NUMBER(10),   --import peritatge
      desctramit     VARCHAR2(200),   --desc. tramitacio
      persona        ob_iax_personas,   --persona tramitacio
   --Persona
      cestper        NUMBER,   --codi estat persona
      testper        VARCHAR2(200),   -- Desc. estat de la persona
   -- direccion
      tdescdireccion VARCHAR2(200),   --descripciÃƒÂ³ de la direcciÃƒÂ³
      direccion      ob_iax_direcciones,   --direccio
   --conductor
      ctipcon        NUMBER,--tipo conductor
      ttipcon        VARCHAR2(200),--desc tipo conductor
      ctipcar        NUMBER,   --tipo permiso
      ttipcar        VARCHAR2(200),--desc tipo permiso
      fcarnet        DATE, --data permis
      calcohol       NUMBER, --alcoholemia 1/0 S/N
   -- vehiculo
      ctipmat        NUMBER,   --codi tipus matricula
      ttipmat        VARCHAR2(200),   --desc tipus matricula
      cmatric        VARCHAR2(12),   --Matricula vehiculo
      cmarca         NUMBER,   -- codi marca
      tmarca         VARCHAR2(200),   -- desc marca
      cmodelo        NUMBER,   --codi model
      tmodelo        VARCHAR2(200),   -- desc. model
      cversion       VARCHAR2(11),   --CÃƒÂ³digo de VersiÃƒÂ³n de VehÃƒÂ­culo
      tversion       VARCHAR2(200)

      Bug 12668 - 16/02/2010 - AMC
      cciudad       number(5),           -- cÃƒÂ³digo ciudad para chile
      fgisx         float,               -- coordenada gis x (gps)
      fgisy         float,               -- coordenada gis y (gps)
      fgisz         float,               -- coordenada gis z (gps)
      cvalida       number(2),           -- cÃƒÂ³digo validaciÃƒÂ³n direcciÃƒÂ³n. valor fijo 1006.
      Fi Bug 12668 - 16/02/2010 - AMC
      -- BUG 0023540 - 24/10/2012 - JMF: Afegir IRECLAM, IINDEMN
      *************************************************************************/
   FUNCTION f_set_objeto_sintramidetalle(
      psseguro IN NUMBER,
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pctramit IN NUMBER,
      pctiptra IN NUMBER,
      pdesctramit IN VARCHAR2,
      psperson IN NUMBER,
      pcestper IN NUMBER,
      ptdescdireccion IN VARCHAR2,
      pcdomici IN NUMBER,
      pcpostal IN VARCHAR2,
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      pcpais IN NUMBER,
      pctipdir IN NUMBER,
      pcsiglas IN NUMBER,
      ptnomvia IN VARCHAR2,
      pnnumvia IN NUMBER,
      ptcomple IN VARCHAR2,
      pcciudad IN NUMBER,
      pfgisx IN FLOAT,
      pfgisy IN FLOAT,
      pfgisz IN FLOAT,
      pcvalida IN NUMBER,
      pctipcon IN NUMBER,
      pctipcar IN NUMBER,
      pfcarnet IN DATE,
      pcalcohol IN NUMBER,
      pctipmat IN NUMBER,
      pcmatric IN VARCHAR2,
      pcmarca IN NUMBER,
      pcmodelo IN NUMBER,
      pcversion IN VARCHAR2,
      pnanyo IN NUMBER,   --BUG:25762-NSS-24/01/2013
      pcchasis IN VARCHAR2,
      pcodmotor IN VARCHAR2,
      pnbastid IN VARCHAR2,
      pccilindraje IN NUMBER,
      vtramidetalle IN OUT ob_iax_sin_trami_detalle,
      mensajes IN OUT t_iax_mensajes,
      pireclam IN NUMBER DEFAULT NULL,
      piindemn IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
 FUNCTION f_set_objeto_sintramiamparo(
      pnsinies IN VARCHAR2,		     
       pntramit IN NUMBER,		     
       pcgarant IN NUMBER,		     
       pnpreten IN NUMBER,		     
       picaprie IN NUMBER,		     
       pcmonpreten IN VARCHAR2,		     
 
      vtramiamparo    IN OUT ob_iax_sin_trami_amparo,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

       /*************************************************************************
      FUNCTION f_set_amparo
           la tabla sin_tramita_amparo .
         
      param in pnsinies : Numero Siniestro		     
       param in pntramit : Numero Tramitacion Siniestro		     
       param in pcgarant : Codigo Garantia		     
       param in pnpreten : vAlor de la pretension		     
       param in picaprie : Importe Capital Riesgo		     
       param in pcmonpreten : Codigo de moneda		     
          return             : 0 -> Tot correcte
                              1 -> Se ha producido un error
   -- BUG 004131 - 2019-05-22 - EA 
   *************************************************************************/ 
FUNCTION f_set_amparo(
      pnsinies IN VARCHAR2,		     
       pntramit IN NUMBER,		     
       pcgarant IN NUMBER,		     
       pnpreten IN NUMBER,		     
       picaprie IN NUMBER,		     
       pcmonpreten IN VARCHAR2,		     
       pamparo IN ob_iax_sin_trami_amparo,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
      /*************************************************************************
      FUNCTION f_set_amparos
           recorre y se guarda el objeto
         
      param in pnsinies : Numero Siniestro		     
       param in pntramit : Numero Tramitacion Siniestro		     
       param in pcgarant : Codigo Garantia		     
       param in pnpreten : vAlor de la pretension		     
       param in picaprie : Importe Capital Riesgo		     
       param in pcmonpreten : Codigo de moneda		     
          return             : 0 -> Tot correcte
                              1 -> Se ha producido un error
   -- BUG 004131 - 2019-05-22 - EA 
   *************************************************************************/ 
FUNCTION f_set_amparos(
      pnsinies IN VARCHAR2,		     
       pntramit IN NUMBER,		     
       pcgarant IN NUMBER,		     
       pnpreten IN NUMBER,		     
       picaprie IN NUMBER,		     
       pcmonpreten IN VARCHAR2,		     
 
      pamparos    IN OUT t_iax_sin_trami_amparo,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
   /*************************************************************************
     funciÃƒÂ³n graba en una variable global de la capa IAX los valores del objeto
     ob_iax_siniestros.reserva
    nsinies        VARCHAR2(14),   --NÃƒÂºmero Siniestro
    ntramit        NUMBER(3),   --NÃƒÂºmero TramitaciÃƒÂ³n Siniestro
    ctipres        NUMBER(2),   --CÃƒÂ³digo Tipo Reserva
    ttipres        VARCHAR2(100),--Des tipo reserva
    nmovres        NUMBER(4),   --NÃƒÂºmero Movimiento Reserva
    cgarant        NUMBER(4),   --CÃƒÂ³digo GarantÃƒÂ­a
    tgarant        VARCHAR2(100),--Des garantia
    ccalres        NUMBER(1),   --CÃƒÂ³digo CÃƒÂ¡lculo Reserva (Manual/AutomÃƒÂ¡tico)
    tcalres        Varchar2(100),--des calculo reserva
    fmovres        DATE,   --Fecha Movimiento Reserva
    cmonres        VARCHAR2(3),   --CÃƒÂ³digo Moneda Reserva
    tmonres        VARCHAR2(100),--des moneda reserva
    ireserva       NUMBER,   --Importe Reserva
    ipago          NUMBER,   --Importe Pago
    iingreso       NUMBER,   --Importe Ingreso
    irecobro       NUMBER,   --Importe Recobro
    icaprie        NUMBER,   --Importe capital risc
    ipenali        NUMBER,   --Importe penalitzaciÃƒÂ³
    fresini        DATE,   --Fecha Inicio Reserva
    fresfin        DATE,   --Fecha Fin Reserva
    sidepag        NUMBER(8),   --Secuencia Identificador Pago
    sproces        NUMBER(10),   --Secuencia Proceso
    fcontab        DATE,   --Fecha Contabilidad
    cusualt        VARCHAR2(20),   --CÃƒÂ³digo Usuario Alta
    falta          DATE,   --Fecha Alta
    cusumod        VARCHAR2(20),   --CÃƒÂ³digo Usuario ModificaciÃƒÂ³n
    fmodifi        DATE,   --Fecha ModificaciÃƒÂ³n
    iprerec        NUMBER  -- Importe previsiÃƒÂ³n de recobro

    -- Bug 11945 - 16/12/2009 - Se aÃƒÂ±ade el parametro IPREREC
    *************************************************************************/
   FUNCTION f_set_objeto_sintramireserva(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pctipres IN NUMBER,
      pttipres IN VARCHAR2,
      pnmovres IN NUMBER,
      pcgarant IN NUMBER,
      pccalres IN NUMBER,
      pfmovres IN DATE,
      pcmonres IN VARCHAR2,
      pireserva IN NUMBER,
      pipago IN NUMBER,
      piingreso IN NUMBER,
      pirecobro IN NUMBER,
      picaprie IN NUMBER,
      pipenali IN NUMBER,
      pfresini IN DATE,
      pfresfin IN DATE,
      pfultpag IN DATE,
      psidepag IN NUMBER,
      psproces IN NUMBER,
      pfcontab IN DATE,
      piprerec IN NUMBER,
      pctipgas IN NUMBER,
      vtramireserva IN OUT ob_iax_sin_trami_reserva,
      pifranq IN NUMBER,   -- Bug 27059:NSS:03/06/2013
      pndias IN NUMBER,   -- Bug 27487/159742:NSS:26/11/2013
      pcmovres IN NUMBER,   --0031294/0174788: NSS:26/05/2014
      pitotimp IN NUMBER DEFAULT NULL,   -- 24637/0147756:NSS:28/11/2013
      mensajes IN OUT t_iax_mensajes,   -- 24637/0147756:NSS:05/03/2014
      pitotret IN NUMBER DEFAULT NULL,   -- 24637/0147756:NSS:20/03/2014
      piva_ctipind IN NUMBER DEFAULT NULL,   -- 24637/0147756:NSS:20/03/2014
      pretenc_ctipind IN NUMBER DEFAULT NULL,   -- 24637/0147756:NSS:20/03/2014
      preteiva_ctipind IN NUMBER DEFAULT NULL,   -- 24637/0147756:NSS:20/03/2014
      preteica_ctipind IN NUMBER DEFAULT NULL,   -- 24637/0147756:NSS:20/03/2014
      pcsolidaridad IN NUMBER DEFAULT NULL -- CONF-431 IGIL
                                             )
      RETURN NUMBER;

   /*************************************************************************
     funciÃƒÂ³n graba en una variable global de la capa IAX los valores del objeto
     ob_iax_siniestros.danyos
   nsinies        VARCHAR2(14),   --NÃƒÂºmero Siniestro
   ntramit        NUMBER(3),   --NÃƒÂºmero TramitaciÃƒÂ³n Siniestro
   ndano          NUMBER(3),   --NÃƒÂºmero DaÃƒÂ±o Siniestro
   tdano          VARCHAR2(5000),   --DescripciÃƒÂ³n DaÃƒÂ±o
    *************************************************************************/
   FUNCTION f_set_objeto_sintramidanyo(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pndano IN NUMBER,
      pctipinf IN NUMBER,
      ptdano IN VARCHAR2,
      vtramidanyo IN OUT ob_iax_sin_trami_dano,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
     funciÃƒÂ³n graba en una variable global de la capa IAX los valores del objeto
     ob_iax_siniestros.detdanyos
   nsinies        VARCHAR2(14),   --NÃƒÂºmero Siniestro
   ntramit        NUMBER(3),   --NÃƒÂºmero TramitaciÃƒÂ³n Siniestro
   ndano          NUMBER(3),   --NÃƒÂºmero DaÃƒÂ±o Siniestro
   tdano          VARCHAR2(5000),   --DescripciÃƒÂ³n DaÃƒÂ±o
    *************************************************************************/
   FUNCTION f_set_objeto_sintramidetdanyo(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pndano IN NUMBER,
      pndetdano IN NUMBER,
      vtramidetdanyo IN OUT ob_iax_sin_trami_detdano,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

      /*************************************************************************
        funciÃƒÂ³n graba en una variable global de la capa IAX los valores del objeto
        ob_iax_siniestros.destinatario
   nsinies        VARCHAR2(14),   --NÃƒÂºmero Siniestro
      ntramit        NUMBER(3),   --NÃƒÂºmero TramitaciÃƒÂ³n Siniestro
   --   sperson        NUMBER(6),   --NUm. identificativo destinatario
   --   nnumide        VARCHAR2(14),   --NÃƒÂºmero documento
   --   tdestinatario  VARCHAR2(200),   --Nombre Destinatario
      ctipdes        NUMBER(2),   --CÃƒÂ³digo Tipo Destinatario
      ttipdes        VARCHAR2(100),   --des tipo destinatario
      cpagdes        NUMBER(1),   --Indicador aceptaciÃƒÂ³n pagos
      cactpro        NUMBER(4),   --CÃƒÂ³digo Actividad Profesional
      tactpro        VARCHAR2(100),   --Des Actividad Profesional
      pasigna        NUMBER(5,2), --asignaciÃƒÂ³n
      cpaisre        NUMBER(3),  --cÃƒÂ³digo paÃƒÂ­s residencia
      tpaisre        VARCHAR2(100), --descripciÃƒÂ³n paÃƒÂ­s
      cusualt        VARCHAR2(20),   --CÃƒÂ³digo Usuario Alta
      falta          DATE,   --Fecha Alta
      cusumod        VARCHAR2(20),   --CÃƒÂ³digo Usuario ModificaciÃƒÂ³n
      fmodifi        DATE,   --Fecha ModificaciÃƒÂ³n
      persona        ob_iax_personas,--persona destinataria
      pctipcap       Tipo prestaciÃƒÂ³n
      pcrelase        RelaciÃƒÂ³n con asegurado
       *************************************************************************/
   FUNCTION f_set_obj_sintramidestinatari(
      psseguro IN NUMBER,
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pctipdes IN NUMBER,
      pcpagdes IN NUMBER,
      pcactpro IN NUMBER,
      ppasigna IN NUMBER,
      pcpaisre IN NUMBER,
      psperson IN NUMBER,
      pctipban IN NUMBER,
      pcbancar IN VARCHAR2,
      -- Bug 0015669 - JRH - 30/09/2010 - Alta prestaciones
      pctipcap IN NUMBER,
      pcrelase IN NUMBER,
      -- Fi Bug 0015669 - JRH - 30/09/2010
      psprofes IN NUMBER,   --bug 0024637/0147756: (POSAN500-AN-Sin) Analisis Desarrollo: Siniestros - NSS - 26/02/2014
      vtramidestinatario IN OUT ob_iax_sin_trami_destinatario,
      pcprovin IN NUMBER,   -- SHA -- Bug 38224/216445 --11/11/2015
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

         /*************************************************************************
           funciÃƒÂ³n graba en una variable global de la capa IAX los valores del objeto
           ob_iax_siniestros.recobros
   sidepag        NUMBER(8),   --Secuencia Identificador Pago
      nsinies        VARCHAR2(14),   --NÃƒÂºmero Siniestro
      ntramit        NUMBER(3),   --NÃƒÂºmero TramitaciÃƒÂ³n Siniestro
      ctipdes        NUMBER(2),   --CÃƒÂ³digo Tipo Destinatario
      ttipdes        VARCHAR2(100),   --Desc. Tipo Destinatario
      ctippag        NUMBER(1),   --CÃƒÂ³digo Tipo Pago
      ttippag        VARCHAR2(100),   --Desc. Tipo Pago
      cconpag        NUMBER(2),   --CÃƒÂ³digo Concepto Pago
      tconpag        VARCHAR2(100),   --Desc. COncepto Pago
      ccauind        NUMBER(3),   --CÃƒÂ³digo Causa IndemnizaciÃƒÂ³n
      tcauind        VARCHAR2(100),   --Desc. Causa IndemnizaciÃƒÂ³n
      cforpag        NUMBER(2),   --CÃƒÂ³digo Forma Pago
      tforpag        VARCHAR2(100),   --DEsc. Forma PAgo
      fordpag        DATE,   --Fecha Orden Pago
      ctipban        NUMBER(1),   --CÃƒÂ³digo Tipo Cuenta Bancaria
      ttipban        VARCHAR2(100),   --Desc. Tipo Cuenta Bancaria
      cbancar        VARCHAR2(34),   --CÃƒÂ³digo Cuenta Bancaria
      cmonres        VARCHAR2(3),   --CÃƒÂ³digo Moneda Reserva
      tmonres        VARCHAR2(100),   --Desc. Moneda Reserva
      isinret        NUMBER,   --Importe Sin RetenciÃƒÂ³n
      iconret        NUMBER,   --Importe Con RetenciÃƒÂ³n
      iretenc        NUMBER,   --Importe RetenciÃƒÂ³n
      pretenc        NUMBER(6, 3),   --Porcentaje RetenciÃƒÂ³n
      iiva           NUMBER,   --Importe IVA
      isuplid        NUMBER,   --Importe Suplido
      ifranq         NUMBER,   --Importe Franquicia Pagada
      iresred        NUMBER,   --Importe Rendimiento Reducido (Vida)
      iresrcm        NUMBER,   --Importe Rendimiento (Vida)
      cmonpag        VARCHAR2(3),   --CÃƒÂ³digo Moneda Pago
      tmonpag        VARCHAR2(100),   --Desc Moneda Pago
      isinretpag     NUMBER,   --Importe Sin RetenciÃƒÂ³n Moneda Pago
      iconretpag     NUMBER,   --Importe Con RetenciÃƒÂ³n Moneda Pago
      iretencpag     NUMBER,   --Importe RetenciÃƒÂ³n Moneda Pago
      iivapag        NUMBER,   --Importe IVA Moneda Pago
      isuplidpag     NUMBER,   --Importe Suplido Moneda Pago
      ifranqpag      NUMBER,   --Importe Franquicia Moneda Pago
      fcambio        DATE,   --Fecha de cambio
      nfacref        VARCHAR2(100),   --NÃƒÂºmero Factura/Referencia
      ffacref        DATE,   --Fecha Factura/Referencia
      cusualt        VARCHAR2(20),   --CÃƒÂ³digo Usuario Alta
      falta          DATE,   --Fecha Alta
      cusumod        VARCHAR2(20),   --CÃƒÂ³digo Usuario ModificaciÃƒÂ³n
      fmodifi        DATE,   --Fecha ModificaciÃƒÂ³n
      sidepagtemp    NUMBER  --Indica si el sidepag es el temporal o el definitivo
      destinatari    ob_iax_personas,   --destinatari
      movpagos       t_iax_sin_trami_movpago,   --Coleccion movimientos de pagos
      pagogar        t_iax_sin_trami_pago_gar,   --coleccion pago garantias
      pcagente        NUMBER  CÃƒÂ³digo del agente/mediador
      pnpersrel       NUMBER  CÃƒÂ³digo persona relacionada/perjudicada

      Bug 11848 - 20/11/2009 - AMC - Se aÃƒÂ±ade el parametro psidepagtemp
      BUG 19981 - 07/11/2011 - MDS - AÃƒÂ±adir campos ireteiva, ireteica, ireteivapag, ireteicapag, iica, iicapag en la cabecera, type ob_iax_sin_trami_pago
      Bug 22256/122456 - 28/09/2012 - AMC  - AÃƒÂ±adir campos cagente,npersrel,pcdomici y pctributacion
     *************************************************************************/
   FUNCTION f_set_obj_sintrami_pago_recob(
      psseguro IN NUMBER,
      psidepag IN NUMBER,
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pctipdes IN NUMBER,
      pctippag IN NUMBER,
      pcconpag IN NUMBER,
      pccauind IN NUMBER,
      pcforpag IN NUMBER,
      pfordpag IN DATE,
      pctipban IN NUMBER,
      pcbancar IN VARCHAR2,
      pcmonres IN VARCHAR2,
      pisinret IN NUMBER,
      piconret IN NUMBER,
      ppretenc IN NUMBER,
      piretenc IN NUMBER,   -- ASN 24546
      piiva IN NUMBER,
      pisuplid IN NUMBER,
      pifranq IN NUMBER,
      piresred IN NUMBER,
      piresrcm IN NUMBER,
      pcmonpag IN VARCHAR2,
      pisinretpag IN NUMBER,
      piconretpag IN NUMBER,
      piretencpag IN NUMBER,
      piivapag IN NUMBER,
      pisuplidpag IN NUMBER,
      pifranqpag IN NUMBER,
      pfcambio IN DATE,
      pnfacref IN VARCHAR2,
      pffacref IN DATE,
      psperson IN NUMBER,
      psidepagtemp IN NUMBER,
      pcultpag IN NUMBER,
      pncheque IN VARCHAR2,
      vtrami_pago_recobro IN OUT ob_iax_sin_trami_pago,
      mensajes IN OUT t_iax_mensajes,
      pireteiva IN NUMBER DEFAULT NULL,
      pireteica IN NUMBER DEFAULT NULL,
      pireteivapag IN NUMBER DEFAULT NULL,
      pireteicapag IN NUMBER DEFAULT NULL,
      piica IN NUMBER DEFAULT NULL,
      piicapag IN NUMBER DEFAULT NULL,
      pcagente IN NUMBER DEFAULT NULL,
      pnpersrel IN NUMBER DEFAULT NULL,
      pcdomici IN NUMBER DEFAULT NULL,
      pctributacion IN NUMBER DEFAULT NULL,
      pcbanco IN NUMBER DEFAULT NULL,   --24708:NSS:10/10/2013
      pcofici IN NUMBER DEFAULT NULL,   --24708:NSS:10/10/2013
      pcciudad IN NUMBER DEFAULT NULL,   --29224:NSS:24/02/2014
      pspersonpres  IN NUMBER DEFAULT NULL,
      ptobserva     IN VARCHAR2 DEFAULT NULL,
      piotrosgas    IN NUMBER DEFAULT NULL,
      pibaseipoc    IN NUMBER DEFAULT NULL,
      piipoconsumo  IN NUMBER DEFAULT NULL,
      piotrosgaspag   IN NUMBER DEFAULT NULL,
      pibaseipocpag   IN NUMBER DEFAULT NULL,
      piipoconsumopag IN NUMBER DEFAULT NULL
                                     )
      RETURN NUMBER;

/*************************************************************************
funciÃƒÂ³n graba en una variable global de la capa IAX los valores del objeto
ob_iax_siniestros.tramitaciones.movpagos
   sidepag        NUMBER(8),   --Secuencia Identificador Pago
   nmovpag        NUMBER(4),   --NÃƒÂºmero Movimiento Pago
   cestpag        NUMBER(1),   --CÃƒÂ³digo Estado Pago
   testpag        VARCHAR2(100),--Desc. Estado Pago
   fefepag        DATE,   --Fecha Efecto Pago
   cestval        NUMBER(1),   --CÃƒÂ³digo Estado ValidaciÃƒÂ³n Pago
   testval        VARCHAR2(100),--Desc. Estado ValidaciÃƒÂ³n Pago
   fcontab        DATE,   --Fecha Contabilidad
        cestpagant     NUMBER(1)   --CÃƒÂ³digo Estado Pago anterior

        Bug 13312 - 08/03/2010 - AMC - Se aÃƒÂ±ade el parametro cestpagant
          *************************************************************************/
   FUNCTION f_set_obj_sintram_movpagrecob(
      psidepag IN NUMBER,
      pnmovpag IN NUMBER,
      pcestpag IN NUMBER,
      pfefepag IN DATE,
      pcestval IN NUMBER,
      pfcontab IN DATE,
      pcestpagant IN NUMBER,
      --Bug: 19601 - 13/10/2011 - JMC
      pcsubpag IN NUMBER,
      pcsubpagant IN NUMBER,
      --Fin Bug: 19601 - 13/10/2011 - JMC
      vtrami_movpago_recobro IN OUT ob_iax_sin_trami_movpago,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
funciÃƒÂ³n graba en una variable global de la capa IAX los valores del objeto
ob_iax_siniestros.tramitaciones.movpagos
   sidepag        NUMBER(8),   --Secuencia Identificador Pago
   nmovpag        NUMBER(4),   --NÃƒÂºmero Movimiento Pago
   cestpag        NUMBER(1),   --CÃƒÂ³digo Estado Pago
   testpag        VARCHAR2(100),--Desc. Estado Pago
   fefepag        DATE,   --Fecha Efecto Pago
   cestval        NUMBER(1),   --CÃƒÂ³digo Estado ValidaciÃƒÂ³n Pago
   testval        VARCHAR2(100),--Desc. Estado ValidaciÃƒÂ³n Pago
   fcontab        DATE,   --Fecha Contabilidad

BUG 19981 - 07/11/2011 - MDS - AÃƒÂ±adir campos preteiva, preteica, ireteiva, ireteica, ireteivapag, ireteicapag, pica, iica, iicapag en la cabecera, type ob_iax_sin_trami_pago_gar
*************************************************************************/
   FUNCTION f_set_obj_sintram_pagrecob_gar(
      psidepag IN NUMBER,
      pctipres IN NUMBER,
      pnmovres IN NUMBER,
      pcgarant IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pcmonres IN VARCHAR2,
      pisinret IN NUMBER,
      piiva IN NUMBER,
      pisuplid IN NUMBER,
      piretenc IN NUMBER,
      pifranq IN NUMBER,
      pcmonpag IN VARCHAR2,
      pisinretpag IN NUMBER,
      piivapag IN NUMBER,
      pisuplidpag IN NUMBER,
      piretencpag IN NUMBER,
      pifranqpag IN NUMBER,
      pfcambio IN DATE,
      piresrcm IN NUMBER,
      piresred IN NUMBER,
      ppiva IN NUMBER,
      ppretenc IN NUMBER,
      pcconpag IN NUMBER,
      pnorden IN NUMBER,
      vtrami_pagorecobro_gar IN OUT ob_iax_sin_trami_pago_gar,
      mensajes IN OUT t_iax_mensajes,
      ppreteiva IN NUMBER DEFAULT NULL,
      ppreteica IN NUMBER DEFAULT NULL,
      pireteiva IN NUMBER DEFAULT NULL,
      pireteica IN NUMBER DEFAULT NULL,
      pireteivapag IN NUMBER DEFAULT NULL,
      pireteicapag IN NUMBER DEFAULT NULL,
      ppica IN NUMBER DEFAULT NULL,
      piica IN NUMBER DEFAULT NULL,
      piicapag IN NUMBER DEFAULT NULL,
      pciva_tipind IN NUMBER DEFAULT NULL,   --bug 24637/147756:NSS:03/03/2014
      pcretenc_tipind IN NUMBER DEFAULT NULL,   --bug 24637/147756:NSS:03/03/2014
      pcreteiva_tipind IN NUMBER DEFAULT NULL,   --bug 24637/147756:NSS:03/03/2014
      pcreteica_tipind IN NUMBER DEFAULT NULL,
      piotrosgas    IN NUMBER DEFAULT NULL,
      pibaseipoc    IN NUMBER DEFAULT NULL,
      ppipoconsumo  IN NUMBER DEFAULT NULL,
      pctipind      IN NUMBER DEFAULT NULL,
      piipoconsumo  IN NUMBER DEFAULT NULL,
      piotrosgaspag   IN NUMBER DEFAULT NULL,
      pibaseipocpag   IN NUMBER DEFAULT NULL,
      piipoconsumopag IN NUMBER DEFAULT NULL
      )   --bug 24637/147756:NSS:03/03/2014
      RETURN NUMBER;

   /*************************************************************************
    funciÃƒÂ³n graba en una variable global de la capa IAX los valores del objeto
    ob_iax_siniestros.tramitacion.agenda
   nsinies        VARCHAR2(14),   --NÃƒÂºmero Siniestro
   ntramit        NUMBER(3),   --NÃƒÂºmero TramitaciÃƒÂ³n Siniestro
   nlinage        NUMBER(6),   --NÃƒÂºmero LÃƒÂ­nea
   ctipreg        NUMBER(3),   --CÃƒÂ³digo Tipo Registro
   ttipreg        VARCHAR2(100),   --Des Tipo Registro
   cmanual        NUMBER(3),   --CÃƒÂ³digo Registro Manual
   tmanual        VARCHAR2(100),   --Desc Registro Manual
   cestage        NUMBER(3),   --CÃƒÂ³digo Estado Agenda
   testage        VARCHAR2(100),   --Desc Registro Manual
   ffinage        DATE,   --Fecha FinalizaciÃƒÂ³n
   ttitage        VARCHAR2(100),   --TÃƒÂ­tulo AnotaciÃƒÂ³n
   tlinage        VARCHAR2(2000),   --DescripciÃƒÂ³n AnotaciÃƒÂ³n

   Bug 12604 - 08/01/2010 - AMC - Se quita el parametro pfrec
   *************************************************************************/
   FUNCTION f_set_objeto_sintramiagenda(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnlinage IN NUMBER,
      pctipreg IN NUMBER,
      pcmanual IN NUMBER,
      pcestage IN NUMBER,
      pffinage IN DATE,
      pttitage IN VARCHAR2,
      ptlinage IN VARCHAR2,
      vtrami_agenda IN OUT ob_iax_sin_trami_agenda,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_ins_personarel
         Inserta a la taula SIN_TRAMITA_PERSONAREL dels parÃƒÂ metres informats.
         param in pnsinies     : nÃƒÂºmero sinistre
         param in pntramit     : nÃƒÂºmero tramitaciÃƒÂ³ sinistre
         param in pnpersrel    : nÃƒÂºmero linia
         param in pctipide     : codi tipus registre
         param in pnnumide     : codi registre manual
         param in ptnombre     : codi estat agenda
         param in ptapelli1    : data finalitzaciÃƒÂ³
         param in ptapelli2    : tÃƒÂ­tol anotaciÃƒÂ³
         param in pttelefon    : descripciÃƒÂ³ anotaciÃƒÂ³
         param in psperson     : descripciÃƒÂ³ anotaciÃƒÂ³
         param in ptdesc       : descripciÃƒÂ³ anotaciÃƒÂ³
         param in ptnombre2    : segundo nombre
         param in ptmovil      : telf. movil
         param in ptemail      : email
         return                : 0 -> Tot correcte
                                1 -> S'ha produit un error

         Bug 22325/115249 - 05/06/2012 - AMC
         -- Bug 0024690 - 13/11/2012 - JMF : aÃƒÂ±adir ctiprel
   *************************************************************************/
   FUNCTION f_set_sintramipersonarel(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnpersrel IN NUMBER,
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      ptnombre IN VARCHAR2,
      ptapelli1 IN VARCHAR2,
      ptapelli2 IN VARCHAR2,
      pttelefon IN VARCHAR2,
      psperson IN NUMBER,
      ptdesc IN VARCHAR2,
      ptnombre2 IN VARCHAR2,
      ptmovil IN VARCHAR2,
      ptemail IN VARCHAR2,
      pctiprel IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    funciÃƒÂ³n borra la persona relacionada de la tabla

    nsinies   VARCHAR2(14 ) -- NÃƒÂºmero siniestro
    ntramit   NUMBER(3)     -- NÃƒÂºmero de tramitaciÃƒÂ³n
    npersrel  NUMBER(4)    -- cÃƒÂ³digo persona relacionada

   Bug 12604 - 08/01/2010 - AMC - Se quita el parametro pfrec
   *************************************************************************/
   FUNCTION f_del_sintramipersonarel(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnpersrel IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Devuelve los siniestros que cumplan con el criterio de selecciÃƒÂ³n
      param in pnpoliza     : nÃƒÂºmero de pÃƒÂ³liza
      param in pncert       : nÃƒÂºmero de cerificado por defecto 0
      param in pnsinies     : nÃƒÂºmero del siniestro1
      param out mensajes    : mensajes de error
      return                : ref cursor
   *************************************************************************/
   FUNCTION f_consulta_lstsini(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER DEFAULT -1,
      pnsinies IN VARCHAR2,
      pcestsin IN NUMBER,   -- BUG 16645 --ETM--23/11/2010--0016645: GRC - BÃƒÂºsqueda de siniestros
      pfiltro IN NUMBER,
      pnriesgo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
     funciÃƒÂ³n graba en una variable global de la capa IAX los valores del objeto
     ob_iax_siniestros.tramitaciones(i).movimientos
    nsinies        VARCHAR2(14),   --NÃƒÂºmero Siniestro
    ntramit        NUMBER(3),   --NÃƒÂºmero TramitaciÃƒÂ³n Siniestro
    nmovtra        NUMBER(3),   --NÃƒÂºmero Movimiento TramitaciÃƒÂ³n
    cunitra        VARCHAR2(4),   --CÃƒÂ³digo Unidad TramitaciÃƒÂ³n
    tunitra        VARCHAR2(100),   -- desc. Unidad TramitaciÃƒÂ³n
    ctramitad      VARCHAR2(4),   --CÃƒÂ³digo Tramitador
    ttramitad      VARCHAR2(100),   --Desc. Tramitador
    cesttra        NUMBER(3),   --CÃƒÂ³digo Estado TramitaciÃƒÂ³n
    testtra        VARCHAR2(100),   --Desc. Estado TramitaciÃƒÂ³n
    csubtra        NUMBER(2),   --CÃƒÂ³digo Subestado TramitaciÃƒÂ³n
    tsubtra        VARCHAR2(100),   --Desc. Subestado TramitaciÃƒÂ³n
    festtra        DATE,   --Fecha Estado TramitaciÃƒÂ³n
    cusualt        VARCHAR2(500),   --CÃƒÂ³digo Usuario Alta
    falta          DATE,   --Fecha Alta
    *************************************************************************/
   FUNCTION f_set_objeto_movsiniestro(
      pnsinies IN VARCHAR2,
      pnmovsin IN NUMBER,
      pcestsin IN NUMBER,
      pfestsin IN DATE,
      pccauest IN NUMBER,
      pcunitra IN VARCHAR2,
      pctramitad IN VARCHAR2,
      vmovsin IN OUT ob_iax_sin_movsiniestro,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_inicializa_tramitaciones(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pnsinies IN VARCHAR2,
      pcunitra IN VARCHAR2,
      pctramit IN VARCHAR2,
      pctramte IN NUMBER,   -- Bug : 0018336 - JMC - 02/05/2011
      pccauest IN NUMBER DEFAULT NULL,   -- Bug 21196
      pntramte IN NUMBER DEFAULT NULL,   -- Bug 0022099
      ttramitaciones IN OUT t_iax_sin_tramitacion,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Recuperar la informaciÃƒÂ³n de los asegurados
      param out mensajes : mesajes de error
      return             : objeto asegurados
   *************************************************************************/
   FUNCTION f_leeasegurados(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_asegurados;

   /*************************************************************************
    funciÃƒÂ³n devuelvo las garantias de un seguro

    -- Bug 11847 - 23/11/2009 - AMC
    -- Bug 0020472 - JMF - 09/12/2011: porigen (0-crear siniestro, 1-crear reserva)
   *************************************************************************/
   FUNCTION f_get_garantias(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      pfsinies IN DATE,
      porigen IN NUMBER DEFAULT 0,
      pctramit IN NUMBER DEFAULT NULL,   -- 25812:ASN:23/01/2013
      pnsinies IN NUMBER DEFAULT NULL,   -- 25812:ASN:27/05/2013
      pntramit IN NUMBER DEFAULT NULL,   -- 25812:ASN:27/05/2013
      pctipres IN NUMBER DEFAULT NULL,   -- 25812:ASN:27/05/2013
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
    funciÃƒÂ³n devuelve la franquicia de una garantia

    -- Bug 11847 - 23/11/2009 - AMC
   *************************************************************************/
   FUNCTION f_get_franquicia_garantia(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera la colecciÃƒÂ³n de documentos
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
      param out t_iax_sin_trami_documento :  t_iax_sin_trami_documento
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_documentos(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      t_documentos OUT t_iax_sin_trami_documento,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Function f_get_documento
         Recupera los datos de un documento
         param in  pnsinies  : nÃƒÂºmero de siniestro
         param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
         param in  pndocume  : nÃƒÂºmero de document
         param out  ob_iax_sin_trami_documento :  ob_iax_sin_trami_documento
         param out mensajes  : mensajes de error
         return              : 0 OK
                               1 Error
   ***********************************************************************/
   FUNCTION f_get_documento(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pndocume IN NUMBER,
      ob_documento OUT ob_iax_sin_trami_documento,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
        Graba el objeto siniestros a las tablas de la bbdd
        param out mensajes  : mensajes de error
        return              : 1 -> Todo correcto
                              0 -> Se ha producido un error
     ***********************************************************************/
   FUNCTION f_grabar_siniestro(
      pobsiniestro IN OUT ob_iax_siniestros,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
        Graba la cabecera del objeto siniestros a las tablas de la bbdd
        pobsiniestro IN ob_iax_siniestros
        param out mensajes  : mensajes de error
        return              : 1 -> Todo correcto
                              0 -> Se ha producido un error
     ***********************************************************************/
   FUNCTION f_set_dades_sinistre(
      pobsiniestro IN ob_iax_siniestros,
      pnsinies IN OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
        Graba la los movimientos del siniestro
        pmovimientos IN ob_iax_movsiniestro
        param out mensajes  : mensajes de error
        return              : 1 -> Todo correcto
                              0 -> Se ha producido un error
     ***********************************************************************/
   FUNCTION f_set_movsiniestros(
      pmovimientos IN t_iax_sin_movsiniestro,
      pnsinies IN OUT VARCHAR2,
      pnmovsin IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      grabar los datos de un determinado movimiento de siniestro
      param in  ob_iax_sin_movsiniestro :  ob_iax_sin_movsiniestro
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_set_movsiniestro(
      ob_movsiniestro IN ob_iax_sin_movsiniestro,
      pnsinies IN VARCHAR2,
      pnmovsin IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
       Graba la collecio de tramitacions

       param out  t_iax_sin_tramitacion :  t_iax_sin_tramitacion
       param in  pnsinies  : nÃƒÂºmero de siniestro
       param out mensajes  : mensajes de error
       return              : 0 OK
                             1 Error
    ***********************************************************************/
   FUNCTION f_set_tramitaciones(
      ptramitaciones IN t_iax_sin_tramitacion,
      pnsinies IN VARCHAR2,
      psidepag IN NUMBER,   -- BUG 25537 - FAL - 04/02/2014
      mensajes IN OUT t_iax_mensajes,
      pcvalida_ult IN NUMBER DEFAULT NULL)   --bug 29989/165377;NSS;13-02-2014)
      RETURN NUMBER;

   /***********************************************************************
      Recupera los datos de un determinado tramitacion
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param out  ob_iax_sin_tramitacion :  ob_iax_sin_tramitacion
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_set_tramitacion(
      ptramitacion IN ob_iax_sin_tramitacion,
      pnsinies IN VARCHAR2,
      psidepag IN NUMBER,   -- BUG 25537 - FAL - 04/02/2014
      mensajes IN OUT t_iax_mensajes,
      pcvalida_ult IN NUMBER DEFAULT NULL)   --bug 29989/165377;NSS;13-02-2014)
      RETURN NUMBER;

   /***********************************************************************
        grabar la colecciÃƒÂ³n de movimientos de tramitos
        param in  pnsinies  : nÃƒÂºmero de siniestro
        param in  t_iax_sin_trami_movimiento :  t_iax_sin_trami_movimiento
        param out mensajes  : mensajes de error
        return              : 0 OK
                              1 Error
     ***********************************************************************/
   FUNCTION f_set_movtramits(
      pnsinies IN VARCHAR2,
      pmovtramits IN t_iax_sin_trami_movimiento,
      mensajes IN OUT t_iax_mensajes,
      pcvalida_ult IN NUMBER DEFAULT NULL)   --bug 29989/165377;NSS;13-02-2014
      RETURN NUMBER;

   /***********************************************************************
      graba los datos de un movimiento de tramitacion
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  ob_iax_sin_trami_movimiento :  ob_iax_sin_trami_movimiento
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_set_movtramit(
      pmovtramit IN ob_iax_sin_trami_movimiento,
      pnsinies IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes,
      pcvalida_ult IN NUMBER DEFAULT NULL)   --bug 29989/165377;NSS;13-02-2014
      RETURN NUMBER;

   /***********************************************************************
       graba la colecciÃƒÂ³n de lineas de agenda
       param in  pnsinies  : nÃƒÂºmero de siniestro
       param out  t_iax_sin_trami_agenda :  t_iax_sin_trami_agenda
       param out mensajes  : mensajes de error
       return              : 0 OK
                             1 Error
    ***********************************************************************/
   FUNCTION f_set_agendas(
      pnsinies IN VARCHAR2,
      pagendas IN t_iax_sin_trami_agenda,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      graba los datos de un determinado agenda
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param out  ob_iax_sin_trami_agenda :  ob_iax_sin_trami_agenda
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_set_agenda(
      pnsinies IN VARCHAR2,
      pagenda IN ob_iax_sin_trami_agenda,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      graba la colecciÃƒÂ³n de danyos
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  t_iax_sin_trami_dano :  t_iax_sin_trami_dano
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_set_danyos(
      pnsinies IN VARCHAR2,
      pdanyos IN t_iax_sin_trami_dano,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      graba los datos de un danyo
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  ob_iax_sin_trami_dano :  ob_iax_sin_trami_dano
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_set_danyo(
      pnsinies IN VARCHAR2,
      pdanyo IN ob_iax_sin_trami_dano,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      graba la colecciÃƒÂ³n de destinatarios
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  t_iax_sin_trami_destinatario :  t_iax_sin_trami_destinatario
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_set_destinatarios(
      pnsinies IN VARCHAR2,
      pdestinatarios IN t_iax_sin_trami_destinatario,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      graba los datos de un destinatario
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param out  ob_iax_sin_trami_destinatario :  ob_iax_sin_trami_destintario
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_set_destinatario(
      pnsinies IN VARCHAR2,
      pdestinatario IN ob_iax_sin_trami_destinatario,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      graba la colecciÃƒÂ³n de reservas
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  t_iax_sin_trami_reserva :  t_iax_sin_trami_reserva
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_set_reservas(
      pnsinies IN VARCHAR2,
      preservas IN t_iax_sin_trami_reserva,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      GRABA los datos de un determinado reserva
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param IN  ob_iax_sin_trami_reserva :  ob_iax_sin_trami_reserva
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_set_reserva(
      pnsinies IN VARCHAR2,
      preserva IN ob_iax_sin_trami_reserva,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

      /***********************************************************************
      graba la colecciÃƒÂ³n de referencias
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  t_iax_sin_trami_reserva :  t_iax_sin_trami_reserva
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_set_referencias(
      pnsinies IN VARCHAR2,
      preferencias IN t_iax_siniestro_referencias,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      GRABA los datos de un determinado referencia
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param IN  ob_iax_sin_trami_reserva :  ob_iax_sin_trami_reserva
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_set_referencia(
      pnsinies IN VARCHAR2,
      preferencia IN ob_iax_siniestro_referencias,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      graba la colecciÃƒÂ³n de citaciones por una tramitaciÃƒÂ³n
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  t_iax_sin_trami_citaciones :  t_iax_sin_trami_citaciones
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_set_citaciones(
      pnsinies IN VARCHAR2,
      pcitaciones IN t_iax_sin_trami_citaciones,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

  /***********************************************************************
      graba los datos de una determinada citacion
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  ob_iax_sin_trami_citacion :  ob_iax_sin_trami_citacion
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_set_citacion(
      pnsinies IN VARCHAR2,
      pcitacion IN ob_iax_sin_trami_citacion,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      graba la colecciÃƒÂ³n de tramitaciones por una tramitaciÃƒÂ³n
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  t_iax_sin_trami_localiza :  t_iax_sin_trami_localiza
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_set_localizaciones(
      pnsinies IN VARCHAR2,
      plocalizaciones IN t_iax_sin_trami_localiza,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      graba los datos de una determinada localizacion
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  ob_iax_sin_trami_localiza :  ob_iax_sin_trami_localiza
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_set_localiza(
      pnsinies IN VARCHAR2,
      plocaliza IN ob_iax_sin_trami_localiza,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
       graba la colecciÃƒÂ³n de pagos o recobros, dependiendo del ctippag

       param in  pnsinies  : nÃƒÂºmero de siniestro
    param in  t_iax_sin_trami_destinatario :  t_iax_sin_trami_destinatario
       param out mensajes  : mensajes de error
       return              : 0 OK
                             1 Error
    ***********************************************************************/
   FUNCTION f_set_pagrecobs(
      pnsinies IN VARCHAR2,
      ppagrecobs IN t_iax_sin_trami_pago,
      psidepag IN NUMBER,   -- BUG 25537 - FAL - 04/02/2014
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera los datos de un pago / recobro
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  ob_iax_sin_trami_pago :  ob_iax_sin_trami_pago
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_set_pagrecob(
      pnsinies IN VARCHAR2,
      ppagrecob IN ob_iax_sin_trami_pago,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      graba la colecciÃƒÂ³n de movimientos de pagos o recobros, dependiendo del ctippag
      param in  psidepag  : nÃƒÂºmero de pago
      param out  t_iax_sin_trami_movpago :  t_iax_sin_trami_movpago
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_set_movpagos(
      psidepag IN NUMBER,
      pmovpagos IN t_iax_sin_trami_movpago,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      graba los datos de movimiento de pago / recobro
      param in  sidepag  : nÃƒÂºmero tipo pago
      param out  ob_iax_sin_trami_movpago :  ob_iax_sin_trami_movpago
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_set_movpago(
      psidepag IN NUMBER,
      pmovpag IN ob_iax_sin_trami_movpago,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
       graba la colecciÃƒÂ³n de pagos o recobros, dependiendo del ctippag

       param in  pnsinies  : nÃƒÂºmero de siniestro
    param in  t_iax_sin_trami_destinatario :  t_iax_sin_trami_destinatario
       param out mensajes  : mensajes de error
       return              : 0 OK
                             1 Error
    ***********************************************************************/
   FUNCTION f_set_pagrecobs_gars(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      psidepag IN NUMBER,
      ppagrecobsgar IN t_iax_sin_trami_pago_gar,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera los datos de un pago / recobro
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  ob_iax_sin_trami_pago :  ob_iax_sin_trami_pago
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_set_pagrecobgar(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      psidepag IN NUMBER,
      ppagrecob IN ob_iax_sin_trami_pago_gar,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      retorna el tramitador i la unitat tramitadora per defecte
      pcempres IN  NUMBER,
      pcunitra OUT VARCHAR2,
      pctramit OUT VARCHAR2,
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_unitradefecte(
      pcempres IN NUMBER,
      pcunitra OUT VARCHAR2,
      pctramit OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
       Retorna las causas de un siniestro
       param  in  pcempres :  cÃƒÂ³digo de la empresa
       param  in  pcramo  : cÃƒÂ³digo del ramo
       param  in  psproduc   : cÃƒÂ³digo del producto
       param  in  pccausin   : cÃƒÂ³digo de la causa del siniestro
       param  in  pcmotsin   : cÃƒÂ³digo motivo de siniestro
       param  in  pctipdes : cÃƒÂ³digo tipo destinatario
       param out mensajes  : mensajes de error
       return              : sys_refcursor

       21/05/2009   AMC                 Sinistres.  Bug: 8816
    ***********************************************************************/
   FUNCTION f_get_causas_motivos(
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      pctipdes IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Retorna los destinatarios de un siniestro
      param  in  pscaumot :  cÃƒÂ³digo de la causa
      param  in  pctipdes  : cÃƒÂ³digo del tipo de destinatario
      param out mensajes  : mensajes de error
      return              : sys_refcursor

      21/05/2009   AMC                 Sinistres.  Bug: 8816
   ***********************************************************************/
   FUNCTION f_get_caumot_destinatario(
      pscaumot IN NUMBER,
      pctipdes IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Retorna las formulas
      param  in  pscaumot :  cÃƒÂ³digo de la causa
      param  in  pctipdes  : cÃƒÂ³digo del tipo de destinatario
      param  in  pccampo  : cÃƒÂ³digo del campo
      param  in  pcclave  : cÃƒÂ³digo de la formula
      param out mensajes  : mensajes de error
      return              : sys_refcursor

      21/05/2009   AMC                 Sinistres.  Bug: 8816
   ***********************************************************************/
   FUNCTION f_get_caumot_destformula(
      pscaumot IN NUMBER,
      pctipdes IN NUMBER,
      pccampo IN VARCHAR2,
      pcclave IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Retorna los productos
      param  in  pscaumot :  cÃƒÂ³digo de la causa
      param  in  psproduc  : cÃƒÂ³digo del producto
      param  in  pcactivi  : cÃƒÂ³digo de la actividad
      param  in  pcgarant  : cÃƒÂ³digo de la garantia
      param  in  pctramit  : cÃƒÂ³digo de la tramitaciÃƒÂ³n
      param out mensajes  : mensajes de error
      return              : sys_refcursor

      22/05/2009   AMC                 Sinistres.  Bug: 8816
   ***********************************************************************/
   FUNCTION f_get_caumot_producte(
      pscaumot IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pctramit IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
        Inserta o actualiza en sin_causa_motivo
        param  in  pscaumot : cÃƒÂ³digo de la causa/motivo
        param  in  pccausin : cÃƒÂ³digo de la causa del siniestro
        param  in  pcmotsin : cÃƒÂ³digo del motivo del siniestro
        param  in  pcpagaut : si los pagos son automaticos
        param  in  pcmotmov : cÃƒÂ³digo motivo del movimiento
        param  in  pcmotfin : cÃƒÂ³digo motivo movimiento fin
        param  in  pcmovimi : cÃƒÂ³digo motivo movimiento inicial
        param  in  pcdesaut : si genera destinatario automaticamente
        param  in  pcultpag : Pago se crea marcado como ÃƒÂºltimo pago
        param  out mensajes : mensajes de error
        return              : 0 -> Tot correcte
                              1 -> S'ha produit un error

        25/05/2009   AMC                 Sinistres.  Bug: 8816
        Bug 12753     18/01/2010  AMC Se aÃƒÂ±ade el parametro pcdesaut
        -- Bug 0022490 - 09/07/2012 - JMF: aÃƒÂ±adir pcultpag
     ***********************************************************************/
   FUNCTION f_set_sin_causa_motivo(
      pscaumot IN NUMBER,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      pcpagaut IN NUMBER,
      pcmotmov IN NUMBER,
      pcmotfin IN NUMBER,
      pcmovimi IN NUMBER,
      pcdesaut IN NUMBER,
      pcultpag IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
       Recupera un registro de sin_causa_motivo
       param  in  pscaumot : cÃƒÂ³digo de la causa/motivo
       param  out  pccausin : cÃƒÂ³digo de la causa del siniestro
       param  out  pcmotsin : cÃƒÂ³digo del motivo del siniestro
       param  out  pcpagaut : si los pagos son automaticos
       param  out  pcmotmov : cÃƒÂ³digo motivo del movimiento
       param  out  pcmotfin : cÃƒÂ³digo motivo movimiento fin
       param  out  pcmovimi : cÃƒÂ³digo motivo movimiento inicial
       param  out  pcdesaut : si genera destinatario automaticamente
       param  out  pcultpag : Pago se crea marcado como ÃƒÂºltimo pago

       return              : 0 -> Tot correcte
                             1 -> S'ha produit un error

       26/05/2009   AMC                 Sinistres.  Bug: 8816
       Bug 12753     18/01/2010  AMC Se aÃƒÂ±ade el parametro pcdesaut
       -- Bug 0022490 - 09/07/2012 - JMF: aÃƒÂ±adir pcultpag
    ***********************************************************************/
   FUNCTION f_get_caumot(
      pscaumot IN NUMBER,
      pccausin OUT NUMBER,
      pcmotsin OUT NUMBER,
      pcpagaut OUT NUMBER,
      pcmotmov OUT NUMBER,
      pcmotfin OUT NUMBER,
      pcmovimi OUT NUMBER,
      pcdesaut OUT NUMBER,
      pcultpag OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
        Guarda a la taula una nova conf. per el producte
        param  in  pscaumot :  cÃƒÂ³digo de la causa
        param  in  psproduc  : cÃƒÂ³digo del producto
        param  in  pcactivi  : cÃƒÂ³digo de la actividad
        param  in  pcgarant  : cÃƒÂ³digo de la garantia
        param  in  pctramit  : cÃƒÂ³digo de la tramitaciÃƒÂ³n
        param in out mensajes  : mensajes de error
        return              : NUMBER

        26/05/2009   XPL                 Sinistres.  Bug: 8816
     ***********************************************************************/
   FUNCTION f_set_caumot_producte(
      pscaumot IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pctramit IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Eliminar de la taula una conf. del producte
      param  in  pscaumot :  cÃƒÂ³digo de la causa
      param  in  psproduc  : cÃƒÂ³digo del producto
      param  in  pcactivi  : cÃƒÂ³digo de la actividad
      param  in  pcgarant  : cÃƒÂ³digo de la garantia
      param  in  pctramit  : cÃƒÂ³digo de la tramitaciÃƒÂ³n
      param out mensajes  : mensajes de error
      return              : NUMBER

      26/05/2009   XPL                 Sinistres.  Bug: 8816
   ***********************************************************************/
   FUNCTION f_del_caumot_producte(
      pscaumot IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pctramit IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Grabar les formulas
      param  in  pscaumot :  cÃƒÂ³digo de la causa
      param  in  pctipdes  : cÃƒÂ³digo del tipo de destinatario
      param  in  pccampo  : cÃƒÂ³digo del campo
      param  in  pcclave  : cÃƒÂ³digo de la formula
      param out mensajes  : mensajes de error
      return              : sys_refcursor

      26/05/2009   XPL                 Sinistres.  Bug: 8816
   ***********************************************************************/
   FUNCTION f_set_caumot_destformula(
      pscaumot IN NUMBER,
      pctipdes IN NUMBER,
      pccampo IN VARCHAR2,
      pcclave IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Eliminar de la taula una conf. formula
      scaumot  IN  NUMBER,
      pctipdes  IN  NUMBER,
      pccampo   IN  VARCHAR2,
      pcclave   IN  NUMBER,
      param out mensajes  : mensajes de error
      return              : NUMBER

      26/05/2009   XPL                 Sinistres.  Bug: 8816
   ***********************************************************************/
   FUNCTION f_del_caumot_destformula(
      pscaumot IN NUMBER,
      pctipdes IN NUMBER,
      pccampo IN VARCHAR2,
      pcclave IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Grabar en sin_det_causa_motivo
      param  in  pscaumot : cÃƒÂ³digo de la causa/motivo
      param  in  pctipdes : cÃƒÂ³digo tipo destinatario
      param  in  pcmodfis : cÃƒÂ³digo del modelo fiscal
      param  out mensajes : mensajes de error
      return              : 0 -> Tot correcte
                            1 -> S'ha produit un error

      27/05/2009   AMC                 Sinistres.  Bug: 8816
   ***********************************************************************/
   FUNCTION f_set_sindetcausamot(
      pscaumot IN NUMBER,
      pctipdes IN NUMBER,
      pcmodfis IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Devuelve el siguiente codigo de causa/motivo
      param  out  pscaumot : PrÃƒÂ³ximo cÃƒÂ³digo de la causa/motivo
      return              : 0 -> Tot correcte
                            1 -> S'ha produit un error

      27/05/2009   AMC                 Sinistres.  Bug: 8816
   ***********************************************************************/
   FUNCTION f_get_nextscaumot(pscaumot OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Eliminar de la taula sin_det_causa_motivo
      param  in  pscaumot : cÃƒÂ³digo de la causa/motivo
      param  in  pctipdes : cÃƒÂ³digo tipo destinatario
      param  out  mensajes : Mensajes de error
      return              : 0 -> Tot correcte
                            1 -> S'ha produit un error

      27/05/2009   AMC                 Sinistres.  Bug: 8816
   ***********************************************************************/
   FUNCTION f_del_caumot_destinatario(
      pscaumot IN NUMBER,
      pctipdes IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
       Eliminar de la taula sin_det_causa_motivo
       param  in  pscaumot : cÃƒÂ³digo de la causa/motivo
       param  out  mensajes : Mensajes de error
       return              : 0 -> Tot correcte
                             1 -> S'ha produit un error

       28/05/2009   AMC                 Sinistres.  Bug: 8816
    ***********************************************************************/
   FUNCTION f_del_caumot(pscaumot IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
     FUNCTION F_ESTADO_TRAMITACION:
      Cambia el estado de una tramitaciÃƒÂ³n
      param in pnsinies : NÃƒÂºmero siniestro
      param in pntramit : NÃƒÂºmero tramitaciÃƒÂ³n
      param in pcesttra : CÃƒÂ³digo estado
      param  out  mensajes : Mensajes de error
      return            : 0 -> Tot correcte
                          1 -> S'ha produit un error
   ***********************************************************************/
   FUNCTION f_estado_tramitacion(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pcesttra IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
     FUNCTION F_ESTADO_SINIESTRO:
      Cambia el estado de un siniestro
      param in  pnsinies   : NÃƒÂºmero Siniestro
      param in pcestsin    : codi estat sinistre
      param in pccauest    : codi causa estat sinistre
      param in pcunitra    : codi unitat tramitaciÃƒÂ³
      param in pctramitad  : codi tramitador
      param in pcsubtra    : codi subestat tramitaciÃƒÂ³
      param  out  mensajes : Mensajes de error
      return               : 0 -> Tot correcte
                             1 -> S'ha produit un error
   ***********************************************************************/
   FUNCTION f_estado_siniestro(
      pnsinies IN VARCHAR2,
      pcestsin IN NUMBER,
      pccauest IN NUMBER,
      pcunitra IN VARCHAR2,
      pctramitad IN VARCHAR2,
      pcsubtra IN NUMBER,
      pfsinfin IN DATE,
      porigen IN VARCHAR2 DEFAULT NULL,
      pobserv IN VARCHAR2 DEFAULT NULL, --IAXIS 3663 AABC 12/04/2019 Adicion campo observacion
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
     FUNCTION F_INS_DOCUMENTOS:
         Inserta a la taula SIN_TRAMITA_DOCUMENTO dels parÃƒÂ metres informats.
         param in psproduc    : CÃƒÂ³digo producto
         param in pcactivi    : CÃƒÂ³digo actividad
         param in pccausin    : CÃƒÂ³digo causa
         param in pcmotsin    : CÃƒÂ³digo motivo
         param in pcidioma    : CÃƒÂ³digo idioma
         param in pctramit    : CÃƒÂ³digo tramitaciÃƒÂ³n (opcional, sinÃƒÂ³ = 0)
         param  out  mensajes : Mensajes de error
         return               : 0 -> Tot correcte
                                1 -> S'ha produit un error
   ***********************************************************************/
   FUNCTION f_ins_documentos(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes,
      psseguro IN NUMBER,
      pfreclama IN DATE)
      RETURN NUMBER;

   /***********************************************************************
     FUNCTION F_SET_DOCUMENTOS:
         Inserta a la taula SIN_TRAMITA_DOCUMENTO dels parÃƒÂ metres informats.
         param in psproduc  : CÃƒÂ³digo producto
         param in pcactivi  : CÃƒÂ³digo actividad
         param in pccausin  : CÃƒÂ³digo causa
         param in pcmotsin  : CÃƒÂ³digo motivo
         param in pcidioma  : CÃƒÂ³digo idioma
         param in pctramit  : CÃƒÂ³digo tramitaciÃƒÂ³n (opcional, sinÃƒÂ³ = 0)
         param  out  mensajes : Mensajes de error
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
      31/07/2009   XVM                 Sinistres.  Bug: 8820
   ***********************************************************************/
   FUNCTION f_set_documentos(
      pnsinies IN VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pntramit IN NUMBER DEFAULT 0)
      RETURN NUMBER;

/***********************************************************************
   F_SIN_REA:    Aquesta funciÃƒÂ³ permet crear moviments d'abonament, per
                   part de les companyies de reasseguranÃƒÂ§a, en concepte dels
                   pagaments de sinistres.
                   Busca el desglos d'un pagament en seguro/riscos/garanties
                   i, per cada garantia, crida a la funciÃƒÂ³ F_PAGSINREA.
   ALLIBREA
***********************************************************************/
   FUNCTION f_sin_rea(
      psidepag IN sin_tramita_pago.sidepag%TYPE,
      pmoneda IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes,
      pnsinies IN sin_siniestro.nsinies%TYPE DEFAULT NULL,
      pctippag IN sin_tramita_pago.ctippag%TYPE DEFAULT NULL,
      pfefepag IN sin_tramita_movpago.fefepag%TYPE DEFAULT NULL,
      pcpagcoa IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /***********************************************************************
     FUNCTION F_SET_CAUSA:
         Graba los datos de una determinada causa
         param in pccauest     : CÃƒÂ³digo Causa Estado
         param in pcestsin     : CÃƒÂ³digo Estado Siniestro
         param in pcidioma     : CÃƒÂ³digo Idioma
         param in ptcauest     : DescripciÃƒÂ³n Causa Estado
         param in out mensajes : Mensajes de error
         return               : 0 -> Tot correcte
                                1 -> S'ha produit un error
      31/07/2009   XVM                 Sinistres.  Bug: 8820
   ***********************************************************************/
   FUNCTION f_set_causa(
      pccauest IN NUMBER,
      pcestsin IN NUMBER,
      pcidioma IN NUMBER,
      ptcauest IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_get_causas
         Recupera de la tabla SIN_CODCAUEST y SIN_DESCAUEST las causas
         param in pccauest  : CÃƒÂ³digo Causa Estado
         param in pcestsin  : CÃƒÂ³digo Estado Siniestro
         param in ptcauest  : DescripciÃƒÂ³n Estado
         return             : ref cursor
      31/07/2009   XVM                 Sinistres.  Bug: 8820
   ***********************************************************************/
   FUNCTION f_get_causas(
      pccauest IN NUMBER,
      pcestsin IN NUMBER,
      ptcauest IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      FUNCTION f_get_causa
         Recupera de la tabla SIN_CODCAUEST y SIN_DESCAUEST una causa en
         concreto con sus descripciones
         param in pccauest : CÃƒÂ³digo Causa Estado
         param in pcestsin : CÃƒÂ³digo Estado Siniestro
         return             : ref cursor
      31/07/2009   XVM                 Sinistres.  Bug: 8820
   ***********************************************************************/
   FUNCTION f_get_causa(pccauest IN NUMBER, pcestsin IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
     FUNCTION f_del_causa
         Recupera de la tabla SIN_CODCAUEST y SIN_DESCAUEST una causa en
         concreto con sus descripciones
         param in pccauest : CÃƒÂ³digo Causa Estado
         param in pcestsin : CÃƒÂ³digo Estado Siniestro
         return            : 0 -> Tot correcte
                             1 -> S'ha produit un error
      31/07/2009   XVM                 Sinistres.  Bug: 8820
   ***********************************************************************/
   FUNCTION f_del_causa(pccauest IN NUMBER, pcestsin IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_del_detcausa
         Recupera de la tabla SIN_CODCAUEST y SIN_DESCAUEST una causa en
         concreto con sus descripciones
         param in pccauest : CÃƒÂ³digo Causa Estado
         param in pcestsin : CÃƒÂ³digo Estado Siniestro
         param in pcidioma : CÃƒÂ³digo Idioma
         return            : 0 -> Tot correcte
                             1 -> S'ha produit un error
      31/07/2009   XVM                 Sinistres.  Bug: 8820
   ***********************************************************************/
   FUNCTION f_del_detcausa(
      pccauest IN NUMBER,
      pcestsin IN NUMBER,
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    funciÃƒÂ³n graba los datos del documento asociado a la tramitaciÃƒÂ³n del siniestro
    ob_iax_siniestros.documentacion
       nsinies        VARCHAR2(14),   --NÃƒÂºmero Siniestro
       ntramit        NUMBER(3),   --NÃƒÂºmero TramitaciÃƒÂ³n Siniestro
       ndocume        NUMBER(6),   --NÃƒÂºmero Documento
       cdocume        NUMBER(6),   --CÃƒÂ³digo Documento
       iddoc          NUMBER(10),  --Identificador documento GEDOX
       freclama       DATE,        --Fecha reclamacion
       frecibe        DATE,        --Fecha recepcion
       fcaduca        DATE,        --Fecha caducidad
       cobliga        NUMBER(1)    --CÃƒÂ³digo obligatoriedad
       descripcion    VARCHAR2     --Descripcion del usuario para el documento
         param in out mensajes : Mensajes de error
         return               : 0 -> Tot correcte
                                1 -> S'ha produit un error

   *************************************************************************/
   FUNCTION f_set_objeto_sintramidocumento(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pndocume IN NUMBER,
      pcdocume IN NUMBER,
      piddoc IN NUMBER,
      pfreclama IN DATE,
      pfrecibe IN DATE,
      pfcaduca IN DATE,
      pcobliga IN NUMBER,
      pdescripcion IN VARCHAR2,
      pcaccion IN NUMBER,
      vdocumento IN OUT ob_iax_sin_trami_documento,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION F_INS_MOVSINIESTRO
      Guarda un moviment de sinistre
      param  in  pnsinies    : cÃƒÂ³digo siniestro
      param  in  pcestsin    : cÃƒÂ³digo estado siniestro
      param  in  pfestsin    : data estado siniestro
      param  in  pccauest    : cÃƒÂ³digo causa estado siniestro
      param  in  pcunitra    : cÃƒÂ³digo unidad tramitaciÃƒÂ³n
      param  in  pctramitad  : cÃƒÂ³digo tramitador
      param out pnmovsin  : nÃƒÂºmero movimiento
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_ins_movsiniestro(
      pnsinies IN VARCHAR2,
      pcestsin IN NUMBER,
      pfestsin IN DATE,
      pccauest IN NUMBER,
      pcunitra IN VARCHAR2,
      pctramitad IN VARCHAR2,
      pnmovsin OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/***********************************************************************
       graba la colecciÃƒÂ³n de lineas de documento
       param in  pnsinies  : nÃƒÂºmero de siniestro
       param out  t_iax_sin_trami_documento :  t_iax_sin_trami_documento
       param out mensajes  : mensajes de error
       return              : 0 OK
                             1 Error
    ***********************************************************************/
   FUNCTION f_set_trami_documentos(
      pnsinies IN VARCHAR2,
      --pagendas IN t_iax_sin_trami_agenda,
      pdocumentos IN t_iax_sin_trami_documento,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      graba los datos de un determinado documento
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param out  ob_iax_sin_trami_documento :  ob_iax_sin_trami_documento
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_set_trami_documento(
      pnsinies IN VARCHAR2,
      --pagenda IN ob_iax_sin_trami_agenda,
      pdocumento IN ob_iax_sin_trami_documento,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
       Recupera los datos del documento siniestro
       param in pcdocume: CÃƒÂ³digo del documento
       param in pcidioma : CÃƒÂ³digo del idioma
       param out pttitdoc: Nombre identificativo Documento
       param out ptdocume : DescripciÃƒÂ³n Documento
       param out mensajes  : mensajes de error
       return              : 0 OK
                             1 Error
    ***********************************************************************/
   FUNCTION f_get_documentos(
      pcdocume IN NUMBER,
      pcidioma IN NUMBER,
      pttitdoc OUT VARCHAR2,
      ptdocume OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
       Recupera el ttitdoc de la tabla DOC_DESDOCUMENTO
       param  in  pcdocume : cÃƒÂ³digo documento
       param  out pttitdoc : Nombre identificativo documento

       return              : 0 -> Tot correcte
                             1 -> S'ha produit un error

       06/10/2009   DCT                 Sinistres.  Bug: 10393
    ***********************************************************************/
   FUNCTION f_get_ttitdoc(
      pcdocume IN NUMBER,
      pttitdoc OUT VARCHAR,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
       FUNCTION F_get_unitradefecte
       Obtenim descripciÃƒÂ³ unitat tram i tramitador i els codis per Defecte
       param  out  ptunitra    : desc unidad tramitaciÃƒÂ³n
       param  out  pttramitad  : desc tramitador
       param  out  pcunitra    : cÃƒÂ³digo unidad tramitaciÃƒÂ³n
       param  out  pctramitad  : cÃƒÂ³digo tramitador
       param out mensajes  : mensajes de error
       return              : 0 OK
                             1 Error
    ***********************************************************************/
   FUNCTION f_get_descunitradefecte(
      p_cuser IN VARCHAR2,
      p_sseguro IN NUMBER,
      p_ccausin IN NUMBER,
      p_cmotsin IN NUMBER,
      p_nsinies IN NUMBER,
      p_ntramit IN NUMBER,
      ptunitra OUT VARCHAR2,
      pttramit OUT VARCHAR2,
      pcunitra OUT VARCHAR2,
      pctramit OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera el historico de reservas por tipo
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
      param in  pctipres  : CÃƒÂ³digo de tipo de reservar
      param in  pcgarant  : CÃƒÂ³digo de la garantia
      param in  pnmovres  : Numero de movimiento de la reserva
      param in  psproduc  : CÃƒÂ³digo del producto
      param in  pcactivi  : CÃƒÂ³digo de la actividad
      param out  t_iax_sin_trami_reserva :  t_iax_sin_trami_reserva
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error

      -- Bug 14490 - 18/05/2010 - AMC - Se aÃƒÂ±ade los parametros pnmovres,psproduc,pcactivi
   ***********************************************************************/
   FUNCTION f_get_histreservas(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pctipres IN NUMBER,
      pctipgas IN NUMBER,   -- 26108
      pcgarant IN NUMBER,
      pnmovres IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcmonres IN VARCHAR2,
      t_reservas OUT t_iax_sin_trami_reserva,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /**************************************************************************
      FunciÃƒÂ³n que genera un destinatario automatico
      param in  psseguro : Numero de seguro
      param in  pfsinies : Fecha siniestro
      param in  pccausin : CÃƒÂ³digo causa siniestro
      param in  pcmotsin : CÃƒÂ³digo motivo siniestro
      param in  pcgarant : CÃƒÂ³digo de la garantia
      param out psperson : CÃƒÂ³digo persona
      param out pctipdes : Codigo tipo destinatario
      param out pctipban : CÃƒÂ³digo tipo cuenta bancaria
      param out pcbancar : Cuenta bancaria
      param out pcpaise  : CÃƒÂ³digo PaÃƒÂ­s Residencia
      param out pctipcap : Tipo de prestaciÃƒÂ³n.  Valor 205.-- Bug 0017970 - 16/03/2011 - JMF
      param out mensajes : Mensajes de error
      return              : 0 -> Tot correcte
                            1 -> S'ha produit un error

      Bug 12753 - 19/01/2010 - AMC
   ***********************************************************************/
   FUNCTION f_destina_aut(
      psseguro IN seguros.sseguro%TYPE,
      pfsinies IN sin_siniestro.fsinies%TYPE,
      pccausin IN sin_siniestro.ccausin%TYPE,
      pcmotsin IN sin_siniestro.cmotsin%TYPE,
      pcgarant IN codigaran.cgarant%TYPE,
      psperson OUT sin_tramita_destinatario.sperson%TYPE,
      pctipdes OUT sin_tramita_destinatario.ctipdes%TYPE,
      pctipban OUT sin_tramita_destinatario.ctipban%TYPE,
      pcbancar OUT sin_tramita_destinatario.cbancar%TYPE,
      pcpaisre OUT sin_tramita_destinatario.cpaisre%TYPE,
      pctipcap OUT sin_tramita_destinatario.ctipcap%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /**************************************************************************
      FunciÃƒÂ³n que inserta un pago
      param in  pnsinies : nÃƒÂºmero de siniestro
      param in  pnriesgo : nÃƒÂºero de riesgp
      param in  pntramit : nÃƒÂºmero de tramitacion
      param in  pctipres : cÃƒÂ³digo del tipo de reserva
      param in  pcgarant : cÃƒÂ³digo de la garantia
      param in  pfsinies : fecha del siniestro
      param in  pfperini : fecha inicio periodo
      param in  pfperfin : fecha fin periodo
      param out pcpaise  : Codigo de identificafiÃƒÂ³n del pago
      param out mensajes : Mensajes de error

      return              : 0 -> Tot correcte
                            1 -> S'ha produit un error

      Bug 11849 - 20/01/2010 - AMC
   ***********************************************************************/
   FUNCTION f_inserta_pago(
      pnsinies IN sin_tramita_pago.nsinies%TYPE,
      pnriesgo IN sin_siniestro.nriesgo%TYPE,
      pntramit IN sin_tramita_pago.ntramit%TYPE,
      pctipres IN sin_tramita_reserva.ctipres%TYPE,
      pctipgas IN sin_tramita_reserva.ctipgas%TYPE,   -- 26108
      pcgarant IN sin_tramita_reserva.cgarant%TYPE,
      pfsinies IN sin_siniestro.fsinies%TYPE,
      pfperini IN sin_tramita_reserva.fresini%TYPE,
      pfperfin IN sin_tramita_reserva.fresfin%TYPE,
      psidepag OUT sin_tramita_pago.sidepag%TYPE,
      pipago OUT sin_tramita_pago.isinret%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /**************************************************************************
       FunciÃƒÂ³n que inserta un pago
       param in  pnsinies : nÃƒÂºmero de siniestro
       param in  pntramit : nÃƒÂºmero de tramitacion
       param in  pctipres : cÃƒÂ³digo del tipo de reserva
       param in  psproduc : CÃƒÂ³digo de producto
       param in  pcactivi : CÃƒÂ³digo de la actividad
       param in  pcgarant : cÃƒÂ³digo de la garantia
       param out pfperini : fecha inicio periodo
       param out mensajes : mensajes de error

       return              : 0 -> Tot correcte
                             1 -> S'ha produit un error

       Bug 12207 - 01/02/2010 - AMC
    ***********************************************************************/
   FUNCTION f_get_fechareserva(
      pnsinies IN sin_tramita_pago.nsinies%TYPE,
      pntramit IN sin_tramita_pago.ntramit%TYPE,
      pctipres IN sin_tramita_reserva.ctipres%TYPE,
      pctipgas IN sin_tramita_reserva.ctipgas%TYPE,   -- 26108
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN sin_tramita_reserva.cgarant%TYPE,
      pfperini OUT sin_tramita_reserva.fresini%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
/**************************************************************************
Funcion  borrar amparo 
param in  pnsinies : nÃºmero de siniestro
param in  pntramit : nÃºmero de tramitacion
param in  pcgarant : cÃ³digo de la garantia
param out mensajes : mensajes de error
return              : 0 -> Tot correcte
1 -> S'ha produit un error
Bug 12207 - 01/02/2010 - AMC
***********************************************************************/
FUNCTION f_del_amparo(
    pnsinies IN sin_tramita_amparo.nsinies%TYPE,
    pntramit IN sin_tramita_amparo.ntramit%TYPE,
    pcgarant IN sin_tramita_amparo.cgarant%TYPE,
    mensajes OUT t_iax_mensajes)
  RETURN NUMBER;
    /**************************************************************************
      FunciÃƒÂ³n que borrar el ultimo movimiento de una reserva si no tiene pagos
      param in  pnsinies : nÃƒÂºmero de siniestro
      param in  pntramit : nÃƒÂºmero de tramitacion
      param in  pctipres : cÃƒÂ³digo del tipo de reserva
      param in  pnmovres : Numero de movimiento
      param in  pcgarant : cÃƒÂ³digo de la garantia
      param out mensajes : mensajes de error

      return              : 0 -> Tot correcte
                            1 -> S'ha produit un error

      Bug 12207 - 01/02/2010 - AMC
   ***********************************************************************/
   FUNCTION f_del_ultreserva(
      pnsinies IN sin_tramita_pago.nsinies%TYPE,
      pntramit IN sin_tramita_pago.ntramit%TYPE,
      pctipres IN sin_tramita_reserva.ctipres%TYPE,
      pctipgas IN sin_tramita_reserva.ctipgas%TYPE,   --26108
      pnmovres IN sin_tramita_reserva.nmovres%TYPE,
      pcgarant IN sin_tramita_reserva.cgarant%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /**************************************************************************
        FunciÃƒÂ³n que comprueba la modificacion de la fresfin de una reserva
        param in  pnsinies : nÃƒÂºmero de siniestro
        param in  pntramit : nÃƒÂºmero de tramitacion
        param in  pctipres : cÃƒÂ³digo del tipo de reserva
        param in  pcgarant : cÃƒÂ³digo de la garantia
        param in  pfresfin : Fecha fin de la reserva
        param out pfresfin_out : Fecha permitida como fecha fin reserva
        param out mensajes : Mensajes de error

        return              : 0 -> Tot correcte
                              Codigo error -> S'ha produit un error

        Bug 12207 - 03/02/2010 - AMC
     ***********************************************************************/
   FUNCTION f_actfresfin(
      pnsinies IN sin_tramita_pago.nsinies%TYPE,
      pntramit IN sin_tramita_pago.ntramit%TYPE,
      pctipres IN sin_tramita_reserva.ctipres%TYPE,
      pcgarant IN sin_tramita_reserva.cgarant%TYPE,
      pfresfin IN sin_tramita_reserva.fresfin%TYPE,
      pfresfin_out OUT sin_tramita_reserva.fresfin%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /**************************************************************************
      FUNCTION f_pago_aut
      Crea un pago automÃƒÂ¡tico
      param in pdata   : fecha final de pago
      param out pncobros : Numero de cobros generados
      param out mensajes : Mensajes de error

      return              : 0 -> Tot correcte
                            Codigo error -> S'ha produit un error

      Bug 12207 - 03/02/2010 - AMC
   ***********************************************************************/
   FUNCTION f_pago_aut(
      p_data IN DATE,
      pproductos IN t_iax_info,
      pncobros OUT NUMBER,
      psproces OUT NUMBER,   -- Bug 16580 - 15/11/2010 - AMC
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /**************************************************************************
      FunciÃƒÂ³n que borra el detalle de un pago
      param in  psidepag : numero de pago
      param in  pnsinies : nÃƒÂºmero de siniestro
      param in  pntramit : nÃƒÂºmero de tramitacion
      param in  pctipres : cÃƒÂ³digo del tipo de reserva
      aram in  pcgarant : cÃƒÂ³digo de la garantia
      param in  pnmovres : numero de movimiento

      return              : 0 -> Tot correcte
                            Codigo error -> S'ha produit un error

      Bug 13166 - 15/02/2010 - AMC
   ***********************************************************************/
   FUNCTION f_del_movpaggar(
      psidepag IN sin_tramita_pago.sidepag%TYPE,
      pnsinies IN sin_tramita_pago.nsinies%TYPE,
      pntramit IN sin_tramita_pago.ntramit%TYPE,
      pctipres IN sin_tramita_reserva.ctipres%TYPE,
      pcgarant IN sin_tramita_reserva.cgarant%TYPE,
      pnmovres IN sin_tramita_pago_gar.nmovres%TYPE,
      pnorden IN sin_tramita_pago_gar.norden%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera los datos del riesgo de hogar
      param in psseguro  : cÃƒÂ³digo de seguro
      param in pnriesgo  : cÃƒÂ³digo del riesgo
      param out mensajes : mensajes de error
      return             : ref cursor

      Bug 12668 - 24/02/2010 - AMC
   ***********************************************************************/
   FUNCTION f_get_datsitriesgo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /**************************************************************************
      FunciÃƒÂ³n que borra una tramitacion
      param in  pnsinies : nÃƒÂºmero de siniestro
      param in  pntramit : nÃƒÂºmero de tramitacion
      param in  pctiptra : numero de tipo de tramitacion
      param out mensajes : mensajes de error

      return              : 0 -> Tot correcte
                            1 -> S'ha produit un error

      Bug 12668 - 03/03/2010 - AMC
   ***********************************************************************/
   FUNCTION f_del_tramitacion(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pctiptra IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /**************************************************************************
       FunciÃƒÂ³n que indica si una reserva se puede modificar
       param in  pnsinies  : nÃƒÂºmero de siniestro
       param in  pntramit  : nÃƒÂºmero de tramitacion
       param in  pctipres  : CÃƒÂ³digo del tipo de reserva
       param in  pcgarant  : CÃƒÂ³digo de la garantia
       param in  pnmovres  : Numero de movimiento d la reserva
       param in  psproduc  : Codigo del producto
       param in  pcactivi  : Codigo de la actividad
       param in  pmodificable : 0 - No modificable
                                1 - Modificable
       param out mensajes  : Mensajes de error
       return              : 0 -> Tot correcte
                             Codigo error -> S'ha produit un error

       Bug 14490 - 19/05/2010 - AMC
    ***********************************************************************/
   FUNCTION f_mov_reserva(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pctipres IN NUMBER,
      pctipgas IN NUMBER,   --26108
      pcgarant IN NUMBER,
      pnmovres IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pmodificable OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /**************************************************************************
      FunciÃƒÂ³n que devuelve si se permite borrar una reserva
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  pntramit  : nÃƒÂºmero de tramitacion
      param in  pctipres  : CÃƒÂ³digo del tipo de reserva
      param in  pcgarant  : CÃƒÂ³digo de la garantia
      param in  pfresini  : Fecha de inicio de la reserva
      param in  psproduc  : Codigo del producto
      param in  pcactivi  : Codigo de la actividad
      param out pmodificable : 0 - No modificable
                               1 - Modificable
      param out mensajes  : Mensajes de error
      return              : 0 -> Tot correcte
                            Codigo error -> S'ha produit un error

      Bug 14490 - 20/05/2010 - AMC
   ***********************************************************************/
   FUNCTION f_perdelreserva(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pctipres IN NUMBER,
      pctipgas IN NUMBER,   -- 26108
      pcgarant IN NUMBER,
      pfresini IN DATE,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pmodificable OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /**************************************************************************
      FunciÃƒÂ³n que devuelve si se debe generar la reserva y el destinatario
      param in  pccausin  : nÃƒÂºmero de siniestro
      param in  pcmotsin  : nÃƒÂºmero de tramitacion
      param in  pcgarant  : CÃƒÂ³digo de la garantia
      param in  psproduc  : Codigo del producto
      param in  pcactivi  : Codigo de la actividad
      param out pgenerar : 0 - No se genera
                           1 - Se genera
      param out mensajes  : Mensajes de error
      return             : 0 -> Tot correcte
                            Codigo error -> S'ha produit un error

      Bug 14752 - 01/06/2010 - AMC
   ***********************************************************************/
   FUNCTION f_gen_resdestinatari(
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      pcgarant IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pgenerar OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /**************************************************************************
      FunciÃƒÂ³n que devuelve el capital de una garantia
      param in  pcgarant  : CÃƒÂ³digo de la garantia
      param in  psseguro  : CÃƒÂ³digo del seguro
      param in  pnsinies  : CÃƒÂ³digo del siniestro
      param out pcapital  : Capital de la garantia
      param out mensajes  : mensajes de error
      return              : 0 -> Tot correcte
                           Codigo error -> S'ha produit un error

      Bug 14816 - 02/06/2010 - AMC
   ***********************************************************************/
   FUNCTION f_get_capitalgar(
      pcgarant IN NUMBER,
      psseguro IN NUMBER,
      pnsinies IN VARCHAR2,
      pcapital OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

  /*************************************************************************
        funciÃƒÂ³n borra todo el objeto citacion de tramitaciones
        param in pnsinies : numero de siniestro
        param in pntramit : numero de siniestro
        param in pncitacion : numero de citacion
        param in out mensajes : mensajes de error

   *************************************************************************/
   FUNCTION f_del_citacion(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pncitacion IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************
        funciÃƒÂ³n borra todo el objeto destinatario de tramitaciones
        param in pnsinies : numero de siniestro
        param in pntramit : numero de siniestro
        param in pctipdes : tipo de destinatario
        param in psperson : codigo de destinario
        param in out mensajes : mensajes de error

        Bug 14766 - 03/06/2010 - AMC
   *************************************************************************/
   FUNCTION f_del_destinatario(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pctipdes IN NUMBER,
      psperson IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
        funciÃƒÂ³n borra un apunte de la agenda
        param in pnsinies : numero de siniestro
        param in pntramit : numero de siniestro
        param in pnlinage : numero de linea
        param in out mensajes : mensajes de error

        Bug 15153 - 23/06/2010 - AMC
   *************************************************************************/
   FUNCTION f_del_agenda(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnlinage IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /**************************************************************************
       FunciÃƒÂ³n que retorna los siniestros de una pÃƒÂ³liza, siendo optativo filtrar por su nÃƒÂºmero de riesgo.
       param in  psseguro  : cÃƒÂ³digo que identifica la pÃƒÂ³liza en AXIS
       param in  pnriesgo  : cÃƒÂ³digo que identifica el riesgo de la pÃƒÂ³liza en AXIS
       param out mensajes  : mensajes de error
       return sys_refcursor: cursor que devuelve el listado

       Bug 15965 - 10/09/2010 - SRA
    ***********************************************************************/
   FUNCTION f_consulta_lstsini_riesgo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      plstsini OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- BUG 0015669 - 10/2010 - JRH  -  Alta prestacions en forma de renda (PL)

   /***********************************************************************
      Recupera los datos de una prestaciÃƒÂ³n
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
      param in  psperson  : nÃƒÂºmero identificativo del destinatario
      param in  pctipdes  : nÃƒÂºmero tipo destinatario
      param out  ob_iax_sin_trami_destinatario :  ob_iax_sin_trami_destinatario
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_prestaren(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pctipdes IN NUMBER,
      t_prestaren OUT t_iax_sin_prestaren,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

        /***********************************************************************
     f_set_obj_sinprestaren
      Crea un objeto prestaciÃƒÂ³n con los datos.
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
      param in  psperson  : nÃƒÂºmero identificativo del destinatario
      param in  pctipdes  : nÃƒÂºmero tipo destinatario
      param out  vprestaren :  ob_iax_sin_PRESTAREN
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_set_obj_sinprestaren(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pctipdes IN NUMBER,
      psseguro IN NUMBER,
      pf1paren IN DATE,
      pfuparen IN DATE,
      pcforpag IN NUMBER,
      pibruren IN NUMBER,
      pcrevali IN NUMBER,
      pprevali IN NUMBER,
      pirevali IN NUMBER,
      pctipdur IN NUMBER,
      pnpartot IN NUMBER,
      pctipban IN NUMBER,
      pcbancar IN VARCHAR2,
      pcestado IN NUMBER,
      pcmotivo IN NUMBER,
      pcblopag IN NUMBER,
      pnmes1 IN NUMBER,
      pnmes2 IN NUMBER,
      pnmes3 IN NUMBER,
      pnmes4 IN NUMBER,
      pnmes5 IN NUMBER,
      pnmes6 IN NUMBER,
      pnmes7 IN NUMBER,
      pnmes8 IN NUMBER,
      pnmes9 IN NUMBER,
      pnmes10 IN NUMBER,
      pnmes11 IN NUMBER,
      pnmes12 IN NUMBER,
      pnpresta IN NUMBER,
      vprestaren IN OUT t_iax_sin_prestaren,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/***********************************************************************
     f_del_prestaren
      Borra una prestaciÃƒÂ³n
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n
      param in  psperson  : nÃƒÂºmero identificativo del destinatario
      param in  pctipdes  : nÃƒÂºmero tipo destinatario
      param in  psseguro :  Seguro
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_del_prestaren(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pctipdes IN NUMBER,
      pnpresta IN NUMBER,
      --psseguro IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-- Fi BUG 0015669 - 10/2010 - JRH
   /*************************************************************************
      FUNCTION f_get_productos_pagos
      Nos devuelve los productos de RENTAS o BAJA
      param in pcempres    : Empresa
      param in idioma   : Idioma
      param in pfiltro   : 1 REntas, 2 Bajas
      return           : cÃƒÂ³digo de error

       ---- Bug 15044 - 08/11/2010 - XPL
   *************************************************************************/
   FUNCTION f_get_productos_pagos(
      pcempres IN NUMBER,
      pfiltro IN NUMBER,
      pproductos OUT t_iax_info,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION funciÃƒÂ³n que hace los pagos de rentas
      Nos devuelve los productos de RENTAS o BAJA
      param in p_data    : Fecha
      param in pproductos   : Objeto que contiene los productos a hacer los pagos
      param out pncobro   : Numero de cobros
      return           : cÃƒÂ³digo de error

       ---- Bug 15044 - 08/11/2010 - XPL
   *************************************************************************/
   FUNCTION f_pago_renta_aut(
      p_data IN DATE,
      pproductos IN t_iax_info,
      pncobros OUT NUMBER,
      psproces OUT NUMBER,   -- Bug 16580 - 15/11/2010 - AMC
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- BUG16506:DRA:14/12/2010:Inici
   /*************************************************************************
      FUNCTION que devuelve el tramitador y la unidad de tramitaciÃƒÂ³n del usuario
      Si no tiene unidad de tramitaciÃƒÂ³n devolverÃƒÂ¡ la unidad por defecto, pero
      devolverÃƒÂ¡ un 1 para indicar que no es el tramitador del usuario
      param in p_cuser      : Fecha
      param out p_cunitra   : Objeto que contiene los productos a hacer los pagos
      param out p_ctramitad : Numero de cobros
      return                : 0 --> OK, 1 --> No es el del usuario, NULL --> Error
   *************************************************************************/
   FUNCTION f_get_tramitador_defecto(
      p_cempres IN NUMBER,
      p_cuser IN VARCHAR2,
      p_sseguro IN NUMBER,
      p_ccausin IN NUMBER,
      p_cmotsin IN NUMBER,
      p_nsinies IN VARCHAR2,   -- 22108:ASN:18/05/2012
      p_ntramte IN NUMBER,   -- 22108:ASN:18/05/2012
      p_ntramit IN NUMBER,
      p_cunitra OUT VARCHAR2,
      p_ctramitad OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- BUG16506:DRA:14/12/2010:Fi

   --bug.: 15738 - ICV - 21/12/2010
   /*************************************************************************
        FunciÃƒÂ³n que ejecuta el map 405 (Carta de pago)
        param in  psidepag : cÃƒÂ³digo de pago de siniestros
        param out  pnomfichero : Nombre fichero
     *************************************************************************/
   FUNCTION f_imprimir_pago(
      psidepag IN NUMBER,
      pcmapead IN VARCHAR2,
      pnomfichero OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

--Fin bug.: 15738

   -- Ini Bug 18554 - 14/06/2011 - SRA
   /*************************************************************************
        FunciÃƒÂ³n que llama a pac_siniestros.f_get_hissin_siniestros para recuperar un cursor con datos del
        histÃƒÂ³rico de siniestros
        pnsinies sin_tramita_movimiento.nsinies%TYPE : nÃƒÂºmero de siniestro
        mensajes t_iax_mensajes                      : objeto mensajes
        return                                       : cursor con datos del histÃƒÂ³rico de siniestros
     *************************************************************************/
   FUNCTION f_get_hissin_siniestros(
      pnsinies IN sin_tramita_movimiento.nsinies%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- Fin Bug 18554 - 14/06/2011 - SRA

   -- ini Bug 0018812 - 21/06/2011 - JMF
   /*************************************************************************
        FunciÃƒÂ³n que muestra descipciÃƒÂ³n pÃƒÂ³liza de ahorro o de renta.
        param in  psidepag : cÃƒÂ³digo de pago de siniestros
        param in  ptip: 1=Ahorro, resto = Renta.
        param out ptexto : descipcion
     *************************************************************************/
   FUNCTION f_get_mensaje_polrenta(
      psidepag IN NUMBER,
      ptip IN NUMBER DEFAULT 2,
      ptexto IN OUT VARCHAR2)
      RETURN NUMBER;

-- fin Bug 0018812 - 21/06/2011 - JMF

   /***********************************************************************
      FUNCTION f_get_juzgados
         Recupera la colecciÃƒÂ³n de juzgados
         param in pnsinies    : nÃƒÂºmero del siniestro
         param in pntramit    : nÃƒÂºmero tramitaciÃƒÂ³n siniestro
         param out pjuzgados  : t_iax_sin_tramita_juzgado
         param out mensajes   : mensajes de error
         return               : 0 OK
                                1 Error
      Bug 19821 - 10/11/2011 - MDS
   ***********************************************************************/
   FUNCTION f_get_juzgados(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pjuzgados OUT t_iax_sin_tramita_juzgado,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_get_juzgado
         Recupera un juzgado
         param in pnsinies    : nÃƒÂºmero del siniestro
         param in pntramit    : nÃƒÂºmero tramitaciÃƒÂ³n siniestro
         param in pnlinjuz    : nÃƒÂºmero de lÃƒÂ­nea de juzgado
         param out pjuzgado   : ob_iax_sin_tramita_juzgado
         param out mensajes   : mensajes de error
         return               : 0 OK
                                1 Error
      Bug 19821 - 10/11/2011 - MDS
   ***********************************************************************/
   FUNCTION f_get_juzgado(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnlinjuz IN NUMBER,
      pjuzgado OUT ob_iax_sin_tramita_juzgado,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_set_juzgados
         Graba la colecciÃƒÂ³n de juzgados
         param in pnsinies    : nÃƒÂºmero del siniestro
         param in pjuzgados   : t_iax_sin_tramita_juzgado
         param out mensajes   : mensajes de error
         return               : 0 OK
                                1 Error
      Bug 19821 - 10/11/2011 - MDS
   ***********************************************************************/
   FUNCTION f_set_juzgados(
      pnsinies IN VARCHAR2,
      pjuzgados IN t_iax_sin_tramita_juzgado,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_set_juzgado
         Graba un juzgado
         param in pnsinies    : nÃƒÂºmero del siniestro
         param in pjuzgado    : ob_iax_sin_tramita_juzgado
         param out mensajes   : mensajes de error
         return               : 0 OK
                                1 Error
      Bug 19821 - 10/11/2011 - MDS
   ***********************************************************************/
   FUNCTION f_set_juzgado(
      pnsinies IN VARCHAR2,
      pjuzgado IN ob_iax_sin_tramita_juzgado,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_set_objeto_juzgado
         Guarda en una variable global de la capa IAX los valores del objeto
         param in pnsinies  : nÃƒÂºmero del siniestro
         param in pntramit  : nÃƒÂºmero tramitaciÃƒÂ³n siniestro
         param in pnlinjuz  : nÃƒÂºmero de lÃƒÂ­nea de juzgado
         ...
         ...
         ...
         param out pjuzgado   : ob_iax_sin_tramita_juzgado
         param out mensajes   : mensajes de error
         return               : 0 -> Todo correcto
                                1 -> Se ha producido un error
      Bug 19821 - 10/11/2011 - MDS
   ***********************************************************************/
   FUNCTION f_set_objeto_juzgado(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnlinjuz IN NUMBER,
      pcorgjud IN NUMBER,
      pnorgjud IN VARCHAR2,   --BUG 22048 --ETM --SE MODIFICA EL CAMPO DE NUMERICO A VARCHAR
      ptrefjud IN VARCHAR2,
      pcsiglas IN NUMBER,
      ptnomvia IN VARCHAR2,
      pnnumvia IN NUMBER,
      ptcomple IN VARCHAR2,
      ptdirec IN VARCHAR2,
      pcpais IN NUMBER,
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      pcpostal IN VARCHAR2,
      ptasunto IN VARCHAR2,
      pnclasede IN NUMBER,
      pntipopro IN NUMBER,
      pnprocedi IN VARCHAR2,
      pfnotiase IN DATE,
      pfrecpdem IN DATE,
      pfnoticia IN DATE,
      pfcontase IN DATE,
      pfcontcia IN DATE,
      pfaudprev IN DATE,
      pfjuicio IN DATE,
      pcmonjuz IN VARCHAR2,
      pcpleito IN NUMBER,
      pipleito IN NUMBER,
      piallana IN NUMBER,
      pisentenc IN NUMBER,
      pisentcap IN NUMBER,
      pisentind IN NUMBER,
      pisentcos IN NUMBER,
      pisentint IN NUMBER,
      pisentotr IN NUMBER,
      pcargudef IN NUMBER,
      pcresplei IN NUMBER,
      pcapelant IN NUMBER,
      pthipoase IN VARCHAR2,
      pthipoter IN VARCHAR2,
      pttipresp IN VARCHAR2,
      pcopercob IN NUMBER,
      ptreasmed IN VARCHAR2,
      pcestproc IN NUMBER,
      pcetaproc IN NUMBER,
      ptconcjur IN VARCHAR2,
      ptestrdef IN VARCHAR2,
      ptrecomen IN VARCHAR2,
      ptobserv IN VARCHAR2,
      pfcancel IN DATE,
      pjuzgado IN OUT ob_iax_sin_tramita_juzgado,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_del_juzgado
         Borra un juzgado
         param in pnsinies    : nÃƒÂºmero del siniestro
         param in pntramit    : nÃƒÂºmero tramitaciÃƒÂ³n siniestro
         param in pnlinjuz    : nÃƒÂºmero de lÃƒÂ­nea de juzgado
         param out mensajes   : mensajes de error
         return               : 0 -> Todo correcto
                                1 -> Se ha producido un error
      Bug 19821 - 10/11/2011 - MDS
   *************************************************************************/
   FUNCTION f_del_juzgado(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnlinjuz IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_get_demands
         Recupera la colecciÃƒÂ³n de demantante/demandado
         param in pnsinies    : nÃƒÂºmero del siniestro
         param in pntramit    : nÃƒÂºmero tramitaciÃƒÂ³n siniestro
         param out pdemands   : t_iax_sin_tramita_demand
         param out mensajes   : mensajes de error
         return               : 0 OK
                                1 Error
      Bug 19821 - 10/11/2011 - MDS
      Bug 20340/109094 - 15/03/2012 - AMC
   ***********************************************************************/
   FUNCTION f_get_demands(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pntipodem IN NUMBER,
      pdemands OUT t_iax_sin_tramita_demand,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_get_demand
         Recupera un demantante/demandado
         param in pnsinies    : nÃƒÂºmero del siniestro
         param in pntramit    : nÃƒÂºmero tramitaciÃƒÂ³n siniestro
         param in pnlindem    : nÃƒÂºmero de lÃƒÂ­nea de demantante/demandado
         param out pdemand    : ob_iax_sin_tramita_demand
         param out mensajes   : mensajes de error
         return               : 0 OK
                                1 Error
      Bug 19821 - 10/11/2011 - MDS
      Bug 20340/109094 - 15/03/2012 - AMC
   ***********************************************************************/
   FUNCTION f_get_demand(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnlindem IN NUMBER,
      pntipodem IN NUMBER,
      pdemand OUT ob_iax_sin_tramita_demand,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_set_demands
         Graba la colecciÃƒÂ³n de demantante/demandado
         param in pnsinies    : nÃƒÂºmero del siniestro
         param in pdemands    : t_iax_sin_tramita_demand
         param out mensajes   : mensajes de error
         return               : 0 OK
                                1 Error
      Bug 19821 - 10/11/2011 - MDS
   ***********************************************************************/
   FUNCTION f_set_demands(
      pnsinies IN VARCHAR2,
      pdemands IN t_iax_sin_tramita_demand,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_set_demand
         Graba un demantante/demandado
         param in pnsinies    : nÃƒÂºmero del siniestro
         param in pdemand     : ob_iax_sin_tramita_demand
         param out mensajes   : mensajes de error
         return               : 0 OK
                                1 Error
      Bug 19821 - 10/11/2011 - MDS
   ***********************************************************************/
   FUNCTION f_set_demand(
      pnsinies IN VARCHAR2,
      pdemand IN ob_iax_sin_tramita_demand,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_set_objeto_demand
         Guarda en una variable global de la capa IAX los valores del objeto
         param in pnsinies  : nÃƒÂºmero del siniestro
         param in pntramit  : nÃƒÂºmero tramitaciÃƒÂ³n siniestro
         param in pnlindem  : nÃƒÂºmero de lÃƒÂ­nea de demantante/demandado
         ...
         ...
         ...
         param out pdemand    : ob_iax_sin_tramita_demand
         param out mensajes   : mensajes de error
         return               : 0 -> Todo correcto
                                1 -> Se ha producido un error
      Bug 19821 - 10/11/2011 - MDS
   ***********************************************************************/
   FUNCTION f_set_objeto_demand(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnlindem IN NUMBER,
      psperson IN NUMBER,
      pntipodem IN NUMBER,
      pttramita IN VARCHAR2,
      psperson2 IN NUMBER,
      pnprocedi IN VARCHAR2,
      ptcompani IN VARCHAR2,
      pdemand IN OUT ob_iax_sin_tramita_demand,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_del_demand
         Borra un demantante/demandado
         param in pnsinies    : nÃƒÂºmero del siniestro
         param in pntramit    : nÃƒÂºmero tramitaciÃƒÂ³n siniestro
         param in pnlindem    : nÃƒÂºmero de lÃƒÂ­nea de demantante/demandado
         param out mensajes   : mensajes de error
         return               : 0 -> Todo correcto
                                1 -> Se ha producido un error
      Bug 19821 - 10/11/2011 - MDS
      Bug 20340/109094 - 15/03/2012 - AMC
   *************************************************************************/
   FUNCTION f_del_demand(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnlindem IN NUMBER,
      pntipodem IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

      /*************************************************************************
      FUNCTION f_actualiza_pago
         Actualiza campos del pago
         param in psidepag       : identificador del pago
         param in pmediopago     : medio de pago
         param in preferencia    : NÃƒÂºmero Factura/Referencia
         pimp in impuestos_recibidos : impuestos
         param out mensajes   : mensajes de error
         return               : 0 -> Todo correcto
                                1 -> Se ha producido un error
   *************************************************************************/
   FUNCTION f_actualiza_pago(
      psidepag IN NUMBER,
      pmediopago IN NUMBER,
      preferencia IN VARCHAR2,
      pfcambio IN DATE,
      ptotal IN NUMBER,
      piica IN NUMBER,
      piiva IN NUMBER,
      pireteica IN NUMBER,
      pireteiva IN NUMBER,
      piretenc IN NUMBER,
      pmoneda IN VARCHAR2 DEFAULT 'COP',
      piotrosgas  IN NUMBER,
      pibaseipoc  IN NUMBER,
      ppipoconsumo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

      /*************************************************************************
      FUNCTION f_gestiona_cobpag
         Borra un demantante/demandado
         param in psidepag    : nÃƒÂºmero del pago
         param in pnmovpag    : nÃƒÂºmero movimiento pago
         param in pcestpag    : nÃƒÂºmero de estado pago
         param in pfefepag    : fecha efecto pago
         param in pfcontab    : fecha contabilidad pago
         param out mensajes   : mensajes de error
         return               : 0 -> Todo correcto
                                1 -> Se ha producido un error
   *************************************************************************/
   FUNCTION f_gestiona_cobpag(
      psidepag IN NUMBER,
      pnmovpag IN NUMBER,
      pcestpag IN sin_tramita_movpago.cestpag%TYPE,
      pfefepag IN DATE,
      pfcontab IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Ini Bug 21172 - MDS - 02/03/2012
   /*************************************************************************
       FUNCTION f_get_reserva_multiple
          Devuelve las reservas efectuadas para un siniestro/trÃƒÂ¡mite

          param in  pnsinies : NÃƒÂºmero de siniestro
          param in  pntramit : NÃƒÂºmero de trÃƒÂ¡mite
          param out t_iax_sin_trami_reserva_mult
          param out t_iax_mensajes

          return            : 0 -> Todo correcto
                              1 -> Se ha producido un error
    *************************************************************************/
   FUNCTION f_get_reserva_multiple(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramita_reserva.ntramit%TYPE,
      pctramit IN sin_tramitacion.ctramit%TYPE,   -- 25812:ASN:23/01/2013
      t_reserva_mult OUT t_iax_sin_trami_reserva_mult,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-- Fin Bug 21172 - MDS - 02/03/2012

   /*************************************************************************
      FUNCTION f_del_defraudador
         Borra un defraudador
         param in pnsinies  : nÃƒÂºmero de siniestro
         param in pndefrau  : nÃƒÂºmero de defraudador
         param out mensajes : mensajes de error
         return             : 0 -> Todo correcto
                              1 -> Se ha producido un error
      Bug 21855 - 07/05/2012 - MDS
   *************************************************************************/
   FUNCTION f_del_defraudador(
      pnsinies IN sin_defraudadores.nsinies%TYPE,
      pndefrau IN sin_defraudadores.ndefrau%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_set_defraudadores
         Graba la colecciÃƒÂ³n de defraudadores
         param in pnsinies         : nÃƒÂºmero de siniestro
         param in pdefraudadores   : t_iax_defraudadores
         param out mensajes        : mensajes de error
         return                    : 0 OK
                                     1 Error
      Bug 21855 - 07/05/2012 - MDS
   ***********************************************************************/
   FUNCTION f_set_defraudadores(
      pnsinies IN sin_defraudadores.nsinies%TYPE,
      pdefraudadores IN t_iax_defraudadores,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_set_defraudador
         Graba un defraudador
         param in pnsinies         : nÃƒÂºmero de siniestro
         param in pdefraudador     : ob_iax_defraudadores
         param out mensajes        : mensajes de error
         return                    : 0 OK
                                     1 Error
      Bug 21855 - 07/05/2012 - MDS
   ***********************************************************************/
   FUNCTION f_set_defraudador(
      pnsinies IN sin_defraudadores.nsinies%TYPE,
      pdefraudador IN ob_iax_defraudadores,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_get_defraudadores
         Recupera la colecciÃƒÂ³n de defraudadores
         param in pnsinies         : nÃƒÂºmero de siniestro
         param out pdefraudadores  : t_iax_defraudadores
         param out mensajes        : mensajes de error
         return                    : 0 OK
                                     1 Error
      Bug 21855 - 07/05/2012 - MDS
   ***********************************************************************/
   FUNCTION f_get_defraudadores(
      pnsinies IN sin_defraudadores.nsinies%TYPE,
      pdefraudadores OUT t_iax_defraudadores,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_get_defraudador
         Recupera un defraudador
         param in pnsinies         : nÃƒÂºmero de siniestro
         param in pndefrau         : nÃƒÂºmero de defraudador
         param out pdefraudador    : ob_iax_defraudadores
         param out mensajes        : mensajes de error
         return                    : 0 OK
                                     1 Error
      Bug 21855 - 07/05/2012 - MDS
   ***********************************************************************/
   FUNCTION f_get_defraudador(
      pnsinies IN sin_defraudadores.nsinies%TYPE,
      pndefrau IN sin_defraudadores.ndefrau%TYPE,
      pdefraudador OUT ob_iax_defraudadores,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_set_objeto_defraudador
         Guarda en una variable global de la capa IAX los valores del objeto
         param in pnsinies        : nÃƒÂºmero de siniestro
         param in pndefrau        : nÃƒÂºmero de defraudador
         ...
         ...
         ...
         param out pdefraudador   : ob_iax_defraudadores
         param out mensajes       : mensajes de error
         return                   : 0 -> Todo correcto
                                    1 -> Se ha producido un error
      Bug 21855 - 07/05/2012 - MDS
   ***********************************************************************/
   FUNCTION f_set_objeto_defraudador(
      pnsinies IN sin_defraudadores.nsinies%TYPE,
      pndefrau IN sin_defraudadores.ndefrau%TYPE,
      psperson IN sin_defraudadores.sperson%TYPE,
      pctiprol IN sin_defraudadores.ctiprol%TYPE,
      pfiniefe IN sin_defraudadores.finiefe%TYPE,
      pffinefe IN sin_defraudadores.ffinefe%TYPE,
      pdefraudador IN OUT ob_iax_defraudadores,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_get_personas_defraudadores
         Recupera la lista de personas (defraudadores) relacionadas con el siniestro
         param in psseguro          : nÃƒÂºmero de seguro
         param in pnsinies          : nÃƒÂºmero de siniestro
         param in pntipodefraudador : 1-Asegurado, 2-Tomador, 3-Mediador, 4-Persona relacionada
         param out mensajes         : mensajes de error
         return                     : sys_refcursor
      Bug 21855 - 14/05/2012 - MDS
   *************************************************************************/
   FUNCTION f_get_personas_defraudadores(
      psseguro IN NUMBER,
      pnsinies IN sin_defraudadores.nsinies%TYPE,
      pntipodefraudador IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      FUNCTION f_get_tramitador
       Esta funcion devuelve el tramitador que toca, a la hora de dar de alta un tramite o
       una tramitacion. Para ello busca en el movimiento anterior (o en el tramite si lo hay
       y estamos dando de alta una tramitacion)
       Cuando se trate de un alta de tramite/tramitacion invocara la funcion que obtiene automaticamente
       el tramitador a partir de las condiciones parametrizadas.
       p_nsinies IN numero de siniestro
       p_ntramte IN numero de tramite
       p_ntramit IN numero de tramitacion
       p_cunitra   OUT unidad de tramitacion
       p_ctramitad OUT tramitador
   *************************************************************************/
   FUNCTION f_get_tramitador(
      pnsinies IN NUMBER,
      pntramte IN NUMBER,
      pntramit IN NUMBER,
      pcunitra OUT VARCHAR2,
      pctramitad OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_valida_tramitador
         Compara el limite de autonomia del tramitador con la provision de la tramitacion
         param in pnsinies          : nÃƒÂºmero de siniestro
         param in pntramit          : tramitacion
         param in pctramtad         : tramitador
         param in pccausin          : causa
         param in pcmotsin          : motivo
         param out mensajes         : mensajes de error
         return                     : 0 - OK ; 1 - Error
   *************************************************************************/
   FUNCTION f_valida_tramitador(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pctramitad IN VARCHAR2,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_tramitador_asignado
         param in pctramtad         : tramitador
         param out mensajes         : mensajes de error
         return                     : 0 - OK ; 1 - Error
         22670:ASN:28/06/2012
   *************************************************************************/
   FUNCTION f_tramitador_asignado(pctramitad IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_post_siniestro
         Acciones automaticas para ejecutar al dar de alta un siniestro
         param in pnsinies  : nÃƒÂºmero del siniestro
         return             : codigo error
   *************************************************************************/
   FUNCTION f_post_siniestro(
      pnsinies sin_siniestro.nsinies%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_gestion_asignada
         Crea mensaje cuando se asigna gestion automaticamente en alta de siniestro
         param in pnsinies  : nÃƒÂºmero del siniestro
         return             : codigo error
   *************************************************************************/
   FUNCTION f_gestion_asignada(
      pnsinies sin_siniestro.nsinies%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_estado_final
         Cambia el estado a siniestro/presiniestro en funcion de la reserva en alta
         param in pnsinies  : nÃƒÂºmero del siniestro
         return             : codigo error
   *************************************************************************/
   FUNCTION f_estado_final(
      pnsinies sin_siniestro.nsinies%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera la colecciÃƒÂ³n de documentos de una tramitacion de siniestros
      param in  pnsinies  : nÃƒÂºmero de siniestro
      param in  pntramit  : nÃƒÂºmero de tramitaciÃƒÂ³n o todos si esta vacio
      param out t_iax_sin_trami_documento :  t_iax_sin_trami_documento
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   -- Bug 0022153 - 19/07/2012 - JMF
   ***********************************************************************/
   FUNCTION f_get_sintradoc(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      t_docume OUT t_iax_sin_trami_documento,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_set_tramitador
         Graba el tramitador en el alta de siniestro
         param in pnsinies          : nÃƒÂºmero de siniestro
         param in pcunitra          : unidad tramitacion
         param in pctramtad         : tramitador
         param out mensajes         : mensajes de error
         return                     : 0 - OK ; 1 - Error
   *************************************************************************/
   FUNCTION f_set_tramitador(
      pnsinies IN NUMBER,
      pcunitra IN VARCHAR2,
      pctramitad IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-- Ini Bug 23805 - MDS - 03/10/2012

   /*************************************************************************
    FunciÃƒÂ³n que indica si alguna de las garantÃƒÂ­as contratadas y
    seleccionadas segÃƒÂºn pccausin, pcmotsin, pfsinies tiene asistencia.

      phay_asistencia OUT --> 0 : No , >0 : Si

      RETURN  0 : OK
             >0 : Error

   *************************************************************************/
   FUNCTION f_hay_asistencia(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      pfsinies IN DATE,
      phay_asistencia OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-- Fin Bug 23805 - MDS - 03/10/2012

   /*************************************************************************
      FUNCTION f_repetido
         Valida si hay otro siniestro con la misma causa y fecha
         param in pnsinies  : nÃƒÂºmero del siniestro
         return             : codigo error
         24491:ASN:31/10/2012
   *************************************************************************/
   FUNCTION f_repetido(pnsinies sin_siniestro.nsinies%TYPE, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Devuelve los siniestros que cumplan con el criterio de selecciÃƒÂ³n
      param in pnpoliza     : nÃƒÂºmero de pÃƒÂ³liza
      param in pncert       : nÃƒÂºmero de cerificado por defecto 0
      param in pnsinies     : nÃƒÂºmero del siniestro
      param in cestsin      : cÃƒÂ³digo situaciÃƒÂ³n del siniestro
      param in pnnumide     : nÃƒÂºmero identidad persona
      param in psnip        : nÃƒÂºmero identificador externo
      param in pbuscar      : nombre+apellidos a buscar de la persona
      param in ptipopersona : tipo de persona
                               1 tomador
                               2 asegurado
      param out mensajes    : mensajes de error
      return                : ref cursor

      Bug 23740/123618 - 08/10/2012 - AMC
   *************************************************************************/
   FUNCTION f_consultasini2(
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER DEFAULT -1,
      pnsinies IN VARCHAR2,
      pcestsin IN NUMBER,
      pnnumide IN VARCHAR2,
      psnip IN VARCHAR2,
      pbuscar IN VARCHAR2,
      ptipopers IN NUMBER,
      pnsubest IN NUMBER,
      pnsincia IN VARCHAR2,   --BUG 14587 - PFA - 13/08/2010 - AÃƒÂ±adir campo siniestro compaÃƒÂ±ia
      pfalta   IN DATE,
      pccompani IN NUMBER,   -- Bug 15006 - PFA - 16/08/2010 - nuevos campos en bÃƒÂºsqueda siniestros
      pnpresin IN VARCHAR2,
      pcsiglas IN NUMBER,
      ptnomvia IN VARCHAR2,
      pnnumvia IN NUMBER,
      ptcomple IN VARCHAR2,
      pcpostal IN VARCHAR2,
      pcpoblac IN NUMBER,
      pcprovin IN NUMBER,
      pfgisx IN FLOAT,
      pfgisy IN FLOAT,
      pfgisz IN FLOAT,
      ptdescri IN VARCHAR2,
      pctipmat IN NUMBER,
      pcmatric IN VARCHAR2,
      ptiporisc IN NUMBER,
      -- Fi Bug 15006 - PFA - 16/08/2010 - nuevos campos en bÃƒÂºsqueda siniestros
      pcpolcia IN VARCHAR2,   --Bug.: 14587 - ICV - 14/12/2010
      pcactivi IN NUMBER,   --Bug 18749 - 28/06/2011 - AMC
      pfiltro IN NUMBER,
      pcagente IN NUMBER,   -- Bug 21817 - MDS - 2/05/2012
      ptrefext IN VARCHAR2,   --  Bug: 0036232/207513    CJMR   16/06/2015
      pctipref IN NUMBER,   --  Bug: 0036232/207513    CJMR   16/06/2015
      ptdescrie IN VARCHAR2, -- BUG CONF_309 - 10/09/2016 - JAEG
      pncontrato  IN VARCHAR2, --AP CONF-219
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_mensajes_axissin049(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnlinjuz IN NUMBER,
      pcorgjud IN NUMBER,
      pnorgjud IN VARCHAR2,
      ptrefjud IN VARCHAR2,
      pcsiglas IN NUMBER,
      ptnomvia IN VARCHAR2,
      pnnumvia IN NUMBER,
      ptcomple IN VARCHAR2,
      ptdirec IN VARCHAR2,
      pcpais IN NUMBER,
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      pcpostal IN VARCHAR2,
      ptasunto IN VARCHAR2,
      pnclasede IN NUMBER,
      pntipopro IN NUMBER,
      pnprocedi IN VARCHAR2,
      pfnotiase IN DATE,
      pfrecpdem IN DATE,
      pfnoticia IN DATE,
      pfcontase IN DATE,
      pfcontcia IN DATE,
      pfaudprev IN DATE,
      pfjuicio IN DATE,
      pcmonjuz IN VARCHAR2,
      pcpleito IN NUMBER,
      pipleito IN NUMBER,
      piallana IN NUMBER,
      pisentenc IN NUMBER,
      pisentcap IN NUMBER,
      pisentind IN NUMBER,
      pisentcos IN NUMBER,
      pisentint IN NUMBER,
      pisentotr IN NUMBER,
      pcargudef IN NUMBER,
      pcresplei IN NUMBER,
      pcapelant IN NUMBER,
      pthipoase IN VARCHAR2,
      pthipoter IN VARCHAR2,
      pttipresp IN VARCHAR2,
      pcopercob IN NUMBER,
      ptreasmed IN VARCHAR2,
      pcestproc IN NUMBER,
      pcetaproc IN NUMBER,
      ptconcjur IN VARCHAR2,
      ptestrdef IN VARCHAR2,
      ptrecomen IN VARCHAR2,
      ptobserv IN VARCHAR2,
      pfcancel IN DATE,
      otexto OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_msg_responsable
         Envia mensaje al responsable de siniestros
         23101:ASN:21/12/2012
   *************************************************************************/
   FUNCTION f_msg_responsable(
      pnsinies sin_siniestro.nsinies%TYPE,
      pntramte IN sin_tramite.ntramte%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      pcconapu IN agd_apunte.cconapu%TYPE,
      plit1 IN axis_literales.slitera%TYPE,
      plit2 IN axis_literales.slitera%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_agente_npol(
      psseguro IN NUMBER,
      pcagente OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_preg_siniestro(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN VARCHAR2,
      pccausin IN NUMBER,   --27354:NSS:18/06/2013
      pcmotsin IN NUMBER,   --27354:NSS:18/06/2013
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_resp_siniestro(pcpregun IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_ins_preguntas(
      ptpreguntas IN t_iax_sin_preguntas,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_preguntas(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pnsinies IN NUMBER,
      ppreguntas OUT t_iax_sin_preguntas,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_lstlocaliza(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_localiza(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnlocali IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_vehiculo_asegurado(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- Bug 27514/147806 - 04/07/2013 - AMC
   FUNCTION f_get_limite_tramitador(
      pctramitad IN VARCHAR2,
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      pilimite OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   --Ini Bug 24708:NSS:10/10/2013
   FUNCTION f_get_lstoficinas(
      pcbanco IN NUMBER,
      pcofici IN NUMBER,
      ptofici IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_beneficiario_designado(
      pnsinies IN VARCHAR2,
      psseguro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

--Fin Bug 24708:NSS:10/10/2013

   --Ini Bug 28506:NSS:16/10/2013
   FUNCTION f_get_garantias_dependientes(pgarantias IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

--Fin Bug 28506:NSS:16/10/2013
--30/10/2013 :ASN :0024708: (POSPG500)- Parametrizacion - Sinestros/0157275 actualizar preguntas
   FUNCTION f_actualiza_preguntas(
      pnsinies IN VARCHAR2,
      psseguro IN NUMBER,
      pfsinies IN DATE,
      pcmotsin IN NUMBER,
      pccausin IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   --Ini Bug 28506:NSS:28/10/2013
   FUNCTION f_get_inf_reaseguro(pnsinies IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

--Fin Bug 28506:NSS:28/10/2013

   --BUG 24637/147756 - 28/08/2013 - NSS
   FUNCTION f_objcalcula_imports_detpagos(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pfordpag IN DATE,
      psidepag IN NUMBER,
      pctipgas IN NUMBER,
      pcconcep IN NUMBER,
      pimporte IN NUMBER,
      piretenc IN OUT NUMBER,
      ppretenc IN OUT NUMBER,
      piiva IN OUT NUMBER,
      ppiva IN OUT NUMBER,
      pineta IN OUT NUMBER,
      piica IN OUT NUMBER,
      ppica IN OUT NUMBER,
      pireteiva IN OUT NUMBER,
      ppreteiva IN OUT NUMBER,
      pireteica IN OUT NUMBER,
      ppreteica IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   --Ini Bug 29177/160128:NSS:13/01/2014
   FUNCTION f_ins_pago_contrato(
      psidepag IN NUMBER,
      pcdp IN VARCHAR2,
      ppospres IN VARCHAR2,
      pcrp IN VARCHAR2,
      pposcrp IN VARCHAR2,
      pcontrato IN VARCHAR2,
      pcgestor IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

--Fin Bug 29177/160128:NSS:13/01/2014

   -- BUG 28830:NSS:06/11/2013 - CompensaciÃƒÂ³n de siniestros contra cartera.
   FUNCTION f_get_cartera_pendiente(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN sin_siniestro.nriesgo%TYPE,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      psidepag IN sin_tramita_pago.sidepag%TYPE,
      ptotal OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_compensa_recibos_gar(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN sin_siniestro.nriesgo%TYPE,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      psidepag IN sin_tramita_pago.sidepag%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_compensa_recibos(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN sin_siniestro.nriesgo%TYPE,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      psidepag IN sin_tramita_pago.sidepag%TYPE,
      pntramit IN sin_tramita_pago.ntramit%TYPE,
      psperson IN sin_tramita_pago.sperson%TYPE,
      pctipdes IN sin_tramita_pago.ctipdes%TYPE,
      pctippag IN sin_tramita_pago.ctippag%TYPE,
      pipago IN sin_tramita_pago.isinret%TYPE,
      pcforpag IN sin_tramita_pago.cforpag%TYPE,
      pfordpag IN sin_tramita_pago.fordpag%TYPE,
      pcconpag IN sin_tramita_pago.cconpag%TYPE,
      pccauind IN sin_tramita_pago.ccauind%TYPE,
      pctipban IN sin_tramita_pago.ctipban%TYPE,
      pcbancar IN sin_tramita_pago.cbancar%TYPE,
      pcmonpag IN sin_tramita_pago.cmonpag%TYPE,
      pcultpag IN sin_tramita_pago.cultpag%TYPE,
      pctipres IN sin_tramita_pago_gar.ctipres%TYPE,
      pnmovres IN sin_tramita_pago_gar.nmovres%TYPE,
      pcgarant IN sin_tramita_pago_gar.cgarant%TYPE,
      pfperini IN sin_tramita_pago_gar.fperini%TYPE,
      pfperfin IN sin_tramita_pago_gar.fperfin%TYPE,
      pcmonres IN sin_tramita_pago_gar.cmonres%TYPE,
      pisinret IN sin_tramita_pago_gar.isinret%TYPE,
      pcmonpag_gar IN sin_tramita_pago_gar.cmonpag%TYPE,
      pisinretpag IN sin_tramita_pago_gar.isinretpag%TYPE,
      pfcambio IN sin_tramita_pago_gar.fcambio%TYPE,
      pcconpag_gar IN sin_tramita_pago_gar.cconpag%TYPE,
      pnorden IN sin_tramita_pago_gar.norden%TYPE,
      psidepag_cab IN sin_tramita_pago.sidepag%TYPE,
      ptotal OUT NUMBER,
      prestopag OUT NUMBER,
      psidepag_new OUT sin_tramita_pago.sidepag%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_pago_resto_asegurado(
      pnsinies IN sin_tramita_pago.nsinies%TYPE,
      psidepag IN sin_tramita_pago.sidepag%TYPE,
      pctipres IN sin_tramita_pago_gar.ctipres%TYPE,
      pnmovres IN sin_tramita_pago_gar.nmovres%TYPE,
      pimporte IN NUMBER,
      pfperini IN sin_tramita_pago_gar.fperini%TYPE,
      pfperfin IN sin_tramita_pago_gar.fperfin%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_anula_pago(
      psidepag IN sin_tramita_pago.sidepag%TYPE,
      pfecha IN DATE,
      pnsinies IN sin_tramita_pago.nsinies%TYPE,
      pntramit IN sin_tramita_pago.ntramit%TYPE,
      pctipres IN sin_tramita_pago_gar.ctipres%TYPE,
      pcgarant IN sin_tramita_pago_gar.cgarant%TYPE,
      pcmonres IN sin_tramita_pago_gar.cmonres%TYPE,
      pipago IN sin_tramita_pago.isinret%TYPE,
      pfperini IN sin_tramita_pago_gar.fperini%TYPE,
      pfperfin IN sin_tramita_pago_gar.fperfin%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_cobpag_compensados(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      psidepag IN sin_tramita_pago.sidepag%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_valida_exist_res_noindem(
      psidepag IN sin_tramita_pago.sidepag%TYPE,
      pexisten OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_valida_exist_recib_remesados(
      psseguro IN seguros.sseguro%TYPE,
      pexisten OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-- FIN BUG 28830:NSS:06/11/2013 - CompensaciÃƒÂ³n de siniestros contra cartera.

   -- BUG 30342:DEV:12/03/2014 - Modulo de Autorizaciones para pagos de Siniestros
   FUNCTION f_get_lst_pagos(
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pnsinies IN VARCHAR2,
      psidepag IN NUMBER,
      pcconcep IN NUMBER,
      pimpmin IN NUMBER,
      pcestval IN NUMBER,
      pcespag IN NUMBER,
      psperson IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_tratar_pagos(
      ptblpago IN VARCHAR2,
      pcestval2 IN NUMBER,
      pcestpag2 IN NUMBER,
      pcestpag1 IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-- fin BUG 30342:DEV:12/03/2014 - Modulo de Autorizaciones para pagos de Siniestros

   -- BUG xxx:NSS:15/04/2014 -
   FUNCTION f_get_certif_0(
      psseguro IN NUMBER,
      vcertif0 OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-- FIN BUG xxx:NSS:15/04/2014

   -- BUG 31294/174788: :NSS:18/06/2014 -
   FUNCTION f_get_imp_ult_mov_reserva(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pctipres IN NUMBER,
      pctipgas IN NUMBER,
      pcgarant IN NUMBER,
      pfresini IN DATE,
      pfresfin IN DATE,
      pireserva OUT NUMBER,
      pipago OUT NUMBER,
      pirecobro OUT NUMBER,
      pitotimp OUT NUMBER,
      pitotret OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-- FIN BUG 31294/174788: :NSS:18/06/2014 -

   -- BUG 0033345 17/11/2014.
   FUNCTION f_set_campo_plantilla(
      pnsinies IN VARCHAR2,
      pccodplan IN VARCHAR2,
      pndocume IN VARCHAR2,
      pccampo IN VARCHAR2,
      ptcampo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- BUG 33345/0195569
   FUNCTION f_get_documentacion_pendiente(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      ptlisdoc IN OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_hay_lista_innominados(
      psproduc IN productos.sproduc%TYPE,
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN riesgos.nriesgo%TYPE,
      pnasegur OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_anula_pago_sin(
      psidepag IN sin_tramita_pago.sidepag%TYPE,
      pfecha IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_sin_trami_doc(pnsinies IN sin_siniestro.nsinies%TYPE,
                                pntramit IN sin_tramitacion.ntramit%TYPE,
                                pndocume IN NUMBER,
                                mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;


   /***********************************************************************
     FUNCTION f_get_tramitaciones:
          obtiene las tramitaciones de un siniestro

   ***********************************************************************/
   FUNCTION f_get_tramitaciones(pnsinies IN VARCHAR2,
                            mensajes OUT t_iax_mensajes)
          RETURN SYS_REFCURSOR;

   /***********************************************************************
     FUNCTION f_get_reservas:
          obtiene las tramitaciones de un siniestro

   ***********************************************************************/
   FUNCTION f_get_reservas(pnsinies IN VARCHAR2,
                            mensajes OUT t_iax_mensajes)
          RETURN SYS_REFCURSOR;

  /***********************************************************************
     FUNCTION f_pagos_avion:
          f_pagos_avion

   ***********************************************************************/
   FUNCTION f_pagos_avion(pnsinies in varchar2, -- NÃƒÅ¡MERO DE SINIESTRO
                          pntramit in number, -- NÃƒÅ¡MERO DE TRAMITACIÃƒâ€œN
                          pnmovres in number, -- NÃƒÅ¡MERO MOVIMIENTO RESERVA
                          pctipres in number, -- CÃƒâ€œDIGO DE TIPO DE RESERVA
                          pctipgas in number, -- CÃƒâ€œDIGO DE TIPO DE GASTO
                          pcgarant in number, -- CÃƒâ€œDIGO DE GARANTÃƒÂA
                          pcmonres in varchar2, -- MONEDA DE LA RESERVA
                          pnnumide_agencia in varchar2, -- NÃƒÅ¡MERO DE IDENTIFICACIÃƒâ€œN DE LA AGENCIA DE VIAJES
                          psperson_agencia in number,
                          pnnumide_aero in varchar2, -- NÃƒÅ¡MERO DE IDENTIFICACIÃƒâ€œN DE LA COMPAÃƒâ€˜ÃƒÂA AÃƒâ€°REA
                          psperson_aero  in number,
                          pnfacref in varchar2,-- NÃƒÅ¡MERO DE FACTURA
                          pffacref in date, -- FECHA DE FACTURA
                          ptobserva in varchar2, -- OBSERVACIONES
                          pisinret_aero in number, -- IMPORTE BRUTO PASAJE AÃƒâ€°REO
                          ppiva_aero in number, -- PORCENTAJE DE IVA PASAJE AÃƒâ€°REO
                          piiva_aero in number, -- IMPORTE IVA PASAJE AÃƒâ€°REO
                          piotrosgas_aero in number, -- IMPORTE DE OTROS GASTOS / TASA AEROPORTUARIA DEL PASAJE AÃƒâ€°REO
                          pineto_aero in number, -- IMPORTE NETO PASAJE AÃƒâ€°REO
                          pisinret_agencia in number, -- IMPORTE BRUTO AGENCIA
                          ppiva_agencia in number, -- PORCENTAJE IVA AGENCIA
                          piiva_agencia in number, -- IMPORTE IVA AGENCIA
                          pineto_agencia in number,-- IMPORTE NETO AGENCIA
                          --IAXIS 7654 AABC carga masiva pgos de tiquetes 
                          pcconpag_aero IN NUMBER,
                          pcconpag_agen IN NUMBER,
                          pcmovres IN NUMBER,
                          pidres   IN NUMBER,
                          --IAXIS 7654 AABC carga masiva pgos de tiquetes
                          mensajes out t_iax_mensajes )
          RETURN NUMBER;

  /***********************************************************************
       FUNCTION f_get_sin_tramita_apoyo:
            obtener los datos de una solicitud de apoyo tecnico

     ***********************************************************************/
  FUNCTION f_get_sin_tramita_apoyo (psintapoy IN NUMBER,
                                    pnsinies  IN VARCHAR2,
                                    pntramit  IN NUMBER,
                                    mensajes  OUT t_iax_mensajes)
     RETURN SYS_REFCURSOR;


  /***********************************************************************
     FUNCTION f_set_sin_tramita_apoyo:
          guardar una solicitud de apoyo tecnico

   ***********************************************************************/
   FUNCTION f_set_sin_tramita_apoyo (psintapoy  IN NUMBER,
                                     pnsinies   IN VARCHAR2,
                                     pntramit   IN NUMBER,
                                     pnapoyo    IN NUMBER,
                                     pcunitra   IN VARCHAR2,
                                     pctramitad IN VARCHAR2,
                                     pfingreso  IN DATE,
                                     pftermino  IN DATE,
                                     pfsalida   IN DATE,
                                     ptobserva  IN VARCHAR2,
                                     ptlocali   IN VARCHAR2,
                                     pcsiglas   IN NUMBER,
                                     ptnomvia   IN VARCHAR2,
                                     pnnumvia   IN NUMBER,
                                     ptcomple   IN VARCHAR2,
                                     pcpais     IN NUMBER,
                                     pcprovin   IN NUMBER,
                                     pcpoblac   IN NUMBER,
                                     pcpostal   IN VARCHAR2,
                                     pcviavp    IN NUMBER,
                                     pclitvp    IN NUMBER,
                                     pcbisvp    IN NUMBER,
                                     pcorvp     IN NUMBER,
                                     pnviaadco  IN NUMBER,
                                     pclitco    IN NUMBER,
                                     pcorco     IN NUMBER,
                                     pnplacaco  IN NUMBER,
                                     pcor2co    IN NUMBER,
                                     pcdet1ia   IN NUMBER,
                                     ptnum1ia   IN VARCHAR2,
                                     pcdet2ia   IN NUMBER,
                                     ptnum2ia   IN VARCHAR2,
                                     pcdet3ia   IN NUMBER,
                                     ptnum3ia   IN VARCHAR2,
                                     plocalidad IN VARCHAR2,
                                     pfalta     IN DATE,
                                     pcusualt   IN VARCHAR2,
                                     pfmodifi   IN DATE,
                                     pcusumod   IN VARCHAR2,
                                     ptobserva2 IN VARCHAR2,
                                     pcagente   IN NUMBER,
                                     psperson   IN NUMBER,
                                     mensajes   OUT t_iax_mensajes)
      RETURN NUMBER;

  /***********************************************************************
     FUNCTION f_del_sin_tramita_apoyo:
          eliminar una solicitud de apoyo tecnico

   ***********************************************************************/
  FUNCTION f_del_sin_tramita_apoyo (psintapoy IN NUMBER,
                                    pnsinies  IN VARCHAR2,
                                    pntramit  IN NUMBER,
                                    mensajes  OUT t_iax_mensajes)
     RETURN NUMBER;
     
    
/***********************************************************************
       BUG:3609
     FUNCTION f_get_clasificasiniestro:
             ClasificaciÃ³n de siniestros
            autor: A.B - 05/06/2019

***********************************************************************/ 
     FUNCTION f_get_clasificasiniestro (pnsinies IN VARCHAR2, pnpagos  IN NUMBER,  pntramita  IN NUMBER, mensajes OUT t_iax_mensajes)
        RETURN sys_refcursor;
  /*************************************************************************
      FUNCTION f_ins_estimasini
         Inserta a la tabla sin_tramita_estsiniestro.
         param in pnsinies : numero de siniestro
         param in ntramit  : numero de tramitacion
         param in nmovimi  : numero de movimiento
         param in nmaxpp   : maxima perdida probable
         param in ncontin   : valor de la contingencia
         param in nriesgo   : valor del riesgo
         param in cobserv   : observaciones
         param in pnclasepro valor Clase de proceso
         param in pninstproc valor Instancia del Proceso
         param in pnfallocp valor Fallo
         param in pncalmot valor Calificación Motivos
         param in pfcontingen valor Fecha
         param in ptobsfallo valor Observación de Fallo
         return            : 0 -> correcto
                             1 -> error
      IAXIS 3603 AABC 10/05/2019
   *************************************************************************/
   FUNCTION f_ins_estimasini(
      pnsinies IN NUMBER,
      pntramit  IN NUMBER,
      pnmovimi  IN NUMBER,
      pnmaxpp  IN NUMBER,
      pncontin  IN NUMBER,
      pnriesgo  IN NUMBER,
      pcobserv IN VARCHAR2
    ,pnclasepro IN NUMBER
    ,pninstproc IN NUMBER
    ,pnfallocp IN NUMBER
    ,pncalmot IN NUMBER
    ,pfcontingen IN DATE
    ,ptobsfallo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER; 
      
    /*************************************************************************
    f_get_tramita_estsini
    Traspasa los valores de los parametros a los atributos del objeto f_get_tramita_estsini.
    param in pnsinies                : no de siniestro
    param in pntramte                : no de tramite
    return                           : cursor
   ************************************************************************/
   FUNCTION f_get_tramita_estsini(PNSINIES IN VARCHAR2,
                                  PNTRAMIT IN NUMBER,
                                  MENSAJES IN OUT T_IAX_MENSAJES)
     RETURN SYS_REFCURSOR; 
--Inico IAXIS 4184 07/06/2019 MOS Incluir Cambios Cargue Masivo para pagos
  /***********************************************************************
     FUNCTION f_cargue masivo:
          realiza el cargue masivo de pagos
          autor: Marcelo Ozawa de Sousa - 03/06/2019
   ***********************************************************************/
  FUNCTION f_cargue_masivo (pnsinies in varchar2, -- NUMERO DE SINIESTRO
                          pntramit in number, -- NUMERO DE TRAMITACION
                          pnmovres in number, -- NUMERO MOVIMIENTO RESERVA
                          pctipres in number, -- CODIGO DE TIPO DE RESERVA
                          pctipgas in number, -- CODIGO DE TIPO DE GASTO                          
                          pcmonres in varchar2, -- MONEDA DE LA RESERVA            
                          pnnumide in varchar2, -- NUMERO DE IDENTIFICACION DE LA COMPANIA AEREA
                          psperson in number,
                          pnfacref in varchar2, -- NUMERO DE FACTURA
                          pffacref in date, -- FECHA DE FACTURA
                          ptobserva in varchar2, -- OBSERVACIONES
                          pisinret in number, -- IMPORTE BRUTO PASAJE AEREO
                          ppiva in number, -- PORCENTAJE DE IVA PASAJE AEREO
                          piiva in number, -- IMPORTE IVA PASAJE AEREO
                          pifranq in number, -- DEDUCIBLE
                          piotrosgas in number, -- IMPORTE DE OTROS GASTOS / TASA AEROPORTUARIA DEL PASAJE AEREO
                          pineto in number, -- IMPORTE NETO PASAJE AEREO
                          pcconpag in number, -- CONCEPTO DE PAGO
                          psproces IN NUMBER, -- NUMERO PROCESO 
                          --Inicio IAXIS 4184 14/06/2019 MOS Incluir forma de pago                          
                          pcforpag in number default null, -- FORMA DE PAGO
                          --Fin IAXIS 4184 14/06/2019 MOS Incluir forma de pago  
                          mensajes out t_iax_mensajes)
        RETURN NUMBER;
           
--Fin IAXIS 4184 07/06/2019 MOS Incluir Cambios Cargue Masivo para pagos    

 /*************************************************************************
    f_get_max_tramita_estsini
    obtener el maximo movimiento de la tabla sin_tramita_estsiniestro de acuerdo a un siniestro
    param in pnsinies                : no de siniestro
    param in pntramte                : no de tramite
    return                           : cursor
   ************************************************************************/
   FUNCTION f_get_max_tramita_estsini(PNSINIES IN VARCHAR2,
                                  MENSAJES IN OUT T_IAX_MENSAJES)
     RETURN SYS_REFCURSOR; 
	/*************************************************************************
        funcion borra localizacion de tramitacion
        param in pnsinies : numero de siniestro
        param in pntramit : numero de siniestro
        param in pnlocali : numero localizacion
   *************************************************************************/
   FUNCTION f_del_localizacion(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnlocali IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
     RETURN NUMBER;
	 
END pac_md_siniestros;
/