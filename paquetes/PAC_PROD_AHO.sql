--------------------------------------------------------
--  DDL for Package PAC_PROD_AHO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PROD_AHO" 
    AUTHID CURRENT_USER
IS

   FUNCTION f_cambio_forpag_prest(psseguro IN NUMBER, pcfprest IN NUMBER)
   RETURN NUMBER;

   FUNCTION f_cambio_aportacion_revali(psseguro IN NUMBER, pcforpag IN NUMBER, pprima IN NUMBER, pprevali IN NUMBER, pnmovimi IN NUMBER, pfecha IN DATE)
   RETURN NUMBER;

   FUNCTION f_cambio_modif_gar(psseguro IN NUMBER, pcfallaseg1 IN NUMBER, pcfallaseg2 IN NUMBER, pcaccaseg1 IN NUMBER, pcaccaseg2 IN NUMBER, pnmovimi IN NUMBER, pfecha IN DATE)
   RETURN NUMBER;

   FUNCTION f_cambio_aport_extr(psseguro IN NUMBER, pfefecto IN DATE, pprima IN NUMBER, pnmovimi IN NUMBER)
   RETURN NUMBER;

   FUNCTION f_cambio_fvencimiento(psseguro IN NUMBER, pfvencim IN DATE, pnmovimi IN NUMBER, pfefecto IN DATE)
   RETURN NUMBER;

   FUNCTION f_post_penalizacion (psseguro   IN   NUMBER)
   RETURN NUMBER;

   FUNCTION f_grabar_garantias_aho(pmodo IN NUMBER, psseguro IN NUMBER, pnriesgo IN NUMBER,
                                   pnmovimi IN NUMBER, pfefecto IN DATE, prima_inicial IN NUMBER, prima_per IN NUMBER,
                                   pprevali IN NUMBER, pcfallaseg1 IN NUMBER, pcfallaseg2 IN NUMBER, pcaccaseg1 IN NUMBER,
                                   pcaccaseg2 IN NUMBER)
   RETURN NUMBER;

   FUNCTION f_graba_propuesta_aho(psproduc IN NUMBER, psperson1 IN NUMBER,  pcdomici1 IN NUMBER, psperson2 IN NUMBER,
                                  pcdomici2 IN NUMBER, pcagente IN NUMBER, pcidioma IN NUMBER, pfefecto IN DATE,
                                  pnduraci IN NUMBER, pfvencim IN DATE, pcforpag IN NUMBER, pcbancar IN VARCHAR2,
                                  psclaben IN NUMBER, ptclaben IN VARCHAR2, prima_inicial IN NUMBER, prima_per IN NUMBER,
                                  prevali IN NUMBER, pcfallaseg1 IN NUMBER, pcfallaseg2 IN NUMBER, pcaccaseg1 IN NUMBER,
                                  pcaccaseg2 IN NUMBER,    psseguro IN OUT NUMBER, pcapgar OUT NUMBER, pcapfall OUT NUMBER,
                                  pcapgar_per OUT NUMBER)
   RETURN NUMBER;

   -- JRH 11/2007 Lo hemos puesto en el comu
   --FUNCTION f_programa_revision_renovacion(psseguro IN NUMBER, pndurper IN NUMBER, ppinttec IN NUMBER)
   --RETURN NUMBER;

   -- JRH 11/2007 Lo hemos puesto en el comu
   --PROCEDURE p_revision_renovacion(pfecha IN DATE, psproduc IN NUMBER, psproces IN NUMBER);

--JRH 09/2008 Lo necesitamos para que funcionen el pac_ref_contrata_aho
FUNCTION f_solicitud_traspaso (
      pcinout         IN       NUMBER,                                                           -- 1.-Entrada 2.-Salida
      pcodpla_o       IN       NUMBER,
      pcodpla_d       IN       NUMBER,
      pcodaseg_o      IN       VARCHAR2,
      pcodaseg_d      IN       VARCHAR2,
      psseguro_o      IN       NUMBER,
      psseguro_d      IN       NUMBER,
      pnumppa         IN       VARCHAR2,                                                -- Número PPA traspasos externos
      pctiptras       IN       NUMBER,
      pctiptrassol    IN       NUMBER,                                     -- 1.-Import 2.-Percentatge 3.-Participacions
      pimport         IN       NUMBER,
      pnporcen        IN       NUMBER,
      pnparpla        IN       NUMBER,
      pctipcom        IN       NUMBER,
      pintern         IN       BOOLEAN,
      pobservaciones  IN       VARCHAR2,
      ostras          OUT      NUMBER,
      ocoderror       OUT      NUMBER
   )
      RETURN NUMBER;
END Pac_Prod_Aho;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_PROD_AHO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROD_AHO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROD_AHO" TO "PROGRAMADORESCSI";
