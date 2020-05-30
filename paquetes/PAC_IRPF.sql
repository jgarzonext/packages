--------------------------------------------------------
--  DDL for Package PAC_IRPF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IRPF" AS
   pretanual      NUMBER;
   preduccion     NUMBER;
   psitfam        NUMBER;
   ptiporet       NUMBER;
   pretanu        NUMBER;
   phijos         NUMBER;
   pdescen1625    NUMBER;
   pretdescen316  NUMBER;
   pretdescen3    NUMBER;
   pretdesdis33   NUMBER;
   pretdesdis65   NUMBER;
   pretabuelos    NUMBER;
   predneto       NUMBER;
   predminper     NUMBER;
   predminfam     NUMBER;
   pretpension    NUMBER;
   pretmasdos     NUMBER;
   pgradodisca    NUMBER;
   pretprolon     VARCHAR2(2);
   pretmovgeo     VARCHAR2(2);
   plog           VARCHAR2(3000);

   PROCEDURE p_hoja_irpf(
      parretanual OUT NUMBER,
      parreduccion OUT NUMBER,
      parsitfam OUT NUMBER,
      partiporet OUT NUMBER,
      parretanu OUT NUMBER,
      parhijos OUT NUMBER,
      pardescen1625 OUT NUMBER,
      parretdescen316 OUT NUMBER,
      parretdescen3 OUT NUMBER,
      parretdesdis33 OUT NUMBER,
      parretdesdis65 OUT NUMBER,
      parretabuelos OUT NUMBER,
      parredneto OUT NUMBER,
      parredminper OUT NUMBER,
      parredminfam OUT NUMBER,
      parretpension OUT NUMBER,
      parretmasdos OUT NUMBER,
      raretprolon OUT VARCHAR2,
      parretmovgeo OUT VARCHAR2,
      pargradodisca OUT NUMBER,
      parlog OUT VARCHAR2);

   FUNCTION f_calret_irpf(
      psseguro IN NUMBER,
      psperson IN NUMBER,
      pplan IN NUMBER,
      pfecha IN DATE,
      psaldo IN NUMBER,
      pimppago IN NUMBER,
      pretensn IN VARCHAR2,
      pporreten IN NUMBER,
      pretencion OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_simula_irpf_renta(
      psseguro IN NUMBER,
      psperson IN NUMBER,
      psesion IN NUMBER,
      pretencion OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_simula_irpf_cap(
      psseguro IN NUMBER,
      psperson IN NUMBER,
      psesion IN NUMBER,
      pretencion OUT NUMBER,
      preduccion OUT NUMBER,
      pbase OUT NUMBER)
      RETURN NUMBER;

   --Bug 33748-206175 01/06/2015 KJSC INGRESAR LAS FUNCIONES f_busca_rt y f_calc_rt
   FUNCTION f_busca_rt(
      psesion IN NUMBER,
      psperson IN NUMBER,
      pcapital IN NUMBER,
      pireduccion IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_calc_rt(
      psperson IN NUMBER,
      pcapital IN NUMBER,
      pireduccion IN NUMBER,
      pretencion OUT NUMBER)
      RETURN NUMBER;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_IRPF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IRPF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IRPF" TO "PROGRAMADORESCSI";
