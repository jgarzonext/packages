--------------------------------------------------------
--  DDL for Package PAC_IAX_IMPRESION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_IMPRESION" AS
/******************************************************************************
   NOMBRE:      PAC_IAX_IMPRESION
   PROP¿¿SITO: Funciones para la impresi¿¿n de documentos

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        16/01/2008   JAS                1. Creaci¿¿n del package.
   1.1        17/01/2008   JTS                1. La ruta del fichero se coge
                                                 de parinstalacion.
   1.2        28/04/2008   ACC                3. Incluir funciones de impresi¿¿n
   6.0        04/06/2009   JTS                10233: APR - cartas de impagados ( 2¿¿ parte)
   7.0        12/08/2009   JTS                10729: APR - Pantalla de impresion de recibos
   8.0        13/09/2010   XPL                15685: CIV998 - Preparar la aplicaci¿¿n para que registre campos concretos en log_actividad
   11.0       31/12/2010   ETM                0016446: GRC - Documento de pago de siniestros
   12.0       24/11/2011   ETM                0019783: LCOL_S001-SIN - Rechazo de tramitaciones
   13.0       23/04/2012   JMF                0022030: MDP_A001-Devoluciones: impresion y gestion de cartas
   14.0       05/06/2012   JMF                0022444: MDP_S001-SIN - Carta de rechazo en alta siniestro
******************************************************************************/
   pimpresion     t_iax_impresion;   --xpl 13092010 bug 15685

   /*************************************************************************
      Visualizaci¿¿n de un documento almacenado en GEDOX
      param in piddoc      : Id. del documento que se debe visualizar
      param out mensajes   : mensajes de error
      return               : 0/1 -> Ok/Error
   *************************************************************************/
   FUNCTION f_gedox_verdoc(piddoc IN NUMBER, optpath OUT VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Impresi¿¿n documentaci¿¿n
      param in psseguro    : C¿¿digo del seguro
      param in pcidioma    : C¿¿digo del idioma
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_get_documprod(
      psseguro IN NUMBER,
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_impresion;

   /*************************************************************************
      Impresi¿¿n documentaci¿¿n
      param in psseguro    : C¿¿digo del seguro
      param in pctipo      : Tipo de Documento
      param in pcidioma    : C¿¿digo del idioma
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_get_documprod_tipo(
      psseguro IN NUMBER,
      pctipo IN VARCHAR,
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_impresion;

   /*************************************************************************
      Impresi¿¿n justificante m¿¿dico
      param in P_NREEMB    : N¿¿mero de reembolso
      param in P_NFACT     : N¿¿mero de factura
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
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_impresion;

   /*************************************************************************
      Impresi¿¿n del cuestionario de salud por SSEGURO y NRIESGO
      param in psseguro   : C¿¿digo interno del seguro
      param in pnriesgo   : N¿¿mero del riesgo
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
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_impresion;

   --BUG 10233 - JTS - 04/06/2009
   /*************************************************************************
      Impresi¿¿n carta de impago
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
      Impresi¿¿n recibos
      param in P_SPROIMP   : ID. del lote de recibos a imprimir
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_recibos(p_sproimp IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_impresion;

-- Fi BUG 10729 - JTS - 12/08/2009
   --BUG 10684 - JGM - 14/09/2009
   /*************************************************************************
      Impresi¿¿n del cuestionario de salud por SSEGURO y NRIESGO
      param in pcempres   : C¿¿digo empresa
      param in pcproces   : N¿¿mero de proceso
      param in pcagente   : N¿¿mero de agente
      param in pnomfitxer : Nombre del fichero
      param out mensajes  : mensajes de error
      return              : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_get_listcomi(
      pcempres IN NUMBER,
      pcproces IN NUMBER,
      pcagente IN NUMBER,
      pnomfitxer IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_impresion;

   /*************************************************************************
      --BUG12388 - JTS - 23/12/2009
      Impresi¿¿n traspasos
      param in P_STRAS     : ID. del traspaso a imprimir
      param in P_SSEGURO   : ID. del seguro
      param in P_TIPO      : tipo traspaso, "TRAS/REV" (Traspaso o revocaci¿¿n)
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_traspas(
      p_stras IN NUMBER,
      p_sseguro IN NUMBER,
      p_tipo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_impresion;

   /*************************************************************************
      --BUG13288 - JTS - 23/02/2010
      Impresi¿¿n recibo
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
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_impresion;

   /*************************************************************************
       --BUG 16446 --ETM- 31/12/2010
       Impresi¿¿n pagos
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
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_impresion;

/*************************************************************************
  --BUG 19783 --ETM- 24/11/2011
  Impresi¿¿n pagos
  param in p_nsinies    : id de SINIESTRO
  param in P_ntramit   : numero de tramitacion
  param in P_cestado      : estado de la tramitacion
  param in P_TIPO      : ctipo plantillas
  param out mensajes   : mensajes de error
  return               : objeto rutas ficheros
*************************************************************************/
   FUNCTION f_imprimir_trami(
      p_nsinies IN VARCHAR2,
      p_ntramit IN NUMBER,
      p_cestado IN NUMBER,
      p_tipo IN VARCHAR,
      mensajes OUT t_iax_mensajes)
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    -- ini BUG 0022444 - JMF - 05/06/2012
      Impresi¿¿n carta rechazo siniestro
       param in p_sseguro : numero sseguro
       param in p_tipo    : tipo de plantilla
       param out mensajes : mensajes de error
       return             : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_cartarechazosin(
      p_sseguro IN NUMBER,
      p_tipo IN VARCHAR,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_impresion;

   /*************************************************************************
    -- ini BUG 0021765 - JTS - 19/06/2012
      Impresi¿¿n cartas de preavisos
       param in p_sproces : Sproces
       param in p_tipo    : tipo de plantilla
       param out mensajes : mensajes de error
       return             : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_cartaspreavisos(
      p_sproces IN NUMBER,
      p_tipo IN VARCHAR,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_impresion;

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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
         Bug 22328 - 30/07/2012 - JRB
         Recupera algo
         param out PCURCAT : Select de las impresiones agrupadas
         param out mensajes : mensajes de error
         return             : objeto rutas ficheros
     *************************************************************************/
   FUNCTION f_get_impagrup(pcurcat OUT sys_refcursor, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
       Bug 22328 - 30/07/2012 - JRB
       Recupera algo
       param out PCURCAT : Select de las impresiones agrupadas
       param out mensajes : mensajes de error
       return             : objeto rutas ficheros
   *************************************************************************/
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       Bug 22328 - 30/07/2012 - JRB
       Recupera algo
       param out PCURCAT : Select de las impresiones agrupadas
       param out mensajes : mensajes de error
       return             : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_envia_impresora(
      plistcategorias IN VARCHAR2,
      plistdocs IN VARCHAR2,
      pidimpresora IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       Bug 22328 - 30/07/2012 - JRB
       Recupera algo
       param out PCURCAT : Select de las impresiones agrupadas
       param out mensajes : mensajes de error
       return             : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_get_categorias(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

     /*************************************************************************
       Bug 22328 - 30/07/2012 - JRB
       Recupera algo
       param out PCURCAT : Select de las impresiones agrupadas
       param out mensajes : mensajes de error
       return             : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_get_impresoras(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
       --BUG 24687 --JTS- 31/12/2010
      Impresi¿¿n sproces
      param in P_sproces   : ID. sproces
      param in P_TIPO      : ctipo
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_sproces(
      p_sproces IN NUMBER,
      p_tipo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_impresion;

   FUNCTION f_recupera_pendientes
      RETURN sys_refcursor;

   FUNCTION f_genera_pendientes(piddocdif IN NUMBER)
      RETURN sys_refcursor;

   FUNCTION f_gedox_pendiente(
      piddocdif IN NUMBER,
      pnorden IN NUMBER,
      ptfilename IN VARCHAR2,
      ptruta IN VARCHAR2)
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
          Descripci¿¿n: Envia un correo electronico con archivos los archivos de seguros
          Par¿¿metros entrada:
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
          Retorno:      0 OK / Retorno <> 0 Error
      ************************************************************************************************/
   FUNCTION f_imprimir_via_correo(
      pmodo IN VARCHAR2,
      ptevento IN VARCHAR2,
      pcidioma IN NUMBER,
      pdirectorio IN VARCHAR2,
      pdocumentos IN VARCHAR2,
      pmimestypes IN VARCHAR2,
      pdestinatarios IN VARCHAR2,
      psproduc IN VARCHAR2,
      psseguro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_imprimir_renovcero(p_sseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_impresion;

   FUNCTION f_imprimir_sproces_ccompani(
      p_sproces IN NUMBER,
      p_ccompani IN NUMBER,
      p_tipo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_impresion;

   FUNCTION f_imprimir_cashdesk(
      p_refdeposito IN NUMBER,
      p_tipo IN VARCHAR,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_impresion;

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
      Impresi¿¿n personas
      param in PSPERSON  : ID. persona
      param in P_TIPO      : ctipo de documento
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_sperson(
      p_sperson IN NUMBER,
      p_tipo IN VARCHAR2,
      -- INI - TCS_324B - JLTS - 11/02/2019. Se adiciona la opción idioma por parámetro
      p_cidiomarep    IN       NUMBER DEFAULT NULL,
      -- FIN - TCS_324B - JLTS - 11/02/2019.
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_impresion;

 /*************************************************************************
      --TCS_19 - ACL - 08/03/2019
      Impresión pagare contragarantia
      param in pscontgar  : ID. contragarantia
      param in P_TIPO      : ctipo de documento
      param out mensajes   : mensajes de error
      return               : objeto rutas ficheros
   *************************************************************************/
   FUNCTION f_imprimir_scontgar(
      p_scontgar IN NUMBER,
      p_tipo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_impresion;
END pac_iax_impresion;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_IMPRESION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_IMPRESION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_IMPRESION" TO "PROGRAMADORESCSI";
