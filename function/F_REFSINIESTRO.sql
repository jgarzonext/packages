--------------------------------------------------------
--  DDL for Function F_REFSINIESTRO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_REFSINIESTRO" (pnsinies in NUMBER, pcrefint in out VARCHAR2)
RETURN NUMBER authid current_user IS
/***********************************************************************
 F_REFSINIESTRO: Obtener el campo crefint a partir del identificador del siniestro.
***********************************************************************/
BEGIN
 SELECT crefint
 INTO pcrefint
 FROM siniestros
 WHERE nsinies = pnsinies;
 RETURN 0;
EXCEPTION
 WHEN NO_DATA_FOUND THEN
  pcrefint := pnsinies;
  RETURN 0;
 WHEN OTHERS THEN
  RETURN 105144; -- Error en la lectura de SINIESTROS.
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_REFSINIESTRO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_REFSINIESTRO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_REFSINIESTRO" TO "PROGRAMADORESCSI";
