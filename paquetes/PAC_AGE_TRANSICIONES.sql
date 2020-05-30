--------------------------------------------------------
--  DDL for Package PAC_AGE_TRANSICIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_AGE_TRANSICIONES" AS
   /******************************************************************************
      NOMBRE:       PAC_AGE_TRANSICIONES
      PROPÓSITO:  Funciones para las validaciones de transiciones de estado del agente
                  (tabla AGE_TRANSICIONES)

      REVISIONES:
      Ver        Fecha        Autor   Descripción
     ---------  ----------  ------   ------------------------------------
      1.0        25/04/2012   APD     1. Creación del package.
      2.0        25/04/2012   APD     0021682: MDP - COM - Transiciones de estado de agente.

   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   --Bug 21682 - APD - 25/04/2012 - se crea la funcion
   FUNCTION f_valida_nregdgs(
      pcempres IN NUMBER,
      pcagente IN agentes.cagente%TYPE,
      pctipage IN agentes.ctipage%TYPE,
      pcestant IN agentes.cactivo%TYPE,
      pcestact IN agentes.cactivo%TYPE,
      pctipmed IN agentes.ctipmed%TYPE,
      pnregdgs IN agentes.nregdgs%TYPE)
      RETURN NUMBER;

   --Bug 21682 - APD - 25/04/2012 - se crea la funcion
   FUNCTION f_valida_ctipmed(
      pcempres IN NUMBER,
      pcagente IN agentes.cagente%TYPE,
      pctipage IN agentes.ctipage%TYPE,
      pcestant IN agentes.cactivo%TYPE,
      pcestact IN agentes.cactivo%TYPE,
      pctipmed IN agentes.ctipmed%TYPE)
      RETURN NUMBER;

   --Bug 21682 - APD - 25/04/2012 - se crea la funcion
   FUNCTION f_valida_ctipmed_nregdgs(
      pcempres IN NUMBER,
      pcagente IN agentes.cagente%TYPE,
      pctipage IN agentes.ctipage%TYPE,
      pcestant IN agentes.cactivo%TYPE,
      pcestact IN agentes.cactivo%TYPE,
      pctipmed IN agentes.ctipmed%TYPE,
      pnregdgs IN agentes.nregdgs%TYPE)
      RETURN NUMBER;
END pac_age_transiciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_AGE_TRANSICIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_AGE_TRANSICIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_AGE_TRANSICIONES" TO "PROGRAMADORESCSI";
