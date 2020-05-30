--------------------------------------------------------
--  DDL for Package PAC_MNTDTOSESPECIALES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MNTDTOSESPECIALES" IS
/******************************************************************************
    NOMBRE:      PAC_MNTDTOSESPECIALES
    PROPÓSITO:   Funciones para la gestión de descuentos especiales

    REVISIONES:
    Ver        Fecha        Autor             Descripción
    ---------  ----------  ---------  ------------------------------------
    1.0        15/05/2013   AMC       1. Creación del package. Bug 26615/143210
******************************************************************************/

   /**********************************************************************************************
      Función para recuperar campañas
      param in pccampanya:

      Bug 26615/143210 - 15/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_get_campanyas(pcidioma IN NUMBER)
      RETURN VARCHAR2;

/**********************************************************************************************
      Función para insertar un descuento
      param in pccampanya:

      Bug 26615/143210 - 22/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_set_dtosespeciales(
      pcempres IN NUMBER,
      pccampanya IN NUMBER,
      pfecini IN DATE,
      pfecfin IN DATE,
      pmodo IN VARCHAR2)
      RETURN NUMBER;

    /**********************************************************************************************
      Función para insertar el detalle de un descuento
      param in pccampanya:

      Bug 26615/143210 - 22/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_set_dtosespeciales_lin(
      pcempres IN NUMBER,
      pccampanya IN NUMBER,
      psproduc IN NUMBER,
      pcpais IN NUMBER,
      pcdpto IN NUMBER,
      pcciudad IN NUMBER,
      pcagrupa IN VARCHAR2,
      pcsucursal IN NUMBER,
      pcintermed IN NUMBER,
      ppdto IN NUMBER)
      RETURN NUMBER;

    /**********************************************************************************************
      Función para borrar un descuento
      param in pccampanya:

      Bug 26615/143210 - 22/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_del_dtosespeciales(pcempres IN NUMBER, pccampanya IN NUMBER)
      RETURN NUMBER;

    /**********************************************************************************************
      Función para borrar el detalle un descuento
      param in pccampanya:

      Bug 26615/143210 - 22/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_del_dtosespeciales_lin(
      pcempres IN NUMBER,
      pccampanya IN NUMBER,
      psproduc IN NUMBER,
      pcpais IN NUMBER,
      pcdpto IN NUMBER,
      pcciudad IN NUMBER,
      pcagrupa IN VARCHAR2,
      pcsucursal IN NUMBER,
      pcintermed IN NUMBER)
      RETURN NUMBER;

    /**********************************************************************************************
      Función para recuperar las agrupaciones tipo


      Bug 26615/143210 - 23/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_get_cagrtipo
      RETURN VARCHAR2;
END pac_mntdtosespeciales;

/

  GRANT EXECUTE ON "AXIS"."PAC_MNTDTOSESPECIALES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MNTDTOSESPECIALES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MNTDTOSESPECIALES" TO "PROGRAMADORESCSI";
