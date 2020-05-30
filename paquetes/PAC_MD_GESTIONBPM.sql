--------------------------------------------------------
--  DDL for Package PAC_MD_GESTIONBPM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_GESTIONBPM" IS
/******************************************************************************
   NOMBRE:       PAC_MD_GESTIONBPM
   PROPÓSITO: Funciones para integracion de BPM con AXIS

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        27/09/2013   AMC              1. Creación del package.
******************************************************************************/

   /*******************************************************************************************
         FUNTION f_get_casos
         Función que retorna los casos de bpm
         param in pncaso_bpm. Número de caso BPM
         param in pnsolici_bpm. Número de solicitud BPM
         param in pcusuasignado. Usuario asignado
         param in pcestado. Estado del caso
         param in pctipmov_bpm. Tipo de movimiento
         param in pcramo. Ramo
         param in psproduc. Producto
         param in pnpoliza. Póliza
         param in pncertif. Certificado
         param in pnnumide. Número de identificación
         param in ptnomcom. Nombre del tomador

         Bug 28263/153355 - 27/09/2013 - AMC
     *******************************************************************************************/
   FUNCTION f_get_casos(
      pncaso_bpm IN NUMBER,
      pnsolici_bpm IN NUMBER,
      pcusuasignado IN VARCHAR2,
      pcestado IN NUMBER,
      pctipmov_bpm IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnnumide IN VARCHAR2,
      ptnomcom IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***************************************************************************************
   * Funcion f_get_tomcaso
   * Funcion que devuelve el nombre del tomador del cso BPM
   *
   * Parametros: pnnumcaso: Numero de caso
   *             pncaso_bpm: Numero de caso BPM
   *             pnsolici_bpm: Numero de solicitud BPM
   *             ptnomcom: Nombre completo del tomador
   *
   * Return: 0 OK, otro valor error.
   ****************************************************************************************/
   FUNCTION f_get_tomcaso(
      pnnumcaso IN NUMBER,
      pncaso_bpm IN NUMBER,
      pnsolici_bpm IN NUMBER,
      ptnomcom OUT VARCHAR2,
      pnnumcaso_out OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************
      Devuelve el caso bpm
       Parametros in: pnnumcaso: Numero de caso
                      pncaso_bpm: Numero de caso BPM
                      pnsolici_bpm: Numero de solicitud BPM
       param out mensajes : mesajes de error
      return             : caso bpm

      Bug 28263/153355 - 01/10/2013 - AMC
   *************************************************************************/
   FUNCTION f_lee_caso_bpm(
      pnnumcaso IN NUMBER,
      pncaso_bpm IN NUMBER,
      pnsolici_bpm IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_bpm;

       /*************************************************************************
      Valida los datos del caso bpm
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error

      Bug 28263/153355 - 02/10/2013 - AMC
   *************************************************************************/
   FUNCTION f_valida_datosbpm(
      poliza IN ob_iax_detpoliza,
      pmodo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Valida el tomador del caso bpm
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error

      Bug 28263/153355 - 02/10/2013 - AMC
   *************************************************************************/
   FUNCTION f_valida_tomadorbpm(poliza IN ob_iax_detpoliza, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Valida los datos del caso bpm para certificados
      param in pncaso_bpm: Numero de caso BPM
               pnsolici_bpm: Numero de solicitud BPM
               psproduc: Código del producto
               pnpoliza: Número de póliza
      return : 0 todo correcto
               <> 0 ha habido un error

      Bug 28263/153355 - 07/10/2013 - AMC
   *************************************************************************/
   FUNCTION f_valida_datosbpmcertif(
      pncaso_bpm IN NUMBER,
      pnsolici_bpm IN NUMBER,
      poliza IN ob_iax_detpoliza,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
       Recupera : Retorna un objeto ob_iax_bpm y determina si se debe mostrar o no por pantalla
       param in  psseguro  : codigo de seguro
       param in  pnmovimi  : número de movimiento
       param out pmostrar : indica si se debe mostrar el caso BPM
       param out mensajes : mensajes de error
       return             : ob_iax_bpm
    ***********************************************************************/
   FUNCTION f2_get_caso_bpm(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pmostrar OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_bpm;

   /*************************************************************************
      Valida los datos del caso bpm para certificados
      param in pnpoliza: Numero de póliza
               pncertif: Numero de certificado
               poperacion : Tipo de operacion.
      param out pcasobpm : Caso BPM
      return : 0 todo correcto
               <> 0 ha habido un error
   *************************************************************************/
   FUNCTION f_get_caso_bpm(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      poperacion IN VARCHAR2,
      pcasobpm OUT ob_iax_bpm,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
       Recupera : validaciónes BPM segun el tipo de operacion
       param in  pncaso_bpm  : numero de caso bpm
       param in  pnsolici_bpm: numero de solicitud bpm
       param in  psproduc    : codigo de producto
       param in  pnpoliza    : codigo de poliza
       param in  pncertif    : número de certificado
       param in  poperacion  : Tipo de operacion.
       param out mensajes    : mensajes de error
       return         NUMBER : 0--> OK , codigo error
    ***********************************************************************/
   FUNCTION f2_valida_datosbpm(
      pncaso_bpm IN NUMBER,
      pnsolici_bpm IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      poperacion IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      grabar registro en la tabla CASOS_BPMSEG
      param in
               psseguro:     identificador del seguro
               pnmovimi:     número de movimiento de seguro
               pncaso_bpm:   número del caso en el BPM
               pnsolici_bpm: número de la solicitud en el BPM
               pnnumcaso:    número del caso interno de iAxis
      return : 0 todo correcto
               <> 0  ha habido un error
   *************************************************************************/
   FUNCTION f_trata_movpoliza(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pncaso_bpm IN NUMBER,
      pnsolici_bpm IN NUMBER,
      pnnumcaso IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Valida los datos del caso bpm para cargas
      param in pncaso_bpm: Numero de caso BPM
               pnnumcaso: Numero de caso
               pfichero: nombre del fichero

      return : 0 todo correcto
               <> 0 ha habido un error

      Bug 28263/155558 - 14/10/2013 - AMC
   *************************************************************************/
   FUNCTION f_valida_datosbpmcarga(
      pncaso_bpm IN NUMBER,
      pnnumcaso IN NUMBER,
      pfichero IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_gestionbpm;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_GESTIONBPM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_GESTIONBPM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_GESTIONBPM" TO "PROGRAMADORESCSI";
