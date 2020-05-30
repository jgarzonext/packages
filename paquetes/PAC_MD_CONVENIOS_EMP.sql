--------------------------------------------------------
--  DDL for Package PAC_MD_CONVENIOS_EMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_CONVENIOS_EMP" IS
         /******************************************************************************
      --      NOMBRE:       PAC_MD_CONVENIOS_EMP
            PROPOSITO: Tratamiento convenios en capa presentación

            REVISIONES:
            Ver        Fecha        Autor             Descripcion
            ---------  ----------  ---------------  ------------------------------------
            1.0        04/02/2015   JRH                1. Creacion del package.
   *****************************************************************************/

   /***********************************************************************
      Devuelve  los tramos de regularización para la consulta de detalle de  movimiento
         param in psseguro  : Número interno de seguro
       param in pnmovimi  : Número interno de pnmovimi
                mensajes : mensajes de error
      return             : number
   ***********************************************************************/
   FUNCTION f_get_tramosregul(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

    /***********************************************************************
      Devuelve  los datos del suplemento de regularización
         param in psseguro  : Número interno de seguro
       param in pnmovimi  : Número interno de pnmovimi
                mensajes : mensajes de error
      return             : number
   ***********************************************************************/
   FUNCTION f_datos_sup_regul(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

      /***********************************************************************
      Devuelve  los ámbitos de convenios para el producto
         param in psproduc  :  Producto
       param in pdescri  :  Descripción
                mensajes : mensajes de error
      return             : number
   ***********************************************************************/
   FUNCTION f_get_lstambitos(
      psproduc IN NUMBER,
      pdescri IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

      /***********************************************************************
      Devuelve  los convenios activos para el producto
         param in psproduc  :  Producto
       param in pdescri  :  Descripción
                mensajes : mensajes de error
      return             : number
   ***********************************************************************/
   FUNCTION f_get_lstconvempvers(
      psproduc IN NUMBER,
      pprovin IN NUMBER,
      pdescri IN VARCHAR2,
      ptcodconv IN VARCHAR2 DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_convempvers;

       /***********************************************************************
      Devuelve  los datos de una versión
         param in psproduc  :  psseguro  pidversion  pmodo
       param in pdescri  :  Descripción
                mensajes : mensajes de error
      return             : number
   ***********************************************************************/
   FUNCTION f_get_datosconvempvers(
      psseguro IN NUMBER,
      pidversion IN NUMBER,
      pmodo IN VARCHAR2,
      pidconv OUT NUMBER,
      ptcodconv OUT VARCHAR2,
      ptdescri OUT VARCHAR2,
      pcestado OUT NUMBER,
      pcperfil OUT NUMBER,
      pcvida OUT NUMBER,
      pcorganismo OUT NUMBER,
      pnversion OUT NUMBER,
      pcestadovers OUT NUMBER,
      pnversion_ant OUT NUMBER,
      pobserv OUT VARCHAR2)
      RETURN NUMBER;

/***********************************************************************
      Devuelve  los datos de una versión
         param in psproduc  :  psseguro  pidversion  pmodo
       param in pdescri  :  Descripción
                mensajes : mensajes de error
      return             : number
   ***********************************************************************/
   FUNCTION f_get_versioncon(psseguro IN NUMBER, pidversion IN NUMBER, pmodo IN VARCHAR2)
      RETURN ob_iax_convempvers;

      /***********************************************************************
      Devuelve  la versión activa del convenio de una póliza y su  fecha
      param in psproduc  :  psseguro
      param out pidversion  :  Id de la versión
      param out pfefecto  :  Fecha
      mensajes : mensajes de error
      return             : number
   ***********************************************************************/
   FUNCTION f_get_versactivaconv(pidconv IN NUMBER, pidversion OUT NUMBER, pfefecto OUT DATE)
      RETURN NUMBER;

       /******************************************************************
       F_ES_PRODUCTOCONVENIOS: Obtener si el producto es de convenios
       Devuelve:  1 - Si es convenios
               nnnn - No es de convenios (msj de error)
   *******************************************************************/
   FUNCTION f_es_productoconvenios(psproduc IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_convcontratable(pvers IN ob_iax_convempvers, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_proceso_camb_verscon(
      ptcodconv IN VARCHAR2,
      pcidioma IN NUMBER,
      psproces OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_proceso_anul_verscon(
      ptcodconv IN VARCHAR2,
      pcidioma IN NUMBER,
      psproces OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

----------------------------------------------------------------------------------------------
/***********************************************************************
      Devuelve un sys_refcursor con los asegurados de un riesgo
      PSSEGURO:  in Seguro
      PNRIESGO:  in Riesgo
      PNOMBRE:   in Nombre para buscar
      PNMOVIMI:  in Número de movimiento
      PFECHA:    in fecha
      MENSAJES:  in/out Objeto Mensaje

***********************************************************************/
   FUNCTION f_get_asegurados_innom(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnombre IN VARCHAR2,
      pnmovimi IN VARCHAR2,
      pfecha IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Devuelve  en la busqueda los convenios activos para el producto
         param in psproduc  :  Producto
       param in pdescri  :  Descripción
                mensajes : mensajes de error
      return             : number
      Bug 34461-210152 KJSC Por medio de email enviado el 28/07/2015 de Jordi Vidal se crea nueva funcion
   ***********************************************************************/
   FUNCTION f_get_lstconvemp(
      psproduc IN NUMBER,
      pprovin IN NUMBER,
      pdescri IN VARCHAR2,
      ptcodconv IN VARCHAR2 DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_convempvers;
END pac_md_convenios_emp;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_CONVENIOS_EMP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CONVENIOS_EMP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CONVENIOS_EMP" TO "PROGRAMADORESCSI";
