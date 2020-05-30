--------------------------------------------------------
--  DDL for Function FF_DESAGENTE_PER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_DESAGENTE_PER" (pcagente IN agentes.cagente%TYPE)
   RETURN VARCHAR2 AUTHID CURRENT_USER IS
/***********************************************************************
 FF_DESAGENTE_PER: Retorna nombre del Agente como valor
                                      Utiliza las tablas de personas y no la vista para
                                      evitar problemas de visión
***********************************************************************/
   aux_sperson    NUMBER;
   num_err        NUMBER;
   ptnombre       VARCHAR2(300);
BEGIN
   num_err := 100504;   -- Agent inexistent

   SELECT sperson
     INTO aux_sperson
     FROM agentes
    WHERE cagente = pcagente;

   num_err := 100534;   -- Persona inexistent

   SELECT MAX(TRIM(tapelli1) || ' ' || TRIM(tapelli2)
              || DECODE(tnombre, NULL, NULL, ', ' || LTRIM(RTRIM(tnombre))))
     INTO ptnombre
     FROM per_detper   --PERSONAS
    WHERE sperson = aux_sperson;

   RETURN ptnombre;
EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END;

/

  GRANT EXECUTE ON "AXIS"."FF_DESAGENTE_PER" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_DESAGENTE_PER" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_DESAGENTE_PER" TO "PROGRAMADORESCSI";
