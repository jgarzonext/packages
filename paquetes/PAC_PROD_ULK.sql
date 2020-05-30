--------------------------------------------------------
--  DDL for Package PAC_PROD_ULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PROD_ULK" 
    AUTHID CURRENT_USER
IS
   FUNCTION f_grabar_garantias_index(pmodo IN NUMBER, psseguro IN NUMBER, pnriesgo IN NUMBER,
                                   pnmovimi IN NUMBER, pfefecto IN DATE, prima_inicial IN NUMBER, prima_per IN NUMBER,
                                   pprevali IN NUMBER)
   RETURN NUMBER;

   FUNCTION f_graba_propuesta_index(psproduc IN NUMBER, psperson1 IN NUMBER,  pcdomici1 IN NUMBER, psperson2 IN NUMBER,
                                  pcdomici2 IN NUMBER, pcagente IN NUMBER, pcidioma IN NUMBER, pfefecto IN DATE,
                                  pnduraci IN NUMBER, pfvencim IN DATE, pcforpag IN NUMBER, pcbancar IN VARCHAR2,
                                  pcmodinv IN NUMBER, pmodinv IN PAC_REF_CONTRATA_ULK.cartera, psclaben IN NUMBER, ptclaben IN VARCHAR2,
                                  prima_inicial IN NUMBER, prima_per IN NUMBER, prevali IN NUMBER, psseguro IN OUT NUMBER)
   RETURN NUMBER;

   FUNCTION F_grabar_distribucion_cestas(psseguro IN NUMBER,pnriesgo IN NUMBER, pnmovimi IN NUMBER,
                                          pfefecto IN DATE, pffin IN DATE, pmodinv IN PAC_REF_CONTRATA_ULK.cartera)
   RETURN NUMBER;

   FUNCTION F_actualiza_modinversion (psseguro IN NUMBER, pcmodinv IN NUMBER)
   RETURN NUMBER;

   FUNCTION F_actualiza_modelogastos (psseguro IN NUMBER, pcdefecto IN NUMBER, pcgasges IN NUMBER, pcgasred IN NUMBER)
   RETURN NUMBER;

   FUNCTION f_cambio_gastos(v_est_sseguro IN NUMBER, pcgasges IN NUMBER, pcgasred IN NUMBER) RETURN NUMBER;

   FUNCTION F_grabar_preguntas (psseguro IN NUMBER,pnriesgo IN NUMBER, pnmovimi IN NUMBER, psproduc IN NUMBER)
   RETURN NUMBER;

   FUNCTION f_cambio_minversion(v_est_sseguro IN NUMBER, pcmodinv IN NUMBER, pmodinv IN PAC_REF_CONTRATA_ULK.cartera) RETURN NUMBER;

   FUNCTION f_generar_redistribucion(v_est_sseguro IN NUMBER, pfefecto IN DATE) RETURN NUMBER;
END Pac_Prod_Ulk;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_PROD_ULK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROD_ULK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROD_ULK" TO "PROGRAMADORESCSI";
