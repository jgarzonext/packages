--------------------------------------------------------
--  DDL for Package PK_FRANQUICIAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_FRANQUICIAS" authid current_user IS

 FUNCTION f_codifranq (pcramo NUMBER, pcmodali NUMBER, pctipseg NUMBER, pcactivi NUMBER, cfranq OUT NUMBER) RETURN NUMBER;
 FUNCTION f_versiofranq_garan (pcfranq NUMBER, pdata DATE, pcgarant NUMBER, nfraver OUT NUMBER, clave_sgt OUT NUMBER) RETURN NUMBER;
 FUNCTION f_versiofranq (pcfranq NUMBER, pdata DATE, nfraver OUT NUMBER, clave_sgt OUT NUMBER) RETURN NUMBER;
 FUNCTION f_grupogaran_garan (pcfranq NUMBER, pnfraver NUMBER, pcgarant NUMBER,  ngrpgara OUT NUMBER) RETURN NUMBER;

END Pk_Franquicias;

 
 

/

  GRANT EXECUTE ON "AXIS"."PK_FRANQUICIAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_FRANQUICIAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_FRANQUICIAS" TO "PROGRAMADORESCSI";
