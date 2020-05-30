CREATE OR REPLACE PACKAGE "PAC_MD_IMPRESION" AS
/******************************************************************************
   NOMBRE:      PAC_MD_IMPRESION
   PROPÃ“SITO: Funciones para la impresiÃ³n de documentos

   REVISIONES:
   Ver        Fecha        Autor             DescripciÃ³n
   ---------  ----------  ---------------  ------------------------------------
   1.1        28/04/2008   ACC                1. Incluir funciones de impresiÃ³n
   2.0        19/03/2009   SBG                2. Afegir camps ICGARAC i ICFALLAC
   3.0        13/05/2009   ICV                3. 0010078: IAX - AdaptaciÃ³n impresiones (plantillas)
   6.0        04/06/2009   JTS                10233: APR - cartas de impagados ( 2Âª parte)
   8.0        05/02/2010   JTS                12693: PODER EXTREURE DUPLICATS DE DOCUMENACIÃ“
   9.0        08/02/2010   JTS                12850: CEM210 - Estalvi: Plantilles de pignoracions i bloquejos
   10.0       13/09/2010   XPL                15685: CIV998 - Preparar la aplicaciÃ³n para que registre campos concretos en log_actividad
   18 .0      31/12/2010   ETM                0016446: GRC - Documento de pago de siniestros
   20.0       05/05/2011   JTS                18463: ENSA-101-RecepciÃ³n del nrecibo como parÃ¡metro por parte del modelo de impresiÃ³n
   21.0       24/11/2011   ETM                0019783: LCOL_S001-SIN - Rechazo de tramitaciones
   22.0       23/04/2012   JMF                0022030: MDP_A001-Devoluciones: impresion y gestion de cartas
   23.0       05/06/2012   JMF                0022444: MDP_S001-SIN - Carta de rechazo en alta siniestro
   24.0       24/01/2013   MLA                0025816: RSAG - Enviar un correo con datos adjuntos.
   25.0       03/07/2015   ETM                33632: MSV0010-MSV0003 : templates quotations (protection)/NOTA 0209087--mandar mail al agente si este lo tiene informado para las plantillas de tipo 67
   26.0       15/05/2019   CES-RAB            IAXIS-3088: Ajuste para formato USF.
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   --Estructura amb els possibles parÃ metres necessÃ ris per a la impressiÃ³ d'una pÃ²lissa
   TYPE ob_info_imp IS RECORD(
      sseguro        seguros.sseguro%TYPE,
      npoliza        seguros.npoliza%TYPE,
      ncertif        seguros.ncertif%TYPE,
      nmovimi        movseguro.nmovimi%TYPE,
      sproduc        seguros.sproduc%TYPE,
      nrecibo        recibos.nrecibo%TYPE,
      cidioma        seguros.cidioma%TYPE,
      nriesgo        NUMBER,
      cempres        seguros.cempres%TYPE,
      -- Bug 11595 - se define la variable como en sin_siniestro
      nsinies        VARCHAR2(14),   --siniestros.nsinies%TYPE,   -- Bug 10199 - APD - 27/05/2009 - se aÃ±ade el nsinies
      iprovac        NUMBER,
      icgarac        NUMBER,
      icfallac       NUMBER,
      nomfitxer      VARCHAR2(200),
      stras          NUMBER,   --BUG12388 - JTS - 23/12/2009
      cduplica       NUMBER,   --BUG 12693 - JTS - 04/02/2010
      cagente        NUMBER,
      nreemb         NUMBER,   --BUG16552 - JTS - 16/11/2010
      nfact          NUMBER,   --BUG16552 - JTS - 16/11/2010
      sidepag        NUMBER,   --bug 16446 - ETM - 31/12/2010
      ccausin        NUMBER,   --bug 16446 - ETM - 31/12/2010
      cmotsin        NUMBER,   --bug 16446 - ETM - 31/12/2010
      ntramit        NUMBER,   --bug 19783 --ETM --24/11/2011
      ndocume        NUMBER,   --bug 22760 --JTS --18/07/2012
      sproces        NUMBER,   --BUG24687- JTS - 15/11/2012
      ccompani       NUMBER,   --Bug 32034 - SHA - 27/08/2014
      refdeposito    NUMBER,   --BUG33886/209113- RACS
      sperson        NUMBER,    --CONF-578 - JTS - 31/01/2017
      cidiomarep     NUMBER,     -- TCS_324B - JLTS - 11/02/2019.
	  scontgar       NUMBER,    -- TCS_319 - ACL - 08/03/2019.
    nsolici        NUMBER		-- CES-RAB IAXIS-3088
   );

   /*************************************************************************
      Obtiene un objeto de informaciÃ³n de impresiÃ³n, inicializado con los
      valores generales del seguro pasado por parÃ¡metro.
      param in psseguro    : CÃ³digo de seguro
      param in pctipo      : tipo de documento
      param in pmode       : Modo ('POL' / 'EST')
      param out mensajes   : mensajes de error
      return               : OB_INFO_IMP
   *************************************************************************/
   FUNCTION f_get_infoimppol(
      psseguro IN seguros.sseguro%TYPE,
      pctipo IN NUMBER,
      pmode IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_info_imp;

   /*************************************************************************
      ImpresiÃ³n documentaciÃ³n
      param in psseguro    : CÃ³digo del seguro
      param in pcidioma    : CÃ³digo del idioma
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_get_documprod(
      psseguro IN NUMBER,
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_impresion;

   /*************************************************************************
      VisualizaciÃ³n de un documento almacenado en GEDOX
      param in piddoc      : Id. del documento que se debe visualizar
      param out ptpath     : Ruta del fichero que se debe visualizar
      param out mensajes   : mensajes de error
      param in pws      : Indica si es llamado desde un webservices
      return               : 0/1 -> Ok/Error
   *************************************************************************/
   FUNCTION f_gedox_verdoc(
      piddoc IN NUMBER,
      optpath OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      ImpresiÃ³n documentaciÃ³n por tipo
      param in psseguro    : CÃ³digo del seguro
      param in pctipo      : tipo de documento
      param in pcidioma    : CÃ³digo del idioma
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_get_documprod_tipo(
      psseguro IN NUMBER,
      pctipo IN NUMBER,
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_impresion;

/*************************************************************************
      Llena el objeto de informaciÃ³n de impresiÃ³n
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
--xpl 13092010 bug 15685
   FUNCTION f_get_params(
      pimprimir IN OUT ob_iax_impresion,
      pinfoimp IN ob_info_imp,
      pctipo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      ImpresiÃ³n justificante mÃ©dico
      param in P_NREEMB    : NÃºmero de reembolso
      param in P_NFACT     : NÃºmero de factura
      param in P_NRIESGO   : Id. de riesgo
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_factura(
      p_nreemb IN NUMBER,
      p_nfact IN NUMBER,
      p_nriesgo IN NUMBER,
      p_sseguro IN NUMBER,
      p_tipo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_impresion;

   /*************************************************************************
      ImpresiÃ³n del cuestionario de salud por SSEGURO y NRIESGO
      param in psseguro   : CÃ³digo interno del seguro
      param in pnriesgo   : NÃºmero del riesgo
      param in pnomfitxer : Nombre del fichero
      param in pmodo      : Modo EST o POL
      param out mensajes  : mensajes de error
      return              : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_get_questsalud(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnomfitxer IN VARCHAR2,
      pmodo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_impresion;

   /*************************************************************************
      Devuelve el nÃºmero de copias a generar.
      param in psproduc    : CÃ³digo del producto
      param in pctipo      : Tipo de impresion
      param in pccodplan   : CÃ³digo de plantilla
      param in pfdesde     : Fecha de vigencia
      param in psseguro    : CÃ³digo de seguro
      param out mensajes   : mensajes de error
      return               : NÃºmero de copias en caso de error retorna 1 y el mensaje de error en el objeto mensajes.

       -- BUG 10078 - 13/05/2009 - ICV - 0010078: IAX - AdaptaciÃ³n impresiones (plantillas)
   *************************************************************************/
   FUNCTION f_ncopias(
      psproduc IN NUMBER,
      pctipo IN NUMBER,
      pccodplan IN VARCHAR2,
      pfdesde IN DATE,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,   --BUG18463 - 05/05/2011 - JTS
      pnrecibo IN NUMBER,   --BUG18463 - 05/05/2011 - JTS
      pnsinies IN NUMBER,   --BUG18463 - 05/05/2011 - JTS
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   --BUG 10233 - JTS - 04/06/2009
   /*************************************************************************
      ImpresiÃ³n carta de impago
      param in P_SGESCARTA : ID. de la carta
      param in p_sdevolu   : ID. devolucion
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
      -- Bug 0022030 - 23/04/2012 - JMF
   *************************************************************************/
   FUNCTION f_imprimir_carta(
      p_sgescarta IN NUMBER,
      p_sdevolu IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_impresion;

--Fi BUG 10233 - JTS - 04/06/2009

   --BUG 10729 - JTS - 12/08/2009
   /*************************************************************************
      ImpresiÃ³n recibos
      param in P_SPROIMP   : ID. del lote de recibos a imprimir
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_recibos(p_sproimp IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_impresion;

-- Fi BUG 10729 - JTS - 12/08/2009
   --BUG 10684 - JGM - 14/09/2009
   /*************************************************************************
      ImpresiÃ³n del cuestionario de salud por SSEGURO y NRIESGO
      param in pcempres   : CÃ³digo empresa
      param in pcproces   : NÃºmero de proceso
      param in pcagente   : NÃºmero de agente
      param in pnomfitxer : Nombre del fichero
      param out mensajes  : mensajes de error
      return              : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_get_listcomi(
      pcempres IN NUMBER,
      pcproces IN NUMBER,
      pcagente IN NUMBER,
      pnomfitxer IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_impresion;

   /*************************************************************************
      --BUG12388 - JTS - 23/12/2009
      ImpresiÃ³n traspasos
      param in P_STRAS     : ID. del traspaso a imprimir
      param in P_SSEGURO   : ID. del seguro
      param in P_TIPO      : tipo traspaso, "TRAS/REV" (Traspaso o revocaciÃ³n)
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_traspas(
      p_stras IN NUMBER,
      p_sseguro IN NUMBER,
      p_tipo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_impresion;

   /*************************************************************************
      ImpresiÃ³n detalle documentaciÃ³n
      param in pcodplan    : CÃ³digo plantilla
      param in pparamimp   : ParÃ¡metros de impresiÃ³n de la plantilla
      param in ptfilename  : Nombre del fichero que se debe generar
      param in ncopias     : NÃºmero de copias.
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_detimprimir(
      pinfoimp IN ob_info_imp,
      pccodplan IN VARCHAR2,
      pparamimp IN pac_isql.vparam,
      ptfilename IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_impresion;

   /*************************************************************************
      --BUG12850 - JTS - 08/02/2010
      F_GET_TIPO
      param in PTTIPO      : Tipus de la plantilla
      return               : Ctipo de la plantilla
   *************************************************************************/
   FUNCTION f_get_tipo(pttipo VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      --BUG13288 - JTS - 23/02/2010
      ImpresiÃ³n recibo
      param in P_NRECIBO   : ID. NRECIBO
      param in P_SSEGURO   : ID. del seguro
      param in P_TIPO      : ctipo
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_recibo(
      p_nrecibo IN NUMBER,
      p_ndocume IN NUMBER,
      p_sseguro IN NUMBER,
      p_tipo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_impresion;

   /*************************************************************************
      --BUG13288 - JTS - 23/02/2010
      F_GET_CDUPLICA
      param in PCTIPO      : Tipus de la plantilla
      return               : CDUPLICA de la plantilla
   *************************************************************************/
   FUNCTION f_get_cduplica(pctipo NUMBER)
      RETURN NUMBER;

   --BUG 16446 - ETM - 31/12/2010

   /*************************************************************************
       F_sinies_pago
       param in psproduc    : CÃ³digo del producto
     param in p_ccodplan   : CÃ³digo de plantilla
     param in  p_ccausin : causa del siniestro
    param in p_cmotsin : motivo del siniestro
      return               : Ctipo de la plantilla
   *************************************************************************/
   FUNCTION f_sinies_pago(
      p_ccodplan IN VARCHAR2,
      psproduc IN NUMBER,
      p_ccausin IN NUMBER,
      p_cmotsin IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
 --BUG 16446 - ETM - 31/12/2010
   ImpresiÃ³n  PAGOS
     param in p_sseguro    : id de seguro
    param in P_SIDEGAP   : ID. DE PAGOS A  imprimir
    param in P_TIPO      : ctipo plantillas
    param in  p_ccausin : causa del siniestro
    param in p_cmotsin : motivo del siniestro
   param out mensajes   : mensajes de error
   return               : objeto rutas ficheros
*************************************************************************/
   FUNCTION f_imprimir_pago(
      p_sseguro IN NUMBER,
      p_sidepag IN NUMBER,
      p_tipo IN VARCHAR,
      p_ccausin IN NUMBER,
      p_cmotsin IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_impresion;

    /*************************************************************************
    --BUG 19783 - ETM - 24/11/2011
      ImpresiÃ³n  TRAMITACIONES
      param in p_nsinies    : id de SINIESTRO
       param in P_ntramit   : numero de tramitacion
       param in P_cestado      : estado de la tramitacion
       PARAM in p_tipo        : tipo de plantilla
        param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_trami(
      p_nsinies IN VARCHAR2,
      p_ntramit IN NUMBER,
      p_cestado IN NUMBER,
      p_tipo IN VARCHAR,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_impresion;

   /*************************************************************************
       --BUG 21458 - JTS - 22/05/2012
       FUNCTION f_firmar_doc
        param in p_iddoc    : id del documento GEDOX a firmar
        param in P_firmab64 : firma en BASE64
        param out mensajes  : mensajes de error
       return               : error
    *************************************************************************/
   FUNCTION f_firmar_doc(
      p_iddoc IN VARCHAR2,
      p_fichero IN VARCHAR2,
      p_firmab64 IN CLOB,
      p_conffirma IN VARCHAR2,
      p_ccodplan IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    -- BUG 0022444 - JMF - 05/06/2012
      ImpresiÃ³n carta rechazo siniestro
       param in p_sseguro : numero sseguro
       param in p_tipo    : tipo de plantilla
       param out mensajes : mensajes de error
       return             : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_cartarechazosin(
      p_sseguro IN NUMBER,
      p_tipo IN VARCHAR,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_impresion;

   /*************************************************************************
    -- ini BUG 0021765 - JTS - 19/06/2012
      ImpresiÃ³n cartas de preavisos
       param in p_sproces : Sproces
       param in p_tipo    : tipo de plantilla
       param out mensajes : mensajes de error
       return             : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_cartaspreavisos(
      p_sproces IN NUMBER,
      p_tipo IN VARCHAR,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_impresion;

   FUNCTION f_get_impagrup(pcurcat OUT sys_refcursor, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_impdet(
      pdefault IN NUMBER,
      pccategoria IN NUMBER,
      pctipo IN NUMBER,
      ptfich IN VARCHAR2,
      pfsolici IN DATE,
      puser IN VARCHAR2,
      pfult IN DATE,
      pusult IN VARCHAR2,
      pcestado IN NUMBER,
      psproces IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pcagente IN NUMBER,
      psproduc IN NUMBER,
      pcramo IN NUMBER,
      pcurdocs OUT sys_refcursor,
      plistzips OUT t_iax_impresion,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_categorias(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_impresoras(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

      /*************************************************************************
       Bug 22328 - 30/07/2012 - JRB
       Inserta el documento
       param in PIDDOCGEDOX : Identificador del documento gedox
       param in PTDESC    : descripcion
       param out mensajes : mensajes de error
       return             : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_ins_doc(
      piddocgedox IN NUMBER,
      ptdesc IN VARCHAR2,
      ptfich IN VARCHAR2,
      pctipo IN NUMBER,
      pcdiferido IN NUMBER,
      pccategoria IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnrecibo IN NUMBER,
      pnsinies IN NUMBER,
      psidepag IN NUMBER,
      psproces IN NUMBER,
      pcagente IN NUMBER,
      pcidioma IN NUMBER,
      piddocdif IN NUMBER,
      pnorden IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_envia_impresora(
      plistcategorias IN VARCHAR2,
      plistdocs IN VARCHAR2,
      pidimpresora IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_obtener_valor_columna(
      pinfo IN t_iax_info,
      pnombre_columna IN VARCHAR2,
      pvalor_columna OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      --BUG24687- JTS - 15/11/2012
      ImpresiÃ³n procesos
      param in PSPROCES  : ID. proceso
      param in P_TIPO      : ctipo
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_sproces(
      p_sproces IN NUMBER,
      p_tipo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_impresion;

   FUNCTION f_recupera_pendientes
      RETURN sys_refcursor;

   FUNCTION f_genera_pendientes(piddocdif IN NUMBER)
      RETURN sys_refcursor;

   FUNCTION f_gedox_pendiente(
      piddocdif IN NUMBER,
      pnorden IN NUMBER,
      ptfilename IN VARCHAR2,
      ptruta IN VARCHAR2,
      pterror IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_set_fichzip(
      psproces IN NUMBER,
      ptagrupa IN VARCHAR2,
      pcestado IN NUMBER,
      pterror IN VARCHAR2)
      RETURN NUMBER;

   /************************************************************************************************
        Bug 10.0       24/01/2013   MLA                10.25816: RSAG - Enviar un correo con datos adjuntos.
        f_imprimir_via_correo
        DescripciÃ³n: Envia un correo electronico con archivos los archivos de seguros
        ParÃ¡metros entrada:
              pcempres IN NUMBER, Codigo de empresa
              pmodo IN VARCHAR2, Modo de envio  cfg_notificacion->cmodo
              ptevento IN VARCHAR2, Evento de envio  cfg_notificacion->tevento
              pcidioma IN NUMBER, Idioma de envio
              pdirectorio IN VARCHAR2, Directorio de los archivos adjuntos
              pdocumentos IN VARCHAR2, Listado separado por coma ',' con los nombres de archivos a enviar
              pmimestypes IN VARCHAR2, Listado separado por coma ',' con los mimetypes de los archivos a
                                         enviar, en el mismo orden de correlacion que en pdocumentos
              pdestinatarios IN VARCHAR2, Destinatarios a enviar
              psproduc IN VARCHAR2 DEFAULT '0' Producto asociado
              mensajes OUT t_iax_mensajes Objeto de mensaje para transmision de avisos
              psseguro IN NUMBER DEFAULT NULL Codigo del seguro asociado
        Retorno:      0 OK / Retorno <> 0 Error
    ************************************************************************************************/
   FUNCTION f_imprimir_via_correo(
      pcempres IN NUMBER,
      pmodo IN VARCHAR2,
      ptevento IN VARCHAR2,
      pcidioma IN NUMBER,
      pdirectorio IN VARCHAR2,
      pdocumentos IN VARCHAR2,
      pmimestypes IN VARCHAR2,
      pdestinatarios IN VARCHAR2,
      psproduc IN VARCHAR2,
      psseguro IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_imprimir_renovcero(p_sseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_impresion;

   FUNCTION f_imprimir_sproces_ccompani(
      p_sproces IN NUMBER,
      p_ccompani IN NUMBER,
      p_tipo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_impresion;

   FUNCTION f_imprimir_movimiento(
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_impresion;

   --INI --BUG 33632/209087-- ETM  --03/07/2015--
   FUNCTION f_mail_agente(p_sseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

--FIN --BUG 33632/209087-- ETM  --03/07/2015--

   /*************************************************************************
    --BUG 16446 - ETM - 31/12/2010
      ImpresiÃ³n  PAGOS
        param in p_sseguro    : id de seguro
       param in P_SIDEGAP   : ID. DE PAGOS A  imprimir
       param in P_TIPO      : ctipo plantillas
       param in  p_ccausin : causa del siniestro
       param in p_cmotsin : motivo del siniestro
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_cashdesk(
      p_refdeposito IN NUMBER,
      p_tipo IN VARCHAR,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_impresion;

   /*************************************************************************
      ImpresiÃ³n documentaciÃ³n
      param in pinfoimp    : InformaciÃ³n para realizar la impresiÃ³n
      param in pfefecto    : Fecha efecto
      param in pctipo      : Tipo documentaciÃ³n
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir(
      pinfoimp IN ob_info_imp,
      pfefecto IN DATE,
      pctipo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_impresion;

   /*************************************************************************
      Procedimiento que repasa los documentos que estan encolados para generarse
      en la tabla doc_diferida y los genera
      param in pnumrows    : Numero de trabajos de la tabla doc_diferida que debe realizar
   *************************************************************************/
   PROCEDURE p_genera_docdiferida(pnumrows NUMBER);

   FUNCTION f_imprimir_ensa_mail(
      pccodplan IN VARCHAR2,
      pinfoimp IN ob_info_imp,
      pfefecto IN DATE,
      pctipo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_impresion;

   PROCEDURE f_imprimir_recibo_ensa_mail(
      p_nrecibo IN NUMBER,
      p_ndocume IN NUMBER,
      p_sseguro IN NUMBER,
      p_ccodplan IN VARCHAR2,
      p_tipo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes);

   FUNCTION f_set_documgedox(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      puser IN VARCHAR2,
      ptfilename IN VARCHAR2,
      ptdesc IN VARCHAR2,
      pidcat IN NUMBER,
      piddoc OUT NUMBER,
      mensajes IN OUT t_iax_mensajes,
      dirpdfgdx IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
      f_imprimir_sinies_soldoc
      pctipo IN NUMBER
      psseguro IN NUMBER
      pnsinies IN VARCHAR2
      pntramit IN NUMBER
      psidepag IN NUMBER
      mensajes OUT T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_imprimir_sinies_soldoc(
      pctipo IN NUMBER,
      psseguro IN NUMBER,
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      psidepag IN NUMBER,
      mensajes OUT T_IAX_MENSAJES)
      RETURN t_iax_impresion;

   /*************************************************************************
      --CONF578- JTS - 31/01/2017
      ImpresiÃ³n personas
      param in PSPERSON  : ID. persona
      param in P_TIPO      : ctipo de documento
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_sperson(
      p_sperson IN NUMBER,
      p_tipo IN VARCHAR2,
      -- INI - TCS_324B - JLTS - 11/02/2019. Se adiciona la opciÃ³n idioma por parÃ¡metro
      p_cidiomarep IN NUMBER DEFAULT NULL, 
      -- FIN - TCS_324B - JLTS - 11/02/2019.
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_impresion;

 /*************************************************************************
      --TCS_19 - ACL - 08/03/2019
      ImpresiÃ³n pagare contragarantia
      param in pscontgar  : ID. contragarantia
      param in P_TIPO      : ctipo de documento
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_scontgar(
      p_scontgar IN NUMBER,
      p_tipo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_impresion;
END pac_md_impresion;
/