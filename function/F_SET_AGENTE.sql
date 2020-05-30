--------------------------------------------------------
--  DDL for Function F_SET_AGENTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_SET_AGENTE" (pcempres IN NUMBER,
                                        pctipage IN NUMBER) RETURN NUMBER IS
   i NUMBER;
   v NUMBER;
BEGIN
   i := pac_redcomercial.f_get_contador_agente(pcempres, pctipage, v);
   RETURN v;
END f_set_agente;

/

  GRANT EXECUTE ON "AXIS"."F_SET_AGENTE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_SET_AGENTE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_SET_AGENTE" TO "PROGRAMADORESCSI";
