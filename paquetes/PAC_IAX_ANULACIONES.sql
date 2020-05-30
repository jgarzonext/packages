--------------------------------------------------------
--  DDL for Package PAC_IAX_ANULACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_ANULACIONES" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_ANULACIONES
   PROPÓSITO: Funciones para anular una póliza

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        03/12/2007  ACC              1. Creación del package.
   1.1        02/03/2009  DCM              2. Modificaciones Bug 8850
   1.2        19/05/2009  JTS              3. 9914: IAX- ANULACIÓN DE PÓLIZA - Baja inmediata
   2.0        13/12/2010  ICV              4. 0016775: CRT101 - Baja de pólizas
   3.0        11/07/2012  APD              5. 0022826: LCOL_T010-Recargo por anulación a corto plazo
   4.0        26/09/2012  APD              6. 0022839: LCOL_T010-LCOL - Funcionalidad Certificado 0
   5.0        10-11-2012  JDS              7. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
   6.0        05-03-2013  APD              8. 0026151: LCOL - QT 6096 - Anular movimientos de carátula
******************************************************************************/

   /***********************************************************************
      Recupera los datos de la poliza
      param out psseguro  : código de seguro
      param out onpoliza  : número de póliza
      param out oncertif  : número de certificado
      param out ofefecto  : fecha efecto
      param out ofvencim  : fecha vencimiento
      param out ofrenovac : fecha proxima cartera
      param out osproduc  : código del producto de la póliza
      param out otproduc  : título del producto
      param out otsituac  : descripción de la situación de la póliza
      param out mensajes  : mensajes de error
      return              : 0 todo ha sido correcto
                            1 ha habido un error
   ***********************************************************************/
   FUNCTION f_get_datpoliza(
      psseguro IN NUMBER,
      onpoliza OUT NUMBER,
      oncertif OUT NUMBER,
      ofefecto OUT DATE,
      ofvencim OUT DATE,
      ofrenovac OUT DATE,
      osproduc OUT NUMBER,
      otproduc OUT VARCHAR2,
      otsituac OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera los datos del tomador de la poliza
      param in psseguro  : código de seguro
      param out mensajes : mensajes de error
      return             : objeto tomadores
   ***********************************************************************/
   FUNCTION f_get_tomadores(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_tomadores;

   /***********************************************************************
      Recupera los datos de los recibos de la poliza
      param in psseguro  : código de seguro
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_recibos(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Recupera los datos de los siniestros de la poliza
      param in psseguro  : código de seguro
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_siniestros(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Dato el tipo de anulación calcula la fecha de la anulación
      param in psseguro  : código de seguro
      param in pctipanul : código tipo de anulación
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_set_tipanulacion(
      psseguro IN NUMBER,
      pctipanul IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN DATE;

   /***********************************************************************
      Procesa la anulación de la póliza
      param in psseguro  : código de seguro
      param in pctipanul : código tipo de anulación
      param in pfanulac  : fecha anulación
      param in pmotanula : motivo anulación
      param out mensajes : mensajes de error
      param in precextrn default 0 : indica si se debe procesar el extorno
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   ***********************************************************************/
   -- Bug 22826 - APD - 11/07/2012 - se añade el parametro paplica_penali
   -- Bug 22839 - APD - 26/09/2012 - se cambia el nombre de la funcion por f_anulacion_poliza
   -- se añade el parametro pbajacol = 0.Se está realizando la baja de un certificado normal
   -- 1.Se está realizando la baja del certificado 0
   -- Bug 26151 - APD - 26/02/2013 - se añade el parametro pcommit para indicar si se debe
   -- realizar el COMMIT/ROLLBACK (1) o no (0)
   FUNCTION f_anulacion_poliza(
      psseguro IN NUMBER,
      pctipanul IN NUMBER,
      pfanulac IN DATE,
      pccauanul IN NUMBER,
      pmotanula IN VARCHAR2,
      precextrn IN NUMBER,
      panula_rec IN NUMBER,
      precibos IN VARCHAR2,
      paplica_penali IN NUMBER,
      pbajacol IN NUMBER DEFAULT 0,
      pimpextorsion IN NUMBER DEFAULT 0,
      mensajes OUT t_iax_mensajes,
      panumasiva IN NUMBER DEFAULT 0,
      pcommit IN NUMBER DEFAULT 1)
      RETURN NUMBER;

   --BUG 9914 - JTS - 19/05/2009
   /*************************************************************************
      FUNCTION f_get_reccobrados
      param in psseguro  : Num. seguro
      param in pfanulac  : Fecha de anulacion
      param out pcursor  : sys_refcursor
      param out mensajes : t_iax_mensajes
      return             : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_reccobrados(
      psseguro IN NUMBER,
      pfanulac IN DATE,
      pcursor OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_get_recpendientes
      param in psseguro  : Num. seguro
      param in pfanulac  : Fecha de anulacion
      param out pcursor  : sys_refcursor
      param out mensajes : t_iax_mensajes
      return             : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_recpendientes(
      psseguro IN NUMBER,
      pfanulac IN DATE,
      pcursor OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
     Valida si es pot anular la pólissa a aquella data
     Paràmetres entrada:
        psSeguro : Identificador de l'assegurança   (obligatori)
        pFAnulac : Data d'anulació de la pòlissa    (obligatori)
        pValparcial : Valida parcialmente              (opcional)
                      1 posició = 0 o 1
                      2 posició = 1 no valida dies anulació (11)
                      3 posició = 1 ...
    Torna :
        0 si es permet anular la pòlissa, 1 KO
   **************************************************************************/
   FUNCTION f_val_fanulac(
      psseguro IN NUMBER,
      pfanulac IN DATE,
      pvalparcial IN NUMBER DEFAULT 0,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

--Fi BUG 9914 - JTS - 19/05/2009

   --ini BUG10772-22/07/2009-JMF: CRE - Desanul·lar programacions al venciment/propera cartera
   /***********************************************************************
      Comprobar si es posible desanular una póliza.
      param in  psseguro  : código de seguro
      param out oestado   : Estado 0.- no se puede desanular, 1.- se puede desanular
      param out mensajes  : mensajes de error
      return              : 0 todo ha sido correcto
                            1 ha habido un error
   ***********************************************************************/
   FUNCTION f_es_desanulable(
      psseguro IN NUMBER,
      oestado OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   --fin BUG10772-22/07/2009-JMF: CRE - Desanul·lar programacions al venciment/propera cartera

   --ini BUG10772-22/07/2009-JMF: CRE - Desanul·lar programacions al venciment/propera cartera
   /***********************************************************************
      Realizar la desanulación de una póliza.
      param in psseguro  : código de seguro
      param in pfanulac  : fecha anulación
      param in pnsuplem  : número suplemento
      param out mensajes : mensajes de error
      return             : 0.- proceso correcto
                           1.- error
   ***********************************************************************/
   FUNCTION f_desanula_poliza_vto(
      psseguro IN NUMBER,
      pfanulac IN DATE,
      pnsuplem IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

--fin BUG10772-22/07/2009-JMF: CRE - Desanul·lar programacions al venciment/propera cartera

   --Ini Bug.: 16775 - ICV - 30/11/2010
     /***********************************************************************
        Función que realiza una solicitud de Anulación.
        param in psseguro  : código de seguro
        param in pctipanul  : tipo anulación
        param in pnriesgo  : número de riesgo
        param in pfanulac  : fecha anulación
        param in ptobserv  : Observaciones.
        param in pTVALORD  : Descripción del motivio.
        param in pcmotmov  : Causa anulacion.
        param out mensajes : mensajes de error
        return             : 0.- proceso correcto
                             1.- error
     ***********************************************************************/
   FUNCTION f_set_solanulac(
      psseguro IN NUMBER,
      pctipanul IN NUMBER,
      pnriesgo IN NUMBER,
      pfanulac IN DATE,
      ptobserv IN VARCHAR2,
      ptvalord IN VARCHAR2,
      pcmotmov IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

--Fin Bug.: 16775

   /***********************************************************************
     Funcion para determinar si se debe mostrar o no el check Anulacion a corto plazo
    1.   psproduc: Identificador del producto (IN)
    2.   pcmotmov: Motivo de movimiento (IN)
    3.   psseguro: Identificador de la poliza (IN)
    4.   pcvisible: Devuelve 0 si no es visible, 1 si si es visible (OUT)
      return             : NUMBER (0 --> OK)
   ***********************************************************************/
   -- Bug 22826 - APD - 12/07/2012- se crea la funcion
   -- Bug 23817 - APD - 04/10/2012 - se añade el parametro psseguro
   FUNCTION f_aplica_penali_visible(
      psproduc IN NUMBER,
      pcmotmov IN NUMBER,
      psseguro IN NUMBER,
      pcvisible OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Procesa la anulación de la póliza comprobando primero si se trata
      de un certificado 0 o no
      param in psseguro  : código de seguro
      param in pctipanul : código tipo de anulación
      param in pfanulac  : fecha anulación
      param in pmotanula : motivo anulación
      param out mensajes : mensajes de error
      param in precextrn default 0 : indica si se debe procesar el extorno
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   ***********************************************************************/
   FUNCTION f_anulacion(
      psseguro IN NUMBER,
      pctipanul IN NUMBER,
      pfanulac IN DATE,
      pccauanul IN NUMBER,
      pmotanula IN VARCHAR2,
      precextrn IN NUMBER,
      panula_rec IN NUMBER,
      precibos IN VARCHAR2,
      paplica_penali IN NUMBER,
      mensajes OUT t_iax_mensajes,
      pimpextorsion IN NUMBER DEFAULT 0,
      pcommitpag IN NUMBER DEFAULT 1,
      ptraslado IN NUMBER DEFAULT 0)
      RETURN NUMBER;
END pac_iax_anulaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_ANULACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_ANULACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_ANULACIONES" TO "PROGRAMADORESCSI";
