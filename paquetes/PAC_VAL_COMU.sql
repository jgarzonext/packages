--------------------------------------------------------
--  DDL for Package PAC_VAL_COMU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_VAL_COMU" AUTHID CURRENT_USER IS
   FUNCTION f_valida_forpag(psproduc IN NUMBER, pcforpag IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_edad_prod(
      psproduc IN NUMBER,
      pfefecto IN DATE,
      pfnacimi IN DATE,
      pfnacimi2 IN DATE DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_valida_edad_garant(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      psperson IN NUMBER,
      pfefecto IN DATE)
      RETURN NUMBER;

   FUNCTION f_valida_residentes(
      psproduc IN NUMBER,
      pcpais1 IN NUMBER,
      pcpais2 IN NUMBER,
      piprima IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_durper(psproduc IN NUMBER, pndurper IN NUMBER, pfecha IN DATE)
      RETURN NUMBER;

   FUNCTION f_valida_capital(
      ptipo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      picapital IN NUMBER,
      pcforpag IN NUMBER,
      picapmin OUT NUMBER,
      picapmax OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_capital_persona(
      ptipo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      picapital IN NUMBER,
      psperson IN NUMBER,
      pcpais IN NUMBER,
      pfefecto IN DATE DEFAULT f_sysdate)
      RETURN NUMBER;

   FUNCTION f_valida_fefecto(psproduc IN NUMBER, pfefecto IN DATE)
      RETURN NUMBER;

   FUNCTION f_valida_duracion(
      psproduc IN NUMBER,
      pfnacimi IN DATE,
      pfefecto IN DATE,
      pnduraci IN NUMBER,
      pfvencim IN DATE)
      RETURN NUMBER;

   FUNCTION f_valida_idioma(pcidioma IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_ccc(pcbancar IN VARCHAR2, pctipban IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_poliza_renova(psseguro IN NUMBER, ptipo IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_duracion_renova(psseguro IN NUMBER, pndurper IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_agente(pcagente IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_beneficiario(psproduc IN NUMBER, psclaben IN NUMBER, ptclaben IN VARCHAR2)
      RETURN NUMBER;

-- MSR 7/6/2007
-- Torna el literal d'avís corresponent a
-- Paràmetres entrada:
--    psSeguro : Número de pòlissa                (obligatori)
-- Torna :
--    0 si oficina terminalista = oficina del contrate
--    altrament el literal amb el missatge a mostrar
--
   FUNCTION f_avisos(psseguro IN seguros.sseguro%TYPE)
      RETURN literales.slitera%TYPE;

-- MSR 20/9/2007
-- Torna si la una pòlissa te una clasula de no penalització al seu darrer moviment
-- Paràmetres entrada:
--    psSeguro : Identificador de pòlissa                (obligatori)
-- Torna :
--    > 0 si te clausula de no penalització. És l'any de no penalització.
--    0 si no te clausula de no penalització
--
   FUNCTION f_clausula_no_penalizacion(psseguro IN seguros.sseguro%TYPE)
      RETURN penaliseg.niniran%TYPE;

   FUNCTION f_valida_persona_fallecida(psperson IN NUMBER)
      RETURN NUMBER;

   --
   -- La funció retorna 0 si tot és correcte
   --                  codi error si no es compleix alguna validació
   --  Informar psPerson únicamente cuando se haya realizado la búsqueda por asegurado.
   --
   FUNCTION f_valida_permite_impr_libreta(
      psseguro seguros.sseguro%TYPE,
      psperson IN personas.sperson%TYPE)
      RETURN NUMBER;

   /********************************************************************************
       Función que valida si ha de imprimirse el cuestionario de salud.
       param   in  ppulsado: codigo de si se ha pulsado el boton
       param   in  pmodo: modo 'ALT','SIM' o 'SUP'
       param   in  psseguro: codigo seguro
       param   in  pnriesgo: codigo del riesgo
       Devolviendo 0 si no hace falta imprimirlo ó 1 si hay que imprimirlo
   *********************************************************************************/
   -- Bug 9051 - 18/02/2009 - AMC
   FUNCTION f_valida_cuest_salud(
      ppulsado IN NUMBER,
      pmodo IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER)
      RETURN NUMBER;
END pac_val_comu;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_VAL_COMU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_VAL_COMU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_VAL_COMU" TO "PROGRAMADORESCSI";
