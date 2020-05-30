--------------------------------------------------------
--  DDL for Package PAC_MODELOS_FISCALES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MODELOS_FISCALES" AUTHID CURRENT_USER AS
   -- Constante de package (modelo 347)

   /******************************************************************************
      NAME:       pac_modelos_fiscales
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        29/11/2010    RSC             1. Created this package.
      2.0        30/11/2010    ETM             2. 0016875: 2010: Modelos 190 - 111  Se añaden nuevas funciones--
      3.0        26/07/2012    APD             3. 0022996: MDP_F001-Fiscalidad - crear el modelo 7

   ******************************************************************************/
   k_umbral_347   NUMBER := 3005.06;

   FUNCTION f_valida_alfabetico(ptexto IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_valida_alfanumerico(ptexto IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_valida_alfabeticonum(ptexto IN VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE p_concat_file_fismod345(lpath IN VARCHAR2, pfile1 IN VARCHAR2, pfile2 IN VARCHAR2);

   FUNCTION f_modelos_aho_rentas(
      pmodelo IN VARCHAR2,
      pany IN NUMBER,
      pcempres IN NUMBER,
      pcsoporte IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_modelos_planes(pmodelo IN VARCHAR2, pany IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_datos_irpfpersonas(
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pany IN NUMBER,
      pdato IN VARCHAR2,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_datos_irpfdescendientes(
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pany IN NUMBER,
      pdato IN VARCHAR2,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_datos_irpfmayores(
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pany IN NUMBER,
      pdato IN VARCHAR2,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_global_irpfpersonas(
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pany IN NUMBER,
      preducciones IN VARCHAR2,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_global_irpfdescendientes(
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pany IN NUMBER,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_global_irpfmayores(
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pany IN NUMBER,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /*BUG 16875 - 30/11/2010 - 00016875: 2010: Modelos 190 - 111  Se aÃ±aden nuevas funciones*/
   FUNCTION f_datos_irpfdescen_hijo(
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pnorden IN NUMBER,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

-- Bug 22996 - APD - 25/07/2012 - se crea la funcion
/******************************************************************************
--FUNCTION f_modelo_7_primas
--retorna la select del Modelo fiscal 7: Control de la provision para prestaciones - Primas

   PARAM
    1.   pfini. Fecha inicio del periodo. Obligatorio.
    2.   pffin. Fecha fin del periodo. Obligatorio.
    3.   pcempres. Identificador de la empresa. Obligatorio.
     RETORNA
     VARCHAR2 CON LA SELECT

******************************************************************************/
   FUNCTION f_modelo_7_primas(pfini IN DATE, pffin IN DATE, pcempres IN NUMBER)
      RETURN VARCHAR2;

-- Bug 22996 - APD - 25/07/2012 - se crea la funcion
/******************************************************************************
--FUNCTION f_modelo_7_siniestros
--retorna la select del Modelo fiscal 7: Control de la provision para prestaciones - Siniestros

   PARAM
    1.   pfini. Fecha inicio del periodo. Obligatorio.
    2.   pffin. Fecha fin del periodo. Obligatorio.
    3.   pcempres. Identificador de la empresa. Obligatorio.
     RETORNA
     VARCHAR2 CON LA SELECT

******************************************************************************/
   FUNCTION f_modelo_7_siniestros(pfini IN DATE, pffin IN DATE, pcempres IN NUMBER)
      RETURN VARCHAR2;
END pac_modelos_fiscales;

/

  GRANT EXECUTE ON "AXIS"."PAC_MODELOS_FISCALES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MODELOS_FISCALES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MODELOS_FISCALES" TO "PROGRAMADORESCSI";
