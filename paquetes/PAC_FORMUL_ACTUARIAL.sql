--------------------------------------------------------
--  DDL for Package PAC_FORMUL_ACTUARIAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_FORMUL_ACTUARIAL" authid current_user is

  FIN_MORTA CONSTANT NUMBER := 126;
  MAXTAULA  CONSTANT NUMBER := 127;
  m_1div2m  CONSTANT NUMBER := 11/24;

  FUNCTION FF_LX (psesion IN NUMBER, ptabla IN NUMBER, pedad IN NUMBER, psexo IN NUMBER, p_es_mensual IN NUMBER)
     RETURN NUMBER;

 FUNCTION FF_LXProg (psesion IN NUMBER, ptabla IN NUMBER, pedad IN NUMBER, psexo IN NUMBER, p_es_mensual IN NUMBER,
                 gg number  default  null,ig number default null,edadIni in number) return number;

FUNCTION FF_axProg (psesion IN NUMBER, ptabla IN NUMBER, psexo IN NUMBER, pedad IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER,gg in number,ig in number, mes IN NUMBER, p_es_mensual IN NUMBER DEFAULT 0)
    RETURN NUMBER ;


  FUNCTION FF_A (psesion IN NUMBER, ptabla IN NUMBER, psexo IN NUMBER, pedad IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER,mes IN NUMBER, p_es_mensual IN NUMBER DEFAULT 0)
    RETURN NUMBER;

  FUNCTION FF_A2 (psesion IN NUMBER, ptabla IN NUMBER, psexo IN NUMBER, pedad IN NUMBER,
    psexo2 IN NUMBER, pedad2 IN NUMBER, pduraci IN NUMBER, pv IN NUMBER,mes IN NUMBER, p_es_mensual IN NUMBER DEFAULT 0)
    RETURN NUMBER;

  FUNCTION FF_A_cab (psesion IN NUMBER, ptabla IN NUMBER,
    psexo IN NUMBER, pedad IN NUMBER, psexo2 IN NUMBER, pedad2 IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER,mes IN NUMBER, p_es_mensual IN NUMBER DEFAULT 0)
    RETURN NUMBER;

  FUNCTION FF_ax (psesion IN NUMBER, ptabla IN NUMBER, psexo IN NUMBER, pedad IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER, mes IN NUMBER, p_es_mensual IN NUMBER DEFAULT 0)
    RETURN NUMBER;

  FUNCTION FF_axy (psesion IN NUMBER, ptabla IN NUMBER, psexo IN NUMBER,
    pedad IN NUMBER, psexo2 IN NUMBER, pedad2 IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER, mes IN NUMBER, p_es_mensual IN NUMBER DEFAULT 0)
    RETURN NUMBER;

  FUNCTION FF_axy_cab (psesion IN NUMBER, ptabla IN NUMBER,
    psexo IN NUMBER, pedad IN NUMBER, psexo2 IN NUMBER, pedad2 IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER, pfracc IN NUMBER DEFAULT 12,
    p_es_mensual IN NUMBER DEFAULT 0, prever IN NUMBER DEFAULT 100)
    RETURN NUMBER;

  FUNCTION FF_axy_rever (psesion IN NUMBER, ptabla IN NUMBER,
    psexo IN NUMBER, pedad IN NUMBER, psexo2 IN NUMBER, pedad2 IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER, pvmin IN NUMBER, prever IN NUMBER, preval IN NUMBER DEFAULT 0,
    pfracc IN NUMBER DEFAULT 12,
    p_es_mensual IN NUMBER DEFAULT 0)
    RETURN NUMBER;

  FUNCTION FF_Ex (psesion IN NUMBER, ptabla IN NUMBER, psexo IN NUMBER, pedad IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER,pfrac number default 12, p_es_mensual IN NUMBER DEFAULT 0)
    RETURN NUMBER;

  FUNCTION FF_factorprovi (psesion IN NUMBER, ptabla IN NUMBER,
    psexo IN NUMBER, pedad IN NUMBER, psexo2 IN NUMBER, pedad2 IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER,
    pRo IN NUMBER, preserva IN NUMBER, pgastos IN NUMBER,mes IN NUMBER , p_es_mensual IN NUMBER DEFAULT 0)
    RETURN NUMBER;

  FUNCTION FF_factorgaran (psesion IN NUMBER, ptabla IN NUMBER,
    psexo IN NUMBER, pedad IN NUMBER, psexo2 IN NUMBER, pedad2 IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER,
    pRo IN NUMBER, preserva IN NUMBER, pgastos IN NUMBER,
    pv_E IN NUMBER, nitera IN NUMBER,mes IN NUMBER, p_es_mensual IN NUMBER DEFAULT 0)
    RETURN NUMBER;


 /**************************************************************************************************
AQUI EMPIEZA RP JRH 01/2008
**************************************************************************************************/

 FUNCTION FF_Exy (psesion IN NUMBER, ptabla IN NUMBER, psexo IN NUMBER, pedad IN NUMBER,
    psexo2 IN NUMBER, pedad2 IN NUMBER,pduraci IN NUMBER, pv IN NUMBER,pfrac number default 12, p_es_mensual IN NUMBER DEFAULT 0)
    RETURN NUMBER;

 FUNCTION FF_Exy_Cab (psesion IN NUMBER, ptabla IN NUMBER,
    psexo IN NUMBER, pedad IN NUMBER, psexo2 IN NUMBER, pedad2 IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER,pfrac number default 12, p_es_mensual IN NUMBER DEFAULT 0)
    RETURN NUMBER;

 FUNCTION FF_ax2 (psesion IN NUMBER, ptabla IN NUMBER, psexo IN NUMBER, pedad IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER, mes IN NUMBER, p_es_mensual IN NUMBER DEFAULT 0)
    RETURN NUMBER;

 FUNCTION FF_axy2 (psesion IN NUMBER, ptabla IN NUMBER, psexo IN NUMBER,
    pedad IN NUMBER, psexo2 IN NUMBER, pedad2 IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER, mes IN NUMBER, p_es_mensual IN NUMBER DEFAULT 0)
    RETURN NUMBER;

 FUNCTION FF_axy_cab2 (psesion IN NUMBER, ptabla IN NUMBER,
    psexo IN NUMBER, pedad IN NUMBER, psexo2 IN NUMBER, pedad2 IN NUMBER,
    pduraci IN NUMBER, pv IN NUMBER, pfracc IN NUMBER DEFAULT 12,
    p_es_mensual IN NUMBER DEFAULT 0)
    RETURN NUMBER;


FUNCTION F_CPG_PPJ (sesion IN NUMBER)  RETURN NUMBER ;

END PAC_FORMUL_ACTUARIAL;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_FORMUL_ACTUARIAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FORMUL_ACTUARIAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FORMUL_ACTUARIAL" TO "PROGRAMADORESCSI";
