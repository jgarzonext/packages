--------------------------------------------------------
--  DDL for Function F_DESAGENTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESAGENTE" (
   pcagente   IN       NUMBER,
   ptnombre   IN OUT   VARCHAR2
)
   RETURN NUMBER AUTHID CURRENT_USER
IS
/***********************************************************************
    F_AGENTE: Nombre del Agente.
    ALLIBMFM
***********************************************************************/
   num_err       NUMBER;
BEGIN

   num_err := 100504;                                     -- Agent inexistent
   SELECT f_nombre (sperson, 1, null)
     INTO ptnombre
     FROM agentes
    WHERE cagente = pcagente;

--   num_err := 100534;                                    -- Persona inexistent
   RETURN 0;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN num_err;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESAGENTE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESAGENTE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESAGENTE" TO "PROGRAMADORESCSI";
