--------------------------------------------------------
--  DDL for Package PAC_INT_BASICO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_INT_BASICO" AUTHID CURRENT_USER IS

  FUNCTION formato_poliza (psseguro IN NUMBER, papli OUT VARCHAR2, pempre OUT VARCHAR2,
     pcentro OUT VARCHAR2, pafijo OUT VARCHAR2, pncontr OUT VARCHAR2, pdigito OUT VARCHAR2)
  RETURN NUMBER;

  FUNCTION f_formato_ctapres (pctapres IN prestamos.ctapres%TYPE) RETURN VARCHAR2;

  FUNCTION f_format_ctapres_t (
       p_in_ctapres               IN       prestamos.ctapres%TYPE,
       p_out_ctapres_centro       OUT      VARCHAR2,
       p_out_ctapres_contrato     OUT      VARCHAR2,
       p_out_ctapres_afijo        OUT      VARCHAR2,
       p_out_ctapres_digito       OUT      VARCHAR2) RETURN NUMBER;

  FUNCTION f_formato_ccc (papli IN VARCHAR2, pempre IN VARCHAR2,
   pcentro IN VARCHAR2, pafijo IN VARCHAR2, pncontr IN VARCHAR2,
   pdigito IN VARCHAR2)    RETURN VARCHAR2;

  PROCEDURE obtener_prefijo_prestamo(vafijo IN VARCHAR2, vapli OUT VARCHAR2,
      vempresa OUT VARCHAR2);

  FUNCTION f_importe_asegurado (psseguro IN NUMBER, pnriesgo IN NUMBER,
      pnmovimi IN NUMBER, pimpAsegurado OUT NUMBER) RETURN NUMBER;

  FUNCTION f_valor_provision (psseguro IN NUMBER, pvalProvision OUT NUMBER) RETURN NUMBER;

  FUNCTION f_concepto_libreta (pcmovimi IN NUMBER) RETURN NUMBER;

  FUNCTION f_obtener_valorVencim(psseguro IN NUMBER, pnriesgo IN NUMBER, pnmovimi IN NUMBER,
   pcramo IN NUMBER, pcmodali IN NUMBER, pctipseg IN NUMBER, pccolect IN NUMBER,
   pcactivi IN NUMBER, picapital IN OUT NUMBER) RETURN NUMBER;

  FUNCTION obtener_importes (psseguro IN NUMBER, pnriesgo IN NUMBER, pnnumlin IN NUMBER,
      importe OUT NUMBER, valorProvision OUT NUMBER, valorVencim OUT NUMBER,
   valorFallecim OUT  NUMBER) RETURN NUMBER;

  -- ha de desapareixer i ser substituida per f_obtener_valor_axis
  FUNCTION obtener_valor_axis(pcampo IN VARCHAR2, pvalmv IN VARCHAR2,
      pvalaxis IN OUT VARCHAR2) RETURN NUMBER;

  -- ha de desapareixer i ser substituida per f_obtener_valor_emp
  FUNCTION obtener_valor_bm(pcampo IN VARCHAR2, pvalaxis IN VARCHAR2,
       pvalmv IN OUT VARCHAR2) RETURN NUMBER;

  FUNCTION f_obtener_valor_axis(pemp IN VARCHAR2, pcampo IN VARCHAR2,
     pvalemp IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION f_obtener_valor_emp(pemp IN VARCHAR2, pcampo IN VARCHAR2,
       pvalaxis IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION f_numlibreta (psseguro IN NUMBER) RETURN NUMBER;

  FUNCTION act_libreta_sint(psseguro IN NUMBER, pnnumlin IN NUMBER, psintbatch IN NUMBER)
      RETURN NUMBER;

  FUNCTION act_libreta_nnumlib(psseguro IN NUMBER, pnnumlin IN NUMBER, pnnumlib IN NUMBER)
      RETURN NUMBER;

  FUNCTION f_tipo_persona_int (pdocumento IN VARCHAR2) RETURN NUMBER;

  FUNCTION f_npolizamv(psseguro IN NUMBER, psepara IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

END;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_INT_BASICO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_INT_BASICO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_INT_BASICO" TO "PROGRAMADORESCSI";
