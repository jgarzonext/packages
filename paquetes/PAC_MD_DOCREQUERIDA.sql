--------------------------------------------------------
--  DDL for Package PAC_MD_DOCREQUERIDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_DOCREQUERIDA" AS
   /******************************************************************************
      NOMBRE:       PAC_MD_DOCREQUERIDA
      PROPÓSITO: Funciones relacionadas con la documentación requerida

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  --------  ------------------------------------
      1.0        10/05/2011   JMP      1. Creación del package.
   ******************************************************************************/
   /*************************************************************************
         F_GET_DIRECTORIO
      Obtiene el directorio donde se subirán los ficheros.
      param in pparam                : código de parámetro
      param out ppath                : directorio
      param in out t_iax_mensajes    : mensajes de error
      return                         : 0 todo correcto
                                       1 ha habido un error
   *************************************************************************/
   FUNCTION f_get_directorio(
      pparam IN VARCHAR2,
      ppath OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
         F_SUBIR_DOCSGEDOX
      Realiza la subida de los documentos requeridos al GEDOX.
      param in psseguro              : número secuencial de seguro
      param in pnmovimi              : número de movimiento
      param in out t_iax_mensajes    : mensajes de error
      return                         : 0 todo correcto
                                       1 ha habido un error
   *************************************************************************/
   FUNCTION f_subir_docsgedox(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    F_AVISO_DOCREQ_PENDIENTE
      Para las empreses que deben retener la emisión porque hay documentación requerida
      obligatoaria, devuelve un mensaje de confirmación
      param in  psseguro                : sseguro
      param in  pnmovimi                : Numero de movimiento de la poliza
      param out t_iax_mensajes       : mensajes de error
      return                         : 0 todo correcto
                                       1 aviso
                                       2 error
   ****************************************************************************/
   FUNCTION f_aviso_docreq_pendiente(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    f_retencion
      Crear retención por falta de documentación
      param in  psseguro                : sseguro
      param in  pnmovimi                : Numero de movimiento de la poliza
      param out t_iax_mensajes       : mensajes de error
      return                         : 0 todo correcto
                                       1 aviso
                                       2 error
   ****************************************************************************/
   FUNCTION f_retencion(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pfecha IN DATE,
      mensajes IN OUT t_iax_mensajes,
      pmotretencion IN NUMBER DEFAULT 16)
      RETURN NUMBER;

   /*************************************************************************
    F_DOCREQ_PENDIENTE
      Para las empreses que deben retener la emisión porque hay documentación requerida
      obligatoaria, devuelve un mensaje de confirmación
      param in  psseguro                : sseguro
      param in  pnmovimi                : Numero de movimiento de la poliza
      param out t_iax_mensajes       : mensajes de error
      return                         : 0 todo correcto
                                       1 aviso
                                       2 error
   ****************************************************************************/
   FUNCTION f_docreq_pendiente(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_docreq_pendiente(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER)
      RETURN NUMBER;
   /*************************************************************************
    F_GET_DOCUREQUERIDA
      param in  psseguro                : sseguro
      param in  pnmovimi                : Numero de movimiento de la poliza
      param out t_iax_mensajes       : mensajes de error
      return                         : SYS_REFCURSOR
   ****************************************************************************/
   FUNCTION f_get_docurequerida(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN T_IAX_DOCREQUERIDA;

/*************************************************************************
      F_GRABARDOCREQUERIDAPOL
      Actualiza y guarda en gedox la documentacion de la poliza.
      param in pseqdocu                : parametro secuencial de documento
      param in psproduc                : parametro de producto
      param in psseguro                : parametro secuencial de seguro
      param in pcactivi                : parametro de actividad
      param in pnmovimi                : parametro de movimiento
      param in pnriesgo                : parametro de riesgo
      param in pninqaval               : parametro de inquilino/avalista
      param in pcdocume                : parametro de documento
      param in pctipdoc                : tipo de documento
      param in pcclase                 : clase de documento
      param in pnorden                 : parametro de orden documento
      param in ptdescrip               : Descripcion del documento
      param in ptfilename              : nombre del fichero
      param in padjuntado              : indicador de fichero adjuntado
      param in pciddocgedox            : numero id en GEDOX
      param in out mensajes            : mensajes de error
      return                           : 0 todo correcto
                                         1 ha habido un error
   *************************************************************************/
   FUNCTION f_grabardocrequeridapol(
      pseqdocu IN NUMBER,
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pcactivi IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pninqaval IN NUMBER,
      pcdocume IN NUMBER,
      pctipdoc IN NUMBER,
      pcclase IN NUMBER,
      pnorden IN NUMBER,
      ptdescrip IN VARCHAR2,
      ptfilename IN VARCHAR2,
      padjuntado IN NUMBER,
      pcrecibido IN NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pciddocgedox IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
END pac_md_docrequerida;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_DOCREQUERIDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DOCREQUERIDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DOCREQUERIDA" TO "PROGRAMADORESCSI";
