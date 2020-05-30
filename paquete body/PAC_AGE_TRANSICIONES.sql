--------------------------------------------------------
--  DDL for Package Body PAC_AGE_TRANSICIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_AGE_TRANSICIONES" AS
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

   --Bug 21682 - APD - 25/04/2012
   FUNCTION f_valida_nregdgs(
      pcempres IN NUMBER,
      pcagente IN agentes.cagente%TYPE,
      pctipage IN agentes.ctipage%TYPE,
      pcestant IN agentes.cactivo%TYPE,
      pcestact IN agentes.cactivo%TYPE,
      pctipmed IN agentes.ctipmed%TYPE,
      pnregdgs IN agentes.nregdgs%TYPE)
      RETURN NUMBER IS
      verror         NUMBER;
   BEGIN
      verror := 0;

      -- ctipmed (v.f.1062) = 1.-Agente exclusivo, 3.-Banca seguro exclusivo
      IF pctipmed NOT IN(1, 3) THEN
         IF pnregdgs IS NULL THEN
            verror := 9903628;   -- Falta informar el Nº Registro DGS.
         END IF;
      END IF;

      RETURN verror;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_age_transiciones.f_valida_nregdgs', 2, SQLCODE,
                     SQLERRM);
         RETURN 1;
   END f_valida_nregdgs;

   --Bug 21682 - APD - 25/04/2012
   FUNCTION f_valida_ctipmed(
      pcempres IN NUMBER,
      pcagente IN agentes.cagente%TYPE,
      pctipage IN agentes.ctipage%TYPE,
      pcestant IN agentes.cactivo%TYPE,
      pcestact IN agentes.cactivo%TYPE,
      pctipmed IN agentes.ctipmed%TYPE)
      RETURN NUMBER IS
      verror         NUMBER;
   BEGIN
      verror := 0;

      -- ctipmed (v.f.1062) = 1.-Agente exclusivo, 3.-Banca seguro exclusivo
      IF pctipmed NOT IN(1, 3) THEN
         verror := 9902692;   -- Estado del agente no válido
      END IF;

      RETURN verror;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_age_transiciones.f_valida_ctipmed', 2, SQLCODE,
                     SQLERRM);
         RETURN 1;
   END f_valida_ctipmed;

   --Bug 21682 - APD - 25/04/2012
   FUNCTION f_valida_ctipmed_nregdgs(
      pcempres IN NUMBER,
      pcagente IN agentes.cagente%TYPE,
      pctipage IN agentes.ctipage%TYPE,
      pcestant IN agentes.cactivo%TYPE,
      pcestact IN agentes.cactivo%TYPE,
      pctipmed IN agentes.ctipmed%TYPE,
      pnregdgs IN agentes.nregdgs%TYPE)
      RETURN NUMBER IS
      verror         NUMBER;
   BEGIN
      verror := 0;

      -- ctipmed (v.f.1062) = 1.-Agente exclusivo, 3.-Banca seguro exclusivo
      IF pctipmed IN(1, 3) THEN
         verror := 9902692;   -- Estado del agente no válido
      ELSIF pctipmed NOT IN(1, 3) THEN
         IF pnregdgs IS NULL THEN
            verror := 9903628;   -- Falta informar el Nº Registro DGS.
         END IF;
      END IF;

      RETURN verror;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_age_transiciones.f_valida_ctipmed_nregdgs', 2,
                     SQLCODE, SQLERRM);
         RETURN 1;
   END f_valida_ctipmed_nregdgs;
END pac_age_transiciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_AGE_TRANSICIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_AGE_TRANSICIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_AGE_TRANSICIONES" TO "PROGRAMADORESCSI";
