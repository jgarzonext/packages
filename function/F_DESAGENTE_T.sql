--------------------------------------------------------
--  DDL for Function F_DESAGENTE_T
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESAGENTE_T" (pcagente IN agentes.cagente%TYPE)
   RETURN VARCHAR2 AUTHID CURRENT_USER IS
/***********************************************************************
 F_AGENTE: Retorna nombre del Agente.
***********************************************************************/
   aux_sperson    NUMBER;
   num_err        NUMBER;
   ptnombre       VARCHAR2(250);
BEGIN
   num_err := f_desagente(pcagente, ptnombre);
   RETURN ptnombre;
EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END;

/

  GRANT EXECUTE ON "AXIS"."F_DESAGENTE_T" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESAGENTE_T" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESAGENTE_T" TO "PROGRAMADORESCSI";
