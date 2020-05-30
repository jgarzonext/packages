--------------------------------------------------------
--  DDL for Package PAC_FORMUL_PE_PPA_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_FORMUL_PE_PPA_CALC" AUTHID CURRENT_USER IS
   FUNCTION prob2caps(prob1 IN NUMBER, prob2 IN NUMBER)
      RETURN NUMBER;

   TYPE rt_dades_cap IS RECORD(
      edajub         NUMBER(5),   -- EDAD JUBILACION PRIMERA CABEZA
      edact          NUMBER(5),   -- EDAD ACTUAL PRIMERA CABEZA
      ledact         NUMBER(8),   -- EDAD ACTUAL           PRIMERA CABEZA
      ledact_1       NUMBER(8),   -- EDAD ACTUAL  + 1      PRIMERA CABEZA
      ledact_d       NUMBER(8),   -- EDAD ACTUAL  + D/365  PRIMERA CABEZA
      ledjub         NUMBER(8),   -- EDAD JUBILACION       PRIMERA CABEZA
      ledjub_1       NUMBER(8),   -- EDAD JUBILACION +1    PRIMERA CABEZA
      ledjub_k       NUMBER(8),   -- EDAD JUBILAC. + K/365 PRIMERA CABEZA
      nedact         NUMBER(19, 2),   -- EDAD ACTUAL    PRIMERA CABEZA
      nedact_1       NUMBER(19, 2),   -- EDAD ACTUA   EDAJUB        NUMBER(5),    -- EDAD JUBILACION PRIMERA CABEZA
      nedjub         NUMBER(19, 2)   -- EDAD JUBILACION  PRIMERA CABEZA
   );

   cap1           rt_dades_cap;
   cap2           rt_dades_cap;

----------------------------------------------------------------------
 --                     P R O V M A T                                --
 ----------------------------------------------------------------------
   FUNCTION provmat(
      p_sesion IN NUMBER,
      psseguro IN seguros.sseguro%TYPE,
      ptablas IN VARCHAR2,
      poperacion IN VARCHAR2,
      pfe_venci IN DATE,
      pfe_alta IN DATE,
      pfe_revint IN DATE,
      pfe_interes IN DATE,   -- Data a utilitzar per calcular l'interès
      pfe_ult_oper IN DATE,
      pfe_proceso IN DATE,
      pprimes IN NUMBER,
      pcap_super IN NUMBER,
      pcap_fall IN NUMBER,
      pprov_mat IN NUMBER)
      RETURN NUMBER;

----------------------------------------------------------------------
--         C A P I T A L _ F A L L E C I M I E N T O                --
----------------------------------------------------------------------
   FUNCTION capital_fallecimiento(
      psesion IN NUMBER,
      psseguro IN seguros.sseguro%TYPE,
      ptablas IN VARCHAR2,
      poperacion IN VARCHAR2,
      pfe_ult_oper IN DATE,
      pfe_proceso IN DATE,
      pfe_interes IN DATE,   -- Data a utilitzar per calcular l'interès
      pprimes IN NUMBER,
      pcap_fall IN NUMBER)
      RETURN NUMBER;

----------------------------------------------------------------------
--                     C A P G A R A N                              --
----------------------------------------------------------------------
   FUNCTION capgaran(
      p_sesion IN NUMBER,
      psseguro IN seguros.sseguro%TYPE,
      ptablas IN VARCHAR2,
      poperacion IN VARCHAR2,
      pfe_venci IN DATE,
      pfe_alta IN DATE,
      pfe_revint IN DATE,
      pfe_interes IN DATE,   -- Data a utilitzar per calcular l'interès
      pfe_ult_oper IN DATE,
      pfe_proceso IN DATE,
      pprimes IN NUMBER,
      pcap_super IN NUMBER,
      pcap_fall IN NUMBER,
      pprov_mat IN NUMBER)
      RETURN NUMBER;

----------------------------------------------------------------------
--                     P R O V M A T Z                              --
----------------------------------------------------------------------
   FUNCTION provmatz(
      p_sesion IN NUMBER,
      psseguro IN seguros.sseguro%TYPE,
      ptablas IN VARCHAR2,
      poperacion IN VARCHAR2,
      pfe_venci IN DATE,
      pfe_alta IN DATE,
      pfe_revint IN DATE,
      pfe_interes IN DATE,   -- Data a utilitzar per calcular l'interès
      pfe_proceso IN DATE,
      pcap_super IN NUMBER,
      pcap_fall IN NUMBER,
      pprov_mat IN NUMBER)
      RETURN NUMBER;

----------------------------------------------------------------------
--                     INTERES PROMOCIONAL                          --
----------------------------------------------------------------------
-- Torna la Prima Inicial augmentada pels interesos d'un mes de l'interès promocional descomptat l'interès tècnic.
   FUNCTION interes_promocional(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      ptablas IN VARCHAR2,
      pfecalta IN DATE,
      pfecproceso IN DATE,
      pprimainicial IN seguros.iprianu%TYPE,
      pinterespromocional IN NUMBER)
      RETURN NUMBER;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_FORMUL_PE_PPA_CALC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FORMUL_PE_PPA_CALC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FORMUL_PE_PPA_CALC" TO "PROGRAMADORESCSI";
