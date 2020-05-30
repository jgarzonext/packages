--------------------------------------------------------
--  DDL for Package PAC_FORMUL_RENTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_FORMUL_RENTAS" authid current_user is

  FIN_MORTA CONSTANT NUMBER := 126;
  MAXTAULA  CONSTANT NUMBER := 127;
  m_1div2m  CONSTANT NUMBER := 11/24;

  FUNCTION FF_LX (psesion IN NUMBER, ptabla IN NUMBER, pedad IN NUMBER, psexo IN NUMBER, p_es_mensual IN NUMBER)
    RETURN NUMBER;

  FUNCTION FF_min_RVI (sesion IN NUMBER)
    RETURN NUMBER;

  FUNCTION FF_provi_RVI (sesion IN NUMBER)
    RETURN NUMBER;

  FUNCTION FF_temp_RVI (sesion IN NUMBER)
    RETURN NUMBER;

  FUNCTION FF_pranu_RVI (sesion IN NUMBER, pany IN NUMBER)
    RETURN NUMBER;

  FUNCTION FF_min_RO (sesion IN NUMBER)
    RETURN NUMBER;

  FUNCTION FF_provi_RO (sesion IN NUMBER)
    RETURN NUMBER;

  FUNCTION FF_temp_RO (sesion IN NUMBER)
    RETURN NUMBER;

  FUNCTION FF_pranu_RO (sesion IN NUMBER, pany IN NUMBER)
    RETURN NUMBER;

  FUNCTION FF_renta_RVT (sesion IN NUMBER)
    RETURN NUMBER;

  FUNCTION FF_prima_RVT (sesion IN NUMBER, panual IN NUMBER DEFAULT 0)
    RETURN NUMBER;

  FUNCTION FF_renta_RVD (sesion IN NUMBER)
    RETURN NUMBER;

  FUNCTION FF_insub_LCR (sesion IN NUMBER)
    RETURN NUMBER;

  FUNCTION FF_provi_LCR (sesion IN NUMBER)
    RETURN NUMBER;

  -- RVD. MSR 3/12/2007

  -- pAny : Any pel qual volem la provisió  (pAny va de 1 a 127)
  FUNCTION FF_provi_HI (pSesion IN NUMBER, pAny IN NUMBER)
    RETURN NUMBER;

  FUNCTION FF_prima_HI (pSesion IN NUMBER)
    RETURN NUMBER;

  FUNCTION FF_renta_HI (pSesion IN NUMBER)
    RETURN NUMBER;



  --JRH 01/2008

	FUNCTION FF_coef_RVI (sesion IN NUMBER,psseguro IN NUMBER,Fecha NUMBER)
    RETURN NUMBER;


 /**************************************************************************************************
AQUI EMPIEZA RP JRH 01/2008
**************************************************************************************************/

FUNCTION FF_Exy (psesion IN NUMBER, ptabla IN NUMBER, psexo IN NUMBER, pedad IN NUMBER,
    psexo2 IN NUMBER, pedad2 IN NUMBER,pduraci IN NUMBER, pv IN NUMBER)
    RETURN NUMBER;

 FUNCTION FF_Exy_Cab (psesion IN NUMBER, ptabla IN NUMBER,
    psexo IN NUMBER, pedad IN NUMBER, psexo2 IN NUMBER, pedad2 IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER)
    RETURN NUMBER;

FUNCTION FF_min_RP (sesion IN NUMBER)
    RETURN NUMBER;

FUNCTION FF_temp_RP (sesion IN NUMBER)
    RETURN NUMBER;

FUNCTION FF_provi_RP (sesion IN NUMBER,pany IN NUMBER)
    RETURN NUMBER;

END pac_formul_rentas;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_FORMUL_RENTAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FORMUL_RENTAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FORMUL_RENTAS" TO "PROGRAMADORESCSI";
