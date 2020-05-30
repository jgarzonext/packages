--------------------------------------------------------
--  DDL for Package PAC_IAX_CONVENIOS_EMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_CONVENIOS_EMP" IS
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
      mensajes OUT t_iax_mensajes)
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
      mensajes OUT t_iax_mensajes)
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
      mensajes OUT t_iax_mensajes)
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
      ptcodconv IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_convempvers;

        /***********************************************************************
      Graba el convenio y valida en la propuesta (pantalla de datos de gestión o simulación).
         param in pversion  :  Versión
       param out  mensajes : mensajes de error
      return             : number
   ***********************************************************************/
   FUNCTION f_get_grabarconvempvers(
      pversion IN ob_iax_convempvers,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_proceso_camb_verscon(
      ptcodconv IN VARCHAR2,
      pcidioma IN NUMBER,
      psproces OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_proceso_anul_verscon(
      ptcodconv IN VARCHAR2,
      pcidioma IN NUMBER,
      psproces OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

      /***********************************************************************
      Devuelve un sys_refcursor con los asegurados de un riesgo
      param in pversion  :  VersiÃ³n
      param out  mensajes : mensajes de error
      return             : number
   ***********************************************************************/
   FUNCTION f_get_asegurados_innom(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnombre IN VARCHAR2,
      pnmovimi IN NUMBER,
      pfecha IN DATE,
      mensajes OUT t_iax_mensajes)
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
      ptcodconv IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_convempvers;
END pac_iax_convenios_emp;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_CONVENIOS_EMP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CONVENIOS_EMP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CONVENIOS_EMP" TO "PROGRAMADORESCSI";
