--------------------------------------------------------
--  DDL for Function F_SINISTRE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_SINISTRE" (pnsinies IN NUMBER, pcestsin IN OUT NUMBER,
pfnotifi IN OUT DATE, pfsinies IN OUT DATE, pcusuari IN OUT NUMBER,
ptsinies IN OUT VARCHAR2, pccausin IN OUT NUMBER, psseguro IN OUT NUMBER)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_SINISTRE: Busca los datos generales del siniestro.
	ALLIBSIN - Funciones de siniestros
***********************************************************************/
BEGIN
	SELECT	cestsin,  fnotifi,  fsinies,  cusuari,
		tsinies,  ccausin,  sseguro
	INTO	pcestsin, pfnotifi, pfsinies, pcusuari,
		ptsinies, pccausin, psseguro
	FROM	SINIESTROS
	WHERE	nsinies = pnsinies;
	RETURN 0;
EXCEPTION
	WHEN others THEN
		RETURN 100505;	-- Sinistre inexistent
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_SINISTRE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_SINISTRE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_SINISTRE" TO "PROGRAMADORESCSI";
