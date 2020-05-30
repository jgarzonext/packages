create or replace PACKAGE "PAC_IAX_SINIESTROS" AS
   /******************************************************************************
   NOMBRE:      PAC_IAX_SINIESTROS
   PROPÃ“SITO: Funciones para la gestiÃ³n de siniestro

   REVISIONES:
   Ver        Fecha        Autor             DescripciÃ³n
   ---------  ----------  ---------------  ------------------------------------
   1.0        17/02/2009   XPL i XVM        1. CreaciÃ³n del package.
   2.0        14/10/2009   XPL              2. bug. 11192. Alta de siniestros de Vida
   3.0        13/11/2009   DRA              3. 0011434: CEM - Cambios pantalla alta siniestros
   4.0        23/11/2009   AMC              4. 0011847: AGA - Error al introducir detalle recobro en siniestro
   5.0        08/01/2010   AMC              5. 0012604: CEM - Agenda de siniestros da error
   6.0        17/12/2009   AMC              6. Bug 11944 - Se crea la funciÃ³n f_get_histreservas
   7.0        15/01/2010   AMC              7. Bug 11945 - AGA - Crear columna PrevisiÃ³n Recobro para siniestros
   8.0        18/01/2010   AMC              8  Bug 12753 - CEM - CreaciÃ³n automÃ¡tica de destinatario
   9.0        20/01/2010   AMC              9. Bug 11849 - CEM - Crear botÃ³n generaciÃ³n pago automÃ¡tico en siniestros
   10.0       02/02/2010   LCF             10. Bug 10093 - CRE - Anyadir param bsuqueda pÃ³lizas
   11.0       01/02/2010   AMC             11. Bug 12207 - AGA - IntroducciÃ³n de reservas en productos de Baja (Salud)
   12.0       12/03/2010   AMC             12. Bug 12124 - AGA - Parametrizar imputaciÃ³n reserva y recobro en siniestro
   13.0       24/02/2010   AMC             13. Bug 12668 - AGA - NormalizaciÃ³n riesgo tipo direcciÃ³n
   14.0       18/05/2010   AMC             14. Bug 14490 - AGA - Se aÃ±ade los parametros pnmovres,psproduc,pcactivi
   15.0       31/05/2010   XPL             15. bug : 14607, AGA004 - Conceptos de pago a nivel de detalle del pago de un siniestro
   16.0       01/06/2010   AMC             16. bug 14752 - Se aÃ±aden nuevas funciones.
   17.0       23/06/2010   AMC             17. Bug 15153 - Se aÃ±aden los parametros sproduc y cactivi a la funciÃ³n f_del_objeto_sintramiagenda
   18.0       10/09/2010   SRA             18. Bug 15965 - CRT - Se crea nueva funciÃ³n PAC_IAX_SINIESTROS.F_CONSULTA_LSTSINI_RIESGO
   19.0       30/10/2010   JRH             19. BUG 15669 : Campos nuevos
   20.0       08/11/2010   XPL             20. 15044: AGA202 - Crear pantalla para pagos de rentas
   18.0       13/08/2010   PFA             18. 14587: CRT001 - AÃ±adir campo siniestro compaÃ±ia
   19.0       17/08/2010   PFA             19. 15006: MDP003 - Incluir nuevos campos en bÃºsqueda siniestros
   20.0       23/11/2010   ETM             27. 0016645: GRC - BÃºsqueda de siniestros
   21.0       15/12/2010   ICV             21. 0014587: CRT001 - AÃ±adir campo siniestro compaÃ±ia
   24.0       14/12/2010   DRA             24. 0016506: CRE - Pantallas de siniestros nuevo mÃ³dulo
   25.0       22/12/2010   ICV             23. 0015738: ENSA101 - Duplicat en PDF pagament en capital SONANGOL
   26.0       16/03/2011   JMF             26. 0017970: ENSA101- Campos pantallas de siniestros y mejoras
   27.0       02/05/2011   JMC             27. 0018379: LCOL701 - Desarrollo TrÃ¡mites Siniestros. ModificaciÃ³n funciones de tramitaciones.
   28.0       14/06/2011   SRA             28. 0018554: LCOL701 - Desarrollo de ModificaciÃ³n de datos cabecera siniestro y ver histÃ³rico (BBDD).
   29.0       12/07/2011   ICV             29. 0018977: LCOL_S001 - SIN -AsignaciÃ³n automÃ¡tica de tramitadores
   30.0       13/10/2011   JMC             30. 0019601: LCOL_S001-SIN - Subestado del pago
   31.0       07/11/2011   MDS             31. 0019981: LCOL_S001-SIN - ReteIVA y ReteICA en pagos
   32.0       21/10/2011   JMP             32. 0019832 LCOL_S001-SIN - Carpeta de siniestro
   33.0       10/11/2011   MDS             33. 0019821: LCOL_S001-SIN - TramitaciÃ³n judicial
   34.0       01/12/2011   AFM             34. 0019882: LCOL898 - 04 - Interface NotificaciÃ³n del Pago de una Orden de JDE a iAXIS
   35.0       09/12/2011   JMF             35. 0020472: LCOL_TEST-SIN - Reserva aÃ±adida sobre garantÃ­a contratada (no siniestrada aÃºn)
   36.0       05/01/2012   ETM             36. 0019896: LCOL_S001-SIN - Declarante del siniestro
   37.0       24/01/2012   JMP             37. 0020014: LCOL_S001-SIN - Reservas y pagos en tramitaciones cerradas
   38.0       02/03/2012   MDS             38. 0021172: LCOL_S001-SIN - Alta/ModificaciÃ³n masiva de reservas
   39.0       27/03/2012   ETM             39. 0021740: MDP_S001-SIN - Presiniestros
   40.0       03/05/2012   ETM             40.0022048: LCOL_S001-SIN - NÂº de juzgado cambiar tipo
   41.0       07/05/2012   MDS             41.0021855: MDP_S001-SIN - Detalle fraude
   42.0       16/05/2012   JMF             0022099: MDP_S001-SIN - TrÃ¡mite de asistencia
   43.0       31/05/2012   ASN             0022108: MDP_S001-SIN - Movimiento de trÃ¡mites
   44.0       19/06/2012   JMF             0022108: MDP_S001-SIN - Movimiento de trÃ¡mites
   45.0       05/07/2012   ASN             0022603: MDP_S001-Reserva global
   46.0       09/07/2012   JMF             0022490: LCOL_S001-SIN - Poder indicar que se generen los pagos como el Ãºltimo (Id=4604)
   47.0       19/07/2012   JMF             0022153 MDP_S001-SIN - NÃºmero de presiniestro y documentaciÃ³n
   48.0       27/09/2012   ASN             0023101: LCOL_S001-SIN - Apuntes de agenda automÃ¡ticos
   49.0       03/10/2012   MDS             0023805: MDP_S001-SIN - Visualizar/Ocultar casilla de asistencia en la pantalla de alta de siniestros
   50.0       24/10/2012   JMF             0023536 LCOL_S001-SIN - TramitaciÃ³n Otros
   51.0       24/10/2012   JMF             0023540 LCOL_S001-SIN - TramitaciÃ³n lesionados
   52.0       25/10/2012   MDS             0024192: LCOL898-Modificacions Notificaci? recaudo CxC
   53.0       03/12/2012   JMF             0024964: LCOL_S001-SIN - Seleccion tramitador en alta siniestro (Id=2754)
   54.0       23/01/2013   ASN             0025812: LCOL_S010-SIN - GarantÃ­as segÃºn tramitaciÃ³n
   55.0       15/03/2013   ASN             0026108: LCOL_S010-SIN - LCOL Tipo de gasto en reservas
   56.0       07/05/2013   NSS             0025607: LCOL_S001-SIN - Franquicias en siniestros
   57.0       23/08/2013   LPP             0027860: AGM800-En siniestras al a?adir documentos, no se guardan las descripciones de los documentos.
   58.0       26/02/2014   NSS             0028830/0166530: (POSND500)-N. Desarrollo: Siniestros: Compensaci?n cartera vs. Siniestros
   59.0       04/03/2014   NSS             0029224/0166661: (POSAN500)-Analisis-Siniestros-Nuevos Desarrollos
   60.0       27/02/2014   NSS             0024637/0147756: (POSAN500-AN-Sin) Analisis Desarrollo: Siniestros
   61.0       12/03/2014   DEV             0030342: POSPG500-Modulo de Autorizaciones para pagos de Siniestros
   62.0       24/03/2014   NSS             0024637/0147756: (POSAN500-AN-Sin) Analisis Desarrollo: Siniestros
   63.0       16/04/2014   NSS             0031040: POSPG500-Crear un nuevo tipo de destinatario para los colectivos
   64.0       22/04/2014   NSS             0029989/165377: LCOL_S001-SIN - Rechazo de tramitaciÃ³n Ãºnica
   65.0       24/02/2015   FRC             0033345/0193484: GeneraciÃ³n de documentos en los eventos de siniestros.
   66.0       17/03/2015   JCP             0035102/200437: Validacion de Innomidados, ff_hay_lista_innominados
   67.0       08/05/2015   VCG             0032470-0204062: AÃ±adir la referencia externa en el buscador de siniestros
   68.0       16/06/2015   CJMR            0036232/207513: AÃ±adir la referencia externa en el buscador de siniestros
   69.0       05/01/2016   JCP             0039475/222692: Modificar la select para recuperar tambiÃ©n el nuevo campo fdeteccion de sin_siniestro
   70.0       10/09/2016   JAEG            CONF-309: Desarrollo AT_CONF_SIN-07_ADAPTACION_CORE_SINIESTROS_BUSQUEDA_ANTECEDENTES
   71.0       02/05/2017   JGONZALEZ       CONF-693: Se incluyen campos de audiencia en agenda de citaciones
   72.0       11/08/2017   JGONZALEZ        CONF-1005: Desarrollo de GAP 67 solicitud de apoyo tecnico
   73.0       21/03/2019   AABC            IAXIS-2169 Adicion de Fecha de Alta.
   74.0       12/04/2019   AABC            IAXIS 3663 AABC 12/04/2019 Adicion campo observacion
   75.0       19/12/2019   DFRP            IAXIS-7731: LISTENER Cambio de estado del siniestro y creación de Campos: Valor, Fecha, número de pago, que comunica SAP a IAXIS     
   ******************************************************************************/
   -- BUG 9020 - 10/03/2009 - XPL I XVM - Nou model de dades del Sinistre
   vgobsiniestro ob_iax_siniestros;
   vproductos    t_iax_info;

   /*************************************************************************
      Devuelve los siniestros que cumplan con el criterio de selecciÃ³n
      param in pnpoliza     : nÃºmero de pÃ³liza
      param in pncert       : nÃºmero de cerificado por defecto 0
      param in pnsinies     : nÃºmero del siniestro
      param in cestsin      : cÃ³digo situaciÃ³n del siniestro
      param in pnnumide     : nÃºmero identidad persona
      param in psnip        : nÃºmero identificador externo
      param in pbuscar      : nombre+apellidos a buscar de la persona
      param in ptipopersona : tipo de persona
                               1 tomador
                               2 asegurado
      param out mensajes    : mensajes de error
      return                : ref cursor
   *************************************************************************/
   FUNCTION f_consultasini_old(pnpoliza  IN NUMBER,
                               pncertif  IN NUMBER DEFAULT -1,
                               pnsinies  IN NUMBER,
                               pcestsin  IN NUMBER,
                               pnnumide  IN VARCHAR2,
                               psnip     IN VARCHAR2,
                               pbuscar   IN VARCHAR2,
                               ptipopers IN NUMBER,
                               pnsubest  IN NUMBER,
                               mensajes  OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   FUNCTION f_set_gravar_presiniestro(pnsinies   IN VARCHAR2,
                                      psseguro   IN NUMBER,
                                      pnriesgo   IN NUMBER,
                                      pnmovimi   IN NUMBER,
                                      pfsinies   IN DATE,
                                      phsinies   IN VARCHAR2,
                                      pfnotifi   IN DATE,
                                      pccausin   IN NUMBER,
                                      pcmotsin   IN NUMBER,
                                      pcevento   IN VARCHAR2,
                                      pcculpab   IN NUMBER,
                                      pcreclama  IN NUMBER,
                                      pnasegur   IN NUMBER,
                                      pcmeddec   IN NUMBER,
                                      pctipdec   IN NUMBER,
                                      ptnomdec   IN VARCHAR2,
                                      ptnom1dec  IN VARCHAR2, --BUG 19896 --ETM --20/12/2011-AÃ±adir campo 1nombre de declarante
                                      ptnom2dec  IN VARCHAR2, --BUG 19896 --ETM --20/12/2011-AÃ±adir campo 2nombre de declarante
                                      ptape1dec  IN VARCHAR2,
                                      ptape2dec  IN VARCHAR2,
                                      ptteldec   IN VARCHAR2,
                                      ptmovildec IN VARCHAR2, --BUG 19896 --ETM --20/12/2011-AÃ±adir campo telefono mov de declarante
                                      ptemaildec IN VARCHAR2, --BUG 19896 --ETM --20/12/2011-AÃ±adir campo email  de declarante
                                      ptsinies   IN VARCHAR2,
                                      pcagente   IN NUMBER, -- Bug 21817 - MDS - 2/05/2012
                                      mensajes   OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera los datos de los tomadores de la pÃ³liza
      param in psseguro  : cÃ³digo de seguro
      param out mensajes : mensajes de error
      return             : T_IAX_TOMADORES con la colecciÃ³n de tomadores de la pÃ³liza
                           NULL si error
   ***********************************************************************/
   FUNCTION f_get_poltomadores_old(psseguro IN NUMBER,
                                   mensajes OUT t_iax_mensajes)
      RETURN t_iax_tomadores;

   /***********************************************************************
      Recupera los datos de los riesgos de la pÃ³liza
      param in psseguro  : cÃ³digo de seguro
      param out mensajes : mensajes de error
      return             : T_IAX_GESTRIESGOS con la colecciÃ³n de riesgos de la pÃ³liza
                           NULL si error
   ***********************************************************************/
   FUNCTION f_get_polriesgos_old(psseguro IN NUMBER,
                                 mensajes OUT t_iax_mensajes)
      RETURN t_iax_riesgos;

   /***********************************************************************
      Recupera los datos del Ãºltimo recibo de la pÃ³liza
      param in psseguro  : cÃ³digo de seguro
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_pollastrecibo_old(psseguro IN NUMBER,
                                    mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /***********************************************************************
      Recupera los datos de los recibos de la pÃ³liza
      param in psseguro  : cÃ³digo de seguro
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_polrecibos_old(psseguro IN NUMBER,
                                 mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /***********************************************************************
      Recupera las garantia vigentes de una la pÃ³liza para un determinado riesgo,
      a fecha de ocurrencia del siniestro
      param in psseguro  : cÃ³digo de seguro
      param in pnriesgo  : nÃºmero de riesgo
      param in pfsinies  : fecha de ocurrencia del siniestro
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_polgarantias_old(psseguro IN NUMBER,
                                   pnriesgo IN NUMBER,
                                   pfsinies IN DATE,
                                   mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /***********************************************************************
      Recupera los documentos necesarios para poder realizar la apertura del siniestro.
      param in psseguro  : cÃ³digo de seguro
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_documentacion_old(psseguro IN NUMBER,
                                    mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /***********************************************************************
      Recupera los datos del tramitador
      param out pcusuario : cÃ³digo del tramitador
      param out ptusuario : Nombre del tramitador
      param out mensajes  : mensajes de error
      return              : 1 -> Todo correcto
                            0 -> Se ha producido un error
   ***********************************************************************/
   FUNCTION f_get_tramitador_old(pctrami  OUT NUMBER,
                                 pttrami  OUT VARCHAR2,
                                 mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
      Graba los datos del siniestro en la variable global objeto del paquete
      param in  psseguro  : cÃ³digo de seguro
      param in  pnriesgo  : nÃºmero de riesgo
      param in  pfsinies  : fecha de ocurrencia del siniestro
      param in  phsinies  : hora de ocurrencia del siniestro
      param in  pfnotifi  : fecha de notificaciÃ³n del siniestro
      param in  pctrami   : cÃ³digo del tramitador del siniestro
      param in  ptsinies  : descripciÃ³n del siniestro
      param in  pcmotsin  : cÃ³digo del motivo del siniestro
      param in  pccausin  : cÃ³digo de la causa del siniestro
      param in  pcculpab  : cÃ³digo de la culpabilidad del siniestro
      param in  ptzonaocu : descripciÃ³n de la zona de ocurrencia del siniestro
      param out mensajes  : mensajes de error
      return              : 1 -> Todo correcto
                            0 -> Se ha producido un error
   ***********************************************************************/
   FUNCTION f_set_datsiniestro_old(psseguro  IN NUMBER,
                                   pnriesgo  IN NUMBER,
                                   pfsinies  IN DATE,
                                   phsinies  IN VARCHAR2,
                                   pfnotifi  IN DATE,
                                   pctrami   IN VARCHAR2,
                                   ptsinies  IN VARCHAR2,
                                   pcmotsin  IN NUMBER,
                                   pccausin  IN NUMBER,
                                   pcculpab  IN NUMBER,
                                   ptzonaocu IN VARCHAR2,
                                   mensajes  OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
      Inserta la garantÃ­a como una de las vinculadas al siniestro que se estÃ¡ dando de alta
      param in pcgarant  : cÃ³digo de la garantÃ­a
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_set_garantias_old(pcgarant IN NUMBER,
                                mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
      Inserta el documento como uno de los vinculados al siniestro que se estÃ¡ dando de alta.
      param in pcdocume  : cÃ³digo del documento
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_set_documentacion_old(pcdocume IN NUMBER,
                                    mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
      Graba en la base de datos, los datos del siniestro guardado en la variable global del paquete
      param out mensajes  : mensajes de error
      return              : 1 -> Todo correcto
                            0 -> Se ha producido un error
   ***********************************************************************/
   FUNCTION f_altasiniestro_old(onsinies OUT NUMBER,
                                mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
      Recupera los datos de un determinado siniestro
      param in  pnsinies  : nÃºmero de siniestro
      param out mensajes  : mensajes de error
      return              : OB_IAX_SINIESTROS con la informaciÃ³n del siniestro
                            NULL -> Se ha producido un error
   ***********************************************************************/
   FUNCTION f_get_siniestro_old(pnsinies IN NUMBER,
                                mensajes OUT t_iax_mensajes)
      RETURN ob_iax_siniestros;

   /***********************************************************************
      Recupera los datos de un determinado siniestro
      param in  pnsinies  : nÃºmero de siniestro
      param out mensajes  : mensajes de error
      return              : OB_IAX_SINIESTROS con la informaciÃ³n del siniestro
                            NULL -> Se ha producido un error
   ***********************************************************************/
   FUNCTION f_get_siniestro(mensajes OUT t_iax_mensajes)
      RETURN ob_iax_siniestros;

   /***********************************************************************
      Recupera los datos de un determinado siniestro del tablas a objeto
      param in  pnsinies  : nÃºmero de siniestro
      param out mensajes  : mensajes de error
      return              : OB_IAX_SINIESTROS con la informaciÃ³n del siniestro
                            NULL -> Se ha producido un error
   ***********************************************************************/
   FUNCTION f_inicializasiniestro(psproduc IN NUMBER,
                                  pcactivi IN NUMBER,
                                  pnsinies IN VARCHAR2,
                                  mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
   Ens retorna la Ãºltima reserva per un sinistre donat,
     param in  pnsinies  : nÃºmero de siniestro
     param out ult_reserva  : Ãšltim moviment de la reserva del sinistre
     param out mensajes  : mensajes de error
     return              :  0 OK!
                            1 -> Se ha producido un error

   ***********************************************************************/
   FUNCTION f_get_ultimareserva(pnsinies    IN VARCHAR2,
                                ult_reserva OUT SYS_REFCURSOR,
                                mensajes    OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
     Ens retorna tots els pagaments d'un sinistre idependentment de la tramitaciÃ³,
     param in  pnsinies  : nÃºmero de siniestro
     param in  pctippag  : tipo de pago 2--> pago, 7 --> recobro
     param out pagosporsinistro : CapÃ§alera del pagament
     param out mensajes  : mensajes de error
     return              :  0 OK!
                            1 -> Se ha producido un error

   ***********************************************************************/
   FUNCTION f_get_pagosporsiniestro(pnsinies         IN VARCHAR2,
                                    pctippag         IN NUMBER,
                                    pagosporsinistro OUT SYS_REFCURSOR,
                                    mensajes         OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
     Ens retorna tots els pagaments d'una reserva i una tramitaciÃ³ concreta,
     param in  pnsinies  : nÃºmero de siniestro
     param in  pctippag  : tipo de pago 2--> pago, 7 --> recobro
     param out detallespagos : CapÃ§alera del pagament
     param out mensajes  : mensajes de error
     return              :  0 OK!
                            1 -> Se ha producido un error

   ***********************************************************************/
   FUNCTION f_get_detallespagos(pnsinies      IN VARCHAR2,
                                pntramit      IN NUMBER,
                                pctipres      IN NUMBER,
                                pctippag      IN NUMBER,
                                pcgarant      IN NUMBER,
                                psidepag      IN NUMBER,
                                pnmovres      IN NUMBER,
                                detallespagos OUT SYS_REFCURSOR,
                                mensajes      OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera los datos de los tomadores de la pÃ³liza
      param in psseguro  : cÃ³digo de seguro
      param out mensajes : mensajes de error
      return             : T_IAX_TOMADORES con la colecciÃ³n de tomadores de la pÃ³liza
                           NULL si error
   ***********************************************************************/
   FUNCTION f_get_poltomadores(psseguro IN NUMBER,
                               mensajes OUT t_iax_mensajes)
      RETURN t_iax_tomadores;

   /***********************************************************************
      Recupera los datos del Ãºltimo recibo de la pÃ³liza
      param in psseguro  : cÃ³digo de seguro
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_pollastrecibo(psseguro IN NUMBER,
                                mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /***********************************************************************
      Recupera los datos del Ãºltimo recibo de la pÃ³liza
      param in psseguro  : cÃ³digo de seguro
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_pollastrecibo2(psseguro IN NUMBER,
                                 pfsinies IN DATE,
                                 mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /***********************************************************************
      Graba los datos del siniestro en la variable global objeto del paquete
      param in  psseguro  : cÃ³digo de seguro
      param in  pnriesgo  : nÃºmero de riesgo
      param in  nmovimi   : NÃºmero Movimiento Seguro
      param in  pfsinies  : fecha de ocurrencia del siniestro
      param in  phsinies  : hora de ocurrencia del siniestro
      param in  pfnotifi  : fecha de notificaciÃ³n del siniestro
      param in  pccausin   : CÃ³digo Causa Siniestro
      param in  pcmotsin  : cÃ³digo del motivo del siniestro
      param in  pcevento   : CÃ³digo Evento Siniestro
      param in  pcculpab  : cÃ³digo de la culpabilidad del siniestro
      param in  pcreclama  : CÃ³digo reclamaciÃ³n VF 200011
      param in  pnasegur   : NÃºmero asegurado (producto 2 cabezas)
      param in  pcmeddec   : CÃ³digo Medio declaraciÃ³n
      param in  pctipdec   : CÃ³digo Tipo Declarante
      param in  ptnomdec   : Nombre Declarante
      param in  ptape1dec  : Primer Apellido Declarante
      param in  ptape2dec  : Segundo Apellido Declarante
      param in  ptteldec   : TelÃ©fono Declarante
      param in  ptsinies  : descripciÃ³n del siniestro
      param in  pcnivel  : Nivel Siniestro
      param in  psperson2  : Persona relacionada
      param in  pfechapp  : Fecha para planes pensiones
      param out mensajes  : mensajes de error
      param in pmodo      : PRE_SINIESTROS
      return              : 1 -> Todo correcto
                            0 -> Se ha producido un error
   ***********************************************************************/
   FUNCTION f_set_cabecera_siniestro(pnsinies     IN VARCHAR2,
                                     psseguro     IN NUMBER,
                                     pnriesgo     IN NUMBER,
                                     pnmovimi     IN NUMBER,
                                     pfsinies     IN DATE,
                                     phsinies     IN VARCHAR2,
                                     pfnotifi     IN DATE,
                                     pccausin     IN NUMBER,
                                     pcmotsin     IN NUMBER,
                                     pcevento     IN VARCHAR2,
                                     pcculpab     IN NUMBER,
                                     pcreclama    IN NUMBER,
                                     pnasegur     IN NUMBER,
                                     pcmeddec     IN NUMBER,
                                     pctipdec     IN NUMBER,
                                     ptnomdec     IN VARCHAR2,
                                     ptnom1dec    IN VARCHAR2, --BUG 19896 --ETM --20/12/2011-AÃ±adir campo 1Nombre de declarante
                                     ptnom2dec    IN VARCHAR2, --BUG 19896 --ETM --20/12/2011-AÃ±adir campo 2nombre de declarante
                                     ptape1dec    IN VARCHAR2,
                                     ptape2dec    IN VARCHAR2,
                                     ptteldec     IN VARCHAR2,
                                     ptmovildec   IN VARCHAR2, -- bug 19896--ETM--20/12/2011--AÃ±adir campo movil al declarante
                                     ptemaildec   IN VARCHAR2, -- bug 19896--ETM--20/12/2011--AÃ±adir campo email  al declarante
                                     ptsinies     IN VARCHAR2,
                                     pctipide     IN NUMBER,
                                     pnnumide     IN VARCHAR2,
                                     psperson_dec IN NUMBER,
                                     pnsincia     IN VARCHAR2, --BUG 14587 - PFA - 13/08/2010 - AÃ±adir campo siniestro compaÃ±ia
                                     pccompani    IN NUMBER,
                                     pnpresin     IN VARCHAR2, -- Bug 15006 - PFA - 16/08/2010 - nuevos campos en bÃºsqueda siniestros
                                     -- Bug 0015669 - JRH - 30/09/2010 - Alta prestaciones
                                     pcnivel   IN NUMBER,
                                     psperson2 IN NUMBER,
                                     pfechapp  IN DATE DEFAULT NULL,
                                     -- Fi Bug 0015669 - JRH - 30/09/2010
                                     pcpolcia    IN VARCHAR2, --BUG17539 - JTS - 10/02/2011
                                     piperit     IN NUMBER, --BUG17539 - JTS - 10/02/2011
                                     pcfraude    IN NUMBER, --BUG18748 - jbn
                                     pccarpeta   IN NUMBER, -- BUG 19832 - 24/10/2011 - JMP
                                     pasistencia IN NUMBER, -- Bug 21828/111506 - AMC
                                     pcagente    IN NUMBER, -- Bug 21817 - MDS - 2/05/2012
                                     mensajes    OUT t_iax_mensajes,
                                     pmodo       IN VARCHAR2 DEFAULT NULL, -- Bug 0023826 - 08/10/2012 - JMF
                                     pcsalvam    IN NUMBER, -- BUG 0024675 - 15/11/2012 - JMF
                                     picapital   IN NUMBER, -- BUG 0024869 - 14/12/2012 - NSS
                                     --BUG 39475/222692
                                     pfdeteccion DATE DEFAULT NULL,
                                     psolidaridad IN NUMBER default null, --CONF-249-30/11/2016-RCS
                                     ptdetpreten IN VARCHAR2 default null)
      RETURN NUMBER;

   /*************************************************************************
    funciÃ³n graba en una variable global de la capa IAX los valores del objeto
    ob_iax_siniestros.localizacion
        nsinies        VARCHAR2(14),   --NÃºmero Siniestro
       ntramit        NUMBER(3),   --NÃºmero TramitaciÃ³n Siniestro
       nlocali        NUMBER(3),   --NÃºmero LocalizaciÃ³n Siniestro
       sperson        NUMBER(6),   --Secuencia Persona
       tnombre        VARCHAR2(100),--Nombre persona
       csiglas        NUMBER(2),   --CÃ³digo Tipo VÃ­a
       tsiglas        VARCHAR2(100),   --Des Siglas
       tnomvia        VARCHAR2(40),   --Nombre VÃ­a
       nnumvia        NUMBER(5),   --NÃºmero VÃ­a
       tcomple        VARCHAR2(15),   --DescripciÃ³n Complementaria
       tlocali        VARCHAR2(100),   --DirecciÃ³n no normalizada
       cpais          NUMBER(3),   --CÃ³digo PaÃ­s
       tpais          VARCHAR2(200),   -- Desc. Pais
       cprovin        NUMBER(5),   --CÃ³digo ProvÃ­ncia
       tprovin        VARCHAR2(200),   --Desc Provin
       cpoblac        NUMBER(5),   --CÃ³digo PoblaciÃ³n
       tpoblac        VARCHAR2(200),   --Desc Poblacio
       cpostal        VARCHAR2(30),   --CÃ³digo Postal
       -- Bug 20154/98048 - 15/11/2011 - AMC
        param in cviavp,    -- CÃ³digo de via predio - via principal
        param in clitvp,    -- CÃ³digo de literal predio - via principal
        param in cbisvp,    -- CÃ³digo BIS predio - via principal
        param in corvp,     -- CÃ³digo orientaciÃ³n predio - via principal
        param in nviaadco,  -- NÃºmero de via adyacente predio - coordenada
        param in clitco,    -- CÃ³digo de literal predio - coordenada
        param in corco,     -- CÃ³digo orientaciÃ³n predio - coordenada
        param in nplacaco,  -- NÃºmero consecutivo placa predio - ccordenada
        param in cor2co,    -- CÃ³digo orientaciÃ³n predio 2 - coordenada
        param in cdet1ia,   -- CÃ³digo detalle 1 - informaciÃ³n adicional
        param in tnum1ia,   -- NÃºmero predio 1 - informacion adicional
        param in cdet2ia,   -- CÃ³digo detalle 2 - informaciÃ³n adicional
        param in tnum2ia,   -- NÃºmero predio 2 - informacion adicional
        param in cdet3ia,   -- CÃ³digo detalle 3 - informaciÃ³n adicional
        param in tnum3ia    -- NÃºmero predio 3 - informacion adicional
      -- Fi Bug 20154/98048- 15/11/2011 - AMC
        param in plocalidad -- Descripcion de la localidad -- Bug 24780/130907 - 05/12/2012 - AMC
   *************************************************************************/
   FUNCTION f_set_objeto_sintramilocali(pnsinies IN VARCHAR2,
                                        pntramit IN NUMBER,
                                        pnlocali IN NUMBER,
                                        psperson IN NUMBER,
                                        pcsiglas IN NUMBER,
                                        ptnomvia IN VARCHAR2,
                                        pnnumvia IN NUMBER,
                                        ptcomple IN VARCHAR2,
                                        ptlocali IN VARCHAR2,
                                        pcpais   IN NUMBER,
                                        pcprovin IN NUMBER,
                                        pcpoblac IN NUMBER,
                                        pcpostal IN VARCHAR2,
                                        -- Bug 20154/98048 - 15/11/2011 - AMC
                                        pcviavp   IN NUMBER,
                                        pclitvp   IN NUMBER,
                                        pcbisvp   IN NUMBER,
                                        pcorvp    IN NUMBER,
                                        pnviaadco IN NUMBER,
                                        pclitco   IN NUMBER,
                                        pcorco    IN NUMBER,
                                        pnplacaco IN NUMBER,
                                        pcor2co   IN NUMBER,
                                        pcdet1ia  IN NUMBER,
                                        ptnum1ia  IN VARCHAR2,
                                        pcdet2ia  IN NUMBER,
                                        ptnum2ia  IN VARCHAR2,
                                        pcdet3ia  IN NUMBER,
                                        ptnum3ia  IN VARCHAR2,
                                        -- Fi Bug 20154/98048- 15/11/2011 - AMC
                                        plocalidad IN VARCHAR2, -- Bug 24780/130907 - 05/12/2012 - AMC
                                        mensajes   OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    funciÃ³n recupera una localitzacio duna tramitaciÃ³ concreta
    ob_iax_siniestros.localizacion
        nsinies        VARCHAR2(14),   --NÃºmero Siniestro
       ntramit        NUMBER(3),   --NÃºmero TramitaciÃ³n Siniestro
       nlocali        NUMBER(3),   --NÃºmero LocalizaciÃ³n Siniestro

   *************************************************************************/
   FUNCTION f_get_objeto_sintramilocali(pnsinies IN VARCHAR2,
                                        pntramit IN NUMBER,
                                        pnlocali IN NUMBER,
                                        mensajes OUT t_iax_mensajes)
      RETURN ob_iax_sin_trami_localiza;

   /*************************************************************************
    funciÃ³n graba en una variable global de la capa IAX los valores del objeto
       nsinies        VARCHAR2(14),   --NÃºmero Siniestro
       ntramit        NUMBER(3),   --NÃºmero TramitaciÃ³n Siniestro
       ncitacion      NUMBER(3),   --NÃºmero Citacion Siniestro
       psperson       VARCHAR2(14),   --NÃºmero Persona
       pfcitacion     NUMBER(3),   --Fecha citacion
       phcitacion     VARCHAR2(5),   --Hora citacion
       pcpais       NUMBER(3),   --NÃºmero Pais
       pcprovin       NUMBER(3),   --NÃºmero Provincia
       pcpoblac       NUMBER(3),   --NÃºmero Ciudad
       ptlugar        VARCHAR2(200),   --Lugar de la citacion
   *************************************************************************/
   FUNCTION f_set_objeto_sintramicit(pnsinies IN VARCHAR2,
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
                                     mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
   /*************************************************************************
    funciÃ³n recupera una citacion duna tramitaciÃ³ concreta
       nsinies        VARCHAR2(14),   --NÃºmero Siniestro
       ntramit        NUMBER(3),   --NÃºmero TramitaciÃ³n Siniestro
       ncitacion        NUMBER(3),   --NÃºmero LocalizaciÃ³n Siniestro

   *************************************************************************/
   FUNCTION f_get_objeto_citacion(pnsinies IN VARCHAR2,
                                  pntramit IN NUMBER,
                                  pncitacion IN NUMBER,
                                  mensajes OUT t_iax_mensajes)
      RETURN ob_iax_sin_trami_citacion;
  /*************************************************************************
    funciÃ³n BORRA una citacion duna tramitaciÃ³ concreta
       nsinies        VARCHAR2(14),   --NÃºmero Siniestro
       ntramit        NUMBER(3),   --NÃºmero TramitaciÃ³n Siniestro
       ncitacion      NUMBER(3),   --NÃºmero citacion Siniestro

   *************************************************************************/
   FUNCTION f_del_citacion(pnsinies IN VARCHAR2,
                                        pntramit IN NUMBER,
                                        pncitacion IN NUMBER,
                                        mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

  /*************************************************************************
    funciÃ³n BORRA una citacion duna tramitaciÃ³ concreta
       nsinies        VARCHAR2(14),   --NÃºmero Siniestro
       ntramit        NUMBER(3),   --NÃºmero TramitaciÃ³n Siniestro
       ncitacion      NUMBER(3),   --NÃºmero citacion Siniestro

   *************************************************************************/
   FUNCTION f_get_asiste_citacion_def(pnsinies IN VARCHAR2,
                                      pntramit IN NUMBER,
                                      mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /*************************************************************************
    funciÃ³n BORRA una localitzacio duna tramitaciÃ³ concreta
    ob_iax_siniestros.localizacion
        nsinies        VARCHAR2(14),   --NÃºmero Siniestro
       ntramit        NUMBER(3),   --NÃºmero TramitaciÃ³n Siniestro
       nlocali        NUMBER(3),   --NÃºmero LocalizaciÃ³n Siniestro

   *************************************************************************/
   FUNCTION f_del_objeto_sintramilocali(pnsinies IN VARCHAR2,
                                        pntramit IN NUMBER,
                                        pnlocali IN NUMBER,
                                        mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    funciÃ³n graba en una variable global de la capa IAX los valores del objeto
    ob_iax_siniestros.localizacion
   nsinies        VARCHAR2(14),   --NÃºmero Siniestro
   ntramit        NUMBER(3),   --NÃºmero TramitaciÃ³n Siniestro
   ctramit        NUMBER(4),   --CÃ³digo tipus TramitaciÃ³n
   ttramit        VARCHAR2(100),   --Des tipus TramitaciÃ³n
   ctcausin       NUMBER(2),   --CÃ³digo Tipo DaÃ±o
   ttcausin       VARCHAR2(100),   --Des tipo daÃ±o
   cinform        NUMBER(1),   --Indicador TramitaciÃ³n Informativa
   tinform        VARCHAR2(100),   --Desc. INdicador tramitaciÃ³n Informativa
   cusualt        VARCHAR2(20),   --CÃ³digo Usuario Alta
   falta          DATE,   --Fecha Alta
   cusumod        VARCHAR2(20),   --CÃ³digo Usuario ModificaciÃ³n
   fmodifi        DATE,   --Fecha ModificaciÃ³n
   ctiptra        NUMBER,
   cborrab        NUMBER,
   ttiptra        VARCHAR2(200),
   detalle        ob_iax_sin_trami_detalle,-- detall de la tramitacio
   *************************************************************************/
   FUNCTION f_set_objeto_sintramitacion(pnsinies    IN VARCHAR2,
                                        pntramit    IN NUMBER,
                                        pctramit    IN NUMBER,
                                        pctcausin   IN NUMBER,
                                        pcinform    IN NUMBER,
                                        pctiptra    IN NUMBER,
                                        pcculpab    IN NUMBER,
                                        pccompani   IN NUMBER,
                                        pcpolcia    IN VARCHAR2,
                                        piperit     IN NUMBER,
                                        pnsincia    IN VARCHAR2,
                                        pntramte    IN NUMBER, --Bug 0018379 - JMC - 02/05/2011
                                        pcsubtiptra IN NUMBER, -- BUG 0023536 - 24/10/2012 - JMF
                                        pnradica IN VARCHAR2 DEFAULT NULL,
                                        pntramitout OUT NUMBER,
                                        mensajes    OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    funciÃ³n que retorna en una variable global de la capa IAX los valores del objeto
    ob_iax_siniestros.tramitaciones
   nsinies        VARCHAR2(14),   --NÃºmero Siniestro
   ntramit        NUMBER(3),   --NÃºmero TramitaciÃ³n Siniestro
   *************************************************************************/
   FUNCTION f_get_objeto_sintramitacion(pnsinies IN VARCHAR2,
                                        pntramit IN NUMBER,
                                        mensajes OUT t_iax_mensajes)
      RETURN ob_iax_sin_tramitacion;

   /*************************************************************************
    funciÃ³n que borra una tramitacio
    param in  pnsinies : nÃºmero de siniestro
    param in  pntramit : nÃºmero de tramitacion
    param in  pctiptra : numero de tipo de tramitacion
    param out mensajes : mensajes de error

    Bug 12668 - 03/03/2010 - AMC
   *************************************************************************/
   FUNCTION f_del_objeto_sintramitacion(pnsinies IN VARCHAR2,
                                        pntramit IN NUMBER,
                                        pctiptra IN NUMBER,
                                        mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    funciÃ³n graba en una variable global de la capa IAX los valores del objeto
    ob_iax_siniestros.tramitaciones(i).movimientos
   nsinies        VARCHAR2(14),   --NÃºmero Siniestro
   ntramit        NUMBER(3),   --NÃºmero TramitaciÃ³n Siniestro
   nmovtra        NUMBER(3),   --NÃºmero Movimiento TramitaciÃ³n
   cunitra        VARCHAR2(4),   --CÃ³digo Unidad TramitaciÃ³n
   tunitra        VARCHAR2(100),   -- desc. Unidad TramitaciÃ³n
   ctramitad      VARCHAR2(4),   --CÃ³digo Tramitador
   ttramitad      VARCHAR2(100),   --Desc. Tramitador
   cesttra        NUMBER(3),   --CÃ³digo Estado TramitaciÃ³n
   testtra        VARCHAR2(100),   --Desc. Estado TramitaciÃ³n
   csubtra        NUMBER(2),   --CÃ³digo Subestado TramitaciÃ³n
   tsubtra        VARCHAR2(100),   --Desc. Subestado TramitaciÃ³n
   festtra        DATE,   --Fecha Estado TramitaciÃ³n
   cusualt        VARCHAR2(500),   --CÃ³digo Usuario Alta
   falta          DATE,   --Fecha Alta
   *************************************************************************/
   FUNCTION f_set_objeto_sinmovtramit(pnsinies     IN VARCHAR2,
                                      pntramit     IN NUMBER,
                                      pnmovtra     IN NUMBER,
                                      pcunitra     IN VARCHAR2,
                                      pctramitad   IN VARCHAR2,
                                      pcesttra     IN NUMBER,
                                      pcsubtra     IN NUMBER,
                                      pfesttra     IN DATE,
                                      pccauest     IN NUMBER, -- 21196:ASN:26/03/2014
                                      mensajes     OUT t_iax_mensajes,
                                      pcvalida_ult IN NUMBER DEFAULT NULL) --bug 29989/165377;NSS;13-02-2014
    RETURN NUMBER;

   /*************************************************************************
    funciÃ³n que envia el ultimo movimiento de una tramitacion
   nsinies        VARCHAR2(14),   --NÃºmero Siniestro
   ntramit        NUMBER(3),   --NÃºmero TramitaciÃ³n Siniestro
   *************************************************************************/
   FUNCTION f_get_objeto_ult_sinmovtramit(pnsinies IN VARCHAR2,
                                          pntramit IN NUMBER,
                                          mensajes OUT t_iax_mensajes)
      RETURN ob_iax_sin_trami_movimiento;

   /*************************************************************************
       funciÃ³n graba en una variable global de la capa IAX los valores del objeto
       ob_iax_siniestros.tramitaciones(i).detalle
      nsinies        VARCHAR2(14),   --NÃºmero Siniestro
      ntramit        NUMBER(3),   --NÃºmero TramitaciÃ³n Siniestro
      ctramit        NUMBER(4),   --CÃ³digo tipus TramitaciÃ³n
      ttramit        VARCHAR2(200),   --Des tipus TramitaciÃ³n
      ctiptra        NUMBER(4),   --codi tipus tramitaciÃ³
      ttiptra        VARCHAR2(200),   --Des tipus TramitaciÃ³n
      ccompani       NUMBER(4),   --codi companyia
      tcompani       VARCHAR2(200),   --desc. companyia
      npoliza        NUMBER(8),   --num. polissa
      cpolcia        VARCHAR2(40),   -- num.polissa contraria
      iperit         NUMBER(10),   --import peritatge
      desctramit     VARCHAR2(200),   --desc. tramitacio
      persona        ob_iax_personas,   --persona tramitacio
   --Persona
      cestper        NUMBER,   --codi estat persona
      testper        VARCHAR2(200),   -- Desc. estat de la persona
   -- direccion
      tdescdireccion VARCHAR2(200),   --descripciÃ³ de la direcciÃ³
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
      cversion       VARCHAR2(11),   --CÃ³digo de VersiÃ³n de VehÃ­culo
      tversion       VARCHAR2(200
      Bug 12668 - 16/02/2010 - AMC
      cciudad       number(5),           -- cÃ³digo ciudad para chile
      fgisx         float,               -- coordenada gis x (gps)
      fgisy         float,               -- coordenada gis y (gps)
      fgisz         float,               -- coordenada gis z (gps)
      cvalida       number(2),           -- cÃ³digo validaciÃ³n direcciÃ³n. valor fijo 1006.
      Fi Bug 12668 - 16/02/2010 - AMC
      -- BUG 0023540 - 24/10/2012 - JMF: Afegir IRECLAM, IINDEMN
      *************************************************************************/
   FUNCTION f_set_objeto_sintramidetalle(psseguro        IN NUMBER,
                                         pnsinies        IN VARCHAR2,
                                         pntramit        IN NUMBER,
                                         pctramit        IN NUMBER,
                                         pctiptra        IN NUMBER,
                                         pdesctramit     IN VARCHAR2,
                                         psperson        IN NUMBER,
                                         pcestper        IN NUMBER,
                                         ptdescdireccion IN VARCHAR2,
                                         pcdomici        IN NUMBER,
                                         pcpostal        IN VARCHAR2,
                                         pcprovin        IN NUMBER,
                                         pcpoblac        IN NUMBER,
                                         pcpais          IN NUMBER,
                                         pctipdir        IN NUMBER,
                                         pcsiglas        IN NUMBER,
                                         ptnomvia        IN VARCHAR2,
                                         pnnumvia        IN NUMBER,
                                         ptcomple        IN VARCHAR2,
                                         pcciudad        IN NUMBER,
                                         pfgisx          IN FLOAT,
                                         pfgisy          IN FLOAT,
                                         pfgisz          IN FLOAT,
                                         pcvalida        IN NUMBER,
                                         pctipcon        IN NUMBER,
                                         pctipcar        IN NUMBER,
                                         pfcarnet        IN DATE,
                                         pcalcohol       IN NUMBER,
                                         pctipmat        IN NUMBER,
                                         pcmatric        IN VARCHAR2,
                                         pcmarca         IN NUMBER,
                                         pcmodelo        IN NUMBER,
                                         pcversion       IN VARCHAR2,
                                         pnanyo          IN NUMBER, --BUG:25762-NSS-24/01/2013
                                         pcchasis        IN VARCHAR2,
                                         pcodmotor       IN VARCHAR2,
                                         pnbastid        IN VARCHAR2,
                                         pccilindraje    IN NUMBER,
                                         mensajes        OUT t_iax_mensajes,
                                         pireclam        IN NUMBER DEFAULT NULL,
                                         piindemn        IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
FUNCTION f_set_objeto_sintramiamparo(
      pnsinies IN VARCHAR2,		     
       pntramit IN NUMBER,		     
       pcgarant IN NUMBER,		     
       pnpreten IN NUMBER,		     
       picaprie IN NUMBER,		     
       pcmonpreten IN VARCHAR2,		     
       mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
   /*************************************************************************
    funciÃ³n graba en una variable global de la capa IAX los valores del objeto
    ob_iax_siniestros.reserva
   nsinies        VARCHAR2(14),   --NÃºmero Siniestro
   ntramit        NUMBER(3),   --NÃºmero TramitaciÃ³n Siniestro
   ctipres        NUMBER(2),   --CÃ³digo Tipo Reserva
   ttipres        VARCHAR2(100),--Des tipo reserva
   nmovres        NUMBER(4),   --NÃºmero Movimiento Reserva
   cgarant        NUMBER(4),   --CÃ³digo GarantÃ­a
   tgarant        VARCHAR2(100),--Des garantia
   ccalres        NUMBER(1),   --CÃ³digo CÃ¡lculo Reserva (Manual/AutomÃ¡tico)
   tcalres        Varchar2(100),--des calculo reserva
   fmovres        DATE,   --Fecha Movimiento Reserva
   cmonres        VARCHAR2(3),   --CÃ³digo Moneda Reserva
   tmonres        VARCHAR2(100),--des moneda reserva
   ireserva       NUMBER,   --Importe Reserva
   ipago          NUMBER,   --Importe Pago
   iingreso       NUMBER,   --Importe Ingreso
   irecobro       NUMBER,   --Importe Recobro
   icaprie        NUMBER,   --Importe capital risc
   ipenali        NUMBER,   --Importe penalitzaciÃ³
   fresini        DATE,   --Fecha Inicio Reserva
   fresfin        DATE,   --Fecha Fin Reserva
   sidepag        NUMBER(8),   --Secuencia Identificador Pago
   sproces        NUMBER(10),   --Secuencia Proceso
   fcontab        DATE,   --Fecha Contabilidad
   cusualt        VARCHAR2(20),   --CÃ³digo Usuario Alta
   falta          DATE,   --Fecha Alta
   cusumod        VARCHAR2(20),   --CÃ³digo Usuario ModificaciÃ³n
   fmodifi        DATE,   --Fecha ModificaciÃ³n
   iprerec        NUMBER  -- Importe previsiÃ³n de recobro
   pmodo          VARCHAR2 -- Nos indica desde donde se modifica la reserva (RESER,PAGO,RECO)
   ptorigen       VARCHAR2 -- Pantalla que llama al alta de reservas

   -- Bug 11945 - 16/12/2009 - Se aÃ±ade el parametro IPREREC
   -- Bug 12124 - 12/03/2010 - Se aÃ±ade el parametro pmodo
   *************************************************************************/
   FUNCTION f_set_objeto_sintramireserva(pnsinies         IN VARCHAR2,
                                         pntramit         IN NUMBER,
                                         pctipres         IN NUMBER,
                                         pttipres         IN VARCHAR2,
                                         pnmovres         IN NUMBER,
                                         pcgarant         IN NUMBER,
                                         pccalres         IN NUMBER,
                                         pfmovres         IN DATE,
                                         pcmonres         IN VARCHAR2,
                                         pireserva        IN NUMBER,
                                         pipago           IN NUMBER,
                                         piingreso        IN NUMBER,
                                         pirecobro        IN NUMBER,
                                         picaprie         IN NUMBER,
                                         pipenali         IN NUMBER,
                                         pfresini         IN DATE,
                                         pfresfin         IN DATE,
                                         pfultpag         IN DATE,
                                         psidepag         IN NUMBER,
                                         psproces         IN NUMBER,
                                         pfcontab         IN DATE,
                                         piprerec         IN NUMBER,
                                         pctipgas         IN NUMBER,
                                         pmodo            IN VARCHAR2,
                                         ptorigen         IN VARCHAR2, -- BUG 20014 - 24/01/2012 - JMP - LCOL_S001-SIN - Reservas y pagos en tramitaciones cerradas
                                         pifranq          IN NUMBER, -- BUG 27059 - 03/06/2013 - NSS - LCOL_S010-SIN - Franquicias en siniestros II
                                         pndias           IN NUMBER, -- BUG 27487/159742- 26/11/2013 - NSS -
                                         pcmovres         IN NUMBER, --0031294/0174788: NSS:26/05/2014
                                         pitotimp         IN NUMBER DEFAULT NULL, -- 24637/0147756:NSS:28/11/2013
                                         mensajes         OUT t_iax_mensajes,
                                         ppiva            IN NUMBER DEFAULT NULL, -- 24637/0147756:NSS:05/03/2014
                                         ppretenc         IN NUMBER DEFAULT NULL, -- 24637/0147756:NSS:20/03/2014
                                         ppreteiva        IN NUMBER DEFAULT NULL, -- 24637/0147756:NSS:20/03/2014
                                         ppreteica        IN NUMBER DEFAULT NULL, -- 24637/0147756:NSS:20/03/2014
                                         piva_ctipind     IN NUMBER DEFAULT NULL, -- 24637/0147756:NSS:20/03/2014
                                         pretenc_ctipind  IN NUMBER DEFAULT NULL, -- 24637/0147756:NSS:20/03/2014
                                         preteiva_ctipind IN NUMBER DEFAULT NULL, -- 24637/0147756:NSS:20/03/2014
                                         preteica_ctipind IN NUMBER DEFAULT NULL, -- 24637/0147756:NSS:20/03/2014
                                         pitotret         IN NUMBER DEFAULT NULL, -- 24637/0147756:NSS:20/05/2014
                                         pcsolidaridad    IN NUMBER DEFAULT NULL -- CONF-431 IGIL
                                         ) RETURN NUMBER;

   /*************************************************************************
    funciÃ³n graba en una variable global de la capa IAX los valores del objeto
    ob_iax_siniestro_referencias
   pnsinies        VARCHAR2(14),   --NÃºmero Siniestro
   psrefext        NUMBER(3),   --NÃºmero referencia
   pctipref        NUMBER(2),   --CÃ³digo Tipo referencia
   ptrefext        VARCHAR2(100),--Des tipo referencia
   pfrefini        DATE,   --Fecha Inicio
   pfreffin        DATE,   --Fecha Fin

   *************************************************************************/
   FUNCTION f_set_objeto_sinreferencias(pnsinies IN VARCHAR2,
                                        psrefext IN NUMBER,
                                        pctipref IN NUMBER,
                                        ptrefext IN VARCHAR2,
                                        pfrefini IN DATE,
                                        pfreffin IN DATE,
                                        mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
     funciÃ³n retorna totes les reserves d'una tramitaciÃ³
     ob_iax_siniestros.danyos
   nsinies        VARCHAR2(14),   --NÃºmero Siniestro
   ntramit        NUMBER(3),   --NÃºmero TramitaciÃ³n Siniestro
   ndano          NUMBER(3),   --NÃºmero DaÃ±o Siniestro
   tdano          VARCHAR2(5000),   --DescripciÃ³n DaÃ±o
    *************************************************************************/
   FUNCTION f_get_objreservas_calc(psseguro IN NUMBER,
                                   pnsinies IN VARCHAR2,
                                   pntramit IN NUMBER,
                                   mensajes OUT t_iax_mensajes)
      RETURN t_iax_sin_trami_reserva;

   /*************************************************************************
     funciÃ³n graba en una variable global de la capa IAX los valores del objeto
     ob_iax_siniestros.danyos
   nsinies        VARCHAR2(14),   --NÃºmero Siniestro
   ntramit        NUMBER(3),   --NÃºmero TramitaciÃ³n Siniestro
   ndano          NUMBER(3),   --NÃºmero DaÃ±o Siniestro
   tdano          VARCHAR2(5000),   --DescripciÃ³n DaÃ±o
    *************************************************************************/
   FUNCTION f_set_objeto_sintramidanyo(pnsinies IN VARCHAR2,
                                       pntramit IN NUMBER,
                                       pndano   IN NUMBER,
                                       pctipinf IN NUMBER,
                                       ptdano   IN VARCHAR2,
                                       pndanout OUT NUMBER,
                                       mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
     funciÃ³n graba en una variable global de la capa IAX los valores del objeto
     ob_iax_siniestros.danyos
   nsinies        VARCHAR2(14),   --NÃºmero Siniestro
   ntramit        NUMBER(3),   --NÃºmero TramitaciÃ³n Siniestro
   ndano          NUMBER(3),   --NÃºmero DaÃ±o Siniestro
   tdano          VARCHAR2(5000),   --DescripciÃ³n DaÃ±o
    *************************************************************************/
   FUNCTION f_set_objeto_sintramidetdanyo(pnsinies IN VARCHAR2,
                                          pntramit IN NUMBER,
                                          pndano   IN NUMBER,
                                          pctipinf IN NUMBER,
                                          ptdano   IN VARCHAR2,
                                          dano0    IN NUMBER,
                                          dano1    IN NUMBER,
                                          dano2    IN NUMBER,
                                          dano3    IN NUMBER,
                                          dano4    IN NUMBER,
                                          dano5    IN NUMBER,
                                          dano6    IN NUMBER,
                                          dano7    IN NUMBER,
                                          dano8    IN NUMBER,
                                          dano9    IN NUMBER,
                                          dano10   IN NUMBER,
                                          mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      funciÃ³n recupera un dany
      ob_iax_siniestros.danyos
    nsinies        VARCHAR2(14),   --NÃºmero Siniestro
    ntramit        NUMBER(3),   --NÃºmero TramitaciÃ³n Siniestro
    ndano          NUMBER(3),   --NÃºmero DaÃ±o Siniestro
   *************************************************************************/
   FUNCTION f_get_objeto_sintramidanyo(pnsinies IN VARCHAR2,
                                       pntramit IN NUMBER,
                                       pndano   IN NUMBER,
                                       mensajes OUT t_iax_mensajes)
      RETURN ob_iax_sin_trami_dano;

   /*************************************************************************
        funciÃ³n borra todo el objeto danyo de tramitaciones
   *************************************************************************/
   FUNCTION f_del_danyo(pnsinies IN VARCHAR2,
                        pntramit IN NUMBER,
                        pndano   IN NUMBER,
                        mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
        funciÃ³n graba en una variable global de la capa IAX los valores del objeto
        ob_iax_siniestros.destinatario
   nsinies        VARCHAR2(14),   --NÃºmero Siniestro
      ntramit        NUMBER(3),   --NÃºmero TramitaciÃ³n Siniestro
   --   sperson        NUMBER(6),   --NUm. identificativo destinatario
   --   nnumide        VARCHAR2(14),   --NÃºmero documento
   --   tdestinatario  VARCHAR2(200),   --Nombre Destinatario
      ctipdes        NUMBER(2),   --CÃ³digo Tipo Destinatario
      ttipdes        VARCHAR2(100),   --des tipo destinatario
      cpagdes        NUMBER(1),   --Indicador aceptaciÃ³n pagos
      cactpro        NUMBER(4),   --CÃ³digo Actividad Profesional
      tactpro        VARCHAR2(100),   --Des Actividad Profesional
      pasigna        NUMBER(5,2), --asignaciÃ³n
      cpaisre        NUMBER(3),  --cÃ³digo paÃ­s residencia
      tpaisre        VARCHAR2(100), --descripciÃ³n paÃ­s
      cusualt        VARCHAR2(20),   --CÃ³digo Usuario Alta
      falta          DATE,   --Fecha Alta
      cusumod        VARCHAR2(20),   --CÃ³digo Usuario ModificaciÃ³n
      fmodifi        DATE,   --Fecha ModificaciÃ³n
      persona        ob_iax_personas,--persona destinataria
      pctipcap       Tipo prestaciÃ³n
      pcrelase        RelaciÃ³n con asegurado
       *************************************************************************/
   FUNCTION f_set_obj_sintramidestinatari(psseguro IN NUMBER,
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
                                          psprofes IN NUMBER, -- Bug 0024637/0147756: (POSAN500-AN-Sin) Analisis Desarrollo: Siniestros - NSS - 30/09/2010
                                          pcprovin IN NUMBER, -- SHA -- Bug 38224/216445 --11/11/2015
                                          mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_obj_sintramidestinatari(psseguro IN NUMBER,
                                          pnsinies IN VARCHAR2,
                                          pntramit IN NUMBER,
                                          pctipdes IN NUMBER,
                                          psperson IN NUMBER,
                                          mensajes OUT t_iax_mensajes)
      RETURN ob_iax_sin_trami_destinatario;

   FUNCTION f_get_obj_sintramidestinataris(psseguro IN NUMBER,
                                           pnsinies IN VARCHAR2,
                                           pntramit IN NUMBER,
                                           mensajes OUT t_iax_mensajes)
      RETURN t_iax_sin_trami_destinatario;

   /*************************************************************************
           funciÃ³n graba en una variable global de la capa IAX los valores del objeto
           ob_iax_siniestros.pagos
   sidepag        NUMBER(8),   --Secuencia Identificador Pago
      nsinies        VARCHAR2(14),   --NÃºmero Siniestro
      ntramit        NUMBER(3),   --NÃºmero TramitaciÃ³n Siniestro
      ctipdes        NUMBER(2),   --CÃ³digo Tipo Destinatario
      ttipdes        VARCHAR2(100),   --Desc. Tipo Destinatario
      ctippag        NUMBER(1),   --CÃ³digo Tipo Pago
      ttippag        VARCHAR2(100),   --Desc. Tipo Pago
      cconpag        NUMBER(2),   --CÃ³digo Concepto Pago
      tconpag        VARCHAR2(100),   --Desc. COncepto Pago
      ccauind        NUMBER(3),   --CÃ³digo Causa IndemnizaciÃ³n
      tcauind        VARCHAR2(100),   --Desc. Causa IndemnizaciÃ³n
      cforpag        NUMBER(2),   --CÃ³digo Forma Pago
      tforpag        VARCHAR2(100),   --DEsc. Forma PAgo
      fordpag        DATE,   --Fecha Orden Pago
      ctipban        NUMBER(1),   --CÃ³digo Tipo Cuenta Bancaria
      ttipban        VARCHAR2(100),   --Desc. Tipo Cuenta Bancaria
      cbancar        VARCHAR2(34),   --CÃ³digo Cuenta Bancaria
      cmonres        VARCHAR2(3),   --CÃ³digo Moneda Reserva
      tmonres        VARCHAR2(100),   --Desc. Moneda Reserva
      isinret        NUMBER,   --Importe Sin RetenciÃ³n
      iconret        NUMBER,   --Importe Con RetenciÃ³n
      iretenc        NUMBER,   --Importe RetenciÃ³n
      pretenc        NUMBER(6, 3),   --Porcentaje RetenciÃ³n
      iiva           NUMBER,   --Importe IVA
      isuplid        NUMBER,   --Importe Suplido
      ifranq         NUMBER,   --Importe Franquicia Pagada
      iresred        NUMBER,   --Importe Rendimiento Reducido (Vida)
      iresrcm        NUMBER,   --Importe Rendimiento (Vida)
      cmonpag        VARCHAR2(3),   --CÃ³digo Moneda Pago
      tmonpag        VARCHAR2(100),   --Desc Moneda Pago
      isinretpag     NUMBER,   --Importe Sin RetenciÃ³n Moneda Pago
      iconretpag     NUMBER,   --Importe Con RetenciÃ³n Moneda Pago
      iretencpag     NUMBER,   --Importe RetenciÃ³n Moneda Pago
      iivapag        NUMBER,   --Importe IVA Moneda Pago
      isuplidpag     NUMBER,   --Importe Suplido Moneda Pago
      ifranqpag      NUMBER,   --Importe Franquicia Moneda Pago
      fcambio        DATE,   --Fecha de cambio
      nfacref        VARCHAR2(100),   --NÃºmero Factura/Referencia
      ffacref        DATE,   --Fecha Factura/Referencia
      cusualt        VARCHAR2(20),   --CÃ³digo Usuario Alta
      falta          DATE,   --Fecha Alta
      cusumod        VARCHAR2(20),   --CÃ³digo Usuario ModificaciÃ³n
      fmodifi        DATE,   --Fecha ModificaciÃ³n
      destinatari    ob_iax_personas,   --destinatari
      movpagos       t_iax_sin_trami_movpago,   --Coleccion movimientos de pagos
      pagogar        t_iax_sin_trami_pago_gar,   --coleccion pago garantias
      pcagente        NUMBER  CÃ³digo del agente/mediador
      pnpersrel       NUMBER  CÃ³digo persona relacionada/perjudicada

   -- Bug 11847 - 23/11/2009 - AMC
      BUG 19981 - 07/11/2011 - MDS - AÃ±adir campos ireteiva, ireteica, ireteivapag, ireteicapag, iica, iicapag  en la cabecera y llamadas
      Bug 22256/122456 - 28/09/2012 - AMC  - AÃ±adir campos cagente,npersrel,pcdomici y pctributacion
   *************************************************************************/
   FUNCTION f_set_obj_sintrami_pago_recob(psseguro      IN NUMBER,
                                          psidepag      IN NUMBER,
                                          pnsinies      IN VARCHAR2,
                                          pntramit      IN NUMBER,
                                          pctipdes      IN NUMBER,
                                          pctippag      IN NUMBER,
                                          pcconpag      IN NUMBER,
                                          pccauind      IN NUMBER,
                                          pcforpag      IN NUMBER,
                                          pfordpag      IN DATE,
                                          pctipban      IN NUMBER,
                                          pcbancar      IN VARCHAR2,
                                          pcmonres      IN VARCHAR2,
                                          pisinret      IN NUMBER,
                                          piconret      IN NUMBER,
                                          ppretenc      IN NUMBER,
                                          piretenc      IN NUMBER, -- ASN 24546
                                          piiva         IN NUMBER,
                                          pisuplid      IN NUMBER,
                                          pifranq       IN NUMBER,
                                          piresred      IN NUMBER,
                                          piresrcm      IN NUMBER,
                                          pcmonpag      IN VARCHAR2,
                                          pisinretpag   IN NUMBER,
                                          piconretpag   IN NUMBER,
                                          piretencpag   IN NUMBER,
                                          piivapag      IN NUMBER,
                                          pisuplidpag   IN NUMBER,
                                          pifranqpag    IN NUMBER,
                                          pfcambio      IN DATE,
                                          pnfacref      IN VARCHAR2,
                                          pffacref      IN DATE,
                                          psperson      IN NUMBER,
                                          psidepagtemp  IN NUMBER,
                                          pcultpag      IN NUMBER,
                                          pncheque      IN VARCHAR2,
                                          psidepagout   OUT NUMBER,
                                          mensajes      OUT t_iax_mensajes,
                                          pireteiva     IN NUMBER DEFAULT NULL,
                                          pireteica     IN NUMBER DEFAULT NULL,
                                          pireteivapag  IN NUMBER DEFAULT NULL,
                                          pireteicapag  IN NUMBER DEFAULT NULL,
                                          piica         IN NUMBER DEFAULT NULL,
                                          piicapag      IN NUMBER DEFAULT NULL,
                                          pcagente      IN NUMBER DEFAULT NULL,
                                          pnpersrel     IN NUMBER DEFAULT NULL,
                                          pcdomici      IN NUMBER DEFAULT NULL,
                                          pctributacion IN NUMBER DEFAULT NULL,
                                          pcbanco       IN NUMBER DEFAULT NULL, --24708:NSS:10/10/2013
                                          pcofici       IN NUMBER DEFAULT NULL, --24708:NSS:10/10/2013
                                          pcciudad      IN NUMBER DEFAULT NULL, --29224:NSS:24/02/2014
                                          pspersonpres  IN NUMBER DEFAULT NULL,
                                          ptobserva     IN VARCHAR2 DEFAULT NULL,
                                          piotrosgas    IN NUMBER DEFAULT NULL,
                                          pibaseipoc    IN NUMBER DEFAULT NULL,
                                          piipoconsumo  IN NUMBER DEFAULT NULL,
                                          piotrosgaspag   IN NUMBER DEFAULT NULL,
                                          pibaseipocpag   IN NUMBER DEFAULT NULL,
                                          piipoconsumopag IN NUMBER DEFAULT NULL
                                          ) RETURN NUMBER;

   FUNCTION f_get_obj_sintramipagorecob(psseguro IN NUMBER,
                                        pnsinies IN VARCHAR2,
                                        pntramit IN NUMBER,
                                        pctippag IN NUMBER,
                                        psidepag IN NUMBER,
                                        mensajes OUT t_iax_mensajes)
      RETURN ob_iax_sin_trami_pago;

   FUNCTION f_get_obj_ultim_movpagorecob(psseguro IN NUMBER,
                                         pnsinies IN VARCHAR2,
                                         pntramit IN NUMBER,
                                         pctippag IN NUMBER,
                                         psidepag IN NUMBER,
                                         mensajes OUT t_iax_mensajes)
      RETURN ob_iax_sin_trami_movpago;

   /*************************************************************************
   funciÃ³n RETORNA LOBJECTE DE PAGOS_GAR
         psseguro IN NUMBER,
         pnsinies IN VARCHAR2,
         pntramit IN NUMBER,
         pctippag IN NUMBER,
             *************************************************************************/
   FUNCTION f_get_obj_sintram_pagrecob_gar(psseguro IN NUMBER,
                                           pnsinies IN VARCHAR2,
                                           pntramit IN NUMBER,
                                           pctippag IN NUMBER,
                                           psidepag IN NUMBER,
                                           pctipres IN NUMBER,
                                           pnmovres IN NUMBER,
                                           pnorden  IN NUMBER,
                                           mensajes OUT t_iax_mensajes)
      RETURN ob_iax_sin_trami_pago_gar;

   /*************************************************************************
   funciÃ³n graba en una variable global de la capa IAX los valores del objeto
   ob_iax_siniestros.tramitaciones.movpagos
      sidepag        NUMBER(8),   --Secuencia Identificador Pago
      nmovpag        NUMBER(4),   --NÃºmero Movimiento Pago
      cestpag        NUMBER(1),   --CÃ³digo Estado Pago
      testpag        VARCHAR2(100),--Desc. Estado Pago
      fefepag        DATE,   --Fecha Efecto Pago
      cestval        NUMBER(1),   --CÃ³digo Estado ValidaciÃ³n Pago
      testval        VARCHAR2(100),--Desc. Estado ValidaciÃ³n Pago
      fcontab        DATE,   --Fecha Contabilidad
           Bug 13312 - 08/03/2010 - AMC - Se aÃ±ade el parametro cestpagant
             *************************************************************************/
   FUNCTION f_set_obj_sintram_movpagrecob(pntramit    IN NUMBER,
                                          psidepag    IN NUMBER,
                                          pnmovpag    IN NUMBER,
                                          pcestpag    IN NUMBER,
                                          pfefepag    IN DATE,
                                          pcestval    IN NUMBER,
                                          pfcontab    IN DATE,
                                          pctippag    IN NUMBER,
                                          pcestpagant IN NUMBER,
                                          pcsubpag    IN NUMBER, --Bug:19601 - 13/10/2011 - JMC
                                          pcsubpagant IN NUMBER,
                                          mensajes    OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   funciÃ³n borra en una variable global de la capa IAX los valores del objeto
   ob_iax_siniestros.tramitaciones.pagogar

           -- Bug 13166 - 15/02/2009 - AMC
       *************************************************************************/
   FUNCTION f_del_obj_sintram_pagrecob_gar(pnsinies IN VARCHAR2,
                                           pntramit IN NUMBER,
                                           pctippag IN NUMBER,
                                           psidepag IN NUMBER,
                                           pctipres IN NUMBER,
                                           pcgarant IN NUMBER,
                                           pnmovres IN NUMBER,
                                           pnorden  IN NUMBER,
                                           mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   funciÃ³n graba en una variable global de la capa IAX los valores del objeto
   ob_iax_siniestros.tramitaciones.pagogar
      sidepag        NUMBER(8),   --Secuencia Identificador Pago
      ctipres        NUMBER(2),   --CÃ³digo Tipo Reserva
      ttipres        VARCHAR2(100),   --des tipo reserva
      nmovres        NUMBER(4),   --NÃºmero Movimiento Reserva
      cgarant        NUMBER(4),   --CÃ³digo GarantÃ­a
      tgarant        VARCHAR2(100),   --Des garantia
      fperini        DATE,   --Fecha Periodo Inicio
      fperfin        DATE,   --Fecha Periodo Fin
      cmonres        VARCHAR2(3),   --CÃ³digo Moneda Reserva
      tmonres        VARCHAR2(100),   --DES moneda reserva
      isinret        NUMBER,   --Importe Sin RetenciÃ³n
      iiva           NUMBER,   --Importe IVA
      isuplid        NUMBER,   --Importe Suplido
      iretenc        NUMBER,   --Importe RetenciÃ³n
      ifranq         NUMBER,   --Importe Franquicia Pagada
      cmonpag        VARCHAR2(3),   --CÃ³digo Moneda Pago
      tmonpag        VARCHAR2(100),   --Des Moneda Pago
      isinretpag     NUMBER,   -- importe bruto
      iivapag        NUMBER,   --Importe IVA Moneda Pago
      isuplidpag     NUMBER,   --Importe Suplido Moneda Pago
      iretencpag     NUMBER,   --Importe RetenciÃ³n Moneda Pago
      ifranqpag      NUMBER,   --Importe Franquicia Moneda Pago
      fcambio        DATE,   --Fecha de cambio

      BUG 19981 - 07/11/2011 - MDS - AÃ±adir campos preteiva, preteica, ireteiva, ireteica, ireteivapag, ireteicapag, pica, iica, iicapag en la cabecera y llamadas
             *************************************************************************/
   FUNCTION f_set_obj_sintram_pagrecob_gar(psseguro         IN NUMBER,
                                           pntramit         IN NUMBER,
                                           pctippag         IN NUMBER,
                                           psidepag         IN NUMBER,
                                           pctipres         IN NUMBER,
                                           pctipgas         IN NUMBER, -- 26108
                                           pnmovres         IN NUMBER,
                                           pcgarant         IN NUMBER,
                                           pfperini         IN DATE,
                                           pfperfin         IN DATE,
                                           pcmonres         IN VARCHAR2,
                                           pisinret         IN NUMBER,
                                           piiva            IN NUMBER,
                                           pisuplid         IN NUMBER,
                                           piretenc         IN NUMBER,
                                           pifranq          IN NUMBER,
                                           pcmonpag         IN VARCHAR2,
                                           pisinretpag      IN NUMBER,
                                           piivapag         IN NUMBER,
                                           pisuplidpag      IN NUMBER,
                                           piretencpag      IN NUMBER,
                                           pifranqpag       IN NUMBER,
                                           pfcambio         IN DATE,
                                           piresred         IN NUMBER,
                                           piresrcm         IN NUMBER,
                                           ppiva            IN NUMBER,
                                           ppretenc         IN NUMBER,
                                           pcconpag         IN NUMBER,
                                           pnorden          IN NUMBER,
                                           mensajes         OUT t_iax_mensajes,
                                           ppreteiva        IN NUMBER DEFAULT NULL,
                                           ppreteica        IN NUMBER DEFAULT NULL,
                                           pireteiva        IN NUMBER DEFAULT NULL,
                                           pireteica        IN NUMBER DEFAULT NULL,
                                           pireteivapag     IN NUMBER DEFAULT NULL,
                                           pireteicapag     IN NUMBER DEFAULT NULL,
                                           ppica            IN NUMBER DEFAULT NULL,
                                           piica            IN NUMBER DEFAULT NULL,
                                           piicapag         IN NUMBER DEFAULT NULL,
                                           pciva_tipind     IN NUMBER DEFAULT NULL, --bug 24637/147756:NSS:03/03/2014
                                           pcretenc_tipind  IN NUMBER DEFAULT NULL, --bug 24637/147756:NSS:03/03/2014
                                           pcreteiva_tipind IN NUMBER DEFAULT NULL, --bug 24637/147756:NSS:03/03/2014
                                           pcreteica_tipind IN NUMBER DEFAULT NULL, --bug 24637/147756:NSS:14/03/2014
                                           pitotimp         IN NUMBER DEFAULT NULL, --bug 24637/147756:NSS:03/03/2014
                                           pitotret         IN NUMBER DEFAULT NULL, --bug 24637/147756:NSS:21/03/2014
                                           piotrosgas    IN NUMBER DEFAULT NULL,
                                           pibaseipoc    IN NUMBER DEFAULT NULL,
                                           ppipoconsumo  IN NUMBER DEFAULT NULL,
                                           pctipind      IN NUMBER DEFAULT NULL,
                                           piipoconsumo  IN NUMBER DEFAULT NULL,
                                           piotrosgaspag   IN NUMBER DEFAULT NULL,
                                           pibaseipocpag   IN NUMBER DEFAULT NULL,
                                           piipoconsumopag IN NUMBER DEFAULT NULL
                                           ) RETURN NUMBER;

   /*************************************************************************
    funciÃ³n graba en una variable global de la capa IAX los valores del objeto
    ob_iax_siniestros.tramitacion.agenda
   nsinies        VARCHAR2(14),   --NÃºmero Siniestro
   ntramit        NUMBER(3),   --NÃºmero TramitaciÃ³n Siniestro
   nlinage        NUMBER(6),   --NÃºmero LÃ­nea
   ctipreg        NUMBER(3),   --CÃ³digo Tipo Registro
   ttipreg        VARCHAR2(100),   --Des Tipo Registro
   cmanual        NUMBER(3),   --CÃ³digo Registro Manual
   tmanual        VARCHAR2(100),   --Desc Registro Manual
   cestage        NUMBER(3),   --CÃ³digo Estado Agenda
   testage        VARCHAR2(100),   --Desc Registro Manual
   ffinage        DATE,   --Fecha FinalizaciÃ³n
   ttitage        VARCHAR2(100),   --TÃ­tulo AnotaciÃ³n
   tlinage        VARCHAR2(2000),   --DescripciÃ³n AnotaciÃ³n

   Bug 12604 - 08/01/2010 - AMC - Se quita el parametro pfrec
   *************************************************************************/
   FUNCTION f_set_objeto_sintramiagenda(pnsinies IN VARCHAR2,
                                        pntramit IN NUMBER,
                                        pnlinage IN NUMBER,
                                        pctipreg IN NUMBER,
                                        pcmanual IN NUMBER,
                                        pcestage IN NUMBER,
                                        pffinage IN DATE,
                                        pttitage IN VARCHAR2,
                                        ptlinage IN VARCHAR2,
                                        mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_ins_personarel
         Inserta a la taula SIN_TRAMITA_PERSONAREL dels parÃ metres informats.
         param in pnsinies     : nÃºmero sinistre
         param in pntramit     : nÃºmero tramitaciÃ³ sinistre
         param in pnpersrel    : nÃºmero linia
         param in pctipide     : codi tipus registre
         param in pnnumide     : codi registre manual
         param in ptnombre     : codi estat agenda
         param in ptapelli1    : data finalitzaciÃ³
         param in ptapelli2    : tÃ­tol anotaciÃ³
         param in pttelefon    : descripciÃ³ anotaciÃ³
         param in psperson     : descripciÃ³ anotaciÃ³
         param in ptdesc       : descripciÃ³ anotaciÃ³
         param in ptnombre2    : segundo nombre
         param in ptmovil      : telf. movil
         param in ptemail      : email
         return                : 0 -> Tot correcte
                                1 -> S'ha produit un error

         Bug 22325/115249 - 05/06/2012 - AMC
         -- Bug 0024690 - 13/11/2012 - JMF : aÃ±adir ctiprel
   *************************************************************************/
   FUNCTION f_set_sintramipersonarel(pnsinies  IN VARCHAR2,
                                     pntramit  IN NUMBER,
                                     pnpersrel IN NUMBER,
                                     pctipide  IN NUMBER,
                                     pnnumide  IN VARCHAR2,
                                     ptnombre  IN VARCHAR2,
                                     ptapelli1 IN VARCHAR2,
                                     ptapelli2 IN VARCHAR2,
                                     pttelefon IN VARCHAR2,
                                     psperson  IN NUMBER,
                                     ptdesc    IN VARCHAR2,
                                     ptnombre2 IN VARCHAR2,
                                     ptmovil   IN VARCHAR2,
                                     ptemail   IN VARCHAR2,
                                     pctiprel  IN NUMBER,
                                     mensajes  OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   FunciÃ³n graba en una variable global de la capa IAX los valores del objeto
    ob_iax_siniestros.tramitacion.personarel
    nsinies        VARCHAR2(14),   --NÃºmero Siniestro
    ntramit        NUMBER(3),      --NÃºmero TramitaciÃ³n Siniestro
    pnpersrel      NUMBER(6),      --NÃºmero linea persona relacionada
   *************************************************************************/
   FUNCTION f_del_sintramipersonarel(pnsinies  IN VARCHAR2,
                                     pntramit  IN NUMBER,
                                     pnpersrel IN NUMBER,
                                     mensajes  OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    funciÃ³n devuelve una linea de la agenda
    ob_iax_siniestros.tramitacion.agenda
    nsinies        VARCHAR2(14),--NÃºmero Siniestro
    ntramit        NUMBER(3),   --NÃºmero TramitaciÃ³n Siniestro
    pnpersrel      NUMBER(6),   --NÃºmero LÃ­nea persona rel
   *************************************************************************/
   FUNCTION f_get_objeto_personarel(pnsinies  IN VARCHAR2,
                                    pntramit  IN NUMBER,
                                    pnpersrel IN NUMBER,
                                    mensajes  OUT t_iax_mensajes)
      RETURN ob_iax_sin_trami_personarel;

   /*************************************************************************
    funciÃ³n devuelve una linea de la agenda
    ob_iax_siniestros.tramitacion.agenda
   nsinies        VARCHAR2(14),   --NÃºmero Siniestro
   ntramit        NUMBER(3),   --NÃºmero TramitaciÃ³n Siniestro
   nlinage        NUMBER(6),   --NÃºmero LÃ­nea
   *************************************************************************/
   FUNCTION f_get_objeto_sintramiagenda(pnsinies IN VARCHAR2,
                                        pntramit IN NUMBER,
                                        pnlinage IN NUMBER,
                                        mensajes OUT t_iax_mensajes)
      RETURN ob_iax_sin_trami_agenda;

   /*************************************************************************
    funciÃ³n borra una linea de la agenda ob_iax_siniestros.tramitacion.agenda
     param in pnsinies   : NÃºmero Siniestro
     param in pntramit   : NÃºmero TramitaciÃ³n Siniestro
     param in pnlinage   : NÃºmero LÃ­nea
     param in psproduc   : CÃ³digo de producto
     param in pcactivi   : CÃ³digo de la actividad
     param out mensajes  : Mensajes de error

    Bug 15153 - 23/06/2010 - AMC - Se aÃ±aden los parametros sproduc y cactivi
   *************************************************************************/
   FUNCTION f_del_objeto_sintramiagenda(pnsinies IN VARCHAR2,
                                        pntramit IN NUMBER,
                                        pnlinage IN NUMBER,
                                        psproduc IN NUMBER,
                                        pcactivi IN NUMBER,
                                        mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Devuelve los siniestros que cumplan con el criterio de selecciÃ³n
      param in pnpoliza     : nÃºmero de pÃ³liza
      param in pncert       : nÃºmero de cerificado por defecto 0
      param in pnsinies     : nÃºmero del siniestro
      param in cestsin      : cÃ³digo situaciÃ³n del siniestro
      param in pnnumide     : nÃºmero identidad persona
      param in psnip        : nÃºmero identificador externo
      param in pbuscar      : nombre+apellidos a buscar de la persona
      param in ptipopersona : tipo de persona
                               1 tomador
                               2 asegurado
      param out mensajes    : mensajes de error
      return                : ref cursor
   *************************************************************************/
   FUNCTION f_consultasini(
                           -- Bug 10093 - 02/02/2010 - LCF - Anyadir param busqueda siniestros
                           pcramo   IN NUMBER,
                           psproduc IN NUMBER,
                           -- Fi Bug 10093 - LCF - 02/02/2010
                           pnpoliza  IN NUMBER,
                           pncertif  IN NUMBER DEFAULT -1,
                           pnsinies  IN VARCHAR2,
                           pcestsin  IN NUMBER,
                           pnnumide  IN VARCHAR2,
                           psnip     IN VARCHAR2,
                           pbuscar   IN VARCHAR2,
                           ptipopers IN NUMBER,
                           pnsubest  IN NUMBER,
                           pnsincia  IN VARCHAR2, --BUG 14587 - PFA - 13/08/2010 - AÃ±adir campo siniestro compaÃ±ia
                           pfalta    IN DATE, --IAXIS-2169 AABC Adicion  de Fecha de Alta a la consulta de siniestro
                           pccompani IN NUMBER,
                           pnpresin  IN VARCHAR2,
                           pcsiglas  IN NUMBER,
                           ptnomvia  IN VARCHAR2,
                           pnnumvia  IN NUMBER,
                           ptcomple  IN VARCHAR2,
                           pcpostal  IN VARCHAR2,
                           pcpoblac  IN NUMBER,
                           pcprovin  IN NUMBER,
                           pfgisx    IN FLOAT,
                           pfgisy    IN FLOAT,
                           pfgisz    IN FLOAT,
                           ptdescri  IN VARCHAR2,
                           pctipmat  IN NUMBER,
                           pcmatric  IN VARCHAR2,
                           ptiporisc IN NUMBER,
                           -- Fi Bug 15006 - PFA - 16/08/2010 - nuevos campos en bÃºsqueda siniestros
                           pcpolcia IN VARCHAR2, --Bug.: 14587 - ICV - 14/12/2010
                           pcactivi IN NUMBER, --Bug 18749 - 28/06/2011 - AMC
                           pfiltro  IN NUMBER,
                           pcagente IN NUMBER, -- Bug 21817 - MDS - 2/05/2012
                           pcmotor  IN VARCHAR2, -- Bug 25622/134589 - 06/02/2013 -AMC
                           pcchasis IN VARCHAR2, -- Bug 25622/134589 - 06/02/2013 -AMC
                           pnbastid IN VARCHAR2, -- Bug 25622/134589 - 06/02/2013 -AMC
                           ptrefext IN VARCHAR2, --Bug 32470/204062 - 08/05/2015-VCG
                           pctipref IN NUMBER, --Bug 32470/204062 - 08/05/2015-VCG
                           ptdescrie IN VARCHAR2, -- BUG CONF_309 - 10/09/2016 - JAEG
         pncontrato IN VARCHAR2 DEFAULT NULL, --AP CONF-219
                           mensajes OUT t_iax_mensajes) RETURN SYS_REFCURSOR;

   /*************************************************************************
      Devuelve los siniestros que cumplan con el criterio de selecciÃ³n
      param in pnpoliza     : nÃºmero de pÃ³liza
      param in pncert       : nÃºmero de cerificado por defecto 0
      param in pnsinies     : nÃºmero del siniestro1
      param out mensajes    : mensajes de error
      return                : ref cursor
   *************************************************************************/
   FUNCTION f_consulta_lstsini(pnpoliza IN NUMBER,
                               pncertif IN NUMBER,
                               pnsinies IN VARCHAR2,
                               pcestsin IN NUMBER, -- BUG 16645 --ETM--23/11/2010--0016645: GRC - BÃºsqueda de siniestros
                               pfiltro  IN NUMBER,
                               pnriesgo IN NUMBER,
                               mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /***********************************************************************
      Recupera los datos de los asegurados de la poliza
      param in psseguro  : cÃ³digo de seguro
      param out mensajes : mensajes de error
      return             : objeto tomadores
   ***********************************************************************/
   FUNCTION f_get_asegurados(psseguro IN NUMBER,
                             mensajes OUT t_iax_mensajes)
      RETURN t_iax_asegurados;

   /*************************************************************************
        funciÃ³n borra todo el objeto destinatario de tramitaciones
        param in pnsinies : numero de siniestro
        param in pntramit : numero de siniestro
        param in pctipdes : tipo de destinatario
        param in psperson : codigo de destinario
        param out mensajes : mensajes de error

   -- Bug 14766 - 03/06/2010 - AMC
   *************************************************************************/
   FUNCTION f_del_destinatario(pnsinies IN VARCHAR2,
                               pntramit IN NUMBER,
                               pctipdes IN NUMBER,
                               psperson IN NUMBER,
                               mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
    funciÃ³n devuelvo las garantias de un seguro

    -- Bug 11847 - 23/11/2009 - AMC
    -- Bug 0020472 - JMF - 09/12/2011: porigen (0-crear siniestro, 1-crear reserva)
   *************************************************************************/
   FUNCTION f_get_garantias(psseguro IN NUMBER,
                            pnriesgo IN NUMBER,
                            pccausin IN NUMBER,
                            pcmotsin IN NUMBER,
                            pfsinies IN DATE,
                            porigen  IN NUMBER DEFAULT 0,
                            pctramit IN NUMBER DEFAULT NULL, -- 25812:ASN:23/01/2013
                            pnsinies IN NUMBER DEFAULT NULL, -- 25812:ASN:27/05/2013
                            pntramit IN NUMBER DEFAULT NULL, -- 25812:ASN:27/05/2013
                            pctipres IN NUMBER DEFAULT NULL, -- 25812:ASN:27/05/2013
                            mensajes OUT t_iax_mensajes) RETURN SYS_REFCURSOR;

   /*************************************************************************
    funciÃ³n devuelve la franquicia de una garantia

    -- Bug 11847 - 23/11/2009 - AMC
   *************************************************************************/
   FUNCTION f_get_franquicia_garantia(psseguro IN NUMBER,
                                      pnriesgo IN NUMBER,
                                      pcgarant IN NUMBER,
                                      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Graba el objeto siniestros a las tablas de la bbdd
      param out mensajes  : mensajes de error
      param in pCTRAMITAD : codigo tramitador siniestro (opcional)
      return              : 1 -> Todo correcto
                            0 -> Se ha producido un error
   -- BUG 0024964 - 03/12/2012 - JMF: afegir pCTRAMITAD
   ***********************************************************************/
   FUNCTION f_grabar_siniestro(pnsinies   OUT VARCHAR2,
                               mensajes   OUT t_iax_mensajes,
                               pctramitad IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   /***********************************************************************
     Fa els calculs dels imports del detalld e pagaments
      param out mensajes  : mensajes de error
      return              : 1 -> Todo correcto
                            0 -> Se ha producido un error
    BUG 19981 - 16/11/2011 - MDS - AÃ±adir campos pica, iica, preteiva, ireteiva, preteica, ireteica
   ***********************************************************************/
   FUNCTION f_objcalcula_imports_detpagos(ircmbrut   IN NUMBER,
                                          ireduccion IN NUMBER,
                                          isinret    IN NUMBER,
                                          isuplid    IN NUMBER,
                                          importe    OUT NUMBER,
                                          pretenc    IN NUMBER,
                                          iretenc    OUT NUMBER,
                                          piva       IN NUMBER,
                                          iiva       OUT NUMBER,
                                          ineta      OUT NUMBER,
                                          mensajes   OUT t_iax_mensajes,
                                          pica       IN NUMBER,
                                          iica       OUT NUMBER,
                                          preteiva   IN NUMBER,
                                          ireteiva   OUT NUMBER,
                                          preteica   IN NUMBER,
                                          ireteica   OUT NUMBER,
                                          pccalimp   IN NUMBER, --BUG 24637/147756 - 28/08/2013 - NSS
                                          psidepag   IN NUMBER, --BUG 24637/147756 - 28/08/2013 - NSS
                                          psperson   IN NUMBER, --BUG 24637/147756 - 28/08/2013 - NSS
                                          pfordpag   IN DATE, --BUG 24637/147756 - 28/08/2013 - NSS
                                          pctipgas   IN NUMBER, --BUG 24637/147756 - 28/08/2013 - NSS
                                          pcconcep   IN NUMBER, --BUG 24637/147756 - 28/08/2013 - NSS
                                          pcagente   IN NUMBER, --BUG 24637/147756 - 28/08/2013 - NSS
                                          poretenc   OUT NUMBER, --BUG 24637/147756 - 28/08/2013 - NSS
                                          poiva      OUT NUMBER, --BUG 24637/147756 - 28/08/2013 - NSS
                                          poica      OUT NUMBER, --BUG 24637/147756 - 28/08/2013 - NSS
                                          poreteiva  OUT NUMBER, --BUG 24637/147756 - 28/08/2013 - NSS
                                          poreteica  OUT NUMBER, --BUG 24637/147756 - 28/08/2013 - NSS
                                          piotrosgas  IN NUMBER,
                                          pibaseipoc  IN NUMBER,
                                          pipoconsumo IN NUMBER,
                                          pcmonres    IN VARCHAR2,
                                          pcmonpag    IN VARCHAR2,
                                          pctipres    IN NUMBER,
                                          pcgarant    IN NUMBER,
                                          piipoconsumo  OUT NUMBER,
                                          ppoipoconsumo OUT NUMBER,
                                          pisinretpag   OUT NUMBER,
                                          pinetapag     OUT NUMBER,
                                          pifranq       OUT NUMBER,
                                          valorpesos IN NUMBER,--tarea 3481 andre pfeifer 13/06/19
                                          pvalorconvertido OUT NUMBER--tarea 3481 andre pfeifer 13/06/19
                                          ) RETURN NUMBER;
   /********************************************************************
   Funcion que retorna el valor en dolares dependiendo el valor en pesos 
   IAXIS 5454 AABC 7/11/2019
   *********************************************************************/
   FUNCTION f_sin_calcula_importe(pcmonres         IN  VARCHAR2,
                                  pcmonresdes      IN  VARCHAR2,
                                  valorpesos       IN  NUMBER,
                                  pvalorconvertido OUT NUMBER,                                  
                                  mensajes         OUT t_iax_mensajes
                                  ) RETURN NUMBER;
   /***********************************************************************
      retorna el tramitador i la unitat tramitadora per defecte
      pcempres IN  NUMBER,
      pcunitra OUT VARCHAR2,
      pctramit OUT VARCHAR2,
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_unitradefecte(pcempres IN NUMBER,
                                pcunitra OUT VARCHAR2,
                                pctramit OUT VARCHAR2,
                                mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
      Retorna las causas de un siniestro
      param  in  pcempres :  cÃ³digo de la empresa
      param  in  pcramo  : cÃ³digo del ramo
      param  in  psproduc   : cÃ³digo del producto
      param  in  pccausin   : cÃ³digo de la causa del siniestro
      param  in  pcmotsin   : cÃ³digo motivo de siniestro
      param  in  pctipdes : cÃ³digo tipo destinatario
      param out mensajes  : mensajes de error
      return              : sys_refcursor

      21/05/2009   AMC                 Sinistres.  Bug: 8816
   ***********************************************************************/
   FUNCTION f_get_causas_motivos(pcempres IN NUMBER,
                                 pcramo   IN NUMBER,
                                 psproduc IN NUMBER,
                                 pccausin IN NUMBER,
                                 pcmotsin IN NUMBER,
                                 pctipdes IN NUMBER,
                                 mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /***********************************************************************
      Retorna los destinatarios de un siniestro
      param  in  pscaumot :  cÃ³digo de la causa
      param  in  pctipdes  : cÃ³digo del tipo de destinatario
      param out mensajes  : mensajes de error
      return              : sys_refcursor

      21/05/2009   AMC                 Sinistres.  Bug: 8816
   ***********************************************************************/
   FUNCTION f_get_caumot_destinatario(pscaumot IN NUMBER,
                                      pctipdes IN NUMBER,
                                      mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /***********************************************************************
      Retorna las formulas
      param  in  pscaumot :  cÃ³digo de la causa
      param  in  pctipdes  : cÃ³digo del tipo de destinatario
      param  in  pccampo  : cÃ³digo del campo
      param  in  pcclave  : cÃ³digo de la formula
      param out mensajes  : mensajes de error
      return              : sys_refcursor

      22/05/2009   AMC                 Sinistres.  Bug: 8816
   ***********************************************************************/
   FUNCTION f_get_caumot_destformula(pscaumot IN NUMBER,
                                     pctipdes IN NUMBER,
                                     pccampo  IN VARCHAR2,
                                     pcclave  IN NUMBER,
                                     mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /***********************************************************************
      Retorna los productos
      param  in  pscaumot :  cÃ³digo de la causa
      param  in  psproduc  : cÃ³digo del producto
      param  in  pcactivi  : cÃ³digo de la actividad
      param  in  pcgarant  : cÃ³digo de la garantia
      param  in  pctramit  : cÃ³digo de la tramitaciÃ³n
      param out mensajes  : mensajes de error
      return              : sys_refcursor

      22/05/2009   AMC                 Sinistres.  Bug: 8816
   ***********************************************************************/
   FUNCTION f_get_caumot_producte(pscaumot IN NUMBER,
                                  psproduc IN NUMBER,
                                  pcactivi IN NUMBER,
                                  pcgarant IN NUMBER,
                                  pctramit IN NUMBER,
                                  mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /***********************************************************************
      Inserta o actualiza en sin_causa_motivo
      param  in  pscaumot : cÃ³digo de la causa/motivo
      param  in  pccausin : cÃ³digo de la causa del siniestro
      param  in  pcmotsin : cÃ³digo del motivo del siniestro
      param  in  pcpagaut : si los pagos son automaticos
      param  in  pcmotmov : cÃ³digo motivo del movimiento
      param  in  pcmotfin : cÃ³digo motivo movimiento fin
      param  in  pcmovimi : cÃ³digo motivo movimiento inicial
      param  in  pcdesaut : si genera destinatario automaticamente
      param  in  pcultpag : Pago se crea marcado como Ãºltimo pago
      param  out mensajes : mensajes de error
      return              : 0 -> Tot correcte
                            1 -> S'ha produit un error

      25/05/2009   AMC                 Sinistres.  Bug: 8816
      Bug 12753     18/01/2010  AMC Se aÃ±ade el parametro pcdesaut
      -- Bug 0022490 - 09/07/2012 - JMF: aÃ±adir pcultpag
   ***********************************************************************/
   FUNCTION f_set_sin_causa_motivo(pscaumot IN NUMBER,
                                   pccausin IN NUMBER,
                                   pcmotsin IN NUMBER,
                                   pcpagaut IN NUMBER,
                                   pcmotmov IN NUMBER,
                                   pcmotfin IN NUMBER,
                                   pcmovimi IN NUMBER,
                                   pcdesaut IN NUMBER,
                                   pcultpag IN NUMBER,
                                   mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
      Recupera un registro de sin_causa_motivo
      param  in  pscaumot : cÃ³digo de la causa/motivo
      param  out  pccausin : cÃ³digo de la causa del siniestro
      param  out  pcmotsin : cÃ³digo del motivo del siniestro
      param  out  pcpagaut : si los pagos son automaticos
      param  out  pcmotmov : cÃ³digo motivo del movimiento
      param  out  pcmotfin : cÃ³digo motivo movimiento fin
      param  out  pcmovimi : cÃ³digo motivo movimiento inicial
      param  out  pcdesaut : si genera destinatario automaticamente
      param  out  pcultpag : Pago se crea marcado como Ãºltimo pago

      return              : 0 -> Tot correcte
                            1 -> S'ha produit un error

      26/05/2009   AMC                 Sinistres.  Bug: 8816
      Bug 12753     18/01/2010  AMC Se aÃ±ade el parametro pcdesaut
      -- Bug 0022490 - 09/07/2012 - JMF: aÃ±adir pcultpag
   ***********************************************************************/
   FUNCTION f_get_caumot(pscaumot IN NUMBER,
                         pccausin OUT NUMBER,
                         pcmotsin OUT NUMBER,
                         pcpagaut OUT NUMBER,
                         pcmotmov OUT NUMBER,
                         pcmotfin OUT NUMBER,
                         pcmovimi OUT NUMBER,
                         pcdesaut OUT NUMBER,
                         pcultpag OUT NUMBER,
                         mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
      Guarda a la taula una nova conf. per el producte
      param  in  pscaumot :  cÃ³digo de la causa
      param  in  psproduc  : cÃ³digo del producto
      param  in  pcactivi  : cÃ³digo de la actividad
      param  in  pcgarant  : cÃ³digo de la garantia
      param  in  pctramit  : cÃ³digo de la tramitaciÃ³n
      param out mensajes  : mensajes de error
      return              : NUMBER

      26/05/2009   XPL                 Sinistres.  Bug: 8816
   ***********************************************************************/
   FUNCTION f_set_caumot_producte(pscaumot IN NUMBER,
                                  psproduc IN NUMBER,
                                  pcactivi IN NUMBER,
                                  pcgarant IN NUMBER,
                                  pctramit IN NUMBER,
                                  mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
      Eliminar de la taula una conf. del producte
      param  in  pscaumot :  cÃ³digo de la causa
      param  in  psproduc  : cÃ³digo del producto
      param  in  pcactivi  : cÃ³digo de la actividad
      param  in  pcgarant  : cÃ³digo de la garantia
      param  in  pctramit  : cÃ³digo de la tramitaciÃ³n
      param out mensajes  : mensajes de error
      return              : NUMBER

      26/05/2009   XPL                 Sinistres.  Bug: 8816
   ***********************************************************************/
   FUNCTION f_del_caumot_producte(pscaumot IN NUMBER,
                                  psproduc IN NUMBER,
                                  pcactivi IN NUMBER,
                                  pcgarant IN NUMBER,
                                  pctramit IN NUMBER,
                                  mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
      Grabar les formulas
      param  in  pscaumot :  cÃ³digo de la causa
      param  in  pctipdes  : cÃ³digo del tipo de destinatario
      param  in  pccampo  : cÃ³digo del campo
      param  in  pcclave  : cÃ³digo de la formula
      param out mensajes  : mensajes de error
      return              : sys_refcursor

      26/05/2009   XPL                 Sinistres.  Bug: 8816
   ***********************************************************************/
   FUNCTION f_set_caumot_destformula(pscaumot IN NUMBER,
                                     pctipdes IN NUMBER,
                                     pccampo  IN VARCHAR2,
                                     pcclave  IN NUMBER,
                                     mensajes OUT t_iax_mensajes)
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
   FUNCTION f_del_caumot_destformula(pscaumot IN NUMBER,
                                     pctipdes IN NUMBER,
                                     pccampo  IN VARCHAR2,
                                     pcclave  IN NUMBER,
                                     mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Grabar en sin_det_causa_motivo
      param  in  pscaumot : cÃ³digo de la causa/motivo
      param  in  pctipdes : cÃ³digo tipo destinatario
      param  in  pcmodfis : cÃ³digo del modelo fiscal
      param  out mensajes : mensajes de error
      return              : 0 -> Tot correcte
                            1 -> S'ha produit un error

      27/05/2009   AMC                 Sinistres.  Bug: 8816
   ***********************************************************************/
   FUNCTION f_set_sindetcausamot(pscaumot IN NUMBER,
                                 pctipdes IN NUMBER,
                                 pcmodfis IN NUMBER,
                                 mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
      Devuelve el siguiente codigo de causa/motivo
      param  out  pscaumot : PrÃ³ximo cÃ³digo de la causa/motivo
      param  out  mensajes : Mensajes de error
      return              : 0 -> Tot correcte
                            1 -> S'ha produit un error

      27/05/2009   AMC                 Sinistres.  Bug: 8816
   ***********************************************************************/
   FUNCTION f_get_nextscaumot(pscaumot OUT NUMBER,
                              mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
      Eliminar de la taula sin_det_causa_motivo
      param  in  pscaumot : cÃ³digo de la causa/motivo
      param  in  pctipdes : cÃ³digo tipo destinatario
      param  out  mensajes : Mensajes de error
      return              : 0 -> Tot correcte
                            1 -> S'ha produit un error

      27/05/2009   AMC                 Sinistres.  Bug: 8816
   ***********************************************************************/
   FUNCTION f_del_caumot_destinatario(pscaumot IN NUMBER,
                                      pctipdes IN NUMBER,
                                      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Eliminar de la taula sin_det_causa_motivo
      param  in  pscaumot : cÃ³digo de la causa/motivo
      param  out  mensajes : Mensajes de error
      return              : 0 -> Tot correcte
                            1 -> S'ha produit un error

      28/05/2009   AMC                 Sinistres.  Bug: 8816
   ***********************************************************************/
   FUNCTION f_del_caumot(pscaumot IN NUMBER,
                         mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
     FUNCTION F_ESTADO_TRAMITACION:
      Cambia el estado de una tramitaciÃ³n
      param in pnsinies : NÃºmero siniestro
      param in pntramit : NÃºmero tramitaciÃ³n
      param in pcesttra : CÃ³digo estado
      param  out  mensajes : Mensajes de error
      return            : 0 -> Tot correcte
                          1 -> S'ha produit un error
      31/07/2009   XVM                 Sinistres.  Bug: 8820
   ***********************************************************************/
   FUNCTION f_estado_tramitacion(pnsinies IN VARCHAR2,
                                 pntramit IN NUMBER,
                                 pcesttra IN NUMBER,
                                 mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
     FUNCTION F_ESTADO_SINIESTRO:
      Cambia el estado de un siniestro
      param in  pnsinies   : NÃºmero Siniestro
      param in pcestsin    : codi estat sinistre
      param in pccauest    : codi causa estat sinistre
      param in pcunitra    : codi unitat tramitaciÃ³
      param in pctramitad  : codi tramitador
      param in pcsubtra    : codi subestat tramitaciÃ³
      param  out  mensajes : Mensajes de error
      return               : 0 -> Tot correcte
                             1 -> S'ha produit un error
      31/07/2009   XVM                 Sinistres.  Bug: 8820
   ***********************************************************************/
   FUNCTION f_estado_siniestro(pnsinies   IN VARCHAR2,
                               pcestsin   IN NUMBER,
                               pccauest   IN NUMBER,
                               pcunitra   IN VARCHAR2,
                               pctramitad IN VARCHAR2,
                               pcsubtra   IN NUMBER,
                               pfsinfin   IN DATE,
                               pobserv    IN VARCHAR2 DEFAULT NULL,   --IAXIS 3663 AABC 12/04/2019 Adicion campo observacion
                               mensajes   OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
     FUNCTION F_set_DOCUMENTOS:
         Inserta a la taula SIN_TRAMITA_DOCUMENTO dels parÃ metres informats.
         param in psproduc    : CÃ³digo producto
         param in pcactivi    : CÃ³digo actividad
         param in pccausin    : CÃ³digo causa
         param in pcmotsin    : CÃ³digo motivo
         param in pcidioma    : CÃ³digo idioma
         param in pctramit    : CÃ³digo tramitaciÃ³n (opcional, sinÃ³ = 0)
         param  out  mensajes : Mensajes de error
         return               : 0 -> Tot correcte
                                1 -> S'ha produit un error
      31/07/2009   XVM                 Sinistres.  Bug: 8820
   ***********************************************************************/
   FUNCTION f_set_documentos(pnsinies IN VARCHAR2,
                             psproduc IN NUMBER,
                             pcactivi IN NUMBER,
                             pccausin IN NUMBER,
                             pcmotsin IN NUMBER,
                             pcidioma IN NUMBER,
                             mensajes OUT t_iax_mensajes,
                             pntramit IN NUMBER DEFAULT 0) RETURN NUMBER;

   /***********************************************************************
     FUNCTION F_SET_CAUSA:
         Inserta una causa amb els  parÃ metres informats.
         param in pccauest     : CÃ³digo Causa Estado
         param in pcestsin     : CÃ³digo Estado Siniestro
         param in pcidioma     : CÃ³digo Idioma
         param in ptcauest     : DescripciÃ³n Causa Estado
         param out  mensajes   : Mensajes de error
         return                : 0 -> Tot correcte
                                 1 -> S'ha produit un error
      31/07/2009   XVM                 Sinistres.  Bug: 8820
   ***********************************************************************/
   FUNCTION f_set_causa(pccauest IN NUMBER,
                        pcestsin IN NUMBER,
                        pcidioma IN NUMBER,
                        ptcauest IN VARCHAR2,
                        mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_get_causas
         Recupera de la tabla SIN_CODCAUEST y SIN_DESCAUEST las causas
         param in pccauest  : CÃ³digo Causa Estado
         param in pcestsin  : CÃ³digo Estado Siniestro
         param in ptcauest  : DescripciÃ³n Estado
         param out mensajes : T_IAX_MENSAJES
         return             : ref cursor
      31/07/2009   XVM                 Sinistres.  Bug: 8820
   ***********************************************************************/
   FUNCTION f_get_causas(pccauest IN NUMBER,
                         pcestsin IN NUMBER,
                         ptcauest IN VARCHAR2,
                         mensajes OUT t_iax_mensajes) RETURN SYS_REFCURSOR;

   /***********************************************************************
      FUNCTION f_get_causa
         Recupera de la tabla SIN_CODCAUEST y SIN_DESCAUEST una causa en
         concreto con sus descripciones
         param in pccauest : CÃ³digo Causa Estado
         param in pcestsin : CÃ³digo Estado Siniestro
         param out mensajes : T_IAX_MENSAJES
         return             : ref cursor
      31/07/2009   XVM                 Sinistres.  Bug: 8820
   ***********************************************************************/
   FUNCTION f_get_causa(pccauest IN NUMBER,
                        pcestsin IN NUMBER,
                        mensajes OUT t_iax_mensajes) RETURN SYS_REFCURSOR;

   /***********************************************************************
     FUNCTION f_del_causa
         Recupera de la tabla SIN_CODCAUEST y SIN_DESCAUEST una causa en
         concreto con sus descripciones
         param in pccauest : CÃ³digo Causa Estado
         param in pcestsin : CÃ³digo Estado Siniestro
         return            : 0 -> Tot correcte
                             1 -> S'ha produit un error
      31/07/2009   XVM                 Sinistres.  Bug: 8820
   ***********************************************************************/
   FUNCTION f_del_causa(pccauest IN NUMBER,
                        pcestsin IN NUMBER,
                        mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_del_detcausa
         Recupera de la tabla SIN_CODCAUEST y SIN_DESCAUEST una causa en
         concreto con sus descripciones
         param in pccauest : CÃ³digo Causa Estado
         param in pcestsin : CÃ³digo Estado Siniestro
         param in pcidioma : CÃ³digo Idioma
         return            : 0 -> Tot correcte
                             1 -> S'ha produit un error
      31/07/2009   XVM                 Sinistres.  Bug: 8820
   ***********************************************************************/
   FUNCTION f_del_detcausa(pccauest IN NUMBER,
                           pcestsin IN NUMBER,
                           pcidioma IN NUMBER,
                           mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
    funciÃ³n recupera documentos de una tramitaciÃ³n concreta
    ob_iax_siniestros.documentacion
       nsinies        VARCHAR2(14),   --NÃºmero Siniestro
       ntramit        NUMBER(3),   --NÃºmero TramitaciÃ³n Siniestro
       ndocume        NUMBER(6),   --NÃºmero Documento

   *************************************************************************/
   FUNCTION f_get_objeto_sintramidocumento(pnsinies IN VARCHAR2,
                                           pntramit IN NUMBER,
                                           pndocume IN NUMBER,
                                           mensajes OUT t_iax_mensajes)
      RETURN ob_iax_sin_trami_documento;

   /*************************************************************************
    funciÃ³n graba en una variable global de la capa IAX los valores del objeto
    ob_iax_siniestros.documentacion
       nsinies        VARCHAR2(14),   --NÃºmero Siniestro
       ntramit        NUMBER(3),   --NÃºmero TramitaciÃ³n Siniestro
       ndocume        NUMBER(6),   --NÃºmero Documento
       cdocume        NUMBER(6),   --CÃ³digo Documento
       iddoc          NUMBER(10),  --Identificador documento GEDOX
       freclama       DATE,        --Fecha reclamacion
       frecibe        DATE,        --Fecha recepcion
       fcaduca        DATE,        --Fecha caducidad
       cobliga        NUMBER(1)    --CÃ³digo obligatoriedad
       descripcion    VARCHAR2     --Descripcion del usuario para el documento
   *************************************************************************/
   FUNCTION f_set_objeto_sintramidocumento(pnsinies     IN VARCHAR2,
                                           pntramit     IN NUMBER,
                                           pndocume     IN NUMBER,
                                           pcdocume     IN NUMBER,
                                           piddoc       IN NUMBER,
                                           pfreclama    IN DATE,
                                           pfrecibe     IN DATE,
                                           pfcaduca     IN DATE,
                                           pcobliga     IN NUMBER,
                                           pdescripcion IN VARCHAR2,
                                           pndocume_out OUT NUMBER,
                                           mensajes     OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION F_SET_MOVSINIESTRO
      Guarda un moviment de sinistre
      param  in  pnsinies    : cÃ³digo siniestro
      param  in  pcestsin    : cÃ³digo estado siniestro
      param  in  pfestsin    : data estado siniestro
      param  in  pccauest    : cÃ³digo causa estado siniestro
      param  in  pcunitra    : cÃ³digo unidad tramitaciÃ³n
      param  in  pctramitad  : cÃ³digo tramitador
      param out pnmovsin  : nÃºmero movimiento
      param out mensajes  : mensajes de error
      return              : NUMBER
      26/05/2009   XVM
   ***********************************************************************/
   FUNCTION f_set_movsiniestro(pnsinies   IN VARCHAR2,
                               pcestsin   IN NUMBER,
                               pfestsin   IN DATE,
                               pccauest   IN NUMBER,
                               pcunitra   IN VARCHAR2,
                               pctramitad IN VARCHAR2,
                               pnmovsin   OUT NUMBER,
                               mensajes   OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
      Recupera los datos de los conductores de la poliza
      param in psseguro  : cÃ³digo de seguro
      param in pnriesgo  : NÃºmero de riesgo
      param in pnriesgo  : nÃºmero de riesgo
      return             : objeto tomadores
   ***********************************************************************/
   FUNCTION f_get_conductores(psseguro IN NUMBER,
                              pnriesgo IN NUMBER,
                              mensajes OUT t_iax_mensajes)
      RETURN t_iax_autconductores;

   /***********************************************************************
      Recupera los datos de los riesgos de la pÃ³liza
      param in psseguro  : cÃ³digo de seguro
      param out mensajes : mensajes de error
      param out mensajes : mensajes de error
      return             : T_IAX_GESTRIESGOS con la colecciÃ³n de riesgos de la pÃ³liza
                           NULL si error
   ***********************************************************************/
   FUNCTION f_get_polriesgos(psseguro IN NUMBER,
                             mensajes OUT t_iax_mensajes,
                             pnriesgo IN NUMBER DEFAULT NULL)
      RETURN t_iax_riesgos;

   /***********************************************************************
      Recupera los datos del documento siniestro
      param in pcdocume: CÃ³digo del documento
      param in pcidioma : CÃ³digo del idioma
      param out pttitdoc: Nombre identificativo Documento
      param out ptdocume : DescripciÃ³n Documento
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_documentos(pcdocume IN NUMBER,
                             pcidioma IN NUMBER,
                             pttitdoc OUT VARCHAR2,
                             ptdocume OUT VARCHAR2,
                             mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
         14/10/2009 XPL bug. 11192. Alta de siniestros de Vida
      Dona d'alta la capÃ§alera i localitzaciÃ³ de Sinistres VIDA XPL
      pnsinies IN VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfsinies IN DATE,
      pfnotifi IN DATE,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      phsinies IN VARCHAR2,
      pcculpab IN NUMBER,
      ptsinies IN VARCHAR2,
      ptzonaocu IN VARCHAR2,
      pcmeddec IN NUMBER,
      pctipdec IN NUMBER,
      ptnomdec IN VARCHAR2,
      ptape1dec IN VARCHAR2,
      ptape2dec IN VARCHAR2,
      ptteldec IN VARCHAR2,
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      pnsincia IN VARCHAR2,
      pnpresin IN VARCHAR2,
      mensajes OUT t_iax_mensajes
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_set_objeto_cabecera_vida(pnsinies   IN VARCHAR2,
                                       psproduc   IN NUMBER,
                                       pcactivi   IN NUMBER,
                                       psseguro   IN NUMBER,
                                       pnriesgo   IN NUMBER,
                                       pfsinies   IN DATE,
                                       pfnotifi   IN DATE,
                                       pccausin   IN NUMBER,
                                       pcmotsin   IN NUMBER,
                                       phsinies   IN VARCHAR2,
                                       pcculpab   IN NUMBER,
                                       ptsinies   IN VARCHAR2,
                                       ptzonaocu  IN VARCHAR2,
                                       pcmeddec   IN NUMBER,
                                       pctipdec   IN NUMBER,
                                       ptnomdec   IN VARCHAR2,
                                       ptnom1dec  IN VARCHAR2, --bug 19896--ETM-20/12/2011--AÃ±adir campo tnombre1 al declarante
                                       ptnom2dec  IN VARCHAR2, --bug 19896--ETM-20/12/2011--AÃ±adir campo tnombre2 al declarante
                                       ptape1dec  IN VARCHAR2,
                                       ptape2dec  IN VARCHAR2,
                                       ptteldec   IN VARCHAR2,
                                       ptmovildec IN VARCHAR2, --BUG 19896 --ETM --20/12/2011-AÃ±adir campo telefono mov de declarante
                                       ptemaildec IN VARCHAR2, --BUG 19896 --ETM --20/12/2011-AÃ±adir campo email  de declarante
                                       pctipide   IN NUMBER,
                                       pnnumide   IN VARCHAR2,
                                       pnsincia   IN VARCHAR2, --BUG 14587 - PFA - 13/08/2010 - AÃ±adir campo siniestro compaÃ±ia
                                       pccompani  IN NUMBER,
                                       pnpresin   IN VARCHAR2, -- Bug 15006 - PFA - 16/08/2010 - nuevos campos en bÃºsqueda siniestros
                                       pcagente   IN NUMBER, -- Bug 21817 - MDS - 2/05/2012
                                       mensajes   OUT t_iax_mensajes)
      RETURN NUMBER;

   -- BUG11434:DRA:13/11/2009:Inici
   /***********************************************************************
      Recupera los datos de un pago / recobro
      param in  pnsinies  : nÃºmero de siniestro
      param in  pntramit  : nÃºmero de tramitaciÃ³n
      param in  psidepag  : nÃºmero d pago
      param out  ob_iax_sin_trami_pago :  ob_iax_sin_trami_pago
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_pagrecob(pnsinies    IN VARCHAR2,
                           pntramit    IN NUMBER,
                           psidepag    IN NUMBER,
                           ob_pagrecob OUT ob_iax_sin_trami_pago,
                           mensajes    OUT t_iax_mensajes) RETURN NUMBER;

   -- BUG11434:DRA:13/11/2009:Fi
   /***********************************************************************
      FUNCTION F_get_desunitradefecte
      Obtenim descripciÃ³ unitat tram i tramitador i els codis per Defecte
      param  out  ptunitra    : desc unidad tramitaciÃ³n
      param  out  pttramitad  : desc tramitador
      param  out  pcunitra    : cÃ³digo unidad tramitaciÃ³n
      param  out  pctramitad  : cÃ³digo tramitador
      param in out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_desunitradefecte(p_cuser   IN VARCHAR2,
                                   p_sseguro IN NUMBER,
                                   p_ccausin IN NUMBER,
                                   p_cmotsin IN NUMBER,
                                   p_nsinies IN NUMBER,
                                   p_ntramit IN NUMBER,
                                   ptunitra  OUT VARCHAR2,
                                   pttramit  OUT VARCHAR2,
                                   pcunitra  OUT VARCHAR2,
                                   pctramit  OUT VARCHAR2,
                                   mensajes  OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
      Recupera el historico de reservas por tipo
      param in  pnsinies  : nÃºmero de siniestro
      param in  pntramit  : nÃºmero de tramitaciÃ³n
      param in  pctipres  : CÃ³digo de tipo de reservar
      param in  pcgarant  : CÃ³digo de la garantia
      param in  pnmovres  : Numero de movimiento de la reserva
      param in  psproduc  : CÃ³digo del producto
      param in  pcactivi  : CÃ³digo de la actividad
      param out  t_iax_sin_trami_reserva :  t_iax_sin_trami_reserva
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error

      -- Bug 14490 - 18/05/2010 - AMC - Se aÃ±ade los parametros pnmovres,psproduc,pcactivi
   ***********************************************************************/
   FUNCTION f_get_histreservas(pnsinies   IN VARCHAR2,
                               pntramit   IN NUMBER,
                               pctipres   IN NUMBER,
                               pctipgas   IN NUMBER, -- 26108
                               pcgarant   IN NUMBER,
                               pnmovres   IN NUMBER,
                               psproduc   IN NUMBER,
                               pcactivi   IN NUMBER,
                               pcmonres   IN VARCHAR2,
                               t_reservas OUT t_iax_sin_trami_reserva,
                               mensajes   OUT t_iax_mensajes) RETURN NUMBER;

   /**************************************************************************
      FunciÃ³n que genera un destinatario automatico
      param in  psseguro : Numero de seguro
      param in  pfsinies : Fecha siniestro
      param in  pccausin : CÃ³digo causa siniestro
      param in  pcmotsin : CÃ³digo motivo siniestro
      param in  pcgarant : CÃ³digo de la garantia
      param out psperson : CÃ³digo persona
      param out pctipdes : Codigo tipo destinatario
      param out pctipban : CÃ³digo tipo cuenta bancaria
      param out pcbancar : Cuenta bancaria
      param out pcpaise  : CÃ³digo PaÃ­s Residencia
      param out pctipcap : Tipo de prestaciÃ³n.  Valor 205.-- Bug 0017970 - 16/03/2011 - JMF
      param out mensajes : Mensajes de error
      return              : 0 -> Tot correcte
                            1 -> S'ha produit un error

      Bug 12753 - 19/01/2010 - AMC
   ***********************************************************************/
   FUNCTION f_destina_aut(psseguro IN seguros.sseguro%TYPE,
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
                          mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /**************************************************************************
      FunciÃ³n que inserta un pago
      param in  pnsinies : nÃºmero de siniestro
      param in  pnriesgo : nÃºero de riesgp
      param in  pntramit : nÃºmero de tramitacion
      param in  pctipres : cÃ³digo del tipo de reserva
      param in  pcgarant : cÃ³digo de la garantia
      param in  pfsinies : fecha del siniestro
      param in  pfperini : fecha inicio periodo
      param in  pfperfin : fecha fin periodo
      param in  psproduc : CÃ³digo del producto
      param in  pcactivi : CÃ³digo de la actividad
      param out psidepag : Codigo de identificafiÃ³n del pago
      param out pipago   : Importe del pago
      param out mensajes : Mensajes de error

      return              : 0 -> Tot correcte
                            1 -> S'ha produit un error

      Bug 11849 - 20/01/2010 - AMC
   ***********************************************************************/
   FUNCTION f_inserta_pago(pnsinies IN sin_tramita_pago.nsinies%TYPE,
                           pnriesgo IN sin_siniestro.nriesgo%TYPE,
                           pntramit IN sin_tramita_pago.ntramit%TYPE,
                           pctipres IN sin_tramita_reserva.ctipres%TYPE,
                           pctipgas IN sin_tramita_reserva.ctipgas%TYPE, -- 26108
                           pcgarant IN sin_tramita_reserva.cgarant%TYPE,
                           pfsinies IN DATE,
                           pfperini IN sin_tramita_reserva.fresini%TYPE,
                           pfperfin IN sin_tramita_reserva.fresfin%TYPE,
                           psproduc IN NUMBER,
                           pcactivi IN NUMBER,
                           psidepag OUT sin_tramita_pago.sidepag%TYPE,
                           pipago   OUT sin_tramita_pago.isinret%TYPE,
                           mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /**************************************************************************
      FunciÃ³n que inserta un pago
      param in  pnsinies : nÃºmero de siniestro
      param in  pntramit : nÃºmero de tramitacion
      param in  pctipres : cÃ³digo del tipo de reserva
      param in  psproduc : CÃ³digo de producto
      param in  pcactivi : CÃ³digo de la actividad
      param in  pcgarant : cÃ³digo de la garantia
      param out pfperini : fecha inicio periodo
      param out mensajes : mensajes de error

      return              : 0 -> Tot correcte
                            1 -> S'ha produit un error

      Bug 12207 - 01/02/2010 - AMC
   ***********************************************************************/
   FUNCTION f_get_fechareserva(pnsinies IN sin_tramita_pago.nsinies%TYPE,
                               pntramit IN sin_tramita_pago.ntramit%TYPE,
                               pctipres IN sin_tramita_reserva.ctipres%TYPE,
                               pctipgas IN sin_tramita_reserva.ctipgas%TYPE, -- 26108
                               psproduc IN NUMBER,
                               pcactivi IN NUMBER,
                               pcgarant IN sin_tramita_reserva.cgarant%TYPE,
                               pfperini OUT sin_tramita_reserva.fresini%TYPE,
                               mensajes OUT t_iax_mensajes) RETURN NUMBER;
/**************************************************************************
      FunciÃ³n que borrar amparo
      param in  pnsinies : nÃºmero de siniestro
      param in  pntramit : nÃºmero de tramitacion
     
      param in  pcgarant : cÃ³digo de la garantia
      param in  psproduc : CÃ³digo del producto
      param in  pcactivi : CÃ³digo de la actividad
      param out mensajes : mensajes de error

      return              : 0 -> Tot correcte
                            1 -> S'ha produit un error

      Bug 12207 - 01/02/2010 - AMC
   ***********************************************************************/
   FUNCTION f_del_amparo(pnsinies IN sin_tramita_amparo.nsinies%TYPE,
                             pntramit IN sin_tramita_amparo.ntramit%TYPE,                             
                             pcgarant IN sin_tramita_amparo.cgarant%TYPE,
                             psproduc IN NUMBER,
                             pcactivi IN NUMBER,
                             mensajes OUT t_iax_mensajes) RETURN NUMBER;
   /**************************************************************************
      FunciÃ³n que borrar el ultimo movimiento de una reserva si no tiene pagos
      param in  pnsinies : nÃºmero de siniestro
      param in  pntramit : nÃºmero de tramitacion
      param in  pctipres : cÃ³digo del tipo de reserva
      param in  pnmovres : Numero de movimiento
      param in  pcgarant : cÃ³digo de la garantia
      param in  psproduc : CÃ³digo del producto
      param in  pcactivi : CÃ³digo de la actividad
      param out mensajes : mensajes de error

      return              : 0 -> Tot correcte
                            1 -> S'ha produit un error

      Bug 12207 - 01/02/2010 - AMC
   ***********************************************************************/
   FUNCTION f_del_ultreserva(pnsinies IN sin_tramita_pago.nsinies%TYPE,
                             pntramit IN sin_tramita_pago.ntramit%TYPE,
                             pctipres IN sin_tramita_reserva.ctipres%TYPE,
                             pctipgas IN sin_tramita_reserva.ctipgas%TYPE, -- 26108
                             pnmovres IN sin_tramita_reserva.nmovres%TYPE,
                             pcgarant IN sin_tramita_reserva.cgarant%TYPE,
                             psproduc IN NUMBER,
                             pcactivi IN NUMBER,
                             mensajes OUT t_iax_mensajes) RETURN NUMBER;
FUNCTION f_get_amparo(
      pnsinies IN VARCHAR2,		     
       pntramit IN NUMBER,		     
       pcgarant IN NUMBER,		     
       ob_amparo OUT ob_iax_sin_trami_amparo,
		mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
   /***********************************************************************
      Recupera los datos de una determinada reserva
      param in  pnsinies  : nÃºmero de siniestro
      param in  pntramit  : nÃºmero de tramitaciÃ³n
      param in  pctipres  : nÃºmero de tipo de reserva
      param in  pnmovres  : nÃºmero de movimiento de reserva
      param out  ob_iax_sin_trami_reserva :  ob_iax_sin_trami_reserva
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error

      Bug 12207 - 03/02/2010 - AMC
   ***********************************************************************/
   FUNCTION f_get_reserva(pnsinies   IN VARCHAR2,
                          pntramit   IN NUMBER,
                          pctipres   IN NUMBER,
                          pnmovres   IN NUMBER,
                          pcgarant   IN NUMBER,
                          ob_reserva OUT ob_iax_sin_trami_reserva,
                          mensajes   OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
      Recupera los datos de una determinada referencia
      param in  pnsinies  : nÃºmero de siniestro
      param in  psrefext  : nÃºmero de referencia
      param out  ob_iax_siniestro_referencias :  ob_iax_siniestro_referencias
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error

      Bug 18932 - 02/09/2011 - JRB
   ***********************************************************************/
   FUNCTION f_get_referencia(pnsinies       IN VARCHAR2,
                             psrefext       IN NUMBER,
                             ob_referencias OUT ob_iax_siniestro_referencias,
                             mensajes       OUT t_iax_mensajes) RETURN NUMBER;

   /**************************************************************************
      FunciÃ³n que comprueba la modificacion de la fresfin de una reserva
      param in  pnsinies : nÃºmero de siniestro
      param in  pntramit : nÃºmero de tramitacion
      param in  pctipres : cÃ³digo del tipo de reserva
      param in  pcgarant : cÃ³digo de la garantia
      param in  pfresfin : Fecha fin de la reserva
      param out pfresfin_out : Fecha permitida como fecha fin reserva
      param out mensajes : Mensajes de error

      return              : 0 -> Tot correcte
                            Codigo error -> S'ha produit un error

      Bug 12207 - 03/02/2010 - AMC
   ***********************************************************************/
   FUNCTION f_actfresfin(pnsinies     IN sin_tramita_pago.nsinies%TYPE,
                         pntramit     IN sin_tramita_pago.ntramit%TYPE,
                         pctipres     IN sin_tramita_reserva.ctipres%TYPE,
                         pcgarant     IN sin_tramita_reserva.cgarant%TYPE,
                         pfresfin     IN sin_tramita_reserva.fresfin%TYPE,
                         pfresfin_out OUT sin_tramita_reserva.fresfin%TYPE,
                         mensajes     OUT t_iax_mensajes) RETURN NUMBER;

   /**************************************************************************
       FUNCTION f_pago_aut
       Crea un pago automÃ¡tico
       param in pdata   : fecha final de pago
       param out pncobros : Numero de cobros generados
       param out mensajes : Mensajes de error

       return              : 0 -> Tot correcte
                             Codigo error -> S'ha produit un error

       Bug 12207 - 03/02/2010 - AMC
   ***********************************************************************/
   FUNCTION f_pago_aut(p_data   IN DATE,
                       pncobros OUT NUMBER,
                       psproces OUT NUMBER, -- Bug 16580 - 15/11/2010 - AMC
                       mensajes OUT t_iax_mensajes) RETURN NUMBER;

   --INI BUG 31294/174788:NSS:20/05/2014
   --******Se vuelve a montar todo el proceso de alta y modificaciÃ³n detalle pago utilizando el objeto OB_IAX_SIN_TRAMI_PAGO_GAR******
   --******por lo tanto deja de utilizarse esta funciÃ³n para la modificaciÃ³n del pago******
   /*
   -- BUG 19981 - 07/11/2011 - MDS - AÃ±adir campos preteiva, preteica, ireteiva, ireteica, ireteivapag, ireteicapag en la cabecera, insert
      FUNCTION f_set_sintram_pagrecob_gar2(
         psseguro IN NUMBER,
         pntramit IN NUMBER,
         pctippag IN NUMBER,
         psidepag IN NUMBER,
         pctipres IN NUMBER,
         pctipgas IN NUMBER,   -- 26108
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
         piresred IN NUMBER,
         piresrcm IN NUMBER,
         ppiva IN NUMBER,
         ppretenc IN NUMBER,
         pcconpag IN NUMBER,
         pnorden IN NUMBER,
         mensajes OUT t_iax_mensajes,
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
         pcreteica_tipind IN NUMBER DEFAULT NULL,   --bug 24637/147756:NSS:14/03/2014
         pitotimp IN NUMBER DEFAULT NULL,   --bug 24637/147756:NSS:03/03/2014
         pitotret IN NUMBER DEFAULT NULL   --bug 24637/147756:NSS:21/03/2014
                                        )
         RETURN NUMBER;*/

   /***********************************************************************
      Recupera los datos del riesgo de hogar
      param in psseguro  : cÃ³digo de seguro
      param in pnriesgo  : cÃ³digo del riesgo
      param out mensajes : mensajes de error
      return             : ref cursor

      Bug 12668 - 24/02/2010 - AMC
   ***********************************************************************/
   FUNCTION f_get_datsitriesgo(psseguro IN NUMBER,
                               pnriesgo IN NUMBER,
                               mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /**************************************************************************
      FunciÃ³n que indica si una reserva se puede modificar
      param in  pnsinies  : nÃºmero de siniestro
      param in  pntramit  : nÃºmero de tramitacion
      param in  pctipres  : CÃ³digo del tipo de reserva
      param in  pcgarant  : CÃ³digo de la garantia
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
   FUNCTION f_mov_reserva(pnsinies     IN VARCHAR2,
                          pntramit     IN NUMBER,
                          pctipres     IN NUMBER,
                          pctipgas     IN NUMBER, -- 26108
                          pcgarant     IN NUMBER,
                          pnmovres     IN NUMBER,
                          psproduc     IN NUMBER,
                          pcactivi     IN NUMBER,
                          pmodificable OUT NUMBER,
                          mensajes     OUT t_iax_mensajes) RETURN NUMBER;

   /**************************************************************************
      FunciÃ³n que devuelve si se permite borrar una reserva
      param in  pnsinies  : nÃºmero de siniestro
      param in  pntramit  : nÃºmero de tramitacion
      param in  pctipres  : CÃ³digo del tipo de reserva
      param in  pcgarant  : CÃ³digo de la garantia
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
   FUNCTION f_perdelreserva(pnsinies     IN VARCHAR2,
                            pntramit     IN NUMBER,
                            pctipres     IN NUMBER,
                            pctipgas     IN NUMBER, -- 26108
                            pcgarant     IN NUMBER,
                            pfresini     IN DATE,
                            psproduc     IN NUMBER,
                            pcactivi     IN NUMBER,
                            pmodificable OUT NUMBER,
                            mensajes     OUT t_iax_mensajes) RETURN NUMBER;

   /**************************************************************************
      FunciÃ³n que devuelve si se debe generar la reserva y el destinatario
      param in  pccausin  : nÃºmero de siniestro
      param in  pcmotsin  : nÃºmero de tramitacion
      param in  pcgarant  : CÃ³digo de la garantia
      param in  psproduc  : Codigo del producto
      param in  pcactivi  : Codigo de la actividad
      param out pgenerar : 0 - No se genera
                           1 - Se genera
      param out mensajes  : Mensajes de error
      return             : 0 -> Tot correcte
                            Codigo error -> S'ha produit un error

      Bug 14752 - 01/06/2010 - AMC
   ***********************************************************************/
   FUNCTION f_gen_resdestinatari(pccausin IN NUMBER,
                                 pcmotsin IN NUMBER,
                                 pcgarant IN NUMBER,
                                 psproduc IN NUMBER,
                                 pcactivi IN NUMBER,
                                 pgenerar OUT NUMBER,
                                 mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /**************************************************************************
      FunciÃ³n que devuelve el capital de una garantia
      param in  pcgarant  : CÃ³digo de la garantia
      param in  psseguro  : CÃ³digo del seguro
      param in  pnsinies  : CÃ³digo del siniestro
      param out pcapital  : Capital de la garantia
      param out mensajes  : mensajes de error
      return              : 0 -> Tot correcte
                           Codigo error -> S'ha produit un error

      Bug 14816 - 02/06/2010 - AMC
   ***********************************************************************/
   FUNCTION f_get_capitalgar(pcgarant IN NUMBER,
                             psseguro IN NUMBER,
                             pnsinies IN VARCHAR2,
                             pcapital OUT NUMBER,
                             mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /**************************************************************************
      FunciÃ³n que retorna los siniestros de una pÃ³liza, siendo optativo filtrar por su nÃºmero de riesgo.
      param in  psseguro  : cÃ³digo que identifica la pÃ³liza en AXIS
      param in  pnriesgo  : cÃ³digo que identifica el riesgo de la pÃ³liza en AXIS
      param out mensajes  : mensajes de error
      return sys_refcursor: cursor que devuelve el listado

      Bug 15965 - 10/09/2010 - SRA
   ***********************************************************************/
   FUNCTION f_consulta_lstsini_riesgo(psseguro IN NUMBER,
                                      pnriesgo IN NUMBER,
                                      mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   -- Bug 0015669 - JRH - 30/09/2010 - Alta prestaciones

   /***********************************************************************
     f_set_obj_sinprestaren
      Crea un objeto prestaciÃ³n con los datos.
      param in  pnsinies  : nÃºmero de siniestro
      param in  pntramit  : nÃºmero de tramitaciÃ³n
      param in  psperson  : nÃºmero identificativo del destinatario
      param in  pctipdes  : nÃºmero tipo destinatario
      param out  vprestaren :  ob_iax_sin_PRESTAREN
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_set_obj_sinprestaren(pnsinies IN VARCHAR2,
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
                                   pnmes1   IN NUMBER,
                                   pnmes2   IN NUMBER,
                                   pnmes3   IN NUMBER,
                                   pnmes4   IN NUMBER,
                                   pnmes5   IN NUMBER,
                                   pnmes6   IN NUMBER,
                                   pnmes7   IN NUMBER,
                                   pnmes8   IN NUMBER,
                                   pnmes9   IN NUMBER,
                                   pnmes10  IN NUMBER,
                                   pnmes11  IN NUMBER,
                                   pnmes12  IN NUMBER,
                                   pnpresta IN NUMBER,
                                   mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
     f_del_prestaren
      Borra una prestaciÃ³n
      param in  pnsinies  : nÃºmero de siniestro
      param in  pntramit  : nÃºmero de tramitaciÃ³n
      param in  psperson  : nÃºmero identificativo del destinatario
      param in  pctipdes  : nÃºmero tipo destinatario
      param in  psseguro :  Seguro
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_del_prestaren(pnsinies IN VARCHAR2,
                            pntramit IN NUMBER,
                            psperson IN NUMBER,
                            pctipdes IN NUMBER,
                            pnpresta IN NUMBER,
                            --psseguro IN NUMBER,
                            mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
     f_get_obj_sinprestaren
      Crea un objeto prestaciÃ³n con los datos.
      param in  pnsinies  : nÃºmero de siniestro
      param in  pntramit  : nÃºmero de tramitaciÃ³n
      param in  psperson  : nÃºmero identificativo del destinatario
      param in  pctipdes  : nÃºmero tipo destinatario
      param out  vprestaren :  ob_iax_sin_PRESTAREN
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_obj_sinprestaren(pnsinies IN VARCHAR2,
                                   pntramit IN NUMBER,
                                   psperson IN NUMBER,
                                   pctipdes IN NUMBER,
                                   psseguro IN NUMBER,
                                   pnpresta IN NUMBER,
                                   mensajes OUT t_iax_mensajes)
      RETURN ob_iax_sin_prestaren;

   -- Fi Bug 0015669 - JRH - 30/09/2010
   FUNCTION f_get_productos_pagos(pcempres   IN NUMBER,
                                  pfiltro    IN NUMBER,
                                  pproductos OUT t_iax_info,
                                  mensajes   OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_marcar_producto(psproduc IN NUMBER,
                              pmarcado IN NUMBER,
                              mensajes OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_get_productos_pagos_ob(pproductos OUT t_iax_info,
                                     mensajes   OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION funciÃ³n que hace los pagos de rentas
      Nos devuelve los productos de RENTAS o BAJA
      param in p_data    : Fecha
      param in pproductos   : Objeto que contiene los productos a hacer los pagos
      param out pncobro   : Numero de cobros
      return           : cÃ³digo de error

       ---- Bug 15044 - 08/11/2010 - XPL
   *************************************************************************/
   FUNCTION f_pago_renta_aut(p_data   IN DATE,
                             pncobros OUT NUMBER,
                             psproces OUT NUMBER, -- Bug 16580 - 15/11/2010 - AMC
                             mensajes OUT t_iax_mensajes) RETURN NUMBER;

   -- BUG16506:DRA:14/12/2010:Inici
   /*************************************************************************
      FUNCTION que devuelve el tramitador y la unidad de tramitaciÃ³n del usuario
      Si no tiene unidad de tramitaciÃ³n devolverÃ¡ la unidad por defecto, pero
      devolverÃ¡ un 1 para indicar que no es el tramitador del usuario
      param in p_cuser      : Fecha
      param out p_cunitra   : Objeto que contiene los productos a hacer los pagos
      param out p_ctramitad : Numero de cobros
      return                : 0 --> OK, 1 --> No es el del usuario, NULL --> Error
   *************************************************************************/
   FUNCTION f_get_tramitador_defecto(p_cuser     IN VARCHAR2,
                                     p_sseguro   IN NUMBER,
                                     p_ccausin   IN NUMBER,
                                     p_cmotsin   IN NUMBER,
                                     p_nsinies   IN VARCHAR2, -- 22108:ASN:18/05/2012
                                     p_ntramte   IN NUMBER, -- 22108:ASN:18/05/2012
                                     p_ntramit   IN NUMBER,
                                     p_cunitra   OUT VARCHAR2,
                                     p_ctramitad OUT VARCHAR2,
                                     mensajes    OUT t_iax_mensajes)
      RETURN NUMBER;

   -- BUG16506:DRA:14/12/2010:Fi

   --bug.: 15738 - ICV - 21/12/2010
   /*************************************************************************
      FunciÃ³n que ejecuta el map 405 (Carta de pago)
      param in  psidepag : cÃ³digo de pago de siniestros
      param out  pnomfichero : Nombre fichero
   *************************************************************************/
   FUNCTION f_imprimir_pago(psidepag    IN NUMBER,
                            pcmapead    IN VARCHAR2,
                            pnomfichero OUT VARCHAR2,
                            mensajes    OUT t_iax_mensajes) RETURN NUMBER;

   --Fin bug.: 15738
   -- Ini bug 18554 - 09/06/2011 - SRA
   /*************************************************************************
      FunciÃ³n que llama a pac_md_siniestros.f_get_hissin_siniestros para recuperar un cursor con datos del
      histÃ³rico de siniestros
      param in pnsinies : nÃºmero de siniestro
      param out mensajes: objeto mensajes
      return            : cursor con datos del histÃ³rico de siniestros
   *************************************************************************/
   FUNCTION f_get_hissin_siniestros(pnsinies IN sin_tramita_movimiento.nsinies%TYPE,
                                    mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   -- Fin bug 18554 - 09/06/2011 - SRA
   -- Ini bug 016364 - 27/06/2011 - XPL
   /*************************************************************************
         FunciÃ³n actualiza el movimiento de siniestro a pre-siniestro
   *************************************************************************/
   FUNCTION f_crear_presiniestro(mensajes OUT t_iax_mensajes) RETURN NUMBER;

   -- Fi bug 016364 - 27/06/2011 - XPL

   /*************************************************************************
    Borrar el objeto
   pnsinies        VARCHAR2(14),   --NÃºmero Siniestro
   psrefext        NUMBER(3),   --NÃºmero referencia
   pctipref        NUMBER(2),   --CÃ³digo Tipo referencia
   ptrefext        VARCHAR2(100),--Des tipo referencia
   pfrefini        DATE,   --Fecha Inicio
   pfreffin        DATE,   --Fecha Fin

   *************************************************************************/
   FUNCTION f_delete_sinreferencias(psrefext IN NUMBER,
                                    mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_get_objeto_sintramijuzgado
          Recupera una lÃ­nea de juzgado
            ob_iax_siniestros.tramitacion.juzgado
            nsinies        VARCHAR2(14),   --NÃºmero Siniestro
            ntramit        NUMBER(3),      --NÃºmero TramitaciÃ³n Siniestro
            nlinjuz        NUMBER(6),      --NÃºmero LÃ­nea
      Bug 19821 - 10/11/2011 - MDS
   *************************************************************************/
   FUNCTION f_get_objeto_sintramijuzgado(pnsinies IN VARCHAR2,
                                         pntramit IN NUMBER,
                                         pnlinjuz IN NUMBER,
                                         mensajes OUT t_iax_mensajes)
      RETURN ob_iax_sin_tramita_juzgado;

   /***********************************************************************
      FUNCTION f_set_objeto_sintramijuzgado
          Guarda en una variable global de la capa IAX los valores del objeto ob_iax_siniestros.tramitacion.juzgado
            nsinies        VARCHAR2(14),   --NÃºmero Siniestro
            ntramit        NUMBER(3),      --NÃºmero TramitaciÃ³n Siniestro
            nlinjuz        NUMBER(6),      --NÃºmero LÃ­nea
         ...
         ...
         ...

         return               : 0 -> Todo correcto
                                1 -> Se ha producido un error
      Bug 19821 - 10/11/2011 - MDS
   ***********************************************************************/
   FUNCTION f_set_objeto_sintramijuzgado(pnsinies     IN VARCHAR2,
                                         pntramit     IN NUMBER,
                                         pnlinjuz     IN NUMBER,
                                         pcorgjud     IN NUMBER,
                                         pnorgjud     IN VARCHAR2, --BUG 22048 --ETM --SE MODIFICA EL CAMPO DE NUMERICO A VARCHAR
                                         ptrefjud     IN VARCHAR2,
                                         pcsiglas     IN NUMBER,
                                         ptnomvia     IN VARCHAR2,
                                         pnnumvia     IN NUMBER,
                                         ptcomple     IN VARCHAR2,
                                         ptdirec      IN VARCHAR2,
                                         pcpais       IN NUMBER,
                                         pcprovin     IN NUMBER,
                                         pcpoblac     IN NUMBER,
                                         pcpostal     IN VARCHAR2,
                                         ptasunto     IN VARCHAR2,
                                         pnclasede    IN NUMBER,
                                         pntipopro    IN NUMBER,
                                         pnprocedi    IN VARCHAR2,
                                         pfnotiase    IN DATE,
                                         pfrecpdem    IN DATE,
                                         pfnoticia    IN DATE,
                                         pfcontase    IN DATE,
                                         pfcontcia    IN DATE,
                                         pfaudprev    IN DATE,
                                         pfjuicio     IN DATE,
                                         pcmonjuz     IN VARCHAR2,
                                         pcpleito     IN NUMBER,
                                         pipleito     IN NUMBER,
                                         piallana     IN NUMBER,
                                         pisentenc    IN NUMBER,
                                         pisentcap    IN NUMBER,
                                         pisentind    IN NUMBER,
                                         pisentcos    IN NUMBER,
                                         pisentint    IN NUMBER,
                                         pisentotr    IN NUMBER,
                                         pcargudef    IN NUMBER,
                                         pcresplei    IN NUMBER,
                                         pcapelant    IN NUMBER,
                                         pthipoase    IN VARCHAR2,
                                         pthipoter    IN VARCHAR2,
                                         pttipresp    IN VARCHAR2,
                                         pcopercob    IN NUMBER,
                                         ptreasmed    IN VARCHAR2,
                                         pcestproc    IN NUMBER,
                                         pcetaproc    IN NUMBER,
                                         ptconcjur    IN VARCHAR2,
                                         ptestrdef    IN VARCHAR2,
                                         ptrecomen    IN VARCHAR2,
                                         ptobserv     IN VARCHAR2,
                                         pfcancel     IN DATE,
                                         pnlinjuz_out OUT NUMBER,
                                         mensajes     OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_del_objeto_sintramijuzgado
          Borra una lÃ­nea de juzgado
            nsinies        VARCHAR2(14),   --NÃºmero Siniestro
            ntramit        NUMBER(3),      --NÃºmero TramitaciÃ³n Siniestro
            nlinjuz        NUMBER(6),      --NÃºmero LÃ­nea
          return               : 0 -> Todo correcto
                                1 -> Se ha producido un error
      Bug 19821 - 10/11/2011 - MDS
   ***********************************************************************/
   FUNCTION f_del_objeto_sintramijuzgado(pnsinies IN VARCHAR2,
                                         pntramit IN NUMBER,
                                         pnlinjuz IN NUMBER,
                                         mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_get_objeto_sintramidemand
          Recupera una lÃ­nea de demantante/demandado
            ob_iax_siniestros.tramitacion.demands
            nsinies        VARCHAR2(14),   --NÃºmero Siniestro
            ntramit        NUMBER(3),      --NÃºmero TramitaciÃ³n Siniestro
            nlindem        NUMBER(6),      --NÃºmero LÃ­nea
      Bug 19821 - 10/11/2011 - MDS
      Bug 20340/109094 - 15/03/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_objeto_sintramidemand(pnsinies  IN VARCHAR2,
                                        pntramit  IN NUMBER,
                                        pnlindem  IN NUMBER,
                                        pntipodem IN NUMBER,
                                        mensajes  OUT t_iax_mensajes)
      RETURN ob_iax_sin_tramita_demand;

   /***********************************************************************
      FUNCTION f_set_objeto_sintramidemand
          Guarda en una variable global de la capa IAX los valores del objeto ob_iax_siniestros.tramitacion.demands
            nsinies        VARCHAR2(14),   --NÃºmero Siniestro
            ntramit        NUMBER(3),      --NÃºmero TramitaciÃ³n Siniestro
            nlindem        NUMBER(6),      --NÃºmero LÃ­nea
         ...
         ...
         ...

         return               : 0 -> Todo correcto
                                1 -> Se ha producido un error
      Bug 19821 - 10/11/2011 - MDS
   ***********************************************************************/
   FUNCTION f_set_objeto_sintramidemand(pnsinies     IN VARCHAR2,
                                        pntramit     IN NUMBER,
                                        pnlindem     IN NUMBER,
                                        psperson     IN NUMBER,
                                        pntipodem    IN NUMBER,
                                        pttramita    IN VARCHAR2,
                                        psperson2    IN NUMBER,
                                        pnprocedi    IN VARCHAR2,
                                        ptcompani    IN VARCHAR2,
                                        pnlindem_out OUT NUMBER,
                                        mensajes     OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_del_objeto_sintramidemand
          Borra una lÃ­nea de demantante/demandado
            nsinies        VARCHAR2(14),   --NÃºmero Siniestro
            ntramit        NUMBER(3),      --NÃºmero TramitaciÃ³n Siniestro
            nlindem        NUMBER(6),      --NÃºmero LÃ­nea
          return               : 0 -> Todo correcto
                                 1 -> Se ha producido un error
      Bug 19821 - 10/11/2011 - MDS
      Bug 20340/109094 - 15/03/2012 - AMC
   ***********************************************************************/
   FUNCTION f_del_objeto_sintramidemand(pnsinies  IN VARCHAR2,
                                        pntramit  IN NUMBER,
                                        pnlindem  IN NUMBER,
                                        pntipodem IN NUMBER,
                                        mensajes  OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Bug:19882 - 01/12/2011 - AFM

      graba los datos de movimiento de pago / recobro
      param in  sidepag  : nÃºmero tipo pago
      param out  ob_iax_sin_trami_movpago :  ob_iax_sin_trami_movpago
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_set_movpago(psidepag    IN NUMBER,
                          pnmovpag    IN NUMBER,
                          pmediopago  IN NUMBER,
                          preferencia IN VARCHAR2,
                          pfcambio    IN DATE,
                          ptotal      IN NUMBER,
                          piica       IN NUMBER,
                          piiva       IN NUMBER,
                          pireteica   IN NUMBER,
                          pireteiva   IN NUMBER,
                          piretenc    IN NUMBER,
                          pmoneda     IN VARCHAR2,
                          pcestpag    IN NUMBER, -- Bug 24192 - MDS - 25/10/2012
                          pcestval    IN NUMBER, -- Bug 24192 - MDS - 25/10/2012
                          piotrosgas  IN NUMBER,
                          pibaseipoc  IN NUMBER,
                          ppipoconsumo IN NUMBER,
                          pndocpag    IN NUMBER, -- IAXIS-7731 19/12/2019
                          mensajes    OUT t_iax_mensajes)
      RETURN NUMBER; 

   -- Ini Bug 21172 - MDS - 02/03/2012
   /*************************************************************************
      FUNCTION f_get_reserva_multiple
         Devuelve las reservas efectuadas para un siniestro/trÃ¡mite

         param in  pnsinies : NÃºmero de siniestro
         param in  pntramit : NÃºmero de trÃ¡mite
         param out t_iax_mensajes

         return    t_iax_sin_trami_reserva_mult
   *************************************************************************/
   FUNCTION f_get_reserva_multiple(pnsinies IN sin_siniestro.nsinies%TYPE,
                                   pntramit IN sin_tramita_reserva.ntramit%TYPE,
                                   pctramit IN sin_tramitacion.ctramit%TYPE, -- 25812:ASN:23/01/2013
                                   mensajes OUT t_iax_mensajes)
      RETURN t_iax_sin_trami_reserva_mult;

   -- Fin Bug 21172 - MDS - 02/03/2012

   --INI BUG 21740 --ETM -27/03/2012
   /*************************************************************************
      FUNCTION f_update_presiniestros
        Actualiza el estado del presiniestro

         param in  pcmodo : modo de entrada
         param out t_iax_mensajes

   *************************************************************************/
   FUNCTION f_update_presiniestros(pcmodo   IN VARCHAR2,
                                   mensajes OUT t_iax_mensajes) RETURN NUMBER;

   --fin BUG 21740 --ETM -27/03/2012

   /***********************************************************************
      FUNCTION f_get_objeto_defraudador
         Recupera un objeto defraudador ob_iax_siniestros.defraudadores(i)
         param in pnsinies         : nÃºmero de siniestro
         param in pndefrau         : nÃºmero de defraudador
         param out pdefraudador    : ob_iax_defraudadores
         param out mensajes        : mensajes de error
         return                    : 0 OK
                                     1 Error
      Bug 21855 - 07/05/2012 - MDS
   *************************************************************************/
   FUNCTION f_get_objeto_defraudador(pnsinies IN sin_defraudadores.nsinies%TYPE,
                                     pndefrau IN sin_defraudadores.ndefrau%TYPE,
                                     mensajes OUT t_iax_mensajes)
      RETURN ob_iax_defraudadores;

   /***********************************************************************
      FUNCTION f_set_objeto_defraudador
         Guarda en una variable global de la capa IAX los valores del objeto
         param in pnsinies        : nÃºmero de siniestro
         param in pndefrau        : nÃºmero de defraudador
         ...
         ...
         ...
         param out pndefrau_out   : nÃºmero de defraudador
         param out mensajes       : mensajes de error
         return                   : 0 -> Todo correcto
                                    1 -> Se ha producido un error
      Bug 21855 - 07/05/2012 - MDS
   ***********************************************************************/
   FUNCTION f_set_objeto_defraudador(pnsinies     IN sin_defraudadores.nsinies%TYPE,
                                     pndefrau     IN sin_defraudadores.ndefrau%TYPE,
                                     psperson     IN sin_defraudadores.sperson%TYPE,
                                     pctiprol     IN sin_defraudadores.ctiprol%TYPE,
                                     pfiniefe     IN sin_defraudadores.finiefe%TYPE,
                                     pffinefe     IN sin_defraudadores.ffinefe%TYPE,
                                     pndefrau_out OUT sin_defraudadores.ndefrau%TYPE,
                                     mensajes     OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_del_objeto_defraudador
         Borra un defraudador
         param in pnsinies  : nÃºmero de siniestro
         param in pndefrau  : nÃºmero de defraudador
         param out mensajes : mensajes de error
         return             : 0 -> Todo correcto
                              1 -> Se ha producido un error
      Bug 21855 - 07/05/2012 - MDS
   *************************************************************************/
   FUNCTION f_del_objeto_defraudador(pnsinies IN sin_defraudadores.nsinies%TYPE,
                                     pndefrau IN sin_defraudadores.ndefrau%TYPE,
                                     mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_get_objeto_defraudadores
         Recupera la colecciÃ³n de defraudadores ob_iax_siniestros.defraudadores
         param in pnsinies         : nÃºmero de siniestro
         param out pdefraudador    : t_iax_defraudadores
         param out mensajes        : mensajes de error
         return                    : 0 OK
                                     1 Error
      Bug 21855 - 14/05/2012 - MDS
   *************************************************************************/
   FUNCTION f_get_objeto_defraudadores(pnsinies IN sin_defraudadores.nsinies%TYPE,
                                       mensajes OUT t_iax_mensajes)
      RETURN t_iax_defraudadores;

   /***********************************************************************
      FUNCTION f_get_personas_defraudadores
         Recupera la lista de personas (defraudadores) relacionadas con el siniestro
         param in psseguro          : nÃºmero de seguro
         param in pnsinies          : nÃºmero de siniestro
         param in pntipodefraudador : 1-Asegurado, 2-Tomador, 3-Mediador, 4-Persona relacionada
         param out mensajes         : mensajes de error
         return                     : sys_refcursor
      Bug 21855 - 09/05/2012 - MDS
   *************************************************************************/
   FUNCTION f_get_personas_defraudadores(psseguro          IN NUMBER,
                                         pnsinies          IN sin_defraudadores.nsinies%TYPE,
                                         pntipodefraudador IN NUMBER,
                                         mensajes          OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

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
   FUNCTION f_get_tramitador(pnsinies   IN NUMBER,
                             pntramte   IN NUMBER,
                             pntramit   IN NUMBER,
                             pcunitra   OUT VARCHAR2,
                             pctramitad OUT VARCHAR2,
                             mensajes   OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_valida_tramitador
         Compara el limite de autonomia del tramitador con la provision de la tramitacion
         param in pnsinies          : nÃºmero de siniestro
         param in pntramit          : tramitacion
         param in pctramtad         : tramitador
         param in pccausin          : causa
         param in pcmotsin          : motivo
         param out mensajes         : mensajes de error
         return                     : 0 - OK ; 1 - Error
   *************************************************************************/
   FUNCTION f_valida_tramitador(pnsinies   IN VARCHAR2,
                                pntramit   IN NUMBER,
                                pctramitad IN VARCHAR2,
                                pccausin   IN NUMBER,
                                pcmotsin   IN NUMBER,
                                mensajes   OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
    funciÃ³n graba en una variable global de la capa IAX los valores del objeto
    ob_iax_siniestros.tramites(i).movimientos
   pNSINIES        VARCHAR2(14),   --NÃºmero Siniestro
   pNTRAMTE        NUMBER(3),   --NÃºmero TramitaciÃ³n Siniestro
   pNMOVTTE        NUMBER(3),   --NÃºmero Movimiento TramitaciÃ³n
   pCUNITRA        VARCHAR2(4),   --CÃ³digo Unidad TramitaciÃ³n
   pCTRAMITAD      VARCHAR2(4),   --CÃ³digo Tramitador
   pCESTTTE        NUMBER(3),   --CÃ³digo Estado TramitaciÃ³n
   pFESTTRA        DATE,   --Fecha Estado TramitaciÃ³n
   -- Bug 0022108 - 19/06/2012 - JMF
   *************************************************************************/
   FUNCTION f_set_objeto_sinmovtramte(pnsinies   IN VARCHAR2,
                                      pntramte   IN NUMBER,
                                      pnmovtte   IN NUMBER,
                                      pcunitra   IN VARCHAR2,
                                      pctramitad IN VARCHAR2,
                                      pcesttte   IN NUMBER,
                                      pfesttra   IN DATE,
                                      pccauest   IN NUMBER,
                                      mensajes   OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_post_siniestro
         Acciones automaticas para ejecutar al dar de alta un siniestro
         param in pnsinies  : nÃºmero del siniestro
         return             : codigo error
   *************************************************************************/
   FUNCTION f_post_siniestro(pnsinies sin_siniestro.nsinies%TYPE,
                             mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
      Recupera la colecciÃ³n de documentos de una tramitacion de siniestros
      param in  pnsinies  : nÃºmero de siniestro
      param in  pntramit  : nÃºmero de tramitaciÃ³n o todos si esta vacio
      param out t_iax_sin_trami_documento :  t_iax_sin_trami_documento
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error
   -- Bug 0022153 - 19/07/2012 - JMF
   ***********************************************************************/
   FUNCTION f_get_sintradoc(pnsinies IN VARCHAR2,
                            pntramit IN NUMBER,
                            t_docume OUT t_iax_sin_trami_documento,
                            mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
      Sustituye a f_grabar_siniestro para su uso al inicio del proceso
      (cuando el siniestro esta incompleto) sin mensajes ni asignacion de tramitador
      param out mensajes  : mensajes de error
      return              : 1 -> Todo correcto
                            0 -> Se ha producido un error
   ***********************************************************************/
   FUNCTION f_grabar_sin_primera_vez(pnsinies OUT VARCHAR2,
                                     mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Ini Bug 23805 - MDS - 03/10/2012

   /*************************************************************************
    FunciÃ³n que indica si alguna de las garantÃ­as contratadas y
    seleccionadas segÃºn pccausin, pcmotsin, pfsinies tiene asistencia.

      phay_asistencia OUT --> 0 : No , 1 : Si

      RETURN  0 : OK
              1 : Error

   *************************************************************************/
   FUNCTION f_hay_asistencia(psseguro        IN NUMBER,
                             pnriesgo        IN NUMBER,
                             pccausin        IN NUMBER,
                             pcmotsin        IN NUMBER,
                             pfsinies        IN DATE,
                             phay_asistencia OUT NUMBER,
                             mensajes        OUT t_iax_mensajes) RETURN NUMBER;

   -- Fin Bug 23805 - MDS - 03/10/2012
   /*************************************************************************
      Devuelve los siniestros que cumplan con el criterio de selecciÃ³n
      param in pnpoliza     : nÃºmero de pÃ³liza
      param in pncert       : nÃºmero de cerificado por defecto 0
      param in pnsinies     : nÃºmero del siniestro
      param in cestsin      : cÃ³digo situaciÃ³n del siniestro
      param in pnnumide     : nÃºmero identidad persona
      param in psnip        : nÃºmero identificador externo
      param in pbuscar      : nombre+apellidos a buscar de la persona
      param in ptipopersona : tipo de persona
                               1 tomador
                               2 asegurado
      param out mensajes    : mensajes de error
      return                : ref cursor

      Bug 23740/123618 - 08/10/2012 - AMC
   *************************************************************************/
   FUNCTION f_consultasini2(pcramo    IN NUMBER,
                            psproduc  IN NUMBER,
                            pnpoliza  IN NUMBER,
                            pncertif  IN NUMBER DEFAULT -1,
                            pnsinies  IN VARCHAR2,
                            pcestsin  IN NUMBER,
                            pnnumide  IN VARCHAR2,
                            psnip     IN VARCHAR2,
                            pbuscar   IN VARCHAR2,
                            ptipopers IN NUMBER,
                            pnsubest  IN NUMBER,
                            pnsincia  IN VARCHAR2,
                            pfalta    IN DATE,
                            pccompani IN NUMBER,
                            pnpresin  IN VARCHAR2,
                            pcsiglas  IN NUMBER,
                            ptnomvia  IN VARCHAR2,
                            pnnumvia  IN NUMBER,
                            ptcomple  IN VARCHAR2,
                            pcpostal  IN VARCHAR2,
                            pcpoblac  IN NUMBER,
                            pcprovin  IN NUMBER,
                            pfgisx    IN FLOAT,
                            pfgisy    IN FLOAT,
                            pfgisz    IN FLOAT,
                            ptdescri  IN VARCHAR2,
                            pctipmat  IN NUMBER,
                            pcmatric  IN VARCHAR2,
                            ptiporisc IN NUMBER,
                            pcpolcia  IN VARCHAR2,
                            pcactivi  IN NUMBER,
                            pfiltro   IN NUMBER,
                            pcagente  IN NUMBER,
                            ptrefext  IN VARCHAR2, --  16/06/2015  CJMR  Bug: 0036232/207513
                            pctipref  IN NUMBER, --  16/06/2015  CJMR  Bug: 0036232/207513
                            ptdescrie IN VARCHAR2, -- BUG CONF_309 - 10/09/2016 - JAEG
          pncontrato IN VARCHAR2 DEFAULT NULL, -- AP CONF-219
                            mensajes  OUT t_iax_mensajes) RETURN SYS_REFCURSOR;

   /***********************************************************************
      FUNCTION f_mensajes_axissin049
          Pregunta si realmente quieren guardar en una variable global de la capa IAX los valores del objeto ob_iax_siniestros.tramitacion.juzgado
            nsinies        VARCHAR2(14),   --NÃºmero Siniestro
            ntramit        NUMBER(3),      --NÃºmero TramitaciÃ³n Siniestro
            nlinjuz        NUMBER(6),      --NÃºmero LÃ­nea
         ...
         ...
         ...

         return               : 0 -> Todo correcto
                                1 -> Se ha producido un error
      Bug 25204 - 19/12/2012 - NSS
   ***********************************************************************/
   FUNCTION f_mensajes_axissin049(pnsinies  IN VARCHAR2,
                                  pntramit  IN NUMBER,
                                  pnlinjuz  IN NUMBER,
                                  pcorgjud  IN NUMBER,
                                  pnorgjud  IN VARCHAR2,
                                  ptrefjud  IN VARCHAR2,
                                  pcsiglas  IN NUMBER,
                                  ptnomvia  IN VARCHAR2,
                                  pnnumvia  IN NUMBER,
                                  ptcomple  IN VARCHAR2,
                                  ptdirec   IN VARCHAR2,
                                  pcpais    IN NUMBER,
                                  pcprovin  IN NUMBER,
                                  pcpoblac  IN NUMBER,
                                  pcpostal  IN VARCHAR2,
                                  ptasunto  IN VARCHAR2,
                                  pnclasede IN NUMBER,
                                  pntipopro IN NUMBER,
                                  pnprocedi IN VARCHAR2,
                                  pfnotiase IN DATE,
                                  pfrecpdem IN DATE,
                                  pfnoticia IN DATE,
                                  pfcontase IN DATE,
                                  pfcontcia IN DATE,
                                  pfaudprev IN DATE,
                                  pfjuicio  IN DATE,
                                  pcmonjuz  IN VARCHAR2,
                                  pcpleito  IN NUMBER,
                                  pipleito  IN NUMBER,
                                  piallana  IN NUMBER,
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
                                  ptobserv  IN VARCHAR2,
                                  pfcancel  IN DATE,
                                  otexto    OUT VARCHAR2,
                                  mensajes  OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_get_agente_npol(psseguro IN NUMBER,
                              pcagente OUT NUMBER,
                              mensajes OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_get_preg_siniestro(psproduc IN NUMBER,
                                 pcactivi IN NUMBER,
                                 pcgarant IN VARCHAR2,
                                 pccausin IN NUMBER, --27354:NSS:18/06/2013
                                 pcmotsin IN NUMBER, --27354:NSS:18/06/2013
                                 mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   FUNCTION f_get_resp_siniestro(pcpregun IN VARCHAR2,
                                 mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   FUNCTION f_set_obj_preguntas(pnsinies   IN NUMBER,
                                psproduc   IN NUMBER,
                                pcactivi   IN NUMBER,
                                ppreguntas IN VARCHAR2,
                                mensajes   OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_set_obj_garantias(pnsinies  IN VARCHAR2,
                                pcgarant  IN NUMBER,
                                picapital IN NUMBER,
                                ptgarant  IN VARCHAR2,
                                mensajes  OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_get_lstlocaliza(pnsinies IN sin_siniestro.nsinies%TYPE,
                              pntramit IN NUMBER,
                              mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   FUNCTION f_get_localiza(pnsinies IN sin_siniestro.nsinies%TYPE,
                           pntramit IN NUMBER,
                           pnlocali IN NUMBER,
                           mensajes OUT t_iax_mensajes) RETURN SYS_REFCURSOR;

   FUNCTION f_get_vehiculo_asegurado(psseguro IN sin_siniestro.sseguro%TYPE,
                                     pnriesgo IN sin_siniestro.sseguro%TYPE,
                                     mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   --Ini Bug 24708:NSS:10/10/2013
   FUNCTION f_get_lstoficinas(pcbanco  IN NUMBER,
                              pcofici  IN NUMBER,
                              ptofici  IN VARCHAR2,
                              mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   FUNCTION f_get_beneficiario_designado(pnsinies IN VARCHAR2,
                                         psseguro IN NUMBER,
                                         mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   --Fin Bug 24708:NSS:10/10/2013

   --Ini Bug 28506:NSS:16/10/2013
   FUNCTION f_get_garantias_dependientes(pgarantias IN VARCHAR2,
                                         mensajes   OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   --Fin Bug 28506:NSS:16/10/2013

   --Ini Bug 28506:NSS:28/10/2013
   FUNCTION f_get_inf_reaseguro(pnsinies IN VARCHAR2,
                                mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   --Fin Bug 28506:NSS:28/10/2013

   --Ini Bug 29177/160128:NSS:13/01/2014
   FUNCTION f_ins_pago_contrato(psidepag  IN NUMBER,
                                pcdp      IN VARCHAR2,
                                ppospres  IN VARCHAR2,
                                pcrp      IN VARCHAR2,
                                pposcrp   IN VARCHAR2,
                                pcontrato IN VARCHAR2,
                                pcgestor  IN VARCHAR2,
                                mensajes  OUT t_iax_mensajes) RETURN NUMBER;

   --Fin Bug 29177/160128:NSS:13/01/2014

   -- BUG 28830:NSS:06/11/2013 - CompensaciÃ³n de siniestros contra cartera.
   FUNCTION f_valida_compensacion(psseguro IN seguros.sseguro%TYPE,
                                  pnriesgo IN sin_siniestro.nriesgo%TYPE,
                                  pnsinies IN sin_siniestro.nsinies%TYPE,
                                  psidepag IN sin_tramita_pago.sidepag%TYPE,
                                  ptlitera OUT axis_literales.tlitera%TYPE,
                                  mensajes OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_compensa_cartera(psseguro IN seguros.sseguro%TYPE,
                               pnriesgo IN sin_siniestro.nriesgo%TYPE,
                               pnsinies IN sin_siniestro.nsinies%TYPE,
                               psidepag IN sin_tramita_pago.sidepag%TYPE,
                               mensajes OUT t_iax_mensajes) RETURN NUMBER;

   -- FIN BUG 28830:NSS:06/11/2013 - CompensaciÃ³n de siniestros contra cartera.

   -- BUG 30342:DEV:12/03/2014 - Modulo de Autorizaciones para pagos de Siniestros
   FUNCTION f_get_lst_pagos(pcramo   IN NUMBER,
                            psproduc IN NUMBER,
                            pnsinies IN VARCHAR2,
                            psidepag IN NUMBER,
                            pcconcep IN NUMBER,
                            pimpmin  IN NUMBER,
                            pcestval IN NUMBER,
                            pcespag  IN NUMBER,
                            psperson IN NUMBER,
                            mensajes OUT t_iax_mensajes) RETURN SYS_REFCURSOR;

   FUNCTION f_tratar_pagos(ptblpago  IN VARCHAR2,
                           pcestval2 IN NUMBER,
                           pcestpag2 IN NUMBER,
                           pcestpag1 IN NUMBER,
                           mensajes  OUT t_iax_mensajes) RETURN NUMBER;

   --fin BUG 30342:DEV:12/03/2014 - Modulo de Autorizaciones para pagos de Siniestros

   -- BUG 30935:NSS:10/04/2014 - POSPG500-Control de alta de siniestros duplicados segÃºn garantÃ­a
   FUNCTION f_inicializa_garantias(mensajes OUT t_iax_mensajes) RETURN NUMBER;

   -- FIN BUG 30935:NSS:10/04/2014 - POSPG500-Control de alta de siniestros duplicados segÃºn garantÃ­a

   -- BUG xxx:NSS:15/04/2014 -
   FUNCTION f_get_tomadores(psseguro IN NUMBER,
                            mensajes OUT t_iax_mensajes)
      RETURN t_iax_tomadores;

   -- FIN BUG xxx:NSS:15/04/2014
   -- BUG 0033345: 17/11/2014.

   /***********************************************************************
     FUNCTION F_SET_CAMPO_PLANTILLA
      Cambia el estado de un siniestro
      param in  pnsinies   : NÃºmero Siniestro
      param in pcestsin    : codi estat sinistre
      param in pccauest    : codi causa estat sinistre
      param in pcunitra    : codi unitat tramitaciÃ³
      param in pctramitad  : codi tramitador
      param in pcsubtra    : codi subestat tramitaciÃ³
      param  out  mensajes : Mensajes de error
      return               : 0 -> Tot correcte
                             1 -> S'ha produit un error
      31/07/2009   XVM                 Sinistres.  Bug: 8820
   ***********************************************************************/
   FUNCTION f_set_campo_plantilla(pnsinies IN VARCHAR2,
                                  pttipo   IN VARCHAR2,
                                  psproduc IN NUMBER,
                                  pndocume IN VARCHAR2,
                                  pccampo  IN VARCHAR2,
                                  ptcampo  IN VARCHAR2,
                                  mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /***********************************************************************
     f_comprobar_necesidad_impresion
      Comprueba documentos a imprimir
      param in  sproduc   : producto.
      param  out  mensajes : Mensajes de error
      return               : Numero de documentos.
      26/11/2014  FRC
   ***********************************************************************/
   FUNCTION f_comprobar_impresion(psproduc IN NUMBER,
                                  pttipo   IN cfg_plantillas_tipos.ttipo%TYPE)
      RETURN NUMBER;

   /***********************************************************************
     FUNCTION F_GET_DOCUMENTACION_PENDIENTE:
      Obtiene una lista con los nombres de los documentos pendientes de recibir (AXISSIN061)
      param in pnsinies   : NÃºmero Siniestro
      param in pntramit    : codi subestat tramitaciÃ³
      param  out  ptlisdoc : Lista de documentos
      param  out  mensajes : Mensajes de error
      return               : 0 -> Tot correcte
                             1 -> S'ha produit un error
   ***********************************************************************/
   FUNCTION f_get_documentacion_pendiente(pnsinies IN sin_siniestro.nsinies%TYPE,
                                          pntramit IN sin_tramitacion.ntramit%TYPE,
                                          ptlisdoc OUT VARCHAR2,
                                          mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION ff_hay_lista_innominados(psproduc IN productos.sproduc%TYPE,
                                     psseguro IN seguros.sseguro%TYPE,
                                     pnriesgo IN riesgos.nriesgo%TYPE,
                                     pnasegur OUT NUMBER,
                                     mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_sin_trami_doc(pnsinies IN sin_siniestro.nsinies%TYPE,
                                pntramit IN sin_tramitacion.ntramit%TYPE,
                                pndocume IN NUMBER,
                                mensajes OUT t_iax_mensajes)
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
   FUNCTION f_pagos_avion(pnsinies in varchar2, -- NÃšMERO DE SINIESTRO
                          pntramit in number, -- NÃšMERO DE TRAMITACIÃ“N
                          pnmovres in number, -- NÃšMERO MOVIMIENTO RESERVA
                          pctipres in number, -- CÃ“DIGO DE TIPO DE RESERVA
                          pctipgas in number, -- CÃ“DIGO DE TIPO DE GASTO
                          pcgarant in number, -- CÃ“DIGO DE GARANTÃA
                          pcmonres in varchar2, -- MONEDA DE LA RESERVA
                          pnnumide_agencia in varchar2, -- NÃšMERO DE IDENTIFICACIÃ“N DE LA AGENCIA DE VIAJES
                          psperson_agencia in number,
                          pnnumide_aero in varchar2, -- NÃšMERO DE IDENTIFICACIÃ“N DE LA COMPAÃ‘ÃA AÃ‰REA
                          psperson_aero  in number,
                          pnfacref in varchar2,-- NÃšMERO DE FACTURA
                          pffacref in date, -- FECHA DE FACTURA
                          ptobserva in varchar2, -- OBSERVACIONES
                          pisinret_aero in number, -- IMPORTE BRUTO PASAJE AÃ‰REO
                          ppiva_aero in number, -- PORCENTAJE DE IVA PASAJE AÃ‰REO
                          piiva_aero in number, -- IMPORTE IVA PASAJE AÃ‰REO
                          piotrosgas_aero in number, -- IMPORTE DE OTROS GASTOS / TASA AEROPORTUARIA DEL PASAJE AÃ‰REO
                          pineto_aero in number, -- IMPORTE NETO PASAJE AÃ‰REO
                          pisinret_agencia in number, -- IMPORTE BRUTO AGENCIA
                          ppiva_agencia in number, -- PORCENTAJE IVA AGENCIA
                          piiva_agencia in number, -- IMPORTE IVA AGENCIA
                          pineto_agencia in number,-- IMPORTE NETO AGENCIA
                          --IAXIS 7655 AABC CONCEPTO DE PAGO
                          pcconpag  IN NUMBER,
                          --IAXIS 7655 AABC CONCEPTO DE PAGO
                          mensajes out t_iax_mensajes )
          RETURN NUMBER;


  /***********************************************************************
       FUNCTION f_get_sin_tramita_apoyos:
            obtener los datos de una solicitud de apoyo tecnico

     ***********************************************************************/
  FUNCTION f_get_sin_tramita_apoyo (psintapoy IN NUMBER,
                                    pnsinies  IN VARCHAR2,
                                    pntramit  IN NUMBER,
                                    mensajes  OUT t_iax_mensajes)
     RETURN SYS_REFCURSOR;


  /***********************************************************************
     FUNCTION f_set_sin_tramita_apoyos:
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
     FUNCTION f_del_sin_tramita_apoyos:
          eliminar una solicitud de apoyo tecnico

   ***********************************************************************/
  FUNCTION f_del_sin_tramita_apoyo (psintapoy IN NUMBER,
                                    pnsinies  IN VARCHAR2,
                                    pntramit  IN NUMBER,
                                    mensajes  OUT t_iax_mensajes)
     RETURN NUMBER;
     
   /***********************************************************************
       BUG:3609
      FUNCTION F_GET_CLASIFICASINIESTRO:
             ClasificaciÃ³n de siniestros
            autor: A.B - 05/06/2019
     ***********************************************************************/
  FUNCTION f_get_clasificasiniestro (pnsinies IN VARCHAR2, pnpagos  IN NUMBER,  pntramita  IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;
      
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
    Traspasa los valores de los parámetros a los atributos del objeto f_get_tramita_estsini.
    param in pnsinies                : número de siniestro
    param in pntramte                : número de trámite
    return                           : cursor
   ************************************************************************/
   FUNCTION f_get_tramita_estsini(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      mensajes OUT t_iax_mensajes)
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
                          pnnumide in varchar2, -- NUMERO DE IDENTIFICACION
                          psperson in number,
                          pnfacref in varchar2, -- NUMERO DE FACTURA
                          pffacref in date, -- FECHA DE FACTURA
                          ptobserva in varchar2, -- OBSERVACIONES
                          pisinret in number, -- IMPORTE BRUTO PASAJE AEREO
                          ppiva in number, -- PORCENTAJE DE IVA PASAJE AEREO
                          piiva in number, -- IMPORTE IVA PASAJE AEREO
                          piotrosgas in number, -- IMPORTE DE OTROS GASTOS
                          pineto in number, -- IMPORTE NETO PASAJE AEREO 
                          pcconpag in number, -- CONCEPTO DE PAGO
                          psproces in number, -- proceso IAXIS 4184 AABC 
                          mensajes out t_iax_mensajes)
        RETURN NUMBER;  
--Fin IAXIS 4184 07/06/2019 MOS Incluir Cambios Cargue Masivo para pagos

/*************************************************************************
    f_get_max_tramita_estsini bug 3603
    obtener el maximo movimiento de la tabla sin_tramita_estsiniestro de acuerdo a un siniestro
    param in pnsinies                : no de siniestro
    param in pntramte                : no de tramite
    return                           : cursor
   ************************************************************************/
   FUNCTION f_get_max_tramita_estsini( pnsinies IN VARCHAR2,
                                   mensajes OUT t_iax_mensajes)
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
      mensajes OUT t_iax_mensajes)
     RETURN NUMBER;
END pac_iax_siniestros;
/