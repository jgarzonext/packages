--------------------------------------------------------
--  DDL for Package PAC_CALC_PROV_FINV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CALC_PROV_FINV" AUTHID CURRENT_USER IS
   /******************************************************************************
      NOMBRE:       PAC_CALC_PROV_FINV
      PROPÓSITO:
      REVISIONES:

      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
       1.0       07/05/2009  RSC              1. Creación de package
       2.0       17/09/2009     RSC           2. Bug 0010828: CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
   ******************************************************************************/
   FUNCTION fechaultcambprima281(
      psesion NUMBER,
      pseguro IN NUMBER,
      priesgo IN NUMBER,
      importeprimper OUT NUMBER)
      RETURN NUMBER;

   FUNCTION fechaultcambprima500(
      psesion NUMBER,
      pseguro IN NUMBER,
      pfecha IN NUMBER,
      priesgo IN NUMBER)
      RETURN NUMBER;

   FUNCTION fechaultcambprima508(
      psesion NUMBER,
      pseguro IN NUMBER,
      pfecha IN NUMBER,
      priesgo IN NUMBER)
      RETURN NUMBER;

   FUNCTION fechaultcambprima526(
      psesion NUMBER,
      pseguro IN NUMBER,
      pfecha IN NUMBER,
      priesgo IN NUMBER)
      RETURN NUMBER;

   FUNCTION fechaultcambprima266(
      psesion NUMBER,
      pseguro IN NUMBER,
      pfecha IN NUMBER,
      priesgo IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_cesperado(psesion IN NUMBER, psseguro IN NUMBER, pfecha IN NUMBER)
      RETURN NUMBER;

   FUNCTION ff_cfallec(psesion IN NUMBER, psseguro IN NUMBER, ppfefecto IN NUMBER)
      RETURN NUMBER;
/*************************************************************************
   Obtiene el rendimiento esperado del modelo de inversión asociado
   a un contrato financiero de inversión.
   param in ptablas  : Tablas reales o table est
   param in psseguro : Código de contrato
   return          : 0 todo correcto
                     1 ha habido un error
*************************************************************************/
-- Bug 9424 - 07/04/2009 - RSC - Creación del producto PPJ Dinàmic
--FUNCTION ff_rendimiento_esperado(ptablas IN VARCHAR2, psseguro IN NUMBER)
--RETURN NUMBER;
-- Fin Bug 9424
END pac_calc_prov_finv;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_CALC_PROV_FINV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CALC_PROV_FINV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CALC_PROV_FINV" TO "PROGRAMADORESCSI";
