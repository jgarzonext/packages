create or replace PACKAGE pac_siniestros IS
    /******************************************************************************
    NOMBRE:     PAC_SINIESTROS
    PROPÃ“SITO:  Cuerpo del paquete de las funciones para
       los mÃ³dulos del area de SINIESTROS

    REVISIONES:
    Ver        Fecha        Autor             DescripciÃ³n
    ---------  ----------  ---------------  ------------------------------------
    1.0        17/02/2009   XPL / XVM         1. CreaciÃ³n del package.
    2.0        28/09/2009   DCT               2. 10393 Crear parametrizaciÃ³n de documentaciÃ³n a solicitar por producto/causa/motivo
    3.0        23/11/2009   AMC               3. Bug 11848 - Se aÃ±ade el parametro psidepagtemp a f_ins_pago.
    4.0        15/01/2010   AMC               4. Bug 11945 - AGA - Crear columna PrevisiÃ³n Recobro para siniestros
    5.0        18/01/2010   AMC               5  Bug 12753 - CEM - CreaciÃ³n automÃ¡tica de destinatario
    6.0        20/01/2010   AMC               6. Bug 11849 - CEM - Crear botÃ³n generaciÃ³n pago automÃ¡tico en siniestros
    7.0        01/02/2010   AMC               7. Bug 12207 - AGA - IntroducciÃ³n de reservas en productos de Baja (Salud)
    8.0        26/02/2010   AMC               8. Bug 12668 - AGA - NormalizaciÃ³n riesgo tipo direcciÃ³n
    9.0        31/05/2010   XPL               9. bug : 14607, AGA004 - Conceptos de pago a nivel de detalle del pago de un siniestro
   10.0        03/06/2010   AMC               10. Bug 14766 Se aÃ±aden nuevas funciones
   11.0        07/06/2010   FAL               11. bug 14347: AGA014 - Sinistres productes VIDA RISC (GENERAL i PREVISIO)
   12.0        15/06/2010   JRH               12. 0014185 ENSA101 - Proceso de carga del fichero (beneficio definido)
   13.0        23/06/2010   AMC               13. Bug 15153 Se aÃ±aden nuevas funciones
   15.0        10/09/2010   SRA               15. Bug 15965 - CRT - Se crea nueva funciÃ³n PAC_IAX_SINIESTROS.F_CONSULTA_LSTSINI_RIESGO
   16.0        10/08/2010   JRH               27. BUG 15669 : Campos nuevos
   17.0        07/10/2010   JMF               17. 0016176: AGA601 - control de reserva mÃ¡xima por causa, motivo y garantia
   18.0        15/10/2010   JMF               18. 0016285 GRC - Pagos de siniestros de bajas
   19.0        08/11/2010   XPL               31. 15044: AGA202 - Crear pantalla para pagos de rentas
   20.0        13/08/2010   PFA               20. 14587: CRT001 - AÃ±adir campo siniestro compaÃ±ia
   21.0        17/08/2010   PFA               21. 15006: MDP003 - Incluir nuevos campos en bÃºsqueda siniestros
   22.0        14/12/2010   DRA               22. 0016506: CRE - Pantallas de siniestros nuevo mÃ³dulo
   23.0        14/12/2010   SRA               23. 0016924: GRC003 - Siniestros: estado y tipo de pago por defecto
   24.0        16/03/2011   JMF               24. 0017970: ENSA101- Campos pantallas de siniestros y mejoras
   25.0        04/05/2011   APD               25. 0018286: ENSA101 - Informar el siniestro en pagosrenta. Estados de las prestaciones.
   26.0        02/05/2011   JMC               26. 0018379: LCOL701 - Desarrollo TrÃ¡mites Siniestros. ModificaciÃ³n funciones de tramitaciones.
   27.0        17/06/2011   APD               27. 0018670: ENSA102- Permitir escoger las formas posibles de prestaciÃ³n a partir del tipo de siniestro
   28.0        06/06/2011   SRA               28. 0018554: LCOL701 - Desarrollo de ModificaciÃ³n de datos cabecera siniestro y ver histÃ³rico (BBDD).
   29.0        29/09/2011   MDS               29. 0018934: LCOL_S001 - SIN - Ultimo pago
   30.0        13/10/2011   JMC               30. 0019601: LCOL_S001-SIN - Subestado del pago
   31.0        07/11/2011   MDS               31. 0019981: LCOL_S001-SIN - ReteIVA y ReteICA en pagos
   32.0        21/10/2011   JMP               32. 0019832 LCOL_S001-SIN - Carpeta de siniestro
   33.0        10/11/2011   MDS               33. 0019821: LCOL_S001-SIN - TramitaciÃ³n judicial
   34.0        14/12/2011   ASN               34. 0019416: LCOL_S001-Siniestros y exoneraciÃ³n de pago de primas
   35.0        16/01/2012   ETM               35. 0019896: LCOL_S001-SIN - Declarante del siniestro
   36.0        25/01/2012   JMP               36. 0018423/104212: LCOL705 - Multimoneda
   37.0        03/05/2012   ETM               37.0022048: LCOL_S001-SIN - NÂº de juzgado cambiar tipo
   38.0        07/05/2012   MDS               38.0021855: MDP_S001-SIN - Detalle fraude
   39.0        22/05/2012   MDS               39. 0021817: MDP_S001-SIN - Agente en el alta de siniestros
   40.0        28/062012    ASN               40. 0022670: SIN - Mensajes en alta de siniestros (y nuevo parametro)
   41.0        09/07/2012   JMF               0022490: LCOL_S001-SIN - Poder indicar que se generen los pagos como el Ãºltimo (Id=4604)
   42.0        18/07/2012   ASN               0022603: MDP_S001-Reserva global
   43.0        31/07/2012   ASN               0023101: LCOL_S001-SIN - Apuntes de agenda automÃ¡ticos
   44.0        03/10/2012   MDS               0023805: MDP_S001-SIN - Visualizar/Ocultar casilla de asistencia en la pantalla de alta de siniestros
   45.0        15/10/2012   ASN               0023764: LCOL_S001-LCOL - SIN - PrÃ©stamos y siniestros
   46.0        24/10/2012   JMF               0023536 LCOL_S001-SIN - TramitaciÃ³n Otros
   47.0        24/10/2012   JMF               0023540 LCOL_S001-SIN - TramitaciÃ³n lesionados
   48.0        05/11/2012   JMF               0023643: MDP_S001-SIN - Ocultar tramite global
   49.0        20/11/2012   JMF               0024774 MDP_S001-SIN - Preparacion Pruebas R2 (asn)
   50.0        24/01/2013   ASN               0025812: LCOL_S010-SIN - GarantÃ­as segÃºn tramitaciÃ³n
   51.0        15/03/2013   ASN               0026108: LCOL_S010-SIN - Tipo de gasto en reservas :
   52.0        15/05/2013   ASN               0026929: LCOL_S010-SIN - Ajustes gestiones de autos
   53.0        14/05/2013   ECP               0026676: LCOL_T001- QT 7040: Error cierre de provisiones por c?digo de transacci?n en movimiento de anulaciones errado
   54.0        18/07/2013   MDS               0024742: (POSDE600)-Desarrollo-GAPS Tecnico-Id 179 - AÃ±adir siniestralidad a listado cartera
   55.0        05/08/2013   AVT               0027847: 0027847: LCOL_A004-Qtracker: 0008669: SE GENERO CIERRE DE AUT PARA PROVISIONES, REASEGUROS, XLS, PRESTAMOS, Y REMUNERCION LA CANAL Y NOGE
   56.0        23/08/2013   LPP               0027860: AGM800-En siniestras al a?adir documentos, no se guardan las descripciones de los documentos.
   57.0        30/10/2013   ASN               0024708: (POSPG500)- Parametrizacion - Sinestros/0157275 actualizar preguntas
   58.0        08/01/2014   LPP               0028409: ENSA998-ENSA - ImplementaciÃ³n de historico de prestaciones
   59.0        26/02/2014   NSS               0028830/0166530: (POSND500)-N. Desarrollo: Siniestros: Compensaci?n cartera vs. Siniestros
   60.0        06/03/2014   NSS               0029224/0166661: (POSAN500)-Analisis-Siniestros-Nuevos Desarrollos
   61.0        27/02/2014   NSS               0024637/0147756: (POSAN500-AN-Sin) Analisis Desarrollo: Siniestros
   62.0        22/04/2014   NSS               0029989/165377: LCOL_S001-SIN - Rechazo de tramitaciÃ³n Ãºnica
   63.0        04/07/2014   JTT               0031294/178338: Revision pagos automaticos de baja diaria.
   64.0        14/07/2014   NSS               0031872/0178559: TRQ - SIN-ParametrizaciÃ³n Siniestros
   65.0        17/07/2014   JTT               0028830/179900: Revision del proceso de pago de compensaciones
   66.0        29/09/2014   JTT               0029801/0183298: Parche AXIS (LCOL_5231) Nuevo parametro en la funcion F_INS_RESERVA
   67.0        29/09/2014   JTT               0032428/188259: Cambio tipo PREGUNSINI.nsinies
   68.0        10/02/2015   JTT               0033798/0196746: Nuevas funcion F_getrow_reserva
   69.0        02/03/2015   JTT               0034622/0197860: Fecha de formalizaciÃ³n de siniestros
   70.0        20/04/2015   JBA               0035098/200436:  numero de cheque
   71.0        05/01/2016   JCP               0039475/222692: Modificar la select para recuperar tambiÃ©n el nuevo campo fdeteccion de sin_siniestro
   72.0        02/05/2017   JGONZALEZ         CONF-693: Se incluyen campos de audiencia en agenda de citaciones
   73.0        11/08/2017   JGONZALEZ         CONF-1005: Desarrollo de GAP 67 solicitud de apoyo tecnico
   74.0        05/10/2017   ABENAVIDES        CONF-1133:Cambio en la funcion f_ins_reservadet para la tener los movimientos detallados en la tabla sin_tramita_reservadet.
   75.0        12/04/2019   AABC              IAXIS 3663 AABC 12/04/2019 Adicion campo observacion
   76.0        19/12/2019   DFRP              IAXIS-7731: LISTENER Cambio de estado del siniestro y creación de Campos: Valor, Fecha, número de pago, que comunica SAP a IAXIS     
   ******************************************************************************/

   -- BUG 9020 - 10/03/2009 - XPL I XVM - Nou model de dades del Sinistre
  --Retorna el porcentatge de retencio a aplicar
--------------------------------------------------------------------
   FUNCTION f_ctipcoa(psseguro IN NUMBER, pctipcoa OUT NUMBER)
      RETURN NUMBER;

  -- Calcula la provisio a nivell de sinistre
---------------------------------------------------------------------------------
   FUNCTION f_insctactescia(psidepag IN NUMBER, psseguro IN NUMBER)
      RETURN NUMBER;

---------------------------------------------------------------------------------------------
   FUNCTION f_permite_alta_siniestro(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfsinies IN DATE,
      pfnotifi IN DATE,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      -- Ini Bug 26676 -- ECP -- 14/05/2013
      pskipfanulac NUMBER DEFAULT 0)
      -- Fin Bug 26676 -- ECP -- 14/05/2013)
   RETURN NUMBER;

