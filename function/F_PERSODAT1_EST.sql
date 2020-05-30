--------------------------------------------------------
--  DDL for Function F_PERSODAT1_EST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PERSODAT1_EST" (
  psperson IN NUMBER,
  pcsexper OUT NUMBER,
  pfnacimi OUT DATE,
  pcestado OUT NUMBER,
  psseguro in estseguros.sseguro%type
)
RETURN NUMBER authid current_user IS
/****************************************************************************
	F_persodat1: Obtenir el sexe, la data de naixement i l'estat
		de la persona entrada com a paràmetre.
	ALLIBMFM.

****************************************************************************/
BEGIN
	SELECT csexper, fnacimi, cestper
	INTO pcsexper, pfnacimi, pcestado
	FROM estper_PERSONAS
	WHERE sperson = psperson
      and sseguro = psseguro;
	RETURN (0);
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN 100538;	--Persona inexistent
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_PERSODAT1_EST" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PERSODAT1_EST" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PERSODAT1_EST" TO "PROGRAMADORESCSI";
