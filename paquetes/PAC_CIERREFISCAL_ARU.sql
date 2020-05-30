--------------------------------------------------------
--  DDL for Package PAC_CIERREFISCAL_ARU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CIERREFISCAL_ARU" AUTHID CURRENT_USER AS
/******************************************************************************
   NAME:       PAC_CIERREFISCAL_ARU
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        ??/??/????  ???              1. Created this package body.
   2.0        27/09/2010  RSC              6. Bug 15702 - Models Fiscals: 347
******************************************************************************/
   TYPE assoc_array_error IS TABLE OF NUMBER
      INDEX BY PLS_INTEGER;   --- Table para PIAS

   FUNCTION f_modelos_afectados(psseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_proces_modelosafectado(psproces IN NUMBER, pmodhacienda IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_retencion(pretenc IN NUMBER)
      RETURN NUMBER;

   PROCEDURE f_datos_asegurado(
      psseguro IN NUMBER,
      pnorden IN NUMBER,
      vsperson1 IN OUT NUMBER,
      vnumnif1 IN OUT VARCHAR2,
      vfnacimi1 IN OUT DATE,
      vpais1 IN OUT NUMBER,
      vffecfin1 IN OUT DATE,
      vffecmue1 IN OUT DATE,
      vtidenti IN OUT NUMBER);

   FUNCTION cierre_fis_aho(
      pany IN VARCHAR2,
      pempres IN NUMBER,
      psfiscab IN NUMBER,
      psproces IN NUMBER DEFAULT NULL,
      pfperfin IN DATE DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION cierre_fis_ren_ulk(
      pany IN VARCHAR2,
      pempres IN NUMBER,
      psfiscab IN NUMBER,
      psproces IN NUMBER DEFAULT NULL,
      pfperfin IN DATE DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_calculo_planfiscal_aho(pany IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_calculo_planfiscal_rentas(pany IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_trata_representante(
      vsperson1 IN NUMBER,
      vsperson2 IN NUMBER,
      vnumnif2 IN OUT VARCHAR2,
      psseguro IN NUMBER,
      pfvalmov IN DATE,
      psproduc IN NUMBER,
      vfnacimi1 IN DATE,
      vnumnif1 IN OUT VARCHAR2,
      vtidenti1 IN OUT VARCHAR2,
      vtidenti2 IN OUT VARCHAR2,
      vspersonrep IN OUT NUMBER,
      vnnumnifrep IN OUT VARCHAR2,
      vsproces IN NUMBER,
      vhashcodeerr IN OUT pac_cierrefiscal_aru.assoc_array_error)
      RETURN NUMBER;

   FUNCTION f_valida_nif_1cabeza(
      vsperson1 IN NUMBER,
      vtidenti1 IN NUMBER,
      psseguro IN NUMBER,
      vsproces IN NUMBER,
      vnumnif1 IN OUT VARCHAR2,
      vhashcodeerr IN OUT pac_cierrefiscal_aru.assoc_array_error,
      writeerr IN NUMBER DEFAULT 1)
      RETURN NUMBER;

   FUNCTION cierre_fis_riesgo(
      pany IN VARCHAR2,
      pempres IN NUMBER,
      psfiscab IN NUMBER,
      psproces IN NUMBER DEFAULT NULL,
      pfperfin IN DATE DEFAULT NULL)
      RETURN NUMBER;

   -- Bug 15702 - RSC - 28/09/2010 - Models Fiscals: 347
   FUNCTION f_calculo_planfiscal_riesgo(pany IN VARCHAR2)
      RETURN NUMBER;
END pac_cierrefiscal_aru;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_CIERREFISCAL_ARU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CIERREFISCAL_ARU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CIERREFISCAL_ARU" TO "PROGRAMADORESCSI";