-----------------------------------------------------------------------------------
   FUNCTION f_insctaseguro(
      psseguro IN NUMBER,
      pfcontab IN DATE,
      pffecmov IN DATE,
      pfvalmov IN DATE,
      cmovimi IN NUMBER,
      pimporte IN NUMBER,
      pnsinies IN sin_siniestro.nsinies%TYPE)
      RETURN NUMBER;

   FUNCTION f_insctaseguro_shw(
      psseguro IN NUMBER,
      pfcontab IN DATE,
      pffecmov IN DATE,
      pfvalmov IN DATE,
      cmovimi IN NUMBER,
      pimporte IN NUMBER,
      pnsinies IN sin_siniestro.nsinies%TYPE)
      RETURN NUMBER;

   FUNCTION ff_contador_siniestros(pcramo IN NUMBER, pmodali IN NUMBER, pccausin IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_dades_sini(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pidioma IN NUMBER,
      vsquery OUT VARCHAR2,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_get_localiza(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pnlocali IN NUMBER,
      pidioma IN NUMBER,
      vsquery OUT VARCHAR2,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_get_movsiniestro(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pnmovsin IN NUMBER,
      pidioma IN NUMBER,
      vsquery OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_agenda(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pnlinage IN NUMBER,
      pidioma IN NUMBER,
      vsquery OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_personarel(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pnpersrel IN NUMBER,
      vsquery OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_reserva(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pctipres IN NUMBER,
      pnmovres IN NUMBER,
      pcgarant IN NUMBER,
      pidioma IN NUMBER,
      vsquery OUT VARCHAR2)
      RETURN NUMBER;
      
FUNCTION f_get_amparo(
     pnsinies IN sin_siniestro.nsinies%TYPE,		     
       pntramit IN NUMBER,		     
       pcgarant IN NUMBER,		     
       vsquery OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_referencia(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      psrefext IN NUMBER,
      pidioma IN NUMBER,
      vsquery OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_tramitacion(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pidioma IN NUMBER,
      vsquery OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_movtramit(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pnmovtra IN NUMBER,
      pidioma IN NUMBER,
      vsquery OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_danyo(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pndano IN NUMBER,
      pidioma IN NUMBER,
      vsquery OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_detdanyo(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pndano IN NUMBER,
      pndetdano IN NUMBER,
      pidioma IN NUMBER,
      vsquery OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_citacion(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pncitacion IN NUMBER,
      pidioma IN NUMBER,
      vsquery OUT VARCHAR2,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

  FUNCTION f_get_destinatario(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pctipdes IN NUMBER,
      pidioma IN NUMBER,
      vsquery OUT VARCHAR2,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_get_movpago(
      psidepag IN NUMBER,
      pnmovpag IN NUMBER,
      pidioma IN NUMBER,
      vsquery OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_pagogar(
      psidepag IN NUMBER,
      pctipres IN NUMBER,
      pnmovres IN NUMBER,
      pnorden IN NUMBER,
      pidioma IN NUMBER,
      vsquery OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_pagrecob(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      psidepag IN NUMBER,
      pidioma IN NUMBER,
      vsquery OUT VARCHAR2,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_get_ultimareserva(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pidioma IN NUMBER,
      vsquery OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_pagosporsiniestro(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pctippag IN NUMBER,
      pidioma IN NUMBER,
      vsquery OUT VARCHAR2,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_get_detallespagos(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pctipres IN NUMBER,
      pctippag IN NUMBER,
      pcgarant IN NUMBER,
      psidepag IN NUMBER,
      pnmovres IN NUMBER,
      pidioma IN NUMBER,
      vsquery OUT VARCHAR2,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_get_detalltramitacio(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pctramit IN NUMBER,
      pntramit IN NUMBER,
      pidioma IN NUMBER,
      vsquery OUT VARCHAR2,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION F_Ins_Siniestro
         Inserta a la taula SIN_SINIESTRO dels parÃ metres informats.
         param in pnsinies  : nÃºmero del sinistre
         param in psseguro  : codi del segur
         param in pnriesgo  : codi de la causa del sinistre
         param in pnmovimi  : nÃºmero moviment
         param in pfsinies  : data del sinistre
         param in pfnotifi  : data de la notificaciÃ³
         param in pccausin  : codi causa sinistre
         param in pcmotsin  : codi motiu sinistre
         param in pcevento  : codi event sinistre
         param in pcculpab  : codi culpabilitat
         param in pcreclama : codi reclamaciÃ³
         param in pnasegur  : nÃºmero assegurat
         param in pcmeddec  : codi metge declaraciÃ³
         param in pctipdec  : codi tipus declarant
         param in ptnomdec  : nom declarant
         param in ptnom2dec  : segon nom declarant --BUG 19896 --ETM --20/12/2011-AÃ±adir campo 2nombre de declarante
         param in ptape1dec : primer cognom declarant
         param in ptape2dec : segon cognom declarant
         param in ptteldec  : telefon declarant
         param in ptmovildec : telefon movil declarant --BUG 19896 --ETM --20/12/2011-AÃ±adir campo telefono mov de declarante
         param in ptemaildec: email del declarant --BUG 19896 --ETM --20/12/2011-AÃ±adir campo email  de declarante
         param in ptsinies  : descripcio sinistre
         param in out pnsinies: nÃºmero sinistre
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_ins_siniestro(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pfsinies IN DATE,
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
      ptnom1dec IN VARCHAR2,
      ptnom2dec IN VARCHAR2,   --BUG 19896 --ETM --20/12/2011-AÃ±adir campo telefono mov de declarante
      ptape1dec IN VARCHAR2,
      ptape2dec IN VARCHAR2,
      ptteldec IN VARCHAR2,
      ptmovildec IN VARCHAR2,   --BUG 19896 --ETM --20/12/2011-AÃ±adir campo telefono mov de declarante
      ptemaildec IN VARCHAR2,   --BUG 19896 --ETM --20/12/2011-AÃ±adir campo email  de declarante
      ptsinies IN VARCHAR2,
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      pnsincia IN VARCHAR2,   --BUG 14587 - PFA - 13/08/2010 - AÃ±adir campo siniestro compaÃ±ia
      pccompani IN NUMBER,   -- Bug 15006 - PFA - 16/08/2010 - nuevos campos en bÃºsqueda siniestros
      pnpresin IN VARCHAR2,   -- Bug 15006 - PFA - 16/08/2010 - nuevos campos en bÃºsqueda siniestros
      pnsinies IN OUT sin_siniestro.nsinies%TYPE,
      pcnivel IN NUMBER DEFAULT NULL,
      psperson IN NUMBER DEFAULT NULL,
      psperson_dec IN NUMBER DEFAULT NULL,
      -- Bug 0015669 - JRH - 30/09/2010 - Alta prestaciones
      pfechapp IN DATE DEFAULT NULL,
      -- Fi Bug 0015669 - JRH - 30/09/2010
      pcpolcia IN VARCHAR2 DEFAULT NULL,   --BUG17539 - JTS - 10/02/2011
      piperit IN NUMBER DEFAULT NULL,   --BUG17539 - JTS - 10/02/2011
      pcfraude IN NUMBER DEFAULT NULL,   --BUG18748 - JBN
      pccarpeta IN NUMBER DEFAULT NULL,   -- BUG19832 - 21/10/2011 - JMP
      pcagente IN NUMBER DEFAULT NULL,   -- Bug 21817 - MDS - 2/05/2012
      pcsalvam IN NUMBER DEFAULT NULL,   -- BUG 0024675 - 15/11/2012 - JMF
      --BUG 39475/222692
      pfdeteccion DATE DEFAULT NULL,
      psolidaridad IN Number default null, -- CONF-249
      ptdetpreten IN VARCHAR2 default null
      )
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION F_Ins_Movsiniestro movseguro
         Inserta a la taula SIN_MOVSINIESTRO dels parÃ metres informats.
         param in pnsinies     : nÃºmero del sinistre
         param in pcestsin     : codi estat sinistre
         param in pfestsin     : data estat sinistre
         param in pccauest     : codi causa estat sinistre
         param in pcunitra     : codi unitat tramitaciÃ³
         param in pctramitad   : codi tramitador
         param in out pnmovsin : numero moviment
         return                : 0 -> Tot correcte
                                 1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_ins_movsiniestro(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pcestsin IN NUMBER,
      pfestsin IN DATE,
      pccauest IN NUMBER,
      pcunitra IN VARCHAR2,
      pctramitad IN VARCHAR2,
      pnmovsin IN OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION F_Ins_Tramitacion
         Inserta a la taula SIN_TRAMITACION dels parÃ metres informats.
         param in pnsinies   : nÃºmero del sinistre
         param in pntramit   : numero tramitaciÃ³ sinistre
         param in pctramit   : codi tramitaciÃ³
         param in pctcausin  : codi tipus dany
         param in pcinform   : indicador tramitaciÃ³ informativa
         param in pcsubtiptra : codigo subtipo tramitacion vf_dep.1090
         return              : 0 -> Tot correcte
                               1 -> S'ha produit un error
      -- BUG 0023536 - 24/10/2012 - JMF: Afegir pcsubtiptra
   *************************************************************************/
   FUNCTION f_ins_tramitacion(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pctramit IN NUMBER,
      pctcausin IN NUMBER,
      pcinform IN NUMBER,
      pntramit IN OUT NUMBER,
      pcculpab IN NUMBER DEFAULT NULL,
      pccompani IN VARCHAR2 DEFAULT NULL,
      pnsincia IN VARCHAR2 DEFAULT NULL,
      pcpolcia IN VARCHAR2 DEFAULT NULL,
      piperit IN NUMBER DEFAULT NULL,
      pntramte IN NUMBER DEFAULT NULL,   --bug 0018379 - JMC - 02/05/2011
      pcsubtiptra IN NUMBER DEFAULT NULL,
      pnradica IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION F_Ins_Tramita_Movimiento
         Inserta a la taula SIN_TRAMITA_MOVIMIENTO dels parÃ metres informats.
         param in pnsinies   : nÃºmero del sinistre
         param in pntramit   : numero tramitaciÃ³ sinistre
         param in pcunitra   : codi unitat tramitaciÃ³
         param in pctramitad : codi tramitador
         param in pcesttra   : codi estat tramitaciÃ³
         param in pcsubtra   : codi subestat tramitaciÃ³
         param in pfesttra   : data estat tramitaciÃ³
         param in out pnmovtra   : nÃºmero moviment tramitaciÃ³
         return              : 0 -> Tot correcte
                               1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_ins_tramita_movimiento(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pcunitra IN VARCHAR2,
      pctramitad IN VARCHAR2,
      pcesttra IN NUMBER,
      pcsubtra IN NUMBER,
      pfesttra IN DATE,
      pnmovtra IN OUT NUMBER,
      pccauest IN NUMBER DEFAULT NULL,
      pcvalida_ult IN NUMBER DEFAULT NULL   --bug 29989/165377;NSS;13-02-2014
                                         )
      RETURN NUMBER;

       /*************************************************************************
         FUNCTION F_Ins_detalltramitacio
            Inserta a les taules de detall de tramitacions dels parÃ metres informats.
   pctiptra IN NUMBER,
         pnsinies IN VARCHAR2,
         pntramit IN NUMBER,
         psperson IN NUMBER,
         pcestper IN NUMBER,
         pccompani IN VARCHAR2,
         pcpolcia IN VARCHAR2,
         piperit IN NUMBER,
         pttramita IN VARCHAR2,
         pcsiglas IN NUMBER,
         ptnomvia IN VARCHAR2,
         pnnumvia IN NUMBER,
         ptcomple IN VARCHAR2,
         ptdirec IN VARCHAR2,
         pcpais IN NUMBER,
         pcprovin IN NUMBER,
         pcpoblac IN NUMBER,
         pcpostal IN VARCHAR2,
         param in pcciudad
         param in pfgisx
         param in pfgisy
         param in pfgisz
         param in pcvalida
         pspercon IN NUMBER,
         pctipcar IN VARCHAR2,
         pfcarnet IN DATE,
         pctipcon IN NUMBER,
         pcalcohol IN NUMBER,
         pctipmat IN NUMBER,
         pcmatric IN VARCHAR2,
         pcmarca IN VARCHAR2,
         psmodelo IN NUMBER,
         pcversion IN VARCHAR2,
         )
            return             : 1 -> Tot correcte
                                 0 -> S'ha produit un error
      -- BUG 0023540 - 24/10/2012 - JMF: Afegir IRECLAM, IINDEMN
      *************************************************************************/
   FUNCTION f_ins_detalltramitacio(
      pctiptra IN NUMBER,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pcestper IN NUMBER,
      pttramita IN VARCHAR2,
      pcsiglas IN NUMBER,
      ptnomvia IN VARCHAR2,
      pnnumvia IN NUMBER,
      ptcomple IN VARCHAR2,
      ptdirec IN VARCHAR2,
      pcpais IN NUMBER,
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      pcpostal IN VARCHAR2,
      pcciudad IN NUMBER,
      pfgisx IN FLOAT,
      pfgisy IN FLOAT,
      pfgisz IN FLOAT,
      pcvalida IN NUMBER,
      pctipcar IN VARCHAR2,
      pfcarnet IN DATE,
      pctipcon IN NUMBER,
      pcalcohol IN NUMBER,
      pctipmat IN NUMBER,
      pcmatric IN VARCHAR2,
      pcmarca IN VARCHAR2,
      psmodelo IN NUMBER,
      pcversion IN VARCHAR2,
      pnanyo IN NUMBER,
      pcodmotor IN VARCHAR2,
      pcchasis IN VARCHAR2,
      pnbastid IN VARCHAR2,
      pccilindraje IN VARCHAR2,
      pireclam IN NUMBER DEFAULT NULL,
      piindemn IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION F_Ins_Detpersona
         Inserta a la taula SIN_TRAMITA_DETPERSONA dels parÃ metres informats.
         param in pnsinies  : nÃºmero del sinistre
         param in pntramit  : numero tramitaciÃ³ sinistre
         param in psperson  : codi persona
         param in pcestper  : codi estat persona
         param in pccompani : codi companyia asseg. contraria
         param in pcpolcia  : codi pÃ²lissa companyia asseg. contraria
         param in piperit   : import peritatge
         param in pttramita : desc tramitaciÃ³
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_ins_detpersona(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pcestper IN NUMBER,
      pttramita IN VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION F_Ins_Detdireccion
         Inserta a la taula SIN_TRAMITA_DETDIRECCION dels parÃ metres informats.
         param in pnsinies  : nÃºmero del sinistre
         param in pntramit  : numero tramitaciÃ³ sinistre
         param in psperson  : codi persona
         param in pcsiglas  : codi tipus via
         param in ptnomvia  : nom via
         param in pnnumvia  : nÃºmero via
         param in ptcomple  : dades complementaries
         param in ptdirec   : direcciÃ³ no normalitzada
         param in pcpais    : codi paÃ­s
         param in pcprovin  : codi provincia
         param in pcpoblac  : codi poblaciÃ³
         param in pcpostal  : codi postal
         param in pccompani : codi companyia asseg. contraria
         param in pcpolcia  : codi pÃ²lissa companyia asseg. contraria
         param in piperit   : import peritatge
         param in pttramita : desc tramitaciÃ³
         param in pcciudad  : codigo de ciudad
         param in pfgisx    : codigo gis x
         param in pfgisy    : codigo gis y
         param in pfgisz    : codigo gis z
         param in pcvalida  : codigo de si valida la direccion
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error

         Bug 12668 - 26/02/2010 - AMC
   *************************************************************************/
   FUNCTION f_ins_detdireccion(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pcsiglas IN NUMBER,
      ptnomvia IN VARCHAR2,
      pnnumvia IN NUMBER,
      ptcomple IN VARCHAR2,
      ptdirec IN VARCHAR2,
      pcpais IN NUMBER,
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      pcpostal IN VARCHAR2,
      pttramita IN VARCHAR2,
      pcciudad IN NUMBER,
      pfgisx IN FLOAT,
      pfgisy IN FLOAT,
      pfgisz IN FLOAT,
      pcvalida IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION F_Ins_Detvehiculo
         Inserta a la taula SIN_TRAMITA_DETVEHICULO dels parÃ metres informats.
         param in pnsinies  : nÃºmero del sinistre
         param in pntramit  : numero tramitaciÃ³ sinistre
         param in pspercon  : nÃºmero persona conductor/propietari
         param in pcestper  : codi estat persona
         param in pctipcar  : codi tipus permÃ­s conduir
         param in pfcarnet  : data permÃ­s conduir
         param in pctipcon  : codi tipus conductor
         param in pcalcohol : indicador alcoholemia
         param in pctipmat  : codi tipus matrÃ­cula
         param in pcmatric  : codi matrÃ­cula
         param in pcmarca   : codi marca vehÃ­cle
         param in psmodelo  : seqÃ¼Ã©ncia model vehÃ­cle
         param in pcversion : codi versiÃ³ vehÃ­cle
         param in pccompani : codi companyia asseg. contraria
         param in pcpolcia  : codi pÃ²lissa companyia asseg. contraria
         param in piperit   : import peritatge
         param in pttramita : desc tramitaciÃ³
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_ins_detvehiculo(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pspercon IN NUMBER,
      pcestper IN NUMBER,
      pctipcar IN VARCHAR2,
      pfcarnet IN DATE,
      pctipcon IN NUMBER,
      pcalcohol IN NUMBER,
      pctipmat IN NUMBER,
      pcmatric IN VARCHAR2,
      pcmarca IN VARCHAR2,
      psmodelo IN NUMBER,
      pcversion IN VARCHAR2,
      pnanyo IN NUMBER,
      pcodmotor IN VARCHAR2,
      pcchasis IN VARCHAR2,
      pnbastid IN VARCHAR2,
      pccilindraje IN VARCHAR2,
      pttramita IN VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION F_Ins_Detdescripcion
         Inserta a la taula SIN_TRAMITA_DETDESCRIPCION dels parÃ metres informats.
         param in pnsinies  : nÃºmero del sinistre
         param in pntramit  : numero tramitaciÃ³ sinistre
         param in psperson  : nÃºmero persona propietari
         param in pccompani : codi companyia asseg. contraria
         param in pcpolcia  : codi pÃ²lissa companyia asseg. contraria
         param in piperit   : import peritatge
         param in pttramita : desc tramitaciÃ³
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   -- BUG 0023540 - 24/10/2012 - JMF: Afegir IRECLAM, IINDEMN
   *************************************************************************/
   FUNCTION f_ins_detdescripcion(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pttramita IN VARCHAR2,
      pireclam IN NUMBER DEFAULT NULL,
      piindemn IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
 /*************************************************************************
      FUNCTION f_ins_amparo
         Inserta y actualiza  la tabla sin_tramita_amparo .
         
      param in pnsinies : Numero Siniestro		     
       param in pntramit : Numero Tramitacion Siniestro		     
       param in pcgarant : Codigo Garantia		     
       param in pnpreten : vAlor de la pretension		     
       param in picaprie : Importe Capital Riesgo		     
       param in pcmonpreten : Codigo de moneda		     
       param in pcusualt : Codigo usuario alta		     
       param in pfalta : Fecha Alta		     
       param in pcusumod : Código Usuario Modificacion		     
       param in pfmodifi : Fecha Modificacion		     
          return             : 0 -> Tot correcte
                              1 -> Se ha producido un error
   -- BUG 004131 - 2019-05-22 - EA 
   *************************************************************************/ 
FUNCTION f_ins_amparo(
      pnsinies IN sin_siniestro.nsinies%TYPE
      ,pntramit IN NUMBER		     
       ,pcgarant IN NUMBER		     
       ,pnpreten IN NUMBER		     
       ,picaprie IN NUMBER		     
       ,pcmonpreten IN VARCHAR2	 
                     )
      RETURN NUMBER;
   /*************************************************************************
      FUNCTION F_Ins_Reserva
         Inserta a la taula SIN_TRAMITA_RESERVA dels parÃ metres informats.
         param in pnsinies  : nÃºmero del sinistre
         param in pntramit  : numero tramitaciÃ³ sinistre
         param in pctipres  : codi tipus reserva
         param in pcgarant  : codi garantia
         param in pccalres  : codi cÃ¡lcul reserva (Manual/AutomÃ tic)
         param in pfmovres  : data moviment reserva
         param in pcmonres  : Codi Moneda Reserva
         param in pireserva : import reserva
         param in pipago    : import pagament
         param in piingreso : import ingres
         param in pirecobro : import recobrament
         param in pfresini  : data inici reserva
         param in pfresfin  : data fi reserva
         param in pfultpag  : data ultim pagament
         param in psidepag  : seqÃ¼Ã©ncia identificador pagament
         param in out pnmovres  : nÃºmero moviment reserva
                  ...
         param in pcalcfranq : 0 --> Indica que no se debe realizar el recalculo de franquicia para los gastos de M.O./ Rep. (F_recalculo)
                               1 Ã³ NULL --> Valor por defecto,  se realiza el calculo de la franquicia.


         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error

     Bug 11945 - 16/12/2009 - AMC - Se aÃ±ade piprerec
   *************************************************************************/
   FUNCTION f_ins_reserva(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pctipres IN NUMBER,
      pcgarant IN NUMBER,
      pccalres IN NUMBER,
      pfmovres IN DATE,
      pcmonres IN VARCHAR2,
      pireserva IN NUMBER,
      pipago IN NUMBER,
      picaprie IN NUMBER,
      pipenali IN NUMBER,
      piingreso IN NUMBER,
      pirecobro IN NUMBER,
      pfresini IN DATE,
      pfresfin IN DATE,
      pfultpag IN DATE,
      psidepag IN NUMBER,
      piprerec IN NUMBER,
      pctipgas IN NUMBER,
      pnmovres IN OUT NUMBER,
      pcmovres IN NUMBER,   --Bug 31294/174788:NSS:22/05/2014
      pifranq IN NUMBER DEFAULT NULL,   --Bug 27059:NSS:03/06/2013
      pndias IN NUMBER DEFAULT NULL,   --Bug 27487/159742:NSS:26/11/2013
      pitotimp IN NUMBER DEFAULT NULL,   -- 24637/0147756:NSS:05/03/2014
      pitotret IN NUMBER DEFAULT NULL,   -- 24637/0147756:NSS:20/03/2014
      piva_ctipind IN NUMBER DEFAULT NULL,   -- 24637/0147756:NSS:20/03/2014
      pretenc_ctipind IN NUMBER DEFAULT NULL,   -- 24637/0147756:NSS:20/03/2014
      preteiva_ctipind IN NUMBER DEFAULT NULL,   -- 24637/0147756:NSS:20/03/2014
      preteica_ctipind IN NUMBER DEFAULT NULL,   -- 24637/0147756:NSS:20/03/2014
      pcalcfranq IN NUMBER DEFAULT NULL,   -- 29801/183298:JTT:29/09/2014
      pcsolidaridad IN NUMBER DEFAULT NULL,   -- CONF-431 IGIL
      pmigracion IN NUMBER
            DEFAULT 0   -- indica 0 - No es migraciÃ³n, envio a sistema remoto. 1- Es migracion no envio a sisemas remotos.
                     )
      RETURN NUMBER;

      /*************************************************************************
      FUNCTION F_Ins_Referencia
         Inserta a la taula SIN_TRAMITA_RESERVA dels parÃ metres informats.
         param in pnsinies  : nÃºmero del sinistre
         param in pntramit  : numero tramitaciÃ³ sinistre
         param in pctipres  : codi tipus reserva
         param in pcgarant  : codi garantia
         param in pccalres  : codi cÃ¡lcul reserva (Manual/AutomÃ tic)
         param in pfmovres  : data moviment reserva
         param in pcmonres  : Codi Moneda Reserva
         param in pireserva : import reserva
         param in pipago    : import pagament
         param in piingreso : import ingres
         param in pirecobro : import recobrament
         param in pfresini  : data inici reserva
         param in pfresfin  : data fi reserva
         param in pfultpag  : data ultim pagament
         param in psidepag  : seqÃ¼Ã©ncia identificador pagament
         param in out pnmovres  : nÃºmero moviment reserva
         param in piprerec  : importe prevision recobro
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error

     Bug 11945 - 16/12/2009 - AMC - Se aÃ±ade piprerec
   *************************************************************************/
   FUNCTION f_ins_referencia(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      psrefext IN NUMBER,
      pctipref IN NUMBER,
      ptrefext IN VARCHAR2,
      pfrefini IN DATE,
      pfreffin IN DATE)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_ins_pago
         Inserta a la taula SIN_TRAMITA_PAGO dels parÃ metres informats.
         param in psidepag  : seqÃ¼Ã©ncia identificador pagament;
         param in pnsinies  : nÃºmero sinistre
         param in pntramit  : nÃºmero tramitaciÃ³ sinistre
         param in psperson  : seqÃ¼Ã©ncia persona
         param in pctipdes  : codi tipus Tipo Destinatario
         param in pctippag  : codi tipus pagament
         param in pcconpag  : codi concepte pagament
         param in pccauind  : codi causa indemnitzaciÃ³
         param in pcforpag  : codi forma pagament
         param in pfordpag  : data ordre pagament
         param in pctipban  : codi tipus compte bancaria
         param in pcbancar  : codi compte bancaria
         param in pisinret  : import sense retenciÃ³
         param in piconret  : import amb retenciÃ³
         param in piretenc  : import retenciÃ³
         param in ppretenc  : porcentatge retenciÃ³
         param in piiva     : import IVA
         param in pisuplid  : import 'Suplido'
         param in pifranq   : import franquicia pagada
         param in pnfacref  : nÃºmero factura/referÃ©ncia
         param in pffacref  : data factura/referÃ©ncia
         param in psidepagtemp : indica si el sidepag es el real
         param in pcultpag : ultimo pago
         param in pireteiva : Importe de retenciÃ³n sobre el IVA
         param in pireteica : Importe de retenciÃ³n sobre el ICA
         param in pireteivapag : Importe de retenciÃ³n sobre el IVA Moneda Pago
         param in pireteicapag : Importe de retenciÃ³n sobre el ICA Moneda Pago
         param in piica :
         paran in piicapag :
         param in pcmonres     : Moneda de la reserva
         param in pcagente    : CÃ³digo del agente/mediador
         param in pnpersrel   : CÃ³digo persona relacionada/perjudicada
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error

    -- Bug 11848 - 23/11/2009  - AMC - Se aÃ±ade el parametro psidepagtemp
    -- BUG 19981 - 07/11/2011 - MDS - AÃ±adir campos ireteiva, ireteica, ireteivapag, ireteicapag, iica, iicapag
    -- Bug 22256/122456 - 28/09/2012 - AMC  - AÃ±adir campos cagente,npersrel,pcdomici y pctributacion
   *************************************************************************/
   FUNCTION f_ins_pago(
      psidepag IN OUT NUMBER,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pctipdes IN NUMBER,
      pctippag IN NUMBER,
      pcconpag IN NUMBER,
      pccauind IN NUMBER,
      pcforpag IN NUMBER,
      pfordpag IN DATE,
      pctipban IN NUMBER,
      pcbancar IN VARCHAR2,
      pisinret IN NUMBER,
      piretenc IN NUMBER,
      piiva IN NUMBER,
      pisuplid IN NUMBER,
      pifranq IN NUMBER,
      piresrcm IN NUMBER,
      piresred IN NUMBER,
      pnfacref IN VARCHAR2,
      pffacref IN DATE,
      psidepagtemp IN NUMBER,
      pcultpag IN NUMBER,
      pncheque IN VARCHAR2,
      pireteiva IN NUMBER,
      pireteica IN NUMBER,
      pireteivapag IN NUMBER,
      pireteicapag IN NUMBER,
      piica IN NUMBER,
      piicapag IN NUMBER,
      pcmonres IN VARCHAR2 DEFAULT NULL,   --- BUG 18423/104212 - 03/02/2012 - JMP - Multimoneda
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
      FUNCTION f_ins_movpago
         Inserta a la taula SIN_TRAMITA_MOVPAGO dels parÃ metres informats.
         param in psidepag : seqÃ¼Ã©ncia identificador pagament
         param in pnmovpag : nÃºmero moviment pagament
         param in pcestpag : estat pagament
         param in pfefepag : data efecte pagament
         param in pcestval : estat validaciÃ³ pagament
         param in pfcontab : data contabilitat
         param in psproces : seqÃ¼Ã©ncia proces
         param in pcestpagant :  estat pagament anterior
         return            : 0 -> Tot correcte
                             1 -> S'ha produit un error

     -- Bug 13312 - 08/03/2010 - AMC - Se aÃ±ade el parametro pcestpagant
   *************************************************************************/
   FUNCTION f_ins_movpago(
      psidepag IN NUMBER,
      pcestpag IN sin_tramita_movpago.cestpag%TYPE,
      pfefepag IN DATE,
      pcestval IN NUMBER,
      pfcontab IN DATE,
      psproces IN NUMBER,
      pcestpagant IN NUMBER,
      pnmovpag IN OUT NUMBER,
      pcsubpag IN NUMBER,   --Bug: 19601 - 13/10/2011 - JMC
      pcsubpagant IN NUMBER,
      pndocpag IN NUMBER DEFAULT NULL) -- IAXIS-7731 19/12/2019
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_ins_citacion
         Inserta a la taula SIN_TRAMITA_DESTINATARIO dels parÃ metres informats.
         param in pnsinies : nÃºmero sinistre
         param in pntramit : nÃºmero tramitaciÃ³ sinistre
         param in pncitacion : numero citacion
         param in pfcitacion : fecha citacion
         param in phcitacion : hora citacion
         param in pcpais : codigo pais
         param in pcprovin : codigo provincia
         param in pcpoblac : codigo poblacion
         param in ptlugar : lugar citacion
         return            : 0 -> Tot correcte
                             1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_ins_citacion(
      pnsinies IN sin_siniestro.nsinies%TYPE,
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
      pcmedio IN NUMBER)
      RETURN NUMBER;

  /*************************************************************************
      FUNCTION f_ins_destinatario
         Inserta a la taula SIN_TRAMITA_DESTINATARIO dels parÃ metres informats.
         param in pnsinies : nÃºmero sinistre
         param in pntramit : nÃºmero tramitaciÃ³ sinistre
         param in psperson : estat pagament
         param in pctipdes : codi tipus destinatari
         param in pcpagdes : indicador acceptaciÃ³ pagaments
         param in pcactpro : codi activitat professional
         return            : 0 -> Tot correcte
                             1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_ins_destinatario(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pcbancar IN VARCHAR2,
      pctipban IN NUMBER,
      ppasigna IN NUMBER,
      pcpaisre IN NUMBER,
      pctipdes IN NUMBER,
      pcpagdes IN NUMBER,
      pcactpro IN NUMBER,
      pctipcap IN NUMBER DEFAULT NULL   -- Bug 0015669 - JRH - 30/09/2010 - Alta prestaciones
                                     ,
      pcrelase IN NUMBER DEFAULT NULL,
      -- Fi Bug 0015669 - JRH - 30/09/2010
      psprofes IN NUMBER DEFAULT NULL,   -- Bug 0024637/0147756: (POSAN500-AN-Sin) Analisis Desarrollo: Siniestros - NSS - 26/02/2014
      pcprovin IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_ins_documento
         Inserta a la taula SIN_TRAMITA_DOCUMENTO dels parÃ metres informats.
         param in pnsinies  : nÃºmero sinistre
         param in pntramit  : nÃºmero tramitaciÃ³ sinistre
         param in pndocume  : nÃºmero document sinistre
         param in pcdocume  : cÃ³digo document sinistre
         param in pfreclama : data reclamaciÃ³ document
         param in pfrecibe  : data recepciÃ³ document
         param in pfcaduca  : data caducitat document
         param in pcobliga  : codi document obligatori/opcional
         param in pdescripcion    : descripcion del usuario para el documento
         param in pcaccion  : Codigo de acciÃ³n
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
         28/09/2009   DCT    BUG 10393 Crear parametrizaciÃ³n de documentaciÃ³n a solicitar por producto/causa/motivo
   *************************************************************************/
   FUNCTION f_ins_documento(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pndocume IN NUMBER,
      pcdocume IN NUMBER,
      pfreclama IN DATE,
      pfrecibe IN DATE,
      pfcaduca IN DATE,
      pcobliga IN NUMBER,
      pdescripcion IN VARCHAR2,
      pcaccion IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_ins_localizacion
         Inserta a la taula SIN_TRAMITA_LOCALIZA dels parÃ metres informats.
         param in pnsinies : nÃºmero sinistre
         param in pntramit : nÃºmero tramitaciÃ³ sinistre
         param in pnlocali : nÃºmero localitzaciÃ³ sinistre
         param in psperson : nÃºmero persona
         param in pcsiglas : tipus via
         param in ptnomvia : nom via
         param in pnnumvia : nÃºmero via
         param in ptcomple : descripciÃ³ complementaria
         param in ptlocali : direcciÃ³ no normalitzada
         param in pcpais   : codi paÃ­s
         param in pcprovin : codi provincia
         param in pcpoblac : codi poblaciÃ³
         param in pcpostal : codi postal

         -- Bug 18940/92686 - 27/09/2011 - AMC
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
        -- Fi Bug 18940/92686 - 27/09/2011 - AMC

         return            : 0 -> Tot correcte
                             1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_ins_localiza(
      pnsinies IN sin_siniestro.nsinies%TYPE,
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
      plocalidad IN VARCHAR2   -- Bug 24780/130907 - 05/12/2012 - AMC
                            )
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_ins_dano
         Inserta a la taula SIN_TRAMITA_DANO dels parÃ metres informats.
         param in pnsinies  : nÃºmero sinistre
         param in pntramit  : nÃºmero tramitaciÃ³ sinistre
         param in pndano    : nÃºmero dany sinistre
         param in pctipdano : codi tipus dany
         param in ptdano    : descripciÃ³ dany
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_ins_dano(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pndano IN NUMBER,
      pctipinf IN NUMBER,
      ptdano IN VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_ins_detdano
         Inserta a la taula SIN_TRAMITA_DANO dels parÃ metres informats.
         param in pnsinies  : nÃºmero sinistre
         param in pntramit  : nÃºmero tramitaciÃ³ sinistre
         param in pndano    : nÃºmero dany sinistre
         param in pctipdano : codi tipus dany
         param in ptdano    : descripciÃ³ dany
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_ins_detdano(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pndano IN NUMBER,
      pndetdano IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_ins_profesional
         Inserta a la taula SIN_TRAMITA_PROFESIONAL dels parÃ metres informats.
         param in pnsinies : nÃºmero sinistre
         param in pntramit : nÃºmero tramitaciÃ³ sinistre
         param in pnlocali : nÃºmero localitzaciÃ³ sinistre
         param in psperson : codi persona
         param in pcactpro : codi activitat professional
         param in pfinivig : data inici vigencia
         param in pffinvig : data fi vigencia
         return            : 0 -> Tot correcte
                             1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_ins_profesional(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pnlocali IN NUMBER,
      psperson IN NUMBER,
      pcactpro IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_valida_cab
         FunciÃ³ que valida la capÃ§alera d'un sinistre
         param in pnsinies  : nÃºmero del sinistre
         param in psseguro  : codi del segur
         param in pnriesgo  : codi de la causa del sinistre
         param in pnmovimi  : nÃºmero moviment
         param in pfsinies  : data del sinistre
         param in pfnotifi  : data de la notificaciÃ³
         param in pntramit  : numero tramitaciÃ³ sinistre
         param in pctramit  : codi tramitaciÃ³
         param in pctcausin : codi tipus dany
         param in pcinform  : indicador tramitaciÃ³ informativa
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_valida_cap(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pfsinies IN DATE,
      pfnotifi IN DATE,
      pntramit IN NUMBER,
      pnlocali IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_valida_tram
         FunciÃ³ que valida una tramitaciÃ³ d'un sinistre
         param in pnsinies   : nÃºmero del sinistre
         param in pntramit   : numero tramitaciÃ³ sinistre
         param in pctramit   : codi tramitaciÃ³
         param in pctcausin  : codi tipus dany
         param in pcinform   : indicador tramitaciÃ³ informativa
         return              : 0 -> Tot correcte
                               1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_valida_tram(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pctramit IN NUMBER,
      pctcausin IN NUMBER,
      pcinform IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_valida_trammov
         FunciÃ³ que valida un moviment de tramitaciÃ³ d'un sinistre
         param in pnsinies   : nÃºmero del sinistre
         param in pntramit   : numero tramitaciÃ³ sinistre
         param in pnmovtra   : nÃºmero moviment tramitaciÃ³
         param in pcunitra   : codi unitat tramitaciÃ³
         param in pctramitad : codi tramitador
         param in pcesttra   : codi estat tramitaciÃ³
         param in pcsubtra   : codi subestat tramitaciÃ³
         param in pfesttra   : data estat tramitaciÃ³
         return              : 0 -> Tot correcte
                               1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_valida_trammov(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pnmovtra IN NUMBER,
      pcunitra IN NUMBER,
      pctramitad IN NUMBER,
      pcesttra IN NUMBER,
      pcsubtra IN NUMBER,
      pfesttra IN DATE)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_valida_tramdano
         FunciÃ³ que valida els danys per tramitaciÃ³ d'un sinistre
         param in pnsinies  : nÃºmero sinistre
         param in pntramit  : nÃºmero tramitaciÃ³ sinistre
         param in pndano    : nÃºmero dany sinistre
         param in pctipdano : codi tipus dany
         param in ptdano    : descripciÃ³ dany
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_valida_tramdano(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pndano IN NUMBER,
      pctipdano IN NUMBER,
      ptdano IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_valida_tramres
         FunciÃ³ que valida les reserves per tramitaciÃ³ d'un sinistre
         param in pnsinies  : nÃºmero del sinistre
         param in pntramit  : numero tramitaciÃ³ sinistre
         param in pctipres  : codi tipus reserva
         param in pnmovres  : nÃºmero moviment reserva
         param in pfmovres  : data moviment reserva
         param in pireserva : import reserva
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_valida_tramres(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pctipres IN NUMBER,
      pnmovres IN NUMBER,
      pccalres IN NUMBER,
      pfmovres IN DATE,
      pcmonres IN VARCHAR2,
      pireserva IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_valida_tramdes
         FunciÃ³ que valida els destinataris per tramitaciÃ³ d'un sinistre
         param in pnsinies : nÃºmero sinistre
         param in pntramit : nÃºmero tramitaciÃ³ sinistre
         param in psperson : nÃºmero persona
         param in pctipdes : codi tipus destinatari
         param in pcpagdes : indicador acceptaciÃ³ pagaments
         return            : 0 -> Tot correcte
                             1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_valida_tramdes(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pctipdes IN NUMBER,
      pcpagdes IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_valida_trampag
         FunciÃ³ que valida els pagaments per tramitaciÃ³ d'un sinistre
         param in pnsinies  : nÃºmero del sinistre
         param in psidepag  : seqÃ¼Ã©ncia identificador pagament;
         param in pnsinies  : nÃºmero sinistre
         param in pntramit  : nÃºmero tramitaciÃ³ sinistre
         param in psperson  : seqÃ¼Ã©ncia persona
         param in pctipdes  : codi tipus Tipo Destinatario
         param in pctippag  : codi tipus pagament
         param in pcconpag  : codi concepte pagament
         param in pccauind  : codi causa indemnizaciÃ³
         param in pcforpag  : codi forma pagament
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_valida_trampag(
      psidepag IN NUMBER,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pctipdes IN NUMBER,
      pctippag IN NUMBER,
      pcconpag IN NUMBER,
      pccauind IN NUMBER,
      pcforpag IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_valida_trampagogar
         FunciÃ³ que valida el detall dels pagaments per tramitaciÃ³ d'un sinistre
         param in psidepag : seqÃ¼Ã©ncia identificador pagament
         param in pctipres : codi tipus reserva
         param in pnmovres : nÃºmero movimient reserva
         return            : 0 -> Tot correcte
                             1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_valida_trampagogar(psidepag IN NUMBER, pctipres IN NUMBER, pnmovres IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_valida_tramagen
         FunciÃ³ que valida l'agenda per tramitaciÃ³ d'un sinistre
         param in nsinies : nÃºmero sinistre
         param in ntramit : nÃºmero tramitaciÃ³ sinistre
         param in nlinage : nÃºmero linia
         param in ctipreg : codi tipus registre
         param in csubtip : codi subtipus
         param in fmovage : data moviment agenda
         param in cestage : codi estat agenda
         return           : 0 -> Tot correcte
                            1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_valida_tramagen(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pnlinage IN NUMBER,
      pctipreg IN NUMBER,
      pcsubtip IN NUMBER,
      pfmovage IN NUMBER,
      pcestage IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_ins_pago_gar
         Inserta a la taula SIN_TRAMITA_PAGO_GAR dels parÃ metres informats.
         param in psidepag    : seqÃ¼Ã©ncia identificador pagament
         param in pctipres    : codi tipus reserva
         param in pnmovres    : nÃºmero moviment reserva
         param in pcgarant    : codi garantia
         param in pfperini    : data periode inici
         param in pfperfin    : data periode fi
         param in pcmonres    : codi moneda reserva
         param in pisinret    : import sense retenciÃ³
         param in piiva       : import IVA
         param in pisuplid    : import 'suplido'
         param in piretenc    : import retenciÃ³
         param in pifranq     : import franquicia pagada
         param in pcmonpag    : codi moneda pagament
         param in pisinretpag :
         param in piivapag    : import IVA moneda pagament
         param in pisuplidpag : import 'suplido' moneda pagament
         param in piretencpag : import retenciÃ³ moneda pagament
         param in pifranqpag  : import franquicia moneda pagament
         param in pfcambio    : data cambi
         param in ppreteiva   : Porcentaje de retenciÃ³n sobre el IVA
         param in ppreteica   : Porcentaje de retenciÃ³n sobre el ICA
         param in pireteiva   : Importe de retenciÃ³n sobre el IVA
         param in pireteica   : Importe de retenciÃ³n sobre el ICA
         param in pireteivapag : Importe de retenciÃ³n sobre el IVA Moneda Pago
         param in pireteicapag : Importe de retenciÃ³n sobre el ICA Moneda Pago
         param in ppica :
         param in piica :
         param in piicapag :
         return               : 0 -> Tot correcte
                                1 -> S'ha produit un error
    -- BUG 19981 - 07/11/2011 - MDS - AÃ±adir campos preteiva, preteica, ireteiva, ireteica, ireteivapag, ireteicapag, pica, iica, iicapag
   *************************************************************************/
   FUNCTION f_ins_pago_gar(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
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
      piresrcm IN NUMBER,
      piresred IN NUMBER,
      ppretenc IN NUMBER,
      ppiva IN NUMBER,
      pcmonpag IN VARCHAR2,
      pisinretpag IN NUMBER,
      piivapag IN NUMBER,
      pisuplidpag IN NUMBER,
      piretencpag IN NUMBER,
      pifranqpag IN NUMBER,
      pfcambio IN DATE,
      pcconpag IN NUMBER,
      pnorden IN NUMBER,
      ppreteiva IN NUMBER,
      ppreteica IN NUMBER,
      pireteiva IN NUMBER,
      pireteica IN NUMBER,
      pireteivapag IN NUMBER,
      pireteicapag IN NUMBER,
      ppica IN NUMBER,
      piica IN NUMBER,
      piicapag IN NUMBER,
      pciva_tipind IN NUMBER DEFAULT NULL,   --bug 24637/147756:NSS:03/03/2014
      pcretenc_tipind IN NUMBER DEFAULT NULL,   --bug 24637/147756:NSS:03/03/2014
      pcreteiva_tipind IN NUMBER DEFAULT NULL,   --bug 24637/147756:NSS:03/03/2014
      pcreteica_tipind IN NUMBER DEFAULT NULL,   --bug 24637/147756:NSS:03/03/2014
      piotrosgas    IN NUMBER DEFAULT NULL,
      pibaseipoc    IN NUMBER DEFAULT NULL,
      ppipoconsumo  IN NUMBER DEFAULT NULL,
      pctipind      IN NUMBER DEFAULT NULL,
      piipoconsumo  IN NUMBER DEFAULT NULL,
      piotrosgaspag   IN NUMBER DEFAULT NULL,
      pibaseipocpag   IN NUMBER DEFAULT NULL,
      piipoconsumopag IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_ins_agenda
         Inserta a la taula SIN_TRAMITA_AGENDA dels parÃ metres informats.
         param in pnsinies    : nÃºmero sinistre
         param in pntramit    : nÃºmero tramitaciÃ³ sinistre
         param in pnlinage    : nÃºmero linia
         param in pctipreg    : codi tipus registre
         param in pcmanual    : codi registre manual
         param in pcestage    : codi estat agenda
         param in pffinage    : data finalitzaciÃ³
         param in pttitage    : tÃ­tol anotaciÃ³
         param in ptlinage    : descripciÃ³ anotaciÃ³
         return               : 0 -> Tot correcte
                                1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_ins_agenda(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pnlinage IN NUMBER,
      pctipreg IN NUMBER,
      pcmanual IN NUMBER,
      pcestage IN NUMBER,
      pffinage IN DATE,
      pttitage IN VARCHAR2,
      ptlinage IN VARCHAR2)
      RETURN NUMBER;

    /*************************************************************************
      FUNCTION f_ins_personarel
         Inserta a la taula SIN_TRAMITA_AGENDA dels parÃ metres informats.
         param in pnsinies    : nÃºmero sinistre
         param in pntramit    : nÃºmero tramitaciÃ³ sinistre
         param in pnpersrel   : nÃºmero linia persona
         param in pctipid     : nÃºmero d'IdentificaciÃ³
         param in ptnombre    : Nom
         param in ptapelli1   : Primer cognom
         param in ptapelli2   : Segon cognom
         param in pttelefon   : TelÃ¨fon
         param in psperson    : codi persona
         param in ptdesc      : descripciÃ³ persona relacionada
         param in ptnombre2    : segundo nombre
         param in ptmovil      : telf. movil
         param in ptemail      : email

         return               : 0 -> Tot correcte
                                1 -> S'ha produit un error

         Bug 22325/115249 - 05/06/2012 - AMC
         -- Bug 0024690 - 13/11/2012 - JMF
   *************************************************************************/
   FUNCTION f_ins_personarel(
      pnsinies IN sin_siniestro.nsinies%TYPE,
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
      pctiprel IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_del_personarel
         Inserta a la taula SIN_TRAMITA_AGENDA dels parÃ metres informats.
         param in pnsinies    : nÃºmero sinistre
         param in pntramit    : nÃºmero tramitaciÃ³ sinistre
         param in pnpersrel    : nÃºmero persona relacionada
   *************************************************************************/
   FUNCTION f_del_personarel(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pnpersrel IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_get_documento
         Recupera un document
         param in pnsinies  : nÃºmero del siniestro
         param in pntramit  : nÃºmero tramitaciÃ³n siniestro
         param in pndocume  : nÃºmero de documento
         param out vsquery  : text consulta
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_get_documento(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pndocume IN NUMBER,
      pcidioma IN NUMBER,
      vsquery OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
   FUNCTION f_get_unitradefecte
   Recupera la unitat de tramitaciÃ³ i el tramitador generats per defecte
   param in pcempres  : codi empresa
   param out pcunitra : codi unitat tramitadora
   param out pctramit : codi tramitador
   param out mensajes : missatges d'error
   return             : 0 -> Tot correcte
                        1 -> S'ha produit un error
*************************************************************************/
   FUNCTION f_get_unitradefecte(
      pcempres IN NUMBER,
      pcunitra OUT VARCHAR2,
      pctramit OUT VARCHAR2)
      RETURN NUMBER;

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
      param  in  pcultpag: Pago se crea marcado como Ãºltimo pago

      return              : 0 -> Tot correcte
                            1 -> S'ha produit un error

      25/05/2009   AMC                 Sinistres.  Bug: 8816
      Bug 12753     18/01/2010  AMC Se aÃ±ade el parametro pcdesaut
      -- Bug 0022490 - 09/07/2012 - JMF: aÃ±adir pcultpag
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
      pcultpag IN NUMBER)
      RETURN NUMBER;

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
   FUNCTION f_get_caumot(
      pscaumot IN NUMBER,
      pccausin OUT NUMBER,
      pcmotsin OUT NUMBER,
      pcpagaut OUT NUMBER,
      pcmotmov OUT NUMBER,
      pcmotfin OUT NUMBER,
      pcmovimi OUT NUMBER,
      pcdesaut OUT NUMBER,
      pcultpag OUT NUMBER)
      RETURN NUMBER;

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
   FUNCTION f_set_caumot_producte(
      pscaumot IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pctramit IN NUMBER)
      RETURN NUMBER;

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
   FUNCTION f_del_caumot_producte(
      pscaumot IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pctramit IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_set_caumot_destformula(
      pscaumot IN NUMBER,
      pctipdes IN NUMBER,
      pccampo IN VARCHAR2,
      pcclave IN NUMBER)
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
      pcclave IN NUMBER)
      RETURN NUMBER;

     /***********************************************************************
      Inserta un registro en sin_det_causa_motivo
      param  in  pscaumot : cÃ³digo de la causa/motivo
      param  in  pctipdes : cÃ³digo tipo destinatario
      param  in  pcmodfis : cÃ³digo del modelo fiscal
      return              : 0 -> Tot correcte
                            1 -> S'ha produit un error

      27/05/2009   AMC                 Sinistres.  Bug: 8816
   ***********************************************************************/
   FUNCTION f_set_sindetcausamot(pscaumot IN NUMBER, pctipdes IN NUMBER, pcmodfis IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Devuelve el siguiente codigo de causa/motivo
      param  out  pscaumot : PrÃ³ximo cÃ³digo de la causa/motivo
      return              : 0 -> Tot correcte
                            1 -> S'ha produit un error

      27/05/2009   AMC                 Sinistres.  Bug: 8816
   ***********************************************************************/
   FUNCTION f_get_nextscaumot(pscaumot OUT NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Eliminar de la taula sin_det_causa_motivo
      param  in  pscaumot : cÃ³digo de la causa/motivo
      param  in  pctipdes : cÃ³digo tipo destinatario
      return              : 0 -> Tot correcte
                            1 -> S'ha produit un error

      27/05/2009   AMC                 Sinistres.  Bug: 8816
   ***********************************************************************/
   FUNCTION f_del_caumot_destinatario(pscaumot IN NUMBER, pctipdes IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************
       Eliminar de la taula sin_causa_motivo
       param  in  pscaumot : cÃ³digo de la causa/motivo
       return              : 0 -> Tot correcte
                             1 -> S'ha produit un error

       28/05/2009   AMC                 Sinistres.  Bug: 8816
    ***********************************************************************/
   FUNCTION f_del_caumot(pscaumot IN NUMBER)
      RETURN NUMBER;

/***********************************************************************
   F_SIN_REA:    Aquesta funciÃ³ permet crear moviments d'abonament, per
                   part de les companyies de reasseguranÃ§a, en concepte dels
                   pagaments de sinistres.
                   Busca el desglos d'un pagament en seguro/riscos/garanties
                   i, per cada garantia, crida a la funciÃ³ F_PAGSINREA.
   ALLIBREA
***********************************************************************/
   FUNCTION f_sin_rea(
      psidepag IN sin_tramita_pago.sidepag%TYPE,
      pmoneda IN eco_codmonedas.cmoneda%TYPE,
      pnsinies IN sin_siniestro.nsinies%TYPE DEFAULT NULL,
      pctippag IN sin_tramita_pago.ctippag%TYPE DEFAULT NULL,
      pfefepag IN sin_tramita_movpago.fefepag%TYPE DEFAULT NULL,
      pcpagcoa IN NUMBER DEFAULT NULL,
      pcestpag IN sin_tramita_movpago.cestpag%TYPE DEFAULT NULL)
      RETURN NUMBER;

/***********************************************************************
   F_SIN_PAGREA: Aquesta funciÃ³ permet crear moviments d'abonament, per
                   part de les companyies de reasseguranÃ§a, en concepte dels
                   pagaments de sinistres.
                   Aquests moviments queden a CESIONESREA.
                   Es realitzen a partir de les dades i percentatges de
                   cessiÃ³ que figuren en els moviments de cessions
                   efectuades, sempre en funciÃ³ de les dates cobertes per la
                   cessiÃ³ amb relaciÃ³ a la data en que s'ha produit el
                   sinistre.
                   Primer buscarem cessions de igual garantÃ­a i, si no en
                   trobem, buscarem cessions del risc afectat amb la garantÃ­a
                   a NULL.
                   Si pctippag = 3 (anul.laciÃ³ pagament) o = 7 (recobrament),
                   es crea un moviment de signe contrari.
               Els tipus o motius de moviment considerats (cessions) son:
                   01 - regularitzaciÃ³
                   02 - pagaments de sinistres
                   03 - nova producciÃ³
                   04 - suplement
                   05 - cartera
                   09 - rehabilitaciÃ³ pÃ²lissa
                   40 - canvi data renovaciÃ³
               Casos especials:
                  - Si el pagament de sinistre Ã©s d'una reserva tipus despeses (ctipres=3),
                    no es tÃ© en compte la garantia de la cessiÃ³ a CESIONESREA.
   ALLIBREA
***********************************************************************/
   FUNCTION f_sin_pagrea(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN riesgos.nriesgo%TYPE,
      pcgarant IN garanseg.cgarant%TYPE,
      pctipres IN sin_tramita_reserva.ctipres%TYPE,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pfsinies IN sin_siniestro.fsinies%TYPE,
      pimportsin IN sin_tramita_pago.isinret%TYPE,
      pmoneda IN VARCHAR2,
      pctippag IN sin_tramita_pago.ctippag%TYPE,
      pcestpag IN sin_tramita_movpago.cestpag%TYPE,
      pefepag IN sin_tramita_movpago.fefepag%TYPE,
      psidepag IN sin_tramita_pago.sidepag%TYPE)
      RETURN NUMBER;

   /***********************************************************************
     FUNCTION F_TRAMITA_RESERVA:
      Devuelve la reserva pendiente de una tramitaciÃ³n
      param  in  pnsinies : NÃºmero Siniestro
      param  in  pntramit : NÃºmero TramitaciÃ³n
      param  in  pctipres : CÃ³digo Tipo Reserva
      param  in  pcgarant : CÃ³digo GarantÃ­a
      param  in  pcmonres : Moneda de la reserva
      param  in  pdata    : Fecha
      param  out pireserva: Importe Reserva Pendiente
      param  in  pidres   : Identificador de reserva
      param in default 0 prestot : Reserva total del siniestro
      return              : 0 -> Tot correcte
                            1 -> S'ha produit un error

      Bug 31294 - 04/07/2014 - JTT: AÃ±adimos el parametro pidres
   ***********************************************************************/
   FUNCTION f_tramita_reserva(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      pctipres IN sin_tramita_reserva.ctipres%TYPE,
      pctipgas IN sin_tramita_reserva.ctipgas%TYPE,   -- 26108
      pcgarant IN codigaran.cgarant%TYPE,
      pcmonres IN VARCHAR2,
      pdata IN DATE,
      pireserva OUT NUMBER,
      pidres IN sin_tramita_reserva.idres%TYPE,
      prestot IN NUMBER DEFAULT 0,   --Bug.: 21715 - 28/03/2012 - ICV
      pmoneda_origen IN NUMBER DEFAULT 0)
      -- 27847 - AVT - 05/08/2013 separem el import original del comptable
   RETURN NUMBER;

   /***********************************************************************
     FUNCTION F_SIN_RESERVA:
      Devuelve la reserva pendiente de un siniestro.
      param  in  pnsinies : NÃºmero Siniestro
      param  in  pdata    : Fecha
      param  out pireserva: Importe Reserva Pendiente
      param  out pireserva: Importe Reserva Pendiente
      return              : 0 -> Tot correcte
                            1 -> S'ha produit un error
   ***********************************************************************/
   FUNCTION f_sin_reserva(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pdata IN DATE,
      pireserva OUT NUMBER,
      prestot IN NUMBER DEFAULT 0,   --Bug.: 21715 - 28/03/2012 - ICV
      pcgarant IN NUMBER DEFAULT NULL   -- bug 0035670 - 08/05/2015 - JMF
                                     )
      RETURN NUMBER;

   /***********************************************************************
     FUNCTION F_ESTADO_TRAMITACION:
      Cambia el estado de una tramitaciÃ³n
      param in pnsinies : NÃºmero siniestro
      param in ntramit  : NÃºmero tramitaciÃ³n
      param in pcesttra : CÃ³digo estado
      param in pciesini : Indica si viene del cierre de siniestro (0=No, 1=Si).
      return              : 0 -> Tot correcte
                            1 -> S'ha produit un error
      31/07/2009   XVM                 Sinistres.  Bug: 8820
      -- Bug 0022906 - 17/07/2012 - JMF: pciesini
   ***********************************************************************/
   FUNCTION f_estado_tramitacion(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pcesttra IN NUMBER,
      porigen IN VARCHAR2 DEFAULT NULL,
      pccauest IN NUMBER DEFAULT NULL,
      pciesini IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /***********************************************************************
     FUNCTION F_ESTADO_SINIESTRO:
      Cambia el estado de un siniestro
      param in  pnsinies  : NÃºmero Siniestro
      param in pcestsin   : codi estat sinistre
      param in pccauest   : codi causa estat sinistre
      param in pcunitra   : codi unitat tramitaciÃ³
      param in pctramitad : codi tramitador
      param in pcsubtra   : codi subestat tramitaciÃ³
      return              : 0 -> Tot correcte
                            1 -> S'ha produit un error
      31/07/2009   XVM                 Sinistres.  Bug: 8820
   ***********************************************************************/
   FUNCTION f_estado_siniestro(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pcestsin IN NUMBER,
      pccauest IN NUMBER,
      pcunitra IN VARCHAR2,
      pctramitad IN VARCHAR2,
      pcsubtra IN NUMBER,
      pfsinfin IN DATE,
      porigen IN VARCHAR2 DEFAULT NULL,
      pccautra IN NUMBER DEFAULT NULL,
      pobserv  IN VARCHAR2 DEFAULT NULL) --IAXIS 3663 AABC 12/04/2019 Adicion campo observacion
      RETURN NUMBER;

   /***********************************************************************
     FUNCTION F_INS_DOCUMENTOS:
         Inserta a la taula SIN_TRAMITA_DOCUMENTO dels parÃ metres informats.
         param in psproduc  : CÃ³digo producto
         param in pcactivi  : CÃ³digo actividad
         param in pccausin  : CÃ³digo causa
         param in pcmotsin  : CÃ³digo motivo
         param in pcidioma  : CÃ³digo idioma
         param in pctramit  : CÃ³digo tramitaciÃ³n (opcional, sinÃ³ = 0)
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
      31/07/2009   XVM                 Sinistres.  Bug: 8820
   ***********************************************************************/
   FUNCTION f_ins_documentos(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      pcidioma IN NUMBER,
      pntramit IN NUMBER DEFAULT 0,
      pfreclama IN DATE DEFAULT NULL)
      RETURN NUMBER;

   -- INI RLLF 09/12/2015 0038723: Al siniestrar la pÃ³liza de Vida individual afectando la cobertura de ITP FinalizaciÃ³n del siniestro
   FUNCTION f_accion_siniestro_gar(
      pnsinies IN sin_siniestro.nsinies%TYPE,
	  paccion IN NUMBER,
      pcgarant IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
   -- FIN RLLF 09/12/2015 0038723: Al siniestrar la pÃ³liza de Vida individual afectando la cobertura de ITP FinalizaciÃ³n del siniestro

   -- INI RLLF 09/12/2015 0038723: Al siniestrar la pÃ³liza de Vida individual afectando la cobertura de ITP FinalizaciÃ³n del siniestro
   FUNCTION f_accion_siniestro(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      paccion IN NUMBER)
      RETURN NUMBER;
   -- FIN RLLF 09/12/2015 0038723: Al siniestrar la pÃ³liza de Vida individual afectando la cobertura de ITP FinalizaciÃ³n del siniestro

   FUNCTION f_reajustar_ctaseguro(
      p_nsinies IN sin_siniestro.nsinies%TYPE,
      p_sseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_constar_fallecimiento(
      vsseguro IN NUMBER,
      vsproduc IN NUMBER,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      vfsinies IN DATE)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_ins_causa
         Inserta a la taula SIN_CODCAUEST i SIN_DESCAUEST.
         param in pccauest : CÃ³digo Causa Estado
         param in pcestsin : CÃ³digo Estado Siniestro
         param in pcidioma : CÃ³digo Idioma
         param in ptcauest : CÃ³digo Estado Siniestro
         return            : 0 -> Tot correcte
                             1 -> S'ha produit un error
      31/07/2009   XVM                 Sinistres.  Bug: 8820
   *************************************************************************/
   FUNCTION f_ins_causa(
      pccauest IN NUMBER,
      pcestsin IN NUMBER,
      pcidioma IN NUMBER,
      ptcauest IN VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_get_causas
         Recupera de la tabla SIN_CODCAUEST y SIN_DESCAUEST las causas
         param in pccauest : CÃ³digo Causa Estado
         param in pcestsin : CÃ³digo Estado Siniestro
         param in ptcauest : DescripciÃ³n Estado
         param in pcidioma : CÃ³digo Idioma
         return            : 0 -> Tot correcte
                             1 -> S'ha produit un error
      31/07/2009   XVM                 Sinistres.  Bug: 8820
   *************************************************************************/
   FUNCTION f_get_causas(
      pccauest IN NUMBER,
      pcestsin IN NUMBER,
      ptcauest IN VARCHAR2,
      pcidioma IN NUMBER,
      vsquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_get_causa
         Recupera de la tabla SIN_CODCAUEST y SIN_DESCAUEST las causas
         param in pccauest : CÃ³digo Causa Estado
         param in pcestsin : CÃ³digo Estado Siniestro
         param in ptcauest : DescripciÃ³n Estado
         param in pcidioma : CÃ³digo Idioma
         return            : 0 -> Tot correcte
                             1 -> S'ha produit un error
      31/07/2009   XVM                 Sinistres.  Bug: 8820
   *************************************************************************/
   FUNCTION f_get_causa(pccauest IN NUMBER, pcestsin IN NUMBER, vsquery OUT VARCHAR2)
      RETURN NUMBER;

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
   FUNCTION f_del_causa(pccauest IN NUMBER, pcestsin IN NUMBER)
      RETURN NUMBER;

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
   FUNCTION f_del_detcausa(pccauest IN NUMBER, pcestsin IN NUMBER, pcidioma IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_reabrir_sin
         Reabre el siniestro.
         param in pnsinies : NÃºmero de siniestro.
         return            : 0 -> Tot correcte
                             1 -> S'ha produit un error
      04/08/2009   JPJ                 Sinistres.
   ***********************************************************************/
   FUNCTION f_reabrir_sin(pnsinies IN sin_siniestro.nsinies%TYPE)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_inicializa_sin
         Inicializa un siniestro.
         param in psseguro : SeqÃ¼encial asseguranÃ§a.
         param in pnriesgo : NÃºmero risc.
         param in pcgarant : Codi garantia.
         param in pfsinies : Data sinistre.
         param in pfnotifi : Data notificaciÃ³ sinistre.
         param in ptsinies : DescripciÃ³ sinistre.
         param in pccausin : Causa sinistre.
         param in pcmotsin : Motiu sinistre.
         param in pcsubest : Subestat sinistre.
         param out pnsinies : NÃºmero sinistre.
         param out pnmovsin : NÃºmero moviment sinistre.
         param out pnmovtra : NÃºmero moviment tramitaciÃ³ sinistre.
         return            : 0 -> Tot correcte
                             1 -> S'ha produit un error
      04/08/2009   JPJ                 Sinistres.
   ***********************************************************************/
   FUNCTION f_inicializa_sin(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN riesgos.nriesgo%TYPE,
      pcgarant IN codigaran.cgarant%TYPE,
      pfsinies IN sin_siniestro.fsinies%TYPE,
      pfnotifi IN sin_siniestro.fnotifi%TYPE,
      ptsinies IN sin_siniestro.tsinies%TYPE,
      pccausin IN sin_codmotcau.ccausin%TYPE,
      pcmotsin IN sin_codmotcau.cmotsin%TYPE,
      pcsubest IN sin_tramita_movimiento.csubtra%TYPE,
      pnsinies OUT sin_siniestro.nsinies%TYPE,
      pnmovsin OUT sin_movsiniestro.nmovsin%TYPE,
      pntramit OUT sin_tramitacion.ntramit%TYPE,
      -- Ini Bug 26676 -- ECP -- 14/05/2013
      pdiafinv NUMBER DEFAULT 0,
      pskipfanulac NUMBER DEFAULT 0
                                   -- Fin Bug 26676 -- ECP -- 14/05/2013
   )
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_descausa
         Reabre el siniestro.
         param in pnsinies : NÃºmero de siniestro.
         return            : 0 -> Tot correcte
                             1 -> S'ha produit un error
      04/08/2009   JPJ                 Sinistres.
   ***********************************************************************/
   FUNCTION f_descausa(
      pccausin IN sin_descausa.ccausin%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      tnom IN OUT sin_descausa.tcausin%TYPE)
      RETURN NUMBER;

    /***********************************************************************
      Recupera los datos del documento siniestro
      param in pcdocume: CÃ³digo del documento
      param in pcidioma : CÃ³digo del idioma
      param out pttitdoc: Nombre identificativo Documento
      param out ptdocume : DescripciÃ³n Documento
      return              : 0 OK
                            1 Error
   ***********************************************************************/
   FUNCTION f_get_documentos(
      pcdocume IN NUMBER,
      pcidioma IN NUMBER,
      pttitdoc OUT VARCHAR2,
      ptdocume OUT VARCHAR2)
      RETURN NUMBER;

   /***********************************************************************
      Recupera el ttitdoc de la tabla DOC_DESDOCUMENTO
      param  in  pcdocume : cÃ³digo documento

      return              : 0 -> Tot correcte
                            1 -> S'ha produit un error

      06/10/2009   DCT                 Sinistres.  Bug: 10393
   ***********************************************************************/
   FUNCTION f_get_ttitdoc(pcdocume IN NUMBER, pcidioma IN NUMBER, pttitdoc OUT VARCHAR)
      RETURN NUMBER;

   /**************************************************************************
      FunciÃ³n que devuelve el sperson de la persona siniestrada.
      Si el producto es a 2_Cabezas, el sperson se busca de la tabla ASEGURADOS,
      sino de la tabla RIESGOS
      param  in  pnsinies : Numero siniestro

      return              : 0 -> Tot correcte
                            1 -> S'ha produit un error
   ***********************************************************************/
   FUNCTION ff_sperson_sinies(pnsinies IN sin_siniestro.nsinies%TYPE)
      RETURN NUMBER;

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
      pctipcap OUT sin_tramita_destinatario.ctipcap%TYPE)
      RETURN NUMBER;

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
       param out pcpaise  : Codigo de identificafiÃ³n del pago

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
      pipago OUT sin_tramita_pago.isinret%TYPE)
      RETURN NUMBER;

   /**************************************************************************
      FunciÃ³n que inserta un pago
      param in  pnsinies : nÃºmero de siniestro
      param in  pntramit : nÃºmero de tramitacion
      param in  pctipres : cÃ³digo del tipo de reserva
      param in  pnmovres : numero de movimiento
      param in  psproduc : CÃ³digo de producto
      param in  pcactivi : CÃ³digo de la actividad
      param in  pcgarant : cÃ³digo de la garantia
      param out pfperini : fecha inicio periodo

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
      pfperini OUT sin_tramita_reserva.fresini%TYPE)
      RETURN NUMBER;
/**************************************************************************
      Funcion amparo
      param in  pnsinies : nÃƒÂºmero de siniestro
      param in  pntramit : nÃƒÂºmero de tramitacion
      
      param in  pcgarant : cÃƒÂ³digo de la garantia
      return              : 0 -> Tot correcte
                            Codigo error -> S'ha produit un error
      Bug 12207 - 01/02/2010 - AMC
   ***********************************************************************/
   FUNCTION f_del_amparo(
      pnsinies IN sin_tramita_amparo.nsinies%TYPE,
      pntramit IN sin_tramita_amparo.ntramit%TYPE,
      pcgarant IN sin_tramita_amparo.cgarant%TYPE)
      RETURN NUMBER;
   /**************************************************************************
      FunciÃ³n que borrar el ultimo movimiento de una reserva si no tiene pagos
      param in  pnsinies : nÃºmero de siniestro
      param in  pntramit : nÃºmero de tramitacion
      param in  pctipres : cÃ³digo del tipo de reserva
      param in  pnmovres : Numero de movimiento
      param in  pcgarant : cÃ³digo de la garantia

      return              : 0 -> Tot correcte
                            Codigo error -> S'ha produit un error

      Bug 12207 - 01/02/2010 - AMC
   ***********************************************************************/
   FUNCTION f_del_ultreserva(
      pnsinies IN sin_tramita_pago.nsinies%TYPE,
      pntramit IN sin_tramita_pago.ntramit%TYPE,
      pctipres IN sin_tramita_reserva.ctipres%TYPE,
      pctipgas IN sin_tramita_reserva.ctipgas%TYPE,   -- 26108
      pnmovres IN sin_tramita_reserva.nmovres%TYPE,
      pcgarant IN sin_tramita_reserva.cgarant%TYPE)
      RETURN NUMBER;

   /**************************************************************************
      FunciÃ³n que comprueba la modificacion de la fresfin de una reserva
      param in  pnsinies : nÃºmero de siniestro
      param in  pntramit : nÃºmero de tramitacion
      param in  pctipres : cÃ³digo del tipo de reserva
      param in  pcgarant : cÃ³digo de la garantia
      param in  pfresfin : Fecha fin de la reserva
      param out pfresfin_out : Fecha permitida como fecha fin reserva

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
      pfresfin_out OUT sin_tramita_reserva.fresfin%TYPE)
      RETURN NUMBER;

      /*************************************************************************
      FUNCTION f_pago_aut
      Crea un pago automÃ¡tico
      param in pdata     : fecha final de pago
      param in pncobros  : NÃºmero de cobros
      param in p_nsinies : NÃºmero siniestro (opcional)
      param in p_ntramit : NÃºmero tramit(opcional)
      param in p_ctipres : Tipus reserva (opcional)
      param out psproces : Num. proceso
      param in idres     : Identificador de reserva sobre la que realizamos el pago
      return             : cÃ³digo de error

      Bug 12207 - 08/02/2010 - AMC
      Bug 0016285 - 15/10/2010 - JMF: Afegir p_ntramit i p_ctipres
      Bug 0031294 - 04/07/2014 - JTT: Afegir idres
   *************************************************************************/
   FUNCTION f_pago_aut(
      p_data IN DATE,
      pncobros OUT NUMBER,
      p_nsinies IN VARCHAR2 DEFAULT NULL,
      p_ntramit IN NUMBER DEFAULT NULL,
      p_ctipres IN NUMBER DEFAULT NULL,
      p_ctipgas IN NUMBER DEFAULT NULL,   -- 26108
      pwhere IN VARCHAR2 DEFAULT NULL,
      pcempres IN NUMBER DEFAULT NULL,
      pcgarant IN NUMBER DEFAULT NULL,
      psproces OUT NUMBER,
      pidres IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /**************************************************************************
      FunciÃ³n que borra el detalle de un pago
      param in  psidepag : numero de pago
      param in  pnsinies : nÃºmero de siniestro
      param in  pntramit : nÃºmero de tramitacion
      param in  pctipres : cÃ³digo del tipo de reserva
      aram in  pcgarant : cÃ³digo de la garantia
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
      pnorden IN sin_tramita_pago_gar.norden%TYPE)
      RETURN NUMBER;

   /**************************************************************************
      FunciÃ³n que tira atras el pago de un siniestro
      param in  pnsinies : nÃºmero de siniestro
      param in  psidepag : nÃºmero de pago

      return              : 0 -> Tot correcte
                            Codigo error -> S'ha produit un error

      Bug 13312 - 09/03/2010 - AMC
   ***********************************************************************/
   FUNCTION f_del_ins_rea(pnsinies IN VARCHAR2, psidepag IN NUMBER)
      RETURN NUMBER;

   /**************************************************************************
       FunciÃ³n que borra una tramitacion
       param in  pnsinies : nÃºmero de siniestro
       param in  pntramit : nÃºmero de tramitacion
       param in  pctiptra : numero de tipo de tramitacion

       return              : 0 -> Tot correcte
                             Codigo error -> S'ha produit un error

      Bug 12668 - 03/03/2010 - AMC
   ***********************************************************************/
   FUNCTION f_del_tramitacion(pnsinies IN VARCHAR2, pntramit IN NUMBER, pctiptra IN NUMBER)
      RETURN NUMBER;

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
      return              : 0 -> Tot correcte
                            Codigo error -> S'ha produit un error

      Bug 14490 - 19/05/2010 - AMC
   ***********************************************************************/
   FUNCTION f_mov_reserva(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pctipres IN NUMBER,
      pctipgas IN NUMBER,   -- 26108
      pcgarant IN NUMBER,
      pnmovres IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pmodificable OUT NUMBER)
      RETURN NUMBER;

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
      pmodificable OUT NUMBER)
      RETURN NUMBER;

   /**************************************************************************
      FunciÃ³n que devuelve si se debe generar la reserva y el destinatario
      param in  pccausin  : nÃºmero de siniestro
      param in  pcmotsin  : nÃºmero de tramitacion
      param in  pcgarant  : CÃ³digo de la garantia
      param in  psproduc  : Codigo del producto
      param in  pcactivi  : Codigo de la actividad
      param out pgenerar : 0 - No se genera
                           1 - Se genera
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
      pgenerar OUT NUMBER)
      RETURN NUMBER;

   /**************************************************************************
      FunciÃ³n que devuelve el capital de una garantia
      param in  pcgarant  : CÃ³digo de la garantia
      param in  psseguro  : CÃ³digo del seguro
      param in  pnsinies  : CÃ³digo del siniestro
      param out pcapital  : Capital de la garantia
      param in pcmoneda   : Moneda en la que se busca el capital
      return              : 0 -> Tot correcte
                           Codigo error -> S'ha produit un error

      Bug 14816 - 02/06/2010 - AMC
   ***********************************************************************/
   FUNCTION f_get_capitalgar(
      pcgarant IN NUMBER,
      psseguro IN NUMBER,
      pnsinies IN VARCHAR2,
      pcapital OUT NUMBER,
      pcmoneda IN VARCHAR2 DEFAULT NULL)   -- BUG 18423 - 16/01/2012 - JMP - Multimoneda
      RETURN NUMBER;

   /*************************************************************************
        funciÃ³n borra todo el objeto ciatcion de tramitaciones
        param in pnsinies : numero de siniestro
        param in pntramit : numero de siniestro
        param in pncitacion : numero citacion

   *************************************************************************/
   FUNCTION f_del_citacion(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pncitacion IN NUMBER)
      RETURN NUMBER;

  /*************************************************************************
        funciÃ³n borra todo el objeto destinatario de tramitaciones
        param in pnsinies : numero de siniestro
        param in pntramit : numero de siniestro
        param in pctipdes : tipo de destinatario
        param in psperson : codigo de destinario

        Bug 14766 - 03/06/2010 - AMC
   *************************************************************************/
   FUNCTION f_del_destinatario(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pctipdes IN NUMBER,
      psperson IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
         funciÃ³n genera pagos renta automÃ¡tico
         param in pmes : mes a generar pagos
         param in panyo : aÃ±o a generar pagos
         param in pcgarant : cÃ³digo de garantia
         param out pncobros : pagos generados
         param out psproces : Num. proceso

         Bug 0014347 - 07/06/2010 - FAL
    *************************************************************************/
   FUNCTION f_pago_renta_aut(
      pmes IN NUMBER,
      panyo IN NUMBER,
      pcgarant IN NUMBER,
      pncobros OUT NUMBER,
      pwhere IN VARCHAR2 DEFAULT NULL,
      pcempres IN NUMBER DEFAULT NULL,   -- Bug 15044 - 08/11/2010 - XPL
      psproces OUT NUMBER   -- Bug 16580 - 15/11/2010 - AMC
                         )
      RETURN NUMBER;

   -- Bug 0014185 - JRH - 15/06/2010 - Alta PrestaciÃ³n
    /*************************************************************************
      FUNCTION F_Ins_Prestacion
         Inserta a la taula PRESTAREN dels parÃ metres informats.
         param in pnsinies: nÃºmero del sinistre
         param in psperson: implicat
         param in pctipdur: tipus data fi
         param in pnpartot: participacions totals
         param in pnpartpend : participacions pendents
         param in pCFORPAG: forma de pagament
         param in pIBRUREN: renda
         param in pFPPREN : Data primera renda
         param in crevali : Tipo reval renta
         param in prevali : % reval
         param in irevali : Importe reval
         param in pctipban : Tipo cuenta
         param in cbancar : Cuenta de la prestaciÃ³n
         pFechaFin IN DATE: Da fi de la renda en cas de pctipdur=3
         return              : 0 -> Tot correcte
                               1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_ins_prestacion(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      -- Bug 0015669 - JRH - 30/09/2010 - Alta prestaciones
      pntramit IN NUMBER,
      psperson IN per_personas.sperson%TYPE,
      pctipdes IN NUMBER,
      -- Fi Bug 0015669 - JRH - 30/09/2010
      pcforpag IN NUMBER,
      pibruren IN NUMBER,
      pfppren IN DATE,
      pnpartot IN NUMBER,
      pnpartpend IN NUMBER,
      pctipdur IN NUMBER,
      pfechafin IN DATE,
      pctipban IN NUMBER,
      pcbancar IN VARCHAR2,
      pcrevali IN NUMBER DEFAULT 0,
      pprevali IN NUMBER DEFAULT 0,
      pirevali IN NUMBER DEFAULT 0,
      -- Bug 0015669 - JRH - 30/09/2010 - Alta prestaciones
      pnmesextra IN VARCHAR2 DEFAULT NULL,
      -- Bug 18286 - APD - 20/04/2011 - el estado inicial de la prestacion
      -- debe ser 4.-Pendiente de activar (en vez de 0.-Activa)
      pcestado IN NUMBER DEFAULT 4,
      pcmotivo IN NUMBER DEFAULT NULL,
      pcblopag IN NUMBER DEFAULT 0,
      pnpresta IN NUMBER DEFAULT NULL
                                     -- Fi Bug 0015669 - JRH - 30/09/2010
   )
      RETURN NUMBER;

   /*************************************************************************
        funciÃ³n borra un apunte de la agenda
        param in pnsinies : numero de siniestro
        param in pntramit : numero de siniestro
        param in pnlinage : numero de linea

        Bug 15153 - 23/06/2010 - AMC
   *************************************************************************/
   FUNCTION f_del_agenda(pnsinies IN VARCHAR2, pntramit IN NUMBER, pnlinage IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
        funciÃ³n que devuelve la descripciÃ³n del tipo de tramitaciÃ³n
        param in pnsinies : numero de siniestro
        param in pntramit : numero de siniestro
        param in pctiptra : codigo tipo tramitaciÃ³n
        param out destiptram : descripciÃ³n de la tramitaciÃ³n

        Bug 15260 - 02/07/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_tipustram(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pctiptra IN NUMBER,
      pcidioma IN NUMBER,
      pdestiptram OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
        funciÃ³n que devuelve la descripciÃ³n del tipo de tramitaciÃ³n
        param in pnsinies : numero de siniestro
        param in pntramit : numero de siniestro
        param in pctiptra : codigo tipo tramitaciÃ³n

        Bug 15260 - 05/07/2010 - AMC
   *************************************************************************/
   FUNCTION ff_get_tipustram(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pctiptra IN NUMBER,
      pcidioma IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
        funciÃ³n que devuelve la descripciÃ³n del subtipo de tramitaciÃ³n
        param in pctiptra    : codigo tipo tramitaciÃ³n
        param in pcsubtiptra : codigo subtipo tramitaciÃ³n
        param in pcidioma    : codigo idioma
        -- BUG 0023536 - 24/10/2012 - JMF
   *************************************************************************/
   FUNCTION ff_get_subtipustram(pctiptra IN NUMBER, pcsubtiptra IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_consulta_lstsini_riesgo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnidioma IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

   -- BUG 0015669 - 08/2010 - JRH  -  Alta prestacions en forma de renda (PL)

   /*************************************************************************

        f_get_prestaren

        funciÃ³n obtiene prestaciÃ³n
        param in pnsinies : numero de siniestro
        param in pntramit : numero de tramite
         param in psperson : codigo de destinario
        param in pctipdes : tipo de destinatario
        param in pidioma  : codigo de destinario
        param out vsquery  : query

        retorna 0 si todo ha ido bien
   *************************************************************************/
   FUNCTION f_get_prestaren(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pctipdes IN NUMBER,
      pidioma IN NUMBER,
      vsquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************

          f_del_prestaren

          funciÃ³n borra una prestaciÃ³n
          param in pnsinies : numero de siniestro
          param in pntramit : numero de siniestro
          param in pctipdes : tipo de destinatario
          param in psperson : codigo de destinario

          retorna 0 si todo ha ido bien
     *************************************************************************/
   FUNCTION f_del_prestaren(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pctipdes IN NUMBER,
      pnpresta IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************

        f_est_faseprestdesti

        funciÃ³n indica si destinatario estÃ¡ en fase de prestaciÃ³n
        param in pnsinies : numero de siniestro
        param in pntramit : numero de tramite
        param in psperson : codigo de destinario
        param in pctipdes : tipo de destinatario
        param out pfaseprest : Indica si estÃ¡ en fase de pretaciÃ³n

        retorna 0 si todo ha ido bien
   *************************************************************************/
   FUNCTION f_est_faseprestdesti(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pctipdes IN NUMBER,
      pfaseprest OUT BOOLEAN)
      RETURN NUMBER;

   /*************************************************************************

          f_est_faseprest

          funciÃ³n indica cuantos destinatarios estan en fase de prestaciÃ³n para una pÃ³liza
          param in psseguro : numero de segur
          param out Pnumprest : numero de destinatarios en fase de prestaciÃ³n

          retorna 0 si todo ha ido bien
     *************************************************************************/
   FUNCTION f_est_faseprest(psseguro IN NUMBER, pfaseprest OUT NUMBER)
      RETURN NUMBER;

-- Fi BUG 0015669 - 08/2010 - JRH
   /*************************************************************************
        funciÃ³n que devuelve la descripciÃ³n del tipo de tramitaciÃ³n
        param in p_nsinies : numero de siniestro
        param in p_cgarant : cÃ³digo de garantia
        param in p_ireserv : Importe Reserva Pendiente
        return             : 0=Tot correcte, Codigo error

        Bug 0016176 - 07/10/2010 - JMF
   *************************************************************************/
   FUNCTION f_val_reserva_capitales(
      p_nsinies IN VARCHAR2,
      p_cgarant IN NUMBER,
      p_ireserv IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_get_productos_pagos
      Nos devuelve los productos de RENTAS o BAJA
      param in pcempres    : Empresa
      param in idioma   : Idioma
      param in pfiltro   : 1 REntas, 2 Bajas
      return           : cÃ³digo de error

       ---- Bug 15044 - 08/11/2010 - XPL
   *************************************************************************/
   FUNCTION f_get_productos_pagos(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pfiltro IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

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
   FUNCTION f_get_tramitador_defecto(
      p_cempres IN NUMBER,
      p_cuser IN VARCHAR2,
      p_sseguro IN NUMBER,
      p_ccausin IN NUMBER,
      p_cmotsin IN NUMBER,
      p_nsinies IN VARCHAR2,
      p_ntramte IN NUMBER,
      p_ntramit IN NUMBER,
      p_cunitra OUT VARCHAR2,
      p_ctramitad OUT VARCHAR2)
      RETURN NUMBER;

-- BUG16506:DRA:14/12/2010:Fi

   -- Ini bug 16924 - SRA - 16/12/2010
   FUNCTION f_estadotram_alta_sini(
      pnsinies IN siniestros.nsinies%TYPE,
      pobsiniestro IN OUT ob_iax_siniestros)
      RETURN NUMBER;

-- Fin bug 16924 - SRA - 16/12/2010
   -- Bug 18286 - APD - 19/04/2011 - se crea la funcion
   -- Devuelve el estado del siniestro
   FUNCTION f_get_estado_siniestro(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pfecha IN DATE DEFAULT f_sysdate)
      RETURN NUMBER;

-- Fin Bug 18286 - APD - 19/04/2011

   -- Bug 18286 - APD - 19/04/2011 - se crea la funcion
   -- Cambia el estado de la prestacion
   FUNCTION f_estado_prestacion(
      pnsinies IN prestaren.nsinies%TYPE,
      pcestsin IN sin_movsiniestro.cestsin%TYPE,
      pcestsin_ant IN sin_movsiniestro.cestsin%TYPE DEFAULT NULL,
      pntramit IN prestaren.ntramit%TYPE DEFAULT NULL,
      psperson IN prestaren.sperson%TYPE DEFAULT NULL,
      pctipdes IN prestaren.ctipdes%TYPE DEFAULT NULL,
      psseguro IN prestaren.sseguro%TYPE DEFAULT NULL)
      RETURN NUMBER;

-- Fin Bug 18286 - APD - 19/04/2011

   -- Bug 18286 - APD - 19/04/2011 - se crea la funcion
   -- Devuelve el numero de prestaciones (activas)
   FUNCTION f_num_prestaciones(
      psseguro IN prestaren.sseguro%TYPE,
      psperson IN prestaren.sperson%TYPE DEFAULT NULL,
      pnsinies IN prestaren.nsinies%TYPE DEFAULT NULL,
      pntramit IN prestaren.ntramit%TYPE DEFAULT NULL,
      pctipdes IN prestaren.ctipdes%TYPE DEFAULT NULL)
      RETURN NUMBER;

-- Fin Bug 18286 - APD - 19/04/2011

   -- Bug 18670 - APD - 15/06/2011 - se crea la funcion
   -- Devuelve la forma de prestaciÃ³n por defecto
   FUNCTION f_get_fprestdefecto(
      psproduc IN fprestaprod.sproduc%TYPE,
      pccausin IN fprestaprod.ccausin%TYPE DEFAULT NULL,
      pcmotsin IN fprestaprod.cmotsin%TYPE DEFAULT NULL,
      pcgarant IN fprestaprod.cgarant%TYPE DEFAULT NULL,
      pctippres OUT fprestaprod.ctippres%TYPE)
      RETURN NUMBER;

-- Fin Bug 18670 - APD - 15/06/2011
   -- Ini Bug 18554  - SRA - 06/06/2011
   /*************************************************************************
      FunciÃ³n que devuelve el Ãºltimo estado de un pago de siniestro.
      param in psidepag     : identificador del pago
      return                : estado del pago
   *************************************************************************/
   FUNCTION f_get_cestpag(psidepag IN sin_tramita_movpago.sidepag%TYPE)
      RETURN sin_tramita_movpago.cestpag%TYPE;

   /*************************************************************************
      Dado un siniestro y una tramitaciÃ³n del mismo, esta funciÃ³n devuelve el
      Ãºltimo estado en que se encuentra dicha tramitaciÃ³n
      param in pnsinies     : nÃºmero de siniestro
      param in pntramit     : nÃºmero de tramitaciÃ³n
      return                : estado del pago
   *************************************************************************/
   FUNCTION f_get_cesttra(
      pnsinies IN sin_tramita_movimiento.nsinies%TYPE,
      pntramit IN sin_tramita_movimiento.ntramit%TYPE)
      RETURN sin_tramita_movimiento.cesttra%TYPE;

-- Ini Bug 18554  - SRA - 06/06/2011
   /*************************************************************************
      Dado una causa de siniestro, se retorna la descripciÃ³n correspondiente
      pccausin in sin_descausa.ccausin%TYPE   : cÃ³digo de causa del siniestro
      pcidioma int sin_descausa.cidioma%TYPE  : cÃ³digo de idioma
      return                                  : descripciÃ³n de la causa del siniestro
   *************************************************************************/
   FUNCTION ff_descausa(
      pccausin IN sin_descausa.ccausin%TYPE,
      pcidioma IN sin_descausa.cidioma%TYPE)
      RETURN sin_descausa.tcausin%TYPE;

   /*************************************************************************
     Dado una causa y motivo de siniestro, se retorna la descripciÃ³n correspondiente
     pccausin in sin_desmotcau.ccausin%type : cÃ³digo de causa del siniestro
     pcmotsin in sin_desmotcau.cmotsin%type : cÃ³digo de motivo del siniestro
     pcidioma in sin_desmotcau.cidioma%type : cÃ³digo de idioma
     return                                 : descripciÃ³n del motivo del siniestro
   *************************************************************************/
   FUNCTION ff_desmotcausa(
      pccausin IN sin_desmotcau.ccausin%TYPE,
      pcmotsin IN sin_desmotcau.cmotsin%TYPE,
      pcidioma IN sin_desmotcau.cidioma%TYPE)
      RETURN sin_desmotcau.tmotsin%TYPE;

   /*************************************************************************
      Dado un siniestro, se devuelve una consulta dinÃ¡mica que recupera los datos histÃ³ricos del siniestro
      que se estÃ¡ consultando
      param in pnsinies     : nÃºmero de siniestro
      ptquery out varchar2  : texto de la consulta
      return                : estado del pago
   *************************************************************************/
   FUNCTION f_get_hissin_siniestros(
      pnsinies IN sin_tramita_movimiento.nsinies%TYPE,
      ptquery OUT VARCHAR2)
      RETURN NUMBER;

-- Fin Bug 18554  - SRA - 06/06/2011

   /***********************************************************************
      FUNCTION f_get_pagogar_modif
      param in  sidepag  : nÃºmero tipo pago
      param out esmodif  : 1 es pot modificar, 0 no es pot
      return              : 0 OK
                            1 Error
      --BUG19006 - JTS - 19/07/2011
   ***********************************************************************/
   FUNCTION f_get_pagogar_modif(psidepag IN NUMBER, esmodif OUT NUMBER)
      RETURN NUMBER;

   /***********************************************************************
     FUNCTION F_ULTIMO_PAGO:
      Crea las acciones a realizar una vez el Ãºltimo pago estÃ¡ pagado
      param in pnsinies : NÃºmero siniestro
      param in pntramit : NÃºmero tramitaciÃ³n del pago
      param in pcesttra : CÃ³digo estado
      param in pcempres : Codigo empresa
      param in psseguro : Codigo seguro
      param in pccausin : Codigo causa siniestro
      param in pcmotsin : Codigo motivo siniestro
      return              : 0 -> Todo correcto
                            1 -> Se ha producido un error
      Bug 18934 - 29/09/2011 - MDS
   ***********************************************************************/
   FUNCTION f_ultimo_pago(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pcesttra IN NUMBER,
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_get_juzgado
         Recupera un juzgado
         param in pnsinies  : nÃºmero del siniestro
         param in pntramit  : nÃºmero tramitaciÃ³n siniestro
         param in pnlinjuz  : nÃºmero de lÃ­nea de juzgado
         param out vsquery  : texto consulta
         return             : 0 -> Todo correcto
                              1 -> Se ha producido un error
      Bug 19821 - 10/11/2011 - MDS
   *************************************************************************/
   FUNCTION f_get_juzgado(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pnlinjuz IN NUMBER,
      pcidioma IN NUMBER,
      vsquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_ins_juzgado
         Inserta un juzgado
         param in pnsinies  : nÃºmero del siniestro
         param in pntramit  : nÃºmero tramitaciÃ³n siniestro
         param in pnlinjuz  : nÃºmero de lÃ­nea de juzgado
         ...
         ...
         ...
         return             : 0 -> Todo correcto
                              1 -> Se ha producido un error
      Bug 19821 - 10/11/2011 - MDS
   *************************************************************************/
   FUNCTION f_ins_juzgado(
      pnsinies IN sin_siniestro.nsinies%TYPE,
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
      pfcancel IN DATE)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_del_juzgado
         Borra un juzgado
         param in pnsinies  : nÃºmero del siniestro
         param in pntramit  : nÃºmero tramitaciÃ³n siniestro
         param in pnlinjuz  : nÃºmero de lÃ­nea de juzgado
         return             : 0 -> Todo correcto
                              1 -> Se ha producido un error
      Bug 19821 - 10/11/2011 - MDS
   *************************************************************************/
   FUNCTION f_del_juzgado(pnsinies IN VARCHAR2, pntramit IN NUMBER, pnlinjuz IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_get_demand
         Recupera un demandante/demandado
         param in pnsinies  : nÃºmero del siniestro
         param in pntramit  : nÃºmero tramitaciÃ³n siniestro
         param in pnlindem  : nÃºmero de lÃ­nea de demandante/demandado
         param out vsquery  : texto consulta
         return             : 0 -> Todo correcto
                              1 -> Se ha producido un error
      Bug 19821 - 10/11/2011 - MDS
   *************************************************************************/
   FUNCTION f_get_demand(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN NUMBER,
      pnlindem IN NUMBER,
      pntipodem IN NUMBER,
      pcidioma IN NUMBER,
      vsquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_ins_demand
         Inserta un demandante/demandado
         param in pnsinies  : nÃºmero del siniestro
         param in pntramit  : nÃºmero tramitaciÃ³n siniestro
         param in pnlindem  : nÃºmero de lÃ­nea de demandante/demandado
         ...
         ...
         ...
         return             : 0 -> Todo correcto
                              1 -> Se ha producido un error
      Bug 19821 - 10/11/2011 - MDS
   *************************************************************************/
   FUNCTION f_ins_demand(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit NUMBER,
      pnlindem NUMBER,
      psperson NUMBER,
      pntipodem NUMBER,
      pttramita VARCHAR2,
      psperson2 NUMBER,
      pnprocedi VARCHAR2,
      ptcompani VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_del_demand
         Borra un demandante/demandado
         param in pnsinies  : nÃºmero del siniestro
         param in pntramit  : nÃºmero tramitaciÃ³n siniestro
         param in pnlindem  : nÃºmero de lÃ­nea de demandante/demandado
         return             : 0 -> Todo correcto
                              1 -> Se ha producido un error
      Bug 19821 - 10/11/2011 - MDS
      Bug 20340/109094 - 15/03/2012 - AMC
   *************************************************************************/
   FUNCTION f_del_demand(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnlindem IN NUMBER,
      pntipodem IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_post_siniestro                    -- bug19416:ASN:14/12/2011
         Acciones automaticas para ejecutar al dar de alta un siniestro
         param in pnsinies  : nÃºmero del siniestro
         return             : codigo error
   *************************************************************************/
   FUNCTION f_post_siniestro(pnsinies IN sin_siniestro.nsinies%TYPE)
      RETURN NUMBER;

    /************************************************************************
      FUNCTION Esta funcion anula un siniestro dependiendo del movimiento de la poliza.
         param in psseguro  : nÃºmero del seguros
         param in pnmovimi  : nÃºmero del movimiento
         return             : codigo error
    **************************************************************************/
   -- Bug 19444 - RSC - 15/12/2011 - LCOL_T04: ParametrizaciÃ³n RehabilitaciÃ³n
   FUNCTION f_anu_sini_mov(psseguro IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************************************
       -Funcion que concluye un siniestro: finaliza, anula o rechaza un siniestro.
       -Si tiene pagos pendientes no se pueden realizar las operaciones de anulaciÃ³n y rechazo
       -Genera un apunte en la agenda del siniestro.
       -Realiza la insercion de la provision
       -Comprueva a ver si la poliza esta retenida por haber realizado un siniestro si es asi la deja en estado normal.
       TIPO : nos indica si se trata de un rechado de expediente o es anulacion.
                    1 - FinalizaciÃ³n
           2 - AnulaciÃ³n
           3 - Rechazo
   ***********************************************************************************************/
   FUNCTION f_finalizar_sini(
      pnsinies IN NUMBER,
      ptipo IN NUMBER,
      pccauest IN NUMBER,
      pfecha IN DATE,
      pliteral IN NUMBER,
      pcidioma IN NUMBER)
      RETURN NUMBER;

-- Fin bug 19444

   /*************************************************************************
      FUNCTION f_actualiza_pago
         Actualiza campos del pago
         param in psidepag       : identificador del pago
         param in pmediopago     : medio de pago
         param in preferencia    : NÃºmero Factura/Referencia
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
      piotrosgas   IN NUMBER DEFAULT NULL,
      pibaseipoc   IN NUMBER DEFAULT NULL,
      piipoconsumo IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
       FUNCTION f_gestiona_cobpag
          Llama a la interfaz de siniestros para insertar el pago de un siniestro en el host
          param in psidepag : seqÃ¼Ã©ncia identificador pagament
          param in pnmovpag : nÃºmero moviment pagament
          param in pcestpag : estat pagament
          param in pfefepag : data efecte pagament
          return            : 0 -> Tot correcte
                              1 -> S'ha produit un error
    *************************************************************************/
   FUNCTION f_gestiona_cobpag(
      psidepag IN NUMBER,
      pnmovpag IN NUMBER,
      pcestpag IN sin_tramita_movpago.cestpag%TYPE,
      pfefepag IN DATE,
      pfcontab IN DATE,
      psinterf OUT NUMBER)
      RETURN NUMBER;

   -- Ini Bug 21172 - MDS - 02/03/2012
   /*************************************************************************
       FUNCTION f_get_reserva_multiple
          Devuelve una query con las reservas efectuadas para un siniestro/trÃ¡mite/tipo reserva

          param in ptipoquery : Tipo query a realizar
          param in pnsinies   : NÃºmero de siniestro
          param in pntramit   : NÃºmero de trÃ¡mite
          param in pctipres   : CÃ³digo tipo de reserva
          param in pcidioma   : idioma
          param out vsquery
          return            : 0 -> Todo correcto
                              1 -> Se ha producido un error
    *************************************************************************/
   FUNCTION f_get_reserva_multiple(
      ptipoquery IN NUMBER,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramita_reserva.ntramit%TYPE,
      pctramit IN NUMBER,   --25812:ASN:24/01/2013
      pctipres IN sin_tramita_reserva.ctipres%TYPE,
      pcidioma IN NUMBER,
      vsquery OUT VARCHAR2)
      RETURN NUMBER;

-- Fin Bug 21172 - MDS - 02/03/2012

   /*************************************************************************
      FUNCTION f_get_defraudador
         Recupera un defraudador
         param in pnsinies  : nÃºmero de siniestro
         param in pndefrau  : nÃºmero de defraudador
         param in pcidioma  : idioma
         param out vsquery  : texto consulta
         return             : 0 -> Todo correcto
                              1 -> Se ha producido un error
      Bug 21855 - 07/05/2012 - MDS
   *************************************************************************/
   FUNCTION f_get_defraudador(
      pnsinies IN sin_defraudadores.nsinies%TYPE,
      pndefrau IN sin_defraudadores.ndefrau%TYPE,
      pcidioma IN NUMBER,
      vsquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_ins_defraudador
         Inserta un defraudador
         param in pnsinies  : nÃºmero de siniestro
         param in pndefrau  : nÃºmero de defraudador
         ...
         ...
         ...
         return             : 0 -> Todo correcto
                              1 -> Se ha producido un error
      Bug 21855 - 07/05/2012 - MDS
   *************************************************************************/
   FUNCTION f_ins_defraudador(
      pnsinies IN sin_defraudadores.nsinies%TYPE,
      pndefrau IN sin_defraudadores.ndefrau%TYPE,
      psperson IN sin_defraudadores.sperson%TYPE,
      pctiprol IN sin_defraudadores.ctiprol%TYPE,
      pfiniefe IN sin_defraudadores.finiefe%TYPE,
      pffinefe IN sin_defraudadores.ffinefe%TYPE)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_del_defraudador
         Borra un defraudador
         param in pnsinies  : nÃºmero de siniestro
         param in pndefrau  : nÃºmero de defraudador
         return             : 0 -> Todo correcto
                              1 -> Se ha producido un error
      Bug 21855 - 07/05/2012 - MDS
   *************************************************************************/
   FUNCTION f_del_defraudador(
      pnsinies IN sin_defraudadores.nsinies%TYPE,
      pndefrau IN sin_defraudadores.ndefrau%TYPE)
      RETURN NUMBER;

/***************************************************************************************************
       FUNCTION f_get_provision
         Devuelve el importe contra el que se ha de validar el limite del tramitador
         param in p_nsinies   : numero del siniestro
         param in p_ntramte   : numero tramite siniestro
         param in p_ntramit   : numero tramitacion siniestro
         param in out p_iprovis  : total provisionado
         return              : 0 -> Tot correcte
                               1 -> S'ha produit un error
 ***************************************************************************************************/
   FUNCTION f_get_provision(
      p_nsinies IN VARCHAR2,
      p_ntramte IN NUMBER,
      p_ntramit IN NUMBER,
      p_iprovis OUT NUMBER)
      RETURN NUMBER;

   /****************************************************************************
    Devuelve el maximo importe que puede asumir un tramitador
      pctramitad IN codigo tramitador
      pcempres IN   empresa
      pcramo   IN   ramo
      pccausin IN   causa siniestro
      pcmotsin IN   motivo siniestro
      pilimite OUT
      RETURN codigo de error
   ****************************************************************************/
   FUNCTION f_get_limite_tramitador(
      pctramitad IN VARCHAR2,
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      pilimite OUT NUMBER)
      RETURN NUMBER;

   /***************************************************************************************************
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
   ***************************************************************************************************/
   FUNCTION f_get_tramitador(
      p_nsinies IN VARCHAR2,
      p_ntramte IN NUMBER,
      p_ntramit IN NUMBER,
      p_cunitra OUT VARCHAR2,
      p_ctramitad OUT VARCHAR2)
      RETURN NUMBER;

   /****************************************************************************
    Comprueba si el tramitador puede asignarse a un siniestro
      pnsinies IN numero de siniestro
      pntramit IN tramitacion
      pctramitad IN codigo tramitador
      pcempres IN empresa
      pcramo   IN ramo
      pccausin IN causa siniestro
      pcmotsin IN motivo siniestro
      RETURN codigo de error
   ****************************************************************************/
   FUNCTION f_valida_tramitador(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pctramitad IN VARCHAR2,
      pcempres IN NUMBER,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER)
      RETURN NUMBER;

   /****************************************************************************
   Devuelve el nombre del tramitador
      pctramitad IN codigo tramitador
      22670:ASN:28/12/2012
   ****************************************************************************/
   FUNCTION f_nombre_tramitador(pctramitad IN VARCHAR2, ptnombre OUT VARCHAR2)
      RETURN NUMBER;

   /****************************************************************************
   Devuelve mensaje gestion asignada automaticamente en alta de siniestro
      pnsinies IN codigo siniestro
      pcidioma IN codigo idioma
      ASN : 11/07/2012 : 0022670: SIN - Mensajes en alta de siniestros
   ****************************************************************************/
   FUNCTION f_nombre_profesional(
      pnsinies IN VARCHAR2,
      pcidioma IN NUMBER,
      ptmensaje OUT VARCHAR2)
      RETURN NUMBER;

   /****************************************************************************
   Mira si hay reserva en el siniestro al final del alta y actualiza el estado
      pnsinies IN numero siniestro
      phay_reserva OUT - 0=no 1=si
      22603:ASN:18/07/2012
   ****************************************************************************/
   FUNCTION f_estado_final(pnsinies IN VARCHAR2, phay_reserva OUT NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_set_tramitador
         Graba el tramitador en el alta de siniestro
         param in pnsinies          : nÃºmero de siniestro
         param in pcunitra          : unidad tramitacion
         param in pctramtad         : tramitador
         return                     : 0 - OK ; 1 - Error
   *************************************************************************/
   FUNCTION f_set_tramitador(pnsinies IN NUMBER, pcunitra IN VARCHAR2, pctramitad IN VARCHAR2)
      RETURN NUMBER;

-- Ini Bug 23805 - MDS - 03/10/2012

   /*************************************************************************
    FunciÃ³n que indica si alguna de las garantÃ­as contratadas y
    seleccionadas segÃºn pccausin, pcmotsin, pfsinies tiene asistencia.

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
      phay_asistencia OUT NUMBER)
      RETURN NUMBER;

-- Fin Bug 23805 - MDS - 03/10/2012

   /****************************************************************************
    Recalcula la penalizacion antes de generar un pago

      pnsinies IN numero siniestro
      pntramit IN tramitacion
      pctipres IN tipo de reserva
      pcgarant IN garantia
      pfperini IN fecha inicio
      pfperfin IN fecha fin

      23764:ASN:15/10/2012 creacion
   ****************************************************************************/
   FUNCTION f_recalcula_penalizacion(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pctipres IN NUMBER,
      pcgarant IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_ireserva_ctramte
         Busca ultima reserva del codigo tramite o de todos.
         param in pnsinies          : nÃºmero de siniestro
         param in pctramte          : CÃ³digo tramite
         return                     : Importe reserva o vacio
   -- BUG 0023643 - 05/11/2012 - JMF
   *************************************************************************/
   FUNCTION f_ireserva_ctramte(pnsinies IN NUMBER, pctramte IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_cancela_reserva_global
         Anula la reserva global cuando se da de alta una reserva normal
         param in pnsinies          : nÃºmero de siniestro
         return                     : Importe reserva o vacio
   -- BUG 0022679 - 15/11/2012 - ASN
   *************************************************************************/
   FUNCTION f_cancela_reserva_global(pnsinies IN NUMBER, pntramit IN NUMBER)
      RETURN NUMBER;

   -- BUG 0024774 - 20/11/2012 - JMF
   FUNCTION f_indenta(psproduc IN NUMBER, pcactivi IN NUMBER, pcgarant IN NUMBER)
      RETURN NUMBER;

   -- BUG 0024774 - 20/11/2012 - JMF
   FUNCTION f_seleccionable(psproduc IN NUMBER, pcactivi IN NUMBER, pcgarant IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_padre_con_hijos(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_agente_npol(psseguro IN NUMBER, pcagente OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_preg_siniestro(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN VARCHAR2,
      pccausin IN NUMBER,   --27354:NSS:18/06/2013
      pcmotsin IN NUMBER,   --27354:NSS:18/06/2013
      pcidioma IN NUMBER,
      ptquery OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_resp_siniestro(
      pcpregun IN VARCHAR2,
      pcidioma IN NUMBER,
      ptquery OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_ins_pregunta(
      pnsinies IN sin_siniestro.nsinies%TYPE,   -- Bug 32428 - 30/09/2014 - JTT
      pcpregun IN NUMBER,
      pcrespue IN NUMBER,
      ptrespue IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_preguntas(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pnsinies IN sin_siniestro.nsinies%TYPE,   -- Bug 32428 - 30/09/2014 - JTT
      pcidioma IN NUMBER,
      ptquery OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_limpia_preguntas(pnsinies IN sin_siniestro.nsinies%TYPE)   -- Bug 32428 - 30/09/2014 - JTT
      RETURN NUMBER;

   FUNCTION f_get_lstlocaliza(pnsinies IN VARCHAR2, pntramit IN NUMBER, ptquery OUT VARCHAR2)
      RETURN NUMBER;

   -- BUG 0024742 - MDS - 18/07/2013
   FUNCTION f_indice_siniestralidad(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER DEFAULT 1,
      pcgarant IN NUMBER DEFAULT NULL,
      pfecha IN DATE DEFAULT NULL)
      RETURN NUMBER;

   --Ini Bug 24708:NSS:10/10/2013
   FUNCTION f_get_lstoficinas(
      pcbanco IN NUMBER,
      pcofici IN NUMBER,
      ptofici IN VARCHAR2,
      ptquery OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_beneficiario_designado(
      pnsinies IN VARCHAR2,
      psseguro IN NUMBER,
      ptquery OUT VARCHAR2)
      RETURN NUMBER;

--Fin Bug 24708:NSS:10/10/2013

   --Ini Bug 28506:NSS:16/10/2013
   FUNCTION f_get_garantias_dependientes(
      pgarantias IN VARCHAR2,
      pcempres IN NUMBER,
      ptquery OUT VARCHAR2)
      RETURN NUMBER;

--Fin Bug 28506:NSS:16/10/2013

   -- 0024708: (POSPG500)- Parametrizacion - Sinestros/0157275 actualizar preguntas
   FUNCTION f_actualiza_preguntas(
      pnsinies IN VARCHAR2,
      psseguro IN NUMBER,
      pfsinies IN DATE,
      pcmotsin IN NUMBER,
      pccausin IN NUMBER,
      pcidioma IN NUMBER)
      RETURN NUMBER;

-- 0024708: (POSPG500)- Parametrizacion - Sinestros/0157275 actualizar preguntas (Refresco de preguntas despuÃ©s de modificaciÃ³n cabecera siniestro)
   FUNCTION f_get_producto(pnsinies IN VARCHAR2, psproduc OUT NUMBER, pcactivi OUT NUMBER)
      RETURN NUMBER;

--Ini Bug 28506:NSS:28/10/2013
   FUNCTION f_get_inf_reaseguro(pnsinies IN VARCHAR2, pcidioma IN NUMBER, ptquery OUT VARCHAR2)
      RETURN NUMBER;

--Fin Bug 28506:NSS:28/10/2013

   --Ini Bug 29177/160128:NSS:13/01/2014
   FUNCTION f_ins_pago_contrato(
      psidepag IN NUMBER,
      pcdp IN VARCHAR2,
      ppospres IN VARCHAR2,
      pcrp IN VARCHAR2,
      pposcrp IN VARCHAR2,
      pcontrato IN VARCHAR2,
      pcgestor IN VARCHAR2)
      RETURN NUMBER;

--Fin Bug 29177/160128:NSS:13/01/2014

   --Ini Bug 29989/165377:NSS:13/02/2014
   FUNCTION f_accult_tramitacion(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pcempres IN NUMBER,
      pfsinfin IN DATE,
      pccauest IN NUMBER,
      pcesttra IN NUMBER)
--bug 29989/165377;NSS;23-04-2014
   RETURN NUMBER;

--Fin Bug 29989/165377:NSS:13/02/2014

   -- BUG 28830:NSS:06/11/2013 - CompensaciÃ³n de siniestros contra cartera.
   FUNCTION f_get_datos_pago(
      psidepag IN sin_tramita_pago.sidepag%TYPE,
      pntramit OUT sin_tramita_pago.ntramit%TYPE,
      psperson OUT sin_tramita_pago.sperson%TYPE,
      pctipdes OUT sin_tramita_pago.ctipdes%TYPE,
      pctippag OUT sin_tramita_pago.ctippag%TYPE,
      pisinret OUT sin_tramita_pago.isinret%TYPE,
      pcforpag OUT sin_tramita_pago.cforpag%TYPE,
      pfordpag OUT sin_tramita_pago.fordpag%TYPE,
      pcconpag OUT sin_tramita_pago.cconpag%TYPE,
      pccauind OUT sin_tramita_pago.ccauind%TYPE,
      pctipban OUT sin_tramita_pago.ctipban%TYPE,
      pcbancar OUT sin_tramita_pago.cbancar%TYPE,
      pcmonpag OUT sin_tramita_pago.cmonpag%TYPE,
      pcultpag OUT sin_tramita_pago.cultpag%TYPE)
      RETURN NUMBER;

   FUNCTION f_get_datos_pago_gar(
      psidepag IN sin_tramita_pago.sidepag%TYPE,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_detalle_pago(
      psidepag IN sin_tramita_pago.sidepag%TYPE,
      pctipres IN sin_tramita_pago_gar.ctipres%TYPE,
      pnmovres IN sin_tramita_pago_gar.nmovres%TYPE,
      pcgarant OUT sin_tramita_pago_gar.cgarant%TYPE,
      pfperini OUT sin_tramita_pago_gar.fperini%TYPE,
      pfperfin OUT sin_tramita_pago_gar.fperfin%TYPE,
      pcmonres OUT sin_tramita_pago_gar.cmonres%TYPE,
      pisinret OUT sin_tramita_pago_gar.isinret%TYPE,
      pcmonpag_gar OUT sin_tramita_pago_gar.cmonpag%TYPE,
      pisinretpag OUT sin_tramita_pago_gar.isinretpag%TYPE,
      pfcambio OUT sin_tramita_pago_gar.fcambio%TYPE,
      pcconpag_gar OUT sin_tramita_pago_gar.cconpag%TYPE,
      pnorden OUT sin_tramita_pago_gar.norden%TYPE)
      RETURN NUMBER;

   FUNCTION f_get_detalle_reserva(
      pnsinies IN sin_tramita_reserva.nsinies%TYPE,
      pntramit IN sin_tramita_reserva.ntramit%TYPE,
      pctipres IN sin_tramita_reserva.ctipres%TYPE,
      pcgarant IN sin_tramita_reserva.cgarant%TYPE,
      pcmonres IN sin_tramita_reserva.cmonres%TYPE,
      pfresini IN sin_tramita_reserva.fresini%TYPE,
      pfresfin IN sin_tramita_reserva.fresfin%TYPE,
      pnmovres OUT sin_tramita_reserva.nmovres%TYPE,
      pccalres OUT sin_tramita_reserva.ccalres%TYPE,
      pireserva OUT sin_tramita_reserva.ireserva%TYPE,
      pipago OUT sin_tramita_reserva.ipago%TYPE,
      picaprie OUT sin_tramita_reserva.icaprie%TYPE,
      pipenali OUT sin_tramita_reserva.ipenali%TYPE,
      piingreso OUT sin_tramita_reserva.iingreso%TYPE,
      pirecobro OUT sin_tramita_reserva.irecobro%TYPE,
      piprerec OUT sin_tramita_reserva.iprerec%TYPE,
      pctipgas OUT sin_tramita_reserva.ctipgas%TYPE,
      pifranq OUT sin_tramita_reserva.ifranq%TYPE,
      pndias OUT sin_tramita_reserva.ndias%TYPE,
      pitotimp OUT sin_tramita_reserva.itotimp%TYPE,
      pidres OUT sin_tramita_reserva.idres%TYPE)
      RETURN NUMBER;

   FUNCTION f_destinatario_empresa(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pcempres IN NUMBER,
      psperson OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_cartera_pendiente(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN sin_siniestro.nriesgo%TYPE,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_compensa_recibo(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN sin_siniestro.nriesgo%TYPE,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramita_pago.ntramit%TYPE,
      psidepag IN sin_tramita_pago.sidepag%TYPE,
      psperson IN per_personas.sperson%TYPE,
      pnrecibo IN recibos.nrecibo%TYPE,
      pfefecto IN recibos.fefecto%TYPE,
      pccobban IN recibos.ccobban%TYPE,
      pcdelega IN recibos.cdelega%TYPE,
      pitotalr IN vdetrecibos.itotalr%TYPE,
      pfordpag IN sin_tramita_pago.fordpag%TYPE,
      pcconpag IN sin_tramita_pago.cconpag%TYPE,
      pccauind IN sin_tramita_pago.ccauind%TYPE,
      pcbancar IN sin_tramita_pago.cbancar%TYPE,
      pcmonpag IN sin_tramita_pago.cmonpag%TYPE,
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
      pirestorec IN NUMBER,
      pno_crear_cab_pago IN NUMBER,
      psidepag_cab IN sin_tramita_pago.sidepag%TYPE,
      psidepag_new OUT sin_tramita_pago.sidepag%TYPE,
      pnmovpag_new OUT sin_tramita_movpago.nmovpag%TYPE)
      RETURN NUMBER;

   FUNCTION f_valida_exist_res_noindem(
      psidepag IN sin_tramita_pago.sidepag%TYPE,
      pexisten OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_exist_recib_remesados(
      psseguro IN seguros.sseguro%TYPE,
      pexisten OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_validar_dias_gracia(
      psseguro IN seguros.sseguro%TYPE,
      pfefecto IN recibos.fefecto%TYPE,
      pdias_gracia OUT NUMBER)
      RETURN NUMBER;

-- FIN BUG 28830:NSS:06/11/2013 - CompensaciÃƒÂ³n de siniestros contra cartera.
-- IAXIS 4555 AABC Validacion de indicador de Iva
   FUNCTION f_valida_ind_iva(
      psidepag    IN sin_tramita_pago.sidepag%TYPE,
      pcconpag    IN sin_tramita_pago.cconpag%TYPE,
      pcescenario IN NUMBER)
      RETURN VARCHAR2;
-- IAXIS 4555 AABC Validacion de indicador de Iva
   -- BUG xxx:NSS:15/04/2014 -
   FUNCTION f_get_certif_0(psseguro IN NUMBER, vcertif0 OUT NUMBER)
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
      pitotret OUT NUMBER)
      RETURN NUMBER;

-- FIN BUG 31294/174788: :NSS:18/06/2014 - -

   -- BUG 31872/178559: :NSS:14/07/2014 -
   FUNCTION f_valida_carencia(pnsinies sin_siniestro.nsinies%TYPE, presult OUT NUMBER)
      RETURN NUMBER;

-- FIN BUG 31872/178559: :NSS:14/07/2014 --- BUG 0033345 17/11/2014.
   FUNCTION f_set_campo_plantilla(
      pnsinies IN VARCHAR2,
      pccodplan IN VARCHAR2,
      pndocume IN VARCHAR2,
      pccampo IN VARCHAR2,
      ptcampo IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_getrow_reserva(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pidres IN sin_tramita_reserva.idres%TYPE,
      vreserva OUT sin_tramita_reserva%ROWTYPE)
      RETURN NUMBER;

   -- BUG 33345/0195569
   FUNCTION f_get_documentacion_pendiente(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      ptlisdoc OUT VARCHAR2)
      RETURN NUMBER;

   --BUG 35102/200437
   FUNCTION f_hay_lista_innominados(
      psproduc IN productos.sproduc%TYPE,
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN riesgos.nriesgo%TYPE,
      pnasegur OUT NUMBER)
      RETURN NUMBER;

  FUNCTION f_ins_judicial_detper(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pnrol IN NUMBER,
      pnpersona IN NUMBER,
      pntipper IN NUMBER,
      pnnumide IN VARCHAR2,
      ptnombre IN VARCHAR2,
      piimporte IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

  FUNCTION f_ins_obj_judicial_valpret(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pcgarant IN NUMBER,
      pipreten IN NUMBER)
      RETURN NUMBER;

  FUNCTION f_ins_judicial(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pcproceso IN NUMBER,
      ptproceso IN NUMBER,
      pcpostal IN VARCHAR2,
      pcpoblac IN NUMBER,
      pcprovin IN NUMBER,
      ptiexterno IN VARCHAR2,
      psprofes IN NUMBER,
      pfrecep IN DATE,
      pfnotifi IN DATE,
      pfvencimi IN DATE,
      pfrespues IN DATE,
      pfconcil IN DATE,
      pfdesvin IN DATE,
      ptpreten IN VARCHAR2,
      ptexcep1 IN VARCHAR2,
      ptexcep2 IN VARCHAR2,
      pcconti IN NUMBER,
      pcdespa IN NUMBER,
      pcdescf IN VARCHAR2,
      pcprovinf IN NUMBER,
      pcpoblacf IN NUMBER,
      pcdespao IN NUMBER,
      pcdesco IN VARCHAR2,
      pcprovino IN NUMBER,
      pcpoblaco IN NUMBER,
      pcposici IN NUMBER,
      pcdemand IN NUMBER,
      psapodera IN NUMBER,
      pidemand IN NUMBER,
      pftdeman IN DATE,
      piconden IN NUMBER,
      pcsenten IN NUMBER,
      pfsente1 IN DATE,
      pcsenten2 IN NUMBER,
      pfsente2 IN DATE,
      pcasacion IN NUMBER,
      pfcasaci IN DATE,
      pctsente IN NUMBER,
      pftsente IN DATE,
      pvtsente IN VARCHAR2,
      ptfallo IN VARCHAR2
    ,pcoralproc IN NUMBER
    ,punicainst IN NUMBER
    ,pfunicainst IN DATE)
      RETURN NUMBER;

  FUNCTION f_ins_judicial_audien(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pnaudien IN NUMBER,
      pfaudien IN DATE,
      phaudien IN VARCHAR2,
      ptaudien IN VARCHAR2,
      pcdespa IN NUMBER,
      ptlaudie IN VARCHAR2,
      pcaudien IN VARCHAR2,
      pcdespao IN NUMBER,
      ptlaudieo IN VARCHAR2,
      pcaudieno IN VARCHAR2,
      psabogau IN NUMBER,
      pcoral IN NUMBER,
      pcestado IN NUMBER,
      pcresolu IN NUMBER,
      pfinsta1 IN DATE,
      pfinsta2 IN DATE,
      pfnueva IN DATE,
      ptresult IN VARCHAR2)
      RETURN NUMBER;

  FUNCTION f_elimina_dato_judicial(
      pctipo IN NUMBER,
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pnvalor IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_del_sin_trami_doc(pnsinies IN sin_siniestro.nsinies%TYPE,
                                pntramit IN sin_tramitacion.ntramit%TYPE,
                                pndocume IN NUMBER)
      RETURN NUMBER;
  FUNCTION f_ins_fiscal(
      PNSINIES  IN   VARCHAR2,
      PNTRAMIT  IN   NUMBER,
      PNORDEN   IN   NUMBER,
      PFAPERTU  IN	DATE,
      PFIMPUTA  IN	DATE,
      PFNOTIFI  IN	DATE,
      PFAUDIEN  IN	DATE,
      PHAUDIEN  IN	VARCHAR2,
      PCAUDIEN  IN	NUMBER,
      PSPROFES  IN	NUMBER,
      PCOTERRI  IN	NUMBER,
      PCPROVIN  IN	NUMBER,
      PCCONTRA  IN	NUMBER,
      PCUESPEC  IN	NUMBER,
      PTCONTRA  IN	VARCHAR2,
      PCTIPTRA  IN	NUMBER,
      PTESTADO  IN	VARCHAR2,
      PCMEDIO   IN	NUMBER,
      PFDESCAR  IN	DATE,
      PFFALLO   IN   DATE,
      PCFALLO   IN   NUMBER,
      PTFALLO   IN   VARCHAR2,
      PCRECURSO IN   NUMBER)
      RETURN NUMBER;

  FUNCTION f_ins_fiscal_valpret(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pcgarant IN NUMBER,
      pipreten IN NUMBER)
      RETURN NUMBER;
  FUNCTION f_elimina_dato_fiscal(
      pctipo IN NUMBER,
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pnvalor IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_tramitaciones(pnsinies IN VARCHAR2, ptquery OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_reservas(pnsinies IN VARCHAR2, ptquery OUT VARCHAR2)
      RETURN NUMBER;

--Version 74
FUNCTION f_ins_reservadet(
  pnsinies IN sin_siniestro.nsinies%TYPE,
  pidres   IN NUMBER,
  pnmovres IN NUMBER,
  pfmovres IN DATE,
  pcmovres IN NUMBER,
  pcmonres IN VARCHAR2,
  pcierre  IN NUMBER,
  pireserva IN NUMBER)
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
          Clasificación de siniestros
          Autor:Andre Betancourt 05-06-2019

    ***********************************************************************/ 
 FUNCTION f_get_clasificasiniestro (pnsinies IN VARCHAR2, pnpagos  IN NUMBER,  pntramita  IN NUMBER, ptquery OUT VARCHAR2)
      RETURN NUMBER;
      
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
    ,ptobsfallo IN VARCHAR2)
      RETURN NUMBER;         
	/*************************************************************************
        funcion borra localizacion de tramitacion
        param in pnsinies : numero de siniestro
        param in pntramit : numero de siniestro
        param in pnlocali : numero localizacion
   *************************************************************************/
   FUNCTION f_del_localizacion(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnlocali IN NUMBER)
     RETURN NUMBER;
END pac_siniestros;
/
