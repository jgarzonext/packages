--------------------------------------------------------
--  DDL for Package PAC_IAX_DOCREQUERIDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_DOCREQUERIDA" AS
   /******************************************************************************
      NOMBRE:       PAC_IAX_DOCREQUERIDA
      PROPÓSITO: Funciones relacionadas con la documentación requerida

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  --------  ------------------------------------
      1.0        10/05/2011   JMP      1. Creación del package.
   ******************************************************************************/

   /*************************************************************************
         F_GET_DIRECTORIO
      Obtiene el directorio donde se subirán los ficheros.
      param out ppath                : directorio
      param out t_iax_mensajes       : mensajes de error
      return                         : 0 todo correcto
                                       1 ha habido un error
   *************************************************************************/
   FUNCTION f_get_directorio(ppath OUT VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --INI 18351: LCOL003 - Documentación requerida en contratación y suplementos
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

--FIN 18351: LCOL003 - Documentación requerida en contratación y suplementos

   /*************************************************************************
         f_tienerequerida
      Obtiene 1 si el producto tiene documentació requerida
      return                         : 0 no
                                       1 si
   *************************************************************************/
   FUNCTION f_tienerequerida(psproduc IN NUMBER)
      RETURN NUMBER;

    /*************************************************************************
    F_AVISO_DOCREQ_PENDIENTE
      param in  psseguro                : sseguro
      param in  pnmovimi                : Numero de movimiento de la poliza
      param out t_iax_mensajes       : mensajes de error
      return                         : 0 todo correcto
                                       1 Tiene documentacion requerida pendiente
   ****************************************************************************/
   FUNCTION f_docreq_pendiente(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
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
      mensajes OUT t_iax_mensajes)
      RETURN T_IAX_DOCREQUERIDA;

   /*************************************************************************
      F_GRABARDOCREQUERIDAPOL
      Actualiza y guarda en gedox la documentacion de la poliza.
      param in pseqdocu                : número secuencial de documento
      param in psproduc                : código de producto
      param in psseguro                : número secuencial de seguro
      param in pcactivi                : código de actividad
      param in pnmovimi                : número de movimiento
      param in pnriesgo                : número de riesgo
      param in pninqaval               : número de inquilino/avalista
      param in pcdocume                : código de documento
      param in pctipdoc                : tipo de documento
      param in pcclase                 : clase de documento
      param in pnorden                 : número de orden documento
      param in ptdescrip               : descripción del documento
      param in ptfilename              : nombre del fichero
      param in padjuntado              : indicador de fichero adjuntado
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_docrequerida;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_DOCREQUERIDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DOCREQUERIDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DOCREQUERIDA" TO "PROGRAMADORESCSI";
