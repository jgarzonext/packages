--------------------------------------------------------
--  DDL for Package PAC_IAX_GEDOX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_GEDOX" AS
/******************************************************************************
   NOMBRE:      PAC_IAX_GEDOX
   PROP¿SITO: Funciones para la gesti¿n de la comunicaci¿n con GEDOX

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        17/01/2008   JTS                1. Creaci¿n del package.
   2.0        12/03/2009   DCT                2. Modificaci¿n funci¿n F_GET_DOCUMMOV
   3.0        11/02/2010   XPL                3. 0012116: CEM - SINISTRES: Adjuntar documentaci¿ manualment i guardar-la al GEDOX
   4.0        01/07/2014   ALF                4. modificacio f_set_documgedox per rebre parametre pidfichero
******************************************************************************/

   /***********************************************************************
      Recupera los documentos asociados a un movimiento de un seguro
      param in psseguro  : c¿digo de seguro
      param in pnmovimi  : n¿mero de movimiento del seguro
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_docummov(psseguro IN NUMBER, pnmovimi IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_docummov_exc(psseguro IN NUMBER, pnmovimi IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Recupera un path de directori
      param in pparam : valor de path
      param out ppath    : p¿rametre GEDOX
      param out mensajes : missatge d'error
      return             : 0 o c¿digo error
   ***********************************************************************/
   FUNCTION f_get_idfichero(pid OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera un path de directori
      param out ppath    : p¿rametre directorio trabajo GEDOX
      param out mensajes : missatge d'error
      return             : 0/1 -> Tot OK/Error
   ***********************************************************************/
   FUNCTION f_get_directorio(ppath OUT VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Funci¿n que grava a GEDOX un fitxer ja generat en el directory compartit de GEDOX.
      param in psseguro    : Asseguran¿a a la que cal vincular la
                             impressi¿.
      param in pnmovimi    : Moviment al que pertany la impressi¿.
      param in puser       : Usuari que realitza la gravaci¿ del document.
      param in ptfilename  : Nom del fitxer a pujar al GEDOX.
      param in pnfilename  : Id del fitxer a pujar al GEDOX (fisic).
      param in pidfichero  : Descripci¿ del fitxer a pujar al GEDOX.
      param in pidcat      : Categoria del fitxer a pujar al GEDOX.
      param out mensajes   : Missatges d'error.
      return               : 0/1 -> Tot OK/Error

   *************************************************************************/
   --11/02/2010#XPL#12116#Es canvia el nom de la funci¿, per a que sigui m¿s especific
   FUNCTION f_set_docummovseggedox(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      ptfilename IN VARCHAR2,
      pidfichero IN NUMBER,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      porigen IN NUMBER DEFAULT 0,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Funci¿n que grava a GEDOX un fitxer ja generat en el directory compartit de GEDOX.
      I actualitzar la taula sin_tramita_documento amb iddoc del gedox
      param in pnsinies    : N¿m Sinistre
      param in pntramit    : N¿m. Tramitaci¿
      param in pndocume    : id intern de la taula sin_tramita_documentos
      param in ptfilename  : Nom del fitxer a pujar al GEDOX.
      param in pnfilename  : Id del fitxer a pujar al GEDOX (fisic).
      param in pidfichero  : Descripci¿ del fitxer a pujar al GEDOX.
      param in pidcat      : Categoria del fitxer a pujar al GEDOX.
      param in porigen      : Origen (SINISTRES, CONS.POL...)
      param out mensajes   : Missatges d'error.
      return               : 0/1 -> Tot OK/Error

   *************************************************************************/
   --11/02/2010#XPL#12116#0012116: CEM - SINISTRES: Adjuntar documentaci¿ manualment i guardar-la al GEDOX
   FUNCTION f_set_documsinistresgedox(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pndocume IN NUMBER,
      ptfilename IN VARCHAR2,
      pidfichero IN NUMBER,
      ptdesc IN VARCHAR2,
      pidcat IN NUMBER,
      porigen IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera las categories
      param in pcidioma   : codi idioma
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_categor(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Visualizaci¿n de un documento almacenado en GEDOX
      param in piddoc      : Id. del documento que se debe visualizar
      param out mensajes   : mensajes de error
      return               : 0/1 -> Ok/Error
   *************************************************************************/
   FUNCTION f_gedox_verdoc(piddoc IN NUMBER, optpath OUT VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera los documentos asociados a un movimiento de un seguro
      param in psseguro  : c¿digo de seguro
      param in pnmovimi  : n¿mero de movimiento del seguro
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_docummov_requerida(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_tamanofit(
      pidgedox IN NUMBER,
      ptamano OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_documgedox(
      puser IN VARCHAR2,
      ptfilename IN VARCHAR2,
      pidfichero IN NUMBER,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      piddocgedox OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
     FUNCTION f_set_docummovcompanigedox(
               pccompani  IN NUMBER,
               ptfilename IN VARCHAR2,
               pidfichero IN OUT VARCHAR2,
               ptdesc     IN VARCHAR2 DEFAULT NULL,
               pidcat     IN NUMBER DEFAULT NULL,
               mensajes   OUT t_iax_mensajes)
          RETURN NUMBER;

     FUNCTION f_set_gca_docgsfavclis(
               pidobs  IN NUMBER,
               ptfilename IN VARCHAR2,
               pidfichero IN OUT VARCHAR2,
               ptdesc     IN VARCHAR2 DEFAULT NULL,
               pidcat     IN NUMBER DEFAULT NULL,
               mensajes   OUT t_iax_mensajes)
          RETURN NUMBER;
END pac_iax_gedox;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_GEDOX" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_GEDOX" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_GEDOX" TO "PROGRAMADORESCSI";
