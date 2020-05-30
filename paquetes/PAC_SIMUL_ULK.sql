--------------------------------------------------------
--  DDL for Package PAC_SIMUL_ULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_SIMUL_ULK" AUTHID CURRENT_USER IS
   /******************************************************************************
     Package encargado de las simulaciones

   ******************************************************************************/

   -- Cridada per quan les dades són a la taulas EVOLUPROVMAT
   FUNCTION f_get_evoluprovmat(
      pssolicit IN NUMBER,
      pndurper IN NUMBER,
      pnanyos_transcurridos IN NUMBER,
      pnum_err OUT NUMBER)
      RETURN t_det_simula_pu;

   -- Cridada quan les dades NO són a la taula EVOLUPROVMAT i s'han de calculat
   FUNCTION f_get_dades_calculades(
      pssolicit IN NUMBER,
      pfefecto IN DATE,
      piprima IN NUMBER,
      pcidioma_user IN literales.cidioma%TYPE,
      pnum_err OUT NUMBER)
      RETURN ob_resp_simula_pu_ulk;

   FUNCTION f_genera_sim_pu(
      psproduc IN NUMBER,
      pnombre1 IN VARCHAR2,
      ptapelli1 IN VARCHAR2,
      pfnacimi1 IN DATE,
      psexo1 IN NUMBER,
      pnombre2 IN VARCHAR2,
      ptapelli2 IN VARCHAR2,
      pfnacimi2 IN DATE,
      psexo2 IN NUMBER,
      piprima IN NUMBER,
      pndurper IN NUMBER,
      pfvencim IN DATE,
      ppinttec IN NUMBER,
      pfefecto IN DATE,
      pssolicit OUT NUMBER)
      RETURN NUMBER;
END pac_simul_ulk;

/

  GRANT EXECUTE ON "AXIS"."PAC_SIMUL_ULK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SIMUL_ULK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SIMUL_ULK" TO "PROGRAMADORESCSI";
