--------------------------------------------------------
--  DDL for Package PAC_EXCEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_EXCEL" AUTHID CURRENT_USER IS
/******************************************************************************
   NOMBRE:       PAC_EXCEL
   PROPÓSITO:
   REVISIONES:

   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
    1.0       -            -               1. Creación de package
    2.0       17/03/2009  RSC              2. Análisis adaptación productos indexados
    3.0       28/02/2011  APD              3. 0015707: ENSA102 - Valors liquidatius - Estat actual
******************************************************************************/
   TYPE nombre_fichero_typ IS RECORD(
      nombre         VARCHAR2(200)
   );

   TYPE nombre_fichero_tabtyp IS TABLE OF nombre_fichero_typ
      INDEX BY BINARY_INTEGER;

   v_nombre_fichero nombre_fichero_tabtyp;   -- Declaración de tabla PL/SQL
   cont           NUMBER := 0;
   exparametreincorrecte EXCEPTION;
   exerror        EXCEPTION;   -- Error indefinit

   /*
   Listado de solicitudes y altas de productos de Vida Risc para una fecha
   determinada. (JBP-8301)
   */
   FUNCTION f_fichero_produccion(
      pfecha IN DATE DEFAULT f_sysdate,
      cproces IN OUT NUMBER,
      pempres IN NUMBER)
      RETURN VARCHAR2;

   /*
   Listado de Provisión Matemática
   */
   FUNCTION f_alctr651(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pmesanyo IN DATE,
      pcramo IN ramos.cramo%TYPE,
      psproduc IN productos.sproduc%TYPE,
      pagente IN NUMBER,
      pusuidioma IN NUMBER,
      perror OUT VARCHAR2)
      RETURN nombre_fichero_tabtyp;

   /*
   Listado de Siniestros Abiertos y Reaperturados en un periodo
   */

   /*
   Inventario de Pólizas
   */
   FUNCTION f_sictr009(
      pcempres IN NUMBER,
      pcagrpro IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pagente IN NUMBER,
      pestado IN NUMBER,
      pusuidioma IN NUMBER,
      perror OUT VARCHAR2)
      RETURN nombre_fichero_tabtyp;

   /*
   Listado de Operaciones Económicas producidas en un periodo
   */
   FUNCTION f_sictr018(
      pcempres IN NUMBER,
      pcagrpro IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pagente IN NUMBER,
      pfechaini IN DATE,
      pfechafin IN DATE,
      pusuidioma IN NUMBER,
      perror OUT VARCHAR2)
      RETURN nombre_fichero_tabtyp;

   /*
   Listado de altas de certificados
   */
   FUNCTION f_snctr003(
      pfechaini IN DATE,
      pfechafin IN DATE,
      pempres IN NUMBER,
      psproduc IN NUMBER DEFAULT NULL,
      pcramo IN NUMBER DEFAULT NULL,
      pcagente IN NUMBER DEFAULT NULL,
      pcidioma IN NUMBER)
      RETURN VARCHAR2;

   /*
   Listado de bajas de certificados
   */
   FUNCTION f_snctr004(
      pfechaini IN DATE,
      pfechafin IN DATE,
      pempres IN NUMBER,
      psproduc IN NUMBER,
      pcramo IN NUMBER,
      pvincu IN NUMBER,
      pcidioma IN NUMBER)
      RETURN VARCHAR2;

   /***********************************************************************
    -- RSC 11/03/2008
    -- Listado de cierre de provisiones de siniestros con pagos pendientes de
       pago.
   ************************************************************************/
   FUNCTION f_snctr652(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pmesanyo IN DATE,
      pcramo IN ramos.cramo%TYPE,
      psproduc IN productos.sproduc%TYPE,
      pccausin IN siniestros.ccausin%TYPE,
      pcagente IN seguros.cagente%TYPE,
      pusuidioma IN NUMBER,
      perror OUT VARCHAR2)
      RETURN nombre_fichero_tabtyp;

      /*************************************************************************
     Operaciones del dia sobre contratos financieros de inversión.
     param in pcIdioma     : codigo de idioma
     param in pfFecha      : codigo de fecha
     param in pcEmpresa    : codigo de empresa
     param in pcRamo       : codigo de ramo
     param in psProduc     : codigo de producto
     param in pcAgente     : codigo de agente
     param out mensajes  : mesajes de error
     return              : descripción del acto
   *************************************************************************/
   -- Bug 9031 - 17/03/2009 - RSC -  iAxis: Análisis adaptación productos indexados
   FUNCTION f_sictr024finv(
      pcidioma IN seguros.cidioma%TYPE,
      pffecha IN DATE,
      pcempresa IN seguros.cempres%TYPE,
      pcramo IN ramos.cramo%TYPE,
      psproduc IN productos.sproduc%TYPE,
      pcagente IN seguros.cagente%TYPE,
      psprocesxml OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN nombre_fichero_tabtyp;
END pac_excel;

/

  GRANT EXECUTE ON "AXIS"."PAC_EXCEL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_EXCEL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_EXCEL" TO "PROGRAMADORESCSI";
