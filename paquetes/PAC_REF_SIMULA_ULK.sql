--------------------------------------------------------
--  DDL for Package PAC_REF_SIMULA_ULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_REF_SIMULA_ULK" AUTHID CURRENT_USER IS

/******************************************************************************
  Package encargado de las simulaciones de pólizas de ahorro

******************************************************************************/

    FUNCTION f_valida_prima_ulk(ptipo IN NUMBER, psproduc IN NUMBER, pcactivi IN NUMBER, pcgarant IN NUMBER,
                               picapital IN NUMBER, pcforpag IN NUMBER, psperson IN NUMBER, pcpais IN NUMBER,
                               pcidioma_user IN NUMBER DEFAULT F_IdiomaUser, coderror OUT NUMBER, msgerror OUT VARCHAR2)
    RETURN NUMBER;

    FUNCTION f_simulacion(psproduc IN NUMBER, psperson1 IN NUMBER, pnombre1 IN VARCHAR2,  ptapelli1 IN VARCHAR2,
                          pfnacimi1 IN DATE, psexo1 IN NUMBER, pcpais1 IN NUMBER, psperson2 IN NUMBER, pnombre2 IN VARCHAR2,  ptapelli2 IN VARCHAR2, pfnacimi2 IN DATE,
                          psexo2 IN NUMBER, pcpais2 IN NUMBER, pcidioma IN NUMBER DEFAULT 1, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser, piprima IN NUMBER, pndurper IN NUMBER,
                          ppinttec IN NUMBER, pcagente IN NUMBER)
    RETURN ob_resp_simula_pu_ulk;
END Pac_Ref_Simula_Ulk;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_REF_SIMULA_ULK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REF_SIMULA_ULK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REF_SIMULA_ULK" TO "PROGRAMADORESCSI";
