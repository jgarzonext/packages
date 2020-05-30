--------------------------------------------------------
--  DDL for Package PAC_MATCHING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MATCHING" AUTHID CURRENT_USER
IS
    FUNCTION f_sictr026 ( pcIdioma  IN SEGUROS.CIDIOMA%TYPE,
                          pfFecha   IN DATE,
                          pcEmpresa IN SEGUROS.CEMPRES%TYPE) RETURN NUMBER;

    FUNCTION ff_interes_matching(pcmatching IN NUMBER, fefecto IN DATE) RETURN NUMBER;

    FUNCTION ff_fecha_matching(pcmatching IN NUMBER, fefecto IN DATE) RETURN DATE;

    FUNCTION f_datos_asegurado(psseguro IN NUMBER,
                              pnorden IN NUMBER,
                              pcidioma IN NUMBER,
                              pfnacimiento IN OUT DATE,
                              psexo IN OUT NUMBER) RETURN NUMBER;

    FUNCTION f_pprob_supervivencia (psseguro IN NUMBER,
                                    psproduc IN NUMBER,
                                    pfFecha IN DATE,    -- Fecha del momento de cálculo
                                    pfnacimi1 IN DATE,
                                    psexo1 IN NUMBER,
                                    pfnacimi2 IN DATE,
                                    psexo2 IN NUMBER,
                                    pfejerc IN DATE,    -- Fecha del ejercicio
                                    pfvencim IN DATE,
                                    pcapgar IN NUMBER,
                                    vprovac_200 IN NUMBER DEFAULT NULL) RETURN NUMBER;

    FUNCTION f_pprob_supervivencia_rentas (psseguro IN NUMBER,
                                           psproduc IN NUMBER,
                                           pfFecha IN DATE,    -- Fecha del momento de cálculo
                                           pfnacimi1 IN DATE,
                                           psexo1 IN NUMBER,
                                           pfnacimi2 IN DATE,
                                           psexo2 IN NUMBER,
                                           pfejerc IN DATE,    -- Fecha del ejercicio
                                           pfvencim IN DATE,
                                           pcapgar IN NUMBER,
                                           vprovac_200 IN NUMBER DEFAULT NULL) RETURN NUMBER;

    /*
    FUNCTION f_calc_fracciones (pfFecha IN DATE,    -- Fecha del momento de cálculo
                               pfejerc IN DATE,    -- Fecha del ejercicio
                               pfvencim IN DATE    -- Fecha del vencimiento
                              ) RETURN NUMBER;
    */
    /*
    FUNCTION f_calc_fracciones_RVI (pfFecha IN DATE,    -- Fecha del momento de cálculo
                                   pfejerc IN DATE,    -- Fecha del ejercicio
                                   pfvencim IN DATE    -- Fecha del vencimiento
                                   ) RETURN NUMBER;
    */

     FUNCTION f_calc_fracciones (vpfFecha IN DATE,
                                 vflufrev IN DATE,
                                 vdiasvct IN OUT NUMBER,
                                 vfracN IN OUT NUMBER,
                                 vdiascalc IN OUT NUMBER,
                                 vfrac1 IN OUT NUMBER,
                                 vdiasfcvct IN OUT NUMBER,
                                 vfracNB IN OUT NUMBER,
                                 psproduc IN NUMBER DEFAULT NULL) RETURN NUMBER;

    FUNCTION f_prob_fallecimiento (psseguro IN NUMBER,
                                  psproduc IN NUMBER,
                                  pfFecha IN DATE,    -- Fecha del momento de cálculo
                                  pfnacimi1 IN DATE,
                                  psexo1 IN NUMBER,
                                  pfnacimi2 IN DATE,
                                  psexo2 IN NUMBER,
                                  pfejerc IN DATE    -- Fecha del ejercicio
                                  ) RETURN NUMBER;

    FUNCTION f_prob_fallecimiento_rentas (psseguro IN NUMBER,
                                          psproduc IN NUMBER,
                                          pfFecha IN DATE,    -- Fecha del momento de cálculo
                                          pfnacimi1 IN DATE,
                                          psexo1 IN NUMBER,
                                          pfnacimi2 IN DATE,
                                          psexo2 IN NUMBER,
                                          pfejerc IN DATE    -- Fecha del ejercicio
                                          ) RETURN NUMBER;

     FUNCTION f_prob_supervivencia_rentas (psseguro IN NUMBER,
                                       psproduc IN NUMBER,
                                       pfFecha IN DATE,    -- Fecha del momento de cálculo
                                       pfnacimi1 IN DATE,
                                       psexo1 IN NUMBER,
                                       pfnacimi2 IN DATE,
                                       psexo2 IN NUMBER,
                                       pfejerc IN DATE    -- Fecha del ejercicio
                                       ) RETURN NUMBER;

    FUNCTION f_renta_anual_ponderada (psseguro IN NUMBER,
                                      pfFecha IN DATE,
                                      pfejerc IN DATE) RETURN NUMBER;

     FUNCTION f_valor_rescate_match (psseguro IN NUMBER,
                                   psproduc IN NUMBER,
                                   pcidioma IN NUMBER,
                                   pfFecha  IN DATE,
                                   pprovision IN NUMBER,
                                   vresultat IN OUT NUMBER) RETURN NUMBER;

     FUNCTION f_inserta_flujo(lv_flujo FLUJO_PASIVOS%ROWtype) RETURN NUMBER;

     FUNCTION f_inserta_detflujo (lv_detflujo DETFLUJO_PASIVOS%ROWtype) RETURN NUMBER;

     FUNCTION f_valida_existe_delete(pfFecha IN DATE) RETURN NUMBER;
END pac_matching;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_MATCHING" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MATCHING" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MATCHING" TO "PROGRAMADORESCSI";
