--------------------------------------------------------
--  DDL for Package PAC_MD_GEDOX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_GEDOX" AS
/******************************************************************************
   NOMBRE:      PAC_MD_GEDOX
   PROPÓSITO: Funciones para la gestión de la comunicación con GEDOX

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        30/01/2008   JTS                1. Creación del package.
   2.0        12/03/2009   DCT                2. Modificar F_Get_DocumMov
   3.0        11/02/2010   XPL                3. 0012116: CEM - SINISTRES: Adjuntar documentació manualment i guardar-la al GEDOX
   4.0        30/05/2012   MDS                4. 0022267: LCOL_P001 - PER - Documentaci?n obligatoria subir a Gedox y si es persona o p?liza
   5.0        30/10/2012   FPG                5. 0028129: LCOL899-Desarrollo interfases BPM-iAXIS
   6.0        01/07/2014   ALF                6. modificacio f_set_documgedox per rebre parametre pidfichero
   9.1        06/10/2016   NMM                9.1.CONF-337. PARAM PDIR f_set_documpersgedox
******************************************************************************/

   /***********************************************************************
      Recupera un identificador pel fitxer
      param out mensajes : missatge d'error
      return             : identificador de la seqüéncia
   ***********************************************************************/
   FUNCTION f_get_docummov(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pusuari IN VARCHAR2,
      pcempres IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_docummov_exc(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pusuari IN VARCHAR2,
      pcempres IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Recupera un identificador pel fitxer
      param out mensajes : missatge d'error
      return             : 0/1 -> Tot OK/Error
   ***********************************************************************/
   FUNCTION f_get_idfichero(pid OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera un path de directori
      param in pparam : valor de path
      param out ppath    : pàrametre GEDOX
      param out mensajes : missatge d'error
      return             : 0/1 -> Tot OK/Error
   ***********************************************************************/
   FUNCTION f_get_directorio(
      pparam IN VARCHAR2,
      ppath OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Función que grava a GEDOX un fitxer ja generat en el directory compartit de GEDOX.
      param in psseguro    : Assegurança a la que cal vincular la
                             impressió.
      param in pnmovimi    : Moviment al que pertany la impressió.
      param in puser       : Usuari que realitza la gravació del document.
      param in ptfilename  : Nom del fitxer a pujar al GEDOX.
      param in pnfilename  : Id del fitxer a pujar al GEDOX (fisic).
      param in pidfichero  : Descripció del fitxer a pujar al GEDOX.
      param in pidcat      : Categoria del fitxer a pujar al GEDOX.
      param out mensajes   : Missatges d'error.
      return               : 0/1 -> Tot OK/Error

   *************************************************************************/
   --11/02/2010#XPL#12116#Es canvia el nom de la funció, per a que sigui més especific
   FUNCTION f_set_docummovseggedox(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      puser IN VARCHAR2,
      ptfilename IN VARCHAR2,
      pidfichero IN OUT VARCHAR2,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      porigen IN NUMBER DEFAULT 0,
      mensajes IN OUT t_iax_mensajes,
      pctipdest IN NUMBER DEFAULT 1   -- Bug 22267 - MDS - 30/05/2012
                                   )
      RETURN NUMBER;

   /*************************************************************************
      Función que grava a GEDOX un fitxer ja generat en el directory compartit de GEDOX.
      I actualitzar la taula sin_tramita_documento amb iddoc del gedox
      param in pnsinies    : Núm Sinistre
      param in pntramit    : Núm. Tramitació
      param in pndocume    : id intern de la taula sin_tramita_documentos
      param in ptfilename  : Nom del fitxer a pujar al GEDOX.
      param in pnfilename  : Id del fitxer a pujar al GEDOX (fisic).
      param in pidfichero  : Descripció del fitxer a pujar al GEDOX.
      param in pidcat      : Categoria del fitxer a pujar al GEDOX.
      param in porigen      : Origen (SINISTRES, CONS.POL...)
      param out mensajes   : Missatges d'error.
      return               : 0/1 -> Tot OK/Error

   *************************************************************************/
--11/02/2010#XPL#12116#0012116: CEM - SINISTRES: Adjuntar documentació manualment i guardar-la al GEDOX
   FUNCTION f_set_documsinistresgedox(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pndocume IN NUMBER,
      puser IN VARCHAR2,
      ptfilename IN VARCHAR2,
      pidfichero IN NUMBER,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      porigen IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
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
      Visualización de un documento almacenado en GEDOX
      param in piddoc      : Id. del documento que se debe visualizar
      param out ptpath     : Ruta del fichero que se debe visualizar
      param out mensajes   : mensajes de error
      return               : 0/1 -> Ok/Error
   *************************************************************************/
   FUNCTION f_gedox_verdoc(piddoc IN NUMBER, optpath OUT VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera un identificador pel fitxer
      param out mensajes : missatge d'error
      return             : identificador de la seqüéncia
   ***********************************************************************/
   FUNCTION f_get_docummov_requerida(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pusuari IN VARCHAR2,
      pcempres IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Función que inserta un documento en GEDOX  y hace el insert del registro
      de documentación en la tabla PER_DOCUMENTOS.
      param in psperson : Id. de la persona
      param in pcagente : codigo del agente
      param in puser : Usuario
      param in pfcaduca : Fecha de caducidad del documento
      param in ptobserva : Observaciones
      param in ptfilename : Nombre del fichero
      param in out piddocgedox : Identificador del documento GEDOX
      param in ptdesc : Descripcion
      param in pidcat : Categoría del documento
      param in ptdocumento : Tipo del documento
      param in pedocumento : Estado del documento
      param in pfedo : Fecha de estado del documento
      param out mensajes   : mensajes de error
      return               : 0/1 -> Ok/Error
   *************************************************************************/
   FUNCTION f_set_documpersgedox(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      puser IN VARCHAR2,
      pfcaduca IN DATE,
      ptobserva IN VARCHAR2,
      ptfilename IN VARCHAR2,
      piddocgedox IN OUT NUMBER,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      ptdocumento IN NUMBER DEFAULT NULL,
      pedocumento IN NUMBER DEFAULT NULL,
      pfedo IN DATE DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes,
      pdir IN VARCHAR2 DEFAULT NULL   -- NMM.CONF-337
                                   )
      RETURN NUMBER;

    /*************************************************************************
      FunciÃ³n que inserta un documento en GEDOX  y hace el insert del registro
      de documentaciÃ³n en la tabla PER_DOCUMENTOS.
      param in pcagente : codigo del agente
      param in puser : Usuario
      param in pfcaduca : Fecha de caducidad del documento
      param in ptobserva : Observaciones
      param in ptamano : Tamaño del fichero
      param in ptfilename : Nombre del fichero
      param in out piddocgedox : Identificador del documento GEDOX
      param in ptdesc : Descripcion
      param in pidcat : CategorÃ­a del documento
      param out mensajes   : mensajes de error
      return               : 0/1 -> Ok/Error

      Bug 21543/108711 - AMC - 02/03/2012
   *************************************************************************/
   FUNCTION f_set_documagegedox(
      pcagente IN NUMBER,
      puser IN VARCHAR2,
      pfcaduca IN DATE,
      ptobserva IN VARCHAR2,
      ptamano IN VARCHAR2,
      ptfilename IN VARCHAR2,
      piddocgedox IN OUT NUMBER,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_tamanofit(
      pidgedox IN NUMBER,
      ptamano OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_documinspeccion(
      pcgenerado IN NUMBER,
      puser IN VARCHAR2,
      ptfilename IN VARCHAR2,
      pidfichero IN OUT VARCHAR2,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      porigen IN NUMBER DEFAULT 0,
      mensajes IN OUT t_iax_mensajes,
      pctipdest IN NUMBER DEFAULT 1,
      piddoc_out OUT NUMBER)
      RETURN NUMBER;

   -- BUG 21192 / NSS / 21-03-13 --
   /*************************************************************************
      Función que inserta un documento en GEDOX  y hace el insert del registro
      de documentación en la tabla SIN_PROF_DOC.
      param in psprofes : Id. del profesional
      param in puser : Usuario
      param in pfcaduca : Fecha de caducidad del documento
      param in ptobserva : Observaciones
      param in ptfilename : Nombre del fichero
      param in out piddocgedox : Identificador del documento GEDOX
      param in ptdesc : Descripcion
      param in pidcat : Categoría del documento
      param out mensajes   : mensajes de error
      return               : 0/1 -> Ok/Error
   *************************************************************************/
   FUNCTION f_set_documprofgedox(
      psprofes IN NUMBER,
      puser IN VARCHAR2,
      pfcaduca IN DATE,
      ptobserva IN VARCHAR2,
      ptfilename IN VARCHAR2,
      piddocgedox IN OUT NUMBER,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-- FIN BUG 21192 / NSS / 21-03-13 --

   -- INI BUG 28129 - FPG - 30-10-2013 -
   /*************************************************************************
      Función que inserta un documento en GEDOX.
      param in puser : Usuario
      param in ptfilename : Nombre del fichero
      param in out piddocgedox : Identificador del documento GEDOX
      param in ptdesc : Descripcion del documento
      param in pidcat : Categoría del documento
      param out mensajes   : mensajes de error
      return               : 0/1 -> Ok/Error
   *************************************************************************/
   FUNCTION f_set_documgedox(
      puser IN VARCHAR2,
      ptfilename IN VARCHAR2,
      piddocgedox IN OUT NUMBER,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes,
      pidfichero IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

-- FIN BUG 28129 - FPG - 30-10-2013 -
   FUNCTION f_set_docummovseg(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      puser IN VARCHAR2,
      ptfilename IN VARCHAR2,
      pidfichero IN VARCHAR2,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      porigen IN NUMBER DEFAULT 0,
      mensajes IN OUT t_iax_mensajes,
      pctipdest IN NUMBER DEFAULT 1)
      RETURN NUMBER;

   FUNCTION f_set_docummovcompanigedox(
      pccompani IN NUMBER,
      puser IN VARCHAR2,
      ptfilename IN VARCHAR2,
      pidfichero IN OUT VARCHAR2,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   --CONF - 236 JAVENDANO 22/08/2016
   FUNCTION f_calcula_fecha_aec(pcmodo IN NUMBER)
      RETURN DATE;

   FUNCTION f_set_gca_docgsfavclis(
      pidobs IN NUMBER,
      puser IN VARCHAR2,
      ptfilename IN VARCHAR2,
      pidfichero IN OUT VARCHAR2,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

 /*************************************************************************
      Función que inserta un documento en GEDOX  y hace el insert del registro
      de documentación en la tabla ctgar_doc.
      param in psperson : Id. de la persona
      param in pCONTRA : codigo de LA contraGARANTIA
      param in puser : Usuario
      param in pfcaduca : Fecha de caducidad del documento
      param in ptobserva : Observaciones
      param in ptfilename : Nombre del fichero
      param in out piddocgedox : Identificador del documento GEDOX
      param in ptdesc : Descripcion
      param in pidcat : Categoría del documento
      param in ptdocumento : Tipo del documento
      param in pedocumento : Estado del documento
      param in pfedo : Fecha de estado del documento
      param out mensajes   : mensajes de error
      return               : 0/1 -> Ok/Error
   *************************************************************************/
   FUNCTION f_set_documcontragedox(
      psperson IN NUMBER,
      pcontra IN NUMBER,
      PNMOVIMI IN NUMBER,
      puser IN VARCHAR2,
      pfcaduca IN DATE,
      ptobserva IN VARCHAR2,
      ptfilename IN VARCHAR2,
      piddocgedox IN OUT NUMBER,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      ptdocumento IN NUMBER DEFAULT NULL,
      pedocumento IN NUMBER DEFAULT NULL,
      pfedo IN DATE DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes,
      pdir IN VARCHAR2 DEFAULT NULL   -- NMM.CONF-337
      )
      RETURN NUMBER;

   /*************************************************************************
      Función que inserta un documento en GEDOX  y hace el insert del registro
      de documentación en la tabla AGD_OBSERVACIONES.
      param in psperson : Id. de la persona
      param in pcagente : codigo del agente
      param in puser : Usuario
      param in pfcaduca : Fecha de caducidad del documento
      param in ptobserva : Observaciones
      param in ptfilename : Nombre del fichero
      param in out piddocgedox : Identificador del documento GEDOX
      param in ptdesc : Descripcion
      param in pidcat : Categoría del documento
      param in ptdocumento : Tipo del documento
      param in pedocumento : Estado del documento
      param in pfedo : Fecha de estado del documento
      param out mensajes   : mensajes de error
      return               : 0/1 -> Ok/Error
   *************************************************************************/
   FUNCTION f_set_documobservagedox(
      ptfilename IN VARCHAR2,
      piddocgedox IN OUT NUMBER,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_gedox;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_GEDOX" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_GEDOX" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_GEDOX" TO "PROGRAMADORESCSI";
