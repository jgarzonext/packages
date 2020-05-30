--------------------------------------------------------
--  DDL for Package PAC_MD_MNTDTOSESPECIALES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_MNTDTOSESPECIALES" IS
/******************************************************************************
    NOMBRE:      PAC_MD_MNTDTOSESPECIALES
    PROPÓSITO:   Funciones para la gestión de descuentos especiales

    REVISIONES:
    Ver        Fecha        Autor             Descripción
    ---------  ----------  ---------  ------------------------------------
    1.0        15/05/2013   AMC       1. Creación del package. Bug 26615/143210
******************************************************************************/

   /**********************************************************************************************
      Función para recuperar campañas
      param out mensajes:        mensajes informativos

      Bug 26615/143210 - 16/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_get_campanyas(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /**********************************************************************************************
       Función para recuperar campañas
        param in pccampanya:   campaña
        param in pfecini:   fecha inicio campaña
        param in pcfecfin:  fecha fin campaña
        param out dtosespe: t_iax_dtosespeciales
        param out mensajes: mensajes informativos


       Bug 26615/143210 - 16/05/2013 - AMC
    ************************************************************************************************/
   FUNCTION f_get_dtosespeciales(
      pccampanya IN NUMBER,
      pfecini IN DATE,
      pfecfin IN DATE,
      pdtosespe IN OUT t_iax_dtosespeciales,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /**********************************************************************************************
       Función para insertar un descuento
       param in pccampanya:

       Bug 26615/143210 - 22/05/2013 - AMC
    ************************************************************************************************/
   FUNCTION f_set_dtosespeciales(
      pccampanya IN NUMBER,
      pfecini IN DATE,
      pfecfin IN DATE,
      pmodo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /**********************************************************************************************
      Función para insertar el detalle de un descuento
      param in pccampanya:

      Bug 26615/143210 - 22/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_set_dtosespeciales_lin(
      pccampanya IN NUMBER,
      psproduc IN NUMBER,
      pcpais IN NUMBER,
      pcdpto IN NUMBER,
      pcciudad IN NUMBER,
      pcagrupa IN VARCHAR2,
      pcsucursal IN NUMBER,
      pcintermed IN NUMBER,
      ppdto IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /**********************************************************************************************
      Función para recuperar campañas
       param in pccampanya:   campaña
       param out dtosespe: ob_iax_dtosespeciales
       param out mensajes: mensajes informativos


      Bug 26615/143210 - 16/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_get_dtosespecial(
      pccampanya IN NUMBER,
      pdtosespe IN OUT ob_iax_dtosespeciales,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /**********************************************************************************************
      Función para borrar un descuento
      param in pccampanya:

      Bug 26615/143210 - 22/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_del_dtosespeciales(pccampanya IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /**********************************************************************************************
      Función para borrar el detalle de un descuento
      param in pccampanya:

      Bug 26615/143210 - 22/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_del_dtosespeciales_lin(
      pccampanya IN NUMBER,
      psproduc IN NUMBER,
      pcpais IN NUMBER,
      pcdpto IN NUMBER,
      pcciudad IN NUMBER,
      pcagrupa IN VARCHAR2,
      pcsucursal IN NUMBER,
      pcintermed IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /**********************************************************************************************
      Función para recuperar las agrupaciones tipo
      param IN OUT mensajes
      return cursor con los valores

      Bug 26615/143210 - 23/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_get_cagrtipo(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;
END pac_md_mntdtosespeciales;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTDTOSESPECIALES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTDTOSESPECIALES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTDTOSESPECIALES" TO "PROGRAMADORESCSI";
